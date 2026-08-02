# GOREV-A11 v2.3 — AĞ-DÖNÜŞ İTMESİ (`D0` DARALTMASI) + `Y1` KAÇAĞININ KAPATILMASI

> **Durum:** KİLİT ADAYI (v2). Onur **dört** kilit verdi (2 Ağu 2026, oturum 49).
> **Build: Claude Code. Ölçüm/denetim: Cowork (K26).** Araç onarımı bilerek **yazan elden ayrı ele**
> verilmiştir (`K34-f`; oturum 47'de `A9c` aynı yolu izledi).
>
> 🔴 **v1 GEÇERSİZDİR.** Bağımsız denetim v1'de **altı bloker** buldu; biri (**`B3`**) düzeltmenin
> **hatayı KÖTÜLEŞTİRDİĞİNİ** gösterdi. v2 hepsini karşılar ve hangi maddenin hangi blokerden
> doğduğu **satır satır** yazılıdır — sessizce düzeltilen bir bloker sonraki turda yeniden doğar.

## 1. NE OKUNUR

`DURUM.md` · `CLAUDE.md` · `ORTAM.md` · **`KANIT/cevrimdisi-senkron/01-OLCUM-OZETI.md`** ·
`GOREV-slice-3d-cekme.md` §3 `D0`/`D9` ve §5 `G1` · `araclar/yoklama-yasagi-kapisi.py` ·
`src/client/lib/veri/senkron_dongusu.dart`. `PROJE_HAFIZA.md`'yi **açma**; gerekçe `K115`/`K116`.

🔴 Kapı kimlikleri **spec-yereldir** (`K108`): **daima `A11/G22`** biçiminde atıf yapılır.

## 2. NEDEN — ÖLÇÜLMÜŞ KÖK NEDEN

Oturum 49, emülatör: uçak modunda iki görev eklendi, **30 s sunucuya sızmadı** (doğru), ağ **4,4 s**'de
döndü, **uygulama ön plandayken 90 s kuyruk boşalmadı**; *"Yenile"* ile **2,2 s**. Kök neden koddan
ölçüldü: itmenin **üç** tetikleyicisi var (`main.dart:55`, `:81`, `:94`); `main.dart:150` sinyal
dinleyicisi **yalnız çekme** koşar; `pubspec`'te ağ-durumu paketi **yok**. ⇒ *"ağ geri geldi"*
tetikleyicisi **hiç tasarlanmamıştır** — K112'nin kardeşi kapsam boşluğu.

🔴 **ÇÜRÜTÜLMÜŞ ŞIK (tekrar önerilmesin):** *"`SinyalBaglandi`'yi itme tetikleyicisi yap"* — logcat o
pencerede **ne kopma ne yeniden bağlanma** gösterdi, sonrasında **`Changed alindi` geldi** ⇒ soket
hiç kopmadı; emülatör NAT'ı **kurulu** bağlantıyı koruyor. O yol **hiç egzersiz edilmedi**.

## 3. KİLİTLİ KARARLAR (Onur — pazarlığa kapalı)

### `D-A11-1` — `D0` DARALTILDI
*"Periyodik **ÇEKME** yasak"*: zamanlayıcıyla `cekmeTuruCalistir()` çağırmak **KIRMIZI kalır**.
**TEK İSTİSNA:** kuyrukta **bekleyen** satır varken **başarısız** bir **itme** turu, tavanlı geri
çekilmeyle yeniden denenebilir. Gerekçe: `D0`'ın kendi yazılı gerekçesi *(pil + sunucu yükü + 3e'yi
sahte karşılamak)* bunu kapsamaz — yeniden deneme yalnız **gönderilmemiş iş varken** koşar ve
**hiçbir koşulda çekmez**.

> 🔴 **`M6` KARŞILIĞI — KANONİK-KOPYA UYARISI.** `D0`'ın metni `GOREV-slice-3d-cekme.md`'de **iki**
> yerde geçer (§2 satır 174, §3 satır 225-227) ve o dosya **`K70` ile KİLİTLİDİR** (`889A383F`,
> `tek-kopya-kapisi.py` kapsamında). ⇒ **O dosyaya tek bayt yazılmaz.** Daraltmanın kanonik metni
> `DURUM.md` §5 + `PROJE_HAFIZA.md` `K116`'dır. **BEYAN EDİLMİŞ BEDEL:** yalnız `slice-3d`'yi okuyan
> biri **bayat** metni görür; bu bilinçli takastır (kilidi bozmak daha pahalı) ve `DURUM.md` §5
> bu spec'e adıyla atıf yapar.

### `D-A11-2` — YENİDEN DENEME SÖZLEŞMESİ
1. **Çizelge:** `2s · 5s · 15s · 30s · 60s`, sonrası **60 s'de sabit**. Jitter **±%20**.
   🔴 **`M7` karşılığı:** `Random` **enjekte edilebilir** olur (`signalr_json_sinyal.dart` yapıcısındaki
   kabul edilmiş desenin aynısı) ⇒ test **pencere değil KESİN eşitlik** ölçer.
2. **Planlama tekliği:** aynı anda **en fazla BİR** bekleyen zamanlayıcı.
3. **ÇİZELGE SIFIRLAMA:** ① başarılı itme ② **yeni yerel yazma** (taze kullanıcı niyeti — v1'de
   yoktu, denetimin `MINOR`'ı). Sıfırlama bekleyen zamanlayıcıyı **iptal edip yeniden kurar**.
4. **DURMA:** kuyruk boşaldı · itme başarılı · `durdur()`.
5. 🔴 **YALNIZ TAŞIMA HATASI ve `5xx` yeniden denenir.** **`408`/`429` KAPSAM DIŞIDIR** — bugün
   `_httpHatasiIsle` onları *401-olmayan 4xx* dalına atıp rozeti `cakisma` yapıyor; bunu değiştirmek
   **`D9`'un kilitli sınıflandırmasına** dokunur ve bu dilimin konusu değildir. **Borç** (§6b).
6. 🔴 **YENİDEN DENEME HİÇBİR KOŞULDA `cekmeTuruCalistir()` ÇAĞIRMAZ.** `K3` bayrağı değişmez.
7. Tek-uçuş kilidini (`D4`) paylaşır.

### `D-A11-4` — TAŞIMA HATASI `denemeSayisi`'NI ARTIRMAZ  🔴 **[`B3` — YENİ KİLİT, Onur]**
`senkron_dongusu.dart:22` `_denemeTavani = 8`; bugün **her** başarısız tur `denemeSayisi++` yapar ve
aşınca satır **`zehirli`** + rozet **`cakisma`** olur. `D-A11-2` çizelgesiyle **9.** başarısızlık
nominal **t≈292 s** ⇒ **~5 dakikadan uzun bir kesinti kuyruğu KALICI zehirler ve ağ dönse de bir daha
gitmez.** Düzeltme, düzeltmediği kusurdan **daha kötü** olurdu.

**KİLİT:** `denemeSayisi` *"bu op sunucuda kabul edilemiyor"* sayacıdır. **Taşıma hatasında op
sunucuya HİÇ ULAŞMAMIŞTIR ⇒ değerlendirilmemiştir ⇒ sayaç ARTMAZ.** `5xx` de artırmaz (sunucu
op'u reddetmedi, hizmet veremedi). 🔴 **[v2.1 DÜZELTMESİ — builder yakaladı]** **`401` sayacı ARTIRMAYA DEVAM EDER** ve zehirli-op
korumasını **tek başına canlı tutan yol budur**. **`401`-dışı `4xx` (400/408/429…) zaten HİÇ
artırmıyordu** — `D9`'un **kilitli** hâli budur (`slice-3d` §3:215-216, `K70` ile kilitli dosya) ve
**değişmeden kalır**. v2'nin *"4xx sayacı artırmaya devam eder"* cümlesi **YANLIŞTI**.
🔴 Bu **`D9`'un daraltılmasıdır** ve `A11` öncesinde de bir kusurdu; yalnız itme seyrek tetiklendiği
için **görünmüyordu**. `A11` onu görünür ve kaçınılmaz yapardı.

### `D-A11-3` — `Y1` KAÇAĞI KAPATILIR (① 'den ÖNCE) 🔴 **[`B6` genişletildi, Onur]**
1. Kapı `Future.delayed(` / `Future<...>.delayed(` çağrılarını da tarar.
2. 🔴 **GÖVDE KURALI ÇAĞRININ PARANTEZİNDEN, KAPSAYAN FONKSİYON/KAPANIŞ GÖVDESİNE TAŞINIR.** Bugün
   kural yalnız `metin[m.start():kapa_idx+1]` aralığına bakıyor ⇒ şu **en doğal iki yoklama biçimi
   KAÇIYOR**: `while (true) { await Future.delayed(d); await cekme(); }` ve
   `Future.delayed(d).then((_) => cekme());`. Sadece `Future.delayed` eklemek altın kümeyi
   **yeşil yakıp kaçağı açık bırakırdı** — spec'in kendi cümlesinin ihlali.
3. **Yanlış-pozitif bedeli beyan edilir:** kapsam genişlediği için altın küme **yanlış-pozitif
   kontrol vakaları taşımak ZORUNDADIR** (animasyon gecikmesi, senkronla ilgisiz `.then`).

### `D-A11-5` — RETRY **KENDİ DOSYASINDA VE KENDİ SINIFINDA** YAŞAR 🔴 **[`B5`]**
`Y1` beyaz listesi **(dosya, kapsayan sınıf)** çiftidir. Retry `SenkronDongusu`'nun içine konursa
**senkron çekirdeğinin tamamı** 1. bacaktan muaf olur ve `Timer.periodic(2s, () => turCalistir())`
(periyodik **itme** yoklaması) yeşil geçer — `K81`'in *"dosya bütününü affetme"* gerekçesinin sınıf
ölçeğinde tekrarı.
**KİLİT:** yeni sınıf **`ItmeYenidenDeneme`**, yeni dosya **`lib/veri/itme_yeniden_deneme.dart`**.
Beyaz liste girdisi **yalnız** `("itme_yeniden_deneme.dart", "ItmeYenidenDeneme")`. `SenkronDongusu`
beyaz listeye **GİRMEZ** ve tüm kapı bacaklarına tabi kalır.
🔴 O sembolde bile: **`turCalistir` izinli**; `cekmeTuruCalistir`, `SenkronAgi` ve
**`_yuvarlakDongusu`** yasak kalır (denetim `B5`: 2. bacak yalnız üç *literal* ad arıyordu, özel
metot adıyla periyodik çekme yazılabiliyordu).

### `D-A11-6` — PLANLAMA, HATA SINIFININ **BİLİNDİĞİ YERDE** YAPILIR 🔴 **[`B4`]**
`turCalistir()` `Future<void>` döndürür ve sonucu **yutar**; `D4` gereği **başkasının** turunun
future'ını döndürebilir ⇒ çağıran taraf hata sınıfını **göremez**. Bu yüzden retry **çağırandan
planlanmaz**: `SenkronDongusu` hata sınıfını zaten `_httpHatasiIsle` içinde biliyor ve orada
`ItmeYenidenDeneme.planla(...)` / `.iptal()` çağrılır. **`SenkronDongusu`'nun genel API'si
DEĞİŞMEZ** (v1 var olmayan bir gözlem noktası varsayıyordu).

## 4. ORTAMI KİM KALDIRIR (K80)

① `docker start momentum-postgres` → `docker ps` **healthy görünene kadar YOKLA** (tavanlı).
② Backend **detached**: `ASPNETCORE_ENVIRONMENT=Development` **açıkça** (K61 — aksi hâlde her istek
401), `ASPNETCORE_URLS=http://0.0.0.0:5298`; `netstat -ano | findstr :5298` **LISTENING görünene
kadar YOKLA**. ③ Emülatör detached; `adb devices` + `getprop sys.boot_completed` ile **YOKLA**.
`adb` PATH'te **YOK**: `C:\Users\gulci\AppData\Local\Android\Sdk\platform-tools\adb.exe`.

🔴 **Sabit `sleep` bir ölçüm değildir.** 🔴 **PID hiçbir belgeye yazılmaz, ölçülür.**
🔴 **Çevrimdışı kapısı `airplane_mode_on` DEĞİLDİR** — oturum 49'da **iki yönde de yalan söylediği**
ölçüldü. Kapı: `adb shell toybox nc -w 2 10.0.2.2 5298` (cihazda `curl` **yok**).

## 5. KAPILAR

### G22 — AĞ-DÖNÜŞ İTMESİ (birim testi, `fakeAsync` sanal saat; ağa çıkmaz)

`src/client/test/ag_donus_itmesi_test.dart`. Sahte `SenkronAgi` (`test/destekler/sahte_senkron_agi.dart`
**mevcut**) + **enjekte edilmiş seed'li `Random`**.
🔴 **`B2` KARŞILIĞI — GÖZLEM NOKTASI İSTEK DEĞİL, ZAMANLAYICIDIR.** `turCalistir()` kuyruk boşken
`_agi.gonder`'e **hiç gitmez** (`senkron_dongusu.dart:131`), bu yüzden *"ek istek görülür"* biçiminde
yazılan her ayak **ölçmez**. Ayaklar `fakeAsync.pendingTimers` / `nonPeriodicTimerCount` **ve**
sahte ağın çağrı sayacı ile **birlikte** ölçülür.

| ayak | ölçülen |
|---|---|
| `a` | kuyrukta 1 op, taşıma hatası ⇒ **tam 2 s**'de ikinci istek (seed sabit ⇒ **kesin eşitlik**) |
| `b` | ardışık hatalar ⇒ istek anları `2·5·15·30·60`, altıncıdan sonra **60 s'de sabit** |
| `c` | ağ düzelir ⇒ op gider, kuyruk boşalır, +300 s ⇒ **`pendingTimers` BOŞ** ve ek istek yok |
| `d` | başarı sonrası yeni op + hata ⇒ ilk yeniden deneme **yine 2 s** (çizelge sıfırlandı) |
| `e` | bekleyen zamanlayıcı varken ikinci hata ⇒ **`nonPeriodicTimerCount == 1`** |
| `f` | ağ **400** ⇒ +300 s'de **`pendingTimers` BOŞ** (planlanmadı) |
| `g` | ağ **503** ⇒ yeniden deneme **planlanır** (`pendingTimers` dolu) |
| `h` | yeniden deneme boyunca gönderilen her gövdede **`ops` boş değil** (çekme yok) |
| `i` | `durdur()` sonrası +300 s ⇒ **`pendingTimers` BOŞ** (yetim zamanlayıcı yok) |
| `j` | 🔴 **`D-A11-4`:** 12 ardışık **taşıma** hatası ⇒ satır **`bekliyor`** kalır, `denemeSayisi` **artmaz**, rozet **`cakisma` OLMAZ** |
| `k` | 🔴 **`D-A11-4` sınırı [v2.1'de `400` → `401` DÜZELTİLDİ]:** ardışık **`401`** ⇒ `denemeSayisi` **artar**, 9'da satır **`zehirli`** + `sonHataKodu='deneme-tavani'` + rozet `cakisma`. **Bu ayak `A11`'in en riskli yan etkisini ölçer:** `D-A11-4` taşıma ve `5xx`'i sayaçtan muaf tuttuğuna göre, sayacı canlı tutan **başka bir yol kalmalıdır** — yoksa `_denemeTavani = 8` **ölü kod** olur ve zehirli-op koruması sessizce kaybolur |
| `l` | 🔴 **`D-A11-2`/3:** bekleyen 60 s'lik zamanlayıcı varken **yeni yerel yazma** ⇒ iptal edilir, yeni deneme **2 s**'de |
| `m` | 🔴 **[v2.3 — builder ÜÇÜNCÜ kez yakaladı] ÇOK-YUVARLAKLI TUR, `hasMore` İLE DEĞİL TOPLU GÖNDERİM TAVANIYLA.** Kurulum: **101 bekleyen op** (`_bekleyenleriSec()` `..limit(100)` taşır, `:220`) ve tur **retry'dan** gelir (indeks > 0). 1. yuvarlak: 100 op gider, `SenkronBasarili` (**`hasMore` GEREKMEZ**) ⇒ `:182` `sifirla()` ⇒ indeks **0**. 2. yuvarlak: `_bekleyenleriSec()` **kalan 1 op**'u seçer ⇒ `secilenler` **BOŞ DEĞİL** ⇒ taşıma hatası ⇒ `:205` guard'ı **geçer** ⇒ `planla()` **2 s**'den. `M142` ile indeks 1'de kalır ⇒ **5 s**. Seed sabit ⇒ **kesin eşitlik**. 🔴 **v2.2'nin `hasMore` kurulumu ERİŞİLEMEZDİ:** 1. sayfada tek op `Applied` olup silindiğinden 2. yuvarlakta `secilenler` **boş** kalıyor ve `:205`'in `secilenler.isNotEmpty` guard'ı `planla()`'yı **hiç çağırmıyordu** |

### G23 — `Y1` KAÇAK KAPISI (statik; `yoklama-yasagi-kapisi.py` altın kümesi)

| ayak | ölçülen |
|---|---|
| `a` | `Future.delayed(d, () => cekmeTuruCalistir())` ⇒ **ISIRIR** |
| `b` | `Future<void>.delayed(...)` + `SenkronAgi` ⇒ **ISIRIR** |
| `c` | 🔴 `while (true) { await Future.delayed(d); await cekmeTuruCalistir(); }` ⇒ **ISIRIR** (kapsayan gövde) |
| `d` | 🔴 `Future.delayed(d).then((_) => cekmeTuruCalistir())` ⇒ **ISIRIR** (kapsayan gövde) |
| `e` | `ItmeYenidenDeneme` sembolünde `Timer` + **`turCalistir`** ⇒ **SUSAR** |
| `f` | 🔴 aynı sembolde `Timer` + **`cekmeTuruCalistir`** ⇒ **ISIRIR** (daraltma, muafiyet değil) |
| `g` | 🔴 aynı sembolde `Timer` + **`_yuvarlakDongusu(kuyrugaBak: false)`** ⇒ **ISIRIR** (özel metot kaçağı) |
| `h` | `itme_yeniden_deneme.dart`'ta **başka** sınıfta `Timer` ⇒ **ISIRIR** (`K81` dosya bütünü affedilmez) |
| `i` | ilgisiz `Future.delayed` (animasyon) ⇒ **SUSAR** — yanlış-pozitif kontrolü |
| `j` | ilgisiz `.then` zinciri (senkron sembolü geçmiyor) ⇒ **SUSAR** — yanlış-pozitif kontrolü |

### G24 — `D0` REGRESYON KAPISI (daraltma bir gevşetme DEĞİLDİR)

🔴 **`B1` KARŞILIĞI:** v1'de bu kapının mutantı `Y1`'i değiştiriyordu ama `G24`/`a`'nın dayanağı
`slice-3d/M4` **Dart birim testidir** ⇒ mutant hayatta kalıyordu (kör kapı). v2'de her ayak
**hangi araçla** ölçüldüğü yazılarak ayrıştırılmıştır.

| ayak | araç | ölçülen |
|---|---|---|
| `a` | **Dart testi** | `Timer.periodic(2s, cekmeTuruCalistir)` ⇒ `slice-3d/G1` sanal saat ayağı **hâlâ KIRMIZI** |
| `b` | **Dart testi** | kuyruk **boş**, hiç tetik yok, +300 s ⇒ **sıfır istek ve `pendingTimers` BOŞ** |
| `c` | **statik araç** | `SenkronDongusu` beyaz listeye **girmemiştir**: o sınıfa `Timer` eklenirse `Y1` **ISIRIR** |
| `d` | **zincir** | `slice-3d` `G1`'in tüm `D0`/`D7` ayakları + `Y1`–`Y4` bacakları **yeniden koşar ve geçer** |

## 6. MUTANTLAR

| mutant | değişiklik | kapı | beklenen |
|---|---|---|---|
| **M139** | Yeniden-deneme planlamasını kaldır | `A11/G22`/`a` | ikinci istek gelmez ⇒ **KIRMIZI** |
| **M140** | Çizelgeyi sabit `2 s` yap | `A11/G22`/`b` | çizelge ayağı düşer ⇒ **KIRMIZI** |
| **M141** | Kuyruk boşalınca **zamanlayıcıyı iptal etme** | `A11/G22`/`c` | `pendingTimers` dolu kalır ⇒ **KIRMIZI** |
| **M142** | Başarı dalındaki `sifirla()`'yı kaldır (`_yuvarlakDongusu` `SenkronBasarili` dalı) | `A11/G22`/**`m`** | **[v2.2]** çok-yuvarlaklı turda 2. yuvarlak hata verince `planla()` **5 s**'den başlar (2 s yerine) ⇒ **KIRMIZI**. 🔴 v2'de bu mutant `G22`/`d`'ye bağlıydı ve **EŞDEĞERDİ** — builder ölçtü ve haklıydı: `d`'de bir sonraki hata **dışarıdan** gelen çağrıdan doğuyor ve o çağrı zaten koşulsuz sıfırlıyor. Kaçırılan yol **boşaltma döngüsüdür**: `sifirla()` (`:182`) ve `planla()` (`:205`) **aynı turda** ateşlenebilir |
| **M143** | Planlama tekliği kontrolünü kaldır | `A11/G22`/`e` | `nonPeriodicTimerCount == 2` ⇒ **KIRMIZI** |
| **M144** | `400`'ü de yeniden dene | `A11/G22`/`f` | `pendingTimers` dolu ⇒ **KIRMIZI** |
| **M145** | Yeniden denemeyi `cekmeTuruCalistir`e bağla | `A11/G22`/`h` + `A11/G23`/`f` | boş `ops` **ve** statik kapı ⇒ **KIRMIZI ×2** |
| **M146** | `Y1`'den `Future.delayed` ayağını çıkar | `A11/G23`/`a`,`b` | iki ayak düşer ⇒ **KIRMIZI** |
| **M147** | `Y1` beyaz listesini **dosya bazlı** yap | `A11/G23`/`h` | başka sınıf affedilir ⇒ **KIRMIZI** (`K81`) |
| **M148** | `durdur()`'da zamanlayıcıyı iptal etme | `A11/G22`/`i` | yetim zamanlayıcı ⇒ **KIRMIZI** |
| **M149** | 🔴 Gövde kuralını **çağrı parantezine** geri al | `A11/G23`/`c`,`d` | `while`/`.then` kaçakları yeşil geçer ⇒ **KIRMIZI** |
| **M150** | 🔴 Yasak kümesinden `_yuvarlakDongusu`'nu çıkar | `A11/G23`/`g` | özel metotla periyodik çekme yeşil geçer ⇒ **KIRMIZI** |
| **M151** | 🔴 `SenkronDongusu`'nu beyaz listeye ekle | `A11/G24`/`c` | senkron çekirdeği muaf olur ⇒ **KIRMIZI** |
| **M152** | 🔴 Taşıma hatasında `denemeSayisi`'nı **artır** (`D-A11-4` iptal) | `A11/G22`/`j` | 12 hatada `zehirli` + `cakisma` ⇒ **KIRMIZI** |
| **M153** | 🔴 [v2.1] `401` dalındaki `sayaciArtir: true`'yu **`false`** yap (aşırı daraltma) | `A11/G22`/`k` | sayacı artıran **son** yol da kapanır, `denemeSayisi` **ölü sayaç** olur ⇒ **KIRMIZI** |
| **M154** | 🔴 Yerel yazmada çizelge sıfırlamayı kaldır | `A11/G22`/`l` | yeni görev 60 s bekler ⇒ **KIRMIZI** |
| **M155** | 🔴 `Y1` **her** `Future.delayed`'ı ısırsın (aşırı genişleme) | `A11/G23`/`i`,`j` | animasyon gecikmesi ısırılır ⇒ **KIRMIZI** (kapı gürültüye dönüşmedi) |

## 6b. MUTANT BORCU — **BOŞ, VE BU BOŞLUK ÖLÇÜLMÜŞTÜR**

🔴 **YENİ BULGU — `spec-kapi-kapsama.py`'NİN KURAL ENVANTERİ YAPISAL OLARAK DAR.**
Araç kural adlarını yalnız §5 tablolarının **ilk sütunundan** ve yalnız şu biçimlerde tanır:
`D<TEK HANE>` · `A11Y-<hane>` · sabit `kontrast`/`metin` (`spec-kapi-kapsama.py:52-83`).
⇒ **`D-A11-2` gibi spec-yerel karar adları envantere HİÇ GİREMEZ** — dahası `\bD(\d)\b` deseni
yüzünden **`D10` ve sonrası da göremez**. Bu spec'in kararları §3'te ve `D-A11-n` adlıdır ⇒ araç
için **kural envanteri BOŞTUR** ve §6b mekanizması bu spec'e **uygulanamaz**.

**Ölçülerek doğrulandı:** ilk yazımda iki borç bu bölüme yazıldı ve araç ikisini de doğru biçimde
**okudu** (denetimin `M2` bulgusu böylece kapandı) ama **`[S6] GEREKSİZ BORÇ — envanterde böyle bir
kural yok`** dedi. Araç haklıydı: envanterinde olmayan bir kurala borç yazmak **hayalet borçtur**.
Borçlar bu yüzden **§9'a** (beyan edilmiş sınırlar) taşındı — gizlenmedi, **doğru rafa kondu**.

🔴 **BU KÖRLÜK `Y1` KAÇAĞININ KARDEŞİDİR ve bu dilimde KAPATILMIYOR:** `K108` kapı kimliklerini
spec-yerel ilan ettiğinden bundan sonraki her spec kendi karar adlarını kullanacak; o hâlde aracın
**kural yarısı yeni spec'lerin hiçbirinde çalışmayacak** ve her koşumda `KURAL (0)` yazıp **EXIT 0**
verecek — yani *"mutantsız kural yok"* hükmü **boşluğa** verilecek. Bu bir **borçtur** ve `A11`'in
kapsamına **bilerek alınmamıştır** (üç araç onarımı bir dilime sığmaz); Onur'un kilidi beklenir.

## 7. KABUL KRİTERLERİ (sırayla)

0. 🔴 **YÜRÜYEN İSKELET ADIMI (K53/5) — `M4` KARŞILIĞI.** Bu repoda `fakeAsync` ile **drift** hiç
   birlikte koşmadı (`g1_cekme_yolu_kapisi_test.dart` *"sanal saat"* dediği ayağı **gerçek 200 ms**
   `Future.delayed` ile yazmış; `signalr_json_sinyal.dart:121-133` ölçülmüş bir `fakeAsync`
   anomalisi kaydediyor). ⇒ **Önce tek bir ayak yazılır** (`G22`/`a`) ve `fakeAsync` + drift'in
   birlikte koştuğu **ölçülür**. Koşmuyorsa **DUR ve Onur'a sor** — kalan ayaklar yazılmaz.
1. `python araclar\yoklama-yasagi-kapisi.py --altin-kume` ⇒ **EXIT 0**, vaka **≥ 25**.
2. `python araclar\yoklama-yasagi-kapisi.py .` ⇒ **EXIT 0**.
3. `flutter analyze --fatal-infos` ⇒ **No issues found**.
4. `flutter test` ⇒ hepsi yeşil, sayı **485'ten büyük**.
5. `M139`–`M155` **hepsi** sırayla uygulanır (v1 yalnız `M139`–`M148` diyordu — denetimin `B1`
   bulgusu), her biri beklenen kapıyı **KIRMIZI** yapar, dosya **bayt-özdeş** geri alınır, temiz
   koşum **tekrar EXIT 0**.
6. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A11-ag-donus-itmesi.md` ⇒ **EXIT 0**.
   🔴 Araç **dizin kabul etmez**. **Beyan edilmiş sınır (`M1`):** bu araç **ayak** granülerliğinde
   ölçmez; ayak-mutant eşlemesi **insan denetiminin** işidir.
7. 🔴 **CİHAZDA UÇTAN UCA — `M5` KARŞILIĞI (pay ölçülerek).** §4'teki üç adım kaldırılır. Uçak modu
   **TCP probuyla** doğrulanarak açılır, iki görev eklenir, **30 s** sızıntı olmadığı ölçülür.
   🔴 **Çevrimdışı pencere en az 180 s tutulur** ki çizelge **60 s platosuna gerçekten çıksın** (en
   kötü hâli egzersiz etmeyen bir kabul, kabul değildir). Sonra uçak modu kapatılır ve **saat,
   bayraktan değil `nc` probunun `true` döndüğü andan** başlatılır. **Kabul: 120 s içinde, uygulamaya
   HİÇ DOKUNULMADAN kuyruk boşalır.** *(Pay hesabı: plato 60 s × jitter 1,2 = 72 s.)*
   Ayrıca **rozet `cakisma` OLMAMALIDIR** (`D-A11-4`'ün cihazdaki kanıtı).
8. `powershell -File araclar\verify.ps1` ⇒ **EXIT 0**. 🔴 **`M8` karşılığı:** v1 `python` ile
   çağırıyordu; bu dosya **PowerShell** betiğidir.

## 8. YASAKLAR

1. 🔴 **Yeni bağımlılık YASAK** (`connectivity_plus` vb. — kırmızı çizgi 3).
2. 🔴 **`cekmeTuruCalistir()`'i herhangi bir zamanlayıcıya bağlamak YASAK.**
3. 🔴 **`Y1`'i susturmak / muafiyet eklemek / beyaz listeyi dosya bazına çevirmek YASAK.**
4. 🔴 **`SenkronDongusu`'nu `Y1` beyaz listesine eklemek YASAK** (`D-A11-5`).
5. 🔴 **Backend'e ve `GOREV-slice-3d-cekme.md`'ye dokunmak YASAK** (ikincisi `K70` ile kilitli).
6. 🔴 **`DESIGN.md`'ye tek bayt yazmak YASAK** (`K46`).
7. 🔴 **Kapıyı `Future.delayed` ile atlatmak YASAK.**
8. **Ölçmediğini "temiz" sayma.** Ölç ya da **`[DOĞRULANMADI]`** yaz.

## 9. BEYAN EDİLMİŞ SINIRLAR

1. 🔴 **Gerçek fiziksel cihaz ölçülmüyor** — emülatör NAT'ı yeniden bağlanma yolunu maskeledi.
2. 🔴 **Keepalive canlılık borcu kapanmıyor:** `{"type":6}` yalnız gönderiliyor, yanıta zaman aşımı yok.
3. 🔴 **`durdur()` bugün YOK** (`senkron_dongusu.dart`'ta yalnız yorumlarda geçiyor) ve `main.dart`'ın
   dispose yolu yoktur. Bu spec `durdur()`'u **ister**; üretimde onu çağıracak bir yaşam-döngüsü
   kancası **eklenmez** ⇒ `G22`/`i` bugün **yalnız testte** anlamlıdır. **Borç, ayrı dilim.**
4. **En kötü hâl maliyeti:** uygulama açık + kuyruk dolu + ağ kalıcı kapalı ⇒ **60 s'de bir** istek.
   Kuyruk boşalınca **sıfıra** iner. `D-A11-4` sayesinde bu **zehirlenmeye yol açmaz**.
5. 🔴 **`408`/`429` KAPSAM DIŞI.** Bugün `_httpHatasiIsle` onları *401-olmayan 4xx* dalına atıp
   rozeti `cakisma` yapıyor; *yeniden denenebilir* ilan etmek **`D9`'un KİLİTLİ sınıflandırmasına**
   dokunur ve Onur bu dilimde onu kilitlemedi. **Ayrı dilim.** *(Bu madde §6b'den buraya taşındı:
   araç envanterinde `D-A11-n` diye bir kural olmadığı için orada **hayalet borç** sayılıyordu.)*
9. 🔴 **`A11/G24`/`d` mutantsızdır.** O ayak yeni davranış değil, `slice-3d/G1` ve `Y1`–`Y4`
   kapılarının **yeniden koşumudur**; kendi mutantı onların mutantlarının kopyası olur, yeni bilgi
   vermezdi. *(Bu da §6b'den taşındı, aynı sebeple.)*
10. 🔴 **`spec-kapi-kapsama.py`'nin kural yarısı bu spec'te ÖLÜDÜR** (§6b'de ölçüldü): envanteri
   yalnız `D0`–`D9`/`A11Y-<hane>` tanır, `D-A11-n`'i göremez ⇒ `KURAL (0)` yazıp **EXIT 0** verir.
   Kabul kriteri 6'nın *kural* bacağı bu spec için **hiçbir şey ölçmez**. Borç; `A11` kapsamında değil.
6. **Çakışma rozeti ve çift yönün kabul kriterleri** bu dilimin konusu değildir.
7. `duzenle`/`sil` yolları `onYerelYazma` sarmalayıcısına hâlâ bağlı değil (oturum 48 borcu).
12. 🔴 **v2.3 ERRATA — BUILDER ÜÇÜNCÜ KEZ YAKALADI (`G22`/`m` erişilemezdi).** v2.2'nin
    `hasMore`'lu kurulumunda 1. sayfadaki tek op `Applied` olup **silindiği** için 2. yuvarlakta
    `_bekleyenleriSec()` **boş** dönüyor; `:205`'teki `if (kuyrugaBak && secilenler.isNotEmpty)`
    guard'ı `planla()`'yı **hiç çağırmıyordu**. Senaryo **101 op**'a çevrildi (toplu gönderim
    tavanı `..limit(100)`, `:220`) — böylece 2. yuvarlakta **gerçekten bekleyen** bir op olur.
    🔴 **BUILDER'IN "kapıyı genişlet — yalnız `kuyrugaBak` yeterli" ŞIKKI REDDEDİLDİ.** Guard'ı
    `secilenler.isNotEmpty`'siz bırakmak, **kuyruk boşken retry planlanmasına** izin verirdi ve
    bu, `D-A11-1`'in Onur'a sunulan **daraltma gerekçesini çürütürdü**: *"yeniden deneme yalnız
    gönderilmemiş iş varken koşar ⇒ boştaki maliyeti sıfırdır."* Ayrıca *"cümle DB durumuna
    değil turun türüne atıfta bulunur diye YORUMLANIR"* demek, **kilitli bir kararı kodla
    yeniden yorumlamaktır** — `slice-3d` §1'in yasağı: *bir karar yanlışsa kodla değil, Onur'un
    kilidiyle değişir.* **Kapı doğrudur; hatalı olan benim senaryomdu.**
10. 🔴 **v2.2 ERRATA — BUILDER İKİNCİ KEZ YAKALADI (`M142` eşdeğer mutant).** v2'de `M142`
    `G22`/`d`'ye bağlıydı; builder ölçtü: `d`'de başarıdan sonraki hata **dışarıdan** gelen bir
    `turCalistir()`'den doğar ve o giriş noktası (`:98-100`) çizelgeyi **zaten koşulsuz sıfırlar**
    ⇒ başarı dalındaki `sifirla()` **hiçbir ölçülebilir etki üretmiyordu**. Builder haklıydı.
    🔴 **Ama "eşdeğer ilan et" şıkkı REDDEDİLDİ:** kaçırılan bir yol var — `_yuvarlakDongusu`
    bir **`while(true)` boşaltma döngüsüdür** (`D7`), yani `sifirla()` (`:182`) ve `planla()`
    (`:205`) **AYNI TURDA** ateşlenebilir. Yeni ayak **`G22`/`m`** o yolu ölçer ve `M142`
    gerçekten ısırır. **Ders: bir mutant "eşdeğer" ilan edilmeden önce ERİŞİLEBİLİR YOLLARIN
    TAMAMI sayılmalıdır; "bu ayakta etkisi yok" ile "hiçbir yolda etkisi yok" aynı şey değildir.**
11. 🔴 **`M141` İÇİN KARAR BUILDER'A BIRAKILDI (ölç, ilan etme).** Aynı akıl yürütme `M141`
    (`G22`/`c`, kuyruk boşalınca iptal) için de geçerli olabilir: başarı anında bekleyen
    zamanlayıcı **yoktur** (ateşlenen zamanlayıcı kendini `null`'lar), dolayısıyla oradaki
    `cancel()` inert olabilir. **ÖLÇ:** erişilebilir yolları say (özellikle `:97`'deki
    `if (devamEden != null) return devamEden;` erken dönüşü — dışarıdan gelen çağrı devam eden
    tura takılırsa `:99` sıfırlaması **hiç koşmaz**). Isıran bir yol varsa ayağı ona bağla;
    **yoksa** eşdeğer ilan et — ama gerekçede **hangi yolları saydığını** yaz, *"etkisi yok"*
    demekle yetinme.
9. 🔴 **v2.1 ERRATA — BU SPEC'İN KENDİ HATASI, BUILDER YAKALADI.** v2'nin `G22`/`k` ve `M153`
   maddeleri `400` durum kodunu kullanıyordu ve `D9`'un **kilitli** sınıflandırmasıyla doğrudan
   çelişiyordu (`401`-dışı `4xx`'te `denemeSayisi` **artmaz**). Üç bağımsız kanıt: `slice-3d` §3
   satır 215-216 (`K70` kilitli) · `g5_karantina_kapisi_test.dart`'taki **mevcut ve GEÇEN**
   *'D9: HTTP 400'* testi (`denemeSayisi == 0`) · `senkron_dongusu.dart` `_httpHatasiIsle`.
   `401`'e düzeltildi. 🔴 **Not: "ayağı ATLA" ŞIKKI REDDEDİLDİ** — atlamak, `D-A11-4`'ün en riskli
   yan etkisini (*sayaç ölür mü?*) **ölçüsüz** bırakırdı. Ayak yanlış değildi, **durum kodu**
   yanlıştı. **Bu kayıt, `K26`'nın ters yönde çalıştığının kanıtıdır: builder spec yazarını denetledi.**
8. 🔴 **`G22`/`h` üretimde daha zayıftır:** `K3` bayrağı devam eden tur bitince `cekmeTuruCalistir()`
   koşturabilir ⇒ ayak *"yeniden deneme yolunda çekme yok"* iddiasını **yutulan tetikleyici
   olmayan** temiz kurulumda ölçer. Beyan edilmiştir.
