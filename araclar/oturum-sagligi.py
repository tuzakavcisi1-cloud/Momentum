# -*- coding: utf-8 -*-
"""oturum-sagligi.py 1.0.0 -- K21'in MEKANIK KAPISI (Momentum, K44-a).

K21 su an PAZARLIKSIZ ama KORDUR: "ozet kanonik degerden sapmis mi?" diye
hicbir arac sormuyor ve kanonik-kopya sinifi bu projede bes kez isirdi.
Bu arac o soruyu MEKANIK olarak sorar.

DORT + BIR AYAK, IKI AYRI HUKUM (Onur kilitledi, oturum 38):

  [KANONIK/D1 HUKMU]  -- transcript ISTEMEZ, her zaman kosar
    S1 KANONIK : CLAUDE.md'nin K21 blogundaki MUTLAK esikler, bu aracin
                 kanonik sabitleriyle ayni mi? Blok yoksa/ayristirilamazsa
                 KIRMIZI (kanonik kaynak kayip).
    S2 YUZDE   : canli belgelerde oturum-sagligi baglaminda YUZDE yazilmis mi?
                 K21: "Yuzde yazan el paydayi uydurmustur." KOSULSUZ KIRMIZI.
    S3 KOPYA   : kanonik esikler CLAUDE.md DISINDA bir canli belgeye
                 kopyalanmis mi? K21: "ESIKLER BASKA HICBIR DOSYAYA
                 KOPYALANMAZ." KIRMIZI.
    D1 TAZELIK : "kayit, olctugu dosyanin SON yazimindan ONCE mi yazilmis?"
                 uc kaynak: DURUM.md 9. bolum kimlik tablosu (DONMUS kimlikler
                 -- calisma agaciyla karsilastirilir, cunku onlar SOZLESMEDIR) |
                 PROJE_HAFIZA.md devir notunun kimlik blogu (YAZIM ANIYLA
                 karsilastirilir) | PROJE_RADAR.jsonl (ZAMAN ayagi).

                 🔴 YAZIM ANI AYRIMI [ilk gercek kosumda olculdu, oturum 38]:
                 bir devir notu zamanla "bayat" GORUNUR cunku sonraki oturumlar
                 dosyalari degistirir -- bu KUSUR DEGILDIR. Kusur, kaydin
                 YAZILDIGI AN zaten bayat olmasidir. Yazim ani = PROJE_HAFIZA.md'yi
                 son degistiren commit (not commit'lenmemisse calisma agaci).
                 Bu ayrim yapilmadan arac her oturum kirmizi yanar ve KOR KAPIYA
                 doner -- olculdu: ilk kosum uc kirmizi verdi, biri gercek kusur,
                 biri yapisal, biri YANLIS-POZITIFTI.

  [OTURUM SAGLIGI HUKMU] -- yalniz --transcript verilirse kosar
    S4 TOKEN   : canli baglam = son mesajin input + cache_read + cache_creation.
                 Renk MUTLAK esikten hesaplanir; PAYDA KULLANILMAZ.
    S5 PAYDA   : olculen canli baglam varsayilan pencereden BUYUKSE, o pencere
                 varsayimi OLUDUR -> renk ILAN EDILMEZ, Onur'a soylenir.
    --transcript verilmezse hukum "OLCULMEDI"dir. YESIL DEGILDIR.

CIKIS KODLARI:
    0 = iki hukum de YESIL (transcript verildi ve olculdu)
    1 = SARI
    2 = KIRMIZI
    3 = ORTAM HATASI (kok/dosya yok)
    4 = kanonik/D1 YESIL ama OTURUM SAGLIGI OLCULMEDI (transcript verilmedi)
        -- ayri kod, cunku 0 "olculdu ve saglikli" demektir; 4 onu demez.

BEYAN EDILMIS SINIRLAR (gizlenmis degil):
  * Defterin BAYT-DISK karsilastirmasi radar.py'nin D1'idir ve BURADA
    TEKRARLANMAZ. Bu aracin defter ayagi ZAMAN ayagidir; defter yalniz GUN
    cozunurlugu tasidigi icin AYNI GUN yazilan bayat kaydi GOREMEZ.
  * S2 yalniz RAKAMLI yuzde arar ("%62"). "yuzde altmis iki" diye yazan eli
    yakalamaz.
  * Kimlik blogunda ciplak dosya adi varsa depo taranir; sifir ya da birden
    fazla eslesme "OLCULEMEDI"dir -- "TEMIZ" DEGILDIR.
  * Devir ayagi GIT'e bagimlidir. git okunamazsa "OLCULEMEDI" der, TEMIZ demez.
  * core.autocrlf bu depoda AKTIF: CRLF tasiyan bir dosyada blob-calisma agaci
    bayt karsilastirmasi KORDUR ⇒ o giris "OLCULEMEDI" isaretlenir, gecirilmez.
  * Bir devir notu KENDI KABININ (PROJE_HAFIZA.md) kimligini dogru yazamaz --
    notu yazmak dosyayi buyutur. Bu 'D1-OZ' koduyla SARI raporlanir, KIRMIZI
    degil; cunku kusur eldeki degil KURALDADIR (not kendi kabini beyan etmemeli).
  * Bu arac hicbir dosyaya YAZMAZ (K60 kapsamina girmez).

KULLANIM:
    python araclar\\oturum-sagligi.py .
    python araclar\\oturum-sagligi.py . --transcript <yol.jsonl>
    python araclar\\oturum-sagligi.py --altin-kume
"""
import hashlib
import json
import os
import re
import sys
import tempfile
import time

try:  # ortam kusuru: bu makinede stdout cp1254, "=>" gibi karakter kabugu olduruyor
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

SURUM = "1.0.0"

# --------------------------------------------------------------------------
# KANONIK SABITLER -- CLAUDE.md'nin K21 blogu ile AYNI olmak ZORUNDA.
# Bu araci degistiren el, CLAUDE.md'yi de degistirmemisse S1 ISIRIR. Kasit bu.
# --------------------------------------------------------------------------
KANONIK_YESIL_UST = 550_000    # < 550k  : DEVAM
KANONIK_SARI_UST = 750_000     # 550k-750k : bitir + checkpoint
VARSAYILAN_PENCERE = 1_000_000  # K21 esikleri bu pencere beyanindan turedi

# S2/S3'un tarayacagi CANLI belgeler (arsiv PROJE_HAFIZA.md DAHIL DEGIL:
# append-only tarihce, gecmiste yazilmis yuzde bir KAYITTIR, iddia degil).
CANLI_BELGELER = ["DURUM.md", "CLAUDE.md", "DESIGN.md"]

BAGLAM_ANAHTARLARI = ("baglam", "token", "oturum sagligi", "pencere",
                      "canli baglam", "devir esigi", "kapasite")

TARAMA_HARIC = (".git", "build", ".dart_tool", "node_modules", ".idea",
                ".gradle", "obj", "bin", "KANIT")


def fold(s):
    """Turkce harfleri ASCII'ye indirger (desen eslesmesi icin)."""
    tablo = {"c": "cC", "g": "gG", "i": "iI", "o": "oO", "s": "sS", "u": "uU"}
    del tablo
    esle = {"ç": "c", "Ç": "c", "ğ": "g", "Ğ": "g",
            "ı": "i", "İ": "i", "ö": "o", "Ö": "o",
            "ş": "s", "Ş": "s", "ü": "u", "Ü": "u"}
    return "".join(esle.get(ch, ch) for ch in s).lower()


def oku(yol):
    with open(yol, "rb") as f:
        return f.read().decode("utf-8", errors="replace")


def sha8(yol):
    with open(yol, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()[:8].upper()


def sayiya(metin):
    """'550', '18.075', '18,075' -> int. Binlik ayraci nokta VE virgul."""
    return int(re.sub(r"[.,\s]", "", metin))


# ==========================================================================
# S1 -- KANONIK ESIK KARSILASTIRMASI
# ==========================================================================
def k21_blogu(claude_metni):
    """CLAUDE.md'de K21 gecen '## ' basligini ve govdesini dondurur."""
    satirlar = claude_metni.splitlines()
    bas = None
    for i, s in enumerate(satirlar):
        if s.startswith("## ") and "K21" in s:
            bas = i
            break
    if bas is None:
        return None
    son = len(satirlar)
    for j in range(bas + 1, len(satirlar)):
        if satirlar[j].startswith("## "):
            son = j
            break
    return "\n".join(satirlar[bas:son])


def kanonik_esikleri_ayristir(blok):
    """Renk isaretlerine BITISIK esikleri okur. Donen: (dict, hata_listesi)."""
    hatalar = []
    d = {}
    m = re.search(r"\U0001F7E2[^\n]*?<\s*([\d.,]+)\s*k", blok)
    if m:
        d["yesil_ust"] = sayiya(m.group(1)) * 1000
    else:
        hatalar.append("YESIL esigi ayristirilamadi (beklenen: '< NNNk')")
    m = re.search(r"\U0001F7E1[^\n]*?([\d.,]+)\s*k\s*[–—-]\s*([\d.,]+)\s*k", blok)
    if m:
        d["sari_alt"] = sayiya(m.group(1)) * 1000
        d["sari_ust"] = sayiya(m.group(2)) * 1000
    else:
        hatalar.append("SARI araligi ayristirilamadi (beklenen: 'NNNk-NNNk')")
    m = re.search(r"\U0001F534[^\n]*?>\s*([\d.,]+)\s*k", blok)
    if m:
        d["kirmizi_alt"] = sayiya(m.group(1)) * 1000
    else:
        hatalar.append("KIRMIZI esigi ayristirilamadi (beklenen: '> NNNk')")
    return d, hatalar


def s1_kanonik(kok, bulgular):
    yol = os.path.join(kok, "CLAUDE.md")
    if not os.path.isfile(yol):
        bulgular.append(("KIRMIZI", "S1", "CLAUDE.md YOK -- kanonik kaynak kayip."))
        return
    blok = k21_blogu(oku(yol))
    if blok is None:
        bulgular.append(("KIRMIZI", "S1",
                         "CLAUDE.md'de 'K21' gecen '## ' basligi YOK -- kanonik "
                         "blok kayip ya da yeniden adlandirilmis."))
        return
    d, hatalar = kanonik_esikleri_ayristir(blok)
    for h in hatalar:
        bulgular.append(("KIRMIZI", "S1", "KANONIK BLOK BOZUK: " + h))
    if hatalar:
        return
    if d["yesil_ust"] != d["sari_alt"]:
        bulgular.append(("KIRMIZI", "S1",
                         "KANONIK BLOK KENDI ICINDE TUTARSIZ: yesil ust sinir "
                         "%d, sari alt sinir %d." % (d["yesil_ust"], d["sari_alt"])))
    if d["sari_ust"] != d["kirmizi_alt"]:
        bulgular.append(("KIRMIZI", "S1",
                         "KANONIK BLOK KENDI ICINDE TUTARSIZ: sari ust sinir "
                         "%d, kirmizi alt sinir %d." % (d["sari_ust"], d["kirmizi_alt"])))
    if d["yesil_ust"] != KANONIK_YESIL_UST:
        bulgular.append(("KIRMIZI", "S1",
                         "ESIK SAPMASI: CLAUDE.md yesil ust siniri %d diyor, arac "
                         "%d tutuyor. Biri digerinden habersiz degistirilmis."
                         % (d["yesil_ust"], KANONIK_YESIL_UST)))
    if d["sari_ust"] != KANONIK_SARI_UST:
        bulgular.append(("KIRMIZI", "S1",
                         "ESIK SAPMASI: CLAUDE.md sari ust siniri %d diyor, arac "
                         "%d tutuyor." % (d["sari_ust"], KANONIK_SARI_UST)))
    if not any(k == "S1" for _, k, _ in bulgular):
        bulgular.append(("BILGI", "S1",
                         "kanonik esikler tutuyor: yesil<%d, sari %d-%d, kirmizi>%d"
                         % (KANONIK_YESIL_UST, KANONIK_YESIL_UST,
                            KANONIK_SARI_UST, KANONIK_SARI_UST)))


# ==========================================================================
# S2 -- YUZDE AVI  (K21: "Yuzde yazan el paydayi uydurmustur")
# ==========================================================================
YUZDE_DESENI = re.compile(r"(%\s*\d+(?:[.,]\d+)?|\d+(?:[.,]\d+)?\s*%)")


def s2_yuzde(kok, belgeler, bulgular):
    vuruldu = False
    for ad in belgeler:
        yol = os.path.join(kok, ad)
        if not os.path.isfile(yol):
            continue
        for no, satir in enumerate(oku(yol).splitlines(), 1):
            if not YUZDE_DESENI.search(satir):
                continue
            f = fold(satir)
            if any(a in f for a in BAGLAM_ANAHTARLARI):
                vuruldu = True
                bulgular.append(("KIRMIZI", "S2",
                                 "%s:%d oturum-sagligi baglaminda YUZDE yaziyor "
                                 "-- K21: yuzde yazan el paydayi uydurmustur. "
                                 "Satir: %s" % (ad, no, satir.strip()[:110])))
    if not vuruldu:
        bulgular.append(("BILGI", "S2",
                         "canli belgelerde oturum-sagligi baglaminda rakamli "
                         "yuzde YOK."))


# ==========================================================================
# S3 -- KANONIK ESIK KOPYASI AVI
# ==========================================================================
def esik_desenleri():
    d = []
    for v in (KANONIK_YESIL_UST, KANONIK_SARI_UST):
        bin_k = v // 1000
        d.append(re.compile(r"\b%dk\b" % bin_k))
        d.append(re.compile(r"\b%d[.,]000\b" % bin_k))
        d.append(re.compile(r"\b%d\b" % v))
    return d


def s3_kopya(kok, belgeler, bulgular):
    desenler = esik_desenleri()
    vuruldu = False
    for ad in belgeler:
        if ad == "CLAUDE.md":
            continue  # kanonik kaynak: burada BULUNMASI gerekir
        yol = os.path.join(kok, ad)
        if not os.path.isfile(yol):
            continue
        for no, satir in enumerate(oku(yol).splitlines(), 1):
            for dsn in desenler:
                if dsn.search(satir):
                    vuruldu = True
                    bulgular.append(("KIRMIZI", "S3",
                                     "%s:%d KANONIK ESIK KOPYALANMIS -- K21: "
                                     "esikler BASKA HICBIR DOSYAYA kopyalanmaz. "
                                     "Satir: %s" % (ad, no, satir.strip()[:110])))
                    break
    if not vuruldu:
        bulgular.append(("BILGI", "S3",
                         "kanonik esikler CLAUDE.md disinda hicbir canli "
                         "belgede gecmiyor."))


# ==========================================================================
# S4 / S5 -- TOKEN VE PAYDA YANLISLAMA
# ==========================================================================
def transcript_olc(yol):
    """Son 'usage' tasiyan mesajin MUTLAK canli baglamini dondurur."""
    son = None
    satir_sayisi = 0
    with open(yol, "rb") as f:
        for ham in f:
            s = ham.decode("utf-8", errors="replace").strip()
            if not s:
                continue
            satir_sayisi += 1
            try:
                d = json.loads(s)
            except ValueError:
                continue
            msg = d.get("message")
            if not isinstance(msg, dict):
                continue
            u = msg.get("usage")
            if isinstance(u, dict):
                son = u
    if son is None:
        return None, satir_sayisi
    toplam = (int(son.get("input_tokens", 0) or 0)
              + int(son.get("cache_read_input_tokens", 0) or 0)
              + int(son.get("cache_creation_input_tokens", 0) or 0))
    return toplam, satir_sayisi


def renk_mutlak(toplam):
    if toplam < KANONIK_YESIL_UST:
        return "YESIL"
    if toplam <= KANONIK_SARI_UST:
        return "SARI"
    return "KIRMIZI"


def s4_s5(transcript, pencere, bulgular):
    """Donen: 'OLCULMEDI' | 'YESIL' | 'SARI' | 'KIRMIZI'."""
    if not transcript:
        bulgular.append(("OLCULMEDI", "S4",
                         "--transcript verilmedi ⇒ canli baglam OLCULMEDI. "
                         "K21: olcemezsen yesil de kirmizi da VARSAYMA."))
        return "OLCULMEDI"
    if not os.path.isfile(transcript):
        bulgular.append(("KIRMIZI", "S4",
                         "transcript yolu YOK: %s" % transcript))
        return "KIRMIZI"
    toplam, satir = transcript_olc(transcript)
    if toplam is None:
        bulgular.append(("OLCULMEDI", "S4",
                         "transcript'te 'usage' tasiyan mesaj YOK (%d satir "
                         "okundu) ⇒ OLCULMEDI." % satir))
        return "OLCULMEDI"
    if toplam >= pencere:
        bulgular.append(("KIRMIZI", "S5",
                         "PAYDA YANLISLAMA TESTI ISIRDI: olculen canli baglam "
                         "%d, varsayilan pencere %d. Pencere varsayimi OLUDUR "
                         "⇒ RENK ILAN EDILMEZ, Onur'a soylenir."
                         % (toplam, pencere)))
        return "KIRMIZI"
    renk = renk_mutlak(toplam)
    seviye = {"YESIL": "BILGI", "SARI": "SARI", "KIRMIZI": "KIRMIZI"}[renk]
    bulgular.append((seviye, "S4",
                     "canli baglam MUTLAK %d token (%d satir) ⇒ %s "
                     "(esikler: <%d yesil, %d-%d sari, >%d kirmizi)"
                     % (toplam, satir, renk, KANONIK_YESIL_UST,
                        KANONIK_YESIL_UST, KANONIK_SARI_UST, KANONIK_SARI_UST)))
    return renk


# ==========================================================================
# D1 -- TAZELIK: "kayit, dosyanin SON yazimindan ONCE mi yazilmis?"
# ==========================================================================
def yolu_coz(kok, ad):
    """Ciplak dosya adini depoda arar. Donen: (yol|None, durum)."""
    ad = ad.replace("\\", "/").strip()
    if "/" in ad:
        tam = os.path.join(kok, ad.replace("/", os.sep))
        return (tam, "TAM") if os.path.isfile(tam) else (None, "YOK")
    hedef = os.path.basename(ad)
    bulunan = []
    for dizin, altlar, dosyalar in os.walk(kok):
        altlar[:] = [a for a in altlar if a not in TARAMA_HARIC]
        if hedef in dosyalar:
            bulunan.append(os.path.join(dizin, hedef))
        if len(bulunan) > 1:
            break
    if len(bulunan) == 1:
        return bulunan[0], "TEK"
    if not bulunan:
        return None, "YOK"
    return None, "COKLU"


def kimlik_karsilastir(kok, kaynak, girisler, bulgular):
    """girisler: [(ad, beyan_bayt, beyan_sha8|None, satir_no)]"""
    if not girisler:
        bulgular.append(("OLCULEMEDI", "D1",
                         "%s: kimlik girisi AYRISTIRILAMADI ⇒ OLCULEMEDI "
                         "(bu 'TEMIZ' DEGILDIR)." % kaynak))
        return
    temiz = 0
    for ad, beyan_b, beyan_s, no in girisler:
        yol, durum = yolu_coz(kok, ad)
        if yol is None:
            bulgular.append(("OLCULEMEDI", "D1",
                             "%s:%s '%s' adi %s ⇒ OLCULEMEDI (TEMIZ degil)."
                             % (kaynak, no, ad,
                                "depoda YOK" if durum == "YOK"
                                else "BIRDEN FAZLA dosyayla eslesti")))
            continue
        gercek_b = os.path.getsize(yol)
        if gercek_b != beyan_b:
            bulgular.append(("KIRMIZI", "D1",
                             "%s:%s BAYAT KIMLIK -- '%s' beyan %d b, disk %d b "
                             "(fark %+d). Kayit, dosyanin SON yazimindan ONCE "
                             "yazilmis." % (kaynak, no, ad, beyan_b, gercek_b,
                                            gercek_b - beyan_b)))
            continue
        if beyan_s:
            gercek_s = sha8(yol)
            if gercek_s != beyan_s.upper():
                bulgular.append(("KIRMIZI", "D1",
                                 "%s:%s BAYAT KIMLIK -- '%s' bayt TUTUYOR ama "
                                 "sha8 beyan %s, disk %s. Ayni boyutta degismis."
                                 % (kaynak, no, ad, beyan_s.upper(), gercek_s)))
                continue
        temiz += 1
    if temiz:
        bulgular.append(("BILGI", "D1",
                         "%s: %d kimlik girisi diskle TUTUYOR." % (kaynak, temiz)))


TABLO_SATIRI = re.compile(r"^\|(.+)\|\s*$")


# K151 (6 Agu 2026) DURUM.md 9. bolumunu KIMLIKLER.md'ye TASIDI. Kapsam bu yuzden bir
# LISTEDIR, tek dosya adi DEGIL -- hangi belge tabloyu tasiyorsa oradan okunur.
KIMLIK_TABLOSU_BELGELERI = ("KIMLIKLER.md", "DURUM.md")


def _kimlik_tablosu_girisleri(yol):
    girisler = []
    for no, satir in enumerate(oku(yol).splitlines(), 1):
        m = TABLO_SATIRI.match(satir)
        if not m:
            continue
        hucreler = [h.strip() for h in m.group(1).split("|")]
        if len(hucreler) < 3:
            continue
        ad_m = re.search(r"`([^`]+)`", hucreler[0])
        bayt_m = re.search(r"(\d[\d.,]*)", hucreler[1])
        sha_m = re.search(r"([0-9A-Fa-f]{8})", hucreler[2])
        if not (ad_m and bayt_m and sha_m):
            continue
        if not re.search(r"\.[A-Za-z0-9]+$", ad_m.group(1).strip()):
            continue
        girisler.append((ad_m.group(1).strip(), sayiya(bayt_m.group(1)),
                         sha_m.group(1), no))
    return girisler


def d1_durum_tablosu(kok, bulgular):
    """K157 (oturum 62): kimlik tablosu ARTIK DURUM.md'de degil KIMLIKLER.md'de.

    Bu fonksiyon K151'den oturum 62'ye kadar yalniz DURUM.md'ye bakti ve her kosumda
    'AYRISTIRILAMADI => OLCULEMEDI' dedi: bir siniri TASIYAN el, o siniri OKUYAN araci
    tasimadigi icin D1'in kimlik ayagi KOR kaldi. Kapsam artik bir listedir; TABLOYU
    TASIYAN HER BELGE olculur ve OLCULEMEDI yalnizca HICBIRINDE giris yoksa yazilir --
    aksi halde tablosuz kalan DURUM.md kalici bir yanlis-pozitif uretirdi."""
    bulunan, olculdu = [], False
    for ad in KIMLIK_TABLOSU_BELGELERI:
        yol = os.path.join(kok, ad)
        if not os.path.isfile(yol):
            continue
        bulunan.append(ad)
        girisler = _kimlik_tablosu_girisleri(yol)
        if girisler:
            olculdu = True
            kimlik_karsilastir(kok, "%s kimlik tablosu" % ad, girisler, bulgular)
    if olculdu:
        return
    if not bulunan:
        bulgular.append(("OLCULEMEDI", "D1",
                         "kimlik tablosu belgesi YOK (%s aranmisti) \u21d2 OLCULEMEDI."
                         % ", ".join(KIMLIK_TABLOSU_BELGELERI)))
        return
    bulgular.append(("OLCULEMEDI", "D1",
                     "%s: kimlik girisi AYRISTIRILAMADI \u21d2 OLCULEMEDI "
                     "(bu 'TEMIZ' DEGILDIR)." % " + ".join(bulunan)))


DEVIR_GIRISI = re.compile(
    r"([A-Za-z0-9_][A-Za-z0-9_\-./\\]*\.[A-Za-z0-9]+)\s+(\d[\d.,]*)\s*b\b"
    r"(?:\s*[·|\-]\s*([0-9A-Fa-f]{8})\b)?")


def git_calistir(kok, args, ikili=False):
    """git'i --no-optional-locks ile kosar. Donen: (cikti|None, hata|None)."""
    import subprocess
    try:
        p = subprocess.run(["git", "-C", kok, "--no-optional-locks"] + args,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                           timeout=60)
    except Exception as e:  # git yok, PATH'te degil, zaman asimi
        return None, str(e)
    if p.returncode != 0:
        return None, p.stderr.decode("utf-8", errors="replace").strip()[:120]
    return (p.stdout if ikili else p.stdout.decode("utf-8", errors="replace")), None


def yazim_ani_kimlik(kok, commit, yol):
    """Dosyanin <commit> anindaki (bayt, sha8) kimligi. Donen: (kimlik, hata)."""
    rel = os.path.relpath(yol, kok).replace("\\", "/")
    ham, hata = git_calistir(kok, ["show", "%s:%s" % (commit, rel)], ikili=True)
    if ham is None:
        return None, hata or "git show basarisiz"
    return (len(ham), hashlib.sha256(ham).hexdigest()[:8].upper()), None


def d1_devir_blogu(kok, bulgular):
    yol = os.path.join(kok, "PROJE_HAFIZA.md")
    if not os.path.isfile(yol):
        bulgular.append(("OLCULEMEDI", "D1",
                         "PROJE_HAFIZA.md YOK ⇒ devir kimlik blogu OLCULEMEDI."))
        return
    satirlar = oku(yol).splitlines()
    bas = None
    for i, s in enumerate(satirlar):
        f = fold(s)
        if "dosya" in f and "kimlik" in f:
            bas = i
            break
    if bas is None:
        bulgular.append(("OLCULEMEDI", "D1",
                         "PROJE_HAFIZA.md'de 'DOSYA KIMLIKLERI' blogu BULUNAMADI "
                         "⇒ OLCULEMEDI (TEMIZ degil)."))
        return
    girisler = []
    bosluk = 0
    for j in range(bas, min(bas + 16, len(satirlar))):
        bulundu = DEVIR_GIRISI.findall(satirlar[j])
        if bulundu:
            bosluk = 0
            for ad, b, s in bulundu:
                girisler.append((ad, sayiya(b), s or None, j + 1))
        elif girisler:
            bosluk += 1
            if bosluk >= 2:
                break
    devir_karsilastir(kok, yol, girisler, bulgular)


def devir_karsilastir(kok, hafiza_yolu, girisler, bulgular):
    """Devir notunun kimlik beyanini YAZIM ANINDAKI dosya haliyle karsilastirir.

    Kritik ayrim (ilk gercek kosumda olculdu, oturum 38): bir devir notu
    zamanla "bayat" gorunur cunku SONRAKI oturumlar dosyalari degistirir. Bu
    KUSUR DEGILDIR. Kusur, kaydin YAZILDIGI AN zaten bayat olmasidir. Yazim ani
    = PROJE_HAFIZA.md'yi son degistiren commit. Bu ayrim yapilmazsa kapi her
    oturum kirmizi yanar ve KOR KAPIYA doner.
    """
    kaynak = "DEVIR notu kimlik blogu"
    if not girisler:
        bulgular.append(("OLCULEMEDI", "D1",
                         "%s: kimlik girisi AYRISTIRILAMADI ⇒ OLCULEMEDI "
                         "(bu 'TEMIZ' DEGILDIR)." % kaynak))
        return
    # YAZIM ANI = NOTU EKLEYEN commit -- dosyanin BUGUN kirli olmasi, NOTUN
    # commit'lenmemis oldugu anlamina GELMEZ. (Olculdu, oturum 38: arsive YENI
    # bir checkpoint eklemek PROJE_HAFIZA.md'yi kirletti ve arac eski, commit'li
    # devir notunu 'commit'lenmemis' sanip calisma agaciyla karsilastirdi ⇒
    # YANLIS-POZITIF geri geldi. Kirlilik testi bu isin OLCUSU DEGILDIR.)
    imza = None
    for ad, b, s, no in girisler:
        if s:
            imza = s
            break
    if imza is None:
        imza = "%s %s b" % (girisler[0][0], girisler[0][1])
    cikti, hata = git_calistir(kok, ["log", "-1", "--format=%H",
                                     "-S", imza, "--", os.path.basename(hafiza_yolu)])
    if cikti is None:
        bulgular.append(("OLCULEMEDI", "D1",
                         "%s: git okunamadi (%s) ⇒ YAZIM ANI olculemedi. Beyan "
                         "DOGRULANMADI (TEMIZ degil)." % (kaynak, hata)))
        return
    commit = cikti.strip() or None  # bos ⇒ not hicbir commit'te yok = yazilmamis
    temiz, sonradan = 0, 0
    for ad, beyan_b, beyan_s, no in girisler:
        p, durum = yolu_coz(kok, ad)
        if p is None:
            bulgular.append(("OLCULEMEDI", "D1",
                             "%s:%s '%s' adi %s ⇒ OLCULEMEDI (TEMIZ degil)."
                             % (kaynak, no, ad, "depoda YOK" if durum == "YOK"
                                else "BIRDEN FAZLA dosyayla eslesti")))
            continue
        with open(p, "rb") as f:
            ham = f.read()
        if commit is None:
            o_bayt, o_sha = len(ham), hashlib.sha256(ham).hexdigest()[:8].upper()
        else:
            if b"\r\n" in ham:
                bulgular.append(("OLCULEMEDI", "D1",
                                 "%s:%s '%s' CRLF tasiyor; core.autocrlf yuzunden "
                                 "blob-calisma agaci bayt karsilastirmasi KORDUR "
                                 "⇒ OLCULEMEDI." % (kaynak, no, ad)))
                continue
            kimlik, hata = yazim_ani_kimlik(kok, commit, p)
            if kimlik is None:
                bulgular.append(("OLCULEMEDI", "D1",
                                 "%s:%s '%s' yazim ani commit'inde OKUNAMADI (%s) "
                                 "⇒ OLCULEMEDI." % (kaynak, no, ad, hata)))
                continue
            o_bayt, o_sha = kimlik
        kendi_kabi = os.path.abspath(p) == os.path.abspath(hafiza_yolu)
        sapma = (o_bayt != beyan_b) or (beyan_s and beyan_s.upper() != o_sha)
        if sapma and kendi_kabi:
            bulgular.append(("SARI", "D1-OZ",
                             "%s:%s '%s' KENDI KABINI beyan ediyor: beyan %d b, "
                             "yazim aninda %d b. Bu YAPISAL olarak imkansizdir "
                             "-- notu yazmak dosyayi buyutur. Kural: devir notu "
                             "kendi kabinin kimligini YAZMAZ."
                             % (kaynak, no, ad, beyan_b, o_bayt)))
            continue
        if sapma:
            bulgular.append(("KIRMIZI", "D1",
                             "%s:%s YAZIM ANINDA BAYAT -- '%s' beyan %d b/%s, "
                             "kaydin yazildigi an %d b/%s. Kimlik son yazimdan "
                             "ONCE olculmus."
                             % (kaynak, no, ad, beyan_b, beyan_s or "-", o_bayt, o_sha)))
            continue
        temiz += 1
        if len(ham) != o_bayt:
            sonradan += 1
    if temiz:
        bulgular.append(("BILGI", "D1",
                         "%s: %d giris YAZIM ANINDA dogruydu (%d tanesi sonradan "
                         "degisti -- bu kusur DEGIL). Yazim ani: %s"
                         % (kaynak, temiz, sonradan, commit[:7] if commit
                            else "commit'lenmemis (calisma agaci)")))


def d1_defter_zaman(kok, bulgular):
    """ZAMAN ayagi. BAYT-disk karsilastirmasi radar.py'nin D1'idir, burada YOK."""
    yol = os.path.join(kok, "PROJE_RADAR.jsonl")
    if not os.path.isfile(yol):
        bulgular.append(("OLCULEMEDI", "D1",
                         "PROJE_RADAR.jsonl YOK ⇒ defter zaman ayagi OLCULEMEDI."))
        return
    son_kayit = {}
    with open(yol, "rb") as f:
        for no, ham in enumerate(f, 1):
            s = ham.decode("utf-8", errors="replace").strip()
            if not s:
                continue
            try:
                d = json.loads(s)
            except ValueError:
                continue
            art = d.get("artefakt")
            tar = d.get("tarih")
            if art and tar:
                son_kayit[art] = (tar, no)
    if not son_kayit:
        bulgular.append(("OLCULEMEDI", "D1",
                         "defterde 'artefakt'+'tarih' tasiyan kayit YOK ⇒ OLCULEMEDI."))
        return
    bayat, olculen = 0, 0
    for art, (tar, no) in sorted(son_kayit.items()):
        p, durum = yolu_coz(kok, art)
        if p is None:
            continue  # etiket olabilir (D1 defterde KOR -- DURUM 8'de yazili)
        olculen += 1
        try:
            dosya_gun = time.strftime("%Y-%m-%d", time.localtime(os.path.getmtime(p)))
        except OSError:
            continue
        if dosya_gun > tar:
            bayat += 1
            bulgular.append(("SARI", "D1",
                             "defter:%d '%s' SON kaydi %s tarihli ama dosya %s "
                             "gununde yeniden yazilmis ⇒ o kaydin bayt beyani "
                             "yapisal olarak BAYAT." % (no, art, tar, dosya_gun)))
    bulgular.append(("BILGI", "D1",
                     "defter zaman ayagi: %d artefakt olculdu, %d bayat. "
                     "BEYAN EDILMIS SINIR: defter GUN cozunurlugu tasir, AYNI GUN "
                     "yazilan bayat kayit GORUNMEZ." % (olculen, bayat)))


# ==========================================================================
# KOSUM + HUKUM
# ==========================================================================
def tara(kok, transcript=None, pencere=VARSAYILAN_PENCERE, belgeler=None):
    belgeler = belgeler or CANLI_BELGELER
    bulgular = []
    s1_kanonik(kok, bulgular)
    s2_yuzde(kok, belgeler, bulgular)
    s3_kopya(kok, belgeler, bulgular)
    d1_durum_tablosu(kok, bulgular)
    d1_devir_blogu(kok, bulgular)
    d1_defter_zaman(kok, bulgular)
    saglik = s4_s5(transcript, pencere, bulgular)
    return bulgular, saglik


def hukumler(bulgular, saglik):
    yapisal = [b for b in bulgular if b[1] in ("S1", "S2", "S3", "D1")]
    if any(s == "KIRMIZI" for s, _, _ in yapisal):
        h1 = "KIRMIZI"
    elif any(s in ("SARI", "OLCULEMEDI") for s, _, _ in yapisal):
        h1 = "SARI"
    else:
        h1 = "YESIL"
    return h1, saglik


def cikis_kodu(h1, saglik):
    if h1 == "KIRMIZI" or saglik == "KIRMIZI":
        return 2
    if saglik == "OLCULMEDI":
        return 1 if h1 == "SARI" else 4
    if h1 == "SARI" or saglik == "SARI":
        return 1
    return 0


def yazdir(bulgular, h1, saglik):
    print("=" * 78)
    print("OTURUM SAGLIGI KAPISI %s -- K21'in mekanik kapisi" % SURUM)
    print("=" * 78)
    sira = {"KIRMIZI": 0, "SARI": 1, "OLCULMEDI": 2, "OLCULEMEDI": 2, "BILGI": 3}
    for seviye, kod, mesaj in sorted(bulgular, key=lambda b: (sira.get(b[0], 9), b[1])):
        print("  [%s] %s: %s" % (seviye, kod, mesaj))
    print("-" * 78)
    print("HUKUM (KANONIK+D1)   : %s" % h1)
    print("HUKUM (OTURUM SAGLIGI): %s" % saglik)
    if saglik == "OLCULMEDI":
        print("  >> OLCULMEDI YESIL DEGILDIR. Transcript verilmeden bu oturumun")
        print("     sagligi hakkinda hicbir renk ilan EDILEMEZ (K21).")
    print("=" * 78)


# ==========================================================================
# ALTIN KUME -- ARAC ONCE KENDINI KANITLAR (KOR KAPI YOK)
# ==========================================================================
KANONIK_BLOK_TEMIZ = (
    "## Oturum sagligi ve devir [K21 -- PAZARLIKSIZ]\n"
    "Devir karari olculur.\n"
    "\U0001F7E2 **< 550k: DEVAM** · \U0001F7E1 **550k–750k:** bitir · "
    "\U0001F534 **> 750k:** kapat\n"
    "## Sonraki bolum\n")


def _fixture(icerik_haritasi):
    d = tempfile.mkdtemp(prefix="oturum-sagligi-altin-")
    for ad, icerik in icerik_haritasi.items():
        tam = os.path.join(d, ad.replace("/", os.sep))
        os.makedirs(os.path.dirname(tam), exist_ok=True)
        with open(tam, "wb") as f:
            f.write(icerik.encode("utf-8") if isinstance(icerik, str) else icerik)
    return d


def _jsonl(toplam):
    kayit = {"message": {"usage": {"input_tokens": 2,
                                   "cache_read_input_tokens": toplam - 2,
                                   "cache_creation_input_tokens": 0}}}
    return json.dumps(kayit) + "\n"


def _git_depo(icerik, sonradan=None, commitle_hafizayi=True):
    """Fixture'i GERCEK bir git deposu yapar (yazim ani ayagi olculebilsin).

    sonradan: commit'ten SONRA yazilacak icerik (calisma agaci degisir, commit
    edilmez) -- 'kayit dogruydu, dosya sonradan degisti' vakasi icin.
    """
    import subprocess
    d = _fixture(icerik)
    ortak = ["git", "-C", d, "-c", "user.email=a@b.c", "-c", "user.name=altin",
             "-c", "core.autocrlf=false", "-c", "commit.gpgsign=false"]
    for args in (["init", "-q"], ["add", "-A"], ["commit", "-q", "-m", "altin"]):
        p = subprocess.run(ortak + args, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
        if p.returncode != 0 and args[0] != "init":
            raise RuntimeError("fixture git hatasi: " + p.stderr.decode("utf-8", "replace"))
    for ad, ic in (sonradan or {}).items():
        with open(os.path.join(d, ad), "wb") as f:
            f.write(ic.encode("utf-8") if isinstance(ic, str) else ic)
    if not commitle_hafizayi:
        with open(os.path.join(d, "PROJE_HAFIZA.md"), "a", encoding="utf-8") as f:
            f.write("\ncommit'lenmemis ek satir\n")
    return d


def _temiz_depo(ek=None):
    """Dort D1 kaynagi da TAZE olan bir fixture depo uretir."""
    veri = "abcdefghij"
    s = hashlib.sha256(veri.encode("utf-8")).hexdigest()[:8].upper()
    icerik = {
        "CLAUDE.md": KANONIK_BLOK_TEMIZ,
        "veri.txt": veri,
        "DURUM.md": ("| dosya | bayt | sha8 | neden |\n|---|---|---|---|\n"
                     "| `veri.txt` | **10** | **`%s`** | test |\n" % s),
        "PROJE_HAFIZA.md": ("DOSYA KIMLIKLERI (son yazimdan SONRA olculdu):\n"
                            "  veri.txt 10 b · %s\n" % s),
        "PROJE_RADAR.jsonl": json.dumps(
            {"tarih": "2099-01-01", "artefakt": "veri.txt", "tur": 1}) + "\n",
    }
    icerik.update(ek or {})
    return _git_depo(icerik)


def _kodlar(bulgular, kod):
    return [b for b in bulgular if b[1] == kod]


def _isirdi(bulgular, kod, seviye="KIRMIZI"):
    return any(b[0] == seviye for b in _kodlar(bulgular, kod))


def _ayristirilamadi(bulgular):
    """K157: 'AYRISTIRILAMADI' yanlis-pozitifini vaka duzeyinde olcer."""
    return any(b[1] == "D1" and "AYRISTIRILAMADI" in b[2] for b in bulgular)


def altin_kume():
    vakalar = []

    def vaka(ad, kosul, ayrinti=""):
        vakalar.append((ad, bool(kosul), ayrinti))

    # --- S1 -----------------------------------------------------------
    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ})
    b, _ = tara(kok)
    vaka("1) KANONIK TEMIZ -- S1 SUSMALI", not _isirdi(b, "S1"))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ.replace("550k", "500k")
                                                   .replace("750k", "700k")})
    b, _ = tara(kok)
    vaka("2) KANONIK SAPMIS (500k/700k) -- S1 ISIRMALI", _isirdi(b, "S1"))

    kok = _fixture({"CLAUDE.md": "## Baska baslik\nhicbir sey\n"})
    b, _ = tara(kok)
    vaka("3) K21 BLOGU YOK -- S1 ISIRMALI", _isirdi(b, "S1"))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ.replace(
        "**550k–750k:**", "**600k–750k:**")})
    b, _ = tara(kok)
    vaka("4) BLOK KENDI ICINDE TUTARSIZ -- S1 ISIRMALI", _isirdi(b, "S1"))

    # --- S2 -----------------------------------------------------------
    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ,
                    "DURUM.md": "Baglam %62 dolu, devam edilebilir.\n"})
    b, _ = tara(kok)
    vaka("5) YUZDE + BAGLAM -- S2 ISIRMALI", _isirdi(b, "S2"))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ,
                    "DURUM.md": "canli belge %10 budanabilir; tavan 32 KB.\n"})
    b, _ = tara(kok)
    vaka("6) YUZDE ama BAGLAM DISI -- S2 SUSMALI (yanlis-pozitif kontrolu)",
         not _isirdi(b, "S2"))

    # --- S3 -----------------------------------------------------------
    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ,
                    "DURUM.md": "Esik: 550k asilirsa devret.\n"})
    b, _ = tara(kok)
    vaka("7) ESIK KOPYALANMIS -- S3 ISIRMALI", _isirdi(b, "S3"))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ,
                    "DURUM.md": "Kanonik esikler YALNIZ CLAUDE.md'de.\n"})
    b, _ = tara(kok)
    vaka("8) ESIK ATFI ama SAYI YOK -- S3 SUSMALI (yanlis-pozitif kontrolu)",
         not _isirdi(b, "S3"))

    # --- S4 / S5 -------------------------------------------------------
    # Not: cikis 4'u olcebilmek icin D1 kaynaklarinin da TEMIZ olmasi gerekir;
    # eksik kaynak dogru olarak SARI uretir (vaka 9 ilk kurguda bu yuzden dustu).
    kok = _temiz_depo()
    b, s = tara(kok)
    h1, _ = hukumler(b, s)
    vaka("9) TRANSCRIPT YOK -- 'OLCULMEDI', YESIL DEGIL, cikis 4",
         s == "OLCULMEDI" and h1 == "YESIL" and cikis_kodu(h1, s) == 4,
         "saglik=%s h1=%s cikis=%d" % (s, h1, cikis_kodu(h1, s)))

    kok = _temiz_depo({"t.jsonl": _jsonl(130_000)})
    b, s = tara(kok, transcript=os.path.join(kok, "t.jsonl"))
    h1, _ = hukumler(b, s)
    vaka("9b) HER SEY TEMIZ + TOKEN YESIL -- cikis 0",
         h1 == "YESIL" and s == "YESIL" and cikis_kodu(h1, s) == 0,
         "h1=%s saglik=%s cikis=%d" % (h1, s, cikis_kodu(h1, s)))

    for ad, tok, bekle in (("10) TOKEN 130k -- YESIL", 130_000, "YESIL"),
                           ("11) TOKEN 600k -- SARI", 600_000, "SARI"),
                           ("12) TOKEN 800k -- KIRMIZI", 800_000, "KIRMIZI")):
        kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "t.jsonl": _jsonl(tok)})
        b, s = tara(kok, transcript=os.path.join(kok, "t.jsonl"))
        vaka(ad, s == bekle, "olculen hukum=%s" % s)

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "t.jsonl": _jsonl(1_200_000)})
    b, s = tara(kok, transcript=os.path.join(kok, "t.jsonl"))
    vaka("13) PAYDA OLU (1.2M > 1M) -- S5 ISIRMALI, RENK ILAN EDILMEMELI",
         _isirdi(b, "S5") and s == "KIRMIZI")

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "t.jsonl": "{}\n"})
    b, s = tara(kok, transcript=os.path.join(kok, "t.jsonl"))
    vaka("14) TRANSCRIPT VAR ama usage YOK -- 'OLCULMEDI'", s == "OLCULMEDI")

    # --- D1 -------------------------------------------------------------
    hedef = "abcdefghij"  # 10 bayt
    hedef_sha = hashlib.sha256(hedef.encode("utf-8")).hexdigest()[:8].upper()
    tablo_taze = ("| dosya | bayt | sha8 | neden |\n|---|---|---|---|\n"
                  "| `veri.txt` | **10** | **`%s`** | test |\n" % hedef_sha)
    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "DURUM.md": tablo_taze})
    b, _ = tara(kok)
    vaka("15) D1 KIMLIK TAZE -- SUSMALI", not _isirdi(b, "D1"))

    tablo_bayat = ("| dosya | bayt | sha8 | neden |\n|---|---|---|---|\n"
                   "| `veri.txt` | **99** | **`%s`** | test |\n" % hedef_sha)
    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "DURUM.md": tablo_bayat})
    b, _ = tara(kok)
    vaka("16) D1 BAYT BAYAT (99 vs 10) -- ISIRMALI", _isirdi(b, "D1"))

    tablo_sha_bayat = ("| dosya | bayt | sha8 | neden |\n|---|---|---|---|\n"
                       "| `veri.txt` | **10** | **`AAAAAAAA`** | test |\n")
    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "DURUM.md": tablo_sha_bayat})
    b, _ = tara(kok)
    vaka("17) D1 BAYT TUTUYOR ama SHA BAYAT -- ISIRMALI (ayni boyutta degisim)",
         _isirdi(b, "D1"))

    # --- K157 (oturum 62): kapsam bir LISTEDIR. K151 tabloyu KIMLIKLER.md'ye tasiyinca
    #     bu ayak KORLESTI; asagidaki dort vaka o korlugu PINLER.
    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "KIMLIKLER.md": tablo_taze})
    b, _ = tara(kok)
    vaka("17b) TABLO YALNIZ KIMLIKLER.md'de -- OLCULMELI ve SUSMALI",
         (not _isirdi(b, "D1")) and (not _ayristirilamadi(b)))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "KIMLIKLER.md": tablo_bayat})
    b, _ = tara(kok)
    vaka("17c) KIMLIKLER.md'de BAYAT KIMLIK -- ISIRMALI", _isirdi(b, "D1"))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "KIMLIKLER.md": tablo_taze,
                    "DURUM.md": "tablosuz canli durum\n"})
    b, _ = tara(kok)
    vaka("17d) KIMLIKLER.md TAZE + DURUM.md TABLOSUZ -- "
         "DURUM.md 'AYRISTIRILAMADI' DEMEMELI (K151'in urettigi yanlis-pozitif)",
         (not _isirdi(b, "D1")) and (not _ayristirilamadi(b)))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef,
                    "DURUM.md": "tablosuz\n", "KIMLIKLER.md": "tablosuz\n"})
    b, _ = tara(kok)
    vaka("17e) HICBIR BELGEDE TABLO YOK -- 'OLCULEMEDI' demeli, TEMIZ DEMEMELI",
         _ayristirilamadi(b))

    taban = {"CLAUDE.md": KANONIK_BLOK_TEMIZ, "veri.txt": hedef}

    def hafiza(bayt, sha=hedef_sha, ad="veri.txt"):
        return "DOSYA KIMLIKLERI (olculdu):\n  %s %s b · %s\n" % (ad, bayt, sha)

    kok = _git_depo(dict(taban, **{"PROJE_HAFIZA.md": hafiza(99)}))
    b, _ = tara(kok)
    vaka("18) DEVIR BLOGU YAZIM ANINDA BAYAT -- ISIRMALI", _isirdi(b, "D1"))

    kok = _git_depo(dict(taban, **{"PROJE_HAFIZA.md": hafiza(10)}))
    b, _ = tara(kok)
    vaka("19) DEVIR BLOGU YAZIM ANINDA TAZE -- SUSMALI", not _isirdi(b, "D1"))

    kok = _git_depo(dict(taban, **{"PROJE_HAFIZA.md": hafiza(10)}),
                    sonradan={"veri.txt": hedef + "SONRADAN-BUYUDU"})
    b, _ = tara(kok)
    vaka("19b) YAZIM ANINDA TAZE ama dosya SONRADAN degisti -- SUSMALI "
         "(gercek kosumda uretilen yanlis-pozitifin kontrolu)",
         not _isirdi(b, "D1"),
         "bulgular=%s" % [x[2][:60] for x in _kodlar(b, "D1") if x[0] == "KIRMIZI"])

    kok = _git_depo(dict(taban, **{"PROJE_HAFIZA.md": hafiza(10)}),
                    sonradan={"veri.txt": hedef + "SONRADAN"},
                    commitle_hafizayi=False)
    b, _ = tara(kok)
    vaka("19c) HAFIZA KIRLI ama NOT COMMIT'LI, dosya sonradan degisti -- SUSMALI "
         "(ikinci gercek kosumda uretilen yanlis-pozitifin kontrolu: kirlilik "
         "testi yazim aninin olcusu DEGILDIR)",
         not _isirdi(b, "D1"),
         "kirmizilar=%s" % [x[2][:70] for x in _kodlar(b, "D1") if x[0] == "KIRMIZI"])

    kok = _git_depo(taban, sonradan={"PROJE_HAFIZA.md": hafiza(1)})
    b, _ = tara(kok)
    vaka("19e) NOT HIC COMMIT'LENMEMIS -- yazim ani CALISMA AGACI, ISIRMALI",
         _isirdi(b, "D1"))

    kok = _git_depo(dict(taban, **{
        "PROJE_HAFIZA.md": hafiza(12345, "AAAAAAAA", "PROJE_HAFIZA.md")}))
    b, _ = tara(kok)
    vaka("19d) NOT KENDI KABINI beyan ediyor -- KIRMIZI DEGIL, 'D1-OZ' SARI",
         _isirdi(b, "D1-OZ", "SARI") and not _isirdi(b, "D1"),
         "kodlar=%s" % [(x[0], x[1]) for x in b if x[1].startswith("D1")])

    kok = _git_depo(dict(taban, **{
        "PROJE_HAFIZA.md": hafiza(10, "AAAAAAAA", "yok-boyle-dosya.txt")}))
    b, _ = tara(kok)
    vaka("20) AD COZUMLENEMEDI -- 'OLCULEMEDI' demeli, TEMIZ DEMEMELI",
         _isirdi(b, "D1", "OLCULEMEDI"))

    kok = _fixture({"CLAUDE.md": KANONIK_BLOK_TEMIZ,
                    "PROJE_HAFIZA.md": "burada kimlik blogu yok\n"})
    b, _ = tara(kok)
    vaka("21) DEVIR BLOGU YOK -- 'OLCULEMEDI' demeli", _isirdi(b, "D1", "OLCULEMEDI"))

    print("=" * 78)
    print("ALTIN KUME -- OTURUM SAGLIGI KAPISININ KENDI KANITI (kor kapi yok)")
    print("=" * 78)
    dusen = 0
    for ad, gecti, ayrinti in vakalar:
        print("[%s] %s%s" % ("GECTI" if gecti else "DUSTU", ad,
                             ("  << " + ayrinti) if (ayrinti and not gecti) else ""))
        if not gecti:
            dusen += 1
    print("-" * 78)
    print("%d/%d vaka gecti." % (len(vakalar) - dusen, len(vakalar)))
    print("HUKUM: " + ("ARAC KULLANILABILIR -- temizde susuyor, kirlide isiriyor."
                       if dusen == 0 else "ARAC KULLANILAMAZ -- %d vaka DUSTU." % dusen))
    print("=" * 78)
    return 0 if dusen == 0 else 2


def main(argv):
    if "--altin-kume" in argv:
        return altin_kume()
    kok = None
    transcript = None
    pencere = VARSAYILAN_PENCERE
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == "--transcript" and i + 1 < len(argv):
            transcript = argv[i + 1]
            i += 2
            continue
        if a == "--pencere" and i + 1 < len(argv):
            pencere = int(argv[i + 1])
            i += 2
            continue
        if not a.startswith("--"):
            kok = a
        i += 1
    if kok is None:
        print("KULLANIM: python araclar\\oturum-sagligi.py <kok> "
              "[--transcript <yol.jsonl>] [--pencere N]")
        print("          python araclar\\oturum-sagligi.py --altin-kume")
        return 3
    if not os.path.isdir(kok):
        print("ORTAM HATASI: dizin yok: %s" % kok)
        return 3
    bulgular, saglik = tara(kok, transcript=transcript, pencere=pencere)
    h1, s = hukumler(bulgular, saglik)
    yazdir(bulgular, h1, s)
    return cikis_kodu(h1, s)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
