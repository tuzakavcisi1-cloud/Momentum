# GOREV-slice-3e-G12 — Builder ölçümü (Claude Code, 29 Tem 2026)

> **Bu bir SPEC KAPANIŞI DEĞİLDİR** — `GOREV-slice-3e-G12.md` KİLİTLİ bir spec'tir (K79); değişen
> her baytı kilidi bozar, bu belgeye HİÇBİR bayt kopyalanmadı. Aşağıdaki sayılar **builder'ın kendi
> koşumuyla** ölçüldü; kriter 10 gereği **Cowork bunların hiçbirine güvenmeden hepsini yeniden koşacaktır.**

## 1. Yapılanlar (T1–T5, GOREV §2)

| adım | dosya | durum |
|---|---|---|
| T1 | `src/client/lib/ag/signalr_json_sinyal.dart` | `KanalAcici` typedef + enjekte edilebilir `kanalAcici` parametresi; varsayılan davranış (`IOWebSocketChannel.connect`) AYNEN korunur |
| T2 | `src/client/lib/main.dart`, `signalr_json_sinyal.dart` | `_UretimKurulumu.sinyal` alanı eklendi; `durdur()` idempotent + `_denetleyici.close()` çağırıyor |
| T3 | `src/client/lib/ag/signalr_json_sinyal.dart` | `baslat()` ilk satırı `kIsWeb` koruması — web'de hiç bağlanmaz |
| T4 | `src/client/test/g12_sinyal_kapisi_test.dart` | 13 ayak (A1–A13) + strengthened iki ek ayak (A7b ayrı, A13b) = 15 test() |
| T5 | `araclar/yoklama-yasagi-kapisi.py` | Y1–Y4 statik kapı, altın küme 12 vaka |

## 2. Kabul kriterleri (GOREV §4) — builder'ın kendi koşumu

| # | kriter | sonuç |
|---|---|---|
| 1 | `flutter analyze --fatal-infos` | **0 bulgu** |
| 2 | `flutter test` | **171/171** (156 önceki + 15 yeni G12 ayağı; hiç düşen yok) |
| 3 | `yoklama-yasagi-kapisi.py --altin-kume` | **EXIT 0**, **12/12** vaka GEÇTİ (≥9 şartı fazlasıyla aşıldı) |
| 4 | `yoklama-yasagi-kapisi.py .` | 🔴 **EXIT 1 — "temiz depoda susar" ŞARTI KARŞILANMIYOR.** Tek bulgu: `src/client/lib/sunum/senkron_rozeti.dart` içinde bir `Timer.periodic` (bkz. §4 "Bilinen sınırlar") |
| 5 | 16 mutant kanıtı | **16/16** — §3 |
| 6 | `flutter build web --release` | **EXIT 0** |
| 7 | Cihaz regresyonu (Android) | **GEÇTİ** — §5 |
| 8 | `spec-kapi-kapsama.py .` | 🔴 **ÇALIŞTIRILAMADI** — bkz. §4 |
| 9 | `iddia-kapisi.py` (bu belge) | **EXIT 0, HÜKÜM: TEMİZ.** `python araclar\iddia-kapisi.py KANIT/slice-3e-G12/00-HUKUM.md --kanit KANIT/slice-3e-G12` ile builder'ın kendisi koşturdu. 6 SARI "hayalet kanıt" (`M3`,`M52`,`M5z`,`M6`,`M7`,`M?`) çıktı — bunlar aracın KENDİ bilinen sınırından (§8 borcu, bu spec'in kriter 9 dipnotunda da anılıyor): PNG ikilileri metin gibi taranıyor, rastgele baytlar `M\d+` desenine denk düşüyor. KIRMIZI değil, EXIT'i etkilemiyor. |
| 10 | Cowork bağımsız yeniden koşum | N/A (builder rolü kapsamında değil) |

## 3. Mutant tablosu (M58–M73, 16 adet) — kırmızı/yeşil kanıtı `09-MUTANT/`

| # | mutant | hedef ayak | kırmızı | yeşil |
|---|---|---|---|---|
| **M58** | `target == 'Changed'` → `true` | A2 | GEÇTİ (yalnız A2) | 14/14 |
| **M59** | `case 6:` SinyalDegisiklik yayınlasın | A3 | GEÇTİ (A3 + kolateral A6, aynı kök neden) | 14/14 |
| **M60** | `case 7:` `_baglantiKoptu` çağrısı silindi | A4 | GEÇTİ (A4 + kolateral A11, aynı kök neden) | 14/14 |
| **M61** | `default:` `gunlukYaz` silindi | A5 | GEÇTİ (yalnız A5) | 14/14 |
| **M62** | `_cerceveyiAyir` yalnız ilk parça | A6 | GEÇTİ (yalnız A6) | 14/14 |
| **M63** | `_elSikismaYanitiDogrula` `error` kontrolü silindi | A7b | GEÇTİ (yalnız A7b) | 14/14 |
| **M64** | el sıkışma dalındaki `continue` silindi | A8 | GEÇTİ (yalnız A8) | 14/14 |
| **M65** | `_negotiate` `statusCode != 200` kontrolü silindi | A9 | GEÇTİ (yalnız A9) — **A9 fixture'ı bu süreçte GÜÇLENDİRİLDİ** (§4) | 14/14 |
| **M66** | `connectionToken` boş/null kontrolü silindi | A10 | GEÇTİ (yalnız A10) | 14/14 |
| **M67** | `_geriCekilmeIndeksi = 0` sıfırlaması silindi | A11 | GEÇTİ (yalnız A11) | 14/14 |
| **M68** | jitter çarpanı `1.0` sabitlendi | A12 | GEÇTİ (A12 + kolateral A11, aynı kök neden) | 14/14 |
| **M69** | `durdur()`'de `_durduruldu = true` silindi | A13 ailesi (A13b) | GEÇTİ (yalnız A13b) — **A13 ailesine A13b EKLENDİ** (§4) | 15/15 |
| **M70** | `durdur()`'e eklenen `_denetleyici.close()` silindi | A13 | GEÇTİ (yalnız A13) | 15/15 |
| **M71** | `gorev_deposu.dart`'a `Timer.periodic(...cekmeTuruCalistir...)` eklendi | Y1 | GEÇTİ (Y1 dosya adıyla görünür) | Y1 kayboldu (yalnız pre-existing senkron_rozeti.dart kalır) |
| **M72** | `_tekMesajiIsle`'ye `mesaj['arguments']` okuma eklendi | Y2 | GEÇTİ (Y2 satır numarasıyla görünür) | Y2 kayboldu |
| **M73** | `IOWebSocketChannel.connect`'ten `headers:` kaldırıldı | Y4 | GEÇTİ (Y4 görünür) | Y4 kayboldu |

**Kolateral ısırık notu (K79/4):** M59/M60/M68'de HEDEFTEN BAŞKA bir ayak da kırılıyor (A6, A11, A11
sırasıyla) — bu bir "ölü tuzak" DEĞİLDİR (hedef ayak zaten kendi başına kırılıyor, ham çıktıda adı
görünüyor); ayrıntılı gerekçe her `M<nn>-diff.txt`'nin NOT bölümünde yazılı.

## 4. Bilinen sınırlar / bulgular (beyan edildi, gizlenmedi)

- 🔴 **Kriter 4 KARŞILANMIYOR — `src/client/lib/sunum/senkron_rozeti.dart:161` önceden var olan bir
  `Timer.periodic` (dönen ok animasyonu, `_DonenOkState`, K68'den TAMAMEN bağımsız bir UI efekti).
  GOREV Y1'in metni MUTLAK ("her Timer(/Timer.periodic( beyaz listede olmalı", istisna yok) —
  yoklama-yasagi-kapisi.py bunu OLDUĞU GİBİ uyguladı, bulguyu YUMUŞATMADI. Bu dosya slice-3d/R10'dan
  kalma, **G12 kapsamı dışında** (K79/1: T1–T3 ürün kodu + T4/T5 kapı) — dokunulmadı. Kilit Onur'dan
  gelmeli: ya Y1 beyaz listesi genişletilir (UI-animasyon istisnası, spec değişikliği) ya da bu
  bulgu kalıcı "beyan edilmiş sınır" olarak kabul edilir.**
- 🔴 **Kriter 8 çalıştırılamıyor** — `python araclar\spec-kapi-kapsama.py .` → `ORTAM HATASI: [Errno 13]
  Permission denied: '.'` (EXIT 3, dizin argümanı bekliyor, dosya değil). `python
  araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-slice-3e-G12.md` da `EXIT 3` — G12 spec'i
  `## 5. KAPILAR`/`## 6. MUTANTLAR` biçimini DEĞİL, kendi `## 2. YAPILACAKLAR`/`## 3. MUTANT TABLOSU`
  biçimini kullanıyor (araç eski slice-3b/3c/3d biçimine göre yazılmış). **Ne spec (K79 kilitli) ne de
  bu araç (K34-f, T1–T5 dışı) builder tarafından değiştirilmedi** — kilit Onur'dan gelmeli.
- **Test kalitesi bulguları — mutant matrisi ÇALIŞIRKEN ölçüldü, dead-trap önlendi:**
  - A9'un ilk fixture'ı (`http.Response('', 401)`, boş gövde) M65'i YAKALAMAZDI — status kontrolü
    olmasa da `jsonDecode('')` zaten patlardı, aynı sonuca varılırdı. Fixture GÜÇLENDİRİLDİ: gövde artık
    GEÇERLİ bir `connectionToken` taşıyor, böylece status kontrolü SİLİNİRSE gövde "başarılı" sayılır.
  - Orijinal A13, M69'u (durdur()'de `_durduruldu=true` silinmesi) YAKALAMAZDI —
    `_denetleyici.close()` (T2) zaten kapalı kanala sızmayı engelliyordu, `_durduruldu`'nun KENDİ
    etkisi (askıdaki bir denemenin WS açmaya bile ÇALIŞMAMASI) görünmüyordu. Yeni **A13b** ayağı
    eklendi: `kanalAciciCagrildi` bayrağını doğrudan ölçerek bu spesifik korumayı ayırt eder.
- Web ayağı **[DOĞRULANMADI]** olmaya devam eder (K79/2 sınırı) — T3 yalnız "web'de sessizce kapalı"
  olduğunu ölçer.
- `Y3`'ün mutantı YOK (GOREV §3 kilitli borç) — yapay enjeksiyon yazılmadı.
- Sahte kanal (`package:web_socket/testing.dart` + `AdapterWebSocketChannel`) gerçek ağ davranışını
  (TCP kopması, yarım çerçeve, TLS) taşımaz — protokol mantığı ölçülür, taşıma değil (K79/5 sınırı).
- **G12 ile ayrıca ÖLÇÜLEN bir üretim-kodu düzeltmesi:** `_kanaliKapat()`'te bir abonenin `cancel()`ini
  KENDİ olay teslimatı içinden çağırmak, `fakeAsync` altında Future'ın hiç tamamlanmamasına yol açtığı
  gözlemlendi (gerçek/`fakeAsync`-dışı koşumda gözlenmedi — A4 kanıtı). Sebep tam doğrulanmadı ama
  düzeltme (fire-and-forget) bağımsız sağlam — koda ve `signalr_json_sinyal.dart`'ın ilgili
  yorumlarına yazıldı.
- `A12` seed'e (`Random(42)`) bağlıdır; `Random` uygulaması Dart sürümüyle değişirse ayak kırılır —
  beyan edilmiş kırılganlık (GOREV §6).

## 5. Kriter 7 — Android cihaz regresyonu

`emulator-5554`, `com.momentum.client`, backend `127.0.0.1:5298` (zaten çalışıyordu, Development modu).
G12 kodu ile yeniden derlendi (`flutter build apk --debug`), yeniden kuruldu (`adb install -r`).

- El sıkışma başarılı: soğuk açılıştan ~9 sn sonra (`_ws-trafik-kesit.txt`).
- Ayrı bir süreçten (curl, aynı `devUserId`) `POST /v1/sync` ile yeni görev itildi
  (`01-uzak-yazim-istek.json` → `02-uzak-yazim-yanit.json`, **200 Applied**).
- Cihaz **dokunulmadan** ~5 sn içinde `Changed` aldı; ekranda (`01-android-regresyon.png`) yeni görev
  elle yenileme OLMADAN göründü.
- Cihaz DB imleci `{"xid":1251,"seq":291}` → `{"xid":1254,"seq":292}` ilerledi (`_db_before*`/`_db_after*`).
- **Sonuç: `kIsWeb` koruması (T3) Android'i ETKİLEMEDİ** — uygulama hâlâ yoklamasız güncelleniyor.

PNG imzaları doğrulandı: `89 50 4E 47 0D 0A 1A 0A` (ikisi de).

## 6. Dosyalar

`00-HUKUM.md` (bu) · `00-once.png` · `01-android-regresyon.png` · `01-uzak-yazim-istek.json` ·
`02-uzak-yazim-yanit.json` · `_ws-trafik-kesit.txt` (+ tam ham logcat KANIT DIŞINDA, 100KB sınırı —
sha256 ilk16 `571b28ad9ea580ea` bu dosyada kayıtlı) · `_db_before.sqlite`/`_db_before_b64.txt` ·
`_db_after.sqlite`/`_db_after_b64.txt` · `09-MUTANT/M58..M73-{diff,kirmizi,yesil}.txt` (48 dosya, 16×3).
