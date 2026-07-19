using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Momentum.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class DispatcherIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // GOREV slice-2b2 D6-1/D2-b (SPEC-ERRATA closure): available_at's DB default was `now()`
            // (2b1's InitialSync). SQL now() is now banned everywhere (D2-b: TimeProvider is the ONE clock
            // source for the dispatcher's lease comparisons) -- a row born under the DB clock while the
            // dispatcher runs under a test's fake clock would never satisfy `available_at <= @now`, so the
            // default must go. OutboxWriter (D6-1) now writes available_at explicitly on every insert.
            migrationBuilder.AlterColumn<DateTimeOffset>(
                name: "available_at",
                table: "outbox_messages",
                type: "timestamp with time zone",
                nullable: false,
                oldClrType: typeof(DateTimeOffset),
                oldType: "timestamp with time zone",
                oldDefaultValueSql: "now()");

            // GOREV slice-2b2 D6-2/D6-3: partial indexes for the dispatcher's claim query (D2) and the
            // scope-membership query (D5). Raw SQL (not EF model changes) -- same pattern as InitialSync's
            // commit_xid/server_seq columns.
            migrationBuilder.Sql(
                "CREATE INDEX ix_outbox_dispatch ON outbox_messages (commit_xid, server_seq) WHERE signaled_at IS NULL;");
            migrationBuilder.Sql(
                "CREATE INDEX ix_outbox_owner_scope ON outbox_messages (owner_id, scope_id) WHERE scope_id IS NOT NULL;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP INDEX IF EXISTS ix_outbox_owner_scope;");
            migrationBuilder.Sql("DROP INDEX IF EXISTS ix_outbox_dispatch;");

            migrationBuilder.AlterColumn<DateTimeOffset>(
                name: "available_at",
                table: "outbox_messages",
                type: "timestamp with time zone",
                nullable: false,
                defaultValueSql: "now()",
                oldClrType: typeof(DateTimeOffset),
                oldType: "timestamp with time zone");
        }
    }
}
