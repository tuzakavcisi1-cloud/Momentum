using System.Text.Json;
using Momentum.Domain.Sync;

namespace Momentum.Application.Features.Sync;

/// <summary>
/// Wire &lt;-&gt; Domain envelope mapping (GOREV slice-2b1 D3/D4). The outbox payload is the accepted op
/// with CLAMPED HLCs — produced by reusing the Domain <see cref="HlcClamp"/> (no second clamp logic).
/// </summary>
public static class WireMapping
{
    public static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);

    private static readonly IReadOnlyDictionary<string, WireFieldWrite> NoFields = new Dictionary<string, WireFieldWrite>(StringComparer.Ordinal);
    private static readonly IReadOnlyDictionary<string, WireSetDelta> NoSets = new Dictionary<string, WireSetDelta>(StringComparer.Ordinal);
    private static readonly IReadOnlyDictionary<string, WireGroupWrite> NoGroups = new Dictionary<string, WireGroupWrite>(StringComparer.Ordinal);

    public static Hlc ToHlc(WireHlc hlc) => new(hlc.WallMs, hlc.Counter, hlc.ClientId);

    public static WireHlc ToWire(Hlc hlc) => new(hlc.WallMs, hlc.Counter, hlc.ClientId);

    public static ChangeOperation ToDomain(WireOp op)
    {
        var fields = (op.Fields ?? NoFields).ToDictionary(
            kv => kv.Key, kv => new FieldWrite(kv.Value.Value, ToHlc(kv.Value.Hlc)), StringComparer.Ordinal);

        var order = (op.Order ?? NoFields).ToDictionary(
            kv => kv.Key, kv => new FieldWrite(kv.Value.Value, ToHlc(kv.Value.Hlc)), StringComparer.Ordinal);

        var groups = (op.Groups ?? NoGroups).ToDictionary(
            kv => kv.Key,
            kv => new GroupWrite(new Dictionary<string, string?>(kv.Value.Fields, StringComparer.Ordinal), ToHlc(kv.Value.Hlc)),
            StringComparer.Ordinal);

        var sets = (op.Sets ?? NoSets).ToDictionary(
            kv => kv.Key,
            kv => new SetDelta(
                (kv.Value.Adds ?? []).Select(a => new SetAdd(a.El, a.Tag, ToHlc(a.Hlc))).ToList(),
                (kv.Value.Removes ?? []).Select(r => new SetRemove(r.El, r.Observed, ToHlc(r.Hlc))).ToList()),
            StringComparer.Ordinal);

        return new ChangeOperation(
            op.OperationId, op.ClientId, op.EntityId, op.ActorId, op.EntityType, ToHlc(op.OpHlc), fields, sets, groups, order);
    }

    /// <summary>
    /// Canonical JSON of the accepted op with every HLC clamped (ADR 0002 K2-B1, outbox payload).
    /// IS-EMRI-o83 F5 KILIDI: <paramref name="authenticatedActorId"/> OVERWRITES the wire-declared
    /// <c>op.ActorId</c> here too -- not just in <c>OutboxRecord.ActorId</c> (SyncCommandHandler.BuildOutbox).
    /// This payload is exactly what OTHER clients receive back as <c>WireChange.Payload</c> via pull; if
    /// only the DB column were fixed, a spoofed actorId would still reach every OTHER client's screen.
    /// </summary>
    public static string ClampedPayload(WireOp op, long serverReceiveWallMs, Guid authenticatedActorId)
    {
        WireHlc Clamp(WireHlc h) => ToWire(HlcClamp.Clamp(ToHlc(h), serverReceiveWallMs));

        var clamped = op with
        {
            ActorId = authenticatedActorId,
            OpHlc = Clamp(op.OpHlc),
            Fields = op.Fields?.ToDictionary(kv => kv.Key, kv => kv.Value with { Hlc = Clamp(kv.Value.Hlc) }, StringComparer.Ordinal),
            Order = op.Order?.ToDictionary(kv => kv.Key, kv => kv.Value with { Hlc = Clamp(kv.Value.Hlc) }, StringComparer.Ordinal),
            Groups = op.Groups?.ToDictionary(kv => kv.Key, kv => kv.Value with { Hlc = Clamp(kv.Value.Hlc) }, StringComparer.Ordinal),
            Sets = op.Sets?.ToDictionary(
                kv => kv.Key,
                kv => new WireSetDelta(
                    kv.Value.Adds?.Select(a => a with { Hlc = Clamp(a.Hlc) }).ToList(),
                    kv.Value.Removes?.Select(r => r with { Hlc = Clamp(r.Hlc) }).ToList()),
                StringComparer.Ordinal),
        };

        return JsonSerializer.Serialize(clamped, Json);
    }

    public static WireIngestResult ToWire(IngestResult result) =>
        new(result.OperationId, result.Code.ToString(), result.EffectiveOpHlc is { } e ? ToWire(e) : null);
}
