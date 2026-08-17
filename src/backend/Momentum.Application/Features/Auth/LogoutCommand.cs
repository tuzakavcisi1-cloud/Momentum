using Mediator;
using Momentum.Application.Abstractions.Auth;

namespace Momentum.Application.Features.Auth;

public sealed record LogoutCommand(string RefreshToken) : ICommand<AuthCommandResult>;

/// <summary>Revokes the refresh token (IS-EMRI-o83 s2.2/12). Idempotent -- an unknown/already-revoked token still reports <see cref="AuthResultCode.Ok"/> (no existence leak).</summary>
public sealed class LogoutCommandHandler(IRefreshTokenStore refreshTokenStore, TimeProvider timeProvider) : ICommandHandler<LogoutCommand, AuthCommandResult>
{
    public async ValueTask<AuthCommandResult> Handle(LogoutCommand command, CancellationToken cancellationToken)
    {
        var tokenHash = AuthTokens.HashRefreshToken(command.RefreshToken);
        var existing = await refreshTokenStore.FindByTokenHashAsync(tokenHash, cancellationToken);
        if (existing is not null && existing.RevokedAt is null)
        {
            await refreshTokenStore.RevokeAsync(existing.Id, timeProvider.GetUtcNow(), cancellationToken);
        }

        return new AuthCommandResult(AuthResultCode.Ok, null);
    }
}
