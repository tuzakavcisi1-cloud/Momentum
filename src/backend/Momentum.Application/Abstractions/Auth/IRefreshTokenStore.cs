namespace Momentum.Application.Abstractions.Auth;

/// <summary>
/// Port for the <c>refresh_tokens</c> table (IS-EMRI-o83 D1). Only SHA-256 hashes are stored/looked up
/// -- the raw token value is returned to the client once (login/register/refresh) and never persisted.
/// </summary>
public interface IRefreshTokenStore
{
    Task CreateAsync(RefreshTokenRecord token, CancellationToken cancellationToken);

    Task<RefreshTokenRecord?> FindByTokenHashAsync(string tokenHash, CancellationToken cancellationToken);

    /// <summary>Marks the token revoked (idempotent -- revoking an already-revoked token is a no-op).</summary>
    Task RevokeAsync(Guid tokenId, DateTimeOffset revokedAt, CancellationToken cancellationToken);
}
