# `A13` — KABUL ÖNCESİ BAĞIMSIZ DENETİM (K127) · oturum 53, 3 Ağu 2026

> **K127 gereği bu tur KİLİTTEN/KABULDEN ÖNCE koştu.** Üç bağımsız denetçi (K26: üreten ≠
> denetleyen) ayrı lenslerle çalıştı; hiçbiri Cowork'ün özetine güvenmedi, hepsi ham veriden
> ve canlı GitHub API'sinden yeniden ölçtü. **Denetçilerin hükmü: ÜÇÜ DE "ŞARTLI".**

| denetçi | lens | hüküm | bloker |
|---|---|---|---|
| A | kriter 7'yi çürüt | ŞARTLI | yok |
| B | kriter 8'i çürüt (eşdeğer mutant avı) | ŞARTLI | **B1 — `M167` eşdeğer** |
| C | spec ↔ ölçüm kapsaması/tutarlılığı | ŞARTLI | yok |

---

## 🔴 BLOKER B1 — `M167` EŞDEĞER MUTANTTIR (Cowork tarafından GERÇEK DEPODA doğrulandı)

Denetçi B izole bir pakette buldu; **Cowork gerçek `src/client/lib/main.dart` üzerinde yeniden
ölçtü** (kanıt: `07-MUTANT-kosan/40-BULGU-M167-esdeger-mutant.txt`). Flutter **3.44.6**,
`flutter analyze --help` ham çıktısı:

```
--[no-]fatal-infos        Treat info level issues as fatal.
                          (defaults to on)
```

Gerçek depoda ölçülen tablo (yama bayt düzeyinde uygulandı, `git restore` KULLANILMADI,
geri yazım **bayt-özdeş** `C6B6EDBD`):

| vaka | EXIT |
|---|---|
| temiz + bayraksız | **0** |
| temiz + `--fatal-infos` | **0** |
| `print('mutant')` + **BAYRAKSIZ** | **1** |
| `print('mutant')` + `--no-fatal-infos` | **0** |
| `print('mutant')` + `--fatal-infos` | **1** |

⇒ **`ci.yml`'den `--fatal-infos` silinseydi `M167` YİNE ısırırdı.** Yani `M167`,
`D-A13-3`'ün çekirdek iddiasını (*"bayrak taşıyıcıdır, düşürmek kapıyı sessizce gevşetir"*)
**ölçmüyor**. Bu, oturum 52'nin *"`M167` ÖNCE EŞDEĞERDİ, DEĞİŞTİRİLDİ"* diye kapattığını
sandığı kusurun **birebir tekrarıdır**: onarım WARNING'i INFO ile değiştirdi, oysa 3.44.6'da
**ikisi de varsayılan ölümcüldür**.

**Ölçülmüş sonuç:** bu sürümde `--fatal-infos` varsayılanı tekrar eden bir **no-op**'tur;
gevşeten bayrak `--no-fatal-infos`'tur. Bayrağın *dosyadaki varlığı* statik `M162` ile
korunuyor; *çalışma anındaki taşıyıcılığı* **hiçbir mutantla gösterilemez ve gösterilemezdi**.
🔴 *Koşan* mutant tavanı **3/3 DOLU** (§6) ⇒ dördüncü mutant açılamaz. Doğru kapanış yeni
mutant değil, **spec'in ölçülen gerçeğe çekilmesidir**.

---

## 🟠 MAJOR (üç denetçinin de bağımsız bulduğu)

**MJ-1 — `A13/G29/b` KÖR AYAK.** `Xcode build done.` tam dizgesi `main` (ios **success**,
`91.9s`) ve `M169` (ios **failure**, `43.7s`) loglarının **ikisinde de 1 kez** geçiyor.
Ayırt etme gücü **sıfır**; `G29`'u ısırtan yalnız `c` ve `d`'dir. Yanlış-YEŞİL üretmiyor
(kapı bütün olarak ayırt ediyor) ⇒ bloker değil, ama **beyan edilmemiş sınır**.
Kanıt: `07-MUTANT-kosan/30-BULGU-G29b-kor-ayak.txt`.

**MJ-2 — `08-OZET.md` BAYAT VE ARTIK YANLIŞ.** mtime 10:50:44Z, CI koşumu 11:27:18Z ⇒
özet koşumdan **37 dk önce** yazılmış ve hâlâ *"kriter 7 = ⏳ BEKLEMEDE"* diyor. §10 bu
dosyayı *"madde madde PASS/FAIL + ölçülen sayılar"* diye tanımlıyor. İşe alan tarafın
açacağı dosya, geçmiş bir kriteri **yalanlıyor** (`bayat-iddia` sınıfı).

**MJ-3 — KRİTER 7'NİN DİNAMİK AYAKLARININ KORUNMUŞ ARACI YOK (K44-a).** `ci-kapisi.py`
yalnız statik ayakları ölçüyor. `G27 a·b·c` + `G28 c·d` + `G29 b·c·d` **saklanmamış**
`%TEMP%` betikleriyle ölçüldü; altın kümesi yok, üçüncü bir el yeniden koşamaz.
🔴 **Kaçan tek kör ayağın (`G29/b`) tam da araçsız kümede olması tesadüf değildir.**

**MJ-4 — `M170` GERÇEK ÖLÇÜM YOLUNU DEĞİL KOPYASINI ISIRIYOR.** Kriter 7 betiği `G27/b`'yi
**canlı `gh` stdout'undan** ölçüyor; kaydedilen JSON bir yan-üründür. `M170` o JSON'u bozup
**kendi içinde yazdığı** karşılaştırmayı koşuyor. Gizleme yok (betiğin docstring'i bunu
yazıyor), ama *"`G27/b` kör değildir"* hükmü **ölçülenden geniştir**; ölçülen şey
*"kaydedilmiş kanıtın karşılaştırma mantığı ayırt ediyor"*tur.

**MJ-5 — `G29/c` ONARIMININ DEĞERİ HİÇBİR MUTANTLA GÖSTERİLEMEDİ.** Kilit öncesi denetimin
gerekçesi *"başarısız derlemede log `Runner.app` içerir (ör. `ProcessInfoPlistFile`)"* idi;
`M169` logunda `Runner.app` alt-dizgesi **0**, `ProcessInfoPlistFile` **0** ⇒ eski (alt-dizge)
ayak da `M169`'da KIRMIZI verirdi. Elde bulunan tüm örneklerde onarılmış ve onarılmamış ayak
**davranışsal olarak özdeş**. 🔴 Üstelik Cowork'ün `20-M167-M169-OLCUM.txt` dosyası bu `0`'ı
**`KOR-AYAK KANITI:`** diye etiketledi — **etiket terstir**, `0` körlüğün değil tersinin
göstergesidir. *(Cowork'ün kendi ölçüm betiğinin kusuru; gizlenmiyor.)*

---

## 🟡 MINOR

- `01-gh-run-list-branch-main.json` **`--branch main` filtresini kendi kendine kanıtlayamıyor**:
  `--json` alanlarında `headBranch` yok, komut satırı kaydedilmemiş. (Denetçi A canlı filtreli
  koşup aynı tek kaydı aldı ⇒ içerik doğru, **kanıt zayıf**.) Onarım: `headBranch` ekle.
- `M170` spec'in *"sıra pazarlıksız"* düzeninin **dışında** koştu: mutant koşumları havadayken
  (12:17:08Z) ölçüldü. Özde zararsız (yalnız yerel JSON + `rev-parse main`), ama sıra ihlali.
- `M170`'in geri yazımı `01-…json`'un **zaman damgasını ezdi** (12:17:08Z = yakalama anı değil).
  İçerik bütünlüğü korunmuş (`2B63CB73` önce/sonra özdeş, canlı `gh` ile de teyitli).
- **Bayat yer tutucular:** `06-ci-yesil/00-BEKLEMEDE.txt` hâlâ *"HENÜZ BOŞ, push YAPILMADI"*,
  `07-MUTANT-kosan/00-DALLAR-YERELDE-ACILDI.txt` hâlâ *"`gh workflow run` KOŞTURULMADI"* diyor.
- **`G28/d`'nin `N/N` biçimi logda lafzen YOK:** CI reporter'ı `🎉 500 tests passed.` basıyor,
  payda yok. Hüküm *"`failed` satırı 0"* kuralıyla verildi. 🔴 Gevşek `tests passed` arayan bir
  kapı `M168`'in `499 tests passed, 1 failed.` satırını **yeşil sayardı** ⇒ dizge pinlenmeli.
- **Mutantsız ayaklar (§9'da beyan edilmemiş):** `G27/a` · `G27/c` · `G30/b`.
- **Yasak 8 (kapı susturma) hiçbir kapıyla ölçülmüyor** — `G30/d`'nin yol listesi
  `analysis_options.yaml`'ı kapsamıyor. *(Fiilî ihlal yok: denetçi C ölçtü, dosya bu dilimde
  değişmemiş ve `avoid_print` devre dışı değil.)*
- **Kilit öncesi denetimin *"14 ayak"* sayımı yanlış** — kendi eşlemesi **15** veriyor.
- **Aksiyonlar sha'ya pinli değil** (`actions/checkout@v4`, `subosito/flutter-action@v2`) ⇒
  bu yeşil **inşa gereği tekrarlanabilir değildir**.
- **Uzaktaki üç mutant dalı duruyor** — silmesi Onur'un (kırmızı çizgi 4).
- Kanıt dosyaları (`06-ci-yesil/*`, `07-MUTANT-kosan/*`) **izlenmiyor** (`??`) ⇒ itilmiş
  depoda kabul kanıtı yok.

---

## 🟢 ÇÜRÜTÜLEMEYEN — DENETÇİLERİN BAĞIMSIZ ONAYLADIĞI

- **Koşum gerçek, `main` dalında, bu commit'te.** Denetçi A ham logu **canlı yeniden çekti**:
  `192.875 bayt · sha256 5adc00c6…bb5e` — diskteki kopyayla **BAYT-ÖZDEŞ**. Bayatlık ve
  uydurma **elendi**. `02-gh-run-view.json` de canlı çekimle JSON-özdeş.
- **Kriter 7 ↔ 8 çelişkisi GERÇEKTEN kapandı:** filtreli `--branch main` → tek kayıt `success`;
  **filtresiz** `gh run list` → listenin başı `mutant/A13-M169 failure`. `A11`'in tekrarı
  önlendi, `--branch main` onarımı hem gerekliydi hem işe yaradı.
- **Kapı susturma YOK:** `ci.yml` (580 b, blob `0b326e38…`) Python ile sayıldı —
  `continue-on-error` 0 · `if:` 0 · `|| true` 0 · `set +e` 0 · `exit 0` 0 · `--no-fatal` 0.
  Diskteki dosya `main:.github/workflows/ci.yml` ile bayt-özdeş ⇒ okunan dosya koşan dosyadır.
- **Hiçbir test `skip` edilmedi:** 35 test dosyasında `skip:`/`solo:`/`@Skip`/`@Tags`
  eşleşmesi **0**; log'da `~N` atlama sayacı yok. `500 = 499 + 1` (`M168`) tutuyor.
- **İzolasyon 3/3:** `M167`/`M168` → `ios` success + `istemci` failure; `M169` → tersi.
  Hiçbir koşumda yanlış iş düşmedi. Adım düzeyinde de temiz.
- **Dal hijyeni:** üç dalın hiçbiri `main`'in atası değil (`--is-ancestor` rc=**1**, 128 değil);
  `ci.yml` blob'u **6 ref'in (yerel+uzak) hepsinde** aynı; run `headSha`'ları uzak dal uçlarıyla
  birebir eşit. `git diff e65a8bc..79d0901 -- src/client .github araclar` **BOŞ**.
- **`M170` `git restore` KULLANMIYOR** (ORTAM.md'ye uygun); `.tmp`/`.yedek` artığı yok.
- **`ci-kapisi.py --altin-kume` denetçi C tarafından yeniden koşuldu: 13/13, EXIT 0**,
  yorum-satırı vakası kümede var ⇒ kriter 1'in pazarlıksız şartı bağımsız koşumda da karşılandı.
- **15 kapı ayağının 15'i, 10 mutantın 10'u** ölçülmüş. Ölçülmeyen ayak **yok**.

---

## 🟢 DENETİMİN KAPATTIĞI BEYANLAR

- **§9/5 `workflow` token yetkisi `[DOĞRULANMADI]` ⇒ KAPANDI.** Push kapsam yüzünden
  reddedilmedi; GCM token'ında `workflow` vardı (Cowork push öncesi ölçtü:
  `X-OAuth-Scopes = 'gist, repo, workflow'`). Ayrıca `gh workflow run` **`repo` ile çalıştı**
  ⇒ `gh auth refresh` hiç gerekmedi.
- **§9/10 `ci-kapisi.py` HENÜZ YAZILMADI ⇒ KAPANDI** (418 satır, altın küme 13/13).
- **§9/4 KISMEN KAPANDI:** Timing API ⇒ dört koşumun da **billable MACOS 0 ms / UBUNTU 0 ms**
  (ücretsiz kota içinde). **Kalan kontenjan hâlâ `[ÖLÇÜLMEDİ]`.**
- **§9/9'un GEREKÇESİ ÇÜRÜDÜ:** *"şablon içeriği `ios/` üretilmeden ölçülemedi"* — `ios/` artık
  var ve ölçüldü: `RunnerTests` bundle id = `com.momentum.client.RunnerTests` (3 yapılandırma),
  `com.example` **0 geçiş**. Sınır *"ölçülemez"* değil **"kapsam dışı bırakıldı"** demeli.

---

## DENETİMİN ŞARTLARI (kabul için kapatılmalı — hiçbiri CI koşumu istemiyor)

1. 🔴 **`D-A13-3`'ün gerekçesi ve §6'nın `M167` notu ölçülen gerçeğe çekilecek:**
   `--fatal-infos` 3.44.6'da varsayılanı tekrar eden bir no-op'tur; taşıyıcılığı mutantla
   gösterilemez. `M167`'nin ölçtüğü şey **"CI'da analiz kapısı canlıdır ve INFO düzeyinde bir
   ihlali yakalar"**tır — bayrağın taşıyıcılığı değil. Bayrak **geleceğe karşı savunma** olarak
   kalır ve varlığı statik `M162` ile korunur.
2. 🔴 **`A13/G29/b` kör ayak olarak beyan edilecek** (ya da builder tarafından onarılacak/
   kaldırılacak — **Cowork onaramaz, K34-f**).
3. 🔴 **`08-OZET.md` kriter 7 ve 8'i PASS + ölçülen sayılarla yazacak** (§10'un gereği).
4. 🟡 `20-M167-M169-OLCUM.txt`'deki ters `KOR-AYAK KANITI` etiketi düzeltilecek; `G29/c`
   onarımının hiçbir mutantla gösterilemediği yazılacak.
5. 🟡 Bayat yer tutucular (`00-BEKLEMEDE.txt`, `00-DALLAR-YERELDE-ACILDI.txt`) güncellenecek.
6. 🟡 Uzaktaki üç mutant dalını **Onur** silecek (kırmızı çizgi 4).

🔴 **1 ve 2 KİLİTLİ SPEC'E DOKUNUR** (`GOREV-A13-ios-iskeleti-ci.md`, K127 kilidi,
sha `BCD0AA81`) ⇒ **Onur'un açık kilit açması gerekir.** Cowork kilitli spec'e kendiliğinden
tek bayt yazmaz.

---

## DENETİMİN KENDİ SINIRLARI (gizlenmiyor)

- Eşdeğerlik reprodüksiyonu **yerel Flutter 3.44.6** ile koştu; *"CI'da bayraksız da düşerdi"*
  doğrudan ölçülmedi — ölçmenin tek yolu 4. bir koşan mutanttır, **tavan dolu**. CI logu aynı
  SDK'yı gösteriyor (`stable-3.44.6-x64`) ve bayrak varsayılanı araç özelliğidir, OS'a bağlı değil.
- `araclar/ci-kapisi.py`'nin **kaynak kodu satır satır denetlenmedi**; araç dışarıdan ölçüldü
  (altın küme 13/13 + 6 statik mutantın kayıtlı sonucu).
- `18.7MB` bir **log iddiasıdır**; artefakt yüklenmediği için `Runner.app` tartılamadı.
- Üç mutant logunun canlı bayt-özdeşliği yeniden çekilerek doğrulanmadı (yalnız `main` logu
  için yapıldı); koşumların `conclusion`/`headSha`/`headBranch` üçlüsü canlı API'den teyitli.
- Kalan ücretsiz Actions dakikası **ölçülemedi** (`gh` token'ında `user` yetkisi yok).
