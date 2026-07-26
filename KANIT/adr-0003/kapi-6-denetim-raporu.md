# KAPI-6 — ADR 0003 v6 BAĞIMSIZ DENETİM RAPORU

**Tarih:** 25 Tem 2026 · oturum 24 · **Denetlenen:** `docs/ADR/0003-kimlik-cekirdegi.md` (v6)
**Belge kimliği (kaynaktan ölçüldü):** 241.689 bayt · 1.123 satır · sha256 `6f6be71a0d86cb32d7d6b2b856c1526247cacd8aa57b0b4b36facd8a8638cb08` · UTF-8 geçerli · BOM yok · `U+FFFD` 0 · CRLF 0
**Denetlenen ikinci nesne (K29-a):** `araclar/adr-kapi-taramasi.py` (50.582 bayt)
**Denetlenen üçüncü nesne (K32-d):** `KANIT/adr-0003/kapi-5-denetim-raporu.md` (19.827 bayt)

---

## 0. HÜKÜM

# 🔴 ADR 0003 v6 KİLİTLENEMEZ.

**9 BLOKER · 31 MAJÖR · 14 MİNÖR · 2 ÇÜRÜTÜLEN İDDİA.**
Ayrıca **kapı-6'nın kendi ölçemedikleri** §5'te adlandırılmıştır ve bunlardan biri (ADR 0002'nin hiç açılmamış olması) tek başına bir sonraki turun ilk işidir.

**Bu 6. turdur.** K13-a yürürlüktedir: bloker sıfırlanana kadar tur; tur sayısı raporlanır, sınırlanmaz.

**Turun tek cümlelik hükmü:** *v6, kapı-5'in bulgularını büyük ölçüde kapattı ve belgenin merkezî iddiaları (karar↔kapı eşlemesi, numara bütünlüğü, aracın koşum sonuçları) bağımsız olarak DOĞRULANDI; ama v6 aynı kusur sınıflarını **kendi yeni yazdığı satırlarda yeniden üretti** — ve bu kez kusurların bir kısmı ölçüm aracının **yapısal kör noktalarına** düştüğü için araç yeşil kalmaya devam etti.*

---

## 1. KAPI KURULUMU

**Bağımsızlık (K26):** bu oturum v6'yı yazmadı, aracı onarmadı, kapı-5'i koşmadı ⇒ K26(1) ihlal edilmedi; K26(2) gereği denetim alt ajanlara dağıtıldı.

**17 bağımsız denetçi, hiçbiri diğerinin bulgusunu görmedi:**
- **A turu — 10 bölüm denetçisi:** §0+§1+§1-K · §2-A/B · §2-C · §2-D/§2-I · §2-J · §2-K/§2-L · §2-M · §3 (yapı) · §3.1+§3.2 · §4-§7
- **A turu — 3 mutant-çıpası denetçisi (K32-b):** 51 mutantın **51'i** tek tek; her biri için *"ölüyor mu · baseline yeşil mi · ayırt edici mi"*
- **A turu — 1 araç kaynak denetçisi (K29-a):** altın kümenin **17 kontrolünün 17'si** mutasyonla zorlandı
- **A turu — 1 FARKLI MODEL (Sonnet) SALDIRGANI (K26(5), K32-c):** *"bu aracı KANDIR"*
- **A turu — 1 kapı-5 raporu çapraz denetçisi (K32-d)**
- **B turu — RED-TEAM EN SON:** A turunu **çürütmekle** görevli
- **Kapanış — TAMAMLIK KRİTİĞİ (K32-a):** *"ne atlandı"*

**K13-a uygulandı:** hükmü taşıyan iddiaların tamamı rapora girmeden önce Cowork tarafından **kaynaktan yeniden ölçüldü**. Alt-ajan beyanı olduğu gibi aktarılmadı; ölçümde tutmayan iddialar aşağıda §4'te **ÇÜRÜTÜLEN** olarak yazılıdır.

**K26(4) uygulandı:** alt-ajan ham çıktıları `KANIT/adr-0003/kapi-6-ham-ajan-ciktilari/` altındadır.

---

## 2. BLOKERLER (9)

### B6-1 — M56 KÖR KAPIDIR: sızmış-parola kara listesinin kill probu, kara liste hiç yokken de aynı sonucu verir
`M56`'nın kill sinyali (satır 908) probu **`123456`** olarak pinliyor. `len("123456") = 6`; `[KS-17]` = **15 karakter** (satır 132). ⇒ mutasyon (*"kara liste kontrolü kaldırılır"*) uygulandığında `123456` **yine `400` alır** — bu kez uzunluk doğrulamasından. İkinci ayak (*"listede olmayan, `[KS-17]`'yi sağlayan parola `201`"*) blocklist kaldırılınca da `201` verir. **İki ayağın ikisi de mutasyon altında YEŞİL kalır ⇒ mutant hayatta kalır.**
Belge bunu kendi satırında yazıyor (satır 216): *"`123456` parolasına karşı Argon2id'nin … yatırımı hiçbir şey satın almaz — **uzunluk, KDF'den önce gelir**."*
**Ek inşa riski [ŞÜPHELİ]:** `[KS-31]` *"en yaygın parolalar"* listesidir ve en yaygın parola havuzunun ezici çoğunluğu <15 karakterdir; `[KS-17]` bu kesişimi neredeyse boşaltır ⇒ ısırtılabilir bir prob (≥15 karakterlik, listede bulunan bir parola) **var olduğu ölçülmemiştir**.
*Ölçüm:* `sed -n '908p' … | grep -o '123456'` · `sed -n '132p' …` ⇒ `15 karakter`.
**v7'nin yapması gereken:** prob `[KS-17]`'yi sağlayan bir kara-liste parolasına çevrilir **ve** böyle bir parolanın listede bulunduğu ölçülür; bulunamazsa `[KS-31]`'in seçim ölçütü değişir.

### B6-2 — M29'un mutantı koşul 3 tarafından MASKELENİYOR
`M29`'un mutasyonu (satır 870) **yalnız koşul 1'i** kaldırır (`consumed_at + [KS-4]`). Kill sinyali saati *"`[KS-4]`'ü AŞACAK KADAR"* ilerletir. Ama o anda K3-C6(5)'in **iki silme mekanizması da** (fırsatçı silme, satır 362 · süpürücü, satır 363) `successor_secret_enc`'i `NULL`'lar ⇒ **koşul 3 düşer** ⇒ satır 331'in kendi cümlesiyle *"dal (d)'ye düşülür"* ⇒ **aile yine iptal olur** ⇒ assert mutasyon altında da GEÇER.
Belge aynı tehlikeyi kardeş mutantta **pinlemiş**: `M40b` birebir *"süpürücü fixture'a kaydedilmez"* (satır 889). `M29`'a taşınmamış.
**v7'nin yapması gereken:** M29'un önkoşuluna *"her iki silme mekanizması da devre dışı"* ya da mutasyona *"koşul 1 VE koşul 3 birlikte kaldırılır"* pinlenir.

### B6-3 — M24'ün "korumalı uç"u PİNSİZ; belgenin tanımladığı tek korumalı uç `ICurrentUser`'ı hiç çözmüyor
`M24`'ün mutasyonu `ICurrentUser`'ın `"sub"` yerine `ClaimTypes.NameIdentifier` okumasıdır; bu **yalnız `UserId` fiilen dereference edildiğinde** patlar. Belgenin adıyla pinlediği tek korumalı uç `GET /v1/_probe/deny-default`'tur (M14, satır 856) ve gövdesi `ICurrentUser`'a **dokunmaz** ⇒ o uç seçilirse mutasyon altında da `200` döner, mutant yaşar.
Satır 865 asimetriyi **adıyla teşhis edip** yanlış şeyi pinlemiş: boru hattını pinlemiş (*"gerçek `AddJwtBearer`"*), **ucun `UserId`'yi çözmesi gerektiğini** pinlememiş. K3-D2'nin ve K3-C7'nin yan etkisinin tek kapısı M24'tür.

### B6-4 — Aracın SESSİZ, BEYANSIZ K4 kaçış kapısı: tek kelime tüm satırı muaf ediyor
`araclar/adr-kapi-taramasi.py` **satır 412**: `if ("KANONİK" in s) or ("§1-K" in s): continue`.
Bu bir **bölüm filtresi değil, belge geneli dize filtresidir** ve `[KS-LITERAL]` muafiyetinin aksine **hiç raporlanmaz**. Canlı belgede **4 satır** bu filtreyi tetikliyor ve bunlardan biri **satır 906 — M54'ün canlı mutant satırıdır** (metninde `§1-K` geçiyor) ⇒ o satırdaki her kanonik kopya sessizce affediliyor.
Bu, kapı-5'in **B5-2**'de kapattığı *"`[KS-` toptan muafiyeti"* kusurunun birebir kardeşidir ve iki satır yukarıda açık kalmıştır. Altın küme bu ekseni **hiç** kontrol etmiyor.
*Ölçüm:* `grep -n 'KANONİK.*in s' araclar/adr-kapi-taramasi.py` ⇒ `412` · filtre tetikleyen canlı satırlar: `5 · 38 · 77 · 906`.

### B6-5 — §3.1'in *"araç altın kümede kendini kanıtlamadan koşmaz"* cümlesi YANLIŞTIR
Kaynak satır 880-881: `if a.altin_kume: return altin_kume()`. ⇒ `--altin-kume` **erken döner**; normal tarama altın kümeyi **hiç koşmaz**. Araç, altın küme düşürülmüş hâlde bile temiz bir belgeye *"BULGU YOK"* deyip **çıkış kodu 0** verir (koşularak kanıtlandı).
§3.1 bunu aracın üç sınırından **biri** olarak değil, aracın lehine bir **güvence** olarak yazıyor. Belgenin en güçlü dürüstlük vitrini, ölçülmemiş bir güvenceye dayanıyor.

### B6-6 — K3-L8'in dal envanteri EKSİK: *"yenileme kimliği HİÇ YOK"* dalı yazılmamış
K3-L8 `/refresh`'in **üç** dalını pinliyor (ağ hatası · `401`/`reuse_detected` · `429`/`5xx`); **dördüncü durum** — istemcide sunulacak bir yenileme kimliği hiç yok (çıkış sonrası · çerez süresi dolmuş · taze kurulum) — hiçbir dala düşmüyor. Web'de bu bir builder tercihi değil, **tasarımın zorladığı** bir sonuçtur: `__Host-mrt` `HttpOnly`'dir ⇒ istemci çerezin varlığını okuyamaz ⇒ uçak modunda *"kimliğim yok"* ile *"ağ yok"*u ayırt edemez ve satır 729'un yazılı kuralı devreye girer (*"çevrimdışı-yetkili kalır ⇒ yerel DB tam okunur/yazılır"*). K3-L7 *"çıkışta SİLME YOKTUR"* diyor ve aktif profil kaydının temizlendiği hiçbir yerde yazmıyor.
⇒ **paylaşılan bir makinede çıkış yapmış A'nın görevleri, kimlik sunulmadan, çevrimdışı açılışta okunur** — belgenin satır 691'de adıyla reddettiği senaryonun yerel-DB'deki hâli. Bu bir 3b işi değildir: satır 737 *"`userId`'nin nereden geldiği bu belgenin işidir"* diyor. B3 ve B9 (kapı-3/kapı-4) aynı sınıftandı ve ikisi de bloker sayıldı.

### B6-7 — §3.2(9) izolasyonu TEK YÖNLÜ: hız sınırını ölçmeyen sınıflar için kova bütçesi yok
`[KS-10]` = **30 istek / 5 dk**, kapsamı `/login` + `/register`; partition **tek** (`RemoteIpAddress` `TestHost`'ta `null`); `FakeTimeProvider` pencereyi **ilerletemez** (§3.2(9)'un kendi ölçümü); pencerenin dolmasını beklemek **YASAK** (satır 1016). §3.2(9)'un kararı ise yalnız *"hız sınırını ÖLÇEN her test sınıfı kendi fabrikasını kurar"* diyor. ⇒ paylaşılan bir host örneğinin ömrü boyunca `/login`+`/register` çağrısı **31'e ulaştığı anda** sıradaki her auth testi `429` alır. **TS+TC etiketli 43 mutantın** çoğu en az bir `/register`+`/login` çifti ister.
⇒ §3.2(8)'in ve satır 1023'ün *"baseline YEŞİL doğar"* garantisi **kurulamaz**. Limiter'ı testte devre dışı bırakan bir kural da yok (`grep` ⇒ 0).

### B6-8 — K3-I4'ün Extract-atlama gerekçesi *"§3.1'de beyanlıdır"* diyor; §3.1'de YOKTUR
Satır 438 birebir: *"…türetme zayıflar ve bunu ölçen bir kapı YOKTUR — **§3.1'de beyanlıdır**."* §3.1'in kapısız-kalan tablosunda (satır 944-995) `K3-I4` · `HKDF` · `Extract` · kök anahtar entropisi ile ilgili **tek satır yoktur**.
Doktrin: *"beyan edilmiş sınır kabul edilir, gizlenmiş sınır edilmez"* — burada sınırın beyan edildiği **iddia ediliyor ama beyan edilmemiş**. Bu, kapı-5'in **B5-5**'te bloker saydığı kalıbın (*"beyan edildiği söylenen ama yazılmamış sınır"*) aynı belgede tekrarıdır.

### B6-9 — AAD'nin bayt-kodlaması KAPISIZ ve BEYANSIZ; §2-I'nin ilan ettiği *"AAD karıştırılır"* mutasyonunu hiçbir kill sinyali öldürmüyor
Satır 458 kapıları *"M50 · M51 (AAD kaldırılır/**karıştırılır**)"* diye sayıyor. *"Karıştırılır"* formu — ör. AAD `token_hash ‖ family_id` sırasına çevrilir ya da `family_id` `Guid.ToByteArray()` ile yazılır — şifreleme ve çözme **aynı kodu** kullandığı için sistemin davranışını **hiç değiştirmez**: satırdan satıra kopyalanan blok yine çözülemez ⇒ M51'in sinyali **geçer**.
Kırılan şey davranış değil **interop pinidir** ve K3-I5(2) bunu PAZARLIKSIZ ilan ediyor (satır 453: *"`family_id` **16 ham bayt** — RFC 9562 big-endian; iki bağımsız implementasyonun aynı AAD'yi kurması için baytlar BİREBİR yazılmak ZORUNDADIR"*). Belge tam bu sınıf için HKDF `info` etiketlerine **M42b altın vektörünü** yazmıştı (kapı-4 majör #13); AAD'nin kardeş kapısı **yok** ve §3.1'in kapısız listesinde de **yok**.
**Ek [MAJÖR, aynı kalem]:** M51'in ikinci mutasyon formu (*"yalnız `family_id` ile kurulur"*) için A ve B satırlarının **aynı ailede** olması pinli değil; farklı aile seçilirse o form da hayatta kalır. *(Red-team bu ayağı tersine çevirdi ve daralttı: aynı ailede mutant **ölür**; kusur pinin yokluğudur.)*

---

## 3. MAJÖRLER (31)

### 3.1 — Kanonik sayı disiplinindeki kırılmalar (9)
1. **[satır 106-107] §1-K'nın KENDİ aritmetiği BAYAT:** *"`KS-4` + `KS-6` = **120 sn**"*. Ölçüm: `[KS-4]` = **10 dk** (satır 99), `[KS-6]` = **60 sn** (satır 101) ⇒ **660 sn**. Belge bu literali satır 365'te **adıyla geri çekmiş** (*"K28-a `[KS-4]`'ü 60 sn'den 10 dk'ya çıkarınca bu literal SESSİZCE YANLIŞLANDI"*) — düzeltme §2-C(5)'e uygulanmış, **kaynağına uygulanmamış**. Araç bunu yapısal olarak göremez (B6-4 + K4'ün §1-K bölgesini atlaması). *Red-team daralttı: §6 Risk #13 ve M40 sembolik yazıldığı için hiçbir mutant bu literale çıpalı değil ⇒ kör kapı yok, ölü tuzak yok.*
2. **[satır 116-117] KS-11 ve KS-12 *"(kapısız — §3.1)"* diyor; §3.1'de o iki tavan için satır YOK** (`awk 'NR>=926&&NR<=990' | grep -c 'KS-11\|KS-12'` ⇒ **0**). Sarkan beyan. **[satır 145] KS-24 için aynı kusur** (*"(ölçüm, kapı değil — §3.1)"*, §3.1'de `K3-B1` satırı yok) ⇒ dört §3.1 atfının **üçü sarkıyor**.
3. **[satır 872] M31'in çıpasında MUAFİYETSİZ ham kanonik sayılar:** *"15/14 çifti pazarlıksızdır … çizgi 10'a da 15'e de düşse"*. `15` = `[KS-17]`, `14` = `[KS-17]−1`, `10` = geri çekilmiş çizgi. Aynı hücrenin kill sinyali doğru biçimi kullanıyor ⇒ tek hücrede iki standart. **Bu, K30-b'nin aradığı kalemin ta kendisidir** ⇒ §3.1'in *"çevrilecek gerçek bir sınır-değer literali YOKTU"* raporu **yanlıştır**.
4. **[satır 1086] `15 dk` ham kopya, muafiyet gerekçesi olgusal olarak YANLIŞ:** `<!-- [KS-LITERAL: XSS risk anlatımı — **kanonik sayı değil**] -->`. `15 dk` tam olarak `[KS-1]`'dir (satır 96). Muafiyet, aracı bilerek kör bırakıyor.
5. **[satır 193 · 216] `m=19456,t=2,p=1` iki kez ham yazılmış, muafiyet yok** — ve K3-B3 parametre değişimini **planlı** bir olay olarak yazıyor.
6. **[satır 637] `[KS-12]`'nin değeri (60 istek / 5 dk) gövdede ham yazılmış**, `[KS-LITERAL]` gerekçesi (*"v2'nin geçersiz kılınmış durumunun tarihsel kaydı"*) cümlenin yalnız ilk yarısını kapsıyor; sayı **yürürlükteki karardır**.
7. **[satır 568] `[KS-13]`+1'in ham literali (`6`) iki kez**; `[KS-13]` = 5. Araç `[KS-13]`'ü *"tek haneli literal"* diye **kapsam dışı** bırakıyor ⇒ §3.1'in *"sınır-değer literali yoktu"* iddiası, aracın kendi körlüğünü hesaba katmıyor.
8. **[satır 378] `≤20 dk`** = `[KS-1]` + `[KS-8]`'in varsayılanı; türev, atıfsız, muafiyetsiz.
9. **[satır 668 · 879] KS-3 belgede SIFIR kez atıf alıyor**, değeri iki yerde metin olarak kopyalanmış. Araç KS-3'ü *"türetilmiş değer"* diye kapsam dışı bırakıp *"ELLE kontrol edilmeli"* diyor; **o elle kontrol hiç yapılmamış.** *(Kardeşleri KS-5, KS-7 de ölü kayıt: yalnız kendi tanım satırlarında geçiyorlar.)*

### 3.2 — Mutant tablosu: ölmeyen ayaklar, ayırt edici olmayan mutantlar (11)
10. **[satır 908] M56 tabloda 7 hücre, başlık 5** — sebep `grep "blocklist|pwned|sızdırılmış"` içindeki **iki kaçışsız `|`**. GFM fazla hücreyi atar ⇒ **`[KS-31]` atfı, HIBP'nin adlandırılmış reddi ve satırın ÇIPASI `K3-B6(2)` ekranda kaybolur.** Bu, kapı-5'in M31'de bloker saydığı sınıfın **v6'nın yeni yazdığı satırda** yeniden doğmasıdır. *(Kaynakta bilgi kaybı yok ve araç çıpayı kaynaktan okuyor ⇒ red-team majöre indirdi. Belgenin tamamındaki **tek** hücre sapması budur.)*
11. **[satır 187 · 906] M54'ün ikinci ayağı kendi mutasyonu altında ÖLMÜYOR:** mutasyon `new byte[16]`, `[KS-23]`'ün salt uzunluğu **16 bayt** ⇒ *"salt alanı `[KS-23]`'ün salt uzunluğundadır"* mutasyon altında da doğru. Satır 833'ün PAZARLIKSIZ kuralının ihlali — üstelik M54 v6'nın **kendi yeni kalemidir**.
12. **[satır 872] M31 ayak 2** (*"tam `[KS-17]` → 201"*) kendi mutasyonu altında ölmüyor (süs ayak).
13. **[satır 858] M16** iki bağımsız mekanizmayı tek satırda **"veya"lı** mutasyonla taşıyor; her koşumda bir ayak süs. Aynı kusur **M21 (862)** · **M36 (878)** · **M48**'de. Belge doğru biçimi kendi içinde kurmuş (M4: *"İKİ AYRI COMMIT'TE koşulur"* · M36b: *"her biri AYRI commit"*) ve bu dört satıra uygulamamış.
14. **[satır 868] M27'nin *"aile iptal edilmez"* ayağı** mutasyon altında ölmüyor: `expires_at` yüklemi kaldırılınca `UPDATE` 1 satır döndürür, dal ayrıştırması **hiç koşmaz**.
15. **[satır 876] M34 ayak 2** (*"gövde bilinen/bilinmeyen e-posta ile aynıdır"*) `traceId` muafiyeti taşımıyor ⇒ satır 204'ün kendi ölçümüyle **ölü tuzak**; M37'de düzeltilmiş, M34'e taşınmamış.
16. **[satır 874] M33a'nın `GET /` ayağı süs:** `UseDefaultFiles`+`UseStaticFiles` auth'tan **önce** (satır 507) ⇒ `/` fallback'e hiç gitmez.
17. **[satır 882 ⟷ 895] M39 ile M45 aynı önkoşul, aynı ölçüt** (*"ailenin satır sayısı tam olarak 1 artmıştır"*) ⇒ kırmızı bir koşum hangi kararın bozulduğunu söylemez. Çakışma v6'nın kendi düzeltmesiyle doğdu. *(Red-team minöre indirdi: ikisi de kendi mutasyonu altında ölüyor; kayıp yalnız tanı ayırt ediciliği.)*
18. **[satır 901] M49'un ayırt ediciliği SIFIR:** kill sinyali *"M32b'nin NetArchTest kuralı kırmızıya döner"* — yani başka bir mutantın testi. Yeni assert, yeni gözlem yok. Bir mutant numarası tüketiyor **ve K18-a'yı ölçüm aracına "kapılı" gösteriyor.**
19. **[satır 888] M40'ın ikinci ayağı ölü tuzak riski taşıyor:** süpürücünün yaş eşiği `[KS-4]` = 600 sn; ayak yalnız `[KS-6]` = 60 sn ilerletiyor ⇒ yüklem tutmaz. Ayrıca süpürme **fazı** pinsiz ve K3-C6(5)'in *"`SweepAsync` doğrudan çağrılır"* gerekçesiyle çelişiyor.
20. **[satır 367 ⟷ 888] §2-C, M40'ın PİNLİ mutasyon biçiminin yasakladığı biçimi öneriyor** (*"süpürücü devre dışı bırakılır"* ⇒ servis kaydının kaldırılması, tablo bunu *"ayırt edici olmaz"* diye reddetmiş).
21. **[satır 892 ⟷ 900] M42'nin kill sinyali M42c ile %99,6 aynı;** M42 artık M42c'nin ölçmediği hiçbir şeyi ölçmüyor. §3.2(7) `KON` mutantlarını *"(M8b, M42c)"* diye sayıyor — tabloda **üç** `KON` satırı var.
22. **[satır 830 ⟷ M43] M43'ün üçüncü ayağı kapı-4'te ADIYLA *"ölmüyor"* diye ölçülmüş, v6'da hâlâ kill sinyalinde ve kendi mutasyonu yok.** M41→M41b, M31→M52, M36→M36b onarıldı; M43(3) onarılmadı. §3.1 onu K3-L10'un *"başlık yoksa 400"* kuralının **tek kapısı** ilan ediyor.

### 3.3 — Karar metinleri ile mutant tablosu arasındaki sapmalar (5)
23. **[satır 567] §2-J, M41'i hâlâ *"iki ayaklı"* ilan ediyor** ve mutant tablosunun (satır 890) ölçerek **süs** dediği ikinci ayağı kill sinyali olarak diriltiyor. **M41b, §2 gövdesinin tamamında 0 kez geçiyor** ⇒ kararı okuyan builder onun varlığını hiç öğrenmez.
24. **[satır 587 ⟷ 624] `Retry-After` iki yerde iki karar:** K3-J3'ün akış şeması kontrol 3 için de `Retry-After` yazdırıyor; K3-J4(b) *"kontrol 3'te YAZILMAZ"* diyor (ölçülmüş gerekçeyle: `ConcurrencyLease` `MetadataName.RetryAfter` taşımıyor). Hangisinin bağlayıcı olduğu yazılmamış ve hiçbir mutant ısırmıyor.
25. **[satır 545 ⟷ 576] Uç × kontrol matrisi çelişik:** tablo kontrol 2'yi *"yalnız `/login`"* diye pinliyor; bağlayıcı sıra şeması `/register`'ı da aynı akışa koyuyor.
26. **[satır 570 ⟷ 1012] M41'in önkoşul gerekçesi (*"K16-b sayıları bunu zaten sağlar"*) §3.2(9)'un kendi ölçümüyle çelişiyor.** Ayrıca §3.2(9) *"M41'in/M46'nın **negatif** assert'leri"* diyor — M41'in sinyali v6'da **pozitiftir**, M46'nınki hiç negatif olmadı, gerçekten negatif olan tek mutant **M41b**'dir ve §3.2(9)'a atıf yapmıyor, önkoşul da taşımıyor.
27. **[satır 441 · 907] M55'in gerekçesi (*"M42b de YEŞİL kalır"*) v6'nın KENDİ M42b kill sinyaliyle yanlışlanıyor:** M42b artık üç alt anahtarı altın vektöre pinliyor ⇒ etiketler eşitlenirse M42b **FAIL eder**. Aynı yanlış iddia iki yerde yazılı.

### 3.4 — Port envanteri, katman ve inşa boşlukları (4)
28. **[satır 773-787] Port envanteri TAM DEĞİL:** v6'nın kendi yeni mekanizması olan **sızmış-parola kara listesinin** (`[KS-31]`, `FrozenSet`, gömülü dosya) envanterde satırı yok; **K3-I5'in AES-256-GCM şifreleme/nonce/AAD mekanizmasının** da yok. §2-M kapı-4'ün B-4 blokerini kapatan bölümdür ve kendi turunun mekanizmalarını atlamış.
29. **[satır 785-786 ⟷ 564] Aynı iki kontrol için iki farklı inşa:** §2-M portları `ILoginAttemptWindow`/`IPasswordHashConcurrencyLimiter` (impl **Infrastructure**) diyor; satır 564 *"DI'dan alınan bir `PartitionedRateLimiter<string>`"* diyor (Application'a **somut çerçeve tipi** enjekte edilir). Hangi kural ayırt eder? Hiçbiri — `System.Threading.RateLimiting` hiçbir NetArchTest kuralında geçmiyor.
30. **[satır 466] Pinli anahtar dosyasının `Momentum:MasterKey`'e NASIL bağlandığı hiçbir yerde yazılı değil** (`Momentum__MasterKey` / `AddKeyPerFile` / `AddIniFile` ⇒ 0 eşleşme). Seçim M8b/M42c'nin koşum biçimini ve §3.2(10)'un üretim-eşdeğerliği iddiasını etkiler.
31. **[satır 804 ⟷ 981] `ICurrentUser`'ın yeri: §2-M *"tercih değil, kuralın sonucu"*, §3.1 *"bir mimari tercihtir, ihlal-edilebilir bir kural değildir"*.** Aynı belgede iki normatif hüküm; ve kural gerçekten Api'yi serbest bırakıyor (tablonun kendi 4. sütunu: *"`Microsoft.AspNetCore.Http` yalnız Infrastructure/**Api**"*).

### 3.5 — Aracın kapsamı ve beyanları (3) · dürüstlük muhasebesi (3)
32. **Aracın karar deseni `K\d+-[A-Z]\d+`** ⇒ `K18-a`/`K28-c`/`K14-f` ailesindeki **44 kimlik** hiç görülmüyor. *(Red-team daralttı: `grep -c '^\*\*K[0-9]*-[a-z]'` ⇒ **0** — bu aile karar başlığı değil, Onur çatal kilidi ⇒ *"K1=0 bakılmadı demektir"* **çürütüldü**. Kalan kusur: bu kapsam sınırı aracın 6 beyanının hiçbirinde yazılı değil.)*
33. **Araç 6 sınır beyan ediyor, §3.1 üçünü aktarıyor** — ve aktarılan üçüncüsü bir **sınır değil, aracın lehine bir güvencedir** (B6-5'te yanlış çıktı). Aktarılmayanların biri aracın kendi deyimiyle *"en büyük tek sınırı"*dır.
34. **Altın küme kontrol sayısı: §0 "22", §3.1 "21", araç 17 numaralı blok basıyor.** Kusur yalnız çelişki değil, *"kontrol"* biriminin **hiç tanımlanmamış** olmasıdır.
35. **[satır 13] *"iki `[DOĞRULANMADI]` etiketi canlıdır"* — canlı etiket ÜÇTÜR** (satır 1054 Isopoh lisans ailesi · 1084 `flutter_secure_storage` · 1091 WebKit). Öz-denetim beyanı tek `grep` ile yanlışlanıyor.
36. **[satır 1093 ⟷ §7] §6 Risk #17 *"§7'nin devir listesine yazılmıştır"* diyor; §7'de rotasyon 0 kez geçiyor.** Kapı-5'in B5-5 kusurunun bir seviye aşağıda tekrarı.
37. **[satır 965-970] `K4` adjudikasyonunun aritmetiği tutmuyor** (*"önce 35 bulgu"*; adjudike edilen 26+2+2 = **30**) ve aracın *"ZAYIF EŞLEŞMELER"* ile *"KAPSAM DIŞI BIRAKTIKLARI"* sınıfları belgenin **hiçbir yerinde geçmiyor** — *"aracın kendi kapsam beyanı"* diye yeniden adlandırılıp adjudikasyonsuz kapatılmışlar. Bölümün başlığı *"SESSİZ ELEME YOKTUR"* diyor.

---

## 4. ÇÜRÜTÜLEN / DARALTILAN İDDİALAR — dürüst kalibrasyon

**Bulgu şişirmesi engellendi.** Aşağıdakiler A turunda bulgu olarak geldi ve **Cowork'ün kendi ölçümü ya da red-team tarafından düşürüldü**:

1. **ÇÜRÜTÜLDÜ — *"§0.1–§0.3'ün ≈%6,5'i yanlış"*:** ölçtüm — `11.112 / 170.261 (v4) = **%6,53**`. Metin çıkarılan belge v4'tür ⇒ oran **doğrudur**. (`11.112 / 241.689 = %4,60` karşılaştırması yanlış paydayı kullanıyor.)
2. **ÇÜRÜTÜLDÜ — *"satır 28 'Üçü de §0.4'te' diyor ama §0.4'te 7 satır var"*:** cümle *"§0.4 yalnız üç satırdır"* demiyor; v4'ün üç geri çekmesinin orada listelendiğini söylüyor ve üçü de fiilen 46/47/48'de. Kalan dört satır v5/v6'nın kendi geri çekmeleridir — bölümün amacı budur.
3. **DARALTILDI — *"araç `K18-a` ailesini görmüyor ⇒ K1=0 anlamsız"*:** o ailenin hiçbir üyesi karar başlığı değil ⇒ desen genişletilse **0 yeni başlık** çıkardı.
4. **DARALTILDI — *"K3-L4 kapısız"*:** çıpası (M46) gerçekten sahte, **ama** M33a/M33b statik-dosya ayağını fiilen ısırıyor ⇒ kusur çıpa hijyenidir, kapısız karar değil.
5. **DARALTILDI — *"M51 ısırmıyor"*:** aynı ailede mutant **ölür**; kusur *"A ve B aynı ailededir"* pininin yokluğudur.
6. **DARALTILDI — *"M42'nin türetme yarısı gözlemsiz"*:** M42b (altın vektör) ve M55 türetme kaldırılırsa **ölür**. Kalan kusur: M42 artık artık bir satır.
7. **DARALTILDI — *"satır 908'in hücre taşması bilgi kaybıdır"*:** kaynakta kayıp yok, araç çıpayı kaynaktan okuyor ⇒ kayıp **render'dadır** (portfolyo belgesi olduğu için yine de majör).
8. **DARALTILDI — *"120 sn blokerdir"*:** hiçbir mutant o literale çıpalı değil ⇒ kör kapı da ölü tuzak da doğmuyor.

---

## 5. KIRILAMAYAN YERLER — denetçiler aradı, bulamadı

- **§3.1'in TAMLIK İDDİASI DÖRDÜNCÜ TURDA DA AYAKTA.** Bağımsız bir ayrıştırıcıyla 47 karar başlığının 47'si kapılı/beyanlı/devredilmiş olarak eşlendi; **kapısız-VE-beyansız karar YOKTUR**. Dağılım belgenin satır 951'deki kaydıyla birebir: `karar 47 · kapılı 32 · beyanlı 15 · devredilmiş 5 · mutant 51`.
- **Aracın v6 üzerindeki koşumu birebir tekrarlandı:** `K1`=0 · `K2`=0 · `K3`=0 · `K5`=0 · `K6`=2 · `K4`=5 · altın küme çıkış kodu **0**. Belgenin satır 7'deki beyanı doğrudur.
- **ALTIN KÜME GERÇEKTEN ISIRIYOR: 17 kontrolün 17'si mutasyonla zorlandı, 17'si de kırmızı verdi (çıkış kodu 2).** Kapı-5'in en ağır endişesi — *"altın küme süs olabilir"* — **kapanmıştır**.
- **§3.1(c)'nin iki yanlış-pozitif adjudikasyonu DOĞRULANDI** (satır 853 ve 890'daki `9` gerçekten `§3.2(9)` bölüm atfıdır). **Belgeyi aracı susturmak için değiştirmeme kararı DOĞRUDUR** — kapı tiyatrosu olurdu.
- **NUMARA BÜTÜNLÜĞÜ TAM:** boşluklar tam olarak beyan edilen kümeler (M2·M3·M9·M10·M20 = 0004 rezervi; M13 VOID; M57-M59 tampon); **çift kayıt 0**; 0004'ün `M60` pini üç yerde tutarlı.
- **`[çıpa+]` / `[devir]` sayıları ölçümle birebir** (12 + 5) ⇒ kapı-5'in *"16 ≠ 18"* tutarsızlığı **gerçekten çözülmüş**.
- **SARKAN MUTANT/KS ATFI YOK (ileri yön):** tablodaki 37 `K3-…` ve 13 `[KS-n]` atfının tamamı §2'de / §1-K'da tanımlı. **§6'nın 17 risk kaleminin numaralandırması boşluksuz ve 21 `Risk #n` atfının 21'i de var olan bir kaleme düşüyor** ⇒ kapı-5'in *"Risk #17 yok"* blokeri kapandı.
- **`[KS-4]` → K16-b yanlış atfı tamamen temizlenmiş** (12 `K16-b` geçişinin hiçbiri canlı yanlış atıf değil).
- **ADR 0001 K-H1 alıntısı kelime kelime sadık** (yalnız markdown vurgusu eklenmiş).
- **M44 · M50 · M55 · M12 · M15 · M19 · M30 · M32/M32b/M32c · M35 · M36b · M40b · M42b/M42c · M52 · M53'ün saat ayağı** — zorlandı, ısırdıkları doğrulandı.
- **Gölgeleme bulgusu ÇÜRÜTÜLEMEDİ.** Kapı-6 bunu çürütmekle yükümlüydü; iki bağımsız denetçi adım adım yürüttü ve **iddia doğru çıktı** — üstelik §6 #11'in kendi `[KS-1]` tavanını da yıkacak kadar güçlü (aşağıda B6-A). Belgenin geri çekmesi (§0.4 satır 52) **yerindedir**. *Bir alt-iddia ÇÜRÜTÜLDÜ: zincir çatallanmaz — dal (c) yeni token üretmediği için iki taraf **daima aynı halefi** alır.*

---

## 6. KAPI-6'NIN KENDİ BULDUĞU EK KALEMLER

**B6-A [MAJÖR → v7 için karar gerektirir] — GÖLGELEMENİN ÖLÇÜSÜ §6'da YANLIŞ YAZILI.**
§6 #11 *"çevrimiçi kurbanda `[KS-1]`"* tavanını kuruyor, sonra *"ayrıca gölgeleme mümkündür"* diyor. Ama gölgeleme o tavanı **yok eder**: `[KS-4]` (10 dk) < `[KS-1]` (15 dk) olduğu için saldırganın her turda pencereye yetişmek için **10 dakikalık bütçesi** vardır ve maliyeti 5 dk'da bir bir `/refresh`'tir — `[KS-11]` = 120 istek/5 dk tavanının çok altında. ⇒ **çevrimiçi kurbanda da en kötü durum `[KS-1]` değil `[KS-2]`'dir (15 dk değil 30 gün).** Bu sayı belgenin **hiçbir yerinde** yazmıyor. §6 kabul edilen en kötü durumu yazmakla yükümlü olan bölümdür.
Ayrıca **§6 #16'nın RFC 9700 uyum hükmü** bu yanlış ölçüye dayanıyor ve gölgelemeyi hiç anmıyor.

**B6-B [MAJÖR] — Gölgelemenin ADLANDIRILMAMIŞ bedeli:** çarpışma sonunda iptal edilen şey **ailedir** ⇒ tespit anı, meşru kullanıcının yeniden giriş ekranı görmesidir. Bu, K14-a'nın seçilme gerekçesinin (*"uçak modu demosunun ortasında yeniden giriş"*) tam kendisidir ve *"dürüst muhasebe"*de yazılı değil.

**B6-C [MİNÖR] — satır 354'ün *"zincir yeni token basmaz"* ifadesi yanıltıcı:** zincir her adımda yeni token basar; basan şey replay dalı değil, karşı tarafın normal döndürmesidir. Ölçülebilir doğru ifade: *"replay dalı ailenin satır sayısını artırmaz."*

**B6-D [MAJÖR] — K3-B7'nin savunmacı dalı K3-B5'in *"aynı işi yapar"* garantisini kırıyor:** bozuk PHC yolunda Argon2 hiç koşmadan `401` döner (≈1 ms vs ≈270 ms) ⇒ *"hızlı 401 = bu hesap VARDIR"*. Kapısı yok (M34 gövde+kod ölçer, M37 gövde, M7 çağrı sayısı), beyanı yok. **Onarımı tek cümledir.**

---

## 7. KAPI-6'NIN ÖLÇEMEDİKLERİ VE ÜÇ SINIRI

**ÖLÇÜLEMEYENLER (adlandırılıyor, gizlenmiyor):**
1. **ADR 0002 (`0002-senkron-mekanigi.md`) bu denetime BAĞLANMADI ve HİÇ AÇILMADI.** Belge ona 9 satırda atıf yapıyor (`K2-E3` ×6 · `K2-E5` ×2 · `K2-A4` ×2 · `K2-H12` ×2 · `K2-I3`) ve bunların bir kısmı **tırnak içinde "birebir alıntı" iddiasıdır**. **K14-h'nin (dilim yeniden adlandırma) tek gerekçesi K2-I3'tür ve doğrulanmamıştır.**
2. **`src/` · `tests/` · `docker-compose.yml` bağlı değildi** ⇒ §3.2'nin koşum sözleşmesi gerçek kod tabanına karşı **ölçülemedi**. Belge kapı-4'ün aynı körlüğünü §0'da adıyla kaydetmişti; kapı-6 aynı körlükte koştu.
3. **Birincil kaynak alıntıları (30+) bağımsız doğrulanmadı** — NIST SP 800-63B-4 (13 atıf), RFC 9700/9562/6265/4648, aspnetcore `release/9.0`'ın 10 kaynak-kodu iddiası. **[DOĞRULANMADI]** Bir aday sapma: `[KS-19]` *"254 karakter (RFC 5321 **yol sınırı**)"* — RFC 5321'in yol sınırı 256'dır ve 254 türetilmiş bir değerdir; atıf gevşek görünüyor ama **bu turda birincil kaynaktan ölçülemedi**.
4. **Gerçek GitHub render'ı ölçülemedi** (yalnız hücre sayımı ve CommonMark ayrıştırması yapıldı).
5. **`docs/ODEV.md` ile çelişkiler [YENİ, ölçüldü]:** ODEV §3.1/§4.1/§6.1 dilimi hâlâ **`slice-3a-auth`** diye anıyor (ADR 8 yerde `slice-3c-auth`); ODEV §6.1 dilimi **1,5-2 gün** diye kutuluyor; ODEV §6 *"Backend'de kalan işler **zaman kutulanmalıdır**"* diyor, K13-a ise *"tur sayısı **sınırlanmaz**"* diyor. **Bu iki kural aynı anda yürürlükte olamaz ve adjudike edilmemiştir.**

**KAPI-6'NIN ÜÇ SINIRI — bir sonraki denetçiye:**
1. **Kapı-6 belgeyi belgeye karşı denetledi, KAYNAĞA karşı değil.** ADR 0002, `src/`, `tests/`, ağ ve KANIT'ın bir kısmı kapının dışında kaldı. **Kapı-7 bu dosyalar bağlanmadan başlamamalıdır**; bağlanamıyorsa *"öncül-kör koşuldu"* diye yazılmalıdır.
2. **Kapı-6 de bir üretimdir.** Bu raporun her satır numarası ve her komutu tekrarlanabilir; **kapı-7 bu raporu da denetlemelidir.** Özellikle §4'teki sekiz çürütme/daraltma kararı — bir bulguyu düşürmek, bulmak kadar hatalı olabilir.
3. **Araç artık ISIRIYOR ama KAPSAMI DAR.** Altın küme 17/17 zorlandı ve geçti; buna karşılık K4 §1-K bölgesini, türetilmiş değerleri, `KS-n → kapı` sütununu ve tek haneli literalleri **yapısal olarak taramıyor**, ve **satır 412'de sessiz bir kaçış kapısı var (B6-4)**. **Aracın yeşili hâlâ tek başına kanıt değildir.**

---

## 8. FARKLI MODEL SALDIRISI (K32-c) — SONNET, 10 VEKTÖR

**6 saldırı KAÇTI** (araç 0 bulgu / çıkış kodu 0 verdi, belge gerçekte kusurluydu):
1. **Kiril homoglif karar başlığı** (`**К9-D1**`, U+041A) — karar sözlüğe hiç girmiyor.
2. **Küçük harfli aile, saf ASCII** (`K9-d1`) — aynı körlük, Unicode gerektirmeden.
3. **Çıpa hücresine alakasız karar doldurma** — bedava *"kapılı"*. *(Aracın kendi beyan ettiği en büyük sınırı; somut belgeyle kanıtlandı.)*
4. **Kanonik sayıyı yazıyla yazmak** (*"on beş dakika"*) — K4 yalnız rakam arıyor.
5. **THIN SPACE (U+2009) ile bölünmüş sayı** — `GORUNMEZ` listesi yalnız 7 sıfır-genişlikli karakteri temizliyor.
6. **Uzak satırdaki *"rezerv"* kelimesiyle mutant-boşluğu affı** — af mantığı belgenin tamamını tarıyor, yalnız §3'ü değil.

**4 saldırı YAKALANDI:** gerekçesiz `[KS-LITERAL:]` (raporlanıyor) · §3.1'i HTML `<table>` ile yazmak (K1+K6 ile dürüstçe ihbar) · başlığı `### 3-1` yapmak (K0+K1+K6) · kaçışsız `|` ile hücre taşırma (kendi ayağına sıktı).

**Dürüst kayıt:** Sonnet ile Opus aynı aileden ⇒ kör nokta korelasyonu azalır, **sıfırlanmaz**. Bu bir ek örneklemdir, garanti değil.

---

## 9. v7'NİN YAPMASI GEREKENLER — sıralı

**Onur kararı gerektirenler (çatal):**
- **Ç-1:** `[KS-31]` kara listesi ile `[KS-17]` = 15'in kesişimi. Ya prob ≥15 karakterlik bir liste kaydına çevrilir (ve böyle bir kaydın varlığı ÖLÇÜLÜR), ya `[KS-31]`'in seçim ölçütü değişir, ya kalem kapsam dışı ilan edilir. (B6-1)
- **Ç-2:** K3-L8'in dördüncü dalı (*"kimlik hiç yok"*) ve çıkışta aktif profil kaydının kaderi. Bu bir ŞEMA kararıdır ve Drift'i bağlar. (B6-6)
- **Ç-3:** §3.2(9)'un izolasyonu tüm auth testlerine mi genişletilir, yoksa testte limiter devre dışı mı bırakılır? (B6-7)
- **Ç-4:** **ODEV × K13-a çatışması** — *"zaman kutulanmalıdır"* ile *"tur sayısı sınırlanmaz"* aynı anda yürürlükte olamaz. Bu, v6→v7 döngüsünün **sonlanma kanıtı** sorusudur ve bugüne kadar hiç sorulmadı.

**Karar gerektirmeyen yazım işleri:** B6-2 · B6-3 · B6-4 (araç) · B6-5 (araç + §3.1) · B6-8 · B6-9 · 31 majörün tamamı · B6-A/B/C/D.

**Araç onarımı (B6-4, B6-5 + Sonnet'in 6 kaçışı) AYRI BİR ELDEN çıkmalıdır** — v7'yi yazan el aracı onarırsa K29-a'nın bedeli üçüncü kez ödenir.

---

*Bu rapor bir üretimdir ve kendi üreticisi tarafından onaylanmamıştır. Kapı-7 onu da denetlemekle yükümlüdür.*
