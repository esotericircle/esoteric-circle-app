import 'package:flutter/foundation.dart';

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

  void setName(String value) {
    _name = normalizzaNome(value);
    notifyListeners();
  }

  /// Il nome scritto come si scrive un nome, deciso QUI, dove entra.
  ///
  /// Chi batteva "mauro" se lo ritrovava minuscolo in ogni bolla e in ogni
  /// responso, per sempre: la correzione al momento di mostrarlo andrebbe
  /// ripetuta in venti punti, e uno resterebbe indietro. Nessuno scrive il
  /// proprio nome tutto minuscolo per scelta, e nessuno lo urla maiuscolo:
  /// sono la fretta della tastiera e il blocco maiuscole.
  ///
  /// Le maiuscole INTERNE volute si riconoscono e restano: McDonald non
  /// diventa Mcdonald. I separatori dei nomi composti (spazio, trattino,
  /// apostrofo) aprono ciascuno una nuova iniziale.
  static String normalizzaNome(String grezzo) {
    final pulito = grezzo.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (pulito.isEmpty) return '';

    final buf = StringBuffer();
    var iniziale = true;
    for (var i = 0; i < pulito.length; i++) {
      final ch = pulito[i];
      if (ch == ' ' || ch == '-' || ch == "'" || ch == '’') {
        buf.write(ch);
        iniziale = true;
        continue;
      }
      if (iniziale) {
        buf.write(ch.toUpperCase());
        iniziale = false;
        continue;
      }
      // Dentro la parola: si abbassa solo se la parola e' tutta maiuscola,
      // cioe' un urlo da blocco maiuscole. Una maiuscola isolata dentro un
      // nome e' voluta e va lasciata stare.
      final parola = _parolaDa(pulito, i);
      buf.write(parola == parola.toUpperCase() ? ch.toLowerCase() : ch);
    }
    return buf.toString();
  }

  static String _parolaDa(String s, int i) {
    var inizio = i;
    while (inizio > 0 &&
        s[inizio - 1] != ' ' &&
        s[inizio - 1] != '-' &&
        s[inizio - 1] != "'" &&
        s[inizio - 1] != '’') {
      inizio--;
    }
    var fine = i;
    while (fine < s.length &&
        s[fine] != ' ' &&
        s[fine] != '-' &&
        s[fine] != "'" &&
        s[fine] != '’') {
      fine++;
    }
    return s.substring(inizio, fine);
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
