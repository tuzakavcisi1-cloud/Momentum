using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Momentum.Application.Abstractions.Sync;
using Momentum.Application.Features.Sync;

namespace Momentum.Infrastructure.Sync;

/// <summary>
/// Signal publisher (ADR 0002 K2-F2, GOREV slice-2b2 D2). A polling <see cref="BackgroundService"/>:
/// claim a lease-protected batch (<see cref="OutboxClaimStore"/>) -> publish payload-less signals
/// (<see cref="ISignalPublisher"/>, resolved OUTSIDE any op transaction, D2-a) -> close only the rows
/// whose groups ALL succeeded. Order-independent, multi-instance safe (SKIP LOCKED); crash between claim
/// and close just lets the lease expire and the row resurface (real at-least-once).
/// <para>
/// Both <see cref="OutboxClaimStore"/> and <see cref="ISignalPublisher"/> are DI-scoped ports -- direct
/// singleton injection is forbidden, so a fresh <see cref="IServiceScope"/> is opened on EVERY pump
/// (D2-e). <see cref="PumpOnceAsync"/> and <see cref="ExecuteAsync"/> have DELIBERATELY different
/// exception contracts (D2-f): the former LEAKS (mutant-8's only kill path), the latter NEVER does
/// (otherwise <c>BackgroundServiceExceptionBehavior.StopHost</c> kills the whole DB-less host).
/// </para>
/// </summary>
public sealed class OutboxDispatcher : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly TimeProvider _timeProvider;
    private readonly OutboxDispatcherOptions _options;
    private readonly ILogger<OutboxDispatcher> _logger;

    public OutboxDispatcher(
        IServiceScopeFactory scopeFactory,
        TimeProvider timeProvider,
        OutboxDispatcherOptions options,
        ILogger<OutboxDispatcher> logger)
    {
        _scopeFactory = scopeFactory;
        _timeProvider = timeProvider;
        _options = options;
        _logger = logger;
    }

    /// <summary>
    /// One pump: returns the number of rows TALEP EDİLEN (claimed in Txn-1) this turn -- NOT the number of
    /// signals published. 0 means nothing was eligible. Exceptions from the claim (e.g. a lock_timeout
    /// abort) or the publish step are NOT caught here -- see the type doc.
    /// </summary>
    public async Task<int> PumpOnceAsync(CancellationToken cancellationToken)
    {
        await using var scope = _scopeFactory.CreateAsyncScope();
        var claimStore = scope.ServiceProvider.GetRequiredService<OutboxClaimStore>();

        var now = _timeProvider.GetUtcNow();
        var rows = await claimStore.ClaimAsync(_options.BatchSize, now, _options.Lease, cancellationToken);
        if (rows.Count == 0)
        {
            return 0;
        }

        var publisher = scope.ServiceProvider.GetRequiredService<ISignalPublisher>();
        var envelopes = BuildEnvelopes(rows);
        var failures = await publisher.PublishAsync(envelopes, cancellationToken);
        var failedGroups = failures.Select(f => f.Group).ToHashSet(StringComparer.Ordinal);

        var okIds = new List<Guid>();
        var reopenRows = new List<(Guid Id, int BackoffSeconds)>();
        foreach (var row in rows)
        {
            // D1 YB-1: a row is closed only if EVERY group it belongs to succeeded.
            if (GroupsFor(row).Any(failedGroups.Contains))
            {
                reopenRows.Add((row.Id, Backoff(row.Attempts)));
            }
            else
            {
                okIds.Add(row.Id);
            }
        }

        await claimStore.CloseAsync(okIds, reopenRows, now, cancellationToken);
        return rows.Count;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var idle = true;
            try
            {
                idle = await PumpOnceAsync(stoppingToken) == 0;
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                // D2-e: ExecuteAsync must NEVER let an exception escape (BackgroundServiceExceptionBehavior
                // .StopHost is the default and would kill the whole host, including a DB-less one).
                _logger.LogWarning(ex, "Outbox dispatcher pump failed; backing off.");
            }

            if (idle)
            {
                try
                {
                    await Task.Delay(PollDelay(), stoppingToken);
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
            }
        }
    }

    private static TimeSpan PollDelay() =>
        TimeSpan.FromSeconds(1) + TimeSpan.FromMilliseconds(Random.Shared.Next(0, 250));

    /// <summary>
    /// <c>attempts</c> is a REQUEST counter (bumped every claim, D2-c) -- backoff uses the post-increment
    /// value the row was just claimed with, not a separate failure count.
    /// </summary>
    private static int Backoff(int attemptsAfterClaim) =>
        (int)Math.Min(Math.Pow(2, attemptsAfterClaim), 60);

    /// <summary>Pump-internal reduction (D3): rows sharing a group in ONE pump collapse to one signal
    /// carrying the group's LARGEST cursor. Across separate pumps a group may re-signal -- harmless,
    /// since a hint is not a cursor.</summary>
    private static IReadOnlyList<SignalEnvelope> BuildEnvelopes(IReadOnlyList<ClaimedOutboxRow> rows)
    {
        var maxByGroup = new Dictionary<string, WireCursor>(StringComparer.Ordinal);
        foreach (var row in rows)
        {
            foreach (var group in GroupsFor(row))
            {
                if (!maxByGroup.TryGetValue(group, out var existing) || IsGreater(row.Cursor, existing))
                {
                    maxByGroup[group] = row.Cursor;
                }
            }
        }

        return maxByGroup.Select(kv => new SignalEnvelope(kv.Key, kv.Value)).ToList();
    }

    private static bool IsGreater(WireCursor candidate, WireCursor current) =>
        candidate.Xid > current.Xid || (candidate.Xid == current.Xid && candidate.Seq > current.Seq);

    /// <summary>Up to 3 groups per row (ADR 0002 K2-F2/C7): owner always, scope if any, old_scope if the
    /// op moved the entity out of a scope (D7 double-publish).</summary>
    private static IEnumerable<string> GroupsFor(ClaimedOutboxRow row)
    {
        yield return $"user:{row.OwnerId}";
        if (row.ScopeId is { } scope)
        {
            yield return $"scope:{scope}";
        }

        if (row.OldScopeId is { } oldScope)
        {
            yield return $"scope:{oldScope}";
        }
    }
}
