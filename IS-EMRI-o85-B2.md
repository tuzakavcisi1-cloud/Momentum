# İŞ EMRİ o85-B2 — o85-B denetim kapanışı: kapısız keyset kolu + yalan söyleyen D6 çıpası

`MOD: NORMAL` · kutu **20-21 Ağu 2026** · yazan: **Cowork (bağımsız denetçi)** · koşacak: **Claude Code**
Öncül: `c50796f` (o85-B) — **PUSH EDİLMEDİ**, `origin/main` = `b425d94`. Denetim turu **KABUL ETMEDİ**;
iki bulgu. Bu emir **yalnız o iki bulguyu** kapatır, başka hiçbir şeye dokunmaz.

---

## 0. DEMİR KURALLAR

1. 🔴 **ÜRÜN KODU DEĞİŞMEZ — bu emir TEST-ONLY.** Kapanışta
   `git --no-optional-locks diff --stat c50796f -- src` çıktısı **BOŞ** olmalıdır. Bulguların ikisi de
   "kod doğru, kapı yok" sınıfıdır; `src/**`e dokunma dürtüsü olursa **DUR ve bildir**.
2. 🔴 **Yeni kapı DOSYASI açılmaz** (DURUM sınır 3). Düzeltmeler **iki mevcut dosyaya** girer:
   `tests/Momentum.Persistence.Tests/TaskMaterializationD0Tests.cs` ve
   `tests/Momentum.Persistence.Tests/ScopeAndDriftAnchorTests.cs`.
3. 🔴 **ADR/spec YAZILMAZ** (İŞLEYİŞ md.4). Tasarım bu emirdedir.
4. Mutantlar **uygulanır, ham çıktısı alınır, GERİ ALINIR**. Kapanışta ürün kodu bayt-özdeş (kural 1).
5. `c50796f` **amend EDİLMEZ** — üstüne **ayrı commit** (denetim izi korunur, o85-A→A2 emsali).
6. `verify.ps1` · `DURUM.md` · `CLAUDE.md` · `arsiv/` · `.github/workflows/*` · `src/client/**`:
   **dokunma**. **PUSH ONUR'DA.**

---

## 1. NEREDEYİZ (Cowork ölçtü, 20 Ağu — kaynak dosyalardan, builder beyanından değil)

- `TaskReadStore.ListProjectsAsync` yüklemi üç kollu: ① imleçsiz ② `cursorPos IS NOT NULL` →
  `(pos, entity_id) > (…) OR pos IS NULL` ③ **`cursorPos IS NULL` → `pos IS NULL AND entity_id > @cursorId`**.
  SQL, `ListTaskListsAsync`in birebir kopyası ve **doğru yazılmış**.
- **③ hiçbir testte ısırmıyor.** `Project_read_endpoint_owner_filter_soft_delete_and_keyset_pagination`
  testinde pos'suz proje **tek** (`projectEntity`); `limit=2` ile sayfa 2 iki satır dönüp
  `nextCursor=null` ile bitiyor, imleç null bölmesine **hiç düşmüyor**.
- 🔴 **Bu, üründe TEK gerçek yol:** istemci `pos` yazmıyor (o85-B §2 + DURUM kilidi "listPos/order
  AÇILMADI") ⇒ bugün **her `projects` satırının `pos`'u NULL** ⇒ tüm liste null bölmesinde.
  50 satırı aşan hesapta `GET /v1/projects`in ikinci sayfası **yalnızca ③'e** bağlı.
- Emsal zaten kapatıyor: **aynı dosyadaki `/v1/tasks` keyset testi** 3 pos'lu + 3 pos'suz kurar ve
  null bölmesinin sırasını `Guid.CreateVersion7(FromUnixTimeMilliseconds(Wire.BaseWall + i))` ile
  bilerek sabitler; gerekçesi test içindeki yorumda yazılı. Yeni test "birebir desen" iddiasıyla
  yazıldı ama **emsalden zayıf**.
- `ScopeAndDriftAnchorTests.D6_out_of_scope_entity_types_produce_zero_new_rows` (satır ~17-35):
  bir `Project` op'u + bir `Tag` op'u iter, `tasks`/`task_lists`/`task_tags` **0** doğrular.
  Docstring: *"Project/Tag ops are out-of-scope — zero new rows in all three materialized tables."*
  `Project` **artık kapsam içinde** ve `projects`e satır yazıyor; test **yeşil kalıyor** çünkü yeni
  tabloyu saymıyor. o85-B `EntityMaterializer`daki D6 **yorumunu** güncelledi, **çıpanın kendisini**
  güncellemedi ⇒ adı ve beyanı yanlış olan bir kapı kaldı.

---

## 2. §A — BULGU 1: üçüncü keyset kolunu kapıya bağla

**A1. 🔴 İLK İŞ — ÖLÇ (test yazmadan ÖNCE).** Mutant **M3a**'yı uygula: `ListProjectsAsync`
yüklemindeki `OR (@cursorPos::text IS NULL AND (pos IS NULL AND entity_id > @cursorId::uuid))`
satırını **tamamen sil**. `dotnet test tests/Momentum.Persistence.Tests` koş.
**Beklenen: YEŞİL** — kapının bugün var olmadığının kanıtı budur. Ham çıktı
`KANIT/o85B2/01-mutant-M3a-KAPISIZ-yesil.txt`. Sonra mutantı **geri al**.
Mutant beklenmedik şekilde kırmızı çıkarsa: **DUR ve bildir** (denetim yanılmış olur, ham çıktıyla).

**A2.** `Project_read_endpoint_owner_filter_soft_delete_and_keyset_pagination` testini genişlet —
null bölmesi **tek satırdan üç satıra** çıkar:

- `projectEntity` dâhil **bütün pos'suz** projeler tek bir monoton seriden üretilir:
  `Guid.CreateVersion7(DateTimeOffset.FromUnixTimeMilliseconds(Wire.BaseWall + i))`, `i = 0,1,2`.
  🔴 **`Guid.NewGuid()` (v4) ile karıştırma** — rastgele v4, Postgres bayt sırasında monoton v7'lerin
  arasına düşer ve beklenen sırayı belirsizleştirir. Emsaldeki gerekçe yorumu (aynı dosya,
  `/v1/tasks` testi) **birebir buraya da yazılır**.
- Sıralı üç pos'lu proje (`p1`/`p2`/`p3`) aynen kalır. `deletedEntity` aynen kalır (varsayılan
  listeye girmez, sırayı etkilemez).
- `limit=2` ile sayfalama: `expectedOrder` = `[p1, p2, p3]` + pos'suz üçlü **üretim sırasıyla**.
  `collected.Count` = **6** · `collected.Distinct().Count()` = **6** · `collected.ShouldBe(expectedOrder)`.
- Böylece imleç **null bölmesinin İÇİNE** düşer (sayfa 2 pos'suz bir satırda biter) ⇒ ③ ısırır.

**A3.** Mutantları **tekrar uygula, kırmızıyı ham çıktıyla göster, geri al**:
- **M3a** (③'ü sil) → `KANIT/o85B2/02-mutant-M3a-KIRMIZI.txt`
- **M3b** (③'te `entity_id > @cursorId` → `entity_id >= @cursorId`) → `03-mutant-M3b-KIRMIZI.txt`
  (beklenen ısırık: tekrar eden satır ⇒ `Distinct` veya sıra assert'i düşer)

---

## 3. §B — BULGU 2: D6 çıpasını doğru söyleyen ve ısıran hâle getir

**B1. ÖLÇ (dar yol, mount 45 sn tavanı var):** `D6_out_of_scope` dizgesi `.github/`, `araclar/`,
`verify.ps1` içinde geçiyor mu? **Geçiyorsa test ADI DEĞİŞMEZ**, yalnız docstring + assert güncellenir.
Geçmiyorsa ad da düzeltilir: `D6_Tag_kapsam_disi_sifir_satir_Project_ise_materyalize_edilir`.

**B2.** Docstring gerçeğe çekilir: *"D6 [kapsam çıpası]: `Tag` kapsam dışıdır — üç eski materyalize
tabloda sıfır satır. `Project` IS-EMRI-o85-B ile kapsama GİRDİ: `projects` tablosuna tam bir satır
yazar (pozitif kontrol)."*

**B3.** Test iki `Guid.NewGuid()` çağrısını **değişkene alır** (`projectEntity`, `tagEntity`) ve
mevcut üç sıfır assert'inin yanına **pozitif kontrol** eklenir:
- `SELECT count(*) FROM projects WHERE entity_id = @project` = **1** (Project materyalize edildi)
- `SELECT count(*) FROM projects` = **1** (Tag op'u `projects`e satır **DOĞURMADI** — "görünmemeli"
  iddiası da ölçülür)

**B4.** Çıpanın gerçekten ısırdığı **mutantla** gösterilir: `EntityMaterializer`daki
`case "Project": await MaterializeProjectAsync(...)` dalını `case "Project": break;` yap →
test **KIRMIZI** olmalı. Ham çıktı `KANIT/o85B2/04-mutant-D6-KIRMIZI.txt`, sonra **geri al**
(ürün kodu bayt-özdeş kalır — §0/1).

---

## 4. §C — KANIT

`KANIT/o85B2/` altında:

- `00-CEVAP.md` (dört satır, §5)
- `01-mutant-M3a-KAPISIZ-yesil.txt` — A1'in ham çıktısı (**test yazmadan ÖNCE alınmış**)
- `02-mutant-M3a-KIRMIZI.txt` · `03-mutant-M3b-KIRMIZI.txt`
- `04-mutant-D6-KIRMIZI.txt`
- `05-verify-ps1.txt` — EXIT 0 özeti
- `06-src-bayt-ozdes.txt` — `git --no-optional-locks diff --stat c50796f -- src` çıktısı (**BOŞ**)

---

## 5. CEVAP — `KANIT/o85B2/00-CEVAP.md`, dört satır

1. **M3a ÖNCE yeşil / SONRA kırmızı** (kapının yokken var edildiğinin kanıtı) + M3b kırmızısı;
   yeni `expectedOrder`ın null bölmesindeki sırası ve neden deterministik olduğu.
2. D6 çıpasının yeni docstring'i + adı (değişti mi, B1 ölçümü ne dedi) + `case "Project": break;`
   mutantında kırmızıya döndüğü.
3. `git --no-optional-locks diff --stat c50796f -- src` çıktısı — **BOŞ** (ürün kodu bayt-özdeş).
4. `verify.ps1` EXIT + test sayısı: **144 → 144 beklenir** (yeni `[Fact]` yok, mevcut ikisi genişledi).
   Sayı değiştiyse **neden** değiştiği tek cümleyle.

---

## 6. KABUL

- [ ] M3a'nın **önce yeşil** ham çıktısı var (kapı yoktu, ispatlandı)
- [ ] M3a ve M3b **kırmızı** ham çıktılarıyla düştü; ikisi de geri alındı
- [ ] Null bölmesinde **üç** pos'suz proje var, hepsi monoton-ms UUIDv7; `Guid.NewGuid()` karışmadı
- [ ] `collected` = 6 · `Distinct` = 6 · sıra birebir `expectedOrder`
- [ ] D6 çıpası `projects` = 1 pozitif kontrolünü içeriyor ve `case "Project": break;` mutantında **öldü**
- [ ] D6 docstring'i artık doğru; ad B1 ölçümüne göre ya değişti ya bilerek korundu
- [ ] 🔴 `git diff --stat c50796f -- src` **BOŞ** — ürün kodu bayt-özdeş
- [ ] `verify.ps1` EXIT 0 · yeni kapı dosyası açılmadı · `src/client/**` görünmüyor
- [ ] Tek commit (amend YOK), yol belirterek, **çift tırnaksız** mesaj, author `onurkesimbjk@gmail.com`
- [ ] 🔴 **PUSH YOK** · kanıt dosyası kendi commit'inin hash'ini yazmaz
- [ ] `KANIT/slice-3c/02-G2/*.json` commit'e **girmedi** (mayın 19 — `git add` yol belirterek)

---

## 7. DOKUNMA LİSTESİ

- ❌ `src/**` (mutantlar hariç — hepsi geri alınır) · `src/client/**` · `FieldStrategyRegistry` · migration'lar
- ❌ Yeni test/kapı **dosyası** açmak · `members` / `project_members` (DİLİM 3)
- ❌ `verify.ps1` · `DURUM.md` · `CLAUDE.md` · `arsiv/` · `.github/workflows/*`
- ❌ `c50796f`i amend etmek · **PUSH** — sıradaki adım Onur'un
