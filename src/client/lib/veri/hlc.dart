/// Tel bicimindeki HLC (GOREV-slice-3c D3/D7): `{wallMs, counter, clientId}`.
/// Sunucunun `WireHlc(WallMs, Counter, ClientId)`'siyle birebir eslesir.
class Hlc {
  final int wallMs;
  final int counter;
  final String clientId;

  const Hlc({required this.wallMs, required this.counter, required this.clientId});

  Map<String, Object?> toJson() => {
    'wallMs': wallMs,
    'counter': counter,
    'clientId': clientId,
  };

  factory Hlc.fromJson(Map<String, Object?> json) => Hlc(
    wallMs: json['wallMs'] as int,
    counter: json['counter'] as int,
    clientId: json['clientId'] as String,
  );
}

/// GOREV-slice-3c D3: monoton + TAVANLI HLC ureteci. Tavan
/// (`HlcClamp.MaxForwardSkewMs` ile AYNI deger, 300000ms/5dk) sunucunun
/// kirpma tavanidir -- cihaz saati ileri kacsa bile uretilen damga bu tavani
/// ASLA asmaz. Tavansiz bir `max(now, sonWall)` saatin BIR KEZ ileri
/// alinmasiyla cihazi kalici senkron-disi birakir (D3 kirmizi uyari); bu
/// yuzden tavan HER cagrida GUNCEL `simdiMs()`'den yeniden hesaplanir --
/// `sonWall` gecmiste ne kadar ileri surukmus olursa olsun, tavan onu asla
/// takip etmez.
///
/// Saf/senkron ve saat enjekte edilebilir (G4 kapisi): DB'ye DOKUNMAZ --
/// kalicilastirma cagiranin sorumlulugundadir (D8: kuyruk/Gorevler ile ayni
/// transaction icinde islenecekse cagiran o transaction icinde yazar).
class HlcUretici {
  static const int tavanMs = 300000; // HlcClamp.MaxForwardSkewMs ile AYNI deger

  final int Function() simdiMs;
  final String clientId;
  int sonWall;
  int sonCounter;

  HlcUretici({
    required this.simdiMs,
    required this.clientId,
    this.sonWall = 0,
    this.sonCounter = 0,
  });

  /// D3 `sonrakiHlc(now)`: bir sonraki HLC'yi uretir VE ic durumu ilerletir.
  ///
  /// K65 (Onur, kilitli): `counter` wall degismese de degisse de HER
  /// cagrida artar -- eski "wall==sonWall ise artir, degilse 0'a don"
  /// kurali sunucunun receive-time kirpmasiyla ETKILESIYORDU: sunucu ayni
  /// istekteki iki alan-HLC'sini `receiveWall+5dk`'ya kirpinca ikisi de
  /// AYNI clamp'lenmis damgaya dusuyor, tie-break `opId` dize-ordinaline
  /// kaliyor -- opId rastgele UUID v4 oldugu icin bu bir YAZI-TURA'ya
  /// donusuyordu (%50 kayip). `counter`in HER damgada kesin artmasi + opId
  /// uretecinin UUIDv7'ye (zaman-sirali, bkz. `uretimIdUret()`) gecmesi
  /// birlikte bu carpismayi KAYNAGINDA kesiyor.
  Hlc sonrakiHlc() {
    final now = simdiMs();
    final tavan = now + tavanMs;
    final ileri = now > sonWall ? now : sonWall; // max(now, sonWall)
    final wall = ileri < tavan ? ileri : tavan; // min(ileri, tavan)
    final counter = sonCounter + 1;
    sonWall = wall;
    sonCounter = counter;
    return Hlc(wallMs: wall, counter: counter, clientId: clientId);
  }

  /// D3 `yanitIsle(serverHlc, effectiveOpHlc)`: her senkron turundan sonra
  /// sunucu damgalarini birlestirir -- yalniz ileri tasir, asla geri almaz.
  void yanitIsle({Hlc? serverHlc, Hlc? effectiveOpHlc}) {
    for (final h in [serverHlc, effectiveOpHlc]) {
      if (h != null && h.wallMs > sonWall) {
        sonWall = h.wallMs;
        sonCounter = h.counter;
      }
    }
  }
}
