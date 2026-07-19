using System.Text.Json;
using Mediator;
using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;

namespace Momentum.Application.Features.Sync;

/// <summary>
/// Orchestrates /v1/sync (ADR 0002 K2-E, GOREV slice-2b1 D4/D5/D6). Push = one txn per op:
/// lock (client -> entity) -> DB dedup -> hydrate -> DOMAIN decides (2a SyncIngest) -> dump delta +
/// outbox + client-clock + dedup in the SAME commit. Then pull (xmin horizon) or full snapshot.
/// The decision recipe lives ONLY in Domain — this handler never re-implements LWW/CRDT/registry (§5).
/// </summary>
public sealed class SyncCommandHandler : ICommandHandler<SyncCommand, SyncResponse>
{
    private const string ProjectIdField = "projectId";

    private readonly ISyncTransaction _transaction;
    private readonly ISyncStore _store;
    private readonly IOutboxWriter _outbox;
    private readonly IProcessedOperations _processed;
    private readonly IClientClock _clientClock;
    private readonly ISyncPuller _puller;
    private readonly TimeProvider _timeProvider;

    public SyncCommandHandler(
        ISyncTransaction transaction,
        ISyncStore store,
        IOutboxWriter outbox,
        IProcessedOperations processed,
        IClientClock clientClock,
        ISyncPuller puller,
        TimeProvider timeProvider)
    {
        _transaction = transaction;
        _store = store;
        _outbox = outbox;
        _processed = processed;
        _clientClock = clientClock;
        _puller = puller;
        _timeProvider = timeProvider;
    }

    public async ValueTask<SyncResponse> Handle(SyncCommand command, CancellationToken cancellationToken)
    {
        var request = command.Request;
        var receiveWall = _timeProvider.GetUtcNow().ToUnixTimeMilliseconds();

        var applied = new List<WireIngestResult>();
        Hlc? maxEffective = null;

        // --- push: one transaction per op (poison op drops only its own txn) ---
        foreach (var wireOp in request.Ops ?? [])
        {
            var result = await ProcessOpAsync(wireOp, receiveWall, cancellationToken);
            applied.Add(WireMapping.ToWire(result));
            if (result is { Code: IngestResultCode.Applied, EffectiveOpHlc: { } effective }
                && (maxEffective is null || effective.CompareTo(maxEffective.Value) > 0))
            {
                maxEffective = effective;
            }
        }

        // --- pull / snapshot (after the client's own pushes are committed) ---
        WireCursor? nextCursor = null;
        var hasMore = false;
        var resyncRequired = false;
        IReadOnlyList<WireChange> changes = [];
        IReadOnlyList<WireSnapshotEntity>? snapshot = null;

        if (request.SinceCursor is null)
        {
            var page = await _puller.SnapshotAsync(command.ActorId, cancellationToken);
            snapshot = page.Entities.Select(ToWire).ToList();
            nextCursor = new WireCursor(page.NextCursor.Xid, page.NextCursor.Seq);
        }
        else
        {
            var since = new SyncCursor(request.SinceCursor.Xid, request.SinceCursor.Seq);
            if (await _puller.ShouldResyncAsync(since, cancellationToken))
            {
                resyncRequired = true; // flag-only: client re-requests with sinceCursor=null (named refinement)
                nextCursor = request.SinceCursor;
            }
            else
            {
                var page = await _puller.PullIncrementalAsync(command.ActorId, since, cancellationToken);
                changes = page.Changes.Select(ToWire).ToList();
                nextCursor = new WireCursor(page.NextCursor.Xid, page.NextCursor.Seq);
                hasMore = page.HasMore;
            }
        }

        // serverHlc: max effective produced now, else last known client clock, else null (informational only).
        WireHlc? serverHlc;
        if (maxEffective is { } produced)
        {
            serverHlc = WireMapping.ToWire(produced);
        }
        else
        {
            var last = await _clientClock.GetAsync(request.ClientId, cancellationToken);
            serverHlc = last is { } value ? WireMapping.ToWire(value) : null;
        }

        return new SyncResponse(serverHlc, nextCursor, hasMore, resyncRequired, applied, changes, snapshot);
    }

    private async ValueTask<IngestResult> ProcessOpAsync(WireOp wireOp, long receiveWall, CancellationToken cancellationToken)
    {
        await using var scope = await _transaction.BeginOpScopeAsync(cancellationToken);
        var op = WireMapping.ToDomain(wireOp);

        // Fixed lock order: client then entity (ADR 0002 K2-A4 / B1 — deadlock-free).
        await _store.LockClientAsync(op.ClientId, cancellationToken);
        await _store.LockEntityAsync(op.EntityType, op.EntityId, cancellationToken);

        // DB dedup precheck (replaces the in-memory dedup; Duplicate is rebuilt from the row).
        var prior = await _processed.GetAsync(op.ClientId, op.OperationId, cancellationToken);
        if (prior is not null)
        {
            await scope.CommitAsync(cancellationToken);
            return prior.Code == IngestResultCode.Applied
                ? new IngestResult(op.OperationId, IngestResultCode.Duplicate, prior.EffectiveOpHlc)
                : new IngestResult(op.OperationId, prior.Code, prior.EffectiveOpHlc);
        }

        // Hydrate the entity + seed the client clock, then let the DOMAIN decide.
        var syncState = new SyncState();
        var entity = syncState.GetOrCreateEntity(op.EntityType, op.EntityId);
        await _store.HydrateAsync(entity, op.EntityType, op.EntityId, cancellationToken);

        var preProjectId = ReadProjectId(op.EntityType, entity);

        var clockStore = new ClientClockStore();
        if (await _clientClock.GetAsync(op.ClientId, cancellationToken) is { } seed)
        {
            clockStore.Merge(op.ClientId, seed);
        }

        var result = new SyncIngest(syncState, clockStore).Ingest(op, receiveWall);

        if (result.Code == IngestResultCode.RejectedInvalid)
        {
            await scope.CommitAsync(cancellationToken); // ERRATA: RejectedInvalid is NOT recorded
            return result;
        }

        if (result is { Code: IngestResultCode.Applied, EffectiveOpHlc: { } effective })
        {
            await _store.PersistDeltaAsync(op, entity, cancellationToken);
            await _clientClock.UpsertGreatestAsync(op.ClientId, effective, cancellationToken);
            await _outbox.WriteAsync(BuildOutbox(wireOp, op, entity, effective, preProjectId, receiveWall), cancellationToken);
        }

        await _processed.RecordAsync(op.ClientId, op.OperationId, result.Code, result.EffectiveOpHlc, cancellationToken);
        await scope.CommitAsync(cancellationToken);
        return result;
    }

    private OutboxRecord BuildOutbox(WireOp wireOp, ChangeOperation op, EntityState entity, Hlc effective, string? preProjectId, long receiveWall)
    {
        var postProjectId = ReadProjectId(op.EntityType, entity);
        var scopeId = TryScope(postProjectId);
        Guid? oldScopeId = null;
        if (op.EntityType == "Task"
            && op.Fields.ContainsKey(ProjectIdField)
            && !string.Equals(preProjectId, postProjectId, StringComparison.Ordinal))
        {
            oldScopeId = TryScope(preProjectId);
        }

        var now = _timeProvider.GetUtcNow();
        return new OutboxRecord(
            AggregateType: op.EntityType,
            AggregateId: op.EntityId,
            OperationId: op.OperationId,
            OwnerId: op.ActorId,
            ScopeId: scopeId,
            OldScopeId: oldScopeId,
            ActorId: op.ActorId,
            EventType: $"{op.EntityType}.changed",
            Payload: WireMapping.ClampedPayload(wireOp, receiveWall),
            Hlc: effective.Encode(),
            OccurredAt: now,
            AvailableAt: now); // slice-2b2 D6-1: ONE clock source (TimeProvider) -- no SQL now() default
    }

    private static string? ReadProjectId(string entityType, EntityState entity) =>
        entityType == "Task" && entity.Fields.TryGetValue(ProjectIdField, out var register) && register.HasValue
            ? register.Value
            : null;

    private static Guid? TryScope(string? projectId) =>
        projectId is not null && Guid.TryParse(projectId, out var scope) ? scope : null;

    private static WireChange ToWire(ChangeRecord change)
    {
        using var document = JsonDocument.Parse(change.PayloadJson);
        return new WireChange(new WireCursor(change.Cursor.Xid, change.Cursor.Seq), document.RootElement.Clone());
    }

    private static WireSnapshotEntity ToWire(SnapshotEntity entity) => new(
        entity.EntityType,
        entity.EntityId,
        entity.Scalars.Select(s => new WireSnapshotScalar(s.Field, s.Value, WireMapping.ToWire(s.Hlc), s.WinOperationId)).ToList(),
        entity.Sets.Select(set => new WireSnapshotSet(
            set.SetName,
            set.Elements.Select(element => new WireSnapshotElement(
                element.Element,
                element.ActiveTags.Select(tag => new WireSnapshotActiveTag(tag.Tag, WireMapping.ToWire(tag.Hlc))).ToList())).ToList())).ToList(),
        entity.Groups.Select(g => new WireSnapshotGroup(g.Group, g.Fields, WireMapping.ToWire(g.Hlc), g.WinOperationId)).ToList());
}
