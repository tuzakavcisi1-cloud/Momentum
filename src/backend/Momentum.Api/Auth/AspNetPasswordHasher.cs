using Microsoft.AspNetCore.Identity;
using Momentum.Application.Abstractions.Auth;

namespace Momentum.Api.Auth;

/// <summary>
/// Wraps ASP.NET Core's BUILT-IN <c>PasswordHasher&lt;T&gt;</c> (IS-EMRI-o83 s2.1/3: "yeni bagimlilik
/// getirmez" -- it ships in the ASP.NET Core shared framework, which <c>Momentum.Api</c> (Sdk.Web)
/// already implicitly references; no new PackageReference). The generic parameter is unused by the
/// hasher itself (API-generality artifact upstream) -- a shared dummy instance avoids allocating one
/// per call.
/// </summary>
public sealed class AspNetPasswordHasher : IPasswordHasher
{
    private static readonly object DummyUser = new();
    private readonly PasswordHasher<object> _hasher = new();

    public string Hash(string password) => _hasher.HashPassword(DummyUser, password);

    public bool Verify(string hash, string password) =>
        _hasher.VerifyHashedPassword(DummyUser, hash, password) is
            PasswordVerificationResult.Success or PasswordVerificationResult.SuccessRehashNeeded;
}
