using Mediator;
using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;

namespace Momentum.Application.Features.Tasks;

/// <summary>GOREV slice-3a D4: GET /v1/tasks. <see cref="Cursor"/> is the ALREADY-DECODED keyset position (endpoint decodes the opaque wire string first).</summary>
public sealed record GetTasksQuery(Guid OwnerId, Guid? ProjectId, bool IncludeDeleted, int Limit, TaskKeysetCursor? Cursor)
    : IQuery<GetTasksResult>;

public sealed record GetTasksResult(IReadOnlyList<TaskProjection> Items, string? NextCursor);
