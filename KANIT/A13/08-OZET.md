# KANIT/A13/08-OZET.md — GOREV-A13, madde madde PASS/FAIL

> Bu dosya **beyan yok, dosya var** ilkesiyle yazıldı: her satır `KANIT/A13/` altındaki bir
> dosyaya işaret eder. §7'nin **SIRA PAZARLIKSIZ** kuralına uyulmuştur.
>
> 🔴 **OTURUM 53 DÜZELTMESİ — YAZAR AYRIMI AÇIKÇA BELİRTİLİR.** Kriter **0–6** satırları
> **builder'ındır** (oturum 52, dokunulmadı). Kriter **7 ve 8** satırlarını **Cowork** yazdı
> (3 Ağu 2026, oturum 53), çünkü o iki kriteri **Cowork ölçtü** (K26: üreten ≠ denetleyen).
> Eski hâlleri *"⏳ BEKLEMEDE"* / *"⏳ KISMEN"* idi ve push'tan **37 dakika önce** yazılmıştı;
> kabul öncesi bağımsız denetim (K127) bunu **bayat-iddia** olarak buldu — §10 bu dosyayı
> *"madde madde PASS/FAIL + ölçülen sayılar"* diye tanımlıyor ve dosya geçmiş bir kriteri
> yalanlıyordu. Aşağıdaki *"Push sonrası beklenen adımlar"* listesi **tarihsel kayıt olarak
> bırakıldı**; hepsi yapıldı (madde 2 hariç: `gh auth refresh` **gerekmedi**, ölçüldü).
> Nihai hüküm: **`KANIT/A13/10-COWORK-KABUL-HUKMU.md`** · denetim: **`00-DENETIM-kabul-oncesi.md`**.

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
| 7. CI yeşil (main) | ✅ **PASS [oturum 53, COWORK ölçtü]** — run **`30809600584`**, `conclusion success`, `headSha 79d0901…` == `rev-parse main`; işler `['ios','istemci']` **ikisi de success**; `No issues found! (ran in 9.8s)`; **`🎉 500 tests passed.`** (N=500, logdan); `Xcode build done. 91.9s`; **`✓ Built build/ios/iphoneos/Runner.app (18.7MB)`** | `06-ci-yesil/01,02,03` |
| 8. Koşan mutantlar + M170 | ✅ **PASS [oturum 53, COWORK ölçtü]** — `M167` run `30812873002` · `M168` `30812875758` · `M169` `30812878437` ⇒ **3/3 ISIRDI**, her birinde **doğru iş** düştü (M167/M168 `istemci`, M169 `ios`), yanlış iş hiç düşmedi. `M170` ısırdı; JSON geri yazımı **bayt-özdeş** (`2B63CB73`) | `07-MUTANT-kosan/10,20,30,40` |
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
