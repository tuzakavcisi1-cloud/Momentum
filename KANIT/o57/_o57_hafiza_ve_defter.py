# -*- coding: utf-8 -*-
"""K137 checkpointi (PROJE_HAFIZA.md, DIZIN:SON ALTINA) + oturum 57 defter kayitlari.
K60 atomik yazim. Emoji chr() ile kurulur (ORTAM.md: iki \\u kacisi BIRLESMEZ).
"""
import hashlib
import io
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
HAFIZA = os.path.join(KOK, "PROJE_HAFIZA.md")
DEFTER = os.path.join(KOK, "PROJE_RADAR.jsonl")
KIRMIZI = chr(0x1F534)
YESIL = chr(0x1F7E2)
KILIT = chr(0x1F512)

CP = """
## K137 — `GOREV-W1` v2 KİLİTLENDİ (Onur, 4 Ağu 2026, oturum 57)

{K} **Kimlik: 33.077 b · `5CF3F921`.** Kilit satırı ÖNCESİ `606F04F5` (32.801 b) ve v1 `DFA8FF77`
(19.941 b) **GEÇERSİZDİR**. Kapıları `W1/G35`–`W1/G38`, mutantları `M189`–`M199` (18 adet).

**NEDEN BU İŞ SEÇİLDİ — ölçüldü, hissedilmedi.** `radar.py . --olc-urun-kodu 32336559..HEAD` ⇒
oturum 56 **0 satır** ürün kodu. `KANIT/o57/_o57_r8_mutant.py` gerçek deftere dokunmadan kopya
dizinde ölçtü: kontrol ⇒ `R8` **susuyor**; oturum 57 de 0 yazılırsa ⇒ `R8` **ısırıyor**
(*"SERT DURAK: bir sonraki oturum ÜRÜN KODU ile başlar; yeni belge/ADR/spec/araç turu AÇILMAZ"*).
{R} Bu yüzden ⑨ web borcu **spec turu olarak DEĞİL**, `K53/5` gereği **yürüyen iskelet** olarak
kuruldu; 100k'lık tam web spec'i **bilerek yazılmadı**.

**ÖLÇÜLEN TABAN (DURUM.md'nin söylemediği):** `flutter build web` **EXIT 0** (57,3 s, artefakt
tazelendi) · Drift web **tam bağlı** (`DriftWebOptions` + `onResult` `MOMENTUM-G6-KANIT` kancası) ·
`kIsWeb` yalnız 2 yerde · {R} **92 backend dosyasının hiçbirinde CORS YOK** (pozitif kontrollü
tarama). Web'in blokeri *"spec yok"* değil **CORS**'tur ve bu kusur **derleme başarısıyla görünmez**.

**{KP} K127 ŞARTI ÖDENDİ — VE İŞE YARADI.** İki bağımsız denetçi (`K26`: üreten ≠ denetleyen)
kilitten ÖNCE koştu: `KANIT/W1/00-DENETIM-kosulabilirlik.md` (`6000E9A4`) **3 bloker/7 major/5 minor**
· `KANIT/W1/00-DENETIM-kor-kapi.md` (`269D1F22`) **3 bloker/6 major/3 minor**.
Altı bloker: ① `Content-Type` izinli başlıklarda yoktu ⇒ **dört kapı da YEŞİL kalırken Chrome
isteği bloklardı** ② `G38/b` `DEV_USER_ID` olmadan koşulamaz ③ koşan mutantları/F5'i **kimin**
koşacağı yazılı değildi (`K80` çelişkisi) ④ **`G37/b` KÖRDÜ** — backend açıkken F5 testi kalıcılığı
değil senkronu ölçer (imleç aynı Drift DB'sinde) ⑤ `M196` **eşdeğerdi** ⑥ `AddCors` yarısı hiçbir
ayakta ölçülmüyordu. Altısı da v2'de kapandı; kapanışlar spec `## 0`'da satır satır yazılı.

{R} **ÜÇÜNCÜ ISIRIŞ — `spec-kapi-kapsama.py`'nin BİÇİMİNİ TAHMİN ETMEK.** v1'in **EXIT 0**'ı
kapı başına **tek bit** ölçüyordu: kararlar `###` başlığı değil **kalın metindi** ⇒ araç
`KURAL (0)` görüyor, `## 6b` prozası **hiç okunmuyordu**. Biçim aracın **kaynağından okundu**
(`KANIT/o57/_o57_borc_bicimi.py`): kural adı `### <ad>`'den, borç yalnız
`- KURAL: <ad> | GEREKCE: <>=20 karakter>` biçiminden. v2 ölçümü: `KAPI (4)` · **`KURAL (9)`** ·
`MUTANT (18)` · `BEYAN EDILMIS BORC (1): D-W1-7` · **EXIT 0**. Ders: **aracın kabul ettiği biçimi
tahmin eden el, kendi beyanını sessizce ölü yapar** (`K81`/`K126` sınıfının üçüncü ısırışı).

{R} **ORTAM.md ISIRDI, K60 TUTTU.** Kilit satırını yazan ilk betik emojiyi iki ayrı `\\u` kaçışı
olarak kurdu; **birleşmedi**, vekil karakter kaldı ve `encode('utf-8')` patladı. `K60`'ın sırası
(**önce encode, sonra yaz**) sayesinde dosyaya **tek bayt yazılmadı** — spec `606F04F5`'te kaldı.
Çözüm: emoji `chr(0x1F512)` ile kuruldu.

**DEFTER ONARIMI:** oturum 56 kendi radar kaydını yazmamıştı ve bu boşluk `R8`'i **körleştiriyordu**;
altı kayıt geriye dönük yazıldı (291.415 → 299.011 b), her satır kendi kökenini beyan ediyor
(ölçülen ↔ `[TAHMIN]`). {R} Kendi doğrulayıcım ilk koşumda **6 sahte KIRMIZI** verdi (defterin `#`
başlık bloğunu JSON sandı) — **ölçüm aracının kendi kusuru**, onarıldı.

{R} **YAŞAYAN SINIRLAR (kabul edilmedi, BEYAN edildi):** ① uygulama **fiilen koşulmadı** (`K80`) ⇒
`Content-Type` blokerı kod okumasıyla kesin, **canlı preflight'la değil**; `T3` spec'i
**yanlışlayabilir** ② `cors-kapisi.py`/`_preflight.py` **yok** ⇒ **18 mutantın ısırdığı ÖLÇÜLMEDİ**;
`spec-kapi-kapsama.py` kendi beyanıyla *"ısırmayı değil kapsamayı"* ölçer ③ `WebApplicationFactory`
riski `[ÖLÇÜLMEDİ]` (spec `## 8/7`) ④ `B-W1-1`/`B-W1-2` `BORCLAR.md`'de **yok** ⇒ **sarkan atıf**;
`T7` kapatır ve `BORCLAR.md` **SARI** olduğu için tavan kararı `K40` gereği **Onur'a** gider
⑤ spec `tek-kopya-kapisi.py` kapsamına **eklenmedi** (beyanlı-kilit sepeti, `A13`/`SS2` emsali).

{R} **ÖLÇÜLDÜ — `K135` ve `K136` DOSYANIN SONUNA YAZILMIŞ (`K58` İHLALİ, İKİNCİ KEZ).** Oturum 57
bu checkpoint'i yazarken işaret arandı ve `<!-- DIZIN:SON -->` dosyada **5 kez** geçtiği görüldü;
dördü checkpoint **gövdesinde**, kuralın kendisini alıntılayan prozada. Gerçek işaret **satır
183**; `K135` **satır 7498**, `K136` **satır 7601** — yani ikisi de **dosyanın SONUNDA**. Bu, satır
405'te kayıtlı `K129`/`K130` kusurunun **birebir tekrarıdır**. {R} **TAŞINMADILAR** — dosya
append-only'dir, yerinde düzeltme YASAKTIR; kural gereği yalnız bu **düzeltme notu** yazılır ve
deftere `olcum-duzeltme` kaydı girer. Ders: *kuralı ALINTILAYAN proza, kuralı UYGULAYAN aracın
işaret aramasını kirletir* — bu yüzden `K137` işareti **satır başında** olma şartıyla aradı.

{Y} **BORÇLANAMAYAN KUSUR YOK:** `K53/1` turu **1**'de kaldı — iki denetçi de *"hiçbir bloker
mimariyi değiştirmiyor: düzelt → kilitle"* dedi, üçüncü tur **açılmadı**.
""".format(K=KILIT, R=KIRMIZI, Y=YESIL, KP=KILIT)

KOKEN57 = " || Oturum 57 kaydi; urun_kodu_satiri GIT'ten olculdu, elle yazilmadi (K55)."

KAYITLAR = [
    {"tarih": "2026-08-04", "oturum": 57, "urun_kodu_satiri": 0,
     "artefakt": "GOREV_CLAUDE_CODE/GOREV-W1-web-yuruyen-iskelet.md", "tur": 1,
     "asama": "v1 yazildi + IKI bagimsiz denetci kilitten ONCE kostu (K127/K26)",
     "bulgu": {"bloker": 6, "major": 13, "minor": 8},
     "siniflar": ["kor-kapi", "esdeger-mutant", "kosulamaz-kabul-sarti", "beyansiz-sinir"],
     "bayt": 19941, "kapatilan": 0, "uretilen": 27,
     "not": ("URETILEN 27: v1'in KENDI yazimi 6 bloker + 13 major + 8 minor dogurdu. En agiri: "
             "izinli baslıklarda Content-Type YOKTU ve G35/d AllowAnyHeader'i YASAKLIYORDU => "
             "dort kapi da YESIL kalirken Chrome istegi BLOKLARDI. Ikincisi: G37/b KORDU -- "
             "main.dart:56 her acilista cekmeTuruCalistir kosuyor ve imlec ayni Drift DB'sinde, "
             "yani yerel kalicilik TAMAMEN cokse bile F5 sonrasi gorev gorunurdu. Ucuncusu: "
             "spec-kapi-kapsama.py'nin EXIT 0'i kapi basina TEK BIT olcuyordu (kararlar ### "
             "basligi degil kalin metindi => KURAL(0), ## 6b hic okunmuyordu). Denetim ciktilari: "
             "KANIT/W1/00-DENETIM-kosulabilirlik.md (6000E9A4) ve 00-DENETIM-kor-kapi.md "
             "(269D1F22). KAPATILAN 0 -- bu tur URETIM ve OLCUM turuydu.") + KOKEN57},
    {"tarih": "2026-08-04", "oturum": 57, "urun_kodu_satiri": 0,
     "artefakt": "GOREV_CLAUDE_CODE/GOREV-W1-web-yuruyen-iskelet.md", "tur": 2,
     "asama": "v2 yazildi, alti bloker kapandi, K137 ile KILITLENDI (Onur)",
     "bulgu": {"bloker": 0, "major": 0, "minor": 0},
     "siniflar": [],
     "bayt": 33077, "kapatilan": 22, "uretilen": 0,
     "not": ("KAPATILAN 22 = 6 bloker + 11 major + 5 minor. Kapanislar spec ## 0 tablosunda satir "
             "satir yazili. Yeni ayaklar: G35/d iki basligi da ADIYLA ister (D-W1-8) - G35/b "
             "AddCors VE UseCors'u '// W1/D-W1-2' isaretli blok araliginda arar - G37/b backend "
             "KAPALIYKEN olculur (D-W1-6) - G36/b'nin gercek hedefi origin-yankilayan politika - "
             "## 4c EL DAGILIMI (K80 celiskisi). Mutant 12 -> 18. spec-kapi-kapsama.py artik "
             "KURAL(9) goruyor ve BEYAN EDILMIS BORC(1) sayiyor, EXIT 0. BEYAN EDILEN AMA "
             "KAPANMAYAN 2 MAJOR: WebApplicationFactory riski [OLCULMEDI] (## 8/7) ve "
             "B-W1-1/B-W1-2'nin BORCLAR.md'de olmamasi (sarkan atif, T7 kapatir). URETILEN 0.")
     + KOKEN57},
    {"tarih": "2026-08-04", "oturum": 57, "urun_kodu_satiri": 0,
     "artefakt": "PROJE_HAFIZA.md", "tur": 40,
     "asama": "K137 checkpointi DIZIN:SON'un ALTINA yazildi + dizin yeniden uretildi",
     "bulgu": {"bloker": 0, "major": 0, "minor": 0}, "siniflar": [],
     "bayt": 0, "kapatilan": 1, "uretilen": 0,
     "not": ("Bayt alani 0 -- boyut ayni betikte yukarida olculur, buraya elle kopyalamak "
             "bayat-iddia uretirdi (o55/o56 deseni). ISARET SATIR BASINDA arandi: DIZIN:SON "
             "dosyada 5 kez geciyor, dordu checkpoint GOVDESINDE kurali ALINTILAYAN prozada.")
     + KOKEN57},
    {"tarih": "2026-08-04", "oturum": 57, "urun_kodu_satiri": 0,
     "artefakt": "PROJE_HAFIZA.md", "tur": 39,
     "asama": "olcum-duzeltme: oturum 56 kaydinda [OLCULMEDI] denen checkpoint YERI OLCULDU",
     "bulgu": {"bloker": 0, "major": 1, "minor": 0},
     "siniflar": ["kanonik-kopya"],
     "bayt": 0, "kapatilan": 1, "uretilen": 0,
     "not": ("OLCUM-DUZELTME (D2). Oturum 57'nin o56 icin yazdigi kayit checkpointlerin "
             "DIZIN:SON ALTINA yazilip yazilmadigini [OLCULMEDI] birakmisti. SIMDI OLCULDU: "
             "gercek isaret satir 183; K135 satir 7498, K136 satir 7601 => IKISI DE DOSYANIN "
             "SONUNDA. Bu, satir 405'te kayitli K129/K130 kusurunun BIREBIR TEKRARIDIR (K58 "
             "ihlali, ikinci kez). TASINMADILAR -- dosya append-only, yerinde duzeltme YASAK; "
             "duzeltme notu K137 govdesine yazildi. Kok neden OLCULDU: kurali ALINTILAYAN proza "
             "isaret aramasini kirletiyor (5 esleme, 4'u govde-ici) => isaret SATIR BASINDA "
             "aranmalidir. Mekanik kapisi YOK -- hafiza-dizin.py dizini uretir ama YERLESIMI "
             "DENETLEMEZ; bu bir BORCTUR.") + KOKEN57},
]


def atomik_yaz(yol, metin):
    ham = metin.encode("utf-8")
    tmp = yol + ".tmp"
    with open(tmp, "wb") as f:
        f.write(ham)
        f.flush()
        os.fsync(f.fileno())
    if hashlib.sha256(open(tmp, "rb").read()).hexdigest() != hashlib.sha256(ham).hexdigest():
        raise RuntimeError(".tmp sha tutmadi")
    yedek = yol + ".yedek"
    os.rename(yol, yedek)
    try:
        os.rename(tmp, yol)
    except Exception:
        os.rename(yedek, yol)
        raise
    os.remove(yedek)


ISARET = "<!-- DIZIN:SON -->"
h = io.open(HAFIZA, encoding="utf-8", newline="").read()
onceki_h = len(h.encode("utf-8"))
L = h.split("\n")
# OLCULDU: isaret dosyada 5 kez geciyor -- DORDU checkpoint GOVDESINDE, kuralin
# kendisini ALINTILAYAN prozada. Gercek dizin sonu SATIR BASINDA olandir.
adaylar = [i for i, s in enumerate(L) if s.strip() == ISARET and s.startswith("<!--")]
if len(adaylar) != 1:
    print("[KIRMIZI] satir-basi DIZIN:SON adayi %d -- YAZILMADI" % len(adaylar))
    sys.exit(2)
i = adaylar[0]
print("  gercek isaret satiri: %d (govde-ici alintilar atlandi)" % (i + 1))
atomik_yaz(HAFIZA, "\n".join(L[:i + 1]) + "\n" + CP + "\n".join(L[i + 1:]))
print("K137 yazildi (DIZIN:SON ALTINA): %d -> %d bayt" % (onceki_h, os.path.getsize(HAFIZA)))

onceki_d = os.path.getsize(DEFTER)
with open(DEFTER, "rb") as f:
    f.seek(-1, os.SEEK_END)
    son = f.read(1)
parca = ("" if son == b"\n" else "\n")
for k in KAYITLAR:
    parca += json.dumps(k, ensure_ascii=True) + "\n"
with open(DEFTER, "ab") as f:
    f.write(parca.encode("utf-8"))
    f.flush()
    os.fsync(f.fileno())
print("defter: %d kayit append edildi, %d -> %d bayt"
      % (len(KAYITLAR), onceki_d, os.path.getsize(DEFTER)))
