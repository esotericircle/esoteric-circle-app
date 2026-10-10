import '../entitlement/plan_catalog.dart';
import '../entitlement/tier.dart';
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
    disponibile: false,
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
    disponibile: true,
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
    disponibile: false,
  ),
  setteCarte(
    nome: 'Stesa del Ferro di Cavallo',
    breve: 'Sette Carte',
    descrizione: 'Il ferro di cavallo',
    posizioni: [
      SpreadPosition.passato,
      SpreadPosition.presente,
      SpreadPosition.futuro,
      SpreadPosition.consiglio,
      SpreadPosition.ambiente,
      SpreadPosition.ostacolo,
      SpreadPosition.esito,
    ],
    // Un arco aperto in alto: le punte alte, il centro in basso.
    tavolo: [
      PostoSulTavolo(-3.3, -1.5),
      PostoSulTavolo(-2.2, -0.5),
      PostoSulTavolo(-1.1, 0.3),
      PostoSulTavolo(0, 0.6),
      PostoSulTavolo(1.1, 0.3),
      PostoSulTavolo(2.2, -0.5),
      PostoSulTavolo(3.3, -1.5),
    ],
    fonte: 'Forma diffusa nella cartomanzia moderna, senza autore '
        'documentato.',
    disponibile: false,
  ),
  dieciCarte(
    nome: 'Stesa della Croce Celtica',
    breve: 'Dieci Carte',
    descrizione: 'La Croce Celtica',
    // Nell'ordine di Waite: la quinta e la sesta carta, il dietro e il
    // davanti, sono il passato e il futuro.
    posizioni: [
      SpreadPosition.copre,
      SpreadPosition.attraversa,
      SpreadPosition.corona,
      SpreadPosition.sotto,
      SpreadPosition.passato,
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
    fonte: 'Arthur Edward Waite, The Pictorial Key to the Tarot, 1911, '
        'capitolo "An Ancient Celtic Method of Divination".',
    disponibile: false,
  );

  const TarotSpreadType({
    required this.nome,
    required this.breve,
    required this.descrizione,
    required this.posizioni,
    required this.tavolo,
    required this.fonte,
    required this.disponibile,
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

  /// Se e' gia' apribile o se resta Coming soon col lucchetto.
  final bool disponibile;

  /// La stesa della Demo, l'unica viva.
  static const TarotSpreadType predefinita = TarotSpreadType.treCarte;

  /// **SE QUESTO PIANO PUO' APRIRE QUESTA STESA.** Ordine EX voce 02: la
  /// stesa da dieci carte solo dall'Adepto, *"la stesa a 10 solo dal tier 2
  /// 19,99"*. Una stesa non ancora disponibile non si apre per nessuno.
  bool apribileDa(Tier tier) =>
      disponibile && (carte < 10 || PlanCatalog.haLaStesaDaDieci(tier));
}
