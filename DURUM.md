# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Tavan: **≤ 32 KB** [K58; eski tavan 12 KB]. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır. Gerekçe okuma kapasitesi değil **R4 freni + dikkat**; tavanı şu an **hiçbir kapı zorlamıyor** (beyan edilmiş zayıf kontrol, ilk ısırışta araç yazılır).
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 28 Tem 2026, oturum 35 (K71 — **kabul kriteri 9 GEÇTİ**; `R9` kusuru açık; §8 arşivlendi).

---

## 1. Proje

Çok platformlu görev yönetimi (to-do): **Flutter** istemci (Android + Web) + **N-katmanlı .NET 9 / ASP.NET Core** backend + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak **mimari ve kod kalitesi**. Vitrin: **çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği**.

**Kanonik kök: `C:\dev\Momentum`** 🔴 **[K56 — TAŞINDI]** · Eski kökteki Türkçe karakterler dört araç zincirini kırıyordu (§7); kök neden kaldırıldı, **junction yok, `android.overridePathCheck` EKLENMEDİ** — hiçbir kapı susturulmadı.

---

## 2. AÇILIŞ PROTOKOLÜ (sırayla, atlanmaz)

1. **Bu dosyayı** + `CLAUDE.md`'yi oku. *(`PROJE_HAFIZA.md`'yi okuma — gerekirse sonra bak.)*
2. `python araclar\tek-kopya-kapisi.py .` — **tek kopya dosya regresyon kapısı (K60).** KIRMIZI ise **önce dosyayı kurtar** (`git restore <yol>`), sonra iş yap.
3. `python araclar\radar.py --altin-kume` (EXIT 0) → `python araclar\radar.py .`
   **KIRMIZI ise yeni tur YASAK**; dört şık Onur'a sunulur, **varsayılan DEVRET**.
4. `git --no-optional-locks status --porcelain` + `Test-Path .git\index.lock`
5. §4'teki **SIRADAKİ İŞ**'ten devam et.

---

## 3. CANLI DURUM

| alan | durum |
|---|---|
| **Backend** | ✅ slice-1 → 3d. `araclar\verify.ps1` ⇒ build **0 uyarı/0 hata** · **test 120/120** (Architecture 5 · Api 15 · SyncCore 44 · Persistence 56) · CVE 0 · EXIT 0. slice-3d eki: `opId` **v7 nibble zorlaması** (`IsEnvelopeValid`) + `owner_id` **kusuru düzeltildi** (`SyncCommandHandler` outbox artık `authenticatedActorId`). |
| **Veritabanı** | ✅ Docker 29.6.1, `momentum-postgres` Up (healthy) |
| **İstemci (Flutter)** | 🟢 **slice-3b + 3c + 3d BİTTİ — senkron artık ÇİFT YÖNLÜ.** Drift çevrimdışı CRUD · push kuyruğu · **çekme:** `UzakAlanDurumu` (şema **v4**) + yerel LWW + `hasMore` boşaltma + snapshot/artımlı iki dal. Cowork'ün kendi koşumu: `analyze --fatal-infos` **0 bulgu** · `flutter test` **136/136** · dokuz kapı `G1`–`G9` YEŞİL · **kırk mutantın kırkı da ısırdı** (ham çıktı `KANIT/slice-3d/09-MUTANT/M1`–`M40`, boşluk yok). |
| **Tasarım sistemi** | ✅ `DESIGN.md` v1 (15.742 b · `534DFF68`) — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7 |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `radar.py` **plugin 0.2.0 ile bayt-özdeş** — R8 · D1‑D5 · `--olc-urun-kodu` · altın küme **18/18**. Hüküm **KIRMIZI** ve bu **beklenen**: kâğıt artefaktlar (`docs/ADR/0003` park · `GOREV-slice-3b-spec` build'e devredildi) hâlâ defterde duruyor. `slice-3b-istemci` kapanış kaydı: bloker 0 · **`urun_kodu_satiri` = 61** ⇒ **R8 SUSTU** · `gorunen_cikti_yuzde` **ilk kez 0'ın üstünde (35, TAHMİN)**. Varsayılan cevap **DEVRET** — zaten yapılan bu |
| **Git** | **PUSH DAİMA ONUR'DA.** İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR**: `git --no-optional-locks rev-list --left-right --count origin/main...HEAD` |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · .NET 9.0.316 · **Windows masaüstü ☠** · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ





✅ **slice-3c KAPANDI** (senkron kuyruğu, yalnız push) · ✅ **K68** slice-3d tasarımı kilitlendi (`P1` `UzakAlanDurumu` tablosu/şema v4 · `P2` açılış+elle+`hasMore`, yoklama YOK · `P3` F3+F2 · `P4` `IsEnvelopeValid`'de v7 nibble reddi). Gerekçeler ve **beş ölçülmüş kısıt** arşivde.

✅ **slice-3d (ÇEKME) KABUL EDİLDİ — K70, Onur onayladı [oturum 34].** Spec **KİLİTLİ**: `GOREV-slice-3d-cekme.md` **80.399 b · `889A383F`** (`tek-kopya-kapisi.py` kapsamında `kilitli` ⇒ sapma her açılışta ölçülür). **Ürün kodu 3.070 elle yazılan satır** — ölçüm `diff` **+** `status` ile yapıldı; yalnız `diff` **1.147** diyordu (K66/3 bir kez daha kanıtlandı). **COWORK'ÜN KENDİ KOŞUMU (K26), altı ölçümün altısı geçti:** `iddia-kapisi --kanit KANIT/slice-3d` **TEMİZ** · `spec-kapi-kapsama` · `sayi-tazeligi` · `verify.ps1` 120/120 · `analyze` 0 bulgu · `flutter test` 136/136 — hepsi **EXIT 0**. 🔴 **K66/2 BORCU KAPANDI:** `I2`/`I3` **ilk kez** koştu ve temiz döndü. Kapıların ölçmediğini Cowork ölçtü: 40 mutant dosyasının **hiçbiri** derleme hatası değil, hepsinde assertion izi var ⇒ **mutantlar doğru sebeple ısırdı** (K69/EK'in build'e devrettiği birinci sorunun cevabı: **EVET**).

🔴 **SIRADAKİ İŞ:** ✅ **kabul kriteri 9 GEÇTİ** (K71) · ✅ **`R9` kilidi alındı: `P6`/`D4` DARALTILDI** (K72 — INSERT-from-pull ayrılır, UPDATE-of-local **dokunulmaz**). → **① SIRADAKİ İŞ: `GOREV-R9-rozet-kapsami.md` BUILD** (Claude Code; spec **14.061 b · `B2082127`**, bağımsız denetimden geçti, `spec-kapi-kapsama` + `iddia-kapisi` **EXIT 0**). ② `araclar/oturum-sagligi.py` (K21 kapısı — K44-a) · ③ **slice-3e (SignalR)**, K42-d adım 4. 🔴 **`R10` (§8) ONUR'UN ÖNCELİK KİLİDİNİ BEKLİYOR.** **Push Onur'da.**

🟡 **Arka planda `http://localhost:5298` Development API çalışıyor olabilir** — `G8`/F3 uçtan uca koşumu için **gerekli**. 🔴 **PID YAZILMAZ, ÖLÇÜLÜR** (`netstat -ano | findstr :5298`); bu satırda üç oturum boyunca bayat bir PID durdu. Gerekmiyorsa bilinçli kapatılır.

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- **K72** — **`R9` kilidi: `P6`/`D4` DARALTILDI.** Rozet dokunulmazlığı **UPDATE-of-local**'da AYNEN durur; **INSERT-from-pull** kapsam dışıdır ⇒ çekmeyle doğan satır `'senkronize'` ile INSERT edilir. Ölçüldü: CHECK kısıtı buna **zaten izin veriyor** ⇒ **migration YOK, şema v4 KALIR**. Reddedilen *"rozeti kaldır"* şıkkı `AYAK6` olarak **mekanik şarta** çevrildi. Build spec'i: `GOREV-R9-rozet-kapsami.md` **14.061 b · `B2082127`** (bağımsız denetim: 4 bloker + 3 önemli + 5 not, kapatıldı). 🔴 Spec **`kilitli` sınıfına ALINMADI** — kilitlenen **tasarımdır**, metin değil.
- **K71** — **kabul kriteri 9 ÖLÇÜLDÜ ve GEÇTİ (3/3 ayak);** `R9` kusuru koşan uygulamadan doğdu; `DURUM.md` §8 arşivlendi ve **altı bayat iddia** ayıklandı. Kanıt: `KANIT/slice-3d/10-KABUL9/`.
- **K70** — **slice-3d (ÇEKME) KABUL EDİLDİ; spec KİLİTLİ:** `GOREV-slice-3d-cekme.md` **80.399 b · `889A383F`**, `tek-kopya-kapisi.py`'de `kilitli`. Kabul, **Cowork'ün kendi altı ölçümüne** dayanır (K26). **İki bulgu bilinçle AÇIK borç bırakıldı** (§8): `02-G2` üretici kodu · `verify.ps1`'in fail-loud ayağı. `R8` sert durağı **öldü** (3.070 satır ürün kodu).
- **K69** — **slice-3d spec'i yazıldı+denetlendi; üç karar kilitli:** `P5` `owner_id` kusuru **kapsanır** (`SyncCommandHandler.cs:184` → `authenticatedActorId`) · `P6` uzak değişiklik **rozete DOKUNMAZ** · `P7` **bekleyen yerel yazım korunur**. **K68/3'ün gerekçesi düzeltildi, kilidi AYNI.** **K69/EK — DARALT:** denetim **yalnız kâğıtta ölçülebilene** bakar; mutantların ısırması, `G8`'in gerçek kurulumu ve `P5`'in yakalayıcılığı **bilinçle build'e devredildi**. **K69/EK-2:** denetim koştu, 12 bulgu kapatıldı, üç yeni çatalı Onur kilitledi (dar döküm · itme turu da uygular · yutulan tetik bir kez yeniden koşar).
- **K68** — **slice-3d (çekme) tasarımı KİLİTLİ:** `P1` ayrı `UzakAlanDurumu` tablosu (şema v4) · `P2` açılış + elle yenile + `hasMore` boşaltma (yoklama YOK) · `P3` F3 uçtan uca **+** F2 ucuz kapı · `P4` `IsEnvelopeValid`'de op-bazlı v7 nibble reddi + mutant. **Echo ATILMAZ** (kırpılmış HLC öğrenilir) · **snapshot dalı zorunlu** (ilk senkron oraya düşer) · **ayrı çekme ucu YOK**. Tasarım turu **tekrar açılmaz**.
- **K61** — **Dev-kimlik kalkanı (şık 1) KİLİTLİ:** yalnız `Development`'ta `DevCurrentUser` (**`X-Momentum-Dev-User`** → `UserId`; başlık yok/bozuk ⇒ 401, sessiz varsayılan kullanıcı YOK); **üretimde `NullCurrentUser` korunur ve bunu bir MUTANT kanıtlar** (`Production` ⇒ 401). `UserId` ⟂ `ClientId`. ADR 0003 **donmuş kalır** (K41). Beyan edilen sınır: bu bir kimlik **çözümü değil**, ölçüm **iskelesidir**.
- **K62** — **slice-3c tasarım kilitleri (`D0`–`D9`), spec v2:** kanal eşlemesi (`tamamlandi` → `Groups["completion"]`, `isDeleted` = tam `"true"`, `status` ∈ {`done`,`open`}, grup yazımı **REPLACE**) · kuyruk gövdesi **üretim anında donar**, sıra `(wall, counter, opId)` · HLC **monoton + KALICI + TAVANLI** (`now+300000`) ve sunucu damgasıyla **birleşir** · batch **≤ 100** + **tek uçuş** · zehirli op **karantina**, `cakisma` **kilitlenir** · **`D7`** zarf (`operationId`/`clientId`/`entityId`/`actorId` boş-GUID olamaz; her yazımın **kendi HLC'si**) · **`D8`** `Gorevler`+kuyruk **tek transaction**, `gonderildi → bekliyor` **kurtarma** · **`D9`** HTTP sınıflandırma (400 ⇒ tur durur; deneme tavanı 8) · **yalnız push**, çekme **uygulanmaz**.
- **K64** — **Spec v2 KİLİTLİ: 41.692 b · `537D0579`** (Onur onayladı, 27 Tem 2026). Değişen her bayt kilidi bozar; dosya `tek-kopya-kapisi.py` kapsamında **`kilitli`** sınıfına alındı ⇒ sapma **açılış protokolü adım 2'de** ölçülür. **`5899A220` (v1) GEÇERSİZDİR.**
- **K63** — **Spec v1 (`5899A220`) GEÇERSİZ; v2 geçerlidir.** İki bağımsız denetçi v1'i kırdı: 10 bloker · 12 önemli · 8 not (30 kapatıldı, 3 sınır beyan edildi). **Kendi mutantlarımdan `M13` eşdeğerdi (iptal), `M14`'ün beklenen sonucu olgusal olarak yanlıştı** (`tasks` upsert'tir). Kural: **ısırmayan mutant kapıyı gevşetmez — önce kapı düzeltilir** (K60'ın M2b emsali).
- **K66** — **slice-3c KABUL EDİLDİ (Cowork'ün kendi koşumu, K26).** Dört bulgu kayda geçti: ① devir notundaki `00-OZET.md` kimliği **yanlış** (iki ayrı dosya karıştırıldı) · ② spec §8'in *"her mutant için kanıt"* şartı **tam karşılanmadı** (8/36 ham; kalanı transkriptten doğrulandı) · ③ **kabul kriteri 8'in ölçümü kör** — `git diff` **takipsiz dosyaları görmez**, doğru ölçüm `diff` **+** `status` · ④ K65 bir **backend kusuru değil**, spec kusuru + backend'de zorlanmamış varsayım.
- **K65** — **`opId` UUIDv7 + `counter` her damgada artar (Onur kilitledi).** Gerekçe: sunucu clamp'i iki alan-HLC'sini eşitleyince tie-break `opId` dize-ordinaline düşüyor; v4 rastgele olduğu için **yazı-tura** oluyordu (~%40‑50 kayıp). Düzeltme **yalnız istemcide**; backend'e tek satır dokunulmadı; **10/10** ardışık koşum SON.
- **K53** — Verimlilik reformu: kâğıt denetim turu tavanı **1** · radar KIRMIZI'da varsayılan **DEVRET** · koşan-uygulama-mutant tavanı **3** · iki oturum 0 ürün kodu = **sert durak (`R8` — K57'de `R7`'den yeniden adlandırıldı)** · hafıza bölündü.
- **K59** — Spec **v6, KİLİTLİ**: **44.560 b · `F0C3A75A`**. **`6056A5BB`, `79A53AA3`, `BE4581BA`, `1AB02B73` GEÇERSİZ.** ① **A2 iki yakalama** ister (vitrin + gerçek ekran, ham JSON, birleşimde 8 ad) — gevşetme **değil**, sağlanamaz şartın sağlanabilir ve **daha pahalı** hâli; gerekçe §5/G1'de ölçümle yazılı. ② Kriter **6·7·8**'e araç adı + ölçülen rakamlar (`8/8`, `6/6`, `18/18`) ⇒ `sayi-tazeligi.py` artık bu satırları **mekanik** doğruluyor, **muafiyet kalmadı**.
- **K57** — Spec v5 (`6056A5BB`): on **bayat çapraz-atıf** düzeltildi; özü değişmedi. Onuncuyu, kilitten **sonra** doğan `sayi-tazeligi.py` buldu. Ayrıntı: `PROJE_HAFIZA.md` K57.
- **K60** — **Tek kopya dosyaya yazan her betik ATOMİK yazar:** önce `metin.encode("utf-8")` (hata dosyaya **dokunmadan** patlar), sonra `.tmp`, en son takas. Gerekçe ucuz değil: oturum 31'de `io.open(yol,"w")` `PROJE_HAFIZA.md`'yi **önce boşalttı** ⇒ 542 KB arşiv 0 bayta düştü; kurtaran **şanstı** (`git restore`). ✅ Kapısı var: `tek-kopya-kapisi.py`. **Beyan edilen sınır:** kapı hasarı **önlemez**, sessiz kalmasını imkânsız kılar. 🔴 **oturum 34 EKİ:** bu makinede `os.replace` `WinError 5` veriyor ⇒ takas **üç adımlı yedekli** yapılır (§7).
- **K57‑b** — `araclar/radar.py` **plugin 0.2.0 ile BAYT-ÖZDEŞ** (`46E3A8BC`); proje-yerel not **eklenmez** ⇒ sapma **tek sha ile** ölçülür.
- **K58** — `DURUM.md` tavanı **12 → 32 KB**. Gerekçe okuma kapasitesi **değil**: ① R4 freni, ② dikkat (3,5k token okunur, 40k *göz gezdirilir*). Gevşetmenin dayanağı: bayat-atıf sınıfı **mekanikleşti**. 🔴 Tavanı **hiçbir kapı zorlamıyor** — beyan edilmiş **zayıf kontrol**; ilk ısırışta `belge-tavan-kapisi.py` yazılır. Ayrıca `PROJE_HAFIZA.md`'ye **mekanik dizin** (`hafiza-dizin.py`); **yeni checkpoint `<!-- DIZIN:SON -->` ALTINA** eklenir.
- 🔴 **`araclar/oturum-sagligi.py` YOK — K21'in MEKANİK KAPISI EKSİK [K21-DÜZELTME, oturum 34].** Kural artık mutlak eşikli ve tek kanonik yerde, ama *"özet kanonik değerden sapmış mı?"* sorusunu **hiçbir araç sormuyor** — kanonik-kopya sınıfı bu projede beş kez ısırdı. Araç: transcript'ten **mutlak** token okur, rengi mutlak eşikten hesaplar, paydaya DOKUNMAZ, `CLAUDE.md`'nin K21 bloğunu kanonik değerlerle karşılaştırır, **payda yanlışlama testini** koşar. Altın küme: bilerek bozulmuş bir özet satırını yakalamalı. **Build'den sonra ilk ARAÇ işi** (K44-a; şimdi yazılmadı çünkü `R8` sert durağı yeni araç turunu da yasaklıyor — Onur'un kilidi: F1+F2+F4 şimdi, F3 build sonrası).
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
| `pub-cve-kapisi.py` (G2) | `pubspec.lock` ↔ `/advisories`; `withdrawn` atar, `ignored_advisories` **yutmaz** | **8/8** |
| `pub-lisans-kapisi.py` (G3) | `pubspec.lock` ↔ `/metrics` SPDX; *bilinmeyen ≠ temiz*; **metin-kanıtlı eşleşme** (`lisans-eslesme.json`, kanıtsız eşleşme KIRMIZI) | **6/6** |
| `iddia-kapisi.py` **1.1.0** | belgenin **kendi sayı iddiasını** tablosuyla (`I1`, Türkçe sayı sözcükleri dâhil) ve **beyan edilen her mutantın ham kanıtını** KANIT diziniyle (`I2`/`I3`) karşılaştırır; **envanter reddi** (`LISTE_ESIGI=8`) ve **dairesel kanıt yasağı** (özet/hüküm dosyaları kanıt sayılmaz) | **12/12** |
| `tek-kopya-kapisi.py` **1.1.0** | tek kopya dosyaların **HEAD'e göre regresyonunu** ölçer (`S0`–`S10`); sınıf başına farklı kural: append-only **küçülmez**, kilitli **sapmaz**, canlı **%10 budanabilir**; muafiyet gerekçesiz olamaz, **ölü muafiyeti söyler** | **19/19** |
| `tek-kopya-mutant.py` | kapının **ölçüm ayağını** gerçek depoda kanıtlar: arşivi 0 bayta düşürür, satır siler, kilitli dosyayı **aynı boyutta** değiştirir, `.tmp` bırakır, UTF-8'i bozar, dosyayı siler — hepsinde kapının **ısırdığını** ölçer | **11/11** |
| `hafiza-dizin.py` **1.0.0** | `PROJE_HAFIZA.md`'nin başına **türetilmiş** checkpoint dizini yazar; **fikirli** (koşum 2–3'te sha sabit) ve kendi çıktısını doğrular | **7/7** |
| `dosya-kimlik.py` | bayt + sha256 + U+FFFD + CRLF | — |
| `mcp-arac-probe.py` | MCP'nin **gerçek** araç listesi (`tools/list`) | — |
| `pub-surum-olc.py` | pub.dev `/api` sürüm + advisory | — |
| `lisans-yokla.py` | lisansın hangi uçta olduğunu ölçer | — |
| `adr-kapi-taramasi.py` | ADR 0003 kapısı (**dondurulmuş**, dokunma) | — |
| `verify.ps1` | backend build+test+CVE zinciri | — |

---

## 7. KANLA YAZILI ORTAM UYARILARI

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
- **Git Bash/MSYS, `cmd /c`'deki `/c`'yi POSIX yol sanıp `C:/` diye YENİDEN YAZIYOR** ⇒ ham `cmd /c` içeren komutlar **PowerShell'den** koşulur.
- **Başka bir el çalışırken `git add -A` YASAK** — commit'lenmemiş işini kör alır (ölçüldü: `dee6dbc`). Yol belirterek `git add <yol>` yap.
- **`flutter test --platform chrome` bu ortamda SONUÇ ÜRETMİYOR** (iki ölçüm: 7 dk ve 9,8 dk) ⇒ web test ayağı `[DOĞRULANMADI]`.
- **pub.dev HTML sayfaları BAYAT** — kanıt yalnız `/api/` ucudur (spec Z10). · `.ps1`'e Türkçe yol literali yazma. · `kasif` skill'ini **Cowork çağıramaz**; Onur `/kasif` yazar.
- 🔴 **`git`'te `core.autocrlf` AKTİF** — `git restore` LF yazılmış 2.400 baytlık dosyayı **2.800 bayt** geri getirdi (ölçüldü). Çalışma kopyası ↔ HEAD blob **bayt karşılaştırması bu ortamda tek başına KÖRDÜR**; kimlik ölçen her araç LF'e normalize etmelidir.
- 🔴 **`io.open(yol,"w")` DOSYAYI ÖNCE BOŞALTIR** — encode hatası gelirse dosya **0 bayt** kalır (oturum 31: 542 KB arşiv gitti, `git restore` kurtardı). **Python'da `"\ud83d\udd3b"` iki `\u` kaçışı olarak yazılırsa BİRLEŞMEZ**, yalnız vekil karakter olur ve `encode` patlar; emoji için `\U0001F53B` yaz. Kural: **K60 atomik yazım**.
- **`flutter test` Desktop Commander kabuğunda ÇÖKÜYOR** — `%PROGRAMFILES(X86)% environment variable not found` (ölçüldü: değişken `os.environ`'da **yok**, dizin diskte **var**). ⇒ alt sürece `PROGRAMFILES(X86)=C:\Program Files (x86)` **enjekte et**; kalkanla test 36/36 geçti. Bu bir **ortam** kusurudur, ürün kusuru değil.

---

## 8. AÇIK BORÇLAR (adlandırılmış, gizlenmemiş)

> 🔴 **KAPANMIŞ kalemler ve BAYAT çıkan altı iddia buradan ÇIKARILDI** ⇒ `PROJE_HAFIZA.md` **K71**
> (28 Tem 2026, oturum 35). Bu bölüm yalnız **bugün açık olanı** taşır. Kapanmış bir kalemi burada
> aramak bayat okuma üretir; gerekçesi arşivdedir.

### Ürün / kod

- 🔴 **`R9` — UZAKTAN GELEN GÖREV EKRANDA *"Yalnızca bu cihazda"* DİYOR [oturum 35, CANLI ölçüm].**
  Sunucudan inen iki görevin ikisi de saat ikonlu bu rozeti taşıyor; cümle **olgusal olarak
  yanlış**. Mekanizma: `P6` çekmeyle doğan satırı `senkron_durumu='yerel'` bırakıyor
  (`senkron_rozeti.dart:52-58` ⇒ `yalnizcaBuCihazda`), `senkronize` ise rozeti **hiç çizmiyor**
  (`SizedBox.shrink()`). `P6`'nın gerekçesi *bekleyen yerel yazımı* korumaktır ama **çekmeyle DOĞAN
  satırda bekleyen yazım YOKTUR** (`senkron_kuyrugu` ölçümde 0 satır) ⇒ kilit, INSERT-from-pull ile
  UPDATE-of-local'ı ayırmadığı için kapsamı dışına taştı. **Bu bir TASARIM KİLİDİ değişikliğidir,
  kilit Onur'dan gelir.** Kanıt: `KANIT/slice-3d/10-KABUL9/`. ✅ **KİLİT ALINDI (K72): DARALT.** Build spec'i hazır: `GOREV-R9-rozet-kapsami.md` (`B2082127`). Borç **build'de** kapanır.
- 🔴 **`R10` — ÇEKİLMİŞ GÖREV YERELDE DÜZENLENİNCE ROZET SUSAR [denetim buldu, oturum 35].** `senkronize` satır `duzenle()`/`tamamlaGeriAl()`/`sil()` ile değişince rozet `senkronize` kalır ⇒ `SizedBox.shrink()` ⇒ **hiçbir rozet yok**; kullanıcı gönderilmemiş değişikliği senkronize sanar (`gorev_deposu.dart` dört yazma yolu `senkronDurumu`'na yazmıyor). 🔴 **DÜZELTİLMEDİ, ÇÜNKÜ İKİ MEVCUT KAPIYI KIRAR** (`g5_karantina_kapisi_test.dart:212-214` ve `:216-219`: `duzenle()` sonrası rozet **`cakisma` KALMALI**). Gerçek soru: *hem ÇAKIŞMALI hem BEKLEYEN satır hangisini söyler?* — **öncelik kilidi Onur'dan gelir.** Sınıf `R9`'dan önce de vardı (itilmiş görevlerde); `T1` onu çekilmiş görevlere genişletir ⇒ **net kötüleşme dar ama gerçek.**
- 🟡 **`senkron_rozeti.dart:9-11` DOKÜMAN YORUMU BAYAT** — *"'senkronize' hiçbir zaman gerçek veriden
  doğmaz, yalnız vitrin/testler içindir"* diyor; cihaz DB'sinde `abcf4930…` satırı **`senkronize`**
  ve onu `senkron_dongusu.dart:186` gerçek itme turunda yazıyor (K69/EK-2 `B1` aynı satırı gösterir).
- 🔴 **`KANIT/slice-3c/02-G2/` GERİ DOĞDU ve ÜRETİCİ KOD DÜZELTİLMEDİ.**
  `g2_registry_zarf_kapisi_test.dart:64` hâlâ `Directory('../../KANIT/slice-3c/02-G2')` yazıyor
  (28 Tem 2026'da yeniden ölçüldü, **aynen duruyor**). slice-3d build notunda ayrı madde olarak
  verilmişti; yapılmadı **ve devir notunda anılmadı** ⇒ *beyan edilmemiş atlama*. Silmek düzeltme
  DEĞİLDİR. 🔴 **AYNI DESENİN İKİNCİ YAZICISI ÖLÇÜLDÜ:** `g3_ayristirici_kapisi_test.dart:20` →
  `Directory('../../KANIT/slice-3d/03-G3-ayristirici')`. Hiçbir araç *"KANIT dizini ile onu yazan
  kodun yolu aynı mı?"* diye sormuyor ⇒ sınıf tek vaka değil.
- 🟡 **Son sayfa tam `PageSize` ise BİR BOŞ TUR fazladan koşar** — `hasMore = (changes.Count ==
  PageSize)`, `PageSize=500` sabit. Veri kaybı değil, **maliyet**.

### Araç / kapı

- 🔴 **`verify.ps1` FAIL-LOUD AYAĞINI OTOMATİK ZİNCİRDE ETKİSİZ KILIYOR** (28 Tem 2026'da yeniden
  ölçüldü, duruyor): `if (-not $env:MOMENTUM_KANIT_DIZIN) { … }` varsayılan atıyor ve dizini
  yaratıyor. Test hâlâ fırlatıyor, **ama** spec §8.2'nin *"zorunlu"* şartı regresyon zincirinde
  **hiç ölçülmüyor**. Ayrıca bu bir **araç** değişikliğidir (K34-f).
- 🔴 **D1-ÖNLEME BORCU** — defter/belgeye sayı yazan **her** betiğe *"önce diskten ölç"* adımı zorunlu
  olsun. D1 bu projede **altı kez** ısırdı; radar onu **sonradan** bulur, önleme **doğmasını** engeller.
- 🔴 **`belge-tavan-kapisi.py` HÂLÂ YOK** — `DURUM.md` tavanını (32 KB) **hiçbir kapı zorlamıyor**;
  beyan edilmiş **zayıf kontrol**. K71 taşıması payı geçici olarak açtı, sınıfı kapatmadı.
- 🔴 **`pub-surum-olc.py`'ye ÇÖZÜMLENEBİLİRLİK AYAĞI [Z10b]** — araç **sürümü** ölçüyor,
  **çözülebilirliği** ölçmüyor. Kalkan gelene dek her pin `pub get` ile doğrulanır.
- 🟢 **`tek-kopya-kapisi.py`'nin BEYAN EDİLMİŞ SINIRI [S10]** — karşılaştırma **LF'e normalize**
  içerik üzerinden (`core.autocrlf`; M2: 2.400 → 2.800 b). Yalnız satır sonunu kaybeden dosya kapıyı
  geçer (M2b). İçerik kaybı değil, **beyan edilmiş** sınır.
- 🟡 **`radar.py` R5'in CÜMLESİ KAPSAMINI AŞIYOR** — R5 artefaktın kendi kaydını okur ama
  *"**projenin** görünen çıktısı %0"* der. Kusur **metinde**. Onarım üst akış plugin'inde (K57-b
  bayt-özdeşliği bozulmasın), **ayrı el** (K34-f).
- 🟡 **`radar --olc-urun-kodu` ÇALIŞMA AĞACINI GÖRMEZ** — yalnız commit'lenmiş farkı sayar ⇒ iki elin
  çalıştığı bu projede R8'i yanlış-pozitif yapar. R8 yandığında **önce çalışma ağacı ölçülür.**
- 🟡 **`sayi-tazeligi.py` — İMZA↔SAYI YAKINLIĞI ÖLÇÜLMÜYOR [3 kez tetikledi].** Eşik uydurulmadı
  (K40); kalıcı onarım **ayrı ele** (K34-f).
- 🟡 **M2b beyanının TERSİ ölçüldü** — spec/DESIGN A-4 *"çok satırlı `/* */` içindeki literal
  KAÇABİLİR"* diyordu; kapı onu **yakaladı** ⇒ `yorum_disi()` yorumu soymuyor (yanlış-pozitif yönü).
- **`radar.config.json` YOK ve bu bir KARAR** — varsayılan yollar repoya birebir uyuyor. Eşik
  değiştiren K40 gereği **altın kümeye vaka ekler**.

### Belge / defter

- **`DESIGN.md` BD‑1…BD‑7** — **K46 gereği kapatılmadı**; liste spec §10'da. BD‑6'nın bayat sayısı
  `sayi-tazeligi.py`'de **gerekçeli muafiyet**.
- 🔴 **Defter dürüstlük kusurları** — `D3`: `docs/ADR/0003` tur 8 kaydının zorunlu alanları eksik ·
  `D2`: aynı defterde **tur 1 atlanmış**. Append-only ⇒ **düzeltme kaydı** (28 Tem 2026 radarında
  hâlâ SARI yanıyor).
- 🟡 **`D1` bu defterde KÖR** — artefakt adları çoğunlukla **etiket**, yol değil. Yeni kayıtlara
  **gerçek yol** yazılır.
- 🟡 **`KANIT/slice-3b/04-G3/gercek-tarama.txt` 1,9 MB** — portfolyo reposuna yüktür; kesit + sha yeterdi.

### `[DOĞRULANMADI]` (ölçülmedi — "temiz" DEĞİL)

- **Kriter 9 kapsamı dışında kalanlar:** web ayağı (`--platform chrome` bu ortamda sonuç üretmiyor) ·
  iOS (Mac yok, CI-only) · boşaltma tavanı 20'nin **her** koşulda yeterliliği.
- **Kriter 9 ölçümünün kendi beyan ettiği sınırlar:** `01-acilis.png`'deki ANR diyaloğunun sahibi
  **System UI**'dır (ölçüldü), ama uygulamanın kendi ANR üretmediği **ölçülmedi** · soğuk açılış
  **süresi** ölçülmedi · düzenleme/tamamlama/silme yollarının uzak yansıması bu ayakta ölçülmedi.
- **builder'ın *"`cmd /v:on` kalıbı `M4`'te bir kez SESSİZCE başarısız oldu"* iddiası** — Cowork aynı
  kalıbı onlarca kez kullandı, **hiç yalan söylemedi**; sapma zararsız, **gerekçesi doğrulanmadı**.
- **Eski açık 5:** flutter_secure_storage Windows · WebKit `__Host-` · Isopoh lisansı ·
  NIST SP 800-38D · web'de `textScaler`/tema farkı.
- **`pub.dev` uçları** dokümantasyonsuz/garantisiz — kalkan: fixture altın kümeleri. · **Kontrast
  betiği** `araclar/` dışında.
- **Geçici artıklar (repo DIŞINDA, silme Onur'da):** `%TEMP%\_cw_*` · `C:\dev\_cowork_tmp\`.

---

## 9. DOSYA KİMLİKLERİ (`sha256` ilk 8 · **son yazımdan sonra ölçülür**)

🔴 **BURAYA YALNIZ *DONMUŞ* KİMLİKLER YAZILIR.** Sık değişen bir sha'yı buraya yazmak `kanonik-kopya` kusurunu **garanti eder** (bu tabloda üç kez oldu). Değişkenlerin kimliği **yazılmaz, ÖLÇÜLÜR**:

```powershell
python araclar\dosya-kimlik.py DURUM.md CLAUDE.md DESIGN.md PROJE_RADAR.jsonl GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md
```

**DONMUŞ KİMLİKLER (bunlar SÖZLEŞMEDİR — değişirse bir kilit bozulmuş demektir):**

| dosya | bayt | sha8 | neden donmuş |
|---|---|---|---|
| `DESIGN.md` | 15.742 | `534DFF68` | **K46** — tek bayt yazılamaz |
| `GOREV-slice-3b-istemci-iskeleti.md` | **44.560** | **`F0C3A75A`** | 🔒 **K59 kilidi (v6)** — değişen her bayt kilidi bozar. `6056A5BB` · `79A53AA3` · `BE4581BA` · `1AB02B73` **geçersizdir** |
| `GOREV-slice-3c-senkron.md` | **41.692** | **`537D0579`** | 🔒 **K64 kilidi (v2, Onur onayladı 27 Tem 2026)** — `5899A220` (v1) **GEÇERSİZDİR**. `tek-kopya-kapisi.py` kapsamında **`kilitli`** sınıfındadır ⇒ sapma **her açılışta ölçülür** |
| `GOREV-slice-3d-cekme.md` | **80.399** | **`889A383F`** | 🔒 **K70 kilidi** (Onur onayladı 28 Tem 2026) — build'i sürdü, iki bağımsız denetimden geçti, `tek-kopya-kapisi.py` kapsamında **`kilitli`** ⇒ sapma **her açılışta** ölçülür |
| `araclar/radar.py` | 28.878 | `46E3A8BC` | **K57‑b** — plugin 0.2.0 ile bayt-özdeş; sapma tek sha ile ölçülür |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` | **K34-f** tutuyor; ADR donduruldu |
| `araclar/tek-kopya-kapisi.py` | **17.259** | **`66AC9CA3`** | K70'te kapsam genişledi; değişiklikten sonra **mutant kümesi 11/11 yeniden koştu** |

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** (`Measure-Object -Line` boş satırları saymaz) ve **DAİMA son yazımdan SONRA** ölçülür.

---

## 10. NEREDE NE VAR

`DURUM.md` (**canlı durum**) · `CLAUDE.md` (kalıcı kurallar) · `PROJE_HAFIZA.md` (**append-only arşiv**, K1…K57) · `DESIGN.md` · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` · `araclar/` (kapılar) · `KANIT/` · `src/`, `tests/`.
