# KANIT/CI/10 — KABUL HÜKMÜ (COWORK, bağımsız koşum) · `D-A13-4` · o69

> `K26`: hiçbir kriter builder'ın beyanıyla kabul edilmedi. Aşağıdaki her satır
> **Cowork'ün KENDİ koşumudur**, aksi açıkça yazılmıştır.
> Ölçüm yeri: cihaz mount'u (`device_bash`) + bulut konteyneri (pwsh 7.4.6).

## HÜKÜM: 🟡 **KOŞULLU KABUL** — kriter 9 (gerçek CI koşumu) AÇIK, push bekliyor.

| kriter | kim ölçtü | sonuç |
|---|---|---|
| 1 taban | **COWORK** | `ls-files --cached --others --exclude-standard` ⇒ **32 · 6 · 41** — KORUNUYOR ✔ |
| 2 dosya kümesi | **COWORK** | `12f0d6a` **13 dosya**: ci.yml · verify.ps1 · ci-kapisi.py · GOREV-A13 · GOREV-W3b · DURUM.md + `KANIT/CI/**`. İzin verilen kümenin **DIŞINDA hiçbir yol yok** ✔ |
| 3 çıkarma testi | **COWORK** | `difflib` opcode dökümü: `[('equal',30,30), ('insert',0,17)]` ⇒ **TAM 1 ekleme, 0 replace/delete**. Blok çıkarılınca kalan **580 b · `283D785E…C22D1`** = `KANIT/CI/04`'teki pin ile **BAYT-ÖZDEŞ** ✔ |
| 4 Linux ayağı | **COWORK (bulut, pwsh 7.4.6)** | ayrıştırma **0 hata** · satır 26 **fırlatmıyor** (`Test-Path False` ⇒ `$dotnet` varsayılanda kalır) · satır 57 **ters eğik çizgi taşımıyor** (`/tmp/sahte/KANIT/slice-3d/07-G7-backend-zorlama`) · gerçek koşum satır 26'yı **geçip** satır 37'de yalnız `dotnet` kurulu olmadığı için düştü ✔ |
| 4 Windows ayağı | **BUILDER** (denetlendi, yeniden koşulmadı — `K80`) | `KANIT/CI/08`: `dotnet : C:\Program Files\dotnet\dotnet.exe` (64-bit tercihi **korunmuş**) · `== VERIFY PASSED ==` · EXITCODE=0 |
| 5 altın küme | **COWORK** | `ci-kapisi.py --altin-kume` ⇒ **22/22 GEÇTİ, EXIT 0** (taban 13/13'tü) ✔ |
| 6 statik mutant | **COWORK** | `S1` (backend işi silindi) ⇒ `['G31a','G31b','G31d']` **ISIRDI** ✔ — ayrıca bkz. §"Cowork'ün kendi saldırıları" |
| 7 koşan mutant | **BUILDER** (denetlendi — `K80`: Cowork ortam kaldırmaz) | `M-o69-1..4` + `K80` ön koşulu (`docker info` yoklamalı 0,5 s · `:5298` boş · taban koşum `Persistence.Tests` 56/56). Ayırt edici kanıtlar **birebir** yazılmış |
| 8 geri yükleme | **COWORK** | `git status --porcelain -- src tests` ⇒ **0 kayıt**; gerçek `ci.yml` **957 b · `D3C4DA5A`**, CRLF 0 · mutant kalıntısı **YOK** ✔ |
| 9 gerçek CI | — | 🔴 **AÇIK.** `rev-list` ⇒ `0 1`: `12f0d6a` **gönderilmemiş**. Push Onur'da |
| 10 kimlik | **COWORK** | `12f0d6a` author **`Onur Kesim <onurkesimbjk@gmail.com>`**, `.git/index.lock` **YOK** ✔ |

## 🟢 BUILDER'IN KENDİ DENETİMİ GERÇEK BİR KÖR KAPI BULDU — BAĞIMSIZ DOĞRULANDI
Builder taze bağlamlı bir ajanla kendi çıktısını denetletti; ajan **akış-stili (flow-style) YAML**
kör kapısını buldu (`KANIT/CI/09`). Cowork o üç saldırıyı **kendi kurduğu geçici depoda yeniden koştu**:
```
R1) kuresel defaults akis-stili + shell:pwsh          exit=1  ['G31h']
R2) backend'e services akis-stili                     exit=1  ['G31h']
R3) ios tamamen akis-stili + if:false                 exit=1  ['G31h']
0)  TEMIZ gercek ci.yml                               exit=0  GECTI
```
⇒ **Düzeltme GERÇEK.** `G31/h` tur-2'nin `Y2` saldırısının akış-stili varyantını kapatıyor.

## 🔎 COWORK'ÜN KENDİ SALDIRILARI (`G31/h`'yi AŞMAYA çalıştı)
```
X1) COK SATIRLI akis-stili kuresel defaults            exit=1  ['G31e','G31h']  ISIRDI
X2) DIZI OGESI akis-stili: verify adimi shell:bash     exit=1  ['G31b']         ISIRDI
X3) steps TAMAMEN akis-dizisi (backend)                exit=1  ['G31b']         ISIRDI
X6) POZITIF KONTROL workflow_dispatch: { } (bosluklu)  exit=0  GECTI (istisna calisiyor)
X7) backend isi TAMAMEN silindi                        exit=1  ['G31a','G31b','G31d'] ISIRDI
X4) defaults: { } + gizli x_gizli blogu                exit=0  🔴 GECTI
X5) kuresel defaults blogu TAMAMEN SILINDI (akis YOK)  exit=0  🔴 GECTI
```
🔴 **BULGU (yeni borç, BLOKER DEĞİL):** `X4`/`X5` gösteriyor ki **hiçbir ayak küresel
`defaults.run.working-directory: src/client`'ın VAR OLDUĞUNU pinlemiyor.** Bu **akış-stiline özgü
değildir** (`X5` düz blok stiliyle de geçti) ⇒ `G31/h`'nin kusuru değil, **önceden var olan bir
boşluktur**. Bu turda **kriter 3 (çıkarma testi) onu yakalar** (silme ⇒ saf ekleme değil) ve CI
koşumu da yüksek sesle düşerdi. **Borç olarak beyan edilir.**

## ⚖ `M-o69-4` (CVE mutantı) ADJUDİKASYONU — builder `K26` gereği hüküm vermedi, Cowork veriyor
**KABUL — ERRATUM ve BEYAN EDİLMİŞ SINIR ile.**
- Ölçülen: mutant `verify.ps1`'i **gerçekten KIRMIZI** yapıyor (exit 1, `== VERIFY PASSED ==` yok),
  **ama build adımında** — `NU1903` + `GHSA-5crp-9r3c-p9vr` — CVE gate adımında değil.
- Kök neden ölçüldü: `Directory.Build.props` `<NuGetAudit>true</NuGetAudit>` + `<NuGetAuditMode>all</NuGetAuditMode>`
  + `TreatWarningsAsErrors` ⇒ audit **restore/build aşamasında** yakalıyor, açık CVE bloğu **arkada kalıyor**.
- Builder ayrı bir **tanı** koşumuyla (`NuGetAudit=false`) CVE bloğunun **ölü kod OLMADIĞINI** ve aynı
  açığı doğru tespit ettiğini gösterdi.
- 🔴 **KUSUR İŞ EMRİNİNDİR, BUILDER'IN DEĞİL.** *"CVE gate adımında KIRMIZI"* beklentisini yazan el
  **Cowork'tü** ve `NuGetAudit=true` satırı **kendi ölçüm çıktısında zaten duruyordu** — okunmadı.
  Bu, bu oturumun **`ölçüldü ama okunmadı`** sınıfındaki **yedinci** kusurudur.
- **DÜZELTİLEN ÖLÇÜT:** `M-o69-4`'ün ayırt edici kanıtı ⇒ *"build adımında `NU1903` + advisory URL,
  `== VERIFY PASSED ==` YOK"*. **BEYAN EDİLMİŞ SINIR:** mevcut yapılandırmada `verify.ps1`'in açık
  CVE bloğu bu senaryo için **ulaşılamazdır**; **ikinci katman** savunmadır ve canlılığı yalnız
  `NuGetAudit` kapalıyken gözlemlenebilir. `K155` **ihlal edilmedi**: ayağın mutantı var ve **ısırıyor**.

## AÇIK KALANLAR
- 🔴 **kriter 9** — push sonrası `gh run list --branch main --workflow ci --limit 5` ile ölçülecek;
  logda dört çapa aranacak: `--- build -warnaserror ---` · `--- test ---` ·
  `--- CVE gate (dotnet list package --vulnerable) ---` · `== VERIFY PASSED ==`.
- 🔴 **`B-O63-2` AÇIK** (`--no-web-resources-cdn` CI'ya bağlanmadı) — iş emri §6'da beyanlı.
- 🔴 **YENİ BORÇ:** küresel `defaults.run.working-directory` varlığını pinleyen ayak **yok** (`X4`/`X5`).
- 🔴 **`R8`:** bu tur `ci.yml`+araç+belge üretti; `K53`/4 gereği `urun_kodu_satiri` **0**.
  İki oturum üst üste 0 ⇒ **sert durak**; sonraki tur **ürün koduyla** başlamalıdır.
