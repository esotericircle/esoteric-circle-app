import 'package:flutter/services.dart';

import '../../services/ai/registro_dei_guasti.dart';

/// **NIENTE CATTURE DELLO SCHERMO.** Ordine EV, il fondatore il 1 ottobre
/// 2026: *"vorrei disattivassi la possibilità di fare screenshot"*.
///
/// Su Android e' il segno `FLAG_SECURE` sulla finestra, in `MainActivity.kt`
/// sullo stesso canale dello schermo acceso: niente cattura, niente
/// registrazione dello schermo, e l'anteprima fra le app recenti resta nera.
/// **Su iOS non esiste**: il sistema non lascia a un'app il modo di impedire
/// una cattura, solo di sapere che e' avvenuta; il canale di iOS risponde che
/// il metodo non c'e', e qui non e' un guasto.
///
/// **Le build di collaudo possono riaccenderle** con
/// `--dart-define=CATTURE_PERMESSE=true`: le prove sul telefono di collaudo
/// sono catture dello schermo, e con il segno acceso escono nere.
abstract final class LoSchermoProtetto {
  static const MethodChannel _canale = MethodChannel('esoteric_circle/schermo');

  /// Vero solo nelle build di collaudo che lo dichiarano.
  static const bool cattureConsentite =
      bool.fromEnvironment('CATTURE_PERMESSE');

  /// **Sostituibile nelle prove**, perche' il banco non ha una finestra.
  static Future<void> Function(bool protetto) chiedi = _dalCanale;

  static Future<void> _dalCanale(bool protetto) =>
      _canale.invokeMethod<void>('proteggi', protetto);

  /// Protegge lo schermo, salvo nelle build di collaudo.
  static Future<void> applica() async {
    try {
      await chiedi(!cattureConsentite);
    } on MissingPluginException {
      // iOS, il banco e il web: il segno non c'e'.
    } on PlatformException catch (errore) {
      if (errore.code != 'notImplemented') {
        annotaGuastoInnocuo('lo schermo non si protegge', errore);
      }
    } catch (errore) {
      annotaGuastoInnocuo('lo schermo non si protegge', errore);
    }
  }
}
