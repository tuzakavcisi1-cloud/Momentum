# ⛔ ERRATUM — **`S6` YANLIŞ OKUNDU. `Ö4` GERÇEK BİR ENGEL DEĞİL.** (o70)

**Ölçen:** Cowork, `device_bash` ile **kilitli spec'in kendi satırlarından**. **Tarih:** 11 Ağu 2026.
**Geçersiz kıldığı:** `KANIT/SS2/07` **`B-E`** · `KANIT/SS2/08` §7'nin *"web şıkkı YOKTUR"* satırı ·
`KANIT/SS2/09` §1'in *"`B-E` KAPANDI"* hükmü · `K180` §2/① · Onur'un *"iki Android emülatör"* kilidi.

---

## 1. ÖLÇÜM — kilitli spec'in İKİ satırı, birebir

**`S6`'nın TAM metni** (`GOREV-SS2` §8, satır 508–509):
> *"**S6** — Web ayağı **`[DOĞRULANMADI]`**: `flutter test --platform chrome` bu ortamda sonuç
> üretmiyor (7 dk ve 9,8 dk — `ORTAM.md`). Kriter 8 **Android** üzerinde koşar."*

**Kriter 8'in kendi ⑤. adımı** (`GOREV-SS2` §7, satır 477–478):
> *"⑤ **Cihaz A** (**ikinci emülatör ya da `flutter run -d chrome`**) aynı görevin başlığını `A1` yapar
> ve **senkronize olur**"*

🔴 **`S6`'nın konusu `flutter test --platform chrome` TEST AYAĞIDIR**, cihaz topolojisi değil.
*"Kriter 8 Android üzerinde koşar"* cümlesi, **doğrulanmamış web test ayağına dayanılmadığını** söyler —
**cihaz A'nın chrome olmasını YASAKLAMAZ.** Aynı spec, **aynı kriterin içinde**, chrome'u **açıkça sunar**.

⇒ **Kilitli spec, `flutter run -d chrome`'u cihaz A olarak ZATEN İZİN VERİYOR.**
⇒ **`Ö4` (ikinci AVD yok) bir ENGEL DEĞİLDİR.** `tuzak_api34` = **cihaz B** · chrome = **cihaz A**.

## 2. 🔴 KUSUR COWORK'ÜNDÜR — bu oturumun ONBİRİNCİ aynı-sınıf kusuru, ve EN PAHALISI

Tur 1 denetçisi `B-E`'yi şöyle yazdı: *"Kilitli spec §8 birebir: '**S6** — **…** Kriter 8 **Android**
üzerinde koşar.'"* — 🔴 **üç nokta, cümlenin konusunu (`flutter test --platform chrome`) SİLİYOR.**
Cowork bu **kısaltılmış alıntıyı KAYNAĞA BAKMADAN kabul etti** ve kendi v1'inin
*"ikinci emülatör YA DA `flutter run -d chrome`"* satırını **doktrin ihlali** ilan etti — oysa o satır
**kriter 8 ⑤'ten BİREBİR kopyalanmıştı ve DOĞRUYDU.**

**Yayılma zinciri:** yanlış hüküm → `07`'ye `B-E` olarak yazıldı → Onur'a sunulan şıkta
*"web şıkkını seçersen `S6`'yı **gevşetmiş** olursun"* diye çerçevelendi → **Onur yanlış öncüle dayanan
bir kilit verdi** (*"iki Android emülatör"*) → `08` §7'ye *"web şıkkı YOKTUR"* diye kilit yazıldı →
`09` bunu *"KAPANDI"* saydı → **Claude Code `Ö4`'te DURDU** ve Onur'a *"yeni AVD / fiziksel cihaz /
`S6`'yı gevşet"* diye **var olmayan bir kaynak kararı** taşıdı.

🔴 **Sınıf: `bayat-iddia` + `olu-beyan` — ölçülebilir bir olgu, bir DENETİM RAPORUNDAN türetildi.**
Bu, o69 devir notunun *"denetim raporundan kopyalanan satır no"* kusurunun **aynısıdır** ve bu oturumda
**dokuzuncu, onuncu, onbirinci** kez ısırdı. **Alıntıdaki üç nokta, ölçülmemiş bir varsayımdır.**

## 3. YENİ DURUM — Onur'un ÜÇ ŞIKKININ ÜÇÜ DE GEREKSİZ

| şık | hüküm |
|---|---|
| Yeni AVD yarat | **GEREKMİYOR** — kilitli spec chrome'a izin veriyor |
| Fiziksel cihaz bağla | **GEREKMİYOR** — aynı gerekçe |
| `S6`'nın web yasağını gevşet | **YASAK YOK** — gevşetilecek bir kilit **hiç olmadı** |

🟢 **Topoloji: `tuzak_api34` (cihaz B, Android, çevrimdışına alınan) + `flutter run -d chrome` (cihaz A).**
`S6` **korunur**: kriter 8'in **kendisi** (çakışmayı doğuran çevrimdışı cihaz) **Android'dedir**.

## 4. 🔴 CHROME YOLUNUN ÖLÇÜLECEK — VE ÖLÇÜLMEMİŞ — DÖRT ŞARTI

Bunlar **doktrin engeli değil, ORTAM ölçümüdür**; tur-2 red-team'i haklı olarak saydı, **hâlâ geçerli**:

1. **Taban URL:** emülatör `10.0.2.2:5298`, chrome `localhost:5298` — **iki istemcinin AYNI backend'e
   gittiği ÖLÇÜLÜR** (backend logu iki farklı kökenden istek göstermeli). Derleme zamanı sabitse ⇒ **DUR**.
2. **CORS:** web istemcisi **çapraz-köken** olur ⇒ `W1` yolu devreye girer.
   `appsettings.Development.json` ⇒ `Cors:AllowedOrigins = ["http://localhost:5000"]` **ölçüldü** ⇒
   `flutter run -d chrome`'un portu **`--web-port 5000` ile PİNLENİR**, yoksa rastgele port CORS'a takılır.
   🔴 `B-W1-5`: *"CORS yalnız Development"* kararı **kapısız** — beyan edilmiş borç.
3. **Drift web varlıkları** (`sqlite3.wasm` / `drift_worker.js`) yerinde mi — `web-varlik-indir.py`
   pinine karşı **ölçülür**; yoksa web istemcinin veritabanı **hiç açılmaz**.
4. **`--no-web-resources-cdn` gerekliliği** `[DOĞRULANMADI]` (`B-O63-2` **AÇIK**) ⇒ **ölçülür**, varsayılmaz.

🔴 **`kIsWeb` ⇒ SignalR web'de KAPALI** (`DURUM.md` §3) — bu **sorun değildir**: adım ⑤ ve ⑦'de A'nın
senkronunu **Onur elle tetikler** (o70 kilidi: *"UI'ı Onur sürer"*) ve `v2` zaten tetikleyicinin
**birebir yazılmasını** şart koşuyor.

## 5. `KANIT/SS2/09`'un 19 MADDESİNE ETKİ

- **Madde 8** (`<seri>`↔AVD↔pencere eşlemesi) — **daralır**: yalnız **bir** seri var (`tuzak_api34`);
  cihaz A chrome olduğu için karışma riski **düşer**, ama *"Onur hangi pencereye bakıyor"* **hâlâ ölçülür**.
- **Madde 10** (`build apk` + `install` + `monkey`) — **cihaz B için aynen durur**; cihaz A için
  `flutter run -d chrome --web-port 5000` gelir.
- **Madde 5** (emülatörde `curl`) — **yalnız cihaz B** için geçerli.
- Kalan maddeler **aynen durur**.

## 6. NE ÖLÇÜLEMEDİ

- **`flutter emulators` çıktısını Cowork ÖLÇEMEDİ** — `flutter` Windows'ta, Cowork'ün Linux VM'inde yok;
  AVD listesi (`tuzak_api34`, **tek**) **Claude Code'un ölçümüdür** ve Cowork onu **doğrulamadı**.
  🔴 Ama hüküm **buna dayanmıyor**: tek AVD **yeterlidir**, çünkü ikinci cihaz chrome'dur.
- **Chrome yolunun dört şartı ölçülmedi** (§4) — hepsi Claude Code'un işidir.
- `Cors:AllowedOrigins` **kaynaktan** okundu (`appsettings.Development.json`), **çalışan sunucudan değil**.
