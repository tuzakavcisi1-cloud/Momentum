# GOREV-slice-3e YÜRÜYEN İSKELET — Builder ölçümü (Claude Code, 29 Tem 2026)

> **Bu bir spec kapanışı DEĞİLDİR.** `GOREV-slice-3e-iskelet.md` kendisi de spec değil, K53/5 gereği
> yazılmış bir yürüyen iskelet talimatıydı (`G12`, mutantlar, kabul kriterleri KAPSAM DIŞI). Aşağıdaki
> sayılar **builder'ın kendi koşumuyla** ölçüldü; belgenin kendi kuralı gereği (§4) **Cowork bunların
> hiçbirine güvenmeden yeniden koşacaktır.**

## Yapılanlar (T1–T5, GOREV §2)

| adım | dosya | durum |
|---|---|---|
| T1 | `src/client/lib/ag/gercek_zamanli_sinyal.dart` | yeni — `SinyalOlayi`/`GercekZamanliSinyal` soyutlaması |
| T2 | `src/client/lib/ag/signalr_json_sinyal.dart` | yeni — SignalR JSON alt kümesi, `web_socket_channel` üstünde |
| T3 | `src/client/lib/main.dart` | `_uretimKurulumOlustur()` içine sinyal kurulumu eklendi |
| T4 | `src/client/pubspec.yaml` | `web_socket_channel: ^3.0.3` eklendi |
| T5 | `KANIT/slice-3e-iskelet/*` | cihaz kanıtı (aşağıda) |

## Otomatik ölçümler (builder'ın kendi koşumu)

| ölçüm | sonuç |
|---|---|
| `flutter analyze --fatal-infos` | **0 bulgu** |
| `flutter test` | **156/156** (mevcut sayı düşmedi — GOREV eşiği ≥156) |
| `pub-cve-kapisi.py src/client/pubspec.lock` | **EXIT 0** — 91 hosted paket sorgulandı, bulgu 0 (`pub-cve-kapisi.txt`) |
| `pub-lisans-kapisi.py src/client/pubspec.lock` | **EXIT 0** — `web_socket_channel`/`stream_channel` **BSD-3-Clause** ölçüldü, izinsiz/bilinmeyen lisans 0 (`pub-lisans-kapisi.txt`) |

Her iki pub kapısı da gerçek taramadan ÖNCE kendi `--altin-kume` ile doğrulandı (ikisi de EXIT 0).

## T5 — Cihaz kanıtı (emulator-5554, `com.momentum.client`, backend `127.0.0.1:5298`)

**Ortam (yazılmadı, ölçüldü):** `adb devices` ⇒ `emulator-5554`. Backend zaten Development modunda
çalışıyordu (PID 4700) — `POST /hubs/sync/negotiate` başlıksız **401**, `X-Momentum-Dev-User` ile **200**
+ `connectionToken` (canlı doğrulandı). Docker `momentum-postgres` healthy.

**Cihaz kimlikleri** (run-as + base64 ile `momentum.sqlite`'tan okundu): `02b-uzak-yazim-kimlikler.txt`.

### Ayak 1 — açık ve önde, WS bağlı
`00-once.png` / `00b-dialog-sonrasi.png` (PNG imzası doğrulandı: `89 50 4E 47 0D 0A 1A 0A`).
Logcat: el sıkışma başarılı `15:08:19.133` (soğuk açılıştan ~12 sn sonra).
🔴 `00-once.png`'de bir **System UI isn't responding** diyaloğu var — K71/R9'da ölçülenle AYNI sınıf
(System UI'a ait, `com.momentum.client`'a değil; uygulama `pidof` boyunca canlıydı). `00b` diyalog
kapatıldıktan sonraki temiz durumdur.

### Ayak 2 — canlı, yoklamasız yayılım (asıl T5 kanıtı)
Ayrı bir süreçten (curl, "başka bir cihaz" — farklı `clientId`, AYNI `devUserId`) `POST /v1/sync` ile
yeni görev itildi (`02-uzak-yazim-istek.json` → `03-uzak-yazim-yanit.json`, **200 Applied**).
Cihaz **dokunulmadan** `Changed` aldı (gecikme **`[DOĞRULANMADI]`** — ayrıntı `_ws-trafik.txt` §2), imleç
`{"xid":1245,"seq":289}` → `{"xid":1248,"seq":290}` ilerledi, görev `01-sonra.png`'de ve UI dump'ta
(`content-desc`) TAM başlığıyla göründü.

### Ayak 3 — yeniden bağlanma + kaçan sinyal kurtarma (K77/2)
`svc wifi disable` + `svc data disable` ile bağlantı GERÇEKTEN kesildi (airplane_mode broadcast'i
kabuk için izinsizdi, `svc` ile doğrudan kesildi — `_ws-trafik.txt` §4). Cihaz çevrimdışıyken
İKİNCİ bir uzak görev push edildi (`04-…istek.json` → `05-…yanit.json`, 200 Applied) — cihaz bu sinyali
**hiç almadı** (SignalR kuyruklamaz). Ağ geri açıldıktan sonra yeniden bağlanma başarılı oldu ve TEK
çekme turu bu kaçan görevi getirdi: imleç `{"xid":1248,"seq":290}` → `{"xid":1251,"seq":291}`,
`02-yeniden-baglanma.png`'de görev dokunulmadan listede.

**Geri çekilme çizelgesi ölçümü** (`02-yeniden-baglanma.txt`): 6 deneme; ölçülen aralıkların 6'sı da
K77/2 çizelgesinin (1-2-4-8-16-30 sn, ±%20 jitter) aralığına düşüyor. 🔴 **Bu bir ÜST SINIR ölçümüdür:**
aralık = zamanlayıcı gecikmesi **+ başarısız deneme süresi**, ve deneme süresi ölçülmedi. Üçüncü aralık
(3.236 ms) alt sınıra (3.200 ms) yalnız **36 ms** uzakta ⇒ deneme 36 ms'den uzun sürdüyse gerçek gecikme
aralığın DIŞINDADIR. Güçlü belirti, **kanıt değil** [Cowork bağımsız doğrulaması, oturum 37].

## Bilinen sınırlar (beyan edildi, gizlenmedi)

- Web ayağı **[DOĞRULANMADI]** — K77/3 kilidi gereği bu dilimin kapsamı dışında.
- `00-once.png`'deki System UI ANR diyaloğu emülatörün bilinen bir yapısıdır (K71/R9'da da ölçüldü);
  uygulamanın kendi ANR'si olup olmadığı bu ölçümün konusu değildi.
- `G12` kapısı ve mutantlar **bilerek yazılmadı** (K77/4, K53/5 — iskelet önce, kapılar sonra).
- Bu ölçümün hiçbiri Cowork'ün bağımsız yeniden koşumunun yerine geçmez (K26).

## Dosyalar

`00-once.png` · `00b-dialog-sonrasi.png` · `01-sonra.png` · `02-uzak-yazim-istek.json` ·
`02b-uzak-yazim-kimlikler.txt` · `03-uzak-yazim-yanit.json` · `04-ucak-modu-uzak-yazim-istek.json` ·
`05-ucak-modu-uzak-yazim-yanit.json` · `02-yeniden-baglanma.png` · `02-yeniden-baglanma.txt` ·
`_ws-trafik.txt` (+ ham `_ws-trafik_ham.txt`, `_logcat_raw.txt`) · `_db_before*/​_db_after*/​_db_reconnect*`
(sqlite + base64) · `pub-cve-kapisi.txt` · `pub-lisans-kapisi.txt`.
