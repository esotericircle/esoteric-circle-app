/// LE SCADENZE DEI DATI SUL TELEFONO. Ordine CB voce 05.
///
/// **Parole del fondatore, 29 agosto 2026:** "sara' Code a decidere per quanto
/// tempo ogni dato o categoria di dati rimarra' memorizzato secondo il miglior
/// rapporto logica/costo, magari facendosi guidare dall'esperienza di altre
/// app. decide Code, non l'hai ancora capito? e chiaramente deve motivarlo."
///
/// **Il censimento ha trovato una cosa che vale la pena dire prima dei
/// numeri.** Sul telefono il Cerchio tiene pochissimo, e quasi tutto si limita
/// da solo: la parola del giorno si riscrive ogni giorno, il registro del
/// borsellino tiene otto movimenti, le letture del viso ne tengono quaranta, e
/// il resto sono interruttori (permesso chiesto, avviso gia' proposto, ingresso
/// fatto) che non sono contenuto. **Le uniche memorie che crescono nel tempo e
/// che nessuno rilegge sono due**, e sono quelle che scadono qui.
///
/// **Cosa NON scade, e perche' e' una decisione e non una dimenticanza:**
///
/// - **Il cammino, i Sigilli, il borsellino, la carta natale, il profilo.**
///   Non sono storia, sono cio' che la persona ha guadagnato o dato: farli
///   scadere vorrebbe dire togliere a qualcuno il suo lavoro mentre non
///   guarda. Se ne vanno con la cancellazione, e solo con quella.
/// - **Le coppie della Sinastria.** E' una collezione, come i Sigilli: chi
///   colleziona rilegge, e una collezione che si assottiglia da sola sarebbe
///   una promessa rotta.
/// - **Gli interruttori** (`avvisi.`, `permesso.`, `onboarding.`, `device.id`).
///   Occupano byte e non raccontano niente di nessuno: scaderli non farebbe
///   guadagnare niente e farebbe ricomparire domande gia' fatte.
library;

/// Quanto resta una memoria che cresce nel tempo, con la ragione scritta.
class ScadenzaDelTelefono {
  const ScadenzaDelTelefono({
    required this.nome,
    required this.giorni,
    required this.perche,
  });

  /// Come si chiama nel manifesto e nella privacy policy.
  final String nome;

  /// Dopo quanti giorni quella riga non serve piu' a nessuno.
  final int giorni;

  /// Perche' proprio quel numero. Una riga, e non e' facoltativa: e' il
  /// fondatore a pretenderla.
  final String perche;

  Duration get quanto => Duration(days: giorni);

  /// Vero se una riga scritta in [quando] e' scaduta rispetto a [adesso].
  bool scaduta(DateTime quando, DateTime adesso) =>
      adesso.difference(quando) > quanto;
}

/// IL LISTINO DELLE SCADENZE DEL TELEFONO.
///
/// Due voci sole, e sono le due che il censimento ha trovato: due liste che
/// crescono a ogni gesto e che nessuno riapre dopo mesi.
abstract final class ScadenzeDelTelefono {
  /// Le letture del viso, che sono testo e non immagini, ma parlano del corpo
  /// di una persona.
  static const viso = ScadenzaDelTelefono(
    nome: 'Le tue letture del viso',
    giorni: 730,
    perche: 'il gradino del volto che cambia guarda indietro di un mese e il '
        'limite del giorno guarda l\'oggi. Due anni sono più di ogni regola '
        'che li legge. Una lettura del proprio volto è un dato del corpo. Non '
        'si tiene per sempre solo perché costa poco tenerlo.',
  );

  /// Lo storico dell'Archetipo, che regge la regola dei tre mesi.
  static const archetipo = ScadenzaDelTelefono(
    nome: 'Lo storico del tuo Archetipo',
    giorni: 730,
    perche: 'la regola che governa il test guarda gli ultimi tre mesi. La '
        'scheda mostra l\'ultimo risultato. Due anni tengono in piedi tutte e '
        'due con un margine largo. Quello che sta più indietro non lo apre '
        'nessuno.',
  );

  /// Le due voci insieme, per chi le deve scorrere o raccontare.
  static const List<ScadenzaDelTelefono> tutte = [viso, archetipo];
}
