/// F6 -- 13 kullanici dizgesi TEK YERDE. Kilit aninda
/// araclar/fixture/metinler-kilit.json'a dondurulur; G5 bu dosyayi fixture
/// ile birebir karsilastirir. DESIGN.md ayristirilmaz (§9.1 F6).
class Metinler {
  Metinler._();

  // Gorunur (8)
  static const String yalnizcaBuCihazda = 'Yalnızca bu cihazda';
  static const String gonderiliyor = 'Gönderiliyor';
  static const String cevrimdisiKaydedildi =
      'Çevrimdışısınız. Değişiklikler kaydedildi.';
  static const String cakismaVar = 'Bu görev başka bir cihazda da değişti.';
  static const String bosDurum = 'Henüz görev yok. Aşağıdan ekleyin.';
  static const String birSeylerTersGitti = 'Bir şeyler ters gitti.';
  static const String yenidenDene = 'Yeniden dene';
  static const String yukleniyor = 'Yükleniyor';

  // Semantics duyurusu (5)
  static const String duyuruGorevlerYukleniyor = 'Görevler yükleniyor';
  static const String duyuruSenkronizeEdildi = 'Senkronize edildi';
  static const String duyuruCevrimdisi = 'Çevrimdışı';
  static const String duyuruCakismaVar = 'Çakışma var';
  static const String duyuruHata = 'Hata';

  // EK -- F6'nin 13 dizgesine DAHIL DEGIL (G5 fixture karsilastirmasi bunu
  // icermez). Sabit kontrol etiketidir, durum dizgesi degildir; GorevEkleAlani
  // ikon-yalniz ekle dugmesi tasidigindan A11Y-3 (ikon-yalniz buton yasak)
  // bunu zorunlu kilar, DESIGN.md §6 bu eylem icin ayri bir metin tanimlamaz.
  static const String ekleDugmesi = 'Ekle';
}
