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

    /// <summary>Inserts an outbox row on an explicit connection/transaction (controlled commit timing).</summary>
    public static async Task InsertOutboxAsync(NpgsqlConnection connection, NpgsqlTransaction transaction, Guid ownerId, string hlc)
    {
        await ExecuteAsync(connection, transaction,
            "INSERT INTO outbox_messages (id, aggregate_type, aggregate_id, operation_id, owner_id, actor_id, event_type, payload, hlc, occurred_at) " +
            "VALUES (@id, 'Task', @ai, @oi, @ow, @ow, 'Task.changed', '{}'::jsonb, @hlc, now())",
            ("id", Guid.CreateVersion7()), ("ai", Guid.NewGuid()), ("oi", Guid.NewGuid()), ("ow", ownerId), ("hlc", hlc));
    }
}
