# -*- coding: utf-8 -*-
"""K138 -- W1 KABUL. Hafiza checkpointi + defter kayitlari + DURUM.md tek satir.
TAVAN KORUMALI: DURUM.md 32768'i asarsa HICBIR SEY yazilmaz (K40 -- esik Onur'da).
BORCLAR.md'ye DOKUNULMAZ (pay 295 b; B-W1-3/B-W1-4 bilerek YAZILMIYOR, beyan edilir).
Emoji chr() ile (ORTAM.md).
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
DURUM = os.path.join(KOK, "DURUM.md")
R = chr(0x1F534)
Y = chr(0x1F7E2)
K = chr(0x1F512)

CP = """
## K138 — `GOREV-W1` KABUL EDİLDİ (Onur kilitledi, 5 Ağu 2026, oturum 57)

{Y} **On bir kriterin dokuzu COWORK'ÜN KENDİ KOŞUMUYLA ölçüldü (`K26`).** Code'un `kriter*.txt`
dosyaları **okunmadı**, zincir baştan koşuldu (`KANIT/o57/_o57_cowork_kabul_kosumu.py`, ham çıktı
`KANIT/o57/kabul-kosumu-COWORK.txt`): `verify.ps1` **EXIT 0** (97,2 s; kapanış ÖLÇÜLDÜ — `:5298` ve
`:5000` **BOŞ**, pozitif kontrol 30 LISTENING satırı) · `analyze --fatal-infos` **0** ·
`flutter test` **522/522** · `cors-kapisi.py --altin-kume` **18/18** ve proje koşumu **BULGU YOK** ·
`spec-kapi-kapsama` · `tek-kopya` · `kapi-ad-teklik` · `sayi-tazeligi` hepsi **EXIT 0**.
Hüküm: `KANIT/W1/01-COWORK-KABUL-HUKMU.md`.

{Y} **BAĞIMSIZ MUTANT ÖRNEKLEMESİ — `M192` GERÇEK REPODA.** Cowork, denetimin **BLOKER-1**'ini
seçti: kontrol temiz (0) → `Content-Type` izinli başlıklardan çıkarıldı → kapı **1** verdi
(*"[G35d] izinli başlıklarda 'Content-Type' adıyla yok"*) → yedekten geri yazıldı → **bayt-özdeş**
(`1e31f5b4…`, `git restore` KULLANILMADAN). Bu sha Code'un kendi kaydıyla **birebir tutuyor**.

{Y} **SPEC'İN İKİ BEYAN EDİLMİŞ BİLİNMEZİ KAPANDI.** `## 8/9`: *"`Content-Type` blokerı kod
okumasıyla kesin, canlı preflight'la değil"* → canlı ölçüldü (`204` · `ACAO: http://localhost:5000`,
**`*` değil** · `ACAH: Content-Type,X-Momentum-Dev-User` · `evil.local` ⇒ **ACAO YOK**).
`## 8/7`: `WebApplicationFactory` riski `[ÖLÇÜLMEDİ]` → `verify.ps1` **EXIT 0**.
Denetçilerin `B1` (kör `G37/b`) ve `B2` (eşdeğer `M196`) bulguları da canlı ölçümle kapandı:
`G37/b` backend **ölçülerek kapalıyken** koşuldu ve görev sunucuya **hiç gitmemişti** (`psql` = 0);
`M196` tam istendiği gibi yalnız `G36/b`'yi düşürdü, `evil.local` başlığı **gerçekten aldı**.

{R} **COWORK'ÜN BULDUĞU DÖRT ŞEY — Code'un raporunda BU HÂLİYLE YOKTU:**
① **`urun_kodu_satiri = 6773` YANILTICI:** kırılım `drift_worker.js` **+6.743** · `Program.cs`
**+23** · `appsettings.Development.json` **+7** ⇒ **elle yazılmış ürün kodu 30 SATIR**. `R8` hükmü
değişmez (30 > 0) ama defter bu oturumu sonsuza kadar 6.773 satırlık gösterir. `radar.py`'nin ürün
yolları (`src/`, `lib/`, `app/`) **satıcı varlıklarını eliyor değil SAYIYOR** ⇒ borç **`B-W1-3`**.
② **TOFU PİNİ DEĞİŞTİ** (`drift-2.34.0` → `2.34.3`), spec bunu **yetkilendirmemişti**. Cowork
bağımsız denetledi (`KANIT/o57/_o57_pin_denetimi.py`): disk sha'sı pinle **TUTUYOR**,
`sqlite3.wasm` pini **değişmemiş**, `pubspec.lock` drift sürümü **2.34.3** ⇒ tag ile **EŞLEŞİYOR**.
Yani tahmin değil, **gerçek bir sürüm uyuşmazlığının onarımı** — ama **beyan edilmiş sapmadır** ve
pin↔paket sürümünü karşılaştıran **kapı YOK**: uyuşmazlığı **çalışan uygulama** buldu, kapı değil
⇒ borç **`B-W1-4`**. *Bu, `K53/5`'in (**yürüyen iskelet önce**) bu oturumdaki en somut kanıtıdır:
kâğıt bu kusuru asla bulamazdı.*
③ **İKİ CANLI BELGE BİRDEN SARI:** `DURUM.md` pay **1.304** · `BORCLAR.md` pay **295** (`T7`
borçları yazınca 845'ten düştü). {R} **`B-W1-3` ve `B-W1-4` bilerek `BORCLAR.md`'ye YAZILMADI** —
yazım tavanı **AŞACAKTI** ve tavan kararı `K40` gereği Onur'dadır. Bu bir **sarkan atıftır** ve
gizlenmiyor: borçlar bu checkpoint'te, hükümde ve defterde yaşıyor, yalnız `BORCLAR.md`'de yok.
④ **`missingFeatures` BOŞ DEĞİL:** `G37/c` beyan etti (sessiz geçilmedi) ⇒ web kalıcılığı OPFS'e
değil bir **geri-düşüş** implementasyonuna dayanıyor. Kabul bunu **kapatmaz, taşır** (COOP/COEP →
`ADR 0004`).

{R} **KABUL, KAPANMAMIŞ SINIRLARLA VERİLDİ** (`A13`/`K130` · `SS2`/`K136` emsali). Yaşayan sınırlar:
14 statik mutantın **13'ü Code'un kaydından OKUNDU, Cowork'çe ölçülmedi** (biri örneklendi) · dört
koşan mutant (`M195`–`M197`, `M199`) **yeniden koşulmadı** çünkü `K80` Cowork'e ortamı yeniden
başlatmayı yasaklar; ham kayıtları okundu · `B-W1-1`…`B-W1-4`.
""".format(R=R, Y=Y)

KOKEN = " || Oturum 57; urun_kodu_satiri GIT'ten olculdu (K55), elle yazilmadi."
UYARI = (" URUN KODU SAYISI YANILTICI: 6743'u src/client/web/drift_worker.js (INDIRILEN SATICI "
         "VARLIGI), yalniz 30'u elle yazilmis kod (Program.cs 23 + appsettings 7). radar.py "
         "satici varliklarini elemiyor => borc B-W1-3.")

KAYITLAR = [
    {"tarih": "2026-08-05", "oturum": 57, "urun_kodu_satiri": 6773,
     "artefakt": "GOREV_CLAUDE_CODE/GOREV-W1-web-yuruyen-iskelet.md", "tur": 3,
     "asama": "T1-T7 Claude Code'ca kosuldu; Cowork BAGIMSIZ kabul kosumu yapti (K138)",
     "bulgu": {"bloker": 0, "major": 2, "minor": 2},
     "siniflar": ["olcum-aracinin-varsayimi", "beyansiz-sinir"],
     "bayt": 33077, "kapatilan": 11, "uretilen": 4,
     "not": ("KAPATILAN 11: on bir kabul kriteri; DOKUZU Cowork'un KENDI kosumuyla "
             "(verify.ps1 EXIT 0 - analyze 0 - test 522/522 - cors-kapisi altin kume 18/18 ve "
             "proje BULGU YOK - spec-kapi-kapsama/tek-kopya/kapi-ad-teklik/sayi-tazeligi hepsi 0 "
             "- urun kodu git'ten). AYRICA spec'in ## 8/9 ve ## 8/7 bilinmezleri KAPANDI ve "
             "denetimin B1/B2 bulgulari canli olcumle dogrulandi. URETILEN 4: B-W1-3 (satici "
             "varligi urun kodu sayiliyor) - B-W1-4 (pin<->paket surum kapisi YOK; uyusmazligi "
             "calisan uygulama buldu) - 13 statik mutant OKUNDU olculmedi - dort kosan mutant "
             "yeniden kosulmadi (K80)." + UYARI) + KOKEN},
    {"tarih": "2026-08-05", "oturum": 57, "urun_kodu_satiri": 6773,
     "artefakt": "KANIT/W1/01-COWORK-KABUL-HUKMU.md", "tur": 1,
     "asama": "K138: W1 KABUL EDILDI (Onur kilitledi), kapanmamis sinirlarla",
     "bulgu": {"bloker": 0, "major": 0, "minor": 4},
     "siniflar": ["beyansiz-sinir"],
     "bayt": 0, "kapatilan": 9, "uretilen": 4,
     "not": ("Bayt alani 0 -- boyut hukum dosyasinda olculur, buraya elle kopyalamak bayat-iddia "
             "uretirdi. BAGIMSIZ MUTANT ORNEKLEMESI: M192 gercek repoda kosuldu, kapi ISIRDI, "
             "geri alma BAYT-OZDES (1e31f5b4...) ve bu sha Code'un kaydiyla BIREBIR TUTUYOR. "
             "git restore KULLANILMADI (core.autocrlf)." + UYARI) + KOKEN},
    {"tarih": "2026-08-05", "oturum": 57, "urun_kodu_satiri": 6773,
     "artefakt": "araclar/cors-kapisi.py", "tur": 1,
     "asama": "yeni kapi: G35/a-d + G37/d + G38/c statik ayaklari, iki dilli (.cs + .dart)",
     "bulgu": {"bloker": 0, "major": 0, "minor": 0}, "siniflar": [],
     "bayt": 0, "kapatilan": 1, "uretilen": 0,
     "not": ("Altin kume 18/18, Cowork'un KENDI kosumu. Kume kor kapi birakmiyor: pozitif kontrol "
             "(AddMediator silinirse ORTAM HATASI, YESIL DEMEZ) - HEM // HEM /* */ yorum yolu "
             "(M193/M193c) - iki yanlis-pozitif kontrolu (M191b/M193b) - spec'te ISTENMEYEN iki "
             "ek vaka (driftDatabase yoklugu, isaret silinmesi). Bayt alani 0: dosya bu turda "
             "olculmedi, elle yazmak bayat-iddia uretirdi." + UYARI) + KOKEN},
    {"tarih": "2026-08-05", "oturum": 57, "urun_kodu_satiri": 6773,
     "artefakt": "src/client/web/drift_worker.js", "tur": 1,
     "asama": "TOFU pini drift-2.34.0 -> 2.34.3; surum uyusmazligi CALISAN UYGULAMA ile bulundu",
     "bulgu": {"bloker": 0, "major": 1, "minor": 0},
     "siniflar": ["kor-kapi"],
     "bayt": 354758, "kapatilan": 1, "uretilen": 1,
     "not": ("KAPATILAN 1: worker drift-2.34.0'a pinliyken pubspec.lock paketi 2.34.3 idi; web "
             "calistirilinca uyusmazlik ortaya cikti ve pin tazelendi. Cowork BAGIMSIZ dogruladi: "
             "disk sha'si pinle TUTUYOR, sqlite3.wasm pini DEGISMEDI, tag paket surumuyle "
             "ESLESIYOR. URETILEN 1: pin<->paket surumunu karsilastiran KAPI YOK (B-W1-4) -- bu "
             "kusuru kagit degil KOSAN URUN buldu, K53/5'in dogrudan kaniti. Spec bu degisikligi "
             "yetkilendirmemisti => BEYAN EDILMIS SAPMA." + UYARI) + KOKEN},
]

# --- DURUM.md: tek satir, TAVAN KORUMALI ---
ESKI = "İş **Claude Code'da** (`T1`–`T7`); kabul kriterleri spec `## 7`'de."
YENI = ("**KABUL EDİLDİ** (`K138`, Onur, 5 Ağu 2026) — hüküm `KANIT/W1/01-COWORK-KABUL-HUKMU.md`;\n"
        "on bir kriterin **dokuzu** Cowork'ün kendi koşumuyla. " + R + " Kabul **kapanmamış sınırlarla**: "
        "13 statik\nmutant **okundu, ölçülmedi** · dört koşan mutant **yeniden koşulmadı** (`K80`) · "
        "`B-W1-1`…`B-W1-4`\n(`B-W1-3`/`B-W1-4` **`BORCLAR.md`'ye YAZILAMADI** — tavan SARI, karar `K40` "
        "gereği Onur'da).")


def atomik(yol, metin, tavan=None):
    ham = metin.encode("utf-8")
    if tavan and len(ham) > tavan:
        raise RuntimeError("TAVAN ASILIR: %d > %d" % (len(ham), tavan))
    tmp = yol + ".tmp"
    with open(tmp, "wb") as f:
        f.write(ham)
        f.flush()
        os.fsync(f.fileno())
    if hashlib.sha256(open(tmp, "rb").read()).hexdigest() != hashlib.sha256(ham).hexdigest():
        raise RuntimeError(".tmp sha tutmadi")
    yed = yol + ".yedek"
    os.rename(yol, yed)
    try:
        os.rename(tmp, yol)
    except Exception:
        os.rename(yed, yol)
        raise
    os.remove(yed)


d = io.open(DURUM, encoding="utf-8", newline="").read()
if d.count(ESKI) != 1:
    print("[KIRMIZI] DURUM.md deseni %d kez -- HICBIR SEY YAZILMADI" % d.count(ESKI))
    sys.exit(2)
yeni_d = d.replace(ESKI, YENI, 1)
boyut = len(yeni_d.encode("utf-8"))
if boyut > 32768:
    print("[KIRMIZI] DURUM.md TAVANI ASAR (%d) -- HICBIR SEY YAZILMADI, karar K40 ile Onur'da" % boyut)
    sys.exit(3)

ISARET = "<!-- DIZIN:SON -->"
h = io.open(HAFIZA, encoding="utf-8", newline="").read()
L = h.split("\n")
adaylar = [i for i, s in enumerate(L) if s.strip() == ISARET and s.startswith("<!--")]
if len(adaylar) != 1:
    print("[KIRMIZI] satir-basi DIZIN:SON adayi %d -- YAZILMADI" % len(adaylar))
    sys.exit(2)
i = adaylar[0]

atomik(HAFIZA, "\n".join(L[:i + 1]) + "\n" + CP + "\n".join(L[i + 1:]))
print("K138 hafizaya yazildi (DIZIN:SON satir %d ALTINA) -> %d bayt" % (i + 1, os.path.getsize(HAFIZA)))
atomik(DURUM, yeni_d, 32768)
print("DURUM.md: %d -> %d bayt (pay %d)" % (len(d.encode('utf-8')), boyut, 32768 - boyut))

onceki_d = os.path.getsize(DEFTER)
with open(DEFTER, "rb") as f:
    f.seek(-1, os.SEEK_END)
    son = f.read(1)
parca = ("" if son == b"\n" else "\n") + "".join(
    json.dumps(k, ensure_ascii=True) + "\n" for k in KAYITLAR)
with open(DEFTER, "ab") as f:
    f.write(parca.encode("utf-8"))
    f.flush()
    os.fsync(f.fileno())
print("defter: %d kayit, %d -> %d bayt" % (len(KAYITLAR), onceki_d, os.path.getsize(DEFTER)))
print("BORCLAR.md'ye DOKUNULMADI (pay 295 b; B-W1-3/B-W1-4 beyan edildi, yazilmadi).")
