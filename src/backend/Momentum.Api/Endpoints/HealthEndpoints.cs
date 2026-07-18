using Microsoft.AspNetCore.Diagnostics.HealthChecks;

namespace Momentum.Api.Endpoints;

/// <summary>
/// Health endpoints (ADR 0001 K-D2). Named static class (not an inline lambda) so the
/// architecture rule "Api.Endpoints must not depend on Infrastructure concrete types"
/// (GOREV slice-1 D9 rule 2) has a real surface to bite. Anonymous: no auth in slice-1.
/// </summary>
public static class HealthEndpoints
{
    public static void Map(IEndpointRouteBuilder app)
    {
        // Liveness: no dependencies -> only "live"-tagged checks -> 200.
        app.MapHealthChecks("/health/live", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains("live"),
        }).AllowAnonymous();

        // Readiness: only "ready"-tagged checks. DB readiness arrives with the persistence slice;
        // the 503 gate is already proven now via a fake Unhealthy check in Api.Tests (no blind gate).
        app.MapHealthChecks("/health/ready", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains("ready"),
        }).AllowAnonymous();
    }
}
