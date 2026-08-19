using Mediator;
using Momentum.Application.Abstractions.Sync;

namespace Momentum.Application.Features.Tasks;

/// <summary>IS-EMRI-o85-B: GetTaskListsQueryHandler'in birebir deseni.</summary>
public sealed class GetProjectsQueryHandler(ITaskReadStore store) : IQueryHandler<GetProjectsQuery, GetProjectsResult>
{
    public async ValueTask<GetProjectsResult> Handle(GetProjectsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        var fetched = await store.ListProjectsAsync(query.OwnerId, query.IncludeDeleted, query.Limit + 1, query.Cursor, cancellationToken);

        var hasMore = fetched.Count > query.Limit;
        var items = hasMore ? fetched.Take(query.Limit).ToList() : fetched;
        var nextCursor = hasMore
            ? TaskCursorCodec.Encode(new TaskKeysetCursor(items[^1].Pos, items[^1].EntityId))
            : null;

        return new GetProjectsResult(items, nextCursor);
    }
}
