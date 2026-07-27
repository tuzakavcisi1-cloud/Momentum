using Momentum.Application.Abstractions;

namespace Momentum.Api.Auth;

/// <summary>
/// Development-only <see cref="ICurrentUser"/> (GOREV slice-3c D0). Reads the authenticated user's id
/// from the <c>X-Momentum-Dev-User</c> header -- a measurement scaffold for the sync surface until the
/// real identity slice lands (ADR 0003 is frozen, K41). Registered ONLY when
/// <c>IHostEnvironment.IsDevelopment()</c> is true (Program.cs); missing, empty, or non-GUID header
/// yields <c>null</c> -&gt; /v1/sync returns 401. No silent default user is ever produced.
/// </summary>
public sealed class DevCurrentUser(IHttpContextAccessor httpContextAccessor) : ICurrentUser
{
    private const string HeaderName = "X-Momentum-Dev-User";

    public Guid? UserId
    {
        get
        {
            var context = httpContextAccessor.HttpContext;
            if (context is null || !context.Request.Headers.TryGetValue(HeaderName, out var values))
            {
                return null;
            }

            return Guid.TryParse(values.ToString(), out var parsed) ? parsed : null;
        }
    }
}
