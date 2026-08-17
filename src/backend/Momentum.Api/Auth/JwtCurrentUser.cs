using System.Security.Claims;
using Momentum.Application.Abstractions;

namespace Momentum.Api.Auth;

/// <summary>
/// Reads the authenticated user from the validated JWT (IS-EMRI-o83 s2.1/5/7: "ICurrentUser JWT'den
/// okur", PRIMARY in every environment). <c>HttpContext.User</c> is populated by <c>UseAuthentication</c>
/// (Program.cs) BEFORE this runs -- an invalid/missing/expired bearer token leaves it unauthenticated,
/// this returns <c>null</c> (deny-by-default, same posture as the old <c>NullCurrentUser</c>).
/// </summary>
public sealed class JwtCurrentUser(IHttpContextAccessor httpContextAccessor) : ICurrentUser
{
    public Guid? UserId
    {
        get
        {
            var user = httpContextAccessor.HttpContext?.User;
            if (user?.Identity?.IsAuthenticated != true)
            {
                return null;
            }

            var sub = user.FindFirstValue(ClaimTypes.NameIdentifier) ?? user.FindFirstValue("sub");
            return Guid.TryParse(sub, out var parsed) ? parsed : null;
        }
    }
}
