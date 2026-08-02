/// Un singolo turno della conversazione con un Maestro.
///
/// E' un modello di dominio puro, senza dipendenze da Firebase o dalla UI, cosi'
/// lo condividono lo strato AI, lo strato di memoria e la presentazione. La
/// persistenza vera vive nel repository di memoria, qui resta solo il dato.
library;

/// Chi ha prodotto il messaggio: l'utente oppure il Maestro.
enum ChatRole { user, maestro }

/// Messaggio della conversazione, con testo, autore e istante.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.at,
    this.pending = false,
    this.failed = false,
    this.ripiego = false,
    this.approfondita = false,
    this.intentId,
  });

  final ChatRole role;
  final String text;

  /// Se il messaggio del Maestro instrada verso una funzione immersiva, l'id
  /// dell'intento: la bolla mostra il pulsante che la apre. Nullo altrimenti.
  final String? intentId;

  /// Istante di creazione, se noto (dal server in persistenza).
  final DateTime? at;

  /// Vero mentre il Maestro sta ancora componendo la risposta: la UI mostra
  /// l'indicatore astrale al posto della bolla piena.
  final bool pending;

  /// Vero se l'invio non e' andato a buon fine: la UI offre di riprovare.
  final bool failed;

  /// Vero se questo testo NON viene dal Maestro ma da un ripiego dell'app.
  /// Distinto da [failed], che dice solo che si puo' riprovare: un ripiego puo'
  /// essere una risposta compiuta e leggibile, e proprio per questo va
  /// dichiarato, altrimenti la persona la scambia per la voce del Maestro.
  final bool ripiego;

  /// Vero se questa risposta e' gia' stata portata piu' a fondo. L'invito
  /// "Vai piu' a fondo" compare una volta sola per risposta: due volte sarebbe
  /// una scala senza fine, e la persona non saprebbe quando si e' arrivati.
  final bool approfondita;

  bool get isUser => role == ChatRole.user;
  bool get isMaestro => role == ChatRole.maestro;

  ChatMessage copyWith({
    String? text,
    bool? pending,
    bool? failed,
    bool? ripiego,
    bool? approfondita,
  }) {
    return ChatMessage(
      role: role,
      text: text ?? this.text,
      at: at,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
      ripiego: ripiego ?? this.ripiego,
      approfondita: approfondita ?? this.approfondita,
      intentId: intentId,
    );
  }
}
