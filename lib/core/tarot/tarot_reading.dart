import 'domanda_della_persona.dart';
import 'tarot_card.dart';
import 'tarot_spread.dart';
import '../../features/horoscope/answer_depth.dart';
import 'tarot_topic.dart';
import 'tetti_della_stesa.dart';

// LE CARTE CHE DIALOGANO NON VIVONO PIU' QUI, ordine P voce 08.
//
// C'erano una classe per la riga del dialogo, una enumerazione di nove regole e
// la funzione che le applicava in ordine di priorita'. La bolla che mostrava
// quel testo e' stata eliminata, e con lei se ne va la generazione: eliminare
// vuol dire togliere il widget, i suoi testi, la sua generazione e il suo
// costo, non nasconderla dietro un interruttore. I tre nomi non compaiono
// nemmeno in questo commento, perche' la prova della voce 08 li cerca nel
// sorgente e un commento che li nomina la farebbe cadere per finta.
//
// Cio' che quel testo diceva di vero, cioe' quanti Arcani Maggiori sono usciti
// e quante carte sono rovesciate, non e' andato perduto: e' entrato nel
// CONSIGLIO, che per la voce 09 deve poggiare sulle tre carte insieme. Una
// bolla in meno e una bolla piu' piena, invece di due bolle che dicevano la
// stessa cosa in due modi.

/// La carta che e' il cuore della stesa, con la ragione della scelta.
class CartaChiave {
  const CartaChiave({required this.drawn, required this.perche});

  final DrawnCard drawn;
  final String perche;
}

/// L'interpretazione completa di una stesa, letta dentro un argomento.
///
/// **L'ORDINE E' CAMBIATO CON L'ORDINE P.** Prima gli strati erano sette e il
/// consiglio arrivava per ultimo, scarno, dopo due bolle che ripetevano cio'
/// che le carte avevano gia' detto. Adesso sono cinque e il primo e' il
/// consiglio: sintesi forte, IL CONSIGLIO con la domanda dentro, le tre
/// posizioni fra cui una porta lo stato di carta chiave, poi le azioni col
/// disclaimer.
///
/// La ragione sta nella voce 09: il consiglio e' la bolla che la persona porta
/// via, quindi si genera prima e si legge prima. E la domanda non e' piu' una
/// bolla: e' come finisce cio' che Medora dice, perche' una domanda in una
/// cornice sua sembra un compito assegnato.
///
/// Tutto e' deterministico e cacheabile: a parita' di carte e di argomento il
/// testo e' sempre lo stesso. A runtime Gemini cuce solo l'ultimo strato sulla
/// persona, il resto non tocca l'LLM.
class TarotReading {
  const TarotReading({
    required this.spread,
    required this.topic,
    required this.depth,
    required this.sintesi,
    required this.posizioni,
    required this.chiave,
    required this.consiglio,
    required this.domanda,
  });

  final TarotSpread spread;
  final TarotTopic topic;

  /// La profondita' di TUTTA la lettura, non di una posizione sola.
  ///
  /// Le tre posizioni sono una lettura unica e continua: una profondita' per
  /// posizione darebbe un racconto sbilanciato, lungo in un punto e stretto in
  /// quello dopo. A runtime questa e' il tetto di lunghezza di ogni testo di
  /// responso, e i testi lunghi si generano solo quando la persona li chiede.
  final AnswerDepth depth;

  /// Strato 1: una riga forte, dalla sintesi della carta del Presente.
  final String sintesi;

  /// Strato 3: le tre posizioni, ognuna col testo ricco letto nell'argomento.
  final List<PosizioneLetta> posizioni;

  /// Quale delle tre posizioni porta lo STATO di carta chiave.
  ///
  /// **Non e' piu' una bolla**, ordine P voce 07: la carta chiave e' uno stato
  /// di una delle tre bolle di Passato, Presente e Futuro, e la ragione della
  /// scelta e' la marcatura piccola dentro quella bolla.
  final CartaChiave chiave;

  /// STRATO 2, IL PRIMO CHE SI LEGGE: il consiglio di Medora, con la domanda
  /// dentro come ultimo paragrafo.
  final String consiglio;

  /// La domanda di chiusura, tenuta anche come dato suo.
  ///
  /// A schermo vive dentro il [consiglio] e non ha una bolla propria. Resta un
  /// campo perche' va SALVATA: ricompare nel dono del mattino successivo con la
  /// formula "Ieri Medora ti ha lasciato questa domanda", ed e' quella la
  /// ragione per cui la domanda esiste.
  final String domanda;

  /// Strato 4: le azioni e il disclaimer stanno nella schermata, una sola volta.

  /// Compone la lettura di [spread] dentro [topic], alla profondita' [depth].
  /// [fattoDelCielo] e' la riga del cielo VERO di oggi, quando c'e'. Ordine BN
  /// voce 07: le due arti vivono nella stessa app e non si parlavano, e la
  /// stesa non sapeva niente del cielo che l'Oroscopo calcola gia'. Nulla
  /// quando la carta natale manca: in quel caso il consiglio resta quello di
  /// oggi, e **non si finge nessun transito**.
  static TarotReading of(
    TarotSpread spread,
    TarotTopic topic, {
    AnswerDepth depth = AnswerDepth.free,
    String? fattoDelCielo,
    String? domandaScritta,
  }) {
    // **LA DOMANDA DELLA PERSONA ENTRA QUI, ordine CQ voce 6.10.**
    //
    // Prima non entrava affatto: misurato, su una domanda di cinque parole
    // portanti ne arrivavano ZERO nel testo del responso. Il campo esisteva,
    // raccoglieva il testo e lo mostrava, e la lettura chiudeva con una
    // domanda pescata dal corpus, identica che tu avessi scritto qualcosa o
    // no.
    //
    // **Fa due cose, e la seconda e' quella che conta.** Si fa nominare, cosi'
    // chi legge vede che e' stata letta; e **sceglie la lente**, cosi' tutte
    // e tre le carte vengono lette col taglio della sua domanda. Solo la
    // prima sarebbe la sua frase incollata sopra un testo generale, ed e'
    // esattamente cio' che il fondatore ha chiamato "generiche".
    final sua = DomandaDellaPersona.pulita(domandaScritta);
    final lente = sua == null
        ? topic
        : DomandaDellaPersona.lenteDedotta(sua) ?? topic;
    final domanda = sua ?? domandaDi(spread, topic);
    return TarotReading(
      spread: spread,
      topic: lente,
      depth: depth,
      sintesi: TettiDellaStesa.dentro(
          spread.presente.summary, TettiDellaStesa.sintesi),
      posizioni: [
        for (final drawn in spread.cards) PosizioneLetta.of(drawn, topic),
      ],
      chiave: chiaveDi(spread),
      consiglio: consiglioDi(spread, lente, domanda, fattoDelCielo,
          DomandaDellaPersona.apertura(domandaScritta)),
      domanda: domanda,
    );
  }

  /// IL CONSIGLIO DI MEDORA, che poggia sulle tre carte insieme e le nomina.
  ///
  /// **Ordine P voce 09.** Prima era il solo modello del gruppo, cioe' un testo
  /// che valeva identico per qualunque stesa dello stesso argomento: la persona
  /// se ne accorge alla seconda lettura, ed e' esattamente il motivo per cui la
  /// bolla piu' importante era anche la meno credibile.
  ///
  /// Adesso il consiglio ha quattro pezzi, in quest'ordine: il consiglio del
  /// gruppo, che resta materiale del corpus e non si tocca; una frase che lega
  /// il Passato al Presente NOMINANDOLI; una frase sul Futuro che dice dove
  /// questo va, senza mai prometterlo; e la lettura dei versi e dei Maggiori,
  /// che e' il pezzo di verita' rimasto della bolla eliminata dalla voce 08.
  /// Poi una riga di stacco, e la domanda.
  ///
  /// Resta deterministico: stesse carte e stesso argomento danno sempre lo
  /// stesso testo, quindi la bolla piu' lunga dell'app continua a non toccare
  /// l'LLM.
  static String consiglioDi(
      TarotSpread spread, TarotTopic topic, String domanda,
      [String? fattoDelCielo,
      String? apertura]) {
    final pezzi = <String>[
      // **LA RISPOSTA PRIMA DELL'AZIONE, ordine S voce 26.** L'allegato C ha
      // portato le tre risposte che mancavano, una per gruppo, e il montaggio e'
      // quello che dichiara: la lente dell'argomento, la virgola, la risposta,
      // poi l'azione che c'era gia' e non si tocca. Prima la bolla apriva
      // sull'azione, e chi legge riceveva un consiglio prima di sapere cosa la
      // lettura vede nella sua situazione.
      //
      // **Le sedici lenti fanno sedici aperture da tre soli testi**, ed e' la
      // ragione per cui le risposte cominciano in minuscola: si innestano, non
      // stanno da sole.
      '${topic.lente}, ${topic.group.risposta}',
      topic.group.consiglio,
      'Le tre carte lo dicono insieme. ${spread.passato.displayName} tiene il '
          'filo di ciò che è stato, ${_minuscola(spread.passato.summary)} e '
          '${spread.presente.displayName} è ciò che hai fra le mani adesso.',
      '${spread.futuro.displayName} non è una sentenza: è dove questo va se non '
          'cambi passo, ${_minuscola(spread.futuro.summary)}.',
      _letturaDeiVersi(spread),
    ];
    // **I PARAGRAFI ESISTONO GIA' QUI, ordine BN voce 06.** Parole del
    // fondatore: "vorrei che il titolo fosse piu' grande e il testo diviso in
    // 2/3 paragrafi". I paragrafi NON si ricavano tagliando il blocco a
    // occhio: erano gia' cinque pezzi dichiarati, appiattiti da un `join(' ')`
    // in un muro solo. Si raggruppano per SENSO, tre paragrafi e non cinque:
    // cosa dice la lettura, cosa dicono le tre carte insieme, e cosa dicono i
    // versi. Nessuna frase viene spezzata, perche' non si taglia niente: si
    // uniscono pezzi che erano gia' interi.
    final paragrafi = <String>[
      // **LA DOMANDA DELLA PERSONA APRE, quando c'e'. Ordine CQ voce
      // 6.10.** Sta in cima e non in coda perche' chi ha scritto una
      // domanda deve vedere subito che e' stata letta, non alla fine di un
      // testo che sembra scritto per chiunque.
      //
      // **E sta fra i PARAGRAFI e non fra i pezzi, ed e' un difetto che ho
      // fatto e misurato.** Messa fra i `pezzi` spostava di uno tutti gli
      // indici, e i paragrafi qui sotto si compongono per indice: il
      // consiglio si rimontava sbagliato **anche per chi non aveva scritto
      // nessuna domanda**. Lo ha preso la tavola generata delle lunghezze.
      if (apertura != null && apertura.trim().isNotEmpty) apertura else '',
      // La lente dell'argomento con la risposta, e il consiglio del gruppo.
      [pezzi[0], pezzi[1]].where((p) => p.isNotEmpty).join(' '),
      // Le tre carte, dal passato al futuro.
      [pezzi[2], pezzi[3]].where((p) => p.isNotEmpty).join(' '),
      // I versi e i Maggiori, che possono non esserci: in quel caso i
      // paragrafi restano due, e due l'ordine li ammette.
      // **IL CONSIGLIO RACCOGLIE IL CIELO, ordine BN voce 07.** Solo quando
      // c'e' un fatto VERO: senza carta natale questa coda non esiste e il
      // consiglio resta quello di oggi. Una frase generica travestita da
      // transito sarebbe una promessa non mantenuta detta nella bolla che la
      // persona porta via.
      //
      // Sta in CODA all'ultimo paragrafo e non ne apre uno suo: la voce 06
      // vuole due o tre paragrafi, e il cielo non deve farne nascere un
      // quarto. Le due voci dello stesso ordine devono stare in piedi
      // insieme.
      [
        pezzi[4],
        if (fattoDelCielo != null && fattoDelCielo.trim().isNotEmpty)
          'E il cielo di oggi lo accompagna. $fattoDelCielo',
      ].where((p) => p.trim().isNotEmpty).join(' '),
    ].where((p) => p.trim().isNotEmpty).toList();
    final prosa = paragrafi.join('\n\n');
    return '${TettiDellaStesa.dentro(prosa, TettiDellaStesa.consiglio - domanda.length - 2)}'
        '\n\n$domanda';
  }

  /// La sintesi breve senza la maiuscola iniziale e senza il punto finale, per
  /// entrare dentro una frase piu' grande invece di interromperla.
  static String _minuscola(String sintesi) {
    var testo = sintesi.trim();
    while (testo.endsWith('.')) {
      testo = testo.substring(0, testo.length - 1);
    }
    if (testo.isEmpty) return testo;
    return testo[0].toLowerCase() + testo.substring(1);
  }

  /// COSA DICONO I VERSI E I MAGGIORI, tutti e tre insieme.
  ///
  /// E' il contenuto vero che la bolla "Le carte che dialogano" portava, entrato
  /// nel consiglio invece di sparire con lei: quante carte sono uscite
  /// rovesciate e quanti Arcani Maggiori attraversano la stesa sono fatti della
  /// tradizione, non ornamenti.
  static String _letturaDeiVersi(TarotSpread spread) {
    final rovesciate = spread.cards.where((c) => c.reversed).length;
    final maggiori =
        spread.cards.where((c) => c.card.arcana == TarotArcana.maggiore).length;
    final versi = switch (rovesciate) {
      // LA PAROLA DEL ROVESCIO NON SI SCRIVE A MANO, nemmeno qui. La parola
      // accordata alla carta vive in `DrawnCard.versoLabel`, e una parola fissa
      // riporterebbe il maschile su "La Papessa". Qui il soggetto non e' una
      // carta ma il CONTO delle carte, quindi si dice il fatto senza la parola:
      // "uscita al rovescio" vale per qualunque arcano, e la prova che
      // sorveglia l'accordo resta verde perche' non ha piu' niente da accordare.
      0 => 'Nessuna delle tre è uscita al rovescio: la strada è libera e il '
          'passo tocca a te.',
      1 => 'Una delle tre è uscita al rovescio, quindi c\'è un nodo da '
          'sciogliere e non un muro.',
      _ => 'Più di una è uscita al rovescio: prima di andare avanti c\'è '
          'qualcosa da sciogliere e il margine per farlo ce l\'hai.',
    };
    if (maggiori >= 2) {
      return '$versi E con $maggiori Arcani Maggiori nella stesa il tema è più '
          'grande della giornata: il cielo insiste su questo.';
    }
    return versi;
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
    maggiori.sort(
        (a, b) => (b.card.majorNumber ?? 0).compareTo(a.card.majorNumber ?? 0));
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
