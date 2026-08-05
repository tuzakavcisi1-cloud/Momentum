# ADR 0004 — Web Çapraz-Köken İzolasyonu (COOP/COEP) ve OPFS Kalıcılığı

- **Durum:** 📝 **İSKELET** — GOREV-W2 (K142, spec v3) kriter 10 gereği açıldı. Karar İÇERMEZ; yalnız
  bağlamı ve açık soruyu sabitler. **KİLİT YOK** — bu dilimde build EDİLMEZ.
- **Tarih:** 2026-08-05 (açılış) — oturum 59
- **Kaynak dilim:** `GOREV-W2-depolama-gorunurlugu.md` §2 "DIŞARIDA, gerekçeli" maddesi:
  *"COOP/COEP ve OPFS'e geçiş ⇒ `ADR 0004`"*.

---

## 1. Bağlam

W2 ölçtü (build sırasında, tarayıcıda): bu projenin web istemcisi bugün `sharedIndexedDb`
implementasyonuna **geri düşüyor** — `opfsShared`/`opfsLocks` (kalıcı, OPFS-tabanlı depolama)
**seçilmiyor**. Ölçülmüş sebep, drift'in kendi kaynağında (`wasm_setup/types.dart`) belgeli:

- `opfsShared` yalnız Firefox'ta uygulanmış (Chrome: [crbug.com/1088481](https://crbug.com/1088481);
  Safari henüz desteklemiyor).
- `opfsLocks` **çapraz-köken izolasyonu** ister: sunucunun yanıtlarında
  `Cross-Origin-Opener-Policy: same-origin` ve `Cross-Origin-Embedder-Policy: require-corp`
  başlıklarının bulunması gerekir.

Bugün sunucu bu başlıkları **göndermiyor** ⇒ Chrome'da kalıcı OPFS yolu **erişilemez**, istemci
`sharedIndexedDb`'ye düşer. `sharedIndexedDb` de bir şeyler saklar (W1 kriter 9: F5 sonrası görev
yaşadı) — bu ADR'nin çözdüğü şey **kalıcılığın yokluğu değil**, kalıcılığın **en sağlam** (OPFS)
yoluna Chrome'da erişilememesidir.

W2 bu durumu **görünür kıldı** (şerit + log kanıtı) ama **onarmadı** — kapsam dışıydı (spec §2).

---

## 2. Açık soru

**Sunucu COOP/COEP başlıklarını nasıl ve ne bedelle ekler, ve bu değişiklik projenin geri kalanını
(SignalR, üçüncü-taraf iframe/asset yükü varsa, mobil istemcilerin build'i vb.) bozar mı?**

Alt sorular (bu ADR'nin gövdesi büyüdükçe buraya eklenir, henüz YANITLANMADI):

1. Başlıklar ASP.NET Core middleware katmanında mı eklenir, yoksa statik dosya sunucusunda
   (varsa ayrı bir web sunucusu/CDN) mı? `require-corp` **tüm** alt-kaynakların (varsa font/görsel/
   üçüncü-taraf script) CORP/CORS uyumlu olmasını zorunlu kılar — bu projenin bugünkü statik varlık
   seti (`sqlite3.wasm`, `drift_worker.js`, Flutter'ın kendi ürettiği JS/asset'leri) bu koşulu
   BUGÜN karşılıyor mu? [ÖLÇÜLMEDİ]
2. `Cross-Origin-Embedder-Policy: require-corp` SignalR'ın WebSocket/uzun-yoklama bağlantısını
   etkiler mi? [ÖLÇÜLMEDİ]
3. Bu başlıklar yalnız `Development` ortamında mı denenir, yoksa üretim dağıtımının bir parçası mı
   olur? W1'in CORS politikası da (`GOREV-W1-web-yuruyen-iskelet.md`, D-W1-2) yalnız
   `IsDevelopment()` altında etkindi — aynı kapsam sorusu burada da geçerli.
4. `opfsLocks` Chrome'da izolasyon sağlansa bile **hâlâ** `SharedArrayBuffer`/dedicated-worker-in-
   shared-worker desteğine bağlı (B-W1-2'de kaydedilen `missingFeatures` kümesi) — izolasyon TEK
   BAŞINA yeterli mi, yoksa ek bir tarayıcı/worker mimarisi değişikliği de mi gerekir? [ÖLÇÜLMEDİ]
5. Canlı tarayıcı ölçümü bu ortamda nasıl yapılır — `ORTAM.md`nin kaydettiği `flutter test
   --platform chrome` kısıtı bu ADR'nin doğrulama turunu nasıl etkiler?

---

## 3. Kapsam DIŞI (bu iskelette KESİNLEŞMEDİ, gelecekte eklenir)

- Somut middleware/kod tasarımı.
- Mutant/kapı listesi.
- Kabul kriterleri.
- Geri-dönüş (rollback) planı.

Bu ADR **kilitlenmeden** hiçbir build turu bu numarayı gerekçe göstermez (K127 disiplini: kilit
öncesi bağımsız denetim burada da geçerli olacaktır).
