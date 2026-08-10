# DENETİM HÜKMÜ — `GOREV-ADR0004-KAPISI-ONARIM-1-INDEKS` **v1 DÜŞTÜ**

**Tarih:** 10 Ağu 2026, oturum 68 (cihazdan ölçüldü: `TZ='Europe/Istanbul' date`).
**Denetlenen:** Cowork'ün ürettiği onarım spec'i v1.
**Denetçi:** İKİ bağımsız el, **üretici olmayan** (`K26`). Mercekler ayrı.
**Hüküm:** **A → SPEC EKSİK · B → ÖLÇÜTLER KÖR.** Spec **uygulamaya VERİLMEDİ**, v2 yazıldı.
**Kaynak HEAD:** `5b0f259` (denetçi B cihazda doğruladı; çalışma ağacı temiz).
**Hedef belge:** `docs/ADR/0004-web-capraz-koken-izolasyonu.md` · `md5 fcf83c2c9109323734ef83b983d2c06c`
(cihaz ↔ bulut kopyası **birebir aynı** — bulut ölçümleri cihaza taşınabilir).

---

## 1. TASARIM AYAKTA KALDI (§1 İNDEKS + §2 sözleşme)

Denetçi A, spec §1/§2/§3'e **birebir sadık** bir referans indeks uygulaması yazdı ve
orijinal `_dosya_coz`'a karşı diferansiyel koşturdu:

| koşum | karşılaştırma | fark |
|---|---|---|
| 27 düşmanca `ad` × 6 `kok` biçimi | **162** | **0** |
| 60 tohumlu rastgele ağaç (sembolik bağ, kendine döngü, kırık bağ, hardlink, budanan dizinler, Türkçe ad, boşluklu dizin, `\` ve `./`, 3 kök biçimi) | **8.187** | **0** |
| hedef belgede stdout | bayt-bayt | **ÖZDEŞ** |
| altın küme | 39 vaka | **39/39** |

Denetçi B, **cihazda** (mount): V0-SADIK ↔ ESKİ **md5 eşit**, süre **3,03 sn**.

⇒ **Kusur tasarımda değil; §3'ün beyanlarında ve §4'ün kabul ölçütlerinde.**

---

## 2. BLOKERLER

### B1 — K1 ("hükmün kalbi") sözleşmenin 5 maddesinden 4'ünü PİNLEMİYOR *(A + B)*

Cihazda, gerçek koşum, ESKİ ile bayt-bayt:

| sabotaj varyantı | ihlal | K1 | K2 |
|---|---|---|---|
| V0-SADIK | (yok) | ÖZDEŞ | 3,03 sn |
| V1 harf katlayan indeks | §2.2 | **ÖZDEŞ** | 2,74 sn |
| V2 yol-parçası süzgeci **silindi** | §2.3 | **ÖZDEŞ** | 2,64 sn |
| V4 ek budama | §2.1 + §1 reddi | **ÖZDEŞ** | **2,66 sn (en hızlı)** |

**Sebep ölçüldü, belge kaynaklı:** hedef belgenin ürettiği 11 çağrının **hepsi çıplak
taban-ad**, hiçbirinde `/` yok ⇒ §2.3 eleme dalı **0 kez** çalışıyor; 11 adın hepsi **tek**
dosyaya çözülüyor ⇒ §2.4'ün "çoklu → sıralı liste" biçimi **hiç üretilmiyor** ve `g52`'nin
`coz[0]` sıra bağımlılığı **hiç uyarılmıyor**; §2.5'in `kok="."` öneki **CLI'dan erişilemez**
(`main()` satır 1308 `abspath` uyguluyor).

Denetçi A ayrıca hüküm sınıfını **fiilen değiştiren** iki üretilebilir girdi verdi:
- `src/web/Program.cs` + `src/mobil/Program.cs`, belge: ``…`src/web/Program.cs`:9999…``
  → ESKİ `G54/c KIRMIZI` (EXIT 2) · V2 `G54/b SARI` (EXIT 1)
- `aaa/Ayar.cs` (boş) + `zzz/Ayar.cs` (`var x = KRITIK_DESEN;`), belge:
  `Ayar.cs icindeki 'KRITIK_DESEN' ÖLÇÜLEMEDİ.`
  → ESKİ bulgu yok (EXIT 0) · ters sıralı varyant `G52/b KIRMIZI` (EXIT 2)

### B2 — K3 "`os.walk` tam 1" UYGULANAMAZ *(A + B)*

`os.walk` **global** sarılıp gerçek ağaçta tam bir `denetle()` koşuldu:

| sürüm | toplam | dağılım |
|---|---|---|
| ESKİ | **20** | `_dosya_coz`:11 · `g55`(601):6 · `_kimligin_araci`(565):3 |
| V0-SADIK (kusursuz onarım) | **10** | indeks:1 · `g55`:6 · `_kimligin_araci`:3 |

⇒ **Kusursuz onarımda bile 10.** Ölçüt yazıldığı gibi koşulursa **doğru onarımı düşürür**;
düşürmemek için koşum anında sessizce daraltılır — **kör kapı mekaniğinin ta kendisi**.
Ek: `g55`'in walk sayısı **belgeye lineer** (belgedeki `X/G<n>` eşleşme sayısı = 6 = walk).

### B3 — K5(b) ÖLÜ MUTANT, sağlanması İMKÂNSIZ *(A + B)*

`altin_kume_kos()` gövdesinde (satır 810–1292) **`denetle(` çağrısı SIFIR**; 39 vakanın
tamamı `g52`/`g53`/`g54`/`g55`/`g56`'yı **doğrudan** çağırıyor.

| mutant | altın küme |
|---|---|
| `denetle()`'de sıfırlama YOK | **39/39 GEÇTİ** |
| `denetle()`'de **ve** vaka başında sıfırlama YOK | **39/39 GEÇTİ** |

### B4 — K4 (altın küme) indeks kusurunu YAKALAYAMIYOR *(B)*

Sayım doğrulandı: **39 vaka** (35 numaralı + `4b`, `11n`, `18b`, `18n`), yerinde **39/39, EXIT 0**.
`_dosya_coz`'a giden **18 vaka, 20 çağrı**; dönüş dağılımı TEK=18, YOK=1 (vaka 16), ÇOKLU=1 (vaka 19).

| sabotaj | ihlal | altın küme |
|---|---|---|
| V1 harf duyarsız | §2.2 | 39/39 GEÇTİ |
| V2 yol parçası yok | §2.3 | 39/39 GEÇTİ |
| V3 sırasız/tekilleştirilmemiş | §2.4 | 39/39 GEÇTİ |
| V4 ek budama | §2.1 | 39/39 GEÇTİ |
| V5 kok-kör önbellek | §3 | 39/39 GEÇTİ |
| V6 `followlinks=True` | §3 | 39/39 GEÇTİ |
| V7 sıfırlama yok | §3 | 39/39 GEÇTİ |
| V8 çoklu bayrağı yok | §2.4 | **38/39 (vaka 19 düştü)** |

**9 sabotajdan 8'i geçiyor.** Altın küme, sözleşmeden **tek bit** pinliyor.

### B5 — §3'ün per-vaka sıfırlama zorunluluğu KUSURU MASKELİYOR *(B)*

```
V5 (kok-kör önbellek) + vaka başı sıfırlama VAR  → 39/39 GEÇER   ← kusur maskelendi
V5 (kok-kör önbellek) + vaka başı sıfırlama YOK  → 27/39 DÜŞER   ← kusur ısırır
V0 (sadık)           + vaka başı sıfırlama YOK  → 39/39 GEÇER
```
⇒ Zorunluluk **doğru uygulama için gereksiz, kusurlu uygulama için kalkan**.

### B6 — §3'ün `onerror` beyanı OLGUSAL OLARAK YANLIŞ *(A)*

v1: *"`PermissionError`/`OSError` mevcut kodda yutulmuyor; indeks de yutmaz."*
Ölçüm (uid 65534, `kapali/` mod 000):
```
os.walk(kok) VARSAYILAN     : ÇÖKMEDİ, 2 dizin gezildi → HATA YUTULDU
os.walk(kok, onerror=raise) : ÇÖKTÜ → PermissionError(13)
```
⇒ Spec'i harfiyen uygulayan el `onerror=` ekler, araç **traceback ile ölür**,
çıkış kodu sözleşmesi (0–4) **dışına** düşer.

### B7 — §2.5 ↔ §3 (`abspath` anahtarı) BİRBİRİNİ ÇÜRÜTÜYOR *(A)*

```
kok='/tmp/key_.../'  ESKİ=['/tmp/key_.../Program.cs', …]  YENİ=aynı           ÖZDEŞ
kok='.'              ESKİ=['./Program.cs', …]
                     YENİ=['/tmp/key_.../Program.cs', …]  >>> BAYT-FARKI <<<
```
Bugün tetiklenmiyor (`main()` `abspath`'liyor, altın kümede abspath çakışması yok) ama
**iki kilitli bölüm çelişiyor**; el hangisini seçerse diğerini ihlal ediyor.

---

## 3. YANLIŞ BEYANLAR (spec'in kendi metninde)

| v1'de yazan | ÖLÇÜM | bulan |
|---|---|---|
| *"`lru_cache` GEÇERSİZ — **ölçüldü**, 11 çağrının 11'i farklı ad"* | 11 çağrı, **5 farklı ad, 6 isabet (%54,5)**; `IzolasyonBasliklari.cs` ×4, `IstemciServisi.cs` ×3, `Program.cs` ×2. `lru_cache` 11→5 walk yapardı | B |
| *"G55/G56'nın **iki** `GOREV_CLAUDE_CODE` walk'ı"* | **dokuz** (6 + 3); **G56 sıfır walk** | A + B |
| *"`os.walk` `PermissionError` yutmuyor"* | **yutuyor** (bkz. B6) | A |
| K6: *"`G53/e` bulgu kümesi K1'de zaten pinli"* | ek budama: 1.864→1.824 dosya, **40** taban-ad değişiyor, **ADR'nin 5 adının 0'ı** ⇒ K1 **kör** | A + B |
| §0: *"43 sn / EXIT 124 tam açıklanıyor"* | bugün cihazda **25,57 / 26,41 sn · EXIT 3 · 2.996 b / 29 satır**, koşum **BİTİYOR** | B |

---

## 4. NE ÖLÇÜLEMEDİ

1. **Native Windows / NTFS** — kap yok. §2.2'nin gerçek riski (NTFS büyük/küçük harf
   duyarsızlığı), `ntpath.basename`, sürücüler arası `relpath` `ValueError`'ı,
   junction farkları: **hiçbiri ölçülmedi**.
2. **Soğuk önbellek** — VM'de root yok, `drop_caches` yapılamadı ⇒ 43 sn'nin soğuk bir
   koşum olup olmadığı **ne doğrulandı ne çürütüldü**.
3. **43 sn / EXIT 124 koşumunun koşulları** spec'te ve devir notunda **kayıtlı değil**
   (hangi `timeout`, hangi `--kok`, `device_bash` tavanı mı kesti) ⇒ **yeniden kurulamadı**.
4. **Claude Code'un gerçek onarım kodu** — henüz yok. Denetlenen şey **ölçütlerdir**.
5. **Gerçek sembolik-bağ döngüsü** — kullanıcının diskine yazmama disiplini gereği
   kurulmadı; `followlinks` varyantı yalnız sentetik ağaçta ölçüldü.
6. **G56'nın süre payı** — `PROJE_RADAR.jsonl` (372 KB) okuma payı ayrıştırılmadı
   (walk payı **0** ölçüldü).
7. **Bulut denetçisinin altın küme fixture'ı sentetikti** (`araclar/fixture/adr-hukum/`
   yüklemede yoktu) ⇒ vaka 1/5/6/23/29/35 gerçek fixture'la farklı davranabilir.
   🟢 Cihaz denetçisi (B) **yerinde, gerçek fixture'la** koştu: **39/39, EXIT 0**.

---

## 5. HÜKÜM

**SPEC v1 UYGULAMAYA VERİLMEDİ.** v2 yazıldı; on iki bulgunun her biri v2'de bir
maddeye bağlandı (v2 §6 tablosu). `K53/1` gereği v2 **üçüncü kâğıt turuna girmez**.

🔴 **Bu turun dersi:** spec'i yazan el (Cowork), kendi spec'inde **"ölçüldü" damgalı
uydurma bir gerekçe** taşıdı (`lru_cache`) ve iki olgusal hata yaptı. Üçünü de
**ölçüm buldu, muhakeme değil** — ve ölçümü **üretici olmayan eller** koştu.
`K26` bu turda **işini yaptı**.
