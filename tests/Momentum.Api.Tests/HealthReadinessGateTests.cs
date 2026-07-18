using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Shouldly;
using Xunit;

namespace Momentum.Api.Tests;

/// <summary>
/// The "biting" readiness gate (ADR 0001 K-D2, GOREV slice-1 D4): a fake <c>ready</c>-tagged
/// Unhealthy check must drive <c>/health/ready</c> to 503 while <c>/health/live</c> stays 200.
/// This proves the gate is real now, before the DB readiness check exists (no blind gate).
/// </summary>
public sealed class HealthReadinessGateTests
{
    private static WebApplicationFactory<Program> FactoryWithFakeUnhealthyReadyCheck() =>
        new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.ConfigureServices(services =>
                services.AddHealthChecks()
                    .AddCheck(
                        "fake-not-ready",
                        () => HealthCheckResult.Unhealthy("Forced Unhealthy for the readiness gate test."),
                        tags: ["ready"])));

    [Fact]
    public async Task Ready_returns_503_when_a_ready_check_is_unhealthy()
    {
        using var factory = FactoryWithFakeUnhealthyReadyCheck();

        var response = await factory.CreateClient().GetAsync("/health/ready");

        response.StatusCode.ShouldBe(HttpStatusCode.ServiceUnavailable);
    }

    [Fact]
    public async Task Live_stays_200_even_when_a_ready_check_is_unhealthy()
    {
        using var factory = FactoryWithFakeUnhealthyReadyCheck();

        var response = await factory.CreateClient().GetAsync("/health/live");

        response.StatusCode.ShouldBe(HttpStatusCode.OK);
    }
}
