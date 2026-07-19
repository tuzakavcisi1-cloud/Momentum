using System.Text;

// Independent oracle engine (GOREV slice-2a D8). Models ingest steps 1-9 BIREBIR, in a naive, explicit
// style. MUST NOT reference Momentum.Domain.Sync (isolation rule). Correctness > speed.
namespace Momentum.SyncCore.Tests.Oracle;

public sealed class OracleEngine
{
    public const int SetTagCap = 100;
    public const long MaxForwardSkewMs = 300_000;
    public const long AbsurdForwardMs = 31_536_000_000;

    private const string IsDeletedField = "isDeleted";
    private const string DeletedValue = "true";

    private readonly long _maxForwardSkewMs;
    private readonly long _absurdForwardMs;

    private readonly Dictionary<Guid, OracleHlc> _clocks = [];
    private readonly Dictionary<(string EntityType, Guid EntityId), Entity> _entities = [];
    private readonly Dictionary<(Guid ClientId, Guid OperationId), OracleResult> _processed = [];

    private static readonly IReadOnlyDictionary<string, EntityDef> Registry = BuildRegistry();

    public OracleEngine(long maxForwardSkewMs = MaxForwardSkewMs, long absurdForwardMs = AbsurdForwardMs)
    {
        _maxForwardSkewMs = maxForwardSkewMs;
        _absurdForwardMs = absurdForwardMs;
    }

    public OracleResult Ingest(OracleOp op, long serverReceiveWallMs)
    {
        // (1) envelope validation (closed list) -- returned immediately, not recorded.
        if (!IsValid(op))
        {
            return new OracleResult(op.OperationId, OracleResultCode.RejectedInvalid, null);
        }

        // (2) dedup.
        if (_processed.TryGetValue((op.ClientId, op.OperationId), out var prior))
        {
            return prior.Code == OracleResultCode.Applied
                ? new OracleResult(prior.OperationId, OracleResultCode.Duplicate, prior.EffectiveOpHlc)
                : prior;
        }

        // (3) absurd-HLC over ALL HLCs.
        if (AllHlcs(op).Any(h => h.WallMs > serverReceiveWallMs + _absurdForwardMs))
        {
            return Record(op, new OracleResult(op.OperationId, OracleResultCode.RejectedAbsurdHlc, null));
        }

        // (4) clamp ALL HLCs.
        var clamped = ClampAll(op, serverReceiveWallMs);

        // (5) registry enforcement.
        if (!IsRegistryValid(clamped))
        {
            return Record(op, new OracleResult(op.OperationId, OracleResultCode.RejectedRegistryViolation, null));
        }

        // (6) OR-Set cap.
        if (ExceedsCap(clamped))
        {
            return Record(op, new OracleResult(op.OperationId, OracleResultCode.RejectedSetCapExceeded, null));
        }

        // (7) effective op-HLC (per-client monotonic; op-HLC only).
        var effective = AssignEffective(clamped.ClientId, clamped.OpHlc);

        // (8) apply.
        Apply(clamped);

        // (9) record.
        return Record(op, new OracleResult(op.OperationId, OracleResultCode.Applied, effective));
    }

    public void Compact(string entityType, Guid entityId, string setName, OracleHlc horizon)
    {
        if (_entities.TryGetValue((entityType, entityId), out var entity)
            && entity.Sets.TryGetValue(setName, out var set))
        {
            CompactSet(set, horizon);
        }
    }

    // ---- step helpers -----------------------------------------------------------------------------

    private static bool IsValid(OracleOp op)
    {
        if (op.OperationId == Guid.Empty || op.ClientId == Guid.Empty
            || op.EntityId == Guid.Empty || op.ActorId == Guid.Empty)
        {
            return false;
        }

        if (AllHlcs(op).Any(h => h.WallMs < 0))
        {
            return false;
        }

        return op.Fields.Count > 0 || op.Sets.Count > 0 || op.Groups.Count > 0 || op.Order.Count > 0;
    }

    private OracleResult Record(OracleOp op, OracleResult result)
    {
        _processed[(op.ClientId, op.OperationId)] = result;
        return result;
    }

    private static IEnumerable<OracleHlc> AllHlcs(OracleOp op)
    {
        yield return op.OpHlc;
        foreach (var w in op.Fields.Values)
        {
            yield return w.Hlc;
        }

        foreach (var w in op.Order.Values)
        {
            yield return w.Hlc;
        }

        foreach (var g in op.Groups.Values)
        {
            yield return g.Hlc;
        }

        foreach (var s in op.Sets.Values)
        {
            foreach (var a in s.Adds)
            {
                yield return a.Hlc;
            }

            foreach (var r in s.Removes)
            {
                yield return r.Hlc;
            }
        }
    }

    private OracleOp ClampAll(OracleOp op, long recv)
    {
        OracleHlc C(OracleHlc h) => h with { WallMs = Math.Min(h.WallMs, recv + _maxForwardSkewMs) };

        return op with
        {
            OpHlc = C(op.OpHlc),
            Fields = op.Fields.ToDictionary(kv => kv.Key, kv => kv.Value with { Hlc = C(kv.Value.Hlc) }, StringComparer.Ordinal),
            Order = op.Order.ToDictionary(kv => kv.Key, kv => kv.Value with { Hlc = C(kv.Value.Hlc) }, StringComparer.Ordinal),
            Groups = op.Groups.ToDictionary(kv => kv.Key, kv => kv.Value with { Hlc = C(kv.Value.Hlc) }, StringComparer.Ordinal),
            Sets = op.Sets.ToDictionary(
                kv => kv.Key,
                kv => new OracleSetDelta(
                    kv.Value.Adds.Select(a => a with { Hlc = C(a.Hlc) }).ToList(),
                    kv.Value.Removes.Select(r => r with { Hlc = C(r.Hlc) }).ToList()),
                StringComparer.Ordinal),
        };
    }

    private static bool IsRegistryValid(OracleOp op)
    {
        if (!Registry.TryGetValue(op.EntityType, out var def))
        {
            return false;
        }

        if (op.Fields.Keys.Any(k => !def.Scalars.Contains(k)))
        {
            return false;
        }

        if (op.Sets.Keys.Any(k => !def.OrSets.Contains(k)))
        {
            return false;
        }

        if (op.Order.Keys.Any(k => !def.Fractionals.Contains(k)))
        {
            return false;
        }

        foreach (var (groupName, write) in op.Groups)
        {
            if (!def.Groups.TryGetValue(groupName, out var members) || write.Fields.Keys.Any(m => !members.Contains(m)))
            {
                return false;
            }
        }

        return true;
    }

    private bool ExceedsCap(OracleOp op)
    {
        _entities.TryGetValue((op.EntityType, op.EntityId), out var entity);
        foreach (var (setName, delta) in op.Sets)
        {
            OrSet? set = null;
            entity?.Sets.TryGetValue(setName, out set);

            var newActive = new Dictionary<string, HashSet<Guid>>(StringComparer.Ordinal);
            foreach (var add in delta.Adds)
            {
                if (set is not null && !IsNewActive(set, add.Element, add.Tag))
                {
                    continue;
                }

                if (!newActive.TryGetValue(add.Element, out var tags))
                {
                    tags = [];
                    newActive[add.Element] = tags;
                }

                tags.Add(add.Tag);
            }

            foreach (var (element, tags) in newActive)
            {
                var current = set is null ? 0 : ActiveCount(set, element);
                if (current + tags.Count > SetTagCap)
                {
                    return true;
                }
            }
        }

        return false;
    }

    private OracleHlc AssignEffective(Guid clientId, OracleHlc clampedOpHlc)
    {
        OracleHlc candidate;
        if (_clocks.TryGetValue(clientId, out var last))
        {
            var bumped = last.Counter == uint.MaxValue
                ? new OracleHlc(last.WallMs + 1, 0, last.ClientId)
                : new OracleHlc(last.WallMs, last.Counter + 1, last.ClientId);
            candidate = clampedOpHlc.CompareTo(bumped) >= 0 ? clampedOpHlc : bumped;
        }
        else
        {
            candidate = clampedOpHlc;
        }

        if (!_clocks.TryGetValue(clientId, out var cur) || candidate.CompareTo(cur) > 0)
        {
            _clocks[clientId] = candidate;
            return candidate;
        }

        return cur;
    }

    private void Apply(OracleOp op)
    {
        var entity = GetOrCreateEntity(op.EntityType, op.EntityId);

        foreach (var (name, w) in op.Fields)
        {
            ApplyLww(entity.Fields, name, w, op.OperationId);
        }

        foreach (var (name, w) in op.Order)
        {
            ApplyLww(entity.Orders, name, w, op.OperationId);
        }

        foreach (var (name, w) in op.Groups)
        {
            var candidate = new OracleKey(w.Hlc, op.OperationId);
            if (!entity.Groups.TryGetValue(name, out var cur) || candidate.CompareTo(cur.Key) > 0)
            {
                entity.Groups[name] = (new Dictionary<string, string?>(w.Fields, StringComparer.Ordinal), candidate);
            }
        }

        foreach (var (setName, delta) in op.Sets)
        {
            if (!entity.Sets.TryGetValue(setName, out var set))
            {
                set = new OrSet();
                entity.Sets[setName] = set;
            }

            foreach (var add in delta.Adds)
            {
                var el = GetElement(set, add.Element);

                // ERRATA E-1 (D1b, GOREV slice-2c): independent fix -- written in the oracle's own naive
                // style, NOT copied from Momentum.Domain.Sync.OrSetField (isolation rule, top of file). A
                // CvRDT merge must be a semilattice JOIN: keep whichever stamp compares greater under the
                // full Hlc order. "First wins" (the original oracle bug, mirroring production's own) is
                // idempotent but not commutative -- P3 (OracleDiffProperty) diverges from production
                // without this fix (KANIT/slice-2c/d1b-justification-p3-diverges-after-d1-alone.txt).
                if (!el.Adds.TryGetValue(add.Tag, out var existingStamp) || add.Hlc.CompareTo(existingStamp) > 0)
                {
                    el.Adds[add.Tag] = add.Hlc;
                }
            }

            foreach (var remove in delta.Removes)
            {
                var el = GetElement(set, remove.Element);
                el.RemoveStamps.Add(remove.Hlc);
                foreach (var observed in remove.Observed)
                {
                    el.Cancelled.Add(Resolve(el, observed));
                }
            }
        }
    }

    private static void ApplyLww(Dictionary<string, (string? Value, OracleKey Key)> map, string name, OracleFieldWrite w, Guid opId)
    {
        var candidate = new OracleKey(w.Hlc, opId);
        if (!map.TryGetValue(name, out var cur) || candidate.CompareTo(cur.Key) > 0)
        {
            map[name] = (w.Value, candidate);
        }
    }

    // ---- OR-Set helpers ---------------------------------------------------------------------------

    private static Element GetElement(OrSet set, string element)
    {
        if (!set.Elements.TryGetValue(element, out var el))
        {
            el = new Element();
            set.Elements[element] = el;
        }

        return el;
    }

    private static Guid Resolve(Element el, Guid tag)
    {
        while (el.Remap.TryGetValue(tag, out var next))
        {
            tag = next;
        }

        return tag;
    }

    private static bool IsNewActive(OrSet set, string element, Guid tag)
    {
        if (!set.Elements.TryGetValue(element, out var el))
        {
            return true;
        }

        return !el.Cancelled.Contains(tag) && !el.Adds.ContainsKey(tag);
    }

    private static int ActiveCount(OrSet set, string element)
    {
        if (!set.Elements.TryGetValue(element, out var el))
        {
            return 0;
        }

        return el.Adds.Keys.Count(t => !el.Cancelled.Contains(t));
    }

    private static bool IsPresent(Element el) => el.Adds.Keys.Any(t => !el.Cancelled.Contains(t));

    private static void CompactSet(OrSet set, OracleHlc horizon)
    {
        foreach (var el in set.Elements.Values)
        {
            var belowActive = el.Adds
                .Where(kv => !el.Cancelled.Contains(kv.Key) && kv.Value.CompareTo(horizon) < 0)
                .Select(kv => kv.Key)
                .ToList();

            if (belowActive.Count < 1)
            {
                continue;
            }

            var canonical = belowActive
                .OrderByDescending(t => el.Adds[t].Encode(), StringComparer.Ordinal)
                .ThenByDescending(t => t.ToString("N"), StringComparer.Ordinal)
                .First();

            foreach (var tag in belowActive)
            {
                if (tag == canonical)
                {
                    continue;
                }

                el.Adds.Remove(tag);
                el.Remap[tag] = canonical;
            }
        }
    }

    private Entity GetOrCreateEntity(string entityType, Guid entityId)
    {
        var key = (entityType, entityId);
        if (!_entities.TryGetValue(key, out var entity))
        {
            entity = new Entity();
            _entities[key] = entity;
        }

        return entity;
    }

    // ---- observational projection (D8 comparison surface) -----------------------------------------

    public string Project()
    {
        var builder = new StringBuilder();
        foreach (var ((entityType, entityId), entity) in _entities
                     .OrderBy(e => e.Key.EntityType, StringComparer.Ordinal)
                     .ThenBy(e => e.Key.EntityId.ToString("N"), StringComparer.Ordinal))
        {
            builder.Append("E|").Append(entityType).Append('|').Append(entityId.ToString("N")).Append('\n');

            foreach (var (name, cell) in entity.Fields.OrderBy(f => f.Key, StringComparer.Ordinal))
            {
                builder.Append("F|").Append(name).Append('|').Append(ValueRepr(cell.Value)).Append('|').Append(cell.Key.Encode()).Append('\n');
            }

            foreach (var (name, cell) in entity.Orders.OrderBy(f => f.Key, StringComparer.Ordinal))
            {
                builder.Append("O|").Append(name).Append('|').Append(ValueRepr(cell.Value)).Append('|').Append(cell.Key.Encode()).Append('\n');
            }

            foreach (var (name, cell) in entity.Groups.OrderBy(g => g.Key, StringComparer.Ordinal))
            {
                var members = string.Join(",", cell.Fields
                    .OrderBy(m => m.Key, StringComparer.Ordinal)
                    .Select(m => m.Key + "=" + ValueRepr(m.Value)));
                builder.Append("G|").Append(name).Append('|').Append(members).Append('|').Append(cell.Key.Encode()).Append('\n');
            }

            foreach (var (name, set) in entity.Sets.OrderBy(s => s.Key, StringComparer.Ordinal))
            {
                var present = set.Elements
                    .Where(e => IsPresent(e.Value))
                    .Select(e => e.Key)
                    .OrderBy(e => e, StringComparer.Ordinal);
                builder.Append("S|").Append(name).Append('|').Append(string.Join(",", present)).Append('\n');
            }

            builder.Append("C|").Append(HasDeleteEditConflict(entity) ? "1" : "0").Append('\n');
        }

        return builder.ToString();
    }

    private static string ValueRepr(string? value) => value is null ? "<null>" : value;

    private static bool HasDeleteEditConflict(Entity entity)
    {
        if (!entity.Fields.TryGetValue(IsDeletedField, out var del) || !string.Equals(del.Value, DeletedValue, StringComparison.Ordinal))
        {
            return false;
        }

        var delKey = del.Key;

        foreach (var (name, cell) in entity.Fields)
        {
            if (!string.Equals(name, IsDeletedField, StringComparison.Ordinal) && cell.Key.CompareTo(delKey) > 0)
            {
                return true;
            }
        }

        if (entity.Orders.Values.Any(c => c.Key.CompareTo(delKey) > 0))
        {
            return true;
        }

        if (entity.Groups.Values.Any(c => c.Key.CompareTo(delKey) > 0))
        {
            return true;
        }

        foreach (var set in entity.Sets.Values)
        {
            var max = MaxStamp(set);
            if (max is { } m && m.CompareTo(delKey.Hlc) > 0)
            {
                return true;
            }
        }

        return false;
    }

    private static OracleHlc? MaxStamp(OrSet set)
    {
        OracleHlc? max = null;
        foreach (var el in set.Elements.Values)
        {
            foreach (var h in el.Adds.Values)
            {
                if (max is null || h.CompareTo(max.Value) > 0)
                {
                    max = h;
                }
            }

            foreach (var h in el.RemoveStamps)
            {
                if (max is null || h.CompareTo(max.Value) > 0)
                {
                    max = h;
                }
            }
        }

        return max;
    }

    // ---- registry table (mirror of ADR 0002 K2-B2) ------------------------------------------------

    private sealed record EntityDef(
        HashSet<string> Scalars,
        HashSet<string> OrSets,
        HashSet<string> Fractionals,
        Dictionary<string, HashSet<string>> Groups);

    private static IReadOnlyDictionary<string, EntityDef> BuildRegistry()
    {
        static HashSet<string> S(params string[] xs) => new(xs, StringComparer.Ordinal);

        return new Dictionary<string, EntityDef>(StringComparer.Ordinal)
        {
            ["Task"] = new(
                S("title", "notes", "priority", "dueAt", "remindAt", "projectId", "isDeleted", "recurrenceRule"),
                S("tags", "assignees", "checklistItems"),
                S("listPos", "boardPos"),
                new Dictionary<string, HashSet<string>>(StringComparer.Ordinal) { ["completion"] = S("status", "completedAt") }),
            ["Project"] = new(
                S("name", "color", "isDeleted"),
                S("members"),
                S("pos"),
                new Dictionary<string, HashSet<string>>(StringComparer.Ordinal)),
            ["TaskList"] = new(
                S("name", "isDeleted"),
                S(),
                S("pos"),
                new Dictionary<string, HashSet<string>>(StringComparer.Ordinal)),
            ["Tag"] = new(
                S("label", "color", "isDeleted"),
                S(),
                S(),
                new Dictionary<string, HashSet<string>>(StringComparer.Ordinal)),
        };
    }

    // ---- naive mutable state ----------------------------------------------------------------------

    private sealed class Entity
    {
        public Dictionary<string, (string? Value, OracleKey Key)> Fields { get; } = new(StringComparer.Ordinal);

        public Dictionary<string, (string? Value, OracleKey Key)> Orders { get; } = new(StringComparer.Ordinal);

        public Dictionary<string, (Dictionary<string, string?> Fields, OracleKey Key)> Groups { get; } = new(StringComparer.Ordinal);

        public Dictionary<string, OrSet> Sets { get; } = new(StringComparer.Ordinal);
    }

    private sealed class OrSet
    {
        public Dictionary<string, Element> Elements { get; } = new(StringComparer.Ordinal);
    }

    private sealed class Element
    {
        public Dictionary<Guid, OracleHlc> Adds { get; } = [];

        public HashSet<Guid> Cancelled { get; } = [];

        public Dictionary<Guid, Guid> Remap { get; } = [];

        public List<OracleHlc> RemoveStamps { get; } = [];
    }
}
