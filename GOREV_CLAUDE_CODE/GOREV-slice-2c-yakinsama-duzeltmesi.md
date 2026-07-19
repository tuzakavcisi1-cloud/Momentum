# GÖREV (Claude Code) — slice-2c: OR-Set damga yakınsaması (ADR 0002 ERRATA E-1 / E-1b)  [v3]

> **ÜÇ TUR BAĞIMSIZ DENETİMDEN GEÇTİ:** v1 → (red-team: 5 bloker + 5 majör + 7 minör · teknik doğruluk denetimi: 2 bloker + 5 majör + 6 minör) → v2 → (**hedefli yeniden-doğrulama: 1 kalan bloker + 2 majör + 1 minör**) → **v3**.
> **v2'nin kusuru — ev tarihinin tam olarak uyardığı kalıp:** v2, v1'in 5. blokerini ("yalnız `WallMs` karşılaştıran max-join tüm kapılardan kaçıyor") kapattığını **beyan etmiş ama fiilen kapatmamıştı**: D2d'nin üreteci şart koşulmamıştı, ısırdığını kanıtlayacak mutant yoktu, ve testin ineceği dosyanın mevcut `H(wall) => new(wall, 0, Ids.Client(0))` deyimi körlüğü **garanti ediyordu**. Ayrıca D2b/D2c'nin izolasyon pini yalnız set kanalını kapatıyordu (field/order/group kanalları açıktı → mutant-5/6 yine kör kalabilirdi) ve D0'ın ön-koşul assert'i **yanlış katmandaydı** (clamp ÖNCESİ damgalara bakıyordu; clamp sonrası özdeşleşen iki damga ön-koşulu geçip ayırt edici yüzey bırakmıyordu).
> **v1'in kusurları — hepsi bu dilimin kendi ilkesinin ihlaliydi:** (1) `mutant-3`'ün kapısı **kör**dü (`LoadTag` üretimde tag başına yalnız BİR kez çağrılıyor → max-join ile son-yazan ayırt edilemez); (2) **bağımsız Oracle da aynı kusuru taşıyor** (`OracleEngine.cs:291` `TryAdd`) → D1'den sonra P3 kırmızıya döner, ama v1'in kabul kriteri "75 test değişmeden yeşil" diyordu (builder'ı P3'ü zayıflatmaya iterdi); (3) `mutant-6`'nın **ısırma yüzeyi bugün hiç yok**; (4) `D2b`/`D2c` fixture izolasyonu pinlenmediği için `mutant-5`/`mutant-6` sessizce ısırmayabilirdi; (5) **"yalnız `WallMs` karşılaştıran max-join" v1'in TÜM kapılarından kaçıyordu**; (6) KANIT v2'nin dayattığı özet satırı bu makinede hiç basılmıyor (Türkçe yerel).
> **Bu dilim bir KUSUR DÜZELTMESİDİR, özellik değil.** Kusur Cowork'ün slice-2b2 doğrulamasında bulundu, temiz ağaçta sabit tohumla determinist yeniden üretildi, kök nedeni **kanıtlandı** (hipotez değil).
> **Kaynak kanıt:** `KANIT/slice-2b2/cowork-bagimsiz-dogrulama.txt` §6 (BULGU-3) ve §7 (BULGU-4). **Kaynak karar:** ADR 0002 **K2-C2 ERRATA E-1 / E-1b** (Onur kilitledi, 19 Tem 2026).

- **Rol:** Sen **build** edersin. `PROJE_HAFIZA.md` ve `docs/ADR/*`'a **DOKUNMA**. Cowork artefaktı bağımsız doğrular.
- **Dil:** Kod/isimler İngilizce; commit mesajı **ASCII**.
- Testler Docker İSTER (Persistence.Tests). Docker'sız koşuda fail = doğru davranış (skip/kör-kapı YOK).

## 0. Önce oku
`CLAUDE.md` · `PROJE_HAFIZA.md` (oturum-7 devri) · **`KANIT/slice-2b2/cowork-bagimsiz-dogrulama.txt` §6+§7** · ADR 0002 **K2-C2 + ERRATA E-1/E-1b**, **K2-C4** · `Domain/Sync/Crdt/OrSetField.cs` (TAMAMI) · `Domain/Sync/State/EntityState.cs` · `Domain/Sync/Hlc.cs` · `Infrastructure/Sync/SyncStore.cs` · `Infrastructure/Sync/SyncRowHydration.cs` · **`tests/Momentum.SyncCore.Tests/Oracle/OracleEngine.cs`** (D1b'nin sebebi) · `tests/Momentum.Persistence.Tests/SemanticRoundTripTests.cs`.

## 1. KANITLANMIŞ KUSUR (yeniden keşfetme; doğrula ve geç)
`P1_permutations_of_an_op_set_converge`, **CsCheck tohumu `fcGWfMJW_dB2`** ile düşer. Tek fark: `E|Project|00000002000200000000000000000000` satırında `C|1` (ileri) ↔ `C|0` (ters). `C|` = `EntityState.HasDeleteEditConflict` (K2-C4, **türetilmiş**).

**Zincir (denetimde aritmetikle teyit edildi):** `(el1, tag 00000004-0002-…)` çifti iki damgayla geliyor —
`A = 1700000300000.00000005.…0001` (op#4; clamp tavanı `BaseWall + 300_000`'e kırpılmış) ve
`B = 1700000046192.00000000.…0000` (op#6). `deleteKey = 1700000300000.00000004.…0003`.
Sıralama: **A > deleteKey > B**. `ApplyAdd`'in `Adds.TryAdd`'i **ilk geleni** saklıyor → `MaxStamp()` sıraya bağlı → bayrak `1↔0`. Üyelik/`Cancelled`/`RemoveStamps` iki sırada da AYNI → `F|`/`O|`/`S|` yakınsıyor.

## 2. Kapsam — NE VAR / NE YOK

**VAR:** E-1'in üç uygulama noktası · **Oracle'ın eş-düzeltmesi (D1b)** · E-1b (kalıcılık GREATEST'i + ısırdığını kanıtlayan test) · pinli-tohum + **üreteçten bağımsız literal** regresyon · C4'ün **add** ve **remove** pozitif testleri · komütatiflik property testi · hidrasyon round-trip regresyonu · collation kapısının genişletilmesi · `CompactBelow`↔`MaxStamp` bağının pinlenmesi · **6 mutant** + KANIT.

**YOK — adlandırılmış erteleme (sessiz açık bırakma YASAK):**
- Register/group/order birleştirme yollarının **sistematik komütatiflik taraması** (Onur kapsamı "kusur + property-test sertleştirme" olarak kilitledi).
- **Compaction↔remove sıra bağımlılığı** — K2-C2/Y2'nin *tasarlanmış* GC ödünleşimi, kusur değil (ADR E-1 yan-kazanç fıkrası düzeltildi).
- **`Cancelled` canonical↔observed sapması** (`OrSetField.cs:70-71` `canonical` iptal ederken `SyncStore.cs:129-131` ham `observed`'ı tombstone'luyor) ve **`Remap` hiç kalıcı değil** (`DumpRemap`/`LoadRemap` yok; `DumpRemoveStamps()` **ölü kod**). İkisi de yalnız compaction ile tetiklenir; `SyncIngest.Compact`'in **üretim çağıranı YOK**. Latent, adlandırıldı, kendi işine bırakıldı.
- `Db.cs:63` `at ?? DateTimeOffset.UtcNow` yedeği (2b2 §8 küçük bulgusu).
- `SyncPuller` snapshot'ının tel-görünür damgasının artık max olması: **doğru yön**, ama testle pinlenmiyor.
- 2b3/collab-auth (K2-G2 grup-düşürme yarısı, K2-C7 pull ayağı, push-authz E3, Redis backplane).

## 3. Teslimatlar

**D0 — KIRMIZI ÖNCE [PAZARLIKSIZ, İLK İŞ].**
Düzeltmeye DOKUNMADAN pinli-tohum regresyon testini yaz ve **kırmızı olduğunu kanıtla**.
- Test: `P1_regression_seed_fcGWfMJW_dB2` — P1'in gövdesi, `Check.Sample(..., seed: "fcGWfMJW_dB2", iter: 1)`.
- **Kırmızı-önce komutu (BİREBİR; `CsCheck_Seed` env değişkeni VERİLMEZ — CsCheck'te açık `seed` argümanı env'i ezer):**
  `dotnet test <SyncCore.Tests> --nologo --filter "FullyQualifiedName~P1_regression_seed_fcGWfMJW_dB2"`
- **ÖN-KOŞUL ASSERT'İ (tohum sürüklenmesine karşı, ZORUNLU) — KATMAN PİNİ [v3 düzeltmesi]:** test, üretilen op kümesinde aynı `(entityType, entityId, setName, element, tag)` için **≥2 farklı `Hlc`** bulunduğunu doğrular; bulamazsa `Assert.Fail("seed drift: pinned case no longer exhibits the duplicate-tag surface")`.
  **Karşılaştırma CLAMP SONRASI damgalar üzerinde yapılır** — `HlcClamp.Clamp(op.Sets[s].Adds[i].Hlc, matIngest.ReceiveWall)` (public). *v2 bunu ham üreteç damgalarına bakarak yazdırıyordu; `WallOffset ∈ [-600_000, 600_000]` ama clamp tavanı `recv + 300_000` olduğundan offset'i 400_000 ve 500_000 olan iki add clamp sonrası **özdeşleşir** → ayırt edici yüzey sıfırdır ama ön-koşul yine de geçerdi. §1'in A damgası zaten tam clamp tavanında (`1700000300000`).*
  **Dürüstlük sınırı:** bu koşul **gerekli ama yeterli değildir** (vakanın ısırması için `deleteKey`'in iki damga arasına düşmesi de gerekir). Bir **sürüklenme alarmıdır**, vakayı yeniden pinlemez — asıl sürüklenmez kapı D0b'dir.
- KANIT'a düzeltmeden ÖNCEki FAIL'in ve SONRAki PASS'ın **ham** çıktısı yapıştırılır.
- **Gerekçe pini:** rastgele tohumla 20 ardışık koşumda 0 FAIL ölçüldü (Cowork). "Yeşil gördüm" bu kusur için kanıt DEĞİLDİR.

**D0b — ÜRETEÇTEN BAĞIMSIZ LİTERAL REGRESYON [asıl kalıcı kapı].**
§1'in somut vakasını **elle** kur (CsCheck yok, üreteç yok): tek entity, tek set, tek eleman, aynı tag'e `A` ve `B` damgalı iki add, `isDeleted:true` @ `deleteKey`; ileri ve ters sıra projeksiyonlarının **eşit** olduğunu assert et. Bu test tohum/üreteç/CsCheck sürümünden **bağımsızdır ve sürüklenemez**; D0 sürüklense bile bu kalır.

**D1 — `OrSetField.ApplyAdd` = max-join (E-1 nokta 1).**
```csharp
// ERRATA E-1: a CvRDT merge must be a semilattice JOIN. "first stamp wins" is idempotent
// but NOT commutative -> MaxStamp() (and thus K2-C4) became ingest-order dependent.
if (!element.Adds.TryGetValue(add.Tag, out var existing) || add.Hlc.CompareTo(existing) > 0)
{
    element.Adds[add.Tag] = add.Hlc;
}
```
**PİN: karşılaştırma TAM `Hlc.CompareTo` ile yapılır** — `(WallMs, Counter, ClientId-hex-ordinal)` üçlüsünün tamamı. *Yalnız `WallMs` karşılaştıran bir "max" v1'in tüm kapılarından kaçıyordu ve `WallMs` eşitliğinde (clamp tavanına kırpılan damgalarda **sık**) komütatifliği ihlal etmeye devam ediyordu.* Born-dead damga kaydı ve `Cancelled` mantığı **korunur**; üyelik semantiği **değişmez**.

**D1b — `OracleEngine`'in eş-düzeltmesi [BLOKER'DI].**
`tests/Momentum.SyncCore.Tests/Oracle/OracleEngine.cs:291` de `el.Adds.TryAdd(add.Tag, add.Hlc)` kullanıyor. Bugün P3 (`OracleDiffProperty`) yeşil çünkü **iki motor aynı hatayı paylaşıyor**. D1'den sonra üretim max-join'e geçer, Oracle ilk-yazanda kalır → **P3 kırmızıya döner**.
- Oracle'ın değeri **bağımsızlığındandır**: `OrSetField`'tan kopyalama YAPMA. Kuralı **ADR E-1 metninden yeniden yaz**, Oracle'ın kendi naif stilinde. Raporda bunu açıkça beyan et.
- Bu, kabul kriteri 2'nin **adlandırılmış istisnasıdır** (§5/2).

**D2 — `OrSetField.LoadTag` = aynı max-join (E-1 nokta 2) — DÜRÜSTLÜK BEYANI ZORUNLU.**
Bugün `state.Adds[tag] = stamp` ile **son yazanı** saklıyor; `ApplyAdd` ile çelişiyor. Aynı kural iki yerde farklı olamaz → düzelt. D1 ile **ortak özel yardımcı** kullan (yardımcı **yalnız damga** birleştirir; `Cancelled.Add` yolu dışarıda kalır).
- **KAPI DEĞİL, API SÖZLEŞMESİ:** `sync_orset_tags` PK'sı `(entity_type, entity_id, set_name, element, add_tag)` olduğundan `SyncRowHydration` bir `(element, tag)` için **en fazla BİR** satır okur; ayrıca `SyncCommandHandler`/`SyncPuller` her seferinde **taze** state hidratlar. Yani üretimde `LoadTag` aynı anahtar için **iki kez çağrılmaz** ve max-join ile son-yazan **üretim yolunda ayırt edilemez**.
- Kapısı bir **birim testidir**: `LoadTag`'i aynı `(element, tag)` için **azalan damgayla iki kez** çağır → `MaxStamp()` yüksek damgayı vermeli. Raporda **"bu bir API sözleşmesi kapısıdır, üretim yolu kapısı değildir"** diye adlandır. *(v1 bunu D4'ün kapıladığını iddia ediyordu; YANLIŞTI.)*
- **UYGULAMA PİNİ [v3]:** `LoadTag`, `ApplyAdd`'i **çağırarak uygulanamaz**. Öyle yazılırsa `LoadTag`'e ait mutasyona uygun satır kalmaz ve `mutant-3` fiilen `mutant-2`'ye çöker (ayırt edicilik kaybı). İkisi de **ortak damga-birleştirme yardımcısını** çağırır, biri diğerini değil.

**D2b — C4 ADD-DALI POZİTİF TESTİ (birim, Docker'sız).**
`isDeleted:true` @ `deleteKey`; OR-Set'e `deleteKey`'den **büyük** damgalı bir add ⇒ `HasDeleteEditConflict == true`.
- **İZOLASYON PİNİ [PAZARLIKSIZ — v3'te GENİŞLETİLDİ]:** bu fixture'da **hiçbir remove damgası `deleteKey`'i aşmayacak** VE **`isDeleted` dışında hiçbir field/order/group register'ı `deleteKey`'i aşmayacak**. *`HasDeleteEditConflict`'in DÖRT kanalı vardır (`EntityState.cs:79-114`: fields, orders, groups, sets); herhangi biri `deleteKey`'i aşarsa metot `true` döner ve set dalını hedefleyen `mutant-5` **ısırmaz** — test kör kapı olur. v2 yalnız remove kanalını pinliyordu.*
- Mevcut `SemanticRoundTripTests.Tombstone_persists_and_delete_edit_conflict_matches_domain` bu ayağı **zaten karşılıyor** ama **Docker'a bağımlı**; D2b'nin katma değeri "birim seviyesinde, Docker'sız kapı"dır. Bunu raporda böyle adlandır.

**D2c — C4 REMOVE-DALI POZİTİF TESTİ (birim, YENİ — bugün hiç yok).**
`isDeleted:true` @ `deleteKey`; `deleteKey`'den **büyük** damgalı bir `ApplyRemove` (görülmemiş tag gözlemleyerek) ⇒ `HasDeleteEditConflict == true`.
- **İZOLASYON PİNİ [PAZARLIKSIZ — v3'te GENİŞLETİLDİ]:** bu fixture'da **hiçbir add damgası `deleteKey`'i aşmayacak** VE **`isDeleted` dışında hiçbir field/order/group register'ı `deleteKey`'i aşmayacak** (aynı dört-kanal gerekçesi; aksi hâlde `mutant-6` ısırmaz).
- *Gerekçe:* denetim tüm test ağacını taradı — `RemoveStamps` dalının C4'ü tetiklediğini assert eden **hiçbir test yok**. `SemanticRoundTripTests` remove@5 < isDeleted@10 kullanıyor, yani o dal kaldırılsa bile yeşil kalıyor. `mutant-6`'nın bugün ısırma yüzeyi YOKTUR; D2c onu yaratır. **"Mevcut testlerde var mı diye bak" kaçış maddesi v2'de KALDIRILMIŞTIR.**

**D2d — KOMÜTATİFLİK PROPERTY TESTİ (`OrSetProperties.cs`) — ÜRETEÇ PİNLİ [v3'ün BLOKER düzeltmesi].**
Aynı `(element, tag)` üzerine rastgele bir damga çoklu-kümesi; **tüm permütasyonlarda** `MaxStamp()` = `Hlc.CompareTo` altındaki gerçek maksimum.
**ÜRETEÇ PİNİ [PAZARLIKSIZ]:** damgalar **`WallMs` EŞİT, `Counter`/`ClientId` FARKLI** vakaları **zorunlu olarak** üretmelidir. Öneri: `wall` 2-3 değerlik küçük bir havuzdan, `counter ∈ [0,3]`, `clientIdx ∈ [0,2]`.
*Gerekçe (v2'nin kör noktası):* `OrSetProperties.cs`'in mevcut deyimi `private static Hlc H(long wall) => new(wall, 0, Ids.Client(0));` — bununla `WallMs` eşitliği damgaların **tamamen özdeş** olması demektir ve hiçbir ayırt edicilik kalmaz. Bu pin olmadan `add.Hlc.WallMs > existing.WallMs` biçimindeki **yarım-max** uygulaması D2d'den de, D0'dan da, D0b'den de kaçar (§1'in A ve B damgaları farklı `WallMs` taşıyor). Clamp tavanına kırpılan damgalarda `WallMs` eşitliği **sıktır** — yani bu, kusurun yaşadığı bölgenin ta kendisi.
**Kapısı `mutant-7`'dir** (§4); ısırmazsa DUR ve bildir.

**D3 — `SyncStore.UpsertTagAsync` = GREATEST (E-1b) + ISIRAN TEST [TARİF BİREBİR PİNLİ].**
```sql
ON CONFLICT (entity_type, entity_id, set_name, element, add_tag)
DO UPDATE SET hlc = GREATEST(excluded.hlc, sync_orset_tags.hlc)
```
- **Güvenlik teyidi (teknik denetim):** `Hlc.Encode()` = `{WallMs:D13}.{Counter:x8}.{ClientId:N}` sabit genişlikte (`0 <= WallMs < 10^13` değişmezi `HlcKey.cs`'te yazılı, `SyncIngest` negatifi reddediyor, clamp tavanı ~1.78e12) ve **hem `sync_orset_tags.hlc` hem `sync_client_clock.hlc` zaten `.UseCollation("C")`** taşıyor → metin `GREATEST`, `Hlc.CompareTo` ile izomorfiktir. Tombstone-only satırda `hlc` NULL'dır; Postgres `GREATEST` NULL'ı yok sayar → gerçek damga "damgasız"ı yener (istenen).
- `TombstoneTagAsync`'in `cancelled = true` yoluna **DOKUNMA**. (`DO UPDATE`'in `cancelled`'ı güncellememesi bugün güvenlidir — add'ler remove'lardan önce koşuyor — ama asimetriktir; bir yorum satırı ekle.)
- **ISIRAN TESTİN TARİFİ (kelimesi kelimesine — v1'in her iki doğal okuması da kör kapı üretiyordu):**
  1. `Db.ExecuteAsync` ile `sync_orset_tags`'a **YÜKSEK** `hlc`'li satırı ham SQL ile INSERT et.
  2. `SyncTestApp`'e `PersistSetDeltaWithoutHydrationAsync` yardımcısı ekle: **taze** `EntityState` + `GetOrCreateSet(...).ApplyAdd(DÜŞÜK)` + `ISyncStore.PersistDeltaAsync(op, state, ct)`'i **doğrudan** çağır — `LockEntityAsync` YOK, `HydrateAsync` YOK.
  3. **Assert: satırdaki `hlc` HÂLÂ YÜKSEK.**
  *Neden başka türlü olmuyor:* iki yazımı da ham SQL yaparsan `UpsertTagAsync` hiç çalışmaz (kör). Normal `/v1/sync` yolunu kullanırsan `SyncCommandHandler` önce kilit alıp sonra hidratlar → max-join YÜKSEK'i korur → SQL'e `excluded.hlc = YÜKSEK` gider → mutant-4 yine ısırmaz.
  *Bu yardımcı YENİ test altyapısıdır; §7 sapma listesine yaz.*
- **DÜRÜSTLÜK BEYANI [ZORUNLU]:** Bu test **erişilebilir bir üretim yarışını değil, çağıran disiplininden bağımsız DEPOLAMA DEĞİŞMEZİNİ** kapılar — entity advisory kilidi bugün yarışı zaten dışlıyor. `ClientClockGateTests`'in client clock için kurduğu kalıbın birebir aynısı. E-1b bu çerçevede kapıdır. **Somut ısırma gerekçeleri (kodda gerçek):** (i) `PersistSetAsync`'te `TryGetTag` false dönerse geri düşüş ham `add.Hlc`'dir (`SyncStore.cs:116`) — `CompactBelow` tag'i düşürdüğünde tam olarak bu olur; (ii) `TryGetTag` tombstone-only'de `hlc = null` döndürebilir ve eski SQL mevcut damgayı **NULL'a çevirirdi**.
- Isırdığını kanıtlayamıyorsan **DUR ve Cowork'e bildir** — kendi başına "kapı" ilan etme.

**D3b — COLLATION KAPISINI GENİŞLET.**
`SchemaTests` bugün `collation_name = 'C'`'yi **yalnız** `outbox_messages.hlc` için assert ediyor. E-1b'nin doğruluğu `sync_orset_tags.hlc`'nin collation'ına dayanıyor ve bunu hiçbir test tutmuyor.
**PİN [v3]:** mevcut testin gövdesini DÜZENLEME — **YENİ bir `[Fact]`** ekle (`sync_orset_tags.hlc` ve `sync_client_clock.hlc` için `collation_name = 'C'`). *Kabul kriteri 2 "mevcut test değiştirilemez" diyor; v2 "2 satır ekle" derken mevcut `[Fact]`'in gövdesini düzenlemeyi ima ediyordu ve kriterle çelişiyordu.* E-1b'nin temelinin en ucuz kapısı budur.

**D4 — KALICILIK ROUND-TRIP REGRESYONU (Persistence.Tests, Docker).**
*Yaz → hidratla → yeniden uygula* turunda aynı `(element, tag)`'in damgasının **max** kaldığını doğrula.
**Bu D2'nin kapısı DEĞİLDİR** (bkz. D2 dürüstlük beyanı) — kalıcılık zincirinin uçtan uca regresyonudur. Böyle adlandır.

**D5 — PROPERTY-TEST TOHUM POLİTİKASI [mutantsız — dürüstlük beyanı].**
- **Pinli regresyon kümesi:** bilinen kırmızı tohumlar ayrı, sabit `[Fact]`'ler (bugün: `fcGWfMJW_dB2`). Yeni kırmızı tohum bulunursa bu kümeye eklenir.
- **Geniş rastgele koşum:** mevcut P1/P4 rastgele koşumu KALIR; `iter` **düşürülmez**.
- İkisi ayrı testlerdir; rastgele koşum pinli kümenin yerine geçmez.
- **Beyan:** tohum politikası bir **regresyon önlemidir, mutantla korunan kapı DEĞİLDİR** (D9-b kalıbı). Raporda böyle adlandır.

**D6 — `CompactBelow` ↔ `MaxStamp()` BAĞINI PİNLE.**
Teknik denetim kanıtladı: `CompactBelow` `MaxStamp()`'i **bozmuyor**, çünkü `canonical` `belowActive`'in **arg-max**'ıdır (düşürülen her tag'in damgası ≤ canonical). **Ama bu bağ yazısız ve testsiz.** Biri `IsHigher`'ı tag-hex-öncelikli yapsa veya canonical'ı "ilk ufuk-altı tag" seçse `MaxStamp()` sessizce damga düşürür ve C4 **hiçbir test düşmeden** geriler — düzeltmenin kendisi bu bağa bağımlılık yarattığı için kapatılmalı.
- `CompactBelow` doküman-yorumuna: *"canonical MUST be the arg-max of belowActive so MaxStamp() is preserved"*.
- 5 satırlık birim test: compaction öncesi ve sonrası `MaxStamp()` **eşit**.

## 4. MUTANTLAR (6 zorunlu) — `KANIT/slice-2c/`

**KANIT KURALI v2.1 [PAZARLIKSIZ — slice-2b2 BULGU-4'ün düzeltmesi]:**
- **Tüm KANIT koşumları `DOTNET_CLI_UI_LANGUAGE=en` ile koşulur.** *(v1 `Failed: N, Passed: M, Total: T` biçimini dayatıyordu; bu makinede yerel Türkçe olduğu için o satır hiç basılmıyordu — kural kendi kendini ihlal ettiriyordu.)*
- KANIT'a **HAM koşucu çıktısı YAPIŞTIRILIR**: koşucunun kendi özet satırı (`Failed!  - Failed: N, Passed: M, Skipped: K, Total: T, Duration: … - X.dll (net9.0)`) ve **kırılan testlerin koşucudan kopyalanmış tam adları**. Elle listeleme YOK.
- **Hiçbir karakteri değiştirme:** diakritik katlama, boşluk sıkıştırma, sütun hizası bozma **YASAK**. *(2b2'nin KANIT'ları elle ASCII'ye katlanmıştı — "ham yapıştır" kuralı fiilen yeniden-yazımla karşılanmıştı.)*
- Her KANIT: (a) mutasyonun tam diff'i, (b) yukarıdaki ham kırmızı çıktı, (c) `git checkout` sonrası **TAM SUITE** yeşil koşumunun ham özeti (filtreli dar koşum YETMEZ), (d) `--blame-hang-timeout 120s`.

| # | mutant | mutasyon | ısırması ZORUNLU |
|---|--------|----------|------------------|
| 1 | `mutant-1-applyadd-first-wins` | D1 → `Adds.TryAdd` (kusurun kendisi geri) | **D0 + D0b FAIL** |
| 2 | `mutant-2-applyadd-last-wins` | D1 → koşulsuz `Adds[tag] = hlc` | **D0 + D0b FAIL** *(düzeltmenin "tutarlı" olması yetmez, **max** olmalı)* |
| 3 | `mutant-3-loadtag-last-wins` | D2 → koşulsuz `Adds[tag] = stamp` | **D2'nin birim testi FAIL** — *API sözleşmesi kapısı; **üretim yolu kapısı değildir**, raporda böyle adlandır* |
| 4 | `mutant-4-upsert-no-greatest` | D3 SQL → `hlc = excluded.hlc` | **D3'ün ısıran testi FAIL** |
| 5 | `mutant-5-maxstamp-drops-adds` | `MaxStamp()`'ten **Adds** döngüsü kaldırılır | **D2b FAIL + `SemanticRoundTripTests.Tombstone_persists_and_delete_edit_conflict_matches_domain` FAIL** *(D0'ı YEŞİL bırakır — D2b'nin varlık sebebi)* |
| 6 | `mutant-6-maxstamp-drops-removes` | `MaxStamp()`'ten **RemoveStamps** döngüsü kaldırılır | **D2c FAIL** *(D2c olmadan bu mutantın ısırma yüzeyi YOKTUR)* |
| 7 | `mutant-7-applyadd-wallms-only-max` | D1 → `add.Hlc.WallMs > existing.WallMs` (yarım-max) | **D2d FAIL** *(v1'in 5. blokerinin gerçek kapısı; D0/D0b'yi YEŞİL bırakır — D2d'nin varlık sebebi)* |

**Bir mutant ısırmıyorsa testi ZAYIFLATMA — bu testin değil SPEC'in kusurudur, DUR ve bildir.**

**İLK MUTANTTA DİL PİNİNİ DOĞRULA:** `mutant-1`'i koşarken `DOTNET_CLI_UI_LANGUAGE=en` altında beklenen İngilizce özet satırının (`Failed!  - Failed: N, Passed: M, Skipped: K, Total: T, Duration: … - X.dll (net9.0)`) **gerçekten basıldığını GÖR**. Basılmıyorsa **DUR ve bildir** — aksi hâlde 2b2'nin BULGU-4'ü yeni kılıkta geri gelir.

**Maliyet uyarısı:** KANIT kuralı (c) her mutant için TAM SUITE yeşil koşum istiyor; Persistence.Tests tek başına ~1 dk 31 sn (2b2 ölçümü). 7 mutant ≈ 7 tam Docker koşumu + kırmızı koşumlar. Bu maliyet **bilinçli olarak kabul edilmiştir**.

## 5. Kabul kriterleri
1. Build `-warnaserror` **0/0**.
2. **Mevcut 75 test yeşil — İKİ adlandırılmış istisna: (i) `OracleEngine`'in D1b eş-düzeltmesi** (o olmadan P3 zorunlu olarak kırmızıya döner), **(ii) `SchemaTests`'e D3b'nin YENİ `[Fact]`'inin eklenmesi** (mevcut `[Fact]`'lerin gövdesi değişmez). Başka hiçbir mevcut test **değiştirilemez**; yeni testler ayrı sayılır ve raporlanır.
3. **D0'ın KIRMIZI-ÖNCE ham çıktısı** KANIT'ta. Bu olmadan dilim kabul EDİLMEZ.
4. **7 mutant**, KANIT KURALI v2.1'e birebir uygun. Temiz ağaçta kalıntı yok.
5. **Domain değişikliği SINIRLI:** yalnız `OrSetField.cs` (+ `EntityState.cs`'te yorum). Başka Domain dosyası değişirse **DUR ve Cowork'e sor**. Domain dışı zorunlu değişiklikler (Oracle, test altyapısı) **ayrı başlıkta** raporlanır ve kriter 2'nin istisnasıdır.
6. `araclar/verify.ps1` **DEĞİŞMEDEN** geçer (Docker açık), exit 0. *(Dil pini verify.ps1'e DEĞİL, mutant koşum komutlarına konur.)*
7. CVE temiz; sır yok; `PROJE_HAFIZA`/`docs/ADR` **dokunulmamış**; `bin/obj` ignore.
8. **Geriye dönük veri:** `sync_orset_tags`'ta düşük damga taşıyan satır **konuşlanmış hiçbir ortamda yok** varsayımıyla backfill YAPILMAZ. *Dayanak (denetimde tarandı): şemayı Testcontainers dışında yaratan kod yolu yok — `Migrate()` yalnız `tests/Momentum.Persistence.Tests/TestSupport.cs:56`'da; `Program.cs` migrate etmiyor; `appsettings.json`'da bağlantı dizesi yok.* **Tek yanlışlanabilir nokta:** `docker-compose.yml` **kalıcı adlandırılmış volume** tanımlıyor (`momentum-pgdata:/var/lib/postgresql/data`, DB `momentum`) — oraya elle `dotnet ef database update` uygulandıysa varsayım çöker. **Bu volume'de migration koşulduysa DUR ve Cowork'e sor** — kayıp damga kendiliğinden geri gelmez (GREATEST ancak o tag'e yeni add gelirse yükseltir).

## 6. Kırmızı çizgiler
Sır repoya girmez · **yeni bağımlılık YOK** · **`CsCheck` sürümü (`4.7.0`) regresyon-kritik pindir; bu dilimde yükseltilmez** (tohum vakası üreteç+sürüm fonksiyonudur) · `DateTime.UtcNow` üretimde yasak · SQL `now()` yasak · **SQL'de LWW/CRDT implementasyonu yasak — TEK istisna E-1b'nin GREATEST'idir ve ısırdığı kanıtlanmak zorundadır** · hiçbir outbox satırı kalıcı iskartaya çıkarılmaz · **add-wins üyelik semantiği değişmez** · **testi mutanta uydurmak için zayıflatmak yasak** · **Oracle üretim kodundan kopyalanmaz** (bağımsızlığı onun tek değeri).

## 7. Teslim protokolü
1. `araclar/verify.ps1` (Docker açık) — TÜM çıktı rapora.
2. Commit (ASCII): `fix(sync): orset add stamp max-join (ADR 0002 errata E-1/E-1b) + convergence regression gates`. **Push YAPMA** (Cowork).
3. Rapor: (a) test sayıları (75 + yeni ayrımı), (b) **D0 ayrı başlık: kırmızı-önce + yeşil-sonra ham çıktı**, (c) verify exit, (d) 7 mutant KANIT yolu + koşucudan kopyalanmış kırılan-test listeleri, (e) **Domain diff kapsamı + Domain dışı zorunlu değişiklikler ayrı başlık**, (f) sapma/varsayım TAM listesi (yeni test yardımcısı dâhil), (g) **D3'ün ısıran testinin gerçekten ısırdığının kanıtı** (ısıramadıysa AÇIKÇA bildir), (h) **D2'nin "API sözleşmesi kapısı, üretim yolu kapısı değil" beyanı**, (i) D5'in "mutantsız regresyon önlemi" beyanı.

> Cowork beyanına güvenmez: D0/D0b'yi, D2b/D2c'yi, D2d'yi, D3'ün ayırt edici testini ve **7 mutantı** **kendi koşusuyla** doğrulayacak; özellikle **mutant-5'in D0'ı yeşil bırakıp D2b'yi kırdığını**, **mutant-6'nın D2c'yi kırdığını** ve **mutant-7'nin (yarım-max) D0/D0b'yi yeşil bırakıp D2d'yi kırdığını** kendi eliyle görecek — bu üçü, düzeltmenin sessizce semantik gerilemeye ya da yarım-max'a çürümediğinin tek kanıtıdır.
