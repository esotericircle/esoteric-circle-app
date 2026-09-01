import '../maestro/maestro.dart';

/// I DATI VERI DI STAMATTINA che un rito puo' nominare.
///
/// Il rito non e' un testo pescato da un elenco: e' una forma che si riempie
/// col cielo di oggi. Per questo ogni variante dichiara di quale dato ha
/// bisogno, e se quel dato manca la variante non entra: **il rito cambia
/// momento invece di inventare**.
enum DatoDelCielo {
  /// La fase lunare vera, da `MoonPhase.forDate`.
  faseLunare('{fase}'),

  /// Il segno in cui si trova la Luna, da `NightSky.moonSign`.
  segnoLunare('{segno}'),

  /// L'ora del sorgere del sole per il luogo della persona, da
  /// `SunsetTime.albaPerData`. Manca se il luogo non e' noto.
  oraDellAlba('{alba}');

  const DatoDelCielo(this.segnaposto);

  /// Il segnaposto che compare nel testo della variante.
  final String segnaposto;
}

/// UN GESTO da compiere davvero, non da leggere.
class Gesto {
  const Gesto({
    required this.testo,
    required this.parola,
    required this.dato,
    required this.viaTattile,
    this.usaSensore = false,
  });

  /// Cosa fare, con dentro il segnaposto del dato che nomina.
  final String testo;

  /// **LA PAROLA CHE APPARTIENE A QUESTO GESTO. Ordine AS voce 06.**
  ///
  /// **Il difetto che chiude.** La parola del giorno si estraeva con un terzo
  /// seme, indipendente dal gesto e dal respiro: era una scelta deliberata
  /// ("cosi' i tre momenti non si muovono insieme"), e produceva riti dove il
  /// gesto diceva "conta quante ore mancano a stasera" e la parola era
  /// "Ombra". Nessuna attinenza, e chi legge lo sente subito.
  ///
  /// Adesso il legame e' DICHIARATO NEL DATO, una parola per gesto, e non
  /// dedotto da un indice: chi scrive un gesto nuovo deve dire quale parola
  /// gli appartiene, e la guardia lo pretende. Le combinazioni scendono da
  /// sessantaquattro a sedici per forma, ed e' il prezzo giusto: un rito che
  /// tiene insieme vale piu' di quattro riti che non c'entrano niente.
  final String parola;

  /// Il dato del cielo che questo gesto nomina.
  final DatoDelCielo dato;

  /// LA VIA COL DITO, sempre presente.
  ///
  /// E' regola di casa che ogni esperienza abbia un ripiego tattile. Qui nessun
  /// gesto usa sensori, quindi la via col dito non e' un ripiego tecnico ma la
  /// versione del gesto per chi lo compie da seduto, al buio, o senza potersi
  /// muovere. Un rito che si puo' fare solo in piedi e' un rito che qualcuno non
  /// puo' fare.
  final String viaTattile;

  /// Se il gesto chiede un sensore. Falso per tutti, per scelta.
  final bool usaSensore;
}

/// UN RESPIRO CONTATO, con il suo numero.
class Respiro {
  const Respiro({
    required this.tempi,
    required this.giri,
    required this.testo,
    this.dato,
  });

  /// Quanti tempi dura ogni fase del respiro.
  final int tempi;

  /// Quante volte si ripete.
  final int giri;

  /// Come si conta, detto in parole.
  final String testo;

  /// Il dato del cielo che il respiro nomina, se ne nomina uno.
  final DatoDelCielo? dato;
}

/// UNA PAROLA DA PORTARE nella giornata.
class Parola {
  const Parola({
    required this.parola,
    required this.perche,
    this.dato,
  });

  /// La parola, una sola.
  final String parola;

  /// Perche' quella: mai una promessa di esito, solo cosa la parola indica.
  final String perche;

  /// Il dato del cielo che la riga nomina, se ne nomina uno.
  final DatoDelCielo? dato;
}

/// UNA FORMA DEL RITO: tre momenti, ognuno con almeno quattro varianti.
///
/// Una forma sola produce `gesti * respiri * parole` riti diversi. Con quattro
/// varianti per momento sono sessantaquattro riti da una forma, e con nove
/// forme sono cinquecentosettantasei: un elenco di testi che desse altrettanto
/// andrebbe scritto a mano cinquecento volte, e si esaurirebbe comunque.
class FormaDelRito {
  const FormaDelRito({
    required this.maestro,
    required this.nome,
    required this.gesti,
    required this.respiri,
    required this.parole,
  });

  final Maestro maestro;

  /// Il nome della forma, che compare a schermo.
  final String nome;

  final List<Gesto> gesti;
  final List<Respiro> respiri;
  final List<Parola> parole;

  /// Quante combinazioni produce questa forma.
  int get combinazioni => gesti.length * respiri.length * parole.length;
}

/// LE NOVE FORME, tre per Maestro.
///
/// **Le tre lenti non si somigliano, ed e' il criterio con cui sono scritte.**
/// Medora legge il tempo e la direzione, e i suoi gesti guardano avanti, verso
/// un'ora o verso un giorno. Aura legge il corpo e l'energia, i suoi gesti sono
/// fisici e il respiro e' il centro del rito, non un contorno. Caligo legge il
/// simbolo, e i suoi gesti tracciano o portano un segno. Se un rito di Medora
/// si potesse dare ad Aura cambiando il nome, sarebbe scritto male, e una prova
/// lo pretende.
class RitoAlbaCorpus {
  const RitoAlbaCorpus._();

  static const List<FormaDelRito> forme = [
    // =========================================================================
    // MEDORA, il tempo e la direzione
    // =========================================================================
    FormaDelRito(
      maestro: Maestro.medora,
      nome: 'L\'ora che viene',
      gesti: [
        Gesto(
          testo: 'Il sole sorge alle {alba}. Mettiti dove puoi vedere la luce '
              'che entra e resta rivolto in quella direzione per il tempo di un '
              'respiro intero.',
          parola: 'Direzione',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Se non puoi alzarti, gira il palmo verso la finestra e '
              'tienilo aperto per il tempo di un respiro.',
        ),
        Gesto(
          testo: 'Guarda un orologio e conta quante ore mancano a stasera. '
              'Il sole di oggi è sorto alle {alba}: quel numero è la parte '
              'di giornata che hai davanti.',
          parola: 'Passo',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Conta le ore sulle dita, una per dito, senza guardare '
              'nessun quadrante.',
        ),
        Gesto(
          testo: 'La Luna è in {segno}. Scegli una cosa sola che vuoi aver '
              'fatto prima che finisca il giorno e dilla ad alta voce una '
              'volta.',
          parola: 'Prima',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Se non vuoi parlare, scrivila con un dito sul palmo '
              'aperto dell\'altra mano.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Volgi lo sguardo verso il punto più '
              'lontano che riesci a vedere da dove sei e restaci sopra finché '
              'non hai contato fino a dieci.',
          parola: 'Adesso',
          dato: DatoDelCielo.faseLunare,
          viaTattile:
              'Chiudi gli occhi e conta fino a dieci tenendo il pollice '
              'sul palmo.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 4,
            giri: 4,
            testo: 'Quattro tempi mentre entra, quattro mentre esce. Quattro '
                'giri.'),
        Respiro(
            tempi: 5,
            giri: 3,
            testo: 'Cinque tempi dentro, cinque fuori, per tre giri. Il conto '
                'sta davanti al respiro, non il contrario.'),
        Respiro(
            tempi: 6,
            giri: 3,
            testo:
                'Sei tempi dentro e sei fuori, tre volte, tenendo lo sguardo '
                'fermo su un punto solo.'),
        Respiro(
            tempi: 4,
            giri: 6,
            testo: 'Quattro dentro e quattro fuori, sei giri: uno per ogni ora '
                'della prima parte del giorno.'),
      ],
      parole: [
        Parola(
            parola: 'Direzione',
            perche: 'Indica il verso, non la meta: si può tenere una '
                'direzione anche in un giorno che va storto.'),
        Parola(
            parola: 'Adesso',
            perche: 'Nomina l\'unico momento in cui si può agire.'),
        Parola(
            parola: 'Prima',
            perche: 'Indica ciò che viene messo davanti al resto, oggi.'),
        Parola(
            parola: 'Passo',
            perche: 'Indica una misura corta: un passo si fa, una distanza si '
                'guarda soltanto.'),
      ],
    ),
    FormaDelRito(
      maestro: Maestro.medora,
      nome: 'Il passo del giorno',
      gesti: [
        Gesto(
          testo: 'Fai sette passi in linea retta, contandoli. Il sole è '
              'sorto alle {alba} e questi sono i primi passi che fai dopo.',
          parola: 'Avanti',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Batti sette volte il dito su una superficie, contando.',
        ),
        Gesto(
          testo: 'La Luna è in {segno}. Apri e chiudi la mano tre volte, '
              'lentamente, pensando a una cosa che oggi vuoi lasciar andare.',
          parola: 'Ordine',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Se la mano non si apre bene, premi il pollice contro '
              'l\'indice tre volte.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Alzati e resta in piedi immobile per il '
              'tempo di tre respiri, senza appoggiarti.',
          parola: 'Uno',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Da seduto, raddrizza la schiena e tienila dritta per '
              'tre respiri.',
        ),
        Gesto(
          testo: 'Il giorno si è aperto alle {alba}. Scegli l\'ora in cui '
              'vuoi aver finito la cosa più pesante e ricordatela.',
          parola: 'Misura',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Scrivi quell\'ora con un dito sul tavolo.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 4,
            giri: 7,
            testo:
                'Quattro dentro e quattro fuori, sette giri, uno per passo.'),
        Respiro(
            tempi: 3,
            giri: 5,
            testo:
                'Tre tempi dentro e tre fuori, cinque giri, corti e regolari.'),
        Respiro(
            tempi: 5,
            giri: 4,
            testo: 'Cinque dentro, cinque fuori, quattro giri.'),
        Respiro(
            tempi: 6,
            giri: 2,
            testo: 'Sei dentro e sei fuori, due giri soli, ma senza fretta.'),
      ],
      parole: [
        Parola(
            parola: 'Ordine',
            perche: 'Indica cosa viene prima e cosa dopo, quando tutto sembra '
                'urgente.'),
        Parola(parola: 'Uno', perche: 'Indica una cosa sola alla volta.'),
        Parola(
            parola: 'Avanti',
            perche: 'Indica il verso del movimento, non la sua velocità.'),
        Parola(
            parola: 'Misura',
            perche: 'Indica la quantità giusta, che non è né tutto né '
                'niente.'),
      ],
    ),
    FormaDelRito(
      maestro: Maestro.medora,
      nome: 'La direzione della luce',
      gesti: [
        Gesto(
          testo: 'La Luna è in {segno}. Individua da che parte viene la luce '
              'più forte nella stanza e voltati verso di essa.',
          parola: 'Verso',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Passa la mano nell\'aria finché non senti la parte '
              'più tiepida e fermala lì.',
        ),
        Gesto(
          testo: 'Alle {alba} il sole ha toccato l\'orizzonte del tuo luogo. '
              'Indica col braccio teso il punto da cui pensi sia arrivato.',
          parola: 'Chiaro',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Indica quel punto col solo dito, senza alzare il '
              'braccio.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Guarda fuori e trova tre cose che non '
              'c\'erano ieri, o che ieri non avevi notato.',
          parola: 'Aperto',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Se non c\'è una finestra, trova tre suoni diversi e '
              'contali sulle dita.',
        ),
        Gesto(
          testo: 'Il sole è sorto alle {alba}. Resta fermo finché non senti '
              'l\'aria sulla pelle, poi muoviti.',
          parola: 'Oggi',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Appoggia il dorso della mano sulla guancia e aspetta di '
              'sentire la differenza di temperatura.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 4,
            giri: 3,
            testo: 'Quattro dentro, quattro fuori, tre giri, rivolto verso la '
                'luce.'),
        Respiro(
            tempi: 7,
            giri: 2,
            testo: 'Sette tempi dentro e sette fuori, due giri: lunghi e se '
                'sette è troppo scendi a cinque.'),
        Respiro(
            tempi: 5,
            giri: 5,
            testo: 'Cinque dentro e cinque fuori, cinque giri.'),
        Respiro(
            tempi: 6,
            giri: 4,
            testo: 'Sei dentro e sei fuori, quattro giri, contando piano.'),
      ],
      parole: [
        Parola(
            parola: 'Chiaro',
            perche: 'Indica ciò che si vede senza sforzo e che spesso si '
                'guarda per ultimo.'),
        Parola(
            parola: 'Verso',
            perche: 'Indica un orientamento, che si può correggere in '
                'qualsiasi momento.'),
        Parola(
            parola: 'Aperto', perche: 'Indica una condizione, non un dovere.'),
        Parola(
            parola: 'Oggi',
            perche: 'Delimita: quello che segue riguarda un giorno solo.'),
      ],
    ),

    // =========================================================================
    // AURA, il corpo e l'energia. Il respiro e' il centro del rito.
    // =========================================================================
    FormaDelRito(
      maestro: Maestro.aura,
      nome: 'Il corpo che si sveglia',
      gesti: [
        Gesto(
          testo: 'La Luna è {fase}. Appoggia entrambe le mani sul petto e '
              'lasciale lì finché non senti il torace muoversi da solo.',
          parola: 'Peso',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Se non puoi alzare le braccia, appoggia una mano sola '
              'sul ventre.',
        ),
        Gesto(
          testo: 'Il sole è sorto alle {alba}. Ruota le spalle indietro '
              'cinque volte, lentamente, sentendo dove si blocca.',
          parola: 'Lento',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Muovi solo le dita delle mani, aprendole e chiudendole '
              'cinque volte.',
        ),
        Gesto(
          testo: 'La Luna è in {segno}. Poggia a terra tutti e due i piedi '
              'e senti il peso passare dai talloni alle dita.',
          parola: 'Terra',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Da sdraiato, premi i talloni contro il materasso e '
              'lascia andare.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Allunga le braccia sopra la testa fino a '
              'sentire tirare, poi lasciale cadere di colpo.',
          parola: 'Aria',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Allunga solo le dita, aprendole il più possibile, poi '
              'rilassale.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 4,
            giri: 8,
            testo: 'Quattro tempi dentro, quattro fuori, otto giri. È il '
                'centro del rito: se fai solo questo, il rito è fatto.',
            dato: null),
        Respiro(
            tempi: 4,
            giri: 6,
            testo: 'Quattro dentro, quattro trattenuti, quattro fuori, quattro '
                'fermi. Sei giri. Se trattenere da\' fastidio, togli le due '
                'pause e resta sul respiro semplice.'),
        Respiro(
            tempi: 6,
            giri: 6,
            testo: 'Sei dentro e sei fuori, sei giri, con le mani sul ventre '
                'per sentire dove arriva l\'aria.'),
        Respiro(
            tempi: 5,
            giri: 8,
            testo: 'Cinque dentro e cinque fuori, otto giri, senza forzare la '
                'fine dell\'espirazione.'),
      ],
      parole: [
        Parola(
            parola: 'Peso',
            perche: 'Indica ciò che il corpo sente per primo al risveglio.'),
        Parola(
            parola: 'Lento',
            perche: 'Indica una velocità ed è l\'unica cosa che si può '
                'davvero scegliere al mattino.'),
        Parola(
            parola: 'Terra',
            perche: 'Indica il punto di appoggio, quello che regge senza che '
                'ci si pensi.'),
        Parola(
            parola: 'Aria',
            perche: 'Indica ciò che entra ed esce senza permesso.'),
      ],
    ),
    FormaDelRito(
      maestro: Maestro.aura,
      nome: 'Il respiro che conta',
      gesti: [
        Gesto(
          testo: 'La Luna è in {segno}. Siediti e appoggia le mani sulle '
              'ginocchia, palmi in su e lasciale aperte per tutto il respiro.',
          parola: 'Piano',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Appoggia le mani dove ti è comodo, purché i palmi '
              'restino aperti.',
        ),
        Gesto(
          testo: 'Il sole è sorto alle {alba}. Chiudi gli occhi e conta '
              'quanti suoni diversi arrivano, senza cercarli.',
          parola: 'Conta',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Se preferisci tenerli aperti, fissa un punto solo e '
              'conta i suoni lo stesso.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Poggia la lingua dietro i denti '
              'superiori e lasciala lì per tutto il tempo del respiro.',
          parola: 'Ancora',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Se da\' fastidio, lascia la bocca socchiusa e non '
              'pensarci.',
        ),
        Gesto(
          testo: 'La Luna è in {segno}. Lascia cadere le spalle di due dita '
              'e non rialzarle per tutto il rito.',
          parola: 'Basta',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Espira una volta lunga e lascia che scendano da sole.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 4,
            giri: 10,
            testo: 'Quattro dentro e quattro fuori, dieci giri. È il rito '
                'intero: il gesto serve solo a metterti in posizione.'),
        Respiro(
            tempi: 6,
            giri: 8,
            testo: 'Sei dentro e sei fuori, otto giri, contando a mente.'),
        Respiro(
            tempi: 4,
            giri: 12,
            testo: 'Quattro e quattro, dodici giri, senza mai accelerare la '
                'fine.'),
        Respiro(
            tempi: 5,
            giri: 10,
            testo: 'Cinque dentro e cinque fuori, dieci giri e se perdi il '
                'conto ricominci da uno senza rimproverarti.'),
      ],
      parole: [
        Parola(
            parola: 'Conta',
            perche: 'Indica cosa fare quando la testa va altrove.'),
        Parola(parola: 'Basta', perche: 'Indica un limite e va bene metterlo.'),
        Parola(
            parola: 'Ancora',
            perche: 'Indica che una cosa si può rifare, non che si deve.'),
        Parola(parola: 'Piano', perche: 'Indica un modo, non un ritardo.'),
      ],
    ),
    FormaDelRito(
      maestro: Maestro.aura,
      nome: 'La soglia del corpo',
      gesti: [
        Gesto(
          testo: 'La Luna è {fase}. Bevi un bicchiere d\'acqua lentamente, '
              'sentendo dove arriva.',
          parola: 'Sete',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Se non puoi bere adesso, bagna le labbra e le dita.',
        ),
        Gesto(
          testo: 'Il sole è sorto alle {alba}. Appoggia i palmi uno contro '
              'l\'altro e premili finché non senti caldo, poi separali.',
          parola: 'Caldo',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Sfrega solo i polpastrelli fra loro, il risultato è lo '
              'stesso.',
        ),
        Gesto(
          testo: 'La Luna è in {segno}. Passa una mano dalla nuca alla '
              'spalla, da un lato e poi dall\'altro.',
          parola: 'Sciolto',
          dato: DatoDelCielo.segnoLunare,
          viaTattile:
              'Se il braccio non arriva, passa la mano sull\'avambraccio '
              'opposto.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Sbadiglia apposta, anche se non ne hai '
              'voglia e lascia che il corpo decida se continuare.',
          parola: 'Soglia',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Apri la bocca lentamente e richiudila, senza forzare.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 4,
            giri: 5,
            testo:
                'Quattro dentro e quattro fuori, cinque giri, dopo l\'acqua.'),
        Respiro(
            tempi: 7,
            giri: 4,
            testo: 'Sette dentro e sette fuori, quattro giri. Se sette è '
                'troppo lungo, scendi a cinque: il numero serve a te, non tu a '
                'lui.'),
        Respiro(
            tempi: 5,
            giri: 6,
            testo: 'Cinque dentro e cinque fuori, sei giri, con le spalle '
                'basse.'),
        Respiro(
            tempi: 6,
            giri: 5,
            testo: 'Sei dentro e sei fuori, cinque giri, lasciando l\'ultima '
                'espirazione più lunga delle altre.'),
      ],
      parole: [
        Parola(
            parola: 'Soglia',
            perche: 'Indica un passaggio e il mattino ne è uno.'),
        Parola(
            parola: 'Caldo',
            perche: 'Indica una sensazione che si può produrre da soli.'),
        Parola(
            parola: 'Sciolto',
            perche: 'Indica una condizione del corpo, non un giudizio su di '
                'esso.'),
        Parola(
            parola: 'Sete',
            perche: 'Indica un bisogno semplice, che si ascolta prima degli '
                'altri.'),
      ],
    ),

    // =========================================================================
    // CALIGO, il simbolo. Il gesto traccia o porta un segno.
    // =========================================================================
    FormaDelRito(
      maestro: Maestro.caligo,
      nome: 'Il segno tracciato',
      gesti: [
        Gesto(
          testo: 'La Luna è in {segno}. Traccia col dito, sul vetro o '
              'sull\'aria, una linea verticale e una obliqua che la incrocia.',
          parola: 'Traccia',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Tracciala sul palmo della mano e sentila mentre la '
              'fai.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Disegna un cerchio con un dito e chiudilo, '
              'poi mettici dentro un punto.',
          parola: 'Nodo',
          dato: DatoDelCielo.faseLunare,
          viaTattile:
              'Fallo sul dorso dell\'altra mano, dove il segno si sente '
              'meglio.',
        ),
        Gesto(
          testo: 'Il sole è sorto alle {alba}. Scrivi quell\'ora con un dito '
              'su una superficie e poi cancellala passandoci sopra.',
          parola: 'Segno',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Scrivila sul palmo e chiudi la mano per cancellarla.',
        ),
        Gesto(
          testo: 'La Luna è in {segno}. Traccia tre linee parallele, poi '
              'attraversale con una quarta.',
          parola: 'Soglia',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Usa quattro dita appoggiate, poi passaci sopra il '
              'pollice.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 4,
            giri: 3,
            testo: 'Quattro dentro e quattro fuori, tre giri, guardando il '
                'segno che hai fatto.'),
        Respiro(
            tempi: 5,
            giri: 4,
            testo: 'Cinque dentro e cinque fuori, quattro giri, uno per ogni '
                'tratto.'),
        Respiro(
            tempi: 6,
            giri: 3,
            testo: 'Sei dentro e sei fuori, tre giri, senza rifare il segno.'),
        Respiro(
            tempi: 3,
            giri: 6,
            testo: 'Tre dentro e tre fuori, sei giri, corti come i tratti.'),
      ],
      parole: [
        Parola(
            parola: 'Segno',
            perche: 'Indica una cosa che sta al posto di un\'altra ed è '
                'l\'unico modo che abbiamo di dire il difficile.'),
        Parola(
            parola: 'Soglia',
            perche: 'Indica il punto in cui una cosa finisce e un\'altra '
                'comincia.'),
        Parola(
            parola: 'Nodo',
            perche: 'Indica un punto in cui due cose si tengono: si può '
                'stringere o sciogliere.'),
        Parola(
            parola: 'Traccia',
            perche: 'Indica ciò che resta del passaggio di qualcosa.'),
      ],
    ),
    FormaDelRito(
      maestro: Maestro.caligo,
      nome: 'Il sigillo portato',
      gesti: [
        Gesto(
          testo: 'La Luna è {fase}. Scegli un oggetto piccolo che hai a '
              'portata e mettilo in tasca: oggi è il tuo segno.',
          parola: 'Custodire',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Se non hai tasche, tienilo in mano per il tempo del '
              'respiro e poi rimettilo al suo posto.',
        ),
        Gesto(
          testo: 'La Luna è in {segno}. Chiudi il pugno attorno a qualcosa e '
              'stringi finché non senti la forma, poi lascia.',
          parola: 'Chiuso',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Stringi il pugno vuoto, la forma la fa la mano.',
        ),
        Gesto(
          testo: 'Il sole è sorto alle {alba}. Tocca tre volte lo stesso '
              'punto di una superficie, sempre lo stesso.',
          parola: 'Forma',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Tocca tre volte la punta del pollice con l\'indice.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Prendi qualcosa con la mano che di solito '
              'non usi e tienila per un respiro intero.',
          parola: 'Peso',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Se non puoi cambiare mano, apri quella che usi sempre e '
              'tienila aperta.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 4,
            giri: 4,
            testo: 'Quattro dentro e quattro fuori, quattro giri, tenendo '
                'l\'oggetto.'),
        Respiro(
            tempi: 6,
            giri: 3,
            testo: 'Sei dentro e sei fuori, tre giri, con la mano chiusa.'),
        Respiro(
            tempi: 5,
            giri: 3,
            testo: 'Cinque dentro e cinque fuori, tre giri, poi lascia andare '
                'la presa.'),
        Respiro(
            tempi: 4,
            giri: 7,
            testo: 'Quattro e quattro, sette giri, uno per ogni giorno della '
                'settimana che viene.'),
      ],
      parole: [
        Parola(
            parola: 'Peso',
            perche: 'Indica quanto una cosa preme: alcune pesano meno di quel '
                'che sembrava.'),
        Parola(
            parola: 'Chiuso',
            perche: 'Indica ciò che per oggi non si apre e va bene così.'),
        Parola(
            parola: 'Custodire', perche: 'Indica il tenere senza stringere.'),
        Parola(
            parola: 'Forma',
            perche: 'Indica il contorno di una cosa, che si sente prima di '
                'vederla.'),
      ],
    ),
    FormaDelRito(
      maestro: Maestro.caligo,
      nome: 'L\'ombra e il segno',
      gesti: [
        Gesto(
          testo: 'Il sole è sorto alle {alba}. Trova la tua ombra, o quella '
              'di un oggetto e guarda da che parte cade.',
          parola: 'Ombra',
          dato: DatoDelCielo.oraDellAlba,
          viaTattile: 'Se non c\'è luce diretta, passa la mano sopra una '
              'superficie e senti dove si fa più fresco.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Copri un occhio con la mano e guarda la '
              'stanza, poi cambia occhio.',
          parola: 'Dentro',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Chiudi un occhio senza usare la mano, il risultato è '
              'lo stesso.',
        ),
        Gesto(
          testo: 'La Luna è in {segno}. Nomina a mente una cosa di te che '
              'oggi non mostrerai a nessuno e non aggiungere altro.',
          parola: 'Silenzio',
          dato: DatoDelCielo.segnoLunare,
          viaTattile: 'Se preferisci, tracciane l\'iniziale sul palmo.',
        ),
        Gesto(
          testo: 'La Luna è {fase}. Spegni ogni luce che puoi spegnere e '
              'resta così per il tempo di due respiri.',
          parola: 'Riparo',
          dato: DatoDelCielo.faseLunare,
          viaTattile: 'Chiudi gli occhi e coprili con le mani per due respiri.',
        ),
      ],
      respiri: [
        Respiro(
            tempi: 5,
            giri: 4,
            testo: 'Cinque dentro e cinque fuori, quattro giri, al buio se '
                'puoi.'),
        Respiro(
            tempi: 4,
            giri: 5,
            testo: 'Quattro dentro e quattro fuori, cinque giri, senza '
                'guardare niente in particolare.'),
        Respiro(
            tempi: 6,
            giri: 4,
            testo: 'Sei dentro e sei fuori, quattro giri, lasciando che '
                'l\'espirazione finisca da sola.'),
        Respiro(
            tempi: 7,
            giri: 3,
            testo: 'Sette dentro e sette fuori, tre giri. Se sette è troppo, '
                'cinque va bene uguale.'),
      ],
      parole: [
        Parola(
            parola: 'Ombra',
            perche: 'Indica ciò che esiste proprio perché c\'è luce.'),
        Parola(
            parola: 'Dentro',
            perche: 'Indica un luogo che non ha bisogno di essere mostrato.'),
        Parola(
            parola: 'Silenzio',
            perche: 'Indica un\'assenza che si può scegliere.'),
        Parola(
            parola: 'Riparo',
            perche:
                'Indica un posto dove stare, non un posto dove nascondersi.'),
      ],
    ),
  ];

  /// LA RIGA DEL RISVEGLIO, per chi compie il rito dentro la fascia.
  ///
  /// **E' contenuto, non un punteggio.** Chi arriva entro un'ora dal proprio
  /// sorgere del sole riceve una riga in piu' dal Maestro di turno, che gli
  /// altri non ricevono. Chi arriva dopo compie il rito per intero: manca solo
  /// questa riga, e non manca nient'altro.
  ///
  /// Non promette niente e non premia una prestazione: dice una cosa che ha
  /// senso solo a quell'ora, ed e' per questo che a quell'ora appartiene.
  static const Map<Maestro, List<String>> righeDelRisveglio = {
    Maestro.medora: [
      'Sei qui nell\'ora in cui il giorno non ha ancora preso una forma. '
          'Quello che decidi adesso non deve correggere niente.',
      'A quest\'ora il giorno è ancora tutto davanti e nessuna delle sue ore '
          'è già occupata da qualcosa che non hai scelto.',
      'La luce di adesso è la stessa di ogni mattina, ma il giorno che apre '
          'non è mai lo stesso.',
      'Chi guarda il cielo presto sa una cosa in più sul resto della '
          'giornata: da dove arriva la luce.',
    ],
    Maestro.aura: [
      'Il corpo a quest\'ora è ancora vicino al sonno e sente più di '
          'quanto sentirà fra un\'ora.',
      'Sei arrivato prima che il rumore cominciasse. Il respiro che hai contato '
          'adesso lo hai contato nel silenzio.',
      'A quest\'ora il corpo non ha ancora preso le abitudini del giorno: '
          'quello che gli chiedi adesso lo ascolta meglio.',
      'La prima cosa che il corpo ha fatto oggi l\'hai scelta tu e questo '
          'succede raramente.',
    ],
    Maestro.caligo: [
      'Il segno tracciato nella prima ora resta più a lungo, perché non ha '
          'ancora niente accanto con cui confondersi.',
      'A quest\'ora l\'ombra è lunga e il contorno delle cose si vede meglio '
          'che a mezzogiorno.',
      'Sei arrivato quando il giorno era ancora chiuso. Quello che hai portato '
          'con te lo hai scelto al buio.',
      'La soglia si attraversa una volta sola per giorno e tu l\'hai '
          'attraversata adesso.',
    ],
  };

  /// Le forme di un Maestro.
  static List<FormaDelRito> perMaestro(Maestro maestro) =>
      forme.where((f) => f.maestro == maestro).toList(growable: false);

  /// Quante combinazioni produce tutto il corpus.
  static int get combinazioniTotali =>
      forme.fold(0, (somma, f) => somma + f.combinazioni);

  /// IL PANNELLO FONTI E METODO, nella forma gia' usata dall'Estrazione Rune:
  /// separa cio' che e' antico da cio' che e' nostro, senza spacciare l'uno per
  /// l'altro.
  static const String fontiEMetodo =
      "Antico. Il rito del mattino rivolto alla luce che sorge è documentato in "
      "più tradizioni indipendenti: la sandhya vandana vedica, preghiera "
      "quotidiana all'alba e al tramonto descritta nei testi brahmanici; la "
      "shacharit ebraica, la preghiera del mattino; la salat al-fajr islamica, "
      "che si compie fra l'aurora e il sorgere del sole. Il respiro contato "
      "appartiene al pranayama, che gli Yoga Sutra di Patanjali elencano come "
      "quarto degli otto membri e che l'Hatha Yoga Pradipika descrive per "
      "tempi e rapporti.\n\n"
      "Moderno, dichiarato come tale. La sequenza fissa di gesto, respiro "
      "contato e parola da portare è una nostra composizione, non una pratica "
      "tramandata: nessuna delle tradizioni citate la prescrive in questa "
      "forma. Anche il Saluto al Sole, che spesso si presenta come antichissimo, "
      "è come sequenza codificata un'invenzione del primo Novecento. I testi "
      "dei riti sono curatela originale dei Maestri, ispirata a queste fonti e "
      "non citazione.\n\n"
      "Cosa non facciamo. Non promettiamo esiti. Un rito del mattino è un modo "
      "di cominciare la giornata con attenzione, non una cura, non una "
      "protezione e non una fortuna: se un testo ti promettesse salute, "
      "guarigione o successo, sarebbe scritto male e vogliamo saperlo.";
}
