# BORCLAR.md — Momentum · AÇIK BORÇLAR (adlandırılmış, gizlenmemiş)

> 🔴 **AÇILIŞTA OKUNMAZ** (`K83`); yalnız **iş bir borca dokunduğunda** açılır.
> 🔴 **BU DOSYA ARTIK BİR İNDEKSTİR [K160, oturum 63 — Onur kilitledi].** Her kalem **kimlik + tek
> cümle** taşır. **Tam gerekçeler `PROJE_HAFIZA.md` K160'ın altındaki arşiv bloğundadır** ve oraya
> *hiçbir cümle kaybolmadan* taşındı. **Hiçbir borç kapanmadı, hiçbir borç silinmedi** — sıkıştırma
> anlatımı küçültür, listeyi değil. Yeni kalem de **tek satır** yazılır; anlatım hafızaya gider.
> 🔴 **TAVAN BU SATIRDA YAZILI DEĞİLDİR** — kanonik eşik `belge-tavan-kapisi.py`'nin kapsam
> tablosundadır ve K40 gereği yalnız Onur değiştirir. *(Ölçülmüş gerekçe: bu başlık o63'e kadar
> `≤ 32.768 b [K126]` diyordu; `K152` tavanı 40.960 yapalı beri **ÖLÜ BEYAN**dı — `kanonik-kopya`.
> Sayıyı kopyalayan satır bayatlar, kapıya atan bayatlamaz.)*
> **Kapanan kalem buradan ÇIKARILIR**, gerekçesi `PROJE_HAFIZA.md`'ye yazılır (`K71`).

---

### Ürün / kod

- 🔴 **`SenkronDongusu.durdur()` yok** ve üretimde yaşam-döngüsü kancası da yok ⇒ `A11/G22/i` bugün yalnız testte anlamlı [o49].
- 🔴 **Sinyal keepalive'i canlılık ölçmüyor** — `{"type":6}` gidiyor, sunucu yanıtına zaman aşımı yok; **yeniden bağlanma yolu bu depoda HİÇ egzersiz edilmedi** (emülatör NAT'ı soketi koruyor) [o49].
- 🟡 **`408`/`429` yeniden denenmiyor** — `D9`'un kilitli sınıflandırmasına dokunur, ayrı dilim [K116 kapsam dışı].
- 🟡 **`K113` sarmalayıcısı `duzenle`/`sil` yollarını kapsamıyor** — o yollar açılırsa `_yerelYaz()`'dan geçmeleri ZORUNLU, yoksa K112 boşluğu döner.
- 🟡 **.NET 10 kapsam dışı paketler** [K111]: `Asp.Versioning.Http` 8.1.1→10.0.1 · `xunit` 2.9.2→2.9.3 · `Test.Sdk` 17.12.0→18.8.1 · `xunit.runner.visualstudio` 2.8.2→3.1.5 · `Scalar.AspNetCore`→2.16.17.
- 🟡 **`Microsoft.OpenApi 2.11.0` geçici CVE pini** [K111] — yukarı akış düzelince **silinir**; unutulursa sürüm gerilemesi olarak ısırır.
- 🟡 **`LangVersion=latest` dil-sürümü sınıfına açık** [K111, mutant kanıtlı] — çatıya pinleme Onur'un kararı.
- 🔴 **Sabit `sleep` bir ölçüm değildir** [o35, KENDİ ölçüm kusurum] — 22 sn bekleyip yanlış KIRMIZI verildi; kriter 9'un 15 sn'lik ilk geçişi **titizlik değil ŞANSTI**.
- 🔴 **`iddia-kapisi.py` ikili dosyaları metin gibi tarıyor** [o35] — bir PNG dört hayalet kanıt üretti; tehlikeli yön **ters**: kanıt kazayla sağlanabilir. 🔴 **AYRI EL (K34-f)**.
- 🟡 **[K76] cihaz kanıtındaki `zehirli` kuyruk kaydı SQLite'a seed edildi** — render gerçek, **veri sentetik**.
- 🟡 **`tazelik-muafiyet.json`'daki `BD-6` gerekçesi bayat** [o36] — muafiyet geçerli, **gerekçesi değil**. 🔴 **AYRI EL**.
- 🔴 **`KANIT/slice-3c/02-G2/` geri doğuyor, üretici kod düzeltilmedi** — `g2_registry_zarf_kapisi_test.dart:64` + `g3_ayristirici_kapisi_test.dart:20`. Hiçbir araç *"KANIT dizini ile onu yazan kodun yolu aynı mı?"* diye sormuyor.
- 🟡 **Son sayfa tam `PageSize` ise bir boş tur fazladan koşar** — veri kaybı değil, **maliyet**.
- 🟡 **`CakismaRozeti` dokunma hedefi 48,0 dp ölçüldü**; `Checkbox`'ın kendi ölçek davranışı **[DOĞRULANMADI]**.
- 🔴 **A‑7 `DESIGN.md`'de kapanmadı** [K86] — kırpma ölçülerek düzeltildi (266/266, 14/14 mutant) ama `K46` gereği tek bayt yazılmadı; açılışı Onur'un ayrı kilidi.
- 🟡 **`_CakismaCozumSayfasi` `GOREV-A8`'in beyanlı haricidir** [K90] — `K42-d` adım 3'te kapanır.
- 🔴 **Çakışma çözüm sayfası 2.0×'te kırpılıyor** [K86] — `ellipsis` var, `maxLines` yok; kayıp **görsel**, ekran okuyucuda yok.
- 🔴 **ÇAĞRILMAYAN KAPI sınıfı — KAPANMADI.** `KAPILAR.md` tetikleri **beyan ediyor, zorlamıyor**; `design-token-kapisi.py`, `iddia-kapisi.py`, `hafiza-dizin.py` hâlâ `DURUM.md` §2'nin numaralı listesinde **değil**.

### Araç / kapı

- 🟡 **`_start_api.cmd` `ASPNETCORE_ENVIRONMENT` borcu ÖLÇÜLEMEDİ** [o48'de denendi] — ikinci `dotnet run` dll kilidi yüzünden derlenemiyor (`MSB3027`).
- 🔴 **`verify.ps1` geçmiş kanıtı eziyor** [K111, iki kez ölçüldü] — `MOMENTUM_KANIT_DIZIN` varsayılanı donmuş kanıtı yeniden yazıyor. 🔴 **AYRI EL**.
- 🔴 **`.gitignore` kanıtı sessizce yutuyor — sınıf açık** [K111] — vaka kapandı, sınıf değil; ucuz kalkan `check-ignore -v` + `diff --cached --stat`.
- 🔴 **`verify.ps1` fail-loud ayağını otomatik zincirde etkisiz kılıyor** — spec §8.2'nin *"zorunlu"* şartı regresyonda **hiç ölçülmüyor**. 🔴 **AYRI EL**.
- 🟡 **D1-önleme borcu kısmen kapandı** [K82] — araç bayat kimliği **yakalar**, *"önce diskten ölç"* adımını **dayatmaz**: tespit, önleme değil.
- 🔴 **Devir notu kendi kabının kimliğini yazmamalı** [K82, ölçüldü] — beyan **yapısal olarak imkânsız**; araç `D1-OZ` ile SARI der, kural `CLAUDE.md`'ye **yazılmadı**.
- 🟡 **`oturum-sagligi.py` `DURUM.md` §3'ü görmüyor** [o38] — `D1` yalnız üç hücreli tabloyu ayrıştırır; boşluk aynı gün ısırdı. 🔴 **AYRI EL**.
- 🔴 **`pub-surum-olc.py`'ye çözümlenebilirlik ayağı gerek** [Z10b] — sürümü ölçüyor, **çözülebilirliği** değil.
- 🟡 **`radar.py` `R5`'in cümlesi kapsamını aşıyor** — kusur metinde; onarım **üst akış plugin'inde**, ayrı el.
- 🟡 **`radar --olc-urun-kodu` çalışma ağacını görmez** — yalnız commit'lenmiş farkı sayar ⇒ `R8` yandığında **önce çalışma ağacı ölçülür**.
- 🟡 **`sayi-tazeligi.py` imza↔sayı yakınlığı ölçülmüyor** [**4 kez** tetikledi; sonuncusu o51'de **ters yönde** ısırdı, iki sahte `T1`] — kuralın **iki yönü** var. Ayrı el.
- **`radar.config.json` yok ve bu bir KARAR** — eşik değiştiren K40 gereği altın kümeye vaka ekler.
- 🔴 **`belge-tavan-kapisi.py`'nin altın kümesi kapsam listesini kanıtlamıyor** [o39; **o42'de aynen tekrarlandı**] — kapsamdan bir canlı belge düşse küme **görmez**; ısırış yalnız **el ile** ölçüldü. Ayrı el.
- 🟡 **`BORCLAR.md` + `KAPILAR.md` `tek-kopya-kapisi.py` kapsamında değil** [o39/o42] — sepette **dört** kalem; kilit **beyanla** yaşıyor, regresyonunu ölçen yok.
- 🔴 **`design-token-kapisi.py` açılış protokolünde çağrılmıyor** [K86] — "çağrılmayan kapı" sınıfı aynı oturumda ikinci kez ısırdı; ekleme kararı **Onur'da**.
- 🔴 **İki ölçüm gerilemesi aynı turda kapandı, SINIF AÇIK** [K89-DÜZELTME, o42] — kimlik bloğu çapası çalındı · `_SILINECEKLER` kopyaları adı çoğalttı. **Varsayımları ölçen kapı YOK**.
- 🟡 **`oturum-sagligi.py` kapsamını beyan etmiyor** [K86] — `--transcript` ne verilirse ölçer, *"bu el benim işim değil"* demez. Ayrı el.
- 🔴 **Spec mutant tablosu, mutantı ısırtacak ayağın aritmetiğini yapmamıştı** [K86] — `G14/A4` `M75`/`M77`'ye **kördü**; kâğıt turu değil **BUILD** yakaladı (`K53/1`'i doğrular).

### Belge / defter

- **`DESIGN.md` BD‑1…BD‑7** — `K46` gereği kapatılmadı; liste spec §10'da, `BD-6`'nın bayat sayısı gerekçeli muafiyette.
- 🔴 **Defter dürüstlük kusurları** — `D3`: `docs/ADR/0003` tur 8 alanları eksik · `D2`: tur 1 atlanmış. Append-only ⇒ **düzeltme kaydı**.
- 🟡 **`D1` bu defterde kör** — artefakt adları çoğunlukla **etiket**, yol değil; yeni kayıtlara gerçek yol yazılır.
- 🟡 **İki dev KANIT dosyası** (`slice-3b/04-G3/gercek-tarama.txt` 1,9 MB · `slice-3e-iskelet/pub-lisans-kapisi.txt` 2 MB) — portfolyo yükü; kesit+sha yeterdi.
- 🔴 **Defterde `D2` boşluğu BİLEREK açık** [o37] — `uzak_degisiklik_uygulayici.dart` tur 2 yok; geriye dönük kayıt uydurmak **sahte sıfır** yazmaktır.
- 🟡 **`_start_api.cmd` `ASPNETCORE_ENVIRONMENT` set etmiyor** [o37, ÖLÇÜLMEDİ] — aksi hâlde `NullCurrentUser` ⇒ **401** (K61).
- 🔴 **Radar yapısal olarak kalıcı KIRMIZI** [o38] — `radar.py`'de park/kapatma mekanizması **yok**; onarım üst akış + ayrı el. 🔒 **`K83` (Onur): şık (4) DURDUR kilitli** — ritüel kısaldı, alarm sönmedi.
- 🟡 **`iddia-kapisi.py` hayalet kanıt sınıfı ikinci kez ısırdı** [K78] — `A8`'de ısırmadı (envanter reddi çalıştı).

### `[DOĞRULANMADI]` (ölçülmedi — "temiz" DEĞİL)

- 🟡 **CI'da .NET 10 [DOĞRULANMADI]** [K111] — geçiş tek makinede ölçüldü.
- **Kriter 9'un beyan ettiği sınırlar:** web ayağı (`--platform chrome` sonuç üretmiyor) · iOS (Mac yok) · boşaltma tavanı 20 · uygulamanın kendi ANR'si · soğuk açılış süresi · düzenleme/tamamlama/silme yollarının uzak yansıması.
- **Eski açık 5:** `flutter_secure_storage` Windows · WebKit `__Host-` · Isopoh lisansı · NIST SP 800-38D · web'de `textScaler`/tema farkı.
- **`pub.dev` uçları** dokümantasyonsuz/garantisiz (kalkan: fixture altın kümeleri) · **kontrast betiği** `araclar/` dışında.
- **Geçici artıklar (repo DIŞINDA, silme Onur'da):** `%TEMP%\_cw_*` · `C:\dev\_cowork_tmp\` · `_SILINECEKLER/o61/`, `o62/`, `o63/`.

---

## NUMARALI BORÇLAR (kimlik + tek cümle · tam gerekçe: hafıza `K160` arşivi)

- 🔴 **`B-O50-1`** — `main.dart:149` sinyal dinleyicisini ölçen kapı **yok**; `yoklama-yasagi-kapisi.py` `Y1` stream dinleyicisine **hiç girmez**, kriter 7'nin kanıtı sessizce bayatlayabilir. Sınıf: **kör kapı**.
- 🔴 **`B-O50-2`** — `sayi-tazeligi.py` **sürüm etiketini** ölçmüyor; `belge-tavan-kapisi.py` banner'ı `1.0.0`, `DURUM.md` §5/§6 `1.1.0` diyor. Sınıf: `bayat-iddia` + `kanonik-kopya`.
- 🔴 **`B-O50-3`** — `radar.py` `D2`'nin `olcum-duzeltme` **önerisi ölü**: mesaj o alanı yazmayı söylüyor ama araç `asama`'yı **hiç okumuyor** ⇒ öneriyi izleyen el bile uyarıyı susturamıyor. 🔴 Düzeltme yeri **plugin** (K57-b).
- 🔴 **`B-O51-1`** — `spec-kapi-kapsama.py` `S2`'si **dolaylı** kapı-ayak→kural eşlemesini görmüyor ⇒ her yeni spec aynı sınıfı yeniden üretir ve elle §6b borcu yazdırır. *(Dokuz kaydın kanonik yeri `GOREV-A11`/`GOREV-A12` §6b'dir, buraya kopyalanmaz.)*
- 🔴 **`B-O52-1`** — `K81` biçim standardı: ① kural yazıldı (**kapandı**) · ② **açık**: araç `hedef` sütununu **adıyla** bulmalı, bulamazsa `[S0] BİÇİM` demeli. `K53/2`: koşan kod olmadan ölçülebilir.
- 🔴 **`B-O52-2`** — `K127`'nin **mekanik kapısı yok**; kilit checkpoint'inin denetçi yolu taşıdığını hiçbir kapı zorlamıyor. Kapanış: `kilit-denetim-kapisi.py` + dört vakalık altın küme *(vakalar hafıza arşivinde)*.

### `A13` kabulünün açtığı beş borç (`K129`/`K130`, o53) — onarımlar **BUILDER'ın** işi (K34-f)
- 🔴 **`B-O53-1`** — `A13/G29/b` **kör ayak**: `Xcode build done.` hem başarı hem hata logunda geçiyor, ayırt etme gücü **sıfır**.
- 🔴 **`B-O53-2`** — mutantsız ayaklar `G27/a` · `G27/c` · `G30/b` ⇒ **körlükleri BİLİNMİYOR**; kapı-granüler araç bu boşluğu göremez.
- 🔴 **`B-O53-3`** — kriter 7'nin **dinamik** ayaklarının korunmuş aracı yok (`K44-a` ihlali); kaçan tek kör ayak tam da bu araçsız kümede.
- 🟡 **`B-O53-4`** — `G28/d`'nin `N/N` biçimi logda **lafzen yok**; gevşek `tests passed` arayan bir kapı `499 passed, 1 failed`'i **YEŞİL sayardı**.
- 🟡 **`B-O53-5`** — aksiyonlar sha'ya **pinli değil** (`@v4`/`@v2` yüzen etiket) ⇒ `A13`'ün yeşili bit-bazında tekrarlanabilir **değil**.
- 🟡 **`A13` §9/4** — Timing API ölçüldü, **kalan kontenjan [ÖLÇÜLMEDİ]** (`gh` token'ında `user` yetkisi yok).

### `SS2` v3 kilidinin borçları (`K133`, o55)
- 🔴 **`B-SS2-1`·`B-SS2-2`·`B-SS2-3`** — tam metin **spec §8'dedir**, kopyalanmaz. Kimlikler: v3→v5 migration `[DOĞRULANMADI]` · rozet iki farklı olayı aynı ikonla gösteriyor · görev silinince çakışma kaydı **yetim** kalır.
- 🔴 **`B-SS2-4`** — `spec-kapi-kapsama.py` *"mutant ISIRIR mı"* diye **sormuyor**; **eşdeğer mutant onun için YEŞİLDİR**. Aynı ders üç tur üst üste alıntılanıp uygulanmadı. 🔴 Araç ürün kodu sayılmaz (`K53/4`) ⇒ `R8` sönmeden açılamaz.
- 🟡 **`B-SS2-5`** — `M172`'nin *beklenen* metni gerçeği tarif etmiyor (spec 1 ayak bekliyor, ölçülen **beş**); sınıf `beyansız-sınır`, kilit **açılmadı**.

### `W1` borçları (`K137`, o57–o58)
- 🟡 **`B-W1-1`·`B-W1-2`** — tam gerekçe **spec §6b'de**: `W1/G38/b` mutantsız · `W1/G37/c` mekanik kapısız (belge disiplini).
- 🔴 **`B-W1-3`** — `radar --olc-urun-kodu` **satıcı varlığını ürün kodu sayıyor**: `W1`'in 6.773 satırının **6.743**'ü indirilmiş `drift_worker.js` ⇒ `R8` tek satır insan kodu yazılmadan sönebilir. 🔴 Onarım `radar.py`'de ⇒ **K57-b'yi bozar**, ayrı el.
- 🟡 **`B-W1-4`** — pin ↔ `pubspec.lock` sürüm kapısı yok; `web-varlik.sha256` **TOFU**'dur, sürüm karşılaştırmaz.
- 🔴 **`B-W1-5`·`B-W1-6`·`B-W1-7`** — tam metin `KANIT/W1/03-DENETIM-o58-BULGULAR.md`'de. `G35/b` `IsDevelopment()`'ı **hiç aramıyor** ⇒ *CORS yalnız Development* kararı kapısız · `M193b` **sahte-geçiş** (kusur önce SPEC'te) · koşucu/kapı kusurları.

### o61 borçları (`K151`/`K152`/`K153`)
- 🟡 **`B-O61-1`** — `tek-kopya-mutant.py` **ortama göre farklı**: sandbox 10/11, Windows 11/11; belge ortam eki taşımıyor ⇒ her Cowork koşumu `T1b` SARI verir. 🔴 Windows koşumu o61'den beri **doğrulanmadı, devralındı**. *(o63'te yine ısırdı.)*
- 🔴 **`B-O61-2`** — `CLAUDE.md:116`'da **araç adı olmayan** altın küme iddiası (`5/5`) ⇒ `sayi-tazeligi.py` `T5: BAĞLANAMADI`. *(o63'te yine ısırdı.)*
- 🟡 **`B-O61-4`** — `hafiza-dizin.py` mount'ta `os.remove` ile düşüyor (`PermissionError`); yazım tamamlanıyor ama `.yedek` kalıyor.
- 🟢 **`B-O61-3` · `B-O61-5` · `B-O61-6` KAPANDI** (gövdeleri hafızada) — 🔴 ama `B-O61-3`'ün **sebebi** kapanmadı (DC yoksa commit yok) ve `B-O61-6`'nın kararı `B-O62-1`'i doğurdu.

### o62 borçları — yürüyen iskeletin açtığı dokuz
- 🔴 **`B-O62-1`** — `K155` (*"kapı AYAĞI borçlanamaz"*) **kapısız**, prozada yaşıyor; araç ayağı kural sanıp *"envanterde yok"* diyor.
- 🟢 **`B-O62-2` — KAPANDI (o66, 8 Ağu 2026).** `verify.ps1` Onur'un makinesinde **Windows'ta İLK KEZ** koştu: **EXIT 0**, build **0 uyarı/0 hata**, test **120/120** (5+15+44+56), CVE **0**, SDK `10.0.302`; ham çıktı `KANIT/W3b/01-verify-ps1-ham.txt`. **Dört oturum açık kaldı.** Aşağıdaki tarihçe kayıt için duruyor. ~~ÜÇÜNCÜ OTURUM AÇIK.~~ Ürün kodu **Onur'un makinesinde derlenmedi**; `verify.ps1` koşulmadı. 🟢 o63'te **bulutta** ölçüldü: gerçek PostgreSQL + docker daemon ile `dotnet test Momentum.sln` ⇒ **120/120, 0 hata**; düşen tek testin (`D9…_kalir`, **fail-loud** `MOMENTUM_KANIT_DIZIN`) **o63 regresyonu olmadığı pozitif kontrolle** kanıtlandı. 🔴 Ama `verify.ps1` bir **PowerShell zinciridir** ve Windows'ta hâlâ koşmadı ⇒ borç **kapanmadı**.
- 🟡 **`B-O62-3`** — `izolasyon-olc.py`'nin `T` ayağı cihazda ölçülemez (playwright yok); **beyan edilmiş** sınır.
- 🟡 **`B-O62-4`** — `OnStarting` kararının mutantı yok; iddia **okunarak** yazıldı, ölçülmedi.
- 🟡 **`B-O62-5`** — `oturum-sagligi.py` `CANLI_BELGELER`'de `KIMLIKLER.md` yok ⇒ `S2`/`S3` orayı taramıyor.
- 🟡 **`B-O62-6`** — defter kaydı eksikliği o60'ta da var (`W3` tur 2 yazılmadı) ⇒ `R2`/`R4` eksik seriden hesaplanıyor. **Sınıf `defter-dürüstlüğü`, ikinci ısırış.**
- 🟡 **`B-O62-7`** — `K61` kalkanı web'de SignalR **WebSocket'ini kapatıyor** (pozitif kontrolle COOP/COEP **suçsuz**); `SSE`/`LongPolling` **ÖLÇÜLMEDİ**.
- 🔴 **`B-O62-8`** — `B-11` (atomik olmayan göç) **hâlâ ölçülmedi**; `T5` açılırsa **ÖNCE** bu ölçülür.
- 🟡 **`B-O62-9`** — `/scalar/v1`'i kapsayan ayak yok; bir üst Scalar sürümü CDN'e dönerse `require-corp` altında **sessizce** kırılır.

### o63 borçları — istemcinin izolasyonunun açtığı dört (`K159`)

- 🔴 **`B-O63-1` — GÖLGELEME KAPISI YOK.** İstemci kökünde bir API öneki **adında dosya** bulunursa `UseStaticFiles` o uç noktayı gölgeler; ölçüm o63'te **bir kez** koştu (21 vaka, temiz), **mekanik kapı yok**. 🔴 Taslak `S` ayağı yazıldı ama **denetimde düştü** (`B-O63-5`): dizin ile dosyayı ayırmıyor, okunamayan dizinde sahte kırmızı veriyor.
- 🔴 **`B-O63-2` — `--no-web-resources-cdn` CI'DA ZORLANMIYOR.** o63'te ölçüldü: Flutter'ın **varsayılan** build'i CanvasKit'i `gstatic`'ten çeker ve `require-corp` CORP'suz çapraz kaynağı **fiilen bloklar** (pozitif+negatif kontrollü). Bayrak bir tercih değil **kapı şartıdır**. 🟢 Taslak `B` ayağının çekirdeği **gerçek CDN/yerel build çiftiyle doğrulandı** — ama `canvasKitBaseUrl` yazım kapsamı eksik (`B-O63-5`) ve CI'ya **bağlanmadı**.
- 🟡 **`B-O63-3` — `SpaDisiOnEkler` LİSTESİNİN TAZELİĞİ ÖLÇÜLMÜYOR.** Liste elle yazıldı; yeni bir kök yol eklenirse **sessizce bayatlar**. 🔴 Taslak `F` ayağı yazıldı ve **denetimde düştü**: kapsama testi alt-dize olduğu için `/health` → `/healthz`'i yutuyor ve **F'nin tek varlık sebebi olan mutant kapıdan geçti**.
- 🔴 **`B-O63-5` — `izolasyon-olc.py`'nin `B`/`S`/`F` TASLAĞI DENETİMDE DÜŞTÜ: 16 BULGU (o63).** Taslak **altın kümesini 25/25 geçti** ve **dört gerçek-depo mutantını ısırttı**, yine de **kördü**; `K26` gereği salınan iki bağımsız denetçi kırdı. **`araclar/`'a KONULMADI**, `KANIT/W3/06-KAPI-TASLAGI-DENETIMDE-DUSTU-o63.py`'de **saklandı**. 🔴 **Onarım `K34-f` gereği AYRI ELE aittir** (taslağı Cowork o63 yazdı). Bulguların tam metni: Cowork projesi `oturum-63-K159-kapisi-DENETIMDE-DUSTU-16-bulgu.md`; özet `KANIT/W3/05-…o63.md` §4. **En az şunlar kapanmadan araca alınmaz:** segment-bazlı kapsama · `_cs_bul` `bin`/`obj` + çoklu aday · karakter-literali/ham-dize yorum sıyırıcı · `canvasKitBaseUrl` yazım kapsamı (tek tırnak + protokol-göreli) · `app.Map*` alıcı ayrımı · `[Route]` sınıfı · **ÖLÇÜLEMEDİ ⇒ sıfır-olmayan çıkış kodu** · dizin/dosya ayrımı.
- 🔴 **`B-O63-6` — `K161`'İN DERSİNİ ZORLAYAN KAPI YOK: "vaka ölçmek sınıf kapatmaz".** `K159-c` bir vakayı (`/v1/BULUNMAYAN-UC`) ölçüp sınıfı kapandı sandı; `/v2` **canlı kaldı** ve bunu iki bağımsız denetçi buldu. Hiçbir kapı *"ölçülen vaka, iddia edilen sınıfı kapsıyor mu?"* diye sormuyor. Kapanış yolu **açık değil** — mekanikleşmesi zor olabilir; en azından checkpoint disiplini olarak yazıldı.
- 🟡 **`B-O63-4` — `index.html` `no-store` GÖNDERMİYOR.** SPA kabuğu önbelleğe girebilir ⇒ kullanıcı bayat kabukla kalır. o63'te **ölçülmedi ve karar verilmedi**; ölçüm tarafı taze tarayıcı bağlamıyla çözüldü, **ürün tarafı açık**.

- 🔴 **`B-O64-1` — `tek-kopya-mutant.py` `M2b` ÖLÜ KURGU (o64'te ölçüldü).** `M2b` `ham[:-1]` ile son baytı siler ve geriye bir `CR` kalmasını varsayar; dosyalar **LF** (`.gitattributes` `* text=auto eol=lf`, repo-yerel `core.autocrlf` TANIMSIZ, `PROJE_HAFIZA.md` CRLF **0**) ⇒ mutasyon **gerçek içerik siliyor**, kapı haklı olarak `S2` veriyor ve mutant **Windows'ta da düşer**. Önceki *"sandbox 10/11 / Windows 11/11 ortam ayrımı"* açıklaması **ölçülmemiş bir varsayımdı** (`olcum-aracinin-varsayimi`). **Onarım:** `M2b` son baytı silmek yerine tüm `LF`'leri `CRLF` yapsın — normalize içerik özdeş, ham bayt farklı ⇒ kapının `S10` ayağı gerçekten ısırır. `K34-f`: onaran el mutantı yazan elden ayrı olmalı.
- 🟡 **`B-O64-2` — `KANIT/o60/_olu_hash_avi.py` KÖKÜ SABİT WINDOWS YOLUYLA YAZIYOR.** `KOK = C:\dev\Momentum` gömülü ⇒ sandbox/mount'ta `FileNotFoundError` ile düşer, yani `CLAUDE.md`'nin `5/5` iddiası **bu ortamda yeniden üretilemez**. Bu yüzden `sayi-tazeligi.py` için gerekçeli muafiyet açıldı (`araclar/tazelik-muafiyet.json`); muafiyet **sessiz değildir**, kök parametreleşince silinir.

- 🟡 **`B-O64-3` — ENVANTER SAYISINI ÖLÇEN KAPI YOK.** `DURUM.md` §6'nın *"N dosya / M çalıştırılabilir / tablo K satır"* sayıları o58'den o64'e kadar **dördü birden** bayat kaldı (`izolasyon-olc.py` o62'de doğdu); hiçbir kapı görmedi. `envantersiz-kapı` sınıfının kardeşi: sayıyı `araclar/`'ı **sayarak** doğrulayan bir ayak `sayi-tazeligi.py`'ye eklenebilir.
- 🟡 **`B-O64-4` — `DURUM.md` §2 ADIM 7 MOUNT SINIRINI BİLMİYOR.** Tüm-ağaç `git status`/`git diff` mount'ta 45 sn tavanını aşıyor ve **bayat `index.lock` bırakıyor**; daraltılmış komutlar `ORTAM.md`'de yazılı ama **protokol adımı hâlâ dar olmayan komutu** söylüyor. o64 bu mayına **fiilen bastı**. Tavan dar olduğu için adım 7 bu turda genişletilmedi.

- 🟡 **`B-O64-5` — `KANIT/W3/` NUMARA ÇAKIŞMASI.** `00` ve `03` indeksleri **iki ayrı belgeye** işaret ediyor (ölçüm dosyaları vs `K127` denetim raporları): `01` *"`03-DENETIM-v2-o60.md`"*, `02` *"`00-DENETIM-o60.md`"* der; diskteki `00`/`03` ise **ölçümdür**. ⇒ `B1`/`B-2`/`B-6`/`B-11`/`BLOKER-3`/`MAJOR-*` etiketlerini tanımlayan belgeler **izlenemiyor** (o64 denetçisi, bulgu A-17). Kapanış yolu **yeniden adlandırma DEĞİL** (atıflar kırılır), **indeks dosyası**.
### `W3b` BORÇLARI (o66'da beyan edildi — kabul hükmü `KANIT/W3b/06-KABUL-HUKMU-COWORK.md`)
- 🟢 **`B-W3b-1`…`B-W3b-5` KAPANDI (o66).** `1` kabul kriteri 8'le (canlı `GET /` + negatif kontrol), `2` kriter 5'in dar komutuyla, `3` **kısmen** (canlı yarı koştu, tarayıcı yarısı `B-W3b-6`'ya devretti), `4` `M254` ile, `5` kapı karşılaştırmasıyla.
- 🟡 **`B-W3b-6` — NEGATİF KONTROL BİR KATMAN YUKARIDA PATLADI.** Kriter 8/③ `GET /` **404** ölçtü (kriter **karşılandı**) ama gözlenen mekanizma `N4`'ün tarif ettiği `Path.GetFullPath("wwwroot")` yanlış çözümü **değil**, content-root'ta `appsettings.json`'un bulunamaması ⇒ `Istemci:KokDizin` **hiç okunamadı**. Temiz izolasyon: yanlış CWD **+** `Istemci__KokDizin` **ortam değişkeniyle verilir**; o zaman tek değişken göreli yol çözümü kalır. 🟢 **Claude Code bunu KENDİ yazdı, gizlemedi**; Onur beyanlı sınır olarak **kabul etti** (o66).
- 🟡 **`B-W3b-7` — `W3b/G51/b2` YORUMU GÖVDE KODUNDAN AYIRT ETMİYOR.** `MW23` ölçtü: `// canvasKitBaseUrl` yorumu geçiş sayısını **2 → 3** yapıp taban pinini **SARI** yaktı. 🟢 Asıl ölçüm sağlam: `G51/b` **hiç fire etmedi** ⇒ sahte-pozitif yok. Kriterin lafzı (*"hiçbir KIRMIZI"*) karşılandı.
- 🟡 **`B-W3b-8` — `_BUILD.json` CRLF=9.** `araclar/web-yayina-al.py` Windows'ta **metin modunda** yazıyor (`ORTAM.md` #48'in sınıfı). Build çıktısı + git-ignore'lu ⇒ zararsız, ama **bizim kodumuzun** kusuru. Kapanış: `"wb"` + LF.
- 🟡 **`B-W3b-9` — `KANIT/W3b/__pycache__` izlenmiyor ve `.gitignore`'da karşılığı yok.**
- 🔴 **`B-W3b-10` — `_mutant_kosucu.py` (Claude Code) `KOK`'u SABİT WINDOWS YOLUYLA yazıyor** (`C:\dev\Momentum`) ⇒ mount'ta `FileNotFoundError`; **`B-O64-2` ile AYNI SINIF, ikinci kez.** Onarım `K34-f` gereği **ayrı ele** verildi (`KANIT/W3b/_mutant_kosucu_cowork16.py`); üreticinin dosyası **kayıt için** olduğu gibi duruyor ve **hâlâ taşınabilir değil**.

### o63 ortam bulgusu (borç değil, **operasyonel uyarı**)
- 🔴 **Mount'ta tüm-ağaç `git status`/`git diff` `device_bash`'in 45 sn tavanını AŞIYOR** (EXIT 124); sebep `--no-optional-locks`'ın indeksi tazeleyememesi + `core.autocrlf` dönüşümü. Açılışta hızlıydı, iş bittikten sonra aşmaya başladı. **Çalışan daraltılmış ölçüm:** `git ... diff --name-only -- <tek dosya>` · `git ... ls-files --others --exclude-standard -- <dizin>`. `DURUM.md` §2 adım 7 bunu **bilmiyor**. 🔴 **o66 DÜZELTMESİ — bu satır fazla iyimserdi:** dar komutlar **tek tek** kilit bırakmıyor (üç kontrollü izolasyon testi) **ama art arda koşulunca bırakabiliyor** — o66'da **iki kez** oldu (biri 23 çağrıdan, biri **yalnız 2** çağrıdan sonra); hangi çağrının bıraktığı **İZOLE EDİLEMEDİ**. ⇒ **her git ölçüm turunun sonunda `.git/index.lock` YOKLANIR.**

### o71 BORÇLARI (kabul hükmü `KANIT/o71/08-KABUL-HUKMU-COWORK.md`)
- 🔴 **`B-O71-1` — `W3/G43`+`G44` KAPSAMI ÜRÜNLE AYRIŞMIŞ.** Her iki kapının ilan edilmiş kapsamı **`Program.cs`**; oysa statik servis çağrıları (`UseDefaultFiles`/`UseStaticFiles`/`MapFallbackToFile`) `Web/IstemciServisi.cs`:111,112,122'de, başlık sabitleri `Web/IzolasyonBasliklari.cs`'te. `G44/d` (*"`Program.cs` dışında `Cross-Origin-` geçmiyor"*) bugün koşsa **ürün doğruyken KIRMIZI** verirdi — spec'in `M230` ile `G44/d` için öngördüğü kaçak, `G43` için **öngörülmemişti**. Onur o71'de **borç yazılmasını** kilitledi (ürünü spec'e taşımak `K159`'u bozardı, spec'i güncellemek `R8` altında kâğıt turudur). Kapanış: `T6` kapısı yazılırken kapsam **`Program.cs` + `Web/**`** olarak ölçülür.
- 🟡 **`B-O71-2` — BİR TEST, KOMMİT EDİLMİŞ KANITI HER KOŞUMDA ÜZERİNE YAZIYOR.** `tests/Momentum.Persistence.Tests/D9OwnerIdVisibilityTests.cs`, `KANIT/slice-3d/07-G7-backend-zorlama/outbox-sorgu.txt`'i **rastgele GUID'lerle** yeniden üretiyor ⇒ ① her `verify.ps1` çalışma ağacını kirletiyor ② `slice-3d`'nin kabulünde gösterilen kanıt artık **o baytlar değil** ③ değişiklik o71'in ürün commit'ine **ilgisiz olarak sızdı** (`d6c87c7`). Sınıf: *kanıtın kendini üzerine yazması*. Kapanış: test kanıtı `TestResults/` altına yazsın, depoya değil. `K34-f`: onarım **ayrı ele**.
- 🟡 **`B-O71-3` — `oturum-sagligi.py` `D1` DEVİR BLOĞU AYAĞI ÖLÇEMİYOR.** o71 açılışında `d1_devir_blogu` *"kimlik girişi AYRIŞTIRILAMADI ⇒ ÖLÇÜLEMEDİ"* verdi (bu **TEMİZ değildir**). Ayak, hafızadaki devir notunun kimlik bloğunu tanımıyor; biçim değişmiş ya da ayrıştırıcı dar. Kapanış: bloğun **fiili** biçiminden bir fikstür çıkarılıp altın kümeye vaka eklenir.
- 🟡 **`B-O71-4` — *"implementasyon yok"* SINIFINI ÖLÇEN KAPI YOK.** `DURUM.md` §4 dört oturum boyunca *"`W3/G43`–`G47` implementasyonu yok"* dedi; `T1`/`T2` fiilen vardı, `T3` kısmiydi, `T4` başka dosyadaydı (o71'de ölçüldü, `K185`). `sayi-tazeligi.py` yalnız *"altın küme N/M"* iddialarını ölçer; **varlık/yokluk iddiaları kapısızdır**. `B-O64-3`'ün kardeşi.
