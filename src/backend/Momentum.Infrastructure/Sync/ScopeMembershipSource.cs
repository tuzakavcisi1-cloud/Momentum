using Momentum.Application.Abstractions.Sync;
using Momentum.Infrastructure.Persistence;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// <see cref="IScopeMembershipSource"/> from the outbox (ADR 0002 K2-G2 half, GOREV slice-2b2 D5). The
/// query is PINNED: <c>scope_id</c> is a projectId, never a userId, so the filter MUST be on
/// <c>owner_id</c> (mutant-7's surface). Outbox is append-only, so this is "every scope this user has
/// EVER written into" -- a user whose visibility was later withdrawn still shows the old scope until the
/// auth slice replaces this with a real membership table (named gap, D5).
/// </summary>
public sealed class ScopeMembershipSource(SyncDbContext db) : IScopeMembershipSource
{
    public async Task<IReadOnlyCollection<Guid>> GetScopesAsync(Guid userId, CancellationToken cancellationToken)
    {
        await using var command = await db.CreateRawCommandAsync(
            "SELECT DISTINCT scope_id FROM outbox_messages WHERE owner_id = @userId AND scope_id IS NOT NULL",
            cancellationToken);
        command.Parameters.AddWithValue("userId", userId);

        var scopes = new List<Guid>();
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            scopes.Add(reader.GetGuid(0));
        }

        return scopes;
    }
}
