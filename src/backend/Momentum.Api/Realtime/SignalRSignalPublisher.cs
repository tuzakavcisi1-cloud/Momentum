using Microsoft.AspNetCore.SignalR;
using Momentum.Application.Abstractions.Sync;
using Momentum.Application.Features.Sync;

namespace Momentum.Api.Realtime;

/// <summary>
/// <see cref="ISignalPublisher"/> over SignalR (ADR 0002 K2-G1, GOREV slice-2b2 D1). Binds the port to
/// <see cref="IHubContext{SyncHub}"/> -- Application/Infrastructure never see SignalR types (D9-b). Each
/// group is sent independently so a failure in one group cannot take down the others (D1 kısmi başarı);
/// the ONLY client-facing call is <c>Changed(SignalEnvelope)</c>, which carries no entity content.
/// </summary>
public sealed class SignalRSignalPublisher(IHubContext<SyncHub> hub) : ISignalPublisher
{
    public async Task<IReadOnlyCollection<PublishFailure>> PublishAsync(
        IReadOnlyCollection<SignalEnvelope> signals, CancellationToken cancellationToken)
    {
        var failures = new List<PublishFailure>();
        foreach (var signal in signals)
        {
            try
            {
                await hub.Clients.Group(signal.Group).SendAsync("Changed", signal, cancellationToken);
            }
            catch (Exception)
            {
                failures.Add(new PublishFailure(signal.Group));
            }
        }

        return failures;
    }
}
