# ADR 0003 — v4'ÜN KAPANMA TABLOLARI (denetim izi, ADR'den ÇIKARILDI)

> **Neden burada:** kapı-4 raporu §7(3) ve **K19-a** kararı gereği §0.1–§0.3
> (dokuz blokerin/majörlerin nerede kapandığı + Onur'un beş çatalı) ADR'den
> **KANIT'a taşınmıştır**: ADR bir **karar** belgesidir, denetim izi burada yaşar.
> **Hiçbir satır silinmemiştir** — bu dosya v4'ün 24–70. satırlarının BİREBİR kopyasıdır
> (13.451 bayt gövde). ADR §0, bu dosyaya atıf yapar.
>
> Kaynak: `docs/ADR/0003-kimlik-cekirdegi.md` v4, sha256 `b85ce0b3…0c45d0`.

---

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
