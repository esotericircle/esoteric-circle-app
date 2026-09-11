import 'domanda_della_persona.dart';
import 'tarot_card.dart';
import 'tarot_spread.dart';
import '../../features/horoscope/answer_depth.dart';
import 'tarot_topic.dart';
import 'voce_della_stesa.dart';
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
        for (final drawn in spread.cards)
          PosizioneLetta.of(drawn, topic, spread),
      ],
      chiave: chiaveDi(spread),
      // **LA DOMANDA PULITA E NON LA FRASE GIA' CONFEZIONATA.** Ordine DF
      // voce 02: il riconoscimento della domanda ha adesso otto forme, e la
      // forma la sceglie `VoceDellaStesa`. Passando qui
      // `DomandaDellaPersona.apertura`, che e' gia' una frase intera, la
      // domanda finiva dentro le virgolette della forma e si leggeva
      // «Su "Hai chiesto: denaro e fortuna? Le tre carte rispondono..."», che
      // e' una frase dentro una frase.
      consiglio: consiglioDi(spread, lente, domanda, fattoDelCielo, sua),
      domanda: domanda,
    );
  }

  /// **IL CONSIGLIO DI MEDORA, E OGNI PAROLA DIPENDE DALLE CARTE USCITE.**
  /// Rifatto dall'ordine DF voci 02, 04.1, 04.2, 04.3, 04.7, 04.8 e 04.9,
  /// 11 settembre 2026.
  ///
  /// **IL FATTO CHE HA APERTO L'ORDINE, con le parole del fondatore.** *"ho
  /// fatto 4 letture di tarocchi con la stessa domanda denaro e fortuna"*, e i
  /// primi due paragrafi erano **identici al carattere** in tutte e quattro,
  /// pur con dodici carte diverse fra loro. *"IO ESIGO CHE OGNI RISPOSTA SIA
  /// DIVERSA ANCHE SE DOVESSI FARE 100 LETTURE CONSECUTIVE CON LA STESSA
  /// DOMANDA."*
  ///
  /// **LA CAUSA, e stava scritta qui dentro in due righe.** I primi due pezzi
  /// erano:
  ///
  ///     '${topic.lente}, ${topic.group.risposta}',
  ///     topic.group.consiglio,
  ///
  /// `topic.lente` ha sedici valori, `group.risposta` e `group.consiglio` ne
  /// hanno **tre**, uno per gruppo. **Nessuno dei tre guardava le carte.** A
  /// parita' di argomento quei due paragrafi erano una costante, e nessuna
  /// estrazione poteva cambiarli. **Attribuzione: ordine S voce 26 per la
  /// risposta e corpus `stesa_interpretazione.md` per l'azione**, montati qui
  /// dall'ordine P voce 09.
  ///
  /// **E LA MISURA LO DICEVA GIA', se qualcuno l'avesse presa.** Su cento
  /// letture con lo stesso argomento la somiglianza massima a coppie era del
  /// **94,4 per cento** e lo **stesso paragrafo compariva cento volte su
  /// cento**. Adesso i numeri veri li stampa
  /// `test/cento_letture_uguali_test.dart`.
  ///
  /// **LA CURA, in una riga: il testo lo sceglie l'estrazione.** Le forme
  /// stanno in `VoceDellaStesa`, il filo che le sceglie nasce dalle tre carte e
  /// dai loro versi, e **non da un orologio**: le stesse tre carte danno sempre
  /// lo stesso testo, quindi la bolla piu' lunga dell'app continua a non
  /// toccare l'LLM e resta cacheabile. **La casualita' sta nel mazzo, dove deve
  /// stare.**
  ///
  /// **E L'ORDINE DI LETTURA E' CAMBIATO**, voce DF.04.9: le carte sono nel
  /// **primo** paragrafo, non dal terzo in poi. Il fondatore: *"con un verdetto
  /// sempre uguale, la persona legge le prime otto righe, le riconosce, e non
  /// arriva mai alla parte che cambia"*.
  static String consiglioDi(
      TarotSpread spread, TarotTopic topic, String domanda,
      [String? fattoDelCielo,
      String? apertura]) {
    final paragrafi = VoceDellaStesa.paragrafi(
      spread,
      topic,
      domandaScritta: apertura,
      fattoDelCielo: fattoDelCielo,
    );
    // **LA LETTURA DEI VERSI E DEI MAGGIORI RESTA**, e sta gia' dentro
    // l'ultimo paragrafo composto da `VoceDellaStesa`: e' il pezzo di verita'
    // rimasto della bolla eliminata dalla voce P.08, e sono fatti della
    // tradizione, non ornamenti. **Da qui se n'e' andata** perche' anche lei
    // aveva bisogno del filo: una frase sola per ogni conto di rovesciate
    // tornava una trentina di volte su cento letture.
    final tutti = [...paragrafi];
    // **LA DOMANDA DI CHIUSURA NON SI RIPETE.** Ordine DF voce 02, misura D.
    //
    // Prima la domanda finiva **sempre** in coda come paragrafo suo, e quando
    // era quella scritta dalla persona compariva **due volte nella stessa
    // bolla**: una in cima, riconosciuta, e una in fondo, identica. Su cento
    // letture con la stessa domanda faceva **cento paragrafi uguali**, che e'
    // la misura D dell'ordine, e la soglia e' due.
    //
    // Adesso: se la persona ha scritto la sua domanda, quella e' gia'
    // riconosciuta nella prima riga e in coda non si ripete. Se non l'ha
    // scritta, in coda va la domanda del corpus, che nasce **dalle carte** e
    // quindi cambia a ogni estrazione.
    final laRipete =
        apertura != null && apertura.trim().isNotEmpty;
    final coda = laRipete ? '' : '\n\n$domanda';
    final prosa = tutti.join('\n\n');
    return '${TettiDellaStesa.dentro(prosa, TettiDellaStesa.consiglio - domanda.length - 2)}'
        '$coda';
  }

  // **LA SINTESI IN MINUSCOLA NON SERVE PIU.** Ordine DF voce 04.3, 11
  // settembre 2026. Qui viveva un aiutante che toglieva la maiuscola e il
  // punto a una sintesi del corpus per infilarla dentro una frase piu grande.
  // Serviva allo stampo vecchio, che citava i significati delle carte dentro
  // il Consiglio **mentre l elenco Passato Presente Futuro li scriveva gia a
  // pochi centimetri**. Adesso il Consiglio le carte le NOMINA e non le cita,
  // quindi non c e piu niente da mettere in minuscola.

  // **LA LETTURA DEI VERSI E DEI MAGGIORI VIVE IN VoceDellaStesa.**
  // Ordine DF voce 02, 11 settembre 2026. Qui c era una frase sola per ogni
  // conto di rovesciate, e i conti sono tre: su cento letture la stessa riga
  // tornava una trentina di volte, e su quella riga si reggeva buona parte
  // della somiglianza a coppie. Adesso sono quattro forme per caso e le
  // sceglie il filo, cioe le carte uscite. Il numero dei Maggiori e scritto
  // in lettere, come chiede la voce DF.04.7.

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

  static PosizioneLetta of(
      DrawnCard drawn, TarotTopic topic, TarotSpread spread) {
    return PosizioneLetta(
      drawn: drawn,
      // **L'APERTURA VARIA, ordine DF voce 02.** Era la lente dell'argomento,
      // identica in tutte e tre le posizioni di tutte le letture: quindici
      // parole regalate a ogni confronto. La lente resta il taglio con cui la
      // carta si legge, ma non e' piu' lei a fare da attacco.
      apertura: VoceDellaStesa.aperturaDellaPosizione(
          spread, SpreadPosition.values.indexOf(drawn.position)),
      testo: drawn.meaning,
    );
  }
}
