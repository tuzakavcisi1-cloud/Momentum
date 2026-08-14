# DURUM.md — Momentum

**BİTTİ: 5/10 · kutu 21 Ağu 2026 · son ölçüm 14 Ağu 2026 13:52 TSİ (oturum 73) · HEAD `a2971aa`**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ test durumu (CI'dan ya da `C:\src\flutter\bin\flutter.bat test`).
> Başka açılış ritüeli yok. `arsiv/` AÇILMAZ.

## Ne yapıldı (oturum 73 · 14 Ağu 2026)

- Açılış yeni usulle koştu. Ölçüldü: HEAD `a2971aa`, `.git/index.lock` yok,
  `user.email` = `onurkesimbjk@gmail.com`.
- **Sil turu çalışma ağacında bulundu, commit'lenmemiş:** `metinler.dart` ·
  `gorev_listesi_ekrani.dart` · `gorev_satiri.dart` · `g14_dikey_donus_kapisi_test.dart` (M) +
  `gorev_satiri_silme_test.dart` (yeni).
- `docs/ODEV.md` okundu ve **BİTTİ listesi onun §4 kapsam kilidinden türetildi** (devirdeki taslak
  ODEV'den türetilmemişti, var olanın tarifiydi). Ölçülen boşluk: backend `TaskProjection`
  **12 alan** materyalize ediyor, istemci Drift tablosu **7 kolon** taşıyor, arayüzde **2** görünüyor.
- Onur kilitledi: **ORTA kapsam** · kutu **21 Ağu 2026** · araclar ayrılır, `KANIT/` yerinde kalır.
- Eski canlı defterler `arsiv/`'e taşındı — **70 dosya, hepsi `R100` (saf yeniden adlandırma,
  içerik değişmedi), hiçbir şey silinmedi:** sekizli + eski `CLAUDE.md`/`DURUM.md` +
  `PROJE-ESASLARI-SABLON.md` + `_SILINECEKLER/`.
- `araclar/` **ayrıldı**: 26 oturum-aparatı `arsiv/araclar/`'a indi; CI'nın çağırdığı `verify.ps1`
  ve bağımlılık/yayın araçları kökte kaldı ⇒ `verify.ps1`'in `$repoRoot`'u bozulmadı,
  **backend CI kırılmadı** (ölçüldü: `ci.yml` yalnız `./araclar/verify.ps1` çağırıyor).
- Yeni tek sayfa `CLAUDE.md` + `DURUM.md` yazıldı.

## Sıradaki iş

1. **Commit + push (Onur ya da Claude Code'da):** indekste bekleyen 70 yeniden adlandırma + yeni
   `CLAUDE.md`/`DURUM.md` + sil turunun 5 dosyası. Mount'tan commit yasak, bu yüzden bekliyor.
2. **Ölç:** `flutter analyze --fatal-infos` = 0 · `flutter test` sayısı (o71 tabanı 549).
   Push edilince `ci.yml` ikisini de kendisi koşar.
3. **Sil dilimini teslim sınırında TEK turda denetle** — canlı çıktıda: gerçek tarayıcıda dört
   eylem (ekle/düzenle/tamamla/sil) · `gorev_satiri.dart`'ın `_dikeyMi()` sabitler toplamına
   `onSil` terimi eklendi mi (eklenmemişse ölçülen düzen ile çizilen düzen **sessizce ayrışır**) ·
   üç mutant ısırır. Sonra README'den *"silme arayüzde yok"* beyanı kalkar.
4. **Dilim: öncelik + son tarih** (`CLAUDE.md` §3).

## Bilinen sınırlar

1. **Sil turu denetlenmedi.** Claude Code bitirdiğini beyan etti; Cowork **ölçmedi**. En kritik
   kalem `_dikeyMi()` sabitler terimi (yukarıda).
2. **Test sayısı ÖLÇÜLEMEDİ.** Bu oturumda Windows kabuğu yoktu: Desktop Commander bağlı değil,
   `device_bash`'in Linux VM'inde `flutter`/`dart` yok (`which` boş döndü). Yeşil varsayılmadı.
3. **Push durumu ÖLÇÜLEMEDİ** (o72'den devrediyor) — cihaz VM'inde `git fetch` HTTP 403 (proxy),
   buluttan GitHub API kapalı. Tek komutla kapanır:
   `git fetch origin && git rev-list --left-right --count origin/main...HEAD`.
4. **README bayat, teslim sınırında tazelenecek:** *"silme arayüzde yok"* beyanı duruyor
   (satır 93 ve 291) · `PROJE_HAFIZA.md`/`BORCLAR.md`/`ORTAM.md` atıfları (satır 76, 229-230) artık
   `arsiv/` altına işaret ediyor · borç sayımı (satır 262-267) yeni usulde geçersiz ·
   `araclar/` atıfları (satır 74, 220, 269) ayrılmadan önceki hâli anlatıyor.
5. **Kapı bütçesi hâlâ ihlal.** `KANIT/` yerinde: 24 MB, README'de *"1.316 izlenen dosya"*.
   Taşınamaz çünkü README'de **9**, `docs/ADR/*`'da **~20** canlı bağlantı ona çıpalı — Onur'un
   ölçülmüş kararı: teslimi kırmamak bütçeyi kapatmaktan önce gelir.
6. **Kimlik `devUserId` ile taşınıyor**, `WireOp.ActorId` istemci-beyanlı ⇒ gerçek zamanlı
   işbirliği iki **gerçek** kullanıcıyla gösterilemez (kapsam dışı yazıldı).
7. **`docs/ADR/0003` kilitli değil** (dosya adı `...-v7-YAZIM-DEVAM-EDIYOR.md`). Yeni usulde kâğıt
   denetlenmez ⇒ **teslimi bloke etmez**, ama kilitsiz olduğu README'de beyan edilir.
8. **Devirden düşen kalem:** `KIMLIKLER.md` D1 kimlik tazeleme bulgusu, belge `arsiv/`'e indiği ve
   kimlik defteri tutulmadığı için **kendiliğinden kapandı** (o72'de Onur'un öngördüğü koşul gerçekleşti).
