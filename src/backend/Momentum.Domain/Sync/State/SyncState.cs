namespace Momentum.Domain.Sync;

/// <summary>
/// In-memory sync state: <c>(entityType, entityId) -&gt; </c><see cref="EntityState"/> plus the
/// <c>processed_operations</c> dedup table (<c>(clientId, operationId) -&gt; </c><see cref="IngestResult"/>),
/// which stores each operation's ORIGINAL result. No IO (ADR 0002 §3 shape-alignment).
/// </summary>
public sealed class SyncState
{
    private readonly Dictionary<(string EntityType, Guid EntityId), EntityState> _entities = [];
    private readonly Dictionary<(Guid ClientId, Guid OperationId), IngestResult> _processedOps = [];

    public IReadOnlyDictionary<(string EntityType, Guid EntityId), EntityState> Entities => _entities;

    public IReadOnlyDictionary<(Guid ClientId, Guid OperationId), IngestResult> ProcessedOps => _processedOps;

    public EntityState GetOrCreateEntity(string entityType, Guid entityId)
    {
        var key = (entityType, entityId);
        if (!_entities.TryGetValue(key, out var state))
        {
            state = new EntityState();
            _entities[key] = state;
        }

        return state;
    }

    public bool TryGetProcessed(Guid clientId, Guid operationId, out IngestResult result) =>
        _processedOps.TryGetValue((clientId, operationId), out result!);

    public void RecordProcessed(Guid clientId, Guid operationId, IngestResult result) =>
        _processedOps[(clientId, operationId)] = result;
}
