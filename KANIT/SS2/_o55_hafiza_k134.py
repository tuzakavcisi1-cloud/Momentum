# -*- coding: utf-8 -*-
import sys, os, hashlib, json
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
YOL = os.path.join(KOK, "PROJE_HAFIZA.md")
ISARET = "<!-- DIZIN:SON -->\n"

CP = """
## K134 — `SS2` T0–T8 UYGULANDI (Claude Code) + COWORK KABUL KOŞUMU · `R8` SÖNDÜ (oturum 55)

**Commit `b900bae`** — 50 dosya, **+5831/−69**. 🟢 **`R8` SÖNDÜ:** `urun_kodu_satiri = 1773`,
`radar.py . --olc-urun-kodu 20e615e` ile **git'ten türetildi**, elle yazılmadı. Radar artık
*"URUN KODU DURGUNLUGU"* bildirmiyor. Oturum 53–54–55'in sıfır serisi kırıldı.

🔴 **BULGU: Claude Code COMMIT ATMADAN bıraktı.** Bütün iş çalışma ağacındaydı; `20e615e..HEAD`
**boştu**. Ürün kodu git'e girmeden `R8` **sönmez** (`K55`: sayı git'ten türetilir) — yani "bitirdim"
beyanı, ölçülebilir bir bitiş **değildi**. Commit'i Cowork attı.

**COWORK'ÜN KENDİ KABUL KOŞUMU (K26 — builder'ın beyanı okunmadı, ölçüldü):**
kriter 1 `flutter analyze` **No issues found!** EXIT 0 · kriter 2 `flutter test` **522/522**
(`A13`'te 500) · kriter 3 `ss2-kapisi.py .` BULGU YOK **ve** `G32/a` testi `kaybedenDeger` /
`kazananDeger` / `kazananClientHex`'i **tam dizeyle** ölçüyor (kör değil) · kriter 5
`spec-kapi-kapsama` EXIT 0 · kriter 6 `ss2-kapisi.py --altin-kume` **10/10** EXIT 0 — ve küme
v3'ün üç onarımını **gerçekten** taşıyor (`M171b` tersine çevrilmiş · `M171c` ayrı yanlış-pozitif
vakası · `count()` çok-satır deseni) · kriter 7 **`verify.ps1` EXIT 0**, `== VERIFY PASSED ==`,
backend **120/120**, CVE **0** · kriter 9 ham çıktılar `KANIT/SS2/` altında.

🔴 **KRİTER 8 ÖLÇÜLMEDİ — KABUL BU OTURUMDA VERİLMEDİ.** Uçtan uca senaryo iki emülatör + backend +
HLC sırası ister; bağlam yetmedi. *"Sekizde sekiz"* demek `§4`'ün yasakladığı şeydir.

🔴 **KRİTER 7'NİN İKİ KOŞUMU — ORTAM KUSURUNU ÜRÜNE YAZMAMA DERSİNİN ÖLÇÜLMÜŞ HÂLİ.** İlk koşum
**EXIT 1** verdi ve **53/56** test düştü; sebep üründe değildi — `momentum-postgres` **Exited(255)**
olduğu için Testcontainers Docker'a bağlanamıyordu. Onur'un **açık izniyle** (K80) `docker start`
koşuldu, üçüncü yoklamada `healthy` görüldü (sabit bekleme yok, tavanlı yoklama) ve aynı zincir
**EXIT 0** verdi. **Ölçüm değişmedi, ortam değişti.**

🔴 **BU OTURUMUN İKİNCİ KUSURU — COWORK YANLIŞ HEDEFİ VURDU VE NEREDEYSE BUILDER'I SUÇLUYORDU.**
Bağımsız mutant örneklemesinde `gorev_deposu.dart`'taki **ilk** `distinct: true` eşleşmesi
`distinct: false` yapıldı; test **geçti** ⇒ betik *"ESDEGER MUTANT!"* hükmü bastı. Altı eşleşme
**tek tek** ölçülünce görüldü ki **ikisi yorum satırı**, dördü gerçek `count()` çağrısı ve
**dördü de** `G33/d`'yi düşürüyor. **Kusur Cowork'teydi; builder'ın beyanı bu noktada DOĞRULANDI.**
Ders: *bir mutantın ısırmaması, önce mutantın yanlış yere düştüğünü düşündürür.*
Kanıt: `KANIT/SS2/T7-COWORK-distinct-6li-olcum.txt`.

**İKİ MINOR (üretildi, kapatılmadı):**
① `M172` **ısırıyor** ama spec'in *"`G32/a` KIRMIZI — kaybeden kazananla bayt-özdeş olur"* beklentisi
gerçeği tarif etmiyor: kaybeden yazımdan sonra okununca şart 4 **eşitlik** verir ve kayıt **hiç
oluşmaz** ⇒ `G32/a,e,e2,g,h` **beşi birden** düşer. Mutant hedefini vuruyor, **açıklaması yanlış**.
② `ss2-kapisi.py`'nin `G33/c` ayağında **yorum-atlama ölçülmemiş**; `G31/a`'da `M171b`/`M171c` ile
ölçülüyor, `G33/c`'de karşılığı yok. Cowork'ün yukarıdaki kusuru tam bu boşluğun içine düştü.

**SIRADAKİ:** kriter 8 (uçtan uca) → `SS2` kabul hükmü. Docker **açık bırakıldı** (kriter 8 zaten
istiyor); kapatma `K80` gereği Onur'un izniyle yapılır.
"""

with open(YOL, "rb") as f: ham = f.read()
metin = ham.decode("utf-8")
if metin.count(ISARET) != 1:
    print("HATA: DIZIN:SON %d kez." % metin.count(ISARET)); sys.exit(2)
metin = metin.replace(ISARET, ISARET + CP, 1)
yeni = metin.encode("utf-8")
if len(yeni) <= len(ham): print("HATA: buyumedi."); sys.exit(3)
tmp, yedk = YOL + ".tmp", YOL + ".yedek"
with open(tmp, "wb") as f: f.write(yeni)
if os.path.exists(yedk): os.remove(yedk)
os.rename(YOL, yedk)
try: os.rename(tmp, YOL)
except Exception as e:
    os.rename(yedk, YOL); print("HATA:", e); sys.exit(4)
with open(YOL, "rb") as f: son = f.read()
if son != yeni:
    os.remove(YOL); os.rename(yedk, YOL); print("HATA: sha."); sys.exit(5)
os.remove(yedk)
print("PROJE_HAFIZA.md: %d -> %d (+%d)" % (len(ham), len(son), len(son)-len(ham)))

k = {"tarih":"2026-08-03","oturum":55,"urun_kodu_satiri":1773,
     "artefakt":"KANIT/SS2/03-v3-KILIT.md","tur":2,
     "asama":"Cowork kabul kosumu: 8 kriter olculdu, kriter 8 ACIK, KABUL VERILMEDI",
     "bulgu":{"bloker":0,"major":0,"minor":2},"siniflar":["kor-kapi","olcum-aracinin-varsayimi"],
     "bayt":5621,"kapatilan":7,"uretilen":2,
     "not":"KAPATILAN 7: kriter 1,2,3,5,6,7,9 Cowork'un KENDI kosumuyla olculdu (analyze 0 - test 522/522 - ss2-kapisi BULGU YOK + G32/a degeri olcuyor - kapsama EXIT 0 - altin kume 10/10 - verify.ps1 EXIT 0 backend 120/120 CVE 0 - ham ciktilar yerinde). URETILEN 2 MINOR: M172'nin spec'teki 'beklenen' aciklamasi gercegi tarif etmiyor (bes ayak birden duser); ss2-kapisi.py G33/c'de yorum-atlama olculmemis. KRITER 8 (uctan uca) OLCULMEDI => KABUL YOK. Docker Onur'un ACIK izniyle acildi (K80); verify'in onceki EXIT 1'i ORTAM kusuruydu ve ayni zincir docker healthy iken EXIT 0 verdi."}
with open(os.path.join(KOK, "PROJE_RADAR.jsonl"), "a", encoding="utf-8", newline="\n") as f:
    f.write(json.dumps(k, ensure_ascii=True) + "\n")
print("PROJE_RADAR.jsonl: kabul kosumu kaydi eklendi.")
