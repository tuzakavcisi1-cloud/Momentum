# İŞ EMRİ — o81 · `aspnet:10.0` yüzen etiketinin pinlenmesi

**Kime:** Claude Code (ürün kodunu yazan el)
**Kimden:** Cowork (tasarım · iş emri · denetim). Cowork ürün kodu YAZMAZ — CLAUDE.md §1.
**Tarih:** 17 Ağustos 2026 · **HEAD:** `09d0e75` · **Kilit:** Onur, 17 Ağu
**Sürüm politikası [Onur kilidi]:** `v1.0.0` etiketi **DEĞİŞMEZ**. Bu düzeltme `main`'e iner;
etiketin kaynak arşivi bu tek satırda geride kalır ve bu bilinçlidir.

---

## 1. Sorun (ölçüldü)

`Dockerfile:149` çalışma imajını **yüzen** etiketle çeker:

```
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS calisma
```

Oysa aynı dosyanın `100-107` satırları, SDK için tam tersini **ölçerek** yazıyor: MCR etiket
listesinde hem `10.0.302` hem `10.0.400` yayında olduğu için yüzen `10.0` etiketi özellik bandını
atlayabilir ⇒ SDK `10.0.302`'ye birebir pinlendi, `global.json` ile hizalı.

**Çelişki budur:** yapı zincirinin bir ucu birebir pinli, öbür ucu yüzen. Bağımsız bir denetçinin
ilk soracağı şey. o79 denetiminde açık bulgu olarak yazıldı, kapatılmadı.

## 2. Yapılacak iş — TEK SATIR

`Dockerfile:149`'daki yüzen etiket, **ölçülmüş** bir sürüme pinlenecek ve gerekçesi SDK pininin
hemen üstündeki yorum bloğuyla **aynı üslupta** yazılacak (tarih + neyin okunduğu + neden).

🔴 **Sürümü UYDURMA.** Aşağıdaki ölçüm koşulmadan pin yazılmaz.

## 3. Ölçüm protokolü (pin yazılmadan ÖNCE)

```powershell
docker pull mcr.microsoft.com/dotnet/aspnet:10.0
docker run --rm mcr.microsoft.com/dotnet/aspnet:10.0 dotnet --list-runtimes
docker image inspect mcr.microsoft.com/dotnet/aspnet:10.0 --format '{{index .RepoDigests 0}}'
```

- İkinci komut, yüzen etiketin **şu an** hangi ASP.NET Core sürümünü verdiğini söyler
  (`Microsoft.AspNetCore.App 10.0.X`). Pin **o X**'e yazılır: `aspnet:10.0.X`.
- Üçüncü komut digest'i verir; digest **KANIT'a yazılır** ama `FROM` satırına digest
  konmaz — depo SDK'yı da tag ile pinliyor, biçim tutarlı kalsın.
- MCR etiket listesi de okunacak (`https://mcr.microsoft.com/v2/dotnet/aspnet/tags/list`) ve
  `10.0.X`'in **gerçekten yayında** olduğu doğrulanacak. 🔴 Bu listeyi bulut aracıyla okuma —
  Cowork denedi, gövde bozuk geldi (`10.0.8`/`10.0.9` eksik, `10.0.10`/`10.0.11` var iddiası).
  Yerelden `curl`/`Invoke-RestMethod` ile ham JSON çek.

## 4. Kabul ölçütü — hepsi ölçülecek, beyanla geçilmez

1. `Dockerfile`'da `aspnet:10.0` **kalmayacak**; `grep -n "aspnet:10\.0$" Dockerfile` **boş** dönecek.
2. `docker compose up --build` yerelde ayağa kalkacak ve `curl -fsS http://localhost:5298/health/ready`
   **200** dönecek.
3. `paket` iş akışı push'tan sonra **yeşil** yanacak (beş ayak + migrator).
4. Çalışan imajın gerçekten pinli sürümü taşıdığı ölçülecek:
   `docker compose exec api dotnet --list-runtimes` (ya da imaj üzerinde eşdeğeri) `10.0.X` diyecek.
   🔴 **Dosyada yazması yetmez — koşan imajdan çekilecek.** (o79 kör kapı dersi: dize değil VARLIK.)
5. Ham çıktılar `KANIT/o81/` altına yazılacak: `01-aspnet-pin-olcumu.txt` (üç komutun çıktısı +
   MCR listesi teyidi) · `02-pin-sonrasi-canli.txt` (health/ready + list-runtimes).

## 5. Sınırlar — dokunma

- **Yalnız `Dockerfile`** değişecek (bir `FROM` satırı + üstüne gerekçe yorumu) ve `KANIT/o81/`
  eklenecek. Başka dosya YOK.
- `README.md`'ye **DOKUNMA** — o düzeltmeyi Cowork yazıyor, çakışma çıkmasın.
- `DURUM.md`'ye **DOKUNMA** — Cowork'ün. Çalışma ağacında `M DURUM.md` duruyor olabilir; ona
  dokunmadan kendi dosyalarını commit et.
- `git add -A` **YASAK** — yol belirt. `KANIT/slice-3c/02-G2/*.json` commit'e **girmez** (sınır 19).
- **Push Onur'da.** Commit mesajında çift tırnak kullanma, ASCII yaz.
- Yeni kapı DOSYASI açma (kapı bütçesi ihlalde, sınır 3).

## 6. Bu iş DÜŞERSE

Pinlenen sürümle imaj kalkmıyorsa ya da `paket` kırmızı yanıyorsa: **geri al, uydurma sürümle
zorlama.** Ölçtüğünü yaz, iş emrini düşmüş say ve Cowork'e dön — borç `aspnet:10.0 yüzen etiket`
olarak README'de yazılı kalır, bu da meşru bir teslim biçimidir.
