namespace Momentum.Domain.Sync;

/// <summary>
/// In-memory per-entity state, shape-aligned to the slice-2b persistence model (materialized row +
/// <c>sync_scalar_meta</c> + <c>sync_orset_tags</c>). Holds scalar/order LWW registers, co-resolved
/// groups, and OR-Sets. <see cref="HasDeleteEditConflict"/> is DERIVED (not stored), per ADR 0002 K2-C4.
/// </summary>
public sealed class EntityState
{
    private const string IsDeletedField = "isDeleted";
    private const string DeletedValue = "true";

    private readonly Dictionary<string, LwwRegister> _fields = new(StringComparer.Ordinal);
    private readonly Dictionary<string, LwwRegister> _orders = new(StringComparer.Ordinal);
    private readonly Dictionary<string, ResolvedGroupField> _groups = new(StringComparer.Ordinal);
    private readonly Dictionary<string, OrSetField> _sets = new(StringComparer.Ordinal);

    public IReadOnlyDictionary<string, LwwRegister> Fields => _fields;

    public IReadOnlyDictionary<string, LwwRegister> Orders => _orders;

    public IReadOnlyDictionary<string, ResolvedGroupField> Groups => _groups;

    public IReadOnlyDictionary<string, OrSetField> Sets => _sets;

    public void ApplyField(string name, FieldWrite write, Guid operationId) =>
        GetOrCreate(_fields, name).Apply(write, operationId);

    public void ApplyOrder(string name, FieldWrite write, Guid operationId) =>
        GetOrCreate(_orders, name).Apply(write, operationId);

    public void ApplyGroup(string name, GroupWrite write, Guid operationId) =>
        GetOrCreate(_groups, name).Apply(write, operationId);

    public OrSetField GetOrCreateSet(string name)
    {
        if (!_sets.TryGetValue(name, out var set))
        {
            set = new OrSetField();
            _sets[name] = set;
        }

        return set;
    }

    public bool TryGetSet(string name, out OrSetField set) => _sets.TryGetValue(name, out set!);

    /// <summary>
    /// C4 delete/edit conflict surfacing (DERIVED): <c>isDeleted == "true"</c> AND some other write's
    /// stamp is strictly greater than the winning <c>isDeleted</c> key. Scalar/order/group compare via
    /// full <see cref="HlcKey"/>; set writes compare via the <c>(WallMs, Counter, ClientId-hex)</c>
    /// prefix (set stamps carry no operationId), prefix-equal meaning "not greater".
    /// </summary>
    public bool HasDeleteEditConflict
    {
        get
        {
            if (!_fields.TryGetValue(IsDeletedField, out var deleted) || !deleted.HasValue)
            {
                return false;
            }

            if (!string.Equals(deleted.Value, DeletedValue, StringComparison.Ordinal))
            {
                return false;
            }

            var deleteKey = deleted.Key;

            foreach (var (name, register) in _fields)
            {
                if (string.Equals(name, IsDeletedField, StringComparison.Ordinal))
                {
                    continue;
                }

                if (register.HasValue && register.Key > deleteKey)
                {
                    return true;
                }
            }

            foreach (var register in _orders.Values)
            {
                if (register.HasValue && register.Key > deleteKey)
                {
                    return true;
                }
            }

            foreach (var group in _groups.Values)
            {
                if (group.HasValue && group.Key > deleteKey)
                {
                    return true;
                }
            }

            foreach (var set in _sets.Values)
            {
                if (set.MaxStamp() is { } maxStamp && maxStamp.CompareTo(deleteKey.Hlc) > 0)
                {
                    return true;
                }
            }

            return false;
        }
    }

    private static TValue GetOrCreate<TValue>(Dictionary<string, TValue> map, string name)
        where TValue : new()
    {
        if (!map.TryGetValue(name, out var value))
        {
            value = new TValue();
            map[name] = value;
        }

        return value;
    }
}
