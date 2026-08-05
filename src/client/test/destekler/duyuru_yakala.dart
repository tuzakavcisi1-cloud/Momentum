import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// GOREV-W2 T9 (denetim YB-8/BL-... `kanonik-kopya` onlemi): bu yardimci
/// ONCEDEN `a11y_kapisi_test.dart:62`'de OZEL (`_duyurulariYakala`) idi --
/// yeni bir test dosyasi (`w2_depolama_seridi_test.dart`, G40/f) onu import
/// EDEMEZDI ve kopyalamak zorunda kalirdi. Artik TEK KAYNAK burasidir.
///
/// `SystemChannels.accessibility`'i mock'lar; `SemanticsService.sendAnnouncement`
/// / `announce`'un GONDERDIGI dizgeleri yakalar (A11Y-7).
List<String> duyurulariYakala(WidgetTester tester) {
  final yakalanan = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (dynamic mesaj) async {
      final harita = mesaj as Map;
      if (harita['type'] == 'announce') {
        final veri = harita['data'] as Map;
        yakalanan.add(veri['message'] as String);
      }
      return null;
    },
  );
  return yakalanan;
}
