# W3 — KİLİT ÖNCESİ BAĞIMSIZ DENETİM (K127), oturum 60

**Denetlenen:** `GOREV_CLAUDE_CODE/GOREV-W3-capraz-koken-izolasyonu.md` **v1** (18.233 b),
Cowork yazdı. **Denetçiler: iki bağımsız ajan** (K26 — üreten ≠ denetleyen); ikisi de
spec'i yazmadı, ikisi de kendi lensiyle çalıştı ve **birbirini görmedi**.

- **Denetçi A — mimari/doğruluk:** 4 BLOKER · 9 MAJOR · 6 MINOR. Birincil kaynak okudu
  (drift 2.34.3 ve drift_flutter 0.3.1 paket arşivleri, ASP.NET Core `main`, Flutter engine),
  **9 canlı HTTP başlık ölçümü** koştu.
- **Denetçi B — kapı/mutant red-team:** 6 BLOKER · 15 MAJOR · 6 MINOR.

🔴 **HÜKÜM: v1 KİLİTLENEMEZ.** İki denetçi **bağımsız olarak** iki kusurda buluştu
(`MapFallbackToFile` sırası · `G45/a` tatmin edilemezliği) — yakınsama, bulgunun gücünü artırır.

---

## YAKINSAYAN BULGULAR (iki denetçi ayrı ayrı buldu)

### Y1 — `M224` ÖLÜ MUTANT ve `D-W3-1`'in "PAZARLIKSIZ sıra" gerekçesi YANLIŞ
`dotnet/aspnetcore` `FallbackEndpointRouteBuilderExtensions.cs:79` birebir:
`conventionBuilder.Add(b => ((RouteEndpointBuilder)b).Order = int.MaxValue);` ve
`Matching/EndpointComparer.cs:29-32` — uç nokta seçimi **kayıt sırasına değil `Order`'a** bakar.
⇒ `MapFallbackToFile`'ı API eşlemelerinden öne almak **hiçbir şeyi değiştirmez**; `G46/d`
YEŞİL kalır, `M224` **ısırmaz**. Spec, gerçekleşmesi imkânsız bir tehlikeye "PAZARLIKSIZ"
damgası vurmuş. Ayrıca `D-W3-6` taksonomisinde **"ölü mutant ⇒ kusur MUTANTTA"** sınıfı **YOK**;
mevcut hâliyle bu vaka yanlışlıkla "kör kapı ⇒ BLOKER" diye sınıflanır.

### Y2 — `G45/a` TATMİN EDİLEMEZ; kabul kriteri 4 ile §8/2 birbirini yalanlıyor
Flutter engine `configuration.dart:362-368` birebir:
`String get fontFallbackBaseUrl => _configuration?.fontFallbackBaseUrl ?? 'https://fonts.gstatic.com/s/';`
⇒ dizge motorda **derlenmiş sabittir**, `--no-web-resources-cdn` (yalnız CanvasKit'i yerelleştirir,
`flutter_command.dart:1511`) onu **çıkarmaz**. `fonts.gstatic.com` ⊃ `gstatic.com` ⇒ `G45/a`
**her zaman KIRMIZI** ⇒ §7/4'ün `EXIT 0` şartı **hiçbir zaman** karşılanamaz.

---

## BLOKERLER

### B1 🔴 DİLİM HEDEFİNE ULAŞMAYABİLİR — ÖLÇÜLEREK DOĞRULANDI
`drift 2.34.3` `lib/wasm.dart` `WasmDatabase.open`, birebir:
```
bool moveExistingIndexedDbToOpfs = false,   // <- varsayilan
...
if (!didMove) {
  selectedImplementation = availableImplementations.firstWhere((e) => e.storageApi == currentDb);
}
```
Kaynaktaki yorum: *"If we have an existing database in storage, we want to keep using that
format to avoid data loss."*
`drift_flutter 0.3.1` `lib/src/web.dart:19` bu bayrağı **geçirmiyor**; `DriftWebOptions`'ın
alanları yalnız `sqlite3Wasm`, `driftWorker`, `onResult`, `initializeDatabase` ⇒ **geçirecek alan YOK.**

🔴 **COWORK'ÜN DOĞRULAMASI (bu oturumda, cihazda ölçüldü):**
`src/client/lib/veri/veritabani.dart` **8.918 b**, satır **180-190**:
`return driftDatabase( name: 'momentum', web: DriftWebOptions( ... onResult: (sonuc) { ...` ⇒
proje **tam da o yolu** kullanıyor. **Denetçinin iddiası KESİN olarak doğrulandı.**

**Sonuç:** Onur'un Chrome profilinde `momentum` adlı IndexedDB veritabanı **zaten var**
(`W1/G37/b` kalıcılığı kanıtladı). COOP/COEP kusursuz olsa, `crossOriginIsolated === true` olsa,
`opfsLocks` uygun hâle gelse bile drift **`sharedIndexedDb`'de kalır**. Kapılar yeşil kapanır,
**ürün davranışı değişmez** — ve `B-W3-1` (tarayıcı ayağı kapsam dışı) bunu **kimseye göstermez.**
Bu, bu projenin en korktuğu sınıftır: kapıların yeşil, ürünün ölü olduğu hâl.

### B2 🔴 §1/2 "ölçülmüş olgu" DEĞİL — ölçüldüğünde TERSİ çıktı
Denetçi A'nın canlı ölçümü (2026-08-05, hepsi HTTP/2 200):
`www.gstatic.com/flutter-canvaskit/*/canvaskit.js` · `canvaskit.wasm` · `skwasm.js` · `skwasm.wasm`
· `fonts.gstatic.com/s/roboto/*.woff2` — **hepsi `cross-origin-resource-policy: cross-origin`** gönderiyor.
MDN COEP (son değişiklik Mar 6, 2026) birebir: *"Note that requests made in `cors` mode won't be
blocked by COEP or trigger COEP violations..."*
⇒ Spec'in *"require-corp açıldığı anda bloklanır ⇒ çalışan sayfayı kırmaktır"* iddiası **yanlış**.
`D-W3-3` zorunlu bir onarım değil, **isteğe bağlı bir sertleştirmedir** — ve onu kritik yola
koymak `Y2`'yi doğuran şeydir.

### B3 🔴 `T2`'nin build komutu `W1`'in `M197` dersini üründe kalıcılaştırıyor
Spec'in tamamında `dart-define`, `SENKRON_SUNUCU_URL`, `10.0.2.2` dizgeleri **hiç geçmiyor**.
`W1` §2 ölçümü: `_senkronSunucuUrl` varsayılanı **`http://10.0.2.2:5298`** (Android emülatör takma adı).
⇒ `T2` yazıldığı gibi koşulursa `wwwroot/main.dart.js` içine `10.0.2.2` derlenir; sayfa
`localhost:5298`'den izole olarak yüklenir ve **her senkron isteği düşer**. 14 mutantın hiçbiri
bu dala dokunmuyor; `G45/d` kuralı `https://` diye yazıldığı için kaçak `http://` şemasında **kör**.

### B4 🔴 `G44`'ün DOSYA KAPSAMI YOK; kabul komutu `.` (dizin) ⇒ kapı kendi spec'ini ölçer
`G43/a` kapsamı adıyla yazılı (`Program.cs`'te), `G45` kapsamı yazılı (`wwwroot/**`),
**`G44`'ün beş ayağının hiçbirinde kapsam yok.** Spec'in kendi satırları (145, 146, 150) hedef
dizgeleri taşıyor; `T8` onları ADR'ye, §7/12 `KANIT/W3/`'e de yazdıracak. ⇒ `M220`/`M221`/`M223`/`M228`
koşulduğunda dizge başka dosyalarda bulunur, kapı **YEŞİL kalır, mutantlar ölür**.

### B5 🔴 `G44/c` DÖRT AYRI GERÇEK C# YAZIMIYLA SESSİZCE GEÇİLİR
1. ternary (`IsDevelopment() ? "require-corp" : "unsafe-none"` — hiç blok yok, aralık yok)
2. yüklem değişimi (`!IsEnvironment(Environments.Production)` — `IsDevelopment` dizgesi hiç geçmez)
3. yapılandırma anahtarı (`Configuration.GetValue<bool>("Isolation:Enabled")` — ev üslubu `Program.cs:102/115`'te zaten var)
4. ayrı sınıfa taşıma (`app.UseCrossOriginIsolation()` sarmalayıcı `IsDevelopment()` içinde, başlıklar başka dosyada)

Dördü de derlenir, dördü de üretimde başlığı öldürür, dördünde de `G44/c` **YEŞİL**.
🔴 **Ve kaçışı yakalayacak canlı ayak YOK:** `ORTAM.md`:41 canlı koşumu
`ASPNETCORE_ENVIRONMENT="Development"` ile sabitliyor ⇒ `G46` **"her ortamda" iddiasını mantıken
hiçbir zaman yanlışlayamaz.** §8/5 bunu yalnız "ayrıştırma kusuru" olarak beyan ediyor; oysa
yukarıdaki dördü **sözlük kusurudur**.

### B6 🔴 `W1`'in BLOKER-3'ü aynen tekrarlanmış: EL DAĞILIMI tablosu YOK
Spec'te `Claude Code` dizgesi **hiç geçmiyor**; `## 4c` eşdeğeri yok. §7 başlığı *"Cowork **kendi**
koşar"* diyor; ama kriter 6 (`M220`–`M224` — backend yeniden başlatma), kriter 7 (canlı `G46`) ve
kriter 8 (`verify.ps1` için backend kapatma) `K80`'e göre **Cowork'ün yapamayacağı** işlerdir
(`ORTAM.md`:37 birebir: *"Kapatmayı Cowork YALNIZ Onur'un açık izniyle yapar; YENİDEN BAŞLATMAZ"*).
**Spec kendi içinde çelişiyor.**
**Ek:** §4/3 hazır-olma üçlüsünün ayırt edici yarısını (`X-Momentum-Dev-User` ile **200**) düşürmüş
⇒ kısaltılmış üçlü Production'da da geçer, canlı koşumun ortamı **ölçülmemiş olur** (B5'i besler).

---

## MAJOR (seçilmiş; tamamı iki ajan çıktısında)

- **M-1 Güvenli bağlam (secure context) şartı spec'te HİÇ geçmiyor.** MDN `SharedArrayBuffer`
  (Feb 10, 2026) birebir: *"your document must be in a **secure context** and cross-origin isolated."*
  `K80` maddesi `ASPNETCORE_URLS=http://0.0.0.0:5298` diyor ama sayfanın **hangi URL'den açılacağını**
  yazmıyor: `http://localhost:5298` güvenli bağlam, `http://192.168.x.x:5298` **değil** ⇒ başlıklar
  kusursuz olsa bile `opfsLocks` gelmez. `G46` urllib ile ölçtüğü için farkı **göremez**.
- **M-2 Başlık middleware'i ile `UseStaticFiles` SIRASI yük taşıyor, kapısı da mutantı da YOK.**
  `UseStaticFiles` kısa devre eder ⇒ başlıklar sonra kaydedilirse `index.html`'e **hiç yazılmaz**;
  `G44`'ün beşi de yeşil kalır.
- **M-3 COOP'un DEĞERİ hiçbir mutantla ölçülmüyor.** `same-origin-allow-popups` alt-dizge olarak
  `same-origin` içerir ⇒ `G44/a` ve `G46/a` yeşil, ama izolasyon **gelmez** ⇒ dilimin tek amacı kaybolur.
  Spec "değer tam eşitlikle mi alt-dizgeyle mi ölçülür" demiyor.
- **M-4 `--web-header` ALTERNATİFİ HİÇ DEĞERLENDİRİLMEMİŞ.** drift'in **kendi belgesi** bunu öneriyor
  (birebir: *"You can use `flutter run --web-header=Cross-Origin-Opener-Policy=same-origin
  --web-header=Cross-Origin-Embedder-Policy=require-corp`..."*), Flutter kaynağında doğrulandı
  (`flutter_command.dart:276-285`, `run.dart:449`). **Sınırı:** `build_web.dart` `usesWebOptions()`
  çağırmaz ⇒ bayrak **yalnız `flutter run`**'da; üretim çözümü değil, ürün kodu üretmez (`R8`).
- **M-5 `wwwroot` git-ignore ⇒ temiz klonda/CI'da kapılar KIRMIZI.** Spec ne "CI önce build koşar"
  diyor, ne kapıya "yoksa ORTAM HATASI" davranışı tanımlıyor. §8/6 yalnız insan sonucunu beyan ediyor.
- **M-6 Teşhis alıntılanmamış:** bugünkü `chosenImplementation=` / `missingFeatures=` ham satırı
  §1'de yok. `missingFeatures` `workerError` veya `fileSystemAccess` içeriyorsa COOP/COEP **hiçbir
  şeyi değiştirmez.** *(Yönün doğruluğu ayrıca teyit edildi: Chrome'da tek OPFS yolu `opfsLocks`'tur
  ve o çapraz-köken izolasyonu ister — drift belgesi, birebir.)*
- **M-7 `hedef` sütununda YANLIŞ KURAL ATFI:** `M226`/`M228` `D-W3-5`'e atfedilmiş; ikisi de
  `D-W3-5`'in hiçbir iddiasını sınamıyor ⇒ `spec-kapi-kapsama.py` `D-W3-5`'i **"kapsanmış" sayar**
  ve borç yazılmasına gerek kalmaz ⇒ *"eşdeğer mutant kusurdur"* doktrini **kural düzeyinde delinir**.
- **M-8 Hiçbir "SUSMALI" mutantı yok.** `W1` bunu `M191b`/`M193b` ile pinlemişti; `MW21`
  (*"hiçbir değişiklik yok"*) kabul kriteri 4'ün **birebir kopyasıdır**, bilgi katkısı sıfır.
- **M-9 `G43/d` mutantsız VE §6b'de beyansız.** Yer tutucu bir `index.html` üç ayağı birden geçer.
- **M-10 §6b'nin makine-okunur bölümü `W1`'in ayırıcı başlığını kaybetmiş** ⇒ proza maddeleri
  `- KURAL:` satırıyla aynı listede; araç `S4`/`S5` verebilir. *(Cowork ölçtü: `spec-kapi-kapsama.py`
  bugün **EXIT 0** veriyor ⇒ bu MAJOR **fiilen tetiklenmiyor**, ama biçim kırılgan.)*
- **M-11 §7/11 (ADR gövdesi) ölçüm aracı olmayan bir kriter** — *"kural değil dilek"*.
- **M-12 §8/4'teki SignalR riski HAYALET:** web'de SignalR `kIsWeb` ile kapalı (`W1/D-W1-5`),
  tarayıcı dışı istemciler COEP uygulamaz ⇒ ölçülecek yüzey yok.
- **M-13 `wwwroot` TAZELİĞİ ölçülmüyor** ⇒ bayat build üstünde yeşil kabul mümkün.
- **M-14 Altın kümenin İÇERİĞİ yazılmamış** — araç yazarına bırakılmış (`W1` içeriği adıyla pinlemişti).

## MINOR (seçilmiş)
`G46/a` ve `b` durum kodu ölçmüyor (404 da izole olur, kapı yeşil) · `Content-Type: application/wasm`
kapısı yok · `/health/live`'ın Content-Type'ı **ölçülmemiş varsayım** (ASP.NET varsayılanı `text/plain`) ·
§7/2 kendi kuralını çiğneyip **539**'u spec'e kopyalamış · `G43/e` çıplak `wwwroot` deseni ·
`G46/e` `:nonfile` kısıtını yazmıyor · `Permissions-Policy: cross-origin-isolated` üçüncü şartı anılmıyor.

---

## NE ÖLÇÜLEMEDİ

- **Gerçek tarayıcıda hiçbir şey koşulmadı** — her iki denetçi de bunu ilan etti; `B-W3-1` onlar için de geçerli.
- `izolasyon-kapisi.py` ve `_izolasyon_http_olc.py` **henüz yok** ⇒ tüm kapı bulguları **spec'in
  lafzına** dayanıyor, aracın gerçek davranışına değil.
- `Y2` ve `B1`, .NET ve Flutter **koşulmadan**, kaynak okumasıyla kesinleştirildi.
- Bugünkü `chosenImplementation=` / `missingFeatures=` ham satırı **okunmadı** (denetçilere `KANIT/W1`,
  `KANIT/W2` verilmedi) ⇒ `M-6` "eksik alıntı" olarak yazıldı, "yanlış teşhis" olarak değil.
- Chrome'un `crbug.com/1088481` **bugünkü** durumu ölçülemedi (izleyici oturum açma istedi) ⇒
  *"Chrome `opfsShared` yapamaz"* iddiası **yalnız drift'in kendi belgesine** (tedarikçi beyanı) dayanıyor.
  Chrome bunu sessizce eklediyse `opfsShared` tercih edilir ve **COOP/COEP'e hiç gerek kalmaz** —
  yani **dilimin tamamı gereksiz olabilir** ve bu **ÖLÇÜLMEMİŞTİR**.
- Denetçilere `.gitignore`, CI workflow, `HealthEndpoints.cs`, `src/client/**`, `build/web` **verilmedi**
  ⇒ §1/1'in `wwwroot` yokluğu, §1/2'nin üç dosyalık gstatic ölçümü ve §1/3'ün araç yokluğu iddiaları
  **onlar tarafından doğrulanamadı** (Cowork cihazda ölçmüştü; bağımsız teyit YOK).

## EKSİKLİK KRİTİĞİ

- Bu denetim **kâğıt üzerindedir**; ilk canlı koşum her iki denetçiyi de yanlışlayabilir.
- Denetçilere verilen dosya kümesi **dar tutuldu** (4 dosya) ⇒ yukarıdaki "doğrulanamadı" listesi
  bunun **doğrudan bedelidir**. İkinci tur açılırsa `KANIT/W1`, `KANIT/W2`, `.gitignore`,
  `veritabani.dart` ve CI dosyası **verilmelidir**.
- Denetçi B kendi ifadesiyle `G45/c`'yi ayrı bir bulguya dönüştürmedi ve SignalR/service-worker
  ayaklarını **hiç incelemedi**.
- 🔴 **Hiçbir denetçi kendi bulgusunu adjudike etmedi ve etmemeli** — hangi bulgunun bloker
  sayılacağına karar, Onur'un kilidiyle verilir.
