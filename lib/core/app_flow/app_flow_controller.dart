import 'package:flutter/foundation.dart';

/// Le fasi di ingresso dell'app.
enum AppPhase {
  /// Intro cinematografica.
  intro,

  /// Onboarding Il Risveglio (dati, carta natale, rivelazione del Maestro).
  onboarding,

  /// App vera e propria (Il Santuario).
  app,
}

/// Governa quale fase di ingresso e' visibile.
///
/// In C2 la fase non e' persistita tra i riavvii: ogni avvio riparte
/// dall'intro, comodo per la revisione ai checkpoint. La persistenza (mostrare
/// l'onboarding una sola volta) arrivera' con l'account e lo storage.
class AppFlowController extends ChangeNotifier {
  AppPhase _phase = AppPhase.intro;
  AppPhase get phase => _phase;

  void _set(AppPhase p) {
    if (p == _phase) return;
    _phase = p;
    notifyListeners();
  }

  void toOnboarding() => _set(AppPhase.onboarding);
  void toApp() => _set(AppPhase.app);
  void restart() => _set(AppPhase.intro);
}
