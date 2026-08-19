# o84 — ÇEKME SIRASI KUSURUNUN KÖK NEDENİ ÖLÇÜLDÜ

**Ölçen:** Cowork · **Tarih:** 18 Ağu 2026 15:0x TSİ (`TZ='Europe/Istanbul' date` ile ölçüldü)
**Nerede:** Cowork bulut konteyneri, `PostgreSQL 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)` — apt ile
kuruldu, `/tmp/pgdata`, port 55432. **Cihazda değil** (cihazda dotnet/docker Cowork'e kapalı).
Ham çıktılar: `01-golge-olcumu.txt` · `02-sayfalama-kaybi.txt` · `03-claim-ve-indeks.txt`
Koşucular: `_olcum.sql` · `_olcum2.sql` · `_sayfalama.py`

---

## 1. KÖK NEDEN — `ORDER BY` çıktı-sütun gölgelemesi · GÜVEN: KESİN

`SyncPuller.cs:37-41` şu sorguyu kuruyor:

```sql
SELECT commit_xid::text, server_seq, payload::text FROM outbox_messages
 WHERE ... ORDER BY commit_xid, server_seq LIMIT 500
```

PostgreSQL'de `commit_xid::text` ifadesinin **çıktı sütun adı yine `commit_xid`**'dir, ve
`ORDER BY`'daki **çıplak ad önce çıktı listesine bağlanır** (SQL standardı ad çözümü). Sonuç:
sıralama `xid8` sütununda değil, onun `::text` kopyasında koşar ⇒ **sözlük sırası**.

Ölçüm (`01-golge-olcumu.txt`, xid 988..1012, 25 satır — üç sorgu, aralarındaki TEK fark yazılı):

| sorgu | tek fark | dönen sıra | EXPLAIN `Sort Key` |
|---|---|---|---|
| **A — ürünün birebir şekli** | — | 1000…1012, **sonra** 988…999 | `((outbox_messages.commit_xid)::text), server_seq` |
| **B** | cast'a ayrı ad (`AS commit_xid_text`) | 988…1012 (doğru) | `outbox_messages.commit_xid, server_seq` |
| **C** | `ORDER BY` nitelendirildi (`o.commit_xid`) | 988…1012 (doğru) | `o.commit_xid, o.server_seq` |

Aynı `Sort Key` dizesi cihazda da ölçülmüştü (`KANIT/o83E/01-tip-olcumu.txt`, PostgreSQL 17.10):
`Sort Key: ((outbox_messages.commit_xid)::text), outbox_messages.server_seq`. **İki farklı sürümde
aynı sonuç** ⇒ sürüme bağlı değil, ad çözümü kuralı.

**Şema ve tip suçlu DEĞİL** (o83-E ölçtü, bu ölçüm doğruluyor): `udt_name`=`xid8`,
`'1000'::xid8 < '988'::xid8` = **f**. `WHERE` tarafı gölgelenmez — çıktı adına bakamaz:
`(commit_xid, server_seq) > ('999'::xid8, 12)` **13 satır** döndürdü (1000…1012), yani **sayısal**.

🔴 **Kusurun özü:** `ORDER BY` **metin**, `WHERE` **sayısal**. İkisi aynı sırayı vermiyor ⇒
imleç sayfalaması kopuyor.

## 2. SONUÇ — SESSİZ VERİ KAYBI · GÜVEN: KESİN

`02-sayfalama-kaybi.txt`: `PullIncrementalAsync`'in döngüsü birebir taklit edildi (ORDER BY ürünün
yazdığı gibi, WHERE ürünün yazdığı gibi, `next` = sayfanın son satırı, devam = satır sayısı ==
PageSize):

| senaryo | ÜRÜN | DÜZELTME |
|---|---|---|
| xid 900..1499 · 600 satır · **PageSize=500 (ürünün gerçek değeri)** | tur 2 · teslim **500** · **KAYIP 100** · sıra yanlış | tur 2 · teslim 600 · kayıp 0 · sıra doğru |
| xid 988..1012 · 25 satır · PageSize=5 | tur 3 · teslim 13 · **KAYIP 12** | tur 6 · teslim 25 · kayıp 0 |
| xid 988..1012 · 25 satır · tek sayfa | kayıp 0 ama **sıra yanlış** (imleç `999`'da kalıyor ⇒ bir tur tekrar teslim) | temiz |

**Kayıp sessizdir:** istemci `devamı var = false` alır, eksik olduğunu ASLA öğrenmez. Bu, kodun
kendi yazılı sözleşmesini çürütür (`DispatcherTests.cs:86-92` "return every change, in order,
exactly once").

## 3. İKİNCİL SONUÇ — indeks boşa gidiyor · GÜVEN: KESİN

`03-claim-ve-indeks.txt` (5.000 satır + `(commit_xid, server_seq)` indeksi):

- **ürün sorgusu:** `Index Scan` **+ ayrı `Sort` düğümü** (`Sort Key: ((commit_xid)::text)…`) —
  eşleşen küme LIMIT'ten önce tümüyle sıralanıyor.
- **düzeltilmiş sorgu:** `Sort` düğümü **YOK**, salt `Index Scan` + `Limit`.

Yani düzeltme yalnız doğru değil, aynı zamanda daha ucuz.

## 4. AYNI SINIFTAN BAŞKA YER VAR MI? · GÜVEN: KESİN (üç yer), ÖLÇÜLEMEDİ (istemci)

`src/backend/Momentum.Infrastructure` içinde `ORDER BY` geçen **7 satırın hepsi** okundu:

- `SyncPuller.cs:41` — 🔴 **HASTA** (tek hasta yer).
- `OutboxClaimStore.cs:25` — **TEMİZ, ölçüldü.** `ORDER BY` iç `SELECT id FROM …` içinde; iç
  çıktı listesinde cast yok. EXPLAIN: `Output: id, commit_xid, server_seq`, `Index Scan`, Sort
  düğümü yok. `commit_xid::text` dıştaki `RETURNING`'de ve iç sıralamayı etkilemiyor.
- `TaskReadStore.cs:32,96,149` — **TEMİZ.** Sıralanan sütunlar (`list_pos`, `pos`, `entity_id`,
  `task_id`, `tag`) çıktı listesinde **cast'sız** duruyor; `::text` yalnız `@cursorPos`
  parametresinde. Gölgeleme yok.
- `SyncPuller.cs:92` — **TEMİZ.** `SELECT DISTINCT aggregate_type, aggregate_id … ORDER BY` aynı
  cast'sız adlar.

## 5. ŞEMA — ISIRTAN TESTİ BAĞLAYAN İKİ MAYIN · GÜVEN: KESİN (kaynak okundu)

`20260718202450_InitialSync.cs:137-139` ham SQL'i:

- `commit_xid xid8 NOT NULL DEFAULT pg_current_xact_id()` ⇒ **DEFAULT'tur, elle YAZILABİLİR.**
- `server_seq bigint GENERATED ALWAYS AS IDENTITY (START WITH 1)` ⇒ **elle YAZILAMAZ**
  (`OVERRIDING SYSTEM VALUE` olmadan insert hata verir). Test bunu üretmeye bırakmalı.
- `available_at`'in `now()` varsayılanı `DispatcherIndexes` migration'ında **kaldırıldı** ⇒ insert
  onu açıkça yazmak zorunda.
- İndeksler: `ux_outbox_messages_commit UNIQUE (commit_xid, server_seq)` ·
  `ix_outbox_messages_owner_cursor (owner_id, commit_xid, server_seq)` ·
  `ix_outbox_dispatch (commit_xid, server_seq) WHERE signaled_at IS NULL`.

## 6. NE ÖLÇÜLEMEDİ

1. **"Flake"in bu kusur olduğu ÖLÇÜLMEDİ — TAHMİN.** `DispatcherTests.Cursor_correctness_…`
   testinin tam pakette düşüp izolasyonda 15/15 geçmesi bu kusurla **tutarlıdır** (izole taze
   DB'de xid sayacı tek basamak grubunda kalır, sınır aşılmaz; tam pakette yüzlerce işlem sayacı
   sınırdan geçirir). Ama bu bağlantı KOŞULARAK gösterilmedi. Yanlışlanabilir tahmin: düzeltmeden
   sonra o test tam pakette 3/3 geçer. Geçmezse **ayrı** kusurdur.
2. **Cihazda hiçbir şey koşulmadı.** Cowork'ün Linux alanında `dotnet`/`pwsh`/`docker` yok (o83'te
   ölçüldü). Ürün kodu KOŞTURULARAK değil, kaynağı okunarak ve sorgu şekli birebir taklit
   edilerek ölçüldü.
3. **PostgreSQL sürüm farkı:** ölçüm 16.13'te; ürün/CI 17.x. Gölgeleme her ikisinde de görüldü
   (17.10 kanıtı `KANIT/o83E`), ama 600 satırlık kayıp senaryosu 17.x'te KOŞULMADI.
4. **İstemci (Flutter/drift) tarafında** imleç saklama/sıralama incelenmedi.
5. **Üretimde kaç kullanıcının etkilendiği** ölçülemez (telemetri yok). `v1.0.1` bu kusurla
   teslim edildi; kusur kimlik diliminden ÖNCE vardı.
