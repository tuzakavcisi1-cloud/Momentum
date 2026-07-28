# DURUM.md — Momentum · CANLI DURUM (her oturumun TEK zorunlu okuması)

> **Bu dosya kısa kalmak ZORUNDADIR.** Tavan: **≤ 32 KB** [K58; eski tavan 12 KB]. Aşarsa budanır, tarihçe `PROJE_HAFIZA.md`'ye taşınır. Gerekçe okuma kapasitesi değil **R4 freni + dikkat**; tavanı şu an **hiçbir kapı zorlamıyor** (beyan edilmiş zayıf kontrol, ilk ısırışta araç yazılır).
> `PROJE_HAFIZA.md` artık **APPEND-ONLY KARAR ARŞİVİDİR**; oturum açılışında **okunmaz**, yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır.
> **Son güncelleme:** 28 Tem 2026, oturum 34 (K69 — slice-3d spec'i **YAZILDI**, iki kapı EXIT 0).

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
| **Backend** | ✅ slice-1 → 3a bitti. `araclar\verify.ps1` ⇒ build 0 uyarı/0 hata · **test 110/110** · CVE 0 · EXIT 0 |
| **Veritabanı** | ✅ Docker 29.6.1, `momentum-postgres` Up (healthy) |
| **İstemci (Flutter)** | 🟢 **slice-3b T0→T9 + slice-3c BİTTİ.** 8 bileşen + `MomentumTema` · Drift çevrimdışı CRUD · senkron kuyruğu (yalnız **push**) · yedi kapı `G1`–`G7` koştu, **24 mutant etiketinin hepsi ısırdı** · `A2` = **8/8** (iki ham ağaç, birleşimi Cowork ayrıştırdı) · Cowork'ün kendi koşumu `analyze` 0 bulgu / `flutter test` 36/36 EXIT 0. Kapanış commit'leri `5df3caf` (3b) ve slice-3c. 🔴 **Çekme (pull) YOK — slice-3d'nin işi.** |
| **Tasarım sistemi** | ✅ `DESIGN.md` v1 (15.742 b · `534DFF68`) — 32 token, 8 görsel bileşen, 8 durum, A11Y‑1…7 |
| **ADR 0003 (kimlik)** | 🧊 v7 **DONDURULDU** (K41). Kanonik v6. **DOKUNMA** |
| **Radar** | `radar.py` **plugin 0.2.0 ile bayt-özdeş** — R8 · D1‑D5 · `--olc-urun-kodu` · altın küme **18/18**. Hüküm **KIRMIZI** ve bu **beklenen**: kâğıt artefaktlar (`docs/ADR/0003` park · `GOREV-slice-3b-spec` build'e devredildi) hâlâ defterde duruyor. `slice-3b-istemci` kapanış kaydı: bloker 0 · **`urun_kodu_satiri` = 61** ⇒ **R8 SUSTU** · `gorunen_cikti_yuzde` **ilk kez 0'ın üstünde (35, TAHMİN)**. Varsayılan cevap **DEVRET** — zaten yapılan bu |
| **Git** | **PUSH DAİMA ONUR'DA.** İleri/geri durumu **yazılmaz, açılışta ÖLÇÜLÜR**: `git --no-optional-locks rev-list --left-right --count origin/main...HEAD` |

**Ortam:** Flutter 3.44.6 · Dart 3.12.2 · Android SDK 36.1.0 ✓ · Chrome/web ✓ · .NET 9.0.316 · **Windows masaüstü ☠** · dart MCP **1.1.0, 14 araç** (`.mcp.json` → `dart pub global run dart_mcp_server`).

---

## 4. SIRADAKİ İŞ

✅ **K42-d ADIM 3 (`slice-3c`) BİTTİ ve BAĞIMSIZ DOĞRULANDI.** Spec `GOREV-slice-3c-senkron.md` (K64, **41.692 b · `537D0579`**) T1–T8 tamamlandı; **ürün kodu +7.602 / −160 satır, 45 dosya** — `R8` sert durağı kalktı.

**COWORK'ÜN KENDİ KOŞUMU [slice-3c, K26 — builder'ın beyanına güvenilmedi]:** `analyze --fatal-infos` 0 bulgu · `flutter test` **+79** · `verify.ps1` build 0 uyarı + **114/114** + CVE 0 · `spec-kapi-kapsama` 8 kapı/10 kural/36 mutant · `sayi-tazeligi`/`tek-kopya`/`design-token` temiz — **hepsi EXIT 0.** 36 mutantın **8'i** ham KANIT'lı; kalan 28 transkriptten doğrulandı (🟡 **yakınlık** ölçer, nedensellik kanıtlamaz). Sınıf **K67'de mekanikleşti.**

🔴 **K65 ve K66/4 arşivdedir.** Tek satırlık özü: bu bir *backend kusuru* **değildi** — düzeltme tamamen istemcide yapıldı (`opId` v4→**v7**, `counter` her damgada artar, 10/10 ardışık koşum), backend'e tek satır dokunulmadı. Doğru sınıflandırma: **① spec kusuru (kapandı) + ② backend'de zorlanmamış varsayım** (K68/`P4` ile planlandı).

**KANIT:** `KANIT/slice-3c/` — `HUKUM.md` (**7.386 b · `E3F87A3D`**) · kök `00-OZET.md` (**3.147 b · `54D1570A`**) · `09-MUTANT/00-OZET.md` (**5.640 b · `4A5CEB71`**).

✅ **K68 — slice-3d (ÇEKME) TASARIMI KİLİTLENDİ (oturum 33, Onur onayladı).** Kilitler: **`P1`** yerel LWW = **ayrı `UzakAlanDurumu` tablosu** (şema **v4**), `Gorevler` saf projeksiyon kalır · **`P2`** tetikleyici = **açılış + elle yenile + `hasMore` boşaltma**, periyodik yoklama YOK · **`P3`** yakınsama kanıtı = **F3 gerçek API'ye iki-DB uçtan uca + F2 sahte ağlı ucuz kapı** · **`P4`** backend `opId` v7 = **`IsEnvelopeValid`'de op-bazlı red + mutant**. Gerekçeler ve **beş ölçülmüş kısıt** (ayrı çekme ucu YOK · ilk senkron zorunlu snapshot · **echo UYGULANIR** çünkü gövde sunucunun KIRPILMIŞ HLC'sini taşır · `hasMore` yanlış-pozitifi · cursor HLC değil, ham metin saklanır) **`PROJE_HAFIZA.md` oturum-33 checkpoint'inde**.

✅ **SPEC YAZILDI [oturum 34]:** `GOREV_CLAUDE_CODE\GOREV-slice-3d-cekme.md` — **61.242 b · `FD85FD37`** · dokuz kapı `G1`–`G9` · on kural `D0`–`D9` · **otuz iki** mutant `M1`–`M32` · on görev `T1`–`T10`. Yazım eli AYRI (temiz bağlamlı alt-ajan), **kapıları Cowork kendi koştu**: `spec-kapi-kapsama.py` **EXIT 0** · `iddia-kapisi.py` **HÜKÜM TEMİZ, EXIT 0**. **[KIRMIZI] Aynı koşum `KANIT DIZINI: verilmedi -- I2/I3 OLCULMEDI` dedi** ⇒ *"kapılar geçti"* bugün **yalnız `I1`** demektir. Spec **KİLİTLİ DEĞİL**.

**[KIRMIZI] SIRADAKİ İŞ: SPEC'E BAĞIMSIZ DENETİM (K26)** — denetçi, spec'i yazan alt-ajandan **AYRI el** olmalı. Emsal pazarlıksız: slice-3c'de aynı denetim spec v1'i **10 bloker + 12 önemli + 8 not** ile kırdı. Denetim özellikle şunları kırmayı denesin: `M1`–`M32` gerçekten **ısırıyor mu** (eşdeğer-mutant sınıfı bu projede iki kez çıktı) · `G8` gerçekten **iki AYRI Drift DB + gerçek API** mi kullanıyor · `P5` mutantı `owner_id` kusurunu GERÇEKTEN yakalıyor mu (`G8` tek sahiple koşuyor ve kusuru **görmez**; mutant `G7`'de — bu ayrım doğru mu?) · `P7`'nin ham-metin gerekçesi (§8 açık bulgu) · **kanıt yolu ile o yolu YAZAN kodun yolu aynı mı** (02-G2 sınıfı). Denetimden sonra **kilit Onur'dan gelir**, sonra BUILD. Devralınan borçlar: iki cihaz yakınsaması · ADR 0003 kimlik.

✅ **TEMİZLİK BİTTİ [oturum 33, Onur yaptı — Cowork ÖLÇTÜ]:** `src/backend/Momentum.Api.Tests/` **YOK** · `src/backend/Momentum.Persistence.Tests/` **YOK** · `KANIT/slice-3c/02-G2/` **YOK** · `_SILINECEKLER/` **boş** (0 giriş; gitignore'lu kabuk, zararsız). 🔴 **02-G2 GERİ GELECEK:** üretici kod hâlâ oraya yazıyor (§8) — silinmesi kusuru kapatmaz, **bir sonraki `flutter test` koşumunda yeniden doğar**.
🟡 **Arka planda `http://localhost:5298` Development API HÂLÂ ÇALIŞIYOR** (ölçüldü: `netstat` LISTENING, PID 28528). F3 uçtan uca koşumu için **gerekli**; kapatılacaksa bilinçli kapatılır.

## 5. YÜRÜRLÜKTEKİ KİLİTLER (tek satır; gerekçe `PROJE_HAFIZA.md`'de)

- **K69** — **slice-3d spec'i YAZILDI; üç karar kilitli:** `P5` `owner_id` kusuru **kapsanır** (`SyncCommandHandler.cs:184` → `authenticatedActorId`; kanıt aynı dosyanın `:156` yorumu) · `P6` uzak değişiklik **rozete DOKUNMAZ** (CHECK beş değerle sınırlı ⇒ migration salt-ekleme kalır) · `P7` **bekleyen yerel yazım korunur** (taban `max(UzakAlanDurumu, kuyrukta bekliyor/gonderildi alan-HLC)`). Ayrıca **K68/3'ün GEREKÇESİ düzeltildi, kilidi AYNI:** echo'nun değeri *"efektif HLC öğrenmek"* değildir (`applied[]` zaten taşır; `SyncPuller.cs:37` outbox `hlc` kolonunu **SELECT etmez**), **kırpılmış alan-HLC'sini `UzakAlanDurumu`'na tohumlamaktır** — atılırsa istemci ile sunucu **farklı kazanan** seçer.
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

- ✅ **KAPANDI [K63]:** slice-3c spec'i bağımsız denetimden geçti; denetim v1'i **KIRDI** (10 bloker · 12 önemli · 8 not; 30 kapatıldı). **K26 SAĞLANDI.** Ders: *beyan edilmiş bir eksik, kapatılmamış bir eksiktir.*
- 🔴 **`KANIT/slice-3c/02-G2/` SİLİNEMEZ — G2 TESTİ ORAYA YAZMAYA DEVAM EDİYOR [K66/5]:** `g2_registry_zarf_kapisi_test.dart` **satır 64** `Directory('../../KANIT/slice-3c/02-G2')` ⇒ klasör her `flutter test` koşumunda **yeniden doğar**. Onur diski temizledi (oturum 33: klasör YOK, ölçüldü) ama **kusur AÇIK**: üretici kod hâlâ o yola yazıyor; silmek düzeltme değildir, kalıcı düzeltme **üretici elin** işi. 🔴 Hiçbir araç *"KANIT dizini ile onu yazan kodun yolu aynı mı?"* diye sormuyor — mekanik kontrol **YOK**.
- 🔴 **BACKEND `OperationId`'nin UUIDv7 OLDUĞUNU ZORLAMIYOR [K66/4]:** `HlcKey` tie-break'i zaman-sıralı `opId` **varsayar**, `IsEnvelopeValid` yalnız *"boş GUID değil"* der ⇒ v4 gönderen bir istemci K65'in yazı-turasını geri getirir ve **hiçbir kapı yanmaz**; bugün kapalı olmasının tek sebebi istemcinin uslu davranması. ✅ **K68/`P4` ile slice-3d KAPSAMINA ALINDI** (op-bazlı red + mutant; borç kapanmadı, **planlandı**).
- **`owner_id` KAYNAK UYUŞMAZLIĞI — K69/`P5` ile KAPSAMA ALINDI (borç kapanmadı, PLANLANDI).** Outbox `owner_id` = wire `op.ActorId` (`SyncCommandHandler.cs:184`), materialize `authenticatedActorId` (`:157`), `SyncRequestValidator` wire `actorId`'yi doğrulamıyor. Kanıt kodun **kendi içinde**: `:156` yorumu *"ownerId is the AUTHENTICATED actor — NEVER op.ActorId"* diyor ⇒ bu bir tasarım tercihi değil **KUSUR**. Artımlı çekme yalnız `owner_id` filtreli (`SyncPuller.cs:40`) ⇒ çekme görünürlüğünü doğrudan etkiler. **Mekanizma ÖLÇÜLDÜ; canlı PoC KOŞULMADI.**
- **`I2`/`I3` slice-3d'de HENÜZ KOŞMADI** — `iddia-kapisi.py` spec üzerinde yalnız `I1` ölçtü (`KANIT DIZINI: verilmedi`). `KANIT/slice-3d/` yokken *"kapılar geçti"* demek mutant kanıtını **kapsamaz**; build'den sonra `--kanit KANIT\slice-3d` ile koşulacak.
- 🟡 **ÇEKME YOLU İÇİN İSTEMCİDE TEK TEST YOK** ve `changes`/`snapshot`/`hasMore` dizeleri `src/client/lib` ağacında **sıfır kez** geçiyor (ölçüldü) — D6 beyanı doğrulandı. `hasMore = (changes.Count == PageSize)`, `PageSize=500` sabit ⇒ son sayfa tam 500 ise **bir boş tur** fazladan koşulur (veri kaybı değil, maliyet).
- ✅ **KAPANDI [oturum 33]:** `araclar/iddia-kapisi.py` **D1 bayat beyanı** (defter 19.912 ⇄ disk **20.157**) — düzeltme kaydı defterde; radar D1 **sustu**.
- ✅ **MEKANİKLEŞTİ [K67]:** *"mutant ham çıktısı"* ve *"sayı ⇄ liste"* sınıflarının kapısı `araclar/iddia-kapisi.py` **1.1.0** (**20.157 b · `9F98CBF9`**), altın küme **12/12**. Araç iki kez kendi kör noktasını gösterdi (ters sıralı sayı iddiası · dairesel kanıt ⇒ envanter reddi `LISTE_ESIGI=8`). slice-3d spec'i bu kapıdan **geçti** (oturum 34, `I1` temiz).
- **MEKANİKLEŞTİ [K66/2 → K67]:** mutant ham çıktısı **koşum anında** yazılmalı; `I2`/`I3` bunu ölçer (slice-3c'de 36 mutantın 8'i ham kanıtlıydı). **[KIRMIZI] slice-3d'de `I2`/`I3` HENÜZ KOŞMADI** — `KANIT/slice-3d/` yok; build'den sonra koşacak.
- 🔴 **`git diff` TAKİPSİZ DOSYALARI GÖRMEZ — "dokunulan yüzey" ölçümü tek başına KÖR [K66/3]** — slice-3c'nin kabul kriteri 8'i `diff --stat` ile ölçülüyordu ve `src/backend/` altındaki yeni `Auth/DevCurrentUser.cs` ile iki stray klasörün **hiçbirini** göstermedi. Bundan sonra "dokunulan yüzey" iddiası **`diff` + `status` birlikte** ölçülür.
- ✅ **KAPANDI [K67] — SAYI ↔ LİSTE TUTARSIZLIĞI:** iki kez üretilmiş sınıfın artık mekanik kapısı var (`iddia-kapisi.py` `I1`, Türkçe sayı sözcükleri dâhil). slice-3d spec'inde **ısırdı ve teslimden önce düzeltildi** (alt-ajanın iki `I1` bulgusu).
- 🟡 **Çekme (pull) yakınsaması slice-3c'de KANITLANMAYACAK** — `D6` beyan edilmiş sınırı: `changes`/`snapshot` Drift'e uygulanmaz, yalnız `nextCursor` saklanır. İki cihazın yakınsaması **slice-3d borcudur**.
- **`DESIGN.md` BD‑1…BD‑7** — **K46 gereği kapatılmadı**; liste spec §10'da. BD‑6'nın bayat sayısı `sayi-tazeligi.py`'de **gerekçeli muafiyet** olarak görünür.
- ✅ **KAPANDI [K57]:** `radar.py` kopyası GERİDE · Spec T2/Z10 kilit düzeltmesi.
- 🔴 **`pub-surum-olc.py`'ye ÇÖZÜMLENEBİLİRLİK AYAĞI [Z10b]** — araç **sürümü** ölçüyor, **çözülebilirliği** ölçmüyor. Kalkan gelene dek **her pin `pub get` ile doğrulanır**.
- 🔴 **Defter dürüstlük kusurları [D-kapısı buldu]** — `D3`: `docs/ADR/0003` tur 8 kaydının zorunlu alanları eksik. `D2`: aynı defterde **tur 1 atlanmış**. Append-only ⇒ **düzeltme kaydı**.
- ✅ **KAPANDI [K59]:** *"Spec kriter 6/7 ölçülmedi"* — araç adları yazıldı, rakamlar ölçüldü, muafiyet **silindi**.
- ✅ **KAPANDI [oturum 31]:** *A2 kanıtı eksik* — iki ham ağaç yazıldı (`widget-tree-vitrin.json` `574223D0` · `widget-tree-gercek-ekran.json` `6C5D431A`), **Cowork ikisini de `json.loads` ile ayrıştırdı**, birleşim **8/8**. `HUKUM.md` (`D6AC8377`) artık **düğüm kimliklerine** atıf yapıyor — beyan değil **çıktı**.
- 🟢 **`tek-kopya-kapisi.py`'nin BEYAN EDİLMİŞ SINIRI [S10]** — karşılaştırma **LF'e normalize** içerik üzerinden yapılır (`core.autocrlf` yüzünden aynı içerik farklı baytta; M2 ölçtü: 2.400 → 2.800). Sonuç: **yalnızca satır sonunu** kaybeden dosya kapıyı geçer (M2b). İçerik kaybı değildir; **beyan edilmiş** sınırdır.
- 🟡 **`radar.py` R5'in CÜMLESİ KAPSAMINI AŞIYOR [ölçüldü]** — R5 artefaktın **kendi** son kaydındaki `gorunen_cikti_yuzde`'yi okur ama *"**projenin** görünen çıktısı %0"* der. Kusur **metinde**, ölçümde değil. Onarım üst akış plugin'inde (K57-b bayt-özdeşliği bozulmasın), ayrı el (K34-f).
- 🟡 **`radar --olc-urun-kodu` ÇALIŞMA AĞACINI GÖRMEZ** — yalnız commit'lenmiş farkı sayar ⇒ iki elin eşzamanlı çalıştığı bu projede **R8'i yanlış-pozitif yapar** (oturum 31'de yaktı; gerçek ölçüm 61 satır). R8 KIRMIZI yandığında **önce çalışma ağacı ölçülür.** Onarım ayrı ele (K34-f).
- 🟡 **`KANIT/slice-3b/04-G3/gercek-tarama.txt` 1,9 MB** — portfolyo reposuna yüktür; ilgili kesit + sha yeterdi.
- 🟡 **M2b beyanının tersi ölçüldü** — spec/DESIGN A-4 *"çok satırlı `/* */` içindeki literal KAÇABİLİR"* diyordu; kapı onu **yakaladı** ⇒ `yorum_disi()` yorumu soymuyor (kaçırma değil, **yanlış-pozitif** yönü). A-4 beyanı bu ölçüme göre yeniden okunmalı.
- 🟡 **`D1` bu defterde KÖR** — artefakt adları çoğunlukla **etiket**, yol değil. Yeni kayıtlara **gerçek yol** yazılır.
- 🟡 **`sayi-tazeligi.py` — İMZA↔SAYI YAKINLIĞI ÖLÇÜLMÜYOR [3 kez tetikledi]** — uzun satırlarda araçla ilgisiz bir oran iddia sanılıyor. **Eşik uydurulmadı** (K40); ikisi muafiyet/metin düzeltmesiyle kapandı. Kalıcı onarım **ayrı ele** (K34-f).
- **`radar.config.json` YOK ve bu bir KARAR** — varsayılan yollar repoya birebir uyuyor. Eşik değiştiren K40 gereği **altın kümeye vaka ekler**.
- **`pub.dev` uçları** dokümantasyonsuz/garantisiz — kalkan: fixture altın kümeleri. · **Kontrast betiği** `araclar/` dışında.
- **Açık `[DOĞRULANMADI]` (5):** flutter_secure_storage Windows · WebKit `__Host-` · Isopoh lisansı · NIST SP 800-38D · web'de `textScaler`/tema farkı.
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
| `araclar/radar.py` | 28.878 | `46E3A8BC` | **K57‑b** — plugin 0.2.0 ile bayt-özdeş; sapma tek sha ile ölçülür |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` | **K34-f** tutuyor; ADR donduruldu |

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** (`Measure-Object -Line` boş satırları saymaz) ve **DAİMA son yazımdan SONRA** ölçülür.

---

## 10. NEREDE NE VAR

`DURUM.md` (**canlı durum**) · `CLAUDE.md` (kalıcı kurallar) · `PROJE_HAFIZA.md` (**append-only arşiv**, K1…K57) · `DESIGN.md` · `PROJE_RADAR.jsonl` (ölçüm defteri) · `docs/ADR/` · `GOREV_CLAUDE_CODE/` · `araclar/` (kapılar) · `KANIT/` · `src/`, `tests/`.
