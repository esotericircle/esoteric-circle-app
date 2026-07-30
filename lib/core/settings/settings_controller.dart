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
/// - [suonoEVibrazione]: l'INTERRUTTORE UNICO del livello sensoriale. Governa i
///   due canali INSIEME, suono e aptica, come prescrivono le Linee Guida alla
///   sezione 6. Un comando solo e non due, perche' chi vuole silenzio vuole
///   silenzio: due interruttori separati obbligherebbero a spegnere due volte la
///   stessa intenzione.
///
/// La persistenza e' best effort: se `SharedPreferences` non e' disponibile
/// (test senza mock, avvio a freddo) le preferenze restano solo in memoria,
/// senza crash.
class SettingsController extends ChangeNotifier {
  SettingsController({
    bool reduceAnimations = false,
    bool simpleMode = false,
    bool subtitles = true,
    bool suonoEVibrazione = true,
  })  : _reduceAnimations = reduceAnimations,
        _simpleMode = simpleMode,
        _subtitles = subtitles,
        _suonoEVibrazione = suonoEVibrazione;

  static const _kReduce = 'settings.reduceAnimations';
  static const _kSimple = 'settings.simpleMode';
  static const _kSubtitles = 'settings.subtitles';
  static const _kSuono = 'settings.suonoEVibrazione';

  bool _reduceAnimations;
  bool _simpleMode;
  bool _subtitles;
  bool _suonoEVibrazione;

  bool get reduceAnimations => _reduceAnimations;
  bool get simpleMode => _simpleMode;
  bool get subtitles => _subtitles;

  /// Se il livello sensoriale e' acceso: suono E vibrazione insieme.
  ///
  /// Ogni funzione che vibra o suona lo legge da qui, e nessuna tiene una
  /// propria preferenza separata: due comandi per la stessa intenzione sono un
  /// modo di non averne nessuno.
  bool get suonoEVibrazione => _suonoEVibrazione;

  /// Carica le preferenze salvate, best effort.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _reduceAnimations = prefs.getBool(_kReduce) ?? _reduceAnimations;
      _simpleMode = prefs.getBool(_kSimple) ?? _simpleMode;
      _subtitles = prefs.getBool(_kSubtitles) ?? _subtitles;
      _suonoEVibrazione = prefs.getBool(_kSuono) ?? _suonoEVibrazione;
      notifyListeners();
    } catch (_) {
      // Nessuna persistenza disponibile: si resta sui valori in memoria.
    }
  }

  /// Accende o spegne il livello sensoriale intero.
  void setSuonoEVibrazione(bool value) {
    if (value == _suonoEVibrazione) return;
    _suonoEVibrazione = value;
    notifyListeners();
    _persist(_kSuono, value);
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
