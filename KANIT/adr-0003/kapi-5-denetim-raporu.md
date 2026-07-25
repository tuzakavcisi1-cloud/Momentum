# KAPI-5 — ADR 0003 v5 BAĞIMSIZ DENETİM RAPORU

**Tarih:** 25 Tem 2026 · **Oturum:** 22 (Cowork, temiz oturum) · **Denetlenen:** `docs/ADR/0003-kimlik-cekirdegi.md`
**Denetlenen sürümün kimliği (denetçinin kendi ölçümü):**
`sha256 758bd1bfa84c72ae174f338a89cd03b9070afd2b27dd51080099187bb6822ef6` · 212.485 bayt · UTF-8, BOM yok · `U+FFFD` 0 · 13.123 Türkçe harf
→ hafızanın K24 beyanıyla **birebir aynı**. *(Tek sapma: `wc -l` **1.080**, hafıza 1.081 diyor — dosya `\n` ile bittiği için sayım kuralı farkı; sha eşit olduğuna göre içerik aynıdır. Kusur değil, kayıt.)*

**HÜKÜM: 🔴 KİLİTLENEMEZ.**
Ölçülerek doğrulanmış **12 bloker**, **7 majör**; ayrıca ölçülemeyen ama gerekçelendirilmiş **6 aday bloker** Onur'un adjudikasyonuna bırakıldı.

---

## 0. Denetim mimarisi (üreten ≠ denetleyen)

- v5'i **oturum 21** yazdı; bu rapor **oturum 22**'ye aittir. Yazan el denetlemedi.
- Belge 10 bağımsız denetçiye bölündü (§0+§1-K · §2-A/B · §2-C · §2-D/§2-I · §2-J · §2-K/§2-L · §2-M · §3 · §3.1+§3.2 · §4-§7); hiçbiri diğerinin bulgusunu görmedi. 11. ajan hafıza tarihçesini taradı.
- **Her bulgu, rapora girmeden önce denetçi tarafından KAYNAKTAN yeniden ölçüldü** (K13-a: *alt-ajan beyanı doğrulanmadan aktarılmaz*). Doğrulanamayan bulgular aşağıda **REDDEDİLENLER** başlığında listelidir.
- Ölçüm aracı **önce kendi altın kümesinde** koşuldu: `--altin-kume` → **çıkış kodu 0**, beş kontrolün beşi geçti. Kanonik belge koşumu: `K1=0 · K2=0 · K3=0 · K4=1 (yalnız kapsam beyanı) · K5=0`, çıkış kodu **1**.

---

## 1. BLOKERLER — ARACIN KENDİSİNDE (K19-c'nin emrettiği denetim)

Devir notu *"araç kendi kör noktalarından dördünü yakaladı; beşincisi olabilir"* diyordu. **Beşincisi var — ve dördüncüsüyle aynı sınıftan.**

### B5-1 [BLOKER] Araç bir kanonik satırı ne tarıyor ne de "kapsam dışı" diye bildiriyor — SESSİZ DARALTMA
Aracın özeti: `kanonik_satir: 30 · kanonik_taranan: 21 · kanonik_atlanan: 8`. **21 + 8 = 29 ≠ 30.**
Kaynak (`araclar/adr-kapi-taramasi.py` ~satır 170):
```python
if anahtar:                                        # satır SAYILIR
    _satir_sayaci[0] += 1
if anahtar and deger and re.search(r"\d", deger):  # sözlüğe yalnız RAKAM İÇEREN girer
    kanonik[anahtar] = deger                       # kapsam-dışı raporu SÖZLÜKTEN üretilir
```
Değerinde hiç rakam olmayan satır sözlüğe girmediği için `_atlanan`'a da giremez ⇒ raporda **görünmez**.
**Kontrollü koşumla kanıtlandı — kayıp satır:**
`satır 116: | **KS-14** | Kontrol 3 — eşzamanlılık izni | **`Environment.ProcessorCount`** | K3-J2(3) | M22 |`
**Etkisi:** aracın *"ELLE kontrol edilmeli"* dediği liste **8 değil 9**'dur. KS-14, hafıza K20'de tam olarak elle-kontrol örneği diye adı geçen satırdır ve kapı-5'e devredilen listeden düşmüştür.

### B5-2 [BLOKER] `K4`'ün muafiyeti satır bazlıdır: `[KS-` içeren HER satır taramadan muaf
Kaynak ~satır 205: `if desen.search(s) and ("KANONİK" not in s) and ("§1-K" not in s) and ("[KS-" not in s) and ("[KS-LITERAL:" not in s):`
Son koşul **ölüdür** (bir öncekinin içinde kalır). Sonuç: *"aynı satırda hem `[KS-n]` atfı hem ham sayı"* — yani en olası ihlal biçimi — **yapısal olarak görülemez**.
Canlı örnekler (ölçüldü, araç ikisini de raporlamadı):
- satır 409: `HKDF.Expand(…, outputLength: 32 `[KS-30]`, …)`
- satır 1037: *"pencere gerçekten **15 dk'dır**, 20 değil"* (15 dk = KS-1)

### B5-3 [BLOKER] `K1` çıpa sütununu ayrıştırmıyor — "36 karar kapılı" bir ölçüm değil
Kaynak satır 111: `kapili = set(JETON.findall(mutant_metin))` — §3'ün **tüm metninde alt dize araması**. Bir karar, §3'ün giriş paragrafında, bir *"reddedilenler"* notunda ya da devir cümlesinde anılıyorsa **kapılı sayılır**.
**Ölçülmüş sonuç:** §3.1 satır 941 `K3-L5…K3-L9` için birebir *"Bu belgede **kapısızdır** ve öyle olduğu yazılıdır"* diyor; araç beşini de **kapılı** sayıyor. Gerçek dağılım 36/11 değil, **31 kapılı · 11 beyanlı · 5 devredilmiş**.

### B5-4 [BLOKER] `K4`, §1-K kuralının açıkça bağladığı iki bölgeyi taramıyor
Kaynak satır 96 + 201: `govde_disi = set(range(mutant…)) | set(range(beyan…))` … `if i in govde_disi: continue`.
§1-K kuralı ise birebir: *"Gövde metni, **mutant tablosu ve §3.1** bu değerlere `[KS-n]` etiketiyle atıf yapar; sayıyı **KOPYALAMAZ**."*
⇒ Kuralın bağladığı yüzeyin üçte ikisi ölçüm dışıdır. Canlı kopyalar (ölçüldü): M23 *"**31.** `/login` isteği"* · M27 *"**31 gün**"* · M29 *"**61 sn**"* · M31 *"**14** / **15** / **129** karakter"*.

> **Aracın onarımı bu oturumun işi DEĞİLDİR** (Onur kilidi, 25 Tem 2026): kusuru bulan el onarmaz. Onarım + yeni altın-küme kontrolleri ayrı bir yazım oturumunda yapılır ve **yeniden bağımsız denetlenir**.

---

## 2. BLOKERLER — BELGEDE

### B5-5 [BLOKER] satır 413 — var olmayan bir risk kalemine "beyan edilmiş sınır" atfı
`ALINTI: "**Bu, kabul edilmiş ve beyan edilmiş bir sınırdır** (§6 Risk #17)."`
**Ölçüm:** §6 **1'den 16'ya** kadardır; `Risk #17` belgede yalnız bu satırda geçer (atfın hedefi değil, atfın kendisi).
⇒ Anahtar rotasyonunun kapsam dışılığı ve *"kök anahtar değişirse tüm oturumlar düşer"* sonucu §6'da **hiçbir yerde yazılı değil**. Beyan, beyan edilmemiş ⇒ **gizlenmiş sınır**.

### B5-6 [BLOKER] satır 1047 + 339 — Risk #13 süpürme periyodunu YANLIŞ kanonik kaleme atfediyor
`satır 1047: "Pencere: `[KS-4]` (yüklem) + azami `[KS-4]` (süpürme periyodu) = en kötü durumda 120 sn."`
Doğrusu **`[KS-6]`**'dır (KS-4 = replay penceresi, sahibi K14-a; KS-6 = süpürme periyodu, sahibi K3-C6(5)). Bugün ikisi de 60 sn olduğu için sonuç **tesadüfen** doğru.
Daha ağırı: satır 339 kendi cümlesinde doğruyu yazıyor (*"azami gecikme bir süpürme periyodudur (`[KS-6]`)"*) ve **hemen ardından** yanlış metni *"§6 Risk #13'te **birebir böyle** beyan edilir"* diye alıntılıyor ⇒ **satır kendisiyle çelişiyor.**
⇒ §1-K'nın *"bu hata sınıfını **yapısal olarak imkânsız** kılar"* iddiası yanlıştır: sınıf yok olmadı, **sayıdan etikete taşındı** ve araç etiketin *hangisi* olduğunu ölçmüyor.

### B5-7 [BLOKER] satır 845 — M31 satırı 11 hücrelidir (başlık 7); v5'in düzeltmesi GFM'de RENDER OLMUYOR
**Ölçüm:** `awk -F'|' NF` → satır 816 (başlık) **7** · satır 844 **7** · **satır 845 = 11** · satır 846 **7**.
GFM fazla hücreleri düşürür ⇒ ekranda görünen metin **v4'ün dört ayaklı hâlidir** (e-posta ayağı dâhil), yani B-6 ile *sahte kapı* ilan edilen sürüm. v5'in düzeltilmiş üç ayaklı metni hücrelerin arkasında kalıyor.
⇒ **"B-6 kapandı" beyanının operatif metinde karşılığı yok.** Ayrıca §3.1 satır 910 hâlâ *"M31'in dördüncü ayağı"* diyor (M52'ye taşınmıştı) ve satır 907 hâlâ `M36` diyor (M36b'ye taşınmıştı) — iki bayat atıf.

### B5-8 [BLOKER] satır 880 + 1073 — numara pini üç yerde çelişiyor, 0004 çakışacak
- satır **800**: *"ADR 0004'ün YENİ mutantları artık **`M60`**'tan başlar — K16-d'nin `M50` pini **geçersizdir**"*
- satır **880**: *"0004'ün yeni numaraları **`M50`**'den başlar [K16-d]"*
- satır **1073**: *"0004'ün yeni mutantları **`M50`**'den başlar"*
Bu belge M49·M50·M51·M52·M53'ü **kendisi tüketti**. 0004 satır 880/1073'ü izlerse **dört numara çakışır** — belgenin başlığında *"bu proje bu hatayı daha önce iki kez yedi"* denen hatanın üçüncüsü.

### B5-9 [BLOKER] satır 113-114 — KS-11 ve KS-12 var olmayan mutant ayaklarına çıpalı
`KS-11 → "M41 (üçüncü ayak)"` · `KS-12 → "M41 (dördüncü ayak)"`
**Ölçüm:** M41'in kendi satırı (863) birebir *"**TEK AYAK**"* diyor; ikinci ayak M41b'ye taşındı. *"üçüncü ayak"* / *"dördüncü ayak"* ifadeleri belgede **yalnız bu iki satırda** geçiyor.
⇒ `/refresh` ve `/logout*` tavanları **kapısız** ve §3.1'de **beyansız**. K1=0 bunu göremez (araç `KS-n → M` eşlemesine hiç bakmaz — beşinci kör nokta ailesinin bir üyesi).

### B5-10 [BLOKER] satır 595 ⟷ satır 760 — ProblemDetails'i kim üretiyor: iki karar, iki katman
- satır 595 (§2-J): *"**Handler**, lease alınamadığında `429` üretir ve … `ProblemDetails` gövdesini döndürür (ortak bir `RateLimitProblemFactory` üzerinden…)"*
- satır 760 (§2-M): *"Ret → `ProblemDetails` ÇEVİRİMİ | (port YOK — bilinçli) | **Api** (`RateLimitProblemFactory`) | `Microsoft.AspNetCore.Mvc.ProblemDetails` **YALNIZ Api'de**"*
595, K18-a'nın **tersini** söylüyor ve fiilen **M49'un mutasyonunun kendisidir**. Builder normatif bölümü (§2-J) okur ⇒ **baseline kırmızı doğar**.

### B5-11 [BLOKER] satır 958 — §3.2(4) gerçeğe uymayan bir uç stili pinliyor
`ALINTI: "Uç stili: `MapGroup("/v1")` + minimal API UÇ DELEGELERİ"`
**Kod ölçümü (Onur'un diski):** `DiagnosticsEndpoints.cs:16` · `SyncEndpoints.cs:19` · `TaskEndpoints.cs:22` · `TaskListEndpoints.cs:18` → dördü de **`MapGroup("/v{version:apiVersion}")`**, üçü ayrıca `.WithApiVersionSet(versionSet)`.
⇒ Birebir uygulanırsa auth uçları mevcut API-versiyonlama setinin **dışında** kalır: ayrı route, OpenAPI'de ayrı grup — sessiz bir mimari çatal.

### B5-12 [BLOKER] satır 872 — M42b'nin kill sinyali ayırt edici değil
`ALINTI: "restart ÖNCESİ verilmiş erişim token'ı restart SONRASI **`401`** alır" **FAIL**`
Mutasyon (`info` etiketi `v1→v2`, ya da bayt kodlaması) **statiktir**: mutasyona uğramış derlemede restart öncesi ve sonrası **aynı** anahtar türetilir ⇒ eski token yine geçerlidir ⇒ *"`401` alır"* assert'i **mutasyon altında da baseline'da da aynı sonucu verir**. Sinyalin ısırması ancak *"token baseline derlemesiyle verilir, konteyner mutasyona uğramış derlemeyle yeniden kalkar"* gibi **iki-derlemeli** bir koşumla mümkündür ve bu **hiçbir yerde tarif edilmemiştir**.
⇒ K3-I4'ün HKDF **türetme** ayağı bugün yaşayan bir sinyalle korunmuyor (M42 ve M42c'nin sinyalleri restart-kalıcılığını ölçüyor, türetmeyi değil).

---

## 3. MAJÖRLER (ölçülerek doğrulandı)

| # | satır | bulgu | ölçüm |
|---|---|---|---|
| M5-1 | 6, 33 | *"§0.1–§0.3 … **13.451 bayt**, belgenin ≈%8'i"* | v4'ün 24-70. satırları = **11.112 bayt**; v4 toplam 170.261 ⇒ **%6,53**. KANIT dosyası 11.691 bayt. Üç sayının hiçbiri 13.451 değil ⇒ ölçülmemiş, tahmin edilmiş. |
| M5-2 | 406 | `\| CSRF token HMAC'i \| K_csrf \| … \| 32 bayt \|` + `[KS-LITERAL: … tablo bütünlüğü için birebir yazılı]` | Gerekçe **komşularıyla çürüyor**: aynı tablonun 405 ve 407. satırları `**[KS-30]**` yazıyor ⇒ etiketin tabloda bütünlük sorunu üretmediği belgenin kendi satırlarıyla ölçülü. `[KS-30]` değişirse bu hücre sessizce 32'de kalır. |
| M5-3 | 1012 | *"Isopoh (**lisans belirsiz**)"* | Bir alternatifi eleyen **tek** gerekçe; belgede ne ölçüm ne `[DOĞRULANMADI]` var. §4'ün kendi kuralının ihlali (belgede 8 `DOĞRULANMADI` var; dokuzuncusu burada olmalıydı). |
| M5-4 | 927 + hafıza | *"18 mutanta `[çıpa+]` eklendi"* (hafıza K23/K24 + devir notu) | Belgede `[çıpa+]` **17 kez** geçiyor; biri (satır 927) mutant satırı değil **açıklama cümlesi** ⇒ fiilen **16 mutant satırı**: M5·M8a·M8b·M11·M16·M19·M22·M24·M29·M32·M34·M51·M-L5·M-L6·M-L7·M-L8. **İki etiket eksik ya da sayı şişirilmiş.** |
| M5-5 | 929 | *"kendi kör noktalarından **üçünü** üretip yakaladı"* | Hafıza K24 **dört** diyor. Altın küme fiilen **üç** kör-nokta kontrolü koşuyor; dördüncüsünün (sessiz daraltma) **regresyon kontrolü yok** — ve B5-1 tam o sınıftan çıktı. Ayrıca üç kontrolün üçü de `K4`'e ait: tamlık iddiasını taşıyan `K1`'in tek bir kör-nokta testi yok. |
| M5-6 | 909 | §3.1 K3-L10'un kapısını *"M43'ün üçüncü ayağı"* ilan ediyor | `K3-L10` belgede 565·717·909'da geçiyor; **§3 mutant tablosunda hiç yok** ve M43'ün çıpa hücresi onu taşımıyor ⇒ araç onu "beyanlı" sayarken §3.1 "artık kapılı" diyor. |
| M5-7 | 961 | *"Paket **zaten repodadır** ⇒ yeni bağımlılık değildir"* | `Microsoft.Extensions.TimeProvider.Testing` **yalnız** `Momentum.Persistence.Tests.csproj`'da. §3.2(1) `TS` testlerini `WebApplicationFactory<Program>`'a bağlıyor; o testlerin yaşayacağı `Momentum.Api.Tests` paketleri: NET.Test.Sdk · xunit · xunit.runner.visualstudio · Shouldly · Mvc.Testing · SignalR.Client — **paket YOK**. Doğru ama eksik olgu ⇒ sonuç (kırmızı çizgi #3 tetiklenmez) yanlış öncülden çıkıyor. |

---

## 4. ADAY BLOKERLER — ONUR'UN ADJUDİKASYONUNA (gerekçelendirildi, koşularak ölçülemedi)

Bu altı kalem **mantıksal çürütmeye** dayanıyor; kod bugün yazılmadığı için koşularak ölçülemedi. Her biri ayrı bir karar çatalıdır.

1. **Çalınmış yenileme token'ının tespit gecikmesi `[KS-4]` değildir (satır 330).** Belge *"meşru istemci `T2`'yi saniyeler içinde kullanır ⇒ pencere reuse-detection'ı `[KS-4]` geciktirir"* diyor. Ama K3-L5 yenilemeyi **401'e** bağlar; 401 erişim token'ı dolunca gelir ⇒ gecikme **`[KS-1]` (15 dk)**, kurban çevrimdışıysa **`[KS-2]`'ye (30 gün)** kadar uzar. K14-a'nın tüm maliyet muhasebesi bu cümleye dayanıyor.
2. **`[KS-4]` = 60 sn, K14-a'nın kendi adlandırdığı senaryoları kapatmıyor (satır 308).** Gerekçe *"uçak modu, hücresel el değiştirme, TCP reset, Doze/process kill"* — bunların hiçbiri 60 sn ölçeğinde değil. Kullanıcı 5 dk sonra yeniden denerse dal (d) ⇒ **meşru kullanıcı hırsız ilan edilir**, ve M29 bu davranışı test olarak mühürlüyor.
3. **M53 kendi mutasyonu altında ölmüyor (satır 878).** Mutasyonda istek 1 `T1`'i tüketir, CSRF patlar → 403. İstek 2 *"hemen ardından"* = `[KS-4]` **içinde** ⇒ dal (c)'nin üç koşulu sağlanır ⇒ **`200`** ⇒ assert **yeşil kalır**. Sinyal, ikinci istekten önce saatin `[KS-4]`'ü aşacak kadar ilerletilmesini şart koşmalı.
4. **M40b'nin önkoşulu kill sinyaliyle çelişiyor (satır 862).** Önkoşul *"`FakeTimeProvider` ilerletilmez"*, sinyal *"`[KS-4]`'ü aşmış ESKİ satır"* — saat ilerletilmezse pencere hiç aşılmaz ⇒ baseline kırmızı doğar. Saat ilerletilirse `KS-4 = KS-6` olduğu için süpürme turu da hak edilir ⇒ mutant hayatta kalır. Önkoşul zamana değil **mekanizmaya** çıpalanmalı.
5. **Parola salt'ının tazeliği hiçbir yerde karara bağlanmamış ve kapısız.** `grep "salt"` → yalnız 140·183·224·225; §3'te **sıfır**. Sabit salt kullanan bir implementasyon M5·M6·M6b·M7·M31·M32·M34'ün **hepsini** geçer. Karşılaştırma: aynı özellik AES nonce'u için **M50** ile kapılı.
6. **HKDF `info` etiketlerinin birbirinden farklı olduğunu ısırtan kapı yok (satır 405-411).** `K_csrf`'in etiketi kopyala-yapıştır ile `K_jwt`'ninkine eşitlenirse alan ayrımı tümüyle çöker; M42·M42b·M42c·M25·M35 **hepsi yeşil kalır**. §3.1'de de beyanlı değil.

**Ayrıca adlandırılmış, tartışmaya açık:** NIST SP 800-63B-4'ün **sızmış-parola blocklist `SHALL`**'ı ne karara bağlanmış ne kapsam dışı ilan edilmiş (`grep "blocklist|pwned|sızdırılmış"` → 0) — belge aynı standardın 15-karakter `SHALL`'ını gerekçe olarak kullanıyor ⇒ **adlandırılmamış sapma**.

---

## 5. REDDEDİLEN ALT-AJAN BULGULARI (K13-a — beyan doğrulanmadan aktarılmaz)

- **RET: *"`KANIT/adr-0003/olcum-araci-altin-kume-kanit.txt` repoda YOKTUR"*.** **Yanlış.** Dosya Onur'un diskinde **vardır**; `KANIT/adr-0003/` altında altı dosya bulunuyor (`kapi-2/3/4-denetim-raporu.md`, `olcum-araci-altin-kume-kanit.txt`, `v4-kapanma-tablolari.md`, `v5-yazim-plani.md`). Ajan, denetim kopyasına o klasör alınmadığı için yokluk çıkarımı yapmış. **Yokluktan yokluk çıkarılmaz.**
- **DÜZELTME:** bir ajan M31 satırını *"9 hücre"* diye ölçtü; denetçinin ölçümü **11 hücre**'dir. Bulgu ayakta, sayı düzeltildi.
- **DÜZELTME:** M42b için *"polarite ters"* denmişti; daha kesin hâli **"sinyal ayırt edici değil"**dir (statik mutasyon restart'tan bağımsızdır) — B5-12'de düzeltilmiş biçimiyle yazıldı.

---

## 6. TEMİZ ÇIKANLAR (kırmayı deneyip kıramadıklarımız — bunlar da kanıttır)

- **Belgenin kimliği birebir doğrulandı:** sha256, bayt, kodlama, `U+FFFD` 0, Türkçe harf sayısı — beşi de hafızanın beyanıyla uyuştu.
- **Araç sahte değil:** altın küme gerçekten koşuyor, kirli fikstürde dört kusurun dördünü de buluyor, temiz fikstürde yanlış alarm vermiyor, çıkış-kodu disiplini var. Kusuru **isabetinde değil, kapsamının beyan edilmemesinde**.
- **`--altin-kume` + kanonik koşum tekrarlanabilir:** `karar 47 · alt_madde 10 · kapili 36 · beyanli 11 · mutant 48` — §3.1'in yazdığıyla birebir.
- **§0.4'ün üç geri çekilmiş iddiası gerçekten ölü:** belgenin tamamı tarandı; hayatta kalan her geçiş *"geri çekilmiş"* olarak işaretli. Sessizce yeniden kullanılan iddia **bulunamadı**.
- **KANIT'a taşıma içerik olarak dürüst:** `v4-kapanma-tablolari.md`, v4'ün 24-70. satırlarıyla örtüşüyor; *"hiçbir satır silinmedi"* doğru (yalnız bayt **sayısı** yanlış — M5-1).
- **Numara bütünlüğü (K5) gerçek:** M1–M53 aralığında eksik yok; M2·M3·M9·M10·M20 devirli, M13 VOID, M54–M59 rezerv — satır 800'de fiilen yazılı. Tek kusur 880/1073'ün bayat pini.
- **§3.2(2) ve (5)'in Y-2/Y-3 düzeltmeleri kodla birebir doğrulandı:** `AddAuthentication`/`TestAuthHandler` → 0 eşleşme · `Program.cs:153` `public partial class Program;` mevcut · `Program.cs:34` `AddSingleton(TimeProvider.System)` · `Program.cs:45` `AddScoped<ICurrentUser, NullCurrentUser>()` · `FakeCurrentUser` iki test projesine birden bağlı.
- **Dockerfile'ın yokluğu gizlenmemiş:** `find -iname Dockerfile*` → 0, compose yalnız `postgres:17-alpine` — belgenin ölçümü doğru ve K22-a ile adlandırılmış bir yapım işine çıpalı.
- **M19 · M24 · M29 · M32(K3-B2) · M34 · M50 · M51 · M8a(K3-I1) tiyatro değil:** etiketlenen kararın ihlali kill sinyalini gerçekten öldürüyor.
- **M46 gerçekten ısırıyor:** `UseRateLimiter` `UseRouting`'den öne alınınca `GetEndpoint()` null olur ⇒ `EnableRateLimiting` bulunamaz ⇒ `429` hiç doğmaz.
- **§4'ün `RemoteIpAddress` özeleştirisi tam:** düşen ayağın üzerine inşa edilmiş her şey tek tek sayılmış — belgenin en güçlü alışkanlığı.

---

## 7. HÜKÜM VE SONRAKİ ADIM

**ADR 0003 v5 KİLİTLENEMEZ.**

Sıra (Onur kilitler):
1. **Ölçüm aracının onarımı — AYRI YAZIM OTURUMU.** B5-1…B5-4. Onarımla birlikte altın kümeye en az dört yeni kontrol: *rakamsız kanonik değer* · *aynı satırda hem atıf hem kopya* · *§3 metninde anılan kapısız karar* · *mutant tablosuna gömülü kanonik kopya*. **Onarımı yapan oturum onu denetleyemez.**
2. **v6 yazımı — AYRI OTURUM.** 12 bloker + 7 majör + adjudike edilen aday blokerler.
3. **6. tur bağımsız kapı — AYRI OTURUM.**

**Kalan bilinen borç, gizlenmiyor:** kapı-4'ün ~27 majöründen kalanlar · ~28 minörün çoğu · `GOREV-slice-3c-auth` spec'i hâlâ YOK.

---
*Bu rapor, denetlediği belgeyi yazmayan bir oturum tarafından üretilmiştir. Raporun kendisi de bir üretimdir ve kendi kendini onaylamaz: içindeki her ölçüm komutu tekrarlanabilir, her satır numarası kaynaktan doğrulanabilir.*
