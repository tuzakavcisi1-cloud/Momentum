namespace Momentum.Application.Abstractions.Auth;

/// <summary>
/// Port over ASP.NET Core's BUILT-IN <c>PasswordHasher&lt;T&gt;</c> (IS-EMRI-o83 §2.1/3: no new
/// dependency -- BCrypt/Argon2 paketleri EKLENMEZ). The concrete implementation lives in
/// <c>Momentum.Api</c> (the only project with the ASP.NET Core shared-framework reference), mirroring
/// how <c>ICurrentUser</c>'s implementations live in <c>Momentum.Api/Auth</c>.
/// </summary>
public interface IPasswordHasher
{
    string Hash(string password);

    bool Verify(string hash, string password);
}
