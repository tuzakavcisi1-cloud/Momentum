# Momentum — PROJE ESASLARI (CLAUDE.md)
`MOD: NORMAL`

> Bu dosya ≤ 8 KB kalır ve projenin **TEK talimat dosyasıdır**; yanında tek `DURUM.md` yaşar
> (≤ 8 KB, yerinde güncellenir: ne yapıldı · sıradaki iş · bilinen sınırlar).
> `arsiv/` append-only tarihçedir ve **AÇILIŞTA OKUNMAZ**: oradaki eski defterlerin hükmü
> **kalkmıştır** — yalnız *"bu karar neden alındı?"* diye sorulunca açılır. Yeni canlı defter AÇILMAZ.
> Bu iki dosya için kapı, mutant, altın küme yazılmaz; gözle denetlenir.

## 1. NE

Çok platformlu görev yönetimi (to-do): **Flutter** (Web + Android canlı, iOS yalnız CI'da derlenir
— Mac yok) + **N-katmanlı .NET/ASP.NET Core** + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak
mimari ve kod kalitesi. Kapsam otoritesi **`docs/ODEV.md`**. Canlı demo README'de.

## 2. BİTTİ LİSTESİ (kutu **21 Ağu 2026** · sayaç DURUM.md ilk satırı)

- [x] Kullanıcı görev ekler, başlığını düzenler, tamamlandı olarak işaretler
- [x] Kullanıcı görevi siler (onay sorarak) — *canlı 14 Ağu*
- [x] Kullanıcı göreve **öncelik** ve **son tarih** verir, ikisini de listede görür — *canlı 14 Ağu*
- [x] Kullanıcı göreve **etiket** ekler ve etikete göre süzer — *canlı 15 Ağu*
- [ ] Kullanıcı görevlerini **başlıkta arar**
- [x] Kullanıcı görevi **tek satır doğal dille** ekler — *canlı 15 Ağu*
- [x] Uygulama internetsiz çalışır, veri kalıcıdır, bağlantı gelince kendiliğinden eşitlenir
- [x] İki cihaz aynı görevi değiştirince kullanıcı çakışmayı görür ve hangi değerin kazandığını anlar
- [x] Değerlendirici uygulamayı canlı adresten açar; tema sistemin açık/karanlık ayarına uyar
- [x] Değerlendirici depoyu klonlar, README'deki komutla testleri koşar ve yeşil görür

*Bu listede yasak: spec/ADR/kapı/mutant/borç. Madde eklemek §5'e kesme yazmadan olmaz.*

## 3. SIRADAKİ İŞ (tek dikey dilim)

**Başlıkta arama** — SON madde; kutu dolarsa kesilecek ilk madde budur.
**KİLİTLİ [Onur, 15 Ağu]:** alan **çip şeridinin ÜSTÜNDE** · eşleştirme **Türkçe-güvenli katlama**
(`I→ı`, `İ→i` ELLE; `toLowerCase` YASAK, aksan katlanmaz) · **her tuşta canlı** · boş sonuçta
**"Eşleşen görev yok."** + süzgeçleri temizle · arama ile çip **ÇARPILIR** · sekme kapanınca
sıfırlanır · **yeni şema/tel YOK** (süzme Dart tarafında, aynı stream).
**Bitti ölçütü (canlı):** arama yazılır liste daralır, alan temizlenince geri gelir; etiket
çipiyle birlikte ikisi birden uygulanır.

## 4. ORTAM MAYINLARI (yalnız ÖLÇÜLMÜŞ)

1. **git okuma:** `--no-optional-locks` zorunlu. Mount'ta tüm-ağaç `status`/`diff` 45 sn tavanını
   aşar (EXIT 124) ve `.git/index.lock` bırakır ⇒ **dar komut** (`log --oneline -1` ·
   `status --porcelain -- <yol>` · `diff --cached --name-status`) ve **her turun sonunda kilidi
   yokla**; sandbox silemez, `mv` ile kaldırılır.
2. **git yazma:** `git add -A` **YASAK** (başka elin commit'lenmemiş işini kör alır) → yol belirt.
   Commit mesajına **çift tırnak yazma**. **Mount'tan commit YASAK** — Desktop Commander ya da
   Claude Code'dan yapılır. **PUSH ONUR'DA.** Author e-postası `onurkesimbjk@gmail.com`.
3. **flutter `.bat`'tir** → tam yol `C:\src\flutter\bin\flutter.bat` (subprocess PATHEXT'i çözmez).
   DC kabuğunda `flutter test` `PROGRAMFILES(X86)` enjekte edilmeden çöker. `--platform chrome`
   bu ortamda sonuç üretmiyor.
4. **Kodlama:** yol **saf ASCII** kalmalı (Türkçe karakter `build_runner`, `flutter analyze`, AGP ve
   `.ps1` zincirlerini kırdı). `python` stdout cp1254 ⇒ `sys.stdout.reconfigure(encoding="utf-8")`.
5. **Satır sonu / geri alım:** `* text=auto eol=lf` `core.autocrlf`'i **ezer**. Mount'ta
   `git restore`/`checkout --` **ÇALIŞMAZ** (unlink denenir) → `git show HEAD:<yol> > <yol>`;
   `git apply` çalışır ama sonuç **sha256 ile** doğrulanır.
6. **`verify.ps1`, `Momentum.Api` ayaktayken koşulamaz** (MSB3026/3027) ⇒ sıra: cihaz kanıtı →
   backend kapatılır (`netstat -ano | findstr :5298` **boş** dönerek ölçülür) → `verify.ps1`.
   Kapatmayı yalnız Onur'un açık izniyle yap, yeniden başlatma.
7. **Backend:** `ConnectionStrings__Momentum` verilmezse host **DB'siz** açılır, port **yine dinler**
   ⇒ hazırlık portla ölçülmez: `/health/ready` 200 + `POST /v1/sync` başlıksız 401 ve
   `X-Momentum-Dev-User` ile 200. `ASPNETCORE_ENVIRONMENT=Development` yoksa her istek 401.
8. **Mount'ta `os.remove`/`unlink` YASAK** (sandbox silemez) → artık dosya
   `arsiv/_SILINECEKLER/<oturum>/`'e `mv` edilir; kalıcı silme Onur'da.
9. **Bulut ≠ cihaz:** Cowork bulutta UTC koşar ⇒ tarih `TZ='Europe/Istanbul' date` ile ölçülür;
   **CI `istemci` işi de `TZ: Europe/Istanbul` koşar** [o77]. `device_stage_files` bulut kopyasına
   **bugünün** mtime'ını yazar. Bulut tarayıcısı canlı kanıt **değildir**.
10. **Kapı bütçesi (İŞLEYİŞ md.3):** `araclar/` ÷ `src/` satır oranı ≤ %10; `src/**/test/` **girmez**
    (onlar üründür). Kökte kalan 11 dosya: `verify.ps1` (CI) · `pub-*`/`lisans-*` (bağımlılık) ·
    `web-*`/`yayin-*` (yayın). Yeni kapı dosyası açılmaz.

## 5. KAPSAM DIŞI (kesilenler — README'ye de yazılır)

- **`docs/ODEV.md` §4(a)'dan kesildi:** liste · proje · tekrar (RRULE) · hatırlatıcı.
- **§4(b)2 işbirliği vitrini:** sinyal kanalı kodda var, **çok kullanıcılı paylaşım/davet akışı yok**.
- **§6.1 kimlik/oturum:** giriş ekranı yok; istemci `devUserId` taşır, `WireOp.ActorId` istemci-beyanlı.
- **§8(4):** tek komutla ayağa kaldırma yok (`Dockerfile` yok; compose yalnız `postgres`).
- **[o77 kesildi]** Ayrıştırma her şeyi yutunca (`#iş !p1 yarın`) hata metni YOK: metin alanda
  kalır. Sessiz kayıp yok, geri bildirim de yok.
- **Zaten kapsam dışı (§4.1/§6.1):** AI asistan · Google Takvim · Kanban/Takvim · iOS cihaz testi ·
  parola sıfırlama · e-posta doğrulama · OAuth · 2FA · RBAC.

---

## İŞLEYİŞ (v2 — TESLİM KURALLARI'nın halefi; değişmez blok)

1. **Takvim kutusu:** her maddeye gün verilir; kutu dolarsa MADDE kesilir, süre uzamaz; kesilen §5'e ve README'ye yazılır. Kalan madde > kalan gün ise hemen kes.
2. **Dikey dilim pazarlıksız** (§3'teki tanım). Dilim sonunda çalışan üründe elle tek doğrulama.
3. **Kapı bütçesi %10:** projeye özel denetim/araç kodu, ürün kodunun %10'unu geçemez (normal birim/widget testleri orana girmez — onlar üründür). Ölçüm tek satırdır, bu dosyanın §4'üne yazılır ve CI'da koşar; ölçüm için ayrı araç dosyası açılmaz. Aşımda yeni kapı yazılmaz: ya kapı silinir ya kural tek cümleye döner.
4. **Kâğıt denetim turu = 0.** Spec/ADR/plan/iş emri denetlenmez; denetim yalnız koşan artefakta. "Üreten ≠ denetleyen" TESLİMDE uygulanır: kullanıcıya değen her teslimde TEK bağımsız tur, CANLI çıktıya bakılır (`MOD: KRİTİK` ise 2 tur). Ajan beyanları güvenilirdir; teslim başına rastgele 1 beyan doğrulanır — sonucu DURUM.md "bilinen sınırlar"a tek cümle yazılır; tutmazsa o dilim %100 doğrulamaya döner. Ayrı sicil defteri açılmaz.
5. **Açılış ≤3 komut:** git durumu · DURUM.md · test durumu. Kapılar CI'da koşar, oturumda değil.
6. **Borç defteri tutulmaz.** Üç seçenek: ŞİMDİ YAP · KAPSAMDAN KES (§5 + README) · SİL.
7. **Tek vitrin.** İkinci "vay" birincinin bitişini geciktirir; diğerleri §5'e.
8. **Kural yaşam döngüsü:** kalıcı kural ancak aynı sınıf İKİ kez ısırınca doğar; ya CI'da mekanik koşar ya tek cümledir; §4'e girer ve girerken bir satır silinir. Kurallar birbirine kimlik numarasıyla atıf veremez. Olay bir kez ısırdıysa yeri DURUM.md "bilinen sınırlar"dır, kural değil.
9. **Haftalık tek soru:** "Bu hafta bitti listesinde kaç madde ✅'ye döndü?" Cevap 0 ise o hafta yapılan her şey gözden geçirilir.
10. **Taban:** bu dosya için kapı/mutant/altın küme/denetim turu yazılmaz. Çelişki çıkarsa öncelik: MUTLAK SINIRLAR > global anayasa > bu dosya > diğer her şey.
