# DURUM.md — Momentum

**BİTTİ: 12/15 · kutu 2 Eyl 2026 · dilim 2/5 LİSTE BİTTİ · HEAD `e9bcb91`. AŞAMA: boşluk kapatma sürüyor.** Teslim biçimi paketlenmiş build (docker imajı + APK); yeni teslim `v1.1.0`.

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihaz Chrome'undan** (bulut tarayıcısı kanıt değil). `arsiv/` AÇILMAZ.
> **Flutter `src/client`'tan** (sınır 1). Oturum 74-84 + kapanmışlar: `arsiv/DURUM-arsiv-o85.md`.

## Kalıcı dersler (dilimden bağımsız)

🔴 **Kör kapı:** dize değil **VARLIK** · sayı değil **AD** · **ÜRÜN UCU**. Düzeltmenin yazılmış
olması indiği anlamına gelmez (sha256 yakaladı). Ortamı değil **DİKİŞİ** ölç.
🔴 **Zamanlamaya benzeyen kusurdan önce `EXPLAIN Sort Key`'e bak:** o84'te dört oturumluk "flake",
`SyncPuller`de gölgelenmiş `ORDER BY` çıktı — basamak sınırında satırlar **sessizce kayboluyordu**
ve `v1.0.1` bununla teslim edilmişti (`KANIT/o84`).
🔴 **Kapı beyanı commit ile birlikte yazılır**; **elle tetiklenen** koşumun sha'sı **run kaydından**
doğrulanır, liste satırı yanıltır (o81: `pages #8` = o78 kodu ⇒ canlı demo teslim edilen kod değildi).
🔴 **Pozitif kontrol:** boş liste her iddiayı geçirir — her "görünüyor" iddiasının yanına bir
"görünmemeli" iddiası konur.

## DİLİM 2 — LİSTE BİTTİ (19-20 Ağu)

**Kapı beyanı (cihaz Chrome, 20 Ağu 00:00):** `ci #75` · `paket #12` · `pages #13` — **üçü de
`e9bcb91`** ve yeşil, `?query=is:success` pozitif süzgeciyle ölçüldü. `pages` elle tetiklendi;
`head_sha=e9bcb91…` + `conclusion=success` **run kaydından** okundu, Pages deploy **Active**.

**Kilitler [Onur, 19 Ağu]:** Liste = sunucudaki **`Project`** (üründe "Liste", kodda/telde
`Project`; README'de beyan edildi) · **klasör KESİLDİ** (CLAUDE.md §5) · `listPos`/`order` kanalı
**AÇILMADI** · `projectId == null` = **Gelen Kutusu** (sanal satır yok) · liste silinince görevler
Gelen Kutusu'na **düşer**, silinmez.

**Sunucu kodu DEĞİŞMEDİ:** `Project` op'ları registry'den geçiyor, hydration entityType-agnostik,
`SyncPuller` owner filtresiyle indiriyor ⇒ iki cihaz aynı listeyi sunucuya dokunmadan görüyor.
Kanıt `KANIT/o85A` (canlı iki istemci + çevrimdışı) ve `KANIT/o85A2` (mutant-ispatlı K5 kapısı).

**SIRADAKİ: `IS-EMRI-o85-B`** — sunucu vitrini: `projects` materyalizasyonu + `ProjectProjection` +
`EntityMaterializer` dalı + `GET /v1/projects`. Ürünü **bloke etmez**.
Sonra **DİLİM 3 — İŞBİRLİĞİ** (24-27 Ağu, taç mücevher).
Açık (ayrı karar): `KANIT/o83D/` takipsiz · G20 testi emekli değişmezi sabitliyor ·
`docker-compose.yml:31` `DEV_USER_ID` ölü.

🔴 **ADR/spec YAZILMAZ** (İŞLEYİŞ md.4): bu dilimi bir kez **altı kâğıt kapı turu öldürdü, 30 gün**.

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin `src/client`.
   PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama çalışmaz, hover'lı bile bazen İKİ
   kez gerekir; diyalogdaki `İptal` tetiklenmez, modalı **Escape** kapatır.
3. **Kapı bütçesi ihlalde** ⇒ yeni kapı DOSYASI açılmaz (widget/birim testleri orana girmez).
   **[o81] Kalan TEK açık bulgu:** arm64 kırılması manifestle gösterildi, **gerçek arm64'te
   KOŞULMADI** — donanım yok.
6. **Pages demosunda backend yok** ⇒ satır kuyrukta kalır, rozet **"↑ Gönderiliyor"**da asılı
   durur. Senkron ayağı Pages'te ASLA ölçülemez, **pakette ölçülür**. Eşitlenmiş satır rozet
   GÖSTERMEZ (`senkronize => null`).
7. **[o79] `.github/workflows/*` yalnız `device_commit_files`'ta reddedilir; `device_bash` oraya
   YAZABİLİR** — koruma araçta, klasörde değil. Yol: korumasız yola yaz → `cp` → sha256 doğrula.
8. **`pub cache` boşalabiliyor** (`flutter pub get`).
9. **ÇAKIŞMA TESPİTİ yalnız başlık/tamamlanma:** `kanonikDize` `fields:title` + `groups:completion`
   tanır; başkasında **FIRLATIR**. Bilinmeyen `priority` çizilmez ama EZİLMEZ.
14. **Etiketlerde BÜYÜK/KÜÇÜK HARF KATLAMASI YOK** (sunucu Ordinal karşılaştırır): `İş` ≠ `iş`.
    32 karakter sınırı YALNIZ İSTEMCİ kelepçesidir.
16. **[o77] Doğal dil sınırları (kilitli):** `Yarın`/ASCII `yarin` TANINMAZ · saat başlıkta kalır ·
    yılsız `03.01` GEÇMİŞE düşer · `#İş` ile `#iş` ayrı etikettir.
18. **[o77 · o85 genişledi] `GorevDeposu.ekle` imzası** DÖRT opsiyonel alan taşır
    (`oncelik`/`sonTarih`/`etiketler`/`projeId`) ⇒ yeni sahte depo dördünü de kabul ETMEK ZORUNDA.
19. **[o77] `flutter test` `KANIT/slice-3c/02-G2/*.json`i her koşumda YENİDEN YAZAR** ⇒ o dört
    dosya commit'e GİRMEMELİ; `git add` yol belirterek yapılır.
21. **[o77] CI `istemci` işi `TZ: Europe/Istanbul` koşar**; `ekle`nin `sonTarih`i normalize EDİLMEZ.
22. 🔴 **[o77] Canlı turda Ctrl+Shift+R YAPMA.** Hard reload drift'in SharedWorker'ını öldürür:
    ekran **bomboş** kalır, **konsolda hata olmaz**. Çözüm: Chrome'u tamamen kapat–aç. Ek tuzak:
    CanvasKit canvas'ı `flt-glass-pane`in SHADOW ROOT'unda ⇒ `querySelectorAll('canvas')` GÖREMEZ.
23. **[o78 ÖLÇÜLDÜ] `'İ'.toLowerCase()` VM'de `[105]`, dart2js'te `[105, 775]`** ⇒ katlama
    tablosundan `İ` silen mutant VM'de ÖLMEZ ama WEB'de arama kopardı; test TABLOYU BİREBİR sınar.
25. **[o78 ÖLÇÜLDÜ] `hintText` hiçbir mevcut kapıya görünmez** (`Text(` yok ⇒ statik tarayıcı
    görmez; semantik düğümde label/value boş ⇒ kontrast kapısı ATLAR). TEK pin
    `test/arama_dilimi_test.dart`.
27. 🔴 **[o78 İKİNCİ KEZ ISIRDI] `dart format lib/` YASAK** — depo format-temiz DEĞİL; 10 ilgisiz
    dosyayı yeniden biçimlendirdi ve `analyze` 4 yeni uyarı verdi. Yalnız DOKUNULAN dosyada koş.
28. **[o78 KİLİT — Onur, 16 Ağu] Ekleme süzgeçleri SIFIRLAR** (arama + etiket çipi). Sıfırlama
    SENKRON ve yalnız `onEkle` ateşlenince. 🔴 **[o85] AKTİF LİSTE BUNA DAHİL DEĞİL** — liste
    süzgeç değil **BAĞLAM**tır, sıfırlanmaz; `test/liste_baglam_test.dart` ısırıyor.
29. 🔴 **[o81] `DEV_USER_ID` iki tarafta AYNI olmalı:** `docker-compose.yml:31` web istemcisini
    `deadbeef-0000-4000-8000-000000000001` ile derler; APK define'sız derlenirse **rastgele**
    kullanıcı üretir ⇒ emülatör ile tarayıcı birbirini GÖRMEZ. `SENKRON_SUNUCU_URL` = `main.dart:25`.
32. **[o85-A] `projeId`/`fields:projectId` ÇAKIŞMA TESPİTİNE GİRMEZ** — `priority`/`dueAt` ile aynı
    sınıf: `kanonikDize` çağrılmaz, `cakismaKayitlari`'na yazılmaz; LWW sessizce kazanır/kaybeder.
33. 🔴 **[o85-A ÖLÇÜLDÜ] Kanal-adı asimetrisi UYUYOR:** fractional alanlar (`pos`/`listPos`/
    `boardPos`) snapshot'ta **`scalars[]`** (`fields:$ad`), artımlıda **`order` haritası**
    (`order:$ad`) gelir — AYNI alan, İKİ `alan` dizgesi ⇒ `UzakAlanDurumu` PK'sinde iki satır.
    Bugün etkisiz; kanal açılınca o84'le AYNI SINIF sessiz-kayıp riski — **İLK ÖLÇÜLECEK yer**.
34. **[o85-A BEYAN] Liste diliminin canlı ölçümü PROTOKOL SEVİYESİNDEDİR** (`/v1/sync` HTTP,
    `KANIT/o85A/_canli_tur_o85a*.py`) — **Flutter UI'ı canlı koşturulmadı**; ekran davranışı widget
    testleriyle ölçüldü. o83-G'nin kimlik ölçümüyle aynı yöntem ve aynı sınır.
35. 🔴 **[o85 — DİLİM 3'ÜN ÖN KOŞULU] `SyncPuller` OWNER-ONLY:** `PullIncrementalAsync` yalnız
    `owner_id = @actorId` süzer, `scope_id`'ye **bakmaz**; `ScopeMembershipSource` yazılmış ama
    **çekmede kullanılmıyor**. Scope yazımı (`scope_id = projectId`, `old_scope_id`) hazır.
    İşbirliği dilimi = pull'a scope kolu + `Project.members` materyalizasyonu.
36. **[İŞLEYİŞ md.4 — o85 doğrulama sonucu]** o85-A2'de builder beyanı bağımsız doğrulandı ve
    **TUTTU**: `gorev_listesi_ekrani.dart` `f54ad06`↔`4800de7` **bayt-özdeş** (test-only iddiası),
    iki mutant ham çıktıyla düşürüldü. Dilim %100 doğrulamaya DÖNMEDİ.
