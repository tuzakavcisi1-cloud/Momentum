# İŞ EMRİ o85-A2 — o85-A DENETİM KAPANIŞI: K5 kapısı + yarım dikiş + eksik beyan

`MOD: NORMAL` · kutu **22-23 Ağu 2026** · yazan: Cowork (bağımsız denetim) · koşacak: **Claude Code**
Kilit: [Onur, **19 Ağu 2026**] · Öncül: `f54ad06` denetlendi — **üç bulgu**, ürün doğru, kapı eksik

---

## 0. DEMİR KURALLAR

1. 🔴 **§A TEST-ONLY.** `gorev_listesi_ekrani.dart` **DEĞİŞMEZ** — ürün kodu doğru ölçüldü,
   eksik olan kapıdır. Testi geçirmek için ürünü değiştirme dürtüsü olursa **DUR ve bildir**.
2. 🔴 **ÖNCE KIRMIZI KANITI** (o83-F deseni). Her yeni test, **mutant üstünde koşturulup
   düşürüldüğü** gösterilmeden yeşil sayılmaz. Mutant uygulanır → KIRMIZI ham çıktı KANIT'a →
   mutant **geri alınır** (`git diff` boş dönmeli) → yeşil ham çıktı KANIT'a.
3. 🔴 **Yeni kapı DOSYASI açılmaz** (DURUM sınır 3). §A testleri **mevcut
   `test/liste_baglam_test.dart`** içine eklenir — ekran davranışının zaten orada ölçüldüğü dosya.
4. 🔴 **§B için TEST YAZILMAZ.** Gerekçe §B'de. Erişilemez yola kapı yazmak **kapı tiyatrosudur**.
5. `src/backend/**` · migration · şema · `verify.ps1` · `CLAUDE.md` · `.github/workflows/*`: **dokunma**.
6. **PUSH ONUR'DA.**

---

## 1. NEREDEYİZ — o85-A denetimi (Cowork ölçtü, 19 Ağu, artefakta bakarak)

**Tutan (bağımsız doğrulandı):** sunucu kodu değişmedi (`git show --stat`) · `wire_op.dart`
**mtime değişmemiş** ⇒ `order` kanalı eklenmedi · migration duplicate-column koruması doğru
(`newColumns` + `!gorevlerYenidenYaratildi`), v1→v8 zincir testi var · `entityType.equals('Task')`
korundu · `KANIT/slice-3c/02-G2/*.json` commit'e girmedi · **canlı turun Python zarfı, Dart'ın
gerçek `WireOp.toJson()` çıktısıyla (`02-op-ornekleri.json`) alan alan aynı** · canlı iddialar
`SystemExit` ile gerçekten düşüyor · D4 testi pozitif kontrollü ve güçlü.

**Bulgular — üçü de bu emirle kapanır.**

---

## 2. §A — 🔴 BULGU 1: K5 KAPISIZ (KABUL maddesi karşılanmadı)

`gorev_listesi_ekrani.dart:489-490` **doğru yazılmış**:
```dart
return g.gorev.projeId == null ||
    !aktifListeIdleri.contains(g.gorev.projeId);
```
`_etkinSecim` (satır ~138-141) de silinmiş seçimden Gelen Kutusu'na doğru düşüyor.

**Ama hiçbir test bunu ısırmıyor** (ölçüldü): `aktifListeIdleri` istemci testlerinin **hiçbirinde**
geçmiyor · `liste_dilimi_test.dart`'ın 13 testinin hiçbiri silinmiş listeye işaret eden görev
kurmuyor · `liste_baglam_test.dart` hiç liste silmiyor.

⇒ İkinci koşulu silen mutant **silinmiş listedeki her görevi ekrandan yok eder** ve **749/749
yeşil kalır**. KABUL listesinin **veri kaybı sonucu olan tek maddesi** budur.

### A1 — test: yetim görev Gelen Kutusu'nda görünür

`liste_baglam_test.dart`e eklenir. Sahte depo `listelerGorunur()` ile **yalnız `p1`** yayınlar;
görev akışına **üç** satır konur:
- `g-inbox` (`projeId: null`)
- `g-is` (`projeId: 'p1'`) — **pozitif kontrol**, Gelen Kutusu'nda görünMEmeli
- `g-yetim` (`projeId: 'p-silinmis'` — listelerde YOK)

**Beklenti (Gelen Kutusu aktifken):** `g-inbox` **ve** `g-yetim` görünür · `g-is` **görünmez**.
🔴 Pozitif kontrol pazarlıksız: `g-is`in görünmediği ayrıca `expect`lenir — yoksa "her şeyi göster"
mutantı testi geçer.

### A2 — test: seçili liste silinince ekran Gelen Kutusu'na düşer

`p1` seçilir (Drawer'dan, A1'in mevcut deseni) ve görevlerin süzüldüğü doğrulanır. Sonra
`listelerGorunur()` **`p1`siz** bir liste yayınlar (başka cihazdan silinme). **Beklenti:**
ekran Gelen Kutusu'na düşer · `g-is` artık **yetim** olduğu için **görünür** · Drawer'da
Gelen Kutusu **seçili** görünür.

> Sahte deponun `listelerGorunur()`ü bugün `Stream.value([...])` döndürüyor ⇒ **ikinci bir değer
> yayınlayabilmesi için `StreamController`a çevrilmelidir.** Görev akışının mevcut deseninin aynısı.

### A3 — 🔴 ÖNCE KIRMIZI (pazarlıksız)

İki mutant, **ayrı ayrı** uygulanır ve ilgili testin **düştüğü** gösterilir:
- **M1:** `gorev_listesi_ekrani.dart:489-490` → yalnız `return g.gorev.projeId == null;`
  ⇒ **A1 KIRMIZI** olmalı.
- **M2:** `_etkinSecim` → `return id;` (geçerlilik denetimi silinir) ⇒ **A2 KIRMIZI** olmalı.

Her mutant için **ham `flutter test` çıktısı** KANIT'a. Sonra **ikisi de geri alınır**;
`git --no-optional-locks status --porcelain -- src/client/lib` **BOŞ** dönmeli (ürün kodu
değişmedi kanıtı). Mutant sağ kalırsa **test yetersizdir, test düzeltilir** — ürün değil.

---

## 3. §B — BULGU 2: `sets` kanalı entityType dalının DIŞINDA (tek satır)

`uzak_degisiklik_uygulayici.dart:255-259`: `fields`/`groups`/`order` `entityType`'a göre
dallanıyor, **`sets` dallanmıyor** — döngü seviyesinde, her entityType için koşuyor. Bir `Project`
varlığına `sets['tags']` gelse `gorevEtiketleri`'ne **projenin id'siyle** satır yazardı.

**Düzeltme:** `sets` bloğu `if (entityType == 'Task') { … }` içine alınır (öteki üç kanalın
şeklinin aynısı). `changesUygula` **ve** `snapshotUygula`, ikisinde de.

🔴 **Mevcut beyan edilmiş sınır KORUNUR:** "sets, VAR OLMAYAN bir entity için gelirse etiket satırı
yazılır ama `Gorevler` satırı DOĞMAZ" — `entityType == 'Task'` bunu **aynen** korur (`g` null
kontrolü DEĞİL, entityType kontrolü). Yorum bloğu silinmez, altına bir satır eklenir.

🔴 **BU SATIRA KAPI YAZILMAZ.** Gerekçe kayda geçer: sunucunun `FieldStrategyRegistry.
IsOperationValid`'i `Project` üzerinde `tags`'i **bütün op'u reddederek** engelliyor ⇒ yol
**erişilemez**. Erişilemez yola mutant yazmak öldürülemez bir kapı üretir; bu proje kapı
tiyatrosu yazmaz. Düzeltme bir **daraltmadır**; mevcut etiket testleri `Task` yolunun bozulmadığını
zaten ısırıyor.

---

## 4. §C — BULGU 3: README'de AD BEYANI EKSİK

o85-A `README.md`ye listeleri ve klasör kesmesini yazdı, ama **ad beyanını yazmadı** (ölçüldü:
`grep -n "Project" README.md` → yalnız ilgisiz iki satır). İş emri §E2 bunu istemişti.

**Eklenecek — tek cümle**, listeleri anlatan paragrafın hemen altına:

> Üründe **"Liste"** denen kap, kodda ve senkron telinde **`Project`** entity'sidir (birincil
> referans Todoist'te de kap "Project"tir); `TaskList` entity'si registry'de duruyor ama bu
> sürümde **kullanılmıyor**.

Bu proje **gizlenmiş sınır kabul etmez** — değerlendirici kodu açtığında karşılaşacağı ilk
çarpıklık budur ve beyan edilmiş olmalıdır.

---

## 5. §D — DURUM.md (tek satır)

Madde 32 ve 33 o85-A'da **zaten yazıldı** — dokunma. **Bir satır eklenir:**

> 34. **[o85-A BEYAN] Liste diliminin canlı ölçümü PROTOKOL SEVİYESİNDEDİR** (`/v1/sync` HTTP
>     çağrıları, `KANIT/o85A/_canli_tur_o85a*.py`) — **Flutter UI'ı canlı koşturulmadı**; ekran
>     davranışı widget testleriyle ölçüldü. o83-G'nin kimlik ölçümüyle aynı yöntem ve aynı sınır.

---

## 6. §E — KANIT

- `KANIT/o85A2/00-CEVAP.md` (dört satır, §7)
- `01-M1-kirmizi.txt` — M1 mutantı altında **A1'in düştüğü** ham `flutter test` çıktısı
- `02-M2-kirmizi.txt` — M2 mutantı altında **A2'nin düştüğü** ham çıktı
- `03-mutant-geri-alindi.txt` — `git --no-optional-locks status --porcelain -- src/client/lib`
  çıktısı (**boş** olmalı) + son yeşil `flutter test` özeti

---

## 7. CEVAP — `KANIT/o85A2/00-CEVAP.md`, dört satır

1. A1 ve A2'nin **tam test kodu** (olduğu gibi).
2. M1/M2 mutantlarının **tam diff'i** ve her birinin düşürdüğü testin adı + hata satırı.
3. `flutter analyze` sonucu + `flutter test` sayısı (koşum dizini **`src/client`** — mayın 1).
4. `git --no-optional-locks status --porcelain -- src tests` ham çıktısı;
   `src/client/lib/sunum/gorev_listesi_ekrani.dart` **GÖRÜNMEMELİ** (§A test-only).

## 8. KABUL

- [ ] A1 ve A2 `liste_baglam_test.dart` içinde; **yeni kapı dosyası açılmadı**
- [ ] A1'de `g-is`in Gelen Kutusu'nda **görünmediği** ayrıca `expect`lendi (pozitif kontrol)
- [ ] M1 → A1 KIRMIZI · M2 → A2 KIRMIZI, **ham çıktılarla** kanıtlandı
- [ ] Mutantlar geri alındı: `status --porcelain -- src/client/lib` **boş**
- [ ] `sets` bloğu `entityType == 'Task'` içine alındı — `changesUygula` **ve** `snapshotUygula`
- [ ] `sets` düzeltmesine **test yazılmadı**, gerekçesi kodda tek satır
- [ ] README'de ad beyanı var
- [ ] DURUM.md'de madde 34 var; 32/33'e **dokunulmadı**
- [ ] `flutter analyze` 0 · testler yeşil · `dart format` yalnız dokunulan dosyada (sınır 27)
- [ ] Tek commit, **yol belirterek**, çift tırnaksız mesaj, author `onurkesimbjk@gmail.com`
- [ ] 🔴 **PUSH YOK** · `KANIT/slice-3c/02-G2/*.json` girmedi (mayın 19)
- [ ] Kanıt dosyası **kendi commit'inin hash'ini yazmaz**

## 9. DOKUNMA LİSTESİ

- ❌ `gorev_listesi_ekrani.dart` (§A **test-only** — testi geçirmek için ürünü değiştirme)
- ❌ `src/backend/**` · migration · Drift şeması · `veritabani.g.dart`
- ❌ `verify.ps1` · `CLAUDE.md` · `arsiv/` · `.github/workflows/*`
- ❌ DURUM.md madde 32/33 · yeni kapı dosyası · `sets` düzeltmesine kapı
- ❌ **PUSH** — sıradaki adım Onur'un
