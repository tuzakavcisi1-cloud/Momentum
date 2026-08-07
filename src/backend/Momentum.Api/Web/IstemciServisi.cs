using Microsoft.Extensions.FileProviders;

namespace Momentum.Api.Web;

/// <summary>
/// W3 yürüyen iskelet — Flutter web istemcisini <c>Momentum.Api</c> ile <b>AYNI KÖKENDEN</b> sunar.
/// </summary>
/// <remarks>
/// <para>
/// GEREKÇE — <see cref="IzolasyonBasliklari"/> COOP/COEP başlıklarını her yanıta yazar, ama bir
/// belgeyi izole eden şey o belgenin KENDİ yanıt başlıklarıdır. İstemci başka bir kökenden
/// (örn. <c>flutter run -d chrome</c>'un kendi sunucusu) servis edildiği sürece API'nin başlıkları
/// istemci belgesine hiç değmez. Oturum 60'ta ölçüldü ve <c>IzolasyonBasliklari</c> bunu kendi
/// beyan edilmiş sınırı olarak yazdı: <i>"Momentum.Api bugün statik dosya SUNMUYOR ⇒ Flutter web
/// istemcisi başka bir kökenden servis edildiği sürece BU başlıklar istemciyi izole ETMEZ."</i>
/// Bu sınıf o sınırı kapatır.
/// </para>
/// <para>
/// KİLL SWITCH BEDAVA GELİR — kök dizin <see cref="KokDizinAnahtari"/> yapılandırma anahtarından
/// okunur; anahtar boşsa ya da dizin diskte yoksa ara katman <b>hiç kurulmaz</b> ve metot
/// <c>false</c> döner. Yol koda gömülmez (<c>W1/D-W1-1</c> deseni: allow-list koddan değil
/// yapılandırmadan okunur), böylece hem mutant ölçülebilir hem de yanlışlıkla üretimde açık kalma
/// riski dağıtım yapılandırmasıyla yönetilir.
/// </para>
/// <para>
/// BEYAN EDİLMİŞ SINIR — <c>UseStaticFiles</c> uç noktalardan ÖNCE koşar. İstemci kökünde
/// <c>v1</c>, <c>health</c>, <c>hubs</c> ya da <c>scalar</c> ADINDA bir dosya bulunursa o dosya
/// aynı adlı uç noktayı <b>gölgeler</b>. Flutter'ın ürettiği çıktıda böyle bir ad YOKTUR ve bu
/// ölçüldü; ama bunu zorlayan bir kapı bu turda <b>YAZILMADI</b> — ölçüm bir kez koştu, kapı
/// borçtur.
/// </para>
/// <para>
/// BEYAN EDİLMİŞ SINIR — <c>MapFallbackToFile</c> <c>Order = int.MaxValue</c> ile kaydolur
/// (birincil kaynak: <c>FallbackEndpointRouteBuilderExtensions.cs:79</c>, oturum 60'ta doğrulandı)
/// ⇒ EŞLEŞEN hiçbir uç noktayı gölgeleyemez. Buna karşılık desen <c>/{*path:nonfile}</c> olduğu
/// için EŞLEŞMEYEN bir <c>/v1/...</c> yolu artık 404 yerine <c>index.html</c> döndürür; bu davranış
/// ölçüldü ve KANIT'a yazıldı.
/// </para>
/// </remarks>
public static class IstemciServisi
{
    /// <summary>Flutter web build çıktısının kök dizini. Boşsa istemci servisi kurulmaz.</summary>
    public const string KokDizinAnahtari = "Istemci:KokDizin";

    /// <summary>SPA kabuğu; hem varsayılan belge hem geri-düşüş hedefi.</summary>
    public const string VarsayilanBelge = "index.html";

    /// <summary>
    /// SPA geri-düşüşünün DOKUNAMAYACAĞI yol önekleri — eşleşmeyen bir API yolu 404 döner,
    /// <see cref="VarsayilanBelge"/> DÖNMEZ.
    /// </summary>
    /// <remarks>
    /// ÖLÇÜLMÜŞ GEREKÇE (oturum 63): bu liste yokken <c>GET /v1/BULUNMAYAN-UC</c> ölçümde
    /// <b>200 + index.html</b> döndü. <c>MapFallbackToFile</c>'ın <c>/{*path:nonfile}</c> deseni
    /// uzantısız her yolu yakalar; eşleşen uç noktalar korunur ama <b>eşleşmeyen</b> API yolları
    /// SPA kabuğuna düşer. Bir API'nin bilinmeyen uç nokta için HTML döndürmesi kusurdur.
    /// Liste açıkça yazılır ki bayatladığında <b>ölçülebilsin</b>; koda gömülü sessiz bir
    /// yönlendirme kuralından iyidir.
    /// </remarks>
    public static readonly string[] SpaDisiOnEkler = ["/v1", "/health", "/hubs", "/scalar", "/openapi"];

    /// <summary>
    /// İstemciyi aynı kökenden sunar. Kurulduysa <c>true</c>, kurulmadıysa <c>false</c> döner —
    /// dönüş değeri ölçülebilir olsun diye vardır, çağıran onu loglar.
    /// </summary>
    public static bool UseIstemciServisi(this WebApplication app, string? kokDizin)
    {
        ArgumentNullException.ThrowIfNull(app);

        if (string.IsNullOrWhiteSpace(kokDizin))
        {
            return false;
        }

        var tamYol = Path.GetFullPath(kokDizin);
        if (!Directory.Exists(tamYol))
        {
            app.Logger.LogWarning(
                "Istemci kok dizini diskte YOK: {Yol}. Istemci servisi KURULMADI.", tamYol);
            return false;
        }

        var saglayici = new PhysicalFileProvider(tamYol);
        var secenekler = new StaticFileOptions
        {
            FileProvider = saglayici,
            // OLCULMUS GEREKCE (oturum 63): Flutter cikti agacinda UZANTISIZ bir dosya var --
            // assets/NOTICES. Varsayilan ServeUnknownFileTypes=false o dosyayi sunmaz, 404 da
            // vermez: ara katman sessizce GECER ve SPA geri-dususu index.html dondurur (olculdu).
            // Kapsam bilincli olarak DAR: bu secenekler yalnizca istemci kok dizini icin gecerli,
            // API'nin geri kalani bu saglayiciyi hic gormez.
            ServeUnknownFileTypes = true,
            DefaultContentType = "application/octet-stream",
        };

        app.UseDefaultFiles(new DefaultFilesOptions { FileProvider = saglayici });
        app.UseStaticFiles(secenekler);

        // API onekleri SPA kabugunu ASLA gormez -- eslesmeyen API yolu 404'tur (K-D3 geregi
        // ProblemDetails'e donusur). Bu geri-dususler daha OZGUL desen tasidigi icin asagidaki
        // catch-all'dan once eslesir; ikisi de Order=int.MaxValue'dur, karari DESEN OZGULLUGU verir.
        foreach (var onEk in SpaDisiOnEkler)
        {
            app.MapFallback(onEk + "/{*kalan}", () => Results.NotFound());
        }

        app.MapFallbackToFile(VarsayilanBelge, secenekler);

        app.Logger.LogInformation(
            "Istemci AYNI KOKENDEN sunuluyor: {Yol}", tamYol);
        return true;
    }
}
