@TestOn('vm')
library;

// GOREV-W2 T10 -- G42 (dikis kapisi, kaynak tarayan). @TestOn('vm')
// ZORUNLU: dart:io kullanir (a11y_statik_tasma_test.dart ile AYNI gerekce).
//
// TARAYICI SOZLESMESI (spec §5/G42, PAZARLIKSIZ): kaynak once YORUMLARDAN
// arindirilir (`//` VE `/* */`) ve arama YALNIZ `onResult` govdesi araliginda
// yapilir. POZITIF KONTROL: tarayici bugunku temiz kaynakta govdeyi (ve
// main.dart'taki iki cagriyi) BULAMAZSA kapi ORTAM HATASI verir, YESIL
// DEMEZ -- `ss2-kapisi.py`/`cors-kapisi.py`'nin bu SINIFTAN kor kaldigi
// olculmustu (spec §5/G42 dipnotu).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `//` VE `/* */` yorumlarini atar; dize icindeki `/`/`*` karakterlerini
/// YORUM SANMAZ (kacis dizisi de korunur). a11y_statik_tasma_test.dart'in
/// `//`-yalniz stripper'indan FARKLI -- G42 blok yorumu da gormek zorunda.
String _yorumsuzKaynak(String kaynak) {
  final tampon = StringBuffer();
  var i = 0;
  final n = kaynak.length;
  String? dizeSinirlayici;
  while (i < n) {
    final c = kaynak[i];
    if (dizeSinirlayici != null) {
      tampon.write(c);
      if (c == '\\' && i + 1 < n) {
        tampon.write(kaynak[i + 1]);
        i += 2;
        continue;
      }
      if (c == dizeSinirlayici) dizeSinirlayici = null;
      i++;
      continue;
    }
    if (c == "'" || c == '"') {
      dizeSinirlayici = c;
      tampon.write(c);
      i++;
      continue;
    }
    if (c == '/' && i + 1 < n && kaynak[i + 1] == '/') {
      while (i < n && kaynak[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '/' && i + 1 < n && kaynak[i + 1] == '*') {
      i += 2;
      while (i + 1 < n && !(kaynak[i] == '*' && kaynak[i + 1] == '/')) {
        if (kaynak[i] == '\n') tampon.write('\n');
        i++;
      }
      i += 2;
      continue;
    }
    tampon.write(c);
    i++;
  }
  return tampon.toString();
}

String _boslukSikistir(String metin) => metin.replaceAll(RegExp(r'\s+'), ' ');

/// `onResult:` anahtarindan sonraki ILK `{`'den baslayip parantez/suslu
/// derinligiyle ESLESEN `}`'ye kadar govdeyi doner. Bulamazsa `null` --
/// cagiran taraf bunu ORTAM HATASI olarak yorumlar (YESIL DEMEZ).
String? _onResultGovdesi(String yorumsuzKaynak) {
  final anahtarIndex = yorumsuzKaynak.indexOf('onResult:');
  if (anahtarIndex < 0) return null;
  final acilisIndex = yorumsuzKaynak.indexOf('{', anahtarIndex);
  if (acilisIndex < 0) return null;
  var derinlik = 0;
  for (var i = acilisIndex; i < yorumsuzKaynak.length; i++) {
    final c = yorumsuzKaynak[i];
    if (c == '{') derinlik++;
    if (c == '}') {
      derinlik--;
      if (derinlik == 0) {
        return yorumsuzKaynak.substring(acilisIndex + 1, i);
      }
    }
  }
  return null;
}

/// `cagriAdi(` sonrasi ILK acilis parantezinden ESLESEN kapanisa kadar
/// argumanlari doner (ic ice cagrilar da GUVENLIDIR -- derinlik sayaci).
String? _cagriGovdesi(String metin, String cagriAdi) {
  final index = metin.indexOf('$cagriAdi(');
  if (index < 0) return null;
  final acilisIndex = index + cagriAdi.length;
  var derinlik = 0;
  for (var i = acilisIndex; i < metin.length; i++) {
    final c = metin[i];
    if (c == '(') derinlik++;
    if (c == ')') {
      derinlik--;
      if (derinlik == 0) {
        return metin.substring(acilisIndex + 1, i);
      }
    }
  }
  return null;
}

void main() {
  late String veritabaniYorumsuz;
  late String mainYorumsuz;
  late String? onResultGovdesi;

  setUpAll(() {
    veritabaniYorumsuz = _yorumsuzKaynak(
      File('lib/veri/veritabani.dart').readAsStringSync(),
    );
    mainYorumsuz = _yorumsuzKaynak(File('lib/main.dart').readAsStringSync());
    onResultGovdesi = _onResultGovdesi(veritabaniYorumsuz);
  });

  group('G42 -- dikis kapisi (kaynak tarayan)', () {
    test(
      'POZITIF KONTROL — tarayici bugunku temiz kaynakta onResult govdesini bulur (ORTAM HATASI degilse)',
      () {
        expect(
          onResultGovdesi,
          isNotNull,
          reason:
              'ORTAM HATASI: onResult govdesi bulunamadi -- tarayici bozuk '
              'ya da kaynak yapisi degisti; kapi YESIL DEMEZ',
        );
        expect(
          onResultGovdesi!.trim(),
          isNotEmpty,
          reason: 'ORTAM HATASI: onResult govdesi bos dondu',
        );
      },
    );

    test(
      'G42/a — depolamaBildirimiYaz( cagrisi VAR ve argumanlari birebir '
      'sonuc.chosenImplementation.name / storageApi?.name okur',
      () {
        final govde = onResultGovdesi;
        if (govde == null) {
          fail('ORTAM HATASI: onResult govdesi yok, G42/a olculemez');
        }
        final cagriArgumanlari = _cagriGovdesi(govde, 'depolamaBildirimiYaz');
        expect(
          cagriArgumanlari,
          isNotNull,
          reason:
              'depolamaBildirimiYaz( cagrisi onResult govdesinde bulunamadi '
              '(silinmis olabilir -- M210 -- ya da yoruma alinmis olabilir '
              've bu yuzden yorumsuz kaynaktan TAMAMEN dusmus olabilir -- M216)',
        );
        final sikistirilmis = _boslukSikistir(cagriArgumanlari!);
        expect(
          sikistirilmis.contains('sonuc.chosenImplementation.name'),
          isTrue,
          reason:
              'cagri uygulamaAdi argumanini sonuc.chosenImplementation.name '
              'olarak OKUMUYOR (D-W2-8 argumanlari PAZARLIKSIZDIR -- M215)',
        );
        expect(
          sikistirilmis.contains('sonuc.chosenImplementation.storageApi?.name'),
          isTrue,
          reason:
              'cagri depolamaApi argumanini '
              'sonuc.chosenImplementation.storageApi?.name olarak OKUMUYOR '
              '(D-W2-8 argumanlari PAZARLIKSIZDIR -- M215)',
        );
      },
    );

    test(
      'G42/b — MOMENTUM-G6-KANIT print satiri onResult govdesinde hala VAR',
      () {
        final govde = onResultGovdesi;
        if (govde == null) {
          fail('ORTAM HATASI: onResult govdesi yok, G42/b olculemez');
        }
        expect(
          govde.contains('MOMENTUM-G6-KANIT'),
          isTrue,
          reason:
              'MOMENTUM-G6-KANIT print satiri onResult govdesinden '
              'KAYBOLMUS -- W1/G37 kanit zincirini kirar (D-W2-6, M211)',
        );
      },
    );

    test(
      "G42/c — main.dart bildirimi hem Veritabani'na hem "
      'GorevListesiEkrani(depolama:)\'na gecirir',
      () {
        final sikistirilmis = _boslukSikistir(mainYorumsuz);

        final veritabaniCagrisi = _cagriGovdesi(sikistirilmis, 'Veritabani');
        expect(
          veritabaniCagrisi,
          isNotNull,
          reason: "ORTAM HATASI: main.dart icinde Veritabani( cagrisi bulunamadi",
        );
        expect(
          RegExp(r'\bdepolamaBildirimi\b').hasMatch(veritabaniCagrisi!),
          isTrue,
          reason: "Veritabani( cagrisi depolamaBildirimi argumanini TASIMIYOR",
        );

        final ekranCagrisi = _cagriGovdesi(sikistirilmis, 'GorevListesiEkrani');
        expect(
          ekranCagrisi,
          isNotNull,
          reason:
              "ORTAM HATASI: main.dart icinde GorevListesiEkrani( cagrisi "
              "bulunamadi",
        );
        expect(
          RegExp(r'depolama\s*:\s*depolama\b').hasMatch(ekranCagrisi!),
          isTrue,
          reason:
              "GorevListesiEkrani( cagrisi depolama: parametresini "
              "bildirime BAGLAMIYOR (main.dart'ta bildirim ekrana "
              "gecirilmiyor -- M212)",
        );
      },
    );
  });
}
