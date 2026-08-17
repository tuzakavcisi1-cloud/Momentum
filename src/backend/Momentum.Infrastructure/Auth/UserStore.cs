using Microsoft.EntityFrameworkCore;
using Momentum.Application.Abstractions.Auth;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Infrastructure.Auth;

/// <summary>Plain EF CRUD over <c>users</c> (IS-EMRI-o83 D1) -- no CRDT merge logic, unlike the Sync/* raw-SQL ports.</summary>
public sealed class UserStore(SyncDbContext db) : IUserStore
{
    public async Task<UserRecord?> FindByNormalizedEmailAsync(string normalizedEmail, CancellationToken cancellationToken)
    {
        var row = await db.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.EmailNormalized == normalizedEmail, cancellationToken);
        return row is null ? null : ToRecord(row);
    }

    public async Task<UserRecord?> FindByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var row = await db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == id, cancellationToken);
        return row is null ? null : ToRecord(row);
    }

    public async Task CreateAsync(UserRecord user, CancellationToken cancellationToken)
    {
        db.Users.Add(new UserRow
        {
            Id = user.Id,
            Email = user.Email,
            EmailNormalized = user.EmailNormalized,
            PasswordHash = user.PasswordHash,
            CreatedAt = user.CreatedAt,
        });
        await db.SaveChangesAsync(cancellationToken);
    }

    private static UserRecord ToRecord(UserRow row) => new(row.Id, row.Email, row.EmailNormalized, row.PasswordHash, row.CreatedAt);
}
