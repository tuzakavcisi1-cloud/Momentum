# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Tavan: **≤ 32 KB** [K58; eski tavan 12 KB]. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır. Gerekçe okuma kapasitesi değil **R4 freni + dikkat**; tavanı artık `belge-tavan-kapisi.py` zorluyor (§2 adım 3) — beyan edilmiş zayıf kontrol **KAPANDI**. 🔴 Aracın **banner sürümü bayat** — borç `B-O50-2` (ayrıntı orada).
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 5 Ağu 2026, **oturum 60** — **`W2` KABUL EDİLDİ (`K144`, Onur kilitledi)**; kriter 4'ün 4/17 aşırı-yakalaması **`K145` ERRATUM**'la **hafızada** düzeltildi (kilitli spec'e dokunulmadı). Açılışın on adımı ölçüldü. *(Oturum 39–59 anlatımı arşivde — `PROJE_HAFIZA.md` K129–K145.)*

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
| **İstemci (Flutter)** | 🟢 **slice-3b→3e + R9/R10 + A7/A8/A9 BİTTİ — senkron ÇİFT YÖNLÜ + gerçek zamanlı sinyal.** Drift çevrimdışı CRUD · itme kuyruğu · çekme (`UzakAlanDurumu` v4 + yerel LWW + `hasMore` + snapshot/artımlı) · rozet **kuyruktan türetiliyor** · SignalR-JSON sinyali (web'de `kIsWeb` ile KAPALI). 🟢 **`ios/` VAR ve CI'da DERLENİYOR** (`A13`, K129): `Runner.app` **18,7 MB**. Kapılar **spec-yereldir** (K108; envanter `GOREV_CLAUDE_CODE/`'da ÖLÇÜLÜR). Ölçülen mutantlar **`M1`–`M170`** (dilim dilim; sayı ve ısırma durumu **kabul hükümlerinde**, buraya yazılmaz). Son koşumlar **Cowork'ün kendisi** (K26): `flutter test` **539/539** · `analyze --fatal-infos` **0** · release APK (K106). 🔴 A‑7 `DESIGN.md`'de kapanmadı (K46). Tur tur anlatım **arşivde** (K73). |
| **Tasarım sistemi** | ✅ `DESIGN.md` **v2** — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7. Kimlik **§9'da** (v1 `534DFF68` **GEÇERSİZ**) |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `radar.py` **plugin 0.2.0 ile bayt-özdeş** · altın küme **18/18**. Hüküm **KIRMIZI** (oturum 40'ta yeniden ölçüldü), **yapısaldır** (park mekanizması yok ⇒ `BORCLAR.md`). 🔴 **KIRMIZI ARTEFAKTLARIN ADI VE SAYISI BURAYA YAZILMAZ — §2 adım 6'da ÖLÇÜLÜR** *(bu satır bir kez "aynı iki artefakt" dedi, ölçüm **11** verdi: sayı yazan satır bayatlar, ölçüme atan bayatlamaz — K82-b)*. 🔒 **K83 — Onur DURDUR'u kilitledi:** park yürürlükte, dört-şık ritüeli **tekrarlanmaz**. 🔴 **`R8` DURUMU DA YAZILMAZ, ÖLÇÜLÜR:** K104'te **ısırdı** (44–45 sıfır), K106'da **düştü**; sayı daima `--olc-urun-kodu <sha>` ile **git'ten** türetilir (K55). |
| **Git** | **PUSH DAİMA ONUR'DA.** İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR** — komut ve **`fetch` şartı yalnız §2 adım 7'de**; buraya **kopyalanmaz** (kanonik-kopya kusuru bu projede beş kez ısırdı). |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · **.NET 10.0.302** (K111; 9.0.316 de kurulu) · **Windows masaüstü ☠** · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

🔒 **K89–K100 KAPANDI (oturum 42–44):** `KAPILAR.md` · `A8` v2 · `A9` v3 · `A9b` v2 · **A9 KABUL**; arşivde.

🟢 **`GOREV-A10` KABUL (K106) · `.gitignore` tuzağı KAPANDI (K107) · `GOREV-A9c` KİLİTLİ (K109,
iş Claude Code'a hazır, araç onarımı ⇒ `R8`'i düşürmez).** Gerekçeler ve `D5` kör kapı **arşivde**.

🟢 **①–④ KAPANDI, ANLATIMLARI ARŞİVDE (K73):** `.NET 10` geçişi (**K111**, ATOMİK) · **A10** (**K106**) ·
cihaz→sunucu senkron (**K112/K113**, **2,1 s**) · çevrimdışı ayağı (**K115**) ve onun doğurduğu **K116**
dört kilidi. Kanıtlar: `KANIT/net10-adim6/` · `KANIT/ucuncu-cihaz-senkron/` · `KANIT/cevrimdisi-senkron/`.
Paket borçları `BORCLAR.md`'de.

🟢 **⑤ `A11` (K121) · ⑥ `A12` (K124) · ⑦ `A13` (K129/K130) · ⑧ `SS2` (K136) KABUL EDİLDİ** —
dördünü de Onur kilitledi, her kriter **Cowork'ün KENDİ koşumuyla** ölçüldü (K26). Hükümler
`KANIT/{A11/07,A12/04,A13/10,SS2/04}-*KABUL*`; anlatımlar **arşivde (K73)**, kapanmamış sınırlar
**`BORCLAR.md`'de**. 🔴 `A12` araç işiydi ⇒ `R8`'i düşürmedi. 🔴 Kota `[ÖLÇÜLMEDİ]`.
🔴 **ÖLÇÜLMEYEN (değişmedi): fiziksel cihazda NAT** — SignalR yeniden bağlanma yolu bu depoda
**hiç egzersiz edilmedi** (`SS2`'de telefon **USB tüneliyle** bağlandı ⇒ borç KAPANMADI).
🟢 **⑨ `W1` (`K137`/`K138`) · ⑩ `W2` (`K142`/**`K144`**) KABUL EDİLDİ** — Onur kilitledi
(5 Ağu 2026, oturum 60); hükümler `KANIT/{W1/01,W2/05}-COWORK-KABUL-HUKMU.md`. `W2`: 12 kriterin
**11'i TAM** · `flutter test` **539/539** · `urun_kodu_satiri = 249` (tamamı **ELLE**) ⇒ `K53/4`
**ÖDENDİ**, `R8` **SÖNDÜ** (sayı daima `--olc-urun-kodu` ile git'ten türetilir — K55).
🔴 Kriter 4 **13/17 tam + 4/17 AŞIRI-YAKALAMA** ile kapandı (**kör kapı DEĞİL**; kusur spec'in
`hedef` sütununda); düzeltme **`K145` ERRATUM**'dur — **hafızada** yaşar, **kilitli spec'e
dokunulmadı** ⇒ spec ↔ hafıza sapması **beyanlıdır**.
🔴 Kapanmayan sınırlar: `BORCLAR.md` `B-W1-1`…`B-W1-7` + `KANIT/W2/05-…` §4 · **dört koşan `W1`
mutantı (`M195`–`M197`, `M199`) yeniden KOŞULMADI (`K80`)**.
→ **SIRADAKİ: backend CI** (`D-A13-4`) + release → ⑪ `ADR 0004` gövdesi (COOP/COEP) + vitrin → README.
🔴 **`verify.ps1` ↔ çalışan `Momentum.Api` ÇAKIŞMASI: kanonik metin `ORTAM.md`'de** (oturum 50'de
ölçüldü). Buraya **kopyalanmaz** — üç satırlık özet oturum 53'te `kanonik-kopya` olarak budandı.

🔒 **MSSQL göçü PARK EDİLDİ (Onur, 1 Ağu 2026).** Reddedilmedi; **iki koşul birlikte** sağlanınca açılır:
① cihaz senkron kanıtı kapandı ② hedef şirket yığını MSSQL. Ölçülen maliyet, `Rule3` ve en riskli parça
(`FOR UPDATE SKIP LOCKED` → `UPDLOCK/READPAST`) **arşivde**.
🔴 **README YOK** — klonlayana tek satır talimat yok (borç `BORCLAR.md`'de). 🔴 Depo görünürlüğü
**yazılmaz, ÖLÇÜLÜR**: *"public"* iddiası oturum 47'de çürüdü, oturum 53'te yine **PRIVATE** ölçüldü.

---

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- 🔒 **K71–K81 · K116–K120 — slice-3e · `R9`/`R10` · `A11` KABUL EDİLDİ; anlatım oturum 56'da arşive taşındı (`K135-EK2`).** Kurallar prozada değil **kapıda** koşuyor (K73). 🔴 **BAŞKA HİÇBİR CANLI BELGEDE İZİ OLMAYAN ALTI BEYAN BURADA KALIR** (ölçüldü: `KANIT/o56/25-beyan-izi.txt`): ① `CursorHint` **yoksayılır** (`D6`) ② `Y3`'ün mutantı **YOK** ③ `G12` kriter 8 **UYGULANMAZ** ④ `D2` kural 3'ün `K != 'yerel'` istisnası ⑤ `R9` öncesi inmiş satırlar **`'yerel'` KALIR** (migration yasak) ⑥ `GOREV-slice-3d-cekme.md`'deki `D0` metni **bilerek bayat** (K70; kanonik metin `GOREV-A11` §3). 🟢 Kalan **yedi** beyan `BORCLAR.md`'de yaşıyor; buraya **kopyalanmaz** (`kanonik-kopya`).
- 🔒 **K111 — .NET 10 (Onur kilitledi, 2 Ağu 2026):** çatı `net10.0`, SDK pini `10.0.302`; kural **`verify.ps1`'de ve `global.json` pininde** koşuyor. Geçiş **ATOMİK** (ara durum ölçülerek kırık bulundu). `LangVersion=latest` riski + geçici CVE pini `BORCLAR.md`'de. Gerekçe: hafıza K111.
- 🔒 **K108 — KAPI KİMLİĞİ SPEC-YERELDİR** (Onur kilitledi, 2 Ağu 2026): atıf **daima** kapsam önekli (`A10/G18`). Ölçülmüş gerekçe: `A9b/G17` ≠ `A10/G17`, `A10/G18` ≠ `A9c/G18` — aynı ad, farklı kapı, ikisi de kabul edilmiş işin içinde. Kapısı **var**: `kapi-ad-teklik-kapisi.py`, açılışta **§2 adım 4b**.
- **K73** — **Bir dilimin kilitleri, dilim KABUL EDİLDİĞİNDE §5'ten çekilir** ve tek satırlık atıfla temsil edilir; kural o andan sonra **prozada değil KAPIDA** yaşar. Arşivde hiçbir şey silinmez. 🔴 Kapısı **olmayan** kilit çekilemez — `K72` bu yüzden §5'te DURUYOR.
- **slice-3b · 3c · 3d kilitleri (K57–K70)** — hepsi **KABUL EDİLDİ** ⇒ §5'ten **ÇEKİLDİ**; kurallar kapılarda ve **40 mutantta** koşuyor, sapma her açılışta `tek-kopya-kapisi.py` ile ölçülür. 🔴 `P6`/`D4` **K72** ile daraltıldı, düzeltmesi **K74** (kapısı `G10`). Gerekçeler: hafıza K57–K74.
- **K61** — **Dev-kimlik kalkanı KİLİTLİ:** yalnız `Development`'ta `DevCurrentUser` (**`X-Momentum-Dev-User`** → `UserId`; başlık yok/bozuk ⇒ **401**, sessiz varsayılan YOK); üretimde `NullCurrentUser` korunur ve bunu bir **MUTANT** kanıtlar. `UserId` ⟂ `ClientId`. Beyan edilen sınır: kimlik **çözümü değil**, ölçüm **iskelesi**.
- **K53** — Verimlilik reformu: kâğıt denetim turu tavanı **1** · radar KIRMIZI'da varsayılan **DEVRET** · koşan-uygulama-mutant tavanı **3** · iki oturum 0 ürün kodu = **sert durak (`R8` — K57'de `R7`'den yeniden adlandırıldı)** · hafıza bölündü.
- **K60** — **Tek kopya dosyaya yazan her betik ATOMİK yazar:** önce `encode("utf-8")`, sonra `.tmp`, en son takas. Gerekçe: oturum 31'de `io.open(yol,"w")` 542 KB arşivi **0 bayta** düşürdü. ✅ Kapısı var: `tek-kopya-kapisi.py`. **Beyan edilen sınır:** kapı hasarı **önlemez**, sessiz kalmasını imkânsız kılar. 🔴 Bu makinede `os.replace` `WinError 5` veriyor ⇒ takas **üç adımlı yedekli** (`ORTAM.md`).
- **K57‑b** — `araclar/radar.py` **plugin 0.2.0 ile BAYT-ÖZDEŞ** (`46E3A8BC`); proje-yerel not **eklenmez** ⇒ sapma **tek sha ile** ölçülür.
- **K58** — `DURUM.md` tavanı **32 KB**; kapısı `belge-tavan-kapisi.py`, §2 adım 3'te koşar. 🔴 Aracın **banner sürümü bayat** (`1.0.0`), borç `B-O50-2`. 🔴 **Yeni checkpoint `<!-- DIZIN:SON -->` ALTINA** eklenir (`hafiza-dizin.py`). Gerekçe (R4 freni + dikkat): hafıza K58.
- 🔒 **K117 · K126 — `BORCLAR.md` TAVANI 32 KB (Onur; 2 ve 3 Ağu 2026):** ölçülmüş gerekçe tek cümledir — **bu dosyada budama ancak bir borç KAPANDIĞINDA işe yarar**. 🔴 **Beyan edilmiş bedel: tavan artık `DURUM.md` ile EŞİT;** *"borç listesi canlı durumun yarısı kadar kalmalı"* tasarımı **ÖLDÜ**. K40 şartı **vaka 13** ile ödendi. Gerekçe: hafıza K117/K126.
- 🟢 **K21'in mekanik kapısı ARTIK VAR:** `araclar/oturum-sagligi.py` **1.0.0**, altın küme **26/26**; `S4` her açılışta ÖLÇÜLÜR (§2 adım 8), buraya **yazılmaz**. *(Bu satırın "araç YOK" ölü beyanı K101'de budandı — arşivde.)* Kalan borç (*"alıntı ≠ beyan"* yanlış-pozitifi, K97/§2b): `BORCLAR.md`.
- **K55** — Başka bir el çalışırken `git add -A` **YASAK**; `urun_kodu_satiri` = *"o oturumda repoya giren ürün kodu, **hangi el olursa olsun**"*.
- **K56** — Kanonik kök **saf ASCII** (`C:\dev\Momentum`); `android.overridePathCheck` **eklenmez**, junction **kullanılmaz**.
- **K46** — `DESIGN.md`'ye **tek bayt yazılmaz** (BD‑1…BD‑7 borçları açık).
- **K42-d** — Taç mücevher dört adımı **TAMAMLANDI**: Docker+verify → Drift/çevrimdışı CRUD → senkron kuyruğu → SignalR.
- **K41** — ADR 0003 v7 **DONDURULDU**; açılması üç şartın BİRLİKTE sağlanmasına + Onur'un açık onayına bağlı.
- 🔒 **K127 — KİLİT ÖNCESİ BAĞIMSIZ DENETİM (Onur kilitledi, 3 Ağu 2026):** kilit checkpoint'i **denetçinin ÇIKTI YOLUNU** taşır; yoksa *"denetim KOŞULMADI"* diye **açıkça** yazar. Kanonik metin **`CLAUDE.md`**'de, buraya kopyalanmaz. **K53/1 ile çelişmez** — turun *sayısını* değil **zamanlamasını** sabitler. 🟢 `K133`'te *"yoksa açıkça yazar"* şıkkı **ilk kez** kullanıldı. 🔴 **Mekanik kapısı YOK** ⇒ borç `B-O52-2`. Gerekçe: hafıza K127.
- 🔒 **K129 · K130 — `A13` KABUL + spec yeniden kilitlendi (Onur, 3 Ağu 2026, oturum 53).** Kurallar `A13/G27`–`G30` kapılarında + `M162`–`M170` mutantlarında koşuyor. 🔴 **Yaşayan beş sınır (hepsi borç, `B-O53-1`…`5`):** `G29/b` **kör** · `--fatal-infos` **taşıyıcı değil** · `G27/a`·`G27/c`·`G30/b` **mutantsız** · kriter 7'nin **dinamik ayaklarının aracı yok** · aksiyonlar **pinsiz**. Ders: **okunan onarım, ölçülmüş onarım değildir.** Gerekçe: hafıza K129/K130.
- 🔒 **K133 · K136 — `SS2` KİLİTLENDİ ve KABUL EDİLDİ** (Onur; 3 ve 4 Ağu 2026). K73 gereği kilit §5'ten **ÇEKİLDİ**; kurallar bugün `SS2/G31`–`G34` kapılarında ve `M171`–`M188` mutantlarında **koşuyor**. 🔴 **Yaşayan üç sınır:** ① `spec-kapi-kapsama.py` *"mutant ISIRIR mı"* **sormaz** (`B-SS2-4`) ② üründe **başlık düzenleme UI'ı YOK** ⇒ kriter 8 **tamamlanma anahtarıyla** koşuldu ③ `M172`'nin *beklenen* metni gerçeği tarif etmiyor (`B-SS2-5`). Gerekçeler: hafıza K133 · K135 · K136.
- 🔒 **K137/K138 · K142/K144 — `W1` ve `W2` KİLİTLENDİ *ve* KABUL EDİLDİ ⇒ K73 gereği ÇEKİLDİ.**
  Kurallar bugün prozada değil **`W1/G35`–`G38` + `W2/G39`–`G42` kapılarında** koşuyor. 🔴 **Bu satır
  oturum 60'a kadar *"`cors-kapisi.py` ve `_preflight.py` henüz YOK"* diyordu — ÖLÜ BEYAN: ölçüldü,
  İKİSİ DE VAR** (`araclar/cors-kapisi.py` **24.450 b** · `KANIT/W1/_preflight.py`). Yaşayan sınırlar
  `BORCLAR.md` (`B-W1-1`…`B-W1-7`) ve `KANIT/W2/05-COWORK-KABUL-HUKMU.md` §4'tedir.
- **K44-a** — **Önce araç, sonra belge.**
- **K34-f** — Bir aracı **onaran el**, onu **yazan elden AYRI** olmalı.
- **K26** — Üretici kendi denetçisini spawn edemez. **Üreten ≠ denetleyen.**
- **K21** — Oturum sağlığı **ölçülür**; eşikler **MUTLAK** (yüzde YOK). 🔴 **Kanonik eşikler YALNIZ `CLAUDE.md`'de — buraya KOPYALANMAZ.** Ölçülen gerekçe: yüzde kopyalanınca **payda düştü**, iki oturum 200k uydurup yanlış renk ilan etti (K21-DÜZELTME). **Yüzde yazan el paydayı uydurmuştur.**
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
| `belge-tavan-kapisi.py` (banner **1.0.0**, etiket bayat ⇒ `B-O50-2`) | canlı belge **bayt tavanı + PAY**; `T1` aşım (KIRMIZI) · `T2` dar pay (SARI, eşik %5) · `T0` dosya yok. Tavanı **kendi değiştirmez** (K40) — 🟢 **vaka 10 artık kapsam tablosundaki HER tavanı PİNLER**: K40'ın *"eşik değiştiren altın kümeye vaka ekler"* şartı **prozadan kapıya taşındı** ve K89'dan beri taşınan *"küme `VARSAYILAN_KAPSAM`'a dokunmuyor"* borcu **KAPANDI**; **vaka 13** (oturum 52) gevşetmenin *fiilen canlı* olduğunu pinler | **13/13** |
| `oturum-sagligi.py` **1.0.0** | K21'in mekanik kapısı: kanonik eşik (`S1`) · yüzde avı (`S2`) · eşik kopyası (`S3`) · token+payda (`S4`/`S5`, `--transcript` ister, yoksa **OLCULMEDI**) · kimlik tazeliği (`D1`, **yazım anıyla**). Çıkış 4 = kanonik temiz ama sağlık ölçülmedi | **26/26** |
| `kapi-ad-teklik-kapisi.py` **1.0.0** | K108: `N1` kapsam öneksiz **belirsiz** atıf (KIRMIZI) · `N2` spec içi tekrar · `N3` etiketsiz paylaşım (bilgi). Yol/dosya adı (`KANIT/…/02-G2/`) ve `(GENİŞLETME)` etiketli paylaşım **yanlış-pozitif değildir** — ikisi de ayrı vakayla kanıtlı | **18/18** |
| `ss2-kapisi.py` [`SS2/T0`] | `SS2/G31/a,b` + `G33/c` **statik** ayakları; düz metin tarar, Dart ayrıştırmaz. 🔴 `//` **ve** `/* */` yorumları atar — **blok yolu oturum 56'da ONARILDI, öncesinde KÖR KAPIYDI** (`M-o56-1` ile kanıtlı) | **14/14** |
| `cors-kapisi.py` [`W1`] | `W1/G35/a`–`d` · `G37/d` · `G38/c` **statik** ayakları; `//` **ve** `/* */` atar, işaretli blok aralığında arar, pozitif kontrol taşır. 🔴 `IsDevelopment()`'ı **HİÇ aramaz** (`B-W1-5`) ⇒ *"CORS yalnız Development"* kararı **kapısız**. 🔴 Envantere **oturum 58'de eklendi** | **18/18** |
| `ci-kapisi.py` [`A13`] | CI iş akışının statik ayakları (altın kümede ölçülen kodlar: `G28a` … `G30c`). 🔴 Envantere **oturum 56'da eklendi** — oturum 53'ten beri tabloda yoktu | **13/13** |
| `dosya-kimlik.py` | bayt + sha256 + U+FFFD + CRLF | — |
| `mcp-arac-probe.py` | MCP'nin **gerçek** araç listesi (`tools/list`) | — |
| `pub-surum-olc.py` | pub.dev `/api` sürüm + advisory | — |
| `lisans-yokla.py` | lisansın hangi uçta olduğunu ölçer | — |
| `yoklama-yasagi-kapisi.py` | slice-3e `G12/T5`: **yoklama yasağı** (K68) + sinyal protokolü statik kapısı `Y1`–`Y4`; `Y3`'ün mutantı **yok** (beyan edilmiş borç). 🟢 **`A11`/`D-A11-3` ile genişledi (oturum 49):** gövde kuralı **kapsayan fonksiyona** taşındı, `Future.delayed` de taranıyor ⇒ `while{}`/`.then()` kaçakları kapandı | **26/26** |
| `web-varlik-indir.py` | Drift web ikililerini indirir, sha256'yı `web-varlik.sha256` **pinine** karşı ölçer (TOFU; sürüm karşılaştırması YAPMAZ) | **4/4** |
| `adr-kapi-taramasi.py` | ADR 0003 kapısı (**dondurulmuş**, dokunma) | — |
| `verify.ps1` | backend build+test+CVE zinciri | — |

🔴 **ENVANTER OTURUM 58'DE YENİDEN SAYILDI (ölçüldü, beyan değil): `araclar\` altında **30** dosya; **24** çalıştırılabilir (23 `.py` + `verify.ps1`), tablo **24** satır; kalan 6 veri/yardımcı (3 `.json` · `.md` · `.sha256` · `.gitkeep`) + 2 dizin (`__pycache__`, `fixture`).** Oturum 56'nın *"29 / 23"* sayımı **tek oturumda bayatladı**: `cors-kapisi.py` (oturum 57) tabloya **hiç girmemişti** ⇒ **`envantersiz-kapı` sınıfı ÜÇÜNCÜ kez ısırdı** (`ci-kapisi.py` o53 · `ss2-kapisi.py` o55 · `cors-kapisi.py` o57). *Envanterde olmayan kapı tetiklenemez*; `KAPILAR.md` bunu **beyan eder, zorlamaz** — sınıfın **hâlâ mekanik kapısı yok**.

---

## 7. KANLA YAZILI ORTAM UYARILARI → **`ORTAM.md`**

🔴 **İÇERİK 2 Ağu 2026'da (oturum 49, Onur kilitledi) `ORTAM.md`'ye TAŞINDI; numara ve başlık BİLEREK
burada kaldı** — `DURUM.md §7`'ye adıyla atıf yapan **6 canlı satır** ölçüldü, bölümü silmek **sarkan
atıf** sınıfını doğururdu (`kanonik-kopya`nın kardeşi, bu projede altı kez ısırdı).

🔴 **`ORTAM.md` AÇILIŞTA OKUNUR** (§2 adım 1) — *okunmaz* sınıfına **KONULMADI**: tavanın gerekçesi
*"okuma kapasitesi DEĞİL, R4 freni + dikkat"*tir; ayrı dosya + ayrı tavan R4'ü zaten çözer, listeyi
gözden kaldırmak ödenmemiş bir bedeldir. Kendi tavanını taşır, `belge-tavan-kapisi.py` kapsamındadır.

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
| `DESIGN.md` **v2** | **18.587** | **`8B8AA35D`** | 🔴 **K142 (Onur, 5 Ağu 2026, oturum 59)** — `3780ACA4` **GEÇERSİZDİR**. Üç satır eklendi: §3.1 `DepolamaSeridi` · §4 depolama geri-düşüşü satırı · §6 `Icons.storage` anlam pini (W2 T7). Açılma kapsamı Onur'un dördüncü kilididir; başka değişiklik yine Onur'un kilidini ister |
| `GOREV-slice-3b-istemci-iskeleti.md` | **44.560** | **`F0C3A75A`** | 🔒 **K59 kilidi (v6)** — değişen her bayt kilidi bozar. `6056A5BB` · `79A53AA3` · `BE4581BA` · `1AB02B73` **geçersizdir** |
| `GOREV-slice-3c-senkron.md` | **41.692** | **`537D0579`** | 🔒 **K64 kilidi (v2, Onur onayladı 27 Tem 2026)** — `5899A220` (v1) **GEÇERSİZDİR**. `tek-kopya-kapisi.py` kapsamında **`kilitli`** sınıfındadır ⇒ sapma **her açılışta ölçülür** |
| `GOREV-slice-3d-cekme.md` | **80.399** | **`889A383F`** | 🔒 **K70 kilidi** (Onur onayladı 28 Tem 2026) — build'i sürdü, iki bağımsız denetimden geçti, `tek-kopya-kapisi.py` kapsamında **`kilitli`** ⇒ sapma **her açılışta** ölçülür |
| `araclar/radar.py` | 28.878 | `46E3A8BC` | **K57‑b** — plugin 0.2.0 ile bayt-özdeş; sapma tek sha ile ölçülür |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` | **K34-f** tutuyor; ADR donduruldu |
| `araclar/tek-kopya-kapisi.py` | **17.352** | **`9D7D0781`** | K70'te kapsam genişledi. 🔴 **Oturum 49'da `ORTAM.md` kapsama eklendi** (`66AC9CA3` / 17.259 b **GEÇERSİZDİR**); aynı disiplin koştu: altın küme **19/19**, ardından `araclar/tek-kopya-mutant.py` **11/11**; ve kapı commit'ten önce `ORTAM.md` için `S5` vererek kapsam eklemesinin **canlı olduğunu kendisi kanıtladı** |

| `GOREV-slice-3e-G12.md` | **12.623** | **`BDB3630E`** | 🔒 **K79 kilidi**. 🔴 Beyanlı-kilit sepetinde — gerekçe ve sepetin tamamı `BORCLAR.md`'de (tek kopya) |
| `GOREV-A10-cihaz-on-kosullari.md` | **26.126** | **`8AD6CA10`** | 🔒 **K105 kilidi (v2, Onur onayladı 1 Ağu 2026)** — `04E49CC9` (v1) ve `A947CC1E` (kilit satırı ÖNCESİ v2) **GEÇERSİZDİR**. 🔴 Beyanlı-kilit sepetinde — gerekçe `BORCLAR.md`'de. Kapıları **`A10/G17`–`A10/G21`** (K108) |
| `GOREV-A9c-D5-kor-kapi-onarimi.md` | **20.600** | **`53ED7838`** | 🔒 **K109 kilidi (Onur onayladı 2 Ağu 2026)** — kilit satırı **ÖNCESİ** `D88312F6` (19.497 b) **GEÇERSİZDİR**. Kapısı **`A9c/G18`** (K108; `A10/G18` ile adı aynı, kendisi farklı). 🔴 Beyanlı-kilit sepetinde — gerekçe `BORCLAR.md`'de |
| `GOREV-A13-ios-iskeleti-ci.md` | **36.155** | **`9C7213F2`** | 🔒 **K130 kilidi (Onur kilitledi 3 Ağu 2026, oturum 53 — KABUL sonrası)** — `BCD0AA81` (K127) · `56871800` (K126) · `D2DA483E` · `3E543DBE` **hepsi GEÇERSİZDİR**. Kilit **kabul öncesi bağımsız denetim** (K127) spec'te ölçümle yanlışlanmış iki gerekçe bulunca açıldı; `D-A13-3` + §9/9 düzeltildi, §9'a 11 yeni beyan eklendi. Kapıları **`A13/G27`–`A13/G30`** (K108). U+FFFD 0 · CRLF 0. 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** (sepet `BORCLAR.md`'de) |

| `GOREV-SS2-cakisma-cozumu.md` | **46.003** | **`420E9F91`** | 🔒 **K133 kilidi (Onur kilitledi 3 Ağu 2026, oturum 55)** — `66CC4AAE` (v2) ve `90314998` (v1) **GEÇERSİZDİR**. U+FFFD 0 · CRLF 0. Kapıları **`SS2/G31`–`SS2/G34`** (K108). 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** (sepet `BORCLAR.md`'de) |
| `GOREV-W1-web-yuruyen-iskelet.md` | **33.077** | **`5CF3F921`** | 🔒 **K137 kilidi (Onur kilitledi 4 Ağu 2026, oturum 57)** — kilit satırı **ÖNCESİ** `606F04F5` (32.801 b) ve **v1** `DFA8FF77` (19.941 b) **GEÇERSİZDİR**. U+FFFD 0 · CRLF 0. Kapıları **`W1/G35`–`W1/G38`**, mutantları `M189`–`M199` (K108). 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** |
| `GOREV-W2-depolama-gorunurlugu.md` **v3** | **19.511** | **`CA2D7BF2`** | 🔒 **K142 kilidi (Onur kilitledi 5 Ağu 2026, oturum 59)** — **v1** `C9BC8453` (11.770 b) ve **v2** `94124CE5` (18.156 b) **GEÇERSİZDİR**. U+FFFD 0 · CRLF 0. Kapıları **`W2/G39`–`W2/G42`**, mutantları `M200`–`M216` + `MW20` negatif kontrolü (K108). `K127` **iki tur** ödendi: `KANIT/W2/00-DENETIM-o59.md` (`B950236F`) + `KANIT/W2/01-v2-DOGRULAMA-o59.md` (`1143A34F`). 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** |

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** ve **DAİMA son yazımdan SONRA** ölçülür.

---

## 10. NEREDE NE VAR

`DURUM.md` (canlı, **açılışta okunur**) · `CLAUDE.md` (kalıcı kurallar, **açılışta okunur**) · `ORTAM.md` (**kanla yazılı ortam uyarıları — açılışta OKUNUR**, oturum 49) · `BORCLAR.md` (**açık borçlar — açılışta OKUNMAZ**, K83) · `PROJE_HAFIZA.md` (**append-only arşiv**, K1…K83) · `DESIGN.md` · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` · `araclar/` · `KANIT/` · `src/`.
