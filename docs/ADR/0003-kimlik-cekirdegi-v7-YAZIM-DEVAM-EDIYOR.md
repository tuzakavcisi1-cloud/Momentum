# ADR 0003 — Kimlik Çekirdeği (`slice-3c-auth`, 1/2)

- **Durum:** 🟡 **TASLAK v6 — KİLİTLİ DEĞİL; 6. TUR BAĞIMSIZ KAPIYI BEKLİYOR.** v5'e **beşinci** bağımsız kapı koştu; hüküm **KİLİTLENEMEZ** oldu (**12 bloker · 7 majör · 6 aday bloker**; rapor: `KANIT/adr-0003/kapi-5-denetim-raporu.md`). **Bu sürüm o 12 blokerin 12'sini de, 7 majörün 7'sini de kapatır**, Onur'un **K28** (dört kilit) ve **K30** (dört kilit) kararlarını yazar ve kapı-4'ten devreden iki majörü (`M19`'un ayırt ediciliği · `M42c`'nin `KON` gözlem yüzeyi) **kapatır**. **K13-a yürürlükte: bloker sıfırlanana kadar tur; tur sayısı raporlanır, sınırlanmaz.**  <!-- [KS-LITERAL: KAPI BULGU SAYIMI — 12 bloker / 7 majör / 6 aday bloker, kapı-5 raporunun sayımıdır; kanonik değer değildir] -->
- **⚠ BU SÜRÜMÜN OKUYUCUSUNA — v5'İN ÜÇ YAPISAL DEĞİŞİKLİĞİ [K19-a]:**
  1. **`§1-K KANONİK SAYILAR` doğdu (KS-1…KS-30; v6'da **`KS-31`** eklendi — K28-c).** Her tavan, ömür, uzunluk ve boyut **bir kez** yazılır; gövde **`[KS-n]`'e atıf yapar, sayıyı KOPYALAMAZ.** *Neden:* kapı-4'ün dokuz blokerinden **ikisi (B-1, B-8)** doğrudan *"kardeş kalem güncellendi, kendisi unutuldu"* sınıfındandı ve kontrol 1'in tavanı v4'te **yedi ayrı yerde** yazılıydı. **Bu kural, o hata sınıfını YAPISAL OLARAK imkânsız kılar.**
  2. **§0.1–§0.3 (kapanma tabloları, **11.112 bayt** (ölçüldü: v4'ün 24-70. satırları)) KANIT'a taşındı** — `KANIT/adr-0003/v4-kapanma-tablolari.md`. Hiçbir satır silinmedi. ADR bir **karar** belgesidir; denetim izi KANIT'ta yaşar.
  3. **§3.1'in tamlık iddiası artık ÖLÇÜLÜYOR** — `araclar/adr-kapi-taramasi.py`. Kapı-2, kapı-3 ve kapı-4'ün **üçü de** o cümleyi çürütmüştü; v5 cümleyi geri çekmedi, **mekanik hâle getirdi**; kapı-5 aracı **kırdı** ve araç oturum 22'de **onarıldı** (altın küme 5 → 22 kontrol). **Onarılmış aracın v6 üzerindeki koşumu: `K1` = 0 · `K2` = 0 · `K3` = 0 · `K5` = 0 · `K6` = 2 · `K4` = 5.** *(Kalan yedi bulgunun **hepsi adıyla adjudike edilmiştir** ve §3.1'dedir: ikisi aracın **yanlış-pozitifi** — `§3.2(9)` bölüm atfını sınır-değer sanıyor —, ikisi **granülerlik farkı** (`K6`), üçü aracın **kendi kapsam beyanı**. **Sessiz eleme YOKTUR.)* *(Aracın üç beyan edilmiş sınırı §3.1'in başındadır — başlıcası: araç **etiketin varlığını** ölçer, mutantın o kararı gerçekten ısırdığını ÖLÇEMEZ.)*
- **⚠ v6'NIN DÜRÜSTLÜK BEYANI — NE YAPILDI, NE YAPILMADI:**
  - ✅ **9/9 bloker kapatıldı:** B-1 (`M11` ölü tuzağı) · B-2 (`M46` körlüğü — K19-b) · B-3 (§3.1 tamlık — ölçüm aracı) · B-4 (katman kararı — K18-a, **M49**) · B-5 (nonce + AAD — K18-b, yeni karar **K3-I5**, **M50**/**M51**) · B-6 (e-posta ayağı — **M52**) · B-7 (hız-sınırlayıcı izolasyonu — §3.2(9)) · B-8 (`M22` ölü tuzağı) · B-9 (testlerin sır kaynağı — K18-c, §3.2(10)).  <!-- [KS-LITERAL: v5 özet başlığı — bloker/majör sayıları ve tur sayıları; kanonik değer değil] -->
  - ✅ **Oturum 21'in ÜÇ YENİ ölçülmüş bulgusu da kapatıldı** (kapı-4 bunları göremezdi; `src/`, `tests/`, `docker-compose.yml` o oturumda **bağlı değildi**): **Y-1** `Dockerfile` yoktu ⇒ **K22-a** ile bu dilimin işi oldu · **Y-2** §3.2(5) olgusal olarak yanlıştı (`Program.cs:34` `TimeProvider.System`) · **Y-3** yasak `TestAuthHandler`'a ama gerçek ikame **`FakeCurrentUser`**'dı.
  - ✅ **15 majör yazıldı** (aralarında: `+` kaçışının **koşularak ölçülmüş** gerçek biçimi · `[KS-4]`'ün sahibinin **K14-a** olarak düzeltilmesi · NIST SP 800-63B-4 §3.2.2'nin **adlandırılmış sapması** · `/refresh`'te CSRF sırası (**M53**) · çoklu-assert kuralı ve **M36b**/**M41b**/**M40b** ayrımları · HKDF `info` bayt kodlaması (**M42b**) · `M42`'nin bileşiklikten ayrılması (**M42c**) · anahtar rotasyonunun kapsam dışı olarak adlandırılması).
  - ✅ **KAPI-4'TEN DEVREDEN İKİ MAJÖR DE KAPANDI [oturum 23]:** `M19`'un kill sinyali **tek bir teste ve istisna mesajına** pinlendi (yan ısırma adlandırıldı) · `M42c`'nin `KON` gözlem yüzeyi **beş adımda uçtan uca** yazıldı (dosya sistemi ayağı sinyali ayırt edici kılar).
  - ❌ **YAPILMAYANLAR [gizlenmiyor]:** kapı-4'ün ~28 minörünün **çoğu** hâlâ açıktır · **`GOREV-slice-3c-auth` spec'i hâlâ yoktur** ⇒ *"spec'te çözülür"* savunması bu sürümde de **kullanılamaz** · **`K4`'ün iki yanlış-pozitifi bilerek düzeltilmedi** (belgeyi ölçüme değil ölçüm aracına uydurmak, projenin *"kapı tiyatrosu"* diye adlandırdığı şeydir) · **iki `[DOĞRULANMADI]` etiketi canlıdır** (`flutter_secure_storage` Windows şifrelemesi · WebKit `__Host-`) · **sızmış-parola listesinin lisans kapısı KOŞMADI** (spec'te koşacak, geri dönüşü adlandırıldı).
  - 🔴 **YENİ — BU SÜRÜMÜN KENDİ ÜRETTİĞİ AÇIK BULGU [gizlenmiyor, kapı-6'ya devrediliyor]: GÖLGELEME.** §2-C(3)'ün koşul 2'si **halefin** `consumed_at`'ine baktığı için, saldırgan ve meşru istemci zinciri **adım adım paylaşabilir** ve tespit çarpışmaya kadar ertelenir. Ömür uzamaz, yeni token basılmaz (v1'in sonsuz zinciri hâlâ imkânsız), ama **K14-a'nın maliyeti v4/v5'in yazdığından büyüktür**. Kapı-6 bunu **çürütmekle yükümlüdür**.
  - ❌ **BU SÜRÜM DENETLENMEDİ.** Yapılan tek kontrol **öz-doğrulamadır** (kodlama · bayt/satır · numara bütünlüğü · ölçüm aracının koşumu · bayat referans taraması). **Bunlar bütünlük ölçümüdür, KAPI DEĞİLDİR.** **Kapı-6 ayrı ve temiz bir oturumda koşar ve İKİ ŞEYİ birden denetlemek ZORUNDADIR: (a) bu belgeyi, (b) ONARILMIŞ ÖLÇÜM ARACINI** — çünkü aracı onaran el (oturum 22) bu belgeyi de yazmaya başlamıştır (**K29-a'nın adlandırılmış bedeli**).
- **Tarih:** 2026-07-25 (v6 yazımı: oturum 22 başladı, **oturum 23 bitirdi**) · v5: 2026-07-25 (`docs/ADR/0003-kimlik-cekirdegi.md`, sha256 `758bd1bf…22ef6`) · v4: 2026-07-25, arşiv: `arsiv/0003-kimlik-cekirdegi-TASLAK-v4-2026-07-25.md` (sha256 `b85ce0b3…0c45d0`) · v3/v2/v1 arşivde.
- **Denetim izi:** v4'ün tam denetim raporu `KANIT/adr-0003/kapi-4-denetim-raporu.md` (190 satır); v4'ün kapanma tabloları `KANIT/adr-0003/v4-kapanma-tablolari.md`; v3'ün raporu `KANIT/adr-0003/kapi-3-denetim-raporu.md` (227 satır); v2'ninki `KANIT/adr-0003/kapi-2-denetim-raporu.md` (171 satır). Bu belgedeki her kapatma o raporlardaki bir bulguya çıpalıdır.
- **Karar verenler:** Onur (sahip) · Cowork (mimar) · bağımsız denetçi ajanlar (kapı bekliyor)
- **⚠ DİLİM ADI DEĞİŞTİ [K14-h]:** `slice-3a-auth` → **`slice-3c-auth`**. *Gerekçe:* `slice-3a` **zaten vardır** (ADR 0002 K2-I3 = sunucu materyalizasyonu + okuma API'si; `KANIT/slice-3a/` klasörü dolu) ve bu proje "aynı numara iki anlam" hatasını daha önce iki kez yedi. **Bilinen ve kabul edilen kusur:** kimlik dilimi `slice-3b`'den **önce** koşar ⇒ harf sırası kronolojiyi yalanlar; "3 ailesi = istemciyi ayaklandıran işler" anlamı korunduğu için kabul edildi. *Reddedilenler:* `slice-4-auth` · `slice-auth` (numarasız).
- **Kapsam (K11-h ile daraltıldı):** kullanıcı varlığı · parola + **girdi politikası** · token yaşam döngüsü · token doğrulama parametreleri · `ICurrentUser` sözleşmesi · sırlar + **dev bootstrap** · kimlik uçları + kaba kuvvet · **istemci token/kuyruk sözleşmesi** · **port envanteri**.
- **Kapsam DIŞI (ADR 0004'e taşındı):** owner EF global query filter + `IgnoreQueryFilters` yasağı · push-authz · pull-authz · `outbox_messages.owner_id` · SignalR hub kimliği · `clientId → principal` **ve onun zorlama kuralı (D-7)**.
- **Bağımlılık:** ADR 0001 (§C, §D, §G, §H) · ADR 0002 (K2-E3, K2-E5, K2-A4, §6/7).

> **Onur'un kilitlediği çatallar:** K8-a…K8-d · K9 · **K11-c/d/e/f/g/h** · K12-d (aynı origin) · **K13-a (K6 tavanı kaldırıldı)** · **K14-a…K14-h** · **K15-a/K15-b** · **K16-a/K16-b/K16-c** (son beşi bu sürümün çatalları — §0.2).
>
> **AÇIK ÇATAL DURUMU — v3'ÜN BEYANI DA KUSURLUYDU ve bu sürümde DÜZELTİLMİŞTİR.** v3 *"bugün açık çatal yoktur"* dedi; denetim **K14-i'nin kendi cümlesiyle** (*"bu bir Onur kilidi DEĞİLDİR ve kilit turunda gözden geçirilebilir"*) çeliştiğini bulguladı (Ma-16). **v4'te K14-i artık açık değildir: K16-b ile Onur tarafından kilitlenmiş, sayıları değişmiş ve gerekçesi yeniden yazılmıştır.** Bu belgede bugün açık çatal yoktur; **ama bu cümle bir DENETİM SONUCU DEĞİL, bir YAZAR İDDİASIDIR** — v2 ve v3'ün aynı cümlesi iki kez denetimde çürütüldüğü için burada böyle etiketlenmiştir ve üçüncü kez çürütülebilir.
>
> **⚠ BU SÜRÜMÜN OKUYUCUSUNA:** v4 üç yerde **v3'ün bir iddiasını geri çekiyor** (kararı değil, iddiayı): (1) `RemoteIpAddress`'in gerçek istemci IP'si olduğu — **ölçümle yanlışlandı** (K3-L4/K15-b); (2) NIST çizgisinin ≥10 olduğu — **kaynaktan yanlışlandı** (K3-B6/K16-a); (3) *"DB'de token'ın ham değeri hiç bulunmaz"* — **K15-a ile `[KS-4]`lik, şifreli ve adlandırılmış bir istisna kazandı** (K3-C2/C6). Üçü de §0.4'te toplu olarak listelenmiştir; **geri çekilen bir iddia, sessizce düzeltilen bir iddiadan daha ucuzdur.**

---

## 0. v4 → v5 değişim kaydı (denetim izi)

> **§0.1–§0.3 BU BELGEDEN ÇIKARILDI [K19-a].** v4'ün *"hangi bloker nerede kapandı"*
> tabloları ve *"v3'te şöyleydi"* anlatıları — **11.112 bayt**, belgenin **≈%6,5'i** (ölçüldü, oturum 22) — artık
> **`KANIT/adr-0003/v4-kapanma-tablolari.md`** dosyasındadır. Hiçbir satır silinmedi.
> *Gerekçe (kapı-4 §7/3):* ADR bir **karar** belgesidir; denetim izi KANIT'ta yaşar.
> Aynı kararla **§1-K KANONİK SAYILAR** tablosu doğdu: bir sayı belgede **bir kez**
> yazılır, gövde ona **atıf yapar, kopyalamaz** — B-1 ve B-8 bu kuralla doğamazdı.


### 0.4 — v4'ÜN GERİ ÇEKTİĞİ İDDİALAR [DÜRÜSTLÜK — kararlar değil, İDDİALAR]

| geri çekilen iddia | nerede yazılıydı | neden düştü | kararın kendisi ne oldu |
|---|---|---|---|
| *"`RemoteIpAddress` **GERÇEK** istemci IP'sidir ⇒ `UseForwardedHeaders` hiç gerekmez"* | K3-L4 (v3) | **Gerçek koşu, Onur'un makinesi:** `localhost` · `127.0.0.1` · LAN IP'sinin **üçünde de** konteyner `172.17.0.1` (köprü ağ geçidi) gördü | **K14-e DURUYOR** (K15-b). Yalnız gerekçenin bu ayağı geri çekildi; kontrol 1 artık **küresel tavan** diye adlandırılıyor |
| *"NIST çizgisi ≥10 karakterdir"* | K3-B6, §5, §6 (v3) | **NIST SP 800-63B-4 birebir:** tek faktör için `SHALL` **15** (MFA bileşeni 8) | **Politika değişti: 15** (K16-a). Karmaşıklık-yok ve ≤128 ayakları **doğruydu, duruyor** <!-- [KS-LITERAL: §0.4 geri çekilen iddia kaydı — tarihsel metin, sayı değişemez] --> |
| *"Yenileme token'ının ham değeri sunucuda hiç bulunmaz"* | K3-C2, M12 (v3) | K14-a'nın *"kayıtlı halef aynen döndürülür"* kuralı **bu iddiayla inşa edilemezdi** (B1) | **`[KS-4]`lik, şifreli, adlandırılmış istisna** (K15-a). M12 bu istisnayla **çelişmeyecek** biçimde yeniden yazıldı; yeni risk §6'ya eklendi |
| *"§3.1'in `iss`/`aud`/`RequireSignedTokens` satırları çerçevenin kendi doğrulamasıdır"* | §3.1 (v3) | `ValidateIssuer=false` **benim kodumdaki tek satırlık yapılandırmadır**, `ClockSkew` ile aynı sınıf | Muafiyet **kaldırıldı**, **M48** yazıldı (Ma-7) |
| *"`docs/ADR/` yalnız `0003`'ü içeriyor ⇒ 0001 alıntısı yapılamaz"* | kapı-3 raporu §5 | **v4 turunda ana oturumda ölçüldü:** `0001-genel-mimari.md` (14.137 bayt) ve `0002-senkron-mekanigi.md` (31.402 bayt) diskte ve **git-takipli** | **Ma-8 kapatıldı** — K-H1 birebir alıntılandı (§2-M) |
| *"`UseRateLimiter` statik dosyalardan sonra konmalıdır, çünkü **onlarca asset isteği kovayı ilk saniyede tüketir**"* | §2-J middleware sırası (v4) | **Yapısal olarak imkânsız** — üç politikanın **üçü de uç-bazlıdır** ve belgede **küresel limiter kararı YOKTUR**; `RateLimitingMiddleware` (aspnetcore 9.0) birebir: *"If this endpoint has no EnableRateLimitingAttribute & there's no global limiter, don't apply any rate limits."* ⇒ statik dosya **hiçbir kovayı tüketemez** | **Karar DEĞİŞMEDİ** (statik dosyalar hız sınırı dışındadır), **gerekçesi değişti**; `M46` gözlemlenebilir bir davranışa **yeniden çıpalandı** (K19-b) |
| *"Replay penceresi reuse-detection'ı **`[KS-4]` kadar** geciktirir"* **ve** *"meşru istemci halefi kullandığı anda saldırganın bir sonraki `/refresh`'i (d) dalına düşer"* | §2-C(3) · §6 Risk #11 · §6 Risk #16 (v4/v5) | **Belgenin KENDİ dal kuralından türetilerek yanlışlandı:** (i) koşul 2 **halefin** `consumed_at`'ine bakar ⇒ halef tazeyken (c) işlemeye devam eder, aile düşmez; (ii) tespit `[KS-4]`'e değil bir **çarpışmaya** bağlıdır ve çarpışmanın zamanını meşru istemcinin yenileme ritmi belirler ⇒ **çevrimiçi kurbanda `[KS-1]`, çevrimdışı kurbanda `[KS-2]`'ye kadar** | **K14-a DURUYOR — mekanizma değişmedi**; yalnız **maliyet muhasebesi** yeniden yazıldı (§2-C(3), §6 #11, §6 #16). **Gölgeleme kalemi kapı-6'ya AÇIK BULGU olarak devredildi** |

> **⚠ ETİKET EMEKLİLİĞİ (v2'den devralındı, hâlâ yürürlükte):** v1'in `K3-E*` · `K3-F*` · `K3-G*` · `K3-H*` etiketleri **emeklidir**; ADR 0004 aynı konuları `K4-*` ile yeniden yayımlar. Bir gelecek oturum `K3-E1` görürse **v1 arşivine** bakıyordur.

---

## 1. Bağlam

Bugüne kadar Momentum'un backend'i **kimliksiz** çalıştı. Bu iki ADR'de sessiz bırakılmadı, **adlandırıldı** — ve v1 denetimi sayımın eksik olduğunu ortaya çıkardı: borç **dört değil BEŞTİR**.

| pin | ertelenmiş gereksinim | kaynak (birebir) | nerede kapanır |
|---|---|---|---|
| **K-D5** | `ICurrentUser` impl + owner query-filter | `0001` §D: *"`ICurrentUser` portu (Application) slice-1'de arayüz olarak tanımlanır; implementasyonu + owner query-filter kimlik dilimiyle kodlanır."* | **sözleşme + impl: 0003 (§2-D)** · filtre: **0004** |
| **M-G** | push-authz | **`0002:145` (K2-E3, Push) — birebir:** *"ingest, her op için «actor bu entity'yi **yazabilir mi**» kontrolü yapmalı. Mekanizma auth diliminde; o zamana dek **deny-by-default** + `entityId` bir yetki-token'ı **DEĞİLDİR**."* | **0004** |
| **K2-E3** | pull-authz | **`0002:144` (K2-E3, Pull) — birebir:** *"`changes` yalnız actor'ın görebildiği **(owner/collaborator)** entity'lerle sınırlı"* + tombstone muafiyeti (`0002:144`'ün *"İstisna"* cümlesi, K2-C7) | **0004** |
| **M-C** | `clientId → principal` | **`0002:244` (§6 "Riskler / açık noktalar", madde 7) — birebir:** *"clientId kimlik-doğrulaması ertelenmiş […] `clientId→principal` auth-bağı + **push-authz** (M-G) auth diliminde aktive edilecek ertelenmiş gereksinimlerdir"* | **0004 (D-6 + D-7)** |
| **B4** | `outbox_messages.owner_id` doğrulanmamış | `PROJE_HAFIZA:145` AÇIK BULGU C | **0004** |

> 🔴 **v7 DÜZELTMESİ [K35 — üç alıntı-hijyeni kalemi; YENİ ALINTI KURALI BURADA İLK KEZ UYGULANDI].**
> Üçü de v6'da **kaynağı daraltıyordu** ve daraltma **işaretsizdi**:
> 1. **M-G:** alıntı *"…auth diliminde**.**"* diye **noktayla** kapatılmıştı; kaynak orada **noktalı virgül**
>    kullanıp devam ediyor. Düşen kısım süs değil, **bugünkü davranışın ta kendisiydi**: *"o zamana dek
>    **deny-by-default**"*. ⇒ 0004 gelene kadar push yolunun ne yaptığı, ADR 0003'ü okuyan bir builder'a
>    **görünmüyordu**.
> 2. **K2-E3 (pull):** *"görebildiği entity'ler"* alınmış, **`(owner/collaborator)` parantezi düşürülmüştü**
>    — yani **görünürlüğü TANIMLAYAN** kısım. Geri kondu.
> 3. **M-C:** konum **"§6/7"** yazıyordu; kalem gerçekte **§6'nın 7. maddesidir** (`0002:244`). ADR 0002'nin
>    **§7'sinin adı *"İlgili"*dir** ve `0002:249`'da başlar ⇒ *"§7"* okuması yanlış bölüme götürüyordu.
>    Ayrıca kısaltma `…` yerine artık **`[…]`** ile, kaynağın kendi cümlesi bozulmadan işaretlendi.
>
> **Bu üçü ne kör kapı ne ölü tuzak üretiyordu** ⇒ sınıf **MİNÖR**. Ama üçü birlikte, K35'in
> **MAJÖR** bulgusuyla (§2-C(4)'ün uydurulmuş alıntısı) **aynı kök nedeni** paylaşıyor: *kaynağı elde
> tutmadan alıntılamak.* **Kök neden artık yapısal olarak kapatıldı:** ADR 0002 bu turda **ilk kez açıldı**
> (K34-e) ve alıntı kuralı (**satır numarası + işaretli kısaltma**) yürürlüğe girdi.
>
> ⚠ **BU DÜZELTME KENDİ KUSURUNU DA ÜRETTİ VE YAKALADI [dürüstlük kaydı].** Bu not bloğu ilk yazıldığında
> **tablonun ORTASINA**, `M-C` ile `B4` satırlarının arasına düştü ⇒ `B4` satırı GFM'de tablodan **kopuyordu**
> — yani kapı-5'in **M31**'de ve kapı-6'nın **M56**'da saydığı **render kusuru sınıfının** ta kendisi,
> bu kez **onu kapatan turun kendi elinden**. Aynı koşumda ölçülüp düzeltildi. **Ders (K33'ün dördüncü
> turda adlandırdığı örüntünün beşinci kanıtı): bir kusur sınıfını kapatan tur, o sınıfın en olası
> üreticisidir** ⇒ v7 kapanışında **kendi yeni satırları** eski bulgu sınıflarına karşı taranacaktır.

**Bu dilim bir özellik değil, bir ŞEMA kararıdır.** Çevrimdışı-öncelikli Flutter istemcisinde dört soru Drift şemasını ve depo katmanını belirler: *"bu yerel satır kimin"* · *"token nerede duruyor"* · *"401 gelince kuyruktaki yazımlar ne oluyor"* · *"çıkışta yerel DB'ye ne oluyor"*. v1 yalnız birincisini karara bağlamıştı; v2 kalan üçünü §2-L'de kapattı; **v3 §2-L'ye bir beşinci soruyu ekledi: *"ağ yokken yerel DB hangi kimlikle açılır"*** — **v4 ise ALTINCISINI ekliyor: *"sunucu geçici olarak reddederse (`429`) istemci hangi duruma geçer"*** (B3; ODEV §4(b)-2'nin iki eşzamanlı kullanıcısı bunu demonun ortasında tetikliyordu) (bloker #10 — üç kararın birleşiminin ürettiği, hiçbirinin tek başına görünmediği bir şema sonucu).

**Ayrıca bir güvenlik yüzeyi kapanır.** Bugün `WireOp.ActorId` **istemci-beyanlıdır** ve doğrulanmış actor push yoluna hiç girmez. Auth olmadığı için sömürülemez; **auth gelince sömürülebilir hâle gelir.** Bu belge kimliği üretir, **ADR 0004 onu yetki kararına bağlar** — ikisi birlikte kapatır, tek başına hiçbiri kapatmaz.

**Neden iki belge?** K11-h'nin gerekçesi *"her belge küçük ⇒ tek turda geçme şansı yüksek"*ti. **Bu beklenti iki kez tutmadı** (v2 = v1 × 1,8 ve 15 bloker taşıdı) ve K13-a ile **tavan kaldırıldı**. Bölünme kararı yine de duruyor, ama artık gerekçesi *"tek turda geçsin"* değil, **konu sınırının gerçekten orada olmasıdır**: v2 denetiminde *"0003/0004 bölünme sınırı sağlam — sınırda kararsız kalmış kimlik-çekirdeği maddesi bulunamadı"* diye ölçüldü.  <!-- [KS-LITERAL: '15 bloker' — kanonik sayı değil, tur sayısı] -->

---
## 1-K. KANONİK SAYILAR [K19-a — PAZARLIKSIZ]

> **KURAL [PAZARLIKSIZ]:** bu belgede geçen her tavan, ömür, uzunluk ve boyut
> **yalnızca bu tabloda** yazılır. Gövde metni, mutant tablosu ve §3.1 bu değerlere
> **`[KS-n]` etiketiyle atıf yapar; sayıyı KOPYALAMAZ.**
>
> **Neden [ölçülmüş gerekçe, kapı-4 §7/2]:** v4'te kontrol 1'in tavanı **7 ayrı yerde**,
> `60 sn` **27 yerde**, `5 dk` **19 yerde** tekrarlanıyordu. Kapı-4'ün dokuz blokerinden
> **ikisi (B-1 ve B-8)** doğrudan bunun sonucudur: *"kardeş kalem güncellendi, kendisi
> unutuldu"*. Tek kaynak varken bu sınıf kusur **doğamaz** — güncelleme tek satırdadır.
>
> **Kapısı:** bu kural bir belge kuralıdır, kodda karşılığı yoktur; **`araclar/adr-kapi-taramasi.py`**
> `K4` kontrolü ihlali **mekanik olarak** bulur (araç altın kümede kendini kanıtlar: bilerek
> kopyalanmış bir sayıyı bulamayan betik kullanılamaz — `KANIT/adr-0003/olcum-araci-altin-kume-kanit.txt`).

### 1-K.1 — Token ve oturum ömürleri

| id | ad | değer | sahibi | kapısı |
|---|---|---|---|---|
| **KS-1** | Erişim token'ı (JWT) ömrü | **15 dk** | K3-C1 | M16 · M17 |
| **KS-2** | Yenileme ailesinin **mutlak** ömrü | **30 gün** | K3-C2 | M18 |
| **KS-3** | Web çerezinin `Max-Age`'i | **ailenin KALAN `expires_at`'i** (üst sınır: KS-2 — ayrı sayı DEĞİL) | K3-L2 | **M36b** |
| **KS-4** | Replay-idempotency penceresi | **10 dk** | **K14-a** *(v4 bunu üç yerde yanlışlıkla K16-b'ye atfediyordu — düzeltildi)* | M1 · M29 · M30 |
| **KS-5** | `successor_secret_enc`'in yaşama süresi | **KS-4 ile aynı** (`consumed_at` + KS-4) | K15-a | M40 |
| **KS-6** | `successor_secret_enc` süpürme **periyodu** | **60 sn** | K3-C6(5) | M40 (ikinci ayak) |
| **KS-7** | Zarafet penceresi | **YOKTUR (0 sn)** | K3-C5 | M27 |
| **KS-8** | `ClockSkew` | **`TimeSpan.Zero`** — varsayılan **300 sn** açıkça ezilir | K3-C7 | M17 |
| **KS-9** | Rate limiter atıl partition temizleme | **10 sn** | K3-J5 | *(kapısız — §3.1)* |

> **KS-4 × KS-6 aritmetiği (§6 Risk #13'ün dayanağı):** şifreli halef satırı en kötü
> **`[KS-4]` + `[KS-6]`** kadar yaşar (pencere dolar, süpürücü bir sonraki turda siler).
> Bu, süreç ayakta olduğu sürece geçerlidir; süreç ölürse satır bir sonraki açılışın
> ilk süpürme turuna kadar kalır — **bu cümle v4'te eksikti, kapı-4 minörüydü.**
>
> ⚠ **v7 DÜZELTMESİ [kapı-6 majör #1]:** v6 burada **`120 sn`** yazıyordu. **Bu literal BAYATTI:**
> K28-a `[KS-4]`'ü **60 sn → 10 dk** yaptığında toplam `120 sn` olmaktan çıktı, ama düzeltme
> §2-C(5)'e uygulanıp **kaynağına — yani bu tabloya — uygulanmamıştı.** Belge kusuru satır 365'te
> **adıyla geri çekmiş** (*"K28-a `[KS-4]`'ü 60 sn'den 10 dk'ya çıkarınca bu literal SESSİZCE
> YANLIŞLANDI"*) ve **kaynağı düzeltmemişti** — yani geri çekme bildirimi ile metin çelişiyordu.
> ⇒ Sayı artık **hiç yazılmıyor**, yalnız sembolik toplam duruyor (K30 kanonik-sayı kuralı).
> **Ders [kapı-6'nın adlandırdığı, v7'nin uyguladığı]:** araç bunu **yapısal olarak göremezdi**
> (`K4` §1-K bölgesini taramıyor + kaynak satır 412'nin sessiz kaçış filtresi); bir kanonik sayı
> değiştiğinde ona **atıf yapmayan ama ondan TÜREYEN** her satır **elle** taranmalıdır.
> *(Kapı-6 red-team'i bunu MAJÖRE indirdi: hiçbir mutant bu literale çıpalı değildi ⇒ kör kapı
> da ölü tuzak da doğmadı. v7 yine de düzeltiyor — bu bir portfolyo belgesidir.)*

### 1-K.2 — Kaba kuvvet tavanları [K16-b]

| id | ad | değer | sahibi | kapısı |
|---|---|---|---|---|
| **KS-10** | Kontrol 1 — `/login` + `/register` | **30 istek / 5 dk** | K16-b · K3-J2(1) | M11 · M23 · M46 |
| **KS-11** | Kontrol 1 — `/refresh` | **120 istek / 5 dk** | K16-b · K3-J2(1) | *(kapısız — §3.1)* |
| **KS-12** | Kontrol 1 — `/logout` + `/logout-all` | **60 istek / 5 dk** | K16-b · K3-J6 | *(kapısız — §3.1)* |
| **KS-13** | Kontrol 2 — normalize e-posta penceresi | **5 deneme / 15 dk** | K3-J2(2) | M41 (birinci/ikinci ayak) |
| **KS-14** | Kontrol 3 — eşzamanlılık izni | **`Environment.ProcessorCount`** | K3-J2(3) | M22 |
| **KS-15** | Kontrol 3 — kuyruk sınırı | **2 × KS-14** | K3-J2(3) | M22 |
| **KS-16** | Kontrol 3'ün fiilen reddettiği eşik | **≥ 3 × KS-14 + 1** eşzamanlı istek | K3-J2(3) | M22 |

> **Kontrol 1 KÜRESELDİR [K15-b, ölçüldü]:** `RemoteIpAddress` bu dağıtımda köprü ağ
> geçididir; `TestHost` altında **`null`**'dır. ⇒ KS-10/11/12 birer **kullanıcı ayrımı
> değil, servis tavanıdır** ve testte **tek partition**'a düşer. §3.2(9) izolasyonu
> bunun için pinler. **Argon2'yi koruyan asıl kontrol KS-14/15'tir, KS-10 değil.**

### 1-K.3 — Girdi politikası [K16-a · K3-B6]

| id | ad | değer | sahibi | kapısı |
|---|---|---|---|---|
| **KS-17** | Parola asgari uzunluk | **15 karakter** (NIST SP 800-63B-4 `SHALL`) | K16-a | M31 ayak 1-2 |
| **KS-18** | Parola azami uzunluk | **128 karakter** | K3-B6 | M31 ayak 3 |
| **KS-19** | E-posta azami uzunluk | **254 karakter** — RFC 5321'den **TÜRETİLMİŞTİR**, RFC'nin yazdığı sayı DEĞİLDİR (aşağıdaki nota bakınız) | K3-B6 | **M52** ayak 1 |
| **KS-31** | Sızmış-parola kara listesi boyutu | **10.000 kayıt** (gömülü, en yaygın parolalar; **kaynağı, türetme tarifi ve beklenen `sha256` K3-B6(2)'de PİNLİDİR**) | **K28-c** · **K37-b** | **M56** |

> 🔴 **v7 DÜZELTMESİ — `[KS-19]`'un ATFI YANLIŞTI [kapı-6 §7(3) aday sapması; v7'de BİRİNCİL KAYNAKTAN ÖLÇÜLDÜ].**
> v6 birebir *"**254 karakter** (RFC 5321 **yol sınırı**)"* yazıyordu. **Ölçüm (RFC 5321, `rfc-editor.org`, 26 Tem 2026):**
> - **§4.5.3.1.3 Path — birebir:** *"The maximum total length of a reverse-path or forward-path is **256** characters (including the brackets)."*
> - §4.5.3.1.1 Local-part: **64** karakter · §4.5.3.1.2 Domain: **255** karakter.
>
> ⇒ **RFC'nin YOL SINIRI 256'dır, 254 değil.** `254` = `256 − 2` (yolu saran `<` ve `>` köşeli ayraçları
> **RFC'nin kendi cümlesine göre** 256'ya dâhildir) ⇒ **254, "mailbox"un azami uzunluğudur ve TÜRETİLMİŞ bir
> değerdir.** *(Bağlayıcı olan budur: `64 + 1 + 255 = 320 > 254`, yani local-part ve domain tavanları tek
> başına 254'ü zorlamaz.)*
> **DEĞER DOĞRUDUR, ATIF YANLIŞTI** — ve düzeltilen şey atıftır: `[KS-19]` artık *"RFC 5321'in yol sınırı"*
> diye sunulmuyor, **RFC'den türetilmiş** olduğu yazılıyor. **M52 ayak 1 etkilenmez** (assert `254`'ü ölçüyor
> ve `254` doğru tavandır) ⇒ ne kör kapı ne ölü tuzak doğdu. **Sınıf: MAJÖR (atıf hatası), BLOKER DEĞİL.**
>
> ⚠ **BU, BELGENİN İLK ÖLÇÜLMÜŞ BİRİNCİL-KAYNAK ATIF HATASIDIR — dürüstçe kayda geçiyor.** Kapı-4 raporu
> *"23 birincil-kaynak atfının hiçbiri yanlış çıkmadı"* diye kapanmıştı ve kapı-6 bu kalemi **ölçemedi**,
> yalnız *"aday sapma, `[DOĞRULANMADI]`"* diye adlandırdı. v7 onu ölçtü ve **sapma gerçek çıktı.**
> ⇒ **Kalan ~30 birincil-kaynak atfı (NIST ×13, RFC 9700/9562/6265/4648, aspnetcore ×10) HÂLÂ
> BAĞIMSIZ DOĞRULANMAMIŞTIR** ve bu kalem, o kümede **başka sapmalar olabileceğinin ölçülmüş kanıtıdır.**
> **KAPI-7'YE PAZARLIKSIZ GÖREV: o atıfların tamamı birincil kaynaktan açılmalıdır.**

### 1-K.4 — Kripto boyutları

| id | ad | değer | sahibi | kapısı |
|---|---|---|---|---|
| **KS-20** | Kök anahtar (`Momentum:MasterKey`) asgari | **32 bayt** (çözülmüş hâli) | K3-I2 | M8a · M8b |
| **KS-21** | Yenileme token'ı entropisi | **32 ham bayt** = 256 bit CSPRNG | K3-C2 | M12 |
| **KS-22** | Yenileme token'ının tel biçimi uzunluğu | **43 karakter** (`Base64Url`, dolgusuz) | K3-C2 | M12 |
| **KS-23** | Argon2id parametreleri | **`m = 19456 KiB · t = 2 · p = 1`**, salt **16 bayt**, çıktı **32 bayt** | K3-B1 | M5 · M32 |
| **KS-24** | Argon2id ölçülen maliyeti | **270 ms · 19 MiB / istek** *(Onur'un makinesi, 25 Tem 2026 — gerçek koşu)* | K3-B1 | *(ölçüm, kapı değil — §3.1)* |
| **KS-25** | AES-256-GCM nonce uzunluğu | **12 bayt**, **her şifrelemede taze CSPRNG** [K18-b] | K3-I5 | **M50** |
| **KS-26** | `successor_secret_enc` blok düzeni | **12 + 32 + 16 = 60 bayt** (`nonce ‖ ciphertext ‖ tag`) | K15-a · K3-I5 | M40 · **M50** |
| **KS-27** | AES-256-GCM AAD | **`family_id ‖ token_hash`** (boyut değil, **bağ**) [K18-b] | K3-I5 | **M51** |
| **KS-28** | CSRF `nonce` entropisi | **32 ham bayt** CSPRNG (`Base64Url`, dolgusuz) | K3-L3(3) | M35 |
| **KS-29** | CSRF çerezinin `Max-Age`'i | **ailenin KALAN `expires_at`'i** (üst sınır: KS-2 — ayrı sayı DEĞİL) | K3-L3(3) | **M36b** |
| **KS-30** | HKDF alt anahtarlarının uzunluğu (`K_jwt` · `K_csrf` · `K_rt`) | **32 bayt** (her biri) | K3-I4 | M42 · M42b |

> 🔴 **v7 NOTU [kapı-6 majör #9 kapanıyor] — `[KS-3]` · `[KS-5]` · `[KS-7]`'NİN ATIF SAYISI ÖLÇÜLDÜ.**
> Kapı-6 ölçtü: **`KS-3` belgede SIFIR kez atıf alıyordu** ve değeri gövdede **kopyalanmıştı**; kardeşleri `KS-5` ve `KS-7` de
> yalnız kendi tanım satırlarında geçiyordu. Araç bu üçünü *"türetilmiş değer"* / *"tek haneli literal"* diye **kapsam dışı**
> bırakıp *"ELLE kontrol edilmeli"* diyor — **ve o elle kontrol hiç yapılmamıştı.** v7'de yapıldı:
> · **`[KS-3]`** artık §2-L'nin çerez tablosunda **atıfla** kullanılıyor (değer kopyası kaldırıldı) ⇒ ölü kayıt **değil**.
> · **`[KS-5]` ve `[KS-7]` HÂLÂ SIFIR ATIF ALIYOR ve bu bir SINIRDIR, gizlenmiyor:** ikisi de **türetilmiş/ikincil** kayıtlardır
>   ve gövdede kendilerine atıf yapılacak bir cümle **yoktur**; kalemler `§1-K`'da **envanter bütünlüğü** için durur.
>   **Kapı-7'ye açık soru:** atıf almayan bir kanonik kayıt `§1-K`'da kalmalı mı, yoksa **kaldırılıp** ilgili kararın içine mi
>   yazılmalı? Bu bir **tasarım tercihidir** ve bu belge onu tek taraflı kapatmıyor.

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
Parametreler **OWASP ikinci yapılandırması**: **`[KS-23]`**.
**Kapı kanıtı (Onur'un makinesinde, gerçek koşu, 25 Tem 2026):** lisans **MIT** · **CVE 0** · net9.0 build **0 uyarı 0 hata** · fiilen çalıştı: 32 baytlık hash, **270 ms**.  <!-- [KS-LITERAL: gerçek koşu ölçüm kaydı (25 Tem 2026) — ölçüm sonucu yeniden yazılamaz] -->
**⚠ ADLANDIRILMIŞ RİSK, GİZLENMİYOR:** paket **~25 ay hareketsiz** (`pushed_at = 2024-06-18`, 20 açık issue, 3 açık PR, GitHub'da release yok, arşivlenmemiş, 6.9M indirme). Bir CVE düşerse yamayı gönderecek bakımcı olmayabilir. **Telafi kapatma değil, İZOLASYONDUR → K3-B2/B3.**

**K3-B1(2) — SALT: HER PAROLA İÇİN TAZE CSPRNG, `[KS-23]`'ÜN SALT UZUNLUĞUNDA. [K28-d(a) — kapı-5'in 5. aday blokeri kapanır] [PAZARLIKSIZ]**
**Kırılan yer (kapı-5 ölçtü):** belge `[KS-23]`'te salt **uzunluğunu** yazıyordu ama salt'ın **nereden geldiğini** hiçbir yerde yazmıyordu — `grep "salt"` §3'ün tamamında **sıfır** eşleşme veriyordu. ⇒ **Global sabit bir salt kullanan bir implementasyon M5 · M6 · M6b · M7 · M31 · M32 · M34'ün HEPSİNİ geçerdi** ve sonuç, gökkuşağı tablosuna açık bir parola deposu olurdu. Bu, `[KS-25]` nonce'u için **M50 ile zaten kapılanmış** özelliğin parola tarafındaki birebir kardeşidir ⇒ emsal belgenin kendi içindedir.
**Kural:** her `Hash(password)` çağrısında salt **yeniden** üretilir: `RandomNumberGenerator.Fill(salt)`, uzunluk `[KS-23]`'ün salt alanı kadar. Sabit salt, kullanıcı kimliğinden/e-postadan **türetilmiş** salt, sayaç ya da zaman damgası **YASAKTIR** (türetilmiş salt, aynı parolayı kullanan iki kullanıcıyı ayırır ama **aynı kullanıcının parola değişimlerini ayırmaz** ve önceden hesaplanabilir).
**Kapı: M54** (`B` — saf birim testi, DB gerektirmez): mutasyon salt'ı sabitler; kill sinyali *"aynı parola iki kez hash'lendiğinde iki PHC dizesi **FARKLIDIR** ve salt alanı `[KS-23]`'ün salt uzunluğundadır"* **FAIL**.
*Reddedilenler [adlandırılmış]:* **§3.1'e kapısız beyan** (sıfır iş, ama *"en kritik iki kripto özelliğinden biri kapısız"* eleştirisi doğar ve kalem **kırmızı çizgi sınıfıdır** — parola deposu) · **salt'ı PHC dizesinden okumakla yetinmek** (K3-B7 ayrıştırmayı zaten zorluyor, ama ayrıştırma salt'ın **taze üretildiğini** ölçmez: sabit salt da PHC'ye yazılır ve ayrıştırılır).

**K3-B2 — `IPasswordHasher` portu [K9].** Arayüz **Application**'da, implementasyon **Infrastructure**'da. `Konscious.*` tipi Domain/Application/Api katmanlarının **hiçbirinde görünmez** — **NetArchTest kuralı** (K-A1 ailesine ek). Paket değişimi tek sınıfı etkiler. **Kuralın mutantı: M32** (0001 K-H1: *"Her kural commit'li negatif/mutant testle ısırdığını kanıtlar"* — v2 bunu ihlal ediyordu, bloker #15).

**K3-B3 — Hash string'i kendi kendini tarif eder [K9].** Depolanan format PHC benzeri:
`$argon2id$v=19$m=19456,t=2,p=1$<b64 salt>$<b64 hash>`  <!-- [KS-LITERAL: PHC STRING'İN BİÇİM ÖRNEĞİ — bu satır bir veri biçimidir; parametreler `[KS-23]` ile AYNI olmak ZORUNDADIR ve K3-B3 parametre değişimini PLANLI bir olay olarak yazdığı için biçim örneği de o gün güncellenir. Atıfla yazılamaz: örnek, ayrıştırıcının beklediği baytları gösterir. v7/oturum-26 — kapı-6 majör #5] -->
Algoritma kimliği ve parametreler **satırın içindedir**. Sonucu: (a) PBKDF2'ye ya da yeni parametreye geçiş **migration değil**, tek sınıf + doğrulama yolunda dallanmadır; (b) **başarılı girişte, depolanan parametreler güncel politikadan farklıysa parola sessizce yeniden hash'lenir** (rehash-on-login).

**K3-B4 — Doğrulama sabit-zamanlı.** `CryptographicOperations.FixedTimeEquals`; `SequenceEqual` **banned-API** (derleme kırılır). *(Not: `byte[] ==` referans karşılaştırmasıdır ve BannedApiAnalyzers ile ifade edilemez — bu ayak bir davranış testine devredildi, bkz. M6.)*

**K3-B5 — Kullanıcı-sayımı ve zamanlama sızıntısı: `/login` ve `/refresh` yolunda PAZARLIKSIZ, `/register`'da ADLANDIRILMIŞ SAPMA.**
`/login`: bilinmeyen e-posta ile yanlış parola **aynı** yanıtı döndürür (`401`, tek tip ProblemDetails) **ve aynı işi yapar** — kullanıcı bulunamazsa da bir **sahte (dummy) Argon2id doğrulaması** koşulur (sabit, uygulama açılışında bir kez üretilmiş geçerli formatlı bir hash'e karşı). Aksi hâlde yanıt süresi (≈270 ms vs ≈1 ms) hesabın varlığını ele verir.  <!-- [KS-LITERAL: gerçek koşu ölçüm kaydı] -->
**⚠ Sahte hash'in bir MALİYETİ vardır ve bu maliyet bir DoS çarpanıdır** — telafisi K3-J2/J3/J4'tür.
**"Aynı yanıt" ayağının kapısı [D3 majörü kapatılıyor]:** *"bilinmeyen e-posta ile yanlış parolanın yanıt gövdesi ve durum kodu **`traceId` alanı hariç bayt bayt aynıdır**"* testi — **M37**.

> **🔴 v3'ÜN "BAYT BAYT AYNI" İDDİASI YAPISAL OLARAK İMKÂNSIZDI — DÜZELTİLİYOR [Ma-4].**
> **ÖLÇÜM (dotnet/aspnetcore `release/9.0`, `DefaultProblemDetailsWriter.cs`):** `var traceId = Activity.Current?.Id ?? httpContext.TraceIdentifier; context.ProblemDetails.Extensions["traceId"] = traceId;` — **koşulsuz.** ⇒ iki ayrı isteğin gövdesi **hiçbir zaman** bayt bayt aynı olamaz; M37 baseline'da **kırmızı doğardı = ölü tuzak.**
> **Karar (iki ayak birlikte):** (1) sinyal *"`traceId` alanı hariç"* diye **pinlenir** — test gövdeyi JSON olarak ayrıştırır, `extensions.traceId` alanını **düşürür**, kalanı karşılaştırır; (2) `traceId` **korelasyon için tutulur** (K-G3'ün correlation-id kararı) — kaldırmak bir gözlemlenebilirlik kaybıdır ve kullanıcı-sayımı sızıntısı **değildir** (değeri hesaptan bağımsızdır).

**K3-B6 — GİRDİ POLİTİKASI: NIST SP 800-63B-4 ÇİZGİSİ, ASGARİ **`[KS-17]`**. [K16-a — bloker #11 kapanır, Ma-9 düzeltilir]**
v2 bunu ne karara bağlamış ne kapsam dışı ilan etmişti ⇒ **gizlenmiş sınır**. Bugün `/register` parolası `"a"` olabiliyordu ve Argon2'ye 1 MB'lık bir parola gönderilebiliyordu.

> **🔴 v3'ÜN NIST ATFI YANLIŞTI — DÜZELTİLİYOR [Ma-9, K16-a].**
> **NIST SP 800-63B-4 (Final) birebir:** *"Verifiers and CSPs **SHALL** require passwords that are used as a **single-factor** authentication mechanism to be a minimum of **15 characters** in length"* (çok faktörlü bir bileşen olarak kullanıldığında asgari 8). Momentum'da parola **tek faktördür** (2FA K3-K3 ile kapsam dışı) ⇒ uygulanan çizgi **15'tir.** v3 *"NIST çizgisi ≥10"* diyordu; **atıf yanlıştı ve belgenin kendi cümlesiyle *"güncel literatürü bilen değerlendiricide eksi sinyal"* üretiyordu.**  <!-- [KS-LITERAL: NIST SP 800-63B-4 BİREBİR alıntı — alıntı değiştirilemez] -->
> **Bedeli adlandırılır ve TELAFİ EDİLİR:** `[KS-17]`, demo sırasında elle yazmak için uzundur ⇒ **teslim paketi bir demo hesabı seed'ler** (`demo@momentum.local` + README'de açıkça yazılı 15+ karakterlik parola) ve giriş ekranı bu değeri **ön-doldurmaz** (ön-doldurma bir güvenlik alışkanlığı bozukluğudur; README yeterlidir).

| kural | değer | gerekçe |
|---|---|---|
| Parola asgari uzunluk | **`[KS-17]`** | NIST SP 800-63B-4'ün tek faktör için `SHALL` çizgisi (yukarıda birebir). `123456` parolasına karşı Argon2id'nin **`[KS-23]`** yatırımı hiçbir şey satın almaz — **uzunluk, KDF'den önce gelir.** |
| Parola **karmaşıklık kuralı** | **YOKTUR — bilinçli** | NIST SP 800-63B-4 birebir *"**SHALL NOT** impose other composition rules … for passwords"*; OWASP da önermez: kullanıcıyı tahmin edilebilir kalıplara (`Parola1!`) iter. **Bu bir eksiklik değil, adlandırılmış bir tercihtir.** |
| Parola azami uzunluk | **`[KS-18]`** | **Argon2 DoS tavanı.** Sınırsız girdi, hash maliyetini saldırganın seçmesine izin verir. NIST-4'ün *"**SHOULD** permit … at least 64"* tavsiyesinin **üstündedir** ⇒ sapma değil. |
| Parola **kesme/kırpma** | **YOKTUR** | Parola `Trim()`'lenmez ve kesilmez; **tek dönüşüm NFC normalizasyonudur** (NIST-4: Unicode parolalar için normalizasyon önerilir). Boşluk anlamlıdır (parola cümleleri). |
| **Sızmış/yaygın parola kara listesi** | **VARDIR — gömülü, `[KS-31]`** | **NIST SP 800-63B-4'ün İKİNCİ `SHALL`'ı** (aşağıda birebir). v5 ilk `SHALL`'ı (`[KS-17]`) *"NIST çizgisi"* diye savunurken bunu **ne karara bağlamış ne kapsam dışı ilan etmişti** ⇒ **adlandırılmamış sapma** (K28-c). ⚠ **Marjinal değeri v7'de ÖLÇÜLDÜ ve KÜÇÜKTÜR:** listenin **`[KS-31]`** kaydının yalnız **9'u** `[KS-17]`'yi sağlıyor, kalanı **uzunluk kontrolünde zaten reddediliyor** ⇒ kalem bir **savunma derinliğidir**, birincil koruma değildir. Beyan: **§6 md. 13** (K37-d). |
| E-posta azami uzunluk | **`[KS-19]`** | RFC 5321'den **TÜRETİLMİŞ** mailbox tavanı (`256 − 2`; RFC'nin yazdığı **yol** sınırı 256'dır — birebir ölçüm §1-K.3'ün notunda). <!-- v7/oturum-26: bu hücre v7'nin ilk dalgasında BAYAT kalmıştı ("RFC 5321 yol sınırı") — düzeltme kaynağa uygulanmış, KOPYASINA uygulanmamıştı; majör #1 ve #3 ile AYNI SINIF --> Ayrıca `email_normalized` üzerindeki btree index'in anahtar boyutu sınırına çarpıp `500` üretmesini önler — aksi hâlde K3-B5'in *"tek tip ProblemDetails"* garantisi kırılırdı. |
| E-posta formatı | **doğrulanır, doğrulayıcı PİNLİDİR** | K3-A2'nin sırasında: **`Trim()`'den SONRA, NFC'den ÖNCE.** Başarısızsa `400` (tek tip ProblemDetails). |

**E-POSTA DOĞRULAYICISI PİNLENİR [Ma-5'in ikinci yarısı — v3 "doğrulanır" deyip bırakmıştı].** Kütüphane varsayılanına **güvenilmez** (`[EmailAddress]` özniteliği fiilen *"içinde `@` var mı"* kadar gevşektir; `MailAddress` ise `"Ad Soyad <a@x.com>"` gösterim biçimini **kabul eder** ⇒ kimlik anahtarı olarak kullanılamaz). Kural kümesi **açıkça** yazılır ve hepsi birden sağlanmalıdır:
1. `System.Net.Mail.MailAddress.TryCreate(value, out var addr)` **başarılı**, **ve** `addr.Address == value` (gösterim-adlı biçim **reddedilir**),
2. tam olarak **bir** `@`, yerel kısım ≥1 karakter, alan kısmında **en az bir** `.` ve alan kısmı `.` ile başlamaz/bitmez,
3. toplam uzunluk **≤ `[KS-19]`**,
4. hiçbir boşluk ya da kontrol karakteri **içermez** (baştaki/sondaki boşluk 1. adımda zaten `Trim()`'lenmiştir).

**Kapılar: M31** (parola, ÜÇ ayak: `[KS-17]`'den bir eksik → `400` · tam `[KS-17]` → `201` · `[KS-18]`'den bir fazla → `400` **ve Argon2 KOŞMAZ**) **ve M52** (e-posta, ÜÇ ayak: tam `[KS-19]` → `201` · `[KS-19]`'dan bir fazla → `400` (`500` DEĞİL) · gösterim-adlı e-posta → `400`). **[B-6]** v4 dört ayağı **tek** M31'e yığmıştı ve dördüncüsü (e-posta) **parola mutasyonuna duyarsızdı** = sahte kapı. *Reddedilenler:* kapsam dışı ilan etmek (azami uzunluk yoksa Argon2 DoS yüzeyi açık kalır) · klasik karmaşıklık kuralları (güncel literatürü bilen değerlendiricide eksi sinyal) · **10'da kalıp adlandırılmış sapma yazmak** (doktrine uygun olurdu ama denetçi *"neden sapıyorsun"*u yeniden sorar; NIST'e uymanın bedeli burada yalnız bir README satırıdır) · **12 karakter** (hiçbir standartta karşılığı yok ⇒ keyfi).  <!-- [KS-LITERAL: REDDEDİLEN alternatiflerin tarihsel kaydı — bu sayılar yürürlükteki politikanın değil, ADLANDIRILARAK REDDEDİLEN seçeneklerin sayılarıdır; `[KS-17]`'ye atıfla yazılamazlar] -->

**K3-B6(2) — SIZMIŞ/YAYGIN PAROLA KARA LİSTESİ: GÖMÜLÜ, `[KS-31]`. [K28-c — adlandırılmamış sapma kapanır]**
**Kırılan yer (kapı-5 ölçtü):** `grep "blocklist|pwned|sızdırılmış"` ⇒ **0**. Belge `[KS-17]`'yi *"NIST SP 800-63B-4 `SHALL`"* diye gerekçelendirirken **aynı standardın ikinci `SHALL`'ını atlıyordu**; bu, doktrinin *"beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez"* kuralının ihlaliydi — sapma **gizliydi**, çünkü belge aynı standardı **kendi lehine** alıntılıyordu.
**Kural:** en yaygın **`[KS-31]`** parola repoya **gömülür** ve **kayıt ile parola değiştirme yollarında** kontrol edilir; listedeki bir parola `400` alır (tek tip ProblemDetails, K3-B5). Karşılaştırma parolanın **NFC normalize edilmiş** hâli üzerinde ve **ordinal** yapılır (K3-A2'nin kültür-duyarlı dönüşüm yasağı burada da geçerlidir). Liste **bellekte bir `FrozenSet<string>`** olarak tutulur ⇒ istek başına maliyet sabittir ve **Argon2'den ÖNCE** koşar (girdi doğrulama katmanı; K3-J3'ün bağlayıcı sırasını değiştirmez).
**🔴 v7 DÜZELTMESİ [B6-1 — BLOKER kapanıyor]. KAYNAK ARTIK PİNLİ VE KIRMIZI ÇİZGİ #3 KAPISI KOŞTU.**
v6 birebir *"Bu belge belirli bir kaynak PİNLEMEZ"* + *"[ÖLÇÜLMEDİ — kapı `GOREV-slice-3c-auth` spec'inde koşar]"* diyordu. **K34-b bunu reddetti** (kapı altı turdur koşmuyordu) ve **K37-b/K37-c ile kaynak kilitlendi; kapı 26 Tem 2026'da KOŞTU.** Ham çıktı: `KANIT/adr-0003/v7-b6-1-kara-liste-kaynagi-ve-kapisi.md`.

1. **KAYNAK [PİNLİ]:** `zxcvbn` **4.5.0** (PyPI · `sha256 2b6eed62…c66bd5ff`) paketinin frekans sıralı `FREQUENCY_LISTS['passwords']` listesi (30.000 kayıt).
2. **TÜRETME TARİFİ [PİNLİ, deterministik]:** listenin **ilk `[KS-31]` kaydı**, **sırası korunarak** · UTF-8, **BOM yok**, satır sonu **LF**, son kayıttan sonra **bir LF** ⇒ **78.880 bayt · `[KS-31]` satır · `sha256 839f86a5e388b0fe1ca13ec6c337975c9daf384e110effb70279b03caddd1462`.**
3. **LİSANS KAPISI — GEÇTİ [ÖLÇÜLDÜ 26 Tem 2026]:** `METADATA` birebir `License: MIT` **ve** `Classifier: License :: OSI Approved :: MIT License`; `LICENSE.txt` birebir *"MIT License / Copyright (c) 2016 Daniel Wolf"* (`sha256 5ac25259…d9869792`). **MIT, izinli OSI ailesindedir** (MIT/Apache-2.0/BSD-3-Clause) ⇒ kırmızı çizgi #3 sağlanır. **Yükümlülük:** lisans metni + atıf, veri dosyasının **yanında** repoya girer (MIT'in *"copyright notice … shall be included"* şartı) ve `dependencies.md`'ye **satır olarak** girer.
4. **CVE KAPISI — GEÇTİ [ÖLÇÜLDÜ]:** `pip-audit 2.10.1` · `zxcvbn==4.5.0` ⇒ *"No known vulnerabilities found"* · `EXIT=0`. **İki sınır BEYAN EDİLİR:** (a) bu bir **anlık görüntüdür** (OSV/PyPI danışma veritabanı, 26 Tem 2026), süregelen garanti değildir; (b) paket **çalışma zamanı bağımlılığı DEĞİLDİR** — yalnız **bir kez** veri türetir, üretime giren şey `.txt` bir **veri dosyasıdır** ⇒ çalışan sistemin CVE yüzeyi bu kalemden **etkilenmez**. Kapı yine de koştu, çünkü türetme aracı da bir bağımlılıktır.
5. **🔴 DOSYA BUGÜN REPODA YOKTUR — BEYAN EDİLMİŞ SINIR [K22-a sınıfından bilinçli kaçınma]:** bu ADR **var olmayan bir artefakta çıpalanmaz**. Pinlenen şey **tarif + beklenen `sha256`**'dır; **üretim ve pin doğrulaması `GOREV-slice-3c-auth` build'inde koşar** ve `sha256` **testte assert edilir**. *Pin, listenin kaymasını **ÖNLEMEZ**; **YAKALAR** — bu bir güvence değil, bir kapıdır.*
6. **GERİ DÖNÜŞ [adlandırılmış, şimdiden onaylı]:** pin ya da lisans ileride düşerse liste izinli lisanslı başka bir kaynaktan **kendi üretilmiş** alt kümeye indirilir ya da `[KS-31]` küçültülür; **kaleme tamamen vazgeçilmez.**

**Kapı: M56** (`B`): mutasyon kontrolü kaldırır. **🔴 KILL SİNYALİ v7'DE YENİDEN YAZILDI — v6'nın probu KÖR KAPIYDI [B6-1]:** v6 *"kara listedeki bir parola (`123456`) `400` alır"* diyordu; **`123456` altı karakterdir** ⇒ `[KS-17]` kuralı onu **mutasyondan bağımsız olarak** reddediyordu ⇒ mutant öldürülmüş görünüyordu, kapı **hiçbir şey ölçmüyordu** *(v6 bu çelişkiyi kendi satırında yazmış ama sonucunu çıkarmamıştı)*. **Yeni kill sinyali, İKİ AYAK, ikisi de ZORUNLU:**
- **(a) POZİTİF:** `mailcreated5240` ile `/register` ⇒ **`400`**. Bu parola **tam `[KS-17]` uzunluğundadır** (⇒ uzunluk kontrolünden **geçer**, oradan `400` alamaz) **ve** listenin **1516.** kaydıdır (**ÖLÇÜLDÜ**, KANIT §4[4]) ⇒ `400` **yalnız kara-liste kontrolünden** gelebilir.
- **(b) NEGATİF:** `MomentumKapiTesti2026` (`[KS-17]`'nin **üstünde**, 30.000'lik kaynağın **hiçbir yerinde YOK** — ÖLÇÜLDÜ) ile `/register` ⇒ **`201`**. Bu ayak olmadan *"her şeyi reddet"* mutasyonu da testi geçerdi.

> **Prob niçin `mailcreated5240` [K37-c]:** ≥`[KS-17]` uzunluktaki kayıtlar listenin **yalnız 9 tanesidir** ve rank'leri **1516 · 2174 · 6236 · 6766 · 8341 · 8512 · 8609 · 9980 · 9990**'dır. `1516` bunların **en derinidir** ⇒ liste ileride yeniden üretilse ya da kısaltılsa bile probun **sessizce ölme** (ölü tuzak) olasılığı en düşüktür; kenardaki bir kayıt (ör. rank 8609) seçilseydi kısaltmada sessizce düşerdi. **Bu, `sha256` pininin neden ZORUNLU olduğunun da gerekçesidir.**
*Gerekçe (K28-c):* **ağ yok, dış bağımlılık yok, çevrimdışı vitrinle çelişmez, DETERMİNİSTİKTİR ⇒ mutantla ısırtılabilir** — projenin kapı doktrini korunur. *Reddedilenler [adlandırılmış]:* **kapsam dışı + adlandırılmış sapma** (sıfır iş, emsali de var — hesap kilitleme `SHALL`'ı böyle yazılmıştı — ama *"15 karakteri NIST diye savunup öbür `SHALL`'ı atlamak"* eleştirisi açık kalırdı) · **HIBP k-anonimlik API'si** (en güçlü koruma, ama **DIŞ AĞ BAĞIMLILIĞI** = ODEV §4.1'in AI asistanını ve Google Takvim'i eleyen risk sınıfının AYNISI; deterministik olmadığı için **mutantla ısırtılamaz**).

**K3-B7 — PHC STRING'İ AYRIŞTIRMA SÖZLEŞMESİ. [Ma-4 kapanır]**
v2 formatı **yazmayı** tarif ediyordu ama **okumayı** hiç yazmamıştı ⇒ bozuk/tanınmayan bir `password_hash` `FormatException` → `500` üretirdi ve **bilinen/bilinmeyen e-posta yanıt kodundan ayırt edilebilirdi** (K3-B5'in garantisi kırılır).

- Ayrıştırma **savunmacıdır**: beş alan (`argon2id` · `v=` · `m=,t=,p=` · b64 salt · b64 hash) beklenir. Herhangi biri eksik/bozuksa **istisna dışarı sızmaz**: doğrulama `false` döner ⇒ `/login` normal `401` yolundan çıkar. Olay `Warning` seviyesinde loglanır (parola veya hash **loglanmaz**).
- **Rehash kararı yalnız `m`, `t`, `p` üçlüsü ve algoritma kimliği üzerinden verilir**; salt ve hash uzunluğu karşılaştırmaya girmez.
- 🔴 **v7 DÜZELTMESİ [B6-D — MAJÖR kapanıyor]: SAVUNMACI DAL, K3-B5'İN *"AYNI İŞİ YAPAR"* GARANTİSİNİ KIRIYORDU. ARTIK SAHTE-HASH DOĞRULAMASI BU DALDA DA ZORUNLUDUR.**
  **Kırılan yer (kapı-6 ölçtü):** v6'nın savunmacı dalı, bozuk PHC gördüğünde **Argon2'yi hiç koşturmadan** `false` dönüyordu ⇒ o hesap için `/login` **`[KS-24]` maliyetini ödemeden** yanıtlanıyordu. K3-B5'in garantisi ise *"bilinen ve bilinmeyen e-posta **aynı işi** yapar"*dır ve o garanti **sahte hash doğrulamasına** dayanır. ⇒ **Ölçülebilir yan kanal:** bozuk hash'li bir hesapta yanıt **çok hızlı** gelir (Argon2 yok), sağlam hash'li bir hesapta **`[KS-24]`** kadar sürer ⇒ *"hızlı `401` = bu e-posta VARDIR **ve** kaydı bozuktur"*. **Kapısı da beyanı da yoktu:** M34 **gövdeyi ve kodu** ölçer, M37 **gövdeyi**, M7 **bilinmeyen-e-posta** yolundaki çağrı sayısını — üçü de bu dalı **görmez**.
  **Karar [PAZARLIKSIZ]:** ayrıştırma başarısız olduğunda doğrulayıcı, `false` dönmeden **ÖNCE** K3-B5'in **sahte hash'ine karşı bir Argon2id doğrulaması KOŞAR** (aynı parametreler, aynı kod yolu) ⇒ üç yol da (bilinmeyen e-posta · sağlam hash + yanlış parola · **bozuk hash**) **aynı işi** yapar.
  **Kapı: 🆕 M58** (`TC`; numara K22-b'nin **M58–M59 tamponundan**): mutasyon — savunmacı daldan sahte-hash doğrulaması **kaldırılır** (dal doğrudan `false` döner). **Kill sinyali:** *"DB'ye elle bozuk `password_hash` yazılmış hesaba `/login` isteğinde **Argon2id doğrulaması TAM OLARAK 1 kez çağrılır**"* **FAIL** — sayaç, **M7'nin kullandığı aynı test-çifti mekanizmasıdır**.
  > **BEYAN EDİLMİŞ SINIR — kapı ZAMANI DEĞİL, MEKANİZMAYI ölçer:** kill sinyali **duvar saati farkını assert ETMEZ** (*"≈1 ms vs ≈`[KS-24]`"* biçiminde bir assert, paylaşılan CI/geliştirici makinesinde **kaçınılmaz olarak kırılgandır** ve ölü tuzak üretir — M1/M7'nin dersi). Ölçülen şey **Argon2'nin çağrıldığıdır**; zamanlama eşitliği bunun **sonucudur**, ayrı bir assert değil. *Bu bir sınırdır, bir güvence değildir.*
- Kapı: **M34** · 🆕 **M58** (yukarıdaki B6-D düzeltmesi).

### C. Token modeli [K8-b]

**K3-C1 — Erişim token'ı = kısa ömürlü JWT (`[KS-1]`), HS256.**
Talepler: `sub` (userId) · `jti` · `iat` · `exp` · **`iss`** · **`aud`** · **`fid`** (family_id, K14-c) · `sstamp` (bugün ölü alan, K3-C8).
> **[Ma-3 kapatıldı]** v2'nin talep listesinde `iss`/`aud` **yoktu** ama K3-C7 ikisini de zorunlu kılıyordu ⇒ liste harfiyen uygulansaydı **her istek `401`** olurdu.
> **[K14-c]** `fid` talebi `/logout`'un hangi aileyi iptal edeceğini **hesaplanabilir** kılar; v2'de bu bilgi hiçbir yerde taşınmıyordu (bloker #6).

İmzalama anahtarı simetrik; **tek servis** topolojisinde asimetrik imza (ES256) anahtar dağıtımı getirir, karşılığında hiçbir şey kazandırmaz. *Reddedilen: ES256 · uzun ömürlü tek JWT (iptal edilemez).*

**K3-C2 — Yenileme token'ı = OPAK, DB'de, DÖNDÜRMELİ, YENİDEN-KULLANIM TESPİTLİ. [taç mekanik]**
- **Değer ve KODLAMASI [B5 — v3'te hiç yazılmamıştı, iki mutantı birden kör bırakıyordu]:** **`[KS-21]`** (256 bit CSPRNG); tele çıkan biçim **`Base64Url`, dolgusuz** (`WebEncoders.Base64UrlEncode` / RFC 4648 §5, `=` dolgusu **yok**) ⇒ **`[KS-22]`**, alfabe `[A-Za-z0-9_-]`. **DB'ye yalnız SHA-256 özeti yazılır ve özet `[KS-21]`'lik HAM BAYTIN üzerinde hesaplanır** (kodlanmış dizenin değil) — `token_hash = SHA256(rawBytes)`. *(Yüksek-entropili rastgele bir sır sözlük saldırısına tabi değildir — bilinçli asimetri; bu yüzden Argon2 değil SHA-256 yeterlidir.)*
  > **Neden bu satır bir kapı kararıdır:** v3 yalnız *"256 bit CSPRNG"* diyordu. Sonucu iki kör kapıydı: (1) **M12** *"SHA-256 özetine eşittir"* diyor ama **neyin** özeti belirsizdi (ham bayt mı, kodlanmış dize mi) ⇒ builder'ın seçimine göre test ya yazılamaz ya yanlış yazılırdı; (2) **M28** gövdeyi ham dize olarak token için tarıyordu — **standart Base64** kullanılsaydı `System.Text.Json`'ın varsayılan kodlayıcısı `+` karakterini **`\u002B`** dizisine çevirdiği için tarama token'ı **≈%49 olasılıkla ıskalardı.** **🔬 ÖLÇÜLDÜ [gerçek koşu — Onur'un makinesi, .NET 9 SDK, 25 Tem 2026]:** `JsonSerializer.Serialize(new { detail = "a+b" })` ⇒ `{"detail":"a\u002Bb"}`; **UTF-8 baytları birebir `… 97 92 117 48 48 50 66 98 …`** ⇒ kaçış dizisi **altı bayttır: `92 117 48 48 50 66`** = ters bölü · `u` · `0` · `0` · `2` · **`B` (66 — BÜYÜK harf)**. *(v4 bu cümlede **aynı karakteri iki kez yazan bir totoloji** kuruyordu — okuyucu neyin neye çevrildiğini öğrenemiyordu; kapı-4 majör #2. Zincirin kaynak ayağı da doğrulandı: `AllowedBmpCodePointsBitmap.ForbidHtmlCharacters()` → `ForbidChar('+')` · `DefaultJavaScriptEncoder(… forbidHtmlSensitiveCharacters: true …)` · `HexConverter.ToBytesBuffer(…, Casing casing = Casing.Upper)` ⇒ **büyük harf varsayılandır**.)* **`Base64Url` alfabesinde `+` ve `/` yoktur ⇒ JSON kaçışı yapısal olarak devre dışı kalır.** Aynı kodlama CSRF nonce'u ve `successor_secret_enc`'in tel biçimi için de geçerlidir.
- **HALEFİN HAM DEĞERİ: `successor_secret_enc` — KISA ÖMÜRLÜ, ŞİFRELİ, ADLANDIRILMIŞ İSTİSNA [K15-a — bloker B1 kapanır].** K3-C6(3)'ün replay-idempotency kuralı *"kayıtlı halef **aynen** döndürülür"* diyor; SHA-256 tersine çevrilemez ve token bir CSPRNG'dir ⇒ **v3'te sunucunun döndürecek bir değeri yoktu ve kural inşa edilemezdi.** Karar: `refresh_tokens`'a `successor_secret_enc` kolonu eklenir; **halefin `[KS-21]`'lik ham baytı**, kök anahtardan türetilmiş `rt-successor-enc` alt anahtarıyla (K3-I4) **AES-256-GCM** ile şifrelenip **yalnız halefi üreten satırda** tutulur ve **`consumed_at + `[KS-4]`` dolduğunda `NULL`**'lanır (mekanizma: K3-C6(5)).
  - **Bu bir istisnadır ve gizlenmiyor:** *"DB'de token'ın ham değeri hiç bulunmaz"* iddiası artık **`[KS-4]` uzunluğunda, şifreli bir pencere** için geçerli değildir. Bedeli **§6 Risk #13**'e yazıldı.
  - **Neden yine de kabul edilebilir:** (a) değer **şifrelidir** ⇒ yalnız DB dökümü alan bir saldırgan onu **kullanamaz**, ayrıca uygulama anahtarını da ele geçirmelidir; (b) pencere **`[KS-4]`dir**, oturum ömrü (`[KS-2]`) değil; (c) `token_hash` sütunu **hâlâ yalnız özettir** ⇒ M12'nin asıl iddiası (*"tele çıkan değer DB'de düz metin durmaz"*) ayakta kalır.
- Ömür: **mutlak `[KS-2]`**, `family_id` doğduğu anda sabitlenir.
- **`expires_at` DEVRALMA DEĞİŞMEZİ [bloker #14'ün ikinci ayağı]:** *"aynı `family_id`'nin **tüm** satırları **özdeş** `expires_at` taşır; döndürmede üretilen yeni satır, sunulan satırın `expires_at`'ini **kopyalar**."* Bu bir cümle değil bir **değişmezdir**: testte tam eşitlikle (`==`) doğrulanır, "yaklaşık" karşılaştırma yasaktır.
- Tablo: `refresh_tokens(id, user_id, token_hash, family_id, created_at, expires_at, consumed_at, replaced_by_id, revoked_at, revoked_reason, successor_secret_enc)`.
  `successor_secret_enc bytea NULL` — AES-256-GCM çıktısı (**`[KS-26]`**). **`NULL` varsayılandır**; yalnız döndürme anında dolar, `[KS-4]` sonra yeniden `NULL` olur. **İlişkili indeks: `WHERE successor_secret_enc IS NOT NULL` kısmi indeksi** (süpürücünün taraması ailenin tamamını değil yalnız canlı pencereyi görsün).
- **Döndürme:** her `/refresh` sunulan token'ı `consumed_at` ile tüketir ve **aynı `family_id`** altında yenisini üretir.
- **YENİDEN-KULLANIM TESPİTİ:** `consumed_at` dolu bir token yeniden sunulursa → **o ailenin tamamı derhal iptal** (`revoked_reason = 'reuse_detected'`), `401`. **İSTİSNA: K3-C6'nın replay-idempotency penceresi** (K14-a) — ve **yalnız o**.

**K3-C3 — `family_id` = GİRİŞ BAŞINA (bir cihaz/oturum) [K11-d].** Her başarılı `/login` **yeni** bir `family_id` doğurur; her `/refresh` **aynı** aileyi sürdürür. Reuse tespiti **yalnız o aileyi** düşürür. *Reddedilen:* kullanıcı başına tek aile.
**Doğum anının kapısı [D3 majörü kapatılıyor]:** M18 bunu yalnız tesadüfen kapsıyordu. Ayırt edici test: *"aynı kullanıcı iki kez `/login` yapar ⇒ dönen iki token **FARKLI** `family_id` taşır"* — **M38**.

**K3-C4 — Çıkış gerçektir, kapsamı AÇIKÇA YAZILIR [K11-d + K14-c].**
`POST /v1/auth/logout` **yalnız JWT'nin `fid` talebindeki aileyi** iptal eder. `POST /v1/auth/logout-all` kullanıcının **tüm ailelerini** iptal eder. Erişim token'ı her iki durumda da **≤ `[KS-1]`** daha geçerli kalır — **bilinçli ve beyan edilmiş** sınır (kara liste tutulmuyor; K3-C8).
**⚠ v2'de bu uç FİİLEN NO-OP'TU** (bloker #2): iptal `revoked_at`'i yazıyordu ama `/refresh` yüklemi ona hiç bakmıyordu. Kapatma K3-C6'dadır; kapısı **M26**.

**K3-C5 — ZARAFET PENCERESİ YOKTUR. [K11-c]** v1'in *"aynı aileden, son 10 sn içinde üretilmiş token da kabul edilir"* penceresi **KALDIRILMIŞTIR**.  <!-- [KS-LITERAL: v1'in KALDIRILMIŞ mekanizmasının tarihsel tarifi] -->
> **⚠ K14-a'NIN REPLAY-IDEMPOTENCY PENCERESİ BU DEĞİLDİR — FARK YAPISALDIR, aşağıda tabloyla yazılıyor (K3-C6).** v1'in penceresi *"ailenin herhangi bir yeni token'ını kabul et"* diyordu ⇒ saldırgan 5 sn'de bir `/refresh` çağırarak **sonsuz bir zarafet zinciri** kurar ve reuse-detection'a **yapısal olarak erişilemez** kılardı. K14-a'nınki *"bu tek token'ın kayıtlı halefini aynen tekrar ver"* diyor ⇒ zincir doğmaz.

**K3-C6 — TÜKETİM ATOMİKTİR; YÜKLEM TAMDIR; 0-SATIR DALI DÖRDE AYRILIR. [bloker #1 + #2 kapanır — bu belgenin en çok değişen maddesi]**

**v2'nin yüklemi eksikti ve tamlık iddiası YANLIŞTI.** v2 birebir şöyle diyordu: *"Etkilenen satır **0** ise token **ya tüketilmiştir** … **ya yoktur**"* — sonuç uzayı hakkında **kapalı bir disjonksiyon**, ve şemada `revoked_at`/`expires_at` varken **yanlış**. Sonucu: `/logout` fiilen no-op, mutlak `[KS-2]` zorlanmıyor.

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
`consumed_at` ve `revoked_at` **aynı anda dolu olabilir** — sıradan bir akışta: kullanıcı `/refresh` yapar (`T1.consumed_at` dolar), sonra `/logout` der (**ailenin tamamı**, `T1` dâhil, `revoked_at` alır). v3'ün dalları **koşulsuz bir küme** gibi yazılmıştı; builder (c)'yi önce ayrıştırırsa **`/logout`'tan sonraki `[KS-4]` boyunca `T1` hâlâ `200` ve çalışan bir halef döndürür** ⇒ çıkış fiilen `[KS-4]` gecikir. **M26 bunu görmez** (o, `revoked_at` yükleminin `UPDATE`'ten çıkarılmasını ölçer, dal sırasını değil).

**Kural:** dallar **bu sırayla** değerlendirilir ve **ilk eşleşen kazanır**:
1. **(a)** satır yok ⇒ `401`.
2. **(b)** `revoked_at IS NOT NULL` **veya** `expires_at ≤ now` ⇒ `401`. **Bu dal sağlanıyorsa replay-idempotency HİÇ DEĞERLENDİRİLMEZ** — iptal edilmiş ya da süresi dolmuş bir aile için "kayıp yanıt telafisi" diye bir şey yoktur.
3. **(c)** `consumed_at IS NOT NULL` **ve** replay koşulları (aşağıda) ⇒ `200`.
4. **(d)** aksi hâlde ⇒ `401` + **`reuse_detected`**.

**Kapı: M44** (mutasyon: sıra (c)→(b) yapılır ⇒ `/logout` sonrası `[KS-4]` içinde replay `200` döner).

**(3) SINIRLI REPLAY-IDEMPOTENCY [K14-a — bloker #1 / **RT-B1**'in kapatılması].**
**Kırılan senaryo (saldırgan gerekmez; aktör = ağ):** istemci `/refresh` gönderir (`T1`) → sunucu tüketimi **commit eder** (`T2` doğar) → **yanıt istemciye ulaşmaz** (uçak modu, hücresel el değiştirme, TCP reset, Android Doze/process kill) → istemcinin elinde hâlâ `T1` var, `T2`'yi hiç görmedi → yeniden dener → v2'de **aile düşer, meşru kullanıcı kendini hırsız ilan eder**. Tek-uçuşluluk (K3-L5) bunu **kapsamaz**: o *eşzamanlı* çağrıları serileştirir, *ardışık yeniden denemeyi* değil — ikinci adımda uçuş zaten bitmiştir.

**Kural:** tüketilmiş `T1` yeniden sunulduğunda, **her ÜÇ koşul da** sağlanıyorsa `T1`'in **kayıtlı halefi aynen** döndürülür; yeni döndürme **yapılmaz**:
1. `now ≤ T1.consumed_at + ` **`[KS-4]`** **[sahibi **K14-a**; Onur kilidi. v4 bu pencereyi ÜÇ yerde **K16-b**'ye atfediyordu — **yanlıştır**: K16-b'nin tam metni **yalnız hız sınırı tavanlarıdır** (`[KS-10]`/`[KS-11]`/`[KS-12]`). Kapı-4 majör #3.]**, **ve**
2. `T1.replaced_by_id`'nin işaret ettiği satırın `consumed_at`'i **hâlâ `NULL`** (halef henüz kullanılmamış), **ve**
3. **`T1.successor_secret_enc IS NOT NULL`** — yani halefin ham değeri hâlâ **çözülebilir** durumdadır (K15-a). Değilse dal **(d)**'ye düşülür.

> **🔴 v3'TE BU KURAL İNŞA EDİLEMİYORDU — B1'İN KAPATILMASI [K15-a].**
> Denetim şunu ölçtü: K3-C2 *"DB'ye **yalnız** SHA-256 özeti yazılır"* diyor · şemada ham değer için kolon **yok** · **M12 bunu ayrıca zorluyor** ⇒ sunucunun *"aynen döndürecek"* bir değeri **yoktu**. SHA-256 tersine çevrilemez ve token bir **CSPRNG**'dir, `HMAC(key, row_id)` gibi yeniden hesaplanabilir bir yapı değildir. **Bu bir yazım kusuru değil, bir inşa-edilemezlik kusuruydu** ve M29/M30/M1'in üçü de var olmayan bir davranışa çıpalıydı.
> **Karar (K15-a): `successor_secret_enc`.** Halefin `[KS-21]`'lik ham baytı, `rt-successor-enc` alt anahtarıyla (K3-I4) **AES-256-GCM** ile şifrelenir ve `T1` satırında tutulur; replay dalında **çözülüp aynen döndürülür**; **`[KS-4]` sonra `NULL`**'lanır (5). **K14-a'nın semantiği hiç değişmedi:** yeni token üretilmez · pencere `T1.consumed_at`'e çıpalıdır · `expires_at` devralınmıştır ⇒ **v1'in sonsuz zinciri hâlâ yapısal olarak imkânsızdır** (aşağıdaki beş eksenli tablo aynen geçerlidir).
> *Reddedilenler [adlandırılmış]:* **dal (c)'nin yeniden yazımı** (*"yeni token üretilir ama `T1`'in halefi olarak kaydedilir, `expires_at` devralınır"* — şema değişmezdi ama *"yeni döndürme yapılmaz"* cümlesi düşer, koşul 2'nin semantiği ve M29/M30'un kill sinyalleri baştan yazılır, her kayıp yanıtta ailede bir satır daha birikir) · **K14-a'nın tümüyle geri alınması** (telafisiz adlandırılmış sınır; RFC 9700 §4.14.2 bunu bir **maliyet** sayar ama değerlendirici uçak modunu açıp kapattığında çevrimdışı vitrininin ortasında yeniden giriş ekranı görür — ODEV §2; K14-a tam da bunun için seçilmişti) · **K3-C2'nin "yalnız özet" kararını tümüyle gevşetmek** (şifreleme olmadan DB dökümü = `[KS-2]`lük kullanılabilir token).

**Neden bu, v1'in reddedilen zarafet penceresi DEĞİL:**

| eksen | v1 zarafet penceresi (REDDEDİLDİ) | K14-a replay-idempotency |
|---|---|---|
| Çıpa | **aileye** (*"ailenin son 10 sn'de üretilmiş herhangi bir token'ı"*) | **tek token'a** (`T1.consumed_at`) <!-- [KS-LITERAL: v1'in KALDIRILMIŞ mekanizmasının tarihsel tarifi] --> |
| Her çağrıda ne olur | **yeni token üretilir** ⇒ pencere ileri kayar | **hiçbir şey üretilmez** ⇒ pencere sabit, `T1` ile birlikte ölür |
| Sonsuz zincir | **MÜMKÜN** (5 sn'de bir `/refresh` ⇒ reuse-detection'a hiç varılmaz) | **YAPISAL OLARAK İMKÂNSIZ** |
| Halef kullanıldıysa | fark etmez, yine kabul | **REDDEDİLİR ⇒ aile düşer** (gerçek hırsızlık sinyali korunur) |
| Ömür | uzayabilir | `expires_at` devralındığı için **uzamaz** |

**Hırsızlık senaryosunda ne kaybediyoruz — dürüst muhasebe [v6'da YENİDEN YAZILDI; v4/v5'in muhasebesi §0.4'te GERİ ÇEKİLDİ].**
Tüketilmiş `T1`'i ele geçiren saldırgan, `[KS-4]` içinde **ve halef `T2` henüz tüketilmemişken** sunarsa dal **(c)** işler: aile düşmez, saldırgan `T2`'yi alır. **Tespit o anda gerçekleşmez — ve gecikmenin ölçüsü `[KS-4]` DEĞİLDİR:**

1. **Tespit bir ÇARPIŞMAYLA olur.** Dal **(d)**'ye ancak tüketilmiş bir token ya `[KS-4]` **dışında** sunulduğunda (koşul 1 düşer) ya da **halefi çoktan tüketilmişken** sunulduğunda (koşul 2 düşer) varılır. Çarpışma olmadan aile düşmez.
2. **Çarpışmanın zamanını meşru istemcinin yenileme ritmi belirler.** Meşru istemci bir sonraki `/refresh`'ini erişim token'ı dolduğunda yapar ⇒ **normal (çevrimiçi) durumda tespit gecikmesinin ölçüsü `[KS-1]`'dir**, `[KS-4]` değil.
3. **Kurban çevrimdışıysa ya da uygulamayı hiç açmıyorsa** hiç yenileme yapmaz ⇒ çarpışma hiç doğmaz ve **gecikme, ailenin mutlak ömrü `[KS-2]`'ye kadar uzayabilir.** Bu, ODEV §2'nin çevrimdışı vitrininin **doğrudan bedelidir**: aynı özellik hem meşru kullanıcıyı kayıp yanıttan kurtarır hem hırsızlık tespitini geciktirir.
4. **[COWORK BULGUSU — v6'da İLK KEZ YAZILIYOR; kapı-6 bunu ÇÜRÜTMEKLE YÜKÜMLÜDÜR] Gölgeleme (shadowing).** Koşul 2 **halefin** `consumed_at`'ine bakar, `T1`'inkine değil. Zincirin her adımında halef **taze** doğduğu için, iki taraf da her tüketimden sonra `[KS-4]` içinde yeniden sunarak **aynı zinciri adım adım paylaşmayı sürdürebilir**. ⇒ v4/v5'in *"meşru istemci `T2`'yi kullandığı anda saldırganın bir sonraki `/refresh`'i (d) dalına düşer"* cümlesi **belgenin kendi dal kuralıyla yanlışlanır**: o `/refresh` koşul 2'yi **sağlar** ve `T3`'ü alır. **Sınırlar yine de duruyor:** 🔴 **v7 DÜZELTMESİ [B6-C]:** v6 burada *"zincir **yeni token basmaz**"* diyordu ve bu **yanıltıcıydı** — zincir her adımda **yeni token basar**; basan şey **replay dalı değil, karşı tarafın normal döndürmesidir.** **Ölçülebilir doğru ifade:** *"**replay dalı (c) ailenin SATIR SAYISINI artırmaz**"* — yani gölgeleme aileye **fazladan satır eklemez**; `expires_at` **devralınır** ⇒ ömür uzamaz ve `[KS-2]`'de kesin biter (**v1'in sonsuz zinciri hâlâ yapısal olarak imkânsızdır**), ayrıca gölgeleyen tarafın **her adımda `[KS-4]` içinde yetişmesi** gerekir; yetişemediği ilk adımda aile düşer. **Bu kalem bir KARAR DEĞİŞİKLİĞİ değildir — ölçülmüş bir maliyet kalemidir ve §6 Risk #11'e yazılmıştır.**

**Bedelin tek cümlelik dürüst özeti:** `[KS-4]` penceresi reuse-detection'ı **kaldırmaz, ÇARPIŞMAYA KADAR ERTELER**; ertelemenin ölçüsü `[KS-4]` değil **`[KS-1]` … `[KS-2]` aralığıdır**. Bu maliyet, *"tek ağ kesintisi `[KS-2]`lük oturumu yeniden girişe çeviriyor"* maliyetine karşı bilinçli olarak seçilmiştir (K14-a) — **ama seçim ancak v6'da gerçek sayıyla tartılmıştır.**

**Kapılar: M29** (pencere dışında sunulan tüketilmiş token **aile düşürür**) · **M30** (halef **pencere içinde** tüketilmişse **aile düşürür**) · **M1** (replay-idempotency tamamen kaldırılırsa değil — reuse-detection kaldırılırsa) · **M44** (dal önceliği) · **M40** (sırrın `[KS-4]` sonra **gerçekten silindiği**).

**(5) `successor_secret_enc`'İN SİLİNMESİ: İKİ MEKANİZMA, İKİSİ DE ZORUNLU [K15-a'nın veri-minimizasyon ayağı — kırmızı çizgi #2].**
Yalnız yüklemle yetinmek **yetmez**: `/refresh` yüklemi pencereyi **güvenlik** açısından zorlar (`[KS-4]` sonra dal (c) açılmaz), ama o satıra bir daha hiç dokunulmazsa **şifreli sır DB'de `[KS-2]` durur** ⇒ §6 Risk #13'ün *"`[KS-4]`lik pencere"* ifadesi **yalan olurdu**. İkisi birlikte:
1. **Fırsatçı (tembel) silme:** her `/refresh` işleminde, aynı transaction içinde, **o ailenin** `consumed_at < now - [KS-4]` olan satırlarının `successor_secret_enc`'i `NULL`'lanır.
2. **Süpürücü (`RefreshSecretSweeper`):** `BackgroundService`, **her `[KS-6]`'te bir**, `UPDATE refresh_tokens SET successor_secret_enc = NULL WHERE successor_secret_enc IS NOT NULL AND consumed_at < @now - interval '10 minutes' <!-- [KS-LITERAL: SQL sabiti; değeri [KS-4] ile AYNI olmak ZORUNDADIR — bu SQL'in YAŞ EŞİĞİDİR, süpürme PERİYODU değil] -->` koşar. **Saat kaynağı `TimeProvider`'dır** (K-C5) ve süpürme işi **doğrudan çağrılabilir bir metoda** (`SweepAsync(CancellationToken)`) ayrılır ⇒ test `BackgroundService`'in zamanlayıcısını beklemek zorunda kalmaz.
   > **K3-D3'ün arka plan tuzağı burada da geçerlidir:** süpürücü **owner-filtreli hiçbir sorguya dokunmaz**; `ICurrentUser`'ı **çözmez**; kendi `IServiceScope`'unu açar. Kapsamı tek kolondur.
3. **Değişmez:** `consumed_at < now - [KS-4]` olan **hiçbir** satırda `successor_secret_enc` dolu olamaz — **azami gecikme bir süpürme periyodudur (`[KS-6]`)** ve bu **§6 Risk #13'te birebir böyle beyan edilir** ("`[KS-4]` pencere + azami `[KS-6]` süpürme gecikmesi ⇒ en kötü durumda **`[KS-4]` + `[KS-6]`**") <!-- [KS-LITERAL: GERİ ÇEKİLEN literalin tarihsel kaydı] v6: burada *"en kötü durumda 120 sn"* yazıyordu; K28-a `[KS-4]`'ü 60 sn'den 10 dk'ya çıkarınca bu literal SESSİZCE YANLIŞLANDI. Sayı düştü, atıf kaldı. -->.

**Kapı: M40** — mutasyon: süpürücü devre dışı bırakılır (veya `SweepAsync` no-op yapılır). Kill sinyali: *"`FakeTimeProvider` **`[KS-4]` + `[KS-6]` kadar** ileri alınıp (yani yaş eşiğini kesin olarak aşacak biçimde) `SweepAsync` çağrıldıktan sonra, tüketilmiş satırın `successor_secret_enc`'i **`NULL`**'dır"* **FAIL**. Seviye **TC** (gerçek Postgres; kolonun fiilen `NULL`'landığı okunur).

**(4) ATOMİKLİK KAPISI [D3 majörü kapatılıyor].** v2 atomikliği **iddia ediyor ama test etmiyordu**. 🔴 **v7 DÜZELTMESİ — v6 BURADA ADR 0002'YE AİT OLMAYAN BİR CÜMLEYİ ALINTI GİBİ SUNUYORDU [K35, ölçüldü].**
**Emsal GERÇEKTEN VARDIR ve şudur — `0002:187` BİREBİR:** *"**K2-H12 — Eşzamanlı-aynı-clientId INGEST [BLOKER-R2]:** aynı clientId'den paralel op'lar → `lastEffectiveHlc` lost-update YOK, monoton, determinist (operationId çözer); mutant (atomik-olmayan yazma / operationId'siz) BAŞARISIZ."*
**ADR 0003'ün KARŞILIĞI — bu cümle BU BELGENİN kendi cümlesidir, ADR 0002'den alıntı DEĞİLDİR:** aynı `T1` ile **paralel** iki `/refresh` ⇒ **M39** (Testcontainers, gerçek Postgres; `TestServer` içi kilit bunu kanıtlamaz).
> ⚠ **NE OLDU:** v6 birebir *"Emsal 0002 K2-H12'**de var**: «aynı `T1` ile paralel iki `/refresh` — tam olarak biri `200`, diğeri `401`+`reuse_detected` alır…»"* yazıyordu. **ÖLÇÜM:** `grep -c "refresh\|reuse_detected" docs/ADR/0002-senkron-mekanigi.md` ⇒ **0**; `/refresh` · `reuse_detected` · `T1` **üçü de ADR 0002'de HİÇ GEÇMİYOR.** Emsalin **özü** doğruydu (paralel aynı-anahtar yarışı · tam olarak biri kazanır · atomik-olmayan yazmaya mutant), ama **tırnak içindeki metin KİLİTLİ bir ADR'ye ait değildi** — o, v6'nın kendi uyarlamasıydı.
> **SINIF:** kapı-5 **B5-5** / kapı-6 **B6-8** ailesi (*"beyan edildiği söylenen ama yazılmamış"*), buradaki biçimiyle *"**alıntılandığı söylenen ama yazılmamış**"*. **BLOKER DEĞİL** (M39 kendi mutasyonu altında ölüyor, kapısı bu alıntıdan bağımsız), **ama bir portfolyo belgesinde kilitli bir kaynağa atfen var olmayan metin göstermek** belgenin kendi §4 kuralının doğrudan ihlalidir.
> **KURAL [v7'de yürürlüğe giriyor, PAZARLIKSIZ]:** başka bir ADR'den **tırnak içinde** aktarılan her metin **satır numarasıyla** verilir (`0002:187` gibi) ve **kısaltma yalnız `…` ile işaretlenerek** yapılır. Bu belgenin **kendi** formülasyonu, kaynağınkiyle **aynı paragrafta bile olsa** tırnak dışında ve *"bu belgenin karşılığı"* etiketiyle yazılır.

**K3-C7 — `TokenValidationParameters` AÇIKÇA YAZILIR — hiçbir varsayılana güvenilmez.**

| ayar | değer | neden |
|---|---|---|
| `ValidateIssuer` / `ValidIssuer` | `true` / yapılandırmadan | K3-C1'in `iss` talebiyle eşleşir |
| `ValidateAudience` / `ValidAudience` | `true` / yapılandırmadan | K3-C1'in `aud` talebiyle eşleşir |
| `ValidateLifetime` | `true` | — |
| **`ClockSkew`** | **`TimeSpan.Zero`** (= `[KS-8]`) | **ÖLÇÜLDÜ:** `TokenValidationParameters.DefaultClockSkew = TimeSpan.FromSeconds(300)` ⇒ varsayılan ezilmezse **beyan edilen `[KS-1]` fiilen `[KS-1]` + `[KS-8]`'in EZİLMEMİŞ varsayılanı** kadar olurdu. <!-- v7: burada "≤20 dk" yazıyordu — kapı-6 majör #8: iki kanonik sayıdan TÜRETİLMİŞ, atıfsız ve muafiyetsiz bir literal. Sayı düştü, türetme sembolik yazıldı (K30). --> |
| `ValidateIssuerSigningKey` / `IssuerSigningKey` | `true` / K3-I1'den | — |
| `ValidAlgorithms` | `[ "HS256" ]` | **DAR AMA GERÇEK BİR KAPIDIR** — yalnız *aynı anahtarla HS384/HS512 ikamesini* kapatır; `alg:none`'ı ve RS256'yı **kapatmaz** (aşağıdaki düzeltmeye bakınız). Kapısı **M16'nın ikinci ayağıdır.** |
| `RequireSignedTokens` / `RequireExpirationTime` | `true` / `true` | `RequireSignedTokens` **`alg:none`'ı kapatan asıl ayardır** |
| **`MapInboundClaims`** | **`false`** | Claim tipleri ham JWT adlarıyla kalır (`sub`, `jti`, `fid`, `sstamp`). |

> **🔴 v2'NİN `alg` BEYANI YANLIŞTI — DÜZELTİLİYOR [bloker #12].**
> v2 birebir *"Pinleme, algoritma-karıştırma sınıfını tek satırla kapatır"* diyordu. **Ölçüm bunu yalanlıyor:**
> 1. Simetrik anahtarla **RS256/ES256 yapısal olarak zaten reddedilir** (`SymmetricSignatureProvider` yalnız `HmacSha256/384/512` + `Aes*CbcHmacSha*` üretir) ⇒ testi RS256 ile yazan bir builder'da mutant **hayatta kalır = kör kapı**.
> 2. **`alg:none`'ı kapatan `ValidAlgorithms` değil `RequireSignedTokens`'tır** ⇒ testi `alg:none` ile yazan bir builder'da da mutant hayatta kalır.
> 3. Pinlemenin kapattığı **tek** şey **aynı anahtarla HS384/HS512 ikamesidir** — ve o anahtara sahip bir saldırgan zaten HS256 imzalayabilir.
> **Sonuç:** ayar **TUTULUR** (ileride asimetrik anahtar eklenirse kritik olur) ve **DAR bir kapıdır**: M16'nın `alg` ayağı **HS512 ikamesine** pinlenir — ve **ısırdığı bu turda doğrulandı** (`SymmetricSignatureProvider` yalnız 128 bitlik asgariyi uygular ⇒ 32 baytlık anahtar HS512 imzalayabilir ⇒ pin kaldırılırsa token **kabul edilir** ⇒ test kırılır). `ClockSkew` ayağı olduğu gibi kalır.  <!-- [KS-LITERAL: `SymmetricSignatureProvider`'ın asgari anahtar biti — kanonik sayı değil] -->
> **[Ma-16 — TEK STATÜ]** v3 bu satıra üç farklı statü veriyordu (*"kapı değil hijyendir"* · *"kapı sayılmaz"* · §3.1'de *"`alg` istisnadır çünkü sessiz varsayılanı değiştirir"*). **v4'ün tek statüsü:** ***`ValidAlgorithms` DAR AMA GERÇEK BİR KAPIDIR; kapsamı yalnız aynı-anahtar HS384/HS512 ikamesidir ve M16'nın ikinci ayağı onu ısırır.*** Belgenin üç yerinde de bu cümle geçerlidir.

> **⚠ `MapInboundClaims=false`'UN ÖLÇÜLMÜŞ YAN ETKİSİ — ÜÇ YERİ VURUR (kaynaktan doğrulandı, 25 Tem 2026):**
> `ClaimTypeMapping.InboundClaimTypeMap` birebir `{ JwtRegisteredClaimNames.Sub, ClaimTypes.NameIdentifier }` girdisini taşır; `JwtBearerOptions.MapInboundClaims` varsayılanı **`true`**'dur ve `false` yapıldığında **çeviri hiç koşmaz** ⇒ `ClaimTypes.NameIdentifier` **DOLMAZ**.
> 1. **Bu belgede:** `ICurrentUser` `ClaimTypes.NameIdentifier` okursa **her istekte `UnauthenticatedException`** ⇒ **`"sub"` doğrudan okunur** (K3-D2, kapı **M24**).
> 2. **ADR 0004'te:** `DefaultUserIdProvider.GetUserId` = `connection.User.FindFirst(ClaimTypes.NameIdentifier)?.Value` ⇒ SignalR `Context.UserIdentifier` **`null`** düşer, `user:{id}` grubu **sessizce** hiçbir istemciye ulaşmaz. Özel `IUserIdProvider` **zorunludur** (**D-1**, §7).
> 3. **[YENİ — D2-#5] `NameClaimType`/`RoleClaimType` bağımsızdır** ⇒ `ClaimTypes.Name` eşlemesi de koşmaz, **`User.Identity.Name` `null` kalır.** Bu kapsamda etkisizdir (token'da `name` talebi yok, roller kapsam dışı) **ama işbirliği diliminde canlanır** — o dilim `User.Identity.Name`'e dayanırsa sessizce boş görünen kullanıcı adları üretir. **Adlandırıldı; 0004/işbirliği diliminin girdisidir.**

**K3-C8 — `security_stamp` BUGÜN ÖLÜ ALANDIR — BİLİNÇLİ VE BEYAN EDİLMİŞ. [K14-d — Ma-5 kapanır]**
Kolon (`User.security_stamp`) ve talep (`sstamp`) **vardır**; **doğrulaması yoktur** ve hiçbir olayda değişmez. Bu bir unutma değil, bir karardır.

- **Sunulmamış ödünleşim, artık sunuluyor:** `/logout-all` (ve ileride parola değişimi) `security_stamp`'i artırsaydı ve her korumalı istekte token'daki `sstamp` DB'dekiyle karşılaştırılsaydı, **Risk #3'ün `[KS-1]` uzunluğundaki penceresi sıfıra inerdi**. Bedeli: **istek başına bir DB okuması**.
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

**K3-I2 — Anahtar yoksa uygulama AÇILMAZ (fail-fast); ANAHTARIN KODLAMASI PİNLİDİR.** Eksik veya **çözülmüş hâli `[KS-20]`'den kısa** kök anahtarda başlangıçta `InvalidOperationException`.
- **[B4'ün ikinci ayağı — v3 bunu yazmamıştı]** Anahtarın tel/dosya biçimi **`Base64` (standart, dolgulu)** olarak pinlenir; uygulama onu **çözer** ve **çözülmüş bayt sayısını** ölçer. v3 *"32 bayttan kısa"* diyordu ama **neyin** 32 baytı belirsizdi ⇒ builder karakter sayısını ölçerse 24 baytlık bir anahtar (32 karakterlik Base64) **fail-fast'ten geçerdi**.  <!-- [KS-LITERAL: v3'ün BELİRSİZ ifadesinin tarihsel alıntısı — kusurun kendisi gösteriliyor] -->
- Fail-fast **tek anahtarı** kontrol eder (K16-c sayesinde ikinci/üçüncü sır yoktur) ve **üç kullanımı birden** güvenceye alır.

**K3-I4 — ANAHTAR TÜRETME: TEK KÖK + HKDF-SHA256, ÜÇ AMAÇ-BAĞLI ALT ANAHTAR. [K16-c — bloker B8 + K15-a'nın anahtar ayağı]**
Üç kriptografik kullanım vardır ve **hiçbiri kök anahtarı doğrudan kullanmaz**:

| kullanım | alt anahtar | `info` etiketi (birebir) | uzunluk | nerede |
|---|---|---|---|---|
| JWT HS256 imzalama | `K_jwt` | `"momentum:v1:jwt-sign"` | **`[KS-30]`** | `IAccessTokenIssuer` + `TokenValidationParameters.IssuerSigningKey` |
| CSRF token HMAC'i | `K_csrf` | `"momentum:v1:csrf-hmac"` | **`[KS-30]`** | `ICsrfTokenService` (K3-L3) |
| Halef sırrı şifreleme | `K_rt` | `"momentum:v1:rt-successor-enc"` | **`[KS-30]`** | `IRefreshTokenService` — AES-256-GCM (K3-C2) |

- **Türetme:** `HKDF.Expand(HashAlgorithmName.SHA256, prk: masterKey, outputLength: `[KS-30]`, info: <etiket>)` — `System.Security.Cryptography.HKDF` **BCL'dedir** (.NET 5+), yeni paket **yok** (kırmızı çizgi 3 tetiklenmez). *(`Extract` adımı atlanır: kök anahtar zaten `[KS-20]` uzunluğunda, yüksek-entropili bir CSPRNG çıktısıdır; HKDF-Expand doğrudan uygulanabilir.)*
- **`info` etiketleri PAZARLIKSIZDIR ve `v1` taşır** — ileride anahtar rotasyonu gerekirse etiket `v2` olur ve **üç alt anahtar birlikte döner**.
- **Neden türetme, üç ayrı sır değil:** K15-a'nın kısıtı birebir *"üçüncü bir sır doğmasın"*dı. Türetme (a) tek bootstrap · (b) tek fail-fast · (c) tek `.gitignore` kalemi verir, **ve yine de anahtar-amaç ayrımını korur**: `K_csrf` sızsa bile JWT imzalanamaz. *Reddedilenler [adlandırılmış]:* **üç ayrı anahtar** (en açık ayrım; bedeli üç fail-fast + üç bootstrap ayağı + üç mutant ve K15-a'nın kısıtının reddi) · **iki anahtar** (CSRF ile şifreleme aynı sırrı paylaşır — anahtar-amaç ayrımını kısmen bozar, denetçi bulur) · **kök anahtarı doğrudan üç yerde kullanmak** (aynı anahtarla hem imzalamak hem şifrelemek: kriptografik olarak en kötü seçenek).
- **HKDF-Extract neden atlanıyor — GEREKÇE ÜRETİM YOLUNDA ZORLANIR [kapı-4 majör #14].** RFC 5869 §3.3 birebir: kaynak anahtar materyali **zaten düzgün dağılımlı** ise `Extract` atlanabilir. Bu gerekçe **kök anahtarın CSPRNG çıktısı olmasına** dayanır — ama K3-I2'nin fail-fast'i **yalnız UZUNLUK ölçer**, entropiyi ölçmez. ⇒ Elle yazılmış `"aaaa…"` gibi `[KS-20]` uzunluğunda bir anahtar fail-fast'ten **geçer** ve gerekçe **karşılıksız kalır**. **Karar:** K3-I3'ün bootstrap'ı anahtarı **her zaman `RandomNumberGenerator.GetBytes(32)`** <!-- [KS-LITERAL: ÜRETİM KODUNUN ÇAĞRI ARGÜMANI — `GetBytes(32)` bir C# literalidir ve değeri `[KS-20]` ile AYNI olmak ZORUNDADIR; atıfla yazılamaz. v7/oturum-26'da aracın K4 bulgusu üzerine ADIYLA muaf tutuldu] --> ile üretir (üretimdeki tek meşru kaynak budur) ve **README'de üretim anahtarının nasıl üretileceği birebir komutla yazılır**. **Gerekçe artık şudur ve sınırı açıkça yazılıdır:** *"Extract atlanabilir ÇÜNKÜ kök anahtar üretim yolunda CSPRNG çıktısıdır; operatör bu yolu atlar ve düşük-entropili bir anahtar koyarsa **türetme zayıflar ve bunu ölçen bir kapı YOKTUR.**"*
> 🔴 **v7 DÜZELTMESİ [B6-8 — BLOKER kapanıyor]. SINIRIN BEYAN OTORİTESİ BU SATIRDIR.**
> v6 cümleyi *"— **§3.1'de beyanlıdır**"* diye bitiriyordu. **ÖLÇÜLDÜ (kapı-6 B6-8): §3.1'in kapısız-kalan
> tablosunda `K3-I4` · `HKDF` · `Extract` · kök anahtar entropisi ile ilgili TEK SATIR YOKTU** — yani
> *"beyan edildiği İDDİA EDİLİYOR ama beyan EDİLMEMİŞ"*. Bu, kapı-5'in **B5-5**'te bloker saydığı kalıbın
> aynı belgede tekrarıydı ve doktrini doğrudan deliyordu: *"**beyan edilmiş** sınır kabul edilir,
> **gizlenmiş** sınır edilmez"* — **beyanı olmayan bir sınır, gizlenmiş sınırdır.**
> ⇒ **Sınır artık BURADA, adıyla ve tam olarak beyan edilmiştir** ve beyanın otoritesi bu satırdır.
> **BEYAN EDİLEN SINIR (birebir):** `Momentum:MasterKey`'in **entropisi hiçbir kapı tarafından ölçülmez**;
> K3-I2'nin fail-fast'i **yalnız `[KS-20]` uzunluğunu** doğrular. Elle yazılmış, `[KS-20]` uzunluğunda ama
> düşük-entropili bir anahtar (ör. tekrar eden bayt dizisi) fail-fast'ten **geçer** ve HKDF-Extract'in
> atlanma gerekçesi o anahtar için **karşılıksız kalır**. **Telafi kapı DEĞİL, YOL kısıtıdır:** üretimdeki
> tek meşru kaynak K3-I3'ün `RandomNumberGenerator.GetBytes(…)` bootstrap'ıdır ve README bunu birebir
> komutla yazar. **Bu sınır kabul edilmiştir.**
> ⚠ **v7 BORCU [açık, gizlenmiyor]:** §3.1'in kapısız-kalan tablosuna bu kalem için bir **özet satırı**
> eklenecektir. **§3.1 yalnız ÖZET taşır; beyanın otoritesi yukarıdaki paragraftır** — böylece aynı
> kusur (*"öbür bölümde beyanlı"* deyip orada olmaması) **yapısal olarak bir daha doğamaz.**  <!-- [KS-LITERAL: RFC 5869 ve fail-fast bağlamı — `[KS-20]` ile aynı sayı, gerekçe metninde birebir gerekli] -->
- **ANAHTAR ROTASYONU — KAPSAM DIŞI, ADLANDIRILMIŞ [kapı-4 majör #15].** v4 rotasyon için ne mekanizma yazıyordu ne de kapsam dışı diyordu. **Karar:** rotasyon **bu dilimin kapsamı dışındadır**. `info` etiketlerindeki `v1`, rotasyonun **gelecekteki yolunu** açık tutar (etiket `v2` olur ⇒ üç alt anahtar birlikte döner) ama **bugün ne bir rotasyon uç noktası ne bir çift-anahtar (eski+yeni) doğrulama penceresi vardır.** ⇒ Kök anahtar değişirse **tüm oturumlar düşer** (JWT'ler doğrulanamaz, CSRF token'ları geçersizleşir, `successor_secret_enc` çözülemez — ki bu sonuncusu K3-I5(3) gereği `reuse_detected` üretir ve aileleri düşürür). **Bu, kabul edilmiş ve beyan edilmiş bir sınırdır** (§6 Risk #17).
- **`info` ETİKETLERİNİN BAYT KODLAMASI PİNLİDİR [kapı-4 majör #13 kapanır].** `HKDF.Expand(…, byte[]? info)` bayt alır, string almaz. Etiketler **US-ASCII** ile kodlanır (`Encoding.ASCII.GetBytes`), **sondaki `NUL` yoktur**, **BOM yoktur**. *Gerekçe:* etiketlerin tamamı ASCII aralığındadır ⇒ UTF-8 ile birebir aynı baytları verir; ASCII'yi pinlemek, ileride etikete ASCII dışı bir karakter sızarsa **derleme/koşum anında patlamayı** sağlar. Bu, B5'in *"neyin özeti"* pinlemesinin birebir kardeşidir: **bir hash/KDF girdisinin baytları yazılmadıkça, iki bağımsız implementasyon aynı anahtarı üretmez.**
- **ETİKETLER TEK YERDE TANIMLANIR (`static class HkdfLabels`) VE İKİŞER İKİŞER FARKLI OLDUKLARI ÖLÇÜLÜR. [K28-d(b) — kapı-5'in 6. aday blokeri kapanır] [PAZARLIKSIZ]** **Kırılan yer (kapı-5 ölçtü):** etiketlerin **çakışmazlığı** hiçbir yerde ölçülmüyordu. Kopyala-yapıştırla `K_csrf`'in etiketi `K_jwt`'ninkine eşitlenirse **alan ayrımı tümüyle çöker** — ve **M42 · M42b · M42c · M25 · M35'in BEŞİ DE YEŞİL kalır**: M42 yalnız *türetmenin varlığını*, M42b yalnız *etiketin baytlarını altın vektöre karşı* ölçer, ikisi de *iki etiketin birbirinden farklı olduğunu* ölçmez. Çakışma **sinsidir**: sistem çalışmaya devam eder, yalnız `K_csrf` ile `K_jwt` aynı anahtar olur ⇒ CSRF çerezini üretebilen bir yüzey **JWT imzalayabilir**. **Kural:** üç `info` etiketi **tek bir `static class HkdfLabels`** içinde `const string` olarak tanımlanır (`Jwt` · `Csrf` · `Rt`); türetme yolu **başka hiçbir yerde string literal taşımaz** ⇒ ikinci bir tanım noktası doğamaz. **Kapı: M55** (`B`): mutasyon iki etiketi eşitler; kill sinyali *"`K_jwt` · `K_csrf` · `K_rt` **ikişer ikişer FARKLIDIR**"* (üç çift, `CryptographicOperations.FixedTimeEquals`) **FAIL**. *Reddedilenler [adlandırılmış]:* **§3.1'e beyan** (K28-d bunu açıkça reddetti: HKDF çakışması salt sabitlemesinden **daha sinsidir**, çünkü hiçbir gözlemlenebilir davranış değişmez) · **etiketleri enum/`nameof` ile üretmek** (tanım noktasını teke indirir ama etiketin **baytlarını** yeniden adlandırmaya bağlar ⇒ M42b'nin altın vektörü bir *refactor* ile sessizce kırılır).
- **Kapı: M42** (yalnız **türetmenin varlığı**: alt anahtar yerine kök anahtar doğrudan kullanılırsa ısırır) **+ M42b** (`info` etiketi değiştirilirse — ör. `v1` → `v2` — mevcut oturumların JWT'leri doğrulanamaz ⇒ `401`). *(v4'te M42'nin mutasyonu **bileşikti** — türetme + efemer üretim tek mutasyonda; kapı-4 majör #10. İki ayak **ayrıldı**: efemer üretim ayağı artık M42c'dir ve `KON` seviyesindedir.)*

**K3-I5 — HALEF SIRRININ ŞİFRELENMESİ: HER ŞİFRELEMEDE TAZE NONCE + AAD. [K18-b — bloker B-5 kapanır] [PAZARLIKSIZ]**

**Kırılan yer:** v4, `successor_secret_enc`'in **düzenini** (`nonce ‖ ciphertext ‖ tag`, `[KS-26]`) yazıyordu ama **nonce'un nereden geldiğini hiçbir yerde yazmıyordu.** `grep RandomNumberGenerator` ⇒ **0 eşleşme**; AAD ⇒ **yok**. Ve `K_rt` **tek ve kalıcıdır** (K3-I4'ün deterministik türetmesi + K3-I3'ün *"sonraki açılışlar aynı anahtarı okur"* vaadi) ⇒ nonce tekrarı teorik bir kaygı değil, **yazılmadığı için varsayılan** bir risktir.

**Karar (üç ayak, üçü de PAZARLIKSIZ):**

| # | kural | neden |
|---|---|---|
| **1** | **Nonce, HER şifreleme çağrısında YENİDEN üretilir:** `RandomNumberGenerator.Fill(nonce)` ile **`[KS-25]`** taze CSPRNG baytı. Sayaç, zaman damgası, `family_id` türevi veya sabit **YASAKTIR.** | **NIST SP 800-38D:** aynı anahtarla nonce tekrarı **hash alt anahtarının ifşasına** götürür (Appendix A) ve tekrar olasılığı **`2^-32`'yi aşmamalıdır** (§8). `[KS-25]` uzunluğundaki rastgele nonce, bu dilimin yazım hacminde bu sınırın **çok altındadır**. |
| **2** | **AAD (associated data) = `family_id ‖ token_hash`**, **`[KS-27]`**. Bayt kodlaması pinlidir: `family_id` **16 ham bayt** (`Guid.ToByteArray()` DEĞİL — **RFC 9562 big-endian** sırası), `token_hash` **32 ham bayt** (Base64 metin DEĞİL).  <!-- [KS-LITERAL: AAD bileşenlerinin BAYT KODLAMASI pini — `[KS-27]` bağı tarif eder, bileşen uzunluklarını değil; iki bağımsız implementasyonun aynı AAD'yi kurması için baytlar BİREBİR yazılmak ZORUNDADIR] --> | Şifreli blok **kendi satırına bağlanır**: bir saldırgan DB'de satır A'nın `successor_secret_enc`'ini satır B'ye kopyalarsa **çözme BAŞARISIZ olur** (`AuthenticationTagMismatchException`). AAD olmadan blok satırdan satıra taşınabilirdi ve K15-a'nın *"halef aynen döndürülür"* replay-idempotency'si **başka bir ailenin halefini** döndürebilirdi. |
| **3** | **Çözme başarısızlığı KAPALI düşer (fail closed):** `AuthenticationTagMismatchException` yakalanır, **`500` değil**, K3-C6'nın **yeniden-kullanım dalı** koşar (`reuse_detected` ⇒ aile düşer) ve olay **loglanır**. Ham istisna istemciye **çıkmaz**. | Bozuk/kurcalanmış şifreli blok, iyi niyetli bir hata değil **saldırı sinyalidir**; K3-B5'in tek-tip yanıt kuralı korunur. |

> **K3-K2'NİN MUAFİYETİ BU KALEME UYGULANMAZ ve bu açıkça yazılıyor.** K3-K2 *"kripto primitifini yazmayız, akışı yazarız"* der. **Ölçüldü (birincil kaynak, .NET `release/9.0`):** `public void Encrypt(ReadOnlySpan<byte> nonce, ReadOnlySpan<byte> plaintext, Span<byte> ciphertext, Span<byte> tag, ReadOnlySpan<byte> associatedData = default)` ⇒ **nonce'u sınıf üretmez, ÇAĞIRANDAN alır.** Nonce seçimi, belgenin **kendi tanımıyla akıştır** — primitif içi değil. Aynı gerekçe AAD için de geçerlidir: `associatedData` bir **çağıran kararıdır**.

**Kapılar:** **M50** (nonce sabitlenir ⇒ iki şifreleme aynı çıktıyı verir) · **M51** (AAD **KALDIRILIR** ⇒ satırdan satıra kopyalanan blok çözülebilir hâle gelir) · 🆕 **M57** (AAD'nin **BAYT KODLAMASI** — aşağıda). Düzen `[KS-26]` aynen korunur.

> 🔴 **v7 DÜZELTMESİ [B6-9 — BLOKER kapanıyor]: AAD'NİN BAYT KODLAMASI ARTIK KAPILI.**
> **Kırılan yer (kapı-6 ölçtü):** v6 kapıları *"M51 (AAD **kaldırılır/karıştırılır**)"* diye sayıyordu.
> **"Karıştırılır" formu hiçbir şeyi ölçmez:** AAD `token_hash ‖ family_id` sırasına çevrilse ya da
> `family_id` `Guid.ToByteArray()` ile yazılsa bile **şifreleme ve çözme AYNI KODU kullanır** ⇒ sistemin
> davranışı **hiç değişmez** ⇒ satırdan satıra kopyalanan blok yine çözülemez ⇒ **M51'in sinyali GEÇER**
> ⇒ mutant hayatta kalır. Kırılan şey davranış değil **INTEROP PİNİDİR** — ve K3-I5(2) onu PAZARLIKSIZ
> ilan ediyor (*"iki bağımsız implementasyonun aynı AAD'yi kurması için baytlar BİREBİR yazılmak ZORUNDADIR"*).
> **Belge tam bu sınıf için HKDF `info` etiketlerine M42b ALTIN VEKTÖRÜNÜ yazmıştı** (kapı-4 majör #13);
> **AAD'nin kardeş kapısı YOKTU** ve §3.1'in kapısız listesinde de yoktu.
>
> **🆕 M57 — AAD ALTIN VEKTÖRÜ [seviye `B`; numara K22-b'nin M57–M59 tamponundan].**
> **Mutasyon:** AAD'nin kuruluşu değiştirilir — (a) bileşen sırası `token_hash ‖ family_id` yapılır **VEYA**
> (b) `family_id` `Guid.ToByteArray()` (little-endian karışık) ile yazılır **VEYA** (c) `token_hash` ham
> bayt yerine Base64 metin olarak eklenir. **Her biri AYRI COMMIT'te koşulur** (M4/M36b kalıbı).
> **Kill sinyali:** *"pinli bir `(family_id, token_hash)` çifti için `BuildAad(...)` **tam olarak
> `[KS-27]`'nin tarif ettiği baytları** üretir — beklenen değer testte **onaltılık ALTIN VEKTÖR** olarak
> yazılıdır ve **RFC 9562 big-endian** sırasını pinler"* **FAIL**. *(M42b'nin birebir kardeşi: girdinin
> baytları yazılmadıkça iki bağımsız implementasyon aynı AAD'yi kuramaz.)*
>
> **⚠ M51'E EKLENEN PİN [aynı kalemin ikinci ayağı — kapı-6 MAJÖR olarak ayırmıştı]:** M51'in ikinci
> mutasyon formu (*"AAD yalnız `family_id` ile kurulur"*) için **A ve B satırlarının AYNI AİLEDE olması
> ZORUNLUDUR** ve bu artık testin **önkoşuludur**. Farklı aile seçilirse `family_id`'ler de farklı olur
> ⇒ çözme yine başarısız olur ⇒ o form da hayatta kalır. *(Kapı-6 red-team'i bu ayağı **tersine çevirdi**:
> aynı ailede mutant gerçekten **ölüyor**; kusur davranışta değil, **pinin yokluğundaydı.**)*

*Reddedilenler [adlandırılmış]:* **AAD'siz taze nonce** (NIST şartı karşılanır ama blok satıra bağlanmaz ⇒ *"başka ailenin halefi"* deliği açık kalır ve **adlandırılmış sapma** yazmak gerekirdi) · **sayaç tabanlı nonce** (GCM için NIST'in tercih ettiği yapıdır, ama **kalıcı sayaç durumu** gerektirir — tek konteynerde restart sonrası sayaç sıfırlanırsa **tam olarak yasaklanan tekrar** doğar; rastgele nonce bu durumu hiç kurmaz) · **K15-a'nın geri alınması** (nonce sorunu tümden yok olur ama kapı-3'te kilitlenen karar düşer ve **B1 yeniden açılır**).

**K3-I3 — GELİŞTİRME BOOTSTRAP'I: COMPOSE İLK AÇILIŞTA RASTGELE ANAHTAR ÜRETİR. [K14-b — bloker #8 kapanır]**
**Kırılan senaryo:** K3-I2 anahtarsız başlangıcı patlatıyor (doğru), K3-I1 gömülü anahtarı yasaklıyor (doğru) — ama **`dotnet user-secrets` klonla gelmez.** Değerlendirici `docker compose up` der, **hiçbir şey ayağa kalkmaz**; K14-e gereği web de aynı süreçten servis edildiği için **uygulama hiç görünmez**. ODEV §2 (*"kesinlikle çalışan bir uygulama; önce uygulamaya bakılacak"*) doğrudan vurulur. Compose dosyasına sabit anahtar yazmak ise **kırmızı çizgi #1** ihlalidir. **v2 bu ikilemi hiç kurmuyordu.**

**Karar:**
- Konteynerin giriş betiği, `ASPNETCORE_ENVIRONMENT=Development` **ve** anahtar dosyası yoksa, **CSPRNG ile `[KS-20]` üretip Base64'leyerek** git-ignore'lu bir dosyaya yazar: **`./.secrets/momentum-master.key`**, mount edilmiş bir volume'de. Sonraki açılışlar **aynı** anahtarı okur ⇒ mevcut oturumlar restart'ta düşmez — **ve K16-c sayesinde bu vaat JWT, CSRF ve halef şifrelemesinin ÜÇÜ için birden geçerlidir** (tek kök ⇒ tek dosya ⇒ tek yaşam döngüsü).
- **`Production` yolunda bu kod ASLA koşmaz.** Üretimde eksik anahtar **hâlâ patlar** (K3-I2 aynen geçerli).
- `.gitignore`'a `.secrets/` eklenir; `.env.example` yine bulunur (ortam değişkeni adlarını belgelemek için) ama **içinde anahtar yoktur**.
- **Dosya adı ve biçimi pinlidir** (K3-I2): tek satır, standart Base64, çözülmüş `[KS-20]`.

> **🔴 v4'ÜN BU MADDESİ VAR OLMAYAN BİR ARTEFAKTA ÇIPALIYDI — K22-a KAPATIYOR.**
> **Ölçüldü (oturum 21, Onur'un diskinden):** `find -iname "Dockerfile*"` ⇒ **0 sonuç**;
> `docker-compose.yml` **yalnız** `postgres:17-alpine` servisini tanımlıyor. ⇒ v4'ün *"konteynerin
> giriş betiği"* **yoktu**, `KON` seviyesi (M8b, M42c) **var olmayan bir şeyi** ısırtıyordu ve
> M8b'nin *"`docker run …` ile açılan konteyner"* kill sinyali **koşulamazdı**.
> **[KARAR — Onur, K22-a] API `Dockerfile` + giriş betiği + compose'a `api` servisi BU DİLİMİN İŞİDİR.**
> Bu, ODEV §8(4)'ün paketleme kalemini bu dilime **öne çeker** ve ODEV'e öyle yazılır. *Gerekçe:*
> değerlendirici uygulamayı **tek komutta** (`docker compose up`) ayağa kaldırır ⇒ ODEV §2'nin
> *"kesinlikle çalışan bir uygulama; önce uygulamaya bakılacak"* ölçütüne **doğrudan** hizmet eder;
> ayrıca `KON` **gerçek** olur ve M8b/M42c çıpalı kalır. **Giriş betiğinin sözleşmesi (pinli):**
> (1) `ASPNETCORE_ENVIRONMENT=Development` **ve** anahtar dosyası yoksa üret, aksi hâlde **ÜRETME**;
> (2) ürettiğini **`stdout`'a yazmaz** (sır loga düşmez, kırmızı çizgi #1); (3) `Production`'da
> anahtar yoksa **uygulamayı başlatır ve K3-I2'nin fail-fast'i patlatır** — betik kendi başına
> `exit` etmez, çünkü M8a'nın gözlemlediği şey **uygulamanın** çıkış kodudur.
> *Reddedilenler [adlandırılmış]:* **`KON`'u kapsam dışına almak** (en az iş; ama M8b tam olarak
> kapı-3'ün **B4 blokerini kapatmak için** `KON`'a taşınmıştı ⇒ geri almak **B4'ü yeniden açar**) ·
> **§3.1'e *"kapısız"* beyan** (en ucuz; ama dev bootstrap'ın ortam koşulu **ve** kök anahtarın
> restart kalıcılığı — kırmızı çizgi #1'e değen **iki mekanizma birden** — kapısız kalırdı).

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
> **🔴 v3 `UseRateLimiter`'I HİÇ ANMIYORDU [Ma-11]; v4 ONU YANLIŞ GEREKÇEYLE YERLEŞTİRDİ [B-2 — K19-b].** Blok `UseForwardedHeaders`'ın **yokluğunu** bile yazıyordu ama §2-J'nin tamamının dayandığı çağrıyı yazmıyordu. **Yerin tek gerçek sonucu vardır ve o da ölçülmüştür:**
> - **`UseRouting`'den ÖNCE** konursa uca bağlı politikalar (`RequireRateLimiting`) **hiç çözülemez** ⇒ **hiçbir hız sınırı uygulanmaz** ⇒ `[KS-10]`/`[KS-11]`/`[KS-12]` ayrımı (K16-b) yalnız kaybolmaz, **tavanların kendisi kaybolur**.
> - **Birincil kaynak — `RateLimitingMiddleware` (aspnetcore `release/9.0`), birebir:** *"If this endpoint has no EnableRateLimitingAttribute & there's no global limiter, don't apply any rate limits."* ve `if (enableRateLimitingAttribute is null && _globalLimiter is null) { return _next(context); }`
>
> **🔻 GERİ ÇEKİLEN İDDİA [§0.4'e işlendi]:** v4 burada ikinci bir gerekçe yazıyordu — *"`UseStaticFiles`'tan ÖNCE konursa Flutter web build'inin onlarca asset isteği kovayı ilk saniyede tüketir"*. **Bu iddia YAPISAL OLARAK İMKÂNSIZDIR:** üç politikanın **üçü de uç-bazlıdır** (`RequireRateLimiting`) ve bu belgede **küresel (global) limiter kararı YOKTUR** ⇒ yukarıdaki kaynağa göre statik dosya isteği **hiçbir kovayı tüketemez**. İddia **geri çekilir**; **kararın kendisi (statik dosyalar hız sınırının dışındadır) DEĞİŞMEZ** — ama gerekçesi artık *"asset'ler kovayı tüketir"* değil, **"uç-bazlı politika statik dosya uçlarına hiç iliştirilmez; onlar Argon2 çalıştırmaz, DB'ye dokunmaz"**dır.
>
> **Kapı: M46 — YENİDEN ÇIPALANDI [K19-b].** Mutasyon: `UseRateLimiter`, **`UseRouting`'den önceye** alınır. Kill sinyali: *"`[KS-10]`'un tavanını aşan `/login` isteği `429` **ALIR**"* **FAIL**. Seviye `TS`. **Neden bu çıpa gerçek:** eski mutasyon (`UseStaticFiles`'tan önce) baseline'da da mutasyonda da **aynı** sonucu veriyordu ⇒ test **hiçbir zaman kırılamazdı** = kör kapı. Yeni mutasyonda uç çözümlemesi kaybolur, politika bulunamaz, `429` **hiç doğmaz** ⇒ gözlemlenebilir fark **gerçektir**.

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
| **1a** | Sabit pencere — **`/login` + `/register`** (Argon2 yolu) | **middleware** | `RemoteIpAddress` ile **anahtarlanır**, ama tek konteynerde **fiilen KÜRESELDİR** (aşağıda) | **`[KS-10]`**, `QueueLimit=0` | Maliyet/DoS **tavanı** | Botnet/proxy havuzu · **kullanıcı ayrımı** (küresel olduğu için) |
| **1b** | Sabit pencere — **`/refresh`** (Argon2 **KOŞMAZ**) | **middleware** | aynı | **`[KS-11]`**, `QueueLimit=0` | Yenileme fırtınası | — |
| **1c** | Sabit pencere — **`/logout` + `/logout-all`** | **middleware** | aynı | **`[KS-12]`** | DB yazma fırtınası (K3-J6) | — |
| **2** | Sabit pencere — yalnız `/login` | **Application handler** (K14-f · K18-a) | **normalize e-posta** | **`[KS-13]`** | **Tek hesaba parola deneme** | **DoS'u KORUMAZ** — anahtarı saldırgan seçer |
| **3** | Eşzamanlılık limiti — **her Argon2 çağrısı (hash VE verify)** | **Application handler** (K18-a) | küresel (partition yok) | izin = **`[KS-14]`**, kuyruk = **`[KS-15]`** | **Argon2'nin bellek/CPU çarpanı** | — |

> **🔴 KONTROL 1 TEK KONTEYNERDE FİİLEN KÜRESEL BİR TAVANDIR — v3'ÜN İDDİASI ÖLÇÜMLE YANLIŞLANDI [B2 / K15-b].**
> v3 (K3-L4/K14-e) birebir şöyle diyordu: *"`RemoteIpAddress` **GERÇEK** istemci IP'sidir ⇒ `UseForwardedHeaders` hiç gerekmez ve K3-J2(1) yaşar. Bu, blokerin en sinsi ayağını **doğmadan** kapatır."*
> **ÖLÇÜM — GERÇEK KOŞU, Onur'un makinesi, 25 Tem 2026 (Docker 29.6.1 / compose v5.3.0):** `docker run --rm -d -p 18080:80 nginx:alpine` → üç ayrı yoldan istek → nginx access log: **`http://localhost` → `172.17.0.1`** · **`http://127.0.0.1` → `172.17.0.1`** · **`http://192.168.0.41` (LAN) → `172.17.0.1`**. Konteyner içi yönlendirme: `default via 172.17.0.1 dev eth0`. **Üç yolda da köprü ağ geçidi; gerçek istemci IP'si hiçbirinde yok** — LAN yolu bile kurtarmıyor. Mekanizma: Docker port yayımlama bir **NAT**'tır; resmî `dockerd` referansı `--userland-proxy`'yi *"Use userland proxy for **loopback traffic**"* varsayılan **`true`** olarak tanımlar, Docker Desktop'ta trafik ayrıca VM sınırından geçer. **Üstelik K3-L4 zaten `http://localhost:PORT` kullanımını ZORUNLU kılıyor** ⇒ trafik tam olarak proxy'lenen yola sokuluyor.
> **[KARAR K15-b] İDDİA GERİ ÇEKİLİR, SINIR ADLANDIRILIR; K14-e DURUR.** Tek konteyner + reverse-proxy yok kararı **korunur** — CORS ve `SameSite` gerekçeleri ölçümden bağımsız olarak sağlamdır. Geri çekilen yalnız **yanlış çıkan ayaktır**. Belgenin bugünkü dürüst ifadesi şudur:
> ***"Bu dağıtımda kontrol 1 KÜRESEL bir hız sınırıdır. Kod `RemoteIpAddress` ile anahtarlanır (partitioner değişmez), ama tek konteynerde tüm istekler köprü ağ geçidinden geldiği için pratikte TEK partition oluşur. Kontrol 1 bir kullanıcı-ayrımı mekanizması DEĞİL, servisin toplam Argon2 yüküne konmuş bir TAVANDIR."***
> **Bunun dört doğrudan sonucu vardır ve dördü de bu belgede uygulanmıştır:**
> 1. **Sayılar yükseltildi ve `/refresh` ayrıldı** (K16-b — yukarıdaki tablo). v3'ün 10/5 dk'lık ortak kovası, K3-L2 gereği **her F5 bir `/refresh` olduğu için** iki kullanıcılı işbirliği demosunu ODEV §2'nin ortasında kesiyordu (B3).  <!-- [KS-LITERAL: v3'ün geçersiz kılınmış sayısının tarihsel kaydı] -->
> 2. **K3-J5'in *"tavanı anlamlı kılan şey IP penceresidir"* cümlesi yanlıştır ve düzeltildi.**
> 3. **§6 Risk #5 düzeltildi**, **Risk #14** eklendi (*tek istemci tüm tavanı tüketebilir*).
> 4. **Argon2'yi asıl koruyan kontrol 3'tür (eşzamanlılık), kontrol 1 değil.** Bu, v3'te de doğruydu ama kontrol 1'e fazla kredi veriliyordu.
> *Reddedilenler [adlandırılmış]:* **reverse-proxy'ye dönüş** (gerçek IP gelir; bedeli `UseForwardedHeaders` + `KnownProxies/KnownNetworks` yapılandırması **ve** M11/M23'ün `X-Forwarded-For` enjekte eden testlere taşınması — dağıtım tek birim olmaktan çıkar, K14-e yeniden açılır) · **IP anahtarını tamamen bırakıp açıkça küresel bir limiter yazmak** (en dürüst kod ama **R2'nin kapısı olan M23'ün konusu kalmaz**: *"partition'ı e-postaya çevirme"* mutasyonu anlamsızlaşır ⇒ bir kör kapıyı kapatmak için başka bir kapıyı silmek olurdu).
> **[R2'NİN TOPOLOJİK İKİZİ, ADIYLA]** v1'in hatası *"partition'ı **saldırgan** seçer"*di; buradaki olgu *"partition'ı **Docker'ın kendisi** siler"*dir. İkisi de aynı sınıftır: **bir kontrolün anahtarı, o kontrolü yazan kişinin denetiminde değilse kontrol yoktur.**

> **[Ma-1 kapatıldı]** v2 kontrol 3'ü *"parola **doğrulama** işi"* diye tanımlıyordu ⇒ `/register`'ın Argon2 **hash**'i kapsam dışı kalıyordu ve Risk #4'ün telafi cümlesi `/register` yolunda yanlıştı. Tanım artık **"her Argon2 çağrısı"**dır.

> **🔴 v2'NİN KONTROL 2'Sİ SEÇİLEN MEKANİZMAYLA İNŞA EDİLEMİYORDU [bloker #5].** E-posta istek **gövdesindedir**; `RateLimiterOptions.AddPolicy` partitioner'ı **senkron** bir delegedir (`Func<HttpContext, RateLimitPartition<T>>`; üç aşırı yüklemenin **üçü de** senkron, `ValueTask` varyantı yok) ⇒ gövde `await` edilemez, `EnableBuffering` + senkron okuma Kestrel'in `AllowSynchronousIO=false` varsayılanına çarpar. Builder'ın kaçınılmaz seçimi limiti handler'a taşımaktı — **ve bu, v2'nin K3-J3'teki bağlayıcı sırasını sessizce bozardı.**
> **[K14-f] Karar:** kontrol 2 **açıkça `Momentum.Application` handler'ının içindedir** (K18-a); DI'dan alınan bir `PartitionedRateLimiter<string>` ile koşar (gövde o noktada zaten deserialize edilmiştir). *Reddedilenler:* anahtarı bir başlıktan almak (**anahtarı istemci seçer ⇒ R2'nin kapattığı hata sınıfı aynen geri gelir**) · kontrol 2'yi tamamen kaldırmak (tek hesaba yavaş parola denemesi sınırsız kalırdı).

> **🔴 KONTROL 2'NİN KAPISI v3'TE HİÇ YOKTU — B7 KAPANIYOR.** K14-f, bloker #5'i kapatmak için **kilitlenen çataldı**; ama v3'ün mutant tablosunda **kontrol 2'yi kaldıran hiçbir mutant yoktu** (M11 → kontrol 1, M22 → kontrol 3, M23 → IP partition) **ve §3.1'in "mutantsız olduğu açıkça yazılanlar" listesinde de geçmiyordu.** §3 *"bu tablo … spec'in mutant listesinin **kimlik-çekirdeği yarısıdır**"* diyerek, §3.1 *"**bu liste, tablonun tamlık iddiasının sınırıdır**"* diyerek **tamlık iddia ediyordu** ⇒ *"kapattım"* denen bir bloker, **kapısız bir mekanizmayla** kapatılmış sayılıyordu. Bu, belgenin kendi doktrininin (**KÖR KAPI YOK**) ihlaliydi.
> **Kapı: M41 — iki ayaklı.** Mutasyon: handler'daki e-posta penceresi kaldırılır.
> 1. *"**aynı** normalize e-posta ile **6.** `/login` denemesi `429` alır **ve** `problem.Extensions[\"limit\"] == \"email\"`"* **FAIL**.
> 2. *"**aynı IP'den farklı e-postalarla** gelen, `[KS-13]`'ten **bir fazla** sıradaki istek `429` **ALMAZ**"* **FAIL** — bu ikinci ayak **R2'yi de korur**: kontrol 2'nin anahtarının e-posta olduğunu, IP olmadığını ısırtır. *(Kontrol 1'in tavanına çarpmamak için test **`[KS-13]`+1 istekle sınırlıdır**; `[KS-10]` tavanının altındadır.)*  <!-- v7/oturum-26 [kapı-6 majör #7]: bu iki literal ÖNCE ham `6` yazılıydı ve `[KS-13]`+1'dir; araç `[KS-13]`'ü *"tek haneli literal — metinde ayırt edilemez"* diye KAPSAM DIŞI bıraktığı için hiçbir zaman ihbar edilmedi ⇒ §3.1'in *"çevrilecek sınır-değer literali yoktu"* iddiası aracın KENDİ KÖRLÜĞÜNE dayanıyordu. K30-b gereği atfa çevrildi. -->
> Seviye **TS**. Önkoşul: kontrol 1'in tavanı bu testte tetiklenmemelidir (K16-b sayıları bunu zaten sağlar).

**R2'nin kırdığı yer, kayda geçmeye devam ediyor:** v1'in anahtarı **IP + e-posta birleşimiydi**. Saldırgan her istekte rastgele bir e-posta yazarak **her seferinde yeni bir partition** yaratır ⇒ sayaç **hiç dolmaz**, ama her istek **270 ms + 19 MiB sahte Argon2** yakar. **Ayrım şudur: DoS'u durduran (1) ve (3)'tür; (2) hesabı korur ve bir DoS kontrolü olarak SAYILMAZ.**  <!-- [KS-LITERAL: gerçek koşu ölçüm kaydı] -->

**K3-J3 — BAĞLAYICI SIRA [K14-f ile yeniden yazıldı; K18-a ile KATMAN ADLARI PİNLENDİ].**
```
/login  ve  /register
  Api boru hattı:        IP penceresi (kontrol 1, [KS-10])          ← UseRateLimiter
       ↓  geçerse
  Application handler:   gövde deserialize + girdi doğrulama (K3-B6)
       ↓
  Application handler:   e-posta penceresi (kontrol 2, [KS-13])
       ↓
  Application handler:   eşzamanlılık limiti (kontrol 3, [KS-14]/[KS-15])
       ↓
                         gerçek VEYA sahte Argon2   ← limit aşılmışsa BURAYA HİÇ GELİNMEZ
       ↓  reddedilirse
  Api uç delegesi:       RateLimitedException → ProblemDetails + Retry-After   (K18-a, M49)

/refresh
  Api boru hattı:        IP penceresi (kontrol 1, [KS-11])          ← UseRateLimiter
       ↓
  Api uç delegesi:       X-Client-Kind okunur (K3-L10) → girdi kanalı seçilir
       ↓
  Application handler:   ⚠ CSRF DOĞRULAMASI (yalnız web kanalı, K3-L3)
       ↓  GEÇERSE
  Application handler:   tüketim UPDATE'i (K3-C6, atomik)
```
> **🔴 `/refresh`'TE CSRF'İN SIRASI v4'TE YAZILMAMIŞTI — kapı-4 majör #7 kapanır. [PAZARLIKSIZ]**
> `/login` için bağlayıcı sıra vardı, `/refresh` için **yoktu**. **Kırılan senaryo:** CSRF doğrulaması tüketim `UPDATE`'inden **sonra** koşarsa, CSRF'i geçersiz olan bir istek token'ı **zaten tüketmiş** olur. Meşru istemci token'ı yeniden dener; `[KS-4]` içindeyse replay-idempotency onu kurtarır, **`[KS-4]` aşılmışsa `reuse_detected` doğar ve AİLE DÜŞER** — yani bir CSRF hatası, kullanıcının oturumunu **öldürür**. **Karar:** CSRF doğrulaması **tüketimden ÖNCE** koşar ve başarısızlığında **hiçbir yazma yapılmaz** (`403`, token **tüketilmez**).
> **Kapı: M53** — mutasyon: CSRF doğrulaması tüketim `UPDATE`'inden sonraya alınır. Kill sinyali: *"geçersiz CSRF token'ı ile yapılan `/refresh`, `403` döner **ve AYNI yenileme token'ı ile, saat `[KS-4]`'ü AŞACAK KADAR ilerletildikten sonra yapılan geçerli-CSRF'li `/refresh` `200` döner**"* **FAIL** (mutasyonda ikinci istek `401` + `reuse_detected` alır). Seviye `TC`.

Sıra bağlayıcıdır: limit aşılmışsa **hiç Argon2 koşmaz**. Aksi hâlde K3-B5'in zamanlama savunması kendisini bir **DoS amplifikatörüne** çevirirdi.

> **🔻 ADLANDIRILMIŞ SAPMA — NIST SP 800-63B-4 §3.2.2'NİN `SHALL`'I KARŞILANMIYOR [kapı-4 majör #6].**
> **Birebir:** *"the verifier **SHALL** limit consecutive failed authentication attempts on a single account to no more than 100 by disabling that authenticator."* Bu belge **hesap devre dışı bırakmaz** — kontrol 2 (`[KS-13]`) bir **throttle**'dır: pencere dolunca sayaç sıfırlanır, hesap **kilitlenmez**. ⇒ ardışık başarısız deneme sayısı, saldırgan yeterince beklerse **100'ü aşabilir.**
> **Neden bilinçli olarak sapılıyor:** hesabı devre dışı bırakmak, bu ödevde **kurtarma yolu olmayan** bir kilit yaratır — parola sıfırlama ve e-posta doğrulama **ODEV §6.1 ile kapsam dışıdır** ⇒ kilitlenen değerlendirici hesabını **hiçbir şekilde** açamaz ve ODEV §2'nin *"kesinlikle çalışan uygulama"* ölçütü doğrudan vurulur. Ayrıca aynı NIST bölümü throttling'i **kilitlemenin karşıtı** olarak konumlandırır (*"reduce the likelihood that an attacker will lock the legitimate claimant out"*).
> **Bu sapma bir eksiklik değil, ADLANDIRILMIŞ BİR KARARDIR** — ve v4'ün kusuru sapmanın kendisi değil, **hiç anılmamış olmasıydı**: belge diğer her sapmayı adlandırıyordu. Kapsam dışı bırakılan kurtarma yolu geldiğinde (ADR 0004 veya sonrası) bu madde **yeniden açılır**.

**K3-J4 — REDDİN YANITI: `429` AÇIKÇA YAZILIR; VARSAYILAN `503`'TÜR. [bloker #7 kapanır]**
> **🔴 ÖLÇÜM (dotnet/aspnetcore `release/9.0`, `RateLimiterOptions.cs`):** `public int RejectionStatusCode { get; set; } = StatusCodes.Status503ServiceUnavailable;` — XML doc birebir *"Defaults to StatusCodes.Status503ServiceUnavailable"*. Durum kodu `OnRejected` **çağrılmadan önce** set edilir; `OnRejected` onu ezebilir.
> **v2 `429` kararını verdi ama override'ı YAZMADI** ⇒ (a) gerçekte `503` dönerdi, (b) `Retry-After` **otomatik değildir**, (c) `503` semantik olarak yanlıştır ve Flutter istemcisinin retry politikasını *"sunucu çökmüş"* diye yorumlatır, (d) **M11/M22/M23'ün kill sinyalleri baseline'da kırmızı doğardı = ölü tuzak.** Bu, §4'teki kendi manşet tezinin (*"bir ADR'nin işi sessiz varsayılanların hangisinin kabul edildiğini yazmaktır"*) **birebir ihlaliydi** — `ClockSkew` için titizlikle yapılan iş burada yapılmamıştı.

**Karar — İKİ AYAK, ÇÜNKÜ `OnRejected` HANDLER LİMİTLERİNİ KAPSAMAZ [Ma-3, ölçüldü]:**

> **🔴 ÖLÇÜM (dotnet/aspnetcore `release/9.0`):** `OnRejected` ve `RejectionStatusCode` **`RateLimiterOptions`'ın üyeleridir** ve yalnız `RateLimitingMiddleware` onları çağırır (`context.Response.StatusCode = _rejectionStatusCode;` + `await thisRequestOnRejected(...)`). **Handler içinde koşan kontrol 2 ve kontrol 3'ü KAPSAMAZLAR** ⇒ v3'ün *"`limit == \"email\"` / `\"concurrency\"` değerleri `OnRejected` tarafından yazılır"* varsayımı yanlıştı ve **M22 baseline'da kırmızı doğardı = ölü tuzak.**

**(a) MIDDLEWARE AYAĞI** (kontrol 1a/1b/1c):
- `options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;` **açıkça yazılır** (varsayılan `503`'tür — aşağıdaki ölçüm).
- `OnRejected` **yazılır**: `Retry-After` başlığını **`FixedWindowLease`'in `MetadataName.RetryAfter`'ından** okur *(ölçüldü: **taşıyor**)*; tek tip `ProblemDetails` gövdesi üretir; `problem.Extensions["limit"] = "ip"` yazar.

**(b) APPLICATION AYAĞI** (kontrol 2 ve 3) — **middleware'in değil, `Application handler`'ın kendi sorumluluğudur**:
- **[K18-a · §2-M — PAZARLIKSIZ]** `Application handler`, lease alınamadığında **`RateLimitedException(Limit, TimeSpan, string)` FIRLATIR** ve **hiçbir ASP.NET tipine dokunmaz**. `429` durum kodunu ve `ProblemDetails` gövdesini **YALNIZ Api uç delegesi** üretir; gövde middleware ayağıyla **aynı şekildedir** (Api'deki ortak `RateLimitProblemFactory` üzerinden — **iki ayrı gövde şekli yazmak yasaktır**, çünkü M22/M23/M41 gövdeyi karşılaştırır).
- `problem.Extensions["limit"]` = **`"email"`** (kontrol 2) veya **`"concurrency"`** (kontrol 3).
- **`Retry-After`:** kontrol 2'de pencere süresinden hesaplanır; **kontrol 3'te YAZILMAZ** — çünkü ölçüldü: **`ConcurrencyLease` `MetadataName.RetryAfter` TAŞIMAZ** (yalnız `ReasonPhrase` taşır) ve eşzamanlılık reddi için anlamlı bir bekleme süresi **yoktur**. Bu bir eksiklik değil, **ölçülmüş bir sonuçtur** ve istemci sözleşmesinde (K3-L8/4) *"`Retry-After` yoksa üstel geri çekilme"* diye karşılanır.
- **(b) şıkkı kozmetik değildir:** M22/M23/M41'in *"hangi limit reddetti"* sorusunu ayırt etmesini sağlar (bloker #13).
- **Hesap KİLİTLEME YOKTUR** — kilitleme, saldırganın kurbanın hesabını kasten kilitlemesine izin verir ve K8-d ile kapsam dışıdır.

> **✅ v3'ÜN `[DOĞRULANMADI]` ETİKETİ KAPANDI — DOKTRİN YİNE KAZANDI.** v3, `ConcurrencyLease`'in `MetadataName.RetryAfter` taşıyıp taşımadığını **ölçmemişti** ve (a) şıkkını **koşullu** yazmıştı. Kapı-3 turunda kaynaktan ölçüldü: **`ConcurrencyLease` TAŞIMIYOR, `FixedWindowLease` TAŞIYOR.** ⇒ koşulluluk kalktı, karar **kesinleşti**, §6 Risk #12 **kapandı** ve §3.1'den ilgili muafiyet **düştü**. *Ölçülmemişi ölçülmemiş diye yazmanın bedeli bir satırlık koşulluluktu; kazancı, üç sürüm sonra hiçbir şeyin geri alınmamasıdır.*

**K3-J5 — ✅ KAPATILDI (v2'de `[DOĞRULANMADI]`, artık ÖLÇÜLDÜ).**
> **ÖLÇÜM (dotnet/runtime `release/9.0`, `DefaultPartitionedRateLimiter.cs`):** `private static readonly TimeSpan s_idleTimeLimit = TimeSpan.FromSeconds(10);` · timer periyodu `TimeSpan.FromMilliseconds(100)` · `if (idleDuration > s_idleTimeLimit) { _cacheInvalid = true; _limiters.Remove(rateLimiter.Key); _limitersToDispose.Add(...); }` + `await limiter.DisposeAsync()`.  <!-- [KS-LITERAL: dotnet kaynağından BİREBİR alıntı (`TimeSpan.FromSeconds(10)`)] -->

**Sonuç, abartısız yazılıyor:** atıl partition'lar **temizlenir** ⇒ *"rastgele e-postalarla sınırsız bellek büyümesi"* endişesi **geçersizdir**. Ama bu **"sıfır bellek" demek değildir**: tavan ≈ **istek hızı × `[KS-9]`** kadar canlı partition'dır.
> **🔴 v3'ÜN İKİNCİ CÜMLESİ DÜZELTİLİYOR [B2/K15-b].** v3 *"tavanı anlamlı kılan şey kontrol 1'in **IP penceresidir**"* diyordu. **Ölçüm bunu yalanladı:** tek konteynerde IP penceresi diye bir ayrım yoktur, kontrol 1 **küresel bir tavandır**. **Doğru ifade:** *"tavanı anlamlı kılan şey kontrol 1'in **küresel istek tavanıdır** (`[KS-10]` `/login`+`/register`) — bu tavan aynı zamanda canlı partition sayısının da üst sınırını verir."* İkisi birlikte okunur; tek başına hiçbiri yeterli değildir.

**K3-J6 — `/logout` ve `/logout-all` DA HIZ SINIRI KAPSAMINDADIR; NAT YANLIŞ-POZİTİFİ ADLANDIRILIR. [RT-M6 kapanır]**
- v2'de bu iki uç hız sınırı dışındaydı ⇒ çalınmış bir JWT ile **DB yazma fırtınası** (her `/logout-all` bir kullanıcının tüm ailelerine `UPDATE`) mümkündü. **Karar:** ikisi de kontrol 1'e dâhildir — **ayrı ve kendi sayacı olan** bir politika: **`[KS-12]`** [K16-b] (meşru kullanım tek hanelidir).  <!-- [KS-LITERAL: v2'nin geçersiz kılınmış durumunun tarihsel kaydı] -->
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
| **ömür** | **`Max-Age` = `[KS-3]`** (ailenin kalan `expires_at`'i; üst sınır `[KS-2]`) — oturum çerezi **DEĞİL** | Oturum çerezi olsaydı **tarayıcı kapanınca çıkış** olurdu = K11-f'in **reddettiği** "F5 = çıkış" şıkkının kardeşi. Her `/refresh`'te `Max-Age` **yeniden hesaplanır** (uzatılmaz — `expires_at` sabittir, K3-C2). |

Erişim token'ı web'de de **yalnız bellektedir** (sekme-yerel).
*Reddedilenler:* web'de yalnız bellek (F5 = çıkış) · her platformda `flutter_secure_storage` (web'de LocalStorage'a düşer ⇒ "secure" adı yanıltıcı olur, README'nin kendisi *"use at your own risk"* diyor).

**K3-L3 — CSRF: İKİ KATMAN; İKİNCİ HAT İMZALIDIR VE AİLEYE BAĞLIDIR. [RT-B2 — bloker #4 kapanır]**

> **🔴 v2'NİN İKİNCİ HATTI, TUTULMA GEREKÇESİ OLAN VEKTÖRE KARŞI GEÇERSİZDİ.** Saldırı: saldırgan kardeş bir alt alan adını ele geçirir (DNS takeover / unutulmuş statik site / oradaki bir XSS) → `Set-Cookie: csrf=SALDIRGAN; Domain=momentum.app; Path=/` yazar (**çerezler origin değil domain kapsamlıdır**) → kurbanı o alt alandaki bir sayfaya çeker → sayfa `/v1/auth/refresh`'i `X-CSRF-Token: SALDIRGAN` ile çağırır → `SameSite=Strict` yenileme çerezini **taşır** (istek same-site'tır) → sunucu çerez == başlık karşılaştırır → **EŞLEŞİR** → geçer.
> **OWASP birebir:** naif double-submit *"bypassable by an attacker who can write cookies on the target domain (e.g., via a vulnerable sibling subdomain, DNS takeover…)"* · *"For new code, use the **Signed** Double-Submit Cookie pattern… **The naive pattern is documented for reference only.**"*
> **Belgenin kendisi bu vektörü K3-L4 notunda adlandırıyor ve double-submit'i TAM DA ONA KARŞI tutuyordu.**

**Karar — üç ayak birlikte:**
1. **Birinci hat — `SameSite=Strict`:** klasik çapraz-site CSRF'ini kapatır.
2. **Yapısal ayak — `__Host-` öneki (K3-L2):** yenileme çerezine **ve** CSRF çerezine (`__Host-mct`) uygulanır ⇒ kardeş alt alan adı **bu çerezleri yazamaz**; saldırının birinci adımı **yapısal olarak** imkânsızlaşır.
3. **İkinci hat — İMZALI double-submit:** CSRF çerezinin değeri rastgele bir dize **değil**, `value = nonce + "." + Base64Url(HMAC-SHA256(K_csrf, nonce + "|" + family_id))`'dir.
   - **`nonce`'un entropisi ve kodlaması PİNLİ [kapı-4 majör #16]:** **`[KS-28]`** ham CSPRNG baytı (`RandomNumberGenerator.GetBytes`), tele **`Base64Url`, dolgusuz** çıkar. *(v4 yalnız `nonce` diyordu; uzunluğu, kaynağı ve kodlaması **hiçbir yerde** yazılı değildi ⇒ builder 4 baytlık bir sayaç da yazabilirdi ve M35 bunu **görmezdi**.)*
   - **CSRF token'ının ömrü PİNLİ:** çerez **`[KS-29]`** taşır. *(Yaşam döngüsü aşağıda: her `/login` ve her `/refresh` yanıtında yeniden set edilir ⇒ pratikte ömrü aileninkiyle birlikte yenilenir; ama `Max-Age`'in kendisi yazılmadan çerez **oturum çerezi** olur ve tarayıcı kapanınca kaybolur ⇒ soğuk açılışta web istemcisi `/refresh` yapamaz.)*
   - Sunucu, gelen çerezi **kendi `K_csrf`'iyle** (K3-I4) yeniden hesaplar ve `CryptographicOperations.FixedTimeEquals` ile karşılaştırır; ayrıca imzanın bağlandığı `family_id`, sunulan yenileme token'ının ailesiyle **aynı olmalıdır**.

**CSRF çerezinin yaşam döngüsü [Ma-9'un ikinci yarısı]:** `/login` ve her `/refresh` yanıtında **yeniden set edilir** (aile değiştiği veya döndüğü için); `HttpOnly` **değildir** (istemci okumalı); `SameSite=Strict`, `Secure`, `__Host-` önekli.

**ÇIKIŞTA HER İKİ ÇEREZ DE SİLİNİR [Ma-12 — v3'te yalnız CSRF çerezi siliniyordu].**
v3'ün cümlesi *"`/logout`'ta silinir"* **yalnız `__Host-mct`** içindi. **`__Host-mrt` unutulmuştu** ve `Path=/` gereği çıkıştan sonra **`[KS-2]`e kadar her isteğe takılmaya devam ederdi** — yaşam döngüsünü *"tam yazdım"* diye ilan eden bölümün son adımı eksikti. **Karar:** `/logout` ve `/logout-all` yanıtları **`__Host-mrt` ve `__Host-mct`'nin ikisini birden** `Max-Age=0` (ve `Expires` geçmiş tarih) ile siler; silme başlıkları çerezin **kendi öznitelikleriyle birebir aynı** (`Path=/`, `Secure`, `SameSite=Strict`, `__Host-` öneki) yazılır — aksi hâlde tarayıcı silmeyi **farklı bir çerez** sanar ve uygulamaz.
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
   - **Kırılan senaryo (saldırgan yok; aktör = değerlendiricinin kendisi):** K3-L2 gereği erişim token'ı web'de **yalnız bellektedir (sekme-yerel)** ⇒ **her F5 bir `/refresh`'tir**. v3'te `/refresh`, `/login` ve `/register` ile **tek politikada** ve **10 istek/5 dk** idi; B2 gereği partition **tek**. ODEV §4(b)-2 gerçek zamanlı işbirliği vitrini **iki eşzamanlı kullanıcı** ister: değerlendirici A'yı kaydeder+girer (2) → B'yi kaydeder+girer (4) → uçak modunu açıp kapatır, her seferinde F5 (5,6,7…) → iki pencerede birkaç yenileme (8,9,10) → **11. istek `429`**. v3'ün istemci sözleşmesi sonucu **yalnız ikiye** ayırıyordu (ağ hatası → çevrimdışı-yetkili · `401`/`reuse_detected` → oturum gerekli) ⇒ `429` **hiçbir dala düşmüyordu** ⇒ builder'ın en doğal seçimi (*"`401` değilse hata, hata ise oturum gerekli"*) **demonun ortasında giriş ekranı** üretirdi.  <!-- [KS-LITERAL: F5/`/refresh` anlatımı — kanonik sayı değil] -->
   - **Karar (iki ayaklı):** (i) **sunucu tarafı — K16-b**: `/refresh` **ayrı ve gevşek** bir politikaya alındı (**`[KS-11]`**), çünkü Argon2 **koşturmaz** ve `/login` ile aynı kovada olmasının hiçbir güvenlik gerekçesi yoktu; (ii) **istemci tarafı — bu dal:** ***`429` ve `5xx` GEÇİCİ hatalardır. İstemci `Retry-After` başlığına uyar (yoksa üstel geri çekilme, tavan `[KS-4]`), ÇEVRİMDIŞI-YETKİLİ KALIR ve "oturum gerekli" durumuna GEÇMEZ.*** Kuyruk çalışmaya devam eder; yalnız senkron duraklar — yani **ağ hatası dalıyla aynı davranış**, farklı gerekçeyle.
   - **Neden `401` ile aynı sepete konamaz:** `401`/`reuse_detected` *"bu kimlik artık geçerli değil"* der; `429` *"şu an değil, birazdan"* der. İkisini birleştirmek, **sunucunun kendi koruma mekanizmasının kullanıcıyı çıkışa sürüklemesi** demektir.
   - **Kapı: M-L9** (DART, `slice-3b`'ye devredilir): mutasyon — `429` dalı `401` dalıyla birleştirilir. Kill: *"`429` yanıtında istemci **çevrimdışı-yetkili kalır**, 'oturum gerekli'ye **GEÇMEZ** ve `Retry-After` süresi kadar bekler"* **FAIL**.
4. **🔴 DÖRDÜNCÜ DAL — AÇIKÇA ÇIKILMIŞ OTURUM: ÇIKIŞTA AKTİF PROFİL KAYDI TEMİZLENİR. [v7 — B6-6 BLOKER kapanıyor · K34-c, ŞEMA KARARI]**
   **Kırılan senaryo [kapı-6 ölçtü; paylaşılan makine, saldırgan yok]:** yukarıdaki 1. madde *"yerel DB **ağ olmadan** aktif profil kaydıyla açılır"* diyor ve bu kural **çıkış yapılmış olup olmadığına bakmıyordu.** `__Host-mrt` **`HttpOnly`** olduğu için (K3-L2) istemci *"kimliğim yok"* ile *"ağ yok"*u **ayırt edemez** ⇒ A çıkış yaptıktan sonra, uçak modunda açılan uygulama **A'nın aktif profil kaydını** bulur, `momentum_{A}.sqlite`'ı açar ve **A'nın görevlerini paylaşılan makinede gösterir.** Bu, bu belgenin **başka bir yerde ADIYLA reddettiği** senaryonun yerel-DB'deki hâlidir. K3-L8'in kendi *"`userId`'nin nereden geldiği BU BELGENİN işidir"* cümlesi gereği `slice-3b`'ye **devredilemez**.
   **Karar [PAZARLIKSIZ]:** `/logout` ve `/logout-all` yollarında — **sunucu yanıtı beklenmeden, ağ hatası olsa bile** — istemci **aktif profil kaydını TEMİZLER.** Soğuk açılışta kayıt **yoksa** hiçbir kullanıcının DB'si açılmaz ve akış *"kimlik yok"* dalına düşer (giriş ekranı). ⇒ *"Ağ yok"* ile *"kimlik yok"* arasındaki ayrım artık **HttpOnly çereze değil, istemcinin kendi kalıcı kaydına** dayanır.
   **🔴 YEREL DB DOSYASI SİLİNMEZ — K11-g ve kırmızı çizgi #4 KORUNUR:** düşen şey **yalnız *"aktif kullanıcı"* işaretçisidir**; `momentum_{userId}.sqlite` **diskte kalır** ve gönderilmemiş kuyruk **kaybolmaz** (A yeniden girdiğinde devam eder — K3-L7'nin (b) sonucu aynen geçerlidir).
   **Şema sonucu [adlandırılmış bedel]:** *aktif profil* alanı istemci ayar deposunun (drift/`shared_preferences`) **şemasına girer**; **temizlenmesi kapısızsa bu bloker aynen geri döner** ⇒ **kapı ZORUNLUDUR:**
   **Kapı: 🆕 M-L10** (`DART`, **`slice-3b`'ye devredilir**): mutasyon — çıkış yolundan aktif profil kaydının temizlenmesi kaldırılır. **Kill sinyali, İKİ AYAK:** *"çıkış sonrası **uçak modunda** yeniden açılışta **hiçbir kullanıcının DB'si açılmaz** ve *kimlik yok* dalına düşülür"* **FAIL** · *"aynı senaryoda `momentum_{A}.sqlite` **diskte VARDIR** ve A yeniden girdiğinde gönderilmemiş kuyruğu **duruyordur**"* **FAIL**. İkinci ayak zorunludur: aksi hâlde *"çıkışta her şeyi sil"* mutasyonu da birinci ayağı geçerdi ve **kırmızı çizgi #4'ü sessizce ihlal ederdi.**
   ⚠ **BU EKLEMENİN ARAÇ SAYAÇLARINA ETKİSİ ÖLÇÜLDÜ [26 Tem 2026, oturum 26 — tahmin edilmedi, KOŞULDU]:** `alt_madde` sayacı **bir arttı** (`K3-L8(4)` eklendi) · `mutant` sayacı **iki arttı** (M57 + M58) · `devredilmiş` **DEĞİŞMEDİ** — çünkü araç `devredilmiş`i **KARAR kimliği** düzeyinde sayar ve `K3-L8(4)` bir **alt maddedir**, ayrı bir karar değildir. *(Bu satır ilk yazıldığında **"devredilmiş 5 → 6"** diye tahmin ediliyordu; **ölçüm onu yanlışladı** ve satır düzeltildi — belgenin kendi §4 kuralının kendisine uygulanmış hâli.)* **§3.1'in TAM yeniden ölçümü (dağılım cümleleri dâhil) yine v7'nin BİR SONRAKİ turuna aittir** — K37-a'nın adlandırılmış bedeli.
5. *(Çevrimdışı kullanıcının hangi **ekranı** göreceği `slice-3b`'nin işidir; `userId`'nin **nereden geldiği** bu belgenin işidir — §1 dilimi zaten "bir ŞEMA kararıdır" diye tanımlıyor.)*

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
  - **M28** — mutasyon: web modunda yenileme token'ı gövdeye **de** eklenir. Kill sinyali: *"`X-Client-Kind: web` ile gelen `/login` ve `/refresh` yanıtlarının gövdesi yenileme token'ını **hiçbir biçimde** içermez"* **FAIL**. **Sinyal B5 gereği güçlendirildi:** test (i) gövdeyi **JSON olarak ayrıştırır ve tüm dize değerlerini ÖZYİNELEMELİ tarar**, (ii) ayrıca **ham gövde metnini** token'ın **hem düz hem JSON-kaçışlı** biçimi için tarar — **kaçışlı biçim artık PİNLİDİR ve ölçülmüştür:** `+` → **`\u002B`** (baytlar `92 117 48 48 50 66`), `/` → `\u002F`. *(v4 yalnız "JSON-kaçışlı biçimi de tara" diyordu ve belgede `u002` **hiç geçmiyordu** ⇒ tarayıcı **hangi diziyi arayacağını bilmiyordu**; kapı-4 majör #2.)* *(Token `Base64Url` olduğu için kaçış yapısal olarak beklenmez — ama tarama yine de yapılır: kodlama kararı bir gün değişirse kapı sessizce körleşmesin.)*
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
| **`users` kalıcılığı (kayıt/okuma)** | **`IUserStore`** | Infrastructure | `Npgsql`/`Dapper` **yalnız** Infrastructure | mevcut K-A1 ailesi |
| **Kontrol 2 — e-posta penceresi `[KS-13]`** | **`ILoginAttemptWindow`** | Infrastructure (bellek-içi, tek instance) | — | — |
| **Kontrol 3 — eşzamanlılık limiti `[KS-14]`/`[KS-15]`** | **`IPasswordHashConcurrencyLimiter`** | Infrastructure (`SemaphoreSlim`) | — | — |
| **Ret → `ProblemDetails` ÇEVİRİMİ** | *(port YOK — bilinçli)* | **Api** (`RateLimitProblemFactory`) | **`Microsoft.AspNetCore.Mvc.ProblemDetails` YALNIZ Api'de** | **`Microsoft.AspNetCore.*` Application'da görünmez (M32b) + M49** |

> **🔴 "HANDLER" HANGİ KATMAN — v4 BUNU HİÇ YAZMAMIŞTI [K18-a, bloker B-4 kapanır].**
> **Ölçülen çelişki:** v4 kontrol 2 ve 3 için *"handler içi"* diyordu, ama **ADR 0001 bu kelimeyi İKİ ANLAMDA kullanıyor** — satır 27 *"`Momentum.Application` | **CQRS handler**"* (= Application) ve satır 80 K-H1 *"**Api endpoint/handler** ⊥ Infrastructure somut tipleri"* (= Api). v4 hangisini kastettiğini **hiçbir yerde** yazmıyordu. Bu bir yazım kusuru değil **karar boşluğuydu**: K3-J4(b) reddin yanıtını *"handler'da `ProblemDetails` üretilir"* diye kuruyordu ve **ölçüldü** (birincil kaynak, aspnetcore `release/9.0`): `ProblemDetails.cs` birebir `namespace Microsoft.AspNetCore.Mvc;` ⇒ **dal (a)'da (Application) v4'ün KENDİ YENİ YAZDIĞI `M32b` kuralı gerçek kodda ihlal edilirdi ve `M32b`'nin baseline'ı KIRMIZI doğardı.**
>
> **[KARAR — Onur, K18-a] KONTROL 2 VE 3 `Momentum.Application`'DA (CQRS handler) KALIR; `ProblemDetails`'E ÇEVİRİM `Momentum.Api`'DE YAPILIR. [PAZARLIKSIZ]**
> Application handler'ı **kendi hata tipini fırlatır** — `RateLimitedException(Limit limit, TimeSpan retryAfter, string window)`; bu tip **`Momentum.Application`'da** tanımlıdır ve **hiçbir ASP.NET tipi taşımaz** (`Limit` bir `enum`'dır: `Ip` · `Email` · `Concurrency`). **Api katmanı** onu `ProblemDetails`'e çevirir ve `Retry-After` başlığını yazar.
> ⇒ **`M32b` kuralı DELİNMEZ** ve N-katmanlı disiplin ödevin **vitrini** olur.
>
> **BU BELGEDE "HANDLER" KELİMESİNİN KULLANIMI [PAZARLIKSIZ]:** bundan sonra **her geçtiği yerde**
> **`Application handler`** (CQRS, `IRequestHandler<,>`) ya da **`Api uç delegesi`** (minimal API)
> diye **açıkça** yazılır. Çıplak *"handler"* kelimesi bu belgede **kullanılmaz**.
>
> **Yeni kapı — `M49`:** *"`ProblemDetails` çevirimi Api'den Application'a taşınır (ör. `RateLimitedException` yerine handler doğrudan `ProblemDetails` döndürür)"* ⇒ kill sinyali: ***"`M32b`'nin NetArchTest kuralı (`Microsoft.AspNetCore.*` ⊥ Application) KIRMIZI olur"*** — yani bu mutant, **başka bir kapının ısırdığını** ısırtır. Seviye **`NA`**.
>
> *Reddedilenler [adlandırılmış]:* **her şeyi Api'de yapmak** (en ucuz ve §3.2(4)'ün *"minimal API"* pini ile birebir uyumlu; ama auth dilimi ADR 0001 K-B1'in **CQRS desenini fiilen atlar** ⇒ denetçi *"neden tam da bu dilim desen dışı"* diye sorar) · **Application'da yapıp `M32b`'yi gevşetmek** (en az iş; ama **bu turda yeni yazılan bir kural doğar doğmaz delinir** ⇒ kapı-5 ilk oraya bakar).

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

> **NUMARA SÖZLEŞMESİ [K22-b ile GÜNCELLENDİ — K16-d'nin yerini alır]:** bu belge **M1–M53** aralığını kullanır (**M2·M3·M9·M10·M20 → 0004'e aittir**, burada yazılmaz; **M13 → VOID**). **M54 · M55 · M56 v6'da TÜKETİLDİ** (salt tazeliği · HKDF alan ayrımı · sızmış-parola listesi — K28-c/d). **🔴 v7 GÜNCELLEMESİ: TAMPONDAN İKİ NUMARA TÜKETİLDİ** — **M57** (AAD altın vektörü, B6-9 · K36) ve **🆕 M58** (PHC savunmacı dalında sahte-hash doğrulaması, B6-D · bu tur) ⇒ **bu belgenin aralığı artık `M1–M58`'dir ve REZERV YALNIZ `M59`'DUR.** *(Bunlar HARFLİ AYAK olarak yazılMADI: K16-d'nin kuralı gereği **kendi başına bir mekanizma olan kapı, sahte bir ikinci ayak gibi gösterilemez** — hepsi bağımsız mekanizmadır.)* **`M60` pini DEĞİŞMEDİ ve çakışma YOKTUR** (`M58 < M60`); ama **tampon bir numaraya indiği için bir sonraki yeni mekanizma `M59`'u tüketir ve ondan sonrası `M60` pinini yeniden tartmayı ZORUNLU kılar** — bu, kapı-7'ye devredilen adlandırılmış bir sınırdır. **ADR 0004'ün YENİ mutantları artık `M60`'tan başlar** — v3'ün `M40` pini de K16-d'nin `M50` pini de **geçersizdir**. *Gerekçe (K16-d'nin kendi gerekçesi, hâlâ geçerli):* **0004 bugüne kadar hiçbir numarayı tüketmedi** ⇒ pini taşımak **bedelsizdir**. *Reddedilen [adlandırılmış]:* v5'in dört yeni mekanizmasını (**M49** katman çevirimi · **M50** nonce · **M51** AAD · **M52** e-posta politikası · **M53** `/refresh` CSRF sırası) **harfli ayak** gibi yazmak — K16-d'nin **açıkça reddettiği** yol: kendi başına bir mekanizma olan kapıyı sahte bir *ikinci ayak* gibi gösterir ve denetçi bunu bulur.

> **🔻 ÇOKLU-ASSERT MUTANTLARI İÇİN PAZARLIKSIZ KURAL [kapı-4 majör #9 kapanır].**
> Kapı-4, dört mutantın (`M41`(2) · `M43`(3) · `M31`(4) · `M36`'nın 7 assert'inden 5'i) **kendi mutasyonu
> altında ÖLMEDİĞİNİ** ölçtü: mutasyon uygulansa bile o ayak **yeşil kalıyordu** ⇒ ayak bir kapı değil,
> bir **süstü**. Bu, `M31`'in e-posta ayağıyla (B-6) **aynı hata sınıfıdır**.
> **KURAL:** *çok assert'li bir mutant satırında **HER ayak, o satırın mutasyonu altında ÖLMEK ZORUNDADIR.***
> Ölmeyen ayak **iki seçenekten birine** gider: (a) kendi mutasyonuyla **ayrı bir mutant** olur; ya da
> (b) kill sinyalinden çıkarılıp **`önkoşul`** ya da **`değişmez`** diye yeniden adlandırılır — çünkü
> ölçtüğü şey mutasyon değil, **testin kurulumudur**. **Üçüncü seçenek yoktur.** Bu kural,
> `GOREV-slice-3c-auth` spec'ine **madde olarak** geçer ve builder her çok-ayaklı mutantta
> ayak-ayak baseline+mutasyon koşumunu **KANIT'a yazar**.

> **TEST SEVİYESİ [D3 majörü + B4 kapatılıyor]:** v2'nin *"saf çekirdek DB'siz kanıtlanır"* iddiası tutmuyordu — canlı mutantların çoğu DB istiyor. Sütun eklendi ki **spec, hangi test altyapısının hangi mutant için gerektiğini tahmin etmek zorunda kalmasın.** Kısaltmalar: **B** = saf birim · **D** = derleme (analizör) · **TS** = `TestServer` entegrasyonu · **TC** = Testcontainers (gerçek Postgres) · **NA** = NetArchTest · **DART** = istemci birim testi (`slice-3b`) · **DART-WEB** = istemci **tarayıcı** testi (`flutter test --platform chrome` / `integration_test` + chromedriver) · **🆕 KON** = **konteyner/E2E** (imaj gerçekten `docker run` ile ayağa kaldırılır; çıkış kodu ve dosya sistemi gözlemlenir).
> **`KON` neden zorunlu oldu [B4]:** M8b'nin mutasyonu **konteynerin giriş betiğindedir**; hiçbir C# testi bir ENTRYPOINT'i gözlemleyemez. v3 seviyeyi `B` yazmıştı ⇒ builder var olmayan bir sınıfa test yazar ve **yeşil geçerdi**. Bir seviye sözlüğünün eksikliği, bir kapıyı **sessizce kör** yapabilir.

| # | mutasyon | kill sinyali (ZORUNLU) | seviye | çıpa |
|---|---|---|---|---|
| **M1** | Yeniden-kullanım tespiti kaldırılır (tüketilmiş token kabul edilir) | *"tüketilmiş token **replay penceresi dışında** ikinci kez sunulunca **o aile** iptal olur"* **FAIL** | TC | K3-C2 |
| **M4** | `ToLowerInvariant` → kültüre-duyarlı `ToLower()` | **İKİ AYRI COMMIT'TE koşulur [Ma-16]:** (1) `ToLowerInvariant` → `ToLower()` ⇒ **DERLEME KIRILIR** (BannedApiAnalyzers); (2) analizör kuralı geçici olarak susturulup mutasyon uygulanır ⇒ tr-TR **zorlanmış kültür** testinde *"`I@x.com` ve `i@x.com` aynı hesaba düşer"* **FAIL**. *(Tek commit'te ikisi kanıtlanamaz: derleme kırıldığında davranış testi zaten koşamaz.)* | D + TC | K3-A2 |
| **M5** | Rehash-on-login kaldırılır | *"eski parametreli hash başarılı girişten sonra güncel parametreye taşınır"* **FAIL** | TC | K3-B3 · **[çıpa+]** **K3-B1** (Argon2id parametrelerinin yükseltilmesi bu mutantla ısırır) · **K3-B7** (PHC alanları ayrıştırılmadan rehash kararı verilemez) |
| **M6** | `FixedTimeEquals` → `SequenceEqual` | **DERLEME KIRILIR** (BannedApiAnalyzers) | D | K3-B4 |
| **M6b** | `FixedTimeEquals` → **`byte[] ==`** (referans karşılaştırması) | *"doğru parola ile giriş **başarılı** olur"* **FAIL** *(referans karşılaştırması her zaman `false` döner)* — **mutasyon YALNIZ karşılaştırma satırına uygulanır**; baseline yeşilken **yalnız bu test** kırılmalıdır | B | **[D3 düzeltmesi]** `byte[] ==` BannedApiAnalyzers ile **ifade edilemez** ⇒ v2'nin M6'sının bu yarısı **yanlış sinyal taşıyordu**; davranış testine ayrıldı |
| **M7** | Bilinmeyen e-postada sahte (dummy) hash koşulmaz | *"bilinmeyen e-posta ile `/login` isteğinde `IPasswordHasher.Verify` **tam olarak 1 kez** çağrılır"* **FAIL** | TS | **YAPISAL ÖLÇÜT** — süre ölçülmez, çağrı sayılır |
| **M8a** | `Production`'da imzalama anahtarı yokken fail-fast kaldırılır | *"anahtarsız / `[KS-20]`'den KISA anahtarlı `Production` başlangıcı **patlar**"* **FAIL** | B | K3-I2 · **[çıpa+]** **K3-I1** (gömülü/varsayılan anahtar yoktur ⇒ `Production`'da anahtarsız açılış patlamalıdır) |
| **M8b** | Dev bootstrap'ın ortam koşulu kaldırılır (her ortamda anahtar üretir) | *"`docker run -e ASPNETCORE_ENVIRONMENT=Production` ile **anahtarsız** açılan konteyner **sıfırdan farklı çıkış kodu** verir **ve** `./.secrets/momentum-master.key` **oluşmaz**"* **FAIL** | **KON** | **K3-I3 — bu ayak olmadan bootstrap'ın kendisi bir açıktır** · **[çıpa+]** **K3-I1** · **K3-I3** |
| **M11** | Hız sınırlayıcı (kontrol 1) tamamen kaldırılır | **ÖNKOŞUL:** her istek **FARKLI rastgele e-posta** ile gelir (kontrol 2 `[KS-13]` tetiklenmez) ve testler `[KS-10]`'un kovasını paylaşmaz (§3.2(9) izolasyonu). *"**`[KS-10]`'un tavanını AŞAN ilk** `/login` isteği `429` alır, `problem.Extensions[\"limit\"] == \"ip\"` **ve yanıt `Retry-After` başlığı taşır**"* **FAIL** | TS | **[B-1 kapanır]** kontrol **1a** (`[KS-10]`). **v4'te ÖLÜ TUZAKTI:** sinyal *"11."* diyordu ama tavan `[KS-10]`'a çıkmıştı (kardeşi M23 güncellenmiş, bu unutulmuştu) ⇒ baseline **kırmızı doğuyordu**. **Sayı artık yazılmıyor, `[KS-n]`'e atıf yapılıyor — bu kusur bir daha DOĞAMAZ.** *"aynı IP'den"* ifadesi de **düştü**: K15-b ölçümüyle `TestHost`'ta `RemoteIpAddress` **`null`**'dır. `Retry-After` ayağı kapı-4 majör #4'ü kapatır (`FixedWindowLease` `MetadataName.RetryAfter` **taşır** — ölçüldü) · **[çıpa+]** **K3-J2(1)** |
| **M12** | Yenileme token'ı DB'ye ham yazılır (hash'lenmez) | *"DB'deki `token_hash`, istemciye verilen token'ın `Base64Url` çözümüyle elde edilen **`[KS-21]`'lik HAM BAYTIN SHA-256 özetine EŞİTTİR**"* **FAIL** *(ek assert: `token_hash` ne ham baytlara ne de kodlanmış dizeye eşittir)* | TC | **[B5]** v3 *"neyin özeti"*ni yazmıyordu ⇒ builder kodlanmış dizeyi hash'lerse test **yazılamazdı**. **`Base64Url` + ham bayt artık K3-C2'de pinlidir.** ⚠ **`successor_secret_enc` bu iddiaya İSTİSNADIR ve M40 onu ayrıca ısırtır** (K15-a) |
| **M13** | ~~Zarafet penceresi sınırı~~ | **VOID — KONUSU KALMADI** | — | Mekanizma K11-c ile kaldırıldı; **sessizce kaybolmasın diye satır duruyor** |
| **M14** | `FallbackPolicy` kaldırılır (deny-by-default kapatılır) | *"test için eklenmiş, **`[Authorize]` yazılmamış** `GET /v1/_probe/deny-default` ucu anonim erişime `401` döner"* **FAIL** | TS | **[D3 düzeltmesi]** v2 hedef ucu tanımsız bırakmıştı ⇒ builder mevcut bir ucu seçerse mutant ısırmayabilirdi. **Uç adı artık pinlidir** (yalnız test derlemesinde kayıtlı) |
| **M15** | `ICurrentUser.UserId` kimliksizken `Guid.Empty` döndürür | *"kimliksiz erişimde `UnauthenticatedException` atılır"* **FAIL** | B | K3-D1 |
| **M16** | `ClockSkew = TimeSpan.Zero` kaldırılır (varsayılan 5 dk) **veya** `ValidAlgorithms` **`HS512`'ye** genişletilir | *"süresi 1 dk önce dolmuş token `401`"* **FAIL** · *"**aynı anahtarla HS512** imzalanmış token reddedilir"* **FAIL** | TS | **[bloker #12 düzeltmesi]** `alg:none` ve RS256 ayakları **kaldırıldı** (ilkini `RequireSignedTokens`, ikincisini `SymmetricSignatureProvider` zaten kapatıyor ⇒ mutant hayatta kalırdı = kör kapı) · **[çıpa+]** **K3-C1** (`ValidAlgorithms` ayağı HS256 pinini ısırtır) · **K3-C7** |
| **M17** | Döndürmede yeni token'a **yeni** mutlak son kullanma verilir | **aile doğduktan sonra `FakeTimeProvider` İLERİ ALINIR**, sonra `/refresh` çağrılır: *"yeni satırın `expires_at`'i eski satırınkine **TAM EŞİTTİR**"* **FAIL** | TC | **[bloker #14 düzeltmesi]** donmuş saat altında v2'nin sinyali **yeşil kalıyordu** = kör kapı |
| **M18** | `/logout` kullanıcının **tüm** ailelerini iptal eder | *"iki cihazdan giriş: birinden `/logout`, diğerinin `/refresh`'i ÇALIŞMAYA DEVAM EDER"* **FAIL** | TC | K3-C4 |
| **M19** | `OutboxDispatcher`'ın kendi `IServiceScope`'u kaldırılıp `ICurrentUser` **doğrudan** singleton'a enjekte edilir | **KILL SİNYALİ PİNLİ VE AYIRT EDİCİ [kapı-4'ten devreden borç — v6'da kapanıyor]:** **TEK** bir test (`Host_builds_and_outbox_dispatcher_resolves_scoped_dependencies`) `factory.Services`'e dokunarak host'u **fiilen kurar**; baseline'da istisna **atılmaz**. Mutasyon altında test `ValidateOnBuild` yüzünden FAIL eder **ve atılan istisnanın mesajı `Cannot consume scoped service` ifadesini TAŞIMALIDIR** — assert bunu da doğrular. **Ayırt edicilik tam olarak budur:** başka herhangi bir DI/başlangıç hatası (eksik kayıt, bağlantı dizesi, migration) bu sinyali **karşılamaz**. **YAN ISIRMA — ADLANDIRILIYOR:** host kurulamadığı için `TS` seviyesindeki **diğer tüm testler de düşer**; bu mutasyonun doğasıdır, kusur değildir — ama KANIT'a *"YAN ISIRMA: tüm `TS` süiti"* diye **YAZILMAK ZORUNDADIR**, aksi hâlde *"kaç test kırıldı"* muhasebesi ölçülemez hâle gelir (slice-2b2 BULGU-4'ün dersi) | **TS** | **[D3 düzeltmesi]** v2'nin mutasyon biçimi kararsızdı (*"ya tüm suite düşer ya hiç ısırmaz"*); mutasyon artık **DI doğrulamasına** çıpalı. **[Ma-13]** seviye `D` **yanlıştı**: `ValidateOnBuild` bir analizör değil **çalışma-zamanı host-build** doğrulamasıdır. **`WebApplicationFactory` üç ayrı yolda `UseEnvironment(Development)` çağırdığı için `TS`'te doğrulama AÇIKTIR** (ölçüldü) — çıplak `ServiceCollection` ile mutant **sessizce hayatta kalır**, o yüzden koşum biçimi §3.2'de pinlendi · **[çıpa+]** **K3-D3** (arka plan servisi tuzağı — `IServiceScope`) |
| **M21** | Normalizasyondan `Trim()` **veya** NFC adımı çıkarılır | *"`\" a@x.com\"` ile `\"a@x.com\"` aynı hesaba düşer"* **FAIL** · *"NFC ayrık aksanlı e-posta birleştirilmiş hâliyle aynı hesaba düşer"* **FAIL** | TC | K3-A2 |
| **M22** | Eşzamanlılık limiti (kontrol 3) kaldırılır | **ÖNKOŞUL (ÜÇ AYAK, ÜÇÜ DE ZORUNLU):** (i) her istek **FARKLI rastgele e-posta** ile gelir — **kontrol 2 `[KS-13]`, kontrol 3'ten ÖNCE ısırır** (K3-J3'ün bağlayıcı sırası), aynı e-posta kullanılırsa `limit == \"email\"` döner ve assert **baseline'da kırılır**; (ii) `IPasswordHasher` **bloke eden sahte** implementasyondur (test kontrollü semafor); (iii) eşzamanlı istek sayısı `[KS-16]`'yı aşar. *"limitin üstündeki eşzamanlı `/login` `429` alır, `problem.Extensions[\"limit\"] == \"concurrency\"` **ve Argon2 KOŞMAZ**"* **FAIL** | TS | **[bloker #13 + Ma-15 + B-8 kapanır]** **ÖNKOŞUL ADR'DE YAZILIR:** `TestHost` `RemoteIpAddress`'i **`null`** bırakır ⇒ *"her istek farklı IP'den"* koşulu, `UseRateLimiter`'dan **ÖNCE** eklenen **tek satırlık test-only middleware** ile kurulur (`ctx.Connection.RemoteIpAddress = IPAddress.Parse($"10.0.0.{i}")`). v3 bunu yazmamıştı ⇒ kusur *"imkânsız"* değil **"yazılmamış"**tı. Ayrıca v2'de test kendi istekleriyle **önce IP penceresini** dolduruyordu ⇒ mutant uygulandığında da ret geliyordu = **kör kapı**; ters yönde hızlı sahte hasher'la limit hiç dolmuyordu = **ölü tuzak** · **[çıpa+]** **K3-J2** · **K3-J2(3)** |
| **M23** | IP partition'ı kaldırılır, yalnız e-posta partition'ı bırakılır | *"her istekte FARKLI rastgele e-posta ile gelen, **`[KS-10]`'un tavanını AŞAN İLK** `/login` isteği de `429` alır ve `limit == \"ip\"`"* **FAIL** | TS | **R2'nin tam kapısı.** **[K16-b]** sayı 11→31 (tavan `[KS-10]`).  <!-- [KS-LITERAL: v3→v4 TARİHSEL DÜZELTME KAYDI — "neyin neye çevrildiği" ancak eski ve yeni sayı yazılarak anlatılabilir; bu satır bir kill sinyali DEĞİL, bir değişim kaydıdır] --> **[K15-b]** kontrol 1 fiilen küresel olsa da **kod IP-anahtarlıdır ve bu mutant tam olarak o kodu ısırtır**: partition e-postaya çevrilirse rastgele e-postalar **hiç ret üretmez** ⇒ test kırılır. Tek partition altında da ısırır (denetimde doğrulandı) |
| **M24** | `ICurrentUser` `"sub"` yerine `ClaimTypes.NameIdentifier` okur | 🔴 **UÇ ARTIK PİNLİ [v7 — B6-3 kapanır]:** hedef uç **`GET /v1/_probe/whoami`**'dir; **yalnız test derlemesinde kayıtlıdır**, `[Authorize]`'lıdır **ve gövdesi `ICurrentUser.UserId`'yi FİİLEN DEREFERENCE ETMEK ZORUNDADIR** (ör. `Results.Ok(currentUser.UserId)`). *"`MapInboundClaims=false` altında geçerli token ile `GET /v1/_probe/whoami` **`200`** döner **ve gövdesindeki değer token'ın `sub` talebine EŞİTTİR**"* **FAIL** *(mutasyon altında `UserId` çözülürken `UnauthenticatedException` atılır ⇒ `500`/`401`; **eşitlik assert'i ikinci ayaktır** ve yanlış bir claim'in sessizce çözülmesini de yakalar)* | TS | K3-C7'nin ölçülmüş yan etkisi. **[Ma-14] PİN:** test **gerçek `AddJwtBearer` boru hattından** geçer; sahte `TestAuthHandler` **YASAKTIR** (§3.2) — sahte handler'la mutant **sessizce hayatta kalır**. M14'te uç adı pinlenmişken burada pinlenmemesi belgenin kendi standardıyla asimetriydi · **[çıpa+]** **K3-D2** (`"sub"` claim'i okunur; `ClaimTypes.NameIdentifier` okunmaz) |
| **M25** | Double-submit CSRF doğrulaması **tamamen** kaldırılır | *"geçerli yenileme çerezi + **EKSİK** `X-CSRF-Token` ile `/refresh` reddedilir"* **FAIL** | TS | K3-L3(3) |
| **M26** | `/refresh` yükleminden **`revoked_at IS NULL`** çıkarılır | *"`/logout` sonrası aynı yenileme token'ı ile `/refresh` **`401`** alır"* **FAIL** | TC | **[bloker #2]** bu ayak olmadan **`/logout` fiilen no-op'tur** ve M18 yine de yeşil kalır |
| **M27** | `/refresh` yükleminden **`expires_at > @now`** çıkarılır | `FakeTimeProvider` **`[KS-2]`'yi AŞACAK KADAR ileri alınır**: *"süresi geçmiş yenileme token'ı `401` alır ve **aile iptal edilmez**"* **FAIL** | TC | **[bloker #2]** mutlak `[KS-2]` ömrün tek zorlayıcısı |
| **M28** | Web modunda yenileme token'ı yanıt gövdesine **de** eklenir | *"`X-Client-Kind: web` ile gelen `/login` ve `/refresh` yanıtlarının **ham gövde metni** yenileme token'ının değerini **içermez**"* **FAIL** | TS | **[bloker #6]** test alan adına güvenmez, gövdeyi dize olarak tarar |
| **M29** | Replay-idempotency penceresi **sınırsızlaştırılır** (`consumed_at + [KS-4]` koşulu kaldırılır) | 🔴 **ÖNKOŞUL ARTIK PİNLİ — İKİ AYAK, İKİSİ DE ZORUNLU [v7 — B6-2 kapanır]:** (i) **fırsatçı silme** (satır §2-C, K3-C6(5)) **devre dışıdır**; (ii) **süpürücü fixture'a KAYDEDİLMEZ** (M40b'nin birebir aynı pini). Ancak bundan sonra `FakeTimeProvider` **`[KS-4]`'ü AŞACAK KADAR ileri alınır**: *"tüketilmiş token yeniden sunulunca **aile iptal olur**"* **FAIL**. **NEDEN ZORUNLU:** iki silme mekanizması da `successor_secret_enc`'i `NULL`'lar ⇒ **koşul 3 düşer** ⇒ §2-C(3)'ün kendi cümlesiyle **dal (d)**'ye düşülür ⇒ aile **mutasyon altında da** iptal olur ⇒ assert **GEÇER** ⇒ mutant hayatta kalır = **KÖR KAPI**. Kardeş mutant **M40b bu önkoşulu zaten pinlemişti; M29'a taşınmamıştı** — belgenin kendi standardıyla asimetriydi (M14 ⟷ M24'ün aynı sınıfı) | TC | **[K14-a]** pencerenin v1'in zarafet penceresine dönüşmesini engelleyen kapı · **[çıpa+]** **K3-C5** (zarafet penceresi yoktur — mutasyon pencereyi tam olarak ona çevirir) · **K3-C6(3)** |
| **M30** | Replay-idempotency'den **"halef tüketilmemiş olmalı"** koşulu kaldırılır | **`[KS-4]` PENCERESİNİN İÇİNDE** kalınır (`FakeTimeProvider` **ilerletilmez**), halef **kullanılır**, sonra `T1` yeniden sunulur: *"**aile iptal olur**"* **FAIL** | TC | **[K14-a + Ma-16]** gerçek hırsızlık sinyalini koruyan kapı. **PİN:** pencere dışına çıkılırsa M29 ile **ayırt edilemez** hâle gelir ⇒ *"pencere İÇİNDE"* koşulu testin önkoşuludur |
| **M31** | Parola asgari/azami uzunluk doğrulaması kaldırılır | **SINIR DEĞER, ÜÇ AYAK (hepsi PAROLA — mutasyon parola doğrulamasıdır):** *"`[KS-17]`'den **bir eksik** karakterlik parola `400`"* · *"**tam `[KS-17]`** karakterlik parola **`201`**"* · *"`[KS-18]`'den **bir fazla** karakterlik parola `400` **ve Argon2 KOŞMAZ**"* — herhangi biri **FAIL** | TS | **[bloker #11 + K16-a + Ma-5]** K3-B6 (parola ayağı). **[B-6 kapanır]** v4'ün **dördüncü ayağı (e-posta formatı) bu mutasyona DUYARSIZDI** — parola doğrulaması kaldırılsa da o ayak yeşil kalıyordu ⇒ sahte kapı. E-posta ayakları **M52**'ye taşındı. 🔴 **v7 DÜZELTMESİ [kapı-6 majör #3 — K30-b'nin ARADIĞI KALEM BUYDU]:** v6 burada *"**15/14** çifti pazarlıksızdır: … çizgi **10**'a da **15**'e de düşse yeşil kalır"* diye **üç ham kanonik sayı** taşıyordu, **muafiyet gerekçesi olmadan** — üstelik **aynı hücrenin kill sinyali doğru biçimi (`[KS-17]`) kullanıyordu** ⇒ tek hücrede iki standart. Doğru biçim: **`[KS-17]` / `[KS-17]`−1 çifti pazarlıksızdır:** yalnız *"`a` reddedilir"* testi, çizgi **`[KS-17]`'ye de, K16-a'nın geri çektiği eski çizgiye de** düşse **yeşil kalır** = ölü ölçüt. ⚠ **BU, §3.1'İN BİR RAPORUNU YANLIŞLAR:** v6 §3.1, K30-b için *"çevrilecek GERÇEK bir sınır-değer literali YOKTU"* diye kapanmıştı; **vardı ve tam olarak burasıydı** — araç onu göremedi çünkü `K4` mutant tablosunu tarasa da **tek haneli literalleri (`10`) kapsam dışı bırakıyor** ve satır 412'nin sessiz filtresi bu bölgeyi de affediyor. §3.1'in ilgili cümlesi **v7'de düzeltilmiştir** |
| **M32** | `Application` katmanındaki bir sınıfa `Konscious.Security.Cryptography` referansı eklenir | *"`Konscious.*` tipleri Domain/Application/Api'de **görünmez**"* NetArchTest kuralı **FAIL** | NA | **[bloker #15 + Ma-16] MUTASYON BİÇİMİ PİNLİ:** yalnız `using` eklemek **yetmez** (kullanılmayan `using` derlemeye referans yazmaz ⇒ NetArchTest görmez); mutasyon **gerçek bir tip kullanımıdır** (ör. `Application` içinde `typeof(Argon2id)` ya da bir alan bildirimi). 0001 K-H1 birebir: *"**Her** kural commit'li negatif/mutant testle ısırdığını kanıtlar"* — v2 bunu ihlal ediyordu · **[çıpa+]** **K3-B2** (`IPasswordHasher` portunun izolasyonu tam olarak bu kuralla zorlanır) · **K3-B1** |
| **M33a** | Fallback ucundan **`AllowAnonymous` kaldırılır** | *"kimliksiz `GET /` ve `GET /tasks` **`200`** döner ve gövdesi `index.html`'dir"* **FAIL** | TS | **[bloker #3 / K14-e / B6]** SPA derin linklerini `FallbackPolicy`'den kurtaran **tek** mekanizma budur (`AuthorizationMiddleware`'in ayrı `IAllowAnonymous` kontrolü) |
| **M33b** | **`UseStaticFiles` auth middleware'inden sonraya alınır** | *"kimliksiz **`GET /main.dart.js`** `200` döner **ve gövdesi `index.html` DEĞİLDİR**"* **FAIL** | TS | **[B6]** v3'ün tek M33'ü **ayırt edici değildi** (ölçüldü: `MapFallbackToFile` kendi `UseStaticFiles`'ını kurar ⇒ `/tasks` her hâlükârda `200`). Fark **dosya-benzeri** yollarda yaşar (`{*path:nonfile}` onları almaz). **ÖNKOŞUL:** test derlemesinde `wwwroot/index.html` **ve** `wwwroot/main.dart.js` yer tutucu olarak bulunur (K3-J1) — yoksa baseline **kırmızı doğar** |
| **M34** | PHC ayrıştırıcısının savunmacı dalı kaldırılır (bozuk format istisna atar) | DB'ye elle bozuk `password_hash` yazılır: *"`/login` **`401`** döner (`500` DEĞİL) ve gövde bilinen/bilinmeyen e-posta ile **aynıdır**"* **FAIL** | TC | **[Ma-4]** K3-B5'in tek-tip yanıt garantisinin kapısı · **[çıpa+]** **K3-B7** (ayrıştırma sözleşmesinin savunmacı dalı) |
| **M35** | CSRF token'ının **HMAC doğrulaması** kaldırılır (yalnız çerez == başlık karşılaştırılır) | **İKİ AYAK:** (1) *"**geçerli biçimli ama İMZASIZ/YANLIŞ İMZALI** bir CSRF değeri hem çerezde hem başlıkta gönderilirse `/refresh` **reddedilir**"* **FAIL**; (2) **[Ma-6 — AİLE BAĞI]** *"**BAŞKA bir ailenin `family_id`'siyle DOĞRU İMZALANMIŞ** bir CSRF değeri, sunulan yenileme çerezinin ailesiyle eşleşmediği için **reddedilir**"* **FAIL**. **Pozitif kontrol zorunlu:** doğru imzalı + doğru aileli değer **kabul edilir** (aksi hâlde *"her şeyi reddet"* mutantı da testi geçer) | TS | **[bloker #4]** v2'nin M25'i naif implementasyonda da **yeşil geçerdi** = kör kapı; **v3'ün M35'i ise yalnız imzayı ölçüyordu, K3-L3(3)'ün aile bağı ayağı KAPISIZDI** |
| **M36** | Çerezlerden **`__Host-`** öneki kaldırılır (veya `Domain` özniteliği eklenir) | **BU MUTASYONUN ISIRDIĞI İKİ AYAK:** *"`Set-Cookie` başlıkları **`__Host-`** ile başlar"* · *"**`Domain=` içermez**"* — herhangi biri **FAIL** | TS | **[bloker #4]** kardeş alt alan adının çerez yazmasını yapısal olarak engelleyen ayak. **[kapı-4 majör #9]** v4 bu satıra **yedi** assert yığmıştı; beşi (`Path=/` · `Secure` · `HttpOnly` · `SameSite=Strict` · `Max-Age`) **`__Host-` mutasyonu altında ÖLMÜYORDU** ⇒ süs. Onlar **M36b**'ye taşındı. Çıpa: **K3-L2** |
| **M36b** | `__Host-mrt` çerezinin öznitelikleri tek tek düşürülür (`Secure` · `HttpOnly` · `SameSite=Strict` · `Max-Age`) — **her biri AYRI commit** | **DÖRT AYRI KOŞUM, her biri kendi mutasyonu altında:** *"`Secure` vardır"* · *"`HttpOnly` vardır (yalnız `__Host-mrt`)"* · *"`SameSite=Strict`'tir"* · *"`Max-Age` ailenin kalan `expires_at`'ine eşittir (±2 sn)"* — ilgili mutasyonda ilgili assert **FAIL** | TS | **[kapı-4 majör #9]** K3-L2'nin öznitelik kararları v3'te **kapısızdı** (Ma-6), v4'te **ölmeyen ayaklara** bağlanmıştı. `Path=/` ayağı **düştü**: `__Host-` öneki `Path=/`'ı tarayıcı tarafından **zorunlu** kılar ⇒ ayrı bir kapı değil, önekin **sonucudur** ve M36'nın birinci ayağı zaten onu kapsar |
| **M37** | `/login`'in bilinmeyen-e-posta dalı farklı bir gövde/kod döndürür | *"bilinmeyen e-posta + yanlış parola ile mevcut e-posta + yanlış parolanın yanıtları, **`extensions.traceId` alanı düşürüldükten sonra**, bayt bayt aynıdır (durum kodu dâhil)"* **FAIL** | TS | **[D3 + Ma-4]** K3-B5'in *"aynı yanıt"* ayağı v2'de kapısızdı; **v3'ün "bayt bayt aynı" sinyali ise ölü tuzaktı** — `DefaultProblemDetailsWriter` `traceId`'yi **koşulsuz** yazıyor (ölçüldü) |
| **M38** | `family_id` her `/login`'de yeniden üretilmez (kullanıcı başına sabit) | *"aynı kullanıcının iki ardışık `/login`'i **FARKLI** `family_id` üretir"* **FAIL** | TC | **[D3]** K3-C3'ün doğum anı v2'de yalnız **tesadüfen** kapsanıyordu; M18 ayırt edici değildi |
| **M39** | Atomik `UPDATE` yerine check-then-act (`SELECT` sonra `UPDATE`) yazılır | **gerçek Postgres'te paralel** iki `/refresh` aynı `T1` ile: *"**tam olarak biri** `200`, diğeri `401`+`reuse_detected` **ALIR; VEYA** (K14-a'nın replay penceresi devreye girdiyse) **ikisi de `200` alır ve dönen token'lar ÖZDEŞTİR**"* — **her iki durumda da** *"ailenin satır sayısı **tam olarak 1** artmıştır"* **FAIL** | TC | **[D3 + Ma-1]** v2 atomikliği iddia ediyor ama test etmiyordu; **v3'ün "tam olarak biri 200" sinyali ise K14-a ile ÖLÜ TUZAKTI**: kaybeden istek dal (c)'ye düşüp `200` alabilir (`K3-L9` **[devir]** — `slice-3b`'ye devredilmiştir, aynı olguyu tersinden yazar; **bu bir ÇIPA DEĞİL, ÇAPRAZ ATIFTIR**). **Değişmez artık yanıt kodu değil, AİLENİN SATIR SAYISIDIR** (K3-C6/1) |

| # | mutasyon | kill sinyali (ZORUNLU) | seviye | çıpa |
|---|---|---|---|---|
| **M32b** | `Application` katmanındaki bir sınıfta **`Microsoft.AspNetCore.Http`** tipi kullanılır (ör. `HttpContext` alanı) | *"`Microsoft.AspNetCore.*` tipleri Domain/**Application**'da görünmez"* NetArchTest kuralı **FAIL** | NA | **[Ma-8]** K-H1 Application için yalnız *"⊥ Infrastructure"* diyordu ⇒ bu **yeni bir namespace kısıtıdır** ⇒ K-H1'in *"her kural mutantlı"* cümlesi gereği mutant **zorunlu**. Mutasyon biçimi M32'deki gibi **gerçek tip kullanımıdır** |
| **M32c** | `Application` katmanındaki bir sınıfta **`Microsoft.IdentityModel.Tokens`** tipi kullanılır | *"`Microsoft.IdentityModel.*` tipleri Domain/**Application**'da görünmez"* NetArchTest kuralı **FAIL** | NA | **[Ma-8]** aynı gerekçe; `IAccessTokenIssuer` portunun izolasyonu (§2-M) ancak bu kuralla zorlanır |
| **M40** | **MUTASYON BİÇİMİ PİNLİ [kapı-4 majör #5]:** `RefreshSecretSweeper.SweepAsync` gövdesi **no-op** yapılır (servis kaydı DURUR — kaldırılırsa `KON`/DI doğrulaması ayrı bir yerden kırılır ve mutant **ayırt edici olmaz**) | **İKİ AYAK, İKİSİ DE BU MUTASYON ALTINDA ÖLÜR:** (1) `FakeTimeProvider` `[KS-4]` + `[KS-6]` kadar ileri alınıp süpürme turu tetiklenir: *"tüketilmiş satırın `successor_secret_enc`'i **`NULL`**'dır"* **FAIL**; (2) *"süpürme turları arasındaki süre `[KS-6]`'dir"* — `FakeTimeProvider` `[KS-6]`'nin **bir eksiği** kadar ilerletildiğinde satır **hâlâ doludur**, `[KS-6]` kadar ilerletildiğinde **`NULL`**'dır **FAIL** | TC | **[K15-a]** kolonun **gerçekten silindiğini** ısırtan kapı. **[kapı-4 majör #5]** v4 mutasyon biçimini pinlemiyordu ve **süpürme periyodunu (`[KS-6]`) hiç ölçmüyordu** ⇒ §6 Risk #13'ün `[KS-4]`+`[KS-6]` aritmetiğinin **yarısı kapısızdı** |
| **M40b** | K3-C6(5)'in **fırsatçı (tembel) silme** ayağı kaldırılır (`/refresh` işlemi içindeki `NULL`'lama düşürülür) | **ÖNKOŞUL [kapı-5 aday bloker 4 — ZAMANA DEĞİL MEKANİZMAYA ÇIPALI]:** süpürücü fixturea **KAYDEDİLMEZ** (`SweepAsync` hiç çağrılmaz); `FakeTimeProvider` **`[KS-4]`ü aşacak kadar** ilerletilir. *(v5 bunu "saat ilerletilmez" diye yazıyordu ⇒ pencere hiç aşılmadığı için **baseline KIRMIZI doğuyordu**; saat ilerletilse bu kez `[KS-4]`=`[KS-6]` olduğu için süpürme turu da hak ediliyor ve mutant hayatta kalıyordu.)* *"aynı ailede yeni bir `/refresh` yapıldıktan sonra, `[KS-4]`'ü aşmış ESKİ satırın `successor_secret_enc`'i **`NULL`**'dır"* **FAIL** | TC | **[kapı-4 majör #5 + B-3 #3]** K3-C6(5) *"İKİ MEKANİZMA, İKİSİ DE ZORUNLU"* diyor; v4 yalnız süpürücüyü ısırtıyordu ⇒ tembel silme **kapısızdı**. Çıpa: **K3-C6(5)** |
| **M41** | Kontrol 2 (e-posta penceresi, `Application handler`) kaldırılır | **ÖNKOŞUL:** `[KS-10]`'un kovası boştur (§3.2(9) izolasyonu). **BU MUTASYONUN ISIRDIĞI TEK AYAK:** *"**aynı** normalize e-posta ile `[KS-13]`'ün tavanını aşan `/login` denemesi `429` alır **ve** `limit == \"email\"` **ve** `Retry-After` taşır"* **FAIL** | TS | **[B7]** K14-f ile kapatıldığı ilan edilen bloker #5, v3'te **kapısızdı**. **[kapı-4 majör #9]** v4'ün ikinci ayağı (*"aynı IP'den farklı e-postalarla gelen istek `429` ALMAZ"*) **bu mutasyon altında ÖLMÜYORDU** — kontrol 2 kaldırılınca da o istek `429` almazdı ⇒ süs. O ayak **M41b**'ye taşındı. Çıpa: **K3-J2(2)** |
| **M41b** | Kontrol 2'nin **anahtarı** normalize e-postadan **IP'ye** çevrilir | *"**aynı IP'den FARKLI e-postalarla** `[KS-13]`'ün tavanını aşan istekler `429` **ALMAZ**"* **FAIL** — mutasyonda IP anahtarlı sayaç dolar ve `429` gelir | TS | **[kapı-4 majör #9]** R2'yi koruyan asıl ayak budur: kontrol 2'nin anahtarının **e-posta** olduğunu, IP olmadığını ısırtır. v4'te M41'in ikinci ayağı olarak yazılmıştı ama **kendi mutasyonu yoktu**. Çıpa: **K3-J2(2)** |
| **M42** | Alt anahtar türetme kaldırılır ve CSRF HMAC anahtarı **her açılışta yeniden üretilir** (efemer) | *"konteyner `docker compose restart` edildikten **sonra**, restart öncesi alınmış `__Host-mct` + `__Host-mrt` çiftiyle yapılan `/refresh` **`200`** döner"* **FAIL** | **KON** | **[B8 / K16-c]** K3-I3'ün açık vaadi (*"restart'ta oturumlar düşmez"*) v3'te **yalnız JWT için** kanıtlıydı; CSRF anahtarının varlığı bile yazılı değildi. M25/M35 hangi anahtar seçilirse seçilsin **yeşil kalır** ⇒ bu kapı olmadan hiçbir test bunu yakalayamaz |
| **M43** | Sunucu girdi kanalını `X-Client-Kind`'dan değil **kanalın varlığından** seçer (*"çerez varsa çerezden oku"*) | **ÜÇ AYAK:** (1) *"`X-Client-Kind: native` + geçerli `__Host-mrt` çerezi + gövdede token **YOK** ⇒ `400`; çerez **kullanılmaz**"* **FAIL**; (2) *"`X-Client-Kind: web` + gövdede geçerli token + çerez **YOK** ⇒ istek **başarısızdır**"* **FAIL**; (3) *"`X-Client-Kind` **başlıksız** `/refresh` `400` alır"* **FAIL** | TS | **K3-L10** · **[B9 + Ma-6]** v3 yalnız **çıktı** yönünü yazmıştı ⇒ güvenlik modunu **istemci** seçiyordu (K14-f'in adlandırarak reddettiği hata sınıfı). Bugün CORS preflight'ı yüzünden sömürülemiyor — **kazara duran savunma savunma sayılmaz** |
| **M44** | K3-C6(2)'nin dal önceliği bozulur: (c) replay dalı (b)'den **önce** değerlendirilir | *"`/logout`'tan **sonra**, `T1.consumed_at + [KS-4]` **içinde** sunulan tüketilmiş token **`401`** alır (`200` DEĞİL)"* **FAIL** | TC | **K3-C6(2)** · **[Ma-2]** `consumed_at` ve `revoked_at` sıradan bir akışta (refresh → logout) **birlikte** dolar; sıra yazılmazsa çıkış fiilen **`[KS-4]` gecikir**. **M26 bunu görmez** (o, yüklemin kendisini ölçer) |
| **M45** | Halef `INSERT`'ü tüketim `UPDATE`'inden **önceye** alınır (veya ayrı transaction'a çıkarılır) | **gerçek Postgres'te paralel** iki `/refresh` aynı `T1` ile: *"ailenin satır sayısı **tam olarak 1** artmıştır"* **FAIL** *(kaybeden istek sahipsiz bir satır bırakırsa 2 artar)* | TC | **[Ma-10]** v3 yalnız `UPDATE … RETURNING`'i pinliyordu; **halef satırının işlem sınırı yazılı değildi** ⇒ yarışı kaybeden istek ailede **sahipsiz ama geçerli** bir satır bırakırdı ve M39 bunu görmezdi |
| **M46** | **`UseRateLimiter`, `UseRouting`'den ÖNCEYE alınır** | **ÖNKOŞUL:** her istek FARKLI rastgele e-posta. *"`[KS-10]`'un tavanını aşan `/login` isteği `429` **ALIR**"* **FAIL** — çünkü uç-bazlı politikalar (`RequireRateLimiting`) **çözülemez** ⇒ **hiçbir sınır uygulanmaz** | TS | **[Ma-11 + B-2 kapanır — K19-b]** **v4'ün mutasyonu KÖRDÜ.** Ölçüldü (birincil kaynak, aspnetcore `release/9.0` `RateLimitingMiddleware`) birebir: *"If this endpoint has no EnableRateLimitingAttribute & there's no global limiter, don't apply any rate limits."* + `if (enableRateLimitingAttribute is null && _globalLimiter is null) { return _next(context); }` ⇒ **statik dosya isteği hiçbir kovayı TÜKETEMEZ**, ne baseline'da ne mutasyonda ⇒ eski assert **her iki durumda da sağlanıyordu = test asla kırılamazdı.** Yeni çıpa **gerçekten gözlemlenebilir**: sıra bozulunca uç çözümlemesi kaybolur, politika bulunamaz, `429` hiç doğmaz. Çıpa: **K3-L4** (aynı origin + statik dosya sırası) |
| **M47** | `/logout` yanıtından **`__Host-mrt` silme başlığı** kaldırılır | *"`/logout` yanıtı **`__Host-mrt` ve `__Host-mct`'nin İKİSİNİ birden** `Max-Age=0` ile siler ve silme başlıkları çerezin **kendi öznitelikleriyle birebir aynıdır**"* **FAIL** | TS | **[Ma-12]** v3'ün *"`/logout`'ta silinir"* cümlesi **yalnız CSRF çerezi** içindi; `__Host-mrt` `Path=/` gereği çıkıştan sonra **`[KS-2]`e kadar** her isteğe takılmaya devam ederdi |
| **M48** | `ValidateIssuer` **veya** `ValidateAudience` `false` yapılır | *"**yanlış `iss`** taşıyan (aksi hâlde geçerli, doğru anahtarla imzalı) token korumalı uçta **`401`** alır"* **FAIL** · *"**yanlış `aud`** için aynı"* **FAIL** | TS | **[Ma-7]** v3 bunu §3.1'de *"çerçevenin kendi doğrulamasıdır"* diye muaf tutuyordu. **Yanlıştı:** `ValidateIssuer=false` **benim kodumdaki tek satırlık yapılandırmadır** — `ClockSkew` ile **birebir aynı sınıf**, ve `ClockSkew` için mutant yazılmıştı |
| **M42b** | `info` etiketi değiştirilir (ör. `"momentum:v1:jwt-sign"` → `"momentum:v2:jwt-sign"`) **veya** bayt kodlaması ASCII yerine UTF-16 yapılır | *"KANIT'a yazılı **pinli kök anahtardan** türetilen `K_jwt` · `K_csrf` · `K_rt`, KANIT'taki **ALTIN VEKTÖR hex'lerine BİREBİR eşittir**"* **FAIL** | B | **[kapı-4 majör #13]** K3-I4'ün **`info` bayt kodlaması** pini. v4 etiketleri §3.1'de mutanttan **muaf** tutuyordu ⇒ hiçbir yerde sabitlenmiyordu. Bir KDF girdisinin baytları yazılmadıkça iki bağımsız implementasyon **aynı anahtarı üretmez**. **[kapı-5 B5-12 — GERİ ÇEKİLEN KİLL SİNYALİ]** v5 bunu *"restart sonrası `401`"* diye ölçüyordu; **ayırt edici DEĞİLDİ**: `info` mutasyonu statiktir, mutasyona uğramış derlemede restart öncesi ve sonrası **aynı** anahtar türetilir ⇒ sinyal baselinede de mutasyonda da aynı sonucu verirdi. Altın vektör tek derlemede, deterministik ve `B` seviyesinde ısırır |
| **M42c** | Alt anahtarlar her açılışta **yeniden üretilir** (efemer; kök anahtar dosyaya yazılmaz) | *"konteyner `docker compose restart` edildikten sonra, restart ÖNCESİ alınmış `__Host-mct` + `__Host-mrt` çiftiyle yapılan `/refresh` **`200`** döner"* **FAIL** | KON | **[kapı-4 majör #10]** v4'te bu ayak **M42'nin içine bileşik olarak** gömülüydü (türetme + efemer üretim **tek** mutasyonda) ⇒ türetme yarısı hiçbir testle gözlemlenemiyordu. **Ayrıldı.** **GÖZLEM YÜZEYİ UÇTAN UCA PİNLENİYOR [kapı-4'ten devreden borç — v6'da kapanıyor]:** (1) `docker compose up -d`; (2) `/login` ile çerez çifti alınır ve **dosyaya yazılır**; (3) `docker compose restart api`; (4) `docker compose exec api ls -l ./.secrets/momentum-master.key` ⇒ **dosya VARDIR ve mtime restart'tan ÖNCEDİR**; (5) **aynı** çerez çiftiyle `/refresh` ⇒ **`200`**. Baseline'da (4) ve (5) birlikte geçer; efemer mutantta **(4) dosyayı hiç bulamaz ve (5) `401` döner**. **İKİ GÖZLEM DE ZORUNLUDUR:** `KON` seviyesinde tek başına bir `401`, onlarca başka sebeple de gelebilir (ağ, migration, port çakışması, sağlıksız konteyner) ⇒ sinyali **ayırt edici kılan şey dosya sistemi ayağıdır**, ve bu ayak §3.2(7)'nin *"gözlenen şey çıkış kodu, stderr ve dosya sisteminin durumudur"* cümlesiyle birebir uyumludur. K22-a ile `KON` artık **gerçek bir imaja** çıpalıdır |
| **M49** | `ProblemDetails` çevirimi **Api'den Application'a taşınır** (Application handler'ı `RateLimitedException` yerine doğrudan `ProblemDetails` döndürür) | *"`M32b`'nin NetArchTest kuralı (`Microsoft.AspNetCore.*` ⊥ `Momentum.Application`) **YEŞİL kalır**"* **FAIL** — kural kırmızıya döner | NA | **[B-4 / K18-a]** Bu mutant **başka bir kapının ısırdığını** ısırtır: katman kararı bir kural olarak yazıldı, bu mutant o kuralın **fiilen uygulandığını** kanıtlar. Çıpa: **K3-J4** · **K3-J3** · §2-M |
| **M50** | AES-256-GCM nonce'u **sabitlenir** (sıfır dizisi ya da `family_id` türevi) | *"**aynı** düz metin ve **aynı** `family_id`/`token_hash` için iki ayrı şifreleme çağrısı **FARKLI** `successor_secret_enc` üretir"* **FAIL** — sabit nonce'ta çıktılar **birebir aynı** olur | B | **[B-5 / K18-b]** K3-I5(1). NIST SP 800-38D: aynı anahtarla nonce tekrarı **hash alt anahtarını ifşa eder** (Appendix A), tekrar olasılığı `2^-32`'yi aşmamalı (§8). `K_rt` **tek ve kalıcıdır** (K3-I4) ⇒ risk teorik değildir. Ölçüldü: `AesGcm.Encrypt(ReadOnlySpan<byte> nonce, …)` **nonce'u çağırandan alır** ⇒ K3-K2'nin *"primitifi yazmayız"* muafiyeti **UYGULANMAZ** |
| **M51** | AAD kaldırılır (`associatedData` hiç geçilmez) **veya** yalnız `family_id` ile kurulur | *"**satır A**'nın `successor_secret_enc` değeri **satır B**'ye kopyalandığında çözme **BAŞARISIZ** olur (`AuthenticationTagMismatchException`) ve istek K3-C6'nın **yeniden-kullanım dalına** düşer"* **FAIL** | TC | **[B-5 / K18-b]** K3-I5(2)+(3). AAD olmadan şifreli blok **satırdan satıra taşınabilir** ⇒ K15-a'nın replay-idempotency'si **başka bir ailenin halefini** döndürebilirdi. Bayt kodlaması pinli: `family_id` **16 ham bayt** (RFC 9562 big-endian) ‖ `token_hash` **32 ham bayt**  <!-- [KS-LITERAL: AAD bileşenlerinin bayt kodlaması pini — kill sinyalinin inşa edilebilmesi için birebir gereklidir] --> · **[çıpa+]** **K3-I5(3)** (çözme başarısızlığı KAPALI düşer) |
| **M52** | **E-posta** girdi politikası kaldırılır (uzunluk **ve** format doğrulaması) | **ÜÇ AYAK:** *"tam `[KS-19]` uzunluğunda geçerli e-posta **`201`**"* · *"`[KS-19]`'dan **bir fazla** karakterlik e-posta **`400`** (`500` DEĞİL)"* · *"gösterim-adlı e-posta (`Ad <a@x.com>` biçimi) **`400`**"* — herhangi biri **FAIL** | TS | **[B-6 kapanır]** v4'te bu ayaklar **M31'in içindeydi** ve M31'in mutasyonu **paroladır** ⇒ e-posta ayakları mutasyona **DUYARSIZDI** (sahte kapı); ayrıca **`[KS-19]` sınırının assert'i HİÇ YOKTU** — belge iki yerde *"kapandı"* diyordu. Çıpa **K3-B6** (e-posta ayağı) + **K3-A2**. `500` ayağı kritiktir: `email_normalized` btree index'inin anahtar boyutu aşılırsa Postgres hata verir ve K3-B5'in **tek-tip yanıt** kuralı kırılır |
| **M53** | `/refresh`'te CSRF doğrulaması tüketim `UPDATE`'inden **sonraya** alınır | *"geçersiz CSRF token'ı ile yapılan `/refresh` `403` döner **ve AYNI yenileme token'ı ile, `FakeTimeProvider` `[KS-4]`'ü AŞACAK KADAR ilerletildikten sonra yapılan geçerli-CSRF'li `/refresh` `200` döner**"* **FAIL** — mutasyonda ikinci istek `401` + `reuse_detected` alır ve **aile düşer** | TC | **[kapı-4 majör #7 · kapı-5 aday bloker 3]** *(v5te ikinci istek **`[KS-4]` İÇİNDE** yapılıyordu ⇒ dal (c) replay-idempotency onu `200` ile kurtarıyor, assert YEŞİL kalıyor, mutant HAYATTA kalıyordu = KÖR KAPI.)* K3-J3'ün `/refresh` ayağı + K3-L3. `/login` için bağlayıcı sıra vardı, `/refresh` için **yoktu** ⇒ bir CSRF hatası kullanıcının **oturumunu öldürebiliyordu**. Sıra artık PAZARLIKSIZ: **CSRF önce, tüketim sonra**; CSRF başarısızsa **hiçbir yazma yapılmaz** |
| **M54** | Parola hash'inde salt **SABİTLENİR** (global sabit / `new byte[16]`) | *"AYNI parola iki kez hash'lendiğinde üretilen iki PHC dizesi **FARKLIDIR** ve salt alanı `[KS-23]`'ün salt uzunluğundadır"* **FAIL** | B | **[kapı-5 aday bloker 5 — K28-d]** **K3-B1(2)** — K3-B1'in salt ayağı. v5'te salt yalnız §1-K ve PHC biçim örneğinde geçiyordu, **§3'te SIFIR kez** ⇒ sabit salt kullanan bir implementasyon **M5·M6·M6b·M7·M31·M32·M34'ün hepsini geçer** ve sonuç gökkuşağı tablosuna açık bir parola deposudur. Belge **aynı özelliği AES nonce'u için M50 ile zaten kapılamıştı** — emsal kendi içindeydi, parola tarafında yoktu |
| **M55** | İki alt anahtarın `info` etiketi **AYNI** yapılır (kopyala-yapıştır: `K_csrf`'in etiketi `K_jwt`'ninki olur) | *"`K_jwt` · `K_csrf` · `K_rt` **ikişer ikişer FARKLIDIR**"* (`FixedTimeEquals` ile üç çift) **FAIL** | B | **[kapı-5 aday bloker 6 — K28-d]** K3-I4'ün **alan ayrımı** ayağı. v5'te türetmenin TÜM gerekçesi *"`K_csrf` sızsa bile JWT imzalanamaz"* idi ama bunu ölçen **hiçbir kapı yoktu**: etiketler bitişik satırlarda ve kopyala-yapıştır bir tuşluk ⇒ `K_csrf == K_jwt` olur, alan ayrımı **tümüyle çöker** ve **M42·M42b·M42c·M25·M35'in beşi de YEŞİL kalır**. **Ek pin:** üç etiket tek bir `static class HkdfLabels` içinde `const string` olarak yazılır, başka hiçbir yerde string literal olarak geçmez |
| **M56** | Sızmış-parola kara listesi kontrolü kaldırılır | 🔴 **PROB ARTIK GERÇEK BİR KAYIT — İKİ AYAK, İKİSİ DE ZORUNLU [v7 — B6-1 kapanır]:** **(a)** *"`mailcreated5240` ile `/register` **`400`** alır"* — **tam `[KS-17]` uzunluğunda** ⇒ uzunluk kontrolünden **geçer**, oradan `400` alamaz **ve** listenin **1516.** kaydıdır (ÖLÇÜLDÜ) ⇒ `400` yalnız kara-liste kontrolünden gelebilir · **(b)** *"`MomentumKapiTesti2026` (`[KS-17]`'nin üstünde, kaynağın hiçbir yerinde YOK — ÖLÇÜLDÜ) ile `/register` **`201`** alır"* ⇒ *"her şeyi reddet"* mutasyonunu da yakalar. **İkisi birden FAIL** olmalıdır. **v6'nın probu `123456`'ydı ve 6 karakter olduğu için mutasyondan BAĞIMSIZ olarak `400` alıyordu = KÖR KAPI.** | B | **[K28-c · K37-b/c]** K3-B6'nın blocklist ayağı. v5, `[KS-17]`'yi **NIST SP 800-63B-4 `SHALL`'ı** diye gerekçelendirirken **AYNI standardın ikinci `SHALL`'ını** (yaygın/sızmış parola kara listesi) ne karara bağlıyor ne kapsam dışı ilan ediyordu ⇒ **ADLANDIRILMAMIŞ SAPMA** (`grep "blocklist\|pwned\|sızdırılmış"` ⇒ **0**). Liste **gömülüdür** (`[KS-31]`): ağ yok, dış bağımlılık yok, çevrimdışı vitrinle çelişmez, **deterministiktir** ⇒ ısırtılabilir. Kaynak + türetme tarifi + beklenen `sha256` **K3-B6(2)'de PİNLİ**; lisans (MIT) ve CVE kapıları **26 Tem 2026'da KOŞTU** (`KANIT/adr-0003/v7-b6-1-kara-liste-kaynagi-ve-kapisi.md`). *Reddedilen [adlandırılmış]:* HIBP k-anonimlik API'si — ODEV §4.1'in AI asistanı ve Google Takvim'i elediği **dış-ağ risk sınıfının aynısı** ve deterministik olmadığı için mutantla ısırtılamaz · **çıpa: K3-B6(2)** |
| 🆕 **M58** | PHC ayrıştırma başarısız olduğunda **sahte-hash Argon2 doğrulaması** kaldırılır (savunmacı dal doğrudan `false` döner) | *"DB'ye elle **bozuk** `password_hash` yazılmış hesaba `/login` isteğinde **Argon2id doğrulaması TAM OLARAK 1 kez çağrılır**"* **FAIL** (sayaç: M7'nin aynı test-çifti mekanizması) | TC | **[kapı-6 B6-D]** **K3-B7** — savunmacı dalın **zamanlama eşitliği** ayağı. v6'da bu dal Argon2'yi **hiç koşturmuyordu** ⇒ bozuk hash'li hesapta `401` **≈anında** dönüyor, sağlam hash'li hesapta `[KS-24]` kadar sürüyordu ⇒ *"hızlı `401` = bu e-posta VAR ve kaydı bozuk"* yan kanalı ve **K3-B5'in *"aynı işi yapar"* garantisinin ihlali**. M34 gövde+kodu, M37 gövdeyi, M7 **bilinmeyen-e-posta** yolunu ölçer ⇒ **üçü de bu dalı görmüyordu.** **Beyan edilmiş sınır:** kapı **duvar saatini assert ETMEZ**, mekanizmayı (çağrı sayısını) ölçer — zamanlama assert'i paylaşılan makinede kırılgandır ve **ölü tuzak** üretir (M1/M7 dersi) · **çıpa: K3-B7 · K3-B5** |

**ADR 0004'e ait mutantlar (burada YAZILMAZ, kaybolmasın diye adlandırılır):** M2 (`ActorId` ile yetki) · M3 (EF global filtre) · M9 (`client_id ↔ user_id`) · M10 (`IgnoreQueryFilters` allowlist dışı) · M20 (sahiplik TOCTOU) · **pull-authz mutantı** · **imleç opaklığı mutantı** · **D-7'nin zorlama mutantı**. **0004'ün yeni numaraları `M60`'tan başlar [K22-b — K16-d'nin `M50` pini GEÇERSİZDİR: v5 M49–M53'ü tüketti].**

**`slice-3b`'ye DEVREDİLEN mutantlar [bloker #9 kapanır — v2'de bunlar ne kapılıydı ne devirliydi]:**

| # | mutasyon | kill sinyali | seviye | çıpa (DEVİR — bu belgede KAPISIZ) |
|---|---|---|---|---|
| **M-L5** | İstemcideki tek-uçuşlu kilit kaldırılır | *"eşzamanlı N adet 401 karşısında `/refresh` **TAM OLARAK 1 kez** çağrılır"* **FAIL** · **web ayağı:** *"iki sekmede eşzamanlı yenilemede `/refresh` tam olarak 1 kez çağrılır"* **FAIL** (Web Locks, K3-L9) | DART + **DART-WEB** | **[devir]** K3-L5 — kapısı `slice-3b` spec'inde koşar |
| **M-L6** | 401'de gönderilmemiş kuyruk temizlenir | *"gönderilmemiş op'lar diskte kalır ve yeniden girişte gönderilir"* **FAIL** | DART | **[devir]** K3-L6 — kapısı `slice-3b` spec'inde koşar |
| **M-L7** | Kullanıcı-başına DB dosyasından tek DB dosyasına dönülür | *"A çıkıp B girince A'nın görevleri okunamaz **VE** A yeniden girince kuyruğu duruyor"* **FAIL** | DART | **[devir]** K3-L7 — kapısı `slice-3b` spec'inde koşar |
| **M-L8** | Ağ hatası dalı `401` dalıyla birleştirilir | *"ağ hatasında istemci **çevrimdışı-yetkili** kalır; 'oturum gerekli'ye GEÇMEZ"* **FAIL** | DART | **[devir]** K3-L8 — kapısı `slice-3b` spec'inde koşar |
| **M-L9** | `429`/`5xx` dalı `401` dalıyla birleştirilir | *"`/refresh` **`429`** döndüğünde istemci **çevrimdışı-yetkili kalır**, 'oturum gerekli'ye **GEÇMEZ** ve `Retry-After` süresi kadar (yoksa üstel geri çekilme, tavan `[KS-4]`) bekler"* **FAIL** | DART | **[devir]** K3-L8 — kapısı `slice-3b` spec'inde koşar |
| 🆕 **M-L10** | Çıkış yolundan **aktif profil kaydının temizlenmesi** kaldırılır | **İKİ AYAK, ikisi de zorunlu:** *"çıkış sonrası **uçak modunda** yeniden açılışta **hiçbir kullanıcının DB'si açılmaz**, *kimlik yok* dalına düşülür"* **FAIL** · *"aynı senaryoda `momentum_{A}.sqlite` **diskte VARDIR** ve A yeniden girince gönderilmemiş kuyruğu **duruyordur**"* **FAIL** (ikincisi *"çıkışta her şeyi sil"* mutasyonunu yakalar ⇒ kırmızı çizgi #4) | DART | **[devir]** **K3-L8(4)** — **v7'de doğdu (B6-6 · K34-c)**; kapısı `slice-3b` spec'inde koşar |

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
| K3-L2'nin `HttpOnly`/`SameSite`/`Max-Age` öznitelikleri | Karar olarak yazılmışlardı ama **hiçbir mutant ölçmüyordu** (Ma-6) | **M36b** |
| K3-L3(3)'ün **aile bağı** ayağı | M35 yalnız **imzayı** ölçüyordu ⇒ *"başka ailenin doğru imzalı token'ı"* geçerdi (Ma-6) | **M35**'in ikinci ayağı |
| K3-L10'un *"başlık yoksa `400`"* kuralı ve native-çerez-yok ayağı | Kapısızdı (Ma-6) | **M43**'ün üçüncü ayağı |
| K3-B6'nın e-posta **254 + format** ayakları | Kapısızdı (Ma-6) | **M52** |
| K3-C6(2)'nin **dal (a)** ve dal önceliği | Kapısızdı (Ma-2/Ma-6) | **M44** |
| **K3-I4'ün HKDF `info` etiketleri** | Kapı-4 majör #13: etiketlerin **bayt kodlaması** hiçbir yerde sabitlenmiyordu ⇒ *"neyin özeti"* kusurunun birebir kardeşi | **M42b** |

**BUGÜN MUTANTSIZ OLANLAR — hepsi bilinçli, hepsi gerekçeli. Bu liste, tablonun tamlık iddiasının sınırıdır:**

> **🔬 BU İDDİA ARTIK ÖLÇÜLÜYOR — v5'in en önemli yapısal değişikliği [K18-d / K19-c].**
> Kapı-2, kapı-3 ve kapı-4'ün **üçü de** bu cümleyi çürüttü (sırasıyla #15 → B7 → B-3): liste her seferinde
> **eksikti** ve eksikliği **elle** bulmak zorunda kalındı. **v5'te cümle geri çekilmedi — ölçülür hâle getirildi.**
> **`araclar/adr-kapi-taramasi.py`** her `**K3-…**` kararını çıkarır ve ya §3 mutant tablosunun **çıpa sütununda**
> ya bu tabloda **etiketiyle** geçtiğini doğrular; geçmiyorsa **`K1` bulgusu** üretir. **v5'in koşumunda `K1` = 0'dır**
> **(ÖLÇÜLDÜ — oturum 23, onarılmış araçla, v6 üzerinde: `karar` 47 · `alt_madde` 12 · **`kapili` 32** · **`beyanli` 15** · `devredilmis` 5 · `mutant` 51.)**  <!-- [KS-LITERAL: ARACIN ÖLÇÜM KAYDI — bunlar kanonik sayı değil, aracın bu belge üzerindeki sayımıdır] -->
> ⚠ **v5 burada *"36'sı kapılı, 11'i burada beyanlı"* yazıyordu — BAYATTI ve düzeltilmiştir.** O sayılar aracın **B5-3 onarımından ÖNCEKİ** koşumundan geliyordu: eski araç `K1`'i çıpa sütunundan değil §3'ün **tüm metninden** çözüyordu ⇒ §3.1'de *"kapısızdır"* diye beyan edilen kalemleri de **kapılı** sayıyordu (kapı-5 bunu ölçtü: gerçek dağılım o gün **31 kapılı · 11 beyanlı · 5 devredilmiş** idi)  <!-- [KS-LITERAL: kapı-5'in ÖLÇÜM KAYDI — tarihsel sayım] -->. **Bu belgede bir sayı, onu üreten ölçüm aracı değiştiğinde YENİDEN ÖLÇÜLÜR** — bu satır o kuralın kendisine uygulanmış hâlidir.
>
> **⚠ ARACIN YEŞİLİ TEK BAŞINA KANIT DEĞİLDİR — DÖRT sınırı açıkça yazılıyor** <!-- v7/oturum-26: v6 "üç" diyordu; (4) eklendiği için sayı düzeltildi (B6-4/B6-5) -->**:**
> **(1)** Aracı **v5'i yazan oturum yazdı** ⇒ *üreten ≠ denetleyen* bu kalemde kısmen delindi; **kapı-5, ARACIN
> KENDİSİNİ de denetlemek zorundadır.** **(2)** Araç **etiketin varlığını** ölçer, mutantın o kararı **gerçekten
> ısırdığını** ölçemez — çıpa sütununa etiket eklemek, kapıyı bir **tiyatroya** çevirebilir; bu yüzden yukarıdaki
> `**[çıpa+]**` işaretli her eklemenin **gerekçesi satırın içinde yazılıdır** ve kapı-5 bunları tek tek zorlamalıdır.
> **(3)** 🔴 **v7 DÜZELTMESİ [B6-5 — BLOKER kapanıyor]: BU MADDE BİR GÜVENCEYDİ VE GÜVENCE YANLIŞTI; ARTIK BİR SINIRDIR.**
> v6 birebir *"Araç, altın kümede kendini kanıtlamadan **koşmaz** (`--altin-kume`, çıkış kodu 2)"* diyordu.
> **KAYNAKTAN ÖLÇÜLDÜ (`araclar/adr-kapi-taramasi.py`, satır 880-881, birebir):**
> `if a.altin_kume:` / `    return altin_kume()` ⇒ **altın küme, YALNIZ `--altin-kume` bayrağı verildiğinde koşar
> ve o koşumda araç ADR'yi HİÇ TARAMAZ (erken `return`).** Bayraksız normal bir tarama (`python araclar/adr-kapi-taramasi.py <adr>`)
> altın kümeyi **hiç çalıştırmaz.** ⇒ **Doğru ifade budur ve bir SINIRDIR:** *altın küme ile ADR taraması
> **iki AYRI koşumdur**; bu belgedeki her araç sayısı, altın kümenin **AYNI koşumda** doğrulanmadığı bir taramadan gelir.*
> **Telafi bir kapı DEĞİL, bir YOL kısıtıdır** (K3-I4'ün telafi kalıbıyla aynı sınıf): ölçümü raporlayan el,
> **altın kümeyi ayrıca koşup çıkış kodunu KANIT'a yazmakla** yükümlüdür — ve bu yükümlülük **mekanik olarak
> zorlanmaz.** *(Araç ONARILMAZ: K34-f, 2. onarım AYRI ELE aittir. Kusur burada **adıyla** duruyor.)*
> Altın kümenin kendisi gerçektir ve yazım sırasında **kendi kör noktalarından DÖRDÜNÜ üretip yakaladı; kapı-5 BEŞİNCİSİNİ buldu** (rakamsız kanonik değer sessizce düşüyordu) ⇒ araç **oturum 22'de onarıldı** — altın küme **5 → 21 kontrole** çıktı, ayrıca farklı bir modelle SALDIRILDI; **kapı-6 21 kontrolün 21'ini mutasyonla zorladı ve 21'i de ısırdı.** Kanıt: `KANIT/adr-0003/olcum-araci-altin-kume-kanit.txt` + **`KANIT/adr-0003/olcum-araci-onarim-kanit.txt`**.
>
> **(4) 🔴 ARACIN BİLİNEN SINIRLARI — ADIYLA BEYAN [B6-4'ün ADR AYAĞI; araç ONARILMAZ, K34-f].**
> *Kapı-6, aracın bir davranışının §3.1'de **hiç yazılmadığını** ölçtü. Buradaki liste o borcu kapatır:
> bu belgedeki `K1`…`K7` sayıları bu sınırların ALTINDA okunmalıdır ve **tek başına kanıt değildir.***
> - **`K4`'ÜN SESSİZ KAÇIŞ FİLTRESİ [kaynak satır 412, birebir]:** `if ("KANONİK" in s) or ("§1-K" in s):` → `continue`.
>   ⇒ İçinde **`KANONİK`** ya da **`§1-K`** dizgisi geçen **HER satır**, `K4` (kopyalanmış kanonik sayı) taramasından
>   **tümüyle düşer** — satırın gerçekten §1-K bölgesinde olup olmadığına bakılmaksızın. Amaç kanonik tabloyu
>   muaf tutmaktı; **fiili sonuç**, gövdede §1-K'ya **atıf yapan** bir satırın da sessizce muaf kalmasıdır.
>   **Bu filtre `[KS-LITERAL:` muafiyetinin aksine RAPORLANMAZ** (o muafiyet SALDIRI-1'den sonra adıyla raporlanır hâle
>   getirilmişti; bu ise hâlâ sessizdir). ⇒ **bu belgedeki HER `K4` sonucu, bu filtrenin ARDINDAN okunmalıdır:
>   `K4 = 0` bir *"kopya yok"* güvencesi DEĞİL, *"filtrenin görebildiği yerde kopya yok"* ölçümüdür.**
> - **ALTIN KÜME AYRI KOŞUMDUR** (yukarıdaki (3)).
> - **`K1` yalnız ETİKETİN VARLIĞINI ölçer**, mutantın kararı gerçekten ısırdığını ölçemez (yukarıdaki (2)).
> - **`K4`'ÜN İKİ YANLIŞ-POZİTİFİ DÜZELTİLMEDİ ve KÖK NEDENİ v7'DE ÖLÇÜLDÜ: YAPISALDIR.** Kök neden tek:
>   **§3.2'nin hız-sınırı izolasyon maddesine yapılan bölüm atfındaki madde numarası**, `[KS-4]`'ün `±1` sınır
>   deseniyle çakışır (aşağıdaki `K4` adjudikasyon bloğu). Tetiklenen satırlar M11 ve M41'in kill sinyalleridir.
>   ⚠ **v7'de ÖLÇÜLDÜ ve gizlenmiyor:** bu maddenin **ilk yazımı** o bölüm atfını **rakamıyla** içeriyordu ve
>   **kendisi de aynı yanlış-pozitifi tetikledi** — *"aracın iki yanlış-pozitifi var"* diye yazan cümle **üçüncüsünü
>   üretti**; ölçüm bunu yakaladı ve cümle **atfı rakamsız yazacak biçimde** düzeltildi. ⇒ Yanlış-pozitif **yapısaldır**:
>   o maddeye rakamıyla atıf yapan **her** satır tetikler. **Kalan iki bulgu bilinçli olarak DÜZELTİLMİYOR** (ne belgede
>   ne araçta): belgeyi ölçüm aracına uydurmak *"kapı tiyatrosu"*dur, aracı onarmak ise **AYRI ELİN işidir** (K34-f).
>   **Kapı-7'ye not: `K4`'ün taban çizgisi sıfır DEĞİL İKİ'dir ve ikisi de adıyla beklenen bulgudur.**
> - **ARACI v5'İ YAZAN OTURUM YAZDI** (yukarıdaki (1)) ve **2. ONARIMI HENÜZ YAPILMADI** (K34-f) ⇒ **kapı-7,
>   aracı v7 ile birlikte BAĞIMSIZ nesne olarak denetlemek zorundadır.**

> **🔢 `[çıpa+]` SAYISI KAYNAKTAN ÇÖZÜLDÜ [kapı-5 majör M5-4 — kapanıyor].**
> Hafıza (K23/K24) *"**18** mutantın çıpa sütununa etiket eklendi"* diyordu; kapı-5 v5'te **16** mutant satırı saydı ve *"iki etiket eksik ya da sayı şişirilmiş"* dedi. **Oturum 23'te kaynaktan sayıldı — cevap: SAYI ŞİŞİRİLMİŞTİ, ETİKET EKSİK DEĞİLDİ.** v5'te `[çıpa+]` **12 mutant satırında** + `[devir]`in atası **4 M-L satırında** = **16**; kapı-5'in sayımı **doğruydu**. **18, hiçbir zaman ölçülmüş bir sayı değildi** — yazım oturumunun *niyetinden* hafızaya geçmiş bir tahmindi ve bu belgeye hiç girmedi (v6'da `18` iddiası **yoktur**; `grep` ⇒ 0). v6'nın bugünkü dağılımı: **`[çıpa+]` 12 mutant satırı · `[devir]` 5 M-L satırı** (v6, `K3-L9`'u da devir işaretiyle kapsayarak 4'ü 5'e çıkardı). ⇒ **Kayıp etiket YOKTUR; kayıp olan ÖLÇÜMDÜ.** *Ders — bu belgenin kendi §4 kuralının hafızaya uygulanmış hâli: bir sayı hafızaya yazılırken de ya ölçülür ya `[TAHMİN]` diye işaretlenir.*  <!-- [KS-LITERAL: ÇIPA SAYIM KAYDI — bu satırdaki sayılar kanonik değer değil, etiket SAYIMIDIR (v5 ve v6 ölçümleri); atıfla yazılamazlar] -->

> **📊 `K4`'ÜN ADJUDİKASYONU [oturum 23 — K30-b'nin uygulanması; SESSİZ ELEME YOKTUR].**
> Onarılmış araç v6 üzerinde önce **35** `K4` bulgusu üretti. Kalem kalem adjudike edildi:
> **(a) 26'sı GERÇEK KOPYAYDI ve ATFA ÇEVRİLDİ** (`[KS-21]` · `[KS-22]` · `[KS-26]` · `[KS-20]` · `[KS-1]` · `[KS-8]` · `[KS-9]` ailesi) ya da **gerekçesiyle `[KS-LITERAL]` işaretlendi** (reddedilen alternatiflerin sayıları · geri çekilen literallerin tarihsel kaydı · aracın kendi ölçüm kaydı · AAD bileşenlerinin bayt kodlaması pini).
> **(b) 2'si TARİHSEL DEĞİŞİM KAYDIDIR** (*"sayı 11→31"*): bir düzeltmenin **ne olduğu** ancak eski ve yeni sayı birlikte yazılarak anlatılabilir; atıfla yazılamaz.  <!-- [KS-LITERAL: `K4` ADJUDİKASYON KAYDI — bu satırlardaki sayılar kanonik değer DEĞİL, aracın bulgu sayımı ve adjudike edilen literallerin kendisidir; atıfla yazılamazlar] -->
> **(c) 2'si ARACIN YANLIŞ-POZİTİFİDİR ve DÜZELTİLMEMİŞTİR — bu bir DÜRÜSTLÜK KARARIDIR [kapı-6 doğrulasın].** Araç, `[KS-4]`=10 dk için satırda **`9`** ya da **`11`** arar; M11 ve M41 satırlarındaki `9`, bir sayı değil **`§3.2(9)` BÖLÜM ATFIDIR.** Bu satırları aracı susturmak için yeniden yazmak, belgeyi ölçüme değil **ölçüm aracına** uydurmak olurdu — projenin *"kapı tiyatrosu"* diye adlandırdığı şeyin ta kendisi. **Bulgu açık bırakılmıştır ve burada adıyla yazılıdır.**  <!-- [KS-LITERAL: `K4` ADJUDİKASYON KAYDI — bu satırlardaki sayılar kanonik değer DEĞİL, aracın bulgu sayımı ve adjudike edilen literallerin kendisidir; atıfla yazılamazlar] -->
> **⚠ K30-b'NİN ÖLÇÜLMÜŞ SONUCU — ONUR'A DÜRÜST RAPOR:** Onur *"dokuz sınır-değer literalinin hepsi `[KS-n] ± 1` biçimine çevrilsin"* diye kilitledi. **Kaynaktan ölçüldü: ÇEVRİLECEK GERÇEK BİR SINIR-DEĞER LİTERALİ YOKTU.** Aracın *"SINIR DEĞER"* başlığı altında raporladığı satırların tamamı ya bölüm atfı (`§3.2(9)`), ya tarihsel değişim kaydı (`11→31`), ya ölçüm kaydı, ya da bayt kodlaması pinidir. **Gerçek sınır-değer kill sinyalleri (M31 · M52) v6'ya ZATEN atıflı biçimde yazılmıştı** (*"`[KS-17]`'den bir eksik"* · *"`[KS-18]`'den bir fazla"* · *"`[KS-19]`'dan bir fazla"*). ⇒ **K30-b'nin kuralı YÜRÜRLÜKTEDİR ve bundan sonra yazılacak her kill sinyalini bağlar; ama bu turda uygulanacak bir kalem BULUNMAMIŞTIR.** Kilidi "uygulandı" diye raporlamak, yapılmamış bir işi yapılmış ilan etmek olurdu.  <!-- [KS-LITERAL: `K4` ADJUDİKASYON KAYDI — bu satırlardaki sayılar kanonik değer DEĞİL, aracın bulgu sayımı ve adjudike edilen literallerin kendisidir; atıfla yazılamazlar] -->

| kapısız kalan | neden mutant yazılmadı |
|---|---|
| **`RequireSignedTokens` / `RequireExpirationTime`** | Mutasyonu, çerçevenin **token üreticisini** mutasyona uğratmayı (imzasız/`exp`'siz token üretmeyi) gerektirir. `ClockSkew` ve `ValidAlgorithms` **istisnadır** çünkü ikisi de **sessiz bir varsayılanı** değiştirir ve doğrulayıcı tarafta ölçülebilir (M16). |
| **K3-C4'ün ≤ `[KS-1]` sınırı** *(kararın TAMAMI değil — YALNIZ BU ÖZELLİK)* | Bir **beyandır**, bir mekanizma değil. Mekanizması `exp`'tir ve onu M16 ısırır. **[K30-c — ÖZELLİK DÜZEYİNE DARALTILDI]** ⚠ **`K3-C4`'ün KENDİSİ KAPISIZ DEĞİLDİR:** kararın *"`/logout` yalnız o aileyi düşürür"* ayağı §3'te **M18 ile KAPILIDIR**. Ölçüm aracı KARAR-ID düzeyinde çalıştığı için bu satırı *"kapılı ↔ kapısız-beyanlı çelişkisi"* (`K6`) diye ihbar eder; **çelişki yoktur, GRANÜLERLİK FARKI vardır** ve burada adıyla yazılmıştır. |
| **K3-C8 `security_stamp`** | **Ölü alandır** (K14-d) — ölü bir alanın mutantı da ölü olurdu. Canlandırılırsa mutant **zorunlu** olur. |
| **K3-A3 `/register` sayım oracle'ı** | **Adlandırılmış sapmadır**; mutantı *"sapmayı geri al"* olurdu ve bu bir kapı değil bir **karar değişimidir**. |
| **K3-B4'ün SABİT-ZAMAN ÖZELLİĞİ** *(kararın TAMAMI değil — YALNIZ BU ÖZELLİK)* | **[K30-c — ÖZELLİK DÜZEYİNE DARALTILDI]** ⚠ **`K3-B4`'ün KENDİSİ KAPISIZ DEĞİLDİR:** *"`FixedTimeEquals` çağrılır, `SequenceEqual` yasaktır"* ayağı §3'te **M6 (derleme) ve M6b (davranış) ile KAPILIDIR**; kapısız olan **yalnız** aşağıda tarif edilen **zamanlama özelliğidir**. Ölçüm aracı KARAR-ID düzeyinde çalıştığı için bu satırı `K6` ile ihbar eder; **çelişki yoktur, GRANÜLERLİK FARKI vardır.** **[Ma-6 — açıkça beyan ediliyor]** `FixedTimeEquals` çağrısının **varlığı** M6 (derleme) ve M6b (davranış) ile kapılıdır; ama *"elle yazılmış, erken çıkışlı bir döngü"* **ikisini de geçer** ve onu yakalayacak şey bir **zamanlama testidir**. Zamanlama testleri CI'da **kırılgandır** (gürültü, JIT, paylaşımlı runner) ⇒ bu belgenin *"ölü tuzak yazma"* kuralına aykırı olurdu. **Telafi kapı değil, gözden geçirmedir:** kod incelemesinde bu satır **adlandırılmış bir kontrol kalemidir**. Bu bir sınırdır ve gizlenmiyor. |
| **K3-L1/L2'nin platform seçimi** | İstemci tarafıdır ve paket seçimidir; kapısı `slice-3b`'nin lisans+CVE kapısıdır (kırmızı çizgi 3). |
| **K3-J6'nın NAT yanlış-pozitifi** | Kabul edilmiş bir **bedeldir**, bir mekanizma değil. (B2'den sonra bu bedel **varsayılan** durumdur — §6 Risk #14.) |
| **§2-M'nin `IAccessTokenIssuer`/`IRefreshTokenStore`/`ICsrfTokenService` port SATIRLARI** | Bunlar **port yerleşimi** kararlarıdır; NetArchTest ile ifade edilen **namespace kısıtları** yukarıda mutantlandı (M32/M32b/M32c). Portun **adı ve yeri** bir mimari tercihtir, ihlal-edilebilir bir kural değildir. |
| **`slice-3b`'ye devredilenler (M-L5…M-L9)** | Bu belgede **kapısızdır ve öyle olduğu yazılıdır**; kapıları `slice-3b` spec'inde koşar. Devir listesi §7'dedir. |
| **K3-A1 — `User` entity'sinin alan kümesi** | Bir **veri modeli** kararıdır: alan eklemek/çıkarmak hiçbir davranış testini kırmaz, dolayısıyla ısıran bir mutant **kurulamaz**. Kırmızı çizgi #2 (asgari PII) bir kod kuralı değil **tasarım kuralıdır**. Gerçek kapısı **şema testidir ve ADR 0004'ün işidir** (`users` tablosunun kolonları). *(Bu satır, kapısızlığı ilan eder; ADR 0004 bu borcu devralır.)* |
| **K3-A4 — `User` senkronlanabilir kök DEĞİLDİR** | Kapısı **yapısal olarak ADR 0004'tedir**: *"`User`, `/sync` teline eklenirse test kırılır"* mutantı **sync sözleşmesini** ısırtır ve o sözleşme bu belgenin kapsamı dışındadır (0004: `owner_id`, push/pull-authz). Burada **kısıt olarak** yazılır, **kapısı 0004'te açılır** — ve bu, ADR 0004'ün açık bir borcudur. |
| **K3-D4 — `User.Identity.Name` KULLANILMAZ** | `MapInboundClaims=false` altında `ClaimTypes.Name` eşlemesi zaten koşmaz ⇒ kural bir **kodlama disiplini**dir, ısırtılabilir bir davranış farkı üretmez: `User.Identity.Name` kullanan bir implementasyon **zaten `null` alır ve patlar**, yani mutasyon **baseline'ı** kırar, kapıyı değil. **M24** komşu kararı (`"sub"` okuması) ısırtır; bu kalem onun **gerekçe notudur**, ayrı bir kapı değildir. |
| **`[KS-11]` ve `[KS-12]` tavanları (kontrol 1'in `/refresh` ve `/logout` aileleri)** | **[v7 — kapı-6 majör #2 kapanıyor]** §1-K bu iki satırda *"(kapısız — §3.1)"* diyordu ama **§3.1'de karşılık gelen satır YOKTU** ⇒ **sarkan beyan** (B5-5/B6-8 ailesi). Beyan burada yazılır: **ikisi de KAPISIZDIR.** Neden: `[KS-10]`'un kovasını ısırtan **M11** ve **M23** kontrol 1'in **mekanizmasını** zaten ölçer; `[KS-11]`/`[KS-12]` **aynı mekanizmanın farklı TAVANLARIDIR** ve tavanı ısırtmak için o uçlara `[KS-11]`+1 / `[KS-12]`+1 istek atmak gerekir — **§3.2'nin izolasyon maddesi pencereyi ilerletmeyi YASAKLADIĞI için** bu ancak her tavan için **ayrı bir fabrika ve yüzlerce istek** ile kurulabilirdi. **Kabul edilen bedel:** üç politikanın **ayrı ayrı bağlandığı** (K16-b) mekanik olarak doğrulanmaz; ısırtılan şey **politika ayrımının VARLIĞI değil, kontrol 1'in kendisidir.** *(Kapı-7'ye açık soru olarak bırakılıyor: `RequireRateLimiting` politika ADLARININ uçlara doğru bağlandığını ölçen ucuz bir `NA`/`TS` kapısı kurulabilir mi?)* |
| **`[KS-24]` — Argon2id'nin ÖLÇÜLEN maliyeti** | **[v7 — kapı-6 majör #2 kapanıyor]** §1-K *"(ölçüm, kapı değil — §3.1)"* diyordu, §3.1'de satır **YOKTU** ⇒ aynı sarkan beyan. Beyan burada: **bu bir KARAR değil ÖLÇÜMDÜR** (Onur'un makinesi, 25 Tem 2026) ⇒ **kapısı olmaz**; yanlışsa **yeniden koşularak** çürütülür. Argon2id'nin *parametreleri* (`[KS-23]`) **M5 · M32 ile kapılıdır**; kapısız olan şey **ölçülen süre/bellek rakamıdır.** |
| **K3-J5 — Rate limiter partition belleği `[KS-9]`** | Bu bir **karar değil ÖLÇÜMDÜR** (dotnet kaynağından okunan atıl-temizleme davranışı). Ölçümün kapısı olmaz; yanlışsa **kaynağa bakılarak** çürütülür. Belgede **§4 kuralı gereği** ölçüm olarak etiketlidir. |
| **K3-K1 — ASP.NET Core Identity KULLANILMAZ** | **Negatif bir kapsam kararıdır.** Bir paketin *kullanılmadığını* ısırtan mutant, o paketi **eklemek** olurdu — bu bir mutasyon değil **yeni bir bağımlılıktır** (kırmızı çizgi #3'ü tetikler) ve mutant testi olarak commit edilemez. `Konscious.*` izolasyonu (**M32**) aynı yüzeyi **pozitif** yönden koruyor: hash yolu Infrastructure'da kilitli olduğu sürece Identity sessizce sızamaz. |
| **K3-K3 — Kapsam dışı listesi** | **Kapsam beyanıdır**, mekanizma değildir; ısırtılacak bir davranışı yoktur. Doğruluğu **ODEV §6.1 ile karşılaştırılarak** denetlenir (kapı-4 bunu yaptı: *"kapsam kayması YOK; K3-K3'ün listesi ODEV §6.1'in kesin üst kümesi"*). |
| **K3-L5 · K3-L6 · K3-L7 · K3-L8 (dördüncü dalı **`K3-L8(4)`** dâhil) · K3-L9 — istemci sözleşmesinin beş kararı** <!-- v7/oturum-26: `K3-L8(4)` (çıkışta aktif profil kaydının temizlenmesi, B6-6/K34-c) bu satıra ADIYLA eklendi — aracın `K1` bulgusu onu "kapısız-ve-beyansız alt madde" diye ihbar etti ve HAKLIYDI: kapısı `M-L10`'dur ama `[devir]` işaretli çıpa KAPI SAYILMAZ ⇒ beyan ZORUNLUDUR --> | **`slice-3b`'ye DEVREDİLDİ; bu belgede KAPISIZDIR.** Kapıları `M-L5…M-L10`'dur (🆕 **`M-L10`** = `K3-L8(4)`) ve **`slice-3b` spec'inde koşar** (Dart tarafı). **[kapı-5 B5-3 — DÜZELTME]** v5 bu beyanı yalnız **mutant kimliğiyle** (*"M-L5…M-L9"*) yazıyordu ⇒ karar kimliğiyle arayan ölçüm aracı beşini de **kapısız-ve-beyansız** görüyordu; üstelik M-L tablosundaki `[çıpa+]` etiketleri onları aynı anda **kapılı** gösteriyordu (**çelişki**). Etiketler `[devir]` yapıldı, beyan buraya karar kimliğiyle yazıldı. |

### 3.2 — KOŞUM SÖZLEŞMESİ: TESTLERİN NASIL AYAĞA KALKACAĞI PİNLENİR [YENİ — Ma-13/Ma-14 ve denetimin "ölçülemeyenler" kalemi]

> Denetim şunu bulguladı: *"builder'ın koşum tercihleri (minimal API mi controller mı, `AddProblemDetails()` çağrılıyor mu, `WebApplicationFactory` mi çıplak `TestServer` mi) — M37 ve M19'un kesin sonucu buna bağlı; **ADR bunu yazmıyor ve bu başlı başına bir eksikliktir.**"* Bu bölüm o eksikliği kapatır. **Aşağıdakiler mutantların önkoşuludur, üslup tercihi değildir.**

1. **`TS` seviyesindeki her test `WebApplicationFactory<Program>` ile ayağa kalkar** — çıplak `new TestServer(...)` **YASAKTIR**. *Gerekçe:* `WebApplicationFactory` üç ayrı yolda `UseEnvironment(Environments.Development)` çağırır (ölçüldü) ⇒ `ValidateOnBuild`/`ValidateScopes` **açıktır** ⇒ **M19 ısırır**. Çıplak `ServiceCollection` ile mutant sessizce hayatta kalır.
2. **Kimlik doğrulama testleri gerçek `AddJwtBearer` boru hattından geçer** — sahte `TestAuthHandler` / `AuthenticationSchemeOptions` ikamesi **YASAKTIR** (M24, M16, M48'in önkoşulu).
   > **⚠ AMA ASIL İKAME BAŞKA BİR ADLA ZATEN VAR — Y-3 [oturum 21'de ölçüldü, kapı-4 bunu göremezdi].** Repoda `TestAuthHandler` **yoktur** ve `AddAuthentication` **hiç çağrılmamaktadır** (`grep` src+tests ⇒ 0 eşleşme; `Program.cs` satır 108-110 birebir: *"There is no authentication scheme yet…"*). ⇒ **bu yasak geriye dönük hiçbir testi kırmaz.** Bugünkü kimlik ikamesi **`FakeCurrentUser`**'dır: `ICurrentUser`'ın sabit-kimlik stub'ı (`tests/Momentum.Persistence.Tests/FakeCurrentUser.cs`, `Compile Include` ile `Momentum.Api.Tests`'e de bağlı), üretimde yerini `NullCurrentUser` alır (`Program.cs:45`).
   > **KARAR [PAZARLIKSIZ]:** `slice-3c` sonrasında **kimlik doğrulamayı ölçen** hiçbir test `ICurrentUser`'ı DI'dan ikame **EDEMEZ** — kimlik **gerçek token'dan** gelir. `FakeCurrentUser` yalnız **kimliğin konusu olmadığı** testlerde (senkron/kalıcılık/gerçek zamanlı — ADR 0002 ailesi) yaşamaya devam eder ve orada **mevcut davranışı korunur**. *Gerekçe:* aksi hâlde `TestAuthHandler` yasağı deliği kapatmaz, **yalnız adını değiştirir** — ve M15/M33a/M33b'nin ölçtüğü şey (kimliksizde `401`) DI ikamesiyle **atlanabilir** hâle gelir.
3. **`AddProblemDetails()` çağrılır ve `DefaultProblemDetailsWriter` kullanılır** — özel bir `IProblemDetailsWriter` yazılmaz. *Gerekçe:* M37'nin *"`traceId` hariç aynı"* sinyali bu yazıcının davranışına pinlidir; özel yazıcı sinyali sessizce değiştirir.
4. **Uç stili: `MapGroup("/v{version:apiVersion}").WithApiVersionSet(versionSet)` + minimal API UÇ DELEGELERİ** *(**ÖLÇÜLDÜ [oturum 22]:** repodaki dört uç dosyasının dördü de bu biçimi kullanıyor — `DiagnosticsEndpoints.cs:16` · `SyncEndpoints.cs:19` · `TaskEndpoints.cs:22` · `TaskListEndpoints.cs:18`. v5in `/v1` literali **olgusal olarak yanlıştı** ve auth uçlarını mevcut sürümleme setinin DIŞINDA bırakırdı.)* *(K18-a'nın adlandırma kuralı: bunlar **Api uç delegesidir**, `Application handler`'ı DEĞİLDİR).* *(Controller'lar yasak değildir ama `[Authorize]`/`AllowAnonymous` metadata'sının nereye düştüğü M14/M33a'nın sinyalini etkiler ⇒ **tek stil pinlenir**.)*
5. **`TimeProvider` testte `FakeTimeProvider`'a ÇEVRİLİR — ve bu bir OTOMATİK durum DEĞİL, fixture'ın AÇIK İŞİDİR.**
   > **🔴 v4'ÜN CÜMLESİ OLGUSAL OLARAK YANLIŞTI — Y-2 [oturum 21'de ölçüldü].** v4 *"`TimeProvider` **her testte** `FakeTimeProvider`'dır"* diyordu. **Ölçüm:** `src/backend/Momentum.Api/Program.cs` satır 34 birebir `builder.Services.AddSingleton(TimeProvider.System);` ve mevcut testlerin çoğu (`DispatcherTests`, `TestSupport.cs:73`) **`TimeProvider.System`** kullanıyor; `FakeTimeProvider` bugün **tek bir yerde** geçiyor (`DispatcherTests.cs:194`). ⇒ `WebApplicationFactory<Program>` ile kalkan bir test, **fixture açıkça ezmedikçe GERÇEK SAATİ alır** ve M17/M27/M29/M30/M40 **sessizce gerçek zamana bağlanır**.
   > **KARAR [PAZARLIKSIZ]:** saat ilerletmeye dayanan her `TS`/`TC` testi fixture'da **açıkça** `builder.ConfigureServices(s => s.Replace(ServiceDescriptor.Singleton<TimeProvider>(new FakeTimeProvider(...))))` yapar. **PAKET, TESTLERİN YAŞAYACAĞI PROJEDE BUGÜN YOKTUR ve EKLENECEKTİR [kapı-5 majör M5-7 — v5'in *"paket zaten repodadır"* cümlesi FAZLA GENİŞTİ].** **Ölçüldü (Onur'un diskinden, dört test `.csproj`'unun tamamı, 25 Tem 2026):** `Microsoft.Extensions.TimeProvider.Testing` **9.0.0** yalnız `tests/Momentum.Persistence.Tests`'tedir; **`tests/Momentum.Api.Tests`'te YOKTUR** (o projede bugün yalnız `Microsoft.NET.Test.Sdk` 17.12.0 · `xunit` 2.9.2 · `xunit.runner.visualstudio` 2.8.2 · `Shouldly` 4.3.0 · `Microsoft.AspNetCore.Mvc.Testing` 9.0.18 · `Microsoft.AspNetCore.SignalR.Client` 9.0.0 vardır). `Testcontainers.PostgreSql` **4.13.0** için de aynı durum geçerlidir: yalnız `Persistence.Tests`'tedir. ⇒ **KARAR:** `slice-3c-auth`'un `TS`/`TC` testleri `Momentum.Api.Tests`'te yaşar ve o projeye **iki `PackageReference` eklenir: `Microsoft.Extensions.TimeProvider.Testing` 9.0.0 ve `Testcontainers.PostgreSql` 4.13.0 — İKİSİ DE AYNI SÜRÜMDEN.** **Bu YENİ BİR BAĞIMLILIK DEĞİLDİR:** her ikisinin de lisans+CVE kapısı zaten koşmuştur (oturum 21 ölçümü; `Testcontainers` csproj yorumu birebir *"MIT"*) ve ikisi de `dependencies.md`'de zaten kayıtlıdır ⇒ **kırmızı çizgi #3 yeniden tetiklenmez**, ama **sürüm sapması tetiklenirse tetiklenir**: farklı bir sürüm eklemek yeni bir kapı açar ve YASAKTIR. *(v5 burada yalnız *"repoda var"* diye ölçmüştü; **hangi projede** olduğunu ölçmemişti — ve `TS` testleri o projede yaşamayacaktı ⇒ baseline temiz klonda **derlenmezdi**.)*
   > **⚠ VE BU EZME HIZ SINIRLAYICIYA İŞLEMEZ — bkz. madde 9.**
6. **`TC` seviyesi = Testcontainers + gerçek PostgreSQL**, her test sınıfı için **temiz şema**. `TestServer` içi kilitler ya da in-memory sağlayıcı **atomiklik iddialarını kanıtlamaz** (M39/M45).
7. **`KON` seviyesi = gerçek imaj.** `docker build` + `docker run`; gözlemlenen şey **çıkış kodu**, **stderr** ve **dosya sisteminin durumu**dur (M8b, M42c). Bu testler CI'da ayrı bir job'dadır ve **yerelde de koşabilir olmalıdır.**
   > **🔴 v4'TE BU SEVİYE VAR OLMAYAN BİR ARTEFAKTA ÇIPALIYDI — K22-a KAPATIYOR.** Ölçüldü (oturum 21): **`Dockerfile` YOKTUR**, `docker-compose.yml` yalnız `postgres:17-alpine` tanımlıyor. **K22-a ile API `Dockerfile` + giriş betiği + compose `api` servisi bu dilimin işidir** ⇒ `KON` gerçek olur.
   > **CI HENÜZ YOKTUR ve bu bir borçtur [kapı-4 majör #12]:** ODEV §8(4) CI/CD'yi 11-12 Ağu'ya koyuyor, `slice-3c` ondan **önce** koşuyor. ⇒ **`KON` testleri bu dilimde YERELDE koşulur ve KANIT'a yazılır**; CI job'ı kurulduğunda **aynı komutlar** oraya taşınır. *Bu bir sapmadır ve adlandırılmıştır*: `KON`'un *"CI'da ayrı job"* cümlesi bugün **niyet**, ölçüm değildir.
8. **Baseline kuralı [K6/K13-a'ya tabi değil]:** her mutant **gerçekten koşulur** ve mutasyondan **önce** testin **yeşil** olduğu kaydedilir. *"Beklenir"* diye akıl yürütmeyle KANIT yazılmaz (slice-2b1 BULGU-1 dersi).
9. **HIZ SINIRLAYICI İZOLASYONU PİNLENİR — `FakeTimeProvider` BU MEKANİZMAYI İLERLETEMEZ. [B-7 kapanır] [PAZARLIKSIZ]**
   **Ölçüldü (birincil kaynak, runtime `release/9.0`):** `FixedWindowRateLimiter` alanları birebir `private readonly Timer? _renewTimer;` ve `_idleSince = _lastReplenishmentTick = Stopwatch.GetTimestamp();`, karar noktasında `long nowTicks = Stopwatch.GetTimestamp();` ⇒ **`TimeProvider`'dan beslenmez; `FakeTimeProvider` enjekte edilemez.** Pencere testte **ilerletilemez.**
   İkinci ölçüm (K15-b): kontrol 1 **tek partition**'dır (`TestHost`'ta `RemoteIpAddress` **`null`**). ⇒ paylaşılan bir `WebApplicationFactory`'de M23'ün istekleri + M11'in istekleri + M52/M31'in `/register` çağrıları **aynı kovayı** doldurur ve **M41'in/M46'nın negatif assert'leri (`429` ALMAZ) SIRA BAĞIMLI olarak kırılır.**
   **Karar (üç kural):**
   1. 🔴 **v7 DÜZELTMESİ [B6-7 — BLOKER kapanıyor · K34-d]: İZOLASYON ARTIK *"HIZ SINIRINI ÖLÇEN"* SINIFLARLA SINIRLI DEĞİL.**
      v6 kuralı birebir *"**Hız sınırını ölçen** her test sınıfı KENDİ `WebApplicationFactory` örneğini kurar"* diyordu. **Bu TEK YÖNLÜ izolasyondu ve yetmiyordu (kapı-6 ölçtü):** kovayı dolduran istekler *"hız sınırını ölçen"* sınıflardan **gelmek zorunda değil** — `/login` ya da `/register` çağıran **HER** test (M31'in üç ayağı, M52'nin üç ayağı, M37, M34, M54, M5, M56 …) **aynı tek partition'a** yazar (kontrol 1 `TestHost`'ta tek partition'dır; yukarıdaki ikinci ölçüm) ve `FakeTimeProvider` pencereyi **ilerletemez** (birinci ölçüm), beklemek de **madde 3 ile YASAKTIR** ⇒ paylaşılan bir host, **`[KS-10]`'dan bir fazla** istekte `429` vermeye başlar ve `TS`/`TC` seviyesindeki mutantların **baseline'ı SIRA BAĞIMLI olarak KIRILIR** ⇒ **madde 8'in *"baseline yeşil doğar"* garantisi bugün KURULAMIYORDU.**
      **YENİ KURAL [PAZARLIKSIZ]: `/login` ya da `/register` çağıran HER test sınıfı KENDİ `WebApplicationFactory` örneğini kurar** (`IClassFixture` paylaşımı **YASAK**) ⇒ her sınıf **taze kova** ile başlar. Fabrika `await using` ile **kapatılır**.
      *Bu seçenek §3.2(10)'un **üretim eşdeğerliği** iddiasını tam korur, **test-only kanca doğurmaz** ve **yeni bir kanonik sayı doğurmaz.***
      **Bedel [adlandırılmış, gizlenmiyor]:** host başına kalkış maliyeti ⇒ `TS`/`TC` mutantlarının koşum süresi **belirgin artar**; ve **CI HÂLÂ KURULMAMIŞTIR** (madde 7'nin borcu, ODEV §8(4)) ⇒ bu maliyet bugün **Onur'un makinesinde** ödenir.
      > *Reddedilenler [adlandırılmış]:* **testte limiter'ı devre dışı bırakmak** (en ucuz; ama kapatma kancasının kendisi **kapısız bir davranıştır** ⇒ ona da mutant gerekir, yoksa üretimde de kapalı kalabilir = **kör kapı sınıfı**) · **test ortamında kova bütçesini yükseltmek** (limiter boru hattı üretimdekiyle aynı kalır; ama aynı tavan **iki yerde yaşar** ⇒ **K30'un *"bir sayı bir kez yazılır"* kuralıyla doğrudan sürtüşür** ve araç bunu **yeni bir `K4` kopyası** olarak raporlar).
   2. **Bir sınıf içinde birden fazla hız-sınırı testi varsa**, her test **kendi uç yolunu** kullanır ya da testler **tek bir test metodunda** birleştirilir — kovayı zamanla değil **izolasyonla** sıfırlarız.
   3. **Pencerenin DOLMASINI bekleyen test YAZILMAZ.** `Task.Delay(5 dk)` yasaktır; `[KS-10]`'un penceresinin dolmasına dayanan bir assert **kurulamaz**. Ölçülen şey **tavanın ısırdığıdır**, penceresinin **yenilendiği değil**.
   > *Reddedilen [adlandırılmış]:* `PartitionedRateLimiter`'ı test için `TimeProvider`'lı özel bir implementasyonla değiştirmek — o zaman test **kendi yazdığımız sahte limiter'ı** ölçer, `RequireRateLimiting` boru hattını değil ⇒ M11/M23/M46 **kör kapıya** dönerdi.
10. **TESTLERİN SIRRI NEREDEN ALDIĞI PİNLENİR. [B-9 kapanır — K18-c] [PAZARLIKSIZ]**
   **Kırılan zincir:** madde 1 `WebApplicationFactory<Program>` **zorunlu** kılıyor ⇒ **gerçek `Program` boot eder** ⇒ **K3-I2'nin fail-fast'i koşar** (kök anahtar yoksa `InvalidOperationException`). Üç kaynağın **üçü de kapalıydı:** `dotnet user-secrets` — belgenin **kendi cümlesi** *"klonla gelmez"* (K3-I3) · bootstrap dosyası — **giriş betiğindedir**, test sürecinde koşmaz · ortam değişkeni — belgede **hiçbir yerde yazılı değildi**. ⇒ `TS`+`TC` etiketli mutantların baseline'ı **temiz bir klonda KIRMIZI doğardı** = madde 8'in doğrudan ihlali.
   **Karar:** test fixture'ı, `WithWebHostBuilder(b => b.ConfigureAppConfiguration(c => c.AddInMemoryCollection(new[]{ KeyValuePair.Create("Momentum:MasterKey", TEST_MASTER_KEY) })))` ile kök anahtarı **test kodundan** sağlar. `TEST_MASTER_KEY`, test projesinde tanımlı, `[KS-20]` uzunluğunu karşılayan, **açıkça `TEST-ONLY` adlandırılmış** bir Base64 sabittir.
   **K3-I1 ile ÇELİŞMEZ ve nedeni açıkça yazılıyor:** K3-I1 *"**Varsayılan/gömülü anahtar YOKTUR**"* der — bu cümlenin öznesi **üretim kodudur**. Buradaki sabit **test yapılandırmasındadır**: üretim ikilisine (`Momentum.Api`, `Momentum.Infrastructure`) **girmez**, `Program` onu **hiçbir varsayılandan okumaz** (fail-fast aynen durur), ve kırmızı çizgi #1 (*"sırlar repoya girmez"*) ihlal edilmez çünkü repoya giren şey **bir üretim sırrı değil, bir test sabitidir** — üretimdeki hiçbir sistemi açmaz.
   **M8a ve M42c BU KARARDAN ETKİLENMEZ ve bu açıkça yazılıyor:** M8a `Production` ortamında **fail-fast'in kaldırılmasını** ısırtır; fixture'ın anahtarı `Development`/test yolundadır ve `Production` yolunu **hiç kurmaz**. M42c ise **`KON` seviyesindedir** — gerçek imajda koşar, fixture'ı hiç görmez.
   ⇒ **`TS` ve `TC` seviyelerinin baseline'ı artık temiz bir klonda YEŞİL doğar** (madde 8 karşılanır).
   > *Reddedilenler [adlandırılmış]:* **test başına CSPRNG anahtar** (sabit-anahtar optiği hiç doğmaz; ama M42'nin **kalıcılık** iddiası `TS`'te kurulamaz, tamamı `KON`'a yığılır) · **ortam değişkeni zorunluluğu** (üretimle birebir aynı mekanizma; ama *"klonla gelmez"* sorununu **testlere taşır** ve **CI henüz kurulmadı** — ODEV §8(4) ⇒ değerlendiricinin `dotnet test` demesi yetmezdi).

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
| Parola KDF | Argon2id (Konscious 1.3.1, izole) | Isopoh (**lisans ailesi `[DOĞRULANMADI]`** — eleme gerekçesi bu ölçüm yapılana kadar ASKIDADIR) · NSec-libsodium (**OWASP parametrelerinde koşmadı**) · PBKDF2 (K8-c yedeği) |
| **Parola politikası** | **NIST SP 800-63B-4: `[KS-17]` (tek faktör `SHALL`), karmaşıklık YOK, `[KS-18]`** [K16-a] | Kapsam dışı ilan etmek (**Argon2 DoS tavanı açık kalır**) · klasik kompozisyon kuralları (NIST-4 birebir *"SHALL NOT impose other composition rules"*) · **≥10'da kalıp adlandırılmış sapma yazmak** (doktrine uygun ama uyumun bedeli burada yalnız bir README satırı) · **12** (hiçbir standartta karşılığı yok ⇒ keyfi) <!-- [KS-LITERAL: REDDEDİLEN alternatifin sayısı — politikanın değil] --> |
| **Halefin saklanması** | **`successor_secret_enc`: HKDF alt anahtarıyla AES-256-GCM, `[KS-4]` sonra `NULL`** [K15-a] | Dal (c)'yi *"yeni token üret ama halef olarak kaydet"* diye yeniden yazmak (*"yeni döndürme yapılmaz"* cümlesi düşer, ailede satır birikir) · K14-a'yı tümüyle geri almak (uçak modu demosunun ortasında yeniden giriş) · şifresiz saklamak (DB dökümü = `[KS-2]`lük kullanılabilir token) |
| **Anahtar mimarisi** | **Tek kök anahtar + HKDF-SHA256 ile üç amaç-bağlı alt anahtar** [K16-c] | Üç ayrı sır (üç fail-fast + üç bootstrap + üç mutant; K15-a'nın *"üçüncü sır doğmasın"* kısıtının reddi) · iki sır (anahtar-amaç ayrımını kısmen bozar) · kök anahtarı üç yerde **doğrudan** kullanmak (aynı anahtarla hem imzalamak hem şifrelemek) |
| **Hız sınırı politikaları** | **Uç ailesine göre üç ayrı politika: `[KS-10]` · `[KS-11]` · `[KS-12]`** [K16-b] | Tek ortak kova (v3: 10/5 dk — **her F5 bir `/refresh`** olduğu için işbirliği demosunu keser) · 60/240/120 (kontrol 1'in DoS anlamı sembolikleşir) |
| Yenileme token'ı | Opak + DB + döndürme + reuse-detection | Stateless JWT-refresh (iptal edilemez) · tek uzun ömürlü JWT (çevrimdışı kuyruk kaybı) |
| **Kayıp yanıt telafisi** | **Sınırlı replay-idempotency (`[KS-4]`, halef tüketilmemiş)** | **Telafisiz adlandırılmış sınır** (RFC 9700 bunu maliyet sayar ama uçak modu demosunun ortasında yeniden giriş üretir) · **`Idempotency-Key`** (yeni tablo + TTL + temizleme; aynı sonuç, daha geniş yüzey) · **v1'in zarafet penceresi** (sonsuz zincir, K3-C6'daki tabloya bkz.) |
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
3. **Erişim token'ı anlık iptal edilemez** (≤ `[KS-1]` pencere) — beyan edilmiş sınır (K3-C4). **`security_stamp` bu pencereyi sıfırlayabilirdi ve bilinçli olarak KULLANILMIYOR** (K3-C8/K14-d). `ClockSkew=0` sayesinde pencere gerçekten **`[KS-1]`**'dir — `[KS-8]`'in ezilmemiş varsayılanı kadar fazlası değil.
4. **Argon2id `[KS-24]`** — gerçek maliyet; sahte hash (K3-B5) bunu bilinmeyen e-postalarda **da** ödetir. Maliyeti sınırlayan **kontrol 1'in küresel tavanı + eşzamanlılık limitidir** — ve **asıl koruyan eşzamanlılık limitidir** (kontrol 1 bir tavandır, bir ayrım değil; B2/K15-b); e-posta penceresi maliyete **hiçbir şey katmaz**. Kalan yüzey: **botnet/proxy havuzu** — tek IP penceresi onu durdurmaz; eşzamanlılık limiti hizmeti ayakta tutar ama **gecikme artar**. Tek-instance bir ödev dağıtımında **kabul edilen ve beyan edilen** sınır.
5. **~~Rate limiter partition belleği~~ → ✅ KAPANDI** (K3-J5, ölçüldü: `[KS-9]` atıl temizleme). **Kalan doğru ifade [v4'te DÜZELTİLDİ — B2]:** tavan ≈ istek hızı × `[KS-9]`, ve tavanı anlamlı kılan şey **kontrol 1'in küresel istek tavanıdır** (`[KS-10]`). v3 burada *"IP penceresidir"* diyordu; **tek konteynerde IP penceresi diye bir şey yoktur.**
6. **RateLimiter'ın çok-instance davranışı** — bellek-içi sayaç **tek instance'a** özgüdür. Tek-instance dağıtımda sorun değil; K3-K3'te kapsam dışı.
7. **Web dağıtım topolojisi KİLİTLİ: tek konteyner, aynı origin, proxy yok** (K3-L4 / K14-e). **Kalan yüzeyler adlandırıldı:** (a) `SameSite=Strict` **kardeş alt alan adlarını** kapsamaz ⇒ K3-L3'ün imzalı ikinci hattı durur · (b) **`Secure` çerez `http://localhost` dışında set edilmez** ⇒ teslim paketi ve README `localhost` kullanımını **zorunlu** kılar (RT-M1) — **ve bu kısıt WebKit/Safari'de ÖLÇÜLMEMİŞTİR (§6 #15)** ⇒ teslim paketi *"Chromium tabanlı tarayıcı"* notunu taşır · (c) aynı-origin kararı **teslim paketini bağlar**: web build'i API ile birlikte servis edilmelidir (CI/CD ve paketleme adımında görünür gereksinim).
8. **`slice-3b` bağımlılığı:** `flutter_secure_storage`'ın **lisansı ölçüldü (BSD-3-Clause, izinli aile)**; **CVE ayağı 3b'de koşar** ve düşerse K3-L1 yeniden açılır. **Windows şifreleme yöntemi `[DOĞRULANMADI]`** — v2'nin DPAPI iddiası geri çekildi.
9. **Parola değiştirme yok** (K3-K3) ⇒ `/logout-all`'ın en doğal tetikleyicisi de yok. Uç yine de vardır ve testlidir (M18). **Fazladan yüzey olduğu kabul edilir**, gizlenmez.
10. **[YENİ — RT-M5] Aynı-origin kararının XSS SONUCU, adlandırılıyor:** `HttpOnly` çerez, XSS'in yenileme token'ını **okumasını** engeller — ama **kullanmasını engellemez.** Sayfa açıkken enjekte edilmiş bir betik `/refresh`'i çağırabilir (çerez otomatik gider, CSRF çerezi JS'e **okunabilir** olmak zorundadır) ve **her `[KS-1]`'de bir taze erişim token'ı** elde edebilir. **`HttpOnly`'nin satın aldığı şey gerçektir ama sınırlıdır: token *dışarı sızdırılamaz*, ama *sayfa açıkken kullanılabilir*.** Kapatmanın yolu XSS'i hiç doğurmamaktır (CSP + Flutter web'in DOM'a ham HTML yazmaması); bu `slice-3b`'nin işidir ve orada adlandırılacaktır.  <!-- v7/oturum-26 [kapı-6 majör #4]: bu satırda ÖNCE `[KS-1]`'in DEĞERİ ham olarak yazılı ve muafiyet gerekçesi *"kanonik sayı değil"* idi; ÖLÇÜLDÜ: o değer TAM OLARAK `[KS-1]`'dir — ve bu düzeltmenin ilk yazımı, gerekçeyi anlatmak için literali TEKRAR yazdığı için aracı YENİDEN tetikledi (K33 örüntüsü); ikinci yazımda literal tümüyle kaldırıldı ⇒ gerekçe OLGUSAL OLARAK YANLIŞTI ve aracı bilerek kör bırakıyordu. Sayı atfa çevrildi, muafiyet KALDIRILDI. -->
11. **[K14-a'nın kabul edilmiş bedeli — v6'da YENİDEN TARTILDI]** Replay-idempotency penceresi (`[KS-4]`) çalınmış bir token için reuse-detection'ı **kaldırmaz, bir ÇARPIŞMAYA kadar erteler** (§2-C(3)'ün dürüst muhasebesi): dal (d)'ye ancak tüketilmiş token ya `[KS-4]` **dışında** ya da **halefi tüketilmişken** sunulduğunda varılır. **Gecikmenin ölçüsü `[KS-4]` DEĞİLDİR:** çevrimiçi kurbanda meşru istemcinin bir sonraki yenilemesine, yani **`[KS-1]`**'e kadar ⚠ **(bu tavan GÖLGELEME ALTINDA GEÇERSİZDİR — aşağıdaki B6-A düzeltmesi; yürürlükteki en kötü durum `[KS-2]`'dir)**; **kurban çevrimdışıysa ailenin mutlak ömrü `[KS-2]`'ye kadar** uzar. **Ayrıca gölgeleme mümkündür:** koşul 2 **halefin** `consumed_at`'ine baktığı için iki taraf zinciri adım adım paylaşabilir — ailenin **mutlak ömrü uzamaz** ve **replay dalı ailenin SATIR SAYISINI artırmaz** *(v7 düzeltmesi [B6-C]: v6 burada *"yeni token basılmaz"* diyordu ve bu **yanıltıcıydı** — zincir her adımda yeni token **basar**; basan şey replay dalı değil, karşı tarafın **normal döndürmesidir**)*, ama tespit **ertelenmeye devam eder**. *(v4/v5 burada `[KS-4]` yazıyor ve *"halef kullanılınca aile düşer"* diyordu; **her iki iddia da §0.4'te geri çekildi**.)*
    🔴 **v7 DÜZELTMESİ [B6-A — MAJÖR kapanıyor]: GÖLGELEME, YUKARIDAKİ `[KS-1]` TAVANINI YOK EDER. EN KÖTÜ DURUM ÇEVRİMİÇİ KURBANDA DA `[KS-2]`'DİR.**
    v6 bu maddede önce *"çevrimiçi kurbanda `[KS-1]`'e kadar"* tavanını kuruyor, **sonra** gölgelemeyi ekliyordu — **ama gölgeleme o tavanı geçersiz kılar** ve v6 bu sonucu **hiçbir yerde yazmıyordu.** Gerekçe, belgenin kendi sayılarından türer: **`[KS-4]` < `[KS-1]`** olduğu için saldırgan her turda pencereye yetişmek üzere **bir `[KS-4]` bütçesine** sahiptir; maliyeti **her `[KS-4]` içinde bir tek `/refresh`'tir** ve bu, `/refresh`'in kendi tavanının (**`[KS-11]`**) **çok altındadır** ⇒ hız sınırı bu davranışı **hiç görmez**. ⇒ **Meşru kullanıcı çevrimiçi olsa bile, tespit ailenin mutlak ömrü olan `[KS-2]`'ye kadar ertelenebilir.** *Bu sayı v6'da hiçbir yerde yazmıyordu ve §6, kabul edilen en kötü durumu yazmakla yükümlü olan bölümdür.*
    🔴 **v7 DÜZELTMESİ [B6-B — MAJÖR kapanıyor]: GÖLGELEMENİN BEDELİ ADLANDIRILIYOR.** Çarpışma sonunda (halef tüketilmişken sunum ya da `[KS-4]` dışı sunum) dal (d) koşar ve **iptal edilen şey AİLEDİR** ⇒ **tespit anı, meşru kullanıcının yeniden giriş ekranı gördüğü andır.** Bu tam olarak **K14-a'nın seçilme gerekçesinin kendisidir** (*"uçak modu demosunun ortasında yeniden giriş"*) ⇒ K14-a bu senaryoyu **ortadan kaldırmaz, geciktirir**; gölgeleme altında ise **`[KS-2]`'ye kadar geciktirip sonra AYNI bedeli ödetir.** *Kabul ediliyor ve burada adıyla yazılıyor:* alternatifi replay penceresini tümüyle geri almaktı (o zaman bedel **her kayıp yanıtta** ödenirdi, gecikmeli değil). **Bu, belgenin *"dürüst muhasebe"* bölümünde v6'da YAZILI DEĞİLDİ.** **Sahiplik:** mekanizmanın sahibi **K14-a**, `[KS-4]`'ün değeri **K28-a ile Onur tarafından kilitlenmiştir** — v3/v4'ün **K16-b** atfı **yanlıştı** (K16-b'nin tam metni yalnız hız sınırı tavanlarıdır: `[KS-10]`/`[KS-11]`/`[KS-12]`).
12. **~~`ConcurrencyLease` × `Retry-After`~~ → ✅ KAPANDI (ölçüldü).** `FixedWindowLease` `MetadataName.RetryAfter` **taşıyor**; `ConcurrencyLease` **taşımıyor** (yalnız `ReasonPhrase`). K3-J4'ün koşulluluğu kalktı: middleware ayağı lease'ten okur, kontrol 2 pencereden hesaplar, **kontrol 3 `Retry-After` YAZMAZ** ve istemci bunu üstel geri çekilmeyle karşılar (K3-L8/4).
13. **[YENİ — K15-a'NIN BEDELİ, ADLANDIRILIYOR] DB sızıntısı, dar bir pencerede KULLANILABİLİR token verir.** `successor_secret_enc`, halefin ham değerini **şifreli** olarak tutar. Bir saldırgan **hem DB dökümünü hem kök anahtarı** ele geçirirse, o pencerede tüketilmiş satırların halefleriyle **çalışan oturumlar** elde eder. **Pencere: `[KS-4]` (yüklem) + azami `[KS-6]` (süpürme periyodu) = en kötü durumda **`[KS-4]` + `[KS-6]`**.** *Neden kabul edildi:* alternatifi K14-a'yı geri almaktı (uçak modu demosunun ortasında yeniden giriş — ODEV §2) ya da değeri **şifresiz** tutmaktı (`[KS-2]`lük kullanılabilir token). *Telafi:* şifreleme (K16-c'nin `rt-successor-enc` alt anahtarı) + **fiilen silme** (M40) + kısmi indeks. **v3'ün *"DB'de ham değer hiç bulunmaz"* iddiası artık bu istisnayla birlikte okunur** (§0.4).
14. **[YENİ — B2'NİN BEDELİ] Kontrol 1 KÜRESELDİR: tek istemci tüm tavanı tüketebilir.** `RemoteIpAddress` bu dağıtımda köprü ağ geçididir (ölçüldü) ⇒ hız sınırı bir **kullanıcı ayrımı** değil, servisin toplam yüküne konmuş bir **tavandır**. Sonucu: kötü niyetli **ya da yalnızca gürültülü** tek bir istemci, `/login` tavanını (`[KS-10]`) doldurup **diğer kullanıcıların girişini geçici olarak engelleyebilir**. Tek-instance bir ödev dağıtımında **kabul edilmiş ve beyan edilmiş** sınırdır; kapatmanın yolu (reverse-proxy + `X-Forwarded-For`, ya da kullanıcı-anahtarlı ikinci katman) **K3-K3 ile kapsam dışıdır**. **Argon2'yi koruyan asıl mekanizma kontrol 3'tür ve o küresel olmaktan zaten etkilenmez.**
15. **[YENİ — DOĞRULANMADI] WebKit/Safari'nin `http://localhost` üzerinde `Secure` / `__Host-` davranışı ölçülmedi.** Chromium ve Firefox `localhost`'u güvenli bağlam sayar; WebKit'in aynı davranışı gösterdiği **tarayıcı kaynağından doğrulanmamıştır**. ⇒ Safari'de yenileme çerezi hiç set edilmeyebilir ve `/refresh` sessizce çalışmayabilir. **Telafi tek satırlıktır ve teslim paketindedir:** *"demo Chromium tabanlı bir tarayıcıda açılmalıdır"*. Ölçülünce ya kapanır ya adlandırılmış sınır olur.
16. **[YENİ — ADLANDIRMA BORCU ÖDENİYOR] RFC 9700 §4.14.2 ile ilişki.** RFC, döndürmeli yenileme token'ları için **`MUST`** koşulunu *"replay tespit yöntemlerinden **birini** kullan"* için koyar; *"yeniden kullanım tespit edilince ailenin iptal edilmesi"* cümlesi **betimleyicidir**. Momentum döndürme + yeniden-kullanım tespiti uygular ⇒ **ihlal yoktur.** K14-a'nın penceresi iptali **kaldırmaz, bir çarpışmaya kadar erteler** (§2-C(3) ve §6 #11'in dürüst muhasebesi: gecikmenin ölçüsü `[KS-4]` **değildir**; **gölgeleme altında en kötü durum — kurban çevrimiçi olsun ya da olmasın — `[KS-2]`'dir** <!-- v7/oturum-26 [B6-A]: v6 burada "çevrimiçi kurbanda [KS-1]" diyordu ve bu ölçü YANLIŞTI; §6 #11'in v7 düzeltmesiyle hizalandı --> ) — bu, RFC'nin adlandırdığı ödünleşimin **bilinçli bir noktasıdır** ve burada adıyla kayda geçmiştir. **RFC uyumu bundan ETKİLENMEZ** (RFC yöntemlerden *birini* şart koşar ve döndürme+tespit uygulanır); etkilenen şey **kabul edilen en kötü durumun ÖLÇÜSÜDÜR** ve o ölçü artık doğru yazılıdır.
17. **[YENİ — kapı-5 B5-5: BEYAN EDİLDİĞİ SÖYLENEN AMA YAZILMAMIŞ SINIR] Anahtar rotasyonu YOKTUR.** §2-I *"bu, kabul edilmiş ve beyan edilmiş bir sınırdır (§6 Risk #17)"* diyordu ama **§6'da 17 numaralı kalem YOKTU** ⇒ beyan, beyan edilmemişti (kapı-5 ölçtü: §6 1'den 16'ya kadardı). **Kalem burada yazılır:** kök anahtar (`Momentum:MasterKey`) sızarsa ya da değişirse **çift-anahtar (eski+yeni) doğrulama penceresi YOKTUR** ⇒ **tüm oturumlar düşer**: JWT'ler doğrulanamaz, CSRF token'ları geçersizleşir, `successor_secret_enc` çözülemez — ki bu sonuncusu **K3-I5(3) gereği `reuse_detected` üretir ve aileleri iptal eder**. *Kurtarma yordamı:* yeni anahtar üretilir, `.secrets/` dosyası değiştirilir, tüm kullanıcılar yeniden giriş yapar. *Kabul edilen bedel:* toplu oturum düşmesi. *Sahibi:* kapsam dışı bırakılmıştır (`K3-K3`); rotasyon uç noktası **ADR 0004'ün ya da işletim diliminin işidir** ve §7'nin devir listesine yazılmıştır. `info` etiketlerindeki `v1`, rotasyonun gelecekteki yolunu açık tutar (etiket `v2` olur ⇒ üç alt anahtar birlikte döner).

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
  - **[NUMARA PİNİ — K16-d ile GÜNCELLENDİ]** 0004'ün yeni mutantları **`M60`'tan** başlar [K22-b]. *(v3'ün `M40` pini geçersizdir: v4 M40–M48'i tüketti. 0004 henüz hiçbir numarayı tüketmediği için pini taşımak bedelsizdir.)*
- **`slice-3b`'ye DEVREDİLEN mutantlar:** **M-L5** (tek-uçuşluluk + **web ayağı: Web Locks**, K3-L9 — seviye `DART` + `DART-WEB`) · **M-L6** (401'de kuyruk) · **M-L7** (kullanıcı-başına DB) · **M-L8** (ağ hatası ≠ 401, K3-L8) · **M-L9** (`429`/`5xx` = geçici, K3-L8/3 — **B3'ün istemci ayağı**) · **🆕 M-L10** (çıkışta aktif profil kaydı temizlenir, K3-L8(4) — **B6-6'nın istemci ayağı; v7'de doğdu**). Ayrıca **XSS yüzeyinin CSP ayağı** (§6 Risk #10) ve **teslim paketinin demo hesabı + `localhost` + Chromium notu** (K16-a, RT-M1, §6 #15).
- **Sıradaki:** **bağımsız kapı** (architecture + red-team, **RED-TEAM EN SON**; üreten ≠ denetleyen — **bu belgeyi yazan oturum onu denetleyemez**) → **K13-a: bloker sıfırlanana kadar tur** → Onur kilidi → ayrı oturumda **ADR 0004** → **`GOREV-slice-3c-auth`** spec'i → Claude Code build → **Cowork TEMİZ OTURUMDA bağımsız doğrular**.
- **Sonra:** `slice-3b` (Flutter istemci) — §2-L'nin token/kuyruk/DB/profil kararları Drift şemasını ve depo katmanını **doğrudan** belirler.

---

*🟡 **TASLAK v6 — KİLİTLİ DEĞİL.** Kapı-5'in **12 blokeri ve 7 majörü** kapatıldı; Onur **sekiz çatal** kilitledi (**K28-a/b/c/d · K30-a/b/c/d**); **iki iddia daha açıkça geri çekildi** (§0.4 — replay penceresinin maliyet muhasebesi). **Bağımsız kapı KOŞMADI — 6. tur için AYRI ve TEMİZ bir oturum gerekir (K13-a) ve o oturum HEM BU BELGEYİ HEM ONARILMIŞ ÖLÇÜM ARACINI denetlemek zorundadır (K29-a).** Bu ADR'yi yazan el onu onaylayamaz.*  <!-- [KS-LITERAL: KAPI BULGU SAYIMI — kapı-5'in 12/7 sayımı; kanonik değer değildir] -->
