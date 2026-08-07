import 'dart:math';
import 'dart:ui' show Offset;

import 'runes.dart';

/// L'orientamento di una runa gettata: dritta, oppure in merkstave, il verso
/// d'ombra. Convenzione moderna dichiarata, non attestata nell'antico.
enum RuneVerso { dritto, merkstave }

/// Le rune simmetriche dell'Elder Futhark, identiche se girate: non escono mai
/// in merkstave, restano sempre diritte. La loro riga d'ombra vale quando la
/// gettata intera pende in penombra.
const Set<String> kRuneSimmetriche = <String>{
  'Gebo',
  'Hagalaz',
  'Isa',
  'Jera',
  'Eihwaz',
  'Sowilo',
  'Ingwaz',
  'Dagaz',
};

/// Una posizione della gettata, col suo titolo breve e la sua glossa.
class PosizioneGettata {
  const PosizioneGettata(this.titolo, this.glossa);

  /// Il nome della posizione, per esempio Urdhr, oppure Ostacolo.
  final String titolo;

  /// Cosa dice quella posizione, per esempio "ciò che fu".
  final String glossa;
}

/// Un tipo di gettata delle rune, con le sue posizioni e il testo dinamico che
/// ne spiega tradizione, letteratura, autori e metodo di calcolo.
///
/// Il selettore e' estensibile per costruzione: aggiungere una quarta gettata,
/// per esempio la sorte libera sul panno alla maniera di Tacito, e' solo una
/// nuova voce in [gettate], senza toccare motore, schermata ne test.
class GettataRune {
  const GettataRune({
    required this.id,
    required this.nome,
    required this.sottotitolo,
    required this.posizioni,
    required this.testoDinamico,
    this.libera = false,
    this.sparse = 0,
  });

  /// Chiave stabile della gettata.
  final String id;

  /// Nome mostrato nel selettore, per esempio "Le tre Norne".
  final String nome;

  /// Riga breve sotto il nome, per esempio "tre rune".
  final String sottotitolo;

  /// Le posizioni in cui cadono le rune, in ordine. Per la gettata libera sono
  /// le posizioni per vicinanza al centro, non slot fissi.
  final List<PosizioneGettata> posizioni;

  /// Il testo che cambia con la scelta: tradizione, fonti, autori, metodo di
  /// calcolo e differenza con le altre gettate.
  final String testoDinamico;

  /// Vero per la sorte libera sul telo, alla maniera di Tacito: nessuna
  /// posizione fissa, le rune cadono sparse, si leggono quelle in luce per
  /// vicinanza al centro.
  final bool libera;

  /// Quante rune si spargono sul telo nella gettata libera. Zero per le fisse.
  final int sparse;

  /// Quante rune si estraggono nelle gettate a posizioni fisse.
  int get numero => posizioni.length;
}

/// Runa di Odino, una runa. Il consiglio essenziale per una domanda mirata.
const GettataRune gettataOdino = GettataRune(
  id: 'odino',
  nome: 'Runa di Odino',
  sottotitolo: 'una runa',
  posizioni: [
    PosizioneGettata('La runa di Odino', 'il consiglio essenziale'),
  ],
  testoDinamico:
      "Il nome Runa di Odino è convenzione moderna, dal dio che nell'Edda "
      "poetica, nell'Havamal, conquista le rune restando appeso a Yggdrasil per "
      "nove notti. La lettura a una runa è la più semplice, diffusa dai manuali "
      "del Novecento. Metodo di calcolo: una runa estratta a sorte fra "
      "ventiquattro, dritta o in merkstave se asimmetrica. Differenza: il Dono "
      "Runa del Tramonto usa la stessa forma a una runa ma è quotidiano e "
      "deterministico, questa è a richiesta e casuale.",
);

/// Le tre Norne, tre rune. Urdhr ciò che fu, Verdhandi ciò che diviene, Skuld
/// ciò che sarà.
const GettataRune gettataNorne = GettataRune(
  id: 'norne',
  nome: 'Le tre Norne',
  sottotitolo: 'tre rune',
  posizioni: [
    PosizioneGettata('Urdhr', 'ciò che fu'),
    PosizioneGettata('Verdhandi', 'ciò che diviene'),
    PosizioneGettata('Skuld', 'ciò che sarà'),
  ],
  testoDinamico:
      "Trarre tre sorti ha un precedente antico. Tacito, nella Germania al "
      "capitolo dieci, descrive segni incisi su verghe di un albero, sparse su "
      "un panno bianco, da cui si traggono e leggono tre sorti. La cornice "
      "delle tre Norne e del Pozzo di Urdhr alle radici di Yggdrasil viene "
      "dall'Edda poetica (la Voluspa) e dall'Edda in prosa di Snorri Sturluson "
      "(la Gylfaginning). L'etichetta passato, presente, futuro è lettura "
      "moderna. Metodo di calcolo: tre rune diverse estratte a sorte, "
      "orientamento a sorte per le asimmetriche.",
);

/// La Croce delle Cinque, cinque rune. Cuore, radice, ostacolo, consiglio,
/// esito.
const GettataRune gettataCroce = GettataRune(
  id: 'croce',
  nome: 'La Croce delle Cinque',
  sottotitolo: 'cinque rune',
  posizioni: [
    PosizioneGettata('Cuore', 'il cuore della questione'),
    PosizioneGettata('Radice', 'la radice'),
    PosizioneGettata('Ostacolo', "l'ostacolo"),
    PosizioneGettata('Consiglio', 'il consiglio'),
    PosizioneGettata('Esito', "l'esito"),
  ],
  testoDinamico:
      "La stesa a cinque posizioni fisse è adattamento moderno, ispirato alle "
      "stese dei tarocchi, formalizzato nei manuali runici del Novecento. "
      "Dichiarata come pratica moderna, non attestata nell'antico. Metodo di "
      "calcolo: cinque rune diverse estratte a sorte, orientamento a sorte per "
      "le asimmetriche.",
);

/// Il getto sul telo, la sorte libera alla maniera di Tacito: le rune si
/// spargono su un panno bianco, si leggono quelle in luce per vicinanza al
/// centro, fino a tre. Il metodo storico piu' antico, senza posizioni fisse.
const GettataRune gettataTelo = GettataRune(
  id: 'telo',
  nome: 'Il getto sul telo',
  sottotitolo: 'sorte libera',
  libera: true,
  sparse: 7,
  posizioni: [
    PosizioneGettata('Al centro', 'la più vicina al centro'),
    PosizioneGettata('Presso il centro', 'vicina al centro'),
    PosizioneGettata('Ai margini', 'verso i margini della luce'),
  ],
  testoDinamico:
      "Il getto sul telo è il metodo storico più antico. Tacito, nella Germania "
      "al capitolo dieci, descrive segni incisi su rametti sparsi su un panno "
      "bianco, da cui il sacerdote trae e legge tre sorti. Qui non ci sono "
      "posizioni fisse: le rune cadono libere sul telo, alcune in luce e "
      "diritte, altre in ombra e coperte. Metodo di calcolo: si leggono quelle "
      "in luce e la loro vicinanza al centro, fino a tre, la più vicina pesa di "
      "più. Le stese a posizioni fisse sono invece moderne, adattamenti del "
      "Novecento.",
);

/// Le gettate disponibili. Estensibile: una nuova gettata e' solo una voce.
const List<GettataRune> gettate = [
  gettataOdino,
  gettataNorne,
  gettataCroce,
  gettataTelo,
];

/// I suggerimenti di domanda tappabili prima del lancio. La domanda e' solo
/// intenzione, non inviata a nessun servizio nella Demo.
const List<String> kRuneDomandeSuggerite = [
  'Cosa devo sapere sul mio momento?',
  'In amore, dove sto andando?',
  'Nel lavoro, quale passo fare?',
  'Una scelta mi blocca, cosa la scioglie?',
  'Cosa mi sfugge di questa situazione?',
];

/// Il testo base di "Fonti e metodo", che dichiara cosa e' antico e cosa e'
/// moderno, senza spacciare l'uno per l'altro.
const String kRuneFontiEMetodo =
    "Antico. L'Elder Futhark, l'alfabeto runico germanico di ventiquattro segni "
    "nelle tre aett di Freyr, Hagal e Tyr. I significati affondano nei tre Carmi "
    "Runici, l'anglosassone, il norvegese, l'islandese. La sorte tratta a segni "
    "è descritta da Tacito nella Germania, capitolo dieci: le sorti incise si "
    "gettano sopra un candido panno, quello stesso che il getto libero "
    "stende. La cornice delle Norne e del Pozzo di "
    "Urdhr viene dall'Edda poetica (la Voluspa) e dalla Gylfaginning di Snorri "
    "Sturluson.\n\n"
    "Moderno, dichiarato come tale. La lettura divinatoria delle rune, le stese "
    "a posizioni fisse e il verso d'ombra o merkstave sono convenzioni moderne, "
    "diffuse nel Novecento da autori come Edred Thorsson, alias Stephen Flowers, "
    "nel suo Futhark del 1984, Freya Aswynn e Diana Paxson, divulgate poi da "
    "Ralph Blum. I nostri testi sono curatela originale scritta da Caligo, "
    "ispirata a queste fonti, non citazione.";

/// La nota del sigillo del giorno: dichiara che la bindrune e' una forma
/// autentica della tradizione, e che questa e' composta dalle rune del momento.
const String kRuneBindruneNota =
    "Le bindrune sono glifi intrecciati autentici della tradizione runica. "
    "Questo sigillo intreccia le rune del tuo momento in un segno solo, "
    "sovrapposte su un'asta condivisa.";

/// Una runa uscita in una posizione della gettata, col suo verso.
class RunaGettata {
  const RunaGettata({
    required this.rune,
    required this.verso,
    required this.posizione,
    this.punto,
    this.coperta = false,
  });

  final Rune rune;
  final RuneVerso verso;
  final PosizioneGettata posizione;

  /// Dove cade la runa sul telo, in coordinate normalizzate. Null per le
  /// gettate a posizioni fisse, dove il posto lo da' la schermata.
  final Offset? punto;

  /// Vero se la runa e' caduta in ombra, coperta, nella gettata libera: non si
  /// legge, resta velata sul telo.
  final bool coperta;

  /// Vero se la runa e' uscita in merkstave, il verso d'ombra.
  bool get inOmbra => verso == RuneVerso.merkstave;

  /// La riga letta, secondo l'orientamento: il verso dritto o quello d'ombra.
  String get riga => inOmbra ? rune.shadow : rune.upright;

  RunaGettata copyWith({PosizioneGettata? posizione, bool? coperta}) =>
      RunaGettata(
        rune: rune,
        verso: verso,
        posizione: posizione ?? this.posizione,
        punto: punto,
        coperta: coperta ?? this.coperta,
      );
}

/// L'esito di una gettata: le rune lette nelle loro posizioni. Per la gettata
/// libera, [sparse] tiene tutte le rune cadute sul telo, in luce e in ombra,
/// mentre [rune] sono solo quelle lette, in luce e vicine al centro.
class EsitoGettata {
  const EsitoGettata({
    required this.gettata,
    required this.rune,
    this.sparse = const [],
  });

  final GettataRune gettata;
  final List<RunaGettata> rune;
  final List<RunaGettata> sparse;
}

/// Il motore dell'estrazione. Qui il caso e' voluto e autentico, e' gettare le
/// sorti: nessuna determinazione dal giorno, un vero lancio a ogni richiesta.
/// Il [random] rende il caso iniettabile nei test.
class RuneCast {
  const RuneCast._();

  /// Getta le rune per [gettata]: estrae a sorte rune tutte diverse, una per
  /// posizione, ognuna dritta o in merkstave a sorte. Le simmetriche escono
  /// sempre diritte. La gettata libera segue invece la sorte sul telo.
  static EsitoGettata getta(GettataRune gettata, {Random? random}) {
    final rng = random ?? Random();
    if (gettata.libera) return _gettaLibera(gettata, rng);
    final indici = List<int>.generate(kElderFuthark.length, (i) => i)
      ..shuffle(rng);
    final rune = <RunaGettata>[];
    for (var i = 0; i < gettata.numero; i++) {
      final r = kElderFuthark[indici[i]];
      final simmetrica = kRuneSimmetriche.contains(r.name);
      final verso = (!simmetrica && rng.nextBool())
          ? RuneVerso.merkstave
          : RuneVerso.dritto;
      rune.add(RunaGettata(
          rune: r, verso: verso, posizione: gettata.posizioni[i]));
    }
    return EsitoGettata(gettata: gettata, rune: rune);
  }

  static const Offset _centroTelo = Offset(0.5, 0.5);
  static const PosizioneGettata _sulTelo =
      PosizioneGettata('Sul telo', 'sparsa sul telo');

  static double _distanzaDalCentro(Offset p) => (p - _centroTelo).distance;

  /// Il getto sul telo: sparge [GettataRune.sparse] rune libere, ognuna in luce
  /// e diritta oppure in ombra e coperta a sorte. Si leggono quelle in luce piu'
  /// vicine al centro, fino alle posizioni previste. Le simmetriche restano
  /// sempre diritte, come nelle altre gettate.
  static EsitoGettata _gettaLibera(GettataRune gettata, Random rng) {
    final indici = List<int>.generate(kElderFuthark.length, (i) => i)
      ..shuffle(rng);
    final sparse = <RunaGettata>[];
    for (var i = 0; i < gettata.sparse; i++) {
      final r = kElderFuthark[indici[i]];
      final x = 0.14 + rng.nextDouble() * 0.72;
      final y = 0.14 + rng.nextDouble() * 0.72;
      final inLuce = rng.nextDouble() < 0.58;
      sparse.add(RunaGettata(
        rune: r,
        verso: RuneVerso.dritto,
        posizione: _sulTelo,
        punto: Offset(x, y),
        coperta: !inLuce,
      ));
    }
    // Le rune lette: quelle in luce, ordinate per vicinanza al centro.
    final inLuce = sparse.where((s) => !s.coperta).toList()
      ..sort((a, b) =>
          _distanzaDalCentro(a.punto!).compareTo(_distanzaDalCentro(b.punto!)));
    final lette = <RunaGettata>[];
    final quante =
        inLuce.length < gettata.posizioni.length ? inLuce.length : gettata.posizioni.length;
    for (var i = 0; i < quante; i++) {
      lette.add(inLuce[i].copyWith(posizione: gettata.posizioni[i]));
    }
    // Se nessuna e' caduta in luce, si scopre la piu' vicina al centro.
    if (lette.isEmpty && sparse.isNotEmpty) {
      final piuVicina = [...sparse]..sort((a, b) =>
          _distanzaDalCentro(a.punto!).compareTo(_distanzaDalCentro(b.punto!)));
      final scelta = piuVicina.first
          .copyWith(coperta: false, posizione: gettata.posizioni.first);
      final idx = sparse.indexOf(piuVicina.first);
      sparse[idx] = scelta;
      lette.add(scelta);
    }
    return EsitoGettata(gettata: gettata, rune: lette, sparse: sparse);
  }

  /// L'aett di una runa dal suo posto nell'Elder Futhark: la famiglia di Freyr
  /// (le prime otto), di Hagal (le seconde otto), di Tyr (le ultime otto).
  static String aett(Rune r) {
    final i = kElderFuthark.indexWhere((x) => x.name == r.name);
    if (i < 8) return 'Freyr';
    if (i < 16) return 'Hagal';
    return 'Tyr';
  }
}
