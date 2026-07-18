using Momentum.Application.Abstractions.Sync;
using Momentum.Domain.Sync;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// <c>sync_client_clock</c> access (ADR 0002 K2-A4). The GREATEST upsert is the ONE sanctioned SQL
/// "LWW"; the client advisory lock serializes it per client.
/// </summary>
public sealed class ClientClock(SyncDbContext db) : IClientClock
{
    public async Task<Hlc?> GetAsync(Guid clientId, CancellationToken cancellationToken)
    {
        await using (var command = await db.CreateRawCommandAsync(
            "SELECT hlc FROM sync_client_clock WHERE client_id = @c", cancellationToken))
        {
            command.Parameters.AddWithValue("c", clientId);
            if (await command.ExecuteScalarAsync(cancellationToken) is string encoded && Hlc.TryParse(encoded, out var hlc))
            {
                return hlc;
            }
        }

        // Lazy per-client restore (ADR 0002 K2-H10): no clock row (e.g. after restart) -> derive from
        // this client's OWN max outbox hlc. The 3-part codec's fixed-position ClientId segment is bytes
        // 24..55 (13 + '.' + 8 + '.' = 23 prefix), so filter per-client (NOT a global max).
        await using var restore = await db.CreateRawCommandAsync(
            "SELECT max(hlc) FROM outbox_messages WHERE substring(hlc from 24 for 32) = @chex", cancellationToken);
        restore.Parameters.AddWithValue("chex", clientId.ToString("N"));
        return await restore.ExecuteScalarAsync(cancellationToken) is string restored && Hlc.TryParse(restored, out var restoredHlc)
            ? restoredHlc
            : null;
    }

    public async Task UpsertGreatestAsync(Guid clientId, Hlc effectiveOpHlc, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "INSERT INTO sync_client_clock (client_id, hlc) VALUES (@c, @h) " +
            "ON CONFLICT (client_id) DO UPDATE SET hlc = GREATEST(excluded.hlc, sync_client_clock.hlc)",
            cancellationToken);
        command.Parameters.AddWithValue("c", clientId);
        command.Parameters.AddWithValue("h", effectiveOpHlc.Encode());
        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}
