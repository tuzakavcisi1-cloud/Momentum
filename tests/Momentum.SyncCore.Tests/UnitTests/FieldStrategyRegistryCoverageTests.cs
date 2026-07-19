using System.Collections;
using System.Reflection;
using Momentum.Domain.Sync;
using Shouldly;
using Xunit;

namespace Momentum.SyncCore.Tests.UnitTests;

/// <summary>
/// D2b (GOREV slice-3a, ADR 0002 K2-B2): <see cref="FieldStrategyRegistry.DescribeFieldKeys"/> must
/// truly DERIVE from <c>_entities</c> (never a hand-written literal that can go stale), and Task/TaskList
/// keys must be fully covered by the projection (mapped column, named <c>Deferred</c>, or a group marker
/// whose members are ALL mapped).
/// </summary>
public sealed class FieldStrategyRegistryCoverageTests
{
    /// <summary>
    /// CANLILIK ASSERT'I (v5's fix for v2/v3/v4's mutant-13 muafiyeti): reads <c>_entities</c> via
    /// reflection and computes the expected key set INDEPENDENTLY of <see cref="FieldStrategyRegistry.DescribeFieldKeys"/>,
    /// then compares. A frozen/hand-written <c>DescribeFieldKeys</c> would diverge the moment <c>_entities</c>
    /// changes (mutant-13's actual kill surface) even though the three-bucket rule below cannot see it.
    /// </summary>
    [Fact]
    public void DescribeFieldKeys_derives_live_from_the_entities_field_for_every_registered_entity_type()
    {
        var registry = FieldStrategyRegistry.Default;
        var entitiesField = typeof(FieldStrategyRegistry).GetField("_entities", BindingFlags.NonPublic | BindingFlags.Instance)!;
        var entities = (IDictionary)entitiesField.GetValue(registry)!;

        foreach (DictionaryEntry entry in entities)
        {
            var entityType = (string)entry.Key;
            var definition = entry.Value!;
            var definitionType = definition.GetType();

            var scalars = (IEnumerable<string>)definitionType.GetProperty("Scalars")!.GetValue(definition)!;
            var orSets = (IEnumerable<string>)definitionType.GetProperty("OrSets")!.GetValue(definition)!;
            var fractionals = (IEnumerable<string>)definitionType.GetProperty("Fractionals")!.GetValue(definition)!;
            var groups = (IDictionary)definitionType.GetProperty("Groups")!.GetValue(definition)!;

            var expected = new HashSet<string>(StringComparer.Ordinal);
            expected.UnionWith(scalars);
            expected.UnionWith(orSets);
            expected.UnionWith(fractionals);
            foreach (DictionaryEntry groupEntry in groups)
            {
                var groupName = (string)groupEntry.Key;
                expected.Add(groupName);
                foreach (var member in (IEnumerable<string>)groupEntry.Value!)
                {
                    expected.Add($"{groupName}.{member}");
                }
            }

            registry.DescribeFieldKeys(entityType).ShouldBe(expected, ignoreOrder: true);
        }
    }

    /// <summary>KABUL KURALI — UC KOVA: every Task field key maps to a projection column, is named
    /// Deferred (assignees/checklistItems), or is the "completion" group marker with ALL members mapped.</summary>
    [Fact]
    public void Task_field_keys_are_fully_covered_by_projection_deferred_or_group_marker()
    {
        var keys = FieldStrategyRegistry.Default.DescribeFieldKeys("Task");
        var mapped = new HashSet<string>(StringComparer.Ordinal)
        {
            "title", "notes", "priority", "dueAt", "remindAt", "projectId", "isDeleted",
            "recurrenceRule", "listPos", "boardPos", "tags", "completion.status", "completion.completedAt",
        };
        var deferred = new HashSet<string>(StringComparer.Ordinal) { "assignees", "checklistItems" };
        var groupMarkers = new HashSet<string>(StringComparer.Ordinal) { "completion" };

        foreach (var key in keys)
        {
            (mapped.Contains(key) || deferred.Contains(key) || groupMarkers.Contains(key))
                .ShouldBeTrue($"'{key}' falls into none of the three buckets (mapped / Deferred / group marker).");
        }

        keys.ShouldContain("completion");
        keys.Where(k => k.StartsWith("completion.", StringComparison.Ordinal)).ShouldAllBe(k => mapped.Contains(k));
    }

    /// <summary>Same rule for TaskList: name/isDeleted/pos are the only mapped columns; no Deferred, no groups.</summary>
    [Fact]
    public void TaskList_field_keys_are_fully_covered_by_projection_columns()
    {
        var keys = FieldStrategyRegistry.Default.DescribeFieldKeys("TaskList");
        var mapped = new HashSet<string>(StringComparer.Ordinal) { "name", "isDeleted", "pos" };

        foreach (var key in keys)
        {
            mapped.Contains(key).ShouldBeTrue($"'{key}' is not mapped to a TaskList projection column.");
        }
    }
}
