// Independent oracle model (GOREV slice-2a D8). DELIBERATELY does NOT reference Momentum.Domain.Sync
// -- a second, naive implementation with its own mini types. No `using Momentum.Domain.Sync` anywhere
// in this folder. The test body maps the production envelope onto these types (visible, trivial map).
namespace Momentum.SyncCore.Tests.Oracle;

public readonly record struct OracleHlc(long WallMs, uint Counter, Guid ClientId)
{
    public int CompareTo(OracleHlc other)
    {
        if (WallMs != other.WallMs)
        {
            return WallMs.CompareTo(other.WallMs);
        }

        if (Counter != other.Counter)
        {
            return Counter.CompareTo(other.Counter);
        }

        return string.CompareOrdinal(ClientId.ToString("N"), other.ClientId.ToString("N"));
    }

    public string Encode() => $"{WallMs:D13}.{Counter:x8}.{ClientId:N}";
}

public readonly record struct OracleKey(OracleHlc Hlc, Guid OperationId)
{
    public int CompareTo(OracleKey other)
    {
        var c = Hlc.CompareTo(other.Hlc);
        return c != 0 ? c : string.CompareOrdinal(OperationId.ToString("N"), other.OperationId.ToString("N"));
    }

    public string Encode() => $"{Hlc.WallMs:D13}.{Hlc.Counter:x8}.{Hlc.ClientId:N}.{OperationId:N}";
}

public sealed record OracleFieldWrite(string? Value, OracleHlc Hlc);

public sealed record OracleSetAdd(string Element, Guid Tag, OracleHlc Hlc);

public sealed record OracleSetRemove(string Element, IReadOnlyList<Guid> Observed, OracleHlc Hlc);

public sealed record OracleSetDelta(IReadOnlyList<OracleSetAdd> Adds, IReadOnlyList<OracleSetRemove> Removes);

public sealed record OracleGroupWrite(IReadOnlyDictionary<string, string?> Fields, OracleHlc Hlc);

public sealed record OracleOp(
    Guid OperationId,
    Guid ClientId,
    Guid EntityId,
    Guid ActorId,
    string EntityType,
    OracleHlc OpHlc,
    IReadOnlyDictionary<string, OracleFieldWrite> Fields,
    IReadOnlyDictionary<string, OracleSetDelta> Sets,
    IReadOnlyDictionary<string, OracleGroupWrite> Groups,
    IReadOnlyDictionary<string, OracleFieldWrite> Order);

public enum OracleResultCode
{
    Applied,
    Duplicate,
    RejectedRegistryViolation,
    RejectedAbsurdHlc,
    RejectedSetCapExceeded,
    RejectedInvalid,
}

public sealed record OracleResult(Guid OperationId, OracleResultCode Code, OracleHlc? EffectiveOpHlc);
