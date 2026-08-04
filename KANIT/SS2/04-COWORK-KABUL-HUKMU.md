# `SS2` KABUL HÜKMÜ — Cowork'ün KENDİ koşumu (4 Ağu 2026, oturum 56 · Onur kilitledi)

**Spec:** `GOREV_CLAUDE_CODE/GOREV-SS2-cakisma-cozumu.md` v3, `K133`, **46.003 b / `420E9F91`**
**Uygulama:** Claude Code `b900bae` (`T0`–`T8`, +5831/−69), `K134`
**Kural (K26):** dokuz kriterin dokuzu da **Cowork'ün kendi koşumuyla** ölçüldü; üreten ≠ denetleyen.

## Dokuz kriter

| # | kriter | ölçüm | hüküm |
|---|---|---|---|
| 1 | `flutter analyze` 0 sorun | `No issues found!` (oturum 55) | 🟢 |
| 2 | `flutter test` tamamı yeşil | **522/522** (oturum 55) | 🟢 |
| 3 | `SS2/G31`–`G34` her ayak | `ss2-kapisi.py .` **BULGU YOK** (oturum 56'da **güçlendirilmiş** araçla yeniden ölçüldü: `KANIT/o56/16-ss2-gercek-repo.txt`) | 🟢 |
| 4 | `M171`–`M188` ısırır (`M171c` susar) | builder **23/23** + Cowork'ün bağımsız `count(distinct)` örneklemesi **4/4** ısırdı (`T7-COWORK-distinct-6li-olcum.txt`) | 🟡 **örneklem** — Cowork 23'ün tamamını değil, seçtiği alt kümeyi koştu |
| 5 | `spec-kapi-kapsama.py` `[S0]/[S1]/[S2]` yok | EXIT 0 (`T8/spec-kapi-kapsama-SS2.txt`) | 🟢 |
| 6 | `ss2-kapisi.py --altin-kume` EXIT 0 | oturum 55'te **10/10**; oturum 56'da **14/14** (`KANIT/o56/15-ss2-altin-kume-14.txt`) | 🟢 |
| 7 | `verify.ps1` EXIT 0 | EXIT 0 · backend **120/120** · CVE **0** (`T8-verify-ps1.txt`) | 🟢 |
| 8 | **uçtan uca** | **`KANIT/o56/65-KRITER8-HUKUM.md`** — çakışma rozeti çıktı, iki değer ekranda, *Benimkini tut* A'ya ulaştı, iki `clientId` + HLC sırası **sunucu veritabanından** ölçüldü | 🟢 **beyan edilmiş sapmayla** |
| 9 | `KANIT/SS2/` ham çıktılar | `T0`–`T8` + `KANIT/o56/` | 🟢 |

**HÜKÜM: `SS2` KABUL EDİLDİ** (Onur kilitledi, 4 Ağu 2026) — **kapanmamış sınırlarla**
(`A13`/`K130` emsali: beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez).

## Kabulün taşıdığı AÇIK sınırlar (hepsi beyan, hiçbiri gizli)

1. 🔴 **Kriter 8 spec'in LAFZIYLA koşulmadı.** Spec ④/⑤ *"başlık `B1`/`A1` yapılır"* diyor;
   **üründe başlık düzenleyen bir etkileşim YOK** (`KANIT/o56/34-KRITER8-SPEC-KOSULAMAZ.md`:
   `duzenle()` `lib/` içinde yalnız `cakismaCoz`'dan çağrılıyor; satır `onTap` taşımıyor).
   Çakışma **tamamlanma anahtarıyla** üretildi — aynı mekanizma (`G32` dört şart · `G33` rozet +
   projeksiyon · `G34` çözüm), farklı alan. **Spec bu kabulle uyumlu hâle GETİRİLMEDİ; kilit
   açılmadı.**
2. 🔴 **Kuyruğun KENDİLİĞİNDEN boşalma süresi ÖLÇÜLMEDİ.** Bu koşumda **Yenile** ile bir tur
   zorlandı. *"Zorlanan turda boşaldı"* ölçüldü; *"kendiliğinden N s'de boşalır"* **ölçülmedi**.
3. 🔴 **Kriter 4 bir ÖRNEKLEMDİR** (yukarıda 🟡). Builder'ın 23/23 beyanı Cowork'ün dört ayaklı
   bağımsız örneklemesiyle desteklendi; **yirmi üçün tamamı Cowork tarafından koşulmadı.**
4. 🔴 **Açık borçlar:** `B-SS2-1`…`B-SS2-4` (spec §8 ve `BORCLAR.md`) + **`B-SS2-5`**
   (oturum 56: `M172`'nin *beklenen* metni gerçeği tarif etmiyor).
5. 🟡 **Fiziksel cihaz USB tüneliyle bağlandı** (`adb reverse`) ⇒ **NAT/Wi-Fi yolu geçilmedi**;
   `SignalR` yeniden bağlanma borcu **KAPANMADI**.
6. 🟡 Telefonda geçici olarak `accelerometer_rotation 1→0` ve `svc power stayon usb` yapıldı;
   ikisi de ölçüm iskelesidir, oturum sonunda geri alınır.

## Kabulün DIŞINDA kalan, bu turda ONARILAN kusur
`ss2-kapisi.py`'nin **blok yorum kör kapısı** (`K135`): `/* schemaVersion => 5 */` yorumdayken
gerçek kod `=> 4` olduğunda araç **yanlış susuyordu**. Onarıldı, altın küme **10 → 14**, onarımın
yük taşıdığı **`M-o56-1`** mutantıyla kanıtlandı (12/14, geri alma bayt-özdeş).
