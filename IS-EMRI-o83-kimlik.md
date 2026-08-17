# İŞ EMRİ o83 — DİLİM 1: KİMLİK

`MOD: NORMAL` · kutu **18-21 Ağu 2026** · yazan: Cowork · koşacak: **Claude Code**
Kilit: [Onur, 18 Ağu 2026] — boşluk kapatma planı, dilim 1/5.

---

## 0. BU DİLİMİN DEMİR KURALI

🔴 **ADR YAZILMAYACAK. SPEC YAZILMAYACAK. KÂĞIT DENETİM TURU YOK.**

Bu dilim bir kez denendi ve **30 gün** yedi. Sebebi tahmin değil, ölçüldü ve `docs/ODEV.md` §6.1
errata'sında yazılı: *"'1,5-2 gün' TAHMİNİ TUTMADI"* — dilimi kod değil **ADR 0003 için altı yazım
turu + altı kapı turu** öldürdü. O kural (`K127`, kilit-öncesi zorunlu ön-denetim) **feshedildi**;
yürürlükteki kural İŞLEYİŞ md.4: *"Kâğıt denetim turu = 0. Denetim yalnız koşan artefakta."*

Yol: **bu iş emri → kod → çalışan üründe canlı ölçüm → BİTTİ.** Arada belge yok.

---

## 1. SORUN

`docs/ODEV.md` §6.1 ince kimlik dilimini kilitledi; **teslim edilmedi.** Bugünkü durum ölçülmüş:

- Giriş ekranı **yok**, kullanıcı modeli **yok**, JWT/OIDC **yok**, yenileme token'ı **yok**.
- İstemci `devUserId` taşıyor; `WireOp.ActorId` **istemci-beyanlı** — sunucu doğrulamıyor.
- Yerine duran şey `K61` ölçüm iskelesi: `Development`ta `X-Momentum-Dev-User` başlığı `UserId`
  taşır, başlık yoksa **401**; `Production`da `NullCurrentUser` — deny-by-default, mutantla kanıtlı.

Bunun iki bedeli var. Birincisi kendi başına eksik. İkincisi **zincirleyici**: ÖDEV §6.1 birebir
diyor ki *"gerçek zamanlı işbirliği vitrini iki gerçek kullanıcı ister"* ⇒ **dilim 3 (işbirliği)
bu dilim bitmeden başlayamaz.**

---

## 2. YAPILACAK

### 2.1 Backend

1. **`users` tablosu + migration.** Asgari: `id` (uuid) · `email` (benzersiz, normalize) ·
   `password_hash` · `created_at`. Fazlası yok.
2. **Uçlar:** `POST /v1/auth/register` · `POST /v1/auth/login` · `POST /v1/auth/refresh` ·
   `POST /v1/auth/logout` (yenileme token'ını geçersizler).
3. **Parola hash'i:** ASP.NET Core'un **yerleşik** `PasswordHasher<T>`i kullanılır.
   *Gerekçe: yeni bağımlılık getirmez ⇒ lisans + CVE kapısı açılmaz.* BCrypt/Argon2 paketi ekleme.
4. **Token:** kısa ömürlü **erişim** JWT'si + uzun ömürlü **yenileme** token'ı (DB'de saklanır,
   döndürülebilir/iptal edilebilir). Yenileme token'ı ÖDEV §6.1'de **pazarlıksız** yazılı:
   *"çevrimdışı istemcide erişim token'ı süresi dolduğunda kuyruktaki yazımların kaybolmaması
   mimari zorunluluktur, konfor değil."*
5. **`ICurrentUser` JWT'den okur.** README zaten *"gerçek kimlik eklendiğinde değişmesi gereken tek
   yer `ICurrentUser` uygulamasıdır"* diyor — o cümleyi doğrula ya da çürüt, ikisi de kabul.
6. 🔴 **F5 KİLİDİ — bu dilimin asıl kazancı:** `WireOp.ActorId` artık **sunucudaki doğrulanmış
   `UserId`'den yazılır**. İstemcinin gönderdiği `ActorId` **yok sayılır** (silinmez, ezilir).
   `UserId ⟂ ClientId` ayrımı korunur: kimlik kullanıcıya, senkron kimliği cihaza ait.
7. **Dev-header kalkanı KALIR** (`Development` profilinde). Sebep ölçülmüş: `paket.yml` AYAK 3
   (`POST /v1/sync` başlıksız 401, `X-Momentum-Dev-User` ile 200) ve mevcut 127 backend testi buna
   dayanıyor. JWT **ikinci ve birincil** yol olarak eklenir; ikisi de aynı `ICurrentUser`'ı besler.
   Kaldırma işi bu dilimin kapsamında **değildir**.

### 2.2 İstemci (Flutter)

8. **Giriş + kayıt ekranı.** Uygulama açılışında oturum yoksa buraya düşer.
9. **Token saklama:** `flutter_secure_storage` (Android: EncryptedSharedPreferences).
   🔴 **YENİ BAĞIMLILIK** ⇒ kırmızı çizgi gereği `araclar/pub-lisans-kapisi.py` ve
   `araclar/pub-cve-kapisi.py` **koşulacak ve çıktısı KANIT'a yazılacak.** Kapı kırmızı yanarsa
   paket eklenmez, token Drift'te saklanır ve **web'de zayıf olduğu README'ye yazılır.**
10. **401'de sessiz yenileme:** istek 401 dönerse yenileme denenir, başarılıysa istek **tekrarlanır**.
11. 🔴 **Yenileme de düşerse kuyruk KORUNUR.** Kullanıcı giriş ekranına döner ama itme kuyruğundaki
    yazımlar **silinmez**; yeniden giriş yapınca **aynı kullanıcıysa** kuyruk gönderilir.
12. **Çıkış (logout):** yenileme token'ı sunucuda iptal edilir. Yerel veriye ne olacağı
    §2.3'teki kararla aynıdır.

### 2.3 Mevcut veriyle ne olacak — karar

Bugün `DURUM.md` sınır 29 şu mekanizmayı ölçmüş: `DEV_USER_ID` mevcut kimlikten farklıysa ilk
açılışta **yerel görevler ve senkron kuyruğu aynı transaction'da silinir**. **Aynı mekanizma
yeniden kullanılır:** giriş yapılan `UserId`, yereldeki kimlikten farklıysa yerel veri temizlenir.
Yeni mekanizma icat etme. Bu davranış README'ye tek cümleyle yazılır.

---

## 3. ÖLÇÜM PROTOKOLÜ

Sıra pazarlıksız (mayın 6): **cihaz/canlı kanıt → backend kapat → `verify.ps1`.**

1. `cd src/client` (mayın 3: repo kökünden koşarsa yalan söyler) → `flutter analyze` → **0 uyarı**.
2. `flutter test` → **tüm testler yeşil**; sayıyı yaz (bugün 708, artacak).
   `KANIT/slice-3c/02-G2/*.json` yeniden yazılır, **commit'e girmez** (mayın 9).
3. Backend: `dotnet test` → **tüm testler yeşil**; sayıyı yaz (bugün 127, artacak).
4. **Canlı tur** — `docker compose up --build` ya da geliştirici yolu:
   a. Hesap A açılır, giriş yapılır, görev eklenir.
   b. **Çıkış yapılır**, hesap B açılır → **A'nın görevi GÖRÜNMEZ.**
   c. B'de görev eklenir, çıkış, A'ya giriş → **B'nin görevi GÖRÜNMEZ.**
   d. A ile giriş, ağ kesilir, görev yazılır (kuyrukta *"↑ Gönderiliyor"*), erişim token'ının
      süresi dolacak kadar beklenir/zorlanır, ağ açılır → satır **kaybolmadan** sunucuya ulaşır.
   e. `GET /v1/tasks` Authorization başlığıyla **200**, başlıksız **401**.
5. **Yeni bağımlılık kapısı** (§2.2/9 eklendiyse): `pub-lisans-kapisi.py` + `pub-cve-kapisi.py`
   çıktısı `KANIT/o83/` altına.
6. Backend kapatılır (`netstat -ano | findstr :5298` **boş** dönmeli — kapatmayı yalnız Onur'un
   izniyle) → `araclar\verify.ps1` → **EXIT 0**.
7. Ham çıktıların hepsi `KANIT/o83/` altına yazılır.

---

## 4. KABUL ÖLÇÜTÜ

Dilim ancak şunların **hepsi** sağlanınca BİTTİ sayılır:

- [ ] §3.4(b) ve §3.4(c) canlıda ölçüldü: **iki hesap birbirinin görevini görmüyor.**
- [ ] §3.4(d) canlıda ölçüldü: **token yenilendikten sonra kuyruktaki yazım kaybolmadı.**
- [ ] `WireOp.ActorId` istemciden gönderilse bile **sunucudaki `UserId` kazanıyor** — bunu bir
      **mutant** ısırtıyor (istemci sahte `ActorId` gönderir, test kırmızı yanar).
- [ ] `flutter analyze` 0 · istemci testleri yeşil · backend testleri yeşil · `verify.ps1` EXIT 0.
- [ ] `paket.yml` beş ayak + migrator **hâlâ yeşil** (dev-header kalkanı kırılmadı).
- [ ] Yeni bağımlılık eklendiyse lisans + CVE kapısı yeşil, çıktısı KANIT'ta.
- [ ] `CLAUDE.md` §2'deki *"Hesap aç, giriş yap…"* maddesi `[x]`e döndü.

**Cowork bu ölçütleri BAĞIMSIZ olarak yeniden ölçer** (İŞLEYİŞ md.4). Claude Code'un beyanı
güvenilirdir ama **rastgele bir beyan** bağımsız doğrulanır; tutmazsa dilim %100 doğrulamaya döner.

---

## 5. DOKUNMA LİSTESİ (bu dilimde DEĞİŞMEYECEK)

- ❌ `pubspec.yaml`da `name: client` — bütün `package:client/…` import'ları kırılır.
- ❌ `applicationId` — sabit.
- ❌ `v1.0.0` ve `v1.0.1` etiketleri/varlıkları — arşiv, dokunulmaz.
- ❌ `docker-compose.yml`deki `DEV_USER_ID` sabiti — dilim 3'e kadar demo kimliği olarak kalır.
- ❌ `paket.yml` AYAK 3'ün dev-header sözleşmesi.
- ❌ `dart format lib/` — depo format-temiz değil, **yalnız dokunulan dosyada** koş (sınır 27).
- ❌ Yeni kapı **dosyası** açma (kapı bütçesi %10 ihlalde; İŞLEYİŞ md.3). Normal birim/widget
  testleri orana girmez — onlar üründür, serbestçe yaz.
- ❌ ADR, spec, plan, tasarım belgesi — §0.

---

## 6. DÜŞERSE NE OLACAK

- **Kod düşerse:** iş emri v2 yazılır, **denetim turu açılmaz**. Düşme sebebi tek cümleyle
  `DURUM.md` "bilinen sınırlar"a yazılır (İŞLEYİŞ md.8: bir kez ısırdıysa yeri orasıdır, kural değil).
- **21 Ağu'da dilim bitmediyse:** İŞLEYİŞ md.1 devreye girer — **kutu uzamaz, madde kesilir.**
  Kesme sırası kilitli: **hatırlatıcı → tekrar → proje klasörü.** Kimlik kesilmez; kesilirse
  dilim 3 (işbirliği) de düşer ve ÖDEV §4(b) 1/2'de kalır.
- **Yeni bağımlılık kapısı kırmızı yanarsa:** paket eklenmez, token Drift'te saklanır, web'deki
  zayıflık README §Beyan edilmiş sınırlar'a yazılır. Dilim düşmez.
- **`v1.0.1` her hâlükârda yayında ve çalışıyor.** Bu dilim tamamen düşse bile **teslim edilmiş
  bir ürün duruyor** — planın tamamını düşük riskli yapan tek şey budur.
