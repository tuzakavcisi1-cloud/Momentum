# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Tavan: **≤ 32 KB** [K58; eski tavan 12 KB]. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır. Gerekçe okuma kapasitesi değil **R4 freni + dikkat**; tavanı artık `belge-tavan-kapisi.py` **1.0.0** zorluyor (§2 adım 3) — beyan edilmiş zayıf kontrol **KAPANDI**.
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 2 Ağu 2026, **oturum 48 (K111 .NET 10 · K112 cihaz senkron)** — açılışın 10 adımı da koştu; **kapı adı çakışması ÖLÇÜLDÜ** (`A9b/G17` ≠ `A10/G17`, `A10/G18` ≠ `A9c/G18`), Onur **K108'i kilitledi**, `kapi-ad-teklik-kapisi.py` yazıldı ve **§2 adım 4b** olarak protokole bağlandı. *(Oturum 39–46'da yapılan iş arşivdedir.)*

---

## 1. Proje

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) + **N-katmanlı .NET 9 / ASP.NET Core** backend + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak **mimari ve kod kalitesi**. Vitrin: **çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği**.

**Kanonik kök: `C:\dev\Momentum`** 🔴 **[K56 — TAŞINDI]** · gerekçe ve kısıt **§7'de** (üçüncü kopya oturum 47'de budandı, `kanonik-kopya`); hiçbir kapı susturulmadı.

---

## 2. AÇILIŞ PROTOKOLÜ (sırayla, atlanmaz)

1. **Bu dosyayı** + `CLAUDE.md`'yi **TAM** oku. *(`PROJE_HAFIZA.md` ve `BORCLAR.md` AÇILMAZ.)* 🔴 **İKİSİNİ DE** — oturum 38'de `CLAUDE.md` okunmadan "okundu" işaretlendi: **sahte yeşil**.
2. `python araclar\tek-kopya-kapisi.py .` — regresyon kapısı (K60). KIRMIZI ise **önce dosyayı kurtar** (`git restore <yol>`), sonra iş yap.
3. `python araclar\belge-tavan-kapisi.py .` — canlı belge tavanı (K73). `T1` KIRMIZI ise checkpoint yazmadan **ÖNCE** budanır.
4. `python araclar\sayi-tazeligi.py .` 🔴 **[oturum 39'da EKLENDİ — ölçülmüş gerekçe]** Bu kapı protokolde **YOKTU** ve elle koşulduğunda **KIRMIZI** verdi: `oturum-sagligi.py` için **bayat** bir altın-küme sayısı yazılıydı, ölçülen gerçek **26**. **Çağrılmayan kapı, kör kapı kadar kördür.** Sınıfın kalanı `BORCLAR.md`'de açık.
4b. `python araclar\kapi-ad-teklik-kapisi.py .` 🔴 **[K108 — oturum 47'de EKLENDİ]** Kapı kimliği **spec-yereldir**; birden fazla spec'te ilan edilmiş bir kimliğe **kapsam öneksiz** atıf KIRMIZI'dır (`A10/G18` yaz, çıplak kimlik yazma — kapı bu satırı da denetler ve ilk yazımda **beni ısırdı**). Numara **4b'dir çünkü** yeniden numaralama §2'ye yapılan *"adım 7/8/9"* atıflarını kırardı.
5. `python araclar\oturum-sagligi.py --altin-kume` (**26/26**, EXIT 0) → `python araclar\oturum-sagligi.py .`
6. `python araclar\radar.py --altin-kume` (EXIT 0) → `python araclar\radar.py .` — **KIRMIZI ise yeni tur YASAK**; dört şık Onur'a sunulur, **varsayılan DEVRET**. *(30 Tem 2026'dan beri yürürlükteki kilit: **K83 / DURDUR** — §4.)*
7. **ÖNCE** `git --no-optional-locks fetch origin`, sonra `log --oneline -1` + `rev-list --left-right --count origin/main...HEAD` + `status --porcelain` + `Test-Path .git\index.lock`. 🔴 **Son commit ve push durumu hiçbir belgeye YAZILMAZ, burada ÖLÇÜLÜR (K82-b).** 🔴 **`fetch` ATLANIRSA "0 geri" BİR ÖLÇÜM DEĞİL, BAYAT BİR YEREL REFERANSTIR [oturum 42'de ölçüldü: `.git\FETCH_HEAD` **29 Tem 17:01** yazıyordu ⇒ karşılaştırılan `origin/main` ~24 saat bayattı].**
8. **Oturum sağlığını KENDİ oturum-id'nle ÖLÇ.** Cowork'te transcript **BULUTTADIR** (`/root/.claude/projects/*/<oturum-id>.jsonl`) ⇒ araç **bulutta** `--transcript` ile koşulur. Windows'taki koşum `S4`'ü **OLCULMEDI** der ve **bu yeşil DEĞİLDİR**.
9. **Ortamı ÖLÇ** (K80): `docker ps` · `netstat -ano | findstr :5298` · **`adb`**. 🔴 **`adb` PATH'TE YOK [oturum 42'de ölçüldü] ⇒ TAM YOLLA çağrılır:** `C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe devices`. K86'nın *"`flutter` bu makinede `.bat`"* dersinin aynısı: **çözülemeyen ad, sessizce atlanan adımdır.** 🔴 Sonuç **hiçbir belgeye yazılmaz** — beyan bayatlar, ölçüm bayatlamaz.
10. §4'teki **SIRADAKİ İŞ**'ten devam et.

> 🔴 **Hangi kapı HANGİ OLAYDA ve HANGİ ORTAMDA koşar: `KAPILAR.md` (kapı-tetik tablosu, K89).** Açılışta **okunmaz**; sıra burada, eşleme orada. *Beyan edilmiş zayıf kontrol: tabloyu zorlayan bir kapı henüz yok.*

---

## 3. CANLI DURUM

| alan | durum |
|---|---|
| **Backend** | ✅ slice-1 → 3e (3e'de **tek bayt yazılmadı**, ayak 2b2'de bitmişti). `araclar\verify.ps1` ⇒ build **0 uyarı/0 hata** · **test 120/120** · CVE 0 · EXIT 0. |
| **Veritabanı** | PostgreSQL / Docker; konteyner adı **`momentum-postgres`**. 🔴 **ÇALIŞMA DURUMU BURAYA YAZILMAZ — §2 adım 9'da ÖLÇÜLÜR (K80).** *(Oturum 42: bu hücre `✅ … Up (healthy)` diyordu; ölçüm `docker ps -a` ⇒ **`Exited (255)`** çıktı. K80'i doğuran bayat-PID vakasının ikinci kopyasıydı.)* |
| **İstemci (Flutter)** | 🟢 **slice-3b→3e + R9/R10 + A7/A8/A9 BİTTİ — senkron ÇİFT YÖNLÜ + gerçek zamanlı sinyal.** Drift çevrimdışı CRUD · itme kuyruğu · çekme (`UzakAlanDurumu` v4 + yerel LWW + `hasMore` + snapshot/artımlı) · rozet **kuyruktan türetiliyor** · SignalR-JSON sinyali (web'de `kIsWeb` ile KAPALI). Kapılar **spec-yereldir** (K108; envanter `GOREV_CLAUDE_CODE/`'da ÖLÇÜLÜR) + `design-token-kapisi.py` + `iddia-kapisi.py` **1.3.0**. Ölçülen mutantlar: **`M1`–`M108`** (dilim dilim) + A9b'nin **14** kanıtı; `M119` ISIRIYOR (vaka 27, `A9c/D8`). Son koşumlar **Cowork'ün kendisi** (K26): `flutter test` **481/481** (A10 ile 476→481) · `analyze --fatal-infos` **0** · **release APK derlendi** (bu depoda ilk kez, K106). 🔴 A‑7 `DESIGN.md`'de kapanmadı (K46). Tur tur anlatım **arşivde** (K73). |
| **Tasarım sistemi** | ✅ `DESIGN.md` **v2** — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7. Kimlik **§9'da** (v1 `534DFF68` **GEÇERSİZ**) |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `radar.py` **plugin 0.2.0 ile bayt-özdeş** · altın küme **18/18**. Hüküm **KIRMIZI** (oturum 40'ta yeniden ölçüldü), **yapısaldır** (park mekanizması yok ⇒ `BORCLAR.md`). 🔴 **KIRMIZI ARTEFAKTLARIN ADI VE SAYISI BURAYA YAZILMAZ — §2 adım 6'da ÖLÇÜLÜR** *(bu satır bir kez "aynı iki artefakt" dedi, ölçüm **11** verdi: sayı yazan satır bayatlar, ölçüme atan bayatlamaz — K82-b)*. 🔒 **K83 — Onur DURDUR'u kilitledi:** park yürürlükte, dört-şık ritüeli **tekrarlanmaz**. 🔴 **`R8` DURUMU DA YAZILMAZ, ÖLÇÜLÜR:** K104'te **ısırdı** (44–45 sıfır), K106'da **düştü**; sayı daima `--olc-urun-kodu <sha>` ile **git'ten** türetilir (K55). |
| **Git** | **PUSH DAİMA ONUR'DA.** İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR** — komut ve **`fetch` şartı yalnız §2 adım 7'de**; buraya **kopyalanmaz** (kanonik-kopya kusuru bu projede beş kez ısırdı). |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · **.NET 10.0.302** (K111; 9.0.316 de kurulu) · **Windows masaüstü ☠** · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

🔒 **K89–K100 KAPANDI (oturum 42–44):** `KAPILAR.md` · `GOREV-A8` v2 · `GOREV-A9` v3 · `GOREV-A9b` v2
(**30.046 b · `AF624471`**) · **A9 KABUL**. Anlatım **arşivde** (K73).

🟢 **`GOREV-A10` KABUL (K106) · `.gitignore` tuzağı KAPANDI (K107).** Kapılar **`A10/G17`–`A10/G21`**,
mutantlar **`M125`–`M135`**; anlatım arşivde. 🟢 **`GOREV-A9c` KİLİTLİ (K109)**, iş **Claude Code'a
hazır** (K34-f) — araç onarımı olduğu için `R8`'i düşürmez.
🟡 `D5` kör kapı, A9b hassaslaştırma ve `vaka 20b`: gerekçeler **arşivde** (K100 · K102 · K104 · K106).

🟢 **① `.NET 10` GEÇİŞİ KAPANDI (K111, oturum 48 · Onur kilitledi).** Spec YAZILMADAN, **koşan deneyle**:
`net10.0` + SDK **10.0.302** · `verify.ps1` **EXIT 0** (build 0/0 · test 120/120 · CVE 0) · commit
`a20e290`+`a0aed23`. Kâğıttaki *"Mediator riski"* **çürüdü**; gerçek engeller **CVE pini** ve **sağlayıcı
hizalaması** çıktı. Geçiş **ATOMİKTİR** — ara durum `CS0023` ile kırık (izole mutant kanıtlı).
Kanıt `KANIT/net10-adim6/`; ayrıntı arşivde (K111); paket borçları `BORCLAR.md`'de.
**② A10 ✅ KAPANDI (K106).** 🔴 *"Geliştirme modunda `devUserId` alanı"* ifadesi **DARALTILDI**:
çalışma-zamanı UI alanı **değil**, derleme-zamanı `--dart-define` ezmesi (A10 §8/5) — kullanıcı değiştirmek
**yeniden derleme + kurulum** ister.
🟢 **③ YÜRÜYEN İSKELET KOŞTU (K112, oturum 48):** emülatörde oluşturulan görev **PostgreSQL'e ulaştı**
(iki vaka, 14,4 s / 23,5 s) · `entityId` **UUIDv7** · rozet senkrondan sonra **düştü** · K61 kalkanı ve
SignalR **canlı**. Kanıt `KANIT/ucuncu-cihaz-senkron/`. 🔴 **AYNI KOŞUMDA BULGU: yerel yazma İTMEYİ
tetiklemiyor** — *"Yenile"* yalnız çekme koşar, itme **yalnız açılışta**; kapsam boşluğu, **kilit Onur'da**.
🔴 **ÖLÇÜLMEYEN:** çift yön (sunucu→cihaz) · çevrimdışı/çakışma · **fiziksel cihaz** (yalnız emülatör).
→ ④ iOS iskelesi + CI → ⑤ `SS2` (dar) → ⑥ web borcu + release → ⑦ `ADR 0004` + vitrin.

🔒 **MSSQL göçü PARK EDİLDİ (Onur, 1 Ağu 2026).** Reddedilmedi; **iki koşul birlikte** sağlanınca açılır:
① cihaz senkron kanıtı kapandı ② hedef şirket yığını MSSQL. Ölçülen maliyet, `Rule3` ve en riskli parça
(`FOR UPDATE SKIP LOCKED` → `UPDLOCK/READPAST`) **arşivde**.
🔴 **YENİ BORÇ — README YOK.** Klonlayana **tek satır talimat yok**; dışarıdan gelen *"Docker zor iş"*
itirazının **haklı çekirdeği**. 🔴 *"Repo public"* iddiası oturum 47'de **ÇÜRÜDÜ**: buluttan anonim
`git ls-remote` ⇒ *could not read Username*. Görünürlük **yazılmaz, ölçülür**.

🟡 Ortam ve push durumu bu dosyaya YAZILMAZ, her açılışta ÖLÇÜLÜR (§2 adım 7 ve 9).

---

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- **K77 · K78 · K79 · K81 — slice-3e KAPANDI** (iskelet **K78**, `G12` **K81**; ikisi de Cowork'ün kendi koşumuyla, K26). Tasarım/spec kilitleri K73 gereği **çekildi**; kurallar bugün `G12`'nin 15 ayağında (`A1`–`A13` + `A7b`/`A13b`), `araclar/yoklama-yasagi-kapisi.py`'nin `Y1`–`Y4`'ünde ve `M58`–`M73`+`M71b` mutantlarında **koşuyor**. 🔴 **Yaşayan üç beyan:** ① `Y1` **sembol bazlı** (`K79/3` K81'de daraltıldı) ve gövde kuralı beyaz listedekiler **dâhil** herkese uygulanır ② `CursorHint` **yoksayılır** (`D6`) — sinyal yalnız uyandırma zili ③ web'de sinyal **`kIsWeb` ile kapalı**, web ayağı **`[DOĞRULANMADI]`**. 🔴 **İki açık borç:** `Y3`'ün mutantı yok · `G12` kriter 8 **UYGULANMAZ** (biçim standardı `CLAUDE.md`'de). Gerekçeler: hafıza K77–K81.
- **K76 · K75 · K74 · K71** — **`R9` ve `R10` KABUL EDİLDİ**; tasarım/spec kilitleri K73 gereği §5'ten **ÇEKİLDİ** ve bugün prozada değil `G10`/`G11` kapılarında + `M41`–`M57` mutantlarında **koşuyor**. 🔴 **Yaşayan iki beyan edilmiş sınır:** ① `D2` kural 3'ün `K != 'yerel'` istisnası — kolonu hâlâ `'yerel'` olan ESKİ satırlar sunucuda olsa da *"Yalnızca bu cihazda"* der; ② `R9` öncesi inmiş satırlar `'yerel'` KALIR (migration yasak). 🔴 **`K46` AÇIK** (kapsam: bileşik satır + `gonderilmemis`) ⇒ `DESIGN.md` **v2**. Gerekçeler: hafıza K71/K74/K75/K76.
- 🔒 **K111 — .NET 10 (Onur kilitledi, 2 Ağu 2026):** çatı `net10.0`, SDK pini `10.0.302`. Kural bugün prozada
  değil **`verify.ps1`'de ve `global.json` pininde** koşuyor. Geçiş **ATOMİK** (ara durum ölçülerek kırık bulundu);
  `LangVersion=latest` riski + kapsam dışı paketler + geçici CVE pini `BORCLAR.md`'de. Gerekçe: hafıza K111.
- 🔒 **K108 — KAPI KİMLİĞİ SPEC-YERELDİR** (Onur kilitledi, 2 Ağu 2026): atıf **daima** kapsam önekli (`A10/G18`). Ölçülmüş gerekçe: `A9b/G17` ≠ `A10/G17`, `A10/G18` ≠ `A9c/G18` (iki farklı kapı, aynı ad; ikisi de kabul edilmiş işin içindeydi) ve dilim spec'lerinin **ilk sekiz kapı kimliği en baştan dilim-yereldi** ⇒ *"küresel dizi"* varsayımı hiç doğru olmamıştı. Hiçbir kilit bozulmadı. Kapısı **var**: `kapi-ad-teklik-kapisi.py` (§6), açılışta **§2 adım 4b**.
- **K73** — **Bir dilimin tasarım/spec kilitleri, dilim KABUL EDİLDİĞİNDE §5'ten çekilir** ve tek satırlık atıfla temsil edilir; çünkü o andan sonra kural **prozada değil KAPIDA** yaşar (K53 doktrini). Arşivde hiçbir şey silinmez. 🔴 Kapısı **olmayan** kilit çekilemez — bu yüzden `K72` §5'te DURUYOR (`G10` henüz yok).
- **slice-3b (K57·K59) · slice-3c (K62–K66) · slice-3d (K68–K70) kilitleri** — hepsi **KABUL EDİLDİ** ⇒ K73 gereği §5'ten **ÇEKİLDİ**. Kurallar (`D0`–`D9`, `P1`–`P7`, `A2`/`G` ayakları) bugün prozada değil **kapılarda ve 40 mutantta koşuyor**; spec kimlikleri §9'da, sapma her açılışta `tek-kopya-kapisi.py` ile ölçülür. 🔴 `P6`/`D4` **K72** ile daraltıldı, düzeltmesi **K74** ile kabul edildi (kapısı `G10`). Gerekçeler: hafıza K57–K74.
- **K61** — **Dev-kimlik kalkanı (şık 1) KİLİTLİ:** yalnız `Development`'ta `DevCurrentUser` (**`X-Momentum-Dev-User`** → `UserId`; başlık yok/bozuk ⇒ 401, sessiz varsayılan kullanıcı YOK); **üretimde `NullCurrentUser` korunur ve bunu bir MUTANT kanıtlar** (`Production` ⇒ 401). `UserId` ⟂ `ClientId`. ADR 0003 **donmuş kalır** (K41). Beyan edilen sınır: bu bir kimlik **çözümü değil**, ölçüm **iskelesidir**.
- **K53** — Verimlilik reformu: kâğıt denetim turu tavanı **1** · radar KIRMIZI'da varsayılan **DEVRET** · koşan-uygulama-mutant tavanı **3** · iki oturum 0 ürün kodu = **sert durak (`R8` — K57'de `R7`'den yeniden adlandırıldı)** · hafıza bölündü.
- **K60** — **Tek kopya dosyaya yazan her betik ATOMİK yazar:** önce `metin.encode("utf-8")` (hata dosyaya **dokunmadan** patlar), sonra `.tmp`, en son takas. Gerekçe ucuz değil: oturum 31'de `io.open(yol,"w")` `PROJE_HAFIZA.md`'yi **önce boşalttı** ⇒ 542 KB arşiv 0 bayta düştü; kurtaran **şanstı** (`git restore`). ✅ Kapısı var: `tek-kopya-kapisi.py`. **Beyan edilen sınır:** kapı hasarı **önlemez**, sessiz kalmasını imkânsız kılar. 🔴 **oturum 34 EKİ:** bu makinede `os.replace` `WinError 5` veriyor ⇒ takas **üç adımlı yedekli** yapılır (§7).
- **K57‑b** — `araclar/radar.py` **plugin 0.2.0 ile BAYT-ÖZDEŞ** (`46E3A8BC`); proje-yerel not **eklenmez** ⇒ sapma **tek sha ile** ölçülür.
- **K58** — `DURUM.md` tavanı **12 → 32 KB**. Gerekçe okuma kapasitesi **değil**: ① R4 freni, ② dikkat (3,5k token okunur, 40k *göz gezdirilir*). Gevşetmenin dayanağı: bayat-atıf sınıfı **mekanikleşti**. 🟢 Tavanı artık `belge-tavan-kapisi.py` **1.0.0** (altın küme **9/9**) zorluyor ve §2 adım 3'te koşuyor — zayıf kontrol **KAPANDI**. Ayrıca `PROJE_HAFIZA.md`'ye **mekanik dizin** (`hafiza-dizin.py`); **yeni checkpoint `<!-- DIZIN:SON -->` ALTINA** eklenir.
- 🟢 **K21'in mekanik kapısı ARTIK VAR:** `araclar/oturum-sagligi.py` **1.0.0**, altın küme **26/26**; `S4` her açılışta ÖLÇÜLÜR (§2 adım 8), buraya **yazılmaz**. 🔴 **Bu satır oturum 45'e kadar *"araç YOK"* diyordu — ölü beyan, K101'de budandı.** Kalan borç (*"alıntı ≠ beyan"* yanlış-pozitifi, K97/§2b): `BORCLAR.md`.
- **K55** — Başka bir el çalışırken `git add -A` **YASAK**; `urun_kodu_satiri` = *"o oturumda repoya giren ürün kodu, **hangi el olursa olsun**"*.
- **K56** — Kanonik kök **saf ASCII** (`C:\dev\Momentum`); `android.overridePathCheck` **eklenmez**, junction **kullanılmaz**.
- **K46** — `DESIGN.md`'ye **tek bayt yazılmaz** (BD‑1…BD‑7 borçları açık).
- **K42-d** — Taç mücevher dilimi dört adım, atlanmaz: (1)✅ Docker+verify → (2) Flutter+Drift+çevrimdışı CRUD → (3) senkron kuyruğu → (4) SignalR.
- **K41** — ADR 0003 v7 **DONDURULDU**; açılması üç şartın BİRLİKTE sağlanmasına + Onur'un açık onayına bağlı.
- **K44-a** — **Önce araç, sonra belge.**
- **K34-f** — Bir aracı **onaran el**, onu **yazan elden AYRI** olmalı.
- **K26** — Üretici kendi denetçisini spawn edemez. **Üreten ≠ denetleyen.**
- **K21** — Oturum sağlığı **ölçülür**; eşikler **MUTLAK** (yüzde YOK). 🔴 **Kanonik eşikler YALNIZ `CLAUDE.md`'de — buraya KOPYALANMAZ.** Ölçülen gerekçe: bu satır eşikleri *yüzde* kopyalayınca **payda düştü**, iki oturum 200k uydurup yanlış renk ilan etti (**K21-DÜZELTME**). **Yüzde yazan el paydayı uydurmuştur.**
- **K40** — Radar KIRMIZI'da yeni tur YASAK; kilit **Onur'dan** gelir.
- **§4** — **Ölç ya da `[DOĞRULANMADI]` yaz.** "Beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez."

---

## 6. ARAÇLAR (`araclar\`) — hepsi önce kendini kanıtlar

| araç | ne yapar | altın küme |
|---|---|---|
| `radar.py` **0.2.0** | kısır döngü + **R8 ürün kodu durgunluğu** + **defter dürüstlüğü D1‑D5** + `--olc-urun-kodu` | **18/18** |
| `spec-kapi-kapsama.py` | spec'te **mutantsız kapı/kural** arar; borç beyanı okur | **13/13** |
| `sayi-tazeligi.py` **1.1.0** | belgedeki **"altın küme N/M"** iddiasını **aracı koşarak** doğrular; muafiyet `tazelik-muafiyet.json`'da ve **gerekçesiz olamaz** | **16/16** |
| `design-token-kapisi.py` **0.2.0** | `DESIGN.md` ↔ Dart token kapısı `D0`–`D6` (D1 sıkılaştırma + D5 + D6 T8'de) | **18/18** |
| `pub-cve-kapisi.py` (`slice-3b/G2`) | `pubspec.lock` ↔ `/advisories`; `withdrawn` atar, `ignored_advisories` **yutmaz** | **8/8** |
| `pub-lisans-kapisi.py` (`slice-3b/G3`) | `pubspec.lock` ↔ `/metrics` SPDX; *bilinmeyen ≠ temiz*; **metin-kanıtlı eşleşme** (`lisans-eslesme.json`, kanıtsız eşleşme KIRMIZI) | **6/6** |
| `iddia-kapisi.py` **1.3.0** [A9c] | saf çekirdek (`kanit_topla`/`denetle`); kanıt eşlemesi **yalnız HAM dosya adından** (`I2`/`I3`), dairesel-kanıt filtresi ad-içi arar, envanter reddi (`LISTE_ESIGI=8`, iki yönlü pinli, `D8` ile **gerçekten** yük taşıyor); `I1` **satır-sha keyli, dosya-kapsamlı** muafiyet alabiliyor (`iddia-muafiyet.json`) | **27/27** |
| `tek-kopya-kapisi.py` **1.1.0** | tek kopya dosyaların **HEAD'e göre regresyonunu** ölçer (`S0`–`S10`); sınıf başına farklı kural: append-only **küçülmez**, kilitli **sapmaz**, canlı **%10 budanabilir**; muafiyet gerekçesiz olamaz, **ölü muafiyeti söyler** | **19/19** |
| `tek-kopya-mutant.py` | kapının **ölçüm ayağını** gerçek depoda kanıtlar: arşivi 0 bayta düşürür, satır siler, kilitli dosyayı **aynı boyutta** değiştirir, `.tmp` bırakır, UTF-8'i bozar, dosyayı siler — hepsinde kapının **ısırdığını** ölçer | **11/11** |
| `hafiza-dizin.py` **1.1.0** | `PROJE_HAFIZA.md`'nin başına **türetilmiş** checkpoint dizini yazar; **fikirli** (koşum 2–3'te sha sabit) ve kendi çıktısını doğrular | **13/13** |
| `belge-tavan-kapisi.py` **1.0.0** | canlı belge **bayt tavanı + PAY**; `T1` aşım (KIRMIZI) · `T2` dar pay (SARI, eşik %5) · `T0` dosya yok. Tavanı **kendi değiştirmez** (K40) | **9/9** |
| `oturum-sagligi.py` **1.0.0** | K21'in mekanik kapısı: kanonik eşik (`S1`) · yüzde avı (`S2`) · eşik kopyası (`S3`) · token+payda (`S4`/`S5`, `--transcript` ister, yoksa **OLCULMEDI**) · kimlik tazeliği (`D1`, **yazım anıyla**). Çıkış 4 = kanonik temiz ama sağlık ölçülmedi | **26/26** |
| `kapi-ad-teklik-kapisi.py` **1.0.0** | K108: `N1` kapsam öneksiz **belirsiz** atıf (KIRMIZI) · `N2` spec içi tekrar · `N3` etiketsiz paylaşım (bilgi). Yol/dosya adı (`KANIT/…/02-G2/`) ve `(GENİŞLETME)` etiketli paylaşım **yanlış-pozitif değildir** — ikisi de ayrı vakayla kanıtlı | **18/18** |
| `dosya-kimlik.py` | bayt + sha256 + U+FFFD + CRLF | — |
| `mcp-arac-probe.py` | MCP'nin **gerçek** araç listesi (`tools/list`) | — |
| `pub-surum-olc.py` | pub.dev `/api` sürüm + advisory | — |
| `lisans-yokla.py` | lisansın hangi uçta olduğunu ölçer | — |
| `yoklama-yasagi-kapisi.py` | slice-3e `G12/T5`: **yoklama yasağı** (K68) + sinyal protokolü statik kapısı `Y1`–`Y4`; `Y3`'ün mutantı **yok** (beyan edilmiş borç) | **15/15** |
| `web-varlik-indir.py` | Drift web ikililerini indirir, sha256'yı `web-varlik.sha256` **pinine** karşı ölçer (TOFU; sürüm karşılaştırması YAPMAZ) | **4/4** |
| `adr-kapi-taramasi.py` | ADR 0003 kapısı (**dondurulmuş**, dokunma) | — |
| `verify.ps1` | backend build+test+CVE zinciri | — |

🔴 **ENVANTER OTURUM 47'DE YENİDEN SAYILDI: `araclar\` altında **27** dosya; **21** çalıştırılabilir (20 `.py` + `verify.ps1`), tablo **21** satır; kalan 6 veri/yardımcı (3 `.json` · `.md` · `.sha256` · `.gitkeep`).** Eski *"20 dosya"* beyanı bu ayrımı yapmıyordu. *Envanterde olmayan kapı tetiklenemez*; `KAPILAR.md`'nin varlık sebebi budur.

---

## 7. KANLA YAZILI ORTAM UYARILARI

- 🔴 **COWORK BULUTTA UTC İLE KOŞUYOR — TARİH ONUR'UN TAKVİMİNDEN 3 SAAT GERİDE [ÖLÇÜLDÜ, oturum 39].** Oturum bağlamı *"Today's date: 2026-07-29"* diyordu; aynı anda cihazda `Get-Date` **2026-07-30 00:50 +03:00** ölçtü (bulut UTC 21:50). **00:00–03:00 arası her oturum bir gün geriye tarih yazar.** Bu oturum bu kusuru fiilen üretti: `K83` checkpoint'i ve defter kaydı `2026-07-29` yazdı, `oturum-sagligi.py`'nin `D1` **zaman ayağı** yakaladı (*"kayıt 29 Tem, dosya 30 Tem'de yazılmış"*) ⇒ append-only iki dosyaya **düzeltme kaydı** girmek zorunda kalındı. 🔴 **Kural: tarih ortam beyanından OKUNMAZ, cihazdan ÖLÇÜLÜR** — `Get-Date -Format 'yyyy-MM-dd'`. Onur'un devir notu doğru tarihi taşıyordu; **bulut yanlıştı, insan doğruydu.**
- **Claude Code DAİMA `Momentum` kökünden açılır** (üstten açarsan `.mcp.json` görünmez, dart MCP yüklenmez).
- **Cowork→PowerShell köprüsü `$` değişkenlerini SİLİYOR** ve iç içe tırnakları bozuyor ⇒ `$` gönderme, **Python betiği yaz**.
- **Commit mesajına ÇİFT TIRNAK yazma** (PowerShell argümanı böler, commit sessizce düşer); sonra `git log --oneline -1` ile SHA'yı doğrula.
- **git'te `--no-optional-locks` ZORUNLU.** Commit **yalnız Desktop Commander** ile; `device_bash`/mount **YASAK**. **PUSH ONUR'DA.**
- 🔴 **`cmd /c "... & echo %ERRORLEVEL%"` KÖRDÜR — SAHTE `EXIT=0` VERİR [ölçüldü, oturum 33].** `%VAR%` **ayrıştırma anında**, komut koşmadan önce genişler. Bu kusurla üç kapı sahte `0` bildirdi; radar gerçekte **2** dönüyordu. **DOĞRUSU: `cmd /v:on /c "... & echo !ERRORLEVEL!"`.** Kör kapı sınıfının **ölçüm katmanındaki** hâli: yeşil gördüğünü sanan el, hiç koşmamış bir kapıyı geçmiş sayar.
- **Cowork↔masaüstü köprüsü oturum ORTASINDA düşebilir** (`device not connected to the bridge`; oturum 34'te internet kesintisinde oldu, `mcp__remote-devices__*` araçlarının **tamamı** düştü). Uzun hafıza yazımını tek parçada yapma; ölçümleri köprüden **bağımsız** bir yere (Cowork projesi) de yaz. K60 *dosyanın* yarım kalmasını engeller, **oturumun** yarım kalmasını engellemez.
- 🔴 **`os.replace` bu makinede `WinError 5` verebilir** — hedef de kaynak da **kilitli olmadığı hâlde** (ölçüldü: her ikisi de `rename` edilebiliyor, hedef `r+b` açılıyor). Windows'un klasör/fidye koruması *var olan dosyayı değiştir* desenini engelliyor, düz `rename`'e izin veriyor. **Çalışan yol:** `rename(hedef→.yedek)` → `rename(.tmp→hedef)` → **sha doğrula** → `.yedek` sil (adım 2 patlarsa yedek geri alınır). K60'ın atomik takası bu makinede **üç adımlı yedekli takas**tır.
- 🔴 **`python` stdout bu makinede cp1254** — `⇒` gibi bir karakter yazdıran betik `UnicodeEncodeError` ile **kabuğu öldürüyor** (ölçüldü: PowerShell süreci komut ortasında düştü). Zorunlu: `sys.stdout.reconfigure(encoding="utf-8", errors="replace")`. Kusur **stdout**'ta, dosyada değil.
- **`device_stage_files` BAYAT KOPYA sunabiliyor** (oturum 28; 30'da tekrarlanmadı) ⇒ stage'lenenin **sha'sını karşılaştır**; tutmuyorsa `read_file` kullan.
- 🔴 **YOL SAF ASCII KALMAK ZORUNDA [K56].** Türkçe karakter dört zinciri kırdı (`build_runner`, `flutter analyze`, AGP, `.ps1`). Boşluk suçsuz, junction çözmez. Ayrıntı: `KANIT/slice-3b/ORTAM-YOL-KISITI.txt`.
- 🔴 **`findstr` AYNI DOSYADA bir dizgeyi bulup diğerini KAÇIRABİLİYOR [ölçüldü, oturum 46].** `.gitignore`'da `"Dd"` ve `"bin"` **bulundu**, *aynı satırlardaki* `"ebug"` ve `"npm"` **bulunamadı**; dosyanın **bayt-özdeş kopyası** başka adla arandığında ikisi de bulundu (dosya UTF-8, LF, BOM'suz — Python ile ölçüldü). Ayrıca `/s` **çıplak dizin** yolu (wildcard'sız) verilirse **sessizce 0** döner. ⇒ **`findstr` ile YOKLUK ölçen her ayak, AYNI dosyada bir VARLIK pozitif kontrolü koşmak ZORUNDADIR** (`A10/G18/b` · `A10/G18/d` · `A10/G21/b` bu oturumda böyle doğrulandı).
- **Git Bash/MSYS, `cmd /c`'deki `/c`'yi POSIX yol sanıp `C:/` diye YENİDEN YAZIYOR** ⇒ ham `cmd /c` içeren komutlar **PowerShell'den** koşulur.
- **Başka bir el çalışırken `git add -A` YASAK** — commit'lenmemiş işini kör alır (ölçüldü: `dee6dbc`). Yol belirterek `git add <yol>` yap.
- **`flutter test --platform chrome` bu ortamda SONUÇ ÜRETMİYOR** (iki ölçüm: 7 dk ve 9,8 dk) ⇒ web test ayağı `[DOĞRULANMADI]`.
- **pub.dev HTML sayfaları BAYAT** — kanıt yalnız `/api/` ucudur (spec Z10). · `.ps1`'e Türkçe yol literali yazma. · `kasif` skill'ini **Cowork çağıramaz**; Onur `/kasif` yazar.
- 🔴 **`git`'te `core.autocrlf` AKTİF** — `git restore` LF yazılmış 2.400 baytlık dosyayı **2.800 bayt** geri getirdi (ölçüldü). Çalışma kopyası ↔ HEAD blob **bayt karşılaştırması bu ortamda tek başına KÖRDÜR**; kimlik ölçen her araç LF'e normalize etmelidir.
- 🔴 **`io.open(yol,"w")` DOSYAYI ÖNCE BOŞALTIR** — encode hatası gelirse dosya **0 bayt** kalır (oturum 31: 542 KB arşiv gitti, `git restore` kurtardı). **Python'da `"\ud83d\udd3b"` iki `\u` kaçışı olarak yazılırsa BİRLEŞMEZ**, yalnız vekil karakter olur ve `encode` patlar; emoji için `\U0001F53B` yaz. Kural: **K60 atomik yazım**.
- **`flutter test` Desktop Commander kabuğunda ÇÖKÜYOR** — `%PROGRAMFILES(X86)% environment variable not found` (ölçüldü: değişken `os.environ`'da **yok**, dizin diskte **var**). ⇒ alt sürece `PROGRAMFILES(X86)=C:\Program Files (x86)` **enjekte et**; kalkanla test 36/36 geçti. Bu bir **ortam** kusurudur, ürün kusuru değil.
- 🔴 **`uiautomator dump` uygulama henüz çizilmeden çağrılırsa "null root node" verir ve DOSYA OLUŞMAZ [K86, oturum 40].** Sabit bekleme değil, çıktıda `"dumped to"` dizgesi görünene kadar **yoklanır** (tavanlı).
- **`flutter` bu makinede `.bat`'tir [K86]** — Python `subprocess` PATHEXT'i çözmez ⇒ doğrudan çağrı `WinError 2` verir; tam yol `C:\src\flutter\bin\flutter.bat` kullanılır.
- **Commit mesajındaki çift tırnak yasağı yeniden ISIRDI [K86, oturum 40]** — bir commit `pathspec` hatasıyla düştü, ağaç sağlam kaldı; kural aynı kalır (§ üstteki madde).

---

## 8. AÇIK BORÇLAR → **`BORCLAR.md`**

🔴 **Bu bölüm 30 Tem 2026'da (oturum 39, kilit K83) `BORCLAR.md`'ye TAŞINDI.** Kazanç toplam bayt değil, **her
oturumun okumak zorunda olduğu** bayttır (31.744 → 21.349). `BORCLAR.md` açılışta **okunmaz**, kendi tavanını
taşır, `belge-tavan-kapisi.py` kapsamındadır. Ölçüm ve gerekçenin tamamı **arşivde** (K83).

---

## 9. DOSYA KİMLİKLERİ (`sha256` ilk 8 · **son yazımdan sonra ölçülür**)

🔴 **BURAYA YALNIZ *DONMUŞ* KİMLİKLER YAZILIR.** Sık değişen bir sha'yı buraya yazmak `kanonik-kopya` kusurunu **garanti eder** (bu tabloda üç kez oldu). Değişkenlerin kimliği **yazılmaz, ÖLÇÜLÜR**:

```powershell
python araclar\dosya-kimlik.py DURUM.md CLAUDE.md DESIGN.md PROJE_RADAR.jsonl GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md
```

**DONMUŞ KİMLİKLER (bunlar SÖZLEŞMEDİR — değişirse bir kilit bozulmuş demektir):**

| dosya | bayt | sha8 | neden donmuş |
|---|---|---|---|
| `DESIGN.md` **v2** | **18.075** | **`3780ACA4`** | 🔴 **K46 AÇILDI (K75)** — `534DFF68` (v1) **GEÇERSİZDİR**. Açılma kapsamı iki maddedir (bileşik satır + `gonderilmemis`); başka değişiklik Onur'un kilidini ister |
| `GOREV-slice-3b-istemci-iskeleti.md` | **44.560** | **`F0C3A75A`** | 🔒 **K59 kilidi (v6)** — değişen her bayt kilidi bozar. `6056A5BB` · `79A53AA3` · `BE4581BA` · `1AB02B73` **geçersizdir** |
| `GOREV-slice-3c-senkron.md` | **41.692** | **`537D0579`** | 🔒 **K64 kilidi (v2, Onur onayladı 27 Tem 2026)** — `5899A220` (v1) **GEÇERSİZDİR**. `tek-kopya-kapisi.py` kapsamında **`kilitli`** sınıfındadır ⇒ sapma **her açılışta ölçülür** |
| `GOREV-slice-3d-cekme.md` | **80.399** | **`889A383F`** | 🔒 **K70 kilidi** (Onur onayladı 28 Tem 2026) — build'i sürdü, iki bağımsız denetimden geçti, `tek-kopya-kapisi.py` kapsamında **`kilitli`** ⇒ sapma **her açılışta** ölçülür |
| `araclar/radar.py` | 28.878 | `46E3A8BC` | **K57‑b** — plugin 0.2.0 ile bayt-özdeş; sapma tek sha ile ölçülür |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` | **K34-f** tutuyor; ADR donduruldu |
| `araclar/tek-kopya-kapisi.py` | **17.259** | **`66AC9CA3`** | K70'te kapsam genişledi; değişiklikten sonra **mutant kümesi 11/11 yeniden koştu** |

| `GOREV-slice-3e-G12.md` | **12.623** | **`BDB3630E`** | 🔒 **K79 kilidi**. 🔴 Beyanlı-kilit sepetinde — gerekçe ve sepetin tamamı `BORCLAR.md`'de (tek kopya) |
| `GOREV-A10-cihaz-on-kosullari.md` | **26.126** | **`8AD6CA10`** | 🔒 **K105 kilidi (v2, Onur onayladı 1 Ağu 2026)** — `04E49CC9` (v1) ve `A947CC1E` (kilit satırı ÖNCESİ v2) **GEÇERSİZDİR**. 🔴 Beyanlı-kilit sepetinde — gerekçe `BORCLAR.md`'de. Kapıları **`A10/G17`–`A10/G21`** (K108) |
| `GOREV-A9c-D5-kor-kapi-onarimi.md` | **20.600** | **`53ED7838`** | 🔒 **K109 kilidi (Onur onayladı 2 Ağu 2026)** — kilit satırı **ÖNCESİ** `D88312F6` (19.497 b) **GEÇERSİZDİR**. Kapısı **`A9c/G18`** (K108; `A10/G18` ile adı aynı, kendisi farklı). 🔴 Beyanlı-kilit sepetinde — gerekçe `BORCLAR.md`'de |

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** ve **DAİMA son yazımdan SONRA** ölçülür.

---

## 10. NEREDE NE VAR

`DURUM.md` (canlı, **açılışta okunur**) · `CLAUDE.md` (kalıcı kurallar, **açılışta okunur**) · `BORCLAR.md` (**açık borçlar — açılışta OKUNMAZ**, K83) · `PROJE_HAFIZA.md` (**append-only arşiv**, K1…K83) · `DESIGN.md` · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` · `araclar/` · `KANIT/` · `src/`.
