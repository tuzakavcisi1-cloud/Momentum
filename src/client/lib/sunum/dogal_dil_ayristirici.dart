// ODEV.md §4(a) / CLAUDE.md §3 -- "DOGAL DILLE TEK SATIR EKLEME" dilimi.
//
//   `yarın 17:00 rapor gönder #iş !p1`
//     -> baslik  : "17:00 rapor gönder"
//        sonTarih: yarin (TAKVIM GUNU, UTC gece yarisi)
//        etiket  : {"iş"}
//        oncelik : 1
//
// 🔴 SAF ve DETERMINISTIK: bu dosyada `DateTime.now()` YOKTUR -- "bugun"
// DISARIDAN verilir. Bir ayristiricinin kendi saatini okumasi, ayni girdinin
// iki kosumda iki farkli sonuc vermesi demektir; property testi de mutant
// kapisi da o an ANLAMSIZLASIR.
//
// 🔴 SIFIR BAGIMLILIK: `flutter` da `drift` de import EDILMEZ (`etiket_
// dogrulama.dart` emsali). Tek istisna AYNI katmandaki `etiketDogrula` --
// etiket kurali IKINCI KEZ yazilirsa `kanonik-kopya` dogar (bu projede bes
// kez isirdi).
//
// KILITLI KURALLAR (Onur, 15 Agu 2026 -- oturum 77):
//   1. Tarih dagarcigi CEKIRDEK: `bugün` · `yarın` · `gg.aa[.yyyy]` ·
//      `yyyy-aa-gg`. Gun adlari / "haftaya" / "N gun sonra" KAPSAM DISI.
//   2. Yilsiz `gg.aa` -> HER ZAMAN icinde bulunulan yil (gecmise dusebilir;
//      urun zaten gecmis son tarihi yazabiliyor -- takvim secici bir yil
//      geriye izin veriyor -- yeni bir kavram GIRMEZ).
//   3. SAAT TANINMAZ: `17:00` ayri bir kural almaz, BASLIKTA KALIR. `sonTarih`
//      takvim gunu pinlidir (`GorevSatiri.takvimGunu` = `DateTime.utc(y,m,d)`)
//      ⇒ saklanamayacak bir degeri yutmak SESSIZ KAYIP olurdu.
//   4. TEKRARDA ILK KAZANIR (alan basina): `!p1 ... !p3` -> oncelik 1, `!p3`
//      BASLIKTA KALIR. Kullanici fazlaligi EKRANDA GORUR.
//   5. YALNIZ KUCUK HARF: `Yarın` tanINMAZ, baslikta kalir. Dart'in
//      `toLowerCase`i Turkce'de 'I' -> 'i' verir ('ı' olmaliydi); etiketlerde
//      de katlama YOK (o76 sinirı) ⇒ iki doktrin ayrismaz. ASCII karsiliklar
//      (`bugun`/`yarin`) da TANINMAZ.
//   6. Etiket COKLU: `#iş #acil` ikisini de alir. Ayni etiket iki kez
//      yazilirsa TEKILLESIR (deger yine yakalanir ⇒ kayip yok).
//   7. `#` YALNIZ token'in BASINDA etikettir ⇒ `C# öğren` bozulmaz.
//   8. TANINMAYAN HER TOKEN BASLIKTA KALIR (gecersiz tarih, `!p4`, `#`,
//      32 karakteri asan etiket dahil). Sessiz kayip YASAK.

import 'etiket_dogrulama.dart';

/// `!p<N>` icin kabul edilen EN BUYUK N.
///
/// 🔴 KANONIK KAYNAK BU DEGILDIR: seviye kumesinin tek sahibi
/// `gorev_deposu.dart`daki `oncelikSayidan` (1/2/3 pini). Burasi yalniz
/// ayristirma kelepcesidir ve `dogal_dil_ayristirici_test.dart` iki kumenin
/// AYNI oldugunu MEKANIK olarak dogrular -- kopya elle senkron tutulmaz.
const int kDogalDilAzamiOncelik = 3;

/// Ayristirma sonucu. `baslik` BOS olabilir (`#iş` tek basina yazildiginda):
/// bos basligi REDDETME kurali burada DEGIL, cagiran taraftaki
/// `gorevBasligiDogrula`dadir -- dogrulama tek kaynaktan okunur.
class DogalDilSonucu {
  /// Tanınmayan token'lar, GIRDIDEKI SIRAYLA, aralarinda TEK bosluk.
  final String baslik;

  /// Tel/DB sayisi (1/2/3) ya da `null` = verilmedi. Enum'a cevirmek
  /// cagiranin isidir (`oncelikSayidan`) -- bu dosya `drift`e bulasmaz.
  final int? oncelik;

  /// TAKVIM GUNU: her zaman `DateTime.utc(y, m, d)` (gece yarisi, UTC).
  final DateTime? sonTarih;

  /// ILK GORULME sirasinda, TEKIL. `LinkedHashSet` sirasi korunur ⇒ uretilen
  /// `WireSetAdd` sirasi da deterministiktir (testte beklenebilir).
  final List<String> etiketler;

  const DogalDilSonucu({
    required this.baslik,
    this.oncelik,
    this.sonTarih,
    this.etiketler = const [],
  });

  @override
  String toString() =>
      'DogalDilSonucu(baslik: "$baslik", oncelik: $oncelik, '
      'sonTarih: $sonTarih, etiketler: $etiketler)';
}

// Bir kez derlenir (her cagride yeniden kurmak sicak yolda bosa istir).
final RegExp _oncelikKalibi = RegExp(r'^!p(\d+)$');
final RegExp _gunAy = RegExp(r'^(\d{1,2})\.(\d{1,2})$');
final RegExp _gunAyYil = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$');
final RegExp _isoKalibi = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
final RegExp _bosluk = RegExp(r'\s+');

/// SAF. [bugun] cagiranin saatidir; YALNIZ yil/ay/gun alanlari okunur
/// (saat/dilim DUSURULUR) ⇒ ayni takvim gununde hangi saatte cagrildigi
/// sonucu DEGISTIRMEZ.
DogalDilSonucu dogalDilAyristir(String ham, {required DateTime bugun}) {
  final bugunGun = DateTime.utc(bugun.year, bugun.month, bugun.day);

  final baslikParcalari = <String>[];
  final etiketler = <String>{};
  int? oncelik;
  DateTime? sonTarih;

  for (final token in ham.trim().split(_bosluk)) {
    if (token.isEmpty) continue;

    // --- TARIH (ilk kazanir) ---
    if (sonTarih == null) {
      final tarih = _tarihCoz(token, bugunGun);
      if (tarih != null) {
        sonTarih = tarih;
        continue;
      }
    }

    // --- ONCELIK (ilk kazanir) ---
    if (oncelik == null) {
      final eslesme = _oncelikKalibi.firstMatch(token);
      if (eslesme != null) {
        // 🔴 `tryParse` PAZARLIKSIZ [OLCULDU -- bagimsiz denetim, o77]:
        // `\d+` basamak SAYMAZ ve `int.parse` 64 biti asan girdide
        // `FormatException` FIRLATIR. VM/Android'de ekleme dugmesi
        // sessizce hicbir sey yapmazdi (Web'de dart2js double'a dusup
        // AYRI davranirdi) -- iki platform ayrisirdi. `null` = tanINMADI
        // ⇒ token KILIT 8 uyarinca baslikta kalir.
        final sayi = int.tryParse(eslesme.group(1)!);
        // `!p4` KAPIDAN GECMEZ: bilinmeyen bir seviyeyi yazmak, urunun
        // "bilinmeyen priority'yi CIZME ama EZME" doktrininin tersidir --
        // orada uzaktan GELEN deger korunur, burada YEREL olarak URETILIRDI.
        if (sayi != null && sayi >= 1 && sayi <= kDogalDilAzamiOncelik) {
          oncelik = sayi;
          continue;
        }
      }
    }

    // --- ETIKET (coklu) ---
    // `token[0]` guvenli: `isEmpty` yukarida elendi.
    if (token.startsWith('#')) {
      final etiket = etiketDogrula(token.substring(1));
      if (etiket != null) {
        etiketler.add(etiket);
        continue;
      }
    }

    baslikParcalari.add(token);
  }

  return DogalDilSonucu(
    baslik: baslikParcalari.join(' '),
    oncelik: oncelik,
    sonTarih: sonTarih,
    etiketler: etiketler.toList(growable: false),
  );
}

/// SAF. Tanimadigi her seye `null` doner (token baslikta kalir).
DateTime? _tarihCoz(String token, DateTime bugunGun) {
  if (token == 'bugün') return bugunGun;
  if (token == 'yarın') return bugunGun.add(const Duration(days: 1));

  final gunAyYil = _gunAyYil.firstMatch(token);
  if (gunAyYil != null) {
    return _takvimGunu(
      int.parse(gunAyYil.group(3)!),
      int.parse(gunAyYil.group(2)!),
      int.parse(gunAyYil.group(1)!),
    );
  }

  final gunAy = _gunAy.firstMatch(token);
  if (gunAy != null) {
    // KILIT 2: yil DAIMA icinde bulunulan yil -- gecmise dusebilir.
    return _takvimGunu(
      bugunGun.year,
      int.parse(gunAy.group(2)!),
      int.parse(gunAy.group(1)!),
    );
  }

  final iso = _isoKalibi.firstMatch(token);
  if (iso != null) {
    return _takvimGunu(
      int.parse(iso.group(1)!),
      int.parse(iso.group(2)!),
      int.parse(iso.group(3)!),
    );
  }

  return null;
}

/// 🔴 TASMA KONTROLU PAZARLIKSIZ: `DateTime.utc(2026, 2, 30)` PATLAMAZ,
/// sessizce 2 Mart'a KAYAR. Kullanicinin yazdigi gun ile kaydedilen gun
/// ayrisirsa bu, kullanicinin GORMEDIGI bir veri degisimidir -- gidis-donus
/// dogrulanir, tutmazsa token BASLIKTA KALIR.
DateTime? _takvimGunu(int yil, int ay, int gun) {
  // 🔴 YIL >= 1 PAZARLIKSIZ [OLCULDU -- bagimsiz denetim, o77]: Dart
  // `DateTime.utc(0, 1, 1)`i seve seve kurar ve `0000-01-01T00:00:00.000Z`
  // uretir; sunucunun `ProjectionFields.ReadDate`i ise `DateTimeOffset`
  // (`MinValue` = 0001-01-01) ile `TryParseExact` yapar ve bunu
  // `MalformedFields`e atip alani DUSURUR. Istemci son tarihi CIZER, sunucu
  // ATAR ⇒ SINIR OTESI SESSIZ KAYIP. Token baslikta kalsin, daha iyi.
  if (yil < 1) return null;
  final aday = DateTime.utc(yil, ay, gun);
  if (aday.year != yil || aday.month != ay || aday.day != gun) return null;
  return aday;
}
