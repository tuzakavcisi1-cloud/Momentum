namespace Momentum.Infrastructure.Sync;

/// <summary>
/// <see cref="OutboxDispatcher"/> tuning (ADR 0002 K2-F2, GOREV slice-2b2 D2/D8-i). Production batch is
/// 100; tests inject 10 so a 25-row/25-owner fixture spans multiple pumps deterministically (D8-i pin --
/// the production value must never silently change under test pressure).
/// </summary>
public sealed class OutboxDispatcherOptions
{
    public int BatchSize { get; init; } = 100;

    public TimeSpan Lease { get; init; } = TimeSpan.FromSeconds(30);
}
