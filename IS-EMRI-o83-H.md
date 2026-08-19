# İŞ EMRİ o83-H — KANIT KAYDI + İKİ TEMİZLİK (ürün koduna dokunulmaz)

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, 18 Ağu 2026] · Öncesi: `o83-F` ve `o83-G` bağımsız denetimden **KABUL** aldı

---

## 0. DEMİR KURALLAR

1. 🔴 **`src/` DEĞİŞMEZ.** Bu emirde değişecek tek kaynak dosya: `KANIT/o83/_canli_tur.py`.
2. 🔴 **PUSH YOK.** Push bu emirden **sonraki** adımdır ve Onur'undur. Kapı beyanı o zaman yazılır.
3. **Tek commit**, yol belirterek. `git add -A` **YASAK**.
4. `docker compose down` serbest; **`-v` YASAK**.

---

## 1. NEREDEYİZ (Cowork ölçtü, 18 Ağu)

- HEAD `09e2720` · `origin/main` `735f1e5` · **9 commit push edilmemiş**.
- 🔴 **`KANIT/o83E` ve `KANIT/o84` hiç commit'lenmemiş** (`git log -- <yol>` boş döndü). DURUM.md
  sınır 31 ve `IS-EMRI-o83-F` bu iki klasöre **atıf yapıyor** ⇒ kapandı ilan edilen kusurun
  dayanağı yalnız diskte duruyor.
- 🔴 **`KANIT/o83/08-canli-tur.txt` üzerine yazıldı**: o83-G koşumunun yeşil çıktısını taşıyor
  (5.863 bayt, içinde `kendi gorevini goruyor` satırları var). o83'ün **kırmızı** kaydı yalnız
  git geçmişinde (`8110133`). o83 etiketli dosyada yeşil gören biri yanlış sonuç çıkarır — bu
  sınır 30'un ("kapı beyanı commit ile birlikte yazılır") aynı sınıfı.
- **`b_gorur_a_yi`, `b_kendi_gorur`dan ÖNCE ölçülüyor** ⇒ o anda B'nin listesi `items:[]`.
  Vakıf değil (A'nınki materyalize olduğu kanıtlı) ama `a_gorur_b_yi` kadar güçlü değil.

---

## 2. §A — BETİK DÜZELTMESİ (`KANIT/o83/_canli_tur.py`)

**A1 — çıktı yolu zorunlu argüman.** Çıktı dosyası artık `sys.argv[1]`den alınır; **varsayılan yol
KALMAZ**. Argümansız çağrılırsa `SystemExit` ile *"çıktı yolu zorunlu argümandır"* der ve hiçbir
şey yazmaz. Sebep: bir o83-G/H koşumu bir daha **o83'ün klasörüne yazamasın**.

**A2 — negatif kontrol sırası.** `b_gorur_a_yi` ölçümü `b_kendi_gorur`dan **SONRAYA** alınır.
Yeni sıra: B kaydolur → B kendi görevini ekler → `b_kendi_gorur` (pozitif, denemeli) →
`b_gorur_a_yi` (negatif, tek sorgu) → `a_gorur_b_yi` (negatif, tek sorgu). Böylece **her iki
negatif de dolu liste üstünde** ölçülür.

**A3 — boş liste kalkanı negatiflere de.** Negatif kontrol anında ilgili kullanıcının listesi
`items:[]` ise ayak **geçmez**: `SystemExit` ile *"ÖLÇÜLEMEDİ (liste boş) — negatif kontrol
anlamsız"* der. Boş listede "görmüyor" bedava doğrudur; bu emrin varlık sebebi odur.

Betiğin başka hiçbir ayağı (a, d.1, d.2, d.3, e) değişmez.

## 3. §B — o83'ÜN KIRMIZI KAYDINI GERİ AL

```
git show 8110133:KANIT/o83/08-canli-tur.txt   →   KANIT/o83/08-canli-tur.txt
```

Dosyaya **not/uyarı satırı eklenmez** — kanıt birebir kalır. İki doğrulama koşulur, ikisi de
CEVAP'a yazılır:

- dosyada `kendi gorevini goruyor` dizesi **GEÇMEZ** (yani o83-G çıktısı değil)
- dosyada `01a01401-49dc` (o83'ün A kullanıcısı) **GEÇER** ve `{"items":[]` **iki kez** bulunur

## 4. §C — YENİDEN KOŞUM (§A'yı kanıtlar)

Yığın ayağa kaldırılır (`docker compose up -d`, **`-v` YOK**), betik **açık argümanla** koşulur:

```
python KANIT/o83/_canli_tur.py KANIT/o83H/01-canli-tur.txt
```

Çıktıda görünmesi gerekenler:

- dört kontrolün dördü (`a_kendi_gorur` · `b_kendi_gorur` · `b_gorur_a_yi` · `a_gorur_b_yi`)
- **her iki negatifin de ölçüldüğü anda ilgili listenin DOLU olduğu** (ham JSON'da görünür)
- pozitiflerin kaçıncı denemede tuttuğu

Ayrıca koşumdan **sonra** §B'nin bozulmadığı yeniden doğrulanır (`08-canli-tur.txt` hâlâ kırmızı
kaydı taşıyor mu) — A1 işe yaradıysa taşıyor olmalı.

**Kırmızı yanarsa:** `IS-EMRI-o83-G` §3.2'deki dört teşhis sorgusu koşulur →
`KANIT/o83H/02-teshis.txt` → **DUR ve bildir.** Ürün kodunu düzeltme.

## 5. §D — TEK COMMIT (push yok)

Yol belirterek eklenecekler:

- `KANIT/o83E/` · `KANIT/o84/` (ikisi de takipsiz — bu emrin asıl sebebi)
- `KANIT/o83/08-canli-tur.txt` (geri alınmış) · `KANIT/o83/_canli_tur.py` (düzeltilmiş)
- `KANIT/o83H/` · `DURUM.md` (Cowork güncelledi, 8.178 bayt) · `IS-EMRI-o83-H.md`

**Girmeyecekler:** `KANIT/slice-3c/02-G2/*.json` (mayın 19) · `*.trx` (ignore'lu) ·
`KANIT/o83/__pycache__/` (varsa `.gitignore`a bir satır eklenebilir — tek satır, başka düzenleme yok).

Mesajda **çift tırnak yok**; author `onurkesimbjk@gmail.com`. 🔴 **PUSH YOK.**

---

## 6. CEVAP — `KANIT/o83H/00-CEVAP.md`, beş satır

1. §B iki doğrulaması: dize **yok** mu, eski userId **var** mı, `{"items":[]` kaç kez.
2. §C dört kontrol + **her negatifin ölçüldüğü anda listenin dolu olduğu** (tek cümle kanıt).
3. Betik **argümansız** çağrılınca ne oldu (çıktının tek satırı).
4. Commit'e giren dosya listesi (`git show --stat --oneline -1`).
5. `git --no-optional-locks status --porcelain -- src` — **BOŞ olmalı.**

## 7. KABUL

- [ ] `KANIT/o83E` ve `KANIT/o84` artık **takipli** (`git log -- <yol>` bu commit'i döndürüyor)
- [ ] `KANIT/o83/08-canli-tur.txt` o83'ün **kırmızı** kaydını taşıyor (iki doğrulama tuttu)
- [ ] `KANIT/o83H/01-canli-tur.txt` var; **iki negatif de dolu liste üstünde** ölçülmüş
- [ ] Betik argümansız çalışmıyor (kanıt CEVAP'ta)
- [ ] `status --porcelain -- src` **boş** · tek commit · **push yok**

## 8. DOKUNMA LİSTESİ

- ❌ `src/` altındaki her şey · migration · şema · testler · `verify.ps1`
- ❌ `docker compose down -v` · `docker volume rm` · veritabanı silme
- ❌ `README.md` · `CLAUDE.md` · `arsiv/` · yeni ADR/spec/kapı dosyası
- ❌ `08-canli-tur.txt`e açıklama satırı eklemek (kanıt birebir kalır)
- ❌ **PUSH** — sıradaki adım Onur'un
