namespace Momentum.Domain.Sync;

/// <summary>
/// GOREV slice-3a D2 (ADR 0002 K2-I2): pure, IO-less projection from <see cref="EntityState"/> to the
/// materialized "task_lists" row shape. TaskList's registry has no int/date/Guid scalar (only
/// name/isDeleted/pos), so <see cref="MalformedFields"/> is always empty for this entity type.
/// </summary>
public sealed record TaskListProjection(
    Guid EntityId, string? Name, bool IsDeleted, string? Pos,
    bool HasDeleteEditConflict, IReadOnlyList<string> MalformedFields)
{
    public static TaskListProjection From(Guid entityId, EntityState state)
    {
        ArgumentNullException.ThrowIfNull(state);
        var malformed = new List<string>();

        var name = ProjectionFields.ReadText(state.Fields, "name");
        // CHANNEL WARNING (mutant-16): pos is a Fractional -- lives ONLY in state.Orders.
        var pos = ProjectionFields.ReadText(state.Orders, "pos");

        return new TaskListProjection(
            entityId, name, state.IsDeleted, pos, state.HasDeleteEditConflict, ProjectionFields.FinalizeMalformed(malformed));
    }
}
