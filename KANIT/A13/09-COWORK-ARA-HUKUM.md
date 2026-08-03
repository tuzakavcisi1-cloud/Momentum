# `A13` — COWORK'ÜN ARA HÜKMÜ (oturum 52, 3 Ağu 2026)

🔴 **BU BİR KABUL HÜKMÜ DEĞİLDİR.** `A13` **yarımdır**: kriter 7 ve 8 **push'a bağlıdır** ve push
Onur'undur. Aşağıdaki her satır **Cowork'ün kendi koşumudur** (K26); builder'ın `08-OZET.md`'si
okundu ama **hiçbiri kanıt yerine sayılmadı**.

| kriter | Cowork'ün ölçümü | hüküm |
|---|---|---|
| 1 — araç | `ci-kapisi.py --altin-kume` → **13/13 GEÇTİ, EXIT 0**; **yorum-satırı vakası kümede VAR** (vaka 3) ⇒ kriter 1'in pazarlıksız şartı karşılandı | ✅ |
| 1 — dilim öncesi sha | `c676eb15…` · `git merge-base --is-ancestor` **EXIT 0** ⇒ gerçekten HEAD'in atası (uydurulmuş sha değil) | ✅ |
| 2 — iskelet | `src/client/ios/` diskte (`Flutter` · `Runner` · `Runner.xcodeproj` · `Runner.xcworkspace` · `RunnerTests`) · **`flutter analyze --fatal-infos` EXIT 0 — "No issues found!"** (Cowork koştu, 12,6 s) | ✅ |
| 3 — hijyen a·b·c | `ci-kapisi.py .` **EXIT 0 / bulgu yok** | ✅ |
| 3 — hijyen d | `git diff --stat c676eb15..HEAD -- src/client/lib src/client/test src/client/pubspec.yaml` ⇒ **ÇIKTI BOŞ** | ✅ |
| 4 — CI dosyası | `ci.yml` **Cowork tarafından okundu**: `workflow_dispatch` + `push: [main]` · iki iş (`istemci` ubuntu / `ios` macos) · **`flutter-version: 3.44.6` her ikisinde pinli** · `--fatal-infos` · `--no-codesign` | ✅ |
| 5 — statik mutantlar | 🔴 **COWORK KENDİ KOŞTU: 6/6.** `M162`→`G28a` · `M163`→`G28b` · `M164`→`G29a` · `M165`→`G30a` · `M166`→`G30c` **ısırdı**; **`M163b` SUSTU** (yanlış-pozitif kontrolü). Üç dosyanın da `sha8`'i önce/sonra **özdeş** (`283D785E` · `1D94D07C` · `4F708868`). TEMİZ-ÖNCE **ve** TEMİZ-SONRA **EXIT 0** | ✅ |
| 6 — commit, push yok | `e65a8bc` + `7e48b74`; `git rev-list` ⇒ **0 geri / 2 ileri**, `index.lock` **YOK**. Push **yapılmamış** — doğru davranış | ✅ |
| 7 — CI yeşil | **ÖLÇÜLEMEDİ** — push yapılmadı, CI hiç koşmadı | ⏳ |
| 8 — koşan mutantlar | Dallar **git ile doğrulandı** (builder beyanı değil): `mutant/A13-M167` → `lib/main.dart` **+1 satır** · `-M168` → `test/widget_test.dart` **1 satır değişti** · `-M169` → `ios/Runner/Info.plist` **−1 satır**. Koşum push'a bağlı | ⏳ |
| 9 — kanıt | `KANIT/A13/` dolu (bu dosya dâhil) | ✅ |

## COWORK'ÜN KENDİ BULGULARI (builder'ın özetinde YOK)

🟡 **MINOR — mutant dalları `main`'in GERİSİNDE.** Üç dal da `e65a8bc` tabanlı; `main` o zamandan
beri `7e48b74` ile ilerledi ⇒ dallarda `KANIT/A13/05-commit.txt`, `06-ci-yesil/`, `07-MUTANT-kosan/`,
`08-OZET.md` **yok** (diff'te 121–122 satır silinmiş görünüyor). **Ürün kodu ve `ci.yml` aynı**
olduğu için CI sonucu geçerlidir; bloker değil. Ama `M170` kriter 7'nin JSON'ına bakacağı için
**kanıt dosyalarının dalda bulunmaması karıştırıcıdır** — kriter 8 koşulmadan önce dallar `main`
üzerine rebase edilirse bu gürültü kalkar.

🟢 **RİSK YANLIŞLANDI — CI ilk koşumda üretilmiş-dosya yüzünden patlamayacak.** Cowork ölçtü:
`src/client/lib/veri/veritabani.g.dart` diskte **ve `git ls-files`'da izleniyor**; `.gitignore`'da
`*.g.dart` deseni **yok** (`.dart_tool` ve `build/` var, pozitif kontrolle doğrulandı). ⇒ CI'da
`build_runner` çıktısı eksikliği **riski yok**. `ci.yml`'de `flutter pub get` adımı yok ama Flutter
aracı `package_config` yoksa **kendi koşar** ⇒ tek başına bulgu değildir.

## SIRADAKİ — PUSH SONRASI (kriter 7 → 8)

1. `git push origin main` → CI `push: main` ile koşar. Reddedilirse: `gh auth refresh -h github.com -s workflow`.
2. `gh run list --workflow ci.yml --branch main --limit 5 --json conclusion,headSha,status,databaseId` → `06-ci-yesil/`.
3. `headSha` == `git rev-parse main` (`G27/b`); `gh run view <id> --log` → `Xcode build done.` **tam dizgesi** + `Built build/ios/iphoneos/Runner.app (` satırı + boyut > 0 + `flutter test` **N/N** (N **logdan** okunur).
4. **Ancak bundan sonra** mutant dalları push edilir, `gh workflow run ci.yml --ref <dal>` × 3, `M167`–`M169` **3/3 ISIRIR**.
5. `M170`: kaydedilen JSON'un `headSha`'sı bozulur, `G27/b` **KIRMIZI** vermeli.
