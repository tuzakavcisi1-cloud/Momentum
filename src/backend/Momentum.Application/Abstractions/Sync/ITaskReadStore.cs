using Momentum.Domain.Sync;

namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// GOREV slice-3a D4 (ADR 0002 K2-I2): the read side. ALL SQL for the read API lives in the
/// Infrastructure implementation of this port -- SQL performs presentation ORDERING ONLY (winner
/// selection / stamp comparison / conflict decisions are Domain-only, ADR 0002 kirmizi cizgi).
/// Every method REQUIRES an <paramref name="ownerId"/> filter (mutant-4/5/15's target).
/// </summary>
public interface ITaskReadStore
{
    Task<IReadOnlyList<TaskProjection>> ListTasksAsync(
        Guid ownerId, Guid? projectId, bool includeDeleted, int limit, TaskKeysetCursor? cursor, CancellationToken cancellationToken);

    /// <summary>Owner-scoped by-id lookup. A soft-deleted task still returns (with its flags) -- only "not owned" or "not found" is null.</summary>
    Task<TaskProjection?> GetTaskByIdAsync(Guid ownerId, Guid entityId, CancellationToken cancellationToken);

    Task<IReadOnlyList<TaskListProjection>> ListTaskListsAsync(
        Guid ownerId, bool includeDeleted, int limit, TaskKeysetCursor? cursor, CancellationToken cancellationToken);

    // IS-EMRI-o85-B: ListTaskListsAsync'in birebir imzasi (ayni iki-dalli keyset kurali gecerli).
    Task<IReadOnlyList<ProjectProjection>> ListProjectsAsync(
        Guid ownerId, bool includeDeleted, int limit, TaskKeysetCursor? cursor, CancellationToken cancellationToken);
}

/// <summary>
/// Decoded keyset position (D4 IKI DALLI pin). A <c>null</c> <see cref="TaskKeysetCursor"/> REFERENCE
/// means "no cursor" (first page, unfiltered); a non-null cursor whose <see cref="Pos"/> is itself
/// <c>null</c> means "resume inside the NULL-position partition" -- these are DIFFERENT states, never
/// conflated (mutant-12's target: dropping the "OR list_pos IS NULL" arm collapses the null partition).
/// </summary>
public sealed record TaskKeysetCursor(string? Pos, Guid EntityId);
