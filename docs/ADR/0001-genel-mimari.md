# ADR 0001 — Genel Mimari (Backend Omurga)

- **Durum:** ✅ **KİLİTLİ (v3)** — engineering (architecture + system-design) **ve** red-team kapıları geçti; bulgular işlendi. K-B1a, Onur tarafından Cowork'e devredildi → araştırmayla karara bağlandı (martinothamar/Mediator, MIT). Değişiklik ancak yeni ADR ile.
- **Tarih:** 2026-07-18
- **Karar verenler:** Onur (sahip) · Cowork (mimar) · bağımsız denetçi ajanlar (architecture, system-design, red-team)
- **Kapsam:** Backend mimari iskeleti **+ senkron/işbirliğini taşıyan yapısal kontratların ŞEKLİ/YÖNÜ**. Protokol **mekaniği → ADR 0002**. İskelette **hangi kararın şimdi kodlandığı** §3 tablosunda nettir.
- **İlk dikey dilim (slice-1):** solution + Clean Architecture katmanları + sağlık ucu. DB ertelendi → iskelet **canlı DB olmadan** derlenip çalışır.

> **Denetim izi:** v1→v2 engineering bulgularıyla (taşıyıcı kontratlar 0001'e alındı; FluentAssertions/AutoMapper lisans tuzakları); v2→v3 red-team bulgularıyla (DateTime kapısı→BannedApiAnalyzers, CVE kapısı, EF çift-filtre çakışması, outbox atomikliği, alıcı-yetki, ve **şimdi-kodla vs yön-notu** ayrımı) düzeltildi.

---

## 1. Bağlam

Momentum; offline-first senkron + gerçek zamanlı işbirliği vitrinli, çok platformlu görev yönetimi uygulaması. Bu ADR backend'in .NET 9 tarafını kapsar. İşe-alım/portfolyo ödevi; birincil eksen **mimari & kod kalitesi**. Strateji **OMURGA-ÖNCE / DİKEY-DİLİM**. **Ortam:** PostgreSQL bu dilimde ertelendi (Docker/WSL2 sonra) → iskelet çalışan DB olmadan derlenip sağlık ucuyla ayağa kalkar. Mac yok → iOS yalnız CI'da derlenir.

---

## 2. Kararlar

### A. Katmanlar & bağımlılık
**K-A1 — Clean Architecture, 4 proje, katı bağımlılık kuralı.**

| Proje | Sorumluluk | Bağımlılık |
|---|---|---|
| `Momentum.Domain` | Entity, value object, domain event, iş kuralı; saf | **Hiçbir şey** |
| `Momentum.Application` | CQRS handler, port arayüzleri, DTO, doğrulama, iş akışı | → Domain |
| `Momentum.Infrastructure` | EF Core/Npgsql, dış servisler; Application portlarını uygular | → Application |
| `Momentum.Api` | ASP.NET Core; endpoint, DI composition root, middleware, health | → Application + Infrastructure (yalnız kablolama) |

Oklar yalnız içe. Infrastructure, Application **arayüzlerini** uygular (DIP); somut altyapı yalnız `Api` composition root'ta bağlanır. **Kural makineyle zorlanır (K-H1).**

### B. CQRS/Mediator
**K-B1 — CQRS + Mediator + Application içinde feature-folder.** Tek-model command/query segregasyonu (ayrı read-store yok → purist "CQRS" değil, topluluk-standart ayrım). Kesişen ilgiler pipeline behavior ile. `Application/Features/Tasks/CreateTask/…`.

**K-B1a — Mediator kütüphanesi + lisans [KIRMIZI ÇİZGİ #3 — ✅ KARAR: martinothamar/Mediator (MIT)].**
- **MediatR 13.0+ (Tem 2025):** dual RPL-1.5/ticari (Lucky Penny); <5M$ "Community" ücretsiz ama lisans-anahtarı + uyarı **logları** + reciprocal şart → portfolyoda gürültü, **elendi**.
- **MediatR 12.x:** Apache-2.0, ücretsiz ama sürüm donmuş → **yedek**.
- **Cortex.Mediator / LiteBus:** MIT ve DDD/CQS-dostu ama daha yeni/az benimsenmiş → altyapı "sıkıcı-güvenilir" olsun, mimari yıldız kalsın diye **elendi**.

**Karar (Onur devri → araştırmayla):** **martinothamar/Mediator (MIT)**, en son **stabil** sürüme sabit (preview değil). Gerekçe: en çok benimsenen MIT alternatifi; MediatR-benzeri API (denetçi-dostu, düşük sürtünme) **+ açık `ICommand`/`IQuery`/`INotification` işaret arayüzleri** (K-G1 komut-only transaction kapsamı için tam gerekli); source-gen + ValueTask + **Native AOT** (modern performans vitrini); derleme-zamanı tanı (eksik handler = uyarı → "runtime'da değil derlemede patlat" etiğine uyar). Bedel: tek-bakımcı bus-factor → CQRS soyutlaması geçişi sınırlar; **yedek MediatR 12.x (Apache)**. Paket eklenirken lisans+CVE teyidi (K-H1).

### C. Taşıyıcı veri kontratları — **ŞEKİL/YÖN 0001, temsil+mekanik 0002, kodlama zamanı §3'te**
**K-C1 — Entity temel tipi (senkronlanabilir kök).**
- **Id:** UUIDv7 — `Guid.CreateVersion7()` (K-E1). *[ilk entity diliminde kodlanır]*
- **Zaman damgaları:** `createdAt`,`updatedAt` — yalnız `TimeProvider`'dan (K-C5). *[ilk entity diliminde]*
- **Soft-delete/tombstone:** hard-delete **yok** (red line #4); `isDeleted`+`deletedAt`+**HLC-damgalı tombstone**. *[ilk entity diliminde]*
- **Sahiplik:** `ownerId` çıpası. *[ilk entity diliminde]*
- **Alan-düzeyi değişim metadatası:** alan-düzeyi çözüm (K-I1) entity-düzeyi tek versiyonla **yapılamaz**; ancak somut temsil (per-field HLC haritası vs op-log'un `alan+HLC` taşıması) **0002'ye ait** → **iskelette KODLANMAZ**, yön olarak sabit: "EntityBase alan-düzeyi metadatayı taşıyacak şekilde 0002'de genişletilir; satır-etag yetersizdir."

**K-C2 — Komut/operasyon zarfı (idempotency kontratı).** Her yazma komutu entity-ID'den ayrı, istemci-üretimli **`operationId`** + istemci HLC taşır (aynı entity'ye iki update ayrı operasyon). Dedup mekaniği 0002; **zarf alanı** yön olarak sabit. *[ilk komut diliminde kodlanır]*

**K-C3 — Kanonik integration-event zarfı şekli.** Domain event (in-process) ≠ integration event (sınır aşan). Kanonik şekil: `{ entityType, entityId, opType, changedFields, hlc, operationId, actorId }`. SignalR yayını + delta kuyruğu bu tek zarftan türer. Tel-format 0002. *[senkron diliminde]*

**K-C4 — Olay dağıtımı + Outbox (atomiklik).** Domain event'ler transaction **içinde** toplanır; **integration-event outbox satırı domain değişikliğiyle AYNI commit'te** yazılır (dual-write deliği kapanır); **relay (SignalR + delta) commit SONRASI** outbox'tan okur. Outbox tablo şeması + çok-instance dispatcher güvenliği (`FOR UPDATE SKIP LOCKED`/tek-dispatcher) 0002. *[senkron diliminde]*

**K-C5 — Saat kaynağı + sunucu HLC otoritesi (yön).** `TimeProvider` (.NET 8+) DI'a bağlanır *[slice-1'de kaydedilir]*; `DateTime.Now/UtcNow` doğrudan çağrısı **BannedApiAnalyzers ile derleme-zamanı yasak** (K-H1). **Sunucu, ingest'te istemci HLC'sinin otoritesidir** (poison-write savunması) — *sınırlama/clamp algoritması 0002 mekaniğidir; burada yalnız yön.*

### D. API biçimi, sağlık, hata, versiyon, auth
**K-D1 — REST + OpenAPI.** Minimal API + endpoint gruplama. Doküman `Microsoft.AspNetCore.OpenApi` (.NET 9 yerleşik JSON); **UI ayrı paket (Scalar veya NSwag)** — .NET 9'da yerleşik Swagger UI yok.
**K-D2 — Sağlık.** `/health/live` (liveness) + `/health/ready` (readiness). **slice-1'de bile ısırır:** sahte `Unhealthy` check → `ready` **503** döndüren negatif test şimdi eklenir; DB gelince Npgsql kontrolü + ölü-DB→503 testi eklenir (kör kapı yok).
**K-D3 — Hata modeli.** Üniform **ProblemDetails (RFC 9457, 7807'yi geçersiz kılar)**; global exception→HTTP eşleme; validation → `400 problem+json`. Beklenen domain hataları **Result deseni**.
**K-D4 — Versiyonlama.** URL-segment `/v1` (`Asp.Versioning`) — offline istemci geri kalabilir.
**K-D5 — Auth sınırı.** Mekanizma sonraki dilim; **uçlar deny-by-default** (health `AllowAnonymous`). **`ICurrentUser` portu (Application) slice-1'de arayüz olarak tanımlanır**; implementasyonu + owner query-filter kimlik dilimiyle kodlanır (owner izolasyonu auth'a bağımlıdır, erken kodlanamaz).

### E. Kimlik primitifi
**K-E1 — UUIDv7 (`Guid.CreateVersion7()`).** Offline istemci ID'yi çevrimdışı üretmeli; v7 zaman-sıralı → indeks-dostu. **Risk:** .NET `Guid` byte-order ↔ Postgres `uuid`/Npgsql eşlemesi yanlışsa sıralı-indeks avantajı sessizce kaybolur → **DB geldiğinde v7 sıralama korunumu testle doğrulanır.**

### F. Kalıcılık
**K-F1 — EF Core + Npgsql; DB ertelendi.** `DbContext`+config Infrastructure'da tanımlı; iskelet çalışan DB olmadan derlenir. Sırlar repoya girmez → user-secrets/env (red line #1). Migration + gerçek bağlantı DB diliminde; o dilimde DB'siz **`ModelBuilder` model-doğrulama testi** + Testcontainers.

### G. Kesişen ilgiler
**K-G1 — Pipeline sırası/kapsamı.** Dıştan içe: **exception → loglama → doğrulama → (yalnız komutlarda) transaction/UoW.** Sorgular transaction açmaz. *[transaction behavior ilk komut/DB diliminde]*
**K-G2 — Doğrulama:** FluentValidation + validation behavior.
**K-G3 — Loglama:** Serilog (yapısal) + **correlation-id** *[slice-1'de]*.
**K-G4 — Eşleme:** manuel veya **Mapster (MIT)**. AutoMapper 2025'te ticarileşti → kullanılmaz (red line #3).

### H. Kalite kapıları ("ısıran kapı")
**K-H1 — Analizör + mimari + güvenlik kapıları.** `net9.0`, `Nullable=enable`, `TreatWarningsAsErrors`, `.editorconfig` + Roslyn analizörleri.
- **NetArchTest — gerçekten ihlal-edilebilir kurallar:** **Application ⊥ Infrastructure** · **Api endpoint/handler ⊥ Infrastructure somut tipleri** (composition root dışında) · **Domain ⊥ EF/ASP.NET/Npgsql namespace'leri**. Her kural commit'li negatif/mutant testle ısırdığını kanıtlar.
- **BannedApiAnalyzers:** `P:System.DateTime.Now`,`P:System.DateTime.UtcNow` yasak (K-C5) — mutant (UtcNow çağıran dosya) build'i kırar.
- **CVE kapısı (red line #3'ün diğer yarısı):** verify'de `dotnet list package --vulnerable --include-transitive` (gerekirse OWASP dependency-check). Eklenen **her** pakete tek-satır **lisans + CVE** beyanı (FluentValidation/Serilog/Mapster/Scalar/Asp.Versioning/NetArchTest dâhil).

**K-H2 — Test yığını [KARARA BAĞLANDI].** xUnit + **Shouldly (BSD-3-Clause)**. *(FluentAssertions 8.x ticari; v7.x Apache. Shouldly teknik-doğru + sıfır-bedel → denetçi ratifiye etti; yedek FA 7.x.)* **Errata (18 Tem 2026, slice-1 doğrulaması sonrası):** Shouldly gerçek lisansı **BSD-3-Clause** (nuspec SPDX), MIT değil — permissive & red-line-safe olduğundan ratifiye edildi. İzinli lisans ailesi: **MIT/Apache/BSD-3-Clause**.

### I. Senkron & gerçek-zamanlı YÖNÜ (mekanik → 0002)
**K-I1 — Senkron/çakışma:** delta/operasyon kuyruğu + **HLC** + **alan-düzeyi** çözüm (LWW+merge); sunucu HLC otoritesi (K-C5). Per-record monotonik HLC, "since X" delta çekişi + checkpoint'in (0002) ön koşulu.
**K-I2 — Gerçek-zamanlı:** SignalR; Hub `Api`'de; integration-event zarfından (K-C3) yayınlanır. **Yayın alıcı-bazlı yetki kapsamıyla sınırlanır (owner/collaborator grubu)** — kullanıcılar arası veri sızmaz (red line #2). Redis backplane + yazma-tarafı scale-out (Outbox competing-consumers) sonraki dilim.

---

## 3. Uygulama sırası — slice-1'de **KODLA** vs **YÖN-NOTU** (over-engineering çizgisi)

> Red-team hükmü: C-grubunu şimdi koda dökmek slice-1'i geciktirir ve "gösteriş mimarisi" tuzağıdır. slice-1 = **health-only**; entity/senkron kontratları **yön** olarak sabit ama **sonraki dilimlerde** kodlanır.

**slice-1'de KODLANIR (health host'u doğru kurmak):** K-A1 (4 katman) · K-H1 (NetArchTest DIP kuralları + BannedApiAnalyzers + CVE kapısı) · K-D1 (OpenAPI JSON + UI) · K-D2 (live+ready + **503 ısıran testi**) · K-D3 (ProblemDetails) · K-C5 **yalnız `TimeProvider` DI kaydı** · K-D5 (deny-by-default + `ICurrentUser` **arayüzü**) · K-D4 (`/v1`) · K-G3 (Serilog+correlation-id).

**YÖN-NOTU — slice-1'de KODLANMAZ (sonraki dilim):** K-C1 EntityBase (özellikle alan-düzeyi HLC temsili — 0002) · K-C2 operationId zarfı · K-C3 integration-event zarfı · K-C4 Outbox · K-G1 transaction/UoW behavior (DB yok) · K-I1/K-I2 senkron/SignalR.

**BORDERLINE:** K-B1 CQRS/Mediator + pipeline — health-only için tam CQRS tören; slice-1'de **minimal mediator kablolaması + bir örnek** yeter, tam desen ilk gerçek komut diliminde.

---

## 4. Gerekçe
Makineyle zorlanan Clean Architecture "mimari kalite" ekseninde en yüksek getiriyi verir. CQRS/Mediator komut→olay akışını tek kanonik zarftan (K-C3) hem SignalR'a hem delta kuyruğuna besler; **Outbox atomikliği** (K-C4) dual-write tutarsızlığını kapatır. HLC + alan-düzeyi çözüm offline-first'in tatlı noktası (entity-LWW veri kaybeder, CRDT süre riskini şişirir). Taşıyıcı kontratları **yön** olarak şimdi sabitlemek ama **kodlamayı dilime ertelemek**, omurga-önce disiplinini over-engineering'e düşmeden korur.

## 5. Alternatifler
| Eksen | Seçilen | Reddedilen (neden) |
|---|---|---|
| Katman | Clean Arch + feature-folder | Katı Vertical Slice (klasik-vitrin zayıf) · Sade N-katman (vitrin düşük) |
| Çakışma | HLC + alan-düzeyi | Entity-LWW (veri kaybı) · CRDT (karmaşıklık/süre) |
| Kimlik | UUIDv7 istemci-üretimli | Sequential (offline-first'i kırar) |
| Olay | Outbox (atomik) | Doğrudan dual-write (tutarsızlık) |
| Mediator | martinothamar (MIT) | MediatR 13+ (ticari/log) · MediatR 12 (donmuş) |
| Assertion | Shouldly (BSD-3-Clause) | FluentAssertions 8 (ticari) |

## 6. Riskler / açık noktalar
1. **K-B1a — mediator kütüphanesi:** ✅ karara bağlandı → martinothamar/Mediator (MIT, stabil pin). Kalan risk: tek-bakımcı bus-factor (CQRS soyutlamasıyla sınırlı; yedek MediatR 12.x Apache).
2. **UUIDv7 byte-order** DB diliminde testle doğrulanacak.
3. **DB ertelendi** → `ready` DB kontrolü DB diliminde ısırır (slice-1'de sahte-Unhealthy testiyle kapı yine de canlı).
4. martinothamar/Mediator seçilirse tek-bakımcı riski; MediatR 12 yedeği drop-in değil.
5. Lisans/sürüm etiketleri paket eklenirken teyit (+ CVE kapısı her pakette).

## 7. İlgili
- **ADR 0002 (sıradaki):** delta tel-format, HLC tick kuralları + sunucu sınırlama, alan-başına çakışma politikası, dedup, checkpoint/cursor, Outbox tablo şeması, taç-mücevher doğrulama kapısı.
- Gelecek: auth/kimlik dilimi (owner filter + ICurrentUser impl); DB/Docker dilimi; SignalR dilimi.

---

*✅ KİLİTLİ v3. engineering ✓ · red-team ✓ · K-B1a ✓. Sıradaki: GOREV_CLAUDE_CODE spec (slice-1) → ADR 0002 (senkron mekaniği).*
