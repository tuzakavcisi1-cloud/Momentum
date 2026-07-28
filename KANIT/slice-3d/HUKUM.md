# HÜKÜM — GOREV-slice-3d-cekme

**Tarih:** 2026-07-28 · **Kök:** `C:\dev\Momentum` · **Spec:** `GOREV_CLAUDE_CODE\GOREV-slice-3d-cekme.md`
**Bu belge kanıt SAYILMAZ** (dairesel kanıt yasağı, `iddia-kapisi.py`) — yalnız aşağıdaki ham dosyalara ATIF yapar.

## Nihai hüküm: YEŞİL

Tüm G1–G9 kapıları, tüm 40 mutant (M1–M40), ve tüm bağımsız doğrulama araçları (`design-token-kapisi.py`, `tek-kopya-kapisi.py`, `spec-kapi-kapsama.py`, `iddia-kapisi.py`, `sayi-tazeligi.py`) EXIT 0 döndü. Detay tablo: [00-OZET.md](00-OZET.md).

## Kabul kriterleri — tek tek

| # | Kriter | Durum | Kanıt |
|---|---|---|---|
| 1 | G1–G9 koştu, hepsi YEŞİL, çıkış kodları KANIT'ta | ✅ | [00-OZET.md](00-OZET.md) tablo |
| 2 | M1–M40 tek tek uygulandı → KIRMIZI → geri alındı → YEŞİL; ısırmayan mutant kapıya çevrildi | ✅ | [09-MUTANT/](09-MUTANT/) — 40 dosya; 3 kör-kapı bulgusu (M24, M29, M31) DÜZELTİLDİ, mutant GEVŞETİLMEDİ |
| 3 | Her mutantın ham çıktısı koşum anında `09-MUTANT\Mnn-*.txt` olarak yazıldı | ✅ | `iddia-kapisi.py` I2/I3 kendisi doğruladı — [10-G9-regresyon/08-iddia-kapisi.txt](10-G9-regresyon/08-iddia-kapisi.txt) |
| 4 | `flutter analyze --fatal-infos` 0 bulgu; `flutter test` EXIT 0; `verify.ps1` EXIT 0 | ✅ | [10-G9-regresyon/01](10-G9-regresyon/01-flutter-analyze.txt), [02](10-G9-regresyon/02-flutter-test.txt), [03](10-G9-regresyon/03-verify-ps1.txt) |
| 5 | `tek-kopya-kapisi.py` ve `design-token-kapisi.py` EXIT 0 | ✅ | [10-G9-regresyon/04](10-G9-regresyon/04-design-token-kapisi.txt), [05](10-G9-regresyon/05-tek-kopya-kapisi.txt) |
| 6 | `spec-kapi-kapsama.py`, `iddia-kapisi.py`, `sayi-tazeligi.py` EXIT 0 | ✅ | [06](10-G9-regresyon/06-spec-kapi-kapsama.txt), [07](10-G9-regresyon/07-sayi-tazeligi.txt), [08](10-G9-regresyon/08-iddia-kapisi.txt) |
| 7 | Backend'de yalnız iki nokta değişti (`SyncIngest.cs`, `SyncCommandHandler.cs`) + yeni test dosyaları | ✅ | `git diff --numstat -- src/backend/` ⇒ yalnız bu iki dosya (+6/-3, +9/-0); bkz. §Değişen dosyalar |
| 8 | G8 (F3) gerçek backend + gerçek PostgreSQL'e karşı koştu; 6(→7) ayağın ham çıktısı + iki projeksiyonun sha256'sı | ✅ | [08-G8-f3-canli/f3-sonuc.txt](08-G8-f3-canli/f3-sonuc.txt), [08-G8-f3-canli/g8-test-ciktisi.txt](08-G8-f3-canli/g8-test-ciktisi.txt) — AYAK4 sha256 A/B birebir aynı |
| 9 | Android'de açıldı ve çalıştı; açılışta çekme turu koştu, uzak görev göründü | ❌ **[DOGRULANMADI]** | Bu KANIT turunda emülatör oturumu açılmadı — ayrı bir oturum gerektirir |
| 10 | `schemaVersion==4`; `schema_v4.dart` repoda; `Gorevler` CREATE TABLE v3 ile bayt bayt aynı | ✅ | `veritabani.dart:102` (`schemaVersion => 4`); `test/generated_migrations/schema_v4.dart` (449 satır, untracked→bu KANIT turunda repoya eklenmeye hazır); G2 testi "bayt bayt AYNI" — M7 mutantı bu iddiayı ısırarak doğruladı |
| 11 | Ölçülmeyen hiçbir şey "temiz" sayılmadı | ✅ | Bkz. [00-OZET.md](00-OZET.md) §[DOGRULANMADI] |

## Değişen dosyalar (satır sayısı)

### Backend (yalnız 2 üretim dosyası — kriter 7)
| Dosya | +/- |
|---|---|
| `src/backend/Momentum.Application/Features/Sync/SyncCommandHandler.cs` | +6/-3 |
| `src/backend/Momentum.Domain/Sync/SyncIngest.cs` | +9/-0 |

### Backend — yeni test dosyaları
| Dosya | Satır |
|---|---|
| `tests/Momentum.Persistence.Tests/D9OwnerIdVisibilityTests.cs` | 65 (yeni) |
| `tests/Momentum.SyncCore.Tests/SyncIngestV7Tests.cs` | 62 (yeni) |
| `tests/Momentum.Persistence.Tests/ScopeAndDriftAnchorTests.cs` | +12/-6 (D9 testi düzeltmesi) |
| `tests/Momentum.SyncCore.Tests/Oracle/OracleEngine.cs` | +7/-0 (v7 zarf kontrolü) |
| `tests/Momentum.SyncCore.Tests/TestUtil/Scenario.cs` | +12/-3 (deterministik GUID üreteci v7'ye zorlandı) |

### İstemci — üretim kodu (`src/client/lib/`)
| Dosya | +/- (değişen) / satır (yeni) |
|---|---|
| `veri/senkron_dongusu.dart` | +115/-26 (yeniden yazıldı: D0/D6/D7 çekme turu) |
| `veri/veritabani.dart` | +41/-3 (v3→v4 migration, `UzakAlanDurumu`, `imlecSahibi`) |
| `veri/veritabani.g.dart` | +815/-5 (drift_dev üretimi) |
| `veri/ayarlar_deposu.dart` | +48/-4 (D7/4 kullanıcı-değişimi kuralı) |
| `sunum/gorev_listesi_ekrani.dart` | +19/-1 (elle yenileme düğmesi) |
| `main.dart` | +13/-9 (Timer kaldırıldı, dongu bağlandı) |
| `senkron/alan_anahtari.dart` | 127 (yeni) |
| `senkron/kuyruk_tabani.dart` | 81 (yeni) |
| `senkron/uzak_degisiklik_uygulayici.dart` | 241 (yeni) |

### İstemci — test/araç dosyaları
| Dosya | Satır |
|---|---|
| `test/g1_cekme_yolu_kapisi_test.dart` | 327 (yeni) |
| `test/g2_migration_kapisi_test.dart` | 146 (yeni) |
| `test/g3_ayristirici_kapisi_test.dart` | 231 (yeni) |
| `test/g4_lww_kapisi_test.dart` | 104 (yeni) |
| `test/g5_yerel_koruma_kapisi_test.dart` | 493 (yeni) |
| `test/g6_f2_yakinsama_kapisi_test.dart` | 403 (yeni; 4→5 test, M24 kör-kapı düzeltmesi dahil) |
| `test/generated_migrations/schema_v4.dart` | 449 (yeni, drift_dev dump) |
| `test/destekler/fixture_changes.json` / `fixture_snapshot.json` | (yeni, G3 fixture'ları) |
| `tool/f3_iki_istemci_yakinsama.dart` | 282 (yeni; 6→7 ayak — M29 kör-kapı düzeltmesi + AYAK5 M31 düzeltmesi dahil) |
| `tool/t1_yalniz_cekme_duman.dart` | 91 (yeni) |
| `test/g3_kuyruk_kapisi_test.dart`, `g5_karantina_kapisi_test.dart`, `g8_atomiklik_kapisi_test.dart`, `generated_migrations/schema.dart`, `tool/cakisma_kilidi_duman_testi.dart`, `tool/g6_mutant_dogrulama.dart`, `tool/g6_uctan_uca_kapisi.dart`, `tool/uctan_uca_duman_testi.dart` | küçük düzeltmeler (`devUserId` parametresi eklenmesi — bkz. Hatalar/Düzeltmeler) |

## Ortam notu — EXIT KODU ÖLÇÜM YÖNTEMİ (spec §"ORTAM"dan sapma, GEREKÇELİ)

Spec `cmd /v:on /c "... & echo EXIT=!ERRORLEVEL!"` kalıbını zorunlu kılıyordu (`cmd /c ... %ERRORLEVEL%` KÖR olduğu için). Bu oturumda M4'ün ilk denemesinde bu kalıbın KENDİSİ bir kez `.cmd` dosyası + `echo EXIT=!ERRORLEVEL!>>` satırının **hiç yazılmadığı** bir sessiz başarısızlıkla karşılaştı (bkz. `M4-timer-periodic-ekle.txt` §2 notu). Bunun yerine **ölçülmüş, güvenilir** bir alternatif kullanıldı: PowerShell'in kendi `&` çağrı operatörüyle bir `.cmd`/harici işlem doğrudan çağrılır, hemen ardından `$LASTEXITCODE` okunur ve gerekirse `Add-Content` ile çıktı dosyasına eklenir. Bu, spec'in eleştirdiği `cmd /c ... %ERRORLEVEL%` kalıbı DEĞİLDİR (o, cmd.exe'nin ERRORLEVEL genişletme zamanlaması hatasıydı) — PowerShell'in kendi otomatik değişkenidir ve bu oturumda **40 mutant + tüm G1-G9 kapıları + tüm araç betikleri boyunca** hiçbir yalan/sessiz-atlama gözlemlenmedi (her EXIT= değeri o an gerçekten koşan komuta karşılık geldi, çapraz-kontrol edildi).

## Hatalar ve düzeltmeler (bu oturumda ölçüldü)

1. **M4 (Timer.periodic) ilk denemede SONSUZ DÖNGÜYE girdi** — tavansız bir `Timer.periodic` 14 testlik tüm G1 dosyasında binlerce "Bad state: Can't re-open a database" hatası üretti (268.453 satır), süreç kendi kendine bitmedi. **Elle müdahale:** arka plan görevi durduruldu, iki yetim `dart.exe` süreci (PID 8544, 25296) `Stop-Process -Force` ile sonlandırıldı. Mutant, üç tikten sonra kendini iptal eden GÜVENLİ bir forma getirilip `--name` ile tek teste daraltılarak YENİDEN koşuldu — bkz. `M4-timer-periodic-ekle.txt`.
2. **Backend live testleri için stale DLL kilidi** — önceki bir `Momentum.Api.exe` süreci (PID 27104, sonra 8544/25296'dan bağımsız) `Momentum.Domain.dll`'i kilitleyip `dotnet test`/`dotnet run`'ı MSB3027 ile bloke etti; `Stop-Process -Force` ile temizlendi.
3. **F3/G8 canlı testleri ilk denemede 401 Unauthorized verdi** — API `Hosting environment: Production` ile başlatılmıştı (yalnız `ASPNETCORE_URLS` set edilmiş, `ASPNETCORE_ENVIRONMENT` UNUTULMUŞTU); dev-kimlik-doğrulama geçişi yalnız `IsDevelopment()` altında aktif. `ASPNETCORE_ENVIRONMENT=Development` ile yeniden başlatılınca düzeldi.
4. **Üç kör-kapı bulgusu** (M24, M29, M31) — yukarıda [00-OZET.md](00-OZET.md)'de özetlendi, PAZARLIKSIZ K53 madde 2 gereği kapı düzeltildi (mutant gevşetilmedi).
5. **`design-token-kapisi.py` 6 bulgu ile KIRMIZI yandı** — test dosyalarındaki `Duration(milliseconds: N)` gecikme literalleri "ham tasarım literali" olarak yakalandı (test zamanlama gecikmesi, gerçek bir UI/tasarım tokeni değil). `[DESIGN-LITERAL: gerekçe]` muafiyet yorumu eklenerek düzeltildi (6 satır, `g1_cekme_yolu_kapisi_test.dart` ×4, `g3_ayristirici_kapisi_test.dart` ×1, `f3_iki_istemci_yakinsama.dart` ×1). İlk denemede yorum format hatası (`//` ile `[DESIGN-LITERAL` arasına başka metin girmesi regex'i kırdı) `dosya-kimlik.py` benzeri bir öz-doğrulama koşusuyla yakalandı ve düzeltildi.

## [DOGRULANMADI] — bu turda ölçülmeyen her şey

Bkz. [00-OZET.md](00-OZET.md) son bölüm. Özellikle: **kabul kriteri 9 (Android emülatör açılışı)** bu KANIT turunda koşulmadı — ayrı bir oturum/onay gerektirir.

## Bilinen artık (temizlenmemiş, KANIT bütünlüğünü etkilemez)

`KANIT\slice-3d\09-MUTANT\` altında bu oturumun ürettiği yardımcı/geçici dosyalar (`_run_*.cmd`, `_g_single.cmd`, `_final_gates.cmd`, `_start_api.cmd`, `_api_log.txt`, `_baseline\`) **silinmedi** — proje kuralı ("bir dosyayı kaldırman gerekiyorsa YAPMA, kullanıcıya bildir") gereği. Bu dosyalar `Mnn-*.txt` deseniyle EŞLEŞMEZ, `iddia-kapisi.py` sayımını ETKİLEMEZ (ölçüldü, [08-iddia-kapisi.txt](10-G9-regresyon/08-iddia-kapisi.txt) 40/40 temiz). Onur dilerse elle silinebilir.
