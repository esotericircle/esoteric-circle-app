// GENERATO da tool/le_schede_del_cielo_profondo.py dal corpus
// docs/corpus/cielo_profondo.md. Non si modifica a mano: si cambia il
// corpus e si rilancia il generatore (ordine FH parte 10).

/// Una scheda del cielo profondo, nelle quattro parti del corpus.
class SchedaDelCieloProfondo {
  const SchedaDelCieloProfondo({
    required this.id,
    required this.titolo,
    required this.apertura,
    required this.fatto,
    required this.fattoUmano,
    required this.forma,
    required this.stagione,
    required this.plurale,
  });

  /// L'id dell'oggetto in kCieloProfondo.
  final String id;
  final String titolo, apertura, fatto, fattoUmano;

  /// La forma della riga pratica, che compone il motore (voce 10.4).
  final String forma;

  /// Il fatto della stagione, che segue la riga pratica.
  final String stagione;

  /// Il nome e' plurale: "sorgono", "alte".
  final bool plurale;
}

const List<SchedaDelCieloProfondo> kSchedeDelCieloProfondo = [
  SchedaDelCieloProfondo(
    id: 'm45',
    titolo: 'Le Pleiadi',
    apertura:
        'Sono il gruppo di stelle che quasi ogni popolo della Terra ha contato. Quasi sempre ne ha contate sette.',
    fatto:
        'Un ammasso di stelle giovani nel Toro, a circa quattrocentoquaranta anni luce. Sono più di mille, nate insieme da una stessa nube circa cento milioni di anni fa. Viaggiano ancora insieme. A occhio nudo se ne vedono sei o sette; chi ha la vista molto buona in un cielo scuro arriva a undici. La nebbia azzurra che le avvolge è polvere che riflette la loro luce.',
    fattoUmano:
        'Esiodo, nell\'ottavo secolo avanti Cristo, le usa come calendario: quando sorgono prima dell\'alba si miete, quando tramontano si ara. I Maori chiamano Matariki il loro ritorno e con quello aprono l\'anno nuovo. In Giappone sono Subaru, cioè l\'unione. Il libro di Giobbe le nomina. In Grecia sono sette sorelle, figlie di Atlante, delle quali una si nasconde: quasi tutte le tradizioni che le raccontano dicono che le sorelle sono sette ma che se ne vede una in meno.',
    forma: 'Direzione e altezza adesso, oppure l\'ora in cui sorgono.',
    stagione: 'In Italia si vedono bene da ottobre ad aprile.',
    plurale: true,
  ),
  SchedaDelCieloProfondo(
    id: 'm42',
    titolo: 'La Nebulosa di Orione',
    apertura:
        'È il posto più vicino a noi dove in questo momento stanno nascendo delle stelle.',
    fatto:
        'Una nube di gas a circa milletrecento anni luce, dentro la spada di Orione. A occhio nudo è una macchia sfocata; è polvere e idrogeno che continuano a condensarsi in stelle nuove, illuminati da quattro stelle giovanissime al centro, il Trapezio, che hanno meno di un milione di anni. Il Sole è nato così, quattro miliardi e mezzo di anni fa, in un posto come questo.',
    fattoUmano:
        'La figura che la contiene è una delle più antiche che l\'umanità abbia disegnato: le tre stelle della cintura compaiono riconosciute in Egitto, in Mesopotamia, in Cina e fra gli aborigeni australiani, ciascuno con un nome suo. Gli Egizi legavano Orione a Osiride, il dio che muore e torna. La nebulosa in sé, che a occhio nudo è solo una macchia, non ha una tradizione antica propria: la riconosce per primo Nicolas-Claude Fabri de Peiresc nel 1610, col cannocchiale.',
    forma: 'Direzione e altezza adesso, oppure l\'ora in cui sorge.',
    stagione: 'In Italia si vede bene da novembre a marzo.',
    plurale: false,
  ),
  SchedaDelCieloProfondo(
    id: 'm31',
    titolo: 'La Galassia di Andromeda',
    apertura:
        'È la cosa più lontana che un occhio umano possa vedere senza strumenti. La sua luce è partita quando sulla Terra non esisteva ancora nessuno capace di guardarla.',
    fatto:
        'Non è una stella e non è una nube della nostra Galassia: è un\'altra galassia, grande quanto la nostra e anzi un po\' di più, con mille miliardi di stelle. Sta a due milioni e mezzo di anni luce, quindi la luce che arriva stanotte è partita due milioni e mezzo di anni fa. A occhio nudo è un ovale pallido e sfocato. Si sta avvicinando a noi: fra quattro miliardi di anni le due galassie si fonderanno.',
    fattoUmano:
        'La descrive per primo l\'astronomo persiano Al-Sufi nel 964, che la chiama una piccola nube. Per secoli si è creduto che fosse una nebulosa dentro la nostra Galassia: che fosse un altro universo di stelle lo ha dimostrato Edwin Hubble nel 1925. Da quel giorno l\'universo conosciuto è diventato enormemente più grande. Porta il nome della principessa incatenata allo scoglio del mito greco, accanto a sua madre Cassiopea e a Perseo che la libera.',
    forma: 'Direzione e altezza adesso, oppure l\'ora in cui sorge.',
    stagione:
        'Dall\'Italia è visibile quasi tutto l\'anno, alta nel cielo d\'autunno.',
    plurale: false,
  ),
  SchedaDelCieloProfondo(
    id: 'm8',
    titolo: 'La Nebulosa Laguna',
    apertura: 'Guardandola guardi verso il centro della nostra Galassia.',
    fatto:
        'Una nube di idrogeno a circa quattromila anni luce, nel Sagittario, larga tre volte la Luna piena. Il canale scuro che la taglia in due e che le dà il nome, è polvere che si frappone fra noi e la luce. Dentro ci sono stelle appena nate. Sta nella direzione in cui, molto più lontano, si trova il nucleo della Via Lattea. È per questo che l\'intera zona attorno è la più fitta di stelle di tutto il cielo.',
    fattoUmano:
        'Il Sagittario che la contiene è l\'arciere, figura che la tradizione mesopotamica e poi quella greca pongono a guardia di quella parte di cielo. La nebulosa viene notata per la prima volta da Giovanni Battista Hodierna, in Sicilia, prima del 1654; Charles Messier la cataloga come ottava nel 1764.',
    forma: 'Direzione e altezza adesso, oppure l\'ora in cui sorge.',
    stagione: 'In Italia si vede bassa sull\'orizzonte sud, d\'estate.',
    plurale: false,
  ),
  SchedaDelCieloProfondo(
    id: 'h_chi',
    titolo: 'Il Doppio Ammasso del Perseo',
    apertura:
        'Sono due ammassi veri, vicini davvero, non una coincidenza prospettica.',
    fatto:
        'NGC 869 e NGC 884, a circa settemilacinquecento anni luce, separati da poche centinaia di anni luce l\'uno dall\'altro. Contengono insieme più di quattrocento stelle giganti, molte azzurre e molto giovani, alcune già diventate supergiganti rosse. A occhio nudo, da un cielo scuro, sono due macchie chiare nella Via Lattea fra Perseo e Cassiopea.',
    fattoUmano:
        'Li registra Ipparco di Nicea nel secondo secolo avanti Cristo, quindi sono fra i primi oggetti non stellari annotati nella storia. Stanno nella mano di Perseo, la figura che nel mito libera Andromeda, nonché una delle poche cose che nel cielo si vedono doppie e lo sono davvero.',
    forma: 'Direzione e altezza adesso, oppure l\'ora in cui sorge.',
    stagione:
        'Dall\'Italia sono circumpolari o quasi, quindi visibili quasi ogni notte dell\'anno.',
    plurale: false,
  ),
];
