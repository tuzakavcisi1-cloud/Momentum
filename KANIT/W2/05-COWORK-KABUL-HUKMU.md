# W2 — COWORK'ÜN BAĞIMSIZ KABUL KOŞUMU (oturum 59, 5 Ağu 2026, 22:0x–23:xx TSİ)

> `K26` — **üreten ≠ denetleyen.** Bu hüküm Claude Code'un `KANIT/W2/02…04` dosyaları
> **okunarak** değil, zincir **baştan koşularak** verildi. Code'un *"koştu, geçti"* beyanı
> kanıt sayılmadı. Cowork'ün kendi betikleri: `_o59_cowork_mutant_ornegi.py` (M215) ve
> `_o59_cowork_mutant_ornegi2.py` (M200) — **Code'un `_mutant_kosucu.py`'si KULLANILMADI.**
> Denetlenen commit'ler: **`57cc8d1`** (T1–T10) + **`95d2c00`** (mutant koşumu + ADR 0004).

## 1. ON İKİ KRİTER — COWORK'ÜN KENDİ ÖLÇÜMÜ

| # | kriter | Cowork'ün ölçümü |
|---|---|---|
| 1 | `flutter analyze --fatal-infos` | ✅ **EXIT 0** — *"No issues found! (ran in 78.9s)"* |
| 2 | `flutter test` | ✅ **EXIT 0** — *"All tests passed!"*, **539/539**. Taban `522` (o57'de ölçülmüştü) ⇒ **+17 test**; sayı **kopyalanmadı, ölçüldü** |
| 3 | `spec-kapi-kapsama.py <spec>` | ✅ **EXIT 0** — BULGU YOK |
| 4 | 17 mutant + `MW20` | 🟡 **13/17 TAM EŞİTLİK · 4/17 AŞIRI-YAKALAMA** — aşağıda §2 |
| 5 | koşum sonrası `git status --porcelain` | ✅ **Cowork'ün KENDİ iki mutant koşumundan sonra da** `veritabani.dart` ve `depolama_durumu.dart` **görünmüyor**; ağaçta yalnız 5 bilinen `verify.ps1` artefaktı + Cowork'ün 2 yeni kanıt betiği |
| 6 | `radar.py . --olc-urun-kodu a474463` | ✅ **`urun_kodu_satiri = 249`** — **249'un tamamı `lib/` altında ELLE yazılmış ürün kodudur** (`depolama_seridi` 96 · `depolama_durumu` 74 · `main` 31 · `veritabani` 23 · `gorev_listesi_ekrani` 16 · `metinler` 9). 🟢 `B-W1-3`'ün satıcı-varlığı kusuru **bu turda tetiklenmedi**: indirilen tek bayt yok |
| 7 | dört açılış kapısı | ✅ `tek-kopya` **YEŞİL** · `kapi-ad-teklik` **YEŞİL** · `sayi-tazeligi` **TEMİZ** · `belge-tavan` **SARI** (T1 yeşil; T2 `DURUM.md` 1.129 b, `BORCLAR.md` 151 b — beyan ediliyor, susturulmuyor) |
| 8 | `design-token-kapisi.py` | ✅ **EXIT 0** — *"her MUST token kodda kullaniliyor, ham literal yok"* |
| 9 | `DESIGN.md` yeni kimlik + `DURUM.md` §9 | ✅ `DESIGN.md` **18.587 b · `8B8AA35D`** (U+FFFD 0 · CRLF 0); `DURUM.md` §9 **aynı turda** güncellenmiş ve `3780ACA4` **GEÇERSİZ** yazılmış |
| 10 | `ADR 0004` iskeleti | ✅ `docs/ADR/0004-web-capraz-koken-izolasyonu.md` **3.656 b · `06BE5761`** |
| 11 | koşucu `K26` kapsamında | ✅ Koşucuyu **Code yazdı**, hükmü **Cowork veriyor**; ayrıca Cowork **kendi iki bağımsız koşucusunu** yazıp koştu |
| 12 | ham çıktılar `KANIT/W2/` | ✅ 19 `_KOSUM-*.txt` + `02`/`03`/`04` + Cowork'ün iki betiği |

## 2. KRİTER 4 — LAFIZ KARŞILANMADI, KUSUR **SPEC'TE**

**Ölçülen:** 17 mutantın **hiçbiri hayatta kalmadı** (hepsi bir yerden ısırdı); `MW20` negatif
kontrolü **KALDI** (koşucu bozuk değil); dört dosyada geri alma **bayt-özdeş**.
**Eşleşmeyen dört mutant, `gözlenen ⊇ hedef`** — yani **aşırı-yakalama**, `gözlenen ⊉ hedef`
(kör kapı) **değil**.

| mutant | hedef | gözlenen | sınıf |
|---|---|---|---|
| `M200` | `{G39/b}` | `{G39/b, G39/e, G39/g}` | ④ **tek `return`**, üç ayak aynı yoldan geçiyor |
| `M204` | `{G40/a, G40/b}` | `+ G40/e, G40/f` | şerit hiç çizilmeyince e ve f de düşer |
| `M206` | `{G40/b}` | `{G40/a, G40/b, G40/e}` | `G40/a`'nın **spec'in EMRETTİĞİ** gömülü pozitif kontrolü |
| `M207` | `{G40/c}` | `{G40/c, G40/f}` | `G40/f` ön-koşulu **aynı sabiti** kullanıyor (`D-W2-7` gereği) |

🔴 **COWORK BU AÇIKLAMAYA GÜVENMEDİ, İKİSİNİ KENDİ ELİYLE KOŞTU:**

**(a) `M215` — dilimin en yük taşıyan mutantı** (`YB-1`'in kapandığı yer):
```
taban sha8     : 84D87200  (8.920 b)   [Code'un beyan ettiği sha ile BİREBİR AYNI]
[KONTROL] mutantsız : cikis=0
[M215] argümanlar SABİT DİZGEYE çevrildi (8.920 -> 8.864 b)
  cikis=1  |  kırmızı: "G42/a — depolamaBildirimiYaz( cagrisi VAR ve argumanlari birebir..."
geri alma sha8 : 84D87200  ozdes=True
[KONTROL] geri sonrası: cikis=0
```
⇒ **`YB-1` ÇALIŞAN KODLA KAPANDI.** Sabit-argümanlı gövde — v2'yi tam puanla geçen saldırı —
artık kapıyı **geçmiyor**, ve **yalnız hedef ayağı** düşürüyor.

**(b) `M200` — aşırı-yakalama iddiasının kendisi:**
```
taban sha8  : C46A2F05  (3.042 b)
[M200] ④ aksi-hâl dalı geriDusus -> kaliciOpfs
  cikis=1  |  KIRMIZI AYAKLAR (ölçülen): G39/b, G39/e, G39/g
geri alma   : sha8=C46A2F05 ozdes=True
```
⇒ Code'un beyanıyla **birebir aynı**, ve kaynak bunu doğruluyor: `depolama_durumu.dart`'ta
④ **tek bir `return DepolamaSinifi.geriDusus;`** satırıdır; `G39/b`, `G39/e`, `G39/g`
üçü de **aynı koddan** geçer. **Kod doğru; SPEC'in `hedef` sütunu, üç ayağın tek dala
düştüğünü hesaba katmamış.**

🔴 **HÜKÜM (kriter 4):** kriterin **LAFZI** (*"eşleşmiyorsa mutant GEÇMEDİ"*) **KARŞILANMADI**.
Bu **susturulmuyor**. Ama kusur **kodda değil, kilitli spec'in mutant tablosundadır** ve bu
**ölçülerek** gösterildi. Düzeltme yolu bir **ERRATUM**dur ve kilitli bir spec'e dokunduğu için
**Onur'un kilidini ister** (aşağıda §4).

## 3. KAPANAN BEYAN EDİLMİŞ SINIR

🟢 **Spec §8/3'ün `[ÖLÇÜLMEDİ]` kalemi KAPANDI ve Cowork bunu BAĞIMSIZ doğruladı:**
`drift_flutter-0.3.1/lib/src/native.dart` içinde `web` dizgesi **yalnız bir kez** geçiyor —
`DriftWebOptions? web,` **parametre bildiriminde**; gövdede **hiç okunmuyor** ⇒ native yolda
`onResult` **çağrılmaz**, durum `olculmedi` kalır (`D-W2-7` doğrulandı).

## 4. HÜKÜM

🟢 **`W2` KABUL EDİLEBİLİR — KAPANMAMIŞ BİR SINIRLA** (`A13`/`K130`, `SS2`/`K136`, `W1`/`K138`
emsali). On iki kriterin **on biri** Cowork'ün kendi koşumuyla **tam** doğrulandı; kriter 4
**13/17 tam + 4/17 aşırı-yakalama** ile kapandı ve fark **beyan edildi, gizlenmedi**.

🔴 **KABUL KİLİDİ ONUR'DADIR** ve yanında **bir ERRATUM kararı** bekliyor:

| şık | ne yapar | bedel |
|---|---|---|
| **① ERRATUM (öneri)** | Dört mutantın `hedef` sütunu yeni bir `K` numarasıyla genişletilir (`M200`→`{G39/b,e,g}` · `M204`→`{G40/a,b,e,f}` · `M206`→`{G40/a,b,e}` · `M207`→`{G40/c,f}`); **spec dosyasına DOKUNULMAZ**, düzeltme hafızada yaşar | Kilitli spec ile hafıza arasında bilerek bir sapma kalır (beyan edilir) |
| ② v4 turu | Spec yeniden açılır, tablo düzeltilir, yeniden kilitlenir | `K53/1` tavanı **üçüncü kez** aşılır; radar `R1` bu artefakta üçüncü turu **yasaklıyor** |
| ③ olduğu gibi | Fark yalnız bu hükümde yaşar | Kriter 4'ün lafzı ile ruhu arasındaki gerilim **mekanik iz bırakmaz** — bir sonraki el bunu göremez |

🔴 **YAŞAYAN SINIRLAR (kabul bunları KAPATMAZ):**
① Gerçek tarayıcıda şeridin göründüğü **hâlâ ölçülmedi** (`ORTAM.md`: `flutter test --platform
chrome` sonuç üretmiyor) ⇒ `B-W1-2` **açık**, iddia spec §8/2'deki **daraltılmış** hâliyle geçerli.
② `G40`'ın "VAR" yüklemi **yerleşim** ölçer, **boyama** değil (spec §8/6).
③ `v3` **yeniden denetlenmedi** (radar `R1`); bu turda ısıran kusur çıkmadı ama bu **kanıt değildir**.
④ `belge-tavan` **SARI** iki dosyada; `BORCLAR.md` payı **151 b** — bir sonraki borç `T1`'i KIRMIZI yapar.
