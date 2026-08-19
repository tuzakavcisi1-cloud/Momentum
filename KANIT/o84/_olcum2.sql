\pset pager off
DROP TABLE IF EXISTS outbox_messages;
CREATE TABLE outbox_messages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    commit_xid xid8 NOT NULL, server_seq bigint NOT NULL,
    owner_id uuid NOT NULL DEFAULT gen_random_uuid(),
    signaled_at timestamptz, available_at timestamptz NOT NULL DEFAULT now(),
    payload text NOT NULL DEFAULT '{}'
);
INSERT INTO outbox_messages (commit_xid, server_seq, payload)
SELECT (900 + i)::text::xid8, (1+i)::bigint, 'v'||i FROM generate_series(0, 4999) AS g(i);
CREATE INDEX ix_outbox_cursor ON outbox_messages (commit_xid, server_seq);
ANALYZE outbox_messages;

\echo '=== 1) OutboxClaimStore.cs:22-28 ic SELECT golgeleniyor mu? (ic liste yalniz id) ==='
EXPLAIN (VERBOSE, COSTS OFF)
SELECT id FROM outbox_messages
 WHERE signaled_at IS NULL AND available_at <= now()
 ORDER BY commit_xid, server_seq
 LIMIT 50;

\echo '=== 2) URUN sorgusu (golgeli) -- indeks kullanilabiliyor mu? ==='
EXPLAIN (VERBOSE, COSTS OFF)
SELECT commit_xid::text, server_seq, payload::text FROM outbox_messages
 WHERE commit_xid < pg_snapshot_xmin(pg_current_snapshot())
   AND (commit_xid, server_seq) > ('900'::xid8, 1)
 ORDER BY commit_xid, server_seq LIMIT 500;

\echo '=== 3) DUZELTILMIS sorgu (nitelendirilmis ORDER BY) -- indeks kullanilabiliyor mu? ==='
EXPLAIN (VERBOSE, COSTS OFF)
SELECT o.commit_xid::text, o.server_seq, o.payload::text FROM outbox_messages o
 WHERE o.commit_xid < pg_snapshot_xmin(pg_current_snapshot())
   AND (o.commit_xid, o.server_seq) > ('900'::xid8, 1)
 ORDER BY o.commit_xid, o.server_seq LIMIT 500;
