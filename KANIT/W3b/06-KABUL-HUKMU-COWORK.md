# `GOREV-W3b` — KABUL HÜKMÜ (Cowork, bağımsız · `K26`) · oturum 66, 8 Ağu 2026

> **Bu bir kabul BEYANI değil, kabul HÜKMÜDÜR.** Kilit Onur'dan gelir (`K40`/`K127` deseni).
> Üreten el **Claude Code**, ölçen ve hüküm veren el **Cowork** — `K26` korunmuştur.
> Ölçümlerin tamamı **cihazda** koşuldu (`ORTAM.md`: kapı hükmü, koştuğu ortamın hükmüdür).

**Commit:** `9d8c204` · **`urun_kodu_satiri` = 4** (git'ten: `radar.py --olc-urun-kodu 8f5d643`) ⇒ **`R8` SÖNDÜ.**

---

## 1. KABUL KRİTERLERİ — sekizi de KARŞILANDI

| # | kriter | ölçüm | hüküm |
|---|---|---|---|
| 1 | Dört kapı YEŞİL (Cowork koşar) | `yayin-kapisi.py .` → **EXIT 0**, bulgu yok | 🟢 |
| 2 | Altın küme; her ayak temiz+kirli | **29/29 GEÇTİ**, EXIT 0 (20 mutant senaryosu + `B-W3b-4` ek vakası + 4 çıkış-kodu sözleşmesi) | 🟢 |
| 3 | **20 mutantın 20'si hüküm verir** | **20/20** — 18 kusurlunun her biri hedefini düşürdü, 2 susmalının **hiçbiri KIRMIZI vermedi**; **ölü mutant YOK**, geri yükleme **hepsinde bayt-özdeş** | 🟢 *(ilk koşumda 9 ölü çıktı — aşağıya bak)* |
| 4 | `dotnet build` 0 uyarı / 0 hata | `verify.ps1` çıktısında birebir | 🟢 |
| 5 | İzlenmeyen dosya (dar komut) | `ls-files --others -- …/wwwroot` → **BOŞ** | 🟢 |
| 6 | `verify.ps1` EXIT 0 | **120/120** (5+15+44+56) · CVE 0 · SDK 10.0.302 | 🟢 ⇒ **`B-O62-2` KAPANDI** |
| 7 | Bağımsız denetim turu 1 | `§0` — agentId `a0fe359b259f347d8` | 🟢 |
| 8 | Canlı HTTP + negatif kontrol | `GET /` **200** + `flutter_bootstrap.js` ✔ · `/_BUILD.json` **200** · negatif kontrol **404** | 🟢 ⇒ **`B-W3b-1` KAPANDI** *(beyanlı sınırla, Onur kabul etti)* |

---

## 2. MUTANT HÜKÜM TABLOSU — 20/20

| mutant | hedef | gözlenen | hüküm |
|---|---|---|---|
| `M246` | `G48/a` KIRMIZI | rc=2 | ✔ ISIRDI |
| `M247` | `G48/b` KIRMIZI | rc=2 | ✔ |
| `M248` | ORTAM HATASI (3) | rc=3 | ✔ |
| `M249` | `G49/a`+`c` KIRMIZI | rc=2 | ✔ |
| `M250` | ORTAM HATASI | rc=3 | ✔ *(Cowork **yeniden** ölçtü)* |
| `M251` | `G50/a` KIRMIZI | rc=2 | ✔ |
| `M252` | `G50/b` KIRMIZI + `G50/e` **hükümsüz** | rc=**3**; çıktıda `[KIRMIZI] G50/b` **ve** `[NOT] G50/e … HÜKÜMSÜZDÜR` | ⚠ **ERRATUM** — `gözlenen ⊇ hedef`: dosya boşalınca `G51/d` pozitif kontrolü de düştü ⇒ ORTAM HATASI baskın oldu. **Doğru davranış**; bloker değil (spec §6 taksonomisi) |
| `M253` | `G50/c` KIRMIZI | rc=2 | ✔ *(Cowork **yeniden** ölçtü)* |
| `M254` | `G50/d` KIRMIZI | rc=2 | ✔ — **`B4` blokerinin onarımı kanıtlandı** |
| `M255` | `G50/e` KIRMIZI | rc=2 | ✔ |
| `M256` | ORTAM HATASI (3) | rc=3 | ✔ *(Cowork **yeniden** ölçtü)* |
| `M257` | `G51/a` KIRMIZI (çekirdek kusur) | rc=2 | ✔ |
| `M258` | `G51/b` KIRMIZI (çift tırnak) | rc=2 | ✔ |
| `M259` | `G51/b` KIRMIZI (tek tırnak) | rc=2 | ✔ |
| `M260` | `G51/b` KIRMIZI (protokol-göreli) | rc=2 | ✔ |
| `M261` | `G51/c` **SARI** | rc=1 | ✔ (KIRMIZI **vermedi** — sayan-raporlayan deseni doğru) |
| `M262` | ORTAM HATASI, çıkış ≠ 0 | rc=3 | ✔ *(Cowork **yeniden** ölçtü)* |
| `M263` | `G51/b2` **SARI** (2→1) | rc=1 | ✔ — **`B2` blokerinin taban pini kanıtlandı** |
| `MW23` | **SUSMALI**: hiçbir KIRMIZI | rc=**1** (SARI) — `[SARI] G51/b2: pin=2, ölçülen=3`; **`G51/b` HİÇ FİRE ETMEDİ** | ✔ **KRİTER KARŞILANDI** + 🔴 **BEYAN**: aşağıya bak |
| `MW24` | **SUSMALI** | rc=0 YEŞİL | ✔ |

### 🔴 `MW23` HAKKINDA BEYAN (gizlenmez)
Mutantın **amacı** `G51/b`'nin *"salt mention'a ısırıyor mu"* sorusunu ölçmekti: **ısırmadı** — sahte-pozitif
**yok**, `B2` blokerinin onarımı bu ayakta da doğrulandı. Ama yorum satırı `canvasKitBaseUrl` geçiş sayısını
**2 → 3** yaptığı için `G51/b2`'nin **taban pini SARI verdi**. Bu **sahte-pozitif değil, pinin çalışmasıdır**
(`b2` zaten *"sapma SARI verir"* diye tanımlı). Kriterin lafzı (*"hiçbir KIRMIZI"*) karşılandı.
🔴 **Sonuç: `G51/b2` yorum satırlarını gövde kodundan AYIRT ETMEZ** — beyan edilmiş sınır, borç `B-W3b-7`.

---

## 3. 🔴 İLK KOŞUMDA 9 MUTANT ÖLÜ ÇIKTI — ne oldu, nasıl kapandı

Claude Code'un yazdığı `_mutant_kosucu.py` ile koşulduğunda 16 içerik mutantının **9'u hüküm vermedi**:

| sebep | mutantlar | mekanizma |
|---|---|---|
| Tanımsız bırakılmış | `M251` `M252` `M254` | `eski=None, yeni=None` ⇒ `ham.count(None)` **TypeError** |
| Çoklu eşleşme | `M255` `M258` `M259` `M260` | çapa `_flutter` gerçek dosyada **12 kez**; `n==1` koruması yamayı **hiç uygulamadı** |
| Çoklu eşleşme | `M263` | çapa **2 kez** |
| Sıfır eşleşme | `MW23` | çapa (`canvasKitBaseUrl:i.canvasKitBaseUrl`) dosyada **0 kez** — gerçek kod üçlü işleç |

**Kusur KAPIDA DEĞİL, KOŞUCUDAYDI** (spec §6 taksonomisi: *"gözlenen = {} ⇒ ÖLÜ MUTANT, kusur mutanttadır"*).
Onarım **`K34-f` gereği ayrı ele** verildi: Cowork `KANIT/W3b/_mutant_kosucu_cowork16.py`'yi yazdı; üreticinin
dosyası **kayıt için olduğu gibi bırakıldı**.

**Onarımın üç ayağı:**
1. `KOK` **argv/CWD'den** gelir — sabit `C:\dev\Momentum` yolu kaldırıldı (`B-O64-2` sınıfı, üreticide **ikinci kez** tekrarlanmıştı; mount'ta `FileNotFoundError` veriyordu).
2. Üç yeni kip: `whole` · `empty` · `json_del`; çok-eşleşmede `first`/`append` **açık semantik** + eşleşme sayısı kanıta yazılır.
3. 🔴 **Üreticide OLMAYAN ayak:** yama uygulandı mı diye **sha karşılaştırılır**. `sha(yamalı) == sha(yedek)` ise mutant **ÖLÜ** ilan edilir ve kapı **koşulmaz** — sessizce yeşil dönemez. *`K118`: "yamanın fiilen uygulandığı ölçülmeden koşum geçersizdir".*

**Sonuç:** ölü mutant **YOK**, geri yükleme **20/20 bayt-özdeş** (`.gitignore` `3203A77B` · `flutter_bootstrap.js` `531DCA42` — mutant turundan önce ve sonra aynı).

🟢 **EK KAZANIM:** spec §6'nın *"dört mutant Cowork'ten koşulamaz (mount `unlink` yasağı)"* **beyan edilmiş sınırı KAPANDI** — `unlink` yerine `mv` kullanıldı (mount'ta çalışıyor) ve `M250`/`M253`/`M256`/`M262` **Cowork tarafından bağımsız olarak yeniden ölçüldü**; dördü de üreticinin bildirdiği sonucu verdi. Üreticinin kendi ölçtüğü tek kalem kalmadı.

---

## 4. AÇIK KALAN / YENİ BORÇLAR

| id | borç |
|---|---|
| `B-W3b-6` | Kriter 8'in **negatif kontrolü** `N4`'ün tam mekanizmasını (`Path.GetFullPath("wwwroot")` yanlış çözümü) değil, bir katman yukarısını (content-root'ta `appsettings.json` bulunamaması) gözledi. Temiz izolasyon: yanlış CWD **+** `Istemci__KokDizin` ortam değişkeniyle verilir. **Claude Code kendi yazdı, gizlemedi**; Onur beyanlı sınır olarak kabul etti (o66). |
| `B-W3b-7` | `G51/b2` **yorum satırlarını gövde kodundan ayırt etmez** (`MW23` ölçtü: yorum sayıyı 2→3 yapıp SARI ürettirdi). |
| `B-W3b-8` | `araclar/web-yayina-al.py` `_BUILD.json`'ı Windows'ta **metin modunda** yazıyor ⇒ **CRLF=9** (`ORTAM.md` #48 sınıfı). Build çıktısı ve git-ignore'lu olduğu için zararsız, ama **bizim kodumuzun** kusuru. |
| `B-W3b-9` | `KANIT/W3b/__pycache__` izlenmiyor ve `.gitignore`'da karşılığı yok. |
| `B-O63-2` | `--no-web-resources-cdn`'in **CI'da** zorlanması — `W3b/G51` kapıyı yazdı, CI'ya bağlanması `D-A13-4` turunda. |
| `B-O63-5` | `izolasyon-olc.py` `B`/`S`/`F` taslağı hâlâ `araclar/` dışında. |

---

## 5. HÜKÜM

🟢 **`GOREV-W3b` KABUL EDİLEBİLİR.** Sekiz kriterin sekizi de karşılandı; 20 mutantın 20'si hüküm verdi;
dört kapı gerçek depoda yeşil; altın küme 29/29; `verify.ps1` Windows'ta **ilk kez** geçti; `R8` söndü.
**İki gerçek borç kapandı** (`B-O62-2`, `B-W3b-1`), **dört yeni borç beyan edildi** (gizlenmedi).
🔴 **Kilit Onur'dan gelir.**
