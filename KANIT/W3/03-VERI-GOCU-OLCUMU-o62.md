# `W3` — VERİ GÖÇÜ ÖLÇÜLDÜ · 🔴 **`02-O2-OLCUMU-o62.md`'YE ERRATUM** (oturum 62)

**6 Ağu 2026, oturum 62. Koşan el:** Cowork. **Nerede:** bulut konteyneri (Flutter **3.44.9**,
Dart 3.12.2, headless Chromium). **Onur'un makinesinde DEĞİL.**

---

## 🔴 ÖNCE ERRATUM — kendi hükmümü ölçüm yanlışladı

`02-O2-OLCUMU-o62.md` şunu yazdı:

> *"🟢 HÜKÜM: İZOLASYON ÜRÜN DAVRANIŞINI DEĞİŞTİRDİ … **Bu, `B1`'in yanlışlanmasıdır.**"*

**Bu hüküm EKSİKTİ.** Ölçüm **temiz profille** koşmuştu ve o cümle **yalnız temiz kurulum için**
doğru. Onur *"önce veri göçünü ölç"* dediği için ölçüm **mevcut depoyla** tekrarlandı ve sonuç
**tersine döndü**. Bu, projenin kendi **`B2` sınıfıdır** (*"ölçüldü" damgalı iddia, ölçülünce ters
çıktı*) — ve bu kez **benim çıktımda** oldu. `02`'nin `B1` hükmü **bu belgeyle daraltılmıştır**.

---

## Kurgu

Aynı build, aynı köken (`127.0.0.1:5211`), **KALICI tarayıcı profili**, üç koşum art arda:

| # | başlık | ne bekleniyordu |
|---|---|---|
| 1 | yok | drift `sharedIndexedDb` seçsin, `momentum` deposunu **oluştursun** |
| 2 | `COOP`+`COEP` | izolasyon açık ⇒ **göç** olsun, `opfsLocks`'a geçsin |
| 3 | yok | izolasyon geri alınırsa veri **hangi tarafta** kaldı |

## ÖLÇÜLEN

| # | `crossOriginIsolated` | `chosenImplementation` | `missingFeatures` | IndexedDB | OPFS |
|---|---|---|---|---|---|
| 1 | `false` | `sharedIndexedDb` | `dedicatedWorkersInSharedWorkers`, **`sharedArrayBuffers`** | `momentum` v1 | **boş** |
| 2 | **`true`** | **`sharedIndexedDb`** | `dedicatedWorkersInSharedWorkers` | `momentum` v1 | **boş** |
| 3 | `false` | `sharedIndexedDb` | `dedicatedWorkersInSharedWorkers`, `sharedArrayBuffers` | `momentum` v1 | **boş** |

**Kontrol (temiz profil, `_o2_olc.py` iki kez koştu, aynı sonuç):**
izolasyonsuz → `sharedIndexedDb` · izole → **`opfsLocks`**.

## 🔴 HÜKÜM

**İzolasyon ALGILANIYOR ama SEÇİM DEĞİŞMİYOR.** Koşum 2'de `missingFeatures` listesinden
`sharedArrayBuffers` **düştü** — yani drift izolasyonu **gördü** — ve buna rağmen
`sharedIndexedDb`'de **kaldı**. **OPFS üç koşumda da BOŞ:** göç **hiç başlamadı**.

⇒ **`B1` MEVCUT KULLANICI İÇİN AYAKTA.** Doğru ifade şudur:

| senaryo | izolasyon açılınca |
|---|---|
| **temiz kurulum** (deposu olmayan tarayıcı) | 🟢 `opfsLocks` — kendiliğinden, kod değişikliği **gerekmez** |
| **mevcut kullanıcı** (`sharedIndexedDb` deposu var) | 🔴 `sharedIndexedDb`'de **KALIR** — izolasyon **yetmez** |

Bu, `drift`in `_selectExistingDatabase` davranışıdır: var olan depo **tercih edilir**.
`moveExistingIndexedDbToOpfs` bayrağı **tam olarak bu vaka için** vardır ve `drift_flutter 0.3.1`
onu **geçiremez** (denetim `B1`'in ölçülmüş çekirdeği).

### `T5` için sonuç — gerekçe DEĞİŞTİ, gereklilik DOĞRULANDI

`K151/③`'ün gerekçesi artık *"drift OPFS'e hiç geçemez"* değil; ölçülmüş gerekçe:
**"mevcut kullanıcı OPFS'e geçemez ve verisi IndexedDB'de kalır."** `T5`'in maliyeti
(dosya bölmesi · `W2`'nin `onResult` dikişini taşıma) **bu bedele karşılık** tartılmalıdır.
🔴 **Karar Onur'undur; `K151` yürürlüktedir.** (`K26`: üreten kendi çıktısını adjudike edemez.)

---

## 🔴 BU ÖLÇÜMÜN KENDİ KUSURU DA ÜRETİLDİ VE YAKALANDI

İlk koşumda **üç koşumun üçü de** `crossOriginIsolated = false` verdi — yani koşum 2 **kördü** ve
*"göç olmadı"* diye okunacaktı. Sebep ölçüldü: **kalıcı profil + HTTP önbelleği** — koşum 1'de
önbelleğe giren `index.html` koşum 2'de **başlıksız** hâliyle geri servis edildi.

Onarım **iki katmanlı**: ① sunucu `Cache-Control: no-store` gönderiyor ② betik artık her koşumda
`crossOriginIsolated == beklenen` diye **doğruluyor**; tutmazsa koşumu **`KOR`** işaretliyor ve
`EXIT 1` ile hüküm vermeyi **reddediyor**. **Bu muhafız bu oturumda üçüncü kez gerekti**
(`M-W3-1` mutantı iki kez kör koşmuştu) — sınıf: *ölçüm aracının kendi kusurunu ürüne yazmak.*

## NE ÖLÇÜLEMEDİ (boş olamaz)

1. **SATIR DÜZEYİNDE KULLANICI VERİSİ.** Depoda drift'in kendi şeması var; **UI'dan görev
   eklenmedi** çünkü Flutter web **CanvasKit** ile çiziyor ve DOM'da tıklanacak öğe yok
   (semantics açılmadı). *"Kullanıcının görevleri kayboldu mu"* sorusu **ÖLÇÜLMEDİ** — ölçülen
   *"depo hangi tarafta"* sorusudur.
2. **`moveExistingIndexedDbToOpfs: true` ile davranış.** Bayrak geçirilemediği için
   **denenmedi**; göçün *çalışıp çalışmadığı* değil, **hiç tetiklenmediği** ölçüldü.
3. **Denetimin `B-11`'i (yarıda kalan göç ⇒ öksüz kopya)** — göç hiç başlamadığı için
   **hâlâ ÖLÇÜLMEDİ** ve **açık kalıyor**.
4. **`opfsShared`** hiçbir koşumda görülmedi; `dedicatedWorkersInSharedWorkers` her koşumda eksik.
   Headless Chromium kaynaklı olabilir — **ölçülmedi**.
5. **Onur'un makinesinde hiçbiri**; Flutter **3.44.9 ≠ 3.44.6**.
6. **Gerçek tarayıcı çeşitliliği yok** — yalnız Chromium; Firefox/Safari **ölçülmedi**.

**Koşucu:** `KANIT/W3/_gocu_olc.py` (üç koşum + `KOR` muhafızı) · kontrol: `_o2_olc.py`.
