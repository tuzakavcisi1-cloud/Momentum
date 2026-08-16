// ODEV.md §4(a) / CLAUDE.md §3 -- "BASLIKTA ARAMA" dilimi.
//
//   baslik "IŞIK yak"  +  sorgu "ışık"  -> ESLESIR
//   baslik "Ödeme"     +  sorgu "odeme" -> ESLESMEZ (aksan KATLANMAZ)
//
// 🔴 SAF ve SIFIR BAGIMLILIK: `flutter` da `drift` de import EDILMEZ
// (`etiket_dogrulama.dart` / `dogal_dil_ayristirici.dart` emsali). Bu dosya
// suzmenin TEK kuralidir; ekran kendi karsilastirmasini YAZMAZ (ayni kural
// iki yerde yazilirsa `kanonik-kopya` dogar -- bu projede bes kez isirdi).
//
// KILITLI KURALLAR (Onur, 15 Agu 2026 -- oturum 77 tasarim kilidi):
//   1. TURKCE-GUVENLI KATLAMA: `'I' -> 'ı'` ve `'İ' -> 'i'` ELLE eslenir.
//      Ham `metin.toLowerCase()` YASAKTIR. IKI AYRI ARIZASI OLCULDU
//      (15 Agu 2026, Dart 3.11 / Flutter 3.44.6):
//        (a) HER IKI PLATFORMDA: `'IŞIK'.toLowerCase()` -> `'işik'`
//            ('ışık' olmaliydi) ⇒ `ışık` yazan `IŞIK`i BULAMAZDI.
//        (b) 🔴 PLATFORMA GORE AYRISIR: `'İ'.toLowerCase()` VM'de `[105]`
//            (tek kod birimi 'i'), dart2js/Node'da `[105, 775]`
//            (i + BIRLESEN NOKTA U+0307). Yani `İ` girisi olmadan arama
//            VM/Android'de CALISIR, WEB'DE (canli demo platformu!) `iş`
//            sorgusu `İş görüşmesi`ni SESSIZCE bulamazdi -- o77'nin
//            `int.parse` arizasiyla AYNI SINIF.
//      DIKIS UYARISI: (b) yuzunden `İ` girisini silen mutant VM testinde
//      DAVRANISLA OLMEZ; `arama_dilimi_test.dart` bu yuzden TABLOYU BIREBIR
//      sinar (o77 dersi: ortami degil DIKISI olc).
//   2. AKSAN KATLANMAZ: `odeme` yazan `Ödeme`yi BULMAZ. Gerekce: etiketlerde
//      hicbir katlama yok (o76 siniri); aramada aksani katlayip buyuk/kucugu
//      katlamak IKI DOKTRIN dogururdu. Katlama YALNIZ buyuk/kucuk harctir.
//   3. ALT DIZE eslesmesi (`contains`), kelime basi degil: `rapor` sorgusu
//      `Aylık rapor` basligini BULUR.
//   4. YALNIZ BASLIKTA aranir (etiket icin cip seridi zaten var).
//   5. BOS SORGU = SUZME YOK: `aramaEslesir` `true` doner. Yalniz bosluktan
//      olusan sorgu da BOS sayilir (kirpilir) -- aksi halde tek bir bosluk
//      tusu, iceriginde bosluk OLMAYAN tek kelimelik basliklari eleyip
//      ekrani bozuk gosterirdi.
//
// SINIR (ÖLÇÜLMEDİ, bilincli): Unicode NORMALIZASYONU yapilmaz. Onceden
// birlesmis `Ö` (U+00D6) ile ayrisik `O`+`◌̈` (U+0308) AYRI dizgelerdir ve
// eslesmezler; metin alanindan gelen girdi pratikte NFC'dir.

/// Turkce'nin `toLowerCase` ile DOGRU katlanamayan iki harfi. Katlama
/// tablosunun TEK KAYNAGI burasidir; ekran ya da test kendi tablosunu
/// KURMAZ.
///
/// Geri kalan her karakter icin `toLowerCase` GUVENLIDIR ve BILEREK
/// kullanilir: elle yazilmis tam bir Unicode kucuk-harf tablosu `Ç/Ğ/Ö/Ş/Ü`
/// disindaki her alfabede (Yunan, Kiril, aksanli Latin) SESSIZCE yanlis
/// calisirdi.
///
/// KAPSAM (OLCULDU 15 Agu 2026 -- 1.112.064 kod noktasi VM ve dart2js'te
/// tek tek tarandi): bu iki giris, `toLowerCase`in **Turkce/Latin icin**
/// yanlis oldugu TUM kumedir -- `U+0000-U+024F` araliginda VM ile web
/// arasinda ayrisan kod noktasi SIFIRDIR. Aralik disinda 465 kod noktasi
/// (Cherokee, Gurcuce Mtavruli, Adlam, Deseret vb.) VM ile web'de FARKLI
/// katlanir; urun dili Turkce oldugu icin bu bilincli bir sinirdir,
/// DURUM.md'ye yazilir.
const Map<String, String> kTurkceKatlamaIstisnalari = {'I': 'ı', 'İ': 'i'};

/// Karsilastirma bicimine katlar. SAF ve `idempotent`
/// (`aramaKatla(aramaKatla(x)) == aramaKatla(x)`).
///
/// `runes` uzerinden yurunur: BMP disi karakter (or. emoji) ikiye BOLUNMEZ.
String aramaKatla(String metin) {
  final tampon = StringBuffer();
  for (final kod in metin.runes) {
    final karakter = String.fromCharCode(kod);
    final istisna = kTurkceKatlamaIstisnalari[karakter];
    tampon.write(istisna ?? karakter.toLowerCase());
  }
  return tampon.toString();
}

/// Turkce-guvenli, aksan-DUYARLI alt dize eslesmesi.
///
/// Bos (ya da yalniz bosluktan olusan) [sorgu] icin `true` -- "suzme yok"
/// hali cagiranda AYRICA kontrol edilmez, kural burada TEK yerdedir.
bool aramaEslesir({required String baslik, required String sorgu}) {
  final kirpilmis = sorgu.trim();
  if (kirpilmis.isEmpty) return true;
  return aramaKatla(baslik).contains(aramaKatla(kirpilmis));
}
