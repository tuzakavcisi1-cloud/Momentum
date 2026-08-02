# A11 kriter 7 — "T1+4 s'de kuyruğu KİM boşalttı?" (Cowork, oturum 50, 2 Ağu 2026)

**Devir notunun açık sorusu:** *"4 s'de boşaldı" retry'ı KANITLAMIYOR.*
Soru haklıydı; cevabı **zamanlamayla değil, YOLLARI SAYARAK** verilebiliyor.

## Ölçülen olgular

1. `KANIT/cevrimdisi-senkron/_a11-e2e-log3-final.txt`
   `T0` (çevrimdışı onaylandı, `nc`) = **21:47:24** · `T1` (çevrimiçi onaylandı, `nc`) = **21:50:30**
   yoklama 1 (`T1+1 s`) = 0 · yoklama 2 (`T1+4 s`) = **2** ⇒ boşalma anı ≈ `T0+190 s`.
2. `KANIT/cevrimdisi-senkron/_a11-flutter-run-stdout.log:1589-1604` — çevrimdışı pencerede
   `[sinyal] baglanti koptu: ... Network is unreachable, errno = 101` (6 kez), `T1` sonrası
   **`[sinyal] el sikisma basarili -- SinyalBaglandi yayinlaniyor`** (3 kez).
   🔴 Aynı pencerede **`[sinyal] Changed alindi` HİÇ YOK** — sunucudan değişiklik sinyali gelmedi.
3. Uygulama PID koşum boyunca **aynı** (`18440`) ⇒ yeniden başlatma **olmadı**.

## Kuyruğu boşaltabilecek YOLLARIN TAMAMI (kod okundu, sayıldı)

| yol | çağırdığı | kuyruğu İTER Mİ | bu koşumda mümkün mü |
|---|---|---|---|
| SignalR sinyali — `main.dart:149` `sinyal.olaylar.listen((_) => unawaited(dongu.cekmeTuruCalistir()))` | **`cekmeTuruCalistir()`** | 🔴 **HAYIR** | olay geldi ama **itemez** |
| Açılış — `main.dart:55-56` | `turCalistir()` | evet | 🔴 hayır (PID değişmedi) |
| `elleYenile` ("Yenile" düğmesi) — `main.dart:93` | `turCalistir()` | evet | 🔴 hayır (dokunulmadı) |
| `onYerelYazma` (yeni görev) — `main.dart:81` | `turCalistir()` | evet | 🔴 hayır (dokunulmadı) |
| **`ItmeYenidenDeneme` zamanlayıcısı** — `senkron_dongusu.dart:78-80` | `turCalistir()` | evet | ✅ **tek kalan yol** |

🔴 **Sinyal yolunun kuyruğu itememesinin MEKANİK sebebi** (`senkron_dongusu.dart`,
`_yuvarlakDongusu`): `final secilenler = kuyrugaBak ? await _bekleyenleriSec() : const <SenkronKuyruguRow>[];`
⇒ `cekmeTuruCalistir()` **`kuyrugaBak: false`** ile çağrılır, `_istekGovdesiOlustur([])`
gövdeyi `"ops":[]` kurar ve **hiçbir bekleyen op sunucuya gitmez**.

## Zamanlama TUTARLILIK kontrolü (kanıt değil, yanlışlama)

Çizelge `2·5·15·30·60·60…`, jitter ±%20 ⇒ 6. denemenin kümülatif anı **137–206 s** aralığında.
Ölçülen boşalma `T0+190 s` bu aralığın **içinde**. ⇒ retry hipotezi zamanlamayla **çürümüyor**.
🔴 **Ama zamanlama tek başına AYIRT ETMEZ** (aralıklar örtüşüyor) — hükmü veren yol sayımıdır.

## HÜKÜM

✅ **Kriter 7'nin tetikleyicisi A11'in `ItmeYenidenDeneme` zamanlayıcısıdır.** Kuyruğu itebilen
diğer üç yolun üçü de bu koşumda **fiilen imkânsızdı**, SignalR yolu ise **yapısal olarak** kuyruğu
itemez. Devir notundaki açık soru **KAPANDI**.

🔴 **BEYAN EDİLMİŞ SINIR — bu izolasyon KOD OKUMASIYLA yapıldı, KAPI İLE DEĞİL.**
`main.dart`'taki sinyal dinleyicisinin `cekmeTuruCalistir` yerine `turCalistir` çağırmaya
dönmesini ölçen **hiçbir mekanik kapı yok**: `yoklama-yasagi-kapisi.py` `Y1`'i yalnız
`Timer`/`Future.delayed` çağrılarının kapsayan gövdesinde arar, `main.dart:149` bir **stream
dinleyicisidir** ve o taramaya hiç girmez. Bugün doğru olan bu satır yarın sessizce değişirse
kriter 7'nin bu kanıtı **bayatlar ve kimse görmez**. Sınıf: `kör kapı`. **Borç.**
