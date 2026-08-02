# .NET 10 ADIM 6 — ÖLÇÜM ÖZETİ (oturum 48, 2 Ağu 2026)

**Koşan el:** Cowork. **Yöntem:** spec YAZILMADAN önce koşan deney (K53/2 — *"ölçülemeyen sınıfın
cevabı DEVRET'tir"*). Her aşama `araclar\verify.ps1` ile ölçüldü; ham loglar bu dizinde.

**Ortam (ölçüldü, beyan edilmedi):** `momentum-postgres` Up (healthy, 3 yoklamada) ·
SDK'lar: `9.0.316` + `10.0.302` · Windows / PowerShell.

## Aşama tablosu

| # | değişiklik | sonuç | kanıt |
|---|---|---|---|
| BAZ | yok (net9.0, SDK 9.0.316) | ✅ VERIFY PASSED · build 0/0 · test **120/120** · CVE 0 | `01-BAZ-net9-verify.txt` |
| A1 | `global.json` → 10.0.302, TF **net9.0 kaldı** | 🔴 **BUILD KIRIK** — `CS0023` ×2 (`OrSetProperties.cs` 35, 86) | `02-A1-...-KIRIK.log` |
| A2 | TF → **net10.0**, paketler 9.x | ✅ build 0 uyarı / 0 hata | `03-A2-...-build.log` |
| A3 | (A2 üstüne) tam verify | ✅ **PASSED** · test **120/120** · CVE 0 | `04-A3-...-GECTI.log` |
| A4 | paketler naif *"en güncel"* 10.x | 🔴 **CVE KAPISI ISIRDI** — `Microsoft.OpenApi 2.0.0`, GHSA-v5pm-xwqc-g5wc (High, CVSS 7.5) | `05-A4-...-ISIRDI.log` |
| A5 | `Microsoft.OpenApi 2.11.0` pini | 🔴 `MSB3277` — EFCore.Relational **10.0.4 ↔ 10.0.10** çakışması | `06-A5-...-CAKISMASI.log` |
| A6 | EFCore + Design → **10.0.4** (Npgsql 10.0.3 zinciriyle hizalandı) | ✅ **PASSED** · build 0/0 · test **120/120** · CVE 0 | `07-A6-...-GECTI.log` |

## Üç ölçülmüş bulgu

**1 — GEÇİŞ ATOMİK OLMAK ZORUNDA.** SDK'yı tek başına yükseltmek depoyu kırıyor. Kök neden
**izole mutantla kanıtlandı** (Momentum deposuna dokunulmadan, `C:\dev\_o48_mutant`):

| kombinasyon | sonuç |
|---|---|
| `net9.0` + `LangVersion=latest` (C# 14, SDK 10) | 🔴 `CS0023` |
| `net9.0` + `LangVersion=13` | ✅ derlendi |
| `net10.0` + `LangVersion=latest` | ✅ derlendi |

⇒ Suçlu SDK değil, **C# 14 dili + net9 referans kümesi** kombinasyonu: C# 14'te yeni span
dönüşümleri `dizi.Reverse()` çağrısını `MemoryExtensions.Reverse<T>(Span<T>)` (**void**) aşırı
yüklemesine bağlıyor; `net10.0` hedefinde `Enumerable.Reverse<T>(T[])` aşırı yüklemesi bulunduğu
için doğru bağlanma geri geliyor. `Directory.Build.props` **`LangVersion=latest`** taşıdığı için
bu depo bu sınıfa açıktır. Mutant betiği + çıktısı: `08-MUTANT-reverse-*`. İki bağımsız koşum,
aynı sonuç (deterministik).
Kaynak: C# 14 aşırı yükleme çözümü kırıcı değişikliği (learn.microsoft.com/dotnet/core/compatibility/core-libraries/10.0/csharp-overload-resolution) · dotnet/roslyn#80259 · dotnet/runtime#107723.

**2 — *"En güncel sürüme çık"* NAİF KURALI İKİ KEZ KIRILDI.** ① `Microsoft.AspNetCore.OpenApi 10.0.10`
transitif olarak **savunmasız** `Microsoft.OpenApi 2.0.0` getiriyor (ilk yamalı sürüm **2.7.5**);
② `Microsoft.EntityFrameworkCore 10.0.10`, `Npgsql.EntityFrameworkCore.PostgreSQL 10.0.3`'ün
beklediği **10.0.4** Relational ile çakışıyor. Doğru kural: **sağlayıcı zinciriyle hizala, CVE'yi ölç.**

**3 — DURUM.md'nin *"en ciddi risk"* dediği MEDIATOR HİÇ ISIRMADI.** `Mediator.SourceGenerator 3.0.2`
(netstandard2.0) net10.0'da sorunsuz üretti; kâğıtta *"kararlı .NET 10 sürümü yok"* diye yazılan
risk **ölçümle çürüdü**. Gerçek engel hiç tahmin edilmemiş yerdeydi (CVE + sağlayıcı hizalaması).
K53'ün doğuş gerekçesinin tekrarı: *prozada aranan kusuru koşan betik ilk koşumda buldu.*

## Beyan edilmiş sınırlar (gizlenmedi)

- **Kapsam dışı bırakılan paketler:** `Asp.Versioning.Http` 8.1.1 (→10.0.1, iki majör atlama),
  `Scalar.AspNetCore` 2.16.15 (→2.16.17, .NET sürümüyle ilgisiz), `xunit` 2.9.2 / `Microsoft.NET.Test.Sdk`
  17.12.0 / `xunit.runner.visualstudio` 2.8.2 (test altyapısı majör atlaması). Bunlar **ayrı bir iştir**
  ve bu deneyde ölçülmedi.
- **`Microsoft.OpenApi 2.11.0` bir CVE PİNİDİR**, mimari karar değil. Yukarı akış güvenli bir transitif
  sürüme geçtiğinde satır **silinir**; ölçüm: `dotnet nuget why Momentum.sln Microsoft.OpenApi`.
- **ADR 0001 K-H1 hâlâ `net9.0` diyor** (satır 79; ayrıca satır 15 ve K-D1/satır 60). Kod ile ADR
  arasında **açık tutarsızlık** vardır ve bu bir **borçtur** — kilit Onur'dadır.
- **`verify.ps1` YAN ETKİSİ ÖLÇÜLDÜ:** `MOMENTUM_KANIT_DIZIN` varsayılanı `KANIT\slice-3d\07-G7-backend-zorlama`
  olduğu için her koşum `outbox-sorgu.txt` kanıtını **yeniden yazıyor** (bu turda `git restore` ile geri alındı).
  Kanıt bütünlüğü açısından borç: bir regresyon kapısı, geçmiş bir kanıtın üzerine yazmamalıdır.
- Bu ölçüm **tek makinede** yapıldı; CI'da .NET 10 kurulumu **[DOĞRULANMADI]**.
