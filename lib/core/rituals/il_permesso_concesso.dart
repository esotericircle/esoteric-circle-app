/// IL PERMESSO DELLE NOTIFICHE, APPENA CONCESSO. Ordine FF voce 09.3, 7
/// ottobre 2026.
///
/// **Il fatto misurato.** Il recapito per le push si leggeva una volta sola,
/// all'avvio (`CustodeMontato`), e solo se il permesso c'era gia'. Il
/// permesso pero' non si chiede all'avvio: lo chiede il primo Dono, il menu'
/// degli avvisi o il Sigillo, a sessione gia' aperta. Chi lo concedeva
/// restava senza recapito fino al lancio seguente, e su iPhone, dove l'app
/// resta in memoria per giorni, poteva voler dire giorni senza push.
///
/// Adesso chi ottiene il si' lo annuncia qui, e il custode rilegge il
/// recapito subito.
library;

import 'dart:async';

abstract final class IlPermessoConcesso {
  static final StreamController<void> _flusso =
      StreamController<void>.broadcast();

  /// Un evento per ogni si' del sistema.
  static Stream<void> get flusso => _flusso.stream;

  /// Lo chiama chi ha appena ottenuto il permesso.
  static void annuncia() => _flusso.add(null);
}
