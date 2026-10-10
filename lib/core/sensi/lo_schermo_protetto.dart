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
/// **LAPIDE: dalla build 2290 alla 2291 lo schermo si proteggeva sempre**,
/// salvo le build di collaudo con `CATTURE_PERMESSE`. Il fondatore il
/// giorno stesso, col Viaggio da mostrare: *"Devi riattivare la possibilità
/// di fare screenshot, così non posso farli nemmeno per te"*. **Adesso le
/// catture sono permesse**, e la protezione si accende solo nella build che
/// la dichiara con `--dart-define=CATTURE_VIETATE=true`, per il giorno in
/// cui il fondatore la vorra' negli store. Il segno e il canale restano.
abstract final class LoSchermoProtetto {
  static const MethodChannel _canale = MethodChannel('esoteric_circle/schermo');

  /// Vero solo nella build che lo dichiara: di base le catture si fanno.
  static const bool cattureVietate = bool.fromEnvironment('CATTURE_VIETATE');

  /// **Sostituibile nelle prove**, perche' il banco non ha una finestra.
  static Future<void> Function(bool protetto) chiedi = _dalCanale;

  static Future<void> _dalCanale(bool protetto) =>
      _canale.invokeMethod<void>('proteggi', protetto);

  /// Protegge lo schermo solo se la build lo dichiara, e altrimenti toglie
  /// il segno: un telefono che arriva dalla 2291 non resta protetto.
  static Future<void> applica() async {
    try {
      await chiedi(cattureVietate);
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
