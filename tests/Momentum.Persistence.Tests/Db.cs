using Npgsql;

namespace Momentum.Persistence.Tests;

/// <summary>Tiny raw-SQL helpers for asserting on DB state and driving controlled-timing hazard tests.</summary>
public static class Db
{
    public static async Task<NpgsqlConnection> OpenAsync(string connectionString)
    {
        var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        return connection;
    }

    public static async Task<T> ScalarAsync<T>(string connectionString, string sql, params (string Name, object Value)[] parameters)
    {
        await using var connection = await OpenAsync(connectionString);
        return await ScalarAsync<T>(connection, null, sql, parameters);
    }

    public static async Task<T> ScalarAsync<T>(NpgsqlConnection connection, NpgsqlTransaction? transaction, string sql, params (string Name, object Value)[] parameters)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        command.Transaction = transaction;
        foreach (var (name, value) in parameters)
        {
            command.Parameters.AddWithValue(name, value);
        }

        var result = await command.ExecuteScalarAsync();
        return result is null or DBNull ? default! : (T)result;
    }

    public static async Task ExecuteAsync(string connectionString, string sql, params (string Name, object Value)[] parameters)
    {
        await using var connection = await OpenAsync(connectionString);
        await ExecuteAsync(connection, null, sql, parameters);
    }

    public static async Task ExecuteAsync(NpgsqlConnection connection, NpgsqlTransaction? transaction, string sql, params (string Name, object Value)[] parameters)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        command.Transaction = transaction;
        foreach (var (name, value) in parameters)
        {
            command.Parameters.AddWithValue(name, value);
        }

        await command.ExecuteNonQueryAsync();
    }

    /// <summary>
    /// Inserts an outbox row on an explicit connection/transaction (controlled commit timing).
    /// slice-2b2 D6-b (KB-A): NO SQL <c>now()</c> anywhere in the seed path -- <c>available_at</c> and
    /// <c>occurred_at</c> are written from an explicit <see cref="DateTimeOffset"/> (the D6-1 default-drop
    /// makes a bare insert without <c>available_at</c> fail NOT NULL; writing <c>now()</c> here would
    /// silently reintroduce the DB-clock bug the dispatcher's TimeProvider pin exists to close).
    /// </summary>
    public static async Task InsertOutboxAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid ownerId, string hlc, DateTimeOffset? at = null)
    {
        var when = at ?? DateTimeOffset.UtcNow;
        await ExecuteAsync(connection, transaction,
            "INSERT INTO outbox_messages (id, aggregate_type, aggregate_id, operation_id, owner_id, actor_id, event_type, payload, hlc, occurred_at, available_at) " +
            "VALUES (@id, 'Task', @ai, @oi, @ow, @ow, 'Task.changed', '{}'::jsonb, @hlc, @at, @at)",
            ("id", Guid.CreateVersion7()), ("ai", Guid.NewGuid()), ("oi", Guid.NewGuid()), ("ow", ownerId), ("hlc", hlc), ("at", when));
    }
}
