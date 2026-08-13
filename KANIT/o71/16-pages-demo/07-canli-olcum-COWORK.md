# o71 — PAGES DEMOSU · CANLI ÖLÇÜM (COWORK) · 14 Ağu 2026, 00:57–01:03 TSİ

**Ölçen:** Cowork (üreten el DEĞİL — `K26`). **Ölçüm yolu:** Onur'un Chrome'u,
`claude-in-chrome` MCP. **Adres:** `https://tuzakavcisi1-cloud.github.io/Momentum/`
**İş akışı:** `pages` #1, `demo` işi **succeeded, 2m 1s**; `deploy-pages@v5` →
*"Evaluated environment url: https://tuzakavcisi1-cloud.github.io/Momentum/"*

🔴 **ÖLÇÜM YOLU BEYANI (üç yol denendi, ikisi düştü):** ① Cowork'ün bulut konteyneri +
Playwright/Chromium: **`net::ERR_CONNECTION_RESET`** — konteynerin ağ izin listesi
`github.io`'ya çıkmıyor; bu sayfanın değil **aracın** sınırıdır. ② `WebFetch`: **404** —
`K191`'de ölçülmüş 15 dakikalık URL önbelleği şüphesi altında, **hüküm için kullanılmadı**.
③ **Gerçek tarayıcı (kullanılan yol).** Profil: bu URL o profilde **ilk kez** açıldı
(IndexedDB/SW boş), ama gizli pencere **değil** — beyan edilmiş sapma.

---

## 1. ÖLÇÜLEN DEĞERLER (birebir)

| ölçüm | değer |
|---|---|
| `crossOriginIsolated` | **false** |
| `SharedArrayBuffer` | **tanımsız** |
| `isSecureContext` | true |
| `<base href>` | `https://tuzakavcisi1-cloud.github.io/Momentum/` |
| `_flutter.buildConfig.useLocalCanvasKit` | **true** |
| Service worker | **kayıtlı değil** (`navigator.serviceWorker.controller` = null) |
| `document.title` | **boş dize** |

**Konsol — birebir alıntı (3 satır, her sayfa yüklemesinde tekrar eder):**

```
MOMENTUM-G6-KANIT chosenImplementation=WasmStorageImplementation.sharedIndexedDb
  missingFeatures={MissingBrowserFeature.dedicatedWorkersInSharedWorkers,
                   MissingBrowserFeature.sharedArrayBuffers}
[sinyal] web: gercek zamanli sinyal KAPALI (K79/2) -- elle yenileme tek yol
Injecting <script> tag. Using callback.        (flutter_bootstrap.js, DEBUG)
```

🟢 **21 konsol kaydı ölçüldü, `error`/`exception` sınıfı kayıt sayısı: 0.**
🟢 **Ağ:** üçüncü-taraf/CDN isteği **YOK** (`gstatic.com` çağrısı sıfır — `useLocalCanvasKit`
canlıda da doğrulandı). Sayfa dışına giden tek istek: `http://10.0.2.2:5298/v1/sync`
(**OPTIONS, pending**) — kendi backend'i, ulaşılamaz adres; **kullanıcıya hiçbir hata
göstermeden** sessizce düşüyor.

---

## 2. ETKİLEŞİM TURU (canlı, gerçek tarayıcı)

| adım | sonuç |
|---|---|
| Açılış | **Uygulama çizildi.** Beyaz sayfa **YOK**, `HataDurumu` **YOK**. Boş durum: *"Henüz görev yok. Aşağıdan ekleyin."* |
| `DepolamaSeridi` | **görünür**, metin birebir: *"Veriler tarayıcı deposunda tutuluyor."* (`geriDusus` sınıfı — `olculmedi` değil) |
| **Ekle** | ✅ *"Pages demo olcumu"* eklendi; satırda **↑ Gönderiliyor** rozeti (kuyruk görünür) |
| **Sayfayı yenile (F5)** | ✅ **Veri durdu** — `sharedIndexedDb` kalıcılığı canlıda doğrulandı |
| **Tamamla** | ✅ Kutu işaretlendi, başlık üstü çizildi |
| **Başlık düzenle** | ✅ *"Başlığı düzenle"* diyaloğu açıldı, *"… DUZENLENDI"* olarak kaydedildi |
| **Sil** | 🔴 **UI'DA TETİKLEYİCİ YOK** (aşağıda) |
| **Yenile düğmesi** | ✅ Bastım; kalıcı spinner **yok**, UI donmadı |

---

## 3. YAYIN-DURDURMA ŞARTLARI (v2 §8) — dokuzunun ölçümü

| # | şart | ölçüm |
|---|---|---|
| 1 | ilk kare çizilmiyor (beyaz sayfa) | 🟢 **yanmadı** |
| 2 | CRUD dörtlüsünden biri çalışmıyor | 🔴 **YANDI — `sil` UI'da yok** |
| 3 | yenilemede veri kayboluyor | 🟢 yanmadı |
| 4 | `HataDurumu` blokluyor | 🟢 yanmadı (hiç çizilmedi) |
| 5 | kalıcı spinner | 🟢 yanmadı |
| 6 | konsol hata hızı sönümlenmiyor | 🟢 yanmadı (**0 hata**) |
| 7 | üçüncü-taraf istek > 0 | 🟢 yanmadı (CDN isteği yok) |
| 8 | iş akışı Success değil / pozitif koşum KIRMIZI | 🟢 yanmadı |
| 9 | README çerçevelemesi yok | ⏳ **beklemede** — metni Onur yazacak |

---

## 4. ÖLÇÜLEN İKİ KUSUR

### 4.1 🔴 `sil` UI'da erişilemiyor — README satır 63 ile çelişiyor

Ölçüm (kaynak): `GorevDeposu.sil(String id)` **vardır** (`gorev_deposu.dart`, arayüz satır 81,
uygulama satır 388) ve `Gorevler.silindi` tombstone sütunu (`veritabani.dart`:30) ile senkron
protokolüne bağlıdır. **Ama `gorev_listesi_ekrani.dart` onu hiç çağırmaz** — ekranın çağırdığı
tek depo metotları: `gorevlerGorunur` (63, 77) · `tamamlaGeriAl` (134) · `duzenle` (149) ·
`ekle` (163). Canlı turda kaydırma (`Dismissible`) da denendi: **satır silinmedi**;
`sunum/` altında `Dismissible`/`onSil` **hiç yok**.

`README.md`:63 birebir: *"Flutter: Drift ile çevrimdışı CRUD (ekle · **başlık düzenle** ·
tamamla · **sil**), itme kuyruğu, çekme, çakışma rozeti"*.

⇒ Bir ziyaretçi demoda silmeyi **deneyemez**. İddia veri katmanı için doğru, **ürün yüzeyi
için yanlış**. Bu, demonun kusuru değil; demonun **görünür kıldığı** bir README kusurudur.

### 4.2 🟡 `<title>` çalışma zamanında boşalıyor — `K193` istisnası fiilen etkisiz

`index.html`'e yazılan `<title>Momentum</title>` yalnız **yükleme anında** geçerli;
uygulama açılınca ölçüm **`document.title === ""`** ve `<title>` etiketinin içeriği de **boş**.
Sebep: `main.dart`'taki `MaterialApp`'te **`title:` parametresi yok** ⇒ Flutter web çalışma
zamanında belge başlığını boş dizeyle ezer. Sekmede URL görünür.
`manifest.json` değişikliği (PWA adı `Momentum`) **etkilenmez**, o ayakta duruyor.

---

## 5. DÜŞEN DENETİM BULGULARI (canlı ölçüm çürüttü)

- **C6 / B4①** *"SignalR geri çekilme yolu canlıda ilk kez koşacak"* → **DÜŞTÜ.** Kod web'de
  sinyali hiç başlatmıyor; konsol birebir: *"[sinyal] web: gercek zamanli sinyal KAPALI
  (K79/2) -- elle yenileme tek yol"*. README'nin *"gerçek zamanlı sinyal web'de kapalı"*
  beyanı **canlıda doğrulandı**.
- **C1 / B4②** *"`runApp` öncesi depolama zinciri beyaz ekran üretebilir"* → **bu koşumda
  gerçekleşmedi**; zincir tamamlandı, uygulama çizildi. *(Sınıf kapanmadı — `K161`: bir vaka
  ölçmek sınıf kapatmaz. Farklı tarayıcı/gizli pencere ölçülmedi.)*
- **A7 / C13** *"service worker bayat sürüm servis eder"* → **DÜŞTÜ**: SW **kayıtlı değil**.
- **C9(b)** *"şerit `olculmedi` gösterebilir"* → **DÜŞTÜ**: şerit `geriDusus` metnini gösterdi.

---

## 6. NE ÖLÇÜLEMEDİ

1. **Anonim/gizli pencere** ölçümü — kullanılan profil Onur'un Chrome'u; bulut konteynerinden
   anonim ölçüm ağ izin listesi nedeniyle **imkânsızdı**.
2. **Mobil (Android Chrome)** — `unsafeIndexedDb` beklentisi (denetçi C3) **ölçülmedi**.
3. **Safari/iOS** ve **Firefox** — hiç açılmadı; WebKit'in 7 günlük depolama tavanı (C14) ölçüm dışı.
4. **İlk boya süresi / 4G kısıtı** (C12) — ölçülmedi.
5. **Mixed-content bloğunun kipi** — konsola bir blok mesajı **yansımadı**; isteğin
   `pending` kalması ile blok arasındaki fark **ayırt edilemedi**.
6. **İki sekmede veri yarışı** (`sharedIndexedDb` çok sekme davranışı) — denenmedi.
7. **`flutter_driver`'ın bundle'dan düşüp düşmediği** (`B-o71-PAGES-2`) — bundle sembol
   taraması yapılmadı.
8. Demo turunda eklenen **test kaydı** Onur'un tarayıcı deposunda **duruyor** (silinemedi —
   §4.1); temizlemek isterse site verisini elle silmeli.
