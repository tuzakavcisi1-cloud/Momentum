## 🔒 CHECKPOINT — K128 · **`A13` KRİTER 1–6 COWORK'ÇE DOĞRULANDI; 7–8 PUSH BEKLİYOR** (oturum 52, 3 Ağu 2026)

🔴 **DENETÇİ ÇIKTI YOLU (K127):** `KANIT/A13/09-COWORK-ARA-HUKUM.md`.
🔴 **BU BİR KABUL HÜKMÜ DEĞİLDİR.** `A13` **yarımdır**; kriter 7 (CI yeşil) ve 8 (koşan mutantlar)
**push'a bağlıdır** ve push Onur'undur.

Claude Code kriter 1–6'yı üretti (`e65a8bc` + `7e48b74`, **push YOK — doğru davranış**). Cowork
builder'ın `08-OZET.md`'sini **okudu ama kanıt yerine saymadı** (K26) ve hepsini **kendi koştu**:

**COWORK'ÜN KENDİ ÖLÇÜMLERİ — 1–6 ve 9 GEÇTİ:**
① `ci-kapisi.py --altin-kume` **13/13, EXIT 0** ve **yorum-satırı vakası kümede VAR** (vaka 3) ⇒
kriter 1'in *pazarlıksız* şartı gerçekten karşılanmış — araç kendi kendini onaylamıyor ·
dilim öncesi sha `c676eb15…`, `git merge-base --is-ancestor` **EXIT 0** ⇒ uydurulmuş değil,
gerçekten HEAD'in atası ② `flutter analyze --fatal-infos` **EXIT 0 / "No issues found!"**
(Cowork koştu, 12,6 s) ③ `ci-kapisi.py .` **EXIT 0** + `git diff --stat c676eb15..HEAD --
lib test pubspec.yaml` **ÇIKTI BOŞ** ④ `ci.yml` **Cowork'çe okundu**: `workflow_dispatch` +
`push:[main]`, iki iş, `flutter-version: 3.44.6` **her ikisinde pinli**, `--fatal-infos`,
`--no-codesign` ⑤ 🔴 **MUTANTLAR COWORK'ÜN KENDİ KOŞUMU: 6/6** — `M162`→`G28a` · `M163`→`G28b` ·
`M164`→`G29a` · `M165`→`G30a` · `M166`→`G30c` **ISIRDI**, **`M163b` SUSTU**; üç dosyanın `sha8`'i
önce/sonra **özdeş**, TEMİZ-ÖNCE ve TEMİZ-SONRA **EXIT 0** ⑥ `0 geri / 2 ileri`, `index.lock` YOK.

🟢 **BİR RİSK YANLIŞLANDI (Cowork'ün kendi sorusu, spec'te yoktu):** *"CI ilk koşumda üretilmiş
dosya eksikliğinden patlar mı?"* — `src/client/lib/veri/veritabani.g.dart` diskte **ve
`git ls-files`'da izleniyor**; `.gitignore`'da `*.g.dart` deseni **yok** (`.dart_tool`/`build/` var,
**pozitif kontrolle** doğrulandı). ⇒ **Risk yok.** `pub get` adımının yokluğu da tek başına bulgu
değildir (Flutter aracı `package_config` yoksa kendi koşar).

🟡 **COWORK'ÜN BULDUĞU MINOR — builder'ın özetinde YOKTU:** üç mutant dalı da `e65a8bc` tabanlı,
`main` ise `7e48b74`'te ⇒ dallarda `KANIT/A13/05`, `06`, `07`, `08` **yok** (diff'te ~122 satır
silinmiş görünüyor). **Ürün kodu ve `ci.yml` aynı** olduğu için CI sonucu geçerli — **bloker değil**;
ama `M170` kriter 7'nin JSON'ına bakacağından, kriter 8'den önce dalları `main` üzerine almak
gürültüyü kaldırır. Dalların içeriği **git ile doğrulandı** (beyanla değil): `M167`→`main.dart` +1,
`M168`→`widget_test.dart` 1 satır, `M169`→`Info.plist` −1.

🔴 **`R8` HÂLÂ DÜŞMEDİ AMA ARTIK DÜŞEBİLİR:** `src/client/ios/` (40 dosya) ve `ci.yml` repoya
**girdi**; `urun_kodu_satiri` bu oturumun defter kaydında ölçülecek. `A13` kabul edilmeden dilim
**kapanmaz** — kabul, push sonrası kriter 7–8 ölçümüne bağlıdır.
