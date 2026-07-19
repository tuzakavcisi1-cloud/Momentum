namespace Momentum.Domain.Sync;

/// <summary>
/// GOREV slice-3a D2 (ADR 0002 K2-I2): pure, IO-less projection from <see cref="EntityState"/> to the
/// materialized "tasks" row shape -- the SOLE authority (no second implementation of IsDeleted,
/// HasDeleteEditConflict, active-tag-set, or any parsing rule; see ProjectionFields).
/// </summary>
public sealed record TaskProjection(
    Guid EntityId, string? Title, string? Notes, int? Priority,
    DateTimeOffset? DueAt, DateTimeOffset? RemindAt, Guid? ProjectId,
    bool IsDeleted, string? RecurrenceRule, string? ListPos, string? BoardPos,
    string? Status, DateTimeOffset? CompletedAt,
    bool HasDeleteEditConflict, IReadOnlyList<string> MalformedFields, IReadOnlyList<string> Tags)
{
    public static TaskProjection From(Guid entityId, EntityState state)
    {
        ArgumentNullException.ThrowIfNull(state);
        var malformed = new List<string>();

        var title = ProjectionFields.ReadText(state.Fields, "title");
        var notes = ProjectionFields.ReadText(state.Fields, "notes");
        var recurrenceRule = ProjectionFields.ReadText(state.Fields, "recurrenceRule");
        var priority = ProjectionFields.ReadInt(state.Fields, "priority", malformed);
        var dueAt = ProjectionFields.ReadDate(state.Fields, "dueAt", malformed);
        var remindAt = ProjectionFields.ReadDate(state.Fields, "remindAt", malformed);
        var projectId = ProjectionFields.ReadGuid(state.Fields, "projectId", malformed);

        // CHANNEL WARNING (mutant-16's exact target): listPos/boardPos are Fractionals -- they live ONLY
        // in state.Orders (SyncRowHydration -> LoadOrder, ConflictResolver -> ApplyOrder); state.Fields
        // NEVER contains these keys, so reading them from Fields (even defensively, via TryGetValue) would
        // silently return NULL forever.
        var listPos = ProjectionFields.ReadText(state.Orders, "listPos");
        var boardPos = ProjectionFields.ReadText(state.Orders, "boardPos");

        string? status = null;
        DateTimeOffset? completedAt = null;
        if (state.Groups.TryGetValue("completion", out var completion) && completion.HasValue)
        {
            status = ProjectionFields.ReadGroupText(completion.Fields, "status");
            completedAt = ProjectionFields.ReadGroupDate(completion.Fields, "completedAt", malformed);
        }

        var tags = state.TryGetSet("tags", out var tagSet)
            ? tagSet.PresentElements().OrderBy(t => t, StringComparer.Ordinal).ToList()
            : [];

        return new TaskProjection(
            entityId, title, notes, priority, dueAt, remindAt, projectId,
            state.IsDeleted, recurrenceRule, listPos, boardPos, status, completedAt,
            state.HasDeleteEditConflict, ProjectionFields.FinalizeMalformed(malformed), tags);
    }
}
