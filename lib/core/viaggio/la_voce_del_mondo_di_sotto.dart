import '../responsi/filo_della_voce.dart';
import '../tempo/confine_del_giorno.dart';
import 'la_domanda_del_viaggio.dart';
import 'scena_del_viaggio.dart';

/// **LA VOCE DEL MONDO DI SOTTO: la scena diventa una risposta.**
/// Ordine DG voce 07, 11 settembre 2026.
///
/// **IL DIFETTO, con le parole del fondatore:** *"le risposte fanno cagare,
/// scarne e non seguono le regole delle risposte"*.
///
/// **Aveva ragione, e si vede dal codice prima ancora che a schermo.** La
/// risposta del Viaggio era **una frase sola**, composta di apertura piu'
/// corpo piu' chiusura: *"Dal Mondo di Sotto: Ti porta alla cima sotto la
/// pioggia. C'e' l'ombra che non e' tua. Il resto viene da se'."* Una riga, e
/// dentro non c'era niente di cio' che le regole di casa pretendono.
///
/// **LE REGOLE, che sono gia' scritte e non si inventano qui:**
///
/// - **Ordine S voce 15**: il responso parla **alla persona e alla sua
///   domanda**, in seconda persona, con parole comuni. Il simbolo entra
///   **dopo**. La scena invece apriva col simbolo e la domanda non compariva
///   mai.
/// - **Ordine S voce 16**: la risposta, **cosa puoi fare**, **da dove viene**,
///   e la tradizione fuori dal responso. Di questi quattro ce n'era mezzo.
/// - **Gerarchia dettata dal fondatore il 3 settembre**: titolo diretto che a
///   colpo d'occhio e' gia' una risposta, poi la risposta vera, la fonte breve
///   e verso la fine.
///
/// **COSA CAMBIA IN CONCRETO.** Quattro pezzi al posto di una riga:
///
/// 1. **il titolo**, che e' gia' una risposta e si legge da solo;
/// 2. **la risposta**, che nomina **la domanda con cui sei sceso**;
/// 3. **cosa puoi fare**, un gesto solo e concreto;
/// 4. **da dove viene**, cioe' la scena che hai visto, che e' la fonte.
///
/// **PERCHE' TANTE FORME CORTE E NON POCHE LUNGHE.** E' la lezione misurata
/// dell'ordine DF: le forme lunghe alzano la varieta' degli scheletri **e
/// peggiorano** la somiglianza a coppie, perche' regalano sequenze di parole
/// identiche a ogni confronto. Molte forme corte fanno tutte e due le cose
/// insieme, perche' una frase di quattro parole non produce nessuna sequenza
/// di cinque.
abstract final class LaVoceDelMondoDiSotto {
  /// **VENTIQUATTRO TITOLI PER TEMA DELLA DOMANDA.**
  ///
  /// Non uno per scena: **uno per quello che la persona e' venuta a chiedere**.
  /// Un titolo che nominasse il luogo del sogno sarebbe un titolo sulla scena,
  /// e la scena non e' la risposta: e' da dove viene.
  ///
  /// **SCRITTI DAL FONDATORE, ordine DJ voce 01**, 13 settembre 2026, e
  /// nell'ordine in cui li ha scritti. Erano otto: con una discesa al giorno
  /// sullo stesso tema lo stesso titolo tornava ogni otto giorni, e il titolo
  /// e' la prima cosa che si legge. Nel tema *finito* c'era un doppione, *"Resta
  /// quello che hai imparato"* e *"Quello che hai imparato resta"*: il secondo
  /// e' uscito. **Tre titoli hanno la forma che rispetta le regole di casa**:
  /// *"Non ti serve essere sicuro"* e *"Se arrivasse domani, saresti pronto"*
  /// dicevano a chi legge di essere un uomo, e sono *"Non ti serve la
  /// certezza"* e *"Se arrivasse domani, avresti tutto pronto"*; *"E' finito,
  /// e va bene cosi'"* aveva la virgola davanti alla *e*, ed e' rimasto *"E'
  /// finito: va bene cosi'"*, com'era gia'.
  static const Map<String, List<String>> titoliPerTema = {
    'scelta': [
      'Hai già una preferenza',
      'Il rischio è più piccolo di così',
      'Decidi come se dovessi rifarlo',
      'Non è per sempre',
      'La strada la scegli tu',
      'Una delle due è già più tua',
      'Non sono uguali come sembrano',
      'Scegli quella che puoi rifare',
      'Nessuna delle due è sbagliata',
      'Stai già scegliendo, piano',
      'Il tempo che ci metti dice qualcosa',
      'Prova la più piccola',
      'Chiedi a chi ci è passato',
      'Metti una data e scegli',
      'Quella che ti spaventa la conosci',
      'Due strade, un solo te',
      'Puoi tornare indietro da entrambe',
      'Non ti serve la certezza',
      'Quella che racconteresti meglio',
      'Decidi oggi, correggi domani',
      'Hai più informazioni di quante credi',
      'La paura non è un argomento',
      'Scegli e poi difendila',
      'Una si può provare, l\'altra no',
    ],
    'persona': [
      'Chiedilo, invece di dedurlo',
      'Conta il tempo, non le parole',
      'Sei tu a dover scegliere quanto',
      'Il silenzio dice qualcosa anche lui',
      'Il posto ce l\'ha già',
      'Guarda cosa fa, non cosa dice',
      'La distanza è un\'informazione',
      'Non devi decidere per due',
      'Dille quello che non dici',
      'Sei tu che stai aspettando',
      'Chiedile come sta, davvero',
      'Non ti serve un nome per questo',
      'Guarda quanto spazio le lasci',
      'Quello che fa quando non deve',
      'Sta a te fare il primo passo',
      'Non è tenuta a indovinare',
      'Quanto la pensi è la risposta',
      'Una domanda vale sei mesi',
      'Puoi volerle bene e stare lontano',
      'Non leggi male, leggi poco',
      'Lasciale il tempo che chiedi per te',
      'Se ti manca, è già detto',
      'Non deve essere reciproco per valere',
      'Chiudi la porta oppure aprila',
    ],
    'blocco': [
      'Ti manca un pezzo piccolo',
      'Non serve la forza',
      'Lascialo lì e vai avanti',
      'È già successo altre volte',
      'Non è un muro, è una porta stretta',
      'Ci torni perché non è finito',
      'Il blocco tiene qualcosa al sicuro',
      'Girala invece di spingerla',
      'Non sei tu il problema',
      'Fallo male, ma fallo',
      'Manca una persona, non uno sforzo',
      'Comincia dalla parte più piccola',
      'È fermo perché lo tieni',
      'Ti sta proteggendo da qualcosa',
      'Riposati: è lavoro anche quello',
      'Prova da un altro lato',
      'Non serve capirlo per muoverlo',
      'Lo hai già sciolto una volta',
      'Chiedi aiuto e basta',
      'Togli, invece di aggiungere',
      'Il primo passo è ridicolo, fallo',
      'Non è pigrizia',
      'Spingi meno, gira di più',
      'Quello che eviti è una riga sola',
    ],
    'attesa': [
      'Muovi qualcosa di piccolo',
      'Il tempo sta facendo la sua parte',
      'Non è colpa tua se tarda',
      'Guarda altrove per una settimana',
      'L\'attesa sta lavorando',
      'Non è fermo, è lento',
      'Datti una data',
      'Smetti di guardare la porta',
      'Non sei in ritardo',
      'Intanto prepara il dopo',
      'Smetti di controllare ogni giorno',
      'Sta arrivando, ma non oggi',
      'La tua vita non è in pausa',
      'Fissa il giorno in cui smetti',
      'Non dipende da te',
      'Se arrivasse domani, avresti tutto pronto',
      'Occupa le mani',
      'Chiedi a che punto siamo',
      'Aspettare non è perdere',
      'Quello che aspetti è già cambiato',
      'Non tutto quello che tarda arriva',
      'Un mese, poi decidi',
      'Guarda cosa è cresciuto intanto',
      'Il silenzio non è un no',
    ],
    'direzione': [
      'Parti da dove non vuoi andare',
      'Prova una strada per un mese',
      'Il movimento chiarisce',
      'Non serve la mappa intera',
      'Il passo prima della mappa',
      'Segui quello che ti tira',
      'Una direzione basta per oggi',
      'Non ti serve vedere la fine',
      'Comincia e la strada si vede',
      'Sai dove non vuoi stare',
      'Non ti serve la strada giusta',
      'Guarda da dove vieni',
      'Chiedi che cosa ti diverte',
      'Fai un mese di prova',
      'La meta cambia, il passo no',
      'Segui chi vorresti essere',
      'Non ti manca il coraggio, manca il permesso',
      'Scegli il primo chilometro',
      'Fermarti è già una direzione',
      'Vai dove ti chiamano',
      'Nessuno ti chiede la mappa',
      'Quello che rimandi indica la via',
      'Meno strade, più strada',
      'Cammina e poi correggi',
    ],
    'finito': [
      'Non devi capirla tutta',
      'Resta quello che hai imparato',
      'Il lutto è lavoro anche lui',
      'Fai spazio a quello che viene',
      'È finito: va bene così',
      'Lascia che resti indietro',
      'Chiudi la porta piano',
      'È finito davvero',
      'Non devi fare in fretta',
      'Ringrazia e chiudi',
      'Ti manca chi eri lì',
      'Non c\'è niente da salvare',
      'Lascia il posto vuoto per ora',
      'Puoi essere triste e stare bene',
      'Non tornare a controllare',
      'Finire richiede tempo, come costruire',
      'Quello che hai dato non si perde',
      'Non era sbagliato, era finito',
      'Comincia qualcosa di piccolo',
      'Non deve avere un senso adesso',
      'Tieni una cosa, lascia il resto',
      'Il dolore non misura l\'errore',
      'Un giorno sarà solo una storia',
      'Non sei tu che devi farlo finire',
    ],
  };

  /// Se il tema non è dei sei, il titolo viene da qui.
  static const List<String> titoliSenzaDomanda = [
    'Quello che hai visto di là',
    'Quello che hai riportato su',
    'Il Mondo di Sotto ti ha risposto',
    'Te lo sei portato dietro',
  ];

  /// **IL TEMA IN DUE PAROLE**, per le riprese corte.
  ///
  /// **Perche' esiste.** *Un blocco che non si supera* e' sei parole, e
  /// tornava in ognuna delle otto riprese: sei parole identiche regalano due
  /// sequenze di cinque a ogni confronto, e la misura C di quella domanda
  /// restava al 42,9 per cento mentre le altre cinque erano scese sotto il
  /// trenta. Qui il tema si nomina in due parole, e meta' delle riprese usano
  /// questa forma.
  static const Map<String, String> temaInDueParole = {
    'scelta': 'la scelta',
    'persona': 'quella persona',
    'blocco': 'il blocco',
    'attesa': 'l\'attesa',
    'direzione': 'la direzione',
    'finito': 'quello che è finito',
  };

  /// **DODICI MODI DI RIPRENDERE LA DOMANDA**, e nessuno la ripete.
  ///
  /// `{tema}` e' il tema, in minuscolo: *una scelta da fare*, *un blocco che
  /// non si supera*.
  ///
  /// **RISCRITTE CON L'ORDINE DI VOCE 05**, e ognuna per un difetto visto.
  /// *"Con te e' scesa {tema}"* diventava *"Con te e' scesa un tempo che non
  /// arriva"*; *"Hai chiesto di {breve}"* diventava *"Hai chiesto di la
  /// scelta"*; *"Te la porti dietro da un po', {breve}"* diventava *"Te la
  /// porti dietro, il blocco"*; e *"Sei sceso"* diceva a ogni donna che
  /// leggeva di essere un uomo. **Nessuna forma accorda piu' niente col tema**,
  /// e nessuna ha un participio riferito a chi legge.
  static const List<String> riprendeLaDomanda = [
    'Hai portato giù {tema}.',
    'Nella discesa avevi con te {tema}.',
    'La tua domanda era {tema}.',
    'Hai affidato alla discesa {tema}.',
    // **QUESTE USANO IL TEMA IN DUE PAROLE**, e non e' una svista: vedi la
    // nota su [temaInDueParole].
    'La domanda riguardava {breve}.',
    'Quello che ti pesa è {breve}.',
    'Il tuo pensiero era {breve}.',
    'Sotto hai guardato {breve}.',
    'Giù ti aspettava {breve}.',
    'Da un po\' ti porti dietro {breve}.',
    'Il motivo della discesa era {breve}.',
    'Sotto hai portato {tema}.',
  ];

  /// **OTTO RISPOSTE PER TEMA, corte e in seconda persona.**
  static const Map<String, List<String>> rispostePerTema = {
    'scelta': [
      'Nessuna delle due ti chiude le altre porte.',
      'Hai già scelto una volta senza pentirtene.',
      'Il tempo che ci stai mettendo è già una risposta.',
      'Chiedi a te stesso quale racconterai meglio fra dieci anni.',
      'Non stai scegliendo fra due cose: stai scegliendo chi diventi dopo.',
      'Una delle due la stai già facendo, in piccolo, da settimane.',
      'Il costo di sbagliare è più basso di quanto lo stai contando.',
      'Aspetti un segno che dica quale. Non arriverà, ma va bene.',
      'La paura è di perdere l\'altra, non di prendere questa.',
      'Se fossero davvero uguali, avresti già scelto.',
      'Chiediti quale delle due puoi ancora cambiare fra un mese.',
      'Stai cercando la giusta: cerca quella che sai portare avanti.',
    ],
    'persona': [
      'Le stai dando un peso che lei non sa di avere.',
      'Puoi tenerla vicino senza sapere che posto ha.',
      'Se ci pensi ogni giorno, il posto ce l\'ha già.',
      'Una conversazione breve vale sei mesi di ipotesi.',
      'Il posto che ha per te lo sai già: quello che manca è dirlo.',
      'Stai aspettando che sia lei a nominare la cosa.',
      'Quanto tempo le dedichi dice più di quanto ci pensi.',
      'La domanda vera non è che posto ha: è quanto te ne manca.',
      'Non serve una definizione per trattarla bene.',
      'Se dovessi allontanarti, sapresti già cosa perdi.',
      'Le stai chiedendo una risposta che tocca a te.',
      'Guarda cosa fa quando non deve.',
    ],
    'blocco': [
      'Non è un blocco: stai tenendo due cose insieme.',
      'Il pezzo che manca lo hai già usato altrove.',
      'Prova a farlo male, tanto per farlo.',
      'Chiedi aiuto: è la parte che stai saltando.',
      'Ci torni perché non è chiuso, non perché sei debole.',
      'Quel blocco sta proteggendo qualcosa che non vuoi guardare.',
      'Non si supera di slancio: si gira intorno.',
      'L\'hai già superato altre volte, in altre forme.',
      'Il pezzo che manca è piccolo e non è la forza.',
      'Stai spingendo su una porta che si apre tirando.',
      'Non è un muro: è una porta stretta. Ci passi se lasci qualcosa.',
      'Chiediti che cosa succederebbe se lo lasciassi lì.',
    ],
    'attesa': [
      'Aspettare bene è diverso da aspettare e basta.',
      'Nel frattempo puoi preparare quello che serve dopo.',
      'La tua vita non si è messa in pausa con lei.',
      'Se arrivasse domani, sapresti che cosa fare?',
      'Non è fermo: è lento. Non è la stessa cosa.',
      'L\'attesa sta facendo un lavoro che non vedi.',
      'Stai guardando la porta: intanto la finestra è aperta.',
      'Datti una data. Se passa, hai la tua risposta.',
      'Quello che aspetti è già cambiato mentre aspettavi.',
      'Non tutto quello che tarda sta per arrivare.',
      'L\'attesa costa meno se smetti di controllarla ogni giorno.',
      'Muovi una cosa piccola adesso, invece di aspettare quella grande.',
    ],
    'direzione': [
      'Una direzione si trova camminando, non da fermi.',
      'Guarda quanta strada hai già fatto senza accorgertene.',
      'Le direzioni buone all\'inizio sembrano tutte piccole.',
      'Non ti manca la meta: ti manca il permesso.',
      'Non ti serve la mappa: ti serve il primo passo.',
      'Segui quello che ti tira, non quello che ti conviene.',
      'Una direzione per oggi basta: domani la correggi.',
      'Sai benissimo dove non vuoi andare: parti da lì.',
      'Stai cercando la strada giusta e ti basterebbe una strada.',
      'Chi non sa dove va arriva spesso dove voleva.',
      'Il punto non è la meta: è che ti stai fermando.',
      'Prova una direzione per un mese, come si prova una scarpa.',
    ],
    'finito': [
      'Finire è un lavoro. Lo stai facendo.',
      'Non devi rimpiazzarla subito con qualcosa.',
      'Quello che ti manca non è la cosa: è chi eri lì.',
      'Ringraziala, anche se è finita male.',
      'È finito. Non sei tu che devi farlo finire.',
      'Quello che hai imparato lì non finisce con la cosa.',
      'Stai tenendo aperta una porta per non sentire il rumore.',
      'La fine non cancella: mette da parte.',
      'Non ti serve capirla tutta per lasciarla andare.',
      'Il lutto è la parte del lavoro che nessuno ti conta.',
      'Chiudila piano. Poi non tornarci a controllare.',
      'Qualcosa comincia solo se questa finisce davvero.',
    ],
  };

  /// **OTTO CODE DELLA RISPOSTA, cortissime.**
  ///
  /// **Non spiegano niente**: servono a far salire le combinazioni. Otto
  /// riprese per dodici risposte per otto code fanno settecentosessantotto
  /// modi di dire la stessa cosa, e su cento discese la misura D scende sotto
  /// le due.
  static const List<String> codaDellaRisposta = [
    'Lo sai già.',
    'Tienilo presente.',
    'Non è poco.',
    'Vale oggi.',
    'Ed è tutto qui.',
    'Il resto è rumore.',
    'Fidati di questo.',
    'Basta questo.',
    'E non serve altro.',
    'Ci puoi contare.',
    'Non serve altro, per oggi.',
    'Prendilo così.',
  ];

  /// **OTTO APERTURE DEL GESTO, cortissime.**
  static const List<String> apreIlGesto = [
    'Una cosa sola:',
    'Il passo di oggi:',
    'Da dove cominci:',
    'Quello che puoi fare:',
    'Comincia da qui:',
    'La cosa concreta:',
    // **Qui c'era *"Fai questo:"***, che davanti a *"Fai la telefonata"*
    // diceva lo stesso verbo due volte. Ordine DI voce 05.
    'Il gesto da compiere:',
    'Per muoverti:',
  ];

  /// Le otto risposte per chi è sceso senza domanda.
  static const List<String> risposteSenzaDomanda = [
    // **Qui c'erano *"Sei sceso per incontrarlo"*, *"Sei andato a
    // guardare"* e *"Sei sceso senza niente in mano"***: tre participi al
    // maschile per chiunque legga. Ordine DI voce 05.
    'La discesa era l\'incontro. L\'incontro è avvenuto.',
    'Non hai chiesto niente. Hai visto lo stesso.',
    'Oggi il Mondo di Sotto ti ha mostrato e basta.',
    'Non tutte le discese hanno una domanda.',
    'Hai voluto soltanto vedere. È già qualcosa.',
    'Nessuna domanda: solo la scena. Quella ti resta.',
    'Hai fatto la discesa a mani vuote. È un modo anche questo.',
    'Questa volta il viaggio era il viaggio.',
  ];

  /// **VENTI GESTI, uno solo per risposta e sempre concreto.**
  ///
  /// Ordine S voce 16, *cosa puoi fare*: non un consiglio di vita, **una cosa
  /// che si fa oggi**.
  static const List<String> cosaPuoiFare = [
    'Scrivi la domanda su un foglio e mettila dove la rivedi.',
    'Dilla a una persona sola. Guarda come suona fuori.',
    'Datti tre giorni. Alla fine scegli comunque.',
    'Fai la cosa più piccola che va in quella direzione.',
    'Togli una cosa dalla lista, invece di aggiungerne una.',
    'Chiedi a qualcuno che ci è già passato.',
    'Segnati oggi sul calendario. Torna a guardarlo fra un mese.',
    'Smetti di cercare informazioni: ne hai già abbastanza.',
    'Metti un limite di tempo, poi rispettalo.',
    'Rimanda solo quello che puoi rimandare davvero.',
    'Fai la telefonata che stai rimandando.',
    'Dormici una notte e rileggi questa riga domattina.',
    'Manda un messaggio, anche corto, a chi sai tu.',
    'Prendi carta e penna e scrivi le due colonne.',
    'Esci a camminare trenta minuti senza telefono.',
    'Riguarda com\'è andata l\'ultima volta che hai deciso così.',
    'Fissa un incontro invece di pensarci ancora.',
    'Butta via una cosa che tieni per abitudine.',
    'Metti per iscritto che cosa ti farebbe dire di no.',
    'Fai una prova piccola, che puoi annullare.',
  ];

  /// **OTTO MODI DI DIRE QUANDO**, che si attaccano al gesto.
  ///
  /// **Perche' il gesto si compone invece di essere una frase intera.** Con
  /// dodici frasi intere la misura D dava dodici ripetizioni su cento; venti
  /// gesti per otto tempi fanno centosessanta combinazioni, e la misura scende
  /// sotto le due. E' la lezione dell'ordine DF: **molte forme corte**.
  static const List<String> quando = [
    'Oggi.',
    'Entro stasera.',
    'Prima che finisca la settimana.',
    'Domani mattina, appena ti alzi.',
    'Adesso, finché ce l\'hai in mente.',
    'Nei prossimi tre giorni.',
    'Alla prima occasione buona.',
    'Prima di tornare a pensarci.',
  ];

  /// **OTTO MODI DI DIRE DA DOVE VIENE.** `{scena}` è la scena vista.
  ///
  /// Ordine S voce 16, *da dove viene*: la scena non è la risposta, è la
  /// **fonte** della risposta, e sta verso la fine come dice la gerarchia.
  ///
  /// **NESSUNA FINISCE PIU' COI DUE PUNTI, ordine DI voce 05.** Le otto forme
  /// finivano tutte e otto coi due punti, e la scena che seguiva cominciava
  /// spesso con un'apertura che li aveva anche lei: a schermo *"Da dove nasce:
  /// Quello che e' successo di la': Vi trovate al ponte nella notte."* Adesso
  /// il blocco dice da dove viene con una frase intera, e la scena lo segue
  /// **senza la sua apertura**, che e' `ScenaDelViaggio.testoSenzaApertura`.
  static const List<String> daDoveViene = [
    'Viene da ciò che hai visto. {scena}',
    'Te lo dice la scena che hai visto. {scena}',
    'Nasce da qui. {scena}',
    'L\'hai vista così. {scena}',
    'Il Mondo di Sotto te l\'ha detto così. {scena}',
    'Sotto era così. {scena}',
    'La scena era questa. {scena}',
    'E l\'hai riportata su così. {scena}',
  ];

  /// **IL GIRO DELLA VOCE.** Ordine DI voce 16, 13 settembre 2026.
  ///
  /// **LA MISURA CHE LO FA NASCERE.** La prova a cento discese, cento giorni
  /// consecutivi con la stessa domanda, ha trovato il titolo ripetuto **fino
  /// a trenta volte** e la risposta e il gesto fino a tre, contro le due che
  /// l'ordine DF concede. La causa non era la lunghezza degli elenchi: ogni
  /// blocco pescava **a caso**, con un filo di hash, e cento pescate a caso
  /// ripetono per forza, anche da mille combinazioni. E' il problema del
  /// compleanno, e nessun elenco lo cura.
  ///
  /// **Adesso la voce del Viaggio gira invece di pescare.** Il giorno della
  /// discesa diventa un numero, i giorni dall'inizio del 2026, e ogni blocco
  /// avanza di un posto al giorno dentro il suo spazio: il titolo dentro le
  /// forme del suo tema, la risposta e il gesto dentro lo spazio delle loro
  /// combinazioni, che ne ha piu' di mille. Prima di tornare su una
  /// combinazione le percorre tutte.
  ///
  /// **E LO SPAZIO E' MESCOLATO**, una volta per sempre e con un seme per
  /// blocco: il posto di domani non e' la combinazione accanto a quella di
  /// oggi, e' una qualunque. La seconda stesura avanzava con un passo fisso
  /// senza mescolare, e i blocchi con lo stesso numero di forme, otto il
  /// titolo, otto l'apertura del gesto e otto il quando, **tornavano in fase**:
  /// a otto giorni di distanza due responsi condividevano quattro pezzi su
  /// sei, e la misura C era al 52 per cento.
  ///
  /// **E' UNA DEROGA DICHIARATA AL FILO DELLA VOCE**, che per le altre arti
  /// nasce da cio' che e' appena uscito e mai da un contatore. La' la
  /// casualita' dell'estrazione basta, perche' le carte e le rune sono tante;
  /// qui il vocabolario della scena e' chiuso, e la stessa persona che scende
  /// ogni giorno con la stessa domanda si accorgerebbe della stessa frase. Il
  /// determinismo resta intero: la stessa discesa, riaperta, dice la stessa
  /// cosa, perche' il giro dipende soltanto dal giorno e da quante discese
  /// c'erano gia' state quel giorno.
  ///
  /// **[giaOggi] E NON IL NUMERO DELLA DISCESA**, e l'errore e' stato fatto e
  /// misurato. La prima stesura sommava trentasette volte il resto del
  /// numero della discesa diviso tre, per separare le due discese dello
  /// stesso giorno che un piano puo' concedere dopo il riconoscimento. Ma il
  /// numero della discesa cresce ogni giorno, e due giorni diversi cadevano
  /// sullo stesso giro: la prova a cento discese ha trovato due responsi
  /// **identici in tutto** fuorche' la scena, e la misura C al 79 per cento.
  /// La seconda discesa dello stesso giorno salta avanti di un numero primo
  /// grande, e cade in un posto che nessun giorno vicino occupa.
  static int giro(DateTime giorno, int giaOggi) =>
      ConfineDelGiorno.giorniDa(DateTime(2026), giorno) +
      giaOggi * _saltoDellaSeconda;

  static const int _saltoDellaSeconda = 1000003;

  /// **IL POSTO DI OGGI** in uno spazio di [quante] forme, per il blocco
  /// [marcatore]: il posto del giro, letto nello spazio mescolato di quel
  /// blocco.
  static int alGiro(int giro, int quante, String marcatore) {
    final mescolato = _mescolati.putIfAbsent(
        '$marcatore/$quante', () => _mescola(quante, marcatore));
    final partenza = FiloDellaVoce.da([marcatore, 'giro']).seme % quante;
    return mescolato[(partenza + giro) % quante];
  }

  static final Map<String, List<int>> _mescolati = {};

  static int _mcd(int a, int b) => b == 0 ? a : _mcd(b, a % b);

  /// **UN POSTO MESCOLATO**: [i] letto nello spazio mescolato di [quante]
  /// posti del blocco [marcatore]. Una permutazione non unisce mai due posti
  /// diversi, quindi cio' che era iniettivo resta iniettivo, e smette di
  /// essere lineare.
  static int mescolato(int i, int quante, String marcatore) =>
      _mescolati.putIfAbsent(
          '$marcatore/$quante', () => _mescola(quante, marcatore))[i % quante];

  /// **LO SPAZIO MESCOLATO**: i numeri da zero a [quante], in un ordine fisso
  /// che dipende soltanto da [marcatore]. Fisher e Yates, col filo come dado.
  static List<int> _mescola(int quante, String marcatore) {
    final posti = List<int>.generate(quante, (i) => i);
    final filo = FiloDellaVoce.da([marcatore, 'mescola']);
    for (var i = quante - 1; i > 0; i--) {
      final j = filo.scegli(List<int>.generate(i + 1, (k) => k));
      final t = posti[i];
      posti[i] = posti[j];
      posti[j] = t;
    }
    return List.unmodifiable(posti);
  }

  /// **IL TITOLO, che a colpo d'occhio è già una risposta.**
  ///
  /// [giornoDellaDiscesa] e [giaOggi] fanno girare il titolo dentro le forme
  /// del suo tema: vedi [giro]. Senza il giorno si pesca col filo, come
  /// prima dell'ordine DI.
  static String titolo(ScenaDelViaggio scena, String? temaDomanda,
      {DateTime? giornoDellaDiscesa, int giaOggi = 0}) {
    // **IL MARCATORE `titolo` NON E' UN ORNAMENTO**: senza, questo filo
    // nascerebbe dagli stessi ingredienti di quello dei paragrafi e le due
    // scelte camminerebbero insieme, cioe' due discese con lo stesso titolo
    // avrebbero spesso anche la stessa risposta.
    final filo = FiloDellaVoce.da([
      ...scena.idDeiPezzi,
      temaDomanda ?? 'nulla',
      if (giornoDellaDiscesa != null)
        '${giornoDellaDiscesa.year}-${giornoDellaDiscesa.month}'
            '-${giornoDellaDiscesa.day}',
      'titolo',
    ]);
    final quali = titoliPerTema[temaDomanda] ?? titoliSenzaDomanda;
    if (giornoDellaDiscesa == null) return filo.scegli(quali);
    // **IL TITOLO NON GIRA IN FASE COL NUCLEO.** Con otto titoli in un ciclo
    // di otto, a quaranta giorni tornavano insieme il titolo e il gesto, che
    // gira su venti, e a ventiquattro il titolo e la risposta, che gira su
    // dodici: due responsi con due frasi in comune, e la somiglianza sopra
    // il quaranta per cento. Adesso il titolo si sposta di un posto a ogni
    // suo giro completo, e non torna mai in fase ne' con l'uno ne' con
    // l'altra; e non si ripete in due giorni di fila.
    final n = quali.length;
    final u = FiloDellaVoce.da(['titolo', temaDomanda ?? 'nulla']).seme % n +
        giro(giornoDellaDiscesa, giaOggi);
    return quali[mescolato((u + u ~/ n) % n, n, 'titolo ${temaDomanda ?? 'nulla'}')];
  }

  /// **I PARAGRAFI DELLA RISPOSTA**, nell'ordine in cui si leggono.
  /// **[giornoDellaDiscesa] E' IL GIORNO DELLA DISCESA, e il filo lo conosce.**
  ///
  /// **Senza, due discese che pescassero gli stessi quattro pezzi darebbero
  /// parola per parola lo stesso responso**: misurato, e succedeva una volta
  /// su cinquanta. Il vocabolario del Viaggio e' finito, e la ripetizione
  /// della **scena** e' matematica; la ripetizione del **testo** no, ed e' cio'
  /// che l'ordine DF vieta.
  ///
  /// **Il determinismo che conta resta intatto**: la stessa discesa, riaperta,
  /// dice la stessa cosa, perche' una discesa e' identificata dal suo giorno e
  /// dalla sua domanda.
  static List<String> paragrafi({
    required ScenaDelViaggio scena,
    required String? temaDomanda,
    required String? temaInLettere,
    DateTime? giornoDellaDiscesa,
    int giaOggi = 0,
    int? formaDellaScena,
  }) {
    if (giornoDellaDiscesa != null) {
      return _paragrafiAlGiro(scena, temaDomanda, temaInLettere,
          giro(giornoDellaDiscesa, giaOggi), formaDellaScena);
    }
    final filo = FiloDellaVoce.da([
      ...scena.idDeiPezzi,
      temaDomanda ?? 'nulla',
      if (giornoDellaDiscesa != null)
        '${giornoDellaDiscesa.year}-${giornoDellaDiscesa.month}'
            '-${giornoDellaDiscesa.day}',
      'risposta',
    ]);
    final righe = <String>[];

    // 1. la risposta, che nomina la domanda con cui si e' scesi.
    if (temaDomanda != null && temaInLettere != null) {
      final ripresa = filo
          .scegli(riprendeLaDomanda)
          .replaceAll('{tema}', _minuscola(temaInLettere))
          .replaceAll('{breve}',
              temaInDueParole[temaDomanda] ?? _minuscola(temaInLettere));
      // **TRE FILI PER TRE SCELTE**, e non tre passi dello stesso: due
      // discese con semi vicini sceglievano insieme la risposta e la coda, e
      // la misura D restava a tre con settecentosessantotto combinazioni
      // disponibili.
      final risposta = filo
          .piu(3)
          .scegli(rispostePerTema[temaDomanda] ?? risposteSenzaDomanda);
      final coda = filo.piu(11).scegli(codaDellaRisposta);
      righe.add(cuci([ripresa, risposta, coda]));
    } else {
      righe.add(filo.scegli(risposteSenzaDomanda));
    }

    // 2. cosa puoi fare: l'apertura, il gesto, il quando.
    //
    // **CON UN FILO SUO**, e non con lo stesso della risposta: le scelte
    // successive di un filo camminano sullo stesso seme, e due discese con
    // semi vicini finivano per scegliere insieme la risposta **e** il gesto.
    // Misurato: la misura D restava a tre con milleduecentottanta
    // combinazioni disponibili, che e' impossibile se le scelte sono
    // indipendenti.
    final filoDelGesto = filo.piu(7);
    final apre = filoDelGesto.scegli(apreIlGesto);
    final gesto = filoDelGesto.scegli(cosaPuoiFare);
    // **IL QUANDO NON RIPETE L'APERTURA**: *"Il passo di oggi: ... Oggi."*
    // Ordine DI voce 05, trovato leggendo i responsi per intero. Si passa al
    // quando dopo, finche' non ripete niente.
    var qualeQuando = quando.indexOf(filoDelGesto.scegli(quando));
    for (var giri = 0;
        giri < quando.length && _ripete(quando[qualeQuando], '$apre $gesto');
        giri++) {
      qualeQuando = (qualeQuando + 1) % quando.length;
    }
    righe.add(cuci([apre, gesto, quando[qualeQuando]]));

    // 3. da dove viene, cioe' la scena. **Con un filo suo**, per la stessa
    // ragione del gesto.
    final daDove = filo.piu(19).scegli(daDoveViene).split('{scena}');
    righe.add(cuci([daDove.first.trimRight(), scena.testoSenzaApertura]));

    return righe;
  }

  /// **I PARAGRAFI COL GIRO**, ordine DI voce 16: le stesse tre righe di
  /// [paragrafi], con le stesse forme e le stesse regole, scelte dal giro del
  /// giorno invece che pescate. Vedi [giro].
  ///
  /// **IL NUCLEO GIRA INTERO.** Le due frasi lunghe del responso sono quella
  /// della risposta e quella del gesto, e la seconda da sola vale sei
  /// sequenze di cinque parole. Scelte ognuna per conto suo, su
  /// quattromilanovecentocinquanta coppie di discese una ventina le
  /// condivideva tutte e due, e quelle coppie superavano il quaranta per
  /// cento di somiglianza: misurato, 40,3 e 40,9. Adesso la coppia risposta e
  /// gesto e' **un posto solo** di uno spazio di duecentosessanta, centosessanta
  /// senza tema: prima di duecentosessanta giorni due discese non hanno mai
  /// tutte e due le frasi in comune.
  ///
  /// **E LE CORNICI DIPENDONO DAL NUCLEO**, la ripresa e la coda della
  /// risposta, l'apertura e il quando del gesto. A risposta fissa la cornice
  /// della risposta cambia col gesto, a gesto fisso la cornice del gesto
  /// cambia con la risposta: dentro i duecentosessanta giorni nessun
  /// paragrafo torna uguale, per costruzione. La stesura di prima le faceva
  /// girare in spazi loro, e quella del gesto, sessantaquattro posti, tornava
  /// identica dopo sessantaquattro giorni insieme allo stesso gesto: un
  /// paragrafo intero ripetuto, e la misura C del blocco al 41,8 per cento.
  ///
  /// **E SONO MESCOLATE.** La terza stesura le legava al nucleo con una
  /// formula lineare: iniettive, ma due discese con la stessa risposta e due
  /// gesti vicini cadevano su cornici vicine, con la stessa forma della scena
  /// e la stessa chiusura, e col modello vero la misura C della direzione e'
  /// arrivata al 45,1 per cento. Adesso ogni cornice passa da uno spazio
  /// mescolato, che non unisce mai due posti e non lascia vicini i vicini.
  static List<String> _paragrafiAlGiro(ScenaDelViaggio scena,
      String? temaDomanda, String? temaInLettere, int g, int? formaDellaScena) {
    final righe = <String>[];
    final conTema = temaDomanda != null && temaInLettere != null;
    final risposte = conTema
        ? rispostePerTema[temaDomanda] ?? risposteSenzaDomanda
        : risposteSenzaDomanda;
    final s = risposte.length;
    // **DUE CICLI, E NON UNA PESCATA NELLO SPAZIO.** Il gesto gira sulle sue
    // venti forme, la risposta sulle sue [s]; e poiche' venti e [s] hanno
    // divisori in comune, dopo il loro minimo comune multiplo di giorni la
    // risposta si sposta di un posto. **Cosi' la stessa azione non torna
    // prima di venti giorni, la stessa risposta prima di [s] meno uno, e la
    // coppia non torna in nessuna finestra di duecento giorni con un tema,
    // di centoquaranta senza.** La dimostrazione: due giorni con lo stesso
    // gesto distano venti per m, e la risposta coincide se venti per m piu'
    // lo spostamento d e' multiplo di [s]. Con dodici risposte serve d
    // uguale a quattro volte m modulo dodici, e lo spostamento, un posto
    // ogni sessanta giorni, lo raggiunge la prima volta a m uguale a dieci,
    // cioe' a duecento giorni; con otto, a m uguale a sette, centoquaranta.
    // **E il ciclo non si chiude**: la seconda stesura lo faceva ricominciare
    // ogni duecentoquaranta giorni, e dove ricominciava lo spostamento
    // tornava a zero e la stessa risposta ricadeva a tre giorni di distanza.
    // La prima stesura pescava la coppia da uno spazio mescolato: unica
    // anche lei, ma la stessa azione poteva tornare a tre giorni, e nessuna
    // delle cinque misure lo vedeva. Le forme di ogni ciclo sono in un
    // ordine mescolato.
    final c = cosaPuoiFare.length;
    final chiave = conTema ? temaDomanda : 'nulla';
    final t = FiloDellaVoce.da(['nucleo', chiave]).seme % (s * c) + g;
    final multiplo = s * c ~/ _mcd(s, c);
    final ge = mescolato(t % c, c, 'gesto del nucleo');
    final ri =
        mescolato((t + t ~/ multiplo) % s, s, 'risposta del nucleo $chiave');
    final risposta = risposte[ri];
    final gesto = cosaPuoiFare[ge];
    // Le partenze delle due cornici, fisse e diverse fra loro.
    final pr = FiloDellaVoce.da(['cornice della risposta']).seme;
    final pg = FiloDellaVoce.da(['cornice del gesto']).seme;

    if (conTema) {
      final r = riprendeLaDomanda.length;
      // Iniettiva nel gesto a risposta fissa: undici e' primo con le
      // centoquarantaquattro cornici.
      final quante = r * codaDellaRisposta.length;
      final cornice = mescolato(
          (pr + ge * 13 + ri) % quante, quante, 'cornice della risposta');
      final ripresa = riprendeLaDomanda[cornice % r]
          .replaceAll('{tema}', _minuscola(temaInLettere))
          .replaceAll('{breve}',
              temaInDueParole[temaDomanda] ?? _minuscola(temaInLettere));
      righe.add(cuci([ripresa, risposta, codaDellaRisposta[cornice ~/ r]]));
    } else {
      // Senza tema la risposta e' una frase sola su otto: ha la coda, o in
      // cento discese tornerebbe dodici volte.
      righe.add(cuci([
        risposta,
        codaDellaRisposta[(pr + ge * 5) % codaDellaRisposta.length],
      ]));
    }

    final a = apreIlGesto.length;
    // Iniettiva nella risposta a gesto fisso: cinque e' primo con le
    // sessantaquattro cornici, e le risposte di un tema sono meno.
    final cornice = mescolato((pg + ri * 5 + ge * 7) % (a * quando.length),
        a * quando.length, 'cornice del gesto');
    final apre = apreIlGesto[cornice % a];
    // **IL QUANDO NON RIPETE L'APERTURA**, ordine DI voce 05: si passa al
    // quando dopo, finche' non ripete niente.
    var qualeQuando = cornice ~/ a;
    for (var giri = 0;
        giri < quando.length && _ripete(quando[qualeQuando], '$apre $gesto');
        giri++) {
      qualeQuando = (qualeQuando + 1) % quando.length;
    }
    righe.add(cuci([apre, gesto, quando[qualeQuando]]));

    // **LA CORNICE DELLA SCENA**: l'apertura del blocco, la forma della frase
    // che cuce i pezzi e la chiusura. Anche lei e' funzione iniettiva del
    // nucleo: dentro i duecentosessanta giorni due discese non hanno mai
    // tutte e tre le parti uguali. Pescate a caso, coincidevano su due scene
    // che avevano un pezzo in comune, e la misura C passava il quaranta per
    // cento su tutte le coppie: 42,3 il blocco, 47,1 una domanda libera.
    final ps = FiloDellaVoce.da(['cornice della scena']).seme;
    final posti = daDoveViene.length * 8 * 12;
    final cs = mescolato(
        (ps + ri * cosaPuoiFare.length + ge) % posti, posti, 'cornice della scena');
    final daDove = daDoveViene[cs % daDoveViene.length].split('{scena}');
    // **LA FORMA CHE CUCE LA SCENA** la sceglie chi conosce la storia,
    // `IlResponsoDelViaggio.formaDellaScena`: una scena che somiglia a una di
    // prima non si racconta con la stessa frase. Senza storia, quella della
    // sua cosa. La chiusura resta alla cornice.
    const forme = 8;
    final forma = formaDellaScena ??
        FiloDellaVoce.da([scena.cosa.id, 'forma']).seme % forme;
    final chiusura = cs ~/ daDoveViene.length;
    righe.add(cuci([
      daDove.first.trimRight(),
      scena.testoSenzaAperturaAlPosto(forma + forme * chiusura),
    ]));
    return righe;
  }

  /// **LA CUCITURA DEI PEZZI, e impedisce i due punti annidati per
  /// costruzione.** Ordine DI voce 05: *"in nessun punto dell'app due
  /// segmenti che terminano con i due punti possono concatenarsi: va aggiunto
  /// un controllo in fase di composizione che lo impedisca per costruzione,
  /// non un rattoppo sulle stringhe"*.
  ///
  /// **La regola.** Un pezzo che finisce coi due punti apre una spiegazione,
  /// e la spiegazione e' la **prima frase** del pezzo dopo. Se quella frase
  /// contiene a sua volta dei due punti, la spiegazione si aprirebbe dentro
  /// un'altra spiegazione. In quel caso **i due punti del primo pezzo
  /// diventano un punto**: la frase resta italiana, e la cosa non puo' uscire
  /// a schermo in nessuna combinazione.
  ///
  /// **Pubblica perche' una guardia la possa provare da sola**, oltre a
  /// percorrere tutte le combinazioni del materiale vero.
  static String cuci(List<String> pezzi) {
    final fatti = <String>[];
    for (var i = 0; i < pezzi.length; i++) {
      var pezzo = pezzi[i].trim();
      if (pezzo.isEmpty) continue;
      final dopo = i + 1 < pezzi.length ? pezzi[i + 1].trim() : '';
      if (pezzo.endsWith(':') && _primaFrase(dopo).contains(':')) {
        pezzo = '${pezzo.substring(0, pezzo.length - 1)}.';
      }
      // **DOPO I DUE PUNTI SI CONTINUA IN MINUSCOLO**, come si scrive in
      // italiano: *"Il passo di oggi: Prendi carta e penna"* aveva la
      // maiuscola di una frase nuova dentro una frase che non era finita.
      if (fatti.isNotEmpty && fatti.last.endsWith(':')) {
        pezzo = _minuscola(pezzo);
      }
      fatti.add(pezzo);
    }
    return fatti.join(' ');
  }

  /// La prima frase di [s], fino al primo punto, punto esclamativo o
  /// interrogativo.
  static String _primaFrase(String s) {
    final fine = RegExp(r'[.!?]').firstMatch(s);
    return fine == null ? s : s.substring(0, fine.start);
  }

  /// Se [uno] ripete una parola piena di [altro], da quattro lettere in su.
  static bool _ripete(String uno, String altro) {
    Set<String> parole(String s) => RegExp(r'[a-zàèéìòù]{4,}')
        .allMatches(s.toLowerCase())
        .map((m) => m.group(0)!)
        .toSet();
    return parole(uno).intersection(parole(altro)).isNotEmpty;
  }

  static String _minuscola(String s) =>
      s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

  /// Il tema della domanda con cui si è scesi, o nulla.
  /// **L'ID DEL TEMA, dal tipo.** Ordine DI voce 01: qui arrivava una
  /// stringa, e lo schermo ci metteva l'etichetta invece dell'id. Adesso
  /// arriva il tipo, e un'etichetta non compila.
  static String? temaDi(TemaDellaDomanda? tema) => tema?.name;

  /// L'etichetta per esteso del tema, per la ripresa della domanda.
  static String? temaInLettereDi(TemaDellaDomanda? tema) => tema?.inLettere;
}
