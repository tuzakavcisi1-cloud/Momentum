using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Momentum.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialSync : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "outbox_messages",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    aggregate_type = table.Column<string>(type: "text", nullable: false),
                    aggregate_id = table.Column<Guid>(type: "uuid", nullable: false),
                    operation_id = table.Column<Guid>(type: "uuid", nullable: false),
                    owner_id = table.Column<Guid>(type: "uuid", nullable: false),
                    scope_id = table.Column<Guid>(type: "uuid", nullable: true),
                    old_scope_id = table.Column<Guid>(type: "uuid", nullable: true),
                    actor_id = table.Column<Guid>(type: "uuid", nullable: false),
                    event_type = table.Column<string>(type: "text", nullable: false),
                    payload = table.Column<string>(type: "jsonb", nullable: false),
                    hlc = table.Column<string>(type: "text", nullable: false, collation: "C"),
                    occurred_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    signaled_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    attempts = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    available_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false, defaultValueSql: "now()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_outbox_messages", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "processed_operations",
                columns: table => new
                {
                    client_id = table.Column<Guid>(type: "uuid", nullable: false),
                    operation_id = table.Column<Guid>(type: "uuid", nullable: false),
                    first_seen_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    result_code = table.Column<string>(type: "text", nullable: false),
                    effective_op_hlc = table.Column<string>(type: "text", nullable: true, collation: "C")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_processed_operations", x => new { x.client_id, x.operation_id });
                });

            migrationBuilder.CreateTable(
                name: "sync_client_clock",
                columns: table => new
                {
                    client_id = table.Column<Guid>(type: "uuid", nullable: false),
                    hlc = table.Column<string>(type: "text", nullable: false, collation: "C")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sync_client_clock", x => x.client_id);
                });

            migrationBuilder.CreateTable(
                name: "sync_gc_state",
                columns: table => new
                {
                    id = table.Column<int>(type: "integer", nullable: false),
                    gc_horizon_seq = table.Column<long>(type: "bigint", nullable: false, defaultValue: 0L)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sync_gc_state", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sync_orset_removes",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    entity_type = table.Column<string>(type: "text", nullable: false),
                    entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    set_name = table.Column<string>(type: "text", nullable: false),
                    element = table.Column<string>(type: "text", nullable: false),
                    hlc = table.Column<string>(type: "text", nullable: false, collation: "C")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sync_orset_removes", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "sync_orset_tags",
                columns: table => new
                {
                    entity_type = table.Column<string>(type: "text", nullable: false),
                    entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    set_name = table.Column<string>(type: "text", nullable: false),
                    element = table.Column<string>(type: "text", nullable: false),
                    add_tag = table.Column<Guid>(type: "uuid", nullable: false),
                    hlc = table.Column<string>(type: "text", nullable: true, collation: "C"),
                    cancelled = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sync_orset_tags", x => new { x.entity_type, x.entity_id, x.set_name, x.element, x.add_tag });
                });

            migrationBuilder.CreateTable(
                name: "sync_scalar_meta",
                columns: table => new
                {
                    entity_type = table.Column<string>(type: "text", nullable: false),
                    entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    field = table.Column<string>(type: "text", nullable: false),
                    value = table.Column<string>(type: "text", nullable: true),
                    hlc = table.Column<string>(type: "text", nullable: false, collation: "C"),
                    win_operation_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sync_scalar_meta", x => new { x.entity_type, x.entity_id, x.field });
                });

            migrationBuilder.CreateIndex(
                name: "ix_outbox_messages_owner_id",
                table: "outbox_messages",
                column: "owner_id");

            // GOREV slice-2b1 D2 (pin): commit_xid / server_seq are DB-generated (never EF-written) and
            // added here via raw SQL. GENERATED ALWAYS rejects accidental writes at the DB level too;
            // server_seq STARTS WITH 1 so the (horizon,0) resync sentinel can never collide with a row.
            migrationBuilder.Sql(
                "ALTER TABLE outbox_messages " +
                "ADD COLUMN commit_xid xid8 NOT NULL DEFAULT pg_current_xact_id(), " +
                "ADD COLUMN server_seq bigint GENERATED ALWAYS AS IDENTITY (START WITH 1) NOT NULL;");
            migrationBuilder.Sql(
                "ALTER TABLE outbox_messages ADD CONSTRAINT ux_outbox_messages_commit UNIQUE (commit_xid, server_seq);");
            migrationBuilder.Sql(
                "CREATE INDEX ix_outbox_messages_owner_cursor ON outbox_messages (owner_id, commit_xid, server_seq);");

            // sync_gc_state: single-row config table. gc_horizon_xid (xid8, unmapped) + CHECK(id=1).
            migrationBuilder.Sql("ALTER TABLE sync_gc_state ADD COLUMN gc_horizon_xid xid8 NULL;");
            migrationBuilder.Sql("ALTER TABLE sync_gc_state ADD CONSTRAINT ck_sync_gc_state_singleton CHECK (id = 1);");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "outbox_messages");

            migrationBuilder.DropTable(
                name: "processed_operations");

            migrationBuilder.DropTable(
                name: "sync_client_clock");

            migrationBuilder.DropTable(
                name: "sync_gc_state");

            migrationBuilder.DropTable(
                name: "sync_orset_removes");

            migrationBuilder.DropTable(
                name: "sync_orset_tags");

            migrationBuilder.DropTable(
                name: "sync_scalar_meta");
        }
    }
}
