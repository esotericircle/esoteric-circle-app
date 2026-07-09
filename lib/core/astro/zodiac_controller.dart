import 'package:flutter/foundation.dart';

import 'zodiac.dart';

/// Tiene il segno solare dell'utente, usato dal cosmo di sfondo per evidenziare
/// in oro la costellazione corrispondente.
///
/// Parte senza segno: nessuna costellazione evidenziata durante l'intro e
/// l'onboarding (niente costellazione decorativa incollata in un angolo). Il
/// segno reale viene impostato con [setSunSign] a fine carta natale, e da li'
/// in poi il cielo evidenzia la costellazione del Sole dell'utente.
class ZodiacController extends ChangeNotifier {
  ZodiacController({Zodiac? sunSign}) : _sunSign = sunSign;

  Zodiac? _sunSign;
  Zodiac? get sunSign => _sunSign;

  void setSunSign(Zodiac? sign) {
    if (sign == _sunSign) return;
    _sunSign = sign;
    notifyListeners();
  }
}
