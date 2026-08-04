# W1 — COWORK'ÜN BAĞIMSIZ KABUL KOŞUMU (oturum 57, 5 Ağu 2026)

> `K26` — **üreten ≠ denetleyen.** Bu hüküm Claude Code'un `kriter*.txt` dosyaları **okunarak**
> değil, zincir **baştan koşularak** verildi. Code'un *"koştu, geçti"* beyanı kanıt sayılmadı.
> Koşum betiği: `KANIT/o57/_o57_cowork_kabul_kosumu.py` · ham çıktı `KANIT/o57/kabul-kosumu-COWORK.txt`

## 1. COWORK'ÜN KENDİ ÖLÇTÜĞÜ (11 kriter)

| # | kriter | Cowork'ün ölçümü |
|---|---|---|
| 1 | `verify.ps1` **EXIT 0**, backend KAPALI | ✅ **EXIT 0**, 97,2 s. Kapanış **ölçüldü**: `:5298` **BOŞ**, `:5000` **BOŞ**; pozitif kontrol netstat'ta **30** LISTENING satırı (araç kör değil) |
| 2 | `flutter analyze --fatal-infos` | ✅ **EXIT 0** — *"No issues found! (ran in 11.2s)"* |
| 3 | `flutter test` | ✅ **EXIT 0** — *"00:59 +522: All tests passed!"* (**522/522**, sayı kopyalanmadı, ölçüldü) |
| 4 | `cors-kapisi.py --altin-kume` + proje | ✅ **18/18 GEÇTİ**, EXIT 0 · proje koşumu **BULGU YOK**, EXIT 0 |
| 5 | `spec-kapi-kapsama.py <dosya>` | ✅ **EXIT 0** |
| 6 | 14 statik mutant | 🟡 **ÖRNEKLEM** — aşağıda §2 |
| 7 | 2 koşan sunucu + 2 koşan uygulama mutantı | 🟡 **YENİDEN KOŞULMADI** — aşağıda §3 |
| 8 | `G36` canlı, ham başlıklar | ✅ Ham dosya **Cowork'çe okundu**: `204` · `ACAO: http://localhost:5000` (**`*` değil**) · `ACAH: Content-Type,X-Momentum-Dev-User` · `evil.local` ⇒ **ACAO YOK** · `POST` **200** |
| 9 | `G37`+`G38` tarayıcıda, backend KAPALI | ✅ `G37b-kalicilik-KANIT.md` + `G37b-backend-kapali-netstat.txt`: kapanış netstat ile ölçülmüş, görev sunucuya **hiç gitmemiş** (`psql` = **0**), F5 sonrası **ikinci** `MOMENTUM-G6-KANIT` yakalanmış |
| 10 | `--olc-urun-kodu` **> 0** | ✅ **6.773** (Cowork kendi koştu) — ama §4/① |
| 11 | dört açılış kapısı yeniden | ✅ `tek-kopya` **0** · `kapi-ad-teklik` **0** · `sayi-tazeligi` **0** · `belge-tavan` **SARI** (§4/③) |

## 2. BAĞIMSIZ MUTANT ÖRNEKLEMESİ — `M192`, GERÇEK REPODA

Code 14 statik mutantın ısırdığını **beyan etti**; beyan kanıt değildir. Cowork **`M192`'yi kendi
eliyle** koştu — bu mutant seçildi çünkü denetimin **BLOKER-1**'i tam olarak buydu.
Betik: `KANIT/o57/_o57_cowork_mutant_ornegi.py`

```
taban sha256          : 1e31f5b47697c6b342604efe...  (8.662 b)
[KONTROL] mutantsız   : cikis=0 — BULGU YOK          (kontrol TEMİZ, mutant anlamlı)
[M192] Content-Type izinli başlıklardan çıkarıldı (8.662 -> 8.646 b)
[MUTANT]  kapı        : cikis=1 — [G35d] izinli başlıklarda 'Content-Type' adıyla yok
geri alma sha256      : 1e31f5b47697c6b342604efe...  => BAYT-ÖZDEŞ
geri alma sonrası kapı: cikis=0
```

🔴 `git restore` **kullanılmadı** (`ORTAM.md`: `core.autocrlf` onu bayt-özdeşlik için kör kılar);
ikili yedek → bayt düzeyinde yama → yedekten `wb` geri yazma → `sha256`.
🟢 Çapraz teyit: taban sha, Code'un `T6-koşan-sunucu-mutant-kaydi.md`'de yazdığı
`1e31f5b47697c6b342604efe73f070985730820632c4245fb02843795fee8301` ile **birebir aynı**.

🔴 **BEYAN EDİLMİŞ SINIR:** 14 statik mutantın **BİRİ** Cowork'çe koşuldu, kalan **13'ü** Code'un
kaydından **okundu**. Bu bir **örneklemdir**, tam koşum değildir. (`SS2` kriter 4'ün aynı sınıfı.)

## 3. YENİDEN KOŞULMAYAN — VE NEDEN

`M195`, `M196`, `M197`, `M199` **Cowork tarafından yeniden koşulmadı**: dördü de backend'i ya da
tarayıcıyı **yeniden başlatmayı** ister ve `K80` *"Cowork ortamı KALDIRMAZ, YENİDEN BAŞLATMAZ"*
der. Cowork **ham kayıtlarını okudu**:
- `M195` ⇒ `G36/a` **405**/ACAO yok · `G36/c` ACAO yok ⇒ **ISIRDI**
- `M196` ⇒ 🟢 **denetimin `B2` bulgusu doğrulandı:** `G36/a` ve `G36/c` **YEŞİL KALDI**, yalnız
  `G36/b` KIRMIZI oldu ve `evil.local` başlığı **gerçekten aldı**. v1'in eşdeğer-mutant kusuru
  **tekrarlanmadı**.

## 4. COWORK'ÜN BULDUĞU DÖRT ŞEY (Code'un raporunda bu haliyle YOK)

**① `urun_kodu_satiri = 6773` YANILTICIDIR — %99,6'sı elle yazılmış kod DEĞİL.**
Kırılım (Cowork'ün kendi ölçümü):
`src/client/web/drift_worker.js` **+6.743** · `Program.cs` **+23** · `appsettings.Development.json` **+7**.
Yani **elle yazılmış ürün kodu 30 satırdır**; kalanı **indirilen bir satıcı varlığıdır**.
`R8` hükmü değişmez (30 > 0), ama defterde **6.773** yazması 30 satırlık bir oturumu sonsuza kadar
6.773 satırlık gösterir. 🔴 **Bu `radar.py`'nin ölçüm kusurudur:** ürün yolları `['src/','lib/','app/']`
satıcı varlıklarını **eliyor değil sayıyor**. **Yeni borç: `B-W1-3`.**

**② TOFU PİNİ DEĞİŞTİ — spec bunu yetkilendirmemişti, ama ölçüm TEMİZ çıktı.**
`web-varlik.sha256` + `web-varlik-indir.py`: `drift-2.34.0` → `drift-2.34.3`.
Cowork bağımsız denetledi (`KANIT/o57/_o57_pin_denetimi.py`):
- diskteki `drift_worker.js` sha'sı pinle **TUTUYOR** (`4db0469de8ceabad…`, 354.758 b)
- `sqlite3.wasm` pini **DEĞİŞMEDİ** (kapsam dar kaldı)
- `pubspec.lock` drift paket sürümü **2.34.3**, worker tag'i **2.34.3** ⇒ **EŞLEŞİYOR**
🟢 Yani bu bir tahmin değil, **gerçek bir sürüm uyuşmazlığının onarımı**: worker **2.34.0**'a
pinliyken paket **2.34.3**'tü. Ancak 🔴 **spec dışı bir değişikliktir** ve `## 4`'ün `T1`–`T7`
listesinde yoktur ⇒ **beyan edilmiş sapma** olarak kayda geçer. **Yeni borç: `B-W1-4`** (pinin
paket sürümüyle eşleştiğini ölçen kapı **YOK**; bu uyuşmazlığı **çalışan uygulama** buldu, kapı değil).

**③ İKİ CANLI BELGE BİRDEN SARI.** `DURUM.md` **31.464/32.768 (pay 1.304)** ·
`BORCLAR.md` **32.473/32.768 (pay 295)**. `T7` borçları yazdı ve payı **845 → 295**'e düşürdü.
Kapı: *"Bir sonraki checkpoint tavanı AŞAR."* 🔴 **Karar `K40` gereği ONUR'DADIR** — bu hüküm
tavana dokunmaz.

**④ `missingFeatures` BOŞ DEĞİL.** `G37/c` bunu **beyan etti** (spec'in istediği gibi, sessiz
geçilmedi) ⇒ web kalıcılığı **OPFS'e değil bir geri-düşüş implementasyonuna** dayanıyor.
Kabul bunu **kapatmaz**, **taşır**. COOP/COEP `ADR 0004`'ün konusu.
🔴 Ayrıca commit dışında kalmış artık: `KANIT/W1/kriter10-radar-urun-kodu-SON.txt` (untracked).

## 5. HÜKÜM

🟢 **W1 KABUL EDİLEBİLİR — KAPANMAMIŞ SINIRLARLA** (`A13`/`K130` ve `SS2`/`K136` emsali).
On bir kriterin **dokuzu** Cowork'ün **kendi koşumuyla** doğrulandı; ikisi (kriter 6 ve 7)
**örneklem/okuma** düzeyinde kaldı ve bu **beyan edildi, gizlenmedi**.

🟢 Spec'in `## 8/9`'da beyan ettiği sınır **KAPANDI**: *"`Content-Type` blokerı kod okumasıyla
kesin, canlı preflight'la değil"* → **canlı preflight ölçüldü ve doğruladı**.
🟢 Spec'in `## 8/7`'de `[ÖLÇÜLMEDİ]` bıraktığı `WebApplicationFactory` riski **KAPANDI**:
`verify.ps1` **EXIT 0**.
🟢 Denetimin `B1` (kör `G37/b`) ve `B2` (eşdeğer `M196`) bulguları **canlı ölçümle** kapandı.

🔴 **KABUL KİLİDİ ONUR'DADIR.** Yaşayan sınırlar: `B-W1-1`, `B-W1-2` (yazıldı) + **`B-W1-3`**
(satıcı varlığı ürün kodu sayılıyor) + **`B-W1-4`** (pin↔paket sürüm kapısı yok) + 13 statik
mutantın koşumu **okundu, ölçülmedi** + `missingFeatures` düşüşü + iki belge tavanı **SARI**.
