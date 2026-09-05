import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/voice/voice_greeting.dart';

/// Il saluto della primissima apertura del Santuario.
///
/// Alla prima volta, il Maestro di turno del giorno saluta l'utente per nome:
/// una frase sola, una volta sola. La voce prova a parlare (Gemini-TTS sul
/// device); il sottotitolo e' attivo di default e resta anche senza voce. Il
/// "gia' salutato" e' persistito, cosi' non si ripete.
class GreetingController extends ChangeNotifier {
  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.** Vedi
  /// `DimenticanzaDellaMemoriaViva`: i controller vivono per tutta la
  /// sessione, e cancellare l'account senza svuotarli lascia a schermo i dati
  /// di chi se n'e' appena andato. **Questo l'ha trovato la prova che enumera
  /// i provider di `app.dart`**, non l'occhio: era uno dei cinque che nessuno
  /// aveva contato.
  void dimenticaChiSeNeVa() {
    _text = null;
    _maestro = null;
    notifyListeners();
  }

  GreetingController({
    DateTime Function()? clock,
    VoiceGreeting voice = const SilentVoiceGreeting(),
  })  : _clock = clock ?? DateTime.now,
        _voice = voice;

  final DateTime Function() _clock;
  final VoiceGreeting _voice;

  static const _kGreeted = 'santuario.greeted';

  String? _text;
  Maestro? _maestro;

  /// Il sottotitolo del saluto, o null se non c'e' saluto da mostrare.
  String? get text => _text;

  /// Il Maestro di turno che saluta.
  Maestro? get maestro => _maestro;

  /// Alla prima apertura prepara il saluto e prova la voce, una volta sola. Su
  /// qualunque problema (niente persistenza) resta silente, senza saluto.
  Future<void> prepare({required String name}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_kGreeted) == true) return;
      final maestro = DailyRituals.dawnMaestro(_clock());
      final greeting = greetingFor(maestro, name);
      _maestro = maestro;
      _text = greeting;
      await prefs.setBool(_kGreeted, true);
      notifyListeners();
      // La voce e' un di piu': se non parla, resta il sottotitolo.
      unawaited(_voice.speak(greeting));
    } catch (_) {
      // Nessuna persistenza disponibile: nessun saluto, mai un errore.
    }
  }

  /// Nasconde il saluto dopo che e' stato visto.
  void dismiss() {
    if (_text == null) return;
    _text = null;
    notifyListeners();
  }

  /// La frase del saluto, breve, nella voce del Maestro di turno.
  static String greetingFor(Maestro maestro, String name) {
    switch (maestro) {
      case Maestro.medora:
        return '$name, il cielo ti riconosce. Entra nel cerchio.';
      case Maestro.aura:
        return '$name, respira: sei nel posto giusto.';
      case Maestro.caligo:
        return '$name, la soglia si apre per te.';
    }
  }
}
