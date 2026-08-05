# GOREV-W2 — Mutant koşumu (M200–M216 + MW20) ham sonuç + analiz

> **Bu dosya bir KABUL BEYANI DEĞİLDİR (K11/K26).** `KANIT/W2/_mutant_kosucu.py`'yi
> YAZAN el (Claude Code, oturum 59) bu dosyayı da yazmıştır ve bu, koşumun HÜKMÜNÜ
> VERMEZ — yalnız runner'ın ürettiği ham veriyi teknik olarak açıklar. Koşumun
> kendisi runner'ı YAZMAMIŞ bağımsız bir ajan tarafından çalıştırılmış ve ham
> sonuç birebir raporlanmıştır (bu raporun tamamı `KANIT/W2/_KOSUM-*.txt` ve
> `_KOSUM-OZET.txt` dosyalarından türetilmiştir — hiçbir sayı uydurulmadı).

## 1. Bağımsız denetim (runner'ı yazmamış ajan tarafından, çalıştırmadan ÖNCE)

Dört kritere göre kontrol edildi, **kusur bulunamadı**:
- TAM EŞİTLİK mi (`==`), alt küme mi (`<=`)? → **TAM EŞİTLİK** (`gozlenen_ayaklar == hedef`, satır 345).
- Geri-yazma `try/finally` içinde mi? → **EVET** (satır 322–338).
- MW20 gerçekten hiçbir dosyaya dokunmadan mı koşuyor? → **EVET** (satır 372, boş dosya listesiyle `flutter_test_json([], ...)`, öncesinde `yaz()` çağrısı yok).
- sha256 bayt-özdeşlik kontrolü var mı? → **EVET** (satır 75-76, 332-338).

## 2. Sayısal özet

- **MW20 (negatif kontrol): KALDI** (beklenen) — runner'ın kendisi BOZUK değil.
- **TEMİZ-ÖNCE ve TEMİZ-SONRA: ikisi de EXIT 0, sıfır kırmızı.**
- **Bayt-özdeşlik: 4/4 dosya `ozdes=True`** (revert sonrası sha8 taban ile birebir: `depolama_durumu.dart` C46A2F05, `depolama_seridi.dart` 68FC299B, `veritabani.dart` 84D87200, `main.dart` 3B2966E4).
- **`git --no-optional-locks status --porcelain` (koşum sonrası, bağımsız doğrulama):** 4 mutasyonlanan dosyanın hiçbiri görünmüyor — `git diff --stat` bu dört dosya için **boş** döndü (kriterion 5, Claude Code'un kendi ölçümü).
- **TAM EŞİTLİK ile eşleşen mutant: 13/17.**
- **ESLESMEDI: 4/17** — **hepsi AŞIRI-YAKALAMA (gözlenen ⊇ hedef), HİÇBİRİ KÖR KAPI (gözlenen ⊉ hedef) DEĞİL.** Yani mutasyonun HİÇBİRİ hayatta kalmadı (hepsi bir yerden ısırdı) — sorun yalnız "hangi ayak adının kırmızıya düştüğü" kümesinin spec'in dar `hedef` beyanını AŞMASI.

## 3. Ham sonuç tablosu (17/17)

| Mutant | hedef | gözlenen | Eşitlik | Kök sebep |
|---|---|---|---|---|
| M200 | {G39/b} | {G39/b, G39/e, G39/g} | ❌ | §4.1 |
| M201 | {G39/c} | {G39/c} | ✅ | — |
| M202 | {G39/d} | {G39/d} | ✅ | — |
| M213 | {G39/e} | {G39/e} | ✅ | — |
| M203 | {G40/a} | {G40/a} | ✅ | — |
| M204 | {G40/a, G40/b} | {G40/a, G40/b, G40/e, G40/f} | ❌ | §4.2 |
| M206 | {G40/b} | {G40/a, G40/b, G40/e} | ❌ | §4.2 |
| M205 | {G40/e} | {G40/e} | ✅ | — |
| M208 | {G40/d} | {G40/d} | ✅ | — |
| M207 | {G40/c} | {G40/c, G40/f} | ❌ | §4.3 |
| M214 | {G40/f} | {G40/f} | ✅ | — |
| M209 | {G39/a, G41/a} | {G39/a, G41/a} | ✅ | — |
| M210 | {G42/a} | {G42/a} | ✅ | — |
| M216 | {G42/a} | {G42/a} | ✅ | — |
| M215 | {G42/a} | {G42/a} | ✅ | — |
| M211 | {G42/b} | {G42/b} | ✅ | — |
| M212 | {G42/c} | {G42/c} | ✅ | — |

## 4. Kök sebep analizi (üç sınıf, hepsi yapısal — test yazarken keşfedildi, gizlenmedi)

### 4.1 — M200: `depolamaSinifiCoz`'un TEK ortak "aksi halde" dönüşü

`D-W2-2`'nin ④ maddesi ("aksi hâlde ⇒ geriDusus") **kasıtlı olarak** tek bir `return`
satırıdır (`depolama_durumu.dart`) ve spec'in kendi G39 tablosu bu dalı ÜÇ ayrı ayakla
sınar: `b) bilinmeyen ad`, `e) bilinmeyen api`, `g) null+null` — üçü de AYNI kod yoluna
düşer. M200 bu TEK satırı mutasyonluyor ⇒ üçü de aynı anda kırmızıya düşüyor. Bu,
kodun YANLIŞ yazıldığı anlamına GELMEZ — tam tersi, D-W2-2'nin "④ aksi halde" maddesini
tek bir dal olarak doğru uygulamanın DOĞAL sonucu. **Spec'in mutant tablosu bu üç
ayağın AYNI koddan geçtiğini hesaba katmamış** (hedef yalnız `G39/b` yazmış).

### 4.2 — M204 / M206: `G40/a`'nın gömülü pozitif kontrolü + `G40/e`'nin örnek durumu

Spec'in KENDİSİ `G40/a`'yı şöyle tanımlıyor: *"kaliciOpfs ⇒ YOK (**pozitif kontrol:
aynı testte** geriDusus ⇒ VAR)"* — yani `G40/a`'nın test gövdesi spec'in EMRİYLE
`geriDusus` durumunu da sınar. Bu yüzden `geriDusus` render yolunu bozan HER mutasyon
(`M204`: durumu gizler, `M206`: ikonu kaldırır) `G40/a`'yı da kırmızıya düşürür — ki
`M204`'ün hedefi zaten `G40/a`'yı İÇERİYOR (beklenen), ama `M206`'nın hedefi
İÇERMİYOR (beklenmeyen ek). Ayrıca bu iki test dosyasında `G40/e` de örnek durum
olarak `geriDusus` kullanıyor (spec `G40/e` için belirli bir durum ZORUNLU KILMIYOR
— bu benim seçimim) ⇒ `G40/e` de aynı iki mutasyondan kırmızıya düşüyor.
**Kısmi düzeltilebilir:** `G40/e`'yi `kaliciDegil` durumuna geçirmek `M204`/`M206`'nın
fazladan yakaladığı ayak sayısını BİRER azaltır, ama `G40/a`'nın gömülü kontrolü
spec'in kendi metniyle sabitlendiği için `M204`/`M206` yine de tam eşleşmez
(M206 hedefi hiç `G40/a` içermiyor ve bu embed spec'in kendi tasarımı).

### 4.3 — M207: `G40/f`'in başlangıç sabiti olarak `olculmedi()`'yi kullanması

`D-W2-7` PAZARLIKSIZ olarak native/varsayılan başlangıç değerinin
`const DepolamaDurumu.olculmedi()` SABİTİ olmasını ister; `G40/f`'in kendisi de
("olculmedi → geriDusus geçişi") bu SABİTİ başlangıç noktası olarak kullanmak
ZORUNDADIR (spec'in kendi ayak tanımı). M207 tam olarak bu sabitin `sinif` alanını
mutasyonluyor ⇒ `G40/f`'in "geçişten ÖNCE duyuru YOK" ön-koşulu da bozuluyor (mount
anında zaten `geriDusus` görünüyor ve erken bir duyuru tetikleniyor) — `G40/c`'nin
yanına `G40/f` de ekleniyor.

## 5. Neden bunlar "kör kapı" DEĞİL

`spec-kapi-kapsama.py`'nin BEYAN EDİLMİŞ SINIRI şudur: *"eşdeğer-mutant tespiti
çalışan kod ister; yalnızca KAPSAMA ölçülür."* Burada durum TAM TERSİ: mutant
ÇALIŞAN KODLA ısırdı (hiçbiri `HAYATTA KALMADI`), üstelik **hedeflenenden FAZLA**
ayaktan ısırdı. Bu üç sınıf da spec'in KENDİ ayak tasarımının (paylaşılan kod dalı,
gömülü pozitif kontrol, paylaşılan sabit) doğal, DOĞRU bir sonucu — kodda ya da
testte gizli bir kusur değil.

## 6. Öneri (karar Cowork'e aittir, burada DAYATILMIYOR)

Üç seçenek görünüyor, hiçbiri bu turda uygulanmadı (K53/1 + K127: kilitli spec'e
üçüncü tur yok, kilit değişikliği Onur'dan gelir):

1. **Spec hatası kaydı (erratum):** `hedef` sütunu bu dört mutant için genişletilir
   (`M200`→`{G39/b,G39/e,G39/g}`, `M204`→`{G40/a,G40/b,G40/e,G40/f}`,
   `M206`→`{G40/a,G40/b,G40/e}`, `M207`→`{G40/c,G40/f}`) — yeni bir K numarasıyla,
   spec dosyasına DOKUNULMADAN (append-only PROJE_HAFIZA.md'ye not, ya da yeni kilitli
   v4 turu).
2. **Test yeniden tasarımı:** `G40/e`'yi `kaliciDegil`'e taşımak (benim yetkim
   dahilinde, spec'e dokunmaz) `M206`'nın fazlasını 3→2'ye indirir ama TAM eşleşme
   yine sağlanmaz (G40/a gömülü kontrolü kalıcıdır).
3. **Olduğu gibi kabul:** 13/17 tam eşleşme + 4/17 "aşırı-yakalama" (kör kapı değil)
   yeterli kabul edilir; kriter 4'ün "TAM EŞİTLİK" lafzı ile "mutant hiçbiri hayatta
   kalmadı" ruhu arasındaki gerilim NOT edilir.

**Bu üç seçenekten hiçbirini ben seçmedim — bu, Cowork'ün K26 kapsamındaki bağımsız
kararıdır.**
