# ③ GERÇEK CİHAZDA UÇTAN UCA SENKRON — YÜRÜYEN İSKELET (oturum 48, 2 Ağu 2026)

**Kapsam (Onur kilitledi):** *cihaz → sunucu* tek yön. Çift yön ve çevrimdışı/çakışma **bu turda
ölçülmedi**. **Koşan el:** Cowork (K26 — build Claude Code'undu, ölçüm denetleyenindir).

## Ortam — ÖLÇÜLDÜ (K80 üç adım, hepsi yoklanarak)
`momentum-postgres` **Up (healthy)**, 3 yoklama · backend **0.0.0.0:5298 LISTENING**,
`/health/live` ve `/health/ready` **200 Healthy**, 5 yoklama (22 s), `ASPNETCORE_ENVIRONMENT=Development`
**açıkça** verildi (K61) · `emulator-5554`, `tuzak_api34`, **Android 14 / API 34**, `boot_completed=1`,
21,7 s. Ayrıntı: `00-ortam.txt`. Docker ve emülatör **detached** başlatıldı (köprü düşerse yetim kalmasınlar).

## KANITLANAN

1. **Cihazda oluşturulan görev PostgreSQL'e ulaştı — iki bağımsız vaka.**
   `GET /v1/tasks` ⇒ `O48-SENKRON-K` (`019fc1a9-1095-74f9-b10c-aa7d61052056`) ve
   `IKINCI` (`019fc1ad-90f5-7d94-a19e-7d03af99e92d`). Kanıt: `16-api-v1-tasks-SONUC.json`.
2. **`entityId` ikisinde de UUIDv7** (`…-7xxx-…` sürüm alanı) ⇒ ADR 0001 **K-E1** canlı doğrulandı.
3. **Rozet kuyruktan türetiliyor — canlı görüldü.** Yeni görev *"Bu cihazda"* etiketiyle geliyor
   (`11-ekran-02`), senkrondan sonra etiket **düşüyor** (`12-ekran-03`). İki ekran görüntüsü aynı
   görevi rozetli ve rozetsiz gösteriyor.
4. **K61 dev-kimlik kalkanı canlı ölçüldü:** başlıksız **401** · bozuk başlık (`abc`) **401** ·
   geçerli GUID **200**. Bugüne kadar yalnız birim testinde ısırmıştı.
5. **SignalR sinyali ayakta:** `[sinyal] el sikisma basarili` → `[sinyal] Changed alindi`.
6. **A10 §8/4 uygulandı:** `adb shell pm clear com.momentum.client` kurulumdan **önce ve sonra**
   ⇒ senkron kanıtı **temiz tabandan** ölçüldü (`GET /v1/tasks` başlangıçta `{"items":[]}`).

## 🔴 BULGU — YEREL YAZMA İTMEYİ TETİKLEMİYOR

| deneme | sonuç |
|---|---|
| Görev ekle → **60 s** yoklama | API'de **yok** |
| *"Yenile"* düğmesine bas → **40 s** daha | API'de **hâlâ yok** |
| Uygulamayı yeniden başlat | **14,4 s** ve **23,5 s**'te geldi (iki vaka) |

**Kaynağı kodda ölçüldü, tahmin edilmedi:**
- `main.dart:55` — `turCalistir()` (**itme**) yalnızca **açılışta bir kez**.
- `main.dart:76` — `onYenile: dongu?.cekmeTuruCalistir` ⇒ *"Yenile"* yalnızca **çekme** koşar.
- `senkron_dongusu.dart:78` — çekme turu *"gövdeyi **DAİMA** `ops:[]` ile kurar"* ⇒ kuyruğu
  **hiç göndermez** (slice-3d `D0` gereği, bilinçli).
- `gorev_listesi_ekrani.dart:100` — `GorevEkleAlani(onEkle: widget.depo.ekle)` ⇒ ekleme
  **doğrudan depoya** yazar, senkron döngüsüne dokunmaz.

`GOREV-slice-3d-cekme.md:218` *"Tetikleyiciler — KAPALI LİSTE (dört tanedir, beşincisi yoktur)"*
diyor; o liste **çekme** tetikleyicilerinindir. **İtme için yerel-yazma tetikleyicisi hiç
tasarlanmamıştır** ⇒ bu bir regresyon değil, **kapsam boşluğudur** ve vitrinin kalbindedir:
kullanıcı görev ekler, *"Bu cihazda"* rozetini görür ve uygulamayı yeniden başlatana kadar öyle kalır.

🔴 **481 istemci testi, 120 backend testi ve üç kapı ailesi bunu GÖRMEDİ; koşan uygulama beş
dakikada gösterdi.** K53/5'in (*"yürüyen iskelet önce"*) bu depodaki en net kanıtı.

## Beyan edilmiş sınırlar (ölçüm aracının kusurları dâhil)

- 🔴 **`adb shell input text` uzun metni KESTİ:** `O48-SENKRON-KANITI-A` → **`O48-SENKRON-K`**.
  Ürün kusuru **değil**, ölçüm aracının kusuru; ikinci vakada kısa metin (`IKINCI`) tam gitti.
- 🔴 **Backend logu 0 satır.** `dotnet run` detached başlatıldı, stdout dosyaya yönlendirildi ama
  dosya boş kaldı ⇒ *"istek geldi mi / 401 mi"* teşhisi **backend logundan yapılamadı**; teşhis API
  yanıtı + logcat + kod okumasıyla yapıldı. Borç.
- **Çift yön (sunucu → cihaz) ve çevrimdışı/çakışma bu turda ÖLÇÜLMEDİ.**
- **Gerçek fiziksel cihaz ölçülmedi** — yalnız emülatör; `10.0.2.2` host takma adı emülatöre özgüdür.
- `--profile` varyantı ölçülmedi (A10 §8/3 zaten kapsam dışı bırakmıştı).
- UI etkileşimi **sabit koordinatlıdır** (`463,2153` / `970,2153` / `1014,213`); widget yerleşimi
  değişirse betik sessizce ıskalar. Bu turda her adım `uiautomator dump` ile **doğrulandı**
  (ıskalama olsaydı *"IKINCI cihazda VAR MI"* ayağı hükmü geçersiz ilan edecekti — o ayak koştu ve **True** döndü).
