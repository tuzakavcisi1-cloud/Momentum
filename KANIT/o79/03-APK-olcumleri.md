# KANIT — o79 · Android APK ham ölçümleri

**17 Ağu 2026 · Onur'un Windows makinesi · Flutter 3.44.6 · `flutter build apk --release`**
Derleme Onur koştu; **ölçümü Cowork bağımsız yaptı** (APK'yı kendisi açtı, builder beyanına
güvenmedi).

## Derleme çıktısı (birebir)

```
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 2888 bytes
Running Gradle task 'assembleRelease'...                          284,4s
√ Built build\app\outputs\flutter-apk\app-release.apk (57.2MB)
```

## Artefakt

| ölçüm | değer |
|---|---|
| boyut | **59.953.214 bayt** |
| sha256 | `318f6df9ce29634803993a6309fdeb50cabbba62d14362a35f2d94ac00323d75` |
| ABI | `lib/arm64-v8a/` · `lib/armeabi-v7a/` · `lib/x86_64/` (üç ABI ⇒ boyutun sebebi) |
| `libapp.so` (arm64) | 6.685.584 bayt |

## İmza — beyan doğrulandı

`META-INF/` altında **`.RSA`/`.SF` YOK** ⇒ v1 (JAR) imzası yok, yalnız APK Signature Scheme v2/v3.
`apksigner` bu ortamda bulunmadığı için imza bloğu ayrıştırılamadı; bunun yerine sertifika
öznesi ham baytlarda arandı:

```
grep -ac 'Android Debug' app-release.apk   ->  2
strings -a app-release.apk | grep -i 'Android Debug'  ->  Android Debug1
```

⇒ **APK debug anahtarıyla imzalıdır.** README'nin beyanı (`build.gradle.kts`'teki Flutter
varsayılanı `signingConfig = signingConfigs.getByName("debug")` + `TODO`) **artefaktta da
doğrulandı** — kâğıttan değil, çıktıdan.

## dart-define'lar derlemeye girdi mi (denetim bulgusu M3'ün telefon ayağı)

`lib/arm64-v8a/libapp.so` içinde arandı:

```
deadbeef-0000-4000-8000-000000000001   ->  BULUNDU (1)
http://10.129.100.171:5298             ->  BULUNDU (2 kez)
```

⇒ Telefon, imajdaki web istemcisiyle **aynı `DEV_USER_ID`'yi** taşıyor ⇒ ikisi **aynı kullanıcı**
olacak. Bu, iki-istemcili senkron/çakışma vitrininin ön koşuluydu ve artık ölçüldü.
CI kapısı bunu yalnız web tarafında ölçebiliyor; telefon tarafı burada kapandı.

## NE ÖLÇÜLEMEDİ

1. **Telefonun sunucuya fiilen ulaşması.** APK `10.129.100.171:5298`e derlendi ama telefonun bu
   ağda olduğu ve **Windows Güvenlik Duvarı'nın 5298'e izin verdiği** doğrulanmadı.
2. **Kurulum ve çalışma.** APK cihaza kurulmadı; açılış, çevrimdışı yazım ve senkron rozetleri
   telefonda görülmedi.
3. **Çakışma çözümü iki istemcide** — aynı görevi telefon ve tarayıcıdan değiştirip rozeti görmek.
4. **İmza bloğunun tam ayrıştırması.** `apksigner` yoktu; sertifika öznesi dize aramasıyla
   doğrulandı, DER ayrıştırması yapılmadı.
