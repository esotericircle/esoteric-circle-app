import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// **LA SUONERIA DEL TELEFONO: e' in silenzioso?** Ordine FS aggiunta, voce
/// FS.A2, 14 ottobre 2026.
///
/// L'ordine: l'audio del video della Stesa *"rispetta le impostazioni audio
/// dell'app e la modalita' silenziosa del telefono"*. Le impostazioni dell'app
/// le legge `SettingsController`; la modalita' silenziosa la sa solo il
/// sistema, e la si chiede qui.
///
/// **Su Android** risponde `AudioManager.getRingerMode()` in `MainActivity`:
/// silenzioso e vibrazione contano tutti e due come silenzio, perche' chi ha
/// messo il telefono a vibrare non ha chiesto di sentire un video.
///
/// **Su iOS non c'e' risposta**: il sistema non dice a un'app dove sta
/// l'interruttore laterale, e il canale non e' implementato. Si risponde
/// "non in silenzio", cioe' come prima di questo file; il limite e' scritto
/// nel rapporto dell'ordine FS aggiunta.
///
/// **Non lancia mai**: un canale che manca (le prove, iOS) e un errore della
/// piattaforma valgono "non in silenzio".
class LaSuoneria {
  const LaSuoneria._();

  static const MethodChannel _canale =
      MethodChannel('esoteric_circle/suoneria');

  /// La risposta finta delle prove: nulla per chiedere al canale.
  @visibleForTesting
  static bool? spentaPerLeProve;

  /// Vero se il telefono e' in silenzioso o in vibrazione.
  static Future<bool> spenta() async {
    final finta = spentaPerLeProve;
    if (finta != null) return finta;
    try {
      return await _canale.invokeMethod<bool>('spenta') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (errore) {
      debugPrint('La suoneria non risponde: $errore');
      return false;
    }
  }
}
