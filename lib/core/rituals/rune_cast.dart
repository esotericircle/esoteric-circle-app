import 'dart:math';

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
  });

  /// Chiave stabile della gettata.
  final String id;

  /// Nome mostrato nel selettore, per esempio "Le tre Norne".
  final String nome;

  /// Riga breve sotto il nome, per esempio "tre rune".
  final String sottotitolo;

  /// Le posizioni in cui cadono le rune, in ordine.
  final List<PosizioneGettata> posizioni;

  /// Il testo che cambia con la scelta: tradizione, fonti, autori, metodo di
  /// calcolo e differenza con le altre gettate.
  final String testoDinamico;

  /// Quante rune si estraggono: una, tre o cinque.
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

/// Le gettate disponibili, in ordine di crescente ampiezza. Estensibile.
const List<GettataRune> gettate = [gettataOdino, gettataNorne, gettataCroce];

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
    "è descritta da Tacito nella Germania. La cornice delle Norne e del Pozzo di "
    "Urdhr viene dall'Edda poetica (la Voluspa) e dalla Gylfaginning di Snorri "
    "Sturluson.\n\n"
    "Moderno, dichiarato come tale. La lettura divinatoria delle rune, le stese "
    "a posizioni fisse e il verso d'ombra o merkstave sono convenzioni moderne, "
    "diffuse nel Novecento da autori come Edred Thorsson, alias Stephen Flowers, "
    "nel suo Futhark del 1984, Freya Aswynn e Diana Paxson, divulgate poi da "
    "Ralph Blum. I nostri testi sono curatela originale nella voce di Caligo, "
    "ispirata a queste fonti, non citazione.\n\n"
    "Per intrattenimento e crescita personale, nessuna promessa deterministica.";

/// Una runa uscita in una posizione della gettata, col suo verso.
class RunaGettata {
  const RunaGettata({
    required this.rune,
    required this.verso,
    required this.posizione,
  });

  final Rune rune;
  final RuneVerso verso;
  final PosizioneGettata posizione;

  /// Vero se la runa e' uscita in merkstave, il verso d'ombra.
  bool get inOmbra => verso == RuneVerso.merkstave;

  /// La riga letta, secondo l'orientamento: il verso dritto o quello d'ombra.
  String get riga => inOmbra ? rune.shadow : rune.upright;
}

/// L'esito di una gettata: le rune uscite nelle loro posizioni.
class EsitoGettata {
  const EsitoGettata({required this.gettata, required this.rune});

  final GettataRune gettata;
  final List<RunaGettata> rune;
}

/// Il motore dell'estrazione. Qui il caso e' voluto e autentico, e' gettare le
/// sorti: nessuna determinazione dal giorno, un vero lancio a ogni richiesta.
/// Il [random] rende il caso iniettabile nei test.
class RuneCast {
  const RuneCast._();

  /// Getta le rune per [gettata]: estrae a sorte rune tutte diverse, una per
  /// posizione, ognuna dritta o in merkstave a sorte. Le simmetriche escono
  /// sempre diritte.
  static EsitoGettata getta(GettataRune gettata, {Random? random}) {
    final rng = random ?? Random();
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

  /// L'aett di una runa dal suo posto nell'Elder Futhark: la famiglia di Freyr
  /// (le prime otto), di Hagal (le seconde otto), di Tyr (le ultime otto).
  static String aett(Rune r) {
    final i = kElderFuthark.indexWhere((x) => x.name == r.name);
    if (i < 8) return 'Freyr';
    if (i < 16) return 'Hagal';
    return 'Tyr';
  }
}
