/// LA PROVA DELLA SETTIMANA. Ordine FF voce 05, 7 ottobre 2026.
///
/// Il fondatore, il 6 ottobre 2026: *"proponiamo al cerchio un test di
/// personalità il cui punteggio determina la personalità o altra
/// caratteristica dell'utente, e gli altri prima di scoprire il punteggio
/// devono indovinarlo"*. Il pozzo e' il corpus dell'Architetto
/// (`docs/corpus/Corpus_Le_Prove.md`, generato in
/// `le_prove_del_corpus.g.dart`): sei temi, dodici domande ciascuno.
///
/// **Il tema lo sceglie il cielo del lunedi'**, con la porta unica
/// (`IlCieloDiMeeus`, `IlSegnoDelCielo`, `MoonPhase`), e il primo criterio
/// che si verifica vince: Mercurio retrogrado in un giorno della settimana,
/// Venere che cambia segno, Marte che cambia segno, la Luna piena, la Luna
/// nuova; altrimenti "Chi stai diventando". Il calcolo e' lo stesso su ogni
/// telefono, quindi la Prova e' la stessa per tutti.
///
/// **Il punteggio**: ogni risposta vale da zero a tre, dieci domande fanno
/// al massimo trenta, il punteggio su cento e' la somma per cento diviso
/// trenta, arrotondata. Deterministico. **Non si mostra mai.**
///
/// **LE QUATTRO NATURE**, 8 ottobre 2026. Il fondatore: *"Non possiamo
/// parlare di gioco o sfide o punteggi nella nostra app. Si trattano di test
/// sempre legati a tradizioni esoteriche e i risultati devono essere
/// coerenti con trattati, metodi, fonti e tradizioni esoteriche."* Le quattro
/// fasce di ogni tema sono i quattro elementi col loro temperamento, nella
/// scala dal piu' grave al piu' sottile del Timeo: la persona legge la sua
/// natura, mai un numero.
library;

import '../astro/il_segno_del_cielo.dart';
import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/moon_phase.dart';
import 'i_tempi_dei_giochi.dart';
import 'le_prove_del_corpus.g.dart';

class RispostaDellaProva {
  const RispostaDellaProva(this.testoMarcato, this.peso);

  /// Il testo, con le marche del genere dell'Architetto.
  final String testoMarcato;

  /// Da zero a tre: non si mostra mai.
  final int peso;
}

class DomandaDellaProva {
  const DomandaDellaProva(this.numero, this.testoMarcato, this.risposte);
  final int numero;
  final String testoMarcato;
  final List<RispostaDellaProva> risposte;
}

class FasciaDellaProva {
  const FasciaDellaProva(
      this.da, this.a, this.figura, this.testoMarcato, this.fareMarcato);
  final int da;
  final int a;

  /// L'elemento della fascia, col suo articolo: "La Terra", "L'Acqua"...
  final String figura;
  final String testoMarcato;

  /// Che cosa fare questa settimana, la seconda parte del responso.
  final String fareMarcato;
}

/// **LE QUATTRO NATURE**, nell'ordine delle fasce: dal piu' grave al piu'
/// sottile, come nel Timeo di Platone. Le qualita' e i temperamenti sono
/// quelli della tradizione ippocratica e galenica, raccolti da Agrippa
/// (De occulta philosophia, libro I, capitolo 3).
enum NaturaDellaProva {
  terra('La Terra', 'la Terra', 'fredda e secca', 'melancolico'),
  acqua('L’Acqua', 'l’Acqua', 'fredda e umida', 'flemmatico'),
  aria('L’Aria', 'l’Aria', 'calda e umida', 'sanguigno'),
  fuoco('Il Fuoco', 'il Fuoco', 'caldo e secco', 'collerico');

  const NaturaDellaProva(
      this.nome, this.nomeInFrase, this.qualita, this.temperamento);

  /// "La Terra", in testa a una riga.
  final String nome;

  /// "la Terra", dentro una frase.
  final String nomeInFrase;

  /// Le due qualita' dell'elemento.
  final String qualita;

  /// Il temperamento che la tradizione gli lega.
  final String temperamento;

  /// La natura di una fascia (0-3), o nulla fuori dall'elenco.
  static NaturaDellaProva? diIndice(int? i) =>
      i == null || i < 0 || i >= values.length ? null : values[i];

  /// "Il temperamento melancolico."
  String get riga => 'Il temperamento $temperamento';

  /// Da dove viene la natura, in una frase con le sue fonti.
  String get fonte => '$nome è $qualita: '
      'è il temperamento $temperamento (Ippocrate, Sulla natura dell’uomo; '
      'Galeno, De temperamentis; Agrippa, De occulta philosophia, I, 3). '
      'Le quattro nature vanno dalla più grave alla più sottile, come nel '
      'Timeo di Platone: la Terra, l’Acqua, l’Aria, il Fuoco.';
}

class TemaDellaProva {
  const TemaDellaProva({
    required this.numero,
    required this.nome,
    required this.fonte,
    required this.domande,
    required this.fasce,
  });
  final int numero;
  final String nome;

  /// Da dove viene la domanda del cielo di questo tema, con la sua fonte.
  final String fonte;
  final List<DomandaDellaProva> domande;
  final List<FasciaDellaProva> fasce;
}

/// Il tema di una settimana, e perche'.
enum CriterioDelCielo {
  mercurioRetrogrado,
  venereCambiaSegno,
  marteCambiaSegno,
  lunaPiena,
  lunaNuova,
  nessuno,
}

abstract final class LaProva {
  /// Quante domande ha la Prova di una settimana.
  static const int domandePerSettimana = 10;

  static List<TemaDellaProva> get temi => temiDelCorpus;

  /// **IL CRITERIO DEL CIELO della settimana che comincia [lunedi]**, il
  /// primo che si verifica nell'ordine del corpus.
  static CriterioDelCielo criterio(DateTime lunedi) {
    final l = ITempiDeiGiochi.lunediDi(lunedi);
    // Mezzogiorno di ogni giorno della settimana, e il lunedi' dopo per il
    // passaggio dell'ultimo giorno.
    final giorni = [
      for (var i = 0; i <= 7; i++) DateTime(l.year, l.month, l.day + i, 12),
    ];
    final settimana = giorni.take(7).toList();
    if (settimana.any((g) => IlCieloDiMeeus.retrogrado(
        CorpoCeleste.mercurio, IlCieloDiMeeus.giornoGiuliano(g.toUtc())))) {
      return CriterioDelCielo.mercurioRetrogrado;
    }
    bool cambia(CorpoCeleste c) {
      for (var i = 0; i < 7; i++) {
        if (IlSegnoDelCielo.delCorpo(c, giorni[i]) !=
            IlSegnoDelCielo.delCorpo(c, giorni[i + 1])) {
          return true;
        }
      }
      return false;
    }

    if (cambia(CorpoCeleste.venere)) return CriterioDelCielo.venereCambiaSegno;
    if (cambia(CorpoCeleste.marte)) return CriterioDelCielo.marteCambiaSegno;
    final piena = ITempiDeiGiochi.prossimaLunaPiena(l);
    if (piena != null && piena.difference(l).inDays < 7) {
      return CriterioDelCielo.lunaPiena;
    }
    for (var i = 0; i < 7; i++) {
      final a = DateTime(l.year, l.month, l.day + i);
      final b = DateTime(l.year, l.month, l.day + i + 1);
      // La Luna nuova: il ciclo ricomincia, la frazione torna verso zero.
      if (MoonPhase.forDate(a).fraction > MoonPhase.forDate(b).fraction) {
        return CriterioDelCielo.lunaNuova;
      }
    }
    return CriterioDelCielo.nessuno;
  }

  /// Il tema della settimana di [istante]: i criteri, nell'ordine, aprono i
  /// temi da uno a sei.
  static TemaDellaProva temaDi(DateTime istante) =>
      temiDelCorpus[criterio(istante).index];

  /// Il numero della settimana nell'anno, alla maniera ISO 8601.
  static int numeroDellaSettimana(DateTime istante) {
    final giorno = DateTime.utc(istante.year, istante.month, istante.day);
    final giovedi = giorno.add(Duration(days: 4 - giorno.weekday));
    final primo = DateTime.utc(giovedi.year, 1, 1);
    return giovedi.difference(primo).inDays ~/ 7 + 1;
  }

  /// **LE DIECI DOMANDE DELLA SETTIMANA**: delle dodici del tema si saltano
  /// le due alle posizioni date dal resto della divisione del numero della
  /// settimana per dodici, quella posizione e la seguente (in cerchio). Il
  /// corpus dice "le due alle posizioni date dal resto", e un resto e' un
  /// numero solo: la seconda e' la posizione dopo, scelta dichiarata.
  static List<DomandaDellaProva> domandeDi(DateTime istante) {
    final tema = temaDi(istante);
    final r = numeroDellaSettimana(istante) % 12;
    final salta = {r, (r + 1) % 12};
    return [
      for (var i = 0; i < tema.domande.length; i++)
        if (!salta.contains(i)) tema.domande[i],
    ];
  }

  /// Il punteggio da zero a cento, dai pesi delle risposte date.
  static int punteggio(List<int> pesi) {
    final somma = pesi.fold<int>(0, (a, b) => a + b);
    return (somma * 100 / (domandePerSettimana * 3)).round();
  }

  /// La fascia del punteggio nel tema.
  static FasciaDellaProva fascia(TemaDellaProva tema, int punteggio) =>
      tema.fasce.firstWhere((f) => punteggio >= f.da && punteggio <= f.a,
          orElse: () => tema.fasce.last);

  /// La natura di un punteggio: la posizione della sua fascia.
  static NaturaDellaProva natura(TemaDellaProva tema, int punteggio) =>
      NaturaDellaProva.values[tema.fasce.indexOf(fascia(tema, punteggio))];

  /// **Da dove viene**, la terza parte del responso: la domanda del cielo
  /// di questa settimana e la natura, con le loro fonti.
  static String daDoveViene(TemaDellaProva tema, NaturaDellaProva n) =>
      '${tema.fonte} ${n.fonte}';
}
