# GOREV-W3b — Claude Code kendi koşumunun özeti

> **Bu dosya bir KABUL HÜKMÜ DEĞİLDİR.** T4 (kapı) + T5'in 4/20 mutantı **bunu yazan el** tarafından
> yazıldı/koşuldu; K26 gereği nihai kabul kararı **Cowork'e** aittir. Aşağıdaki sayılar **ham ölçümdür**,
> "TEMİZ"/"YEŞİL" gibi yerel çıktılar kapının kendi çıktısıdır — spec'in genel kabulü değildir.

## T1–T4 (ürün + kapı)

- `T1` — `.gitignore`'a tam yol eklendi: `src/backend/Momentum.Api/wwwroot/`.
- `T2` — `appsettings.json`'a `"Istemci": {"KokDizin": "wwwroot"}` eklendi (JSON geçerliliği ölçüldü).
- `T3` — `araclar/web-yayina-al.py` yazıldı ve **gerçekten iki kez koşturuldu** (build + kopyalama +
  `_BUILD.json`), kaynakSha `ff9b4dbfbef487fefc0a82858aa1a289df08364199914f10879a5a789676c93c`
  (42 dosya), `flutterSurum` **3.44.6** (DURUM.md ile birebir, yama farkı YOK).
- `T4` — `araclar/yayin-kapisi.py` yazıldı; **altın küme 29/29 GEÇTİ** (`03-…-ham.txt`), gerçek repoya
  karşı **YEŞİL (EXIT 0)** (`04-…-ham.txt`).

## Regex düzeltmesi (canlı build ile ölçüldü)

İlk yazımda `useLocalCanvasKit` regex'i yalnız tırnaksız anahtar biçimini (`useLocalCanvasKit:true`)
tanıyordu; **gerçek `--release` build çıktısı anahtarı TIRNAKLI taşıyordu** (`"useLocalCanvasKit":true`,
minifikasyon sonucu). Bu, gerçek build'e karşı ilk koşumda G51/a'yı YANLIŞ-POZİTİF olarak
KIRMIZI'ya düşürdü — kapı kendi golden set'ini geçmişti ama gerçek veriye kördü. Regex her iki biçimi
de (tırnaklı/tırnaksız) kapsayacak şekilde düzeltildi, golden set yeniden koşuldu (29/29 hâlâ geçiyor),
gerçek repo YEŞİL'e döndü. **Bu, üretici elin kendi kusurunu build sırasında yakaladığı bir vakadır —
gizlenmedi.**

## B-W3b-4 / B-W3b-5 borç kapatma testleri (kabul koşumunda ZORUNLU, gerçek ortamda koşuldu)

- **B-W3b-4**: `src/client/lib/main.dart`'a bir bayt eklendi → kapı **G50/d KIRMIZI** verdi
  (kaynakSha uyuşmazlığı) → bayt **byte-özdeş** geri alındı (`git diff --stat` boş) → kapı YEŞİL'e döndü.
- **B-W3b-5**: `wwwroot`'a sahte bir eski dosya (`eski-main.dart.js`) bırakıldı → `web-yayina-al.py`
  **yeniden koşuldu** (gerçek `flutter build web`) → dosya **KALMADI** (temizle-ve-kopyala semantiği
  fiilen doğrulandı) → kapı YEŞİL.

## Kriter 4 (dotnet build)

`dotnet build src/backend/Momentum.Api` ⇒ **0 Uyarı / 0 Hata**.

## Kriter 5 (izlenmeyen dosya ölçümü — dar komut)

`git --no-optional-locks ls-files --others --exclude-standard -- src/backend/Momentum.Api/wwwroot`
⇒ **BOŞ**. `.git/index.lock` yoklandı — **yok**.

## Kriter 6 (verify.ps1)

Sıra: `docker start momentum-postgres` → **yoklanarak** `healthy` (3 deneme, ~6 sn) → `netstat`/
`Get-NetTCPConnection -LocalPort 5298` ile port **serbest** doğrulandı (🔴 çıplak `findstr :5298` bu
turda **yanlış-pozitif** verdi — `52989`'u yakaladı; `ORTAM.md`'nin findstr uyarısı **birebir tekrar
doğrulandı**, kesin ölçüm `Get-NetTCPConnection` ile yapıldı) → `verify.ps1` **EXIT 0**, `0 Uyarı/0 Hata`,
CVE **0**, test **120/120**. **Borç kapandı: `B-O62-2`** (verify.ps1'in Windows'ta ilk başarılı koşumu).

## Kriter 8 (canlı HTTP ölçümü — B-W3b-1'den terfi)

- **Doğru dizinden** (`ORTAM.md` reçetesi birebir): `GET /` ⇒ **200**, gövdede `flutter_bootstrap.js`
  geçiyor. `GET /_BUILD.json` ⇒ **200**.
- **Negatif kontrol**: ilk deneme (`dotnet run --project ...` repo kökünden) **BEKLENMEDİK ŞEKİLDE**
  doğru dizine çözdü (GEÇERSİZ sayıldı, teşhis dosyada yazılı) — ikinci, GEÇERLİ deneme (derlenmiş DLL
  doğrudan `C:\dev`'den çalıştırıldı) `GET /` ⇒ **404** (200 DEĞİL) verdi. N4'ün beyan ettiği bedel
  **fiilen doğrulandı** — hangi iç katmanın (appsettings.json yüklemesi mi, `Path.GetFullPath` mi) önce
  patladığı ayrı bir teşhis sorusu olarak **dürüstçe not edildi** (`02-kriter8-…txt`).
- **Kapatır: `B-W3b-1`.**

## T5 — mutant koşumu (yalnız BENİM 4'üm: M250/M253/M256/M262)

Hepsi **gerçek repoya karşı** koşuldu, hepsi **beklenen sonucu verdi**, hepsi **bayt-özdeş** geri
alındı (`ozdes=True` dördünde de):

| mutant | rc | hüküm | beklenen |
|---|---|---|---|
| M250 | 3 | ORTAM HATASI | ORTAM HATASI (G49/b pozitif kontrol düşer) |
| M253 | 2 | KIRMIZI | G50/c KIRMIZI |
| M256 | 3 | ORTAM HATASI | ORTAM HATASI (G50/f) |
| M262 | 3 | ORTAM HATASI | ORTAM HATASI (G51/d) |

Diğer **16 mutant Cowork'e aittir** (spec §4b, hepsi içerik-mutantı, mount'ta sorunsuz koşar) —
`_mutant_kosucu.py` bunları **tanımlı** tutar (`--hepsi` ile bu makinede de koşulabilir) ama varsayılan
koşum yalnız yukarıdaki dördünü çalıştırır.

## Ortam ölçümü (K80)

`docker ps`/`ps -a`, `netstat`/`Get-NetTCPConnection`, `adb devices` (tam yolla), `flutter --version`
— hepsi `00-ortam-olcumu.txt`'te ham. Son durum: `momentum-postgres` **çalışıyor** (bırakıldı),
`Momentum.Api` süreci **kapalı** (port serbest).

## Commit

Bekleyen 8 izlenen + 3 yeni Cowork dosyası + benim T1–T5 ürün/araç/kanıt dosyalarım **tek turda**
commit edilecek (ayrı adımda, bu dosyadan SONRA) — author `onurkesimbjk@gmail.com`, mesajda çift tırnak
yok, `--no-optional-locks`, **push YOK**.

## Ölçülmeyen / beyan edilmiş sınırlar (tekrar etmiyorum, spec §8'de zaten yazılı)

Tarayıcı ölçümü (`crossOriginIsolated`, gerçek `main.dart.js` yürütmesi, `--dart-define`'ın çalışma
anındaki değeri) bu turda da **ölçülmedi** (playwright yok, `B-O62-3`). `B-W3b-3` açık kalır.
