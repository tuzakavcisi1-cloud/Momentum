# KANIT/A13/08-OZET.md — GOREV-A13, madde madde PASS/FAIL

> Bu dosya **beyan yok, dosya var** ilkesiyle yazıldı: her satır `KANIT/A13/` altındaki bir
> dosyaya işaret eder. §7'nin **SIRA PAZARLIKSIZ** kuralına uyulmuştur; kriter 7 ve kriter 8'in
> ölçüm gerektiren kısımları **push'a bağlı** olduğundan Onur'un push'unu bekliyor.

| kriter | durum | kanıt |
|---|---|---|
| 0. Ortam (K80) | ✅ Cihaz/backend **açılmadı** (bu dilim istemiyor) | §4, bu belge |
| 1. Araç + dilim-öncesi sha | ✅ `ci-kapisi.py --altin-kume` **13/13 GECTI, EXIT 0** (yorum-satırı vakası dâhil) | `01-arac-altin-kume.txt` |
| 1. Dilim öncesi sha | ✅ `c676eb15f1f3bde8bb1eaae2ff477741ffa958fd` | `00-ortam.txt` |
| 2. İskelet | ✅ `flutter create --platforms=ios .` → 40 dosya · `flutter analyze --fatal-infos` **0 sorun** | `02-iskelet.txt` |
| 3. Hijyen (G30/a,b,c EXIT 0) | ✅ `.gitignore` ve `project.pbxproj` **zaten** D-A13-2'ye uygundu (ek düzenleme gerekmedi) | `03-statik-kapilar.txt` |
| 3. Hijyen (G30/d çıktı boş) | ✅ `git diff --stat <öncesi-sha>..HEAD -- lib test pubspec.yaml` **BOŞ** (commit sonrası da tekrar ölçüldü) | `03-statik-kapilar.txt`, `05-commit.txt` |
| 4. CI dosyası (G28 a,b · G29 a) | ✅ `.github/workflows/ci.yml` yazıldı; `ci-kapisi.py .` **EXIT 0** | `03-statik-kapilar.txt` |
| 5. Statik mutantlar | ✅ **M162–M166 5/5 ISIRDI**, **M163b SUSTU** (yanlış-pozitif kontrolü), her turda sha256 özdeşliği doğrulandı | `04-MUTANT-statik/OZET.txt` |
| 6. Commit (push yok) | ✅ `e65a8bc` — yalnız `git add <yol>` ile (A13'e ait dosyalar); push **YAPILMADI** | `05-commit.txt` |
| 7. CI yeşil (main) | ⏳ **BEKLEMEDE** — push Onur'undur; push sonrası `gh run list/view` ile ölçülecek | `06-ci-yesil/00-BEKLEMEDE.txt` |
| 8. Koşan mutantlar + M170 | ⏳ **KISMEN**: `mutant/A13-M167/M168/M169` dalları **yerelde açıldı ve commit'lendi**, her biri **yerelde** (analyze/test/XML-geçerlilik ile) ayrıca doğrulandı; push ve `gh workflow run` Onur'u bekliyor. M170 kriter 7'nin JSON'ı olmadan koşulamaz | `07-MUTANT-kosan/00-DALLAR-YERELDE-ACILDI.txt` |
| 9. Kanıt (§10) | ✅ Bu dosya + yukarıdaki tümü | `KANIT/A13/` |

## Push sonrası Onur'dan / Cowork'ten beklenen adımlar (kriter 7 → 8)

1. `git push origin main` — CI `push:main` tetiğiyle koşar.
2. Push reddedilirse (§4 ön koşul): `gh auth refresh -h github.com -s workflow`.
3. `gh run list --workflow ci.yml --branch main --limit 5 --json conclusion,headSha,status,databaseId`
   → `KANIT/A13/06-ci-yesil/` altına ham JSON.
4. `headSha` == `git rev-parse main` doğrulanır (`A13/G27/b`).
5. `gh run view <databaseId> --log` → `istemci` ve `ios` işlerinin ikisi de koştuğu + `flutter analyze`
   0 sorun + `flutter test` N/N + `Xcode build done.` tam dizgesi + `Built build/ios/iphoneos/Runner.app (`
   satırı (boyut > 0) ölçülür.
6. **Ancak bundan SONRA:** `git push origin mutant/A13-M167 mutant/A13-M168 mutant/A13-M169`,
   her dal için `gh workflow run ci.yml --ref <dal>`, `M167`–`M169` **3/3 ISIRIR** ölçülür.
7. `M170`: kriter 7'de kaydedilen JSON'un `headSha`'sı tek karakter değiştirilip `G27/b` ölçümünün
   gerçekten KIRMIZI verdiği doğrulanır (kabul ölçümünün kendi kör-kapı testi).
8. Mutant dalları **Onur** tarafından uzaktan silinir (kırmızı çizgi 4); `main` hiçbir mutant
   içermez.

## Beyan edilmiş sınırlar (bu build'de yeniden doğrulandı, §9 ile birebir)

- Backend CI'da yok (D-A13-4, borç §6b — GOREV-A13'ün kendi metninde).
- iOS yalnız derlenir, çalıştırılmaz.
- `RunnerTests`'in bundle id'si ölçülmez.
- `ci-kapisi.py` düz metin tarar; yorum-satırı yanlış-pozitifi kendi altın kümesinde pinlidir.
