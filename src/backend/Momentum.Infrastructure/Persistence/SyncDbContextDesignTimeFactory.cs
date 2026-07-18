using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Momentum.Infrastructure.Persistence;

/// <summary>
/// Design-time factory for <c>dotnet ef migrations add</c> only (GOREV slice-2b1 D12). The connection
/// string is a design-time placeholder that is NEVER connected to (migrations add does not hit the DB);
/// the real connection string comes from user-secrets/env at runtime (red line #1).
/// </summary>
public sealed class SyncDbContextDesignTimeFactory : IDesignTimeDbContextFactory<SyncDbContext>
{
    public SyncDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<SyncDbContext>()
            .UseNpgsql("Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=design_time_placeholder")
            .Options;

        return new SyncDbContext(options);
    }
}
