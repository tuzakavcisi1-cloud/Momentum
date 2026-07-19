using Mediator;
using Momentum.Application.Abstractions.Sync;

namespace Momentum.Application.Features.Tasks;

public sealed class GetTaskListsQueryHandler(ITaskReadStore store) : IQueryHandler<GetTaskListsQuery, GetTaskListsResult>
{
    public async ValueTask<GetTaskListsResult> Handle(GetTaskListsQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);

        var fetched = await store.ListTaskListsAsync(query.OwnerId, query.IncludeDeleted, query.Limit + 1, query.Cursor, cancellationToken);

        var hasMore = fetched.Count > query.Limit;
        var items = hasMore ? fetched.Take(query.Limit).ToList() : fetched;
        var nextCursor = hasMore
            ? TaskCursorCodec.Encode(new TaskKeysetCursor(items[^1].Pos, items[^1].EntityId))
            : null;

        return new GetTaskListsResult(items, nextCursor);
    }
}
