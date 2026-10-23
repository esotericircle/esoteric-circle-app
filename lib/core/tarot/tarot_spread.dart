import 'dart:math';

import '../chat/la_marca_del_genere.dart';
import 'tarot_card.dart';

/// LE POSIZIONI DELLE STESE. Ordine FI voce 04, 10 ottobre 2026: da tre a
/// diciassette; dall'ordine FJ, aggiunta 2, quattordici, perche' col ferro di
/// cavallo sono uscite le sue tre posizioni orfane (consiglio, ambiente,
/// ostacolo). Le prime tre sono quelle della Stesa di Medora a tre carte e
/// non si toccano; le altre undici servono alla carta sola, alla croce di
/// Dora e alla Croce Celtica di Waite. Quali posizioni ha
/// una stesa, e in che ordine, lo dice la stesa stessa
/// ([TarotSpreadType.posizioni]): questo elenco non e' una stesa.
///
/// Le sette etichette della Croce Celtica vengono da Arthur Edward Waite, The
/// Pictorial Key to the Tarot, 1911, che per le prime sei usa le formule
/// "this covers him", "this crosses him", "this crowns him", "this is beneath
/// him", "this is behind him", "this is before him". La sesta carta di
/// Waite, il davanti, e' il futuro; la quinta, il dietro, ha la sua posizione
/// dall'ordine FK voce 8. La formula "this crowns him" non e' verificata dal
/// reperto docs/corpus/tarocchi_posizione/verifica_waite_1911.md, che per la
/// terza carta riporta l'attacco "It represents" (ordine FK voce 15): resta
/// da vedere.
enum SpreadPosition {
  passato('Passato'),
  presente('Presente'),
  futuro('Futuro'),

  /// La stesa a una carta.
  cartaSola('La carta'),

  /// La croce di Dora: il consultante in basso, i due lati, l'esito in alto.
  consultante('Il consultante'),
  lato('Il lato'),

  /// L'esito della croce di Dora e della Croce Celtica.
  esito("L'esito"),

  /// La Croce Celtica di Waite.
  copre('Ciò che copre'),
  attraversa('Ciò che attraversa'),
  corona('Ciò che corona'),
  sotto('Il fondamento'),

  /// La quinta carta della Croce Celtica, ordine FK voce 8: "This is behind
  /// him. It gives the influence that is just passed, or is now passing
  /// away." (Waite 1911, Parte III, sezione 7, dalla trascrizione di
  /// sacred-texts). Due stati, l'appena trascorso e cio' che sta svanendo
  /// adesso, distinti dal fondamento, che e' il passato fatto proprio.
  dietro('Ciò che è dietro'),

  /// "Te stesso" dice a chi legge un genere: passa dalla marca, come ogni
  /// testo rivolto alla persona (ordine FI voce 05).
  seStesso('[Te stesso|Te stessa|Tu]'),
  laCasa('La tua casa'),
  speranzeOTimori('Speranze o timori');

  const SpreadPosition(this.label);

  /// L'etichetta come e' scritta, con la marca del genere dove serve.
  final String label;

  /// L'etichetta da mostrare, con la marca del genere risolta.
  String get etichetta => LaMarcaDelGenere.risolvi(label);

  /// **LA DIDASCALIA SOTTO LA CARTA IN PIEDI DELLA CROCE CELTICA. Ordine FS,
  /// 14 ottobre 2026.** Il fondatore: "rifai anche i testi delle
  /// didascalie", alcune grandi e altre rimpicciolite. Con le parole lunghe
  /// ("attraversa", "fondamento") una misura sola per tutte scendeva a nove
  /// punti. Le didascalie seguono la forma di Waite stesso, che dice ogni
  /// posto rispetto alla persona ("This covers him", "This crosses him",
  /// "This crowns him", "beneath him", "behind him", "before him", "Himself",
  /// "his house", "hopes or fears": Waite 1911, Parte III, sezione 7). Il
  /// nome pieno resta l'[etichetta]: nelle bolle, nelle istruzioni al
  /// modello e in ogni altra stesa.
  String get didascalia => switch (this) {
        SpreadPosition.copre => 'Ti copre',
        SpreadPosition.attraversa => 'Contro di te',
        SpreadPosition.corona => 'Ti corona',
        SpreadPosition.sotto => 'Sotto di te',
        SpreadPosition.dietro => 'Dietro di te',
        SpreadPosition.futuro => 'Davanti a te',
        SpreadPosition.seStesso => 'Tu',
        SpreadPosition.speranzeOTimori => 'Speri o temi',
        _ => etichetta,
      };

  /// Le tre posizioni della Stesa di Medora a tre carte, nell'ordine di
  /// lettura. Prima dell'ordine FI erano tutto l'elenco, e la stesa le
  /// leggeva come `SpreadPosition.values`.
  static const List<SpreadPosition> treCarte = [passato, presente, futuro];
}

/// Una carta pescata: la carta, la sua posizione e il verso in cui e' uscita.
///
/// Il verso decide quale testo del corpus si mostra, dritto o rovesciato: sono
/// sempre coerenti, non si mostra mai il dritto su una carta rovesciata.
class DrawnCard {
  const DrawnCard({
    required this.card,
    required this.position,
    required this.reversed,
  });

  final TarotCard card;
  final SpreadPosition position;
  final bool reversed;

  /// La parola del rovescio accordata alla carta, vuota se la carta e' dritta.
  ///
  /// E' l'unico punto da cui la parola si prende, in tutta l'app: sotto la
  /// miniatura, nelle intestazioni degli strati, sulla carta chiave e nella
  /// card condivisibile. Scritta a mano da qualche parte, tornerebbe il
  /// maschile fisso su "La Papessa" o su "Gli Amanti".
  String get versoLabel => reversed ? card.reversedWord : '';

  /// Il nome come si legge sotto la carta, con la parola del rovescio accordata.
  String get displayName =>
      reversed ? '${card.name} ${card.reversedWord}' : card.name;

  /// La riga di significato dal corpus, del verso giusto.
  String get meaning => reversed ? card.reversed : card.upright;

  /// La sintesi breve dal corpus, del verso giusto.
  String get summary => reversed ? card.reversedSummary : card.uprightSummary;
}

/// Una stesa a tre carte, Passato Presente Futuro, nella voce di Medora.
///
/// Il pescaggio e' casuale ma passa da un seme opzionale, cosi' test e anteprima
/// sono riproducibili. Nessuna carta si ripete nella stessa stesa.
class TarotSpread {
  const TarotSpread(this.cards);

  final List<DrawnCard> cards;

  /// Probabilita' che una carta esca rovesciata.
  static const double reversedChance = 0.30;

  /// Quante carte si mostrano nel ventaglio coperto.
  static const int fanSize = 9;

  // **LA STESA E' UNA SEQUENZA DI COPPIE, posizione e carta, nell'ordine di
  // lettura.** Ordine FK, aggiunta 2 voce A8. Ogni `DrawnCard` porta la sua
  // posizione, quindi una posizione che torna due volte (i due `lato` della
  // croce a quattro) resta due coppie: una mappa da posizione a carta ne
  // perderebbe una. Le posizioni e il loro ordine vengono dalla definizione
  // della stesa, `TarotSpreadType.posizioni`.

  /// Le posizioni di questa stesa, nell'ordine di lettura.
  List<SpreadPosition> get posizioni => [for (final c in cards) c.position];

  /// **LE TRE SCORCIATOIE DELLA STESA A TRE CARTE.** Restano perche' tredici
  /// file le usano; non sono la forma della classe. Su un'altra stesa non
  /// hanno senso: chi legge una stesa qualunque usa [cuore], [approdo] e
  /// [cards].
  DrawnCard get passato => cards[0];
  DrawnCard get presente => cards[1];
  DrawnCard get futuro => cards[2];

  /// Vero se e' la stesa a tre carte, passato presente futuro.
  bool get eATreCarte =>
      cards.length == 3 &&
      [for (var i = 0; i < 3; i++) cards[i].position].join() ==
          SpreadPosition.treCarte.join();

  /// **LA CARTA CHE REGGE LA LETTURA**: il presente nella stesa a tre carte,
  /// la carta sola, il consultante nella croce, cio' che copre nella Croce
  /// Celtica. Altrimenti la prima.
  DrawnCard get cuore {
    for (final p in const [
      SpreadPosition.presente,
      SpreadPosition.cartaSola,
      SpreadPosition.consultante,
      SpreadPosition.copre,
    ]) {
      for (final c in cards) {
        if (c.position == p) return c;
      }
    }
    return cards.first;
  }

  /// **DOVE LA STESA VA A FINIRE**: l'ultima carta, se la stesa ne ha piu' di
  /// una e l'ultima e' il futuro o l'esito; altrimenti nulla.
  DrawnCard? get approdo {
    if (cards.length < 2) return null;
    final ultima = cards.last;
    return ultima.position == SpreadPosition.futuro ||
            ultima.position == SpreadPosition.esito
        ? ultima
        : null;
  }

  /// La riga di sintesi memorabile, dalla sintesi breve della carta del
  /// Presente: e' il colpo d'occhio sopra le tre carte.
  String get synthesis => cuore.summary;

  /// La lettura che concatena le tre posizioni in modo fluido.
  String get reading => eATreCarte
      ? 'Alle tue spalle ${passato.displayName}: ${passato.meaning} '
          'Nel momento che vivi ${presente.displayName}: ${presente.meaning} '
          'Davanti a te ${futuro.displayName}: ${futuro.meaning}'
      // Le altre stese, ordine FK aggiunta 2 voce A8: ogni carta con la sua
      // posizione, nell'ordine di lettura.
      : [
          for (final c in cards)
            '${c.position.etichetta}, ${c.displayName}: ${c.meaning}',
        ].join(' ');

  /// La riga di chiusura, sempre nella cornice della consapevolezza.
  static const String closing =
      'Il cielo inclina, non obbliga: la scelta resta tua.';

  /// Il disclaimer, mostrato una sola volta in fondo alla schermata.
  static const String disclaimer =
      'I tarocchi sono tradizione reale, qui per intrattenimento e crescita: '
      'nessuna promessa sul futuro, sempre uno spazio di scelta.';

  /// IL MAZZO IN ORDINE, come lista di indici del corpus.
  ///
  /// **Perche' esiste, ordine 2171 voce 6.** Fino al 10 agosto 2026 Taglia e
  /// Mischia erano gesti simbolici: lanciavano un'animazione e la stesa
  /// restava quella pescata all'apertura. Adesso il mazzo ha un ordine vero
  /// che i due gesti cambiano davvero, e le tre carte si prendono da li'.
  static List<int> mazzoMescolato({int? seed}) {
    final random = seed == null ? Random() : Random(seed);
    return List<int>.generate(TarotDeck.cards.length, (i) => i)
      ..shuffle(random);
  }

  /// La stesa che viene da un mazzo gia' ordinato: le prime tre carte, in
  /// cima, come le prenderebbe una mano.
  ///
  /// Il verso di ciascuna dipende dal seme e dalla posizione nel mazzo, non
  /// dal caso del momento: due tagli che riportano lo stesso ordine danno la
  /// stessa stesa, ed e' cio' che ci si aspetta da un mazzo di carte.
  static TarotSpread dalMazzo(List<int> ordine,
      {int seed = 0,
      List<SpreadPosition> posizioni = SpreadPosition.treCarte}) {
    return TarotSpread([
      for (var i = 0; i < posizioni.length; i++)
        DrawnCard(
          card: TarotDeck.cards[ordine[i]],
          position: posizioni[i],
          reversed:
              Random(ordine[i] * 7919 + seed).nextDouble() < reversedChance,
        ),
    ]);
  }

  /// IL VERSO DI UNA CARTA, in un punto solo.
  ///
  /// Nasce dall'indice della carta e dal seme, mai dal caso del momento: la
  /// stessa carta nella stessa stesa e' sempre dritta o sempre rovesciata,
  /// anche se la schermata si ricostruisce dieci volte.
  static bool versoDi(int indiceCarta, int seme) =>
      Random(indiceCarta * 7919 + seme).nextDouble() < reversedChance;

  /// Il caso con cui si mescola: col seme e' riproducibile, senza e' nuovo.
  static Random casoCon(int? seme) => seme == null ? Random() : Random(seme);

  /// Il mazzo tagliato in [punto]: la meta' sotto sale sopra, come nel gesto
  /// vero. Un taglio non mescola niente, cambia solo da dove si comincia.
  static List<int> taglia(List<int> ordine, int punto) {
    final k = punto % ordine.length;
    return [...ordine.sublist(k), ...ordine.sublist(0, k)];
  }

  /// Pesca tre carte distinte dal mazzo, ognuna dritta o rovesciata.
  ///
  /// Con [seed] la stesa e' riproducibile: stesso seme, stessa stesa. Senza,
  /// ogni pescaggio e' nuovo.
  static TarotSpread draw(
      {int? seed, List<SpreadPosition> posizioni = SpreadPosition.treCarte}) {
    final random = seed == null ? Random() : Random(seed);
    final indici = List<int>.generate(TarotDeck.cards.length, (i) => i)
      ..shuffle(random);
    return TarotSpread([
      for (var i = 0; i < posizioni.length; i++)
        DrawnCard(
          card: TarotDeck.cards[indici[i]],
          position: posizioni[i],
          reversed: random.nextDouble() < reversedChance,
        ),
    ]);
  }
}
