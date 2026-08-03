## 🔒 CHECKPOINT — K127 · **KİLİT ÖNCESİ BAĞIMSIZ DENETİM ZORUNLU** + `A13` DÜZELTİLDİ VE YENİDEN KİLİTLENDİ (Onur kilitledi, 3 Ağu 2026, oturum 52)

🔴 **DENETÇİ ÇIKTI YOLU (K127'nin kendi şartı, ilk kez uygulanıyor): `KANIT/A13/00-DENETIM-kilit-oncesi.md`.**
🔴 **ZAMANLAMA DÜRÜSTÇE YAZILIYOR: bu denetim `K126` kilidinden SONRA koştu.** Kural tam da bu
sıra hatasından doğdu.

## NE OLDU

`K126` `A13`'ü **denetimsiz** kilitledi. Kilitten sonra iki bağımsız ajan (K26; **ikisi de spec'i
yazmadı**, farklı lensler) koşturuldu ve **3 BLOKER + 6 MAJOR + 5 MINOR** buldu. Onur kilidi
**açtı**, spec düzeltildi, yeniden kilitlendi.

🔴 **BLOKER 1 — `A11`'İN KRİTER 7↔8 ÇELİŞKİSİ, AYNI NUMARALARLA TEKRARLADI.** `A13/G27/a`
`gh run list --workflow ci.yml --limit 5` idi — **dal filtresi yoktu** — ve *"en son koşum
`success`"* istiyordu. Kriter 8 ise aynı iş akışını mutant dallarında kasten **failure**
koşturuyor ⇒ kabul ölçümü kriter 8'den sonra yapıldığında listenin başı `M169`'un failure'ı olur
ve **kriter 7 kendi kendini KIRMIZI'ya düşürürdü**. Onarım: `--branch main` + `rev-parse main`
(`HEAD` değil; builder mutant dallarındayken `HEAD` mutant commit'idir).
🔴 **BLOKER 2 — `A13/G30/d` KÖRDÜ.** `git status --porcelain`'in boşluğu *"dosyalar değişmedi"*yi
değil *"ağaç kirli değil"*i ölçer. **Ölçülmüş kanıt bu oturumda fiilen görüldü:** commit betiğinde
o komut **EXIT 0** verdi ve çıktısı **beş dosyayla doluydu**. Onarım: `git diff --stat
<dilim-öncesi-sha>..HEAD -- src/client/lib src/client/test src/client/pubspec.yaml` ⇒ **çıktı BOŞ**;
dilim öncesi sha artık **kriter 1'de** kaydediliyor.
🔴 **BLOKER 3 — `A13/G29/c` KÖRDÜ ve `M169` ONU MASKELİYORDU.** *"Logda `Runner.app` geçsin"* bir
**alt-dizge** aramasıydı; Xcode logu **başarısız** derlemede de `Runner.app` içerir
(`ProcessInfoPlistFile …/Runner.app/Info.plist` — `M169`'un patlattığı adımın ta kendisi).
`M169` işi düşürdüğü için `G29/d` kırmızı olur ve **kör ayağı gizlerdi**: `A11`/`M141` deseninin
aynısı. Onarım: **tam satır pini** `Built build/ios/iphoneos/Runner.app (` + boyut > 0.

🔴 **EN PAHALI MAJOR — `M167` EŞDEĞERDİ.** *"Kullanılmayan `import`"* Dart'ta **WARNING**'dir ve
`flutter analyze` zaten warning'de düşer ⇒ mutant **`--fatal-infos` OLMADAN DA** ısırırdı; yani
`D-A13-3`'ün çekirdek iddiasını (*"bayrak taşıyıcıdır"*) **hiçbir koşan mutant ölçmüyordu**.
Onarım **ölçülerek** seçildi: `src/client/analysis_options.yaml` okundu, `flutter_lints/flutter.yaml`
dâhil ve `avoid_print` **devre dışı bırakılmamış** ⇒ `print()` **INFO** şiddetindedir ve yalnız
`--fatal-infos` varsa işi düşürür. Ayrıca `M163b` (yanlış-pozitif mutantı) ve `M170` (`G27/b`'nin
mutantı) eklendi; `M169`'un hedefi `D-A13-2` → **`D-A13-1`** olarak düzeltildi.

🟢 **DENETÇİLERİN OLUMLU ÖLÇÜMÜ:** §5'in **14 ayağının tamamı** §7'de çağrılıyor ⇒ **kör kapı yok**.

## DÜZELTME SONRASI ÖLÇÜM (yeniden kilit)

`GOREV_CLAUDE_CODE/GOREV-A13-ios-iskeleti-ci.md` — **27.908 b · `BCD0AA81`** · U+FFFD 0 · CRLF 0.
🔴 `K126`'nın kilit kimliği **`56871800` (20.940 b) GEÇERSİZDİR**; kilit `BCD0AA81`'dedir.
`spec-kapi-kapsama.py` altın küme **21/21** → spec **EXIT 0 / bulgu yok**: **4 kapı · 7 kural ·
10 mutant** (`M162`–`M170` + `M163b`; *koşan* sınıf **tam 3**, K53/3 tavanı dolu) · **1 gerekçeli
borç** (`D-A13-4`). `kapi-ad-teklik-kapisi.py` **YEŞİL**.

## K127 — KURALIN KENDİSİ (Onur kilitledi)

**Bir spec/ADR kilitlenirken yazılan checkpoint, o turda koşan BAĞIMSIZ DENETÇİNİN ÇIKTI YOLUNU
taşımak ZORUNDADIR.** Yol yoksa checkpoint *"denetim KOŞULMADI"* diye **açıkça** yazar.
Kanonik metin `CLAUDE.md`'dedir (K81'in altında).

🔴 **K53/1 İLE ÇELİŞMEZ.** Tavan hâlâ **bir** kâğıt turudur; K127 turun *sayısını* değil
**zamanlamasını** sabitler — tur **kilitten ÖNCE** koşar. K53/1'in kendi gerekçesi de buydu:
*"sebep denetimin miktarı değil, zamanlaması"*. Bu turda bulunan dokuz kusurun **hiçbiri koşan kod
gerektirmiyordu**; hepsi tek bir okuma turuyla bulunabilirdi — ve bulundu, yalnız **bir adım geç**.

🔴 **BEYAN EDİLMİŞ SINIR:** K127'nin **mekanik kapısı YOK**. Bugün checkpoint metnini kimse
denetlemiyor; kural prozada yaşıyor. Bu, projenin en çok eleştirdiği duruma (*"beyan edilmiş zayıf
kontrol"*) **bilerek** düşülmüş bir örnektir ve `BORCLAR.md`'ye `B-O52-2` olarak yazıldı.
