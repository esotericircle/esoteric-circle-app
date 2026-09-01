import 'package:flutter/foundation.dart';

import 'tier.dart';

/// Espone il tier dell'utente corrente.
///
/// In C1 e' un contenitore locale con valore di default `free`, utile per
/// dimostrare il gating premium in Home. Nei checkpoint successivi verra'
/// alimentato dallo stato reale di abbonamento (modello reader app, lettura
/// dello stato dal web) tramite un servizio dedicato.
class EntitlementService extends ChangeNotifier {
  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.** Vedi la nota estesa su
  /// `DiarioDelCammino.dimenticaChiSeNeVa`: i controller vivono per tutta la
  /// sessione, e cancellare l'account senza svuotarli lasciava a schermo i
  /// dati di chi se n'era appena andato.
  void dimenticaChiSeNeVa() {
    setTier(Tier.free);
  }

  EntitlementService({Tier initial = Tier.free}) : _tier = initial;

  Tier _tier;
  Tier get tier => _tier;

  void setTier(Tier tier) {
    if (tier == _tier) return;
    _tier = tier;
    notifyListeners();
  }
}
