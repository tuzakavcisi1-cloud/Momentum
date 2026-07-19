using Mediator;
using Momentum.Application.Abstractions.Sync;

namespace Momentum.Application.Features.Tasks;

/// <summary>Fetches limit+1 rows to compute hasMore/nextCursor without a second COUNT query.</summary>
public sealed class GetTasksQueryHandler(ITaskReadStore store) : IQueryHandler<GetTasksQuery, GetTasksResult>
{
    public async ValueTask<GetTasksResult> Handle(GetTasksQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        var fetched = await store.ListTasksAsync(
            query.OwnerId, query.ProjectId, query.IncludeDeleted, query.Limit + 1, query.Cursor, cancellationToken);

        var hasMore = fetched.Count > query.Limit;
        var items = hasMore ? fetched.Take(query.Limit).ToList() : fetched;
        var nextCursor = hasMore
            ? TaskCursorCodec.Encode(new TaskKeysetCursor(items[^1].ListPos, items[^1].EntityId))
            : null;

        return new GetTasksResult(items, nextCursor);
    }
}
