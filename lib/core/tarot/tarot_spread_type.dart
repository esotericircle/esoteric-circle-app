import '../entitlement/plan_catalog.dart';
import '../entitlement/tier.dart';
import 'le_carte_nella_posizione.dart';
import 'tarot_spread.dart';

/// UN POSTO SUL TAVOLO: dove va una carta della stesa e se sta di traverso.
///
/// Ordine FI voce 02, 10 ottobre 2026: la geometria e' un dato, accanto alle
/// posizioni, e la schermata la legge invece di disporre le carte a mano.
/// [x] e [y] sono il centro della carta, misurati in larghezze di carta dal
/// centro della figura, con la [y] che cresce verso il basso; una carta e'
/// alta una larghezza e mezza.
class PostoSulTavolo {
  const PostoSulTavolo(this.x, this.y, {this.diTraverso = false});
  final double x, y;

  /// La carta girata di un quarto, come la seconda della Croce Celtica.
  final bool diTraverso;
}

/// I tipi di stesa che il Cerchio offre.
///
/// Il nome non e' una stringa scritta a mano nella schermata: e' un dato della
/// definizione della stesa. Cosi' il titolo in alto segue da solo la stesa
/// attiva, e quando arriveranno quelle da sette e dieci carte non ci sara' da
/// ricordarsi di cambiare anche il titolo.
///
/// **CINQUE STESE** dall'ordine FI voce 01, 10 ottobre 2026 (il fondatore:
/// "bisogna inserire la stesa a 1 carta e quelle delle tradizioni piu'
/// popolari"). Ognuna porta le sue posizioni nell'ordine di lettura, il suo
/// posto sul tavolo per ogni carta e la sua fonte; quante carte ha lo dicono
/// le posizioni.
enum TarotSpreadType {
  unaCarta(
    nome: 'Stesa a una Carta',
    breve: 'Una Carta',
    descrizione: 'La carta sola',
    posizioni: [SpreadPosition.cartaSola],
    tavolo: [PostoSulTavolo(0, 0)],
    fonte: 'La carta del giorno della cartomanzia, forma minima della '
        'lettura.',
    costruita: false,
  ),
  treCarte(
    nome: 'Stesa di Tarocchi',
    breve: 'Tre Carte',
    descrizione: 'Passato, Presente, Futuro',
    posizioni: SpreadPosition.treCarte,
    tavolo: [
      PostoSulTavolo(-1.15, 0),
      PostoSulTavolo(0, 0),
      PostoSulTavolo(1.15, 0),
    ],
    fonte: 'Etteilla per le posizioni fisse, anni 1780; diffusa da Eden '
        'Gray, The Tarot Revealed, 1960.',
    costruita: true,
  ),
  croceQuattro(
    nome: 'Stesa a Croce',
    breve: 'Quattro Carte',
    descrizione: 'La croce',
    // Nell'ordine di lettura di Dora: il consultante in basso, il lato a
    // sinistra, il lato a destra, l'esito in alto.
    posizioni: [
      SpreadPosition.consultante,
      SpreadPosition.lato,
      SpreadPosition.lato,
      SpreadPosition.esito,
    ],
    tavolo: [
      PostoSulTavolo(0, 1.6),
      PostoSulTavolo(-1.15, 0),
      PostoSulTavolo(1.15, 0),
      PostoSulTavolo(0, -1.6),
    ],
    fonte: 'Il tirage en croix della tradizione francese, letto col mazzo di '
        'Marsiglia; la variante dei due lati aperti è la lettura del Cerchio.',
    costruita: false,
  ),
  // **LAPIDE: la Stesa del Ferro di Cavallo, sette carte** (passato,
  // presente, futuro, consiglio, ambiente, ostacolo, esito). Tolta
  // dall'ordine FJ, aggiunta 2, 11 ottobre 2026, per decisione del fondatore
  // ("Il ferro di cavallo va tolto", "resta il no"). Due ragioni: quelle sette
  // posizioni non hanno nessuna fonte (non Mathers 1888, che la forma la
  // usa con ventisei carte e senza posizioni; non il manoscritto bolognese);
  // e la stesa a sette documentata, il metodo rapido di Papus (The Tarot of
  // the Bohemians, 1892, cap. XX, pp. 322-324), vuole due estrazioni da due
  // mazzi ridotti, lavoro nuovo sul motore della stesa che non vale il
  // tempo. Se il motore cambiasse, Papus e' pronto e vorrebbe tre posizioni
  // nuove: inizio, culmine, declino.
  dieciCarte(
    nome: 'Stesa della Croce Celtica',
    breve: 'Dieci Carte',
    descrizione: 'La Croce Celtica',
    // Nell'ordine di Waite. La sesta carta, il davanti, e' il futuro: "This
    // is before him. It shews the influence that is coming into action and
    // will operate in the near future." La quinta, il dietro, ha la sua
    // posizione dall'ordine FK voce 8: "This is behind him. It gives the
    // influence that is just passed, or is now passing away." Due stati, che
    // il passato della stesa a tre carte non regge; e il confine con la
    // quarta, il fondamento, e' il piu' costoso della stesa.
    posizioni: [
      SpreadPosition.copre,
      SpreadPosition.attraversa,
      SpreadPosition.corona,
      SpreadPosition.sotto,
      SpreadPosition.dietro,
      SpreadPosition.futuro,
      SpreadPosition.seStesso,
      SpreadPosition.laCasa,
      SpreadPosition.speranzeOTimori,
      SpreadPosition.esito,
    ],
    // La figura di Waite: la croce con la seconda carta di traverso sulla
    // prima, e a destra il bastone di quattro carte, dal basso in alto.
    tavolo: [
      PostoSulTavolo(0, 0),
      PostoSulTavolo(0, 0, diTraverso: true),
      PostoSulTavolo(0, -1.65),
      PostoSulTavolo(0, 1.65),
      PostoSulTavolo(-1.6, 0),
      PostoSulTavolo(1.6, 0),
      PostoSulTavolo(3.4, 2.4),
      PostoSulTavolo(3.4, 0.8),
      PostoSulTavolo(3.4, -0.8),
      PostoSulTavolo(3.4, -2.4),
    ],
    // Il luogo esatto, ordine FK voce 16: Parte III, sezione 7, non un
    // capitolo (docs/corpus/tarocchi_posizione/verifica_waite_1911.md).
    fonte: 'Arthur Edward Waite, The Pictorial Key to the Tarot, 1911, '
        'Parte III, sezione 7, "An Ancient Celtic Method of Divination".',
    costruita: false,
  );

  const TarotSpreadType({
    required this.nome,
    required this.breve,
    required this.descrizione,
    required this.posizioni,
    required this.tavolo,
    required this.fonte,
    required this.costruita,
  });

  /// Il nome per esteso, quello che va nel titolo della schermata.
  final String nome;

  /// Il nome corto, per i selettori e il riepilogo.
  final String breve;

  /// Quante carte compongono la stesa: quante posizioni ha.
  int get carte => posizioni.length;

  /// Le posizioni nell'ordine di lettura. Una posizione puo' tornare due
  /// volte, come il lato nella croce di Dora: il posto lo dice l'indice.
  final List<SpreadPosition> posizioni;

  /// Dove va ogni carta, una voce per posizione, nello stesso ordine.
  final List<PostoSulTavolo> tavolo;

  /// La tradizione da cui viene la stesa, per il Foglio delle Fonti.
  final String fonte;

  /// Cosa promette la stesa, in poche parole.
  final String descrizione;

  /// Se la schermata sa gia' stenderla, geometria e lettura comprese.
  final bool costruita;

  /// **SE E' GIA' APRIBILE o se resta Coming soon col lucchetto.**
  /// Ordine FI, aggiunta A6 e A7: una stesa costruita si apre solo quando
  /// tutte le sue posizioni hanno la fonte del corpus, mai ripiegando sul
  /// testo del verso. La stesa a tre carte ce l'ha dall'ordine EQ.
  bool get disponibile =>
      costruita && posizioni.every(LeCarteNellaPosizione.haLaFonte);

  /// La stesa della Demo, l'unica viva.
  static const TarotSpreadType predefinita = TarotSpreadType.treCarte;

  /// **SE QUESTO PIANO PUO' APRIRE QUESTA STESA.** Ordine EX voce 02: la
  /// stesa da dieci carte solo dall'Adepto, *"la stesa a 10 solo dal tier 2
  /// 19,99"*. Una stesa non ancora disponibile non si apre per nessuno.
  ///
  /// Ordine FI voce 32: la croce dall'Iniziato, la carta sola e le tre carte
  /// a tutti (il ferro di cavallo, che apriva dall'Adepto, e' tolto
  /// dall'ordine FJ, aggiunta 2).
  bool apribileDa(Tier tier) =>
      disponibile &&
      switch (this) {
        TarotSpreadType.unaCarta || TarotSpreadType.treCarte => true,
        TarotSpreadType.croceQuattro =>
          PlanCatalog.apre(RigaDelPiano.stesaACroce, tier),
        TarotSpreadType.dieciCarte => PlanCatalog.haLaStesaDaDieci(tier),
      };
}
