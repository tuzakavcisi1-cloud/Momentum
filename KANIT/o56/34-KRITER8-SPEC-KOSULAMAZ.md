# 🔴 BULGU — `SS2` KRİTER 8 SPEC'İN YAZDIĞI GİBİ KOŞULAMAZ (oturum 56, Cowork ölçtü)

## İddia
Kilitli spec (`GOREV-SS2-cakisma-cozumu.md`, `K133`, `420E9F91`) §7 kriter 8:
- ④ *"Cihaz B çevrimdışına alınır …, **başlık `B1` yapılır** ⇒ op kuyrukta"*
- ⑤ *"Cihaz A … **aynı görevin başlığını `A1` yapar** ve senkronize olur"*

**Bu iki adım bugünkü üründe UI'dan YAPILAMAZ: uygulamada görev başlığını DÜZENLEYEN bir
etkileşim YOKTUR.**

## Ölçüm (üç bağımsız tarama, hepsi `KANIT/o56/_tara.py` ile; pozitif kontrol: 42–110 dosya okundu)

1. **`\.duzenle\(` çağrısı `lib/` altında YALNIZ deponun kendisinde:**
   `veri/gorev_deposu.dart:77` (arayüz) · `:330` (uygulama) · `:449` (**`cakismaCoz`**'un
   *Benimkini tut* dalı). `sunum/` altında **tek bir çağıran yok**.
2. **Satırda düzenleme yolu yok:** `sunum/gorev_satiri.dart:10-12` **kendi kaynağında**
   şöyle yazıyor: *"PAZARLIKSIZ DOKUNMA SINIRI (T6): bu widget'in kendisi `onTap`
   TAŞIMAZ"*. `onLongPress` · `Dismissible` · `Slidable` · `PopupMenu` **hiçbiri yok**.
   `sunum/` altındaki tek `GestureDetector` **çakışma rozetinin** (`cakisma_rozeti.dart:51`),
   tek `InkWell` **ekleme düğmesinin** (`gorev_ekle_alani.dart:71`).
3. **Ekrandaki tek `IconButton`** `gorev_listesi_ekrani.dart:83`, `tooltip: 'Yenile'`.
   Cihaz dökümü de bunu doğruluyor (`KANIT/o56/30-ilk-ekranlar.txt`): satırlar `CheckBox`,
   ekranda **Yenile** ve **Ekle** dışında düğme yok.

## Sonuç
`duzenle()` bugün **yalnız çakışma çözümünden** tetikleniyor ⇒ *başlık düzenlemek için önce
çakışma, çakışma için önce başlık düzenlemek* gerekiyor. **Kriter 8'in lafzı kendi kendini
kilitliyor.**

🔴 **Bu, oturum 55'in kilidinde GÖRÜLMEMİŞ bir kusurdur:** spec, ürünün taşımadığı bir
etkileşimi kabul şartı yapmış. Kâğıt üzerinde iki denetim turu geçti, çünkü hiçbir tur
*"bu adım cihazda fiilen yapılabiliyor mu"* diye **ölçmedi**.

## Çakışma yine de üretilebilir (ölçülmüş yol)
Çakışma tespiti (`G32`) `kanonikDize` eşitsizliğine bakar ve `kanonikDize`
**tamamlanma alanını da taşır** (`M187`: `groups:completion` dalı). ⇒ **tamamlanma
anahtarıyla** (`tamamlaGeriAl`, satırdaki `CheckBox`) gerçek bir çakışma üretilebilir.

Değerlerin FARKLI olması şart (şart 4 eşitliği eler). Bu yüzden sıra şöyle olmalı:
1. B çevrimdışı → `CheckBox` **bir kez** → B'nin bekleyen değeri **tamamlandı**
2. A çevrimiçi → `CheckBox` **iki kez** (tamamlandı → tamamlanmadı) ⇒ sunucudaki değer
   **tamamlanmadı** ve HLC'si B'ninkinden **SONRA**
3. B çevrimiçi → bekleyen op varken bir tur ⇒ **çakışma** (`tamamlandı` ↔ `tamamlanmadı`)
4. *Benimkini tut* ⇒ B'de **tamamlandı** görünür ve A'ya ulaşır

**Bu, spec'in LAFZINDAN sapmadır** (başlık yerine tamamlanma) ama **aynı mekanizmayı**
(`G32` dört şartı · `G33` rozet/projeksiyon · `G34` çözüm) egzersiz eder. Kilidi Onur verir.
