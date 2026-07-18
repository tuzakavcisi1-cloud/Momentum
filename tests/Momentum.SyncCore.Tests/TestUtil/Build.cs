using Momentum.Domain.Sync;

namespace Momentum.SyncCore.Tests.TestUtil;

/// <summary>Small builders for constructing envelopes in targeted unit tests.</summary>
public static class Build
{
    public static readonly IReadOnlyDictionary<string, FieldWrite> NoFields =
        new Dictionary<string, FieldWrite>(StringComparer.Ordinal);

    public static readonly IReadOnlyDictionary<string, SetDelta> NoSets =
        new Dictionary<string, SetDelta>(StringComparer.Ordinal);

    public static readonly IReadOnlyDictionary<string, GroupWrite> NoGroups =
        new Dictionary<string, GroupWrite>(StringComparer.Ordinal);

    public static readonly IReadOnlyDictionary<string, FieldWrite> NoOrder =
        new Dictionary<string, FieldWrite>(StringComparer.Ordinal);

    public static Hlc H(long wall, uint counter, int clientIdx) => new(wall, counter, Ids.Client(clientIdx));

    public static ChangeOperation Op(
        int opIdx,
        int clientIdx,
        int entityIdx,
        string type,
        Hlc opHlc,
        IReadOnlyDictionary<string, FieldWrite>? fields = null,
        IReadOnlyDictionary<string, SetDelta>? sets = null,
        IReadOnlyDictionary<string, GroupWrite>? groups = null,
        IReadOnlyDictionary<string, FieldWrite>? order = null) =>
        new(Ids.Op(opIdx), Ids.Client(clientIdx), Ids.Entity(entityIdx), Ids.Actor(clientIdx), type, opHlc,
            fields ?? NoFields, sets ?? NoSets, groups ?? NoGroups, order ?? NoOrder);

    public static IReadOnlyDictionary<string, FieldWrite> Fields(params (string Name, string? Value, Hlc Hlc)[] items) =>
        items.ToDictionary(i => i.Name, i => new FieldWrite(i.Value, i.Hlc), StringComparer.Ordinal);

    public static IReadOnlyDictionary<string, GroupWrite> Group(string name, Hlc hlc, params (string Member, string? Value)[] members) =>
        new Dictionary<string, GroupWrite>(StringComparer.Ordinal)
        {
            [name] = new GroupWrite(members.ToDictionary(m => m.Member, m => m.Value, StringComparer.Ordinal), hlc),
        };

    public static IReadOnlyDictionary<string, SetDelta> Set(string name, IReadOnlyList<SetAdd> adds, IReadOnlyList<SetRemove> removes) =>
        new Dictionary<string, SetDelta>(StringComparer.Ordinal) { [name] = new SetDelta(adds, removes) };

    public static SetAdd Add(string element, int tagIdx, Hlc hlc) => new(element, Ids.Tag(tagIdx), hlc);

    public static SetRemove Remove(string element, Hlc hlc, params int[] observedTagIdx) =>
        new(element, observedTagIdx.Select(Ids.Tag).ToList(), hlc);
}
