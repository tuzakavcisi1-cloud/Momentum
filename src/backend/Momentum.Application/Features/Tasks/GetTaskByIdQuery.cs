using Mediator;
using Momentum.Domain.Sync;

namespace Momentum.Application.Features.Tasks;

/// <summary>GOREV slice-3a D4: GET /v1/tasks/{id}. Null result -&gt; endpoint returns 404 (not owned or doesn't exist -- indistinguishable by design).</summary>
public sealed record GetTaskByIdQuery(Guid OwnerId, Guid EntityId) : IQuery<TaskProjection?>;
