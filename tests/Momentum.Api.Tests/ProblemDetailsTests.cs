using System.Net;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.DependencyInjection;
using Shouldly;
using Xunit;

namespace Momentum.Api.Tests;

/// <summary>
/// Uniform error model (ADR 0001 K-D3, GOREV slice-1 D5). The host is pinned to a
/// non-Development environment (Developer Exception Page OFF) and a test-only throwing endpoint
/// is injected; the response must be <c>500</c> with <c>application/problem+json</c> (RFC 9457).
/// </summary>
public sealed class ProblemDetailsTests
{
    private static WebApplicationFactory<Program> ProductionFactoryWithThrowingEndpoint() =>
        new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.UseEnvironment("Production");
            builder.ConfigureServices(services =>
                services.AddSingleton<IStartupFilter, ThrowingEndpointStartupFilter>());
        });

    [Fact]
    public async Task Unhandled_exception_maps_to_500_problem_json()
    {
        using var factory = ProductionFactoryWithThrowingEndpoint();
        var client = factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false,
        });

        var response = await client.GetAsync(ThrowingEndpointStartupFilter.Path);

        response.StatusCode.ShouldBe(HttpStatusCode.InternalServerError);
        response.Content.Headers.ContentType?.MediaType.ShouldBe("application/problem+json");
    }
}
