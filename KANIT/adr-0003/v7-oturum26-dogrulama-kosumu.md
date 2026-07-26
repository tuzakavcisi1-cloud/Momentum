# v7 DOĞRULAMA KOŞUMU — oturum 26 (26 Tem 2026)

**Ne koştu:** (1) tablo hücre bütünlüğü tarayıcısı (oturum 25'in betiği, DEĞİŞTİRİLMEDEN) ·
(2) `araclar/adr-kapi-taramasi.py` **altın küme** (ayrı koşum, B6-5'in beyan ettiği yükümlülük) ·
(3) aynı araç **v7 üzerinde** · (4) aynı araç **v6 üzerinde** (taban çizgisi karşılaştırması).

**Araca TEK BAYT DOKUNULMADI** (K34-f): `sha256 A22841F29A42DBAC76206EF5ABA84BB3E2C68F1788A6E602012F3045EE81ADB8` · 50.582 bayt (koşumdan sonra yeniden ölçüldü).

---

## 1. TABLO HÜCRE BÜTÜNLÜĞÜ — HAM ÇIKTI

```
===== v7 CALISMA DOSYASI  (satir 1294)
  TABLO: 23 · TOPLAM KUSUR: 0
===== v6 KANONIK (degismedi mi)  (satir 1124)
  [HUCRE SAPMASI] satir 47: 5 hucre (baslik 4)
  [HUCRE SAPMASI] satir 342: 4 hucre (baslik 3)
  [HUCRE SAPMASI] satir 908: 7 hucre (baslik 5)
  [HUCRE SAPMASI] satir 1055: 4 hucre (baslik 3)
  TABLO: 23 · TOPLAM KUSUR: 4
===== KANIT b6-1 (bu oturumun yazdigi)  (satir 168)
  TABLO: 0 · TOPLAM KUSUR: 0
===== KANIT tablo-butunlugu (oturum 25)  (satir 173)
  TABLO: 1 · TOPLAM KUSUR: 0
```

**HÜKÜM:** **v7'nin tablo taban çizgisi SIFIRDIR.** Dört sapmanın **üçü kozmetikti** (HTML yorumu
son `\|`'den sonra) ve düzeltildi; **dördüncüsü (v6 satır 908 = M56 satırı) GERÇEK KUSURDU** ve
B6-1'in yeniden yazımında kaçışlar (`\|`) eklenerek kapandı ⇒ `[KS-31]` atfı, HIBP'nin adlandırılmış
reddi ve satırın çıpası **artık render'da kaybolmuyor.**
**v6 dokunulmadı** (4 sapma aynen duruyor — kanonik sürüm değişmedi).
🔴 **Bu oturum YENİ bir hücre sapması ÜRETMEDİ ve yazdığı KANIT dosyası da temiz çıktı**
(oturum 25 aynı yerde kendi KANIT dosyasında kusur üretmişti).

---

## 2. ALTIN KÜME — AYRI KOŞUM (B6-5'in beyan ettiği yükümlülük)

```
python araclar/adr-kapi-taramasi.py --altin-kume
…
HÜKÜM: ✅ ARAÇ KULLANILABİLİR — yanlış-pozitif, yanlış-negatif ve YEDİ kör-kapı
        kontrolünü geçti (üçü v5 yazımından, DÖRDÜ kapı-5'in B5-1…B5-4 bulgularından).
UYARI:  Aracı v5'i yazan oturum yazdı, ONARAN oturum ise kapı-5'i koşan oturumdur (K26-a).
        Aracın yeşili TEK BAŞINA kanıt DEĞİLDİR; KAPI-6 ARACIN KENDİSİNİ de denetlemelidir.
ALTIN-KUME-EXIT=0
```

⚠ **Bu koşum, B6-5'in ölçtüğü sınırın somut kanıtıdır:** altın küme **ayrı bir koşumdur**
(kaynak satır 880-881: `if a.altin_kume:` → `return altin_kume()`), yani aşağıdaki v7 taraması
altın kümeyi **koşmadı**. Yükümlülük **elle** yerine getirildi ve çıkış kodu buraya yazıldı —
**mekanik olarak zorlanmıyor** (araç ONARILMAZ: K34-f).

---

## 3. v7 TARAMASI — HAM ÇIKTI (özet + bulgular)

```
ÖZET : {'karar': 47, 'alt_madde': 13, 'kapili': 32, 'beyanli': 15, 'kanonik_satir': 31,
        'kanonik_taranan': 22, 'kanonik_atlanan': 9, 'kanonik_sayi': 31, 'capasiz_tablo': 0,
        'devredilmis': 5, 'mutant': 53}

### K4 — 5 bulgu
  satır 980   SINIR DEĞER LİTERALİ: KS-4 / KS-9 (10-1) kill sinyaline yazılmış …
  satır 1017  SINIR DEĞER LİTERALİ: KS-4 / KS-9 (10-1) kill sinyaline yazılmış …
  satır 0     K4 `[KS-LITERAL:]` MUAFİYETİYLE GEÇEN KOPYALAR [ELLE DOĞRULA] …
  satır 0     K4 ZAYIF EŞLEŞMELER [çıplak sayı — birim uyuşmadı; ELLE DOĞRULA] …
  satır 0     K4 KAPSAM DIŞI BIRAKTIKLARI [sessiz daraltma yok] …

### K6 — 2 bulgu
  satır 252   ÖZELLİK DÜZEYİ BELİRSİZLİĞİ: K3-B4 hem çıpa sütununda hem §3.1'de …
  satır 345   ÖZELLİK DÜZEYİ BELİRSİZLİĞİ: K3-C4 hem çıpa sütununda hem §3.1'de …

TOPLAM: 11 → (düzeltmelerden SONRA) 7 bulgu
```

## 4. v6 TARAMASI — TABAN ÇİZGİSİ (aynı araç, aynı gün)

```
### K4 — 5 bulgu
  satır 853   SINIR DEĞER LİTERALİ: KS-4 / KS-9 (10-1) …
  satır 890   SINIR DEĞER LİTERALİ: KS-4 / KS-9 (10-1) …
  (+ 3 toplu rapor satırı)
### K6 — 2 bulgu
  satır 196   K3-B4 …
  satır 271   K3-C4 …
TOPLAM: 7 bulgu
```

---

## 5. HÜKÜM — v7, ARAÇ BULGUSU BAKIMINDAN v6 İLE AYNI ÇİZGİDEDİR

| eksen | v6 (kanonik) | v7 (çalışma) | hüküm |
|---|---|---|---|
| `K1` (kapısız-ve-beyansız) | 0 | **0** | eşit |
| `K4` bulgu sayısı | 5 | **5** | eşit — **YENİ kopya YOK** |
| `K6` (özellik düzeyi) | 2 | **2** | eşit (K3-B4 · K3-C4, ikisi de devredilen kalem) |
| TOPLAM | 7 | **7** | eşit |
| tablo hücre sapması | **4** | **0** | **v7 DAHA İYİ** |

### 🔴 AMA ÖNCE ÖYLE DEĞİLDİ — DÜRÜSTLÜK KAYDI, GİZLENMİYOR

İlk koşumda **v7'nin 13 bulgusu vardı** (`K1` 1 · `K4` 10 · `K6` 2). Aradaki fark **bu oturumun
kendi ürettiği kusurlardı** ve **hepsini KOŞULAN araç buldu, akıl yürütme değil:**

1. **`K1` 1 bulgu — `K3-L8(4)` kapısız-ve-beyansız çıktı.** Yeni dördüncü dal yazılmış, kapısı
   (`M-L10`) tabloya eklenmiş, **ama `[devir]` işaretli çıpa KAPI SAYILMAZ** ⇒ §3.1'de beyan
   ZORUNLUYDU ve yazılmamıştı. **Araç HAKLIYDI**; §3.1'in devir satırına adıyla eklendi.
2. **`K4` — BEŞ kanonik-sayı kopyası.** Dördü bu oturumun (`10.000` ×2 · `15 karakter` ×1 ·
   `10 dk` ×1), **biri oturum 25'in** (`GetBytes(32)`). Dördü **atfa çevrildi**; beşincisi bir
   **C# çağrı argümanıdır** ve `[KS-LITERAL:]` ile **gerekçesiyle** muaf tutuldu.
3. **`K4` — ÜÇÜNCÜ BİR YANLIŞ-POZİTİF DOĞDU ve kaynağı, yanlış-pozitifleri BELGELEYEN cümleydi.**
   §3.1'e *"aracın iki yanlış-pozitifi var"* diye yazılan madde, ilgili bölüm atfını **rakamıyla**
   içerdiği için **kendisi de tetikledi** (ve ilk düzeltme denemesi **iki tane daha** üretti: 9 bulgu).
   Cümle **atfı rakamsız yazacak biçimde** yeniden yazıldı ⇒ taban çizgisi v6'nın **iki**
   bulgusuna geri döndü.
4. **Bir SAYI TAHMİNİ ölçümle YANLIŞLANDI.** `K3-L8(4)` notu ilk yazımında *"devredilmiş 5 → 6"*
   diyordu; araç `devredilmiş`i **KARAR kimliği** düzeyinde saydığı için sayı **değişmedi**
   (`alt_madde` bir arttı). Satır düzeltildi — belgenin kendi §4 kuralının kendisine uygulanması.

⇒ **K33'ün örüntüsünün ALTINCI kanıtı:** *bir kusur sınıfını kapatan tur, o sınıfın en olası
üreticisidir* — ve dördünde de **bulan şey akıl yürütme değil, KOŞULAN bir ölçüm aracı oldu.**

---

*Bu dosya bir ÖLÇÜM kaydıdır, bir kapı değildir. Kapı-7 hem ölçümü hem hükmü denetlemelidir —
özellikle §5'in "eşit çizgide" hükmünü ve `[KS-LITERAL:]` muafiyetinin gerekçesini.*
