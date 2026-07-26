# v7 — NORMATİF ATIF DENETİMİ (BİRİNCİL KAYNAKTAN)

**Tarih:** 26 Tem 2026 · oturum 27 · **Yetki:** K39-b(a) (Onur kilidi)
**Denetlenen:** `docs/ADR/0003-kimlik-cekirdegi-v7-YAZIM-DEVAM-EDIYOR.md`
**Yöntem:** her normatif atıf **birincil kaynaktan** açıldı ve **karakter düzeyinde** karşılaştırıldı. Aşağıdaki alıntılar kaynağın **kendi metnidir**; yeniden yazılmadı.

> **KAPSAM SINIRI [beyan edilmiş]:** bu denetim **NORMATİF** atıfları kapsar. `aspnetcore` kaynak satırları (×10) **atıf değil DAVRANIŞ ÖLÇÜMÜDÜR** ⇒ K39-b(b) gereği **build'de koşularak** doğrulanır ve `GOREV-slice-3c-auth`'a devredildi (ADR §8.3). **NIST SP 800-38D** (GCM nonce tekrarı, §2-I) **bu turda AÇILMADI** ⇒ **`[DOĞRULANMADI]`**.

---

## 1. NIST SP 800-63B — Revision 4

**Kaynak:** `pages.nist.gov/800-63-4/sp800-63b.html` · **Status: Published · Date: August 26, 2025** (sayfada basılı olduğu gibi) ⇒ belgenin *"(Final)"* nitelemesi **DOĞRU**.

### 1.1 — TUTAN DÖRT KALEM (§3.1.1.2)

1. **Asgari uzunluk, tek faktör — `[KS-17]`'nin dayanağı:**
   *"Verifiers and CSPs **SHALL** require passwords that are used as a single-factor authentication mechanism to be a minimum of 15 characters in length."*
   ⇒ ADR satır 277'nin birebir alıntısı **TUTTU.**
2. **Çok faktörlü bileşen:**
   *"Verifiers and CSPs **MAY** allow passwords that are only used as part of multi-factor authentication processes to be shorter but **SHALL** require them to be a minimum of eight characters in length."*
   ⇒ ADR'nin parantez içi nitelemesi **DOĞRU** (alıntı olarak sunulmuyor).
3. **Kompozisyon kuralları:**
   *"Verifiers and CSPs **SHALL NOT** impose other composition rules (e.g., requiring mixtures of different character types) for passwords."*
   ⇒ ADR *"… for passwords"* biçiminde, **kısaltmayı `…` ile İŞARETLEYEREK** alıntılıyor ⇒ **K35'in kuralına UYGUN, TUTTU.**
4. **Azami uzunluk:**
   *"Verifiers and CSPs **SHOULD** permit a maximum password length of at least 64 characters."*
   ⇒ ADR **işaretli kısaltmayla** doğru alıntılıyor; **`[KS-18]` bu tavsiyenin ÜSTÜNDEDİR** ⇒ sapma değildir. **TUTTU.**

### 1.2 — 🔴 SAPMA S-2: *"aşağıda birebir"* DENİLEN ALINTI BELGEDE YOKTU (§3.1.1.2)

**Birincil kaynak:**
*"Verifiers **SHALL** compare the prospective secret against a blocklist that contains known commonly used, expected, or compromised passwords."*

**Ölçüm:** ADR'de `blocklist that` / `prospective secret` ⇒ **0 eşleşme.** §1-K'nın politika tablosu bu `SHALL`'a **"(aşağıda birebir)"** diye gönderme yapıyordu ve **aşağıda böyle bir alıntı yoktu.**
**SINIF:** B5-5 / B6-8 / K35'in *"beyan edildiği söylenen ama yazılmamış"* ailesinin **YENİ örneği.**
**DÜZELTME:** alıntı K3-B6(2)'nin altına **birebir** yazıldı; bölüm numarası (`§3.1.1.2`) eklendi.
**DERS:** bu kusuru **dört turluk okuma bulamadı; BİRİNCİL KAYNAĞIN AÇILMASI buldu.** K38-b'nin **çapraz-atıf çözücüsü** bu sınıfı mekanik yakalayacaktır.

### 1.3 — 🔴 SAPMA S-1: §3.2.2 ALINTISI BİREBİR DEĞİLDİ

**Birincil kaynak (§3.2.2):**
*"The verifier **SHALL** limit consecutive failed authentication attempts **using a specific authenticator** on a single **subscriber** account to no more than 100 by disabling that authenticator."*

**ADR'nin v6/v7'de yazdığı (yanlış):**
*"the verifier SHALL limit consecutive failed authentication attempts **on a single account** to no more than 100 by disabling that authenticator."*

**İKİ İŞARETSİZ KISALTMA:** `using a specific authenticator` **düşürülmüş** · `subscriber` **düşürülmüş**. **`…` işareti YOK** ⇒ **K35'in PAZARLIKSIZ kuralının ihlali.**
**NEDEN ANLAMLI:** sınır **kimlik-doğrulayıcı BAŞINA** tanımlıdır ve *"disabling that authenticator"* ona geri gönderme yapar; kısaltılmış hâl sınırı **hesap başına** okutuyordu.
**BU, BELGENİN İKİNCİ ÖLÇÜLMÜŞ YANLIŞ BİRİNCİL-KAYNAK ATFIDIR** (birincisi `[KS-19]`'un RFC 5321 atfıydı — oturum 25).
**SAPMANIN YÖNÜ:** düzeltme, adlandırılmış sapmayı **zayıflatmaz, GÜÇLENDİRİR** (gerçek `SHALL` daha dar kapsamlı; Momentum'un throttle'ı hiçbir kapsamda devre dışı bırakma yapmaz) ⇒ **sapma aynen durur, gerekçesi aynen geçerlidir.**

---

## 2. RFC 9700 §4.14.2

**Kaynak:** `rfc-editor.org/rfc/rfc9700`

1. **TUTTU — `MUST`'ın konusu:** *"Authorization servers **MUST** utilize one of the following methods to detect refresh token replay"* ⇒ ADR'nin *"yöntemlerden **birini** kullan"* nitelemesi **DOĞRU.**
2. **TUTTU — birebir alıntı:** *"This stops the attack at the cost of forcing the legitimate client to obtain a fresh authorization grant."* ⇒ ADR satır 844'ün alıntısı **BİREBİR DOĞRU.**
3. **🔴 SAPMA S-3 — aile iptali NORMATİFTİR:** *"If a refresh token is presented for which a refresh token rotation has already been performed in a previous token request, the authorization server **SHOULD** revoke the complete token family."*
   **ADR (yanlış):** o cümlenin **"betimleyici"** olduğunu yazıyordu ⇒ **birincil kaynakta bir `SHOULD`'dur, yani NORMATİFTİR.**
   **HÜKÜM DEĞİŞMEZ, ZEMİN DEĞİŞİR:** Momentum döndürme + yeniden-kullanım tespiti uygular **ve aileyi iptal eder** ⇒ `SHOULD` **KARŞILANIR**, ihlal yoktur. Yanlış olan *"cümle betimleyici olduğu için bağlayıcı değil"* gerekçesiydi. **Düzeltildi.**

---

## 3. RFC 9562 (UUID)

**Kaynak:** `rfc-editor.org/rfc/rfc9562`
**TUTTU (§4):** *"Saving UUIDs to binary format is done by sequencing all fields in big-endian format."* · *"…each field is encoded with the most significant byte first (known as \"network byte order\")."* · **§6.11:** *"UUIDs created by this specification are crafted with big-endian byte order (network byte order) in mind."*
⇒ ADR'nin **AAD bayt kodlaması pini** (`family_id` = 16 ham bayt, **RFC 9562 big-endian**) ve **M42b/M51'in altın vektörü** **DOĞRU ZEMİNDEDİR.**
> **Beyan edilmiş sınır:** ADR'nin *"`Guid.ToByteArray()` DEĞİL"* ifadesi bir **BCL davranış iddiasıdır**, RFC atfı değil ⇒ **K39-b(b) sınıfına girer** ve build'de koşularak doğrulanır (ADR §8.3).

---

## 4. RFC 4648 — 🟠 MİNÖR M-1 (atıf hijyeni, sapma DEĞİL)

**Kaynak:** `rfc-editor.org/rfc/rfc4648`
**§5** URL-güvenli alfabeyi tanımlar (62. ve 63. karakter `-` ve `_`) ve dolgunun atlanabileceğini **anar**, ama **§3.2'ye gönderir**.
**§3.2 (normatif hüküm):** *"Implementations **MUST** include appropriate pad characters at the end of encoded data unless the specification referring to this document explicitly states otherwise."*
⇒ ADR yalnız **§5**'e atıf yapıyordu. **Değer DOĞRU** (dolgusuz Base64Url), **atıf EKSİKTİ**: dolgunun atlanması **§3.2**'nin *"referans veren spesifikasyon açıkça aksini belirtir"* şartına bağlıdır ve **BU ADR o spesifikasyondur** ⇒ atıf `§5 (alfabe) + §3.2 (dolgu)` olarak düzeltildi ve ADR'nin açık beyanı **o şartı karşılar.**

---

## 5. rfc6265bis — TUTTU

**Kaynak:** `httpwg.org/http-extensions/draft-ietf-httpbis-rfc6265bis.html`
- **§5.2** *"'Same-site' and 'cross-site' Requests"* · **§5.2.1 = "Document-based requests"** ⇒ ADR satır 840'ın **§5.2.1** atfı **DOĞRU** (sayfa yüklendikten sonra aynı origin'e giden `fetch` same-site'tır).
- **§4.1.3.2 — The "__Host-" Prefix:** *"If a cookie's name begins with a case-sensitive match for the string `__Host-`, then the cookie will have been set with a `Secure` attribute, a `Path` attribute with a value of `/`, and no `Domain` attribute."*
- **⚠ ÇAPRAZ KONTROL:** **RFC 6265 (2011) `__Host-` önekini ve same-site tanımını İÇERMEZ**; o belgede **§5.2.1 = "The Expires Attribute"**'tur ⇒ *"RFC 6265"* ile *"RFC 6265bis"* karıştırılırsa bölüm numaraları **sessizce yanlış yere düşer.** ADR **doğru belgeyi** (bis) anıyor. **Öneri (devir):** `__Host-` için **§4.1.3.2** numarası da yazılabilir; bugün numarasız.

---

## 6. HÜKÜM

| kaynak | kalem | sonuç |
|---|---|---|
| NIST 63B-4 §3.1.1.2 | asgari uzunluk `SHALL` (tek faktör) | ✅ TUTTU |
| NIST 63B-4 §3.1.1.2 | çok faktörlü bileşen asgarisi | ✅ TUTTU |
| NIST 63B-4 §3.1.1.2 | `SHALL NOT` kompozisyon | ✅ TUTTU |
| NIST 63B-4 §3.1.1.2 | `SHOULD` azami uzunluk | ✅ TUTTU |
| NIST 63B-4 §3.1.1.2 | kara liste `SHALL` | 🔴 **S-2: alıntı YAZILMAMIŞTI** — yazıldı |
| NIST 63B-4 §3.2.2 | throttling `SHALL` | 🔴 **S-1: alıntı BİREBİR DEĞİLDİ** — düzeltildi |
| RFC 9700 §4.14.2 | `MUST` = yöntemlerden biri | ✅ TUTTU |
| RFC 9700 §4.14.2 | *"This stops the attack…"* | ✅ TUTTU |
| RFC 9700 §4.14.2 | aile iptali betimleyici mi | 🔴 **S-3: bir `SHOULD`'dur** — zemin düzeltildi |
| RFC 9562 §4 / §6.11 | big-endian | ✅ TUTTU |
| RFC 4648 | dolgunun atlanması | 🟠 **M-1: §3.2 bağı eksikti** — eklendi |
| rfc6265bis §5.2.1 | document-based requests | ✅ TUTTU |
| NIST SP 800-38D | GCM nonce tekrarı | ⚠ **`[DOĞRULANMADI]`** — bu turda açılmadı |
| `aspnetcore` ×10 | davranış | ⏭ **build'e devredildi** (K39-b(b), §8.3) |

**ÜÇ SAPMA + BİR MİNÖR ÖLÇÜLDÜ VE DÜZELTİLDİ.** **Hiçbir KARAR değişmedi** — değişen şey **alıntıların doğruluğu ve gerekçelerin zemini**dir.

**K39-b'NİN GEREKÇESİ ÖLÇÜMLE DOĞRULANDI:** Onur bu turu *"portfolyoda en zarar veren kusur sınıfı budur"* diye açtı; tur **iki yanlış/eksik normatif alıntı** buldu — ikisi de bir değerlendiricinin **tek arama** ile bulabileceği türden.

**ARAÇ (düzeltmelerden SONRA, K39-a — araca DOKUNULMADI):** altın küme `EXIT=0` · v7'de `K1`=0 · `K4`=5 · `K6`=2 ⇒ **TOPLAM 7 = v6 taban çizgisi** · `capasiz_tablo`=0 ⇒ **bu turun düzeltmeleri YENİ araç bulgusu ÜRETMEDİ.**

**⚠ BU DENETİM DE BİR ÜRETİMDİR ve kendi üreticisi tarafından onaylanamaz — KAPI-7 onu da adjudike etmelidir** (özellikle: S-1'in *"sapmayı güçlendirir"* yorumu · S-3'ün *"`SHOULD` karşılanır"* hükmü · M-1'in *"bu ADR referans veren spesifikasyondur"* okuması — **üçü de yorumdur, ölçüm değil**).
