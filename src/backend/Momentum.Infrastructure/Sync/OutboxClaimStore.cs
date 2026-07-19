using System.Globalization;
using Momentum.Application.Features.Sync;
using Npgsql;

namespace Momentum.Infrastructure.Sync;

/// <summary>One claimed outbox row (GOREV slice-2b2 D2), enough to route + backoff without re-reading it.</summary>
public sealed record ClaimedOutboxRow(Guid Id, Guid OwnerId, Guid? ScopeId, Guid? OldScopeId, WireCursor Cursor, int Attempts);

/// <summary>
/// Raw-SQL lease claim/close for <c>outbox_messages</c> (ADR 0002 K2-F2, GOREV slice-2b2 D2/D2-g). Opens
/// its OWN <see cref="NpgsqlConnection"/> per call -- NEVER the shared <c>SyncDbContext</c> connection --
/// so two dispatcher instances are genuinely independent sessions (sharing one session would make H9's
/// SKIP LOCKED gate a tautology: a session always "sees" its own uncommitted locks). <c>lock_timeout</c>
/// is set IN THE CONNECTION STRING (a pooled connection can have a session-level SET reset from under it);
/// this is what turns mutant-8 (SKIP LOCKED removed) into a FAILING exception instead of a hang.
/// </summary>
public sealed class OutboxClaimStore
{
    private const string ClaimSql =
        "UPDATE outbox_messages " +
        "   SET attempts = attempts + 1, available_at = @availableAt " +
        " WHERE id = ANY (SELECT id FROM outbox_messages " +
        "                  WHERE signaled_at IS NULL AND available_at <= @now " +
        "                  ORDER BY commit_xid, server_seq " +
        "                    FOR UPDATE SKIP LOCKED " +
        "                  LIMIT @batch) " +
        "RETURNING id, owner_id, scope_id, old_scope_id, commit_xid::text, server_seq, attempts;";

    private readonly string _connectionString;

    public OutboxClaimStore(string connectionString)
    {
        var builder = new NpgsqlConnectionStringBuilder(connectionString)
        {
            CommandTimeout = 10,
            Options = "-c lock_timeout=5000", // 5s; GUC default unit for lock_timeout is milliseconds
        };
        _connectionString = builder.ConnectionString;
    }

    /// <summary>
    /// Txn-1 (ADR 0002 K2-F2 refinement, D2-a): makes up to <paramref name="batchSize"/> eligible rows
    /// invisible to other claimants (lease) and commits. Does NOT publish and does NOT close rows.
    /// Propagates any exception (including a lock_timeout abort) -- callers must not swallow it (D2-f).
    /// </summary>
    public async Task<IReadOnlyList<ClaimedOutboxRow>> ClaimAsync(int batchSize, DateTimeOffset now, TimeSpan lease, CancellationToken cancellationToken)
    {
        await using var connection = new NpgsqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);
        await using var transaction = await connection.BeginTransactionAsync(cancellationToken);

        await using var command = connection.CreateCommand();
        command.Transaction = transaction;
        command.CommandText = ClaimSql;
        command.Parameters.AddWithValue("now", now);
        command.Parameters.AddWithValue("availableAt", now + lease);
        command.Parameters.AddWithValue("batch", batchSize);

        var rows = new List<ClaimedOutboxRow>();
        await using (var reader = await command.ExecuteReaderAsync(cancellationToken))
        {
            while (await reader.ReadAsync(cancellationToken))
            {
                var cursor = new WireCursor(ulong.Parse(reader.GetString(4), CultureInfo.InvariantCulture), reader.GetInt64(5));
                rows.Add(new ClaimedOutboxRow(
                    reader.GetGuid(0),
                    reader.GetGuid(1),
                    reader.IsDBNull(2) ? null : reader.GetGuid(2),
                    reader.IsDBNull(3) ? null : reader.GetGuid(3),
                    cursor,
                    reader.GetInt32(6)));
            }
        }

        await transaction.CommitAsync(cancellationToken);
        return rows;
    }

    /// <summary>
    /// Txn-2 (D2-a), OUTSIDE the claim txn and after publishing: rows whose groups ALL succeeded are
    /// closed (<c>signaled_at</c>); rows with at least one failed group are reopened with a per-row
    /// backoff (D1's YB-1 all-or-nothing-per-row rule). Never deletes/discards a row (§5).
    /// </summary>
    public async Task CloseAsync(
        IReadOnlyCollection<Guid> okIds,
        IReadOnlyCollection<(Guid Id, int BackoffSeconds)> reopenRows,
        DateTimeOffset now,
        CancellationToken cancellationToken)
    {
        await using var connection = new NpgsqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        if (okIds.Count > 0)
        {
            await using var command = connection.CreateCommand();
            command.CommandText = "UPDATE outbox_messages SET signaled_at = @now WHERE id = ANY(@ids)";
            command.Parameters.AddWithValue("now", now);
            command.Parameters.AddWithValue("ids", okIds.ToArray());
            await command.ExecuteNonQueryAsync(cancellationToken);
        }

        if (reopenRows.Count > 0)
        {
            await using var command = connection.CreateCommand();
            command.CommandText =
                "UPDATE outbox_messages AS o " +
                "   SET available_at = @now + (v.backoff_seconds * interval '1 second') " +
                "  FROM (SELECT unnest(@ids) AS id, unnest(@backoffs) AS backoff_seconds) AS v " +
                " WHERE o.id = v.id";
            command.Parameters.AddWithValue("now", now);
            command.Parameters.AddWithValue("ids", reopenRows.Select(r => r.Id).ToArray());
            command.Parameters.AddWithValue("backoffs", reopenRows.Select(r => r.BackoffSeconds).ToArray());
            await command.ExecuteNonQueryAsync(cancellationToken);
        }
    }
}
