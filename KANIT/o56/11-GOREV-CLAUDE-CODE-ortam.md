# GÖREV (Claude Code) — SS2 kriter 8 ORTAMINI KALDIR ve AÇIK BIRAK

> Oturum 56 · Cowork yazdı · spec kaynağı: `GOREV_CLAUDE_CODE/GOREV-SS2-cakisma-cozumu.md` §7/8
> (satır 469–486). **Spec satır 486 birebir:** *"Ortamı Claude Code kaldırır, Cowork yalnız ölçer (K80)."*

## KIRMIZI ÇİZGİLER (pazarlıksız)
1. **Senaryoyu KOŞMA.** `B1`/`A1` yazımı, çakışma, *"benimkini tut"* — hepsi **Cowork'ün** işi (K26:
   üreten ≠ denetleyen). Sen yalnız ortamı kaldırır ve **rapor edersin**.
2. **Hiçbir kaynak dosyaya yazma, commit atma, `git add` yapma.** Bu görev **ürün kodu üretmez**.
3. **Güvenlik duvarına dokunma.** Telefon LAN ile değil **USB tüneliyle** bağlanacak (Onur kilitledi).
4. Bitirince **DUR ve BIRAK**: backend penceresi, emülatör ve telefon **AÇIK KALIR**.

## ÖLÇÜLMÜŞ TABAN (Cowork oturum 56'da ölçtü — varsayma, bunlar doğrulanmış)
- `momentum-postgres` → **Up (healthy)** · `netstat :5298` → **BOŞ** (backend yok) · `adb devices` → **BOŞ**
- Boş RAM **1,75 GiB** / toplam 7,80 GiB ⇒ **Gradle derlemeleri emülatör AÇILMADAN ÖNCE yapılır.**
- `main.dart:23` → `SENKRON_SUNUCU_URL` dart-define, varsayılan `http://10.0.2.2:5298`
- `main.dart:31` → `DEV_USER_ID` dart-define (A10/Y3: *iki cihazı aynı kullanıcı yapmanın yolu*)
- `debug/res/xml/network_security_config.xml` → `<base-config cleartextTrafficPermitted="true" />`
- `applicationId = com.momentum.client` · aktivite `.MainActivity`
- Tek AVD: **`tuzak_api34`** (`hw.ramSize=2G`, `hw.gpu.enabled=no`)

## ADIM 0 — ÖN KOŞUL (ÖLÇ, varsayma)
```
docker ps
C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe devices
```
- `momentum-postgres` **healthy** değilse `docker start momentum-postgres` → healthy görene kadar **yokla**.
- Telefon `unauthorized` görünüyorsa **DUR**, Onur'a söyle (telefonda RSA onayı gerekir).
- Telefonun **seri numarasını** not al; aşağıda `<TEL>` diye geçiyor.

## ADIM 1 — BACKEND (ayrı pencere, açık kalır)
```powershell
cd C:\dev\Momentum\src\backend\Momentum.Api
$env:ASPNETCORE_ENVIRONMENT="Development"
$env:ASPNETCORE_URLS="http://0.0.0.0:5298"
$env:ConnectionStrings__Momentum="Host=localhost;Port=5432;Database=momentum;Username=momentum;Password=momentum_dev"
dotnet run
```
🔴 **HAZIR OLDUĞU PORTLA ÖLÇÜLMEZ** (`ORTAM.md`: bağlantı dizesi verilmezse host DB'siz açılır ve
port **yine dinler**). Zorunlu üçlü — hazır betikle koş:
```
python C:\dev\Momentum\KANIT\A11\_backend_dogrula.py
```
⇒ `/health/live` **200** · `/health/ready` **200** · `POST /v1/sync` başlıksız **401** →
`X-Momentum-Dev-User` ile **200**. `clientId` **geçerli GUID** olmak zorunda (oturum 50'de dize
gönderilince uç 500 döndü; kusur **probun**du). **Ham çıktıyı sakla.**

## ADIM 2 — İKİ APK (emülatör AÇILMADAN ÖNCE; sıra önemli)
```powershell
cd C:\dev\Momentum\src\client
# B = EMÜLATÖR
C:\src\flutter\bin\flutter.bat build apk --debug --dart-define=DEV_USER_ID=11111111-1111-1111-1111-111111111111 --dart-define=SENKRON_SUNUCU_URL=http://10.0.2.2:5298
copy build\app\outputs\flutter-apk\app-debug.apk C:\dev\Momentum\KANIT\o56\apk-B-emulator.apk
# A = TELEFON (USB tüneli üzerinden loopback)
C:\src\flutter\bin\flutter.bat build apk --debug --dart-define=DEV_USER_ID=11111111-1111-1111-1111-111111111111 --dart-define=SENKRON_SUNUCU_URL=http://127.0.0.1:5298
copy build\app\outputs\flutter-apk\app-debug.apk C:\dev\Momentum\KANIT\o56\apk-A-telefon.apk
```
🔴 **`DEV_USER_ID` İKİSİNDE DE AYNI.** Farklı olursa iki cihaz iki ayrı kullanıcıdır ve **çakışma
hiç doğmaz** — kriter 8 sessizce yalancı bir yeşil verir.
🔴 İki APK'nın **URL'si bilerek farklı**: B'nin çevrimdışına alınması `svc wifi/data disable` ile
yapılacak; bir `reverse` tüneli bu kesintiyi **atlatır** ⇒ B **gerçek ağı** kullanmak zorunda.
🟡 `flutter` bu makinede `.bat` (K86). Gradle `PROGRAMFILES(X86)` hatası verirse değişkeni enjekte et.

## ADIM 3 — EMÜLATÖR
```
C:\src\flutter\bin\flutter.bat emulators --launch tuzak_api34
```
Sonra **doğrula** (K80'in üçüncü adımı; v1'de eksikti): `adb devices` ⇒ `emulator-5554  device`.
Açılışı **sabit beklemeyle değil yoklayarak** ölç.

## ADIM 4 — KURULUM (her cihazda `pm clear` ÖNCE ve SONRA — A10 §8/4)
```
adb -s emulator-5554 shell pm clear com.momentum.client
adb -s emulator-5554 install -r C:\dev\Momentum\KANIT\o56\apk-B-emulator.apk
adb -s emulator-5554 shell pm clear com.momentum.client
adb -s <TEL> shell pm clear com.momentum.client
adb -s <TEL> install -r C:\dev\Momentum\KANIT\o56\apk-A-telefon.apk
adb -s <TEL> shell pm clear com.momentum.client
```
(İlk `pm clear` uygulama kurulu değilse hata verir — **sorun değil**, devam et.)

## ADIM 5 — TELEFON İÇİN USB TÜNELİ (güvenlik duvarına dokunmadan)
```
adb -s <TEL> reverse tcp:5298 tcp:5298
adb -s <TEL> reverse --list
```
⇒ liste `tcp:5298 tcp:5298` göstermeli. **Ham çıktıyı sakla.**
🔴 **Emülatöre `reverse` KURMA.**

## ADIM 6 — İKİ UYGULAMAYI BAŞLAT ve BIRAK
```
adb -s emulator-5554 shell am start -n com.momentum.client/.MainActivity
adb -s <TEL> shell am start -n com.momentum.client/.MainActivity
```
İkisi de çizilene kadar **yokla** (K86: `uiautomator dump` uygulama çizilmeden çağrılırsa
*"null root node"* verir ve **dosya oluşmaz**; çıktıda `"dumped to"` görünene kadar tavanlı yokla).

## ADIM 7 — RAPOR ET ve DUR
Bana şunları **ham** ver: ① telefon seri no ② `_backend_dogrula.py` çıktısı ③ iki APK'nın yolu+bayt
④ `adb devices` ⑤ `adb -s <TEL> reverse --list` ⑥ iki uygulamanın çizildiğinin kanıtı.
**Senaryoyu KOŞMA. Backend/emülatör/telefon AÇIK KALSIN.** Devamı Cowork'ün.
