using Asp.Versioning;
using Asp.Versioning.Builder;
using Mediator;
using Momentum.Application.Features.Diagnostics.Ping;

namespace Momentum.Api.Endpoints;

/// <summary>
/// Business diagnostics endpoints under <c>/v1</c> (ADR 0001 K-D4). Named static class with
/// named handler methods (no inline lambdas) per GOREV slice-1 D3.
/// </summary>
public static class DiagnosticsEndpoints
{
    public static void Map(IEndpointRouteBuilder app, ApiVersionSet versionSet)
    {
        var v1 = app.MapGroup("/v{version:apiVersion}")
            .WithApiVersionSet(versionSet);

        v1.MapGet("/ping", HandlePingAsync)
            .MapToApiVersion(new ApiVersion(1, 0))
            .WithName("Ping")
            .AllowAnonymous();
    }

    // Routed through the mediator to prove cross-assembly handler discovery (GOREV slice-1 D2).
    private static async Task<IResult> HandlePingAsync(IMediator mediator, CancellationToken cancellationToken)
    {
        var response = await mediator.Send(new PingQuery(), cancellationToken);
        return Results.Ok(response);
    }
}
