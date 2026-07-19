using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Momentum.Application.Abstractions.Sync;
using Momentum.Infrastructure.Persistence;
using Momentum.Infrastructure.Sync;

namespace Momentum.Infrastructure;

/// <summary>Wires the slice-2b1 persistence: <see cref="SyncDbContext"/> + the raw-SQL sync ports.</summary>
public static class DependencyInjection
{
    public static IServiceCollection AddSyncInfrastructure(this IServiceCollection services, string connectionString)
    {
        services.AddDbContext<SyncDbContext>(options => options.UseNpgsql(connectionString));

        services.AddScoped<ISyncTransaction, SyncTransaction>();
        services.AddScoped<ISyncStore, SyncStore>();
        services.AddScoped<IOutboxWriter, OutboxWriter>();
        services.AddScoped<IProcessedOperations, ProcessedOperations>();
        services.AddScoped<IClientClock, ClientClock>();
        services.AddScoped<ISyncPuller, SyncPuller>();

        // slice-2b2: dispatcher (D2) + scope-membership (D5) ports. OutboxClaimStore opens its OWN
        // NpgsqlConnection (never the shared SyncDbContext one, D2-g) but is still DI-scoped so
        // OutboxDispatcher must resolve it through a fresh scope per pump (D2-e), same as every other
        // sync port here.
        services.AddScoped(_ => new OutboxClaimStore(connectionString));
        services.AddScoped<IScopeMembershipSource, ScopeMembershipSource>();

        return services;
    }
}
