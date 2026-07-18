using Momentum.Domain.Sync;
using Momentum.SyncCore.Tests.TestUtil;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.Properties;

/// <summary>
/// P10 (ADR 0002 K2-B2/H11): wrong-channel / unknown-field / unknown-entityType ops are rejected WHOLE
/// (<see cref="IngestResultCode.RejectedRegistryViolation"/>) and never change state.
/// </summary>
public sealed class RegistryProperty
{
    [Fact]
    public void P10_registry_violations_are_rejected_and_state_unchanged()
    {
        var hlc = Build.H(Scenario.BaseWall, 0, 0);

        var violations = new (string Name, ChangeOperation Op)[]
        {
            ("group-member-status-on-scalar-channel",
                Build.Op(2, 0, 0, "Task", hlc, fields: Build.Fields(("status", "x", hlc)))),
            ("orset-field-on-scalar-channel",
                Build.Op(2, 0, 0, "Task", hlc, fields: Build.Fields(("tags", "x", hlc)))),
            ("fractional-field-on-scalar-channel",
                Build.Op(2, 0, 0, "Task", hlc, fields: Build.Fields(("listPos", "x", hlc)))),
            ("scalar-field-on-set-channel",
                Build.Op(2, 0, 0, "Task", hlc, sets: Build.Set("title", [Build.Add("el0", 0, hlc)], []))),
            ("scalar-field-on-order-channel",
                Build.Op(2, 0, 0, "Task", hlc, order: new Dictionary<string, FieldWrite>(StringComparer.Ordinal)
                {
                    ["title"] = new FieldWrite("x", hlc),
                })),
            ("unknown-field",
                Build.Op(2, 0, 0, "Task", hlc, fields: Build.Fields(("foo", "x", hlc)))),
            ("unknown-entity-type",
                Build.Op(2, 0, 0, "Widget", hlc, fields: Build.Fields(("name", "x", hlc)))),
            ("unknown-group-member",
                Build.Op(2, 0, 0, "Task", hlc, groups: Build.Group("completion", hlc, ("foo", "x")))),
            ("unknown-group-name",
                Build.Op(2, 0, 0, "Task", hlc, groups: Build.Group("bogus", hlc, ("status", "x")))),
        };

        foreach (var (name, op) in violations)
        {
            var state = new SyncState();
            var ingest = new SyncIngest(state, new ClientClockStore());
            ingest.Ingest(Build.Op(1, 0, 0, "Task", hlc, fields: Build.Fields(("title", "seed", hlc))), Scenario.BaseWall);
            var before = ProdProjector.Project(state);

            ingest.Ingest(op, Scenario.BaseWall).Code.ShouldBe(IngestResultCode.RejectedRegistryViolation, name);
            ProdProjector.Project(state).ShouldBe(before, name);
        }
    }
}
