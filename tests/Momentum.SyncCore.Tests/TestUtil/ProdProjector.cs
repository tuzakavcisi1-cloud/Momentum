using System.Text;
using Momentum.Domain.Sync;

namespace Momentum.SyncCore.Tests.TestUtil;

/// <summary>
/// Builds the SAME observational projection string as <c>OracleEngine.Project()</c> from the production
/// <see cref="SyncState"/> (D8 comparison surface): field/order values + winning keys, group members +
/// key, set MEMBERSHIP (not tag internals), and the derived C4 conflict flag. Entities/keys sorted
/// deterministically (Ordinal).
/// </summary>
public static class ProdProjector
{
    public static string Project(SyncState state)
    {
        var builder = new StringBuilder();
        foreach (var (key, entity) in state.Entities
                     .OrderBy(e => e.Key.EntityType, StringComparer.Ordinal)
                     .ThenBy(e => e.Key.EntityId.ToString("N"), StringComparer.Ordinal))
        {
            builder.Append("E|").Append(key.EntityType).Append('|').Append(key.EntityId.ToString("N")).Append('\n');

            foreach (var (name, register) in entity.Fields
                         .Where(f => f.Value.HasValue)
                         .OrderBy(f => f.Key, StringComparer.Ordinal))
            {
                builder.Append("F|").Append(name).Append('|').Append(ValueRepr(register.Value)).Append('|')
                    .Append(register.Key.Encode()).Append('\n');
            }

            foreach (var (name, register) in entity.Orders
                         .Where(f => f.Value.HasValue)
                         .OrderBy(f => f.Key, StringComparer.Ordinal))
            {
                builder.Append("O|").Append(name).Append('|').Append(ValueRepr(register.Value)).Append('|')
                    .Append(register.Key.Encode()).Append('\n');
            }

            foreach (var (name, group) in entity.Groups
                         .Where(g => g.Value.HasValue)
                         .OrderBy(g => g.Key, StringComparer.Ordinal))
            {
                var members = string.Join(",", group.Fields
                    .OrderBy(m => m.Key, StringComparer.Ordinal)
                    .Select(m => m.Key + "=" + ValueRepr(m.Value)));
                builder.Append("G|").Append(name).Append('|').Append(members).Append('|')
                    .Append(group.Key.Encode()).Append('\n');
            }

            foreach (var (name, set) in entity.Sets.OrderBy(s => s.Key, StringComparer.Ordinal))
            {
                var present = set.PresentElements().OrderBy(e => e, StringComparer.Ordinal);
                builder.Append("S|").Append(name).Append('|').Append(string.Join(",", present)).Append('\n');
            }

            builder.Append("C|").Append(entity.HasDeleteEditConflict ? "1" : "0").Append('\n');
        }

        return builder.ToString();
    }

    private static string ValueRepr(string? value) => value is null ? "<null>" : value;
}
