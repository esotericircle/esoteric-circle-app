library;

import 'lettura_degli_ancoraggi.dart';
import 'sentieri.dart';

/// COME SI RICONOSCE UN TRAGUARDO SU CIASCUNA DELLE TRE ARTI. Ordine T voce 01.
///
/// **Una regola per sentiero, perche' le tre arti non si somigliano.** Sul
/// sentiero di Caligo le sfere sono GRIGIE in mezzo all'oro e al rosso: il segno
/// e' l'assenza di colore, non la sua presenza. Sui due sentieri che passano
/// dalla strada dei pallini il segno e' il colore pieno di un pallino.
///
/// **La regola sta qui e non dentro il lettore**, cosi' un sentiero nuovo si
/// aggiunge in un punto solo e il codice che conta non si tocca.
class RegoleDelleTreArti {
  const RegoleDelleTreArti._();

  /// DOVE STA L'ARTE di un sentiero.
  static String arteDi(Sentiero sentiero) =>
      'brand_assets/sentieri/${_nomeDelFile(sentiero)}.png';

  /// DOVE STAREBBE IL LIVELLO DEI PALLINI, se quel sentiero ne ha bisogno.
  static String palliniDi(Sentiero sentiero) =>
      'brand_assets/sentieri/${_nomeDelFile(sentiero)}_pallini.png';

  static String _nomeDelFile(Sentiero sentiero) => switch (sentiero) {
        Sentiero.costellazione => 'costellazione',
        Sentiero.albero => 'albero',
        Sentiero.loto => 'loto',
      };

  /// **L'ALBERO DELLA VITA: le sfere sono NEUTRE in mezzo a un'arte calda.**
  ///
  /// Misurato sull'arte vera prima di scrivere la regola: una sfera vale
  /// rgb 195/175/173 oppure 163/149/137, cioe' rosso e blu quasi uguali; l'oro
  /// che le circonda vale 130/62/15, con centoquindici punti fra rosso e blu.
  /// **Il segno e' l'assenza di colore, e regge su tutte e cinquantacinque.**
  ///
  /// La luminanza minima toglie l'ombra: il nero fra un ramo e l'altro e' neutro
  /// anche lui, ma non e' una sfera.
  static final RegolaDiRiconoscimento albero = RegolaDiRiconoscimento(
    nome: 'albero, le sfere neutre in mezzo all\'oro',
    riconosci: (r, g, b, a) {
      if (a <= 200) return false;
      final massimo = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final minimo = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final luminanza = (r * 299 + g * 587 + b * 114) ~/ 1000;
      if (luminanza <= 45) return false;
      // Croma sotto il trenta per cento del canale piu' alto: neutro.
      return (massimo - minimo) * 100 < 30 * (massimo < 1 ? 1 : massimo);
    },
    // **VENTI PIXEL, e non viene da cio' che si e' misurato.** Sull'arte a 941
    // di larghezza venti pixel sono poco piu' di un fiammifero: sotto questa
    // misura non si sta guardando una sfera ma un riflesso su un ramo. La sfera
    // piccola vera ne misura una trentina, la grande una sessantina.
    diametroMinimo: 20,
  );

  /// **LA REGOLA DEI PALLINI**, quella della strada B.
  ///
  /// Il livello dei pallini e' un PNG alla stessa misura dell'arte, con
  /// cinquantacinque pallini pieni su fondo trasparente. Qui basta l'opacita':
  /// tutto cio' che e' opaco e' un pallino, e il colore dice a quale gruppo
  /// appartiene. **Il gruppo NON si ricava dal colore in questo punto**, si
  /// ricava dalla vicinanza al grande come sugli altri sentieri: il colore resta
  /// il modo con cui Mauro tiene il conto mentre disegna, e una prova lo
  /// confronta col gruppo trovato.
  static final RegolaDiRiconoscimento pallini = RegolaDiRiconoscimento(
    nome: 'pallini, un livello a parte',
    riconosci: (r, g, b, a) => a > 128,
    diametroMinimo: 12,
    // Un pallino pieno riempie il suo riquadro quasi del tutto: chiedere di
    // piu' che sull'arte e' giusto, perche' qui non ci sono ombre.
    pienoMinimo: 0.60,
    quadroMinimo: 0.70,
  );

  /// LA REGOLA IN USO per un sentiero, oggi.
  static RegolaDiRiconoscimento per(Sentiero sentiero) =>
      switch (sorgenteDi(sentiero)) {
        SorgenteDegliAncoraggi.arte => albero,
        SorgenteDegliAncoraggi.pallini => pallini,
      };

  /// **DA DOVE VENGONO GLI ANCORAGGI DI CIASCUN SENTIERO, e il perche' di
  /// ognuno.** Ordine T voce 02.
  ///
  /// **E' un dato, non un "se" sparso nel codice**: se un giorno l'Albero avesse
  /// il suo file di pallini, si cambia questa riga e nient'altro.
  ///
  /// - **Albero, dall'arte**: le sfere sono grigie in mezzo a un disegno caldo,
  ///   e la lettura automatica trova le cinquantacinque macchie con un baratro
  ///   fra grandi e piccoli. Chiusa nella voce T.01 e non si tocca.
  /// - **Costellazione e Loto, dai pallini**: sulla costellazione gli orbi di
  ///   lapis sono spezzati dai riflessi dorati e le mezzelune portano lo stesso
  ///   smalto blu; sul loto i petali si toccano fra loro e le foglie decorative
  ///   hanno lo stesso verde e la stessa forma. Cinque strade automatiche
  ///   misurate, nessuna arriva: il file dei pallini non e' un ripiego, e' il
  ///   dato che l'arte non porta.
  static SorgenteDegliAncoraggi sorgenteDi(Sentiero sentiero) =>
      switch (sentiero) {
        Sentiero.albero => SorgenteDegliAncoraggi.arte,
        Sentiero.costellazione => SorgenteDegliAncoraggi.pallini,
        Sentiero.loto => SorgenteDegliAncoraggi.pallini,
      };

  /// Il file da cui si leggono gli ancoraggi: l'arte stessa oppure i pallini.
  static String daDoveSiLegge(Sentiero sentiero) =>
      switch (sorgenteDi(sentiero)) {
        SorgenteDegliAncoraggi.arte => arteDi(sentiero),
        SorgenteDegliAncoraggi.pallini => palliniDi(sentiero),
      };
}

/// Le due strade per sapere dove stanno i cinquantacinque elementi.
enum SorgenteDegliAncoraggi {
  /// Si riconoscono dentro l'arte stessa.
  arte,

  /// Si leggono da un secondo PNG con cinquantacinque dischi pieni, cinque
  /// colori per i cinque gruppi, il grande di diametro doppio.
  pallini,
}
