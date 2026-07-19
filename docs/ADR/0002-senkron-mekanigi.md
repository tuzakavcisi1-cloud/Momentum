# ADR 0002 — Senkron Protokol Mekaniği (Taç Mücevher)

- **Durum:** ✅ **KİLİTLİ (v3)** — `engineering` (architecture + system-design) **ve** red-team kapıları + bağımsız hedefli-doğrulama geçti; bulgular işlendi. **Onur onayıyla KİLİTLENDİ (18 Tem 2026, oturum 4).** Değişiklik ancak yeni ADR ile.
- **Tarih:** 2026-07-18
- **Karar verenler:** Onur (sahip) · Cowork (mimar) · bağımsız denetçi ajanlar (architecture, system-design, red-team)
- **Kapsam:** ADR 0001 §I'de **yön** olarak sabitlenen senkron/çakışma/Outbox kontratlarının **somut mekaniği**.
- **Bağımlılık:** Mekanik **kilidi** DB gerektirmez; **build**'in kalıcılık ayağı DB/Docker dilimine bağlıdır. Saf çekirdek DB'siz kanıtlanır; kalıcılık/görünürlük/eşzamanlılık hazardları **Testcontainers-Postgres** ister (§3, §H).

> **Onur'un kilitlediği 4 fork:** katmanlı çakışma · istemci-HLC korunur · sinyal+pull · yoklamalı Outbox.
>
> **Denetim izi:**
> **v1→v2 (engineering ×2):** imleç → `pg_snapshot_xmin` ufku (sinyalden ayrık); tam-genişlik `clientId`; GC→resync; Outbox yönlendirme anahtarları; alan→strateji kaydı; alan-versiyon kalıcılık modeli; katman ataması; UoW opt-out; düğüm-monoton clamp; eş-çözülen alan grupları; silme↔düzenleme yüzeyleme; sunucu-otoriter rebalance; RRULE occurrence kapsam-dışı.
> **v2→v3 (red-team):** **(BLOKER-R1)** resync/snapshot devam-imleci = `pg_snapshot_xmin` `(xmin,0)` (atlama kapandı). **(BLOKER-R2)** nihai eşitlik-bozucu **`operationId`** → koşulsuz tam-sıra; `lastEffectiveHlc` atomik `GREATEST`+istemci-başı serileştirme. **(Majörler)** HER HLC'ye (op/alan/küme/grup) clamp; entity-arası batch **soft-ref**; **kapsam-geçişi çift-yayını** (hayalet); OR-Set **compaction+cap**; registry **sunucu-zorlamalı**; push-tarafı yetki (ertelenmiş, adlandırıldı); grup-üyeliği↔yetki transactional; H kapısına resync-imleç + eşzamanlı-ingest testleri.
> **v3 hedefli-doğrulama:** R1 (`(horizon,0)` resync-imleci) ve R2 (`operationId` eşitlik-bozucu + atomik/serileşmiş clamp) bağımsız doğrulamayla **TUTTU** (yeni delik yok). Netleştirmeler işlendi: pull-authz tombstone **muafiyeti** (Y1), OR-Set compaction **remove-remap** (Y2), `COLLATE "C"`/Ordinal, `server_seq≥1` değişmezi.

---

## 1. Bağlam

Momentum'un taç mücevheri: **çevrimdışı-öncelikli senkron + çakışma çözümü** ve **gerçek-zamanlı işbirliği**. ADR 0001 mimariyi ve taşıyıcı kontratların *şeklini* kilitledi; mekaniği bu ADR kesinleştirir.

**Topoloji — HUB-AND-SPOKE (sunucu-aracılı).** Sunucu **tek uzlaşma otoritesidir** → saf-P2P CRDT'lerin sınırsız nedensellik metadatasına gerek kalmaz; **sunucu-çıpalı, sınırlı-metadata** varyantlar (§2.C).

**İki yol, ayrı sorumluluk:** `/sync` değişim **verisini** taşır (doğruluk otoritesi); SignalR yalnız **payload'suz dürtü** (en-iyi-çaba). Delta hesabı tek yolda (`/sync`).

---

## 2. Kararlar

### A. Hibrit Mantıksal Saat (HLC)

**K2-A1 — HLC + kanonik anahtar (koşulsuz tam-sıra).** HLC = `(wallMs, counter, nodeId=clientId)`; **karşılaştırma/LWW anahtarı = `(wallMs, counter, clientId, operationId)`** — nihai eşitlik-bozucu `operationId` (UUIDv7).
- Kodlama (leksikografik, sabit-genişlik, **küçük-harf** hex): `{wallMs:013d}.{counter:08x}.{clientId:032x}.{operationId:032x}`.
- `clientId` tam-genişlik + `operationId` benzersiz olduğundan **anahtar hiçbir koşulda berabere kalmaz** — clientId çakışması/spoof'u veya eşzamanlı-ingest yarışı (K2-A4) tam-sırayı **bozamaz** (BLOKER-R2). Her skaler alan-versiyonu, kazanan yazımın `operationId`'sini saklar.
- Hex **zorunlu küçük-harf**: büyük-harf ASCII sıralamayı bozar (§H sabitler).
- **Sıralama-kararlılığı [implementasyon-kısıtı, doğrulama]:** anahtar-string kolonu `COLLATE "C"` (byte/ordinal sıra); C# karşılaştırmaları `StringComparer.Ordinal`. Locale-collation `.`-ayıracını/harf-sırasını bozabilir → sabit-genişlik leksikografik düzen ancak ordinal ile garanti.

**K2-A2 — Yerel tick + overflow.**
```
wall = TimeProvider.now_ms()
if wall > L.wallMs:            L=(wall,0,self)
elif L.counter==UINT32_MAX:   L=(L.wallMs+1,0,self)     # taşma → wallMs'e taşı
else:                         L=(L.wallMs,L.counter+1,self)
```

**K2-A3 — Alım/birleştirme (standart Kulkarni HLC):**
```
wall=now_ms(); w'=max(L.wallMs,m.wallMs,wall)
if   w'==L.wallMs==m.wallMs: c=max(L.counter,m.counter)+1
elif w'==L.wallMs:           c=L.counter+1
elif w'==m.wallMs:           c=m.counter+1
else:                        c=0
L=(w',c,self)
```

**K2-A4 — Sunucu clamp + düğüm-monotonluk; HER HLC'ye uygulanır.**
1. **İleri-sapma clamp'i** her gelen HLC'ye: `clamped.wallMs = min(hlc.wallMs, serverReceiveWall + MAX_FORWARD_SKEW)` (5 dk, yapılandırılır). **Op-HLC, per-alan HLC, küme-op HLC, grup HLC — HEPSİ clamp'lenir** (per-alan HLC ile op-clamp'i atlatan poison kapandı, denetçi M-A). Geçmiş-tarih asla sınırlanmaz; absürt (>1 yıl) → `422`.
2. **Düğüm-başına monotonik etkin-HLC:** `effectiveHlc = max( clamped(hlc), lastEffectiveHlc[clientId] ⊕ tick )`.
   - **Eşzamanlılık güvenliği [BLOKER-R2]:** `lastEffectiveHlc[clientId]` güncellemesi **atomik-monoton** (`INSERT … ON CONFLICT DO UPDATE SET hlc = GREATEST(excluded.hlc, sync_client_clock.hlc)`) **ve** verilen `clientId` için etkin-HLC ataması **istemci-başı serileştirilir** (per-client advisory-lock / `SELECT … FOR UPDATE`, ya da `SERIALIZABLE`+retry). Böylece lost-update ile geri-sıçrama/özdeş-HLC olmaz. Bedel: aynı istemcinin eşzamanlı op'ları serileşir (istemci-başı, düşük çekişme).
   - Nihai emniyet: iki op yine de özdeş `(wallMs,counter,clientId)` alsa bile `operationId` (K2-A1) determinist çözer.

**K2-A5 — İKİ SAAT AYRIMI [kritik].** Çakışma = düzenleme-zamanı **etkin HLC**; imleç = sunucu **commit-görünürlük konumu** `(commit_xid, server_seq)` (§E/F). Karıştırmak kaçan-değişim hatasıdır; pazarlıksız.

**Poison dürüstlük notu:** clamp poison'ı elemez, ≤ MAX_FORWARD_SKEW + yetki-kapsamına (K2-E3) daraltır.

### B. Delta tel-format + registry (sunucu-zorlamalı)

**K2-B1 — Değişim kaydı.** (alan-başına HLC; `opType` = `isDeleted` üzerinden türetilir; yalnız değişen alan taşınır)
```json
{ "operationId":"uuidv7","clientId":"uuidv7","entityType":"Task","entityId":"uuidv7","actorId":"uuidv7",
  "opHlc":"...","fields":{"title":{"value":"Süt al","hlc":"..."},"isDeleted":{"value":false,"hlc":"..."}},
  "sets":{"tags":{"adds":[{"el":"iş","tag":"uuidv7","hlc":"..."}],"removes":[{"el":"ev","observed":["uuidv7"],"hlc":"..."}]}},
  "groups":{"completion":{"fields":{"status":"done","completedAt":"..."},"hlc":"..."}},
  "order":{"listPos":{"value":"0|hzzzzz:","hlc":"..."}} }
```
Not: ADR 0001 K-C3 zarfını bilinçli revize eder (açık kayıt). 0001 K-I2 "SignalR zarftan yayınlanır" ifadesi burada **payload'suz dürtü**ye daraltıldı (bilinçli refinement).

**K2-B2 — Alan→strateji kaydı, SUNUCU-ZORLAMALI [denetçi M-F].** Her `entityType`.alan bir stratejiye bağlı:

| entityType | scalar-LWW | OR-Set | fractional-index | eş-çözülen grup |
|---|---|---|---|---|
| `Task` | title, notes, priority, dueAt, remindAt, projectId, isDeleted, recurrenceRule | tags, assignees, checklistItems | listPos, boardPos | `{status, completedAt}` |
| `Project` | name, color, isDeleted | members | pos | — |
| `TaskList`/`Section` | name, isDeleted | — | pos | — |
| `Tag` | label, color, isDeleted | — | — | — |

**Sunucu, ingest'te registry'yi ZORLAR:** bir alanı yanlış kanaldan gönderen (ör. grup üyesi `status`'u `fields` skaler kanalından, ya da OR-Set alanını skaler) op **reddedilir (`422`)** veya registry'ye remap edilir → C1b değişmezleri istemci-iyi-niyetine bırakılmaz. Tam liste slice-2a spec'inde; mekanizma + Task örneği kilitli.

### C. Çakışma semantiği — KATMANLI (fork #1)

**K2-C1 — Skaler → per-alan LWW register** (anahtar K2-A1; bağımsız çözülür, kayıpsız birleşme).

**K2-C1b — Eş-çözülen alan grupları** — `{status, completedAt}` vb. **tek grup-HLC** altında atomik çözülür (jointly-geçersiz durum yok). Registry'de tanımlı, sunucu-zorlamalı (K2-B2).

**K2-C2 — Küme → OR-Set (add-wins) + compaction/cap [denetçi M-E].** Add = benzersiz `tag`; remove yalnız `observed[]`'i iptal eder; eleman mevcut ⇔ iptal-edilmemiş ≥1 tag. **Büyüme sınırı:** (a) sunucu **`gcHorizon`'da compaction** — mevcut elemanın, ufkun altındaki tüm add-tag'leri tek kanonik tag'e indirilir (ufuk altında yeni-gözlem imkânsız, güvenli); (b) per-(entity,set,eleman) **add-tag yumuşak üst-sınırı** aşımı reddedilir/loglanır (patolojik/DoS ekleme sınırlanır). Sınır + davranış belgelenir. **Pencere-içi remove uyumu [doğrulama Y2]:** compaction sonrası, `observed[]`'i **ufuk-altı (compact-edilmiş) bir add-tag'e** referans veren remove, sunucu tarafında elemanın **kanonik tag'ine remap edilir** → remove niyeti sessizce kaybolmaz (compact-edilmiş istemci hâlâ silebilir).

**K2-C2 ERRATA E-1 (19 Tem 2026, Onur kilitledi) — add damgası: "ilk damga kalır" → "EN BÜYÜK damga kalır".**
*Bulgu:* `P1_permutations_of_an_op_set_converge` property'si **CsCheck tohumu `fcGWfMJW_dB2`** ile determinist olarak düşüyordu (Cowork slice-2b2 denetiminde yakaladı, temiz ağaçta birebir yeniden üretildi; `KANIT/slice-2b2/cowork-bagimsiz-dogrulama.txt` §6). Aynı `(element, tag)` çifti farklı `Hlc`'lerle geldiğinde `OrSetField.ApplyAdd` **ilk geleni** saklıyordu; bu idempotent ama **komütatif değil**. Üyelik etkilenmediği için `S|` yakınsıyor, ama `MaxStamp()` sıraya bağlı değişip K2-C4 çakışma bayrağını `1↔0` çeviriyordu.
*Kural (kilitli):* Bir CvRDT birleştirmesi yarı-kafes **join**'i olmak zorundadır (idempotent **+ komütatif** + birleşmeli). Aynı `(element, tag)` için birden çok damga görülürse **max** saklanır. Kuralın **ÜÇ uygulama noktası** vardır ve üçü de aynı olmak zorundadır:
  1. `OrSetField.ApplyAdd` (canlı uygulama) — bugün *ilk-yazan*;
  2. `OrSetField.LoadTag` (kalıcılıktan hidratlama) — bugün *son-yazan* (**ApplyAdd ile çelişiyor**);
  3. `SyncStore.UpsertTagAsync` SQL'i — bugün `DO UPDATE SET hlc = excluded.hlc` (*koşulsuz son-yazan*).
*Değişmeyen:* add-wins üyelik semantiği · `Cancelled` kalıcılığı · born-dead damganın kaydedilmesi · K2-C4'ün **ifadesi** (yalnız artık gerçekten yakınsıyor) · **şema** (`sync_orset_tags` PK'sı tag başına tek satır tutuyor; max-yükseltme mevcut satırın güncellenmesidir).
*Yan kazanç (SINIRLI — denetimde düzeltildi):* compaction'ın `(Hlc, tag-hex)` kanonik seçiminin **damga bileşeni** sıradan bağımsızlaşır. **Compaction↔remove sıra bağımlılığı KALIR** ve bu bir kusur değil, K2-C2/Y2'nin bilinen ve *tasarlanmış* GC ödünleşimidir (`remove` sonra `Compact` ⇒ eleman mevcut; `Compact` sonra `remove` ⇒ kanonik iptal edilir ⇒ eleman yok — `OrSetProperties` bunu istenen davranış olarak zaten assert ediyor). E-1 bunu komütatif YAPMAZ; öyle olduğunu iddia etmek yanlış olur.
*Gizli bağ (yazıya geçirildi):* `MaxStamp()`'in compaction altında korunması, `CompactBelow`'un kanonik tag'i `belowActive`'in **arg-max**'ı seçmesine bağlıdır (düşürülen her tag'in damgası kanonikinkinden ≤ olur). Kanonik seçim kuralı değişirse `MaxStamp()` sessizce damga düşürmeye başlar ve C4 hiçbir test düşmeden geriler. Bu bağ `CompactBelow` doküman-yorumunda ve bir mikro-testte pinlenir.

**K2-C2 ERRATA E-1b (aynı kilit) — kalıcılık katmanında GREATEST'e AÇIK İSTİSNA.**
`UpsertTagAsync` `hlc = GREATEST(excluded.hlc, sync_orset_tags.hlc)` olur. Bu, "SQL'de ikinci LWW/CRDT implementasyonu yasak" kuralına **adlandırılmış istisnadır**: gerekçe, farklı istemcilerin aynı tag'i yazdığı eşzamanlı transaction'larda domain'in hesapladığı max'ın DB'de geri çekilememesidir — `sync_client_clock`'un K2-A4 GREATEST'iyle **birebir aynı kalıp**. Hlc kodlaması sabit genişlikte ve sıralı olduğundan metin `GREATEST`'i doğru çalışır; tombstone-only satırda `hlc` NULL'dır ve Postgres `GREATEST` NULL'ı yok saydığı için gerçek damga "damgasız"ı yener (istenen davranış).
**ZORUNLU KOŞUL (2b1 BULGU-2'nin doğrudan uygulaması):** bu GREATEST **kör koruma olamaz**. Isırdığını kanıtlayan bir mutant + test olmadan "kapı" sayılmaz; kanıtlanamazsa ADR'de savunma-derinliği diye adlandırılır. D0'ın client clock için kurduğu ayırt edici test kalıbı burada orset tag için tekrarlanır.

**K2-C3 — Sıralama → kesirli-index + sunucu-otoriter rebalance.** `positionKey` skaler-LWW; rebalance yalnız sunucu (tek-otorite), sunucu-otoriter HLC ile; eşzamanlı istemci taşıması determinist çözülür.

**K2-C4 — Silme → `isDeleted` LWW + çakışma yüzeyleme.** Hard-delete yok (red line #4). Alan-düzenlemesi HLC'si kazanan `isDeleted:true`'dan büyükse → sessiz gizleme yerine **çakışma bayrağı** (UI rozet).
> **C4 NOTU (E-1 çapraz referansı):** Bu bayrak **türetilmiştir** ve girdilerinden biri OR-Set'in `MaxStamp()`'idir. Dolayısıyla C4'ün yakınsaklığı **doğrudan C2'nin damga kuralının komütatifliğine bağlıdır**; E-1 kilitlenmeden C4 "yakınsak" sayılamaz. C4'ün kendi ifadesi E-1 ile DEĞİŞMEZ.

**K2-C5 — Zengin metin → LWW-sınırlı** (bilinen sınır; çakışma-gölge rozeti).

**K2-C6 — Retention + GC-ufku → zorunlu resync [BLOKER-4].** Tombstone/gölge/delta `RETENTION` (varsayılan 90 gün) saklanır; `gcHorizon` = budanan en yüksek imleç. **`sinceCursor < gcHorizon` → `/sync` artımlı DÖNMEZ; `resyncRequired:true` + tam-snapshot** (istemci yerelini değiştirir). Diriliş/hayalet/ıraksama zinciri kapanır.

**K2-C7 — Kapsam-geçişi çift-yayını (hayalet düzeltmesi) [denetçi M-D].** Bir entity bir kapsamdan **ayrılınca** (projectId değişimi / collaborator çıkarma), değişim **eski kapsama da** yayılır: eski-scope üyeleri "kapsamdan-çıktı" delta/sinyali alır (entity'yi yerelde tombstone'lar), yeni-scope entity'yi alır. Outbox satırı geçişte `old_scope_id` + `scope_id` taşır; dispatcher iki gruba da yayınlar. Yoksa eski-scope collaborator'ında **kalıcı hayalet** (yalnız tam-resync temizlerdi) oluşurdu. **Pull-authz muafiyeti [doğrulama Y1]:** bu "kapsamdan-çıktı" tombstone'u emit-anı `old_scope_id` üyeliğiyle yetkilendirilir ve **içeriksizdir**; pull-tarafı içerik-filtresi (K2-E3) onu *güncel-görünürlük* testinden **açıkça muaf** tutar (aksi halde entity artık eski-scope'a görünmediğinden tombstone filtrelenir → hayalet geri gelir).

### D. Idempotency & dedup

**K2-D1** — istemci `operationId` (UUIDv7) her yazma op'unda.
**K2-D2** — `processed_operations(client_id, operation_id, first_seen_at, result_code, PK(client_id,operation_id))`; push'ta `INSERT … ON CONFLICT DO NOTHING` (eşzamanlı çift-push yarışı kapalı).
**K2-D3** — etki-bir-kez (pencere-içi): dedup, yan-etki tekilliğini (Outbox olayı/bildirim) korur.
**K2-D4** — **istemci op-TTL ≤ sunucu dedup-retention**; aşan op retry edilmez, tam-resync'e düşer. Pencere-dışı at-least-once; reinstall→yeni clientId düşük riski kabul, belgeli.

### E. `/sync` batch protokolü

**K2-E1 — `POST /v1/sync`** (push+pull; `sinceCursor`, `clientHlc`, `ops[]` → `serverHlc`, `nextCursor`, `hasMore`, `resyncRequired`, `applied[]`, `changes[]`).

**K2-E2 — İmleç = `(commit_xid, server_seq)` + `pg_snapshot_xmin` ufku [BLOKER-1+2].** Her outbox satırı `commit_xid xid8 DEFAULT pg_current_xact_id()`. Pull yalnız **kesin görünür** satırları döndürür:
```sql
SELECT * FROM outbox_messages
 WHERE commit_xid < pg_snapshot_xmin(pg_current_snapshot())
   AND (commit_xid, server_seq) > (:sinceXid, :sinceSeq)
   AND (:actor kapsam filtresi)
 ORDER BY commit_xid, server_seq LIMIT 500;
```
İptal-deliği bağışık (rollback satırı yok); uçuşta-güvenli (`commit_xid≥xmin` görünmez; istemci imleci xmin'i geçemez → txn commit edince değişim doğru sırada gelir, atlanmaz/takılmaz). `xid8` sarma-bağışık. *(Tek-primary varsayımı; replica okuma eklenirse read-your-writes monotonluğu incelenecek — §6.)*

**K2-E3 — Yetki: PULL + PUSH.**
- **Pull [red line #2]:** `changes` yalnız actor'ın görebildiği (owner/collaborator) entity'lerle sınırlı (Application, `ICurrentUser`). Dispatch-yönlendirmeden ayrı (K2-F1/G2). **İstisna:** içeriksiz "kapsamdan-çıktı" tombstone'u (K2-C7) `old_scope_id` yetkisiyle geçer (güncel-görünürlük filtresinden muaf).
- **Push [denetçi M-G, ertelenmiş gereksinim]:** ingest, her op için "actor bu entity'yi **yazabilir mi**" kontrolü yapmalı. Mekanizma auth diliminde; o zamana dek **deny-by-default** + `entityId` bir yetki-token'ı DEĞİLDİR. Bu, ertelenmiş gereksinim olarak açıkça adlandırılır (sessiz açık bırakılmaz).

**K2-E4 — İlk-senkron / resync devam-imleci [BLOKER-R1 düzeltmesi].**
- **Tam-snapshot** (`sinceCursor==null` veya `resyncRequired`): tek `REPEATABLE READ` txn'de (a) `horizon = pg_snapshot_xmin(pg_current_snapshot())` yakalanır, (b) durum **entity-PK ile sayfalanır** (state satırının doğal `(commit_xid,server_seq)`'i yoktur). **Snapshot sonrası devam-imleci = `(horizon, 0)`** — ufkun **kendisi**. Postgres garantisi: `commit_xid<horizon` her satır snapshot'ta; snapshot'ta OLMAYAN her satır `commit_xid≥horizon` → `(horizon,0)`'dan artımlı = **atlamasız üst-küme** (snapshot-anı uçuştaki düşük-xid txn'ler yakalanır; kesişim idempotent yeniden-teslim, zararsız).
- **Artımlı sayfalama** (`hasMore` bir artımlı pull içinde): `nextCursor` = **son dönen değişimin** `(commit_xid,server_seq)`'i. *(İki kural FARKLI: snapshot sınırı → ufuk; artımlı sayfa → son satır. v2'de karıştırılmıştı.)*
- Çok-sayfalı snapshot tek `REPEATABLE READ` txn'de tutulur (sayfalar-arası yırtık yok); uzun-txn xmin-pin tazelik bedeli (§6 Risk#1). Artımlı `/sync` req-başı `READ COMMITTED` (taze ufuk).

**K2-E5 — Op-başına transaction + UoW opt-out + entity-arası soft-ref.**
- Her op kendi txn'inde (mutasyon + outbox + dedup **aynı commit**, K-C4); `/sync` handler'ı K-G1 UoW behavior'ından **açık opt-out** (marker/predicate). Zehirli op batch'i düşürmez.
- **Entity-arası referans [denetçi M-B]:** batch'te `[createProject P, createTask T→P]` gibi bağımlılıklarda, senkron-ingest **FK'yı DB-seviyesinde zorlamaz** (soft-ref): istemci batch'i nedensel sıralar; sunucu geçici dangling referansa **tolerans** gösterir; çocuk entity, ebeveyni gelene dek **pending** görünür ve reconciliation'da materyalize olur. Böylece op-başına txn + kısmi-red FK-ihlali/orphan üretmez. (slice-2b: soft-ref + reconciliation süpürmesi.)

### F. Outbox + sinyal yayıncısı (fork #4)

**K2-F1 — `outbox_messages`:** `id`(uuidv7 PK) · `commit_xid`(xid8 DEFAULT pg_current_xact_id() — imleç ufku) · `server_seq`(IDENTITY `START WITH 1`, **≥1 değişmezi** — `(horizon,0)` sentinel'inin doğruluğu buna bağlı; ikincil sıra) · `aggregate_type/id` · `operation_id` · `owner_id` + `scope_id` (+ geçişte `old_scope_id`) [dispatch yönlendirme, commit-anı snapshot] · `actor_id` · `event_type` · `payload`(jsonb) · `hlc`(text) · `occurred_at` · `signaled_at`(NULL=beklemede) · `attempts`/`available_at`. Satır domain mutasyonuyla **aynı txn**.

**K2-F2 — Sinyal yayıncısı (`IHostedService`), sıra-BAĞIMSIZ, çok-instance güvenli.** Yalnız dürtü (imleç değil): `WHERE signaled_at IS NULL AND available_at<=now() FOR UPDATE SKIP LOCKED LIMIT 100` → `user:{owner_id}` + `scope:{scope_id}` (+ geçişte `scope:{old_scope_id}`) gruplarına payload'suz sinyal → `signaled_at=now()`. Doğruluk `/sync` xmin-okumasında; sinyal sırasızlığı zararsız.

**K2-F3 — At-least-once sinyal + idempotent pull** (kayıp sinyal → sonraki sinyal/periyodik-pull/yeniden-bağlanma yakalar).

### G. Gerçek-zaman — SİNYAL + PULL (fork #3)

**K2-G1 — Payload'suz sinyal** `{changed:true, cursorHint}`; istemci `/sync`'i **saklı gerçek imleciyle** çağırır. **`cursorHint` yalnız tavsiye — asla imleç olarak saklanmaz** (yalnız `/sync` yanıtı `nextCursor`'dan güncellenir).

**K2-G2 — Grup/kapsam + üyelik-yetki transactional senkron [denetçi M-H].** Sinyal `user:{owner_id}` + `scope:{scope_id}` gruplarına. **Grup üyeliği yetkiyle senkron:** collaborator çıkarma op'u commit edilince, çıkarılan üye scope grubundan **aynı outbox/dispatch yolunda** düşürülür + bağlantıda üyelik yetkiden **yeniden hesaplanır**. Kalıntı: çıkarma-anında uçuşta bir dürtü gidebilir ama payload pull-authz (E3) ile kapılı (3-katman savunma). Redis backplane + yatay ölçek sonraki dilim.

**K2-G3 — Yeniden-bağlanma = imleçle yakalama** (kayıp-mesaj yok; sinyal en-iyi-çaba, imleç otorite).

### H. TAÇ MÜCEVHER doğrulama kapısı

**Saf çekirdek (slice-2a, DB'siz):**
- **K2-H1 — Bağımsız oracle** (üretim `ConflictResolver`'dan ayrı); **ingest dönüşümünü de modeller: HER HLC'ye (op/alan/küme/grup) clamp + düğüm-monotonluk** (denetçi M-A; effective-HLC'yi hazır almaz).
- **K2-H2 — Property yasaları** (CsCheck / FsCheck — lisans+CVE kapısı, etiket teyidi §6): değişmezlik, idempotentlik, yakınsama, determinizm.
- **K2-H3 — Idempotency:** aynı `operationId` batch'i N kez → tek Outbox olayı, tek etki.
- **K2-H4 — MUTANT:** HLC `>`→`<`; OR-Set remove eşzamanlı add'i yensin; clamp kaldır; **`operationId` eşitlik-bozucuyu kaldır**; grup-atomikliği boz → property/oracle-diff BAŞARISIZ olmalı. Kanıt `KANIT/slice-2/`.
- **K2-H5 — Eşitlik-bozucu ZİNCİRİ [red-team H5 düzeltmesi]:** üreteç her katmanı ayrı sınar — eşit `(wallMs,counter)` + farklı `clientId` → clientId çözer; eşit `(wallMs,counter,clientId)` (yarış/spoof) + farklı `operationId` → **operationId çözer**; determinist tek-kazanan. (v2'nin "çakışan clientId'yi tam-genişlik kurtarır" çelişkisi kaldırıldı.)
- **K2-H6 — Eş-çözülen grup değişmezleri** (CRDT-yasası değil; ayrı test + registry sunucu-zorlaması).
- **K2-H7a — GC-resync TETİKLEME:** `sinceCursor<gcHorizon` → resync.
- **K2-H7b — Resync İMLEÇ doğruluğu [BLOKER-R1]:** snapshot-anında uçuşta txn A + snapshot sonrası A commit → `(horizon,0)` devam-imleci A'yı **atlamaz**; **`server_seq≥1` değişmezini de assert** eder; mutant (imleç=son-satır) BAŞARISIZ olmalı.

**Kalıcılık/eşzamanlılık (slice-2b, Testcontainers-Postgres):**
- **K2-H8 — Commit-görünürlük [BLOKER-1]:** rollback ile seq yak; yavaş-commit in-flight'i yüksek-seq önce commit; savepoint/subtxn dâhil → xmin-ufku ne atlar ne takılır; mutant (ham `bigserial` max) BAŞARISIZ.
- **K2-H9 — Çok-instance dispatcher [BLOKER-2 read-side]:** 2+ dispatcher + SKIP LOCKED → sinyal at-least-once + imleç doğruluğu sıradan bağımsız.
- **K2-H12 — Eşzamanlı-aynı-clientId INGEST [BLOKER-R2]:** aynı clientId'den paralel op'lar → `lastEffectiveHlc` lost-update YOK, monoton, determinist (operationId çözer); mutant (atomik-olmayan yazma / operationId'siz) BAŞARISIZ.
- **K2-H10 — Sunucu-HLC restart:** **per-client** `max(outbox.hlc) WHERE client_id` (global değil) restore; mutant → bayat damgalama.
- **K2-H11 — Kapsam-geçişi + soft-ref + registry-zorlama:** çift-yayın hayalet bırakmaz; kısmi-batch FK-ihlali yaratmaz; kanal-atlayan alan reddedilir.

**İstemci ve materyalizasyon (slice-3, Onur kilitledi 19 Tem 2026):**

**K2-I1 — İstemci uzlaştırma rolü: SUNUCU-OTORİTER, TEK RESOLVER. [PAZARLIKSIZ]**
Flutter istemcisi **kendi HLC/CRDT resolver'ını TAŞIMAZ.** Çevrimdışı yazım *iyimser* uygulanır (yerel Drift/SQLite durumu hemen güncellenir, kullanıcı beklemez) ve op kuyruğa alınır; **çakışma çözümü YALNIZ sunucuda** yapılır. Pull'da dönen sunucu durumu, o entity için **otoriter** kabul edilir ve yereli ezer.
*Gerekçe:* ikinci bir resolver, ikinci bir doğruluk kaynağı demektir ve bu projede o sınıf hatanın maliyeti ölçüldü — **ERRATA E-1** (aynı değişmezliğin üç kopyası birbiriyle çelişiyordu) ve slice-2c'nin **D1b**'si (bağımsız Oracle üretimle birlikte düzeltilmezse ayrışıyordu, ve o yalnızca bir *test* motoruydu). Üretim istemcisinde aynı ayrışma, kullanıcının verisinde sessiz kayıp olur.
*Kabul edilen ödünleşim (adlandırıldı):* sunucu farklı karar verirse istemcide **geri-alma/titreme (rollback/flicker)** görülebilir. Bu bilinçlidir; UI bunu "senkronlanıyor / güncellendi" göstergesiyle karşılar, gizlemez.
*Bunu isteyen bir gelecek dilim çıkarsa:* Dart tarafına da oracle + property + mutant zinciri kurmadan ikinci resolver YAZILAMAZ.

**K2-I2 — Materyalize entity satırı İNŞA EDİLİR (§2'deki kalıcılık modelinin açık kalan yarısı).**
Bugün DB'de yalnız senkron meta tabloları var (`outbox_messages`, `processed_operations`, `sync_client_clock`, `sync_gc_state`, `sync_orset_removes`, `sync_orset_tags`, `sync_scalar_meta`); **hiçbir entity tablosu yok** — yani projeksiyon yalnız bellekte yaşıyor. Bu dilimde `tasks` / `task_lists` materyalize edilir ve okuma API'siyle sunulur. Sunucu-tarafı sorgu/arama ve ileride Semantic Kernel bu satıra dayanır.
*Kapsam pini:* bu dilimde **Task + TaskList**. `Project`/`Tag` ertelendi — `Project` üyeliği auth diliminde (K2-E3) zaten yeniden ele alınacağı için şimdi materyalize etmek iki kez yapmak olur.

**K2-I3 — Dilim bölünmesi.** slice-3a = sunucu materyalizasyonu + okuma API'si; slice-3b = Flutter istemci (Drift + senkron kuyruğu + çevrimdışı anahtarı + çakışma demosu), hedef platformlar **Web + Android** (Mac yok → iOS CI-only). Her ikisi kendi KANIT'ıyla kapanır.

---

## 3. Uygulama sırası

**slice-2a (DB'siz, HEMEN):** HLC (A1–A4 saf) · çözümleyici + sunucu-zorlamalı registry (B2, C1–C4, C1b) · zarf tipleri (B1) · oracle + property + mutant + eşitlik-zinciri (H1–H7a). Saf **Domain**; PostgreSQL gerekmez; reboot beklemez.

**slice-2b (DB/Docker diline BAĞLI):** outbox/dedup/alan-versiyon şeması (F1,D2,§B-kalıcılık) · `/v1/sync` + xmin-ufku + resync-imleç (E2,E4) · sinyal yayıncısı (F2) · SignalR (G) · Testcontainers hazard/eşzamanlılık testleri (H7b,H8,H9,H11,H12) · HLC restart (H10).

**Katman [M5]:** `ConflictResolver`+HLC+CRDT = saf **Domain**; wire↔Domain eşleme **Application**; yayıncı+`/sync` kalıcılığı **Infrastructure**; portlar (`IOutbox`,`ISyncStore`) Application'da → NetArchTest (K-A1) temiz.

**Alan-versiyon kalıcılık modeli (şekil kilitli):** materyalize entity satırı + `sync_scalar_meta(entity_id,field,hlc,win_operation_id)` + `sync_orset_tags(entity_id,set_name,element,add_tag,hlc,cancelled)` + retention-pencereli `sync_field_shadow`; per-client `sync_client_clock(client_id,hlc)` (K2-A4). slice-2a in-memory durumu bu şekle hizalı.

**YÖN (kapsam dışı / sonraki dilim):** kimlik/owner-filter + push-authz aktivasyonu (E3, auth dilimi) · Redis backplane + yatay relay · MessagePack · zengin-metin CRDT · **RRULE occurrence/completion/exception (kapsam dışı — tekrar-dilimi; RRULE-string skaler-LWW ama occurrence modellenmez)**.

## 4. Gerekçe

İki-saat ayrımı + istemci-HLC korunumu çevrimdışı-önceliğin doğruluk kalbi. Katmanlı CRDT entity-LWW kaybını ve tam-CRDT süre riskini birlikte eler; hub-and-spoke sınırlı-metadata sağlar. İmleci `pg_snapshot_xmin` ufkuna bağlamak `bigserial` commit-görünürlük hazardını hem artımlı hem **resync sınırında** (`(horizon,0)` devam-imleci) çözer ve sinyal dağıtımından ayrıştırır. `operationId` nihai eşitlik-bozucu tam-sırayı **koşulsuz** (yarış/spoof dâhil) garanti eder. GC-ufku→resync retention'ı doğruluk garantisine çevirir. Kapı (bağımsız oracle + CRDT-yasa property + Testcontainers görünürlük/eşzamanlılık testi + mutant) ölçülebilir, ısıran kanıt üretir.

## 5. Alternatifler

| Eksen | Seçilen | Reddedilen |
|---|---|---|
| İmleç | `(commit_xid,server_seq)` + `pg_snapshot_xmin`; resync→`(horizon,0)` | Ham `bigserial` (iptal-deliği/reorder) · tek relay-pozisyonu (çok-instance çelişkisi) · resync→son-satır (atlama) |
| Eşitlik-bozucu | `(…, clientId, operationId)` koşulsuz | Kısaltılmış/yalnız-clientId (yarış/spoof → berabere → ıraksama) |
| Çakışma | Katmanlı (LWW+grup+OR-Set+kesirli-index) | Entity-LWW (kayıp) · tam sekans-CRDT (süre) |
| Saat | İstemci-HLC + clamp + düğüm-monoton (atomik/serileşmiş) | Sunucu-damga (çevrimdışını bozar) · saf clamp (inversion/yarış) |
| Küme | OR-Set + gcHorizon-compaction + cap | LWW-set (kayıp add) · sınırsız OR-Set (büyüme/DoS) |
| Gerçek-zaman | Sinyal + `/sync` pull | Soket-payload (çift yol) |
| Outbox | Yoklamalı sinyal (SKIP LOCKED) | LISTEN/NOTIFY (dayanıksız) · CDC (aşırı) |
| Entity-arası | Soft-ref + reconciliation | DB-zorlamalı FK (kısmi-batch ihlali) |

## 6. Riskler / açık noktalar

1. **xmin-ufku gecikmesi:** uzun-txn xmin'i (ve tam-snapshot `REPEATABLE READ`) geciktirir → tazelik düşer (doğruluk korunur). Uzun txn kaçınılır, izlenir.
2. **Kesirli-index büyümesi** → sunucu-otoriter rebalance (C3).
3. **Retention/GC (90 gün)** aşımı → zorunlu tam-resync (C6); doğru ama pahalı (nadir).
4. **Zengin metin LWW kaybı** — bilinçli (C5), UI rozet.
5. **Düğüm-monoton clamp durumu** (`sync_client_clock`) per-client kalıcı; restart'ta per-client `max(outbox.hlc)`'den türetme + H10.
6. **`MAX_FORWARD_SKEW`** poison'ı ≤5dk + yetki-kapsamına daraltır (elemez).
7. **clientId kimlik-doğrulaması ertelenmiş [denetçi M-C]:** tam-sıra garantisi non-spoof varsayımı + `operationId` eşitlik-bozucuyla tutar; `clientId→principal` auth-bağı + **push-authz** (M-G) auth diliminde aktive edilecek ertelenmiş gereksinimlerdir (açıkça adlandırıldı).
8. **Replica okuma:** tek-primary varsayımı; read-replica eklenirse `/sync` monotonluğu (read-your-writes) incelenecek.
9. **CsCheck/FsCheck lisans etiketi** paket eklenirken teyit (CsCheck MIT sanılıyor; Apache-2.0 olabilir — izinli ailede güvenli ama 0001 errata dersi: etiketi doğrula). + CVE kapısı (K-H1).
10. **RRULE occurrence** kapsam dışı (M8) — tekrar-dilimine dek modellenmemez, bilinçli.

## 7. İlgili

- **Öncül:** ADR 0001 §C, §I, K-C5, K-G1 (K2-E5 opt-out), K-I2 (K2-B1/G1 refinement).
- **Sıradaki:** **slice-2a spec** (saf çekirdek + kapı, DB'siz) → Claude Code build → Cowork bağımsız doğrula. Sonra **DB/Docker dilimi** → **slice-2b**.
- **Gelecek:** auth/kimlik (E3 pull+push aktif); Redis backplane; tekrar-dilimi (RRULE occurrence).

---

*✅ KİLİTLİ v3 — engineering ✓ · red-team ✓ · hedefli-doğrulama ✓ · Onur ✓. Sıradaki: slice-2a spec (saf çekirdek + taç mücevher kapısı, DB'siz) — temiz oturumda.*
