using Mediator;
using Momentum.Application.Abstractions.Auth;

namespace Momentum.Application.Features.Auth;

public sealed record RefreshCommand(string RefreshToken) : ICommand<AuthCommandResult>;

/// <summary>
/// ODEV kilidi (IS-EMRI-o83 s2.1/4): refresh token "dondurulebilir/iptal edilebilir" olmak zorunda --
/// bu yuzden her yenileme ESKI token'i iptal edip YENI bir cift basar (rotation). Eski token'i tekrar
/// sunmak (calinti/replay) `InvalidOrExpiredRefreshToken` doner.
/// </summary>
public sealed class RefreshCommandHandler(
    IRefreshTokenStore refreshTokenStore,
    IAccessTokenIssuer accessTokenIssuer,
    TimeProvider timeProvider) : ICommandHandler<RefreshCommand, AuthCommandResult>
{
    public async ValueTask<AuthCommandResult> Handle(RefreshCommand command, CancellationToken cancellationToken)
    {
        var tokenHash = AuthTokens.HashRefreshToken(command.RefreshToken);
        var existing = await refreshTokenStore.FindByTokenHashAsync(tokenHash, cancellationToken);
        var now = timeProvider.GetUtcNow();

        if (existing is null || existing.RevokedAt is not null || existing.ExpiresAt <= now)
        {
            return new AuthCommandResult(AuthResultCode.InvalidOrExpiredRefreshToken, null);
        }

        await refreshTokenStore.RevokeAsync(existing.Id, now, cancellationToken);
        return await AuthTokens.IssueAsync(existing.UserId, refreshTokenStore, accessTokenIssuer, timeProvider, cancellationToken);
    }
}
