# T9 — KAPILAR VE MUTANTLAR — ilerleme özeti (oturum 31)

## Durum: Sınıf A + Sınıf B TAMAM (21/23 mutant). Sınıf C (3) kaldı.

Sıralama PAZARLIKSIZ (K53): **A (statik) → B (widget) → C (koşan uygulama)**.
A ve B bitti, ikisi de gerçek kodda uygulanıp geri alındı, her biri kırmızı
çıktısıyla `KANIT/slice-3b/03-G2/`, `04-G3/`, `05-G4/`, `06-G5/`, `08-G7/`
altında kanıtlı. Her mutant sonrası `flutter analyze` (0 bulgu) + tam
`flutter test` (36/36 yeşil) ile regresyon doğrulandı.

## Sınıf A — statik (11/11)

| # | mutant | kapı | sonuç |
|---|---|---|---|
| M1 | MUST sembolü sil (`MRenk.tehlike`) | G4/D3 | ISIRDI |
| M2a | Ham renk literali | G4/D2 | ISIRDI |
| M2b | Aynı literal çok satırlı yorumda | G4/D2 sınırı | ISIRDI (spec "ısırmayabilir" diyordu; ısırması da kabul — sebep: per-satır yorum ayrıştırıcı çok satırlı bloğu tanımıyor) |
| M8 | `dio 4.0.6` enjekte (gerçek pub.dev) | G2 | ISIRDI — **ve gerçek bir hata buldu**: OSV event ayrıştırma "anahtar var mı" kontrolü yapıyordu, "değer null mı" değil; pub.dev'in gerçek `/advisories` şeması her event'te dört anahtarı da (bazıları null) taşıyor → gerçek CVE'ler sessizce kaçıyordu. **Düzeltildi**, golden küme + gerçek koşum yeniden doğrulandı |
| M11 | Gerçek GPL-3.0 paket (`iconsax`) enjekte | G3 | ISIRDI |
| M12 | `Theme.of(context)` bileşende | G4/D5 | ISIRDI |
| M14 | `licenses` boş (fixture) | G3 | ISIRDI |
| M20 | `cupertino.dart` importu | G4/D6 | ISIRDI |
| M21 | MUST token kullanımını `tema.dart`'a taşı | G4/D1 sıkılaştırma | ISIRDI |
| M22 | `DESIGN.md` kopyasında tokens satırı boz | G4/D0 | ISIRDI (`araclar/fixture/DESIGN-M22-kopya.md`, `DESIGN.md`'nin kendisi dokunulmadı, kimlik doğrulandı) |
| M23 | Gerekçesiz `[DESIGN-LITERAL]` | G4/D4 | ISIRDI |

## Sınıf B — widget testi (10/10)

| # | mutant | kapı | sonuç |
|---|---|---|---|
| M5 | Dokunma hedefi 32dp | G5/A11Y-1 | ISIRDI |
| M6 | `disableAnimations` kontrolü kaldır | G5/A11Y-5 | ISIRDI |
| M7 | `CakismaRozeti` semantics etiketi sil | G5/A11Y-3 | ISIRDI |
| M10 | Ham dizge (`Metinler.bosDurum` yerine) | G5/metin | ISIRDI — **yeni statik kontrol yazıldı** (widget testi görsel eşleşmeyle bunu yakalayamaz, kaynak taraması gerekti) |
| M13 | `silindi=false` filtresini kaldır | G7 | ISIRDI |
| M15 | Odak halkası kalınlığı 0 | G5/A11Y-2 | ISIRDI |
| M16 | Sabit yükseklik + `maxLines:1`, overflow silinmiş | G5/A11Y-4 statik | ISIRDI — statik kontrol `maxLines` tek başına yeterli SANIYORDU, düzeltildi (yalnız `overflow: TextOverflow.ellipsis` yeterli sayılır) |
| M17 | Çevrimdışı rozetinden metin düğümü sil | G5/A11Y-6 | ISIRDI — testin kendisinde **iki gerçek kusur** bulundu ve düzeltildi: (1) tüm `GorevSatiri` satırı taranıyordu, başlık metni rozetin metnini taklit ediyordu; (2) `CakismaRozeti`'nin görünür `Text`'i yok, yalnız `Semantics(label:)` var — spec zaten "semantics ağacında" diyor, widget ağacı değil |
| M18 | Semantics duyurusunu kaldır | G5/A11Y-7 | ISIRDI |
| M19 | `renk.metin.ikincil`'i yüzeye yaklaştır | G5/kontrast | ISIRDI |

## Yan etki: gerçek kod/test düzeltmeleri (bu oturumda bulunup kapatıldı)

1. `CakismaRozeti`: `MRadius.s` hiç kullanılmıyordu (D1) → rozet artık
   `MRadius.s` köşe yuvarlaklığıyla 48dp'lik bir kap içinde.
2. `CakismaRozeti`: "çakışma" durumunda `duyuruCakismaVar` hiç
   gönderilmiyordu (DESIGN.md §4 A11Y-7 gerektiriyor) → `StatefulWidget`'a
   çevrildi, bir kerelik duyuru eklendi.
3. `GorevSatiri`'nin Checkbox'ı semantics etiketi taşımıyordu (A11Y-3) →
   `Semantics(label: gorev.baslik)` ile sarıldı.
4. `GorevSatiri`'nin rozet slotu `Flexible` değildi → 2x metin ölçeğinde
   `RenderFlex` taşması (A11Y-4) → `Flexible` ile sarıldı.
5. `lib/sunum/`'daki 6 `Text()` çağrısı `overflow`/`maxLines` taşımıyordu →
   hepsine `overflow: TextOverflow.ellipsis` eklendi.
6. G2'nin OSV olay ayrıştırma hatası (yukarıda, M8).

## Sınıf C — koşan uygulama (0/3, K53 tavanı: TAM 3)

**Henüz başlanmadı.** M3 (vitrine hata fırlatan widget → `get_runtime_errors`
dolu), M9 (`enableFlutterDriverExtension` çağrısını kaldır → screenshot
başarısız), M4 (`--web-header=` bayraklarını kaldır → kalıcılık `opfs*`
değil) — üçü de gerçek emülatör/tarayıcı + dart MCP (`flutter_driver_command`,
`widget_inspector`, `dtd`) gerektirir. Bu aynı zamanda **G1 kapısının kendisinin**
(3 ayak + ön koşul, Android + Web) ve **G6'nın** (kalıcılık kapısı) İLK kez
gerçek koşumu olacak — T0-T7 bu ikisini henüz koşmadı.

Kullanılabilir emülatör ölçüldü: `tuzak_api34` (AVD, `emulator -list-avds`).
