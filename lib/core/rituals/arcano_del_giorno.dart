import '../tarot/tarot_card.dart';

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

  /// La carta di [giorno].
  ///
  /// **Il conto non e' il giorno dell'anno**, che darebbe a tutti gli anni la
  /// stessa carta nello stesso giorno e farebbe tornare il Matto ogni
  /// ventidue giorni esatti, cioe' un ciclo che si riconosce. Qui si mescola
  /// anche l'anno e il mese, con una moltiplicazione di numeri primi: resta
  /// deterministico e ripetibile, ma il passo non si legge a occhio.
  static TarotCard di(DateTime giorno) {
    final carte = maggiori;
    final seme = giorno.year * 10000 + giorno.month * 100 + giorno.day;
    final mescolato = (seme * 2654435761) ^ (seme >> 3);
    return carte[mescolato.abs() % carte.length];
  }

  /// Il colpo d'occhio: una frase sola, quella che il corpus dei tarocchi ha
  /// gia' scritto come sommario della carta diritta.
  static String sommarioDi(DateTime giorno) => di(giorno).uprightSummary;

  /// Il responso della giornata: il testo della carta diritta, che nel corpus
  /// e' gia' scritto in seconda persona e finisce con cosa fare.
  static String responsoDi(DateTime giorno) => di(giorno).upright;
}
