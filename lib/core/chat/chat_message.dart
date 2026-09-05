/// Un singolo turno della conversazione con un Maestro.
///
/// E' un modello di dominio puro, senza dipendenze da Firebase o dalla UI, cosi'
/// lo condividono lo strato AI, lo strato di memoria e la presentazione. La
/// persistenza vera vive nel repository di memoria, qui resta solo il dato.
library;

import '../maestro/maestro.dart';

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
    this.seguito,
    this.seguitoInArrivo = false,
    this.tipo,
    this.intentId,
    this.autore,
    this.conversazione,
  });

  final ChatRole role;
  final String text;

  /// **A QUALE CONVERSAZIONE APPARTIENE. Ordine CI voce 06.**
  ///
  /// Nullo per tutti i messaggi scritti prima di questa voce, e vuol dire "la
  /// prima conversazione": **nessuna migrazione**. E' la ragione per cui la
  /// conversazione e' una MARCATURA e non un documento a parte, ed e' la
  /// decisione delegata di questa voce.
  final String? conversazione;

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

  /// IL SEGUITO, cioe' il testo che il Maestro ha scritto SOTTO la risposta
  /// gia' data, quando la persona ha toccato la freccia.
  ///
  /// Nullo vuol dire che nessuno l'ha chiesto. Sta in un campo suo e non
  /// attaccato a `text` perche' la bolla lo mette in un posto preciso, fra il
  /// corpo e la riga del consiglio, e un testo incollato in coda finirebbe
  /// SOTTO il consiglio, che e' esattamente cio' che non deve succedere.
  final String? seguito;

  /// VERO MENTRE IL SEGUITO STA ARRIVANDO, e il testo resta dov'e'.
  ///
  /// **Perche' non basta `pending`.** Con `pending` la bolla si svuota e mostra
  /// i puntini: e' giusto per una risposta che ancora non esiste, ed e'
  /// sbagliato per un seguito, perche' il primo strato la persona lo sta
  /// leggendo proprio adesso. Toglierglielo di sotto agli occhi per qualche
  /// secondo, e poi rimetterlo, e' il difetto che il fondatore ha visto:
  /// pagava l'attesa due volte.
  ///
  /// Con questo il testo non si muove di un carattere: sotto compare una riga
  /// discreta che dice che sta scendendo dell'altro.
  final bool seguitoInArrivo;

  /// CHI ha detto questo messaggio, quando non e' il Maestro della chat.
  ///
  /// **Il dato che ha fatto nascere questo campo.** Dal 3 agosto 2026 gli altri
  /// due Maestri rispondono NELLA STESSA conversazione, e una bolla non
  /// appartiene piu' alla schermata ma a chi l'ha detta. Prima il volto e il
  /// colore li dava la schermata: senza questo campo, riaprendo domani la
  /// cronologia, le risposte di Aura e Caligo comparirebbero col volto e col
  /// blu di Medora, cioe' l'app direbbe il falso su chi ha parlato.
  ///
  /// Nullo vuol dire "il Maestro di questa chat", che e' anche il senso giusto
  /// per tutta la cronologia salvata prima di oggi: nessuna migrazione.
  final Maestro? autore;

  /// Chi ha parlato, sempre. [predefinito] e' il Maestro della conversazione.
  Maestro autoreEffettivo(Maestro predefinito) => autore ?? predefinito;

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
    String? seguito,
    bool? seguitoInArrivo,
  }) {
    return ChatMessage(
      role: role,
      text: text ?? this.text,
      at: at,
      // La marcatura della conversazione viaggia con la copia: un messaggio
      // che cambia stato non cambia conversazione.
      conversazione: conversazione,
      pending: pending ?? this.pending,
      failed: failed ?? this.failed,
      ripiego: ripiego ?? this.ripiego,
      approfondita: approfondita ?? this.approfondita,
      seguito: seguito ?? this.seguito,
      seguitoInArrivo: seguitoInArrivo ?? this.seguitoInArrivo,
      tipo: tipo,
      intentId: intentId,
      autore: autore,
    );
  }
}
