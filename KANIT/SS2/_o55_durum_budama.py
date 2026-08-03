# -*- coding: utf-8 -*-
# Oturum 55: DURUM.md §5 BUDAMASI. Gerekce -> hafiza; BEYAN korunur.
# Kanonik gerekce: §5 basligi "tek satir; gerekce PROJE_HAFIZA.md'de" diyor ve bu dort madde
# kendi kurallarini ihlal ediyordu. Ayrica K58/K117-K126'nin gerekcesi belge-tavan-kapisi.py'nin
# KENDI banner'inda zaten yazili => DURUM.md'deki kopya `kanonik-kopya` kusurudur.
import sys, os, hashlib, json
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
YOL = os.path.join(KOK, "DURUM.md")
Y = []

Y.append(("K58",
"""- **K58** — `DURUM.md` tavanı **12 → 32 KB**. Gerekçe okuma kapasitesi **değil**: ① R4 freni, ② dikkat (3,5k token okunur, 40k *göz gezdirilir*). Gevşetmenin dayanağı: bayat-atıf sınıfı **mekanikleşti**. 🟢 Tavanı artık `belge-tavan-kapisi.py` (altın küme **13/13**) zorluyor ve §2 adım 3'te koşuyor — zayıf kontrol **KAPANDI**. 🔴 Aracın **banner sürümü bayat** (`1.0.0`), borç `B-O50-2`. Ayrıca `PROJE_HAFIZA.md`'ye **mekanik dizin** (`hafiza-dizin.py`); **yeni checkpoint `<!-- DIZIN:SON -->` ALTINA** eklenir.""",
"""- **K58** — `DURUM.md` tavanı **32 KB**; kapısı `belge-tavan-kapisi.py`, §2 adım 3'te koşar. 🔴 Aracın **banner sürümü bayat** (`1.0.0`), borç `B-O50-2`. 🔴 **Yeni checkpoint `<!-- DIZIN:SON -->` ALTINA** eklenir (`hafiza-dizin.py`). Gerekçe (R4 freni + dikkat): hafıza K58."""))

Y.append(("K117-K126",
"""- 🔒 **K117 · K126 — `BORCLAR.md` TAVANI 16 → 24 → 32 KB (Onur; 2 ve 3 Ağu 2026):** iki turun da ölçülmüş gerekçesi tek cümledir — **bu dosyada budama ancak bir borç KAPANDIĞINDA işe yarar**; oturum 52'de `T2` SARI verdi (pay **324 b**) ve kapanan borç **yoktu**. 🔴 **Beyan edilmiş bedel: tavan artık `DURUM.md` ile EŞİT; *"borç listesi canlı durumun yarısı kadar kalmalı"* tasarımı ÖLDÜ.** K40 şartı ödendi: **vaka 13** gevşetmenin *fiilen canlı* olduğunu pinler ve körlüğü **mutantla yanlışlandı** — tavan sessizce geri çekilince küme **iki vakada birden düştü**, araç `sha8` önce/sonra **`6804636F` özdeş**. Gerekçe: hafıza K126.""",
"""- 🔒 **K117 · K126 — `BORCLAR.md` TAVANI 32 KB (Onur; 2 ve 3 Ağu 2026):** ölçülmüş gerekçe tek cümledir — **bu dosyada budama ancak bir borç KAPANDIĞINDA işe yarar**. 🔴 **Beyan edilmiş bedel: tavan artık `DURUM.md` ile EŞİT;** *"borç listesi canlı durumun yarısı kadar kalmalı"* tasarımı **ÖLDÜ**. K40 şartı **vaka 13** ile ödendi. Gerekçe: hafıza K117/K126."""))

Y.append(("K127",
"""- 🔒 **K127 — KİLİT ÖNCESİ BAĞIMSIZ DENETİM (Onur kilitledi, 3 Ağu 2026):** bir spec/ADR kilitlenirken yazılan checkpoint, o turda koşan **bağımsız denetçinin ÇIKTI YOLUNU** taşımak zorundadır; yoksa *"denetim KOŞULMADI"* diye **açıkça** yazar. Kanonik metin **`CLAUDE.md`**'de (K81'in altında), buraya kopyalanmaz. Ölçülmüş gerekçe kuralın doğduğu turdur: `A13` denetimsiz kilitlendi, kilitten **sonra** koşan iki bağımsız ajan **3 bloker + 6 major + 5 minor** buldu ve hiçbiri koşan kod gerektirmiyordu. **K53/1 ile çelişmez** — tavan hâlâ bir tur; K127 turun *sayısını* değil **zamanlamasını** sabitler. 🔴 **Mekanik kapısı YOK** ⇒ borç `B-O52-2`.""",
"""- 🔒 **K127 — KİLİT ÖNCESİ BAĞIMSIZ DENETİM (Onur kilitledi, 3 Ağu 2026):** kilit checkpoint'i **denetçinin ÇIKTI YOLUNU** taşır; yoksa *"denetim KOŞULMADI"* diye **açıkça** yazar. Kanonik metin **`CLAUDE.md`**'de, buraya kopyalanmaz. **K53/1 ile çelişmez** — turun *sayısını* değil **zamanlamasını** sabitler. 🟢 `K133`'te *"yoksa açıkça yazar"* şıkkı **ilk kez** kullanıldı. 🔴 **Mekanik kapısı YOK** ⇒ borç `B-O52-2`. Gerekçe: hafıza K127."""))

Y.append(("K129-K130",
"""- 🔒 **K129 · K130 — `A13` KABUL + SPEC YENİDEN KİLİTLENDİ (Onur, 3 Ağu 2026, oturum 53).** K73 gereği `A13`'ün kuralları artık prozada değil **`A13/G27`–`G30` kapılarında + `M162`–`M170` mutantlarında** koşuyor. 🔴 **Yaşayan beş sınır (§9'da yazılı, hepsi borç):** `G29/b` **kör** · `--fatal-infos`'un taşıyıcılığı **gösterilemez** (3.44.6'da varsayılan açık) · `G27/a`·`G27/c`·`G30/b` **mutantsız** · kriter 7'nin **dinamik ayaklarının aracı yok** · aksiyonlar **sha'ya pinsiz**. 🔴 **K127'nin ilk gerçek sınavı:** denetim kilitten önce koştu ve spec'te **ölçümle yanlışlanmış iki gerekçe** buldu. Ders: **okunan onarım, ölçülmüş onarım değildir.** Gerekçe: hafıza K129/K130.""",
"""- 🔒 **K129 · K130 — `A13` KABUL + spec yeniden kilitlendi (Onur, 3 Ağu 2026, oturum 53).** Kurallar `A13/G27`–`G30` kapılarında + `M162`–`M170` mutantlarında koşuyor. 🔴 **Yaşayan beş sınır (hepsi borç, `B-O53-1`…`5`):** `G29/b` **kör** · `--fatal-infos` **taşıyıcı değil** · `G27/a`·`G27/c`·`G30/b` **mutantsız** · kriter 7'nin **dinamik ayaklarının aracı yok** · aksiyonlar **pinsiz**. Ders: **okunan onarım, ölçülmüş onarım değildir.** Gerekçe: hafıza K129/K130."""))

with open(YOL, "rb") as f: ham = f.read()
metin = ham.decode("utf-8")
print("GIRDI :", len(ham), "bayt")
hata = 0
for ad, eski, yeni in Y:
    n = metin.count(eski)
    if n != 1:
        print("  [HATA] %s: eslesme %d" % (ad, n)); hata += 1
    else:
        metin = metin.replace(eski, yeni, 1)
        print("  [OK]   %-12s  %+d bayt" % (ad, len(yeni.encode()) - len(eski.encode())))
if hata:
    print("\nHUKUM: DOKUNULMADI (%d hata)." % hata); sys.exit(2)

yeni_ham = metin.encode("utf-8")
if b"\r\n" in yeni_ham or "\ufffd" in metin:
    print("HUKUM: CRLF/U+FFFD -- iptal."); sys.exit(3)
tmp, yedk = YOL + ".tmp", YOL + ".yedek"
with open(tmp, "wb") as f: f.write(yeni_ham)
if os.path.exists(yedk): os.remove(yedk)
os.rename(YOL, yedk)
try: os.rename(tmp, YOL)
except Exception as e:
    os.rename(yedk, YOL); print("HUKUM: takas patladi, GERI ALINDI:", e); sys.exit(4)
with open(YOL, "rb") as f: son = f.read()
if son != yeni_ham:
    os.remove(YOL); os.rename(yedk, YOL); print("HUKUM: sha uyusmadi, GERI ALINDI."); sys.exit(5)
os.remove(yedk)

TAVAN = 32768
pay = TAVAN - len(son)
esik = int(TAVAN * 0.05)
print("\nCIKTI :", len(son), "bayt · sha8", hashlib.sha256(son).hexdigest()[:8].upper())
print("DELTA :", len(son) - len(ham), "bayt")
print("PAY   :", pay, "b   (esik %d) =>" % esik, "YESIL" if pay > esik else "HALA SARI")

# defter kaydi -- bayt alani OLCULEN degerden yazilir, elle kopyalanmaz (D1)
kayit = {"tarih":"2026-08-03","oturum":55,"urun_kodu_satiri":0,"artefakt":"DURUM.md","tur":23,
 "asama":"§5 budamasi: dort kilidin GEREKCESI hafizaya devredildi, BEYANLARI korundu",
 "bulgu":{"bloker":0,"major":0,"minor":0},
 "siniflar":["kanonik-kopya"],
 "bayt":len(son),"kapatilan":4,"uretilen":0,
 "not":"Onur kilitledi. Kanonik gerekce: §5 basligi 'tek satir; gerekce PROJE_HAFIZA.md'de' diyor ve K58/K117-K126/K127/K129-K130 kendi kurallarini ihlal ediyordu (5-10 satir). Ayrica K58 ve K117/K126'nin gerekce metni belge-tavan-kapisi.py'nin KENDI banner'inda zaten yazili => DURUM.md'deki kopya kanonik-kopya kusuruydu (bu dosyada 5 turdur sayiliyor). BEYANLAR KORUNDU: banner bayatligi (B-O50-2), tavan bedeli, K127'nin kapisizligi (B-O52-2), A13'un yasayan bes siniri (B-O53-1..5). Bu turda TAHMIN YOK: pay degeri betigin KENDI olcumunden yazildi ve hemen ardindan belge-tavan-kapisi.py kosuldu."}
ryol = os.path.join(KOK, "PROJE_RADAR.jsonl")
with open(ryol, "a", encoding="utf-8", newline="\n") as f:
    f.write(json.dumps(kayit, ensure_ascii=True) + "\n")
print("PROJE_RADAR.jsonl: DURUM.md tur 23 kaydi eklendi (bayt =", len(son), "olculdu).")
