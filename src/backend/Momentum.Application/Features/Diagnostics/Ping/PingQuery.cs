using Mediator;

namespace Momentum.Application.Features.Diagnostics.Ping;

/// <summary>
/// Minimal example vertical (ADR 0001 K-B1, GOREV slice-1 D2): proves cross-assembly
/// handler discovery and the <see cref="TimeProvider"/> DI wiring end-to-end.
/// </summary>
public sealed record PingQuery : IQuery<PingResponse>;

/// <summary>Response for <see cref="PingQuery"/>; <paramref name="ServerTimeUtc"/> comes from <see cref="TimeProvider"/>.</summary>
public sealed record PingResponse(string Status, DateTimeOffset ServerTimeUtc);
