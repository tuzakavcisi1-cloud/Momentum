namespace Momentum.SyncCore.Tests.TestUtil;

/// <summary>
/// Hand-made deterministic <see cref="TimeProvider"/> (GOREV slice-2a forbids
/// <c>Microsoft.Extensions.TimeProvider.Testing</c>). Only <see cref="GetUtcNow"/> is needed by
/// <c>HlcClock</c>; clamp receive-times are supplied explicitly by the tests.
/// </summary>
public sealed class ManualTimeProvider : TimeProvider
{
    private long _unixMs;

    public ManualTimeProvider(long initialUnixMs) => _unixMs = initialUnixMs;

    public override DateTimeOffset GetUtcNow() => DateTimeOffset.FromUnixTimeMilliseconds(_unixMs);

    public void SetUnixMs(long unixMs) => _unixMs = unixMs;

    public void Advance(long deltaMs) => _unixMs += deltaMs;
}
