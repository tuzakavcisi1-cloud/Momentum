using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Momentum.Application.Abstractions;
using Momentum.Persistence.Tests;
using Shouldly;
using Xunit;

namespace Momentum.Api.Tests;

/// <summary>
/// slice-2b2 D8-vii: <c>/hubs/sync</c> deny-by-default (D4). The gate is a path-based negotiate-401
/// middleware, NOT <c>Hub.OnConnectedAsync</c>'s <c>Context.Abort()</c> (which runs AFTER a successful
/// handshake and is defense-in-depth only -- the ASP.NET Core 9 source proves <c>OnConnectedAsync</c>
/// runs after the handshake is already flushed, so aborting there would not fail <c>StartAsync</c>).
/// Negotiate never reaches <c>SyncHub.OnConnectedAsync</c> (that only runs once an actual hub connection
/// is established), so BOTH tests here stay DB-less like the rest of Momentum.Api.Tests.
/// </summary>
public sealed class HubRejectionTests
{
    [Fact]
    public async Task HubConnection_start_fails_when_the_caller_has_no_identity()
    {
        await using var factory = new WebApplicationFactory<Program>();
        var server = factory.Server;

        await using var connection = new HubConnectionBuilder()
            .WithUrl("http://localhost/hubs/sync", options =>
            {
                options.HttpMessageHandlerFactory = _ => server.CreateHandler();
                options.WebSocketFactory = async (context, ct) => await server.CreateWebSocketClient().ConnectAsync(context.Uri, ct);
            })
            .Build();

        await Should.ThrowAsync<Exception>(() => connection.StartAsync());
    }

    [Fact]
    public async Task Negotiate_returns_401_without_identity()
    {
        await using var factory = new WebApplicationFactory<Program>();

        var response = await factory.CreateClient().PostAsync("/hubs/sync/negotiate?negotiateVersion=1", null);

        response.StatusCode.ShouldBe(HttpStatusCode.Unauthorized);
    }

    /// <summary>Proves the middleware is SELECTIVE (a blanket 401 for everyone would also "pass" the
    /// negative test above) -- regression/documentary, not mutant-gated on its own.</summary>
    [Fact]
    public async Task Negotiate_succeeds_when_the_caller_is_authenticated()
    {
        await using var factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
            builder.ConfigureTestServices(services =>
                services.AddScoped<ICurrentUser>(_ => new FakeCurrentUser(Guid.NewGuid()))));

        var response = await factory.CreateClient().PostAsync("/hubs/sync/negotiate?negotiateVersion=1", null);

        response.StatusCode.ShouldBe(HttpStatusCode.OK);
    }
}
