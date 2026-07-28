# KABUL KRİTERİ 9 — ÖLÇÜM HÜKMÜ (oturum 35, 28 Tem 2026)

**Kriterin KİLİTLİ metni** (`GOREV-slice-3d-cekme.md` §7/9, satır 926-927; spec 80.399 b · `889A383F`):

> Uygulama Android'de **açıldı ve çalıştı** (ekran görüntüsü); açılışta çekme turu koştu ve uzaktan
> gelen bir görev listede **göründü**.

**HÜKÜM: GEÇTİ (3/3 ayak).** Ölçen el Cowork'tür; builder'ın beyanı kullanılmadı (K26).

---

## Ölçüm ortamı (yazılmadı, ÖLÇÜLDÜ)

| alan | ölçülen değer | nasıl |
|---|---|---|
| Emülatör | `emulator-5554` · `sdk_gphone64_x86_64` · AVD `tuzak_api34` | `adb devices -l` |
| Paket | `com.momentum.client` · versionName 1.0.0 | `dumpsys package` |
| APK | `app-debug.apk`, Gradle `assembleDebug` 85,5 s + install 22,8 s | `flutter run` çıktısı |
| Backend | `127.0.0.1:5298` LISTENING, PID **16808** | `netstat -ano` (PID yazılmadı, ölçüldü) |
| Cihaz DB | `/data/data/com.momentum.client/app_flutter/momentum.sqlite`, 32.768 b | `run-as` + `base64` |
| Cihaz `devUserId` | `3e966072-284f-42b9-bd36-aaeb307aab72` | cihaz DB'si `ayarlar` |
| Cihaz `clientId` | `7b6f2012-44a6-4625-95c5-690dbdf1a587` | cihaz DB'si `ayarlar` |
| "Uzak cihaz" `clientId` | `9a1c47d2-5e08-4b31-8f6a-2c05d7e91b44` — cihazınkinden **FARKLI** | yazım betiği |

**Neden aynı `actorId`, farklı `clientId`:** `SyncPuller` yalnız `owner_id` filtreli çeker
(`SyncPuller.cs:40`); görünürlük ancak aynı aktörün **başka bir cihazından** gelen yazımla ölçülebilir.

---

## Ayak A — "Android'de açıldı ve çalıştı"

`adb shell pidof com.momentum.client` ⇒ **15011** (sıcak), soğuk açılıştan sonra **15277**.
Ekran görüntüleri: `01-acilis.png` · `04-uzak-gorev-listede.png` · `06-soguk-acilis-listede.png`.

🔴 **ÖLÇÜM ARACININ KENDİ KUSURU YAKALANDI VE DÜZELTİLDİ:** ilk yakalama
`adb exec-out screencap -p > dosya.png` ile alındı ve **169.840 bayt** yazdı; PowerShell'in `>`
yönlendirmesi ikili veriyi metne çevirip **bozuyor**. Aynı kare `screencap` + `adb pull` ile
**84.550 bayt** ve **geçerli PNG imzası** (`137,80,78,71,13,10,26,10`) döndü. Bozuk dosya silindi.
Ders: *kanıtın VARLIĞI, kanıtın GEÇERLİ olduğunu göstermez* — her PNG'nin imzası ölçüldü.

## Ayak B — "açılışta çekme turu koştu"

**SICAK (hot restart, `main()` yeniden koştu):** imleç `{"xid":1217,"seq":0}` →
`{"xid":1217,"seq":279}`.

**SOĞUK (asıl kanıt):** uygulama `am force-stop` ile **öldürüldü** (`pidof` çıkış **1**),
uygulama ÖLÜYKEN sunucuya ikinci uzak görev yazıldı, sonra `am start` ile **soğuk açılış** yapıldı.
İmleç `{"xid":1220,"seq":280}`'e ilerledi ve görev indi ⇒ turu tetikleyen şey açılıştır, kullanıcı
eylemi değil. Periyodik yoklama YOK (D0) — tek tetikleyici açılıştır.

## Ayak C — "uzaktan gelen bir görev listede göründü"

| görev | opId (v7 nibble) | HTTP | cihaz DB'sinde | ekranda |
|---|---|---|---|---|
| `UZAKTAN GELEN GOREV - oturum 35 kriter 9` | `019fa960-a5d2-**7**e54-...` | 200 `Applied` | ✅ `ce3092e6…` | ✅ `04-…png` |
| `SOGUK ACILIS KANITI 35` | `019fa963-16ea-**7**2c1-...` | 200 `Applied` | ✅ `d9eeffdc…` | ✅ `06-…png` |

`uzak_alan_durumu` 1 → **3** satır; kazanan `win_op_id` değerleri gönderilen v7 opId'lerle birebir.

**İKİ KAPI YAN ÜRÜN OLARAK CANLI DOĞRULANDI (kimse istememişti):**
- **`P4` / v7 nibble zorlaması:** iki opId de UUIDv7 üretildi ve `IsEnvelopeValid`
  (`SyncIngest.cs:131`, `(op.OperationId.ToByteArray()[7] >> 4) != 0x7`) ikisini de **kabul etti**.
- **`B3` / `olusturuldu` türetmesi:** yeni satırların `olusturuldu` değeri
  `2026-07-28T15:38:31.250Z` ve `15:41:11.274Z` — op-HLC'nin `wallMs`'iyle **milisaniyesi
  milisaniyesine aynı**, cihaz saatinden DEĞİL. K69/EK-2'nin `B3` çözümü canlıda tuttu; liste
  sıralaması bu yüzden determinist.

---

## 🔴 KOŞAN UYGULAMANIN ORTAYA ÇIKARDIĞI KUSUR — `R9`: UZAKTAN GELEN GÖREV "YALNIZCA BU CİHAZDA" DİYOR

**Ölçülen:** `06-soguk-acilis-listede.png` — sunucudan gelmiş **iki** görevin ikisi de saat ikonuyla
**"Yalnızca bu cihazda"** rozeti taşıyor. Bu cümle **olgusal olarak yanlıştır**: o satırlar zaten
sunucudan indi.

**Mekanizma (koddan ölçüldü, tahmin değil):**
1. `P6` (K69 kilidi) *"uzak değişiklik rozete DOKUNMAZ"* der ⇒ çekmeyle doğan satır
   `senkron_durumu = 'yerel'` ile INSERT edilir (cihaz DB'sinde ikisi de `yerel`).
2. `senkron_rozeti.dart:52-58` — `SenkronDurumTuru.yerel` ⇒ `Metinler.yalnizcaBuCihazda`.
3. `senkronize` durumunda rozet **hiç çizilmez** (`SizedBox.shrink()`), yani kullanıcının gördüğü
   tek sinyal `yerel`'dir ve o sinyal yanlış tarafa basıyor.

**`P6`'nın gerekçesi bu vakayı KAPSAMIYOR.** `P6`'nın koruduğu şey *bekleyen yerel yazımı olan bir
satırın* rozetinin uzak echo'yla ezilmemesidir (`P7` ile kardeş). **Çekmeyle DOĞAN bir satırda
bekleyen yerel yazım YOKTUR** — `senkron_kuyrugu` bu ölçümde **0 satır**. Yani `P6`, INSERT-from-pull
ile UPDATE-of-local'ı ayırmadan yazıldığı için kapsamı dışına taştı.

**Ayrıca `senkron_rozeti.dart:9-11`'deki DOKÜMAN YORUMU BAYAT:** *"'senkronize' hiçbir zaman gerçek
veriden doğmaz … bu değer yalnız vitrin/testler içindir"* diyor. Cihaz DB'sinde `abcf4930…` satırı
**`senkronize`** ve bu değeri `senkron_dongusu.dart:186` gerçek itme turunda yazıyor (K69/EK-2 `B1`
aynı satırı gösteriyor). Yorum yanlış; ekranda o satırın rozetsiz görünmesi de bunu doğruluyor.

**Neden bu kâğıtta bulunamazdı:** üç denetim turu, 40 mutant ve 136 widget testi `P6`'yı
*"rozete dokunma"* olarak doğru uyguladı. Kusur **uygulamada değil, kilidin kapsamında**; ancak
gerçek bir listeye bakınca görünür. **`R8`/DURDUR kilidinin ödediği bedel tam olarak budur.**

**Vitrin riski (abartısız):** değerlendirici uygulamayı açtığında, çevrimdışı-öncelikli senkronun
vitrini olan ekranda, sunucudan gelmiş bir görevin *"yalnızca bu cihazda"* dediğini görür.

🔴 **DÜZELTİLMEDİ — bu bir TASARIM KİLİDİ (`P6`) değişikliğidir, kilit Onur'dan gelir.** Oturumun
kilidi DURDUR/kriter 9 ölçümüydü; kapsam dışına çıkılmadı.

---

## Ölçülmedi / `[DOĞRULANMADI]`

- **`01-acilis.png` karesinde bir `System UI isn't responding` (ANR) diyaloğu var.** Diyalog
  **System UI**'a aittir, `com.momentum.client`'a değil (`pidof` boyunca canlı). Emülatörün yazılım
  GPU'sunda `Skipped 396 frames` / `Davey! duration=5728ms` ölçüldü. **Uygulamanın kendi ANR'si
  olmadığı ölçülmedi** — yalnız diyaloğun sahibi ölçüldü. Soğuk açılış karesi (`06`) temizdir.
- Uygulamanın **soğuk açılış süresi** ölçülmedi (kriter süre şartı koymuyor).
- Görev **düzenleme/tamamlama/silme** yollarının uzak yansıması bu ayakta ölçülmedi; kriter 9 yalnız
  *"göründü"* diyor.
- Web ayağı · iOS · boşaltma tavanı 20'nin yeterliliği — spec §10'daki `[DOGRULANMADI]` olarak
  **duruyor**, bu ölçüm onlara dokunmadı.

## Dosyalar

`00-HUKUM.md` (bu) · `01-acilis.png` · `02-uzak-yazim-istek.json` · `02b-uzak-yazim-kimlikler.txt` ·
`03-uzak-yazim-yanit.json` · `04-uzak-gorev-listede.png` · `05-soguk-acilis-uzak-yazim.json` ·
`05b-soguk-acilis-kimlikler.txt` · `06-soguk-acilis-listede.png` · `07-cihaz-db-son.txt`
