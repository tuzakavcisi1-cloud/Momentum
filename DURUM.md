# DURUM.md — Momentum

**BİTTİ: 8/10 · kutu 21 Ağu 2026 · `ci #45` YEŞİL (628/628) · `pages #6` YEŞİL · son ölçüm 15 Ağu 2026, oturum 77. 9. madde (doğal dil) KOD BİTTİ + 676/676 yeşil + 2 bağımsız denetim turu geçti, CANLI ÖLÇÜM BEKLİYOR — commit/push/pages ONUR'DA.**

> Açılış ≤3 komut: ① `git --no-optional-locks log --oneline -1` + `status --porcelain -- src`
> ② bu dosya ③ CI durumu — **cihazdaki Chrome'dan okunur** (bulut tarayıcısı kanıt değildir).
> `arsiv/` AÇILMAZ. **Flutter komutları `src/client`'tan koşulur** (bilinen sınır 1).

## Oturum 74 (özet) — öncelik + son tarih (6/10 → 7/10)

`oncelik`/`sonTarih` (şema v5→v6) · **TAKVİM GÜNÜ PİNİ** (`DateTime.utc(y,m,d)`, tek nokta
`GorevSatiri.takvimGunu`) · `intl` **0.20.2**, kanonik sürüm **`pubspec.lock`**.
**DERS (kanla):** kâğıt denetimi migration'ın **v1 yolunu KOŞAMAZ** — iki denetçi bir çökmeyi buldu
ama `v1→v2` regresyonunu KAÇIRDI; onu `flutter test` yakaladı.

## Oturum 76 — etiket dilimi **CANLI YEŞİL** (7/10 → 8/10)

- **Şema v6→v7 (SALT-EKLEME):** `gorev_etiketleri(gorevId, etiket, addTag, iptalEdildi)`;
  `Gorevler`e DOKUNULMADI ⇒ v1 yolu etkilenmedi. Tel: `sets.tags.{adds,removes}`
  (`el/tag/observed/hlc`), sunucudan ÖLÇÜLDÜ. `sets` kanalı LWW meta'ya ASLA bağlanmaz.
- **Birleştirme:** adds=insertOrIgnore (tombstone kalıcı) · removes=observed başına iptal ⇒
  idempotent + değişmeli. Tombstone TELE ÇIKMAZ ⇒ kuyruktaki yerel tag KORUNUR.
- Canlı tur üç ayak yeşil (cihaz Chrome, 15 Ağu 11:10). İki denetçi / 14 mutant → iki CİDDİ bulgu.

## Oturum 77 — doğal dil dilimi: KOD BİTTİ, canlı ölçüm bekliyor

`yarın 17:00 rapor gönder #iş !p1` → başlık + son tarih + etiket + öncelik. **YENİ ŞEMA YOK** (v7).
Bulutta yazıldı/koşuldu (Flutter 3.44.6): `analyze --fatal-infos` temiz · **676/676** (taban 628) ·
14 dosya cihaza **sha256 ile bayt-bayt** doğrulanarak yazıldı.

- **`lib/sunum/dogal_dil_ayristirici.dart` SAF:** `DateTime.now()` YOK, "bugün" dışarıdan verilir;
  sıfır bağımlılık (tek istisna `etiketDogrula` — kural ikinci kez YAZILMAZ).
- **KİLİTLER (Onur, 15 Ağu):** dağarcık `bugün`/`yarın`/`gg.aa[.yyyy]`/`yyyy-aa-gg` · saat TANINMAZ,
  başlıkta kalır · tekrarda **İLK kazanır** · yalnız küçük harf · yılsız tarih = içinde bulunulan yıl ·
  etiket çoklu + tekilleşir · `#` yalnız token başında · tanınmayan her token BAŞLIKTA KALIR.
- **Yazma yolu:** `ekle()` opsiyonel `oncelik`/`sonTarih`/`etiketler` aldı ⇒ dört alan **TEK `WireOp`
  + TEK `transaction`**. Verilmeyen alan tele HİÇ konmaz; boş `tags` deltası yazılmaz (D2).
- **Ayrıştırma WIDGET'ta** (`GorevEkleAlani`): boş başlık reddi ayrıştırmadan SONRA bakılmalı —
  `#iş` ham metni boş değildir. Ekranda ayrıştırılsaydı alan temizlenir, başlık sessizce düşerdi.
- **41 MUTANT ÖLDÜ, sağkalan YOK.** İlk tur 27 (14 ayrıştırıcı + 13 yazma yolu/kablo). **İKİ
  BAĞIMSIZ DENETÇİ** 14 sağkalan daha buldu; hepsi kapatıldı.
- **DENETİM İKİ ÜRÜN KUSURU ÇIKARDI (ikisi de düzeltildi, elle doğrulandı):**
  (a) `int.parse` 64 biti aşan `!p999…`de `FormatException` fırlatıyordu ⇒ **VM/Android'de ekle
  düğmesi sessizce ölüyordu**, Web (dart2js) AYRI davranıyordu → `int.tryParse`.
  (b) Yıl `0000` kabul ediliyordu; sunucunun `DateTimeOffset` `TryParseExact`i onu `Malformed`a
  atar ⇒ istemci çizer, sunucu düşürür (**sınır ötesi sessiz kayıp**) → `yil < 1` reddi.
- **Kapı yalanları kapatıldı:** yerel `addTag` ↔ tel `tag` çapraz doğrulaması yoktu (ayrışsa
  kuyruk koruması kaçar, etiket sessizce iptal olurdu) · "AYNI transaction" testi transaction'a
  dair tek iddia taşımıyordu (etiket yazımı dışarı taşınınca 667 test yeşildi) · `gg.aa` yılının
  çağıranın `bugün`ünden geldiği pinsizdi · `bugünkü`/`yarınki` yutulabiliyordu · ayraç yalnız
  boşlukla sınanıyordu · basamak kelepçeleri pinsizdi.
- **`simdi` dikişi ORTAM-BAĞIMSIZ kapatıldı:** `.toUtc()` mutantı UTC koşan CI'da davranışla
  ÖLDÜRÜLEMEZ (yerel == UTC); `DateTime`ı `implements` eden sonda dönüştürücü çağrısını yakalar.

## Sıradaki iş

1. **Onur:** commit + push + `pages` workflow_dispatch → sonra **canlı ölçüm**: tek satır yazılır,
   görev doğru alanlarla oluşur, sekme kapanınca durur ⇒ yeşilse **9/10**.
2. Sonra **başlıkta arama** (kutu dolarsa kesilecek İLK madde budur).

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
12. **ÖLÇÜLMEDİ:** diyalog içi dokunma hedefleri a11y kılavuzundan geçirilmedi; `snapshotUygula`
    ayağı yeni alanlar için test edilmedi.
13. **ÖLÇÜLDÜ, TEMİZ:** `kuyrukEnBuyuk`/`hamAlanHlcCikar` alan adı beyaz listesi tutmaz ⇒ D5
    koruması yeni kanalları da kapsıyor.
14. **Etiketlerde BÜYÜK/KÜÇÜK HARF KATLAMASI YOK** (sunucu Ordinal karşılaştırır): `İş` ≠ `iş`;
    Türkçe I/İ katlaması ayrı mayın, kapsam dışı. Sıra KOD-BİRİMİ sırasıdır. 32 karakter sınırı
    YALNIZ İSTEMCİ kelepçesidir; uzaktan gelen daha uzun etiket EZİLMEZ.
16. **[o77] Doğal dil sınırları (bilinçli, kilitli):** `Yarın`/`YARIN` ve ASCII `bugun`/`yarin`
    TANINMAZ · saat (`17:00`) başlıkta kalır, saklanmaz · yılsız `03.01` GEÇMİŞE düşer · `!p01` → 1
    (pinli) · `#İş` ile `#iş` ayrı etikettir.
17. **[o77] `GorevEkleAlani.onEkle` artık `DogalDilSonucu` taşır** (String değil) ve `simdi`
    enjekte edilebilir. **Ekran enjekte ETMEZ** ⇒ ürün yolunda `DateTime.now` koşar; tarih ayağı
    widget testinde pinli saatle, ekran ayağı "bugün" ile iki-aday toleransıyla ölçülür.
18. **[o77] `GorevDeposu.ekle` imzası değişti** (opsiyonel üç alan) ⇒ 8 test sahte deposu güncellendi.
    Yeni bir sahte depo yazan, üç parametreyi de kabul etmek ZORUNDADIR.
19. **[o77 ÖLÇÜLDÜ] `flutter test` `KANIT/slice-3c/02-G2/*.json`i her koşumda YENİDEN YAZAR**
    (yalnız UUID'ler değişir). Bu dört dosya commit'e GİRMEMELİ — `git add` yol belirterek yapılır.
20. **[o77 KARAR BEKLİYOR] Tamamen ayrıştırılan girdide geri bildirim YOK:** `#iş !p1 yarın`
    yazılıp Ekle'ye basılırsa görev oluşmaz, alan korunur ama hata metni yoktur. Önceden yalnız
    BOŞ girdide oluşabilirdi; sınıf genişledi.
21. **[o77] `ekle`nin `sonTarih`i normalize EDİLMEZ** (DB'ye ham, tele `.toUtc()`'lu). Canlı yol
    güvenli (ayrıştırıcı daima `DateTime.utc(y,m,d)` üretir); `ayrintilariGuncelle` ile AYNI sınır.
22. **[o77] CI UTC koşar** ⇒ "gece yarısı" ayakları UTC'de zayıftır; kritik dikiş sondayla kapatıldı.
