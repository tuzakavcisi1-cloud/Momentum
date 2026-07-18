namespace Momentum.Domain.Sync;

/// <summary>
/// Per-field Last-Writer-Wins register (ADR 0002 K2-C1). The comparison key is <see cref="HlcKey"/>;
/// a write wins iff its key is STRICTLY greater (equal or smaller keeps the incumbent). Also backs the
/// Order channel (fractional-index positionKey is an opaque scalar-LWW value; K2-C3). The winner's
/// <c>operationId</c> is retained (<c>sync_scalar_meta</c> alignment).
/// </summary>
public sealed class LwwRegister
{
    public bool HasValue { get; private set; }

    public string? Value { get; private set; }

    public HlcKey Key { get; private set; }

    /// <returns><c>true</c> if <paramref name="write"/> won and mutated the register.</returns>
    public bool Apply(FieldWrite write, Guid operationId)
    {
        ArgumentNullException.ThrowIfNull(write);
        var candidate = new HlcKey(write.Hlc, operationId);
        if (HasValue && candidate <= Key)
        {
            return false;
        }

        HasValue = true;
        Value = write.Value;
        Key = candidate;
        return true;
    }

    /// <summary>slice-2b1 D0 (ADDITIVE): restore a persisted winning value+key (hydrate; no comparison).</summary>
    public void Load(string? value, HlcKey key)
    {
        HasValue = true;
        Value = value;
        Key = key;
    }
}
