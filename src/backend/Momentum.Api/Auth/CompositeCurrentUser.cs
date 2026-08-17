using Momentum.Application.Abstractions;

namespace Momentum.Api.Auth;

/// <summary>
/// Development-only (IS-EMRI-o83 s2.1/7): JWT is PRIMARY, the <c>X-Momentum-Dev-User</c> header stays
/// as a SECONDARY shield -- both feed the same <see cref="ICurrentUser"/>. Production uses
/// <see cref="JwtCurrentUser"/> directly (no dev-header fallback outside Development, unchanged from
/// the old <c>NullCurrentUser</c> deny-by-default posture for anything that is not a valid JWT).
/// </summary>
public sealed class CompositeCurrentUser(JwtCurrentUser jwt, DevCurrentUser dev) : ICurrentUser
{
    public Guid? UserId => jwt.UserId ?? dev.UserId;
}
