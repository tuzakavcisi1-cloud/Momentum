# Momentum — PROJE ESASLARI (CLAUDE.md)
`MOD: NORMAL`

> Bu dosya ≤ 8 KB ve projenin **TEK talimat dosyasıdır**; yanında tek `DURUM.md` yaşar (≤ 8 KB,
> yerinde güncellenir). `arsiv/` append-only tarihçedir, **AÇILIŞTA OKUNMAZ**; hükmü kalkmıştır,
> yalnız *"bu karar neden alındı?"* diye sorulunca açılır. Yeni canlı defter AÇILMAZ. Bu iki
> dosya için kapı/mutant/altın küme yazılmaz; gözle denetlenir.

## 1. NE

Çok platformlu görev yönetimi (to-do): **Flutter** (Web + Android canlı, iOS yalnız CI'da derlenir
— Mac yok) + **N-katmanlı .NET/ASP.NET Core** + **PostgreSQL**. İşe-alım/portfolyo ödevi; odak
mimari ve kod kalitesi. Kapsam otoritesi **`docs/ODEV.md`**. Canlı demo README'de.
**İŞ BÖLÜMÜ [Onur, 16 Ağu]:** ürün kodunu **Claude Code** yazar; Cowork tasarım · iş emri ·
denetim · orkestrasyon · hafıza yapar, kod yazmaz.

## 2. BİTTİ LİSTESİ (kutu **2 Eyl 2026** · sayaç DURUM.md ilk satırı · tarihler DURUM'da)

- [x] Görev ekle · başlığını düzenle · tamamla
- [x] Görevi sil (onay sorarak)
- [x] Göreve **öncelik** ve **son tarih** ver, ikisini de listede gör
- [x] Göreve **etiket** ekle ve etikete göre **süz**
- [x] Görevleri **başlıkta ara**
- [x] Görevi **tek satır doğal dille** ekle
- [x] İnternetsiz çalış, veri kalıcı, bağlantı gelince kendiliğinden eşitle
- [x] İki cihaz aynı görevi değiştirince **çakışma görünür**, kazanan anlaşılır
- [x] Canlı adresten açılır; tema sistemin **açık/karanlık** ayarına uyar
- [x] Depo klonlanır, README'deki komutla testler **yeşil** koşar
- [x] **Hesap aç, giriş yap;** kendi görevlerini gör, başkasınınkini görme — *18-21 Ağu*
- [ ] Görevleri **listelere** ayır, listeleri **klasörde** topla, görevi listeye taşı — *22-23 Ağu*
- [ ] **İki kullanıcı bir listeyi paylaşır;** birinin yazdığı ötekinin ekranında belirir — *24-27 Ağu*
- [ ] Göreve **tekrar** ver; tamamlayınca sonraki örnek doğar — *28-29 Ağu*
- [ ] Göreve **hatırlatıcı** kur; zamanı gelince bildirim düşer — *30 Ağu-1 Eyl · İLK KESİLECEK*

*Bu listede yasak: spec/ADR/kapı/mutant/borç. Madde eklemek §5'e kesme yazmadan olmaz.*

## 3. SIRADAKİ İŞ (tek dikey dilim)

**DİLİM 1 — KİMLİK** (18-21 Ağu). `users` + kayıt/giriş uçları + JWT erişim ve **yenileme**
token'ı · `ICurrentUser` token'dan okur · **`WireOp.ActorId` sunucuda doğrulanmış `UserId`'den
yazılır** · Flutter giriş ekranı · 401'de sessiz yenileme · yenileme düşerse **kuyruk korunarak**
giriş ekranına dönüş. İş emri: `IS-EMRI-o83-kimlik.md`.
🔴 **ADR/spec YAZILMAZ** (İŞLEYİŞ md.4): bu dilimi bir kez **altı kâğıt kapı turu öldürdü, 30 gün**
(ÖDEV §6.1 errata). Sonra liste → işbirliği → tekrar → hatırlatıcı; kutu dolarsa kesme sırası
**hatırlatıcı → tekrar → proje klasörü** [Onur kilidi, 18 Ağu].

## 4. ORTAM MAYINLARI (yalnız ÖLÇÜLMÜŞ)

1. **git okuma:** `--no-optional-locks` zorunlu; mount'ta tüm-ağaç `status`/`diff` 45 sn tavanını
   aşar (EXIT 124) ve `.git/index.lock` bırakır ⇒ **daima dar yol ver**, her turun sonunda
   **kilidi yokla** (sandbox silemez, `mv` ile kaldırılır).
2. **git yazma:** `git add -A` **YASAK** (başka elin commit'lenmemiş işini kör alır) → yol belirt.
   Commit mesajına **çift tırnak yazma**. **Mount'tan commit YASAK** — Desktop Commander ya da
   Claude Code'dan yapılır. **PUSH ONUR'DA.** Author e-postası `onurkesimbjk@gmail.com`.
3. **flutter `.bat`'tir** → tam yol `C:\src\flutter\bin\flutter.bat` (subprocess PATHEXT'i çözmez).
   DC kabuğunda `flutter test` `PROGRAMFILES(X86)` enjekte edilmeden çöker; `--platform chrome`
   bu ortamda sonuç üretmez.
4. **Kodlama:** yol **saf ASCII** kalmalı (Türkçe karakter `build_runner`, `flutter analyze`, AGP ve
   `.ps1` zincirlerini kırdı). `python` stdout cp1254 ⇒ `sys.stdout.reconfigure(encoding="utf-8")`.
5. **Geri alım:** `* text=auto eol=lf` `core.autocrlf`'i **ezer**. Mount'ta `git restore`/
   `checkout --` **ÇALIŞMAZ** → `git show HEAD:<yol> > <yol>`; sonuç **sha256 ile** doğrulanır.
6. **`verify.ps1`, `Momentum.Api` ayaktayken koşulamaz** (MSB3026/3027) ⇒ sıra: cihaz kanıtı →
   backend kapat (`netstat -ano | findstr :5298` **boş** dönmeli) → `verify.ps1`. Kapatmayı
   yalnız Onur'un izniyle yap.
7. **Backend:** `ConnectionStrings__Momentum` verilmezse host **DB'siz** açılır, port **yine dinler**
   ⇒ hazırlık portla ölçülmez: `/health/ready` 200 + `POST /v1/sync` başlıksız 401 ve
   `X-Momentum-Dev-User` ile 200. `ASPNETCORE_ENVIRONMENT=Development` yoksa her istek 401.
8. **Mount'ta `os.remove`/`unlink` YASAK** (sandbox silemez) → artık dosya
   `arsiv/_SILINECEKLER/<oturum>/`'e `mv` edilir; kalıcı silme Onur'da.
9. **Bulut ≠ cihaz:** Cowork bulutta UTC koşar ⇒ tarih `TZ='Europe/Istanbul' date` ile ölçülür;
   **CI `istemci` işi de `TZ: Europe/Istanbul` koşar** [o77]. Bulut tarayıcısı canlı kanıt DEĞİLDİR.
10. **Kapı bütçesi (İŞLEYİŞ md.3):** `araclar/` ÷ `src/` satır oranı ≤ %10; `src/**/test/` girmez
    (onlar üründür). Yeni kapı dosyası açılmaz.

## 5. KAPSAM DIŞI (kesilenler — README'ye de yazılır)

- **[18 Ağu GERİ ALINDI]** liste · proje · tekrar · hatırlatıcı · işbirliği vitrini · kimlik
  **§2'ye taşındı**, kutu 2 Eyl'e uzadı [Onur kilidi]. `v1.0.1` bunlar kesikken teslim edildi;
  yeni teslim `v1.1.0`.
- **Windows masaüstü hedefi yok** [Onur, 16 Ağu]: `src/client/` yalnız `android`/`ios`/`web`
  taşır. Windows'ta uygulama **tarayıcıdan** çalışır (imajdaki web istemcisi).
- **[o77 kesildi]** Ayrıştırma her şeyi yutunca (`#iş !p1 yarın`) hata metni YOK: metin alanda
  kalır. Sessiz kayıp yok, geri bildirim de yok.
- **Zaten kapsam dışı (ODEV §4.1/§6.1):** AI asistan · Google Takvim · Kanban/Takvim · iOS cihaz ·
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
