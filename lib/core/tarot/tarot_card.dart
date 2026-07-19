import '../assets/family_image.dart';

/// Il seme di un Arcano Minore, con l'elemento tradizionale.
enum TarotSeme {
  bastoni('Bastoni', 'fuoco'),
  coppe('Coppe', 'acqua'),
  denari('Denari', 'terra'),
  spade('Spade', 'aria');

  const TarotSeme(this.italianName, this.elemento);
  final String italianName;
  final String elemento;
}

/// Il tipo di Arcano.
enum TarotArcana { maggiore, minore }

/// Una carta dei tarocchi, nella voce di Medora: nome, tipo, seme e numero se
/// Minore, il verso dritto e il verso rovesciato (sintesi piu' riga ciascuno) e
/// l'arte bundlata (famiglia `mazzo-tarocchi`).
class TarotCard {
  const TarotCard({
    required this.name,
    required this.arcana,
    this.seme,
    this.number,
    required this.uprightSummary,
    required this.upright,
    required this.reversedSummary,
    required this.reversed,
    required this.stem,
  });

  final String name;
  final TarotArcana arcana;

  /// Seme e numero, valorizzati solo per i Minori.
  final TarotSeme? seme;
  final int? number;

  final String uprightSummary;
  final String upright;
  final String reversedSummary;
  final String reversed;
  final String stem;

  String get thumbPath => FamilyImage.thumb(AssetFamily.tarocchi, stem);
  String get fullPath => FamilyImage.full(AssetFamily.tarocchi, stem);

  /// Il numero d'ordine di un Arcano Maggiore, da 0 a 21, letto dallo stem.
  /// Null per i Minori.
  int? get majorNumber {
    if (arcana != TarotArcana.maggiore) return null;
    final m = RegExp(r'^tar_rw_(\d{2})_').firstMatch(stem);
    return m == null ? null : int.parse(m.group(1)!);
  }

  /// Vero per le quattro carte di corte di ogni seme: Fante, Cavaliere, Regina,
  /// Re. Il loro grado per esteso non entra leggibile nella placca stretta in
  /// alto, quindi la' va il numero.
  bool get isCorte =>
      arcana == TarotArcana.minore && number != null && number! >= 11;

  /// Il numerale del cartiglio superiore: romano per i Maggiori, arabo per i
  /// Minori, corti comprese (Fante 11, Cavaliere 12, Regina 13, Re 14).
  ///
  /// Le corti portano il numero e non il grado scritto: la parola per esteso in
  /// quella placca stretta scendeva a una misura illeggibile. Il grado resta nel
  /// cartiglio inferiore e nel nome grande sotto la carta.
  String get numeral => arcana == TarotArcana.maggiore
      ? _romani[majorNumber ?? 0]
      : '${number ?? ''}';

  static const List<String> _romani = [
    '0', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', //
    'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX', 'XXI'
  ];
}

/// Il mazzo completo dei 78 Arcani, dal corpus `docs/corpus/tarocchi.md`, legati
/// all'arte Rider-Waite per nome (Maggiori) e per seme e numero (Minori).
class TarotDeck {
  const TarotDeck._();

  /// Stem del dorso del mazzo, per le carte coperte.
  static const String dorsoStem = 'tar_rw_dorso_medora_v1';
  static String get dorsoThumb =>
      FamilyImage.thumb(AssetFamily.tarocchi, dorsoStem);
  static String get dorsoFull =>
      FamilyImage.full(AssetFamily.tarocchi, dorsoStem);

  /// Le settantotto carte nei due versi, dal corpus `docs/corpus/tarocchi.md`.
  ///
  /// Testo ricco di due o tre frasi per verso, con la sintesi tenuta a
  /// parte. La legatura all'arte e' per NOME e non per numero, perche' i
  /// file d'arte seguono l'ordine Rider-Waite, dove La Forza e' l'VIII e
  /// La Giustizia l'XI, l'opposto della numerazione del corpus.
  static const List<TarotCard> cards = [
    TarotCard(
      name: 'Il Matto',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'Il salto nel vuoto.',
      upright:
          'Un nuovo inizio ti chiama e il cielo ti chiede di partire leggero, con fiducia e cuore aperto, anche senza vedere tutta la strada. Il Matto non è ingenuo, è libero e la sua leggerezza è una forma di coraggio. Fidati del primo passo, il resto si mostra cammin facendo.',
      reversedSummary: 'Il passo avventato.',
      reversed:
          'C\'è uno slancio senza direzione, oppure un timore che ti trattiene sull\'orlo proprio mentre vorresti spiccare il volo. Prima di partire fermati un istante e senti da dove nasce l\'impulso: è coraggio che ti spinge, o è fuga da qualcosa che non hai guardato? La strada resta aperta, ma questa volta scegli con gli occhi aperti.',
      stem: 'tar_rw_00_il-matto_v1',
    ),
    TarotCard(
      name: 'Il Mago',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'Il potere di creare.',
      upright:
          'Hai tra le mani tutti gli strumenti e la volontà per usarli e il momento chiede di manifestare. Ciò che finora era solo idea vuole diventare gesto concreto, parola detta, passo fatto. Non aspettare le condizioni perfette, il tuo potere è reale adesso.',
      reversedSummary: 'Il potere sprecato.',
      reversed:
          'Un talento resta chiuso nel cassetto, oppure le parole promettono più di quanto le mani mantengono. Non è mancanza di dono, è scollamento tra intenzione e azione. Riporta ciò che dici a ciò che fai e la magia torna vera.',
      stem: 'tar_rw_01_il-mago_v1',
    ),
    TarotCard(
      name: 'La Papessa',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'Il sapere del silenzio.',
      upright:
          'C\'è una conoscenza che non passa dalle parole, la senti prima di poterla spiegare. Un mistero si svela solo alla mente quieta, quindi fai spazio al silenzio e alla tua intuizione. Non tutto va deciso ora, certe risposte maturano nell\'attesa.',
      reversedSummary: 'L\'intuito messo a tacere.',
      reversed:
          'Stai coprendo con la ragione o col rumore una voce interiore che invece sa. Forse temi ciò che sentiresti se ti fermassi ad ascoltare. Torna al silenzio senza fretta, il segreto che cerchi aspetta solo di essere accolto.',
      stem: 'tar_rw_02_la-papessa_v1',
    ),
    TarotCard(
      name: 'L\'Imperatrice',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La forza che genera.',
      upright:
          'Abbondanza, creatività e cura fioriscono nelle tue mani e qualcosa di vivo prende forma, un progetto, un legame, un\'idea. Il tuo compito ora è nutrirlo con dolcezza, senza forzarne i tempi. La terra fertile non tira le piante per farle crescere, le lascia sbocciare.',
      reversedSummary: 'La cura dimenticata.',
      reversed:
          'La creatività sembra bloccata, oppure ti sei scordata di rivolgere a te stessa l\'attenzione che dai a tutto il resto. Prima di far fiorire fuori, torna a nutrire la tua radice. Rifiorisce dentro ciò che curi con gentilezza.',
      stem: 'tar_rw_03_l-imperatrice_v1',
    ),
    TarotCard(
      name: 'L\'Imperatore',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La struttura che protegge.',
      upright:
          'È tempo di ordine e di fondamenta solide, di dare forma e regola a ciò che costruisci. L\'Imperatore non soffoca, sostiene: qui la disciplina è la cornice dentro cui la tua vita cresce sicura. Prendi le tue responsabilità con fermezza e ciò che edifichi durerà.',
      reversedSummary: 'La regola che soffoca.',
      reversed:
          'O il controllo si è fatto troppo stretto e toglie il respiro, oppure mancano proprio le fondamenta e tutto vacilla. Cerca l\'ordine che protegge, non quello che imprigiona. Una struttura è buona quando ti tiene in piedi, non quando ti tiene fermo.',
      stem: 'tar_rw_04_l-imperatore_v1',
    ),
    TarotCard(
      name: 'Il Papa',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La guida antica.',
      upright:
          'Tradizione, insegnamento e senso condiviso ti sono vicini e vale la pena cercare un maestro, un consiglio, una sapienza più grande di te. C\'è forza nell\'appartenere a qualcosa che viene da lontano. Ma la guida vera non ti sostituisce, ti aiuta a diventare maestro di te stesso.',
      reversedSummary: 'La regola da rivedere.',
      reversed:
          'Un sapere ricevuto, una convenzione, un dover essere non ti appartiene più. Non è ribellione, è crescita: cerca il tuo senso anche fuori dal sentiero già tracciato. Ciò che è tuo davvero lo riconosci perché ti fa respirare.',
      stem: 'tar_rw_05_l-ierofante_v1',
    ),
    TarotCard(
      name: 'Gli Amanti',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La scelta del cuore.',
      upright:
          'C\'è amore e c\'è un bivio: una decisione che tocca i tuoi valori più veri, non solo il desiderio del momento. Il cielo ti chiede di scegliere con tutto te stesso, testa e cuore insieme. Quando l\'amore è allineato a ciò che sei, la strada si fa chiara.',
      reversedSummary: 'La scelta rimandata.',
      reversed:
          'Dubbio, disaccordo, valori che si contendono il campo: qualcosa dentro non è ancora sincero con sé stesso. Prima di decidere con l\'altro, mettiti d\'accordo con te. La scelta giusta pesa meno quando smetti di mentirti.',
      stem: 'tar_rw_06_gli-amanti_v1',
    ),
    TarotCard(
      name: 'Il Carro',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La volontà che vince.',
      upright:
          'Hai direzione, slancio e la forza per tenere insieme spinte contrarie: è il momento di prendere le redini e andare avanti. La vittoria qui non è fortuna, è padronanza. Tieni fermo lo sguardo sulla meta e le tue energie opposte lavoreranno per te.',
      reversedSummary: 'Le redini allentate.',
      reversed:
          'Forze che tirano in versi opposti ti fanno sbandare, o corri senza sapere bene dove. Fermati un attimo, ritrova il tuo centro, poi riprendi la guida. Non è debolezza rallentare per non perdere la strada.',
      stem: 'tar_rw_07_il-carro_v1',
    ),
    TarotCard(
      name: 'La Giustizia',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La bilancia della verità.',
      upright:
          'Equilibrio, causa ed effetto, responsabilità: raccogli con lucidità ciò che hai seminato, senza sconti e senza colpe inutili. È un tempo di verità e di scelte giuste. Agisci con onestà e la bilancia peserà a tuo favore.',
      reversedSummary: 'Il conto sospeso.',
      reversed:
          'C\'è una verità che eviti, oppure una responsabilità che continui a rimandare. Finché resta in ombra, pesa. Guardala in faccia con calma, l\'equilibrio torna nel momento in cui sei onesto con te stesso.',
      stem: 'tar_rw_11_la-giustizia_v1',
    ),
    TarotCard(
      name: 'L\'Eremita',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La luce interiore.',
      upright:
          'È tempo di ritiro e di ricerca, di rallentare e cercare dentro invece che fuori. La tua lanterna non illumina tutta la strada in una volta, ma un passo alla volta è abbastanza. Concediti il silenzio, le risposte più vere arrivano quando fai spazio.',
      reversedSummary: 'Il ritiro che isola.',
      reversed:
          'Una solitudine che doveva illuminare si è fatta peso e ti allontana invece di chiarirti. La tua lanterna serve anche a ritrovare la strada verso gli altri. Un conto è raccogliersi, un altro è nascondersi.',
      stem: 'tar_rw_09_l-eremita_v1',
    ),
    TarotCard(
      name: 'La Ruota della Fortuna',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'Il giro del destino.',
      upright:
          'I cicli girano e qualcosa cambia, spesso quando meno te lo aspetti. Accogli la svolta senza aggrapparti a com\'era, nulla resta fermo per sempre e questo vale anche quando sei in basso. Muoviti con la ruota, non contro.',
      reversedSummary: 'Il giro che resiste.',
      reversed:
          'Un ciclo sembra bloccato, oppure gira storto e ti pare di non avere presa. Anche la sosta è parte del movimento: raccogli le forze, la ruota riprende presto a girare. Ciò che ora frena, domani spinge.',
      stem: 'tar_rw_10_la-ruota-della-fortuna_v1',
    ),
    TarotCard(
      name: 'La Forza',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La forza gentile.',
      upright:
          'Il coraggio vero qui è dolce: domini l\'istinto con la mano ferma e il cuore mite, non con la violenza. La Forza non doma la belva con la lotta, la addomestica con la calma. Ciò che ti agita dentro si placa se lo tratti con fermezza tenera.',
      reversedSummary: 'Il dominio perso.',
      reversed:
          'Forse dubiti della tua tenuta, o forse sei diventata dura con te stessa. La vera forza non è la stretta, è la mano gentile. Torna a trattarti con mitezza e ritrovi il controllo che credevi perso.',
      stem: 'tar_rw_08_la-forza_v1',
    ),
    TarotCard(
      name: 'L\'Appeso',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'Il dono della sospensione.',
      upright:
          'C\'è un tempo in cui fermarsi e capovolgere lo sguardo vale più di ogni azione. Da un\'attesa che sembra vuota nasce una comprensione nuova. Lascia andare il bisogno di fare e vedrai la situazione da un\'angolazione che prima ti sfuggiva.',
      reversedSummary: 'La sospensione che pesa.',
      reversed:
          'L\'attesa ha smesso di insegnare e sa di stallo, o ti sei imposta un sacrificio che non serve a nessuno. Cambia lo sguardo, oppure scendi dall\'albero e torna ad agire. Non ogni rinuncia è nobile, alcune sono solo paura travestita.',
      stem: 'tar_rw_12_l-appeso_v1',
    ),
    TarotCard(
      name: 'La Morte',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La fine che libera.',
      upright:
          'Qualcosa si chiude perché qualcos\'altro possa nascere e non c\'è nulla da temere in questo. La Morte dei tarocchi non è fine, è trasformazione: lascia andare ciò che è giunto al suo termine. Dove qualcosa muore, la vita fa spazio al nuovo.',
      reversedSummary: 'La fine trattenuta.',
      reversed:
          'Resisti a un cambiamento che è già arrivato, ti aggrappi a ciò che sta finendo. Ma trattenere fa più male del lasciare, la vita vuole scorrere e tu con lei. Apri la mano e il dolore diventa passaggio.',
      stem: 'tar_rw_13_la-morte_v1',
    ),
    TarotCard(
      name: 'La Temperanza',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La misura che guarisce.',
      upright:
          'Armonia, pazienza e giusto dosaggio: è il tempo di unire gli opposti con calma e di ritrovare l\'equilibrio. La Temperanza mescola con arte ciò che sembrava inconciliabile. Vai piano, misura e ciò che era ferita torna intero.',
      reversedSummary: 'La misura perduta.',
      reversed:
          'Eccessi, fretta, o due parti di te che non si parlano più. Il rimedio è semplice ma chiede volontà: rallenta, ridosa, ritrova il ritmo che guarisce. L\'equilibrio non è un colpo di fortuna, è una pratica quotidiana.',
      stem: 'tar_rw_14_la-temperanza_v1',
    ),
    TarotCard(
      name: 'Il Diavolo',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'L\'ombra da guardare.',
      upright:
          'Catene, tentazioni, attaccamenti che ti legano più di quanto ammetti. Il primo passo per allentare la presa è riconoscerla, non c\'è vergogna nell\'ombra, solo verità da vedere. Ciò che nomini, smette di comandarti nel buio.',
      reversedSummary: 'La catena che si spezza.',
      reversed:
          'Ti accorgi di un legame che ti tratteneva e già questo cambia tutto. Vederlo è metà della libertà: adesso, con dolcezza, sciogli il nodo che hai finalmente riconosciuto. Ciò che ti teneva non era più forte di te, solo più nascosto.',
      stem: 'tar_rw_15_il-diavolo_v1',
    ),
    TarotCard(
      name: 'La Torre',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'Il crollo che rivela.',
      upright:
          'Cade all\'improvviso ciò che era costruito sul falso e sul momento fa male. Ma la Torre non abbatte il vero, solo l\'illusione: ciò che resta in piedi è ciò su cui puoi davvero contare. Da queste macerie nasce una base più onesta.',
      reversedSummary: 'Il crollo evitato.',
      reversed:
          'Rimandi una scossa che sarebbe necessaria, oppure ne stai uscendo a fatica. Meglio un vero che vacilla che un falso che regge in apparenza. Se qualcosa deve cadere, lasciarlo cadere ora ti risparmia un crollo peggiore domani.',
      stem: 'tar_rw_16_la-torre_v1',
    ),
    TarotCard(
      name: 'La Stella',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La speranza ritrovata.',
      upright:
          'Dopo la tempesta arriva una luce dolce e con lei fiducia, ispirazione, la promessa che guarirai. La Stella non urla, rassicura: sei sulla strada giusta anche se sei stanco. Lasciati guidare da questa quiete luminosa, il peggio è passato.',
      reversedSummary: 'La speranza offuscata.',
      reversed:
          'La fiducia è stanca, l\'ispirazione sembra lontana e fatichi a credere che le cose miglioreranno. Ma la luce non è spenta, solo velata da una nube passeggera. Concediti di sperare ancora, la Stella è lì anche quando non la vedi.',
      stem: 'tar_rw_17_le-stelle_v1',
    ),
    TarotCard(
      name: 'La Luna',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'Il velo dei sogni.',
      upright:
          'Non tutto è chiaro in questo momento: l\'inconscio parla, le paure notturne si affacciano, le cose non sono come sembrano alla prima occhiata. Procedi con intuito e prudenza, senza pretendere subito ogni certezza. Alcuni passaggi vanno attraversati al buio, fidandoti del passo.',
      reversedSummary: 'Il velo che si dirada.',
      reversed:
          'Le paure perdono forza, una confusione si sta chiarendo e ciò che al buio sembrava enorme si mostra più piccolo alla luce. Stai uscendo dalla nebbia. Guarda con occhi nuovi ciò che ti spaventava, aveva più ombra che sostanza.',
      stem: 'tar_rw_18_la-luna_v1',
    ),
    TarotCard(
      name: 'Il Sole',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La gioia piena.',
      upright:
          'Chiarezza, calore e successo: è un tempo luminoso in cui le cose fioriscono e il cuore ride senza doversi nascondere. Il Sole non lascia zone d\'ombra, illumina ciò che sei. Goditi questo momento e lascia che la tua luce scaldi anche chi ti sta vicino.',
      reversedSummary: 'La gioia velata.',
      reversed:
          'L\'entusiasmo è trattenuto, la luce c\'è ma fatichi a sentirla sulla pelle. Non è che il sole se ne sia andato, è che qualcosa lo copre. Lascia cadere quella nube, spesso è un pensiero vecchio e la gioia torna a scaldarti.',
      stem: 'tar_rw_19_il-sole_v1',
    ),
    TarotCard(
      name: 'Il Giudizio',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'La chiamata al risveglio.',
      upright:
          'È tempo di un bilancio e di una rinascita: una voce ti chiama a una vita più vera, più tua. Il Giudizio non condanna, risveglia. Ascolta quella chiamata e rispondi, anche se ti chiede di lasciare la persona che eri per quella che stai diventando.',
      reversedSummary: 'La chiamata inascoltata.',
      reversed:
          'Rimandi un bilancio che senti necessario, oppure ti giudichi con una durezza che non ti aiuta. La rinascita non nasce dalla condanna, ma dall\'ascolto e dal perdono. Sii con te stesso il giudice giusto, quello che comprende prima di sentenziare.',
      stem: 'tar_rw_20_il-giudizio_v1',
    ),
    TarotCard(
      name: 'Il Mondo',
      arcana: TarotArcana.maggiore,
      seme: null,
      number: null,
      uprightSummary: 'Il cerchio che si compie.',
      upright:
          'Pienezza, traguardo, integrazione: un ciclo si chiude in armonia e tu sei arrivato dove dovevi. È un momento di compimento, goditelo prima di aprire il prossimo cerchio. Ciò che hai attraversato ora è parte di te, intero.',
      reversedSummary: 'Il cerchio quasi chiuso.',
      reversed:
          'Il traguardo è a un passo, ma manca ancora un pezzo da integrare, un dettaglio da sciogliere. Non fermarti proprio adesso. La pienezza chiede l\'ultimo tratto e sarebbe un peccato lasciarla incompiuta così vicino alla fine.',
      stem: 'tar_rw_21_il-mondo_v1',
    ),
    TarotCard(
      name: 'Asso di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 1,
      uprightSummary: 'La scintilla che accende.',
      upright:
          'Un impulso nuovo, un\'ispirazione ardente ti attraversa ed è il momento giusto per iniziare. Afferra la fiamma finché è viva, non aspettare che il fuoco si raffreddi nei ripensamenti. Ogni grande cosa parte da una scintilla come questa.',
      reversedSummary: 'La scintilla che tarda.',
      reversed:
          'Lo slancio è bloccato, oppure una partenza continua a essere rimandata. Non è che il fuoco manchi, è che qualcosa lo soffoca, forse la paura di sbagliare. Ritrova il desiderio prima di accendere e la fiamma tornerà da sola.',
      stem: 'tar_rw_bastoni_01_v1',
    ),
    TarotCard(
      name: 'Due di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 2,
      uprightSummary: 'Lo sguardo lontano.',
      upright:
          'Un progetto prende forma e ti chiede di scegliere una direzione, di guardare oltre il confine di ciò che già conosci. Hai il mondo in mano, ora decidi la rotta. È il tempo di pianificare con ambizione, non di restare fermo dove sei.',
      reversedSummary: 'Il piano incerto.',
      reversed:
          'C\'è paura di osare, o una direzione ancora confusa che ti tiene sulla soglia. Prima di muoverti, chiarisci a te stesso cosa vuoi davvero. Un passo deciso vale più di dieci fatti nel dubbio.',
      stem: 'tar_rw_bastoni_02_v1',
    ),
    TarotCard(
      name: 'Tre di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 3,
      uprightSummary: 'Le navi in mare.',
      upright:
          'Hai seminato e messo in moto qualcosa e ora comincia l\'attesa dei frutti, l\'espansione avviata. Guarda arrivare ciò che hai lanciato, con fiducia. I risultati sono in viaggio verso di te, tienti pronto ad accoglierli.',
      reversedSummary: 'L\'attesa che pesa.',
      reversed:
          'Arrivano ritardi, o le aspettative non tornano come speravi. Puoi pazientare ancora un poco, oppure correggere la rotta con lucidità, senza scoraggiarti. Un ritardo non è un no, spesso è solo un tempo diverso.',
      stem: 'tar_rw_bastoni_03_v1',
    ),
    TarotCard(
      name: 'Quattro di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 4,
      uprightSummary: 'La festa della soglia.',
      upright:
          'Stabilità, celebrazione, un traguardo raggiunto che si condivide: è tempo di gioire di ciò che hai costruito. Le fondamenta reggono e questo va festeggiato. Concediti di riconoscere il bello che c\'è, senza correre già al prossimo.',
      reversedSummary: 'La festa sospesa.',
      reversed:
          'C\'è un\'armonia da ritrovare, o radici ancora un po\' incerte sotto la superficie. Prima di festeggiare, cura le fondamenta perché reggano davvero. La gioia piena arriva quando la base è solida.',
      stem: 'tar_rw_bastoni_04_v1',
    ),
    TarotCard(
      name: 'Cinque di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 5,
      uprightSummary: 'La sfida vivace.',
      upright:
          'Attriti, competizione, un confronto acceso di idee: l\'energia si scontra e ribolle. Usala per crescere e per misurarti, non per ferire o per vincere a ogni costo. Da una sfida ben giocata si esce più forti.',
      reversedSummary: 'Il conflitto che stanca.',
      reversed:
          'Ci sono tensioni inutili, oppure attriti che eviti lasciandoli covare. Scegli le battaglie che contano davvero e lascia cadere il resto. Non tutto merita la tua energia.',
      stem: 'tar_rw_bastoni_05_v1',
    ),
    TarotCard(
      name: 'Sei di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 6,
      uprightSummary: 'La vittoria che sfila.',
      upright:
          'Arriva un riconoscimento, un successo meritato che gli altri finalmente vedono. Accogli l\'onore con misura, senza montarti la testa né sminuirti. Hai lavorato per questo, goditelo.',
      reversedSummary: 'Il merito non visto.',
      reversed:
          'Un riconoscimento tarda ad arrivare, o un dubbio su di te ti fa sentire poco valido. Ma il tuo valore resta anche quando l\'applauso non c\'è. Non legare ciò che vali solo a chi te lo conferma.',
      stem: 'tar_rw_bastoni_06_v1',
    ),
    TarotCard(
      name: 'Sette di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 7,
      uprightSummary: 'La posizione difesa.',
      upright:
          'È tempo di tenere il punto, di avere coraggio sotto pressione e difendere ciò in cui credi. Sei in vantaggio, anche se ti senti assediato. Hai la forza per reggere, non cedere proprio adesso.',
      reversedSummary: 'La guardia stanca.',
      reversed:
          'Ti senti sopraffatto, o troppo sulla difensiva anche quando non serve. Scegli con lucidità dove vale la pena resistere e dove invece puoi lasciare. Non devi difendere ogni collina.',
      stem: 'tar_rw_bastoni_07_v1',
    ),
    TarotCard(
      name: 'Otto di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 8,
      uprightSummary: 'Le frecce nell\'aria.',
      upright:
          'Velocità, notizie, eventi che accelerano tutti insieme: le cose si muovono in fretta. Cavalca il ritmo invece di frenarlo, è un momento di movimento e di risposte rapide. Ciò che aspettavi sta arrivando.',
      reversedSummary: 'La corsa frenata.',
      reversed:
          'Ci sono ritardi, oppure una fretta mal riposta che ti fa inciampare. Rallenta quel tanto che basta per ritrovare l\'ordine. La velocità serve solo quando sai dove stai andando.',
      stem: 'tar_rw_bastoni_08_v1',
    ),
    TarotCard(
      name: 'Nove di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 9,
      uprightSummary: 'L\'ultima resistenza.',
      upright:
          'Sei stanco ma vicino al traguardo e la tenacia ora è tutto. Hai già fatto il più, non mollare proprio l\'ultimo tratto. Un\'ultima prova, poi potrai posare lo scudo.',
      reversedSummary: 'La difesa irrigidita.',
      reversed:
          'Una diffidenza di troppo, o una stanchezza che ti fa chiudere a riccio. Abbassa un poco lo scudo, non tutto ciò che arriva è una minaccia. Ti difendi anche da chi vorrebbe solo avvicinarsi.',
      stem: 'tar_rw_bastoni_09_v1',
    ),
    TarotCard(
      name: 'Dieci di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 10,
      uprightSummary: 'Il peso portato.',
      upright:
          'Hai molte responsabilità sulle spalle, un carico che ti curva. Chiediti con onestà cosa è davvero tuo da portare e cosa puoi posare. Non è forza tenere tutto, è saggezza scegliere cosa.',
      reversedSummary: 'Il carico da alleggerire.',
      reversed:
          'Porti un fardello che forse non ti appartiene, per abitudine o per senso del dovere. Lascia andare ciò che ti sei caricato senza necessità. Alleggerirti non è tradire nessuno, è respirare.',
      stem: 'tar_rw_bastoni_10_v1',
    ),
    TarotCard(
      name: 'Fante di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 11,
      uprightSummary: 'Il messaggero ardente.',
      upright:
          'Curiosità, entusiasmo fresco, un\'idea giovane che bussa alla porta. Seguila con slancio, è il tempo di esplorare e di provare. Le grandi avventure iniziano da una scintilla curiosa come questa.',
      reversedSummary: 'L\'entusiasmo disperso.',
      reversed:
          'Un\'impulsività che si accende e si spegne, uno slancio che svanisce prima di dare frutti. Dai forma all\'energia prima che si disperda. L\'entusiasmo diventa qualcosa solo se lo incanali.',
      stem: 'tar_rw_bastoni_11_v1',
    ),
    TarotCard(
      name: 'Cavaliere di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 12,
      uprightSummary: 'La corsa audace.',
      upright:
          'Passione, azione, avventura: parti con coraggio verso ciò che desideri. Tieni però un occhio alla meta, così l\'ardore non si perde per strada. È un tempo per osare, non per esitare.',
      reversedSummary: 'La foga incauta.',
      reversed:
          'Impazienza, o uno slancio senza rotta che rischia di bruciarti. Incanala l\'ardore invece di sprecarlo in mille direzioni. La stessa energia, con una meta, diventa forza.',
      stem: 'tar_rw_bastoni_12_v1',
    ),
    TarotCard(
      name: 'Regina di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 13,
      uprightSummary: 'Il carisma caldo.',
      upright:
          'Sicurezza, calore, magnetismo: brilli con generosità e la tua fiamma scalda chi ti sta intorno. Sii pienamente te stessa, è proprio questo che attrae. La tua luce non toglie spazio a nessuno.',
      reversedSummary: 'La fiamma insicura.',
      reversed:
          'Un dubbio su di te, o una gelosia che offusca la tua luce. Torna al tuo centro, la tua fiamma non ha rivali da temere. Quando ti riconosci, l\'insicurezza si spegne da sola.',
      stem: 'tar_rw_bastoni_13_v1',
    ),
    TarotCard(
      name: 'Re di Bastoni',
      arcana: TarotArcana.minore,
      seme: TarotSeme.bastoni,
      number: 14,
      uprightSummary: 'La visione che guida.',
      upright:
          'Guida matura, ispirazione, una volontà che apre strade con l\'esempio. La tua fiamma indica il cammino anche agli altri. È il momento di prendere in mano la direzione con generosità.',
      reversedSummary: 'Il comando impaziente.',
      reversed:
          'Un\'autorità rigida, o troppo impulsiva, che spinge senza ascoltare. Guida con l\'ascolto oltre che con la forza. Il vero capo accende gli altri, non li travolge.',
      stem: 'tar_rw_bastoni_14_v1',
    ),
    TarotCard(
      name: 'Asso di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 1,
      uprightSummary: 'Il cuore che trabocca.',
      upright:
          'Un amore nuovo, un\'emozione pura sgorga come una fonte: apri il cuore e lascia scorrere. È un tempo di apertura sentimentale, di grazia e di dolcezza. Accogli ciò che senti senza difenderti da esso.',
      reversedSummary: 'Il cuore trattenuto.',
      reversed:
          'Emozioni chiuse a chiave, o un amore rimandato per timore di soffrire. Concediti di sentire, l\'acqua vuole scorrere e ristagna se la trattieni. Aprirsi è un rischio, ma è anche l\'unica via alla gioia.',
      stem: 'tar_rw_coppe_01_v1',
    ),
    TarotCard(
      name: 'Due di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 2,
      uprightSummary: 'L\'incontro dei cuori.',
      upright:
          'Un\'unione, un patto d\'amore, un\'armonia a due che si sigilla. Coltiva questo legame con cura, perché ciò che nasce ora è prezioso. Quando due cuori si riconoscono, la loro forza si moltiplica.',
      reversedSummary: 'L\'armonia incrinata.',
      reversed:
          'Un malinteso, un equilibrio da ritrovare tra due persone che si vogliono bene. Parlatevi con il cuore aperto e il legame si ricuce. Spesso basta ascoltare davvero per sciogliere la distanza.',
      stem: 'tar_rw_coppe_02_v1',
    ),
    TarotCard(
      name: 'Tre di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 3,
      uprightSummary: 'Il brindisi degli amici.',
      upright:
          'Amicizia, festa, comunità: è il tempo di celebrare insieme. La gioia condivisa raddoppia, quindi circondati di chi ti vuole bene. C\'è qualcosa da festeggiare, non farlo da solo.',
      reversedSummary: 'La festa da riequilibrare.',
      reversed:
          'Forse un eccesso, o un cerchio di persone che va curato meglio. Torna alle amicizie vere, quelle che nutrono, senza disperderti. Meglio pochi legami sinceri che tanti di facciata.',
      stem: 'tar_rw_coppe_03_v1',
    ),
    TarotCard(
      name: 'Quattro di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 4,
      uprightSummary: 'L\'offerta non vista.',
      upright:
          'Apatia, noia, un dono che ti viene teso ma che non stai guardando. Alza lo sguardo, qualcosa di buono ti aspetta proprio accanto. A volte la fortuna bussa mentre fissi altrove.',
      reversedSummary: 'Il risveglio dell\'interesse.',
      reversed:
          'Esci dal torpore e torni a sentire, una nuova apertura ti chiama. Accoglila, il cuore si sta ridestando. Dopo la noia arriva sempre una curiosità nuova, seguila.',
      stem: 'tar_rw_coppe_04_v1',
    ),
    TarotCard(
      name: 'Cinque di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 5,
      uprightSummary: 'Le coppe versate.',
      upright:
          'Una perdita, un rimpianto, lo sguardo fisso su ciò che è andato. Ma due coppe restano ancora in piedi dietro di te: voltati e vedile. Il dolore è reale e non è tutto ciò che ti resta.',
      reversedSummary: 'Lo sguardo che si rialza.',
      reversed:
          'Arriva l\'accettazione, il perdono, la ripresa dopo il lutto. Il dolore lascia posto alla speranza, piano. Ti stai voltando verso ciò che c\'è ancora ed è un buon segno.',
      stem: 'tar_rw_coppe_05_v1',
    ),
    TarotCard(
      name: 'Sei di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 6,
      uprightSummary: 'Il dono dell\'infanzia.',
      upright:
          'Nostalgia dolce, ricordi cari, un affetto sincero che dal passato torna a scaldarti. Lascia che questa tenerezza ti nutra. C\'è innocenza e bontà in ciò che ricordi con amore.',
      reversedSummary: 'Il passato che trattiene.',
      reversed:
          'Il rischio è vivere di ricordi, restare aggrappato a un tempo che non c\'è più. Onora ciò che è stato, poi torna con dolcezza al presente. La vita ti aspetta adesso, non solo nella memoria.',
      stem: 'tar_rw_coppe_06_v1',
    ),
    TarotCard(
      name: 'Sette di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 7,
      uprightSummary: 'Le coppe dei sogni.',
      upright:
          'Fantasie, molte possibilità, illusioni che si affollano davanti a te. Sogna pure in grande, poi scegli con i piedi a terra. Non tutte le coppe contengono ciò che promettono.',
      reversedSummary: 'La nebbia che si dirada.',
      reversed:
          'Dopo la confusione arriva la chiarezza, metti a fuoco un desiderio vero tra i tanti. Ora sai quale strada vuoi. Scegliere una cosa è rinunciare alle altre ed è proprio questo che ti rende libero.',
      stem: 'tar_rw_coppe_07_v1',
    ),
    TarotCard(
      name: 'Otto di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 8,
      uprightSummary: 'La partenza silenziosa.',
      upright:
          'Lasci ciò che non ti nutre più per cercare un senso più alto e parti in silenzio. Il cuore sa già dove ti sta portando, anche se la mente non ha ancora tutte le risposte. A volte andarsene è l\'atto più onesto.',
      reversedSummary: 'Il piede sulla soglia.',
      reversed:
          'Un\'indecisione tra restare e andare ti tiene sulla porta. Ascoltati con sincerità e saprai se è davvero tempo di lasciare. Non c\'è fretta, ma non ingannarti nemmeno.',
      stem: 'tar_rw_coppe_08_v1',
    ),
    TarotCard(
      name: 'Nove di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 9,
      uprightSummary: 'Il desiderio appagato.',
      upright:
          'Soddisfazione, benessere, un augurio che si è avverato: goditi ciò che hai ottenuto. È la carta del cuore contento, riconosci la tua fortuna. Concediti di essere felice senza sentirti in colpa.',
      reversedSummary: 'L\'appagamento vuoto.',
      reversed:
          'Piaceri che non colmano davvero, una soddisfazione solo di facciata. Cerca la gioia vera, quella che tocca il profondo. Chiediti se ciò che desideri ti renderà pieno o solo distratto.',
      stem: 'tar_rw_coppe_09_v1',
    ),
    TarotCard(
      name: 'Dieci di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 10,
      uprightSummary: 'L\'arcobaleno della famiglia.',
      upright:
          'Armonia affettiva, pienezza condivisa, l\'amore attorno a te che diventa la tua ricchezza. È un tempo di gratitudine per i legami che hai. La felicità qui non è un traguardo solitario, è condivisa.',
      reversedSummary: 'L\'armonia da ricucire.',
      reversed:
          'Tensioni negli affetti, una distanza in famiglia o nella coppia. Torna al legame con dialogo e pazienza, la casa si ricompone. Le crepe negli affetti si riparano parlando, non tacendo.',
      stem: 'tar_rw_coppe_10_v1',
    ),
    TarotCard(
      name: 'Fante di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 11,
      uprightSummary: 'Il sognatore gentile.',
      upright:
          'Sensibilità, creatività, un messaggio d\'amore che affiora. Ascolta l\'emozione nuova che nasce, anche se è fragile. C\'è poesia in ciò che senti, dalle spazio.',
      reversedSummary: 'La sensibilità ferita.',
      reversed:
          'Un\'emotività fragile, o un cuore che si è chiuso per proteggersi. Custodisci la tua sensibilità senza murarla del tutto. Sentire molto è un dono, non un difetto da nascondere.',
      stem: 'tar_rw_coppe_11_v1',
    ),
    TarotCard(
      name: 'Cavaliere di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 12,
      uprightSummary: 'Il cuore in viaggio.',
      upright:
          'Romanticismo, una proposta, un invito che arriva con grazia. Segui il sentimento e offri il tuo cuore, è un tempo di aperture affettuose. Lasciati corteggiare dalla bellezza, o offrila tu.',
      reversedSummary: 'Il sentimento incostante.',
      reversed:
          'Promesse vaghe, o illusioni che non trovano radici. Verifica che alle parole seguano i gesti, tuoi o dell\'altro. Un sentimento vero si vede in ciò che dura, non solo in ciò che si dice.',
      stem: 'tar_rw_coppe_12_v1',
    ),
    TarotCard(
      name: 'Regina di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 13,
      uprightSummary: 'La cura profonda.',
      upright:
          'Empatia, intuito, tenerezza: accogli e comprendi con il cuore. La tua sensibilità è una forza, non una debolezza. Sai leggere gli altri in profondità, usa questo dono anche per te.',
      reversedSummary: 'L\'emozione che sommerge.',
      reversed:
          'Ti perdi negli altri, assorbi ogni loro stato d\'animo fino a smarrire il tuo. Riporta un poco di cura anche a te stessa. Puoi amare senza annegare.',
      stem: 'tar_rw_coppe_13_v1',
    ),
    TarotCard(
      name: 'Re di Coppe',
      arcana: TarotArcana.minore,
      seme: TarotSeme.coppe,
      number: 14,
      uprightSummary: 'La calma del cuore.',
      upright:
          'Equilibrio emotivo, saggezza affettiva, la capacità di guidare i sentimenti con serenità matura. Sei il porto sicuro, per te e per gli altri. La padronanza qui non è freddezza, è calma profonda.',
      reversedSummary: 'L\'onda trattenuta.',
      reversed:
          'Emozioni represse, o al contrario instabili, che fatichi a governare. Dai voce a ciò che senti senza temerlo. Il controllo vero non è soffocare l\'onda, è saperla cavalcare.',
      stem: 'tar_rw_coppe_14_v1',
    ),
    TarotCard(
      name: 'Asso di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 1,
      uprightSummary: 'Il seme d\'oro.',
      upright:
          'Un\'opportunità concreta, un inizio prospero: il terreno è fertile, pianta il seme. È il momento giusto per qualcosa di materiale e solido, un lavoro, un progetto, una base. Ciò che avvii ora ha buone radici.',
      reversedSummary: 'L\'occasione trascurata.',
      reversed:
          'Un\'apertura che rischi di perdere, o un rischio valutato male. Guarda meglio ciò che hai davanti prima che sfumi. Non tutte le occasioni tornano, questa merita attenzione.',
      stem: 'tar_rw_denari_01_v1',
    ),
    TarotCard(
      name: 'Due di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 2,
      uprightSummary: 'Il gioco d\'equilibrio.',
      upright:
          'Gestisci più cose insieme, ti adatti, tieni il ritmo tra impegni diversi. Fallo con leggerezza, come un giocoliere, senza irrigidirti. La flessibilità qui è la tua alleata.',
      reversedSummary: 'L\'equilibrio perso.',
      reversed:
          'Troppe cose insieme minacciano di farti cadere tutto. Scegli le priorità prima che il gioco ti sfugga di mano. Meglio poche cose tenute bene che tante lasciate cadere.',
      stem: 'tar_rw_denari_02_v1',
    ),
    TarotCard(
      name: 'Tre di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 3,
      uprightSummary: 'L\'opera comune.',
      upright:
          'Collaborazione, competenza, primi risultati concreti: costruisci insieme agli altri. Il tuo lavoro è visto e apprezzato e questo è solo l\'inizio. Da soli si va veloci, insieme si va lontano.',
      reversedSummary: 'La collaborazione stonata.',
      reversed:
          'Ruoli confusi, poca sintonia, un lavoro comune che non ingrana. Chiarite i compiti e le aspettative e l\'opera riparte. Spesso il problema non è la volontà, ma la comunicazione.',
      stem: 'tar_rw_denari_03_v1',
    ),
    TarotCard(
      name: 'Quattro di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 4,
      uprightSummary: 'La mano che stringe.',
      upright:
          'Sicurezza, risparmio, controllo su ciò che possiedi: proteggi ciò che hai. Attento però a non chiuderti troppo, la mano stretta non riceve. La stabilità è buona, l\'attaccamento un po\' meno.',
      reversedSummary: 'La presa da allentare.',
      reversed:
          'Un attaccamento eccessivo, o la paura di perdere che ti irrigidisce. Apri la mano, il denaro e le energie servono per fluire, non per essere trattenuti. Ciò che stringi troppo, ti stringe a sua volta.',
      stem: 'tar_rw_denari_04_v1',
    ),
    TarotCard(
      name: 'Cinque di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 5,
      uprightSummary: 'Il freddo fuori dalla porta.',
      upright:
          'Una difficoltà, una mancanza, un senso di esclusione o di solitudine. Ma la luce calda è più vicina di quanto credi: chiedi aiuto senza vergogna. Nessuno deve attraversare l\'inverno da solo.',
      reversedSummary: 'Il ritorno al caldo.',
      reversed:
          'Una ripresa, un sostegno ritrovato: il periodo duro comincia ad allentarsi. Riaccogli la fiducia, stai uscendo dal freddo. Dopo la mancanza torna l\'abbondanza, un passo alla volta.',
      stem: 'tar_rw_denari_05_v1',
    ),
    TarotCard(
      name: 'Sei di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 6,
      uprightSummary: 'La bilancia del dare.',
      upright:
          'Generosità, uno scambio equo, un aiuto che va e viene con giustizia. Dai e ricevi mantenendo l\'equilibrio e tutto guarisce. La vera abbondanza circola, non si accumula soltanto.',
      reversedSummary: 'Il dare sbilanciato.',
      reversed:
          'Debiti, o una generosità mal riposta che ti svuota. Verifica che lo scambio sia davvero equo, in entrambe le direzioni. Dare troppo a chi non ricambia non è bontà, è squilibrio.',
      stem: 'tar_rw_denari_06_v1',
    ),
    TarotCard(
      name: 'Sette di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 7,
      uprightSummary: 'L\'attesa del raccolto.',
      upright:
          'Pazienza, valutazione, un investimento che matura lentamente: hai coltivato, ora aspetta il tempo giusto. Non strappare i frutti prima che siano pronti. Ciò che cresce bene, cresce senza fretta.',
      reversedSummary: 'La fretta del raccolto.',
      reversed:
          'Impazienza, o uno sforzo che sembra mal ripagato. Rivedi con calma dove metti la tua energia, senza scoraggiarti. A volte il raccolto tarda perché il seme era quello sbagliato, non il tempo.',
      stem: 'tar_rw_denari_07_v1',
    ),
    TarotCard(
      name: 'Otto di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 8,
      uprightSummary: 'La mano che affina.',
      upright:
          'Impegno, mestiere, dedizione: perfezioni con cura, un dettaglio alla volta. La maestria nasce proprio da questa pratica paziente. Ciò che fai bene oggi diventa il tuo talento domani.',
      reversedSummary: 'Il lavoro senz\'anima.',
      reversed:
          'Monotonia, o una cura che si è persa per strada. Ritrova il senso di ciò che fai, oppure abbi il coraggio di cambiare direzione. Il mestiere senza passione diventa una gabbia.',
      stem: 'tar_rw_denari_08_v1',
    ),
    TarotCard(
      name: 'Nove di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 9,
      uprightSummary: 'Il giardino conquistato.',
      upright:
          'Autonomia, agiatezza, frutti meritati con le tue mani: goditi ciò che hai costruito da te. È la carta dell\'indipendenza serena. Ti sei guadagnata il tuo spazio, abitalo con piacere.',
      reversedSummary: 'L\'indipendenza da curare.',
      reversed:
          'Un\'insicurezza, o eccessi che minano la tua serenità. Ritrova l\'equilibrio tra il valore di te e quello di ciò che possiedi. Non sei ciò che hai, sei molto di più.',
      stem: 'tar_rw_denari_09_v1',
    ),
    TarotCard(
      name: 'Dieci di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 10,
      uprightSummary: 'L\'eredità della casa.',
      upright:
          'Ricchezza duratura, famiglia, radici solide: ciò che costruisci resta e nutrirà chi verrà dopo di te. È un tempo di stabilità profonda. Stai piantando qualcosa che dura oltre te.',
      reversedSummary: 'Le radici da rassodare.',
      reversed:
          'Tensioni sui beni, o in famiglia, che scuotono le fondamenta. Cura ciò che dura davvero, oltre il guadagno di oggi. La ricchezza vera è anche l\'armonia di chi ti sta intorno.',
      stem: 'tar_rw_denari_10_v1',
    ),
    TarotCard(
      name: 'Fante di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 11,
      uprightSummary: 'Lo studente diligente.',
      upright:
          'Apprendimento, un progetto concreto, una promessa che chiede impegno. Coltiva questa idea nuova con serietà e pazienza. I sogni pratici si realizzano un passo studiato dopo l\'altro.',
      reversedSummary: 'La promessa rimandata.',
      reversed:
          'Distrazione, o un progetto che si è fermato a metà. Rimettiti al lavoro un passo alla volta, senza voler recuperare tutto subito. Anche un piccolo gesto rimette in moto ciò che era fermo.',
      stem: 'tar_rw_denari_11_v1',
    ),
    TarotCard(
      name: 'Cavaliere di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 12,
      uprightSummary: 'Il passo costante.',
      upright:
          'Metodo, affidabilità, impegno paziente: avanzi con costanza verso la meta. Qui la lentezza non è un limite, è la tua forza. Chi va piano e non si ferma, arriva sempre.',
      reversedSummary: 'Il passo bloccato.',
      reversed:
          'Uno stallo, o un eccesso di prudenza che ti tiene immobile. Muovi qualcosa, anche di piccolo, per ripartire. La perfezione dell\'attesa a volte è solo paura di sbagliare.',
      stem: 'tar_rw_denari_12_v1',
    ),
    TarotCard(
      name: 'Regina di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 13,
      uprightSummary: 'La cura concreta.',
      upright:
          'Accoglienza, praticità, un\'abbondanza generosa: nutri chi ami e i tuoi progetti con i piedi a terra. Sai unire il cuore e la concretezza ed è un dono raro. La tua casa e il tuo lavoro fioriscono nelle tue mani.',
      reversedSummary: 'La cura dispersa.',
      reversed:
          'Ti dimentichi di te mentre ti prendi cura di tutto e di tutti. Rimetti equilibrio tra dare e ricevere. Anche il giardino più generoso ha bisogno di essere annaffiato.',
      stem: 'tar_rw_denari_13_v1',
    ),
    TarotCard(
      name: 'Re di Denari',
      arcana: TarotArcana.minore,
      seme: TarotSeme.denari,
      number: 14,
      uprightSummary: 'La prosperità sicura.',
      upright:
          'Successo concreto, stabilità, una generosità matura: guidi con abbondanza e misura. Hai costruito qualcosa di solido e sai condividerlo. La ricchezza qui è anche saggezza nel gestirla.',
      reversedSummary: 'Il possesso che irrigidisce.',
      reversed:
          'Un attaccamento, o una rigidità legata a ciò che hai. La vera ricchezza è anche saperla lasciare circolare. Ciò che possiedi non deve possederti.',
      stem: 'tar_rw_denari_14_v1',
    ),
    TarotCard(
      name: 'Asso di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 1,
      uprightSummary: 'La lama della verità.',
      upright:
          'Chiarezza, un\'idea netta, un taglio deciso: vedi con lucidità e distingui il vero dal falso. È il momento di dire le cose come stanno, con onestà. Una verità detta bene apre più di quanto ferisca.',
      reversedSummary: 'La lama confusa.',
      reversed:
          'Idee annebbiate, o parole taglienti usate male. Rischiara la mente prima di decidere o di parlare. La stessa lama può liberare o ferire, dipende da come la impugni.',
      stem: 'tar_rw_spade_01_v1',
    ),
    TarotCard(
      name: 'Due di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 2,
      uprightSummary: 'La scelta bendata.',
      upright:
          'Indecisione, uno stallo, un equilibrio precario tenuto a occhi chiusi. Togli la benda e guarda ciò che stai evitando. La decisione che rimandi non sparisce, ti aspetta.',
      reversedSummary: 'La verità che riaffiora.',
      reversed:
          'Un blocco che si scioglie, una scelta rimandata che torna a chiederti una risposta. Ora puoi vedere ciò che prima coprivi. Affrontarla adesso pesa meno che continuare a girarci intorno.',
      stem: 'tar_rw_spade_02_v1',
    ),
    TarotCard(
      name: 'Tre di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 3,
      uprightSummary: 'Il cuore trafitto.',
      upright:
          'Un dolore, una delusione, una ferita che attraversa il petto. Lascia scorrere le lacrime, perché il dolore attraversato guarisce, quello negato resta. Anche la pioggia più fitta, prima o poi, passa.',
      reversedSummary: 'La ferita che rimargina.',
      reversed:
          'Il perdono, la ripresa, un dolore che comincia a sfumare. La pioggia sta passando e il cuore torna a respirare. Guarire non significa dimenticare, ma smettere di sanguinare.',
      stem: 'tar_rw_spade_03_v1',
    ),
    TarotCard(
      name: 'Quattro di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 4,
      uprightSummary: 'Il riposo del guerriero.',
      upright:
          'Una pausa, un recupero, il silenzio necessario dopo la fatica. Fermati e ricarica, la mente ha bisogno di quiete quanto il corpo. Non è tempo perso, è tempo che ti restituisce forza.',
      reversedSummary: 'Il risveglio dalla sosta.',
      reversed:
          'Hai riposato abbastanza, è tempo di rimetterti in moto con calma. Torna all\'azione senza strafare al primo passo. La quiete ha fatto il suo lavoro, ora tocca a te.',
      stem: 'tar_rw_spade_04_v1',
    ),
    TarotCard(
      name: 'Cinque di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 5,
      uprightSummary: 'La vittoria amara.',
      upright:
          'Un conflitto, l\'orgoglio, un successo che costa più di quanto valga. Chiediti con sincerità se merita ciò che perdi per ottenerlo. Non tutte le battaglie vinte sono guadagni.',
      reversedSummary: 'La pace da ricucire.',
      reversed:
          'Nasce la voglia di riconciliazione, di deporre le armi. Il perdono libera più della ragione, anche quando avresti ragione. Fare il primo passo verso la pace non è perdere, è scegliere meglio.',
      stem: 'tar_rw_spade_05_v1',
    ),
    TarotCard(
      name: 'Sei di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 6,
      uprightSummary: 'La traversata calma.',
      upright:
          'Una transizione, l\'allontanarsi dalle acque agitate verso una sponda più serena. Vai un passo alla volta, il mare si sta calmando. Lasciare la tempesta alle spalle è già metà del viaggio.',
      reversedSummary: 'La partenza difficile.',
      reversed:
          'Fatichi a lasciare il passato, il distacco pesa più del previsto. Il viaggio è comunque possibile, anche se il cuore resta un po\' indietro. Si può partire anche con la valigia pesante.',
      stem: 'tar_rw_spade_06_v1',
    ),
    TarotCard(
      name: 'Sette di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 7,
      uprightSummary: 'La strategia silenziosa.',
      upright:
          'Astuzia, prudenza, agire con tatto invece che di forza. Usa l\'ingegno, ma resta onesto con te stesso su cosa stai facendo. La furbizia è un\'arte, l\'inganno una trappola anche per chi lo tende.',
      reversedSummary: 'Il gioco da chiarire.',
      reversed:
          'Un inganno che pesa sulla coscienza, tuo o di qualcun altro, che sta venendo a galla. Torna alla trasparenza, libera la coscienza. La verità costa meno di una bugia da mantenere.',
      stem: 'tar_rw_spade_07_v1',
    ),
    TarotCard(
      name: 'Otto di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 8,
      uprightSummary: 'La prigione dei pensieri.',
      upright:
          'Ti senti bloccato, ma i limiti sono soprattutto nella tua mente. Le corde sono più larghe di quanto credi e la benda te la puoi togliere. Il primo passo verso l\'uscita è capire che c\'è.',
      reversedSummary: 'Le corde che cadono.',
      reversed:
          'Una liberazione, una via che si apre dopo il senso di trappola. Riconosci la tua forza e fai il primo passo fuori. Eri più libero di quanto la paura ti diceva.',
      stem: 'tar_rw_spade_08_v1',
    ),
    TarotCard(
      name: 'Nove di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 9,
      uprightSummary: 'L\'angoscia della notte.',
      upright:
          'Ansia, pensieri cupi, notti insonni: le paure crescono al buio. Ma alla luce del giorno si ridimensionano quasi sempre. Non credere a tutto ciò che la mente ti racconta alle tre di notte.',
      reversedSummary: 'L\'alba dopo l\'incubo.',
      reversed:
          'La paura comincia ad allentare la presa, il peggio della notte è passato. Parlane, condividi ciò che ti angoscia e il peso si dimezza. Ciò che si dice a voce fa meno paura di ciò che si rimugina.',
      stem: 'tar_rw_spade_09_v1',
    ),
    TarotCard(
      name: 'Dieci di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 10,
      uprightSummary: 'La fine e la resa.',
      upright:
          'Un ciclo doloroso si chiude, hai toccato il fondo. Ma proprio da qui si può solo risalire, più in basso non si va. Ogni notte più nera annuncia l\'alba.',
      reversedSummary: 'La risalita.',
      reversed:
          'Una ripresa, un sollievo, il peggio ormai alle spalle. L\'alba torna, rialzati con dolcezza e senza fretta. Hai superato la parte più dura, ora si ricomincia.',
      stem: 'tar_rw_spade_10_v1',
    ),
    TarotCard(
      name: 'Fante di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 11,
      uprightSummary: 'La mente curiosa.',
      upright:
          'Vigilanza, idee acute, una verità da cercare con occhi attenti. Osserva e informati, ma scegli con cura le parole. La curiosità è preziosa, la lingua affilata va usata con misura.',
      reversedSummary: 'La parola pungente.',
      reversed:
          'Pettegolezzo, o pensieri sparsi che feriscono senza costruire. Modera la lingua e verifica prima di parlare. Le parole dette a vanvera tornano sempre indietro.',
      stem: 'tar_rw_spade_11_v1',
    ),
    TarotCard(
      name: 'Cavaliere di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 12,
      uprightSummary: 'La carica del pensiero.',
      upright:
          'Determinazione, azione rapida, idee decise: vai dritto allo scopo. Fai attenzione però a non travolgere chi ti sta accanto. La velocità della mente è un dono se non diventa fretta cieca.',
      reversedSummary: 'La foga imprudente.',
      reversed:
          'Fretta, o parole affilate lanciate senza pensare. Rallenta, la lucidità vale molto più della velocità. Un istante di pausa ti risparmia molti passi indietro.',
      stem: 'tar_rw_spade_12_v1',
    ),
    TarotCard(
      name: 'Regina di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 13,
      uprightSummary: 'La lucidità sincera.',
      upright:
          'Intelligenza, onestà, confini chiari: pensi con nitore e dici il vero senza giri. La tua franchezza è un dono, anche quando non è comoda. Sai distinguere e questo ti protegge.',
      reversedSummary: 'La freddezza difensiva.',
      reversed:
          'Una durezza, o una solitudine scelta come corazza. Ammorbidisci il giudizio, a partire da quello verso te stessa. La lama più affilata non deve rivolgersi contro chi la porta.',
      stem: 'tar_rw_spade_13_v1',
    ),
    TarotCard(
      name: 'Re di Spade',
      arcana: TarotArcana.minore,
      seme: TarotSeme.spade,
      number: 14,
      uprightSummary: 'Il giudizio giusto.',
      upright:
          'Autorità mentale, etica, verità: decidi con equità e con la ragione al servizio del cuore. Sei un punto di riferimento lucido e onesto. Il vero potere della mente è metterla al servizio del bene.',
      reversedSummary: 'Il rigore senza cuore.',
      reversed:
          'Freddezza, o un\'autorità dura che dimentica le persone. Unisci alla logica la compassione. La ragione senza cuore vince le discussioni e perde i legami.',
      stem: 'tar_rw_spade_14_v1',
    ),
  ];
}
