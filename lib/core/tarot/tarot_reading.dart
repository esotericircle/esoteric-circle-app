import 'domanda_della_persona.dart';
import 'la_domanda_letta.dart';
import 'la_lettura_dal_modello.dart';
import 'le_carte_nella_posizione.dart';
import 'le_singole_sulla_domanda.dart';
import 'tarot_card.dart';
import 'tarot_spread.dart';
import '../../features/horoscope/answer_depth.dart';
import 'tarot_topic.dart';
import 'voce_della_stesa.dart';
import 'tetti_della_stesa.dart';
import '../../core/chat/user_profile.dart';
import '../responsi/la_forma_del_responso.dart';

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
/// via, quindi si genera prima e si legge prima.
///
/// **LAPIDE: "A RUNTIME GEMINI CUCE SOLO L'ULTIMO STRATO".** Qui era scritto
/// che tutto era deterministico e cacheabile, e che l'LLM non toccava la
/// lettura. Dall'ordine EQ voce 04, 27 settembre 2026, la lettura la scrive
/// Flash quando risponde (`LaLetturaDellaStesa`): il fondatore l'aveva
/// trovata *"troppo criptica"*, e il collaudo "prima" gli ha dato ragione,
/// una risposta diretta su venti letture e nessuna carta su sessanta letta
/// nella sua posizione (`docs/collaudo/EQ/tarocchi/prima`).
///
/// **LA FORMA NUOVA, ordine GA voci GA.03, GA.04, GA.05 e GA.07, 20 ottobre
/// 2026.** Il responso principale e' un `ResponsoInterpretato` ([principale]):
/// il titolo, la risposta, il riquadro "Cosa fare adesso" e, nella Lunga,
/// l'approfondimento e la contemplazione propiziatoria della carta chiave.
/// Lo scrive il modello sulla domanda e su tutte le carte; quando il modello
/// non torna parla la lettura di casa (`VoceDellaStesa.responsoDiCasa`, o la
/// carta sola dal corpus), sempre Breve. Ogni carta ha il suo responso breve
/// dal corpus (decisione del fondatore "Carte dal corpus",
/// [PosizioneLetta.responso]). Il "Da dove viene" ([fonte]) e' uno solo
/// e chiude la consultazione.
class TarotReading {
  const TarotReading({
    required this.spread,
    required this.topic,
    required this.depth,
    required this.sintesi,
    required this.posizioni,
    required this.chiave,
    required this.principale,
    required this.domanda,
  });

  final TarotSpread spread;
  final TarotTopic topic;

  /// La profondita' del responso principale, non delle carte: le singole
  /// carte hanno sempre il responso breve (voce GA.05, il fondatore: *"solo
  /// per il responso principale e non per le singole carte"*).
  final AnswerDepth depth;

  /// Strato 1: una riga forte, dalla sintesi della carta del Presente.
  final String sintesi;

  /// Strato 3: le carte, ognuna col suo responso breve letto nell'argomento.
  final List<PosizioneLetta> posizioni;

  /// Quale delle posizioni porta lo STATO di carta chiave.
  ///
  /// **Non e' piu' una bolla**, ordine P voce 07: la carta chiave e' uno stato
  /// di una delle bolle delle carte, e la ragione della scelta e' la
  /// marcatura piccola dentro quella bolla.
  final CartaChiave chiave;

  /// **IL RESPONSO PRINCIPALE**, nella forma di GA.03, col suo "Da dove
  /// viene". Nella stesa a una carta e' il responso della carta, e sotto non
  /// c'e' un secondo blocco per la stessa carta (voce GA.05).
  final ResponsoInterpretato principale;

  /// **IL TITOLO, CHE E' GIA' LA RISPOSTA.** Ordine FK aggiunta voci A1 e A2.
  /// Quello del modello quando c'e' e regge (non nomina le carte), altrimenti
  /// quello della lettura di casa: mai vuoto, mai col punto in fondo.
  String get titolo => principale.titolo;

  /// **IL "DA DOVE VIENE" DELLA CONSULTAZIONE**, uno solo (voce GA.05): le
  /// carte uscite col verso e la posizione, il mazzo, la stesa, la fonte dei
  /// significati, nella Lunga la fonte della contemplazione e il cielo di
  /// oggi quando c'e'.
  String get fonte => principale.daDoveViene ?? '';

  /// Il responso principale senza il "Da dove viene": la schermata delle
  /// stese con piu' carte lo disegna cosi', e chiude la consultazione col
  /// "Da dove viene" dopo le carte.
  ResponsoInterpretato get principaleSenzaLaFonte => ResponsoInterpretato(
        arte: principale.arte,
        titolo: principale.titolo,
        risposta: principale.risposta,
        cosaFare: principale.cosaFare,
        approfondimento: principale.approfondimento,
        rito: principale.rito,
      );

  /// **IL CONSIGLIO COME TESTO**, per chi lo porta via: il Parlane con
  /// Medora, il diario, la card da condividere, le prove della diversita'.
  /// La risposta, il cosa fare e, nella Lunga, l'approfondimento, separati da
  /// una riga vuota. **La domanda di chiusura non ci sta piu'** (ordine GA):
  /// resta un dato ([domanda]) per il dono del mattino.
  String get consiglio => [
        principale.risposta,
        principale.cosaFare,
        if (principale.approfondimento != null) principale.approfondimento!,
      ].join('\n\n');

  /// La domanda di chiusura, tenuta come dato suo.
  ///
  /// **Non va a video dall'ordine GA**: la forma di GA.03 non le da' un
  /// posto. Resta un campo perche' va SALVATA: ricompare nel dono del
  /// mattino successivo con la formula "Ieri Medora ti ha lasciato questa
  /// domanda", ed e' quella la ragione per cui la domanda esiste.
  final String domanda;

  /// Strato 4: le azioni e il disclaimer stanno nella schermata, una sola volta.

  /// Compone la lettura di [spread] dentro [topic], alla profondita' [depth].
  /// [fattoDelCielo] e' la riga del cielo VERO di oggi, quando c'e'. Ordine BN
  /// voce 07: le due arti vivono nella stessa app e non si parlavano, e la
  /// stesa non sapeva niente del cielo che l'Oroscopo calcola gia'. Nulla
  /// quando la carta natale manca: in quel caso **non si finge nessun
  /// transito**. Dall'ordine GA la riga del cielo sta nel "Da dove viene".
  ///
  /// [dalModello] e' il responso principale scritto da Flash, ordine EQ voce
  /// 04 e ordine GA. Nullo, parla la lettura di casa. [mazzo] e
  /// [nomeDellaStesa] entrano nel "Da dove viene".
  static TarotReading of(
    TarotSpread spread,
    TarotTopic topic, {
    AnswerDepth depth = AnswerDepth.free,
    String? fattoDelCielo,
    String? domandaScritta,
    LetturaDelModello? dalModello,
    List<int>? uscite,
    String? mazzo,
    String? nomeDellaStesa,
  }) {
    // **LA DOMANDA DELLA PERSONA ENTRA QUI, ordine CQ voce 6.10.**
    //
    // Prima non entrava affatto: misurato, su una domanda di cinque parole
    // portanti ne arrivavano ZERO nel testo del responso. **Fa due cose, e la
    // seconda e' quella che conta.** Si fa nominare, cosi' chi legge vede che
    // e' stata letta; e **sceglie la lente**, cosi' le carte vengono lette
    // col taglio della sua domanda.
    final sua = DomandaDellaPersona.pulita(domandaScritta);
    final lente =
        sua == null ? topic : DomandaDellaPersona.lenteDedotta(sua) ?? topic;
    final domanda = sua ?? domandaDi(spread, topic);
    final posizioni = [
      for (var i = 0; i < spread.cards.length; i++)
        PosizioneLetta.of(spread.cards[i], topic, spread,
            uscita: uscite != null && i < uscite.length ? uscite[i] : 0,
            domanda: LaDomandaLetta.di(sua),
            posto: i,
            base: spread.cards.first.card.name.codeUnits
                .fold<int>(0, (a, b) => a + b)),
    ];
    final chiave = chiaveDi(spread, domandaScritta: sua);
    return TarotReading(
      spread: spread,
      topic: lente,
      depth: depth,
      sintesi:
          TettiDellaStesa.dentro(spread.cuore.summary, TettiDellaStesa.sintesi),
      posizioni: posizioni,
      chiave: chiave,
      principale: principaleDi(spread, lente, posizioni, chiave,
          depth: depth,
          dalModello: dalModello,
          domandaScritta: sua,
          fattoDelCielo: fattoDelCielo,
          mazzo: mazzo,
          nomeDellaStesa: nomeDellaStesa),
      domanda: domanda,
    );
  }

  /// **IL RESPONSO PRINCIPALE**, ordine GA voci GA.03, GA.04 e GA.05.
  ///
  /// - **Dal modello**, quando c'e': il suo titolo se regge (non nomina le
  ///   carte), la sua risposta e il suo cosa fare; nella Lunga il suo
  ///   approfondimento e la contemplazione propiziatoria della carta chiave
  ///   dal corpus dei riti, mai dal modello (*"Nessuna formula inventata"*).
  /// - **Di casa**, quando il modello non torna: nella stesa a una carta il
  ///   responso della carta dal corpus (titolo, paragrafo e cosa fare), nelle
  ///   altre `VoceDellaStesa.responsoDiCasa`. Sempre Breve: senza modello non
  ///   c'e' un approfondimento, e un rito senza approfondimento sarebbe una
  ///   forma a meta' (ordine FN, *"un riquadro arancione senza niente
  ///   dentro"*).
  static ResponsoInterpretato principaleDi(
    TarotSpread spread,
    TarotTopic lente,
    List<PosizioneLetta> posizioni,
    CartaChiave chiave, {
    required AnswerDepth depth,
    LetturaDelModello? dalModello,
    String? domandaScritta,
    String? fattoDelCielo,
    String? mazzo,
    String? nomeDellaStesa,
  }) {
    final lunga = depth == AnswerDepth.profonda &&
        dalModello != null &&
        dalModello.approfondimento.isNotEmpty;
    final rito =
        lunga ? LeCarteNellaPosizione.contemplazioneDi(chiave.drawn) : null;
    // Un rito che manca nel corpus non si inventa: senza, il responso resta
    // Breve. Non succede, la guardia pretende i 156 riti.
    final eLunga = lunga && rito != null && rito.trim().isNotEmpty;
    final fonte = daDoveViene(spread,
        mazzo: mazzo,
        stesa: nomeDellaStesa,
        contemplazione: eLunga ? chiave.drawn : null,
        cielo: fattoDelCielo);
    if (dalModello == null) {
      // **LA CARTA SOLA PASSA DALLA VOCE ANCHE LEI**, ordine GA voce GA.06,
      // 21 ottobre 2026. LAPIDE: il responso principale della stesa a una
      // carta era il responso della carta dal corpus (titolo, paragrafo e
      // cosa fare della posizione `cartaSola`). Il lettore cieco ha trovato
      // che in nove stese a una carta su dieci quel paragrafo descriveva la
      // carta senza rispondere alla domanda (*"L'abitudine fa da cinghia a
      // un peso che non ti riguarda"* a chi chiede di una promozione). Il
      // corpus della carta descrive la carta e resta suo; la risposta alla
      // domanda la compone la voce, con la carta come carta chiave. Resta
      // un blocco solo per la stessa carta (voce GA.05). PADRE: ordine GA
      // voci 03 e 05, commit 8208cbcf.
      final casa = VoceDellaStesa.responsoDiCasa(spread, lente,
          domandaScritta: domandaScritta,
          fattoDelCielo: fattoDelCielo,
          chiave: chiave.drawn);
      return ResponsoInterpretato(
        arte: ArteInterpretata.tarocchi,
        titolo: _senzaPunto(casa.titolo),
        risposta: casa.risposta,
        cosaFare: casa.cosaFare,
        daDoveViene: fonte,
      );
    }
    return ResponsoInterpretato(
      arte: ArteInterpretata.tarocchi,
      titolo: titoloDi(spread, lente, dalModello,
          domandaScritta: domandaScritta, fattoDelCielo: fattoDelCielo),
      risposta: dalModello.risposta,
      cosaFare: dalModello.cosaFare,
      approfondimento: eLunga ? dalModello.approfondimento : null,
      rito: eLunga ? rito : null,
      daDoveViene: fonte,
    );
  }

  static String _senzaPunto(String t) {
    var s = t.trim();
    while (s.endsWith('.')) {
      s = s.substring(0, s.length - 1).trimRight();
    }
    return s;
  }

  /// Il titolo della lettura: quello del modello se c'e' e non nomina una
  /// carta (il simbolo non apre mai), altrimenti quello di casa: nella stesa
  /// a una carta il titolo della carta dal corpus, nelle altre quello di
  /// `VoceDellaStesa`.
  static String titoloDi(
      TarotSpread spread, TarotTopic topic, LetturaDelModello? dalModello,
      {String? domandaScritta, String? fattoDelCielo}) {
    var t = dalModello?.titolo.trim() ?? '';
    if (spread.cards.any((d) => LaLetturaDellaStesa.nominaLaCarta(
        t,
        d.card.name
            .replaceFirst(RegExp(r"^(Il |Lo |La |Le |Gli |I |L')"), '')))) {
      t = '';
    }
    if (t.isEmpty) {
      t = VoceDellaStesa.titoloDellaLettura(spread, topic,
          domandaScritta: domandaScritta,
          fattoDelCielo: fattoDelCielo,
          chiave: chiaveDi(spread, domandaScritta: domandaScritta).drawn);
    }
    return _senzaPunto(t);
  }

  /// **DA DOVE VIENE, in forma breve e verso la fine.** Ordine FK aggiunta
  /// voce A2; il fondatore, 3 settembre 2026: *"giustamente, e' giusto
  /// informarlo come e' stata estratta questa parola [...] ma questo in forma
  /// breve e verso la fine"*. Le carte uscite col loro verso e la loro
  /// posizione, il mazzo, la stesa e da dove vengono i significati.
  ///
  /// **Ordine GA voci GA.04 e GA.05**: chiude la consultazione una volta
  /// sola e cita le fonti di tutte le carte uscite; nella Lunga aggiunge la
  /// fonte della contemplazione propiziatoria della carta [contemplazione]
  /// (la pratica della Golden Dawn, `docs/corpus/riti/
  /// contemplazione_dei_tarocchi.md`); il cielo di oggi, quando c'e', sta
  /// qui e non dentro i paragrafi, che hanno la loro misura.
  static String daDoveViene(TarotSpread spread,
      {String? mazzo,
      String? stesa,
      DrawnCard? contemplazione,
      String? cielo}) {
    final carte = [
      for (final d in spread.cards)
        // **L'ETICHETTA, NON IL NOME CON LA MARCA**, ordine GA voce GA.06:
        // `label` porta la marca del genere a tre vie e arrivava a video
        // grezza, *"La Papessa ([te stesso|te stessa|tu])"*, in tutte e
        // dieci le Croci Celtiche del lettore cieco. PADRE: ordine FK
        // aggiunta voce A2 (commit 42e1fd68), che ha scritto la riga col
        // `label` dopo che l'ordine FI voce 05 (commit 6daf8be5) ci aveva
        // messo la marca.
        '${d.displayName} (${d.position.etichetta.toLowerCase()})',
    ].join(', ');
    final dove = [
      if (mazzo != null && mazzo.trim().isNotEmpty) 'Mazzo ${mazzo.trim()}',
      if (stesa != null && stesa.trim().isNotEmpty) stesa.trim(),
    ].join(', ');
    final righe = <String>[
      'Le carte uscite: $carte.',
      '${dove.isEmpty ? 'Ogni' : '$dove: ogni'} carta si legge col suo '
          'significato nella tradizione di Waite e nella posizione in cui è '
          'uscita.',
      if (contemplazione != null)
        'La contemplazione propiziatoria: '
            '${LeCarteNellaPosizione.fonteDellaContemplazione(contemplazione) ?? ''}',
      if (cielo != null && cielo.trim().isNotEmpty)
        'Accanto alle carte, il cielo di oggi: ${cielo.trim()}',
    ];
    return righe.where((r) => r.trim().isNotEmpty).join(' ');
  }

  // **LAPIDE: IL CONSIGLIO COMPOSTO A TRE PARAGRAFI.** Qui vivevano
  // `consiglioDelModello` (ordine EQ voce 04 e ordine FK aggiunta voce A2: la
  // risposta, il consiglio, il legame col cielo e la domanda di chiusura) e
  // `consiglioDi` (ordine DF voci 02, 04.1-04.9: i tre paragrafi di
  // `VoceDellaStesa` troncati al tetto `TettiDellaStesa.consiglio`). Dal
  // l'ordine GA il responso principale ha la forma di GA.03, due paragrafi
  // da 40 a 50 parole nella Breve, e non si tronca mai (voce GA.07): lo
  // compone [principaleDi].
  //
  // **IL FATTO CHE AVEVA APERTO L'ORDINE DF, con le parole del fondatore.**
  // *"ho fatto 4 letture di tarocchi con la stessa domanda denaro e
  // fortuna"*, e i primi due paragrafi erano identici al carattere. *"IO
  // ESIGO CHE OGNI RISPOSTA SIA DIVERSA ANCHE SE DOVESSI FARE 100 LETTURE
  // CONSECUTIVE CON LA STESSA DOMANDA."* La cura resta: il testo di casa lo
  // sceglie l'estrazione (`VoceDellaStesa`, il filo nato dalle carte), e le
  // prove della diversita' lo misurano sul responso nuovo.

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
  ///
  /// **CON LA DOMANDA, LA CARTA CHIAVE E' LA CARTA CHE RISPONDE.** Ordine GA
  /// voce GA.06, 21 ottobre 2026. A una domanda che chiede come va a finire
  /// (si' o no, quando, una scelta, un distacco, un timore, una domanda
  /// vaga) risponde la carta dell'esito; a una che chiede il modo o che cosa
  /// c'e', il cuore. Il lettore cieco indipendente ha trovato un si' tratto
  /// dal Presente con un Due di Coppe rovesciato nel Futuro (tarocchi-12), e
  /// L'Eremita, Maggiore piu' alto ma nel Passato, letto al presente come
  /// carta chiave (tarocchi-2): **il Maggiore piu' alto conta solo se sta in
  /// un posto che dice l'adesso o l'esito**, mai alle spalle o di traverso.
  /// La schermata marca la stessa carta da cui viene la risposta. PADRE:
  /// ordine GA voce GA.06, commit 9b2d2d29 (la chiave senza la domanda), e
  /// ordine FK aggiunta 2 voce A8 (il Maggiore in qualunque posizione).
  static CartaChiave chiaveDi(TarotSpread spread, {String? domandaScritta}) {
    // **IL CUORE DELLA STESA, ordine FK aggiunta 2 voce A8**: il presente
    // nella stesa a tre carte, e nelle altre la carta che regge la lettura
    // (`TarotSpread.cuore`). Le ragioni della stesa a tre carte restano le
    // sue parole; le altre stese dicono la loro.
    final presente = spread.cuore;
    if (spread.cards.length == 1) {
      return CartaChiave(
        drawn: presente,
        perche: 'È la carta sola della stesa: tutta la lettura passa da lei.',
      );
    }
    final aTre = spread.eATreCarte;
    final d = LaDomandaLetta.di(domandaScritta);
    final approdo = spread.approdo;
    final chiedeLEsito = d.vaga ||
        d.distacco ||
        d.timore ||
        d.sensibile != null ||
        switch (d.forma) {
          FormaDellaDomanda.siNo ||
          FormaDellaDomanda.quando ||
          FormaDellaDomanda.scelta =>
            true,
          _ => false,
        };
    if (approdo != null &&
        d.forma != FormaDellaDomanda.nessuna &&
        chiedeLEsito) {
      return CartaChiave(
        drawn: approdo,
        perche: aTre
            ? 'È la carta del Futuro: la tua domanda chiede dove va la '
                'questione: risponde lei.'
            : 'È la carta dell\'esito: la tua domanda chiede dove va la '
                'questione: risponde lei.',
      );
    }
    if (presente.card.arcana == TarotArcana.maggiore) {
      return CartaChiave(
        drawn: presente,
        perche: aTre
            ? 'È la carta del momento che vivi: un Arcano Maggiore nel '
                'Presente parla più forte di ogni altra cosa.'
            : 'È la carta che regge la stesa: un Arcano Maggiore che '
                'parla più forte di ogni altra cosa.',
      );
    }
    final maggiori = spread.cards
        .where((c) =>
            c.card.arcana == TarotArcana.maggiore &&
            switch (VoceDellaStesa.ruoloDi(c.position)) {
              RuoloDellaPosizione.ora || RuoloDellaPosizione.esito => true,
              _ => false,
            })
        .toList();
    if (maggiori.isEmpty) {
      return CartaChiave(
        drawn: presente,
        perche: aTre
            ? 'È la carta del momento che vivi, il centro della stesa.'
            : 'È la carta che regge la stesa, il suo centro.',
      );
    }
    maggiori.sort(
        (a, b) => (b.card.majorNumber ?? 0).compareTo(a.card.majorNumber ?? 0));
    final scelta = maggiori.first;
    return CartaChiave(
      drawn: scelta,
      perche: aTre
          ? 'È l\'Arcano Maggiore più alto della stesa: pesa più del '
              'Minore che occupa il Presente.'
          : 'È l\'Arcano Maggiore più alto della stesa: pesa più del '
              'Minore che la regge.',
    );
  }

  /// Le domande di chiusura, dal pool del corpus.
  static const List<String> domande = [
    'Cosa [sei disposto|sei disposta|puoi] lasciare andare per fare spazio a '
        'questo?',
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
    return LaMarcaDelGenere.risolvi(domande[hash % domande.length]);
  }
}

/// Una posizione letta dentro l'argomento scelto.
class PosizioneLetta {
  const PosizioneLetta({
    required this.drawn,
    required this.apertura,
    required this.testo,
    this.responso,
  });

  final DrawnCard drawn;

  /// La riga che introduce la posizione dentro l'argomento.
  final String apertura;

  /// Il testo della carta nella sua posizione: il paragrafo del suo
  /// responso ([responso]), scheletro della posizione e registro del gruppo.
  /// La carta aperta a tutta scena ne costruisce una col significato del
  /// verso (`stesa_tre_carte_screen.dart`, `_apriLaCarta`).
  final String testo;

  /// **IL RESPONSO BREVE DELLA CARTA**, ordine GA voce GA.05: il titolo della
  /// carta in quel posto, il paragrafo e il riquadro "Cosa fare adesso",
  /// tutto dal corpus (`LeCarteNellaPosizione.responsoDi`). Nullo solo nella
  /// carta aperta a tutta scena, che porta il significato del verso.
  final ResponsoInterpretato? responso;

  static PosizioneLetta of(
      DrawnCard drawn, TarotTopic topic, TarotSpread spread,
      {int uscita = 0, LaDomandaLetta? domanda, int posto = 0, int base = 0}) {
    // **LAPIDE: "testo: drawn.meaning".** Fino all'ordine EQ voce 04 qui
    // c'era il significato del verso, uguale nel passato, nel presente e
    // nel futuro e per qualunque domanda. Dall'ordine FI, aggiunta A3: lo
    // scheletro e dopo di lui il registro del gruppo dell'argomento.
    // **LAPIDE: "testoDelModello ??"**, dall'ordine EQ voce 04 all'ordine
    // GA: quando il modello rispondeva, il testo della carta era il suo.
    // Dall'ordine GA ("Carte dal corpus") la carta viene SEMPRE dal corpus,
    // in ogni stesa e in ogni piano.
    // **DAL TERZO GIRO DELL'ORDINE GA VOCE GA.06 la carta singola si legge
    // sulla domanda**: il gruppo viene dalla domanda, e su salute, legge e
    // denaro il "Cosa fare" non da' nessun gesto (`LeSingoleSullaDomanda`).
    final responso = domanda == null
        ? LeCarteNellaPosizione.responsoDi(drawn, topic.group, uscita: uscita)
        : LeSingoleSullaDomanda.di(drawn, domanda, topic,
            uscita: uscita, posto: posto, base: base);
    return PosizioneLetta(
      drawn: drawn,
      // **L'APERTURA VARIA, ordine DF voce 02.** Era la lente dell'argomento,
      // identica in tutte e tre le posizioni di tutte le letture: quindici
      // parole regalate a ogni confronto. Il posto nella stesa e non la
      // posizione, ordine FK aggiunta 2 voce A8: i due `lato` della croce
      // sono due posti.
      apertura: VoceDellaStesa.aperturaDellaPosizione(
          spread, spread.cards.indexOf(drawn)),
      testo: responso.risposta,
      responso: responso,
    );
  }
}
