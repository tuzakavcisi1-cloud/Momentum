/// F6 -- 13 kullanici dizgesi TEK YERDE (GOREV-R10/K75: iki yeni dizge BU
/// SAYIYA DAHIL DEGIL, ayri EK grupta -- fixture/metinler-kilit.json F6
/// kilidini bozmaz). Kilit aninda araclar/fixture/metinler-kilit.json'a
/// dondurulur; G5 bu dosyayi fixture ile birebir karsilastirir. DESIGN.md
/// ayristirilmaz (§9.1 F6).
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

  // GOREV-R10 [K75] -- 'gonderilmemis' durumu (DESIGN.md v2 §4/§6).
  static const String gonderilmemisDegisiklik = 'Gönderilmemiş değişiklik';
  static const String duyuruGonderilmemisDegisiklik =
      'Gönderilmemiş değişiklik var';

  // GOREV-A7 [K85 / spec v4 §4/D-A7-1] -- ROZETIN EKRANDA GORUNEN KISA
  // metinleri. Yukaridaki "Gorunur (8)" grubu DEGISMEDI: o dizgeler artik
  // Semantics(label:)'da yasiyor ve ekran okuyucu ONLARI okuyor -- bilgi
  // KAYBI YOKTUR. Burada yasayanlar yalniz GOZLE gorulen kisaltmalardir.
  //
  // Neden ayri grup: bunlar F6'nin KILITLI 13 dizgesine DAHIL DEGILDIR
  // (GOREV-slice-3b §T-metin / K59'un "13 dizge" kilidi bozulmaz) --
  // GOREV-R10'un `gonderilmemisDegisiklik` icin kurdugu ayni EK deseni.
  // fixture/metinler-kilit.json'da "rozetKisaGorunur" grubunda aynalanir ve
  // a11y_kapisi_test.dart bu grubu da BIREBIR sinar (uc dosya es zamanli).
  //
  // OLCULDU (flutter_test fontu, 236 px alan, olcek 2.0x -- KANIT/A7/
  // 02-COZUM-OLCUM.txt): "Bu cihazda" 262,5 px / 2 satir · "Cevrimdisi"
  // 262,5 / 2 · "Gonderilmedi" 315,0 / 2. Reddedilenler (3 satir):
  // "Cevrimdisi kaydedildi" 551,3 · "Yalniz bu cihazda" 446,3.
  // 'kuyrukta' icin AYRI sabit YOKTUR: `gonderiliyor` (315,0 / 2 satir) hem
  // tam hem kisa metindir; kopya sabit yazmak F6'yi ikiye bolerdi.
  static const String rozetKisaYerel = 'Bu cihazda';
  static const String rozetKisaCevrimdisi = 'Çevrimdışı';
  static const String rozetKisaGonderilmedi = 'Gönderilmedi';

  // EK -- F6'nin 13 dizgesine DAHIL DEGIL (G5 fixture karsilastirmasi bunu
  // icermez). Sabit kontrol etiketidir, durum dizgesi degildir; GorevEkleAlani
  // ikon-yalniz ekle dugmesi tasidigindan A11Y-3 (ikon-yalniz buton yasak)
  // bunu zorunlu kilar, DESIGN.md §6 bu eylem icin ayri bir metin tanimlamaz.
  static const String ekleDugmesi = 'Ekle';

  // GOREV-SS2 [D-SS2-8] -- cakisma cozum ekrani. F6'nin 13 dizgesine DAHIL
  // DEGIL (GOREV-R10/A9'un ayni EK deseni). Kanonik dize (D-SS2-4) EKRANDA
  // GOSTERILMEZ -- bu etiketler yerellestirilmis karsiliklardir.
  static const String cakismaKaydiYok = 'Çakışan bir değişiklik bulunamadı.';
  static const String cakismaAlaniBaslik = 'Başlık';
  static const String cakismaAlaniTamamlanma = 'Tamamlanma durumu';
  static const String cakismaDegerTamamlandi = 'Tamamlandı';
  static const String cakismaDegerAcik = 'Açık';
  static const String cakismaBenimki = 'Benimki';
  static const String cakismaOnlarinki = 'Onlarınki';
  static const String cakismaBenimkiniTut = 'Benimkini tut';
  static const String cakismaOnlarinkiniAl = 'Onlarınkini al';

  // GOREV-W2 [D-W2-3/D-W2-8] -- depolama seridi. F6'nin 13 dizgesine DAHIL
  // DEGIL (GOREV-R10/SS2'nin ayni EK deseni) -- K59'un kilitli "13 dizge"
  // iddiasi bu ucle bayatlamaz.
  static const String depolamaGeriDususu =
      'Veriler tarayıcı deposunda tutuluyor.';
  static const String depolamaKaliciDegil =
      'Veriler kalıcı DEĞİL: sekme kapanınca silinir.';
  static const String duyuruDepolamaGeriDususu = 'Depolama geri düşüşü';

  // IS-EMRI-o68 -- SS2 kriter 8: baslik duzenleme ikonu + diyaloğu. F6'nin
  // 13 dizgesine DAHIL DEGIL (ayni EK deseni). Ayni dize hem ikonun
  // Semantics(label:)'i hem diyalog basligi olarak kullanilir -- ikisi de
  // ayni eylemi adlandirir, ayri dize UYDURULMAZ.
  static const String baslikDuzenle = 'Başlığı düzenle';
  static const String iptalDugmesi = 'İptal';
  static const String kaydetDugmesi = 'Kaydet';

  // IS-EMRI-o72 -- gorev silme eylemi (ikon + onay diyaloğu). F6'nin 13
  // dizgesine DAHIL DEGIL (ayni EK deseni, IS-EMRI-o68 emsali). Ayni dize
  // hem ikonun tooltip'i hem diyalog basligi olarak kullanilir.
  static const String gorevSil = 'Görevi sil';
  static const String gorevSilOnay = 'Bu görev silinsin mi?';
}
