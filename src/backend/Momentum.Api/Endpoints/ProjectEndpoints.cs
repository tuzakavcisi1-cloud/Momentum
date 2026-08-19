using Asp.Versioning;
using Asp.Versioning.Builder;
using Mediator;
using Momentum.Application.Abstractions;
using Momentum.Application.Features.Tasks;

namespace Momentum.Api.Endpoints;

/// <summary>
/// IS-EMRI-o85-B: <c>GET /v1/projects</c> (TaskListEndpoints'in birebir deseni). 🔴 Vitrin/API paritesi
/// icindir -- istemci bu uca BAGLANMAZ (istemci yalniz /v1/auth/* ve /v1/sync cagirir).
/// </summary>
public static class ProjectEndpoints
{
    private const int DefaultLimit = 50;
    private const int MinLimit = 1;
    private const int MaxLimit = 200;

    public static void Map(IEndpointRouteBuilder app, ApiVersionSet versionSet)
    {
        var v1 = app.MapGroup("/v{version:apiVersion}").WithApiVersionSet(versionSet);

        v1.MapGet("/projects", HandleListAsync)
            .MapToApiVersion(new ApiVersion(1, 0))
            .WithName("GetProjects");
    }

    private static async Task<IResult> HandleListAsync(
        ICurrentUser currentUser,
        IMediator mediator,
        CancellationToken cancellationToken,
        bool includeDeleted = false,
        int limit = DefaultLimit,
        string? cursor = null)
    {
        if (currentUser.UserId is not { } actorId)
        {
            return Results.Unauthorized();
        }

        if (limit is < MinLimit or > MaxLimit)
        {
            return Results.Problem(detail: $"limit must be between {MinLimit} and {MaxLimit}.", statusCode: StatusCodes.Status400BadRequest);
        }

        if (!TaskCursorCodec.TryDecode(cursor, out var decodedCursor))
        {
            return Results.Problem(detail: "cursor is malformed or has an unrecognized version.", statusCode: StatusCodes.Status400BadRequest);
        }

        var result = await mediator.Send(new GetProjectsQuery(actorId, includeDeleted, limit, decodedCursor), cancellationToken);
        return Results.Ok(new { items = result.Items, nextCursor = result.NextCursor });
    }
}
