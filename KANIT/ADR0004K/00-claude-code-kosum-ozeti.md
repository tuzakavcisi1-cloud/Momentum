# GOREV-ADR0004-KAPISI — Claude Code kendi koşumunun özeti

> **KABUL HÜKMÜ DEĞİLDİR** (K26/K34-f). Altın küme koşumu, 27 mutant + 5 NK koşumu ve
> nihai HÜKÜM **Cowork'ündür**. Aşağıdaki sayılar bu betiği YAZAN elin **kendi**
> ölçümüdür.

## 1. Üretilen dosyalar

- `araclar/sinif-sozlugu-uret.py` — `PROJE_RADAR.jsonl`'dan **betikle** türetici (K148-b).
- `araclar/sinif-sozlugu.json` — 115 girdi (tanım + 5 `ayrı_tutuldu` çift), 22.460 b.
- `araclar/adr-hukum-kapisi.py` — G52–G56, 22 ayak.
- `araclar/fixture/adr-hukum/pozitif-kontrol.md` + `pozitif-kontrol-kapilar.md`.
- `KAPILAR.md` — yeni kapı-tetik satırı eklendi.

## 2. Kriter kriter (kendi ölçümüm)

| # | kriter | sonuç |
|---|---|---|
| 1 | `adr-hukum-kapisi.py --altin-kume` | **EXIT 0, 37/37 GEÇTİ** — 22 ayağın 22'si temiz+kirli vaka ile |
| 2 | 27 mutant + 5 NK koşumu | **Cowork'ün işi** — bu turda koşulmadı |
| 3 | Gerçek `docs/ADR/0004-…` denetimi | **EXIT 2 KIRMIZI** — V1 (G52/a2) · V2 (G53/a2, Izolasyon:Etkin) · V3 (G53/d, UseCors) · V6 (G55/a, yayin-kapisi.py kimlik üzerinden) hepsi bulundu + öngörülen ek bulgu (`Cors:AllowedOrigins`, §8/10) |
| 4 | `araclar` (dizin) argümanı | **[S0] BİÇİM, EXIT 4** |
| 5 | `belge-tavan-kapisi.py .` | **YEŞİL (EXIT 0)** |
| 6 | D-K170-5 beyan satırı | her koşumda basılıyor (rapor altında) |
| 7 | `sayi-tazeligi.py .` | **EXIT 1 — ÖN-VAROLAN, BENİM İŞİM DEĞİL** (bkz. §3) |
| 8 | `spec-kapi-kapsama.py GOREV-ADR0004-KAPISI.md` | **EXIT 0** |
| 9 | Defter satırı | Cowork'ün işi (mutant koşumundan sonra) |
| 10 | `git config user.email` | `onurkesimbjk@gmail.com` (ölçüldü) |
| 11 | Öz-test (K108) | golden set vaka 35: fixture `KAPILAR.md`'den araç satırı silinince **KIRMIZI** |
| 12 | `DURUM.md:121` beş ayak + §6 sayaç | **YAZILMADI** — Onur'un açık talimatı (bkz. §4) |

## 3. `sayi-tazeligi.py` EXIT 1 — BENİM İŞİM DEĞİL, ölçüldü

`sayi-tazeligi.py .` iki `[SARI] T1b` bulgusu veriyor: `DURUM.md:158` ve
`KIMLIKLER.md:49`, ikisi de `tek-kopya-mutant.py`'nin golden set "GEÇEN" sayısı
(belge 10 diyor, araç 11 geçti) hakkında. **Bu iki dosyaya bu oturumda HİÇ
DOKUNMADIM** (DURUM.md'ye dokunmama talimatı zaten vardı; KIMLIKLER.md'ye hiç
girmedim) — bulgu **ön-var olan, benim işimin dışında** bir staleness'tır.
Kriter 7 bu haliyle **KARŞILANMIYOR** ama sebep benim değişikliğim değil.

## 4. DURUM.md — DOKUNULMADI, yalnız ÖLÇÜLDÜ (Onur'un açık talimatı)

Mevcut pay: **31.073 b / 32.768 b** (SARI eşiği 31.129,6 b — yalnız **~56 b**
serbest, spec'in "53 bayt" ölçümüyle örtüşüyor).

Gerekli üç düzenlemenin (§4/5b,c,d) **ölçülmüş net bayt etkisi**:

| düzenleme | bayt etkisi |
|---|---|
| b) §6 yeni tablo satırı (`adr-hukum-kapisi.py`) | **+220 b** |
| c) §6 envanter sayaç cümlesi (o67 ölçümüyle yeniden yazılırsa) | **-146 b** (daha kısa yazılabilir) |
| d) §5 K170 satırı: "üç ayağı" → "beş ayak" | **-3 b** |
| **TOPLAM NET** | **+71 b** |

**+71 b, mevcut ~56 b'lik payı AŞAR** — bu üçü budama YAPILMADAN eklenirse
`belge-tavan-kapisi.py` **SARI** verir (henüz KIRMIZI değil, 32.768'i aşmaz).
Spec'in kendi hedefi ("eklenen bayt + ≥300 b emniyet payı") karşılanması için
**en az ~371 b** boş alan açacak bir budama gerekir. Budanacak satırı **Onur
seçer** (K73); bu ölçüm yalnız BİLDİRİM amaçlıdır, hiçbir yazım yapılmadı.

## 5. Envanter ölçümleri (§4/5c komutlarıyla, bugün — 10 Ağu 2026)

```
ls araclar/*.py | wc -l                          => 28
ls araclar/*.py araclar/*.ps1 | wc -l             => 29
ls araclar/*.json | wc -l                         => 5
find araclar -maxdepth 1 -type f | wc -l          => 37
find araclar -maxdepth 1 -mindepth 1 -type d | wc -l => 2
ls -A araclar | wc -l                             => 39
```

Bu sayılar `adr-hukum-kapisi.py` + `sinif-sozlugu.json` + `sinif-sozlugu-uret.py`
+ `fixture/` dizini (2 dosya) **dahil edilerek** ölçüldü.

## 6. Ölçemediğim / yapmadığım (Onur'un açık üç yasağı + doğal sınırlar)

1. **27 mutant + 5 NK hiç koşulmadı** — Onur'un açık talimatı, Cowork'ün işi (K26).
2. **DURUM.md'ye tek bayt yazılmadı** — Onur'un açık talimatı; §4'te yalnız ÖLÇÜM var.
3. **`docs/ADR/0004` gövdesine tek bayt yazılmadı** — Onur'un açık talimatı (K170).
4. `sayi-tazeligi.py`'nin iki ön-var olan SARI bulgusu **onarılmadı** (kapsam dışı,
   §3'te açıklandı).
5. G54/d'nin "kilit metni" registry'si yalnız **K21** için (DURUM.md §5'in canlı
   K21 satırı kanonik kaynak) örnekle kuruldu; başka kilitler (K26 vb.) için
   registry GENİŞLETİLEBİLİR ama bu turda genişletilmedi — spesifik bir kilit
   listesi spec'te verilmediği için kapsam BEYAN edilmiş bir sınırdır.
6. G53/d'nin C# çözümlemesi basit bir "geriye 5 satır, açık if(" sezgiseldir;
   iç içe `if`/ternary/`when` **[DOĞRULANMADI]** (spec §9 zaten bunu ölçülmedi
   diye işaretlemişti).
7. `.git/index.lock`: her iki commit'ten sonra da **yok** (ölçüldü, aşağıda).
