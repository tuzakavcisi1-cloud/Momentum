# DURUM.md — Momentum

**BİTTİ: 10/10 · kutu 21 Ağu 2026 · özellik dilimi YOK · HEAD `ce630ec`. AŞAMA: TESLİM** = docker imajı (API + web aynı köken) + Android APK. Windows masaüstü ve iOS cihaz KAPSAM DIŞI.

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihazdaki Chrome'dan okunur** (bulut tarayıcısı kanıt değildir).
> `arsiv/` AÇILMAZ. **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Oturum 74–78 (özet; ayrıntı `arsiv/`)

**Takvim günü pini:** `DateTime.utc(y,m,d)`, tek nokta `GorevSatiri.takvimGunu`; `intl` **0.20.2**.
**Etiket:** `gorev_etiketleri(...)` SALT-EKLEME; `sets` LWW meta'ya ASLA bağlanmaz; tombstone TELE ÇIKMAZ.
**Doğal dil (o77):** dört alan TEK `WireOp` + TEK `transaction`; ayrıştırıcı SAF; 41 mutant öldü.
**Arama (o78):** `arama_eslestirme.dart` SAF; katlama tablosu (`I→ı`, `İ→i`) TEK KAYNAK, ham
`toLowerCase` YASAK; süzme TEK `where`da; 32 mutant öldü; canlı tur beş ayak yeşil.
**Dersler:** kâğıt denetimi migration'ın v1 yolunu KOŞAMAZ (o74) · ortamı değil **DİKİŞİ** ölç (o77).

## Oturum 79 — docker paketi ve KÖR KAPI dersi

`Dockerfile` · `docker-compose.yml` (postgres → migrator → api) · `paket.yml`. Şemayı `api` DEĞİL
**ayrı migrator servisi** kurar. Bulutta yakalanan üç kusur: `cirruslabs/flutter:3.44.6` yok (→
birinci taraf arşiv + sha256) · yüzen `sdk:10.0` `global.json` pinini kırabilirdi (→ `10.0.302`) ·
`ef bundle` başlangıç projesi Api olamaz (→ Infrastructure + tasarım-zamanı fabrikası).
🔴 **KÖR KAPI:** kapı gövdede `flutter_bootstrap.js` **dizesini** arıyordu; o dize
`src/client/web/index.html:44` şablonunda zaten var ⇒ bütün Flutter çıktısı **404** dönerken **dört
ayak da yeşil** yandı. Kapı yeniden yazıldı: **dize değil VARLIK · sayı değil AD · ÜRÜN UCU**.
Denetim 3 bloker · 6 majör · 7 minör; kapatılmayanlar §sınır 3. **İkinci ders:** düzeltmenin
yazılmış olması indiği anlamına gelmez (sha256 yakaladı). **Üçüncü ders:** `curl … | grep -q`
YAZMA — grep boruyu kapatır, curl 23 düşer, `pipefail` **yalancı kırmızı** yakar.

## Oturum 80 — KAPANDI (canlı)

Boş senkron rozeti satırın yarısını yutuyordu; düzeltildi ve **gerçek telefonda** doğrulandı:
başlığın çizilen genişliği **~225 → ~450 px** (`KANIT/o80/01`). 3 mutant öldü, A11Y-7 regresyonu
bulunup kapatıldı, `analyze` 0, test **708/708**.
**Paket gerçek makinede ölçüldü** (17 Ağu, Windows + Docker Desktop): ilk derleme **27 dk** ·
`crossOriginIsolated=true` · drift **opfsLocks** (Pages'te `sharedIndexedDb`) · tarayıcıda yazılan
görev **PostgreSQL'e ulaştı**. **Çift yönlü senkron iki gerçek istemcide kanıtlandı** (masaüstü
tarayıcı ↔ telefon). O APK 59.953.214 bayt / üç ABI / **debug anahtarıyla imzalı**, ama
`SENKRON_SUNUCU_URL` Onur'un LAN IP'sine gömülü ⇒ **değerlendiricide çalışmaz**.

## Sıradaki iş — GitHub Release (kutu kapanışı 21 Ağu)

**[Onur kilidi 17 Ağu]** Release APK'sı **`http://10.0.2.2:5298`** (emülatör varsayılanı) ile,
**Onur'un makinesinde elle** derlenir — yeni ürün kodu YOK. Release notuna: sha256 · debug imza
beyanı · `DEV_USER_ID` uyarısı · tek-komut docker bölümü · ölçülmüş kanıt özeti · KAPSAM DIŞI
listesi. Sonra README son okuma.

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin `src/client`.
   PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama çalışmaz, hover'lı bile bazen İKİ
   kez gerekir; diyalogdaki `İptal` tetiklenmez, modalı **Escape** kapatır.
3. **Kapı bütçesi ihlalde** ⇒ yeni kapı DOSYASI açılmaz (widget/birim testleri orana girmez).
   **[o79 AÇIK KALAN denetim bulguları]** `aspnet:10.0` yüzen etiket (SDK pinliyken) · arm64
   kırılması manifestle gösterildi ama **gerçek arm64'te KOŞULMADI** · yatay (landscape) konum
   telefonda denenmedi · A11Y-7 duyurusu TalkBack ile doğrulanmadı.
   (APK ve iki-istemci vitrini o80'de ÖLÇÜLDÜ.)
4. **Kimlik `devUserId` ile taşınıyor** ⇒ gerçek zamanlı işbirliği gösterilemez (kapsam dışı).
6. **Pages demosunda backend yok** ⇒ rozetler "Çevrimdışı"ya düşer; senkron ayağı Pages'te ASLA
   ölçülemez. **Pakette ölçülür** (o79 canlı tur). Eşitlenmiş satır rozet GÖSTERMEZ (`senkronize
   => null`) — boş rozet alanı senkronize demektir.
7. **[o79 ÖLÇÜLDÜ] `.github/workflows/*` yalnız `device_commit_files`'ta reddedilir;
   `device_bash` oraya YAZABİLİR.** Koruma araçta, klasörde değil. Yol: korumasız yola yaz →
   cihazda `cp` → sha256 doğrula. **[Onur kilidi 16 Ağu: bu yol serbest.]**
8. **`pub cache` boşalabiliyor** (`flutter pub get`).
9. **ÇAKIŞMA TESPİTİ yalnız başlık/tamamlanma:** `kanonikDize` `fields:title` + `groups:completion`
   tanır. **Bilinmeyen `priority`** çizilmez ama EZİLMEZ.
14. **Etiketlerde BÜYÜK/KÜÇÜK HARF KATLAMASI YOK** (sunucu Ordinal karşılaştırır): `İş` ≠ `iş`.
    32 karakter sınırı YALNIZ İSTEMCİ kelepçesidir.
16. **[o77] Doğal dil sınırları (kilitli):** `Yarın`/ASCII `yarin` TANINMAZ · saat başlıkta kalır ·
    yılsız `03.01` GEÇMİŞE düşer · `#İş` ile `#iş` ayrı etikettir.
18. **[o77] `GorevDeposu.ekle` imzası** üç opsiyonel alan taşır ⇒ yeni sahte depo üçünü de kabul
    ETMEK ZORUNDADIR.
19. **[o77] `flutter test` `KANIT/slice-3c/02-G2/*.json`i her koşumda YENİDEN YAZAR** ⇒ o dört
    dosya commit'e GİRMEMELİ; `git add` yol belirterek yapılır.
21. **[o77] CI `istemci` işi `TZ: Europe/Istanbul` koşar**; `ekle`nin `sonTarih`i normalize EDİLMEZ.
22. 🔴 **[o77 ÖLÇÜLDÜ] Canlı turda Ctrl+Shift+R YAPMA.** Hard reload drift'in SharedWorker'ını
    öldürür, yeniden kurulamaz: ekran **bomboş** kalır ve **konsolda hata olmaz**. Çözüm: Chrome'u
    tamamen kapat–aç. Ek tuzak: CanvasKit canvas'ı `flt-glass-pane`in SHADOW ROOT'undadır ⇒
    `querySelectorAll('canvas')` onu GÖREMEZ.
23. **[o78 ÖLÇÜLDÜ] `'İ'.toLowerCase()` VM'de `[105]`, dart2js'te `[105, 775]`** ⇒ katlama
    tablosundan `İ` silen mutant VM'de ÖLMEZ ama WEB'de arama kopardı; test TABLOYU BİREBİR sınar.
25. **[o78 ÖLÇÜLDÜ] `hintText` hiçbir mevcut kapıya görünmez** (`Text(` yok ⇒ statik tarayıcı
    görmez; semantik düğümde label/value boş ⇒ kontrast kapısı ATLAR). TEK pin
    `test/arama_dilimi_test.dart`. İpucu bu yüzden **'Ara'**ya kısaltıldı (320 dp'de kırpılıyordu).
26. **[o78 ÖLÇÜLDÜ] `dispose()` mutantı SAĞ KALIYOR** (flutter_test leak-tracking kapalı) —
    kapsanmayan sınıf, kapı yalanı değil.
27. 🔴 **[o78 İKİNCİ KEZ ISIRDI] `dart format lib/` YASAK** — depo format-temiz DEĞİL; 10 ilgisiz
    dosyayı yeniden biçimlendirdi ve `analyze` 4 yeni uyarı verdi. Yalnız DOKUNULAN dosyada koş.
28. **[o78 KİLİT — Onur, 16 Ağu] Ekleme süzgeçleri SIFIRLAR.** Süzgeç (arama ya da çip) açıkken
    eklenen görev listeye giriyor ama EKRANDA GÖRÜNMÜYORDU (ölçüldü: depoda 2 görev / ekranda 1
    satır / bildirim 0). Sıfırlama SENKRON ve yalnız `onEkle` ateşlenince.
29. 🔴 **[o81 ÖLÇÜLDÜ] `DEV_USER_ID` iki tarafta AYNI olmalı.** `docker-compose.yml:31` web
    istemcisini `deadbeef-0000-4000-8000-000000000001` ile derler; APK bu define verilmeden
    derlenirse **rastgele** kullanıcı üretir ⇒ emülatör ile tarayıcı birbirini GÖRMEZ.
    `SENKRON_SUNUCU_URL` varsayılanı `main.dart:25` = `http://10.0.2.2:5298`.
30. 🔴 **[o81 §5 DOĞRULAMA] DEVİR'in "üç kapı da son kodla koştu" beyanı TUTMADI** (cihaz Chrome,
    17 Ağu): `ci #64`=`ce630ec` ✔ · `paket #8`=`84ff84c` (fark tek KANIT dosyası, ürün kodu değil) ·
    `pages #8`=**o78 kodu** ⇒ canlı Pages demosu teslim edilen kod DEĞİLDİ. Kapı beyanı bundan
    sonra **commit ile birlikte** yazılır.
