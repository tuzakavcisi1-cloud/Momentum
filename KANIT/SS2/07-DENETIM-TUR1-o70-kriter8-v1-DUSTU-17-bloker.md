# DENETİM TUR 1 — `SS2` kriter 8 iş emri **v1 DÜŞTÜ** (o70)

**Denetlenen:** `KANIT/SS2/06-IS-EMRI-o70-kriter8-UCTAN-UCA-v1.md` (9.865 b · sha8 `0794327F`)
**Zamanlama:** `K127` — **kilitten ÖNCE**. **Tur sayısı:** 1 (`K53`/1 tavanı).
**Denetçiler:** iki **bağımsız**, **taze bağlamlı** ajan (`K26` — üreten ≠ denetleyen).
- Denetçi 1 — doğruluk/doktrin ekseni · agentId `a80452b98a6e0155c` · 152.468 token · 11 araç çağrısı
- Denetçi 2 — red-team / koşulabilirlik ekseni · agentId `aa07164ba943b4046` · 155.345 token · 8 araç çağrısı

**HÜKÜM: 🔴 v1 DÜŞTÜ — 17 bloker · 19 major · 13 minor.**
Örtüşme yüksek (ikisi de bağımsız olarak aynı beş çekirdek boşluğu buldu) ⇒ bulgular **gerçek**.

---

## 1. MİMARİYİ DEĞİŞTİREN BLOKERLER (`K53`/1 gereği ikinci turu meşru kılan sınıf)

| # | bulgu | neden bloker |
|---|---|---|
| **B-A** | **Senaryonun 0. adımı YOK** — "B'de *görevin* başlığı `B1` yapılır" deniyor ama o görevin **iki istemcide de var ve senkron olduğu** şart koşulmuyor. | Görev B'de yoksa çekiş `G32/f` **INSERT dalına** düşer ⇒ **0 kayıt** ⇒ kriter 5 kırmızı ve **ürün kusuru sanılır**. Bu, v1'i düşüren `Ö8`/BLOKER-5 sınıfının **aynısı**. Ayrıca B'nin kuyruğunun başlangıçta **boş** olduğu da ölçülmüyor. |
| **B-B** | **İki istemcinin AYNI backend'e baktığı kurulmuyor.** Sunucu tarafı çözülmüş (`0.0.0.0`), **istemci** tarafı hiç konuşulmamış. | Emülatör `10.0.2.2:5298`, Chrome `localhost:5298` — taban URL'nin nasıl verildiği (sabit / `--dart-define` / ayar) belgede yok; kanıtta *"A ve B aynı sunucuya konuştu"* ölçümü yok. Tur sessizce boş döner. |
| **B-C** | **`dotnet run` `--no-launch-profile` taşımıyor.** | `Properties/launchSettings.json`'ın `applicationUrl`'ü kalıtılan `ASPNETCORE_URLS`'i **ezebilir** ⇒ backend `localhost`'a bağlanır, **emülatör hiç ulaşamaz**. Kapı da kör: ölçüt 1 `netstat` topluyor ama **bağlanılan adresi** kontrol etmiyor. |
| **B-D** | **İstemcinin iç durumu (`clientId` · kuyruktaki `bekliyor` op · HLC) için TEK okuma komutu yok.** | Dört kabul ölçütü bunu istiyor ⇒ üçü de bir `.txt`'ye **elle yazılarak** geçilebilir. *"Ortam kuruldu, senaryo koştu"* diyen elin geçeceği tam da bunlar. `K26`'nın bağımsızlığı **kâğıt üstünde** kalır. |
| **B-E** | **`S6` DOKTRİN İHLALİ** — kilitli spec §8 birebir: *"Kriter 8 **Android** üzerinde koşar."* v1 *"ikinci emülatör **YA DA** `flutter run -d chrome`"* yazıyor. | Web şıkkı kilitli sınırla çelişir **ve** zincir sürükler: CORS (`W1`, `B-W1-5` kapısız) · rastgele `--web-port` · drift web varlıkları · `--no-web-resources-cdn` `[DOĞRULANMADI]` · `kIsWeb` ile **SignalR KAPALI** (A kendiliğinden senkron olmaz). |

## 2. DİĞER BLOKERLER

| # | bulgu |
|---|---|
| **B-F** | **HLC garantisi ölçülmüyor, varsayılıyor.** *"A'nın B'yi yenmesi garanti edilir"* deniyor ama HLC'nin **nereden okunacağı** yazılı değil; damgalamanın **istemcide** olduğu varsayımı ne yazılı ne ölçülü. Sunucuda damgalanıyorsa **B kazanır** ve çekilen değişiklik B'nin kendi echo'sudur ⇒ `D-SS2-3/3` echo elemesi ⇒ **0 kayıt**. |
| **B-G** | **"Senkronize olur" / "bir tur koşar" tetikleyicisi yazılı değil ve pencere TEK ATIMLIK.** Bu projede **yoklama YASAK** (`K68`) ⇒ tur olaya bağlıdır. B'nin turu bittiği an op kuyruktan düşer, `bekleyenYerelYazimVarMi` sonsuza dek `false` olur; **kaçırılan pencere geri gelmez** ve yeniden kurma yordamı yok. |
| **B-H** | **Çevrimdışılık ne güvenilir ne ölçülüyor.** `svc wifi disable` AVD'de tipik olarak yalnız Wi-Fi'ı düşürür; emüle radyo/NAT ayakta kalabilir. Ölçüt 3 (*"op kuyrukta `bekliyor` görünüyor"*) **çevrimiçiyken de YEŞİL verir** — hedeflediği kusur varken susuyor ⇒ **kör kapı**. |
| **B-I** | **Arayüzü KİM, NASIL sürecek yazılmıyor.** `adb shell input tap` koordinat ister; koordinatın kaynağı (`uiautomator dump`) yalnız **kanıt** olarak anılıyor, **sürücü** olarak değil. |
| **B-J** | **`uiautomator dump` Flutter'a kör olabilir ve pozitif kontrolü yok.** Flutter tuvale çizer; semantik ağaç yalnız erişilebilirlik açıkken yayılır. `ORTAM.md`'nin *"`findstr` ile YOKLUK ölçen her ayak pozitif kontrol koşmak ZORUNDADIR"* dersinin **aynısı** burada tekrarlanıyor. |
| **B-K** | **Kanıt hiçbir ağaca/commit'e çivilenmiyor.** Emülatörde aylar önce kurulmuş bir APK koşarken kriter 8 YEŞİL verebilir. Emsal hüküm (`KANIT/SS2/05`) bunu **birebir yapmıştı**: *"`git diff -- src/client` boş ⇒ ölçülen ağaç = `2710db0`"*. v1 bu disiplini **düşürmüş**. |
| **B-L** | **Üç uzun ömürlü süreç var, süreç yönetimi yok.** `dotnet run` + iki `flutter run` ön planda ve süresiz koşar; *"ayrı pencerede"* deniyor ama **pencerenin nasıl açılacağı** yazılmıyor, `$env:` atamalarının çocuk sürece nasıl geçeceği yazılmıyor, **kabuk cinsi beyan edilmemiş** (`$env:` yalnız PowerShell sözdizimidir). |
| **B-M** | **TAVAN sayı olarak hiç verilmemiş ve HİÇBİR başarısızlık yolu yazılı değil.** Dört yerde *"yoklanır, tavanlı"* yazıyor; kaç deneme / kaç saniye / tavana çarpınca ne yapılacağı **hiçbirinde yok**. `docker inspect '{{.State.Health.Status}}'` konteynerde **HEALTHCHECK tanımlı değilse** sonsuza kadar `<no value>` döner. |
| **B-N** | **`flutter test` mayını §0 tablosunda YOK.** `ORTAM.md`: *"`flutter test` Desktop Commander kabuğunda ÇÖKÜYOR — `%PROGRAMFILES(X86)% environment variable not found` ⇒ alt sürece enjekte et."* Ölçüt 7 *"taban 549, düşemez"* dediği için çöküş **regresyon** diye okunur. |
| **B-O** | **Prob kimliği ölçülüyor, İSTEMCİLERİN kimliği ölçülmüyor.** `UserId` ⟂ `ClientId` (`K61`). A ve B **farklı `UserId`** taşırsa birbirinin görevini **hiç görmez** ve ⑤–⑦ sessizce boş üretir. |

## 3. MAJOR (seçilmiş — tamamı ajan çıktılarındadır)

- **M-1** Belgeye **`Taban HEAD: 79c208c`** ve **`R8 KIRMIZI`** yazılmış. `DURUM.md` §2/7: *"Son commit ve push durumu **hiçbir belgeye YAZILMAZ**, burada ÖLÇÜLÜR (K82-b)"* · §3: *"**`R8` DURUMU DA YAZILMAZ, ÖLÇÜLÜR**"*. **Doktrin ihlali.**
- **M-2** **549 tabanı Linux/bulut hükmünden kopyalanıp Windows eşiği yapılmış.** Kaynak `KANIT/SS2/05` kendi sınırını beyan etmişti (*"Windows koşumu ÖLÇÜLEMEDİ"*); `DURUM.md` §3 hâlâ **539/539** diyor. `ORTAM.md`: *"Kapı hükmü, koştuğu ortamın hükmüdür."* ⇒ `bayat-iddia` + `kanonik-kopya`.
- **M-3** `flutter.bat`/`adb` §0'da *"tam yol"* denip §1–§3'te **çıplak adla** çağrılıyor. `DURUM.md`: *"çözülemeyen ad, sessizce atlanan adımdır."*
- **M-4** **`verify.ps1` satırı ÖLÜ** — §0'da ilan edilmiş, hiçbir adıma/dosyaya/ölçüte bağlanmamış; **backend'i kapatan adım YOK** ⇒ tur bitince ayakta kalır, bir sonraki `verify.ps1` **36 `MSB3026`** ile düşer.
- **M-5** **Ham çıktının kodlaması/satır sonu yazılmamış.** PowerShell 5.1 `>` ile **UTF-16LE** üretir; python stdout **cp1254**. Kanıt okunamaz inebilir ve hükmü veren el kanıtı okuyamaz.
- **M-6** **Backend logu kanıt listesinde YOK** — oysa `clientId`/HLC/"aynı sunucu" için **en ucuz, en bağımsız** kanıt odur; v1 backend penceresinin çıktısını **çöpe atıyor**.
- **M-7** **Ölçüt 1 tek cihazla geçiliyor** (*"`adb devices` cihazı gösteriyor"* — tekil), oysa iki istemci isteniyor.
- **M-8** **`S5` ve `S11` §6'da beyan edilmemiş.** `S5`: rozet **iki farklı olayı** aynı ikonla gösterir ⇒ ölçüt 5'in rozet ayağı tek başına **belirsizdir**. `S11`: iç içe transaction `[ÖLÇÜLMEDİ]` ve ölçüt 6 tam o yolu koşuyor.
- **M-9** **`K149`/2 ve commit-sonrası pazarlıksız kontrol atlanmış** (`git config user.email` ölçümü · `status --porcelain` + `Test-Path .git\index.lock`).
- **M-10** **Adım ④'ün ön koşulu ölçülmüyor:** başlık düzenleme UI'ı (`K174`, commit `2710db0`) taban HEAD'de var mı? `merge-base --is-ancestor` ile ölçülmeli.
- **M-11** **Saat kayması ele alınmamış.** İki yazım birbirini görmeden bağımsız damgalarla doğar; emülatör anlık görüntüden dönünce saat kayması olağandır ⇒ **yanlış taraf kazanabilir** ve sebebi ortamdır.

## 4. MINOR (seçilmiş)

`m-1` ölçüt 7'de *"0 fail · EXIT 0"* yok, yalnız sayı eşiği · `m-2` `flutter test`in **çalışma dizini** yazılmamış · `m-3` `docker inspect --format` hangi kabukta koşacağı yazılmamış (tırnak davranışı `cmd` ↔ PowerShell'de farklı) · `m-4` kanıt başlıklarındaki *"ne zaman"*ın **cihazdan** ölçüleceği yazılmamış (`ORTAM.md`'nin UTC maddesi) · `m-5` `netstat | findstr` pozitif kontrol taşımıyor (boş dönerse *"kapalı"* mı *"kör"* mü ayrılamaz) · `m-6` `flutter emulators` **sıfır AVD** listelerse ne yapılacağı yazılmamış · `m-7` `KANIT/A11/_backend_dogrula.py`'nin **varlığı ölçülmeden** kullanılıyor · `m-8` `cmd /v:on` mayınının iki tamamlayıcı yarısı düşmüş (`adb shell` içinde `^|` cihazda çalışır, cihazda `findstr` **yoktur**) · `m-9` `R8`'in **birikeceği** yazılmamış.

---

## 5. NE ÖLÇÜLEMEDİ — **iki denetçinin de zorunlu bölümü** (`K127` + araştırma teslim kapısı)

Denetçilere yalnız şunlar verildi: `CLAUDE.md` · `DURUM.md` · `ORTAM.md` · `GOREV-SS2` · `KANIT/SS2/{05,06}` · `araclar/oturum-sagligi.py`. **`src/` ve `.git` VERİLMEDİ.** Bunun bedeli:

- **İstemci kaynağı okunmadı** ⇒ şunların hiçbiri ölçülmedi, **hepsi gerekçeli şüphedir**: taban URL'nin nasıl verildiği · istemcinin `X-Momentum-Dev-User` gönderip göndermediği · `clientId`'nin nerede saklandığı · HLC'nin **istemcide mi sunucuda mı** damgalandığı · senkron turunun hangi eylemle tetiklendiği · uygulamanın semantik ağacı yayıp yaymadığı.
- **`.git` yok** ⇒ `79c208c`'nin HEAD olduğu ve `2710db0`'ı içerdiği **doğrulanamadı**.
- **`radar.py` / `PROJE_RADAR.jsonl` yok** ⇒ denetçi `R8`'in rengini **kendisi ölçemedi**; M-1'i yalnız `DURUM.md` satır 5'in kayıtlı o69 ölçümüyle karşılaştırdı.
- **`KANIT/A11/_backend_dogrula.py` açılamadı** ⇒ var olduğu, argümanları, GUID `clientId` ürettiği **VAR SAYILMADI**.
- **Cihaz/ağ tarafında hiçbir ölçüm yapılmadı** ⇒ `momentum-postgres`'in HEALTHCHECK taşıyıp taşımadığı · `launchSettings.json`'ın `applicationUrl` taşıyıp taşımadığı · `svc wifi disable`'ın `10.0.2.2` rotasını kesip kesmediği · `uiautomator dump`'ın Flutter metnini gösterip göstermediği · `flutter test`'in Claude Code kabuğunda çöküp çökmediği — **beşi de ÖLÇÜLMEDİ**; v2 bunları **ölçüm adımı** olarak taşımalıdır.
- **`PROJE_HAFIZA.md` · `BORCLAR.md` · `KAPILAR.md` açılmadı** (`K53`/`K83` gereği) ⇒ `B-O63-2`, `B-W1-5`, `B-SS2-*` metinleri okunmadı.

🔴 **Bu bölümün kendisi bir bulgudur:** denetim `src/`siz koştuğu için **beş bloker mekanizmadan türetilmiş şüphedir, ölçüm değildir** (B-B · B-D · B-F · B-G · B-J). v2 bunları *"ölçülecek adım"* olarak taşır, *"bilinen kusur"* olarak **değil**.

---

## 6. ONUR'UN ÜÇ KİLİDİ (denetimden SONRA, v2'nin girdisi)

1. 🔒 **Topoloji: İKİ ANDROID EMÜLATÖR** — `S6` kilidine uyulur, web şıkkı **düşer**. Ön koşul (ikinci AVD var mı, iki emülatör aynı anda kalkar mı) **v2'de ölçüm adımıdır**; kalkmıyorsa **DURULUR**.
2. 🔒 **İç durum BACKEND İSTEK LOGUNDAN okunur** — `clientId` ve HLC zaten teldedir; **ürün koduna dokunulmaz**, cihaz içine girilmez ve iki istemcinin **aynı sürece** konuştuğu aynı anda kanıtlanır.
3. 🔒 **UI'ı ONUR sürer, Claude Code yalnız ölçer** — pencere **tek atımlıktır**; v2 *"pencere kaçarsa adım 0'dan başlanır"* yordamını taşır.

**Sonuç:** `K53`/1 gereği tur 1 **mimariyi değiştiren** blokerler buldu (B-A · B-B · B-D · B-E) ⇒ **v2 yazılır ve ikinci tur MEŞRUDUR.**
