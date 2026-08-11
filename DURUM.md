# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Tavan: **≤ 32 KB** [K58; eski tavan 12 KB]. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır. Gerekçe okuma kapasitesi değil **R4 freni + dikkat**; tavanı artık `belge-tavan-kapisi.py` zorluyor (§2 adım 3) — beyan edilmiş zayıf kontrol **KAPANDI**. 🔴 Aracın **banner sürümü bayat** — borç `B-O50-2` (ayrıntı orada).
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 10 Ağu 2026, **oturum 69** — 🟢 açılış protokolü **tam koştu** (kapılar: tek-kopya YEŞİL · belge-tavan **SARI/T2** · sayı-tazeliği TEMİZ · kapı-ad-teklik YEŞİL · radar KIRMIZI-yapısal, **`R8` susuyor**); oturum sağlığı **161.341 token** (bulut, transcript'le). `K175` sırasında sıradaki: **backend CI**. *(o39–o68 arşivde.)*

---

## 1. Proje

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) + **N-katmanlı .NET 9 / ASP.NET Core** backend + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak **mimari ve kod kalitesi**. Vitrin: **çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği**.

**Kanonik kök: `C:\dev\Momentum`** 🔴 **[K56 — TAŞINDI]** · gerekçe ve kısıt **§7'de** (üçüncü kopya oturum 47'de budandı, `kanonik-kopya`); hiçbir kapı susturulmadı.

---

## 2. AÇILIŞ PROTOKOLÜ (sırayla, atlanmaz)

1. **Bu dosyayı** + `CLAUDE.md` + **`ORTAM.md`**'yi **TAM** oku. *(`PROJE_HAFIZA.md`, `BORCLAR.md` ve `KIMLIKLER.md` AÇILMAZ.)* 🔴 **ÜÇÜNÜ DE** — `ORTAM.md` oturum 49'da §7'den ayrıldı ve *okunmaz* sınıfına **KONULMADI** (Onur kilitledi): mayın listesi başvuru değil **operasyoneldir**. 🔴 **SAHTE YEŞİL YASAĞI:** oturum 38'de `CLAUDE.md` okunmadan "okundu" işaretlendi: **sahte yeşil**.
2. `python araclar\tek-kopya-kapisi.py .` — regresyon kapısı (K60). KIRMIZI ise **önce dosyayı kurtar** (`git restore <yol>`), sonra iş yap.
3. `python araclar\belge-tavan-kapisi.py .` — canlı belge tavanı (K73). `T1` KIRMIZI ise checkpoint yazmadan **ÖNCE** budanır.
4. `python araclar\sayi-tazeligi.py .` 🔴 **[o39'da EKLENDİ — ölçülmüş gerekçe]** Protokolde **YOKTU** ve elle koşulduğunda **KIRMIZI** verdi. **Çağrılmayan kapı, kör kapı kadar kördür.**
4b. `python araclar\kapi-ad-teklik-kapisi.py .` 🔴 **[K108 — oturum 47'de EKLENDİ]** Kapı kimliği **spec-yereldir**; birden fazla spec'te ilan edilmiş bir kimliğe **kapsam öneksiz** atıf KIRMIZI'dır (`A10/G18` yaz, çıplak kimlik yazma — kapı bu satırı da denetler ve ilk yazımda **beni ısırdı**).
5. `python araclar\oturum-sagligi.py --altin-kume` (**30/30**, EXIT 0) → `python araclar\oturum-sagligi.py .`
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
| **İstemci (Flutter)** | 🟢 **slice-3b→3e + R9/R10 + A7/A8/A9 BİTTİ — senkron ÇİFT YÖNLÜ + gerçek zamanlı sinyal.** Drift çevrimdışı CRUD · itme kuyruğu · çekme · rozet **kuyruktan türetiliyor** · SignalR-JSON sinyali (web'de `kIsWeb` ile KAPALI). 🟢 **`ios/` VAR ve CI'da DERLENİYOR** (`A13`, K129). Mutantlar `M1`–`M170`; sayı ve ısırma **kabul hükümlerinde**. Son koşum (K26): `flutter test` **549/549** · `analyze --fatal-infos` **0** — 🔴 **bulut/Linux** koşumu (o68, `K174`); **Windows ÖLÇÜLEMEDİ**. 🔴 A‑7 `DESIGN.md`'de kapanmadı (K46). Anlatım **arşivde** (K73). |
| **Tasarım sistemi** | ✅ `DESIGN.md` **v2** — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7. Kimlik **§9'da** (v1 `534DFF68` **GEÇERSİZ**) |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `radar.py` **plugin 0.2.0 ile bayt-özdeş** · altın küme **18/18**. Hüküm **KIRMIZI**, **yapısaldır** (`BORCLAR.md`). 🔴 **KIRMIZI ARTEFAKTLARIN ADI VE SAYISI BURAYA YAZILMAZ — §2 adım 6'da ÖLÇÜLÜR**. 🔒 **K83 — Onur DURDUR'u kilitledi:** park yürürlükte, dört-şık ritüeli **tekrarlanmaz**. 🔴 **`R8` DURUMU DA YAZILMAZ, ÖLÇÜLÜR:** sayı daima `--olc-urun-kodu <sha>` ile **git'ten** türetilir (K55). |
| **Git** | **PUSH DAİMA ONUR'DA.** İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR** — komut ve **`fetch` şartı yalnız §2 adım 7'de**; buraya **kopyalanmaz** (kanonik-kopya kusuru bu projede beş kez ısırdı). |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · **.NET 10.0.302** (K111; 9.0.316 de kurulu) · **Windows masaüstü ☠** · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

🟢 **KAPANDI, ANLATIMLARI ARŞİVDE (K73):** K89–K100 · `A10` · `GOREV-A9c` · ①–④ (`K111` · `K112`/`K113` · `K115`/`K116`); kanıtlar `KANIT/`'ta, paket borçları `BORCLAR.md`'de.

🟢 **⑤–⑩ KABUL EDİLDİ, ANLATIMLARI ARŞİVDE (K73):** `A11` (K121) · `A12` (K124) · `A13` (K129/K130) ·
`SS2` (K136) · `W1` (K137/K138) · `W2` (K142/**K144**) — hepsini Onur kilitledi, her kriter **Cowork'ün
KENDİ koşumuyla** (K26). Hükümler `KANIT/{A11/07,A12/04,A13/10,SS2/04,W1/01,W2/05}-*KABUL*`; `W2`'nin
kriter-4 sapması **hafızada** (`K145` ERRATUM), sapma **beyanlı**.
🔴 **Kapanmayan sınırlar:** `B-W1-1`…`B-W1-7` + `KANIT/W2/05-…` §4 · dört `W1` mutantı (`M195`–`M197`,
`M199`) **yeniden KOŞULMADI** · **cihazda NAT** ⇒ SignalR yeniden bağlanma **hiç egzersiz edilmedi**.
🔴 **`verify.ps1` ↔ çalışan `Momentum.Api` çakışması: kanonik metin `ORTAM.md`'de.**

🟢 **⑫ `W3b` KABUL EDİLDİ (`K167`/`K168`, o66)** — kurallar `W3b/G48`–`G51` + 20 mutantta
koşuyor; hüküm `KANIT/W3b/06-KABUL-HUKMU-COWORK.md`, anlatım **hafızada**. Sınırlar `B-W3b-6`…`10`.
🔴 **`W3` (ana spec) AÇILMADI;** `W3/G43`–`G47` implementasyonu **yok** · `B-O63-1`…`B-O63-5` **AÇIK**.

🔒 **MSSQL göçü PARK EDİLDİ (Onur, 1 Ağu 2026):** ① cihaz senkron kanıtı ② hedef yığın MSSQL —
**birlikte** sağlanınca açılır. Maliyet ve `Rule3` **arşivde**.
🟢 **README VAR (o63, `K162`)** — mimari · **ölçülmüş** çalıştırma sırası · **iki zorunlu şart** · ölçüm disiplini · beyan edilmiş sınırlar. 🔴 Depo görünürlüğü
**yazılmaz, ÖLÇÜLÜR**: *"public"* iddiası oturum 47'de çürüdü, oturum 53'te yine **PRIVATE** ölçüldü.

🟢 **o64–o66 anlatımı HAFIZADA;** budanan metinler `_SILINECEKLER/o64|o65|o66/`'da.
🔒 **`ADR 0004` KAPSAM DIŞI (`K175`①, o68):** gövde · `adr-hukum-kapisi.py` onarımı · kapı zinciri **PARK**.
o66'nın `K170` kilidi ve o68'in ADR 0004 onarım kilitleri **HÜKÜMSÜZ**; üç düşüşün (`K164`·`K165`·`K169`)
anlatımı ve `K170`'in üç ayağı **hafızada** (o69'da budandı ⇒ `_SILINECEKLER/o69/`).

🟢 **BACKEND CI KABUL EDİLDİ (`K178`) — `D-A13-4` KAPANDI.** On kriterin **onu da** geçti;
kriter 9 `ci #25` (`e80cb19`, `main`) **Success**, dört çapa logda **birebir**, **120/120** test
(`Persistence.Tests` 56/56 gerçek Postgres). Hükümler `KANIT/CI/10` + `KANIT/CI/11`.
🔴 `B-O63-2` **AÇIK**.

🟢 **`SS2` kriter 8'in UI'ı KABUL EDİLDİ (`K174`, o68):** `2710db0` · `lib/` **+216** · `KANIT/SS2/05-…`
(7/7 · **5/5 mutant** · `M7` ölmedi). 🔴 **KRİTER 8 AÇIK** — uçtan uca cihaz koşumu (`D-SS2-11`).
o70: iş emri **iki kâğıt turunda DÜŞTÜ** ⇒ `K53`/1 **tur 3 açılmadı**, iş **Code'a devredildi**; `K181`
*“backend logundan oku”* kilidini **ölçümle düşürdü** ⇒ **sunucunun PostgreSQL'i**. `KANIT/SS2/06`–`10`.

---

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- 🔒 **K175 — KAPSAM KESİMİ (Onur, 10 Ağu 2026, o68).** ① **`ADR 0004` KAPSAM DIŞI** — gövde, `adr-hukum-kapisi.py` onarımı ve kapı zinciri **PARK**; gerekçe `README`'ye tek paragraf. ② **YENİ ARTEFAKT YASAĞI** — `GOREV_CLAUDE_CODE`/`docs/ADR`/`araclar` altında yeni dosya **AÇILMAZ**; taban **32·6·41** 🔴 **[o69'da DÜZELTİLDİ]** — o68 **33** yazmıştı, `ls-files` bugün **32** ölçüyor; fark, `ADR 0004` parkıyla **öksüz kalan izlenmeyen** onarım indeksiydi (Onur `_SILINECEKLER/o69/`'a aldırdı). 🔴 **Sayım `ls-files --cached --others --exclude-standard` ile yapılır** — çıplak `ls-files` izlenmeyeni **GÖREMEZ** ve yasağın koruduğu sınıfa **KÖRDÜR** (o69'da bağımsız denetçi ölçtü). Büyürse **DUR**. ③ **MUHASEBE OTURUM BAŞINA TEK YAZIM**; 90 açık borç **kapatılmaz, TESLİMDE BEYAN EDİLİR**. 🔴 o68'in `ADR 0004` onarım kilitleri ve `K170` **HÜKÜMSÜZ**. Sıra: depo görünürlüğü → `SS2` kriter 8 → backend CI → `README`. Ölçülmüş gerekçe (kâğıt %79,5 ↔ ürün %9,5; ADR 5,21 ↔ ürün 0,19 bloker/tur): **hafıza + Cowork projesi o68**.
- 🟢 **K174 — `SS2` kriter 8'in UI'ı KABUL EDİLDİ (o68) ⇒ `K73` gereği ÇEKİLDİ** (`2710db0` · `KANIT/SS2/05-…`). 🔴 **o70'e kadar bitmiş işi BEKLEYEN KİLİT gibi sunuyordu — ölü beyan.** Kriter 8 **§4'te**.
- 🔒 **K71–K81 · K116–K120 — slice-3e · `R9`/`R10` · `A11` KABUL EDİLDİ; anlatım o56'da arşive taşındı (`K135-EK2`).** 🔴 **BAŞKA HİÇBİR CANLI BELGEDE İZİ OLMAYAN ALTI BEYAN BURADA KALIR** (`KANIT/o56/25-beyan-izi.txt`): ① `CursorHint` **yoksayılır** (`D6`) ② `Y3`'ün mutantı **YOK** ③ `G12` kriter 8 **UYGULANMAZ** ④ `D2` kural 3'ün `K != 'yerel'` istisnası ⑤ `R9` öncesi inmiş satırlar **`'yerel'` KALIR** (migration yasak) ⑥ `GOREV-slice-3d-cekme.md`'deki `D0` metni **bilerek bayat** (K70; kanonik metin `GOREV-A11` §3). 🟢 Kalan yedi beyan `BORCLAR.md`'de.
- 🔒 **K111 — .NET 10 (Onur, 2 Ağu 2026):** çatı `net10.0`, SDK pini `10.0.302`; kural **`verify.ps1` ve `global.json` pininde** koşuyor. Geçiş **ATOMİK**. Riskler `BORCLAR.md`'de.
- 🔒 **K108 — KAPI KİMLİĞİ SPEC-YERELDİR** (Onur, 2 Ağu 2026): atıf **daima** kapsam önekli (`A10/G18`). Kapısı `kapi-ad-teklik-kapisi.py` (§2 adım 4b). Gerekçe: hafıza K108.
- **K73** — **Bir dilimin kilitleri, dilim KABUL EDİLDİĞİNDE §5'ten çekilir** ve tek satırlık atıfla temsil edilir; kural o andan sonra **prozada değil KAPIDA** yaşar. Arşivde hiçbir şey silinmez. 🔴 Kapısı **olmayan** kilit çekilemez (`K72` bu yüzden durur).
- **slice-3b · 3c · 3d kilitleri (K57–K70)** — hepsi **KABUL EDİLDİ** ⇒ §5'ten **ÇEKİLDİ**; kurallar kapılarda ve **40 mutantta** koşuyor, sapma her açılışta `tek-kopya-kapisi.py` ile ölçülür. 🔴 `P6`/`D4` **K72** ile daraltıldı, düzeltmesi **K74** (kapısı `G10`). Gerekçeler: hafıza K57–K74.
- **K61** — **Dev-kimlik kalkanı KİLİTLİ:** yalnız `Development`'ta `DevCurrentUser` (**`X-Momentum-Dev-User`** → `UserId`; başlık yok/bozuk ⇒ **401**, sessiz varsayılan YOK); üretimde `NullCurrentUser` ve bunu bir **MUTANT** kanıtlar. `UserId` ⟂ `ClientId`. Sınır: kimlik **çözümü değil**, ölçüm **iskelesi**.
- **K53** — Verimlilik reformu: kâğıt denetim turu tavanı **1** · radar KIRMIZI'da varsayılan **DEVRET** · koşan-uygulama-mutant tavanı **3** · iki oturum 0 ürün kodu = **sert durak (`R8`)** · hafıza bölündü.
- **K60** — **Tek kopya dosyaya yazan her betik ATOMİK yazar** (`.tmp` → takas). Kapısı `tek-kopya-kapisi.py`. **Sınır:** kapı hasarı **önlemez**, sessiz kalmasını imkânsız kılar. 🔴 Ele göre değişen takas yordamı: **`ORTAM.md`** (Windows üç adımlı · `device_bash` tek adımlı).
- **K57‑b** — `araclar/radar.py` plugin 0.2.0 ile **BAYT-ÖZDEŞ** (`46E3A8BC`); proje-yerel not **eklenmez**.
- **K58** — `DURUM.md` tavanı **32 KB**; kapısı `belge-tavan-kapisi.py`, §2 adım 3'te koşar. 🔴 Aracın **banner sürümü bayat** (`1.0.0`) ⇒ `B-O50-2`. 🔴 **Yeni checkpoint `<!-- DIZIN:SON -->` ALTINA** (`hafiza-dizin.py`). Gerekçe (R4 freni + dikkat): hafıza K58.
- 🔒 **K117 · K126 · K152 — `BORCLAR.md` tavanının ÜÇ gevşetmesi (o49/o52/o61);** K40 şartı vaka **10 · 13 · 15** ile ödendi. 🔴 `K160` daralttı: o ölçümler **kalem** sayıyordu, budanabilir olan **anlatımdı**. Gerekçe: hafıza.
- 🟢 **K21'in mekanik kapısı ARTIK VAR:** `araclar/oturum-sagligi.py` **1.0.0**, altın küme **30/30**; `S4` her açılışta ÖLÇÜLÜR (§2 adım 8), buraya **yazılmaz**. Kalan borç (*"alıntı ≠ beyan"*): `BORCLAR.md`.
- **K55** — Başka bir el çalışırken `git add -A` **YASAK**; `urun_kodu_satiri` = *"o oturumda repoya giren ürün kodu, **hangi el olursa olsun**"*.
- **K56** — Kanonik kök **saf ASCII** (`C:\dev\Momentum`); `android.overridePathCheck` eklenmez, junction kullanılmaz.
- **K46** — `DESIGN.md`'ye **tek bayt yazılmaz** (BD‑1…BD‑7 açık).
- **K41** — ADR 0003 v7 **DONDURULDU**; açılması üç şartın BİRLİKTE sağlanmasına + Onur'un açık onayına bağlı.
- 🔒 **K127 — KİLİT ÖNCESİ BAĞIMSIZ DENETİM (Onur, 3 Ağu 2026):** kilit checkpoint'i **denetçinin ÇIKTI YOLUNU** taşır; yoksa *"denetim KOŞULMADI"* diye **açıkça** yazar. **Kanonik metin `CLAUDE.md`'de**, `K53/1` ile çelişmez (turun sayısını değil **zamanlamasını** sabitler). 🔴 Mekanik kapısı **YOK** ⇒ `B-O52-2`.
- 🔒 **K129 · K130 — `A13` KABUL + spec yeniden kilitlendi (Onur, o53).** Kurallar `A13/G27`–`G30` + `M162`–`M170`'te koşuyor. 🔴 Yaşayan beş sınır **`B-O53-1`…`5`**'te. Ders: **okunan onarım, ölçülmüş onarım değildir.**
- 🔒 **K133 · K136 — `SS2` KİLİTLENDİ ve KABUL EDİLDİ** (Onur, o55/o56); kurallar `SS2/G31`–`G34` + `M171`–`M188`'de **koşuyor**. 🔴 Yaşayan üç sınır: `B-SS2-4` · 🟢 başlık düzenleme UI'ı **o68'de GELDİ ve KABUL EDİLDİ** (`K174`) · kriter 8 **hâlâ tamamlanma anahtarıyla** koşuyor (§4) · `B-SS2-5`.
- 🔒 **K137/K138 · K142/K144 — `W1`+`W2` KİLİTLENDİ *ve* KABUL EDİLDİ ⇒ K73 gereği ÇEKİLDİ.** Kurallar prozada değil **`W1/G35`–`G38` + `W2/G39`–`G42` kapılarında** koşuyor. Yaşayan sınırlar: `BORCLAR.md` (`B-W1-1`…`B-W1-7`) + `KANIT/W2/05-…` §4. 🔴 Bu satırın o60'a kadar taşıdığı **ÖLÜ BEYAN** ve `K145` ERRATUM: **hafızada**.
- 🔒 **K170 — `ADR 0004`: MEKANİKLEŞTİR (Onur, o66) ⇒ `K175`① ile **HÜKÜMSÜZ** (o68).** Gövde üç kez düştü (`K164`·`K165`·`K169`), artefakt **PARK**. `K170`'in üç ayağı ve gerekçe: hafıza `K170` + `K175`.
- 🟢 **K167 + K168 — `W3b` KİLİTLENDİ *ve* KABUL EDİLDİ (Onur, o66) ⇒ `K73` gereği ÇEKİLDİ.** `K127` denetimi kilitten **ÖNCE** koştu; kurallar `W3b/G48`–`G51` + 20 mutantta koşuyor. Sınırlar `BORCLAR.md`. Gerekçe: hafıza `K167`/`K168`.
- 🔒 **K149 · K149-b — GITHUB KATKI GRAFİĞİ + COMMIT KİMLİĞİ (Onur, 6 Ağu 2026).** 🔴 **KANONİK METİN `CLAUDE.md`'DE — BURAYA KOPYALANMAZ.** Tek hatırlatma: 6 Ağu 2026 öncesi **tüm** commit hash'leri **ÖLÜDÜR**; ulaşılabilirlik `merge-base --is-ancestor` ile ölçülür, `cat-file` ile **ölçülmez**.
- 🔒 **K148 · K148-b (Onur, o60):** `W3` ölçümü **BUILD'in önündedir**; ölçümü Onur/Code koşar (`K80`). **Ders: yürürlükteki kilit ŞIKKIN İÇİNDE yeniden yazılır** ve **elle sayılan her sayı yanlıştır**. Gerekçe: hafıza K148.
- 🔒 **K151 — DÖRT KARAR (Onur, o61):** ① `§9` → **`KIMLIKLER.md`** ② `T0` **başlıklı yerel sunucuyla** ölçülür (bayrak yolu **ÖLÜ**) ③ `T5` → `K158` ile **ERTELENDİ** ④ `G45/d` pinli sayan-raporlayan. `K151-b`/`c`: hafıza.
- 🔒 **K153 — `spec-kapi-kapsama.py` DÖRT ALANLI §6b'yi OKUR (o61).** Altın küme **23/23**; boş `KAPATMA` ⇒ `S4`. Gerekçe: hafıza K153.
- 🔒 **K154 — İSKELET ÖNCE (Onur, o62):** `R8` kırmızıyken yeni spec/ADR/araç turu **açılmaz**; önce **koşan en küçük şey** yazılır (`K53/4`+`K53/5`). 🔴 **Yazılmayan ölçüm kaydı, kapatılmayan kapıdır** — o61 deftere hiç yazmadı, `R8` kördü.
- 🔒 **K155 — KAPI AYAĞI BORÇLANAMAZ (Onur, o62):** `spec-kapi-kapsama.py`'nin *"KAPI borçlanamaz, yalnız KURAL"* kuralı (`S5`) **ayağı da kapsar**; mutantı olmayan ayak spec'ten **çıkarılır** ya da mutantı yazılır. 🔴 Aracın bu yorumu **zorlayan kodu YOK** ⇒ borç `BORCLAR.md`.
- 🔒 **K156 — K21 EŞİKLERİ KANONİKTİR (Onur, o62):** Momentum içinde **`CLAUDE.md`'deki eşikler** geçerlidir; Onur'un kişisel talimatındaki eşikler **bu depoda uygulanmaz**. Sayı buraya **kopyalanmaz** (K21'in kendi kuralı).
- 🔒 **K157 — `oturum-sagligi.py` D1 KAPSAMI BİR LİSTEDİR (o62):** altın küme **26 → 30**. **Ders: bir sınırı TAŞIYAN el, o sınırı OKUYAN aracı da taşımak zorundadır.**
- 🔒 **K158 — `T5` ERTELENDİ ve SINIR BEYAN EDİLDİ (Onur, o62).** `K151/③` **yazılmayacak**; üç ölçülmüş gerekçe **hafızada**. **BEYAN ZORUNLU** (spec + README): *"mevcut IndexedDB deposu olan tarayıcı OPFS'e geçmez; göç bilerek kapsam dışıdır."* 🟢 Bedeli: denetimin üç blokeri düştü, `W2`'nin `onResult` dikişine **dokunulmadı**. 🔴 `B-11` **ölçülmedi** — borç.
- 🔒 **K159 — İSTEMCİNİN İZOLASYONU (Onur, o63):** kök dizin **yapılandırmadan** okunur (`Istemci:KokDizin`; boşsa ara katman **hiç kurulmaz** ⇒ kill switch bedava) · **her ortamda** açık · sıra **zorunlu**: izolasyon başlıkları → statik servis → **açık `app.UseRouting()`**. 🔴 **`K159-c`:** ilk düzeltme (`ServeUnknownFileTypes`) **kâğıtta doğru, koşumda ÖLÜ** çıktı; kök neden `StaticFileMiddleware`'in `ValidateNoEndpoint`'i. **Ders `K53/5`'in kendi gerekçesidir.** Borçlar `B-O63-1`…`6`.
- 🟢 **K162 — o63 KAPANIŞI:** beyanlar spec §8'de · **README ilk kez var** · `dotnet test` **120/120** (bulutta, gerçek PostgreSQL). 🔴 **`B-O62-2` KAPANMADI** — `verify.ps1` koşulmadı. Anlatım: hafıza K162.
- 🔒 **K161 · K161-b — VAKA ÖLÇMEK SINIF KAPATMAZ / SPA'dan dışlanan yol rota ailesinin ŞABLONUNU taşır** (Onur, o63). **Kapandı:** `/v1`–`/v1.0` **404**, `/vault`/`/version` doğru şekilde SPA'ya düşüyor. 🔴 Kusuru **ÜRETEN el bulmadı** — `K26` gereği salınan **iki bağımsız denetçi** buldu. Anlatım: **hafıza K161** · kanıt `KANIT/W3/05`.
- 🔴 **`izolasyon-olc.py` `B`/`S`/`F` TASLAĞI DENETİMDE DÜŞTÜ (16 bulgu) ⇒ `araclar/`'a KONULMADI** (`B-O63-5`; `KANIT/W3/06-…o63.py`'de donmuş duruyor, onarım **AYRI ELE** — `K34-f`). Ders: **kendi kapısını kendi altın kümesiyle kanıtlayan el, hâlâ kör bir kapı teslim edebilir.** Playwright kapsam sınırı ve ayrıntı: **hafıza + `BORCLAR.md`**.
- 🔒 **K160 — `BORCLAR.md` SIKIŞTIRILDI (Onur, o63):** dosya artık **indekstir** (kimlik + tek cümle). **39.086 → 17.669 b**, hiçbir borç **kapanmadı/silinmedi**. Aynı turda bir **ölü beyan** (bayat tavan iddiası) düzeltildi. Gerekçeler: **hafıza K160**.
- **K44-a** — **Önce araç, sonra belge.**
- **K34-f** — Bir aracı **onaran el**, onu **yazan elden AYRI** olmalı.
- **K26** — Üretici kendi denetçisini spawn edemez. **Üreten ≠ denetleyen.**
- **K21** — Oturum sağlığı **ölçülür**; eşikler **MUTLAK** (yüzde YOK). 🔴 **Kanonik eşikler YALNIZ `CLAUDE.md`'de — buraya KOPYALANMAZ.** Ölçülen gerekçe: yüzde kopyalanınca **payda düştü** ve iki oturum yanlış renk ilan etti (K21-DÜZELTME). **Yüzde yazan el paydayı uydurmuştur.**
- **K40** — Radar KIRMIZI'da yeni tur YASAK; kilit **Onur'dan** gelir.
- **§4** — **Ölç ya da `[DOĞRULANMADI]` yaz.** "Beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez."

---

## 6. ARAÇLAR (`araclar\`) — hepsi önce kendini kanıtlar

| araç | ne yapar | altın küme |
|---|---|---|
| `radar.py` **0.2.0** | kısır döngü + **R8 ürün kodu durgunluğu** + **defter dürüstlüğü D1‑D5** + `--olc-urun-kodu` | **18/18** |
| `spec-kapi-kapsama.py` | spec'te **mutantsız kapı/kural** arar; borç beyanı okur (`A12`: §3 karar başlıkları da). 🟢 **o61 (`K153`):** dört alanlı §6b biçimini de okur, boş `KAPATMA` **S4**; mutantla kanıtlı. 🔴 **`K155`'i (ayak borçlanamaz) ZORLAMIYOR** ⇒ borç | **23/23** |
| `sayi-tazeligi.py` **1.2.0** | belgedeki **"altın küme N/M"** iddiasını **aracı koşarak** doğrular; muafiyet `tazelik-muafiyet.json`'da ve **gerekçesiz olamaz**. 🟢 **o61 (`K151-c`) DARALTILDI:** yol parçası ve bölüm atfı artık **iddia sayılmaz**, tablo imzası yalnız **başlık** satırından alınır; üçü de mutantla kanıtlı | **19/19** |
| `design-token-kapisi.py` **0.2.0** | `DESIGN.md` ↔ Dart token kapısı `D0`–`D6` (D1 sıkılaştırma + D5 + D6 T8'de) | **18/18** |
| `pub-cve-kapisi.py` (`slice-3b/G2`) | `pubspec.lock` ↔ `/advisories`; `withdrawn` atar, `ignored_advisories` **yutmaz** | **8/8** |
| `pub-lisans-kapisi.py` (`slice-3b/G3`) | `pubspec.lock` ↔ `/metrics` SPDX; *bilinmeyen ≠ temiz*; **metin-kanıtlı eşleşme** (`lisans-eslesme.json`, kanıtsız eşleşme KIRMIZI) | **6/6** |
| `iddia-kapisi.py` **1.3.0** [A9c] | saf çekirdek (`kanit_topla`/`denetle`); kanıt eşlemesi **yalnız HAM dosya adından** (`I2`/`I3`), dairesel-kanıt filtresi ad-içi arar, envanter reddi (`LISTE_ESIGI=8`, iki yönlü pinli, `D8` ile **gerçekten** yük taşıyor); `I1` **satır-sha keyli, dosya-kapsamlı** muafiyet alabiliyor (`iddia-muafiyet.json`) | **27/27** |
| `tek-kopya-kapisi.py` **1.1.0** | tek kopya dosyaların **HEAD'e göre regresyonunu** ölçer (`S0`–`S10`); sınıf başına farklı kural: append-only **küçülmez**, kilitli **sapmaz**, canlı **%10 budanabilir**; muafiyet gerekçesiz olamaz, **ölü muafiyeti söyler** | **19/19** |
| `tek-kopya-mutant.py` | kapının **ölçüm ayağını** gerçek depoda kanıtlar: arşivi 0 bayta düşürür, satır siler, kilitli dosyayı **aynı boyutta** değiştirir, `.tmp` bırakır, UTF-8'i bozar, dosyayı siler — hepsinde kapının **ısırdığını** ölçer. 🔴 `M2b` **ÖLÜ KURGU** (`B-O64-1`) | **10/11** |
| `hafiza-dizin.py` **1.1.0** | `PROJE_HAFIZA.md`'nin başına **türetilmiş** checkpoint dizini yazar; **fikirli** (koşum 2–3'te sha sabit) ve kendi çıktısını doğrular | **13/13** |
| `belge-tavan-kapisi.py` (banner **1.0.0**, etiket bayat ⇒ `B-O50-2`) | canlı belge **bayt tavanı + PAY**; `T1` aşım (KIRMIZI) · `T2` dar pay (SARI, eşik %5) · `T0` dosya yok. Tavanı **kendi değiştirmez** (K40) — 🟢 kapsam tablosundaki **HER tavanı PİNLER**: vaka **10 · 13 · 14 · 15** (K40'ın *'eşik değiştiren altın kümeye vaka ekler'* şartı prozadan **kapıya** taşındı). Gevşetmelerin ölçülmüş gerekçeleri **hafızada** (K117/K126/K151/K152/K160) | **15/15** |
| `oturum-sagligi.py` **1.0.0** | K21'in mekanik kapısı: kanonik eşik (`S1`) · yüzde avı (`S2`) · eşik kopyası (`S3`) · token+payda (`S4`/`S5`, `--transcript` ister, yoksa **OLCULMEDI**) · kimlik tazeliği (`D1`, **yazım anıyla**). Çıkış 4 = kanonik temiz ama sağlık ölçülmedi. 🟢 **o62 `K157`:** D1 kimlik tablosunu **`KIMLIKLER.md` + `DURUM.md`** listesinden okur (`K151`'den beri **kördü**) | **30/30** |
| `izolasyon-olc.py` **1.0.0** [`W3`] | çapraz-köken izolasyon: **H** ayağı (**yalnız stdlib**) `COOP`/`COEP` başlıklarını, **T** ayağı (playwright) **gerçek tarayıcıda** `crossOriginIsolated`'ı ölçer — bayrak yolu **ölü** olduğu için ikisi de gerekir. `credentialless` **bilerek** reddedilir; ulaşılamayan adres **ORTAM HATASI**'dır, *"izole değil"* **değil**. 🔴 Onur'un makinesinde playwright **YOK** ⇒ `T` vakaları **KAPSAM DIŞI**, `N/M`'ye **girmez**, araç bunu **beyan eder** (`B-O62-3`). Buradaki sayı **cihazda ölçülendir** | **9/9** |
| `kapi-ad-teklik-kapisi.py` **1.0.0** | K108: `N1` kapsam öneksiz **belirsiz** atıf (KIRMIZI) · `N2` spec içi tekrar · `N3` etiketsiz paylaşım (bilgi). Yol/dosya adı (`KANIT/…/02-G2/`) ve `(GENİŞLETME)` etiketli paylaşım **yanlış-pozitif değildir** — ikisi de ayrı vakayla kanıtlı | **18/18** |
| `ss2-kapisi.py` [`SS2/T0`] | `SS2/G31/a,b` + `G33/c` **statik** ayakları; düz metin tarar, Dart ayrıştırmaz. 🔴 `//` **ve** `/* */` yorumları atar — **blok yolu oturum 56'da ONARILDI, öncesinde KÖR KAPIYDI** (`M-o56-1` ile kanıtlı) | **14/14** |
| `cors-kapisi.py` [`W1`] | `W1/G35/a`–`d` · `G37/d` · `G38/c` **statik** ayakları; `//` **ve** `/* */` atar, işaretli blok aralığında arar, pozitif kontrol taşır. 🔴 `IsDevelopment()`'ı **HİÇ aramaz** (`B-W1-5`) ⇒ *"CORS yalnız Development"* kararı **kapısız**. 🔴 Envantere **oturum 58'de eklendi** | **18/18** |
| `ci-kapisi.py` [`A13`] | CI iş akışının statik ayakları (altın kümede ölçülen kodlar: `G28a` … `G30c`). 🔴 Envantere **oturum 56'da eklendi** — oturum 53'ten beri tabloda yoktu. 🟢 **o69 (`D-A13-4`):** `A13/G31/a`–`h` (backend CI işi) eklendi, `_CI_TEMIZ` fikstürü gerçek `ci.yml` yapısına (küresel `defaults:`) hizalandı. 🔴 `G31/h` (akış-stili YAML yasağı) bağımsız denetimde bulunan kör kapıyı kapattı (`KANIT/CI/09`) | **22/22** |
| `dosya-kimlik.py` | bayt + sha256 + U+FFFD + CRLF | — |
| `mcp-arac-probe.py` | MCP'nin **gerçek** araç listesi (`tools/list`) | — |
| `pub-surum-olc.py` | pub.dev `/api` sürüm + advisory | — |
| `lisans-yokla.py` | lisansın hangi uçta olduğunu ölçer | — |
| `yoklama-yasagi-kapisi.py` | slice-3e `G12/T5`: **yoklama yasağı** (K68) + sinyal protokolü statik kapısı `Y1`–`Y4`; `Y3`'ün mutantı **yok** (beyan edilmiş borç). 🟢 **`A11`/`D-A11-3` ile genişledi (oturum 49):** gövde kuralı **kapsayan fonksiyona** taşındı, `Future.delayed` de taranıyor ⇒ `while{}`/`.then()` kaçakları kapandı | **26/26** |
| `web-varlik-indir.py` | Drift web ikililerini indirir, sha256'yı `web-varlik.sha256` **pinine** karşı ölçer (TOFU; sürüm karşılaştırması YAPMAZ) | **4/4** |
| `adr-kapi-taramasi.py` | ADR 0003 kapısı (**dondurulmuş**, dokunma) | — |
| `verify.ps1` | backend build+test+CVE zinciri | — |

🔴 **ENVANTER o64'TE YENİDEN ÖLÇÜLDÜ (8 Ağu 2026): `araclar\` altında **31** dosya; **25** çalıştırılabilir (**24** `.py` + `verify.ps1`), tablo **25** satır; kalan **6** veri/yardımcı (3 `.json` · `.md` · `.sha256` · `.gitkeep`) + 2 dizin.** 🔴 Bu satır o64'e kadar o58'in *30 / 24 / 23 / 24* sayımını taşıyordu — `izolasyon-olc.py` (o62) doğdu, **dördü de bayatladı**; sınıf `bayat-iddia`, hiçbir kapı görmedi. `envantersiz-kapı` sınıfı **üç kez** ısırdı (`ci-kapisi` o53 · `ss2-kapisi` o55 · `cors-kapisi` o57); *envanterde olmayan kapı tetiklenemez* — sınıfın **hâlâ mekanik kapısı yok** (`B-O64-3`). Anlatım: hafıza.

---

## 7. KANLA YAZILI ORTAM UYARILARI → **`ORTAM.md`**

🔴 **İÇERİK `ORTAM.md`'ye TAŞINDI (o49, Onur kilitledi); numara ve başlık BİLEREK burada kaldı** —
§7'ye adıyla atıf yapan **6 canlı satır** ölçüldü; silmek **sarkan atıf** sınıfını doğururdu.

🔴 **`ORTAM.md` AÇILIŞTA OKUNUR** (§2 adım 1) — *okunmaz* sınıfına **KONULMADI**: ayrı dosya + ayrı
tavan R4'ü zaten çözer, mayın listesini gözden kaldırmak **ödenmemiş bir bedeldir**. Kendi tavanını
taşır, `belge-tavan-kapisi.py` kapsamındadır.

---

## 8. AÇIK BORÇLAR → **`BORCLAR.md`**

🔴 **Bu bölüm 30 Tem 2026'da (oturum 39, kilit K83) `BORCLAR.md`'ye TAŞINDI.** Kazanç toplam bayt değil, **her
oturumun okumak zorunda olduğu** bayttır (31.744 → 21.349). `BORCLAR.md` açılışta **okunmaz**, kendi tavanını
taşır, `belge-tavan-kapisi.py` kapsamındadır. Ölçüm ve gerekçenin tamamı **arşivde** (K83).

---

## 9. DOSYA KİMLİKLERİ → **`KIMLIKLER.md`**

🔴 **İÇERİK `KIMLIKLER.md`'ye TAŞINDI (o61, `K151`); numara ve başlık BİLEREK burada kaldı** —
§9'a adıyla atıf yapan **11 canlı satır** ölçüldü; bölümü silmek §7'de kaçınılan **sarkan atıf**
sınıfını doğururdu. Taşıma gerekçesi ve **beyan edilmiş bedeli**: hafıza `K151`.

🔴 **`KIMLIKLER.md` AÇILIŞTA OKUNMAZ** (`BORCLAR.md`/`KAPILAR.md` sınıfı — **başvuru**; `ORTAM.md`
gibi **operasyonel** değil). Kendi tavanı **16 KB**; **dört ölçümün** kapsamında:
`belge-tavan-kapisi.py` (vaka 14) · `tek-kopya-kapisi.py` (`canli`) · `sayi-tazeligi.py` ·
🟢 **o62'den beri `oturum-sagligi.py` D1 (`K157`)**.

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** ve **DAİMA son yazımdan SONRA** ölçülür — `K151-b` ile
**dördüncü** kez ısırdı.

## 10. NEREDE NE VAR

`DURUM.md` (canlı, **açılışta okunur**) · `CLAUDE.md` (kalıcı kurallar, **açılışta okunur**) · `ORTAM.md` (**mayın listesi — açılışta OKUNUR**) · `BORCLAR.md` · `KIMLIKLER.md` · `KAPILAR.md` (üçü de **açılışta OKUNMAZ**) · `PROJE_HAFIZA.md` (**append-only arşiv**) · `DESIGN.md` · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` · `araclar/` · `KANIT/` · `src/`.
