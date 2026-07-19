using Asp.Versioning;
using Asp.Versioning.Builder;
using FluentValidation;
using Mediator;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Momentum.Api.Auth;
using Momentum.Api.Endpoints;
using Momentum.Api.Health;
using Momentum.Api.Realtime;
using Momentum.Application.Abstractions;
using Momentum.Application.Abstractions.Sync;
using Momentum.Application.Behaviors;
using Momentum.Application.Features.Sync;
using Momentum.Infrastructure;
using Momentum.Infrastructure.Sync;
using Scalar.AspNetCore;
using Serilog;
using Serilog.Context;

var builder = WebApplication.CreateBuilder(args);

// slice-2b1 D1: the connection string comes from user-secrets/env (red line #1); no DB configured ->
// the host still boots DB-less (slice-1 contract) and the Npgsql readiness probe is not registered.
var connectionString = builder.Configuration.GetConnectionString("Momentum");
var hasDatabase = !string.IsNullOrWhiteSpace(connectionString);

// --- ADR 0001 K-G3: structured logging (Serilog) --------------------------------------------
builder.Host.UseSerilog((_, configuration) => configuration
    .MinimumLevel.Information()
    .Enrich.FromLogContext()
    .WriteTo.Console());

// --- ADR 0001 K-C5: the clock is TimeProvider ONLY (DateTime.* is banned in production) -------
builder.Services.AddSingleton(TimeProvider.System);

// --- ADR 0001 K-B1/K-B1a: CQRS mediator. Lifetime = Scoped is set in Application via
//     [assembly: MediatorOptions] (compile-time; handlers may depend on scoped persistence ports). ----
builder.Services.AddMediator();

// --- slice-2b1: persistence (SyncDbContext + raw-SQL ports) + sync request pipeline ---------------
// DB-less boot uses a placeholder connection string that is never connected to (no readiness probe).
builder.Services.AddSyncInfrastructure(hasDatabase
    ? connectionString!
    : "Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=not_configured");
builder.Services.AddScoped<ICurrentUser, NullCurrentUser>();          // deny-by-default (K-D5)
builder.Services.AddScoped<IValidator<SyncRequest>, SyncRequestValidator>();
builder.Services.AddScoped(typeof(IPipelineBehavior<,>), typeof(TransactionBehavior<,>)); // K-G1

// --- slice-2b2: realtime signal (K2-F2/G1/G3). ISignalPublisher binds to SignalR only HERE -- the
//     dispatcher (Infrastructure) and the Domain/Application layers never see a SignalR type (D9-b). ---
builder.Services.AddSignalR();
builder.Services.AddScoped<ISignalPublisher, SignalRSignalPublisher>();
builder.Services.AddSingleton<OutboxDispatcherOptions>(); // production default: BatchSize=100, Lease=30s
if (hasDatabase)
{
    // D2-e: registered ONLY when a real connection string exists, so the DB-less slice-1 host (used by
    // Api.Tests' 9 tests) never starts a dispatcher that would immediately fault its DB calls.
    builder.Services.AddHostedService<OutboxDispatcher>();
}

// --- ADR 0001 K-D3: uniform error model (ProblemDetails / RFC 9457) in ALL environments -------
builder.Services.AddProblemDetails();

// --- ADR 0001 K-D1: OpenAPI document (built-in .NET 9 JSON generator) -> /openapi/v1.json ------
builder.Services.AddOpenApi();

// --- ADR 0001 K-D4: URL-segment API versioning (/v1) -----------------------------------------
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
});

// --- ADR 0001 K-D2 + slice-2b1 D8: health checks. "self" is live+ready; the Npgsql probe is added to
//     "ready" ONLY when a DB is configured (so the DB-less slice-1 host stays ready). ----------------
var healthChecks = builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy("Process is up."), tags: ["live", "ready"]);
if (hasDatabase)
{
    healthChecks.AddCheck<NpgsqlReadyHealthCheck>("postgres", tags: ["ready"]);
}

var app = builder.Build();

// Exception -> ProblemDetails, active in every environment (no Developer Exception Page leak).
app.UseExceptionHandler();

// Correlation-id (K-G3): honor an incoming X-Correlation-Id or mint one; echo it on the
// response and push it onto the Serilog log scope for every downstream log line.
app.Use(async (context, next) =>
{
    const string headerName = "X-Correlation-Id";
    var correlationId = context.Request.Headers.TryGetValue(headerName, out var incoming)
        && !string.IsNullOrWhiteSpace(incoming)
            ? incoming.ToString()
            : Guid.NewGuid().ToString();

    context.Response.Headers[headerName] = correlationId;
    using (LogContext.PushProperty("CorrelationId", correlationId))
    {
        await next(context);
    }
});

app.UseSerilogRequestLogging();

// ADR 0001 K-D5: deny-by-default fallback policy -> auth slice. There is no authentication
// scheme yet, so enforcing a fallback authorization policy here would break the host; health
// and OpenAPI/Scalar stay anonymous until the identity slice wires auth in.

// slice-2b2 D4 (Onur kilidi #2): /hubs/sync deny-by-default. [Authorize] cannot be used (no auth scheme
// is registered -> it would 500, not 401). This is a plain path-based middleware, NOT AddEndpointFilter
// (SignalR's endpoint is not a route-handler/controller builder, so endpoint filters do not apply to
// it). Rejecting HERE -- before negotiate -- is what makes HubConnection.StartAsync actually throw
// (Hub.OnConnectedAsync's Context.Abort() runs AFTER the handshake already succeeded, D4 gerekce).
app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/hubs/sync"))
    {
        var currentUser = context.RequestServices.GetRequiredService<ICurrentUser>();
        if (currentUser.UserId is null)
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            return;
        }
    }

    await next(context);
});

// K-D1: OpenAPI JSON + Scalar UI, mapped in every environment (no auth in this slice -> no leak).
app.MapOpenApi();            // -> /openapi/v1.json
app.MapScalarApiReference(); // -> /scalar/v1

// K-D4: single version set for the business endpoints (/v1).
ApiVersionSet versionSet = app.NewApiVersionSet()
    .HasApiVersion(new ApiVersion(1, 0))
    .Build();

// Endpoints live in named static classes (arch rule 2; GOREV slice-1 D3).
HealthEndpoints.Map(app);
DiagnosticsEndpoints.Map(app, versionSet);
SyncEndpoints.Map(app, versionSet); // slice-2b1: POST /v1/sync

app.MapHub<SyncHub>("/hubs/sync"); // slice-2b2 D4: payload-less realtime signal

app.Run();

/// <summary>Exposed as partial so <c>WebApplicationFactory&lt;Program&gt;</c> can host it in tests.</summary>
public partial class Program;
