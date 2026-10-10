/// Confine astratto verso la voce dei Maestri (Gemini-TTS).
///
/// Regola d'oro dello stack: la sintesi vocale reale gira su Gemini via Vertex,
/// sul device. Qui la UI dipende solo da questa astrazione: se la voce non e'
/// disponibile (Demo, nessuna configurazione) resta il sottotitolo, mai un
/// errore. `available` dice se la voce puo' parlare davvero.
abstract interface class VoiceGreeting {
  bool get available;

  /// Pronuncia la frase. Restituisce true se la voce ha parlato davvero.
  Future<bool> speak(String text);
}

/// Voce silenziosa, di default: non parla e lo dichiara. Il saluto resta come
/// sottotitolo. La voce reale su Gemini-TTS arriva sul device.
class SilentVoiceGreeting implements VoiceGreeting {
  const SilentVoiceGreeting();

  @override
  bool get available => false;

  @override
  Future<bool> speak(String text) async => false;
}
