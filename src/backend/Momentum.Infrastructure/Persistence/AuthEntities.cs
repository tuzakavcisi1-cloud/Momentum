namespace Momentum.Infrastructure.Persistence;

// EF-mapped rows for IS-EMRI-o83 D1 (users/refresh_tokens). Unlike the Sync/* tables (CRDT merge,
// raw SQL), these are simple CRUD tables -- reads/writes go through plain EF Core in
// Infrastructure/Auth/*Store.cs, no raw-SQL layer needed (no concurrent-merge logic here).

public sealed class UserRow
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string EmailNormalized { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public DateTimeOffset CreatedAt { get; set; }
}

public sealed class RefreshTokenRow
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string TokenHash { get; set; } = string.Empty;
    public DateTimeOffset ExpiresAt { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? RevokedAt { get; set; }
}
