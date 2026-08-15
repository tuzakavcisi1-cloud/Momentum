/// ODEV.md §4(a) etiket dilimi: etiket metni icin TEK dogrulama kaynagi --
/// diyalogun ekleme alani BURADAN okur (`gorev_baslik_dogrulama.dart`
/// emsali; ayni kural iki yerde yazilirsa `kanonik-kopya` dogar, bu projede
/// bes kez isirdi).
///
/// KURAL (Onur, kilitli -- oturum 76): KIRPMA + BOS REDDI + AZAMI UZUNLUK.
///
/// 🔴 BUYUK/KUCUK HARF KATLAMASI YAPILMAZ: sunucu OR-Set elemanlarini
/// ORDINAL karsilastirir (`StringComparer.Ordinal`, `SyncPuller` gruplamasi)
/// ⇒ 'İş' ile 'iş' AYRI etiketlerdir. Turkce I/İ katlamasi AYRI bir mayindir
/// (`toLowerCase` Dart'ta 'I' -> 'i' verir, Turkce'de 'ı' olmasi gerekirdi)
/// ve bu dilimde KAPSAM DISIDIR -- sinir DURUM.md'ye yazilir.
///
/// UZUNLUK YALNIZ ISTEMCI KELEPCESIDIR: sunucu eleman uzunlugunu KISITLAMAZ
/// (serbest metin OR-Set elemani) ⇒ UZAKTAN gelen daha uzun bir etiket
/// EZILMEZ, oldugu gibi saklanir ve cizilir -- bilinmeyen `priority`
/// degerinin AYNI doktrini (baska istemcinin yazdigini sessizce EZMEK LWW'nin
/// altini oymaktir).
///
/// Sayim KOD BIRIMIDIR (`String.length`), rune degil: BMP disi bir karakter
/// (or. emoji) iki sayilir. Bu bilincli ve ucuz bir kelepcedir -- sinir
/// sunucuda degil, yalniz bu alandadir.
const int kEtiketAzamiUzunluk = 32;

/// `null` doner: kirpma sonrasi BOS ya da azami uzunlugu ASAN etiket
/// REDDEDILIR ve cagiran hicbir sey yapmaz (diyalog alani TEMIZLENMEZ --
/// sessiz kayip YASAK, o68'de olculen desen). Aksi halde KIRPILMIS etiket.
String? etiketDogrula(String ham) {
  final kirpilmis = ham.trim();
  if (kirpilmis.isEmpty) return null;
  if (kirpilmis.length > kEtiketAzamiUzunluk) return null;
  return kirpilmis;
}
