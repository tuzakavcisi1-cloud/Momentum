# KANIT/CI/09 — Claude Code'un KENDİ tazeliğinde bağımsız denetimi (K26 ruhu)

> `K26`: "Üreten ≠ denetleyen" — bu turun **nihai** hükmü Cowork'ün (K176/§5.2).
> Ama teslimden ÖNCE, kendi yazdığımı kendim onaylamamak için **taze bağlamlı**
> bir ajana (kendi kodumu bilmeyen, iş emrini + KANIT'i sıfırdan okuyan)
> adversarial denetim yaptırdım. Bulduklarını burada **birebir** aktarıyorum
> ve nasıl kapattığımı (ya da kapatmadığımı) ölçümle gösteriyorum.

## BULGU 1 (EN AĞIR) — `ci-kapisi.py`: akış-stili (flow-style) YAML kör kapı

**Denetçinin bulduğu:** `_blok_ayikla`/`_is_bloklarini_ayikla` yalnız BLOK-STİLİ
(girintili) YAML anahtarlarını tanıyor. Denetçi üç sentetik `ci.yml` kurup
GERÇEK `ci-kapisi.py`'yi KOŞTURDU:
  - `defaults: {run: {shell: pwsh}}` (küresel, akış-stili)
  - `services: {postgres: {...}}` (backend işi içinde, akış-stili)
  - `ios: {runs-on: macos-latest, if: false, steps: [...]}` (iş TAMAMEN akış-stili)
Üçü de GEÇERLİ YAML'dır ve GitHub Actions AYNEN çalıştırır — üçü de tur-2'nin
`Y2` saldırısının (küresel shell / sessiz `if: false`) AKIŞ-STİLİYLE YENİDEN
AÇILMIŞ hâliydi. Üçü de `BULGU YOK, EXIT 0` verdi (G31/c, G31/e, G31/f'nin
regex'leri akış-stili içeriği GÖRMEDİ).

**DÜZELTME:** yeni ayak `A13/G31/h` eklendi — ci.yml'de akış-stili (`{...}`)
YALNIZ BOŞ hâliyle (`workflow_dispatch: {}`, dosyanın ZATEN taşıdığı tek
meşru kullanım) izinlidir; İÇİ DOLU her akış-stili eşleme KIRMIZI'dır. Bu,
her G31 ayağını TEK TEK akış-stili anlayacak şekilde genişletmek yerine
SINIFI TEK NOKTADAN kapatır.

**YENİDEN ÖLÇÜLDÜ — denetçinin ÜÇ saldırısı da BİREBİR tekrarlandı, ÜÇÜ DE
şimdi ISIRIYOR:**
```
Saldiri 1 (kuresel defaults flow-style + shell:pwsh gizli): ['G31h']
Saldiri 2 (services flow-style gizli):                      ['G31h']
Saldiri 3 (ios tamamen flow-style + if:false gizli):         ['G29a', 'G31h']
```
Altın küme: yeni vaka 22 (`defaults: {run: {working-directory: src/client}}`
→ `['G31h']`) eklendi. **22/22 GEÇTİ, EXIT 0.** Gerçek `ci.yml`: `BULGU YOK`,
EXIT 0 (yalnız `workflow_dispatch: {}` taşıyor, o istisna).

**Statik mutant (S5, kriter 6'nın tavansız sınıfı, K53/3) — gerçek dosyada
bayt-yaması ile koşuldu:**
```
mutant: kuresel defaults -> akis-stiline cevrildi
exit=1
[G31h] A13/G31/h: akis-stili (flow-style) YAML eslemesi bulundu: ...
geri yazildi, sha ozdes: True (d3c4da5ad2ab -> d3c4da5ad2ab)
```

## BULGU 2 — Kapsam disiplini (K175②): tam-agac `git status` iki dosya buldu

**Denetçinin bulduğu:** kendi kriter-2 ölçümüm yalnız ÖN-BELİRLENMİŞ altı
dizin/dosyaya BAKIYORDU (dizin dizin, ORTAM.md 44 gereği tam-ağaç KOŞULMADI)
— ama TAM AĞAÇ `git status --porcelain` (denetçinin KENDİ yaptığı, filtresiz)
iki fazlalık buldu:
  1. `PROJE_HAFIZA.md.yedek` (1,2 MB, izlenmeyen) — `hafiza-dizin.py`'nin
     ORTAM.md'de BEYAN EDİLMİŞ bilinen artığı (mount'ta `os.remove` YASAK
     olduğu için son temizlik adımı düşer). **BEN YAZMADIM** — Cowork'ün bu
     oturumdaki ÖNCEKİ çalışmasından kalma.
  2. `KANIT/slice-3d/07-G7-backend-zorlama/outbox-sorgu.txt` (izlenen, M) —
     kriter 7'nin ZORUNLU kıldığı yerel `verify.ps1` koşumları (taban + 4
     mutant + 1 tanı + 1 son doğrulama = 7 koşum) `MOMENTUM_KANIT_DIZIN`
     altına kanıt yazan `D9OwnerIdVisibilityTests.cs` yüzünden HER KOŞUMDA
     kendiliğinden değişiyor — `KANIT/slice-3c/02-G2/*.json`'un (is emri §2)
     BİREBİR AYNI sınıfı, ama BAŞKA bir KANIT alt dizininde.

**DÜZELTME:**
  1. `PROJE_HAFIZA.md.yedek` → `_SILINECEKLER/o69/`'a `mv` edildi (ORTAM.md'nin
     KENDİ reçetesi: *"mv ile _SILINECEKLER/<oturum>/'e alınır"*). `_SILINECEKLER/`
     `.gitignore`'da (satır 100) ⇒ taşıma git'e GÖRÜNMEZ, kalıcı SİLİNMEDİ.
  2. `KANIT/slice-3d/07-G7-backend-zorlama/outbox-sorgu.txt` → `git restore`
     ile HEAD'e döndürüldü (bu bir MUTANT-DOĞRULAMA bağlamı DEĞİLDİ — sıradan
     bir yan-etki dosyasının HEAD'e dönmesi güvenlidir, ORTAM.md 38'in yasağı
     yalnız KONTROLLÜ mutant turlarını kapsar).

**YENİDEN ÖLÇÜLDÜ (tam ağaç, filtresiz):**
```
git --no-optional-locks status --porcelain
 M .github/workflows/ci.yml
 M DURUM.md
 M GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md
 M GOREV_CLAUDE_CODE/GOREV-W3b-web-yayina-alma.md
 M PROJE_HAFIZA.md          <-- Cowork'un ONCEDEN kirlettigi, is emri §1'de
                                  "DOKUNMA, kendi commit'ine DAHIL ETME" diye
                                  ACIKCA beyanli (benim degil)
 M araclar/ci-kapisi.py
 M araclar/verify.ps1
?? KANIT/CI/**              <-- yasagin DISINDA
```
Artık TAM AĞAÇ görünümü de is emrinin izin verdiği kümeyle BİREBİR uyuşuyor.

## BULGU 3 — M-o69-4 (CVE mutantı): denetçi gerekçeyi doğru buldu, bir ek senaryo önerdi

Denetçi, `KANIT/CI/08`'deki ölçümü (NuGetAudit build'te önden yakalıyor,
açıkça yazılmış CVE gate bloğu bu YAPILANDIRMADA erişilmiyor ama TANI
mutantıyla ÇALIŞTIĞI kanıtlandı) **doğru** buldu, ama şunu ekledi: tanı
mutantı YAPAY bir `NuGetAudit=false` geçersiz kılmasına dayanıyor; daha
GERÇEKÇİ bir senaryo (artımlı/`--no-restore` bir koşumda audit'in atlanması)
adlandırılmadı.

**ÖLÇÜLDÜ (bu turda):** `araclar/verify.ps1:50`'deki build adımı
`& $dotnet build $solution -warnaserror --nologo` — **`--no-restore`
TAŞIMIYOR** ⇒ `dotnet build` HER ÇAĞRIDA örtük bir restore (ve dolayısıyla
NuGetAudit) çalıştırır; script'in KENDİ bugünkü kullanım deseninde "artımlı
restore atlama" senaryosu **oluşamaz**. Denetçinin önerdiği senaryo, script
`--no-restore` ALSAYDI geçerli olurdu — script bunu taşımıyor.

**HÜKÜM VERMİYORUM (K26):** M-o69-4'ün is emrinde YAZILAN "ayırt edici kanıt"
(CVE gate adımının KIRMIZI vermesi) bugünkü yapılandırmada NuGetAudit'in
ARKASINDA kalıyor — bu bir BLOKER mü (K155: "mutantsız ayak çıkar ya da
mutant yaz, üçüncü şık yok" — mutant YAZILDI ama YANLIŞ ADIMDA ısırıyor) yoksa
KABUL EDİLEBİLİR mi (güvenlik özelliği DOĞRU ve ÖLÇÜLDÜ, yalnız katman adı
farklı) — bu Cowork'ün kararı. Ölçtüğümü birebir yazdım, ikinci bir mutant
denemesi ile Cowork'ün önüne GEREKSİZ bir "düzeltilmiş" görünüm SUNMADIM.

## SONUÇ

- Bulgu 1: **DÜZELTİLDİ ve yeniden ölçüldü** (G31/h eklendi, denetçinin üç
  saldırısı da artık ISIRIYOR, altın küme 21/21 → 22/22, S5 statik mutant
  eklendi).
- Bulgu 2: **DÜZELTİLDİ ve yeniden ölçüldü** (iki fazlalık dosya temizlendi,
  tam-ağaç `git status` artık is emrinin izin verdiği kümeyle birebir).
- Bulgu 3: **AÇIK BIRAKILDI, BEYAN EDİLDİ** — hüküm Cowork'ün (K26).
