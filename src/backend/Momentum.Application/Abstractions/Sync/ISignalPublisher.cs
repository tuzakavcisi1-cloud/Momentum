using Momentum.Application.Features.Sync;

namespace Momentum.Application.Abstractions.Sync;

/// <summary>
/// Payload-less realtime signal port (ADR 0002 K2-F2/G1, GOREV slice-2b2 D1). The dispatcher never
/// touches SignalR directly; this port hides the transport so the dispatcher can be measured with a
/// deterministic recording fake. A signal carries NO entity content, field name, or aggregateId.
/// </summary>
public interface ISignalPublisher
{
    /// <summary>Publishes every signal; returns only the groups that FAILED (empty = full success).</summary>
    Task<IReadOnlyCollection<PublishFailure>> PublishAsync(
        IReadOnlyCollection<SignalEnvelope> signals, CancellationToken cancellationToken);
}

public sealed record PublishFailure(string Group);
