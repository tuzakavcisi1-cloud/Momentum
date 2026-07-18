namespace Momentum.Domain.Sync;

/// <summary>
/// Co-resolved field group (ADR 0002 K2-C1b). A single group <see cref="HlcKey"/> decides the winner;
/// the winner's fields are written ATOMICALLY (REPLACE) — never merged field-by-field, so no member of
/// a losing op can leak. Empty <see cref="Fields"/> is legal (the group is emptied).
/// </summary>
public sealed class ResolvedGroupField
{
    private Dictionary<string, string?> _fields = new(StringComparer.Ordinal);

    public bool HasValue { get; private set; }

    public IReadOnlyDictionary<string, string?> Fields => _fields;

    public HlcKey Key { get; private set; }

    /// <returns><c>true</c> if <paramref name="write"/> won and replaced the group.</returns>
    public bool Apply(GroupWrite write, Guid operationId)
    {
        ArgumentNullException.ThrowIfNull(write);
        var candidate = new HlcKey(write.Hlc, operationId);
        if (HasValue && candidate <= Key)
        {
            return false;
        }

        HasValue = true;
        _fields = new Dictionary<string, string?>(write.Fields, StringComparer.Ordinal); // REPLACE entire state
        Key = candidate;
        return true;
    }

    /// <summary>slice-2b1 D0 (ADDITIVE): restore a persisted group (hydrate; no comparison).</summary>
    public void Load(IReadOnlyDictionary<string, string?> fields, HlcKey key)
    {
        ArgumentNullException.ThrowIfNull(fields);
        HasValue = true;
        _fields = new Dictionary<string, string?>(fields, StringComparer.Ordinal);
        Key = key;
    }
}
