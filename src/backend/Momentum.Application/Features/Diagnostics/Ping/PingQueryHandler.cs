using Mediator;

namespace Momentum.Application.Features.Diagnostics.Ping;

/// <summary>
/// Handles <see cref="PingQuery"/>. The server time is read from <see cref="TimeProvider"/>
/// (ADR 0001 K-C5) — never from <c>DateTime.UtcNow</c>, which BannedApiAnalyzers forbids.
/// </summary>
public sealed class PingQueryHandler(TimeProvider timeProvider) : IQueryHandler<PingQuery, PingResponse>
{
    public ValueTask<PingResponse> Handle(PingQuery query, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(query);
        var response = new PingResponse("ok", timeProvider.GetUtcNow());
        return ValueTask.FromResult(response);
    }
}
