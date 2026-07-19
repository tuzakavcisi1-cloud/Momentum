using Asp.Versioning;
using Asp.Versioning.Builder;
using Mediator;
using Momentum.Application.Abstractions;
using Momentum.Application.Features.Tasks;

namespace Momentum.Api.Endpoints;

/// <summary>
/// <c>GET /v1/tasks</c> + <c>GET /v1/tasks/{id}</c> (ADR 0002 K2-I2/I3, GOREV slice-3a D4). Deny-by-default
/// (no <see cref="ICurrentUser.UserId"/> -&gt; 401); every query is owner-scoped by the Application/
/// Infrastructure layers beneath this endpoint (arch Rule 2: no Infrastructure type reachable from here).
/// </summary>
public static class TaskEndpoints
{
    private const int DefaultLimit = 50;
    private const int MinLimit = 1;
    private const int MaxLimit = 200;

    public static void Map(IEndpointRouteBuilder app, ApiVersionSet versionSet)
    {
        var v1 = app.MapGroup("/v{version:apiVersion}").WithApiVersionSet(versionSet);

        v1.MapGet("/tasks", HandleListAsync)
            .MapToApiVersion(new ApiVersion(1, 0))
            .WithName("GetTasks");

        v1.MapGet("/tasks/{id:guid}", HandleGetByIdAsync)
            .MapToApiVersion(new ApiVersion(1, 0))
            .WithName("GetTaskById");
    }

    private static async Task<IResult> HandleListAsync(
        ICurrentUser currentUser,
        IMediator mediator,
        CancellationToken cancellationToken,
        Guid? projectId = null,
        bool includeDeleted = false,
        int limit = DefaultLimit,
        string? cursor = null)
    {
        if (currentUser.UserId is not { } actorId)
        {
            return Results.Unauthorized(); // deny-by-default (K2-E3 push-authz deferred)
        }

        if (limit is < MinLimit or > MaxLimit)
        {
            return Results.Problem(detail: $"limit must be between {MinLimit} and {MaxLimit}.", statusCode: StatusCodes.Status400BadRequest);
        }

        if (!TaskCursorCodec.TryDecode(cursor, out var decodedCursor))
        {
            // Malformed/unrecognized-version cursor -> 400 ProblemDetails, NEVER 500 (D4 pin).
            return Results.Problem(detail: "cursor is malformed or has an unrecognized version.", statusCode: StatusCodes.Status400BadRequest);
        }

        var result = await mediator.Send(new GetTasksQuery(actorId, projectId, includeDeleted, limit, decodedCursor), cancellationToken);
        return Results.Ok(new { items = result.Items, nextCursor = result.NextCursor });
    }

    private static async Task<IResult> HandleGetByIdAsync(Guid id, ICurrentUser currentUser, IMediator mediator, CancellationToken cancellationToken)
    {
        if (currentUser.UserId is not { } actorId)
        {
            return Results.Unauthorized();
        }

        var task = await mediator.Send(new GetTaskByIdQuery(actorId, id), cancellationToken);
        // Not owned and not-found are INDISTINGUISHABLE by design -- both 404 (no ownership oracle via status code).
        return task is null ? Results.NotFound() : Results.Ok(task);
    }
}
