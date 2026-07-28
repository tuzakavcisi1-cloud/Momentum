# slice-3d (CEKME) — KANIT ÖZETİ

Her satır: **komut** → **çıkış kodu** (ölçüm yöntemi: PowerShell `$LASTEXITCODE`, dış işlem doğrudan `&` ile çağrılıp koddan hemen sonra okunur — `cmd /c ... %ERRORLEVEL%` kalıbı KULLANILMADI, bkz. HUKUM.md §Ortam notu) → tek satır hüküm.

| # | Kapı | Komut | Exit | Hüküm |
|---|------|-------|------|-------|
| G1 | Yalnız-çekme istek yolu | `flutter test test\g1_cekme_yolu_kapisi_test.dart` | 0 | 13/13 YEŞİL — [01-G1-yalniz-cekme/g1-test-ciktisi.txt](01-G1-yalniz-cekme/g1-test-ciktisi.txt) |
| G2 | Şema v3→v4 migration | `flutter test test\g2_migration_kapisi_test.dart` | 0 | 6/6 YEŞİL — [02-G2-migration/g2-test-ciktisi.txt](02-G2-migration/g2-test-ciktisi.txt) |
| G3 | İki ayrıştırıcı + projeksiyon | `flutter test test\g3_ayristirici_kapisi_test.dart` | 0 | 12/12 YEŞİL — [03-G3-ayristirici/g3-test-ciktisi.txt](03-G3-ayristirici/g3-test-ciktisi.txt) |
| G4 | Yerel LWW karşılaştırıcı | `flutter test test\g4_lww_kapisi_test.dart` | 0 | 7/7 YEŞİL — [04-G4-lww/g4-test-ciktisi.txt](04-G4-lww/g4-test-ciktisi.txt) |
| G5 | Yerel koruma / rozet / echo | `flutter test test\g5_yerel_koruma_kapisi_test.dart` | 0 | 15/15 YEŞİL — [05-G5-yerel-koruma/g5-test-ciktisi.txt](05-G5-yerel-koruma/g5-test-ciktisi.txt) |
| G6 | F2 ucuz yakınsama (sahte sunucu) | `flutter test test\g6_f2_yakinsama_kapisi_test.dart` | 0 | 5/5 YEŞİL (4→5, bkz. M24 kör-kapı düzeltmesi) — [06-G6-f2-yakinsama/g6-test-ciktisi.txt](06-G6-f2-yakinsama/g6-test-ciktisi.txt) |
| G7 | Backend zorlamaları (D8/D9) | `dotnet test` (SyncCore + Persistence, filtreli) | 0 | v7 + owner_id testleri YEŞİL — [07-G7-backend-zorlama/outbox-sorgu.txt](07-G7-backend-zorlama/outbox-sorgu.txt) |
| G8 | F3 canlı yakınsama (gerçek backend+Postgres) | `flutter test tool\f3_iki_istemci_yakinsama.dart` | 0 | 7/7 ayak YEŞİL (6→7, bkz. M29 kör-kapı düzeltmesi) — [08-G8-f3-canli/g8-test-ciktisi.txt](08-G8-f3-canli/g8-test-ciktisi.txt) |
| G9 | Regresyon (analyze+test+verify+kapılar) | aşağıda ayrı satırlar | 0 | hepsi YEŞİL |

## G9 — regresyon alt-kalemleri

| Komut | Exit | Hüküm |
|---|---|---|
| `flutter analyze --fatal-infos` | 0 | 0 bulgu — [10-G9-regresyon/01-flutter-analyze.txt](10-G9-regresyon/01-flutter-analyze.txt) |
| `flutter test` (tam paket) | 0 | 136/136 YEŞİL — [10-G9-regresyon/02-flutter-test.txt](10-G9-regresyon/02-flutter-test.txt) |
| `araclar\verify.ps1` (backend build+test+CVE) | 0 | 120/120 backend test YEŞİL, CVE temiz — [10-G9-regresyon/03-verify-ps1.txt](10-G9-regresyon/03-verify-ps1.txt) |
| `python araclar\design-token-kapisi.py .` | 0 | 0 bulgu (6 test-zamanlama literali `[DESIGN-LITERAL]` ile muaf tutuldu) — [10-G9-regresyon/04-design-token-kapisi.txt](10-G9-regresyon/04-design-token-kapisi.txt) |
| `python araclar\tek-kopya-kapisi.py .` | 0 | bulgu yok — [10-G9-regresyon/05-tek-kopya-kapisi.txt](10-G9-regresyon/05-tek-kopya-kapisi.txt) |
| `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-slice-3d-cekme.md` | 0 | — [10-G9-regresyon/06-spec-kapi-kapsama.txt](10-G9-regresyon/06-spec-kapi-kapsama.txt) |
| `python araclar\sayi-tazeligi.py .` | 0 | — [10-G9-regresyon/07-sayi-tazeligi.txt](10-G9-regresyon/07-sayi-tazeligi.txt) |
| `python araclar\iddia-kapisi.py GOREV_CLAUDE_CODE\GOREV-slice-3d-cekme.md --kanit KANIT\slice-3d` | 0 | 40/40 mutant beyanı ham kanıtla tutuyor — [10-G9-regresyon/08-iddia-kapisi.txt](10-G9-regresyon/08-iddia-kapisi.txt) |

## Mutantlar (09-MUTANT/)

**40/40** (M1–M40) — her biri kendi `Mnn-<kisa-ad>.txt` dosyasında 4 bölüm (diff / RED / GREEN / hüküm). Ayrıntı: [HUKUM.md](HUKUM.md).

**Koşan (canlı) mutantlar — tavan 3, aşılmadı:** M29, M30, M31 (gerçek backend + gerçek PostgreSQL, F3 aracı üzerinden).

**Kör kapı bulgusu + düzeltmesi (3 kez, PAZARLIKSIZ K53 madde 2 gereği kapı düzeltildi, mutant gevşetilmedi):**
- **M24** (G6/D3) → `g6_f2_yakinsama_kapisi_test.dart`'a yeni test eklendi (4→5 test).
- **M29** (G8/D3, M24'ün canlı tekrarı) → `f3_iki_istemci_yakinsama.dart`'a AYAK7 eklendi (6→7 ayak).
- **M31** (G8/D5) → F3'ün AYAK5'i kendi belgelenmiş amacına uygun gerçek bir yarış kuracak şekilde düzeltildi (ADDITIVE — mevcut assertion silinmedi, öncesine bir adım eklendi).

## [DOGRULANMADI] — ölçülmedi

- Web ayağı (`flutter test --platform chrome`) — sonuç üretmediği ortam notunda önceden BEYAN edilmişti, bu oturumda da denenmedi.
- iOS — Mac yok, CI-only (proje ortam notu).
- Boşaltma tavanının (`_bosaltmaTavani=20`) yeterliliği — M3/M39 tavan davranışını ısırdığını kanıtlar ama "20 her koşulda yeter mi" ölçülmedi.
- Android emülatör açılış + uzak görev görünürlüğü (kabul kriteri 9) — bu KANIT turunda [DOGRULANMADI]; ayrı bir emülatör oturumu gerektirir.
