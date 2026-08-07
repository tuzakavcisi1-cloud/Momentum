# KANIT/W3/05 — `K159`'un ÜRÜN KUSURU: `/v{version}` ↔ `SpaDisiOnEkler` uyumsuzluğu · oturum 63

**Ölçüm tarihi:** 7 Ağu 2026, ~19:40 UTC (**22:40 +03**). **Ölçen el:** Cowork, bulut konteyneri.
**Nasıl bulundu:** `K159`'un kapısını yazan el Cowork'tü; `K26` gereği **iki bağımsız denetçi ajan**
farklı merceklerle (kör-kapı avı / yanlış-pozitif avı) salındı. **İkisi de kapıyı kırdı (16 bulgu)**
ve birincisi kapının kör noktasının **canlı bir ürün kusurunu örttüğünü** gösterdi.

---

## 1. KUSUR — ölçülmüş, sonra Cowork tarafından BAĞIMSIZ doğrulandı

`K159`'un ilk yazımı `SpaDisiOnEkler` listesine **literal** `"/v1"` koymuştu. Gerçek rota ailesi ise
`MapGroup("/v{version:apiVersion}")` ile kuruluyor. Sonuç:

| yol | ÖNCE | SONRA |
|---|---|---|
| `/v1/YOK` | 404 | **404** |
| `/v2/YOK` | 🔴 **200 · text/html · 1546 B** | **404** |
| `/v3/YOK` | 🔴 200 · text/html | **404** |
| `/v1.0/YOK` | 🔴 200 · text/html | **404** |
| `/vault/x` | 200 · text/html | **200 · text/html** *(doğru — API yolu değil)* |
| `/version/x` | 200 · text/html | **200 · text/html** *(doğru)* |
| `/v1/tasks` (başlıksız) | 401 | **401** *(`K61` kalkanı sağlam)* |
| `/health/YOK` | 404 | **404** |
| `/hubs/YOK` | 404 | **404** |
| `/openapi/YOK` | 404 | **404** |

🔴 **`K159`'un kendi dersi kendisine uygulanmamıştı.** O checkpoint şunu yazıyor: *"Bir API'nin
bilinmeyen uç nokta için HTML döndürmesi kusurdur."* Düzeltme yazıldı, `/v1` için **ölçüldü**,
yeşil görüldü ve kapatıldı sanıldı — **oysa koruma yalnız BİR sürüm için koşuyordu**. Tek bir
sürümü ölçüp *"sınıf kapandı"* demek, bu projenin `vaka ≠ sınıf` kusurunun bir kopyasıdır.

## 2. DÜZELTME

`SpaDisiOnEkler` artık **literal önek değil, ROTA ŞABLONU** tutar:

```csharp
public static readonly string[] SpaDisiOnEkler =
    ["/v{version:apiVersion}", "/health", "/hubs", "/scalar", "/openapi"];
```

`MapFallback(onEk + "/{*kalan}", () => Results.NotFound())` böylece gerçek rota ailesini
**birebir aynalar**. `apiVersion` kısıtı `AddApiVersioning` tarafından kaydedildiği için
`/vault/...` ve `/version/...` bu şablona **uymaz** ve doğru şekilde SPA kabuğuna düşer — ölçüldü.

> **KİLİTLENECEK DERS:** SPA'dan dışlanan yol, korumak istediği rota ailesinin **ŞABLONUNU**
> taşımak zorundadır; şablonun **literal bir örneğini** değil. Literal örnek, ailenin geri kalanını
> sessizce korumasız bırakır.

**Dosya:** `src/backend/Momentum.Api/Web/IstemciServisi.cs` · 128 satır · sha256/16 `eeddf193542b53b7`
Derleme **0 uyarı / 0 hata** (`TreatWarningsAsErrors=true`).

## 3. REGRESYON — `K159`'un tüm iddiaları yeniden ölçüldü

- 21 vakalık HTTP ölçümü: **BAŞLIKSIZ YANIT 0** · **KABUK DÖNEN API YOLU: YOK**
- Gerçek tarayıcı: **`crossOriginIsolated = True`**, `SharedArrayBuffer = function`, Flutter çizildi,
  10 istek **0 başarısız**
- `K61` (başlıksız 401) ve slice-2b2 `D4` hub kalkanı **canlı**

🟡 `/scalar/YOK` **200 · text/html · 627 B** döner — bu SPA kabuğu **DEĞİLDİR** (kabuk 1.546 B);
Scalar'ın kendi UI'ı `/scalar/{documentName}` eşlemesiyle yanıt veriyor. Gölgeleme değil.

## 4. 🔴 KAPI TESLİM EDİLMEDİ — 16 BULGU

`izolasyon-olc.py`'ye yazılan üç ayak (`B` build · `S` gölgeleme · `F` tazelik) **altın kümesini
25/25 geçti** ve **dört gerçek-depo mutantı ısırdı** — ve **yine de kördü**. Taslak
`KANIT/W3/06-KAPI-TASLAGI-DENETIMDE-DUSTU-o63.py` olarak **saklandı**, `araclar/`'a **konulmadı**.

Bulguların tamamı Cowork projesindeki `oturum-63-K159-kapisi-DENETIMDE-DUSTU-16-bulgu.md`
belgesindedir. Başlıklar:

**Kör bırakanlar** — kapsama testi **alt-dize** (`/health` → `/healthz`, `/hubs` → `/hubs-v2`,
`/v1` → `/v1beta` yutuluyor; F'nin tek varlık sebebi olan "liste bayatladı" mutantı **geçti**) ·
`canvasKitBaseUrl` regex'i **tek tırnak** ve **protokol-göreli** yazımı kaçırıyor (denetçi iki köken
+ gerçek Chromium ile **canlı istismar** gösterdi) · `app.MapGet("/mutlak")` F'ye **görünmez**
(runtime kanıtı) · ayrıştırıcı `@"..."`, `[.. spread]`, `nameof()`, `$"..."` yazımlarında **sessizce
yanlış liste** dönüyor · listeye giren tek bir `"/"` F'yi tamamen etkisizleştiriyor ·
`[Route]` öznitelikli controller **beyan edilmemiş üçüncü sınıf** · **ÖLÇÜLEMEDİ'de EXIT=0**.

**Gürültü üretenler** — `_cs_bul` `bin`/`obj` atlamıyor (bayat kopyayı ayrıştırıp *"ARACA
YAZILMADI, AYRIŞTIRILDI"* diye ilan ediyor) · yorum sıyırıcı `'"'` karakter literaliyle **faz
kaydırıyor** · iç içe `MapGroup` mutlak sanılıyor · okunamayan dizin **B0 KIRMIZI** veriyor
(aracın kendi ORTAM≠BULGU doktrininin ihlali) · `S` dizin ile dosyayı ayırmıyor · yanlış hata metni.

**Kırılamayanlar:** `--altin-kume` determinist ve artıksız · 1 GiB bootstrap + bellek sınırı →
temiz `ORTAM HATASI` · döngüsel symlink → asılmıyor · geçersiz UTF-8 → temiz hata ·
**`B` ayağının çekirdek iddiası gerçek CDN/yerel build çiftinde doğrulandı** ·
`fonts.gstatic.com` bugün `CORP: cross-origin` + `ACAO: *` taşıyor ⇒ `require-corp` altında geçerli
(o63'ün "ÖLÇÜLEMEDİ" kaydını denetçi **kapattı**).

## 5. 🔴 NE ÖLÇÜLEMEDİ

1. **Onur'un makinesinde hiçbiri.** `verify.ps1` + 120 test bu değişiklikle **koşulmadı**
   (`B-O62-2` **üçüncü** oturumdur açık).
2. **PostgreSQL yok** ⇒ `/v1/**` uçlarının 200 gövdesi yine görülmedi.
3. **`/v2` ailesi gerçekten kullanıma açıldığında** davranış: bugün `ApiVersionSet` yalnız `1.0`
   ilan ediyor; `/v2` bir uç nokta **eşlerse** fallback'in onu gölgelemediği ölçülmedi.
4. **Windows/NTFS** davranışı (denetçilerin ölçümleri de dâhil) hiç ölçülmedi — hepsi Linux/ext4.
5. **Kapı taslağının 16 bulgusunun onarımı** yapılmadı; `K34-f` gereği **onaran el ayrı olmalı**.
6. **Denetçilerin ham koşum logları** oturumla birlikte kaybolur; yalnız özetleri saklandı.
