# W1 — OTURUM 58 BAĞIMSIZ DENETİM BULGULARI

> **Bağlam:** Oturum 58, `W1` kabulünün (`K138`) kapanmamış sınırlarından birini kapatmak için
> **13 statik mutantı gerçek repoda koştu** (o57'de 13'ü *okunmuş, ölçülmemişti*). Koşucu:
> `KANIT/W1/_statik_mutant_kosucu.py` · ham çıktı: `KANIT/W1/02-STATIK-MUTANT-KOSUMU.txt`.
> Ardından **K26** gereği koşucunun kendisi **bağımsız bir denetçiye** kırdırıldı.
> Bu dosya o denetimin bulgularını ve **Cowork'ün bağımsız yeniden ölçümünü** taşır.

## 0. ÖLÇÜLEN — KOŞUM SONUCU

`14/14` (13 spec mutantı + `M-o58-1`). Her `ISIR` mutantı hedef ayağının bulgu kodunu **fiilen**
üretti; her geri alma **bayt-özdeş** (`sha256` + bağımsız olarak `git status`'ta üç ürün dosyası
**görünmüyor**). Temiz repoda taban ve kapanış ölçümü **EXIT 0**.

🟢 **`M-o58-1` bu oturumda EKLENDİ ve spec tablosunda YOKTU.** `G35`'in *"POZİTİF KONTROL
(PAZARLIKSIZ)"* prozası ne mutant ne borç taşıyordu; `spec-kapi-kapsama.py` onu **göremez**, çünkü
harfli bir ayak değil serbest prozadır. Ölçüldü: çapa bozulunca kapı `EXIT 3` + `ORTAM HATASI`
veriyor ve **YEŞİL DEMİYOR** ⇒ pozitif kontrol **gerçekten çalışıyor**.

🔴 **`M-o58-1` İLK YAZIMINDA EŞDEĞERDİ — üretenin kendi kusuru, koşumda yakalandı.** İlk yama
`AddMediator()` → `AddMediatorX()` idi; aranan dizge `builder.Services.AddMediator` bu metinde
**ÖNEK olarak hâlâ vardı** ⇒ çapa hiç bozulmamıştı, kapı haklı olarak sustu ve mutant `KALDI` yazdı.
`AddCqrsMediator` ile düzeltildi. **Ders: yokluk ölçen mutant, dizgeyi ÖNEK olarak da bırakmamalıdır.**
Bu kusur yalnız **bulgu kodları çıktıya eklendiği için** görüldü — çıkış kodu tek başına onu gizliyordu.

---

## 1. BLOKER — `G35/b` `IsDevelopment()`'I HİÇ ARAMIYOR

**Spec ne diyor** (`GOREV-W1-web-yuruyen-iskelet.md` §5, `G35/b`):

> **b)** **İkisi de** `// W1/D-W1-2` işaretli **`IsDevelopment()` bloğunun** metin aralığındadır.

**Kapı ne yapıyor** (`araclar/cors-kapisi.py`): `_ISARET_DESENI = r"//\s*W1/D-W1-2.*?\{"` — yalnız
**yorum işareti** ve ondan sonraki `{`'in derinlik aralığı.

**COWORK'ÜN BAĞIMSIZ ÖLÇÜMÜ (birebir):** `findstr /n IsDevelopment araclar\cors-kapisi.py` ⇒
`289`, `299`, `309`, `399`, `405` **hepsi altın küme FİKSTÜR metni**, `489` bir **vaka başlığı**.
**Ölçüm mantığında (`denetle()`) `IsDevelopment` dizgesi HİÇ GEÇMİYOR.**

**Sonuç:** `if (true) // W1/D-W1-2` yazılırsa kapı **YEŞİL** kalır ve CORS **her ortamda** açılır.
Spec §8/2'nin kırmızı çizgisi (*"CORS yalnız `Development`"*) ve `D-W1-2`'nin **tam kendisi** düşer.
**On dört statik mutantın hiçbiri, altın kümenin 18 vakasının hiçbiri bunu ölçmüyor.**
`M190`/`M190b` **çağrıyı** taşıyor; **koşulu** kimse bozmuyor.

🔴 **Altın küme vakası 18 bu körlüğü GÖRÜNÜR kılıyor ama KAPATMIYOR:** *"işaret HER İKİ yerden de
silinir (**IsDevelopment koşulları kalır**) ⇒ `G35b` KIRMIZI"*. Yani kapı **işareti** sözleşme
sayıyor, **koşulu** değil — tersi (koşul silinir, işaret kalır) hiç ölçülmemiş.

## 2. BLOKER — işaret çağrıyla BİRLİKTE taşınırsa `G35/b` yine YEŞİL

`_ISARET_DESENI` `re.S` ile derleniyor ve `g35b_blok_isaretli` **tüm işaretli blokların
BİRLEŞİMİNE** bakıyor ⇒ **işaretli blok EKLEMEK kapıyı geçmeyi KOLAYLAŞTIRIR.** Denetçinin
ölçümü: korumalı blok `// W1/D-W1-2 bkz. yukaridaki kayit blogu` + `{ app.UseCors(); }` ile
değiştirildiğinde kapı **YEŞİL** — `app.UseCors()` artık **koşulsuz**. `M190` yalnız çağrıyı
*işaretsiz* bir yere koyduğu için ısırıyor; işareti birlikte taşıyan bir refactor **sessizce** geçer.

## 3. BLOKER — `M193b` HİÇBİR ŞEY ÖLÇMÜYOR (sahte-geçiş)

Yama (birebir): `"    // MUTANT M193b: fazladan // yorum\n    app.UseCors();\n"`.
Eklenen yorum kapının aradığı **dokuz dizgeden hiçbirini** içermiyor. Denetçinin yük testi:
yorum-atlama **tamamen sökülünce** `M191b` KIRMIZI oluyor (⇒ yük taşıyor) ama `M193b` **yine SUS**.
⇒ Çalışan bir yorum-atlayıcıyla **hiç olmayan** birini ayırt edemiyor.
🔴 **Kusur önce SPEC'tedir:** §6 `M193b`'yi *"yalnız fazladan `//` yorum eklenir"* diye tanımlıyor —
bu, tanımı gereği ölçemez. Kapının **kendi altın kümesi vaka 12** aynı adı daha güçlü koşuyor
(`// app.UseCors(); // hatirlatma yorumu`). Koşucu spec'e sadık kaldı; **spec zayıftı**.

---

## 4. MAJOR

- **MJ1 — Koşucu hedef ayağı DOĞRULAMIYOR.** Hüküm yalnız `kod != 0`'dan çıkıyor; basılan
  `| [G35a] …` satırları **süs**. Hedefinden başka bir ayaktan ısıran mutant `GECTI` yazılırdı.
  Denetlenen kapının **kendi** altın kümesi daha güçlü: `olculen == sorted(set(beklenen))`.
  ⇒ **koşucu, ölçtüğü kapıdan daha zayıf bir kabul ölçütü kullanıyor.**
- **MJ2 — `EXIT 3` "ISIR" sayılıyor.** Pozitif kontrol düşünce `denetle()` **erken dönüyor** ve
  altı ayağın hiçbiri koşmuyor; dosyayı bozan herhangi bir mutant hedef ayağı hiç ölçülmeden
  `GECTI` alır. `M-o58-1` için kasıtlı, ama **kanal geneldir**.
- **MJ3 — `G35/d` "izinli başlıklar" değil DOSYA GENELİ arıyor.** `.AllowAnyHeader()` + alakasız
  bir satırda geçen iki ad ⇒ kapı **YEŞİL**. Spec'in *"yalnız `AllowAnyHeader()` yetmez"* dediği
  durumun tam kendisi geçiyor. Bugün güvenli olmasının sebebi tesadüf (iki ad `Program.cs`'te
  yalnız satır 106'da geçiyor).
- **MJ4 — `_temiz` DİZE LİTERALLERİNİ atmıyor.** Kusursuz bir günlük satırı
  (`Log.Information("... AllowAnyOrigin ve SetIsOriginAllowed YASAKTIR ...")`) kapıyı **KIRMIZI**
  yapıyor ⇒ `G35/c` yanlış-pozitif üretebilir; `M191b` yalnız `//` yolunu kapsıyor, **dize yolu
  kapsamsız**.
- **MJ5 — "14/14" kriter 6'nın on dördü DEĞİL.** Koşulan adlar `M192`'yi **içermiyor**,
  `M-o58-1` ise kriterde **yok**. Sayı tesadüfen 14. Kriter **fiilen** kapalı (`M192` o57'de
  koşuldu ve `Program.cs` sha'sı o tabanla birebir ⇒ bayat değil) **ama `02-STATIK-MUTANT-KOSUMU.txt`
  bu bağı yazmıyor** ⇒ yalnız o dosyayı okuyan bir denetçi kriter 6'yı kapatamaz.
  🔴 `spec-kapi-kapsama.py` bunu **yakalayamaz**: beyan edilen mutantı sayar, **koşulanı** değil.
- **MJ6 — Yama ile geri-alma arasında `try/finally` YOK.** İstisna/Ctrl-C hâlinde üç ürün dosyası
  **mutantlı kalır** ve kanıt dosyası hiç üretilmez ⇒ hem depo bozulur hem kaza **sessiz** kalır.
  Referans alınan `KANIT/A11/_mutant_kosucu.py`'den bu koruma taşınmamış.

## 5. MINOR

`MN1` betik başlığı *"ON UC"* diyor, liste **14** · `MN2` `sha()` yalnız **32 bit** karşılaştırıyor
ve **yedeğe** karşı (taahhütlü tabana değil); kanıt dosyasında hiçbir hash **yazılı değil** ⇒
`BAYT-OZDES` iddiası artefaktın kendisinden yanlışlanamaz *(bağımsız olarak `git status` ile
doğrulandı)* · `MN3` kapının kendi gerekçesi *"işaret dosyada İKİ KEZ geçer"* diyor, ölçüm **DÖRT**;
sonuç doğru, **gerekçe yanlış** ⇒ gerekçeye dayanan sonraki değişiklik kırılır · `MN4` "ham çıktı"
ham değil, üreticinin **süzdüğü** özet · `MN5` `M191b`'nin marjinal değeri gerçek depoda düşük
(`Program.cs:96` zaten yorumda taşıyor) · `MN6` `M190b` yaması girintiyi bozuk bırakıyor ·
`MN7` çok-yamalı mutantlarda desen-tekliği ön kontrolü **ara duruma** bakmıyor.

---

## 6. NE ÖLÇÜLEMEDİ

1. Denetçi koşucuyu **koşmadı** (ürün dosyalarına yazar) ⇒ `02-…txt`'deki `EXIT=` değerleri bellek
   içi `denetle()` sonuçlarından **çıkarsandı**, gözlenmedi.
2. Kaydedilen koşumun **o anda, o baytlarla** yapıldığı doğrulanamaz; ölçülen şey **tutarlılıktır**.
3. `KANIT/o57/_o57_cowork_mutant_ornegi.py` **açılıp okunmadı**, `M192` **yeniden koşulmadı** ⇒
   `M192`'nin bağımsızlığı **iddiadır**.
4. Hiçbir mutantın **derlenip derlenmediği** ölçülmedi (`dotnet build`/`flutter analyze` koşulmadı).
5. Koşan mutantlar (`M195`–`M197`, `M199`) **kapsam dışıydı**; kriter 7 denetlenmedi (`K80`).
6. §1–§2'deki saldırıların **canlı** davranışı ölçülmedi: `if (true)` hâlinde backend'in üretimde
   gerçekten CORS başlığı döndüğü **koşan sunucuyla** doğrulanmadı (`K80` — Cowork ortam kaldırmaz).
7. `spec-kapi-kapsama.py` **yeniden koşulmadı**; `M-o58-1`'in `## 6` tablosunda olmamasının aracı
   düşürüp düşürmediği ölçülmedi (düşürmemesi beklenir — bu da MJ5'in neden mekanik olarak
   yakalanamadığını açıklar).

---

## 7. HÜKÜM

**`W1` kabulü (`K138`) GERİ ALINMIYOR** — kabul, `A13`/`SS2` emsalindeki gibi **kapanmamış
sınırlarla** verilmişti ve bu bulgular o sınırların **adlandırılmış** hâlidir. Ama iki cümle
yazıya geçer:

1. 🔴 **`W1`'in ana güvenlik kararı — *CORS yalnız Development* — bugün MUTANTSIZ ve KAPISIZDIR.**
   Spec onu `PAZARLIKSIZ` ilan etti, kapı onu ölçmüyor, hiçbir mutant düşürmüyor.
2. 🔴 **Statik mutant koşumu "13'ü okundu, ölçülmedi" borcunu KAPATTI, ama `M193b`'nin sahte-geçişi
   ve `M192`'nin bu dosyada bulunmaması yüzünden kriter 6 YALNIZ BU ARTEFAKTLA kapatılamaz.**

Borçlar: `BORCLAR.md` → `B-W1-5` · `B-W1-6` · `B-W1-7`.
