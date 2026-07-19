namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// Scope membership for realtime group assignment (ADR 0002 K2-G2 half, GOREV slice-2b2 D5). Consulted
/// on EVERY hub connect (never cached) so a connection's group set reflects current visibility, not a
/// stale snapshot. Known gap (named, not silently accepted): a read-only collaborator who has never
/// written to a shared scope has no outbox row for it, so they join no <c>scope:</c> group until the
/// auth slice wires a real membership table.
/// </summary>
public interface IScopeMembershipSource
{
    Task<IReadOnlyCollection<Guid>> GetScopesAsync(Guid userId, CancellationToken cancellationToken);
}
