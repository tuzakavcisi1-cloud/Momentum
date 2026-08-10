/// IS-EMRI-o68 SS2 SS3: gorev basligi icin TEK dogrulama kaynagi --
/// `GorevEkleAlani` (ekleme) VE `GorevSatiri`'nin baslik duzenleme diyaloğu
/// AYNI kurali BURADAN okur. Kural iki yerde ayri yazilirsa `kanonik-kopya`
/// doğar (bu projede bes kez ısırdı -- CLAUDE.md kirmizi cizgi listesi).
///
/// OLCULDU (oturum 68 acilis taramasi): bugun urunde tek kural KIRPMA + BOS
/// REDDI'dir (`gorev_ekle_alani.dart` `_gonder()`, bu dosya yazilmadan once).
/// IS-EMRI-o68 §3.3 "azami uzunluk"tan da soz eder ama koda hic YAZILMAMIS
/// -- burada da uydurulmaz (CLAUDE.md §4: "Ölç ya da [DOĞRULANMADI] yaz").
///
/// `null` doner: kirpma sonrasi bos baslik REDDEDILIR, cagiran hicbir sey
/// yapmaz. Aksi halde KIRPILMIS baslik doner.
String? gorevBasligiDogrula(String ham) {
  final kirpilmis = ham.trim();
  if (kirpilmis.isEmpty) return null;
  return kirpilmis;
}
