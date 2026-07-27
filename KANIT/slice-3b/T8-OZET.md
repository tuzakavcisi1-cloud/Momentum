# T8 — KAPI ARAÇLARI — özet (K57 sonrası, oturum 31)

## Üretilen/güncellenen araçlar

1. **`araclar/pub-cve-kapisi.py`** (YENİ, G2) — pubspec.lock + pubspec.yaml
   (`ignored_advisories`) girdisiyle pub.dev `/advisories` ucunu tarar.
   Altın küme: **8/8, EXIT 0** (`--altin-kume`). Ağa çıkmaz, fixture.
2. **`araclar/pub-lisans-kapisi.py`** (YENİ, G3) — pubspec.lock girdisiyle
   pub.dev `/metrics` ucunu (`scorecard.panaReport.licenses`) tarar.
   Altın küme: **6/6, EXIT 0** (`--altin-kume`, bkz. aşağıdaki metin-kanıtlı
   eşleşme mekanizması). Ağa çıkmaz, fixture.
3. **`araclar/design-token-kapisi.py`** (GÜNCELLENDİ v0.1.0 → v0.2.0, K34-f: onaran
   el = yazan elden ayrı, meşru) — D1 sıkılaştırması (yalnız `lib/design/` içinde
   kullanım D1'i doyurmaz; 4 adlı token TAM MUAF) + D5 (tokens.dart/tema.dart
   dışında `Theme.of(`) + D6 (`lib/` altında cupertino.dart importu) eklendi.
   Altın küme: **18/18, EXIT 0** (12 mevcut + 6 yeni: D1×3, D5×2, D6×1).
4. **`araclar/lisans-eslesme.json`** (YENİ) — G3'ün metin-kanıtlı lisans
   eşleşme defteri (bkz. aşağıda).

## Gerçek koşum sonuçları

| kapı | komut | sonuç |
|---|---|---|
| G2 | `pub-cve-kapisi.py src\client\pubspec.lock` | **TEMİZ, EXIT 0** — 90 hosted paket sorgulandı (5 SDK atlandı), bastırılmamış CVE bulgusu **0**. Ham JSON + sorgu zamanı: `03-G2/gercek-tarama.txt`. |
| G3 | `pub-lisans-kapisi.py src\client\pubspec.lock --eslesme araclar\lisans-eslesme.json` | **TEMİZ, EXIT 0** — bkz. aşağıdaki çözüm. Ham JSON: `04-G3/gercek-tarama.txt`. |
| G4 | `design-token-kapisi.py . --design DESIGN.md --kod src/client --token-dosyasi lib/design/tokens.dart` | **TEMİZ, EXIT 0** — D0-D6 hepsi 0 (bkz. aşağıdaki yan-etki düzeltmesi). |

## G3 GERÇEK BULGU — ÇÖZÜLDÜ (metin-kanıtlı eşleşme, Onur+Cowork kararı)

`sqlcipher_flutter_libs 0.7.0+eol` (drift_flutter → transitif, **Z9 gereği
ELENEMEZ**) pub.dev pana taramasında **üç** SPDX etiketi taşıyordu: `Pixar`,
`MIT`, `BSD-3-Clause-HP`. Cowork'ün bağımsız ölçümü (pub cache'teki gerçek
LICENSE dosyası, 12929 bayt, sha256 `1052710c...`) dosyanın **üç ayrı gerçek
lisans metni** taşıdığını gösterdi: MIT (satır 3) + düz Apache-2.0 (satır 29,
`"Pixar"`/`"Modified Apache"` dizgesi dosyada **YOK**) + düz BSD-3-Clause
(satır 209, Zetetic/SQLCipher). Kusur pakette değil pana'nın bulanık şablon
eşleştirmesinde. Kanıt: `04-G3/COWORK-BAGIMSIZ-LISANS-OLCUMU.txt` +
`04-G3/COWORK-ham-LICENSE-sqlcipher_flutter_libs-0.7.0+eol.txt`.

**Çözüm — METİN-KANITLI EŞLEŞME (yeni mekanizma, `araclar/lisans-eslesme.json`):**
her eşleşme kaydı `<paket, sürüm, pana_spdx> -> <gerçek_aile>` + zorunlu kanıt
alanları (`kanit_dosya`, `kanit_satir`, `kanit_olcum`, `gerekce`) taşır; eşleşme
YALNIZ o paket+sürüm için geçerlidir (genel beyaz liste DEĞİL). `pub-lisans-kapisi.py`
her geçerli eşleşmeyi **`ESLENDI ...` diye basar** (yutmaz); alan eksikse
`LIS-ESLESME-GECERSIZ` ile KIRMIZI yanar. Altın küme **4/4 → 6/6** büyüdü (K40:
eşiği değiştiren vaka ekler), `--altin-kume` **EXIT 0**.

**Gerçek koşum (güncel):** `pub-lisans-kapisi.py src\client\pubspec.lock --eslesme araclar\lisans-eslesme.json`
→ **HÜKÜM: TEMİZ, EXIT 0** — izinsiz lisans 0, iki `ESLENDI` satırı basılı,
`sqlite3_flutter_libs 0.6.0+eol` ayrıca ölçüldü ve zaten temiz (yalnız MIT).
Çıktı: `04-G3/gercek-tarama.txt`, `04-G3/konsol-ciktisi.txt`.

Spec kabul kriteri 7'deki `"4/4"` → `"6/6"` düzeltmesi ve spec'e araç adının
eklenmesi **Onur/Cowork'ün T9 kapanışındaki tek kilit turunda** yapılacak
(K57 kilidi gereği spec bu oturumda Claude Code tarafından değiştirilmedi).

## Yan etki: `CakismaRozeti` kod düzeltmesi (D1, MRadius.s)

Gerçek G4 koşumunda `radius.s` (`MRadius.s`) MUST token'ının hiçbir yerde
kullanılmadığı görüldü (DESIGN.md §3.1 bu token'ı `CakismaRozeti`'ne atıyor,
ama T6'da bileşen bunu hiç kullanmıyordu — belge ile kod çelişkisi, **kod
düzeltildi**, spec §0: *"Belge ile kod çelişirse kodu düzelt"*).
`src/client/lib/sunum/cakisma_rozeti.dart`: ikon artık `MOlcu.dokunmaHedefi`
boyutunda, `MRadius.s` köşe yuvarlaklığı ve hafif `MRenk.tehlike` tonlu bir
`Container` içinde (48dp dokunma hedefi de A11Y‑1'e hazırlık). Düzeltme sonrası
`flutter analyze` (0 bulgu) ve `flutter test` (20/20) yeniden koşuldu, ikisi de
YEŞİL.

`renk.yuzey.ikincil` ve `hareket.hizli` (BD-7'nin diğer iki adı) hâlâ kodda
hiç kullanılmıyor ama **MUAF listesinde** oldukları için D1 artık onlara
dokunmuyor (TAM MUAFİYET — kullanım şartı yok, spec: *"meşru yerleri
tema.dart'tır"*).

## Durum

T8'in üç aracı da golden-kümesinde kanıtlandı (K44-a). G2, G3, G4 gerçek
koşumda TEMİZ. **T8 KAPANDI, açık borç bırakılmadı. Sıradaki: T9.**
