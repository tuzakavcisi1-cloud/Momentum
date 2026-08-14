# -*- coding: utf-8 -*-
"""tek-kopya-kapisi.py'nin OLCUM AYAGINI (olc() + git) gercek bir depoda kanitlar.
Altin kume yalniz denetle()'yi sikistirir; olc() bozuk olsa kapi sonsuza kadar
YESIL yanardi. Bu betik gercek dosyalari gercekten bozar ve kapinin ISIRDIGINI olcer."""
import io, os, shutil, subprocess, sys, tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import importlib.util
spec = importlib.util.spec_from_file_location(
    "tkk", os.path.join(os.path.dirname(os.path.abspath(__file__)), "tek-kopya-kapisi.py"))
tkk = importlib.util.module_from_spec(spec)
spec.loader.exec_module(tkk)

kok = tempfile.mkdtemp(prefix="tkk_mutant_")
KAPSAM = [("PROJE_HAFIZA.md", "append_only"), ("DURUM.md", "canli"),
          ("DESIGN.md", "kilitli")]


def yaz(ad, metin):
    io.open(os.path.join(kok, ad), "w", encoding="utf-8", newline="\n").write(metin)


def git(*a):
    return subprocess.run(["git"] + list(a), cwd=kok, capture_output=True)


yaz("PROJE_HAFIZA.md", "arsiv\n" * 400)
yaz("DURUM.md", "canli durum\n" * 100)
yaz("DESIGN.md", "tasarim\n" * 100)
git("init", "-q")
git("config", "user.email", "t@t")
git("config", "user.name", "t")
git("add", "PROJE_HAFIZA.md", "DURUM.md", "DESIGN.md")
git("commit", "-qm", "temel")

sonuc = []


def kos(ad, bekle_hukum, bekle_kod):
    b, h = tkk.denetle(tkk.olc(kok, KAPSAM))
    kodlar = sorted({k for _, k, _, _ in b})
    ok = h == bekle_hukum and (bekle_kod is None or bekle_kod in kodlar)
    sonuc.append(ok)
    # ETIKET [GECTI]/[KALDI]: sayi-tazeligi.py bu araci KOSARAK 11/11 iddiasini
    # dogrulayabilsin diye. Olculemeyen iddia, iddia degildir.
    print("[%s] %-46s hukum=%-7s kodlar=%s  (%s)" %
          ("GECTI" if ok else "KALDI", ad, h, kodlar,
           "isirdi/sustu = beklendigi gibi" if ok else "BEKLENEN DAVRANIS YOK"))


kos("KONTROL: hic dokunulmadi -- SUSMALI", "YESIL", None)

io.open(os.path.join(kok, "PROJE_HAFIZA.md"), "w").close()          # 0 bayt
kos("M1: arsiv 0 BAYTA dusuruldu (oturum 31'in ta kendisi)", "KIRMIZI", "S1")
git("restore", "PROJE_HAFIZA.md")

h = os.path.join(kok, "PROJE_HAFIZA.md")
ham = io.open(h, "rb").read()
f = io.open(h, "wb"); f.write(ham[:-len("arsiv\r\n")]); f.close()     # SON SATIR gitti
kos("M2a: arsivden BIR SATIR silindi (gercek icerik kaybi)", "KIRMIZI", "S2")
git("restore", "PROJE_HAFIZA.md")

ham = io.open(h, "rb").read()
f = io.open(h, "wb"); f.write(ham[:-1]); f.close()                   # yalniz son \n
kos("M2b: yalniz SON SATIR SONU dustu -- normalize edilince icerik AYNI, "
    "SUSMASI DOGRU [BEYAN EDILMIS SINIR]", "YESIL", "S10")
git("restore", "PROJE_HAFIZA.md")

d = os.path.join(kok, "DURUM.md")
ham = io.open(d, "rb").read()
io.open(d, "wb").write(ham[:int(len(ham) * 0.80)])                   # %20 kirpma
kos("M3: canli dosya %20 kirpildi", "KIRMIZI", "S2")
git("restore", "DURUM.md")

ham = io.open(d, "rb").read()
io.open(d, "wb").write(ham[:int(len(ham) * 0.97)])                   # %3 budama
kos("M4: canli dosya %3 budandi -- MESRU, SUSMALI", "YESIL", None)
git("restore", "DURUM.md")

g = os.path.join(kok, "DESIGN.md")
ham = io.open(g, "rb").read()
io.open(g, "wb").write(ham.replace(b"tasarim\n", b"tasarXm\n", 1))   # AYNI boyut
kos("M5: kilitli dosya AYNI BOYUTTA degistirildi (boyut kapisi KOR kalirdi)",
    "KIRMIZI", "S6")
git("restore", "DESIGN.md")

io.open(os.path.join(kok, "PROJE_HAFIZA.md.tmp"), "w").write("yarim")
kos("M6: yarim kalmis .tmp artigi -- SARI", "SARI", "S4")
os.remove(os.path.join(kok, "PROJE_HAFIZA.md.tmp"))

io.open(h, "wb").write(b"gecerli metin\n" + b"\xff\xfe\x00bozuk")     # bozuk UTF-8
kos("M7: dosya BOZUK UTF-8 yapildi", "KIRMIZI", "S3")
git("restore", "PROJE_HAFIZA.md")

os.remove(h)
kos("M8: izlenen dosya SILINDI", "KIRMIZI", "S0")
git("restore", "PROJE_HAFIZA.md")

kos("KAPANIS KONTROLU: her sey geri alindi -- tekrar SUSMALI", "YESIL", None)

print("\nMUTANT SONUCU: %d/%d" % (sum(sonuc), len(sonuc)))
shutil.rmtree(kok, ignore_errors=True)
sys.exit(0 if all(sonuc) else 1)
