using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;

namespace Momentum.Api.Tests;

/// <summary>
/// Test-only startup filter (GOREV slice-1 D5): the shipped app must NOT contain a throwing
/// endpoint, so the ProblemDetails test injects one here. The middleware is appended AFTER the
/// application's own pipeline, hence DOWNSTREAM of <c>UseExceptionHandler</c>, so a throw on
/// <see cref="Path"/> is converted to <c>application/problem+json</c> (RFC 9457).
/// </summary>
internal sealed class ThrowingEndpointStartupFilter : IStartupFilter
{
    public const string Path = "/__test/throw";

    public Action<IApplicationBuilder> Configure(Action<IApplicationBuilder> next) =>
        app =>
        {
            next(app);
            app.Use(async (context, nextMiddleware) =>
            {
                if (context.Request.Path.Equals(Path, StringComparison.Ordinal))
                {
                    throw new InvalidOperationException(
                        "Deliberate failure to exercise the ProblemDetails pipeline (test-only).");
                }

                await nextMiddleware(context);
            });
        };
}
