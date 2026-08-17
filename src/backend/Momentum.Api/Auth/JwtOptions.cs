namespace Momentum.Api.Auth;

/// <summary>Bound from configuration section "Jwt" (IS-EMRI-o83 D1). <see cref="Secret"/> is Base64 (>=256 bit, HS256 minimum).</summary>
public sealed class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Secret { get; set; } = string.Empty;
    public string Issuer { get; set; } = "Momentum";
    public string Audience { get; set; } = "Momentum";

    // ODEV kilidi (IS-EMRI-o83 s2.1/4): "kisa omurlu erisim JWT'si". 15 dk -- cevrimdisi calisma
    // seansi bunu asar (beklenen), bu yuzden istemci tarafinda 401 -> sessiz yenileme akisi zorunlu
    // (s2.2/10) ve yenileme token'i 30 gun (AuthTokens.RefreshTokenLifetime).
    public int AccessTokenMinutes { get; set; } = 15;
}
