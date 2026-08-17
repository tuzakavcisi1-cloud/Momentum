using System.Security.Cryptography;
using System.Text;
using Momentum.Application.Abstractions.Auth;

namespace Momentum.Application.Features.Auth;

/// <summary>
/// Shared refresh-token issuance/hashing for Register/Login/Refresh (IS-EMRI-o83 D1). BCL crypto only
/// (<c>System.Security.Cryptography</c>) -- no new dependency, same rationale as the built-in
/// <see cref="IPasswordHasher"/> port.
/// </summary>
internal static class AuthTokens
{
    // ODEV kilidi (IS-EMRI-o83 s2.1/4): "cevrimdisi istemcide erisim token'i suresi dolduğunda
    // kuyruktaki yazimlarin kaybolmamasi mimari zorunluluktur" -- refresh omru cevrimdisi bir
    // calisma seansini rahatca kapsayacak kadar uzun (30 gun) tutulur.
    public static readonly TimeSpan RefreshTokenLifetime = TimeSpan.FromDays(30);

    public static string HashRefreshToken(string rawToken) =>
        Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(rawToken)));

    private static (string RawToken, string TokenHash) GenerateRefreshToken()
    {
        var raw = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32));
        return (raw, HashRefreshToken(raw));
    }

    /// <summary>Mints a NEW access+refresh pair and persists the refresh token's hash.</summary>
    public static async ValueTask<AuthCommandResult> IssueAsync(
        Guid userId,
        IRefreshTokenStore refreshTokenStore,
        IAccessTokenIssuer accessTokenIssuer,
        TimeProvider timeProvider,
        CancellationToken cancellationToken)
    {
        var now = timeProvider.GetUtcNow();
        var (rawToken, tokenHash) = GenerateRefreshToken();
        var record = new RefreshTokenRecord(Guid.CreateVersion7(), userId, tokenHash, now + RefreshTokenLifetime, now, null);
        await refreshTokenStore.CreateAsync(record, cancellationToken);

        var (accessToken, accessExpiresAt) = accessTokenIssuer.Issue(userId);
        return new AuthCommandResult(AuthResultCode.Ok, new AuthTokenResponse(userId, accessToken, accessExpiresAt, rawToken));
    }
}
