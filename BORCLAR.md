# BORCLAR.md — Momentum · AÇIK BORÇLAR (adlandırılmış, gizlenmemiş)

> 🔴 **AÇILIŞTA OKUNMAZ.** Bu dosya `DURUM.md` §8'den **30 Tem 2026'da (oturum 39, Onur'un kilidi K83)** ayrıldı.
> Açılış protokolü **`DURUM.md` + `CLAUDE.md`** ile sınırlıdır; burası yalnız **iş bir borca dokunduğunda** açılır
> (`PROJE_HAFIZA.md` ayrımının aynısı).
> **TAVAN: ≤ 24.576 b** 🔴 **[K117, oturum 49 — Onur; ESKİ 16.384 GEÇERSİZDİR].** Gerekçe `DURUM.md`'nin
> tavanından **farklıdır ve büyümeyi ÖDÜLLENDİRMEZ:** bu liste
> büyüdüğünde kapının ısırması **doğru sinyaldir** — borç kapanmıyor demektir. Ayrım anındaki içerik **10.395 b**.
> Eşik değişikliği K40 gereği **Onur'dan** gelir ve `belge-tavan-kapisi.py`'nin altın kümesine vaka eklemeyi zorunlu kılar.
> 🟢 **K117'de bu şart MEKANİKLEŞTİ:** aracın **vaka 10**'u kapsam tablosundaki **her tavanı pinler**; eşiği
> değiştirip altın kümeyi güncellemeyen el artık **KIRMIZI** alır. Yükseltmenin ölçülmüş gerekçesi ve
> **beyan edilmiş bedeli** (bu bir gevşetmedir) `PROJE_HAFIZA.md` **K117**'dedir.
> **Kapanan kalem buradan ÇIKARILIR**, gerekçesi `PROJE_HAFIZA.md`'ye yazılır (K71 emsali). Kapanmış bir kalemi
> burada aramak **bayat okuma üretir**.

---

> 🔴 **KAPANMIŞ kalemler ve BAYAT çıkan altı iddia buradan ÇIKARILDI** ⇒ `PROJE_HAFIZA.md` **K71**
> (28 Tem 2026, oturum 35). Bu bölüm yalnız **bugün açık olanı** taşır. Kapanmış bir kalemi burada
> aramak bayat okuma üretir; gerekçesi arşivdedir.

### Ürün / kod

- 🔴 **`SenkronDongusu.durdur()` YOK ve üretimde yaşam-döngüsü kancası da yok [oturum 49].**
  `senkron_dongusu.dart`'ta `durdur`/`dispose` **yalnız yorumlarda** geçiyor; `main.dart` `dongu`'yu
  uygulama ömrü boyunca tutar. `GOREV-A11` bir `durdur()` **istiyor** ama onu çağıracak kanca
  **eklemiyor** ⇒ `A11/G22`/`i` (yetim zamanlayıcı yok) bugün **yalnız testte** anlamlı olacak.
- 🔴 **SİNYAL KEEPALIVE'İ CANLILIK ÖLÇMÜYOR [oturum 49'da ölçüldü].** `signalr_json_sinyal.dart`
  15 s'de bir `{"type":6}` **gönderiyor** ama sunucu yanıtına **zaman aşımı yok** ⇒ ölü ama "açık"
  görünen bir soket sessizce sinyal taşımayı bırakabilir. **Ölçülmedi.** Aynı turda ölçülen komşu
  gerçek: uçak modunda soket **hiç kopmadı** (emülatör NAT'ı kurulu bağlantıyı koruyor) ⇒
  **yeniden bağlanma yolu bu depoda HİÇ egzersiz edilmedi**, gerçek cihazda `[DOĞRULANMADI]`.
- 🟡 **`408`/`429` YENİDEN DENENMİYOR [K116 kapsam dışı].** Bugün `_httpHatasiIsle` onları
  *401-olmayan 4xx* dalına atıp rozeti `cakisma` yapıyor. *Yeniden denenebilir* ilan etmek
  **`D9`'un kilitli sınıflandırmasına** dokunur; Onur `A11`'de onu kilitlemedi. Ayrı dilim.

- 🟡 **K113 SARMALAYICISI `duzenle`/`sil` YOLLARINI KAPSAMIYOR.** O iki yol bugün arayüzde kullanıcıya
  **açık değil**; açılırlarsa `_yerelYaz()`'dan geçmeleri ZORUNLUDUR, yoksa K112 boşluğu geri döner.
- 🟡 **.NET 10 KAPSAM DIŞI paketler [K111, Onur kilidi]:** `Asp.Versioning.Http` 8.1.1→10.0.1 · `xunit` 2.9.2→2.9.3 ·
  `Microsoft.NET.Test.Sdk` 17.12.0→18.8.1 · `xunit.runner.visualstudio` 2.8.2→3.1.5 · `Scalar.AspNetCore`→2.16.17.
- 🟡 **`Microsoft.OpenApi 2.11.0` GEÇİCİ CVE PİNİ [K111]**, mimari karar değil; yukarı akış düzelince **silinir**
  (`dotnet nuget why Momentum.sln Microsoft.OpenApi`). Unutulursa sürüm gerilemesi olarak ısırır.
- 🟡 **`LangVersion=latest` dil-sürümü sınıfına AÇIK [K111 — mutant kanıtlı].** C#14+net9 `CS0023` üretti; bugün
  zararsız (çatı net10), sonraki dil sürümü aynı sınıfı habersiz getirir. Çatıya pinlemek Onur'un kararı.
- 🔴 **SABİT `sleep` BİR ÖLÇÜM DEĞİLDİR [oturum 35 — KENDİ ölçüm kusurum].** Cihaz doğrulamasında 22 sn bekleyip **yanlış KIRMIZI** verdim; görev birkaç saniye sonra inmişti. Daha kötüsü: kriter 9'un ilk ölçümü (K71) 15 sn ile **geçmişti — o geçiş titizlik değil ŞANSTI.** Cihaz ölçen her betik **koşula kadar yoklamalı** (tavanlı), sabit uyumamalı.
- 🔴 **`iddia-kapisi.py` İKİLİ DOSYALARI METİN GİBİ TARIYOR [oturum 35].** 89.628 b'lik bir PNG'nin rastgele baytları `\bM\d\b` desenine denk düşüp **dört hayalet kanıt** üretti. Bugün yanlış-pozitif; **tehlikeli yönü ters:** büyük bir ikili dosya `M41` desenine denk düşerse kapı o mutantın kanıtı **varmış gibi** sayar ⇒ **kanıt-kazayla-sağlanır**. Onarım: yalnız metin uzantıları taransın. 🔴 **AYRI ELE (K34-f)** — aracı Cowork yazdı (K67).
- 🟡 **[K76] Cihaz kanıtındaki `zehirli` kuyruk kaydı SQLite'a SEED EDİLDİ** — render gerçek widget ağacı, **sentetik olan veridir**.
- 🟡 **`tazelik-muafiyet.json`'daki `BD-6` GEREKÇESİ BAYATLADI [oturum 36].** Muafiyet *"DESIGN.md K46 ile DONDURULMUŞTUR"* diyor; **K46 açıldı** (K75). Muafiyet hâlâ geçerli ama **gerekçesi doğru değil**. 🔴 **AYRI ELE (K34-f)**.
- 🔴 **`KANIT/slice-3c/02-G2/` GERİ DOĞDU ve ÜRETİCİ KOD DÜZELTİLMEDİ.** `g2_registry_zarf_kapisi_test.dart:64` hâlâ `Directory('../../KANIT/slice-3c/02-G2')` yazıyor. Silmek düzeltme DEĞİLDİR. 🔴 **İkinci yazıcı da ölçüldü:** `g3_ayristirici_kapisi_test.dart:20`. Hiçbir araç *"KANIT dizini ile onu yazan kodun yolu aynı mı?"* diye sormuyor ⇒ sınıf tek vaka değil. Gerekçe: hafıza K71/K78.
- 🟡 **Son sayfa tam `PageSize` ise BİR BOŞ TUR fazladan koşar** — `hasMore = (changes.Count ==
  PageSize)`, `PageSize=500` sabit. Veri kaybı değil, **maliyet**.
- 🟡 **`CakismaRozeti` dokunma hedefi cihazda 48,0 dp ÖLÇÜLDÜ** (162 px / density 540);
  `Checkbox`'ın KENDİ ölçek davranışı hâlâ **[DOĞRULANMADI]** (`G15/A10` yalnız *"≥ 48dp"* der,
  `Checkbox`'a özgü ölçüm yok). *(K86 — bu maddenin BORCLAR.md'de daha önce "S6" etiketiyle bir
  karşılığı bulunamadı; yeni madde olarak eklendi, `KANIT/A8/10-HUKUM-K86-isleme.md`'ye şerh düşüldü.)*

- 🔴 **A‑7 `DESIGN.md`'DE KAPANMADI [K86].** Kırpma ölçülerek düzeltildi (266/266, 14/14
  mutant, CM1–CM3) ama K46 gereği `DESIGN.md`'ye tek bayt yazılmadı (`18.075 b · 3780ACA4`
  teyit edildi) ⇒ A‑7 satırı **"ölçüldü / kapanmadı"** olarak durur; açılışı Onur'un ayrı kilidi.
- 🟡 **`_CakismaCozumSayfasi` (`cakisma_rozeti.dart:77,82`) `GOREV-A8`'in BEYANLI HARİCİDİR [K90].** Aynı
  metin-kaybı sınıfı; yer tutucu olduğu için **K42-d adım 3**'te kapanır, oraya emek harcanmadı.
- 🔴 **ÇAKIŞMA ÇÖZÜM SAYFASI 2.0×'TE KIRPILIYOR [ölçüldü, K86].** `cakisma_rozeti.dart`
  `_CakismaCozumSayfasi`: `ellipsis` VAR, `maxLines` YOK ⇒ tek satır. A‑7'nin düzelttiği
  **AYNI SINIF, BAŞKA bileşen**; spec ne dâhil ne hariç etti (`G13` kapsamı rozet alt ağacı).
  Ekran okuyucuda kayıp YOK, kayıp **görsel**. Yer tutucu — K42‑d adım 3 değiştirecek.

- 🔴 **ÇAĞRILMAYAN KAPI SINIFI [ÖLÇÜLDÜ, oturum 39 — YENİ SINIF].** `sayi-tazeligi.py` bir kapıydı, altın kümesi
  16/16 geçiyordu, **ama açılış protokolünde YOKTU** ⇒ ölçüm var, hüküm görülmüyor (`DURUM.md` iki yerde
  `oturum-sagligi.py 25/25` diyordu, gerçek **26**). 🟢 **K89'DA MEKANİKLEŞTİ [oturum 42]:** `KAPILAR.md`
  her kapının **olay + ortam** eşlemesini tek yerde beyan ediyor. 🔴 **SINIF KAPANMADI:** ① tabloyu **zorlayan
  bir kapı yok** (`kapi-tetik-kapisi.py`, sınıf tabloya rağmen ısırdığında yazılır) ② `design-token-kapisi.py`,
  `iddia-kapisi.py`, `hafiza-dizin.py` hâlâ §2'nin **numaralı listesinde değil** — tablo bunu **beyan ediyor,
  düzeltmiyor**.

### Araç / kapı

- 🟡 **`_start_api.cmd` `ASPNETCORE_ENVIRONMENT` borcu ÖLÇÜLEMEDİ [oturum 48'de DENENDİ].** Aynı depoda
  ikinci bir `dotnet run` örneği, birincinin **dll'leri kilitlemesi** yüzünden derlenemiyor (`MSB3027`) ⇒
  değişkensiz davranış ölçülemedi. Ölçmenin yolu: tek örnek, değişkensiz kaldırma (ortamı boşaltmayı ister).
- 🔴 **`verify.ps1` GEÇMİŞ KANITI EZİYOR [K111 — ölçüldü, iki kez].** `MOMENTUM_KANIT_DIZIN` varsayılanı yüzünden her
  koşum `KANIT\slice-3d\07-G7-backend-zorlama\outbox-sorgu.txt`'yi yeniden yazıyor; oturum 47'nin *"kaydedilmemiş
  yeniden koşum"* vakasının **kaynağı budur**. Kapı donmuş kanıtı ezmemeli. 🔴 **AYRI ELE (K34-f).**
- 🔴 **`.gitignore` KANITI SESSİZCE YUTUYOR — SINIF AÇIK [K111].** `*.log` (satır 93) 7 ham verify kaydını staged
  etmedi; özet var olmayan dosyalara atıf yaptı. Vaka `.txt` ile kapandı (`a0aed23`), **sınıf değil**: hiçbir kapı
  *"KANIT altına yazılan dosya ignore ediliyor mu?"* diye sormuyor. Ucuz: `check-ignore -v` + `diff --cached --stat`.
- 🔴 **`verify.ps1` FAIL-LOUD AYAĞINI OTOMATİK ZİNCİRDE ETKİSİZ KILIYOR.** `if (-not $env:MOMENTUM_KANIT_DIZIN) { … }` varsayılan atıp dizini yaratıyor; spec §8.2'nin *"zorunlu"* şartı regresyon zincirinde **hiç ölçülmüyor**. Araç değişikliği ⇒ **ayrı el (K34-f)**.
- 🟡 **D1-ÖNLEME BORCU — KISMEN KAPANDI [K82].** `oturum-sagligi.py` bayat kimliği artık **yakalar**
  (yazım anıyla karşılaştırarak), ama sayı yazan betiklere *"önce diskten ölç"* adımını **dayatmaz**:
  bu **tespit**tir, önleme değil.
- 🔴 **DEVİR NOTU KENDİ KABININ KİMLİĞİNİ YAZMAMALI [K82, ölçüldü].** Not `PROJE_HAFIZA.md 684.530 b`
  diyor, yazım anında **691.599 b** — notu yazmak dosyayı büyütür ⇒ beyan **yapısal olarak imkânsız**.
  Araç `D1-OZ` ile SARI der; kural henüz `CLAUDE.md`'ye **yazılmadı** (Onur'un kilidi).
- 🟡 **`oturum-sagligi.py` `tek-kopya-kapisi.py` kapsamına EKLENMEDİ** — eklemek kapının kilitli sha'sını
  bozar + 11/11 mutantı yeniden koşturur; `GOREV-slice-3e-G12.md` ile **aynı beyanlı-kilit** durumu.
- 🟡 **`oturum-sagligi.py` §3'ü GÖRMÜYOR [ölçüldü, oturum 38].** `D1` yalnız ÜÇ hücreli kimlik tablosunu
  ayrıştırır; §3'ün iki hücreli satırları **kapsam dışı**. Boşluk aynı gün ısırdı: §3 `DESIGN.md` v1
  `534DFF68`'i (§9'un **GEÇERSİZ** dediği sha) ve `156/156`'yı (gerçek **171/171**) taşıyordu — ikisi de
  **elle** bulundu, araçla değil. Onarım **ayrı ele (K34-f)**.
- 🔴 **`pub-surum-olc.py`'ye ÇÖZÜMLENEBİLİRLİK AYAĞI [Z10b]** — araç **sürümü** ölçüyor,
  **çözülebilirliği** ölçmüyor. Kalkan gelene dek her pin `pub get` ile doğrulanır.
- 🟡 **`radar.py` R5'in CÜMLESİ KAPSAMINI AŞIYOR** — artefaktın kaydını okur ama *"**projenin** görünen çıktısı %0"* der. Kusur **metinde**; onarım üst akış plugin'inde, **ayrı el** (K34-f).
- 🟡 **`radar --olc-urun-kodu` ÇALIŞMA AĞACINI GÖRMEZ** — yalnız commit'lenmiş farkı sayar ⇒ R8 yanlış-pozitif olabilir; R8 yandığında **önce çalışma ağacı ölçülür.**
- 🟡 **`sayi-tazeligi.py` İMZA↔SAYI YAKINLIĞI ÖLÇÜLMÜYOR** [**4 kez** tetikledi]. 🔴 Sonuncusu (oturum 51)
  **ters yönde ısırdı:** kapı bir satırda araç adı bulunmadığı için `T5` verdi; ad satıra taşınınca bu kez
  *aynı satırdaki BAŞKA* ölçümlerin sayıları (`500/500`, `17/17`) o araca bağlandı ⇒ **iki sahte `T1`**.
  ⇒ Kuralın **iki yönü** var: sayı aracın adıyla aynı satırda yaşamalı, **ve** o satırda başka bir aracın
  sayısı yaşamamalı. Eşik uydurulmadı (K40), onarım **ayrı ele** (K34-f).
- **`radar.config.json` YOK ve bu bir KARAR**; eşik değiştiren K40 gereği **altın kümeye vaka ekler.**

- 🔴 **`belge-tavan-kapisi.py`'NİN ALTIN KÜMESİ KAPSAM LİSTESİNİ KANITLAMIYOR [ÖLÇÜLDÜ, oturum 39].**
  Dokuz vakanın hepsi `denetle()` saf fonksiyonunu sentetik ölçümlerle (`_o(...)`) sınar; **`VARSAYILAN_KAPSAM`
  listesine hiç dokunmaz.** Ölçümün kanıtı: `BORCLAR.md` kapsama eklendi ve altın küme **9/9 olarak DEĞİŞMEDİ** —
  yani kapsamdan bir canlı belge **düşse** bu küme onu **GÖRMEZ**. Boşluk `sayi-tazeligi.py`'de bugün ısıran
  *"çağrılmayan kapı"* sınıfının kardeşi: **ölçülmeyen kapsam, ölçülmeyen kapıdır.** Bu oturumda kapsamın fiilen
  ısırdığı **dört diskte-koşan mutantla** kanıtlandı (`T1` tavan+1 b · `T2` pay 684 b · gerçek boyut sessiz ·
  `T0` dosya yok) — ama bu **tek seferlik el kanıtıdır**, kümede yaşamıyor. Onarım **ayrı ele (K34-f)**.
  🔴 **OTURUM 42'DE AYNEN TEKRARLANDI:** kapsama `KAPILAR.md` eklendi ve altın küme yine **9/9** kaldı;
  eklemenin ısırdığı yalnız **el ile** ölçüldü (`KAPILAR.md`'siz bir kökte `T0` SARI ⇒ `_SILINECEKLER\_t0-kanit-ots42`).
- 🟡 **`BORCLAR.md` `tek-kopya-kapisi.py` KAPSAMINDA DEĞİL [oturum 39].** Yeni bir **canlı** belge doğdu ve
  regresyon kapısı (`S0`–`S10`) onu izlemiyor ⇒ bu dosya sessizce 0 bayta düşse kapı **susar**. Eklemek aracın
  §9'da **donmuş** sha'sını (`66AC9CA3`) bozar ve `11/11` mutantı yeniden koşturmayı gerektirir — bu yüzden
  `oturum-sagligi.py` ve `GOREV-slice-3e-G12.md` ile **aynı beyanlı-kilit** sepetinde: kilit **beyanla** yaşıyor.
  🔴 **`KAPILAR.md` DE AYNI SEPETE GİRDİ [oturum 42, K89]** — sepette artık **dört** kalem var; `belge-tavan`
  onu ölçüyor ama **regresyonunu ölçen yok**. Sepet büyüdükçe *"kaç canlı belge kapısız?"* sorusu ucuzlamıyor.

- 🔴 **`design-token-kapisi.py` AÇILIŞ PROTOKOLÜNDE ÇAĞRILMIYOR — "ÇAĞRILMAYAN KAPI" SINIFI
  AYNI OTURUMDA İKİNCİ KEZ ISIRDI [K86].** HEAD'de KIRMIZI olduğu hâlde `DURUM.md` §3
  **istemci kapılarının tamamını YEŞİL** sayıyordu (o cümlenin kapsamsız kimlik yazımı
  **K108** ile yasaklandı; birebir alıntı arşivdedir). K89'da `KAPILAR.md` bu kapının tetiğini **beyan etti**
  (*açılış-nöbetçi*) ama §2'nin **numaralı listesine eklenmedi** — ekleme kararı Onur'da.
- 🔴 **İKİ ÖLÇÜM GERİLEMESİ — AYNI TURDA KAPANDI, SINIF AÇIK [K89-DÜZELTME, oturum 42].**
  ① `oturum-sagligi.py` kimlik bloğunu *"dosya"+"kimlik"* geçen **İLK** satırdan bulur; K89'un
  `dosya-kimlik` sözcüğü çapayı **çaldı** ② `_SILINECEKLER` altındaki kanıt **kopyaları** `DESIGN.md`
  adını çoğalttı (araç **FS'i** yürür, git'i değil). İkisi de onarıldı; **varsayımları ölçen kapı YOK**.
- 🟡 **`oturum-sagligi.py` KAPSAMINI BEYAN ETMİYOR [K86].** `--transcript` ne verilirse ölçer,
  "bu el benim işim değil" demez. K21'in kapsamı `CLAUDE.md`'ye yazıldı; **aracın** kapsam
  ayağı yok ⇒ onarım ayrı ele (K34‑f).
- 🔴 **SPEC MUTANT TABLOSU, MUTANTI ISIRTACAK AYAĞIN ARİTMETİĞİNİ YAPMAMIŞTI [K86].**
  `G14/A4`'ün tek kanonik vakası `M75` ve `M77`'ye **KÖRDÜ**. Bu **Cowork'ün kusurudur** ve
  *"çözümün yeterliliği ölçülmedi"* sınıfının **mutant tablosundaki hâli**; kâğıt turu değil
  **BUILD** yakaladı (K53/1'i doğrular). Spec'e eklenecek vaka §2/(b) cevabına bağlı.

### Belge / defter

- **`DESIGN.md` BD‑1…BD‑7** — **K46 gereği kapatılmadı**; liste spec §10'da. BD‑6'nın bayat sayısı
  `sayi-tazeligi.py`'de **gerekçeli muafiyet**.
- 🔴 **Defter dürüstlük kusurları** — `D3`: `docs/ADR/0003` tur 8 kaydının zorunlu alanları eksik ·
  `D2`: aynı defterde **tur 1 atlanmış**. Append-only ⇒ **düzeltme kaydı** (28 Tem 2026 radarında
  hâlâ SARI yanıyor).
- 🟡 **`D1` bu defterde KÖR** — artefakt adları çoğunlukla **etiket**, yol değil. Yeni kayıtlara
  **gerçek yol** yazılır.
- 🟡 **`KANIT/slice-3b/04-G3/gercek-tarama.txt` 1,9 MB** ve **`KANIT/slice-3e-iskelet/pub-lisans-kapisi.txt` 2 MB** — portfolyo yükü; kesit+sha yeterdi.

- 🔴 **DEFTERDE `D2` BOŞLUĞU BİLEREK AÇIK [oturum 37].** `uzak_degisiklik_uygulayici.dart` tur 1 ve 3 taşıyor, **tur 2 YOK**. Geriye dönük kayıt uydurmak **sahte sıfır** yazmaktır ⇒ aracı kasten körleştirir. Boşluk **beyan edildi**, `D2` SARI kalıyor.
- 🟡 **`_start_api.cmd` `ASPNETCORE_ENVIRONMENT` SET ETMİYOR [oturum 37, ÖLÇÜLMEDİ].** Aksi hâlde `NullCurrentUser` ⇒ **401** (K61). `dotnet run --no-launch-profile`'ın ortamı Development'a düşürdüğü **ölçülmedi**; oturum 37'de değişken **elle** set edilip `/v1/tasks` başlıksız 401 / başlıklı 200 ölçüldü.

- 🔴 **RADAR YAPISAL OLARAK KALICI KIRMIZI [ölçüldü, oturum 38].** `radar.py`'de defter kaydını **park/kapatma mekanizması YOK** ⇒ `docs/ADR/0003` (9 tur) ve `GOREV-slice-3b-spec` (7 tur) **asla iyileşemez**; hüküm her açılışta KIRMIZI ve **sürekli yanan alarm kör kapıya dönüşür**. Onarım `radar.py`'de ⇒ K57-b'yi bozar ⇒ **üst akış + AYRI EL (K34-f)**. 🔒 **K83 (Onur):** şık **(4) DURDUR** kilitli; ritüel kısaldı, **alarm sönmedi**.
- 🟡 **`iddia-kapisi.py` HAYALET KANIT SINIFI İKİNCİ KEZ ISIRDI [K78].** `KANIT/slice-3e-iskelet`'te tabloda **sıfır** mutant varken **altı** hayalet buldu; kaynak 2 MB'lık `pub-lisans-kapisi.txt` + ikili baytlar. 🟢 **A8'de ISIRMADI:** 10 gerçek mutant, **envanter reddi çalıştı** (`07-IDDIA.txt` liste diye reddedildi).

### `[DOĞRULANMADI]` (ölçülmedi — "temiz" DEĞİL)

- 🟡 **CI'da .NET 10 [DOĞRULANMADI] [K111].** Geçiş tek makinede ölçüldü; CI'da SDK 10.0.302 + `verify` hiç koşmadı.
- **Kriter 9'un kapsamı ve beyan ettiği sınırlar:** web ayağı (`--platform chrome` sonuç üretmiyor) · iOS (Mac yok, CI-only) · boşaltma tavanı 20'nin her koşulda yeterliliği · `01-acilis.png`'deki ANR **System UI**'a ait (ölçüldü) ama uygulamanın kendi ANR üretmediği **ölçülmedi** · soğuk açılış **süresi** ölçülmedi · düzenleme/tamamlama/silme yollarının uzak yansıması bu ayakta ölçülmedi.
- **Eski açık 5:** flutter_secure_storage Windows · WebKit `__Host-` · Isopoh lisansı ·
  NIST SP 800-38D · web'de `textScaler`/tema farkı.
- **`pub.dev` uçları** dokümantasyonsuz/garantisiz — kalkan: fixture altın kümeleri. · **Kontrast
  betiği** `araclar/` dışında.
- **Geçici artıklar (repo DIŞINDA, silme Onur'da):** `%TEMP%\_cw_*` · `C:\dev\_cowork_tmp\`.

---

## B-O50-1 — `main.dart:149` SİNYAL DİNLEYİCİSİNİ ÖLÇEN KAPI YOK (oturum 50, ölçüldü)

`A11` kriter 7'nin tetikleyici izolasyonu (`KANIT/A11/05-KRITER7-TETIKLEYICI-IZOLASYONU.md`) şu
satıra dayanıyor: `sinyal.olaylar.listen((_) => unawaited(dongu.cekmeTuruCalistir()))`. Bu satır
`turCalistir`'e dönerse **kriter 7'nin kanıtı sessizce bayatlar** — sinyal yolu kuyruğu itebilir
hâle gelir ve *"tetikleyici retry'dı"* hükmü çürür. 🔴 **Ölçen hiçbir kapı yok:**
`yoklama-yasagi-kapisi.py` `Y1`'i yalnız `Timer`/`Future.delayed` çağrılarının **kapsayan
gövdesinde** arar; `main.dart:149` bir **stream dinleyicisidir** ve o taramaya **hiç girmez**.
Sınıf: `kör kapı`. Kapanış: `Y1`'e (ya da ayrı bir ayağa) *"sinyal dinleyicisi `turCalistir`
çağıramaz"* kuralı + mutantı.

## B-O50-2 — `sayi-tazeligi.py` SÜRÜM ETİKETİNİ ÖLÇMÜYOR (oturum 50, ölçüldü)

`belge-tavan-kapisi.py` banner'ı **1.0.0** yazıyor; `DURUM.md`'nin **3. satırı da 1.0.0**, ama §5
(K58) ve §6 tablosu **1.1.0** diyor. Araç gerçekten güncel — vaka 10 çıktıda görünüyor ve **12/12**
iddiası `sayi-tazeligi.py` ile **doğrulandı** ⇒ kusur **sürüm etiketinde**, kapasitede değil.
🔴 `sayi-tazeligi.py` bu sınıfı **görmez**: yalnız *"altın küme N/M"* desenini ölçer, **`SURUM`
sabitini belgedeki sürüm iddiasıyla karşılaştırmaz**. Sınıf: `bayat-iddia` + `kanonik-kopya`
(aynı sayı `DURUM.md`'de **iki farklı değerle** yaşıyor). Kapanış: araca *"belgede geçen
`<arac> N.N.N` iddiasını aracın `SURUM` sabitiyle karşılaştır"* ayağı + mutant; ya da banner
sürümünün tek kaynağa bağlanması.

## B-O50-3 — `radar.py` `D2`'NİN `olcum-duzeltme` ÖNERİSİ ÖLÜ (oturum 50, ölçüldü)

`radar.py:268-272` yinelenen tur numarasını **yalnız sayarak** buluyor ve mesajda
*"düzeltme kaydıysa `asama` alanına `olcum-duzeltme` yaz"* diyor — ama **`asama` alanını hiç
okumuyor**. Bu oturumda **dört** düzeltme kaydı tam o biçimde yazıldı ve `D2` **yine SARI** verdi.
🔴 **Öneriyi izleyen el bile uyarıyı susturamıyor** ⇒ uyarı **gürültüye** dönüşür ve gerçek bir
yinelenen turu **maskeler**. Sınıf: `kör kapı` + `ölü beyan`.
🔴 **Düzeltme yeri PROJE DEĞİL, PLUGIN:** `araclar/radar.py` **K57-b** ile `proje-radari` plugin
0.2.0'a **bayt-özdeş** kilitli (`46E3A8BC`); proje-yerel yama sapmayı ölçen tek sha'yı kırar.
Kapanış: plugin'de `asama` alanı okunacak (`startswith("olcum-duzeltme")` ⇒ o kaydı yinelenen
sayma) + altın kümeye vaka; sonra proje kopyası tazelenir.

## B-O51-1 — `spec-kapi-kapsama.py`'nin `S2`'si DOLAYLI kapı-ayak→kural eşlemesini GÖRMÜYOR (oturum 51, ölçüldü)

`GOREV-A12-kural-envanteri.md`'nin kural-envanteri onarımı (`D-A12-1`/`D-A12-2`) `A11`'in ve `A12`'nin
kendi §3 kararlarını (`D-A11-1`…`D-A11-6`, `D-A12-1`…`D-A12-3`) envanterde **doğru** görünür kıldı —
ama bu 9 kararın **hiçbiri** hiçbir mutant tablosu satırında **adıyla** geçmiyor (satırlar yalnız
`A11/G22`/`a` gibi kapı-ayak biçiminde atıf taşıyor); `S2` yalnız **doğrudan** kural→mutant adı
atfına bakıyor ⇒ 9'u da ilk koşumda `[S2] MUTANTSIZ KURAL` verdi (Claude Code'un ölçümü:
`KANIT/A12/01-PATLAMA-YARICAPI-OLCUMU.txt`). Bu **kör kapı değil DOĞRU alarm**: kararların hepsi
gerçekten bir mutant tarafından ısırılıyor, yalnız eşleme kapı-ayak üzerinden **dolaylı**.

🔴 **BU DİLİMDE KAPATILMADI (Onur, 3 Ağu 2026 — ŞART 3):** `A11` ve `A12`'nin §6b'sine 9 gerekçeli
borç kaydı yazıldı (her biri kararı ısıran mutantı adıyla gösterir ve eşlemenin neden dolaylı
olduğunu açıklar — hiçbiri "mutantı yok" demez) ama **`S2`'nin kendisi** hâlâ bu dolaylı bağı
**göremiyor**; her yeni spec aynı sınıfı yeniden üretecek ve her seferinde elle §6b borcu yazmayı
gerektirecek. Kapanış: `mutantlar()`'ın atıf kümesini yalnız §6 tablosunun "kapı/kural" sütunundan
değil, kapı-ayak → o ayağın **ölçtüğü** kararlar eşlemesinden de (`## 5.` tablolarındaki ayak
metninden, veya spec yazarının ayrı bir eşleme bloğundan) türetmesi gerekir — bu, `S2` mantığına
dokunmayı gerektirdiği için `A12`'nin mikro-dilim kapsamı **dışında** bırakıldı (araç kodu
`D-A12-1`/`D-A12-2` dışında değiştirilmedi). Örnek dokuz kayıt (isim, mutant, kapı-ayak):
`D-A11-1`←`M151`(`G24/c`) · `D-A11-2`←`M139,M140,M143`(`G22/a,b,e`) · `D-A11-3`←`M149,M155`(`G23/c,d,i,j`) ·
`D-A11-4`←`M152`(`G22/j`) · `D-A11-5`←`M145,M147,M150`(`G22/h`+`G23/f,g,h`) · `D-A11-6`←`M142,M154`(`G22/m,l`) ·
`D-A12-1`←`M156,M161`(`G25/a,b`) · `D-A12-2`←`M157,M158`(`G25/c,d`) · `D-A12-3`←`M160`(`G26/a`).

### `B-O52-1` — K81 BİÇİM STANDARDI YARIM: **MUTANT TABLOSUNUN SÜTUN SIRASI YAZILI DEĞİL**

🔴 **Ölçüldü (oturum 52, `GOREV-A13` ilk yazımı):** `spec-kapi-kapsama.py` mutant hedefini
**`hucreler[2]`**'den okur (`mutantlar()`). `hedef` sütunu dördüncü sıraya konunca araç
**`[S1]` × 4 + `[S2]` × 5** verdi: sekiz mutantın hiçbiri hiçbir kapıya bağlanmadı, dört kapının
dördü de *"mutantsız"* göründü. K81 **bölüm başlıklarını** standartlaştırdı ama **sütun sırasını
yazmadı** ⇒ standart yarım. **Kapanış (iki yol, biri seçilir):** ① `CLAUDE.md`'nin K81 maddesine
tek cümle eklenir (*"§6 tablosunda 3. sütun `hedef`tir"*) — ucuz ama **kapısız**; ② araç, başlık
satırındaki `hedef` sütununu **adıyla** bulur (sabit indeks yerine) ve bulamazsa `[S0] BİÇİM` der —
pahalı ama **mekanik**. K53/2 gereği ikincisi *"koşan kod olmadan ölçülebilir"* sınıfındadır.

### `B-O52-2` — `K127`'NİN MEKANİK KAPISI YOK (kural prozada yaşıyor)

🔴 **Ölçüldü (oturum 52, K127'nin doğduğu tur):** `K127` *"kilit checkpoint'i bağımsız denetçinin
çıktı yolunu taşımak zorundadır"* der, ama bunu **hiçbir kapı zorlamıyor**. Bugün checkpoint metnini
kimse denetlemiyor ⇒ bir sonraki kilit yine denetimsiz yazılabilir ve kimse fark etmez. Bu, projenin
en çok eleştirdiği sınıfın (*"beyan edilmiş zayıf kontrol"*, `belge-tavan-kapisi.py` öncesi durum)
bilerek tekrarıdır. **Kapanış yolu:** `PROJE_HAFIZA.md`'nin **en üstteki** checkpoint'inde, başlığı
`KİLİT`/`KILITLENDI` içeren her kayıt için `KANIT/**/*DENETIM*` deseninde **var olan** bir dosya
yolu arayan küçük bir kapı (`kilit-denetim-kapisi.py`); yol yoksa ya da dosya diskte yoksa KIRMIZI.
Altın küme: yol var+dosya var (sussun) · yol var+dosya yok (ısırsın) · yol yok ama *"denetim
KOŞULMADI"* açıkça yazılı (sussun) · ikisi de yok (ısırsın).

---

## OTURUM 53 — `A13` KABULÜNÜN AÇTIĞI BEŞ BORÇ (K129/K130)

> Hepsi **kabul öncesi bağımsız denetimde** (K127) bulundu; hiçbiri **yanlış-YEŞİL** üretmiyor,
> hepsi *fazlalık / gösterilemeyen iddia* sınıfındadır. Kabul **bu sınırlar YAZILARAK** verildi.
> Kaynak: `KANIT/A13/00-DENETIM-kabul-oncesi.md` · beyanlar `GOREV-A13` §9/11–21.
> 🔴 **Onarımların hepsi BUILDER'ın işidir (K34-f)** — Cowork ölçer ve raporlar, onarmaz.

- 🔴 **`B-O53-1` — `A13/G29/b` KÖR AYAK.** `Xcode build done.` tam dizgesi `main` (ios **success**,
  91.9s) ve `M169` (ios **failure**, 43.7s) loglarının **ikisinde de** geçiyor ⇒ ayırt etme gücü
  **sıfır**. Ölçüm: `KANIT/A13/07-MUTANT-kosan/30-BULGU-G29b-kor-ayak.txt`.
  **Kapanış yolu:** builder ya ayağı `Built build/ios/iphoneos/Runner.app (` pinine **birleştirir**,
  ya da ayağı **kaldırır**; her iki durumda `M169`'un logu üzerinde **yeniden ölçülür**.
  *Neden bloker değil:* `G29` bir bütün olarak ayırt ediyor — `c` (fail 0 / success 1) ve `d`
  (failure/success) ikisi de `M169` ile kanıtlı.

- 🔴 **`B-O53-2` — MUTANTSIZ AYAKLAR: `G27/a` · `G27/c` · `G30/b`.** Üçü de ölçüldü ama hiçbirinin
  kendi mutantı yok ⇒ **körlükleri BİLİNMİYOR** (`G29/b`'nin körlüğü tam da mutantsız olduğu için
  yıllarca görülmezdi). `M170` §6'da `A13/G27`'yi hedef gösteriyor ama yalnız **`b`**'yi ölçüyor;
  kapı granülerliğinde çalışan `spec-kapi-kapsama.py` bu boşluğu **göremez** — aracın beyan edilmiş
  sınırı. **Kapanış yolu:** ya ayak-granüler kapsama ölçümü, ya üç statik mutant (üçü de ucuz:
  `G27/a` → kaydedilmiş JSON'da `conclusion` bozulur · `G27/c` → iş adı silinir · `G30/b` →
  `IPHONEOS_DEPLOYMENT_TARGET` değiştirilir).

- 🔴 **`B-O53-3` — KRİTER 7'NİN DİNAMİK AYAKLARININ KORUNMUŞ ARACI YOK (K44-a ihlali).**
  `ci-kapisi.py` yalnız **statik** ayakları ölçüyor (`G28/a,b` · `G29/a` · `G30/a,b,c`).
  `G27 a·b·c` + `G28 c·d` + `G29 b·c·d` **saklanmamış** `%TEMP%` betikleriyle ölçüldü; altın kümesi
  yok, üçüncü bir el **yeniden koşamaz** (bağımsız denetçi sıfırdan yazmak zorunda kaldı —
  yazdı ve **aynı sonuca vardı**, bu yüzden bloker değil).
  🔴 **Ölçülmüş bağlantı: kaçan tek kör ayak (`B-O53-1`) tam da bu araçsız kümededir.**
  **Kapanış yolu:** builder `araclar\ci-log-kapisi.py` yazar (girdi = kaydedilmiş `gh` log + JSON,
  çıktı = `G27`/`G28c-d`/`G29b-d` hükmü), **kendi altın kümesiyle**; küme `M169` logunu **negatif
  vaka** olarak taşımak zorundadır (kör ayak orada yakalanır).

- 🟡 **`B-O53-4` — `G28/d`'nin `N/N` BİÇİMİ LOGDA LAFZEN YOK.** Spec `N/N geçti` istiyor; CI
  reporter'ı `🎉 500 tests passed.` basıyor, **payda yazmıyor**. Hüküm *"`failed` satırı 0 +
  `skip` 0"* kuralıyla verildi — savunulabilir ama **spec'in yazdığı ölçü değil**.
  🔴 **Ölçülmüş tehlike:** gevşek `tests passed` arayan bir kapı, `M168`'in
  `##[error]499 tests passed, 1 failed.` satırını **YEŞİL sayardı**.
  **Kapanış yolu:** dizge pinlenir (`^🎉 (\d+) tests passed\.$` + `failed` satırı yokluğu, ikisi
  birlikte) ve `B-O53-3`'ün aracına vaka olarak girer.

- 🟡 **`B-O53-5` — AKSİYONLAR SHA'YA PİNLİ DEĞİL.** `actions/checkout@v4` ve
  `subosito/flutter-action@v2` **yüzen etiketlerdir**; `D-A13-6` Flutter'ı pinler, **aksiyonları
  pinlemez**. ⇒ `A13`'ün yeşili **bit-bazında tekrarlanabilir değildir**: yarın aynı commit farklı
  aksiyon kodu çekebilir ve o gün kusur **üründe sanılır** (`D-A13-6`'nın kendi gerekçesinin
  aksiyonlara uygulanmamış hâli). **Kapanış yolu:** `@<tam-sha>` pini + `M163`'ün kardeşi bir
  statik mutant. *Beyan edilmiş bedel:* pin, güvenlik yamalarını da dondurur ⇒ Dependabot'suz
  pin bir bakım borcudur.

### OTURUM 53'TE KAPANAN / DEĞİŞEN
- 🟡 **`A13` §9/4 KISMEN KAPANDI** — Timing API: dört koşumun da **billable MACOS 0 ms /
  UBUNTU 0 ms**. **Kalan kontenjan hâlâ `[ÖLÇÜLMEDİ]`** (`gh` token'ında `user` yetkisi yok).
- 🔴 **`B-O52-2` (K127'nin mekanik kapısı yok) HÂLÂ AÇIK — ama bu turda K127 kapısız hâliyle
  bile İŞE YARADI:** denetim kilitten önce koştu ve **1 bloker** yakaladı. Kapı olmadığı için
  *koştuğunu* garanti eden bir şey yok; **bu tur onu Onur'un talimatı garanti etti.**

### OTURUM 55'TE AÇILAN — `SS2` v3 KİLİDİNİN BORÇLARI (`K133`)

- 🔴 **`B-SS2-1` · `B-SS2-2` · `B-SS2-3` — SPEC'İN KENDİ §8'İNDE TAM METİNLE YAZILIDIR.**
  Buraya **kopyalanmaz** (`kanonik-kopya` bu projede altı kez ısırdı); kanonik yer
  `GOREV_CLAUDE_CODE/GOREV-SS2-cakisma-cozumu.md` §8 → `S7` · `S5` · `S8`. Tek satırlık kimlikleri:
  `B-SS2-1` v3→v5 migration zinciri `[DOĞRULANMADI]` (`G31/c` yalnız v4→v5 ölçer) ·
  `B-SS2-2` rozet **iki farklı olayı** aynı ikonla gösteriyor (ayrıştırma yok) ·
  `B-SS2-3` görev silinince çakışma kaydı **yetim** kalır (`sil()` temizlemez).
  🔴 **Bu üç atıf v2'de de vardı ve BORCLAR.md'de karşılığı YOKTU** — kilit onları **sarkan atıf**
  yapacaktı; oturum 55 açılışında ölçülüp kapatıldı.

- 🔴 **`B-SS2-4` — `spec-kapi-kapsama.py` *"MUTANT ISIRIR MI"* DİYE SORMUYOR.** Araç *"mutant VAR
  mı"* sorar; **eşdeğer mutant onun için YEŞİLDİR** ve bu, aracın kendi beyan edilmiş sınırıdır.
  🔴 **Ölçülmüş bedel:** aynı ders **üç tur üst üste** alıntılanıp uygulanmadı
  (`A13/M167` → `SS2` v1 `M172`/`M173`/`M175` → v2 `M172`) ve iki bağımsız denetim turu (~307k +
  ~120k token) onu **elle** yakalamak zorunda kaldı. Kapı olsaydı üçü de ilk turda düşerdi.
  **Kapanış yolu:** mutantı **gerçekten uygulayıp** kapıyı koşan, sonra geri alan bir koşucu;
  referans **`KANIT/A11/_mutant_kosucu.py`** (ikili yedek → bayt düzeyinde yama → kapı → `wb` ile
  geri yazım → `sha256` ile özdeşlik). 🔴 `git restore` ile geri alma **YASAK** (`core.autocrlf`
  bayt-özdeşliği kör kılar — `ORTAM.md`). 🔴 **Araç ÜRÜN KODU SAYILMAZ (`K53/4`)** ⇒ bu borç
  `R8` sönmeden açılamaz.


- 🟢 **KAPANMIŞ ÜÇ KALEM ARŞİVE TAŞINDI [oturum 56, `K135`]:** `spec-kapi-kapsama.py` kural yarısı (`K124`) · `A13` §9/5 · `A13` §9/10. Tam metinleri `PROJE_HAFIZA.md` `K135`'te; burada **yer kaplamaları** tavanı borç KAPANMADIĞI hâlde daraltıyordu.
- 🟡 **`B-SS2-5` — `M172`'nin *beklenen* metni gerçeği tarif etmiyor [oturum 56'da ölçüldü, Onur borçlandırdı].** Kilitli spec (`K133`) satır 382 yalnız `G32/a` bekler; ölçülen gerçek **beş ayak** (`G32/a`·`e`·`e2`·`g`·`h`) — şart 4 çakışma kaydını **tamamen bastırıyor**. Sınıf **beyansız-sınır**; kilit **açılmadı** (çekirdek sözleşme ayakta: `M172` `G32/a`'yı **adıyla** düşürdü). Gerekçe + kapanış şartı: hafıza `K135-EK3`.
