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
  });

  final ChatRole role;
  final String text;

  /// Istante di creazione, se noto (dal server in persistenza).
  final DateTime? at;

  /// Vero mentre il Maestro sta ancora componendo la risposta: la UI mostra
  /// l'indicatore astrale al posto della bolla piena.
  final bool pending;

  /// Vero se l'invio non e' andato a buon fine: la UI offre di riprovare.
  final bool failed;

  bool get isUser => role == ChatRole.user;
  bool get isMaestro => role == ChatRole.maestro;

  ChatMessage copyWith({String? text, bool? pending, bool? failed}) {
    return ChatMessage(
      role: role,
      text: text ?? this.text,
      at: at,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
    );
  }
}
