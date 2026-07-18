using CsCheck;
using Momentum.Domain.Sync;

namespace Momentum.SyncCore.Tests.TestUtil;

// Deterministic id factory: distinct (category, index) -> distinct non-empty Guid.
public static class Ids
{
    public static Guid Client(int i) => Make(0x01, i);

    public static Guid Entity(int i) => Make(0x02, i);

    public static Guid Actor(int i) => Make(0x03, i);

    public static Guid Tag(int i) => Make(0x04, i);

    public static Guid Op(int i) => Make(0x05, i);

    private static Guid Make(byte category, int index)
    {
        var bytes = new byte[16];
        bytes[0] = category;
        BitConverter.GetBytes(index).CopyTo(bytes, 4);
        return new Guid(bytes);
    }
}

// ---- generated spec records (integer/choice fields only; materialized deterministically) ----------
public sealed record HlcSpec(long WallOffset, uint Counter, int ClientIdx);

public sealed record RawField(int NameIdx, int ValueIdx, HlcSpec Hlc);

public sealed record RawSetOp(int NameIdx, bool IsAdd, int ElemIdx, int TagIdx, int[] ObservedIdx, HlcSpec Hlc);

public sealed record RawGroup(int Mask, int StatusValIdx, int CompletedValIdx, HlcSpec Hlc);

public sealed record OpSpec(
    int TypeIdx,
    int ClientIdx,
    int EntityIdx,
    HlcSpec OpHlc,
    RawField[] Fields,
    RawSetOp[] Sets,
    RawGroup? Group,
    RawField[] Orders,
    long ReceiveOffset);

public sealed record CompactSpec(int TypeIdx, int EntityIdx, int SetNameIdx, HlcSpec Horizon);

public sealed record StepSpec(OpSpec? Op, CompactSpec? Compact);

// Materialized, concrete step consumed by both engines.
public abstract record MatStep;

public sealed record MatIngest(ChangeOperation Op, long ReceiveWall) : MatStep;

public sealed record MatCompact(string EntityType, Guid EntityId, string SetName, Hlc Horizon) : MatStep;

/// <summary>
/// CsCheck generators + deterministic materializer for sync scenarios (GOREV slice-2a D9). Produces
/// registry-valid ops across the channels, plus clamp/skew/absurd HLCs, partial groups, unseen-tag
/// removes and compaction events. The seed is reportable via CsCheck on failure.
/// </summary>
public static class Scenario
{
    public const long BaseWall = 1_700_000_000_000; // fixed base (~2023-11); keeps WallMs in [0, 10^13)
    public const long AbsurdForwardMs = 31_536_000_000;

    public const int ClientPool = 4;
    public const int EntityPool = 3;
    public const int ElemPool = 3;
    public const int TagPool = 6;

    private static readonly string[] Types = ["Task", "Project", "TaskList", "Tag"];
    private static readonly string?[] Values = ["A", "B", "C", "true", "false", string.Empty, null];

    private static readonly string[][] Scalars =
    [
        ["title", "notes", "priority", "dueAt", "remindAt", "projectId", "isDeleted", "recurrenceRule"],
        ["name", "color", "isDeleted"],
        ["name", "isDeleted"],
        ["label", "color", "isDeleted"],
    ];

    private static readonly string[][] OrSets =
    [
        ["tags", "assignees", "checklistItems"],
        ["members"],
        [],
        [],
    ];

    private static readonly string[][] Fractionals =
    [
        ["listPos", "boardPos"],
        ["pos"],
        ["pos"],
        [],
    ];

    private static readonly string[] GroupMembers = ["status", "completedAt"];

    private static string Element(int i) => "el" + (i % ElemPool);

    // ---- HLC generators ---------------------------------------------------------------------------
    private static readonly Gen<HlcSpec> HlcNormal =
        from wall in Gen.Long[-600_000, 600_000]
        from counter in Gen.UInt[0u, 5u]
        from client in Gen.Int[0, ClientPool - 1]
        select new HlcSpec(wall, counter, client);

    private static readonly Gen<HlcSpec> HlcAbsurd =
        from wall in Gen.Long[AbsurdForwardMs + 1, AbsurdForwardMs + 5_000_000_000]
        from counter in Gen.UInt[0u, 5u]
        from client in Gen.Int[0, ClientPool - 1]
        select new HlcSpec(wall, counter, client);

    private static readonly Gen<HlcSpec> HlcMaybeAbsurd =
        from k in Gen.Int[0, 24]
        from hlc in k == 0 ? HlcAbsurd : HlcNormal
        select hlc;

    private static Gen<RawField> GenField(Gen<HlcSpec> hlcGen) =>
        from name in Gen.Int[0, 7]
        from value in Gen.Int[0, Values.Length - 1]
        from hlc in hlcGen
        select new RawField(name, value, hlc);

    private static Gen<RawSetOp> GenSetOp(Gen<HlcSpec> hlcGen) =>
        from name in Gen.Int[0, 2]
        from isAdd in Gen.Bool
        from elem in Gen.Int[0, ElemPool - 1]
        from tag in Gen.Int[0, TagPool - 1]
        from observed in Gen.Int[0, TagPool - 1].Array[0, 3]
        from hlc in hlcGen
        select new RawSetOp(name, isAdd, elem, tag, observed, hlc);

    private static Gen<RawGroup?> GenMaybeGroup(Gen<HlcSpec> hlcGen) =>
        from present in Gen.Int[0, 2]
        from mask in Gen.Int[0, 3]
        from statusVal in Gen.Int[0, Values.Length - 1]
        from completedVal in Gen.Int[0, Values.Length - 1]
        from hlc in hlcGen
        select present == 0 ? null : new RawGroup(mask, statusVal, completedVal, hlc);

    private static Gen<OpSpec> GenOp(Gen<HlcSpec> hlcGen) =>
        from typeIdx in Gen.Int[0, 3]
        from clientIdx in Gen.Int[0, ClientPool - 1]
        from entityIdx in Gen.Int[0, EntityPool - 1]
        from opHlc in hlcGen
        from fields in GenField(hlcGen).Array[0, 4]
        from sets in GenSetOp(hlcGen).Array[0, 3]
        from grp in GenMaybeGroup(hlcGen)
        from orders in GenField(hlcGen).Array[0, 2]
        from recv in Gen.Long[-400_000, 400_000]
        select new OpSpec(typeIdx, clientIdx, entityIdx, opHlc, fields, sets, grp, orders, recv);

    private static Gen<CompactSpec> GenCompact =>
        from typeIdx in Gen.Int[0, 1] // only Task/Project have orsets
        from entityIdx in Gen.Int[0, EntityPool - 1]
        from setName in Gen.Int[0, 2]
        from horizon in HlcNormal
        select new CompactSpec(typeIdx, entityIdx, setName, horizon);

    /// <summary>Scenario for P3 (oracle-diff): ops with clamp/absurd variety + interleaved compaction.</summary>
    public static Gen<List<StepSpec>> P3Scenario =>
        (from k in Gen.Int[0, 5]
         from step in k == 0
             ? GenCompact.Select(c => new StepSpec(null, c))
             : GenOp(HlcMaybeAbsurd).Select(o => new StepSpec(o, null))
         select step).List[1, 24];

    /// <summary>Scenario for P1 (permutation): op-only, no compaction, no absurd (fixed receive later).</summary>
    public static Gen<List<OpSpec>> P1OpSet => GenOp(HlcNormal).List[1, 12];

    // ---- materialization --------------------------------------------------------------------------

    public static List<MatStep> Materialize(IReadOnlyList<StepSpec> steps, bool fixedReceive)
    {
        var result = new List<MatStep>(steps.Count);
        for (var i = 0; i < steps.Count; i++)
        {
            var step = steps[i];
            if (step.Op is { } op)
            {
                result.Add(new MatIngest(BuildOp(op, i), fixedReceive ? BaseWall : BaseWall + op.ReceiveOffset));
            }
            else if (step.Compact is { } compact)
            {
                var type = Types[compact.TypeIdx];
                var sets = OrSets[compact.TypeIdx];
                if (sets.Length == 0)
                {
                    continue;
                }

                var setName = sets[compact.SetNameIdx % sets.Length];
                result.Add(new MatCompact(type, Ids.Entity(compact.EntityIdx), setName, Hlc(compact.Horizon)));
            }
        }

        return result;
    }

    public static List<MatStep> MaterializeOps(IReadOnlyList<OpSpec> ops, bool fixedReceive)
    {
        var result = new List<MatStep>(ops.Count);
        for (var i = 0; i < ops.Count; i++)
        {
            result.Add(new MatIngest(BuildOp(ops[i], i), fixedReceive ? BaseWall : BaseWall + ops[i].ReceiveOffset));
        }

        return result;
    }

    private static Hlc Hlc(HlcSpec spec) => new(BaseWall + spec.WallOffset, spec.Counter, Ids.Client(spec.ClientIdx));

    private static Hlc OpHlc(HlcSpec spec, int opClientIdx) =>
        new(BaseWall + spec.WallOffset, spec.Counter, Ids.Client(opClientIdx));

    private static ChangeOperation BuildOp(OpSpec op, int stepIndex)
    {
        var type = Types[op.TypeIdx];
        var scalars = Scalars[op.TypeIdx];
        var orsets = OrSets[op.TypeIdx];
        var fracts = Fractionals[op.TypeIdx];

        var fields = new Dictionary<string, FieldWrite>(StringComparer.Ordinal);
        foreach (var f in op.Fields)
        {
            var name = scalars[f.NameIdx % scalars.Length];
            fields[name] = new FieldWrite(Values[f.ValueIdx], Hlc(f.Hlc)); // last write wins on duplicate name
        }

        var orders = new Dictionary<string, FieldWrite>(StringComparer.Ordinal);
        if (fracts.Length > 0)
        {
            foreach (var o in op.Orders)
            {
                var name = fracts[o.NameIdx % fracts.Length];
                orders[name] = new FieldWrite(Values[o.ValueIdx], Hlc(o.Hlc));
            }
        }

        var groups = new Dictionary<string, GroupWrite>(StringComparer.Ordinal);
        if (op.TypeIdx == 0 && op.Group is { } g)
        {
            var members = new Dictionary<string, string?>(StringComparer.Ordinal);
            if ((g.Mask & 1) != 0)
            {
                members["status"] = Values[g.StatusValIdx];
            }

            if ((g.Mask & 2) != 0)
            {
                members["completedAt"] = Values[g.CompletedValIdx];
            }

            groups["completion"] = new GroupWrite(members, Hlc(g.Hlc));
        }

        var sets = new Dictionary<string, (List<SetAdd> Adds, List<SetRemove> Removes)>(StringComparer.Ordinal);
        if (orsets.Length > 0)
        {
            foreach (var s in op.Sets)
            {
                var name = orsets[s.NameIdx % orsets.Length];
                if (!sets.TryGetValue(name, out var bucket))
                {
                    bucket = ([], []);
                    sets[name] = bucket;
                }

                if (s.IsAdd)
                {
                    bucket.Adds.Add(new SetAdd(Element(s.ElemIdx), Ids.Tag(s.TagIdx), Hlc(s.Hlc)));
                }
                else
                {
                    var observed = s.ObservedIdx.Select(t => Ids.Tag(t % TagPool)).ToList();
                    bucket.Removes.Add(new SetRemove(Element(s.ElemIdx), observed, Hlc(s.Hlc)));
                }
            }
        }

        var setDeltas = sets.ToDictionary(
            kv => kv.Key,
            kv => new SetDelta(kv.Value.Adds, kv.Value.Removes),
            StringComparer.Ordinal);

        return new ChangeOperation(
            Ids.Op(stepIndex),
            Ids.Client(op.ClientIdx),
            Ids.Entity(op.EntityIdx),
            Ids.Actor(op.ClientIdx),
            type,
            OpHlc(op.OpHlc, op.ClientIdx),
            fields,
            setDeltas,
            groups,
            orders);
    }
}
