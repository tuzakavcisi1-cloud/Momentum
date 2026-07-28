// GOREV-slice-3d G4 -- LWW KARSILASTIRMA KAPISI (Dart birim testi, saf sinif).
// Ag/DB YOK.

import 'dart:math';

import 'package:client/senkron/alan_anahtari.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('D3: wallMs farkli -- buyuk wallMs kazanir', () {
    final a = AlanAnahtari(wall: 100, counter: 5, clientId: 'c1', opId: 'o1');
    final b = AlanAnahtari(wall: 200, counter: 0, clientId: 'c1', opId: 'o1');
    expect(kazandiMi(b, a), isTrue);
    expect(kazandiMi(a, b), isFalse);
  });

  test('D3: wallMs esit, counter farkli -- buyuk counter kazanir', () {
    final a = AlanAnahtari(wall: 100, counter: 1, clientId: 'c1', opId: 'o1');
    final b = AlanAnahtari(wall: 100, counter: 2, clientId: 'c1', opId: 'o1');
    expect(kazandiMi(b, a), isTrue);
    expect(kazandiMi(a, b), isFalse);
  });

  test('D3: wallMs+counter esit, clientId farkli -- tiresiz kucuk harf hex ordinal sirasi', () {
    final a = AlanAnahtari(wall: 100, counter: 0, clientId: '00000000-0000-0000-0000-000000000001', opId: 'o1');
    final b = AlanAnahtari(wall: 100, counter: 0, clientId: '00000000-0000-0000-0000-000000000002', opId: 'o1');
    expect(kazandiMi(b, a), isTrue, reason: '...02 > ...01 normalize hex sirasinda');
    expect(kazandiMi(a, b), isFalse);
  });

  test('D3: clientId RAW (tireli/karisik-buyuk-kucuk) sira ile NORMALIZE sira FARKLI sonuc verir -- beklenen NORMALIZE', () {
    // RAW (case-duyarli) karsilastirmada: 'A'(0x41) < 'a'(0x61) ⇒ B'nin
    // baslangici (buyuk harf 'A') A'nin baslangicindan (kucuk harf 'a')
    // KUCUK sayilir -- B raw'da A'dan ONCE gelir.
    // NORMALIZE (kucuk harf) karsilastirmada: ikisi de "a..." ile baslar,
    // ikinci hane '0' vs '1' -- A normalize'de B'den ONCE gelir.
    // Iki sira TERSTIR; dogru kod DAIMA normalize'i kullanir.
    const rawA = 'a0000000-0000-0000-0000-000000000000';
    const rawB = 'A1000000-0000-0000-0000-000000000000';

    final rawKarsilastirma = rawB.compareTo(rawA); // case-duyarli, YANLIS yontem
    expect(rawKarsilastirma, lessThan(0), reason: 'on kosul: RAW karsilastirmada B < A (test kendi varsayimini dogrular)');

    final anahtarA = AlanAnahtari(wall: 100, counter: 0, clientId: rawA, opId: 'o1');
    final anahtarB = AlanAnahtari(wall: 100, counter: 0, clientId: rawB, opId: 'o1');
    // normalize edilmis (kucuk harf, tiresiz) sirada A < B -- yani B kazanir.
    expect(kazandiMi(anahtarB, anahtarA), isTrue, reason: 'NORMALIZE sirada B > A olmali (RAW sira bunun TERSIYDI)');
    expect(kazandiMi(anahtarA, anahtarB), isFalse);
  });

  test('D3: anahtarin TAMAMI esit -- mevcut KORUNUR (kesin buyukluk)', () {
    final a = AlanAnahtari(wall: 100, counter: 5, clientId: 'c1', opId: 'o1');
    final b = AlanAnahtari(wall: 100, counter: 5, clientId: 'c1', opId: 'o1');
    expect(kazandiMi(b, a), isFalse, reason: 'esit anahtarda mevcut korunmali (> degil >=)');
  });

  test('D3: HLC esit, opId farkli -- opId tiresiz ordinal sirasi tie-break', () {
    final a = AlanAnahtari(wall: 100, counter: 0, clientId: 'c1', opId: '00000000-0000-0000-0000-000000000001');
    final b = AlanAnahtari(wall: 100, counter: 0, clientId: 'c1', opId: '00000000-0000-0000-0000-000000000002');
    expect(kazandiMi(b, a), isTrue);
    expect(kazandiMi(a, b), isFalse);
  });

  test('D3: 200 rastgele cift -- Dart compareTo sunucu-esdeger ordinal sirayla BIREBIR AYNI', () {
    final rnd = Random(42);
    String rastgeleHexGuid() {
      final baytlar = List<int>.generate(16, (_) => rnd.nextInt(256));
      String hex(int a, int z) => baytlar.sublist(a, z).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
    }

    for (var i = 0; i < 200; i++) {
      final wallA = rnd.nextInt(1000);
      final wallB = rnd.nextInt(1000);
      final counterA = rnd.nextInt(10);
      final counterB = rnd.nextInt(10);
      final clientA = rastgeleHexGuid();
      final clientB = rastgeleHexGuid();
      final opA = rastgeleHexGuid();
      final opB = rastgeleHexGuid();

      final a = AlanAnahtari(wall: wallA, counter: counterA, clientId: clientA, opId: opA);
      final b = AlanAnahtari(wall: wallB, counter: counterB, clientId: clientB, opId: opB);

      // "Sunucu-esdeger" beklenen sira: normHex uzerinde String.compareTo
      // (CompareOrdinal ile aynidir) -- alan_anahtari.dart'in DISINDA,
      // BAGIMSIZ elle yazilmis bir karsilastirma.
      int beklenenSira;
      if (wallA != wallB) {
        beklenenSira = wallA.compareTo(wallB);
      } else if (counterA != counterB) {
        beklenenSira = counterA.compareTo(counterB);
      } else {
        final ch = normHex(clientA).compareTo(normHex(clientB));
        beklenenSira = ch != 0 ? ch : normHex(opA).compareTo(normHex(opB));
      }

      final gercekSira = a.compareTo(b);
      final gercekIsaret = gercekSira == 0 ? 0 : (gercekSira > 0 ? 1 : -1);
      final beklenenIsaret = beklenenSira == 0 ? 0 : (beklenenSira > 0 ? 1 : -1);
      expect(gercekIsaret, beklenenIsaret, reason: 'cift $i: a=$a b=$b');
    }
  });
}
