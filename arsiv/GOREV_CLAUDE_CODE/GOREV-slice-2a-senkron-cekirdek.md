# GÖREV (Claude Code) — slice-2a: Saf Senkron Çekirdeği + Taç Mücevher Kapısı  [v2]

- **Kaynak karar:** `docs/ADR/0002-senkron-mekanigi.md` (KİLİTLİ v3), özellikle **§2.A–§2.D, §2.H "saf çekirdek", §3 "slice-2a"**. Genel çerçeve: ADR 0001.
- **Rol:** Sen **build** edersin. `PROJE_HAFIZA.md` ve `docs/ADR/*`'a **DOKUNMA** (Cowork sahibi). Cowork artefaktı Desktop Commander ile bağımsız doğrular.
- **Dil:** Kod/isimler İngilizce; commit mesajı **ASCII** (locale tr-TR/cp1254 non-ASCII commit'i kırar).
- Bu dilim **DB'siz**dir: PostgreSQL, EF Core, Outbox tablosu, SignalR, HTTP ucu YOK. Her şey saf Domain + test.
- Bu v2, bağımsız spec-QA'nın bulgularını içerir (5 bloker + 9 majör kapatıldı; hedefli yeniden-doğrulama: 5 bloker-düzeltmesi TUTTU, tek çarpışma [Y-1 EffectiveOpHlc] işlendi); muğlak bırakılan nokta yok — semantik pinleri ve üreteç-kısıtlarını **birebir** uygula, tahmin etme, kırmızı gördüğün property'yi/üreteci SESSİZCE zayıflatma (şüphede Cowork'e sor).

## 0. Önce oku
`CLAUDE.md` + `PROJE_HAFIZA.md` (devir notu) + `docs/ADR/0002-senkron-mekanigi.md` (tamamı) + ADR 0001 §2 (katman kuralları).

## 1. Kapsam — NE VAR / NE YOK
**VAR:** HLC çekirdeği (A1–A4; tick, receive, clamp, per-client monoton etkin-HLC) + kanonik anahtar kodlama + zarf tipleri (B1) + sunucu-zorlamalı alan→strateji registry'si (B2, 4 entity tam tablo) + katmanlı çözümleyici (C1, C1b, C2, C3-LWW, C4) + GC-resync tetikleme mantığı (C6/H7a) + in-memory dedup (D1–D3'ün saf karşılığı) + in-memory durum (alan-versiyon şekline hizalı) + **taç mücevher kapısı: bağımsız oracle + CsCheck property'leri + 5 mutant kanıtı + eşitlik-bozucu zinciri (H1–H7a)** + KANIT.
**YOK (slice-2b/sonraki):** PostgreSQL/EF/Npgsql, `outbox_messages`, `/v1/sync` HTTP, SignalR, Testcontainers (H7b–H12), kesirli-index **rebalance** (yalnız yön), kapsam-geçişi çift-yayını (C7), entity-arası soft-ref reconciliation, auth/push-authz, RRULE occurrence.
> `Momentum.Domain` paket referansı almaya devam ETMEZ (proje referanssız kalır). CsCheck yalnız test projesine girer.

## 2. Kesin proje/dosya yerleşimi
```
src/backend/Momentum.Domain/Sync/            (yeni; saf çekirdek — namespace Momentum.Domain.Sync)
  Hlc.cs  HlcKey.cs  HlcClock.cs  HlcClamp.cs  EffectiveHlcAssigner.cs
  SyncCursor.cs  ResyncPolicy.cs
  Envelope/ChangeOperation.cs  Envelope/FieldWrite.cs  Envelope/SetDelta.cs
  Envelope/GroupWrite.cs  Envelope/IngestResult.cs
  Registry/FieldStrategy.cs  Registry/FieldStrategyRegistry.cs
  Crdt/LwwRegister.cs  Crdt/OrSetField.cs  Crdt/ResolvedGroupField.cs
  State/EntityState.cs  State/SyncState.cs  State/ClientClockStore.cs
  ConflictResolver.cs  SyncIngest.cs
tests/Momentum.SyncCore.Tests/               (yeni; xUnit + Shouldly + CsCheck)
  Oracle/   (bağımsız ikinci implementasyon — aşağıda D8)
  Properties/  UnitTests/  TestUtil/ManualTimeProvider.cs
KANIT/slice-2a/
```
Dosya-içi düzen serbest (bir public tip = bir dosya konvansiyonu); **tip adları ve sorumluluklar aşağıda sabittir, değiştirme.** Test projesi `Momentum.sln`'e eklenir; `tests/Directory.Build.props` otomatik uygulanır (BannedApiAnalyzers testte yok). Üretim tarafında `DateTime.UtcNow` zaten derlemeyi kırar → zaman HER YERDE `TimeProvider`'dan.

## 3. Teslimatlar

**D1 — HLC tipleri (K2-A1).**
- `Hlc` = readonly record struct `(long WallMs, uint Counter, Guid ClientId)`.
- `HlcKey` = readonly record struct `(Hlc Hlc, Guid OperationId)` — **LWW karşılaştırma anahtarı**.
- **Kanonik kodlama (K2-A1):** `Encode()` → `"{WallMs:D13}.{Counter:x8}.{ClientId:N}.{OperationId:N}"` — hex **zorunlu küçük-harf** (`:x8` ve Guid `"N"` zaten küçük-harf üretir; yine de testle sabitle). **Kodlama sözleşmesi:** `0 ≤ WallMs < 10^13` için tanımlıdır (13 hane sabit-genişlik; ~yıl 2286'ya dek yeter — absürt-eşik zaten çok altında tutar); negatif zaten `RejectedInvalid`.
- **Sıra otoritesi:** `HlcKey` sırası, **kodlanmış string'in `StringComparer.Ordinal` sırası** olarak TANIMLIDIR. `IComparable<HlcKey>` alan-alan hızlı karşılaştırma yapabilir ama **P9 izomorfizm property'si** (D9) ikisinin özdeşliğini kanıtlar. Guid karşılaştırmasını `Guid.CompareTo` ile YAPMA — Guid'leri `"N"` hex string'e çevirip ordinal karşılaştır (mikro-optimizasyona girme). **`Hlc`'nin tek başına sıralandığı HER yerde de** (D4 `max`, kanonik-tag seçimi, P12) aynı kural: `(WallMs, Counter, ClientId-hex-ordinal)`.
- Geçersizler: `WallMs < 0` → zarf doğrulamasında reddedilir (D5 `RejectedInvalid`).

**D2 — HlcClock (K2-A2/A3).** `HlcClock(TimeProvider tp, Guid clientId)`; durum içi `Hlc Local`.
- `Tick()`: ADR A2 birebir — `wall > L.WallMs` → `(wall,0)`; `Counter == uint.MaxValue` → `(L.WallMs+1, 0)`; değilse `Counter+1`.
- `Receive(Hlc m)`: ADR A3 Kulkarni birleştirme; **counter taşması burada da A2 kuralıyla WallMs'e taşınır** — A3'ün ÜÇ dalında da (`max(L.c,m.c)+1`, `L.c+1`, `m.c+1`): sonuç taşarsa `(w'+1, 0)`.
- İkisi de yeni `Local`'i döner; sınıf thread-safe olmak zorunda DEĞİL (istemci-tarafı tekil kullanım; sunucu tarafı D4'te ayrı).

**D3 — HlcClamp (K2-A4/1).** `static Hlc Clamp(Hlc hlc, long serverReceiveWallMs, long maxForwardSkewMs)`:
`clamped.WallMs = min(hlc.WallMs, serverReceiveWallMs + maxForwardSkewMs)`; Counter/ClientId aynen. Sabitler: `MaxForwardSkewMs = 300_000` (5 dk, parametreyle değiştirilebilir); **absürt eşik:** `hlc.WallMs > serverReceiveWallMs + 31_536_000_000` (365 gün) → clamp DEĞİL, **op reddi** (D5 `RejectedAbsurdHlc`). Geçmiş-tarih asla değiştirilmez.

**D4 — EffectiveHlcAssigner (K2-A4/2) — İKİ DÖNÜŞÜMÜN AYRIMI [kritik, tahmin etme].**
- **Clamp HER HLC'ye uygulanır:** op-HLC, per-alan HLC, küme add/remove HLC, grup HLC, order HLC — hepsi (denetçi M-A poison kapanışı).
- **Per-client monoton etkin-HLC YALNIZ op-HLC'ye uygulanır:** `effectiveOpHlc = max(clamped(opHlc), lastEffective[clientId] ⊕ tick)`. Alan/küme/grup HLC'leri clamp SONRASI **aynen korunur** — bunlar geçmiş düzenleme damgalarıdır; monoton yükseltme çevrimdışı-önceliği (fork #2 "istemci-HLC korunur") yok ederdi. LWW çözümü alan-HLC'leriyle yapılır; effective op-HLC per-client saat durumu (2b'de `outbox.hlc` restore kaynağı) + tanı içindir. *(Bu, ADR H1'deki "HER HLC'ye clamp + düğüm-monotonluk" ifadesinin Cowork-kilitli yorumudur: monotonluk alan-HLC'lerine uygulansaydı fork #2 ölür ve P1 yakınsaması imkânsızlaşırdı — ADR'yle çelişki SANMA, buna göre uygula.)*
- **İlk op:** `lastEffective[clientId]` henüz yokken `effectiveOpHlc = clamped(opHlc)`.
- `ClientClockStore` (in-memory, `sync_client_clock` karşılığı): `lastEffective[clientId]` **atomik-monoton** güncellenir (kilit içinde `max(mevcut, aday)` — GREATEST semantiği). Paralel aynı-clientId çağrıları: monotonluk bozulmaz, geri-sıçrama olmaz (D9 P4 + paralel unit test).
- `⊕ tick`: `lastEffective`'ten kesin-büyük en küçük değer (`Counter+1`, taşarsa `WallMs+1,0`).
- **Eşzamanlılık sözleşmesi (2a-pini):** `SyncIngest.Ingest` **tek global kilitle uçtan uca serileştirilir** (in-memory referans-modelde doğruluk > paralellik; `SyncState`/`ProcessedOps` bu kilit altında güvenli). ADR'nin istemci-başı advisory-lock tasarımı 2b'nin DB implementasyonuna aittir — koda `// per-client advisory lock -> slice-2b (DB)` yorumu düş. Paralel test (P4) bu sözleşmeyle koşar ve gözlemleneni (monotonluk + kayıp-güncelleme yokluğu) ölçer.

**D5 — Zarf tipleri + IngestResult (K2-B1).** `ChangeOperation`: `OperationId, ClientId, EntityId, ActorId` (**Guid**), `EntityType` (**string** — registry adıyla eşleşir), `OpHlc (Hlc)`, `Fields: IReadOnlyDictionary<string, FieldWrite>`, `Sets: IReadOnlyDictionary<string, SetDelta>`, `Groups: IReadOnlyDictionary<string, GroupWrite>`, `Order: IReadOnlyDictionary<string, FieldWrite>`.
- `FieldWrite(string? Value, Hlc Hlc)` — **değer OPAKTIR** (`string?`); çekirdek değer içeriğini yorumlamaz, yalnız HLC karşılaştırır. **TEK istisna:** `isDeleted` alanının değeri C4 türetimi için yorumlanır — tam-eşleşme küçük-harf `"true"` = silinmiş; diğer HER değer (null dahil) = silinmemiş. Tip doğrulama entity diliminin işi (yön). JSON serileştirme bu dilimde YOK (wire eşleme Application'a, 2b'ye).
- `SetDelta(IReadOnlyList<SetAdd> Adds, IReadOnlyList<SetRemove> Removes)`; `SetAdd(string Element, Guid Tag, Hlc Hlc)`; `SetRemove(string Element, IReadOnlyList<Guid> Observed, Hlc Hlc)`.
- `GroupWrite(IReadOnlyDictionary<string,string?> Fields, Hlc Hlc)` — tek grup-HLC. **Kısmi grup-yazımı LEGALDİR ve REPLACE semantiği taşır:** kazanan `GroupWrite.Fields` grup durumunun TAMAMINI değiştirir — yazılmayan üye alanlar `unset/null` olur (merge DEĞİL; merge atomikliği bozar). Boş `Fields` sözlüğü de legaldir (grubu boşaltır).
- `IngestResult(Guid OperationId, IngestResultCode Code, Hlc? EffectiveOpHlc)`; `EffectiveOpHlc`: `Applied`'da atanır; **`Applied`-kökenli `Duplicate` orijinalin değerini taşır**; tüm red kodlarında `null` (P4/P3 bunun üzerinden ölçer). `enum IngestResultCode { Applied, Duplicate, RejectedRegistryViolation, RejectedAbsurdHlc, RejectedSetCapExceeded, RejectedInvalid }`.
- **`RejectedInvalid` KAPALI LİSTE — yalnız şunlar:** (i) `OperationId/ClientId/EntityId/ActorId`'den herhangi biri `Guid.Empty`; (ii) op'taki herhangi bir HLC'de `WallMs < 0`; (iii) boş op = `Fields∪Sets∪Groups∪Order` hiç anahtar taşımıyor. **Başka doğrulama YOK** (boş `SetDelta` listeleri, boş `Observed`, boş `GroupWrite.Fields` hepsi legal no-op/yazım). Kontrol adım (1)'de yapılır.

**D6 — FieldStrategyRegistry (K2-B2) — SUNUCU-ZORLAMALI, TAM TABLO.**
`enum FieldStrategy { ScalarLww, OrSet, FractionalIndex, ResolvedGroup }`. Kayıt (ADR tablosu birebir; **grup üyeleri ayrıca işaretli**):
- `Task`: scalar → `title, notes, priority, dueAt, remindAt, projectId, isDeleted, recurrenceRule`; orset → `tags, assignees, checklistItems`; fractional (Order kanalı) → `listPos, boardPos`; group `completion` → üyeler `{status, completedAt}`.
- `Project`: scalar → `name, color, isDeleted`; orset → `members`; fractional → `pos`.
- `TaskList`: scalar → `name, isDeleted`; fractional → `pos`. (`Section` = `TaskList` ile aynı kayıt; ayrı entityType olarak EKLEME — wire'da "Section" gelirse eşleme kararı 2b/Application'da verilecek, yön notu.)
- `Tag`: scalar → `label, color, isDeleted`.
**Zorlama kuralı (spec-kilidi):** bilinmeyen entityType VEYA bilinmeyen alan VEYA **yanlış kanal** (örn. grup üyesi `status` `Fields`'tan; OR-Set alanı `Fields`'tan; skaler alan `Sets`'ten; fractional alan `Fields`'tan) → **OP BÜTÜNÜYLE reddedilir**, `RejectedRegistryViolation`, durum DEĞİŞMEZ (remap YOK — ADR H11 "kanal-atlayan alan reddedilir" ile tutarlı; Cowork kilidi). Ad eşleşmesi **Ordinal, case-sensitive** (entityType + alan/set/grup adları).

**D7 — Çözümleyici + durum + ingest (K2-C1–C4, C6, D1–D3).**
- `LwwRegister`: `Apply(FieldWrite w, Guid opId)` — `HlcKey(w.Hlc, opId) > mevcutKey` ise değer+key değişir; **eşit veya küçükse mevcut KALIR** (kesin-büyük kazanır). Kazanan `operationId` saklanır (`sync_scalar_meta` hizası).
- `ResolvedGroupField`: tek grup-`HlcKey` karşılaştırması; kazanan grubun TÜM alanları atomik yazılır — asla alan-alan karışmaz (H6/M5 mutantı bunu ısırır).
- `OrSetField` (add-wins): eleman mevcut ⇔ iptal-edilmemiş ≥1 add-tag. `Remove` yalnız `Observed[]`'teki tag'leri iptal eder (görmediği eşzamanlı add'i ASLA iptal etmez). **Görülmemiş-tag iptali KALICIDIR (tombstone, yakınsama-pini):** `Observed[]`'teki bir tag-id henüz görülmemiş olsa bile kalıcı iptal kaydı yazılır; sonradan gelen aynı-tag `Add` **ölü doğar** (üyelik vermez) — aksi halde P1 permütasyon-yakınsaması {add;remove} çiftlerinde kırılır. Ölü-doğan add'in damgası da set-aktivite max'ına (C4 türetimi) **girer**. **Compaction (K2-C2):** saf modelde `CompactBelow(Hlc horizon)`: elemanın horizon-altı iptal-edilmemiş add-tag'leri **tek kanonik tag'e** indirilir; kanonik = horizon-altı tag'ler içinde **en yüksek `(Hlc, Tag-hex)` sıralı** olan (determinist). İptal edilmişler ve horizon-üstü tag'ler aynen kalır. **Remove-remap (Y2):** compaction sonrası gelen `Observed[]` içinde compact-edilmiş (artık var olmayan) tag varsa **elemanın kanonik tag'ine remap edilir** — remove niyeti kaybolmaz. Bunun için compaction `eskiTag → kanonikTag` eşlemesini eleman-başına saklar; **eşleme COMPOSE edilir** (zincirli compaction'da lookup canlı tag'e kadar transitif çözülür: `T→C1`, sonra `C1→C2` ⇒ `T→C2`). İptal-kayıtları/tombstone'lar 2a'da budanmaz (yön: budama kuralı 2b GC/retention diliminde). **Cap (admission-control, CRDT yasası DEĞİL):** kesin formül — `mevcutAktifTagSayısı(eleman) + op'un o elemana GERÇEKTEN-YENİ-AKTİF tag ekleyecek add sayısı > 100 → op bütünüyle RejectedSetCapExceeded`. Op-içi remove'lar sayımı DÜŞÜRMEZ; zaten-mevcut tag tekrarı ve ölü-doğacak add "yeni-aktif" SAYILMAZ. Kısmi uygulama yok.
- **Set-damga karşılaştırmaları (tip-pini):** `SetAdd`/`SetRemove` yalnız `Hlc` taşır (opId yok — `sync_orset_tags` hizası). Set damgalarının `HlcKey`'le (isDeleted kazanan-key'i, compaction horizon'u) karşılaştırıldığı yerlerde karşılaştırma `(WallMs, Counter, ClientId-hex)` **öneki** üzerinden yapılır; önek-eşitliği → "büyük DEĞİL" ve "horizon-altı DEĞİL". Remove damgaları, C4 conflict-türetimi için eleman-başına saklanır (şekil-hizasının bilinçli küçük genişletmesi — not düş).
- Kesirli-index: `Order` kanalı alanları **skaler-LWW ile aynı mekanik** (`LwwRegister`); değer opak positionKey. **Rebalance bu dilimde YOK** (sunucu-otoriter, 2b+; koda `// server-authoritative rebalance -> slice-2b+` yorumu).
- `isDeleted` + çakışma-yüzeyleme (K2-C4): `EntityState.HasDeleteEditConflict` **türetilmiş** (saklanmaz): `isDeleted` alanının güncel değeri `"true"` VE ∃ başka alan/grup/order/set-yazımı ki damgası `isDeleted`'ın kazanan `HlcKey`'inden **büyük** → true. Alan/grup/order için `HlcKey` karşılaştırılır; set-yazımı için elemanların add/remove damgalarının en büyüğü **önek kuralıyla** (D7 tip-pini: `(WallMs,Counter,ClientId-hex)`; önek-eşit → büyük değil; ölü-doğan add dahil) karşılaştırılır. Undelete (daha büyük `"false"`) bayrağı doğal düşürür.
- `SyncState`: in-memory; `(entityType, entityId) → EntityState`; `EntityState` = alan→`LwwRegister`, grup→`ResolvedGroupField`, set→`OrSetField` (alan-versiyon kalıcılık modeline şekil-hizalı; IO yok). `ProcessedOps`: `(clientId, operationId) → IngestResult` (in-memory `processed_operations`; **orijinal sonucu** saklar).
- `SyncIngest.Ingest(ChangeOperation op, long serverReceiveWallMs)` sırası (**sabit**): (1) zarf doğrulama (`RejectedInvalid` kapalı-liste); (2) dedup; (3) absürt-HLC kontrolü (TÜM HLC'ler; biri absürtse op reddi); (4) TÜM HLC'lere clamp; (5) registry zorlaması (`RejectedRegistryViolation`); (6) OR-Set cap ön-kontrolü (`RejectedSetCapExceeded`); (7) effective op-HLC ataması (D4); (8) çözümleyici uygulaması (atomik — tüm yazımlar uygulanır); (9) sonuç `ProcessedOps`'a kaydedilir. Kısmi uygulama HİÇBİR dalda yok.
- **Dedup/Duplicate semantiği (B1-pini):** `ProcessedOps` İLK işlemin orijinal sonucunu saklar. Tekrar gelen `(clientId, operationId)`: orijinal `Applied` ise → **`Duplicate`** döner (`EffectiveOpHlc` = orijinalinki); orijinal RED ise → **aynı red kodu** döner. Her iki durumda durum DEĞİŞMEZ (D3 etki-bir-kez). Reddedilenler de kaydedilir (replay determinizmi — clamp/absürt receive-time'a bağlı olduğundan dedup ONLARDAN ÖNCE gelir; sıra bilinçli).
- `ResyncPolicy` (K2-C6/H7a): `SyncCursor` = readonly record struct `(ulong Xid, long Seq)`, sıra `(Xid, Seq)`; `SyncCursor.AtHorizon(xid)` → `(xid, 0)` sentinel (**`Seq ≥ 1` gerçek-satır değişmezi 2b'de zorlanır** — tip yorumuna yaz); `ShouldResync(since, gcHorizon) => since < gcHorizon`.

**D8 — Bağımsız ORACLE (K2-H1) — üretimden İZOLE.**
`tests/Momentum.SyncCore.Tests/Oracle/` altında **ikinci, bağımsız, bilinçli-naif** implementasyon. **KURAL:** Oracle kodu `Momentum.Domain.Sync` tiplerini **KULLANAMAZ** (using yasak) — kendi mini tipleriyle (`OracleOp`, düz dict/list modeli) çalışır; test gövdesi üretim zarfını oracle-girdisine map eder (bu eşleme trivial ve görünür olmalı). Oracle **ingest dönüşümünü D7'nin sabit adım sırasıyla (1–9) BİREBİR modeller** — kendi sıra icat etme: (1) invalid-kapalı-liste, (2) dedup+Duplicate-eşleme, (3) absürt-red, (4) TÜM-HLC clamp, (5) registry-red, (6) cap-red (kesin formül), (7) per-client monoton etkin op-HLC (ilk-op dahil), (8) LWW/grup-replace/OR-Set(tombstone+compaction+compose-remap)/order çözümü, (9) sonuç kaydı. Basitlik > hız (LINQ ile açık-seçik). Oracle karşılaştırması: final durumun **gözlemsel projeksiyonu** — alan değerleri + kazanan HlcKey'ler + set üyelikleri (eleman kümeleri) + conflict bayrakları + sonuç kodları + **Applied op-başına `EffectiveOpHlc`**. (Add-tag iç yapısı compaction'da farklılaşabilir; ÜYELİK + davranışsal eşdeğerlik karşılaştırılır; compaction determinizmi ayrıca P7'de üretim-üretim karşılaştırmasıyla sınanır.) *(K2-H3'ün "tek Outbox olayı" yarısı 2b'ye aittir; 2a karşılığı P2 etki-bir-kez + tek `Applied` kaydıdır.)*

**D9 — CsCheck PROPERTY'leri (K2-H2/H5) — hepsi zorunlu.**
Paket: **CsCheck 4.7.0+ (Apache-2.0)**. Testler `ManualTimeProvider` (el-yapımı, `TestUtil/`; paket EKLEME) ile **sabit/kontrollü zaman** kullanır — clamp `serverReceiveWallMs`'i test belirler, determinizm bozulmaz. Üreteçler: makul aralıklar (wallMs ±10 dk pencere + skew-aşan + absürt vakalar; 1–4 client; 1–3 entity; alan/set/grup karışık op'lar; **seed raporlanabilir** olmalı).
- **P1 Permütasyon-yakınsaması:** aynı op KÜMESİ farklı sıralarla ingest → final **gözlemsel durum** özdeş (alan değerleri, kazanan key'ler, üyelikler, bayraklar). (`ClientClockStore` içeriği, `EffectiveOpHlc` değerleri ve sonuç-kodu-sırası hariç — onlar sıraya bağlı olabilir.) Her permütasyonda `serverReceiveWallMs` AYNI sabit değer. **Üreteç-kısıtları (bilinçli — sessiz daraltma değil):** (i) eleman-başına toplam add sayısı ≤ 20 (cap admission-control'dür, CRDT yasası değil; sıraya-bağlı cap reddi P1'i meşru kırar — cap davranışı P7 + hedefli unit'te sınanır); (ii) `operationId`'ler benzersiz (çift yalnız bit-özdeş op olarak üretilebilir); (iii) op-kümesinde compaction olayı YOK (compaction-anının permütasyonu meşru ıraksama yaratır; compaction eşdeğerliği P7'nin işi).
- **P2 İdempotentlik:** işlenmiş rastgele durum üzerine **orijinali `Applied` olan** bir op tekrar (dedup AÇIK → `Duplicate`, durum aynı, `EffectiveOpHlc` orijinalle aynı) VE dedup atlanarak resolver'a doğrudan aynı yazım tekrar (durum yine aynı — eşit key kazanamaz). Ayrıca: orijinali RED olan op'un tekrarı aynı red kodunu döner, durum değişmez (hedefli unit).
- **P3 Oracle-diff (determinizm):** rastgele senaryo (op dizisi + **serbest/monoton-olmayabilen** receive zamanları + compaction anları + kısmi grup-yazımları + görülmemiş-tag remove'ları dahil) → üretim `SyncIngest` sonucu == oracle sonucu (D8 projeksiyonu, `EffectiveOpHlc` dahil). EN KRİTİK property.
- **P4 Monotonluk:** per-client `Applied` sonuçlarının `EffectiveOpHlc` dizisi kesin artan; paralel aynı-clientId ingest'te de (ayrıca `Parallel.For` unit testi: 8 thread × 50 op, tek clientId → dönen `EffectiveOpHlc`'ler üzerinde monotonluk + kayıp-güncelleme yok).
- **P5 Clamp sınırı:** clamp sonrası her HLC `WallMs ≤ receive+skew`; `WallMs ≤ receive+skew` olan girdiler değişmemiş; absürt girdili op reddedilmiş ve durum değişmemiş.
- **P6 Eşitlik-bozucu ZİNCİRİ (K2-H5):** özel üreteç katman-katman: (a) eşit `(WallMs,Counter)` + farklı `ClientId` → clientId çözer; (b) eşit `(WallMs,Counter,ClientId)` + farklı `OperationId` → operationId çözer; iki durumda da determinist tek-kazanan, iki uygulama sırası da aynı kazanan.
- **P7 OR-Set yasaları:** add-wins (remove görmediği **horizon-üstü/eşzamanlı** add'i silemez); üyelik determinist; tombstone-yakınsaması ({add;remove} çifti her iki sırada aynı sonuç); compaction **gözlemsel-eşdeğer** + **remove-remap niyet korunumu** (compact-edilmiş tag'e remove gelir → eleman yine silinir; **≥2 ardışık compaction'lı zincir vakası zorunlu** — compose-remap sınanır); cap aşımı reddi durumu değiştirmez (hedefli unit: kesin formül sınırında ±1). **Üreteç-kısıtı (ADR Y2'nin "ufuk-altında yeni-gözlem imkânsız" varsayımının saf-model karşılığı):** compaction içeren akışlarda her remove ya (a) yalnız horizon-üstü tag'leri gözler ya da (b) elemanın horizon-altı **aktif tag'lerinin TAMAMINI** gözler. (Kısıtsız karışım gerçek sistemde oluşamaz; kısıtsız üreteç eşdeğerlik/add-wins'i meşru kırar — property'yi DEĞİL üreteci bu kurala bağla.)
- **P8 Grup atomikliği (K2-H6):** `completion` grubunda final `{status, completedAt}` HER ZAMAN tek bir op'un yazdığı içerik (REPLACE semantiği; karışım imkânsız — kazanmayan op'un hiçbir üyesi sızmaz); **üreteç kısmi grup-yazımları da üretir** (yalnız `status`, yalnız `completedAt`, boş sözlük); grup değişmezi registry-zorlamasıyla birlikte (üye alan skaler kanaldan gelirse red).
- **P9 Kodlama izomorfizmi:** rastgele `HlcKey` çiftleri (**üreteç alanı: `WallMs ∈ [0, 10^13)`** — kodlama sözleşmesi; ayrıca **eşit-önek bias'ı**: aynı `(WallMs,Counter)`, aynı `(WallMs,Counter,ClientId)` çiftleri sık üretilir) → `CompareTo` sonucu == `Encode()` string'lerinin `StringComparer.Ordinal` sonucu; `Encode` her zaman küçük-harf, sabit-genişlik, tek format.
- **P10 Registry-zorlama:** yanlış-kanal/bilinmeyen-alan op'ları asla durum değiştirmez, her zaman `RejectedRegistryViolation`.
- **P11 GC-tetikleme (K2-H7a):** `since < gcHorizon ⇔ ShouldResync == true`; `(horizon,0)` sentineli `Seq=1`'li aynı-xid satırından küçük.
- **P12 HLC saat yasaları:** `Tick`/`Receive` monoton (`yeni > eski Local`); `Receive(m) ≥ m` ve `≥ eski Local`; counter-taşması wallMs'e taşınır (uint.MaxValue vakası özel üreteçle; üç Receive dalı da). Hlc-tekil sıralama `WallMs ∈ [0, 10^13)` alanında üretilir.
CsCheck iter: property başına ≥ 1000 (`CsCheck_Iter` env ile artırılabilir); fail'de seed'i test çıktısına yaz.

**D10 — MUTANT KANITLARI (K2-H4) — 5 mutant, hepsi ISIRMALI.**
Her biri için: mutasyonu uygula → `dotnet test tests/Momentum.SyncCore.Tests` → **en az 1 test FAIL** → çıktıyı `KANIT/slice-2a/mutant-N-<ad>.txt`'e kaydet → `git checkout` ile geri al → temiz koşuda yeniden YEŞİL. Kanıt dosyasına hangi satırın nasıl değiştirildiğini yaz. (ADR H4 kanıt yolunu `KANIT/slice-2/` yazar; bu dilim için geçerli yol **`KANIT/slice-2a/`** — Cowork böyle doğrulayacak.)
1. `mutant-1-hlc-compare`: `HlcKey` karşılaştırmasında `>` → `<` (tersine çevir).
2. `mutant-2-orset-removewins`: `OrSetField.Remove` observed-kontrolünü kaldır (remove her add'i iptal etsin → remove-wins).
3. `mutant-3-no-clamp`: `HlcClamp.Clamp` girdiyi aynen döndürsün.
4. `mutant-4-no-opid-tiebreak`: `HlcKey` karşılaştırmasından `OperationId`'yi çıkar (yalnız `(WallMs,Counter,ClientId)`).
5. `mutant-5-group-fieldwise`: `ResolvedGroupField` grup-HLC'yle atomik REPLACE yerine üye-alan-başına ayrı LWW-merge yapsın. (Bu mutant ancak **kısmi grup-yazımları** varken ısırılabilir — P8/P3 üreteçleri bunu ürettiği için ısırır; tam-üyeli yazımlarla ısırılamayacağını fark edersen üreteci değil ANLAYIŞINI kontrol et, spec'e uy.)

**D11 — Bağımlılık + kayıt.** Yeni paket YALNIZ test projesine: `CsCheck` (**Apache-2.0** — Cowork 18 Tem 2026'da NuGet'ten teyit etti; ADR risk #9'daki "MIT sanılıyor" notu bu teyitle kapandı. Kurulumda etiketi YİNE doğrula; farklı görürsen — MIT dahil ikisi de izinli — raporda belirt). `docs/dependencies.md`'ye satır ekle (ad+sürüm+lisans+CVE). Üretim projelerine paket EKLENMEZ. `dotnet list package --vulnerable` D12/slice-1 kapısından geçmeli.

**D12 — verify.** `araclar/verify.ps1` değişmeden geçmeli (sln-hedefli olduğundan yeni test projesi otomatik kapsanır: build -warnaserror → tüm testler → CVE-parse). Yeni script YAZMA; verify kırılırsa nedenini raporla.

## 4. Bağımlılıklar
**İzinli:** CsCheck (Apache-2.0) — YALNIZ test. Mevcutlar aynen (Mediator, Shouldly, Serilog, xUnit, NetArchTest, BannedApiAnalyzers, ...).
**YASAK:** FsCheck (CsCheck kilitlendi — karışım olmasın) · MediatR 13+ · AutoMapper · FluentAssertions 8+ · her türlü DB/EF/Npgsql paketi (bu dilimde) · `Microsoft.Extensions.TimeProvider.Testing` (el-yapımı `ManualTimeProvider` kullan). Şüphede ekleme, Cowork'e sor.

## 5. Kabul kriterleri (verify çıktısıyla kanıtlanır)
1. `dotnet build -warnaserror` → **0 uyarı / 0 hata**; `Momentum.Domain` hâlâ paket-referanssız.
2. `dotnet test` → TÜMÜ yeşil: slice-1'in 13 testi + yeni SyncCore testleri (P1–P12 property'leri + unit'ler + paralel monotonluk testi). Toplam test sayısını raporla.
3. **5 mutant kanıtı** `KANIT/slice-2a/`'da; her biri FAIL çıktısı + geri-alım notu içerir; final çalışma ağacında mutant kalıntısı yok.
4. Oracle, `Momentum.Domain.Sync`'e using-bağımlılığı içermiyor (D8 kuralı — raporda dosya başlıklarıyla göster).
5. Registry tablosu ADR B2 ile birebir (4 entityType; Task 8 skaler + 3 orset + 2 order + 1 grup).
6. CVE parse temiz; `docs/dependencies.md` güncel (CsCheck satırı).
7. Sır yok; `bin/obj` ignore; PROJE_HAFIZA.md / docs/ADR dokunulMAMIŞ.

## 6. Kırmızı çizgiler
Sır repoya girmez · yalnız MIT/Apache/BSD-3 (lisans+CVE kapısı) · kalıcı silme/para/güvenlik YOK · `bin/obj/build` git-ignore · DB/HTTP/SignalR/auth bu dilimde YOK · `DateTime.UtcNow` üretimde derlemeyi kırar (TimeProvider).

## 7. Teslim protokolü
1. `araclar/verify.ps1` çalıştır; TÜM çıktıyı rapora koy.
2. Kodu commit et (ASCII), ör: `feat(sync): slice-2a pure sync core (HLC + resolver + registry) + crown jewel gate`.
3. **PROJE_HAFIZA.md / docs/ADR'ye DOKUNMA.**
4. Raporda ver: (a) build özeti, (b) test sayıları (slice-1 + yeni ayrımıyla), (c) verify exit kodu, (d) CsCheck sürüm+lisans teyidi, (e) KANIT dosya yolları (5 mutant), (f) oracle-izolasyon gösterimi, (g) sapma/varsayımların TAM listesi.

> Cowork senin beyanına güvenmez; artefaktı kendi derleyip test edecek, mutantları KENDİ yeniden koşacak, oracle-izolasyonu ve registry tablosunu ADR'ye karşı kendi denetleyecek. Kanıtları eksiksiz bırak.
