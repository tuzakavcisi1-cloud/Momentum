# GOREV-A12 — `spec-kapi-kapsama.py` KURAL ENVANTERİNİN ONARIMI (mikro-dilim)

> **Durum:** KİLİT ADAYI. Onur *"önerini yap"* dedi (2 Ağu 2026, oturum 49) ⇒ öneri **ölçüldü** ve
> spec'e döküldü. **Build: Claude Code** (`K34-f` — aracı **yazan elden ayrı el**). Ölçüm: Cowork.
> **Bilerek küçük tutuldu:** `A11` zaten üç kapı + 17 mutant taşıyor; üç araç onarımı bir dilime sığmaz.

## 1. NE OKUNUR
`CLAUDE.md` (**K81** biçim standardı) · `araclar/spec-kapi-kapsama.py` ·
`GOREV_CLAUDE_CODE/GOREV-A11-ag-donus-itmesi.md` (**kurbanın kendisi**). `PROJE_HAFIZA.md` **açılmaz**.
🔴 Kapı kimlikleri spec-yereldir (`K108`): **`A12/G25`** biçiminde atıf yapılır.

## 2. NEDEN — ÖLÇÜLMÜŞ KÖK NEDEN

`spec-kapi-kapsama.py` kural envanterini **yalnız §5 tablolarının ilk sütunundan** ve **yalnız**
şu biçimlerde çıkarıyor (`:52-83`): `D<TEK HANE>` · `A11Y-<hane>` · sabit `kontrast`/`metin`.
Deseni `\bD(\d)\b`'dir ⇒ **`D10` bile görünmez.**

🔴 **`K108` bunu ölümcül yaptı:** kapı kimlikleri spec-yerel ilan edildiğinden yeni spec'ler kendi
karar adlarını kullanıyor (`A11`'de `D-A11-1` … `D-A11-6`). Sonuç **oturum 49'da ölçüldü**:
`A11` için araç `KURAL (0)` yazdı ve **EXIT 0** verdi — yani *"mutantsız kural yok"* hükmü
**boşluğa** verildi. Aracın **kapı yarısı çalışıyor, kural yarısı ölü.**

🔴 İkinci ölçülmüş belirti: `A11` §6b'ye yazılan **gerekçeli** iki borç aracın biçimini **doğru**
taşıyordu ve araç ikisini de **okudu**, ama `[S6] GEREKSİZ BORÇ — envanterde böyle bir kural yok`
dedi. **Araç haklıydı**; borçlar §9'a taşındı. Yani bugün **borç mekanizması da yeni spec'lerde
kullanılamıyor**.

🟢 **PATLAMA YARIÇAPI ÖLÇÜLDÜ (oturum 49, 22 spec taranarak): SIFIR.** Genişletilmiş desen mevcut
her spec'te **bugünküyle aynı** kural kümesini buldu (`YENI-MUTANTSIZ: 0`, istisnasız); sekiz eski
spec zaten `[S0] BİÇİM` ile okunmuyor 🔴 **[SAYI YANLIŞ — bkz. errata altta: gerçek sayı ON]**.
⇒ Bu onarım **hiçbir mevcut spec'te yeni bulgu üretmez**.

🔴 **ERRATA (3 Ağu 2026, Claude Code'un bağımsız ölçümü — kriter 0, Onur kilitledi): "SIFIR" İDDİASI
YANLIŞTI.** `D-A12-1`+`D-A12-2` kilitli metne birebir uygulanıp 23 spec'in tamamı önce/sonra ölçülünce
`GOREV-A11-ag-donus-itmesi.md`'de 6, bu spec'in kendisinde 3 yeni `[S2]` doğdu (kanıt:
`KANIT/A12/01-PATLAMA-YARICAPI-OLCUMU.txt`). Oturum-49 ölçümü **yalnız** zaten-envanterde-olan
kuralların mutant durumunu karşılaştırmış; §3 başlıklarından **yeni** envantere giren kuralların
(daha önce hiç görünmedikleri için) otomatik `S2` üreteceğini ölçmemiş — bu bir ölçüm hatası değil,
ölçülmemiş bir kategoriydi. `D-A12-3` bu yüzden **daraltıldı** (bkz. §3); yeni kurallardan doğan
`S2`'ler §6b'de gerekçeli borç olarak kapatıldı, sıfır iddiası **iptal edilmedi, düzeltildi**.

🔴 **ERRATA 2 — "SEKİZ ESKİ SPEC" SAYISI DA YANLIŞTI, GERÇEK SAYI ON.** Claude Code'un kendi ölçümü
(`KANIT/A12/onceki/*.txt`, 23 spec'in tamamı) `[S0] BİÇİM` veren **on** spec buldu, sekiz değil:
`GOREV-slice-1-backend-omurga.md` · `GOREV-slice-2a-senkron-cekirdek.md` ·
`GOREV-slice-2b1-kalicilik-sync.md` · `GOREV-slice-2b2-gercek-zaman.md` ·
`GOREV-slice-2c-yakinsama-duzeltmesi.md` · `GOREV-slice-3a-DUZELTME-1-D5-ortak-senaryo.md` ·
`GOREV-slice-3a-DUZELTME-2-KANIT-diff-butunlugu.md` · `GOREV-slice-3a-materyalizasyon.md` ·
`GOREV-slice-3e-G12.md` · `GOREV-slice-3e-iskelet.md`. Cowork'ün `KANIT/A12/00-COWORK-TABAN-ONCESI.txt`
tabanı da **on** diyor (`TOPLAM BULGU: 10`) — sayı Cowork'te doğruydu, yalnız bu spec'in kendi
düzyazısına **sekiz** olarak yanlış yazılmıştı. Eksik sayılan ikisi `slice-3e-G12` ve `slice-3e-iskelet`;
birincisinin `[S0]` sebebi zaten `CLAUDE.md` `K81`'de yazılıydı (kendi başlık şemasını kullanıyor).

## 3. KİLİTLİ KARARLAR

### `D-A12-1` — ENVANTER **§3'ün KARAR BAŞLIKLARINI** DA OKUR
Bugünkü kaynak (§5 ilk sütun) **korunur**; üstüne §3'teki `### <KURAL-ADI> — <baslik>` biçimindeki
**karar başlıkları** eklenir. Gerekçe: yeni spec'ler kararlarını **§3'te başlık olarak** yazıyor
(`A11` aynen böyle), §5 tabloları ise **ayak** tablosudur. Kuralı belgenin yazıldığı yerden okumak,
belgeyi araca uydurmaktan **ucuzdur**.

### `D-A12-2` — AD DESENİ GENİŞLER
Tanınan kural adı: `D<rakam+>` (**çok haneli**, `D10` dâhil) · `A11Y-<rakam+>` ·
`D-<harf/rakam>+-<rakam+>` (spec-yerel, ör. `D-A11-2`) · mevcut sabitler `kontrast`/`metin`.
🔴 **`G<n>` kapı kimlikleri kural sayılmaz** — kapı ile kural ayrımı korunur (`S1` ≠ `S2`).

### `D-A12-3` — GERİYE UYUM PAZARLIKSIZ 🔴 **[3 Ağu 2026 — Onur DARALTTI, ŞIK 2]**
Envanterine **YENİ giren kurallar DIŞINDA** hiçbir spec'te yeni bulgu üretmez. **Envantere yeni giren
kuralın `S2` vermesi BEKLENEN ve KABUL EDİLEN sonuçtur; §6b kaydıyla karşılanır.**

🔴 **ERRATA — ÖNCEKİ METİN YANLIŞLANDI, KISIT KALDIRILMADI, DARALTILDI.** Bu kararın ilk metni
*"Onarım hiçbir mevcut spec'te yeni bulgu üretmeyecek"* diyordu ve bunu §2'deki oturum-49 ölçümüne
(22 spec, `YENI-MUTANTSIZ: 0`) dayandırıyordu. Claude Code'un **kendi bağımsız ölçümü** (kriter 0,
`KANIT/A12/01-PATLAMA-YARICAPI-OLCUMU.txt`) bunu **yanlışladı**: `D-A12-1`+`D-A12-2` birebir kilitli
metne uygulanınca `GOREV-A11-ag-donus-itmesi.md`'de **6**, bu spec'in kendisinde **3** yeni `[S2]`
doğdu — toplam **9 spec'e YAYILAN 9 bulgu, 2 spec'te**. Kök neden: oturum-49 ölçümü yalnız **ESKİ**
desenin bulduğu kural kümesiyle **YENİ** desenin bulduğu kural kümesini karşılaştırmış (`YENI-MUTANTSIZ:
0` yalnız *"zaten envanterde olan kurallar arasında yeni mutantsız çıkan var mı"* diye ölçmüş) —
envantere **hiç girmemiş** bir kuralın (§3 başlıklarından gelen `D-A11-n`, `D-A12-n`) birdenbire
göründüğünde otomatik olarak `S2` vereceğini **hiç hesaba katmamış**. Kısıt bu yüzden **imkânsızdı**:
bir envanteri genişletmek tanımı gereği önceden görünmeyen kuralları görünür kılar ve görünür kılınan
her kural, mutantı yoksa `S2` verir — bu, aracın **doğru çalıştığının** kanıtıdır, arızası değil.
**Kaldırılmadı, DARALTILDI:** "yeni bulgu üretmeyecek" yerine "envantere yeni giren kuraldan doğan S2
DIŞINDA yeni bulgu üretmeyecek." Bu yeni sınır **§6b kaydıyla** (borç, gerekçeli) karşılanır, kapı
kırmızıda bırakılmaz.

## 4. ORTAM
Cihaz **gerekmez**; bu dilim **saf statik araç** işidir. Docker/emülatör **kaldırılmaz**.

## 5. KAPILAR

### G25 — ENVANTER KAPISI (araç kendi altın kümesinde)

| ayak | ölçülen |
|---|---|
| `a` | §3'te `### D-A11-2 — …` başlığı ⇒ envanterde **`D-A11-2`** görünür (bugün görünmüyor) |
| `b` | §5 ilk sütununda `D0`-`D4` aralığı ⇒ **beş** kural (mevcut davranış **bozulmadı**) |
| `c` | `D10` ⇒ envanterde **`D10`** (bugün `\bD(\d)\b` yüzünden **hiç** görünmüyor) |
| `d` | §3'te `### G25 — …` başlığı ⇒ **kural sayılmaz** (kapı/kural ayrımı korunur) |
| `e` | envanterdeki bir kural mutantsız **ve** borçsuz ⇒ **`S2` ISIRIR** |
| `f` | envanterdeki kural için **gerekçeli** borç ⇒ **SUSAR** ve özet bölümünde **sayılır** |
| `g` | envanterde **olmayan** bir ada borç ⇒ **`S6` ISIRIR** (hayalet borç korumasi bozulmadı) |
| `h` | mutant tablosunda envanterde olmayan kurala atıf ⇒ **`S3` HAYALET ATIF** (bozulmadı) |

### G26 — GERİYE UYUM KAPISI (gerçek depo, 22 spec)

| ayak | ölçülen |
|---|---|
| `a` | `GOREV_CLAUDE_CODE/*.md`'nin **tamamı** onarım ÖNCESİ ve SONRASI koşulur; **bulgu kümesi bayt-bayt AYNI** kalır (yeni `S2`/`S3`/`S6` **yok**) |
| `b` | `A11` artık **`KURAL (0)` DEĞİL**: en az `D-A11-1`…`D-A11-6` görünür |
| `c` | `A11`'in §9'a taşınmış iki sınırı **§6b'ye geri konabilir** ve araç `S6` **vermez** (mekanizma yeni spec'lerde **çalışır hâle geldi**) |

## 6. MUTANTLAR

| mutant | değişiklik | kapı | beklenen |
|---|---|---|---|
| **M156** | §3 başlık kaynağını kaldır (yalnız §5 kalsın) | `A12/G25`/`a` | `D-A11-2` görünmez ⇒ **KIRMIZI** |
| **M157** | Deseni tek haneye geri al (`\bD(\d)\b`) | `A12/G25`/`c` | `D10` kaybolur ⇒ **KIRMIZI** |
| **M158** | `G<n>`'i de kural say | `A12/G25`/`d` | kapılar kural envanterine sızar ⇒ **KIRMIZI** |
| **M159** | Hayalet-borç kontrolünü (`S6`) kaldır | `A12/G25`/`g` | uydurma ada borç yeşil geçer ⇒ **KIRMIZI** |
| **M160** | Deseni `\w+` kadar gevşet (aşırı genişleme) | `A12/G26`/`a` | eski spec'lerde **yeni `S2`'ler** doğar ⇒ **KIRMIZI** (geriye uyum kapısı ısırır) |
| **M161** | §5 ilk-sütun kaynağını kaldır | `A12/G25`/`b` | `D0`-`D4` aralığı kaybolur ⇒ **KIRMIZI** |

## 6b. MUTANT BORCU — **BOŞ, VE BU BOŞLUK ONARIMIN GEREKÇESİDİR**

🔴 **ARAÇ, KENDİSİNİ ONARAN SPEC'İ DE ISIRDI — ÖLÇÜLDÜ.** Bu bölüme önce şu satır yazıldı:
`- KURAL: D-A12-3 | GEREKCE: …`. Araç onu **doğru biçimde okudu** ve
**`[S6] GEREKSİZ BORÇ: D-A12-3 — envanterde böyle bir kural yok`** dedi. Yani *körlüğü kapatan
belgenin kendisi, o körlüğün kurbanı oldu.* `D-A12-3` §3'te bir **karar başlığıdır** ve araç §3'ü
hiç okumaz — `D-A12-1`'in var oluş sebebi tam olarak budur.

Borç bu yüzden **§9'a** taşındı (aynı şey `A11`'de de yapıldı). **Bu dilim bittiğinde bu bölüm
yeniden kullanılabilir hâle gelir**; `A12/G26`/`c` tam olarak bunu ölçer.

🟢 **BÖLÜM ARTIK KULLANILABİLİR [3 Ağu 2026, Onur kilidi — ŞIK 2].** Onarım kendi §3 kararlarını da
görünür kıldı (`D-A12-1`, `D-A12-2`, `D-A12-3`) ve üçü de hiçbir mutant tablosu satırında **adıyla**
geçmediğinden ilk koşumda `[S2]` verdi (Claude Code'un ölçümü: `KANIT/A12/sonraki/GOREV-A12-kural-envanteri.txt`,
3/3). Aşağıdaki kayıtlar bu üçünü kapatır — hiçbiri "mutantı yok" DEMEZ:

- KURAL: D-A12-1 | GEREKCE: MUTANTSIZ DEGILDIR: M156 (A12/G25/a, SS3 baslik kaynagi kaldirilinca D-A11-2 envanterden kaybolur) kararin EKLENEN yarisini, M161 (A12/G25/b, SS5 ilk-sutun kaynagi kaldirilinca D0-D4 araligi kaybolur) KORUNAN yarisini dogrudan isirir. Esleme kapi-ayak uzerinden DOLAYLIDIR.
- KURAL: D-A12-2 | GEREKCE: MUTANTSIZ DEGILDIR: M157 (A12/G25/c, desen tek haneye donunce D10 kaybolur) cok-haneli D<rakam+> alt-kuralini, M158 (A12/G25/d, G<n> de kural sayilinca kapilar envantere sizar) kapi/kural ayrimi alt-kuralini dogrudan isirir. D-<harf/rakam>+-<rakam+> (spec-yerel) alt-deseninin KENDI mutanti yok; kaybi yalniz M156 uzerinden dolayli gozlenir (SS9'da ayrica beyan edilir).
- KURAL: D-A12-3 | GEREKCE: MUTANTSIZ DEGILDIR: M160 (A12/G26/a, desen \w+ kadar gevsetilince eski spec'lerde yeni S2'ler dogar) tam olarak bu karari isirir -- SS9/4'un zaten yazdigi gibi kendi mutanti G26/a'nin ta kendisidir. Esleme DOLAYSIZDIR ama ayri bir mutant numarasi tasimaz (SS9/4'ten buraya tasindi, mekanizma calisir hale geldigi icin).

🔴 **ASIL KUSUR BURADA DA KAPANMIYOR (ŞART 3):** yukarıdaki üç kaydın "DOLAYLIDIR" demek zorunda
kalması, aracın kendi kural envanterini onaran spec'te bile aynı kör noktayı taşıdığını gösterir:
`S2` yalnız doğrudan kural→mutant adı atfını arar, kapı-ayak üzerinden kurulan dolaylı kapsamayı
görmez. Bu, `A12`'nin kapsamına **alınmaz** (araç kodunda `S2` mantığına dokunmak bu dilimin dışında);
kalem `BORCLAR.md` `B-O51-1`.


## 7. KABUL KRİTERLERİ
0. 🔴 **PATLAMA YARIÇAPI YENİDEN ÖLÇÜLÜR** (Cowork'ün oturum 49 ölçümüne **güvenilmez**, tekrarlanır):
   onarım öncesi tüm spec'ler için bulgu kümesi kaydedilir. 🔴 **[DARALTILDI, 3 Ağu 2026 — Onur, ŞIK 2,
   `D-A12-3` ile aynı düzeltme]:** **envantere yeni giren kurallardan doğan `S2` DIŞINDA** onarım
   sonrası fark **> 0 ise DUR ve Onur'a sor** — sessizce başka bir sınıfta yeni bulgu üretmek bu
   dilimin **yasağıdır**. Ölçüldü (Claude Code, kriter 0 ilk turu): `A11`'de 6, `A12`'nin kendisinde 3
   yeni `S2` doğdu, hepsi *envantere yeni giren kural* sınıfındandı (`KANIT/A12/01-PATLAMA-YARICAPI-OLCUMU.txt`)
   ⇒ istisna kapsamında; §6b'deki borç kayıtlarıyla kapatılınca **ikisi de yeniden `EXIT 0`** vermelidir
   (kriter 3a/3b bunu ayrıca ölçer).
1. `python araclar\spec-kapi-kapsama.py --altin-kume` ⇒ **EXIT 0**, vaka **≥ 21** (bugün 13).
2. `M156`–`M161` sırayla; her biri beklenen kapıyı **KIRMIZI** yapar, dosya **bayt-özdeş** geri
   alınır, temiz koşum **tekrar EXIT 0**.
3. 🔴 **İKİ AŞAMALI [3 Ağu 2026, Onur DÜZELTTİ — ŞART 2b: eski kriter 3 "KURAL (0) yazmasın" VE
   "EXIT 0 versin" derken KENDİ İÇİNDE ÇELİŞİYORDU].** Envanter genişleyip `D-A11-1`…`D-A11-6`
   görünür oldu mu, mutantları/borcu olmadan hepsi `S2` verir — `KURAL (0)` gerçekten yazılmaz
   ama `EXIT 0` da vermez; bu **kör kapı olmadığının kanıtıdır**, iki aşamada ayrı ayrı ölçülür:
   - **3a — §6b kayıtlarından ÖNCE:** `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A11-ag-donus-itmesi.md`
     ⇒ **EXIT 1**, tam **6** adet `[S2]` (`D-A11-1`…`D-A11-6`, her biri).
   - **3b — §6b kayıtlarından SONRA:** aynı komut ⇒ **EXIT 0**, çıktıda `KURAL (0)` **YAZMAZ**
     (en az `KURAL (6)` görünür) ve hiçbir `[S2]` **yok**.
4. `python araclar\sayi-tazeligi.py .` ⇒ **TEMİZ** (altın küme sayısı belgelerde tazelenmiş olmalı).
5. `python araclar\tek-kopya-kapisi.py .` ⇒ **YEŞİL**.

## 8. YASAKLAR
1. 🔴 **Mevcut spec'lerin metnine dokunmak YASAK** — özellikle `K59`/`K64`/`K70`/`K79`/`K105`/`K109`
   ile **kilitli** olanlara. Araç belgeye uyar, belge araca değil.
2. 🔴 **`S1`/`S3`/`S4`/`S5`/`S6` davranışlarını gevşetmek YASAK.**
3. 🔴 **`G<n>`'i kural saymak YASAK** (`M158`).
4. **Ölçmediğini "temiz" sayma.**

## 9. BEYAN EDİLMİŞ SINIRLAR
1. 🔴 **ON eski spec `[S0] BİÇİM` ile hâlâ okunmuyor** (K81 öncesi başlık şeması) 🔴 **[ERRATA, 3 Ağu
   2026: bu madde "sekiz" diyordu, Claude Code'un ölçümü ON verdi — eksik sayılanlar `slice-3e-G12` ve
   `slice-3e-iskelet`, bkz. §2 ERRATA 2].** Bu dilim onu **kapatmaz**; o belgeler kilitli ve `K81`
   zaten *bundan sonraki* spec'leri bağlıyor.
2. Araç **mutantın gerçekten ısırdığını** ölçmez, yalnız **kapsamayı** ölçer — kendi de böyle yazıyor.
3. `A11`'in §9'a taşınan iki sınırı bu dilim bitene kadar **orada kalır**; geri taşıma **isteğe bağlıdır**.
4. 🟢 **[TAŞINDI, 3 Ağu 2026] `D-A12-3` (geriye uyum) artık §6b'de gerekçeli borç kaydıdır** —
   mekanizma çalışır hâle geldi, bu madde kendi önerdiği gibi §6b'ye taşındı. Gerekçe aynı kaldı:
   geriye uyum bir davranış değil **kısıttır**; kendi mutantı `A12/G26`/`a`'nın ta kendisidir ve
   `M160` onu düşürür. Ayrı bir mutant aynı ölçümün kopyası olurdu. *(Bu madde numarası, append-only
   disiplini gereği bayat işaretiyle burada durur; içerik §6b'dedir.)*
