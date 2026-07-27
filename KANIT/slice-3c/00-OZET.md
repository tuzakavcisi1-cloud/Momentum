# KANIT/slice-3c — 00-OZET

Spec: `GOREV_CLAUDE_CODE/GOREV-slice-3c-senkron.md` (K64, kilitli, sha8 537D0579).
Kilitli ara-düzeltme: **K65** (Onur) — bkz. `06-G6-uctan-uca/03-K65-bulgu-ve-duzeltme.md`.

| kapı | komut | çıkış | hüküm | kanıt |
|---|---|---|---|---|
| G1 (401×3) | `dotnet test tests/Momentum.Api.Tests --filter DevKimlikKapisiTestleri` | 0 | YEŞİL 3/3 | `01-G1-dev-kimlik/01-401-testleri.txt` |
| G1 (200×1) | `dotnet test tests/Momentum.Persistence.Tests --filter DevKimlikKapisi200Testleri` | 0 | YEŞİL 1/1 | `01-G1-dev-kimlik/02-200-testi.txt` |
| G2 | `flutter test test/g2_registry_zarf_kapisi_test.dart` | 0 | YEŞİL 11/11 | `02-G2-registry-zarf/00-test-ciktisi.txt` + 4 ham WireOp JSON |
| G3 | `flutter test test/g3_kuyruk_kapisi_test.dart` | 0 | YEŞİL 8/8 | `03-G3-kuyruk/00-test-ciktisi.txt` |
| G4 | `flutter test test/g4_hlc_kapisi_test.dart` | 0 | YEŞİL 8/8 (K65 sonrası güncel) | `04-G4-hlc/00-test-ciktisi.txt` |
| G5 | `flutter test test/g5_karantina_kapisi_test.dart` | 0 | YEŞİL 11/11 | `05-G5-karantina/00-test-ciktisi.txt` |
| G6 | `flutter test tool/g6_uctan_uca_kapisi.dart` + Postgres SQL doğrulama | 0 | YEŞİL 6/6 ayak (**K65 düzeltmesi sonrası**; düzeltme öncesi AYAK6 ~%40-50 aralıklı KIRMIZI'ydı — bkz. bulgu dosyası) | `06-G6-uctan-uca/` (4 dosya) |
| G7 | analyze + `flutter test` (79) + `verify.ps1` + design-token + tek-kopya | 0/0/0/0/0 | YEŞİL | `07-G7-regresyon/` (5 dosya) |
| G8 | `flutter test test/g8_atomiklik_kapisi_test.dart` | 0 | YEŞİL 4/4 | `08-G8-atomiklik/00-test-ciktisi.txt` |
| MUTANT | M1–M36, tek tek uygula→KIRMIZI ölç→geri al→YEŞİL | — | 36/36 | `09-MUTANT/00-OZET.md` |
| kriter 6 | `spec-kapi-kapsama.py` + `sayi-tazeligi.py` | 0/0 | TEMİZ | `07-G7-regresyon/06-*.txt`, `07-*.txt` |

**Backend dokunulan yüzey (kabul kriteri 8):** `git diff --stat 5df3caf -- src/backend/`
⇒ yalnız `Program.cs` (12 satır: `AddHttpContextAccessor` + D0 kaydı) + yeni
`Auth/DevCurrentUser.cs`. Backend senkron çekirdeğine (Domain/Application/Infrastructure
sync kodu) **tek satır dokunulmadı**.

**Bilinen zayıf kontrol / temizlik notu:** `src/backend/Momentum.Api.Tests/` ve
`src/backend/Momentum.Persistence.Tests/` adında iki YANLIŞ KONUMLANDIRILMIŞ (T7
sırasında keşfedilen, `Momentum.sln`'e hiç bağlı olmayan, git-tracked OLMAYAN) klasör
kaldı — içerikleri doğru konuma (`tests/Momentum.Api.Tests/`,
`tests/Momentum.Persistence.Tests/`) taşındı ve orada yeniden doğrulandı; stray
klasörler `rm`/`Remove-Item` izin katmanınca reddedildiği için SİLİNEMEDİ, dosyaları
inert bir açıklama yorumuyla nötrleştirildi. Onur'un elle silmesi gerekiyor. Ayrıca
`KANIT/slice-3c/02-G2/` (boş, taşıma sonrası) aynı sebeple silinemedi.

**Diğer notlar:**
- `KANIT/slice-3c/T5-http-lisans.txt` T7 sırasında 2 MB'a şişmiş halde bulundu (§8'in
  200 KB kuralını ihlal ediyordu, muhtemelen erken bir oturumda yanlışlıkla farklı bir
  komutun ham JSON çıktısıyla karışmıştı) — `pub-lisans-kapisi.py` yeniden koşularak
  2584 bayta budandı, HUKUM: TEMİZ (exit 0) korunarak.
