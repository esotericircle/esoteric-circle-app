import 'tarot_spread.dart';

/// **IL TONO DI UNA CARTA USCITA, letto dal suo significato.** Ordine GA voce
/// GA.06, 21 ottobre 2026.
///
/// **DA DOVE NASCE.** Il lettore cieco dei Tarocchi (`docs/collaudo/GA/
/// lettori_ciechi/esiti/esito_tre_domande_tarocchi.md`) ha trovato la prima
/// frase delle stese di casa scritta su quattro "nature" che venivano solo
/// dall'arcano e dal verso (`NaturaDellaCarta`, ordine DF voce 04.2): un
/// Minore dritto era sempre un *"favore"*. Cosi' il Nove di Spade, l'angoscia
/// della notte, dava *"una situazione che gira a tuo favore"*, il Tre di
/// Spade *"la risposta e' buona"*, il Dieci di Spade *"un favore concreto e
/// vicino"*. Il verso e l'arcano non dicono se una carta apre o chiude: lo
/// dice il suo significato.
///
/// **TRE TONI, e li decide il significato documentato del verso** (il corpus
/// `docs/corpus/tarocchi.md`, cioe' i testi di `TarotDeck.cards`):
/// [favorevole] quando la carta apre, sostiene o libera; [condizionato]
/// quando apre a una condizione che la carta stessa nomina (un'attesa, una
/// pausa, un pezzo che manca); [sfavorevole] quando la carta parla di dolore,
/// blocco, perdita o inganno.
enum TonoDellaCarta { favorevole, condizionato, sfavorevole }

/// **CIO' CHE UNA CARTA PORTA DENTRO LA RISPOSTA**, per carta e verso. Ordine
/// GA voce GA.06: *"Ogni affermazione poggia sul simbolo uscito e sul suo
/// significato documentato, dritto o rovesciato"*.
///
/// - [tono]: se la carta apre, apre a una condizione o chiude (vedi
///   [TonoDellaCarta]).
/// - [tema]: il significato in due a cinque parole, con l'articolo, per
///   nominare la carta accanto ad altre e per il titolo. **Non e' la
///   sintesi del corpus**, che si legge gia' sotto la carta (ordine DF voce
///   04.3: *"i significati scritti due volte nella stessa schermata"*).
/// - LAPIDE: `dice` e `via`, il perche' e il gesto della carta in una
///   riga, che la prima cura dell'ordine GA voce GA.06 (commit 9b2d2d29)
///   cuciva nella risposta (*"si', perche' Re di Coppe indica che serve
///   calma emotiva"*, *"X aggiunge un gesto: festeggia ciò che hai
///   costruito"* sotto un conflitto col capo). Il lettore cieco indipendente
///   li ha bocciati; i testi per ruolo e il gesto della carta adesso sono
///   SCRITTI, in `la_carta_nella_risposta_scritta.dart`.
/// - [distacco]: la carta parla di una fine, di una partenza o di una
///   liberazione; davanti a una domanda di distacco (*"Devo chiudere
///   l'amicizia?"*) dice si'.
///
/// **LE REGOLE DEI TESTI**, sorvegliate da `la_carta_nella_risposta_
/// test.dart`: nessuna figura del lessico di `FigureDellaStesa` (la stessa
/// immagine in due pezzi dello stesso responso e' il difetto dell'ordine DS
/// voce 09), nessun futuro, nessuna cifra, nessuna parola che dia un genere
/// a chi legge, mai la virgola prima di "e".
class LaCartaNellaRisposta {
  const LaCartaNellaRisposta(this.tono, this.tema,
      {this.distacco = false, this.legame = false});

  final TonoDellaCarta tono;
  final String tema;
  final bool distacco;

  /// La carta parla di un legame che ha valore (l'intesa, la casa, la
  /// festa condivisa, la pace): davanti a una domanda di distacco dice di
  /// non chiudere ancora.
  final bool legame;

  /// La chiave di una carta uscita: nome e verso, `dritta` o `capovolta`
  /// come nel corpus delle posizioni.
  static String chiaveDi(DrawnCard d) =>
      '${d.card.name}|${d.reversed ? 'capovolta' : 'dritta'}';

  /// Cio' che la carta [d] porta nella risposta. Non manca mai: la guardia
  /// pretende tutte le centocinquantasei carte-verso.
  static LaCartaNellaRisposta di(DrawnCard d) => tavola[chiaveDi(d)]!;

  /// **LE CARTE CHE POSSONO DARE UN SI' O UN NO.** Ordine GA voce GA.06, terzo
  /// giro: il lettore cieco indipendente ha trovato un *"si', ma con una
  /// riserva"* dal Dieci di Bastoni rovesciato per una promozione, un *"per
  /// ora la risposta e' si'"* dal Re di Coppe per un incontro, un *"le carte
  /// consigliano di no"* dal Re di Spade rovesciato contro tre carte
  /// favorevoli. Un tono non e' un verdetto: una carta che parla di un
  /// carattere, di un'attesa, di una tenuta o di uno stato d'animo non dice
  /// se un evento avviene. Qui stanno solo le carte il cui significato
  /// documentato e' un esito (una riuscita, un compimento, una perdita, un
  /// crollo), con il tono univoco: per tutte le altre il responso dice che
  /// cosa le carte mostrano e non un si' o un no. PADRE: ordine GA voce
  /// GA.06, commit 9b2d2d29 (il tono diventava verdetto per ogni carta).
  static const Set<String> carteDaVerdetto = {
    // Si': l'esito e' una riuscita o un avvio.
    'Il Carro|dritta',
    'La Ruota della Fortuna|dritta',
    'La Stella|dritta',
    'Il Sole|dritta',
    'Il Mondo|dritta',
    'Asso di Bastoni|dritta',
    'Tre di Bastoni|dritta',
    'Sei di Bastoni|dritta',
    'Otto di Bastoni|dritta',
    'Asso di Coppe|dritta',
    'Due di Coppe|dritta',
    'Nove di Coppe|dritta',
    'Dieci di Coppe|dritta',
    'Asso di Denari|dritta',
    'Tre di Denari|dritta',
    'Nove di Denari|dritta',
    'Dieci di Denari|dritta',
    'Quattro di Bastoni|dritta',
    'Tre di Coppe|dritta',
    'Asso di Spade|dritta',
    'Otto di Spade|capovolta',
    'Il Diavolo|capovolta',
    // No: l'esito e' una perdita, un crollo, una fine.
    'La Torre|dritta',
    'Cinque di Coppe|dritta',
    'Tre di Spade|dritta',
    'Cinque di Spade|dritta',
    'Dieci di Spade|dritta',
    'Cinque di Denari|dritta',
    'Dieci di Coppe|capovolta',
    'Due di Coppe|capovolta',
    'Sette di Denari|capovolta',
  };

  /// Se la carta [d] puo' sostenere un si' o un no (vedi [carteDaVerdetto]).
  static bool daVerdetto(DrawnCard d) => carteDaVerdetto.contains(chiaveDi(d));

  /// **LE CENTOCINQUANTASEI CARTE-VERSO**, scritte da Code il 21 ottobre
  /// 2026 leggendo il significato di ciascuna in `tarot_card.dart`.
  static const Map<String, LaCartaNellaRisposta> tavola = {
    // --- GLI ARCANI MAGGIORI ---
    'Il Matto|dritta':
        LaCartaNellaRisposta(_f, 'un inizio fatto con fiducia', distacco: true),
    'Il Matto|capovolta':
        LaCartaNellaRisposta(_s, 'uno slancio senza direzione'),
    'Il Mago|dritta': LaCartaNellaRisposta(_f, 'la capacità di fare'),
    'Il Mago|capovolta': LaCartaNellaRisposta(_s, 'un talento lasciato fermo'),
    'La Papessa|dritta':
        LaCartaNellaRisposta(_c, 'una risposta che matura piano'),
    'La Papessa|capovolta':
        LaCartaNellaRisposta(_s, 'l\'intuito messo da parte'),
    'L\'Imperatrice|dritta':
        LaCartaNellaRisposta(_f, 'una cosa viva che cresce'),
    'L\'Imperatrice|capovolta':
        LaCartaNellaRisposta(_s, 'una crescita bloccata'),
    'L\'Imperatore|dritta': LaCartaNellaRisposta(_f, 'l\'ordine che protegge'),
    'L\'Imperatore|capovolta':
        LaCartaNellaRisposta(_s, 'un controllo che soffoca'),
    'Il Papa|dritta': LaCartaNellaRisposta(_f, 'il consiglio di chi sa'),
    'Il Papa|capovolta': LaCartaNellaRisposta(_c, 'una regola da rivedere'),
    'Gli Amanti|dritta': LaCartaNellaRisposta(_f, 'una scelta di cuore'),
    'Gli Amanti|capovolta':
        LaCartaNellaRisposta(_c, 'un accordo interiore che manca'),
    'Il Carro|dritta': LaCartaNellaRisposta(_f, 'la volontà che avanza'),
    'Il Carro|capovolta': LaCartaNellaRisposta(_s, 'una corsa che sbanda'),
    'La Giustizia|dritta':
        LaCartaNellaRisposta(_c, 'il conto onesto dei fatti'),
    'La Giustizia|capovolta':
        LaCartaNellaRisposta(_s, 'un conto rimasto aperto'),
    'L\'Eremita|dritta': LaCartaNellaRisposta(_c, 'un ritiro che chiarisce'),
    'L\'Eremita|capovolta':
        LaCartaNellaRisposta(_s, 'una solitudine che isola'),
    'La Ruota della Fortuna|dritta':
        LaCartaNellaRisposta(_f, 'una svolta che arriva'),
    'La Ruota della Fortuna|capovolta':
        LaCartaNellaRisposta(_c, 'un ciclo in sosta'),
    'La Forza|dritta': LaCartaNellaRisposta(_f, 'la calma che regge'),
    'La Forza|capovolta': LaCartaNellaRisposta(_s, 'una tenuta che vacilla'),
    'L\'Appeso|dritta': LaCartaNellaRisposta(_c, 'un\'attesa che insegna'),
    'L\'Appeso|capovolta':
        LaCartaNellaRisposta(_s, 'un\'attesa diventata stallo'),
    'La Morte|dritta':
        LaCartaNellaRisposta(_c, 'una fine che trasforma', distacco: true),
    'La Morte|capovolta': LaCartaNellaRisposta(_s, 'un cambiamento trattenuto'),
    'La Temperanza|dritta':
        LaCartaNellaRisposta(_f, 'la pazienza che accorda', legame: true),
    'La Temperanza|capovolta':
        LaCartaNellaRisposta(_s, 'un equilibrio perduto'),
    'Il Diavolo|dritta': LaCartaNellaRisposta(_s, 'un legame che trattiene'),
    'Il Diavolo|capovolta':
        LaCartaNellaRisposta(_f, 'una catena che si spezza', distacco: true),
    'La Torre|dritta':
        LaCartaNellaRisposta(_s, 'un crollo improvviso', distacco: true),
    'La Torre|capovolta': LaCartaNellaRisposta(_c, 'una scossa rimandata'),
    'La Stella|dritta': LaCartaNellaRisposta(_f, 'la fiducia ritrovata'),
    'La Stella|capovolta': LaCartaNellaRisposta(_c, 'una fiducia stanca'),
    'La Luna|dritta': LaCartaNellaRisposta(_c, 'una situazione non chiara'),
    'La Luna|capovolta':
        LaCartaNellaRisposta(_f, 'una confusione che si chiarisce'),
    'Il Sole|dritta': LaCartaNellaRisposta(_f, 'una riuscita piena'),
    'Il Sole|capovolta': LaCartaNellaRisposta(_c, 'una gioia trattenuta'),
    'Il Giudizio|dritta': LaCartaNellaRisposta(_f, 'una chiamata a rinascere'),
    'Il Giudizio|capovolta': LaCartaNellaRisposta(_s, 'un bilancio rimandato'),
    'Il Mondo|dritta': LaCartaNellaRisposta(_f, 'un compimento pieno'),
    'Il Mondo|capovolta': LaCartaNellaRisposta(_c, 'un pezzo che manca'),
    // --- BASTONI ---
    'Asso di Bastoni|dritta': LaCartaNellaRisposta(_f, 'un impulso nuovo'),
    'Asso di Bastoni|capovolta':
        LaCartaNellaRisposta(_s, 'una partenza che slitta'),
    'Due di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'un progetto che si allarga'),
    'Due di Bastoni|capovolta':
        LaCartaNellaRisposta(_c, 'una direzione ancora confusa'),
    'Tre di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'un risultato già in arrivo'),
    'Tre di Bastoni|capovolta':
        LaCartaNellaRisposta(_c, 'un ritorno diverso dall\'attesa'),
    'Quattro di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'una stabilità da festeggiare', legame: true),
    'Quattro di Bastoni|capovolta':
        LaCartaNellaRisposta(_c, 'una festa rimandata'),
    'Cinque di Bastoni|dritta': LaCartaNellaRisposta(_c, 'un confronto acceso'),
    'Cinque di Bastoni|capovolta':
        LaCartaNellaRisposta(_s, 'un attrito che stanca'),
    'Sei di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'un riconoscimento meritato'),
    'Sei di Bastoni|capovolta': LaCartaNellaRisposta(_c, 'un merito che tarda'),
    'Sette di Bastoni|dritta':
        LaCartaNellaRisposta(_c, 'una posizione da tenere'),
    'Sette di Bastoni|capovolta': LaCartaNellaRisposta(_s, 'una difesa stanca'),
    'Otto di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'un\'accelerazione improvvisa'),
    'Otto di Bastoni|capovolta':
        LaCartaNellaRisposta(_c, 'una fretta mal riposta'),
    'Nove di Bastoni|dritta':
        LaCartaNellaRisposta(_c, 'la tenacia dell\'ultimo tratto'),
    'Nove di Bastoni|capovolta':
        LaCartaNellaRisposta(_s, 'una diffidenza di troppo'),
    'Dieci di Bastoni|dritta':
        LaCartaNellaRisposta(_s, 'un carico troppo grande'),
    'Dieci di Bastoni|capovolta':
        LaCartaNellaRisposta(_c, 'un carico da posare'),
    'Fante di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'un\'idea giovane da provare'),
    'Fante di Bastoni|capovolta':
        LaCartaNellaRisposta(_s, 'un entusiasmo che si spegne'),
    'Cavaliere di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'il coraggio di partire', distacco: true),
    'Cavaliere di Bastoni|capovolta':
        LaCartaNellaRisposta(_s, 'un\'impazienza che brucia'),
    'Regina di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'un calore che attira'),
    'Regina di Bastoni|capovolta':
        LaCartaNellaRisposta(_s, 'una gelosia che divide'),
    'Re di Bastoni|dritta':
        LaCartaNellaRisposta(_f, 'una guida che dà l\'esempio'),
    'Re di Bastoni|capovolta':
        LaCartaNellaRisposta(_s, 'un\'autorità che non ascolta'),
    // --- COPPE ---
    'Asso di Coppe|dritta':
        LaCartaNellaRisposta(_f, 'un\'emozione nuova', legame: true),
    'Asso di Coppe|capovolta':
        LaCartaNellaRisposta(_s, 'un sentimento trattenuto'),
    'Due di Coppe|dritta':
        LaCartaNellaRisposta(_f, 'un\'intesa a due', legame: true),
    'Due di Coppe|capovolta': LaCartaNellaRisposta(_s, 'un\'armonia incrinata'),
    'Tre di Coppe|dritta':
        LaCartaNellaRisposta(_f, 'una gioia condivisa', legame: true),
    'Tre di Coppe|capovolta':
        LaCartaNellaRisposta(_c, 'un gruppo da curare meglio'),
    'Quattro di Coppe|dritta':
        LaCartaNellaRisposta(_c, 'un\'offerta non vista'),
    'Quattro di Coppe|capovolta':
        LaCartaNellaRisposta(_f, 'un interesse che si risveglia'),
    'Cinque di Coppe|dritta': LaCartaNellaRisposta(_s, 'una perdita che pesa'),
    'Cinque di Coppe|capovolta':
        LaCartaNellaRisposta(_f, 'una ripresa dopo il dolore'),
    'Sei di Coppe|dritta':
        LaCartaNellaRisposta(_f, 'un affetto che torna', legame: true),
    'Sei di Coppe|capovolta':
        LaCartaNellaRisposta(_c, 'la nostalgia che trattiene'),
    'Sette di Coppe|dritta':
        LaCartaNellaRisposta(_c, 'un miraggio fra molte possibilità'),
    'Sette di Coppe|capovolta':
        LaCartaNellaRisposta(_f, 'un desiderio riconosciuto'),
    'Otto di Coppe|dritta':
        LaCartaNellaRisposta(_c, 'una partenza silenziosa', distacco: true),
    'Otto di Coppe|capovolta':
        LaCartaNellaRisposta(_c, 'un\'indecisione fra restare e andare'),
    'Nove di Coppe|dritta': LaCartaNellaRisposta(_f, 'una soddisfazione piena'),
    'Nove di Coppe|capovolta':
        LaCartaNellaRisposta(_c, 'una soddisfazione di facciata'),
    'Dieci di Coppe|dritta':
        LaCartaNellaRisposta(_f, 'l\'armonia negli affetti', legame: true),
    'Dieci di Coppe|capovolta':
        LaCartaNellaRisposta(_s, 'tensioni negli affetti'),
    'Fante di Coppe|dritta':
        LaCartaNellaRisposta(_f, 'un\'emozione sincera che affiora'),
    'Fante di Coppe|capovolta':
        LaCartaNellaRisposta(_s, 'una sensibilità ferita'),
    'Cavaliere di Coppe|dritta':
        LaCartaNellaRisposta(_f, 'una proposta gentile'),
    'Cavaliere di Coppe|capovolta':
        LaCartaNellaRisposta(_s, 'una promessa vaga'),
    'Regina di Coppe|dritta':
        LaCartaNellaRisposta(_f, 'l\'empatia che capisce'),
    'Regina di Coppe|capovolta':
        LaCartaNellaRisposta(_s, 'un\'emozione che sommerge'),
    'Re di Coppe|dritta': LaCartaNellaRisposta(_f, 'una calma che governa'),
    'Re di Coppe|capovolta': LaCartaNellaRisposta(_s, 'un umore instabile'),
    // --- DENARI ---
    'Asso di Denari|dritta': LaCartaNellaRisposta(_f, 'un\'occasione concreta'),
    'Asso di Denari|capovolta':
        LaCartaNellaRisposta(_c, 'un\'occasione che rischia di sfumare'),
    'Due di Denari|dritta':
        LaCartaNellaRisposta(_f, 'un equilibrio flessibile'),
    'Due di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'un ritmo perso negli impegni'),
    'Tre di Denari|dritta':
        LaCartaNellaRisposta(_f, 'una collaborazione che funziona'),
    'Tre di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'una collaborazione confusa'),
    'Quattro di Denari|dritta':
        LaCartaNellaRisposta(_c, 'la prudenza che conserva'),
    'Quattro di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'una presa troppo stretta'),
    'Cinque di Denari|dritta':
        LaCartaNellaRisposta(_s, 'una mancanza da attraversare'),
    'Cinque di Denari|capovolta':
        LaCartaNellaRisposta(_f, 'un sostegno che torna'),
    'Sei di Denari|dritta':
        LaCartaNellaRisposta(_f, 'uno scambio equo', legame: true),
    'Sei di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'uno scambio sbilanciato'),
    'Sette di Denari|dritta':
        LaCartaNellaRisposta(_c, 'un raccolto che chiede pazienza'),
    'Sette di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'uno sforzo mal ripagato'),
    'Otto di Denari|dritta': LaCartaNellaRisposta(_f, 'il mestiere che cresce'),
    'Otto di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'un lavoro senza senso'),
    'Nove di Denari|dritta': LaCartaNellaRisposta(_f, 'un raccolto meritato'),
    'Nove di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'un\'autonomia che vacilla'),
    'Dieci di Denari|dritta':
        LaCartaNellaRisposta(_f, 'una stabilità che dura', legame: true),
    'Dieci di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'una contesa in famiglia'),
    'Fante di Denari|dritta':
        LaCartaNellaRisposta(_f, 'un impegno da studiare'),
    'Fante di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'un impegno lasciato a metà'),
    'Cavaliere di Denari|dritta':
        LaCartaNellaRisposta(_f, 'una costanza che arriva'),
    'Cavaliere di Denari|capovolta':
        LaCartaNellaRisposta(_s, 'una prudenza diventata immobilità'),
    'Regina di Denari|dritta': LaCartaNellaRisposta(_f, 'una cura concreta'),
    'Regina di Denari|capovolta':
        LaCartaNellaRisposta(_c, 'una cura che dimentica te'),
    'Re di Denari|dritta':
        LaCartaNellaRisposta(_f, 'una prosperità gestita con misura'),
    'Re di Denari|capovolta': LaCartaNellaRisposta(_s, 'una ricchezza ferma'),
    // --- SPADE ---
    'Asso di Spade|dritta': LaCartaNellaRisposta(_f, 'una chiarezza netta'),
    'Asso di Spade|capovolta': LaCartaNellaRisposta(_s, 'una mente annebbiata'),
    'Due di Spade|dritta': LaCartaNellaRisposta(_c, 'una decisione rimandata'),
    'Due di Spade|capovolta':
        LaCartaNellaRisposta(_f, 'una verità che riaffiora'),
    'Tre di Spade|dritta': LaCartaNellaRisposta(_s, 'un dolore che ferisce'),
    'Tre di Spade|capovolta':
        LaCartaNellaRisposta(_c, 'una ferita che guarisce'),
    'Quattro di Spade|dritta': LaCartaNellaRisposta(_c, 'una pausa necessaria'),
    'Quattro di Spade|capovolta':
        LaCartaNellaRisposta(_f, 'la ripartenza dopo la sosta'),
    'Cinque di Spade|dritta': LaCartaNellaRisposta(_s, 'una vittoria amara'),
    'Cinque di Spade|capovolta':
        LaCartaNellaRisposta(_f, 'la voglia di fare pace', legame: true),
    'Sei di Spade|dritta': LaCartaNellaRisposta(
        _f, 'una traversata verso acque calme',
        distacco: true),
    'Sei di Spade|capovolta': LaCartaNellaRisposta(_c, 'un distacco che costa'),
    'Sette di Spade|dritta': LaCartaNellaRisposta(_c, 'una prudenza astuta'),
    'Sette di Spade|capovolta':
        LaCartaNellaRisposta(_s, 'un inganno che affiora'),
    'Otto di Spade|dritta':
        LaCartaNellaRisposta(_s, 'una trappola fatta di pensieri'),
    'Otto di Spade|capovolta':
        LaCartaNellaRisposta(_f, 'una liberazione', distacco: true),
    'Nove di Spade|dritta': LaCartaNellaRisposta(_s, 'l\'ansia notturna'),
    'Nove di Spade|capovolta':
        LaCartaNellaRisposta(_c, 'una paura che allenta'),
    'Dieci di Spade|dritta':
        LaCartaNellaRisposta(_s, 'una fine dolorosa', distacco: true),
    'Dieci di Spade|capovolta':
        LaCartaNellaRisposta(_c, 'una ripartenza da zero'),
    'Fante di Spade|dritta': LaCartaNellaRisposta(_c, 'una vigilanza attenta'),
    'Fante di Spade|capovolta':
        LaCartaNellaRisposta(_s, 'una parola che ferisce'),
    'Cavaliere di Spade|dritta':
        LaCartaNellaRisposta(_c, 'una determinazione veloce'),
    'Cavaliere di Spade|capovolta':
        LaCartaNellaRisposta(_s, 'una fretta imprudente'),
    'Regina di Spade|dritta': LaCartaNellaRisposta(_f, 'una franchezza lucida'),
    'Regina di Spade|capovolta':
        LaCartaNellaRisposta(_s, 'una durezza difensiva'),
    'Re di Spade|dritta': LaCartaNellaRisposta(_f, 'un giudizio equo'),
    'Re di Spade|capovolta':
        LaCartaNellaRisposta(_s, 'una freddezza che ferisce'),
  };
}

const TonoDellaCarta _f = TonoDellaCarta.favorevole;
const TonoDellaCarta _c = TonoDellaCarta.condizionato;
const TonoDellaCarta _s = TonoDellaCarta.sfavorevole;
