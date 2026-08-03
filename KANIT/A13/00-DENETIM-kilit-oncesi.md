# `GOREV-A13` — BAĞIMSIZ DENETİM (oturum 52, 3 Ağu 2026)

🔴 **ZAMANLAMA DÜRÜSTÇE YAZILIYOR: bu denetim kilitten SONRA koştu.** Onur `K126` ile kilidi
verdikten sonra Cowork denetimi koşturdu, bloker çıktı, kilit **Onur'un onayıyla açıldı** ve spec
düzeltildi. Bu sıra hatasının kendisi **`K127`**'yi doğurdu (kilit checkpoint'i artık denetçi çıktı
yolunu taşımak zorundadır). Bu dosya **o yoldur**.

**Denetçiler:** iki bağımsız ajan, **ikisi de spec'i yazmadı** (K26). Farklı lensler:
① kriter-içi çelişki / ölçülemeyen kriter · ② kör kapı / eşdeğer mutant.
İkisi de **bağımsız olarak aynı bloker'a** çarptı (`G27/a`'nın dal filtresizliği).

---

## BLOKER 1 — kriter 7 ↔ kriter 8 çelişiyor (**`A11`'in aynısı, aynı numaralarda**)

`A13/G27/a` ölçümü `gh run list --workflow ci.yml --limit 5` idi ve geçme koşulu *"**en son**
koşumun `conclusion` = `success`"*. **Dal filtresi yoktu.** Kriter 8 aynı iş akışını mutant
dallarında kasten **failure** koşturuyor.

**Senaryo:** kriter 8 biter → §11 gereği Cowork `G27/a`'yı kendi ölçer → listenin başı `M169`'un
`failure`'ı olur → **kriter 7 kabul anında KIRMIZI**, hâlbuki geçmişti. İki kriter aynı anda
sağlanamaz.

**Onarım:** `--branch main` (ayak a) + `rev-parse main` (ayak b, `HEAD` değil — builder mutant
dallarındayken `HEAD` mutant commit'idir).

## BLOKER 2 — `A13/G30/d` **kördü**

`git status --porcelain`'in boş olması *"dosyalar değişmedi"*yi değil *"ağaç kirli değil"*i ölçer.
`flutter create` `lib/main.dart`'ı yeniden üretir, builder commit'ler ⇒ **ölçüm tertemiz döner**,
oysa `lib/` değişmiştir. Üstelik §9/8 `D-A13-1`'in mutantsızlığını tam da bu ayağa yaslıyordu.

**Ölçülmüş kanıt (oturum 52'de fiilen görüldü):** commit betiğinde `git status --porcelain`
**EXIT 0** verdi ve çıktısı **beş dosyayla doluydu** ⇒ çıkış koduna bakan el kirli ağacı yeşil sayar.

**Onarım:** `git diff --stat <dilim-öncesi-sha>..HEAD -- src/client/lib src/client/test
src/client/pubspec.yaml` ⇒ **çıktı BOŞ**. Dilim öncesi sha artık **kriter 1'de** kaydediliyor.

## BLOKER 3 — `A13/G29/c` **kördü ve `M169` onu maskeliyordu**

Ölçüm *"log içinde `Runner.app` üretim satırı"* — alt-dizge araması. Xcode logu **başarısız**
derlemede de `Runner.app` içerir (`ProcessInfoPlistFile …/Runner.app/Info.plist`, ki `M169`'un
patlattığı adımın ta kendisidir) ⇒ ayak bozukta da yeşil verirdi; `M169` işi düşürdüğü için `G29/d`
kırmızı olur ve **kör ayağı gizlerdi**. `A11`/`M141` deseninin aynısı.

**Onarım:** tam satır pini `Built build/ios/iphoneos/Runner.app (` + parantez içi boyut > 0;
`G29/b` de *"benzeri"*den **tam dizge**ye (`Xcode build done.`) çevrildi.

---

## MAJOR (altısı da düzeltildi)

| # | bulgu | onarım |
|---|---|---|
| 1 | **`M167` EŞDEĞER** — `unused_import` Dart'ta **warning**; `flutter analyze` zaten warning'de düşer ⇒ mutant `--fatal-infos` olmadan da ısırır ⇒ `D-A13-3`'ün çekirdek iddiası **hiç ölçülmüyordu** | `print('mutant');` (`avoid_print`, **INFO**). Ölçülerek seçildi: `src/client/analysis_options.yaml` `flutter_lints/flutter.yaml` içeriyor, `avoid_print` **devre dışı değil** (dosya okundu) |
| 2 | `G27/b` mutant dallarında ölçülemez (`HEAD` ≠ `main`) | `rev-parse main` |
| 3 | Kriter 3 *"`G30` (a·b·c·d) EXIT 0"* diyordu ama ayak d'nin komutu **kirlide de 0 döner** | a·b·c ⇒ EXIT 0; d ⇒ **çıktı BOŞ** (iki ölçü ayrıldı) |
| 4 | `G30/a` *"HER `PRODUCT_BUNDLE_IDENTIFIER`"* — Flutter şablonunda `RunnerTests`'in **kendi** id'si var ⇒ kriter ya hiç geçmez ya builder projeyi bozar *(denetçi `[ŞÜPHE]` işaretledi, şablonu ölçemedi)* | yalnız **`Runner` hedefinin üç yapılandırması**; `RunnerTests` **§9/9'da beyan edilmiş sınır** `[DOĞRULANMADI]` |
| 5 | `G28/b` *"`stable`/`latest` geçmesin"* — `flutter-version: 3.44.6` + `channel: stable` **meşru** birliktelik ⇒ doğru dosya kırmızı olurdu | `flutter-version:` **anahtarının değeri** ölçülür; ayrıca **`M163b`** yanlış-pozitif mutantı eklendi (ısırmamalı) |
| 6 | Kriter 8'in **push'u** §7'nin "SIRA PAZARLIKSIZ" listesinde hiç geçmiyordu | kriter 8'e **Onur'un tek push'u** açıkça yazıldı |

## MINOR (beşi de kapatıldı)

- `G29/b`'deki *"benzeri"* bir ölçüm değil hükümdü ⇒ tam dizge
- §9/8 *"kriter 3 ile 6 arasında **iki kez** ölçülür"* diyordu, §7 **bir kez** zorluyordu ⇒ beyan gerçeğe çekildi
- `G27/b` **mutantsızdı** ⇒ **`M170`** eklendi (statik, tavansız): kaydedilmiş `gh run` JSON'ının `headSha`'sı bozulur, `G27/b` ısırmalı
- `M169`'un hedefi `D-A13-2` yazıyordu; `Info.plist`'i bozmak bundle id'yi ölçmez ⇒ hedef **`D-A13-1`**
- **Kriter 1 ↔ §9/7:** altın kümenin *yorum satırı* vakasının **beklenen hükmü yazılı değildi** ⇒ builder aracı kendi lehine yazabilirdi (*"küme kendini onaylar"*). Hüküm artık **kriter 1'de yazılı**: yorum satırındaki bayrak **KIRMIZI vermeli**.

---

## DENETÇİLERİN DOĞRULADIĞI (bulgu değil, olumlu ölçüm)

🟢 **KÖR KAPI YOK:** §5'in **14 ayağının tamamı** §7'de çağrılıyor. İkinci denetçi tek tek eşledi:
`G30` a-d → kriter 3 · `G28` a-b + `G29` a → kriter 4 · `G27` a-c + `G28` c-d + `G29` b-d → kriter 7.

## DÜZELTME SONRASI ÖLÇÜM

`spec-kapi-kapsama.py` altın küme **21/21** → spec **EXIT 0 / BULGU YOK**.
**4 kapı · 7 kural · 10 mutant** (`M162`–`M170` + `M163b`; *koşan* sınıf **tam 3**) · **1 gerekçeli borç**.
`kapi-ad-teklik-kapisi.py` **YEŞİL**. Kimlik: **27.908 b · `BCD0AA81`** · U+FFFD 0 · CRLF 0.
