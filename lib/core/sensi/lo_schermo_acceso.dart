import 'package:flutter/services.dart';

import '../../services/ai/registro_dei_guasti.dart';

/// **LO SCHERMO RESTA ACCESO MENTRE SI PARLA COI MAESTRI.** Guasto trovato
/// nell'ordine EK il 24 settembre 2026, alla prova della trascrizione sul
/// Realme.
///
/// **Il fatto.** Il LIVE si fa parlando, senza toccare il telefono. Alle
/// 13:24:05 lo schermo si e' spento da solo, cinque minuti dopo l'ultimo
/// tocco, che e' il tempo di spegnimento di quel telefono, mentre Medora stava
/// ancora rispondendo. Da li' il microfono ha dato -100 decibel, la frase
/// successiva non e' arrivata, e dopo trenta secondi il LIVE si e' chiuso da
/// solo. Su un telefono impostato a trenta secondi, e molti lo sono, il LIVE
/// muore a ogni risposta lunga. Padre: ordine EG, la schermata del LIVE, che
/// non ha mai chiesto di tenere acceso lo schermo.
///
/// **La cura** e' quella delle videochiamate: finche' la schermata del LIVE e'
/// aperta, lo schermo non si spegne da solo. Su Android e' il segno
/// `FLAG_KEEP_SCREEN_ON` sulla finestra, che non chiede permessi e si toglie
/// da se' quando la finestra se ne va; su iOS e' `isIdleTimerDisabled`. Il
/// canale sta in `MainActivity.kt` e in `AppDelegate.swift`.
abstract final class LoSchermoAcceso {
  static const MethodChannel _canale = MethodChannel('esoteric_circle/schermo');

  /// **Sostituibile nelle prove**, perche' il banco non ha una finestra.
  static Future<void> Function(bool acceso) chiedi = _dalCanale;

  static Future<void> _dalCanale(bool acceso) =>
      _canale.invokeMethod<void>('tieniAcceso', acceso);

  /// Tiene acceso lo schermo, o lo lascia di nuovo spegnere.
  static Future<void> tieni(bool acceso) async {
    try {
      await chiedi(acceso);
    } on MissingPluginException {
      // Sul banco e sul web il canale non c'e': non e' un guasto.
    } catch (errore) {
      annotaGuastoInnocuo(
        'lo schermo non si tiene ${acceso ? 'acceso' : 'libero'}',
        errore,
      );
    }
  }
}
