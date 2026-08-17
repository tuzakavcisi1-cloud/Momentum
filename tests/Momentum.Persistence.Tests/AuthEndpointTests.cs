using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Momentum.Application.Features.Auth;
using Momentum.Application.Features.Sync;
using Shouldly;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// IS-EMRI-o83 D1 -- POST /v1/auth/{register,login,refresh,logout}, uctan uca (gercek Postgres,
/// DevKimlikKapisi200Testleri deseni: WebApplicationFactory + ConnectionStrings:Momentum ile).
///
/// TEK app + TEK veritabani TUM sinif icin paylasilir (<see cref="IAsyncLifetime"/>) -- 12 ayri
/// TestDatabase.CreateAsync cagrisi, sinifin kendi Npgsql havuzu sayisini 12'den 1'e indirir (olculdu:
/// bu dosya olmadan bile suit "too many clients already" ile ARA SIRA dusuyordu -- VisibilityTests.H7b/
/// H8, paylasilan Testcontainer'in max_connections'ina yakin calisiyor; 12 fresh-DB testi bunu daha
/// SIK tetikliyordu). Testler ARASI izolasyon artik veritabani DEGIL, BENZERSIZ e-posta ile saglanir.
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class AuthEndpointTests(PostgresFixture fixture) : IAsyncLifetime
{
    private static readonly Uri TasksUri = new("/v1/tasks", UriKind.Relative);

    private WebApplicationFactory<Program> _app = null!;
    private HttpClient _client = null!;

    public async Task InitializeAsync()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);
        _app = new WebApplicationFactory<Program>().WithWebHostBuilder(b =>
        {
            b.UseEnvironment("Development");
            b.UseSetting("ConnectionStrings:Momentum", connectionString);
        });
        _client = _app.CreateClient();
    }

    public async Task DisposeAsync()
    {
        _client.Dispose();
        await _app.DisposeAsync();
    }

    private static HttpRequestMessage Yetkili(HttpMethod method, Uri uri, string accessToken)
    {
        var request = new HttpRequestMessage(method, uri);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        return request;
    }

    [Fact]
    public async Task Register_yeni_eposta_201_ve_token_cifti_doner()
    {
        var response = await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("a@ornek.test", "sifre1234"));

        response.StatusCode.ShouldBe(HttpStatusCode.Created);
        var body = await response.Content.ReadFromJsonAsync<AuthTokenResponse>();
        body.ShouldNotBeNull();
        body!.AccessToken.ShouldNotBeNullOrWhiteSpace();
        body.RefreshToken.ShouldNotBeNullOrWhiteSpace();
        body.UserId.ShouldNotBe(Guid.Empty);
    }

    [Fact]
    public async Task Register_ayni_normalize_eposta_ikinci_kez_409_doner()
    {
        (await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("Foo@Ornek.test", "sifre1234")))
            .StatusCode.ShouldBe(HttpStatusCode.Created);

        // Buyuk/kucuk harf farkli AMA normalize edilince AYNI eposta -- EmailNormalizer.Normalize
        // (ToLowerInvariant) sayesinde bu da carpismali (culture-invariant, o78 I/i dersi).
        var ikinci = await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("foo@ornek.test", "baskaSifre1"));

        ikinci.StatusCode.ShouldBe(HttpStatusCode.Conflict);
    }

    [Fact]
    public async Task Register_bos_sifre_400_doner()
    {
        var response = await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("kisa@ornek.test", "x"));

        response.StatusCode.ShouldBe(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Login_dogru_sifre_200_ve_token_cifti_doner()
    {
        await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("b@ornek.test", "dogruSifre1"));

        var response = await _client.PostAsJsonAsync("/v1/auth/login", new LoginRequest("b@ornek.test", "dogruSifre1"));

        response.StatusCode.ShouldBe(HttpStatusCode.OK);
        (await response.Content.ReadFromJsonAsync<AuthTokenResponse>())!.AccessToken.ShouldNotBeNullOrWhiteSpace();
    }

    [Fact]
    public async Task Login_yanlis_sifre_401_doner()
    {
        await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("c@ornek.test", "dogruSifre1"));

        var response = await _client.PostAsJsonAsync("/v1/auth/login", new LoginRequest("c@ornek.test", "yanlisSifre"));

        response.StatusCode.ShouldBe(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Login_bilinmeyen_eposta_da_401_doner_varlik_sizdirmaz()
    {
        var response = await _client.PostAsJsonAsync("/v1/auth/login", new LoginRequest("yok@ornek.test", "herhangi1"));

        response.StatusCode.ShouldBe(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Refresh_gecerli_token_ile_YENI_cift_doner_ESKI_token_tekrar_kullanilamaz()
    {
        var kayit = await (await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("d@ornek.test", "sifre12345")))
            .Content.ReadFromJsonAsync<AuthTokenResponse>();

        var yenile1 = await _client.PostAsJsonAsync("/v1/auth/refresh", new RefreshRequest(kayit!.RefreshToken));
        yenile1.StatusCode.ShouldBe(HttpStatusCode.OK);
        var yeniCift = await yenile1.Content.ReadFromJsonAsync<AuthTokenResponse>();
        yeniCift!.RefreshToken.ShouldNotBe(kayit.RefreshToken, "rotation: yeni refresh token ESKISINDEN farkli olmali");

        // ESKI token'i TEKRAR sunmak (calinti/replay senaryosu) artik gecersiz -- rotation onu iptal etti.
        var eskiyiTekrarDene = await _client.PostAsJsonAsync("/v1/auth/refresh", new RefreshRequest(kayit.RefreshToken));
        eskiyiTekrarDene.StatusCode.ShouldBe(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Refresh_bilinmeyen_token_401_doner()
    {
        var response = await _client.PostAsJsonAsync("/v1/auth/refresh", new RefreshRequest("gecersiz-hic-var-olmamis-token"));

        response.StatusCode.ShouldBe(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Logout_token_iptal_eder_sonraki_refresh_denemesi_401_doner()
    {
        var kayit = await (await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("e@ornek.test", "sifre12345")))
            .Content.ReadFromJsonAsync<AuthTokenResponse>();

        (await _client.PostAsJsonAsync("/v1/auth/logout", new LogoutRequest(kayit!.RefreshToken))).StatusCode.ShouldBe(HttpStatusCode.NoContent);

        var refreshDeneme = await _client.PostAsJsonAsync("/v1/auth/refresh", new RefreshRequest(kayit.RefreshToken));
        refreshDeneme.StatusCode.ShouldBe(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Logout_bilinmeyen_token_ile_bile_204_doner_idempotent()
    {
        var response = await _client.PostAsJsonAsync("/v1/auth/logout", new LogoutRequest("hic-var-olmamis"));

        response.StatusCode.ShouldBe(HttpStatusCode.NoContent);
    }

    /// <summary>Kabul olcutu (is emri s3.4.e): "GET /v1/tasks Authorization basligiyla 200, basliksiz 401."</summary>
    [Fact]
    public async Task Tasks_gecerli_Bearer_ile_200_basliksiz_401_doner()
    {
        var kayit = await (await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("f@ornek.test", "sifre12345")))
            .Content.ReadFromJsonAsync<AuthTokenResponse>();

        (await _client.SendAsync(Yetkili(HttpMethod.Get, TasksUri, kayit!.AccessToken))).StatusCode.ShouldBe(HttpStatusCode.OK);
        (await _client.GetAsync(TasksUri)).StatusCode.ShouldBe(HttpStatusCode.Unauthorized);
    }

    /// <summary>
    /// Kabul olcutu (is emri s4): "iki hesap birbirinin gorevini gormuyor" -- gercek JWT ile uctan
    /// uca (canli tur elle de dogrulanir, ama bu otomatik kanit CI'da her turda kosar).
    /// </summary>
    [Fact]
    public async Task Iki_hesap_birbirinin_gorevini_GORMEZ()
    {
        var a = await (await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("g-a@ornek.test", "sifre12345")))
            .Content.ReadFromJsonAsync<AuthTokenResponse>();
        var b = await (await _client.PostAsJsonAsync("/v1/auth/register", new RegisterRequest("g-b@ornek.test", "sifre12345")))
            .Content.ReadFromJsonAsync<AuthTokenResponse>();

        var entity = Guid.NewGuid();
        var opId = Guid.CreateVersion7();
        var syncGovdesi = new SyncRequest(Guid.NewGuid(), null, null,
            [Wire.TaskField(opId, a!.UserId, entity, a.UserId, "title", "A'nin gorevi")]);
        var pushIstegi = Yetkili(HttpMethod.Post, new Uri("/v1/sync", UriKind.Relative), a.AccessToken);
        pushIstegi.Content = JsonContent.Create(syncGovdesi);
        (await _client.SendAsync(pushIstegi)).StatusCode.ShouldBe(HttpStatusCode.OK);

        var aGorur = await _client.SendAsync(Yetkili(HttpMethod.Get, TasksUri, a.AccessToken));
        var bGormez = await _client.SendAsync(Yetkili(HttpMethod.Get, TasksUri, b!.AccessToken));

        (await aGorur.Content.ReadAsStringAsync()).ShouldContain(entity.ToString(), customMessage: "A kendi gorevini GORMELI");
        (await bGormez.Content.ReadAsStringAsync()).ShouldNotContain(entity.ToString(), customMessage: "B, A'nin gorevini GORMEMELI");
    }
}
