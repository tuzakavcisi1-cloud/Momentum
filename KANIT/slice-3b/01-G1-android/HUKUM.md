# G1 — MCP KAPISI — ANDROID (F1: 3 gerçek ayak + 1 ön koşul)

**Koşum:** `flutter run -d emulator-5554 --dart-define=ENABLE_FLUTTER_DRIVER=true --dart-define=DURUM_VITRINI=true --print-dtd` (emulator `tuzak_api34`, AVD, cold boot).
**Ön koşul:** `dtd -> listDtdUris` yerine doğrudan `dtd -> connect` (DTD URI koşum
çıktısından okundu: `ws://127.0.0.1:54319/IJEDqwtamaM=`). Bağlantı başarılı,
uygulama otomatik keşfedildi (`Kind: Flutter - Device: sdk gphone64 x86 64 - Package: client`).

## A1 — `flutter_driver_command` → `screenshot`
**SONUÇ: GEÇTİ.** İlk çağrı 5000ms varsayılan timeout'ta zaman aşımına uğradı
(muhtemelen ilk JIT/isolate ısınması); 20000ms ile tekrar edildi ve **gerçek
bir PNG döndü**. Görüntü durum vitrinini doğru çiziyor: "Henüz görev yok..."
başlığı, "Yükleniyor" spinner'ı, `Sut al`/`Ekmek al`/`Faturaları öde`
(çizili)/`Kitap oku` satırları + doğru rozetler (saat ikonu, dönen ok,
bulut-kapalı ikonu), `Toplantı hazırla` satırında çakışma rozeti, ve alt
kısımda "Bir şeyler ters gitti." + "Yeniden dene" (hata durumu). `ErrorWidget`
YOK, görüntü boyutu cihaz çözünürlüğüyle uyumlu (sahte-yeşil koruması geçti).

## A2 — `widget_inspector` → `get_widget_tree` (`summaryOnly: true`)
**SONUÇ: GEÇTİ — v6/F0C3A75A'ya göre YENİDEN ÖLÇÜLDÜ (bu koşum).** Önceki
sürüm (F. 6056A5BB / 79A53AA3 / BE4581BA / 1AB02B73 altında yazılmış) TEK
yakalamaya (yalnız durum vitrini) dayanıyordu ve `GorevEkleAlani` ile
`GorevListesiEkrani`'yi hiç göstermiyordu — vitrin bu ikisini hiçbir zaman
içermez (`durum_vitrini.dart` `GorevListesiEkrani`'yi import bile etmez).
Spec artık **İKİ bağımsız yakalamanın BİRLEŞİMİNİ** şart koşuyor (GOREV
satır 176/295). Bu koşumda ikisi de ayrı ayrı çalıştırılıp ham JSON olarak
kaydedildi:

- **Vitrin** — `flutter run -d emulator-5554 --dart-define=ENABLE_FLUTTER_DRIVER=true --dart-define=DURUM_VITRINI=true --print-dtd` → `widget_inspector get_widget_tree summaryOnly=true` → ham çıktı **olduğu gibi** [widget-tree-vitrin.json](widget-tree-vitrin.json) (16.772 bayt, kırpılmadı).
- **Gerçek ekran** — aynı koşum `--dart-define=DURUM_VITRINI` OLMADAN (gerçek `GorevListesiEkrani`, gerçek Drift veritabanı) → aynı komut → ham çıktı **olduğu gibi** [widget-tree-gercek-ekran.json](widget-tree-gercek-ekran.json) (5.672 bayt, kırpılmadı). Ekranda önceki bir G6 kanıt koşumundan kalma gerçek bir görev (`"G6 android kaniti"`) zaten vardı; bu satır `GorevSatiri`+`SenkronRozeti`'yi gerçek ekranda da görünür kıldığından ayrıca görev eklemeye gerek kalmadı (bir ekleme denendi — `Ekle` semantics etiketine `tap` — ama zaman aşımına uğradı ve veritabanına hiçbir yeni görev **eklenmedi**; `get_runtime_errors` bu koşumda da temiz döndü).

**8 sınıfın birleşim kapsama tablosu** (her satır ilgili JSON dosyasındaki `"widgetRuntimeType":"…"` alanına ve `valueId`'sine atıflıdır):

| Sınıf | Dosya | Adet | `valueId` örnekleri |
|---|---|---|---|
| `BosDurum` | widget-tree-vitrin.json | 1 | `inspector-16` |
| `CakismaRozeti` | widget-tree-vitrin.json | 1 | `inspector-58` |
| `GorevEkleAlani` | widget-tree-gercek-ekran.json | 1 | `inspector-8` |
| `GorevListesiEkrani` | widget-tree-gercek-ekran.json | 1 | `inspector-3` |
| `GorevSatiri` | widget-tree-vitrin.json | 5 | `inspector-10,11,12,13,14` |
| `GorevSatiri` | widget-tree-gercek-ekran.json | 1 | `inspector-13` |
| `HataDurumu` | widget-tree-vitrin.json | 1 | `inspector-23` |
| `SenkronRozeti` | widget-tree-vitrin.json | 4 | `inspector-64,67,70,73` |
| `SenkronRozeti` | widget-tree-gercek-ekran.json | 1 | `inspector-30` |
| `YuklenmeDurumu` | widget-tree-vitrin.json | 1 | `inspector-17` |

**8/8 sınıf birleşimde kapsandı → KAPI YEŞİL.** (Tablo `python` ile iki dosya üzerinde mekanik `"widgetRuntimeType":"<Sınıf>"` taraması yapılarak üretildi — elle sayılmadı.)

🔴 **BEYAN EDİLMİŞ ARTIK DOSYA:** bu dizindeki eski `widget-tree.json` (345 bayt, JSON DEĞİL — kendine "Ham JSON: widget-tree.json" diye atıf yapan proza) artık **hiçbir A2 iddiasının kaynağı değildir** ve yukarıdaki iki dosyayla değiştirilmiştir. Silinmedi (kalıcı silme bu oturumun yetkisinde değil — Onur'un elle kaldırması gerekir).

## A3 — `get_runtime_errors`
**SONUÇ: GEÇTİ (temiz).** "No runtime errors found." — bkz. `A3-runtime-errors-temiz.txt`.
M3 mutantı altında bu ayağın DOLU döndüğü ayrıca ölçülecek (bkz. `M3.txt`).

## HÜKÜM
**G1 Android: 3/3 ayak + ön koşul GEÇTİ.**
