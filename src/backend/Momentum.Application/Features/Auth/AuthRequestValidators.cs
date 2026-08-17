using FluentValidation;

namespace Momentum.Application.Features.Auth;

// STRUCTURAL validation only (SyncRequestValidator emsali, ADR 0001 K-G2). Semantic checks (email
// already taken, wrong password, expired/revoked refresh token) stay in the handlers -- they are
// per-request DB-dependent outcomes, not shape errors.

public sealed class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(r => r.Email).NotEmpty().EmailAddress();
        RuleFor(r => r.Password).NotEmpty().MinimumLength(8);
    }
}

public sealed class LoginRequestValidator : AbstractValidator<LoginRequest>
{
    public LoginRequestValidator()
    {
        RuleFor(r => r.Email).NotEmpty();
        RuleFor(r => r.Password).NotEmpty();
    }
}

public sealed class RefreshRequestValidator : AbstractValidator<RefreshRequest>
{
    public RefreshRequestValidator()
    {
        RuleFor(r => r.RefreshToken).NotEmpty();
    }
}

public sealed class LogoutRequestValidator : AbstractValidator<LogoutRequest>
{
    public LogoutRequestValidator()
    {
        RuleFor(r => r.RefreshToken).NotEmpty();
    }
}
