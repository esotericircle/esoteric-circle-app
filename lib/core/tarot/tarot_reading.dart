import 'tarot_card.dart';
import 'tarot_spread.dart';
import 'tarot_topic.dart';

/// La regola che ha fatto parlare fra loro le tre carte.
///
/// Serve a spiegare da dove viene la riga del dialogo, e ai test per verificare
/// che la priorita' sia rispettata.
enum DialogoRule {
  treMaggiori,
  dueMaggiori,
  soloMinori,
  unaRovesciata,
  piuRovesciate,
  stessoSeme,
  semeCoerente,
  spadeCoppe,
  bastoniDenari,
}

/// Come dialogano fra loro le tre carte uscite.
class Dialogo {
  const Dialogo({required this.rule, required this.text});

  final DialogoRule rule;
  final String text;
}

/// La carta che e' il cuore della stesa, con la ragione della scelta.
class CartaChiave {
  const CartaChiave({required this.drawn, required this.perche});

  final DrawnCard drawn;
  final String perche;
}

/// L'interpretazione completa di una stesa, letta dentro un argomento.
///
/// Sette strati, nell'ordine del corpus `docs/corpus/stesa_interpretazione.md`:
/// sintesi forte, le tre posizioni, le carte che dialogano, la carta chiave, il
/// consiglio di Medora, la domanda di chiusura, poi le azioni col disclaimer.
///
/// Tutto e' deterministico e cacheabile: a parita' di carte e di argomento il
/// testo e' sempre lo stesso. A runtime Gemini cuce solo l'ultimo strato sulla
/// persona, il resto non tocca l'LLM.
class TarotReading {
  const TarotReading({
    required this.spread,
    required this.topic,
    required this.sintesi,
    required this.posizioni,
    required this.dialogo,
    required this.chiave,
    required this.consiglio,
    required this.domanda,
  });

  final TarotSpread spread;
  final TarotTopic topic;

  /// Strato 1: una riga forte, dalla sintesi della carta del Presente.
  final String sintesi;

  /// Strato 2: le tre posizioni, ognuna col testo ricco letto nell'argomento.
  final List<PosizioneLetta> posizioni;

  /// Strato 3: come le tre carte parlano fra loro.
  final Dialogo dialogo;

  /// Strato 4: quale delle tre e' il cuore.
  final CartaChiave chiave;

  /// Strato 5: il consiglio di Medora, dal gruppo dell'argomento.
  final String consiglio;

  /// Strato 6: la domanda che apre a Chiedi ai Maestri.
  final String domanda;

  /// Strato 7: le azioni e il disclaimer stanno nella schermata, una sola volta.

  /// Compone la lettura di [spread] dentro [topic].
  static TarotReading of(TarotSpread spread, TarotTopic topic) {
    return TarotReading(
      spread: spread,
      topic: topic,
      sintesi: spread.presente.summary,
      posizioni: [
        for (final drawn in spread.cards) PosizioneLetta.of(drawn, topic),
      ],
      dialogo: dialogoDi(spread),
      chiave: chiaveDi(spread),
      consiglio: topic.group.consiglio,
      domanda: domandaDi(spread, topic),
    );
  }

  /// Le carte che dialogano, con le regole del corpus.
  ///
  /// Se piu' regole valgono, vince quella coi Maggiori: un tema del destino
  /// pesa piu' di un accostamento di semi.
  static Dialogo dialogoDi(TarotSpread spread) {
    final carte = spread.cards;
    final maggiori =
        carte.where((c) => c.card.arcana == TarotArcana.maggiore).length;
    final rovesciate = carte.where((c) => c.reversed).length;
    final semi = carte
        .where((c) => c.card.seme != null)
        .map((c) => c.card.seme!)
        .toList();

    // Priorita' ai Maggiori.
    if (maggiori == 3) {
      return const Dialogo(
        rule: DialogoRule.treMaggiori,
        text: 'Un momento cardine della tua vita, il cielo insiste.',
      );
    }
    if (maggiori == 2) {
      return const Dialogo(
        rule: DialogoRule.dueMaggiori,
        text: 'Un tema del destino, qualcosa di grande attraversa la tua '
            'stesa, non è un caso.',
      );
    }

    // Tre carte dello stesso seme: un filo unico.
    if (semi.length == 3 && semi.toSet().length == 1) {
      final seme = semi.first;
      return Dialogo(
        rule: DialogoRule.stessoSeme,
        text: 'Un filo unico, l\'elemento domina la lettura: ${_elemento(seme)} '
            'di ${seme.italianName}.',
      );
    }

    // Lo stesso seme che ricorre dal Passato al Futuro.
    final estremi = [spread.passato.card.seme, spread.futuro.card.seme];
    if (estremi[0] != null && estremi[0] == estremi[1]) {
      return const Dialogo(
        rule: DialogoRule.semeCoerente,
        text: 'Un cammino coerente, stai andando nella tua direzione.',
      );
    }

    // Gli accostamenti di seme.
    final insieme = semi.toSet();
    if (insieme.contains(TarotSeme.spade) &&
        insieme.contains(TarotSeme.coppe)) {
      return const Dialogo(
        rule: DialogoRule.spadeCoppe,
        text: 'Mente e cuore ti tirano da due parti, cercano equilibrio.',
      );
    }
    if (insieme.contains(TarotSeme.bastoni) &&
        insieme.contains(TarotSeme.denari)) {
      return const Dialogo(
        rule: DialogoRule.bastoniDenari,
        text: 'Slancio e concretezza, l\'impulso chiede di posarsi a terra.',
      );
    }

    // I versi.
    if (rovesciate >= 2) {
      return const Dialogo(
        rule: DialogoRule.piuRovesciate,
        text: 'Un nodo da sciogliere prima di andare avanti, con margine di '
            'scelta.',
      );
    }
    if (rovesciate == 1) {
      return const Dialogo(
        rule: DialogoRule.unaRovesciata,
        text: 'Una svolta, un blocco che si scioglie mentre passi.',
      );
    }

    // Nessun Maggiore e nessun verso che parli: resta il quotidiano.
    return const Dialogo(
      rule: DialogoRule.soloMinori,
      text: 'La risposta è nel quotidiano e nelle tue mani, non in un destino '
          'più grande.',
    );
  }

  static String _elemento(TarotSeme seme) {
    switch (seme) {
      case TarotSeme.bastoni:
        return 'il fuoco';
      case TarotSeme.coppe:
        return 'l\'acqua';
      case TarotSeme.denari:
        return 'la terra';
      case TarotSeme.spade:
        return 'l\'aria';
    }
  }

  /// La carta chiave: di default il Presente.
  ///
  /// Se il Presente e' un Minore e fra le tre c'e' almeno un Maggiore, il cuore
  /// passa al Maggiore piu' significativo, quello col numero piu' alto.
  static CartaChiave chiaveDi(TarotSpread spread) {
    final presente = spread.presente;
    if (presente.card.arcana == TarotArcana.maggiore) {
      return CartaChiave(
        drawn: presente,
        perche: 'È la carta del momento che vivi: un Arcano Maggiore nel '
            'Presente parla più forte di ogni altra cosa.',
      );
    }
    final maggiori = spread.cards
        .where((c) => c.card.arcana == TarotArcana.maggiore)
        .toList();
    if (maggiori.isEmpty) {
      return CartaChiave(
        drawn: presente,
        perche: 'È la carta del momento che vivi, il centro della stesa.',
      );
    }
    maggiori.sort((a, b) => (b.card.majorNumber ?? 0)
        .compareTo(a.card.majorNumber ?? 0));
    final scelta = maggiori.first;
    return CartaChiave(
      drawn: scelta,
      perche: 'È l\'Arcano Maggiore più alto della stesa: pesa più del '
          'Minore che occupa il Presente.',
    );
  }

  /// Le domande di chiusura, dal pool del corpus.
  static const List<String> domande = [
    'Cosa sei disposto a lasciare andare per fare spazio a questo?',
    'Se il cielo inclina e non obbliga, qual è il primo passo che spetta a te?',
    'Cosa cambierebbe se ti fidassi di ciò che già senti?',
    'Qual è la verità che stai rimandando di dirti?',
    'Di cosa hai davvero bisogno, oltre a ciò che chiedi?',
  ];

  /// Pesca la domanda in modo deterministico da carte e argomento: la stessa
  /// stesa sullo stesso argomento chiude sempre con la stessa domanda.
  static String domandaDi(TarotSpread spread, TarotTopic topic) {
    var hash = 0x811c9dc5;
    void mix(int byte) {
      hash = (hash ^ byte) & 0xFFFFFFFF;
      final lo = (hash & 0xFFFF) * 0x01000193;
      final hi = (((hash >> 16) & 0xFFFF) * 0x01000193 & 0xFFFF) << 16;
      hash = (lo + hi) & 0xFFFFFFFF;
    }

    for (final drawn in spread.cards) {
      for (final code in drawn.card.stem.codeUnits) {
        mix(code & 0xFF);
      }
      mix(drawn.reversed ? 1 : 0);
    }
    mix(topic.index & 0xFF);
    return domande[hash % domande.length];
  }
}

/// Una posizione letta dentro l'argomento scelto.
class PosizioneLetta {
  const PosizioneLetta({
    required this.drawn,
    required this.apertura,
    required this.testo,
  });

  final DrawnCard drawn;

  /// La riga che introduce la posizione dentro l'argomento.
  final String apertura;

  /// Il testo ricco della carta, nel verso in cui e' uscita.
  final String testo;

  static PosizioneLetta of(DrawnCard drawn, TarotTopic topic) {
    return PosizioneLetta(
      drawn: drawn,
      // Solo la lente dell'argomento: il quando lo dice gia' l'etichetta della
      // posizione sopra, e ripeterlo dava frasi che si contraddicevano, come
      // "sul bivio davanti a te, alle tue spalle".
      apertura: topic.lente,
      testo: drawn.meaning,
    );
  }
}
