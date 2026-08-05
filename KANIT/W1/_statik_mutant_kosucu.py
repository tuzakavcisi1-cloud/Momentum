# -*- coding: utf-8 -*-
"""W1 kriter 6 -- ON UC STATIK MUTANT (Cowork'un KENDI kosumu, K26).

Oturum 57'de 14 statik mutantin 13'u Claude Code'un KAYDINDAN OKUNDU, olculmedi;
yalniz M192 gercek repoda kosuldu. Bu betik kalan 13'u OLCER.

Yontem (ORTAM.md, referans KANIT/A11/_mutant_kosucu.py):
  ikili yedek -> bayt duzeyinde yama -> kapiyi kos -> yedekten wb ile geri yaz
  -> sha256 ile BAYT-OZDESLIK dogrula.  `git restore` YASAK (core.autocrlf).
"""
import hashlib
import io
import os
import subprocess
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

KOK = r"C:\dev\Momentum"
KAPI = os.path.join(KOK, "araclar", "cors-kapisi.py")
PC = os.path.join(KOK, "src", "backend", "Momentum.Api", "Program.cs")
SJ = os.path.join(KOK, "src", "client", "lib", "ag", "signalr_json_sinyal.dart")
VT = os.path.join(KOK, "src", "client", "lib", "veri", "veritabani.dart")


def oku(p):
    with io.open(p, "rb") as f:
        return f.read()


def yaz(p, b):
    with io.open(p, "wb") as f:
        f.write(b)


def sha(b):
    return hashlib.sha256(b).hexdigest()[:8].upper()


def nl(ham, s):
    return s.replace("\n", "\r\n") if b"\r\n" in ham else s


def kapiyi_kos():
    p = subprocess.run([sys.executable, KAPI, "."], cwd=KOK, capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    return p.returncode, ((p.stdout or "") + (p.stderr or ""))


# ====================== KAYNAK PARCALARI (birebir) ============================
ADDCORS = (
    "    builder.Services.AddCors(options => options.AddDefaultPolicy(policy => policy\n"
    "        .WithOrigins(corsAllowedOrigins)\n"
    "        .WithHeaders(\"Content-Type\", \"X-Momentum-Dev-User\")\n"
    "        .WithMethods(\"GET\", \"POST\", \"PUT\", \"DELETE\", \"OPTIONS\")));\n"
)
IF_SATIRI = ("if (builder.Environment.IsDevelopment() && corsAllowedOrigins.Length > 0)"
             " // W1/D-W1-2\n")
USECORS_BLOK = IF_SATIRI + "{\n    app.UseCors();\n}\n"
ADDCORS_BLOK = IF_SATIRI + "{\n" + ADDCORS + "}\n"

KISWEB_DAL = (
    "    if (kIsWeb) {\n"
    "      gunlukYaz('web: gercek zamanli sinyal KAPALI (K79/2)"
    " -- elle yenileme tek yol');\n"
    "      return;\n"
    "    }\n"
)
ONRESULT = (
    "      onResult: (sonuc) {\n"
    "        // ignore: avoid_print\n"
    "        print(\n"
    "          'MOMENTUM-G6-KANIT chosenImplementation=${sonuc.chosenImplementation} '\n"
    "          'missingFeatures=${sonuc.missingFeatures}',\n"
    "        );\n"
    "      },\n"
)
ONEK_SATIRI = ("          'MOMENTUM-G6-KANIT chosenImplementation="
               "${sonuc.chosenImplementation} '\n")


# ====================== MUTANT TANIMLARI ======================================
# (ad, kapi-ayak, beklenti: "ISIR" | "SUS", [(dosya, eski, yeni)])
M = []

M.append(("M189", "W1/G35/a", "ISIR", [
    (PC, "    app.UseCors();\n", "    // MUTANT M189: UseCors KALDIRILDI\n")]))

M.append(("M189b", "W1/G35/a + D-W1-2", "ISIR", [
    (PC, ADDCORS, "    // MUTANT M189b: AddCors KALDIRILDI\n")]))

M.append(("M190", "W1/G35/b + D-W1-2", "ISIR", [
    (PC, USECORS_BLOK,
     IF_SATIRI + "{\n    // MUTANT M190: UseCors blok DISINA tasindi\n}\n"
     "app.UseCors();\n")]))

M.append(("M190b", "W1/G35/b + D-W1-2", "ISIR", [
    (PC, ADDCORS_BLOK,
     IF_SATIRI + "{\n    // MUTANT M190b: AddCors blok DISINA tasindi\n}\n"
     + ADDCORS.replace("\n    ", "\n"))]))

M.append(("M191", "W1/G35/c + D-W1-1", "ISIR", [
    (PC, "        .WithOrigins(corsAllowedOrigins)\n",
     "        .AllowAnyOrigin() // MUTANT M191\n")]))

M.append(("M191b", "W1/G35/c yanlis-pozitif", "SUS", [
    (PC, "    builder.Services.AddCors(options",
     "    // MUTANT M191b: AllowAnyOrigin() ve SetIsOriginAllowed yalniz YORUMDA\n"
     "    builder.Services.AddCors(options")]))

M.append(("M192b", "W1/G35/d + D-W1-8", "ISIR", [
    (PC, "        .WithHeaders(\"Content-Type\", \"X-Momentum-Dev-User\")\n",
     "        .WithHeaders(\"Content-Type\") // MUTANT M192b\n")]))


M.append(("M193", "W1/G35/a (// yolu)", "ISIR", [
    (PC, "    app.UseCors();\n", "    // app.UseCors(); // MUTANT M193\n")]))

M.append(("M193b", "W1/G35/a yanlis-pozitif", "SUS", [
    (PC, "    app.UseCors();\n",
     "    // MUTANT M193b: fazladan // yorum\n    app.UseCors();\n")]))

M.append(("M193c", "W1/G35/a (/* */ yolu)", "ISIR", [
    (PC, "    app.UseCors();\n", "    /* app.UseCors(); MUTANT M193c */\n")]))

M.append(("M194", "W1/G38/c + D-W1-5", "ISIR", [
    (SJ, KISWEB_DAL,
     "    // MUTANT M194: kIsWeb DALI SILINDI (import satiri DURUYOR)\n")]))

M.append(("M198", "W1/G37/d", "ISIR", [
    (VT, ONEK_SATIRI,
     "          'MUTANT-M198-ONEK chosenImplementation="
     "${sonuc.chosenImplementation} '\n")]))

M.append(("M198b", "W1/G37/d (/* */ yolu)", "ISIR", [
    (VT, ONRESULT,
     "      onResult: (sonuc) {\n"
     "        /* print('MOMENTUM-G6-KANIT ...'); MUTANT M198b */\n"
     "      },\n")]))

# OTURUM 58'DE EKLENDI -- spec tablosunda YOKTU (bulgu, asagida gerekcesi).
# G35'in POZITIF KONTROLU (`AddMediator` capasi) ne mutantli ne borcluydu;
# `spec-kapi-kapsama.py` onu goremez cunku harfli bir ayak degil, proza.
M.append(("M-o58-1", "W1/G35 pozitif kontrol", "ISIR", [
    (PC, "builder.Services.AddMediator();\n",
     "builder.Services.AddCqrsMediator(); // MUTANT M-o58-1: capa BOZULDU\n")]))
# 🔴 ILK YAZIMDA ESDEGERDI (oturum 58'de olculdu): `AddMediatorX()` yamasi
# aranan dizgeyi (`builder.Services.AddMediator`) ONEK olarak HALA iceriyordu
# => capa bozulmamisti, kapi hakli olarak sustu. `AddCqrsMediator` dizgeyi
# gercekten yok eder. Ders: yokluk olcen mutant, dizgeyi ONEK olarak da
# birakmamalidir.


# ============================ KOSUM =========================================
def main():
    satirlar = []

    def y(s):
        satirlar.append(s)
        print(s)

    kod, _ = kapiyi_kos()
    if kod != 0:
        y("ORTAM HATASI: temiz repoda cors-kapisi.py EXIT %d -- kosum IPTAL." % kod)
        return 3
    y("TEMEL OLCUM: temiz repoda cors-kapisi.py EXIT 0 (yanlis-pozitif kontrolu).")
    y("")

    gecen = 0
    basarisiz = []
    for ad, ayak, beklenti, yamalar in M:
        yedek = {}
        eksik = None
        for yol, eski, yeni in yamalar:
            ham = yedek.get(yol)
            if ham is None:
                ham = oku(yol)
                yedek[yol] = ham
            desen = nl(ham, eski).encode("utf-8")
            adet = ham.count(desen)
            if adet != 1:
                eksik = "%s: desen %d kez bulundu (1 olmali)" % (
                    os.path.basename(yol), adet)
                break
        if eksik:
            y("[ORTAM HATASI] %-6s %-26s %s" % (ad, ayak, eksik))
            basarisiz.append(ad)
            continue

        calisan = dict(yedek)
        for yol, eski, yeni in yamalar:
            ham = yedek[yol]
            calisan[yol] = calisan[yol].replace(
                nl(ham, eski).encode("utf-8"), nl(ham, yeni).encode("utf-8"), 1)
        for yol, veri in calisan.items():
            yaz(yol, veri)

        kod, cikti = kapiyi_kos()

        for yol, veri in yedek.items():
            yaz(yol, veri)
        ozdes = all(sha(oku(yol)) == sha(veri) for yol, veri in yedek.items())

        isirdi = (kod != 0)
        beklendi = (beklenti == "ISIR")
        tamam = (isirdi == beklendi) and ozdes
        gecen += 1 if tamam else 0
        if not tamam:
            basarisiz.append(ad)
        y("[%s] %-6s %-26s beklenen=%-4s olculen=%s EXIT=%d geri-alma=%s" % (
            "GECTI" if tamam else "KALDI", ad, ayak, beklenti,
            "ISIR" if isirdi else "SUS ", kod,
            "BAYT-OZDES" if ozdes else "BOZUK!!"))
        for satir in cikti.splitlines():
            s = satir.strip()
            if ("G35/" in s or "G37/" in s or "G38/" in s or "ORTAM HATASI" in s):
                y("        | " + s)
        if not ozdes:
            y("   >> DUR: bayt-ozdeslik SAGLANMADI, sonraki mutant KOSULMAZ.")
            break

    y("")
    kod, _ = kapiyi_kos()
    y("KAPANIS OLCUMU: cors-kapisi.py EXIT %d (0 olmali)." % kod)
    y("HUKUM: %d/%d gecti." % (gecen, len(M)))
    if basarisiz:
        y("KALANLAR: " + ", ".join(basarisiz))
    yol = os.path.join(KOK, "KANIT", "W1", "02-STATIK-MUTANT-KOSUMU.txt")
    with io.open(yol, "wb") as f:
        f.write(("\n".join(satirlar) + "\n").encode("utf-8"))
    return 0 if (not basarisiz and kod == 0) else 1


if __name__ == "__main__":
    sys.exit(main())
