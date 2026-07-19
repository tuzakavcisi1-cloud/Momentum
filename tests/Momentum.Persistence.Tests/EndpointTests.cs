using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Momentum.Application.Abstractions;
using Momentum.Application.Features.Sync;
using Npgsql;
using Shouldly;
using Testcontainers.PostgreSql;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>WAF endpoint tests: deny-by-default 401, structural 400, and the Npgsql readiness 503 gate.</summary>
public sealed class EndpointTests
{
    [Fact]
    public async Task Sync_without_authenticated_user_returns_401()
    {
        await using var factory = new WebApplicationFactory<Program>();
        var client = factory.CreateClient();

        var response = await client.PostAsJsonAsync("/v1/sync", new SyncRequest(Guid.NewGuid(), null, null, []));

        response.StatusCode.ShouldBe(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Sync_with_more_than_100_ops_returns_400()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.ConfigureTestServices(services =>
                services.AddScoped<ICurrentUser>(_ => new FakeCurrentUser(Guid.NewGuid()))));
        var client = factory.CreateClient();

        var ops = Enumerable.Range(0, 101)
            .Select(_ => Wire.TaskField(Guid.CreateVersion7(), Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid(), "title", "x"))
            .ToArray();

        var response = await client.PostAsJsonAsync("/v1/sync", new SyncRequest(Guid.NewGuid(), null, null, ops));

        response.StatusCode.ShouldBe(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Ready_is_200_when_db_up_and_503_when_down_live_stays_200()
    {
        var container = new PostgreSqlBuilder("postgres:17-alpine").Build();
        await container.StartAsync();
        try
        {
            var connectionString = new NpgsqlConnectionStringBuilder(container.GetConnectionString()) { Timeout = 5 }.ConnectionString;
            await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
                builder.UseSetting("ConnectionStrings:Momentum", connectionString));
            var client = factory.CreateClient();

            (await client.GetAsync("/health/ready")).StatusCode.ShouldBe(HttpStatusCode.OK);
            (await client.GetAsync("/health/live")).StatusCode.ShouldBe(HttpStatusCode.OK);

            await container.StopAsync();

            (await client.GetAsync("/health/ready")).StatusCode.ShouldBe(HttpStatusCode.ServiceUnavailable);
            (await client.GetAsync("/health/live")).StatusCode.ShouldBe(HttpStatusCode.OK);
        }
        finally
        {
            await container.DisposeAsync();
        }
    }
}
