/// Un singolo turno della conversazione con un Maestro.
///
/// E' un modello di dominio puro, senza dipendenze da Firebase o dalla UI, cosi'
/// lo condividono lo strato AI, lo strato di memoria e la presentazione. La
/// persistenza vera vive nel repository di memoria, qui resta solo il dato.
library;

/// Chi ha prodotto il messaggio: l'utente oppure il Maestro.
enum ChatRole { user, maestro }

/// CHE COSA porta un messaggio.
///
/// Serve a distinguere cio' che e' un RESPONSO da cio' che non lo e', e la
/// distinzione vive qui e non in una condizione scritta dentro una schermata.
///
/// **Il dato che ha fatto nascere questo tipo.** Il 2 agosto 2026, sul telefono
/// del fondatore, sotto il messaggio "per oggi hai finito le domande" compariva
/// l'invito "Vai più a fondo". Non c'e' nessuna lettura da approfondire in una
/// frase che dice che hai finito: il messaggio del limite era una bolla senza
/// marca, quindi l'app lo scambiava per una risposta del Maestro.
enum TipoDiMessaggio {
  /// La domanda della persona.
  domanda,

  /// Una lettura vera del Maestro. E' l'UNICO tipo che si puo' approfondire.
  responso,

  /// Una lettura che l'app ha messo al posto della voce, dichiarandolo.
  ripiego,

  /// Le domande del giorno sono finite.
  limiteRaggiunto,

  /// Un guasto: la voce non ha risposto.
  errore,

  /// Un invito ad aprire una funzione immersiva.
  instradamento,
}

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
    this.tipo,
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

  /// Che cosa porta questo messaggio. Nullo sui messaggi vecchi, e in quel
  /// caso lo si RICAVA dai flag: cosi' la cronologia gia' salvata non perde il
  /// senso e non serve una migrazione.
  final TipoDiMessaggio? tipo;

  /// Il tipo, sempre. Ricavato quando non e' dichiarato.
  TipoDiMessaggio get tipoEffettivo {
    if (tipo != null) return tipo!;
    if (isUser) return TipoDiMessaggio.domanda;
    if (intentId != null) return TipoDiMessaggio.instradamento;
    if (ripiego) return TipoDiMessaggio.ripiego;
    if (failed) return TipoDiMessaggio.errore;
    return TipoDiMessaggio.responso;
  }

  /// Vero se questo messaggio porta una lettura da poter approfondire.
  ///
  /// E' la regola di 1d, e vive QUI: chiedere di andare piu' a fondo su una
  /// frase che annuncia un limite non vuol dire niente.
  bool get portaUnResponso => tipoEffettivo == TipoDiMessaggio.responso;

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
      tipo: tipo,
      intentId: intentId,
    );
  }
}
