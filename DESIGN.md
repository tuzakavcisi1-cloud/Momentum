# DESIGN.md — Momentum Tasarım Sistemi

> **Durum:** TASLAK v1 · 26 Tem 2026 · `slice-3b` (Flutter istemci) için yazıldı.
> **Yetki:** K10 (tasarım yönü) · K10-e (MUST/NICE bölünmesi) · **K42-b** (tam tasarım sistemi + iki pazarlıksız kısıt) · **K44-a** (araç ÖNCE, belge SONRA).
> **Bu belge kendi başına bir güvence DEĞİLDİR.** Hükmü `araclar/design-token-kapisi.py` verir (§10).

---

## 0. İki pazarlıksız kısıt (K42-b) — bu belgenin varlık şartı

1. **KULLANIM KISITI.** Aşağıdaki `MUST` işaretli her token ve her bileşen, **ilk dikey dilimde FİİLEN kullanılır.** Kullanılmayan her şey `NICE`'tır ve **tek satır** yer kaplar. Gerekçe: kod üretmeyen bir tasarım belgesi büyür ve çapraz-atıf yüzeyi doğurur (radar R2b/R4) — ADR 0003'ün sekiz tura girmesinin ölçülmüş kök nedeni budur.
2. **ÖLÇÜM KISITI.** Belge, ölçüm aracıyla **birlikte** yaşar. `MUST` token kodda kullanılmıyorsa **kusurdur**; kodda token'sız ham tasarım literali varsa **kusurdur**. Araç önce **altın kümesinde kendini kanıtlar** (10/10, `EXIT=0`, 26 Tem 2026) — **kör kapı yok.**

**Makine-okunur veri yalnız §1'deki `tokens` bloğundadır.** Bu belgedeki hiçbir proza, tablo veya başlık araç tarafından okunmaz — bu, K38-b'nin *"mutant tablosu prozadan VERİYE çevrilir"* dersinin doğrudan uygulanmasıdır.

---

## 1. Token'lar — TEK makine-okunur kaynak

Biçim: `ad = değer -> DartSembolü`. Değerlerde `-` karakteri **kullanılmaz** (ayrıştırıcı sınırı). Dart karşılıkları `src/client/lib/design/tokens.dart` içinde tanımlanır; tanımsız `MUST` sembolü `D3` kusuru verir.

```tokens
# seviye: MUST
renk.yuzey                = #FFFFFF   -> MRenk.yuzey
renk.yuzey.ikincil        = #F3F4F6   -> MRenk.yuzeyIkincil
renk.metin                = #14181F   -> MRenk.metin
renk.metin.ikincil        = #525C6B   -> MRenk.metinIkincil
renk.birincil             = #1B4FC4   -> MRenk.birincil
renk.uzeri.birincil       = #FFFFFF   -> MRenk.uzeriBirincil
renk.tehlike              = #A4231C   -> MRenk.tehlike
renk.cevrimdisi           = #7A5200   -> MRenk.cevrimdisi
renk.ayirici              = #DDE1E7   -> MRenk.ayirici
renk.kenarlik.etkilesim   = #6E7783   -> MRenk.kenarlikEtkilesim
tipo.baslik.l             = 20/28 w600 -> MTipo.baslikL
tipo.govde.m              = 16/24 w400 -> MTipo.govdeM
tipo.etiket.s             = 13/18 w500 -> MTipo.etiketS
bosluk.xs                 = 4         -> MBosluk.xs
bosluk.s                  = 8         -> MBosluk.s
bosluk.m                  = 16        -> MBosluk.m
bosluk.l                  = 24        -> MBosluk.l
radius.s                  = 8         -> MRadius.s
radius.m                  = 12        -> MRadius.m
hareket.hizli             = 120ms     -> MHareket.hizli
hareket.standart          = 200ms     -> MHareket.standart
olcu.dokunma.hedefi       = 48        -> MOlcu.dokunmaHedefi
olcu.ikon                 = 24        -> MOlcu.ikon
olcu.odak.kalinlik        = 2         -> MOlcu.odakKalinlik
# seviye: NICE
renk.basari               = #1B6B3A   -> MRenk.basari
renk.uyari                = #8A5A00   -> MRenk.uyari
tipo.baslik.xl            = 28/36 w700 -> MTipo.baslikXl
bosluk.xl                 = 32        -> MBosluk.xl
radius.tam                = 999       -> MRadius.tam
hareket.yavas             = 320ms     -> MHareket.yavas
olcu.ikon.buyuk           = 32        -> MOlcu.ikonBuyuk
yukselti.kart             = 1         -> MYukselti.kart
```

### 1.1 Koyu tema karşılıkları [MUST — aynı semboller, farklı değer]

Koyu tema **ayrı token adı doğurmaz**; `tokens.dart` aynı sembolleri `Brightness`e göre çözer. Bu, K30'un *"sayı bir kez yazılır"* kuralının tema tarafındaki karşılığıdır.

| sembol | açık | koyu |
|---|---|---|
| `MRenk.yuzey` | `#FFFFFF` | `#0F1319` |
| `MRenk.yuzeyIkincil` | `#F3F4F6` | `#181D25` |
| `MRenk.metin` | `#14181F` | `#E8EBF0` |
| `MRenk.metinIkincil` | `#525C6B` | `#A2ADBC` |
| `MRenk.birincil` | `#1B4FC4` | `#8FB4FF` |
| `MRenk.uzeriBirincil` | `#FFFFFF` | `#0F1319` |
| `MRenk.tehlike` | `#A4231C` | `#FF8F87` |
| `MRenk.cevrimdisi` | `#7A5200` | `#F0C24B` |
| `MRenk.ayirici` | `#DDE1E7` | `#2A313B` |
| `MRenk.kenarlikEtkilesim` | `#6E7783` | `#8B94A2` |


---

## 2. Erişilebilirlik — ZORUNLU (a11y kapısı PAZARLIKSIZ)

### 2.1 Kontrast — ÖLÇÜLDÜ, iddia edilmedi

W3C'nin bağıl parlaklık ve kontrast formülü uygulandı (`(L1+0.05)/(L2+0.05)`), her iki tema için, 26 Tem 2026. **24 çiftin 24'ü geçti, 0 kaldı.** Ham betik: `araclar/` dışında geçici koşuldu; **kalıcı hâli a11y kapısına girer** (§10, açık kalem A-1).

| çift | eşik | açık | koyu |
|---|---|---|---|
| gövde metni / yüzey | 4.5 | **17,79:1** | **15,59:1** |
| gövde metni / ikincil yüzey | 4.5 | **16,17:1** | **14,16:1** |
| ikincil metin / yüzey | 4.5 | **6,77:1** | **8,20:1** |
| ikincil metin / ikincil yüzey | 4.5 | **6,15:1** | **7,44:1** |
| birincil (link) / yüzey | 4.5 | **7,09:1** | **8,99:1** |
| birincil buton üzeri metin | 4.5 | **7,09:1** | **8,99:1** |
| hata metni / yüzey | 4.5 | **7,41:1** | **8,45:1** |
| çevrimdışı rozet metni / yüzey | 4.5 | **6,92:1** | **11,11:1** |
| etkileşim kenarlığı / yüzey | 3.0 | **4,54:1** | **6,08:1** |
| etkileşim kenarlığı / ikincil yüzey | 3.0 | **4,12:1** | **5,52:1** |
| odak halkası / yüzey | 3.0 | **7,09:1** | **8,99:1** |
| odak halkası / ikincil yüzey | 3.0 | **6,44:1** | **8,17:1** |

🔴 **ÖLÇÜM BİR KUSUR BULDU VE BELGE YAZILMADAN ÖNCE KAPANDI [gizlenmiyor]:** ilk palette tek bir `renk.kenarlik` vardı ve **1,58:1 (açık) / 1,65:1 (koyu)** ile 3:1 eşiğinde **KALDI**. Token **ikiye ayrıldı:**
- `renk.ayirici` — **dekoratif ayırıcı**; bir kontrolü tanımlamaz ⇒ WCAG 1.4.11 **kapsam dışıdır**. Ölçülen **1,31:1 / 1,42:1**. **BEYAN EDİLMİŞ MUAFİYETTİR**, gizlenmiş bir sınır değildir. **Kural:** bu renk **hiçbir zaman** bir kontrolün tek tanımlayıcısı olamaz.
- `renk.kenarlik.etkilesim` — **kontrolü tanımlayan** kenarlık (girdi alanı, onay kutusu çerçevesi) ⇒ **≥3:1 ZORUNLU**, ölçüldü ve geçti.

### 2.2 Diğer a11y zorunluları [MUST]

| # | kural | nasıl ölçülür |
|---|---|---|
| A11Y‑1 | Her dokunulabilir hedef **≥ `olcu.dokunma.hedefi` (48dp)** | widget testi + `flutter_driver` ile gerçek hit-box |
| A11Y‑2 | Odak **görünür**: `olcu.odak.kalinlik` kalınlığında `renk.birincil` halka | `widget_inspector` + ekran görüntüsü |
| A11Y‑3 | Her etkileşimli öğe **`Semantics` etiketi** taşır; ikon-yalnız buton **yasak** | semantics ağacı taraması |
| A11Y‑4 | Metin ölçeği **2.0×'e kadar** taşma/kırpma YOK | `MediaQuery` textScaler testi + ekran görüntüsü |
| A11Y‑5 | `MediaQuery.disableAnimations` **onurlandırılır** (hareket azaltma) | mutantla ısırtılır: bayrak açıkken süre 0 olmalı |
| A11Y‑6 | **Renk tek başına anlam taşımaz**: çevrimdışı/çakışma **ikon + metin** ile de anlatılır | semantics + ekran görüntüsü |
| A11Y‑7 | Senkron durumu değişince ekran okuyucuya **duyurulur** (`SemanticsService.announce`) | semantics olay testi |

> **KÖR KAPI UYARISI:** A11Y‑1…A11Y‑7'nin hepsi **çalışan uygulama** ister. Bugün `0 .dart` var ⇒ **hiçbiri koşulmadı.** Bu kapı, `slice-3b` adım 2 biter bitmez koşulur ve **her maddesi mutantla ısırtılır** (K44-b).

---

## 3. Bileşen envanteri

### 3.1 MUST — ilk dilimde fiilen kullanılacaklar

| bileşen | işi | taşıdığı token'lar |
|---|---|---|
| `MomentumTema` | Açık/koyu tema çözümü; **tek** `ThemeData` kaynağı | tümü |
| `GorevListesiEkrani` | Tek vitrin ekranı | `bosluk.m`, `renk.yuzey` |
| `GorevSatiri` | Görev: onay kutusu + başlık + senkron rozeti | `tipo.govde.m`, `bosluk.s`, `olcu.dokunma.hedefi`, `renk.ayirici` |
| `GorevEkleAlani` | Alt sabit giriş + ekle düğmesi | `renk.kenarlik.etkilesim`, `radius.m`, `renk.birincil`, `renk.uzeri.birincil` |
| `SenkronRozeti` | 4 durum: yerel · kuyrukta · gönderildi · çevrimdışı | `renk.cevrimdisi`, `tipo.etiket.s`, `olcu.ikon`, `bosluk.xs` |
| `CakismaRozeti` | Sunucu ile çakışma; dokununca çözüm sayfası | `renk.tehlike`, `olcu.ikon`, `radius.s` |
| `BosDurum` | Hiç görev yok | `tipo.baslik.l`, `renk.metin.ikincil`, `bosluk.l` |
| `YuklenmeDurumu` | İlk yükleme | `hareket.standart`, `renk.metin.ikincil` |
| `HataDurumu` | Yerel DB / ağ hatası + yeniden dene | `renk.tehlike`, `tipo.govde.m`, `bosluk.m` |

### 3.2 NICE — tek satır, ilk dilimde YOK

`FiltreCubugu` · `EtiketCipi` · `TarihSecici` · `KaydirmaliEylem` (sil/ertele) · `AramaAlani` · `ProjeSecici` · `KaranlikModAnahtari` (sistem teması izlenir, elle geçiş NICE) · `BosDurumIllustrasyonu`.


---

## 4. Durum matrisi — çevrimdışı-öncelikli uygulamanın asıl tasarım işi

Bu matris **vitrinin kendisidir**: ödevin taç mücevheri *"çevrimdışı-öncelikli senkron + gerçek zamanlı işbirliği"* ve kullanıcı bunu **yalnız bu durumlardan** görür.

| durum | ekran | rozet | metin (TR) | semantics duyurusu |
|---|---|---|---|---|
| **boş** | `BosDurum` | — | "Henüz görev yok. Aşağıdan ekleyin." | — |
| **yükleniyor** | `YuklenmeDurumu` | — | "Yükleniyor" | "Görevler yükleniyor" |
| **yerel** (kaydedildi, gönderilmedi) | liste | saat ikonu + `renk.metin.ikincil` | "Yalnızca bu cihazda" | — |
| **kuyrukta** (gönderiliyor) | liste | yukarı ok, `hareket.standart` ile döner | "Gönderiliyor" | — |
| **senkronize** | liste | ikon **YOK** (gürültü azaltma) | — | "Senkronize edildi" (A11Y‑7) |
| **çevrimdışı** | liste + üst şerit | bulut-kapalı ikonu + `renk.cevrimdisi` | "Çevrimdışısınız. Değişiklikler kaydedildi." | "Çevrimdışı" |
| **çakışma** | liste + `CakismaRozeti` | uyarı ikonu + `renk.tehlike` | "Bu görev başka bir cihazda da değişti." | "Çakışma var" |
| **hata** | `HataDurumu` | — | "Bir şeyler ters gitti." + "Yeniden dene" | "Hata" |

**PAZARLIKSIZ:** her durumda **ikon + metin birlikte** vardır (A11Y‑6). Yalnız renkle ayrılan durum **yoktur**.

---

## 5. Hareket

| token | süre | nerede |
|---|---|---|
| `hareket.hizli` | 120ms | onay kutusu işaretleme, rozet değişimi, basma geri bildirimi |
| `hareket.standart` | 200ms | liste öğesi giriş/çıkış, çevrimdışı şeridi açılış |
| `hareket.yavas` *(NICE)* | 320ms | sayfa geçişleri |

**Eğri:** giriş `easeOut`, çıkış `easeIn`, durum değişimi `easeInOut`. **PAZARLIKSIZ:** `MediaQuery.disableAnimations` açıkken **tüm süreler 0**'dır (A11Y‑5) ve bu **mutantla ısırtılır** — bayrağı onurlandırmayan bir sürüm testi geçemez.

---

## 6. İkonografi

- **Tek kaynak:** Material Symbols (Flutter yerleşik `Icons`). **İkinci ikon kütüphanesi eklenmez** — yeni bağımlılık = lisans + CVE kapısı (kırmızı çizgi #3).
- **Boyut:** `olcu.ikon` (24). Büyük varyant `olcu.ikon.buyuk` **NICE**.
- **Anlam pini [MUST]:** çevrimdışı = `cloud_off` · kuyrukta = `arrow_upward` · yerel = `schedule` · çakışma = `error_outline` · sil = `delete_outline`. **Aynı ikon iki farklı anlam taşıyamaz.**
- **İkon-yalnız etkileşim YASAK** (A11Y‑3): her ikonun ya görünür metni ya `Semantics` etiketi vardır.

---

## 7. İmza öğeler (K10-e — MUST / NICE ayrımı)

**MUST — ödevin ayırt edici yüzü, ilk dilimde var:**
1. **Senkron rozeti dili.** Her görev satırı, sunucuya göre durumunu **kendi üstünde** taşır. Çoğu to-do uygulamasında bu bilgi yoktur; Momentum'un vitrini tam olarak budur.
2. **Çevrimdışı şeridi güven verir, korkutmaz.** Metin *"bağlantı yok"* değil, **"değişiklikler kaydedildi"**dir — çevrimdışı-öncelikli mimarinin kullanıcıya çevirisi.
3. **Çakışma gizlenmez.** Çakışma sessizce çözülmez; kullanıcıya **görünür** ve dokunulabilir yapılır.

**NICE — sonraki dilimler:** yumuşak liste yeniden sıralama · NLP hızlı ekleme ipucu balonu · boş durum illüstrasyonu · haptik geri bildirim.

---

## 8. Ban-list [PAZARLIKSIZ]

1. **Ham tasarım literali yasak.** `Color(0x…)`, `fontSize: 14`, `EdgeInsets.all(12)`, `BorderRadius.circular(8)`, `SizedBox(height: 20)`, `Duration(milliseconds: 300)` — hepsi token'a çevrilir. Muafiyet **yalnız** `// [DESIGN-LITERAL: gerekçe]` ile ve **gerekçe zorunludur** (`D2`/`D4`).
2. **İkinci tasarım kütüphanesi yok** (Cupertino karışımı, üçüncü taraf UI kiti). Yeni bağımlılık = lisans + CVE kapısı.
3. **Renk tek başına anlam taşımaz** (A11Y‑6).
4. **Sabit yükseklikli metin kutusu yok** — metin ölçeği 2.0×'te kırpma yasak (A11Y‑4).
5. **`print` ile UI durum kaydı yok**; hata durumu `HataDurumu` bileşenine düşer.
6. **Marka/telif:** üçüncü taraf logo, ikon seti veya font gömülmez.
7. **`tokens.dart` DIŞINDA tema çözümü yok** — `Theme.of(context)` üstünden elle renk seçmek yasak.

---

## 9. Dosya sözleşmesi

```
src/client/
  lib/
    design/
      tokens.dart        <- MUST sembollerinin TEK tanım yeri (D3 burayı arar)
      tema.dart          <- ThemeData çözümü (açık/koyu)
    ...
```
`tokens.dart` **ham değer taşımak zorundadır** ve bu yüzden `D2` taramasından **muaftır** (araç onu kullanım gövdesinden çıkarır). Başka hiçbir dosya bu muafiyete sahip değildir.

---

## 10. KAPI — bu belge nasıl ölçülür

```powershell
python araclar\design-token-kapisi.py --altin-kume    # once ARAC kendini kanitlar (EXIT 0 olmali)
python araclar\design-token-kapisi.py .               # sonra belge <-> kod
```

| kod | ne yakalar |
|---|---|
| `D0` | `tokens` bloğu biçim hatası / birden çok blok |
| `D1` | `MUST` token kodda hiç kullanılmıyor |
| `D2` | Kodda ham tasarım literali (token kaçağı) |
| `D3` | `MUST` sembolü `tokens.dart` içinde tanımsız |
| `D4` | Gerekçesiz muafiyet |

**26 Tem 2026 ölçümü:** altın küme **10/10 GEÇTİ** · gerçek proje üzerinde hüküm **"BOŞ GİRDİ — ölçülecek şey yok"** (`exit 0`). ⚠ Bu **temiz hükmü DEĞİLDİR**; henüz `0 .dart` olduğu için ölçülecek bir şey yoktur. **Kod doğduğu anda bu kapı gerçek hüküm verecektir.**

**Aracın beyan edilmiş sınırı:** `yorum_disi()` tam bir Dart ayrıştırıcısı değildir ⇒ **çok satırlı `/* */` bloğu içindeki ham literal kaçabilir.** Altın kümede bu vaka **YOKTUR** — adlandırılmış borçtur.

---

## 11. Açık kalemler / devir

| # | kalem | sahibi |
|---|---|---|
| **A‑1** | Kontrast betiği geçici koştu; **kalıcı hâli `araclar/` altına ve a11y kapısına girmeli** (altın kümesiyle) | ayrı el |
| **A‑2** | A11Y‑1…A11Y‑7 **hiç koşulmadı** (0 `.dart`); adım 2 biter bitmez koşulur ve **mutantla ısırtılır** | `slice-3b` adım 2 |
| **A‑3** | `flutter_driver` paketi `pubspec`'e eklenmezse ekran görüntüsü + widget ağacı kapısı **fiziksel olarak imkânsız** (K43/K44‑b) | `GOREV-slice-3b` spec |
| **A‑4** | Çok satırlı `/* */` içindeki literal kaçağı — altın küme vakası eksik | ayrı el |
| **A‑5** | Web'de `MRenk` çözümü + `textScaler` davranışı Android'den **farklı olabilir**; iki platformda ayrı ölçülecek [DOĞRULANMADI] | `slice-3b` adım 2 |
| **A‑6** | Yazı tipi ailesi **seçilmedi** (sistem varsayılanı kullanılacak); gömülü font = lisans kapısı ⇒ bilinçli olarak ertelendi | sonraki dilim |

---

> **Bu belge oturum 28'de yazıldı. K26 gereği onu yazan el DENETLEYEMEZ.** Bağımsız kapılar: `design:design-system` · `design:design-critique` · `design:accessibility-review` → **red-team EN SON**.
