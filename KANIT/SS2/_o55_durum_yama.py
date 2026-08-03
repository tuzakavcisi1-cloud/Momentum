# -*- coding: utf-8 -*-
# Oturum 55: DURUM.md budama+guncelleme, BORCLAR.md B-SS2-1..4. K60 atomik yazim.
import sys, os, hashlib
sys.stdout.reconfigure(encoding="utf-8", errors="replace")
KOK = r"C:\dev\Momentum"
ISLER = {}   # yol -> [(ad, eski, yeni), ...]

def yama(dosya, ad, eski, yeni):
    ISLER.setdefault(dosya, []).append((ad, eski, yeni))

# ================================================================= DURUM.md
D = "DURUM.md"

yama(D, "son guncelleme (BUDAMA)",
"""> **Son güncelleme:** 3 Ağu 2026, **oturum 53 (K129 `A13` KABUL · K130 spec yeniden kilitlendi)** — açılışın 10 adımı koştu, `A13` kriter 7 ve 8 ölçüldü, **iOS ilk kez CI'da derlendi**. 🔴 **K127 ilk kez işe yaradı ve kendi kuralı doğruladı:** kabul öncesi bağımsız denetim (3 denetçi) **1 bloker + 5 major + 8 minor** buldu; bloker, oturum 52'nin *"düzelttim"* sandığı `M167` eşdeğerliğiydi — **onarım da yanlıştı** (`--fatal-infos` Flutter 3.44.6'da varsayılan **AÇIK** ⇒ bayrak no-op; Cowork gerçek depoda ölçtü). Ders: **okunan onarım, ölçülmüş onarım değildir.** Ayrıca `G29/b` **kör ayak** çıktı, `08-OZET.md` bayat bulundu, Cowork'ün kendi ölçüm betiğinde **ters etiket** yakalandı. Beşi de kapatıldı, spec **K130** ile yenilendi, beş yeni borç (`B-O53-1`…`5`) açıldı. *(Oturum 39–52 arşivde.)*""",
"""> **Son güncelleme:** 3 Ağu 2026, **oturum 55 (`K133` — `SS2` v3 KİLİTLENDİ)** — açılışın 10 adımı koştu; tur 2 denetiminin **beş blokeri de kapatıldı** (`K53/3`'e göre **hiçbiri borçlanamıyordu**: üçü kör kapı, biri ürün veri kaybı, biri spec içi çelişki), 13 majoru borçlandı. Kilit **kapanmamış sınırlarla** verildi (`A13`/`K130` emsali); hüküm `KANIT/SS2/03-v3-KILIT.md`. *(Oturum 39–54 anlatımı arşivde — `PROJE_HAFIZA.md` K129–K133.)*""")

yama(D, "A13 blogu (BUDAMA, K73)",
"""🟢 **⑦ `GOREV-A13` KABUL EDİLDİ (K129/K130, oturum 53 · Onur kilitledi).** Dokuz kriterin dokuzu da
Cowork'ün KENDİ koşumuyla geçti (K26). **iOS bu depoda İLK KEZ gerçekten derlendi** — GitHub
macOS runner'ında: `✓ Built build/ios/iphoneos/Runner.app (**18.7MB**)` · `🎉 **500** tests passed.`
· `analyze --fatal-infos` **0 sorun** · koşan mutantlar **`M167`–`M169` 3/3 ISIRDI** (her birinde
**doğru iş** düştü) · `M170` ısırdı. Hüküm **`KANIT/A13/10-COWORK-KABUL-HUKMU.md`**.
🔴 **K130 — spec kilidi AÇILDI ve YENİLENDİ; kabul KAPANMAMIŞ SINIRLARLA verildi.** Beşi de
**§9'da yazılı ve borçlandı** (`B-O53-1`…`5`): `G29/b` **kör** · `--fatal-infos`'un taşıyıcılığı
**gösterilemez** · `G27/a`·`G27/c`·`G30/b` **mutantsız** · kriter 7'nin **dinamik ayaklarının
aracı yok** · aksiyonlar **pinsiz**. Onarım **builder'ın** (K34-f). Gerekçe **§5/K130 + arşiv**.
🟢 `A13` **§9/5 · §9/10 KAPANDI**, §9/4 kısmen (ayrıntı kabul hükmünde). 🔴 Kota `[ÖLÇÜLMEDİ]`.""",
"""🟢 **⑦ `A13` KABUL (K129/K130, oturum 53 · Onur kilitledi).** Dokuz kriterin dokuzu Cowork'ün
KENDİ koşumuyla geçti (K26); **iOS bu depoda İLK KEZ derlendi**. Hüküm
`KANIT/A13/10-COWORK-KABUL-HUKMU.md`. Kabul **kapanmamış beş sınırla** verildi (`B-O53-1`…`5`;
gerekçe §5/K130). 🟢 §9/5 · §9/10 KAPANDI, §9/4 kısmen. 🔴 Kota `[ÖLÇÜLMEDİ]`.""")

yama(D, "SS2 blogu",
"""🔴 **⑧ `SS2` v2: İKİ TUR DENETİM DÜŞÜRDÜ (K132).** Kalan 5 bloker **mimari DEĞİL**; kanıt
`KANIT/SS2/02-DENETIM-tur2.md`. **K53/1 ⇒ üçüncü kâğıt turu AÇILAMAZ.**""",
"""🟢 **⑧ `SS2` v3 KİLİTLENDİ (`K133`, oturum 55 · Onur kilitledi).** Tur 2'nin **beş blokeri de
kapatıldı**; **13 major borçlandı** (`S11`–`S14` + `B-SS2-4`). Üçüncü denetim turu `K53/1` gereği
**açılmadı**, gerekçe kanıtta yazılı (K127'nin *"yoksa açıkça yazar"* şıkkı). Dört mekanik kapı
YEŞİL. Hüküm **`KANIT/SS2/03-v3-KILIT.md`**. 🔴 **İş Claude Code'da: `T0` → `T1`.**""")

yama(D, "R8 blogu",
"""🔴 **R8 SERT DURAK YANDI** (53 ve 54 = **0** ürün kodu) ⇒ **oturum 55 ÜRÜN KODUYLA başlar** (K53/4).
→ ⑨ web borcu + **backend CI** (`D-A13-4`) + release → ⑩ `ADR 0004` + vitrin.""",
"""🔴 **`R8` AÇIK — oturum 55'te ÖLÇÜLDÜ ve ISIRDI** (53 ve 54 = **0** ürün kodu). Sönmesi
`SS2/T1`'in **ilk satırına** bağlıdır; `T0` araçtır, **saymaz**. 🔴 **ÖLÇÜLDÜ (oturum 55): ⑨ web
borcunun HAZIR SPEC'İ YOK** — `GOREV_CLAUDE_CODE/` altındaki 25 spec'in **hiçbiri web değil** ⇒ o
yol önce bir **spec turu** ister ve `R8` onu yasaklar; devir notunun *"kural açısından en temiz"*
beyanı böylece **çürüdü**. → ⑨ web + **backend CI** (`D-A13-4`) + release → ⑩ `ADR 0004` + vitrin.""")

yama(D, "olu satir (K82-b ihlali) SILINIYOR",
"""🟢 **ONUR'A AÇIK İŞ KAPANDI (oturum 54'te ÖLÇÜLDÜ):** uzakta yalnız `main` · `KANIT/A13` izlenir
(`??` 0) · `origin/main == HEAD` · kabul pini ayakta.
""", "")

yama(D, "K133 kilidi",
"""- **K44-a** — **Önce araç, sonra belge.**""",
"""- 🔒 **K133 — `SS2` v3 KİLİTLENDİ (Onur kilitledi, 3 Ağu 2026, oturum 55):** tur 2'nin **beş
  blokeri kapandı** — sınıflama `K53/3`'e göre yapıldı ve **hiçbiri borçlanamıyordu** (üçü KAPI:
  `G32/a`·`G31/a`·`G33/c` kör; biri ÜRÜN: `/e`'nin şart 3'ü atlaması **yeni veri kaybı**; biri spec
  içi çelişki). 13 major **borçlandı**. Kilit **kapanmamış sınırlarla** verildi (`A13`/`K130`
  emsali). Üçüncü kâğıt turu `K53/1` gereği **açılmadı**; gerekçe ve dört kapı çıktısı
  `KANIT/SS2/03-v3-KILIT.md`'de. 🔴 **Yaşayan sınır:** `spec-kapi-kapsama.py` *"mutant ISIRIR mı"*
  **sormaz** ⇒ v3'ün üç onarımı yalnız **`T7`'de koşan kodla** kanıtlanır (borç `B-SS2-4`).
  Gerekçe: hafıza K133.
- **K44-a** — **Önce araç, sonra belge.**""")

yama(D, "9 kimlik satiri",
"""⚠ **Kimlik `sha256`+bayttır, satır DEĞİL**""",
"""| `GOREV-SS2-cakisma-cozumu.md` | **46.003** | **`420E9F91`** | 🔒 **K133 kilidi (Onur kilitledi 3 Ağu 2026, oturum 55)** — `66CC4AAE` (v2) ve `90314998` (v1) **GEÇERSİZDİR**. U+FFFD 0 · CRLF 0. Kapıları **`SS2/G31`–`SS2/G34`** (K108). 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** (sepet `BORCLAR.md`'de) |

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL**""")

# ================================================================= BORCLAR.md
B = "BORCLAR.md"
yama(B, "B-SS2-1..4",
"""- 🔴 **`B-O52-2` (K127'nin mekanik kapısı yok) HÂLÂ AÇIK — ama bu turda K127 kapısız hâliyle
  bile İŞE YARADI:** denetim kilitten önce koştu ve **1 bloker** yakaladı. Kapı olmadığı için
  *koştuğunu* garanti eden bir şey yok; **bu tur onu Onur'un talimatı garanti etti.**""",
"""- 🔴 **`B-O52-2` (K127'nin mekanik kapısı yok) HÂLÂ AÇIK — ama bu turda K127 kapısız hâliyle
  bile İŞE YARADI:** denetim kilitten önce koştu ve **1 bloker** yakaladı. Kapı olmadığı için
  *koştuğunu* garanti eden bir şey yok; **bu tur onu Onur'un talimatı garanti etti.**

### OTURUM 55'TE AÇILAN — `SS2` v3 KİLİDİNİN BORÇLARI (`K133`)

- 🔴 **`B-SS2-1` · `B-SS2-2` · `B-SS2-3` — SPEC'İN KENDİ §8'İNDE TAM METİNLE YAZILIDIR.**
  Buraya **kopyalanmaz** (`kanonik-kopya` bu projede altı kez ısırdı); kanonik yer
  `GOREV_CLAUDE_CODE/GOREV-SS2-cakisma-cozumu.md` §8 → `S7` · `S5` · `S8`. Tek satırlık kimlikleri:
  `B-SS2-1` v3→v5 migration zinciri `[DOĞRULANMADI]` (`G31/c` yalnız v4→v5 ölçer) ·
  `B-SS2-2` rozet **iki farklı olayı** aynı ikonla gösteriyor (ayrıştırma yok) ·
  `B-SS2-3` görev silinince çakışma kaydı **yetim** kalır (`sil()` temizlemez).
  🔴 **Bu üç atıf v2'de de vardı ve BORCLAR.md'de karşılığı YOKTU** — kilit onları **sarkan atıf**
  yapacaktı; oturum 55 açılışında ölçülüp kapatıldı.

- 🔴 **`B-SS2-4` — `spec-kapi-kapsama.py` *"MUTANT ISIRIR MI"* DİYE SORMUYOR.** Araç *"mutant VAR
  mı"* sorar; **eşdeğer mutant onun için YEŞİLDİR** ve bu, aracın kendi beyan edilmiş sınırıdır.
  🔴 **Ölçülmüş bedel:** aynı ders **üç tur üst üste** alıntılanıp uygulanmadı
  (`A13/M167` → `SS2` v1 `M172`/`M173`/`M175` → v2 `M172`) ve iki bağımsız denetim turu (~307k +
  ~120k token) onu **elle** yakalamak zorunda kaldı. Kapı olsaydı üçü de ilk turda düşerdi.
  **Kapanış yolu:** mutantı **gerçekten uygulayıp** kapıyı koşan, sonra geri alan bir koşucu;
  referans **`KANIT/A11/_mutant_kosucu.py`** (ikili yedek → bayt düzeyinde yama → kapı → `wb` ile
  geri yazım → `sha256` ile özdeşlik). 🔴 `git restore` ile geri alma **YASAK** (`core.autocrlf`
  bayt-özdeşliği kör kılar — `ORTAM.md`). 🔴 **Araç ÜRÜN KODU SAYILMAZ (`K53/4`)** ⇒ bu borç
  `R8` sönmeden açılamaz.""")

# ================================================================= MOTOR (dosya basina atomik)
toplam_hata = 0
for dosya, liste in ISLER.items():
    yol = os.path.join(KOK, dosya)
    with open(yol, "rb") as f:
        ham = f.read()
    metin = ham.decode("utf-8")
    print("\n== %s ==  GIRDI %d bayt · sha8 %s" % (dosya, len(ham), hashlib.sha256(ham).hexdigest()[:8].upper()))
    hata = 0
    for ad, eski, yeni in liste:
        n = metin.count(eski)
        if n != 1:
            print("  [HATA] '%s': eslesme %d (1 olmali)" % (ad, n)); hata += 1
        else:
            metin = metin.replace(eski, yeni, 1); print("  [OK]   %s" % ad)
    if hata:
        toplam_hata += hata; print("  >> %s'e DOKUNULMADI." % dosya); continue

    yeni_ham = metin.encode("utf-8")
    if b"\r\n" in yeni_ham or "�" in metin:
        print("  >> CRLF/U+FFFD -- iptal."); toplam_hata += 1; continue
    tmp, yedk = yol + ".tmp", yol + ".yedek"
    with open(tmp, "wb") as f: f.write(yeni_ham)
    if os.path.exists(yedk): os.remove(yedk)
    os.rename(yol, yedk)
    try:
        os.rename(tmp, yol)
    except Exception as e:
        os.rename(yedk, yol); print("  >> takas patladi, GERI ALINDI:", e); toplam_hata += 1; continue
    with open(yol, "rb") as f: son = f.read()
    if son != yeni_ham:
        os.remove(yol); os.rename(yedk, yol); print("  >> sha uyusmadi, GERI ALINDI."); toplam_hata += 1; continue
    os.remove(yedk)
    print("  CIKTI %d bayt · sha8 %s · DELTA %+d" % (len(son), hashlib.sha256(son).hexdigest()[:8].upper(), len(son)-len(ham)))

print("\nHUKUM:", "TAMAM" if toplam_hata == 0 else "%d HATA" % toplam_hata)
sys.exit(0 if toplam_hata == 0 else 2)
