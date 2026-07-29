# GOREV — slice-3e YÜRÜYEN İSKELET (gerçek zamanlı sinyal, istemci ayağı)

> **Bu bir SPEC DEĞİLDİR.** K53/5 gereği yazılmış bir **yürüyen iskelet** talimatıdır: amaç, en küçük
> çalışan şeyi cihazda kanıtlamak. **Kapılar (`G12`), mutantlar, tam GOREV spec'i ve kabul kriterleri
> BU BELGENİN KAPSAMI DIŞINDADIR** ve iskelet ölçüldükten **sonra** yazılacaktır.
> Tasarım kilidi: **K77** (Onur, 29 Tem 2026). Kilitli dört karar §1'dedir.

---

## 0. NEDEN BU DİLİM KÜÇÜK — ölçülmüş zemin

Backend ayağı **zaten bitmiştir** (slice-2b2). Cowork bunu oturum 37'de diskten **ve canlı sunucudan**
doğruladı, builder'ın ya da devir notunun beyanına güvenmedi:

| ölçüm | sonuç |
|---|---|
| `src/backend/Momentum.Api/Realtime/SyncHub.cs` | var (1.530 b) — gruplar `user:{userId}` + `scope:{scope}`, üyelik **her connect'te** porttan yeniden hesaplanıyor |
| `SignalRSignalPublisher.cs` | var (1.279 b) — tek istemci çağrısı `Changed(SignalEnvelope)`, grup başına bağımsız gönderim |
| `Program.cs` | `AddSignalR()` + `MapHub<SyncHub>("/hubs/sync")` + **negotiate ÖNCESİ** yol-tabanlı 401 middleware'i |
| `POST /hubs/sync/negotiate?negotiateVersion=1` **başlıksız** | **401** (canlı ölçüldü) |
| aynı uç, `X-Momentum-Dev-User` ile | **200** — `connectionToken` döndü, `availableTransports`: WebSockets · ServerSentEvents · LongPolling |
| `SignalEnvelope` | `(string Group, WireCursor CursorHint)` — **yükü boş**; entity içeriği, alan adı, aggregateId **taşımaz** |
| `SenkronDongusu.cekmeTuruCalistir()` | var — tek-uçuş kilidi + `K3 _cekmeBekliyor` bayrağı **zaten** coalescing yapıyor |

**Sonuç: slice-3e istemci işidir. Backend'e TEK BAYT yazılmayacaktır.**

---

## 1. KİLİTLİ KARARLAR (K77) — pazarlığa kapalı

**K77/1 — TAŞIMA: kendi minimal SignalR-JSON istemcimiz.** `web_socket_channel ^3.0.3` (BSD-3-Clause,
pub.dev `/advisories` **0 kayıt**, ölçüldü) üstüne yazılır. `signalr_netcore` **kullanılmaz**; gerekçe
altı geçişli bağımlılığın (`sse_channel 0.1.1`, `message_pack_dart` dâhil) kırmızı çizgi 3 maliyeti ve
kütüphanenin kendi yeniden-bağlanma politikasının **bizim ölçtüğümüz şey olmaktan çıkması**. Sinyal
yükü boş olduğu için MessagePack, SSE, stream ve istemci→sunucu invoke **hiç gerekmiyor**.

**K77/2 — YENİDEN BAĞLANMA: üstel geri çekilme + her başarılı (yeniden) bağlanmada BİR çekme turu.**
`1s → 2s → 4s → 8s → 16s → 30s` tavan, ±%20 jitter. 🔴 **Bu YOKLAMA DEĞİLDİR ve belgede böyle
yazılacaktır:** zamanlayıcı **veri çekmez**, yalnız **bağlanmayı** dener; veri çekmenin tetikleyicisi
`Changed` olayı ya da *"bağlantı kuruldu"* olayıdır. K68'in yasakladığı şey `Timer.periodic` ile
`/v1/sync` dövmektir; burada olan o değildir.

**K77/3 — KAPSAM: Android (emülatör) + Windows. Web ayağı `[DOĞRULANMADI]` diye BEYAN EDİLİR.**
Gerekçe ölçüldü: `/hubs/sync` middleware'i **her** istekte `X-Momentum-Dev-User` başlığı istiyor —
negotiate'te **ve** WebSocket upgrade'inde. Tarayıcı WS upgrade'ine özel başlık koyamaz; web'i açmak
backend'e `access_token` query kanalı eklemek, yani slice-2b2 `D4` deny-by-default middleware'ine ve
K61 kalkanına **dokunmak** demektir. Bu dilimde yapılmaz.

**K77/4 — SIRALAMA: iskelet önce, kapılar sonra.** Bu belge bittiğinde `G12` **yoktur** ve bu bir
eksiklik değil, **kilitli karardır**.

**K77/5 — SİNYAL→ÇEKME EŞLEMESİ DOĞRUDAN.** Her `Changed` → `cekmeTuruCalistir()`. **Ek debounce,
ek zamanlayıcı, ek kuyruk YOK.** Gerekçe koddan ölçüldü: elli sinyallik bir patlama, mevcut tek-uçuş
kilidi (`_devamEdenTur`) + K3 bayrağı (`_cekmeBekliyor`) sayesinde **en fazla bir ek tura** çöker.

**K77/6 — `CursorHint` YOKSAYILIR.** Gerekçe `D6` kilidi: `WireCursor.Xid` `ulong`dur, Dart `int` web'de
53-bit güvenlidir, **sayıya çevirmek yasaktır**. Hint'i karşılaştırmak metin/BigInt karşılaştırması
demektir ⇒ yeni kusur sınıfı. Sözleşmenin kendi docstring'i de *"hint, gerçek imlecin yerini tutmaz"*
diyor. Sinyal **yalnız bir uyandırma zilidir**.

---

## 2. YAPILACAKLAR

### T1 — Port: `src/client/lib/ag/gercek_zamanli_sinyal.dart`

`SenkronAgi` ile **aynı desende** bir port. Üretim uygulaması bunun arkasında durur; testler
deterministik bir sahte enjekte eder. Taşıma tipi (WebSocket, SignalR, hiçbiri) bu dosyada **geçmez**.

```dart
sealed class SinyalOlayi { const SinyalOlayi(); }

/// Sunucu `Changed` yayınladı — YÜKSÜZ. İçerik taşımaz, taşımamalıdır.
class SinyalDegisiklik extends SinyalOlayi { const SinyalDegisiklik(); }

/// (Yeniden) bağlantı kuruldu — K77/2: kopukken kaçan sinyaller için BİR çekme turu tetikler.
class SinyalBaglandi extends SinyalOlayi { const SinyalBaglandi(); }

abstract class GercekZamanliSinyal {
  Stream<SinyalOlayi> get olaylar;
  Future<void> baslat();
  Future<void> durdur();
}
```

### T2 — Uygulama: `src/client/lib/ag/signalr_json_sinyal.dart`

SignalR **JSON hub protokolünün** yalnız gereken alt kümesi. Kayıt ayracı `` (0x1E).

1. **negotiate** — `POST {taban}/hubs/sync/negotiate?negotiateVersion=1`, başlık
   `X-Momentum-Dev-User: {actorId}`. 401 ⇒ bağlanma **başarısız** (sessiz yeniden deneme değil,
   geri çekilmeye düş). 200 ⇒ gövdeden `connectionToken` alınır.
2. **WebSocket** — `ws(s)://{taban}/hubs/sync?id={connectionToken}`, **aynı başlıkla**
   (`IOWebSocketChannel.connect(..., headers: {...})`). `http`→`ws`, `https`→`wss`.
3. **El sıkışma** — `{"protocol":"json","version":1}` + `` gönderilir; ilk yanıt beklenir.
   Yanıt `{}` ⇒ başarılı. `"error"` alanı varsa ⇒ başarısız, geri çekilmeye düş.
4. **El sıkışma başarılı olur olmaz** `SinyalBaglandi` yayınlanır.
5. **Mesaj döngüsü** — gelen çerçeve `` ile bölünür, her parça JSON çözülür:
   `type == 1 && target == "Changed"` ⇒ `SinyalDegisiklik` yayınla ·
   `type == 6` (ping) ⇒ **yut** · `type == 7` (close) ⇒ kapat, geri çekilmeye düş ·
   **tanınmayan tip ⇒ YUTULUR ama SESSİZ DEĞİL** (ileride kapı ayağı olacak; şimdilik log).
   🔴 `arguments` içeriği **okunmaz** (K77/6).
6. **Keepalive** — her 15 sn `{"type":6}` gönderilir. 🔴 **Bu bir protokol keepalive'ıdır,
   yoklama değildir**; `/v1/sync`'e dokunmaz. Belgede böyle beyan edilir.
7. **Geri çekilme** — K77/2 çizelgesi. `durdur()` çağrıldıysa yeniden bağlanma **denenmez**.

### T3 — Bağlama: `src/client/lib/main.dart`

`_uretimKurulumOlustur()` içinde kurulur; `DURUM_VITRINI` dalında **kurulmaz** (F5 gerekçesi aynen
korunur). Abonelik tek satırdır ve iki olay **aynı** çağrıya gider:

```dart
sinyal.olaylar.listen((_) => unawaited(dongu.cekmeTuruCalistir()));
unawaited(sinyal.baslat());
```

Sunucu tabanı `_senkronSunucuUrl` sabitinden **yeniden türetilir**, ikinci bir `String.fromEnvironment`
**eklenmez** (kanonik-kopya sınıfı bu projede beş kez ısırdı).

### T4 — Bağımlılık

`pubspec.yaml` → `web_socket_channel: ^3.0.3`. Kırmızı çizgi 3 gereği `araclar\pub-cve-kapisi.py` **ve**
`araclar\pub-lisans-kapisi.py` koşulur; çıktı `KANIT/slice-3e-iskelet/` altına yazılır.
Cowork'ün ön ölçümü (teyit edilecek, körü körüne kabul edilmeyecek): **BSD-3-Clause, 0 advisory**.

### T5 — Cihaz kanıtı (iskeleti "yürüyen" yapan şey)

**İki taraflı, yoklamasız yayılım.** İkinci istemci bir **betiktir**, ikinci bir emülatör değil:

1. Emülatörde uygulama açık ve **öndeyken** ekran görüntüsü alınır (`00-once.png`).
2. Ayrı bir süreçten `POST /v1/sync` ile **aynı kullanıcı adına** yeni bir görev itilir
   (`X-Momentum-Dev-User` aynı GUID). Bu, "başka bir cihazdaki ben" demektir.
3. **Uygulamaya DOKUNULMADAN**, ekran güncellenene kadar **yoklanarak** beklenir (sabit `sleep`
   **YASAK** — oturum 35 dersi), tavan 30 sn.
4. `01-sonra.png` alınır; yeni görev **elle yenileme olmadan** listede görünmelidir.
5. WS trafiği ve zaman damgaları `_ws-trafik.txt` olarak yazılır (el sıkışma → `Changed` → çekme turu).

**Ayrıca:** uçak modu açılıp kapatılır; `SinyalBaglandi` sonrası **bir** çekme turunun koştuğu logda
görülür (`02-yeniden-baglanma.txt`).

---

## 3. KAPSAM DIŞI (bilerek, gizlenmeden)

`G12` kapısı ve mutantları · tam GOREV spec'i ve kabul kriterleri · **backend'de hiçbir değişiklik** ·
web ayağı (K77/3) · `DESIGN.md`'ye dokunmak (K46 yalnız iki madde için açık; bağlantı-durumu rozeti
**ÜÇÜNCÜ** bir açılış olurdu ve ayrı kilit ister) · `CursorHint` kullanımı (K77/6) · gerçek kimlik
(ADR 0003 donmuş, K41).

---

## 4. BİTİŞ ÖLÇÜTÜ

`flutter analyze --fatal-infos` **0 bulgu** · `flutter test` **mevcut sayı ≥ 156, düşmeden** ·
`pub-cve-kapisi` + `pub-lisans-kapisi` **EXIT 0** · T5'in iki PNG'si + trafik logu `KANIT/slice-3e-iskelet/`
altında · **ve builder'ın bu sayıların hiçbirine güvenilmeden Cowork tarafından yeniden koşulması (K26).**

🔴 **Builder'ın beyanı kanıt değildir.** Her sayı Cowork'ün kendi koşumuyla ölçülecek, PNG'ler
**gözle** denetlenecektir.
