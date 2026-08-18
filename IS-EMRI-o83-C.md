# İŞ EMRİ o83-C — DISPATCHER'I AYIRT ET, c AYAĞINI ONAR

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, 18 Ağu 2026] — o83-B bağımsız denetimi: 3 bulgu kapandı, 3 açık kaldı.

---

## 0. DEMİR KURAL

🔴 **ADR YOK · SPEC YOK · kâğıt denetim turu YOK.** Punch list.
`IS-EMRI-o83-kimlik.md` §5 DOKUNMA LİSTESİ aynen yürürlükte.

🔴 **BU İŞ EMRİ ÖNCE ÖLÇER, SONRA DÜZELTİR.** §1 bitmeden §2'ye geçilmez; §1'in sonucu
hangi yolun açılacağını belirler. Ölçmeden düzeltme YASAK.

---

## 1. DISPATCHER — AYIRT EDİCİ ÖLÇÜM (önce bu, tek başına)

`DispatcherTests.Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner`
o83-B'den sonra **2/2 koşumda** düştü. Hata `53300` **değil**, Shouldly iddiası:
`seen[0]` `"v0"` içermiyor. Ayrıca `seen.Count.ShouldBe(25)` **geçti** ⇒ satır kaybı yok,
**SIRA** bozuk.

"Flake" **denmeyecek** — flake bazen geçer, bu tutarlı düşüyor.

### Üç hipotez

- **H1 — gerçek ürün kusuru.** Bağlantı açlığı önceden iki dispatcher'ı fiilen sıraya
  sokuyordu; havuz temizlenince yarış **ilk kez gerçekten koşuyor**.
- **H2 — havuz kelepçesi sebep.** `MaxPoolSize=4`, `d1` + `d2` + puller'ı boğuyor.
- **H3 — testin iddiası fazla katı.** Eşzamanlı dispatch altında çekme sırasının **ekleme
  sırasına** eşit olacağı hiçbir yerde sözleşme değilse, kusur üründe değil **testtedir**.

### Ölçüm — 3 kol × 5 koşum, YALNIZ bu test

`dotnet test tests/Momentum.Persistence.Tests --filter "FullyQualifiedName~Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner"`

| kol | `TestSupport.cs` durumu | koşum |
|---|---|---|
| A | kelepçe **YOK** (üç satır geçici çıkarılır) | 5 |
| B | kelepçe **var**, `MaxPoolSize = 4` (bugünkü) | 5 |
| C | kelepçe var, `MaxPoolSize = 50` | 5 |

Her kol için **geçen/düşen sayısı** yazılır. Kol A ve C sonunda dosya **bugünkü haline
(MaxPoolSize=4) geri döndürülür** ve `git diff --stat -- tests/Momentum.Persistence.Tests/TestSupport.cs`
**boş** olduğu gösterilir.

Ham çıktı → `KANIT/o83C/01-dispatcher-uc-kol.txt`

### H3 için sözleşme kontrolü (ölçüm, tahmin değil)

`OutboxDispatcher` / `SyncPuller` / `PullIncrementalAsync` kodunda ve mevcut testlerde
**"çekme sırası = ekleme sırası"** diye bir sözleşme var mı? Cursor `xid`/`seq` üzerinden
sıralıyorsa ve iki dispatcher `available_at`/`seq`i eşzamanlı yazıyorsa, ekleme sırası
**korunmayabilir** — bu durumda testin iddiası üründen fazlasını istiyordur.
Bulduğunu dosya:satır ile yaz. **Kod değiştirme.**

### 🔴 SONUÇ VE DUR

- A/B/C **hepsi 5/5 düşerse** → **H1 veya H3**. Sözleşme kontrolünün sonucunu yaz ve **DUR**.
  Ürün kodu değiştirme, testi de değiştirme — karar Onur'da.
- **B düşüp C geçerse** → **H2**. Kelepçe suçlu. `MaxPoolSize`ı C'de geçen en küçük değere
  ayarla, gerekçeyi tek satır yorum olarak yaz, §2'ye devam et.
- **Karışık (bazı koşumlar geçiyor)** → gerçekten flake. Geçme oranını yaz ve **DUR**.

---

## 2. c AYAĞI — POZİTİF KONTROL  (§1 H2 çıkarsa ya da Onur açarsa)

`08-canli-tur.txt` → `c) GET /v1/tasks (Bearer A)` = `{"items":[],...}` **BOŞ**.
A adım (a)'da `Applied` aldı ve `/v1/sync` snapshot'ında görevi **görünüyor**; `/v1/tasks` boş.
Betiğin tek kontrolü `b_entity_id in gov` — **boş liste bunu bedava geçirir.**
v1'de A kendi görevini görüyordu; **regresyon**.

`_canli_tur.py`:

1. `entity_id` ve `b_entity_id` **koşum-başına taze** olacak (e-posta gibi), sabit
   `1111…`/`4444…`/`7777…` **kullanılmayacak** — kalıcı Postgres cildinde önceki koşumun
   sahipliğiyle çakışıyor olabilir.
2. c ayağına **pozitif kontrol** eklenecek:
   `a_kendi_gorur = entity_id in gov` → **True olmalı**
   `a_gorur_b_yi = b_entity_id in gov` → **False olmalı**
   İkisi birden sağlanmazsa ayak **DÜŞER** (`SystemExit`), sessizce geçmez.
   Aynı kontrol b ayağına da: `b_kendi_gorur` True (B kendi görevini ekledikten sonra).
3. Taze entity id'lerle **hâlâ** A kendi görevini görmüyorsa: bu `/v1/sync` snapshot ile
   `/v1/tasks` okuma modeli arasında **gerçek bir tutarsızlıktır**. **DUR ve bildir.**
   Ürün kodunu kendi başına değiştirme.

Ham çıktı → `KANIT/o83C/02-canli-tur.txt`

---

## 3. SÜPÜRME

`KANIT/o83/_gecici_kanit/`, `KANIT/o83/_verify_stdout.txt`, `KANIT/o83/_verify_stderr.txt`
kaldırılır (içerikleri `09-verify-ps1.txt`de zaten var).

---

## 4. KABUL ÖLÇÜTÜ

- [ ] §1 üç kol × 5 koşum ham çıktısı `KANIT/o83C/01-dispatcher-uc-kol.txt`de, sayılarla
- [ ] `TestSupport.cs` ölçüm sonrası bilinen haline döndü (`git diff --stat` boş ya da yalnız
      H2 ayarı)
- [ ] H3 sözleşme kontrolü dosya:satır ile cevaplandı
- [ ] §1'in "DUR" şıkkı geldiyse: **durdu**, ürün/test kodu değişmedi
- [ ] §2 koşulduysa: `a_kendi_gorur` **True** ve `a_gorur_b_yi` **False** ham çıktıda görünüyor
- [ ] §3 süpürüldü

🔴 **`verify.ps1` EXIT 0 bu iş emrinin kabul ölçütü DEĞİLDİR.** o83-B'de EXIT 0 şartı ile
"Dispatcher düzeltilmez" muafiyeti çelişiyordu — çelişkiyi Cowork yazdı. Çözüm §1'in
sonucuna bağlı ve **Onur kilidini bekliyor**.

## 5. DOKUNMA LİSTESİ

v1 §5 aynen **+**:

- ❌ **ÜRÜN KODU** — `src/backend`, `src/client/lib` DEĞİŞMEZ. Değişmesi gerektiğini ölçersen DUR.
- ❌ `DispatcherTests.cs` — testin iddiasını gevşetme; H3 doğru olsa bile karar Onur'da.
- ❌ `max_connections` / Testcontainers komut satırı
- ❌ `TestSupport.cs` dışında test dosyası düzenleme
- ❌ Push — push Onur'da.
