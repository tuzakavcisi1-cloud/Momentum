using Momentum.Application.Abstractions;

namespace Momentum.Api.Auth;

/// <summary>
/// Deny-by-default <see cref="ICurrentUser"/> (ADR 0001 K-D5, ADR 0002 K2-E3). No auth scheme yet, so
/// <see cref="UserId"/> is always <c>null</c> and /v1/sync returns 401. The identity slice replaces this;
/// tests inject a fake with a concrete id.
/// </summary>
public sealed class NullCurrentUser : ICurrentUser
{
    public Guid? UserId => null;
}
