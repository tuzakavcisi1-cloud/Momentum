# `W3` — denetim raporunun `F/4` ve `F/5` maddeleri ÖLÇÜLDÜ (oturum 62)

**6 Ağu 2026, oturum 62. Koşan el:** Cowork.
🔴 **NEREDE KOŞTU:** Cowork'ün **bulut konteyneri** (Linux, .NET SDK **10.0.302**, headless
**Chromium**/Playwright). **Onur'un Windows makinesinde DEĞİL.**

`KANIT/W3/03-DENETIM-v2-o60.md` §F, *"NE ÖLÇÜLEMEDİ"* listesinde iki maddeyi **kilitten önce
ölçülmeli** diye işaretlemişti. İkisi de burada ölçüldü — **koşan ürün kodu üzerinde**, kâğıtta değil.

---

## `F/4` — `/scalar/v1` `require-corp` altında 🟢 **ÇALIŞIYOR**

**Denetimin endişesi:** *"Scalar.AspNetCore 2.16.15 içinde `.js`/`.html` varlığı yok, DLL'de
`jsdelivr`/`unpkg`/`cdn.` dizgeleri bulunamadı ⇒ UI varlıklarının nereden geldiği ÖLÇÜLEMEDİ.
Çapraz-köken bir `<script src>` (`no-cors`) kullanıyorsa **COEP onu bloklar**."*

**Ölçüm — `curl`:** sayfa iki betik atıfı taşıyor, **ikisi de göreli**:
`src="scalar.aspnetcore.js"` · `src="scalar.js"` ⇒ aynı kökene çözülüyor.

| adres | HTTP | tür | bayt |
|---|---|---|---|
| `/scalar/scalar.js` | **200** | `text/javascript` | **3.728.126** |
| `/scalar/scalar.aspnetcore.js` | **200** | `text/javascript` | **2.632** |

**Ölçüm — headless Chromium (`networkidle`):**

```json
{"crossOriginIsolated": true, "title": "Scalar API Reference",
 "body_dugum_sayisi": 195,
 "yanitlar": [[200,"/scalar/v1"],[200,"/scalar/scalar.aspnetcore.js"],
              [200,"/scalar/scalar.js"],[200,"/openapi/v1.json"]],
 "basarisiz_istekler": [], "konsol": ["info: @scalar/api-reference@1.62.9"]}
```

Gövde metni: *"… DiagnosticsEndpoints … `/v{version}/ping` … SyncEndpoints …"* ⇒ **UI fiilen
çizildi**, iskelet HTML değil.

🟢 **HÜKÜM: `F/4` KAPANDI.** Sıfır başarısız istek, sıfır COEP hatası, dört yanıtın dördü de
**aynı kökenden**. Scalar varlıklarını **DLL'e gömüyor**; CDN yok ⇒ `require-corp` onu etkilemiyor.
🔴 **Beyan edilmiş sınır:** ölçüm `@scalar/api-reference@1.62.9` sürümü içindir; Scalar bir üst
sürümde CDN'e dönerse bu hüküm **bayatlar** — `izolasyon-olc.py` bunu **ölçmez**, `/scalar/v1`'i
kapsam alan bir ayak **yok** (borç).

---

## `F/5` — `/hubs/sync` izolasyon altında: 🟡 negotiate **ÇALIŞIYOR**, WebSocket **DÜŞÜYOR**

**Kurgu (gerçekçi):** probe sayfası **ayrı bir kökende** (`http://127.0.0.1:5111`) ve **kendi**
COOP/COEP başlıklarıyla servis edildi ⇒ belge **izole**. Oradan API'ye (`:5298`) çapraz-köken
`negotiate` (fetch, `cors`) ve `WebSocket` denendi. API'nin CORS allowlist'ine probe kökeni
eklendi (`Cors__AllowedOrigins__0`); **preflight pozitif kontrolü** ölçüldü:

```
HTTP/1.1 204 No Content
Access-Control-Allow-Origin: http://127.0.0.1:5111
Access-Control-Allow-Headers: Content-Type,X-Momentum-Dev-User
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

**Ölçülen:**

| ayak | sonuç |
|---|---|
| `self.crossOriginIsolated` (probe belgesi) | **true** |
| `POST /hubs/sync/negotiate` (fetch, `X-Momentum-Dev-User` ile) | **200** · `connectionToken` geldi · transports `WebSockets, ServerSentEvents, LongPolling` |
| `POST /hubs/sync/negotiate` **başlıksız** (curl) | **401** ⇒ `K61` kalkanı izolasyon altında **ayakta** |
| `new WebSocket(ws://…/hubs/sync?id=<token>)` | 🔴 **BAŞARISIZ** |
| `new WebSocket(ws://…/hubs/sync)` | 🔴 **BAŞARISIZ** |
| başarısız **istek** sayısı (ağ katmanı) | **0** |

Konsol, iki WebSocket için de birebir:

> `WebSocket connection to 'ws://127.0.0.1:5298/hubs/sync?id=…' failed: HTTP Authentication failed; no valid credentials available`

### 🔴 POZİTİF KONTROL — sebep COOP/COEP DEĞİL

Aynı ölçüm, API **izolasyon başlıkları KAPALI** iken (`Izolasyon__Etkin=false`, yanıtta
`cross-origin` başlığı **0 adet**) tekrarlandı:

| | izolasyon AÇIK | izolasyon KAPALI |
|---|---|---|
| negotiate | **200** | **200** |
| WebSocket (tokenlı) | başarısız | **başarısız** |
| WebSocket (tokensız) | başarısız | **başarısız** |
| konsol hatası | *HTTP Authentication failed* | ***HTTP Authentication failed*** |

⇒ **Yeni ara katman SignalR'ı BOZMUYOR.** `negotiate` (`cors` modu) COEP'ten **etkilenmiyor** —
denetimin `O3`'te doğruladığı MDN kuralının fiilen ölçülmüş hâli.

### Gerçek sebep — ve bu bir ÜRÜN sınırıdır

`K61` dev-kimlik kalkanı `X-Momentum-Dev-User` **başlığını** istiyor (`Program.cs`'teki yol-tabanlı
ara katman, `/hubs/sync` için `ICurrentUser.UserId is null` ⇒ **401**). Tarayıcının `WebSocket`
yapıcısı **özel başlık ekleyemez** ⇒ web istemcisi `negotiate`'i geçse bile **WebSocket
transportunu açamaz**.

🔴 **Bu, izolasyondan BAĞIMSIZ, önceden var olan bir sınırdır** ve bugüne kadar görünmemesinin
sebebi ölçülmüştü: SignalR **web'de `kIsWeb` ile KAPALI**, mobilde ise Dart istemcisi başlık
**ekleyebiliyor**. `W3` istemciyi web'de izole edip gerçek zamanlı işbirliğini web'e açtığı anda
bu sınır **bloker olur**.

🟡 **HÜKÜM: `F/5` ÖLÇÜLDÜ.** Denetimin sorduğu *"COEP SignalR'ı etkiler mi"* sorusunun cevabı
**HAYIR** (pozitif kontrolle kanıtlı). Ama ölçüm **yeni bir sınır** buldu: web istemcisi için
`K61` kalkanı **başlık yerine sorgu dizesi/çerez** gibi bir yol gerektirir — bu bir **karar**dır,
Onur'a aittir, bu oturumda **alınmadı**.

---

## EK — `require-corp` FİİLEN İŞ YAPIYOR MU? 🟢 **EVET, ÖLÇÜLDÜ**

`00-ISKELET-OLCUMU-o62.md` §6/5 açık bırakmıştı: *"ölçülen yalnızca belgenin izole olduğudur;
CORP göndermeyen bir alt kaynağın **bloklandığı** ölçülmedi."* Kapatıldı.

**Kurgu:** belge `:5111`'de (COOP + COEP ⇒ **izole**), alt kaynak **ayrı kökende** `:5112`'de,
`<img>` ile (`no-cors` modu — COEP'in klasik hedefi). Üç varyant:

| alt kaynağın `Cross-Origin-Resource-Policy`'si | sonuç | tarayıcı hatası |
|---|---|---|
| **yok** | 🔴 **BLOKLANDI** | `ERR_BLOCKED_BY_RESPONSE.NotSameOriginAfterDefaultedToSameOriginByCoep` |
| `same-origin` | 🔴 **BLOKLANDI** | `ERR_BLOCKED_BY_RESPONSE.NotSameOrigin` |
| `cross-origin` | 🟢 **YÜKLENDİ** | — |

🟢 **HÜKÜM: `require-corp` dekoratif değil.** Ara katman gerçek bir kısıt uyguluyor.
🔴 **BEDELİ DE ÖLÇÜLDÜ:** izole bir belgede **çapraz-köken her alt kaynak `CORP: cross-origin`
göndermek ZORUNDA**. Bu, `G45/d`'nin (`www.gstatic.com/flutter-canvaskit`) neden kritik olduğunun
mekanik kanıtıdır — denetim `O3`'te gstatic'in `CORP: cross-origin` **gönderdiğini** ölçmüştü,
yani o kaynak **geçer**; ama bu tabloya göre **göndermeyen her kaynak sessizce ölür**.

Koşucu: `KANIT/W3/_corp_olc.py` — `EXIT 0` = üç varyantın üçü de beklendiği gibi.

---

## NE ÖLÇÜLEMEDİ (boş olamaz)

1. **SignalR'ın kendi JS istemcisi** koşturulmadı; ölçüm ham `fetch` + ham `WebSocket` ile yapıldı.
   `ServerSentEvents`/`LongPolling` transportlarının izole belgeden davranışı **ÖLÇÜLMEDİ** —
   ikisi de `K61` başlığını taşıyabilir (fetch tabanlı) ve **çalışabilir**; bu bir **tahmin**dir,
   ölçüm değil.
2. **Onur'un makinesinde hiçbiri.** `verify.ps1` ve backend testleri bu oturumda **koşulmadı**.
3. **Gerçek Flutter web istemcisi** — `drift`in OPFS geçişi hâlâ hiç egzersiz edilmedi.
4. **HTTPS/WSS altında** hiçbir ölçüm yok; hepsi düz `http`/`ws`.
5. **`/scalar/v1`'in bir üst Scalar sürümünde** CDN'e dönüp dönmediği; kapsam alan kapı **yok**.
6. **`fetch`/`script`/`worker` için CORP davranışı** — ek ölçüm yalnız `<img>` (`no-cors`) ile
   yapıldı; diğer alt kaynak türleri **ölçülmedi**. Aynı davranışı beklemek bir **tahmindir**.
7. **Gerçek `flutter build web` çıktısı** izole bir belgede hiç yüklenmedi ⇒ `G45/d`'nin
   `flutter.js` bulgusu **ürün üzerinde** hâlâ doğrulanmadı.
