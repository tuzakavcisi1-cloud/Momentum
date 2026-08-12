using System.Net;
using System.Text;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Momentum.Api.Web;
using Xunit;

namespace Momentum.Api.Tests;

/// <summary>
/// D-W3-4 (GOREV-W3 SS3, kilitli karar, o71): CORP (Cross-Origin-Resource-Policy) YALNIZ statik
/// yanitlara yazilir -- /v1/**, /health/**, /hubs/**, /scalar/** CORP GORMEZ. (b)/(c) bir YOKLUK
/// olcer; ORTAM.md'nin findstr dersi geregi AYNI kosumda (a)'nin VARLIK pozitif kontrolu de kosar
/// -- yoksa "hicbiri hicbir yerde CORP yazmiyor" durumu da (b)/(c)'yi yanlislikla GECIRIR.
/// </summary>
public sealed class CorpBasligiTestleri : IDisposable
{
    private const string StatikDosyaAdi = "favicon.png";
    private const string IndexHtmlIcerigi = "<html><body>momentum-corp-test index.html</body></html>";
    private readonly string _kokDizin;

    public CorpBasligiTestleri()
    {
        _kokDizin = Directory.CreateTempSubdirectory("momentum-corp-test-").FullName;
        File.WriteAllBytes(Path.Combine(_kokDizin, StatikDosyaAdi), [1, 2, 3, 4]);
        File.WriteAllText(Path.Combine(_kokDizin, IstemciServisi.VarsayilanBelge), IndexHtmlIcerigi);
    }

    public void Dispose() => Directory.Delete(_kokDizin, recursive: true);

    private WebApplicationFactory<Program> UygulamaOlustur() =>
        new WebApplicationFactory<Program>().WithWebHostBuilder(b =>
        {
            b.UseEnvironment("Development");
            b.ConfigureAppConfiguration((_, cfg) => cfg.AddInMemoryCollection(
                new Dictionary<string, string?> { [IstemciServisi.KokDizinAnahtari] = _kokDizin }));
        });

    private static StringContent SenkronGovdesi(Guid clientId) =>
        new(
            $$"""{"clientId":"{{clientId}}","clientHlc":null,"sinceCursor":null,"ops":[]}""",
            Encoding.UTF8,
            "application/json");

    /// <summary>(a) VARLIK -- statik yanit CORP=same-origin tasir. Pozitif kontrol (ORTAM.md findstr dersi).</summary>
    [Fact]
    public async Task Statik_dosya_CORP_same_origin_tasir()
    {
        await using var uygulama = UygulamaOlustur();
        using var istemci = uygulama.CreateClient();

        var yanit = await istemci.GetAsync("/" + StatikDosyaAdi);

        Assert.Equal(HttpStatusCode.OK, yanit.StatusCode);
        var degerler = Assert.IsAssignableFrom<IEnumerable<string>>(
            yanit.Headers.GetValues(IzolasyonBasliklari.CorpAdi));
        Assert.Equal(IzolasyonBasliklari.CorpDegeri, Assert.Single(degerler));
    }

    /// <summary>(b) YOKLUK -- /health/live CORP tasimaz.</summary>
    [Fact]
    public async Task Health_live_CORP_tasimaz()
    {
        await using var uygulama = UygulamaOlustur();
        using var istemci = uygulama.CreateClient();

        var yanit = await istemci.GetAsync("/health/live");

        Assert.False(yanit.Headers.Contains(IzolasyonBasliklari.CorpAdi));
    }

    /// <summary>(c) YOKLUK -- POST /v1/sync (X-Momentum-Dev-User ile) CORP tasimaz.</summary>
    [Fact]
    public async Task Sync_ucnoktasi_CORP_tasimaz()
    {
        await using var uygulama = UygulamaOlustur();
        using var istemci = uygulama.CreateClient();
        istemci.DefaultRequestHeaders.Add("X-Momentum-Dev-User", Guid.NewGuid().ToString());

        var yanit = await istemci.PostAsync("/v1/sync", SenkronGovdesi(Guid.NewGuid()));

        Assert.False(yanit.Headers.Contains(IzolasyonBasliklari.CorpAdi));
    }

    /// <summary>(d) REGRESYON -- ucunde de COOP=same-origin + COEP=require-corp degismeden durur.</summary>
    [Fact]
    public async Task Statik_yanitta_COOP_ve_COEP_degismez()
    {
        await using var uygulama = UygulamaOlustur();
        using var istemci = uygulama.CreateClient();

        var yanit = await istemci.GetAsync("/" + StatikDosyaAdi);

        DogrulaCoopCoep(yanit);
    }

    [Fact]
    public async Task Health_yanitinda_COOP_ve_COEP_degismez()
    {
        await using var uygulama = UygulamaOlustur();
        using var istemci = uygulama.CreateClient();

        var yanit = await istemci.GetAsync("/health/live");

        DogrulaCoopCoep(yanit);
    }

    [Fact]
    public async Task Sync_yanitinda_COOP_ve_COEP_degismez()
    {
        await using var uygulama = UygulamaOlustur();
        using var istemci = uygulama.CreateClient();
        istemci.DefaultRequestHeaders.Add("X-Momentum-Dev-User", Guid.NewGuid().ToString());

        var yanit = await istemci.PostAsync("/v1/sync", SenkronGovdesi(Guid.NewGuid()));

        DogrulaCoopCoep(yanit);
    }

    /// <summary>
    /// BULGU 1 (o71 ek is) -- IstemciServisi.cs'teki yorum "SPA geri-dususu de statiktir ve CORP
    /// alir; bu BILINCLIDIR" diye IDDIA ediyordu ama hicbir test bunu OLCMUYORDU (beyan != olcum).
    /// /bilinmeyen-rota SpaDisiOnEkler'in HICBIRINE uymaz ve uzantisiz oldugu icin
    /// MapFallbackToFile'in /{*path:nonfile} desenine duser. Bu test MapFallbackToFile'in AYNI
    /// secenekler nesnesindeki OnPrepareResponse'u gercekten CAGIRDIGINI dogrudan olcer --
    /// varsayim degil.
    /// </summary>
    [Fact]
    public async Task SPA_geri_dusus_belgesi_CORP_tasir()
    {
        await using var uygulama = UygulamaOlustur();
        using var istemci = uygulama.CreateClient();

        var yanit = await istemci.GetAsync("/bilinmeyen-rota");

        Assert.Equal(HttpStatusCode.OK, yanit.StatusCode);
        var govde = await yanit.Content.ReadAsStringAsync();
        Assert.Equal(IndexHtmlIcerigi, govde);
        var degerler = Assert.IsAssignableFrom<IEnumerable<string>>(
            yanit.Headers.GetValues(IzolasyonBasliklari.CorpAdi));
        Assert.Equal(IzolasyonBasliklari.CorpDegeri, Assert.Single(degerler));
    }

    private static void DogrulaCoopCoep(HttpResponseMessage yanit)
    {
        Assert.Equal(
            IzolasyonBasliklari.CoopDegeri,
            Assert.Single(yanit.Headers.GetValues(IzolasyonBasliklari.CoopAdi)));
        Assert.Equal(
            IzolasyonBasliklari.CoepDegeri,
            Assert.Single(yanit.Headers.GetValues(IzolasyonBasliklari.CoepAdi)));
    }
}
