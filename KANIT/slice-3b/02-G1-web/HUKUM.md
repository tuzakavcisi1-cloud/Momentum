# G1 — MCP KAPISI — WEB (F1: 2 gerçek ayak + 1 ön koşul + 1 ölçülmüş muafiyet)

**Koşum:** `flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp --dart-define=ENABLE_FLUTTER_DRIVER=true --dart-define=DURUM_VITRINI=true --print-dtd`.
**Ön koşul:** `dtd -> connect` (DTD URI koşum çıktısından: `ws://127.0.0.1:49636/IBhCHsyKzqk=`), başarılı, uygulama otomatik keşfedildi.
**Ölçüldü [B-3]:** `-d chrome` ile DTD gerçekten bağlandı — sorun yok, `-d web-server` denenmedi (spec zaten `-d chrome` ile başlamayı söylüyor).

## A2 — `widget_inspector` → `get_widget_tree`
**SONUÇ: GEÇTİ.** Android ile birebir aynı ağaç (8 bileşen adıyla: BosDurum,
YuklenmeDurumu, GorevSatiri, SenkronRozeti, _DonenOk/AnimatedRotation,
CakismaRozeti, HataDurumu).

## A3 — `get_runtime_errors`
**SONUÇ: GEÇTİ (temiz).** "No runtime errors found."

## A1 — muafiyet (Z6), ÖLÇÜLDÜ
İlk denemede `ENABLE_FLUTTER_DRIVER` bayrağı unutulmuş, "extension not enabled"
hatası alınmıştı (bu GEÇERSİZ ölçümdür, bayrak eksikliğinden kaynaklanır).
Bayrak düzeltilip koşum TEKRARLANDI: bu kez extension gerçekten etkindi ama
`screenshot` çağrısı **gerçek bir hata** döndürdü: web (DDC) çalışma zamanında
`dart:io` stderr desteklenmediği için flutter_driver'ın kendi log mekanizması
patlıyor ("Unsupported operation: StdIOUtils._getStdioOutputStream").
Kanıt: `MUAF-kanit.txt`. Z6'nın *"web'de flutter_driver screenshot/tap
desteklenmez"* iddiasıyla birebir tutarlı.

## HÜKÜM
**G1 Web: A2 + A3 GEÇTİ, A1 muafiyeti ÖLÇÜLEREK doğrulandı (iddia edilmedi).**
