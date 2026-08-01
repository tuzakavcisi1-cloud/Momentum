# 09-HUKUM.md — GOREV-A8 (v2) · builder'ın kendi hükmü

> 🔴 Bu bir **Cowork onayı DEĞİLDİR** — K26 gereği builder'ın kendi beyanıdır; Cowork kendi
> denetimini (Desktop Commander ile gerçek FS'ten) koşmadan bunu **KABUL ETMEZ**.

**Kim:** Claude Code · **Ne zaman:** 1 Ağu 2026, oturum 42 (spec kilidi K90'ın hemen ardından) ·
**Hangi spec:** `GOREV_CLAUDE_CODE/GOREV-A8-metin-kaybi-gercek-ekranlar.md`

## Kabul kriterleri — sırayla, atlanmadı

| # | Kriter | Sonuç | Kanıt |
|---|---|---|---|
| 1 | G16 önce KIRMIZI, DUR şartı yalnız A1'e bağlı | ✅ A1 36 noktanın **20**'sinde ısırdı (Y2 9/9, Y3 8/9, Y4 2/9, Y5 1/9) — DUR **tetiklenmedi** | `00-ONCE-KIRMIZI.txt` (65 kırmızı: A1=20, A2=45) |
| 2 | maxLines ölçümü, tavan 8 | ✅ 320dp×2.0x: Y2=6, Y3=4, Y4=2, Y5=2 — hepsi ≤8, DUR **tetiklenmedi** | `00-OLCUM.txt` |
| 3 | Ürün değişikliği (5 Text + adlandırılmış sabitler) | ✅ `kGorevSatiriBaslikMaxSatir=1` · `kBosDurumMaxSatir=6` · `kHataDurumuMesajMaxSatir=4` · `kYenidenDeneMaxSatir=2` · `kYuklemeDurumuMaxSatir=2` | 4 dosya diff'i (§ altta) |
| 4 | G16 sonra YEŞİL | ✅ 162/162 | `01-SONRA-YESIL.txt` |
| 5 | M88–M97 (10 mutant) beklendiği gibi | ✅ hepsi doğrulandı (M96/M97 tersten okunur: sustular) | `02-MUTANT/M88.txt`…`M97.txt` |
| 6 | Regresyon (a11y_statik_tasma · a11y_kapisi · sunum_bilesenleri · g13/g14/g15) | ✅ 122/122, **en riskli nokta** (a11y_kapisi_test.dart:313-318, vitrin textScale 2.0, RenderFlex riski S8) dahil — DUR **tetiklenmedi** | `06-REGRESYON.txt` |
| 7 | `flutter analyze --fatal-infos` | ✅ EXIT 0, "No issues found!" | `04-ANALYZE.txt` |
| 8 | `flutter test` tamamı yeşil, sayı ölçülür | ✅ **428/428** (A-7 tabanı 266 + G16'nın 162'si = 428, ölçüldü, uydurulmadı) | `03-TEST.txt` |
| 9 | `design-token-kapisi.py` | ✅ EXIT 0, "TEMIZ" | `05-DESIGN-TOKEN.txt` |
| 10 | `spec-kapi-kapsama.py` (dosya yoluyla, K81) | ✅ EXIT 0 — KAPI(1): G16 · MUTANT(10): M88-M97 · BULGU YOK | `_SILINECEKLER/06-SPEC-KAPSAMA.txt` (bu dizin **dışında**, dairesel kanıt) |
| 11 | `iddia-kapisi.py --kanit KANIT\A8` | ✅ EXIT 0, **KANITLI MUTANT (10)**: M88…M97 birebir | `07-IDDIA.txt` |
| 12 | `git status` ölçümü, `git add -A` yasak | ✅ 4 üretim dosyası değişti + yeni KANIT/A8 + yeni test dosyaları; kilit yok | `08-GIT-STATUS.txt` |
| 13 | BORCLAR.md kapanış maddesi (cakisma_rozeti.dart:77,82) | ✅ **zaten mevcuttu** — Cowork bunu K90 kilidinde spec ile birlikte yazmış (`BORCLAR.md:35-36`); build tarafında ek işlem gerekmedi | `BORCLAR.md:35-36` |

## Ürün değişikliği (kriter 3) — dosya dosya

- `lib/sunum/gorev_satiri.dart` — `_baslik()`'e `maxLines: kGorevSatiriBaslikMaxSatir` (=1, **sabit**, ölçülmedi — S1).
- `lib/sunum/bos_durum.dart` — `Text`'e `maxLines: kBosDurumMaxSatir` (=6, ölçüldü).
- `lib/sunum/hata_durumu.dart` — mesaj `Text`'ine `maxLines: kHataDurumuMesajMaxSatir` (=4) ve `TextButton`'ın `Text`'ine `maxLines: kYenidenDeneMaxSatir` (=2), ikisi de ölçüldü.
- `lib/sunum/yukleme_durumu.dart` — `Text`'e `maxLines: kYuklemeDurumuMaxSatir` (=2, ölçüldü).
- `overflow: TextOverflow.ellipsis` **hiçbirinde dokunulmadı** (a11y_statik_tasma_test'in zorunlu kıldığı gibi). `MBosluk`/`MTipo`/`MRenk` token'larına dokunulmadı (D0 — design-token-kapisi.py bunu doğruladı).

## Build sırasında bulunan ve düzeltilen İKİ kendi kusurum (gizlenmedi, kayda geçirildi)

1. **G16 harness'inin kendi RenderFlex tasması (Y1, 411dp×2.0x).** İlk yazımda `SizedBox(height: h)`
   TIGHT yükseklik veriyordu; `GorevSatiri`'nin kökü `Container` (Y2-Y5'in `Center` kökünün aksine)
   bunu gevşetmiyordu ve `mainAxisSize.min` Column'la çarpıştı. Ayrıca `Scaffold` eksikti (Checkbox
   `Material` atası ister). İkisi de düzeltildi (loose `ConstrainedBox(maxHeight:)` + `Scaffold`,
   G13/G14 ile aynı desen) — kod DEĞİL, yalnız test harness'i.
2. **Ölçüm dosyasının (`_a8_olcum_test.dart`) kendisi İKİ KEZ yanlış ölçtü**, ikisi de mekanik prob
   ile (denetimle değil) bulundu: (a) companion `TextPainter` ellipsis taşımıyordu, Y5'i olduğundan
   dar ölçtü; (b) `Scaffold`/`Material` yoktu, `DefaultTextStyle` (letterSpacing dahil) hiç
   uygulanmıyordu. Düzeltmeden sonra Y5@320dp×2.0x = 2 satır çıktı ve bu, G16'nın gerçek
   `didExceedMaxLines=true` bulgusuyla **birebir çapraz doğrulandı**. Tam anlatım
   `_a8_olcum_test.dart`'ın kendi başlık yorumunda.

## Kalıcı olmayan test dosyaları (temizlik notu — silinemedi, boşaltıldı)

`test/_a8_olcum_test.dart` ve `test/_a8_probe_test.dart` bu oturumda ölçüm için yazıldı; işleri
bitince **boşaltıldı** (`void main() {}`, 0 test) — bu ortamda `rm`/`Remove-Item` **izinli değil**
(CLAUDE.md güvenlik kuralı: "bir dosyayı kaldırman gerekiyorsa YAPMA, kullanıcıya bildir"). Onur
isterse bu iki dosyayı elle silebilir; bırakılmaları test sayısını **etkilemiyor** (0 test) ve aynı
desen `BORCLAR.md`'de zaten kayıtlı ("_ önekli iki ölü test, `void main(){}`").

## BEYAN EDİLMİŞ SINIRLAR (spec §8'den, build'in doğruladığı/doğrulamadığı)

- **S1-S9 spec'te yazılı — build bunları ÇÖZMEDİ, spec'in izin verdiği kapsamda BIRAKTI.**
  Özellikle **S8** (Y2-Y5'in dikey büyümesi) kriter 6'da **koşan kodla ölçüldü** ve regresyon
  **kırılmadı** — ama bu S8'i kapatmaz, yalnız bu build'de **görünür bir kırılma olmadığını** kanıtlar.
- **PUSH ONUR'DA** — bu oturum commit/push YAPMADI, yalnız çalışma ağacında bıraktı (kriter 12
  yalnız `git status` **ölçümünü** ister).

## HÜKÜM

**13/13 kriter geçti, hiçbir DUR şartı tetiklenmedi.** G16 kapısı hem önce-kırmızı hem sonra-yeşil
kanıtlı, 10 mutantın hepsi kanıtlı (`iddia-kapisi.py` bunu bağımsız doğruladı), regresyon zinciri
(en riskli nokta dahil) yeşil, `analyze`/`design-token-kapisi`/`spec-kapi-kapsama` temiz.
**Cowork'ün bağımsız denetimini BEKLER** (K26) — bu belge yalnız builder'ın kendi beyanıdır.
