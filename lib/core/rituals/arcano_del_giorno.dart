import '../tarot/tarot_card.dart';
import 'carta_di_nascita_dei_tarocchi.dart';

/// L'ARCANO DEL GIORNO. Ordine AS voce 08.
///
/// **Cosa cambia, e perche' lo decide Mauro.** L'Oracolo del Giorno era una
/// riga presa a giro da un elenco di ventidue frasi, la stessa per tutti e
/// legata solo al giorno dell'anno: si leggeva come un biscotto della fortuna.
/// Adesso il dono e' l'estrazione di UNA CARTA dei soli Arcani Maggiori, che e'
/// una tradizione vera, ha un'immagine da guardare e porta con se' un
/// significato che il progetto ha gia' scritto e verificato.
///
/// **Si prende spunto dalla Stesa, ma la scena resta semplice**: una carta, un
/// colpo d'occhio in una frase e un responso diretto. Non una lezione di
/// tarocchi: chi apre l'app vuole sapere cosa fare oggi, non imparare gli
/// arcani.
///
/// **PERCHE' SOLO DIRITTA, e non si e' dimenticato il rovescio.** Nella Stesa
/// la carta rovescia esiste e ha il suo senso, perche' li' si legge un
/// intreccio di tre carte e il rovescio e' una sfumatura dentro un discorso.
/// Qui la carta e' UNA e il responso e' la risposta della giornata: una carta
/// rovescia obbligherebbe a spiegare cos'e' il rovescio prima di dire qualcosa
/// di utile, cioe' esattamente la lezione che questa voce toglie.
///
/// **Deterministico dal giorno**: la stessa carta per tutta la giornata, e se
/// la riapri e' quella. Un dono che cambia a ogni apertura non e' un dono.
class ArcanoDelGiorno {
  const ArcanoDelGiorno._();

  /// I soli Arcani Maggiori, nell'ordine del mazzo: dal Matto al Mondo.
  static List<TarotCard> get maggiori => TarotDeck.cards
      .where((c) => c.arcana == TarotArcana.maggiore)
      .toList(growable: false);

  /// La carta di [giorno], per chi e' nato il [nascita].
  ///
  /// **Il conto non e' il giorno dell'anno**, che darebbe a tutti gli anni la
  /// stessa carta nello stesso giorno e farebbe tornare il Matto ogni
  /// ventidue giorni esatti, cioe' un ciclo che si riconosce. Qui si mescola
  /// anche l'anno e il mese, con una moltiplicazione di numeri primi: resta
  /// deterministico e ripetibile, ma il passo non si legge a occhio.
  ///
  /// **E DAL 30 AGOSTO 2026 NON E\' PIU\' LA STESSA CARTA PER TUTTI.**
  /// Ordine CE voce 13. Il quarto fumetto del tutorial promette che i
  /// cinque Doni nascono "incrociando il Cielo di oggi e la tua Carta
  /// natale", e questo Dono, misurato, non incrociava niente: il seme
  /// veniva dal solo calendario. Adesso nel seme entra anche la CARTA DI
  /// NASCITA DEI TAROCCHI, che non e' una formula inventata qui ma la via
  /// che la tradizione del mazzo offre da sempre per legare una persona
  /// agli Arcani (vedi `CartaDiNascitaDeiTarocchi`).
  ///
  /// **Chi non ha dato la nascita non perde il Dono**: senza data il conto
  /// e' esattamente quello di prima, e la carta resta quella del giorno.
  /// Un'app che chiedesse la nascita per aprire un Dono sarebbe un
  /// pedaggio, e questo Dono si riceve appena si arriva.
  static TarotCard di(DateTime giorno, {DateTime? nascita}) {
    final carte = maggiori;
    final seme = giorno.year * 10000 + giorno.month * 100 + giorno.day;
    var mescolato = (seme * 2654435761) ^ (seme >> 3);
    if (nascita != null) {
      // Il numero della carta di nascita entra nel seme come fattore, non
      // come somma: una somma avrebbe solo traslato l'elenco, e due
      // persone a un giorno di distanza avrebbero visto la carta che
      // l'altra aveva ieri.
      // **E LA NASCITA INTERA, NON SOLO LA CARTA NATALE.**
      // Ordine CQ voce 2.05, 3 settembre 2026.
      //
      // **Il fatto, parole del fondatore:** l'Arcano non e' individuale.
      // Misurato: nel seme entrava il solo NUMERO della carta natale, che
      // vale da uno a ventidue. **Due persone con la stessa carta natale
      // vedevano la stessa carta ogni giorno, per sempre**, anche essendo
      // nate a vent'anni di distanza: la parte personale del seme aveva
      // ventidue valori in tutto, e un ventiduesimo del mondo era un blocco
      // solo che si muoveva insieme.
      //
      // **Le carte restano ventidue, e non e' quello il punto.** In un
      // giorno solo non possono uscire piu' di ventidue carte diverse,
      // qualunque seme si usi. Cio' che cambia e' che due persone nate in
      // giorni diversi si scorrelano: prima coincidevano il 100 per cento
      // dei giorni, adesso circa un giorno su ventidue, che e' quanto ci si
      // aspetta da due estrazioni indipendenti.
      //
      // **La carta natale resta**, perche' e' la via che la tradizione del
      // mazzo offre per legare una persona agli Arcani, ed e' il legame che
      // il tutorial promette. Entra come uno dei fattori, non come l'unico.
      final natale = CartaDiNascitaDeiTarocchi.numeroDi(nascita);
      final giornoDiNascita =
          nascita.year * 10000 + nascita.month * 100 + nascita.day;
      final oraDiNascita = nascita.hour * 60 + nascita.minute;
      mescolato = (mescolato ^ (natale * 2246822519)) * 40503;
      mescolato = (mescolato ^ (giornoDiNascita * 2654435761)) * 2246822519;
      mescolato = (mescolato ^ (oraDiNascita * 40503)) * 668265263;
    }
    return carte[mescolato.abs() % carte.length];
  }

  /// Il colpo d'occhio: una frase sola, quella che il corpus dei tarocchi ha
  /// gia' scritto come sommario della carta diritta.
  static String sommarioDi(DateTime giorno, {DateTime? nascita}) =>
      di(giorno, nascita: nascita).uprightSummary;

  /// Il responso della giornata: il testo della carta diritta, che nel corpus
  /// e' gia' scritto in seconda persona e finisce con cosa fare.
  static String responsoDi(DateTime giorno, {DateTime? nascita}) =>
      di(giorno, nascita: nascita).upright;
}
