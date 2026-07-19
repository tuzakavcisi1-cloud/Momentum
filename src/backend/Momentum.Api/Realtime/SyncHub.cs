using Microsoft.AspNetCore.SignalR;
using Momentum.Application.Abstractions;
using Momentum.Application.Abstractions.Sync;

namespace Momentum.Api.Realtime;

/// <summary>
/// Payload-less realtime hub (ADR 0002 K2-G1/G2/G3, GOREV slice-2b2 D4/D5). The REAL deny-by-default
/// gate is the <c>/hubs/sync</c> negotiate-401 middleware (Program.cs, D4) -- SignalR's own handshake
/// completes before <see cref="OnConnectedAsync"/> ever runs, so <see cref="HubCallerContext.Abort"/>
/// here is defense-in-depth ONLY, never reported as an independent gate (2b1's GREATEST lesson: only
/// what a mutant can be shown to bite is a "gate").
/// </summary>
public sealed class SyncHub(ICurrentUser currentUser, IScopeMembershipSource membership) : Hub
{
    public override async Task OnConnectedAsync()
    {
        if (currentUser.UserId is { } userId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"user:{userId}", Context.ConnectionAborted);

            // D5: membership is recomputed from the port on EVERY connect -- never cached/replayed from a
            // prior connection, so a since-withdrawn scope is not carried forward (D8-v).
            foreach (var scope in await membership.GetScopesAsync(userId, Context.ConnectionAborted))
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, $"scope:{scope}", Context.ConnectionAborted);
            }
        }
        else
        {
            Context.Abort();
        }

        await base.OnConnectedAsync();
    }
}
