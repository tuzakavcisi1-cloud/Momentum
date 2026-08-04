# -*- coding: utf-8 -*-
"""Oturum 56 -- SS2 KABUL: DURUM.md §4 ve §5 guncellenir, K136 hafizaya yazilir.
K73: kabul edilen dilimin kilitleri §5'ten CEKILIR, tek satirlik atifla temsil edilir."""
import hashlib, io, os, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DURUM, HAFIZA = os.path.join(KOK, "DURUM.md"), os.path.join(KOK, "PROJE_HAFIZA.md")


def atomik_yaz(yol, metin):
    ham = metin.encode("utf-8")
    tmp, yedek = yol + ".tmp", yol + ".yedek"
    with open(tmp, "wb") as f:
        f.write(ham)
    if os.path.exists(yedek):
        os.remove(yedek)
    os.rename(yol, yedek)
    try:
        os.rename(tmp, yol)
    except Exception:
        os.rename(yedek, yol)
        raise
    if hashlib.sha256(open(yol, "rb").read()).digest() != hashlib.sha256(ham).digest():
        os.remove(yol)
        os.rename(yedek, yol)
        raise SystemExit("[KIRMIZI] SHA TUTMADI -- yedek geri alindi.")
    os.remove(yedek)
    return len(ham)


ESKI_8 = """🟢 **⑧ `SS2` v3 KİLİTLENDİ (`K133`) ve `T0`–`T8` UYGULANDI (`K134`, oturum 55).** Beş bloker
kapandı, 13 major borçlandı (`S11`–`S14` + `B-SS2-4`); üçüncü denetim turu `K53/1` gereği
**açılmadı**. Claude Code `b900bae` ile **+5831/−69** yazdı. 🔴 **KABUL VERİLMEDİ:** Cowork'ün kendi
koşumuyla **kriter 1·2·3·5·6·7·9 geçti** (`analyze` 0 · `test` **522/522** · `verify.ps1` EXIT 0,
backend **120/120**, CVE 0);
`ss2-kapisi.py` altın küme **14/14** (oturum 56'da 10→14: oturum 55'in iki MINOR'u **pinlendi** +
**blok yorum KÖR KAPISI onarıldı**, mutantla kanıtlı). 🔴 **kriter 8 (uçtan uca) ÖLÇÜLMEDİ.**
Hükümler: `KANIT/SS2/03-v3-KILIT.md` + hafıza K134."""

YENI_8 = """🟢 **⑧ `SS2` KABUL EDİLDİ (`K136`, oturum 56 · Onur kilitledi).** Dokuz kriterin dokuzu
Cowork'ün KENDİ koşumuyla ölçüldü (K26); **çakışma cihazda ilk kez uçtan uca görüldü**: rozet
çıktı, ekran iki değeri gösterdi, *Benimkini tut* karşı cihaza ULAŞTI, iki `clientId` ve HLC
sırası **sunucu veritabanından** ölçüldü. Hüküm `KANIT/SS2/04-COWORK-KABUL-HUKMU.md`.
🔴 **Kabul KAPANMAMIŞ SINIRLARLA verildi** (`A13`/`K130` emsali): ① kriter 8 spec'in **lafzıyla
koşulamadı** — üründe **başlık düzenleme UI'ı YOK**, çakışma **tamamlanma anahtarıyla** üretildi
② kuyruğun **kendiliğinden** boşalma süresi **ÖLÇÜLMEDİ** (Yenile ile zorlandı) ③ kriter 4 bir
**örneklemdir** ④ telefon **USB tüneliyle** bağlandı ⇒ **NAT/SignalR borcu KAPANMADI**.
Borçlar `B-SS2-1`…`5`."""

ESKI_K133_BAS = "- 🔒 **K133 — `SS2` v3 KİLİTLENDİ (Onur kilitledi, 3 Ağu 2026, oturum 55):**"
YENI_K133 = ("- 🔒 **K133 · K136 — `SS2` KİLİTLENDİ ve KABUL EDİLDİ** (Onur; 3 ve 4 Ağu 2026). K73 gereği "
             "kilit §5'ten **ÇEKİLDİ**; kurallar bugün `SS2/G31`–`G34` kapılarında ve `M171`–`M188` "
             "mutantlarında **koşuyor**. 🔴 **Yaşayan üç sınır:** ① `spec-kapi-kapsama.py` *\"mutant "
             "ISIRIR mı\"* **sormaz** (`B-SS2-4`) ② üründe **başlık düzenleme UI'ı YOK** ⇒ kriter 8 "
             "**tamamlanma anahtarıyla** koşuldu ③ `M172`'nin *beklenen* metni gerçeği tarif etmiyor "
             "(`B-SS2-5`). Gerekçeler: hafıza K133 · K135 · K136.")

K136 = """

## K136 — `SS2` KABUL EDİLDİ (Onur kilitledi, 4 Ağu 2026, oturum 56)

**Hüküm dosyası:** `KANIT/SS2/04-COWORK-KABUL-HUKMU.md`. Dokuz kriterin dokuzu **Cowork'ün kendi
koşumuyla** (K26). Kriter 8 kanıtı: `KANIT/o56/65-KRITER8-HUKUM.md` + 40–64 numaralı ham çıktılar.

**Bu oturumun en pahalı dersi.** Kriter 8'i koşmaya başlayınca ölçüldü ki **spec, ürünün
taşımadığı bir etkileşimi kabul şartı yapmış**: ④/⑤ *"başlık `B1`/`A1` yapılır"* diyor ama
uygulamada **başlık düzenleyen bir yol yok** (`duzenle()` `lib/` içinde **yalnız** `cakismaCoz`'dan
çağrılıyor; `gorev_satiri.dart` kendi kaynağında *"bu widget `onTap` TAŞIMAZ"* diyor). Spec iki
kâğıt denetim turundan geçmişti; **hiçbir tur *"bu adım cihazda fiilen yapılabiliyor mu"* diye
sormamıştı.** 🔴 **Yeni kusur sınıfı: KOŞULAMAZ KABUL ŞARTI.** Kâğıt denetimi bir adımın
*doğruluğunu* denetler, *yapılabilirliğini* denetlemez — yapılabilirlik ancak ortam kalkınca ölçülür.

**Onur'un kilidi:** çakışma **tamamlanma anahtarıyla** üretilsin, sapma **beyan edilsin**, spec
**açılmasın**. Ölçülen gerekçe: `kanonikDize` tamamlanma alanını da taşır (`M187`'nin
`groups:completion` dalı) ⇒ aynı dört şart, aynı rozet, aynı çözüm yolu koşar.

**Ölçümün çekirdeği (sunucu veritabanı, `processed_operations`).** B'nin çevrimdışı yazımı
**11:25:34'te ÜRETİLDİ**, sunucuya **11:29:36'da ULAŞTI** (4 dk kuyrukta); A'nın son yazımının HLC'si
`1785842911692` > B'nin `1785842734501` ⇒ **A kazanan, B kaybeden** — ve uygulamanın ekranı bunu
kendi diliyle söyledi: *Benimki = Tamamlandı* (B) · *Onlarınki = Açık* (A). Beyan bir yerden,
ölçüm başka yerden geldi ve **tuttular**.

🔴 **Cowork'ün bu koşumda ürettiği iki ölçüm kusuru (ikisi de kendi kendine yakalandı):**
① `toybox nc` probu başarılı bağlantıda `stdin`'i bekleyip **40 s astı** — `stdin=DEVNULL` ile
onarıldı; **probun kusuru ürüne yazılmadı**. ② **Döküm satır sınırı DOKUNMA ALANI DEĞİLDİR:**
`CheckBox` semantics düğümü satırın tamamını kaplıyor, gerçek hit-test alanı **solda ~132 px**.
Satır merkezine dokunmak hiçbir şey yapmadı; acele edilse *"ısırmadı"* diye **yanlış hüküm**
basılırdı — oturum 55'in *"bir mutant ısırmıyorsa önce mutantın yanlış yere düştüğünü düşün"*
dersinin **UI'daki birebir kardeşi**.
"""

durum = io.open(DURUM, encoding="utf-8").read()
d_once = len(durum.encode("utf-8"))
if durum.count(ESKI_8) != 1:
    raise SystemExit("[KIRMIZI] §4 ⑧ blogu TEK DEGIL (%d)" % durum.count(ESKI_8))
durum2 = durum.replace(ESKI_8, YENI_8)
satirlar = durum2.split("\n")
idx = [i for i, s in enumerate(satirlar) if s.startswith(ESKI_K133_BAS)]
if len(idx) != 1:
    raise SystemExit("[KIRMIZI] K133 ANCHOR TEK DEGIL (%d)" % len(idx))
son = idx[0] + 1
while son < len(satirlar) and not satirlar[son].startswith("- ") and satirlar[son].strip():
    son += 1
satirlar[idx[0]:son] = [YENI_K133]
durum3 = "\n".join(satirlar)

hafiza = io.open(HAFIZA, encoding="utf-8").read()
h_once = len(hafiza.encode("utf-8"))
h_sonra = atomik_yaz(HAFIZA, hafiza + K136)
print("PROJE_HAFIZA.md : %d b -> %d b (%+d)" % (h_once, h_sonra, h_sonra - h_once))
d_sonra = atomik_yaz(DURUM, durum3)
print("DURUM.md        : %d b -> %d b (%+d)  pay %d b" % (d_once, d_sonra, d_sonra - d_once,
                                                          32768 - d_sonra))
