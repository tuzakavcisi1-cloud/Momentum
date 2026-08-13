# `SS2` KRİTER 8 (UÇTAN UCA) — COWORK BAĞIMSIZ KABUL HÜKMÜ

**Ölçen:** Cowork (`K26`). **Üreten/koşan:** Claude Code + Onur (elle sürüş).
**Tarih:** 13 Ağu 2026 (cihazdan ölçüldü). **Koşum:** 12 Ağu 2026 21:16–21:46 UTC.
**Commit'ler:** `babdee8` (erratum + ortam + adım ⓪ SEED-2) · `0b73d59` (adım ④–⑦).

## 1. COWORK'ÜN KENDİ ÖLÇÜMLERİ — Code'un beyanına dayanılmadı

| ne | nasıl ölçtüm | sonuç |
|---|---|---|
| ⑤ A, B'den SONRA yazdı | `06-adim5-A-yazdi.txt` ham HLC'leri | A `wall_ms=1786569598693` ↔ B `1786569372954` ⇒ **fark 225.739 ms**; iki `clientId` kanıtta |
| ⑥ çakışma göründü | **PNG'yi kendim açtım** (`09-adim6-B-cakisma-ekran.png`) | B'nin listesinde satır **`A1`** ve yanında **kırmızı ünlem rozeti** — gördüm |
| ⑥ sunucu birleştirmesi | `10-adim6-cakisma-gorundu.txt` | B'nin bekleyen op'u **13,5 sn**'de `Applied`; `tasks.title` **`A1`** kaldı (alan-seviyesi LWW A'nın geç HLC'sini korudu) |
| ⑦ *Benimkini tut* | **PNG'yi kendim açtım** (`11-adim7-B-benimkini-tut-ekran.png`) | satır **`B1`**, yanında **"Gönderilmedi"** etiketi — gördüm |
| ⑦ A'ya ulaştı | `13-…-A-ulasti-OLCUM.txt` (postgres) | `processed_operations` `Applied` · `tasks.title=B1` — **sunucunun kendi değeri** |
| ⓪ erratum | `01-KONSOLIDE-OLCUM-RAPORU.md` (8.823→10.919 b) | ölü iki cümle **silinmedi**, ERRATUM bloğuyla işaretlendi (`K34-f`) |
| ağaç | `git status --porcelain -- src tests KANIT` | **boş** — her şey commit'li |

## 2. HÜKÜM

🟢 **KRİTER 8 KABUL EDİLİR.** `D-SS2-11`'in uçtan uca ölçümü yapıldı: çevrimdışı yazım kuyrukta
bekledi, geç yazan A alan-seviyesi LWW'yi kazandı, B çevrimiçi olduğunda **bekleyen op'u varken**
çakışma **doğdu ve göründü**, *Benimkini tut* **projeksiyonu da yazdı** ve değişiklik **sunucuya ulaştı**.

## 3. BEYAN EDİLMİŞ SINIRLAR

1. 🔴 **ÇAKIŞMA ÇÖZÜM EKRANININ CANLI GÖRSELİ YOK.** Spec ⑥ *"ekran `B1` ↔ `A1` gösterir"* der;
   canlı cihazda yalnız **rozet** yakalandı. Code *"bir sonraki adımda ölçülecek"* yazdı ve **ölçmedi**
   (sınıf: **ölü söz**). Onur bunu **beyanlı sınır** olarak kilitledi (13 Ağu). Eksik olan **fotoğraftır, olgu değil**:
   `kazananDeger=A1` ekrandan ölçüldü · `kaybedenDeger=B1` **kaynaktan zorunludur**
   (`gorev_deposu.dart:446-448` — `benimkiniTut` YALNIZ `kayit.kaybedenDeger`'i yazar ve çıktı `B1` ölçüldü)
   · iki değerin **aynı anda ekranda** olduğu `G34/b` widget testiyle **mutantlı** ölçülüyor.
   Borç: `B-O71-5` (`BORCLAR.md`'ye **o72'de** yazılacak — `K175`③ bu oturumun tek yazımını harcadı).
2. 🔴 **CİHAZ A'NIN EKRANI BAĞIMSIZ DOĞRULANMADI** — Code dürüstçe `[DOĞRULANMADI]` yazdı; Chrome
   penceresi computer-use'un tıkla-yasak kipinde yakalanamadı. Otoriter kaynak (postgres) ölçüldü.
3. 🔴 **`verify.ps1` ŞU AN EXIT 1** — `KANIT/SS2/T8-uctan-uca/14-verify-ps1.txt`. CVE kapısı:
   **SSH.NET `<= 2025.1.0`**, High (CVSS 7.1), `GHSA-q939-rpr3-3284`, yamalı sürüm **2026.0.0**;
   advisory **12 Ağu 2026**'da yayımlandı ⇒ **bizim değişikliğimiz değil**. `Testcontainers.PostgreSql 4.13.0`'ın
   **geçişli** bağımlılığı, **yalnız test projesinde**. Onur pinlemeyi kilitledi (13 Ağu) — `B-O71-6`.
4. 🔴 **Cowork `dotnet`/`adb`/`docker` koşamadı** (mount VM'inde yok); ortam ve test sayıları Code'un
   ham çıktısından okundu. Bağımsız katkım: PNG'lerin **kendi gözümle** doğrulanması, HLC aritmetiği,
   kaynak kodu okuması, git ölçümleri, CVE'nin **birincil kaynaktan** okunması.
