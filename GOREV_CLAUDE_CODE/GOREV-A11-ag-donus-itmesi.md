# GOREV-A11 — AĞ-DÖNÜŞ İTMESİ (`D0` DARALTMASI) + `Y1` KAÇAĞININ KAPATILMASI

> **Durum:** KİLİT ADAYI — Onur'un iki kilidi alınmıştır (2 Ağu 2026, oturum 49); bu belge onları
> yürütülebilir hâle getirir. **Build: Claude Code. Ölçüm/denetim: Cowork (K26 — üreten ≠ denetleyen).**
> Araç onarımı bilerek **yazan elden ayrı ele** verilmiştir (`K34-f`; oturum 47'de `A9c` aynı yolu izledi).

## 1. NE OKUNUR

`DURUM.md` · `CLAUDE.md` · `ORTAM.md` · **`KANIT/cevrimdisi-senkron/01-OLCUM-OZETI.md`** (bu spec'in
tamamı o ölçümden doğdu) · `GOREV_CLAUDE_CODE/GOREV-slice-3d-cekme.md` §3 `D0` ve §5 `G1`.
`PROJE_HAFIZA.md`'yi **açma** — append-only arşivdir; gerekçe sorulursa `K115`.

🔴 Kapı kimlikleri **spec-yereldir** (`K108`): bu belgedeki kapılara **daima `A11/G22` biçiminde**
atıf yapılır, çıplak `G22` yazılmaz.

## 2. NEDEN — ÖLÇÜLMÜŞ KÖK NEDEN (kâğıttan değil, koşan uygulamadan)

Oturum 49'da emülatörde ölçüldü: uçak modunda iki görev eklendi, **30 s boyunca sunucuya sızmadı**
(doğru), ağ **4,4 s**'de geri geldi, ve **uygulama ön plandayken 90 s boyunca kuyruk boşalmadı.**
*"Yenile"*ye basılınca **2,2 s**'de gitti.

Kök neden koddan ölçüldü: **itmenin (`turCalistir()`) üç tetikleyicisi vardır** — `main.dart:55`
(açılış) · `main.dart:81` `onYerelYazma` (K113) · `main.dart:94` `elleYenile`. `main.dart:150`
sinyal dinleyicisi **yalnız `cekmeTuruCalistir()`** koşar. `pubspec.yaml`'da ağ-durumu paketi **yoktur**.
⇒ ***"ağ geri geldi"* diye bir tetikleyici hiç tasarlanmamıştır.** Bu bir regresyon değil,
**K112'nin kardeşi kapsam boşluğudur**; 485 istemci + 120 backend testi görmedi, koşan uygulama gösterdi.

🔴 **ÇÜRÜTÜLMÜŞ ŞIK — tekrar önerilmesin diye yazılıdır.** *"`SinyalBaglandi` olayını itme
tetikleyicisi yap"* şıkkı ölçümle çürüdü: `18-logcat.txt` o pencerede **ne `baglanti koptu` ne
`el sikisma basarili`** gösterdi, buna karşılık sonrasında **`Changed alindi` geldi** ⇒ **soket hiç
kopmadı.** Emülatörün `10.0.2.2` NAT'ı **kurulu** bağlantıyı koruyor. Yeniden bağlanma yolu
**hiç egzersiz edilmedi**; gerçek cihazda davranış **`[DOĞRULANMADI]`**.

## 3. KİLİTLİ KARARLAR (Onur, 2 Ağu 2026 — pazarlığa kapalı)

### `D-A11-1` — `D0` DARALTILDI (K68/K79 daraltması)

**Eski metin:** *"[YASAK] Periyodik yoklama (polling). Zamanlayıcı YOK — `D0`."*
**Yeni metin:** *"[YASAK] Periyodik **ÇEKME**. Zamanlayıcıyla `cekmeTuruCalistir()` çağırmak
KIRMIZI'dır ve öyle kalır."*
**TEK İSTİSNA:** kuyrukta **bekleyen** satır varken **başarısız olmuş** bir **itme** turu, tavanlı
geri çekilmeyle **yeniden denenebilir**.

🔴 **Daraltmanın ölçülmüş gerekçesi:** `D0`'ın kendi yazılı gerekçesi *(mobil pil + sunucu yükü +
gerçek zamanlı ihtiyacı 3e'den önce sahte biçimde karşılamak)* bu davranışı **kapsamaz**. Yeniden
deneme yalnız **gönderilmemiş iş varken** koşar; `turCalistir()` kuyruk boşken **istek atmaz**
(`slice-3d/M2` bu ayağı zaten koruyor) ⇒ **boştaki maliyeti sıfırdır** ve gerçek zamanlılık iddiası
doğurmaz — çünkü **hiçbir koşulda çekmez**.

### `D-A11-2` — YENİDEN DENEME SÖZLEŞMESİ

1. **Çizelge:** `2s · 5s · 15s · 30s · 60s`, sonrası **60 s'de sabit**. Jitter **±%20**
   (`signalr_json_sinyal.dart`'taki kabul edilmiş desenin aynısı — yeni desen icat edilmez).
2. **Planlama tekliği:** aynı anda **en fazla BİR** bekleyen yeniden-deneme zamanlayıcısı olur.
   İkinci bir başarısızlık yeni zamanlayıcı **kurmaz**.
3. **DURMA KOŞULLARI (hepsi):** kuyruk **boşaldı** · itme **başarılı** oldu (çizelge **sıfırlanır**)
   · `durdur()`/dispose çağrıldı.
4. 🔴 **YALNIZ TAŞIMA/GEÇİCİ HATA yeniden denenir:** soket/DNS/timeout hataları, **5xx**, **408**,
   **429**. **Diğer 4xx yeniden DENENMEZ** — sonsuz döngü kurar. (`D8`'in *"bir bozuk op yüzünden
   tüm isteği reddetme"* kuralı yürürlükte kalır; bu madde onu değiştirmez.)
5. 🔴 **YENİDEN DENEME HİÇBİR KOŞULDA `cekmeTuruCalistir()` ÇAĞIRMAZ.** Çekme yalnız kendi kapalı
   tetikleyici listesinden koşar. `K3` bayrağı (`_cekmeBekliyor`) davranışı **değişmez**.
6. Yeniden deneme **tek-uçuş kilidini** (`D4`) paylaşır: devam eden tur varken yeni tur başlatmaz.

### `D-A11-3` — `Y1` KAÇAĞI KAPATILIR (① 'den ÖNCE)

`araclar/yoklama-yasagi-kapisi.py` bugün yalnız `\bTimer(?:\.periodic)?\s*\(` arıyor ⇒ **aynı
yoklama `Future.delayed` ile yazılırsa kapı GÖRMEZ.** Kapı `Future.delayed(` / `Future<...>.delayed(`
çağrılarını da **aynı gövde kuralıyla** taramalıdır.

🔴 **Sıra pazarlıksızdır:** `D-A11-3` **önce** biter. Gerekçe: `D-A11-1` beyaz listeye bir sembol
ekliyor; kaçak açıkken eklenen kural **delik doğar** ve o deliği bir daha kimse aramaz.

🔴 **BEYAZ LİSTE DARALTILARAK genişler.** Yeni sembol (yeniden-deneme zamanlayıcısı) `turCalistir`
çağırabilir; **`cekmeTuruCalistir` ya da `SenkronAgi`'ye doğrudan dokunması KIRMIZI kalır.** Yani
`K81`'in *"gövde kuralı beyaz listedekiler dâhil herkese uygulanır"* ilkesi **kaldırılmaz**, kuralın
**yasak sembol kümesi** o tek sembol için daraltılır.

## 4. ORTAMI KİM KALDIRIR (K80 — bu spec cihaz kanıtı ister)

Kabul kriteri 7 **koşan uygulama** ister. Builder ortamı **kendi kaldırır**, sırayla:
① `docker start momentum-postgres` → `docker ps` ile **healthy görünene kadar YOKLA** (tavanlı).
② Backend ayrı, **detached** süreçte: `ASPNETCORE_ENVIRONMENT=Development` **açıkça set edilir**
(K61: aksi hâlde `NullCurrentUser` ⇒ her istek **401**), `ASPNETCORE_URLS=http://0.0.0.0:5298`.
`netstat -ano | findstr :5298` ile **LISTENING görünene kadar YOKLA**.
③ Emülatör: `emulator.exe -avd tuzak_api34` (detached), `adb devices` + `getprop sys.boot_completed`
ile **YOKLA**. `adb` PATH'te **YOKTUR**, tam yol:
`C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe`.

🔴 **Sabit `sleep` bir ölçüm değildir** — koşula kadar yoklanır, tavanlı.
🔴 **PID/cihaz adı hiçbir belgeye YAZILMAZ, ÖLÇÜLÜR.**
🔴 **Çevrimdışı kapısı `airplane_mode_on` DEĞİLDİR** — o bir bayraktır ve oturum 49'da **iki yönde
de yalan söylediği ölçüldü** (kapanışta bayrak 0,5 s'de "çevrimiçi" dedi, gerçek erişim ~12 s sonra
geldi). Kapı **uygulama katmanı probudur**: `adb shell toybox nc -w 2 10.0.2.2 5298` (cihazda `curl`
**yoktur**; `/system/bin/nc` vardır).

## 5. KAPILAR

### G22 — AĞ-DÖNÜŞ İTMESİ KAPISI (birim/widget testi, **sanal saat**; ağa çıkmaz)

`src/client/test/ag_donus_itmesi_test.dart`. Sahte `SenkronAgi` + `fakeAsync` sanal saat.

| ayak | ölçülen |
|---|---|
| `a` | kuyrukta **1 op** var, ağ taşıma hatası veriyor ⇒ **2 s**'de ikinci istek gider |
| `b` | ardışık hatalar ⇒ istek anları çizelgeye uyar (`2·5·15·30·60`), altıncıdan sonra **60 s'de sabit** |
| `c` | ağ düzelir ⇒ op gider, **kuyruk boşalır**, sanal saat **+300 s** ilerletilir ⇒ **EK İSTEK YOK** |
| `d` | başarılı itmeden sonra yeni bir op eklenir + ağ yine hata verir ⇒ ilk yeniden deneme **yine 2 s** (çizelge **sıfırlanmış**) |
| `e` | **planlama tekliği:** bekleyen zamanlayıcı varken ikinci hata gelir ⇒ toplam bekleyen zamanlayıcı **1**, istek anları **ikiye katlanmaz** |
| `f` | ağ **400** döner (taşıma hatası değil) ⇒ **yeniden deneme PLANLANMAZ** (sanal saat +300 s, ek istek yok) |
| `g` | ağ **503** döner ⇒ yeniden deneme **planlanır** |
| `h` | 🔴 yeniden deneme boyunca **`cekmeTuruCalistir` HİÇ çağrılmaz** (gönderilen her gövdede `ops` **boş değil**) |
| `i` | `durdur()`/dispose sonrası sanal saat +300 s ⇒ **ek istek YOK** (yetim zamanlayıcı yok) |

### G23 — `Y1` KAÇAK KAPISI (statik; `yoklama-yasagi-kapisi.py` altın kümesi)

| ayak | ölçülen |
|---|---|
| `a` | `Future.delayed(...) { cekmeTuruCalistir(); }` ⇒ **`Y1` ISIRIR** (bugün susuyor) |
| `b` | `Future<void>.delayed(...) { SenkronAgi... }` ⇒ **`Y1` ISIRIR** |
| `c` | beyaz liste **dışı** sembolde `Future.delayed` + `turCalistir` ⇒ **ISIRIR** |
| `d` | yeniden-deneme sembolünde `Timer` + **`turCalistir`** ⇒ **SUSAR** (daraltılmış beyaz liste) |
| `e` | 🔴 aynı sembolde `Timer` + **`cekmeTuruCalistir`** ⇒ **ISIRIR** (daraltma, muafiyet değil) |
| `f` | ilgisiz `Future.delayed` (animasyon gecikmesi, senkron sembolü geçmiyor) ⇒ **SUSAR** (yanlış-pozitif kontrolü) |

🔴 Altın küme **15 → en az 21** vakaya çıkar ve `sayi-tazeligi.py` bu sayıyı doğrulayacağı için
belgedeki *"altın küme N/M"* iddiaları **aynı turda** güncellenir.

### G24 — `D0` REGRESYON KAPISI (daraltma bir gevşetme DEĞİLDİR)

| ayak | ölçülen |
|---|---|
| `a` | `Timer.periodic(2s, cekmeTuruCalistir)` ⇒ **hâlâ KIRMIZI** (`slice-3d/M4` yeniden koşar) |
| `b` | kuyruk **boş**, hiçbir tetik yok, sanal saat +300 s ⇒ **sıfır istek** (`slice-3d/G1` `D0` ayağı bozulmadı) |
| `c` | `slice-3d` `G1`'in **tüm** `D0`/`D7` ayakları ve `slice-3e` `G12`'nin `Y1`–`Y4` ayakları **yeniden koşar ve geçer** |

## 6. MUTANTLAR

| mutant | değişiklik | kapı | beklenen |
|---|---|---|---|
| **M139** | Yeniden-deneme planlamasını tamamen kaldır | `A11/G22`/`a` | ikinci istek hiç gelmez ⇒ **KIRMIZI** |
| **M140** | Çizelgeyi sabit `2 s` yap (geri çekilme yok) | `A11/G22`/`b` | çizelge ayağı düşer ⇒ **KIRMIZI** |
| **M141** | Kuyruk boşalınca durma koşulunu kaldır | `A11/G22`/`c` | +300 s'de ek istekler görülür ⇒ **KIRMIZI** |
| **M142** | Başarıdan sonra çizelgeyi sıfırlama | `A11/G22`/`d` | ilk yeniden deneme 2 s yerine 60 s ⇒ **KIRMIZI** |
| **M143** | Planlama tekliği kontrolünü kaldır | `A11/G22`/`e` | istek anları ikiye katlanır ⇒ **KIRMIZI** |
| **M144** | 4xx'i de yeniden dene | `A11/G22`/`f` | 400'den sonra ek istek görülür ⇒ **KIRMIZI** |
| **M145** | Yeniden denemeyi `cekmeTuruCalistir`e bağla | `A11/G22`/`h` + `A11/G23`/`e` | boş `ops` gövdesi görülür **ve** statik kapı ısırır ⇒ **KIRMIZI ×2** |
| **M146** | `Y1`'den `Future.delayed` ayağını çıkar | `A11/G23`/`a`,`b`,`c` | üç ayak birden düşer ⇒ **KIRMIZI** |
| **M147** | `Y1` beyaz listesini **dosya bazlı** yap (sembol değil) | `A11/G23`/`e` | aynı dosyadaki başka sembol affedilir ⇒ **KIRMIZI** (`K81` korunuyor) |
| **M148** | `durdur()` sonrası zamanlayıcıyı iptal etme | `A11/G22`/`i` | yetim zamanlayıcı istek atar ⇒ **KIRMIZI** |
| **M149** | `Y1`'in yasak sembol kümesinden `cekmeTuruCalistir`'i çıkar — daraltmayı **gevşetmeye** çevir | `A11/G24`/`a` | `Timer.periodic(2s, cekmeTuruCalistir)` yeşil geçer ⇒ **KIRMIZI**. Bu mutant `D-A11-1`'in *daraltma* olduğunu, gevşetme OLMADIĞINI kanıtlar |
| **M150** | Yeniden-deneme zamanlayıcısını **koşulsuz** kur (kuyruk boş olsa bile) | `A11/G24`/`b` | kuyruk boşken +300 s'de istek görülür ⇒ **KIRMIZI**. `M141`'den farkı: `M141` *boşaldıktan sonra durmamayı*, bu *hiç iş yokken başlamayı* ölçer |

## 6b. MUTANT BORCU

- **`A11/G22`/`g` (503 ⇒ yeniden dene) ayağının kendi mutantı YOKTUR.** Gerekçe: `M144`'ün aynası
  olurdu ve `M144` zaten *"hangi hata sınıfı yeniden denenir"* ayrımının **her iki yönünü** ölçüyor
  (4xx yeniden denenirse KIRMIZI ⇒ sınıf ayrımı gerçekten yük taşıyor). Ayrı mutant **yeni bilgi
  vermez**; `CLAUDE.md` K53/3 gereği bu **statik/widget** sınıfında tavan yoktur ama **gereksiz
  mutant da bedeldir**. Borç bilinçlidir ve buraya yazılmıştır.

## 7. KABUL KRİTERLERİ (sırayla; her biri KANIT üretir)

1. `python araclar\yoklama-yasagi-kapisi.py --altin-kume` ⇒ **EXIT 0**, vaka sayısı **≥ 21**.
2. `python araclar\yoklama-yasagi-kapisi.py .` ⇒ **EXIT 0** (ürün kodu temiz).
3. `flutter analyze --fatal-infos` ⇒ **No issues found**.
4. `flutter test` ⇒ **hepsi yeşil**, sayı **485'ten büyük** (yeni `A11/G22` ayakları).
5. `M139`–`M148` sırayla uygulanır, her biri beklenen kapıyı **KIRMIZI** yapar, sonra dosya
   **bayt-özdeş** geri alınır ve temiz koşum **tekrar EXIT 0** verir.
6. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A11-ag-donus-itmesi.md` ⇒ **EXIT 0**.
   🔴 Araç **dizin kabul etmez**, **dosya yoluyla** çağrılır (`K81`).
7. 🔴 **CİHAZDA UÇTAN UCA (ölçüm, beyan değil):** §4'teki üç adım kaldırılır; uçak modu **TCP probuyla**
   doğrulanarak açılır, **iki görev** eklenir, **30 s** sunucuda görünmediği ölçülür, uçak modu
   kapatılır ve **uygulamaya HİÇ DOKUNULMADAN** kuyruğun boşaldığı ölçülür.
   **Kabul: 90 s içinde, elle yenileme OLMADAN.** Ekran görüntüsü + `uiautomator` dökümü + API JSON.
8. `python araclar\verify.ps1` ⇒ **EXIT 0** (backend'e dokunulmadığının kanıtı).

## 8. YASAKLAR (bu dilimde)

1. 🔴 **Yeni bağımlılık eklemek YASAK** — `connectivity_plus` ve benzeri. (Gerekirse ayrı dilim +
   lisans/CVE kapısı; kırmızı çizgi 3.)
2. 🔴 **`cekmeTuruCalistir()`'i herhangi bir zamanlayıcıya bağlamak YASAK** — `D0`'ın çekirdeği budur.
3. 🔴 **`Y1`'i susturmak, muafiyet eklemek ya da beyaz listeyi dosya bazına çevirmek YASAK** (`M147`).
4. 🔴 **Backend senkron çekirdeğine dokunmak YASAK** — bu dilim **yalnız istemci + araç**.
5. 🔴 **`DESIGN.md`'ye tek bayt yazmak YASAK** (`K46`).
6. 🔴 **Kapıyı `Future.delayed` ile atlatmak YASAK** — kaçağı kapatan spec, kaçağı kullanamaz.
7. **Ölçmediğini "temiz" sayma.** Ölç ya da **`[DOĞRULANMADI]`** yaz.

## 9. BEYAN EDİLMİŞ SINIRLAR (spec yazılırken bilinen, gizlenmeyen)

1. 🔴 **Gerçek fiziksel cihaz ölçülmüyor.** Emülatör NAT'ı kurulu soketi koruduğu için SignalR
   yeniden bağlanma yolu **hiç egzersiz edilmedi**; gerçek cihazda `SinyalBaglandi`'nin ateşlenip
   ateşlenmediği **`[DOĞRULANMADI]`**. Bu spec o yola **bağımlı değildir** — bilerek.
2. 🔴 **Keepalive canlılık borcu kapatılmıyor.** `{"type":6}` 15 s'de bir **yalnız gönderiliyor**,
   sunucu yanıtına **zaman aşımı yok** ⇒ ölü ama "açık" görünen soket sessizce sinyal taşımayı
   bırakabilir. Ayrı dilim.
3. **Çakışma rozeti ve çift yönün kabul kriterleri** bu dilimin konusu **değildir**.
4. **En kötü hâl maliyeti beyan edilmiştir:** uygulama açık, kuyruk dolu ve ağ kalıcı olarak
   kapalıysa **60 s'de bir** bir istek denenir. Bu, `D0`'ın pil gerekçesine karşı **bilinçli** ve
   sınırlı bir ödemedir; kuyruk boşalır boşalmaz **sıfıra** iner.
5. `duzenle`/`sil` yolları arayüzde açık olmadığı için `onYerelYazma` sarmalayıcısı onları hâlâ
   kapsamıyor (oturum 48 borcu) — bu spec o borcu **kapatmaz**.
