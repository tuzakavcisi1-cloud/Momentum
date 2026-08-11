# ÖLÇÜM ERRATUMU — Onur'un 2. kilidi **DÜŞTÜ**, dördüncü yol **ÖLÇÜLDÜ**, ölçütler **DARALTILDI** (o70)

**El:** Cowork. **Yol:** `device_bash` ile depo dosyalarının doğrudan okunması. **Tarih:** 11 Ağu 2026 (cihazdan ölçüldü).
**Etkilediği belge:** `KANIT/SS2/09-DENETIM-TUR2-o70-v2-DUSTU-TUR3-YASAK.md` — **madde 6, 7 ve 15 DÜŞER**, yerine §3 gelir.

> 🔴 **Bu bir tasarım turu DEĞİL, bir ÖLÇÜM KAYDIDIR** (`K154`: *"yazılmayan ölçüm kaydı, kapatılmayan kapıdır"*).
> `K53`/1'in yasakladığı **üçüncü kâğıt turu açılmamıştır**; aksine kâğıt **daraltılmıştır**.

---

## 1. 🔴 COWORK'ÜN ONUNCU AYNI-SINIF KUSURU: ölçüm elimin altındaydı, ben devrettim

`09`'un **madde 6**'sı *"`Program.cs` gövdeyi logluyor mu — bunu **Claude Code** ölçsün"* diyordu.
Bu **yanlıştı**: `src/` bağlı klasörde duruyor ve Cowork onu `device_bash` ile **okuyabiliyor**.
Ölçüm **iki `grep`** sürdü. Onur üç şıkkın hiçbirini seçmeyip *"karar ver"* demekle **doğru olanı yaptı**:
şıklar **ölçülmemiş bir öncüle** dayanıyordu.

## 2. ÖLÇÜM — Onur'un 2. kilidi (*"iç durum backend istek logundan okunur"*) **DÜŞTÜ**

| ölçüm | sonuç |
|---|---|
| `Program.cs:29–32` Serilog yapılandırması | `MinimumLevel.Information()` · `Enrich.FromLogContext()` · `WriteTo.Console()` — **başka hiçbir şey** |
| `Program.cs:162` | `app.UseSerilogRequestLogging()` — **method · path · status · elapsed**; **GÖVDE YOK** |
| `Program.cs:147–159` | yalnız **`X-Correlation-Id`** üretilip `LogContext`'e itiliyor |
| `HttpLogging` · `AddHttpLogging` · `EnableBuffering` · `RequestBody` araması (`src/backend`, `bin`/`obj` hariç) | **0 eşleşme** |
| Backend'in **TÜM** log çağrıları | **ÜÇ tane**: `Web/IstemciServisi.cs:93` (`LogWarning`) · `Web/IstemciServisi.cs:124` (`LogInformation`) · `Sync/OutboxDispatcher.cs:100` (`LogWarning`) |
| `clientId` **veya** `hlc` içeren log çağrısı | **0** |
| `appsettings.json` `Logging` bloğu | `Default: Information` · `Microsoft.AspNetCore: Warning` — gövde loglama **yok** |

🔴 **HÜKÜM: backend istek logu `clientId`'yi de HLC'yi de TAŞIMIYOR ve yapılandırmayla taşıyamaz.**
Onur'un 2. kilidi **ölçümle düştü** — tahminle değil.

## 3. 🟢 DÖRDÜNCÜ YOL — **SUNUCUNUN KENDİ PostgreSQL'İ** (ölçüldü, üç şıkkın üçünü de gereksiz kılar)

`src/backend/Momentum.Infrastructure/Persistence/` — şema **ölçüldü**:

| tablo | ilgili sütunlar | kaynak |
|---|---|---|
| `processed_operations` | **PK (`client_id`, `operation_id`)** · `client_id` **`uuid`** | `Migrations/20260718202450_InitialSync.cs:43,51` · `SyncConfigurations.cs:41–42` |
| `sync_client_clock` | **PK `client_id`** · **`hlc`** | `InitialSync.cs:58–63` · `SyncConfigurations.cs:55–57` |
| (dört tabloda) | **`hlc`** — hepsi **`COLLATE "C"`** | `SyncConfigurations.cs:7,25,71,87,103` |

`SyncConfigurations.cs:7` birebir: *"COLLATE `"C"` on every `hlc`/`effective_op_hlc` column so byte order
matches the HLC ordering"* ⇒ **HLC karşılaştırması SQL'de doğrudan yapılabilir.**

**Okuma yolu:** `docker exec -i momentum-postgres psql -U momentum -d momentum -c "<sorgu>"`

- **Ürün koduna sıfır bayt** · **cihaz içine sıfır giriş** (`adb run-as`/sqlite3 **gerekmiyor**) ·
  **log yapılandırmasına sıfır dokunuş** · `Tee-Object`/kodlama sorunu **yok** (psql çıktısı doğrudan dosyaya).
- Ve bu **OTORİTER kayıttır**: sunucunun LWW'si ve echo elemesi (`D-SS2-3/3`) **zaten bu sütunlara** dayanıyor.
- 🔴 **Beyan edilmiş sınır:** psql sunucunun **gördüğünü** ölçer, cihazın **kuyruğunu** değil. §4 bunu çözüyor.

**Ders (o69'un devir notundan, birebir):** *"bir ölçümün ÖLÇÜLEMEDİ olması ARACIN değil ELİN sınırıdır —
üç el denendi, üçüncüsü ölçtü."* Burada dördüncü el **sunucunun kendi veritabanıydı** ve baştan oradaydı.

## 4. DARALT — kilitli spec'in İSTEMEDİĞİ üç ölçütü v2 icat etmişti

`GOREV-SS2` §7 kriter 8'in **yazılı** şartı yalnız şudur:
> *"koşum, A'nın yazımının B'ninkini yenmesini **garanti etmek için** A'yı **sonra** yazdırır ve
> **iki `clientId`'yi kanıta yazar**."*

- **HLC'yi OKUMAYI şart koşmuyor** — sıra **kurgu ile garanti edilir** (A sonra yazar), ölçümle değil.
  *(Yine de psql ile **ölçülebiliyor** ⇒ kanıta **fazladan** yazılır, ama **eşik değildir**.)*
- **Kuyruğu okumayı HİÇ istemiyor.** *"Op kuyrukta"* iddiasının gözlemlenebilir kanıtı **⑥'nın kendisidir**:
  **çakışma göründüyse op kuyruktaydı** — B çevrimdışıyken yazılmayan bir op çakışma üretemez.
  🔴 Ara ölçüm, **kanıtı olmayan bir ara değişkeni** ölçmeye çalışıyordu.
- **`X-Momentum-Dev-User` (`UserId`) eşitliği** psql'den değil, **davranıştan** ölçülür: A'nın yarattığı görev
  B'de görünüyorsa iki cihaz **aynı kullanıcıdadır** (`K61`: farklı `UserId` ⇒ birbirinin görevini **hiç görmez**).

🔴 **Cowork v2'de kilitli spec'in istemediği dört ölçüt icat etti, sonra ölçemediğini görünce
Onur'a üç ürün-kodu şıkkı sundu.** Radar `R2b`'nin (*"koşulamayan spec"*) ve `R4`'ün (*"artefakt büyüyor"*)
ölçtüğü sınıf budur. **Kâğıdı büyüten el, ölçemediği şeyi şık diye sunar.**

## 5. `09`'a ERRATUM — üç madde düşer, biri gelir

- ❌ **Madde 6** (*"`Program.cs` gövdeyi logluyor mu"*) ⇒ **ÖLÇÜLDÜ, §2. Kapandı.**
- ❌ **Madde 7** (*"`Ö8` üçe ayrılır, backend logunda üç alan aranır"*) ⇒ **DÜŞER.** `Ö8` yerine:
  **`docker exec ... psql` ile `processed_operations` ve `sync_client_clock` okunabiliyor mu** — tek ölçüm.
- ❌ **Madde 15** (*"iki kuyruk boş, backend logundan ölçülemez"*) ⇒ **DÜŞER.** Kuyruk **hiç okunmaz** (§4).
- ✅ **YENİ:** psql erişimi ön koşul olarak ölçülür (`docker exec -i momentum-postgres psql -U momentum -d momentum -c "\\dt"`);
  şema beklenen iki tabloyu **gösterir**. Sağlanmazsa **DUR**.
- 🔴 Kalan **16 madde AYNEN durur** — hepsi kabuk/cihaz mekaniği ve hepsinin cevabı hâlâ **makinededir**.

## 6. NE ÖLÇÜLEMEDİ

- **psql'in bu makinede fiilen koştuğu ÖLÇÜLMEDİ** — `docker` Cowork'ten erişilemez (`K80`); şema
  **kaynak kodundan** ölçüldü, **çalışan veritabanından değil**. Claude Code'un ilk ölçümü bu olmalıdır.
- 🟢 **ÖLÇÜLDÜ (bu satır düzeltildi):** sonraki iki migration'ın **gövdesi** (`20260719072330_DispatcherIndexes.cs`,
  `20260719162721_MaterializeTasksAndTaskLists.cs`) `client_id`/`hlc`'ye **dokunmuyor** — eşleşme yalnız
  `.Designer.cs` model anlık görüntülerinde, ki onlar **tüm** modeli taşır. ⇒ sütun adları `InitialSync`'teki
  hâliyle **duruyor**. 🔴 Yine de **çalışan veritabanında** değil, **kaynakta** ölçüldü.
- **`processed_operations`'ın bir op'un HANGİ ALANINI taşıdığı** (başlık değeri var mı) ölçülmedi ⇒
  *"B'nin yazımı A'ya ulaştı"* ölçütünün psql ayağı **[DOĞRULANMADI]**; birincil kanıt **`screencap`** kalır.
- **Cihazın kuyruğu psql'den GÖRÜNMEZ** — beyan edilmiş sınır, §4'te bilerek kapsam dışı bırakıldı.
