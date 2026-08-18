# İŞ EMRİ o83-G — c AYAĞI POZİTİF KONTROL + TEST KELEPÇESİ + `verify.ps1`

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, 18 Ağu 2026] · Önceki: `IS-EMRI-o83-F` **KABUL** (bağımsız denetimden geçti)

---

## 0. DEMİR KURALLAR

1. 🔴 **ÜRÜN KODUNA DOKUNULMAZ.** Bu emirde değişecek dosyalar: `KANIT/o83/_canli_tur.py` (ölçüm
   betiği) ve `tests/…/PullCursorOrderTests.cs` (tek satır). Backend/istemci ürün kodu: **HAYIR.**
2. 🔴 **§B kırmızı yanarsa DUR.** Teşhis sorgularını koş, yaz, emri geri ver. Ürün kodunu kendi
   başına düzeltme — bu bir ölçüm emridir, düzeltme emri değil.
3. **PUSH YOK.** Commit serbest (yol belirterek, çift tırnaksız mesaj).
4. `docker compose down` serbest; **`-v` YASAK** (birim silinir, geri alınamaz).

---

## 1. NEREDEYİZ

Kimlik dilimi kabul maddesi: *"§3.4(b) ve §3.4(c) canlıda ölçüldü: **iki hesap birbirinin görevini
görmüyor**"*. Bugünkü kanıt (`KANIT/o83/08-canli-tur.txt`) bunu **kanıtlamıyor**:

```
=== b) GET /v1/tasks (Bearer B) ===   A'nin gorevini icerir mi: False   {"items":[],...}
=== c) GET /v1/tasks (Bearer A) ===   B'nin gorevini icerir mi: False   {"items":[],...}
```

**İki liste de BOŞ.** Boş listede "ötekini görmüyor" **bedava** doğrudur — betiğin tek kontrolü
`x_entity_id in gov` olduğu için ayak yeşil yandı. Üstelik daha ağırı: **A kendi görevini de
görmüyor**, oysa aynı görev A'nın `/v1/sync` yanıtında `Applied` ve snapshot'ta duruyor.

> 🔴 **KURAL (bu emrin özü): NEGATİF KONTROL, POZİTİF KONTROL YEŞİL OLMADAN ANLAMSIZDIR.**
> "B, A'nınkini görmüyor" cümlesi ancak "B kendi görevini görüyor" ölçüldükten sonra bilgi taşır.

---

## 2. §A — `_canli_tur.py` DÜZELTMESİ (ölçüm betiği)

`KANIT/o83/_canli_tur.py`:

1. **Taze kimlikler.** `entity_id` ve `b_entity_id` her koşumda **yeni** üretilir (e-posta gibi).
   Sabit `1111…`/`4444…`/`7777…` **kullanılmaz** — kalıcı Postgres cildinde önceki koşumun
   sahipliğiyle çakışıyor olabilir.
2. **Pozitif kontroller** (her biri ayrı ayrı yazılır ve özete girer):
   - `a_kendi_gorur` = A'nın kendi `entity_id`si A'nın `/v1/tasks` listesinde → **True olmalı**
   - `b_kendi_gorur` = B'nin kendi `b_entity_id`si B'nin listesinde → **True olmalı**
3. **Negatif kontroller, POZİTİFTEN SONRA değerlendirilir:**
   - `b_gorur_a_yi` → **False olmalı** · `a_gorur_b_yi` → **False olmalı**
   - İlgili pozitif kontrol düşmüşse negatif sonuç **"ÖLÇÜLEMEDİ"** yazılır, "False" diye
     yeşil YAZILMAZ.
4. **Boş liste kalkanı:** ilgili `GET /v1/tasks` yanıtı `items: []` iken ayak **asla geçmez**.
5. **Okuma modeli gecikmeli olabilir — ölç, varsayma.** Pozitif kontrol en fazla **10 deneme ×
   300 ms** boyunca yeniden sorgulanır; **kaçıncı denemede tuttuğu yazılır**
   (`a_kendi_gorur: True (deneme 1/10)`). 1'de tutuyorsa yazım **eşzamanlı**dır; sonra tutuyorsa
   okuma modeli **nihai tutarlı**dır ve bu bilgi DURUM.md'ye sınır olarak girer. Negatif kontrolde
   **bekleme YOK** (tek sorgu — beklemek yanlış negatifi gizler).
6. **Ayak düşerse `SystemExit`** — sessizce geçmez, özet satırı `BEKLENEN/GERÇEK` yazar.

Betiğin başka hiçbir ayağı (a, d.1, d.2, d.3, e) değiştirilmez.

## 3. §B — CANLI TUR (ölçüm)

Yığın ayağa kaldırılır (mevcut `docker compose` yolu; **`-v` yok**), düzeltilmiş betik koşulur.
Ham çıktı → **`KANIT/o83G/01-canli-tur.txt`**. Çıktının başına şu üçü yazılır:
kullanılan taze `entity_id`ler · `SELECT pg_snapshot_xmin(pg_current_snapshot())::text` · yığının
taze mi yoksa eski cilt mi olduğu.

### 3.1 YEŞİLSE
Dört kontrol de beklendiği gibiyse (`a_kendi_gorur`=True · `b_kendi_gorur`=True ·
`a_gorur_b_yi`=False · `b_gorur_a_yi`=False) c ayağı **kapandı**, §C'ye geç.

### 3.2 KIRMIZIYSA — DUR, ama tek turda teşhis et

Ürün koduna **dokunma**. Şu dört sorgu aynı veritabanında koşulur, ham çıktı →
**`KANIT/o83G/02-teshis.txt`**, sonra **DUR ve bildir**:

```sql
-- A'nin userId'si = <a_user_id>, A'nin entity'si = <entity_id>
-- 1) Okuma modelinde satir var mi, sahibi kim?
SELECT entity_id, owner_id, title, is_deleted FROM tasks WHERE entity_id = '<entity_id>';
-- 2) A'nin sahipligindeki toplam satir
SELECT count(*) AS a_nin_satirlari FROM tasks WHERE owner_id = '<a_user_id>';
-- 3) Outbox'a yazildi mi, sahibi kim, gonderildi mi?
SELECT commit_xid::text, server_seq, owner_id, aggregate_type, signaled_at
  FROM outbox_messages WHERE aggregate_id = '<entity_id>' ORDER BY server_seq;
-- 4) Sahiplik uyusuyor mu?
SELECT '<a_user_id>'::uuid = (SELECT owner_id FROM tasks WHERE entity_id = '<entity_id>') AS sahip_ayni;
```

Bu dört cevap teşhisi tek turda ayırır: **(1) boşsa** materyalizasyon hiç olmamıştır ·
**(1) doluysa ama `owner_id` A değilse** sahiplik yanlış atanmıştır · **(3) boşsa** yazım
outbox'a hiç düşmemiştir · **(3) doluysa ama (1) boşsa** yazım ile okuma modeli arasında kopukluk
vardır. Yorum yapma, dört cevabı yaz.

## 4. §C — TEST KELEPÇESİ (tek satır)

`tests/Momentum.Persistence.Tests/PullCursorOrderTests.cs`, Test 2:

```csharp
var before = (long)(b / 10);              // ESKI
var before = (long)Math.Min(b / 10, 100); // YENI
```

**Neden (Cowork ölçtü, o83-F denetimi):** `b` ufkun altındaki en büyük 10 kuvveti olduğu için
yazılan satır sayısı ortamın xid sayacıyla büyüyor — X=752'de 510 satır, X=12.000.000 olsaydı
**1.000.500** satır. Bugün zararsız (her koşum taze konteyner), ama testin varlık sebebi
bağlamdan bağımsız olmaktı. Kelepçe alt bloğun **"hepsi 9 ile başlar"** değişmezini bozmaz:
`B≥1000` için `B-100 … B-1` zaten 9'lu onluktadır, `B=100` için `min(10,100)=10` değişmez.

Kelepçeden sonra **iki test yeniden koşulur, ikisi de yeşil kalmalı** →
`KANIT/o83G/03-kelepce-sonrasi.txt` (ölçülen X ve B satırı çıktıda görünmeli).

## 5. §D — `verify.ps1` (yalnız §B yeşilse)

Backend kapatılır (`docker compose down`, **`-v` YOK**; `netstat -ano | findstr :5298` **boş**
dönmeli), `verify.ps1` koşulur, **çıkış kodu birebir** yazılır →
`KANIT/o83G/04-verify-ps1.txt`. EXIT 0 değilse **düşen adımı yaz ve DUR** — bu emirde onu
kovalama.

---

## 6. CEVAP — `KANIT/o83G/00-CEVAP.md`, altı satır

1. Taze `entity_id`ler, ölçülen `pg_snapshot_xmin`, yığın taze mi eski cilt mi.
2. `a_kendi_gorur` / `b_kendi_gorur` — **kaçıncı denemede** tuttu (ya da düştü).
3. `a_gorur_b_yi` / `b_gorur_a_yi` — False mı, yoksa **ÖLÇÜLEMEDİ** mi.
4. §C kelepçesinden sonra iki testin outcome'u + çıktıdaki X ve B.
5. `verify.ps1` çıkış kodu (koşulduysa); koşulmadıysa sebebi.
6. `git --no-optional-locks status --porcelain -- src tests` çıktısı — **`src` altı BOŞ olmalı.**

## 7. KABUL

- [ ] `KANIT/o83G/01-canli-tur.txt` var; dört kontrolün dördü de **açıkça** yazılı
- [ ] Hiçbir ayak **boş liste** üstünden geçmedi
- [ ] (kırmızıysa) `KANIT/o83G/02-teshis.txt` dört sorgunun ham çıktısıyla var ve **DURULDU**
- [ ] `KANIT/o83G/03-kelepce-sonrasi.txt` — iki test yeşil
- [ ] (yeşilse) `KANIT/o83G/04-verify-ps1.txt` — çıkış kodu birebir
- [ ] Ürün kodu **değişmedi** (`status --porcelain -- src` boş)
- [ ] Commit yol belirterek atıldı, **push YOK**, `KANIT/slice-3c/02-G2/*.json` girmedi (mayın 19)

## 8. DOKUNMA LİSTESİ

- ❌ Backend/istemci ürün kodu · migration · şema · `SyncPuller.cs` (o83-F'te kapandı)
- ❌ `docker compose down -v` · `docker volume rm` · veritabanı silme
- ❌ DURUM.md · README · `arsiv/` · yeni ADR/spec/kapı dosyası
- ❌ `verify.ps1` içeriğini değiştirmek (yalnız koşulur)
- ❌ Kırmızıyı "düzeltmek" için ikinci tur açmak — DUR ve bildir
