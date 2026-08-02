# `GOREV-A11` — KABUL HÜKMÜ (Cowork'ün bağımsız koşumu, K26 · 2 Ağu 2026, oturum 50)

**Denetlenen commit:** `8e82568` (Claude Code, `G22`/`c2` ayağı) · HEAD temiz, `index.lock` YOK

## Builder'ın beyanı DOĞRULANDI — ölçülerek, okunarak değil

| iddia | ölçüm | sonuç |
|---|---|---|
| *"spec §5'teki metinle birebir"* | `_c2_birebir_mi.py`: spec'in tek `dart` bloğu test dosyasında **AYNEN** var | ✅ BİREBİR |
| *"ürün kodunda kalıcı değişiklik yok"* | `itme_yeniden_deneme.dart` **`50B88E92`** · `senkron_dongusu.dart` **`0435E333`** · `yoklama-yasagi-kapisi.py` **`8F8BBB66`** — üçü de **oturum 50 başındaki değerle aynı** | ✅ DEĞİŞMEMİŞ |
| *"tam paket 500/500"* | `flutter test` ⇒ **500/500**, EXIT 0 | ✅ |
| *"`M141` artık ısırıyor"* | tam koşum: **17/17** | ✅ |

🔴 **Ürün kodunun bayt-özdeş kalması, kriter 0 ve kriter 7'nin ÖNCEKİ kanıtını da diri tutar** —
o kanıtlar ürün davranışını ölçüyordu ve davranışı üreten baytlar değişmedi. Bu bir varsayım değil,
`dosya-kimlik.py` ile **ölçülmüş** bir zincirdir.

## Kabul kriterleri (spec §7) — hepsi ÖLÇÜLDÜ

| # | kriter | ölçüm | hüküm |
|---|---|---|---|
| 0 | yürüyen iskelet: `fakeAsync` + gerçek dosya tabanlı Drift | `NativeDatabase(File(...))` + `fake_async`, tüm ayaklar geçiyor | ✅ |
| 1 | `yoklama-yasagi-kapisi.py --altin-kume` ⇒ EXIT 0, vaka ≥25 | EXIT 0, **26/26 vaka** | ✅ |
| 2 | `yoklama-yasagi-kapisi.py .` ⇒ EXIT 0 | EXIT 0 | ✅ |
| 3 | `flutter analyze --fatal-infos` | **No issues found (6,3 s)**, EXIT 0 | ✅ |
| 4 | `flutter test` ⇒ >485 | **500/500**, EXIT 0 | ✅ |
| 5 | `M139`–`M155` hepsi KIRMIZI + bayt-özdeş geri alma + temiz koşum EXIT 0 | **17/17 ISIRDI**; üç dosya `ozdes=True`; TEMIZ-ÖNCE **ve** TEMIZ-SONRA `DART`/`ALTIN`/`PROJE` üçü de **EXIT 0** | ✅ |
| 6 | `spec-kapi-kapsama.py` (`A11`) | EXIT 0 | ✅ |
| 7 | cihazda uçtan uca: ≥180 s çevrimdışı, `nc` probu, 120 s içinde dokunulmadan boşalma, rozet `cakisma` yok | `T0` 21:47:24 → `T1` 21:50:30 (**186 s**) → boşalma **`T1`+4 s**; tetikleyici **izole edildi** (`05-KRITER7-TETIKLEYICI-IZOLASYONU.md`) | ✅ |
| 8 | `powershell -File araclar\verify.ps1` | **VERIFY PASSED**, EXIT 0 — build 0/0 · test **120/120** (5+15+44+56) · CVE **0** | ✅ |

🔴 **Kriter 8, backend KAPALIYKEN ölçüldü** (`netstat :5298` boş) — v2.4'ün pazarlıksız sırası
(**7 → kapat → 8**) fiilen uygulandı.

## Açık kalan tek bulgu KAPANDI

`M141` oturum 50'nin ilk koşumunda **hayatta kalmıştı**; eşdeğerlik **yanlışlandı** (prob + orijinal
kod `EXIT 0`, prob + `M141` `EXIT 1`) ⇒ `A11/G22`/`c` **kördü**. Onur `c2`'yi kilitledi (K120),
Claude Code yazdı, Cowork bağımsız koştu: **`M141` artık `A11/G22`/`c2`'yi KIRMIZI yapıyor.**
Kanıt: `03-MUTANT-M141.txt` (`kapi A11/G22/c2` · `HUKUM: KIRMIZI (beklenen)` · `ozdes=True`).

## HÜKÜM

# ✅ `GOREV-A11` KABUL EDİLEBİLİR — sekiz kriterin sekizi de ölçülerek geçti.

**Kilit Onur'dan gelir.** Kabul edilirse K73 gereği `K116`/`K120` kilitleri `DURUM.md` §5'ten
çekilir ve kural bundan sonra prozada değil **`A11/G22`–`A11/G24` kapılarında + `M139`–`M155`
mutantlarında** yaşar.

## Beyan edilmiş sınırlar (gizlenmedi, taşındı)

1. **`B-O50-1`** — `main.dart:149` sinyal dinleyicisini ölçen **kapı yok**; kriter 7'nin izolasyonu
   o satıra dayanıyor ve `Y1` stream dinleyicisini taramıyor. **Borç, ayrı dilim.**
2. Spec §9'un kendi sınırları yürürlükte: fiziksel cihaz ölçülmedi · keepalive canlılık borcu ·
   `durdur()` üretimde çağrılmıyor · `408`/`429` kapsam dışı.
