namespace Momentum.SyncCore.Tests.TestUtil;

/// <summary>Property iteration count (GOREV slice-2a D9): &gt;= 1000, overridable via <c>CsCheck_Iter</c>.</summary>
public static class PropertyConfig
{
    public static long Iter { get; } =
        long.TryParse(Environment.GetEnvironmentVariable("CsCheck_Iter"), out var value) && value > 0
            ? value
            : 1000;
}
