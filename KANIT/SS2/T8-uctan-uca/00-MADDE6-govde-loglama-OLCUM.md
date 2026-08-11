# MADDE 6 ÖLÇÜMÜ — /v1/sync istek gövdesi backend logunda görünüyor mu?

**Tarih (cihazdan ölçüldü):** 2026-08-11 13:47:49 (+03, `Get-Date -Format 'yyyy-MM-dd HH:mm:ss'`)
**El:** Claude Code (yalnız OKUMA — ürün koduna hiçbir bayt yazılmadı)
**Kapsam:** `KANIT/SS2/09-DENETIM-TUR2…md` §2 madde 6/7 — koşum öncesi ölçülmesi
zorunlu kılınan tek madde ("ÖNCE MADDE 6'YI ÖLÇ — tek başına, her şeyden önce").

---

## SORU

`Program.cs` ve `appsettings*.json`'da `/v1/sync` isteklerinin **gövdesi**
(`clientId`, HLC) backend logunda görünüyor mu? Varsayılan ASP.NET Core
logu gövdeyi yazmaz — bu **varsayımın kendisi** ölçülüyor.

## ÖLÇÜM 1 — `Program.cs`'in Serilog kurulumu (satır 28-32, birebir)

```csharp
builder.Host.UseSerilog((_, configuration) => configuration
    .MinimumLevel.Information()
    .Enrich.FromLogContext()
    .WriteTo.Console());
```

🔴 **Lambda'nın ilk parametresi (`HostBuilderContext`, `IConfiguration`'a
erişimi olan taraf) `_` ile ATILIYOR** — yani bu kurulum `appsettings.json`'un
`"Logging"` bölümünü **HİÇ okumuyor**. Pipeline tamamen **kod-sabitli**:
`MinimumLevel.Information()` + `Enrich.FromLogContext()` + konsola yaz.
**Gövde zenginleştirmesi (`Enrich.With...`) YOK.**

## ÖLÇÜM 2 — `app.UseSerilogRequestLogging()` (satır 162, argümansız)

```csharp
app.UseSerilogRequestLogging();
```

Argümansız çağrı ⇒ Serilog.AspNetCore'un **varsayılan** şablonu: HTTP metodu +
yol + durum kodu + geçen süre. `options.EnrichDiagnosticContext` **callback'i
TANIMLANMAMIŞ** — bu, gövdeyi (ya da herhangi bir özel alanı) log olayına
eklemenin standart yoludur ve burada **yok**.

## ÖLÇÜM 3 — istek işleme zincirinde (endpoint → handler → pipeline) HERHANGİ
BİR loglama çağrısı var mı

```
grep -rn "Log\.|_logger\.|ILogger|LogInformation|LogDebug|UseSerilogRequestLogging|EnrichDiagnosticContext" src/backend
  ⇒ 3 dosya: Program.cs · Web/IstemciServisi.cs · Infrastructure/Sync/OutboxDispatcher.cs
    (üçü de /v1/sync GÖVDESİYLE İLGİSİZ: statik dosya servisi + outbox dispatch logu)

grep -rn "LogContext|PushProperty" src/backend
  ⇒ yalnız Program.cs:156 (CorrelationId push'u — gövdeyle ilgisiz)

Şu üç dosyanın İÇİNDE ayrıca arandı (Console./Debug.Write/Trace.Write/Serilog/logger/Logger):
  Momentum.Application/Features/Sync/SyncCommandHandler.cs  ⇒ 0 eşleşme
  Momentum.Api/Endpoints/SyncEndpoints.cs                   ⇒ 0 eşleşme
  Momentum.Application/Behaviors/TransactionBehavior.cs     ⇒ 0 eşleşme
```

⇒ `/v1/sync` isteğini karşılayan **HİÇBİR** kod yolunda (endpoint, handler,
transaction pipeline) açık bir loglama çağrısı **YOK**.

## ÖLÇÜM 4 — appsettings*.json (tam içerik, ikisi de)

`appsettings.json`:
```json
{
  "Logging": { "LogLevel": { "Default": "Information", "Microsoft.AspNetCore": "Warning" } },
  "AllowedHosts": "*",
  "Istemci": { "KokDizin": "wwwroot" }
}
```
`appsettings.Development.json`:
```json
{ "Cors": { "AllowedOrigins": ["http://localhost:5000"] } }
```
🔴 **`"Logging"` anahtarı Ölçüm 1'in gösterdiği sebeple ETKİSİZDİR** — Serilog
`appsettings`'i hiç okumuyor; bu anahtar yalnız `UseSerilog` tarafından
**değiştirilmiş** `Microsoft.Extensions.Logging` sağlayıcılarına uygulanırdı,
ama o sağlayıcılar Serilog ile **tamamen ikame edilmiştir**.

---

## HÜKÜM (ölçüldü, yorum değil)

🔴 **`/v1/sync` isteğinin gövdesi (`clientId`, HLC dâhil) backend logunda
GÖRÜNMÜYOR.** Ne varsayılan `UseSerilogRequestLogging()` şablonu ne de
istek işleme zincirindeki herhangi bir kod bunu yazıyor.

## YAPILANDIRMAYLA YÜKSELTİLEBİLİR Mİ (`Logging__LogLevel__*` vb.)?

**HAYIR — ölçüldü.** Serilog'un `MinimumLevel`'i `Program.cs`'te **kod-sabitli**
(`.MinimumLevel.Information()`) ve `appsettings`/ortam değişkeni **hiç
okunmuyor** (Ölçüm 1). `Logging:LogLevel:*` anahtarını (ortam değişkeniyle ya
da `appsettings` ile) değiştirmek Serilog'un davranışını **etkilemez** —
etkilediği sağlayıcılar zaten devre dışı. `UseSerilogRequestLogging()`'in
gövde-zenginleştirme callback'i de **kod içinde** tanımlanır, yapılandırma
anahtarı DEĞİLDİR (Serilog.AspNetCore API'sinin kendisi böyle tasarlanmıştır).

⇒ **Gövdeyi görünür kılmanın TEK yolu `Program.cs`'e kod eklemektir**
(`EnrichDiagnosticContext` callback'i ya da bir loglama satırı) — bu **ÜRÜN
KODU DEĞİŞİKLİĞİDİR** ve iş emri §7 + §1 madde 6 gereği **YASAKTIR**.

---

## 🔴 DURULDU — ONUR'A DÖNÜLÜYOR

İş emrinin kendi kilidi (§1 Ö8, birebir): *"LOGLANMIYORSA: DUR, ÜRÜN KODUNA
DOKUNMA, Onur'a dön ve söyle. Onur'un 'iç durum backend logundan okunur'
kilidi o zaman ölçümle düşer."*

**Bu ölçüm o kilidi düşürüyor.** Kalan 18 madde koşulmadı (madde 6 geçmeden
koşum başlamaz — iş emri §1 başlığı: *"Herhangi biri sağlanmazsa: DURULUR,
ham çıktı yazılır, ONUR'A DÖNÜLÜR. Sessizce ikinci bir yola geçilmez."*).

**Onur'un önündeki üç şık** (iş emrinin kendi listesi, Ö8 satırı):
1. Backend logunu gövdeyi yazacak şekilde **genişlet** — bu bir **ürün kodu
   değişikliğidir**, ayrı bir turda (`§7` kilidi gereği bu turda YAPILMAZ).
2. İç durumu **cihaz sqlite'ından** oku — istemci tarafı, ayrı bir ölçüm yolu.
3. Uygulamaya **hata-ayıklama çıktısı** ekle — bu da **ürün kodu değişikliğidir**.

Üçü de bu turun kapsamı **dışındadır** (§7: *"ÜRÜN KODUNA TEK BAYT
YAZILMAZ… kod değişikliği zorunlu hâle gelirse DURULUR ve ONUR'A DÖNÜLÜR"*).

**Ürün koduna hiçbir bayt yazılmadı.** `git status --porcelain -- src` bu
belgenin yazıldığı an itibarıyla **temiz** olmalıdır (aşağıda ayrıca ölçülür).
