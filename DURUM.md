# DURUM.md — Momentum

**BİTTİ: 9/10 · kutu 21 Ağu 2026 · HEAD `ecd2787` · `ci #47` YEŞİL (676/676) · `pages #7` YEŞİL · doğal dil dilimi CANLI DOĞRULANDI (cihaz Chrome, 15 Ağu 2026 13:44 TSİ). Kalan tek madde: başlıkta arama.**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihazdaki Chrome'dan okunur** (bulut tarayıcısı kanıt değildir).
> `arsiv/` AÇILMAZ. **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Oturum 74 · 76 (özet) — öncelik/son tarih (v5→v6) ve etiket (v6→v7) dilimleri

**TAKVİM GÜNÜ PİNİ:** `DateTime.utc(y,m,d)`, tek nokta `GorevSatiri.takvimGunu`. `intl` **0.20.2**
(kanonik sürüm **`pubspec.lock`**). **Etiket:** `gorev_etiketleri(gorevId, etiket, addTag,
iptalEdildi)` SALT-EKLEME, `Gorevler`e dokunulmadı ⇒ v1 yolu etkilenmedi. Tel
`sets.tags.{adds,removes}` sunucudan ÖLÇÜLDÜ; `sets` LWW meta'ya ASLA bağlanmaz.
adds=insertOrIgnore (tombstone kalıcı) · removes=observed başına iptal ⇒ idempotent + değişmeli.
Tombstone TELE ÇIKMAZ ⇒ kuyruktaki yerel tag KORUNUR.
**DERS (kanla, o74):** kâğıt denetimi migration'ın **v1 yolunu KOŞAMAZ** — iki denetçi bir çökmeyi
buldu ama `v1→v2` regresyonunu KAÇIRDI; onu `flutter test` yakaladı.

## Oturum 77 — doğal dil dilimi **CANLI YEŞİL** (8/10 → 9/10)

`yarın 17:00 rapor gönder #iş !p1` → başlık + son tarih + etiket + öncelik. **YENİ ŞEMA YOK** (v7).
Bulutta yazıldı/koşuldu (Flutter 3.44.6): `analyze --fatal-infos` temiz · **676/676** (taban 628) ·
14 dosya cihaza **sha256 ile bayt-bayt** doğrulanarak yazıldı.

- **`lib/sunum/dogal_dil_ayristirici.dart` SAF:** `DateTime.now()` YOK, "bugün" dışarıdan verilir;
  sıfır bağımlılık (tek istisna `etiketDogrula` — kural ikinci kez YAZILMAZ).
  Sekiz kilitli kural (Onur, 15 Ağu) o dosyanın başlığındadır — kanonik yer ORASIDIR.
- **Yazma yolu:** `ekle()` opsiyonel `oncelik`/`sonTarih`/`etiketler` aldı ⇒ dört alan **TEK `WireOp`
  + TEK `transaction`**. Verilmeyen alan tele HİÇ konmaz; boş `tags` deltası yazılmaz (D2).
- **Ayrıştırma WIDGET'ta** (`GorevEkleAlani`): boş başlık reddi ayrıştırmadan SONRA bakılmalı —
  `#iş` ham metni boş değildir. Ekranda ayrıştırılsaydı alan temizlenir, başlık sessizce düşerdi.
- **41 MUTANT ÖLDÜ, sağkalan YOK.** İlk tur 27 (14 ayrıştırıcı + 13 yazma yolu/kablo). **İKİ
  BAĞIMSIZ DENETÇİ** 14 sağkalan daha buldu; hepsi kapatıldı.
- **DENETİM İKİ ÜRÜN KUSURU ÇIKARDI (düzeltildi, elle doğrulandı):** (a) `int.parse` 64 biti aşan
  `!p999…`de fırlatıyordu ⇒ VM/Android'de ekle düğmesi sessizce ölüyor, Web AYRI davranıyordu →
  `int.tryParse`. (b) Yıl `0000` geçiyordu; sunucu `TryParseExact`i onu `Malformed`a atar ⇒
  istemci çizer, sunucu düşürür (**sınır ötesi sessiz kayıp**) → `yil < 1` reddi.
- **En pahalı iki kapı yalanı:** yerel `addTag` ↔ tel `tag` çapraz doğrulanmıyordu (ayrışsa kuyruk
  koruması kaçar, etiket sessizce iptal olurdu) · "AYNI transaction" testi transaction'a dair tek
  iddia taşımıyordu — etiket yazımı dışarı taşınınca **667 test yeşil kalıyordu**.
- **DERS:** `.toUtc()` mutantı UTC koşan CI'da DAVRANIŞLA öldürülemez (yerel == UTC). Çözüm ortamı
  değil DİKİŞİ ölçmektir: `DateTime`ı `implements` eden sonda dönüştürücü çağrısını yakalar.

## Canlı tur (cihaz Chrome, Pages demosu, 15 Ağu 2026 13:44 TSİ — COWORK KOŞTU)

**Üç ayak da yeşil.** (1) Regresyon: dört eski görev + `Tümü`/`iş` şeridi yerinde. (2) Tek satır
`yarın 17:00 rapor gönder #iş !p1` → satır **"17:00 rapor gönder"**, meta **"Yüksek · 16 Ağu 2026 ·
#iş"**, alan temizlendi. (3) **Sekme KAPATILIP yeniden açıldı** — satır ve dört alan DURDU.
Rozet `Gönderiliyor → Çevrimdışı` (bilinen sınır 6).

## Sıradaki iş

**Başlıkta arama** — son madde; kutu dolarsa kesilecek İLK madde budur. Eşleştirme kuralı (harf
katlaması, Türkçe I/İ) kod yazılmadan ŞIKLARLA kilitlenir.

## Bilinen sınırlar

1. 🔴 **Flutter komutu repo kökünden koşulursa yalan söyler.** Doğru dizin `src/client`.
   PowerShell 5.1'de `&&` yok, `;` yaz.
2. **Canlı ölçümde tıklama tuzağı:** hover'sız sentetik tıklama çalışmaz; hover'lı tıklama bile bazen
   İKİ kez gerekir (ilki yalnız ODAK verir); diyalogdaki `İptal` tetiklenmez, modalı **Escape** kapatır.
3. **Kapı bütçesi ihlali**; teslimi kırmamak bütçeyi kapatmaktan önce gelir.
4. **Kimlik `devUserId` ile taşınıyor** ⇒ gerçek zamanlı işbirliği gösterilemez (kapsam dışı).
5. **`docs/ADR/0003` kilitli değil** — kâğıt denetlenmez, teslimi bloke etmez.
6. **Pages demosunda backend yok** ⇒ rozetler "Bu cihazda → Gönderiliyor → Çevrimdışı"ya düşer;
   üç ayaklı ölçütlerin "ikinci istemciye eşitlenir" ayağı Pages'te ASLA ölçülemez.
7. **Mount'a yazmanın tek yolu YERİNDE yazmaktır** (`unzip -o`/`mv` "Operation not permitted").
   **[o77 ÖLÇÜLDÜ]** `device_commit_files` mount'a YAZAR ve sha256 birebir tutar (15/15).
8. **`pub cache` boşalabiliyor** (`flutter pub get` çözer); `--delete-conflicting-outputs` kaldırıldı.
9. **Öncelik/son tarih/etiket için ÇAKIŞMA TESPİTİ kapsam dışı:** `kanonikDize` yalnız
   `fields:title` + `groups:completion` tanır. Uzak yolda `DateTime.tryParse` sunucunun
   `TryParseExact`inden müsamahakârdır. **Bilinmeyen `priority`** çizilmez ama EZİLMEZ.
12. **ÖLÇÜLMEDİ:** diyalog içi dokunma hedefleri a11y kılavuzundan geçmedi; `snapshotUygula` yeni
    alanlar için test edilmedi. **ÖLÇÜLDÜ, TEMİZ:** `kuyrukEnBuyuk`/`hamAlanHlcCikar` alan adı
    beyaz listesi tutmaz ⇒ D5 koruması yeni kanalları da kapsıyor.
14. **Etiketlerde BÜYÜK/KÜÇÜK HARF KATLAMASI YOK** (sunucu Ordinal karşılaştırır): `İş` ≠ `iş`;
    Türkçe I/İ katlaması ayrı mayın, kapsam dışı. Sıra KOD-BİRİMİ sırasıdır. 32 karakter sınırı
    YALNIZ İSTEMCİ kelepçesidir; uzaktan gelen daha uzun etiket EZİLMEZ.
16. **[o77] Doğal dil sınırları (bilinçli, kilitli):** `Yarın`/`YARIN` ve ASCII `bugun`/`yarin`
    TANINMAZ · saat (`17:00`) başlıkta kalır, saklanmaz · yılsız `03.01` GEÇMİŞE düşer · `!p01` → 1
    (pinli) · `#İş` ile `#iş` ayrı etikettir.
17. **[o77] `GorevEkleAlani.onEkle` artık `DogalDilSonucu` taşır** (String değil); `simdi` enjekte
    edilebilir ama **EKRAN enjekte ETMEZ** ⇒ ürün yolunda `DateTime.now` koşar.
18. **[o77] `GorevDeposu.ekle` imzası değişti** (opsiyonel üç alan) ⇒ 8 test sahte deposu güncellendi.
    Yeni bir sahte depo yazan, üç parametreyi de kabul etmek ZORUNDADIR.
19. **[o77 ÖLÇÜLDÜ] `flutter test` `KANIT/slice-3c/02-G2/*.json`i her koşumda YENİDEN YAZAR**
    (yalnız UUID'ler değişir). Bu dört dosya commit'e GİRMEMELİ — `git add` yol belirterek yapılır.
20. **[o77 KARAR BEKLİYOR] Tamamen ayrıştırılan girdide geri bildirim YOK:** `#iş !p1 yarın`
    yazılıp Ekle'ye basılırsa görev oluşmaz, alan korunur ama hata metni yoktur. Önceden yalnız
    BOŞ girdide oluşabilirdi; sınıf genişledi.
21. **[o77] CI UTC koşar** ⇒ "gece yarısı" ayakları UTC'de zayıf; kritik dikiş sondayla kapatıldı.
    `ekle`nin `sonTarih`i normalize EDİLMEZ (`ayrintilariGuncelle` ile AYNI sınır; canlı yol
    güvenli, ayrıştırıcı daima `DateTime.utc(y,m,d)` üretir).
22. 🔴 **[o77 ÖLÇÜLDÜ] Canlı turda Ctrl+Shift+R YAPMA.** Hard reload drift'in SharedWorker'ını
    öldürüyor ve yeniden kurulamıyor: `drift_worker.js` isteği `pending` asılı kalıyor (aynı URL
    `fetch` ile 200 dönerken). `main()` `runApp`tan ÖNCE DB açılışını beklediği için **ekran
    bomboş** kalır ve **konsolda hata olmaz**. Çözüm ÖLÇÜLDÜ: Chrome'u tamamen kapat–aç.
    Ek tuzak: CanvasKit canvas'ı `flt-glass-pane`in SHADOW ROOT'undadır ⇒
    `querySelectorAll('canvas')` onu GÖREMEZ; "kare çizilmedi" tanısı yanlış çıkar.
