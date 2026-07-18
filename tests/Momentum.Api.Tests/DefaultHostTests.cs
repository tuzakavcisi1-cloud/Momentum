using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Shouldly;
using Xunit;

namespace Momentum.Api.Tests;

/// <summary>
/// Happy-path checks against the shipped host booting WITHOUT a database
/// (GOREV slice-1 acceptance 2 & 3): health, ping, OpenAPI JSON and Scalar UI.
/// </summary>
public sealed class DefaultHostTests(WebApplicationFactory<Program> factory)
    : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory = factory;

    [Fact]
    public async Task Health_live_returns_200()
    {
        var response = await _factory.CreateClient().GetAsync("/health/live");
        response.StatusCode.ShouldBe(HttpStatusCode.OK);
    }

    [Fact]
    public async Task Health_ready_returns_200_when_all_checks_healthy()
    {
        var response = await _factory.CreateClient().GetAsync("/health/ready");
        response.StatusCode.ShouldBe(HttpStatusCode.OK);
    }

    [Fact]
    public async Task Ping_returns_200_and_status_ok()
    {
        var response = await _factory.CreateClient().GetAsync("/v1/ping");

        response.StatusCode.ShouldBe(HttpStatusCode.OK);

        var payload = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(payload);
        document.RootElement.GetProperty("status").GetString().ShouldBe("ok");
        document.RootElement.TryGetProperty("serverTimeUtc", out _).ShouldBeTrue();
    }

    [Fact]
    public async Task Ping_echoes_a_correlation_id_header()
    {
        var response = await _factory.CreateClient().GetAsync("/v1/ping");
        response.Headers.Contains("X-Correlation-Id").ShouldBeTrue();
    }

    [Fact]
    public async Task OpenApi_document_returns_200()
    {
        var response = await _factory.CreateClient().GetAsync("/openapi/v1.json");

        response.StatusCode.ShouldBe(HttpStatusCode.OK);
        response.Content.Headers.ContentType?.MediaType.ShouldBe("application/json");
    }

    [Fact]
    public async Task Scalar_reference_ui_returns_200()
    {
        var response = await _factory.CreateClient().GetAsync("/scalar/v1");
        response.StatusCode.ShouldBe(HttpStatusCode.OK);
    }
}
