namespace Momentum.Domain.Sync;

/// <summary>
/// Client-side HLC generator (ADR 0002 K2-A2 tick, K2-A3 receive/merge). Time comes only from
/// <see cref="TimeProvider"/> (never <c>DateTime.UtcNow</c>). Not required to be thread-safe:
/// single client-side use; the server path uses <see cref="EffectiveHlcAssigner"/> instead.
/// </summary>
public sealed class HlcClock
{
    private readonly TimeProvider _timeProvider;
    private readonly Guid _clientId;

    public HlcClock(TimeProvider timeProvider, Guid clientId)
    {
        ArgumentNullException.ThrowIfNull(timeProvider);
        _timeProvider = timeProvider;
        _clientId = clientId;
        Local = new Hlc(0, 0, clientId);
    }

    public Hlc Local { get; private set; }

    private long NowMs() => _timeProvider.GetUtcNow().ToUnixTimeMilliseconds();

    /// <summary>Local event (K2-A2). Counter overflow carries into WallMs.</summary>
    public Hlc Tick()
    {
        var wall = NowMs();
        Hlc next;
        if (wall > Local.WallMs)
        {
            next = new Hlc(wall, 0, _clientId);
        }
        else if (Local.Counter == uint.MaxValue)
        {
            next = new Hlc(Local.WallMs + 1, 0, _clientId);
        }
        else
        {
            next = new Hlc(Local.WallMs, Local.Counter + 1, _clientId);
        }

        Local = next;
        return next;
    }

    /// <summary>
    /// Receive/merge (K2-A3 Kulkarni). Counter overflow in any of the three counter branches
    /// carries into WallMs (K2-A2 rule): a candidate above <see cref="uint.MaxValue"/> becomes
    /// <c>(w'+1, 0)</c>.
    /// </summary>
    public Hlc Receive(Hlc m)
    {
        var wall = NowMs();
        var wPrime = Math.Max(Local.WallMs, Math.Max(m.WallMs, wall));

        ulong candidate;
        if (wPrime == Local.WallMs && wPrime == m.WallMs)
        {
            candidate = (ulong)Math.Max(Local.Counter, m.Counter) + 1UL;
        }
        else if (wPrime == Local.WallMs)
        {
            candidate = (ulong)Local.Counter + 1UL;
        }
        else if (wPrime == m.WallMs)
        {
            candidate = (ulong)m.Counter + 1UL;
        }
        else
        {
            candidate = 0UL;
        }

        var next = candidate > uint.MaxValue
            ? new Hlc(wPrime + 1, 0, _clientId)
            : new Hlc(wPrime, (uint)candidate, _clientId);

        Local = next;
        return next;
    }
}
