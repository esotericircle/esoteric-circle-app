/// LE SEDICI CORNICI DEL PRESAGIO. Allegato B all'ordine S, materiale
/// dell'Architetto, consegnato il 13 agosto 2026.
///
/// **Cosa e' una cornice.** Non e' il presagio: e' cio' che sta attorno alla
/// frase della runa. Il montaggio, dall'allegato:
///
///     APERTURA della cornice
///     +  la frase della runa uscita, dal corpus, che non si tocca
///     +  CHIUSURA della cornice
///     +  la riga "da dove viene", che nomina la runa e il verso
///
/// L'apertura e' la parte 1 dell'anatomia, la risposta: nomina l'area della
/// domanda con le parole della persona e prepara il posto in cui la frase della
/// runa si innesta. La chiusura e' la parte 2, cosa puoi fare. La terza parte la
/// compone il motore del presagio dal corpus della runa.
///
/// **QUESTE SEDICI NON SI TOCCANO.** Verbatim vuol dire verbatim: nessuna
/// riformulazione, nessun accorciamento, nessun sinonimo. Se una cornice non e'
/// nell'allegato, non esiste. L'unica cosa che questo file fa ai testi
/// dell'allegato e' scriverli con gli ACCENTI VERI invece della convenzione
/// ASCII dei documenti (`e'` diventa `è`), perche' a schermo si legge questo.
///
/// **L'ACCOSTAMENTO SI FA PER TESTO ESATTO DELLA DOMANDA**, non per posizione
/// nell'elenco: se domani l'ordine delle domande cambia, le cornici restano
/// attaccate a quella giusta.
///
/// **PERCHE' NON SONO 576.** La cornice porta la DOMANDA, non la runa: la runa
/// continua a portare la sua frase di corpus, sempre la stessa. Sedici cornici
/// per ventiquattro rune in due versi non fanno un corpus da scrivere, fanno un
/// innesto.
///
/// **IL RIPIEGO NON SI DICHIARA MAI COME RIPIEGO.** Quando il modello risponde il
/// presagio e' suo; quando non risponde e' cornice piu' frase della runa, e la
/// persona non deve poter capire quale dei due sta leggendo. Per questo la
/// cornice non e' un testo di serie B: e' scritta per stare a video.
///
/// **IL CASO SENZA DOMANDA NON USA NESSUNA DI QUESTE SEDICI.** L'allegato lo
/// vieta in chiaro: userne una direbbe alla persona che ha chiesto una cosa che
/// non ha chiesto. Vale la voce S.15, il responso parla alla giornata, e per lei
/// c'e' la DICIASSETTESIMA, [CorniciDelPresagio.dellaGiornata], arrivata
/// nell'allegato aggiornato del 13 agosto 2026. Il testo provvisorio che teneva
/// il posto nel motore del presagio non esiste piu'.
///
/// **LA VIRGOLA PRIMA DELLA E NON E' IN DEROGA, e non lo e' mai stata.** Avevo
/// chiesto una deroga per undici testi su trentadue; Mauro l'ha negata con la
/// ragione giusta: in queste cornici quella virgola e' sempre stilistica e mai
/// portante, quindi il costo di toglierla e' zero e si evita una lista di
/// eccezioni che nessuno mantiene. Una regola con un'eccezione dichiarata resta
/// una regola; con un elenco di eccezioni diventa un elenco. Togliere la virgola
/// e' l'UNICO intervento sui testi oltre agli accenti, ed e' un intervento che
/// l'allegato ordina, non una riformulazione.
library;

import 'domande_del_cerchio.dart';

/// Una cornice: l'apertura e la chiusura attorno alla frase della runa.
class CorniceDelPresagio {
  const CorniceDelPresagio({
    required this.domanda,
    required this.apertura,
    required this.chiusura,
  });

  /// Il TESTO ESATTO della domanda a cui questa cornice appartiene. E' la chiave
  /// dell'accostamento: non l'indice, non la famiglia.
  final String domanda;

  /// Parte 1, la risposta: nomina l'area della domanda e prepara il posto in cui
  /// la frase della runa si innesta.
  final String apertura;

  /// Parte 2, cosa puoi fare: concreta, compibile, legata all'area della domanda.
  final String chiusura;
}

/// L'elenco delle sedici, nell'ordine dell'allegato.
class CorniciDelPresagio {
  const CorniciDelPresagio._();

  /// LE OTTO GENERICHE.
  static const List<CorniceDelPresagio> generiche = [
    CorniceDelPresagio(
      domanda: 'Cosa devo sapere sul mio momento?',
      apertura: 'Il momento che stai attraversando non chiede di essere capito '
          'tutto insieme. Chiede una cosa sola e le pietre indicano quale.',
      chiusura: 'Oggi non decidere niente di grande. Guarda cosa del tuo '
          'momento si ripete e prendine nota da qualche parte: le cose che si '
          'ripetono sono quelle che stanno chiedendo.',
    ),
    CorniceDelPresagio(
      domanda: 'In amore, dove sto andando?',
      apertura: 'In amore non stai fermo, nemmeno quando ti sembra. Una '
          'direzione c’è già e le pietre dicono da che parte punta.',
      chiusura: 'Nei prossimi giorni fai una cosa sola in quella direzione, '
          'piccola e detta a voce. In amore quello che non viene nominato resta '
          'un’intenzione.',
    ),
    CorniceDelPresagio(
      domanda: 'Nel lavoro, quale passo fare?',
      apertura:
          'Nel lavoro il passo giusto quasi mai è il più grande. È quello '
          'che si può fare domani mattina e le pietre lo indicano.',
      chiusura: 'Scegli un passo solo e dagli un’ora precisa. Un passo '
          'senza un’ora non è un passo, è un proposito.',
    ),
    CorniceDelPresagio(
      domanda: 'Una scelta mi blocca: cosa la scioglie?',
      apertura:
          'Una scelta che blocca raramente è difficile davvero: di solito '
          'manca un dato, oppure manca il permesso di sbagliare. Le pietre '
          'dicono quale dei due ti manca.',
      chiusura: 'Scrivi la scelta in una riga sola, con le due strade accanto. '
          'Ciò che non entra in una riga non è ancora una scelta, è un '
          'groviglio.',
    ),
    CorniceDelPresagio(
      domanda: 'Cosa mi sfugge di questa situazione?',
      apertura: 'In questa situazione c’è qualcosa che vedi ogni giorno e '
          'che non registri più. Le pietre lo rimettono in mezzo.',
      chiusura: 'Chiedi a una persona che c’era com’è andata secondo '
          'lei. Quello che ti sfugge, di solito, lo tiene qualcun altro.',
    ),
    CorniceDelPresagio(
      domanda: 'Cosa conviene lasciare andare adesso?',
      apertura:
          'Lasciare andare non è perdere. Adesso qualcosa ti sta costando '
          'più di quanto ti rende e le pietre lo nominano.',
      chiusura: 'Scegline una sola e lasciala per sette giorni. Se dopo sette '
          'giorni non ti manca, era quella.',
    ),
    CorniceDelPresagio(
      domanda: 'Su cosa vale la pena insistere?',
      apertura: 'Insistere non è testardaggine quando la cosa risponde, anche '
          'piano e anche male. Le pietre dicono che cosa sta rispondendo.',
      chiusura:
          'Dai a quella cosa lo stesso tempo per tre giorni di fila, alla '
          'stessa ora. L’insistenza si misura in ripetizioni, non in '
          'sforzo.',
    ),
    // **RISCRITTA DALL’ARCHITETTO il 13 agosto 2026**, e a chiederlo e’ stata la
    // prova (b): la prima stesura non conteneva nessuna parola piena della sua
    // domanda, quindi era l’unica delle sedici a violare il vincolo 2
    // dell’allegato. La versione nuova nomina "guardando", e la deroga che teneva
    // in piedi la prova non serve piu’.
    CorniceDelPresagio(
      domanda: 'Cosa non sto guardando di me?',
      apertura: 'Quello che non stai guardando di te non è la parte peggiore: '
          'è quella che non torna comoda nel racconto che fai agli altri. Le '
          'pietre la mettono in mezzo.',
      chiusura: 'Oggi di’ a voce alta, anche solo a te stesso, la cosa di te '
          'che stai evitando di guardare. Una volta sola basta.',
    ),
  ];

  /// LE OTTO PERSONALI. Le quattro il cui dato non e' ancora agganciato (Luna,
  /// Ascendente, animale guida, archetipo) hanno gia' la loro cornice: quando il
  /// dato arriva, la domanda si mostra e la cornice e' pronta.
  static const List<CorniceDelPresagio> personali = [
    CorniceDelPresagio(
      domanda: 'Il mio Sole: dove mi chiede coraggio?',
      apertura: 'Il tuo Sole non chiede coraggio dove sei già bravo. Lo chiede '
          'dove ti esponi e le pietre indicano il punto.',
      chiusura: 'Fai oggi, in piccolo, la cosa che ti espone. Il coraggio si '
          'allena in scala ridotta, non si aspetta in scala grande.',
    ),
    CorniceDelPresagio(
      domanda: 'La mia Luna: cosa chiede adesso?',
      apertura: 'La tua Luna chiede quasi sempre la stessa cosa e quasi sempre '
          'a bassa voce. Adesso le pietre la dicono forte.',
      chiusura: 'Concedile la cosa più piccola che chiede, oggi stesso. Una '
          'Luna ascoltata smette di insistere.',
    ),
    CorniceDelPresagio(
      domanda: 'Il mio Ascendente: cosa mostro e cosa nascondo?',
      apertura: 'Il tuo Ascendente è la porta: chi arriva vede quella e crede '
          'che sia la casa. Le pietre dicono cosa resta dietro.',
      chiusura: 'Con una persona sola, oggi, mostra mezzo passo in più di '
          'quanto mostri di solito. Mezzo, non uno.',
    ),
    CorniceDelPresagio(
      domanda: 'La runa di ieri sera: cosa continua oggi?',
      apertura: 'Ieri sera hai chiuso il giorno con un segno e quella cosa non '
          'si è fermata alla notte. Le pietre di adesso dicono dove è arrivata.',
      chiusura: 'Riprendi oggi ciò che ieri sera avevi lasciato a metà, anche '
          'solo per dieci minuti. Continuare vale più che ricominciare.',
    ),
    CorniceDelPresagio(
      domanda: 'La parola di stamattina: dove la ritrovo?',
      apertura: 'La parola di stamattina non era un ornamento: era un filo. Le '
          'pietre dicono dove passa adesso.',
      chiusura: 'Prima di sera trova un momento della giornata in cui quella '
          'parola è già successa e riconoscilo. Non serve cercarne un altro.',
    ),
    CorniceDelPresagio(
      domanda: 'Il mio segno in questo periodo: cosa cambia?',
      apertura: 'Nel tuo segno questo periodo non porta un colpo di scena: '
          'sposta un peso da una parte all’altra. Le pietre dicono da dove '
          'a dove.',
      chiusura:
          'Guarda cosa hai smesso di fare senza deciderlo. Il cambiamento '
          'si vede nelle abitudini prima che nei pensieri.',
    ),
    CorniceDelPresagio(
      domanda: 'Il mio animale guida: cosa mi dice ora?',
      apertura: 'Il tuo animale guida non parla: fa. Ti mostra un modo di '
          'stare e le pietre dicono in quale punto ti serve adesso.',
      chiusura: 'Oggi affronta una cosa nel suo modo invece che nel tuo. Una '
          'volta sola e guarda cosa cambia.',
    ),
    CorniceDelPresagio(
      domanda: 'Il mio archetipo: quale passo mi somiglia?',
      apertura: 'Il tuo archetipo non è un vestito, è una direzione. Le pietre '
          'dicono quale passo è davvero tuo e quale stai imitando.',
      chiusura: 'Fra le due cose che stai valutando, scegli quella che faresti '
          'anche se nessuno lo sapesse mai.',
    ),
  ];

  /// LA DICIASSETTESIMA, per chi non scegli nessuna domanda. Allegato B
  /// aggiornato del 13 agosto 2026.
  ///
  /// **Non e’ una delle sedici e non lo diventa.** Usare la cornice di una domanda
  /// per chi non ne ha scelta nessuna direbbe alla persona che ha chiesto qualcosa
  /// che non ha chiesto. Vale la voce S.15: il responso parla alla giornata.
  ///
  /// **La prova (b) non si applica a lei**, perche’ non esiste una domanda con cui
  /// confrontare le parole, e l’allegato pretende che sia esclusa PER NOME dentro
  /// la prova, non con un’eccezione silenziosa nella condizione.
  ///
  /// **Questa cornice non chiude: apre.** Chi getta senza domanda esce con una
  /// domanda per il giorno dopo, ed e’ il ritorno che la voce cerca.
  static const CorniceDelPresagio dellaGiornata = CorniceDelPresagio(
    domanda: '',
    apertura:
        'Non hai chiesto niente e va bene cos\u00ec: certi giorni la domanda '
        'non \u00e8 ancora una domanda. Allora le pietre non rispondono, guardano '
        'la tua giornata.',
    chiusura:
        'Prima di sera guarda se qualcosa di oggi assomiglia a questo. Se '
        'assomiglia, domani la domanda ce l\u2019hai gi\u00e0.',
  );

  /// Tutte e sedici.
  static List<CorniceDelPresagio> get tutte => [...generiche, ...personali];

  /// LA CORNICE DI UNA DOMANDA, per testo esatto.
  ///
  /// Torna nulla per una domanda che la persona ha scritto con parole sue, ed e'
  /// giusto: per quella non esiste una cornice, e il presagio lo compone il
  /// modello. Il ripiego, in quel caso, parla alla giornata.
  static CorniceDelPresagio? perDomanda(String domanda) {
    final cercata = domanda.trim();
    // **SENZA DOMANDA VALE LA DICIASSETTESIMA**, non una delle sedici.
    if (cercata.isEmpty) return dellaGiornata;
    for (final c in tutte) {
      if (c.domanda == cercata) return c;
    }
    // Una domanda scritta con parole della persona non ha cornice: il presagio lo
    // compone il modello, e in ripiego si parla alla giornata.
    return null;
  }

  /// Le domande della gettata che restano senza cornice. Vuoto, e la prova
  /// `le_sedici_cornici_test` cade se non lo e'.
  static List<String> domandeSenzaCornice() {
    final conCornice = tutte.map((c) => c.domanda).toSet();
    return [
      for (final d in [
        ...DomandeDelCerchio.generichePerLaGettata,
        ...DomandeDelCerchio.personaliPerLaGettata,
      ])
        if (!conCornice.contains(d.testo)) d.testo,
    ];
  }

  /// Le cornici che restano senza domanda. Anche questo vuoto: una cornice
  /// appesa a una domanda che non esiste piu' e' una deroga silenziosa.
  static List<String> corniciSenzaDomanda() {
    final domande = {
      for (final d in [
        ...DomandeDelCerchio.generichePerLaGettata,
        ...DomandeDelCerchio.personaliPerLaGettata,
      ])
        d.testo,
    };
    return [
      for (final c in tutte)
        if (!domande.contains(c.domanda)) c.domanda,
    ];
  }
}
