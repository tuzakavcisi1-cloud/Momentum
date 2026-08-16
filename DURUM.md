# DURUM.md — Momentum

**BİTTİ: 10/10 · kutu 21 Ağu 2026 · `ci #50` YEŞİL (705/705) · `pages #8` YEŞİL · özellik dilimi YOK. TESLİM AŞAMASI: paketlenmiş build = docker imajı (API + web aynı köken) + Android APK. Windows masaüstü ve iOS cihaz KAPSAM DIŞI.**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihazdaki Chrome'dan okunur** (bulut tarayıcısı kanıt değildir).
> `arsiv/` AÇILMAZ. **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Oturum 74 · 76 · 77 (özet)

**TAKVİM GÜNÜ PİNİ:** `DateTime.utc(y,m,d)`, tek nokta `GorevSatiri.takvimGunu`; `intl` **0.20.2**.
**Etiket:** `gorev_etiketleri(...)` SALT-EKLEME; `sets` LWW meta'ya ASLA bağlanmaz; idempotent +
değişmeli; tombstone TELE ÇIKMAZ. **Doğal dil (o77):** dört alan TEK `WireOp` + TEK `transaction`,
ayrıştırıcı SAF, 41 mutant öldü. **DERS (o74):** kâğıt denetimi migration'ın v1 yolunu KOŞAMAZ.
**DERS (o77):** ortamı değil **DİKİŞİ** ölç.

## Oturum 78 — başlıkta arama dilimi (KAPANDI, 10/10)

**705/705**, 32 mutant öldü (tek sağkalan `dispose`). YENİ ŞEMA/TEL YOK. `arama_eslestirme.dart`
SAF; katlama tablosu (`I→ı`, `İ→i`) TEK KAYNAK, ham `toLowerCase` YASAK, aksan KATLANMAZ. Süzme
TEK `where`da (çip × arama). **Canlı tur (Pages #8) beş ayak yeşil:** `ışık` → **IŞIK yak** · boş
sonuçta temizle · `#iş`+`deneme` = BOŞ (çarpım) · süzgeç açıkken eklenen görev göründü · sekme
kapat–aç sonrası arama sıfırlandı.

## Oturum 79 — teslim paketi (docker) ve KÖR KAPI dersi

Yeni: `Dockerfile` · `docker-compose.yml` (postgres → migrator → api) ·
`docker-compose.gelistirme.yml` · `.github/workflows/paket.yml`. Şemayı `api` değil **ayrı
migrator servisi** kurar (EF bundle, 34,7 MB). **Bulutta yakalanan üç kusur:**
`cirruslabs/flutter:3.44.6` **yok** (→ birinci taraf arşiv + sha256) · yüzen `sdk:10.0`
`global.json` pinini kırabilirdi (→ `10.0.302`) · `ef bundle` başlangıç projesi **Api olamaz**
(Design `PrivateAssets=all` → Infrastructure + tasarım-zamanı fabrikası).

🔴 **KÖR KAPI (bu turun asıl dersi).** İlk sürüm gövdede `flutter_bootstrap.js` **dizesini**
arıyordu; o dize `src/client/web/index.html:44` **şablonunda** zaten var. Denetçi `Istemci:KokDizin`e
yalnız `index.html` koydu: bütün Flutter çıktısı **404** dönerken **dört ayak da yeşil** yandı.
`≥3 tablo` eşiği de yarım şemayı geçiriyordu (8 tablo, `GET /v1/tasks` **500**). Kapı yeniden
yazıldı: **dize değil VARLIK**, **sayı değil AD**, **ÜRÜN UCU**. Denetim: **3 bloker · 6 majör ·
7 minör**; kapatılmayanlar §Bilinen sınırlar.
**DERS:** kapının yeşili, ölçtüğü şeyin ürün olduğunu kanıtlamaz — girdisi depoda zaten duruyorsa
kapı kördür. **İKİNCİ DERS:** düzeltmenin yazılmış olması indiği anlamına gelmez (kör kapı
düzeltmesi ilk denemede depoya inmedi, sha256 yakaladı). **ÜÇÜNCÜ DERS — YALANCI KIRMIZI:**
`curl … | grep -q` yazıldı; grep eşleşmeyi BULUNCA boruyu kapatıyor, curl `23` ile düşüyor,
`pipefail` bunu kırmızıya çeviriyor ⇒ dize BULUNDUĞU HÂLDE ayak kırmızı yandı (koşum 6). Önce
dosyaya indir, sonra ara. Kör kapı yalancı yeşildi; bu aynası.

## Sıradaki iş

**`paket` koşum 7 YEŞİL** (`0902658`). **PAKET GERÇEK MAKİNEDE CANLI ÖLÇÜLDÜ** (17 Ağu, Windows +
Docker Desktop): ilk derleme **27 dk** · `crossOriginIsolated=true` · drift **opfsLocks** (Pages'te
`sharedIndexedDb`) · tarayıcıda yazılan görev **PostgreSQL'e ulaştı** (`GET /v1/tasks` 200).
Ham ölçüm: `KANIT/o79/`. Sıradaki: APK (derleniyor), kutu kapanışı (21 Ağu).
Canlı turda **Ctrl+Shift+R YAPMA** (sınır 22). Demoda iki ölçüm artefaktı: `IŞIK yak`, `Sut al`.

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin `src/client`.
   PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama çalışmaz, hover'lı bile bazen İKİ
   kez gerekir; diyalogdaki `İptal` tetiklenmez, modalı **Escape** kapatır.
3. **Kapı bütçesi ihlalde** ⇒ yeni kapı DOSYASI açılmaz (widget/birim testleri orana girmez).
   **[o79 AÇIK KALAN denetim bulguları]** `aspnet:10.0` yüzen etiket (SDK pinliyken) · arm64
   kırılması manifestle gösterildi ama gerçek arm64'te KOŞULMADI · APK ve iki-istemci vitrini
   fiilen ölçülmedi · tarayıcı `crossOriginIsolated` ölçümü kapının göremediği yer.
4. **Kimlik `devUserId` ile taşınıyor** ⇒ gerçek zamanlı işbirliği gösterilemez (kapsam dışı).
6. **Pages demosunda backend yok** ⇒ rozetler "Çevrimdışı"ya düşer; senkron ayağı Pages'te ASLA
   ölçülemez. **Pakette ölçülür** (o79 canlı tur). Eşitlenmiş satır rozet GÖSTERMEZ (`senkronize
   => null`) — boş rozet alanı senkronize demektir.
7. **[o79 ÖLÇÜLDÜ — eski madde YANLIŞTI] `.github/workflows/*` yalnız `device_commit_files`'ta
   reddedilir; `device_bash` oraya YAZABİLİR.** Koruma araçta, klasörde değil. Yol: korumasız
   yola yaz → cihazda `cp` → sha256 doğrula. **[Onur kilidi 16 Ağu: bu yol serbest.]**
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
    Katlama ayrışması `U+0000–U+024F` içinde SIFIR, dışında 465 kod noktası (bilinçli sınır).
25. **[o78 ÖLÇÜLDÜ] `hintText` hiçbir mevcut kapıya görünmez** (`Text(` yok ⇒ statik tarayıcı
    görmez; semantik düğümde label/value boş ⇒ kontrast kapısı ATLAR). TEK pin
    `test/arama_dilimi_test.dart`. İpucu bu yüzden **'Ara'**ya kısaltıldı (320 dp'de kırpılıyordu).
26. **[o78 ÖLÇÜLDÜ] `dispose()` mutantı SAĞ KALIYOR** (flutter_test leak-tracking kapalı) — kapsanmayan
    sınıf, kapı yalanı değil. Yeni kapı kodu YAZILMADI (bütçe ihlalde).
27. 🔴 **[o78 İKİNCİ KEZ ISIRDI] `dart format lib/` YASAK** — depo format-temiz DEĞİL; 10 ilgisiz
    dosyayı yeniden biçimlendirdi ve `analyze` 4 yeni uyarı verdi. Yalnız DOKUNULAN dosyada koş.
28. **[o78 KİLİT — Onur, 16 Ağu] Ekleme süzgeçleri SIFIRLAR.** Süzgeç (arama ya da çip) açıkken
    eklenen görev listeye giriyor ama EKRANDA GÖRÜNMÜYORDU ve hiçbir geri bildirim yoktu (ölçüldü:
    depoda 2 görev / ekranda 1 satır / bildirim 0). Sıfırlama SENKRON ve yalnız `onEkle` ateşlenince
    (geçersiz girdi süzgeci düşürmez). Bu, çipin o76'dan gelen kusurunu da kapattı.
