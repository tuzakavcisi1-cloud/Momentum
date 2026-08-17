namespace Momentum.Application.Abstractions.Auth;

// GOREV IS-EMRI-o83 (DILIM 1 KIMLIK) D1: minimal DTOs for the auth ports. Domain stays pure (no
// EFCore/AspNetCore) -- these live in Application, mirroring how Task/TaskList already have no
// Domain-level entity (Infrastructure rows + Application ports only, ADR 0002 K2-I2 pattern).

/// <summary>A persisted user row, as read back through <see cref="IUserStore"/>.</summary>
public sealed record UserRecord(Guid Id, string Email, string EmailNormalized, string PasswordHash, DateTimeOffset CreatedAt);

/// <summary>
/// A persisted refresh token, as read back through <see cref="IRefreshTokenStore"/>. Only the SHA-256
/// hash of the token value is ever stored (never the raw value -- same "never store the secret" rule
/// as <see cref="UserRecord.PasswordHash"/>).
/// </summary>
public sealed record RefreshTokenRecord(Guid Id, Guid UserId, string TokenHash, DateTimeOffset ExpiresAt, DateTimeOffset CreatedAt, DateTimeOffset? RevokedAt);
