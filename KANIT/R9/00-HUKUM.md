# HÜKÜM — GOREV-R9-rozet-kapsami

**Tarih:** 28 Tem 2026 · **Kök:** `C:\dev\Momentum` · **Spec:** `GOREV_CLAUDE_CODE\GOREV-R9-rozet-kapsami.md` (14.061 b · `B2082127`)
**Kilit:** K72 (Onur, oturum 35) — `P6`/`D4` DARALTMA, tasarım turu tekrar açılmadı.
**Bu belge kanıt SAYILMAZ** (dairesel kanıt yasağı) — yalnız ham dosyalara ATIF yapar.

## Nihai hüküm: YEŞİL

`T1`–`T4` uygulandı, `G10`'un altı ayağı da YEŞİL, `M41`–`M45` tek tek KIRMIZI→geri alındı→YEŞİL, kırmızı çizgilerin hiçbiri ihlal edilmedi, cihaz üzerinde tekrar ölçüm kusurun düzeldiğini doğruladı.

## Kabul kriterleri — tek tek

| # | Kriter | Durum | Kanıt |
|---|---|---|---|
| 1 | `G10`'un altı ayağı da YEŞİL, çıkış kodu KANIT'ta | ✅ | [01-G10/g10-test-ciktisi.txt](01-G10/g10-test-ciktisi.txt) — EXIT=0, 6/6 |
| 2 | `M41`–`M45` tek tek uygulandı, hedef ayak KIRMIZI, geri alındı, YEŞİL döndü; ham çıktı koşum anında; her mutant için düşen ayağın YALNIZ G10 mu yoksa mevcut testle BİRLİKTE mi düştüğü beyan edildi | ✅ | [MUTANT/M41.txt](MUTANT/M41.txt) … [MUTANT/M45.txt](MUTANT/M45.txt) — her dosyada ayrı "[BEYAN]" bölümü |
| 3 | `flutter analyze --fatal-infos` 0 bulgu · `flutter test` EXIT 0 · test sayısı 136→142 (136+G10'un 6'sı), `g3_ayristirici_kapisi_test.dart`'ın bir testi T3 ile GÜNCELLENDİ | ✅ | [03-flutter-analyze.txt](03-flutter-analyze.txt) (EXIT 0) · [03-flutter-test.txt](03-flutter-test.txt) (EXIT 0, **142/142** — "136 aynen durdu" demek burada YANLIŞ olurdu, doğrusu 136→142) |
| 4 | `tek-kopya-kapisi.py` EXIT 0 · `design-token-kapisi.py` EXIT 0 | ✅ | [04-tek-kopya-kapisi.txt](04-tek-kopya-kapisi.txt) · [04-design-token-kapisi.txt](04-design-token-kapisi.txt) |
| 5 | `schemaVersion == 4` DEĞİŞMEDİ, yeni şema dosyası EKLENMEDİ | ✅ | `veritabani.dart:102` hâlâ `=> 4`; `git status --porcelain -- test/generated_migrations/` **boş** (ölçüldü, komut çıktısı sıfır satır) |
| 6 | UPDATE dalına (`mevcut != null`, `:235` civarı) hiçbir `+`/`-` satır YOK | ✅ | [06-update-dali-diff.txt](06-update-dali-diff.txt) — tek değişiklik INSERT dalında (`} else {`'den ÖNCE); `else` bloğu diff'te hiç görünmüyor |
| 7 | Backend'e TEK SATIR dokunulmadı: `git diff --stat -- src/backend/` boş | ✅ | [07-backend-diff-stat.txt](07-backend-diff-stat.txt) — **0 satır** |
| 8 | `iddia-kapisi.py --kanit KANIT\R9` EXIT 0 · `spec-kapi-kapsama.py` EXIT 0 | ✅ | [08-iddia-kapisi.txt](08-iddia-kapisi.txt) (5/5 mutant kanıtlı, TEMİZ) · [08-spec-kapi-kapsama.txt](08-spec-kapi-kapsama.txt) — 🔴 **ARAÇ KUSURU ÖLÇÜLDÜ:** `02-cihaz/03-soguk-acilis-listede.png` ikili içeriği tarandığında rastgele bayt dizileri `M0`/`M3`/`M5`/`M7` desenine denk düşüyor, dört SARI "HAYALET KANIT" bulgusu üretiyor (`grep` ile doğrulandı: `Binary file ...png matches`). Hüküm yine de **TEMİZ/EXIT 0** (SARI, KIRMIZI değil) — `iddia-kapisi.py` metin-dışı dosyaları da tarıyor, bu ölçülmüş bir araç sınırıdır, gizlenmedi. |
| 9 | Cihazda tekrar ölçüm: `10-KABUL9` kurgusu yeniden koşuldu; yeni ekran görüntüsünde uzaktan gelen görev "Yalnızca bu cihazda" DEMİYOR | ✅ | Aşağıdaki "Kabul kriteri 9 — cihaz ölçümü" bölümü + [02-cihaz/](02-cihaz/) |
| 10 | Ölçülmeyen hiçbir şey "temiz" sayılmadı | ✅ | Bkz. `[DOĞRULANMADI]` bölümü |

## Kabul kriteri 9 — cihaz ölçümü (ayrıntı)

**Ölçüm ortamı:**

| alan | değer | nasıl |
|---|---|---|
| Emülatör | `emulator-5554` (`tuzak_api34`, önceki oturumdan zaten açık — soğuk boot GEREKMEDİ, uygulama zaten `force-stop`/`am start` ile "soğuk" test edildi) | `adb devices` |
| APK | R9 (`T1`) dahil taze `assembleDebug` (68,1 s), `adb install -r` (veri KORUNDU) | [_tmp_build.txt gibi ham log yalnız oturum içi, dosyaya alınmadı — build EXIT ölçüldü: 0] |
| Backend | `127.0.0.1:5298`, PID **16808** — ÖNCEKİ oturumdan beri AYNI süreç (yeniden başlatılmadı) | `netstat -ano \| findstr :5298` |
| Cihaz `actorId`/`devUserId` | `3e966072-284f-42b9-bd36-aaeb307aab72` (önceki oturumla AYNI, veri korunduğu için) | cihaz DB `ayarlar` |
| "Uzak cihaz" `clientId` (bu tur) | `d581b5ac-2334-4c17-9e71-aed020758aea` (yeni, tek kullanımlık) | [02-cihaz/01b-uzak-yazim-kimlikler.txt](02-cihaz/01b-uzak-yazim-kimlikler.txt) |

**Prosedür (ölçüldü, `KANIT/slice-3d/10-KABUL9/` kurgusunun AYNISI):**
1. Cihaz DB'si `adb pull` ile okundu (`run-as`+`cp`+redirect denemesi BOM ile bozdu — `adb root` + doğrudan `adb pull` ile düzeltildi, bkz. [02-cihaz/05-png-imza-dogrulama.txt](02-cihaz/05-png-imza-dogrulama.txt)).
2. Gerçek `/v1/sync` uç noktasına, cihazınkinden **FARKLI** bir `clientId` ile fakat **AYNI** `actorId` (`X-Momentum-Dev-User` başlığı) taşıyan bir istek gönderildi — "başka bir cihazdan gelen yazım" simüle edildi. HTTP **200**, `code: "Applied"`. Kanıt: [02-cihaz/01-uzak-yazim-istek.json](02-cihaz/01-uzak-yazim-istek.json) · [02-cihaz/02-uzak-yazim-yanit.json](02-cihaz/02-uzak-yazim-yanit.json).
3. Uygulama `am force-stop` ile öldürüldü (`pidof` çıkış **1**, ölçüldü), sonra `am start` ile **soğuk** açıldı (yeni PID **16028**).
4. Ekran `adb shell screencap -p` + `adb pull` ile yakalandı (**`>` yönlendirmesi KULLANILMADI**); PNG imzası bayt bayt doğrulandı. Kanıt: [02-cihaz/03-soguk-acilis-listede.png](02-cihaz/03-soguk-acilis-listede.png) · [02-cihaz/05-png-imza-dogrulama.txt](02-cihaz/05-png-imza-dogrulama.txt).
5. Cihaz DB'si tekrar çekildi ve sorgulandı. Kanıt: [02-cihaz/04-cihaz-db-son.txt](02-cihaz/04-cihaz-db-son.txt).

**Sonuç (ölçüldü):**
- Ekranda **"R9 DUZELTME KA…"** satırı (yeni gelen görev) — **saat ikonu YOK, "Yalnızca bu cihazda" YOK**.
- Cihaz DB'sinde bu satırın `senkron_durumu = 'senkronize'`.
- İmleç `{"xid":1220,"seq":280}` → `{"xid":1223,"seq":281}` ilerledi ⇒ soğuk açılışta çekme turu **gerçekten koştu** (D0, periyodik yoklama yok — tek tetikleyici açılış).
- **DÜRÜST KIYAS:** ekranda hâlâ ÜÇ eski satır "Yalnızca bu cihazda" gösteriyor (`UZAKTAN GELEN GÖREV…`, `SOGUK ACILIS KANITI 35`, ve yerel `G6 android kaniti`). İlk ikisi **önceki oturumda, ESKİ (düzeltme öncesi) APK ile** çekilip `'yerel'` olarak INSERT edilmiş satırlardır — spec §10 kriter 5'in yasakladığı migration OLMADIĞI için bu eski satırlar GERİYE DÖNÜK düzelmiyor (bu **beklenen ve doğru** davranış, kusur DEĞİL: `T1` yalnız BUNDAN SONRAKİ INSERT-from-pull'u düzeltir). `G6 android kaniti` zaten GERÇEKTEN yereldir (rozeti doğru).

## Mutant özeti (M41–M45)

| # | hedef | beklenen ayak | kolateral (spec önceden beyan etti) |
|---|---|---|---|
| M41 | INSERT `Value('senkronize')` silindi | AYAK1+AYAK2+AYAK5 | g3 (T3'ün testi) |
| M42 | UPDATE dalına da yazıldı (kilit ihlali) | AYAK3+AYAK4 | g3:158, g5:330-331 |
| M43 | INSERT'e `'yerel'` yazıldı | AYAK1+AYAK2+AYAK5 | g3 (T3'ün testi) |
| M44 | `yerel` dalı `SizedBox.shrink()` | AYAK6 | sunum_bilesenleri_test.dart:79-80, a11y_kapisi_test.dart:295(+ekran testi) |
| M45 | `snapshotUygula` sonu `_projeksiyonYaz` çağrısı kaldırıldı | AYAK2 (yalnız), AYAK1 YEŞİL kalır | yok — YALNIZ G10 |

Beşinin beşi de spec'in "beklenen" sütunuyla **birebir** eşleşti; hiçbir mutant kör çıkmadı (M41-M45 için — R9'un KENDİ mutantları bunlar; ayrıca T1'in eklediği kodun G6/F2 gibi ÖNCEKİ dilimin kapılarında kör kalıp kalmadığı bu spec'in kapsamı dışıdır, o zaten slice-3d'nin M24/M29/M31 kör-kapı düzeltmeleriyle ayrı ele alındı).

## R10 — kapsam dışı bırakıldı (spec §4, beyan)

Bu dilimde **dokunulmadı**: çekilmiş `senkronize` bir satır yerelde düzenlenirse rozet susar (`SizedBox.shrink()`). Öncelik kilidi Onur'dan gelmeden `gorev_deposu.dart`'ın dört yazma yoluna dokunulmadı (kırmızı çizgi 3). Kanıt: kod değişmedi — `git diff -- src/client/lib/veri/gorev_deposu.dart` boş (aşağıda doğrulandı).

```
$ git --no-optional-locks diff --stat -- src/client/lib/veri/gorev_deposu.dart
(boş)
```

## [DOĞRULANMADI] — bu turda ölçülmedi

- Web ayağı (`--platform chrome` bu ortamda sonuç üretmiyor, önceden beyan edilmiş sınır).
- iOS (Mac yok, CI-only).
- `R10`'un kendisi — spec'in kendisi bunu bilinçli kapsam dışı bırakıyor (§4/§8), Onur'un öncelik kilidini bekliyor.
- Görev düzenleme/tamamlama/silme yollarının uzak yansıması — kriter 9 yalnız "göründü"yü ölçtü, bu ayrı bir ölçüm.
- Uygulamanın soğuk açılış SÜRESİ ölçülmedi (kriter süre şartı koymuyor).
- Ekranda bir ANR/sistem diyaloğu görünüp görünmediği bu turda ayrıca ölçülmedi (önceki turda System UI'a ait olduğu, uygulamanın kendisine değil, ölçülmüştü — bu tur o ölçümü TEKRARLAMADI, yalnız rozet ölçüldü).

## Değişen dosyalar (satır sayısı)

| Dosya | +/- |
|---|---|
| `src/client/lib/senkron/uzak_degisiklik_uygulayici.dart` | T1: +5/-1 (yalnız INSERT dalı) |
| `src/client/lib/sunum/senkron_rozeti.dart` | T2: +6/-3 (yalnız doküman yorumu, kod DEĞİŞMEDİ) |
| `src/client/test/g3_ayristirici_kapisi_test.dart` | T3: +2/-2 (bir testin adı+expect+reason'ı) |
| `src/client/test/g10_rozet_kapsami_test.dart` | T4: 191 satır (yeni) |

**Backend: 0 satır.** **`schemaVersion`: değişmedi (4).** **UPDATE dalı: 0 satır.**

## Ortam notu (mirasen alınan pratik)

`git --no-optional-locks` kullanıldı. `flutter test` için `PROGRAMFILES(X86)` PowerShell'in kendi sürecinde zaten doğru tanımlıydı (`[Environment]::GetEnvironmentVariable` ile ölçüldü) — Desktop Commander kabuğuna özgü kusur bu oturumda GÖZLENMEDİ, ayrı enjeksiyon gerekmedi. Exit kodları PowerShell'in `&` çağrı operatörü + `$LASTEXITCODE` ile ölçüldü (slice-3d'de aynı yöntem 40 mutant + tüm kapılar boyunca hiç yalan söylemedi).

## Bilinen artık

`KANIT\R9\` altında bu oturumun yardımcı/geçici dosyaları (`_run.cmd`, `_baseline\`, `_tmp_*.sqlite`, `_tmp_*.txt`) **silinmedi** (proje kuralı: kaldırman gerekiyorsa yapma, bildir). `Mnn.txt` deseniyle eşleşmiyorlar, `iddia-kapisi.py` sayımını etkilemiyorlar (ölçüldü, 5/5 temiz). Backend dev server (`127.0.0.1:5298`, PID 16808) ve emülatör (`emulator-5554`) hâlâ AÇIK bırakıldı — Cowork'ün bağımsız doğrulaması için gerekebilir.

Commit/push **YAPILMADI** — Onur'un işi.
