namespace Momentum.Domain.Sync;

/// <summary>
/// Server-enforced field-to-strategy registry (ADR 0002 K2-B2), full 4-entity table. Ingest ENFORCES
/// it: an op that sends a field on the wrong channel (e.g. a group member <c>status</c> via the scalar
/// <c>Fields</c> channel, an OR-Set field via <c>Fields</c>, a scalar via <c>Sets</c>, a fractional via
/// <c>Fields</c>), an unknown field, or an unknown entityType is rejected WHOLE — no remap (ADR H11).
/// Name matching is Ordinal, case-sensitive.
/// </summary>
public sealed class FieldStrategyRegistry
{
    private sealed record EntityDefinition(
        IReadOnlySet<string> Scalars,
        IReadOnlySet<string> OrSets,
        IReadOnlySet<string> Fractionals,
        IReadOnlyDictionary<string, IReadOnlySet<string>> Groups);

    private readonly IReadOnlyDictionary<string, EntityDefinition> _entities;

    private FieldStrategyRegistry(IReadOnlyDictionary<string, EntityDefinition> entities) => _entities = entities;

    /// <summary>The canonical registry locked by ADR 0002 K2-B2.</summary>
    public static FieldStrategyRegistry Default { get; } = BuildDefault();

    /// <summary>
    /// Whole-op validity: <c>true</c> iff the entityType is known AND every channel key sits on its
    /// registered channel (and every group member key belongs to that group).
    /// </summary>
    public bool IsOperationValid(ChangeOperation op)
    {
        ArgumentNullException.ThrowIfNull(op);

        if (!_entities.TryGetValue(op.EntityType, out var def))
        {
            return false;
        }

        foreach (var field in op.Fields.Keys)
        {
            if (!def.Scalars.Contains(field))
            {
                return false;
            }
        }

        foreach (var set in op.Sets.Keys)
        {
            if (!def.OrSets.Contains(set))
            {
                return false;
            }
        }

        foreach (var order in op.Order.Keys)
        {
            if (!def.Fractionals.Contains(order))
            {
                return false;
            }
        }

        foreach (var (groupName, write) in op.Groups)
        {
            if (!def.Groups.TryGetValue(groupName, out var members))
            {
                return false;
            }

            foreach (var member in write.Fields.Keys)
            {
                if (!members.Contains(member))
                {
                    return false;
                }
            }
        }

        return true;
    }

    /// <summary>
    /// slice-2b1 D0 (ADDITIVE): resolve the strategy for a persisted <c>sync_scalar_meta</c> field key
    /// (scalar, fractional, group marker <c>"group"</c>, or group member <c>"group.member"</c>) so hydrate
    /// routes channels via the ONE registry (no second copy in Infrastructure). Set names use OR-Set.
    /// </summary>
    public bool TryGetStrategy(string entityType, string field, out FieldStrategy strategy)
    {
        ArgumentNullException.ThrowIfNull(field);
        strategy = default;
        if (!_entities.TryGetValue(entityType, out var def))
        {
            return false;
        }

        if (def.Scalars.Contains(field))
        {
            strategy = FieldStrategy.ScalarLww;
            return true;
        }

        if (def.Fractionals.Contains(field))
        {
            strategy = FieldStrategy.FractionalIndex;
            return true;
        }

        if (def.OrSets.Contains(field))
        {
            strategy = FieldStrategy.OrSet;
            return true;
        }

        if (def.Groups.ContainsKey(field))
        {
            strategy = FieldStrategy.ResolvedGroup; // marker row (field == group name)
            return true;
        }

        var dot = field.IndexOf('.', StringComparison.Ordinal);
        if (dot > 0
            && def.Groups.TryGetValue(field[..dot], out var members)
            && members.Contains(field[(dot + 1)..]))
        {
            strategy = FieldStrategy.ResolvedGroup; // "group.member" row
            return true;
        }

        return false;
    }

    /// <summary>
    /// GOREV slice-3a D2b: every field key an <paramref name="entityType"/> can carry — for the
    /// registry-vs-projection full-coverage gate (unknown entityType -&gt; empty). TÜRETME PİNİ
    /// (PAZARLIKSIZ): derived ONLY from <see cref="_entities"/>, never a hand-written literal list, so
    /// this can never silently drift from the enforcement table in <see cref="IsOperationValid"/>.
    /// </summary>
    public IReadOnlyCollection<string> DescribeFieldKeys(string entityType)
    {
        if (!_entities.TryGetValue(entityType, out var def))
        {
            return [];
        }

        var keys = new HashSet<string>(StringComparer.Ordinal);
        keys.UnionWith(def.Scalars);
        keys.UnionWith(def.Fractionals);
        keys.UnionWith(def.OrSets);
        foreach (var (groupName, members) in def.Groups)
        {
            keys.Add(groupName);
            foreach (var member in members)
            {
                keys.Add($"{groupName}.{member}");
            }
        }

        return keys;
    }

    private static FieldStrategyRegistry BuildDefault()
    {
        static IReadOnlySet<string> Set(params string[] names) => new HashSet<string>(names, StringComparer.Ordinal);

        static IReadOnlyDictionary<string, IReadOnlySet<string>> NoGroups() =>
            new Dictionary<string, IReadOnlySet<string>>(StringComparer.Ordinal);

        var entities = new Dictionary<string, EntityDefinition>(StringComparer.Ordinal)
        {
            ["Task"] = new(
                Scalars: Set("title", "notes", "priority", "dueAt", "remindAt", "projectId", "isDeleted", "recurrenceRule"),
                OrSets: Set("tags", "assignees", "checklistItems"),
                Fractionals: Set("listPos", "boardPos"),
                Groups: new Dictionary<string, IReadOnlySet<string>>(StringComparer.Ordinal)
                {
                    ["completion"] = Set("status", "completedAt"),
                }),
            ["Project"] = new(
                Scalars: Set("name", "color", "isDeleted"),
                OrSets: Set("members"),
                Fractionals: Set("pos"),
                Groups: NoGroups()),
            // Section shares the TaskList registry; do NOT add a separate entityType (wire "Section"
            // mapping is decided in slice-2b/Application).
            ["TaskList"] = new(
                Scalars: Set("name", "isDeleted"),
                OrSets: Set(),
                Fractionals: Set("pos"),
                Groups: NoGroups()),
            ["Tag"] = new(
                Scalars: Set("label", "color", "isDeleted"),
                OrSets: Set(),
                Fractionals: Set(),
                Groups: NoGroups()),
        };

        return new FieldStrategyRegistry(entities);
    }
}
