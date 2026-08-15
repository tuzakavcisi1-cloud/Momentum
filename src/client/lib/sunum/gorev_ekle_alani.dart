import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';
import 'dogal_dil_ayristirici.dart';
import 'gorev_baslik_dogrulama.dart';

/// SS3.1 -- alt sabit giris + ekle dugmesi.
///
/// A11Y-2 (G5): focusedBorder.borderSide.width == MOlcu.odakKalinlik ve
/// rengi == MRenk.birincil(context) -- bu ozellik DOGRUDAN bu widget'in
/// InputDecoration'inda tanimlanir (M15 mutanti bu satiri hedefler).
///
/// ODEV.md §4(a) DOGAL DIL DILIMI: ayristirma BU WIDGET'TA yapilir, ekranda
/// DEGIL. 🔴 Gerekce OLCULDU: bos baslik reddi ayristirmadan SONRA bakilmak
/// zorundadir -- `#iş` tek basina yazildiginda ham metin BOS DEGILDIR, ama
/// ayristirmadan sonra baslik BOSTUR. Ekranda ayristirilsaydi widget alani
/// TEMIZLER, ekran da bos basligi sessizce duserdi (o68'de olculen SESSIZ
/// KAYIP deseninin aynisi).
class GorevEkleAlani extends StatefulWidget {
  /// Ayristirilmis ekleme istegi. `baslik` `gorevBasligiDogrula`dan GECMISTIR
  /// (bos olamaz).
  final ValueChanged<DogalDilSonucu> onEkle;

  /// Ayristiricinin "bugun"u. 🔴 Ayristirici SAFTIR; saati okuyan tek yer
  /// BURASIDIR ve testte pinlenebilsin diye disaridan verilebilir.
  final DateTime Function() simdi;

  const GorevEkleAlani({
    super.key,
    required this.onEkle,
    this.simdi = DateTime.now,
  });

  @override
  State<GorevEkleAlani> createState() => _GorevEkleAlaniState();
}

class _GorevEkleAlaniState extends State<GorevEkleAlani> {
  final _denetleyici = TextEditingController();

  void _gonder() {
    final ayristirilan = dogalDilAyristir(
      _denetleyici.text,
      bugun: widget.simdi(),
    );
    // IS-EMRI-o68 §3.3: dogrulama (kirpma + bos reddi) `GorevSatiri`'nin
    // baslik duzenleme diyaloğuyla PAYLASILIR -- kopyalanmaz.
    final metin = gorevBasligiDogrula(ayristirilan.baslik);
    // Gecersizse ALAN TEMIZLENMEZ: kullanicinin yazdigi metin EKRANDA KALIR
    // (`GorevSatiri._kaydet` ile ayni desen -- sessiz kayip YASAK).
    if (metin == null) return;
    widget.onEkle(
      DogalDilSonucu(
        baslik: metin,
        oncelik: ayristirilan.oncelik,
        sonTarih: ayristirilan.sonTarih,
        etiketler: ayristirilan.etiketler,
      ),
    );
    _denetleyici.clear();
  }

  @override
  void dispose() {
    _denetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MBosluk.m),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _denetleyici,
              onSubmitted: (_) => _gonder(),
              style: MTipo.govdeM.copyWith(color: MRenk.metin(context)),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MRadius.m),
                  borderSide: BorderSide(
                    color: MRenk.kenarlikEtkilesim(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MRadius.m),
                  borderSide: BorderSide(
                    width: MOlcu.odakKalinlik,
                    color: MRenk.birincil(context),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: MBosluk.s),
          SizedBox(
            width: MOlcu.dokunmaHedefi,
            height: MOlcu.dokunmaHedefi,
            child: Material(
              color: MRenk.birincil(context),
              borderRadius: BorderRadius.circular(MRadius.m),
              child: InkWell(
                borderRadius: BorderRadius.circular(MRadius.m),
                onTap: _gonder,
                child: Semantics(
                  button: true,
                  label: Metinler.ekleDugmesi,
                  child: Icon(Icons.add, color: MRenk.uzeriBirincil(context)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
