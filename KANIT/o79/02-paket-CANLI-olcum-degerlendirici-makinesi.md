# KANIT — o79 · paketin CANLI ölçümü (değerlendirici-eşdeğeri makine)

**17 Ağu 2026 ~00:15 TSİ · Onur'un Windows makinesi · Docker Desktop · gerçek Chrome**
Cowork koştu (tarayıcı otomasyonu), ölçümler sayfanın kendi bağlamından alındı.

Bu, "tek komutla çalışan uygulama" iddiasının **CI dışında, gerçek bir makinede** ilk ölçümüdür.

## 1. `docker compose up --build -d` — birebir çıktı

```
[+] up 4/4
 ✔ Image momentum:yerel        Built      1639.7s
 ✔ Container momentum-postgres Healthy      16.2s
 ✔ Container momentum-migrator Exited       13.9s
 ✔ Container momentum-api      Started      14.3s
```

- **İlk derleme 1639,7 sn = 27 dk.** CI'da 2,5 dk idi (hızlı ağ + Docker Desktop katmanı yok).
  Bileşen: Flutter arşivi **574 sn** indi (1,54 GB) · `sdk:10.0.302` katmanı 185 MB / 130 sn ·
  `dotnet publish` 271 sn · `ef bundle` 82 sn · `flutter build web` 148 sn.
- **sha256 kapısı gerçek makinede de tuttu:** `/tmp/flutter.tar.xz: OK`.
- `migrator` **Exited** — tasarım gereği şemayı kurup çıktı; `api` ona bağlı olarak başladı.

## 2. Tarayıcıdan ölçüm (`http://localhost:5298`)

```json
{"koken":"http://localhost:5298","baslik":"Momentum",
 "crossOriginIsolated":true,"SharedArrayBuffer":true,
 "glassPane":true,"bootstrapVar":true,
 "healthReady":200,"v1tasks":200}
```

🟢 **`crossOriginIsolated === true`** — bu, o79 denetiminin "NE ÖLÇÜLEMEDİ" listesindeki
maddeydi (`curl` göremez, kapı göremez). Aynı kökenden sunmanın **fiilen** izolasyon ürettiği
burada kanıtlandı.

**Depolama seçimi — Pages ile ölçülmüş fark.** Konsol, birebir:

```
MOMENTUM-G6-KANIT chosenImplementation=WasmStorageImplementation.opfsLocks
                  missingFeatures={MissingBrowserFeature.dedicatedWorkersInSharedWorkers}
```

Pages demosunda aynı satır `sharedIndexedDb` diyordu (`crossOriginIsolated === false`).
Paket **OPFS** kullanıyor. İzolasyon başlıklarının somut karşılığı budur.

Konsoldaki üç `EXCEPTION` (*"A listener indicated an asynchronous response…"*) **tarayıcı
eklentisi gürültüsüdür**, uygulamadan gelmez (kaynak `:0:0`, uygulama çerçevesi yok).

## 3. Uçtan uca senkron — TAÇ MÜCEVHER, pakette ölçüldü

Tarayıcıya yazıldı: `yarin 17:00 paket denemesi #is !p1` → satır **"yarin 17:00 paket denemesi"**,
alt satır **"Yüksek · #is"**.

Sunucuya soruldu (`GET /v1/tasks`, demo kimliğiyle):

```json
{"durum":200,"adet":1,
 "items":[{"entityId":"00000c6f-6c5c-7f5e-86a2-c3ac3ed40446",
           "title":"yarin 17:00 paket denemesi","priority":1,"tags":["is"]}]}
```

⇒ İstemcide yazılan görev **itme kuyruğundan geçip PostgreSQL'e materyalize oldu**. Bu ayak
Pages demosunda ASLA ölçülemiyordu (backend yok) ve CI'da yalnız boş `ops` ile ölçülüyordu.

**Doğal dil sınırları da canlıda doğrulandı** (DURUM sınır 16, ikisi de bilinçli):
ASCII `yarin` TANINMADI (tarih boş) · saat **başlıkta kaldı**.

**Rozet davranışı:** eşitlenmiş satırda rozet **görünmez** — kod da öyle diyor
(`senkron_rozeti.dart`: `SenkronDurumTuru.senkronize => null`). Boş rozet alanı = senkronize.

## 4. NE ÖLÇÜLEMEDİ (bu turda)

1. **Telefon ayağı.** APK bu ölçüm sırasında hâlâ derleniyordu; `DEV_USER_ID`'nin iki istemcide
   fiilen aynı kullanıcıyı verdiği **ölçülmedi**.
2. **Çakışma çözümü pakette** — iki istemci gerekiyor, tek tarayıcıyla kurulamaz.
3. **LAN erişimi.** APK `http://10.129.100.171:5298`e derlendi; telefonun bu ağda olduğu ve
   Windows Güvenlik Duvarı'nın 5298'e izin verdiği doğrulanmadı.
4. **Ekran görüntüsü aracı** iki denemede CDP hatası verdi; üçüncüde çalıştı — kararsızlık kaydedildi.
