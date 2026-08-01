# GOREV-A10 — Gerçek cihaz ön koşulları (INTERNET izni · cleartext yapılandırması · `DEV_USER_ID` ezmesi)

> 🔒 **KİLİTLİ — Onur onayladı, 1 Ağu 2026, oturum 46 (K105).** Bu dosyaya **tek bayt yazılmaz**;
> değişen her bayt **kilidi bozar**. Kilitli kimlik `DURUM.md` §9 (DONMUŞ KİMLİKLER) tablosunda tutulur
> ve **bu kilit satırı eklendikten SONRA** ölçülmüştür. Builder değişiklik gerekiyorsa **yazmaz, Onur'a sorar**.
>
> **v2 · 1 Ağu 2026 · Cowork yazdı (tasarım) · KODU CLAUDE CODE YAZAR (K26 · K34-f).**
> 🔴 **v1 (12.151 b · `04E49CC9`) GEÇERSİZDİR.** **TEK** denetim turu (K53/1) **iki bağımsız mercekle** koştu
> (teknik denetçi 12 + red-team 13 = **ham 25 bulgu, ham 10 bloker etiketi**; **BEŞ mükerrer çift** ayıklanınca
> **20 AYRIK bulgu, 7 AYRIK bloker**). Mükerrer çiftler — iki mercek bunları **bağımsız** buldu, çoklu-mercek
> tasarımının ölçülmüş getirisi budur: ① define boru hattı ② `G18/b`'nin bedava yeşili ③ `M127`'nin eşdeğerliği
> ④ ezmede yerel verinin kalması ⑤ `G19` fikstürünün vacuous'luğu. Red-team hükmü: *"MİMARİYİ DEĞİŞTİREN BLOKER: YOK"*
> ⇒ **ikinci kâğıt turu AÇILMAZ** (K53/1). Onur iki tasarım kararını kilitledi: **§3/c** ve **§3/d**.
> **KAPSAM:** 4 değişen + 2 yeni ürün dosyası + 2 yeni test dosyası. Yeni bağımlılık YOK, **yeni araç/betik YOK** (R8).
> **BU BİR DİKEY DİLİM DEĞİL**, ③ *"gerçek cihazda uçtan uca senkron kanıtı"* işinin **ön koşuludur**.

## 0. NEDEN ŞİMDİ — ölçüldü, varsayılmadı

| ölçüm | sonuç | nerede |
|---|---|---|
| `radar.py . --olc-urun-kodu HEAD~3` | **`urun_kodu_satiri = 0`** | oturum 46 açılışı |
| `R8` sert durak | **KIRMIZI** — oturum 44 ve 45 sıfır ürün kodu | `radar.py .` |
| `src/main/AndroidManifest.xml` | `uses-permission` **HİÇ YOK** | dosya okundu |
| `src/debug/` + `src/profile/` manifestleri | INTERNET izni **YALNIZ BURADA** (Flutter varsayılanı) | `dir /s /b` + iki dosya okundu |
| `app/src/debug/` içeriği | **yalnız** `AndroidManifest.xml`; `res/` dizini **YOK** | `dir /s /b` |
| `network_security_config.xml` | repoda **YOK** | aynı ölçüm |
| `targetSdk` | `flutter.targetSdkVersion` (≥ 28) ⇒ platform katmanında cleartext varsayılan **KAPALI** | `app/build.gradle.kts` |
| `_senkronSunucuUrl` | `String.fromEnvironment('SENKRON_SUNUCU_URL', default 'http://10.0.2.2:5298')` — düz HTTP | `lib/main.dart:22` |
| `devUserIdDegistir` | yazılmış, **hiçbir akıştan çağrılmıyor** (doc yorumu da bunu beyan ediyor) | `lib/veri/ayarlar_deposu.dart:118` |
| 🔴 **`DevCurrentUser`** | **`Guid.TryParse`** — GUID **olmayan** başlık ⇒ `null` ⇒ **her istek 401** | `src/backend/Momentum.Api/Auth/DevCurrentUser.cs:26` |
| 🔴 D7/4 sıfırlamasının **kapsamı** | **yalnız** `nextCursorJson` + `uzak_alan_durumu`; `gorevler` ve `senkron_kuyrugu` **KALIR** | `ayarlar_deposu.dart:46-55` |

**Sonuç:** ① release derlemesi **ağa hiç çıkamaz** ⇒ *"çevrimdışı-öncelikli senkron"* vitrini release'te ölüdür.
② İki cihazı **aynı kullanıcı** yapmanın yolu yoktur (`devUserId` her kurulumda rastgele) ⇒ ③ kurulamaz.

🔴 **BEYAN EDİLMİŞ BELİRSİZLİK:** `dart:io HttpClient` Android'in Java ağ yığınını kullanmaz ve Android
belgesi `usesCleartextTraffic`'in **best-effort** olduğunu, **Socket API'nin onu onurlandırmasının
beklenmediğini** yazar (belge beyanı; bu projede **ÖLÇÜLMEDİ**). Bu yüzden **Y2 bir no-op olabilir** ve
*"kesin gerekli"* diye değil **debug-only, bedelsiz sigorta** diye yazılmıştır; hüküm ③'te cihazda verilir.

---

## 1. YAPILACAK — üç kalem

**Y1.** `android/app/src/main/AndroidManifest.xml`'e `<uses-permission android:name="android.permission.INTERNET"/>` eklenir (`<manifest>` altına, `<application>`'dan önce). **`debug/` ve `profile/` manifestlerine DOKUNULMAZ**: aynı izin **birebir aynı özniteliklerle** tekrar ettiği için manifest merger onları tek elemana indirger, uyarı üretmez (denetimde doğrulandı).

**Y2.** `android/app/src/debug/res/xml/network_security_config.xml` **yeni** oluşturulur; `debug/AndroidManifest.xml`'e `<application android:networkSecurityConfig="@xml/network_security_config"/>` eklenir. `main/` bu özniteliği taşımadığı için `tools:replace` ve `xmlns:tools` **gerekmez** (doğrulandı). Yapılandırma **yalnız debug kaynak kümesinde** yaşar ⇒ release varyantı bu manifesti hiç görmez, referans oluşmaz, **release derlemesi kırılmaz** (doğrulandı).

**Y3.** `DEV_USER_ID` derleme-zamanı ezmesi: `lib/veri/ayarlari_hazirla.dart` **yeni** dosyasında **public** `ayarlariHazirla` fonksiyonu yaşar; `lib/main.dart` `const String devUserIdEzmesi = String.fromEnvironment('DEV_USER_ID');` **public** sabitini tanımlar ve `_uretimKurulumOlustur` içindeki `yukleVeyaOlustur()` çağrısını bu fonksiyona devreder.

## 2. PAZARLIKSIZ SINIRLAR

1. **Release'e cleartext AÇILMAZ.** `android:usesCleartextTraffic` **hiçbir manifeste yazılmaz** (`G18/d` bunu statik olarak ölçer); `main/` manifesti `networkSecurityConfig` **almaz**.
2. **Yeni bağımlılık YOK · yeni araç/betik YOK.** `R8` yürürlükte: bu tur **ürün kodu** turudur. Tüm ölçümler `findstr` · `dir` · `aapt2` · `flutter test` · PowerShell `ZipFile` ile yapılır.
3. **İkinci bir `String.fromEnvironment('SENKRON_SUNUCU_URL')` EKLENMEZ** (K77/5). 🔴 **ÖLÇÜLDÜ (bugün):** `lib/main.dart`'ta `String.fromEnvironment` **tam 1** (`SENKRON_SUNUCU_URL`), `bool.fromEnvironment` **tam 2** (`ENABLE_FLUTTER_DRIVER`, `DURUM_VITRINI`) kez geçiyor ⇒ Y3'ten **sonra** `String.fromEnvironment` **tam 2** olmalıdır, `bool.fromEnvironment` **2 kalmalıdır**.
4. **İmleç sahipliği mantığı KOPYALANMAZ.** İmleç/`uzak_alan_durumu` sıfırlaması `yukleVeyaOlustur()`'un **mevcut** D7/4 karşılaştırmasıyla yapılır; bu iki alan Y3'ün kodunda **elle silinmez**.
5. **Ezme verilmediğinde davranış BAYT BAYT eskisiyle aynıdır** — `DEV_USER_ID` boşsa `devUserIdDegistir` **hiç çağrılmaz** (`G19/c` casusla sayar) ve tek fazladan yazma koşmaz.
6. `ayarlar_deposu.dart`'taki `devUserIdDegistir` doc yorumu *"üretimde ÇAĞRILMAZ"* diyor; Y3 bunu **yanlışlar**. Yorum **aynı commit'te** düzeltilir ve yeni çağrı yolunu + §3/d'nin sınırını yazar.

## 3. Y3'ÜN TAM SÖZLEŞMESİ

`lib/veri/ayarlari_hazirla.dart` (yeni, public — `main.dart`'a konmaz; kriter 5 bu dosyayı **beyaz listede** taşır):

```dart
final RegExp _guid = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

Future<Ayarlar> ayarlariHazirla(
  Veritabani db,
  AyarlarDeposu deposu, {
  required String ezme,
}) async {
  final ayarlar = await deposu.yukleVeyaOlustur();            // a
  if (ezme.isEmpty || ezme == ayarlar.devUserId) return ayarlar;  // b
  if (!_guid.hasMatch(ezme)) {                                 // c  [ONUR KİLİDİ]
    throw ArgumentError.value(ezme, 'DEV_USER_ID',
        'GUID olmalı -- backend Guid.TryParse kullanır, aksi halde her istek 401');
  }
  await db.transaction(() async {                              // d  [ONUR KİLİDİ]
    await deposu.devUserIdDegistir(ezme);
    await db.delete(db.gorevler).go();
    await db.delete(db.senkronKuyrugu).go();
  });
  return deposu.yukleVeyaOlustur();                            // e
}
```

**(a)** mevcut satırı okur. **(b)** ezme yoksa ya da zaten eşitse **hiçbir yazma koşmaz** (§2/5).
**(c) ONUR KİLİTLEDİ — gürültülü hata:** GUID olmayan ezme **sessizce yutulmaz**. Ölçülmüş gerekçe: backend `Guid.TryParse` kullanır (`DevCurrentUser.cs:26`) ⇒ bozuk ezme **her isteği 401** yapar, `senkron_dongusu.dart` 401'i ağ hatası sayar, kuyruk `denemeSayisi` 8'e tırmanır ve **kusur istemcide hiç görünmez**. K61'in *"sessiz varsayılan kullanıcı YOK"* kilidinin istemci karşılığıdır.
**(d) ONUR KİLİTLEDİ — kullanıcı-kapsamlı veri silinir:** D7/4 sıfırlaması **yalnız** `nextCursorJson` + `uzak_alan_durumu`'nu kapsar (`ayarlar_deposu.dart:46-55` okundu). `gorevler` ve `senkron_kuyrugu` bırakılırsa **eski kullanıcının bekleyen op'ları YENİ kimlikle sunucuya itilir** (op gövdesi kullanıcıyı taşımaz; kimlik `X-Momentum-Dev-User` başlığındadır) ⇒ başka bir kullanıcının verisi Onur'un hesabına yazılır. Kırmızı çizgi 2 (gizlilik-öncelikli) gereği **kapatıldı**.
**(e)** `imlecSahibi != devUserId` görülür ⇒ `nextCursorJson` + `uzak_alan_durumu` **mevcut** mekanizmayla, tek transaction'da sıfırlanır. **(d) ile (e) arasında çökme kendini onarır:** bir sonraki açılışta (a) uyumsuzluğu görür.

🔴 **ÇAĞRI YERİ (pazarlıksız):** `_uretimKurulumOlustur` **içinde**, `final ayarlar = await ayarlarDeposu.yukleVeyaOlustur();` satırının **yerine** `final ayarlar = await ayarlariHazirla(db, ayarlarDeposu, ezme: devUserIdEzmesi);` yazılır. `main()`'in gövdesi ve `_UretimKurulumu`'nun biçimi **DEĞİŞMEZ**.

🔴 **BEŞ TÜKETİCİ DE DÖNEN NESNEDEN BESLENİR:** `HlcUretici(clientId:, sonWall:, sonCounter:)` · `DriftGorevDeposu(actorId:)` · **`HttpSenkronAgi(actorId:)`** · `SenkronDongusu(devUserId:, baslangicCursorJson:)` · `SignalrJsonSinyal(actorId:)`. **`HttpSenkronAgi` v1'de listede yoktu ve `X-Momentum-Dev-User` başlığını taşıyan tam odur.** Eski bağ kalırsa: oplar eski kullanıcıya yazılır, iki cihaz asla buluşmaz; daha kötüsü eski imleç ilk yanıtta `nextCursorKalicilastir(eski, devUserId: yeni)` ile **yeni sahiple kalıcılaşır** ⇒ D7/4 muhafızı **bir daha asla ateşlenemez**. Prozayla kapatılan tuzak kapatılmamış sayılır ⇒ `G21` bunu **statik olarak** ölçer.

## 4. KABUL KRİTERLERİ (hepsi ÖLÇÜLÜR; beyan kabul edilmez)

1. `flutter analyze --fatal-infos` ⇒ **0 bulgu**.
2. `flutter test` ⇒ tüm testler yeşil. **Taban 476**; yeni testlerle sayı **ARTAR**, düşemez. Ham çıktı `KANIT/A10/` altına.
3. `flutter build apk --release` **VE** `flutter build apk --debug` başarılı. 🔴 **Bu depoda `flutter build apk` DAHA ÖNCE HİÇ KOŞULMADI** (`DURUM.md`/`KAPILAR.md`/`BORCLAR.md`'de tek kaydı yok) ⇒ bu bir **ölçümdür**, formalite değil. İlk hata Gradle/JDK/AGP kaynaklıysa **A10'un kapsamı dışıdır** ve ayrı raporlanır.
4. `G17` · `G18` · `G19` · `G20` · `G21` **beşi de** ölçülür ve **GEÇER**. 🔴 **Bir ayak `[ÖLÇÜLEMEDİ]` ise o kapı KAPANMAZ ve bu kriter YEŞİL YAZILAMAZ.** *"Ölçülemedi", "temiz" DEĞİLDİR.*
5. **KAPSAM — `git --no-optional-locks status --porcelain` ile ölçülür** (`git diff --stat` izlenmeyen yeni dosyaları **GÖREMEZ**; `--no-optional-locks` `CLAUDE.md` gereği her git çağrısında **ZORUNLU**). Depoda **zaten** 85 izlenmeyen dosya vardır ⇒ ölçüm **farka** bakar: build'den **önce** çıktı `KANIT/A10/00-TABAN-status.txt`'ye yazılır; kabulde **yeni görünen** satırlar **yalnız** şunlar olabilir: `android/app/src/main/AndroidManifest.xml` · `android/app/src/debug/AndroidManifest.xml` · `android/app/src/debug/res/xml/network_security_config.xml` · `lib/main.dart` · `lib/veri/ayarlari_hazirla.dart` · `lib/veri/ayarlar_deposu.dart` · `test/ayarlari_hazirla_test.dart` · `test/dev_user_id_define_test.dart` · `KANIT/A10/**`. **Başka tek satır bile kapsam sızmasıdır.**
6. `devUserIdDegistir` doc yorumundaki *"üretimde ÇAĞRILMAZ"* ifadesi kaldırılır; yeni çağrı yolu **ve** §3/d sınırı yazılır (§2/6).
7. `python araclar\tek-kopya-kapisi.py .` ⇒ **YEŞİL**.
8. Ürün kodu satırı **elle yazılmaz**: kapanışta `python araclar\radar.py . --olc-urun-kodu <build-öncesi-sha>` koşulur; çıkan sayı deftere **olduğu gibi** girer.
9. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A10-cihaz-on-kosullari.md` ⇒ **EXIT 0** (K81: **dizin değil, DOSYA yolu**).
10. `KANIT/A10/06-MUTANT/M<n>/` altındaki **dört dosya** kuralı (§6 girişi) **her mutant için** sağlanır.

## 5. KAPILAR

🔴 **ORTAK KURAL — YOKLUK AYAĞI BEDAVAYA YEŞİL OLAMAZ:** bir ayak *"şu şey YOK"* diye ölçüyorsa, önce ölçülen **artefaktın VAR OLDUĞU** kanıtlanır (pozitif kontrol). Dosya/çıktı yoksa hüküm **`[ÖLÇÜLEMEDİ]`**'dir; *"YOK"* **yazılamaz**.

🔴 **ORTAK KURAL — BİRLEŞTİRİLMİŞ MANİFEST YOLU VARSAYILMAZ, KEŞFEDİLİR:** AGP sürümü yolu bir alt dizin kaydırır (`…\merged_manifests\<varyant>\process<Varyant>Manifest\AndroidManifest.xml`). Her ölçüm `dir /s /b build\app\intermediates\merged_manifests\<varyant>\*AndroidManifest.xml` ile **tam 1** dosya bulmalı, bulunan **tam yol** kanıta yazılmalı; 0 dosya ⇒ `[ÖLÇÜLEMEDİ]`. Pozitif kontrol: aynı dosyada `findstr /c:"package="` ⇒ **BULUNUR**.

### G17 — release derlemesi INTERNET iznini TAŞIR

| ayak | ölçüm | beklenen |
|---|---|---|
| `G17/0` | 🔴 **TABAN — Y1'DEN ÖNCE:** `flutter build apk --release` bir kez koşulur, release birleştirilmiş manifestinde `android.permission.INTERNET` aranır; sonuç `KANIT/A10/00-TABAN.txt` | **BULUNMAZ**. Bulunursa §0'ın teşhisi **ÇÜRÜMÜŞTÜR** (bir eklenti AAR'ı izni enjekte ediyordur): Y1 **durdurulur**, Onur'a bildirilir |
| `G17/a` | Y1 sonrası release birleştirilmiş manifesti (ortak kural ile keşfedilir) | `android.permission.INTERNET` **BULUNUR** |
| `G17/b` | `<aapt2> dump permissions build\app\outputs\flutter-apk\app-release.apk` | çıktı **BOŞ DEĞİL** (pozitif kontrol) **ve** `android.permission.INTERNET` **VAR** |

> `G17/0` olmadan `G17/a`'nın yeşili **Y1'in katkısını değil rastlantıyı** ölçmüş olur. `aapt2` çözülemezse `G17/b` **`[ÖLÇÜLEMEDİ]`**'dir ve `G17` **KAPANMAZ**.

### G18 — cleartext yapılandırması YALNIZ debug'da, cleartext AÇIKÇA açılmamış

| ayak | ölçüm | beklenen |
|---|---|---|
| `G18/a` | debug birleştirilmiş manifestinde `android:networkSecurityConfig` | **VAR** |
| `G18/b` | **release** birleştirilmiş manifestinde `android:networkSecurityConfig` (ortak kurallar zorunlu) | **YOK** |
| `G18/c` | PowerShell: `Add-Type -A System.IO.Compression.FileSystem` ile `app-debug.apk` açılır, `res/xml/*network_security_config*` girdisi aranır | **≥ 1 girdi** |
| `G18/d` | `findstr /s /i /c:"usesCleartextTraffic" src\client\android\` | **0 eşleşme** |
| `G18/e` | aynı sorgu `app-release.apk` üzerinde (`G18/c`'nin negatif ikizi) | **0 girdi** |

> `G18/b` + `G18/e` bu kapının **yokluk ayaklarıdır** ve pazarlıksızdır: yalnız varlığı ölçen kapı, yapılandırmanın release'e **sızdığını göremez**. `G18/d` `usesCleartextTraffic` kaçamağını kapatır — v1'de **hiçbir ayak** §2/1'i ölçmüyordu.

### G19 — `ayarlariHazirla` sözleşmesi (birim testleri)

🔴 **ORTAK FİKSTÜR (pazarlıksız; aksi hâlde ayaklar VACUOUS yeşildir):** `ayarlar` satırı `devUserId = <GUID-A>`, `imlecSahibi = <GUID-A>` (**EŞİT**), `nextCursorJson = '{"Xid":7,"Seq":3}'` (**null DEĞİL**) yazılır; `uzak_alan_durumu`'na **≥ 2**, `gorevler`'e **≥ 2**, `senkron_kuyrugu`'na **≥ 2** satır eklenir. Çağrıdan **önce** dört sayı okunup kanıta yazılır (`ÖNCE: cursor=dolu, uzak=2, gorev=2, kuyruk=2`).

| ayak | ölçüm | beklenen |
|---|---|---|
| `G19/a` | `ayarlariHazirla(db, depo, ezme: <GUID-B>)` | `devUserId == <GUID-B>` · `nextCursorJson == null` · `uzak_alan_durumu` **0** · `gorevler` **0** · `senkron_kuyrugu` **0** |
| `G19/b` | `ayarlariHazirla(db, depo, ezme: '')` | `devUserId` **DEĞİŞMEZ** · cursor **KORUNUR** · üç tablo da **DOLU KALIR** |
| `G19/c` | `devUserIdDegistir` çağrılarını **SAYAN casus** depoyla `ayarlariHazirla(db, casus, ezme: <GUID-A>)` (ezme zaten eşit) | çağrı sayısı **0** · cursor **KORUNUR** · tablolar **DOLU** |
| `G19/d` | `ayarlariHazirla(db, depo, ezme: 'onur')` (GUID **değil**) | `ArgumentError` **fırlatılır** · `devUserId` **DEĞİŞMEZ** · hiçbir tablo boşalmaz |

### G20 — `--dart-define=DEV_USER_ID` boru hattı gerçekten bağlı

| ayak | ölçüm | beklenen |
|---|---|---|
| `G20/a` | `flutter test --dart-define=DEV_USER_ID=<GUID> test\dev_user_id_define_test.dart` — test, **kanonik anahtarı kendi okur** (`String.fromEnvironment('DEV_USER_ID')`) ve ürünün `devUserIdEzmesi` sabitiyle karşılaştırır | **eşit** |
| `G20/b` | aynı test `--dart-define` **VERİLMEDEN** | **ikisi de boş** ⇒ yeşil (yanlış-pozitif kontrolü) |

> Test kanonik anahtarı **kendi** yazar, ürün kodu **kendi** yazar; ikisi ayrıştığında ayak kırmızıdır. Anahtar adı yanlış yazılırsa (`DEV_USERID`) v1'de **hiçbir kapı görmüyordu**: analyze 0, test yeşil, tüm kapılar yeşil, cihazda ezme hiç uygulanmaz.

### G21 — `main.dart` kablolaması tek bağdan beslenir (statik)

| ayak | ölçüm | beklenen |
|---|---|---|
| `G21/a` | `findstr /n /c:"ayarlariHazirla(" lib\main.dart` | **tam 1** eşleşme, `ezme: devUserIdEzmesi` argümanını taşır |
| `G21/b` | `findstr /n /c:"yukleVeyaOlustur(" lib\main.dart` | **0** eşleşme |
| `G21/c` | `findstr /n /c:"ayarlar." lib\main.dart` — `HlcUretici` · `DriftGorevDeposu` · `HttpSenkronAgi` · `SenkronDongusu` · `SignalrJsonSinyal` çağrılarının hepsi aynı `ayarlar` bağını okur | **beş tüketici**, ikinci bir `Ayarlar` bağı **YOK** |
| `G21/d` | `findstr /n /c:"String.fromEnvironment" lib\main.dart` **ve** `findstr /n /c:"bool.fromEnvironment" lib\main.dart` (§2/3) | sırasıyla **tam 2** ve **tam 2** eşleşme |

## 6. MUTANTLAR

Her mutant **uygulanır → kapı koşulur → geri alınır**. `KANIT/A10/06-MUTANT/M<n>/` altına **DÖRT dosya** konur; **eksiği olan mutant KOŞMAMIŞ SAYILIR**:
① `diff.txt` — uygulanan değişikliğin `git --no-optional-locks diff` çıktısı ·
② `artefakt.txt` — ölçülen dosyanın **tam yolu** + `certutil -hashfile <yol> SHA256` + değiştirilme zamanı (**derleme mutantlarında** bu, ölçülenin **mutant sonrası** üretildiğini kanıtlar; mutantsız koşumun sha'sından **FARKLI olmak ZORUNDA**) ·
③ `kapi-KIRMIZI.txt` — kapının ham çıktısı ·
④ `geri-alma-YESIL.txt` — geri alma sonrası **aynı kapının YEŞİL** ham çıktısı.
🔴 **KIRMIZI, iki YEŞİL'in arasında görülmediyse ısırık kanıtlanmamıştır** (KÖR KAPI YOK).

| # | mutant | kapı / kural | beklenen |
|---|---|---|---|
| M125 | `main/AndroidManifest.xml`'den `uses-permission` satırı silinir, release **yeniden** derlenir | `G17` (her iki ayak) | manifestte ve APK'da izin **YOK** ⇒ `G17` **KIRMIZI** |
| M126 | `debug/AndroidManifest.xml`'den `android:networkSecurityConfig` niteliği silinir, debug **yeniden** derlenir | `G18` varlık ayağı | nitelik **YOK** ⇒ `G18` **KIRMIZI** |
| M127 | Nitelik `main/`'e **eklenir** (debug'daki yerinde KALIR) **VE** kaynak `src/main/res/xml/network_security_config.xml` olarak **KOPYALANIR**, release yeniden derlenir | `G18` yokluk ayağı | derleme **BAŞARILI**, release manifestinde nitelik **GÖRÜNÜR** ⇒ `G18` **KIRMIZI**. 🔴 **Yalnız niteliği taşımak EŞDEĞER MUTANTTIR** — aapt2 `@xml/...`'i çözemez, derleme kırılır ve ölçülen şey kapı değil derleme olur. İki dosya da geri alınır, geri alma `status --porcelain` ile **ÖLÇÜLÜR** |
| M128 | §3'ün (e) adımı silinip `return ayarlar;` yazılır | `G19` | `nextCursorJson` **hayatta kalır** ⇒ `G19` **KIRMIZI** |
| M129 | §3/b'deki `ezme.isEmpty` koşulu silinir | `G19` | ezme boşken de yazma koşar ⇒ `G19` **KIRMIZI** |
| M130 | `main/AndroidManifest.xml`'in `<application>` etiketine `android:usesCleartextTraffic="true"` eklenir (derleme İSTEMEZ) | `G18` | `G18/d` **1 eşleşme** ⇒ **KIRMIZI** |
| M131 | Ürün kodundaki define anahtarı `DEV_USER_ID` → `DEV_USERID` yapılır | `G20` | `G20/a` **KIRMIZI**, `G20/b` yeşil kalır (beyan edilmiş) |
| M132 | `HttpSenkronAgi(actorId:)` çağrısı **eski** bağa (ikinci bir `yukleVeyaOlustur()` sonucuna) döndürülür | `G21` | `G21/b` **1 eşleşme** ⇒ **KIRMIZI** |
| M133 | §3/c'deki GUID kontrolü silinir | `G19` | `'onur'` sessizce kalıcılaşır, `ArgumentError` **fırlamaz** ⇒ `G19/d` **KIRMIZI** |
| M134 | §3/d'deki `gorevler` + `senkronKuyrugu` silme satırları çıkarılır | `G19` | iki tablo **dolu kalır** ⇒ `G19/a` **KIRMIZI** |
| M135 | §3/b'deki `ezme == ayarlar.devUserId` koşulu silinir (`isEmpty` kalır) | `G19` | casus çağrı sayısı **1** ⇒ `G19/c` **KIRMIZI** |

**Maliyet sınıfı beyanı (K53/3):** `M125` · `M126` · `M127` **koşan derleme** ister ⇒ **3/3 — TAVAN TAM DOLU**, bu dilimde **dördüncü derleme mutantı açılamaz**. `M130` · `M131` · `M132` **statik**, `M128` · `M129` · `M133` · `M134` · `M135` **birim testi** ⇒ **tavansız** (saniyeler sürerler).

## 6b. MUTANT BORCU

§5 envanterinde adlandırılmış **kural** yoktur (yalnız kapı vardır) ⇒ araç anlamında borçlanacak kalem yoktur. §2'nin altı pazarlıksız sınırı ise şu ölçümlere bağlanmıştır — **hiçbiri ölçüsüz bırakılmadı**:

| §2 maddesi | ölçen |
|---|---|
| 1 — release'e cleartext açılmaz | `G18/d` + `G18/e` · mutant `M130` |
| 2 — yeni araç/betik yok | kriter 5 (`status --porcelain` farkı) |
| 3 — ikinci `fromEnvironment` yok | `G21/d` |
| 4 — imleç mantığı kopyalanmaz | `M128` (kopyalayan uygulama `G19`'u geçemez) |
| 5 — ezme yokken bayt bayt aynı davranış | `G19/b` + `G19/c` casus · mutant `M135` |
| 6 — doc yorumu düzeltilir | kriter 6 (elle okunur; **beyan edilmiş sınır:** mekanik kapısı yoktur, bir yorumun *doğruluğunu* ölçen araç bu projede yok) |

## 7. ORTAMI KİM KALDIRIR (K80)

🟢 **Bu spec cihaz ya da canlı sunucu kanıtı İSTEMEZ** — kabul kriterlerinin tamamı derleme-zamanı, statik ya da birim testidir. K80'in üç adımlı ortam kaldırma maddesi bu yüzden **UYGULANMAZ**; bu bir muafiyet değil **kapsam beyanıdır**: Docker'a, port 5298'e, emülatöre ya da `adb`'ye **ihtiyaç yoktur** (açılışta ölçüldü: backend kapalı, `adb` cihaz yok — A10 bundan etkilenmez).

**Gereken araçlar ve ÇÖZÜLMÜŞ adları** *(çözülemeyen ad, sessizce atlanan adımdır — K86)*:

| araç | çağrı |
|---|---|
| Flutter | `C:\src\flutter\bin\flutter.bat` — `.bat` uzantısı **zorunlu** (Python `subprocess` PATHEXT çözmez) |
| `aapt2` | `C:\Users\gulci\AppData\Local\Android\Sdk\build-tools\<sürüm>\aapt2.exe` — `<sürüm>` **ÖLÇÜLÜR** (`dir /b …\build-tools`), **varsayılmaz**. 🔴 `aapt2`'nin `list` alt komutu **YOKTUR** (yalnız v1'de vardı) ⇒ APK içi girdi araması PowerShell `System.IO.Compression.ZipFile` ile yapılır; `unzip` bu makinede **yoktur** |
| `flutter test` | alt sürece `PROGRAMFILES(X86)=C:\Program Files (x86)` **enjekte edilir** (ölçülmüş ortam kusuru; kalkansız çöker) |
| EXIT kodu | `cmd /v:on /c "... & echo !ERRORLEVEL!"` — `%ERRORLEVEL%` **KÖRDÜR** |

🔴 **③ (gerçek cihazda uçtan uca senkron) BU SPEC'İN İÇİNDE DEĞİLDİR.** O spec kendi ortam maddesini kendisi taşıyacak ve **en az** şunları içerecektir: `docker start momentum-postgres` (healthy görülene kadar **yoklanır**, sabit `sleep` değil) · backend ayrı süreçte **`ASPNETCORE_ENVIRONMENT=Development` AÇIKÇA set edilerek** (K61: aksi hâlde `NullCurrentUser` ⇒ her istek 401) ve **dış arayüzde dinleyerek** · emülatör/cihaz `adb devices` ile doğrulanarak · **her cihazda ezmeli ilk kurulumdan ÖNCE `adb shell pm clear com.momentum.client`** (§8/4).

## 8. BEYAN EDİLMİŞ SINIRLAR (gizlenmiş sınır kabul edilmez)

1. **Cleartext'in Dart isteklerine uygulanıp uygulanmadığı BU SPEC'TE ÖLÇÜLMEZ.** Android belgesi bayrağın **best-effort** olduğunu ve **Socket API'nin onu onurlandırmasının beklenmediğini** yazar; `dart:io HttpClient` Java yığınından geçmez ⇒ **Y2 bir no-op olabilir.** ③'te HTTP yine başarısız olursa **teşhis sırası**: ① INTERNET izni (`G17`) ② sunucunun dış arayüzde dinlemesi ③ `X-Momentum-Dev-User` biçimi / 401 ④ cleartext.
2. **`G18/c` ayağının ayrı mutantı YOKTUR.** `M126` niteliği, `M127` sızmayı ölçer; kaynağın **paketlendiğini** ölçen ayak mutantsızdır — kaynağı silmek derlemeyi zaten kırar, yani **eşdeğer mutant** olurdu.
3. **`profile` varyantı A10'un kapsamı dışındadır:** INTERNET iznini `main`'den alır ama `networkSecurityConfig` **taşımaz**. ③ ölçümü `--debug` ya da `--release` ile yapılır; `--profile` ile cleartext davranışı **ÖLÇÜLMEMİŞTİR**.
4. **Ezme, `gorevler` + `senkron_kuyrugu`'nu SİLER (Onur kilidi, §3/d) ama bu yalnız EZME UYGULANDIĞINDA olur.** Ezme **hiç verilmeden** kurulan bir cihazda eski oturumun verisi **durmaya devam eder** ⇒ ③'ün spec'i her cihazda ezmeli ilk kurulumdan önce `adb shell pm clear` adımını **kabul kriteri** olarak taşımak **ZORUNDADIR**; aksi hâlde senkron kanıtı kirli tabandan ölçülür.
5. **Ezme DERLEME-ZAMANI sabittir.** Kriter 3'ün ürettiği iki APK `DEV_USER_ID` **taşımaz**; ③ için ayrıca `flutter build apk --debug --dart-define=DEV_USER_ID=<GUID>` gerekir ve **o artefakt A10 kapsamında ölçülmemiştir**. Kullanıcı değiştirmek **yeniden derleme + kurulum** ister. 🔴 `DURUM.md` §4'ün *"geliştirme modunda `devUserId` alanı"* ifadesi burada **bilinçli olarak DARALTILDI**: çalışma-zamanı bir **alan** (UI) yazılmıyor.
6. **`--dart-define=DURUM_VITRINI=true` yolunda ezme UYGULANMAZ** (`_uretimKurulumOlustur` hiç çağrılmaz) — kusur değil, sınır.
7. **Release APK hâlâ debug anahtarıyla imzalanıyor** (`app/build.gradle.kts` TODO). A10 buna **dokunmaz**.
8. **`SENKRON_SUNUCU_URL` LAN IP'sine ezilirse** backend'in dış arayüzde dinlemesi gerekir — A10 **kapsam dışı**, ③'ün işi.
9. **Bu spec TEK denetim turu gördü** (K53/1; iki bağımsız mercek, **20 ayrık bulgu / 7 ayrık bloker**, *"mimariyi değiştiren bloker YOK"*) ⇒ **ikinci kâğıt turu açılmaz**; kalan risk **koşan kodda** ölçülür.
