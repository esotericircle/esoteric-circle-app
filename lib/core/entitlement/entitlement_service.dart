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

  /// **IL PIANO LO DICE IL SERVER, e da qui in poi ha una sorgente sola.**
  /// Ordine CQ voce 1.01, 3 settembre 2026.
  ///
  /// **Il difetto che chiude.** Il piano viveva in due posti che non si
  /// parlavano: questo servizio, che il pulsante "Attiva in Demo" cambiava, e
  /// `users/<uid>/stato/abbonamento.piano` su Firestore, che nessuno scriveva
  /// e valeva `free` per tutti. Il campo arrivava dentro `StatoDelCerchio` e
  /// **nessuno lo leggeva**: il telefono applicava il tetto di un piano e il
  /// server quello di un altro, e a schermo si vedevano tutti e due insieme,
  /// "ti restano 29 gettate su 30" e subito dopo "non ti resta nessuna
  /// gettata".
  ///
  /// **Un nome che il server non conosce vale `free`**, come fa gia'
  /// `pianoValido` dall'altra parte: nel dubbio si sbaglia dalla parte del
  /// tetto, mai da quella del regalo.
  void applicaIlPianoDelServer(String piano) {
    setTier(switch (piano) {
      'tier1' => Tier.tier1,
      'tier2' => Tier.tier2,
      'tier3' => Tier.tier3,
      _ => Tier.free,
    });
  }

  /// Il nome che il server usa per questo piano, per la strada di ritorno.
  static String nomeDelServer(Tier tier) => switch (tier) {
        Tier.free => 'free',
        Tier.tier1 => 'tier1',
        Tier.tier2 => 'tier2',
        Tier.tier3 => 'tier3',
      };

  void setTier(Tier tier) {
    if (tier == _tier) return;
    _tier = tier;
    notifyListeners();
  }
}
