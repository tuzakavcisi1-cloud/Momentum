import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'gercek_zamanli_sinyal.dart';

/// GOREV-slice-3e-G12 T1: kanal acici soyutlamasi -- uretimde `null` ⇒
/// `IOWebSocketChannel.connect` (davranis DEGISMEZ), testte sahte bir
/// `WebSocketChannel` enjekte edilebilir (K79/5: sahte TASIMA, gercek
/// PROTOKOL).
typedef KanalAcici = WebSocketChannel Function(Uri url, Map<String, String> basliklar);

/// GOREV-slice-3e T2: SignalR JSON hub protokolunun YALNIZ gereken alt
/// kumesi -- K77/1 PAZARLIKSIZ: kendi minimal istemcimiz, `signalr_netcore`
/// KULLANILMAZ (gerekce GOREV K77/1 -- alti gecisli bagimlilik + kutuphanenin
/// kendi yeniden-baglanma politikasi). Kayit ayraci `` (0x1E, RS).
///
/// `dart:io` `WebSocket`e dayanir (K77/3: yalniz Android+Windows: `web`
/// hedefi bu dosyayla DOGRULANMAMISTIR -- tarayici WS upgrade'ine ozel
/// baslik koyamaz, ayrinti GOREV-slice-3e-iskelet.md K77/3).
class SignalrJsonSinyal implements GercekZamanliSinyal {
  static const String _devKullaniciBasligi = 'X-Momentum-Dev-User';
  static const String _kayitAyraci = '';
  static const Duration _keepaliveAraligi = Duration(seconds: 15);
  static const Duration _elSikismaZamanAsimi = Duration(seconds: 10);

  /// K77/2 PAZARLIKSIZ: 1s -> 2s -> 4s -> 8s -> 16s -> 30s tavan, +-%20
  /// jitter. Bu zamanlayici VERI CEKMEZ, yalniz BAGLANMAYI dener; veri
  /// cekmenin tetikleyicisi `Changed` olayi ya da baglanma olayidir.
  static const List<Duration> _geriCekilmeCizelgesi = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 16),
    Duration(seconds: 30),
  ];

  final String sunucuTabanUrl;
  final String actorId;
  final Duration negotiateZamanAsimi;
  final Duration baglantiZamanAsimi;
  final http.Client _http;
  final Random _rastgele;
  final KanalAcici? _kanalAcici;

  /// Taninmayan cerceve/mesaj tipi ve close olaylari SESSIZ YUTULMAZ (T2/5)
  /// -- varsayilan `print`, G12 oncesi tek kanal; test gozlemci enjekte eder.
  final void Function(String mesaj) gunlukYaz;

  final StreamController<SinyalOlayi> _denetleyici =
      StreamController<SinyalOlayi>.broadcast();

  WebSocketChannel? _kanal;
  StreamSubscription<Object?>? _abonelik;
  Timer? _keepaliveZamanlayicisi;
  Timer? _yenidenBaglanmaZamanlayicisi;
  int _geriCekilmeIndeksi = 0;
  bool _durduruldu = true;
  bool _kapatmaIslemde = false;
  bool _durdurCagrildi = false;

  SignalrJsonSinyal({
    required this.sunucuTabanUrl,
    required this.actorId,
    http.Client? istemci,
    Random? rastgele,
    void Function(String mesaj)? gunlukYaz,
    KanalAcici? kanalAcici,
    this.negotiateZamanAsimi = const Duration(seconds: 10),
    this.baglantiZamanAsimi = const Duration(seconds: 10),
  })  : _http = istemci ?? http.Client(),
        _rastgele = rastgele ?? Random(),
        // `this._kanalAcici` parametre adini da PRIVATE yapardi, disaridan
        // `kanalAcici:` adlandirilmis argumanla cagrilamaz hale gelirdi
        // (bkz. senkron_dongusu.dart:1).
        // ignore: prefer_initializing_formals
        _kanalAcici = kanalAcici,
        gunlukYaz = gunlukYaz ?? _varsayilanGunlukYaz;

  static void _varsayilanGunlukYaz(String mesaj) {
    // ignore: avoid_print -- T2/5 "SESSIZ DEGIL"; G12'de gercek loglayiciya baglanir.
    print('[sinyal] $mesaj');
  }

  @override
  Stream<SinyalOlayi> get olaylar => _denetleyici.stream;

  @override
  Future<void> baslat() async {
    // G12/T3 PAZARLIKSIZ (K79/2): web'de HIC baglanmaz -- IOWebSocketChannel
    // dart:io'ya dayanir + WS upgrade'ine ozel baslik konamaz (K77/3).
    // `_durduruldu` TRUE KALIR ki sonraki cagrilar da sessizce donsun ve
    // HICBIR zamanlayici kurulmasin.
    if (kIsWeb) {
      gunlukYaz('web: gercek zamanli sinyal KAPALI (K79/2) -- elle yenileme tek yol');
      return;
    }
    if (!_durduruldu) return; // zaten baslatilmis -- idempotent.
    _durduruldu = false;
    unawaited(_baglanmayiDene());
  }

  /// K77/2: cagirildiktan SONRA yeniden baglanma DENENMEZ.
  /// G12/T2 PAZARLIKSIZ: IDEMPOTENT -- ikinci cagri PATLAMAZ (sessizce doner).
  /// `_denetleyici` de burada kapatilir (once hic kapanmiyordu, K79/0).
  @override
  Future<void> durdur() async {
    if (_durdurCagrildi) return;
    _durdurCagrildi = true;
    _durduruldu = true;
    _yenidenBaglanmaZamanlayicisi?.cancel();
    _yenidenBaglanmaZamanlayicisi = null;
    await _kanaliKapat();
    await _denetleyici.close();
  }

  /// G12 T4 ile OLCULDU (A11, `fakeAsync` altinda): bir abonenin `cancel()`ini
  /// KENDI olay teslimati icinden -- sync:true ic kanal kuran
  /// `AdapterWebSocketChannel` uzerinden, uretimin `IOWebSocketChannel`i de
  /// BUNA dayanir -- cagirmak, dondugu Future'in fakeAsync sanal saatinde HIC
  /// tamamlanmamasina yol aciyor (gercek/`fakeAsync`-DISI kosumda GOZLENMEDI,
  /// A4 kaniti). Sebep tam olarak DOGRULANMADI ama duzeltme BAGIMSIZ SAGLAM:
  /// `cancel()` cagrildigi ANDA gelecek olay teslimini durdurur, dondugu
  /// Future'in NE ZAMAN tamamlandigina bagli hicbir mantik YOK -- bu yuzden
  /// `_kanaliKapat` artik BEKLENMEZ (fire-and-forget, bkz. `_baglantiKoptu`);
  /// eski kaynaklarin serbest kalmasi yeniden baglanma ZAMANLAMASINI geciktirmez.
  Future<void> _kanaliKapat() async {
    _keepaliveZamanlayicisi?.cancel();
    _keepaliveZamanlayicisi = null;
    final abonelik = _abonelik;
    _abonelik = null;
    unawaited(abonelik?.cancel());
    final kanal = _kanal;
    _kanal = null;
    try {
      await kanal?.sink.close();
    } catch (_) {
      // kapanistaki hata yeniden-baglanma denemesini ENGELLEMEZ.
    }
  }

  Future<void> _baglanmayiDene() async {
    if (_durduruldu) return;
    _kapatmaIslemde = false; // YENI deneme -- bu denemenin KENDI kopusu tekrar islenebilsin.
    try {
      final connectionToken = await _negotiate();
      if (_durduruldu) return;
      final kanal = _websocketAc(connectionToken);
      _kanal = kanal;
      await kanal.ready.timeout(baglantiZamanAsimi);
      await _elSikismaYapVeDinlemeyeBasla(kanal);
      if (_durduruldu) return;
      _geriCekilmeIndeksi = 0; // basarili baglanma -- cizelge sifirlanir.
      gunlukYaz('el sikisma basarili -- SinyalBaglandi yayinlaniyor');
      _denetleyici.add(const SinyalBaglandi());
      _keepaliveBaslat(kanal);
    } catch (hata) {
      _baglantiKoptu('baglanma denemesi basarisiz: $hata');
    }
  }

  /// T2/1: negotiate. 401 (ya da baska 200-disi kod) ⇒ bagli DEGIL, sessiz
  /// yeniden deneme YOK -- catch zincirinden `_baglantiKoptu`ya, oradan da
  /// geri cekilme cizelgesine duser.
  Future<String> _negotiate() async {
    final url = Uri.parse('$sunucuTabanUrl/hubs/sync/negotiate')
        .replace(queryParameters: {'negotiateVersion': '1'});
    final yanit = await _http
        .post(url, headers: {_devKullaniciBasligi: actorId})
        .timeout(negotiateZamanAsimi);
    if (yanit.statusCode != 200) {
      throw StateError('negotiate basarisiz: HTTP ${yanit.statusCode}');
    }
    final govde = jsonDecode(yanit.body) as Map<String, Object?>;
    final token = govde['connectionToken'] as String?;
    if (token == null || token.isEmpty) {
      throw StateError('negotiate yanitinda connectionToken yok');
    }
    return token;
  }

  /// T2/2: ayni baslikla WS baglantisi -- http(s) -> ws(s).
  /// G12/T1: acici enjekte edilmisse ONU kullanir; uretimde (`null`) davranis
  /// AYNEN korunur -- `IOWebSocketChannel.connect`.
  WebSocketChannel _websocketAc(String connectionToken) {
    final wsTaban = _wsTabaniniTuret(sunucuTabanUrl);
    final url = Uri.parse('$wsTaban/hubs/sync?id=$connectionToken');
    final basliklar = {_devKullaniciBasligi: actorId};
    return (_kanalAcici ?? _varsayilanKanalAc)(url, basliklar);
  }

  static WebSocketChannel _varsayilanKanalAc(
    Uri url,
    Map<String, String> basliklar,
  ) => IOWebSocketChannel.connect(url, headers: basliklar);

  static String _wsTabaniniTuret(String httpTaban) {
    if (httpTaban.startsWith('https://')) {
      return 'wss://${httpTaban.substring('https://'.length)}';
    }
    if (httpTaban.startsWith('http://')) {
      return 'ws://${httpTaban.substring('http://'.length)}';
    }
    throw ArgumentError(
      'desteklenmeyen sema (http/https bekleniyor): $httpTaban',
    );
  }

  /// T2/3: el sikisma gonderilir, ILK yanit beklenir; basariliysa AYNI
  /// abonelik T2/5'in mesaj dongusune donusur (ikinci bir subscribe YOK).
  Future<void> _elSikismaYapVeDinlemeyeBasla(WebSocketChannel kanal) async {
    final elSikismaTamam = Completer<void>();
    var elSikismaBitti = false;

    _abonelik = kanal.stream.listen(
      (mesaj) {
        List<String> parcalar;
        try {
          parcalar = _cerceveyiAyir(mesaj as String);
        } catch (hata) {
          gunlukYaz('cozulmeyen cerceve YUTULDU (sessiz degil): $mesaj ($hata)');
          return;
        }
        for (final parca in parcalar) {
          if (!elSikismaBitti) {
            elSikismaBitti = true;
            final hataMesaji = _elSikismaYanitiDogrula(parca);
            if (hataMesaji != null) {
              if (!elSikismaTamam.isCompleted) {
                elSikismaTamam.completeError(StateError(hataMesaji));
              }
              return;
            }
            if (!elSikismaTamam.isCompleted) elSikismaTamam.complete();
            continue; // bu parca el sikisma yanitiydi, mesaj DEGIL.
          }
          if (_tekMesajiIsle(parca)) return; // type==7: kalan parcalar islenmez.
        }
      },
      onError: (Object hata) => _baglantiKoptu('kanal hatasi: $hata'),
      onDone: () => _baglantiKoptu('kanal kapandi (onDone)'),
      cancelOnError: true,
    );

    kanal.sink.add('{"protocol":"json","version":1}$_kayitAyraci');
    await elSikismaTamam.future.timeout(_elSikismaZamanAsimi);
  }

  String? _elSikismaYanitiDogrula(String parca) {
    if (parca.isEmpty) return 'bos el sikisma yaniti';
    Map<String, Object?> govde;
    try {
      govde = jsonDecode(parca) as Map<String, Object?>;
    } catch (hata) {
      return 'el sikisma yaniti cozulemedi: $hata';
    }
    if (govde.containsKey('error')) {
      return 'el sikisma hatasi: ${govde['error']}';
    }
    return null;
  }

  /// T2/5: mesaj dongusu. Doner: `true` ⇔ type==7 (close) -- cagiran KALAN
  /// parcalari islemeyi durdurur (baglanti zaten kapatiliyor).
  bool _tekMesajiIsle(String parca) {
    if (parca.isEmpty) return false;
    Map<String, Object?> mesaj;
    try {
      mesaj = jsonDecode(parca) as Map<String, Object?>;
    } catch (hata) {
      gunlukYaz('cozulmeyen mesaj YUTULDU (sessiz degil): $parca ($hata)');
      return false;
    }
    final tip = mesaj['type'];
    switch (tip) {
      case 1:
        // K77/6 PAZARLIKSIZ: `arguments` ICERIGI OKUNMAZ -- sinyal yalniz
        // uyandirma zilidir, `CursorHint` yoksayilir.
        if (mesaj['target'] == 'Changed') {
          gunlukYaz('Changed alindi -- SinyalDegisiklik yayinlaniyor');
          _denetleyici.add(const SinyalDegisiklik());
        } else {
          gunlukYaz('taninmayan invocation hedefi YUTULDU: ${mesaj['target']}');
        }
        return false;
      case 6:
        return false; // sunucu ping'i -- yut.
      case 7:
        gunlukYaz('sunucu close gonderdi: ${mesaj['error']}');
        _baglantiKoptu('sunucu close: ${mesaj['error']}');
        return true;
      default:
        gunlukYaz('taninmayan mesaj tipi YUTULDU (sessiz degil): $tip');
        return false;
    }
  }

  /// T2/6 PAZARLIKSIZ: bu bir PROTOKOL keepalive'idir, YOKLAMA DEGILDIR --
  /// `/v1/sync`e DOKUNMAZ, yalniz WS uzerinden `{"type":6}` gonderir.
  void _keepaliveBaslat(WebSocketChannel kanal) {
    _keepaliveZamanlayicisi?.cancel();
    _keepaliveZamanlayicisi = Timer.periodic(_keepaliveAraligi, (_) {
      try {
        kanal.sink.add('{"type":6}$_kayitAyraci');
      } catch (_) {
        // gonderim hatasi -- onError/onDone zaten kopusu yakalayacak.
      }
    });
  }

  /// T2/7: baglanti koptugunda kanal kapatilir ve -- `durdur()` cagirilmadiysa
  /// -- geri cekilme cizelgesiyle yeniden baglanma PLANLANIR. G12 ile
  /// OLCULDU: eski kanalin temizligi (`_kanaliKapat`) ARTIK BEKLENMEZ --
  /// yeniden baglanma ZAMANLAMASI ona bagli DEGILDIR (bkz. `_kanaliKapat`
  /// dokumantasyonu). `_kapatmaIslemde` bir sonraki `_baglanmayiDene()`
  /// baslayana kadar `true` kalir -- ayni kopusun GEC gelen ikinci bildirimi
  /// (ör. eski abonenin gecikmis `onDone`'u) ikinci bir tur PLANLAMAZ.
  void _baglantiKoptu(String neden) {
    if (_kapatmaIslemde) return; // ayni kopusun ikinci bildirimi -- yut.
    _kapatmaIslemde = true;
    gunlukYaz('baglanti koptu: $neden');
    unawaited(_kanaliKapat());
    if (!_durduruldu) _yenidenBaglanmayiPlanla();
  }

  void _yenidenBaglanmayiPlanla() {
    final indeks = min(_geriCekilmeIndeksi, _geriCekilmeCizelgesi.length - 1);
    final tabanGecikme = _geriCekilmeCizelgesi[indeks];
    _geriCekilmeIndeksi++;
    final jitterCarpani = 1 + (_rastgele.nextDouble() * 0.4 - 0.2); // +-%20
    _yenidenBaglanmaZamanlayicisi = Timer(tabanGecikme * jitterCarpani, () {
      unawaited(_baglanmayiDene());
    });
  }

  List<String> _cerceveyiAyir(String cerceve) {
    final parcalar = cerceve.split(_kayitAyraci);
    // SignalR JSON protokolu HER mesaji ayracla BITIRIR -- son parca bu
    // yuzden hep bos string'tir, atilir.
    if (parcalar.isNotEmpty && parcalar.last.isEmpty) {
      parcalar.removeLast();
    }
    return parcalar;
  }
}
