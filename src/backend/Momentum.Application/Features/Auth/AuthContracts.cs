namespace Momentum.Application.Features.Auth;

// Wire contracts for POST /v1/auth/{register,login,refresh,logout} (IS-EMRI-o83 D1). JSON is camelCase,
// mirroring Sync's WireHlc/WireOp convention (Features/Sync/SyncContracts.cs).

public sealed record RegisterRequest(string Email, string Password);

public sealed record LoginRequest(string Email, string Password);

public sealed record RefreshRequest(string RefreshToken);

public sealed record LogoutRequest(string RefreshToken);

/// <summary>
/// Access-JWT + refresh-token pair. <see cref="RefreshToken"/> is the RAW value (returned exactly
/// once) -- only its SHA-256 hash is ever persisted (<c>Momentum.Application.Abstractions.Auth.RefreshTokenRecord</c>).
/// </summary>
public sealed record AuthTokenResponse(Guid UserId, string AccessToken, DateTimeOffset AccessTokenExpiresAt, string RefreshToken);

public enum AuthResultCode
{
    Ok,
    EmailTaken,
    InvalidCredentials,
    InvalidOrExpiredRefreshToken,
}

/// <summary><see cref="Tokens"/> is non-null iff <see cref="Code"/> is <see cref="AuthResultCode.Ok"/>.</summary>
public sealed record AuthCommandResult(AuthResultCode Code, AuthTokenResponse? Tokens);
