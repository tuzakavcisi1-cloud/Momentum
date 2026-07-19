using System.Text.Json;

namespace Momentum.Application.Features.Sync;

// Wire contracts for POST /v1/sync (ADR 0002 K2-E1, GOREV slice-2b1 D3). JSON is camelCase; HLC is an
// object {wallMs, counter, clientId} (the 2a envelope shape, verbatim).

public sealed record WireHlc(long WallMs, uint Counter, Guid ClientId);

public sealed record WireCursor(ulong Xid, long Seq);

public sealed record WireFieldWrite(string? Value, WireHlc Hlc);

public sealed record WireSetAdd(string El, Guid Tag, WireHlc Hlc);

public sealed record WireSetRemove(string El, IReadOnlyList<Guid> Observed, WireHlc Hlc);

public sealed record WireSetDelta(IReadOnlyList<WireSetAdd>? Adds, IReadOnlyList<WireSetRemove>? Removes);

public sealed record WireGroupWrite(IReadOnlyDictionary<string, string?> Fields, WireHlc Hlc);

public sealed record WireOp(
    Guid OperationId,
    Guid ClientId,
    Guid EntityId,
    Guid ActorId,
    string EntityType,
    WireHlc OpHlc,
    IReadOnlyDictionary<string, WireFieldWrite>? Fields,
    IReadOnlyDictionary<string, WireSetDelta>? Sets,
    IReadOnlyDictionary<string, WireGroupWrite>? Groups,
    IReadOnlyDictionary<string, WireFieldWrite>? Order);

public sealed record SyncRequest(
    Guid ClientId,
    WireHlc? ClientHlc,
    WireCursor? SinceCursor,
    IReadOnlyList<WireOp>? Ops);

public sealed record WireIngestResult(Guid OperationId, string Code, WireHlc? EffectiveOpHlc);

public sealed record WireChange(WireCursor Cursor, JsonElement Payload);

public sealed record WireSnapshotScalar(string Field, string? Value, WireHlc Hlc, Guid WinOperationId);

public sealed record WireSnapshotActiveTag(Guid Tag, WireHlc Hlc);

public sealed record WireSnapshotElement(string Element, IReadOnlyList<WireSnapshotActiveTag> ActiveTags);

public sealed record WireSnapshotSet(string SetName, IReadOnlyList<WireSnapshotElement> Elements);

public sealed record WireSnapshotGroup(string Group, IReadOnlyDictionary<string, string?> Fields, WireHlc Hlc, Guid WinOperationId);

public sealed record WireSnapshotEntity(
    string EntityType,
    Guid EntityId,
    IReadOnlyList<WireSnapshotScalar> Scalars,
    IReadOnlyList<WireSnapshotSet> Sets,
    IReadOnlyList<WireSnapshotGroup> Groups);

public sealed record SyncResponse(
    WireHlc? ServerHlc,
    WireCursor? NextCursor,
    bool HasMore,
    bool ResyncRequired,
    IReadOnlyList<WireIngestResult> Applied,
    IReadOnlyList<WireChange> Changes,
    IReadOnlyList<WireSnapshotEntity>? Snapshot);

/// <summary>
/// A payload-less realtime signal (ADR 0002 K2-G1, GOREV slice-2b2 D1). <c>CursorHint</c> is the
/// Application wire cursor (NOT Domain's authoritative <c>SyncCursor</c>) — a type-level reminder that
/// this is a hint clients may use to decide whether to pull, never a substitute for the real cursor.
/// </summary>
public sealed record SignalEnvelope(string Group, WireCursor CursorHint);
