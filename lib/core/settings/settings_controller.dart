import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferenze dell'utente, tenute in un solo posto e persistite in locale.
///
/// - [reduceAnimations]: riduce o ferma i movimenti (parallasse, animazioni). Si
///   riversa su `MediaQuery.disableAnimations`, cosi' tutto il codice che gia'
///   rispetta Riduci Movimento lo onora senza modifiche.
/// - [simpleMode]: modalita' semplice, abbassa la qualita' grafica (meno stelle,
///   niente blur) per fluidita' e leggibilita'.
/// - [subtitles]: sottotitoli attivi, di default veri. Segnaposto in attesa del
///   passo voce: la preferenza si conserva, l'effetto arriva con la voce.
///
/// La persistenza e' best effort: se `SharedPreferences` non e' disponibile
/// (test senza mock, avvio a freddo) le preferenze restano solo in memoria,
/// senza crash.
class SettingsController extends ChangeNotifier {
  SettingsController({
    bool reduceAnimations = false,
    bool simpleMode = false,
    bool subtitles = true,
  })  : _reduceAnimations = reduceAnimations,
        _simpleMode = simpleMode,
        _subtitles = subtitles;

  static const _kReduce = 'settings.reduceAnimations';
  static const _kSimple = 'settings.simpleMode';
  static const _kSubtitles = 'settings.subtitles';

  bool _reduceAnimations;
  bool _simpleMode;
  bool _subtitles;

  bool get reduceAnimations => _reduceAnimations;
  bool get simpleMode => _simpleMode;
  bool get subtitles => _subtitles;

  /// Carica le preferenze salvate, best effort.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _reduceAnimations = prefs.getBool(_kReduce) ?? _reduceAnimations;
      _simpleMode = prefs.getBool(_kSimple) ?? _simpleMode;
      _subtitles = prefs.getBool(_kSubtitles) ?? _subtitles;
      notifyListeners();
    } catch (_) {
      // Nessuna persistenza disponibile: si resta sui valori in memoria.
    }
  }

  void setReduceAnimations(bool value) {
    if (value == _reduceAnimations) return;
    _reduceAnimations = value;
    notifyListeners();
    _persist(_kReduce, value);
  }

  void setSimpleMode(bool value) {
    if (value == _simpleMode) return;
    _simpleMode = value;
    notifyListeners();
    _persist(_kSimple, value);
  }

  void setSubtitles(bool value) {
    if (value == _subtitles) return;
    _subtitles = value;
    notifyListeners();
    _persist(_kSubtitles, value);
  }

  Future<void> _persist(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // Best effort: un errore di scrittura non deve rompere l'app.
    }
  }
}
