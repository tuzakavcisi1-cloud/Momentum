# DURUM.md — Momentum

**BİTTİ: 10/15 · kutu 2 Eyl 2026 · dilim 1/5 KİMLİK · HEAD `c706a97`. AŞAMA: `v1.0.1` TESLİM EDİLDİ, boşluk kapatma başladı.** Teslim biçimi paketlenmiş build (docker imajı + APK); yeni teslim `v1.1.0`.

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihaz Chrome'undan** (bulut tarayıcısı kanıt değil).
> `arsiv/` AÇILMAZ. **Flutter `src/client`'tan koşulur** (sınır 1).

## Oturum 74–80 (özet; ayrıntı `arsiv/` + README)

**Pinler:** takvim günü `DateTime.utc(y,m,d)`, tek nokta `GorevSatiri.takvimGunu`, `intl` **0.20.2** ·
`gorev_etiketleri` SALT-EKLEME, tombstone TELE ÇIKMAZ · doğal dil dört alan TEK `WireOp` + TEK
`transaction`, ayrıştırıcı SAF · `arama_eslestirme.dart` SAF, katlama tablosu TEK KAYNAK.
**Paket:** `Dockerfile` + compose (postgres → ayrı migrator → api) + `paket.yml`; gerçek makinede
ölçüldü (17 Ağu): `crossOriginIsolated=true` · drift **opfsLocks** · çift yönlü senkron iki gerçek
istemcide. Test 708/708, `analyze` 0.
**Dersler:** kâğıt denetimi migration'ın v1 yolunu KOŞAMAZ · ortamı değil **DİKİŞİ** ölç ·
🔴 kör kapı: **dize değil VARLIK · sayı değil AD · ÜRÜN UCU** (düzeltmenin yazılmış olması indiği
anlamına gelmez — sha256 yakaladı).

## Sıradaki iş — DİLİM 1: KİMLİK (18-21 Ağu)

**`v1.0.1` teslim edildi (17 Ağu)** → `a332b25`, APK sha256 tuttu; kapılar `ci #70`=`39e0699` · `paket #9`·`pages #10`=`a332b25`. o82 README okuması: 7 bulgu düzeltildi (ayrıntı README).

🔴 **[Onur kilidi, 18 Ağu] BOŞLUKLAR KAPATILACAK.** ÖDEV kilidine göre teslim eksikti: §4(a)
parite **6/10** (liste · proje · tekrar · hatırlatıcı yok) · §4(b) taç mücevher **1/2** (işbirliği
vitrini yok) · §6.1 kimlik dilimi **teslim edilmedi**. Sıra **kimlik → liste(+proje klasörü) →
işbirliği → tekrar → hatırlatıcı**; liste, işbirliğinin **ön koşuludur** (ÖDEV §8(5): paylaşım
liste/proje düzeyinde).

**[18 Ağu · o83-F + o83-G] KİMLİK DİLİMİ CANLIDA YEŞİL.** HEAD `09e2720`. Çekme sırası kusuru
kapandı; c ayağı **pozitif kontrolle** yeniden ölçüldü (`KANIT/o83G`): `a_kendi_gorur`=True(1/10) ·
`b_kendi_gorur`=True(1/10) · `a_gorur_b_yi`=False (A'nın listesi **dolu**) · `b_gorur_a_yi`=False.
`verify.ps1` **EXIT 0** (142/142, 0 uyarı, CVE temiz).
🔴 **BİTTİ İLAN EDİLMEDİ** — sınır 30 gereği kapı beyanı commit ile birlikte yazılır: `09e2720`
**push edilip** `ci`/`paket`/`pages` bu commit'le yeşil görülmeden kapanmaz. Push Onur'da.
Açık temizlik: (a) `KANIT/o83/08-canli-tur.txt` o83-G koşumuyla **üzerine yazıldı** (o83'ün kırmızı
kaydı yalnız git'te, `8110133`) — geri alınacak, betiğin çıktı yolu parametreleştirilecek ·
(b) `b_gorur_a_yi` B kendi görevini eklemeden önce ölçülüyor, sonraya alınacak (2 satır).

🔴 **ADR/spec YAZILMAZ** (İŞLEYİŞ md.4): bu dilimi bir kez **altı kâğıt kapı turu öldürdü, 30 gün**.

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin `src/client`.
   PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama çalışmaz, hover'lı bile bazen İKİ
   kez gerekir; diyalogdaki `İptal` tetiklenmez, modalı **Escape** kapatır.
3. **Kapı bütçesi ihlalde** ⇒ yeni kapı DOSYASI açılmaz (widget/birim testleri orana girmez).
   **[o81] Kalan TEK açık bulgu:** arm64 kırılması manifestle gösterildi, **gerçek arm64'te
   KOŞULMADI** (donanım yok). Ötekiler kapandı: `aspnet:10.0` pini iş emrinde · yatay yerleşim
   ÖLÇÜLDÜ (temiz) · TalkBack **kapsam dışı** yazıldı (README §Beyan edilmiş sınırlar).
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
31. **[o83-D/E/F + o84 · KAPANDI 18 Ağu] "flake" değildi:** `SyncPuller`de `SELECT commit_xid::text
    … ORDER BY commit_xid` — cast'ın çıktı adı sütunu **gölgeliyordu** ⇒ sıra METİN, `WHERE` SAYISAL;
    basamak sınırında satırlar **sessizce kayboluyordu** (canlı: 510'un 500'ü teslim). `v1.0.1`
    bununla teslim edildi. Kanıt `KANIT/o84` + `KANIT/o83F`; `Cursor_correctness_…` 3/3 ⇒ ayrı flake
    YOK. **Ders: zamanlamaya benzeyen kusurdan önce `EXPLAIN Sort Key`'e bak.**
