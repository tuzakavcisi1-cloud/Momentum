using System.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using Momentum.Application.Abstractions.Sync;
using Npgsql;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// Op-scope transactions on the shared connection (GOREV slice-2b1 M7). Every scoped writer port uses
/// the same <see cref="SyncDbContext"/>, so a scope's transaction is ambient for all of them. Disposing
/// without <see cref="ISyncOpScope.CommitAsync"/> rolls the op back (advisory xact locks release too).
/// </summary>
public sealed class SyncTransaction(Persistence.SyncDbContext db) : ISyncTransaction
{
    public async Task<ISyncOpScope> BeginOpScopeAsync(CancellationToken cancellationToken)
    {
        var connection = (NpgsqlConnection)db.Database.GetDbConnection();
        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync(cancellationToken);
        }

        var transaction = await db.Database.BeginTransactionAsync(cancellationToken);
        return new SyncOpScope(transaction);
    }

    private sealed class SyncOpScope(IDbContextTransaction transaction) : ISyncOpScope
    {
        private bool _committed;

        public async Task CommitAsync(CancellationToken cancellationToken)
        {
            await transaction.CommitAsync(cancellationToken);
            _committed = true;
        }

        public async ValueTask DisposeAsync()
        {
            if (!_committed)
            {
                try
                {
                    await transaction.RollbackAsync();
                }
                catch (InvalidOperationException)
                {
                    // transaction already completed/aborted (e.g. broken connection) — nothing to roll back
                }
            }

            await transaction.DisposeAsync();
        }
    }
}
