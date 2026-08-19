# IS-EMRI-o85-A — CEVAP (SS9, 6 madde)

**1) schemaVersion 8 + migration blok metni + v7 dump ne zaman alındı**
`lib/veri/veritabani.dart:201`: `int get schemaVersion => 8;` (önceki 7).
v7 dump'ı (`drift_schemas/drift_schema_v7.json`) bu iş emrinden ÖNCE, 2026-08-15
10:28:40 +0300'te commit'lenmişti (`git log -1 --format='%ai' -- ...v7.json`);
bu iş emri v1..v7 migration bloklarına DOKUNMADI (yalnız `newColumns`
listesine `gorevler.projeId` EKLENDİ — v1 yolu, `alterTable` GÜNCEL Dart
tanımını kullandığı için gerekli). Tam migration blok metni (221 satır, 80
satır) `KANIT/o85A/01-sema-v8-migration.txt`'te birebir.

**2) `Projeler`'in nihai sütun listesi**
`id` (TextColumn, PK) · `ad` (TextColumn) · `silindi` (BoolColumn, varsayılan
`false`) · `olusturuldu` (DateTimeColumn). **`pos` YOK, `renk`/color YOK**
(K1/K3 — ölü sütun doktrini, bu dilimde ekranı olmayan sütun açılmadı).

**3) `changesUygula`'nın tam dal kodu (3 dal)**
`lib/senkron/uzak_degisiklik_uygulayici.dart:98-260`. Her `fields`/`groups`
girdisi için: `entityType=='Task'` → `g` (mevcut `_kanalUygula`, DEĞİŞMEDEN)
· `entityType=='Project'` → `pg` (yeni `_projeKanalUygula`, ayrı havuz) ·
başka her `entityType` → yalnız `_metaDepo.degerlendirVeMetaYaz` (projeksiyona
YAZILMAZ, bugünkü davranışla AYNI). Aynı 3'lü dal `snapshotUygula`'da da var
(C2). `order` kanalı için (`payload['order']`) gerçek bir tel örneği bu
dilimde ÖLÇÜLMEDİ (backend `WireOp.Order` daima null geldi) — kod bunu
`fields`'la AYNI per-alan biçim VARSAYARAK `_metaDepo`'ya yazıyor, projeksiyona
DEĞİL (satır 217-239, açık yorum).

**4) `ekle`'nin yeni imzası + kaç çağrı yeri güncellendi**
```dart
Future<void> ekle(
  String baslik, {
  int? oncelik,
  DateTime? sonTarih,
  Set<String> etiketler = const {},
  String? projeId,
});
```
`projeId` isteğe bağlı (varsayılan `null`) olduğu için mevcut çağrı yerleri
DEĞİŞMEDEN derlenmeye devam etti; güncellenen siteler: **12 sahte
`GorevDeposu` override'ı** (11 dosya + `a11y_kapisi_test.dart`'ta 2 sınıf —
DURUM.md sınır 18'in gereği) + **1 yeni sahte depo** (`liste_baglam_test.dart`,
D4 testi için) + **1 üretim çağrı yeri** (`gorev_listesi_ekrani.dart:~`,
`projeId: etkinSecim` geçirir) = **14 site**.

**5) `flutter analyze` + `flutter test` sayısı (src/client'tan koşuldu)**
`flutter analyze`: **No issues found!** (80.6s). `flutter test`: **749/749
geçti**, 0 başarısız (`All tests passed!`) — bkz.
`KANIT/o85A/05-flutter-test-tam-kosum.txt` (repo kökü DEĞİL, `src/client`'tan;
kök yalan söyler, mayın 1).

**6) `git status --porcelain -- src tests` (commit ÖNCESİ, path-belirtilmiş
`git add`'den önceki ham durum)**
Aşağıda birebir — `KANIT/slice-3c/02-G2/*.json` (mayın 19, her `flutter test`
koşumunda YENİDEN YAZILIR) **BİLEREK path'e dahil edilmedi**, commit'e
GİRMEYECEK:
(`git --no-optional-locks status --porcelain -- src tests`, birebir, `tests/`
.NET klasörü DEĞİŞMEDEN temiz döndüğü için hiç satır üretmedi):
```
 M src/client/lib/design/metinler.dart
 M src/client/lib/senkron/uzak_degisiklik_uygulayici.dart
 M src/client/lib/sunum/bos_durum.dart
 M src/client/lib/sunum/gorev_listesi_ekrani.dart
 M src/client/lib/sunum/gorev_satiri.dart
 M src/client/lib/veri/gorev_deposu.dart
 M src/client/lib/veri/veritabani.dart
 M src/client/lib/veri/veritabani.g.dart
 M src/client/test/a11y_kapisi_test.dart
 M src/client/test/a11y_statik_tasma_test.dart
 M src/client/test/arama_dilimi_test.dart
 M src/client/test/dogal_dil_ekleme_test.dart
 M src/client/test/etiket_ui_test.dart
 M src/client/test/g11_rozet_turetme_kapisi_test.dart
 M src/client/test/g16_metin_kaybi_kapisi_test.dart
 M src/client/test/g2_migration_kapisi_test.dart
 M src/client/test/g34_cakisma_ekrani_test.dart
 M src/client/test/generated_migrations/schema.dart
 M src/client/test/gorev_listesi_cikis_test.dart
 M src/client/test/oncelik_son_tarih_test.dart
 M src/client/test/sunum_bilesenleri_test.dart
 M src/client/test/w2_depolama_seridi_test.dart
 M src/client/test/yerel_yazma_itme_tetikleyicisi_test.dart
?? src/client/drift_schemas/drift_schema_v8.json
?? src/client/test/generated_migrations/schema_v8.dart
?? src/client/test/liste_baglam_test.dart
?? src/client/test/liste_dilimi_test.dart
```
`src/backend/**` satırı YOK — dokunulmadı, DEMİR KURAL uyuldu.
`KANIT/slice-3c/02-G2/*.json` bu listede YOK çünkü sorgu `-- src tests`
yoluyla sınırlıydı (o dosyalar `KANIT/` altında, ne `src` ne `tests`); ayrıca
commit'e path-belirtilmiş `git add`'le girmeyecekler (mayın 19).
