# GÖREV (Claude Code) — slice-1: Backend Omurga + Sağlık Ucu  [v2]

- **Kaynak karar:** `docs/ADR/0001-genel-mimari.md` (KİLİTLİ v3), özellikle **§3 "slice-1'de KODLA"**.
- **Rol:** Sen **build** edersin. `PROJE_HAFIZA.md` ve `docs/ADR/*`'a **DOKUNMA** (Cowork sahibi). Cowork artefaktı Desktop Commander ile bağımsız doğrular.
- **Dil:** Kod/isimler İngilizce; commit mesajı **ASCII** (locale tr-TR/cp1254 non-ASCII commit'i kırar).
- Bu v2, bağımsız spec-denetiminin bulgularını içerir; muğlak bırakılan hiçbir nokta yok — aşağıdaki yerleşim ve test tasarımlarını **birebir** uygula, tahmin etme.

## 0. Önce oku
`CLAUDE.md` + `PROJE_HAFIZA.md` (devir notu) + `docs/ADR/0001-genel-mimari.md` (§2 kararlar, §3 kapsam).

## 1. Kapsam — NE VAR / NE YOK
**VAR:** solution + 4 Clean Arch katmanı + minimal mediator (1 örnek dikey) + API host (OpenAPI/Scalar, /v1) + health (live/ready) + ProblemDetails + TimeProvider DI + `ICurrentUser` arayüzü + Serilog/correlation-id + kalite kapıları (NetArchTest + BannedApiAnalyzers + CVE) + verify script + KANIT.
**YOK (sonraki dilim):** EF Core/DbContext/migration, PostgreSQL, entity, senkron/HLC/Outbox, SignalR, auth mekanizması, owner query-filter. Bu dilim **çalışan DB olmadan** derlenir ve ayağa kalkar.
> `Momentum.Infrastructure` bu dilimde **kasıtlı minimaldir** (katman + arch-kural hedefi). Doldurma.

## 2. Kesin proje/dosya yerleşimi (tahmin etme)
```
Momentum.sln                              (repo kökünde; tüm projeleri içerir)
src/backend/Directory.Build.props         (net9.0; Nullable=enable; ImplicitUsings=enable;
                                           TreatWarningsAsErrors=true; LangVersion=latest;
                                           BannedApiAnalyzers + BannedSymbols.txt SADECE burada)
src/backend/Momentum.Domain/              (ref: yok)
src/backend/Momentum.Application/         (ref: Domain; Mediator.Abstractions + Mediator.SourceGenerator BURADA)
src/backend/Momentum.Infrastructure/      (ref: Application; minimal)
src/backend/Momentum.Api/                 (ref: Application + Infrastructure; composition root)
tests/Directory.Build.props               (net9.0; Nullable=enable; TreatWarningsAsErrors=true;
                                           BannedApiAnalyzers YOK — testler DateTime kullanabilir)
tests/Momentum.ArchitectureTests/         (xUnit + NetArchTest.Rules + Shouldly)
tests/Momentum.Api.Tests/                 (xUnit + Shouldly + WebApplicationFactory<Program>)
araclar/verify.ps1
docs/dependencies.md
KANIT/slice-1/
```
`.gitignore` repo kökünde zaten var — `bin/`,`obj/`,`build/`,`.env` kapsadığını doğrula, eksikse tamamla. `Program`'a test erişimi için `public partial class Program {}` ekle.

## 3. Teslimatlar

**D1 — Solution + katmanlar (K-A1).** Yukarıdaki 4 proje + referans yönleri. İki `Directory.Build.props` (src/backend ve tests) — net9/nullable/warnings-as-errors ikisinde de; **BannedApiAnalyzers yalnız src/backend**.

**D2 — Mediator (K-B1/B1a) — KESİN yerleşim.** `martinothamar/Mediator`, **en son STABİL** (preview değil). `Mediator.Abstractions` + `Mediator.SourceGenerator` → `Momentum.Application`'da. `Momentum.Api` composition root'ta `services.AddMediator(...)` (Application assembly'sini tarayacak şekilde; güncel README'ye göre options). Örnek dikey: `Application/Features/Diagnostics/Ping/PingQuery.cs` → `PingQuery : IQuery<PingResponse>`, `PingResponse(string Status, DateTimeOffset ServerTimeUtc)`; handler `ServerTimeUtc`'yi **`TimeProvider.GetUtcNow()`'dan** alır (TimeProvider DI'ını kanıtlar). Api'de `/v1/ping` bu query'yi mediator ile çağırır. **Kabul:** `/v1/ping` runtime'da 200 döner (cross-assembly handler keşfi çalışıyor); generator tanıları warnings-as-errors altında temiz.

**D3 — API host (K-D1/D4).** Uçlar **adlandırılmış statik sınıflarda**: `Momentum.Api/Endpoints/HealthEndpoints.cs`, `.../DiagnosticsEndpoints.cs` (inline lambda DEĞİL — arch Kural-2 için şart). `Program` yalnız kablolama. İş uçları `/v1` altında; versiyonlama **minimal**: tek `ApiVersionSet` + `/v1` (`Asp.Versioning.Http`); belge-per-version glue'suna girme. OpenAPI JSON: `Microsoft.AspNetCore.OpenApi` (`AddOpenApi` + `MapOpenApi` → `/openapi/v1.json`). UI: `Scalar.AspNetCore` (`MapScalarApiReference`). OpenAPI+Scalar tüm ortamlarda map'li (yalnız-Development yapma; D7 auth yok, sızıntı yok).

**D4 — Health (K-D2) — kendini kırmayan tasarım.** `Microsoft.Extensions.Diagnostics.HealthChecks`. Check'ler **tag**'lenir (`"live"` / `"ready"`).
- `MapHealthChecks("/health/live", new(){ Predicate = r => r.Tags.Contains("live") })` — canlılık, bağımlılık yok → 200.
- `MapHealthChecks("/health/ready", new(){ Predicate = r => r.Tags.Contains("ready") })`.
- **ISIRAN TEST (Api.Tests, WAF):** test-host'ta **`ready` tag'li sahte `Unhealthy` check** kaydet → `/health/ready`→**503**; aynı testte `/health/live`→**200** (live etkilenmez). Ayrıca varsayılan host'ta `/health/ready`→200, `/health/live`→200.

**D5 — Hata modeli (K-D3) — ortam tuzağısız.** `AddProblemDetails()` + `UseExceptionHandler` **tüm ortamlarda** aktif (RFC 9457). Shipped `/v1/_throw` **ekleme**. **TEST:** `Momentum.Api.Tests`'te WAF, ortamı **non-Development'a sabitler** (`UseEnvironment("Production")` → Developer Exception Page kapalı) ve **kendi fırlatan uç**'unu ekler (test-only endpoint) → yanıt **`500 application/problem+json`** (content-type + gövde doğrulanır).

**D6 — TimeProvider (K-C5).** `services.AddSingleton(TimeProvider.System)`. Kodda `DateTime.Now/UtcNow` yok (D11). Ping handler zamanı TimeProvider'dan alır.

**D7 — ICurrentUser portu (K-D5).** `Momentum.Application/Abstractions/ICurrentUser.cs`: `public interface ICurrentUser { Guid? UserId { get; } }`. **Implementasyon YOK**, bu dilimde tüketilmiyor — yalnız sözleşme. **deny-by-default**, bu dilimde YÖN/kod-yorumu olarak gerçeklenir: auth şeması yokken enforce fallback policy host'u kırar; ADR K-D5 "mekanizma sonraki dilim" ile tutarlı — bunu Program'a tek yorum satırı olarak yaz (`// deny-by-default fallback policy -> auth slice`). Health + OpenAPI/Scalar anonim.

**D8 — Loglama (K-G3).** `Serilog.AspNetCore`: yapısal + `UseSerilogRequestLogging` + **correlation-id** (gelen `X-Correlation-Id` yoksa üret; response header'a yansıt; log scope'una ekle). Konsol sink.

**D9 — Mimari testler (K-H1) — ısırabilir kurallar.** `Momentum.ArchitectureTests` (NetArchTest.Rules + Shouldly):
1. `Momentum.Application` tipleri `Momentum.Infrastructure`'a bağımlı OLMAMALI.
2. `Momentum.Api.Endpoints` namespace'indeki tipler Infrastructure **somut** tiplerine bağımlı olmamalı (endpoint'ler adlı sınıfta olduğundan `Program`/composition root doğal olarak kapsam dışı).
3. `Momentum.Domain` → `Microsoft.EntityFrameworkCore` / `Microsoft.AspNetCore` / `Npgsql` namespace'lerine bağımlı olmamalı.
NetArchTest'in .NET 9 assembly'lerini yüklediğini doğrula; çökerse Cowork'e bildir (sessizce kuralı düşürme).

**D10 — Arch kurallarının ISIRDIĞININ KANITI (kör kapı yok) — doğru reçete.** NetArchTest **tip**-bağımlılığına bakar; salt proje-referansı derleyici tarafından elenip testi kırMAYABİLİR. Gerçek tip-bağımlılığı üret: ör. Kural-1 için `Momentum.Infrastructure`'a `public class Probe {}` ekle + `Momentum.Application`'da bir yerde `new Probe()` kullan → `dotnet test` → Test-1 **FAIL** çıktısını `KANIT/slice-1/arch-mutant-rule1.txt`'e kaydet → mutantı geri al. Mümkünse 3 kural için de yakalanmış FAIL kanıtı (her biri: dummy tip + kullan + test + geri al); **en az Kural-1 tam**, diğerleri için reçete+not. "Salt proje-referansı yetmez" uyarısını KANIT'a yaz.

**D11 — BannedApiAnalyzers (K-H1).** `Microsoft.CodeAnalysis.BannedApiAnalyzers` + `BannedSymbols.txt` (yalnız src/backend, Directory.Build.props üzerinden tüm üretim projelerine): `P:System.DateTime.Now`, `P:System.DateTime.UtcNow`, `P:System.DateTimeOffset.Now`, `P:System.DateTimeOffset.UtcNow`, `P:System.DateTime.Today`. warnings-as-errors ile kullanım = **derleme hatası**. KANIT: `KANIT/slice-1/banned-datetime.txt` — bir üretim dosyasına `DateTime.UtcNow` ekleyince build KIRILDI, sonra geri alındı (yakalanmış çıktı).

**D12 — CVE + lisans kapısı (K-H1, red line #3) — GERÇEKTEN ısıran.** `dotnet list package --vulnerable --include-transitive --format json` çıktısını **parse et**; herhangi bir `vulnerabilities` düğümü varsa verify **exit≠0**. (Ham exit koduna güvenme — savunmasızlıkta bile 0 döner.) Ek olarak projelerde `NuGetAudit` açık kalsın (warnings-as-errors ile tamamlayıcı). `docs/dependencies.md`: her paket → ad + sürüm + **lisans (MIT/Apache)** + CVE-durumu.

**D13 — verify (K-H1).** `araclar/verify.ps1`, **repo kökünden `Momentum.sln` hedefiyle** çalışır; sıra: `dotnet build -warnaserror` → `dotnet test` (tüm testler) → D12 CVE-parse. Herhangi biri başarısızsa script **exit≠0**. Tüm çıktı teslim raporuna girer.

## 4. Bağımlılıklar
**İzinli (MIT/Apache):** Mediator (MIT), Shouldly (MIT), Serilog.AspNetCore (Apache), Microsoft.AspNetCore.OpenApi (MIT), Scalar.AspNetCore (MIT), Asp.Versioning.Http (MIT), NetArchTest.Rules (MIT), Microsoft.CodeAnalysis.BannedApiAnalyzers (Apache), xUnit (Apache), Microsoft.AspNetCore.Mvc.Testing (MIT).
**YASAK:** MediatR 13+ · AutoMapper · FluentAssertions 8+ (hepsi ticari). Şüphede ekleme, Cowork'e sor. Her paket için lisans+CVE → `docs/dependencies.md`.

## 5. Kabul kriterleri (verify çıktısıyla kanıtlanır)
1. `dotnet build -warnaserror` → **0 uyarı / 0 hata**.
2. `dotnet test` → hepsi yeşil: 3 arch kuralı + health(ready-503, live-200, ikisi-de-200) + Ping(200) + ProblemDetails(500 problem+json) + **OpenAPI `/openapi/v1.json`→200** + **Scalar route→200**.
3. Host DB'siz ayağa kalkar; yukarıdaki uçlar elle de doğrulanır.
4. `DateTime/DateTimeOffset.UtcNow/Now/Today` üretimde derlemeyi kırar (D11 KANIT).
5. Arch Kural-1 mutantla ısırır (D10 KANIT); mümkünse 3 kural.
6. CVE parse temiz; `docs/dependencies.md` tam.
7. Sır yok; `bin/obj` ignore; iki `Directory.Build.props` uygulanıyor.

## 6. Kırmızı çizgiler
Sır repoya girmez (user-secrets/env) · yalnız MIT/Apache (lisans+CVE kapısı) · kalıcı silme/para/güvenlik YOK · `bin/obj/build` git-ignore · DB/entity/auth bu dilimde YOK.

## 7. Teslim protokolü
1. `araclar/verify.ps1` çalıştır; TÜM çıktıyı rapora koy.
2. Kodu commit et (ASCII), ör: `feat(backend): slice-1 omurga - clean arch + health + kalite kapilari`.
3. **PROJE_HAFIZA.md / docs/ADR'ye DOKUNMA** (Cowork bağımsız doğrulayıp hafızayı güncelleyecek).
4. Raporda ver: (a) build özeti, (b) test sonuç sayıları, (c) verify exit kodu, (d) paketler+sürüm+lisans, (e) KANIT yolları, (f) `/health/live`,`/health/ready`,`/v1/ping`,`/openapi/v1.json` yanıtları, (g) yaptığın her sapma/varsayım.

> Cowork senin beyanına güvenmez; artefaktı kendi derleyip test edecek, arch/banned/CVE kapılarını kendi koşacak. Kanıtları eksiksiz bırak.
