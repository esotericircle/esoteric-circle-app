/// **I QUATTRO VIAGGI E IL RICONOSCIMENTO.** Ordine DC voce 04,
/// 10 settembre 2026. Riscritto per intero dall'ordine FZ voce 01,
/// 17 ottobre 2026: la storia qui sotto e' quella vera oggi, non un riassunto
/// delle tappe superate.
///
/// **LA FONTE, ed e' il motivo per cui ci vogliono quattro volte.** Michael
/// Harner, *The Way of the Shaman*, 1980, e' esplicito: la chiave per
/// riconoscere il proprio animale di potere e' che **si mostri almeno quattro
/// volte**, non per forza di fila, da angolazioni diverse, in aspetti
/// diversi, o come animali diversi della stessa specie.
///
/// **TRE TAPPE, E LA TERZA NON E' UN COMPROMESSO CON LE PRIME DUE: E' LA
/// LETTURA GIUSTA DELLA STESSA FONTE.**
///
/// **Tappa 1, ordine DC.** L'animale nasceva da due meta': *"il cielo
/// restringe"* tre candidati dalla data di nascita, *"le scelte decidono"*
/// con l'ombra seguita a ogni discesa. Il risultato era **una seconda
/// porta**: il Passaporto mostrava il Lupo, il Viaggio consegnava l'Aquila,
/// due animali guida per la stessa persona.
///
/// **Tappa 2, ordine DG, 11 settembre 2026.** Si chiude la seconda porta:
/// resta solo `GuideAnimalDerivation.forSign`, il segno decide per sempre, e
/// il Viaggio non fa che mostrare **sempre lo stesso animale**, a pezzi
/// crescenti. Qui la lettura di Harner si piega: "si mostra quattro volte"
/// diventa "lo stesso animale, che non puo' essere altro che uno, si rivela
/// in quattro gradi". Funziona, ma non e' piu' una scelta della persona: e'
/// un destino scritto alla nascita che il Viaggio si limita a scoprire a
/// rate.
///
/// **Tappa 3, ordine FZ, 17 ottobre 2026: LA SCELTA TORNA, E STAVOLTA NON
/// APRE UNA SECONDA PORTA.** Il fondatore, davanti alla domanda se l'animale
/// fosse "gia' assegnato" dal cielo, ha scelto esplicitamente la via in cui
/// si rivela **nel viaggio**: a ogni discesa tre ombre, sagome scure senza
/// nome, e la persona ne segue una a intuito. Quando la stessa ombra e' stata
/// seguita **quattro volte, non per forza di fila**, quella e' il suo
/// animale, fisso per sempre. **Non e' il ritorno alla tappa 1**: li' le tre
/// ombre nascevano in parte dal cielo, e la porta del segno restava aperta in
/// parallelo nel Passaporto; qui il cielo non entra per niente nella scelta
/// delle ombre (vedi `AnimaleDiPotere.treOmbreProposte`, che guarda solo
/// quali ombre la persona ha gia' seguito), e la porta e' una sola:
/// `AnimaleDiPotere.riconosciutoDa`. `GuideAnimalDerivation.forSign` resta
/// nel codice solo per la migrazione una tantum di chi aveva gia' concluso
/// col vecchio sistema, non per decidere l'animale di nessuno.
///
/// **E QUESTO E' HARNER ALLA LETTERA, non un compromesso.** La chiave del
/// riconoscimento e' che l'animale **torni a mostrarsi almeno quattro volte**:
/// con tre ombre possibili, "tornare a mostrarsi" significa di nuovo quello
/// che Harner intendeva, cioe' che la stessa presenza si ripresenti, non che
/// si accumulino quattro incontri a caso.
abstract final class IQuattroViaggi {
  /// **QUANTE DISCESE SERVONO PER RICONOSCERLO.** Quattro, e viene da Harner.
  static const int quanteDiscese = 4;

  /// **I QUATTRO GRADI IN CUI L'ANIMALE SI MOSTRA.**
  ///
  /// Non sono decorazione: sono il modo in cui la tradizione descrive il
  /// riconoscimento, e ognuno lascia qualcosa fuori.
  static const List<String> comeSiMostra = [
    'Un\'ombra che passa. Fuori resta un segno, un\'impronta nel fango.',
    'Di profilo, che si allontana.',
    'Ti guarda senza fuggire.',
    'Viene in piena luce.',
  ];

  /// Cosa si vede alla discesa numero [quale], contata da zero.
  static String comeSiMostraAlla(int quale) =>
      comeSiMostra[quale.clamp(0, comeSiMostra.length - 1)];

  /// **SE A QUESTA DISCESA IL CERCHIO PUO' DIRE IL NOME.**
  ///
  /// Solo alla quarta, e solo allora il Passaporto si accende.
  static bool siPuoNominare(int discesePrima) =>
      discesePrima + 1 >= quanteDiscese;

  /// **I TRE CANDIDATI CHE IL CIELO PROPONE**, dalla data di nascita.
  ///
  /// Il primo e' quello della tabella del cielo, che esisteva gia'. Gli altri
  /// due vengono dalla stessa data per una via stabile: **la stessa data da'
  /// sempre le stesse tre ombre**, altrimenti chi riapre l'app troverebbe un
  /// cammino diverso e le quattro scelte non vorrebbero dire niente.
  /// **IL NOME, QUANDO SI PUO' DIRE.**
  ///
  /// [discese] quante ne sono state compiute, [animale] il nome che viene
  /// dalla nascita. **Nulla finche' le discese non sono quattro**: il nome non
  /// si dice prima, ed e' il punto di tutta questa classe.
  ///
  /// **Qui prima c'era `seguitoDaLeQuattroScelte`**, che contava quale ombra
  /// era stata seguita piu' volte e proclamava quella. Era la seconda porta
  /// dell'animale guida, ed e' la ragione per cui il fondatore ha visto il
  /// Lupo nel Passaporto e l'Aquila alla fine del Viaggio. Vedi la nota in
  /// testa al file.
  static String? nomeDopoLeQuattroDiscese(int discese, String animale) =>
      discese >= quanteDiscese ? animale : null;

  /// **PERCHE' NON SI PUO' FARE TUTTO IN UNA SERA**, detto a chi legge.
  ///
  /// L'ordine chiede che *"il tooltip dichiari che l'attesa viene dal metodo e
  /// non da noi, citando la fonte"*. **Un'attesa senza ragione e' una
  /// trattenuta; un'attesa con la sua fonte e' un metodo.**
  static const String percheSiAspetta =
      'I viaggi cadono in quattro giorni diversi perché il riconoscimento '
      'chiede che l\'animale si mostri almeno quattro volte, in aspetti '
      'diversi. Non è una regola nostra: è il metodo descritto da Michael '
      'Harner in The Way of the Shaman, 1980.';

  /// La riga che dice a che punto si è, senza numeri da videogioco.
  static String aChePunto(int discese) {
    final restano = quanteDiscese - discese;
    if (restano <= 0) return 'Lo hai riconosciuto.';
    // **IN PAROLE E MAI IN NUMERI**, ordine DI voce 08: *"si e' mostrato due
    // volte, ne mancano due"*. Qui c'era *"Si e' mostrato 2 volte su 4"*, che
    // e' un punteggio scritto in lettere a meta'.
    final mancano =
        restano == 1 ? 'ne manca una' : 'ne mancano ${inLettere(restano)}';
    if (discese == 0) return 'Non si è ancora mostrato, $mancano.';
    return 'Si è mostrato ${_volte(discese)}, $mancano.';
  }

  /// **I NUMERI DEL CAMMINO IN LETTERE.** Il cammino ha quattro passi; le
  /// parole arrivano a dieci perche' il Passaporto conta anche le discese
  /// dopo il riconoscimento, e un conteggio che passa il suo massimo non deve
  /// tornare alle cifre. Al femminile, perche' si contano le volte.
  static String inLettere(int n) =>
      const {
        1: 'una',
        2: 'due',
        3: 'tre',
        4: 'quattro',
        5: 'cinque',
        6: 'sei',
        7: 'sette',
        8: 'otto',
        9: 'nove',
        10: 'dieci',
      }[n] ??
      'molte';

  static String _volte(int n) => n == 1 ? 'una volta' : '${inLettere(n)} volte';

  /// **LA FRASE DEL CONTEGGIO, e vive in un posto solo.**
  ///
  /// Difetto visto sul telefono 767f596c il 10 settembre 2026, sulla scena
  /// del ritorno dopo la prima discesa: **"Si è mostrato 1 volte su 4."**
  ///
  /// La stessa frase esisteva in due posti. Quella del Passaporto, in
  /// `LAnnuncioDellAnimale.sottoLaSagoma`, il singolare ce l'aveva, e un
  /// commento diceva perfino che la prima stesura sbagliava proprio li'.
  /// Questa non ce l'aveva. **Riparare una copia e lasciare l'altra e' la
  /// stessa cosa che non riparare niente**, e a schermo e' arrivata la copia
  /// rotta.
  ///
  /// Adesso la frase e' una, e tutte e due le porte passano di qui.
  ///
  /// **E DALL'ORDINE DI VOCE 08 E' IN PAROLE**, come la riga della soglia:
  /// *"Si e' mostrato 2 volte su 4"* era un punteggio.
  static String quanteVolteSiEMostrato(int discese) =>
      'Si è mostrato ${_volte(discese)} su ${inLettere(quanteDiscese)}.';
}
