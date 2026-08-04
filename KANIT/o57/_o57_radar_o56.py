# -*- coding: utf-8 -*-
"""oturum 57: oturum 56'nin PROJE_RADAR.jsonl kayitlarini GERIYE DONUK yazar.
K40: her checkpointte BIR SATIR; TAM-DOSYA REWRITE YOK -- yalniz append.
Kaynak: Onur'un devir notu + git + KANIT/o56 + disk olcumu.
"""
import json
import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

YOL = r"C:\dev\Momentum\PROJE_RADAR.jsonl"

KOKEN = (
    " || KAYIT KOKENI: BU SATIR OTURUM 57 TARAFINDAN GERIYE DONUK YAZILDI -- "
    "oturum 56 kendi kaydini YAZMADI ve bunu devir notunda ACIK birakti. "
    "urun_kodu_satiri GIT'TEN olculdu (radar.py . --olc-urun-kodu "
    "32336559..HEAD => 0), ELLE YAZILMADI. bayt DISKTEN olculdu "
    "(dosya-kimlik.py, oturum 57). bulgu/kapatilan/uretilen sayilari devir "
    "notundan ve KANIT/o56 artefaktlarindan TURETILDI, oturum 57 tarafindan "
    "yeniden OLCULMEDI => [TAHMIN]."
)

KAYITLAR = [
    {
        "tarih": "2026-08-04", "oturum": 56, "urun_kodu_satiri": 0,
        "artefakt": "araclar/ss2-kapisi.py", "tur": 1,
        "asama": "K135: blok yorum (/* */) KOR KAPISI onarildi; altin kume 10 -> 14",
        "bulgu": {"bloker": 0, "major": 0, "minor": 2},
        "siniflar": ["kor-kapi"],
        "bayt": 15658, "kapatilan": 3, "uretilen": 0,
        "not": (
            "KAPATILAN 3: (1) SS2 kabul turunun MINOR (2)'si; (2) blok yorum "
            "kesilmiyordu => YORUMDAKI '=> 5' KOD SANILIP kapi yesil donuyordu, "
            "gercek kod '=> 4' idi; (3) G33/c yorum-atlama olcumu. M-o56-1 "
            "mutanti onarimin YUK TASIDIGINI kanitladi: 12/14 dustu, geri alma "
            "bayt-ozdes (AC744C65). URETILEN 0. DERS: MINOR'u kapatmak icin "
            "yazilan OLCUM, MINOR'un ADINI KOYMADIGI iki kusuru buldu -- kagit "
            "denetimi degil, KOSAN olcum buldu (K53/1'in kendi gerekcesi). "
            "Kanit: KANIT/o56/15-ss2-altin-kume-14.txt, 17-mutant-o56-onarim-yuku.txt"
        ) + KOKEN,
    },
    {
        "tarih": "2026-08-04", "oturum": 56, "urun_kodu_satiri": 0,
        "artefakt": "DURUM.md", "tur": 24,
        "asama": "K135-EK2: 5. bolum budandi + 6. bolum envanteri yeniden sayildi (27/21 -> 29/23)",
        "bulgu": {"bloker": 0, "major": 0, "minor": 1},
        "siniflar": ["bayat-iddia"],
        "bayt": 30329, "kapatilan": 2, "uretilen": 0,
        "not": (
            "KAPATILAN 2: (1) 6. bolum envanteri BAYATTI -- ss2-kapisi.py (o55) "
            "ve ci-kapisi.py (o53) tabloya HIC girmemisti, yani IKI KAPI "
            "ENVANTERSIZ kosuyordu ('envanterde olmayan kapi tetiklenemez'); "
            "(2) 5. bolum anlatimi K73 geregi arsive tasindi. BUDAMA KOR "
            "DEGILDI: once IZ olculdu (KANIT/o56/25-beyan-izi.txt) ve tasinacak "
            "13 beyandan ALTISININ baska hicbir canli belgede izi olmadigi "
            "gorulup o alti 5. bolumde KORUNDU."
        ) + KOKEN,
    },
]

KAYITLAR += [
    {
        "tarih": "2026-08-04", "oturum": 56, "urun_kodu_satiri": 0,
        "artefakt": "BORCLAR.md", "tur": 17,
        "asama": "K135-EK/EK3: uc kapanmis kalem arsive tasindi, B-SS2-5 acildi; pay 857 -> 845 b",
        "bulgu": {"bloker": 0, "major": 0, "minor": 1},
        "siniflar": ["olcum-aracinin-varsayimi"],
        "bayt": 31923, "kapatilan": 3, "uretilen": 1,
        "not": (
            "BUDAMANIN NET ETKISI -12 BAYT: uc kalem arsive tasindi ama ayni "
            "turda B-SS2-5 acildi => T2 SARI KALDI (31923/32768, pay 845, esik "
            "1638). K117/K126'nin dersi ('budama ancak bir borc KAPANINCA ise "
            "yarar') bu turda IKINCI kez olculdu. OTURUM 57 ACILISINDA kapi yine "
            "SARI verdi ve 'bir sonraki checkpoint tavani ASAR' dedi. TAVAN "
            "KARARI K40 GEREGI ONUR'DA; oturum 57 tavani DEGISTIRMEDI ve "
            "budamayi TEKRARLAMADI -- olculerek basarisiz olmus bir hamleyi "
            "yeniden kosmak kisir dongunun tanimidir."
        ) + KOKEN,
    },
    {
        "tarih": "2026-08-04", "oturum": 56, "urun_kodu_satiri": 0,
        "artefakt": "GOREV_CLAUDE_CODE/GOREV-SS2-cakisma-cozumu.md", "tur": 5,
        "asama": "KABUL kosumu: kriter 8 spec'in LAFZIYLA kosulamadi -- urunde baslik duzenleme UI'i YOK",
        "bulgu": {"bloker": 0, "major": 1, "minor": 0},
        "siniflar": ["kosulamaz-kabul-sarti"],
        "bayt": 46003, "kapatilan": 0, "uretilen": 1,
        "not": (
            "YENI KUSUR SINIFI -- KOSULAMAZ KABUL SARTI. Spec kriter 8'in 4. ve "
            "5. adimi 'baslik B1/A1 yapilir' diyor; URUNDE BASLIK DUZENLEYEN "
            "ETKILESIM YOK: duzenle() lib/ icinde yalnizca cakismaCoz'dan "
            "cagriliyor ve gorev_satiri.dart 'bu widget onTap TASIMAZ' diyor. "
            "IKI KAGIT DENETIM TURU BUNU GORMEDI -- hicbiri 'bu adim cihazda "
            "FIILEN yapilabiliyor mu' diye SORMADI. Yapilabilirlik ancak ortam "
            "kalkinca olculur; bu, K53/1'in 'kagit turu tavani 1' gerekcesinin "
            "dogrudan kanitidir. ONUR'UN KILIDI: cakisma TAMAMLANMA anahtariyla "
            "uretilsin, sapma BEYAN edilsin, spec ACILMASIN. "
            "Kanit: KANIT/o56/34-KRITER8-SPEC-KOSULAMAZ.md"
        ) + KOKEN,
    },
]

KAYITLAR += [
    {
        "tarih": "2026-08-04", "oturum": 56, "urun_kodu_satiri": 0,
        "artefakt": "KANIT/SS2/04-COWORK-KABUL-HUKMU.md", "tur": 1,
        "asama": "K136: SS2 KABUL EDILDI (Onur kilitledi) -- dokuz kriter Cowork'un KENDI kosumuyla, kabul KAPANMAMIS DORT SINIRLA",
        "bulgu": {"bloker": 0, "major": 0, "minor": 4},
        "siniflar": ["kosulamaz-kabul-sarti", "olcum-belirsizligi"],
        "bayt": 3757, "kapatilan": 9, "uretilen": 4,
        "not": (
            "KAPATILAN 9: dokuz kabul kriteri olculdu (K26). CAKISMA CIHAZDA ILK "
            "KEZ UCTAN UCA GORULDU: rozet cikti, ekran iki degeri gosterdi, "
            "'Benimkini tut' karsi cihaza ULASTI. SUNUCU VERITABANINDAN olculdu: "
            "B'nin op'u 11:25:34'te URETILDI, 11:29:36'da ULASTI (4 dk kuyrukta); "
            "A HLC 1785842911692 > B HLC 1785842734501 => A kazanan, B kaybeden. "
            "URETILEN 4 KAPANMAMIS SINIR (B-SS2-1..5): (1) kriter 8 spec'in "
            "lafziyla kosulamadi; (2) kuyrugun KENDILIGINDEN bosalma suresi "
            "OLCULMEDI -- Yenile ile zorlandi; (3) kriter 4 bir ORNEKLEMDIR, 23 "
            "mutantin tamami kosulmadi; (4) telefon USB tuneliyle (adb reverse) "
            "baglandi => NAT/SignalR yeniden baglanma borcu KAPANMADI. "
            "Ham cikti: KANIT/o56/40-64 + 65-KRITER8-HUKUM.md"
        ) + KOKEN,
    },
    {
        "tarih": "2026-08-04", "oturum": 56, "urun_kodu_satiri": 0,
        "artefakt": "PROJE_HAFIZA.md", "tur": 39,
        "asama": "K135 / K135-EK / K135-EK2 / K135-EK3 / K136 checkpointleri yazildi",
        "bulgu": {"bloker": 0, "major": 0, "minor": 0},
        "siniflar": [],
        "bayt": 0, "kapatilan": 1, "uretilen": 0,
        "not": (
            "Bayt alani 0 -- boyut ayni betikte YUKARIDA olculur; buraya elle "
            "kopyalamak bayat-iddia uretirdi (oturum 55'in deseni). "
            "Checkpointlerin DIZIN:SON satirinin ALTINA yazilip yazilmadigi "
            "oturum 57'de [OLCULMEDI]."
        ) + KOKEN,
    },
]


def main():
    onceki = os.path.getsize(YOL)
    with open(YOL, "rb") as f:
        f.seek(-1, os.SEEK_END)
        son_bayt = f.read(1)
    parcalar = []
    if son_bayt != b"\n":
        parcalar.append("\n")
        print("[BILGI] dosya newline ile bitmiyordu -- ayirici eklendi.")
    for k in KAYITLAR:
        parcalar.append(json.dumps(k, ensure_ascii=True) + "\n")
    govde = "".join(parcalar).encode("utf-8")
    with open(YOL, "ab") as f:
        f.write(govde)
        f.flush()
        os.fsync(f.fileno())
    sonra = os.path.getsize(YOL)
    print("APPEND TAMAM -- tam-dosya rewrite YOK.")
    print("  kayit sayisi : %d" % len(KAYITLAR))
    print("  bayt         : %d -> %d (+%d)" % (onceki, sonra, sonra - onceki))
    with open(YOL, "r", encoding="utf-8") as f:
        satirlar = f.read().splitlines()
    bozuk = 0
    for i, s in enumerate(satirlar, 1):
        if not s.strip():
            continue
        try:
            json.loads(s)
        except Exception as e:
            bozuk += 1
            print("  [KIRMIZI] satir %d ayristirilamadi: %s" % (i, e))
    print("  satir sayisi : %d · ayristirilamayan: %d" % (len(satirlar), bozuk))
    print("HUKUM: %s" % ("TEMIZ" if bozuk == 0 else "KIRMIZI"))


if __name__ == "__main__":
    main()
