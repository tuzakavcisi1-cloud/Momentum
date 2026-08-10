# HÜKÜM — `adr-hukum-kapisi.py` · **DÜZELT** (Cowork, bağımsız koşum, oturum 67)

> **EL:** Aracı **Claude Code** yazdı; bu hükmü **Cowork** verdi (`K26`). Üreticinin beyanı kanıt
> sayılmadı; her sayı bu belgede **yeniden ölçüldü**.
> **Tarih (cihazdan ÖLÇÜLDÜ):** 2026-08-10 (+03).

## 0. HÜKÜM: 🔴 **DÜZELT — KABUL EDİLMEDİ**

İki **BLOKER**, ikisi de **çift doğrulandı** ve ikisi de üreticinin **37/37 altın kümesinin
görmediği** yollarda. Kalan her ölçüm 🟢.

---

## 1. 🔴 BLOKER-1 — Araç ÇÖKÜYOR (`ValueError`), spec §4c'nin şartı karşılanmıyor

`araclar/adr-hukum-kapisi.py`:198
```python
sinif, a, b = _g52_hedef_ayikla(ham_satir, kok)     # UC'LU ac
```
`_g52_hedef_ayikla`'nın **altı** dönüş noktasından **beşi** 3'lü demet döndürüyor; biri **2'li**:
```python
return ("a2-ortam-hatasi", "flutter_bootstrap.js bulunamadi (git-izsiz build ciktisi, G52/a2)")
```
⇒ tetiklenmiş bir satırda `<yertutucu>` varken `wwwroot/flutter_bootstrap.js` **yoksa** araç
`ValueError: not enough values to unpack (expected 3, got 2)` ile **düşer ve HİÇBİR HÜKÜM VERMEZ**.

**Ölçüm (kontrollü, aynı belge, tek değişken):**

| koşul | sonuç |
|---|---|
| bootstrap **VAR** | 🟢 `EXIT 3` · `[ORTAM HATASI] … 'https://www.gstatic.com/flutter-canvaskit/abc123def456/canvaskit.wasm' bağlantı KURULAMADI` |
| bootstrap **YOK** | 🔴 `Traceback … line 198 … ValueError` — **çöküyor** |

**Neden bloker:** spec `§4c` birebir *"dosya yoksa **ORTAM HATASI** (yeşil **değil**)"* diyor. Bu, iki
denetçinin (A/YB4 · B/Y3) v2'de bulup v3'e **yazdırdığı** şarttır — kodda **uygulanmamış**.
`wwwroot` **git-izsizdir** (`.gitignore:31`) ⇒ temiz klonda / CI'da / `flutter build web` koşmamış
makinede bu **normal** durumdur, kenar vaka değil.
**Onarım:** o dönüşe üçüncü öge (`None`) eklenir. Tek satır.

---

## 2. 🔴 BLOKER-2 — `G54/a`, hedef belgenin KULLANDIĞI atıf biçimine KÖR

`ATIF_DESENI = re.compile(r"`?([\w./\\-]+\.(?:cs|py|md|js|json))(?::(\d+)(?:-(\d+))?)?`?")`
— satır numarası **backtick'in İÇİNDE** olmak zorunda.

**Ölçüm (aynı kusur, yalnız atıf biçimi değişti):**

| atıf biçimi | `G54/a` |
|---|---|
| `` `araclar/kaynak.py`:3 `` — **ADR 0004'ün kullandığı biçim** | 🔴 **SESSİZ** (EXIT 0) |
| `` `araclar/kaynak.py:3` `` | 🟢 ISIRDI (KIRMIZI) |
| `araclar/kaynak.py:3` (çıplak) | 🟢 ISIRDI |
| `` `araclar/kaynak.py:2-4` `` (aralık) | 🟢 ISIRDI |

Hedef belgedeki gerçek atıflar bu biçimdedir: `ADR:31` `` `IzolasyonBasliklari.cs`:32-36 `` ·
`ADR:33` `` `Program.cs`:117 `` · `ADR:37` `` `IstemciServisi.cs`:43 ``.
⇒ **`G54/a` `docs/ADR/0004`'te HİÇBİR atıfı çözemez** ⇒ `kanonik-kopya` — `R1`'in üç sınıfından
biri — hedef belgede **mekanik olarak kapanmamıştır**.

🔴 **İkinci katman:** `NK4`/`NK5` (backtick'li tanımlayıcı yanlış-pozitif bekçileri) bu yüzden
**boşta geçiyor** — susmalarının sebebi *"backtick alıntı sayılmıyor"* değil, **atıfın hiç
ayrıştırılmaması**. Susan bir negatif kontrol, ölçtüğünü sanır. Bu, `spec §6`'nın kendi
**ÖLÜ MUTANT** tanımıdır.
**Onarım:** desene `` `yol`:satır `` biçimi eklenir; `NK4`/`NK5` **onarımdan sonra** yeniden koşulur
(şu an geçmeleri hükümsüzdür).

---

## 3. 🟢 KIRAMADIKLARIM — bağımsız sondanın DOĞRULADIKLARI

14 sondalık **kara kutu** koşumu; girdiler üreticinin altın kümesinden **bağımsız** kuruldu.

| sonda | ayak | sonuç |
|---|---|---|
| P01 · P03 | `G53/d` koşullu `UseCors()`, **pencerede iki çağrı** | 🟢 ISIRDI (Code'un oturum içi düzeltmesi çalışıyor) |
| P02 | `G53/d` koşulsuz çağrı | 🟢 **SUSTU** (yanlış-pozitif tabanı sağlam) |
| P04b | `G52/a2` şablon çözümleme | 🟢 host+revision **doğru sentezlendi** (uydurma revision yerine oturdu ⇒ vakaya değil **sınıfa** bakıyor) |
| P06 | `D-K170-9` büyük `İ` | 🟢 tetikledi; kod satır 62'de kanonik reçete: `s.replace("İ","i").replace("I","ı").lower()` — **NFKD yok** |
| P09 | `G55/a` durum iddiası + envanterde yok | 🟢 ISIRDI |
| P10 | `G55/a` kutup: yokluğun **doğru** beyanı | 🟢 **SUSTU** |
| P11 | `G53/c` sabit çözümleme → `G53/a2` | 🟢 ISIRDI, anahtarı `Izolasyon:Etkin` diye **adıyla** raporladı |
| P12 | `G56/a` sözlükte olmayan sınıf | 🟢 ISIRDI + öneri |
| P13 | kusursuz belge | 🟢 **KIRMIZI vermedi** |
| P14 | `D-K170-2` dizin argümanı | 🟢 `[S0] BİÇİM`, EXIT ≠ 0 |

**Kriter 3 (gerçek `docs/ADR/0004`, Cowork'ün kendi koşumu):** `V1` (a2 URL'yi sentezledi) ·
`V2` (`Izolasyon:Etkin`) · `V3` (`UseCors()` koşullu) · `V6` (`yayin-kapisi.py` ×3) — **dördü de
bulundu**, artı spec `§8/10`'un öngördüğü **`Cors:AllowedOrigins`** ek bulgusu ve `G55/c`'nin
`W3/G43` mutantsız-ayak bulgusu.

**Diğer kriterler (Cowork koşumu):** `--altin-kume` **37/37 EXIT 0** · `spec-kapi-kapsama.py`
**EXIT 0** · `sayi-tazeligi.py` **TEMİZ EXIT 0** (Code'un *"EXIT 1"* iddiası **yeniden
üretilemedi**) · commit'ler gerçek (`abb443f`, `06e3ff9`, author doğru).

---

## 4. 🔴 SONDANIN KENDİ KUSURLARI (gizlenmiyor)

İlk koşumda **5 sonda kaldı**; ikisi **benim** kusurumdu ve düzeltildi:
1. Sözlük fixture'ını `{"siniflar":[…]}` diye kurdum; şema `{"girdiler":[…]}` ⇒ `G56/a` her koşumda
   patlayıp diğer bulguları **maskeledi**.
2. Sonda belgelerini **ASCII Türkçe** yazdım (*"Sira zorunludur"*, *"olculmedi"*) ⇒ tetik aileleri
   eşleşmedi ve dört sonda **sahte KALDI** verdi. **Ölçüm aracının kendi kusurunu ürüne yazmak, kör
   kapının aynadaki hâlidir** (`ORTAM.md`) — bu tuzağa düştüm, ölçümle çıktım.

## 5. NE ÖLÇÜLEMEDİ

- **Spec §6'nın 27 mutantı + 5 NK'si BAĞIMSIZ KOŞULMADI.** Diskte fixture **yok**
  (`araclar/fixture/adr-hukum/` altında **2** dosya, ikisi de pozitif kontrol); altın küme
  fixture'ları `tempfile.TemporaryDirectory()` ile **aracın içinde** üretiliyor ⇒ mutantlar ile
  altın küme **aynı el, aynı artefakt**. Bu hüküm **14 sondalık hedefli körlük taraması**dır;
  Onur bunu bilerek seçti. **`K26` bu ölçekte KAPANMADI, kriter 2 SAĞLANMADI.**
- **Windows/PowerShell ayağı** — tüm koşumlar `device_bash` Linux VM'inde. Ağ ayağı bu VM'den
  **403 proxy** (bulut konteynerden `HEAD` çalışıyor) ⇒ kabul koşumu **cihazda** tekrarlanmalı.
- **`_SILINECEKLER/`** ve `KANIT/**` içerikleri açılmadı; `sinif-sozlugu.json`'un **115 girdisinin
  içeriği** denetlenmedi (yalnız şeması ve `G56/a`/`G56/b` davranışı ölçüldü).
- `G52/b`, `G53/a`, `G53/e`, `G54/b`, `G54/c`, `G54/d`, `G55/b`, `G55/c`, `G55/d`, `G56/b`, `G56/c`
  ayakları **sondada ayrıca sınanmadı** (gerçek ADR koşumunda bir kısmı ısırdı).

## 6. SIRADAKİ

1. İki blokerin onarımı — **Claude Code** (`K26`: hükmü veren el onarmaz).
2. Onarımdan sonra `NK4`/`NK5` **yeniden koşulur** (şu an hükümsüz).
3. Altın kümeye **iki yeni vaka**: ① bootstrap yok ⇒ ORTAM HATASI (çökme değil) ② `` `yol`:satır ``
   biçiminde atıf ⇒ `G54/a` ısırır.
4. Sonra kabul koşumu **cihazda** tekrarlanır ve `mekanik_kontrol_siniflari` kararı Onur'a gelir.
