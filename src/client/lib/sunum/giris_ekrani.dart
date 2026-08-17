import 'package:flutter/material.dart';

import '../design/metinler.dart';
import '../design/tokens.dart';
import '../veri/oturum_yoneticisi.dart';

/// IS-EMRI-o83 s2.2/8: giriş+kayıt ekranı. Uygulama açılışında oturum yoksa
/// buraya düşer (kök widget -- bkz. main.dart). Başarılı giriş/kayıt sonrası
/// [OturumYoneticisi.oturum] reaktif olarak dolar, kök widget bunu dinleyip
/// bu ekrandan uzaklaşır -- burada Navigator.pop/push YOK.
class GirisEkrani extends StatefulWidget {
  final OturumYoneticisi oturumYoneticisi;

  const GirisEkrani({super.key, required this.oturumYoneticisi});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  // o68 dersi (gorev_satiri.dart): controller'in yasam dongusu State'e
  // baglidir, dispose() burada yapilir.
  final _formAnahtari = GlobalKey<FormState>();
  late final TextEditingController _epostaDenetleyici;
  late final TextEditingController _sifreDenetleyici;
  bool _kayitModu = false;
  bool _gonderiliyor = false;
  String? _hataMetni;

  @override
  void initState() {
    super.initState();
    _epostaDenetleyici = TextEditingController();
    _sifreDenetleyici = TextEditingController();
  }

  @override
  void dispose() {
    _epostaDenetleyici.dispose();
    _sifreDenetleyici.dispose();
    super.dispose();
  }

  Future<void> _gonder() async {
    if (!_formAnahtari.currentState!.validate()) {
      return;
    }
    setState(() {
      _gonderiliyor = true;
      _hataMetni = null;
    });
    final eposta = _epostaDenetleyici.text.trim();
    final sifre = _sifreDenetleyici.text;
    final hata = _kayitModu
        ? await widget.oturumYoneticisi.kayitOl(eposta, sifre)
        : await widget.oturumYoneticisi.girisYap(eposta, sifre);
    // Basarili donusteoturum.value dolar, kok widget bu ekrani zaten
    // kaldirir -- ama basarisizsa State hala hayattadir, mounted kontrolu
    // yalniz async bosluktan sonraki setState icin gerekli guvenlik.
    if (!mounted) {
      return;
    }
    setState(() {
      _gonderiliyor = false;
      _hataMetni = hata;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MBosluk.m),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formAnahtari,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      Metinler.girisEkraniBasligi,
                      style: MTipo.baslikXl,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: MBosluk.l),
                    TextFormField(
                      controller: _epostaDenetleyici,
                      enabled: !_gonderiliyor,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: Metinler.epostaEtiketi,
                      ),
                      validator: (deger) =>
                          (deger == null || deger.trim().isEmpty)
                          ? Metinler.epostaEtiketi
                          : null,
                    ),
                    SizedBox(height: MBosluk.s),
                    TextFormField(
                      controller: _sifreDenetleyici,
                      enabled: !_gonderiliyor,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: Metinler.sifreEtiketi,
                      ),
                      validator: (deger) => (deger == null || deger.isEmpty)
                          ? Metinler.sifreEtiketi
                          : null,
                      onFieldSubmitted: (_) => _gonder(),
                    ),
                    if (_hataMetni != null) ...[
                      SizedBox(height: MBosluk.s),
                      Text(
                        _hataMetni!,
                        style: TextStyle(color: MRenk.tehlike(context)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                    SizedBox(height: MBosluk.m),
                    SizedBox(
                      height: MOlcu.dokunmaHedefi,
                      child: FilledButton(
                        onPressed: _gonderiliyor ? null : _gonder,
                        child: _gonderiliyor
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _kayitModu
                                    ? Metinler.kayitOlDugmesi
                                    : Metinler.girisYapDugmesi,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                      ),
                    ),
                    SizedBox(height: MBosluk.xs),
                    TextButton(
                      onPressed: _gonderiliyor
                          ? null
                          : () => setState(() {
                              _kayitModu = !_kayitModu;
                              _hataMetni = null;
                            }),
                      child: Text(
                        _kayitModu
                            ? Metinler.zatenHesabinVarMi
                            : Metinler.hesabinYokMu,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
