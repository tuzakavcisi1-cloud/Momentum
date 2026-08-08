> # 🔴 BU BİR TASLAKTIR — `K127` DENETİMİ **HENÜZ KOŞMADI** (o65, 8 Ağu 2026)
>
> **`docs/ADR/0004-*.md` DOSYASINA YAZILMADI. KİLİT YOK.** Bu metin, o64'te **denetimde düşen**
> gövdenin (`KANIT/W3/07-ADR0004-GOVDE-TASLAGI-DENETIMDE-DUSTU-o64.md`, 26.553 b · `0C46C8F9`)
> onarımıdır. Onarımı **o65 eli** yaptı; üreten ≠ denetleyen (`K26`) gereği **yeni bir bağımsız
> denetim turu ZORUNLUDUR** ve o tur koşmadan bu metnin hiçbir iddiası **kabul edilmiş sayılmaz**.
> `K53/1` tavanı aşılmıyor: birinci tur **mimariyi değiştiren** bir bloker buldu (BLOKER-2, CI kararı)
> ⇒ ikinci tur **meşru ve zorunludur**.
>
> **Onarım haritası §0'dadır** — hangi bulgunun nerede ve nasıl kapandığı denetçinin izleyebilmesi
> için tek tabloda verilmiştir. Kapanmayan bulgular da **adıyla** yazılıdır.

---

# ADR 0004 — Web Çapraz-Köken İzolasyonu (COOP/COEP) ve OPFS **İMPLEMENTASYON SEÇİMİ**

- **Durum:** 📝 **TASLAK v2 — denetim bekliyor.** Kilit YOK.
- **Tarih:** 2026-08-05 (iskelet, o59) → 2026-08-08 (gövde v1, o64, **düştü**) → **2026-08-08 (gövde v2, o65)**
- **Kaynak dilim:** `GOREV-W2-depolama-gorunurlugu.md` §2 · yürüyen iskelet
  `GOREV-W3-capraz-koken-izolasyonu.md`
- **Yerini aldığı metin:** bu dosyanın **iskelet** hâli (**3.656 b**, o59; diskten ölçüldü). O metin
  karar içermiyordu ve beş açık sorusu vardı; **`[ÖLÇÜLMEDİ]` damgası bu beş sorunun ÜÇÜNDE
  geçiyordu** (sorular 1, 2, 4 — iskelet dosyası üzerinde sayıldı). Beşinin de **yanıtsız** olduğu
  doğrudur, ama *"beşi de damgalıydı"* **yanlıştı** ve v1'in ilk cümlesinde duruyordu.

> 🔴 **BU ADR'DEKİ HİÇBİR SAYI BEYAN DEĞİLDİR.** Her iddia bir `KANIT/W3/**` dosyasına ve o dosyadaki
> koşuma dayanır. Ölçülmemiş olan **"ÖLÇÜLMEDİ" diye yazılıdır ve yeşil sayılmaz.**
> 🔴 **ÖLÇÜMLERİN ORTAK SINIRI:** aşağıdaki ölçümlerin **hepsi** Cowork'ün **bulut konteynerinde**
> (Linux, .NET SDK `10.0.302`, headless Chromium/Playwright, **Flutter 3.44.9**) koştu.
> **Onur'un Windows makinesinde hiçbiri koşmadı** ve depo `DURUM.md` Flutter **3.44.6** diyor —
> **yama farkı vardır, etkisi ölçülmedi.** `K80` Onur'un makinesi için aynen ayaktadır.
> 🔴 **KAYNAK SPEC'İN STATÜSÜ:** `GOREV-W3` **v2 KİLİTLENMEDİ** — spec v1 `K146`, **v2 `K150`** ile
> denetimde **düştü** (`DURUM.md` §4/⑫). Bu ADR'nin §7'si o spec'in §8'ini kaynak alır; **kilitli bir
> belgenin sınırları değil, REDDEDİLMİŞ bir taslağın sınırlarıdır.** Buna rağmen kullanılmasının
> gerekçesi: `K162` ile **spec §8'e yazılan iki beyan** (`K158` ve `K159-b`) Onur'un kilitleridir ve
> spec'in reddi o iki maddeyi **düşürmez**. Geri kalan maddeler **taslak statüsündedir.**

---

## 0. ONARIM HARİTASI — o64 denetiminin 6 bloker + 13 major'ı

> Denetçiler: **A** (`aecafd5ecb646f518`, kör nokta/çürütme merceği) · **B** (`a825b59210dbebfc6`,
> aşırı-iddia/iç çelişki/kilit çatışması merceği). Tam metin: Cowork projesi
> `oturum-64-ADR0004-govdesi-DENETIMDE-DUSTU.md`.

| bulgu | nerede kapandı | nasıl |
|---|---|---|
| **BLOKER-1** `--no-web-resources-cdn` gerekçesi çürütülmüş | **§2.E** | Çelişki **ilan edildi**; kilit (`K159-b`) **korundu**, gerekçesi **değiştirildi**: COEP bloklaması değil, üçüncü-taraf CORP politikasına bağımlılık + çevrimdışı + tedarik zinciri |
| **BLOKER-2** §2.H'nin CI kararı riski ölçemiyor (kör kapı) | **§2.H** | Karar **korundu**, körlük **beyan edildi**, ve bayrağı **fiilen ölçen** yeni bir statik ayak (`W3/G45/f` adayı) karara bağlandı ⇒ `B-O63-2` kapanış yolu **adlandırıldı** |
| **BLOKER-3** başlıktaki *"OPFS kalıcılığı"* ölçülmemiş | **başlık + §1.2 + §7/10** | Başlık *"OPFS **implementasyon seçimi**"* olarak daraltıldı; ölçülenin bir **seçim beyanı** olduğu ve *"sonraki açılışta OPFS'ten okuma"*nın **ölçülmediği** yazıldı |
| **BLOKER-4** §7 reddedilmiş spec'e dayanıyor, statüsü yazılı değil | **üst blok + §7 girişi** | `GOREV-W3` v2'nin `K150` ile **düştüğü** ve `K162`'nin iki maddesinin ayrık olduğu açıkça yazıldı |
| **BLOKER-5** teslim tasarım = spec'in kendi mutantı (`M230`) | **§2.A/3 (yeni)** | `W3/G44` kapsamının (*"YALNIZ `Program.cs`"*) bugünkü ürüne karşı **KIRMIZI** vereceği ilan edildi; kapı kapsamının güncellenmesi **karara bağlandı** |
| **BLOKER-6** `B-O63-6` listelenmiş ama açılmamış | **§6/R8 (yeni)** | *"vaka ölçmek sınıf kapatmaz"* borcu, bu ADR'nin **ana dersi** olarak açıldı ve iki somut açık vakası yazıldı |
| A-7 / B-15 `128 satır` yanlış adımda | **§2.B + §3** | `04` §1'den ölçüldü: `IstemciServisi.cs` **113 satır**, `Program.cs` **+15**, **toplam 128**. `K55` uyarısı taşındı |
| A-8 §7/1 kendi içinde çelişiyor | **§7/1** | `verify.ps1` **koşmadı** · `dotnet test` **koştu (120/120, bulutta)** — ikisi ayrıldı |
| A-9 / B-7 §7/7 ölü beyan | **§7/7** | `04` §5 `<script>` ile ölçtü ⇒ ölü beyan **silindi**; kalan gerçek boşluk (`fetch`, `worker`) yazıldı |
| A-10 / B-10 §2.F `D-W3-4`'ü adını anmadan tersine çeviriyor | **§2.F** | Çatışma **adıyla** ilan edildi; `W3/G46/c`, `W3/G46/g` ayaklarının ve `M231`/`M239` mutantlarının **ölü** kaldığı yazıldı |
| A-11 / B-16 *"kill switch bedava"* mutantsız | **§2.B/2** | Mutantsızlık **beyan edildi**; boş `Istemci:KokDizin` vakasının **hiç denenmediği** yazıldı |
| A-12 §2.E'nin kaynağı bypass dalı içeriyor | **§2.E** | `canvasKitBaseUrl` dalı **yazıldı**: set edilirse `useLocalCanvasKit`'e hiç bakılmaz ⇒ bayrak tek başına yetmez |
| A-13 `R1`'in kesin gelecek hükmü ↔ *"ÖLÇÜLMEDİ"* | **§6/R1** | *"bloker OLUR"* → *"bloker **olması beklenir** — transport geri düşüşü **ölçülmedi**"* |
| A-14 üçüncü sınıf düşürülmüş + `/scalar/YOK` vakası | **§2.D + §7/12** | `[Route]` öznitelikli controller ve `app.MapGet("/mutlak")` **beyan edilmemiş sınıflar** olarak yazıldı; `/scalar/YOK` → **200 · text/html · 627 B** (kabuk **1.546 B** ⇒ gölgeleme **değil**) ölçümüyle eklendi |
| A-15 `W2` §8'in devrettiği canlı şerit ölçümü yok | **§7/17 (yeni)** | Devir **adıyla** yazıldı, ölçüm **yapılmadı** diye işaretlendi |
| A-16 *"ÖLÇÜLEREK ÖLÜ"* etiketi yanlış | **§5** | → *"**ULAŞILAMAZ** (ölçüldü)"*; ölülük değil **erişilemezlik** ölçüldü |
| A-18 `adr-kapi-taramasi.py` EXIT 1, `'karar': 0` | **§7/18 (yeni)** | Beyan edildi; **beyan edilmiş sınırıyla**: o araç `ADR 0003` kapsamlıdır ⇒ bu bir *"ADR 0004 kapısı düştü"* hükmü **değildir** |
| B-4 *"ayrı köken reddedildi"* gerekçesi yanlış | **§5** | `01` `F/5` ölçümü: ayrı kökendeki probe belgesi **kendi başlıklarıyla** `crossOriginIsolated = true` **oldu** ⇒ gerekçe **değiştirildi** (kontrol edilmeyen ikinci dağıtım yüzeyi + CORS bağı) |
| B-5 §2.C'deki ✅ kod okunarak yazıldı | **§2.C** | ✅ **kaldırıldı**; `D-W1-3`'ün *"korunduğu"* iddiası **okuma** olarak işaretlendi, CORS'un o63'te **hiç egzersiz edilmediği** yazıldı |
| B-6 *"HER ORTAMDA"* Production'da ölçülmedi | **§2.A + §7/19 (yeni)** | Karar korundu, **ölçüm boşluğu** `W3/G46/f`'nin koşmadığı belirtilerek yazıldı |
| B-8 `credentialless` reddinin öncülü yanlış | **§5** | *"tüm alt kaynaklar aynı kökende"* öncülü **düzeltildi**: `fonts.gstatic.com` **kalıyor**; red **başka** gerekçeyle korundu |
| B-9 §3'ün HTTP hükmü `04` §2'ye demirlenmiş | **§3** | Doğru atıf **`05` §3** (o, `/v2/YOK` onarımından **sonraki** durumu ölçer) |
| B-12 **`K108` İHLALİ** | **belge geneli** | Her kapı atfı **kapsam önekli**: `W3/G43/g`, `W3/G44/b`, `W3/G45/d`, `W3/G44/g` … |
| B-13 §5'in dürüstlüğü | **§5** | Ölçüme dayanan üç red (`ServeUnknownFileTypes` · literal `/v1` · `wwwroot`+`MapFallbackToFile`) tabloya **eklendi** |
| B-14 *"beşi de damgalıydı"* | **üst blok** | Ölçüldü: damga **3 kez** (sorular 1, 2, 4) |
| B-3 kilit adayı ilan ederken checkpoint yok | **üst blok** | Bu metin kendini **kilit adayı ilan ETMİYOR**; denetim bekleyen **taslaktır** |
| A-17 `KANIT/W3` numara çakışması | **§8** | Çakışma **ilan edildi** ve kaynak listesi **belge adlarıyla** yazıldı; dosya adı çakışmaması için bu metin **`08-`** öneki aldı |

🔴 **KAPANMAYAN / KAPANAMAYAN:** `B-O62-2` (Windows'ta `verify.ps1` **koşmadı** — bu belge onu
kapatamaz, yalnız beyan eder) · `B-O63-5` (kapı taslağı `araclar/`'a girmedi; onarımı `K34-f` gereği
**ayrı ele** aittir) · `B-O62-8`/`B-11` · `B-W3-1`…`B-W3-8`. Hepsi §7'de adıyla yazılıdır.

---

## 1. Bağlam

### 1.1 `W2` neyi bıraktı

`W2` (`K142`/`K144`) tarayıcıda **ölçtü**: bu projenin web istemcisi `sharedIndexedDb`
implementasyonuna **geri düşüyordu**; `opfsLocks` **seçilmiyordu**. Ölçülmüş sebep drift'in kendi
kaynağında belgeli (`wasm_setup/types.dart`): `opfsLocks` **çapraz-köken izolasyon** ister — sunucunun
`Cross-Origin-Opener-Policy: same-origin` **ve** `Cross-Origin-Embedder-Policy: require-corp`
göndermesi gerekir. Sunucu bunları göndermiyordu.

`W2` bu durumu **görünür kıldı ama onarmadı** — kapsam dışıydı. Bu ADR o onarımın kararlarını taşır.

> **Bu ADR'nin çözdüğü şey kalıcılığın YOKLUĞU değildir.** `sharedIndexedDb` de saklar (`W1` kriter 9:
> F5 sonrası görev yaşadı). Çözülen, **OPFS tabanlı implementasyonun Chrome'da seçilememesidir.**

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

🔴 **ÖLÇÜLENİN SINIRI — `K161` deseni, BLOKER-3'ün konusu.** Yukarıdaki tabloda ölçülen şey
**konsoldaki `chosenImplementation=` dizgesidir**: drift'in **hangi implementasyonu SEÇTİĞİNİN
beyanı**. Ölçülen **kalıcılık DEĞİLDİR**. *"Bir sonraki açılışta veri fiilen OPFS'ten okundu mu"*
sorusu **hiç sorulmadı** — `KANIT/W3/02`'nin kendi cümlesi budur ve v1 gövdesine **hiç girmemişti**.
Bu yüzden bu ADR'nin başlığı *"OPFS **kalıcılığı**"* değil, *"OPFS **implementasyon seçimi**"*dir.

> Bu ikilik ADR'nin en önemli tek cümlesidir ve **kararı da belirler** (§2.G):
> **temiz kurulum `opfsLocks` seçer, mevcut kullanıcı seçmez.**

### 1.3 İskeletin beş sorusu

| iskelet sorusu (o59) | ölçüm | kaynak |
|---|---|---|
| 1. Başlıklar nerede eklenir? Bugünkü statik varlık seti CORP koşulunu karşılıyor mu? `[ÖLÇÜLMEDİ]` | ASP.NET Core ara katmanı (`OnStarting`) + istemci **aynı kökenden**; 21 vakanın **21'i** COOP+COEP taşıyor. Yerel statik set **karşılıyor**; `gstatic`'ten çekilen CanvasKit için §2.E | `04` §2, §5 |
| 2. `require-corp` SignalR'ı etkiler mi? `[ÖLÇÜLMEDİ]` | **HAYIR** — pozitif kontrollü: izolasyon **açık ve kapalı** iki koşumda da `negotiate` **200**, WebSocket **iki koşumda da** düştü ⇒ sebep COEP değil (§6/R1) | `01` `F/5` |
| 3. Yalnız `Development` mı? *(damgasız)* | **Hayır — her ortamda** (karar). 🔴 Production'da **fiilen ölçülmedi** — §7/19 | `04` §1, `K159/3` |
| 4. İzolasyon tek başına yeter mi? `[ÖLÇÜLMEDİ]` | Temiz kurulumda **evet**; mevcut kullanıcıda **hayır** | `02` + `03` |
| 5. Canlı tarayıcı ölçümü bu ortamda nasıl? *(damgasız)* | Bulut konteynerinde Playwright/Chromium ile; **Onur'un makinesinde playwright YOK** ⇒ orada `T` ayağı `[ÖLÇÜLEMEDİ]` der | `00-DENETIM-o60` §5, `B-O62-3` |

---

## 2. Kararlar

### A. `COOP: same-origin` + `COEP: require-corp` — **HER ORTAMDA**, `OnStarting` ile

Ara katman `src/backend/Momentum.Api/Web/IzolasyonBasliklari.cs`.

1. **Başlıklar `OnStarting` ile yazılır, doğrudan değil.** `UseExceptionHandler` hata yolunda yanıtı
   temizleyip yeniden çalıştırabilir; doğrudan yazılan başlık o yolda **sessizce düşer**.
   🔴 **Bu gerekçe OKUNARAK yazıldı; `UseExceptionHandler`'ın başlıkları düşürdüğü bir mutantla
   KANITLANMADI** (`B-O62-4`).
2. **Neden her ortamda, yalnız `Development` değil:** `Program.cs`'te **üçüncü** bir `IsDevelopment()`
   bloğu doğmasın — o60 denetiminin `BLOKER-3`'ü tam bunu işaretlemişti. İzolasyon bir hata ayıklama
   kolaylığı değil, **ürünün depolama davranışının ön koşuludur**; ortama göre değişen bir depolama
   yolu, üretimde **ölçülmemiş** bir davranış demektir.
   🔴 **BU KARAR PRODUCTION'DA FİİLEN ÖLÇÜLMEDİ** — spec'in `W3/G46/f` ayağı (*"aynı ölçüm
   `ASPNETCORE_ENVIRONMENT=Production` ile de koşar"*) **koşmadı**. Spec bunu adı konmuş bir bloker
   sınıfı (`B5`) olarak işaretlemişti. §7/19.
3. 🔴 **TESLİM EDİLEN TASARIM, SPEC'İN KENDİ MUTANTIDIR — kapı kapsamı GÜNCELLENMELİDİR** (BLOKER-5).
   `GOREV-W3` §5'te `W3/G44`'ün kapsamı *"**YALNIZ** `Program.cs`"*tir ve `W3/G44/d` ayağı
   *"`src/backend/**/*.cs` içinde `Program.cs` **dışında** `Cross-Origin-` dizgesi geçmiyor"* der;
   mutant `M230` ise tam olarak *"başlıklar ayrı `IzolasyonBaslikAraKatmani.cs` dosyasına taşınır"*dır.
   **Ürün bunu yaptı** (`Web/IzolasyonBasliklari.cs`). ⇒ O kapı bugünkü ürüne karşı koşarsa
   **KIRMIZI verir** ve verdiği kırmızı **doğrudur**: kapı, kabul edilen tasarımı ölçmüyor.
   **KARAR:** `W3/G44`'ün kapsamı `Program.cs` **+ başlık ara katmanı dosyası** olarak genişletilir;
   `W3/G44/d`'nin *"başka dosya yok"* ayağı **beyan edilmiş bir dosya listesine** çevrilir (kaçak
   hâlâ ölçülür, ama liste dışı dosyaya karşı). Bu değişiklik **spec'in bir sonraki sürümüne** aittir;
   ADR yalnız kararı verir. 🔴 **Bugün bu kapı KOŞULMADI** — koşsaydı düşerdi.

### B. İstemci **AYNI KÖKENDEN** sunulur

`src/backend/Momentum.Api/Web/IstemciServisi.cs` — **113 satır**, 5.753 b, sha256/16 `1bf90719eb4a83ce`
(`04` §1'den; **toplam 128 satır** = 113 + `Program.cs`'in **+15**'i). 🔴 **`R8` sayısı bu belgeden
değil, `radar.py --olc-urun-kodu <sha>` ile git'ten türetilir (`K55`).**

1. Kök dizin **yapılandırmadan** okunur: `Istemci:KokDizin` (`W1/D-W1-1` deseni — yol koda gömülmez).
2. Anahtar **boş** ya da dizin **diskte yoksa** ara katman **hiç kurulmaz** ⇒ kill switch **bedava** gelir.
   🔴 **BU ÖZELLİK MUTANTSIZDIR VE ÖLÇÜLMEDİ.** Koşan tek mutant (`M-W3-1`) `Izolasyon:Etkin=false`
   yolunu ölçtü; **boş `Istemci:KokDizin` ile ara katmanın kurulmadığı hiç denenmedi.** Beyan edilmiş
   borç — mutantı yazılana kadar bu bir **tasarım iddiasıdır**, ölçüm değil.

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
**Yeniden ölçüm: 1.380.683 b.**

🔴 **`D-W1-3`'ün (`UseCors`'un `UseRouting` ile uç nokta yürütmesi arasında kalması) KORUNDUĞU İDDİASI
KOD OKUNARAK YAZILDI — ÖLÇÜLMEDİ.** Ardışık hat o63'te **değişti** ve **CORS bu turda hiç egzersiz
edilmedi** (çapraz-köken bir istek gönderilmedi; 21 vakanın hepsi aynı kökenden). Bu bir **beyan edilmiş
boşluktur**, yeşil değildir. §7/20.

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

🔴 **BU KORUMANIN KAPSAMI EKSİKTİR — İKİ SINIF DAHA VAR ve ikisi de `SpaDisiOnEkler`'e GÖRÜNMEZ**
(`05` §4, o63 kapı denetiminin bulgusu):
- **`[Route]` öznitelikli controller** — öneki listede olmayan bir controller rotası eklenirse
  SPA fallback onu gölgeleyebilir; liste bunu **hiç görmez**.
- **`app.MapGet("/mutlak")` gibi doğrudan eşlemeler** — aynı sebeple **görünmez**.
🔴 **Bu iki sınıf ÖLÇÜLMEDİ ve kapısı YOK.** *"Sınıf kapandı"* demek bugün **yanlış olur** — ölçülen
`/v{version}` **ailesidir**, sınıfın tamamı değil (`B-O63-6`, §6/R8).

🟡 **Ölçülmüş ve gölgeleme OLMADIĞI belirlenen bir vaka:** `/scalar/YOK` → **200 · text/html · 627 B**.
Bu **SPA kabuğu değildir** (kabuk **1.546 B**); Scalar'ın kendi `/scalar/{documentName}` eşlemesi yanıt
veriyor (`05` §3). ADR'nin *"bir API'nin bilinmeyen uç nokta için HTML döndürmesi kusurdur"* kuralı
burada **uygulanmaz** — dönen HTML API yanıtı değil, Scalar UI'ıdır. **Karar verilmedi**, ölçüm kaydedildi.

🔴 **Bu kusuru ÜRETEN el bulmadı** — `K26` gereği salınan **iki bağımsız denetçi** buldu.

### E. `--no-web-resources-cdn` **ZORUNLUDUR** (`K159-b`) — 🔴 **ama gerekçesi DEĞİŞTİ**

**Kilit ayaktadır:** web build `--no-web-resources-cdn` ile üretilir. `K159-b` Onur'un kilididir ve bu
ADR onu **değiştirmez**.

🔴 **AMA v1 GÖVDESİNİN GEREKÇESİ, BU ADR'NİN KENDİ KAYNAK KÜMESİNDEKİ BİR ÖLÇÜMLE ÇELİŞİYORDU —
ÇELİŞKİ BURADA İLAN EDİLİR** (BLOKER-1, iki bağımsız denetçi):

**① Ne ölçüldü (`04` §5):** ikinci bir köken kuruldu (`127.0.0.1:5299`); `korplu.js` **CORP taşır**,
`korpsuz.js` **taşımaz**. İzole belge ikisini de `<script>` ile yükledi:

```
POZİTİF KONTROL (ikinci köken erişilebilir mi): True
crossOriginIsolated                           : True
CORP'SUZ çapraz-köken betik: BLOKLANDI   (BEKLENEN: BLOKLANDI)
CORP'LU  çapraz-köken betik: YÜKLENDİ    (BEKLENEN: YÜKLENDİ)
```

⇒ Ölçülen önerme: **"CORP göndermeyen çapraz-köken kaynak `require-corp` altında bloklanır."**
**`gstatic` bu ölçümde HİÇ TEST EDİLMEDİ** — test edilen, yerelde kurulmuş **sentetik** bir kaynaktı.

**② `gstatic` fiilen ne gönderiyor (`GOREV-W3` §1 `O3` — canlı ölçüm, 2026-08-05, dokuz istek, hepsi
HTTP/2 **200**):** `www.gstatic.com/flutter-canvaskit/*` (`canvaskit.js`, `canvaskit.wasm`, `skwasm.js`,
`skwasm.wasm`, `chromium/canvaskit.js`) **ve** `fonts.gstatic.com/s/roboto/*.woff2` —
**hepsi `cross-origin-resource-policy: cross-origin` gönderiyor.** Aynı ölçüm `PROJE_HAFIZA.md`'de spec
v1'i düşüren **`B2` blokeri** olarak kayıtlıdır: *"v1'in 'çapraz-köken alt-kaynaklar bloklanır' gerekçesi
**olgusal olarak yanlıştı**."* Ve `D-W3-3` bunu karara bağlamıştı: bayrak *"COEP bloklamasını önlemek
için **gerekli değildir**"*.

**③ ÇELİŞKİ:** *"bayrak olmazsa izolasyon **çürür**"* hükmü, ancak `gstatic` CORP **göndermiyorsa**
doğrudur. Ölçüm **tam tersini** söylüyor. v1 gövdesi bu ölçümü **ne alıntıladı ne çürüttü**; §7'de yalnız
`fonts.gstatic.com` yarısını taşıyıp `flutter-canvaskit` yarısını **düşürdü**.

**④ KARAR — kilit korunur, gerekçe DEĞİŞTİRİLİR.** `--no-web-resources-cdn`'in **ölçülmüş** değeri
şunlardır ve bunların hiçbiri COEP bloklaması değildir:
- **Üçüncü taraf CORP politikasına bağımlılığın kalkması.** Bugün `gstatic` `CORP: cross-origin`
  gönderiyor; **bunu Google'ın politikası belirliyor, bu depo değil.** Politika değişirse uygulama
  **sessizce** kırılır ve bunu görecek bir kapı yoktur. Bayrak bu bağımlılığı **tamamen kaldırır**.
- **Çevrimdışı çalışabilirlik** ve **tedarik zinciri yüzeyinin daralması** (`D-W3-3`'ün kendi gerekçesi).
- 🔴 **TAZELİK:** `O3` ölçümü **5 Ağu 2026** tarihlidir; **8 Ağu 2026'da yeniden ölçülemedi** — bu
  oturumun bulut konteynerinden yanıt başlığı ölçme yolu yok (`WebFetch` başlık döndürmez, doğrudan
  HTTP istemcisi kullanımı bu ortamda yasak). **`gstatic`'in BUGÜNKÜ CORP başlığı: ÖLÇÜLEMEDİ.**
  Bu belirsizliğin kendisi, yukarıdaki birinci maddenin **kanıtıdır**: ölçemediğimiz bir üçüncü tarafa
  bağımlı kalmak yerine bayrak kullanılır.

🔴 **BAYRAK TEK BAŞINA YETMEZ — BYPASS DALI VAR (A-12).** `flutter_bootstrap.js`'in kendi üçlü işleci:

```js
i.canvasKitBaseUrl ? i.canvasKitBaseUrl
                   : (e.engineRevision && !e.useLocalCanvasKit
                        ? I("https://www.gstatic.com/flutter-canvaskit", e.engineRevision)
                        : "canvaskit")
```

**`canvasKitBaseUrl` set edilirse `useLocalCanvasKit`'e HİÇ BAKILMAZ.** Yani `--no-web-resources-cdn`
ile alınmış bir build bile, yapılandırmaya bir `canvasKitBaseUrl` yazılarak **uzak kaynağa
döndürülebilir** — ve o63 denetçileri bunun **canlı istismarını** gösterdi. ⇒ Bayrağı ölçen her kapı
**`canvasKitBaseUrl` yazımını da** ölçmek zorundadır (tek tırnak ve protokol-göreli yazımlar dâhil —
`B-O63-5`'in kapanmamış maddelerinden biri tam budur).

🔴 **BAYRAK BAYTI ÇIKARMAZ, ÇALIŞMA ZAMANI DAVRANIŞINI ÇEVİRİR:** `--no-web-resources-cdn` ile üretilen
çıktıda `www.gstatic.com/flutter-canvaskit` dizgesi **`flutter.js`(1) + `flutter_bootstrap.js`(1) = 2**
yerde **DURUYOR** (`02` ikincil ölçüm). Bu yüzden `W3/G45/d` **pinli sayan-raporlayan** bir kapıdır
(`K151/④`), *"dizge yok"* diyen bir kapı **değildir** — öyle bir kapı yanlış-negatif verirdi.

### F. `Cross-Origin-Resource-Policy` **YAZILMAZ** — 🔴 bu, spec'in `D-W3-4` kararını TERSİNE ÇEVİRİR

**Karar:** CORP başlığı **hiçbir yanıta yazılmaz**. Kapsamı (`/v1/**`, `/health/**`, `/hubs/sync`,
`/scalar/v1`) **ölçülmemiş bir karardır** ve çapraz-köken bir istemcide **ürün davranışını değiştirir**;
ölçülmeden yazılmadı.

🔴 **ÇATIŞMA İLANI (A-10/B-10):** `GOREV-W3`'ün `D-W3-4` kararı *"`Cross-Origin-Resource-Policy:
same-origin` **yalnız statik dosya yanıtlarına** yazılır"* der. Bu ADR onu **tersine çeviriyor** ve v1
gövdesi bunu **adını anmadan** yapıyordu. Bedeli **adlandırılmıştır**:
- `W3/G44/e` (*"CORP VAR ve değeri `same-origin`"*) bugünkü ürüne karşı **KIRMIZI verir**;
- `W3/G46/c` (statiklerde CORP bekler) ve `W3/G46/g` (`/v1`'de CORP olmamasını bekler) **ölür**;
- mutant `M231` (CORP satırı silinir) ve `M239` (CORP tüm yanıtlara yazılır) **hedefsiz kalır**.
⇒ Bu ayaklar ve mutantlar **spec'in bir sonraki sürümünde kaldırılır ya da karar geri alınır.**
**ADR kararı budur; spec'i bu ADR değiştirmez.**

### G. Veri göçü **KAPSAM DIŞIDIR** — `K158` zorunlu beyanı

**MEVCUT `sharedIndexedDb` deposu olan bir tarayıcı OPFS'e GEÇMEZ**; verisi IndexedDB'de kalır.
`T5` (`WasmDatabase.open(..., moveExistingIndexedDbToOpfs: true)`) **ERTELENDİ ve YAZILMAYACAK.**
Üç ölçülmüş gerekçe:

1. COOP/COEP başlıkları **temiz kurulumu** zaten `opfsLocks`'a taşıyor (§1.2).
2. Kalıcı profille üç koşum: izolasyon açık, `chosenImplementation` yine `sharedIndexedDb`,
   **OPFS BOŞ** ⇒ göç **hiç başlamadı** — yani bayraksız yol **çalışmıyor**, "yavaş" değil.
3. **Bayrak yolu ULAŞILAMAZ:** `drift 2.34.3` `wasm.dart:163` bayrağı taşıyor ama
   `drift_flutter 0.3.1` `web.dart:19-24` **geçirmiyor**, ve pub.dev `/api` ölçümü
   **`latest = 0.3.1`** (11 Tem 2026) diyor ⇒ sürüm yükselterek erişilemez.

**Beyan edilmiş bedel:** bayrağın koruduğu şey **mevcut kullanıcı verisidir**; bu depo private ve sahada
kullanıcı **yok** ⇒ kazanç teorik, bedel gerçek (dosya bölmesi · `WasmDatabase.open`'ın VM'de derlenmemesi ·
`W2`'nin `onResult` dikişini taşıma riski — denetimin `B-2`/`B-6` blokerleri).

🔴 **`B-11` (göç atomik değil: taşıma kopyalamıyor, kaynağı SİLİYOR) HÂLÂ ÖLÇÜLMEDİ** (`B-O62-8`).
**`T5` bir gün açılırsa ÖNCE o ölçülür; sıra tersine çevrilemez.**

### H. CI **önce build alır, sonra kapıyı koşar** — 🔴 **ve bugünkü kapı BAYRAĞI ÖLÇEMEZ**

`GOREV-W3` §8/6 bu kararı açıkça bu ADR'ye havale etmişti. **Karar (Onur kilitledi, 8 Ağu 2026):**

```
1. flutter build web --release --no-web-resources-cdn
2. çıktı → Istemci:KokDizin
3. API kaldırılır (hazır olma /health/live 200'e kadar YOKLANIR — sabit sleep YASAK, K80)
4. izolasyon-olc.py  H ayağı koşar   (yalnız stdlib ⇒ CI'da playwright gerekmez)
```

🔴 **BLOKER-2 — BU KARAR, GEREKÇE GÖSTERDİĞİ RİSKİ YAPISAL OLARAK ÖLÇEMEZ.** Gerekçe *"bayrak
unutulursa izolasyon sessizce kırılır ve bunu gören hiçbir kapı yok (`B-O63-2`)"* idi. Ama
`KANIT/W3/00-DENETIM-o60.md` §5'in tanımı gereği **`H` ayağı yanıt BAŞLIKLARINI ölçer**, `T` ayağı
(playwright) `crossOriginIsolated`'ı ölçer. **COOP/COEP başlıklarını ASP.NET ara katmanı yazar ve
`--no-web-resources-cdn` bayrağından TAMAMEN BAĞIMSIZDIR** ⇒ **bayrağı unutulmuş bir build'de `H`
ayağı YEŞİL verir.** Bayrağı görebilecek tek ayak, o63'te taslak kalan **`B` ayağıdır** ve o taslak
**denetimde düşüp `araclar/`'a KONULMAMIŞTIR** (`B-O63-5`).
⇒ **Karar, bugünkü hâliyle adlandırdığı borcu (`B-O63-2`) KAPATMAZ.** Bu, projenin *"KÖR KAPI YOK"*
doktrininin ihlalidir ve bu ADR'nin **en pahalı** kararını (CI'ya Flutter SDK adımı) gerekçesiz bırakır.

🔒 **KARAR (Onur onayladı, 8 Ağu 2026 — o65):** CI adımı **korunur**, körlük **kapatılır**:

1. CI zinciri yukarıdaki dört adımıyla **aynen kalır**.
2. **Bayrağın izini FİİLEN ölçen bir statik ayak eklenir** — `W3/G45/f` adayı. Ölçtüğü, build
   çıktısındaki **çalışma zamanı bayrağıdır**, dizge yokluğu değil:
   - `wwwroot/flutter_bootstrap.js` içinde **`useLocalCanvasKit` `true`** (bu değer
     `--no-web-resources-cdn` ile üretilen çıktıda `KANIT/W3/04` §5'te **fiilen ölçüldü**);
   - **VE** aynı taramada **`canvasKitBaseUrl` yazımı YOK** (bypass dalı — A-12; tek tırnak, çift
     tırnak ve protokol-göreli yazımlar dâhil);
   - **POZİTİF KONTROL:** aynı dosyada `_flutter` dizgesi bulunur ve dosya boş değildir — yoksa ayak
     **ORTAM HATASI** verir, *"aradım bulamadım"* ile *"aramadım"* ayrılır.
   - **MUTANTI ZORUNLUDUR** (`K155`: kapı ayağı borçlanamaz): `useLocalCanvasKit` değeri `false`
     yapılır ⇒ ayak **KIRMIZI** vermeli; ayrıca `canvasKitBaseUrl` enjekte edilir ⇒ **KIRMIZI**.
3. **`K53/2`'nin yazılı gerekçesi** (ispat yükü `MEKANİKLEŞTİR` seçende): *bu sınıf **koşan kod
   olmadan ölçülebilir** — bayrağın izi build çıktısında **statik bir dizgedir**, tarayıcı
   gerektirmez.*
4. 🔴 **BEYAN EDİLMİŞ SINIR — kapanmayan kısım:** `T` ayağı (gerçek tarayıcı) CI'da **koşmaz**;
   `H` + `W3/G45/f` birlikte *"başlıklar gönderiliyor"* ve *"build bayrağı doğru"* der, ama
   **belgenin fiilen izole olduğunu ve drift'in hangi implementasyonu seçtiğini ölçmez** (`B-W3-1`).
   Bu, bilinçli bir kapsam daraltmasıdır.
5. 🔴 **Bu karar bu ADR'de YAZILDI, CI'da HENÜZ KOŞULMADI** — uygulaması `D-A13-4` (backend CI)
   turundadır. Ayağın **kendisi de henüz yazılmadı**; `B-O63-2` **ancak ayak `araclar/`'a girip
   mutantıyla ısırdığı ölçüldüğünde** kapanır. Bugün **AÇIK**.

---

## 3. Uygulama sırası ve kanıtlar

| adım | ürün kodu | kanıt |
|---|---|---|
| 1. İzolasyon ara katmanı + kill switch | `Web/IzolasyonBasliklari.cs` (yeni), `Program.cs` (+2) | `KANIT/W3/00-ISKELET-OLCUMU-o62.md` — derleme **0 uyarı/0 hata**; `crossOriginIsolated=true`; `M-W3-1` **ısırdı** |
| 2. `/scalar/v1` ve `/hubs/sync` izolasyon altında | — (ölçüm) | `KANIT/W3/01-F4-F5-OLCUMU-o62.md` — `F/4` **KAPANDI**, `F/5` **ölçüldü** |
| 3. Merkezî ürün sorusu (`O2`) | — (ölçüm) | `KANIT/W3/02-O2-OLCUMU-o62.md` **(ERRATUM'lu)** |
| 4. Veri göçü | — (ölçüm) | `KANIT/W3/03-VERI-GOCU-OLCUMU-o62.md` — `02`'yi **daraltır** |
| 5. İstemci aynı kökenden | `Web/IstemciServisi.cs` **113 satır** (yeni) + `Program.cs` **+15** = **128 satır toplam** | `KANIT/W3/04-ISTEMCI-IZOLASYONU-o63.md` §1 — 21 vaka, `M-W3-2` **ısırdı** |
| 6. `/v{version}` ↔ `SpaDisiOnEkler` onarımı | `Web/IstemciServisi.cs` | `KANIT/W3/05-URUN-KUSURU-V-SURUMU-o63.md` |

🔴 **`R8` ürün kodu sayısı bu tablodan OKUNMAZ** — `radar.py --olc-urun-kodu <sha>` ile **git'ten**
türetilir (`K55`).

**HTTP düzeyi hüküm — kaynak `KANIT/W3/05` §3'tür** (`04` §2 **değil**): `05` aynı 21 vakalık ölçümü
`/v2/YOK` onarımından **sonra** yeniden koştu ⇒ **BAŞLIKSIZ YANIT SAYISI = 0** · **KABUK DÖNEN API
YOLU = YOK** · gerçek tarayıcıda `crossOriginIsolated = True`, `SharedArrayBuffer = function`, 10 istek
**0 başarısız**. Dört API yüzeyinin (`/v1/**`, `/health/**`, `/hubs/sync`, `/scalar/v1`) hiçbiri
gölgelenmiyor; `K61` dev-kimlik kalkanı **canlı** (başlıksız **401**); slice-2b2 `D4` hub kalkanı
**canlı**. 🔴 **`04` §2'ye demirlemek `K161`'in doğduğu kusurun tekrarı olurdu:** `04`'ün hükmü
`/v2` kusuru **hâlâ canlıyken** yazılmıştı.

---

## 4. Gerekçe

**Neden başlıklar, neden kod değil.** `B1` blokeri iki tur boyunca *"drift `sharedIndexedDb`'de KALIR,
ürün davranışı DEĞİŞMEZ"* dedi ve `T5`'in **tek gerekçesiydi**. Ölçüm bunu **temiz kurulum için çürüttü**:
`WasmDatabase.open`'ın seçim mantığı zaten tarayıcı yeteneğine bakıyor; eksik olan **bayrak değil,
izolasyondu**. **İki yanıt başlığı**, bir dosya bölmesinden ve `onResult` dikişini taşıma riskinden daha
ucuz ve daha az kırılgandır.

**Neden aynı köken.** İzolasyon başlıkları yalnız **kendi kökenlerinden servis edilen belgeleri** izole
eder ve istemci ayrı kökende kaldığı sürece API'ye başlık eklemek istemciyi izole **etmez** — bu o62'de
kodun kendi `<remarks>`'ında beyan edilmiş bir sınırdı ve o63'te **kapatılarak** ölçüldü. 🔴 **Bunun
tersi ("ayrı köken izole OLAMAZ") YANLIŞTIR ve ölçülmüştür** — §5'e bakınız.

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
| `COEP: credentialless` | 🔴 **BİLEREK REDDEDİLDİ** | `izolasyon-olc.py` altın kümesinde **ayrı bir vaka** olarak reddedilir. 🔴 **v1'in öncülü YANLIŞTI** (*"bu ADR'nin kapsamındaki tüm alt kaynaklar aynı kökendedir"*): `fonts.gstatic.com` **kalıyor** ve bu, aynı belgenin §7/5'inde yazılı. **Düzeltilmiş gerekçe:** `credentialless` CORP şartını gevşetir ve çapraz-köken kaynakları **kimlik bilgisiz** çeker; kazancı bu projede **yok** (kalan tek çapraz-köken kaynak font'tur ve zaten `CORP: cross-origin` gönderiyor), bedeli **ölçülmemiş bir davranış farkıdır** |
| `moveExistingIndexedDbToOpfs: true` (bayrak yolu) | 🔴 **ULAŞILAMAZ (ölçüldü)** | `drift_flutter 0.3.1` bayrağı **geçirmiyor**, pub.dev `/api` ölçümü `latest = 0.3.1` ⇒ **sürüm yükseltme yolu yok**. 🔴 v1 buna *"ÖLÇÜLEREK ÖLÜ"* diyordu — **ölçülen ölülük değil ERİŞİLEMEZLİKTİR**; bayrak drift'te **yaşıyor** (`wasm.dart:163`), ona **ulaşılamıyor** |
| `T5` — koşullu import + dosya bölmesi | 🔴 **ERTELENDİ** (`K158`, Onur kilitledi) | Bedeli gerçek (dosya bölmesi · VM'de derlenmeme · `W2`'nin `onResult` dikişi), kazancı **teorik** (sahada kullanıcı yok) |
| İstemciyi **ayrı kökenden** sunmak | 🔴 **REDDEDİLDİ** | 🔴 **v1'in gerekçesi OLGUSAL OLARAK YANLIŞTI.** `01` `F/5` ölçtü: ayrı kökendeki (`127.0.0.1:5111`) probe belgesi **kendi** COOP+COEP başlıklarıyla **`crossOriginIsolated = true`** oldu ⇒ ayrı köken izolasyonu **çürütmez**. **Düzeltilmiş gerekçe:** ayrı köken **ikinci bir dağıtım yüzeyi** demektir; o yüzeyin başlıklarını bu depo **kontrol etmez** (ters vekil/CDN onları ezebilir — §6/R3) ve istemci↔API arasına **CORS bağımlılığı** girer (`W1`'in `B-W1-5` blokeri hâlâ açık). Bu depoda dağıtım hedefi **yok** ⇒ ölçülemeyen bir yüzeye bağımlılık kabul edilmedi |
| Başlıkları yalnız `Development`'ta açmak | 🔴 REDDEDİLDİ | Depolama yolu ortama göre değişirdi ⇒ üretimde **ölçülmemiş** davranış; ayrıca `Program.cs`'te üçüncü `IsDevelopment()` bloğu (o60 `BLOKER-3`) |
| Başlıkları doğrudan yazmak (`OnStarting` yerine) | 🔴 REDDEDİLDİ | `UseExceptionHandler` yanıtı temizleyebilir ⇒ başlık **sessizce düşer**. 🔴 Gerekçe **okunarak** yazıldı, **mutantla kanıtlanmadı** (`B-O62-4`) |
| CI'da kapıyı **koşmamak** | 🔴 REDDEDİLDİ (§2.H) | Bayrak unutulursa izolasyon **sessizce** kırılır. 🔴 Bugünkü `H` ayağı bunu **ölçemiyor** — §2.H/2'deki yeni ayak bu redde **anlam kazandırır**; o ayak yazılmazsa bu red **gerekçesiz kalır** |
| `ServeUnknownFileTypes = true` ile `/assets/NOTICES` onarımı | 🔴 **REDDEDİLDİ — koşumda ÖLÜ çıktı** | Kâğıtta doğru, ölçümde etkisiz: kök neden `StaticFileMiddleware`'in `ValidateNoEndpoint`'iydi, MIME tipi değil (`04` §6/K2). Doğru onarım **açık `app.UseRouting()`** |
| `SpaDisiOnEkler`'e literal `"/v1"` yazmak | 🔴 **REDDEDİLDİ — ölçümle çürütüldü** | `/v1/YOK` 404 verip *"sınıf kapandı"* sandırıyordu; `/v2/YOK` **200 + kabuk** canlı kaldı (`05`). Rota **şablonu** (`/v{version:apiVersion}`) yazıldı |
| `wwwroot` + `MapFallbackToFile` yerine yakala-hepsi rota (`app.Map("/{**path}")`) | 🔴 **REDDEDİLDİ — birincil kaynakla** | `FallbackEndpointRouteBuilderExtensions.cs:79` fallback'e `Order = int.MaxValue` verir ve `EndpointComparer` seçimi **`Order`'a** bağlar ⇒ fallback API'yi **yutamaz**; düşük `Order`'lı elle yazılmış yakala-hepsi **yutar** (spec'in `M224` mutantı bunu hedefler) |

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
kimlik taşıma yolu ayrı bir karardır. **Bugün bloker değildir** (web'de SignalR zaten kapalı).
🔴 **Web'e açıldığında bloker OLMASI BEKLENİR — ama bu bir TAHMİNDİR, ölçüm değil:** ölçülen yalnız
**ham `WebSocket`** transportudur. SignalR `WebSockets` başarısız olunca `ServerSentEvents` ve
`LongPolling`'e **geri düşer** ve bu iki transport **fetch tabanlıdır** ⇒ başlık taşıyabilirler.
**Transport geri düşüşü HİÇ ÖLÇÜLMEDİ.** `B-O62-7` açık kalır.

### R2 🔴 Güvenli bağlam kapı tarafından ölçülemez (`B-W3-3`)

`192.168.x.x` gibi bir adresten açılan sayfa **güvenli bağlam değildir** ⇒ sessizce izolasyonsuz kalır ve
**hiçbir kapı kırmızı vermez**. Emülatör/LAN testlerinde bu tuzağa dikkat.

### R3 🔴 Üretim dağıtım topolojisi bu dilimde **YOK**

Ters vekil / CDN / ayrı statik host COOP/COEP'i **ezebilir** ve bu **ölçülmez**. HTTPS/WSS altında
**hiçbir ölçüm yapılmadı**; hepsi düz `http`/`ws`.

### R4 🟡 Regresyon koruması dar (`B-W3-1`)

Birisi `require-corp`'u `credentialless` yaparsa `W3/G44/b` yakalar; ama **drift'in fiilen hangi API'yi
seçtiğini hiçbir otomatik kapı görmez.** §2.H'nin CI kapısı **başlıkları** ve (yeni ayakla) **build
bayrağını** ölçer, **seçimi** değil.

### R5 🟡 `/scalar/v1` bir üst sürümde CDN'e dönebilir (`B-O62-9`)

`F/4` hükmü `@scalar/api-reference@1.62.9` içindir; Scalar CDN'e dönerse hüküm **bayatlar** ve
`izolasyon-olc.py` bunu **ölçmez** (`/scalar/v1`'i kapsam alan ayak **yok**).

### R6 🟡 `index.html` `no-store` göndermiyor (`B-O63-4`)

SPA kabuğu önbelleğe girebilir ⇒ kullanıcı bayat kabukla kalabilir. **Ölçülmedi ve karar verilmedi.**
*(Ölçüm tarafında bu tuzak fiilen ısırdı: o62'de kalıcı profil + önbellek yüzünden izolasyon kör ölçüldü.)*

### R7 🟡 Gölgeleme ve liste tazeliği kapısız (`B-O63-1`, `B-O63-3`)

İstemci kökünde `v1`/`health`/`hubs`/`scalar` **adında bir dosya** bulunursa uç nokta gölgelenir —
ölçüm **bir kez** koştu, mekanik kapı **yok**. `SpaDisiOnEkler` listesine yeni bir kök yol eklenirse
liste **sessizce bayatlar**. 🔴 Bu iki ayağın taslağı yazıldı, **denetimde düştü (16 bulgu)** ve
`araclar/`'a **konulmadı** (`B-O63-5`).

### R8 🔴 **VAKA ÖLÇMEK SINIF KAPATMAZ — bu ADR'nin ana dersi ve kapanmamış borcu (`B-O63-6`)**

`K161`'in dersi budur ve **onu zorlayan hiçbir kapı yoktur.** Hiçbir araç *"ölçülen vaka, iddia edilen
sınıfı kapsıyor mu?"* diye sormaz. Bu ADR'de **iki canlı örneği** vardır:

1. **`K159-c`/`K161-b`:** `/v1/BULUNMAYAN-UC` ölçüldü, **404** görüldü, *"sınıf kapandı"* sanıldı —
   `/v2` **canlı kaldı** ve bunu **iki bağımsız denetçi** buldu. Şablona geçilerek `/v{version}` ailesi
   kapandı; ama **`[Route]` öznitelikli controller ve `app.MapGet("/mutlak")` sınıfları HÂLÂ AÇIK**
   (§2.D) — yani sınıf **bugün de kapanmadı**, yalnız **daha geniş bir vaka kümesi** kapandı.
2. **§2.E'nin kendisi (BLOKER-1):** *"CORP'suz sentetik kaynak bloklandı"* vakası ölçüldü ve
   *"gstatic'ten çeken build izolasyonu kırar"* **sınıfı** iddia edildi. Vaka doğruydu, sınıf
   **çürüktü** — `O3` gstatic'in CORP gönderdiğini ölçmüştü.

🔴 **Kapanış yolu AÇIK DEĞİLDİR ve mekanikleşmesi zor olabilir.** En azından **checkpoint disiplini**
olarak yazılır: *ölçülen vaka kümesi ile iddia edilen sınıf, her hüküm cümlesinde **ayrı ayrı**
yazılacak.* Bu ADR bu disiplini kendi üzerinde uygulamıştır (§1.2, §2.D, §2.E).

---

## 7. 🔴 BEYAN EDİLMİŞ SINIRLAR — *"neyi ölçmüyoruz"*

`GOREV-W3` §8 (🔴 **kilitlenmemiş, `K150` ile reddedilmiş** bir taslağın §8'i — üst bloğa bakınız) ve
`KANIT/W3/**`'ün *"NE ÖLÇÜLEMEDİ"* listelerinin birleşimi. **Bu bölüm boş olamaz.**

1. 🔴 **Onur'un Windows makinesinde HİÇBİRİ koşmadı.** İki ayrı olgu, v1'de birbirine karışmıştı:
   **`verify.ps1` KOŞMADI** (PowerShell zinciri, Windows'ta hiç çalıştırılmadı — `B-O62-2`, **dördüncü**
   oturumdur açık) · **`dotnet test Momentum.sln` KOŞTU ve 120/120 verdi** — ama **bulut konteynerinde,
   Linux'ta, gerçek PostgreSQL ile** (o63). *"0 uyarı"* ölçümü de Linux ölçümüdür.
2. 🔴 **Flutter yama farkı:** ölçümler **3.44.9**, depo **3.44.6** diyor. Farkın etkisi **ölçülmedi**.
3. 🔴 **PostgreSQL yoktu** (o62/o63 tarayıcı ölçümlerinde) ⇒ `/v1/**` uçlarının **200 gövdesi hiç
   görülmedi**; yalnız *gölgelenmedikleri* ölçüldü. Çevrimdışı/OPFS akışı, drift senkronu, gerçek CRUD
   **hiç egzersiz edilmedi**.
4. 🔴 **`gstatic.com`'un CORP'u BU OTURUMDA (8 Ağu 2026) ÖLÇÜLEMEDİ** — bulut konteynerinden yanıt
   başlığı ölçme yolu yok. Elde **tek kayıt** `GOREV-W3` §1 `O3`'tür (**5 Ağu 2026**, dokuz istek,
   `flutter-canvaskit/*` **ve** `fonts.gstatic.com/*` hepsi `CORP: cross-origin`). §2.E'nin mekanizma
   ölçümü **yerel sentetik ikinci kökenle** yapıldı, **gstatic ile değil**. ⇒ *"gstatic bloklanır"*
   **hiçbir zaman ölçülmedi**; §2.E'nin gerekçesi bu yüzden değiştirildi.
5. `fonts.gstatic.com` istekleri **kalır** (`B-W3-2`). Çevrimdışı ilk açılışta font düşer;
   uygulama **çalışır**, tipografi geri düşer. Ölçüldü, kabul edildi.
6. 🔴 **Service worker** `require-corp` altında **ÖLÇÜLMEDİ** (`B-W3-4`).
7. 🔴 **CORP alt kaynak davranışı iki yolla ölçüldü — `<script>` (`04` §5) ve `<img>`/`no-cors`
   (`01` EK, üç varyant).** `fetch` ve `worker` için **ölçülmedi**; aynı davranışı beklemek bir
   **tahmindir**. *(v1 burada "script için ölçülmedi" diyordu — **ölü beyandı**, `04` §5 tam olarak
   `<script>` ile ölçmüştü ve §2.E o ölçümü kanıt olarak kullanıyordu.)*
8. 🔴 **`opfsShared` hiçbir koşumda görülmedi** — `dedicatedWorkersInSharedWorkers` her koşumda eksikti.
   Ölçülen **`opfsLocks`**'tur. Headless Chromium kaynaklı olabilir — **ölçülmedi**.
9. 🔴 **Tarayıcı çeşitliliği YOK** — yalnız Chromium. **Firefox/Safari ölçülmedi.**
10. 🔴 **KALICILIK ÖLÇÜLMEDİ — yalnız SEÇİM ölçüldü** (BLOKER-3). Ölçülen `chosenImplementation=opfsLocks`
    **dizgesidir**; *"bir sonraki açılışta veri fiilen OPFS'ten okundu mu"* **hiç sorulmadı**
    (`KANIT/W3/02`'nin kendi beyanı). **SATIR DÜZEYİNDE KULLANICI VERİSİ de ölçülmedi** — *"kullanıcının
    görevleri kayboldu mu"* sorusu **açık** (Flutter web **CanvasKit** ile çiziyor, DOM'da tıklanacak
    öğe yok, semantics açılmadı).
11. 🔴 **`B-11` — göç atomik değil** (`B-O62-8`): göç **hiç başlamadığı** için hâlâ ölçülmedi.
12. 🔴 **SPA gölgeleme sınıfının İKİ ALT SINIFI ÖLÇÜLMEDİ ve kapısızdır** (§2.D): `[Route]` öznitelikli
    controller · `app.MapGet("/mutlak")` gibi doğrudan eşlemeler. Ayrıca **`/v2` ailesi gerçekten
    kullanıma açıldığında** fallback'in onu gölgelemediği **ölçülmedi**; bugün `ApiVersionSet` yalnız
    `1.0` ilan ediyor.
13. 🔴 **`OnStarting` kararının hata yolundaki üstünlüğü mutantla kanıtlanmadı** (`B-O62-4`).
14. 🔴 **`W3/G44/g` yorum atıcısı tam bir C# parserı DEĞİLDİR** (`B-W3-5`).
15. 🔴 **Ölçüm koşucuları Onur'un diskine YAZILMADI** — bulut konteyneri oturumla kaybolur.
    `KANIT/W3/04` §8 tanımları yeniden üretmeye yeter; kalıcılaştırma kararı **alınmadı**.
16. 🔴 **Windows/NTFS davranışı hiç ölçülmedi** — hepsi Linux/ext4.
17. 🔴 **`W2` §8'in bu ADR turuna AÇIKÇA DEVRETTİĞİ canlı şerit ölçümü YAPILMADI** (A-15). Devir
    `B-W1-2` kimliğiyle kayıtlıdır; bu turda ne koşuldu ne de gerekçesi yazıldı. **Açık devir.**
18. 🔴 **`adr-kapi-taramasi.py` bu gövdeye karşı koşuldu ⇒ EXIT 1, `'karar': 0`** — yani A–H
    kararlarının **hiçbiri hiçbir kapıya görünmüyor**. **BEYAN EDİLMİŞ SINIR:** o araç `ADR 0003`
    kapsamlıdır ve `K41` ile **dondurulmuştur** ⇒ bu bir *"ADR 0004 kapısı düştü"* hükmü **DEĞİLDİR**;
    ölçtüğü şey, bu ADR'nin **hiçbir mekanik kapıya bağlı olmadığıdır**. Kabul kriteri 6'nın aracı
    (`adr-doldurulmus-mu.py`) da **henüz yazılmadı**.
19. 🔴 **"HER ORTAMDA" KARARI PRODUCTION'DA ÖLÇÜLMEDİ** (§2.A/2). Spec'in `W3/G46/f` ayağı — *"aynı
    ölçüm `ASPNETCORE_ENVIRONMENT=Production` ile de koşar ve `a`–`c` aynen geçer"* — **hiç koşmadı**.
    Spec bunu adı konmuş bir bloker sınıfı (`B5`) olarak işaretlemişti: *"canlı katman yalnız
    Development'ta koşarsa 'her ortamda' iddiası mantıken yanlışlanamaz."* **Bugün yanlışlanamaz
    durumdadır.**
20. 🔴 **`D-W1-3` (CORS'un `UseCors` konumu) KORUNDU İDDİASI KOD OKUNARAK YAZILDI** (§2.C). Ardışık hat
    o63'te değişti ve **CORS bu turda hiç egzersiz edilmedi** — 21 vakanın hepsi aynı kökendendi.
    `W1`'in `B-W1-5` borcu (*"CORS yalnız Development" kararı kapısız*) hâlâ açık.
21. 🔴 **`W3/G44` ve `W3/G46` kapılarının bir kısmı bu ürüne karşı KIRMIZI verir** (§2.A/3, §2.F) ve
    **bu turda koşulmadılar**. Kapı-ürün uyumsuzluğu **beyan edilmiştir**, ölçülerek kapanmamıştır.

---

## 8. İlgili

🔴 **`KANIT/W3` NUMARA ÇAKIŞMASI — ARŞİV BÜTÜNLÜĞÜ KUSURU (A-17, açık).** `00` ve `03` indeksleri
**iki ayrı belgeye** işaret ediyor: `00-DENETIM-o60.md` **ve** `00-ISKELET-OLCUMU-o62.md` ·
`03-DENETIM-v2-o60.md` **ve** `03-VERI-GOCU-OLCUMU-o62.md`. Bu yüzden aşağıdaki liste **numarayla
değil, DOSYA ADIYLA** yazılmıştır. *(Bu metin `08-` önekini bu çakışmayı büyütmemek için aldı.)*

- `docs/ADR/0001-genel-mimari.md` §D (API biçimi, sağlık, versiyon) · §H (ısıran kapı doktrini)
- `docs/ADR/0002-senkron-mekanigi.md` §G (gerçek-zaman: sinyal + pull) — §6/R1 oraya dokunur
- `GOREV_CLAUDE_CODE/GOREV-W1-web-yuruyen-iskelet.md` (`W1/D-W1-1` · `W1/D-W1-3`)
- `GOREV_CLAUDE_CODE/GOREV-W2-depolama-gorunurlugu.md` §2 (bu ADR'yi doğuran madde) + §8 (devir, §7/17)
- `GOREV_CLAUDE_CODE/GOREV-W3-capraz-koken-izolasyonu.md` — 🔴 **v2, KİLİTLENMEDİ, `K150` ile düştü**;
  §1 (`O1`–`O5` ölçümleri, **`O3` §2.E'nin konusudur**) · §5 (kapılar `W3/G43`–`W3/G47`) · §8 (sınırlar)
- Ölçüm kanıtları: `KANIT/W3/00-ISKELET-OLCUMU-o62.md` · `01-F4-F5-OLCUMU-o62.md` ·
  `02-O2-OLCUMU-o62.md` **(ERRATUM'lu)** · `03-VERI-GOCU-OLCUMU-o62.md` ·
  `04-ISTEMCI-IZOLASYONU-o63.md` · `05-URUN-KUSURU-V-SURUMU-o63.md`
- Denetim raporları: `KANIT/W3/00-DENETIM-o60.md` (spec v1 · `B1`, `B-2`, `B-6`, `B-11`, `BLOKER-3`,
  `MAJOR-*`) · `KANIT/W3/03-DENETIM-v2-o60.md` (`F/4`, `F/5` maddelerinin kaynağı)
- Düşen taslaklar: `KANIT/W3/06-KAPI-TASLAGI-DENETIMDE-DUSTU-o63.py` (`B-O63-5`) ·
  `KANIT/W3/07-ADR0004-GOVDE-TASLAGI-DENETIMDE-DUSTU-o64.md` (bu metnin v1'i)
- Borçlar: `B-W1-2`, `B-W1-5` · `B-W3-1`…`B-W3-8` · `B-O62-2`, `B-O62-3`, `B-O62-4`, `B-O62-7`,
  `B-O62-8`, `B-O62-9` · `B-O63-1`…`B-O63-6`
- Kilitler: `K61` · `K148`/`K148-b` · `K151` · `K154` · `K158` · `K159`/`K159-b`/`K159-c` ·
  `K161`/`K161-b` · `K162`
