using Microsoft.EntityFrameworkCore;
using Momentum.Application.Abstractions.Auth;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Infrastructure.Auth;

/// <summary>Plain EF CRUD over <c>refresh_tokens</c> (IS-EMRI-o83 D1).</summary>
public sealed class RefreshTokenStore(SyncDbContext db) : IRefreshTokenStore
{
    public async Task CreateAsync(RefreshTokenRecord token, CancellationToken cancellationToken)
    {
        db.RefreshTokens.Add(new RefreshTokenRow
        {
            Id = token.Id,
            UserId = token.UserId,
            TokenHash = token.TokenHash,
            ExpiresAt = token.ExpiresAt,
            CreatedAt = token.CreatedAt,
            RevokedAt = token.RevokedAt,
        });
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task<RefreshTokenRecord?> FindByTokenHashAsync(string tokenHash, CancellationToken cancellationToken)
    {
        var row = await db.RefreshTokens.AsNoTracking().FirstOrDefaultAsync(t => t.TokenHash == tokenHash, cancellationToken);
        return row is null ? null : new RefreshTokenRecord(row.Id, row.UserId, row.TokenHash, row.ExpiresAt, row.CreatedAt, row.RevokedAt);
    }

    public async Task RevokeAsync(Guid tokenId, DateTimeOffset revokedAt, CancellationToken cancellationToken)
    {
        // Idempotent (IRefreshTokenStore contract): revoking an already-revoked row is a silent no-op,
        // it never overwrites the FIRST revocation timestamp.
        var row = await db.RefreshTokens.FirstOrDefaultAsync(t => t.Id == tokenId, cancellationToken);
        if (row is null || row.RevokedAt is not null)
        {
            return;
        }

        row.RevokedAt = revokedAt;
        await db.SaveChangesAsync(cancellationToken);
    }
}
