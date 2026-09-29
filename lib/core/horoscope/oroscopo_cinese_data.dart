// GENERATO da tool/_gen_oroscopo_cinese.py a partire da docs/corpus/oroscopo_cinese.md.
// Fonte di verita': il corpus. Non modificare a mano: rigenerare dal corpus.

/// Le frasi dell'oroscopo cinese del giorno (ordine ES voce 08), trascritte
/// dal corpus. Le marche del genere `[m|f|n]` si risolvono alla lettura.
abstract final class OroscopoCineseData {
  /// Scheda Generale: il rapporto fra l'animale del giorno e il tuo.
  static const Map<String, List<String>> rapporti = {
    'armonia': [
      'Oggi è il giorno di {animale_giorno}, che nella tradizione cinese si accorda con {animale_tuo}: è una delle sei coppie in armonia. Usalo per ciò che si fa in due: una telefonata rimandata, un accordo da chiudere, un aiuto da chiedere.',
      '{animale_giorno} guida il giorno. Il tuo animale e il suo formano una delle sei armonie: due metà che si completano. Oggi conviene cercare chi ti completa invece di [fare tutto da solo|fare tutto da sola|fare tutto senza aiuto].',
      'Giornata in armonia col tuo animale: il ramo di oggi e quello del tuo anno di nascita sono una coppia che la tradizione chiama "accordo". Non ti regala nulla da sé; ti dice che oggi collaborare costa meno fatica del solito.',
    ],
    'triplaArmonia': [
      '{animale_giorno} e {animale_tuo} appartengono alla stessa terna, il gruppo che la tradizione lega a {elemento_terna}. È un\'intesa più larga di una coppia: oggi funziona ciò che coinvolge un gruppo, una squadra, una famiglia.',
      'Oggi guida {animale_giorno}, che sta nella stessa terna del tuo animale. Nell\'almanacco le terne sono alleanze: vale la pena rimettere insieme persone che da tempo non si parlano.',
      'Il giorno di {animale_giorno} è alleato del tuo anno: siete due dei tre rami che insieme fanno {elemento_terna}. Se hai un progetto che dipende da altri, oggi è un buon giorno per coinvolgerli.',
    ],
    'scontro': [
      'Oggi è il giorno di {animale_giorno}, che sta di fronte al tuo animale: l\'almanacco lo chiama scontro. Non vuol dire che andrà male; vuol dire che le spinte vanno in direzioni opposte. Rimanda le decisioni prese di corsa.',
      'Il ramo di oggi è l\'opposto del tuo. Gli almanacchi cinesi lo scrivono in chiaro: oggi si scontra con {animale_tuo}. Tieni le cose semplici, lascia cadere la discussione che non ti serve vincere.',
      'Giorno di scontro col tuo animale. Nella tradizione è il momento in cui le cose ferme si muovono, anche a strattoni. Se qualcosa si rompe, guarda se non era già incrinato; se qualcosa si sblocca, lascialo andare.',
    ],
    'punizione': [
      'Il ramo di oggi e il tuo sono legati da ciò che la tradizione chiama punizione: non un castigo, un attrito che nasce da un eccesso. Oggi misura il tono. Una parola in più pesa più del solito.',
      'Oggi {animale_giorno} e {animale_tuo} formano una delle tre punizioni. Il consiglio antico è di non forzare: rispetta i tempi degli altri, rispetta anche i tuoi.',
      'Giornata di attrito col tuo animale, secondo l\'almanacco. Controlla due volte ciò che firmi o mandi; la fretta oggi è la parte che si paga.',
    ],
    'punizioneDiSe': [
      'Oggi è il giorno del tuo stesso animale e la tradizione dice che {animale_tuo} con se stesso si punisce: il rischio sei tu contro di te. Non chiederti più di quanto chiederesti [a un amico|a un\'amica|a una persona amica].',
      'Giorno del tuo animale, ma nella forma che l\'almanacco chiama punizione di sé. Se ti accorgi di rimuginare, fermati e fai una cosa con le mani.',
      'Il ramo di oggi è il tuo. Per {animale_tuo} la tradizione lo legge come un giorno in cui ci si inciampa da soli: poche cose, finite bene.',
    ],
    'danno': [
      '{animale_giorno} disturba l\'accordo del tuo animale: la tradizione lo chiama danno. È un fastidio più che un urto. Occhio alle promesse degli altri, verificale prima di contarci.',
      'Oggi il giorno e il tuo anno sono una delle sei coppie del danno. Piccoli intoppi, ritardi, un messaggio frainteso: niente di grave, se non lo ingrandisci.',
      'Giorno di danno per {animale_tuo}, dice l\'almanacco. Proteggi ciò che funziona già; non è il giorno per mettere mano a un equilibrio che regge.',
    ],
    'armoniaChePunisce': [
      'Oggi {animale_giorno} e {animale_tuo} si accordano e si punzecchiano insieme: la tradizione conosce questa coppia doppia. Fidati dell\'intesa, ma metti per iscritto i patti.',
      'Coppia doppia oggi: armonia e attrito nello stesso legame. Lavora con chi ti somiglia, senza dare per scontato che capisca al volo.',
      'Il ramo di oggi e il tuo si cercano e si urtano. Vicinanza sì, confidenza cieca no.',
    ],
    'stessoAnimale': [
      'Oggi è il giorno di {animale_giorno}, il tuo stesso animale: ritorna ogni dodici giorni. Non è un giorno di favore né di sfida; è un giorno in cui ciò che fai porta più il tuo segno.',
      'Il ramo di oggi è il tuo. Fai la cosa che solo tu sai fare nel tuo modo, invece di adattarti a quello degli altri.',
      'Giorno del tuo animale: la tradizione non gli dà un peso particolare. Il peso glielo dai tu: scegli una cosa a cui tieni e mettila per prima.',
    ],
    'nessuno': [
      'Oggi guida {animale_giorno}, che col tuo animale non ha legami nella tradizione: né accordo né urto. Il giorno lo leggi meglio dal suo guardiano, qui sotto.',
      'Fra {animale_giorno} e {animale_tuo} oggi non c\'è un rapporto classico. Vuol dire giornata neutra: quello che ne esce dipende da ciò che ci metti.',
      'Nessun accordo e nessuno scontro fra il giorno e il tuo anno. Buona occasione per le cose ordinarie fatte con cura.',
      'Il ramo di oggi e il tuo non si cercano e non si respingono. Giornata libera dal lato degli animali: segui il consiglio del guardiano.',
      'Oggi {animale_giorno} passa accanto al tuo animale senza toccarlo, dice la tradizione. Nessuna spinta da fuori: il ritmo lo decidi tu.',
    ],
  };

  /// Scheda Generale: il guardiano del giorno, da Stabilire a Chiudere.
  static const List<List<String>> guardiani = [
    [
      'Il guardiano di oggi è Stabilire, il primo dei dodici: il giorno in cui qualcosa si mette in piedi. Comincia il corso, la routine, il progetto che rimandi.',
      'Oggi veglia Stabilire. La tradizione lo vuole per gli inizi e per mettersi in viaggio; lo sconsiglia per rivoltare ciò che è già a terra. Pianta, non sradicare.',
      'Stabilire guida il giorno: buono per prendere un impegno nuovo e dirlo a voce alta. Lascia stare i traslochi di cose pesanti.',
    ],
    [
      'Oggi il guardiano è Togliere: la tradizione lo dedica a ciò che si porta via. Una visita medica, un armadio da svuotare, un debito da chiudere.',
      'Togliere veglia sul giorno. Fai spazio prima di aggiungere: una cosa tolta oggi vale più di tre cose nuove.',
      'Giornata di Togliere, dice l\'almanacco: buona per la cura di te e per chiudere conti in sospeso. Rimanda la partenza se puoi.',
    ],
    [
      'Oggi veglia Pieno, il guardiano del raccolto. È un giorno per festeggiare ciò che c\'è già: una cena con i tuoi, un grazie detto per bene.',
      'Il guardiano Pieno dice abbondanza, non avidità. Adatto a incassare, a fare il punto; non a caricarti di impegni nuovi.',
      'Giorno di Pieno: la tradizione lo vuole per le celebrazioni e i guadagni. Resta dove sei; i traslochi aspettino un altro guardiano.',
    ],
    [
      'Il guardiano di oggi è Livellare: un giorno piano, né favorevole né contrario. Perfetto per aggiustare ciò che è storto.',
      'Oggi veglia Livellare. Non cercare svolte: rimetti in pari la casa, l\'agenda, un rapporto un po\' sbilanciato.',
      'Livellare guida il giorno: le cose ordinarie vanno bene, le deviazioni no. Sistema quello che c\'è prima di aprire altro.',
    ],
    [
      'Oggi veglia Fissare: la tradizione lo lega a ciò che deve restare. Metti per iscritto un piano, fissa una data.',
      'Il guardiano Fissare chiede stabilità. Buono per decidere a mente fredda, cattivo per discutere: se una lite si affaccia, rimandala.',
      'Giorno di Fissare: resta, costruisci, programma. Il viaggio e il confronto duro hanno giorni migliori.',
    ],
    [
      'Il guardiano di oggi è Tenere: la tradizione lo vuole per trattenere, non per lasciare andare. Porta a termine una cosa iniziata.',
      'Oggi veglia Tenere. Custodisci ciò che hai costruito; per compravendite e partenze l\'almanacco consiglia altri giorni.',
      'Tenere guida il giorno: presa salda, pochi movimenti. Pianta un seme, finisci un lavoro, non firmare in fretta.',
    ],
    [
      'Oggi il guardiano è Rompere, il più severo dei dodici: gli almanacchi sconsigliano di cominciare cose importanti. Usalo per chiudere ciò che non regge più.',
      'Rompere veglia sul giorno. Non è un giorno da firme né da inizi; è un giorno per tagliare, buttare, dire di no a ciò che ti pesa.',
      'Giorno di Rompere: la tradizione lo vuole solo per demolire e per curarsi. Tieni leggeri i programmi; le cose nuove aspettino.',
    ],
    [
      'Il guardiano di oggi è Pericolo: la tradizione chiede prudenza con l\'altezza e con l\'acqua. Tradotto oggi: niente rischi fisici inutili, attenzione alla guida.',
      'Oggi veglia Pericolo. Non è un presagio; è un invito alla cautela. Giorno buono per raccoglierti, meno per spostarti.',
      'Pericolo guida il giorno: fai con calma ciò che fai di solito in fretta. Scale, strade, cantieri meritano un occhio in più.',
    ],
    [
      'Oggi veglia Compiere, uno dei guardiani più favorevoli: la tradizione lo vuole per ciò che deve arrivare in fondo. Firma, consegna, conferma.',
      'Il guardiano Compiere porta a termine. Se hai un sì da dare o da chiedere, oggi è il giorno; lascia fuori le discussioni.',
      'Giorno di Compiere: accordi, partenze, inizi di coppia vanno bene secondo l\'almanacco. Evita solo di trascinare qualcuno in una lite.',
    ],
    [
      'Il guardiano di oggi è Raccogliere: la tradizione lo lega al raccolto. Incassa, archivia, fai il bilancio.',
      'Oggi veglia Raccogliere. Non seminare: raccogli. Chiedi il compenso che ti spetta, rimetti in ordine ciò che hai guadagnato.',
      'Raccogliere guida il giorno: buono per imparare e per mettere da parte. Le partenze l\'almanacco le rimanda.',
    ],
    [
      'Oggi veglia Aprire, il guardiano delle porte che si aprono: la tradizione lo vuole per inaugurare, presentarsi, chiedere.',
      'Il guardiano Aprire invita a farti vedere. Manda la candidatura, fai la proposta, apri la porta a chi aspetta.',
      'Giorno di Aprire: buono per gli inizi, secondo l\'almanacco. Lascia chiuso solo ciò che riguarda la terra e i lutti.',
    ],
    [
      'Il guardiano di oggi è Chiudere: la tradizione lo lega al riposo e a ciò che si mette al sicuro. Giornata buona per rientrare in te.',
      'Oggi veglia Chiudere. Niente inaugurazioni, niente grandi richieste; chiudi le falle, salva i file, riposa.',
      'Chiudere guida il giorno: l\'almanacco lo sconsiglia per aprire e per partire. Custodisci ciò che hai, il resto domani.',
    ],
  ];

  /// Che cosa conviene e che cosa no col guardiano, da Stabilire a Chiudere.
  static const List<(String, String)> consigliDelGuardiano = [
    (
      'cominciare un percorso, partire, prendere un incarico',
      'lavori di scavo, grandi spostamenti di cose'
    ),
    (
      'pulire, curarsi, liberarsi del vecchio, piccoli affari',
      'partenze, traslochi, candidature a un incarico'
    ),
    (
      'celebrare, incontri di famiglia, aprire un\'attività, cercare un guadagno',
      'traslochi, lavori di terra, prendere un nuovo incarico'
    ),
    (
      'riparare, sistemare, abbellire',
      'aprire strade nuove (la tradizione dice "scavare canali")'
    ),
    (
      'pianificare, decisioni che devono durare, cerimonie',
      'liti, cause, partenze'
    ),
    (
      'tenere fermo ciò che hai, costruire, piantare, portare a termine',
      'aprire un\'attività, commerciare, traslocare, partire'
    ),
    (
      'demolire il vecchio, cercare cure',
      'ogni cosa importante di buon augurio (gli almanacchi scrivono "诸事不宜", nessuna impresa conviene)'
    ),
    ('cerimonie, raccoglimento', 'salire in alto, andare per mare, traslocare'),
    (
      'aprire, firmare accordi, cominciare un\'unione, partire, traslocare, curarsi',
      'liti e cause'
    ),
    ('incassare, raccogliere i frutti, studiare', 'partire, i riti funebri'),
    (
      'aprire un\'attività, inizi di coppia, entrare in casa nuova, chiedere',
      'lavori di terra, i riti funebri'
    ),
    (
      'riposo, mettere al sicuro, chiudere falle',
      'aprire un\'attività, sposarsi, partire, cercare guadagni'
    ),
  ];

  /// Fortuna, Lavoro e Amore: i Dieci Dei, per scheda e per dio.
  static const Map<String, Map<String, List<String>>> dei = {
    'fortuna': {
      'compagno': [
        'Oggi il giorno ha il tuo stesso elemento: nel BaZi è il Compagno, che divide con te ciò che c\'è. Buono per le spese condivise, meno per i guadagni personali.',
        'Il Compagno di oggi dice: quello che entra, entra per più persone. Se c\'è da dividere, dividi con chiarezza.',
        'Giornata del Compagno sul fronte del denaro: niente colpi di fortuna, qualche spesa in compagnia. Tieni il conto.',
      ],
      'rivale': [
        'Oggi il giorno ti porta il Rivale, che il BaZi chiama "chi prende la ricchezza": prudenza con prestiti, acquisti d\'impulso, offerte troppo belle.',
        'Il Rivale è di turno. Non è un furto annunciato; è la tendenza del denaro a scivolare via. Rimanda la spesa grande.',
        'Giornata del Rivale per la fortuna: qualcuno può chiederti più di quanto conviene dare. Un no gentile oggi vale oro.',
      ],
      'nutrimento': [
        'Oggi il giorno ti porta il Nutrimento: nel BaZi è la vena che produce la ricchezza. Il denaro passa dal tuo lavoro ben fatto, non dalla sorte.',
        'Il Nutrimento è di turno: un buon giorno per vendere ciò che crei o per proporre il tuo talento. Con calma, senza svenderti.',
        'Giornata del Nutrimento sul fronte della fortuna: il guadagno è lento ma pulito. Semina qualcosa che rende nel tempo.',
      ],
      'ufficialeFerito': [
        'Oggi il giorno ti porta l\'Ufficiale Ferito: talento che corre e genera guadagno, a patto di non rompere gli accordi. Un\'idea originale può rendere.',
        'L\'Ufficiale Ferito è di turno: la fortuna passa da un\'iniziativa tua, fuori dagli schemi. Controlla però i contratti: le regole non si saltano.',
        'Giornata dell\'Ufficiale Ferito per il denaro: brillante e impaziente. Spendi la creatività, non il conto in banca.',
      ],
      'ricchezzaIndiretta': [
        'Oggi il giorno ti porta la Ricchezza indiretta: nel BaZi è il denaro delle occasioni. Guarda le proposte che arrivano da strade insolite, con la testa lucida.',
        'La Ricchezza indiretta è di turno: il denaro si muove, entra ed esce. Buon giorno per trattare, non per scommettere.',
        'Giornata di Ricchezza indiretta: un\'entrata fuori dal solito è possibile, una spesa fuori dal solito anche. Decidi tu quale delle due lasciare passare.',
      ],
      'ricchezzaDiretta': [
        'Oggi il giorno ti porta la Ricchezza diretta, il denaro guadagnato con metodo. Buon giorno per sistemare i conti, chiedere un pagamento, risparmiare.',
        'La Ricchezza diretta è di turno: niente colpi di scena, entrate che arrivano da dove devono. Fai il punto e metti da parte qualcosa.',
        'Giornata di Ricchezza diretta sul fronte della fortuna: ciò che hai seminato si può raccogliere. Chiedi ciò che ti spetta.',
      ],
      'setteUccisioni': [
        'Oggi il giorno ti porta le Sette Uccisioni: nel BaZi è la pressione. Sul denaro vuol dire spese imposte, scadenze. Pagale per prime, poi respira.',
        'Le Sette Uccisioni sono di turno: il denaro serve a difenderti, non a crescere. Evita rischi, fai fronte agli impegni.',
        'Giornata delle Sette Uccisioni per la fortuna: qualcuno può pretendere. Rispondi con i numeri alla mano, senza farti mettere fretta.',
      ],
      'ufficialeDiretto': [
        'Oggi il giorno ti porta l\'Ufficiale diretto: il denaro va dove c\'è una regola. Tasse, bollette, una spesa per la tua reputazione.',
        'L\'Ufficiale diretto è di turno: spendere per ciò che ti rende affidabile è un buon uso del denaro oggi. Il resto aspetta.',
        'Giornata dell\'Ufficiale diretto sul fronte della fortuna: ordine prima di tutto. Metti in regola una pratica rimasta indietro.',
      ],
      'sigilloIndiretto': [
        'Oggi il giorno ti porta il Sigillo indiretto: nel BaZi non parla di denaro. La fortuna oggi è un\'intuizione, un\'informazione, non un\'entrata.',
        'Il Sigillo indiretto è di turno: poco movimento sul conto, molto nella testa. Annota l\'idea che ti arriva.',
        'Giornata del Sigillo indiretto: il denaro non è il tema. Investi in ciò che impari, anche solo un\'ora.',
      ],
      'sigilloDiretto': [
        'Oggi il giorno ti porta il Sigillo diretto, che protegge più che arricchire. Buon giorno per chiedere un consiglio a chi ne sa di più.',
        'Il Sigillo diretto è di turno: fortuna come sostegno, da una persona o da un\'istituzione. Accettalo senza sentirti in debito.',
        'Giornata del Sigillo diretto sul fronte del denaro: tranquilla. Custodisci, non rischiare.',
      ],
    },
    'lavoro': {
      'compagno': [
        'Oggi al lavoro c\'è il Compagno: pari grado, colleghi, persone come te. Buono per lavorare in squadra, meno per farsi notare da chi decide.',
        'Il Compagno di oggi dice collaborazione orizzontale. Chiedi aiuto a un collega, offri il tuo.',
        'Giornata del Compagno: al lavoro conta la rete dei pari. Coltivala, senza misurarti.',
      ],
      'rivale': [
        'Oggi al lavoro c\'è il Rivale: concorrenza, qualcuno che punta allo stesso posto. Resta sui fatti e documenta ciò che fai.',
        'Il Rivale è di turno: non tutti giocano a carte scoperte. Condividi le idee con chi conosci bene.',
        'Giornata del Rivale: la competizione si sente. Rispondi col lavoro fatto, non con le parole.',
      ],
      'nutrimento': [
        'Oggi al lavoro c\'è il Nutrimento: il tuo talento lavora con naturalezza. Fai la cosa [in cui sei bravo|in cui sei brava|che ti riesce meglio] e lasciala parlare.',
        'Il Nutrimento è di turno: la qualità del lavoro conta più della fretta. Se c\'è una pressione, la regge la competenza.',
        'Giornata del Nutrimento: buona per creare, scrivere, insegnare. I risultati arrivano senza forzare.',
      ],
      'ufficialeFerito': [
        'Oggi al lavoro c\'è l\'Ufficiale Ferito: idee brillanti, pazienza corta. Con i capi scegli le parole; una critica giusta detta male diventa un problema.',
        'L\'Ufficiale Ferito è di turno: la voglia di cambiare le regole è forte. Proponi il cambiamento per iscritto, non in riunione a caldo.',
        'Giornata dell\'Ufficiale Ferito: creatività sì, sfida all\'autorità no. Tieni il talento dalla parte giusta del tavolo.',
      ],
      'ricchezzaIndiretta': [
        'Oggi al lavoro c\'è la Ricchezza indiretta: occasioni laterali, un contatto nuovo, un progetto non previsto. Ascolta prima di dire no.',
        'La Ricchezza indiretta è di turno: il lavoro cresce attraverso le relazioni. Una telefonata a chi non senti da tempo può aprire qualcosa.',
        'Giornata di Ricchezza indiretta: risorse che sostengono la carriera arrivano da fuori. Accoglile con metodo.',
      ],
      'ricchezzaDiretta': [
        'Oggi al lavoro c\'è la Ricchezza diretta: le risorse ci sono, usale bene. Buon giorno per organizzare budget, tempi, strumenti.',
        'La Ricchezza diretta è di turno: il lavoro concreto sostiene la tua posizione. Chiudi pratiche, consegna.',
        'Giornata di Ricchezza diretta: il lavoro fatto con ordine oggi si nota. Metti in fila le cose.',
      ],
      'setteUccisioni': [
        'Oggi al lavoro ci sono le Sette Uccisioni: pressione, richieste dure, una sfida. Nel BaZi è una forza che mette alla prova; si regge con disciplina.',
        'Le Sette Uccisioni sono di turno: qualcuno alza la voce o la posta. Rispondi con calma e con un piano.',
        'Giornata delle Sette Uccisioni: il lavoro chiede coraggio. Affronta la cosa difficile per prima, finché hai energie.',
      ],
      'ufficialeDiretto': [
        'Oggi al lavoro c\'è l\'Ufficiale diretto: regola, responsabilità, riconoscimento. Buon giorno per parlare con chi decide.',
        'L\'Ufficiale diretto è di turno: correttezza e puntualità contano più del solito. [Presentati preparato|Presentati preparata|Presentati con tutto pronto].',
        'Giornata dell\'Ufficiale diretto: la tua affidabilità è sotto gli occhi di tutti. Mantieni la parola data.',
      ],
      'sigilloIndiretto': [
        'Oggi al lavoro c\'è il Sigillo indiretto: intuizioni, soluzioni non convenzionali, studio personale. [Lavora da solo|Lavora da sola|Lavora in autonomia] su ciò che richiede concentrazione.',
        'Il Sigillo indiretto è di turno: capisci le cose di traverso. Annota, verificherai domani.',
        'Giornata del Sigillo indiretto: meno riunioni, più pensiero. Una competenza nuova vale più di un\'ora di chiacchiere.',
      ],
      'sigilloDiretto': [
        'Oggi al lavoro c\'è il Sigillo diretto: sostegno da un superiore, da un maestro, da un\'istituzione. Chiedi una guida.',
        'Il Sigillo diretto è di turno: buon giorno per formarti, certificarti, farti insegnare.',
        'Giornata del Sigillo diretto: qualcuno ti copre le spalle. Ringrazialo e fai bene la tua parte.',
      ],
    },
    'amoreDonna': {
      'compagno': [
        'Oggi in amore c\'è il Compagno: [amici|amiche|persone amiche], persone come te. Una serata con loro ti restituisce [a te stesso|a te stessa|a te].',
        'Il Compagno di oggi mette la complicità davanti alla passione. Parla alla pari con chi ami.',
        'Giornata del Compagno: il legame è amicizia prima che desiderio. Va bene così.',
      ],
      'rivale': [
        'Oggi in amore c\'è il Rivale: qualcuno si mette in mezzo, o così sembra. Chiedi prima di immaginare.',
        'Il Rivale è di turno: gelosie facili. Non lasciare che un\'ombra diventi una storia.',
        'Giornata del Rivale: occhio alla competizione, anche [con te stesso|con te stessa|con te]. Tieniti stretta la fiducia.',
      ],
      'nutrimento': [
        'Oggi in amore c\'è il Nutrimento: dolcezza, piacere semplice. Cucina per qualcuno, fatti cucinare.',
        'Il Nutrimento è di turno: il legame cresce con i gesti piccoli, non con le dichiarazioni.',
        'Giornata del Nutrimento: tenerezza e calma. Lascia fuori i bilanci di coppia.',
      ],
      'ufficialeFerito': [
        'Oggi in amore c\'è l\'Ufficiale Ferito, che nel BaZi urta la figura del partner: la lingua corre. Una critica di troppo può ferire più del previsto.',
        'L\'Ufficiale Ferito è di turno: bisogno di dire tutto. Dillo con dolcezza; poi ascolta la risposta.',
        'Giornata dell\'Ufficiale Ferito: fascino e insofferenza insieme. Scegli quale mostrare.',
      ],
      'ricchezzaIndiretta': [
        'Oggi in amore c\'è la Ricchezza indiretta, che nel BaZi nutre la figura del partner: un gesto generoso, un\'uscita non programmata.',
        'La Ricchezza indiretta è di turno: il legame si scalda con la sorpresa. Prenditi il tempo per un\'uscita.',
        'Giornata di Ricchezza indiretta: dai qualcosa al rapporto, anche piccolo, senza fare conti.',
      ],
      'ricchezzaDiretta': [
        'Oggi in amore c\'è la Ricchezza diretta: si costruisce. Buon giorno per parlare di progetti concreti insieme.',
        'La Ricchezza diretta è di turno: la cura pratica vale come una carezza. Fai una cosa utile per l\'altro.',
        'Giornata di Ricchezza diretta: la stabilità nutre il legame. Pianifica qualcosa per due.',
      ],
      'setteUccisioni': [
        'Oggi in amore ci sono le Sette Uccisioni: nel BaZi è un\'attrazione forte, a volte scomoda. Senti tutto; decidi con calma.',
        'Le Sette Uccisioni sono di turno: passione e tensione nello stesso respiro. Non farti trascinare in una prova di forza.',
        'Giornata delle Sette Uccisioni: un incontro può colpire. Guarda chi hai davanti per quello che fa, non per quello che promette.',
      ],
      'ufficialeDiretto': [
        'Oggi in amore c\'è l\'Ufficiale diretto, che nel BaZi è la figura del partner: buon giorno per la coppia stabile, per una parola seria.',
        'L\'Ufficiale diretto è di turno: il legame chiede rispetto e parole mantenute. [Se sei solo|Se sei sola|Se non hai un legame], l\'incontro serio viene prima di quello leggero.',
        'Giornata dell\'Ufficiale diretto: impegno, fiducia, presenza. Esserci oggi conta.',
      ],
      'sigilloIndiretto': [
        'Oggi in amore c\'è il Sigillo indiretto: bisogno di spazio tuo. Non è distanza; è ricarica.',
        'Il Sigillo indiretto è di turno: capisci l\'altro senza parole, o credi di capirlo. Verifica con una domanda.',
        'Giornata del Sigillo indiretto: il cuore si ascolta in silenzio. Un\'ora [da solo|da sola|per conto tuo] ti renderà più presente dopo.',
      ],
      'sigilloDiretto': [
        'Oggi in amore c\'è il Sigillo diretto: protezione, cura, famiglia. Lasciati accudire.',
        'Il Sigillo diretto è di turno: il legame è un rifugio. Chiedi un abbraccio senza giustificarti.',
        'Giornata del Sigillo diretto: affetti sicuri, madre, casa. Chiama chi ti vuole bene da sempre.',
      ],
    },
    'amoreUomo': {
      'compagno': [
        'Oggi in amore c\'è il Compagno: amici, fratelli, persone come te. Non trascurare chi ami per stare con loro.',
        'Il Compagno di oggi divide l\'attenzione. Porta la tua compagna dentro la tua cerchia, non accanto.',
        'Giornata del Compagno: più amicizia che romanticismo. Va bene, se lo sai.',
      ],
      'rivale': [
        'Oggi in amore c\'è il Rivale, che nel BaZi contende la figura della partner: gelosie, confronti, un terzo nel discorso. Rassicura invece di competere.',
        'Il Rivale è di turno: non metterti in gara con nessuno per chi ami. Chi resta, resta per scelta.',
        'Giornata del Rivale: prudenza con le parole sulle ex e sugli altri. Oggi pesano.',
      ],
      'nutrimento': [
        'Oggi in amore c\'è il Nutrimento, che nel BaZi genera la figura della partner: gentilezza, piacere, attenzioni. Il legame cresce da ciò che offri.',
        'Il Nutrimento è di turno: cucina, invita, ascolta. Il fascino di oggi è la calma.',
        'Giornata del Nutrimento: dolcezza semplice. Un gesto concreto vale più di un discorso.',
      ],
      'ufficialeFerito': [
        'Oggi in amore c\'è l\'Ufficiale Ferito: brillante, seduttivo, impaziente. Usa l\'ironia, non il sarcasmo.',
        'L\'Ufficiale Ferito è di turno: vuoi stupire. Stupisci con un\'idea, non con una provocazione.',
        'Giornata dell\'Ufficiale Ferito: espressione forte. Di\' ciò che senti, ma lascia spazio alla risposta.',
      ],
      'ricchezzaIndiretta': [
        'Oggi in amore c\'è la Ricchezza indiretta, che nel BaZi è l\'incontro: nuove conoscenze, simpatie leggere. Se sei in coppia, porta la leggerezza a casa.',
        'La Ricchezza indiretta è di turno: occasioni sociali, sguardi. Vivile con onestà verso te e verso chi hai accanto.',
        'Giornata di Ricchezza indiretta: il cuore si muove. Scegli dove fermarlo.',
      ],
      'ricchezzaDiretta': [
        'Oggi in amore c\'è la Ricchezza diretta, che nel BaZi è la compagna stabile: buon giorno per la coppia, per un progetto comune.',
        'La Ricchezza diretta è di turno: il legame chiede presenza costante, non gesti eclatanti. Esserci basta.',
        'Giornata di Ricchezza diretta: [se sei solo|se sei sola|se non hai un legame], un incontro serio conta più di dieci leggeri.',
      ],
      'setteUccisioni': [
        'Oggi in amore ci sono le Sette Uccisioni: pressioni esterne tolgono spazio al legame. Proteggi un\'ora solo per voi due.',
        'Le Sette Uccisioni sono di turno: nervi tesi. Non portare a casa la battaglia del giorno.',
        'Giornata delle Sette Uccisioni: chi ami ti vede sotto sforzo. Dillo, invece di chiuderti.',
      ],
      'ufficialeDiretto': [
        'Oggi in amore c\'è l\'Ufficiale diretto: doveri, reputazione, impegni. Il legame passa in secondo piano; non lasciarlo sparire.',
        'L\'Ufficiale diretto è di turno: correttezza e parola data valgono anche in coppia. Mantieni ciò che hai promesso.',
        'Giornata dell\'Ufficiale diretto: amore responsabile. Un gesto di affidabilità rassicura più di un fiore.',
      ],
      'sigilloIndiretto': [
        'Oggi in amore c\'è il Sigillo indiretto: bisogno di pensare, di [stare un po\' da solo|stare un po\' da sola|stare un po\' per conto tuo]. Dillo, così non sembra distanza.',
        'Il Sigillo indiretto è di turno: intuizioni sull\'altro. Chiedi conferma prima di agire.',
        'Giornata del Sigillo indiretto: il legame si nutre di silenzio condiviso. Anche stare accanto senza parlare vale.',
      ],
      'sigilloDiretto': [
        'Oggi in amore c\'è il Sigillo diretto: cura, famiglia, radici. Una visita ai tuoi o una cena a casa.',
        'Il Sigillo diretto è di turno: lasciati accudire senza orgoglio.',
        'Giornata del Sigillo diretto: il legame è protezione reciproca. Chiedi e offri sostegno.',
      ],
    },
    'amoreNeutro': {
      'compagno': [
        'Oggi in amore c\'è il Compagno: amicizia e complicità. Parla alla pari con chi ami.',
        'Il Compagno di oggi ricorda che anche gli amici sono affetti. Dagli tempo.',
        'Giornata del Compagno: il legame è prima di tutto alleanza.',
      ],
      'rivale': [
        'Oggi in amore c\'è il Rivale: facile sentirsi in competizione. Chiedi prima di immaginare.',
        'Il Rivale è di turno: gelosie a portata di mano. Scegli la fiducia.',
        'Giornata del Rivale: non metterti in gara per chi ami.',
      ],
      'nutrimento': [
        'Oggi in amore c\'è il Nutrimento: dolcezza e gesti semplici. Cucina, invita, ascolta.',
        'Il Nutrimento è di turno: il legame cresce da ciò che offri con calma.',
        'Giornata del Nutrimento: piacere semplice, niente bilanci.',
      ],
      'ufficialeFerito': [
        'Oggi in amore c\'è l\'Ufficiale Ferito: la lingua corre. Una parola dolce vale più di una giusta.',
        'L\'Ufficiale Ferito è di turno: bisogno di dire tutto. Dillo, poi ascolta.',
        'Giornata dell\'Ufficiale Ferito: fascino e insofferenza. Scegli quale mostrare.',
      ],
      'ricchezzaIndiretta': [
        'Oggi in amore c\'è la Ricchezza indiretta: incontri, sorprese, uscite fuori programma.',
        'La Ricchezza indiretta è di turno: il cuore si muove. [Resta onesto|Resta onesta|Mantieni l\'onestà] con te e con chi hai accanto.',
        'Giornata di Ricchezza indiretta: dai qualcosa al legame, senza contare.',
      ],
      'ricchezzaDiretta': [
        'Oggi in amore c\'è la Ricchezza diretta: si costruisce. Parla di progetti concreti.',
        'La Ricchezza diretta è di turno: la cura pratica vale come una carezza.',
        'Giornata di Ricchezza diretta: la stabilità nutre il legame.',
      ],
      'setteUccisioni': [
        'Oggi in amore ci sono le Sette Uccisioni: attrazione forte o tensione forte. Senti tutto, decidi con calma.',
        'Le Sette Uccisioni sono di turno: non trasformare il legame in una prova di forza.',
        'Giornata delle Sette Uccisioni: guarda chi hai davanti per quello che fa.',
      ],
      'ufficialeDiretto': [
        'Oggi in amore c\'è l\'Ufficiale diretto: impegno, parola data, fiducia.',
        'L\'Ufficiale diretto è di turno: esserci oggi conta più di qualunque gesto.',
        'Giornata dell\'Ufficiale diretto: amore serio, poche parole mantenute.',
      ],
      'sigilloIndiretto': [
        'Oggi in amore c\'è il Sigillo indiretto: bisogno di spazio proprio. Dillo, così non sembra distanza.',
        'Il Sigillo indiretto è di turno: intuisci l\'altro. Verifica con una domanda.',
        'Giornata del Sigillo indiretto: anche il silenzio condiviso è vicinanza.',
      ],
      'sigilloDiretto': [
        'Oggi in amore c\'è il Sigillo diretto: cura, casa, famiglia. Lasciati accudire.',
        'Il Sigillo diretto è di turno: il legame è un rifugio. Chiedi un abbraccio.',
        'Giornata del Sigillo diretto: chiama chi ti vuole bene da sempre.',
      ],
    },
  };

  /// La spiegazione di una riga di ognuno dei Dieci Dei.
  static const Map<String, String> spiegazioni = {
    'compagno':
        'il giorno ha il tuo stesso elemento con la tua stessa polarità',
    'rivale':
        'il tuo stesso elemento, con polarità opposta: contende ciò che hai',
    'nutrimento':
        'il tuo elemento lo genera, stessa polarità: ciò che produci con calma',
    'ufficialeFerito':
        'il tuo elemento lo genera, polarità opposta: espressione che rompe le regole',
    'ricchezzaIndiretta':
        'il tuo elemento lo governa, stessa polarità: guadagni che arrivano di lato',
    'ricchezzaDiretta':
        'il tuo elemento lo governa, polarità opposta: il guadagno regolare',
    'setteUccisioni':
        'governa il tuo elemento, stessa polarità: pressione, sfida',
    'ufficialeDiretto':
        'governa il tuo elemento, polarità opposta: regola, responsabilità, riconoscimento',
    'sigilloIndiretto':
        'genera il tuo elemento, stessa polarità: sostegno insolito, intuizione',
    'sigilloDiretto':
        'genera il tuo elemento, polarità opposta: protezione, studio, cura',
  };

  /// La riga del colore e dei numeri.
  static const List<String> coloreENumeri = [
    'Il giorno è di {elemento}: il suo colore nella tradizione è il {colore}, i suoi numeri {numeri}.',
    'Elemento del giorno: {elemento}. Colore {colore}, numeri {numeri}, secondo la figura dello He Tu.',
    'Oggi governa {elemento}. Nella tradizione cinese gli appartengono il {colore} e i numeri {numeri}.',
  ];
  static const List<String> direzioneGioia = [
    'Gli almanacchi mettono oggi il Dio della Gioia a {direzione_gioia}: se puoi, metti da quella parte l\'appuntamento che conta.',
    'Direzione del giorno: {direzione_gioia}, dove l\'almanacco colloca il Dio della Gioia.',
    'Il Dio della Gioia oggi sta a {direzione_gioia}, secondo il calendario cinese. Un gesto simbolico: [siediti rivolto da quella parte|siediti rivolta da quella parte|siediti guardando verso quella parte] quando decidi.',
  ];
  static const List<String> direzioneRicchezza = [
    'L\'almanacco pone oggi il Dio della Ricchezza a {direzione_ricchezza}.',
    'Direzione della ricchezza oggi: {direzione_ricchezza}, secondo il calendario cinese.',
    'Il Dio della Ricchezza, dicono gli almanacchi, oggi sta a {direzione_ricchezza}.',
  ];
  static const String notaGenerale =
      'L\'animale del giorno è il ramo del giorno nel ciclo dei sessanta; il rapporto col tuo animale viene dalle tabelle del Sanming Tonghui (1578). Il guardiano è uno dei dodici del calendario, contato dal mese solare; il consiglio viene dal solo guardiano, non dall\'almanacco intero.';
  static const String notaDei =
      'Il tuo giorno di nascita ha un tronco celeste, il giorno di oggi un altro: il loro rapporto fra i cinque elementi dà uno dei Dieci Dei del BaZi. La scheda legge quel dio come lo leggono lo Yuanhai Ziping e il Ziping Zhenquan.';
  static const String notaColore =
      'Colore e numeri sono quelli dell\'elemento del giorno nella tradizione, non colori o numeri portafortuna.';
}
