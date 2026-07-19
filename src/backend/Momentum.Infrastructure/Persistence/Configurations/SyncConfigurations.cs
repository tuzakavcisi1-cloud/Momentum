using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Momentum.Infrastructure.Persistence.Configurations;

// snake_case mapping (GOREV slice-2b1 D2): explicit ToTable/HasColumnName (no naming package).
// COLLATE "C" on every hlc/effective_op_hlc column so byte order matches the HLC order.

public sealed class OutboxMessageConfiguration : IEntityTypeConfiguration<OutboxMessage>
{
    public void Configure(EntityTypeBuilder<OutboxMessage> builder)
    {
        builder.ToTable("outbox_messages");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.AggregateType).HasColumnName("aggregate_type");
        builder.Property(x => x.AggregateId).HasColumnName("aggregate_id");
        builder.Property(x => x.OperationId).HasColumnName("operation_id");
        builder.Property(x => x.OwnerId).HasColumnName("owner_id");
        builder.Property(x => x.ScopeId).HasColumnName("scope_id");
        builder.Property(x => x.OldScopeId).HasColumnName("old_scope_id");
        builder.Property(x => x.ActorId).HasColumnName("actor_id");
        builder.Property(x => x.EventType).HasColumnName("event_type");
        builder.Property(x => x.Payload).HasColumnName("payload").HasColumnType("jsonb");
        builder.Property(x => x.Hlc).HasColumnName("hlc").UseCollation("C");
        builder.Property(x => x.OccurredAt).HasColumnName("occurred_at");
        builder.Property(x => x.SignaledAt).HasColumnName("signaled_at");
        builder.Property(x => x.Attempts).HasColumnName("attempts").HasDefaultValue(0);
        // slice-2b2 D6-1: NO default (SQL now() is banned -- one clock source, TimeProvider). OutboxWriter
        // always writes this column explicitly; a bare INSERT that omits it now fails NOT NULL (correct).
        builder.Property(x => x.AvailableAt).HasColumnName("available_at");
        builder.HasIndex(x => x.OwnerId).HasDatabaseName("ix_outbox_messages_owner_id");
    }
}

public sealed class ProcessedOperationConfiguration : IEntityTypeConfiguration<ProcessedOperation>
{
    public void Configure(EntityTypeBuilder<ProcessedOperation> builder)
    {
        builder.ToTable("processed_operations");
        builder.HasKey(x => new { x.ClientId, x.OperationId });
        builder.Property(x => x.ClientId).HasColumnName("client_id");
        builder.Property(x => x.OperationId).HasColumnName("operation_id");
        builder.Property(x => x.FirstSeenAt).HasColumnName("first_seen_at");
        builder.Property(x => x.ResultCode).HasColumnName("result_code");
        builder.Property(x => x.EffectiveOpHlc).HasColumnName("effective_op_hlc").UseCollation("C");
    }
}

public sealed class SyncClientClockConfiguration : IEntityTypeConfiguration<SyncClientClockRow>
{
    public void Configure(EntityTypeBuilder<SyncClientClockRow> builder)
    {
        builder.ToTable("sync_client_clock");
        builder.HasKey(x => x.ClientId);
        builder.Property(x => x.ClientId).HasColumnName("client_id");
        builder.Property(x => x.Hlc).HasColumnName("hlc").UseCollation("C");
    }
}

public sealed class SyncScalarMetaConfiguration : IEntityTypeConfiguration<SyncScalarMeta>
{
    public void Configure(EntityTypeBuilder<SyncScalarMeta> builder)
    {
        builder.ToTable("sync_scalar_meta");
        builder.HasKey(x => new { x.EntityType, x.EntityId, x.Field });
        builder.Property(x => x.EntityType).HasColumnName("entity_type");
        builder.Property(x => x.EntityId).HasColumnName("entity_id");
        builder.Property(x => x.Field).HasColumnName("field");
        builder.Property(x => x.Value).HasColumnName("value");
        builder.Property(x => x.Hlc).HasColumnName("hlc").UseCollation("C");
        builder.Property(x => x.WinOperationId).HasColumnName("win_operation_id");
    }
}

public sealed class SyncOrsetTagConfiguration : IEntityTypeConfiguration<SyncOrsetTag>
{
    public void Configure(EntityTypeBuilder<SyncOrsetTag> builder)
    {
        builder.ToTable("sync_orset_tags");
        builder.HasKey(x => new { x.EntityType, x.EntityId, x.SetName, x.Element, x.AddTag });
        builder.Property(x => x.EntityType).HasColumnName("entity_type");
        builder.Property(x => x.EntityId).HasColumnName("entity_id");
        builder.Property(x => x.SetName).HasColumnName("set_name");
        builder.Property(x => x.Element).HasColumnName("element");
        builder.Property(x => x.AddTag).HasColumnName("add_tag");
        builder.Property(x => x.Hlc).HasColumnName("hlc").UseCollation("C");
        builder.Property(x => x.Cancelled).HasColumnName("cancelled").HasDefaultValue(false);
    }
}

public sealed class SyncOrsetRemoveConfiguration : IEntityTypeConfiguration<SyncOrsetRemove>
{
    public void Configure(EntityTypeBuilder<SyncOrsetRemove> builder)
    {
        builder.ToTable("sync_orset_removes");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.EntityType).HasColumnName("entity_type");
        builder.Property(x => x.EntityId).HasColumnName("entity_id");
        builder.Property(x => x.SetName).HasColumnName("set_name");
        builder.Property(x => x.Element).HasColumnName("element");
        builder.Property(x => x.Hlc).HasColumnName("hlc").UseCollation("C");
    }
}

public sealed class SyncGcStateConfiguration : IEntityTypeConfiguration<SyncGcState>
{
    public void Configure(EntityTypeBuilder<SyncGcState> builder)
    {
        builder.ToTable("sync_gc_state");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.GcHorizonSeq).HasColumnName("gc_horizon_seq").HasDefaultValue(0L);
    }
}
