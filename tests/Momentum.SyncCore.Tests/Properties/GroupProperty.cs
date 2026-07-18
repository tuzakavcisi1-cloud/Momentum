using CsCheck;
using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

/// <summary>
/// P8 (ADR 0002 K2-H6): the <c>completion</c> group is atomic REPLACE — the final content is exactly
/// one op's write (the max-key winner), with no member leaking from a losing op. Partial and empty
/// group writes are generated too.
/// </summary>
public sealed class GroupProperty
{
    private static readonly string?[] Values = ["s0", "s1", "s2", null];

    [Fact]
    public void P8_completion_group_is_atomic_replace()
    {
        (from mask in Gen.Int[0, 3]
         from statusVal in Gen.Int[0, Values.Length - 1]
         from completedVal in Gen.Int[0, Values.Length - 1]
         from wall in Gen.Long[Scenario.BaseWall - 500_000, Scenario.BaseWall + 500_000]
         from counter in Gen.UInt[0u, 5u]
         from client in Gen.Int[0, 3]
         select (mask, statusVal, completedVal, wall, counter, client)).Array[2, 6]
            .Sample(
                specs =>
                {
                    var state = new SyncState();
                    var ingest = new SyncIngest(state, new ClientClockStore());

                    HlcKey? bestKey = null;
                    Dictionary<string, string?> expected = new(StringComparer.Ordinal);

                    for (var i = 0; i < specs.Length; i++)
                    {
                        var spec = specs[i];
                        var members = new List<(string Member, string? Value)>();
                        if ((spec.mask & 1) != 0)
                        {
                            members.Add(("status", Values[spec.statusVal]));
                        }

                        if ((spec.mask & 2) != 0)
                        {
                            members.Add(("completedAt", Values[spec.completedVal]));
                        }

                        var hlc = Build.H(spec.wall, spec.counter, spec.client);
                        var op = Build.Op(1000 + i, spec.client, 0, "Task", hlc,
                            groups: Build.Group("completion", hlc, members.ToArray()));
                        ingest.Ingest(op, Scenario.BaseWall).Code.ShouldBe(IngestResultCode.Applied);

                        // The group HLC is clamped at ingest; mirror that when computing the expected winner.
                        var clampedWall = Math.Min(spec.wall, Scenario.BaseWall + HlcClamp.MaxForwardSkewMs);
                        var key = new HlcKey(new Hlc(clampedWall, spec.counter, Ids.Client(spec.client)), Ids.Op(1000 + i));
                        if (bestKey is null || key > bestKey.Value)
                        {
                            bestKey = key;
                            expected = members.ToDictionary(m => m.Member, m => m.Value, StringComparer.Ordinal);
                        }
                    }

                    var group = state.Entities[("Task", Ids.Entity(0))].Groups["completion"];
                    group.Fields.Count.ShouldBe(expected.Count);
                    foreach (var (member, value) in expected)
                    {
                        group.Fields.ContainsKey(member).ShouldBeTrue();
                        group.Fields[member].ShouldBe(value);
                    }
                },
                iter: PropertyConfig.Iter);
    }
}
