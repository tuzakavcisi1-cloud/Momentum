# HUKUM.md — oturum 40, K86 hafıza yazım işleme kaydı (Claude Code)

Bu dosya `git add` listesine **dahil edilmedi** (talimat §5'te commit listesinde yok) — geçici
işleme kaydıdır, commit'lenmez. Metinler Cowork'ün K86 talimatındandır; ben yalnız **işledim**,
kendi değerlendirmemi eklemedim. Şerhler aşağıda açıkça işaretli.

---

## 1. İKİ SORUNUN CEVABI (ölçülerek, tahminle değil)

### (a) "önce 172 → sonra 266" — +1 NEREDEN?

**Ölçüm:** `git --no-optional-locks log --oneline 218e910..4fa3203 -- src/client/test/` ⇒ **BOŞ**
(K81/session-37 checkpoint'i ile A-7 spec yazımı arasında test dizini **hiç değişmedi**). Yani
`171/171` (K81, `DURUM.md` eski §3) **bayat DEĞİL** — o anın doğru ölçümüydü.

`172`, `KANIT/A7/09-HUKUM.md` satır 34'te build'in **KENDİ içindeki** bir ara sayımdır. Ölçüm:

```
git --no-optional-locks diff 4fa3203 d8dc60d -- src/client/test/a11y_kapisi_test.dart | grep -c '^+.*test('  ⇒ 1
git --no-optional-locks diff 4fa3203 d8dc60d -- src/client/test/a11y_kapisi_test.dart | grep -c '^-.*test('  ⇒ 0
git --no-optional-locks diff 4fa3203 d8dc60d -- src/client/test/g10_rozet_kapsami_test.dart        | grep -c '^+.*test('  ⇒ 0
git --no-optional-locks diff 4fa3203 d8dc60d -- src/client/test/g11_rozet_turetme_kapisi_test.dart | grep -c '^+.*test('  ⇒ 0
git --no-optional-locks diff 4fa3203 d8dc60d -- src/client/test/sunum_bilesenleri_test.dart        | grep -c '^+.*test('  ⇒ 0
```

Yani: A-7 build'i F6-kırılması düzeltmesi sırasında (`09-HUKUM.md` §6.1) `a11y_kapisi_test.dart`'a
**net +1 yeni `test(`** ekledi (kriter 3'ün *"rozet kisa gorunur (3) birebir"* testi); diğer üç
dosyada mevcut testler **güçlendirildi**, yeni `test(` **açılmadı**. **171 + 1 = 172.** Sonra üç
yeni dosya (`G13` +76 · `G14` +7 · `G15` +11 = **+94**) eklendi ⇒ **172 + 94 = 266**.

**Sonuç:** ne 171 bayattı ne de dışarıdan bir dosya eklendi — 172, A‑7'nin **kendi build
commit'inin** iki farklı zaman kesitidir (G13/G14/G15'ten ÖNCE vs SONRA). Bir sayı iddiası
kusuru **değil**; `PROJE_HAFIZA.md` K86 §10'a bu haliyle yazıldı.

### (b) M75/M77 kaldıracı — hangi vaka eklendi, spec'e yazılması gerekiyor mu?

**Kaynak:** `src/client/test/g14_dikey_donus_kapisi_test.dart` satır 74–90 (`vakalar` listesi +
yorum bloğu).

Spec'in (`GOREV-A7-rozet-tasma.md` v4) TEK kanonik vakası **`320dp / 2.0× / gonderilmemis`** idi
ve bu vaka hem `M75` (`baslikAsgari=0`) hem `M77` (`textScaler` verilmez) mutantlarına **KÖRDÜ**:
o vakada ikisi de hâlâ `>320` çıkıp DİKEY kalıyordu (mutant tetiklenmiyordu).

Claude Code **iki YENİ vaka** ekledi (spec'in vakasını **silmeden**, üçe çıkararak):

| vaka | kaldıraç | neden bu vaka M'yi ısırtıyor |
|---|---|---|
| `320dp / 1.0× / gonderilmemis` | **M75** (`baslikAsgari=0`) | `baslikAsgari` VARKEN 64+96+185,5=345,5>320 ⇒ DİKEY; `baslikAsgari=0` OLSA 64+185,5=249,5<320 ⇒ YATAY — mutant burada **fark yaratır**. Spec'in kanonik vakasında (320/2.0×) `baslikAsgari=0` bile 64+343=407>320 ⇒ hâlâ DİKEY, mutant **fark yaratmaz** (kör). |
| `411dp / 2.0× / gonderilmemis` | **M77** (`textScaler` verilmez) | `textScaler` VARKEN 64+96+343=503>411 ⇒ DİKEY; verilmese 64+96+185,5=345,5<411 ⇒ YATAY — mutant burada fark yaratır. Spec'in kanonik vakasında (320/2.0×) `textScaler` verilmese bile 345,5>320 ⇒ hâlâ DİKEY (kör). |

Bu bir **gevşetme değil, sıkılaştırmadır** — spec'in tek vakası aynen duruyor, üstüne iki tane
daha eklendi. **Spec'in §5/§6'sına (kapı/mutant tabloları) bu iki vaka yazılmadı** — v4 hâlâ tek
vaka taşıyor, dosya kimliği (`21.126 b · 9DFC21A5`) build sırasında **değişmedi**. v5 açılıp
açılmayacağı, `BORCLAR.md`'ye eklenen *"spec mutant tablosu aritmetik yapmamıştı"* kalemiyle
birlikte **Onur'un kararına** bırakıldı — spec'i ben (Claude Code) tek taraflı değiştirmedim.

---

## 2. ŞERHLER — talimatla katılmadığım/tutarsız bulduğum yerler (UYGULANDI, kendi başıma düzeltilmedi)

1. **BORCLAR.md'de "S6 kalemi" bulunamadı.** Talimat 3.2 *"GÜNCELLE: S6 kalemi → ..."* diyordu
   ama mevcut `BORCLAR.md`'de bu etiketle (ya da açıkça eşleşen bir içerikle) bir madde **yoktu**
   — arandı (`grep -n "S6"` ⇒ boş, `grep` dokunma-hedefi/48dp/Checkbox ⇒ boş). **Güncelleme
   değil, YENİ madde olarak eklendi** ("[DOĞRULANMADI]" bölümüne), metnin içeriği aynen
   talimattaki gibi yazıldı.
2. **`uretilen` alanı çelişkili.** Talimat 3.4 hem `"uretilen: 2"` yaz diyor hem de *"senin
   ÜRETMEDİĞİN iki kalemi uretilen'e KOYMADIM"* diyor — bu iki cümle birbiriyle **çelişiyor**
   (2 yaz + 2'yi koyma aynı anda olamaz). Literal `2` değeri **elle değiştirilmeden** yazıldı
   (talimatın açık sayısal değeri); çelişki `PROJE_RADAR.jsonl` kaydının `not` alanına
   **açıkça** işlendi, sessizce çözülmedi. A-7'nin ölçülen kendi ürettiği yeni kusur sayısı
   fiilen **0**'dır (11 dosyası 0 `D2` üretti) — bu HUKUM.md'de ayrıca kayıtlı.
3. **`belge-tavan-kapisi.py` T2 SARI verdi** (`BORCLAR.md` 15.823/16.384 b, pay 561 b < eşik
   819 b). **T1 KIRMIZI değil** ⇒ talimat gereği durup Onur'a dönmedim, devam ettim; ama tavanı
   kendim büyütmedim/kalem budamadım (K40) — Onur'un bir sonraki checkpoint'ten önce budama
   kararı vermesi gerekiyor.
4. **`oturum-sagligi.py .` iki `D1` SARI verdi** (`CLAUDE.md` ve `araclar/sayi-tazeligi.py`
   defter kayıtları bayat) — bu ikisi **bu oturumdan ÖNCE** de bayattı (defterdeki tarihler
   2026-07-26/29, dosyalar daha sonra yeniden yazılmıştı); bu oturumun ürettiği bir kusur
   değil, mevcut bir SARI'nın yeniden ölçülmesi.
5. **`oturum-sagligi.py` token/S4 ayağı `OLCULMEDI` döndü** — K21 kapsam maddesi (bu oturumda
   `CLAUDE.md`'ye yazıldı, madde 3.1) gereği bu Claude Code oturumu için **beklenen ve
   normaldir**, kusur değildir.

---

## 3. ARAÇ ÇIKIŞ KODLARI (sırayla koşuldu)

| araç | hüküm | EXIT |
|---|---|---|
| `hafiza-dizin.py .` | 93 checkpoint indekslendi | 0 |
| `belge-tavan-kapisi.py .` | SARI (T2, `BORCLAR.md` dar pay) | 0 |
| `sayi-tazeligi.py .` | TEMİZ (2 beyanlı T6 muafiyeti, BD-6) | 0 |
| `tek-kopya-kapisi.py .` | YEŞİL | 0 |
| `oturum-sagligi.py --altin-kume` | 26/26 GEÇTİ | 0 |
| `oturum-sagligi.py .` | KANONIK+D1: SARI · OTURUM SAĞLIĞI: ÖLÇÜLMEDİ (K21 kapsamı gereği beklenen) | 1 |
| `radar.py --altin-kume` | 18/18 GEÇTİ | 0 |
| `radar.py .` | KIRMIZI — **yapısal**, aynı iki park edilmiş artefakt (`docs/ADR/0003`, `GOREV-slice-3b-spec`, K83/DURDUR); dört-şık ritüeli tekrarlanmadı (talimat gereği) | 2 |
| `dosya-kimlik.py DURUM.md CLAUDE.md BORCLAR.md PROJE_RADAR.jsonl` | TEMİZ (0 FFFD, 0 CRLF) | 0 |

**Not:** `radar.py .`'nin KIRMIZI'sı bu oturumun ürettiği bir kusur değildir — K83'te Onur'un
kilitlediği yapısal/park durumun aynı ölçümüdür (`docs/ADR/0003` tur 9, `GOREV-slice-3b-spec`
tur 7, ikisi de değişmedi). `R8` (ürün kodu durgunluğu) bu turda **sessizdi** çünkü son oturumun
(40) `urun_kodu_satiri` alanı **197** (sıfır değil).
---
## COWORK SERHI -- oturum 40 (30 Tem 2026): K26 DOGRULAMA + ONUR KARARLARI
(Bu bolumu COWORK ekledi; Code'un yukaridaki isleme kaydina ektir. Onur dort karari Cowork'e devretti.)
### A-7 BUILD -- K26 BAGIMSIZ DOGRULANDI (Cowork olctu, Code'un beyanina guvenmeden)
- flutter analyze --fatal-infos: 0 issue, EXIT 0 (YENIDEN kosuldu).
- flutter test: 266/266, EXIT 0 (YENIDEN kosuldu).
- G13/G14/G15 dosya-basi kosum: 76/7/11 = 94; 172+94 = 266 (olculdu).
- spec-kapi-kapsama.py: EXIT 0 (KAPI 3 / MUTANT 14).
- 14/14 mutant: hepsi EXIT 1 / ISIRDI / REVERT-OK; iki on-mutasyon sha
  (e9dbb328 gorev_satiri, d75b5ddb senkron_rozeti) CANLI dosyalarla BIREBIR.
  M85 BAGIMSIZ yeniden kosuldu: temiz(D75B5DDB) -> maxSatir=1 -> ISIRDI (EXIT1,
  +37 -39) -> geri alma -> BAYT-OZDES (D75B5DDB).
- Cihaz: uiautomator content-desc TEK-OKUMA dogrulandi (kisa dizge 0 kez text=,
  tam etiket 1'er kez content-desc=). PNG'ler: rozet kirpmasiz, Turkce saglam,
  beyan edilen kozmetik hata (kelime-ortasi bolunme) gercek ve gorunur.
- 09-HUKUM.md 9 kriter: 8 PASS + 1 SARTLI (kriter 7, devralinmis D2).
  ASIRI-IDDIA BULUNMADI; hukum kendi kapsam-disi/kozmetik hatalarini BEYAN ediyor.
### KARAR 1 -- _fixtureRozetKisa: SIK (a) ONAYLANDI (Onur devretti -> Cowork onerisi)
Gerekce: uc kisa GORUNUR dizge, _fixtureGorunur'un 13 TAM dizgesinden SEMANTIK OLARAK
FARKLI bir kumedir (gorunen kisa metin != ekran-okuyucu tam metni; kod da metinIcin/
tamMetinIcin ile bu ayrimi yapiyor). Ayri grup mimariyle TUTARLI. Sik (b) [lafza donus]
kilitli slice-3b spec'ini (K59, F0C3A75A) "13->16" icin degistirmeyi gerektirir -> donmus
kimligi bozar, Onur'un AYRI kilidini ister; ustelik spec'in KORUDUGU sey (uc-dosya
eszamanliligi + unutma) zaten yeni testle ("rozet kisa gorunur (3) birebir") MEKANIK
saglaniyor. (a) islevsel kayip getirmez. Kod zaten (a); degisiklik GEREKMEZ. (b) TEK
TARAFLI YAPILMADI (Onur'un kilidini ister).

### KARAR 2 -- SAYI CELISKISI: uretilen=2 DOGRUDUR, KALIYOR + serh
radar.py olcumu: uretilen = o turda artefaktin YUZEYE CIKARDIGI yeni kusur sayisi; R3
(churn) ve D5'i besler. D5: "surekli 0 diyen defter ISIRIR" -> o tur gercekten yeni kusur
ciktiysa 0 yazmak DURUST DEGILDIR. Uc sayi FARKLI seyleri olcer (kategori hatasi, gercek
celiski degil):
  - uretilen=2 = bu turda yuzeye cikan 2 MAJOR yeni kusur sinifi (kor-mutant [spec M75/
    M77'ye kordu] + cagrilmayan-kapi); bulgu.major=2 ile TUTARLI. Devralinmis iki D2'yi
    ICERMEZ (Code dogru disladi; "koymadim" ifadesinin dogru okumasi budur).
  - 0 = A-7'nin KENDI KODUNUN design-token D2 sayisi (11 dosya, AYRI metrik) -- dogru ama
    uretilen'e ait degil.
  - 6 = BORCLAR.md'ye eklenen madde sayisi (belge granulerligi, AYRI metrik).
KARAR: PROJE_RADAR.jsonl'daki uretilen=2 DEGISMEZ (durust deger; 0'a cekmek D5'i tetikler
ve yanlis olurdu). Satirin not alanindaki "celiski cozulmedi" ibaresi BU SERHLE cozuldu
(append-only ileri-atif). Defter dogru; deger degisikligi gereksiz.

### KARAR 3 -- BAYAT DIZIN: KOK NEDEN OLCULDU, YENIDEN KOSUM FAYDASIZ
hafiza-dizin.py BASLIK regex'i (satir 36) yalniz "## CHECKPOINT/DEVIR" basliklarini yakalar;
K80, K81, K83, K83-DUZELTME, K84, K85, K86 "## K<n> --" bicimindedir ve regex bunlari GORMEZ
(olculdu: yedi baslik False). Kopya uzerinde yeniden kosuldu -> cikti BAYT-OZDES (sha
DADC42AF degismedi) => yeniden kosum bu checkpoint'leri indekse EKLEMEZ. Bu bir KOR ARAC
ornegidir: "93 indekslendi, EXIT 0" derken checkpoint'leri SESSIZCE dusurur. Onarim ONUR'DA:
(a) regex'i "## K<n>" icin duzelt (K34-f AYRI EL + bekleyen K60 io.open hatasiyla birlikte),
YA DA (b) basliklari "## CHECKPOINT" bicimine normalize et (append-only gerilimi). Cowork tek
tarafli YAPMADI.

### KALAN ONUR KARARLARI
DIZIN onarim yolu (a/b) - BORCLAR.md budama (belge-tavan T2 SARI, 561 b pay) - kriter-7 iki
D2 onarimi (K34-f) - bu oturumun kalici PROJE_HAFIZA checkpoint'i (yedekli yazim, CHECKPOINT
bicimli baslikla ki DIZIN gorebilsin).
