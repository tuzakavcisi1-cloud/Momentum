# ④ ÇEVRİMDIŞI → KUYRUK → ÇEVRİMİÇİ → SENKRON (oturum 49, 2 Ağu 2026)

**Kapsam (Onur kilitledi):** `③`'ün kalanından **çevrimdışı** ayağı. Çakışma rozeti ve çift yönün
kabul kriterleri **bu turda ölçülmedi**. **Koşan el:** Cowork (K26 — build Claude Code'undu,
ölçüm denetleyenindir). Ham veri: `19-rapor.json`.

## Ölçüm aracının kendisi önce kanıtlandı (FAZ A / A-2)

🔴 **`airplane_mode_on` BİR ÖLÇÜM DEĞİLDİR — bayraktır.** İki yönde de ölçüldü:
uçak modu **açılınca** TCP 5298 **0,7 s**'de düştü ama `ping` **3,3 s** gecikti;
**kapanınca** bayrak 0,5 s'de `0` dedi, gerçek erişim **~12 s** sonra geldi (ilk koşum) /
**4,4 s** (asıl koşum). ⇒ Kapı olarak **uygulama katmanı probu** seçildi:
`toybox nc -w 2 10.0.2.2 5298`. `curl` cihazda **yok** (`/system/bin/nc` var).

🟢 **Sabit koordinat borcu KAPANDI.** Oturum 48 arayüzü `463,2153` gibi sabit noktalarla sürüyordu
ve *"yerleşim değişirse betik sessizce ıskalar"* diye borç yazmıştı. Bu turda öğeler
`uiautomator dump`'tan **`content-desc`/`class` ile bulunuyor** (`Ekle`, `Yenile`, `EditText`);
türetilen merkezler eski sabitlerle **birebir aynı** çıktı — yani borç, davranış değiştirmeden kapandı.

## KANITLANAN

| ayak | ölçülen |
|---|---|
| Çevrimdışına geçiş | TCP 5298 **0,5 s**'de düştü |
| Çevrimdışı CRUD | `OFF1`, `OFF2` **eklendi**, yerelde kaldı |
| Rozet | *"Çevrimdışısınız. Değişiklikler kaydedildi."* — iki satırda da |
| 🔴 **Sızıntı kapısı** | **30 s** boyunca API'de **görünmedi** (`14-api-cevrimdisi.json`) |
| Çevrimiçiye dönüş | TCP **4,4 s** sonra geri geldi |
| Senkron sonrası | API: `[…, OFF1, OFF2]` · ekranda **rozetsiz** (`17-api-senkron-sonrasi.json`) |

## 🔴 BULGU — AĞ GERİ GELDİĞİNDE KUYRUK KENDİLİĞİNDEN BOŞALMIYOR

| ayak | sonuç |
|---|---|
| **A** — ağ geldi, uygulamaya **hiç dokunmadan 90 s** | **GELMEDİ** |
| **B** — *"Yenile"*ye basıldı | **2,2 s**'de geldi |
| C — yeniden başlatma | (B çözdüğü için koşmadı) |

**Kök neden koddan ölçüldü, tahmin edilmedi.** `turCalistir()` (**itme**) yalnız **üç** yerden
tetikleniyor: `main.dart:55` (açılış) · `main.dart:81` `onYerelYazma` (K113) · `main.dart:94`
`elleYenile` (*Yenile* düğmesi). `main.dart:150` sinyal dinleyicisi **yalnız `cekmeTuruCalistir`**
koşuyor. `pubspec.yaml`'da ağ-durumu paketi **yok**. ⇒ ***"ağ geri geldi"* diye bir tetikleyici
hiç tasarlanmamıştır.** Bu bir regresyon değil, **K112'nin kardeşi kapsam boşluğudur** ve yine
vitrinin kalbindedir: kullanıcı çevrimdışı yazar, ağ döner, **hiçbir şey olmaz.**

## 🔴 İKİNCİ BULGU — SİNYAL KATMANI KESİNTİYİ HİÇ FARK ETMEDİ

`signalr_json_sinyal.dart:160` her başarılı el sıkışmada **`SinyalBaglandi`** yayınlıyor ve
`_baglantiKoptu` → `_yenidenBaglanmayiPlanla` geri çekilmeli yeniden bağlanma **var**. Ama
`18-logcat.txt`'de bu pencerede **`baglanti koptu` de `el sikisma basarili` da YOK** — buna karşılık
senkron sonrası **`Changed alindi` GELDİ**, yani soket **hiç kopmamış**.
🔴 **BEYAN EDİLMİŞ SINIR — bu bir emülatör artefaktı olabilir:** emülatörün `10.0.2.2` NAT takma
adında **kurulu** bağlantı uçak modunda korunuyor (FAZ A-2: yeni bağlantı **anında** reddedildi,
`ping` 3,3 s direndi). ⇒ **Yeniden bağlanma yolu bu turda HİÇ EGZERSİZ EDİLMEDİ**; gerçek cihazda
davranış **`[DOĞRULANMADI]`**. Bu yüzden *"sinyal olayını itme tetikleyicisi yap"* şıkkı, tek başına,
**ölçülen vakayı çözdüğü KANITLANMIŞ SAYILAMAZ.**

Yan sonuç: keepalive (`{"type":6}`, 15 s) **yalnız gönderim**; sunucu yanıtına **zaman aşımı yok**
⇒ ölü ama "açık" görünen bir soket sessizce sinyal taşımayı bırakabilir. Ölçülmedi, **borç**.

## 🔴 ÜÇÜNCÜ BULGU — `Y1` KAPISININ BİLİNEN KAÇAĞI

`yoklama-yasagi-kapisi.py` yalnız `\bTimer(?:\.periodic)?\s*\(` arıyor. **Aynı yoklama
`Future.delayed` ile yazılabilir ve kapı GÖRMEZ.** Bu, bir düzeltme şıkkını değil, **kapının
kendisini** ilgilendirir: `D0`'ı `Future.delayed` ile delen bir el bugün yeşil geçer. Borç.

## Tasarım uzayının ölçülmüş kısıtı

`D0` [KIRMIZI]: *"Periyodik yoklama YASAK"* · `Y1`: `src/client/lib` altında **gövdesinde
`turCalistir`/`cekmeTuruCalistir`/`SenkronAgi` geçen HER `Timer`** — beyaz listedeki dosyada bile —
KIRMIZI'dır (K81). ⇒ **"başarısız itmeyi geri çekilmeyle yeniden dene" şıkkı kapıya ÇARPAR** ve
ancak Onur'un K68/K79 kilidini değiştirmesiyle açılır. Kapıyı susturarak değil.

🟢 Ölçülen kolaylık: `turCalistir()` kuyruk boşken **istek atmaz** (`M2` bu ayağı zaten koruyor)
⇒ itmeyi bir tetikleyiciye daha bağlamanın **boştaki maliyeti sıfırdır**.

## Ortam (K80 — ölçüldü)
`momentum-postgres` **Up 7 hours (healthy)** · `0.0.0.0:5298` **LISTENING** · `emulator-5554`
**device**, uygulama pid **14993** (ölçüm boyunca yeniden başlatılmadı).
