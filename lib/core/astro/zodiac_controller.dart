import 'package:flutter/foundation.dart';

import 'zodiac.dart';

/// Tiene il segno solare dell'utente, usato dal cosmo di sfondo per evidenziare
/// in oro la costellazione corrispondente.
///
/// In C1 non c'e' ancora l'onboarding che calcola la carta natale, quindi il
/// valore parte da un segno di esempio (Leone) solo per mostrare la meccanica
/// di evidenziazione. Quando l'onboarding arrivera' (checkpoint C2), imposta
/// qui il segno reale con [setSunSign], oppure `null` per non evidenziare
/// nulla.
class ZodiacController extends ChangeNotifier {
  ZodiacController({Zodiac? sunSign = Zodiac.gemini}) : _sunSign = sunSign;

  Zodiac? _sunSign;
  Zodiac? get sunSign => _sunSign;

  void setSunSign(Zodiac? sign) {
    if (sign == _sunSign) return;
    _sunSign = sign;
    notifyListeners();
  }
}
