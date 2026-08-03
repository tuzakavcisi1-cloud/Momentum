# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Tavan: **≤ 32 KB** [K58; eski tavan 12 KB]. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır. Gerekçe okuma kapasitesi değil **R4 freni + dikkat**; tavanı artık `belge-tavan-kapisi.py` zorluyor (§2 adım 3) — beyan edilmiş zayıf kontrol **KAPANDI**. 🔴 Aracın **banner sürümü bayattır** (`1.0.0` yazıyor, belgeler `1.1.0` diyor; kapasitesi gerçekten güncel, altın küme **12/12** ölçüldü) — borç `B-O50-2`.
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 3 Ağu 2026, **oturum 51 (K122 · K123 · K124 — `A12` KABUL EDİLDİ)** — açılışın 10 adımı koştu; `A12`'nin **yedi kriteri + üç şartı da ölçülerek** geçti (`M156`–`M161` **6/6 ISIRDI**). Yolda iki kâğıt iddiası yanlışlandı (*"sekiz eski spec"* → **10** · *"patlama yarıçapı 0"* → **9 bulgu**) ve `BORCLAR.md` budandı. Önceki oturum: `A11`'in **sekiz kriteri de ölçülerek** geçti. Yolda iki kusur bulundu ve kapatıldı: `M141` **kör ayaktı** (eşdeğerlik **yanlışlandı**, varsayılmadı) ⇒ `G22`/`c2` doğdu · kriter 7 ile 8 **backend konusunda çelişiyordu** ⇒ sıra pazarlıksız oldu. Mutantlar **17/17 ISIRIYOR**. *(Oturum 39–49'da yapılan iş arşivdedir.)*

---

## 1. Proje

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) + **N-katmanlı .NET 9 / ASP.NET Core** backend + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak **mimari ve kod kalitesi**. Vitrin: **çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği**.

**Kanonik kök: `C:\dev\Momentum`** 🔴 **[K56 — TAŞINDI]** · gerekçe ve kısıt **§7'de** (üçüncü kopya oturum 47'de budandı, `kanonik-kopya`); hiçbir kapı susturulmadı.

---

## 2. AÇILIŞ PROTOKOLÜ (sırayla, atlanmaz)

1. **Bu dosyayı** + `CLAUDE.md` + **`ORTAM.md`**'yi **TAM** oku. *(`PROJE_HAFIZA.md` ve `BORCLAR.md` AÇILMAZ.)* 🔴 **ÜÇÜNÜ DE** — `ORTAM.md` oturum 49'da §7'den ayrıldı ve *okunmaz* sınıfına **KONULMADI** (Onur kilitledi): mayın listesi başvuru değil **operasyoneldir**. 🔴 **SAHTE YEŞİL YASAĞI:** oturum 38'de `CLAUDE.md` okunmadan "okundu" işaretlendi: **sahte yeşil**.
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
| **İstemci (Flutter)** | 🟢 **slice-3b→3e + R9/R10 + A7/A8/A9 BİTTİ — senkron ÇİFT YÖNLÜ + gerçek zamanlı sinyal.** Drift çevrimdışı CRUD · itme kuyruğu · çekme (`UzakAlanDurumu` v4 + yerel LWW + `hasMore` + snapshot/artımlı) · rozet **kuyruktan türetiliyor** · SignalR-JSON sinyali (web'de `kIsWeb` ile KAPALI). Kapılar **spec-yereldir** (K108; envanter `GOREV_CLAUDE_CODE/`'da ÖLÇÜLÜR) + `design-token-kapisi.py` + `iddia-kapisi.py` **1.3.0**. Ölçülen mutantlar: **`M1`–`M108`** (dilim dilim) + A9b'nin **14** kanıtı; `M119` ISIRIYOR (vaka 27, `A9c/D8`); **`M139`–`M155` 17/17 ISIRIYOR** (`A11` KABUL, K121). Son koşumlar **Cowork'ün kendisi** (K26): `flutter test` **500/500** · `analyze --fatal-infos` **0** · **release APK derlendi** (bu depoda ilk kez, K106). 🔴 A‑7 `DESIGN.md`'de kapanmadı (K46). Tur tur anlatım **arşivde** (K73). |
| **Tasarım sistemi** | ✅ `DESIGN.md` **v2** — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7. Kimlik **§9'da** (v1 `534DFF68` **GEÇERSİZ**) |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `radar.py` **plugin 0.2.0 ile bayt-özdeş** · altın küme **18/18**. Hüküm **KIRMIZI** (oturum 40'ta yeniden ölçüldü), **yapısaldır** (park mekanizması yok ⇒ `BORCLAR.md`). 🔴 **KIRMIZI ARTEFAKTLARIN ADI VE SAYISI BURAYA YAZILMAZ — §2 adım 6'da ÖLÇÜLÜR** *(bu satır bir kez "aynı iki artefakt" dedi, ölçüm **11** verdi: sayı yazan satır bayatlar, ölçüme atan bayatlamaz — K82-b)*. 🔒 **K83 — Onur DURDUR'u kilitledi:** park yürürlükte, dört-şık ritüeli **tekrarlanmaz**. 🔴 **`R8` DURUMU DA YAZILMAZ, ÖLÇÜLÜR:** K104'te **ısırdı** (44–45 sıfır), K106'da **düştü**; sayı daima `--olc-urun-kodu <sha>` ile **git'ten** türetilir (K55). |
| **Git** | **PUSH DAİMA ONUR'DA.** İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR** — komut ve **`fetch` şartı yalnız §2 adım 7'de**; buraya **kopyalanmaz** (kanonik-kopya kusuru bu projede beş kez ısırdı). |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · **.NET 10.0.302** (K111; 9.0.316 de kurulu) · **Windows masaüstü ☠** · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

🔒 **K89–K100 KAPANDI (oturum 42–44):** `KAPILAR.md` · `A8` v2 · `A9` v3 · `A9b` v2 · **A9 KABUL**; arşivde.

🟢 **`GOREV-A10` KABUL (K106) · `.gitignore` tuzağı KAPANDI (K107).** Kapılar **`A10/G17`–`A10/G21`**,
mutantlar **`M125`–`M135`**; anlatım arşivde. 🟢 **`GOREV-A9c` KİLİTLİ (K109)**, iş **Claude Code'a
hazır** (K34-f) — araç onarımı olduğu için `R8`'i düşürmez.
🟡 `D5` kör kapı, A9b hassaslaştırma ve `vaka 20b`: gerekçeler **arşivde** (K100 · K102 · K104 · K106).

🟢 **①–④ KAPANDI, ANLATIMLARI ARŞİVDE (K73):** **`.NET 10` geçişi** (**K111**; `net10.0` + SDK pini
`10.0.302`, `verify.ps1` EXIT 0, commit `a20e290`+`a0aed23`; geçiş **ATOMİK**, ara durum `CS0023` ile
kırık) · **A10** (**K106**; *"`devUserId` alanı"* derleme-zamanı `--dart-define` ezmesidir, UI alanı
**değil**) · **cihaz→sunucu senkron** (**K112/K113**; `onYerelYazma`+`elleYenile` ⇒ **2,1 s**,
`M136`/`M137` ısırıyor) · **çevrimdışı ayağı** (**K115**; 30 s sızıntı yok) ve onun doğurduğu
**K116** dört kilidi. Kanıtlar: `KANIT/net10-adim6/` · `KANIT/ucuncu-cihaz-senkron/` ·
`KANIT/cevrimdisi-senkron/`. Paket borçları `BORCLAR.md`'de.

🟢 **⑤ `A11` KABUL EDİLDİ (K121, oturum 50 · Onur kilitledi).** Sekiz kriterin sekizi de **ölçülerek**
geçti (hepsi **Cowork'ün kendi koşumu**, K26; kanıt `KANIT/A11/`, hüküm `07-KABUL-HUKMU.md`):
`flutter test` **500/500** · **`M139`–`M155` 17/17 ISIRDI** · `verify.ps1` **EXIT 0** (build 0/0 ·
test 120/120 · CVE 0) · cihazda **186 s çevrimdışı → `T1`+4 s**.
`yoklama-yasagi-kapisi.py` altın küme **26/26**. 🔴 **Yolda iki kusur kapandı:** `M141` **kör ayaktı** (eşdeğerlik **yanlışlandı**) ⇒ `c2`
doğdu · kriter 7↔8 **çelişiyordu** ⇒ sıra **pazarlıksız: 7 → kapat → 8**. Kriter 7'nin kapısı **yok**,
borç `B-O50-1`. *(Ayrıntı arşivde, K73.)*
**➡ SIRADAKİ İLK İŞ: ⑦ iOS iskelesi + CI — ÜRÜN KODU** (`A12` araç işiydi, `R8`'i düşürmedi; iki
oturum üst üste 0 ürün kodu **sert duraktır**, K53/4). Kapsam kilidi Onur'dan.
🔴 **ÖLÇÜLMEYEN:** çakışma rozeti · çift yönün kabul kriterleri · **fiziksel cihaz** (yalnız
emülatör; NAT kurulu soketi koruduğu için SignalR yeniden bağlanma yolu **hiç egzersiz edilmedi**) · CI.
→ **⑦ iOS iskelesi + CI** → ⑧ `SS2` (dar) → ⑨ web borcu + release → ⑩ `ADR 0004` + vitrin. *(⑥ `A12` KAPANDI.)*
🔴 **ORTAM ÇAKIŞMASI ÖLÇÜLDÜ (oturum 50):** `verify.ps1` **çalışan bir `Momentum.Api` varken KOŞULAMAZ**
(36× `MSB3026`/`MSB3027`, DLL kilidi) ⇒ sıra **pazarlıksız: cihaz kanıtı → backend KAPATILIR → `verify.ps1`**.
Madde `ORTAM.md`'de. Cowork süreci **Onur'un açık izniyle kapattı**, **yeniden BAŞLATMADI** (K80 ayakta).

🟢 **⑥ `GOREV-A12` KABUL EDİLDİ (K124, oturum 51 · Onur kilitledi).** `spec-kapi-kapsama.py` altın küme
**21/21**; kural yarısı artık **çalışıyor**. Yedi kriter + üç şart **ölçülerek** geçti (hepsi Cowork'ün
kendi koşumu, K26; hüküm `KANIT/A12/04-COWORK-KABUL-HUKMU.md`): patlama yarıçapı **fark 0** ·
**`M156`–`M161` 6/6 ISIRDI**, araç bayt-özdeş · §6b öncesi/sonrası **EXIT 1 → 0**. 🔴 **Kalan kör nokta
BİLEREK açık: `B-O51-1`** (`S2` dolaylı eşlemeyi görmüyor). 🔴 Araç işidir ⇒ **`R8`'i DÜŞÜRMEZ.**

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
- **K116 · K120 — `A11` KABUL EDİLDİ (K121, Onur kilitledi, 2 Ağu 2026)** ⇒ K73 gereği tasarım/spec kilitleri §5'ten **ÇEKİLDİ**. `D0` daraltması (periyodik **ÇEKME** yasak; **tek istisna** kuyrukta bekleyen satır varken **başarısız İTMEnin** tavanlı geri çekilmesi) · taşıma hatası ve `5xx`'in `denemeSayisi` muafiyeti · retry'ın **kendi sınıfında** yaşaması (`ItmeYenidenDeneme`) · `Y1`'in **kapsayan-gövde** kuralı — hepsi bugün prozada değil **`A11/G22`–`A11/G24` kapılarında ve `M139`–`M155` mutantlarında** koşuyor (**17/17 ISIRIYOR**, Cowork'ün kendi koşumu, K26). 🔴 **Yaşayan üç beyan:** ① `GOREV-slice-3d-cekme.md`'deki `D0` metni **bilerek bayat** (K70 kilitli) — kanonik metin `GOREV-A11` §3'tür ② `main.dart:149` sinyal dinleyicisini ölçen kapı **YOK** (`B-O50-1`) ③ `durdur()` üretimde çağrılmıyor · `408`/`429` kapsam dışı · **fiziksel cihaz ölçülmedi**. Gerekçeler: hafıza K116/K120/K121.
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
- **K58** — `DURUM.md` tavanı **12 → 32 KB**. Gerekçe okuma kapasitesi **değil**: ① R4 freni, ② dikkat (3,5k token okunur, 40k *göz gezdirilir*). Gevşetmenin dayanağı: bayat-atıf sınıfı **mekanikleşti**. 🟢 Tavanı artık `belge-tavan-kapisi.py` (altın küme **12/12**) zorluyor ve §2 adım 3'te koşuyor — zayıf kontrol **KAPANDI**. 🔴 Aracın **banner sürümü bayat** (`1.0.0`), borç `B-O50-2`. Ayrıca `PROJE_HAFIZA.md`'ye **mekanik dizin** (`hafiza-dizin.py`); **yeni checkpoint `<!-- DIZIN:SON -->` ALTINA** eklenir.
- 🔒 **K117 — `BORCLAR.md` TAVANI 16 → 24 KB (Onur, 2 Ağu 2026):** ölçülmüş gerekçe üçlü — ① oturum 48 budamayı **ölçtü**, net **+258 b** ⇒ budama bu dosyada işe yaramıyor ② dosyada `##` bölüm başlığı **yok**, yalnız 4 kapanma işareti var ⇒ arşivlenecek **ölü kütle de yok** ③ pay 212 b'ye düşünce kapı borcun **kapanmasına** değil **kaydedilmesine** baskı yapmaya başlamıştı; oturum 49 **dört yeni ölçülmüş borç** üretti ve hiçbiri yazılamadı. **Görünür borcu görünmez yapan bir eşik, uzun listeden kötüdür.** 🔴 **Beyan edilmiş bedel: bu bir GEVŞETMEDİR**; karşılığında K40'ın altın-küme şartı **mekanikleşti** (vaka 10) ve `belge-tavan-kapisi.py` altın küme **12/12** oldu.
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
| `spec-kapi-kapsama.py` | spec'te **mutantsız kapı/kural** arar; borç beyanı okur (`A12`: §3 karar başlıkları da okunur) | **21/21** |
| `sayi-tazeligi.py` **1.1.0** | belgedeki **"altın küme N/M"** iddiasını **aracı koşarak** doğrular; muafiyet `tazelik-muafiyet.json`'da ve **gerekçesiz olamaz** | **16/16** |
| `design-token-kapisi.py` **0.2.0** | `DESIGN.md` ↔ Dart token kapısı `D0`–`D6` (D1 sıkılaştırma + D5 + D6 T8'de) | **18/18** |
| `pub-cve-kapisi.py` (`slice-3b/G2`) | `pubspec.lock` ↔ `/advisories`; `withdrawn` atar, `ignored_advisories` **yutmaz** | **8/8** |
| `pub-lisans-kapisi.py` (`slice-3b/G3`) | `pubspec.lock` ↔ `/metrics` SPDX; *bilinmeyen ≠ temiz*; **metin-kanıtlı eşleşme** (`lisans-eslesme.json`, kanıtsız eşleşme KIRMIZI) | **6/6** |
| `iddia-kapisi.py` **1.3.0** [A9c] | saf çekirdek (`kanit_topla`/`denetle`); kanıt eşlemesi **yalnız HAM dosya adından** (`I2`/`I3`), dairesel-kanıt filtresi ad-içi arar, envanter reddi (`LISTE_ESIGI=8`, iki yönlü pinli, `D8` ile **gerçekten** yük taşıyor); `I1` **satır-sha keyli, dosya-kapsamlı** muafiyet alabiliyor (`iddia-muafiyet.json`) | **27/27** |
| `tek-kopya-kapisi.py` **1.1.0** | tek kopya dosyaların **HEAD'e göre regresyonunu** ölçer (`S0`–`S10`); sınıf başına farklı kural: append-only **küçülmez**, kilitli **sapmaz**, canlı **%10 budanabilir**; muafiyet gerekçesiz olamaz, **ölü muafiyeti söyler** | **19/19** |
| `tek-kopya-mutant.py` | kapının **ölçüm ayağını** gerçek depoda kanıtlar: arşivi 0 bayta düşürür, satır siler, kilitli dosyayı **aynı boyutta** değiştirir, `.tmp` bırakır, UTF-8'i bozar, dosyayı siler — hepsinde kapının **ısırdığını** ölçer | **11/11** |
| `hafiza-dizin.py` **1.1.0** | `PROJE_HAFIZA.md`'nin başına **türetilmiş** checkpoint dizini yazar; **fikirli** (koşum 2–3'te sha sabit) ve kendi çıktısını doğrular | **13/13** |
| `belge-tavan-kapisi.py` (banner **1.0.0**, etiket bayat ⇒ `B-O50-2`) | canlı belge **bayt tavanı + PAY**; `T1` aşım (KIRMIZI) · `T2` dar pay (SARI, eşik %5) · `T0` dosya yok. Tavanı **kendi değiştirmez** (K40) — 🟢 **vaka 10 artık kapsam tablosundaki HER tavanı PİNLER**: K40'ın *"eşik değiştiren altın kümeye vaka ekler"* şartı **prozadan kapıya taşındı** ve K89'dan beri taşınan *"küme `VARSAYILAN_KAPSAM`'a dokunmuyor"* borcu **KAPANDI** | **12/12** |
| `oturum-sagligi.py` **1.0.0** | K21'in mekanik kapısı: kanonik eşik (`S1`) · yüzde avı (`S2`) · eşik kopyası (`S3`) · token+payda (`S4`/`S5`, `--transcript` ister, yoksa **OLCULMEDI**) · kimlik tazeliği (`D1`, **yazım anıyla**). Çıkış 4 = kanonik temiz ama sağlık ölçülmedi | **26/26** |
| `kapi-ad-teklik-kapisi.py` **1.0.0** | K108: `N1` kapsam öneksiz **belirsiz** atıf (KIRMIZI) · `N2` spec içi tekrar · `N3` etiketsiz paylaşım (bilgi). Yol/dosya adı (`KANIT/…/02-G2/`) ve `(GENİŞLETME)` etiketli paylaşım **yanlış-pozitif değildir** — ikisi de ayrı vakayla kanıtlı | **18/18** |
| `dosya-kimlik.py` | bayt + sha256 + U+FFFD + CRLF | — |
| `mcp-arac-probe.py` | MCP'nin **gerçek** araç listesi (`tools/list`) | — |
| `pub-surum-olc.py` | pub.dev `/api` sürüm + advisory | — |
| `lisans-yokla.py` | lisansın hangi uçta olduğunu ölçer | — |
| `yoklama-yasagi-kapisi.py` | slice-3e `G12/T5`: **yoklama yasağı** (K68) + sinyal protokolü statik kapısı `Y1`–`Y4`; `Y3`'ün mutantı **yok** (beyan edilmiş borç). 🟢 **`A11`/`D-A11-3` ile genişledi (oturum 49):** gövde kuralı **kapsayan fonksiyona** taşındı, `Future.delayed` de taranıyor ⇒ `while{}`/`.then()` kaçakları kapandı | **26/26** |
| `web-varlik-indir.py` | Drift web ikililerini indirir, sha256'yı `web-varlik.sha256` **pinine** karşı ölçer (TOFU; sürüm karşılaştırması YAPMAZ) | **4/4** |
| `adr-kapi-taramasi.py` | ADR 0003 kapısı (**dondurulmuş**, dokunma) | — |
| `verify.ps1` | backend build+test+CVE zinciri | — |

🔴 **ENVANTER OTURUM 47'DE YENİDEN SAYILDI: `araclar\` altında **27** dosya; **21** çalıştırılabilir (20 `.py` + `verify.ps1`), tablo **21** satır; kalan 6 veri/yardımcı (3 `.json` · `.md` · `.sha256` · `.gitkeep`).** Eski *"20 dosya"* beyanı bu ayrımı yapmıyordu. *Envanterde olmayan kapı tetiklenemez*; `KAPILAR.md`'nin varlık sebebi budur.

---

## 7. KANLA YAZILI ORTAM UYARILARI → **`ORTAM.md`**

🔴 **Bu bölümün İÇERİĞİ 2 Ağu 2026'da (oturum 49, Onur kilitledi) `ORTAM.md`'ye TAŞINDI; numara ve
başlık BİLEREK burada kaldı.** `DURUM.md §7`'ye adıyla atıf yapan **6 canlı satır** ölçüldü
(`DURUM.md`:13 · `KAPILAR.md`:30 · `GOREV-A8`:54,208 · `GOREV-A9`:369 · `GOREV-A9b`:318,320) —
bölümü silmek **sarkan atıf** sınıfını doğururdu; `kanonik-kopya`nın kardeşidir ve bu projede
altı kez ısırmış sınıfın aynısıdır.

🔴 **`ORTAM.md` AÇILIŞTA OKUNUR** (§2 adım 1) — `BORCLAR.md`/`KAPILAR.md` gibi *okunmaz* sınıfına
**KONULMADI**. Ölçülmüş gerekçe: tavanın kendi gerekçesi *"okuma kapasitesi DEĞİL, R4 freni +
dikkat"*tir; ayrı dosya + ayrı tavan R4'ü zaten çözer, listeyi gözden kaldırmak ise ödenmemiş bir
bedeldir. Kendi tavanını taşır ve `belge-tavan-kapisi.py` kapsamındadır.

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
| `araclar/tek-kopya-kapisi.py` | **17.352** | **`9D7D0781`** | K70'te kapsam genişledi. 🔴 **Oturum 49'da `ORTAM.md` kapsama eklendi** (`66AC9CA3` / 17.259 b **GEÇERSİZDİR**); aynı disiplin koştu: altın küme **19/19**, ardından `araclar/tek-kopya-mutant.py` **11/11**; ve kapı commit'ten önce `ORTAM.md` için `S5` vererek kapsam eklemesinin **canlı olduğunu kendisi kanıtladı** |

| `GOREV-slice-3e-G12.md` | **12.623** | **`BDB3630E`** | 🔒 **K79 kilidi**. 🔴 Beyanlı-kilit sepetinde — gerekçe ve sepetin tamamı `BORCLAR.md`'de (tek kopya) |
| `GOREV-A10-cihaz-on-kosullari.md` | **26.126** | **`8AD6CA10`** | 🔒 **K105 kilidi (v2, Onur onayladı 1 Ağu 2026)** — `04E49CC9` (v1) ve `A947CC1E` (kilit satırı ÖNCESİ v2) **GEÇERSİZDİR**. 🔴 Beyanlı-kilit sepetinde — gerekçe `BORCLAR.md`'de. Kapıları **`A10/G17`–`A10/G21`** (K108) |
| `GOREV-A9c-D5-kor-kapi-onarimi.md` | **20.600** | **`53ED7838`** | 🔒 **K109 kilidi (Onur onayladı 2 Ağu 2026)** — kilit satırı **ÖNCESİ** `D88312F6` (19.497 b) **GEÇERSİZDİR**. Kapısı **`A9c/G18`** (K108; `A10/G18` ile adı aynı, kendisi farklı). 🔴 Beyanlı-kilit sepetinde — gerekçe `BORCLAR.md`'de |

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** ve **DAİMA son yazımdan SONRA** ölçülür.

---

## 10. NEREDE NE VAR

`DURUM.md` (canlı, **açılışta okunur**) · `CLAUDE.md` (kalıcı kurallar, **açılışta okunur**) · `ORTAM.md` (**kanla yazılı ortam uyarıları — açılışta OKUNUR**, oturum 49) · `BORCLAR.md` (**açık borçlar — açılışta OKUNMAZ**, K83) · `PROJE_HAFIZA.md` (**append-only arşiv**, K1…K83) · `DESIGN.md` · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` · `araclar/` · `KANIT/` · `src/`.
