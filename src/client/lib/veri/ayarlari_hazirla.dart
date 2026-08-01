import 'ayarlar_deposu.dart';
import 'veritabani.dart' hide Ayarlar;

final RegExp _guid = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

/// GOREV-A10 Y3: `DEV_USER_ID` derleme-zamani ezmesini uygular. `ezme` bos ya
/// da mevcut `devUserId` ile ayniysa hicbir yazma KOSMAZ (SS2/5). GUID
/// bicimini tasimayan bir ezme GURULTULU hata verir (SS3/c, Onur kilidi):
/// backend `Guid.TryParse` kullanir, bozuk ezme her istegi sessizce 401
/// yapardi. Ezme GECERLIYSE `devUserId` degistirilir VE ayni transaction'da
/// `gorevler` + `senkron_kuyrugu` silinir (SS3/d, Onur kilidi): D7/4
/// sifirlamasi yalniz `nextCursorJson` + `uzak_alan_durumu`'nu kapsar, bu
/// ikisi birakilirsa eski kullanicinin bekleyen op'lari yeni kimlikle
/// sunucuya itilir.
Future<Ayarlar> ayarlariHazirla(
  Veritabani db,
  AyarlarDeposu deposu, {
  required String ezme,
}) async {
  final ayarlar = await deposu.yukleVeyaOlustur(); // a
  if (ezme.isEmpty || ezme == ayarlar.devUserId) return ayarlar; // b
  if (!_guid.hasMatch(ezme)) {
    // c [ONUR KİLİDİ]
    throw ArgumentError.value(ezme, 'DEV_USER_ID',
        'GUID olmalı -- backend Guid.TryParse kullanır, aksi halde her istek 401');
  }
  await db.transaction(() async {
    // d [ONUR KİLİDİ]
    await deposu.devUserIdDegistir(ezme);
    await db.delete(db.gorevler).go();
    await db.delete(db.senkronKuyrugu).go();
  });
  return deposu.yukleVeyaOlustur(); // e
}
