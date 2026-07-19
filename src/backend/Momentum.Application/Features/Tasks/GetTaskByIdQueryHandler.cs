using Mediator;
using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;

namespace Momentum.Application.Features.Tasks;

public sealed class GetTaskByIdQueryHandler(ITaskReadStore store) : IQueryHandler<GetTaskByIdQuery, TaskProjection?>
{
    public ValueTask<TaskProjection?> Handle(GetTaskByIdQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        return new ValueTask<TaskProjection?>(store.GetTaskByIdAsync(query.OwnerId, query.EntityId, cancellationToken));
    }
}
