import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Governa il primo avvio: la prima apertura dell'app mostra l'onboarding
/// "Il Risveglio", le successive vanno dirette al Santuario.
///
/// Lo stato "gia' risvegliato" e' persistito su `SharedPreferences`. Senza
/// persistenza (test, anteprime) non si blocca l'app con l'onboarding: si va
/// dritti al Santuario.
class OnboardingController extends ChangeNotifier {
  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.**
  ///
  /// Chi cancella l'account deve tornare a essere qualcuno che l'onboarding
  /// non ha ancora visto: senza questa riga l'app crederebbe che il rito
  /// d'ingresso sia gia' stato fatto, e chi arriva dopo si troverebbe dentro
  /// un Cerchio che non lo conosce.
  void dimenticaChiSeNeVa() {
    _resolved = true;
    _needsOnboarding = true;
    notifyListeners();
  }

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

  /// Riporta il rito allo stato di chi non l'ha mai fatto.
  ///
  /// Serve alla prova su dispositivo: senza, per rivedere il Risveglio bisogna
  /// svuotare i dati dell'app dalle impostazioni di sistema a ogni giro. Il
  /// comando che la chiama vive solo nelle build di debug.
  Future<void> reset() async {
    _needsOnboarding = true;
    _resolved = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kDone);
    } catch (_) {
      // Best effort: senza persistenza lo stato resta solo in memoria.
    }
  }

  /// **IL RITO NON SI RIFA' A CHI IL CERCHIO CONOSCE GIA'. Ordine AP voce
  /// 05.**
  ///
  /// La domanda di Mauro: rifare l'onboarding quando si e' gia' registrati
  /// non ha senso. Chi rientra col suo account ha gia' dato la sua nascita, e
  /// richiedergliela e' come se il Cerchio non lo conoscesse.
  ///
  /// **E' diverso da [complete]**, anche se fa la stessa cosa allo stato: la
  /// differenza sta nel MOTIVO, e il motivo si legge nel nome. Chiamarlo
  /// `complete` avrebbe detto che il rito e' stato fatto, e non e' vero: e'
  /// stato RITROVATO.
  Future<void> ritrovato() => complete();

  /// Segna l'onboarding come completato: da qui in poi si apre il Cerchio.
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
