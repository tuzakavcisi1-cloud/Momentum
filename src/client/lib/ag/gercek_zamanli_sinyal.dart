/// GOREV-slice-3e T1: gercek zamanli sinyal tasima soyutlamasi -- `SenkronAgi`
/// ile AYNI desen (bkz. senkron_agi.dart): uretim uygulamasi bunun ARKASINDA
/// durur, testler deterministik bir sahte enjekte eder. Tasima tipi
/// (WebSocket, SignalR, hicbiri) bu dosyada GECMEZ.
sealed class SinyalOlayi {
  const SinyalOlayi();
}

/// Sunucu `Changed` yayinladi -- YUKSUZ. Icerik tasimaz, tasimamalidir
/// (K77/6: `SignalEnvelope` govdesi bos, `CursorHint` yoksayilir).
class SinyalDegisiklik extends SinyalOlayi {
  const SinyalDegisiklik();
}

/// (Yeniden) baglanti kuruldu -- K77/2: kopukken kacan sinyaller icin BIR
/// cekme turu tetikler.
class SinyalBaglandi extends SinyalOlayi {
  const SinyalBaglandi();
}

abstract class GercekZamanliSinyal {
  Stream<SinyalOlayi> get olaylar;
  Future<void> baslat();
  Future<void> durdur();
}
