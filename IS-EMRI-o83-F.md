# İŞ EMRİ o83-F — ÇEKME SIRASI: gölgelenmiş `ORDER BY` (DÜZELTME + ISIRTAN TEST)

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, 18 Ağu 2026] · Kök neden kanıtı: `KANIT/o84/00-CEVAP.md`

---

## 0. DEMİR KURALLAR

1. 🔴 **TEK KUSUR, TEK DÜZELTME.** Bu emirde başka hiçbir şey düzeltilmez: c ayağı regresyonu,
   `verify.ps1`, DURUM.md, README, migration, şema, `OutboxClaimStore`, `TaskReadStore` — **hiçbiri.**
2. 🔴 **ÖNCE TEST KIRMIZI YANAR.** Yeni test, düzeltme İNMEDEN koşulur ve **düşmek zorundadır**;
   ham çıktısı kanıt olarak saklanır. Kırmızı kanıtı olmayan test, kusuru ısırdığını kanıtlamaz
   (o80 dersi: kapı gövdede zaten var olan bir dizeyi arıyordu, dört ayak yalancı yeşil yandı).
3. 🔴 **Test düzeltmeden ÖNCE GEÇERSE: DUR.** Düzeltmeyi uygulama, sebebini yaz, emri geri ver.
4. **PUSH YOK.** Commit serbest (yol belirterek), push Onur'da.

---

## 1. KUSUR NE (Cowork ölçtü — `KANIT/o84/`, PostgreSQL 16.13 + cihazdaki 17.10 çapraz doğrulaması)

`SyncPuller.cs:37-41`:

```sql
SELECT commit_xid::text, server_seq, payload::text FROM outbox_messages
 WHERE ... ORDER BY commit_xid, server_seq LIMIT 500
```

PostgreSQL'de `commit_xid::text` ifadesinin **çıktı sütun adı yine `commit_xid`**'dir ve
`ORDER BY`'daki **çıplak ad önce çıktı listesine bağlanır**. Sıralama `xid8` sütununda değil, onun
metin kopyasında koşar. `WHERE` gölgelenmez (çıktı adına bakamaz), orada karşılaştırma **sayısal**.

> **ORDER BY metin · WHERE sayısal ⇒ imleç sayfalaması kopar.**

Ölçülen sonuç (ürünün gerçek `PageSize=500`'ü, 600 satır, xid 900..1499):
**500 satır teslim, 100 DEĞİŞİKLİK KAYIP, istemci "devamı yok" alır.** Sessiz kayıp.
Tek sayfaya sığan durumda kayıp yok ama sıra yanlış ve imleç geride kalır (bir tur tekrar teslim).

Şema ve `xid8` **suçlu değil** (o83-E + o84): `udt_name`=`xid8`, `'1000'::xid8 < '988'::xid8` = **f**.
`ORDER BY` nitelendirilince ya da cast'a ayrı ad verilince sıra düzeliyor **ve** `Sort` düğümü
tamamen kalkıyor (indeks taraması yetiyor).

**Aynı sınıftan başka yer yok:** `ORDER BY` geçen 7 satırın hepsi okundu; `OutboxClaimStore.cs:25`
iç `SELECT id …` olduğu için temiz (EXPLAIN ile ölçüldü), `TaskReadStore` cast'sız sütunla sıralıyor.

---

## 2. §A — DÜZELTME (tek dosya, tek ifade)

`src/backend/Momentum.Infrastructure/Sync/SyncPuller.cs` → `PullIncrementalAsync` içindeki SQL.

**İKİ KEMER birden takılır** (biri diğerini yedekler; ikisi de ayrı ayrı ölçüldü, ikisi de yeşil):

- (a) tabloya takma ad ver ve `ORDER BY`'ı **nitelendir** → `ORDER BY o.commit_xid, o.server_seq`
- (b) cast'lı çıktı sütunlarına **ayrı ad** ver → `o.commit_xid::text AS commit_xid_text`,
  `o.payload::text AS payload_text` (böylece hiçbir çıktı adı bir sütun adını gölgeleyemez)

`WHERE` yüklemi, parametreler, `LIMIT`, okuyucu sıra numaraları (`GetString(0)` / `GetInt64(1)` /
`GetString(2)`), `next` hesabı ve `PullPage` **AYNEN KALIR**. Aynı dosyadaki `ShouldResyncAsync`,
`SnapshotAsync`, `ReadHorizonAsync`, `ReadOwnedEntitiesAsync`, `Project` **DOKUNULMAZ**.

Satır 35'teki yorum (`xid8 has no bigint cast…`) duruyor; altına **tek satır** eklenir:
gölgelemeyi ve neden nitelendirildiğini anlatan bir cümle + `KANIT/o84` atfı. Yorum şişirilmez.

---

## 3. §B — ISIRTAN TEST (yeni dosya, iki test)

**Dosya:** `tests/Momentum.Persistence.Tests/PullCursorOrderTests.cs`
Mevcut Persistence fixture'ı kullanılır — **yeni harness/fixture/yardımcı sınıf YAZILMAZ**.
(Bunlar normal ürün testidir, kapı bütçesine girmez — İŞLEYİŞ md.3.)

### 3.1 Satır yazma yardımcısı (test dosyasının içinde, `private`)

Ham SQL ile `outbox_messages`'a satır yazar. **`OutboxWriter` KULLANILMAZ** (o `commit_xid` yazamaz).
Şema mayınları (kaynak okundu, `InitialSync.cs:137-139` + `DispatcherIndexes.cs`):

- `commit_xid` = `DEFAULT pg_current_xact_id()` ⇒ **elle yazılabilir**, açıkça yazılacak.
- `server_seq` = `GENERATED ALWAYS AS IDENTITY` ⇒ **elle YAZILAMAZ**, üretime bırakılacak
  (satırlar xid'e göre ARTAN sırada yazılırsa `server_seq` de artan olur).
- `available_at`'ın `now()` varsayılanı kaldırıldı ⇒ **açıkça yazılacak**.
- `payload` `jsonb NOT NULL` ⇒ `'{}'::jsonb`. Diğer NOT NULL alanlar (`aggregate_type`,
  `aggregate_id`, `operation_id`, `actor_id`, `event_type`, `hlc`, `occurred_at`) doldurulacak.
- Tek `INSERT … SELECT … FROM generate_series(...)` yeterli.

**Sınır penceresi (pazarlıksız — sabit xid YAZMA):** çekme sorgusu
`commit_xid < pg_snapshot_xmin(pg_current_snapshot())` istiyor ⇒ yazılan xid'ler o anki ufkun
ALTINDA olmalı. Test önce `X = pg_snapshot_xmin(pg_current_snapshot())` okur.

🔴 **[o84-B düzeltmesi, 18 Ağu — ölçüldü]** Kaybı doğuran değişmez şudur, pencere buna göre kurulur:

> **(i)** sınırın **üstünde tam `PageSize` (500) satır**, **(ii)** altında en az bir satır, ve
> **(iii)** alt grubun tamamı **sözlük sırasında üst gruptan SONRA** gelmeli.

(iii) kendiliğinden olmaz: `B=100` için üst grup `100..599` değerleri `1..5` ile başlar, alt gruptan
`10..19` bunların **arasına karışır**. Her zaman doğru olan tek alt grup, `B`'nin altındaki
**hepsi 9 ile başlayan onluk**tur (`90..99`, `900..999`) — bunlar her üst değerden sonra gelir.

**Kural:**

- `B` = **`B + 499 < X`** ve **`B >= 100`** koşullarını sağlayan **en büyük 10 kuvveti**
- pencere = **`9*B/10 … B+499`** ⇒ alt blok `9*B/10 … B-1` (`B/10` satır), üst blok `B … B+499`
  (**tam 500 = `PageSize`**). Toplam `B/10 + 500` satır.
- `B=1000` ⇒ `900..1499` (600 satır, X>1499 ister) · `B=100` ⇒ `90..599` (510 satır, X>599 ister)

**Cowork ölçtü (`KANIT/o84`, PostgreSQL 16.13):** X=752 ⇒ `B=100` ⇒ pencere `90..599`:
ürün sorgusu **500 teslim / 10 KAYIP / sıra yanlış**, düzeltilmiş sorgu **510 teslim / kayıp 0**.
Yani X=752 altında test **ısırıyor** — tam pakete geçmeye gerek yok.

**`X <= 599` ise** (hiçbir `B` sığmıyorsa): test önce **ayrı işlemlerde** `SELECT pg_current_xact_id()`
koşarak sayacı `X > 600` olana kadar ilerletir (**yakılan işlem sayısını CEVAP'a yazar**), sonra `B`'yi
yeniden hesaplar. Bundan sonra da sığmıyorsa `Assert.Fail` ile **ölçülen X'i yazarak** düşer —
sessizce atlanmaz.

🔴 **YASAK ÇÖZÜM:** pencereyi tutturmak için testi **tam pakette / başka testlerin ardından** koşmak.
Geçerliliği "kaç test önce koştu"ya bağlı bir test, bu projeyi zaten bir kez ısıran bağlam
bağımlılığının aynısıdır; CI'da taze veritabanında yalancı kırmızı ya da sessiz geçiş üretir.
Kırmızı ve yeşil ölçümleri **izole** koşulur (adım 1 ve 3); tam paket yalnız adım 4'tedir.

### 3.2 Test 1 — sıra ve imleç (25 satır, tek sayfa)

`(oncesi:12, sonrasi:12)` ⇒ 25 satır, tam basamak sınırında (ör. 988…1012).
Sıfır imleçten **tek** `PullIncrementalAsync` çağrısı. Doğrulanacaklar:

- dönen satır sayısı = 25
- dönen sıra, yazılan sıraya **birebir** eşit (imleçler `(Xid, Seq)` ikilisinde **sayısal** artan)
- `PullPage`'in `next` imleci = **yazılan en büyük** `(commit_xid, server_seq)`

### 3.3 Test 2 — sayfalama kaybı (600 satır, gerçek `PageSize`)

Yukarıdaki kural ⇒ `9*B/10 … B+499` (X>1499 ise 600 satır, X=752 ölçümüyle 510 satır). `devamı var` bayrağı `false` olana kadar döngüyle çekilir
(en fazla 10 tur; aşarsa `Assert.Fail`). Doğrulanacaklar:

- **teslim edilen benzersiz satır sayısı = yazılan satır sayısı** (kayıp 0)
- tekrar yok
- tüm turlar birleştirildiğinde sıra sayısal olarak artan

🔴 Testlerde **zamanlama, eşzamanlılık, `Task.Delay`, rastgelelik, tekrar denemesi YOK.**
Bu kusur deterministiktir; test de deterministik olacak.

---

## 4. SIRA (bu sırayla koşulacak, her adımın ham çıktısı saklanacak)

1. Test dosyası yazılır. **Düzeltme İNMEDEN** yalnız bu iki test koşulur
   → `KANIT/o83F/01-test-KIRMIZI-duzeltme-oncesi.txt`. **İkisi de DÜŞMELİ.**
   (Test 1 sıra iddiasında, Test 2 kayıp iddiasında düşer. Biri geçerse sebebini yaz.)
2. §A düzeltmesi uygulanır (tek ifade).
3. İki test yeniden koşulur → `KANIT/o83F/02-test-YESIL-duzeltme-sonrasi.txt`. **İkisi de geçmeli.**
4. **Tam Persistence paketi 3 kez** koşulur → `KANIT/o83F/03-tam-paket-3-kosum.txt`.
   Her koşumda `DispatcherTests.Cursor_correctness_is_unaffected_by_concurrent_dispatch_single_owner`
   testinin outcome'u **ayrı ayrı** yazılır.
   🔴 **Yanlışlanabilir tahmin (Cowork'ün, ÖLÇÜLMEDİ):** "flake" bu kusurdu ⇒ düzeltmeden sonra o
   test **3/3 geçer**. **Geçmezse KOVALAMA** — ayrı kusurdur, tek cümleyle yaz, emir burada biter.
5. `KANIT/o83F/00-CEVAP.md` yazılır (aşağıdaki altı satır, yorum yok).

---

## 5. CEVAP — `KANIT/o83F/00-CEVAP.md`, altı satır

1. Ölçülen `X` (`pg_snapshot_xmin`), seçilen `B`, yazılan xid aralıkları ve satır sayıları
   (xid yakıldıysa kaç işlem yakıldığı).
2. Düzeltme öncesi Test 1 / Test 2 outcome'u (**beklenen: ikisi de Failed**) + düşme mesajları.
3. Düzeltme sonrası Test 1 / Test 2 outcome'u (**beklenen: ikisi de Passed**).
4. Tam paket 3 koşumun her birinde toplam geçen/düşen + `Cursor_correctness_…` outcome'u.
5. `SyncPuller.cs`te değişen satır sayısı (beklenen: 1 ifade + 1 yorum satırı).
6. `git --no-optional-locks status --porcelain -- src tests` çıktısı (yalnız bu iki dosya görünmeli).

---

## 6. KABUL

- [ ] `KANIT/o83F/01-…KIRMIZI…txt` var ve **iki testin de DÜŞTÜĞÜ** ham çıktıyla
- [ ] `KANIT/o83F/02-…YESIL…txt` var ve iki test de geçiyor
- [ ] `KANIT/o83F/03-tam-paket-3-kosum.txt` üç koşumun tamamını taşıyor
- [ ] `KANIT/o83F/00-CEVAP.md` altı maddeyi içeriyor
- [ ] Değişen ürün dosyası **yalnız** `SyncPuller.cs`; değişen test dosyası **yalnız** yeni
      `PullCursorOrderTests.cs`
- [ ] Commit atıldı: **yol belirterek** (`git add -A` YASAK), mesajda **çift tırnak yok**,
      author `onurkesimbjk@gmail.com`, **push YOK**
- [ ] `KANIT/slice-3c/02-G2/*.json` commit'e **girmedi** (mayın 19)

## 7. DOKUNMA LİSTESİ

- ❌ c ayağı regresyonu (o83-C §2) · `verify.ps1` · `DURUM.md` · `README.md` · `arsiv/`
- ❌ migration · şema · `OutboxClaimStore` · `TaskReadStore` · `TestSupport.cs` havuz kelepçesi
- ❌ `DispatcherTests.cs`e dokunmak (o83-D'nin geçici enstrümantasyonu hâlâ duruyorsa **yalnız onu**
      geri al, başka satırına dokunma — ve bunu CEVAP'ta yaz)
- ❌ Yeni ADR/spec/plan/kapı dosyası yazmak · yeni bağımlılık · push
