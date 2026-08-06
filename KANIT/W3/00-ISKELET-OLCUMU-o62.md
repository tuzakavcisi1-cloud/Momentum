# W3 — YÜRÜYEN İSKELET, ÖLÇÜM KAYDI (oturum 62)

**Koşum:** 6 Ağu 2026, oturum 62. **Koşan el:** Cowork.
🔴 **NEREDE KOŞTU:** Cowork'ün **bulut konteyneri** (Linux, Ubuntu; .NET SDK **10.0.302** —
`global.json` piniyle **birebir aynı**; headless **Chromium**, Playwright). **Onur'un Windows
makinesinde DEĞİL.** Bu, beyan edilmiş bir sınırdır: aşağıdaki hiçbir sayı `C:\dev\Momentum`
üzerinde ölçülmedi.

**Neden bu tur bir spec değil kod:** `R8` sert durağı bu oturum açılışında **dürüstçe kırmızı
yandı** (o60 = 0, o61 = 0 ürün kodu satırı; o61 deftere hiç kayıt yazmamıştı, ölçüm o yüzden
kördü). `K53/4` gereği yeni spec/ADR/araç turu açılmaz; `K53/5` gereği **önce çalışan en küçük
şey** yazılır. Onur `İSKELET ÖNCE`'yi kilitledi.

---

## 1. ÜRÜN KODU (`src/` — R8'in saydığı yer)

| dosya | ne |
|---|---|
| `src/backend/Momentum.Api/Web/IzolasyonBasliklari.cs` | **YENİ** — COOP/COEP ara katmanı + kill switch |
| `src/backend/Momentum.Api/Program.cs` | `using` + iki satır kayıt (`var app = builder.Build();` hemen altında) |

Ara katmanın iki tasarım kararı ve **ölçülmüş** gerekçeleri:

1. **Başlıklar `OnStarting` ile yazılır, doğrudan değil.** `UseExceptionHandler` hata yolunda
   yanıtı temizleyip yeniden çalıştırabilir; doğrudan yazılan başlık o yolda **sessizce düşer**.
2. **`Cross-Origin-Resource-Policy` YOK.** CORP kapsamı (`/v1/**`, `/health/**`, `/hubs/sync`,
   `/scalar/v1`) ölçülmemiş bir karardır ve çapraz-köken istemcide **ürün davranışını değiştirir**.
   Ölçülmeden yazılmadı — bu bir **eksiklik değil, beyan**.

🔴 **BEYAN EDİLMİŞ SINIR (kodun kendi `<remarks>`'ında da yazılı):** `Momentum.Api` statik dosya
**sunmuyor** (`UseStaticFiles`/`UseDefaultFiles`/`wwwroot` = 0, oturum 60'ta ölçüldü) ⇒ bu başlıklar
**bu kökenden servis edilen belgeleri** izole eder. Flutter web istemcisi başka bir kökenden
sunulduğu sürece **istemci izole olmaz**. İstemcinin izolasyonu ayrı ve henüz alınmamış bir karardır.

---

## 2. ÖLÇÜM — DERLEME

```
dotnet build src/backend/Momentum.Api/Momentum.Api.csproj -c Debug
Build succeeded.  0 Warning(s)  0 Error(s)
```

---

## 3. ÖLÇÜM — TABAN (izolasyon açık, ürün varsayılanı)

```
$ curl -i http://127.0.0.1:5298/health/live
HTTP/1.1 200 OK
...
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

headless Chromium (Playwright), aynı adres:

```json
{"http":200,"coop":"same-origin","coep":"require-corp",
 "crossOriginIsolated":true,"SharedArrayBuffer":"function","Atomics":"object"}
```

🟢 **`crossOriginIsolated = true`** — iki denetim turunun kâğıt üzerinde çözemediği `T0`,
**koşan ürün kodu üzerinde** ölçüldü.

## 4. ÖLÇÜM — MUTANT `M-W3-1` (kill switch kapalı)

`Izolasyon__Etkin=false` ile aynı ikili yeniden koşturuldu:

```
--- basliklar ---   COOP/COEP YOK
--- tarayici ---
{"http":200,"coop":null,"coep":null,
 "crossOriginIsolated":false,"SharedArrayBuffer":"undefined","Atomics":"object"}
```

🟢 **MUTANT ISIRDI.** `SharedArrayBuffer` **undefined**'a düşüyor ⇒ ara katman gerçekten yük
taşıyor, dekoratif değil.

🔴 **BU MUTANT İLK KOŞUMDA KÖRDÜ ve bunu ölçüm yakaladı.** İlk iki denemede eski süreç
öldürülemedi (`pkill -f <dll yolu>` **kendi kabuğunu** da öldürüyordu), mutant koşumu **eski
sürece** çarptı ve `true | function` döndürdü — yani *"mutant ısırmadı"* diye okunacak **sahte bir
yeşil**. Onarım: koşucu ayrı bir dosyaya alındı (`_mutant_m_w3_1.sh`), her koşumdan önce
① süreç listesi ② port `000` **yoklanarak** doğrulanıyor; port doluysa betik `EXIT 3` ile **duruyor**.
Ders `ORTAM.md` sınıfının aynısı: **ölçüm aracının kendi kusuru ürüne yazılırsa, kör kapının
aynadaki hâli olur.**

---

## 5. ÖLÇÜM ARACI — `araclar/izolasyon-olc.py` **1.0.0**

İki ayaklı: **H** (yalnız stdlib, her yerde koşar) yanıt başlıklarını, **T** (playwright) gerçek
tarayıcıda `crossOriginIsolated`'ı ölçer.

**Altın küme: 11/11, EXIT 0.** Vakalar: tam set susmalı · hiç başlık yok ısırmalı ·
yalnız COOP · yalnız COEP · `unsafe-none` · `credentialless` (**bilerek** reddedilir) ·
`same-origin-allow-popups` · başlık **adı** küçük harf (susmalı — ad duyarsız, **değer değil**) ·
tarayıcıda `true` · tarayıcıda `false` · **ulaşılamayan adres ⇒ ORTAM HATASI** (*"izole değil"*
DEMEZ).

Canlı ürün üzerinde: `HUKUM: CAPRAZ-KOKEN IZOLE (iki ayak da olculdu)` · EXIT 0.

🔴 **Aracın beyan ettiği kendi sınırı:** Onur'un makinesinde **playwright yok** (oturum 60'ta
ölçüldü) ⇒ orada **T ayağı `[ÖLÇÜLEMEDİ]`** der ve araç *"tam yeşil değil"* hükmü verir.
**ÖLÇÜLEMEDİ yeşil değildir.** H ayağı orada da koşar.

---

## 6. NE ÖLÇÜLEMEDİ (boş olamaz)

1. **Onur'un Windows makinesinde hiçbiri.** Derleme de, koşum da, tarayıcı da bulutta oldu.
   `verify.ps1` bu oturumda **koşulmadı**; backend test paketi (`120/120`) bu değişiklikle
   **yeniden koşulmadı**.
2. **Flutter istemcisinin davranışı.** `drift`in `sharedIndexedDb` → OPFS geçişi bu iskelette
   **hiç egzersiz edilmedi**; W3'ün asıl ürün sorusu (`O2`) **açık**.
3. **`/scalar/v1` ve `/hubs/sync` `require-corp` altında.** İkisi de canlı uç nokta; bu oturumda
   **ölçülmedi** (denetim raporu `F/4` ve `F/5` maddeleri **açık kalıyor**).
4. **CORP** — bilerek yazılmadı, dolayısıyla ölçülmedi.
5. **Çapraz-köken alt kaynak davranışı.** `require-corp` altında CORP göndermeyen bir alt kaynağın
   **bloklandığı** ölçülmedi; ölçülen yalnızca **belgenin izole olduğudur**.
6. **`OnStarting` kararının hata yolundaki üstünlüğü** — gerekçe *okunarak* yazıldı;
   `UseExceptionHandler`'ın başlıkları düşürdüğü bir mutantla **kanıtlanmadı**.
7. **Kimlik.** Bu dosyanın ve teslim edilen üç dosyanın sha/bayt kimliği **cihaza yazıldıktan
   SONRA** ölçülür (K151-b'nin dersi).
