using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Momentum.Infrastructure.Persistence.Configurations;

// snake_case mapping (SyncConfigurations emsali, GOREV slice-2b1 D2 deseni). IS-EMRI-o83 D1.

public sealed class UserRowConfiguration : IEntityTypeConfiguration<UserRow>
{
    public void Configure(EntityTypeBuilder<UserRow> builder)
    {
        builder.ToTable("users");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.Email).HasColumnName("email");
        builder.Property(x => x.EmailNormalized).HasColumnName("email_normalized").UseCollation("C");
        builder.Property(x => x.PasswordHash).HasColumnName("password_hash");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at");
        // "benzersiz, normalize" (is emri s2.1/1) -- uniqueness is enforced on the NORMALIZED column,
        // COLLATE "C" so it is a byte-exact (not linguistic/case-folding) comparison.
        builder.HasIndex(x => x.EmailNormalized).IsUnique().HasDatabaseName("ux_users_email_normalized");
    }
}

public sealed class RefreshTokenRowConfiguration : IEntityTypeConfiguration<RefreshTokenRow>
{
    public void Configure(EntityTypeBuilder<RefreshTokenRow> builder)
    {
        builder.ToTable("refresh_tokens");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.UserId).HasColumnName("user_id");
        builder.Property(x => x.TokenHash).HasColumnName("token_hash").UseCollation("C");
        builder.Property(x => x.ExpiresAt).HasColumnName("expires_at");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at");
        builder.Property(x => x.RevokedAt).HasColumnName("revoked_at");
        // Lookup path (refresh/logout) is always by hash -- unique so a hash collision (SHA-256,
        // astronomically unlikely) fails loudly at insert instead of silently aliasing two tokens.
        builder.HasIndex(x => x.TokenHash).IsUnique().HasDatabaseName("ux_refresh_tokens_token_hash");
        builder.HasIndex(x => x.UserId).HasDatabaseName("ix_refresh_tokens_user_id");
    }
}
