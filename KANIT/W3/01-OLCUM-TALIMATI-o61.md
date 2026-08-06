# T0 — W3 ÖN-KOŞUL ÖLÇÜMÜ (`D-W3-0` / `K148`)

**KOŞAN: Onur ya da Claude Code — Cowork DEĞİL** (`K80`: Cowork ortam kaldırmaz).
**Sonuç yazılacak yer:** `KANIT/W3/02-OLCUM-SONUC-o61.md`
🔴 **Bu ölçüm YEŞİL gelmeden `GOREV-W3` `T1`–`T10`'un tek satırı yazılmaz.**

---

## Neden bu ölçüm var

`GOREV-W3` §1/`O5`: bugünkü `chosenImplementation` / `missingFeatures` **hiçbir belgede birebir
yazılı değil**. Üç şey ölçülmeden dilim **temelsizdir**:

1. Chrome bugün `opfsShared`'ı **destekliyor mu**? (Desteklıyorsa **izolasyona hiç gerek yok** ve
   `W3` dilimi **İPTAL EDİLİR**.)
2. `missingFeatures` içinde `workerError` ya da `fileSystemAccess` **var mı**? (Varsa izolasyon
   tek başına **hiçbir şeyi çözmez**, kök sebep başkadır.)
3. İzolasyon fiilen sağlandığında drift **gerçekten** `opfsLocks`'a geçiyor mu?

---

## ÖN ŞART — `D-W3-8` GÜVENLİ BAĞLAM

🔴 Sayfa **YALNIZ** `http://localhost:<port>` ya da `https://…` üzerinden açılacak.
`http://192.168.x.x`, `http://127.0.0.1` **dışı** her adres **güvenli bağlam DEĞİLDİR**
(MDN: *"your document must be in a secure context and cross-origin isolated"*) ve o koşum
**`[ÖLÇÜLMEDİ]`** sayılır. Tarayıcı adres çubuğundaki adres **birebir** rapora yazılacak.

---

## KOŞUM 1 — BUGÜNKÜ HÂL (temel çizgi, izolasyon YOK)

```powershell
cd C:\dev\Momentum\src\client
flutter run -d chrome --web-port=5000
```

Sayfa açılınca **DevTools → Console**:
```js
console.log('IZOLE=', crossOriginIsolated, '| SAB=', typeof SharedArrayBuffer);
```

**Kaydedilecek (BİREBİR kopyala-yapıştır, özetleme):**
- `MOMENTUM-G6-KANIT` ile başlayan **tam satır** (uygulama kendi basıyor)
- `chosenImplementation=` değeri
- `missingFeatures=[…]` **tam listesi**
- `IZOLE=` ve `SAB=` çıktısı
- adres çubuğundaki **tam adres**

---

## KOŞUM 2 — İZOLASYONLU (bayrakla zorlanmış)

🔴 `flutter run`'ın kendi dev sunucusu COOP/COEP **göndermez**. Bu yüzden izolasyon
**tarayıcı bayrağıyla** taklit edilir:

```powershell
# Chrome'un TÜM pencerelerini kapat, sonra:
& "C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --user-data-dir="C:\temp\chrome-izole-test" `
  --enable-features=SharedArrayBuffer `
  http://localhost:5000
```

*(`flutter run` **1. koşumdan** ayakta kalsın; yalnız tarayıcı yeniden açılıyor.)*

**Aynı beş kalem** yeniden kaydedilir. Beklenen: `IZOLE= true`.

🔴 **`IZOLE= false` çıkarsa:** bayrak tutmadı ⇒ bu koşum **`[ÖLÇÜLEMEDİ]`** yazılır, **uydurma
yapılmaz**. O hâlde `W3` dilimi *"ölçülemedi"* ile açık kalır ve `T1` **yine başlamaz**.

---

## KOŞUM 3 — TEMİZ KÖKEN (veri taşıma etkisi olmadan)

🔴 `D-W3-7` **geri alınamaz veri taşıması** yapar. Bu yüzden üçüncü koşum **temiz bir kökende**,
**boş** IndexedDB ile yapılır:

```powershell
flutter run -d chrome --web-port=5001
```
Sonra **DevTools → Application → Storage → Clear site data** → sayfayı yenile → aynı beş kalem.

**Amaç:** *"mevcut veritabanı olmasaydı drift ne seçerdi?"* sorusunun yanıtı. Bu, `O2`'nin
(drift'in mevcut biçimi koruması) **fiilen** kök sebep olup olmadığını ayırır.

---

## HÜKÜM TABLOSU — sonuç dosyasına AYNEN doldurulacak

| # | adres | `IZOLE` | `chosenImplementation` | `missingFeatures` | güven |
|---|---|---|---|---|---|
| 1 | | | | | KESİN / ÖLÇÜLEMEDİ |
| 2 | | | | | KESİN / ÖLÇÜLEMEDİ |
| 3 | | | | | KESİN / ÖLÇÜLEMEDİ |

### Hüküm kuralları (pazarlıksız)

| gözlenen | hüküm |
|---|---|
| Herhangi bir koşumda `opfsShared` | 🔴 **`W3` İPTAL** — Chrome desteklemiş, izolasyona gerek yok. `ADR 0004` bunu kaydeder. |
| `missingFeatures` içinde `workerError` **ya da** `fileSystemAccess` | 🔴 **`W3` DURDURULUR** — kök sebep izolasyon değil; yeni teşhis dilimi açılır. |
| Koşum 2'de `IZOLE=true` **ve** `chosenImplementation` hâlâ `sharedIndexedDb`, **ama** koşum 3'te `opfsLocks` | ✅ **`O2` DOĞRULANDI** — sebep drift'in mevcut biçimi koruması. `W3` **tam kapsamıyla** koşar (`D-W3-7` dâhil). |
| Koşum 2'de `IZOLE=true` **ve** `opfsLocks` | ⚠️ **`D-W3-7` GEREKSİZ olabilir** — yalnız sunucu tarafı yeter. `T5` **düşürülür**, `G47` yeniden yazılır. Onur'a sorulur. |
| Koşum 2 `IZOLE=false` | 🔴 **`[ÖLÇÜLEMEDİ]`** — `T1` başlamaz, başka ölçüm yolu aranır. |

---

## NE ÖLÇÜLEMEDİ (bu talimatın kendi sınırı)

- **Bayrakla taklit edilen izolasyon ≠ başlıkla sağlanan izolasyon.** `--enable-features` yolu
  `crossOriginIsolated`'ı `true` yapabilir ama gerçek COOP/COEP davranışını **tam** yansıtmaz;
  koşum 2 bir **gösterge**dir, `G46`'nın yerine geçmez.
- **Chrome sürümü kaydedilmeli** (`chrome://version`) — `opfsShared` desteği sürüme bağlıdır ve
  bu ölçüm **o güne aittir**.
- Firefox/Safari **ölçülmüyor**; `W3`'ün tüm iddiaları **Chrome'a** özeldir.
