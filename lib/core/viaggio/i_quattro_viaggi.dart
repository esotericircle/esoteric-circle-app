
/// **I QUATTRO VIAGGI E IL RICONOSCIMENTO.** Ordine DC voce 04,
/// 10 settembre 2026.
///
/// **LA FONTE, ed e' il motivo per cui i viaggi sono quattro.** Michael
/// Harner, *The Way of the Shaman*, 1980, e' esplicito: la chiave per
/// riconoscere il proprio animale di potere e' che **si mostri almeno quattro
/// volte**, da angolazioni diverse, in aspetti diversi, o come animali diversi
/// della stessa specie.
///
/// **Quindi il primo viaggio non consegna un animale.** Ne mostra uno,
/// parzialmente. E' la differenza fra un risultato e un rapporto, che e' cio'
/// che l'ordine DC vuole riparare: *"oggi l'Animale e' un risultato, e nella
/// tradizione e' un rapporto"*.
///
/// **L'ANIMALE NON SI ESTRAE QUI. QUI SI RIVELA.** Ordine DG,
/// 11 settembre 2026.
///
/// **Cosa c'era prima, e perche' era sbagliato.** L'ordine DC voce 04 aveva
/// fatto nascere l'animale da due meta': *"il cielo restringe"* con tre
/// candidati dalla data di nascita, *"le scelte decidono"* con l'ombra seguita
/// a ogni discesa. L'intenzione era buona e il risultato era **una seconda
/// porta**: il Passaporto mostrava il Lupo, il Viaggio consegnava l'Aquila, e
/// tutte e due dicevano di essere l'animale guida della stessa persona.
///
/// **Chi sopravvive lo dice il Master Briefing e non questo file.** Linee
/// Guida UX Trasversali, sezione 5, elenca fra i dati **identitari e fissi**,
/// deterministici e immutabili, *"carta natale, Angelo Custode, archetipo,
/// **Animale Guida**"*. Le arti a esito variabile stanno in un altro elenco, e
/// sono tarocchi, rune, I-Ching, pendolo, fondi di caffe'.
///
/// **Quindi la porta e' una sola: `GuideAnimalDerivation.forSign`.** Il
/// Viaggio non sceglie niente: mostra **sempre lo stesso animale**, quello di
/// quella persona, e cambia solo **quanto se ne vede**.
///
/// **E questo E' Harner, non un compromesso con lui.** La chiave del
/// riconoscimento e' che l'animale **torni a mostrarsi almeno quattro volte**:
/// e' il ritorno a riconoscerlo, non una selezione fra candidati. Quattro
/// animali diversi in quattro discese sono quattro incontri, non un
/// riconoscimento.
///
/// **Il fondatore lo aveva detto in una riga**: *"ogni viaggio e' un animale
/// diverso e non lo stesso che si rivela sempre di piu' ad ogni viaggio"*.
abstract final class IQuattroViaggi {
  /// **QUANTE DISCESE SERVONO PER RICONOSCERLO.** Quattro, e viene da Harner.
  static const int quanteDiscese = 4;

  /// **QUANTE OMBRE SI INTRAVEDONO IN OGNI DISCESA.** Tre.
  static const int quanteOmbre = 3;

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

  /// **QUANTI CONTORNI HA LA SAGOMA NEL PASSAPORTO.** Ordine DC voce 04:
  /// *"dopo ogni viaggio non completato, la sagoma nel Passaporto guadagna un
  /// contorno in piu': chi guarda vede che manca poco"*.
  static int contorniDellaSagoma(int discese) =>
      discese.clamp(0, quanteDiscese);

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
    if (discese == 0) return 'Non sei ancora sceso.';
    if (restano == 1) return 'Si è mostrato tre volte. Ne manca una.';
    return quanteVolteSiEMostrato(discese);
  }

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
  static String quanteVolteSiEMostrato(int discese) => discese == 1
      ? 'Si è mostrato una volta su $quanteDiscese.'
      : 'Si è mostrato $discese volte su $quanteDiscese.';
}
