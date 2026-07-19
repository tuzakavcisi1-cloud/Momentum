using Momentum.Application.Abstractions;

namespace Momentum.Persistence.Tests;

/// <summary>
/// Fixed-identity <see cref="ICurrentUser"/> (GOREV slice-2b1 EndpointTests, slice-2b2 D10-b). Linked
/// into <c>Momentum.Api.Tests</c> via <c>Compile Include</c> (the two test projects do not reference each
/// other) -- capture the userId OUTSIDE the DI factory lambda when registering this, e.g.
/// <c>var userId = Guid.NewGuid(); services.AddScoped&lt;ICurrentUser&gt;(_ => new FakeCurrentUser(userId));</c>
/// A lambda that calls <c>Guid.NewGuid()</c> INSIDE itself mints a NEW id on every scope resolution (D10-b
/// YB-8/YB-9's bug) -- G3/D8-v need the SAME user across the hub connection scope and the /v1/sync scope.
/// </summary>
public sealed class FakeCurrentUser(Guid userId) : ICurrentUser
{
    public Guid? UserId => userId;
}
