# DURUM.md — Momentum

**BİTTİ: 10/15 · kutu 2 Eyl 2026 · dilim 1/5 KİMLİK · HEAD `39e0699`. AŞAMA: `v1.0.1` TESLİM EDİLDİ, boşluk kapatma başladı.** Teslim biçimi paketlenmiş build (docker imajı + APK); yeni teslim `v1.1.0`.

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihazdaki Chrome'dan okunur** (bulut tarayıcısı kanıt değildir).
> `arsiv/` AÇILMAZ. **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Oturum 74–78 (özet; ayrıntı `arsiv/`)

**Takvim günü pini:** `DateTime.utc(y,m,d)`, tek nokta `GorevSatiri.takvimGunu`; `intl` **0.20.2**.
**Etiket:** `gorev_etiketleri(...)` SALT-EKLEME; `sets` LWW meta'ya ASLA bağlanmaz; tombstone TELE ÇIKMAZ.
**Doğal dil (o77):** dört alan TEK `WireOp` + TEK `transaction`; ayrıştırıcı SAF; 41 mutant öldü.
**Arama (o78):** `arama_eslestirme.dart` SAF; katlama tablosu TEK KAYNAK, ham `toLowerCase`
YASAK; süzme TEK `where`da; 32 mutant öldü.
**Dersler:** kâğıt denetimi migration'ın v1 yolunu KOŞAMAZ (o74) · ortamı değil **DİKİŞİ** ölç (o77).

## Oturum 79-80 (özet; ayrıntı README + `arsiv/`)

Docker paketi: `Dockerfile` · compose (postgres → **ayrı migrator** → api) · `paket.yml`.
🔴 **KÖR KAPI dersi:** kapı gövdede `flutter_bootstrap.js` **dizesini** arıyordu, o dize şablonda
zaten vardı ⇒ tüm Flutter çıktısı **404**'ken dört ayak yeşil yandı. Kural: **dize değil VARLIK ·
sayı değil AD · ÜRÜN UCU**. İkinci ders: düzeltmenin yazılmış olması indiği anlamına gelmez
(sha256 yakaladı). Üçüncü: `curl … | grep -q` YAZMA — `pipefail` **yalancı kırmızı** yakar.
Paket **gerçek makinede** ölçüldü (17 Ağu): 27 dk · `crossOriginIsolated=true` · drift
**opfsLocks** · tarayıcıda yazılan görev **PostgreSQL'e ulaştı** · **çift yönlü senkron iki gerçek
istemcide** (masaüstü ↔ telefon). Test **708/708**, `analyze` 0.

## Sıradaki iş — DİLİM 1: KİMLİK (18-21 Ağu)

**`v1.0.1` teslim edildi (17 Ağu)** → `a332b25`, **Latest**, indirilen APK'nın sha256'sı birebir
tuttu. Kapılar `ci #70`=`39e0699` · `paket #9`·`pages #10`=`a332b25`. o82: README son okuması,
7 bulgu düzeltildi (Releases kutusu `v1.0.1`e döndü · KANIT 1.355 · About paneli dolduruldu).

🔴 **[Onur kilidi, 18 Ağu] BOŞLUKLAR KAPATILACAK.** ÖDEV kilidine göre teslim eksikti: §4(a)
parite **6/10** (liste · proje · tekrar · hatırlatıcı yok) · §4(b) taç mücevher **1/2** (işbirliği
vitrini yok) · §6.1 kimlik dilimi **teslim edilmedi**. Sıra **kimlik → liste(+proje klasörü) →
işbirliği → tekrar → hatırlatıcı**; liste, işbirliğinin **ön koşuludur** (ÖDEV §8(5): paylaşım
liste/proje düzeyinde).

**Şimdi:** `IS-EMRI-o83-kimlik.md` → Claude Code kodlar → Cowork canlıda ölçer.
🔴 **ADR/spec YAZILMAZ** (İŞLEYİŞ md.4): bu dilimi bir kez **altı kâğıt kapı turu öldürdü, 30 gün**.
Canlı ölçüt: iki hesap açılır, biri ötekinin görevini **göremez**; çevrimdışı yazılan satır token
yenilendikten sonra **kaybolmadan** sunucuya ulaşır.

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin `src/client`.
   PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama çalışmaz, hover'lı bile bazen İKİ
   kez gerekir; diyalogdaki `İptal` tetiklenmez, modalı **Escape** kapatır.
3. **Kapı bütçesi ihlalde** ⇒ yeni kapı DOSYASI açılmaz (widget/birim testleri orana girmez).
   **[o81] Kalan TEK açık bulgu:** arm64 kırılması manifestle gösterildi, **gerçek arm64'te
   KOŞULMADI** (donanım yok). Ötekiler kapandı: `aspnet:10.0` pini iş emrinde · yatay yerleşim
   ÖLÇÜLDÜ (temiz) · TalkBack **kapsam dışı** yazıldı (README §Beyan edilmiş sınırlar).
4. **Kimlik `devUserId` ile taşınıyor** ⇒ gerçek zamanlı işbirliği gösterilemez (kapsam dışı).
6. **Pages demosunda backend yok** ⇒ satır kuyrukta kalır, rozet **"↑ Gönderiliyor"**da asılı
   durur (o81 canlı ölçüm; "Çevrimdışı" diyen eski satır YANLIŞTI). Senkron ayağı Pages'te ASLA
   ölçülemez, **pakette ölçülür**. Eşitlenmiş satır rozet GÖSTERMEZ (`senkronize => null`).
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
