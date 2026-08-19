# İŞ EMRİ o83-I — `paket` AYAK 1 BAYAT KAPI: dize kontrolü düşer, kimlik ayağı gelir

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, **19 Ağu 2026**] · Karar: **kapı ürünü izler**

---

## 0. DEMİR KURALLAR

1. 🔴 **Bu bir KAPI düzeltmesidir.** Ürün *davranışı* değişmez. Tek ürün dosyası dokunuşu §B'deki
   **ölü sabitin** silinmesidir — hiçbir yerden okunmadığı ölçüldü, davranışsızdır.
2. 🔴 **Yeni kapı DİZE aramaz.** Eklenen ayak **ÜRÜN UCUNA** konuşur (HTTP kodu + JSON alan varlığı).
   Bu kapı bir kez zaten dize yüzünden kör yandı (o80), bir kez de dize yüzünden bayat kaldı (bugün).
3. 🔴 **Bu emirde kapı KOŞMAZ.** `paket` yalnız push'ta tetikleniyor, push Onur'da. Yeşil kanıtı
   push sonrası ayrı adımda okunur. **PUSH YOK.**
4. `.github/workflows/*`: mayın 7 — `device_commit_files` reddeder ama Claude Code kendi ortamında
   doğrudan yazar; yazdıktan sonra dosyanın **gerçekten indiğini** doğrula (o80 dersi: yazılmış
   olması indiği anlamına gelmez).
5. `verify.ps1` · `DURUM.md` · `README.md` · testler: **dokunma**.

---

## 1. NEREDEYİZ (Cowork ölçtü, 19 Ağu — cihaz Chrome + git)

Kapı beyanı, commit ile birlikte: `ci #72` = `c5b2d7f` **YEŞİL** · `pages #11` = `c5b2d7f`
**YEŞİL** · `paket #10` = `c5b2d7f` **KIRMIZI**.

Düşen ayak **AYAK 1**, düşen tek satır `paket.yml:114`:

```
main.dart.js: 3437468 bayt
KIRMIZI: DEV_USER_ID derlemeye GIRMEMIS -- iki istemci ayni kullanici olmaz
```

Üç ölçüm sebebi ayrıştırdı:

1. `docker-compose.yml` · `Dockerfile` · `paket.yml` **`a332b25`'ten beri değişmedi** ⇒ kapının
   yakalamak için yazıldığı senaryo (build-arg adı yanlış) **değil**; o boru hattı paket #9'da yeşildi.
2. O tarihten beri `src/client/lib/main.dart`'a dokunan **tek commit `838426a`** (kimlik dilimi).
3. `devUserIdEzmesi` istemcide **bir kez tanımlı, hiç okunmuyor** (kullanım sayısı 1 = tanımın
   kendisi). `main.dart:253-254` zaten yazmış: *"ezme ARTIK derleme-zamanı `DEV_USER_ID` DEĞİL,
   giriş yapan kullanıcının GERÇEK kimliği"*. Kullanılmayan sabiti dart2js buduyor ⇒ dize çıktıda yok.

⇒ **Kapı, kimlik diliminin bilerek emekliye ayırdığı bir değişmezi arıyor.** Ürün doğru, kapı bayat.

---

## 2. §A — AYAK 1'den dize kontrolünü çıkar

`.github/workflows/paket.yml`, AYAK 1 içindeki **`DEV_USER_ID` bloğu** (açıklama yorumu +
`grep -q 'deadbeef-…'` satırı, ~109-115) **SİLİNİR**.

AYAK 1'in geri kalanı **aynen kalır**: `main.dart.js` iniyor mu · `> 100000` bayt mı · aynı köken ·
CDN kapalı. Adımın sonundaki `YESIL: …` satırı **artık doğrulamadığı şeyi iddia etmeyecek** şekilde
güncellenir ("demo kimliği" ibaresi çıkar). Adım adı değişmez.

## 3. §B — ölü sabiti sil (davranışsız)

`src/client/lib/main.dart:41`:
`const String devUserIdEzmesi = String.fromEnvironment('DEV_USER_ID');` **silinir**; onu anlatan
yorum bloğu (≈34-40) tek satıra indirilir ya da silinir.

**Kanıt (ikisi de KANIT'a):** silmeden **önce** ve **sonra**
`grep -rn "devUserIdEzmesi\|DEV_USER_ID" src/client/lib` çıktısı. Öncede yalnız tanım satırı
görünmeli (okuyan yok), sonrada hiçbir şey.

**`docker-compose.yml:31`'deki `DEV_USER_ID` satırı — ÖLÇ, KARAR VERME.**
`grep -rn "DEV_USER_ID" src/backend` koşulur:
- **boş dönerse** ⇒ sunucu da kullanmıyor, satır ölüdür → **yaz, ama SİLME** (ayrı karar, Onur'un).
- **dolu dönerse** ⇒ dev-header kalkanı hâlâ kullanıyor → **KALIR**, gerekçesiyle yaz.

## 4. §C — AYAK 3'e gerçek kimlik ayağı ekle (ÜRÜN UCU)

AYAK 3 bugün "varsayılan-ret (401) / dev-kimlikle geçiş (200)" ölçüyor; kimlik dilimini kanıtlayan
**üç adım** eklenir. Hepsi **paketlenmiş imaja** karşı, koşucudan (imajda `curl` yok — bilerek):

1. `POST /v1/auth/register` **taze e-posta** ile → **HTTP 201** ve yanıt gövdesinde `accessToken`
   alanı **var**
2. dönen token ile `GET /v1/tasks` → **HTTP 200**
3. **token olmadan** aynı uç → **HTTP 401**

Üçünden biri sağlanmazsa ayak kırmızı yanar ve **hangisinin düştüğü yazılır**.

🔴 **o79 dersi:** `curl … | grep -q` **YAZMA** — `pipefail` yalancı kırmızı yakar. Önce dosyaya
indir, sonra dosyada bak. Dize araması yerine **HTTP kodu** ve **JSON alan varlığı** kullan.

## 5. §D — KANIT

- `KANIT/o83I/00-CEVAP.md` (beş satır)
- `KANIT/o83I/01-paket-yml-farki.txt` — `paket.yml`de değişen satırların diff'i
- `KANIT/o83I/02-olu-sabit-olcumu.txt` — §B'nin önce/sonra grep çıktısı
- `KANIT/o83I/03-backend-DEV_USER_ID-olcumu.txt` — `grep -rn DEV_USER_ID src/backend` ham çıktısı

**Kapı koşumu bu emirde YOK.** `paket` push'ta tetiklenir; yeşil kanıtı push sonrası okunur.

## 6. CEVAP — `KANIT/o83I/00-CEVAP.md`, beş satır

1. `paket.yml`den silinen satır aralığı + AYAK 1'in **kalan** kontrollerinin listesi.
2. `devUserIdEzmesi` silme **öncesi/sonrası** grep sonucu.
3. `grep -rn DEV_USER_ID src/backend` sonucu ve compose satırının kaderi (kalıyor / ölü ama silinmedi).
4. AYAK 3'e eklenen üç adımın **tam kabuk kodu** (olduğu gibi).
5. `git --no-optional-locks status --porcelain -- src tests` — **yalnız `main.dart`** görünmeli.

## 7. KABUL

- [ ] `paket.yml`de `deadbeef-0000-4000-8000-000000000001` dizesi **hiç geçmiyor**
- [ ] AYAK 1'in kalan kontrolleri bozulmadı; `YESIL:` satırı artık yanlış iddia etmiyor
- [ ] `grep -rn "devUserIdEzmesi" src/client/lib` **boş**
- [ ] AYAK 3'te üç kimlik adımı var, **hiçbiri `| grep -q` boru hattı kullanmıyor**
- [ ] Dört KANIT dosyası var
- [ ] Tek commit, yol belirterek, çift tırnaksız mesaj, author `onurkesimbjk@gmail.com`
- [ ] 🔴 **PUSH YOK** · `KANIT/slice-3c/02-G2/*.json` girmedi (mayın 19)
- [ ] Kanıt dosyası **kendi commit'inin hash'ini yazmaz** (o83-H bulgusu) — dosya listesi yeterli

## 8. DOKUNMA LİSTESİ

- ❌ `verify.ps1` · `DURUM.md` · `README.md` · `CLAUDE.md` · `arsiv/` · testler
- ❌ `docker-compose.yml` (yalnız ÖLÇÜLÜR) · `Dockerfile` · migration · şema
- ❌ Kapıya yeni **dize** araması eklemek
- ❌ Kapıyı `continue-on-error` / `if: false` ile **susturmak**
- ❌ **PUSH** — sıradaki adım Onur'un
