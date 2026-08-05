# W3 — B1 ÖLÇÜM TALİMATI (oturum 61'in İLK işi)

🔒 **Onur kilitledi (oturum 60):** *"Önce ÖLÇ, sonra v2."* Bu ölçüm koşulmadan `W3` v2 **yazılmaz**.
**Koşacak el:** Onur ya da Claude Code. **Cowork KOŞMAZ** (`K80` — Cowork ortamı kaldırmaz, doğrular).

---

## NEYİ KARARA BAĞLIYOR

`KANIT/W3/00-DENETIM-o60.md` `B1`: `drift 2.34.3`'te `WasmDatabase.open`'ın
`moveExistingIndexedDbToOpfs` varsayılanı **`false`**; mevcut bir veritabanı varsa drift
*"veri kaybını önlemek için"* **eski biçimde kalır**. `drift_flutter 0.3.1` bu bayrağı
**geçiremiyor** ve `veritabani.dart:180` tam da `driftDatabase(name: 'momentum', …)` kullanıyor.

⇒ **Soru:** çapraz-köken izolasyonu açıldığında drift **gerçekten** `opfsLocks`'a geçiyor mu,
yoksa mevcut IndexedDB veritabanı yüzünden `sharedIndexedDb`'de mi kalıyor?

**Bu ölçüm olmadan yazılacak her v2 satırı tahmindir.** Denetçinin kendi ifadesi:
*"Kilitten önce koşulması gereken tek ölçüm budur."*

---

## KOŞUM

**Ön koşul:** backend **GEREKMEZ** — drift depolama seçimini veritabanını açarken yapar, senkron
istemez. (İstersen `ORTAM.md` reçetesiyle ayağa kaldır; ölçümü değiştirmez, sayfayı normalleştirir.)

`--web-header` bayrağı **yalnız `flutter run`**'da vardır (`build_web.dart` `usesWebOptions()`
çağırmaz — Flutter kaynağında doğrulandı). Bu bir **ölçüm aracıdır**, üretim çözümü değildir.

### Ölçüm A — BUGÜNKÜ TABAN (izolasyon YOK)
```
flutter run -d chrome --web-port=5000
```
DevTools konsolunda şu satırı bul ve **BİREBİR** kaydet:
`MOMENTUM-G6-KANIT chosenImplementation=<...> missingFeatures=<...>`
Ayrıca konsola yaz ve sonucu kaydet: `crossOriginIsolated` (beklenen: **false**)

### Ölçüm B — İZOLASYON AÇIK, MEVCUT VERİTABANI DURUYOR
```
flutter run -d chrome --web-port=5000 --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```
🔴 **ÖNCE** konsolda `crossOriginIsolated` yaz. **`true` DEĞİLSE ölçüm GEÇERSİZDİR** — sebebini
(başlıklar gelmedi mi, güvenli bağlam mı) kaydet ve **dur**. `true` ise aynı `MOMENTUM-G6-KANIT`
satırını **BİREBİR** kaydet.

### Ölçüm C — İZOLASYON AÇIK, TEMİZ KÖKEN (veritabanı YOK)
```
flutter run -d chrome --web-port=5001 --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```
🔴 **`5001` bilinçlidir:** farklı port = **farklı köken** = o kökende `momentum` veritabanı **YOK**.
Böylece drift serbestçe seçer ve **hiçbir şey silinmez** (yerel veri imha etmeye gerek yok).
`crossOriginIsolated` + `MOMENTUM-G6-KANIT` satırını **BİREBİR** kaydet.

### Ek kayıt (tek satır, ucuz ama pahalı bir soruyu kapatır)
Chrome sürümü: `chrome://version` ilk satırı. *(Denetim, `opfsShared`'ın Chrome'da
desteklenmediğini **yalnız drift'in kendi belgesine** dayandırdı — tedarikçi beyanı, bağımsız
teyit değil. Chrome bunu sessizce eklediyse `opfsShared` seçilir ve **W3'ün tamamı gereksizdir**.)*

---

## HÜKÜM TABLOSU — ölçüm bittiğinde hangi sonuç neyi söyler

| A | B | C | HÜKÜM | v2'ye etkisi |
|---|---|---|---|---|
| `sharedIndexedDb` | **`opfsLocks`** | — | 🟢 **`B1` ÖLÜ** | v2 **yalnız sunucu işidir**; istemci koduna dokunulmaz |
| `sharedIndexedDb` | `sharedIndexedDb` | **`opfsLocks`** | 🔴 **`B1` KANITLANDI** | v2 **istemci kodu değişikliğini ZORUNLU kılar** (`driftDatabase` bırakılıp `WasmDatabase.open(..., moveExistingIndexedDbToOpfs: true)`) — ve bu **ürün kodudur**, `R8`'i düşürür |
| `sharedIndexedDb` | `sharedIndexedDb` | `sharedIndexedDb` | 🔴 **PREMİS ÇÖKTÜ** | izolasyon tek başına yetmiyor ⇒ `missingFeatures` okunur; `workerError`/`fileSystemAccess` çıkarsa W3'ün gerekçesi yeniden yazılır |
| herhangi | **`opfsShared`** | — | 🔴 **W3 GEREKSİZ** | Chrome desteklemiş; dilim **park edilir**, `ADR 0004` bunu kaydeder |
| — | `crossOriginIsolated=false` | — | ⚪ **ÖLÇÜLEMEDİ** | `--web-header` etkisiz; ölçüm yolu değişmeli, hüküm YOK |

🔴 **Tabloyu okurken:** `chosenImplementation` satırı **görülmeden** hiçbir satır işaretlenmez.
Ölçemediğine **"ÖLÇÜLEMEDİ"** yaz — yeşil de kırmızı da **varsayma**.

---

## TESLİM

Sonuçlar **`KANIT/W3/02-OLCUM-SONUC-o61.md`**'ye yazılır. İçerik:
① üç koşumun **birebir** konsol satırları ② her koşumda `crossOriginIsolated` değeri
③ Chrome sürümü ④ hüküm tablosundan **işaretlenen satır** ⑤ ölçülemeyen ne varsa **"ÖLÇÜLEMEDİ"**
başlığı altında — **boş olamaz**.

Sonra `W3` v2 bu ölçümle yazılır ve `KANIT/W3/00-DENETIM-o60.md`'deki **altı bloker + 14 major**
madde madde kapatılır.
