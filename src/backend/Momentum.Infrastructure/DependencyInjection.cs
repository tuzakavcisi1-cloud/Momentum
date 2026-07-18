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

        return services;
    }
}
