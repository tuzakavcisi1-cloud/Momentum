namespace Momentum.Domain.Sync;

/// <summary>
/// Layered conflict resolution (ADR 0002 §2.C): applies a fully-clamped op's writes to an
/// <see cref="EntityState"/> — per-field LWW, co-resolved group REPLACE, OR-Set add/remove, and the
/// Order channel (scalar-LWW mechanic). This is step (8) of ingest; the caller guarantees atomicity
/// (all-or-nothing at the op boundary — no partial application).
/// </summary>
public sealed class ConflictResolver
{
    public void Apply(EntityState entity, ChangeOperation clampedOp)
    {
        ArgumentNullException.ThrowIfNull(entity);
        ArgumentNullException.ThrowIfNull(clampedOp);

        foreach (var (name, write) in clampedOp.Fields)
        {
            entity.ApplyField(name, write, clampedOp.OperationId);
        }

        foreach (var (name, write) in clampedOp.Order)
        {
            // server-authoritative rebalance -> slice-2b+; here Order is plain scalar-LWW on an opaque key.
            entity.ApplyOrder(name, write, clampedOp.OperationId);
        }

        foreach (var (name, write) in clampedOp.Groups)
        {
            entity.ApplyGroup(name, write, clampedOp.OperationId);
        }

        foreach (var (setName, delta) in clampedOp.Sets)
        {
            var set = entity.GetOrCreateSet(setName);
            foreach (var add in delta.Adds)
            {
                set.ApplyAdd(add);
            }

            foreach (var remove in delta.Removes)
            {
                set.ApplyRemove(remove);
            }
        }
    }
}
