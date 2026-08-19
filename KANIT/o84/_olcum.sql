\pset pager off
DROP TABLE IF EXISTS outbox_messages;
CREATE TABLE outbox_messages (
    commit_xid xid8   NOT NULL,
    server_seq bigint NOT NULL,
    payload    text   NOT NULL
);
INSERT INTO outbox_messages (commit_xid, server_seq, payload)
SELECT (988 + i)::text::xid8, (1 + i)::bigint, 'v' || i
FROM generate_series(0, 24) AS g(i);

\echo '=== A) URUN SORGUSU (SyncPuller.cs:37-41 birebir sekli) ==='
SELECT commit_xid::text, server_seq, payload FROM outbox_messages
ORDER BY commit_xid, server_seq;

\echo '=== A-EXPLAIN ==='
EXPLAIN (VERBOSE, COSTS OFF)
SELECT commit_xid::text, server_seq, payload FROM outbox_messages
ORDER BY commit_xid, server_seq;

\echo '=== B) TEK FARK: cikti sutununa AYRI AD verildi ==='
SELECT commit_xid::text AS commit_xid_text, server_seq, payload FROM outbox_messages
ORDER BY commit_xid, server_seq;

\echo '=== B-EXPLAIN ==='
EXPLAIN (VERBOSE, COSTS OFF)
SELECT commit_xid::text AS commit_xid_text, server_seq, payload FROM outbox_messages
ORDER BY commit_xid, server_seq;

\echo '=== C) TEK FARK: ORDER BY nitelendirildi (o.commit_xid) ==='
SELECT commit_xid::text, server_seq, payload FROM outbox_messages o
ORDER BY o.commit_xid, o.server_seq;

\echo '=== C-EXPLAIN ==='
EXPLAIN (VERBOSE, COSTS OFF)
SELECT commit_xid::text, server_seq, payload FROM outbox_messages o
ORDER BY o.commit_xid, o.server_seq;

\echo '=== D) WHERE tarafi: satir karsilastirmasi SAYISAL mi? (gölgelenme WHERE de yok) ==='
SELECT count(*) AS "xid>999 sayisi" FROM outbox_messages
WHERE (commit_xid, server_seq) > ('999'::xid8, 12::bigint);
