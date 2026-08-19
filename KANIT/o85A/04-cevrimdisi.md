# IS-EMRI-o85-A SS8 madde 4 — ÇEVRİMDIŞI (CANLI)

**Ne ölçüldü:** çevrimdışıyken liste yaratma **+ görev taşıma**, bağlantı
gelince kendiliğinden eşitleme. Gerçek çalışan backend'e (`docker compose`,
aynı imaj) karşı, gerçek `/v1/sync` çağrılarıyla.

Script: `KANIT/o85A/_canli_tur_o85a_cevrimdisi.py` · ham çıktı:
`KANIT/o85A/04-cevrimdisi-ham.txt`.

## "Çevrimdışı" iddiası nasıl gerçek kalıyor

Adım 1'de **hiçbir `/v1/sync` çağrısı yapılmıyor** — üç `WireOp` gövdesi
sadece Python'da kuruluyor ve bir sonraki adıma kadar hiçbir ağ isteği
çıkmıyor. Bu, istemcinin gerçek mimarisiyle birebir örtüşür: K112'nin
`_yerelYaz` deseni yerel yazmayı **atomik ve senkron** yapar, itme
(`SenkronDongusu`) **ayrı ve sonraki** bir turdur — `liste_dilimi_test.dart`
zaten bu üç op şeklini `NativeDatabase.memory()` ile **sıfır ağ bağlantısıyla**
üretip doğruluyor (bkz. `KANIT/o85A/02-op-ornekleri.json`). Buradaki yeni ölçüm,
aynı üç op şeklinin gerçek sunucuya push edilip **ikinci bir istemciden
görülebilir olduğunun** uçtan uca kanıtıdır.

## Senaryo ve sonuç

| # | Eylem | Ağ çağrısı? |
|---|---|---|
| 1a | Liste yarat ("Tatil") | ❌ yok (kuyrukta bekliyor) |
| 1b | Mevcut bir görev doğar ("Bileti al", `projectId` YOK) | ❌ yok |
| 1c | O görev "Tatil" listesine **taşınır** (ayrı op, `fields:projectId`) | ❌ yok |
| 2 | **Bağlantı gelir** — kuyruktaki 3 op **TEK turda** pushlanır | ✅ `POST /v1/sync` → 3/3 `Applied` |
| 3 | **TAZE ikinci istemci** ilk pull'unda (`sinceCursor:null`) ikisini de görüyor mu? | ✅ liste VAR, görev VAR, `projectId` **DOĞRU** listeye işaret ediyor |

Adım 3'ün sonucu ayrıca **LWW alan-düzeyinde birleşimi** de doğruluyor: görev
iki AYRI op'tan geldi (doğuş: `title`, taşıma: `projectId`) ama snapshot'ta
**TEK varlık** olarak, iki alan da dolu görünüyor — sunucu tarafında
field-level merge çalışıyor, taşıma op'u doğuş op'unun `title`'ını EZMEDİ.

## Kanıtladığı iş emri maddeleri

- **Çevrimdışı çalış, bağlantı gelince kendiliğinden eşitle** (BİTTİ LİSTESİ
  §2, önceden ✅ işaretli genel özellik) — bu dilimin YENİ op şekilleriyle
  (Project yaratma, Task.projectId taşıma) **de** geçerli olduğu canlı
  ölçüldü.
- **B1/B2** ayrı ayrı — liste yaratma ve görev taşıma **farklı offline
  anlarda** kuyruğa yazılsa bile, reconnect'te sıralı ve doğru uygulanıyor.
- **K5'in dolaylı önkoşulu**: taşıma gerçek bir alan yazımı olarak sunucuya
  ulaşıyor (client-side `projectId` DEĞİŞTİRİLMEDEN bırakılan silme
  senaryosunun *tersi* — burada gerçek bir taşıma, gerçek bir yazım).
