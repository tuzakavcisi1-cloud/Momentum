@TestOn('vm')
library;

// IS-EMRI-o85-A D4 -- PAZARLIKSIZ KAPI: liste bir SUZGEC DEGIL, BAGLAMDIR.
// DURUM sinir 28 ("ekleme suzgecleri SIFIRLAR") arama VE etiket cipleri
// icindir; aktif liste BUNA DAHIL DEGILDIR -- aksi halde kullanici bir
// listeye gorev ekleyip Gelen Kutusu'na firlar (is emrinin kendi lafzi,
// "bu ayrım pazarlıksızdır ve testle ısırtılır").
//
// Bu test TAM O SENARYOYU EKRANDA olcer: Drawer'dan bir liste secilir,
// GorevEkleAlani'ndan yeni bir gorev eklenir -- eklenen gorev SECILI
// LISTEDE GORUNMEYE DEVAM etmeli (kaybolmamali/Gelen Kutusu'na dusmemeli).
// Sahte depo `ekle()` cagrisini KAYDEDER (depoda degil, EKRANDAKI eylemin
// KENDISI olculur -- KABUL maddesi "D4 -- ekranda ölçüldü, depoda değil").

import 'dart:async';

import 'package:client/design/metinler.dart';
import 'package:client/sunum/gorev_ekle_alani.dart';
import 'package:client/sunum/gorev_listesi_ekrani.dart';
import 'package:client/sunum/senkron_rozeti.dart';
import 'package:client/veri/gorev_deposu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SahteDepo implements GorevDeposu {
  final _gorevAkisi = StreamController<List<GorevGorunum>>.broadcast();
  // IS-EMRI-o85A2 A2: StreamController'a cevrildi (eskiden Stream.value tek
  // deger dondururdu) -- baska cihazdan liste silinmesini taklit etmek icin
  // IKINCI bir deger yayinlanabilmesi gerekiyor. Gorev akisinin AYNI deseni.
  final _listelerAkisi = StreamController<List<Proje>>.broadcast();
  final List<Map<String, Object?>> ekleCagrilari = [];

  @override
  Stream<List<GorevGorunum>> gorevlerGorunur() => _gorevAkisi.stream;

  @override
  Stream<List<Proje>> listelerGorunur() => _listelerAkisi.stream;

  @override
  Future<void> ekle(
    String baslik, {
    int? oncelik,
    DateTime? sonTarih,
    Set<String> etiketler = const {},
    String? projeId,
  }) async {
    ekleCagrilari.add({'baslik': baslik, 'projeId': projeId});
  }

  @override
  Future<void> duzenle(String id, String yeniBaslik) async {}

  @override
  Future<void> ayrintilariGuncelle(
    String id, {
    Yazim<String>? baslik,
    Yazim<int?>? oncelik,
    Yazim<DateTime?>? sonTarih,
    Yazim<String?>? projeId,
    Set<String>? etiketEklenen,
    Set<String>? etiketSilinen,
  }) async {}

  @override
  Future<void> tamamlaGeriAl(String id, {required bool tamamlandi}) async {}

  @override
  Future<void> sil(String id) async {}

  @override
  Stream<List<CakismaKaydi>> cakismaKayitlariniIzle(String entityId) =>
      Stream.value(const []);

  @override
  Future<void> cakismaCoz(String entityId, CakismaSecimi secim) async {}

  @override
  Future<void> listeEkle(String ad) async {}

  @override
  Future<void> listeDuzenle(String id, String yeniAd) async {}

  @override
  Future<void> listeSil(String id) async {}

  void yayinla(List<GorevGorunum> g) => _gorevAkisi.add(g);

  void yayinlaListeler(List<Proje> p) => _listelerAkisi.add(p);

  void kapat() {
    _gorevAkisi.close();
    _listelerAkisi.close();
  }
}

GorevGorunum _gorunum(String id, String baslik, {String? projeId}) =>
    GorevGorunum(
      gorev: Gorev(
        id: id,
        baslik: baslik,
        tamamlandi: false,
        olusturuldu: DateTime.utc(2026, 8, 1),
        guncellendi: DateTime.utc(2026, 8, 1),
        senkronDurumu: 'senkronize',
        silindi: false,
        projeId: projeId,
      ),
      senkronDurumu: SenkronDurumTuru.senkronize,
      cakismaVarMi: false,
    );

Proje _proje(String id, String ad) => Proje(
  id: id,
  ad: ad,
  silindi: false,
  olusturuldu: DateTime.utc(2026, 8, 1),
);

void main() {
  testWidgets(
    'D4 PAZARLIKSIZ: aktif liste secilince eklenen gorev O LISTEDE gorunur -- SUZGEC DEGIL BAGLAMDIR',
    (tester) async {
      final depo = _SahteDepo();
      addTearDown(depo.kapat);
      await tester.pumpWidget(
        MaterialApp(home: GorevListesiEkrani(depo: depo)),
      );
      // Gelen Kutusu'nda bir gorev, 'İş' listesinde bir gorev -- secimin
      // GERCEKTEN suzdugu dogrulanabilsin (pozitif kontrol, o83-G dersi:
      // bos liste her iddiayi gecirir).
      depo.yayinlaListeler([_proje('p1', 'İş')]);
      depo.yayinla([
        _gorunum('g-inbox', 'Gelen Kutusu Gorevi'),
        _gorunum('g-is', 'İş Gorevi', projeId: 'p1'),
      ]);
      await tester.pump();

      // Baslangicta Gelen Kutusu aktif -- yalniz o gorev gorunur.
      expect(find.text('Gelen Kutusu Gorevi'), findsOneWidget);
      expect(find.text('İş Gorevi'), findsNothing);

      // Drawer'i AC (programatik -- gercek uygulamada AppBar'daki hamburger
      // ikonu, bu testte onYenile/onCikisYap verilmedigi icin AppBar yok;
      // ScaffoldState.openDrawer() ayni eylemin dogrudan tetiklenmesidir).
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('liste_p1')));
      await tester.pumpAndSettle();

      // Simdi yalniz 'İş' listesindeki gorev gorunur -- suzme GERCEKTEN calisti.
      expect(find.text('İş Gorevi'), findsOneWidget);
      expect(find.text('Gelen Kutusu Gorevi'), findsNothing);

      // AKTIF LISTE SECILIYKEN yeni bir gorev ekle.
      final ekleAlani = find.descendant(
        of: find.byType(GorevEkleAlani),
        matching: find.byType(TextField),
      );
      await tester.enterText(ekleAlani, 'Yeni Gorev');
      await tester.tap(find.bySemanticsLabel(Metinler.ekleDugmesi));
      await tester.pump();

      // D4 KANITI 1: ekle() AKTIF listenin id'siyle cagrildi.
      expect(depo.ekleCagrilari, hasLength(1));
      expect(depo.ekleCagrilari.single['baslik'], 'Yeni Gorev');
      expect(depo.ekleCagrilari.single['projeId'], 'p1');

      // Sahte depo stream'e KENDILIGINDEN yansitmaz (gercek
      // DriftGorevDeposu'nun aksine) -- yeni satiri EKRANA yansit ki "eklenen
      // gorev o listede gorunuyor" GERCEKTEN olculebilsin (depoda degil,
      // ekranda -- KABUL maddesinin lafzi).
      depo.yayinla([
        _gorunum('g-inbox', 'Gelen Kutusu Gorevi'),
        _gorunum('g-is', 'İş Gorevi', projeId: 'p1'),
        _gorunum('g-yeni', 'Yeni Gorev', projeId: 'p1'),
      ]);
      await tester.pump();

      // D4 KANITI 2 (PAZARLIKSIZ): yeni gorev SECILI LISTEDE gorunur --
      // Gelen Kutusu'na FIRLAMADI, aktif liste secimi SIFIRLANMADI.
      expect(find.text('Yeni Gorev'), findsOneWidget);
      expect(find.text('Gelen Kutusu Gorevi'), findsNothing);
    },
  );

  // IS-EMRI-o85A2 §A BULGU 1 (K5 KAPISIZ): `gorev_listesi_ekrani.dart`daki
  // K5 suzgecinin ikinci kosulu (`!aktifListeIdleri.contains(...)`) HICBIR
  // testte gecmiyordu -- onu silen mutant 749/749 yesil kalirdi. Bu iki test
  // O KOSULU ISIRIR (uygulama TEST-ONLY, urun degismedi).
  testWidgets(
    'K5 PAZARLIKSIZ: silinmis/yetim listeye isaretli gorev Gelen Kutusu\'nda GORUNUR -- kaybolmaz',
    (tester) async {
      final depo = _SahteDepo();
      addTearDown(depo.kapat);
      await tester.pumpWidget(
        MaterialApp(home: GorevListesiEkrani(depo: depo)),
      );
      depo.yayinlaListeler([_proje('p1', 'İş')]);
      depo.yayinla([
        _gorunum('g-inbox', 'Gelen Kutusu Gorevi'), // projeId: null
        _gorunum(
          'g-is',
          'İş Gorevi',
          projeId: 'p1',
        ), // pozitif kontrol -- GORUNMEMELI
        _gorunum(
          'g-yetim',
          'Yetim Gorevi',
          projeId: 'p-silinmis',
        ), // listelerde YOK
      ]);
      await tester.pump();

      // Gelen Kutusu (varsayilan baglam): projeId==null OLAN VE projeId
      // gecerli-liste-disi (yetim) olan gorevlerin IKISI DE gorunur.
      expect(find.text('Gelen Kutusu Gorevi'), findsOneWidget);
      expect(find.text('Yetim Gorevi'), findsOneWidget);
      // POZITIF KONTROL (pazarliksiz): gercek bir listeye ait gorev Gelen
      // Kutusu'nda GORUNMEMELI -- yoksa "hepsini goster" mutanti testi gecer.
      expect(find.text('İş Gorevi'), findsNothing);
    },
  );

  testWidgets(
    'K5/C4 PAZARLIKSIZ: secili liste baska cihazdan silinince ekran Gelen Kutusu\'na duser',
    (tester) async {
      final depo = _SahteDepo();
      addTearDown(depo.kapat);
      await tester.pumpWidget(
        MaterialApp(home: GorevListesiEkrani(depo: depo)),
      );
      depo.yayinlaListeler([_proje('p1', 'İş')]);
      depo.yayinla([
        _gorunum('g-inbox', 'Gelen Kutusu Gorevi'),
        _gorunum('g-is', 'İş Gorevi', projeId: 'p1'),
      ]);
      await tester.pump();

      // 'İş' listesini sec.
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('liste_p1')));
      await tester.pumpAndSettle();

      // Suzme GERCEKTEN calisti -- pozitif kontrol.
      expect(find.text('İş Gorevi'), findsOneWidget);
      expect(find.text('Gelen Kutusu Gorevi'), findsNothing);

      // Liste BASKA CIHAZDAN silindi -- listelerGorunur() artik p1'siz.
      depo.yayinlaListeler(const []);
      await tester.pumpAndSettle();

      // C4: ekran Gelen Kutusu'na duser -- artik yetim olan gorev GORUNUR.
      expect(find.text('İş Gorevi'), findsOneWidget);
      expect(find.text('Gelen Kutusu Gorevi'), findsOneWidget);

      // Drawer'da Gelen Kutusu SECILI gorunur (ikinci karar noktasi YOK --
      // `_etkinSecim` tek kaynak, C4 yorumu).
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      final gelenKutusuTile = tester.widget<ListTile>(
        find.byKey(const ValueKey('liste_gelen_kutusu')),
      );
      expect(gelenKutusuTile.selected, isTrue);
    },
  );
}
