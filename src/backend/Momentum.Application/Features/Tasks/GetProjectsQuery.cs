using Mediator;
using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;

namespace Momentum.Application.Features.Tasks;

/// <summary>IS-EMRI-o85-B: GET /v1/projects (GetTaskListsQuery'nin birebir deseni).</summary>
public sealed record GetProjectsQuery(Guid OwnerId, bool IncludeDeleted, int Limit, TaskKeysetCursor? Cursor)
    : IQuery<GetProjectsResult>;

public sealed record GetProjectsResult(IReadOnlyList<ProjectProjection> Items, string? NextCursor);
