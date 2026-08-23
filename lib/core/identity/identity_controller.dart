import 'package:flutter/foundation.dart';
import 'nome_proprio.dart';

/// Forma di cortesia scelta dall'utente, usata per rivolgersi a lui nei testi
/// dei Maestri.
enum AddressForm {
  feminine('Al femminile'),
  masculine('Al maschile'),
  neutral('In modo neutro');

  const AddressForm(this.label);
  final String label;
}

/// Nome e forma di cortesia dell'utente. Si raccolgono subito dopo l'intro e si
/// usano da subito nei testi dei Maestri.
class IdentityController extends ChangeNotifier {
  String _name = '';
  AddressForm _form = AddressForm.neutral;

  String get name => _name.trim();
  bool get hasName => name.isNotEmpty;
  AddressForm get form => _form;

  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.** Il nome con cui i Maestri
  /// si rivolgono a qualcuno e' la cosa piu' sua che ci sia: lasciarlo a
  /// schermo dopo una cancellazione vuol dire salutare col nome di un altro.
  void dimenticaChiSeNeVa() {
    _name = '';
    _form = AddressForm.neutral;
    notifyListeners();
  }

  void setName(String value) {
    _name = normalizzaNomeProprio(value);
    notifyListeners();
  }


  void setForm(AddressForm value) {
    if (value == _form) return;
    _form = value;
    notifyListeners();
  }

  /// Sceglie la variante di una parola secondo la forma. Per la forma neutra si
  /// passa una formulazione gia' priva di marca di genere.
  String pick({
    required String masculine,
    required String feminine,
    required String neutral,
  }) =>
      switch (_form) {
        AddressForm.masculine => masculine,
        AddressForm.feminine => feminine,
        AddressForm.neutral => neutral,
      };

  /// Saluto di benvenuto personalizzato.
  String welcome() {
    final n = hasName ? ', $name' : '';
    return pick(
      masculine: 'Benvenuto nel cerchio$n',
      feminine: 'Benvenuta nel cerchio$n',
      neutral: 'Ti do il benvenuto nel cerchio$n',
    );
  }
}
