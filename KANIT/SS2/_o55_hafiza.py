# -*- coding: utf-8 -*-
# Oturum 55: K133 checkpointi. DIZIN:SON'un ALTINA. K60 atomik yazim (977 KB dosya!).
import sys, os, hashlib, json
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"

CP = """
## K133 — `SS2` v3 KİLİTLENDİ (Onur kilitledi, 3 Ağu 2026, oturum 55)

**Açılış 10/10 KOŞTU.** Ölçümler: `tek-kopya` YEŞİL (sapma +0) · `belge-tavan` **SARI** (T2,
DURUM.md pay 1.623) · `sayi-tazeligi` TEMİZ · `kapi-ad-teklik` YEŞİL · `oturum-sagligi` altın küme
**26/26** · `radar` altın küme **18/18** → proje **KIRMIZI, `R8` ISIRDI** (EXIT 2) · git `6baf651`,
`origin/main...HEAD` = **0/1** (push Onur'da), `index.lock` yok · ortam: postgres **Exited(255)**,
`:5298` boş, adb boş · bulut `S4` **183.509 token** YEŞİL, `S5` ısırmadı.

🔴 **AÇILIŞ ÜÇ BAYAT BEYAN ÖLÇTÜ (devir notunda YOKTU):**
① `DURUM.md` §4 *"`origin/main == HEAD`"* diyordu, ölçüm **0/1** verdi — hem **ölü beyan** hem
**`K82-b` ihlali** (push durumu belgeye yazılmaz, §2/7'de ölçülür). Satır **budandı**.
② `CLAUDE.md`'nin K53 gerekçesi `PROJE_HAFIZA.md`'yi *"488 KB'lik dosya"* diyor; iki bağımsız ölçüm
**977.850 bayt** verdi — beyanın **iki katı**. *(Bu tur düzeltilmedi; borç.)*
③ Devir notunun **(B) şıkkı çürüdü**: *"⑨ web borcu — kural açısından en temiz"* denmişti; ölçüm,
`GOREV_CLAUDE_CODE/` altındaki **25 spec'in hiçbirinin web olmadığını** gösterdi ⇒ o yol önce bir
**spec turu** ister ve `R8` onu yasaklar. **Devir notu beyandır, ölçülmeden iş listesine girmez** —
oturum 54'ün kendi dersi, ikinci kez uygulandı.

**KİLİT KARARI (Onur):** üç şık sunuldu, **(A) kapanmamış sınırlarla kilitle** seçildi. Ölçülen
gerekçe: `R8`'i söndürebilecek **tek hazır yol** SS2'ydi — `GOREV-A9c` kilitli ama *araç onarımı*
(`R8`'i düşürmez), web'in spec'i **yok**.

🔴 **BEŞ BLOKERİN HİÇBİRİ BORÇLANAMADI.** Sınıflama `K53/3` (*"KAPI borçlanamaz, yalnız kural"*)
ile yapıldı: `B2-1`/`B2-3`/`B2-2` **KAPI** (`G32/a`·`G31/a`·`G33/c` **kör**) · `B2-4` **ÜRÜN**
(`/e`'nin şart 3'ü atlaması **yeni veri kaybı** — kırmızı çizgi) · `B2-5` **spec içi çelişki**
(`T1` bump ediyor, `T2` *"regresyon yok"* diyor ⇒ builder kilitlenir). Beşi de **kapatıldı**;
13 major `S11`–`S14` + `B-SS2-4` olarak **borçlandı**.

**Onur'un kilitlediği iki tasarım kararı:** ① `B2-2` → yeni `G33/d` ayağı + `M176b` (fan-out'un
yükü **çakışma kaydı DOLU iken** davranışsal ölçülür; `M176` statik `G33/c`'ye indi ve `G10` şartı
kalktı) ② MAJOR-8 → `cakismaCoz` **dış transaction açar**, `G34/f`+`M177` kilidi korunur; drift'in
savepoint'e indirgemesi **`S11` ile `[ÖLÇÜLMEDİ]` beyan edildi**, `T6` ölçer.

**Ölçülen bağımlılık:** `B2-4`'ün onarımı MAJOR-1'e bağımlıydı — şart 3'ün iki ön koşulu
(`_GorevGuncellemesi`'nin kanal başına kazanan anahtar/`clientHex` taşıması,
`UzakDegisiklikUygulayici`'nın cihazın `clientId`'sini alması) **kodda yoktu**; v2'nin *"üç-kanal
eşlemesi `g` içinde hazır"* gerekçesi ölçümle çürüktü. İkisi de `D-SS2-2`'ye yazıldı.

**K127 — ZORUNLU ALAN:** tur 1 → `KANIT/SS2/00-DENETIM-kilit-oncesi.md` · tur 2 →
`KANIT/SS2/02-DENETIM-tur2.md`. 🔴 **ÜÇÜNCÜ TUR KOŞULMADI** ve gerekçesi yazılı (`K53/1`: tur 2
mimari bloker bulmadı; `K53/4`: `R8`). Bu, K127'nin *"yoksa açıkça yazar"* şıkkının **ilk kullanımı**.

**Mekanik kapılar (v3, cihazda):** `spec-kapi-kapsama` **EXIT 0** (4 kapı / 11 kural / **23 mutant**
— v2'de 20 / 3 gerekçeli borç) · `kapi-ad-teklik` YEŞİL · `dosya-kimlik` **46.003 b · `420E9F91`**,
U+FFFD 0, CRLF 0 · `tek-kopya` YEŞİL. Yama **16/16**, K60 atomik. Hüküm `KANIT/SS2/03-v3-KILIT.md`,
tekrarlanabilir yama `KANIT/SS2/_ss2_v3_yama.py`.

🔴 **SARKAN ATIF KAPANDI:** spec §8 `B-SS2-1`/`2`/`3`'e atıf yapıyordu ve **BORCLAR.md'de karşılığı
YOKTU** (v2'de de yoktu); kilit onları sarkan atıf yapacaktı. Dördü de yazıldı.

🔴 **BU OTURUMUN KENDİ KUSURU — BUDAMA TAHMİN EDİLDİ, ÖLÇÜLMEDİ.** `DURUM.md` budamasının **net
negatif** (~−430 b) olacağı hesaplandı; gerçek ölçüm **+465 b** verdi ⇒ `T2` **hâlâ SARI** (pay
1.158) ve `BORCLAR.md` de SARI'ya düştü (pay **857**). Sınıf: `olcum-aracinin-varsayimi`. **Ders:
bayt tahmini bayt ölçümü değildir** — budama, kapı koşulmadan *"yeterli"* ilan edilemez.

🔴 **`R8` BU OTURUMDA SÖNMEDİ.** `urun_kodu_satiri = 0` (dürüstçe ölçüldü): kilit spec işidir, ürün
kodu `T1`'de **Claude Code'un elinden** girer. Şık metnindeki *"ürün kodu akar"* ifadesi **sonraki
el** içindir; radar bir sonraki koşumda **üçüncü sıfırı** görecektir.
"""

RADAR = [
{"tarih":"2026-08-03","oturum":55,"urun_kodu_satiri":0,
 "artefakt":"GOREV_CLAUDE_CODE/GOREV-SS2-cakisma-cozumu.md","tur":3,
 "asama":"tur-2 denetiminin 5 blokeri KAPATILDI, 13 major borclandi, v3 KILITLENDI (K133)",
 "bulgu":{"bloker":0,"major":0,"minor":0},
 "siniflar":["esdeger-mutant","kor-kapi"],
 "bayt":46003,"kapatilan":18,"uretilen":0,
 "not":"KILIT. Bes bloker K53/3'e gore siniflandi ve HICBIRI borclanamadi: uc KAPI (G32/a, G31/a, G33/c kor), bir URUN (D-SS2-3/e sart 3'u atliyor = YENI veri kaybi), bir spec ici celiski (g2 testi schemaVersion==4 pinli). Onarim: M172'nin hedefi yazim sirasi degil OKUMA KAYNAGI yapildi; M171b tersine cevrildi + yanlis-pozitif kontrolu M171c'ye ayrildi; M176 statik G33/c'ye indi ve fan-out yuku yeni G33/d + M176b ile davranissal olculur; /e'ye sart 3 eklendi (G32/e2 + M180b); T1'e dump SIRASI ve g2 pin guncellemesi yazildi. Onur iki tasarim karari kilitledi (G33/d ekleme; cakismaCoz DIS transaction). MAJOR-1 bagimliligi olculdu: sart 3'un iki on kosulu kodda YOKTU, D-SS2-2'ye yazildi. UCUNCU denetim turu K53/1 geregi ACILMADI, gerekce KANIT/SS2/03-v3-KILIT.md'de (K127'nin 'yoksa acikca yazar' sikkinin ILK kullanimi). Dort mekanik kapi YESIL; spec-kapi-kapsama 20 -> 23 mutant. BEYAN EDILMIS SINIR: kapsama olcumu ISIRMA olcumu degildir -- uc onarim yalniz T7'de kosan kodla kanitlanir (borc B-SS2-4)."},
{"tarih":"2026-08-03","oturum":55,"urun_kodu_satiri":0,"artefakt":"DURUM.md","tur":22,
 "asama":"olu beyan budandi (K82-b ihlali), A13 anlatimi K73 geregi kisaldi, K133 + kimlik yazildi",
 "bulgu":{"bloker":0,"major":0,"minor":1},
 "siniflar":["olu-beyan","olcum-aracinin-varsayimi"],
 "bayt":31610,"kapatilan":2,"uretilen":1,
 "not":"KAPANAN: (1) 'origin/main == HEAD' olu beyani -- olcum 0/1 verdi, ustelik K82-b push durumunun belgeye YAZILMASINI yasakliyor; satir silindi. (2) A13 anlatimi K73 geregi tek paragrafa indi. URETILEN: budama NET NEGATIF (~-430 b) TAHMIN EDILDI, olcum +465 b verdi => T2 hala SARI (pay 1158) ve ayni turda BORCLAR.md de SARI'ya dustu (pay 857). Sinif: olcum-aracinin-varsayimi. Ders: bayt TAHMINI bayt OLCUMU degildir; budama kapi kosulmadan 'yeterli' ilan edilemez. Tavan/budama karari K40 geregi ONUR'DA."},
{"tarih":"2026-08-03","oturum":55,"urun_kodu_satiri":0,"artefakt":"PROJE_HAFIZA.md","tur":38,
 "asama":"K133 checkpointi DIZIN:SON'un ALTINA yazildi + dizin yeniden uretildi",
 "bulgu":{"bloker":0,"major":0,"minor":0},
 "siniflar":[],
 "bayt":0,"kapatilan":1,"uretilen":0,
 "not":"KAPANAN: K129/K130 checkpointleri dosyanin SONUNA eklenmisti (kural ihlali, satir 269'da kayitli); K133 kurala uygun olarak DIZIN:SON'un ALTINA yazildi. Bayt alani 0 -- boyut ayni betikte YUKARIDA olculdu, buraya elle kopyalamak bayat-iddia uretirdi (K132'nin deseni)."},
]

# ---- PROJE_HAFIZA.md
yol = os.path.join(KOK, "PROJE_HAFIZA.md")
with open(yol, "rb") as f: ham = f.read()
metin = ham.decode("utf-8")
ISARET = "<!-- DIZIN:SON -->\n"
if metin.count(ISARET) != 1:
    print("HATA: DIZIN:SON isareti %d kez bulundu." % metin.count(ISARET)); sys.exit(2)
metin = metin.replace(ISARET, ISARET + CP, 1)
yeni = metin.encode("utf-8")
if len(yeni) <= len(ham):
    print("HATA: append-only dosya BUYUMEDI."); sys.exit(3)
tmp, yedk = yol + ".tmp", yol + ".yedek"
with open(tmp, "wb") as f: f.write(yeni)
if os.path.exists(yedk): os.remove(yedk)
os.rename(yol, yedk)
try: os.rename(tmp, yol)
except Exception as e:
    os.rename(yedk, yol); print("HATA: takas patladi, GERI ALINDI:", e); sys.exit(4)
with open(yol, "rb") as f: son = f.read()
if son != yeni:
    os.remove(yol); os.rename(yedk, yol); print("HATA: sha uyusmadi, GERI ALINDI."); sys.exit(5)
os.remove(yedk)
print("PROJE_HAFIZA.md: %d -> %d bayt (+%d) · sha8 %s"
      % (len(ham), len(son), len(son)-len(ham), hashlib.sha256(son).hexdigest()[:8].upper()))

# ---- PROJE_RADAR.jsonl (append)
ryol = os.path.join(KOK, "PROJE_RADAR.jsonl")
with open(ryol, "rb") as f: rham = f.read()
ek = "".join(json.dumps(k, ensure_ascii=True) + "\n" for k in RADAR).encode("utf-8")
if not rham.endswith(b"\n"): ek = b"\n" + ek
with open(ryol, "ab") as f: f.write(ek)
with open(ryol, "rb") as f: rson = f.read()
print("PROJE_RADAR.jsonl: %d -> %d bayt (+%d kayit)" % (len(rham), len(rson), len(RADAR)))
print("HUKUM: TAMAM")
