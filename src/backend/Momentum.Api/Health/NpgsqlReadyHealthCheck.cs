using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Api.Health;

/// <summary>
/// Readiness DB probe (ADR 0001 K-D2, GOREV slice-2b1 D8; own check, no AspNetCore.HealthChecks.*).
/// DB reachable -> Healthy; container down -> Unhealthy -> <c>/health/ready</c> 503 (<c>/health/live</c>
/// stays 200). Only registered when a real connection string is configured.
/// </summary>
public sealed class NpgsqlReadyHealthCheck(SyncDbContext db) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        return await db.Database.CanConnectAsync(cancellationToken)
            ? HealthCheckResult.Healthy("PostgreSQL reachable.")
            : HealthCheckResult.Unhealthy("PostgreSQL unreachable.");
    }
}
