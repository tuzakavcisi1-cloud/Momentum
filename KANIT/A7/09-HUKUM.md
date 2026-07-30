# KANIT/A7/09-HUKUM.md — GOREV-A7 BUILD HÜKMÜ (Claude Code, build eli)

**Kim:** Claude Code — bu spec'i **Cowork yazdı**, bağımsız denetimini (`01-DENETIM.md`)
**Claude Code yaptı**, build de Claude Code'da. **K26 gereği bu belge bir DENETİM DEĞİL, build elinin
kendi ÖLÇÜM raporudur.** Bağımsız denetim Cowork'ün (ya da üçüncü bir elin) işidir; Cowork'ün bu ağaca
erişimi var ve artefaktları kendi sökecek — bu belge **beyan değil, ölçüm** bırakmak için yazıldı.

**Ne zaman:** 30 Temmuz 2026. 🔴 **Tarih ortam beyanından okunmadı, cihazdan ölçüldü:**
`Get-Date -Format 'yyyy-MM-dd HH:mm:ss K'` ⇒ **`2026-07-30 09:13:55 +03:00`** (K83‑DÜZELTME).

**Ölçülen yol / dal / HEAD:** `C:\dev\Momentum` · `main` · **`4fa3203`** · ikincil worktree **YOK**
(`git --no-optional-locks rev-parse --show-toplevel` / `--abbrev-ref HEAD` / `log --oneline -1` /
`worktree list`). Sapma yok.

**Spec kimliği ölçüldü:** `GOREV-A7-rozet-tasma.md` **21.126 b · `9DFC21A5`** ⇒ **v4** (beklenenle
birebir; v3 `2975E2DB` okunmadı).

---

## 0. NET KARAR

> ## ✅ **A‑7 BUILD TAMAMLANDI — 9 kabul kriterinin 8'i PASS, 1'i ŞARTLI PASS (devralınmış bulgu).**
> Yeni bloker **YOK**. `G13`/`G14`/`G15` yazıldı ve yeşil; **M74–M87 (14 mutant) HEPSİ ISIRDI**;
> **CM1–CM3 gerçek emülatörde geçti** ve `font_scale` + `density` **geri alındı, geri alındığı ÖLÇÜLDÜ**.
> **Şartlı olan tek kriter 7'dir** ve sebebi A‑7 **değildir**: `design-token-kapisi.py` ağaçta
> **devralınmış** iki `D2` bulgusuyla kırmızıdır (§5). **Onur'un tek kararı §7'dedir.**

**Ölçülen sayılar (hepsi çıktıdan okundu, ezberden yazılmadı):**

| ölçüm | değer | kanıt |
|---|---|---|
| `flutter analyze --fatal-infos` | **0 issue**, EXIT 0 | `01-analyze.txt` |
| `flutter test` (TAM) | **266/266 geçti**, EXIT 0 | `02-test.txt` (son satır: `+266: All tests passed!`) |
| test sayısı: önce → sonra | **172 → 266** (+94) | +76 `G13` · +7 `G14` · +11 `G15` — ilk koşumda 260 idi (5 F6 kırılması), düzeltildi |
| statik/widget mutant | **14/14 ISIRDI** | `06-MUTANT/M74…M87.txt` (14 dosya, 158.793 b) |
| cihaz mutantı | **CM1 ✅ · CM2 ✅ · CM3 ✅** (tavan 3 DOLDU) | `07-CIHAZ/` |
| `spec-kapi-kapsama.py` | **EXIT 0** (`KAPI 3` / `MUTANT 14`, borç yok) | §4 kriter 6 |

**`urun_kodu_satiri` (Cowork deftere bunu işleyecek — K55):**

> ## `urun_kodu_satiri = 197`

🔴 **Bu sayı ELLE YAZILMADI — aracın kendisi git'ten türetti.** Build commit'lendikten **sonra**
koşuldu:

```
python araclar\radar.py . --olc-urun-kodu 4fa3203
  urun yollari : ['src/', 'lib/', 'app/']   haric: ['test/', 'tests/', 'docs/', ...,'araclar/']
  +121  src/client/lib/sunum/gorev_satiri.dart
  +55   src/client/lib/sunum/senkron_rozeti.dart
  +21   src/client/lib/design/metinler.dart
  (7 dosya HARIC listesi geregi sayilmadi)
  urun_kodu_satiri = 197
  "Bu sayiyi deftere OLDUGU GIBI yaz. Elle degistirirsen R8 korlesir."
```

Elle yaptığım `git diff --numstat` sayımı (`+197 / −42`) bu sonuçla **birebir** tuttu.
**Aracın *"test/ hariç"* kuralı, benim *"yalnız `lib/` ÜRÜNdür"* okumamı doğruladı** — belirsizlik
varsayımla değil, **aracı koşarak** kapandı.

- **Kapı (test) kodu — `urun_kodu_satiri`'na DÂHİL DEĞİL, ayrıca raporlanır:** 3 YENİ dosya
  **27.173 b** (`g13` 9.248 · `g14` 8.524 · `g15` 9.401) + 4 mevcut test dosyası güncellendi.
- **Üretilmiş iskelet yok** (`flutter create` çağrılmadı); nitelik: **elle yazılmış ürün kodu**.

---

## 1. AÇILIŞ PROTOKOLÜ — MADDE MADDE

| adım | sonuç | ölçüm |
|---|---|---|
| `DURUM.md` + `CLAUDE.md` TAM okundu | ✅ | `PROJE_HAFIZA.md` ve `BORCLAR.md` **açılmadı** |
| `KANIT/A7/` üç dosya var mı | ✅ | `00-OLCUM-kor-kapi.txt` 2.332 b · `01-DENETIM.md` 12.457 b · `02-COZUM-OLCUM.txt` 3.734 b — **üçü de KORUNDU**, silinmedi/üzerine yazılmadı |
| `tek-kopya-kapisi.py .` | ✅ **YEŞİL** EXIT 0 | 10 tek-kopya dosya HEAD ile tutarlı |
| `belge-tavan-kapisi.py .` | ✅ **YEŞİL** EXIT 0 | `DURUM.md` 25.677/32.768 (pay +7.091) · `BORCLAR.md` 13.790/16.384 |
| `sayi-tazeligi.py .` | ✅ **TEMİZ** EXIT 0 | 2 `T6` muafiyet (`BD-6`, `DESIGN.md` K46 donduruldu) — sessiz değil |
| `oturum-sagligi.py --altin-kume` | ✅ **26/26** EXIT 0 | |
| `radar.py --altin-kume` | ✅ **18/18** EXIT 0 | |
| `radar.py .` | 🔴 **KIRMIZI** EXIT 2 — **BEKLENEN, yapısal** | `K83/DURDUR` kilidi yürürlükte; **dört şık ritüeli TEKRARLANMADI** (talimat gereği) |
| `R8` (ürün kodu durgunluğu) | 🔴 **ISIRDI** — *"son 2 oturumda (38, 39) tek satır ürün kodu girmedi"* | **Doğru cevap verildi: ÜRÜN KODU yazıldı.** Sayaç bu commit'le düşer (K55) |
| Oturum sağlığı (kendi transcript'imle) | ✅ **YEŞİL** | açılışta **125.697** → checkpoint **278.032 token MUTLAK** (eşik <550.000). 🔴 **Yüzde YAZILMADI** |

### 🔴 Açılışta ölçülen, BANA AİT OLMAYAN iki bulgu (deftere yazamadığım için buraya)

1. **`oturum-sagligi.py` `D1` SARI:** *"defter:28 `araclar/sayi-tazeligi.py` SON kaydı 2026‑07‑26
   tarihli ama dosya 2026‑07‑27'de yeniden yazılmış ⇒ o kaydın bayt beyanı yapısal olarak BAYAT."*
   `PROJE_RADAR.jsonl` satır 28 — **eşzamanlı ikinci yazıcı olduğu için (madde 1) DOKUNULMADI.**
2. **`design-token-kapisi.py` KIRMIZI** — §5'te ayrıntılı; **devralınmış** olduğu ölçüldü.

---

## 2. KAPILAR — YAZILDI ve KOŞULDU

### `G13` · KIRPMA KAPISI (`didExceedMaxLines`) — `test/g13_rozet_tasma_kapisi_test.dart` (9.248 b · `519A8200`)

**76 test, EXIT 0** (`05-KAPI/G13.txt`).

| ayak | ölçüm | sonuç |
|---|---|---|
| **A1** | `3 olcek × 3 genislik × 4 durum × 2 cakisma` = **72 kombinasyon**, her birinde `didExceedMaxLines == false` | ✅ **72/72** |
| **A1‑sayı** | kombinasyon sayısının **TAM 72** olduğu **testle** ölçülür (v3'ün "96"sı yanlıştı) | ✅ |
| **A2** | `senkronize` ⇒ ölçülecek `Text` **yok**; kapı susar ama *"ölçtüm"* **demez** (açık `isEmpty` beyanı + `metinIcin`/`tamMetinIcin` `null`) | ✅ |
| **A3** | **STATİK:** rozet `Text`'i `maxLines` **taşır** + `maxSatir` 1'den büyük ve **3** | ✅ |

🔴 **Hüküm YALNIZ `didExceedMaxLines`'tan geliyor.** `intrinsic`/`size`/`height` hata mesajında
**teşhis** olarak raporlanıyor, **hüküm vermiyor** — v4 kilidi birebir uygulandı, `G13_TOLERANS` **yok**.

### `G14` · DİKEY DÖNÜŞ — `test/g14_dikey_donus_kapisi_test.dart` (8.524 b · `3CEBF35F`)

**7 test, EXIT 0** (`05-KAPI/G14.txt`).

| ayak | ölçüm | sonuç |
|---|---|---|
| **A4** | **ÜÇ vaka** ⇒ DİKEY: `320dp/2.0×` (spec kanonik) · `320dp/1.0×` · `411dp/2.0×` | ✅ |
| **A5** | `800dp/1.0×/yerel` ⇒ `Column` **YOK** (yanlış‑pozitif kontrolü) | ✅ |
| **A6** | aynı girdi iki kez `pump` ⇒ aynı düzen **ve** aynı rozet boyutu (titreme yok) | ✅ |
| **A7** | `senkronize` ⇒ `320dp/2.0×`'te bile **YATAY** | ✅ |
| **A8** | **STATİK:** `lib/sunum`'daki her `TextPainter(` çağrısı `dispose()` edilir + **kör kapı kontrolü** (hiç çağrı bulunamazsa test ısırır) | ✅ |

🔴 **A4'ü spec'in TEK vakasından ÜÇ vakaya çıkardım — bu bir GEVŞETME değil SIKILAŞTIRMADIR ve
ölçülmüş bir gerekçesi var.** Spec'in tek kanonik vakası (`320dp/2.0×/gonderilmemis`) **iki mutanta
KÖRDÜR**:
- `M75` (`baslikAsgari = 0`): o vakada `64 + 343 = 407 > 320` ⇒ **hâlâ DİKEY**, mutant **ısırmazdı**.
- `M77` (`textScaler` verilmez): o vakada `64 + 96 + 185,5 = 345,5 > 320` ⇒ **hâlâ DİKEY**, ısırmazdı.

Eklenen iki vaka tam bu kaldıraçlardır: `320dp/1.0×` `baslikAsgari`'yi, `411dp/2.0×` `textScaler`'ı
**ısırtır**. Spec'in kanonik vakası **aynen duruyor**. Ölçülmüş sonuç: **M75 ve M77 ISIRDI** (§3).
*Kusur spec'in mutant tablosundaydı: mutant ile onu ısırtacak ayak aynı belgede eşleştirilmiş ama
aritmetiği yapılmamıştı — `01-DENETIM.md` §1.3'ün adlandırdığı sınıfın (**"çözümün yeterliliği
ölçülmedi"**) mutant tablosundaki hâli.*

### `G15` · BİLEŞİK SATIR + ÇİFT OKUMA — `test/g15_bilesik_satir_kapisi_test.dart` (9.401 b · `24EDE5C5`)

**11 test, EXIT 0** (`05-KAPI/G15.txt`).

| ayak | ölçüm | sonuç |
|---|---|---|
| **A9** | `cakisma=true + gonderilmemis`, `320dp`, `2.0×` ⇒ her iki rozet ağaçta + taban rozetin `Text`'i duruyor | ✅ |
| **A10** | `Checkbox` ve `CakismaRozeti` ≥ `MOlcu.dokunmaHedefi` (48dp) **+** `androidTapTargetGuideline` bağımsız koşar | ✅ |
| **A11** | **A11Y‑6:** 4 durumun **hepsinde** görünür `Text` var, boş değil **ve çizilen metin `metinIcin()` ile birebir** | ✅ 4/4 |
| **A12** | **A11Y‑7 regresyonu:** `kuyrukta → cevrimdisi` geçişinde duyuru **tam 1 kez**; aynı durumla tekrar `pump` ⇒ **hâlâ 1** | ✅ |
| **A13** | **ÇİFT OKUMA:** rozetin semantics alt ağacında **TEK etiket = TAM metin**; kısa metin ağaçta **YOK** | ✅ 4/4 |

---

## 3. MUTANTLAR — 14/14 ISIRDI (statik/widget ⇒ TAVANSIZ, K53/3)

Her mutant: **uygula → ilgili kapının ısırdığını ÖLÇ → GERİ AL → sha256 ile geri almayı DOĞRULA.**
Sürücü betiği geri alma başarısızlığında **derhal durur** (`exit 3`); hiçbir mutantta tetiklenmedi.

| # | mutasyon | ısıran kapı | EXIT | sonuç |
|---|---|---|---|---|
| **M74** | `LayoutBuilder` kaldırılır, düz `Row` | `G14/A4` | ≠0 | ✅ ISIRDI |
| **M75** | `baslikAsgari = 0` | `G14/A4` | ≠0 | ✅ ISIRDI |
| **M76** | `DIKEY` daima `true` | `G14/A5` | ≠0 | ✅ ISIRDI |
| **M77** | `TextPainter`'a `textScaler` verilmez | `G14/A4` | ≠0 | ✅ ISIRDI |
| **M77b** | `tamMetinIcin` yerine `build` içinde **kopya** eşleme, biri değiştirilir | `G15/A13` | ≠0 | ✅ ISIRDI |
| **M78** | Rozetin görünür `Text`'i kaldırılır | `G15/A11` | ≠0 | ✅ ISIRDI |
| **M79** | Dikey düzende `CakismaRozeti` düşürülür | `G15/A9` | ≠0 | ✅ ISIRDI |
| **M80** | `overflow: TextOverflow.ellipsis` kaldırılır | `a11y_statik_tasma_test` | ≠0 | ✅ ISIRDI |
| **M82** | `Checkbox` dikeyde `SizedBox(width: 24)` içine alınır | `G15/A10` | ≠0 | ✅ ISIRDI |
| **M83** | `TextPainter` `dispose()` satırı silinir | `G14/A8` | ≠0 | ✅ ISIRDI |
| **M84** | `maxLines` **kaldırılır** (v3'ün hâli) | `G13/A1` **+** `G13/A3` | ≠0 | ✅ ISIRDI |
| **M85** | `MAX_SATIR = 1` | `G13/A1` | ≠0 | ✅ ISIRDI |
| **M86** | Görünür dizge **tam metne** döner | `G13/A1` | ≠0 | ✅ ISIRDI |
| **M87** | `ExcludeSemantics` kaldırılır | `G15/A13` | ≠0 | ✅ ISIRDI |

**M81 YOK** — v4'te düştü (`G13_TOLERANS` kaldırıldığı için ısırtacak eşik yok). `spec-kapi-kapsama.py`
**14 mutant** ölçüyor ve **borç yok** diyor.

🔴 **M87'nin uygulanma biçimi BEYAN EDİLİYOR:** `ExcludeSemantics(` → `Semantics(` (annotasyonsuz
`Semantics` **düğüm üretmez**, dolayısıyla `Text`'in kendi semantics düğümü geri gelir ⇒ çift okuma).
Bu, "`ExcludeSemantics` kaldırılır" mutasyonunun **anlamsal olarak aynı**, farkı **tek kelimelik**
hâlidir; blok yeniden girintilenmeden uygulanabildiği için seçildi. `M87.txt`'de tam `git diff` var.

**Mutant kanıtları:** `06-MUTANT/M<n>.txt` — her dosyada ① mutasyon açıklaması ② **`git diff`**
③ kapı koşumu (`EXIT` + çıktının `sha256`'sı + kesit) ④ *"geri alma doğrulandı, sha256 mutasyon
öncesiyle AYNI"*.

---

## 4. KABUL KRİTERLERİ — MADDE MADDE

| # | kriter | sonuç | ölçüm |
|---|---|---|---|
| **1** | `flutter analyze --fatal-infos` ⇒ **0** | ✅ **PASS** | `No issues found!` · EXIT 0 · `01-analyze.txt` |
| **2** | `flutter test` ⇒ mevcut + `G13/G14/G15` yeşil, **toplam ÇIKTIDAN** | ✅ **PASS** | **`+266: All tests passed!`** · EXIT 0 · `02-test.txt`. F6 kırılması **gerçekleşti ve öngörüldüğü gibi düzeltildi** (§6.1) |
| **3** | **Üç dosya EŞZAMANLI**: `metinler.dart` · `metinler-kilit.json` · `a11y_kapisi_test.dart` gömülü harita | ✅ **PASS** (biçim sapması **beyan edildi**, §6.2) | üçü de aynı commit'te; yeni test *"rozet kisa gorunur (3) birebir"* birini unutmayı **ısırtır** |
| **4** | `M74`–`M87` tek tek, ısırdığı ölçülür, **geri alınır** ⇒ `06-MUTANT/M<n>.txt` | ✅ **PASS** | **14/14 ISIRDI**, 14 dosya, geri almalar **sha256 ile doğrulandı** |
| **5** | `CM1`–`CM3` ⇒ `07-CIHAZ/`; `font_scale` geri alındığı **ölçülür** | ✅ **PASS** | 4 PNG + uiautomator dump + `CM-OLCUM.txt`; `font_scale ⇒ 1.0` **ve** `density ⇒ override KALKTI` ölçüldü |
| **6** | `spec-kapi-kapsama.py <spec yolu>` ⇒ **EXIT 0** (dizin verilmez) | ✅ **PASS** | `KAPI (3): G13, G14, G15` · `MUTANT(14)` · *"BULGU YOK"* · EXIT 0 |
| **7** | `design-token-kapisi.py .` ⇒ `D0`–`D6` yeşil, **yeni token yok** (K46) | 🟡 **ŞARTLI PASS** | **Yeni token EKLENMEDİ** (`token 32 (MUST 24 / NICE 8)` — değişmedi) ama kapı **EXIT 1**: iki `D2` bulgusu **devralınmış**, A‑7 dışı (§5) |
| **8** | `00-OLCUM-kor-kapi.txt` ve `01-DENETIM.md` **korunur** | ✅ **PASS** | ikisi de **bayt bayt duruyor**; `02-COZUM-OLCUM.txt` da korundu |
| **9** | `DESIGN.md`'ye **tek bayt yazılmaz** (K46); yazılamıyorsa A‑7 *"kapandı"* **denmez** | ✅ **PASS** | `DESIGN.md` **18.075 b · `3780ACA4`** — donmuş kimliğiyle birebir, **dokunulmadı**. ⇒ **A‑7 "KAPANDI" DENMİYOR: "ÖLÇÜLDÜ / KAPANMADI"** olarak `BORCLAR.md`'ye girmelidir (Cowork'ün işi) |

---

## 5. 🔴 KRİTER 7 — KIRMIZI, ama A‑7'nin ÜRETTİĞİ BİR KUSUR DEĞİL (ölçüldü)

`python araclar\design-token-kapisi.py .` ⇒ **EXIT 1**, iki bulgu:

```
[D2] src\client\test\g12_sinyal_kapisi_test.dart:157
      ham tasarim literali (Duration): 'Duration(milliseconds: 1'
[D2] src\client\test\g12_sinyal_kapisi_test.dart:357
      ham tasarim literali (Duration): 'Duration(milliseconds: 1'
```

**DEVRALINMIŞ OLDUĞU ÖLÇÜLDÜ, varsayılmadı:**
- `git --no-optional-locks diff --stat HEAD -- src/client/test/g12_sinyal_kapisi_test.dart` ⇒ **BOŞ**
  (dosya HEAD ile **bayt‑özdeş**; bu el ona **dokunmadı**).
- `git show HEAD:...` satır 157 ⇒ `await Future<void>.delayed(const Duration(milliseconds: 1400));`
  satır 357 ⇒ `... Duration(milliseconds: 1500));`
- Kapının bulduğu **tüm** bulgular bu iki satırdır ⇒ A‑7'nin 8 değişen + 3 yeni dosyası **hiç `D2`
  üretmiyor**; yani kapı **HEAD'de de kırmızıydı**.

🔴 **Bu, `DURUM.md` §3'ün *"kapılar `G1`–`G12` YEŞİL"* iddiasıyla ÇELİŞİYOR** — bu projede
adlandırılmış **bayat‑iddia / çağrılmayan‑kapı** sınıfı. Sınıfın adı ölçülmüştür, faili bu oturum
**değildir**.

**NEDEN DÜZELTMEDİM (bilinçli kapsam kararı, gizlenmiyor):** düzeltme iki satıra
`// [DESIGN-LITERAL: gerekce]` **muafiyeti** yazmaktır — yani *"1400/1500 ms bir tasarım değeri değil,
test zamanlaması"* diye **hüküm vermek**. Bu (a) A‑7 kapsamı dışıdır, (b) **başka bir elin kapı
dosyasına muafiyet yazmaktır** ve muafiyet bu projede gerekçesiyle **Onur tarafından onaylanır**,
(c) K44‑a/K34‑f ruhuna aykırıdır. **Ölçtüm, adlandırdım, düzeltmedim.** Onur'un kararı §7'de.

---

## 6. BEYAN EDİLEN SAPMALAR ve ÖLÇÜLMÜŞ BULGULAR

### 6.1 F6 kırılması — ÖNGÖRÜLDÜ, GERÇEKLEŞTİ, DÜZELTİLDİ (kusur değil, kapının çalışma kanıtı)

İlk tam koşum **`+260 -5`** verdi. Kırılan **tam olarak 5 test**, hepsi `find.text(<tam F6 dizgesi>)`:

| dosya | ne oldu | nasıl düzeltildi |
|---|---|---|
| `a11y_kapisi_test.dart:314` | `yalnizcaBuCihazda` bulunamadı | `rozetKisaYerel` arandı **+** `tamMetinIcin(...) == yalnizcaBuCihazda` iddiası eklendi |
| `g10_rozet_kapsami_test.dart` `AYAK6` | aynı | aynı |
| `g10_...` `AYAK5` (negatif iddia) | **geçiyordu** | 🔴 yine de **güçlendirildi**: artık **hem kısa hem tam** dizgenin yokluğu aranıyor — yalnız birini aramak diğerinin sızmasına sessizce izin verirdi |
| `g11_rozet_turetme_kapisi_test.dart:436` | `gonderilmemisDegisiklik` bulunamadı | `rozetKisaGonderilmedi` + tam metin iddiası |
| `sunum_bilesenleri_test.dart:80,118` | `yalnizcaBuCihazda` / `cevrimdisiKaydedildi` | kısa dizge + tam metin iddiası |

🔴 **`Semantics` etiketini sınayan hiçbir teste DOKUNULMADI** (spec kriter 2). Düzeltmeler testleri
**zayıflatmadı**: her birinde kısa metnin yanına **tam metnin korunduğu** iddiası **eklendi**.

### 6.2 🔴 SPEC'TEN BEYAN EDİLMİŞ BİÇİM SAPMASI — `_fixtureGorunur` yerine `_fixtureRozetKisa`

Spec kriter 3 *"`a11y_kapisi_test.dart`'ın gömülü **`_fixtureGorunur`** haritası"* der. Üç yeni kısa
dizgeyi o haritaya **katmadım**; aynı dosyada **`_fixtureRozetKisa`** adlı ayrı bir harita ve ayrı bir
test açtım. `metinler-kilit.json`'da da ayrı `"rozetKisaGorunur"` grubu var.

**Ölçülmüş gerekçe:** `GOREV-slice-3b-istemci-iskeleti.md` (**K59 kilidi**, `44.560 b · F0C3A75A`) satır
227 *"`metinler.dart` ↔ `fixture/metinler-kilit.json` **13 dizge** birebir"* der ve o belge
**KİLİTLİDİR** — üç dizgeyi `gorunur` grubuna katmak o kilitli belgenin **sayı iddiasını BAYAT
bırakırdı** (bu projede ölçülmüş `bayat-iddia` sınıfı). **GOREV‑R10**, `gonderilmemisDegisiklik` için
**tam aynı deseni** (ayrı EK grup, *"F6 kilidini bozmaz"*) kurmuştu; onu izledim.

**Spec'in ASIL şartı olan *"üç dosya EŞZAMANLI"* TAM sağlanıyor** ve unutma **ısırılıyor**: yeni test
`Metinler.rozetKisa*` ↔ `_fixtureRozetKisa` karşılaştırır; JSON'daki grup her ikisinin aynasıdır.
**Onur bunu spec'in lafzına döndürmek isterse tek işlem:** üç girdiyi `_fixtureGorunur` + JSON
`gorunur`'a taşımak ve **`13` sayı iddiasını taşıyan belgeleri güncellemek** (kilitli belge ⇒ Onur'un
kilidi gerekir). Bu yüzden **karar Onur'a bırakıldı**, tek taraflı yapılmadı.

### 6.3 `MAX_SATIR = 3`'ün emniyet payı CİHAZDA HAK ETTİĞİNİ KANITLADI

Widget testi (`flutter_test` fontu) bileşik satırda 2 satır öngördü; **gerçek emülatörde de 2 satır**
oluştu ve **tamamı görünür** (`CM1b` PNG). `M85` (`MAX_SATIR=1`) bu koşulda kırpardı. **Spec §8/S3'ün
belirsizliği ölçüldü ve pay yeterli çıktı.**

### 6.4 Widget testi cihazı TAM ÖNGÖRMÜYOR — ölçüldü, gizlenmiyor

`320dp / 1.0× / gonderilmemis` kombinasyonu **test fontuyla DİKEY** hesaplanır
(`64+96+185,5 = 345,5 > 320`) ama **cihazda YATAY** çıktı ⇒ cihazın Roboto'su `"Gönderilmedi"`yi test
fontundan **daha dar** ölçüyor. **Her iki düzen de kırpmasızdır** (CM2 PNG'sinde metin tam görünüyor)
⇒ hüküm değişmez. Ama *"widget testi cihazı öngörür"* iddiası bu noktada **yanlış olurdu ve
kurulmuyor** — spec §8/S3'ün somut hâli.

### 6.5 🔴 KAPSAM DIŞI ama ÖLÇÜLMÜŞ BULGU — çakışma çözüm sayfası 2.0×'te KIRPILIYOR

`CM3`'te açılan `_CakismaCozumSayfasi` (`cakisma_rozeti.dart`) gövde metni **kırpıldı**:
*"Bu görev başka bir ci…"*. **A‑7'nin düzelttiği kusurun AYNI SINIFI, BAŞKA bir bileşende**
(`maxLines` **yok** + `ellipsis` **var** ⇒ tek satıra iner — spec §1.3'ün mekanizması).

- **Spec bu bileşeni ne DAHİL ne HARİÇ etti**; `G13` kapsamı **rozet alt ağacıdır** (§8/S1, S8).
- **Bilgi kaybı ekran okuyucuda YOK:** `content-desc` tam metni taşıyor (uiautomator ile ölçüldü).
  Kayıp **yalnız görseldir**.
- **Düzeltmedim** — kapsam dışı iş üretmek yerine **ölçüp beyan ettim**. Ayrıca bu sayfa bir **yer
  tutucudur** (K42‑d adım 3 onu değiştirecek). ⇒ **`BORCLAR.md`'ye girmesi gereken yeni bir kalem**
  (Cowork'ün işi; ben hafıza dosyalarına yazmıyorum).

### 6.6 Kelime ortasından bölünme (kozmetik, kusur değil)

2.0×'te bileşik satırda `"Gönderilmed" / "i"` — Flexible'a sığmayan **tek kelime** karakter düzeyinde
bölünüyor (aynı davranış `02-COZUM-OLCUM.txt` varyant E'de de ölçülmüştü). **Kırpma YOK, bilgi kaybı
YOK.** Çözümü bir **copy/tasarım kararıdır** ve spec §8/S9 gereği **Onur'un kilidini ister** — bu el
dizgeleri kendi başına değiştirmedi.

---

## 7. 🔴 ONUR İÇİN TEK KARAR (tek dokunuşla cevaplanabilir)

**Ölçülen sayı:** `design-token-kapisi.py` **EXIT 1**, **2 bulgu**, ikisi de
`src/client/test/g12_sinyal_kapisi_test.dart:157` ve `:357`, ikisi de **HEAD ile bayt‑özdeş** bir
dosyada ⇒ **A‑7 bu bulguları üretmedi** (§5). A‑7'nin kendi 11 dosyası **0 `D2`** üretiyor ve **yeni
token eklenmedi** (`token 32` değişmedi).

| şık | ne olur | bedel |
|---|---|---|
| **(A)** *(bu elin önerisi)* **A‑7'yi kriter 7 ŞARTLI PASS ile kabul et**, iki `D2`'yi `BORCLAR.md`'ye **devralınmış kalem** olarak yaz | A‑7 kapanır; `R8` sayacı düşer; borç **görünür** kalır | Kapı bir sonraki açılışta **yine kırmızı** yanar; `DURUM.md` §3'ün *"G1–G12 YEŞİL"* satırı **düzeltilmeli** |
| **(B)** İki satıra `// [DESIGN-LITERAL: test zamanlamasi, tasarim degeri degil]` muafiyeti **şimdi yazılsın** | Kapı yeşile döner, kriter 7 **tam PASS** | Başka bir elin kapı dosyasına **muafiyet hükmü** yazılır; muafiyet gerekçesi denetlenmeden girer |
| **(C)** Ayrı bir düzeltme dilimi açılsın (`Duration` token'ı ya da muafiyet kararı ölçülerek) | En temiz | `R8` yeni tur yasağı yürürlükte; **yeni tur açmak K53/4 ile çatışır** |

**Ek bilgi (karar gerektirmez, yalnız kayda):** §6.2'nin biçim sapması ve §6.5'in kapsam dışı bulgusu
Onur'un onayına açıktır ama **A‑7'yi bloke etmiyor**.

---

## 8. NE YAPILMADI / [DOĞRULANMADI]

- **Web ayağı `[DOĞRULANMADI]`** — `flutter test --platform chrome` bu ortamda sonuç üretmiyor
  (DURUM.md §7: iki ölçüm, 7 dk ve 9,8 dk). **DENENMEDİ, süre harcanmadı.** `G13`/`G14` `dart:io`
  kullandığı için `@TestOn('vm')` taşıyor; `G15` `dart:io` **içermiyor** (web'de koşabilir) ama
  **koşulmadı**.
- **iOS** — Mac yok, CI‑only. **RTL** — spec §2 hariç tuttu, sınanmadı.
- **`Checkbox`'ın `textScaler` davranışı** — spec §8/S6 `[DOĞRULANMADI]` diyordu; `CM3`'te
  `CakismaRozeti` için **48,0 dp ölçüldü** (162 px / 3.375) ama `Checkbox`'ın **kendi** ölçek davranışı
  hâlâ **doğrudan ölçülmedi**; `G15/A10` yalnız *"≥ 48dp"* der. **Kısmen kapandı, tam değil.**
- **Ara ekran genişlikleri** (`320`/`360`/`411` dışı) — spec §8/S4, örneklem; **ölçülmedi**.
- **`docker` + backend** — spec §3/3 gereği bu dilimde **gerekmedi**, kaldırılmadı, *"çalışıyor"*
  **denmiyor**. K61'in `ASPNETCORE_ENVIRONMENT` tuzağı bu dilimde **hiç devreye girmedi**.
- **Hafıza dosyalarına YAZILMADI** (`PROJE_HAFIZA.md` · `PROJE_RADAR.jsonl` · `DURUM.md` ·
  `BORCLAR.md`) — eşzamanlı ikinci yazıcı var (madde 1). **Bu belge devir notudur.**
- **`git add -A` KULLANILMADI** (K55). İzlenmeyen `_debug_join_test.dart` ·
  `_tmp_sqlite_version_test.dart` · `_SILINECEKLER\*` **görüldü, dokunulmadı, commit'lenmedi.**
- **PUSH YAPILMADI** — Onur'un işi.
- **Ölçüm betikleri** (`a7_mutant.py`, `a7_kanit.py`) **repoya YAZILMADI** — bu oturumun
  scratchpad'inde; tek seferlik build koşum araçlarıdır, `araclar\` betiği değildir. Sürücünün yaptığı
  her şey `06-MUTANT/M<n>.txt`'lerdeki `git diff` + `sha256` + `EXIT` üçlüsüyle **yeniden
  üretilebilir**.

---

## 9. DOSYA KİMLİKLERİ (son yazımdan SONRA ölçüldü — `dosya-kimlik.py`)

| dosya | bayt | sha8 |
|---|---|---|
| `src/client/lib/sunum/senkron_rozeti.dart` | **8.586** | **`D75B5DDB`** |
| `src/client/lib/sunum/gorev_satiri.dart` | **5.343** | **`E9DBB328`** |
| `src/client/lib/design/metinler.dart` | **3.148** | **`8A343C01`** |
| `araclar/fixture/metinler-kilit.json` | **1.257** | **`8815AE6B`** |
| `src/client/test/g13_rozet_tasma_kapisi_test.dart` | **9.248** | **`519A8200`** |
| `src/client/test/g14_dikey_donus_kapisi_test.dart` | **8.524** | **`3CEBF35F`** |
| `src/client/test/g15_bilesik_satir_kapisi_test.dart` | **9.401** | **`24EDE5C5`** |
| `DESIGN.md` *(DOKUNULMADI — donmuş kimlik teyidi)* | **18.075** | **`3780ACA4`** |

`U+FFFD 0` · `CRLF 0` (hepsinde) · `HUKUM: TEMIZ`.

> 🔴 **Bu belgenin kendi kimliği burada YAZILMAZ** — bir kayıt kendini içeren şeyin kimliğini beyan
> edemez (K82‑b). Cowork onu **ölçer**.
