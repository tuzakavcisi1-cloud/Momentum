using Asp.Versioning;
using Asp.Versioning.Builder;
using FluentValidation;
using Mediator;
using Momentum.Application.Abstractions;
using Momentum.Application.Features.Sync;

namespace Momentum.Api.Endpoints;

/// <summary>
/// <c>POST /v1/sync</c> (ADR 0002 K2-E1, GOREV slice-2b1 D3). Named static class (arch rule 2). The
/// endpoint is deny-by-default: no <see cref="ICurrentUser.UserId"/> -> 401; structural validation ->
/// 400; otherwise the <c>SyncCommand</c> runs (push per-op txn + pull/snapshot).
/// </summary>
public static class SyncEndpoints
{
    public static void Map(IEndpointRouteBuilder app, ApiVersionSet versionSet)
    {
        var v1 = app.MapGroup("/v{version:apiVersion}").WithApiVersionSet(versionSet);

        v1.MapPost("/sync", HandleAsync)
            .MapToApiVersion(new ApiVersion(1, 0))
            .WithName("Sync");
    }

    private static async Task<IResult> HandleAsync(
        SyncRequest request,
        ICurrentUser currentUser,
        IValidator<SyncRequest> validator,
        IMediator mediator,
        CancellationToken cancellationToken)
    {
        if (currentUser.UserId is not { } actorId)
        {
            return Results.Unauthorized(); // deny-by-default (K2-E3 push-authz deferred)
        }

        var validation = await validator.ValidateAsync(request, cancellationToken);
        if (!validation.IsValid)
        {
            return Results.ValidationProblem(validation.ToDictionary());
        }

        var response = await mediator.Send(new SyncCommand(actorId, request), cancellationToken);
        return Results.Ok(response);
    }
}
