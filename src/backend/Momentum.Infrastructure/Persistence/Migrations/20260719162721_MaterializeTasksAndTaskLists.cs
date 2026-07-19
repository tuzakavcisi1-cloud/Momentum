using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Momentum.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class MaterializeTasksAndTaskLists : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "task_lists",
                columns: table => new
                {
                    entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    owner_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: true),
                    is_deleted = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    pos = table.Column<string>(type: "text", nullable: true, collation: "C"),
                    has_delete_edit_conflict = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    malformed_fields = table.Column<List<string>>(type: "text[]", nullable: false, defaultValueSql: "'{}'")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_task_lists", x => x.entity_id);
                });

            migrationBuilder.CreateTable(
                name: "task_tags",
                columns: table => new
                {
                    task_id = table.Column<Guid>(type: "uuid", nullable: false),
                    tag = table.Column<string>(type: "text", nullable: false, collation: "C")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_task_tags", x => new { x.task_id, x.tag });
                });

            migrationBuilder.CreateTable(
                name: "tasks",
                columns: table => new
                {
                    entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    owner_id = table.Column<Guid>(type: "uuid", nullable: false),
                    title = table.Column<string>(type: "text", nullable: true),
                    notes = table.Column<string>(type: "text", nullable: true),
                    priority = table.Column<int>(type: "integer", nullable: true),
                    due_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    remind_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    project_id = table.Column<Guid>(type: "uuid", nullable: true),
                    is_deleted = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    recurrence_rule = table.Column<string>(type: "text", nullable: true),
                    list_pos = table.Column<string>(type: "text", nullable: true, collation: "C"),
                    board_pos = table.Column<string>(type: "text", nullable: true, collation: "C"),
                    status = table.Column<string>(type: "text", nullable: true),
                    completed_at = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    has_delete_edit_conflict = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    malformed_fields = table.Column<List<string>>(type: "text[]", nullable: false, defaultValueSql: "'{}'")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tasks", x => x.entity_id);
                });

            migrationBuilder.CreateIndex(
                name: "ix_task_lists_owner_deleted_pos_entity",
                table: "task_lists",
                columns: new[] { "owner_id", "is_deleted", "pos", "entity_id" });

            migrationBuilder.CreateIndex(
                name: "ix_tasks_owner_deleted_listpos_entity",
                table: "tasks",
                columns: new[] { "owner_id", "is_deleted", "list_pos", "entity_id" });

            migrationBuilder.CreateIndex(
                name: "ix_tasks_owner_project",
                table: "tasks",
                columns: new[] { "owner_id", "project_id" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "task_lists");

            migrationBuilder.DropTable(
                name: "task_tags");

            migrationBuilder.DropTable(
                name: "tasks");
        }
    }
}
