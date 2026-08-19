# IS-EMRI-o85A2 -- CEVAP (4 satir, s7)

## 1. A1 ve A2'nin tam test kodu (olduğu gibi, `test/liste_baglam_test.dart`e eklendi)

```dart
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
```

Destek: bu iki test `_SahteDepo.listelerGorunur()`nin `Stream.value([...])`den
`StreamController<List<Proje>>.broadcast()`e cevrilmesini gerektirdi (ikinci
deger yayinlanabilmesi icin); bu yuzden **mevcut D4 testi de** `depo.yayinlaListeler([_proje('p1','İş')])`
cagrisini almak zorunda kaldi (aksi halde ilk yayin kaybolur, D4 kirmizi olurdu)
-- `03-mutant-geri-alindi.txt`'te D4'un de yesil kaldigi goruluyor.

## 2. M1/M2 mutantlarinin tam diff'i + dusen test adi + hata satiri

**M1** (`lib/sunum/gorev_listesi_ekrani.dart`, K5 filtresi, ~satir 489-490):
```diff
-                        return g.gorev.projeId == null ||
-                            !aktifListeIdleri.contains(g.gorev.projeId);
+                        return g.gorev.projeId == null;
```
Dusen testler (ikisi de, `01-M1-kirmizi.txt`):
- `K5 PAZARLIKSIZ: silinmis/yetim listeye isaretli gorev Gelen Kutusu'nda GORUNUR -- kaybolmaz`
  -- `test/liste_baglam_test.dart:214` -- `Found 0 widgets with text "Yetim Gorevi"`
- `K5/C4 PAZARLIKSIZ: secili liste baska cihazdan silinince ekran Gelen Kutusu'na duser`
  -- `test/liste_baglam_test.dart:251` -- `Found 0 widgets with text "İş Gorevi"`

**M2** (`lib/sunum/gorev_listesi_ekrani.dart`, `_etkinSecim`):
```diff
   String? _etkinSecim(List<Proje> listeler) {
     final id = _secilenListeId;
-    if (id == null) return null;
-    return listeler.any((p) => p.id == id) ? id : null;
+    return id;
   }
```
Dusen test (`02-M2-kirmizi.txt`):
- `K5/C4 PAZARLIKSIZ: secili liste baska cihazdan silinince ekran Gelen Kutusu'na duser`
  -- `test/liste_baglam_test.dart:252` -- `Found 0 widgets with text "Gelen Kutusu Gorevi"`

Iki mutant da tek tek uygulanip GERI ALINDI; `03-mutant-geri-alindi.txt`
`git status --porcelain -- src/client/lib/sunum/gorev_listesi_ekrani.dart`in
**bos** dondugunu kanitlar (urun kodu byte-ozdes).

## 3. `flutter analyze` + `flutter test` (kosum dizini `src/client`)

`flutter analyze`: **No issues found!** (0 uyari/hata).

`flutter test test/liste_baglam_test.dart` (izole, tekrar-yankisiz):
**3/3 gecti**, exit 0 -- D4 + K5 (A1) + K5/C4 (A2).

`flutter test` (tam paket, mutant YOK, SB fix + A1/A2 + eski 748 dahil):
runner ozeti **`All tests passed!`**, sayac **751**, **exit 0**, basarisiz test
**YOK**. *Not (seffaflik):* tam paket kosumunda bazi dosyalarda (ornegin
`w2_depolama_seridi_test.dart`nin `G40/a`si, bu oturumdan ONCE de vardi) ayni
tanim satiri birden fazla kez basiliyor -- ortam/raporlayici kaynakli, izole
kosumda gorulmuyor, sonucu (0 basarisiz) ETKILEMIYOR.

## 4. `git status --porcelain -- src tests` (ham cikti)

```
 M src/client/lib/senkron/uzak_degisiklik_uygulayici.dart
 M src/client/test/liste_baglam_test.dart
```

`src/client/lib/sunum/gorev_listesi_ekrani.dart` **GORUNMUYOR** (§A test-only
korundu).
