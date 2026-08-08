> # 🔴 BU BİR TASLAKTIR — `K127` DENETİMİNDE DÜŞTÜ (o64, 8 Ağu 2026)
>
> **`docs/ADR/0004-*.md` DOSYASINA YAZILMADI. KİLİTLENMEDİ.** `K26` gereği salınan **iki bağımsız
> denetçi** (agentId `aecafd5ecb646f518` · `a825b59210dbebfc6`) **altı bloker + on üç major** buldu;
> ikisi **bağımsız olarak aynı iki blokeri** işaretledi:
> ① §2.E'nin `--no-web-resources-cdn` gerekçesi, ADR'nin **kendi kaynak kümesindeki** bir ölçümle
> (`GOREV-W3` §1 `O3` — gstatic **`CORP: cross-origin` gönderiyor**) çürütülmüş ve o ölçüm belgede
> **hiç anılmamış** ② §2.H'nin CI kararı, gerekçe gösterdiği riski (**bayrağın unutulması**)
> `izolasyon-olc.py`'nin `H` ayağıyla **yapısal olarak ölçemez** — `H` yanıt başlıklarını ölçer,
> başlıkları ara katman yazar, bayrak onları **etkilemez** ⇒ **kör kapı**, `B-O63-2` kapanmaz.
>
> **Bulguların TAM METNİ:** Cowork projesi → `oturum-64-ADR0004-govdesi-DENETIMDE-DUSTU.md`.
> **Onarım `K34-f` gereği ayrı ele aittir** ya da bu el onarırsa **yeni bir bağımsız denetim** gerekir.
> 🔴 **Aşağıdaki metin ONARILMAMIŞ hâliyle saklanmıştır** — hiçbir iddiası canlı sayılmaz.

---

# ADR 0004 — Web Çapraz-Köken İzolasyonu (COOP/COEP) ve OPFS Kalıcılığı

- **Durum:** 🔴 **DENETİMDE DÜŞTÜ (o64).** Taslak; kilit YOK, `docs/ADR/`'ye girmedi.
- **Tarih:** 2026-08-05 (iskelet, oturum 59) → **2026-08-08 (gövde, oturum 64)**
- **Kaynak dilim:** `GOREV-W2-depolama-gorunurlugu.md` §2 *"COOP/COEP ve OPFS'e geçiş ⇒ `ADR 0004`"*
  · yürüyen iskelet `GOREV-W3-capraz-koken-izolasyonu.md`
- **Yerini aldığı metin:** bu dosyanın **iskelet** hâli (3.656 b, o59). O metin **karar içermiyordu** ve beş
  açık sorusunun beşi de `[ÖLÇÜLMEDİ]` damgalıydı. **Beşi de o62/o63'te ölçüldü**; §1.3 eşlemeyi verir.

> 🔴 **BU ADR'DEKİ HİÇBİR SAYI BEYAN DEĞİLDİR.** Her iddia bir `KANIT/W3/**` dosyasına ve o dosyadaki
> koşuma dayanır. Ölçülmemiş olan **"ÖLÇÜLMEDİ" diye yazılıdır ve yeşil sayılmaz.**
> 🔴 **ÖLÇÜMLERİN ORTAK SINIRI:** aşağıdaki ölçümlerin **hepsi** Cowork'ün **bulut konteynerinde**
> (Linux, .NET SDK `10.0.302`, headless Chromium/Playwright, **Flutter 3.44.9**) koştu.
> **Onur'un Windows makinesinde hiçbiri koşmadı** ve depo `DURUM.md` Flutter **3.44.6** diyor —
> **yama farkı vardır, etkisi ölçülmedi.** `K80` Onur'un makinesi için aynen ayaktadır.

---

## 1. Bağlam

### 1.1 W2 neyi bıraktı

`W2` (K142/K144) tarayıcıda **ölçtü**: bu projenin web istemcisi `sharedIndexedDb` implementasyonuna
**geri düşüyordu**; `opfsLocks` (kalıcı, OPFS tabanlı) **seçilmiyordu**. Ölçülmüş sebep drift'in kendi
kaynağında belgeli (`wasm_setup/types.dart`): `opfsLocks` **çapraz-köken izolasyon** ister — sunucunun
`Cross-Origin-Opener-Policy: same-origin` **ve** `Cross-Origin-Embedder-Policy: require-corp` göndermesi
gerekir. Sunucu bunları göndermiyordu.

`W2` bu durumu **görünür kıldı ama onarmadı** — kapsam dışıydı. Bu ADR o onarımın kararlarını taşır.

> **Bu ADR'nin çözdüğü şey kalıcılığın YOKLUĞU değildir.** `sharedIndexedDb` de saklar (`W1` kriter 9:
> F5 sonrası görev yaşadı). Çözülen, kalıcılığın **en sağlam yoluna (OPFS) Chrome'da erişilememesidir.**

### 1.2 Merkezî ürün sorusu ve cevabı

**İzolasyon tek başına drift'in seçimini değiştirir mi?** — İki koşullu, gerçek `flutter build web`
üzerinde, **üründe tek bayt değiştirmeden** ölçüldü (`KANIT/W3/02-O2-OLCUMU-o62.md`):

| koşul | `crossOriginIsolated` | `chosenImplementation` | `missingFeatures` |
|---|---|---|---|
| başlık **yok** | `false` | `sharedIndexedDb` | `dedicatedWorkersInSharedWorkers`, **`sharedArrayBuffers`** |
| `COOP`+`COEP` | **`true`** | **`opfsLocks`** | `dedicatedWorkersInSharedWorkers` |

🟢 **EVET — temiz kurulumda.** `veritabani.dart`'a dokunulmadan, `driftDatabase()` çağrısı yerinde
dururken. Eksik olan **bayrak değil, izolasyondu**.

🔴 **HAYIR — mevcut kullanıcıda.** Aynı ölçüm **kalıcı profille** üç koşum tekrarlandı
(`KANIT/W3/03-VERI-GOCU-OLCUMU-o62.md`): izolasyon açıkken `missingFeatures`'tan `sharedArrayBuffers`
**düştü** (drift izolasyonu **gördü**) ve buna rağmen `sharedIndexedDb`'de **kaldı**; **OPFS üç koşumda
da BOŞ** — göç **hiç başlamadı**. Sebep drift'in `_selectExistingDatabase` davranışıdır: **var olan depo
tercih edilir.**

> Bu ikilik ADR'nin en önemli tek cümlesidir ve **kararı da belirler** (§2.G):
> **temiz kurulum OPFS'e geçer, mevcut kullanıcı geçmez.**

### 1.3 İskeletin beş sorusu — hepsi ölçüldü

| iskelet sorusu (o59, `[ÖLÇÜLMEDİ]`) | ölçüm | kaynak |
|---|---|---|
| 1. Başlıklar nerede eklenir? Bugünkü statik varlık seti CORP koşulunu karşılıyor mu? | ASP.NET Core ara katmanı (`OnStarting`) + istemci **aynı kökenden**; 21 vakanın **21'i** COOP+COEP taşıyor. Statik set **`--no-web-resources-cdn` ile** karşılıyor; **onsuz karşılamaz** | `04` §2, §5 |
| 2. `require-corp` SignalR'ı etkiler mi? | **HAYIR** — pozitif kontrollü: izolasyon **açık ve kapalı** iki koşumda da `negotiate` **200** | `01` `F/5` |
| 3. Yalnız `Development` mı? | **Hayır — her ortamda** | `04` §1, `K159/3` |
| 4. İzolasyon tek başına yeter mi? | Temiz kurulumda **evet**; mevcut kullanıcıda **hayır** | `02` + `03` |
| 5. Canlı tarayıcı ölçümü bu ortamda nasıl? | Bulut konteynerinde Playwright/Chromium ile; **Onur'un makinesinde playwright YOK** ⇒ orada `T` ayağı `[ÖLÇÜLEMEDİ]` der | `00` §5, `B-O62-3` |

---

## 2. Kararlar

### A. `COOP: same-origin` + `COEP: require-corp` — **HER ORTAMDA**, `OnStarting` ile

Ara katman `src/backend/Momentum.Api/Web/IzolasyonBasliklari.cs`. İki tasarım kararı ve gerekçeleri:

1. **Başlıklar `OnStarting` ile yazılır, doğrudan değil.** `UseExceptionHandler` hata yolunda yanıtı
   temizleyip yeniden çalıştırabilir; doğrudan yazılan başlık o yolda **sessizce düşer**.
   🔴 **Bu gerekçe OKUNARAK yazıldı; `UseExceptionHandler`'ın başlıkları düşürdüğü bir mutantla
   KANITLANMADI** (`00` §6/6).
2. **Kill switch:** `Izolasyon:Etkin=false` ara katmanı kapatır. Mutant `M-W3-1` ile **ısırdığı ölçüldü**:
   `crossOriginIsolated` `false`, `SharedArrayBuffer` **`undefined`** (`00` §4).

**Neden her ortamda, yalnız `Development` değil:** `Program.cs`'te **üçüncü** bir `IsDevelopment()` bloğu
doğmasın — o60 denetiminin `BLOKER-3`'ü tam bunu işaretlemişti. İzolasyon bir hata ayıklama kolaylığı
değil, **ürünün kalıcılık davranışının ön koşuludur**; ortama göre değişen bir kalıcılık yolu, üretimde
ölçülmemiş bir davranış demektir.

### B. İstemci **AYNI KÖKENDEN** sunulur

`src/backend/Momentum.Api/Web/IstemciServisi.cs` (**128 satır**, sha256/16 `eeddf193542b53b7`).

1. Kök dizin **yapılandırmadan** okunur: `Istemci:KokDizin` (`W1/D-W1-1` deseni — yol koda gömülmez).
2. Anahtar **boş** ya da dizin **diskte yoksa** ara katman **hiç kurulmaz** ⇒ kill switch **bedava** gelir.

**Ölçülmüş gerekçe:** o62'nin ara katmanı kendi `<remarks>`'ında şu sınırı beyan ediyordu — *"`Momentum.Api`
statik dosya SUNMUYOR ⇒ bu başlıklar, Flutter istemcisi **başka bir kökenden** servis edildiği sürece
istemciyi izole ETMEZ."* o63'te istemci aynı kökene alındı ve **`crossOriginIsolated = true`** gerçek
tarayıcıda ölçüldü (`04` §3) ⇒ **o beyan edilmiş sınır KAPANDI.**

Mutant `M-W3-2` (istemci aynı kökende **kalır**, yalnız `Izolasyon:Etkin=false`) **ısırdı**:
`crossOriginIsolated=false`, `SharedArrayBuffer=undefined`, ama **uygulama yine açıldı** ⇒ izolasyon
**ürün kodunun yazdığı başlıklardan** doğuyor; aynı kökenden servis etmek **tek başına yetmiyor** (`04` §4).

### C. Ara katman **SIRASI ZORUNLUDUR**

```
UseIzolasyonBasliklari → UseIstemciServisi (statik) → app.UseRouting() [AÇIKÇA] → UseCors → uç noktalar
```

🔴 **`app.UseRouting()` AÇIKÇA çağrılır.** Ölçülmüş gerekçe (`04` §6/K2): `/assets/NOTICES` **1.546 b**
SPA kabuğu dönüyordu, oysa dosya diskte **1.380.683 b**. **İlk düzeltme (`ServeUnknownFileTypes=true`)
kâğıtta doğru, koşumda ÖLÜ çıktı.** Kök neden birincil kaynakta: `StaticFileMiddleware` **eşleşmiş bir uç
nokta varsa dosyayı hiç sunmaz** (`ValidateNoEndpoint`), `WebApplication` ise `UseRouting`'i ardışık hattın
**en başına kendisi ekler** ⇒ statik ara katman yönlendirmeden **sonra** koşuyordu.
**Yeniden ölçüm: 1.380.683 b.** ✅ `D-W1-3` korunur: `UseCors` hâlâ `UseRouting` ile uç nokta yürütmesi
arasındadır.

> **Ders (`K53/5`'in kendi gerekçesi):** ölçüm koşmasaydı repoya *bir şey yaptığını sanan* bir yapılandırma
> satırı girecekti.

### D. SPA dışı önekler **ROTA ŞABLONU** taşır — literal örnek DEĞİL (`K161-b`)

```csharp
public static readonly string[] SpaDisiOnEkler =
    ["/v{version:apiVersion}", "/health", "/hubs", "/scalar", "/openapi"];
```

**Ölçülmüş gerekçe (`05`):** ilk yazım literal `"/v1"` koymuştu; gerçek rota ailesi
`MapGroup("/v{version:apiVersion}")` ile kuruluyordu. Sonuç: `/v1/YOK` → 404 (yeşil görüldü,
"sınıf kapandı" sanıldı) ama **`/v2/YOK` → 200 + `index.html` CANLI kaldı**. Şablona geçildikten sonra
`/v1`–`/v1.0`–`/v2`–`/v3` hepsi **404**; `/vault/x` ve `/version/x` **doğru şekilde** SPA'ya düşüyor
(`apiVersion` kısıtı onlara uymuyor).

🔴 **Bu kusuru ÜRETEN el bulmadı** — `K26` gereği salınan **iki bağımsız denetçi** buldu.
**Bir API'nin bilinmeyen uç nokta için HTML döndürmesi kusurdur.**

### E. `--no-web-resources-cdn` bir tercih değil, **KAPI ŞARTIDIR** (`K159-b`)

Flutter'ın **varsayılan** `flutter build web` çıktısı CanvasKit'i
`https://www.gstatic.com/flutter-canvaskit/<engineRevision>` adresinden çeker. Birincil kaynak,
`flutter_bootstrap.js`'in kendi üçlü işleci:

```js
i.canvasKitBaseUrl ? i.canvasKitBaseUrl
                   : (e.engineRevision && !e.useLocalCanvasKit
                        ? I("https://www.gstatic.com/flutter-canvaskit", e.engineRevision)
                        : "canvaskit")
```

`useLocalCanvasKit` **yalnız** `--no-web-resources-cdn` ile `true` olur
(`flutter_tools/lib/src/runner/flutter_command.dart:1479` + `build_info.dart:1098`).

**`require-corp`'un fiilen blokladığı pozitif+negatif kontrolle ölçüldü** (`04` §5): ikinci köken
(`127.0.0.1:5299`), `korplu.js` CORP taşır / `korpsuz.js` taşımaz ⇒ **CORP'suz BLOKLANDI, CORP'lu YÜKLENDİ.**
Ayrıca `<img>` (`no-cors`) ile üç varyant (`01` EK):

| alt kaynağın CORP'si | sonuç | tarayıcı hatası |
|---|---|---|
| **yok** | 🔴 BLOKLANDI | `ERR_BLOCKED_BY_RESPONSE.NotSameOriginAfterDefaultedToSameOriginByCoep` |
| `same-origin` | 🔴 BLOKLANDI | `ERR_BLOCKED_BY_RESPONSE.NotSameOrigin` |
| `cross-origin` | 🟢 YÜKLENDİ | — |

> ⇒ **Web sürümü `--no-web-resources-cdn` OLMADAN derlenirse bu ADR'nin izolasyon iddiası ÇÜRÜR.**

🔴 **Bayrak `useLocalCanvasKit`'i ÇALIŞMA ZAMANINDA çevirir, BAYTI ÇIKARMAZ:** `--no-web-resources-cdn`
ile üretilen çıktıda `www.gstatic.com/flutter-canvaskit` dizgesi **`flutter.js`(1) + `flutter_bootstrap.js`(1)
= 2** yerde **DURUYOR** (`02` ikincil ölçüm). Bu yüzden `G45/d` **pinli sayan-raporlayan** bir kapıdır
(`K151/④`), *"dizge yok"* diyen bir kapı **değildir** — öyle bir kapı yanlış-negatif verirdi.

### F. `Cross-Origin-Resource-Policy` **YAZILMAZ** — bilerek, beyanla

CORP kapsamı (`/v1/**`, `/health/**`, `/hubs/sync`, `/scalar/v1`) **ölçülmemiş bir karardır** ve
çapraz-köken bir istemcide **ürün davranışını değiştirir**. Ölçülmeden yazılmadı.
**Bu bir eksiklik değil, beyandır** (`00` §1/2).

### G. Veri göçü **KAPSAM DIŞIDIR** — `K158` zorunlu beyanı

**MEVCUT `sharedIndexedDb` deposu olan bir tarayıcı OPFS'e GEÇMEZ**; verisi IndexedDB'de kalır.
`T5` (`WasmDatabase.open(..., moveExistingIndexedDbToOpfs: true)`) **ERTELENDİ ve YAZILMAYACAK.**
Üç ölçülmüş gerekçe:

1. COOP/COEP başlıkları **temiz kurulumu** zaten `opfsLocks`'a taşıyor (§1.2).
2. Kalıcı profille üç koşum: izolasyon açık, `chosenImplementation` yine `sharedIndexedDb`,
   **OPFS BOŞ** ⇒ göç **hiç başlamadı** — yani bayraksız yol **çalışmıyor**, "yavaş" değil.
3. **Sürüm yükseltme yolu ÖLÜ:** `drift 2.34.3` `wasm.dart:163` bayrağı taşıyor ama
   `drift_flutter 0.3.1` `web.dart:19-24` **geçirmiyor**, ve pub.dev `/api` ölçümü
   **`latest = 0.3.1`** (11 Tem 2026) diyor ⇒ yükselterek çözülemez.

**Beyan edilmiş bedel:** bayrağın koruduğu şey **mevcut kullanıcı verisidir**; bu depo private ve sahada
kullanıcı **yok** ⇒ kazanç teorik, bedel gerçek (dosya bölmesi · `WasmDatabase.open`'ın VM'de derlenmemesi ·
`W2`'nin `onResult` dikişini taşıma riski — denetimin `B-2`/`B-6` blokerleri).

🔴 **`B-11` (göç atomik değil: taşıma kopyalamıyor, kaynağı SİLİYOR) HÂLÂ ÖLÇÜLMEDİ** (`B-O62-8`).
**`T5` bir gün açılırsa ÖNCE o ölçülür; sıra tersine çevrilemez.**

### H. CI **önce build alır, sonra kapıyı koşar** *(Onur kilitledi, 8 Ağu 2026)*

`GOREV-W3` §8/6 bu kararı açıkça bu ADR'ye havale etmişti: *"`wwwroot` CI'da yoktur. `G43/g` orada
**ORTAM HATASI** verir; CI iş akışının bu kapıyı koşup koşmayacağı bu dilimde **KARARA BAĞLANMADI** —
`T9`'da `ADR 0004`'e yazılır."* **Karar:**

```
1. flutter build web --release --no-web-resources-cdn
2. çıktı → Istemci:KokDizin
3. API kaldırılır (hazır olma /health/live 200'e kadar YOKLANIR — sabit sleep YASAK, K80)
4. izolasyon-olc.py  H ayağı koşar   (yalnız stdlib ⇒ CI'da playwright gerekmez)
```

**Ölçülmüş gerekçe:** §2.E gösterdi ki bayrak unutulursa izolasyon **sessizce** kırılır ve bugün bunu
gören **hiçbir kapı yok** (`B-O63-2`). Kapıyı build **sonrasına** koymak, `G43/g`'nin `wwwroot`
yokluğundan doğan ORTAM HATASI'nı da ortadan kaldırır — çünkü kök artık **vardır**.
**Beyan edilmiş bedel:** CI süresi artar ve iş akışına bir Flutter SDK adımı girer.
🔴 **Bu karar bu ADR'de YAZILDI, CI'da HENÜZ KOŞULMADI** — uygulaması `D-A13-4` (backend CI) turunda.
🔴 `T` ayağı (gerçek tarayıcı) CI'da **koşmaz**; `H` ayağı yalnız **başlıkları** ölçer, belgenin fiilen
izole olduğunu **ölçmez**. Bu, bilinçli ve **beyan edilmiş** bir kapsam daraltmasıdır.

---

## 3. Uygulama sırası ve kanıtlar

| adım | ürün kodu | kanıt |
|---|---|---|
| 1. İzolasyon ara katmanı + kill switch | `Web/IzolasyonBasliklari.cs` (yeni), `Program.cs` (+2) | `KANIT/W3/00-ISKELET-OLCUMU-o62.md` — derleme **0 uyarı/0 hata**; `crossOriginIsolated=true`; `M-W3-1` **ısırdı** |
| 2. `/scalar/v1` ve `/hubs/sync` izolasyon altında | — (ölçüm) | `KANIT/W3/01-F4-F5-OLCUMU-o62.md` — `F/4` **KAPANDI**, `F/5` **ölçüldü** |
| 3. Merkezî ürün sorusu (`O2`) | — (ölçüm) | `KANIT/W3/02-O2-OLCUMU-o62.md` **(ERRATUM'lu)** |
| 4. Veri göçü | — (ölçüm) | `KANIT/W3/03-VERI-GOCU-OLCUMU-o62.md` — `02`'yi **daraltır** |
| 5. İstemci aynı kökenden | `Web/IstemciServisi.cs` **128 satır** (yeni), `Program.cs` (+15) | `KANIT/W3/04-ISTEMCI-IZOLASYONU-o63.md` — 21 vaka, `M-W3-2` **ısırdı** |
| 6. `/v{version}` ↔ `SpaDisiOnEkler` onarımı | `Web/IstemciServisi.cs` | `KANIT/W3/05-URUN-KUSURU-V-SURUMU-o63.md` |

**HTTP düzeyi hüküm (21 vaka, `04` §2):** **BAŞLIKSIZ YANIT SAYISI = 0** · **KABUK DÖNEN API YOLU = YOK.**
Dört API yüzeyinin (`/v1/**`, `/health/**`, `/hubs/sync`, `/scalar/v1`) hiçbiri gölgelenmiyor;
`K61` dev-kimlik kalkanı **canlı** (başlıksız **401**); slice-2b2 `D4` hub kalkanı **canlı**.

---

## 4. Gerekçe

**Neden başlıklar, neden kod değil.** `B1` blokeri iki tur boyunca *"drift `sharedIndexedDb`'de KALIR,
ürün davranışı DEĞİŞMEZ"* dedi ve `T5`'in **tek gerekçesiydi**. Ölçüm bunu **temiz kurulum için çürüttü**:
`WasmDatabase.open`'ın seçim mantığı zaten tarayıcı yeteneğine bakıyor; eksik olan **bayrak değil,
izolasyondu**. **İki yanıt başlığı**, bir dosya bölmesinden ve `onResult` dikişini taşıma riskinden daha
ucuz ve daha az kırılgandır.

**Neden aynı köken.** İzolasyon başlıkları yalnız **kendi kökenlerinden servis edilen belgeleri** izole
eder. İstemci ayrı bir kökende kaldığı sürece API'ye başlık eklemek `crossOriginIsolated`'ı **açmaz** —
bu o62'de kodun kendi `<remarks>`'ında beyan edilmiş bir sınırdı ve o63'te **kapatılarak** ölçüldü.

**Neden şablon, neden literal değil.** Ölçülmüş bedeli var: literal `/v1` yazan koruma, `/v2`–`/v3`–`/v1.0`
ailesini **sessizce korumasız bıraktı** ve bunu üreten el görmedi.

**Neden ölçüm bu kadar çok kez kendi kusurunu buldu.** Bu turda **üç** ölçüm aracı kusuru üretildi ve
**üçü de yakalandı**: `pkill` kendi kabuğunu öldürüyordu (sahte yeşil mutant) · kalıcı profil + HTTP
önbelleği izolasyonu kör ölçtürüyordu · konteynerde locale yokluğu Flutter'ı `RangeError` ile çökertip
*"kanıt hiçbir koşulda görünmedi"* dedirtiyordu. Her üçünde de onarım **muhafız eklemekti**:
ölçülen `== beklenen` doğrulanmazsa koşum **`KOR`** işaretlenir ve hüküm vermeyi **reddeder**.
*Ölçüm aracının kendi kusurunu ürüne yazmak, kör kapının aynadaki hâlidir.*

---

## 5. Alternatifler ve REDDEDİLENLER

| alternatif | hüküm | gerekçe |
|---|---|---|
| `COEP: credentialless` | 🔴 **BİLEREK REDDEDİLDİ** | `izolasyon-olc.py` altın kümesinde **ayrı bir vaka** olarak reddedilir. `credentialless` çapraz-köken kaynakları kimlik bilgisiz çekerek CORP şartını gevşetir; bu ADR'nin kapsamındaki tüm alt kaynaklar **aynı kökendedir** ⇒ gevşetmenin kazancı yok, davranış farkı **ölçülmemiş** olurdu |
| `moveExistingIndexedDbToOpfs: true` (bayrak yolu) | 🔴 **ÖLÇÜLEREK ÖLÜ** | `drift_flutter 0.3.1` bayrağı **geçirmiyor** ve pub.dev `/api` ölçümü `latest = 0.3.1` diyor ⇒ **sürüm yükseltme yolu yok** |
| `T5` — koşullu import + dosya bölmesi (`WasmDatabase.open` doğrudan) | 🔴 **ERTELENDİ** (`K158`, Onur kilitledi) | Bedeli gerçek (dosya bölmesi · VM'de derlenmeme · `W2`'nin `onResult` dikişi), kazancı **teorik** (sahada kullanıcı yok) |
| İstemciyi **ayrı kökenden** sunmak (ayrı statik host / CDN) | 🔴 **REDDEDİLDİ** | İzolasyon iddiasını **çürütür**: başlıklar yalnız kendi kökenlerini izole eder. o62'nin beyan edilmiş sınırı tam buydu |
| Başlıkları yalnız `Development`'ta açmak | 🔴 **REDDEDİLDİ** | Kalıcılık yolu ortama göre değişirdi ⇒ üretimde **ölçülmemiş** davranış; ayrıca `Program.cs`'te üçüncü `IsDevelopment()` bloğu (o60 `BLOKER-3`) |
| Başlıkları doğrudan yazmak (`OnStarting` yerine) | 🔴 REDDEDİLDİ | `UseExceptionHandler` hata yolunda yanıtı temizleyebilir ⇒ başlık **sessizce düşer**. 🔴 Gerekçe **okunarak** yazıldı, **mutantla kanıtlanmadı** |
| CI'da kapıyı **koşmamak** | 🔴 REDDEDİLDİ (§2.H) | Bayrak unutulursa izolasyon **sessizce** kırılır ve bunu gören kapı **yok** |

---

## 6. Riskler ve açık noktalar

### R1 🔴 `K61` ↔ WebSocket — web'de gerçek zamanlı işbirliğinin **bloker adayı** (`B-O62-7`)

**Ölçüldü** (`01` `F/5`): izole bir belgeden `POST /hubs/sync/negotiate` **200** döner ve
`connectionToken` gelir; ama `new WebSocket(...)` **iki denemede de başarısız**:

> `WebSocket connection to 'ws://127.0.0.1:5298/hubs/sync?id=…' failed: HTTP Authentication failed;
> no valid credentials available`

🔴 **POZİTİF KONTROL — sebep COOP/COEP DEĞİL.** Aynı ölçüm izolasyon **kapalıyken** tekrarlandı:
negotiate **200**, WebSocket yine **başarısız**, konsol hatası **birebir aynı**.
⇒ **Yeni ara katman SignalR'ı BOZMUYOR.**

**Gerçek sebep bir ÜRÜN sınırıdır:** `K61` kalkanı `X-Momentum-Dev-User` **başlığını** istiyor;
tarayıcının `WebSocket` yapıcısı **özel başlık ekleyemez**. Bugüne kadar görünmemesinin sebebi de
ölçülmüştü: SignalR **web'de `kIsWeb` ile KAPALI**, mobilde Dart istemcisi başlık **ekleyebiliyor**.

**KARAR (Onur, 8 Ağu 2026): AÇIK RİSK olarak yazılır, çözüm ERTELENİR.** Bu ADR'nin konusu izolasyondur;
kimlik taşıma yolu ayrı bir karardır. **Bugün bloker değildir** (web'de SignalR zaten kapalı);
**gerçek zamanlı işbirliği web'e açıldığı anda bloker OLUR.** `B-O62-7` açık kalır.
🔴 `ServerSentEvents`/`LongPolling` transportlarının izole belgeden davranışı **ÖLÇÜLMEDİ** — ikisinin de
fetch tabanlı olduğu için başlık taşıyabileceği bir **tahmindir**, ölçüm değil.

### R2 🔴 Güvenli bağlam kapı tarafından ölçülemez (`B-W3-3`)

`192.168.x.x` gibi bir adresten açılan sayfa **güvenli bağlam değildir** ⇒ sessizce izolasyonsuz kalır ve
**hiçbir kapı kırmızı vermez**. Emülatör/LAN testlerinde bu tuzağa dikkat.

### R3 🔴 Üretim dağıtım topolojisi bu dilimde **YOK**

Ters vekil / CDN / ayrı statik host COOP/COEP'i **ezebilir** ve bu **ölçülmez**. HTTPS/WSS altında
**hiçbir ölçüm yapılmadı**; hepsi düz `http`/`ws`.

### R4 🟡 Regresyon koruması dar (`B-W3-1`)

Birisi `require-corp`'u `credentialless` yaparsa `G44/b` yakalar; ama **drift'in fiilen hangi API'yi
seçtiğini hiçbir otomatik kapı görmez.** §2.H'nin CI kapısı **başlıkları** ölçer, **seçimi** değil.

### R5 🟡 `/scalar/v1` bir üst sürümde CDN'e dönebilir

`F/4` hükmü `@scalar/api-reference@1.62.9` içindir; Scalar CDN'e dönerse hüküm **bayatlar** ve
`izolasyon-olc.py` bunu **ölçmez** (`/scalar/v1`'i kapsam alan ayak **yok**).

### R6 🟡 `index.html` `no-store` göndermiyor (`B-O63-4`)

SPA kabuğu önbelleğe girebilir ⇒ kullanıcı bayat kabukla kalabilir. **Ölçülmedi ve karar verilmedi.**
*(Ölçüm tarafında bu tuzak fiilen ısırdı: o62'de kalıcı profil + önbellek yüzünden izolasyon kör ölçüldü.)*

### R7 🟡 Gölgeleme ve liste tazeliği kapısız (`B-O63-1`, `B-O63-3`)

İstemci kökünde `v1`/`health`/`hubs`/`scalar` **adında bir dosya** bulunursa uç nokta gölgelenir —
ölçüm **bir kez** koştu, mekanik kapı **yok**. `SpaDisiOnEkler` listesine yeni bir kök yol
(örn. `/metrics`) eklenirse liste **sessizce bayatlar**.
🔴 Bu iki ayağın taslağı yazıldı, **denetimde düştü (16 bulgu)** ve `araclar/`'a **konulmadı** (`B-O63-5`).

---

## 7. 🔴 BEYAN EDİLMİŞ SINIRLAR — *"neyi ölçmüyoruz"*

`GOREV-W3` §8 ve `KANIT/W3/00`–`05`'in *"NE ÖLÇÜLEMEDİ"* listelerinin birleşimi. **Bu bölüm boş olamaz.**

1. 🔴 **Onur'un Windows makinesinde HİÇBİRİ koşmadı.** `verify.ps1` + 120 test bu değişikliklerle
   **koşulmadı** (`B-O62-2`, **dördüncü** oturumdur açık). Buluttaki *"0 uyarı"* ve *"120/120"*
   **Linux ölçümleridir**.
2. 🔴 **Flutter yama farkı:** ölçümler **3.44.9**, depo **3.44.6** diyor. Farkın etkisi **ölçülmedi**.
3. 🔴 **PostgreSQL yoktu** ⇒ `/v1/**` uçlarının **200 gövdesi hiç görülmedi**; yalnız *gölgelenmedikleri*
   ölçüldü. Çevrimdışı/OPFS akışı, drift senkronu, gerçek CRUD **hiç egzersiz edilmedi**.
4. 🔴 **`gstatic.com` CORP'u DOĞRUDAN ölçülmedi** (konteynerin dış ağı kapalı). §2.E mekanizmayı **yerel
   ikinci kökenle** kanıtlar. 🟢 o63 denetçisi ayrıca `fonts.gstatic.com`'un bugün `CORP: cross-origin` +
   `ACAO: *` taşıdığını **ölçtü** ⇒ o kaynak geçer; ama **göndermeyen her kaynak sessizce ölür**.
   `--no-web-resources-cdn` şartı bu belirsizliğin **güvenli tarafıdır**.
5. `fonts.gstatic.com` istekleri **kalır** (`B-W3-2`). Çevrimdışı ilk açılışta font düşer;
   uygulama **çalışır**, tipografi geri düşer. Ölçüldü, kabul edildi.
6. 🔴 **Service worker** `require-corp` altında **ÖLÇÜLMEDİ** (`B-W3-4`).
7. 🔴 **CORP alt kaynak davranışı yalnız `<img>` (`no-cors`) ile ölçüldü.** `fetch`/`script`/`worker` için
   **ölçülmedi**; aynı davranışı beklemek bir **tahmindir**.
8. 🔴 **`opfsShared` hiçbir koşumda görülmedi** — `dedicatedWorkersInSharedWorkers` her koşumda eksikti.
   Ölçülen **`opfsLocks`**'tur. Headless Chromium kaynaklı olabilir — **ölçülmedi**.
9. 🔴 **Tarayıcı çeşitliliği YOK** — yalnız Chromium. **Firefox/Safari ölçülmedi.**
10. 🔴 **SATIR DÜZEYİNDE KULLANICI VERİSİ ölçülmedi.** *"Kullanıcının görevleri kayboldu mu"* sorusu
    **açık**; ölçülen *"depo hangi tarafta"* sorusudur. (Flutter web **CanvasKit** ile çiziyor, DOM'da
    tıklanacak öğe yok, semantics açılmadı.)
11. 🔴 **`B-11` — göç atomik değil** (`B-O62-8`): göç **hiç başlamadığı** için hâlâ ölçülmedi.
12. 🔴 **`/v2` ailesi gerçekten kullanıma açıldığında** fallback'in onu gölgelemediği **ölçülmedi**;
    bugün `ApiVersionSet` yalnız `1.0` ilan ediyor.
13. 🔴 **`OnStarting` kararının hata yolundaki üstünlüğü mutantla kanıtlanmadı** (§2.A/1).
14. 🔴 **`G44/g` yorum atıcısı tam bir C# parserı DEĞİLDİR** (`B-W3-5`).
15. 🔴 **Ölçüm koşucuları Onur'un diskine YAZILMADI** — bulut konteyneri oturumla kaybolur.
    `KANIT/W3/04` §8 tanımları yeniden üretmeye yeter; kalıcılaştırma kararı **alınmadı**.
16. 🔴 **Windows/NTFS davranışı hiç ölçülmedi** — hepsi Linux/ext4.

---

## 8. İlgili

- `ADR 0001` §D (API biçimi, sağlık, versiyon) · §H (ısıran kapı doktrini)
- `ADR 0002` §G (gerçek-zaman: sinyal + pull) — R1 oraya dokunur
- `GOREV-W1-web-yuruyen-iskelet.md` (`D-W1-1` yapılandırmadan yol · `D-W1-3` `UseCors` konumu)
- `GOREV-W2-depolama-gorunurlugu.md` §2 (bu ADR'yi doğuran madde)
- `GOREV-W3-capraz-koken-izolasyonu.md` §8 (beyan edilmiş sınırlar — §7 onu kapsar)
- `KANIT/W3/00`–`05` (bütün ölçümler) · `KANIT/W3/06-KAPI-TASLAGI-DENETIMDE-DUSTU-o63.py` (düşen taslak)
- Borçlar: `B-W1-*` · `B-W3-1`…`5` · `B-O62-2`, `B-O62-3`, `B-O62-7`, `B-O62-8` · `B-O63-1`…`6`
- Kilitler: `K61` (dev-kimlik kalkanı) · `K148`/`K148-b` · `K151` · `K154` · `K158` · `K159`/`K159-b`/`K159-c` ·
  `K161`/`K161-b` · `K162`
