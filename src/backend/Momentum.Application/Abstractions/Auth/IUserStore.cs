namespace Momentum.Application.Abstractions.Auth;

/// <summary>Port for the <c>users</c> table (IS-EMRI-o83 D1). Asgari: id/email/password_hash/created_at.</summary>
public interface IUserStore
{
    /// <summary><paramref name="normalizedEmail"/> must already be normalized (see <see cref="EmailNormalizer"/>).</summary>
    Task<UserRecord?> FindByNormalizedEmailAsync(string normalizedEmail, CancellationToken cancellationToken);

    Task<UserRecord?> FindByIdAsync(Guid id, CancellationToken cancellationToken);

    /// <summary>Inserts a new user row. Caller has already checked email uniqueness (register handler).</summary>
    Task CreateAsync(UserRecord user, CancellationToken cancellationToken);
}

/// <summary>
/// Culture-INVARIANT email normalization (trim + lower). GOREV o78 dersi burada tekrarlanir: bir
/// culture-sensitive <c>ToLower()</c> tr-TR altinda "I" -&gt; "i" DEGIL "ı" uretir -- <c>ToLowerInvariant</c>
/// zorunludur, aksi halde ayni e-posta iki farkli normalize sonucu uretebilir.
/// </summary>
public static class EmailNormalizer
{
    public static string Normalize(string email) => email.Trim().ToLowerInvariant();
}
