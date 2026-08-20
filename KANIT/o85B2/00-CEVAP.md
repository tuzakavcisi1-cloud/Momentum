# IS-EMRI-o85B2 -- CEVAP (dort satir, s5)

## 1. M3a ONCE yesil / SONRA kirmizi + M3b kirmizisi + null bolmesi sirasinin gerekcesi

**M3a ONCE** (`01-mutant-M3a-KAPISIZ-yesil.txt`, test genisletilmeden ONCE alindi): ucuncu keyset
kolu (`OR (@cursorPos::text IS NULL AND (pos IS NULL AND entity_id > @cursorId::uuid))`) tamamen
silindi, **73/73 yesil kaldi** -- denetimin iddiasi dogrulandi, o kol bugun hicbir testte kosmuyordu.
Test genisletildikten (A2) **SONRA** ayni mutant yeniden uygulandi: `Project_read_endpoint_...`
**KIRMIZI** dustu (`02-mutant-M3a-KIRMIZI.txt`: `collected.Count` 6 beklenirken 4 -- imlec null
bolmesine girer girmez sayfalama durdu). **M3b** (`entity_id > @cursorId` -> `>=`) de KIRMIZI
(`03-mutant-M3b-KIRMIZI.txt`: `collected.Count` 6 beklenirken 8 -- cursor satiri tekrar donuyor).
Ikisi de geri alindi (`06-src-bayt-ozdes.txt`).
**Null bolmesi sirasi**: `projectEntity` + 2 yeni proje, UCU DE `Guid.CreateVersion7(DateTimeOffset.
FromUnixTimeMilliseconds(Wire.BaseWall + i))`, `i=0,1,2` -- tek monoton seriden, `Guid.NewGuid()`
(v4) KARISTIRILMADI. Deterministik cunku: Postgres UUIDv7'yi bayt sirasinda karsilastirir ve
`Wire.BaseWall + i` KESINLIKLE artan milisaniyeler uretir (`D0c` testinin ayni gerekcesi, ayni
dosyada) -- uretim sirasi = Postgres `ORDER BY entity_id` sirasi, ayrica RASTGELE v4 araya girip
sirayi belirsizlestirmez.

## 2. D6 cipasinin yeni docstring'i + adi + `case "Project": break;` mutantinda kirmiziya donusu

**B1 olcumu** (kod yazmadan once): `"D6_out_of_scope"` dizgesi `.github/`, `araclar/`, `verify.ps1`
icinde **GECMIYOR** ⇒ ad **DEGISTIRILDI**: `D6_out_of_scope_entity_types_produce_zero_new_rows` ->
**`D6_Tag_kapsam_disi_sifir_satir_Project_ise_materyalize_edilir`**.
**Yeni docstring**: *"D6 [kapsam çıpası]: `Tag` kapsam dışıdır -- üç eski materyalize tabloda sıfır
satır. `Project` IS-EMRI-o85-B ile kapsama GİRDİ: `projects` tablosuna tam bir satır yazar (pozitif
kontrol)."* Sinif-duzeyi ozet de duzeltildi ("MUTANTSIZ" iddiasi artik yalniz D7/D8 icin gecerli).
Test artik iki NAMED degiskenle (`projectEntity`, `tagEntity`) yaziyor ve iki pozitif kontrol
ekliyor: `SELECT count(*) FROM projects WHERE entity_id=@e` = 1, `SELECT count(*) FROM projects`
= 1 (Tag satir dogurmadi). `EntityMaterializer`de `case "Project": await MaterializeProjectAsync(...)`
-> `case "Project": break;` mutantinda test **KIRMIZI** dustu (`04-mutant-D6-KIRMIZI.txt`:
`count(*) FROM projects WHERE entity_id=@e` 1 beklenirken 0) -- cipa artik gercekten isirir.
Mutant geri alindi.

## 3. `git --no-optional-locks diff --stat c50796f -- src` (ham cikti)

```
(BOS)
```

Urun kodu **bayt-ozdes** -- `06-src-bayt-ozdes.txt`te ayrica dogrulandi (tum mutantlar tek tek geri
alindiktan SONRA alinan olcum).

## 4. `verify.ps1` EXIT + test sayisi

**EXIT 0** (`05-verify-ps1.txt`: build 0 uyari/0 hata, CVE gate temiz).
Test sayisi: **144 -> 144** (degismedi, beklendigi gibi -- yeni `[Fact]` YOK, mevcut ikisi
genisledi/adi degisti: `git diff c50796f -- tests` icinde `+.*\[Fact\]` sayisi **0**).
`Momentum.ArchitectureTests` 5 · `Momentum.SyncCore.Tests` 44 · `Momentum.Api.Tests` 22 ·
`Momentum.Persistence.Tests` 73 -- dordu de 0 basarisiz.
