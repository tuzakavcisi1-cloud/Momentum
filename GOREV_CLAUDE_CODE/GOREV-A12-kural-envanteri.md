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
spec zaten `[S0] BİÇİM` ile okunmuyor. ⇒ Bu onarım **hiçbir mevcut spec'te yeni bulgu üretmez**.

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

### `D-A12-3` — GERİYE UYUM PAZARLIKSIZ
Onarım **hiçbir mevcut spec'te** yeni bulgu üretmeyecek. Ölçülmüştür (§2); builder **yeniden ölçer**.

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


## 7. KABUL KRİTERLERİ
0. 🔴 **PATLAMA YARIÇAPI YENİDEN ÖLÇÜLÜR** (Cowork'ün oturum 49 ölçümüne **güvenilmez**, tekrarlanır):
   onarım öncesi tüm spec'ler için bulgu kümesi kaydedilir. **Onarım sonrası fark > 0 ise DUR ve
   Onur'a sor** — sessizce yeni bulgu üretmek bu dilimin **yasağıdır**.
1. `python araclar\spec-kapi-kapsama.py --altin-kume` ⇒ **EXIT 0**, vaka **≥ 21** (bugün 13).
2. `M156`–`M161` sırayla; her biri beklenen kapıyı **KIRMIZI** yapar, dosya **bayt-özdeş** geri
   alınır, temiz koşum **tekrar EXIT 0**.
3. `python araclar\spec-kapi-kapsama.py GOREV_CLAUDE_CODE\GOREV-A11-ag-donus-itmesi.md` ⇒ **EXIT 0**
   **ve** çıktıda `KURAL (0)` **YAZMAZ**.
4. `python araclar\sayi-tazeligi.py .` ⇒ **TEMİZ** (altın küme sayısı belgelerde tazelenmiş olmalı).
5. `python araclar\tek-kopya-kapisi.py .` ⇒ **YEŞİL**.

## 8. YASAKLAR
1. 🔴 **Mevcut spec'lerin metnine dokunmak YASAK** — özellikle `K59`/`K64`/`K70`/`K79`/`K105`/`K109`
   ile **kilitli** olanlara. Araç belgeye uyar, belge araca değil.
2. 🔴 **`S1`/`S3`/`S4`/`S5`/`S6` davranışlarını gevşetmek YASAK.**
3. 🔴 **`G<n>`'i kural saymak YASAK** (`M158`).
4. **Ölçmediğini "temiz" sayma.**

## 9. BEYAN EDİLMİŞ SINIRLAR
1. 🔴 **Sekiz eski spec `[S0] BİÇİM` ile hâlâ okunmuyor** (K81 öncesi başlık şeması). Bu dilim onu
   **kapatmaz**; o belgeler kilitli ve `K81` zaten *bundan sonraki* spec'leri bağlıyor.
2. Araç **mutantın gerçekten ısırdığını** ölçmez, yalnız **kapsamayı** ölçer — kendi de böyle yazıyor.
3. `A11`'in §9'a taşınan iki sınırı bu dilim bitene kadar **orada kalır**; geri taşıma **isteğe bağlıdır**.
4. 🔴 **`D-A12-3` (geriye uyum) MUTANTSIZDIR** ve §6b'ye yazılamadı (yukarıda ölçüldü: araç onu
   hayalet borç sayıyor). Gerekçe: geriye uyum bir davranış değil **kısıttır**; kendi mutantı
   `A12/G26`/`a`'nın ta kendisidir ve **`M160` onu düşürür**. Ayrı bir mutant aynı ölçümün
   kopyası olurdu. **Bu satır, §6b mekanizması çalışır hâle gelince oraya taşınmalıdır.**
