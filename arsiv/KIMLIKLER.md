# KIMLIKLER.md — Momentum · DONMUŞ DOSYA KİMLİKLERİ

> 🔴 **BU DOSYA AÇILIŞTA OKUNMAZ.** `BORCLAR.md` / `KAPILAR.md` sınıfındadır — **başvuru**
> malzemesi; `ORTAM.md`'nin **operasyonel** mayın listesi sınıfında **DEĞİLDİR**. Bir kilit
> kurulurken, bir kilidin bozulduğundan şüphelenilince ya da `DURUM.md §9`'a atıf yapan bir
> satır okunurken açılır.
> **Tavan: ≤ 16 KB** — `belge-tavan-kapisi.py` kapsamında, **vaka 14** ile pinli (kapsam
> eklemesinin fiilen ısırdığı ölçüldü; `ORTAM.md`/`M138` emsali).
> `tek-kopya-kapisi.py` kapsamında **`canli`** sınıfındadır: *içeriği* donmuş kimliklerdir ama
> *dosya* kilit geldikçe **büyür** ve yanlış yazılmış bir kayıt **düzeltilir** (o61'de `W3` v2
> için tam bunu yapmak gerekti) ⇒ `kilitli` sınıfı burada **yanlış olurdu**.
> `sayi-tazeligi.py` kapsamındadır — buradaki *"altın küme N/M"* iddiaları **ölçülür**; bu
> ekleme yapılmasaydı taşıma, kapı kapsamını sessizce daraltmanın kibar adı olurdu.
> **Kaynak:** `DURUM.md §9`'dan **6 Ağu 2026 (oturum 61, `K151`)** ayrıldı, Onur kilitledi.
> §9 numarası ve başlığı `DURUM.md`'de **yönlendirici olarak DURUYOR** — `DURUM.md §9`'a adıyla
> atıf yapan **11 canlı satır ölçüldü** (`KAPILAR.md`:32 · `GOREV-SS2`:547,552 · `GOREV-A10`:4 ·
> `GOREV-A9c`:4 · `GOREV-W2`:107,217 · `GOREV-W1`:8 · `GOREV-A13`:10 · `BORCLAR.md`:89,113);
> bölümü silmek §7'de kaçınılan **sarkan atıf** sınıfını doğururdu.

---

## 0. KURAL

🔴 **BURAYA YALNIZ *DONMUŞ* KİMLİKLER YAZILIR.** Sık değişen bir sha'yı buraya yazmak
`kanonik-kopya` kusurunu **garanti eder** — eski `DURUM.md §9` tablosunda **dört kez** oldu;
dördüncüsü `K151-b`'dir ve aşağıda `W3` satırında yazılıdır. Değişkenlerin kimliği **yazılmaz,
ÖLÇÜLÜR**:

```powershell
python araclar\dosya-kimlik.py DURUM.md CLAUDE.md DESIGN.md PROJE_RADAR.jsonl GOREV_CLAUDE_CODE\GOREV-slice-3b-istemci-iskeleti.md
```

⚠ **Kimlik `sha256`+bayttır, satır DEĞİL** ve **DAİMA son yazımdan SONRA** ölçülür.
🔴 **Kilitlenmemiş bir artefaktın kimliği bu tabloya yazılırsa bayatlamaya mahkûmdur** — `W3`
satırı bunun ölçülmüş kanıtıdır. Yazılıyorsa **kilit durumu** hücrede açıkça belirtilir.

---

## 1. DONMUŞ KİMLİKLER (bunlar SÖZLEŞMEDİR — değişirse bir kilit bozulmuş demektir)

| dosya | bayt | sha8 | neden donmuş |
|---|---|---|---|
| `DESIGN.md` **v2** | **18.587** | **`8B8AA35D`** | 🔴 **K142 (Onur, 5 Ağu 2026, oturum 59)** — `3780ACA4` **GEÇERSİZDİR**. Üç satır eklendi: §3.1 `DepolamaSeridi` · §4 depolama geri-düşüşü satırı · §6 `Icons.storage` anlam pini (W2 T7). Açılma kapsamı Onur'un dördüncü kilididir; başka değişiklik yine Onur'un kilidini ister |
| `GOREV-slice-3b-istemci-iskeleti.md` | **44.560** | **`F0C3A75A`** | 🔒 **K59 kilidi (v6)** — değişen her bayt kilidi bozar. `6056A5BB` · `79A53AA3` · `BE4581BA` · `1AB02B73` **geçersizdir** |
| `GOREV-slice-3c-senkron.md` | **41.692** | **`537D0579`** | 🔒 **K64 kilidi (v2, Onur onayladı 27 Tem 2026)** — `5899A220` (v1) **GEÇERSİZDİR**. `tek-kopya-kapisi.py` kapsamında **`kilitli`** sınıfındadır ⇒ sapma **her açılışta ölçülür** |
| `GOREV-slice-3d-cekme.md` | **80.399** | **`889A383F`** | 🔒 **K70 kilidi** (Onur onayladı 28 Tem 2026) — build'i sürdü, iki bağımsız denetimden geçti, `tek-kopya-kapisi.py` kapsamında **`kilitli`** ⇒ sapma **her açılışta** ölçülür |
| `araclar/radar.py` | 28.878 | `46E3A8BC` | **K57‑b** — plugin 0.2.0 ile bayt-özdeş; sapma tek sha ile ölçülür |
| `araclar/adr-kapi-taramasi.py` | 50.582 | `A22841F2` | **K34-f** tutuyor; ADR donduruldu |
| `araclar/tek-kopya-kapisi.py` | **17.688** | **`97F8A695`** | K70'te kapsam genişledi. 🔴 **Oturum 49'da `ORTAM.md` kapsama eklendi** (`66AC9CA3` / 17.259 b **GEÇERSİZDİR**); aynı disiplin koştu: altın küme **19/19**, ardından `araclar/tek-kopya-mutant.py` **tamamı geçmişti** (o49 ölçümü — 🔴 **o64'te GEÇERSİZLEŞTİ**, aşağıya bak); ve kapı commit'ten önce `ORTAM.md` için `S5` vererek kapsam eklemesinin **canlı olduğunu kendisi kanıtladı** 🔴 **Oturum 61'de `KIMLIKLER.md` kapsama eklendi** (`K151`; `9D7D0781` / 17.352 b **GEÇERSİZDİR**); aynı disiplin **yeniden** koştu ✅. 🔴 `araclar/tek-kopya-mutant.py` **10/11** koşuyor. 🔴 **o64 DÜZELTMESİ — *"ortam ayrımı"* VARSAYIMI ÖLÇÜMLE ÇÜRÜDÜ:** `M2b` son baytı silerek geriye bir `CR` bırakmayı varsayar; ölçüm ⇒ `PROJE_HAFIZA.md` diskte **CRLF 0** (son 4 bayt `di.\n`), `.gitattributes` `* text=auto eol=lf`, repo-yerel `core.autocrlf` **TANIMSIZ**, mount bayt çevirmiyor (Windows metadata 31.084 b = mount'ta okunan 31.084 b). ⇒ mutant **Windows'ta da düşer**; kapı doğru ısırıyor, **ölü olan mutanttır** (`B-O64-1`). Eski *"Windows'ta tamamı geçer"* iddiası **GEÇERSİZDİR**. 🔴 **Bu aracın TEK kanonik sayısı `DURUM.md` §6 tablosundadır** — buraya kopyalanmaz (`kanonik-kopya`). |
| `GOREV-slice-3e-G12.md` | **12.623** | **`BDB3630E`** | 🔒 **K79 kilidi**. 🔴 Beyanlı-kilit sepetinde — gerekçe ve sepetin tamamı `BORCLAR.md`'de (tek kopya) |
| `GOREV-A10-cihaz-on-kosullari.md` | **26.126** | **`8AD6CA10`** | 🔒 **K105 kilidi (v2, Onur onayladı 1 Ağu 2026)** — `04E49CC9` (v1) ve `A947CC1E` (kilit satırı ÖNCESİ v2) **GEÇERSİZDİR**. 🔴 Beyanlı-kilit sepetinde — gerekçe `BORCLAR.md`'de. Kapıları **`A10/G17`–`A10/G21`** (K108) |
| `GOREV-A9c-D5-kor-kapi-onarimi.md` | **20.600** | **`53ED7838`** | 🔒 **K109 kilidi (Onur onayladı 2 Ağu 2026)** — kilit satırı **ÖNCESİ** `D88312F6` (19.497 b) **GEÇERSİZDİR**. Kapısı **`A9c/G18`** (K108; `A10/G18` ile adı aynı, kendisi farklı). 🔴 Beyanlı-kilit sepetinde — gerekçe `BORCLAR.md`'de |
| `GOREV-A13-ios-iskeleti-ci.md` | **37.106** | **`0748DDD8`** | 🔒 **K130 kilidi (Onur kilitledi 3 Ağu 2026, oturum 53 — KABUL sonrası)** — `BCD0AA81` (K127) · `56871800` (K126) · `D2DA483E` · `3E543DBE` **hepsi GEÇERSİZDİR**. Kilit **kabul öncesi bağımsız denetim** (K127) spec'te ölçümle yanlışlanmış iki gerekçe bulunca açıldı; `D-A13-3` + §9/9 düzeltildi, §9'a 11 yeni beyan eklendi. Kapıları **`A13/G27`–`A13/G30`** (K108). U+FFFD 0 · CRLF 0. 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** (sepet `BORCLAR.md`'de) 🔴 **o70'te ÖLÇÜLDÜ (son yazımdan SONRA), Onur kilitledi:** o69'un `K178` turu `D-A13-4`'ü kapatırken spec'i değiştirdi (commit `12f0d6a`, +24/−10) ve **kimliği güncellemedi** ⇒ `9C7213F2` / **36.155 b GEÇERSİZDİR** (`oturum-sagligi.py` `D1` bunu o70 açılışında KIRMIZI ile yakaladı). Aynı turda `:97` ve `:304`'teki **`A13/G31/a`–`g` (7 statik ayak)** beyanı da düzeltildi — `ci-kapisi.py` fiilen **`G31a`…`G31h`, 8 ayak** taşıyor (altın küme **22/22**); düzeltme öncesi ara değer **`A72EBCB1`** (37.106 b) **GEÇERSİZDİR**. Üç bayt değişti (g→h ×2, 7→8 ×1), boyut sabit kaldı — **bayt karşılaştırması bu düzeltmeye KÖRDÜR**, yalnız sha yakalar. |
| `GOREV-SS2-cakisma-cozumu.md` | **46.003** | **`420E9F91`** | 🔒 **K133 kilidi (Onur kilitledi 3 Ağu 2026, oturum 55)** — `66CC4AAE` (v2) ve `90314998` (v1) **GEÇERSİZDİR**. U+FFFD 0 · CRLF 0. Kapıları **`SS2/G31`–`SS2/G34`** (K108). 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** (sepet `BORCLAR.md`'de) |
| `GOREV-W1-web-yuruyen-iskelet.md` | **33.077** | **`5CF3F921`** | 🔒 **K137 kilidi (Onur kilitledi 4 Ağu 2026, oturum 57)** — kilit satırı **ÖNCESİ** `606F04F5` (32.801 b) ve **v1** `DFA8FF77` (19.941 b) **GEÇERSİZDİR**. U+FFFD 0 · CRLF 0. Kapıları **`W1/G35`–`W1/G38`**, mutantları `M189`–`M199` (K108). 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** |
| `GOREV-W3-capraz-koken-izolasyonu.md` **o63 sonu** | **36.238** | **`C6F2CAD1`** | 🔴 **o64'te ÖLÇÜLDÜ (son yazımdan SONRA):** o63 `K162` ile §8'e madde 9–10 yazıldı ve **bu satır güncellenmedi** ⇒ **v2 `6DD115D4` / 34.029 b GEÇERSİZDİR** (`oturum-sagligi.py` `D1` bunu o64 açılışında KIRMIZI ile yakaladı). 🔴 **KİLİTLENMEDİ ve `K150` ile REDDEDİLDİ** (tur 2, 11 bloker) ⇒ **v3 gerekir**. 🔴 **`K151-b` — BU SATIR o60'ta BAYATTI, o61'de ÖLÇÜLDÜ:** eskiden **`D0143461` / 32.712 b** yazıyordu; o değerin **hiçbir karşılığı yok** — diskte de git'te de. Ölçüm: `rev-list --all --objects` ⇒ dosyanın tek blob'u **`61119601` / 18.950 b** (= **v1**, HEAD'deki hâli), disk ise **`6DD115D4` / 34.029 b**. Dosyanın son yazımı **01:00:16**, kimliğin yazımı **02:02:50** ⇒ kayıt son yazımdan *sonra* alınmış görünüyor ama **değeri tutmuyor: elle yazılmış, ölçülmemiş.** (`K148-b`: *elle sayılan her sayı yanlıştır* — dördüncü vaka.) 🔴 **Bedeli:** o60 denetim raporu (`KANIT/W3/` altındaki `03-DENETIM-v2-o60.md`) da başlığında aynı ölü sayıyı taşıyor ⇒ **K127 turunun hangi artefaktı denetlediği belgeyle KANITLANAMIYOR.** Bulguları bu geçersiz kılmaz — mtime sırası (spec 01:00 → denetim 01:58) üç ajanın **34.029 b**'lik dosyayı okuduğunu gösterir — ama bu **çıkarımdır, kanıt değildir.** **v1** `61119601` **GEÇERSİZ** (`K146`). U+FFFD **0** · CRLF **0**. Kapıları **`W3/G43`–`W3/G47`**, mutantları `M217`–`M245` + `MW21`/`MW22` |
| `GOREV-W2-depolama-gorunurlugu.md` **v3** | **19.511** | **`CA2D7BF2`** | 🔒 **K142 kilidi (Onur kilitledi 5 Ağu 2026, oturum 59)** — **v1** `C9BC8453` (11.770 b) ve **v2** `94124CE5` (18.156 b) **GEÇERSİZDİR**. U+FFFD 0 · CRLF 0. Kapıları **`W2/G39`–`W2/G42`**, mutantları `M200`–`M216` + `MW20` negatif kontrolü (K108). `K127` **iki tur** ödendi: `KANIT/W2/00-DENETIM-o59.md` (`B950236F`) + `KANIT/W2/01-v2-DOGRULAMA-o59.md` (`1143A34F`). 🔴 **Beyanlı-kilit sepetinde** — `tek-kopya-kapisi.py` kapsamına **eklenmedi** |
