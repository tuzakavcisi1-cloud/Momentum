namespace Momentum.Application.Abstractions.Auth;

/// <summary>Issues short-lived access JWTs (IS-EMRI-o83 D1/§2.1/4). Implemented in <c>Momentum.Api/Auth</c>.</summary>
public interface IAccessTokenIssuer
{
    (string Token, DateTimeOffset ExpiresAt) Issue(Guid userId);
}
