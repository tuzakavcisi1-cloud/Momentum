# CLAUDE.md — Momentum (kalıcı proje talimatı)

> **Her oturumda ÖNCE `DURUM.md` + bu dosyayı oku.** Güncel durum, sıradaki iş, yürürlükteki kilitler ve ortam uyarıları orada.
> **`PROJE_HAFIZA.md` artık APPEND-ONLY KARAR ARŞİVİDİR** — oturum açılışında **OKUNMAZ**; yalnız *"bu karar neden alındı?"* diye sorulduğunda açılır. *(K53, 26 Tem 2026: 488 KB'lik dosyayı her oturumun baştan okuması ölçülmüş bir bağlam vergisiydi.)*

## ⚡ VERİMLİLİK KURALLARI [K53 — PAZARLIKSIZ]

> **Ölçülmüş kök neden:** 29 oturumun sonunda backend çalışıyordu (110 test yeşil) ama **istemci 0 satırdı**. Sebep denetimin *miktarı* değil, **zamanlaması**: henüz koşamayan iddialar kâğıtta doğrulanmaya çalışıldı. Aşağıdaki beş kural bunu engeller.

1. **KÂĞIT DENETİM TURU TAVANI = 1.** Bir spec/ADR **tek** bağımsız denetim turu görür → düzeltilir → kilitlenir. **İkinci tur ancak birincisi MİMARİYİ DEĞİŞTİREN bir bloker bulduysa** açılır. *(Ölçüldü: tur 1 → 13 bloker, tur 2 → 4, tur 3 → 0; ve üç turun hiçbirinin bulamadığı iki kusuru 100 satırlık bir betik ilk koşumda buldu. Prozayı LLM'e okutmak pahalı ve yüksek varyanslı; mekanik kontrol ucuz ve deterministik.)*
2. **RADAR KIRMIZI'DA VARSAYILAN CEVAP `DEVRET`'TİR.** `MEKANİKLEŞTİR` seçen el, **yazılı gerekçe** vermek zorundadır: *"bu sınıf, koşan kod OLMADAN ölçülebilir."* Ölçülemiyorsa o şık **geçersizdir**. **İspat yükü tersine çevrilmiştir.**
3. **MUTANT TAVANI MALİYET SINIFINA GÖREDİR, SAYIYA GÖRE DEĞİL.**
   **Koşan uygulama** isteyen mutant (emülatör/tarayıcı + yeniden derleme) tavanı: **3 / dilim.**
   **Statik** (linter/tarayıcı betiği) ve **widget testi** mutantları: **tavansız** — saniyeler sürerler ve portfolyonun en ikna edici parçasıdır.
   Bir kural mutantsız kalacaksa `## 6b. MUTANT BORCU` altına **gerekçesiyle** yazılır; `spec-kapi-kapsama.py` gerekçesiz borcu **reddeder**. **KAPI borçlanamaz**, yalnız kural.
4. **İKİ OTURUM ÜST ÜSTE 0 SATIR ÜRÜN KODU = SERT DURAK.** Radar `R8` bunu ölçer (K57'de `R7`'den yeniden adlandırıldı; oturum 48'de düzeltildi). Kırmızı yanarsa **bir sonraki oturum ürün koduyla başlar**; yeni belge/ADR/spec/araç turu **açılmaz**.
   **`urun_kodu_satiri` TANIMI [K55'te düzeltildi]:** *"o oturum penceresinde repoya giren **ÜRÜN kodu — HANGİ EL olursa olsun**"* (Cowork, Claude Code, fark etmez). **Araç/betik/belge SAYILMAZ.** Üretilmiş iskelet (`flutter create` vb.) sayılır ama **niteliği beyan edilir**. *Bu tanım ilk gerçek kullanımda düzeltildi: "Cowork'ün yazdığı kod" diye okunursa, **Claude Code build ederken R7 yanlış-pozitif verir**.*
5. **YÜRÜYEN İSKELET ÖNCE, KAPILAR SONRA.** Koşan kod üzerindeki kapı kendini doğrular; kâğıt üzerindeki kapı doğrulanamaz. Yeni bir dikey dilimde önce **çalışan en küçük şey**, sonra kapılar.

**Ayrım (her tasarımda uygulanır):** **ÜRÜN kapısı** (*"uygulama çevrimdışı kalıcı mı?"*) her kuruşu hak eder. **SÜREÇ kapısı** (*"her kuralın mutantı var mı?"*) faydalıdır ama **tavanı vardır**.

## Çalışma tarzı
- Türkçe çalış. Dürüst ol, bilgi uydurma; emin değilsen söyle.
- Onur onaylamadan büyük/geri alınamaz iş başlatma; komut çalıştırmadan önce ne yapacağını kısaca söyle.
- **Üreten ≠ denetleyen:** hiçbir çıktı kendi üreticisi tarafından onaylanmaz; bağımsız denetçi kapılardan geçer.
- Çıktıyı teslim etmeden önce kendin doğrula (build logu, test, manifest, bağımlılık).

## İş akışı (her dikey dilim) [PAZARLIKSIZ]
`ADR/tasarım kilidi → engineering skill doğrulama → red-team → KİLİT → GOREV_CLAUDE_CODE spec → Claude Code build → verify zinciri (otomatik kapılar) → uzman denetçi ajanlar → red-team EN SON → düzeltme → kapanış + KANIT`

## Denetçi kapıları
- **Otomatik (verify):** backend build+test+analyzer+güvenlik; frontend analyze+test+a11y; OpenAPI kontrat; **taç mücevher kapısı** (senkron/çakışmayı bağımsız 2. implementasyonla doğrula + idempotency). Her kapı MUTANT testiyle ısırdığını kanıtlar (KÖR KAPI YOK).
- **Uzman ajanlar (kilitte):** architecture, code-review, testing-strategy, accessibility-review, risk-assessment, RED-TEAM EN SON.

## Oturum sağlığı ve devir [K21 — PAZARLIKSIZ · **KANONİK KAYNAK; EŞİKLER BAŞKA HİÇBİR DOSYAYA KOPYALANMAZ**]
Devir kararı **ölçülür, hissedilmez.** Canlı bağlam = transcript'teki son mesajın
`input + cache_read + cache_creation` toplamı (`~/.claude/projects/*/<oturum-id>.jsonl`; kendi oturum-id'nle).

🔴 **EŞİKLER MUTLAKTIR — YÜZDE HESAPLAMA, YÜZDE YAZMA:**
🟢 **< 550k: DEVAM** (devir/temiz-oturum önerisi YOK) · 🟡 **550k–750k:** eldeki maddeyi bitir, checkpoint
yaz, yeni büyük iş başlatma — *"dolu bağlamda ADR/spec yazma yasağı"* **BURADAN** başlar · 🔴 **> 750k:**
devir notu yaz, oturumu kapat.

Bu sayılar 1M pencere beyanından türetildi **ama karar yolunda PAYDA YOKTUR** — yalnız mutlak token
karşılaştırılır. **Yüzde yazmak KUSUR BELİRTİSİDİR:** yüzde yazan bir el paydayı yeniden uydurmuş demektir.
Ölçülen kusur (oturum 33 + 34): kural buraya **yüzde olarak** kopyalanmış, payda düşmüş, iki oturum **200k
uydurup** 🟡 ve 🔴 ilan etmiş; oturum 33 spec yazımını gereksiz devretmiş ve `R8` sert durağının bir bacağı
o sahte oturum sınırından doğmuştur. Kanonik metin+gerekçe: `PROJE_HAFIZA.md` K21 ve **K21-DÜZELTME**.

**PAYDA YANLIŞLAMA TESTİ [bedava, HER ölçümde koşar]:** ölçülen canlı bağlam varsayılan pencereden
**BÜYÜKSE ve istek koşuyorsa**, o pencere varsayımı **ÖLÜDÜR** ⇒ renk ilan etme, Onur'a söyle.
(28 Tem 2026'da koştu: 339.116 token ölçüldü ve istekler koşuyordu ⇒ **200k varsayımı ÖLDÜ**.)
**Ölçemezsen** yeşil de kırmızı da varsayma: ölçemediğini söyle, Onur'a sor. Her büyük iş başında ve her
checkpoint'te ölçümü **mutlak sayıyla** raporla.

🔴 **KAPSAM [oturum 39'da ÖLÇÜLDÜ, Onur kilitledi]:** bu ölçüm ve bu eşikler **YALNIZ COWORK
oturumları içindir.** Claude Code'un kendi bağlam göstergesi vardır ve **penceresi farklıdır**
⇒ `araclar/oturum-sagligi.py` ona **UYGULANMAZ**. Gerekçe K21'in kendi doğuş sebebidir:
eşikler 1M pencere beyanından türetildi; **başka pencereli bir ele uygulamak paydayı yeniden
uydurmaktır** — K21-DÜZELTME'nin yasakladığı şeyin ta kendisi. Kural kapsamını beyan
etmediği için oturum 39'da Cowork bu aracı Claude Code'a koşturttu: **beyan edilmemiş
kapsam, yanlış ele uygulanır.** Aracın kendisi de kapsamını sormuyor (borç: `BORCLAR.md`).

## Git — sandbox'tan okuma [ÖLÇÜLDÜ, PAZARLIKSIZ]
Cowork bağlı diskte **düz `git status` KOŞMAZ**: mount `unlink`'e izin vermediği için git
`.git/index.lock`'u silemez ve **bayat kilit bırakır** — Onur'un bir sonraki `git add`/`commit`'i
*"Unable to create '.git/index.lock': File exists"* ile patlar. **Her zaman:**
`git --no-optional-locks status --porcelain` (kontrollü testle doğrulandı: kilit bırakmıyor).
Aynı kural `git log`/`git diff` için de geçerlidir. Kilit oluşursa sandbox onu **silemez**,
yalnız `mv` ile kenara alabilir; kalıcı silmeyi Onur yapar.

> ### ⏱ ERRATA (26 Tem 2026, oturum 26 — Onur onayıyla): *"sandbox'tan commit ETME"* KURALININ KAPSAMI ÖLÇÜLDÜ
> Kural **KALDIRILMADI**; **kapsamı** daraltıldı ve gerekçesi yazıya geçti. Yasağın ölçülmüş sebebi **mount'a özgüdür:**
> konteynerin mount'u `unlink`'e izin vermediği için git `.git/index.lock`'u silemez ve **bayat kilit** bırakır.
> - **`device_bash` / mount yolu (`/sessions/.../mnt/...`) ile `git add`/`commit`/`push`: HÂLÂ YASAK.** Kuralın konusu budur.
> - **Desktop Commander ile (Onur'un makinesinde YERLİ PowerShell) commit: İZİNLİ.** Mount yolu kullanılmaz.
>   **Ölçüldü (26 Tem 2026, iki commit — `0c5fbc5` ve `7dcc863`):** ağaç temiz kaldı, `.git/index.lock` **oluşmadı**
>   (`Test-Path .git\index.lock` ⇒ `False`).
> - **PAZARLIKSIZ KOŞUL — her commit'ten SONRA:** `git --no-optional-locks status --porcelain` **ve**
>   `Test-Path .git\index.lock` koşulur; kilit varsa Onur'a **hemen** bildirilir (sandbox onu **silemez**, yalnız `mv` ile kenara alabilir).
> - **`--no-optional-locks` her git çağrısında ZORUNLU kalır** (okuma da yazma da).
> - **PUSH hâlâ Onur'un işidir** — bu errata push'a izin VERMEZ.

## Radar [26 Tem 2026 — K40, PAZARLIKSIZ]
- **Her oturum açılışında ve her checkpoint'te** radar koşulur: `python araclar\radar.py --altin-kume`
  (çıkış **0** olmalı) → `python araclar\radar.py .`  ⇒ hüküm **YEŞİL/SARI/KIRMIZI** (çıkış 0/1/2).
- **Her checkpoint'te `PROJE_RADAR.jsonl`'a BİR SATIR eklenir** — `uretilen` alanı (bu oturumun KENDİ
  ürettiği kusur sayısı) **dürüstçe** yazılır; ölçülmeyen sayı `[TAHMIN]` işaretlenir. **Tam-dosya rewrite YOK.**
- **Radar KIRMIZI ise YENİ TUR YASAK.** Dört şık (**DARALT · DEVRET · MEKANİKLEŞTİR · DURDUR**) ölçülmüş
  gerekçe ve adlandırılmış bedelle Onur'a sunulur; **kilit Onur'dan gelir**, oturum kendi başına seçmez.
- Doktrin ve eşikler: `proje-radari` plugin'i (`doktrin.md`). Eşik değiştiren, **altın kümeye yeni vaka eklemek**
  zorundadır — eşiği gevşetip altın kümeyi güncellememek ölçüm aracını kasten körleştirmektir.

## Kırmızı çizgiler (değişmez) [PAZARLIKSIZ]
1. Sırlar repoya girmez (.env + .gitignore + secret yönetimi).
2. PII minimumda; gizlilik-öncelikli.
3. Yeni bağımlılık = lisans + CVE kontrolü.
4. Kalıcı silme / para-hesap işlemi / güvenlik ayarı değişimi → Onur onayı şart.
5. Build artefaktları git-ignore.

## Rol bölümü
Cowork = tasarım/ADR/spec/orkestrasyon/hafıza/denetim; Claude Code = build. Cowork, Code'un beyanına güvenmez; her artefaktı bağımsız doğrular (Desktop Commander ile gerçek FS'ten).

### GOREV spec biçim standardı [K81 — 29 Tem 2026, PAZARLIKSIZ]

`spec-kapi-kapsama.py` **dizin kabul etmez** (`.` verilirse `ORTAM HATASI: Permission denied`) ve
kapıları yalnız `## 5. KAPILAR` altındaki `### G<n>` başlıklarından, mutantları `## 6. MUTANTLAR`
altından okur. Bu yüzden **bundan sonraki her `GOREV_CLAUDE_CODE/*.md` spec'i** bu iki başlığı bu adla
taşır ve araç **spec dosyasının yoluyla** çağrılır, dizinle değil.
🔴 Ölçülmüş gerekçe: `GOREV-slice-3e-G12.md` kendi başlık şemasını kullandı (`## 2. YAPILACAKLAR` /
`## 3. MUTANT TABLOSU`) ⇒ araç `[S0] BİÇİM` ile durdu ve o spec'in **kapsama ölçümü hiç yapılamadı**.
Kusur builder'ın değil, **spec'i yazan elindir**: kriter, aracın hiç kabul etmediği bir argüman biçimiyle
ve ayrıştıramadığı bir belge biçimine karşı yazılmıştı.

## Ortamı kim kaldırır [K80 — 29 Tem 2026, Onur kilitledi · PAZARLIKSIZ]

**Cihaz ya da canlı-sunucu kanıtı isteyen HER spec, ortamı KENDİ kaldırma maddesini taşımak ZORUNDADIR.**
Claude Code bunu **yapabilir ve daha önce yaptı** — ölçülmüş kanıt: `KANIT\slice-3d\09-MUTANT\_start_api.cmd`
builder'ın kendi yazıp koştuğu `dotnet run` betiğidir; `KANIT\slice-3b\00-ortam.txt` emülatörü *"o an
KOŞMUYORDU"* diye ölçmüş ve aynı dilimde `emulator-5554` üzerinde `flutter run` kanıtı üretmiştir.
Spec'in kabul kriterlerinde şu üç adım **sırayla** bulunur: ① `docker start momentum-postgres` (healthy
görülene kadar yoklanır) → ② backend ayrı süreçte, ortam değişkenleriyle → ③ emülatör
(`flutter emulators --launch <avd>` ya da `emulator.exe -avd <avd>`), `adb devices` ile doğrulanır.

- 🔴 **PID, cihaz adı ve "çalışıyor" beyanı hiçbir belgeye YAZILMAZ — ÖLÇÜLÜR:** `docker ps` ·
  `netstat -ano | findstr :5298` · `adb devices`. *(Ölçüldü: `DURUM.md` §4 bu satırda üç oturum boyunca
  bayat bir PID taşıdı; oturum 37 açılışında devir notunun "backend çalışıyor / emülatör açık" iddiasının
  **ikisi de** yanlış çıktı.)*
- 🔴 **Sabit `sleep` bir ölçüm değildir** — koşula kadar **yoklanır**, tavanlı. *(Oturum 35: 22 sn bekleyip
  yanlış KIRMIZI verildi; kriter 9'un 15 sn'lik ilk geçişi titizlik değil ŞANSTI.)*
- 🔴 **`ASPNETCORE_ENVIRONMENT=Development` AÇIKÇA set edilir.** `Program.cs` `builder.Environment.IsDevelopment()`
  ile `DevCurrentUser`'ı açar; aksi hâlde `NullCurrentUser` ⇒ **her istek 401** (K61). `_start_api.cmd` bunu
  **set ETMİYOR** ve `dotnet run --no-launch-profile`'ın ortamı Development'a düşürüp düşürmediği
  **[DOĞRULANMADI]**. Değişkeni yazmak bu belirsizliği ortadan kaldırır.
- **Cowork ortamı KALDIRMAZ, DOĞRULAR.** Gerekçe teknik imkânsızlık değil, ölçülmüş kırılganlıktır:
  Cowork↔masaüstü köprüsü oturum 37'de **üç kez** düştü; köprünün sahip olduğu bir kabuktan başlatılan
  uzun ömürlü sunucunun akıbeti köprü gidince belirsizleşir, logu okunamaz ve öldürülemez. Onur'un ya da
  Code'un açtığı pencere görünür ve kapatılabilir. Cowork yalnız **ölçer** ve sonucu raporlar.

## Hafıza kuralı (checkpoint) [K53'te BÖLÜNDÜ]
**İki dosya, iki iş:**
- **`DURUM.md` — CANLI DURUM.** Her oturumun okuduğu tek dosya. **≤ 32 KB kalmak ZORUNDA** [K58, 27 Tem 2026 — eski tavan 12 KB'dı]. Durum değişince **YERİNDE değiştirilir** (eski satır silinir, yenisi yazılır — burada tarihçe **birikmez**). Aşarsa budanır.
  > **Tavanın gerekçesi OKUMA KAPASİTESİ DEĞİLDİR** (12 KB ≈ 3,5k token; sınırın kat kat altı). İki gerçek gerekçe: ① **R4 freni** — bu projede ölçüldü, ADR 0003 dokuz turda 120→300 KB büyüdü ve her büyüme yeni çapraz-atıf kusuru doğurdu; ② **dikkat** — 3,5k token okunur, 40k token *göz gezdirilir* ve göz gezdirilen belgede bayat iddia hayatta kalır. 12→32 KB gevşetmesinin ölçülmüş gerekçesi: bayat-atıf sınıfı artık **mekanikleşti** (`sayi-tazeligi.py`, `dosya-kimlik.py`, defter `D1`–`D5`), yani R4'ün dayandığı varsayım zayıfladı.
  > 🟢 **ZAYIF KONTROL KAPANDI [oturum 45'te ölçüldü]:** tavanı artık `araclar\belge-tavan-kapisi.py` **1.1.0** (altın küme **12/12**) zorluyor ve açılış protokolünün **3. adımında** koşuyor. K58 *"ilk ısırdığında yazılır"* demişti: **ilk ısırış oturum 39'da** (`T2` SARI, `DURUM.md` 31.744 b) oldu ve araç yazıldı; **ikinci ısırış oturum 45'te** (`T2` SARI, 31.149 b) K73 budamasını tetikledi. 🔴 **Bu satır oturum 45'e kadar *"hiçbir kapı zorlamıyor"* diyordu — ÖLÜ BEYAN.** Aynı cümlenin `DURUM.md`'de **iki kopyası** daha vardı ve üçü birlikte düzeltildi: `kanonik-kopya` sınıfının altıncı ısırışı. Ders: **bir sınırı kapatan el, o sınırı BEYAN EDEN her kopyayı aynı anda kapatmak zorundadır** — yoksa kapanan borç belgede açık görünmeye devam eder.
- **`PROJE_HAFIZA.md` — APPEND-ONLY KARAR ARŞİVİ.** Karar/kapı/kilit anında **üste** yeni checkpoint eklenir; **hiçbir şey silinmez**, hiçbir şey yerinde düzeltilmez (bayat bir satır varsa **düzeltme notu** yazılır). Oturum açılışında **okunmaz**.
  > **DİZİN [K58]:** dosyanın başındaki `<!-- DIZIN:BAS -->…<!-- DIZIN:SON -->` bloğu **mekanik üretimdir, ELLE DÜZENLENMEZ**: `python araclar\hafiza-dizin.py .`. Append-only ihlali değildir — dizin **kayıt değil, kayıtlardan TÜRETİLMİŞ veridir** ve her koşumda sıfırdan yeniden üretilir. **Yeni checkpoint `<!-- DIZIN:SON -->` satırının ALTINA eklenir.**

Checkpoint **anında** yazılır — karar/kapı/kilit anında, küçük ve hemen. Oturum sonunda toplu yazma YOK. Onur "güncelle" demesini bekleme.
**Kimlik ölçümü DAİMA son yazımdan SONRA alınır** (iki kez bayat kimlik yazıldı; `python araclar\dosya-kimlik.py <dosya>`).

## Ortam
Windows / PowerShell. **Kanonik kök: `C:\dev\Momentum` — SAF ASCII OLMAK ZORUNDA [K56].**
> Eski kök (`…\MEMO ÖDEV PROGRAMLAR\TO DO LİST\Momentum`) **dört ayrı araç zincirini kırıyordu**: `build_runner` · `flutter analyze` (LSP çerçeveleme) · **Android Gradle Plugin** · `.ps1` yol literali. Suçlu **boşluk değil, Türkçe karakter** (izole edildi). **Junction ÇÖZMEZ** — JVM reparse point'i gerçek yola çözer. `android.overridePathCheck` **EKLENMEZ** (kapı susturmak + repoya geçici çözüm commit'lemek olur). **Kural: yeni klasör/yol açarken saf ASCII kullan.** Mac yok → iOS CI-only. Build/kod bu klasörde (OneDrive'da değil, senkron derdi yok).
