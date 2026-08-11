# KONSOLİDE ÖLÇÜM RAPORU — SS2 kriter 8 uçtan uca (oturum 70)

**El:** Claude Code. **Tarih (cihazdan):** 2026-08-11 13:47–14:23 (+03).
**Kapsam:** `KANIT/SS2/08` (v2) + `KANIT/SS2/09` (tur-2 denetim, 19 madde) +
`KANIT/SS2/10` (erratum: madde 6/7/15 düzeltmesi, psql yolu).
**Ürün koduna yazılan bayt:** **0** — yalnız `KANIT/SS2/T8-uctan-uca/**` altına yazıldı.

---

## 🔴 SONUÇ ÖZETİ

**On altı madde ölçüldü/kapandı, BİR madde (Ö4) GERÇEK bir engel olarak
duruyor.** Kalan tasarım (senaryo betiği, adım ⓪–⑦) bu engel yüzünden
**yazılmadı** — tek AVD ile iki cihazlı bir senaryo ne yazılabilir ne sınanabilir.

| # | madde | sonuç |
|---|---|---|
| Madde 6 (önceki tur) | backend gövde loglama | 🔴 **KAPANDI** — loglanmıyor, yapılandırmayla yükseltilemez (önceki checkpoint) |
| YENİ ön koşul | `docker exec … psql \dt` şema | 🟢 **GEÇTİ** — `processed_operations` (PK client_id,operation_id) + `sync_client_clock` (PK client_id, hlc COLLATE "C") ikisi de var |
| Ö1 | `git status --porcelain -- src` | 🟢 **TEMİZ** |
| Ö2 | `2710db0` HEAD'in atası mı | 🟢 **EVET** (`rev-parse --verify` + `merge-base --is-ancestor`, ikisi de exit 0) |
| Ö3 | `$FLUTTER`/`$ADB`/`_backend_dogrula.py` | 🟢 **ÜÇÜ DE VAR** |
| **Ö4** | **en az 2 AVD** | 🔴 **YALNIZ 1** (`tuzak_api34`) — **GERÇEK ENGEL, aşağıda** |
| Ö5 (düzeltildi) | `.Config.Healthcheck` (`.State.Health` DEĞİL) | 🟢 **TANIMLI** |
| Ö6 | `launchSettings.json` | bilgi — **YOK**, `--no-launch-profile` yine de kullanılır |
| Ö7 | taban URL | 🟢 **`SENKRON_SUNUCU_URL` derleme-zamanı ezmesi VAR** (`main.dart:24-27`), varsayılan `http://10.0.2.2:5298` — **her emülatör KENDİ hostuna çözer**, iki cihaz için DEĞİŞTİRME GEREKMEZ ⇒ ürün kodu değişikliği **gerekmiyor** |
| EK (kriter 4 için) | `DEV_USER_ID` derleme-zamanı ezmesi | 🟢 **VAR** (`GOREV-A10 Y3`, `main.dart:29-32` + `ayarlari_hazirla.dart`) — **TEK** paylaşılan `--dart-define=DEV_USER_ID=<guid>` derlemesi iki cihazı da aynı kullanıcıya bağlar, elle ayarlama **gerekmiyor** |
| item 2 | `$PSVersionTable.PSVersion` | **5.1.26100.8972** — `pwsh` (PS7) bu makinede **YOK** |
| item 3 | kanıt kodlaması | Python `open(yol,"wb")` ile **UTF-8+LF, BOM'suz** — `dosya-kimlik.py` ile **TEMİZ** ölçüldü (iki dosyada da) |
| item 4 | `adb shell` çıktısında `\r` | Python `subprocess.run([...])` ile çağrıldığında **`\r` YOK** (ölçüldü: `getprop` çıktısı `'1\n'`) — savunmacı kırpma yine de driver'a eklendi (bedava) |
| item 5 | emülatörde `curl` var mı | 🔴 **YOK** (`which curl` boş) — **`nc` (netcat, toybox) VAR** ve pozitif/negatif kontrol **ikisi de ölçüldü**: kapalı porta `Connection refused` (exit 1, ~3sn) · canlı backend'e bağlandı (exit 0). Driver `curl` yerine `nc` kullanacak şekilde tasarlandı |
| item 8 | seri↔AVD eşlemesi | `adb shell getprop ro.boot.qemu.avd_name` **çalışıyor** — ölçüldü: `emulator-5554` ↔ `tuzak_api34` |
| item 10 | `applicationId` | `com.momentum.client` (`android/app/build.gradle.kts:19`) |
| item 12 | `${env:PROGRAMFILES(X86)}` doğru sözdizimi | Bu driver Python `subprocess.Popen(env=...)` kullanıyor — **PowerShell'in parantez parser hatası DOĞASI GEREĞİ oluşmuyor** (env dict'i shell string'e hiç dönüşmüyor) |
| item 13 | backend PID + sökme | 🟢 **ÇALIŞIYOR VE SINANDI CANLI**: `subprocess.Popen` → PID dosyası → `taskkill /PID <pid> /T /F` → **YENİ ÖLÇÜM**: kill sonrası `netstat` dakikalarca `TIME_WAIT` kalıntısı gösteriyor (NORMAL TCP davranışı, LISTENING **DEĞİL**) — "boş" ölçütü `LISTENING satırı yok`a düzeltildi |
| item 18 | `.Config.Healthcheck` vs `.State.Health` | **İKİSİ DE ÖLÇÜLDÜ**, ayrım doğrulandı (madde Ö5'te) |
| item 19 | taban URL taraması `findstr` değil Python | 🟢 **Python `os.walk`+`re`** ile yapıldı, tek çağrıda 4 satır bulundu |
| kabuk girişi | Claude Code hangi kabukta | **İKİ ayrı araç**: Bash (Git Bash/MSYS) ve PowerShell 5.1, ayrı ayrı çağrılıyor — **YENİ ÖLÇÜM**: Git Bash `adb shell .../sdcard/...` gibi `/`-başlayan argümanları **Windows yoluna çeviriyor** (`C:/Program Files/Git/sdcard/...`), **screencap/pull bu yüzden Bash'ten ÇALIŞMIYOR**; PowerShell'den VE Python `subprocess.run([liste])`'den (Bash içinden çağrılsa bile) **ÇALIŞIYOR** — driver'ın TÜM adb çağrıları bu yüzden Python listesi ile yapılıyor |

---

## 🔴 Ö4 — GERÇEK ENGEL: yalnız 1 AVD var, en az 2 gerekiyor

```
& $FLUTTER emulators
1 available emulator:
  tuzak_api34 • tuzak api34 • Google • android
```

`GOREV-SS2-cakisma-cozumu.md` §7 kriter 8 `S6` kilidi: **Android üzerinde iki
ayrı cihaz**. Tek AVD'yi iki kez başlatmak (aynı disk imajı) **iki bağımsız
cihaz DEĞİLDİR** — iş emrinin kendi kilidi bu senaryoyu **DUR** sayıyor.

**Bu benim seçebileceğim bir şık değil** — yeni bir AVD yaratmak (disk/RAM
ayırıp API seviyesi/cihaz profili seçmek) hem kaynak hem tercih kararıdır.
Onur'un önündeki şıklar:
1. **Yeni bir AVD yarattır/yarat** (`avdmanager create avd` ya da Android
   Studio) — bu turun devamı için gerekli.
2. **İkinci "cihaz" olarak `flutter run -d chrome` kullanılsın** — 🔴 iş emri
   bunu **açıkça reddediyor** (`S6`, `KANIT/SS2/08` §7: *"web şıkkı YOKTUR,
   v1'in ihlali"*) — Onur bu kilidi **açıkça** kaldırmadıkça uygulanmaz.
3. **Fiziksel bir Android cihaz** USB ile bağlanır — `adb devices` ile
   ölçülür, AVD sayılmaz ama `S6`'nın *"Android"* şartını karşılar.

---

## KANITLANMIŞ ARAÇLAR (bu turda yazıldı, ÇALIŞIYOR, canlı sınandı)

| dosya | ne yapar | kanıt |
|---|---|---|
| `yardimcilar.py` | ortak: `adb()`/`adb_shell()` (Python liste-argüman, MSYS'ten bağımsız), `yokla()` (sabit sleep değil), `kanit_yaz()` (UTF-8+LF ikili), `mesaj()` (HH:mm:ss damga) | dolaylı — aşağıdaki üç betik onu kullanıyor |
| `on_kosullar.py` | Ö1-Ö7 + psql + EK(DEV_USER_ID) ölçer | `--altin-kume` **23/23 GEÇTİ** (her DUR/GEÇER dalı sentetik veriyle sınandı) · gerçek koşum: 6/7 GEÇTİ, **Ö4 DUR** (`00-onkosul.txt`) |
| `ortam_kur.py` | docker start+yokla · backend başlat (Popen+env, PowerShell kaçışı YOK) + 2-aşamalı yokla (bind→dogrula) · emülatör launch+yokla · sökme (taskkill+LISTENING-yok yokla) | **CANLI SINANDI**: docker healthy (0.2sn) · backend gerçekten ayağa kalktı, `_backend_dogrula.py` "HUKUM: BACKEND HAZIR (DB dahil)" verdi (10.5sn) · `/v1/sync` gerçek istekle 401→200 · sökme sonrası LISTENING satırı yok (bir bind-adresi pollama hatası bu turda BULUNDU VE DÜZELTİLDİ — kanıt aşağıda) |

### Bulunup düzeltilen iki gerçek betik hatası (bu turda, canlı koşumda)
1. **`backend_hazir_mi_yokla` port ölçümü YOKLAMASIZ tek çekimdi** — `dotnet
   run` birkaç saniye derleme+açılış ister; ilk ölçüm HER ZAMAN boş dönüp
   sahte DUR verirdi. Düzeltme: bind-adresi de YOKLAMALI hale getirildi.
2. **"Port boş" ölçütü `LISTENING` ile `TIME_WAIT` ayırmıyordu** — süreç
   öldürüldükten SONRA bile eski bağlantıların `TIME_WAIT` kalıntısı
   dakikalarca `netstat`te görünüyor (ölçüldü: 30 sn'de bile temizlenmedi)
   ve bu YENİ bir dinleyicinin bağlanmasını ENGELLEMEZ. Düzeltme: yalnız
   `LISTENING` satırı arandı.

---

## NE ÖLÇÜLEMEDİ (bu turda, dürüstçe)

- **İki-cihazlı senaryo (adım ⓪-⑦) hiç yazılmadı/koşulmadı** — Ö4 engeli.
- `sync_client_clock`/`processed_operations`'ın GERÇEK bir çakışma turundan
  sonra nasıl göründüğü **ölçülmedi** — şema doğrulandı, veri değil.
- `nc` tabanlı çevrimdışı/çevrimiçi ölçümü yalnız **tek cihazda, tek yönde**
  (kapalı port + canlı backend) sınandı; gerçek `svc wifi/data disable`
  senaryosunda (uçuş modu benzeri) davranışı **henüz ölçülmedi**.
- Ekran görüntüsü/`uiautomator` **pozitif kontrolü** (bilinen bir `AppBar`
  metninin dump'ta bulunması) **henüz ölçülmedi** — çakışma UI'ı yok, sadece
  boş bir emülatör ekranı test edildi.
- `flutter build apk --debug --dart-define=DEV_USER_ID=<guid>` **hiç
  koşulmadı** — mekanizma kaynaktan doğrulandı, derleme değil.

---

## SIRADAKİ (Onur'un kararından sonra)

Ö4 kapanınca (2. AVD/cihaz sağlanınca) kalan iş: `senaryo.py` — adım ⓪-⑦'yi
`yardimcilar.py`/`ortam_kur.py` üzerine kuran, Onur'un HAZIR→ŞİMDİ YAP→YAPTIM
el sıkışma noktalarında **bu sohbette duracak** (script içinde `input()`
DEĞİL — Onur bu terminale yazmıyor, benimle sohbet ediyor) modüler adımlar.
Taslağı bu raporun ekindedir (bkz. görev listesi #19, "ertelendi").
