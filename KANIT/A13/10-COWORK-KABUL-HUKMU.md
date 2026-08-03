# `GOREV-A13` — COWORK'ÜN KABUL HÜKMÜ (oturum 53 · 3 Ağu 2026)

> **K26:** hiçbir satır builder'ın beyanıyla yazılmadı — her biri Cowork'ün **kendi koşumudur**
> (`gh` + Desktop Commander, gerçek FS ve gerçek Actions).
> **K127:** bu hüküm **kabul öncesi bağımsız denetimden SONRA** yazıldı. Denetim çıktısı:
> **`KANIT/A13/00-DENETIM-kabul-oncesi.md`** (üç bağımsız denetçi, üçü de "ŞARTLI").
> Denetimin **1 BLOKER + 5 MAJOR**'ının hepsi kapatıldı; kapanış yolları aşağıda.

---

## 1. DOKUZ KRİTER

| kriter | Cowork'ün ölçümü | hüküm |
|---|---|---|
| 1 — araç + dilim öncesi sha | `ci-kapisi.py --altin-kume` **13/13 EXIT 0** (yorum-satırı vakası **var**); **bağımsız denetçi de koştu, 13/13**. Dilim öncesi sha `c676eb15…`, `merge-base --is-ancestor` EXIT 0 | ✅ |
| 2 — iskelet | `src/client/ios/` diskte · `flutter analyze --fatal-infos` **EXIT 0, "No issues found!"** (Cowork koştu) | ✅ |
| 3 — hijyen a·b·c / d | `ci-kapisi.py .` **EXIT 0** · `git diff --stat c676eb15..HEAD -- lib test pubspec.yaml` **ÇIKTI BOŞ** | ✅ |
| 4 — CI dosyası | `ci.yml` 580 b, blob `0b326e38…`; `workflow_dispatch` + `push:[main]`, `pull_request` **yok**, `continue-on-error`/`if:`/`\|\| true`/`set +e` **0** (Python ile sayıldı, `findstr` değil) | ✅ |
| 5 — statik mutantlar | **`M162`–`M166` 5/5 ISIRDI**, **`M163b` SUSTU**; üç dosyanın sha8'i önce/sonra **özdeş** | ✅ |
| 6 — commit + push | `79d0901` · `rev-list` **0/0** · `ls-remote` `refs/heads/main` = `79d0901…` · `index.lock` **YOK** | ✅ |
| **7 — CI YEŞİL (`main`)** | run **`30809600584`** `success`; `headSha` == `rev-parse main`; işler `['ios','istemci']` **ikisi de success** | ✅ |
| **8 — koşan mutantlar + `M170`** | **3/3 ISIRDI**, izolasyon tam; `M170` ısırdı, dosya **bayt-özdeş** geri yazıldı | ✅ |
| 9 — kanıt | `KANIT/A13/` **§10 düzeninin dokuz kalemi de var** (+ iki denetim + iki hüküm dosyası) | ✅ |

---

## 2. KRİTER 7 — AYAK AYAK (ham dizgelerle)

| ayak | ham kanıt | hüküm |
|---|---|---|
| `G27/a` | `--branch main` son koşum `conclusion success`, `status completed`, id `30809600584` | 🟢 |
| `G27/b` | JSON `headSha 79d09012934817eb9601c86051924a60aeec9ec3` **==** `git rev-parse main` | 🟢 |
| `G27/c` | işler `['ios','istemci']`, ikisi de `completed/success` | 🟢 |
| `G28/c` | `No issues found! (ran in 9.8s)` — logda **tek** eşleşme | 🟢 |
| `G28/d` | **`🎉 500 tests passed.`** — N **logdan = 500**; `failed`/`skip` satırı **0**; 35 test dosyasında `skip:`/`solo:`/`@Skip` eşleşmesi **0** | 🟢 |
| `G29/b` | `Xcode build done.   91.9s` — tam dizge var 🔴 **ama KÖR, §9/12** | 🟡 |
| `G29/c` | `✓ Built build/ios/iphoneos/Runner.app (18.7MB)` ⇒ **18,7 > 0** | 🟢 |
| `G29/d` | `ios` işi `conclusion success` | 🟢 |

**`D-A13-7` sapma kontrolü:** CI **500** = yerel **500** (`A11`/K121) ⇒ **ayrılma yok**.
**`D-A13-6` koşumda canlı:** `FLUTTER_ROOT = /opt/hostedtoolcache/flutter/**stable-3.44.6**-x64/flutter`.
**Kanıt sahteliği ELENDİ:** bağımsız denetçi ham logu **canlı yeniden çekti** —
`192.875 b · sha256 5adc00c6…bb5e` — diskteki kopyayla **BAYT-ÖZDEŞ**.

---

## 3. KRİTER 8 — KOŞAN MUTANTLAR

| mutant | run | `ios` | `istemci` | beklenen iş düştü | ham kanıt |
|---|---|---|---|---|---|
| `M167` | `30812873002` | success | **failure** | ✅ | `info • Don't invoke 'print' … lib/main.dart:34` |
| `M168` | `30812875758` | success | **failure** | ✅ | `##[error]499 tests passed, 1 failed.` · `Expected: no matching candidates` |
| `M169` | `30812878437` | **failure** | success | ✅ | `Property List error: Close tag on line 69 does not match open tag dict` → `Error (Xcode): unable to read property list` |
| `M170` | — | — | — | ✅ | temiz YEŞİL → 1 karakter bozuk **KIRMIZI** → geri yazım **bayt-özdeş `2B63CB73`** |

🔴 **Hiçbir koşumda yanlış iş düşmedi** (izolasyon tam, adım düzeyinde de doğrulandı).
🔴 **`ci.yml` altı ref'in (yerel+uzak `main` + 3 mutant dalı) hepsinde blob `0b326e38…`** ⇒
dispatch mutantı koşturdu, başka bir workflow'u değil.
🔴 **`git diff e65a8bc..79d0901 -- src/client .github araclar` BOŞ** ⇒ mutant dallarının tabanı
ile CI'lanan `main`, ürün kodu ve `ci.yml` olarak **özdeş** ⇒ ara hükümdeki *"dallar geride"*
MINOR'ü **kapandı**.
🔴 **`A11`'in kriter 7↔8 ÇELİŞKİSİ TEKRARLAMADI, ölçüldü:** filtresiz `gh run list` →
liste başı `mutant/A13-M169 failure`; **filtreli** `--branch main` → tek kayıt `success`.
`--branch main` onarımı hem **gerekliydi** hem **işe yaradı**.

---

## 4. DENETİMİN BULDUKLARI VE NASIL KAPATILDI

| # | bulgu | kapanış |
|---|---|---|
| **BLOKER B1** | `M167` **eşdeğer sanıldı**: `--fatal-infos` Flutter 3.44.6'da **varsayılan açık** ⇒ bayrak taşıyıcı değil | 🟢 **Cowork gerçek depoda yeniden ölçtü** (`40-BULGU-…txt`; `main.dart` bayt-özdeş geri yazıldı `C6B6EDBD`). Spec **açıldı (K130)**: `D-A13-3`'ün gerekçesi ve §6'nın `M167` notu **ölçülen gerçeğe çekildi**; `M167`'nin hedefi `A13/G28`'e **daraltıldı**; §9/11 beyanı eklendi. **`M167` eşdeğer DEĞİL, yanlış etiketlenmişti** — ölçtüğü şey `G28/c`'nin ayırt etme gücüdür ve o gerçektir |
| **MAJOR MJ-1** | `A13/G29/b` **kör ayak** | 🟢 §5/G29 tablosuna işaretlendi + **§9/12** beyanı + borç **`B-O53-1`**. Ayak **silinmedi** (K34-f: onarım builder'ın); yanlış-YEŞİL yok, `c`+`d` ayırt ediyor |
| **MAJOR MJ-2** | `08-OZET.md` **bayat** — kriter 7 hâlâ "BEKLEMEDE" | 🟢 Kriter 7–8 satırları **ölçülen sayılarla** yazıldı; **yazar ayrımı** dosyanın başında açıkça belirtildi (0–6 builder, 7–8 Cowork) |
| **MAJOR MJ-3** | Kriter 7'nin dinamik ayaklarının **korunmuş aracı yok** (K44-a) | 🟡 **§9/16** beyanı + borç **`B-O53-3`**. Bu turda araç yazılmadı: radar KIRMIZI ve K53/1 tavanı; aracı yazacak el **builder**'dır |
| **MAJOR MJ-4** | `M170` gerçek yolu değil **kopyayı** ısırıyor | 🟢 §6'daki `M170` hükmü **daraltıldı** + **§9/13** beyanı |
| **MAJOR MJ-5** | `G29/c` onarımının değeri **hiçbir mutantla gösterilemedi**; Cowork'ün `20-…OLCUM.txt` etiketi **ters** | 🟢 §5/G29'a ölçülen gerçek yazıldı + **§9/14**; `20-…OLCUM.txt`'ye **düzeltme bloğu** eklendi |
| MINOR ×8 | bayat yer tutucular · `headBranch` kaydı yok · `M170` sıra ihlali · zaman damgası ezilmesi · `N/N` biçimi · mutantsız ayaklar · yasak 8 kapısız · aksiyonlar pinsiz | 🟢 İkisi düzeltildi (`00-BEKLEMEDE.txt`, `00-DALLAR-…txt`); kalanı **§9/15·17·18·19** beyanları + borçlar `B-O53-2·4·5` |

---

## 5. HÜKÜM

# 🟢 `GOREV-A13` KABUL EDİLDİ

**Ne kanıtlandı:** *"Bu depo iOS hedefini **gerçekten derliyor**, bunu **kendi makinemde
değil GitHub'ın macOS runner'ında** yapıyor, ve bu boru hattı **canlıdır** — üç ayrı bozmayla
üçünde de **doğru işi düşürdü**."* İlk kez ölçüldü: `Runner.app` **18,7 MB** · `500/500` test ·
`analyze --fatal-infos` **0 sorun**.

**Ne KANITLANMADI (§9, 21 madde — hepsi yazılı):** backend CI'da yok · iOS **çalıştırılmadı**,
yalnız derlendi · imzalama/TestFlight yolu ölçülmedi · kalan Actions kotası ölçülemedi ·
web/Windows CI'da yok · `G29/b` **kör** · `--fatal-infos`'un taşıyıcılığı **gösterilemez** ·
`G27/a`, `G27/c`, `G30/b` **mutantsız** · kriter 7'nin dinamik ayaklarının **aracı yok** ·
aksiyonlar **sha'ya pinli değil** ⇒ bu yeşil **bit-bazında tekrarlanabilir değil**.

**Maliyet:** dört koşumun da **billable süresi 0 ms** (Timing API) — ücretsiz kota içinde kalındı.

**Bu dilim `R8`'i DÜŞÜRÜR:** `flutter create --platforms=ios` çıktısı + `ci.yml` + `ci-kapisi.py`
⇒ `urun_kodu_satiri` **git'ten ölçülür** (K55), buraya yazılmaz.

---

## 6. ONUR'A DÜŞEN (kabulün dışında, açık iş)

1. 🔴 **Uzaktaki üç mutant dalını sil** (§6 kırmızı çizgi 4 — silme Cowork'ün işi değil):
   `git push origin --delete mutant/A13-M167 mutant/A13-M168 mutant/A13-M169`
2. 🟡 Kanıt dosyaları (`06-ci-yesil/*`, `07-MUTANT-kosan/*`) **izlenmiyor** (`??`) ⇒ commit
   edilmezse itilmiş depoda kabul kanıtı yok.
3. 🟡 Beş yeni borç açıldı: `B-O53-1`…`B-O53-5` (`BORCLAR.md`).

---

## 7. BU HÜKMÜN KENDİ SINIRLARI (gizlenmiyor)

- Eşdeğerlik reprodüksiyonu **yerel** Flutter 3.44.6 ile koştu; *"CI'da bayraksız da düşerdi"*
  **doğrudan ölçülmedi** — tek yolu 4. bir koşan mutanttır, **tavan 3/3 dolu**.
- `araclar/ci-kapisi.py`'nin **kaynak kodu satır satır denetlenmedi**; araç dışarıdan ölçüldü.
- `18.7MB` bir **log iddiasıdır** — artefakt yüklenmediği için `Runner.app` tartılamadı.
- Üç mutant logunun canlı bayt-özdeşliği yeniden çekilerek doğrulanmadı (yalnız `main` logu için).
- Kriter 7'yi ölçen betikler `%TEMP%` altındaydı ve **repoya girmedi** ⇒ üçüncü bir el bu
  ölçümü yeniden koşamaz, ancak sıfırdan yazabilir (bağımsız denetçi öyle yaptı ve **aynı
  sonuca vardı**). Borç `B-O53-3`.
