using Mediator;
using Momentum.Application.Abstractions.Auth;

namespace Momentum.Application.Features.Auth;

public sealed record LoginCommand(string Email, string Password) : ICommand<AuthCommandResult>;

public sealed class LoginCommandHandler(
    IUserStore userStore,
    IRefreshTokenStore refreshTokenStore,
    IPasswordHasher passwordHasher,
    IAccessTokenIssuer accessTokenIssuer,
    TimeProvider timeProvider) : ICommandHandler<LoginCommand, AuthCommandResult>
{
    public async ValueTask<AuthCommandResult> Handle(LoginCommand command, CancellationToken cancellationToken)
    {
        var user = await userStore.FindByNormalizedEmailAsync(EmailNormalizer.Normalize(command.Email), cancellationToken);

        // Generic result whether the email is unknown OR the password is wrong -- never leak which
        // (standard practice; same "do not confirm existence" posture as LogoutCommandHandler).
        if (user is null || !passwordHasher.Verify(user.PasswordHash, command.Password))
        {
            return new AuthCommandResult(AuthResultCode.InvalidCredentials, null);
        }

        return await AuthTokens.IssueAsync(user.Id, refreshTokenStore, accessTokenIssuer, timeProvider, cancellationToken);
    }
}
