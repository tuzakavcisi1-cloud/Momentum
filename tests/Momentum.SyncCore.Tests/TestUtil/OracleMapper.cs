using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.Oracle;

namespace Momentum.SyncCore.Tests.TestUtil;

/// <summary>
/// Trivial, VISIBLE map from the production envelope to the isolated oracle's mini types (D8). This
/// is the only bridge between the two worlds; the oracle itself never references Momentum.Domain.Sync.
/// </summary>
public static class OracleMapper
{
    public static OracleHlc Map(Hlc hlc) => new(hlc.WallMs, hlc.Counter, hlc.ClientId);

    public static OracleOp Map(ChangeOperation op) => new(
        op.OperationId,
        op.ClientId,
        op.EntityId,
        op.ActorId,
        op.EntityType,
        Map(op.OpHlc),
        op.Fields.ToDictionary(kv => kv.Key, kv => new OracleFieldWrite(kv.Value.Value, Map(kv.Value.Hlc)), StringComparer.Ordinal),
        op.Sets.ToDictionary(kv => kv.Key, kv => new OracleSetDelta(
            kv.Value.Adds.Select(a => new OracleSetAdd(a.Element, a.Tag, Map(a.Hlc))).ToList(),
            kv.Value.Removes.Select(r => new OracleSetRemove(r.Element, r.Observed.ToList(), Map(r.Hlc))).ToList()),
            StringComparer.Ordinal),
        op.Groups.ToDictionary(kv => kv.Key, kv => new OracleGroupWrite(
            new Dictionary<string, string?>(kv.Value.Fields, StringComparer.Ordinal), Map(kv.Value.Hlc)),
            StringComparer.Ordinal),
        op.Order.ToDictionary(kv => kv.Key, kv => new OracleFieldWrite(kv.Value.Value, Map(kv.Value.Hlc)), StringComparer.Ordinal));

    /// <summary>Encode an effective op-HLC for comparison (matches <see cref="OracleHlc.Encode"/>).</summary>
    public static string EncodeEffective(Hlc? hlc) => hlc is { } h ? Map(h).Encode() : "<none>";

    public static string EncodeEffective(OracleHlc? hlc) => hlc is { } h ? h.Encode() : "<none>";
}
