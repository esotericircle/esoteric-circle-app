import 'package:flutter/foundation.dart';
import 'nome_proprio.dart';

/// Il nome dell'utente. Si raccoglie subito dopo l'intro e si usa da subito
/// nei testi dei Maestri.
///
/// **QUI C'ERA ANCHE LA FORMA DI CORTESIA**, un secondo enum `AddressForm` con
/// `pick()` e `welcome()`. Tolto con l'ordine DL voce 01: faceva la stessa
/// cosa di `CourtesyForm`, con un difetto in piu', perche' la forma non si
/// salvava da nessuna parte e ripartiva neutra a ogni avvio. **La forma ha una
/// porta sola**, `CourtesyForm` col profilo che la custodisce, e le parole si
/// decidono in `LaMarcaDelGenere`.
class IdentityController extends ChangeNotifier {
  String _name = '';

  String get name => _name.trim();
  bool get hasName => name.isNotEmpty;

  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.** Il nome con cui i Maestri
  /// si rivolgono a qualcuno e' la cosa piu' sua che ci sia: lasciarlo a
  /// schermo dopo una cancellazione vuol dire salutare col nome di un altro.
  void dimenticaChiSeNeVa() {
    _name = '';
    notifyListeners();
  }

  void setName(String value) {
    _name = normalizzaNomeProprio(value);
    notifyListeners();
  }
}
