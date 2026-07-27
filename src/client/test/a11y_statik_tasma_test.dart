@TestOn('vm')
library;

// G5 -- A11Y-4 STATIK YARISI: "kirpma sessizdir" (Z16/spec SS5 G5). Bir
// Text() dugumu textScaler 2.0 altinda GORUNMEDEN kirpilabilir -- bu, calisan
// bir widget testinin YAKALAYAMAYACAGI bir sessizlik turudur. Bu yuzden
// lib/sunum ve lib/vitrin kaynagi dogrudan TARANIR.
//
// OLCULMUS KURAL [M16'nin ogrettigi]: 'maxLines VARLIGI' TEK BASINA yeterli
// DEGILDIR -- maxLines, overflow:ellipsis OLMADAN verilirse Flutter'in
// VARSAYILANI TextOverflow.clip'tir: metin "..." GOSTERMEDEN SESSIZCE kirpilir.
// Bu yuzden ZORUNLU olan overflow: TextOverflow.ellipsis'in KENDISIDIR (maxLines
// bunun YERINE GECMEZ, onunla BIRLIKTE kullanilabilir). dart:io kullanir --
// @TestOn('vm') PAZARLIKSIZDIR (web'de dart:io yok).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib/sunum ve lib/vitrin altindaki her Text( cagrisi korunakli (overflow/maxLines)', () {
    final kok = Directory('lib');
    final dosyalar = <File>[
      ...Directory('${kok.path}/sunum').listSync(recursive: true).whereType<File>(),
      ...Directory('${kok.path}/vitrin').listSync(recursive: true).whereType<File>(),
    ].where((f) => f.path.endsWith('.dart')).toList();

    expect(dosyalar, isNotEmpty, reason: 'lib/sunum + lib/vitrin taranacak dosya bulunamadi');

    final korunmasizlar = <String>[];
    final textCagrisi = RegExp(r'\bText(\.rich)?\s*\(');

    for (final dosya in dosyalar) {
      final satirlar = dosya.readAsLinesSync();
      for (var i = 0; i < satirlar.length; i++) {
        if (!textCagrisi.hasMatch(satirlar[i])) continue;
        // Text(...) cagrisi genelde birden fazla satira yayilir -- kapanan
        // parantezi bulana kadar (basit derinlik sayaci ile) govdeyi topla.
        var derinlik = 0;
        var basladi = false;
        final govde = StringBuffer();
        for (var j = i; j < satirlar.length && j < i + 25; j++) {
          final satir = satirlar[j];
          govde.writeln(satir);
          for (final ch in satir.split('')) {
            if (ch == '(') {
              derinlik++;
              basladi = true;
            } else if (ch == ')') {
              derinlik--;
            }
          }
          if (basladi && derinlik <= 0) break;
        }
        final metin = govde.toString();
        // maxLines TEK BASINA YETMEZ (M16): overflow:ellipsis OLMADAN maxLines,
        // Flutter varsayilani TextOverflow.clip'e duser -- SESSIZ kirpma.
        final korunakli = metin.contains('TextOverflow.ellipsis');
        if (!korunakli) {
          korunmasizlar.add('${dosya.path}:${i + 1}: ${satirlar[i].trim()}');
        }
      }
    }

    expect(
      korunmasizlar,
      isEmpty,
      reason:
          'Asagidaki Text() cagrilari overflow: TextOverflow.ellipsis tasimiyor -- '
          'textScaler 2.0 altinda SESSIZCE kirpilabilir (A11Y-4, M16):\n'
          '${korunmasizlar.join('\n')}',
    );
  });

  test(
    'metin: F6 dizgeleri lib/sunum + lib/vitrin icinde HAM LITERAL olarak TEKRARLANMAMIS '
    '(tek kaynak metinler.dart -- M10)',
    () {
      // Widget testleri GORUNEN metni Metinler.X ile karsilastirir (find.text) --
      // ama bir bilesen AYNI degeri ham dizge olarak yazsa gorunum FARK ETMEZ,
      // yalniz KAYNAK TARAMASI yakalar. Bu, M10'un ("Metinler.bosDurum yerine
      // duz dizge yaz") tek mekanik kapisidir.
      const f6Dizgeleri = <String>[
        'Yalnızca bu cihazda',
        'Gönderiliyor',
        'Çevrimdışısınız. Değişiklikler kaydedildi.',
        'Bu görev başka bir cihazda da değişti.',
        'Henüz görev yok. Aşağıdan ekleyin.',
        'Bir şeyler ters gitti.',
        'Yeniden dene',
        'Yükleniyor',
        'Görevler yükleniyor',
        'Senkronize edildi',
        'Çevrimdışı',
        'Çakışma var',
        'Hata',
      ];

      final dosyalar = <File>[
        ...Directory('lib/sunum').listSync(recursive: true).whereType<File>(),
        ...Directory('lib/vitrin').listSync(recursive: true).whereType<File>(),
      ].where((f) => f.path.endsWith('.dart'));

      final kacaklar = <String>[];
      for (final dosya in dosyalar) {
        // Yorum satirlarini (// ve ///) at -- dogal dilde bahsetme, KOD DEGIL.
        final govde = dosya
            .readAsLinesSync()
            .map((s) => s.contains('//') ? s.substring(0, s.indexOf('//')) : s)
            .join('\n');
        for (final s in f6Dizgeleri) {
          if (govde.contains("'$s'") || govde.contains('"$s"')) {
            kacaklar.add('${dosya.path}: "$s" ham dizge olarak gecıyor');
          }
        }
      }

      expect(
        kacaklar,
        isEmpty,
        reason:
            'F6 dizgeleri YALNIZ lib/design/metinler.dart\'ta yasamali; '
            'asagidaki dosyalarda HAM LITERAL olarak tekrarlanmis:\n'
            '${kacaklar.join('\n')}',
      );
    },
  );
}
