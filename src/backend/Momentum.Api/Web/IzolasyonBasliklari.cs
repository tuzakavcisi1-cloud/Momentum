namespace Momentum.Api.Web;

/// <summary>
/// W3 yürüyen iskelet — çapraz-köken izolasyon başlıkları (COOP + COEP).
/// </summary>
/// <remarks>
/// <para>
/// Bir tarayıcı bağlamının <c>crossOriginIsolated</c> olması (ve dolayısıyla
/// <c>SharedArrayBuffer</c>'ın gerçekten kullanılabilir olması) YALNIZ yanıt başlıklarından türer.
/// Oturum 60 denetiminde ölçüldü: <c>--enable-features=SharedArrayBuffer</c> /
/// <c>--enable-blink-features=SharedArrayBuffer</c> bayrakları yalnız YAPICIYI geri getirir
/// (<c>false | function</c>), izolasyon VERMEZ. Bu yüzden mekanizma ürün kodunda yaşar, bayrakta değil.
/// </para>
/// <para>
/// 🔴 ÖLÜ BEYAN DÜZELTMESİ (o71) — bu paragraf önceden <i>"CORP bu iskelette YOKTUR … Ölçülmeden
/// yazılmaz"</i> diyordu; <c>D-W3-4</c> kilidiyle (<c>GOREV-W3</c> §3) artık YANLIŞ. <c>Cross-Origin-
/// Resource-Policy</c> (CORP) ARTIK VAR ama BU ARA KATMANDA DEĞİL: yalnız statik yanıtlara —
/// <see cref="IstemciServisi"/>'nin <c>StaticFileOptions.OnPrepareResponse</c>'unda — eklenir.
/// <c>/v1/**</c>, <c>/health/**</c>, <c>/hubs/**</c>, <c>/scalar/**</c> CORP YAZMAZ; bu sınıf
/// yalnız <see cref="CorpAdi"/>/<see cref="CorpDegeri"/> sabitlerini barındırır, başlığı KENDİSİ
/// yazmaz — <see cref="UseIzolasyonBasliklari"/> hâlâ yalnız COOP+COEP ekler.
/// </para>
/// <para>
/// BEYAN EDİLMİŞ SINIR — bu ara katman kendi köken(ler)inde SUNULAN belgeleri izole eder.
/// Momentum.Api bugün statik dosya SUNMUYOR (<c>UseStaticFiles</c>/<c>UseDefaultFiles</c>/
/// <c>wwwroot</c> = 0, oturum 60'ta ölçüldü) ⇒ Flutter web istemcisi başka bir kökenden servis
/// edildiği sürece BU başlıklar istemciyi izole ETMEZ. İstemcinin izolasyonu ayrı bir karardır.
/// </para>
/// </remarks>
public static class IzolasyonBasliklari
{
    /// <summary>Yapılandırma anahtarı; yoksa varsayılan <c>true</c>.</summary>
    public const string EtkinAnahtari = "Izolasyon:Etkin";

    public const string CoopAdi = "Cross-Origin-Opener-Policy";
    public const string CoepAdi = "Cross-Origin-Embedder-Policy";

    public const string CoopDegeri = "same-origin";
    public const string CoepDegeri = "require-corp";

    /// <summary>
    /// <c>D-W3-4</c> (<c>GOREV-W3</c> §3, kilitli karar, o71) — bu başlık BURADA YAZILMAZ; yalnız
    /// <see cref="IstemciServisi"/>'nin statik yanıtlarında kullanılır (<c>/v1/**</c>, <c>/health/**</c>,
    /// <c>/hubs/**</c>, <c>/scalar/**</c> CORP GÖRMEZ).
    /// </summary>
    public const string CorpAdi = "Cross-Origin-Resource-Policy";

    /// <summary>Bkz. <see cref="CorpAdi"/>.</summary>
    public const string CorpDegeri = "same-origin";

    /// <summary>
    /// COOP/COEP başlıklarını HER yanıta ekler. <paramref name="etkin"/> false ise ara katman
    /// hiç kurulmaz — kill switch'in kendisi ölçülebilir bir mutanttır.
    /// </summary>
    /// <remarks>
    /// Başlıklar <c>OnStarting</c> ile yazılır, doğrudan değil: <c>UseExceptionHandler</c> hata
    /// yolunda yanıtı temizleyip yeniden çalıştırabilir; doğrudan yazılan başlık o yolda SESSİZCE
    /// DÜŞER. <c>OnStarting</c> gövde diske inmeden hemen önce koşar ⇒ hata yanıtı da izole kalır.
    /// </remarks>
    public static IApplicationBuilder UseIzolasyonBasliklari(this IApplicationBuilder app, bool etkin)
    {
        ArgumentNullException.ThrowIfNull(app);

        if (!etkin)
        {
            return app;
        }

        return app.Use(async (context, next) =>
        {
            context.Response.OnStarting(static state =>
            {
                var yanit = ((HttpContext)state).Response;
                yanit.Headers[CoopAdi] = CoopDegeri;
                yanit.Headers[CoepAdi] = CoepDegeri;
                return Task.CompletedTask;
            }, context);

            await next(context);
        });
    }
}
