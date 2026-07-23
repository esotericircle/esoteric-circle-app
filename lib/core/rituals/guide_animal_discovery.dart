import 'package:shared_preferences/shared_preferences.dart';

/// Ricorda se l'animale guida e' gia' stato TROVATO col viaggio sciamanico.
///
/// L'animale in se' e' deterministico dal segno, ma nella tradizione lo si trova
/// viaggiando: questo flag distingue chi ha gia' compiuto il viaggio, cosi' dal
/// Cosmic Passport si apre direttamente la lettura senza rifarlo. Solo in locale.
class GuideAnimalDiscovery {
  const GuideAnimalDiscovery._();

  static const String _chiave = 'guide_animal.trovato';

  /// Se il viaggio e' gia' stato compiuto almeno una volta.
  static Future<bool> trovato() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getBool(_chiave) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Segna che l'animale e' stato trovato. Best effort, mai un errore.
  static Future<void> segnaTrovato() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_chiave, true);
    } catch (_) {
      // Senza persistenza il viaggio si potra' rifare, senza crash.
    }
  }
}
