using System.Net;
using System.Text;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace Momentum.Api.Tests;

/// <summary>
/// GOREV-slice-3c G1 (DEV-KIMLIK KAPISI) -- DB'siz 401 ayaklari (3/4).
/// 200 ayagi (gercek Postgres gerektirir -- SyncCommandHandler push
/// sonrasi kosulsuz pull yapar) Momentum.Persistence.Tests'tedir (spec G1
/// ayrimi, Testcontainers).
/// </summary>
public class DevKimlikKapisiTestleri
{
    private const string SyncYolu = "/v1/sync";

    // IS-EMRI-o83 D1: Program.cs artik Jwt:Secret eksikse acilista PATLIYOR (bkz. Program.cs) --
    // appsettings.Development.json'da gercek bir demo deger var ama Production-pinli bu testte YOK,
    // bu yuzden test kendi (gercek olmayan, sadece gecerli-Base64) degerini ACIKCA verir.
    private const string TestJwtSecret = "8YFLoBlqtpdfhP9Pk+fypjeAY5YFKsMrycqTHgw3zTI=";

    private static StringContent MinimalIstek(Guid clientId) =>
        new(
            $$"""{"clientId":"{{clientId}}","clientHlc":null,"sinceCursor":null,"ops":[]}""",
            Encoding.UTF8,
            "application/json");

    [Fact]
    public async Task Development_BasliksizIstek_401Doner()
    {
        await using var uygulama = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(b => b.UseEnvironment("Development"));
        using var istemci = uygulama.CreateClient();

        var yanit = await istemci.PostAsync(SyncYolu, MinimalIstek(Guid.NewGuid()));

        Assert.Equal(HttpStatusCode.Unauthorized, yanit.StatusCode);
    }

    [Fact]
    public async Task Development_GuidOlmayanBaslik_401Doner()
    {
        await using var uygulama = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(b => b.UseEnvironment("Development"));
        using var istemci = uygulama.CreateClient();
        istemci.DefaultRequestHeaders.Add("X-Momentum-Dev-User", "abc");

        var yanit = await istemci.PostAsync(SyncYolu, MinimalIstek(Guid.NewGuid()));

        Assert.Equal(HttpStatusCode.Unauthorized, yanit.StatusCode);
    }

    /// <summary>
    /// GOREV kirmizi uyari (G1): WAF varsayilani Development'tir -- pinlenmezse
    /// bu ayak kendiliginden gecer ve kapi korlesir. `UseEnvironment("Production")`
    /// ile ACIKCA pinlenir.
    /// </summary>
    [Fact]
    public async Task Production_GecerliBaslikOlsaBile_401Doner()
    {
        await using var uygulama = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(b =>
            {
                b.UseEnvironment("Production");
                b.UseSetting("Jwt:Secret", TestJwtSecret);
            });
        using var istemci = uygulama.CreateClient();
        istemci.DefaultRequestHeaders.Add("X-Momentum-Dev-User", Guid.NewGuid().ToString());

        var yanit = await istemci.PostAsync(SyncYolu, MinimalIstek(Guid.NewGuid()));

        Assert.Equal(HttpStatusCode.Unauthorized, yanit.StatusCode);
    }
}
