# ADR 0003 — Kimlik Çekirdeği (`slice-3c-auth`, 1/2)

- **Durum:** 🟡 **TASLAK v4 — KİLİTLİ DEĞİL.** v3'e **üçüncü** bağımsız kapı koştu ve hüküm yine **KİLİTLENEMEZ** oldu (**9 bloker · ~20 majör**, dört bağımsız denetçi; red-team A turunun 20 blokerinin 4'ünü çürüttü, 9'unu majöre indirdi, 2 yeni bloker getirdi). Bu sürüm o **9 blokeri ve ~20 majörü** kapatır. **K13-a yürürlükte: "bloker sıfırlanana kadar tur; tur sayısı raporlanır, sınırlanmaz."** *Üreten ≠ denetleyen: bu ADR'yi yazan el onu onaylayamaz.* Kilit Onur'dadır.
- **Tarih:** 2026-07-25 (v4) · v3: 2026-07-25, arşiv: `arsiv/0003-kimlik-cekirdegi-TASLAK-v3-2026-07-25.md` · v2: `arsiv/0003-kimlik-cekirdegi-TASLAK-v2-2026-07-25.md` · v1: `arsiv/0003-kimlik-ve-yetkilendirme-TASLAK-v1-2026-07-25.md`
- **Denetim izi:** v3'ün tam denetim raporu `KANIT/adr-0003/kapi-3-denetim-raporu.md` (227 satır); v2'ninki `KANIT/adr-0003/kapi-2-denetim-raporu.md` (171 satır). Bu belgedeki her kapatma o raporlardaki bir bulguya çıpalıdır.
- **Karar verenler:** Onur (sahip) · Cowork (mimar) · bağımsız denetçi ajanlar (kapı bekliyor)
- **⚠ DİLİM ADI DEĞİŞTİ [K14-h]:** `slice-3a-auth` → **`slice-3c-auth`**. *Gerekçe:* `slice-3a` **zaten vardır** (ADR 0002 K2-I3 = sunucu materyalizasyonu + okuma API'si; `KANIT/slice-3a/` klasörü dolu) ve bu proje "aynı numara iki anlam" hatasını daha önce iki kez yedi. **Bilinen ve kabul edilen kusur:** kimlik dilimi `slice-3b`'den **önce** koşar ⇒ harf sırası kronolojiyi yalanlar; "3 ailesi = istemciyi ayaklandıran işler" anlamı korunduğu için kabul edildi. *Reddedilenler:* `slice-4-auth` · `slice-auth` (numarasız).
- **Kapsam (K11-h ile daraltıldı):** kullanıcı varlığı · parola + **girdi politikası** · token yaşam döngüsü · token doğrulama parametreleri · `ICurrentUser` sözleşmesi · sırlar + **dev bootstrap** · kimlik uçları + kaba kuvvet · **istemci token/kuyruk sözleşmesi** · **port envanteri**.
- **Kapsam DIŞI (ADR 0004'e taşındı):** owner EF global query filter + `IgnoreQueryFilters` yasağı · push-authz · pull-authz · `outbox_messages.owner_id` · SignalR hub kimliği · `clientId → principal` **ve onun zorlama kuralı (D-7)**.
- **Bağımlılık:** ADR 0001 (§C, §D, §G, §H) · ADR 0002 (K2-E3, K2-E5, K2-A4, §6/7).

> **Onur'un kilitlediği çatallar:** K8-a…K8-d · K9 · **K11-c/d/e/f/g/h** · K12-d (aynı origin) · **K13-a (K6 tavanı kaldırıldı)** · **K14-a…K14-h** · **K15-a/K15-b** · **K16-a/K16-b/K16-c** (son beşi bu sürümün çatalları — §0.2).
>
> **AÇIK ÇATAL DURUMU — v3'ÜN BEYANI DA KUSURLUYDU ve bu sürümde DÜZELTİLMİŞTİR.** v3 *"bugün açık çatal yoktur"* dedi; denetim **K14-i'nin kendi cümlesiyle** (*"bu bir Onur kilidi DEĞİLDİR ve kilit turunda gözden geçirilebilir"*) çeliştiğini bulguladı (Ma-16). **v4'te K14-i artık açık değildir: K16-b ile Onur tarafından kilitlenmiş, sayıları değişmiş ve gerekçesi yeniden yazılmıştır.** Bu belgede bugün açık çatal yoktur; **ama bu cümle bir DENETİM SONUCU DEĞİL, bir YAZAR İDDİASIDIR** — v2 ve v3'ün aynı cümlesi iki kez denetimde çürütüldüğü için burada böyle etiketlenmiştir ve üçüncü kez çürütülebilir.
>
> **⚠ BU SÜRÜMÜN OKUYUCUSUNA:** v4 üç yerde **v3'ün bir iddiasını geri çekiyor** (kararı değil, iddiayı): (1) `RemoteIpAddress`'in gerçek istemci IP'si olduğu — **ölçümle yanlışlandı** (K3-L4/K15-b); (2) NIST çizgisinin ≥10 olduğu — **kaynaktan yanlışlandı** (K3-B6/K16-a); (3) *"DB'de token'ın ham değeri hiç bulunmaz"* — **K15-a ile 60 saniyelik, şifreli ve adlandırılmış bir istisna kazandı** (K3-C2/C6). Üçü de §0.4'te toplu olarak listelenmiştir; **geri çekilen bir iddia, sessizce düzeltilen bir iddiadan daha ucuzdur.**

---

## 0. v3 → v4 değişim kaydı (denetim izi)

> **v1→v2 ve v2→v3 değişim kayıtları arşivdedir** (`arsiv/0003-…-TASLAK-v2/v3-2026-07-25.md`, §0). Burada yalnız **v3'e koşan üçüncü kapının** bulguları izlenir. Kaynak: `KANIT/adr-0003/kapi-3-denetim-raporu.md`.

### 0.1 — DOKUZ BLOKERİN NEREDE KAPANDIĞI

| # | bloker (rapordaki adıyla) | sınıf | v4'te ne oldu | nerede |
|---|---|---|---|---|
| **B1** | K14-a **inşa edilemez** — kayıtlı halefin ham değeri sunucuda yok (K3-C2 + şema + M12 üçü birden kapatıyor) | inşa edilemeyen mekanizma | **KARAR K15-a:** `refresh_tokens.successor_secret_enc` — halefin ham değeri **kök anahtardan türetilmiş bir alt anahtarla şifreli**, `consumed_at + 60 sn` sonra `NULL`. K14-a'nın semantiği **aynen** korunur | **K3-C2**, **K3-C6(3)**, K3-I4, **M40**, M12 |
| **B2** | `RemoteIpAddress` beyanı, belgenin **zorunlu kıldığı** dağıtımda yanlış — gerçek koşuyla ölçüldü | kör kapı (ölçüldü) | **KARAR K15-b:** iddia **geri çekilir**, K14-e **durur**; kontrol 1 **küresel** bir tavan diye adlandırılır, ölçümüyle birlikte yazılır | **K3-L4**, K3-J2, K3-J5, K3-J6, §6 Risk #5 |
| **B3** | `F5 = /refresh` × tek partition × istemci sözleşmesinde `429` dalı yok ⇒ demo ortasında tanımsız durum | ODEV §2'yi vuruyor, kapısız | **KARAR K16-b:** `/refresh` **ayrı ve gevşek** politikaya alındı (120/5 dk) + istemciye **üçüncü dal** (`429`/`5xx` = geçici) | **K3-J2**, **K3-L8(4)**, **M-L9** |
| **B4** | **M8b öldürülemez** — mutasyon konteynerin giriş betiğinde, seviye `B` | kör kapı | Seviye sözlüğüne **KON** eklendi; M8b **KON**'a taşındı; anahtar dosyasının **kodlaması pinlendi** (Base64, çözülmüş 32 bayt) | **§3 seviye sözlüğü**, K3-I2/I3, **M8b** |
| **B5** | **M28 kör** — JSON kodlayıcısı `+` → `+` (≈%49 flaky) **ve** token kodlaması hiç pinlenmemiş | kör kapı (ölçüldü) | **`Base64Url` (dolgusuz) pinlendi** — tek kararla M12 **ve** M28 kapanır; M28'in sinyali **özyinelemeli JSON taraması + kaçışlı biçim** ile güçlendirildi | **K3-C2**, **M12**, **M28** |
| **B6** | **M33 ayırt edici değil** (`MapFallbackToFile` kendi `UseStaticFiles`'ını kurar) + baseline yok (`wwwroot/index.html` bu dilimde yok) | kör kapı + ölü tuzak | **M33 → M33a/M33b** diye bölündü; test fixture'ı (`wwwroot/index.html` + **dosya-benzeri** varlık) K3-J1'de şart koşuldu; K3-J1'in **gerekçesi düzeltildi** | **K3-J1**, **M33a/M33b** |
| **B7** | Kontrol 2 (e-posta penceresi) **tümüyle kapısız** ve §3.1'de de yok ⇒ K14-f kanıtsız | tamlık iddiasının ihlali | **M41** yazıldı — iki ayaklı (e-posta penceresi ısırır **ve** aynı IP'den farklı e-postalar `429` **almaz**; R2'yi de korur) | **K3-J2(2)**, **M41** |
| **B8** | CSRF HMAC anahtarının **varlığı/kaynağı/bootstrap'ı** hiçbir yerde yazılmamış | kararlaştırılmamış çatal + gizlenmiş sınır | **KARAR K16-c:** **tek kök anahtar + HKDF-SHA256** ile üç amaç-bağlı alt anahtar; fail-fast ve bootstrap **tek anahtarı** kapsar; restart vaadi üçü için birden geçerli | **K3-I1/I2/I3/I4**, **M42** |
| **B9** | `X-Client-Kind`'ın **OKUMA yönü** yazılmamış ⇒ güvenlik modunu istemci seçiyor | kararlaştırılmamış çatal | K3-L10'a **üçüncü PAZARLIKSIZ kural** (girdi kanalı **yalnız** başlıktan seçilir) + **M43**; başlığın kendisinin bir CSRF savunması olduğu **lehte** yazıldı | **K3-L10**, **M43** |

### 0.2 — ONUR'UN BU SÜRÜMDE KİLİTLEDİĞİ BEŞ ÇATAL (K15-a/b + K16-a/b/c)

| kilit | karar | reddedilenler [adlandırılmış] |
|---|---|---|
| **K15-a** | **B1 → şifreli halef kolonu.** `successor_secret_enc`, `consumed_at + 60 sn` sonra `NULL`. K14-a'nın semantiği aynen korunur (yeni token üretilmez · pencere `T1.consumed_at`'e çıpalı · `expires_at` devralınır) | dal (c)'nin yeniden yazımı (*"yeni token üretilir ama halef olarak kaydedilir"* — şema değişmez ama *"yeni döndürme yapılmaz"* cümlesi düşer, M29/M30'un kill sinyalleri baştan yazılır, ailede satır birikir) · **K14-a'nın geri alınması** (telafisiz adlandırılmış sınır; RFC 9700 maliyet sayar ama çevrimdışı vitrininin ortasında yeniden giriş üretir — K14-a tam da bunun için seçilmişti) |
| **K15-b** | **B2 → iddia geri çekilir, sınır adlandırılır; K14-e DURUR.** Tek konteyner + proxy yok kararı korunur (CORS ve `SameSite` gerekçeleri ölçümle sağlam); yalnız **yanlış çıkan ayak** geri çekilir | **reverse-proxy'ye dönüş** (gerçek IP gelir ama `UseForwardedHeaders` + `KnownProxies` + M11/M23'ün `X-Forwarded-For` testlerine taşınması geri gelir; dağıtım tek birim olmaktan çıkar) · **IP anahtarını tamamen bırakmak** (en sade ama **R2'nin kapısı olan M23'ün konusu kalmaz**) |
| **K16-a** | **Ma-9 → parola asgari uzunluk 10 → 15.** NIST SP 800-63B-4 birebir *"SHALL … single-factor … minimum of **15** characters"*. Bedeli adlandırılır ve **telafi edilir**: README'de hazır demo hesabı + seed | 10'da kalıp adlandırılmış sapma yazmak (doktrine uygun ama denetçi *"neden sapıyorsun"*u yeniden sorar) · 12 karakter (hiçbir standartta karşılığı yok ⇒ keyfi, savunması en zayıf) |
| **K16-b** | **B2+B3 → `/refresh` ayrı politikaya alınır, tavanlar yükselir.** `/login`+`/register` **30/5 dk** · `/refresh` **120/5 dk** · `/logout`+`/logout-all` **60/5 dk**. **K14-i'nin yerini alır** ve artık bir **Onur kilididir** | yalnız `/refresh`'i ayırıp sayıları korumak (10 küresel tavan iki değerlendirici aynı anda kayıt+giriş denerken hâlâ ısırır) · 60/240/120 (kontrol 1'in DoS anlamı sembolikleşir) |
| **K16-c** | **B8 + K15-a → tek kök anahtar (`Momentum:MasterKey`) + HKDF-SHA256 ile üç amaç-bağlı alt anahtar.** K15-a'nın *"üçüncü bir sır doğmasın"* kısıtı sağlanır, anahtar-amaç ayrımı korunur | **üç ayrı anahtar** (en açık ayrım ama üç fail-fast + üç bootstrap + üç mutant ve K15-a'nın kısıtının reddi) · **iki anahtar** / CSRF ile şifreleme aynı sırrı paylaşır (anahtar-amaç ayrımını kısmen bozar) |

> **K16-d — MUTANT NUMARALANDIRMA PİNİ DEĞİŞTİ [COWORK KARARI, Onur onayına açık — dürüstçe etiketleniyor].**
> v4'ün kapatması gereken bulgular **dokuz gerçekten yeni mekanizma kapısı** doğurdu. Karar: **gerçek ikinci-ayaklar harfle** yazılır (`M33a/M33b`), **yeni mekanizmalar `M40`'tan numaralanır**, ve **ADR 0004'ün yeni mutantları artık `M50`'den başlar** — v3'ün `M40` pini **geçersizdir**. *Gerekçe:* 0004 henüz **hiçbir numarayı tüketmedi** (M2·M3·M9·M10·M20 rezervdir, yenileri adsızdı) ⇒ pini taşımak bedelsizdir; alternatif (her şeyi harfe sıkıştırmak) **kontrol 2 penceresi** gibi kendi başına birer mekanizma olan kapıları sahte bir "ikinci ayak" gibi gösterirdi.

### 0.3 — MAJÖRLERİN NEREDE KAPANDIĞI

| majör | v4'te |
|---|---|
| **Ma-1** M39 ↔ K14-a ölü tuzağı (paralel `/refresh`'te ikisi de `200` alabilir) | M39'un kill sinyali yeniden yazıldı: *"iki yanıt da `200` ise dönen token'lar **özdeştir** ve ailenin satır sayısı **tam olarak 1** artmıştır"* |
| **Ma-2** K3-C6(2)'nin dal **önceliği** yazılmamış (`consumed_at` + `revoked_at` birlikte dolu olabilir) | **(a)→(b)→(c)→(d) sırası PAZARLIKSIZ** yazıldı + **M44** |
| **Ma-3** `OnRejected` kontrol 2/3'ü kapsamıyor (ölçüldü) ⇒ `limit=="email"/"concurrency"` üretilemez | **K3-J4 ikiye ayrıldı:** middleware ayağı + **handler ayağı**. `ConcurrencyLease`'in `RetryAfter` **taşımadığı ölçüldü** ⇒ koşulluluk kalktı, §6 Risk #12 **kapandı** |
| **Ma-4** M37 ölü tuzağı — `DefaultProblemDetailsWriter` **koşulsuz** `traceId` yazıyor | K3-B5'e karar satırı + M37'nin sinyali ***"`traceId` alanı hariç* bayt bayt aynı"* diye pinlendi |
| **Ma-5** M21'in `Trim` ayağı ölü — K3-B6 format doğrulamayı normalizasyondan önce koyuyordu | **K3-A2'nin sırası yeniden yazıldı:** `Trim()` → **format doğrulama** → NFC → `ToLowerInvariant`; doğrulayıcı **pinlendi** (K3-B6) ⇒ M21'in her iki ayağı da yaşıyor |
| **Ma-6** §3.1'in tamlık iddiası yanlış (dokuz kapısız-ve-beyansız kalem) | Kapıya bağlananlar: **M43** (K3-L10'un başlık-yok ve native-çerez-yok ayakları) · **M41** (kontrol 2) · **M35**'in ikinci ayağı (aile bağı) · **M36**'nın çoklu assert'i (`HttpOnly`/`SameSite`/`Max-Age`) · **M44** (dal (a) + öncelik) · **M31**'in dördüncü ayağı (e-posta 254+format). **Kapısız kalan ikisi AÇIKÇA BEYAN EDİLDİ:** K3-B4'ün sabit-zaman özelliği (zamanlama testi kırılgan ⇒ ölü tuzak olurdu) · K3-J6'nın NAT bedeli. §2-M'nin `ICurrentUser` kuralı **M32b** ile kapandı. §3.1 baştan yazıldı |
| **Ma-7** §3.1'in `iss`/`aud`/`RequireSignedTokens` muafiyeti kendi kendini yalanlıyor | **Muafiyet KALDIRILDI** — `ValidateIssuer/Audience` benim yapılandırmam olduğu kabul edildi; **M48** yazıldı |
| **Ma-8** Bloker #15 yarım — §2-M yeni NetArchTest kuralları getiriyor ama §3.1 *"yalnız `Konscious.*` yenidir"* diyor | **ADR 0001 K-H1 birebir alıntılandı** (v3 turunda ölçülemedi; **v4 turunda ölçüldü — dosya diskte ve takipli**). Hangi kural yeni, hangisi mevcut ailenin uzantısı **tek tek yazıldı**; yeni kuralların hepsi mutantlandı: **M32 · M32b · M32c** |
| **Ma-9** NIST atfı yanlış (SHALL 15, belge ≥10 diyor) | **K16-a: 15 karakter** + NIST-4 birebir alıntı + M31'e **sınır-değer** ayağı (14 ⇒ `400`, 15 ⇒ `201`) |
| **Ma-10** Halef `INSERT`'ünün **atomikliği** yazılmamış | K3-C6(1)'e *"`INSERT` ve `UPDATE` **tek transaction**"* + sıra + **M45** |
| **Ma-11** PAZARLIKSIZ middleware sırasında **`UseRateLimiter` yok** | Sıraya eklendi, **yeri gerekçelendirildi** (statik dosyalardan **sonra**, `UseRouting`'den **sonra**) + **M46** |
| **Ma-12** `/logout` yenileme çerezini silmiyor (`__Host-mrt` `Path=/` gereği 30 gün tele çıkmaya devam eder) | K3-L3'ün yaşam döngüsüne eklendi + **M47** |
| **Ma-13** M19'un seviyesi (`D`) yanlış — `ValidateOnBuild` çalışma-zamanı host-build doğrulamasıdır | Seviye **`TS`**'e alındı; **koşum biçimi pinlendi** (`WebApplicationFactory`) — bkz. **§3.2 koşum sözleşmesi** |
| **Ma-14** M24'ün *"gerçek `AddJwtBearer` boru hattı"* pini yok | Pinlendi (sahte `TestAuthHandler` **yasak**, §3.2) |
| **Ma-15** M22'nin farklı-IP önkoşulu ADR'de yazılmamış | Önkoşul yazıldı (test-only middleware, `UseRateLimiter`'dan **önce**) |
| **Ma-16** Dağınık kalemler | `alg`'ın **tek statüsü** (hijyen) üç yerde eşitlendi · K3-J6 sayacının **ayrı** olduğu yazıldı · `/logout-all` ve `/register`'ın `X-Client-Kind` statüsü netleşti · M4'ün iki ayağı **iki commit'e** ayrıldı · M6b'nin mutasyon kapsamı daraltıldı · M30'un *"pencere İÇİNDE"* koşulu pinlendi · M35 negatif iddiaya karşı korundu · M32'nin mutasyon biçimi pinlendi (**gerçek tip kullanımı**, kullanılmayan `using` değil) · M23'ün ifadesi K16-b sonrası güncellendi · **M-L5'in web ayağı `DART-WEB` seviyesine** alındı · **K14-i çelişkisi K16-b ile kapandı** · §3'ün numara sözleşmesi **M-L8/M-L9'u da sayıyor** |

### 0.4 — v4'ÜN GERİ ÇEKTİĞİ İDDİALAR [DÜRÜSTLÜK — kararlar değil, İDDİALAR]

| geri çekilen iddia | nerede yazılıydı | neden düştü | kararın kendisi ne oldu |
|---|---|---|---|
| *"`RemoteIpAddress` **GERÇEK** istemci IP'sidir ⇒ `UseForwardedHeaders` hiç gerekmez"* | K3-L4 (v3) | **Gerçek koşu, Onur'un makinesi:** `localhost` · `127.0.0.1` · LAN IP'sinin **üçünde de** konteyner `172.17.0.1` (köprü ağ geçidi) gördü | **K14-e DURUYOR** (K15-b). Yalnız gerekçenin bu ayağı geri çekildi; kontrol 1 artık **küresel tavan** diye adlandırılıyor |
| *"NIST çizgisi ≥10 karakterdir"* | K3-B6, §5, §6 (v3) | **NIST SP 800-63B-4 birebir:** tek faktör için `SHALL` **15** (MFA bileşeni 8) | **Politika değişti: 15** (K16-a). Karmaşıklık-yok ve ≤128 ayakları **doğruydu, duruyor** |
| *"Yenileme token'ının ham değeri sunucuda hiç bulunmaz"* | K3-C2, M12 (v3) | K14-a'nın *"kayıtlı halef aynen döndürülür"* kuralı **bu iddiayla inşa edilemezdi** (B1) | **60 saniyelik, şifreli, adlandırılmış istisna** (K15-a). M12 bu istisnayla **çelişmeyecek** biçimde yeniden yazıldı; yeni risk §6'ya eklendi |
| *"§3.1'in `iss`/`aud`/`RequireSignedTokens` satırları çerçevenin kendi doğrulamasıdır"* | §3.1 (v3) | `ValidateIssuer=false` **benim kodumdaki tek satırlık yapılandırmadır**, `ClockSkew` ile aynı sınıf | Muafiyet **kaldırıldı**, **M48** yazıldı (Ma-7) |
| *"`docs/ADR/` yalnız `0003`'ü içeriyor ⇒ 0001 alıntısı yapılamaz"* | kapı-3 raporu §5 | **v4 turunda ana oturumda ölçüldü:** `0001-genel-mimari.md` (14.137 bayt) ve `0002-senkron-mekanigi.md` (31.402 bayt) diskte ve **git-takipli** | **Ma-8 kapatıldı** — K-H1 birebir alıntılandı (§2-M) |

> **⚠ ETİKET EMEKLİLİĞİ (v2'den devralındı, hâlâ yürürlükte):** v1'in `K3-E*` · `K3-F*` · `K3-G*` · `K3-H*` etiketleri **emeklidir**; ADR 0004 aynı konuları `K4-*` ile yeniden yayımlar. Bir gelecek oturum `K3-E1` görürse **v1 arşivine** bakıyordur.

---

## 1. Bağlam

Bugüne kadar Momentum'un backend'i **kimliksiz** çalıştı. Bu iki ADR'de sessiz bırakılmadı, **adlandırıldı** — ve v1 denetimi sayımın eksik olduğunu ortaya çıkardı: borç **dört değil BEŞTİR**.

| pin | ertelenmiş gereksinim | kaynak (birebir) | nerede kapanır |
|---|---|---|---|
| **K-D5** | `ICurrentUser` impl + owner query-filter | `0001` §D: *"`ICurrentUser` portu (Application) slice-1'de arayüz olarak tanımlanır; implementasyonu + owner query-filter kimlik dilimiyle kodlanır."* | **sözleşme + impl: 0003 (§2-D)** · filtre: **0004** |
| **M-G** | push-authz | `0002` K2-E3: *"ingest, her op için 'actor bu entity'yi **yazabilir mi**' kontrolü yapmalı. Mekanizma auth diliminde."* | **0004** |
| **K2-E3** | pull-authz | `0002` K2-E3: *"`changes` yalnız actor'ın görebildiği entity'lerle sınırlı"* + tombstone muafiyeti | **0004** |
| **M-C** | `clientId → principal` | `0002` §6/7: *"`clientId` kimlik-doğrulaması ertelenmiş… auth diliminde aktive edilecek"* | **0004 (D-6 + D-7)** |
| **B4** | `outbox_messages.owner_id` doğrulanmamış | `PROJE_HAFIZA:145` AÇIK BULGU C | **0004** |

**Bu dilim bir özellik değil, bir ŞEMA kararıdır.** Çevrimdışı-öncelikli Flutter istemcisinde dört soru Drift şemasını ve depo katmanını belirler: *"bu yerel satır kimin"* · *"token nerede duruyor"* · *"401 gelince kuyruktaki yazımlar ne oluyor"* · *"çıkışta yerel DB'ye ne oluyor"*. v1 yalnız birincisini karara bağlamıştı; v2 kalan üçünü §2-L'de kapattı; **v3 §2-L'ye bir beşinci soruyu ekledi: *"ağ yokken yerel DB hangi kimlikle açılır"*** — **v4 ise ALTINCISINI ekliyor: *"sunucu geçici olarak reddederse (`429`) istemci hangi duruma geçer"*** (B3; ODEV §4(b)-2'nin iki eşzamanlı kullanıcısı bunu demonun ortasında tetikliyordu) (bloker #10 — üç kararın birleşiminin ürettiği, hiçbirinin tek başına görünmediği bir şema sonucu).

**Ayrıca bir güvenlik yüzeyi kapanır.** Bugün `WireOp.ActorId` **istemci-beyanlıdır** ve doğrulanmış actor push yoluna hiç girmez. Auth olmadığı için sömürülemez; **auth gelince sömürülebilir hâle gelir.** Bu belge kimliği üretir, **ADR 0004 onu yetki kararına bağlar** — ikisi birlikte kapatır, tek başına hiçbiri kapatmaz.

**Neden iki belge?** K11-h'nin gerekçesi *"her belge küçük ⇒ tek turda geçme şansı yüksek"*ti. **Bu beklenti iki kez tutmadı** (v2 = v1 × 1,8 ve 15 bloker taşıdı) ve K13-a ile **tavan kaldırıldı**. Bölünme kararı yine de duruyor, ama artık gerekçesi *"tek turda geçsin"* değil, **konu sınırının gerçekten orada olmasıdır**: v2 denetiminde *"0003/0004 bölünme sınırı sağlam — sınırda kararsız kalmış kimlik-çekirdeği maddesi bulunamadı"* diye ölçüldü.

---
## 2. Karar

### A. Kimlik modeli

**K3-A1 — `User` entity, asgari PII [kırmızı çizgi #2].** Alanlar: `id` (UUIDv7, `Guid.CreateVersion7()`, K-E1) · `email` (kullanıcının yazdığı hâl, gösterim) · `email_normalized` (eşsizlik/arama anahtarı) · `password_hash` · `created_at`/`updated_at` (yalnız `TimeProvider`, K-C5) · `security_stamp` (**bugün ölü alan — K3-C8**). **YOK:** ad, soyad, telefon, doğum tarihi, profil fotoğrafı, IP geçmişi, son giriş zamanı. Görev sahipliği `owner_id` çıpasıyla kurulur (K-C1); kullanıcı adı gösterimi işbirliği dilimine aittir.

**K3-A2 — Normalizasyon: `Trim` → FORMAT DOĞRULAMA → NFC → `ToLowerInvariant` + `COLLATE "C"` unique index. [PAZARLIKSIZ]**
Sıra bağlayıcıdır ve dört adımın **dördü de** zorunludur:
1. **`Trim()`** — baştaki/sondaki boşluk (v1'de yoktu; **M21**).
2. **Format doğrulama** (K3-B6'nın kuralları) — **`Trim()`'den SONRA, normalizasyondan ÖNCE.**
3. **Unicode NFC** (`string.Normalize(NormalizationForm.FormC)`) — birleştirilmiş vs ayrık aksan (`é` = U+00E9 vs `e`+U+0301) aynı baytlara iner.
4. **`ToLowerInvariant()`** — ve **yalnız bu**.

> **🔴 v3'ÜN SIRASI M21'İN BİR AYAĞINI ÖLDÜRÜYORDU — DÜZELTİLİYOR [Ma-5].**
> v3'te K3-B6 format doğrulamayı *"normalizasyondan **önce**"* koyuyordu; K3-A2'nin 1. adımı (`Trim`) da normalizasyonun içindeydi ⇒ sıra fiilen **format → Trim** oluyordu ⇒ `" a@x.com"` daha `Trim` görmeden `400` alıyordu ⇒ M21'in *"`\" a@x.com\"` ile `\"a@x.com\"` **aynı hesaba düşer**"* ayağı **kurulamaz** hâle geliyordu (bir **ölü tuzak**: baseline'da kırmızı doğar). **v2'nin denetiminde *"kırılamayan"* ilan edilen bir zinciri, v3'ün yeni bir kararı bozmuştu.**
> **Düzeltme:** `Trim()` **her zaman önce** koşar; format doğrulama **`Trim()`'lenmiş** değeri görür. Sonucu: baştaki/sondaki boşluk **sessizce yutulur** (kullanıcı hatası, güvenlik sonucu yok) ama içeride boşluk ya da bozuk format **`400`** alır.

> **⚠ TÜRKÇE LOCALE TUZAĞI — bu projede teorik değil, ÖLÇÜLMÜŞ bir risktir.**
> Geliştirme makinesinin sistem locale'i **tr-TR / cp1254**'tür (oturum 2 tanısı: bu locale Postgres `initdb`'yi fiilen kırdı). Türkçe kültüründe `"I".ToLower()` → **`"ı"`**, `"i".ToUpper()` → **`"İ"`**. Kültüre-duyarlı `ToLower()` kullanılırsa aynı e-posta sunucunun kültürüne göre **iki farklı** normalize değer üretir ⇒ (a) aynı adresle iki hesap açılabilir, (b) tr-TR makinede kayıt olan kullanıcı invariant makinede **giriş yapamaz**. DB tarafında unique index **`COLLATE "C"`** ile kurulur. `string.ToLower()` · `ToUpper()` · `ToLower(CultureInfo)` · `ToUpper(CultureInfo)` · kültüre-duyarlı `string.Compare` **BannedApiAnalyzers ile derleme-zamanı yasaklanır** (K-H1'in `DateTime.UtcNow` yasağıyla aynı mekanizma). **Kardeşi frontend'dedir:** Dart `toUpperCase()` de Türkçe i→İ dönüşümünü yapmaz ⇒ *kültüre-duyarlı büyük/küçük harf dönüşümü hiçbir katmanda kimlik/eşleştirme yolunda kullanılmaz* (K10 yakınsaması).

**K3-A3 — Kayıt açık; sayım oracle'ı ADLANDIRILMIŞ SAPMADIR [K11-e].** `POST /v1/auth/register` herkese açıktır ve e-posta zaten kayıtlıysa **bunu söyler** (`409`, ayırt edici mesaj). *Gerekçe:* e-posta doğrulama ODEV §6.1'de **kapsam dışıdır** ⇒ *"her durumda 202 döndür"* çözümünün kanonik ikinci ayağı (doğrulama maili) yok; kullanıcı neden giriş yapamadığını hiç öğrenemez ⇒ ODEV §2 zedelenir. **Bu bir sapmadır, bir çözüm değil**; `KANIT`'ta ve README'de açıkça beyan edilir. *Reddedilenler:* her durumda `202` · yalnız sıkı rate-limit (oracle'ı kapatmaz).

**K3-A4 — `User` SENKRONLANABİLİR KÖK DEĞİLDİR. [ADR 0004'ü BAĞLAYAN KISIT]** `User`'ın `owner_id`'si yoktur, `/sync` telinde geçmez, tombstone'u yoktur, CRDT birleştirmesine girmez. **Sonucu 0004 için hayatidir:** owner global query filter'ı `User`'a **UYGULANAMAZ** — uygulanırsa anonim `/login` isteğinde `ICurrentUser.UserId` `UnauthenticatedException` atar ve **giriş fiziksel olarak kilitlenir**. Kısıt burada tanımlanır, kapısı (**D-3**, §7) 0004'te kurulur.

### B. Parola

**K3-B1 — Hash = Argon2id, `Konscious.Security.Cryptography.Argon2` 1.3.1 [KAPI KOŞULDU, GEÇTİ].**
Parametreler **OWASP ikinci yapılandırması**: `m = 19456 KiB · t = 2 · p = 1`, 16 baytlık CSPRNG salt, 32 baytlık çıktı.
**Kapı kanıtı (Onur'un makinesinde, gerçek koşu, 25 Tem 2026):** lisans **MIT** · **CVE 0** · net9.0 build **0 uyarı 0 hata** · fiilen çalıştı: 32 baytlık hash, **270 ms**.
**⚠ ADLANDIRILMIŞ RİSK, GİZLENMİYOR:** paket **~25 ay hareketsiz** (`pushed_at = 2024-06-18`, 20 açık issue, 3 açık PR, GitHub'da release yok, arşivlenmemiş, 6.9M indirme). Bir CVE düşerse yamayı gönderecek bakımcı olmayabilir. **Telafi kapatma değil, İZOLASYONDUR → K3-B2/B3.**

**K3-B2 — `IPasswordHasher` portu [K9].** Arayüz **Application**'da, implementasyon **Infrastructure**'da. `Konscious.*` tipi Domain/Application/Api katmanlarının **hiçbirinde görünmez** — **NetArchTest kuralı** (K-A1 ailesine ek). Paket değişimi tek sınıfı etkiler. **Kuralın mutantı: M32** (0001 K-H1: *"Her kural commit'li negatif/mutant testle ısırdığını kanıtlar"* — v2 bunu ihlal ediyordu, bloker #15).

**K3-B3 — Hash string'i kendi kendini tarif eder [K9].** Depolanan format PHC benzeri:
`$argon2id$v=19$m=19456,t=2,p=1$<b64 salt>$<b64 hash>`
Algoritma kimliği ve parametreler **satırın içindedir**. Sonucu: (a) PBKDF2'ye ya da yeni parametreye geçiş **migration değil**, tek sınıf + doğrulama yolunda dallanmadır; (b) **başarılı girişte, depolanan parametreler güncel politikadan farklıysa parola sessizce yeniden hash'lenir** (rehash-on-login).

**K3-B4 — Doğrulama sabit-zamanlı.** `CryptographicOperations.FixedTimeEquals`; `SequenceEqual` **banned-API** (derleme kırılır). *(Not: `byte[] ==` referans karşılaştırmasıdır ve BannedApiAnalyzers ile ifade edilemez — bu ayak bir davranış testine devredildi, bkz. M6.)*

**K3-B5 — Kullanıcı-sayımı ve zamanlama sızıntısı: `/login` ve `/refresh` yolunda PAZARLIKSIZ, `/register`'da ADLANDIRILMIŞ SAPMA.**
`/login`: bilinmeyen e-posta ile yanlış parola **aynı** yanıtı döndürür (`401`, tek tip ProblemDetails) **ve aynı işi yapar** — kullanıcı bulunamazsa da bir **sahte (dummy) Argon2id doğrulaması** koşulur (sabit, uygulama açılışında bir kez üretilmiş geçerli formatlı bir hash'e karşı). Aksi hâlde yanıt süresi (≈270 ms vs ≈1 ms) hesabın varlığını ele verir.
**⚠ Sahte hash'in bir MALİYETİ vardır ve bu maliyet bir DoS çarpanıdır** — telafisi K3-J2/J3/J4'tür.
**"Aynı yanıt" ayağının kapısı [D3 majörü kapatılıyor]:** *"bilinmeyen e-posta ile yanlış parolanın yanıt gövdesi ve durum kodu **`traceId` alanı hariç bayt bayt aynıdır**"* testi — **M37**.

> **🔴 v3'ÜN "BAYT BAYT AYNI" İDDİASI YAPISAL OLARAK İMKÂNSIZDI — DÜZELTİLİYOR [Ma-4].**
> **ÖLÇÜM (dotnet/aspnetcore `release/9.0`, `DefaultProblemDetailsWriter.cs`):** `var traceId = Activity.Current?.Id ?? httpContext.TraceIdentifier; context.ProblemDetails.Extensions["traceId"] = traceId;` — **koşulsuz.** ⇒ iki ayrı isteğin gövdesi **hiçbir zaman** bayt bayt aynı olamaz; M37 baseline'da **kırmızı doğardı = ölü tuzak.**
> **Karar (iki ayak birlikte):** (1) sinyal *"`traceId` alanı hariç"* diye **pinlenir** — test gövdeyi JSON olarak ayrıştırır, `extensions.traceId` alanını **düşürür**, kalanı karşılaştırır; (2) `traceId` **korelasyon için tutulur** (K-G3'ün correlation-id kararı) — kaldırmak bir gözlemlenebilirlik kaybıdır ve kullanıcı-sayımı sızıntısı **değildir** (değeri hesaptan bağımsızdır).

**K3-B6 — GİRDİ POLİTİKASI: NIST SP 800-63B-4 ÇİZGİSİ, ASGARİ 15 KARAKTER. [K16-a — bloker #11 kapanır, Ma-9 düzeltilir]**
v2 bunu ne karara bağlamış ne kapsam dışı ilan etmişti ⇒ **gizlenmiş sınır**. Bugün `/register` parolası `"a"` olabiliyordu ve Argon2'ye 1 MB'lık bir parola gönderilebiliyordu.

> **🔴 v3'ÜN NIST ATFI YANLIŞTI — DÜZELTİLİYOR [Ma-9, K16-a].**
> **NIST SP 800-63B-4 (Final) birebir:** *"Verifiers and CSPs **SHALL** require passwords that are used as a **single-factor** authentication mechanism to be a minimum of **15 characters** in length"* (çok faktörlü bir bileşen olarak kullanıldığında asgari 8). Momentum'da parola **tek faktördür** (2FA K3-K3 ile kapsam dışı) ⇒ uygulanan çizgi **15'tir.** v3 *"NIST çizgisi ≥10"* diyordu; **atıf yanlıştı ve belgenin kendi cümlesiyle *"güncel literatürü bilen değerlendiricide eksi sinyal"* üretiyordu.**
> **Bedeli adlandırılır ve TELAFİ EDİLİR:** 15 karakter, demo sırasında elle yazmak için uzundur ⇒ **teslim paketi bir demo hesabı seed'ler** (`demo@momentum.local` + README'de açıkça yazılı 15+ karakterlik parola) ve giriş ekranı bu değeri **ön-doldurmaz** (ön-doldurma bir güvenlik alışkanlığı bozukluğudur; README yeterlidir).

| kural | değer | gerekçe |
|---|---|---|
| Parola asgari uzunluk | **15 karakter** | NIST SP 800-63B-4'ün tek faktör için `SHALL` çizgisi (yukarıda birebir). `123456` parolasına karşı Argon2id'nin `m=19456,t=2` yatırımı hiçbir şey satın almaz — **uzunluk, KDF'den önce gelir.** |
| Parola **karmaşıklık kuralı** | **YOKTUR — bilinçli** | NIST SP 800-63B-4 birebir *"**SHALL NOT** impose other composition rules … for passwords"*; OWASP da önermez: kullanıcıyı tahmin edilebilir kalıplara (`Parola1!`) iter. **Bu bir eksiklik değil, adlandırılmış bir tercihtir.** |
| Parola azami uzunluk | **128 karakter** | **Argon2 DoS tavanı.** Sınırsız girdi, hash maliyetini saldırganın seçmesine izin verir. NIST-4'ün *"**SHOULD** permit … at least 64"* tavsiyesinin **üstündedir** ⇒ sapma değil. |
| Parola **kesme/kırpma** | **YOKTUR** | Parola `Trim()`'lenmez ve kesilmez; **tek dönüşüm NFC normalizasyonudur** (NIST-4: Unicode parolalar için normalizasyon önerilir). Boşluk anlamlıdır (parola cümleleri). |
| E-posta azami uzunluk | **254 karakter** | RFC 5321 yol sınırı. Ayrıca `email_normalized` üzerindeki btree index'in anahtar boyutu sınırına çarpıp `500` üretmesini önler — aksi hâlde K3-B5'in *"tek tip ProblemDetails"* garantisi kırılırdı. |
| E-posta formatı | **doğrulanır, doğrulayıcı PİNLİDİR** | K3-A2'nin sırasında: **`Trim()`'den SONRA, NFC'den ÖNCE.** Başarısızsa `400` (tek tip ProblemDetails). |

**E-POSTA DOĞRULAYICISI PİNLENİR [Ma-5'in ikinci yarısı — v3 "doğrulanır" deyip bırakmıştı].** Kütüphane varsayılanına **güvenilmez** (`[EmailAddress]` özniteliği fiilen *"içinde `@` var mı"* kadar gevşektir; `MailAddress` ise `"Ad Soyad <a@x.com>"` gösterim biçimini **kabul eder** ⇒ kimlik anahtarı olarak kullanılamaz). Kural kümesi **açıkça** yazılır ve hepsi birden sağlanmalıdır:
1. `System.Net.Mail.MailAddress.TryCreate(value, out var addr)` **başarılı**, **ve** `addr.Address == value` (gösterim-adlı biçim **reddedilir**),
2. tam olarak **bir** `@`, yerel kısım ≥1 karakter, alan kısmında **en az bir** `.` ve alan kısmı `.` ile başlamaz/bitmez,
3. toplam uzunluk **≤254**,
4. hiçbir boşluk ya da kontrol karakteri **içermez** (baştaki/sondaki boşluk 1. adımda zaten `Trim()`'lenmiştir).

**Kapı: M31** (dört ayak: 14 karakter `400` · **15 karakter `201`** · 129 karakter `400` **ve Argon2 KOŞMAZ** · bozuk e-posta `400`). *Reddedilenler:* kapsam dışı ilan etmek (azami uzunluk yoksa Argon2 DoS yüzeyi açık kalır) · klasik karmaşıklık kuralları (güncel literatürü bilen değerlendiricide eksi sinyal) · **10'da kalıp adlandırılmış sapma yazmak** (doktrine uygun olurdu ama denetçi *"neden sapıyorsun"*u yeniden sorar; NIST'e uymanın bedeli burada yalnız bir README satırıdır) · **12 karakter** (hiçbir standartta karşılığı yok ⇒ keyfi).

**K3-B7 — PHC STRING'İ AYRIŞTIRMA SÖZLEŞMESİ. [Ma-4 kapanır]**
v2 formatı **yazmayı** tarif ediyordu ama **okumayı** hiç yazmamıştı ⇒ bozuk/tanınmayan bir `password_hash` `FormatException` → `500` üretirdi ve **bilinen/bilinmeyen e-posta yanıt kodundan ayırt edilebilirdi** (K3-B5'in garantisi kırılır).

- Ayrıştırma **savunmacıdır**: beş alan (`argon2id` · `v=` · `m=,t=,p=` · b64 salt · b64 hash) beklenir. Herhangi biri eksik/bozuksa **istisna dışarı sızmaz**: doğrulama `false` döner ⇒ `/login` normal `401` yolundan çıkar. Olay `Warning` seviyesinde loglanır (parola veya hash **loglanmaz**).
- **Rehash kararı yalnız `m`, `t`, `p` üçlüsü ve algoritma kimliği üzerinden verilir**; salt ve hash uzunluğu karşılaştırmaya girmez.
- Kapı: **M34**.

### C. Token modeli [K8-b]

**K3-C1 — Erişim token'ı = kısa ömürlü JWT (~15 dk), HS256.**
Talepler: `sub` (userId) · `jti` · `iat` · `exp` · **`iss`** · **`aud`** · **`fid`** (family_id, K14-c) · `sstamp` (bugün ölü alan, K3-C8).
> **[Ma-3 kapatıldı]** v2'nin talep listesinde `iss`/`aud` **yoktu** ama K3-C7 ikisini de zorunlu kılıyordu ⇒ liste harfiyen uygulansaydı **her istek `401`** olurdu.
> **[K14-c]** `fid` talebi `/logout`'un hangi aileyi iptal edeceğini **hesaplanabilir** kılar; v2'de bu bilgi hiçbir yerde taşınmıyordu (bloker #6).

İmzalama anahtarı simetrik; **tek servis** topolojisinde asimetrik imza (ES256) anahtar dağıtımı getirir, karşılığında hiçbir şey kazandırmaz. *Reddedilen: ES256 · uzun ömürlü tek JWT (iptal edilemez).*

**K3-C2 — Yenileme token'ı = OPAK, DB'de, DÖNDÜRMELİ, YENİDEN-KULLANIM TESPİTLİ. [taç mekanik]**
- **Değer ve KODLAMASI [B5 — v3'te hiç yazılmamıştı, iki mutantı birden kör bırakıyordu]:** **256 bit CSPRNG (32 ham bayt)**; tele çıkan biçim **`Base64Url`, dolgusuz** (`WebEncoders.Base64UrlEncode` / RFC 4648 §5, `=` dolgusu **yok**) ⇒ **43 karakter**, alfabe `[A-Za-z0-9_-]`. **DB'ye yalnız SHA-256 özeti yazılır ve özet HAM 32 BAYTIN üzerinde hesaplanır** (kodlanmış dizenin değil) — `token_hash = SHA256(rawBytes)`. *(Yüksek-entropili rastgele bir sır sözlük saldırısına tabi değildir — bilinçli asimetri; bu yüzden Argon2 değil SHA-256 yeterlidir.)*
  > **Neden bu satır bir kapı kararıdır:** v3 yalnız *"256 bit CSPRNG"* diyordu. Sonucu iki kör kapıydı: (1) **M12** *"SHA-256 özetine eşittir"* diyor ama **neyin** özeti belirsizdi (ham bayt mı, kodlanmış dize mi) ⇒ builder'ın seçimine göre test ya yazılamaz ya yanlış yazılırdı; (2) **M28** gövdeyi ham dize olarak token için tarıyordu — **standart Base64** kullanılsaydı `System.Text.Json`'ın varsayılan kodlayıcısı `+` karakterini `+`'ye çevirdiği için tarama token'ı **≈%49 olasılıkla ıskalardı** (ölçüm: `AllowedBmpCodePointsBitmap.ForbidHtmlCharacters()` → `ForbidChar('+')`). **`Base64Url` alfabesinde `+` ve `/` yoktur ⇒ JSON kaçışı yapısal olarak devre dışı kalır.** Aynı kodlama CSRF nonce'u ve `successor_secret_enc`'in tel biçimi için de geçerlidir.
- **HALEFİN HAM DEĞERİ: `successor_secret_enc` — KISA ÖMÜRLÜ, ŞİFRELİ, ADLANDIRILMIŞ İSTİSNA [K15-a — bloker B1 kapanır].** K3-C6(3)'ün replay-idempotency kuralı *"kayıtlı halef **aynen** döndürülür"* diyor; SHA-256 tersine çevrilemez ve token bir CSPRNG'dir ⇒ **v3'te sunucunun döndürecek bir değeri yoktu ve kural inşa edilemezdi.** Karar: `refresh_tokens`'a `successor_secret_enc` kolonu eklenir; **halefin 32 ham baytı**, kök anahtardan türetilmiş `rt-successor-enc` alt anahtarıyla (K3-I4) **AES-256-GCM** ile şifrelenip **yalnız halefi üreten satırda** tutulur ve **`consumed_at + 60 sn` dolduğunda `NULL`**'lanır (mekanizma: K3-C6(5)).
  - **Bu bir istisnadır ve gizlenmiyor:** *"DB'de token'ın ham değeri hiç bulunmaz"* iddiası artık **60 saniyelik, şifreli bir pencere** için geçerli değildir. Bedeli **§6 Risk #13**'e yazıldı.
  - **Neden yine de kabul edilebilir:** (a) değer **şifrelidir** ⇒ yalnız DB dökümü alan bir saldırgan onu **kullanamaz**, ayrıca uygulama anahtarını da ele geçirmelidir; (b) pencere **60 saniyedir**, oturum ömrü (30 gün) değil; (c) `token_hash` sütunu **hâlâ yalnız özettir** ⇒ M12'nin asıl iddiası (*"tele çıkan değer DB'de düz metin durmaz"*) ayakta kalır.
- Ömür: **mutlak 30 gün**, `family_id` doğduğu anda sabitlenir.
- **`expires_at` DEVRALMA DEĞİŞMEZİ [bloker #14'ün ikinci ayağı]:** *"aynı `family_id`'nin **tüm** satırları **özdeş** `expires_at` taşır; döndürmede üretilen yeni satır, sunulan satırın `expires_at`'ini **kopyalar**."* Bu bir cümle değil bir **değişmezdir**: testte tam eşitlikle (`==`) doğrulanır, "yaklaşık" karşılaştırma yasaktır.
- Tablo: `refresh_tokens(id, user_id, token_hash, family_id, created_at, expires_at, consumed_at, replaced_by_id, revoked_at, revoked_reason, successor_secret_enc)`.
  `successor_secret_enc bytea NULL` — AES-256-GCM çıktısı (`nonce ‖ ciphertext ‖ tag`, 12+32+16 = **60 bayt**). **`NULL` varsayılandır**; yalnız döndürme anında dolar, 60 sn sonra yeniden `NULL` olur. **İlişkili indeks: `WHERE successor_secret_enc IS NOT NULL` kısmi indeksi** (süpürücünün taraması ailenin tamamını değil yalnız canlı pencereyi görsün).
- **Döndürme:** her `/refresh` sunulan token'ı `consumed_at` ile tüketir ve **aynı `family_id`** altında yenisini üretir.
- **YENİDEN-KULLANIM TESPİTİ:** `consumed_at` dolu bir token yeniden sunulursa → **o ailenin tamamı derhal iptal** (`revoked_reason = 'reuse_detected'`), `401`. **İSTİSNA: K3-C6'nın replay-idempotency penceresi** (K14-a) — ve **yalnız o**.

**K3-C3 — `family_id` = GİRİŞ BAŞINA (bir cihaz/oturum) [K11-d].** Her başarılı `/login` **yeni** bir `family_id` doğurur; her `/refresh` **aynı** aileyi sürdürür. Reuse tespiti **yalnız o aileyi** düşürür. *Reddedilen:* kullanıcı başına tek aile.
**Doğum anının kapısı [D3 majörü kapatılıyor]:** M18 bunu yalnız tesadüfen kapsıyordu. Ayırt edici test: *"aynı kullanıcı iki kez `/login` yapar ⇒ dönen iki token **FARKLI** `family_id` taşır"* — **M38**.

**K3-C4 — Çıkış gerçektir, kapsamı AÇIKÇA YAZILIR [K11-d + K14-c].**
`POST /v1/auth/logout` **yalnız JWT'nin `fid` talebindeki aileyi** iptal eder. `POST /v1/auth/logout-all` kullanıcının **tüm ailelerini** iptal eder. Erişim token'ı her iki durumda da **≤15 dk** daha geçerli kalır — **bilinçli ve beyan edilmiş** sınır (kara liste tutulmuyor; K3-C8).
**⚠ v2'de bu uç FİİLEN NO-OP'TU** (bloker #2): iptal `revoked_at`'i yazıyordu ama `/refresh` yüklemi ona hiç bakmıyordu. Kapatma K3-C6'dadır; kapısı **M26**.

**K3-C5 — ZARAFET PENCERESİ YOKTUR. [K11-c]** v1'in *"aynı aileden, son 10 sn içinde üretilmiş token da kabul edilir"* penceresi **KALDIRILMIŞTIR**.
> **⚠ K14-a'NIN REPLAY-IDEMPOTENCY PENCERESİ BU DEĞİLDİR — FARK YAPISALDIR, aşağıda tabloyla yazılıyor (K3-C6).** v1'in penceresi *"ailenin herhangi bir yeni token'ını kabul et"* diyordu ⇒ saldırgan 5 sn'de bir `/refresh` çağırarak **sonsuz bir zarafet zinciri** kurar ve reuse-detection'a **yapısal olarak erişilemez** kılardı. K14-a'nınki *"bu tek token'ın kayıtlı halefini aynen tekrar ver"* diyor ⇒ zincir doğmaz.

**K3-C6 — TÜKETİM ATOMİKTİR; YÜKLEM TAMDIR; 0-SATIR DALI DÖRDE AYRILIR. [bloker #1 + #2 kapanır — bu belgenin en çok değişen maddesi]**

**v2'nin yüklemi eksikti ve tamlık iddiası YANLIŞTI.** v2 birebir şöyle diyordu: *"Etkilenen satır **0** ise token **ya tüketilmiştir** … **ya yoktur**"* — sonuç uzayı hakkında **kapalı bir disjonksiyon**, ve şemada `revoked_at`/`expires_at` varken **yanlış**. Sonucu: `/logout` fiilen no-op, mutlak 30 gün zorlanmıyor.

**(1) Atomik tüketim (yüklem tamamlandı):**
```sql
UPDATE refresh_tokens
   SET consumed_at = @now, replaced_by_id = @new
 WHERE token_hash  = @h
   AND consumed_at IS NULL
   AND revoked_at  IS NULL
   AND expires_at  > @now
RETURNING …;
```
Kontrol-sonra-yaz (check-then-act) **yasaktır**.

**HALEF `INSERT`'ÜNÜN ATOMİKLİĞİ — SIRA VE İŞLEM SINIRI PAZARLIKSIZ [Ma-10 — v3 bunu hiç yazmamıştı].**
v3 yalnız yukarıdaki `UPDATE … RETURNING`'i pinliyordu; **halef satırının ne zaman ve hangi işlem sınırında doğduğu yazılı değildi.** Builder'ın en doğal seçimi (*önce `INSERT`, sonra `UPDATE`*) yarışı **kaybeden** istekte ailede **sahipsiz ama biçimsel olarak geçerli** bir satır bırakır: `UPDATE` 0 satır etkiler, istek `401` alır, ama `INSERT` edilmiş satır ailede kalır ve `M39`'un *"tam olarak biri `200`"* ölçütü onu **görmez** (yalnız yanıt kodlarını ölçüyor).

**Karar:**
1. Tüketim ve halef doğumu **TEK transaction** içindedir; **`READ COMMITTED` yeterlidir** (atomikliği sağlayan şey izolasyon seviyesi değil, koşullu `UPDATE`'in satır kilididir).
2. **Sıra:** önce `UPDATE … WHERE … RETURNING` **koşulur**; **0 satır dönerse `INSERT` HİÇ YAPILMAZ** ve işlem geri alınır/boş kapanır. Halef `INSERT`'i yalnız `UPDATE` 1 satır döndürdüğünde koşar.
3. `replaced_by_id` ve `successor_secret_enc` **aynı transaction içinde** yazılır ⇒ *"halef var ama sırrı yok"* ya da *"sır var ama halef yok"* ara durumu **yoktur**.
4. **Değişmez:** başarılı bir `/refresh` ailenin satır sayısını **tam olarak 1** artırır; başarısız bir `/refresh` **hiç artırmaz**.

**Kapı: M45** (mutasyon: `INSERT` `UPDATE`'ten önceye alınır / ayrı transaction'a çıkarılır).

**(2) Etkilenen satır 0 ise — DÖRT dal, tek `SELECT` ile ayrıştırılır** *(bu `SELECT` bir check-then-act değildir: yazma zaten denenmiş ve başarısız olmuştur; okuma yalnız **hangi hata** olduğunu belirler)*:

| durum | sunum | aile iptali |
|---|---|---|
| **(a)** satır yok (`token_hash` bulunamadı) | `401` | **YOK** |
| **(b)** `revoked_at` dolu **veya** `expires_at ≤ now` | `401` | **YOK** — zaten ölü; ikinci kez iptal etmek `revoked_reason`'ı bozar |
| **(c)** `consumed_at` dolu **ve** replay-idempotency koşulları sağlanıyor (aşağıda) | **`200` — kayıtlı halef aynen döndürülür** | **YOK** |
| **(d)** `consumed_at` dolu, koşullar sağlanmıyor | `401` | **VAR — `reuse_detected`, ailenin tamamı** |

**DAL ÖNCELİĞİ PAZARLIKSIZDIR: (a) → (b) → (c) → (d) [Ma-2 — v3 bunu yazmamıştı ve sessiz bir güvenlik açığı üretiyordu].**
`consumed_at` ve `revoked_at` **aynı anda dolu olabilir** — sıradan bir akışta: kullanıcı `/refresh` yapar (`T1.consumed_at` dolar), sonra `/logout` der (**ailenin tamamı**, `T1` dâhil, `revoked_at` alır). v3'ün dalları **koşulsuz bir küme** gibi yazılmıştı; builder (c)'yi önce ayrıştırırsa **`/logout`'tan sonraki 60 saniye boyunca `T1` hâlâ `200` ve çalışan bir halef döndürür** ⇒ çıkış fiilen 60 saniye gecikir. **M26 bunu görmez** (o, `revoked_at` yükleminin `UPDATE`'ten çıkarılmasını ölçer, dal sırasını değil).

**Kural:** dallar **bu sırayla** değerlendirilir ve **ilk eşleşen kazanır**:
1. **(a)** satır yok ⇒ `401`.
2. **(b)** `revoked_at IS NOT NULL` **veya** `expires_at ≤ now` ⇒ `401`. **Bu dal sağlanıyorsa replay-idempotency HİÇ DEĞERLENDİRİLMEZ** — iptal edilmiş ya da süresi dolmuş bir aile için "kayıp yanıt telafisi" diye bir şey yoktur.
3. **(c)** `consumed_at IS NOT NULL` **ve** replay koşulları (aşağıda) ⇒ `200`.
4. **(d)** aksi hâlde ⇒ `401` + **`reuse_detected`**.

**Kapı: M44** (mutasyon: sıra (c)→(b) yapılır ⇒ `/logout` sonrası 60 sn içinde replay `200` döner).

**(3) SINIRLI REPLAY-IDEMPOTENCY [K14-a — bloker #1 / **RT-B1**'in kapatılması].**
**Kırılan senaryo (saldırgan gerekmez; aktör = ağ):** istemci `/refresh` gönderir (`T1`) → sunucu tüketimi **commit eder** (`T2` doğar) → **yanıt istemciye ulaşmaz** (uçak modu, hücresel el değiştirme, TCP reset, Android Doze/process kill) → istemcinin elinde hâlâ `T1` var, `T2`'yi hiç görmedi → yeniden dener → v2'de **aile düşer, meşru kullanıcı kendini hırsız ilan eder**. Tek-uçuşluluk (K3-L5) bunu **kapsamaz**: o *eşzamanlı* çağrıları serileştirir, *ardışık yeniden denemeyi* değil — ikinci adımda uçuş zaten bitmiştir.

**Kural:** tüketilmiş `T1` yeniden sunulduğunda, **her ÜÇ koşul da** sağlanıyorsa `T1`'in **kayıtlı halefi aynen** döndürülür; yeni döndürme **yapılmaz**:
1. `now ≤ T1.consumed_at + 60 sn` **[K16-b kapsamında; Onur kilidi]**, **ve**
2. `T1.replaced_by_id`'nin işaret ettiği satırın `consumed_at`'i **hâlâ `NULL`** (halef henüz kullanılmamış), **ve**
3. **`T1.successor_secret_enc IS NOT NULL`** — yani halefin ham değeri hâlâ **çözülebilir** durumdadır (K15-a). Değilse dal **(d)**'ye düşülür.

> **🔴 v3'TE BU KURAL İNŞA EDİLEMİYORDU — B1'İN KAPATILMASI [K15-a].**
> Denetim şunu ölçtü: K3-C2 *"DB'ye **yalnız** SHA-256 özeti yazılır"* diyor · şemada ham değer için kolon **yok** · **M12 bunu ayrıca zorluyor** ⇒ sunucunun *"aynen döndürecek"* bir değeri **yoktu**. SHA-256 tersine çevrilemez ve token bir **CSPRNG**'dir, `HMAC(key, row_id)` gibi yeniden hesaplanabilir bir yapı değildir. **Bu bir yazım kusuru değil, bir inşa-edilemezlik kusuruydu** ve M29/M30/M1'in üçü de var olmayan bir davranışa çıpalıydı.
> **Karar (K15-a): `successor_secret_enc`.** Halefin 32 ham baytı, `rt-successor-enc` alt anahtarıyla (K3-I4) **AES-256-GCM** ile şifrelenir ve `T1` satırında tutulur; replay dalında **çözülüp aynen döndürülür**; **60 sn sonra `NULL`**'lanır (5). **K14-a'nın semantiği hiç değişmedi:** yeni token üretilmez · pencere `T1.consumed_at`'e çıpalıdır · `expires_at` devralınmıştır ⇒ **v1'in sonsuz zinciri hâlâ yapısal olarak imkânsızdır** (aşağıdaki beş eksenli tablo aynen geçerlidir).
> *Reddedilenler [adlandırılmış]:* **dal (c)'nin yeniden yazımı** (*"yeni token üretilir ama `T1`'in halefi olarak kaydedilir, `expires_at` devralınır"* — şema değişmezdi ama *"yeni döndürme yapılmaz"* cümlesi düşer, koşul 2'nin semantiği ve M29/M30'un kill sinyalleri baştan yazılır, her kayıp yanıtta ailede bir satır daha birikir) · **K14-a'nın tümüyle geri alınması** (telafisiz adlandırılmış sınır; RFC 9700 §4.14.2 bunu bir **maliyet** sayar ama değerlendirici uçak modunu açıp kapattığında çevrimdışı vitrininin ortasında yeniden giriş ekranı görür — ODEV §2; K14-a tam da bunun için seçilmişti) · **K3-C2'nin "yalnız özet" kararını tümüyle gevşetmek** (şifreleme olmadan DB dökümü = 30 günlük kullanılabilir token).

**Neden bu, v1'in reddedilen zarafet penceresi DEĞİL:**

| eksen | v1 zarafet penceresi (REDDEDİLDİ) | K14-a replay-idempotency |
|---|---|---|
| Çıpa | **aileye** (*"ailenin son 10 sn'de üretilmiş herhangi bir token'ı"*) | **tek token'a** (`T1.consumed_at`) |
| Her çağrıda ne olur | **yeni token üretilir** ⇒ pencere ileri kayar | **hiçbir şey üretilmez** ⇒ pencere sabit, `T1` ile birlikte ölür |
| Sonsuz zincir | **MÜMKÜN** (5 sn'de bir `/refresh` ⇒ reuse-detection'a hiç varılmaz) | **YAPISAL OLARAK İMKÂNSIZ** |
| Halef kullanıldıysa | fark etmez, yine kabul | **REDDEDİLİR ⇒ aile düşer** (gerçek hırsızlık sinyali korunur) |
| Ömür | uzayabilir | `expires_at` devralındığı için **uzamaz** |

**Hırsızlık senaryosunda ne kaybediyoruz — dürüst muhasebe:** saldırgan `T1`'i çalıp **60 sn içinde ve meşru istemci `T2`'yi kullanmadan önce** sunarsa, aile düşmez ve saldırgan `T2`'yi alır. **Ama meşru istemci `T2`'yi kullandığı anda** — ki elinde `T2` varsa saniyeler içinde kullanır — saldırganın bir sonraki `/refresh`'i (d) dalına düşer ve **aile düşer**. Yani pencere reuse-detection'ı **kaldırmaz, 60 saniye geciktirir**. Bu maliyet, *"tek ağ kesintisi 30 günlük oturumu yeniden girişe çeviriyor"* maliyetine karşı bilinçli olarak seçilmiştir (K14-a).

**Kapılar: M29** (pencere dışında sunulan tüketilmiş token **aile düşürür**) · **M30** (halef **pencere içinde** tüketilmişse **aile düşürür**) · **M1** (replay-idempotency tamamen kaldırılırsa değil — reuse-detection kaldırılırsa) · **M44** (dal önceliği) · **M40** (sırrın 60 sn sonra **gerçekten silindiği**).

**(5) `successor_secret_enc`'İN SİLİNMESİ: İKİ MEKANİZMA, İKİSİ DE ZORUNLU [K15-a'nın veri-minimizasyon ayağı — kırmızı çizgi #2].**
Yalnız yüklemle yetinmek **yetmez**: `/refresh` yüklemi pencereyi **güvenlik** açısından zorlar (60 sn sonra dal (c) açılmaz), ama o satıra bir daha hiç dokunulmazsa **şifreli sır DB'de 30 gün durur** ⇒ §6 Risk #13'ün *"60 saniyelik pencere"* ifadesi **yalan olurdu**. İkisi birlikte:
1. **Fırsatçı (tembel) silme:** her `/refresh` işleminde, aynı transaction içinde, **o ailenin** `consumed_at < now - 60 sn` olan satırlarının `successor_secret_enc`'i `NULL`'lanır.
2. **Süpürücü (`RefreshSecretSweeper`):** `BackgroundService`, **60 saniyede bir**, `UPDATE refresh_tokens SET successor_secret_enc = NULL WHERE successor_secret_enc IS NOT NULL AND consumed_at < @now - interval '60 seconds'` koşar. **Saat kaynağı `TimeProvider`'dır** (K-C5) ve süpürme işi **doğrudan çağrılabilir bir metoda** (`SweepAsync(CancellationToken)`) ayrılır ⇒ test `BackgroundService`'in zamanlayıcısını beklemek zorunda kalmaz.
   > **K3-D3'ün arka plan tuzağı burada da geçerlidir:** süpürücü **owner-filtreli hiçbir sorguya dokunmaz**; `ICurrentUser`'ı **çözmez**; kendi `IServiceScope`'unu açar. Kapsamı tek kolondur.
3. **Değişmez:** `consumed_at < now - 60 sn` olan **hiçbir** satırda `successor_secret_enc` dolu olamaz — **azami gecikme bir süpürme periyodudur (60 sn)** ve bu **§6 Risk #13'te birebir böyle beyan edilir** ("60 sn pencere + azami 60 sn süpürme gecikmesi ⇒ **en kötü durumda 120 sn**").

**Kapı: M40** — mutasyon: süpürücü devre dışı bırakılır (veya `SweepAsync` no-op yapılır). Kill sinyali: *"`FakeTimeProvider` **121 sn** ileri alınıp `SweepAsync` çağrıldıktan sonra, tüketilmiş satırın `successor_secret_enc`'i **`NULL`**'dır"* **FAIL**. Seviye **TC** (gerçek Postgres; kolonun fiilen `NULL`'landığı okunur).

**(4) ATOMİKLİK KAPISI [D3 majörü kapatılıyor].** v2 atomikliği **iddia ediyor ama test etmiyordu**. Emsal 0002 K2-H12'de var: *"aynı `T1` ile **paralel** iki `/refresh` — tam olarak **biri** `200`, diğeri `401`+`reuse_detected` alır; ikisi birden `200` alırsa test FAIL"* — **M39** (Testcontainers, gerçek Postgres; `TestServer` içi kilit bunu kanıtlamaz).

**K3-C7 — `TokenValidationParameters` AÇIKÇA YAZILIR — hiçbir varsayılana güvenilmez.**

| ayar | değer | neden |
|---|---|---|
| `ValidateIssuer` / `ValidIssuer` | `true` / yapılandırmadan | K3-C1'in `iss` talebiyle eşleşir |
| `ValidateAudience` / `ValidAudience` | `true` / yapılandırmadan | K3-C1'in `aud` talebiyle eşleşir |
| `ValidateLifetime` | `true` | — |
| **`ClockSkew`** | **`TimeSpan.Zero`** | **ÖLÇÜLDÜ:** `TokenValidationParameters.DefaultClockSkew = TimeSpan.FromSeconds(300)` ⇒ varsayılanla **beyan edilen ≤15 dk fiilen ≤20 dk** olurdu. |
| `ValidateIssuerSigningKey` / `IssuerSigningKey` | `true` / K3-I1'den | — |
| `ValidAlgorithms` | `[ "HS256" ]` | **DAR AMA GERÇEK BİR KAPIDIR** — yalnız *aynı anahtarla HS384/HS512 ikamesini* kapatır; `alg:none`'ı ve RS256'yı **kapatmaz** (aşağıdaki düzeltmeye bakınız). Kapısı **M16'nın ikinci ayağıdır.** |
| `RequireSignedTokens` / `RequireExpirationTime` | `true` / `true` | `RequireSignedTokens` **`alg:none`'ı kapatan asıl ayardır** |
| **`MapInboundClaims`** | **`false`** | Claim tipleri ham JWT adlarıyla kalır (`sub`, `jti`, `fid`, `sstamp`). |

> **🔴 v2'NİN `alg` BEYANI YANLIŞTI — DÜZELTİLİYOR [bloker #12].**
> v2 birebir *"Pinleme, algoritma-karıştırma sınıfını tek satırla kapatır"* diyordu. **Ölçüm bunu yalanlıyor:**
> 1. Simetrik anahtarla **RS256/ES256 yapısal olarak zaten reddedilir** (`SymmetricSignatureProvider` yalnız `HmacSha256/384/512` + `Aes*CbcHmacSha*` üretir) ⇒ testi RS256 ile yazan bir builder'da mutant **hayatta kalır = kör kapı**.
> 2. **`alg:none`'ı kapatan `ValidAlgorithms` değil `RequireSignedTokens`'tır** ⇒ testi `alg:none` ile yazan bir builder'da da mutant hayatta kalır.
> 3. Pinlemenin kapattığı **tek** şey **aynı anahtarla HS384/HS512 ikamesidir** — ve o anahtara sahip bir saldırgan zaten HS256 imzalayabilir.
> **Sonuç:** ayar **TUTULUR** (ileride asimetrik anahtar eklenirse kritik olur) ve **DAR bir kapıdır**: M16'nın `alg` ayağı **HS512 ikamesine** pinlenir — ve **ısırdığı bu turda doğrulandı** (`SymmetricSignatureProvider` yalnız 128 bitlik asgariyi uygular ⇒ 32 baytlık anahtar HS512 imzalayabilir ⇒ pin kaldırılırsa token **kabul edilir** ⇒ test kırılır). `ClockSkew` ayağı olduğu gibi kalır.
> **[Ma-16 — TEK STATÜ]** v3 bu satıra üç farklı statü veriyordu (*"kapı değil hijyendir"* · *"kapı sayılmaz"* · §3.1'de *"`alg` istisnadır çünkü sessiz varsayılanı değiştirir"*). **v4'ün tek statüsü:** ***`ValidAlgorithms` DAR AMA GERÇEK BİR KAPIDIR; kapsamı yalnız aynı-anahtar HS384/HS512 ikamesidir ve M16'nın ikinci ayağı onu ısırır.*** Belgenin üç yerinde de bu cümle geçerlidir.

> **⚠ `MapInboundClaims=false`'UN ÖLÇÜLMÜŞ YAN ETKİSİ — ÜÇ YERİ VURUR (kaynaktan doğrulandı, 25 Tem 2026):**
> `ClaimTypeMapping.InboundClaimTypeMap` birebir `{ JwtRegisteredClaimNames.Sub, ClaimTypes.NameIdentifier }` girdisini taşır; `JwtBearerOptions.MapInboundClaims` varsayılanı **`true`**'dur ve `false` yapıldığında **çeviri hiç koşmaz** ⇒ `ClaimTypes.NameIdentifier` **DOLMAZ**.
> 1. **Bu belgede:** `ICurrentUser` `ClaimTypes.NameIdentifier` okursa **her istekte `UnauthenticatedException`** ⇒ **`"sub"` doğrudan okunur** (K3-D2, kapı **M24**).
> 2. **ADR 0004'te:** `DefaultUserIdProvider.GetUserId` = `connection.User.FindFirst(ClaimTypes.NameIdentifier)?.Value` ⇒ SignalR `Context.UserIdentifier` **`null`** düşer, `user:{id}` grubu **sessizce** hiçbir istemciye ulaşmaz. Özel `IUserIdProvider` **zorunludur** (**D-1**, §7).
> 3. **[YENİ — D2-#5] `NameClaimType`/`RoleClaimType` bağımsızdır** ⇒ `ClaimTypes.Name` eşlemesi de koşmaz, **`User.Identity.Name` `null` kalır.** Bu kapsamda etkisizdir (token'da `name` talebi yok, roller kapsam dışı) **ama işbirliği diliminde canlanır** — o dilim `User.Identity.Name`'e dayanırsa sessizce boş görünen kullanıcı adları üretir. **Adlandırıldı; 0004/işbirliği diliminin girdisidir.**

**K3-C8 — `security_stamp` BUGÜN ÖLÜ ALANDIR — BİLİNÇLİ VE BEYAN EDİLMİŞ. [K14-d — Ma-5 kapanır]**
Kolon (`User.security_stamp`) ve talep (`sstamp`) **vardır**; **doğrulaması yoktur** ve hiçbir olayda değişmez. Bu bir unutma değil, bir karardır.

- **Sunulmamış ödünleşim, artık sunuluyor:** `/logout-all` (ve ileride parola değişimi) `security_stamp`'i artırsaydı ve her korumalı istekte token'daki `sstamp` DB'dekiyle karşılaştırılsaydı, **Risk #3'ün 15 dakikalık penceresi sıfıra inerdi**. Bedeli: **istek başına bir DB okuması**.
- **Neden yapılmadı:** **K3-K3 zaten *"anlık erişim-token'ı iptali (kara liste)"* kalemini KAPSAM DIŞI ilan etmişti.** Doğrulamayı eklemek o kapsam kararını **sessizce geri almak** olurdu — ve bu belgenin doktrini *"beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez"*dir.
- **Ne için duruyor:** ileride parola değiştirme ya da anlık iptal kapsama girerse **kancanın hazır olması** için. O gün geldiğinde eklenecek olan şey **doğrulamadır**, şema değişimi değil.
- *Reddedilenler:* canlandırma (istek başına 1 DB okuması + kapsam genişlemesi) · kolonu ve talebi **tamamen kaldırmak** (ileriye kanca kalmaz; K3-C4'ün *"kanca bırakır"* cümlesi de düzeltilmek zorunda kalırdı).
- **Kapısı yoktur ve bu §3.1'de açıkça beyan edilir** — ölü bir alanın mutantı da ölü olurdu.

### D. `ICurrentUser` sözleşmesi [K-D5'in sözleşme ayağı]

**K3-D1 — Şekil.** `Application` katmanında: `Guid UserId { get; }` — kimlik yoksa **`UnauthenticatedException` FIRLATIR**, `Guid.Empty` **DÖNDÜRMEZ** — ve `bool IsAuthenticated { get; }`. *Gerekçe:* `Guid.Empty` sessizce sorguya sızar ve "hiçbir şey döndürmeyen ama patlamayan" bir filtre kurar — **deny-by-default'un en sinsi ihlali**. Kapı: **M15**.

**K3-D2 — Implementasyon `HttpContext.User`'dan `"sub"` claim'ini okur, `scoped` ömürlüdür.** `ClaimTypes.NameIdentifier` **okunmaz**. Değer `Guid.TryParse` ile ayrıştırılır; ayrıştırılamazsa `UnauthenticatedException`.

**K3-D3 — ⚠ ARKA PLAN SERVİSİ TUZAĞI.** `OutboxDispatcher` bir `BackgroundService`'tir (singleton) ve **`HttpContext`'i yoktur**. Bir `scoped ICurrentUser`'ı oradan çözmek ya çalışma-zamanı hatası ya da **daha kötüsü** sessiz yanlış kimlik üretir. **Kural:** dispatcher owner-filtreli hiçbir sorguya dokunmaz; outbox okuması **açıkça filtresizdir**. *(İstisnanın allowlist'i ve filtre tarafı **0004**'ün işidir.)* Kapı: **M19**.

**K3-D4 — `User.Identity.Name` KULLANILMAZ. [D2-#5]** `MapInboundClaims=false` altında `ClaimTypes.Name` eşlemesi koşmaz ⇒ `User.Identity.Name` **`null`**'dur. Kullanıcıyı tanımlayan tek kaynak `ICurrentUser.UserId`'dir. *Bu kural bugün etkisizdir ama işbirliği dilimi için yazılmıştır: orada "kim yazdı" gösterimi `User.Identity.Name`'e dayanırsa **sessizce boş** görünür.*

### I. Sırlar [kırmızı çizgi #1]

**K3-I1 — TEK KÖK ANAHTAR (`Momentum:MasterKey`) REPOYA GİRMEZ. [K16-c]** Geliştirmede `dotnet user-secrets` **veya K3-I3'ün bootstrap dosyası**, üretimde ortam değişkeni. **Varsayılan/gömülü anahtar YOKTUR.**
> **🔴 v3'TE İKİNCİ BİR SIR SESSİZCE VAR SAYILIYORDU — B8 KAPANIYOR.** K3-L3(3) *"sunucu HMAC'i **kendi anahtarıyla** yeniden hesaplar"* diyordu; **hangi anahtar?** K3-I1/I2/I3 yalnız JWT imzalama anahtarını düzenliyordu, §2-M yalnız *"`System.Security.Cryptography`"* diyordu, §3.1 kalemi hiç anmıyordu. Belgenin doktrini *"sessiz varsayılan yoktur"* iken JWT anahtarı için **üç madde**, ikinci sır için **sıfır satır** vardı. **Asıl kırılma:** ikinci anahtar efemer seçilirse `docker compose restart` sonrası her web kullanıcısının `__Host-mct` çerezi doğrulanamaz ⇒ `/refresh` reddedilir ⇒ değerlendirici *"oturum düştü"* görür — ve **K3-I3'ün açık vaadi** (*"sonraki açılışlar aynı anahtarı okur ⇒ mevcut oturumlar restart'ta düşmez"*) **web ayağında kanıtsız** kalırdı. K15-a üçüncü bir sır adayı daha doğurunca (halef şifreleme) karar **zorunlu** hâle geldi.

**K3-I2 — Anahtar yoksa uygulama AÇILMAZ (fail-fast); ANAHTARIN KODLAMASI PİNLİDİR.** Eksik veya **çözülmüş hâli 32 bayttan kısa** kök anahtarda başlangıçta `InvalidOperationException`.
- **[B4'ün ikinci ayağı — v3 bunu yazmamıştı]** Anahtarın tel/dosya biçimi **`Base64` (standart, dolgulu)** olarak pinlenir; uygulama onu **çözer** ve **çözülmüş bayt sayısını** ölçer. v3 *"32 bayttan kısa"* diyordu ama **neyin** 32 baytı belirsizdi ⇒ builder karakter sayısını ölçerse 24 baytlık bir anahtar (32 karakterlik Base64) **fail-fast'ten geçerdi**.
- Fail-fast **tek anahtarı** kontrol eder (K16-c sayesinde ikinci/üçüncü sır yoktur) ve **üç kullanımı birden** güvenceye alır.

**K3-I4 — ANAHTAR TÜRETME: TEK KÖK + HKDF-SHA256, ÜÇ AMAÇ-BAĞLI ALT ANAHTAR. [K16-c — bloker B8 + K15-a'nın anahtar ayağı]**
Üç kriptografik kullanım vardır ve **hiçbiri kök anahtarı doğrudan kullanmaz**:

| kullanım | alt anahtar | `info` etiketi (birebir) | uzunluk | nerede |
|---|---|---|---|---|
| JWT HS256 imzalama | `K_jwt` | `"momentum:v1:jwt-sign"` | 32 bayt | `IAccessTokenIssuer` + `TokenValidationParameters.IssuerSigningKey` |
| CSRF token HMAC'i | `K_csrf` | `"momentum:v1:csrf-hmac"` | 32 bayt | `ICsrfTokenService` (K3-L3) |
| Halef sırrı şifreleme | `K_rt` | `"momentum:v1:rt-successor-enc"` | 32 bayt | `IRefreshTokenService` — AES-256-GCM (K3-C2) |

- **Türetme:** `HKDF.Expand(HashAlgorithmName.SHA256, prk: masterKey, outputLength: 32, info: <etiket>)` — `System.Security.Cryptography.HKDF` **BCL'dedir** (.NET 5+), yeni paket **yok** (kırmızı çizgi 3 tetiklenmez). *(`Extract` adımı atlanır: kök anahtar zaten 32 bayt yüksek-entropili CSPRNG çıktısıdır; HKDF-Expand doğrudan uygulanabilir.)*
- **`info` etiketleri PAZARLIKSIZDIR ve `v1` taşır** — ileride anahtar rotasyonu gerekirse etiket `v2` olur ve **üç alt anahtar birlikte döner**.
- **Neden türetme, üç ayrı sır değil:** K15-a'nın kısıtı birebir *"üçüncü bir sır doğmasın"*dı. Türetme (a) tek bootstrap · (b) tek fail-fast · (c) tek `.gitignore` kalemi verir, **ve yine de anahtar-amaç ayrımını korur**: `K_csrf` sızsa bile JWT imzalanamaz. *Reddedilenler [adlandırılmış]:* **üç ayrı anahtar** (en açık ayrım; bedeli üç fail-fast + üç bootstrap ayağı + üç mutant ve K15-a'nın kısıtının reddi) · **iki anahtar** (CSRF ile şifreleme aynı sırrı paylaşır — anahtar-amaç ayrımını kısmen bozar, denetçi bulur) · **kök anahtarı doğrudan üç yerde kullanmak** (aynı anahtarla hem imzalamak hem şifrelemek: kriptografik olarak en kötü seçenek).
- **Kapı: M42.**

**K3-I3 — GELİŞTİRME BOOTSTRAP'I: COMPOSE İLK AÇILIŞTA RASTGELE ANAHTAR ÜRETİR. [K14-b — bloker #8 kapanır]**
**Kırılan senaryo:** K3-I2 anahtarsız başlangıcı patlatıyor (doğru), K3-I1 gömülü anahtarı yasaklıyor (doğru) — ama **`dotnet user-secrets` klonla gelmez.** Değerlendirici `docker compose up` der, **hiçbir şey ayağa kalkmaz**; K14-e gereği web de aynı süreçten servis edildiği için **uygulama hiç görünmez**. ODEV §2 (*"kesinlikle çalışan bir uygulama; önce uygulamaya bakılacak"*) doğrudan vurulur. Compose dosyasına sabit anahtar yazmak ise **kırmızı çizgi #1** ihlalidir. **v2 bu ikilemi hiç kurmuyordu.**

**Karar:**
- Konteynerin giriş betiği, `ASPNETCORE_ENVIRONMENT=Development` **ve** anahtar dosyası yoksa, **CSPRNG ile 32 bayt üretip Base64'leyerek** git-ignore'lu bir dosyaya yazar: **`./.secrets/momentum-master.key`**, mount edilmiş bir volume'de. Sonraki açılışlar **aynı** anahtarı okur ⇒ mevcut oturumlar restart'ta düşmez — **ve K16-c sayesinde bu vaat JWT, CSRF ve halef şifrelemesinin ÜÇÜ için birden geçerlidir** (tek kök ⇒ tek dosya ⇒ tek yaşam döngüsü).
- **`Production` yolunda bu kod ASLA koşmaz.** Üretimde eksik anahtar **hâlâ patlar** (K3-I2 aynen geçerli).
- `.gitignore`'a `.secrets/` eklenir; `.env.example` yine bulunur (ortam değişkeni adlarını belgelemek için) ama **içinde anahtar yoktur**.
- **Dosya adı ve biçimi pinlidir** (K3-I2): tek satır, standart Base64, çözülmüş **32 bayt**.

**M8 İKİ AYAKLI OLUR [bloker #8'in kapısı]:**
1. **M8a** — *"`Production`'da anahtarsız/kısa anahtarlı başlangıç **patlar**"* — mutasyon: fail-fast kaldırılır → FAIL. **Seviye `B`.**
2. **M8b** — *"`Development` bootstrap'ı **`Production` yolunda ASLA koşmaz**"* — mutasyon: giriş betiğindeki ortam koşulu kaldırılır (her ortamda üretir) → **`Production`'da anahtarsız başlangıç artık patlamaz** → FAIL. **Bu ikinci ayak olmadan bootstrap'ın kendisi bir güvenlik açığı kapısıdır.**
   > **🔴 M8b v3'TE ÖLDÜRÜLEMEZDİ — SEVİYE DÜZELTİLİYOR [B4].** Mutasyon **konteynerin giriş betiğindedir** ama v3 seviyesini **`B` (saf birim)** yazmıştı; hiçbir C# birim/`TestServer` testi bir ENTRYPOINT betiğini gözlemleyemez ve §3'ün seviye sözlüğünde **konteyner seviyesi yoktu**. Builder `B`'yi okur, var olmayan bir sınıfa test yazar, **yeşil geçer**; gerçek yol **kapısız** kalır. **Düzeltme:** §3'ün sözlüğüne **`KON` (konteyner/E2E)** eklendi ve M8b oraya taşındı. Kill sinyali artık gözlemlenebilir bir dış davranıştır: *"`docker run -e ASPNETCORE_ENVIRONMENT=Production` ile **anahtarsız** açılan konteyner **sıfırdan farklı** çıkış kodu verir **ve** `./.secrets/momentum-master.key` **oluşmaz**"*. *Reddedilen alternatif [adlandırılmış]:* bootstrap'ı `Program.cs`'e taşımak (`IHostEnvironment.IsDevelopment()`) ⇒ seviye `TS` olurdu ve `KON` gerekmezdi; **reddedildi** çünkü anahtarı **uygulama sürecinin kendisinin** üretmesi, dosya sistemine yazma iznini uygulama katmanına taşır ve `Production` imajında **ölü ama var olan** bir yazma yolu bırakır.

*Reddedilenler:* `.env.example` + README adımı (en şeffaf, ama `docker compose up` tek başına yetmez ⇒ ODEV §2 değerlendiricinin README okumasına bağlanır) · repoda `DEVELOPMENT ONLY` etiketli sabit anahtar (en kolay açılış, ama kod kalitesi ölçen bir değerlendirici repoda sır görür — gerekçe yazılsa bile kötü sinyal).

### J. Uçlar + kaba kuvvet

**K3-J1 — Uçlar, deny-by-default ve STATİK DOSYA SIRASI. [K14-e ile birlikte okunur]**
Uçlar: `POST /v1/auth/register` · `/login` · `/refresh` · `/logout` · `/logout-all`. İlk üçü `AllowAnonymous`; **`/logout` ve `/logout-all` kimlik ister** (Bearer + `fid`). **Diğer her uç deny-by-default** — `FallbackPolicy = RequireAuthenticatedUser` (K-D5). `/health/live` ve `/health/ready` anonim kalır (K-D2).

> **🔴 v2'DE BU MADDE SPA'YI ÖLDÜRÜYORDU [bloker #3, dal (a)].** MS Learn birebir: *"For requests served by other middleware after the authorization middleware, such as **static files**, the policy applies to **all requests**."* ⇒ `FallbackPolicy` ile `GET /` ve SPA'nın her derin linki (`/tasks`, `/settings`) **`401`** döner ⇒ **giriş ekranına fiziksel olarak ulaşılamaz.** v2 bunu ne görüyor ne kaçış yolunu yazıyordu. **M14 bu yönü ısırmaz** — M14 tersini test eder.

**PAZARLIKSIZ MIDDLEWARE SIRASI (K14-e'nin doğrudan sonucu; `UseRateLimiter` [Ma-11] ile tamamlandı):**
```
UseForwardedHeaders  ❌ YOK (K14-e: proxy yok — gerekçesi K3-L4'te DÜZELTİLDİ)
UseDefaultFiles      →  UseStaticFiles        ← auth'tan ÖNCE
UseRouting
UseRateLimiter                                ← UseRouting'den SONRA, auth'tan ÖNCE
UseAuthentication    →  UseAuthorization
MapControllers / MapGroup("/v1")
MapFallbackToFile("index.html").AllowAnonymous()   ← AÇIKÇA anonim
```
> **🔴 v3 `UseRateLimiter`'I HİÇ ANMIYORDU [Ma-11].** Blok `UseForwardedHeaders`'ın **yokluğunu** bile yazıyordu ama §2-J'nin tamamının dayandığı çağrıyı yazmıyordu. **Yerin iki sonucu vardır ve ikisi de sessizce yanlış olabilirdi:**
> - **`UseRouting`'den ÖNCE** konursa uca bağlı politikalar (`RequireRateLimiting`) **hiç çözülemez** ⇒ yalnız global limiter koşar ⇒ `/login` ile `/refresh` ayrımı (K16-b) **fiilen kaybolur**.
> - **`UseStaticFiles`'tan ÖNCE** konursa Flutter web build'inin **onlarca asset isteği** kovayı ilk saniyede tüketir ⇒ değerlendirici sayfayı açar açmaz `429` görür. **Statik dosyalar hız sınırının DIŞINDADIR** ve bu bilinçlidir: onlar Argon2 çalıştırmaz, DB'ye dokunmaz.
>
> **Kapı: M46** — mutasyon: `UseRateLimiter`, `UseStaticFiles`'tan **önceye** alınır. Kill sinyali: *"kimliksiz **40 statik dosya** isteğinden **sonra** `/v1/auth/login` isteği **`429` ALMAZ**"* **FAIL**. Seviye `TS`.

**Kapı: M33a / M33b** — v3'ün tek M33'ü **ikiye bölündü**; gerekçesi hemen aşağıda.

> **🔴 v3'ÜN M33'Ü AYIRT EDİCİ DEĞİLDİ VE BASELINE'I YOKTU — DÜZELTİLİYOR [B6, ölçüldü].**
> **ÖLÇÜM (dotnet/aspnetcore `release/9.0`, `StaticFilesEndpointRouteBuilderExtensions.cs`):** `MapFallbackToFile` ürettiği `RequestDelegate` içinde `context.Request.Path = "/" + filePath;` yapar, `context.SetEndpoint(null);` çağırır ve **kendi `app.UseStaticFiles()`'ını kurar**; varsayılan kalıp **`{*path:nonfile}`**'dır. Sonuçları:
> 1. `GET /tasks` **fallback ucuna** eşleşir (`AllowAnonymous`) ⇒ `index.html` **fallback'in kendi statik middleware'inden** gelir ⇒ **üst seviye `UseStaticFiles`'ın YERİ bu sinyali hiç etkilemez** ⇒ mutasyon uygulandığında da `200` döner = **kör kapı**.
> 2. Farkın gerçekte yaşadığı yer test **edilmiyordu**: `GET /main.dart.js` gibi **dosya-benzeri** bir yol `{*path:nonfile}` kısıtına **düşmez** ⇒ endpoint `null` kalır ⇒ statik middleware auth'tan **sonraysa** `FallbackPolicy` devreye girer ve **`401`** verir. **Doğru kill sinyali budur.**
> 3. **Baseline yoktu:** `slice-3c` `slice-3b`'den **önce** koşar (K14-h'nin kendi kabulü) ⇒ `wwwroot/index.html` **henüz yoktur** ⇒ fallback `404` verir ⇒ test **baseline'da kırmızı doğar = ölü tuzak.**
> 4. **Mekanizma tarifi de eksikti:** `AllowAnonymousAttribute` bir `IAuthorizeData` **değildir**; `AuthorizationPolicy.CombineAsync` yine `FallbackPolicy`'ye düşer — SPA'yı kurtaran şey `AuthorizationMiddleware`'in **ayrı `IAllowAnonymous` kontrolüdür.**
>
> **Düzeltmeler:**
> - **TEST FİXTURE'I ŞART KOŞULUR:** test derlemesinin içerik kökünde **`wwwroot/index.html`** ve **en az bir dosya-benzeri varlık** (`wwwroot/main.dart.js`) **yer tutucu olarak bulunur**. Bu bir test detayı değil, **bu kapının önkoşuludur** ve ADR'de yazılıdır.
> - **M33a** — mutasyon: fallback ucundan **`AllowAnonymous` kaldırılır**. Kill: *"kimliksiz `GET /tasks` **`200`** döner ve gövdesi `index.html`'dir"* **FAIL**.
> - **M33b** — mutasyon: **`UseStaticFiles` auth middleware'inden sonraya alınır.** Kill: *"kimliksiz `GET /main.dart.js` **`200`** döner **ve gövdesi `index.html` DEĞİLDİR**"* **FAIL**.
> - **K3-J1'in gerekçesi düzeltilir:** SPA'yı 401'den kurtaran şey `UseStaticFiles`'ın yeri **değil**, fallback ucundaki `AllowAnonymous`'tur. `UseStaticFiles`'ın yeri **dosya-benzeri yolları** kurtarır. **İkisi ayrı mekanizmadır ve v3 bunları tek cümlede birleştiriyordu.**

**K3-J2 — Kaba kuvvet savunması ÜÇ AYRI KONTROLDÜR; ÜÇÜ AYRI ŞEY KORUR; SAYILARI YAZILIR. [K11 kilidi + R2 + bloker #5 + bloker #13]**
`Microsoft.AspNetCore.RateLimiting` (middleware ayağı) + `System.Threading.RateLimiting` (handler ayağı) — **çerçevede yerleşik, yeni NuGet YOK** (kırmızı çizgi 3 tetiklenmez).

| # | kontrol | nerede koşar | anahtar | **sayı [K16-b]** | neyi korur | neyi KORUMAZ |
|---|---|---|---|---|---|---|
| **1a** | Sabit pencere — **`/login` + `/register`** (Argon2 yolu) | **middleware** | `RemoteIpAddress` ile **anahtarlanır**, ama tek konteynerde **fiilen KÜRESELDİR** (aşağıda) | **30 istek / 5 dk**, `QueueLimit=0` | Maliyet/DoS **tavanı** | Botnet/proxy havuzu · **kullanıcı ayrımı** (küresel olduğu için) |
| **1b** | Sabit pencere — **`/refresh`** (Argon2 **KOŞMAZ**) | **middleware** | aynı | **120 istek / 5 dk**, `QueueLimit=0` | Yenileme fırtınası | — |
| **1c** | Sabit pencere — **`/logout` + `/logout-all`** | **middleware** | aynı | **60 istek / 5 dk** | DB yazma fırtınası (K3-J6) | — |
| **2** | Sabit pencere — yalnız `/login` | **handler içi** (K14-f) | **normalize e-posta** | **5 deneme / 15 dk** | **Tek hesaba parola deneme** | **DoS'u KORUMAZ** — anahtarı saldırgan seçer |
| **3** | Eşzamanlılık limiti — **her Argon2 çağrısı (hash VE verify)** | **handler içi** | küresel (partition yok) | izin = `ProcessorCount`, `QueueLimit = 2×ProcessorCount` | **Argon2'nin bellek/CPU çarpanı** | — |

> **🔴 KONTROL 1 TEK KONTEYNERDE FİİLEN KÜRESEL BİR TAVANDIR — v3'ÜN İDDİASI ÖLÇÜMLE YANLIŞLANDI [B2 / K15-b].**
> v3 (K3-L4/K14-e) birebir şöyle diyordu: *"`RemoteIpAddress` **GERÇEK** istemci IP'sidir ⇒ `UseForwardedHeaders` hiç gerekmez ve K3-J2(1) yaşar. Bu, blokerin en sinsi ayağını **doğmadan** kapatır."*
> **ÖLÇÜM — GERÇEK KOŞU, Onur'un makinesi, 25 Tem 2026 (Docker 29.6.1 / compose v5.3.0):** `docker run --rm -d -p 18080:80 nginx:alpine` → üç ayrı yoldan istek → nginx access log: **`http://localhost` → `172.17.0.1`** · **`http://127.0.0.1` → `172.17.0.1`** · **`http://192.168.0.41` (LAN) → `172.17.0.1`**. Konteyner içi yönlendirme: `default via 172.17.0.1 dev eth0`. **Üç yolda da köprü ağ geçidi; gerçek istemci IP'si hiçbirinde yok** — LAN yolu bile kurtarmıyor. Mekanizma: Docker port yayımlama bir **NAT**'tır; resmî `dockerd` referansı `--userland-proxy`'yi *"Use userland proxy for **loopback traffic**"* varsayılan **`true`** olarak tanımlar, Docker Desktop'ta trafik ayrıca VM sınırından geçer. **Üstelik K3-L4 zaten `http://localhost:PORT` kullanımını ZORUNLU kılıyor** ⇒ trafik tam olarak proxy'lenen yola sokuluyor.
> **[KARAR K15-b] İDDİA GERİ ÇEKİLİR, SINIR ADLANDIRILIR; K14-e DURUR.** Tek konteyner + reverse-proxy yok kararı **korunur** — CORS ve `SameSite` gerekçeleri ölçümden bağımsız olarak sağlamdır. Geri çekilen yalnız **yanlış çıkan ayaktır**. Belgenin bugünkü dürüst ifadesi şudur:
> ***"Bu dağıtımda kontrol 1 KÜRESEL bir hız sınırıdır. Kod `RemoteIpAddress` ile anahtarlanır (partitioner değişmez), ama tek konteynerde tüm istekler köprü ağ geçidinden geldiği için pratikte TEK partition oluşur. Kontrol 1 bir kullanıcı-ayrımı mekanizması DEĞİL, servisin toplam Argon2 yüküne konmuş bir TAVANDIR."***
> **Bunun dört doğrudan sonucu vardır ve dördü de bu belgede uygulanmıştır:**
> 1. **Sayılar yükseltildi ve `/refresh` ayrıldı** (K16-b — yukarıdaki tablo). v3'ün 10/5 dk'lık ortak kovası, K3-L2 gereği **her F5 bir `/refresh` olduğu için** iki kullanıcılı işbirliği demosunu ODEV §2'nin ortasında kesiyordu (B3).
> 2. **K3-J5'in *"tavanı anlamlı kılan şey IP penceresidir"* cümlesi yanlıştır ve düzeltildi.**
> 3. **§6 Risk #5 düzeltildi**, **Risk #14** eklendi (*tek istemci tüm tavanı tüketebilir*).
> 4. **Argon2'yi asıl koruyan kontrol 3'tür (eşzamanlılık), kontrol 1 değil.** Bu, v3'te de doğruydu ama kontrol 1'e fazla kredi veriliyordu.
> *Reddedilenler [adlandırılmış]:* **reverse-proxy'ye dönüş** (gerçek IP gelir; bedeli `UseForwardedHeaders` + `KnownProxies/KnownNetworks` yapılandırması **ve** M11/M23'ün `X-Forwarded-For` enjekte eden testlere taşınması — dağıtım tek birim olmaktan çıkar, K14-e yeniden açılır) · **IP anahtarını tamamen bırakıp açıkça küresel bir limiter yazmak** (en dürüst kod ama **R2'nin kapısı olan M23'ün konusu kalmaz**: *"partition'ı e-postaya çevirme"* mutasyonu anlamsızlaşır ⇒ bir kör kapıyı kapatmak için başka bir kapıyı silmek olurdu).
> **[R2'NİN TOPOLOJİK İKİZİ, ADIYLA]** v1'in hatası *"partition'ı **saldırgan** seçer"*di; buradaki olgu *"partition'ı **Docker'ın kendisi** siler"*dir. İkisi de aynı sınıftır: **bir kontrolün anahtarı, o kontrolü yazan kişinin denetiminde değilse kontrol yoktur.**

> **[Ma-1 kapatıldı]** v2 kontrol 3'ü *"parola **doğrulama** işi"* diye tanımlıyordu ⇒ `/register`'ın Argon2 **hash**'i kapsam dışı kalıyordu ve Risk #4'ün telafi cümlesi `/register` yolunda yanlıştı. Tanım artık **"her Argon2 çağrısı"**dır.

> **🔴 v2'NİN KONTROL 2'Sİ SEÇİLEN MEKANİZMAYLA İNŞA EDİLEMİYORDU [bloker #5].** E-posta istek **gövdesindedir**; `RateLimiterOptions.AddPolicy` partitioner'ı **senkron** bir delegedir (`Func<HttpContext, RateLimitPartition<T>>`; üç aşırı yüklemenin **üçü de** senkron, `ValueTask` varyantı yok) ⇒ gövde `await` edilemez, `EnableBuffering` + senkron okuma Kestrel'in `AllowSynchronousIO=false` varsayılanına çarpar. Builder'ın kaçınılmaz seçimi limiti handler'a taşımaktı — **ve bu, v2'nin K3-J3'teki bağlayıcı sırasını sessizce bozardı.**
> **[K14-f] Karar:** kontrol 2 **açıkça** handler içindedir; DI'dan alınan bir `PartitionedRateLimiter<string>` ile koşar (gövde o noktada zaten deserialize edilmiştir). *Reddedilenler:* anahtarı bir başlıktan almak (**anahtarı istemci seçer ⇒ R2'nin kapattığı hata sınıfı aynen geri gelir**) · kontrol 2'yi tamamen kaldırmak (tek hesaba yavaş parola denemesi sınırsız kalırdı).

> **🔴 KONTROL 2'NİN KAPISI v3'TE HİÇ YOKTU — B7 KAPANIYOR.** K14-f, bloker #5'i kapatmak için **kilitlenen çataldı**; ama v3'ün mutant tablosunda **kontrol 2'yi kaldıran hiçbir mutant yoktu** (M11 → kontrol 1, M22 → kontrol 3, M23 → IP partition) **ve §3.1'in "mutantsız olduğu açıkça yazılanlar" listesinde de geçmiyordu.** §3 *"bu tablo … spec'in mutant listesinin **kimlik-çekirdeği yarısıdır**"* diyerek, §3.1 *"**bu liste, tablonun tamlık iddiasının sınırıdır**"* diyerek **tamlık iddia ediyordu** ⇒ *"kapattım"* denen bir bloker, **kapısız bir mekanizmayla** kapatılmış sayılıyordu. Bu, belgenin kendi doktrininin (**KÖR KAPI YOK**) ihlaliydi.
> **Kapı: M41 — iki ayaklı.** Mutasyon: handler'daki e-posta penceresi kaldırılır.
> 1. *"**aynı** normalize e-posta ile **6.** `/login` denemesi `429` alır **ve** `problem.Extensions[\"limit\"] == \"email\"`"* **FAIL**.
> 2. *"**aynı IP'den farklı e-postalarla** gelen 6. istek `429` **ALMAZ**"* **FAIL** — bu ikinci ayak **R2'yi de korur**: kontrol 2'nin anahtarının e-posta olduğunu, IP olmadığını ısırtır. *(Kontrol 1'in tavanına çarpmamak için test **6 istekle sınırlıdır**; 30/5 dk tavanının altındadır.)*
> Seviye **TS**. Önkoşul: kontrol 1'in tavanı bu testte tetiklenmemelidir (K16-b sayıları bunu zaten sağlar).

**R2'nin kırdığı yer, kayda geçmeye devam ediyor:** v1'in anahtarı **IP + e-posta birleşimiydi**. Saldırgan her istekte rastgele bir e-posta yazarak **her seferinde yeni bir partition** yaratır ⇒ sayaç **hiç dolmaz**, ama her istek **270 ms + 19 MiB sahte Argon2** yakar. **Ayrım şudur: DoS'u durduran (1) ve (3)'tür; (2) hesabı korur ve bir DoS kontrolü olarak SAYILMAZ.**

**K3-J3 — BAĞLAYICI SIRA [K14-f ile yeniden yazıldı].**
```
middleware:  IP penceresi (kontrol 1)
     ↓  geçerse
handler:     gövde deserialize + girdi doğrulama (K3-B6)
     ↓
handler:     e-posta penceresi (kontrol 2)
     ↓
handler:     eşzamanlılık limiti (kontrol 3)
     ↓
             gerçek VEYA sahte Argon2  ← limit aşılmışsa BURAYA HİÇ GELİNMEZ
```
Sıra bağlayıcıdır: limit aşılmışsa **hiç Argon2 koşmaz**. Aksi hâlde K3-B5'in zamanlama savunması kendisini bir **DoS amplifikatörüne** çevirirdi. *(v2'de sıra middleware'de varsayılıyordu; K14-f onu tek bir kod yolunda **görünür** kıldı — bağlayıcılık zayıflamadı, aksine test edilebilir hâle geldi.)*

**K3-J4 — REDDİN YANITI: `429` AÇIKÇA YAZILIR; VARSAYILAN `503`'TÜR. [bloker #7 kapanır]**
> **🔴 ÖLÇÜM (dotnet/aspnetcore `release/9.0`, `RateLimiterOptions.cs`):** `public int RejectionStatusCode { get; set; } = StatusCodes.Status503ServiceUnavailable;` — XML doc birebir *"Defaults to StatusCodes.Status503ServiceUnavailable"*. Durum kodu `OnRejected` **çağrılmadan önce** set edilir; `OnRejected` onu ezebilir.
> **v2 `429` kararını verdi ama override'ı YAZMADI** ⇒ (a) gerçekte `503` dönerdi, (b) `Retry-After` **otomatik değildir**, (c) `503` semantik olarak yanlıştır ve Flutter istemcisinin retry politikasını *"sunucu çökmüş"* diye yorumlatır, (d) **M11/M22/M23'ün kill sinyalleri baseline'da kırmızı doğardı = ölü tuzak.** Bu, §4'teki kendi manşet tezinin (*"bir ADR'nin işi sessiz varsayılanların hangisinin kabul edildiğini yazmaktır"*) **birebir ihlaliydi** — `ClockSkew` için titizlikle yapılan iş burada yapılmamıştı.

**Karar — İKİ AYAK, ÇÜNKÜ `OnRejected` HANDLER LİMİTLERİNİ KAPSAMAZ [Ma-3, ölçüldü]:**

> **🔴 ÖLÇÜM (dotnet/aspnetcore `release/9.0`):** `OnRejected` ve `RejectionStatusCode` **`RateLimiterOptions`'ın üyeleridir** ve yalnız `RateLimitingMiddleware` onları çağırır (`context.Response.StatusCode = _rejectionStatusCode;` + `await thisRequestOnRejected(...)`). **Handler içinde koşan kontrol 2 ve kontrol 3'ü KAPSAMAZLAR** ⇒ v3'ün *"`limit == \"email\"` / `\"concurrency\"` değerleri `OnRejected` tarafından yazılır"* varsayımı yanlıştı ve **M22 baseline'da kırmızı doğardı = ölü tuzak.**

**(a) MIDDLEWARE AYAĞI** (kontrol 1a/1b/1c):
- `options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;` **açıkça yazılır** (varsayılan `503`'tür — aşağıdaki ölçüm).
- `OnRejected` **yazılır**: `Retry-After` başlığını **`FixedWindowLease`'in `MetadataName.RetryAfter`'ından** okur *(ölçüldü: **taşıyor**)*; tek tip `ProblemDetails` gövdesi üretir; `problem.Extensions["limit"] = "ip"` yazar.

**(b) HANDLER AYAĞI** (kontrol 2 ve 3) — **middleware'in değil, handler'ın kendi sorumluluğudur**:
- Handler, lease alınamadığında **`429`** üretir ve **middleware ayağıyla aynı şekilli** `ProblemDetails` gövdesini döndürür (ortak bir `RateLimitProblemFactory` üzerinden — **iki ayrı gövde şekli yazmak yasaktır**, çünkü M22/M23/M41 gövdeyi karşılaştırır).
- `problem.Extensions["limit"]` = **`"email"`** (kontrol 2) veya **`"concurrency"`** (kontrol 3).
- **`Retry-After`:** kontrol 2'de pencere süresinden hesaplanır; **kontrol 3'te YAZILMAZ** — çünkü ölçüldü: **`ConcurrencyLease` `MetadataName.RetryAfter` TAŞIMAZ** (yalnız `ReasonPhrase` taşır) ve eşzamanlılık reddi için anlamlı bir bekleme süresi **yoktur**. Bu bir eksiklik değil, **ölçülmüş bir sonuçtur** ve istemci sözleşmesinde (K3-L8/4) *"`Retry-After` yoksa üstel geri çekilme"* diye karşılanır.
- **(b) şıkkı kozmetik değildir:** M22/M23/M41'in *"hangi limit reddetti"* sorusunu ayırt etmesini sağlar (bloker #13).
- **Hesap KİLİTLEME YOKTUR** — kilitleme, saldırganın kurbanın hesabını kasten kilitlemesine izin verir ve K8-d ile kapsam dışıdır.

> **✅ v3'ÜN `[DOĞRULANMADI]` ETİKETİ KAPANDI — DOKTRİN YİNE KAZANDI.** v3, `ConcurrencyLease`'in `MetadataName.RetryAfter` taşıyıp taşımadığını **ölçmemişti** ve (a) şıkkını **koşullu** yazmıştı. Kapı-3 turunda kaynaktan ölçüldü: **`ConcurrencyLease` TAŞIMIYOR, `FixedWindowLease` TAŞIYOR.** ⇒ koşulluluk kalktı, karar **kesinleşti**, §6 Risk #12 **kapandı** ve §3.1'den ilgili muafiyet **düştü**. *Ölçülmemişi ölçülmemiş diye yazmanın bedeli bir satırlık koşulluluktu; kazancı, üç sürüm sonra hiçbir şeyin geri alınmamasıdır.*

**K3-J5 — ✅ KAPATILDI (v2'de `[DOĞRULANMADI]`, artık ÖLÇÜLDÜ).**
> **ÖLÇÜM (dotnet/runtime `release/9.0`, `DefaultPartitionedRateLimiter.cs`):** `private static readonly TimeSpan s_idleTimeLimit = TimeSpan.FromSeconds(10);` · timer periyodu `TimeSpan.FromMilliseconds(100)` · `if (idleDuration > s_idleTimeLimit) { _cacheInvalid = true; _limiters.Remove(rateLimiter.Key); _limitersToDispose.Add(...); }` + `await limiter.DisposeAsync()`.

**Sonuç, abartısız yazılıyor:** atıl partition'lar **temizlenir** ⇒ *"rastgele e-postalarla sınırsız bellek büyümesi"* endişesi **geçersizdir**. Ama bu **"sıfır bellek" demek değildir**: tavan ≈ **istek hızı × 10 sn** kadar canlı partition'dır.
> **🔴 v3'ÜN İKİNCİ CÜMLESİ DÜZELTİLİYOR [B2/K15-b].** v3 *"tavanı anlamlı kılan şey kontrol 1'in **IP penceresidir**"* diyordu. **Ölçüm bunu yalanladı:** tek konteynerde IP penceresi diye bir ayrım yoktur, kontrol 1 **küresel bir tavandır**. **Doğru ifade:** *"tavanı anlamlı kılan şey kontrol 1'in **küresel istek tavanıdır** (30/5 dk `/login`+`/register`) — bu tavan aynı zamanda canlı partition sayısının da üst sınırını verir."* İkisi birlikte okunur; tek başına hiçbiri yeterli değildir.

**K3-J6 — `/logout` ve `/logout-all` DA HIZ SINIRI KAPSAMINDADIR; NAT YANLIŞ-POZİTİFİ ADLANDIRILIR. [RT-M6 kapanır]**
- v2'de bu iki uç hız sınırı dışındaydı ⇒ çalınmış bir JWT ile **DB yazma fırtınası** (her `/logout-all` bir kullanıcının tüm ailelerine `UPDATE`) mümkündü. **Karar:** ikisi de kontrol 1'e dâhildir — **ayrı ve kendi sayacı olan** bir politika: **60 istek / 5 dk** [K16-b] (meşru kullanım tek hanelidir).
- **[Ma-16 — v3'te belirsizdi] SAYAÇ AYRIDIR, ORTAK DEĞİLDİR.** `/logout`+`/logout-all` politikası (1c) `/login`+`/register` (1a) ve `/refresh` (1b) politikalarından **bağımsız bir partition kümesi** tutar ⇒ çıkış istekleri giriş kovasını **tüketmez**. Üç politika `RequireRateLimiting("auth-login" | "auth-refresh" | "auth-logout")` ile **uç bazında** bağlanır — bu, `UseRateLimiter`'ın `UseRouting`'den **sonra** olmasını zorunlu kılan şeydir (Ma-11).
- **Yanlış-pozitif tarafı, ilk kez adlandırılıyor — ve v4'te İKİ KAT DERİNDİR:** (1) CGNAT ya da kurumsal NAT arkasındaki **tüm** meşru kullanıcılar tek partition'a düşer; (2) **ve bu dağıtımda Docker'ın KENDİ NAT'ı zaten aynı şeyi yapıyor** — `RemoteIpAddress` **her zaman** köprü ağ geçididir (B2'nin ölçümü) ⇒ **yanlış-pozitif teorik değil, VARSAYILAN durumdur.** Bir ofisten değil, **iki farklı kıtadan** bağlanan iki kullanıcı da aynı kovayı paylaşır. Bu, seçilen dağıtımın **kaçınılmaz** bedelidir ve tek-instance bir ödev dağıtımında **kabul edilmiştir** — telafisi K16-b'nin yükseltilmiş tavanlarıdır. Kapatmanın yolu (kullanıcı-anahtarlı ikinci bir katman + dağıtık sayaç) **K3-K3 ile kapsam dışıdır**.

### K. Elenen ve kapsam dışı [ADLANDIRILDI]

**K3-K1 — ASP.NET Core Identity KULLANILMAZ [K8-d].** *Gerekçe:* Identity, `DbContext`'i `IdentityDbContext`'e çevirir, Infrastructure tiplerini yukarı iter ve 7 tablosunun 5'i bu kapsamda kullanılmaz ⇒ **mevcut NetArchTest kapıları gevşetilir veya istisna alır. Kendi kurduğun kapıyı üçüncü parti için gevşetmek, kod kalitesi ölçen bir ödevde verilebilecek en kötü sinyaldir.** Kapsam darken elle implementasyon ~200-300 satırdır. *Reddedilen: melez `PasswordHasher<T>` — hash kararını fiilen PBKDF2'ye kilitlerdi.*

**K3-K2 — İLKE: KRİPTO PRİMİTİFİNİ YAZMAYIZ, AKIŞI YAZARIZ.** Argon2id, SHA-256, **HMAC-SHA256 (CSRF token'ı)**, JWT imzası, CSPRNG — hepsi dışarıdan (paket veya BCL). Elle yazılan yalnız **akıştır**. **Bu ADR'de hiçbir kriptografik primitif implemente edilmemektedir.**

**K3-K3 — Kapsam dışı [adlandırılmış]:** parola sıfırlama · parola **değiştirme** · e-posta doğrulama · OAuth/sosyal giriş · 2FA · RBAC/roller · hesap kilitleme · collaborator/paylaşım yetkisi (işbirliği dilimi) · **anlık erişim-token'ı iptali (kara liste) — K3-C8 bu kararın doğrudan sonucudur** · dağıtık (çok-instance) hız sınırlama sayacı · **kullanıcı-anahtarlı ikinci hız sınırlama katmanı (K3-J6'nın NAT yanlış-pozitifinin çözümü)** · **reverse-proxy dağıtımı (K14-e)**.

### L. İstemci sözleşmesi [K11-f/g + K14-a/c/e — v1'in cevapsız bıraktığı sorular]

> Bu bölüm backend'in **istemciye dayattığı** sözleşmedir. Flutter kodu `slice-3b`'de yazılır ama **bu kararlar Drift şemasını ve depo katmanını bugün belirler** — sonraya bırakmak migration demektir (§1).

**K3-L1 — Token deposu, native (Android/iOS/Windows): `flutter_secure_storage`.** Yenileme token'ı orada; erişim token'ı **yalnız bellekte**.
> **[D2-#21 — v2'nin DPAPI İDDİASI GERİ ÇEKİLİYOR]** v2 *"Keystore / Keychain / **DPAPI**"* diyordu. **Windows şifreleme yöntemi DOĞRULANAMADI**: paket README'si yöntemi söylemiyor; bir denetçi *"AES-GCM + Windows Credential Manager"* dedi, teyit edilemedi. **Bu belgede artık iddia edilmiyor: `[DOĞRULANMADI]`.** Android/iOS ayakları (Keystore/Keychain) README'de yazılıdır. **Web ayağı README'de birebir *"experimental… use at your own risk"* + LocalStorage'dır ⇒ K3-L2'nin web reddi ölçümle DOĞRULANMIŞTIR.**
> *Bağımlılık kapısı (lisans + CVE, kırmızı çizgi 3) `slice-3b` spec'inde koşar. **Lisans ölçüldü: BSD-3-Clause**, 0001 K-H2'nin izinli ailesinde ⇒ kırmızı çizgi 3 tetiklenmiyor. CVE ayağı 3b'de koşar; düşerse K3-L1 yeniden açılır.*

**K3-L2 — Token deposu, web: yenileme token'ı ÇEREZ; ÇEREZ ÖZNİTELİKLERİ TAM YAZILIR. [Ma-8 kapanır]**
v2 çerezi kararlaştırdı ama **adını, `Path`'ini, `Domain`'ini ve ömrünü hiç yazmadı** — dördü de güvenlik sonucu doğuran alanlardır.

| öznitelik | değer | gerekçe |
|---|---|---|
| **ad** | **`__Host-mrt`** (Momentum Refresh Token) | `__Host-` öneki: tarayıcı **`Domain` özniteliğini yasaklar** ve `Path=/` + `Secure` zorunlu kılar ⇒ **kardeş alt alan adı bu çerezi YAZAMAZ** (RT-B2'nin yapısal cevabı) |
| `HttpOnly` | `true` | JS okuyamaz ⇒ tek XSS yenileme token'ını **okuyamaz** |
| `Secure` | `true` | `__Host-` gereği zorunlu; ayrıca K3-L4'ün `localhost` notu |
| `SameSite` | **`Strict`** | klasik çapraz-site CSRF'i kapatır (K14-e sayesinde fiilen çalışır) |
| **`Path`** | **`/`** | `__Host-` öneki `Path=/` **zorunlu kılar** — seçim değil, önekin bedeli. **Sonucu dürüstçe yazılıyor:** yenileme çerezi **her** aynı-origin isteğinde tele çıkar (statik dosyalar dâhil). Kabul ediliyor çünkü `__Host-`'un çerez-enjeksiyonu bağışıklığı bu maliyetten daha değerli; ve K14-c gereği **sunucu çerezi yalnız `/refresh`'te okur**. |
| **`Domain`** | **YAZILMAZ** | `__Host-` bunu yasaklar |
| **ömür** | **`Max-Age` = ailenin kalan `expires_at`'i (≤30 gün)** — oturum çerezi **DEĞİL** | Oturum çerezi olsaydı **tarayıcı kapanınca çıkış** olurdu = K11-f'in **reddettiği** "F5 = çıkış" şıkkının kardeşi. Her `/refresh`'te `Max-Age` **yeniden hesaplanır** (uzatılmaz — `expires_at` sabittir, K3-C2). |

Erişim token'ı web'de de **yalnız bellektedir** (sekme-yerel).
*Reddedilenler:* web'de yalnız bellek (F5 = çıkış) · her platformda `flutter_secure_storage` (web'de LocalStorage'a düşer ⇒ "secure" adı yanıltıcı olur, README'nin kendisi *"use at your own risk"* diyor).

**K3-L3 — CSRF: İKİ KATMAN; İKİNCİ HAT İMZALIDIR VE AİLEYE BAĞLIDIR. [RT-B2 — bloker #4 kapanır]**

> **🔴 v2'NİN İKİNCİ HATTI, TUTULMA GEREKÇESİ OLAN VEKTÖRE KARŞI GEÇERSİZDİ.** Saldırı: saldırgan kardeş bir alt alan adını ele geçirir (DNS takeover / unutulmuş statik site / oradaki bir XSS) → `Set-Cookie: csrf=SALDIRGAN; Domain=momentum.app; Path=/` yazar (**çerezler origin değil domain kapsamlıdır**) → kurbanı o alt alandaki bir sayfaya çeker → sayfa `/v1/auth/refresh`'i `X-CSRF-Token: SALDIRGAN` ile çağırır → `SameSite=Strict` yenileme çerezini **taşır** (istek same-site'tır) → sunucu çerez == başlık karşılaştırır → **EŞLEŞİR** → geçer.
> **OWASP birebir:** naif double-submit *"bypassable by an attacker who can write cookies on the target domain (e.g., via a vulnerable sibling subdomain, DNS takeover…)"* · *"For new code, use the **Signed** Double-Submit Cookie pattern… **The naive pattern is documented for reference only.**"*
> **Belgenin kendisi bu vektörü K3-L4 notunda adlandırıyor ve double-submit'i TAM DA ONA KARŞI tutuyordu.**

**Karar — üç ayak birlikte:**
1. **Birinci hat — `SameSite=Strict`:** klasik çapraz-site CSRF'ini kapatır.
2. **Yapısal ayak — `__Host-` öneki (K3-L2):** yenileme çerezine **ve** CSRF çerezine (`__Host-mct`) uygulanır ⇒ kardeş alt alan adı **bu çerezleri yazamaz**; saldırının birinci adımı **yapısal olarak** imkânsızlaşır.
3. **İkinci hat — İMZALI double-submit:** CSRF çerezinin değeri rastgele bir dize **değil**, `value = nonce + "." + Base64Url(HMAC-SHA256(key, nonce + "|" + family_id))`'dir. Sunucu başlıktaki değeri alır, HMAC'i **kendi anahtarıyla** yeniden hesaplar **ve** `family_id`'nin **sunulan yenileme çerezinin ailesiyle aynı** olduğunu doğrular. ⇒ Saldırgan çerez yazabilse bile **geçerli bir imza üretemez**; başka bir ailenin token'ını da ödünç alamaz.

**CSRF çerezinin yaşam döngüsü [Ma-9'un ikinci yarısı]:** `/login` ve her `/refresh` yanıtında **yeniden set edilir** (aile değiştiği veya döndüğü için); `HttpOnly` **değildir** (istemci okumalı); `SameSite=Strict`, `Secure`, `__Host-` önekli.

**ÇIKIŞTA HER İKİ ÇEREZ DE SİLİNİR [Ma-12 — v3'te yalnız CSRF çerezi siliniyordu].**
v3'ün cümlesi *"`/logout`'ta silinir"* **yalnız `__Host-mct`** içindi. **`__Host-mrt` unutulmuştu** ve `Path=/` gereği çıkıştan sonra **30 güne kadar her isteğe takılmaya devam ederdi** — yaşam döngüsünü *"tam yazdım"* diye ilan eden bölümün son adımı eksikti. **Karar:** `/logout` ve `/logout-all` yanıtları **`__Host-mrt` ve `__Host-mct`'nin ikisini birden** `Max-Age=0` (ve `Expires` geçmiş tarih) ile siler; silme başlıkları çerezin **kendi öznitelikleriyle birebir aynı** (`Path=/`, `Secure`, `SameSite=Strict`, `__Host-` öneki) yazılır — aksi hâlde tarayıcı silmeyi **farklı bir çerez** sanar ve uygulamaz.
> **Bunun bir güvenlik sonucu da vardır:** sunucu tarafında aile zaten iptal edilmiştir (`revoked_at`), yani çerezin kalması **sömürülebilir değildir**; ama tarayıcıda kalan bir yenileme çerezi (a) her isteğe gereksiz veri ekler, (b) `/refresh`'in `401`'i ile *"oturum gerekli"* döngüsünü karıştırır ve (c) **paylaşılan bir makinede kullanıcıya "çıktım" demenin karşılığını vermez.** Kapı: **M47**.
**CSRF KAPSAMI — K14-c bunu YAPISAL OLARAK ÇÖZDÜ [Ma-9'un birinci yarısı]:** v2'de K3-L3 `/logout`'u da sayıyordu ama K3-J1 onu Bearer'lı yapıyordu ⇒ tutarsızdı. **Bugün `/logout` ve `/logout-all` yetkilerini JWT'nin `fid` talebinden alır** (K14-c) ⇒ otomatik gönderilen bir kimlikle çalışmazlar ⇒ **CSRF yüzeyi yalnız `/refresh`'tir.** Kapı **M25** ve **M35** yalnız orayı test eder; bu artık bir eksiklik değil, bir sonuçtur.

**K3-L4 — [KARAR — Onur] WEB DAĞITIM: AYNI ORIGIN **VE** API STATİK DOSYALARI SERVİS EDER; REVERSE-PROXY YOK. [K12-d + K14-e — bloker #3 kapanır]**

**v2'nin bıraktığı çatal:** *"API statik dosyaları verir **veya** ikisi tek reverse-proxy altında birleşir"* — iki farklı dağıtım, farklı güvenlik sonuçları, **karar yok**. İki dal da bir kontrolü kırıyordu (dal (a): SPA 401'lenir — K3-J1'de kapatıldı; dal (b): aşağıda).

**Karar [K14-e, K15-b ile DOĞRULANDI VE DARALTILDI]: tek konteyner; Kestrel hem `/v1/*` API'sini hem Flutter web build'ini servis eder.** Sonuçları:
- **CORS `AllowCredentials` hiç gerekmez** — çapraz-origin isteği yoktur. **[ÖLÇÜMDEN BAĞIMSIZ, SAĞLAM]**
- **`SameSite=Strict` gerçekten çalışır.** **[ÖLÇÜMDEN BAĞIMSIZ, SAĞLAM]**
- **Dağıtım tek birimdir** ⇒ `docker compose up` (K3-I3 ile birlikte) tek komutta çalışan bir uygulama verir (ODEV §2). **[SAĞLAM]**
- **🔴 ~~`RemoteIpAddress` GERÇEK istemci IP'sidir~~ — BU AYAK GERİ ÇEKİLDİ [K15-b].** Ölçüm (gerçek koşu, üç yol, hepsi `172.17.0.1`) bu iddiayı yanlışladı; ayrıntısı ve kararın tamamı **K3-J2'nin altındaki kutudadır**. Bugünkü dürüst ifade: ***tek konteyner dağıtımında `RemoteIpAddress` KÖPRÜ AĞ GEÇİDİDİR; kontrol 1 küresel bir tavandır, IP-anahtarlı bir kullanıcı ayrımı değildir.*** **K14-e'nin kendisi düşmez** — çünkü kararı ayakta tutan diğer iki gerekçe (CORS ve `SameSite`) ölçümden bağımsızdır — ama **bir kilidin gerekçelerinden biri yanlış bir olguya dayanıyordu ve bu, sessizce düzeltilmek yerine adlandırıldı** (§0.4).
- **Reverse-proxy'nin reddi bu ölçümden SONRA da geçerlidir, ama gerekçesi değişti:** artık *"proxy IP partition'ını öldürür"* diye reddedilmiyor (partition zaten yok); **kapı yükü ve tek-birim dağıtım** gerekçeleriyle reddediliyor.

> **⚠ `Secure` ÇEREZİN TAŞIMA KISITI — ADLANDIRILMIŞ SINIR [RT-M1].** `Secure` çerezler **`http://localhost` dışında** düz HTTP üzerinden set edilmez. Değerlendirici uygulamayı `http://192.168.1.x:8080` gibi bir LAN adresinden açarsa **çerez hiç set edilmez ve `/refresh` sessizce çalışmaz.** **Karar:** teslim paketi ve README **`http://localhost:PORT`** kullanımını **zorunlu** kılar; alternatifi (self-signed HTTPS) tarayıcı uyarısı üretir ve demoyu zedeler. **Bu bir sınırdır, gizlenmiyor** — ve K3-L4'ün kendi bulduğu hata sınıfının (*"ancak canlı web demosunda fark edilirdi"*) tekrarıdır.

*Reddedilenler [adlandırılmış]:* **reverse-proxy** (daha gerçekçi üretim topolojisi; bedeli `UseForwardedHeaders` + `KnownProxies/KnownNetworks` yapılandırması **ve** M11/M23'ün `TestServer` yerine `X-Forwarded-For` enjekte eden testlere taşınması) · **ikisini de desteklemek** (kapı yükü ikiye katlanır, *"hangisi kanıtlandı"* sorusu denetçiye açık kalır) · **çapraz origin + `SameSite=None`** (CSRF yüzeyi genişler) · **web'de çerez yok** (F5 = çıkış).

> **⚠ `SameSite=Strict` HER ŞEYİ KAPATMAZ.** "Same-site" ≠ "same-origin": **kardeş bir alt alan adı** tarayıcı için hâlâ same-site'tır ve ondan gelen istek çerezi **taşır**. Aynı-origin dağıtım klasik çapraz-site CSRF'ini kapatır; **alt alan adı vektörünü kapatmaz.** Bu yüzden K3-L3 durur — ve v2'nin aksine artık **imzalı**dır.
> **`SameSite=Strict` + harici link şüphesi TEMİZ çıktı (bir sonraki denetçi de buraya saldıracağı için yazılıyor):** RFC 6265bis §5.2.1 gereği, sayfa yüklendikten **sonra** aynı origin'e giden `fetch` **same-site**'tır ⇒ kullanıcı e-postadaki bir linkten gelse bile, açılan SPA'nın kendi `/refresh` çağrısı çerezi **taşır**. Sorun yok.

**K3-L5 — Tek-uçuşlu (single-flight) refresh; SINIRI AÇIKÇA YAZILIR. [K11-c + bloker #1]**
İstemcide **aynı anda en çok BİR** `/refresh` uçuşu olur; 401 alan diğer istekler o tek uçuşun sonucunu **bekler**.
> **🔴 v2'NİN BEYANI YANLIŞTI — DÜZELTİLİYOR.** v2 birebir *"meşru istemcinin kendini hırsız ilan ettirmemesi **bu mekanizmaya** bağlıdır"* diyordu. **Tek-uçuşluluk bunu yapısal olarak yapamaz:** *eşzamanlı* çağrıları serileştirir, **ağ yüzünden kaybolan yanıttan sonraki ARDIŞIK yeniden denemeyi değil.** RFC 9700 §4.14.2 bu durumu bir **maliyet** olarak kabul eder, telafi **vaat etmez**: *"…This stops the attack at the cost of forcing the legitimate client to obtain a fresh authorization grant."*
> **Kayıp yanıt problemini çözen şey K3-C6(3)'ün sunucu-taraflı replay-idempotency penceresidir** (K14-a). Tek-uçuşluluk hâlâ gereklidir (eşzamanlı yarışı çözer ve gereksiz döndürmeyi önler) ama **tek başına yeterli değildir ve öyle beyan edilmez.**

Uçuş başarısızsa istekler kuyrukta kalır (K3-L6), **düşürülmez**. Kapı: **M-L5** (3b'ye devredildi, §7).

**K3-L6 — 401'de kuyruk BEKLER, DÜŞÜRÜLMEZ. [K11-g]** Tek-uçuşlu refresh denenir; başarısızsa gönderilmemiş yazımlar **diskte kalır** ve istemci "oturum gerekli" durumuna geçer. Kullanıcı yeniden giriş yapınca kuyruk **kaldığı yerden** gönderilir. *Gerekçe:* ODEV §6.1 bunu mimari zorunluluk ilan etti. Kapı: **M-L6** (3b'ye devredildi).

**K3-L7 — Çıkışta SİLME YOKTUR: kullanıcı-başına ayrı yerel DB dosyası. [K11-g]** Her kullanıcının Drift dosyası ayrıdır: **`momentum_{userId}.sqlite`**. Çıkışta yerel veri **silinmez**, yalnız o dosya kapatılır. Sonuçları: (a) izolasyon **dosya düzeyinde** — bir sorgu filtresi unutulsa bile sızmaz; (b) A'nın gönderilmemiş yazımları A yeniden girince devam eder; (c) **kırmızı çizgi 4 (kalıcı silme) hiç tetiklenmez**. Kapı: **M-L7** (3b'ye devredildi).

**K3-L8 — SOĞUK AÇILIŞ: AKTİF PROFİL KAYDI + AĞ HATASININ `401`'DEN AYRILMASI. [bloker #10 kapanır]**
**Kırılan senaryo — üç kararın birleşimi, hiçbirinin tek başına görünmediği bir şema sonucu:** erişim token'ı yalnız bellekte (K3-L1/L2) + yerel dosya adı `momentum_{userId}.sqlite` (K3-L7) + `userId`'nin tek kaynağı doğrulanmış JWT'nin `sub`'ı (K3-D2) ⇒ **ağsız açılışta yerel DB açılamaz.** Çevrimdışı-öncelikli bir uygulamada bu, vitrinin tam ortasıdır.

**Karar:**
1. **Aktif profil kaydı:** son oturum açan `userId` — **bir sır değildir** — DB dosyalarının **dışında**, kalıcı bir "aktif profil" kaydında tutulur (`shared_preferences` ya da eşdeğeri). Yerel DB **ağ olmadan** onunla açılır. Yenileme token'ı yine güvenli depodadır; **profil kaydı yalnız `userId` taşır**.
2. **`/refresh`'in AĞ HATASI dalı, `401` dalından AYRILIR — bu ayrım pazarlıksızdır:**
   - **Ağ hatası** (bağlantı yok, timeout, DNS): istemci **çevrimdışı-yetkili** kalır ⇒ yerel DB **tam okunur/yazılır**, kuyruk çalışır, **yalnız senkron durur**. "Oturum gerekli" durumuna **GEÇİLMEZ**.
   - **Sunucu `401` / `reuse_detected`**: *o zaman* "oturum gerekli" tetiklenir.
   - v2'de bu ayrım yoktu ⇒ uçak modundaki bir kullanıcı `/refresh` başarısız olduğu için giriş ekranına atılırdı.
3. **`/refresh`'in ÜÇÜNCÜ DALI: `429`/`5xx` = GEÇİCİ. [B3 — v3'te bu dal HİÇ YOKTU ve demonun ortasında tanımsız durum üretiyordu]**
   - **Kırılan senaryo (saldırgan yok; aktör = değerlendiricinin kendisi):** K3-L2 gereği erişim token'ı web'de **yalnız bellektedir (sekme-yerel)** ⇒ **her F5 bir `/refresh`'tir**. v3'te `/refresh`, `/login` ve `/register` ile **tek politikada** ve **10 istek/5 dk** idi; B2 gereği partition **tek**. ODEV §4(b)-2 gerçek zamanlı işbirliği vitrini **iki eşzamanlı kullanıcı** ister: değerlendirici A'yı kaydeder+girer (2) → B'yi kaydeder+girer (4) → uçak modunu açıp kapatır, her seferinde F5 (5,6,7…) → iki pencerede birkaç yenileme (8,9,10) → **11. istek `429`**. v3'ün istemci sözleşmesi sonucu **yalnız ikiye** ayırıyordu (ağ hatası → çevrimdışı-yetkili · `401`/`reuse_detected` → oturum gerekli) ⇒ `429` **hiçbir dala düşmüyordu** ⇒ builder'ın en doğal seçimi (*"`401` değilse hata, hata ise oturum gerekli"*) **demonun ortasında giriş ekranı** üretirdi.
   - **Karar (iki ayaklı):** (i) **sunucu tarafı — K16-b**: `/refresh` **ayrı ve gevşek** bir politikaya alındı (**120/5 dk**), çünkü Argon2 **koşturmaz** ve `/login` ile aynı kovada olmasının hiçbir güvenlik gerekçesi yoktu; (ii) **istemci tarafı — bu dal:** ***`429` ve `5xx` GEÇİCİ hatalardır. İstemci `Retry-After` başlığına uyar (yoksa üstel geri çekilme, tavan 60 sn), ÇEVRİMDIŞI-YETKİLİ KALIR ve "oturum gerekli" durumuna GEÇMEZ.*** Kuyruk çalışmaya devam eder; yalnız senkron duraklar — yani **ağ hatası dalıyla aynı davranış**, farklı gerekçeyle.
   - **Neden `401` ile aynı sepete konamaz:** `401`/`reuse_detected` *"bu kimlik artık geçerli değil"* der; `429` *"şu an değil, birazdan"* der. İkisini birleştirmek, **sunucunun kendi koruma mekanizmasının kullanıcıyı çıkışa sürüklemesi** demektir.
   - **Kapı: M-L9** (DART, `slice-3b`'ye devredilir): mutasyon — `429` dalı `401` dalıyla birleştirilir. Kill: *"`429` yanıtında istemci **çevrimdışı-yetkili kalır**, 'oturum gerekli'ye **GEÇMEZ** ve `Retry-After` süresi kadar bekler"* **FAIL**.
4. *(Çevrimdışı kullanıcının hangi **ekranı** göreceği `slice-3b`'nin işidir; `userId`'nin **nereden geldiği** bu belgenin işidir — §1 dilimi zaten "bir ŞEMA kararıdır" diye tanımlıyor.)*

**K3-L9 — WEB'DE TEK-UÇUŞLULUK SEKMELER ARASI OLMAK ZORUNDADIR. [RT-M2 kapanır]**
Yenileme çerezi origin'in **tüm sekmelerinde ortaktır**, erişim token'ı ise **sekme-yereldir** ⇒ iki sekmede eşzamanlı F5: biri `T1`'i tüketir, diğeri aynı `T1`'i sunar ⇒ **replay-idempotency penceresi bunu yakalar (K14-a sayesinde artık aile düşmez)**, ama pencere dışındaysa **aile düşer ve iki sekme birden çıkar**. Dart `Completer` mutex'i **sekme-yereldir** ve bunu çözmez.
**Karar:** web'de tek-uçuşluluk **Web Locks API** (`navigator.locks.request`) ile, ona erişilemeyen ortamlarda `BroadcastChannel` tabanlı bir kilitle kurulur. **M-L5'in web ayağı budur** ve 3b devir kaleminde açıkça yazılır.
*(Not: K14-a'nın penceresi bu kilidi **gereksiz kılmaz** — pencereyi ikinci bir savunma hattı yapar. İkisi birlikte okunur.)*

**K3-L10 — `X-Client-Kind` VE YENİLEME TOKEN'ININ TESLİM KANALI. [K14-c — bloker #6 kapanır]**
**Kırılan yer:** `/login` ve `/refresh` **tek uçtur**; native istemci **ham değer** ister, web **almamalıdır** (yoksa `HttpOnly` çerezin bütün gerekçesi düşer). v2 sunucunun bu ikisini nasıl ayırt ettiğini **hiç yazmamıştı** ⇒ en doğal builder seçimi (*"hep gövdede + web'e ayrıca `Set-Cookie`"*) **K3-L2'nin *"tek XSS yenileme token'ını okuyamaz"* gerekçesini doğrudan yalanlardı.

**Karar:**
- **Başlığı taşıyan uçlar [Ma-16 — v3'te `/logout-all` ve `/register` belirsizdi]:** `/login` · `/register` · `/refresh` · `/logout` · `/logout-all` — **BEŞİ DE**. Başlık **yoksa veya tanınmıyorsa** istek `400` alır — *"varsayılana düş"* yolu **yoktur** (sessiz varsayılan tam olarak bu belgenin karşı olduğu şeydir). *(`/register` ve `/logout-all` token teslim etmese bile başlığı ister: kural **tek** olsun, istemcide "hangi uçta gönderiyordum" sorusu hiç doğmasın. Ayrıca aşağıdaki CSRF yan kazancı **tüm** uçlarda geçerli olsun.)*
- **PAZARLIKSIZ ÜÇ KURAL:**
  1. **[ÇIKTI]** `X-Client-Kind: web` ⇒ yenileme token'ı **yalnız `Set-Cookie`** ile gider; **yanıt gövdesinde HİÇ görünmez** (ne alan olarak, ne de başka adla).
  2. **[ÇIKTI]** `X-Client-Kind: native` ⇒ yenileme token'ı **yalnız yanıt gövdesinde** gider; **çerez HİÇ set edilmez**.
  3. **[GİRDİ — YENİ, B9 kapanır]** **Sunucu girdi kanalını YALNIZ `X-Client-Kind`'dan seçer:**
     - `web` ⇒ yenileme token'ı **yalnız `__Host-mrt` çerezinden** okunur, **gövde yok sayılır** (gövdede bir token gelse bile **kullanılmaz**), **ve CSRF doğrulaması ZORUNLUDUR**;
     - `native` ⇒ yenileme token'ı **yalnız gövdeden** okunur, **çerez OKUNMAZ** (tarayıcı otomatik eklese bile).
     - *"Çerez varsa çerezden, yoksa gövdeden oku"* **YASAKTIR.**

> **🔴 v3'TE OKUMA YÖNÜ HİÇ YAZILMAMIŞTI — GÜVENLİK MODUNU İSTEMCİ SEÇİYORDU [B9].**
> v3'ün *"PAZARLIKSIZ İKİ KURAL"*ı yalnız **yanıt** yönünü düzenliyordu. **İstek yönü tanımsızdı:** sunucu `/refresh`'te token'ı çerezden mi gövdeden mi okur, iki kanal birden doluysa ne olur, CSRF doğrulaması `native`'de koşar mı? CSRF doğrulaması zorunlu olarak `X-Client-Kind == web`'e koşulludur ⇒ **istemcinin gönderdiği bir başlık sunucunun güvenlik modunu seçer.** Bu, **K14-f'in birebir adlandırarak reddettiği hata sınıfıdır** (*"anahtarı istemci seçer ⇒ R2'nin kapattığı hata sınıfı aynen geri gelir"*). Builder *"çerez varsa çerezden oku"* yazsaydı — en doğal seçim — `X-Client-Kind: native` gönderen bir istek **CSRF katmanını tümüyle atlar** ve tarayıcı `__Host-mrt`'yi zaten otomatik ekler.
> **DÜRÜST DARALTMA:** denetim bu saldırıyı tarayıcıda **kurmayı denedi ve kuramadı** — `X-Client-Kind` **CORS-safelisted değildir** ⇒ çapraz-origin istek preflight tetikler ⇒ K3-L4 gereği CORS politikası **hiç yok** ⇒ tarayıcı bloklar. **Bugün sömürülebilir değil; savunma kazara duruyor.** Bu maddenin bloker sebebi **karar boşluğudur, saldırı değildir** — ve *"kazara duran savunma"* bu belgenin doktrininde bir savunma sayılmaz.
> **YAN KAZANÇ, BELGENİN LEHİNE VE YAZILIYOR:** `X-Client-Kind`'ın **zorunlu** olması, CORS politikası olmadığı için **kendi başına bir CSRF savunmasıdır** — çapraz-origin bir sayfa bu başlığı ekleyemez (preflight bloklanır), başlıksız istek de `400` alır. Yani K3-L3'ün imzalı double-submit'i **üçüncü** bir hatta kavuşur. *(Bu bir yedek hattır, birincil değil: CORS politikası bir gün eklenirse bu koruma düşer, K3-L3 düşmez.)*

- **Kapılar: M28** (çıktı yönü) **ve M43** (girdi yönü).
  - **M28** — mutasyon: web modunda yenileme token'ı gövdeye **de** eklenir. Kill sinyali: *"`X-Client-Kind: web` ile gelen `/login` ve `/refresh` yanıtlarının gövdesi yenileme token'ını **hiçbir biçimde** içermez"* **FAIL**. **Sinyal B5 gereği güçlendirildi:** test (i) gövdeyi **JSON olarak ayrıştırır ve tüm dize değerlerini ÖZYİNELEMELİ tarar**, (ii) ayrıca **ham gövde metnini** token'ın **hem düz hem JSON-kaçışlı** biçimi için tarar. *(Token `Base64Url` olduğu için kaçış yapısal olarak beklenmez — ama tarama yine de yapılır: kodlama kararı bir gün değişirse kapı sessizce körleşmesin.)*
  - **M43** — mutasyon: sunucu *"çerez varsa çerezden oku"* yazar (`X-Client-Kind` girdi seçiminde yok sayılır). Kill sinyali **iki ayaklı**: *"`X-Client-Kind: native` + geçerli `__Host-mrt` çerezi + gövdede token **YOK** ⇒ istek **başarısızdır** (`400`), çerez **kullanılmaz**"* **FAIL** · *"`X-Client-Kind: web` + gövdede geçerli token + çerez **YOK** ⇒ istek **başarısızdır**"* **FAIL**. Seviye `TS`. **Üçüncü ayak (başlık yokluğu):** *"`X-Client-Kind` başlığı olmadan gelen `/refresh` `400` alır"* — Ma-6'nın kapısız kalemlerinden biri de böylece kapanır.
- **`/logout`'un girdisi:** JWT'nin **`fid`** talebi (K3-C1). ⇒ çerez/gövde bağımlılığı yoktur, K11-d'nin *"yalnız o aile"* semantiği korunur ve v2'nin **"hangi aile iptal edilecek hesaplanamıyor"** çıkmazı kapanır.

*Reddedilenler:* ayrı alt yollar `/v1/auth/web/*` (uç sayısı ikiye katlanır, OpenAPI kontrat kapısı ve test yüzeyi büyür) · her platformda çerez (K3-L1 düşer, mobilde çerez kalıcılığı platform başına kırılgandır ve *"yenileme token'ı Keystore/Keychain'de"* vitrini kaybolur).

### M. PORT ENVANTERİ VE KATMAN YERLEŞİMİ [Ma-6 kapanır — YENİ BÖLÜM]

v2'de *"JWT'yi kim üretir, `Microsoft.IdentityModel.Tokens` nerede referanslanır, `refresh_tokens` ham SQL'i hangi portun arkasında, `ICurrentUser` implementasyonu nerede"* soruları **yazılmamıştı** ⇒ K9'un *"paket değişimi tek sınıfı etkiler"* ilkesi kimliğin yarısında **geçersiz** kalıyordu.

| iş | port (Application) | implementasyon | 3. parti tip nerede görünür | NetArchTest kuralı |
|---|---|---|---|---|
| Parola hash/verify | `IPasswordHasher` | Infrastructure | `Konscious.*` **yalnız** Infrastructure | `Konscious.*` Domain/Application/Api'de **görünmez** (**M32**) |
| JWT üretimi | `IAccessTokenIssuer` | Infrastructure | `Microsoft.IdentityModel.*` **yalnız** Infrastructure | `Microsoft.IdentityModel.*` Domain/Application'da **görünmez** |
| JWT doğrulama | *(port yok — çerçeve middleware'i)* | Api (`AddJwtBearer`) | Api | — |
| Yenileme token'ı üretimi + hash | `IRefreshTokenService` | Infrastructure | `System.Security.Cryptography` | — |
| `refresh_tokens` kalıcılığı (ham SQL) | `IRefreshTokenStore` | Infrastructure | `Npgsql`/`Dapper` **yalnız** Infrastructure | mevcut K-A1 ailesi |
| CSRF token imzalama | `ICsrfTokenService` | Infrastructure | `System.Security.Cryptography` | — |
| **Anahtar türetme (HKDF)** | **`IKeyRing`** (`JwtSigningKey` · `CsrfHmacKey` · `RefreshSecretKey`) | Infrastructure, **singleton** | `System.Security.Cryptography.HKDF` **yalnız** Infrastructure | mevcut K-A1 ailesi |
| **Halef sırrı süpürücüsü** | *(port yok — barındırılan servis)* | Infrastructure (`RefreshSecretSweeper : BackgroundService`) | `Npgsql` **yalnız** Infrastructure | mevcut K-A1 ailesi |
| Kimlik taşıma | `ICurrentUser` | **Infrastructure** (Api değil) | `Microsoft.AspNetCore.Http` **yalnız** Infrastructure/Api | `Microsoft.AspNetCore.*` Domain/Application'da **görünmez** |

**`ICurrentUser` neden Api'de değil Infrastructure'da:** `HttpContext`'e bağımlıdır ve Api katmanı bu projede **ince** tutulur (0001 katman kararı); Api yalnız uçları ve DI kaydını taşır. **Bu bir tercih değil, mevcut katman kuralının sonucudur** — ve yukarıdaki NetArchTest satırı onu zorlar.

**HANGİ KURAL YENİ, HANGİSİ MEVCUT AİLENİN UZANTISI — ADR 0001'DEN BİREBİR ALINTIYLA [Ma-8 kapanır].**

> **ADR 0001 §H, K-H1 — birebir:** *"**NetArchTest — gerçekten ihlal-edilebilir kurallar:** **Application ⊥ Infrastructure** · **Api endpoint/handler ⊥ Infrastructure somut tipleri** (composition root dışında) · **Domain ⊥ EF/ASP.NET/Npgsql namespace'leri**. **Her kural commit'li negatif/mutant testle ısırdığını kanıtlar.**"*
>
> *(Kapı-3 turunda bu alıntı **yapılamamıştı** — rapor §5 `docs/ADR/`'de yalnız `0003`'ün bulunduğunu yazıyordu. **v4 turunda ana oturumda ölçüldü: `docs/ADR/0001-genel-mimari.md` — 14.137 bayt, git-takipli, aynı klasörde.** Rapor bu tek kalemde yanılmıştır; hükmü taşıyan diğer ölçümleri etkilemez.)*

| §2-M'nin kuralı | statü | gerekçe (K-H1'e göre) | mutantı |
|---|---|---|---|
| `Microsoft.AspNetCore.*` **Domain**'de görünmez | **MEVCUT AİLENİN UZANTISI** | K-H1 birebir *"Domain ⊥ EF/**ASP.NET**/Npgsql namespace'leri"* — aynı kural, aynı namespace ailesi | mevcut 0001 mutantı |
| `Npgsql`/`Dapper` **yalnız** Infrastructure | **MEVCUT AİLENİN UZANTISI** | K-H1 birebir *"Domain ⊥ EF/ASP.NET/**Npgsql**"* + *"Application ⊥ Infrastructure"* | mevcut 0001 mutantı |
| **`Konscious.*`** Domain/Application/Api'de görünmez | **🆕 YENİ** | 0001 bu paketi bilmiyordu (K9 ile bu ADR'de seçildi) | **M32** |
| **`Microsoft.IdentityModel.*`** Domain **ve Application**'da görünmez | **🆕 YENİ (Application ayağı)** | Domain ayağı K-H1'in *"ASP.NET namespace'leri"* ailesine girer; **Application ayağı yeni bir namespace kısıtıdır** | **M32c** |
| **`Microsoft.AspNetCore.*`** **Application**'da görünmez (`ICurrentUser` bağlamı) | **🆕 YENİ (Application ayağı)** | K-H1 Application için yalnız *"⊥ Infrastructure"* diyor — **namespace düzeyinde bir kısıt getirmiyordu** | **M32b** |

> **🔴 v3'ÜN §3.1 MUAFİYETİ K-H1'İN DOĞRUDAN İHLALİYDİ — KAPATILIYOR.** v3, §3.1'de *"NetArchTest kuralları mevcut K-A1 ailesinin doğrudan uzantısıdır ve o aile zaten mutantlıdır; **yalnız `Konscious.*` kuralı yenidir** ve M32 ile ısırtılır"* diyordu. **Yukarıdaki tablo bunu yalanlıyor:** üç kural yenidir, biri değil. Ve K-H1'in son cümlesi **istisnasızdır**: *"**Her** kural commit'li negatif/mutant testle ısırdığını kanıtlar."* ⇒ **M32b ve M32c yazıldı**; §3.1'in ilgili satırı **kaldırıldı**. *(Bloker #15'in v3'te "yarım kapandı" denmesinin sebebi buydu ve artık tam kapanmıştır.)*

---
## 3. Isıran kapılar (KÖR KAPI YOK)

Her kapı, kaldırıldığında testi **kırdığını** mutantla kanıtlar. Bu tablo `GOREV-slice-3c-auth` spec'inin mutant listesinin **kimlik-çekirdeği yarısıdır**; diğer yarısı ADR 0004'tedir.

> **NUMARA SÖZLEŞMESİ [K16-d ile GÜNCELLENDİ]:** bu belge **M1–M48** aralığını kullanır (M2·M3·M9·M10·M20 **0004'e aittir**, burada yazılmaz; M13 **VOID**'dir). **ADR 0004'ün YENİ mutantları artık `M50`'den başlar** — v3'ün `M40` pini, v4'ün dokuz yeni mekanizma kapısı yüzünden **geçersizdir**; 0004 henüz hiçbir numarayı tüketmediği için pini taşımak bedelsizdir. **Harfli ekler numara tüketmez:** `M6b` · `M8a/M8b` · `M32b/M32c` · `M33a/M33b` (gerçek ikinci-ayaklar) ve `M-L5/M-L6/M-L7/M-L8/M-L9` (istemci tarafı, `slice-3b`, Dart).

> **TEST SEVİYESİ [D3 majörü + B4 kapatılıyor]:** v2'nin *"saf çekirdek DB'siz kanıtlanır"* iddiası tutmuyordu — canlı mutantların çoğu DB istiyor. Sütun eklendi ki **spec, hangi test altyapısının hangi mutant için gerektiğini tahmin etmek zorunda kalmasın.** Kısaltmalar: **B** = saf birim · **D** = derleme (analizör) · **TS** = `TestServer` entegrasyonu · **TC** = Testcontainers (gerçek Postgres) · **NA** = NetArchTest · **DART** = istemci birim testi (`slice-3b`) · **DART-WEB** = istemci **tarayıcı** testi (`flutter test --platform chrome` / `integration_test` + chromedriver) · **🆕 KON** = **konteyner/E2E** (imaj gerçekten `docker run` ile ayağa kaldırılır; çıkış kodu ve dosya sistemi gözlemlenir).
> **`KON` neden zorunlu oldu [B4]:** M8b'nin mutasyonu **konteynerin giriş betiğindedir**; hiçbir C# testi bir ENTRYPOINT'i gözlemleyemez. v3 seviyeyi `B` yazmıştı ⇒ builder var olmayan bir sınıfa test yazar ve **yeşil geçerdi**. Bir seviye sözlüğünün eksikliği, bir kapıyı **sessizce kör** yapabilir.

| # | mutasyon | kill sinyali (ZORUNLU) | seviye | çıpa |
|---|---|---|---|---|
| **M1** | Yeniden-kullanım tespiti kaldırılır (tüketilmiş token kabul edilir) | *"tüketilmiş token **replay penceresi dışında** ikinci kez sunulunca **o aile** iptal olur"* **FAIL** | TC | K3-C2 |
| **M4** | `ToLowerInvariant` → kültüre-duyarlı `ToLower()` | **İKİ AYRI COMMIT'TE koşulur [Ma-16]:** (1) `ToLowerInvariant` → `ToLower()` ⇒ **DERLEME KIRILIR** (BannedApiAnalyzers); (2) analizör kuralı geçici olarak susturulup mutasyon uygulanır ⇒ tr-TR **zorlanmış kültür** testinde *"`I@x.com` ve `i@x.com` aynı hesaba düşer"* **FAIL**. *(Tek commit'te ikisi kanıtlanamaz: derleme kırıldığında davranış testi zaten koşamaz.)* | D + TC | K3-A2 |
| **M5** | Rehash-on-login kaldırılır | *"eski parametreli hash başarılı girişten sonra güncel parametreye taşınır"* **FAIL** | TC | K3-B3 |
| **M6** | `FixedTimeEquals` → `SequenceEqual` | **DERLEME KIRILIR** (BannedApiAnalyzers) | D | K3-B4 |
| **M6b** | `FixedTimeEquals` → **`byte[] ==`** (referans karşılaştırması) | *"doğru parola ile giriş **başarılı** olur"* **FAIL** *(referans karşılaştırması her zaman `false` döner)* — **mutasyon YALNIZ karşılaştırma satırına uygulanır**; baseline yeşilken **yalnız bu test** kırılmalıdır | B | **[D3 düzeltmesi]** `byte[] ==` BannedApiAnalyzers ile **ifade edilemez** ⇒ v2'nin M6'sının bu yarısı **yanlış sinyal taşıyordu**; davranış testine ayrıldı |
| **M7** | Bilinmeyen e-postada sahte (dummy) hash koşulmaz | *"bilinmeyen e-posta ile `/login` isteğinde `IPasswordHasher.Verify` **tam olarak 1 kez** çağrılır"* **FAIL** | TS | **YAPISAL ÖLÇÜT** — süre ölçülmez, çağrı sayılır |
| **M8a** | `Production`'da imzalama anahtarı yokken fail-fast kaldırılır | *"anahtarsız/32 bayttan kısa anahtarlı `Production` başlangıcı **patlar**"* **FAIL** | B | K3-I2 |
| **M8b** | Dev bootstrap'ın ortam koşulu kaldırılır (her ortamda anahtar üretir) | *"`docker run -e ASPNETCORE_ENVIRONMENT=Production` ile **anahtarsız** açılan konteyner **sıfırdan farklı çıkış kodu** verir **ve** `./.secrets/momentum-master.key` **oluşmaz**"* **FAIL** | **KON** | **K3-I3 — bu ayak olmadan bootstrap'ın kendisi bir açıktır** |
| **M11** | Hız sınırlayıcı (kontrol 1) tamamen kaldırılır | *"aynı IP'den **11.** `/login` denemesi `429` alır ve `problem.Extensions[\"limit\"] == \"ip\"`"* **FAIL** | TS | K3-J2(1) |
| **M12** | Yenileme token'ı DB'ye ham yazılır (hash'lenmez) | *"DB'deki `token_hash`, istemciye verilen token'ın `Base64Url` çözümüyle elde edilen **32 HAM BAYTININ SHA-256 özetine EŞİTTİR**"* **FAIL** *(ek assert: `token_hash` ne ham baytlara ne de kodlanmış dizeye eşittir)* | TC | **[B5]** v3 *"neyin özeti"*ni yazmıyordu ⇒ builder kodlanmış dizeyi hash'lerse test **yazılamazdı**. **`Base64Url` + ham bayt artık K3-C2'de pinlidir.** ⚠ **`successor_secret_enc` bu iddiaya İSTİSNADIR ve M40 onu ayrıca ısırtır** (K15-a) |
| **M13** | ~~Zarafet penceresi sınırı~~ | **VOID — KONUSU KALMADI** | — | Mekanizma K11-c ile kaldırıldı; **sessizce kaybolmasın diye satır duruyor** |
| **M14** | `FallbackPolicy` kaldırılır (deny-by-default kapatılır) | *"test için eklenmiş, **`[Authorize]` yazılmamış** `GET /v1/_probe/deny-default` ucu anonim erişime `401` döner"* **FAIL** | TS | **[D3 düzeltmesi]** v2 hedef ucu tanımsız bırakmıştı ⇒ builder mevcut bir ucu seçerse mutant ısırmayabilirdi. **Uç adı artık pinlidir** (yalnız test derlemesinde kayıtlı) |
| **M15** | `ICurrentUser.UserId` kimliksizken `Guid.Empty` döndürür | *"kimliksiz erişimde `UnauthenticatedException` atılır"* **FAIL** | B | K3-D1 |
| **M16** | `ClockSkew = TimeSpan.Zero` kaldırılır (varsayılan 5 dk) **veya** `ValidAlgorithms` **`HS512`'ye** genişletilir | *"süresi 1 dk önce dolmuş token `401`"* **FAIL** · *"**aynı anahtarla HS512** imzalanmış token reddedilir"* **FAIL** | TS | **[bloker #12 düzeltmesi]** `alg:none` ve RS256 ayakları **kaldırıldı** (ilkini `RequireSignedTokens`, ikincisini `SymmetricSignatureProvider` zaten kapatıyor ⇒ mutant hayatta kalırdı = kör kapı) |
| **M17** | Döndürmede yeni token'a **yeni** mutlak son kullanma verilir | **aile doğduktan sonra `FakeTimeProvider` İLERİ ALINIR**, sonra `/refresh` çağrılır: *"yeni satırın `expires_at`'i eski satırınkine **TAM EŞİTTİR**"* **FAIL** | TC | **[bloker #14 düzeltmesi]** donmuş saat altında v2'nin sinyali **yeşil kalıyordu** = kör kapı |
| **M18** | `/logout` kullanıcının **tüm** ailelerini iptal eder | *"iki cihazdan giriş: birinden `/logout`, diğerinin `/refresh`'i ÇALIŞMAYA DEVAM EDER"* **FAIL** | TC | K3-C4 |
| **M19** | `OutboxDispatcher`'ın kendi `IServiceScope`'u kaldırılıp `ICurrentUser` **doğrudan** singleton'a enjekte edilir | **HOST BUILD DOĞRULAMASI KIRILIR** (`scoped` bağımlılık `singleton`'a enjekte edilemez; `ValidateOnBuild=true`) — **`WebApplicationFactory` ile ayağa kaldırılır** (§3.2) | **TS** | **[D3 düzeltmesi]** v2'nin mutasyon biçimi kararsızdı (*"ya tüm suite düşer ya hiç ısırmaz"*); mutasyon artık **DI doğrulamasına** çıpalı. **[Ma-13]** seviye `D` **yanlıştı**: `ValidateOnBuild` bir analizör değil **çalışma-zamanı host-build** doğrulamasıdır. **`WebApplicationFactory` üç ayrı yolda `UseEnvironment(Development)` çağırdığı için `TS`'te doğrulama AÇIKTIR** (ölçüldü) — çıplak `ServiceCollection` ile mutant **sessizce hayatta kalır**, o yüzden koşum biçimi §3.2'de pinlendi |
| **M21** | Normalizasyondan `Trim()` **veya** NFC adımı çıkarılır | *"`\" a@x.com\"` ile `\"a@x.com\"` aynı hesaba düşer"* **FAIL** · *"NFC ayrık aksanlı e-posta birleştirilmiş hâliyle aynı hesaba düşer"* **FAIL** | TC | K3-A2 |
| **M22** | Eşzamanlılık limiti (kontrol 3) kaldırılır | **her istek FARKLI IP'den** gelir (kontrol 1 tetiklenmez) **ve** `IPasswordHasher` **bloke eden sahte** implementasyondur (test kontrollü semafor): *"limitin üstündeki eşzamanlı `/login` `429` alır, `problem.Extensions[\"limit\"] == \"concurrency\"` ve **Argon2 KOŞMAZ**"* **FAIL** | TS | **[bloker #13 + Ma-15]** **ÖNKOŞUL ADR'DE YAZILIR:** `TestHost` `RemoteIpAddress`'i **`null`** bırakır ⇒ *"her istek farklı IP'den"* koşulu, `UseRateLimiter`'dan **ÖNCE** eklenen **tek satırlık test-only middleware** ile kurulur (`ctx.Connection.RemoteIpAddress = IPAddress.Parse($"10.0.0.{i}")`). v3 bunu yazmamıştı ⇒ kusur *"imkânsız"* değil **"yazılmamış"**tı. Ayrıca v2'de test kendi istekleriyle **önce IP penceresini** dolduruyordu ⇒ mutant uygulandığında da ret geliyordu = **kör kapı**; ters yönde hızlı sahte hasher'la limit hiç dolmuyordu = **ölü tuzak** |
| **M23** | IP partition'ı kaldırılır, yalnız e-posta partition'ı bırakılır | *"her istekte FARKLI rastgele e-posta ile gelen **31.** `/login` isteği de `429` alır ve `limit == \"ip\"`"* **FAIL** | TS | **R2'nin tam kapısı.** **[K16-b]** sayı 11→31 (tavan 30/5 dk). **[K15-b]** kontrol 1 fiilen küresel olsa da **kod IP-anahtarlıdır ve bu mutant tam olarak o kodu ısırtır**: partition e-postaya çevrilirse rastgele e-postalar **hiç ret üretmez** ⇒ test kırılır. Tek partition altında da ısırır (denetimde doğrulandı) |
| **M24** | `ICurrentUser` `"sub"` yerine `ClaimTypes.NameIdentifier` okur | *"`MapInboundClaims=false` altında geçerli token ile korumalı uç `200` döner"* **FAIL** | TS | K3-C7'nin ölçülmüş yan etkisi. **[Ma-14] PİN:** test **gerçek `AddJwtBearer` boru hattından** geçer; sahte `TestAuthHandler` **YASAKTIR** (§3.2) — sahte handler'la mutant **sessizce hayatta kalır**. M14'te uç adı pinlenmişken burada pinlenmemesi belgenin kendi standardıyla asimetriydi |
| **M25** | Double-submit CSRF doğrulaması **tamamen** kaldırılır | *"geçerli yenileme çerezi + **EKSİK** `X-CSRF-Token` ile `/refresh` reddedilir"* **FAIL** | TS | K3-L3(3) |
| **M26** | `/refresh` yükleminden **`revoked_at IS NULL`** çıkarılır | *"`/logout` sonrası aynı yenileme token'ı ile `/refresh` **`401`** alır"* **FAIL** | TC | **[bloker #2]** bu ayak olmadan **`/logout` fiilen no-op'tur** ve M18 yine de yeşil kalır |
| **M27** | `/refresh` yükleminden **`expires_at > @now`** çıkarılır | `FakeTimeProvider` **31 gün ileri alınır**: *"süresi geçmiş yenileme token'ı `401` alır ve **aile iptal edilmez**"* **FAIL** | TC | **[bloker #2]** mutlak 30 gün ömrün tek zorlayıcısı |
| **M28** | Web modunda yenileme token'ı yanıt gövdesine **de** eklenir | *"`X-Client-Kind: web` ile gelen `/login` ve `/refresh` yanıtlarının **ham gövde metni** yenileme token'ının değerini **içermez**"* **FAIL** | TS | **[bloker #6]** test alan adına güvenmez, gövdeyi dize olarak tarar |
| **M29** | Replay-idempotency penceresi **sınırsızlaştırılır** (`consumed_at + 60 sn` koşulu kaldırılır) | `FakeTimeProvider` **61 sn ileri alınır**: *"tüketilmiş token yeniden sunulunca **aile iptal olur**"* **FAIL** | TC | **[K14-a]** pencerenin v1'in zarafet penceresine dönüşmesini engelleyen kapı |
| **M30** | Replay-idempotency'den **"halef tüketilmemiş olmalı"** koşulu kaldırılır | **60 sn PENCERESİNİN İÇİNDE** kalınır (`FakeTimeProvider` **ilerletilmez**), halef **kullanılır**, sonra `T1` yeniden sunulur: *"**aile iptal olur**"* **FAIL** | TC | **[K14-a + Ma-16]** gerçek hırsızlık sinyalini koruyan kapı. **PİN:** pencere dışına çıkılırsa M29 ile **ayırt edilemez** hâle gelir ⇒ *"pencere İÇİNDE"* koşulu testin önkoşuludur |
| **M31** | Parola asgari/azami uzunluk doğrulaması kaldırılır | **SINIR DEĞER, dört ayak:** *"**14** karakterlik parola `400`"* · *"**15** karakterlik parola **`201`**"* · *"**129** karakterlik parola `400` **ve Argon2 KOŞMAZ**"* · *"gösterim-adlı e-posta (`\"Ad <a@x.com>\"`) `400`"* — herhangi biri **FAIL** | TS | **[bloker #11 + K16-a + Ma-5]** K3-B6. **15/14 çifti pazarlıksızdır:** yalnız *"`a` reddedilir"* testi, çizgi 10'a da 15'e de düşse **yeşil kalır** = ölü ölçüt |
| **M32** | `Application` katmanındaki bir sınıfa `Konscious.Security.Cryptography` referansı eklenir | *"`Konscious.*` tipleri Domain/Application/Api'de **görünmez**"* NetArchTest kuralı **FAIL** | NA | **[bloker #15 + Ma-16] MUTASYON BİÇİMİ PİNLİ:** yalnız `using` eklemek **yetmez** (kullanılmayan `using` derlemeye referans yazmaz ⇒ NetArchTest görmez); mutasyon **gerçek bir tip kullanımıdır** (ör. `Application` içinde `typeof(Argon2id)` ya da bir alan bildirimi). 0001 K-H1 birebir: *"**Her** kural commit'li negatif/mutant testle ısırdığını kanıtlar"* — v2 bunu ihlal ediyordu |
| **M33a** | Fallback ucundan **`AllowAnonymous` kaldırılır** | *"kimliksiz `GET /` ve `GET /tasks` **`200`** döner ve gövdesi `index.html`'dir"* **FAIL** | TS | **[bloker #3 / K14-e / B6]** SPA derin linklerini `FallbackPolicy`'den kurtaran **tek** mekanizma budur (`AuthorizationMiddleware`'in ayrı `IAllowAnonymous` kontrolü) |
| **M33b** | **`UseStaticFiles` auth middleware'inden sonraya alınır** | *"kimliksiz **`GET /main.dart.js`** `200` döner **ve gövdesi `index.html` DEĞİLDİR**"* **FAIL** | TS | **[B6]** v3'ün tek M33'ü **ayırt edici değildi** (ölçüldü: `MapFallbackToFile` kendi `UseStaticFiles`'ını kurar ⇒ `/tasks` her hâlükârda `200`). Fark **dosya-benzeri** yollarda yaşar (`{*path:nonfile}` onları almaz). **ÖNKOŞUL:** test derlemesinde `wwwroot/index.html` **ve** `wwwroot/main.dart.js` yer tutucu olarak bulunur (K3-J1) — yoksa baseline **kırmızı doğar** |
| **M34** | PHC ayrıştırıcısının savunmacı dalı kaldırılır (bozuk format istisna atar) | DB'ye elle bozuk `password_hash` yazılır: *"`/login` **`401`** döner (`500` DEĞİL) ve gövde bilinen/bilinmeyen e-posta ile **aynıdır**"* **FAIL** | TC | **[Ma-4]** K3-B5'in tek-tip yanıt garantisinin kapısı |
| **M35** | CSRF token'ının **HMAC doğrulaması** kaldırılır (yalnız çerez == başlık karşılaştırılır) | **İKİ AYAK:** (1) *"**geçerli biçimli ama İMZASIZ/YANLIŞ İMZALI** bir CSRF değeri hem çerezde hem başlıkta gönderilirse `/refresh` **reddedilir**"* **FAIL**; (2) **[Ma-6 — AİLE BAĞI]** *"**BAŞKA bir ailenin `family_id`'siyle DOĞRU İMZALANMIŞ** bir CSRF değeri, sunulan yenileme çerezinin ailesiyle eşleşmediği için **reddedilir**"* **FAIL**. **Pozitif kontrol zorunlu:** doğru imzalı + doğru aileli değer **kabul edilir** (aksi hâlde *"her şeyi reddet"* mutantı da testi geçer) | TS | **[bloker #4]** v2'nin M25'i naif implementasyonda da **yeşil geçerdi** = kör kapı; **v3'ün M35'i ise yalnız imzayı ölçüyordu, K3-L3(3)'ün aile bağı ayağı KAPISIZDI** |
| **M36** | Çerezlerden **`__Host-`** öneki kaldırılır (veya `Domain` özniteliği eklenir) | **ÇOKLU ASSERT [Ma-6]:** *"`Set-Cookie` başlıkları **`__Host-`** ile başlar · **`Domain=` içermez** · `Path=/` · **`Secure`** · **`HttpOnly`** (yalnız `__Host-mrt`) · **`SameSite=Strict`** · **`Max-Age`** ailenin kalan `expires_at`'ine eşittir (±2 sn)"* — herhangi biri **FAIL** | TS | **[bloker #4]** kardeş alt alan adının çerez yazmasını yapısal olarak engelleyen ayak. **v3'te `HttpOnly`/`SameSite`/`Max-Age` KAPISIZDI** — üçü de K3-L2'de karar olarak yazılmışken hiçbir mutant onları ölçmüyordu |
| **M37** | `/login`'in bilinmeyen-e-posta dalı farklı bir gövde/kod döndürür | *"bilinmeyen e-posta + yanlış parola ile mevcut e-posta + yanlış parolanın yanıtları, **`extensions.traceId` alanı düşürüldükten sonra**, bayt bayt aynıdır (durum kodu dâhil)"* **FAIL** | TS | **[D3 + Ma-4]** K3-B5'in *"aynı yanıt"* ayağı v2'de kapısızdı; **v3'ün "bayt bayt aynı" sinyali ise ölü tuzaktı** — `DefaultProblemDetailsWriter` `traceId`'yi **koşulsuz** yazıyor (ölçüldü) |
| **M38** | `family_id` her `/login`'de yeniden üretilmez (kullanıcı başına sabit) | *"aynı kullanıcının iki ardışık `/login`'i **FARKLI** `family_id` üretir"* **FAIL** | TC | **[D3]** K3-C3'ün doğum anı v2'de yalnız **tesadüfen** kapsanıyordu; M18 ayırt edici değildi |
| **M39** | Atomik `UPDATE` yerine check-then-act (`SELECT` sonra `UPDATE`) yazılır | **gerçek Postgres'te paralel** iki `/refresh` aynı `T1` ile: *"**tam olarak biri** `200`, diğeri `401`+`reuse_detected` **ALIR; VEYA** (K14-a'nın replay penceresi devreye girdiyse) **ikisi de `200` alır ve dönen token'lar ÖZDEŞTİR**"* — **her iki durumda da** *"ailenin satır sayısı **tam olarak 1** artmıştır"* **FAIL** | TC | **[D3 + Ma-1]** v2 atomikliği iddia ediyor ama test etmiyordu; **v3'ün "tam olarak biri 200" sinyali ise K14-a ile ÖLÜ TUZAKTI**: kaybeden istek dal (c)'ye düşüp `200` alabilir (K3-L9 aynı olguyu tersinden yazıyor). **Değişmez artık yanıt kodu değil, AİLENİN SATIR SAYISIDIR** (K3-C6/1) |

| **M32b** | `Application` katmanındaki bir sınıfta **`Microsoft.AspNetCore.Http`** tipi kullanılır (ör. `HttpContext` alanı) | *"`Microsoft.AspNetCore.*` tipleri Domain/**Application**'da görünmez"* NetArchTest kuralı **FAIL** | NA | **[Ma-8]** K-H1 Application için yalnız *"⊥ Infrastructure"* diyordu ⇒ bu **yeni bir namespace kısıtıdır** ⇒ K-H1'in *"her kural mutantlı"* cümlesi gereği mutant **zorunlu**. Mutasyon biçimi M32'deki gibi **gerçek tip kullanımıdır** |
| **M32c** | `Application` katmanındaki bir sınıfta **`Microsoft.IdentityModel.Tokens`** tipi kullanılır | *"`Microsoft.IdentityModel.*` tipleri Domain/**Application**'da görünmez"* NetArchTest kuralı **FAIL** | NA | **[Ma-8]** aynı gerekçe; `IAccessTokenIssuer` portunun izolasyonu (§2-M) ancak bu kuralla zorlanır |
| **M40** | `successor_secret_enc` süpürücüsü devre dışı bırakılır (`SweepAsync` no-op) | `FakeTimeProvider` **121 sn** ileri alınıp `SweepAsync` çağrılır: *"tüketilmiş satırın `successor_secret_enc`'i **`NULL`**'dır"* **FAIL** | TC | **[K15-a]** kolonun **gerçekten silindiğini** ısırtan kapı. Yalnız `/refresh` yüklemine güvenmek, §6 Risk #13'ün *"60 sn"* ifadesini **yalan** yapardı (satıra bir daha dokunulmazsa sır 30 gün kalırdı) |
| **M41** | Kontrol 2 (e-posta penceresi, handler içi) kaldırılır | **İKİ AYAK:** (1) *"**aynı** normalize e-posta ile **6.** `/login` denemesi `429` **ve** `limit == \"email\"`"* **FAIL**; (2) *"**aynı IP'den farklı e-postalarla** gelen 6. istek `429` **ALMAZ**"* **FAIL** | TS | **[B7]** K14-f ile kapatıldığı ilan edilen bloker #5, v3'te **kapısızdı** ve §3.1'de de beyan edilmemişti. İkinci ayak **R2'yi korur**: anahtarın e-posta olduğunu, IP olmadığını ısırtır |
| **M42** | Alt anahtar türetme kaldırılır ve CSRF HMAC anahtarı **her açılışta yeniden üretilir** (efemer) | *"konteyner `docker compose restart` edildikten **sonra**, restart öncesi alınmış `__Host-mct` + `__Host-mrt` çiftiyle yapılan `/refresh` **`200`** döner"* **FAIL** | **KON** | **[B8 / K16-c]** K3-I3'ün açık vaadi (*"restart'ta oturumlar düşmez"*) v3'te **yalnız JWT için** kanıtlıydı; CSRF anahtarının varlığı bile yazılı değildi. M25/M35 hangi anahtar seçilirse seçilsin **yeşil kalır** ⇒ bu kapı olmadan hiçbir test bunu yakalayamaz |
| **M43** | Sunucu girdi kanalını `X-Client-Kind`'dan değil **kanalın varlığından** seçer (*"çerez varsa çerezden oku"*) | **ÜÇ AYAK:** (1) *"`X-Client-Kind: native` + geçerli `__Host-mrt` çerezi + gövdede token **YOK** ⇒ `400`; çerez **kullanılmaz**"* **FAIL**; (2) *"`X-Client-Kind: web` + gövdede geçerli token + çerez **YOK** ⇒ istek **başarısızdır**"* **FAIL**; (3) *"`X-Client-Kind` **başlıksız** `/refresh` `400` alır"* **FAIL** | TS | **[B9 + Ma-6]** v3 yalnız **çıktı** yönünü yazmıştı ⇒ güvenlik modunu **istemci** seçiyordu (K14-f'in adlandırarak reddettiği hata sınıfı). Bugün CORS preflight'ı yüzünden sömürülemiyor — **kazara duran savunma savunma sayılmaz** |
| **M44** | K3-C6(2)'nin dal önceliği bozulur: (c) replay dalı (b)'den **önce** değerlendirilir | *"`/logout`'tan **sonra**, `T1.consumed_at + 60 sn` **içinde** sunulan tüketilmiş token **`401`** alır (`200` DEĞİL)"* **FAIL** | TC | **[Ma-2]** `consumed_at` ve `revoked_at` sıradan bir akışta (refresh → logout) **birlikte** dolar; sıra yazılmazsa çıkış fiilen **60 sn gecikir**. **M26 bunu görmez** (o, yüklemin kendisini ölçer) |
| **M45** | Halef `INSERT`'ü tüketim `UPDATE`'inden **önceye** alınır (veya ayrı transaction'a çıkarılır) | **gerçek Postgres'te paralel** iki `/refresh` aynı `T1` ile: *"ailenin satır sayısı **tam olarak 1** artmıştır"* **FAIL** *(kaybeden istek sahipsiz bir satır bırakırsa 2 artar)* | TC | **[Ma-10]** v3 yalnız `UPDATE … RETURNING`'i pinliyordu; **halef satırının işlem sınırı yazılı değildi** ⇒ yarışı kaybeden istek ailede **sahipsiz ama geçerli** bir satır bırakırdı ve M39 bunu görmezdi |
| **M46** | `UseRateLimiter`, `UseStaticFiles`'tan **önceye** alınır | *"kimliksiz **40 statik dosya** isteğinden sonra `/v1/auth/login` isteği **`429` ALMAZ**"* **FAIL** | TS | **[Ma-11]** v3'ün PAZARLIKSIZ middleware sırası, §2-J'nin tamamının dayandığı çağrıyı **hiç anmıyordu**. Yanlış yer, değerlendiricinin sayfayı açar açmaz `429` görmesi demektir (ODEV §2) |
| **M47** | `/logout` yanıtından **`__Host-mrt` silme başlığı** kaldırılır | *"`/logout` yanıtı **`__Host-mrt` ve `__Host-mct`'nin İKİSİNİ birden** `Max-Age=0` ile siler ve silme başlıkları çerezin **kendi öznitelikleriyle birebir aynıdır**"* **FAIL** | TS | **[Ma-12]** v3'ün *"`/logout`'ta silinir"* cümlesi **yalnız CSRF çerezi** içindi; `__Host-mrt` `Path=/` gereği çıkıştan sonra **30 güne kadar** her isteğe takılmaya devam ederdi |
| **M48** | `ValidateIssuer` **veya** `ValidateAudience` `false` yapılır | *"**yanlış `iss`** taşıyan (aksi hâlde geçerli, doğru anahtarla imzalı) token korumalı uçta **`401`** alır"* **FAIL** · *"**yanlış `aud`** için aynı"* **FAIL** | TS | **[Ma-7]** v3 bunu §3.1'de *"çerçevenin kendi doğrulamasıdır"* diye muaf tutuyordu. **Yanlıştı:** `ValidateIssuer=false` **benim kodumdaki tek satırlık yapılandırmadır** — `ClockSkew` ile **birebir aynı sınıf**, ve `ClockSkew` için mutant yazılmıştı |

**ADR 0004'e ait mutantlar (burada YAZILMAZ, kaybolmasın diye adlandırılır):** M2 (`ActorId` ile yetki) · M3 (EF global filtre) · M9 (`client_id ↔ user_id`) · M10 (`IgnoreQueryFilters` allowlist dışı) · M20 (sahiplik TOCTOU) · **pull-authz mutantı** · **imleç opaklığı mutantı** · **D-7'nin zorlama mutantı**. **0004'ün yeni numaraları `M50`'den başlar [K16-d].**

**`slice-3b`'ye DEVREDİLEN mutantlar [bloker #9 kapanır — v2'de bunlar ne kapılıydı ne devirliydi]:**

| # | mutasyon | kill sinyali | seviye |
|---|---|---|---|
| **M-L5** | İstemcideki tek-uçuşlu kilit kaldırılır | *"eşzamanlı N adet 401 karşısında `/refresh` **TAM OLARAK 1 kez** çağrılır"* **FAIL** · **web ayağı:** *"iki sekmede eşzamanlı yenilemede `/refresh` tam olarak 1 kez çağrılır"* **FAIL** (Web Locks, K3-L9) | DART + **DART-WEB** |
| **M-L6** | 401'de gönderilmemiş kuyruk temizlenir | *"gönderilmemiş op'lar diskte kalır ve yeniden girişte gönderilir"* **FAIL** | DART |
| **M-L7** | Kullanıcı-başına DB dosyasından tek DB dosyasına dönülür | *"A çıkıp B girince A'nın görevleri okunamaz **VE** A yeniden girince kuyruğu duruyor"* **FAIL** | DART |
| **M-L8** | Ağ hatası dalı `401` dalıyla birleştirilir | *"ağ hatasında istemci **çevrimdışı-yetkili** kalır; 'oturum gerekli'ye GEÇMEZ"* **FAIL** | DART |
| **M-L9** | `429`/`5xx` dalı `401` dalıyla birleştirilir | *"`/refresh` **`429`** döndüğünde istemci **çevrimdışı-yetkili kalır**, 'oturum gerekli'ye **GEÇMEZ** ve `Retry-After` süresi kadar (yoksa üstel geri çekilme, tavan 60 sn) bekler"* **FAIL** | DART |

> **Ölçüt, belgenin kendi emsalidir:** 0004'e giden her mekanizma *"kaybolmasın diye adlandırılmış"*tı; 3b'ye giden **hiçbiri** adlandırılmamıştı. **Asimetri belgenin kendi standardıydı ⇒ ihlaldi ⇒ kapatıldı.**

> **KURAL [K6/K13-a'ya TABİ DEĞİL]:** her mutant **gerçekten koşulur**; *"beklenir"* diye akıl yürütmeyle KANIT yazılmaz (slice-2b1 BULGU-1 dersi). Bir mutant baseline'da **kırmızı doğuyorsa** o bir **ölü tuzaktır** ve **mekanizma tartışılır**, test gevşetilmez (M1/M7 dersi). Bir mutant uygulandığında test **yeşil kalıyorsa** o bir **kör kapıdır** ve **bloker'dır** (v2 denetiminin taksonomisi).

### 3.1 — MUTANTSIZ OLDUĞU AÇIKÇA YAZILANLAR [DÜRÜSTLÜK BEYANI]

v2'de bir dizi karar **sessizce kapısız** kaldı; v3 bu bölümü açtı ama **listesi eksikti** — denetim dokuz kapısız-ve-beyansız kalem buldu (Ma-6) ve bölümün kendi *"bu liste, tablonun tamlık iddiasının sınırıdır"* cümlesini ihlal etti. **v4'te o kalemlerin çoğu kapıya bağlandı** (M43 · M41 · M35'in ikinci ayağı · M36'nın çoklu assert'i · M44 · M31'in dördüncü ayağı · M32b), **kapısız kalanlar aşağıda tek tek beyan edildi.**

**v3'ten ÇIKARILAN muafiyetler (artık kapılıdır):**

| çıkarılan muafiyet | neden düştü | kapısı |
|---|---|---|
| `iss` / `aud` / `RequireSignedTokens` / `RequireExpirationTime` | *"Çerçevenin kendi doğrulamasıdır"* **yanlıştı**: `ValidateIssuer=false` benim kodumdaki tek satırlık yapılandırmadır — `ClockSkew` ile aynı sınıf (Ma-7) | **M48** *(`RequireSignedTokens` ve `RequireExpirationTime` muafiyeti **durur**: ikisinin mutasyonu imzasız/süresiz token üretmeyi gerektirir ve bu, çerçevenin token **üreticisini** mutasyona uğratmak olurdu — sınır burada, ve **kasten** buradadır)* |
| §2-M'nin NetArchTest kuralları (*"yalnız `Konscious.*` yenidir"*) | ADR 0001 K-H1 birebir okundu: **üç kural yenidir** ve K-H1 *"**her** kural commit'li mutant testle ısırdığını kanıtlar"* diyor (Ma-8) | **M32 · M32b · M32c** |
| K3-J4'ün `Retry-After` ayağı (`[DOĞRULANMADI]`) | **Ölçüldü:** `FixedWindowLease` `MetadataName.RetryAfter` **taşıyor**, `ConcurrencyLease` **taşımıyor** ⇒ koşulluluk kalktı | **M11**/**M41**'in gövde assert'leri |
| K3-L2'nin `HttpOnly`/`SameSite`/`Max-Age` öznitelikleri | Karar olarak yazılmışlardı ama **hiçbir mutant ölçmüyordu** (Ma-6) | **M36** (çoklu assert) |
| K3-L3(3)'ün **aile bağı** ayağı | M35 yalnız **imzayı** ölçüyordu ⇒ *"başka ailenin doğru imzalı token'ı"* geçerdi (Ma-6) | **M35**'in ikinci ayağı |
| K3-L10'un *"başlık yoksa `400`"* kuralı ve native-çerez-yok ayağı | Kapısızdı (Ma-6) | **M43**'ün üçüncü ayağı |
| K3-B6'nın e-posta **254 + format** ayakları | Kapısızdı (Ma-6) | **M31**'in dördüncü ayağı |
| K3-C6(2)'nin **dal (a)** ve dal önceliği | Kapısızdı (Ma-2/Ma-6) | **M44** |

**BUGÜN MUTANTSIZ OLANLAR — hepsi bilinçli, hepsi gerekçeli. Bu liste, tablonun tamlık iddiasının sınırıdır:**

| kapısız kalan | neden mutant yazılmadı |
|---|---|
| **`RequireSignedTokens` / `RequireExpirationTime`** | Mutasyonu, çerçevenin **token üreticisini** mutasyona uğratmayı (imzasız/`exp`'siz token üretmeyi) gerektirir. `ClockSkew` ve `ValidAlgorithms` **istisnadır** çünkü ikisi de **sessiz bir varsayılanı** değiştirir ve doğrulayıcı tarafta ölçülebilir (M16). |
| **K3-C4'ün ≤15 dk sınırı** | Bir **beyandır**, bir mekanizma değil. Mekanizması `exp`'tir ve onu M16 ısırır. |
| **K3-C8 `security_stamp`** | **Ölü alandır** (K14-d) — ölü bir alanın mutantı da ölü olurdu. Canlandırılırsa mutant **zorunlu** olur. |
| **K3-A3 `/register` sayım oracle'ı** | **Adlandırılmış sapmadır**; mutantı *"sapmayı geri al"* olurdu ve bu bir kapı değil bir **karar değişimidir**. |
| **K3-B4'ün SABİT-ZAMAN ÖZELLİĞİ** | **[Ma-6 — açıkça beyan ediliyor]** `FixedTimeEquals` çağrısının **varlığı** M6 (derleme) ve M6b (davranış) ile kapılıdır; ama *"elle yazılmış, erken çıkışlı bir döngü"* **ikisini de geçer** ve onu yakalayacak şey bir **zamanlama testidir**. Zamanlama testleri CI'da **kırılgandır** (gürültü, JIT, paylaşımlı runner) ⇒ bu belgenin *"ölü tuzak yazma"* kuralına aykırı olurdu. **Telafi kapı değil, gözden geçirmedir:** kod incelemesinde bu satır **adlandırılmış bir kontrol kalemidir**. Bu bir sınırdır ve gizlenmiyor. |
| **K3-L1/L2'nin platform seçimi** | İstemci tarafıdır ve paket seçimidir; kapısı `slice-3b`'nin lisans+CVE kapısıdır (kırmızı çizgi 3). |
| **K3-J6'nın NAT yanlış-pozitifi** | Kabul edilmiş bir **bedeldir**, bir mekanizma değil. (B2'den sonra bu bedel **varsayılan** durumdur — §6 Risk #14.) |
| **K3-I4'ün HKDF `info` etiketleri** | Etiket değişirse **tüm mevcut oturumlar düşer** ⇒ mutasyonu, sistemi çalışmaz hâle getiren bir değişikliktir; ayırt edici bir kill sinyali üretmez (her test kırılır). **M42 anahtarın kalıcılığını zaten ısırtıyor.** |
| **§2-M'nin `IAccessTokenIssuer`/`IRefreshTokenStore`/`ICsrfTokenService` port SATIRLARI** | Bunlar **port yerleşimi** kararlarıdır; NetArchTest ile ifade edilen **namespace kısıtları** yukarıda mutantlandı (M32/M32b/M32c). Portun **adı ve yeri** bir mimari tercihtir, ihlal-edilebilir bir kural değildir. |
| **`slice-3b`'ye devredilenler (M-L5…M-L9)** | Bu belgede **kapısızdır ve öyle olduğu yazılıdır**; kapıları `slice-3b` spec'inde koşar. Devir listesi §7'dedir. |

### 3.2 — KOŞUM SÖZLEŞMESİ: TESTLERİN NASIL AYAĞA KALKACAĞI PİNLENİR [YENİ — Ma-13/Ma-14 ve denetimin "ölçülemeyenler" kalemi]

> Denetim şunu bulguladı: *"builder'ın koşum tercihleri (minimal API mi controller mı, `AddProblemDetails()` çağrılıyor mu, `WebApplicationFactory` mi çıplak `TestServer` mi) — M37 ve M19'un kesin sonucu buna bağlı; **ADR bunu yazmıyor ve bu başlı başına bir eksikliktir.**"* Bu bölüm o eksikliği kapatır. **Aşağıdakiler mutantların önkoşuludur, üslup tercihi değildir.**

1. **`TS` seviyesindeki her test `WebApplicationFactory<Program>` ile ayağa kalkar** — çıplak `new TestServer(...)` **YASAKTIR**. *Gerekçe:* `WebApplicationFactory` üç ayrı yolda `UseEnvironment(Environments.Development)` çağırır (ölçüldü) ⇒ `ValidateOnBuild`/`ValidateScopes` **açıktır** ⇒ **M19 ısırır**. Çıplak `ServiceCollection` ile mutant sessizce hayatta kalır.
2. **Kimlik doğrulama testleri gerçek `AddJwtBearer` boru hattından geçer** — sahte `TestAuthHandler` / `AuthenticationSchemeOptions` ikamesi **YASAKTIR** (M24, M16, M48'in önkoşulu).
3. **`AddProblemDetails()` çağrılır ve `DefaultProblemDetailsWriter` kullanılır** — özel bir `IProblemDetailsWriter` yazılmaz. *Gerekçe:* M37'nin *"`traceId` hariç aynı"* sinyali bu yazıcının davranışına pinlidir; özel yazıcı sinyali sessizce değiştirir.
4. **Uç stili: `MapGroup("/v1")` + minimal API handler'ları.** *(Controller'lar yasak değildir ama `[Authorize]`/`AllowAnonymous` metadata'sının nereye düştüğü M14/M33a'nın sinyalini etkiler ⇒ **tek stil pinlenir**.)*
5. **`TimeProvider` her testte `FakeTimeProvider`'dır** (K-C5) — M17/M27/M29/M30/M40'ın **tamamı** saat ilerletmeye dayanır.
6. **`TC` seviyesi = Testcontainers + gerçek PostgreSQL**, her test sınıfı için **temiz şema**. `TestServer` içi kilitler ya da in-memory sağlayıcı **atomiklik iddialarını kanıtlamaz** (M39/M45).
7. **`KON` seviyesi = gerçek imaj.** `docker build` + `docker run`; gözlemlenen şey **çıkış kodu**, **stderr** ve **dosya sisteminin durumu**dur (M8b, M42). Bu testler CI'da ayrı bir job'dadır ve **yerelde de koşabilir olmalıdır**.
8. **Baseline kuralı [K6/K13-a'ya tabi değil]:** her mutant **gerçekten koşulur** ve mutasyondan **önce** testin **yeşil** olduğu kaydedilir. *"Beklenir"* diye akıl yürütmeyle KANIT yazılmaz (slice-2b1 BULGU-1 dersi).

---
## 4. Gerekçe

**Bu belgenin değeri "kimlik doğrulama eklendi"de değil, üç yerdedir.**

**Birincisi: token modeli kanıtlanabilirlik için seçildi, konfor için değil.** Stateless bir yenileme JWT'si iptal edilemez — dolayısıyla üzerine **ısıran bir kapı kurulamaz**. Opak + DB + döndürme + yeniden-kullanım tespiti ise **ölçülebilir bir davranıştır**: mutantla kırılır, testle yakalanır. v1'in **zarafet penceresi** tam da bu ölçütten düştü: mekanizmanın kendisi kapıyı **yapısal olarak erişilemez** kılıyordu. Cevap testi gevşetmek değil, **mekanizmayı kaldırmak** oldu.

**İkincisi: parola tarafında asıl mimari iş paket seçimi değil, paketin İZOLASYONUDUR.** Kapı, **aktif bakımlı** adayın (NSec/libsodium) hedef platformda OWASP parametreleriyle **koşamadığını**, **~25 aydır dormant** adayın (Konscious) koştuğunu ölçtü — yani *"en iyi bakılanı seç"* sezgisi bu vakada **yanlış paketi seçerdi**. Buna verilen cevap paketi savunmak değil; `IPasswordHasher` portu + kendini tarif eden hash string'i + rehash-on-login ile **paketi yarın değiştirilebilir kılmaktır**.

**Üçüncüsü — v3'ün eklediği ders: BİR MEKANİZMANIN "DOĞRU" OLMASI, KENDİSİNE YÜKLENEN GÖREVİ YAPABİLDİĞİ ANLAMINA GELMEZ.**
v2 tek-uçuşlu refresh'i doğru tarif etti, doğru gerekçelendirdi, doğru yere koydu — ve sonra ona **yapısal olarak yapamayacağı bir görev yükledi**: *"meşru istemcinin kendini hırsız ilan ettirmemesi bu mekanizmaya bağlıdır."* Tek-uçuşluluk eşzamanlılığı çözer; **kaybolan yanıtı çözmez.** Aradaki fark bir uygulama hatası değil, bir **kategori hatasıdır** ve ancak *"bu mekanizma tam olarak hangi girdi uzayını kapsıyor"* diye sorulduğunda görünür.
**Aynı hata sınıfı bu belgede beş kez daha bulundu:** `FallbackPolicy` deny-by-default'u kurar ama **statik dosyaları da vurur** · `SameSite=Strict` çapraz-site CSRF'ini kapatır ama **kardeş alt alan adını kapatmaz** · naif double-submit token'ı doğrular ama **çerezi kimin yazdığını doğrulamaz** · `ValidAlgorithms` pinlemesi algoritma seçer ama **`alg:none`'ı `RequireSignedTokens` kapatır** · `revoked_at` kolonu iptali **kaydeder** ama `/refresh` yüklemi ona **bakmaz**.
**Bir ADR'nin işi mekanizmayı adlandırmak değil, KAPSAMINI yazmaktır.** v2'nin manşet tezi *"sessiz varsayılanların hangisinin kabul edildiğini yaz"*dı; v3 onu genişletiyor: **"ve her mekanizmanın neyi kapsamadığını da yaz."**

**Dördüncüsü — v4'ün eklediği ders: BİR KARARIN GEREKÇESİ, ÖLÇÜLMEMİŞ BİR OLGUYA DAYANIYORSA, KARAR DOĞRU ÇIKSA BİLE GEREKÇE BORÇTUR.**
K14-e (tek konteyner, reverse-proxy yok) **üç** gerekçeyle kilitlenmişti: CORS gerekmez · `SameSite=Strict` çalışır · **`RemoteIpAddress` gerçek istemci IP'sidir**. İlk ikisi topolojinin **tanımından** çıkar; üçüncüsü **ölçülmemiş bir olgu iddiasıydı** ve gerçek koşu onu yanlışladı (üç yolun üçünde de `172.17.0.1`). **Karar ayakta kaldı, gerekçenin üçte biri düştü** — ve düşen ayak, üzerine bir kapı (`M11`/`M23`'ün *"IP partition'ı"* okuması), bir risk maddesi (§6 #5) ve bir sayı kümesi (K14-i) inşa edilmiş olan ayaktı. Bir kilit yanlış bir olgu üzerine kurulduğunda **kilidin kendisi değil, ondan türeyen her şey** kirlenir.
**Bunun operasyonel karşılığı bu belgede zaten vardı ve işe yaradı:** `[DOĞRULANMADI]` etiketi. `ConcurrencyLease`'in `RetryAfter` taşıyıp taşımadığı v3'te ölçülmemişti ve **koşullu** yazılmıştı; kapı-3'te ölçüldü, koşulluluk kalktı, **hiçbir şey geri alınmadı**. `RemoteIpAddress` ise **koşulsuz** yazılmıştı ve geri alındı. **Fark, iddianın doğruluğu değil, ETİKETLENMİŞ OLMASIYDI.** ⇒ **v4'ün kuralı:** *bir kararın gerekçesindeki her olgu iddiası ya ölçülür ya `[DOĞRULANMADI]` etiketi taşır; üçüncü seçenek yoktur.*

**Beşincisi: SEMANTİK OLARAK DOĞRU BİR KURAL, ŞEMA ONU TAŞIYAMIYORSA İNŞA EDİLEMEZ.**
K14-a'nın replay-idempotency'si beş eksende v1'in zarafet penceresinden ayrılıyordu ve **bu ayrım denetimde kırılamadı — yapısal olarak doğruydu.** Ama *"kayıtlı halef **aynen** döndürülür"* cümlesi, üç ayrı doğru kararın (yalnız-özet saklama · şemada ham kolon yokluğu · M12'nin bunu zorlaması) kesişiminde **inşa edilemez** hâle geliyordu. **Hiçbir denetçi bunu tasarımı okuyarak bulamazdı; ancak *"sunucu bu değeri NEREDEN alacak"* diye sorulduğunda görünür.** ⇒ Bir ADR maddesi yalnız *"ne olmalı"*yı değil, **"bunu üretecek veri hangi satırda duruyor"**u da yazmalıdır (K15-a bunu `successor_secret_enc` ile kapattı — ve **yeni bir risk doğurduğunu** §6 #13'te itiraf ederek).

**Türkçe locale kararı (K3-A2) bu projeye özgü ve ÖLÇÜLMÜŞ bir risktir:** aynı makinede aynı locale Postgres `initdb`'yi zaten kırdı. Kültüre-duyarlı bir `ToLower()` çağrısı, testlerini invariant kültürde koşan bir CI'da **asla görünmeyecek** bir kimlik hatası üretirdi. Aynı tuzağın frontend ucu (Dart `toUpperCase()`) K10'da bağımsız olarak bulundu.

## 5. Alternatifler

| Eksen | Seçilen | Reddedilen (gerekçe) |
|---|---|---|
| Kimlik altyapısı | Elle ince implementasyon | ASP.NET Core Identity (katman baskısı, kullanılmayan 5 tablo, **kendi kapını gevşetme**) |
| Parola KDF | Argon2id (Konscious 1.3.1, izole) | Isopoh (**lisans belirsiz**) · NSec-libsodium (**OWASP parametrelerinde koşmadı**) · PBKDF2 (K8-c yedeği) |
| **Parola politikası** | **NIST SP 800-63B-4: ≥15 (tek faktör `SHALL`), karmaşıklık YOK, ≤128** [K16-a] | Kapsam dışı ilan etmek (**Argon2 DoS tavanı açık kalır**) · klasik kompozisyon kuralları (NIST-4 birebir *"SHALL NOT impose other composition rules"*) · **≥10'da kalıp adlandırılmış sapma yazmak** (doktrine uygun ama uyumun bedeli burada yalnız bir README satırı) · **12** (hiçbir standartta karşılığı yok ⇒ keyfi) |
| **Halefin saklanması** | **`successor_secret_enc`: HKDF alt anahtarıyla AES-256-GCM, 60 sn sonra `NULL`** [K15-a] | Dal (c)'yi *"yeni token üret ama halef olarak kaydet"* diye yeniden yazmak (*"yeni döndürme yapılmaz"* cümlesi düşer, ailede satır birikir) · K14-a'yı tümüyle geri almak (uçak modu demosunun ortasında yeniden giriş) · şifresiz saklamak (DB dökümü = 30 günlük kullanılabilir token) |
| **Anahtar mimarisi** | **Tek kök anahtar + HKDF-SHA256 ile üç amaç-bağlı alt anahtar** [K16-c] | Üç ayrı sır (üç fail-fast + üç bootstrap + üç mutant; K15-a'nın *"üçüncü sır doğmasın"* kısıtının reddi) · iki sır (anahtar-amaç ayrımını kısmen bozar) · kök anahtarı üç yerde **doğrudan** kullanmak (aynı anahtarla hem imzalamak hem şifrelemek) |
| **Hız sınırı politikaları** | **Uç ailesine göre üç ayrı politika: 30 / 120 / 60 (5 dk)** [K16-b] | Tek ortak kova (v3: 10/5 dk — **her F5 bir `/refresh`** olduğu için işbirliği demosunu keser) · 60/240/120 (kontrol 1'in DoS anlamı sembolikleşir) |
| Yenileme token'ı | Opak + DB + döndürme + reuse-detection | Stateless JWT-refresh (iptal edilemez) · tek uzun ömürlü JWT (çevrimdışı kuyruk kaybı) |
| **Kayıp yanıt telafisi** | **Sınırlı replay-idempotency (60 sn, halef tüketilmemiş)** | **Telafisiz adlandırılmış sınır** (RFC 9700 bunu maliyet sayar ama uçak modu demosunun ortasında yeniden giriş üretir) · **`Idempotency-Key`** (yeni tablo + TTL + temizleme; aynı sonuç, daha geniş yüzey) · **v1'in zarafet penceresi** (sonsuz zincir, K3-C6'daki tabloya bkz.) |
| JWT imzası | HS256 (simetrik) | ES256 (tek servis topolojisinde karşılıksız anahtar dağıtımı) |
| Yenileme yarışı | Sunucuda saf reuse-detection + **sınırlı replay** + istemcide tek-uçuşlu refresh | Katı tek-kullanım + istemci çözümü yok (meşru istemciyi hırsız ilan eder) |
| `family_id` kapsamı | Giriş başına (cihaz/oturum) | Kullanıcı başına tek aile (çok-cihaz demosu bozulur) |
| E-posta eşsizliği | `Trim` → NFC → `ToLowerInvariant` + `COLLATE "C"` | `ToLower()` (tr-TR'de İ/ı) · `citext` (Postgres'e kilitler) · normalizasyonsuz |
| `/register` sayım oracle'ı | Adlandırılmış sapma + beyan | Her durumda `202` · yalnız rate-limit |
| Kaba kuvvet | IP penceresi (middleware) + e-posta penceresi (**handler**) + eşzamanlılık limiti | Tek birleşik "IP+e-posta" anahtarı (**R2**) · **e-posta anahtarını başlıktan almak** (anahtarı istemci seçer) · hesap kilitleme (kurbanı kilitleten DoS) |
| **Dağıtım topolojisi** | **Tek konteyner; API statik dosyaları servis eder** *(gerekçesi K15-b ile daraltıldı: CORS + `SameSite`; **IP ayağı geri çekildi**)* | **Reverse-proxy** (`ForwardedHeaders` + `KnownProxies` zorunlu; M11/M23 `X-Forwarded-For` testlerine taşınmalı; dağıtım tek birim olmaktan çıkar) · ikisini birden desteklemek (kapı yükü ×2) · çapraz origin + `SameSite=None` |
| **Kök anahtar bootstrap'ı** | **Compose ilk açılışta rastgele üretir (yalnız Development), giriş betiğinde** | `.env.example` + README adımı (tek komut yetmez) · repoda DEV-ONLY sabit anahtar (kırmızı çizgi #1) · bootstrap'ı `Program.cs`'e almak (`KON` seviyesi gerekmezdi ama `Production` imajında ölü bir yazma yolu kalırdı) |
| **Token teslim kanalı** | **`X-Client-Kind` başlığı + JWT'ye `fid`** | Ayrı alt yollar (uç sayısı ×2) · her platformda çerez (K3-L1 düşer) |
| **CSRF ikinci hattı** | **`__Host-` + HMAC'li, aileye bağlı double-submit** | **Naif double-submit** (OWASP: *"reference only"*; kardeş alt alan adı çerez yazar) · CSRF'i tamamen kaldırmak (`Strict` alt alan adını kapatmıyor) |
| Token deposu (web) | `HttpOnly` çerez (yenileme) + bellek (erişim) | `localStorage`/IndexedDB (tek XSS sızdırır) · yalnız bellek (F5 = çıkış) |
| Çıkışta yerel veri | Kullanıcı-başına DB dosyası, silme YOK | Tek DB + çıkışta silme (kuyrukta veri kaybı; kırmızı çizgi 4) |
| **`security_stamp`** | **Ölü alan, beyan edilmiş** | Canlandırma (istek başına 1 DB okuması + K3-K3'ün kapsam kararını sessizce geri alır) · tamamen kaldırma (ileriye kanca kalmaz) |

## 6. Riskler / açık noktalar

1. **`Konscious` ~25 ay hareketsiz** — adlandırılmış risk (K3-B1). Telafi **kapatma değil izolasyon**. **Tetikleyici:** CVE düşerse PBKDF2'ye geçiş **tek sınıflık** iştir.
2. **`/register` sayım oracle'ı** — **adlandırılmış sapma** (K3-A3). `KANIT` ve README'de beyan edilir. *"Sonra düzeltiriz" değil, "bilerek buradayız" kalemidir.*
3. **Erişim token'ı anlık iptal edilemez** (≤15 dk pencere) — beyan edilmiş sınır (K3-C4). **`security_stamp` bu pencereyi sıfırlayabilirdi ve bilinçli olarak KULLANILMIYOR** (K3-C8/K14-d). `ClockSkew=0` sayesinde pencere gerçekten 15 dk'dır, 20 değil.
4. **Argon2id 270 ms + 19 MiB / istek** — gerçek maliyet; sahte hash (K3-B5) bunu bilinmeyen e-postalarda **da** ödetir. Maliyeti sınırlayan **kontrol 1'in küresel tavanı + eşzamanlılık limitidir** — ve **asıl koruyan eşzamanlılık limitidir** (kontrol 1 bir tavandır, bir ayrım değil; B2/K15-b); e-posta penceresi maliyete **hiçbir şey katmaz**. Kalan yüzey: **botnet/proxy havuzu** — tek IP penceresi onu durdurmaz; eşzamanlılık limiti hizmeti ayakta tutar ama **gecikme artar**. Tek-instance bir ödev dağıtımında **kabul edilen ve beyan edilen** sınır.
5. **~~Rate limiter partition belleği~~ → ✅ KAPANDI** (K3-J5, ölçüldü: 10 sn atıl temizleme). **Kalan doğru ifade [v4'te DÜZELTİLDİ — B2]:** tavan ≈ istek hızı × 10 sn, ve tavanı anlamlı kılan şey **kontrol 1'in küresel istek tavanıdır** (30/5 dk). v3 burada *"IP penceresidir"* diyordu; **tek konteynerde IP penceresi diye bir şey yoktur.**
6. **RateLimiter'ın çok-instance davranışı** — bellek-içi sayaç **tek instance'a** özgüdür. Tek-instance dağıtımda sorun değil; K3-K3'te kapsam dışı.
7. **Web dağıtım topolojisi KİLİTLİ: tek konteyner, aynı origin, proxy yok** (K3-L4 / K14-e). **Kalan yüzeyler adlandırıldı:** (a) `SameSite=Strict` **kardeş alt alan adlarını** kapsamaz ⇒ K3-L3'ün imzalı ikinci hattı durur · (b) **`Secure` çerez `http://localhost` dışında set edilmez** ⇒ teslim paketi ve README `localhost` kullanımını **zorunlu** kılar (RT-M1) — **ve bu kısıt WebKit/Safari'de ÖLÇÜLMEMİŞTİR (§6 #15)** ⇒ teslim paketi *"Chromium tabanlı tarayıcı"* notunu taşır · (c) aynı-origin kararı **teslim paketini bağlar**: web build'i API ile birlikte servis edilmelidir (CI/CD ve paketleme adımında görünür gereksinim).
8. **`slice-3b` bağımlılığı:** `flutter_secure_storage`'ın **lisansı ölçüldü (BSD-3-Clause, izinli aile)**; **CVE ayağı 3b'de koşar** ve düşerse K3-L1 yeniden açılır. **Windows şifreleme yöntemi `[DOĞRULANMADI]`** — v2'nin DPAPI iddiası geri çekildi.
9. **Parola değiştirme yok** (K3-K3) ⇒ `/logout-all`'ın en doğal tetikleyicisi de yok. Uç yine de vardır ve testlidir (M18). **Fazladan yüzey olduğu kabul edilir**, gizlenmez.
10. **[YENİ — RT-M5] Aynı-origin kararının XSS SONUCU, adlandırılıyor:** `HttpOnly` çerez, XSS'in yenileme token'ını **okumasını** engeller — ama **kullanmasını engellemez.** Sayfa açıkken enjekte edilmiş bir betik `/refresh`'i çağırabilir (çerez otomatik gider, CSRF çerezi JS'e **okunabilir** olmak zorundadır) ve **her 15 dk'da bir taze erişim token'ı** elde edebilir. **`HttpOnly`'nin satın aldığı şey gerçektir ama sınırlıdır: token *dışarı sızdırılamaz*, ama *sayfa açıkken kullanılabilir*.** Kapatmanın yolu XSS'i hiç doğurmamaktır (CSP + Flutter web'in DOM'a ham HTML yazmaması); bu `slice-3b`'nin işidir ve orada adlandırılacaktır.
11. **[YENİ — K14-a'nın kabul edilmiş bedeli]** Replay-idempotency penceresi, çalınmış bir token için reuse-detection'ı **kaldırmaz ama 60 saniye geciktirir** (K3-C6(3)'ün dürüst muhasebesi). Pencere süresi (60 sn) **K16-b ile Onur tarafından kilitlenmiştir** — v3'teki *"Onur kilidi değildir"* şerhi **düştü** (Ma-16: o şerh belgenin *"açık çatal yoktur"* beyanıyla çelişiyordu).
12. **~~`ConcurrencyLease` × `Retry-After`~~ → ✅ KAPANDI (ölçüldü).** `FixedWindowLease` `MetadataName.RetryAfter` **taşıyor**; `ConcurrencyLease` **taşımıyor** (yalnız `ReasonPhrase`). K3-J4'ün koşulluluğu kalktı: middleware ayağı lease'ten okur, kontrol 2 pencereden hesaplar, **kontrol 3 `Retry-After` YAZMAZ** ve istemci bunu üstel geri çekilmeyle karşılar (K3-L8/4).
13. **[YENİ — K15-a'NIN BEDELİ, ADLANDIRILIYOR] DB sızıntısı, dar bir pencerede KULLANILABİLİR token verir.** `successor_secret_enc`, halefin ham değerini **şifreli** olarak tutar. Bir saldırgan **hem DB dökümünü hem kök anahtarı** ele geçirirse, o pencerede tüketilmiş satırların halefleriyle **çalışan oturumlar** elde eder. **Pencere: 60 sn (yüklem) + azami 60 sn (süpürme periyodu) = en kötü durumda 120 sn.** *Neden kabul edildi:* alternatifi K14-a'yı geri almaktı (uçak modu demosunun ortasında yeniden giriş — ODEV §2) ya da değeri **şifresiz** tutmaktı (30 günlük kullanılabilir token). *Telafi:* şifreleme (K16-c'nin `rt-successor-enc` alt anahtarı) + **fiilen silme** (M40) + kısmi indeks. **v3'ün *"DB'de ham değer hiç bulunmaz"* iddiası artık bu istisnayla birlikte okunur** (§0.4).
14. **[YENİ — B2'NİN BEDELİ] Kontrol 1 KÜRESELDİR: tek istemci tüm tavanı tüketebilir.** `RemoteIpAddress` bu dağıtımda köprü ağ geçididir (ölçüldü) ⇒ hız sınırı bir **kullanıcı ayrımı** değil, servisin toplam yüküne konmuş bir **tavandır**. Sonucu: kötü niyetli **ya da yalnızca gürültülü** tek bir istemci, `/login` tavanını (30/5 dk) doldurup **diğer kullanıcıların girişini geçici olarak engelleyebilir**. Tek-instance bir ödev dağıtımında **kabul edilmiş ve beyan edilmiş** sınırdır; kapatmanın yolu (reverse-proxy + `X-Forwarded-For`, ya da kullanıcı-anahtarlı ikinci katman) **K3-K3 ile kapsam dışıdır**. **Argon2'yi koruyan asıl mekanizma kontrol 3'tür ve o küresel olmaktan zaten etkilenmez.**
15. **[YENİ — DOĞRULANMADI] WebKit/Safari'nin `http://localhost` üzerinde `Secure` / `__Host-` davranışı ölçülmedi.** Chromium ve Firefox `localhost`'u güvenli bağlam sayar; WebKit'in aynı davranışı gösterdiği **tarayıcı kaynağından doğrulanmamıştır**. ⇒ Safari'de yenileme çerezi hiç set edilmeyebilir ve `/refresh` sessizce çalışmayabilir. **Telafi tek satırlıktır ve teslim paketindedir:** *"demo Chromium tabanlı bir tarayıcıda açılmalıdır"*. Ölçülünce ya kapanır ya adlandırılmış sınır olur.
16. **[YENİ — ADLANDIRMA BORCU ÖDENİYOR] RFC 9700 §4.14.2 ile ilişki.** RFC, döndürmeli yenileme token'ları için **`MUST`** koşulunu *"replay tespit yöntemlerinden **birini** kullan"* için koyar; *"yeniden kullanım tespit edilince ailenin iptal edilmesi"* cümlesi **betimleyicidir**. Momentum döndürme + yeniden-kullanım tespiti uygular ⇒ **ihlal yoktur.** K14-a'nın 60 saniyelik penceresi, iptali **kaldırmaz, geciktirir** (K3-C6/3'ün dürüst muhasebesi) — bu, RFC'nin adlandırdığı ödünleşimin **bilinçli bir noktasıdır** ve burada adıyla kayda geçmiştir.

## 7. İlgili

- **Öncül:** ADR 0001 (K-C1 `ownerId`, K-C5 `TimeProvider`, **K-D5**, K-E1 UUIDv7, **K-H1 banned-API + NetArchTest — "Her kural mutantla ısırdığını kanıtlar"**, K-H2 lisans ailesi) · ADR 0002 (**K2-E3** pull/push authz, K2-E5 op-başına txn + kısmi red, K2-A4 `sync_client_clock`, **K2-H12** paralel yarış testi emsali, §6/7 **M-C**).
- **⚠ BORÇ DURUMU — BEŞ BORÇ, bu belge tek başına HİÇBİRİNİ KAPATMAZ:**

| borç | bu belgede | ADR 0004'te | durum |
|---|---|---|---|
| **K-D5** `ICurrentUser` + owner filtre | sözleşme + impl (§2-D) + **port yerleşimi (§2-M)** | **global query filter** | 🟡 yarısı |
| **M-G** push-authz | — | tamamı | 🔴 açık |
| **K2-E3** pull-authz | — | tamamı + **eksik mutantı** | 🔴 açık |
| **M-C** `clientId → principal` | — | tamamı (**D-6 + D-7**) | 🔴 açık |
| **B4** `outbox_messages.owner_id` | — | tamamı | 🔴 açık |

- **ADR 0004'e DEVREDİLEN, KAYBOLMASIN DİYE ADLANDIRILAN İŞLER:**
  - **D-1** SignalR hub kimliği (K11-a) + **özel `IUserIdProvider` ZORUNLU** (K3-C7'nin ölçülmüş yan etkisi) + token'ın `?access_token=` query string'inden alınması.
  - **D-2** `outbox_messages.owner_id` `ICurrentUser.UserId`'den türer; ingest'te `op.ActorId ≠ token sub` ⇒ **istek reddedilir** (K11-b).
  - **D-3** Global query filter kurulurken **`User` KAPSAM DIŞI** bırakılmalıdır (K3-A4) — aksi hâlde anonim `/login` `UnauthenticatedException` alır ve **giriş fiziksel olarak kilitlenir**. Mutant zorunlu.
  - **D-4** Pull yolunun **ham SQL** olduğu ve `commit_xid`/`server_seq`'in EF'te map edilmediği ⇒ **global filtrenin oraya fiziksel olarak ERİŞEMEDİĞİ** yazılır. **Ayrı pull-authz mutantı zorunlu.**
  - **D-5** **K3-G2 düzeltmesi:** imleç yan-kanalı *"kapatılamaz"* DEĞİLDİR — `server_seq` bir `IDENTITY` kolonu olduğu için sızan şey **tam sayaçtır**. İmleç **opak/HMAC'li** döndürülür + **boş-sayfa `nextCursor` çatalı** kurulur.
  - **D-6** `sync_client_clock`'a `user_id` eklenmesi + backfill politikası.
  - **D-7 [YENİ — Ma-7 kapanır]** **`clientId → principal` ZORLAMA KURALI.** D-6 yalnız **kolonu** ekliyordu; *"bir `clientId` **başka bir principal** tarafından kullanılırsa ne olur"* sorusunun karşılığı hiçbir D maddesinde **yoktu** — yani `M-C` borcu 0004'te de yarım kapanacaktı. Kural yazılmalı (öneri: `sync_client_clock.user_id ≠ ICurrentUser.UserId` ⇒ **istek reddedilir**, cihaz kaçırma sinyali) ve **mutantı zorunlu**. Ayrıca **M20 (sahiplik TOCTOU)**'un iniş yeri 0004'te açıkça belirlenmeli.
  - **[NUMARA PİNİ — K16-d ile GÜNCELLENDİ]** 0004'ün yeni mutantları **`M50`'den** başlar. *(v3'ün `M40` pini geçersizdir: v4 M40–M48'i tüketti. 0004 henüz hiçbir numarayı tüketmediği için pini taşımak bedelsizdir.)*
- **`slice-3b`'ye DEVREDİLEN mutantlar:** **M-L5** (tek-uçuşluluk + **web ayağı: Web Locks**, K3-L9 — seviye `DART` + `DART-WEB`) · **M-L6** (401'de kuyruk) · **M-L7** (kullanıcı-başına DB) · **M-L8** (ağ hatası ≠ 401, K3-L8) · **🆕 M-L9** (`429`/`5xx` = geçici, K3-L8/3 — **B3'ün istemci ayağı**). Ayrıca **XSS yüzeyinin CSP ayağı** (§6 Risk #10) ve **teslim paketinin demo hesabı + `localhost` + Chromium notu** (K16-a, RT-M1, §6 #15).
- **Sıradaki:** **bağımsız kapı** (architecture + red-team, **RED-TEAM EN SON**; üreten ≠ denetleyen — **bu belgeyi yazan oturum onu denetleyemez**) → **K13-a: bloker sıfırlanana kadar tur** → Onur kilidi → ayrı oturumda **ADR 0004** → **`GOREV-slice-3c-auth`** spec'i → Claude Code build → **Cowork TEMİZ OTURUMDA bağımsız doğrular**.
- **Sonra:** `slice-3b` (Flutter istemci) — §2-L'nin token/kuyruk/DB/profil kararları Drift şemasını ve depo katmanını **doğrudan** belirler.

---

*🟡 **TASLAK v4 — KİLİTLİ DEĞİL.** v3'ün **9 blokeri ve ~20 majörü** kapatıldı; beş çatal Onur tarafından kilitlendi (**K15-a/b · K16-a/b/c**); **üç iddia açıkça geri çekildi** (§0.4). **Bağımsız kapı KOŞMADI — bu 4. tur için AYRI ve TEMİZ bir oturum gerekir (K13-a: bloker sıfırlanana kadar tur).** Bu ADR'yi yazan el onu onaylayamaz.*
