# GOREV-A11 Kabul Kriteri 7 — Cihazda Uçtan Uca (2 Ağu 2026, Claude Code)

**Ortam:** `emulator-5554` (tuzak_api34 AVD — bu makinedeki tek AVD) · backend `Development` ·
`momentum-postgres` (docker, healthy).

**Çevrimdışı kapısı:** `airplane_mode_on` ayarı bu emülatörde/API seviyesinde
`am broadcast -a android.intent.action.AIRPLANE_MODE` işlemi `SecurityException`
(`not allowed to send broadcast ... from pid=..., uid=2000`) ile REDDEDİLİYOR — ayar
değişse de radyo gerçekte kapanmıyor (GOREV §4'ün zaten uyardığı "bayrak yalan söyler"
sınıfının bu ortamdaki somut hâli, ÖLÇÜLDÜ). Fiilî çevrimdışı/çevrimiçi geçiş bunun yerine
`adb shell svc data disable/enable` + `adb shell svc wifi disable/enable` ile yapıldı;
**gerçek doğrulama her iki yönde de `adb shell toybox nc -w 2 10.0.2.2 5298` probuyla**
yapıldı (GOREV §4/§7'nin zorunlu kıldığı kapı — buradan sapılmadı).

## Üç koşum, tam şeffaf

1. **`_a11-e2e-log.txt`** — İLK koşum. `svc disable` sonrası 2 görev eklendi, 30 s sızıntı
   yok ölçüldü, 180 s+ çevrimdışı tutuldu, çevrimiçiye dönüldü. **127 s içinde kuyruk HİÇ
   boşalmadı.** Kök neden backend logunda bulundu: `Npgsql.PostgresException 28P01:
   password authentication failed for user "momentum"` — backend'i başlatırken
   `ConnectionStrings__Momentum` ortam değişkenini VERMEMİŞTİM, yanlış/eksik kimlik
   bilgisiyle Postgres'e HİÇ bağlanamıyordu (SignalR `OnConnectedAsync` da aynı hatayla
   patlıyordu — sık "el sıkışma başarılı → bağlantı koptu" döngüsünün gerçek nedeni buydu).
   **Bu bir A11 ürün kusuru DEĞİL, ortam kurulum hatamdı.**
2. **`_a11-e2e-log2-temiz.txt`** — Backend `Host=localhost;Port=5432;Database=momentum;
   Username=momentum;Password=momentum_dev` ile yeniden başlatıldıktan sonraki koşum.
   1 görev (A11TEMIZ1) sunucuya T1+67s'de ulaştı — ama İKİNCİ görev (A11TEMIZ2) yerel
   listeye hiç eklenmemiş çıktı (ekran görüntüsüyle doğrulandı). UI otomasyonu (art arda
   iki `input tap`/`input text`/`input tap`) bu koşumda güvenilmez davrandı — muhtemelen
   backend düzeltmeden ÖNCEKİ SignalR yeniden-bağlanma fırtınasının (2 sn'de bir) uygulama
   üzerindeki kaynak baskısının kalıntısı. **Bu da bir A11 ürün kusuru değil, UI otomasyonu
   kırılganlığıydı** — izole tekrar testinde (PROBE-A/PROBE-B) aynı dizi güvenilir çalıştı.
3. **`_a11-e2e-log3-final.txt`** + **`_a11-final-basarili.png`** — TEMİZ koşum, backend
   düzeltilmiş, iki görev eklemesi ekran dökümüyle doğrulanmış
   (`A11SON1`/`A11SON2`, "Çevrimdışısınız. Değişiklikler kaydedildi." rozetiyle).
   Sonuç: **30 s sızıntı yok · 185 s çevrimdışı (60 s platosu için pay) · çevrimiçi
   dönüşten (nc probu `T1`) yalnız 4 s sonra kuyruk TAMAMEN boşaldı · ekran görüntüsünde
   `cakisma`/`Çevrimdışı` rozeti YOK.** Kabul kriteri 7 **GEÇTİ**.

## Dürüstlük notu

İlk iki koşumun "KIRMIZI" sonucu ürün kodunda değil, benim ortam kurulumumda ve test
otomasyonumdaydı; kök nedenleri ölçüp düzelttikten sonra ÜÇÜNCÜ koşum aynı ürün koduyla
(hiçbir A11 dosyası bu üç koşum arasında değişmedi) temiz geçti. K26 ("üreten ≠ denetleyen")
burada da geçerli: bu üç log de saklandı, hiçbiri silinmedi.
