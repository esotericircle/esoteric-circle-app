import '../tarot/tarot_card.dart';

/// LA CARTA DI NASCITA DEI TAROCCHI. Ordine CE voce 13.
///
/// **E' tradizione documentata, non un'invenzione di questa app.** Il calcolo
/// della carta natale dei tarocchi nasce nella linea della Golden Dawn e viene
/// codificato nella pratica moderna da Angeles Arrien e Mary K. Greer: si
/// sommano le cifre della data di nascita, si riduce la somma sotto il ventidue
/// e il numero che resta indica un Arcano Maggiore, che accompagna quella
/// persona per tutta la vita.
///
/// **Perche' serve qui.** Il quarto fumetto del tutorial promette che i cinque
/// Doni nascono "incrociando il Cielo di oggi e la tua Carta natale". L'Arcano
/// del Giorno, misurato, non incrociava niente: il seme veniva dal solo giorno
/// del calendario, quindi era la stessa carta per tutti quanti. Questa e' la
/// via che la tradizione dei tarocchi offre per legare una persona al mazzo,
/// ed e' quella che l'app usa invece di inventarne una.
///
/// **Il numero e la carta non si confondono.** Nella pratica il ventidue si
/// riporta al Matto, che nel mazzo porta lo zero: qui il numero resta com'e'
/// nella tradizione e la corrispondenza col mazzo la fa una funzione sola.
abstract final class CartaDiNascitaDeiTarocchi {
  /// Il numero della carta di nascita, da 1 a 22, dalla data di nascita.
  ///
  /// Si sommano tutte le cifre di giorno, mese e anno; se la somma supera
  /// ventidue si sommano di nuovo le sue cifre, finche' non ci sta.
  static int numeroDi(DateTime nascita) {
    var somma =
        _cifre(nascita.day) + _cifre(nascita.month) + _cifre(nascita.year);
    while (somma > 22) {
      somma = _cifre(somma);
    }
    // Una data non puo' dare zero, ma una difesa costa una riga e vale
    // un'eccezione in meno.
    return somma == 0 ? 22 : somma;
  }

  /// L'Arcano Maggiore che corrisponde al numero di nascita.
  ///
  /// Il mazzo numera il Matto con lo zero e il Mondo con ventuno; la
  /// tradizione numera da uno a ventidue e riporta il ventidue al Matto.
  static TarotCard cartaDi(DateTime nascita) {
    final n = numeroDi(nascita);
    final maggiori = TarotDeck.cards
        .where((c) => c.arcana == TarotArcana.maggiore)
        .toList(growable: false);
    return maggiori[n % maggiori.length];
  }

  static int _cifre(int n) {
    var v = n.abs();
    var s = 0;
    while (v > 0) {
      s += v % 10;
      v ~/= 10;
    }
    return s;
  }
}
