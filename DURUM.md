# DURUM.md — Momentum

**BİTTİ: 10/10 · kutu 21 Ağu 2026 · `ci #50` YEŞİL (705/705) · `pages #8` YEŞİL · özellik dilimi YOK. TESLİM AŞAMASI: paketlenmiş build = docker imajı (API + web aynı köken) + Android APK. Windows masaüstü ve iOS cihaz KAPSAM DIŞI.**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihazdaki Chrome'dan okunur** (bulut tarayıcısı kanıt değildir).
> `arsiv/` AÇILMAZ. **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Oturum 74 · 76 · 77 (özet)

**TAKVİM GÜNÜ PİNİ:** `DateTime.utc(y,m,d)`, tek nokta `GorevSatiri.takvimGunu`; `intl` **0.20.2**.
**Etiket:** `gorev_etiketleri(...)` SALT-EKLEME; tel `sets.tags.{adds,removes}`, `sets` LWW meta'ya
ASLA bağlanmaz; idempotent + değişmeli; tombstone TELE ÇIKMAZ. **Doğal dil (o77):** dört alan TEK
`WireOp` + TEK `transaction`, ayrıştırıcı SAF, 41 mutant öldü; denetim iki ürün kusuru çıkardı
(`int.parse` taşması; yıl `0000` → sınır ötesi sessiz kayıp).
**DERS (o74):** kâğıt denetimi migration'ın v1 yolunu KOŞAMAZ. **DERS (o77):** ortamı değil
**DİKİŞİ** ölç.

## Oturum 78 — başlıkta arama dilimi (KAPANDI, 10/10)

Kod bulutta yazıldı/koşuldu: `analyze --fatal-infos` temiz · **705/705** (taban 676) · **32 mutant
öldü**, tek sağkalan `dispose`. YENİ ŞEMA YOK, YENİ TEL KANALI YOK. `arama_eslestirme.dart` SAF;
katlama tablosu (`I→ı`, `İ→i`) TEK KAYNAK, ham `toLowerCase` YASAK, aksan KATLANMAZ. Süzme TEK
`where`da (çip × arama). İki bağımsız denetçi koştu, ikisi de ürün kusuru buldu.
**Canlı tur 16 Ağu (cihaz Chrome, Pages #8) beş ayak da yeşil:** `ışık` → **IŞIK yak** · boş
sonuçta "Eşleşen görev yok." + temizle · `#iş` + `deneme` = BOŞ (çarpım) · süzgeç açıkken eklenen
görev göründü · sekme kapat–aç sonrası arama sıfırlandı, veri durdu.

## Oturum 79 — teslim paketi (docker) ve KÖR KAPI dersi

Yeni: `Dockerfile` (Flutter web → .NET publish → çalışma) · `docker-compose.yml`
(postgres → migrator → api) · `docker-compose.gelistirme.yml` · `.github/workflows/paket.yml`.
Şemayı `api` değil **ayrı migrator servisi** kurar (EF bundle, çerçeve-bağımlı 34,7 MB).
**Bulutta yakalanan üç kusur:** `cirruslabs/flutter:3.44.6` **yok** (→ birinci taraf arşiv +
sha256) · yüzen `sdk:10.0` `global.json` pinini kırabilirdi (→ `10.0.302`) · `ef bundle` başlangıç
projesi **Api olamaz** (Design `PrivateAssets=all` → Infrastructure + tasarım-zamanı fabrikası).

🔴 **KÖR KAPI (bu turun asıl dersi).** Kapının ilk sürümü gövdede `flutter_bootstrap.js`
**dizesini** arıyordu; o dize `src/client/web/index.html:44` **şablonunda** zaten var. Bağımsız
denetçi `Istemci:KokDizin`e yalnız `index.html` koydu: bütün Flutter çıktısı **404** dönerken
**dört ayak da yeşil** yandı. Aynı denetim `≥3 tablo` eşiğinin yarım şemayı geçirdiğini ölçtü
(8 tablo, `GET /v1/tasks` **500**). Kapı yeniden yazıldı: **dize değil VARLIK**, **sayı değil AD**,
ve **ÜRÜN UCU**. Denetim: **3 bloker · 6 majör · 7 minör**; kapatılmayanlar §Bilinen sınırlar.
**DERS:** kapının yeşili, ölçtüğü şeyin ürün olduğunu kanıtlamaz — girdisi depoda zaten duruyorsa
kapı kördür. **İKİNCİ DERS:** düzeltmenin yazılmış olması indiği anlamına gelmez; kör kapı
düzeltmesi ilk denemede depoya inmedi, sha256 yakaladı.

## Sıradaki iş

**`paket` koşum 5 YEŞİL** (`d75cbe4`, 2 dk 43 sn) — düzeltilmiş kapı, beş ayak + migrator.
Ham ölçüm: `KANIT/o79/`. Sonra: APK üretimi
(`DEV_USER_ID=deadbeef-0000-4000-8000-000000000001`), kutu kapanışı (21 Ağu).
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
6. **Pages demosunda backend yok** ⇒ rozetler "Bu cihazda → Gönderiliyor → Çevrimdışı"ya düşer;
   "ikinci istemciye eşitlenir" ayağı Pages'te ASLA ölçülemez.
7. **Mount'a yazmanın tek yolu YERİNDE yazmaktır.** `device_commit_files` mount'a YAZAR, sha256
   birebir tutar — AMA `.github/workflows/*` **korumalıdır, reddedilir**; iş akışını Onur elle düzenler.
8. **`pub cache` boşalabiliyor** (`flutter pub get` çözer).
9. **ÇAKIŞMA TESPİTİ yalnız başlık/tamamlanma:** `kanonikDize` `fields:title` + `groups:completion`
   tanır. **Bilinmeyen `priority`** çizilmez ama EZİLMEZ.
14. **Etiketlerde BÜYÜK/KÜÇÜK HARF KATLAMASI YOK** (sunucu Ordinal karşılaştırır): `İş` ≠ `iş`.
    32 karakter sınırı YALNIZ İSTEMCİ kelepçesidir.
16. **[o77] Doğal dil sınırları (kilitli):** `Yarın`/ASCII `yarin` TANINMAZ · saat başlıkta kalır ·
    yılsız `03.01` GEÇMİŞE düşer · `#İş` ile `#iş` ayrı etikettir.
18. **[o77] `GorevDeposu.ekle` imzası** üç opsiyonel alan taşır ⇒ yeni sahte depo üçünü de kabul
    ETMEK ZORUNDADIR.
19. **[o77 ÖLÇÜLDÜ] `flutter test` `KANIT/slice-3c/02-G2/*.json`i her koşumda YENİDEN YAZAR.**
    Bu dört dosya commit'e GİRMEMELİ — `git add` yol belirterek yapılır.
21. **[o77] CI `istemci` işi `TZ: Europe/Istanbul` koşar.** `ekle`nin `sonTarih`i normalize EDİLMEZ.
22. 🔴 **[o77 ÖLÇÜLDÜ] Canlı turda Ctrl+Shift+R YAPMA.** Hard reload drift'in SharedWorker'ını
    öldürür, yeniden kurulamaz: ekran **bomboş** kalır ve **konsolda hata olmaz**. Çözüm: Chrome'u
    tamamen kapat–aç. Ek tuzak: CanvasKit canvas'ı `flt-glass-pane`in SHADOW ROOT'undadır ⇒
    `querySelectorAll('canvas')` onu GÖREMEZ.
23. **[o78 ÖLÇÜLDÜ] `'İ'.toLowerCase()` VM'de `[105]`, dart2js/Node'da `[105, 775]`** (i + U+0307)
    ⇒ katlama tablosundan `İ` girişini silen mutant **VM'de davranışla ÖLMEZ** ama WEB'de `iş`
    sorgusunu `İş görüşmesi`nden koparırdı. Test bu yüzden TABLOYU BİREBİR sınar (o77 dersinin aynısı).
24. **[o78 ÖLÇÜLDÜ] Katlama VM↔web ayrışması:** `U+0000–U+024F` aralığında ayrışan **SIFIR**;
    aralık dışında 465 kod noktası farklı katlanır. Ürün dili Türkçe ⇒ bilinçli sınır.
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
