import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Governa il primo avvio: la prima apertura dell'app mostra l'onboarding
/// "Il Risveglio", le successive vanno dirette al Santuario.
///
/// Lo stato "gia' risvegliato" e' persistito su `SharedPreferences`. Senza
/// persistenza (test, anteprime) non si blocca l'app con l'onboarding: si va
/// dritti al Santuario.
class OnboardingController extends ChangeNotifier {
  static const _kDone = 'onboarding.done';

  bool _resolved = false;
  bool _needsOnboarding = false;

  /// Vero quando lo stato e' stato letto (o e' fallito il ripiego).
  bool get resolved => _resolved;

  /// Vero se va mostrato l'onboarding "Il Risveglio" prima del Santuario.
  bool get needsOnboarding => _needsOnboarding;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _needsOnboarding = prefs.getBool(_kDone) != true;
    } catch (_) {
      _needsOnboarding = false;
    }
    _resolved = true;
    notifyListeners();
  }

  /// Segna l'onboarding come completato: da qui in poi si apre il Santuario.
  Future<void> complete() async {
    _needsOnboarding = false;
    _resolved = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDone, true);
    } catch (_) {
      // Best effort: senza persistenza lo stato resta solo in memoria.
    }
  }
}
