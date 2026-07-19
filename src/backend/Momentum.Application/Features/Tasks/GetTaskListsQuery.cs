using Mediator;
using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;

namespace Momentum.Application.Features.Tasks;

/// <summary>GOREV slice-3a D4: GET /v1/task-lists.</summary>
public sealed record GetTaskListsQuery(Guid OwnerId, bool IncludeDeleted, int Limit, TaskKeysetCursor? Cursor)
    : IQuery<GetTaskListsResult>;

public sealed record GetTaskListsResult(IReadOnlyList<TaskListProjection> Items, string? NextCursor);
