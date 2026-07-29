# GOREV — slice-3e `G12`: gerçek zamanlı sinyal kapısı + yoklama yasağı kapısı

> **Bu bir SPEC'tir ve KİLİTLİDİR (K79, Onur, 29 Tem 2026).** İskelet talimatının (`GOREV-slice-3e-iskelet.md`)
> aksine burada kabul kriterleri, kapı ayakları ve mutant tablosu vardır. Değişen her bayt kilidi bozar.
> Önceki kilitler: **K77** (slice-3e tasarımı), **K78** (iskelet kabul + sekiz bulgu).

---

## 0. NEDEN BU DİLİM VAR — ölçülmüş gerekçe

`K78` ile iskelet kabul edildi ama Cowork'ün bağımsız doğrulaması **sekiz bulgu** üretti. Üçü doğrudan
`G12`'nin varlık sebebidir:

| ölçülen kusur | sonuç |
|---|---|
| `signalr_json_sinyal.dart` **10.861 b / 307 satır**, `flutter test` 156/156 — düşmedi ama **artmadı da** | protokol kodunun **tek** testi yok |
| `_websocketAc()` doğrudan `IOWebSocketChannel.connect(...)` çağırıyor, **private** ⇒ başka kütüphaneden override edilemez | sahte kanal enjekte edilemez ⇒ el sıkışma, mesaj döngüsü, ping, close, geri çekilme **ölçülemez** |
| sinyal örneği `_UretimKurulumu`'ya konmuyor | `durdur()` çağıracak sahip yok; `StreamController` hiç kapanmıyor |
| tarayıcıda `IOWebSocketChannel` çalışmaz + WS upgrade'ine `X-Momentum-Dev-User` konamaz | **sessiz sonsuz yeniden-bağlanma** (30 sn'de bir, sonsuza dek) |
| `K68` *"periyodik yoklama YASAK"* üç dilimdir **prozada** | mekanik kapısı **YOK** |
| `K77/6` *"`CursorHint` YOKSAYILIR"* bugün yalnız **yorumda** yaşıyor | bir mutant `arguments`'ı okumaya başlasa **hiçbir şey ısırmaz** |

---

## 1. KİLİTLİ KARARLAR (K79) — pazarlığa kapalı

**K79/1 — Kapsam: üç ürün-kodu düzeltmesi + İKİ kapı ailesi.** Önce T1–T3 (enjekte edilebilirlik,
`durdur()` sahipliği, web koruması), sonra T4 (`g12_sinyal_kapisi_test.dart`, birim) ve T5
(`araclar/yoklama-yasagi-kapisi.py`, statik). Biri olmadan öteki **kabul edilmez**.

**K79/2 — Web koruması `kIsWeb` ile KAPATMA.** Web'de `baslat()` **hiç bağlanmaz**, tek satır log
bırakır; elle yenileme (`onYenile`) tek yol olarak kalır. 🔴 Koşullu import + `access_token` query
**YAPILMAZ** — o, backend'de slice-2b2 `D4` middleware'ine ve K61 kalkanına dokunmak olurdu.

**K79/3 — `K68` yoklama yasağı MEKANİKLEŞİYOR.** T5'in `Y1` ayağı: üretim kodundaki **her**
`Timer(`/`Timer.periodic(` kullanımı beyaz listede olmak zorundadır. Bugün meşru tek iki kullanıcı:
keepalive ve geri çekilme — ikisi de `signalr_json_sinyal.dart`'ta. Liste dışı bir zamanlayıcı **ya da**
gövdesinde `cekmeTuruCalistir` / `turCalistir` / `SenkronAgi` geçen bir zamanlayıcı ⇒ **KIRMIZI**.

**K79/4 — Mutant bütçesi 16: `M58`–`M70` birim (13) + `M71`–`M73` statik (3).**
🔴 **KOLATERAL ISIRIK YASAK** (oturum 36'nın birinci dersi, `G11-A9`): bir mutantın *herhangi bir*
ayağı kırması YETMEZ — **hedeflediği ayağın KENDİSİNİN** kırıldığı ölçülmelidir. Her mutant için
ham çıktıda **o ayağın adı** görünmelidir. Koşan-uygulama mutantı **YOK**; K53/3 tavanı (3)
**harcanmaz**.

**K79/5 — Sahte kanal, gerçek protokol.** Birim testleri sahte bir `WebSocketChannel` ile koşar ama
**gerçek çerçeve baytlarını** (`0x1E` ayraçlı, gerçek SignalR JSON gövdeleri) besler. Sahte, protokolü
basitleştirmez; yalnız taşımayı değiştirir.

**K79/6 — `Random` deterministik olmalı.** Geri çekilme ayakları seed'li `Random(n)` ile koşar; jitter
"aralıkta mı" diye değil, **tam beklenen değere** karşı ölçülür. 🔴 K78'in *"6/6 aralıkta"* iddiası bir
**üst sınır** ölçümüydü; burada o zayıflık tekrar edilmez.

---

## 2. YAPILACAKLAR

### T1 — Kanal açıcıyı enjekte edilebilir yap (`signalr_json_sinyal.dart`)

Yapıcıya opsiyonel bir parametre eklenir; **üretimde varsayılan davranış DEĞİŞMEZ**:

```dart
typedef KanalAcici = WebSocketChannel Function(Uri url, Map<String, String> basliklar);

// yapıcıda:
KanalAcici? kanalAcici,          // test-görünür; üretimde null ⇒ IOWebSocketChannel.connect
```

`_websocketAc` bu alanı kullanır: `(_kanalAcici ?? _varsayilanKanalAc)(url, {basliklar})`.
🔴 Varsayılan yol `IOWebSocketChannel.connect` olarak **aynen kalır**; T1 bir davranış değişikliği
değil, **ölçülebilirlik** değişikliğidir.

### T2 — `durdur()` sahipliği (`main.dart`)

`_UretimKurulumu` üçüncü alan olarak `GercekZamanliSinyal sinyal` taşır. `durdur()` ayrıca
`_denetleyici.close()` çağırır (bugün hiç kapanmıyor) ve **idempotent** olur: ikinci çağrı patlamaz.

### T3 — Web koruması (`signalr_json_sinyal.dart`)

`import 'package:flutter/foundation.dart' show kIsWeb;` — `baslat()` ilk satırı:

```dart
if (kIsWeb) {
  gunlukYaz('web: gercek zamanli sinyal KAPALI (K79/2) -- elle yenileme tek yol');
  return;                 // _durduruldu true KALIR; hicbir baglanti denenmez
}
```

🔴 `_durduruldu` bayrağı `true` kalmalıdır ki sonraki `baslat()` çağrıları da sessizce dönsün ve
**hiçbir zamanlayıcı kurulmasın**.

### T4 — `src/client/test/g12_sinyal_kapisi_test.dart` (birim kapısı, 13 ayak)

| ayak | ne ölçer |
|---|---|
| `A1` | `{"type":1,"target":"Changed","arguments":[…]}` ⇒ **bir** `SinyalDegisiklik` yayınlanır |
| `A2` | `type:1` ama `target != "Changed"` ⇒ olay yayınlanmaz, `gunlukYaz` çağrılır |
| `A3` | `{"type":6}` (sunucu ping'i) ⇒ **hiçbir** olay yayınlanmaz |
| `A4` | `{"type":7,...}` (close) ⇒ olay yok; kanal kapatılır; yeniden bağlanma **planlanır** |
| `A5` | tanınmayan tip (`{"type":99}`) ⇒ olay yok **ama** `gunlukYaz` çağrılır (sessiz değil) |
| `A6` | tek çerçevede `0x1E` ile ayrılmış **üç** mesaj ⇒ üçü de işlenir, sıra korunur |
| `A7` | el sıkışma yanıtı `{}` ⇒ `SinyalBaglandi`; `{"error":"…"}` ⇒ olay YOK, bağlantı koptu sayılır |
| `A8` | 🔴 **el sıkışma yanıtı MESAJ olarak işlenmez** — `{}` içinde `type` yoktur; işlenseydi `A5` yolundan *"tanınmayan tip"* logu düşerdi. Ayak: el sıkışmadan sonra `gunlukYaz`'da *"taninmayan"* geçmemeli |
| `A9` | negotiate **401** ⇒ `SinyalBaglandi` yok, WS **hiç açılmaz** (sahte açıcı çağrılmadı) |
| `A10` | negotiate 200 ama `connectionToken` yok/boş ⇒ aynı sonuç |
| `A11` | başarılı bağlanmadan **sonra** kopuş ⇒ geri çekilme indeksi **sıfırlanmış** olmalı (ilk gecikme yine 1 sn tabanlı) |
| `A12` | `Random(42)` ile ardışık altı gecikme **tam beklenen** değerlere eşit (1-2-4-8-16-30 tabanı × seed'in ürettiği çarpan); yedinci de 30 sn tabanında **kalır** (tavan) |
| `A13` | `durdur()` sonrası: yeniden bağlanma **denenmez**, `olaylar` akışı **kapanır**, ikinci `durdur()` patlamaz |

🔴 `A9`/`A10` için sahte kanal açıcı **çağrıldı mı** diye ölçülür (bayrak), "olay gelmedi" **yetmez** —
olay gelmemesi başka sebeplerden de olabilir (ölü tuzak riski).

### T5 — `araclar/yoklama-yasagi-kapisi.py` (statik kapı, 4 ayak + altın küme)

Araç **önce kendini kanıtlar**: altın küme (temiz kaynakta susar, kirli fixture'da ısırır), en az **9 vaka**.

| ayak | ne ölçer |
|---|---|
| `Y1` | **YOKLAMA YASAĞI (K68).** `src/client/lib` altındaki her `Timer(`/`Timer.periodic(` beyaz listede olmalı. Beyaz liste: `signalr_json_sinyal.dart` → keepalive + geri çekilme. Liste dışı ⇒ KIRMIZI. Ayrıca **hangi** zamanlayıcı olursa olsun, gövdesinde `cekmeTuruCalistir`/`turCalistir`/`SenkronAgi` geçiyorsa ⇒ KIRMIZI |
| `Y2` | **`CursorHint` YASAĞI (K77/6).** `signalr_json_sinyal.dart`'ta `arguments` / `cursorHint` dizgeleri **yalnız yorum satırında** geçebilir; kod satırında geçerse KIRMIZI |
| `Y3` | **KEEPALIVE YOKLAMAYA DÖNÜŞEMEZ.** `signalr_json_sinyal.dart` içinde `/v1/sync` dizgesi **hiç** geçemez |
| `Y4` | **BAŞLIK İKİLİĞİ.** `X-Momentum-Dev-User` **hem** negotiate isteğinde **hem** WS açılışında gönderilmeli; biri düşerse KIRMIZI (düşmesi sessiz 401 üretir, K77/3'ün dayanağı) |

🔴 `Y2` için **yorum soyma** gerçekten yapılmalı; `design-token-kapisi.py`'nin `yorum_disi()`'si bu
projede zaten ölçülmüş bir referanstır (M2b beyanının tersi ölçüldü — yorumu **soymuyor**, yanlış-pozitif
yönünde). Yeni araç kendi yorum soyucusunu **altın kümede kanıtlamalıdır**.

---

## 3. MUTANT TABLOSU (`M58`–`M73`, 16 adet)

Her mutant: değişiklik uygulanır → **hedef ayağın** KIRMIZI olduğu ham çıktıyla kanıtlanır → geri alınır
→ YEŞİL yeniden ölçülür. Ham çıktı `KANIT/slice-3e-G12/09-MUTANT/M<nn>-{diff,kirmizi,yesil}.txt`.

| mutant | değişiklik | ısırması gereken ayak |
|---|---|---|
| `M58` | `target == 'Changed'` koşulunu `true` yap | `A2` |
| `M59` | `case 6:` dalını `SinyalDegisiklik` yayınlayacak şekilde değiştir | `A3` |
| `M60` | `case 7:` dalında `_baglantiKoptu` çağrısını sil | `A4` |
| `M61` | `default:` dalındaki `gunlukYaz` çağrısını sil | `A5` |
| `M62` | `_cerceveyiAyir` yalnız ilk parçayı döndürsün | `A6` |
| `M63` | `_elSikismaYanitiDogrula`'da `error` kontrolünü kaldır | `A7` |
| `M64` | el sıkışma dalındaki `continue`'yu kaldır (yanıt mesaj gibi işlensin) | `A8` |
| `M65` | `_negotiate`'te `statusCode != 200` kontrolünü kaldır | `A9` |
| `M66` | `connectionToken` boş/null kontrolünü kaldır | `A10` |
| `M67` | `_geriCekilmeIndeksi = 0` sıfırlamasını sil | `A11` |
| `M68` | jitter çarpanını `1.0` sabitle | `A12` |
| `M69` | `durdur()`'de `_durduruldu = true` atamasını sil | `A13` |
| `M70` | `durdur()`'e eklenen `_denetleyici.close()` çağrısını sil | `A13` |
| `M71` | `gorev_deposu.dart`'a `Timer.periodic(... cekmeTuruCalistir ...)` ekle | `Y1` |
| `M72` | `_tekMesajiIsle`'ye `mesaj['arguments']` okuyan bir satır ekle | `Y2` |
| `M73` | WS açılışındaki `headers:` argümanını kaldır | `Y4` |

🔴 **`Y3` mutantı YOKTUR ve bu BEYAN EDİLMİŞ BİR BORÇTUR.** `/v1/sync` dizgesini dosyaya eklemek
"gerçekçi bir kusur" değil, yapay bir enjeksiyondur; ayak yine de koşar ama **ısırdığı ölçülmemiştir**.
Gizlenmiyor, yazılıyor.

---

## 4. KABUL KRİTERLERİ

1. `flutter analyze --fatal-infos` → **0 bulgu**.
2. `flutter test` → **≥ 169** (156 + en az 13 yeni ayak), **düşen test yok**.
3. `araclar/yoklama-yasagi-kapisi.py --altin-kume` → **EXIT 0**, en az **9 vaka**, hepsi GEÇTİ.
4. `araclar/yoklama-yasagi-kapisi.py .` → **EXIT 0** (temiz depoda susar).
5. **16 mutantın 16'sı** için `diff` + `kirmizi` + `yesil` ham çıktısı `KANIT/slice-3e-G12/09-MUTANT/`
   altında; her `kirmizi` dosyasında **hedef ayağın adı** görünür (kolateral ısırık kabul edilmez).
6. `flutter build web --release` → **EXIT 0** (T3 web'i kırmamalı).
7. Cihazda **tek** doğrulama: `kIsWeb` koruması Android'i etkilemedi — uygulama hâlâ `Changed` alıp
   listeyi yoklamasız güncelliyor (`KANIT/slice-3e-G12/01-android-regresyon.png`).
8. `python araclar\spec-kapi-kapsama.py .` → **EXIT 0** (mutantsız kapı/kural kalmadı; `Y3` borcu
   **beyan edilmiş** olarak okunur).
9. `python araclar\iddia-kapisi.py KANIT/slice-3e-G12/00-HUKUM.md --kanit KANIT/slice-3e-G12` →
   **EXIT 0**. 🔴 Bilinen sınır: bu araç ikili dosyaları metin gibi tarıyor (§8 borcu, iki kez ısırdı)
   ⇒ **kanıt dizinine 100 KB'tan büyük ikili/metin dosya KONULMAZ**; büyük çıktılar **kesit + sha**
   olarak yazılır.
10. Cowork bunların **hiçbirine güvenmeden** hepsini yeniden koşar (K26) ve PNG'yi **gözle** denetler.

---

## 5. KAPSAM DIŞI (bilerek, gizlenmeden)

Backend'de **hiçbir değişiklik** · web'de gerçek WS (K79/2) · `access_token` query kanalı ·
`DESIGN.md`'ye dokunmak (K46 yalnız iki madde için açık) · `CursorHint` kullanımı (K77/6) ·
gerçek kimlik (ADR 0003 donmuş, K41) · koşan-uygulama mutantı (K53/3 tavanı harcanmaz) ·
`iddia-kapisi.py`'nin ikili-tarama onarımı (ayrı el, K34-f).

---

## 6. BEYAN EDİLMİŞ SINIRLAR

- `Y3`'ün mutantı yok (§3).
- Sahte kanal gerçek ağ davranışını (TCP kopması, yarım çerçeve, TLS) **taşımaz**; ölçülen protokol
  mantığıdır, taşıma değil.
- Web ayağı **[DOĞRULANMADI]** olmaya devam eder; T3 yalnız *"web'de sessizce kapalı"* olduğunu ölçer,
  *"web'de çalışıyor"* demez.
- `A12` seed'e bağlıdır; `Random` uygulaması Dart sürümüyle değişirse ayak kırılır — bu **beyan edilmiş**
  kırılganlıktır, kabul edilmiştir (deterministik olmayan bir jitter ayağı, oturum 37'nin üst-sınır
  kusurunu tekrar üretirdi).
