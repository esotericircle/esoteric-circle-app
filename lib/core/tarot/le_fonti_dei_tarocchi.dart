import 'i_mazzi_dei_tarocchi.dart';
import 'tarot_spread_type.dart';

/// **IL PANNELLO FONTI E METODO DEI TAROCCHI, col mazzo e la stesa veri.**
/// Ordine FK, aggiunta voce A5, 11 ottobre 2026.
///
/// **LA PREMESSA DELL'ORDINE ERA SBAGLIATA A META'.** L'Architetto scriveva
/// che nei file dei tarocchi `FoglioDelleFonti` compariva zero volte: c'era
/// gia', nella barra della stesa (`stesa_tre_carte_screen.dart`, chiave
/// `tarocchi_fonti`, dall'ordine CS voce S2). La ricerca era stata fatta sui
/// percorsi che contengono "taroc", e la cartella si chiama `tarot`. **Era
/// vera l'altra meta'**: il pannello mostrava un testo fisso,
/// `TestiDelleFonti.tarocchi`, che diceva "la stesa a tre carte" e "il mazzo
/// Rider-Waite-Smith" a chiunque, anche a chi aveva steso una Croce Celtica
/// col mazzo di Marsiglia, e il campo `TarotSpreadType.fonte` con la citazione
/// di Waite non arrivava mai a video.
///
/// Adesso il pannello dice il mazzo scelto e la sua storia, la stesa scelta
/// con la fonte delle sue posizioni (per la Croce Celtica la citazione
/// corretta dall'ordine FK voce 16, Parte III sezione 7, e il grado della
/// fonte, voce 15), e da dove vengono i significati.
class LeFontiDeiTarocchi {
  const LeFontiDeiTarocchi._();

  /// La storia del mazzo, una frase per mazzo.
  static String delMazzo(TarotDeckStyle mazzo) => switch (mazzo) {
        TarotDeckStyle.riderWaite =>
          'Il mazzo è il Rider-Waite-Smith, disegnato nel 1909 da Pamela '
              'Colman Smith su indicazione di Arthur Edward Waite: è il mazzo su '
              'cui si regge quasi tutta la cartomanzia moderna.',
        TarotDeckStyle.marsiglia =>
          'Il mazzo è quello di Marsiglia, la tradizione dei tarocchi '
              'francesi del Seicento e del Settecento; il modello di '
              'riferimento è il mazzo di Nicolas Conver, Marsiglia, 1760.',
        TarotDeckStyle.thoth =>
          'Il mazzo è il Thoth, dipinto da Lady Frieda Harris su indicazione '
              'di Aleister Crowley fra il 1938 e il 1943 e pubblicato nel '
              '1969.',
      };

  /// **IL GRADO DELLA FONTE DI WAITE**, ordine FK voce 15: il testo della
  /// Croce Celtica e' verificato su una trascrizione sola, senza il facsimile
  /// della stampa, e la voce lo dichiara invece di tacerlo.
  static const String gradoDiWaite = 'Il testo di Waite è stato verificato su '
      'una sola trascrizione, senza il facsimile della stampa del 1911: per '
      'questo è una fonte di grado basso.';

  /// Il testo intero del pannello, per il mazzo e la stesa di questa lettura.
  static String testo(TarotDeckStyle mazzo, TarotSpreadType stesa) {
    final waite = stesa == TarotSpreadType.dieciCarte ? ' $gradoDiWaite' : '';
    return '${delMazzo(mazzo)} I significati di ogni carta vengono dalla '
        'tradizione di Waite, The Pictorial Key to the Tarot, anche quando il '
        'mazzo è un altro.\n\n'
        'La stesa è "${stesa.nome}": ${stesa.descrizione.toLowerCase()}. Le '
        'sue posizioni vengono da qui: ${stesa.fonte}$waite\n\n'
        'Il dritto e il rovescio sono due letture della stessa carta: il '
        'rovescio non è una condanna, è un nodo da sciogliere. Le carte escono '
        'da un mescolamento vero, che parte dalla tua domanda e dal momento in '
        'cui la fai. Le parole con cui Medora le racconta sono curatela del '
        'Cerchio, scritte sul senso tradizionale di ogni carta.';
  }
}
