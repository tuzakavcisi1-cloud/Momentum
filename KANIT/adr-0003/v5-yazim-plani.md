# ADR 0003 v5 — YAZIM PLANI (oturum 21'den oturum 22'ye)

> **Bu bir plandır, bir karar belgesi değildir.** Amacı: v5'i yazacak **temiz** oturumun
> hiçbir şeyi yeniden türetmek zorunda kalmaması. Kaynaklar: `KANIT/adr-0003/kapi-4-denetim-raporu.md`
> (bulgular) + `PROJE_HAFIZA.md` **K18** (çatal kilitleri) + **K19** (bu oturumun kararları ve ölçümleri).
>
> **Yarım artefakt:** `docs/ADR/0003-kimlik-cekirdegi-v5-YAZIM-DEVAM-EDIYOR.md`.
> **Kanonik dosya hâlâ v4'tür** (`docs/ADR/0003-kimlik-cekirdegi.md`) ve v5 tamamlanana kadar öyle kalır.

## 0. Oturum 21'de BİTEN işler (tekrarlanmayacak)

| # | iş | kanıt |
|---|---|---|
| 1 | §0.1–§0.3 ADR'den çıkarıldı, **hiçbir satır silinmeden** KANIT'a taşındı | `KANIT/adr-0003/v4-kapanma-tablolari.md` |
| 2 | **§1-K KANONİK SAYILAR** tablosu yazıldı (KS-1…KS-27) | v5 dosyası §1-K |
| 3 | v4'ün **satır 715 başlıksız mutant tablosu** onarıldı | v5 dosyası, `M32b` satırının üstü |
| 4 | **Ölçüm aracı** yazıldı + altın kümede kanıtlandı + v4'te koştu | `araclar/adr-kapi-taramasi.py` · `KANIT/adr-0003/olcum-araci-altin-kume-kanit.txt` |
| 5 | Kapı-4 §6'nın **ölçülemeyenlerinden 5'i** ölçüldü | `PROJE_HAFIZA.md` **K19** ✅ maddeleri 1-7 |
| 6 | `+` kaçış dizisi **üç halkalı birincil kaynak** zinciriyle saptandı | K19 ✅ madde 8 |

## 1. ÖNCE OKU (sırayla, başka bir şey okumadan)

1. `docs/ODEV.md` (kapsam otoritesi) · 2. `CLAUDE.md` · 3. `PROJE_HAFIZA.md` **K19 + K18 + K17**
4. `KANIT/adr-0003/kapi-4-denetim-raporu.md` (HARİTA) · 5. bu dosya · 6. v5 yarım dosyası.
**v4'ün tamamını okuma** — v5 dosyası zaten v4'ün gövdesidir.

## 2. DOKUZ BLOKER — ne yazılacak (K18'de kilitli)

| bloker | karar | v5'in yazacağı |
|---|---|---|
| **B-1** `M11` ölü tuzak | çatalsız | Kill sinyali **`[KS-10]`'a atıf** yapacak (sayı kopyalanmayacak) · önkoşula ***"her istekte FARKLI e-posta"*** · çıpa `K3-J2(1)` yerine **kontrol 1a** · ***"aynı IP'den"*** ifadesi **düşer** (K15-b: `TestHost`'ta `RemoteIpAddress` `null`) |
| **B-2** `M46` kör | **K19-b (Onur onayladı)** | Mutasyon = ***"`UseRateLimiter`, `UseRouting`'den ÖNCEYE alınır"*** · sinyal = *"`[KS-10]`+1'inci `/login` isteği `429` **ALIR**"* **FAIL** · statik-dosya ayağı **düşer** · §2-J'nin *"onlarca asset isteği kovayı ilk saniyede tüketir"* gerekçesi **§0.4'e GERİ ÇEKİLEN İDDİA** olarak yazılır |
| **B-3** §3.1 tamlık iddiası | **K18-d + K19-c** | §3.1 cümlesi **KALIR**, ama artık **ölçülür**: `araclar/adr-kapi-taramasi.py` koşulur, **`K1` bulgusu SIFIR olana kadar** her kalem ya çıpaya bağlanır ya §3.1'e yazılır (§4'teki liste) |
| **B-4** "handler" hangi katman | **K18-a** | Kontrol 2/3 **Application**'da kalır; `ProblemDetails`'e çevirim **Api**'de. §2-M port envanterine **kontrol 2 · kontrol 3 · çevirim noktası · `users` kalıcılığı** satırları eklenir. **Yeni mutant `M49`:** çevirim Application'a taşınırsa `M32b` baseline'ı **kırmızıya döner**. *"handler"* kelimesi geçtiği **her yerde** hangi katman olduğu yazılır (ADR 0001 satır 27 = Application CQRS · satır 80 K-H1 = Api) |
| **B-5** nonce + AAD | **K18-b** | Yeni karar **`K3-I5`**: her şifrelemede **12 bayt taze CSPRNG nonce** `[KS-25]` + **AAD = `family_id ‖ token_hash`** `[KS-27]`; düzen `[KS-26]` aynen. **`M50`** (nonce sabitlenir ⇒ kırılır) · **`M51`** (AAD kaldırılır/karıştırılır ⇒ çözme başarısız). K3-K2'nin *"primitifi yazmayız"* muafiyetinin **nonce seçimine UYGULANMADIĞI** yazılır (ölçüldü: `AesGcm.Encrypt(ReadOnlySpan<byte> nonce, …)` nonce'u **çağırandan** alır) |
| **B-6** K3-B6 e-posta ayağı | çatalsız | E-posta ayakları `M31`'den **ayrı mutanta** (**`M52`**) taşınır — parola mutasyonu e-postayı ısırtamaz. **`[KS-19]` (254) assert'i GERÇEKTEN yazılır**; bugün yok ama iki yerde *"kapandı"* deniyor |
| **B-7** hız-sınırlayıcı izolasyonu | çatalsız | §3.2'ye **9. madde**: sınıf başına yeni `WebApplicationFactory` / kova sıfırlama stratejisi. **Ölçüldü:** `FixedWindowRateLimiter` `Stopwatch.GetTimestamp()`+`Timer` kullanır ⇒ **`FakeTimeProvider` pencereyi İLERLETEMEZ** ve bu cümle belgeye **açıkça** yazılır |
| **B-8** `M22` ölü tuzak | çatalsız | Önkoşula ***"her istekte FARKLI e-posta"*** (kontrol 2 `[KS-13]`, kontrol 3'ten **önce** ısırıyor) + eşik `[KS-16]`'ya atıf |
| **B-9** testlerin anahtar kaynağı | **K18-c** | §3.2'ye **10. madde**: fixture `ConfigureAppConfiguration` ile `Momentum:MasterKey`'i **test-only sabit** değerle enjekte eder. K3-I1'in *"gömülü anahtar YOKTUR"* cümlesiyle **çelişmediği** gösterilir (test yapılandırması ≠ üretim kodu). **`M8a` ve `M42` ETKİLENMEZ** ve bu yazılır |

## 3. OTURUM 21'İN YENİ BULGULARI — v5 bunları da kapatmak zorunda

> Bunlar kapı-4'te **yoktu**, çünkü `src/`, `tests/`, `docker-compose.yml` o oturumda **bağlı değildi**.
> Üçü de ölçülmüştür (K19 ✅ 3, 4, 6).

| # | bulgu | sınıf | v5 ne yapmalı |
|---|---|---|---|
| **Y-1** | **`Dockerfile` YOKTUR**; `docker-compose.yml` yalnız `postgres:17-alpine` tanımlıyor ⇒ **`KON` seviyesi (`M8b`, `M42`) ve §2-I'nin *"konteynerin giriş betiği"* bootstrap'ı BUGÜN VAR OLMAYAN bir artefakta çıpalı** | **BLOKER sınıfı** | Üç seçenekten biri, dördüncüsü yok: (a) API `Dockerfile`+giriş betiği **bu dilimin işi** diye yazılır (ODEV §8/4 paketleme ile birlikte) · (b) `KON` seviyesi **kapsam dışına** alınır ve M8b/M42 yeniden çıpalanır · (c) §3.1'e **kapısız** diye beyan edilir |
| **Y-2** | **§3.2(5) olgusal olarak yanlış:** *"`TimeProvider` her testte `FakeTimeProvider`'dır"*. Ölçüm: `Program.cs:34` **`AddSingleton(TimeProvider.System)`**; testlerin çoğu `TimeProvider.System` kullanıyor | **MAJÖR** | Ya fixture'ın **ezmesi pinlenir** (`WithWebHostBuilder` + `Replace`) ya cümle **daraltılır**. B-7 ile aynı maddede çözülmeli |
| **Y-3** | §3.2 **`TestAuthHandler`'ı adıyla yasaklıyor** ama repodaki gerçek ikame **`FakeCurrentUser`**'dır (`ICurrentUser` DI stub'ı, iki test projesine `Compile Include` ile bağlı) ve §3.2 ondan **hiç söz etmiyor** | **MAJÖR** | slice-3c sonrası kimlik ikamesinin **DI'dan mı gerçek token'dan mı** olacağı **karara bağlanır**; aksi hâlde yasak, deliği başka adla açık bırakır |

**Kapanan borçlar (v5 bunları artık ölçülmüş yazabilir):** `public partial class Program;` **vardır** (`Program.cs:153`) ⇒ §3.2(1) uyumlu · `Microsoft.Extensions.TimeProvider.Testing` **9.0.0 zaten repoda** ⇒ yeni bağımlılık değil, kırmızı çizgi #3 tetiklenmez · `Testcontainers.PostgreSql` **4.13.0 / MIT** · `AddAuthentication` **hiç çağrılmıyor** ⇒ `TestAuthHandler` yasağı **geriye dönük hiçbir testi kırmaz**.

## 4. ÖLÇÜM ARACININ 25 `K1` BULGUSU — kalem kalem adjudikasyon

> **Koş:** `python3 araclar/adr-kapi-taramasi.py docs/ADR/0003-kimlik-cekirdegi.md`
> **Hedef: `K1` = 0.** Her kalem **ikisinden biri** olur; üçüncü seçenek yoktur:
> **(Ç)** var olan bir mutantın **çıpa sütununa etiketi eklenir** — *ancak o mutantın kill sinyali gerçekten o kararı ısırıyorsa*;
> **(B)** §3.1'e **gerekçeli** bir satır yazılır.
>
> ⚠ **Aşağıdaki sütun bir ÖNERİDİR, ölçüm DEĞİLDİR.** Her satır yazılmadan önce ilgili mutantın
> **kill sinyali okunmalı** ve gerçekten o kararı ısırdığı doğrulanmalıdır. **Etiketi yalnız aracı
> yeşile boyamak için eklemek, aracı bir kapı tiyatrosuna çevirir** — bu, doktrinin ihlalidir.

| # | kalem | öneri | not |
|---|---|---|---|
| 1 | `K3-A1` User entity / asgari PII | **B** | Şema kararı; alan eklemek hiçbir testi kırmaz. 0004'ün şema kapısına devredilir |
| 2 | `K3-A4` User senkronlanabilir kök **değildir** | **B** *(0004 borcu)* | Gerçek kapısı 0004'tedir (*"`User` `/sync` teline eklenirse test kırılır"*); burada beyan |
| 3 | `K3-B1` Argon2id + Konscious 1.3.1 | **Ç** → `M5` ve/veya `M32` | `M5` rehash-on-login parametreleri okur ⇒ ısırıyorsa etiket eklenir |
| 4 | `K3-B2` `IPasswordHasher` portu | **Ç** → `M32` | NetArchTest kuralı tam olarak bu kararı ısırtır |
| 5 | `K3-B7` PHC ayrıştırma sözleşmesi | **Ç** → `M5` | `M5` PHC parametrelerini ayrıştırmadan ölemez |
| 6 | `K3-C1` erişim token'ı `[KS-1]` HS256 | **Ç** → `M16`/`M17` | Ömür ve `ClockSkew` kapıları |
| 7 | `K3-C5` zarafet penceresi yoktur `[KS-7]` | **Ç** → `M27` | |
| 8 | `K3-D2` `sub` claim'i okunur, `scoped` | **Ç** veya yeni ayak | `ClaimTypes.NameIdentifier` okunursa kırılan bir ayak gerekir |
| 9 | `K3-D3` arka plan servisi tuzağı (sweeper DI scope) | **Ç** → `M40` ikinci ayak | Kapı-4 B-3 #7 |
| 10 | `K3-D4` `User.Identity.Name` kullanılmaz | **B** veya `M24` ayağı | Kapı-4 B-3 #9 |
| 11 | `K3-I1` tek kök anahtar repoya girmez | **Ç** → `M8a`/`M8b` | **Y-1 kararı bunu etkiler** |
| 12 | `K3-J3` bağlayıcı sıra | **Ç** → `M22`/`M41` | **B-4 ve B-8 ile birlikte** yazılır |
| 13 | `K3-J5` partition temizleme `[KS-9]` | **B** | Ölçümdür, karar değil |
| 14 | `K3-K1` Identity kullanılmaz | **B** | Negatif karar; mutantı yoktur |
| 15 | `K3-K2` primitifi yazmayız ilkesi | **B** | **B-5 sınırıyla birlikte:** nonce seçimi bu muafiyetin DIŞINDADIR |
| 16 | `K3-K3` kapsam dışı listesi | **B** | |
| 17 | `K3-L4` aynı origin, reverse-proxy yok | **Ç** → `M46` | **B-2'nin yeni çıpasıyla** |
| 18 | `K3-L5` single-flight refresh | **Ç** → `M-L*` | DART seviyesi |
| 19 | `K3-L6` `401`'de kuyruk bekler | **Ç** → `M-L*` | DART |
| 20 | `K3-L7` çıkışta silme yok | **Ç** → `M-L*` veya **B** | |
| 21 | `K3-L8` soğuk açılış / aktif profil | **Ç** → `M-L*` | Kapı-4 B-3 #10 (`K3-L8(1)`) |
| 22 | `K3-C6(1)` | **Ç** → `M44` | Dal önceliği |
| 23 | `K3-C6(3)` replay-idempotency | **Ç** → `M1`/`M29` | `[KS-4]` |
| 24 | `K3-C6(5)` tembel/fırsatçı silme | **Ç** → `M40` ayak | Kapı-4 B-3 #3 — *"İKİ MEKANİZMA, İKİSİ DE ZORUNLU"* |
| 25 | `K3-J2(2)` kontrol 2 | **Ç** → `M41` | `[KS-13]` |
| + | `K3-L8(4)` | **Ç** → `M-L9` | `429` dalı |

**Ayrıca aracın diğer kontrolleri:** `K2` (sarkan atıf) = 0 olmalı · `K3` (başlıksız tablo) **onarıldı, 0** · `K4` **gövde KS atıflarına çevrildikten sonra 0 olmalı** · `K5` (numara boşluğu) rezerv ilanı korunduğu için 0.

## 5. MAJÖRLER — kapı-4 §3'ün listesi (16 başlık, ~27 kalem)

1. **AAD** → B-5 ile kapanır (`K3-I5`, `M51`).
2. **`+` kaçışının gerçek biçimi.** v4 satır 195 *"`+` karakterini `+`'ye çevirdiği için"* — **totoloji**. Doğrusu: **`\u002B`** — ters bölü + `u002B`, **altı karakter**, `B` **BÜYÜK**. *Zincir (birincil kaynak, K19 ✅ 8):* `ForbidHtmlCharacters()` → `ForbidChar('+')` · `DefaultJavaScriptEncoder(… forbidHtmlSensitiveCharacters: true …)` · `destination[1]=(byte)'u'` + 4 hane · `HexConverter.ToBytesBuffer(…, Casing casing = Casing.Upper)`. **`M28`'in tarayıcısı artık bu diziyi arar.** ⚠ **Onur'un Windows'ta koştuğu çıktı geldiyse etiket düşer; gelmediyse `[KOŞULARAK DOĞRULANMADI]` yazılır** (bulut konteynerinde .NET yok — dört Microsoft alanı da proxy tarafından **403** ile kesildi, ölçüldü).
3. **`[KS-4]` (60 sn) yanlış atıf:** sahibi **K14-a**, K16-b değil. Kanonik tablo bunu zaten düzeltti; **gövdedeki üç atıf** da düzeltilecek.
4. **`Retry-After` kapısı yok** — `M11`/`M41`'in kill sinyaline `Retry-After` ayağı eklenir (`FixedWindowLease` taşır, `ConcurrencyLease` **taşımaz** — ölçülmüştü).
5. **`M40` mutasyon biçimi pinsiz** + süpürme periyodu `[KS-6]` ölçülmüyor + fırsatçı silme kapısız → tek maddede.
6. **NIST SP 800-63B-4 §3.2.2 `SHALL`** (*ardışık başarısızlıkta ≤100 ⇒ authenticator devre dışı*) **karşılanmıyor** ⇒ **adlandırılmış sapma** olarak yazılır (belge her diğer sapmayı adlandırıyor; bunu hiç anmıyor).
7. **`/refresh`'te CSRF doğrulamasının tüketim `UPDATE`'ine göre sırası** yazılır (`/login` için PAZARLIKSIZ sıra var). CSRF sonra koşarsa başarısız istek token'ı **zaten tüketmiş** olur ⇒ `[KS-4]` aşılırsa `reuse_detected` ⇒ **aile düşer**.
8. **§2-M'de `users` kalıcılığı satırı yok** → B-4 ile birlikte.
9. **Çoklu-assert mutantları:** `M41`(2) · `M43`(3) · `M31`(4) · `M36`'nın 7 assert'inden 5'i **kendi mutasyonu altında ölmüyor** ⇒ ya ayak ayrı mutanta taşınır ya mutasyon bileşikleştirilir.
10. **`M42` bileşik** (türetme + efemer üretim) **+ `KON` gözlem yüzeyi çelişkisi** (`KON` = *çıkış kodu, stderr, dosya sistemi*; `M42`'nin sinyali **HTTP 200**) → **Y-1 ile birlikte** çözülür.
11. **`M19`** tüm `TS` suite'ini düşürüyor ⇒ ayırt edicilik zayıf.
12. **CI yok** ama `KON` *"CI'da ayrı job"* varsayıyor (ODEV §8/4: 11-12 Ağu) → **Y-1 ile birlikte**.
13. **HKDF `info` bayt kodlaması pinsiz** (`HKDF.Expand(…, byte[]? info)`) — B5'in birebir kardeşi.
14. **HKDF-Extract atlama gerekçesi zorlanmıyor** (fail-fast yalnız **uzunluk** ölçüyor).
15. **Anahtar rotasyonu yarım** — mekanizma yok, kapsam dışı da denmemiş.
16. **CSRF nonce'unun uzunluğu/entropi kaynağı ve CSRF token'ının ömrü pinsiz** → kanonik tabloya **KS-28/KS-29** olarak girer.

## 6. MİNÖRLER (öncelikli beş)

`K3-L8`'in 3. dalına 4 atıftan 3'ü *"(4)"* diyor · emekli `K3-G*` etiketine canlı atıf (D-5) · `sstamp`'in ilk değeri yazılmamış · Risk #13'ün *"120 sn"*i sürecin ayakta olmasını varsayıyor ama yazmıyor (**kanonik tablo KS-4×KS-6 notunda düzeltildi**) · demo kimlik bilgisi ↔ K3-I3 optik red asimetrisi.

## 7. NUMARA PİNİ — Onur'un onayına açık [K20-a önerisi]

v5 dört yeni mutant doğuruyor: **`M49`** (katman çevirimi, K18-a) · **`M50`** (nonce) · **`M51`** (AAD) · **`M52`** (e-posta girdi politikası). K16-d **ADR 0004'ün `M50`'den başlamasını** pinlemişti ⇒ **çakışma var.**
**Öneri:** 0003 aralığı **M1–M52**'ye genişler, **0004'ün pini `M60`'a taşınır.** *Gerekçe:* 0004 hâlâ **hiçbir numarayı tüketmedi** (K16-d'nin kendi gerekçesi) ⇒ taşımak bedelsiz; alternatif (yeni mekanizmaları harfli ayak gibi göstermek) **kendi başına mekanizma** olan kapıları sahte ayak gibi gösterir — K16-d'nin **açıkça reddettiği** yol.

## 8. SIRA (öneri)

1. Y-1'i karara bağla (Onur) → `KON`/`M8b`/`M42`/`M8a`/`K3-I1` bir arada çözülür.
2. B-4 · B-5 (`K3-I5` + §2-M) → yeni kararlar; gövdenin en çok değişen yeri.
3. B-1 · B-6 · B-8 · B-2 → mutant tablosu düzeltmeleri (hepsi `[KS-n]` atıflı).
4. B-7 · B-9 · Y-2 · Y-3 → §3.2 (9. ve 10. madde).
5. Gövdeyi **KS atıflarına** çevir (aracın `K4`'ü sıfırlanana kadar).
6. §4'ün 25 kalemini adjudike et (aracın `K1`'i sıfırlanana kadar).
7. Majörler → minörler.
8. **Öz-doğrulama** (kodlama · bayt/satır · numara bütünlüğü · bayat referans · araç koşumu). **BU KAPI DEĞİLDİR.**
9. **Kapı-5: AYRI VE TEMİZ OTURUM.** Denetçiye **aracın kendisi de denetlenecek** diye açıkça söylenir (K19-c).
