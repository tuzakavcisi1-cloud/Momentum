using System.Text;
using System.Text.Json;
using Momentum.Application.Abstractions.Sync;

namespace Momentum.Application.Features.Tasks;

/// <summary>
/// GOREV slice-3a D4: opaque base64url JSON cursor, <c>{"v":1,"p":string|null,"i":uuid}</c>. Callers
/// MUST treat a decode failure (malformed / unrecognized version) as a client error (400 ProblemDetails),
/// never a 500 -- <see cref="TryDecode"/> returns <c>false</c> instead of throwing.
/// </summary>
public static class TaskCursorCodec
{
    private sealed record CursorPayload(int V, string? P, Guid I);

    public static string Encode(TaskKeysetCursor cursor)
    {
        ArgumentNullException.ThrowIfNull(cursor);
        var json = JsonSerializer.Serialize(new CursorPayload(1, cursor.Pos, cursor.EntityId));
        return Base64UrlEncode(Encoding.UTF8.GetBytes(json));
    }

    /// <summary>
    /// <paramref name="encoded"/> == <c>null</c> decodes to <c>cursor = null</c> (no cursor, legal first
    /// page) and returns <c>true</c>. A non-null but malformed/unrecognized-version string returns <c>false</c>.
    /// </summary>
    public static bool TryDecode(string? encoded, out TaskKeysetCursor? cursor)
    {
        cursor = null;
        if (encoded is null)
        {
            return true;
        }

        try
        {
            var payload = JsonSerializer.Deserialize<CursorPayload>(Base64UrlDecode(encoded));
            if (payload is not { V: 1 })
            {
                return false;
            }

            cursor = new TaskKeysetCursor(payload.P, payload.I);
            return true;
        }
        catch (Exception ex) when (ex is FormatException or JsonException)
        {
            return false;
        }
    }

    private static string Base64UrlEncode(byte[] bytes) =>
        Convert.ToBase64String(bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');

    private static byte[] Base64UrlDecode(string value)
    {
        var padded = value.Replace('-', '+').Replace('_', '/');
        padded += (padded.Length % 4) switch { 2 => "==", 3 => "=", _ => string.Empty };
        return Convert.FromBase64String(padded);
    }
}
