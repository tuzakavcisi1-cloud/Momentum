using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Momentum.Application.Abstractions.Auth;

namespace Momentum.Api.Auth;

/// <summary>Signs short-lived access JWTs (HS256). The SAME key/issuer/audience validate them in Program.cs's <c>AddJwtBearer</c> wiring.</summary>
public sealed class JwtAccessTokenIssuer(IOptions<JwtOptions> options, TimeProvider timeProvider) : IAccessTokenIssuer
{
    public (string Token, DateTimeOffset ExpiresAt) Issue(Guid userId)
    {
        var opts = options.Value;
        var now = timeProvider.GetUtcNow();
        var expiresAt = now.AddMinutes(opts.AccessTokenMinutes);

        var key = new SymmetricSecurityKey(Convert.FromBase64String(opts.Secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var claims = new[] { new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()) };

        var token = new JwtSecurityToken(
            issuer: opts.Issuer,
            audience: opts.Audience,
            claims: claims,
            notBefore: now.UtcDateTime,
            expires: expiresAt.UtcDateTime,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }
}
