/// Strato dei servizi: confini verso il mondo esterno.
///
/// Qui vivranno i client verso Firebase, l'AI Gateway, il motore astrologico,
/// lo storage e la memoria. In C1 sono definite solo le interfacce, senza
/// implementazioni concrete e senza alcuna chiave o segreto: le
/// implementazioni reali arrivano nei checkpoint successivi e leggeranno i
/// segreti da Secret Manager in produzione, mai dal codice.
///
/// Lo scopo di dichiararle ora e' fissare i confini dell'architettura, cosi'
/// le feature dipendono da astrazioni stabili e non da dettagli concreti.
///
/// Riferimento: Handoff Fase C sezione 4 (lib/services) e regola d'oro dello
/// stack (Claude costruisce, Gemini fa girare; strato di astrazione AIProvider).
library;

/// Astrae il fornitore AI a runtime (Vertex AI / Gemini in produzione).
///
/// Consente di cambiare provider senza riscrivere le feature. Nessuna
/// chiamata all'LLM avviene in C1.
abstract interface class AiProvider {
  /// Genera testo a partire da un prompt gia' composto dallo strato ibrido.
  Future<String> completeText(String prompt);
}

/// Astrae il motore astrologico su effemeridi svizzere (FreeAstroAPI).
///
/// I dati astrologici non sono mai generati dall'AI: provengono da qui.
abstract interface class AstroEngine {
  /// Calcola i dati della carta natale per data, ora e luogo di nascita.
  Future<Map<String, dynamic>> computeNatalChart({
    required DateTime birthDate,
    DateTime? birthTime,
    required double latitude,
    required double longitude,
  });
}

/// Astrae la sorgente dei contenuti da cache o database, per il routing
/// dell'AI Gateway (circa il 70% delle richieste non tocca l'LLM).
abstract interface class ContentCache {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}
