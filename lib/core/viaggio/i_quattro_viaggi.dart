import '../rituals/animal_catalog.dart';

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
/// **COME NASCE L'ANIMALE, e le due meta' contano tutte e due.**
///
/// **Il cielo restringe**: la data di nascita porta a **tre candidati**, non a
/// uno. **Le scelte decidono**: in ogni discesa si intravedono tre ombre e se
/// ne segue una, e le quattro scelte convergono su uno.
///
/// Cosi' l'animale **nasce dal suo cielo ed e' insieme conquistato dalle sue
/// scelte**, che e' esattamente cio' che l'ordine chiede.
///
/// **COSA C'ERA PRIMA, e va dichiarato.** `GuideAnimalDerivation.forSign`
/// mappava **un segno solare a un animale**, biiettiva su dodici e dodici,
/// deterministica e fissa. Nessuna scelta, nessun viaggio: si apriva la
/// schermata e l'animale era gia' li'. Quella tabella **resta e non si butta**:
/// e' la prima delle tre ombre, cioe' il candidato del cielo.
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
  /// **LE SEI DISPOSIZIONI DI TRE OMBRE**, in ordine fisso.
  ///
  /// Servono a [treOmbre]: la terna resta quella, cambia dove si presenta.
  static const List<List<int>> _disposizioni = [
    [0, 1, 2],
    [2, 0, 1],
    [1, 2, 0],
    [0, 2, 1],
    [2, 1, 0],
    [1, 0, 2],
  ];

  static List<GuideAnimal> treOmbre(GuideAnimal dalCielo, {int discesa = 0}) {
    const tutti = AnimalCatalog.animals;
    final primo = tutti.indexWhere((a) => a.name == dalCielo.name);
    if (primo < 0 || tutti.length < quanteOmbre) return [dalCielo];
    // **Passi coprimi col numero degli animali**, cosi' le tre ombre non
    // cadono mai sullo stesso animale e non sono mai tre vicini di lista.
    final quanti = tutti.length;
    final terna = [
      tutti[primo],
      tutti[(primo + 5) % quanti],
      tutti[(primo + 7) % quanti],
    ];
    // **L'INSIEME NON CAMBIA, CAMBIA L'ORDINE.** Ordine DE voce 03, difetto
    // visto a video l'11 settembre 2026: quattro discese nello stesso giorno
    // mostravano la stessa terna nelle stesse tre posizioni, e la scena
    // sembrava una fotocopia della precedente.
    //
    // **La terna deve restare quella**, perche' e' il meccanismo: si segue
    // un'ombra quattro volte e vince la piu' seguita. Tre animali nuovi a ogni
    // discesa farebbero dell'animale finale un sorteggio. **L'ordine invece
    // puo' cambiare**, e chi scende di nuovo deve guardare le sagome per
    // ritrovare la sua, non ricordare la riga.
    final quale = _disposizioni[discesa.abs() % _disposizioni.length];
    return [for (final i in quale) terna[i]];
  }

  /// **L'ANIMALE CHE LE QUATTRO SCELTE HANNO SCELTO.**
  ///
  /// [scelte] sono i nomi seguiti a ogni discesa, in ordine.
  ///
  /// **Vince quello seguito piu' volte.** A parita', vince **l'ultimo
  /// seguito**: chi cambia idea durante il cammino sta dicendo qualcosa, e la
  /// scelta piu' recente e' quella che conosce le altre tre.
  ///
  /// Nulla finche' le discese non sono quattro: **il nome non si dice prima**,
  /// ed e' il punto di tutta questa voce.
  static String? seguitoDaLeQuattroScelte(List<String> scelte) {
    if (scelte.length < quanteDiscese) return null;
    final conto = <String, int>{};
    for (final s in scelte) {
      conto.update(s, (n) => n + 1, ifAbsent: () => 1);
    }
    var quante = 0;
    for (final v in conto.values) {
      if (v > quante) quante = v;
    }
    // Fra i piu' seguiti, l'ultimo in ordine di tempo.
    for (final s in scelte.reversed) {
      if (conto[s] == quante) return s;
    }
    return scelte.last;
  }

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
