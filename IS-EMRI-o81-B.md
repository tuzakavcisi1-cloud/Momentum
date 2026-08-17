# İŞ EMRİ — o81/B · uygulama adı ve şablon kalıntısı

**Kime:** Claude Code · **Kimden:** Cowork (ürün kodu YAZMAZ — CLAUDE.md §1)
**Tarih:** 17 Ağustos 2026 · **Kilit:** Onur, 17 Ağu — *düzelt + APK yenile, etiket `v1.0.0` kalsın*
**İlişki:** `IS-EMRI-o81.md` (aspnet pini) ile **bağımsızdır**; sırası önemsiz, ikisi ayrı commit olabilir.

---

## 1. Sorun (ölçüldü, 17 Ağu)

`flutter create` klasör adıyla (`client`) koşulmuş ve etiketler hiç özelleştirilmemiş:

| yer | şu an |
|---|---|
| `src/client/android/app/src/main/AndroidManifest.xml:8` | `android:label="client"` |
| `src/client/ios/Runner/Info.plist` | `CFBundleDisplayName` = `Client` · `CFBundleName` = `client` |
| `src/client/web/index.html:26` | `apple-mobile-web-app-title` content=`client` |
| `src/client/pubspec.yaml` | `description: "A new Flutter project."` |

⇒ Teslim edilen APK, değerlendiricinin telefonunda **`client`** diye görünüyor; `pubspec` şablondan
çıkmamış izlenimi veriyor. Web sekme başlığı ve `manifest.json` **zaten `Momentum`** — onlar doğru.

## 2. Yapılacak — dört satır

1. `AndroidManifest.xml:8` → `android:label="Momentum"`
2. `Info.plist` → `CFBundleDisplayName` = `Momentum` · `CFBundleName` = `Momentum`
3. `web/index.html:26` → `content="Momentum"`
4. `pubspec.yaml` → `description: "Momentum istemcisi: cevrimdisi-oncelikli senkron ve cakisma
   cozumu vitrinli cok platformlu Flutter uygulamasi."`
   *(ASCII bilinçli — pubspec'te kodlama sürprizi istemiyoruz.)*

## 3. 🔴 DOKUNMA — sert sınır

`pubspec.yaml`'daki **`name: client` DEĞİŞMEZ.** O, Dart paket adıdır; değişirse bütün
`package:client/…` import'ları kırılır ve bu iş emrinin kapsamı 4 satırdan yüzlerce satıra çıkar.
`applicationId`/`namespace` (`com.momentum.client`) de **değişmez** — uygulama kimliği değişirse
telefondaki mevcut kurulum ayrı uygulama olur.

## 4. Kabul ölçütü — ölçülecek, beyanla geçilmez

1. `src/client` dizininden: `flutter analyze` **0 sorun** · `flutter test` **708/708**.
   (🔴 Repo kökünden koşma — sınır 1. PowerShell 5.1'de `&&` yok, `;` yaz.)
2. `dart format` **KOŞMA** — depo format-temiz değil (sınır 27). Yalnız dokunduğun satır.
3. **ÜRÜN UCU — kaynakta yazması yetmez.** APK yeniden derlendikten sonra, derlenen arşivin
   içinden ölçülecek:
   `unzip -p app-release.apk AndroidManifest.xml | strings | Select-String Momentum` → **eşleşmeli**
   ve aynı taramada `client` **etiket değeri olarak geçmemeli** (paket adı `com.momentum.client`
   geçecektir, o normaldir — aranan şey **etiket**tir).
   *(o79 kör kapı dersi: dize değil VARLIK çekilir, ürün ucundan sorulur.)*
4. `ci` iş akışı **yeşil**.
5. Ham çıktı `KANIT/o81/03-uygulama-adi.txt`.

## 5. APK'yı SEN derlemiyorsun

Sürüm APK'sını **Onur** derler (kilit: kendi makinesinde, iki `--dart-define` ile). Senin işin
kaynağı düzeltmek ve `analyze`/`test` yeşilini ölçmek. Derleme komutu Onur'da:

```
flutter build apk --release --dart-define=SENKRON_SUNUCU_URL=http://10.0.2.2:5298 --dart-define=DEV_USER_ID=deadbeef-0000-4000-8000-000000000001
```

## 6. Sınırlar — dokunma

- `README.md` ve `DURUM.md`'ye **DOKUNMA** (Cowork yazıyor, çakışma çıkmasın).
- `git add -A` **YASAK**, yol belirt. `KANIT/slice-3c/02-G2/*.json` commit'e **girmez** (sınır 19).
- **Push Onur'da.** Commit mesajı ASCII, çift tırnak yok.
- Yeni kapı DOSYASI açma (bütçe ihlalde, sınır 3).

## 7. Bu iş düşerse

`flutter test` 708'in altına düşerse ya da APK'da etiket hâlâ `client` çıkarsa: **geri al**, ölçtüğünü
yaz, Cowork'e dön. Uydurma etiketle ilerleme.
