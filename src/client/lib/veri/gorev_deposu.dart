import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../sunum/senkron_rozeti.dart';
import 'ayarlar_deposu.dart';
import 'hlc.dart';
import 'veritabani.dart';
import 'wire_op.dart';

/// ODEV.md §4(a): kullaniciya gorunen UC seviye. Ham `int?` hem DB'de hem
/// telde tasinir (sunucu sozlesmesi: `priority` = scalar LWW `int?`); bu enum
/// yalniz GOSTERIM ve SECIM icindir.
/// SAYI ESLEMESI PINLI: 1 = yuksek, 2 = orta, 3 = dusuk (kucuk sayi = daha
/// acil). `null` = oncelik yok.
enum Oncelik { yuksek, orta, dusuk }

/// SAF. Enum -> tel/DB sayisi.
int? oncelikSayiya(Oncelik? oncelik) => switch (oncelik) {
  Oncelik.yuksek => 1,
  Oncelik.orta => 2,
  Oncelik.dusuk => 3,
  null => null,
};

/// SAF. Tel/DB sayisi -> enum. 1/2/3 DISINDAKI her sayi (ve `null`) `null`
/// dondurur: bilinmeyen deger EKRANDA CIZILMEZ ama DB'de/telde DOKUNULMADAN
/// durur (bkz. veritabani.dart `oncelik` sutunu).
Oncelik? oncelikSayidan(int? sayi) => switch (sayi) {
  1 => Oncelik.yuksek,
  2 => Oncelik.orta,
  3 => Oncelik.dusuk,
  _ => null,
};

/// "YAZILACAK MI" ile "HANGI DEGER" AYRIMI. `null` = alan DEGISMEDI (tele hic
/// konmaz); `Yazim(null)` = alan TEMIZLENDI (tele `value: null` konur).
/// Tek bir `null`u iki anlamda kullanmak "temizle"yi "dokunma"dan ayirt
/// edilemez yapardi -- drift'in `Value` / `Value.absent()` ayriminin AYNISI,
/// ama drift turu widget katmanina SIZMADAN (F4 dikisi).
class Yazim<T> {
  final T deger;
  const Yazim(this.deger);
}

/// Birlesik duzenleme diyalogunun donusu -- YALNIZ DEGISEN alanlar doludur.
class GorevAyrintiDegisikligi {
  final Yazim<String>? baslik;
  final Yazim<int?>? oncelik;
  final Yazim<DateTime?>? sonTarih;

  /// ODEV.md §4(a) etiket dilimi: OR-Set'te "yeni deger" YOKTUR, EKLEME ve
  /// SILME vardir ⇒ bu iki alan `Yazim` DEGILDIR (bir OR-Set'i "temizlenmis"
  /// diye damgalamak anlamsizdir). Bos kume = o yonde degisiklik yok.
  final Set<String> etiketEklenen;
  final Set<String> etiketSilinen;

  const GorevAyrintiDegisikligi({
    this.baslik,
    this.oncelik,
    this.sonTarih,
    this.etiketEklenen = const {},
    this.etiketSilinen = const {},
  });

  /// Hicbir alan degismediyse op URETILMEZ: sunucu bos bir op'u BUTUN olarak
  /// reddeder (D2 -- her op EN AZ BIR kanal tasir).
  bool get bosMu =>
      baslik == null &&
      oncelik == null &&
      sonTarih == null &&
      etiketEklenen.isEmpty &&
      etiketSilinen.isEmpty;
}

/// TEL BICIMI PINI (sunucu sozlesmesinden OLCULDU, varsayilmadi):
/// `priority` -> `ProjectionFields.ReadInt` = `int.TryParse` +
/// `NumberStyles.Integer` + `InvariantCulture` ⇒ ONDALIK TAMSAYI dizesi.
/// Dart'in `int.toString()`i tam olarak bunu uretir.
String? oncelikTele(int? oncelik) => oncelik?.toString();

/// `dueAt` -> `ProjectionFields.ReadDate` = `TryParseExact` +
/// `["yyyy-MM-dd'T'HH:mm:ss.FFFFFFFK", "yyyy-MM-dd'T'HH:mm:ssK"]` +
/// `AssumeUniversal | AdjustToUniversal`. `DateTime.utc(...)
/// .toIso8601String()` (`2026-08-21T00:00:00.000Z`) bu kaliba oturur.
/// 🔴 `.toUtc()` DUSURULEMEZ: ofset TASIMAYAN bir dize `AssumeUniversal` ile
/// UTC SAYILIR, yani yerel saat sessizce UTC diye okunurdu -- SS1.3'un uc
/// saatlik kaymasinin AYNISI.
String? sonTarihTele(DateTime? sonTarih) => sonTarih?.toUtc().toIso8601String();

/// F4'un dikisi: widget'lar Drift'in urettigi satir sinifini (GorevRow)
/// dogrudan tuketmez -- bu domain modeli araya girer. Adim 3'te beslenen
/// tip degisirse (gercek senkron alanlari eklenirse) degisiklik yalniz
/// burada ve _map()'te kalir, dokuz bilesen yeniden yazilmaz.
class Gorev {
  final String id;
  final String baslik;
  final bool tamamlandi;
  final DateTime olusturuldu;
  final DateTime guncellendi;
  final String senkronDurumu;
  final bool silindi;

  /// ODEV.md §4(a). HAM sutunlardir (turetilmis rozet durumu DEGIL) --
  /// `Gorev`in "yalniz ham projeksiyon tasir" invaryanti korunur.
  /// Varsayilan `null`: mevcut ~40 cagri yeri (testler dahil) bunlari HIC
  /// bilmez ve `null` onlarin GERCEK durumudur.
  final int? oncelik;
  final DateTime? sonTarih;

  /// ODEV.md §4(a) etiket dilimi: OR-Set'in AKTIF elemanlari (iptal edilmis
  /// tag'ler DISARIDA). Bu da HAM PROJEKSIYONDUR -- `gorevEtiketleri`
  /// tablosundan AYNI sorguda toplanir, turetilmis rozet durumu DEGILDIR.
  /// SIRALI ve BENZERSIZ (depo garanti eder) ⇒ ekranda deterministik.
  /// Varsayilan bos liste: mevcut ~40 cagri yeri (testler dahil) bu alani
  /// HIC bilmez ve bos liste onlarin GERCEK durumudur.
  final List<String> etiketler;

  const Gorev({
    required this.id,
    required this.baslik,
    required this.tamamlandi,
    required this.olusturuldu,
    required this.guncellendi,
    required this.senkronDurumu,
    required this.silindi,
    this.oncelik,
    this.sonTarih,
    this.etiketler = const [],
  });
}

/// GOREV-R10 D5: `Gorev` (YALNIZ ham projeksiyon sutunlari) + KUYRUKTAN
/// TURETILEN rozet durumu TEK yerde -- widget'lar iki ayri parametre yerine
/// (senkronDurumu, cakismaVarMi) TEK gorunum nesnesi tuketir. Ham `U`/`B`/`Z`
/// sayimlari BURADAN DISARI CIKMAZ; yalniz turetilmis sonuc tasinir.
class GorevGorunum {
  final Gorev gorev;
  final SenkronDurumTuru senkronDurumu;
  final bool cakismaVarMi;

  const GorevGorunum({
    required this.gorev,
    required this.senkronDurumu,
    required this.cakismaVarMi,
  });
}

/// GOREV-SS2 D-SS2-8: `CakismaKaydiRow`'un (Drift satiri) ekrana sizmamis
/// hali -- F4 dikisinin (Gorev/GorevRow ayrimi) aynisi.
class CakismaKaydi {
  final String alan;
  final String kaybedenDeger;
  final String kazananDeger;

  const CakismaKaydi({
    required this.alan,
    required this.kaybedenDeger,
    required this.kazananDeger,
  });
}

/// GOREV-SS2 D-SS2-6: `cakismaCoz`'un secim parametresi.
enum CakismaSecimi { benimkiniTut, onlarinkiniAl }

abstract class GorevDeposu {
  /// Gorunur kayitlara TEK erisim yolu -- silindi=false filtresi YALNIZ
  /// burada. GOREV-R10 D5/D6: rozet KUYRUKTAN turetilir, sonuc GorevGorunum
  /// olarak doner (Gorev + turetilmis senkronDurumu/cakismaVarMi).
  Stream<List<GorevGorunum>> gorevlerGorunur();

  Future<void> ekle(String baslik);

  Future<void> duzenle(String id, String yeniBaslik);

  /// ODEV.md §4(a): baslik + oncelik + son tarih + ETIKETLER TEK `WireOp`,
  /// TEK `transaction()`. YALNIZ verilen (`Yazim` ile isaretlenmis) alanlar
  /// yazilir -- degismemis bir alani yeniden damgalamak, arada gelen uzak
  /// bir yazimi LWW ile sessizce ezerdi.
  ///
  /// Etiketler `Yazim` TASIMAZ (OR-Set'te "temizlendi" diye bir deger yoktur):
  /// [etiketEklenen] her metin icin YENI bir add-tag'i uretir,
  /// [etiketSilinen] o metnin O ANDA AKTIF tag'lerini iptal eder.
  /// 🔴 `observed` listesi WIDGET'ta DEGIL, BURADA (transaction icinde)
  /// cozulur: diyalog acikken gelen uzak bir add BAYAT bir `observed` ile
  /// gonderilseydi ADD-WINS ile hayatta kalir, kullanicinin gordugu sonuc
  /// ile sunucununki AYRISIRDI.
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  });

  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi});

  Future<void> sil(String id);

  /// GOREV-SS2 D-SS2-8/S9: entity icin cakisma kayitlarini IZLER (watch()) --
  /// tek seferlik okuma DEGIL: ekran acikken kayit degisirse (or. cozulurse)
  /// yeniden cizilir.
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId);

  /// GOREV-SS2 D-SS2-6: entity'nin TUM cakisma kayitlarina TEK secim
  /// uygulanir (karar entity basinadir, S1).
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim);
}

/// GOREV-SS2 D-SS2-4 PAZARLIKSIZ: cakisma tespiti icin TEK temsil alani --
/// hem kaybeden hem kazanan deger BU fonksiyondan gecer. v1'in MAJOR-1
/// kusuru: tel temsili ('done'/'true') projeksiyon bool'uyla karsilastirildi,
/// esitlik hic tetiklenmedi. EKRANDA GOSTERILEN METIN BU DIZE DEGILDIR --
/// Metinler'den gelen yerellestirilmis etiket kullanilir (D-SS2-8); bu
/// yalniz KARSILASTIRMA ve DEPOLAMA birimidir.
String kanonikDize(String alan, Object deger) {
  switch (alan) {
    case 'fields:title':
      return deger as String;
    case 'groups:completion':
      return (deger as bool) ? 'tamamlandi' : 'acik';
    default:
      throw StateError('kanonikDize: desteklenmeyen alan -- $alan');
  }
}

/// GOREV-R10 D3/D4 PAZARLIKSIZ: SAF fonksiyon -- DB/BuildContext/saat erisimi
/// YOK, ayni girdi HER ZAMAN ayni cikti. `senkronDurumu` (K, ham kolon) ONCE
/// dogrulanir -- taninmayan dize kurallar 1-3 kisa devre yapsa bile FIRLAR
/// (D3, mevcut "sessizce 'yerel'e dusmek YASAK" invaryanti).
///
/// D1 PAZARLIKSIZ cakisma kanali: `zehirli>0 || senkronDurumu=='cakisma' ||
/// cakismaKaydiSayisi>0` (GOREV-SS2 D-SS2-5: UCUNCU kanal) -- yalniz
/// `zehirli>0` YANLIStir (4xx yolu zehirli satir uretmeden kolona 'cakisma'
/// yazar, bkz. senkron_dongusu.dart _httpHatasiIsle).
///
/// D2 taban durumu (ilk eslesen kural kazanir):
///  1. ucusta>0                                             => kuyrukta
///  2. ucusta=0, bekleyen>0, K=='cevrimdisi'                => cevrimdisi
///  3. ucusta=0, bekleyen>0, K!='yerel' [build bulgusu, altta] => gonderilmemis (YENI)
///  4. ucusta=0, bekleyen=0                  => K eslemesi
(SenkronDurumTuru, bool) rozetDikisi(
  String senkronDurumu, {
  required int ucusta,
  required int bekleyen,
  required int zehirli,
  // GOREV-SS2 D-SS2-5: varsayilan 0 -- var olan cagri yerleri (SS2'den
  // ONCEKI) bu kanali hic bilmez, 0 onlarin gercek durumudur (cakisma kaydi
  // henuz mumkun degildi).
  int cakismaKaydiSayisi = 0,
}) {
  const gecerliDurumlar = {
    'yerel',
    'kuyrukta',
    'senkronize',
    'cakisma',
    'cevrimdisi',
  };
  if (!gecerliDurumlar.contains(senkronDurumu)) {
    throw ArgumentError('Taninmayan senkronDurumu: $senkronDurumu');
  }

  final cakismaVarMi =
      zehirli > 0 || senkronDurumu == 'cakisma' || cakismaKaydiSayisi > 0;

  // BUILD-ZAMANI BULGU (K75 D2 kural 3'e ELE ALINMAMIŞ kenar durum --
  // ölçüldü, spec'e kopyalanmadı, Cowork/Onur'a build notunda bildirilir):
  // D2 kural 3'ün ham metni ("U=0,B>0 => gonderilmemis") K='yerel'i istisna
  // TUTMUYOR, ama DESIGN.md v2 §4 "gönderilmemiş"i AÇIKÇA "satır sunucuda
  // VAR" diye tanımlıyor -- taze/hiç senkronlanmamış bir satır (K='yerel')
  // sunucuda YOK. Ham kural bu haliyle uygulanınca ÖLÇÜLEN regresyon:
  // g10_rozet_kapsami_test.dart AYAK6 (ekle() sonrası "Yalnızca bu cihazda"
  // beklentisi) KIRILDI -- taze bir görev, kendi gönderilmemiş ekleme
  // op'undan ötürü B>0 olduğu için hemen "Gönderilmemiş değişiklik" gösterdi.
  // DESIGN.md'nin kendi tanımını tie-break olarak kullanıp K=='yerel' kural
  // 3'ten İSTİSNA TUTULUR (rule 4'e düşer, taban 'yerel' kalır) -- kilitli
  // R10 senaryosunun kendisi (senkronize->düzenle->gönderilmemiş, G11-A3)
  // ETKİLENMEZ çünkü orada K zaten 'yerel' DEĞİLDİR.
  final SenkronDurumTuru taban;
  if (ucusta > 0) {
    taban = SenkronDurumTuru.kuyrukta;
  } else if (bekleyen > 0 && senkronDurumu == 'cevrimdisi') {
    taban = SenkronDurumTuru.cevrimdisi;
  } else if (bekleyen > 0 && senkronDurumu != 'yerel') {
    taban = SenkronDurumTuru.gonderilmemis;
  } else {
    taban = switch (senkronDurumu) {
      'senkronize' => SenkronDurumTuru.senkronize,
      'yerel' => SenkronDurumTuru.yerel,
      'cevrimdisi' => SenkronDurumTuru.cevrimdisi,
      'cakisma' => SenkronDurumTuru.yerel,
      'kuyrukta' => SenkronDurumTuru.kuyrukta,
      _ => throw StateError('gecerliDurumlar disi: $senkronDurumu'),
    };
  }

  return (taban, cakismaVarMi);
}

/// GOREV-slice-3c T4 (D2/D7/D8-1): dort yazma yolunun HER BIRI, `Gorevler`
/// satirini VE onun `WireOp`unu TEK Drift `transaction()` icinde yazar --
/// kuyruk yazilmadan `Gorevler` commit olursa veri sunucuya asla gitmez
/// (D8 kirmizi uyari, "hayalet op" ters sirada dogar). Bir op icindeki TUM
/// HLC'ler (`opHlc` + her `fields`/`groups` alaninin `hlc`si) D3'un AYNI
/// damgasidir -- bu yuzden her yazma yolu `hlc.sonrakiHlc()`i BIR KEZ cagirir
/// ve sonucu her yerde yeniden kullanir.
class DriftGorevDeposu implements GorevDeposu {
  final Veritabani _db;
  final DateTime Function() saat;
  final String Function() idUret;
  final HlcUretici hlc;
  final AyarlarDeposu ayarlarDeposu;
  final String actorId;

  DriftGorevDeposu(
    this._db, {
    required this.saat,
    required this.idUret,
    required this.hlc,
    required this.ayarlarDeposu,
    required this.actorId,
  });

  Gorev _map(GorevRow satir, {List<String> etiketler = const []}) => Gorev(
    id: satir.id,
    baslik: satir.baslik,
    tamamlandi: satir.tamamlandi,
    olusturuldu: satir.olusturuldu,
    guncellendi: satir.guncellendi,
    senkronDurumu: satir.senkronDurumu,
    silindi: satir.silindi,
    oncelik: satir.oncelik,
    sonTarih: satir.sonTarih,
    etiketler: etiketler,
  );

  /// ODEV.md §4(a): etiket toplama BANT-ICI AYIRAC KULLANMAZ.
  /// 🔴 [OLCULDU -- bagimsiz denetim, o76: IKI denetci AYNI kusuru buldu]
  /// `group_concat(etiket, <ayirac>)` her ayirac secimi icin BANT-ICIDIR:
  /// ayiraci ICINDE tasiyan bir eleman (uzaktan gelebilir -- sunucu serbest
  /// metin kabul eder, uzunluk/karakter KISITLAMAZ) ekranda IKI HAYALET
  /// etikete bolunuyordu ve o hayaletler SILINEMIYORDU (`WHERE etiket='a'`
  /// hicbir aktif satir bulmaz ⇒ op uretilmez). Virgul yerine U+001F secmek
  /// bu sinifi KUCULTUR, KAPATMAZ.
  /// Cozum: `json_group_array` -- SQLite kacisi her karakteri (kontrol
  /// karakterleri dahil, `\u001f`) tasir, cozme `jsonDecode` iledir.
  /// OLCULDU (o76): VM sqlite 3.53.3 JSON1 iceriyor; `web/sqlite3.wasm`
  /// ikilisi de `json_group_array` sembolunu tasiyor (JSON1 >= 3.38'de
  /// cekirdektedir).
  /// `FILTER (WHERE ... IS NOT NULL)`: sol birlestirmede eslesme yoksa
  /// `[null]` degil `[]` doner.
  /// 🔴 SQL AD BAGIMLILIGI: ifade drift'in urettigi tablo/sutun adlarina
  /// (`gorev_etiketleri`.`etiket`) dayanir; ad degisirse sorgu PATLAR ve
  /// etiket testleri ANINDA kirilir (sessiz bozulma degil).
  static final Expression<String> etiketToplayici = CustomExpression<String>(
    'json_group_array("gorev_etiketleri"."etiket") '
    'FILTER (WHERE "gorev_etiketleri"."etiket" IS NOT NULL)',
  );

  /// SAF: toplayicinin JSON ciktisini BENZERSIZ + SIRALI listeye cevirir.
  /// Fan-out (uc join) ayni etiketi tekrarlar ⇒ `toSet()` PAZARLIKSIZ.
  /// Siralama kod-birimi sirasidir (sunucunun Ordinal karsilastirmasiyla
  /// AYNI taban) -- Turkce harmanlama YOK, bu bir SINIRDIR.
  /// BOS DIZE ELENIR: gosterilemez ve suzulemez bir cip cizmek yerine
  /// projeksiyondan dusurulur -- satir ve TEL dokunulmadan durur
  /// (bilinmeyen `priority` degerinin ayni doktrini).
  static List<String> etiketleriCoz(String? hamJson) {
    if (hamJson == null || hamJson.isEmpty) return const [];
    final liste = (jsonDecode(hamJson) as List)
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    return liste..sort();
  }

  /// GOREV-R10 D6 PAZARLIKSIZ: TEK sorgu, TEK `watch()` -- iki ayri stream +
  /// combineLatest YASAK (ara karede yanlis rozet doğurur). `Gorevler`
  /// SURUCU, kuyruk `leftOuterJoin` -- `innerJoin` kuyruk satiri olmayan
  /// (senkronize) her gorevi listeden DUSURUR. `groupBy(gorevler.id)`
  /// PAZARLIKSIZ: yoksa satir sayisi O(kuyruk satiri) olur. SQLite
  /// `FILTER (WHERE ...)` kullanilir -- olculdu (bu makinede sqlite 3.53.3,
  /// FILTER >=3.30'dan beri var, build notunda beyan edilir).
  /// GOREV-SS2 D-SS2-5: `cakismaKayitlari`'na IKINCI bir `leftOuterJoin` --
  /// entity basina BIRDEN COK satir uretir (PK alan bazlidir) ⇒ TUM
  /// count(...) sutunlari `distinct: true` OLMAK ZORUNDADIR (aksi halde iki
  /// join'in kartezyen carpimi ucusta/bekleyen/zehirli sayilarini SISIRIR).
  /// `Ö12`'nin TEK sorgu / TEK `watch()` kilidi AYNEN durur.
  /// [hamSayimGozlemcisi] Test-görünür (GOREV-SS2 G33/d: `distinct: true`'nun
  /// fan-out'u GERÇEKTEN engellediğini kanıtlamak için HAM sayılara erişim
  /// gerekir -- `GorevGorunum` bunları KASITLI OLARAK dışarı çıkarmaz (D6).
  /// Üretimde her zaman null; imza `GorevDeposu.gorevlerGorunur()`'u
  /// EKSİKSİZ karşılar (yalnız EK bir opsiyonel parametre).
  @override
  Stream<List<GorevGorunum>> gorevlerGorunur({
    void Function(
      int ucusta,
      int bekleyen,
      int zehirli,
      int cakismaKaydiSayisi,
    )?
    hamSayimGozlemcisi,
  }) {
    final kuyruk = _db.senkronKuyrugu;
    final cakisma = _db.cakismaKayitlari;
    final etiketler = _db.gorevEtiketleri;
    final ucustaSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('gonderildi'),
      distinct: true,
    );
    final bekleyenSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('bekliyor'),
      distinct: true,
    );
    final zehirliSutunu = kuyruk.opId.count(
      filter: kuyruk.durum.equals('zehirli'),
      distinct: true,
    );
    final cakismaSutunu = cakisma.alan.count(distinct: true);
    // ODEV.md §4(a): etiketler UCUNCU bir `leftOuterJoin` ile gelir. JOIN
    // SART: drift'in tablo bagimliligini gormesi (ve `watch()`in
    // `gorevEtiketleri` degisince TAZELENMESI) icin -- ham bir
    // `CustomExpression` alt-sorgusu stream'i TAZELEMEZDI.
    // Fan-out ayni etiketi TEKRARLAR; benzersizlestirme ve SIRALAMA Dart
    // tarafindadir (`etiketleriCoz`) -- SQL tarafinda DISTINCT denenmez
    // (SQLite DISTINCT'i toplayici argumaniyla birlikte kabul etmez).
    // Mevcut count(...) sutunlarinin `distinct: true`'su bu fan-out'a karsi
    // ZATEN koruyor (D-SS2-5'te ikinci join icin ayni gerekce yazildi).
    final etiketlerSutunu = etiketToplayici;

    final sorgu =
        _db.select(_db.gorevler).join([
            leftOuterJoin(
              kuyruk,
              kuyruk.entityId.equalsExp(_db.gorevler.id) &
                  kuyruk.entityType.equals('Task'),
              useColumns: false,
            ),
            leftOuterJoin(
              cakisma,
              cakisma.entityId.equalsExp(_db.gorevler.id),
              useColumns: false,
            ),
            // AKTIF uyelik suzgeci JOIN KOSULUNDADIR (`where` degil): sol
            // birlestirmede `where`e konsaydi etiketi olmayan gorevler
            // listeden DUSERDI (D6'nin `innerJoin` tuzaginin aynisi).
            leftOuterJoin(
              etiketler,
              etiketler.gorevId.equalsExp(_db.gorevler.id) &
                  etiketler.iptalEdildi.equals(false),
              useColumns: false,
            ),
          ])
          ..where(_db.gorevler.silindi.equals(false))
          ..addColumns([
            ucustaSutunu,
            bekleyenSutunu,
            zehirliSutunu,
            cakismaSutunu,
            etiketlerSutunu,
          ])
          ..groupBy([_db.gorevler.id])
          ..orderBy([
            OrderingTerm(expression: _db.gorevler.olusturuldu),
            OrderingTerm(expression: _db.gorevler.id),
          ]);

    return sorgu.watch().map(
      (satirlar) => satirlar.map((satir) {
        // `group_concat` hicbir satir eslesmezse NULL doner (etiketsiz gorev).
        final gorev = _map(
          satir.readTable(_db.gorevler),
          etiketler: etiketleriCoz(satir.read(etiketlerSutunu)),
        );
        final ucusta = satir.read(ucustaSutunu) ?? 0;
        final bekleyen = satir.read(bekleyenSutunu) ?? 0;
        final zehirli = satir.read(zehirliSutunu) ?? 0;
        final cakismaKaydiSayisi = satir.read(cakismaSutunu) ?? 0;
        hamSayimGozlemcisi?.call(ucusta, bekleyen, zehirli, cakismaKaydiSayisi);
        final (senkronDurumu, cakismaVarMi) = rozetDikisi(
          gorev.senkronDurumu,
          ucusta: ucusta,
          bekleyen: bekleyen,
          zehirli: zehirli,
          cakismaKaydiSayisi: cakismaKaydiSayisi,
        );
        return GorevGorunum(
          gorev: gorev,
          senkronDurumu: senkronDurumu,
          cakismaVarMi: cakismaVarMi,
        );
      }).toList(),
    );
  }

  @override
  Future<void> ekle(String baslik) async {
    final simdi = saat();
    final id = idUret();
    final opHlc = hlc.sonrakiHlc();
    final op = WireOp(
      operationId: idUret(),
      clientId: hlc.clientId,
      entityId: id,
      actorId: actorId,
      entityType: 'Task',
      opHlc: opHlc,
      fields: {'title': WireFieldWrite(value: baslik, hlc: opHlc)},
    );

    await _db.transaction(() async {
      await _db
          .into(_db.gorevler)
          .insert(
            GorevlerCompanion.insert(
              id: id,
              baslik: baslik,
              olusturuldu: simdi,
              guncellendi: simdi,
            ),
          );
      await _kuyrugaYaz(op);
    });
  }

  @override
  Future<void> duzenle(String id, String yeniBaslik) async {
    final opHlc = hlc.sonrakiHlc();
    final op = WireOp(
      operationId: idUret(),
      clientId: hlc.clientId,
      entityId: id,
      actorId: actorId,
      entityType: 'Task',
      opHlc: opHlc,
      fields: {'title': WireFieldWrite(value: yeniBaslik, hlc: opHlc)},
    );

    await _db.transaction(() async {
      await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
        GorevlerCompanion(
          baslik: Value(yeniBaslik),
          guncellendi: Value(saat()),
        ),
      );
      await _kuyrugaYaz(op);
    });
  }

  /// D8-1 emsali: `Gorevler` satiri VE `WireOp` AYNI transaction'da.
  /// Bir op icindeki TUM HLC'ler (opHlc + her alanin hlc'si) AYNI damgadir --
  /// `sonrakiHlc()` BIR KEZ cagrilir (D3).
  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  }) async {
    final eklenen = etiketEklenen ?? const <String>{};
    final silinen = etiketSilinen ?? const <String>{};
    // D2: bos op URETILMEZ -- sunucu her op'un EN AZ BIR kanal tasimasini
    // sart kosar; hicbir alan degismediyse ne projeksiyona ne kuyruga
    // dokunulur (yoksa "hayalet op" dogar).
    if (baslik == null &&
        oncelik == null &&
        sonTarih == null &&
        eklenen.isEmpty &&
        silinen.isEmpty) {
      return;
    }

    final opHlc = hlc.sonrakiHlc();
    final alanlar = {
      if (baslik != null)
        'title': WireFieldWrite(value: baslik.deger, hlc: opHlc),
      if (oncelik != null)
        'priority': WireFieldWrite(
          value: oncelikTele(oncelik.deger),
          hlc: opHlc,
        ),
      if (sonTarih != null)
        'dueAt': WireFieldWrite(
          value: sonTarihTele(sonTarih.deger),
          hlc: opHlc,
        ),
    };

    await _db.transaction(() async {
      // ETIKET YAZIMLARI TRANSACTION ICINDE: `observed` listesi BURADA
      // cozulur (widget'ta DEGIL) -- bkz. `GorevDeposu.ayrintilariGuncelle`
      // belgesindeki kirmizi uyari.
      final adds = <WireSetAdd>[];
      final removes = <WireSetRemove>[];

      for (final etiket in eklenen) {
        final tag = idUret();
        adds.add(WireSetAdd(el: etiket, tag: tag, hlc: opHlc));
        await _db
            .into(_db.gorevEtiketleri)
            .insert(
              GorevEtiketleriCompanion.insert(
                gorevId: id,
                etiket: etiket,
                addTag: tag,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      for (final etiket in silinen) {
        final aktifler =
            await (_db.select(_db.gorevEtiketleri)..where(
                  (t) =>
                      t.gorevId.equals(id) &
                      t.etiket.equals(etiket) &
                      t.iptalEdildi.equals(false),
                ))
                .get();
        // AKTIF TAG YOKSA REMOVE URETILMEZ: sunucunun `SetRemove`u YALNIZ
        // gorulen tag'leri iptal eder ⇒ bos `observed` HICBIR SEY yapmaz,
        // yalniz bos bir op dogururdu.
        if (aktifler.isEmpty) continue;
        removes.add(
          WireSetRemove(
            el: etiket,
            observed: aktifler.map((s) => s.addTag).toList(),
            hlc: opHlc,
          ),
        );
        await (_db.update(_db.gorevEtiketleri)..where(
              (t) =>
                  t.gorevId.equals(id) &
                  t.etiket.equals(etiket) &
                  t.iptalEdildi.equals(false),
            ))
            .write(const GorevEtiketleriCompanion(iptalEdildi: Value(true)));
      }

      // D2 (ikinci kapi): yalniz "aktif tag'i olmayan bir etiketi sil"
      // istendiyse hicbir kanal DOLMAZ -- projeksiyona da kuyruga da
      // dokunulmadan cikilir.
      if (alanlar.isEmpty && adds.isEmpty && removes.isEmpty) return;

      await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
        GorevlerCompanion(
          baslik: baslik != null ? Value(baslik.deger) : const Value.absent(),
          oncelik: oncelik != null
              ? Value(oncelik.deger)
              : const Value.absent(),
          sonTarih: sonTarih != null
              ? Value(sonTarih.deger)
              : const Value.absent(),
          guncellendi: Value(saat()),
        ),
      );
      await _kuyrugaYaz(
        WireOp(
          operationId: idUret(),
          clientId: hlc.clientId,
          entityId: id,
          actorId: actorId,
          entityType: 'Task',
          opHlc: opHlc,
          fields: alanlar,
          sets: {
            if (adds.isNotEmpty || removes.isNotEmpty)
              'tags': WireSetDelta(adds: adds, removes: removes),
          },
        ),
      );
    });
  }

  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {
    final opHlc = hlc.sonrakiHlc();
    // D2 PAZARLIKSIZ: completion REPLACE'tir -- status ve completedAt DAIMA
    // birlikte yazilir. .toUtc() dusurulemez (SS1.3 kirmizi uyari: 3 saat kaymasi).
    final op = WireOp(
      operationId: idUret(),
      clientId: hlc.clientId,
      entityId: id,
      actorId: actorId,
      entityType: 'Task',
      opHlc: opHlc,
      groups: {
        'completion': WireGroupWrite(
          fields: {
            'status': tamamlandi ? 'done' : 'open',
            'completedAt': tamamlandi ? saat().toUtc().toIso8601String() : null,
          },
          hlc: opHlc,
        ),
      },
    );

    await _db.transaction(() async {
      await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
        GorevlerCompanion(
          tamamlandi: Value(tamamlandi),
          guncellendi: Value(saat()),
        ),
      );
      await _kuyrugaYaz(op);
    });
  }

  @override
  Future<void> sil(String id) async {
    final opHlc = hlc.sonrakiHlc();
    final op = WireOp(
      operationId: idUret(),
      clientId: hlc.clientId,
      entityId: id,
      actorId: actorId,
      entityType: 'Task',
      opHlc: opHlc,
      fields: {'isDeleted': WireFieldWrite(value: 'true', hlc: opHlc)},
    );

    await _db.transaction(() async {
      await (_db.update(_db.gorevler)..where((t) => t.id.equals(id))).write(
        GorevlerCompanion(
          silindi: const Value(true),
          guncellendi: Value(saat()),
        ),
      );
      await _kuyrugaYaz(op);
    });
  }

  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) {
    return (_db.select(
      _db.cakismaKayitlari,
    )..where((t) => t.entityId.equals(entityId))).watch().map(
      (satirlar) => satirlar
          .map(
            (s) => CakismaKaydi(
              alan: s.alan,
              kaybedenDeger: s.kaybedenDeger,
              kazananDeger: s.kazananDeger,
            ),
          )
          .toList(),
    );
  }

  /// GOREV-SS2 D-SS2-6: yazma ONCE, silme SONRA, ikisi de AYNI transaction.
  /// 🟢 IC ICE TRANSACTION -- S11 OLCULDU VE DOGRULANDI (T6,
  /// `test/g34_cakismacoz_test.dart`, "S11 OLCUMU" testi): bu metot KENDI
  /// `_db.transaction()`'ini acar; icinden cagrilan `duzenle`/`tamamlaGeriAl`
  /// KENDI `transaction()`'larini IC ICE acar ve drift bunu GERCEKTEN
  /// savepoint'e indirger (izole test: dis transaction'da kasitli hata
  /// firlatilinca ic transaction'in yazdigi deger de GERI ALINDI). `benimkiniTut`
  /// mevcut yerel-yazma akisini (duzenle/tamamlaGeriAl) kullanir cunku o akis
  /// projeksiyonu DA yazar (v1'in BLOKER-6'si: yalniz kuyruga yazmak).
  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {
    await _db.transaction(() async {
      // 🔴 M177'nin (siralamayi ters cevirme) GERCEKTEN GOZLENEBILIR olmasi
      // icin kayitlar TRANSACTION ICINDE, silmeden HEMEN ONCE degil YAZMADAN
      // ONCE okunur -- sira ters cevrilip silme yazmadan ONCE kosarsa bu
      // sorgu BOS doner ve yazma hic gerceklesmez (M177'nin isirdigi budur).
      final kayitlar = await (_db.select(
        _db.cakismaKayitlari,
      )..where((t) => t.entityId.equals(entityId))).get();

      if (secim == CakismaSecimi.benimkiniTut) {
        for (final kayit in kayitlar) {
          switch (kayit.alan) {
            case 'fields:title':
              await duzenle(entityId, kayit.kaybedenDeger);
            case 'groups:completion':
              await tamamlaGeriAl(
                entityId,
                tamamlandi: kayit.kaybedenDeger == 'tamamlandi',
              );
          }
        }
      }
      // onlarinkiniAl: yazma YOK -- projeksiyon zaten uzagin degerini tasiyor.
      await (_db.delete(
        _db.cakismaKayitlari,
      )..where((t) => t.entityId.equals(entityId))).go();
    });
  }

  /// D1: `govdeJson` uretim aninda donar; gonderim aninda YENIDEN URETILMEZ.
  /// D8-1 ile ayni transaction icinde cagrilir (ustteki dort yazma yolu).
  Future<void> _kuyrugaYaz(WireOp op) async {
    await _db
        .into(_db.senkronKuyrugu)
        .insert(
          SenkronKuyruguCompanion.insert(
            opId: op.operationId,
            clientId: op.clientId,
            entityType: op.entityType,
            entityId: op.entityId,
            govdeJson: jsonEncode(op.toJson()),
            hlcWallMs: op.opHlc.wallMs,
            hlcCounter: op.opHlc.counter,
            olusturuldu: saat().toUtc(),
          ),
        );
    await ayarlarDeposu.hlcKalicilastir(hlc.sonWall, hlc.sonCounter);
  }
}

/// Uretim idUret() -- UUID v7 (RFC 9562), bagimliliksiz (spec'te uuid paketi
/// yok; Random.secure() ile elle uretilir).
///
/// K65 (Onur, kilitli): v4 (tamamen rastgele) yerine v7 (zaman-sirali) --
/// ilk 48 bit unix_ts_ms, buyuk-endian. Sebep: sunucunun `LwwRegister` tie-
/// break'i `opId`nin DIZE-ORDINAL karsilastirmasidir ve bu karsilastirma
/// zaman-sirali bir opId varsayar (bkz. backend `HlcKey`); v4 ile bu
/// varsayim yanlisti -- iki alan-HLC'si sunucu tarafinda ayni degere
/// kirpildiginda (D3 kirmizi uyari senaryosu) tie-break YAZI-TURAya
/// donusuyordu. v7'nin zaman-sirali on-eki bu carpismayi kaynaginda keser.
String uretimIdUret() {
  final simdiMs = DateTime.now().toUtc().millisecondsSinceEpoch;
  final rastgele = Random.secure();
  final baytlar = List<int>.generate(16, (_) => rastgele.nextInt(256));

  baytlar[0] = (simdiMs >> 40) & 0xFF;
  baytlar[1] = (simdiMs >> 32) & 0xFF;
  baytlar[2] = (simdiMs >> 24) & 0xFF;
  baytlar[3] = (simdiMs >> 16) & 0xFF;
  baytlar[4] = (simdiMs >> 8) & 0xFF;
  baytlar[5] = simdiMs & 0xFF;
  baytlar[6] = (baytlar[6] & 0x0F) | 0x70; // surum 7
  baytlar[8] = (baytlar[8] & 0x3F) | 0x80; // varyant 10xx

  String hex(int baslangic, int bitis) => baytlar
      .sublist(baslangic, bitis)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
