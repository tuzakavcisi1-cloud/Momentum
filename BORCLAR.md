# BORCLAR.md — Momentum · AÇIK BORÇLAR (adlandırılmış, gizlenmemiş)

> 🔴 **AÇILIŞTA OKUNMAZ.** Bu dosya `DURUM.md` §8'den **30 Tem 2026'da (oturum 39, Onur'un kilidi K83)** ayrıldı.
> Açılış protokolü **`DURUM.md` + `CLAUDE.md`** ile sınırlıdır; burası yalnız **iş bir borca dokunduğunda** açılır
> (`PROJE_HAFIZA.md` ayrımının aynısı).
> **TAVAN: ≤ 16.384 b.** Gerekçe `DURUM.md`'nin tavanından **farklıdır ve büyümeyi ÖDÜLLENDİRMEZ:** bu liste
> büyüdüğünde kapının ısırması **doğru sinyaldir** — borç kapanmıyor demektir. Ayrım anındaki içerik **10.395 b**.
> Eşik değişikliği K40 gereği **Onur'dan** gelir ve `belge-tavan-kapisi.py`'nin altın kümesine vaka eklemeyi zorunlu kılar.
> **Kapanan kalem buradan ÇIKARILIR**, gerekçesi `PROJE_HAFIZA.md`'ye yazılır (K71 emsali). Kapanmış bir kalemi
> burada aramak **bayat okuma üretir**.

---

> 🔴 **KAPANMIŞ kalemler ve BAYAT çıkan altı iddia buradan ÇIKARILDI** ⇒ `PROJE_HAFIZA.md` **K71**
> (28 Tem 2026, oturum 35). Bu bölüm yalnız **bugün açık olanı** taşır. Kapanmış bir kalemi burada
> aramak bayat okuma üretir; gerekçesi arşivdedir.

### Ürün / kod

- 🔴 **SABİT `sleep` BİR ÖLÇÜM DEĞİLDİR [oturum 35 — KENDİ ölçüm kusurum].** Cihaz doğrulamasında 22 sn bekleyip **yanlış KIRMIZI** verdim; görev birkaç saniye sonra inmişti. Daha kötüsü: kriter 9'un ilk ölçümü (K71) 15 sn ile **geçmişti — o geçiş titizlik değil ŞANSTI.** Cihaz ölçen her betik **koşula kadar yoklamalı** (tavanlı), sabit uyumamalı.
- 🔴 **`iddia-kapisi.py` İKİLİ DOSYALARI METİN GİBİ TARIYOR [oturum 35].** 89.628 b'lik bir PNG'nin rastgele baytları `\bM\d\b` desenine denk düşüp **dört hayalet kanıt** üretti. Bugün yanlış-pozitif; **tehlikeli yönü ters:** büyük bir ikili dosya `M41` desenine denk düşerse kapı o mutantın kanıtı **varmış gibi** sayar ⇒ **kanıt-kazayla-sağlanır**. Onarım: yalnız metin uzantıları taransın. 🔴 **AYRI ELE (K34-f)** — aracı Cowork yazdı (K67).
- 🔴 **[K76] Taban rozet metni 1.0× ölçekte BİLE KIRPILIYOR** ("Gönderilmemiş de…", "Çevrimdışısın…"; cihaz PNG'lerinde, oturum 37'de yeniden görüldü). `DESIGN.md` v2 açık kalemi `A-7` ilk koşumda ısırdı; **2.0× (A11Y-4) ÖLÇÜLMEDİ**. Bileşik satırda iki rozet yan yanayken yer daralıyor.
- 🟡 **[K76] Satırın `content-desc`'i rozet metnini İKİ KEZ taşıyor** (`Semantics(label:)` + `Text` çocuğu) ⇒ ekran okuyucu tekrar okur. · 🟡 **[K76] Cihaz kanıtındaki `zehirli` kuyruk kaydı SQLite'a SEED EDİLDİ** — render gerçek widget ağacı, **sentetik olan veridir**.
- 🟡 **`tazelik-muafiyet.json`'daki `BD-6` GEREKÇESİ BAYATLADI [oturum 36].** Muafiyet *"DESIGN.md K46 ile DONDURULMUŞTUR"* diyor; **K46 açıldı** (K75). Muafiyet hâlâ geçerli ama **gerekçesi doğru değil**. 🔴 **AYRI ELE (K34-f)**.
- 🔴 **`KANIT/slice-3c/02-G2/` GERİ DOĞDU ve ÜRETİCİ KOD DÜZELTİLMEDİ.** `g2_registry_zarf_kapisi_test.dart:64` hâlâ `Directory('../../KANIT/slice-3c/02-G2')` yazıyor. Silmek düzeltme DEĞİLDİR. 🔴 **İkinci yazıcı da ölçüldü:** `g3_ayristirici_kapisi_test.dart:20`. Hiçbir araç *"KANIT dizini ile onu yazan kodun yolu aynı mı?"* diye sormuyor ⇒ sınıf tek vaka değil. Gerekçe: hafıza K71/K78.
- 🟡 **Son sayfa tam `PageSize` ise BİR BOŞ TUR fazladan koşar** — `hasMore = (changes.Count ==
  PageSize)`, `PageSize=500` sabit. Veri kaybı değil, **maliyet**.

- 🔴 **ÇAĞRILMAYAN KAPI SINIFI [ÖLÇÜLDÜ, oturum 39 — YENİ SINIF].** `sayi-tazeligi.py` bir kapıydı, altın kümesi
  16/16 geçiyordu, **ama açılış protokolünde YOKTU.** Oturum 39 açılışında elle koşuldu ve **KIRMIZI** verdi:
  `DURUM.md` iki yerde `oturum-sagligi.py 25/25` diyordu, araç fiilen **26** vaka taşıyor. Kör kapı değil —
  **çağrılmayan kapı**; sonucu aynı: ölçüm var, hüküm görülmüyor. `sayi-tazeligi.py` §2'ye **EKLENDİ**, ama
  **sınıf kapanmadı:** `design-token-kapisi.py` (18/18, `DESIGN.md` ↔ Dart token sözleşmesi — **canlı** bir kapı),
  `iddia-kapisi.py` ve `hafiza-dizin.py` de açılışta **çağrılmıyor**. Hangi kapının hangi olayda (açılış /
  checkpoint / dilim kapanışı) koşacağını **hiçbir yer beyan etmiyor** ⇒ protokol elin hafızasına bağlı.
  Onarım bir *araç* değil, bir **kapı-tetik tablosu**; kapsam kararı **Onur'da**.

### Araç / kapı

- 🔴 **`verify.ps1` FAIL-LOUD AYAĞINI OTOMATİK ZİNCİRDE ETKİSİZ KILIYOR.** `if (-not $env:MOMENTUM_KANIT_DIZIN) { … }` varsayılan atıp dizini yaratıyor; spec §8.2'nin *"zorunlu"* şartı regresyon zincirinde **hiç ölçülmüyor**. Araç değişikliği ⇒ **ayrı el (K34-f)**.
- 🟡 **D1-ÖNLEME BORCU — KISMEN KAPANDI [K82].** `oturum-sagligi.py` bayat kimliği artık **yakalar**
  (yazım anıyla karşılaştırarak), ama sayı yazan betiklere *"önce diskten ölç"* adımını **dayatmaz**:
  bu **tespit**tir, önleme değil.
- 🔴 **DEVİR NOTU KENDİ KABININ KİMLİĞİNİ YAZMAMALI [K82, ölçüldü].** Not `PROJE_HAFIZA.md 684.530 b`
  diyor, yazım anında **691.599 b** — notu yazmak dosyayı büyütür ⇒ beyan **yapısal olarak imkânsız**.
  Araç `D1-OZ` ile SARI der; kural henüz `CLAUDE.md`'ye **yazılmadı** (Onur'un kilidi).
- 🟡 **`CLAUDE.md` K53/4 hâlâ `R7` diyor [ölçüldü, oturum 38]** — kural K57'de **`R8`** oldu, radarın
  ürettiği kod da `R8`. Pazarlıksız kurallar bloğunda bayat araç adı.
- 🟡 **`oturum-sagligi.py` `tek-kopya-kapisi.py` kapsamına EKLENMEDİ** — eklemek kapının kilitli sha'sını
  bozar + 11/11 mutantı yeniden koşturur; `GOREV-slice-3e-G12.md` ile **aynı beyanlı-kilit** durumu.
- 🟡 **`oturum-sagligi.py` §3'ü GÖRMÜYOR [ölçüldü, oturum 38].** `D1` yalnız ÜÇ hücreli kimlik tablosunu
  ayrıştırır; §3'ün iki hücreli satırları **kapsam dışı**. Boşluk aynı gün ısırdı: §3 `DESIGN.md` v1
  `534DFF68`'i (§9'un **GEÇERSİZ** dediği sha) ve `156/156`'yı (gerçek **171/171**) taşıyordu — ikisi de
  **elle** bulundu, araçla değil. Onarım **ayrı ele (K34-f)**.
- 🔴 **`araclar/hafiza-dizin.py` K60'I İHLAL EDİYOR** — son satırı `io.open(yol,"w").write(metin)`; hedefi 665 KB'lik arşiv ve o dosyaya yazan **tek** araç. K60 tam da bu desenden doğdu. Onarım **ayrı ele (K34-f)**.
- 🔴 **`pub-surum-olc.py`'ye ÇÖZÜMLENEBİLİRLİK AYAĞI [Z10b]** — araç **sürümü** ölçüyor,
  **çözülebilirliği** ölçmüyor. Kalkan gelene dek her pin `pub get` ile doğrulanır.
- 🟢 **`tek-kopya-kapisi.py` BEYAN EDİLMİŞ SINIRI [S10]** — karşılaştırma **LF'e normalize** içerik üzerinden (`core.autocrlf`); yalnız satır sonunu kaybeden dosya kapıyı geçer (M2b).
- 🟡 **`radar.py` R5'in CÜMLESİ KAPSAMINI AŞIYOR** — artefaktın kaydını okur ama *"**projenin** görünen çıktısı %0"* der. Kusur **metinde**; onarım üst akış plugin'inde, **ayrı el** (K34-f).
- 🟡 **`radar --olc-urun-kodu` ÇALIŞMA AĞACINI GÖRMEZ** — yalnız commit'lenmiş farkı sayar ⇒ R8 yanlış-pozitif olabilir; R8 yandığında **önce çalışma ağacı ölçülür.**
- 🟡 **`sayi-tazeligi.py` İMZA↔SAYI YAKINLIĞI ÖLÇÜLMÜYOR** [3 kez tetikledi]; eşik uydurulmadı (K40), onarım **ayrı ele** (K34-f).
- 🟡 **M2b beyanının TERSİ ölçüldü** — A-4 *"çok satırlı yorumdaki literal KAÇABİLİR"* diyordu; kapı **yakaladı** ⇒ `yorum_disi()` yorumu soymuyor (yanlış-pozitif yönü).
- **`radar.config.json` YOK ve bu bir KARAR**; eşik değiştiren K40 gereği **altın kümeye vaka ekler.**

- 🔴 **`belge-tavan-kapisi.py`'NİN ALTIN KÜMESİ KAPSAM LİSTESİNİ KANITLAMIYOR [ÖLÇÜLDÜ, oturum 39].**
  Dokuz vakanın hepsi `denetle()` saf fonksiyonunu sentetik ölçümlerle (`_o(...)`) sınar; **`VARSAYILAN_KAPSAM`
  listesine hiç dokunmaz.** Ölçümün kanıtı: `BORCLAR.md` kapsama eklendi ve altın küme **9/9 olarak DEĞİŞMEDİ** —
  yani kapsamdan bir canlı belge **düşse** bu küme onu **GÖRMEZ**. Boşluk `sayi-tazeligi.py`'de bugün ısıran
  *"çağrılmayan kapı"* sınıfının kardeşi: **ölçülmeyen kapsam, ölçülmeyen kapıdır.** Bu oturumda kapsamın fiilen
  ısırdığı **dört diskte-koşan mutantla** kanıtlandı (`T1` tavan+1 b · `T2` pay 684 b · gerçek boyut sessiz ·
  `T0` dosya yok) — ama bu **tek seferlik el kanıtıdır**, kümede yaşamıyor. Onarım **ayrı ele (K34-f)**.
- 🟡 **`BORCLAR.md` `tek-kopya-kapisi.py` KAPSAMINDA DEĞİL [oturum 39].** Yeni bir **canlı** belge doğdu ve
  regresyon kapısı (`S0`–`S10`) onu izlemiyor ⇒ bu dosya sessizce 0 bayta düşse kapı **susar**. Eklemek aracın
  §9'da **donmuş** sha'sını (`66AC9CA3`) bozar ve `11/11` mutantı yeniden koşturmayı gerektirir — bu yüzden
  `oturum-sagligi.py` ve `GOREV-slice-3e-G12.md` ile **aynı beyanlı-kilit** sepetinde: kilit **beyanla** yaşıyor.

### Belge / defter

- **`DESIGN.md` BD‑1…BD‑7** — **K46 gereği kapatılmadı**; liste spec §10'da. BD‑6'nın bayat sayısı
  `sayi-tazeligi.py`'de **gerekçeli muafiyet**.
- 🔴 **Defter dürüstlük kusurları** — `D3`: `docs/ADR/0003` tur 8 kaydının zorunlu alanları eksik ·
  `D2`: aynı defterde **tur 1 atlanmış**. Append-only ⇒ **düzeltme kaydı** (28 Tem 2026 radarında
  hâlâ SARI yanıyor).
- 🟡 **`D1` bu defterde KÖR** — artefakt adları çoğunlukla **etiket**, yol değil. Yeni kayıtlara
  **gerçek yol** yazılır.
- 🟡 **`KANIT/slice-3b/04-G3/gercek-tarama.txt` 1,9 MB** ve **`KANIT/slice-3e-iskelet/pub-lisans-kapisi.txt` 2 MB** — portfolyo yükü; kesit+sha yeterdi.

- 🔴 **DEFTERDE `D2` BOŞLUĞU BİLEREK AÇIK BIRAKILDI [oturum 37].** `uzak_degisiklik_uygulayici.dart` defterde tur 1 (oturum 34) ve tur 3 (oturum 35) taşıyor, **tur 2 YOK**. Geriye dönük kayıt uydurmak `bulgu/kapatilan/uretilen` alanlarına **sahte sıfır** yazmak olurdu ⇒ ölçüm aracını kasten körleştirmek. Boşluk **beyan edildi**, `D2` SARI kalıyor.
- 🟡 **`_start_api.cmd` `ASPNETCORE_ENVIRONMENT` SET ETMİYOR [oturum 37, ÖLÇÜLMEDİ].** `Program.cs` `IsDevelopment()` ile `DevCurrentUser` açıyor (K61), aksi hâlde `NullCurrentUser` ⇒ 401. `dotnet run --no-launch-profile`'ın ortamı Development'a düşürüp düşürmediği **ölçülmedi**; oturum 37'de değişken **elle** set edilerek koşuldu ve `/v1/tasks` başlıksız **401** / başlıklı **200** ölçüldü.

- 🔴 **`_start_api.cmd` KANIT DİYE GÖSTERİLİYOR AMA VERSİYON KONTROLÜNDE DEĞİL [ölçüldü, oturum 38].** `CLAUDE.md` K80, `KANIT/slice-3d/09-MUTANT/_start_api.cmd`'yi *"Claude Code ortamı zaten kaldırabiliyor"*un kanıtı sayıyor; dosya `git status`'ta **`??`**. Temiz bir klonda doktrinin gösterdiği kanıt **YOK**. Ya commit'lenir ya atıf düzeltilir — repo değişikliği, karar **Onur'da**.
- 🟡 **İZLENMEYEN DOSYA SAYISI: 77 [yeniden ölçüldü, oturum 39 — oturum 38'de 92'ydi].** `KANIT/R9/_tmp_*` · `KANIT/slice-3d/09-MUTANT/_tmp_*` · `KANIT/slice-3c/02-G2/` · `src/client/test/_debug_join_test.dart` + `_tmp_sqlite_version_test.dart`. 🔴 **`.gitignore` deseni ÖNERİLMEDİ**, gerekçesi ölçüldü: `_` önekli bazı dosyalar doktrinin **kanıtıdır** (üstteki madde) — geniş desen kanıtı gizler. İki ölü test dosyası **`void main() {}`** ⇒ **0 test bildiriyor**, `171/171` bozulmamış: *şüphe ölçümle ÇÜRÜTÜLDÜ*. Silme **Onur'da** (sandbox silemiyor).
- 🔴 **RADAR YAPISAL OLARAK KALICI KIRMIZI [ölçüldü, oturum 38].** `radar.py`'de defter kaydını **park/kapatma mekanizması YOK** (`urun_kodu_haric` yalnız ürün-kodu sayımına ait). `docs/ADR/0003` (9 tur) ve `GOREV-slice-3b-spec` (7 tur) kayıtları **asla iyileşemez** ⇒ hüküm her açılışta KIRMIZI, dört-şık ritüeli her oturum aynı cevabı üretir. **Sürekli yanan alarm kör kapıya dönüşür.** Onarım `radar.py`'de ⇒ K57-b bayt-özdeşliğini bozar ⇒ **üst akış plugin'i + AYRI EL (K34-f)**. 🔒 **K83 (Onur, 29 Tem 2026):** bu KIRMIZI'ya karşı şık **(4) DURDUR** kilitlendi — kâğıt artefaktlar park, oturum görünen çıktıya geçti. **Borç KAPANMADI:** kilit ritüeli kısaltır, alarmı söndürmez.
- 🟡 **`iddia-kapisi.py` HAYALET KANIT SINIFI İKİNCİ KEZ ISIRDI [K78].** `KANIT/slice-3e-iskelet`'te tabloda **sıfır** mutant varken **altı** hayalet buldu (`M111, M6, M7, M8, M8p, M9`) — kaynak 2 MB'lık `pub-lisans-kapisi.txt` + PNG/sqlite baytları. Aynı dizindeki o 2 MB'lık dosya ayrıca portfolyo yüküdür.

### `[DOĞRULANMADI]` (ölçülmedi — "temiz" DEĞİL)

- **Kriter 9'un kapsamı ve beyan ettiği sınırlar:** web ayağı (`--platform chrome` sonuç üretmiyor) · iOS (Mac yok, CI-only) · boşaltma tavanı 20'nin her koşulda yeterliliği · `01-acilis.png`'deki ANR **System UI**'a ait (ölçüldü) ama uygulamanın kendi ANR üretmediği **ölçülmedi** · soğuk açılış **süresi** ölçülmedi · düzenleme/tamamlama/silme yollarının uzak yansıması bu ayakta ölçülmedi.
- **builder'ın *"`cmd /v:on` kalıbı `M4`'te bir kez SESSİZCE başarısız oldu"* iddiası** — Cowork aynı
  kalıbı onlarca kez kullandı, **hiç yalan söylemedi**; sapma zararsız, **gerekçesi doğrulanmadı**.
- **Eski açık 5:** flutter_secure_storage Windows · WebKit `__Host-` · Isopoh lisansı ·
  NIST SP 800-38D · web'de `textScaler`/tema farkı.
- **`pub.dev` uçları** dokümantasyonsuz/garantisiz — kalkan: fixture altın kümeleri. · **Kontrast
  betiği** `araclar/` dışında.
- **Geçici artıklar (repo DIŞINDA, silme Onur'da):** `%TEMP%\_cw_*` · `C:\dev\_cowork_tmp\`.

---
