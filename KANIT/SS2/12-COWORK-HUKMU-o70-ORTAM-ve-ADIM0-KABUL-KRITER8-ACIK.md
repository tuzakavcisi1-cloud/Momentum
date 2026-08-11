# COWORK HÜKMÜ — `SS2` kriter 8: **ORTAM + ADIM ⓪ KABUL · KRİTER 8 AÇIK** (o70)

**Hükmü veren:** Cowork, **bağımsız ölçümle** (`K26` — builder'ın beyanına güvenilmedi).
**Üreten:** Claude Code · commit'ler `f225afb` · `73a6377` · `10504a7` · `239b463` · `32cfb18` (taban `d2cc02a`).
**Tarih:** 11 Ağu 2026 (cihazdan ölçüldü).

## HÜKÜM

| kapsam | hüküm |
|---|---|
| **Ortam kurulumu + sürücü takımı** | 🟢 **KABUL** |
| **Chrome yolunun dört şartı** (`KANIT/SS2/11` §4) | 🟢 **KABUL** — dördü de geçti |
| **Adım ⓪ tohumlama** | 🟢 **KABUL** — beş ölçütün beşi (biri beyanlı sınırla) |
| **Kriter 8'in KENDİSİ (adım ④–⑦)** | 🔴 **AÇIK — KOŞULMADI.** Çakışma **hiç görülmedi.** |

---

## 1. COWORK'ÜN KENDİ ÖLÇÜMLERİ (builder'ın metnine bakılmadan)

| ölçüm | sonuç |
|---|---|
| `d2cc02a..HEAD` beş commit, `src/` altında değişiklik | **SIFIR** ⇒ *"ürün koduna dokunulmadı"* **DOĞRULANDI** |
| Author | **Onur Kesim** (beşinde de) ✔ |
| Çalışma ağacı · `.git/index.lock` | **tamamen temiz** · **YOK** |
| `K175`② tabanı | **32 · 6 · 41** — **korundu** |
| `SyncCommandHandler.cs:184–187` | `OwnerId: authenticatedActorId`, yorum *"OwnerId **KİMLİK DOĞRULAMADA**"* ⇒ builder'ın *"`owner_id` başlıktan gelir (`K61`), başka kaynağı yok"* iddiası **DOĞRULANDI** |
| `IzolasyonBasliklari.cs:15` | *"BEYAN EDİLMİŞ SINIR — **CORP** bu iskelette **YOKTUR**"* + COOP/COEP **her yanıta** eklenir ⇒ şart-4 gerekçesi (*"chrome kendi dev sunucusundan sunulur, backend'in COOP/COEP'i onu izole etmez"*) **DOĞRULANDI** |
| `araclar/web-varlik.sha256` | **iki giriş**, alıntılanan sha'lar (`4db0469de8ce…` · `41cf96899824…`) **birebir tutuyor** |

## 2. İYİ YAPILAN — ölçüldü, beyan değil

1. **Pozitif VE negatif kontrol birlikte:** CORS'ta `Origin=localhost:5000` ⇒ `ACAO` **dolu**; `localhost:5001` ⇒ `ACAO` **boş**. Bu projede *"yokluk ölçen ayak pozitif kontrol taşımalı"* kuralının **doğru uygulanmış** hâli.
2. **Şart 4 KAYNAK KANITIYLA kapatıldı:** `--no-web-resources-cdn` *"gerekmez"* hükmü tahminle değil, `IzolasyonBasliklari.cs`'in **kendi beyanıyla** verildi ve kapsamı (`B-O63-2`/`ADR-0004`'ün **aynı-köken üretim** mimarisi) doğru ayrıldı.
3. **Cihaz DB'si ikili-güvenli çekildi** (`adb ... exec-out`, 40.960 b) — `entityId` **hem postgres'te hem cihazda** okundu; `03-device-B-momentum.sqlite` + `02-adim0-B-ekran.png` (screencap) **makine üretimi** kanıt.
4. **İki gerçek betik kusuru canlı koşumda bulunup düzeltildi** (biri *"sahte DUR"* üreten bind-adresi yoklaması) — kâğıtta bulunamayacak sınıf, `K53`/5'in ta kendisi.
5. **Dürüst `[DOĞRULANMADI]`:** A'nın kuyruğu için *"bu bir ÖLÇÜM DEĞİL, çıkarımdır"* **kendisi yazdı**.
6. `on_kosullar.py` altın kümesi **23/23**, her DUR/GEÇER dalı sentetik veriyle sınandı — **kör kapı yok**.

## 3. 🔴 BULUNAN İKİ EKSİK

**(a) KRİTER 8 KOŞULMADI.** Adım ④–⑦'nin **hiçbir kanıt dosyası yok** (`ls` ⇒ eşleşme sıfır). Çakışma **hiç doğmadı**, *"Benimkini tut"* **hiç basılmadı**. `D-SS2-11` penceresi **hâlâ canlıda ölçülmemiştir**. ⇒ **Kriter 8 AÇIK.**

**(b) `01-KONSOLIDE-OLCUM-RAPORU.md` BAYAT — kanıt klasöründe ölü beyan.** Dosya **11:24**'te yazıldı, iş **13:40–14:22**'de devam etti. Hâlâ şunları söylüyor:
- satır 12: *"BİR madde (`Ö4`) **GERÇEK** bir engel"* — 🔴 **yanlış**, `KANIT/SS2/11` ile düştü
- satır 23: *"`Ö4` … 🔴 **YALNIZ 1** — **GERÇEK ENGEL**"*
- satır 89: *"**İki-cihazlı senaryo (adım ⓪-⑦) hiç yazılmadı/koşulmadı** — `Ö4` engeli"* — 🔴 adım ⓪ **koşuldu ve geçti**

🔴 **Sınıf `olu-beyan`.** Onarım **builder'ın elinde** (`K34-f`: onaran el, yazan elden ayrı olmalı — burada **yazan el onarır**, Cowork onun kanıtını **yeniden yazmaz**). Bir sonraki turun **ilk işi**.

## 4. ADIM ⓪'IN BEYAN EDİLMİŞ SINIRI

*"İki kuyruk da boş"* ölçütünde **A (chrome/IndexedDB) doğrudan sorgulanmadı** — builder bunu `[DOĞRULANMADI]` yazdı ve dolaylı kanıtın *"ölçüm değil, çıkarım"* olduğunu **kendisi belirtti**. Cowork bu sınırı **kabul eder** (beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez) ve şunu ekler: 🔴 **kriter 8 için bu sınır ZARARSIZDIR** — A'nın kuyruğunun boşluğu senaryonun **ön koşulu değil**; çakışmayı doğuran **B'nin** bekleyen op'udur ve o **ölçüldü** (`senkron_kuyrugu` ⇒ 0 satır).

## 5. SIRADAKİ İŞ (tek cümle)

Adım ⓪ **engelsiz bitti**; sıra **④ B çevrimdışı → ⑤ A yazar → ⑥ çakışma görünür → ⑦ Benimkini tut**.
🔴 Pencere **tek atımlık**; kaçarsa **adım ⓪'dan yeni bir `SEED-n` ile** baştan.
