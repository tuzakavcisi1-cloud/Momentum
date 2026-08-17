using Mediator;
using Momentum.Application.Abstractions.Auth;

namespace Momentum.Application.Features.Auth;

public sealed record RegisterCommand(string Email, string Password) : ICommand<AuthCommandResult>;

/// <summary>Register = create user + immediately issue a token pair (auto-login, IS-EMRI-o83 D1 decision: avoids a second round-trip).</summary>
public sealed class RegisterCommandHandler(
    IUserStore userStore,
    IRefreshTokenStore refreshTokenStore,
    IPasswordHasher passwordHasher,
    IAccessTokenIssuer accessTokenIssuer,
    TimeProvider timeProvider) : ICommandHandler<RegisterCommand, AuthCommandResult>
{
    public async ValueTask<AuthCommandResult> Handle(RegisterCommand command, CancellationToken cancellationToken)
    {
        var normalizedEmail = EmailNormalizer.Normalize(command.Email);
        if (await userStore.FindByNormalizedEmailAsync(normalizedEmail, cancellationToken) is not null)
        {
            return new AuthCommandResult(AuthResultCode.EmailTaken, null);
        }

        var user = new UserRecord(
            Guid.CreateVersion7(),
            command.Email.Trim(),
            normalizedEmail,
            passwordHasher.Hash(command.Password),
            timeProvider.GetUtcNow());
        await userStore.CreateAsync(user, cancellationToken);

        return await AuthTokens.IssueAsync(user.Id, refreshTokenStore, accessTokenIssuer, timeProvider, cancellationToken);
    }
}
