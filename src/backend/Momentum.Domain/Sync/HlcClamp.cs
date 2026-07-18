namespace Momentum.Domain.Sync;

/// <summary>
/// Server forward-skew clamp and absurd-HLC detection (ADR 0002 K2-A4/1). Applied to EVERY
/// incoming HLC (op, per-field, set add/remove, group, order) — the per-field clamp closes the
/// poison that a raw op-only clamp missed (auditor M-A). Past dates are never changed.
/// </summary>
public static class HlcClamp
{
    /// <summary>Max forward skew tolerated before clamping (5 minutes; configurable).</summary>
    public const long MaxForwardSkewMs = 300_000;

    /// <summary>Beyond this forward distance (365 days) the HLC is absurd -> reject, not clamp.</summary>
    public const long AbsurdForwardMs = 31_536_000_000;

    public static Hlc Clamp(Hlc hlc, long serverReceiveWallMs, long maxForwardSkewMs = MaxForwardSkewMs)
    {
        var ceiling = serverReceiveWallMs + maxForwardSkewMs;
        var wall = Math.Min(hlc.WallMs, ceiling);
        return hlc with { WallMs = wall };
    }

    public static bool IsAbsurd(Hlc hlc, long serverReceiveWallMs, long absurdForwardMs = AbsurdForwardMs) =>
        hlc.WallMs > serverReceiveWallMs + absurdForwardMs;
}
