namespace Momentum.Domain.Sync;

/// <summary>
/// The server ingest pipeline (ADR 0002 §2, GOREV slice-2a D7). Fixed step order:
/// (1) envelope validation, (2) dedup, (3) absurd-HLC check, (4) clamp ALL HLCs, (5) registry
/// enforcement, (6) OR-Set cap pre-check, (7) effective op-HLC, (8) resolver apply, (9) record.
/// Dedup precedes the receive-time-dependent steps so replays are deterministic. No partial
/// application in any branch.
/// </summary>
public sealed class SyncIngest
{
    /// <summary>Per-(entity,set,element) soft cap on active add-tags (ADR 0002 K2-C2; admission-control).</summary>
    public const int SetTagCap = 100;

    private readonly SyncState _state;
    private readonly EffectiveHlcAssigner _assigner;
    private readonly ConflictResolver _resolver = new();
    private readonly FieldStrategyRegistry _registry;
    private readonly long _maxForwardSkewMs;
    private readonly long _absurdForwardMs;
    private readonly Lock _gate = new();

    public SyncIngest(
        SyncState state,
        ClientClockStore clocks,
        FieldStrategyRegistry? registry = null,
        long maxForwardSkewMs = HlcClamp.MaxForwardSkewMs,
        long absurdForwardMs = HlcClamp.AbsurdForwardMs)
    {
        ArgumentNullException.ThrowIfNull(state);
        ArgumentNullException.ThrowIfNull(clocks);
        _state = state;
        _assigner = new EffectiveHlcAssigner(clocks);
        _registry = registry ?? FieldStrategyRegistry.Default;
        _maxForwardSkewMs = maxForwardSkewMs;
        _absurdForwardMs = absurdForwardMs;
    }

    public IngestResult Ingest(ChangeOperation op, long serverReceiveWallMs)
    {
        ArgumentNullException.ThrowIfNull(op);

        // 2a concurrency contract: the whole ingest is serialized under one global lock (in-memory
        // reference model favors correctness over parallelism).
        // per-client advisory lock -> slice-2b (DB).
        lock (_gate)
        {
            // (1) envelope validation (RejectedInvalid closed list) -- returned immediately, not recorded.
            if (!IsEnvelopeValid(op))
            {
                return new IngestResult(op.OperationId, IngestResultCode.RejectedInvalid, null);
            }

            // (2) dedup (before receive-time-dependent steps -> replay determinism).
            if (_state.TryGetProcessed(op.ClientId, op.OperationId, out var prior))
            {
                return Dedup(prior);
            }

            // (3) absurd-HLC check over ALL HLCs (op reject if any is absurd).
            if (AnyAbsurd(op, serverReceiveWallMs))
            {
                return Record(op, new IngestResult(op.OperationId, IngestResultCode.RejectedAbsurdHlc, null));
            }

            // (4) clamp ALL HLCs (op, field, set add/remove, group, order).
            var clamped = ClampAll(op, serverReceiveWallMs);

            // (5) registry enforcement (whole-op; no remap).
            if (!_registry.IsOperationValid(clamped))
            {
                return Record(op, new IngestResult(op.OperationId, IngestResultCode.RejectedRegistryViolation, null));
            }

            // (6) OR-Set cap pre-check.
            if (ExceedsSetCap(clamped))
            {
                return Record(op, new IngestResult(op.OperationId, IngestResultCode.RejectedSetCapExceeded, null));
            }

            // (7) effective op-HLC (per-client monotonic; op-HLC only).
            var effective = _assigner.AssignOpHlc(clamped.ClientId, clamped.OpHlc);

            // (8) resolver apply (atomic).
            var entity = _state.GetOrCreateEntity(clamped.EntityType, clamped.EntityId);
            _resolver.Apply(entity, clamped);

            // (9) record.
            return Record(op, new IngestResult(op.OperationId, IngestResultCode.Applied, effective));
        }
    }

    /// <summary>gcHorizon compaction of one set (ADR 0002 K2-C2), serialized with ingest.</summary>
    public void Compact(string entityType, Guid entityId, string setName, Hlc horizon)
    {
        lock (_gate)
        {
            if (_state.Entities.TryGetValue((entityType, entityId), out var entity)
                && entity.TryGetSet(setName, out var set))
            {
                set.CompactBelow(horizon);
            }
        }
    }

    private static IngestResult Dedup(IngestResult prior) =>
        prior.Code == IngestResultCode.Applied
            ? new IngestResult(prior.OperationId, IngestResultCode.Duplicate, prior.EffectiveOpHlc)
            : prior; // a recorded reject replays as the same reject code

    private IngestResult Record(ChangeOperation op, IngestResult result)
    {
        _state.RecordProcessed(op.ClientId, op.OperationId, result);
        return result;
    }

    private static bool IsEnvelopeValid(ChangeOperation op)
    {
        if (op.OperationId == Guid.Empty
            || op.ClientId == Guid.Empty
            || op.EntityId == Guid.Empty
            || op.ActorId == Guid.Empty)
        {
            return false;
        }

        foreach (var hlc in EnumerateHlcs(op))
        {
            if (hlc.WallMs < 0)
            {
                return false;
            }
        }

        return op.Fields.Count > 0 || op.Sets.Count > 0 || op.Groups.Count > 0 || op.Order.Count > 0;
    }

    private bool AnyAbsurd(ChangeOperation op, long serverReceiveWallMs)
    {
        foreach (var hlc in EnumerateHlcs(op))
        {
            if (HlcClamp.IsAbsurd(hlc, serverReceiveWallMs, _absurdForwardMs))
            {
                return true;
            }
        }

        return false;
    }

    private ChangeOperation ClampAll(ChangeOperation op, long recv)
    {
        Hlc Clamp(Hlc hlc) => HlcClamp.Clamp(hlc, recv, _maxForwardSkewMs);

        var fields = op.Fields.ToDictionary(
            kv => kv.Key,
            kv => kv.Value with { Hlc = Clamp(kv.Value.Hlc) },
            StringComparer.Ordinal);

        var order = op.Order.ToDictionary(
            kv => kv.Key,
            kv => kv.Value with { Hlc = Clamp(kv.Value.Hlc) },
            StringComparer.Ordinal);

        var groups = op.Groups.ToDictionary(
            kv => kv.Key,
            kv => kv.Value with { Hlc = Clamp(kv.Value.Hlc) },
            StringComparer.Ordinal);

        var sets = op.Sets.ToDictionary(
            kv => kv.Key,
            kv => new SetDelta(
                kv.Value.Adds.Select(a => a with { Hlc = Clamp(a.Hlc) }).ToList(),
                kv.Value.Removes.Select(r => r with { Hlc = Clamp(r.Hlc) }).ToList()),
            StringComparer.Ordinal);

        return op with { OpHlc = Clamp(op.OpHlc), Fields = fields, Order = order, Groups = groups, Sets = sets };
    }

    private bool ExceedsSetCap(ChangeOperation clamped)
    {
        EntityState? entity = _state.Entities.TryGetValue((clamped.EntityType, clamped.EntityId), out var existing)
            ? existing
            : null;

        foreach (var (setName, delta) in clamped.Sets)
        {
            OrSetField? set = null;
            if (entity is not null && entity.TryGetSet(setName, out var found))
            {
                set = found;
            }

            var newActiveByElement = new Dictionary<string, HashSet<Guid>>(StringComparer.Ordinal);
            foreach (var add in delta.Adds)
            {
                var newActive = set is null || set.IsNewActiveTag(add.Element, add.Tag);
                if (!newActive)
                {
                    continue; // already-active or born-dead adds are not counted (exact cap formula)
                }

                if (!newActiveByElement.TryGetValue(add.Element, out var tags))
                {
                    tags = [];
                    newActiveByElement[add.Element] = tags;
                }

                tags.Add(add.Tag);
            }

            foreach (var (element, newTags) in newActiveByElement)
            {
                var current = set?.ActiveTagCount(element) ?? 0;
                if (current + newTags.Count > SetTagCap)
                {
                    return true;
                }
            }
        }

        return false;
    }

    private static IEnumerable<Hlc> EnumerateHlcs(ChangeOperation op)
    {
        yield return op.OpHlc;

        foreach (var write in op.Fields.Values)
        {
            yield return write.Hlc;
        }

        foreach (var write in op.Order.Values)
        {
            yield return write.Hlc;
        }

        foreach (var group in op.Groups.Values)
        {
            yield return group.Hlc;
        }

        foreach (var delta in op.Sets.Values)
        {
            foreach (var add in delta.Adds)
            {
                yield return add.Hlc;
            }

            foreach (var remove in delta.Removes)
            {
                yield return remove.Hlc;
            }
        }
    }
}
