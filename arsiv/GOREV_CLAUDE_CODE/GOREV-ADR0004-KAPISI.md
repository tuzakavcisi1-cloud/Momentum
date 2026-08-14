# GOREV-ADR0004-KAPISI — `adr-hukum-kapisi.py` (K170'in mekanik kapısı) · **v3**

> 🔴 **DURUM: KİLİT BEKLİYOR — ONUR KİLİTLEMEDEN CLAUDE CODE BU SPEC'İ BUILD ETMEZ.**
> Kilit anında `PROJE_HAFIZA.md` checkpoint'i **aynı turda** yazılır (`K127`) ve §0b'nin yedi
> kilidi arşive geçer.
>
> **EL:** Kapıyı **Claude Code** yazar. Altın küme koşumu, mutant koşumu ve **HÜKÜM Cowork'ün**
> (`K26`, `K34-f`). **Gövdeyi yazan el kapıyı yazamaz.**
> **v1 ve v2 KİLİTTEN ÖNCE denetlendi.** v1 ⇒ 20 bloker. v2 ⇒ 12/19 (A) ve 8/11+6/9 (B) **kapandı**,
> 4 yeni bloker. 🔴 **İki denetçi de: *"üçüncü kâğıt turu AÇILMASIN, kalan bulgular mimariyi
> değiştirmiyor"*** (`K53/1`). v3 o nokta düzeltmeleridir.

---

## 0. KİLİT ÖNCESİ BAĞIMSIZ DENETİM (`K127` — PAZARLIKSIZ)

| tur | denetçi | mercek | agentId | bulgu | hüküm |
|---|---|---|---|---|---|
| 1 | A | çürütme / ölçülebilirlik | `a76f36d14680f312d` | 9 bloker · 10 major · 5 minor | **GEÇMEZ** |
| 1 | B | iç çelişki / kilit çatışması | `a52a2c8bfe32423e3` | 11 bloker · 9 major · 5 minor | **GEÇMEZ** |
| 2 | A | kapanış + yeni yüzey | `a76f36d14680f312d` | 12 kapandı · 4 yeni bloker · 6 major | **GEÇMEZ** — *"3. tur açılmasın"* |
| 2 | B | kapanış + kilit çatışması | `a52a2c8bfe32423e3` | 8+6+5 kapandı · 3 yeni bloker · 6 major | **GEÇMEZ** — *"yeni kâğıt turu açılmasın"* |

🟢 Denetim **kilitten ÖNCE** koştu; **repoya tek bayt yazılmadı.** Anlatım: Cowork projesi
`claude/oturum-67-K170-kapi-speci-v1-DENETIMDE-DUSTU.md`.

### 0a. v2 → v3 ONARIM İZİ

| bulgu | v2'nin kusuru | v3'te nerede |
|---|---|---|
| **A/YB1 · B/Y1** 🔴 | `D-K170-9` *"NFKD normalize eder VE `İ→i` uygular"* — **ölçüldü, NFKD her konumda bozuyor** | `D-K170-9` **yeniden yazıldı**; dört reçetenin ölçüm tablosu kilit metnine kondu |
| **A/YB4 · B/Y3** 🔴 | `M268` fixture'ı `_BUILD.json`'a dayanıyordu; **o dosyada `engineRevision` YOK** | `G52/a2` kaynağı **`flutter_bootstrap.js`**; `_BUILD.json` **çıkarıldı**; dosya yoksa **ORTAM HATASI** (§4c) |
| **A/YB3 · B/Y8** 🔴 | `G54/a`'nın *"tırnaklı alıntı"* tanımı **yoktu** ⇒ dar okumada 0 tetik, geniş okumada **9 sahte KIRMIZI** | `G54/a`'ya **alıntı sözdizimi** yazıldı; tek-backtick **HARİÇ**; `NK4`/`NK5` iki ölçülmüş yanlış-pozitifi bekçiliyor |
| **A/YB2 · B/B8** 🔴 | Kriter 3 **karşılanamazdı** (V1 ve V4 hiçbir ayaktan çıkmıyordu) | V1 `G52/a2` düzeltmesiyle **kapandı**; 🔒 **V4 §8/7'ye taşındı, kriter 3 DÖRT V** (Onur, o67) |
| **B/Y7** | `M287` negatif kontroldü ama 27+1'in içindeydi | **`NK3`** oldu; mutant sayısı **27** |
| **B/Y2 · A/YB5,YB6,YB10** | `G55/a,b` 16 araç için kırmızı verirdi (envanter borcu) | 🔒 **DURUM İDDİASINA BAĞLANDI** (Onur, o67) + **stem** eşleşmesi; §8/6'ya envanter bayatlığı **beyanı** |
| **B/Y5** | `G53/d`'nin cümle penceresi yoktu (V3 ADR:39-40'a yayılı) | `G53/d`'ye **N=3 satır** penceresi; `M278` iki satıra yayılı fixture |
| **B/Y6** | `G55/c`'nin `<spec>` → dosya çözümlemesi yazılı değildi | çözümleme kuralı yazıldı; çözülemezse **SARI `spec-cozulemedi`** |
| **B/Y4** | Kriter 11 öz-testi `D-K170-8` ile uyumsuzdu | fixture belge aracı **adıyla** anar; kimlikler **önekli** (`ADR0004K/G52`) |
| **B/Y9** | §0a *"8 sahte KIRMIZI"* ↔ §5 *"5"* çelişkisi | **5** (v1 modeli) / **3** (yaprak modeli) — ikisi de yazıldı |
| **B/Y11 · Y12 · Y13** | `G56` harf boşluğu · `_hazir` dosyası · kriter 3'ün ölçüm sahibi | `G56/d`→**`G56/c`** · §4c'ye `_hazir` maddesi · kriter 3 *"Cowork eşler"* |
| **A/YB8 · YB11 · A/YB13** | `DURUM.md`**:122** yanlıştı · `M275` hedefi eksikti · `G53/c` teklik kuralı yoktu | **:121** · `M275` hedefi `G53/c · G53/a2` · `M277` **SARI `sabit-belirsiz`** |
| **A/YB7** | *"dosya 34"* tartışmalıydı (A **33** ölçtü) | 🔴 **Cowork yeniden ölçtü**, komut §4/5c'ye **yazıldı**: `find araclar -maxdepth 1 -type f` ⇒ **34** · dizin **2** · `ls -A` ⇒ **36**. A'nın 33'ü **doğrulanmadı**; reprodüksiyon komutu yazıldığı için sayı artık **tartışılabilir**, muallak değil |
| **A/B1 kalıntı** | Kriter 9 `siniflar`'ı faz işaretlerine karşı bağlamıyordu | kriter 9'a: **`kilit`/`mekaniklestirme` faz işaretidir, `siniflar`'a YAZILMAZ** |
| **A/B9 kalıntı** | `kor-kapi` **kısmen** mekanikleşiyor ama radar'ın *"kısmen"* hâli yok | kriter 9'a **açık uyarı** + §8/8; kararı **Onur verir** |
| **B/Y10** | `Cors:AllowedOrigins` da KIRMIZI verecek, öngörülmemişti | §8/10'a **beyan** (muhtemelen **gerçek** bulgu, V listesi dışında) |

### 0b. ONUR'UN KİLİT KARARLARI (oturum 67, 8 Ağu 2026)

> 🔴 **BEYAN:** bu yedi kilit **sohbette** verildi; `PROJE_HAFIZA.md` checkpoint'i **bu spec
> kilitlenirken aynı turda** yazılacaktır. Bugün `grep -nE "oturum 67|o67" PROJE_HAFIZA.md DURUM.md
> BORCLAR.md` ⇒ **sıfır satır** — bu, kaydın **henüz yazılmadığının** ölçümüdür.

1. 🔒 **DÖRDÜNCÜ AYAK: `kor-kapi`** — `radar.py`:136-141 ölçüldü; R1 yalnız `mekanik_kontrol_siniflari`
   o adı taşırsa söner. Üç ayakla R1 **KIRMIZI kalıyordu** (denetçi B simüle etti).
2. 🔒 **BEŞİNCİ AYAK: SINIF ADI SÖZLÜĞÜ (`G56`)** — defterde **115 ad**, ≥0.82 **5 çift**.
3. 🔒 **`G55` ARAÇ ADI ÜZERİNDEN ÖLÇER** (`D-K170-8`).
4. 🔒 **`G53` SABİT ÇÖZÜMLEME AYAĞI TAŞIR** (`G53/c`).
5. 🔒 **KRİTER 9'A ISIRAN MUTANT ŞARTI** (`D-K170-7`).
6. 🔒 **`G55/a,b` DURUM İDDİASINA BAĞLIDIR** (`D-K170-8`, o67 ikinci kilit). Ölçülmüş gerekçe:
   `KAPILAR.md` tablosu **11 araç satırı** taşıyor, `araclar/` altında **27 çalıştırılabilir** araç
   var; tablonun kendi envanter cümlesi **oturum 42'den** (*"20 dosya"* diyor, gerçek **34**) ⇒
   koşulsuz bir `G55/a` **16 araç için** kırmızı verirdi ve bunlar **gövdenin değil envanterin**
   borcudur. V6'nın özü zaten durum iddiasıydı (*"🟢 koşuyor"*).
7. 🔒 **V4 §8'E BEYANLI BOŞLUK, KRİTER 3 DÖRT V** (`V1·V2·V3·V6`). Ölçülmüş gerekçe: ADR:81'de
   `dosya:satır` da tırnaklı alıntı da **yok** ⇒ `G54/a` tetiklenemez. V5 için yapılanın aynısı.

---

## 1. NEDEN — ölçülmüş bağlam

`docs/ADR/0004-web-capraz-koken-izolasyonu.md` gövdesi **ÜÇ KEZ** düştü (`K164`·`K165`·`K169`).
Artefakt radarı (o67, cihazda, **tur açılmadan önce**):

```
[KIRMIZI] docs/ADR/0004-web-capraz-koken-izolasyonu.md
   tur 4 · oturum 3 · bloker egrisi [6, 0, 13, 6, 0] · bayt 13274 · son tur kapatilan 0 / uretilen 0
   [KIRMIZI] R1: TEKRAR EDEN KUSUR SINIFI, MEKANIK KAPISI YOK: kanonik-kopya (2 tur) ·
             kor-kapi (3 tur) · vaka-degil-sinif (3 tur) => 3. tur YASAK
```
> 🔴 **BEYAN:** blok aracın **ham ASCII** çıktısıdır; Türkçe karakter **geri konmadı**.

🔒 `K170`: **DÖRDÜNCÜ KÂĞIT TURU AÇILMAZ.** `K53/2`'nin **MEKANİKLEŞTİR** gerekçesi §5'te ayak ayak yazılı.

**Kapının kapatacağı ÖLÇÜLMÜŞ vakalar** *(her satır bağımsız denetçi tarafından yeniden ölçüldü)*:

| # | vaka | ürün koordinatı (ölçüldü) | ayak |
|---|---|---|---|
| V1 | `§8/3` *"`canvaskit.wasm` CORP'u **ölçülmedi**"* — canlı ölçüm `HTTP/2 200 · CORP: cross-origin · content-length 7229467` (`K169`'un sayısıyla **birebir**) | ADR:158 satırında URL **yok**; `<engineRevision>` **yer tutucu**. Çözüm kaynağı ölçüldü: `wwwroot/flutter_bootstrap.js` ⇒ `engineRevision":"83675ed27633283e7fc296c8bca22e841224c096"` **ve** `gstatic.com/flutter-canvaskit` | **G52/a2** |
| V2 | `Izolasyon:Etkin` kill switch üründe **var**, ADR'de **0 kez** geçiyor | `IzolasyonBasliklari.cs`:30 `const string EtkinAnahtari = "Izolasyon:Etkin";` · `Program.cs`:116 `GetValue(IzolasyonBasliklari.EtkinAnahtari, true)` — **JSON'da YOK** | **G53/c → G53/a2** |
| V3 | `UseCors()` **koşulludur**; ADR'nin sırası koşulu **gizledi** | ADR:39 *"Sıra zorunludur…"* · ADR:40 `` `UseCors()` (`:139`) `` (**iki ayrı satır**) ↔ `Program.cs`:137 `if (builder.Environment.IsDevelopment() && corsAllowedOrigins.Length > 0)` → `:139` | **G53/d** |
| V6 | `§5`'in *"🟢 koşuyor"*u ölçülmemiş **durum iddiası** | `yayin-kapisi.py` `KAPILAR.md`'de **0 geçiş**, `DURUM.md` §6'da **0 geçiş** | **G55/a,b** |
| V7 | `W3b/G51/b2`'nin mutantsız-ayak yarısı | *(yalnız bu yarısı)* | **G55/c** — ölü-mutant yarısı **§8/8** |

> 🔴 **V4 ÇIKARILDI** (Onur, o67) — ADR:81'de `dosya:satır` da tırnaklı alıntı da **yok** ⇒ `G54/a`
> tetiklenemez. **§8/7'de beyanlı boşluk.**
> 🔴 **V5 ÇIKARILDI** (v2'de) — o sayılar gövdede **geçmiyor** (`main.dart.js` 0 · `2.772` 0 · `3.44` 0).
> 🔴 **V8 (bayt/satır tazeliği) bu kapının işi DEĞİL** — `sayi-tazeligi.py` (§8/1).

---

## 2. KAPSAM

**İÇERİDE:** `araclar/adr-hukum-kapisi.py` (`G52`–`G56`) + `--altin-kume` · `araclar/sinif-sozlugu.json`
· `araclar/fixture/adr-hukum/**` · `KAPILAR.md` kapı-tetik satırı · `DURUM.md` §6 envanter satırı **ve
sayaç cümlesi** · 🔴 `DURUM.md` **§5 `K170` satırının güncellenmesi**: *"üç ayağı"* → **beş ayak**.
Bu **zorunludur** — yapılmazsa `DURUM.md`**:121** ölü beyan olur.

**DIŞARIDA (beyanlı):** `docs/ADR/0004` **gövdesi** · bayt/satır/sha tazeliği (§8/1) · defterin
**geçmiş** kayıtları (`D-K170-5`) · **ölü mutant tespiti** (§8/8) · `KAPILAR.md`'nin **eksik 16 araç
satırı** ve bayat envanter cümlesi (§8/6 — `B-O64-3` sınıfı, ayrı iş) · `KAPILAR.md` **şema
değişikliği** (kapı-kimliği sütunu).

---

## 3. KARARLAR

### D-K170-1 — Araç adı `adr-hukum-kapisi.py` 🔒
`araclar/adr-kapi-taramasi.py` ADR 0003'ün **DONDURULMUŞ** kapısıdır (`K41`). Ölçüldü:
`grep -rn "adr-hukum"` ⇒ **çakışma yok**.

### D-K170-2 — Kapı BELGE ALIR, dizin ALMAZ 🔒
`python araclar/adr-hukum-kapisi.py <belge.md> [--kok .]`. Dizin ⇒ **`[S0] BİÇİM`**, EXIT ≠ 0.
🔴 **İKİ AYRI OLGU** (v1 birleştirmişti — `kanonik-kopya`):
① `K81`'in *"kapsama ölçümü hiç yapılamadı"* sonucu **başlık şemasına** bağlıdır.
② `spec-kapi-kapsama.py` dizinle çağrılınca **ortama göre** farklı davranır: `CLAUDE.md` Windows'ta
`Permission denied` diyor; **Linux'ta ölçüldü** ⇒ `[Errno 21] Is a directory`, **EXIT 3**. Bu araç
**ortamdan bağımsız** olsun diye `[S0] BİÇİM` seçildi; `D-K170-3`'ün `ORTAM HATASI` sınıfı
**erişilemeyen KAYNAK** içindir, **yanlış ARGÜMAN** için değil.

### D-K170-3 — ULAŞILAMAYAN KAYNAK "TEMİZ" DEĞİL, **ORTAM HATASI**'DIR 🔒
🔴 **AYRIM ZORUNLU:** sunucu **cevap veriyor ama 404** ⇒ bu bir **ölçümdür**. Bağlantı
kurulamıyorsa ⇒ **ORTAM HATASI**. `M266` bu ayrımı ölçer.

### D-K170-4 — HEDEFİ ÇIKARILAMAYAN SATIR **SARI**'DIR 🔒 (`[SARI] hedef-cikarilamadi`)

### D-K170-5 — `G56` YALNIZ SON KAYDI BAĞLAR 🔒 (Onur, o67)
Defter **append-only** (`K83`). **Beyan edilmiş bedel:** geçmişteki 5 benzer çift **birleşmez** ⇒
ADR 0004'ün R1'i `olcemedigini-sanmak`'ı hâlâ **1 tur** sayar. **Geçmişi onarmaz, geleceği bağlar.**

### D-K170-6 — SÖZLÜKTE ≥0.82 ÇİFT **GEREKÇELİYSE** GEÇER 🔒
Girdi biçimi `{ad, tanim, ayri_tutuldu?}`. Ölçülmüş sebep: `yanlis-pozitif` ↔ `yanlis-pozitif-taban`
ve `arac-yanlis-pozitifi` ↔ `yanlis-pozitif` **farklı kavramlardır** (denetçi A: **en az 2/5**
yanlış-pozitif).

### D-K170-7 — 🔒 ISIRAN MUTANT ŞARTI (Onur, o67)
`radar.py`:136-141: `mekanik` **tüm turların birleşimidir**, defter **append-only** ⇒
**bir ad bir kez yazılınca R1 o sınıf için KALICI susar. GERİ ALINAMAZ.**
> **KURAL: Bir sınıf adı deftere ANCAK o sınıfı ölçen ayağın ISIRAN MUTANTI kabul koşumunda
> FİİLEN GÖRÜLDÜYSE yazılır.** Görülmeyen ad **YAZILMAZ** ve §8'e boşluk olarak geçer.
> Kayıt `artefakt`'ı **birebir** pinler; `siniflar` **gerçek** kusur sınıflarını taşır.

### D-K170-8 — 🔒 `G55` ARAÇ ADI ÜZERİNDEN ve **DURUM İDDİASINA BAĞLI** ÖLÇER (Onur, o67)
Ölçüldü: `grep -nE '\bG[0-9]+\b' KAPILAR.md` ⇒ **eşleşme yok**; tablo **araç adıyla** anahtarlı ve
**11 satır**; `araclar/` altında **27 çalıştırılabilir** araç var.
- **Eşleşme `stem` (uzantısız gövde) üzerindendir** — `KAPILAR.md` bazı araçları uzantısız yazıyor.
- **`a`/`b` YALNIZ belgenin DURUM İDDİASI taşıdığı araçlar için koşar** (`🟢` · `koşuyor` · `YEŞİL` ·
  `geçti` · `EXIT 0`, `D-K170-9` normalizasyonuyla). **Kutup duyarlıdır:** belge bir kapının
  **YOKLUĞUNU doğru** beyan ediyorsa bu **iddia değildir** (`NK3`).
- **Beyan edilmiş bedel:** belge bir aracı **iddiasız** anıyorsa envanter boşluğu **görülmez** (§8/6).

### D-K170-9 — 🔒 TÜRKÇE NORMALİZASYON — **REÇETE ÖLÇÜLDÜ**
🔴 **v2'nin reçetesi (NFKD) YANLIŞTI.** Dört yol koşuldu (`'ÖLÇÜLMEDİ'` → hedef `'ölçülmedi'`):

| # | yordam | sonuç | eşleşti mi |
|---|---|---|---|
| 1 | sade `.lower()` | `'ölçülmedi̇'` (`i`+U+0307) | **HAYIR** |
| 2 | **`İ→i`, `I→ı` sonra `.lower()`** | `'ölçülmedi'` | 🟢 **EVET** |
| 3 | NFKD sonra eşleme+`lower` | `'ölçülmedı̇'` | **HAYIR** |
| 4 | eşleme+`lower` sonra NFKD | *(görünüşte aynı)* | **HAYIR** — `ö`/`ç` ayrışır |

> **KANONİK REÇETE: `s.replace('İ','i').replace('I','ı').lower()` — NFKD KULLANILMAZ.**
> Tetikler **regex ailesidir**, kapalı kelime listesi değil: `ölç(ül)?[eü]?med` · `çözüleme` ·
> `koşulmad` · `yapılmad` · `\[DOĞRULANMADI\]`.

---

## 4. YAPILACAKLAR

1. `araclar/sinif-sozlugu.json` — başlangıç kümesi **elle sayılmaz**, betikle türetilir; ≥0.82
   çiftler ya birleştirilir ya `ayri_tutuldu` gerekçesi **dosyada durur**.
2. `araclar/adr-hukum-kapisi.py` — beş kapı, `--altin-kume` **zorunlu**, `D-K170-9` reçetesi.
3. `araclar/fixture/adr-hukum/**` — her ayak için temiz + kirli vaka; **pozitif kontroller ayrı
   fixture dosyalarında**. Fixture `KAPILAR.md`/`DURUM.md`/spec/`flutter_bootstrap.js` kopyaları
   **kanonik biçimin birebir kopyasıdır** (`ÖLÜ KURGU` yasağı — `M2b`/`B-O64-1` sınıfı).
4. `KAPILAR.md`'ye kapı-tetik satırı *(pay +10.810 b — bol)*.
5. 🔴 **`DURUM.md` DÖRT AYRI DÜZENLEME, ÖLÇÜLMÜŞ SIRAYLA:**
   - **a) ÖNCE BUDA.** Ölçüldü: pay **+1.692 b**, `T2` eşiği `32768 × 0,05 = 1.638,4 b` ⇒
     **serbest alan 53 bayt.** Budama **eklemeden önce**; budanan metin `_SILINECEKLER/o67/`'ye.
     🔴 **Hedef: eklenecek metnin baytı + en az 300 b emniyet payı.** Budanacak satırı **Onur seçer**
     (`K73`); Cowork **ölçer ve önerir**, kendi başına silmez.
   - **b)** §6 envanterine `adr-hukum-kapisi.py` satırı.
   - **c)** §6'nın **envanter sayaç cümlesi ÖLÇÜLEREK yeniden yazılır.** 🔴 **Reprodüksiyon komutları
     ve bugünkü sonuçları:** `ls araclar/*.py | wc -l` ⇒ **26** · `ls araclar/*.py araclar/*.ps1 | wc -l`
     ⇒ **27** · `ls araclar/*.json | wc -l` ⇒ **4** · `find araclar -maxdepth 1 -type f | wc -l` ⇒
     **34** · `find araclar -maxdepth 1 -mindepth 1 -type d | wc -l` ⇒ **2** · `ls -A araclar | wc -l`
     ⇒ **36**. Mevcut cümle *"31 dosya / 25 çalıştırılabilir / 24 `.py`"* diyor ⇒ **üçü de bayat.**
   - **d)** §5 `K170` satırı (**`DURUM.md`:121**): *"üç ayağı"* → **beş ayak**.
6. Commit (Claude Code) → push (Onur).

### 4b. EL DAĞILIMI

| iş | el | gerekçe |
|---|---|---|
| sözlük · araç · altın küme · fixture · `KAPILAR.md` · `DURUM.md` düzenlemeleri | **Claude Code** | `K26`; envanter kapıyla **aynı commit'te** |
| altın küme · **27 mutant + 5 NK** koşumu · **HÜKÜM** | **Cowork** | `K26`; üretici kendi kapısını onaylayamaz |
| commit | **Claude Code** | Cowork'te DC yok; mount'tan commit **YASAK** |
| push | **Onur** | `PUSH DAİMA ONUR'DA` |

### 4c. ORTAMI KİM KALDIRIR (`K80` — bu görev kendi maddesini TAŞIR)

**Backend/emülatör/Docker İSTENMEZ** — bu bir belge kapısıdır. `docker ps` · `netstat :5298` ·
`adb devices` **UYGULANMAZ**; bu bir **BEYANDIR**, atlama değil.

🔴 **v1'İN AĞ İDDİASI ÇÜRÜDÜ — ÖLÇÜLDÜ (o67, bulut):** `gstatic.com` ⇒ **404**, `example.com` ⇒ **200**
— **gerçek üst-akış yanıtları**, proxy bloğu değil. `git fetch`'in 403'ü **git-over-HTTPS'e özgüdür**.
Bu, kapının kapatmak için yazıldığı `olcemedigini-sanmak` sınıfının **spec'in kendisinde** tekrarıydı.

**AĞ / YEREL SUNUCU ORTAMI (`M265`/`M266`):**
- **Dış ağa çıkılmaz.** `python -m http.server` ile **yerel** fixture sunucusu (`127.0.0.1`, boş port).
- 🔴 **Sunulan dizinde `_hazir` adlı boş bir dosya OLUŞTURULUR** — yoklama hedefi budur.
- 🔴 **Sabit `sleep` bir ölçüm değildir** (`K80`): `GET /_hazir` **200** dönene kadar **yoklanır** —
  tavan **10 sn**, aralık **0,2 sn**; tavan aşılırsa **ORTAM HATASI**.
- Süreç turun sonunda kapatılır; kapandığı **ölçülür** (`connect` reddi), varsayılmaz.
- **Maliyet sınıfı beyanı:** bu iki mutant *"koşan yardımcı süreç"*tir. `K53/3`'ün **3/dilim** tavanı
  *"emülatör/tarayıcı + yeniden derleme"* içindir; yerel `http.server` o sınıfa **girmez**.
  **Beyan edilmiştir, sessizce alınmamıştır.**

🔴 **`G52/a2`'NİN GİZLENMEMİŞ ORTAM ŞARTI:** ayak `src/backend/Momentum.Api/wwwroot/flutter_bootstrap.js`
okur. Ölçüldü: `git check-ignore -v` ⇒ **`.gitignore:31: …/wwwroot/`** ⇒ dosya **git-izsiz build
çıktısıdır**. Temiz klonda / CI'da / `flutter build web` koşmamış makinede **yoktur** ⇒
**dosya yoksa `ORTAM HATASI`** (yeşil **değil**) ve kriter 3'ün V1 ayağı **"ölçülmedi"** sayılır.

---

## 5. KAPILAR

> Her ayak **tam bir kanonik sınıf adı** taşır; yanında `K53/2`'nin istediği yazılı gerekçe durur.
> **Toplam 22 ayak** — §6'da 22'sinin de hedefi vardır.

### G52 — `ÖLÇÜLEMEDİ` AYAĞI · sınıf: **`olcemedigini-sanmak`** (kapsam: hedef belge) — 5 ayak

**Gerekçe (K53/2):** *"ölçmedim"* iddiası, belgenin **kendi metninden** hedef çıkarıp o hedefi
okumakla ölçülür. ✅ koşan kod olmadan ölçülebilir.

- **a)** `D-K170-9` regex ailesiyle tetiklenen satırda **açıkça yazılı URL** varsa `HEAD`, olmazsa
  `GET`. **2xx/3xx ⇒ KIRMIZI.** Bağlantı kurulamıyorsa **ORTAM HATASI**; **404 bir ÖLÇÜMDÜR**.
- **a2)** Satırdaki yol `<yertutucu>` içeriyorsa, **host ve yer tutucu** `wwwroot/flutter_bootstrap.js`'ten
  doldurulmaya çalışılır (ölçüldü: dosya hem `engineRevision":"…"` hem `gstatic.com/flutter-canvaskit`
  taşıyor). Dolarsa hedef **ÇIKARILMIŞTIR** ⇒ SARI değil, sonuç `a`'ya beslenir. Dosya yoksa
  **ORTAM HATASI** (§4c). 🔴 **`_BUILD.json` kaynak DEĞİLDİR** — ölçüldü, `engineRevision` **taşımıyor**.
- **b)** Satırda **repo-içi yol** + tırnaklı desen varsa: desen dosyada **bulunursa KIRMIZI**.
- **c)** Hedef çıkarılamazsa **`[SARI] hedef-cikarilamadi`** (`D-K170-4`).
- **d)** **POZİTİF KONTROL — AYRI FIXTURE'DA** (`fixture/adr-hukum/pozitif-kontrol.md`); bilinen
  tetik bulunamazsa **ORTAM HATASI**.

### G53 — ANAHTAR KAPSAMA AYAĞI · sınıf: **`vaka-degil-sinif`** (kapsam: belgenin andığı ürün dosyaları) — 6 ayak

**Gerekçe (K53/2):** anahtarlar, sabitler ve `if` sarmalayıcıları **kaynak metinden** statik olarak
çıkarılır. ✅ koşan kod olmadan ölçülebilir.

- **a)** Belgenin andığı JSON'un **YAPRAK** anahtar yolları; belgede geçmeyen ⇒
  **`[SARI] anahtar-anilmadi`**. *(v1 bunu KIRMIZI yapıyordu: `appsettings.json`'da **5** sahte
  KIRMIZI. Yaprak kuralıyla o sayı **3**'e düşer — `Logging:LogLevel:Default` ·
  `Logging:LogLevel:Microsoft.AspNetCore` · `AllowedHosts`.)*
- **a2)** 🔴 **KIRMIZI YALNIZ BURADA:** `b`/`c` ile bulunan — **kodun FİİLEN OKUDUĞU** — bir anahtar
  belgede geçmiyorsa **KIRMIZI**. *(V2)*
- **b)** `.cs`'te `Configuration[...]` · `GetValue<…>(…)` · **generic'siz `GetValue(…)`** ·
  `GetSection("…")`. 🔴 **`TryGetValue(` NEGATİF FİLTRE** (`NK1`).
- **c)** 🔒 **SABİT ÇÖZÜMLEME:** argüman `X.Y` biçiminde **sembol** ise repoda `const string Y = "A:B"`
  aranır ve çözülür. Çözülemezse **`[SARI] anahtar-cozulemedi`**. 🔴 **TEKLİK KURALI:** aynı adlı
  **birden çok** `const string` bulunursa **`[SARI] sabit-belirsiz`** — KIRMIZI değil.
- **d)** Belge bir çağrıyı **koşulsuz** anlatıyorsa ama üründe o çağrı `if (…)` gövdesindeyse
  **KIRMIZI**. 🔴 **PENCERE: tetik satırından itibaren N=3 satır** — ölçülmüş gerekçe: V3'ün tetiği
  ADR:39'da, çağrı adı ADR:40'ta. Tetik ailesi **kök tabanlıdır** (`zorunlu`+`sıra` aynı pencerede ·
  `her ortamda` · `her yanıtta` · `→` ok grafiği) ve `D-K170-9` uygulanır.
  🔴 **BEYAN:** aile **kapalıdır** (§8/3).
- **e)** Belgenin andığı dosya diskte **yoksa** ⇒ **KIRMIZI** (`var-olmayan-artefakta-hukum`).

### G54 — ATIF BİREBİRLİK AYAĞI · sınıf: **`kanonik-kopya`** (kapsam: belgedeki kaynak atıfları) — 4 ayak

**Gerekçe (K53/2):** alıntı ile kaynak arasındaki fark iki metnin karşılaştırılmasıdır.
✅ koşan kod olmadan ölçülebilir.

- **a)** 🔴 **ALINTI SÖZDİZİMİ TANIMLIDIR** *(v2'de tanımsızdı — dar okumada 0 tetik, geniş okumada
  **9 sahte KIRMIZI**)*: alıntı **yalnız** `*"…"*` · `«…»` · satır başı `> ` blok alıntıdır **ve en
  az 12 karakterdir**. 🔴 **Tek-backtick'li tanımlayıcı (`` `OnStarting` ``) ALINTI DEĞİLDİR** — bu
  projede **vurgudur**; iki ölçülmüş yanlış-pozitif (`ADR:31`, `ADR:33`) `NK4`/`NK5` ile bekçilenir.
  Atıf `dosya:satır` **veya `dosya:a-b`** olabilir; alıntı **atıf satırından başlayan N=5 satırlık
  pencerede** aranır (boşluk normalize; **anlam değiştiren kelime normalize EDİLMEZ**). Yoksa
  **KIRMIZI**. 🔴 **N=5 beyan edilmiş bir sayıdır**; daha uzun kaynak cümleleri **ölçülmedi** (§9).
- **b)** Çıplak dosya adı repoda **tek** eşleşmeye çözülürse kullanılır; **birden çok** ⇒
  **`[SARI] yol-belirsiz`**.
- **c)** `dosya:satır` var ama dosyada o satır yoksa ⇒ **KIRMIZI** (sarkan atıf).
- **d)** Belgedeki bir **kilit metni** kanonik kaynağından farklıysa ⇒ **`[SARI] kanonik-kopya`**.

### G55 — 🔒 KÖR KAPI AYAĞI · sınıf: **`kor-kapi`** *(kısmi — §8/8)* — 4 ayak

**Gerekçe (K53/2):** *"bu kapı koşuyor"* iddiası, **envanter tablolarını ve spec §6 mutant tablosunu
okuyarak** ölçülür. ✅ koşan kod olmadan ölçülebilir.

- **a)** 🔒 Belge bir **araç** hakkında **DURUM İDDİASI** taşıyorsa (`D-K170-8`), o aracın **stem**'i
  `KAPILAR.md` kapı-tetik tablosunda var mı ⇒ yoksa **KIRMIZI**. *(V6)*
- **b)** Aynı koşulda, aynı stem `DURUM.md` §6 envanterinde var mı ⇒ yoksa **KIRMIZI**. *(V6)*
- **c)** Belgede anılan her **kapı kimliği** (`<spec>/G<n>`, `K108` önekli) için, o spec'in
  `## 6. MUTANTLAR` tablosunda **`hedef` sütununda** (üçüncü sütun, `K126`) o kimliği taşıyan satır
  var mı ⇒ yoksa **KIRMIZI** (`K155`). 🔴 **`<spec>` → dosya çözümlemesi:**
  `GOREV_CLAUDE_CODE/GOREV-<spec>-*.md` (ölçüldü: mevcut tüm spec'lerde çalışıyor); çözülemezse
  **`[SARI] spec-cozulemedi`**, KIRMIZI değil. *(V7'nin yalnız mutantsız-ayak yarısı.)*
- **d)** **POZİTİF KONTROL — AYRI FIXTURE'DA** (`fixture/adr-hukum/pozitif-kontrol-kapilar.md`);
  bilinen araç adı bulunamazsa **ORTAM HATASI**.

### G56 — 🔒 SINIF ADI SÖZLÜĞÜ (kapsam: `sinif-sozlugu.json` + `PROJE_RADAR.jsonl` **son satırı**) — 3 ayak

**Gerekçe (K53/2):** iki dizgenin benzerliği saf metin ölçümüdür. ✅ koşan kod olmadan ölçülebilir.

- **a)** Defterin **son** kaydındaki her `siniflar` öğesi sözlükte yoksa ⇒ **KIRMIZI** + ≥0.82 öneri.
- **b)** Sözlükte ≥0.82 çift varsa ve `ayri_tutuldu` gerekçesi **yoksa** ⇒ **KIRMIZI** (`D-K170-6`).
- **c)** Sözlükte **tanımsız** (boş `tanim`) ad varsa ⇒ **SARI**. *(v2'de `d` idi; harf boşluğu
  kapatıldı — boşluk "silinmiş ayak" izlenimi veriyordu.)*

> 🔴 **v1'in `G56/c`'si (beyan satırı) AYAK OLMAKTAN ÇIKARILDI:** bir **girdi ayağı değil, aracın
> davranış şartıdır**; mutantla ölçülemez ve `K155` gereği ayak borçlanamaz. `D-K170-5` + **kriter 6**.

---

## 6. MUTANTLAR — kapıların ISIRDIĞININ KANITI

> Taksonomi: `gözlenen ⊇ hedef` ⇒ **ERRATUM** · `gözlenen ⊉ hedef` ⇒ **KÖR KAPI (BLOKER)** ·
> `gözlenen = {}` (beklenirken) ⇒ **ÖLÜ MUTANT**, kusur mutanttadır.
> **KOŞUM DİSİPLİNİ (`K118`):** ikili yedek → **bayt düzeyinde** yama → kapı → geri yükleme → **sha**.
> 🔴 **ÜÇÜNCÜ SÜTUN `hedef`TİR (`K126`)**; kural kimliği (`D-K170-n`) de **bu sütunda** durur.
> 🟢 **HEPSİ FIXTURE ÜZERİNDE** — kanonik belgelere dokunulmaz ⇒ mount `unlink` kısıtı **yok**.
> 🔴 **MALİYET SINIFI:** **25'i saf statik** (`K53/3` ⇒ tavansız) · **`M265`/`M266` yerel
> `http.server` ister** (*"koşan yardımcı süreç"*, ortam maddesi §4c'de). **Cowork 27'sini de koşar.**
> 🔴 **`NK` satırları NEGATİF KONTROLDÜR: mutant sayımına GİRMEZ**, *"ölü mutant yok"* kriterine
> **tabi değildir** — susmaları **beklenen** davranıştır.

| ID | mutant | hedef | beklenen |
|---|---|---|---|
| M265 | fixture belgeye *"CORP `ÖLÇÜLEMEDİ` (`http://127.0.0.1:<port>/x.wasm`)"*; yerel sunucu **200** | G52/a | KIRMIZI |
| M266 | aynı satır, yerel sunucu **kapalı** (bağlantı reddi) | G52/a · D-K170-3 | ORTAM HATASI |
| M267 | aynı satır **`ÖLÇÜLMEDİ`** (büyük `İ`) ve ayrıca **`ÖLÇÜLEMEDİ`** yazımıyla | G52/a · D-K170-9 | KIRMIZI (iki vaka) |
| M268 | *"`canvaskit/<engineRevision>/x.wasm` **ölçülmedi**"*; fixture `flutter_bootstrap.js` host + revision taşır, yerel sunucu **200** | G52/a2 | KIRMIZI |
| M269 | *"`araclar/radar.py` içindeki `'mekanik'` deseni **ölçülemedi**"*; desen dosyada **var** | G52/b | KIRMIZI |
| M270 | tetik satırından URL ve yol **çıkarılır** | G52/c · D-K170-4 | SARI `hedef-cikarilamadi` |
| M271 | `fixture/pozitif-kontrol.md`'den bilinen tetik **silinir** | G52/d | ORTAM HATASI |
| M272 | fixture JSON'a **yaprak** anahtar eklenir; belgede anılmaz, kod da **okumaz** | G53/a | SARI `anahtar-anilmadi` |
| M273 | aynı anahtar fixture `.cs`'te `Configuration["…"]` ile **okunur**, belgede yok | G53/a2 | KIRMIZI |
| M274 | fixture `.cs`'e **generic'siz** `GetValue("Yeni:Anahtar", true)` eklenir | G53/b | KIRMIZI |
| M275 | fixture `.cs`'e `const string A = "Izolasyon:Etkin";` + `GetValue(Cls.A, true)`; belgede yok | G53/c · G53/a2 | KIRMIZI *(V2)* |
| M276 | sembol argümanın `const`'u fixture'dan **silinir** | G53/c | SARI `anahtar-cozulemedi` |
| M277 | **iki** fixture dosyasında aynı adlı `const string` bulunur | G53/c | SARI `sabit-belirsiz` |
| M278 | fixture `.cs`'te `UseCors()` `if (env.IsDevelopment())` içine alınır; belgede tetik **satır N**, çağrı **satır N+1** | G53/d | KIRMIZI *(V3)* |
| M279 | belgenin andığı fixture dosyanın **adı değiştirilir** | G53/e | KIRMIZI |
| M280 | fixture kaynakta *"izolasyon **verir**"*, belgede `x.py:27` atfı + `*"izolasyon vermez ama alt kaynak"*` alıntısı | G54/a | KIRMIZI |
| M281 | çıplak `Program.cs:10` atfı; fixture'da **iki** `Program.cs` | G54/b | SARI `yol-belirsiz` |
| M282 | belgeye `fixture/x.cs:9999` atfı (dosya 20 satır) | G54/c | KIRMIZI |
| M283 | belgeye `K21` kilit metni **değiştirilerek** kopyalanır | G54/d | SARI `kanonik-kopya` |
| M284 | belge `yayin-kapisi.py` için *"🟢 koşuyor"* der; fixture `KAPILAR.md`'de satırı **yok** | G55/a · D-K170-8 | KIRMIZI *(V6)* |
| M285 | aynı iddia; araç fixture `KAPILAR.md`'de **var**, fixture `DURUM.md` §6'da **yok** | G55/b | KIRMIZI |
| M286 | belgede `W3b/G48` anılır; fixture spec §6'da o kimliği `hedef` alan satır **yok** | G55/c | KIRMIZI |
| M287 | `fixture/pozitif-kontrol-kapilar.md`'den bilinen araç adı **silinir** | G55/d | ORTAM HATASI |
| M288 | fixture defterin son kaydına `olculemedi-sanmak`; sözlükte `olcemedigini-sanmak` var | G56/a | KIRMIZI + öneri |
| M289 | sözlüğe `kor-kapi` yanına `kor-kapilar`, **`ayri_tutuldu` gerekçesi YOK** | G56/b · D-K170-6 | KIRMIZI |
| M290 | sözlüğe **boş `tanim`** alanlı ad eklenir | G56/c | SARI |
| M291 | araç **dizin** argümanıyla çağrılır | D-K170-2 | `[S0] BİÇİM`, EXIT ≠ 0 |
| NK1 | fixture `.cs`'e `TryGetValue(headerName, out _)` eklenir | G53/b *(negatif kontrol)* | **SUSMALI** |
| NK2 | `M280`'in alıntısı yalnız **boşluk** farkıyla ve atıf satırından **2 satır aşağıda** | G54/a *(negatif kontrol)* | **SUSMALI** |
| NK3 | belge bir kapının **yokluğunu doğru** beyan eder (*"`W3/G43`–`G47` implementasyonu yok"*) | G55/a *(negatif kontrol — kutup)* | **SUSMALI** |
| NK4 | `ADR:31` **birebir** fixture'a kopyalanır (`` `OnStarting` `` + `IzolasyonBasliklari.cs`:32-36) | G54/a *(negatif kontrol — backtick)* | **SUSMALI** |
| NK5 | `ADR:33` **birebir** fixture'a kopyalanır (`` `UseCors` `` + `Program.cs`:117) | G54/a *(negatif kontrol — backtick)* | **SUSMALI** |

**Mutant sayısı: 27** (+**5 negatif kontrol**, sayıma girmez).

---

## 6b. MUTANTSIZ KURALLAR — BEYANLI BORÇ

> Her satır **DÖRT** alanlıdır: `ID | KURAL | NEDEN MUTANT YOK | KAPATMA YOLU`.
> 🔴 **KAPI AYAĞI BORÇLANAMAZ, yalnız KURAL** (`K155`). **Ölçüldü:** §5'in **22 ayağının 22'si**
> §6'da bir mutant tarafından hedeflenmiştir; aşağıdaki üç kalem **kural**dır, ayak değil.

```
B-K170-1 | D-K170-5 (gecmis kayitlar denetlenmez) | kural bir KAPSAM DISLAMASIDIR: mutant kapinin ISIRDIGINI kanitlar, ISIRMADIGINI kanitlayamaz -- "olcmedigimiz sey" icin isiran mutant yazilamaz | kabul kriteri 6: arac her kosumda beyan satirini basar ve o satirin ciktida FIILEN oldugu Cowork tarafindan olculur
B-K170-2 | D-K170-7 (isiran mutant sarti) | bir SUREC kuralidir, aracin girdisi degil: "deftere ne yazilacagini" belirler ve aracin davranisini hic degistirmez => girdi mutasyonuyla olculemez | kabul kriteri 9: deftere yazilan her sinif adi icin o sinifin isiran mutant kimligi hukumde ADIYLA gosterilir; gosterilemeyen ad yazilmaz
B-K170-3 | D-K170-1 (arac adi secimi) | ad secimi bir TASARIM kararidir; "yanlis ad" bir kapiyla olculemez -- ancak kapi-ad-teklik-kapisi.py'nin BELGE tarafi (spec dosyalarini da taramasi) yazilirsa olculur | araclar/kapi-ad-teklik-kapisi.py:43 HEDEF_BELGELER listesine GOREV_CLAUDE_CODE/** eklenir; ayri bir istir, bu turda ACILMAZ
```

---

## 7. KABUL KRİTERLERİ

1. `python araclar/adr-hukum-kapisi.py --altin-kume` ⇒ **EXIT 0**, `N/N` (**N ≥ 27**);
   §5'in **22 ayağının 22'si** altın kümede **en az bir temiz + bir kirli** vakayla temsil edilir.
2. **27 mutantın 27'si** `K118` disipliniyle koşar; **ölü mutant YOK**, kör ayak YOK.
   **`NK1`–`NK5` ayrıca koşar ve SUSAR** (sayıma ve bu kritere girmez).
   🔴 Hükmü **Cowork verir** (`K26`).
3. `python araclar/adr-hukum-kapisi.py docs/ADR/0004-…md` koşar; **Cowork çıktıdaki bulguları
   `V1·V2·V3·V6`'ya eşler ve DÖRDÜNÜ DE bulur.** *(V4 ve V5 §8'de beyanlı boşluktur; araçta "V"
   kaydı yoktur, eşleme Cowork'ün ölçümüdür.)*
4. `python araclar/adr-hukum-kapisi.py araclar` ⇒ **`[S0] BİÇİM`**, EXIT ≠ 0 (`D-K170-2`).
5. `python araclar/belge-tavan-kapisi.py .` ⇒ **YEŞİL**. §4/5a budaması **eklemeden önce**;
   ölçülmüş serbest alan **53 bayt**, hedef **eklenen bayt + ≥300 b pay**.
6. Araç her koşumda `D-K170-5` **beyan satırını** basar; Cowork çıktıda **fiilen görür** (`B-K170-1`).
7. `python araclar/sayi-tazeligi.py .` **TEMİZ** kalır.
8. `python araclar/spec-kapi-kapsama.py GOREV_CLAUDE_CODE/GOREV-ADR0004-KAPISI.md` ⇒ **EXIT 0**.
   🔴 **KİLİTLENMEDEN ÖNCE koşulur** — v1 tam burada düştü. *(v3 taslağında **ölçüldü: EXIT 0**.)*
9. 🔒 **DEFTER SATIRI (`D-K170-7`):** kayıt `artefakt` = `docs/ADR/0004-web-capraz-koken-izolasyonu.md`
   (**birebir**) · `siniflar` = kabul turunun **gerçek** kusur sınıfları
   🔴 **`kilit`/`mekaniklestirme` FAZ İŞARETİDİR, `siniflar`'a YAZILMAZ** (denetçi A simüle etti:
   yazılırsa R1 **yeni bir tekrar sınıfı** doğurur ve kapıyı kendi kriteriyle reddettirir) ·
   `mekanik_kontrol_siniflari` = **yalnız ısıran mutantı GÖRÜLEN sınıflar**, her biri için mutant
   kimliği hükümde **adıyla** yazılır. Sonra `radar.py . --artefakt docs/ADR/0004-…` yeniden koşulur
   ve `R1` **ÖLÇÜLÜR**.
   🔴 **AÇIK UYARI:** `G55` `kor-kapi`nin yalnız **envanter/durum-iddiası/mutantsız-ayak** yarısını
   ölçer; `radar.py`'nin `mekanik` kümesinde *"kısmen"* diye bir hâl **yoktur** ⇒ o adı yazmak sınıfı
   **tümüyle ve kalıcı** susturur. **Yazılıp yazılmayacağına ONUR karar verir** (§8/8).
   🔴 **R1'in sönmesi bir hedef değil, bir SONUÇTUR:** sönmezse gövde **yine açılmaz**.
10. `git --no-optional-locks config user.email` = `onurkesimbjk@gmail.com` (`K149`); commit'ten sonra
    `.git/index.lock` **yokluğu ölçülür**.
11. 🔴 **ÖZ-TEST:** araç, `adr-hukum-kapisi.py`'yi **ADIYLA anan** ve `ADR0004K/G52`–`G56` kimliklerini
    **önekli** yazan bir fixture belge üzerinde koşar (`K108`); o fixture'ın `KAPILAR.md` kopyasından
    araç satırı silinince **KIRMIZI** verir.
12. `DURUM.md`:121 `K170` satırı **beş ayak** der; §6 envanter sayaç cümlesi §4/5c'nin **ölçülmüş**
    sayılarını taşır.

---

## 8. BEYAN EDİLMİŞ SINIRLAR — *"neyi ölçmüyoruz"*

1. **Sayı/bayt/sha tazeliği bu kapının işi DEĞİL** — `sayi-tazeligi.py` + `dosya-kimlik.py`.
2. **`G53` yalnız belgenin ANDIĞI dosyaları tarar.** Belge bir ürün dosyasını hiç anmıyorsa
   yakalanmaz. V2 yakalanır çünkü ADR `Program.cs`'i anıyor — **anmasaydı yakalanmazdı**.
3. **`G53/d`'nin tetik ailesi ve N=3 penceresi KAPALIDIR.** `K161`'in *"vaka ölçmek sınıf kapatmaz"*
   uyarısı bu ayak için **geçerlidir** ve burada **açıkça beyan edilmiştir**.
4. **`G54/a` metinsel karşılaştırma yapar**; paraphrase edilmiş ters-alıntı **yakalanmaz**. Ayrıca
   **tek-backtick'li tanımlayıcı alıntı sayılmaz** ⇒ öyle yazılmış bir ters-alıntı **görülmez**.
5. **`G52/a` yalnız açıkça yazılı URL'yi ölçer**; `a2` dışındaki türetmeleri yapmaz. `a2`
   `flutter_bootstrap.js`'e bağlıdır ve o dosya **git-izsizdir** ⇒ temiz klonda **ORTAM HATASI** (§4c).
6. 🔴 **`G55/a,b` DURUM İDDİASINA BAĞLIDIR** (`D-K170-8`). Belge bir aracı **iddiasız** anıyorsa
   envanter boşluğu **görülmez**. **Ölçülmüş bağlam:** `KAPILAR.md` tablosu **11 araç satırı**
   taşıyor, `araclar/` altında **27 çalıştırılabilir** araç var, ve tablonun envanter cümlesi
   **oturum 42'den** kalma (*"20 dosya"*, gerçek **34**) ⇒ **16 araç tabloda yok.** Bu, gövdenin
   değil **envanterin** borcudur (`envantersiz-kapı`, `B-O64-3`) ve **bu turda KAPANMAZ**.
7. **V4 (`credentialless` ters-alıntısı) BU KAPIYLA KAPANMAZ** 🔒 (Onur, o67). Ölçüldü: ADR:81'de
   `dosya:satır` **yok**, tırnaklı alıntı **yok** ⇒ `G54/a` tetiklenemez. Kaynak hâlâ ters
   (`izolasyon-olc.py`:27 *"izolasyon **verir** ama…"* ↔ ADR *"**vermez**"*). Kapatma yolu: gövde
   turunda ADR:81'e atıf + birebir alıntı yazılması, **ya da** ayrı bir "kutup" ayağı — **ikisi de
   bu turda YAZILMADI.**
8. 🔴 **ÖLÜ MUTANT TESPİTİ KAPSAM DIŞIDIR** ⇒ `kor-kapi` **KISMEN** mekanikleşir.
   `spec-kapi-kapsama.py` bu sınırı kendi çıktısında beyan ediyor: *"bu betik mutantin GERCEKTEN
   ISIRDIGINI olcmez; esdeger-mutant tespiti calisan kod ister."* V7'nin *"9/16 mutant ÖLÜ çıktı"*
   yarısı **açık kalır**. Kriter 9 bunu dürüstçe raporlar ve `mekanik_kontrol_siniflari`'na
   `kor-kapi` yazılıp yazılmayacağına **Onur karar verir**.
9. **V5 (`§3`'ün ana kanıtının başka build'e ait olması) KAPANMAZ** — o sayılar gövdede geçmiyor.
10. **`Cors:AllowedOrigins` ÖNGÖRÜLEN BİR EK BULGUDUR.** Ölçüldü: `Program.cs`:98
    `GetSection("Cors:AllowedOrigins")` · ADR'de **0 geçiş** ⇒ `G53/a2` **KIRMIZI** verecek.
    Muhtemelen **gerçek** bir bulgudur ama `V1`–`V6` listesinin **dışındadır**; kriter 3 onu şart
    koşmaz, hüküm onu **ayrıca raporlar**.
11. **Bu kapı gövdenin DOĞRU olduğunu ölçmez** — yalnız tekrar eden kusur sınıflarını. Yeşil hüküm
    *"gövde kabul edilebilir"* demek **değildir**; `K127` denetimi **yerine geçmez**.

---

## 9. NE ÖLÇÜLEMEDİ *(v3 yazımı sırasında)*

- **Aracın gerçek davranışı** — `adr-hukum-kapisi.py`, `sinif-sozlugu.json`, `fixture/adr-hukum/**`
  **henüz yok** (üç denetçi turu da bunu ölçtü). §5'in her hükmü **metinden çıkarımdır**.
  **Güven: KESİN (girdi ölçümleri) / ZAYIF (türetilen kapı çıktıları).**
- **27 mutantın hiçbiri koşulmadı.** `M265`/`M266`'nın yerel `http.server` ayrımı
  (*"404 ölçümdür, bağlantı reddi ORTAM HATASI'dır"*) **fiilen doğrulanmadı**.
- **`0.82` eşiğinin yanlış-pozitif oranı** — 115 ad / 5 çift **iki denetçi tarafından bağımsız
  doğrulandı**; hangi çiftin gerçekten aynı sınıf olduğu **ölçülmedi**. `ayri_tutuldu` bunu
  **yönetir ama ÖLÇMEZ**.
- **`G53/d`'nin C# `if` çözümlemesi** — iç içe `if` / ternary / `when` **[DOĞRULANMADI]**.
- **`G54/a`'nın N=5 penceresi** — `izolasyon-olc.py`:27-28 (2 satır) için yeter; **daha uzun kaynak
  cümleleri ölçülmedi**.
- **Windows/PowerShell ayağı** — tüm ölçümler Linux (`device_bash`) + bulut konteynerinde koştu.
  `belge-tavan-kapisi.py`'nin Windows koşumu, CRLF etkisi, `verify.ps1` **ÖLÇÜLMEDİ**. Kabul koşumu
  **cihazda** yapılmalıdır (`ORTAM.md`: *"kapı hükmü, koştuğu ortamın hükmüdür"*).
- **`KANIT/**` açılmadı** (üç denetçi turunun hiçbirinde) — V1'in `content-length: 7229467` sayısı
  denetçi A tarafından **canlı ölçüldü**, ama `KANIT/W3b/07` ölçüm tabanı **kanıtsız kabul edildi**.
- **`BORCLAR.md` ve `PROJE_HAFIZA.md` açılmadı** (`K53`/`K83`) — `B-O64-1`, `B-O64-3`, `B-O62-3`,
  `B-W3b-6…10` kimlikleri **doğrulanmadı**; kilit metinleri `CLAUDE.md`/`DURUM.md`'den alındı.
- **`DURUM.md`'den kaç bayt budanabileceği** — ölçülmedi; budanacak satırı **Onur seçer** (`K73`).
- **`find araclar -maxdepth 1 -type f` sayısı** — Cowork **34**, denetçi A **33** ölçtü.
  Komut §4/5c'ye yazıldı; **çelişki `[DOĞRULANMADI]` olarak duruyor** ve kabul koşumunda **cihazda
  yeniden ölçülecektir**.
