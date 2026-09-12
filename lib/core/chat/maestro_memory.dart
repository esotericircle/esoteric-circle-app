/// Memoria che un Maestro conserva sull'utente, oltre al profilo condiviso.
///
/// Sono gli altri due strati della memoria a tre livelli dei briefing: i fatti
/// stabili emersi parlando col Maestro e la sintesi della sessione, che tiene
/// il filo del discorso senza dover rileggere ogni messaggio. Per la Demo la
/// persistenza e' su Firestore; l'evoluzione verso Cloud SQL con pgvector resta
/// dietro la stessa astrazione, senza toccare la UI.
library;

/// Il distillato che l'AI produce dalla conversazione per la memoria: una
/// sintesi breve piu' un elenco di fatti stabili sull'utente.
class MemoryDigest {
  const MemoryDigest({required this.summary, required this.facts});

  final String summary;
  final List<String> facts;

  bool get isEmpty => summary.trim().isEmpty && facts.isEmpty;
}

/// Memoria di un Maestro su un utente: fatti stabili e sintesi di sessione.
class MaestroMemory {
  const MaestroMemory({
    this.facts = const [],
    this.sessionSummary = '',
  });

  /// Fatti stabili emersi nel dialogo (per esempio un segno, una domanda
  /// ricorrente, un obiettivo dichiarato). Restano fra le sessioni.
  final List<String> facts;

  /// Sintesi in prosa dell'andamento della relazione col Maestro.
  final String sessionSummary;

  bool get isEmpty => facts.isEmpty && sessionSummary.trim().isEmpty;

  MaestroMemory copyWith({List<String>? facts, String? sessionSummary}) {
    return MaestroMemory(
      facts: facts ?? this.facts,
      sessionSummary: sessionSummary ?? this.sessionSummary,
    );
  }

  static const MaestroMemory empty = MaestroMemory();
}
