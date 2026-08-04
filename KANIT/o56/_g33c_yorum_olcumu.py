# -*- coding: utf-8 -*-
"""Oturum 56 -- MINOR (2): ss2-kapisi.py'nin YORUM-ATLAMA ayagini G33/c'de OLCER.
Uretici Claude Code'du; bu olcumu Cowork yapar (K34-f: onaran el != yazan el).
Bu betik ARACI DEGISTIRMEZ -- yalnizca davranisini olcer."""
import importlib.util, io, os, sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

yol = os.path.join(os.path.dirname(__file__), "..", "..", "araclar", "ss2-kapisi.py")
spec = importlib.util.spec_from_file_location("ss2kapisi", os.path.abspath(yol))
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)

DB = M._VERITABANI_TEMIZ
GD = M._GOREV_DEPOSU_TEMIZ


def olc(ad, db, gd, beklenen, neden):
    kodlar = sorted(set(k for k, _ in M.denetle(db, gd)))
    ok = kodlar == sorted(set(beklenen))
    print(("[BEKLENEN GIBI] " if ok else "[SAPMA] ") + ad)
    print("    beklenen: %s -- olculen: %s" % (sorted(set(beklenen)), kodlar))
    print("    neden onemli: " + neden)
    return ok

print("=" * 74)
print("G33/c + G31/a YORUM-ATLAMA OLCUMU (oturum 56, Cowork)")
print("=" * 74)

# A) M176c -- gercek kod distinct'i kaybeder, dogru bicim YALNIZ yorumda
a = olc("A) M176c: distinct:true satiri YORUMA cevrilir (gercek kod kaybeder)",
        DB,
        GD.replace("      filter: kuyruk.durum.equals('bekliyor'),\n      distinct: true,\n",
                   "      filter: kuyruk.durum.equals('bekliyor'),\n      // distinct: true,\n"),
        ["G33c"],
        "yorumu KODA sayan arac burada SUSAR ve yakalanir -- M171b'nin G33/c'deki esi")

# B) M176d -- kod bozulmaz, fazladan YORUM satirinda distinct'siz bir count( eklenir
b = olc("B) M176d: kod bozulmaz, yorumda distinct'siz .count( -- SUSMALI",
        DB,
        GD + "\n    // final eskiSutun = kuyruk.opId.count(filter: kuyruk.durum.equals('x'));\n",
        [],
        "yorumu atmayan arac burada YANLIS-POZITIF verir -- M171c'nin G33/c'deki esi")

# C) BLOK YORUM -- MINOR'un adini koymadigi derin kor nokta (G33/c yonu)
c = olc("C) BLOK yorum /* ... */ icinde distinct'siz .count( -- SUSMALI",
        DB,
        GD + "\n    /* final eskiSutun = kuyruk.opId.count(filter: kuyruk.durum.equals('x')); */\n",
        [],
        "_yorumsuz_satirlar YALNIZ '//' keser; /* */ kesilmezse YANLIS-POZITIF dogar")

# D) BLOK YORUM -- G31/a yonu: gercek kod 4, dogru deger blok yorumda
d = olc("D) BLOK yorum icinde schemaVersion => 5, gercek kod => 4 -- KIRMIZI olmali",
        DB.replace("int get schemaVersion => 5;",
                   "int get schemaVersion => 4;\n  /* int get schemaVersion => 5; */"),
        GD,
        ["G31a"],
        "blok yorum kesilmezse arac YANLIS SUSAR -- kor kapinin en tehlikeli hali")

print("=" * 74)
print("SONUC: A=%s B=%s C=%s D=%s" % (a, b, c, d))
print("=" * 74)
sys.exit(0 if all([a, b, c, d]) else 1)
