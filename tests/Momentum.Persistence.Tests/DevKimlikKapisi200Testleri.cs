using System.Net;
using System.Text;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace Momentum.Persistence.Tests;

/// <summary>
/// GOREV-slice-3c G1 (DEV-KIMLIK KAPISI) -- 200 ayagi (4/4). `SyncCommandHandler`
/// push sonrasi kosulsuz pull yaptigi icin gercek PostgreSQL sarttir (spec
/// gerekce); bu yuzden Momentum.Api.Tests'ten AYRI, Testcontainers'li projede.
/// Paylasilan <see cref="PostgresFixture"/>/<see cref="TestDatabase"/> (bkz.
/// TestSupport.cs) kullanilir -- baglanti dizesi `UseSetting` ile, Program.cs'in
/// `builder.Build()` ONCESI eager okudugu `ConnectionStrings:Momentum` degerine
/// yazilir (EndpointTests.cs'teki "Ready_is_200..." testiyle AYNI kalip).
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class DevKimlikKapisi200Testleri(PostgresFixture fixture)
{
    [Fact]
    public async Task Development_GecerliBaslik_200DonerVeAppliedIcerir()
    {
        var connectionString = await TestDatabase.CreateAsync(fixture);

        await using var uygulama = new WebApplicationFactory<Program>().WithWebHostBuilder(b =>
        {
            b.UseEnvironment("Development");
            b.UseSetting("ConnectionStrings:Momentum", connectionString);
        });
        using var istemci = uygulama.CreateClient();
        istemci.DefaultRequestHeaders.Add("X-Momentum-Dev-User", Guid.NewGuid().ToString());

        var govde = new StringContent(
            $$"""{"clientId":"{{Guid.NewGuid()}}","clientHlc":null,"sinceCursor":null,"ops":[]}""",
            Encoding.UTF8,
            "application/json"
        );

        var yanit = await istemci.PostAsync("/v1/sync", govde);
        var yanitGovdesi = await yanit.Content.ReadAsStringAsync();

        Assert.True(
            yanit.StatusCode == HttpStatusCode.OK,
            $"beklenen 200, gelen {yanit.StatusCode}: {yanitGovdesi}"
        );
        Assert.Contains("\"applied\"", yanitGovdesi);
    }
}
