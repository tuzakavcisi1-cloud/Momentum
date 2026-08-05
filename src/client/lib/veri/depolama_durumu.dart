import 'package:flutter/foundation.dart';

/// GOREV-W2 T1 (D-W2-1): depolama sinifinin SAF, dize-tabanli siniflandirmasi.
/// Bu dosya drift'i HIC IMPORT ETMEZ -- gercek enum pini G41'dedir (VM'de
/// import edilebilir `package:drift/src/web/wasm_setup/types.dart`).
enum DepolamaSinifi { kaliciOpfs, geriDusus, kaliciDegil, olculmedi }

/// GOREV-W2 T1/D-W2-2 ②: OPFS-tabanli KALICI implementasyon adlari.
/// `depolamaSinifiCoz` BUNU kullanir, satir-ici literal YAZMAZ. G41/G39/a
/// bu kumeyi gercek drift enum'una karsi PINLER (`M209`).
const Set<String> kaliciOpfsAdlari = {'opfsShared', 'opfsLocks'};

/// GOREV-W2 T1/D-W2-2 ③: geri-dusus (kalici DEGIL ama yine de bir seyler
/// saklayan) implementasyon adlari.
const Set<String> geriDususAdlari = {'sharedIndexedDb', 'unsafeIndexedDb'};

/// GOREV-W2 T1/D-W2-2 ①: hicbir sey saklamayan implementasyon adi.
const String kaliciDegilAdi = 'inMemory';

/// GOREV-W2 D-W2-1: saf siniflandirma fonksiyonu.
/// `uygulamaAdi`/`depolamaApi` drift'in `WasmStorageImplementation.name` /
/// `.storageApi?.name` degerleridir (dize -- G41 gercek enum ile pinler);
/// bu fonksiyon drift TIPINI hic gormez, yalniz dizeleri karsilastirir.
DepolamaSinifi depolamaSinifiCoz({
  required String? uygulamaAdi,
  required String? depolamaApi,
}) {
  // D-W2-2 SIRALI KARAR LISTESI -- oncelik PAZARLIKSIZDIR, degistirilemez:
  if (uygulamaAdi == kaliciDegilAdi) {
    return DepolamaSinifi.kaliciDegil; // ①
  }
  if (kaliciOpfsAdlari.contains(uygulamaAdi) && depolamaApi == 'opfs') {
    return DepolamaSinifi.kaliciOpfs; // ②
  }
  if (geriDususAdlari.contains(uygulamaAdi)) {
    return DepolamaSinifi.geriDusus; // ③
  }
  return DepolamaSinifi.geriDusus; // ④ aksi halde (bilinmeyen ad dahil)
}

/// GOREV-W2 T1: yalniz `sinif` + `uygulamaAdi` tasir.
/// 🔴 `eksikYetenekler` alani BILEREK YOK -- hicbir kapi okumaz (olu alan;
/// emsal `veritabani.dart`: "olu sutun yazilmaz").
class DepolamaDurumu {
  final DepolamaSinifi sinif;
  final String? uygulamaAdi;

  const DepolamaDurumu({required this.sinif, required this.uygulamaAdi});

  /// D-W2-7: native yolda (dikis -- `onResult` -- hic cagrilmadigi icin)
  /// baslangic degeri BU SABITTIR ve hic degismez. Olculdu (build turunda):
  /// `drift_flutter`'in native implementasyonu `web:` seceneklerine hic
  /// dokunmuyor (`drift_flutter-0.3.1/lib/src/native.dart` -- `driftDatabase`
  /// govdesi `web` parametresini hic okumaz).
  const DepolamaDurumu.olculmedi()
    : sinif = DepolamaSinifi.olculmedi,
      uygulamaAdi = null;
}

/// GOREV-W2 T1/D-W2-8: UI'nin dinledigi tek kaynak.
typedef DepolamaBildirimi = ValueNotifier<DepolamaDurumu>;

/// GOREV-W2 D-W2-8: saf yazici -- yalniz siniflandirir ve bildirime yazar,
/// baska is YAPMAZ.
void depolamaBildirimiYaz(
  DepolamaBildirimi bildirim, {
  required String? uygulamaAdi,
  required String? depolamaApi,
}) {
  bildirim.value = DepolamaDurumu(
    sinif: depolamaSinifiCoz(uygulamaAdi: uygulamaAdi, depolamaApi: depolamaApi),
    uygulamaAdi: uygulamaAdi,
  );
}
