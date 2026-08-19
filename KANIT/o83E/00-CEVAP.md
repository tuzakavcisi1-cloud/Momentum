# IS-EMRI-o83-E — CEVAP

**Veritabanı:** taze test konteyneri — `docker run postgres:17-alpine` (container `o83e-pg`, host port 55432, db `o83e`), şema `dotnet ef database update` ile uygulandı (4 migration, `docker compose` KULLANILMADI). Ham çıktı: `KANIT/o83E/01-tip-olcumu.txt`.

1. `commit_xid` `data_type`/`udt_name` = **xid8 / xid8**. `server_seq` `data_type`/`udt_name` = **bigint / int8**.
2. `pg_typeof(commit_xid)` = **xid8** (bir satır eklenerek ölçüldü; çapraz doğrulama `pg_typeof(NULL::xid8)` = xid8, birebir aynı).
3. `'1000'::xid8 < '988'::xid8` = **f**.
4. Sort Key = `((outbox_messages.commit_xid)::text), outbox_messages.server_seq` — **Seq Scan** (index yok, tablo taraması + ayrı Sort düğümü).
5. `version()` = **PostgreSQL 17.10 on x86_64-pc-linux-musl, compiled by gcc (Alpine 15.2.0) 15.2.0, 64-bit**.

**Tek cümle:** Şema doğru (`udt_name`=xid8) ve xid8'in kendi karşılaştırması sayısal (madde 3 = f) — ikisi de değil; EXPLAIN'in Sort Key'i `(outbox_messages.commit_xid)::text` yazıyor, yani ölçülen sıralama xid8 sütunu üzerinde değil sorgunun `::text` çevrimi üzerinde çalışıyor.
