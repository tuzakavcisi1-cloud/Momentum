# İŞ EMRİ o83-E — `commit_xid` GERÇEKTE HANGİ TİP? (beş sorgu, başka hiçbir şey)

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, 18 Ağu 2026]

---

## 0. DEMİR KURAL

🔴 **BU BİR ÖLÇÜM. HİÇBİR ŞEY DÜZELTİLMEYECEK.** Ne ürün, ne şema, ne test, ne migration.
Çıktı: **beş sorgunun cevabı**. Yorum yok, öneri yok, düzeltme yok.

---

## 1. NEREDEYİZ

o83-D ölçtü: `ORDER BY commit_xid, server_seq` şu sırayı döndürüyor —
`1000,1001,…,1012` **sonra** `988,…,999`. Sınır tam **999→1000**, yani ondalık basamak
sayısı değişimi. `1000 < 988` yalnız **dize** karşılaştırmasında doğrudur.

Cowork iki adayı ölçtü:

- **A — C# tarafında dize sıralaması.** ❌ **ÇÜRÜDÜ.** `SyncPuller.cs:47-59` reader sırasını
  aynen koruyor, hiçbir `OrderBy` yok, `next = changes[^1].Cursor`, `ulong.Parse` doğru.
- **B — canlı şemada sütun gerçekte metin.** Açık. Migration
  (`20260718202450_InitialSync.cs:137`) `xid8` diyor, ama canlı tabloda ölçülmedi.

---

## 2. ÖLÇÜM — beş sorgu

Migration'ları uygulanmış herhangi bir veritabanına koş (`docker compose` Postgres'i ya da
taze bir test konteyneri — hangisini kullandığını YAZ).

```sql
-- 1) Sutunun GERCEK tipi
SELECT column_name, data_type, udt_name
FROM information_schema.columns
WHERE table_name = 'outbox_messages' AND column_name IN ('commit_xid','server_seq');

-- 2) Calisma zamani tipi
SELECT pg_typeof(commit_xid)::text, pg_typeof(server_seq)::text
FROM outbox_messages LIMIT 1;

-- 3) xid8 karsilastirmasi SAYISAL mi? (beklenen: f)
SELECT '1000'::xid8 < '988'::xid8 AS lex_mi;

-- 4) Siralamayi Postgres nasil yapiyor -- sort key ve index
EXPLAIN (ANALYZE, VERBOSE)
SELECT commit_xid::text, server_seq FROM outbox_messages
ORDER BY commit_xid, server_seq;

-- 5) Surum
SELECT version();
```

Boş tabloda 2. sorgu satır döndürmez — o zaman bir satır ekle (ya da
`SELECT pg_typeof(NULL::xid8)` ile 1. sorguyu çapraz doğrula) ve bunu **yaz**.

Ham çıktı → `KANIT/o83E/01-tip-olcumu.txt`

---

## 3. CEVAP — `KANIT/o83E/00-CEVAP.md`, beş satır

1. `commit_xid` `data_type` / `udt_name` = ?
2. `pg_typeof(commit_xid)` = ?
3. `'1000'::xid8 < '988'::xid8` = **t** mi **f** mi?
4. EXPLAIN'in **Sort Key**i ne yazıyor (ve index mi tarama mı)?
5. `version()` = ?

**Sonra tek cümle:** kusur **şemada** mı (sütun metin) yoksa **`xid8`in kendi sıralamasında**
mı? Başka yorum yok.

---

## 4. KABUL

- [ ] `KANIT/o83E/01-tip-olcumu.txt` beş sorgunun ham çıktısıyla var
- [ ] `KANIT/o83E/00-CEVAP.md` beş maddeyi + tek cümleyi içeriyor
- [ ] Hangi veritabanına koşulduğu yazılı
- [ ] `git --no-optional-locks status --porcelain -- src tests` **boş** (hiçbir kod değişmedi)

## 5. DOKUNMA LİSTESİ

- ❌ Ürün kodu · şema · migration · test · `verify.ps1` — **hiçbiri**
- ❌ Düzeltme önerisi yazmak
- ❌ Push
