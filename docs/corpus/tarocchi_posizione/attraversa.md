# LA POSIZIONE: ATTRAVERSA

Cio' che attraversa, di traverso.

**Fonte da riempire.** Per ogni carta e per ogni verso tre varianti dello
stesso scheletro, `- 1:`, `- 2:`, `- 3:`, scritte dall'Architetto (ordine FI,
aggiunta A1 e A4). Una riga vuota e' un testo che non c'e' ancora. Una
variante e' piena in tutte le 156 carte-verso o vuota in tutte: a meta', il
tool si ferma e nomina le righe che mancano.

**Le tre varianti vengono dal corpus dell'11 ottobre 2026**, scritte
dall'Architetto con dodici scrittori e consegnate col commit 394e9c5, pulite
sulle dieci regole del metro. La posizione sta al **66,2 per cento** in prova
cieca appaiata con dodici lettori e 936 testi nello stesso giro. Provenienza
scritta da Code con l'ordine FK, aggiunta 2 voce A11, dal messaggio del commit
394e9c5, perche' la regola FJ.4 vuole che ogni posizione con testi dica da dove
vengono.

**Regole dei testi** (voce FI.23, le stesse del corpus del 27 settembre):
una o due frasi fra 110 e 280 caratteri, rivolte alla persona col tu. Ne' il
nome della carta ne' il suo verso. Nessuna parola che dia un genere a chi
legge, oppure la marca intera `[maschile|femminile|neutra]`. Niente cifre,
niente la parola voce, niente trattino lungo, mai una virgola seguita da "e"
o "ed", accenti veri. Nessuna previsione certa, solo tendenze; nessuna
promessa su salute, denaro, leggi o morte. Le tre varianti di una carta
cominciano con parole diverse; nessun doppione e nessuna coppia con
somiglianza di Jaccard sopra 0,6.

**Come si tocca.** Si riempie qui, poi si rilancia
`python tool/genera_carte_nella_posizione.py`, che controlla e scrive
`lib/core/tarot/le_carte_nella_posizione_dati.dart`.

## Il Matto

### dritta

- 1: Un principio a mani vuote si apre nell'ora degli impegni dichiarati. La fiducia nel primo passo precede le garanzie che il lavoro avviato ti chiedeva di dare.
- 2: La mano libera porta bene a quello che nasce da zero. Il legame che hai già stretto vive di continuità; quello slancio senza preparativi cerca terreno vergine.
- 3: Verso il momento iniziale tira questa fiducia senza bagagli. La decisione che hai davanti voleva lo sguardo sull'arco intero e l'attenzione resta sul partire.

### capovolta

- 1: Questa spinta parte prima di avere un nome. Una ragione dicibile serviva al passo che hai davanti; l'orlo è già sotto il tuo piede e la provenienza resta impronunciata.
- 2: Sull'orlo punta questo slancio. L'origine che ti serviva nominare resta dietro e il vuoto davanti prende tutta l'attenzione che toccava al motivo.
- 3: Il bordo non ferma questo impulso. Una sosta bastava a dire da dove nasce la partenza e la meta che il tuo partire chiede resta da fissare.

## Il Mago

### dritta

- 1: Tutti i mezzi stanno già a portata e quello che pensi diventa cosa fatta nello stesso istante. Il tuo tentativo in corso chiedeva di restare qualcosa che si poteva ancora disfare.
- 2: La tua facoltà di fare porta frutto al lavoro delle mani: una decisione lasciata aperta chiedeva invece un criterio per scegliere, non una mano pronta a chiuderla.
- 3: Quel potere prosegue oltre il punto in cui un abbozzo bastava: l'opera esce finita e intera, là dove il tuo patto appena avviato voleva una bozza da correggere in due.

### capovolta

- 1: L'annuncio tiene pieno il posto del fatto: il talento è tuo per intero e riposa chiuso. L'impegno che avevi preso voleva in quel posto una cosa consegnata.
- 2: Lo scarto fra quello che dici e quello che le tue mani portano a termine viene allo scoperto proprio dove un accordo teneva coperta la parte non ancora eseguita.
- 3: Una promessa in più da mantenere si somma a quelle che reggi già, perché la parola data cresce al posto del dono, che resta piegato dove lo hai posato.

## La Papessa

### dritta

- 1: Il velo che custodisce questo sapere lo tiene intero al coperto, mentre il riserbo che lo conserva chiude fuori la persona che attendeva da te una frase chiara.
- 2: Quella conoscenza muta lavora bene dove nessuno parla, nella comprensione che matura al buio: il punto che hai aperto chiedeva invece una formula pronunciata davanti a qualcuno.
- 3: Resta pieno di silenzio il posto in cui doveva stare una dichiarazione: la quiete che fa maturare le risposte occupa il momento in cui alla cosa che hai davanti serviva una parola detta.

### capovolta

- 1: Il ragionamento che spiega tutto tiene pieno lo spazio dell'ascolto: quello che già sai senza parole resta sotto, mentre sopra lavora una spiegazione più rumorosa della tua scelta.
- 2: Le spiegazioni continuano oltre il punto in cui una pausa breve avrebbe fatto sentire quello che dentro è chiaro, intanto che il rumore cresce sopra quello che hai da capire.
- 3: Sotto il frastuono dei tuoi ragionamenti quella certezza interna sta al sicuro dal timore di ascoltarla: lo schermo che la ripara chiude anche la stanza dove volevi riconoscerla.

## L'Imperatrice

### dritta

- 1: Una crescita viva si prende il tempo pieno della terra buona davanti alla risposta corta che la tua intesa aspettava: quello che hai avviato matura con una misura di giorni che non si lascia accorciare.
- 2: Il nutrimento continua a salire nella pianta già partita anche quando la tua attesa chiedeva una forma ferma: quello che è vivo seguita a cambiare mentre lo guardi.
- 3: Fiorisce con abbondanza quello che respira già da sé: la dolcezza dei modi e il calore vanno alla pianta avviata, mentre la scelta che il tuo tempo chiede sta ferma su un altro tavolo.

### capovolta

- 1: La cura esce puntuale verso le cose che stanno già fuori e tira da quella parte, mentre la radice del tuo lavoro nuovo resta asciutta: dove nasce il vivo arriva l'ultima parte del nutrimento.
- 2: Altre creature da nutrire entrano nell'elenco e le mani tornano piene, mentre la sorgente da cui prende forma il tuo progetto chiede acqua propria e aspetta il suo turno.
- 3: Si ferma la fioritura proprio dove il tuo legame aveva bisogno di una cosa viva da mostrare: la fertilità resta ritirata dentro, al coperto, con la linfa che non esce dal fusto.

## L'Imperatore

### dritta

- 1: La regola che hai posato sostiene quello che costruisci e nello stesso gesto sigilla la parte dell'intesa che aveva bisogno di restare rivedibile. Protegge la forma; chiude il margine di ritorno.
- 2: Una forma data regge il tuo progetto in piedi mentre serra il punto in cui serviva una decisione morbida: quello che fissa dura, compreso il dettaglio che chiedeva di poter essere riaperto.
- 3: Fermezza e responsabilità tengono su l'impianto del tuo lavoro mentre la stessa fermezza chiude a chiave il patto che sperava di poter essere ridiscusso. Il sostegno è reale ed è inchiodato.

### capovolta

- 1: Il comando che hai dato continua a stringere oltre il punto in cui il lavoro aveva bisogno di gioco, oppure manca la base sotto e l'impianto oscilla: la forma non si arresta dove finisce quello che tiene.
- 2: Troppo serrata, la norma prosegue dove serviva allentarla; oppure sotto la tua costruzione il piano d'appoggio non c'è e ogni scelta che prendi oscilla sul vuoto. Il respiro resta la parte che si restringe.
- 3: Stringe oltre il necessario l'autorità che ti sei dato: il margine in cui una decisione poteva muoversi si assottiglia a ogni giro. Oppure le fondamenta mancano del tutto mentre l'impianto va avanti a reggersi da sé.

## Il Papa

### dritta

- 1: Un magistero più antico di te si pronuncia con l'autorità che gli viene dalla trasmissione: quel pronunciamento giova al corpo che lo custodisce; la questione che hai portato resta tua.
- 2: L'antica scuola a cui ti appoggi ti tiene su e serra nello stesso movimento il margine in cui cercavi una soluzione inedita.
- 3: Arriva una sapienza che ha già risposto a mille casi prima del tuo: la sua parola è pronta, mentre la faccenda che hai in mano chiederebbe un giudizio nato dentro di lei.

### capovolta

- 1: Il congedo da una regola ricevuta tira il tuo interesse verso il senso che vuoi darti; l'intesa che hai in corso aspetta una risposta su un punto stretto.
- 2: Viene allo scoperto una convenzione che hai smesso di sentire tua, nel punto in cui tenevi il tuo assenso al coperto dalle domande di casa.
- 3: La tua ricerca di un criterio proprio occupa lo spazio in cui la trattativa chiedeva una regola valida per tutte le parti: quel posto resta pieno di un dubbio che non hai sciolto.

## Gli Amanti

### dritta

- 1: La prova dei tuoi valori cade sulla decisione nel momento della risposta pratica. Quello in cui credi entra nella scelta accanto a quello che desideri.
- 2: Il bene di questa scelta va a quello che sei nel profondo. La tua fretta di concludere vuole altro e quel vaglio lavora sul fondo delle cose.
- 3: Sulle tue mani, già occupate da una decisione da chiudere, si aggiunge un vaglio da sostenere. Sentimento e giudizio chiedono insieme lo stesso atto.

### capovolta

- 1: Una disputa interna occupa il posto che l'intesa da stringere voleva libero. Il credere e il volere si dividono la scelta e portano tutti e due la tua firma.
- 2: Dentro di te lavora questo disaccordo. La risposta da dare all'altra persona aspetta; il tuo credere e il tuo volere litigano sulla parola e uno dei due resta muto.
- 3: Questo dissidio mostra un valore che tu tenevi al coperto, proprio quando il desiderio bastava a decidere. I due termini della contesa sono tuoi.

## Il Carro

### dritta

- 1: La tua padronanza tira verso la meta che si è data e unisce in quel tiro le spinte contrarie. Il legame che avevi in gioco guardava una cosa di fianco, fuori da quella meta.
- 2: Tenere unite le spinte opposte le ripara dallo strapparsi e con il medesimo comando serra l'obiezione che una delle due portava, quella che il tuo accordo aspettava di sentire.
- 3: Il governo delle redini continua oltre il punto in cui una sosta avrebbe fatto il suo lavoro: l'andare resta saldo e la tua verifica in sospeso voleva un fermo per essere fatta.

### capovolta

- 1: Due tiri opposti occupano insieme lo stesso giogo e nessuno dei due lo lascia. La cosa che hai in mano chiedeva un attacco solo e una presa sola per muoversi.
- 2: La corsa prosegue oltre il punto in cui la mano doveva riprendere le redini: lo slancio resta intero e un accordo tuo quasi fermo voleva proprio quel momento di presa.
- 3: Un secondo tiro da reggere si aggiunge a quello che tenevi già, con le due spinte attaccate al medesimo giogo e le tue mani che avevano posto per una sola.

## La Giustizia

### dritta

- 1: La pesata va avanti fino all'ultima parte dovuta, oltre il punto in cui la cosa che hai davanti chiedeva un margine: ogni atto torna sul piatto tale quale è stato posato.
- 2: Il piatto mostra la porzione del dovuto che restava fuori dal conteggio: la causa torna accanto al suo effetto, cosicché quello che tenevi da parte compare nel computo della tua decisione.
- 3: Questa equità fa bene al merito di ciascuno: risponde a chi ha messo che cosa, mentre la cosa che hai chiesto riguardava un'apertura di credito da concedere senza contare.

### capovolta

- 1: Il caso occupa la casella dove andava il tuo nome: la registrazione resta dalla tua parte mentre l'attribuzione che le dai sta su un altro, cosicché la partita che volevi chiudere sta aperta.
- 2: Una pendenza in più resta da reggere: quella conseguenza porta il tuo nome in calce anche quando l'attribuisci alla sfortuna, cosicché le mani già piene tengono pure questa.
- 3: Proprio mentre la faccenda che hai davanti chiedeva di sapere a chi appartiene quella conseguenza, l'attribuzione si posa su un altro nome, intanto che la registrazione vera resta tua.

## L'Eremita

### dritta

- 1: Il silenzio cercato tiene la ricerca al coperto e tiene chiusa la porta allo scambio che il tuo lavoro a due chiedeva aperto: la lampada schiarisce un tratto breve, il resto sta scuro.
- 2: Un raggio corto di luce tiene occupata l'attenzione intera su un passo solo, mentre il tuo scambio con gli altri chiedeva lo sguardo largo di chi vede la stanza per intero.
- 3: Cresce in profondità il sapere raccolto in lunga strada: quel guadagno va alla ricerca che hai aperto per conto tuo, mentre la parola chiara che il tuo compagno di lavoro aspettava resta dentro il silenzio.

### capovolta

- 1: La solitudine seguita oltre il punto in cui aveva finito di insegnare: la lampada scende sempre dentro, mentre il rientro verso le persone del tuo giro resta senza un tratto schiarito.
- 2: Dentro tira tutta la luce raccolta, verso la stanza chiusa dove il sapere si deposita, mentre la tua promessa a chi aspetta fuori guardava alla strada del ritorno.
- 3: Il raccoglimento custodisce quello che hai capito e lo trattiene là dentro: la cosa detta che il tuo legame chiedeva resta chiusa nel silenzio di casa.

## La Ruota della Fortuna

### dritta

- 1: Il giro cambia verso da sé, senza mano che lo spinga, proprio dove il tuo accordo aveva bisogno di restare fermo per prendere forma. Quello che si muove non chiede il permesso a nessuno.
- 2: Qualcosa si capovolge per rotazione e non per scelta, mentre tocca il punto del tuo lavoro che reggeva solo da fermo. La svolta è reale: cade nell'ora in cui servivano condizioni stabili.
- 3: Senza preavviso l'alto e il basso si scambiano di posto, mentre una cosa tua che stava maturando chiedeva tempo uguale a se stesso. La rotazione tocca pure quello che era appena sistemato.

### capovolta

- 1: La rotazione va avanti storta e tira verso il ripetersi dello stesso giro, mentre quello che hai avviato guardava in avanti. Nessuna mano la governa: la presa non è dalla tua parte.
- 2: Gira per conto suo il meccanismo e porta la tua faccenda a ripassare dal punto di partenza, proprio dove serviva un passo nuovo. Chi sta sopra non ha appigli su cui fare leva.
- 3: Un ciclo tuo continua a muoversi senza che tu lo guidi e lo fa in cerchio, verso il medesimo punto di prima, mentre il tuo progetto chiedeva una direzione diversa dal ritorno.

## La Forza

### dritta

- 1: Il coraggio dolce con cui tieni l'istinto cade nel punto in cui la faccenda chiedeva uno scatto: la mano resta ferma; la trattativa davanti a te premeva per un movimento secco.
- 2: La dolcezza del tuo dominio prosegue oltre il segno in cui la faccenda avrebbe chiuso: la belva si acquieta, poi la stessa mitezza insiste sul punto che chiedeva un rifiuto netto da parte tua.
- 3: Una mano paziente sull'istinto custodisce il tuo equilibrio e con lo stesso gesto chiude la spinta che la decisione in sospeso avrebbe usato per partire.

### capovolta

- 1: Il dubbio sulla tua tenuta esce alla luce nel punto in cui la decisione da prendere aveva bisogno che la saldezza restasse fuori discussione.
- 2: Un dominio che credi perduto chiede una verifica su di te in più, in aggiunta alle pratiche che stai già reggendo da settimane.
- 3: La durezza con cui ti tratti sta là dove la mitezza stava prima: la pratica aperta aspettava una mano mite e incontra la tua stretta.

## L'Appeso

### dritta

- 1: Questa sospensione ferma il tempo nell'ora del gesto atteso. Lo sguardo invertito arriva quando al lavoro che hai aperto occorreva una mano.
- 2: Alla comprensione giova questo capovolgimento. La consegna che hai promesso aspetta; la vista nuova matura in un tempo che non si conta a gesti.
- 3: L'attesa riempie il tempo che occorreva all'azione. Quello che vedi nasce dal verso contrario e il tuo lavoro fermo resta allo stesso punto.

### capovolta

- 1: Una rinuncia priva di destinatario sta nel posto del gesto atteso. Il sacrificio prosegue e il tuo lavoro da fare resta dove era.
- 2: Questa offerta mostra il timore che stava sotto un nome alto, proprio quando una decisione bastava. Quello che hai chiamato dono non trova chi lo riceva.
- 3: Hai le braccia piene della tua faccenda da chiudere e questo sacrificio mette dentro una privazione in più da reggere. L'attesa ha smesso di insegnare.

## La Morte

### dritta

- 1: Una chiusura in corso porta a termine da sé una cosa che la tua attesa aveva bisogno di trovare ancora in piedi, perché il congedo non chiede il permesso di nessuno per compiersi.
- 2: Lo spazio che questo congedo apre serve un terreno diverso dal tuo: il lavoro che vuoi avviare voleva un posto già sgombro, non uno che si sta sgombrando.
- 3: Quello che la cosa finita teneva coperto viene allo scoperto appena il congedo si compie: il tuo riserbo su quel punto reggeva soltanto finché reggeva la copertura.

### capovolta

- 1: La tua mano che non si apre riempie da sola lo spazio dove stava una cosa conclusa. Quello che vorresti far entrare ha bisogno di quello stesso spazio sgombro.
- 2: Trattenere custodisce la forma di quello che è finito e nel medesimo gesto serra la mano su di essa, là dove il tuo legame nuovo chiedeva una mano aperta per essere stretto.
- 3: Una cosa già conclusa resta fra le tue mani come materia da tenere ferma, sommata a quello che reggi di vivo, dove le dita bastavano appena per il secondo.

## La Temperanza

### dritta

- 1: Il dosaggio lento comincia a unire le due parti proprio dove la cosa che hai davanti chiedeva un atto in un colpo solo: la fusione vuole tutto il suo tempo per diventare una terza cosa.
- 2: Questa arte di mescolare fa bene alla convivenza delle due parti, mentre la faccenda che hai chiesto riguardava una preferenza dichiarata: la calma versa l'una nell'altra fino a confonderle.
- 3: Continua la correzione della dose oltre il punto in cui il tuo preparato era pronto da servire: ogni goccia aggiunta chiede un'altra prova prima di fermarsi.

### capovolta

- 1: La parte in eccesso continua a versarsi oltre il punto in cui il recipiente era colmo, mentre l'altra sta a digiuno: le tue due metà hanno smesso di passarsi qualcosa.
- 2: Arriva altra dose da reggere là dove la tua mano era già piena: una delle due metà pretende tutto il rifornimento, cosicché quello che stavi tenendo in equilibrio ha una porzione in più da sostenere.
- 3: Tutto scivola verso la parte che già abbonda, intanto che quello che hai davanti aveva bisogno di uno scambio fra le due metà: il travaso corre da un lato soltanto.

## Il Diavolo

### dritta

- 1: Un piacere reale protegge il legame che hai accettato e lo stringe nello stesso giro: la catena dà indietro qualcosa di buono ogni volta, davanti alla libertà di manovra che il tuo progetto chiedeva.
- 2: Dentro lo spazio che il tuo rapporto teneva libero per una scelta sta già seduto il vincolo: l'attaccamento chiede indietro una libertà per volta e restituisce un gusto preciso, in pieno giorno.
- 3: Oltre il punto in cui quel gusto bastava, il patto continua a chiedere: la catena seguita a stringere sopra la misura che il tuo legame con gli altri aveva fissato in principio.

### capovolta

- 1: Lo scioglimento arriva dove il tuo patto aveva bisogno che quella presa tenesse fermo il proprio appoggio: il nodo si allenta a mano, un giro per volta, mentre il gusto che lo nutriva se ne va con lui.
- 2: Una rinuncia nuova entra fra le cose da portare, perché il legame riconosciuto si allenta al prezzo di un piacere gradito, mentre la tua intesa aveva già la sua parte da lasciare.
- 3: Si vede in chiaro il giro di catena che il tuo legame di famiglia teneva sotto il tavolo: la presa era vera e il nome che riceve la porta in mezzo al discorso di tutti.

## La Torre

### dritta

- 1: Il cedimento improvviso porta alla luce la parte della tua costruzione che stava su per finzione, quella che una convenienza teneva coperta. Resta in piedi il vero, scoperchiato insieme al resto.
- 2: Quello che regge solo in apparenza viene giù di colpo e mostra l'intelaiatura che il tuo progetto non voleva far vedere. La rivelazione passa dal crollo di un pezzo, non dal racconto.
- 3: Cade senza preavviso la facciata di un impianto tuo ed esce allo scoperto quello che un accordo comodo manteneva al riparo dagli occhi. Il vero regge: è in vista.

### capovolta

- 1: La scossa rimandata lascia in piedi un'impalcatura che tiene pieno il posto dove al tuo lavoro sarebbe servito spazio libero per rifare. Quello che non è caduto occupa il terreno della cosa nuova.
- 2: Un rinvio mantiene su la costruzione che avrebbe dovuto venire giù, mentre il posto che serviva vuoto resta ingombro di travi vecchie. La tua faccenda gira attorno a quell'ingombro.
- 3: Regge per rinvio una struttura tua già sfiatata ed è la sua stessa presenza a tenere occupato il terreno su cui la ripresa avrebbe potuto appoggiarsi. L'impalcatura sta dove serviva sgombro.

## La Stella

### dritta

- 1: Una quiete luminosa giova alla parte di te che ha attraversato la tempesta; il punto che hai messo sul tavolo aspettava un criterio per decidere.
- 2: La rassicurazione scende su di te nel punto in cui la pratica aperta avrebbe avuto bisogno di una scossa: la fiducia torna, intanto il fascicolo resta là dove l'hai lasciato.
- 3: Il conforto di questa luce ti difende dalla stanchezza e insieme smorza l'inquietudine da cui la questione traeva la spinta per muoversi.

### capovolta

- 1: La fatica di credere dura più a lungo del segno in cui il tuo caso chiedeva una scommessa: l'ispirazione resta lontana e il velo copre la scelta che devi fare.
- 2: Una speranza affaticata tiene occupato il punto in cui il tuo progetto chiedeva slancio intatto: il velo è passeggero, intanto il tuo slancio non ritrova quel posto libero.
- 3: Il dubbio sul domani aggiunge un peso da portare proprio là dove le tue mani erano già piene della pratica che hai aperto.

## La Luna

### dritta

- 1: Il buio arriva nell'ora del contorno netto. Quello che vedi non coincide con quello che è e il tuo passo da compiere si fa al tatto.
- 2: Questa foschia porta l'attenzione su quello che senti. Il dato da verificare aspettava il tuo esame e la prova resta in secondo piano.
- 3: Le forme notturne di una scena che tu guardavi alla luce del giorno si alzano con questa penombra. Quello che sale dal sonno sta davanti alla superficie leggibile.

### capovolta

- 1: Questo schiarirsi dà il suo frutto al timore che diventa piccolo. Il fondo che ti serviva guardare resta coperto e la luce cade sulle figure della notte.
- 2: Questa luce mostra quanto è piccola una paura che tenevi enorme. Quella paura reggeva la tua attenzione e il contorno rientra nei suoi bordi.
- 3: Il diradarsi non si arresta al timore. La prudenza che ti conveniva tenere intera si apre insieme alla nebbia, anche nel punto in cui un passo cauto serviva.

## Il Sole

### dritta

- 1: Il pieno giorno manda a compimento ogni cosa in una volta. Il lavoro che hai avviato cresceva meglio prima di avere un nome e quel tempo senza nome gli serviva.
- 2: Questo calore va a tutto il cerchio di chi ti sta attorno e scalda ognuno, là dove il patto che stai cercando voleva una stanza con due sedie e nient'altro.
- 3: Una gioia da sostenere e da mostrare si aggiunge alle cose che tieni in piedi, perché il tempo luminoso porta con sé le sue occasioni da reggere e le tue mani erano piene.

### capovolta

- 1: Il calore resta a un dito dalla pelle: la luce è intera e il contatto manca, mentre quello che hai in gioco chiedeva un segno sentito e non soltanto visibile.
- 2: Un velo riempie lo spazio fra te e quel chiarore. Il legame su cui chiedi voleva quello spazio libero, per far passare il tepore fino in fondo.
- 3: La nube che smorza il chiarore mette al riparo dal pieno della luce e nello stesso gesto chiude fuori il tepore, che era quanto il tuo legame aspettava.

## Il Giudizio

### dritta

- 1: La chiamata mette in piena luce tutto il percorso che avevi archiviato: nomina per intero quello che ora sei, mentre la faccenda che hai davanti teneva quelle pagine chiuse.
- 2: Il richiamo continua a pretendere una risposta intera, oltre il punto in cui alla tua decisione bastava una risposta parziale: chiede di presentarsi col nome nuovo.
- 3: Convoca il bilancio di una vita intera proprio dove quello che hai cominciato chiedeva una sola decisione piccola: la chiamata sale al nome che porti e vuole la persona per intero.

### capovolta

- 1: La condanna già emessa occupa il posto in cui andava il riepilogo: la pronuncia precede i fatti, cosicché la faccenda che hai davanti resta senza il conteggio che chiedeva.
- 2: Tira tutto verso la colpa, mentre la faccenda che hai davanti guardava a quello che c'è da riconoscere: la severità prende la scena che era della rassegna dei fatti.
- 3: Il rinvio tiene il bilancio al coperto dallo sguardo e nello stesso gesto lo chiude fuori dalla stanza in cui la tua decisione lo stava aspettando.

## Il Mondo

### dritta

- 1: La chiusura intera del cerchio cade sul punto in cui il tuo progetto teneva una porta aperta per quello che viene dopo: il giro si compie, si salda, raccoglie tutto il percorso dentro di te.
- 2: Il compimento si chiude sopra il ciclo lungo che hai finito di percorrere: l'armonia tocca quel giro, mentre il seguito che il tuo patto nuovo chiedeva sta davanti a un cerchio già saldato.
- 3: Pienezza e integrazione stanno addosso al tempo che la tua scelta seguente teneva da parte: un ciclo chiuso in armonia tiene dentro quello che hai percorso, intero, senza pezzi che sporgono.

### capovolta

- 1: Un pezzo da integrare resta in mano come cosa da tenere, proprio dove la tua attesa chiedeva una faccenda chiusa: l'intero manca di quel dettaglio e lo chiede al tavolo.
- 2: Il cerchio seguita a chiedere il suo ultimo tratto quando la tua attesa si era già fermata a guardare: quello che è compiuto per il resto tiene aperta una fessura sola.
- 3: Tutta la pienezza raccolta si stringe attorno al dettaglio non sciolto, mentre il passaggio nuovo che il tuo legame aspettava guardava dalla parte opposta del giro.

## Asso di Bastoni

### dritta

- 1: L'accensione nuova mette fra le tue mani un altro principio da reggere, mentre quelle mani stringono già una cosa cominciata e lasciata a metà. Il fuoco è vivo ed è un carico in più.
- 2: Una fiamma che nasce chiede di partire subito e porta con sé un secondo inizio da nutrire, là dove il tuo lavoro ne aveva già uno aperto che chiedeva fiato. L'ardore si presenta con il suo peso.
- 3: Parte da sola la spinta a cominciare e il suo slancio si posa sopra un impegno tuo in corso, che reclamava mani libere. Due accensioni vive insieme vogliono entrambe le braccia.

### capovolta

- 1: Il fuoco resta intero sotto il suo coperchio proprio nell'ora in cui quel progetto tuo chiedeva di essere avviato. Il desiderio non è calato: sta chiuso, mentre la finestra buona passa.
- 2: Trattenuta sotto un timore di sbagliare, la fiamma conserva tutta la sua forza e la tiene per sé nel punto in cui il tuo impegno aveva bisogno della prima mossa. Il rinvio non spegne niente.
- 3: Sotto coperta c'è una fiamma viva e la partenza slitta un'altra volta, mentre la cosa che hai in mano reggeva solo se cominciata subito. Quello che manca non è l'ardore: è il via.

## Due di Bastoni

### dritta

- 1: Un progetto di largo respiro porta il tuo sguardo oltre il confine del conosciuto; il caso che hai portato sta sul terreno su cui hai i piedi.
- 2: La scelta della rotta si offre nel punto in cui la tua pratica chiedeva una mossa già partita: hai il mondo in mano, intanto la partenza resta da fare.
- 3: Il piano che prende corpo rende visibile l'ampiezza delle tue intenzioni, là dove tenevi riservata la parte più ambiziosa della trattativa.

### capovolta

- 1: Una direzione confusa sta ferma sul posto che la tua decisione serbava per un bersaglio nitido: la soglia è presa da una domanda a cui non hai risposto.
- 2: Il timore di osare mette una verifica davanti a ogni mossa, dentro un fascicolo che tenevi già pieno delle tue pratiche da chiudere.
- 3: Stare sulla soglia ti mette al coperto dalle conseguenze e insieme sigilla l'apertura da cui la questione poteva prendere aria.

## Tre di Bastoni

### dritta

- 1: Gli occhi di questa attesa vanno oltre l'orizzonte nell'ora della presa vicina. Il carico che hai mandato fuori naviga e la tua mano resta vuota.
- 2: Questa attesa del ritorno satura di orizzonte lo sguardo che il lavoro vicino ti chiedeva. La decisione da prendere resta senza occhi.
- 3: Al largo chiama questa fiducia nel ritorno. Il lavoro che hai sotto le dita voleva la tua presenza e gli occhi stanno sulle vele non rientrate.

### capovolta

- 1: Quello che torna rientra con un profilo diverso dal tuo. Il momento voleva la forma prevista; il carico approda e la sagoma non combacia.
- 2: Questo rientro mostra la distanza fra la forma attesa e quella che approda, proprio nel punto in cui la tua previsione valeva come un dato fermo.
- 3: Insieme a quello che reggevi approda un carico da riconoscere. La forma nuova chiede una rilettura delle tue attese e le braccia erano pronte per un'altra sagoma.

## Quattro di Bastoni

### dritta

- 1: La celebrazione sigilla come compiuta una cosa che aveva ancora un tratto da fare. Il tuo lavoro contava su quel tratto per arrivare intero fino in fondo.
- 2: Il varco resta pieno di chi celebra e non si libera. La cosa che hai in attesa chiedeva un ingresso sgombro, per passare senza domandare permesso a nessuno.
- 3: Questa festa porta l'opera finita sotto gli occhi di tutti, là dove la tua intesa riservata contava sul non essere ancora nominata davanti a nessuno.

### capovolta

- 1: Il compiuto resta senza il gesto che lo dichiara. Quello che hai davanti da cominciare aveva bisogno di un punto fermo da cui contare e quel punto non è stato posato.
- 2: L'attesa del momento giusto per celebrare tira tutto verso quel momento, là dove la tua faccenda guardava una stanza già abitata e un uso di tutti i giorni.
- 3: Una casa pronta e mai inaugurata entra fra le tue cose tenute in sospeso, aggiunta a quelle che porti già, col suo ingresso sempre da fissare.

## Cinque di Bastoni

### dritta

- 1: Le spinte che si premono tutte insieme tengono pieno il tavolo che serviva libero per una decisione sola: nessuno comanda questa mischia, cosicché quello che hai da concordare resta nel frastuono.
- 2: Si aggiungono fronti da reggere dove le tue mani erano già piene: ogni parte preme con la stessa forza delle altre, cosicché quello che stai portando avanti ha un contendente in più sul fianco.
- 3: Il calore del misurarsi tira tutti verso la gara, mentre la faccenda che hai davanti guardava all'opera da compiere: l'energia ribolle fra pari, cosicché il tavolo diventa palestra.

### capovolta

- 1: La frizione va avanti a bassa fiamma oltre il punto in cui aveva esaurito il suo motivo: nessuno apre la contesa, nessuno la chiude, cosicché quello che hai da tenere insieme convive col brontolio.
- 2: Il coperchio tiene l'attrito al sicuro dallo scoppio e nello stesso gesto chiude la discussione che la tua faccenda aveva bisogno di sentire per intero.
- 3: Molte piccole contese restano da tenere in piedi, una per fronte, dove le tue mani erano già occupate: ognuna chiede la sua dose di attenzione, cosicché la faccenda che conta divide la provvista.

## Sei di Bastoni

### dritta

- 1: L'acclamazione porta in piazza il merito che il tuo accordo teneva fra poche persone: il riconoscimento si fa pubblico, con gli occhi di tutti sopra quello che hai fatto.
- 2: Arriva l'onore sulla cosa che il tuo passaggio delicato aveva bisogno di tenere in sordina: il corteo si forma, le teste si girano, il nome detto resta in mezzo alla sala.
- 3: Il riconoscimento prende tutte le ore che la tua prova seguente teneva libere per lavorare: la stima detta in pubblico chiama risposte, saluti, parole da restituire a ciascuno.

### capovolta

- 1: Verso lo sguardo che non si posa tira l'attenzione, mentre il lavoro fatto per il tuo progetto chiedeva mani sul pezzo: il merito sta intero e senza nessuno che lo chiami per nome.
- 2: Il valore si tiene per sé come cosa di casa, al riparo da chi lo misurerebbe: la conferma detta che il tuo patto con il gruppo chiedeva resta fuori dalla porta.
- 3: Tarda la parola di stima nel tempo in cui il tuo impegno contava su un merito dichiarato: il lavoro sta tutto lì, fatto, con il posto dell'applauso vuoto.

## Sette di Bastoni

### dritta

- 1: La difesa del terreno che hai già preso lo protegge e nello stesso gesto lo chiude, perché la posizione tenuta in alto trattiene fuori anche l'intesa che stava salendo. Il vantaggio è reale.
- 2: Tieni il punto da una posizione in vantaggio e quella stessa altura serra il varco da cui una proposta utile avrebbe potuto raggiungere la tua faccenda. Il presidio copre il campo insieme al passaggio.
- 3: Dall'alto la guardia su quello che è tuo tiene fuori tutto quanto, compresa la parte che il tuo lavoro stava aspettando di far entrare. La fermezza protegge il luogo e sigilla la porta.

### capovolta

- 1: La guardia continua oltre i lati che la tua faccenda aveva davvero da tenere e si distende su quelli già quieti. Difendere tutto insieme distribuisce la tenuta su un perimetro che nessuno preme.
- 2: Resistere non si arresta dove il campo si era fatto tranquillo: la difesa si estende a ogni lato, compreso quello da cui la tua richiesta attendeva risposta. Il perimetro cresce; le braccia sono quelle.
- 3: Troppi fronti insieme restano presidiati e la tenuta prosegue dove la pressione era già finita, mentre la parte della tua faccenda che chiedeva una mano aperta ne incontra una chiusa. La stanchezza è della sentinella.

## Otto di Bastoni

### dritta

- 1: La corsa dei fatti non si arresta al segno in cui il tuo caso avrebbe avuto bisogno di una sosta: le risposte si accavallano mentre tu stai leggendo la prima.
- 2: Il movimento che viene da fuori entra nel punto in cui la tua pratica chiedeva tempo fermo: la fretta è nell'aria, intanto il tuo documento resta da rileggere.
- 3: Molte notizie insieme portano materia nuova da tenere a mente, sopra la decisione che hai in preparazione da tempo.

### capovolta

- 1: I ritardi cadono nel punto in cui la tua pratica aveva bisogno che tutto capitasse nella stessa ora: il tempo si allunga; la trattativa che hai in corso chiedeva coincidenze.
- 2: La fretta finita nel posto sbagliato sposta la tua attenzione sulle mosse da recuperare; il punto che avevi messo in cima riguardava la bontà del risultato.
- 3: Un inciampo nella sequenza porta alla luce il disordine che tenevi nascosto, dentro la parte della tua pratica in cui volevi apparire in ordine.

## Nove di Bastoni

### dritta

- 1: Questa guardia da reduce tiene occupato con la vigilanza il posto che l'accoglienza voleva libero. I segni dei colpi già presi stanno sul lavoro che hai davanti.
- 2: Lo scudo alzato difende quello che è quasi concluso e nello stesso gesto lo chiude a quello che potrebbe aggiungersi. La tua tenacia serra il perimetro.
- 3: La resistenza prosegue dopo il momento di posare lo scudo. La fermezza che ti ha portato fino a questo punto non conosce una pausa.

### capovolta

- 1: Le ferite già prese leggono come assalto il gesto di chi bussa. Questa diffidenza mette sentinelle nel varco che serviva aperto al tuo visitatore.
- 2: Sui colpi già ricevuti prende la mira questa guardia. Chi arriva senza armi aspettava il tuo credito e l'attenzione resta sulle offese di prima.
- 3: Una corazza indurita difende quello che ti resta e nello stesso gesto serra la porta a chi si avvicina in pace. La memoria dei colpi decide chi passa.

## Dieci di Bastoni

### dritta

- 1: Il fascio che porti tiene occupate entrambe le tue braccia fino all'ultima presa. La cosa di cui chiedi voleva una mano sgombra per essere raccolta.
- 2: Questo portare prosegue oltre il tratto che era tuo da coprire, perché il fascio non si posa prima dell'arrivo. Una verifica a mezza via voleva proprio una sosta per essere fatta.
- 3: Nuove responsabilità vere si sommano a quelle che reggi già, perché ogni cosa in arrivo trova spalle che la prendono. Il legame che aspettava le tue ore vuole quelle stesse ore.

### capovolta

- 1: Il fardello tira le tue forze verso cose che portano il nome di altri, tenute per abitudine, là dove quello di cui chiedi guardava una faccenda tua rimasta indietro.
- 2: Portare quello che spetta ad altri tiene al riparo la pace con loro e con lo stesso gesto chiude il discorso su chi deve cosa. Il chiarimento che hai in sospeso stava là.
- 3: Cose intestate ad altri si sommano alle tue sulle medesime spalle, perché il senso del dovere le accoglie tutte. La faccenda che aspetta le tue mani vuole quelle mani libere.

## Fante di Bastoni

### dritta

- 1: Un annuncio fresco bussa alla porta proprio dove il tuo lavoro avviato chiedeva di essere portato a termine: la novità vuole essere seguita subito, appena recapitata.
- 2: Verso l'esplorazione tira questa curiosità giovane, mentre la faccenda che hai davanti guardava al compimento: il messaggero porta terre da vedere invece della firma che aspettavi.
- 3: Il recapito dell'annuncio porta allo scoperto un tuo riserbo: il messaggero racconta subito quello che ha visto, senza sapere quali porte erano chiuse.

### capovolta

- 1: Le partenze nuove tengono pieni i posti dove doveva stare una sola cosa da finire: ogni accensione scalza quella di prima, cosicché quello che hai cominciato resta senza il suo turno.
- 2: Il ricambio va avanti oltre il punto in cui una scelta sola bastava: appena una fiamma prende, un'altra la spegne, mentre la cosa che hai in mano aspetta un seguito che duri.
- 3: Si accumulano aperture da tenere accese dove le tue mani erano già piene: ciascuna pretende lo slancio della prima volta, cosicché la faccenda cominciata divide il fiato con le altre.

## Cavaliere di Bastoni

### dritta

- 1: La corsa non si ferma al punto in cui il tuo accordo chiedeva una sosta per contarsi: l'ardore seguita, sella e mantello, verso la cosa desiderata e lontana.
- 2: L'avventura appena vista si porta dietro tutto il calore del corpo, mentre il legame che il tuo patto tiene in piedi aspettava una presenza ferma alla porta di casa.
- 3: Il moto sta sopra il tempo che la tua prova lenta chiedeva fermo: la passione parte di persona, col gusto della strada aperta e la meta tenuta d'occhio da lontano.

### capovolta

- 1: Un'altra partenza entra fra le cose aperte dove le mani del tuo lavoro ne reggevano già tre: la foga aggiunge slanci da tenere vivi tutti insieme.
- 2: La fretta si distende su tutte le ore che il tuo patto teneva libere per una cosa sola: l'impazienza manda avanti il corpo prima del gesto e le partenze si moltiplicano.
- 3: Scatta lo slancio nell'ora in cui la tua pausa di respiro era appena cominciata: l'ardore si accende intero, caldo, con la sella messa prima che la cosa sia pronta.

## Regina di Bastoni

### dritta

- 1: Il calore della tua presenza tira su di te l'attenzione di tutti, mentre quello che hai messo in piedi chiedeva occhi puntati sul lavoro. L'attrazione è vera e sposta il centro su chi la emana.
- 2: Magnetica, la tua figura porta il centro della scena su se stessa e la faccenda in corso scivola di lato, mentre chiedeva di stare in mezzo. Scaldi chi ti sta intorno; il fuoco resta il tuo.
- 3: Sicurezza e calore attirano le persone verso di te ed è lì che finisce lo sguardo che la tua proposta aveva bisogno di ricevere. Il richiamo funziona: tira da una parte sola.

### capovolta

- 1: Il paragone con un'altra fiamma porta allo scoperto il dubbio su di te che il tuo lavoro teneva ben coperto. Quello che si vede di te cambia prima della cosa in gioco.
- 2: Una gelosia accesa fa uscire in piena vista l'incertezza sulla tua stessa presenza, quella che la faccenda in corso manteneva dietro una tenuta sicura. Il confronto rivela il punto scoperto.
- 3: Sotto il confronto con chi brilla accanto a te si scopre quanto poco ti riconosci, mentre il tuo progetto contava su una sicurezza mostrata senza crepe. La materia esposta è la fiducia in te.

## Re di Bastoni

### dritta

- 1: Una guida generosa che accende gli altri porta frutto a chi ti segue; il punto su cui hai chiesto riguarda la parte che spetta soltanto a te.
- 2: L'esempio che vuoi dare orienta la tua volontà verso il pubblico che ti osserva; la pratica che hai aperto aspettava una decisione presa in silenzio.
- 3: Il tuo slancio va avanti oltre il confine in cui la trattativa si era fermata: indichi una meta nuova e il punto precedente aspetta ancora la tua firma.

### capovolta

- 1: La spinta senza ascolto tira dritto oltre la soglia in cui il tuo caso chiedeva una pausa per sentire: l'autorità insiste e la parte davanti a te si irrigidisce.
- 2: Un comando impaziente siede nel posto che l'ascolto teneva libero: la trattativa che hai aperto aveva messo lì una domanda che aspetta ancora.
- 3: Si vede allo scoperto il punto in cui non cedi, perché la rigidità con cui tieni il campo lo espone, là dove la tua pratica guadagnava dal margine coperto.

## Asso di Coppe

### dritta

- 1: Buona per il cuore che si apre, questa piena si rivolge a un destinatario diverso. Il contegno che la faccenda ti chiedeva resta in piedi e l'acqua nuova sgorga.
- 2: La coppa versa oltre il proprio orlo. Un riserbo bastava al punto in cui ti trovi e il sentimento nuovo arriva anche là.
- 3: Questa piena aggiunge un sentire da portare sopra un impegno già colmo. La sorgente dà acqua nuova e la faccenda che tratti voleva le tue mani libere.

### capovolta

- 1: Un'acqua trattenuta colma il recipiente che occorreva vuoto per ricevere. Il sentimento esiste e resta chiuso a chiave; la parola da dire aspetta il tuo turno.
- 2: Il coperchio difende il tuo sentire dal rischio di soffrire e nello stesso gesto serra quello che chiedeva di uscire. La sorgente sta sotto e non dà acqua.
- 3: Dove le tue mani erano già occupate entra un sentimento non detto da custodire. Il recipiente resta sigillato e l'acqua dentro sale.

## Due di Coppe

### dritta

- 1: Il bene di questo patto cade sul legame che lo stringe e su nessun'altra cosa. La tua faccenda si decide da una parte sola e non ammette un secondo firmatario.
- 2: L'intesa a due mette al riparo le parole scambiate e col medesimo sigillo chiude il cerchio sulle due parti, là dove quello che hai in gioco voleva un terzo tavolo e altre mani.
- 3: Un pegno scambiato vale oltre la prova che bastava, perché il sigillo non conosce il termine breve. Quello che hai aperto voleva restare valido per un tempo contato.

### capovolta

- 1: Il senso sbagliato di una frase sta al posto di quello giusto e non lo cede. Il tuo chiarimento aveva bisogno di quel posto per entrare con le parole vere.
- 2: Una frase detta bene tira verso un significato che non era il suo e porta là l'attenzione di entrambi. La cosa che hai in gioco stava dove nessuno dei due guardava più.
- 3: Quello che ciascuno dei due pensava senza dirlo viene allo scoperto per via del malinteso: il riserbo che tratteneva quelle parole era quanto il tuo legame aveva in gioco.

## Tre di Coppe

### dritta

- 1: Questa allegria divisa fra amici fa bene ai legami intorno al tavolo, mentre la cosa che hai chiesto riguardava un lavoro da sbrigare in disparte: il brindisi chiama compagnia.
- 2: La compagnia riempie le ore che servivano vuote: bicchieri alzati, una casa aperta, nomi cari che arrivano uno dopo l'altro, mentre il tuo lavoro voleva una stanza silenziosa.
- 3: Il brindisi porta nel cerchio una cosa che stava fra te e qualcuno: la gioia chiede di essere raccontata a tutti, cosicché quello che era riservato gira di mano in mano.

### capovolta

- 1: Si aggiungono legami da mantenere dove le tue mani erano già piene: ogni presenza di cortesia chiede il suo turno di cura, cosicché la cosa che conta per te divide l'attenzione con molte.
- 2: Le presenze di facciata tengono occupati i posti dei pochi nomi fidati: il cerchio resta largo mentre il tuo legame più vero chiedeva una conversazione a due.
- 3: Verso il numero degli invitati tira questa cerchia allargata, mentre quello che hai davanti guardava alla qualità di un legame: il giro si estende, la confidenza si assottiglia.

## Quattro di Coppe

### dritta

- 1: La sazietà fa da riparo contro il desiderio e abbassa le palpebre: la proposta che il tuo legame aveva messo accanto resta tesa, intatta, senza uno sguardo che la soppesi.
- 2: Verso quello che hai già in mano gira l'attenzione intera, mentre l'apertura che il tuo giro di persone aveva preparato sta al lato e aspetta di essere guardata.
- 3: Il torpore si siede dove il tuo patto nuovo chiedeva appetito: la noia tiene la mano ferma e quello che arriva accanto non riesce a interessare.

### capovolta

- 1: Torna il gusto proprio mentre il tuo riserbo teneva quieta una cosa messa da parte: l'appetito si riapre sopra di lei e la mano si muove verso quel lato.
- 2: L'interesse risvegliato porta in luce la proposta che il tuo silenzio teneva fuori dal tavolo: quello che stava accanto riceve uno sguardo e diventa materia di discorso.
- 3: Un desiderio nuovo si aggiunge alle cose vive della tua giornata, che di roba da seguire ne aveva già quanto bastava: il cuore ridestato chiede posto per una curiosità.

## Cinque di Coppe

### dritta

- 1: Il rimpianto tira il tuo sguardo verso quello che si è versato ed è là che resta, mentre la parte in piedi ti sta dietro le spalle e attende di essere contata.
- 2: Quanto è andato perduto chiama gli occhi a sé con una forza vera, lasciando alle spalle la parte intera su cui la tua scelta dovrebbe appoggiarsi. Lo sguardo è girato dalla parte del vuoto.
- 3: Davanti a te sta il versato e la tua attenzione lo segue tutta intera, mentre il resto che regge in piedi aspetta dietro, fuori dal campo visivo di chi deve decidere.

### capovolta

- 1: L'accettazione che ti rialza chiude il conto con quello che è andato e nello stesso gesto chiude la richiesta che il tuo lavoro aveva bisogno di tenere aperta. Il perdono archivia il fascicolo intero.
- 2: Volgendoti verso quello che resta, metti pace dove c'era il lutto e insieme metti un coperchio sulla pretesa che non era stata detta. La ripresa protegge te; sigilla anche il punto.
- 3: Il dolore lascia posto alla speranza ed è un bene vero, mentre lo stesso movimento serra una partita della tua faccenda che reggeva solo da aperta. Ti rialzi: la porta si chiude dietro.

## Sei di Coppe

### dritta

- 1: Una tenerezza che viene dal passato nutre il bambino che eri; il rapporto fra adulti su cui hai chiesto porta pretese di oggi.
- 2: Il calore dei ricordi cari ti avvolge e con lo stesso movimento chiude la porta da cui l'affetto nuovo doveva entrare nella tua giornata.
- 3: Torna dal passato un affetto sincero che attira il tuo interesse verso il tempo da cui viene; il legame che vivi adesso aspettava di essere guardato per sé.

### capovolta

- 1: La memoria di un tempo buono tiene pieno il vuoto che la tua giornata serbava per una presenza nuova venuta da fuori.
- 2: Un tempo che non c'è più domanda una cura continua da tenere in piedi, accanto ai tuoi legami vivi che reggi ogni giorno nel presente.
- 3: Il ritorno di una dolcezza antica capita nel punto in cui la tua giornata chiedeva presente pieno: il ricordo scalda, intanto il tavolo di oggi aspetta la tua mano.

## Sette di Coppe

### dritta

- 1: Queste immagini ingombrano il posto che una scelta sola voleva libero. Ogni coppa promette un contenuto e il tuo sguardo non ha visto i fondi.
- 2: Sul contenuto promesso trascina l'occhio questa fantasia. La prova dei fatti aspettava il tuo esame e le figure schierate restano in primo piano.
- 3: Ogni possibilità in più da reggere entra dove una decisione sola era già abbastanza. Le coppe si moltiplicano davanti a te e ciascuna porta la sua offerta.

### capovolta

- 1: Il frutto di questa messa a fuoco cade sul desiderio che hai riconosciuto. Le porte che ti conveniva tenere aperte restano da un'altra parte.
- 2: Questa decisione custodisce il desiderio verificato e nello stesso gesto chiude le offerte che stavano accanto. Quello che ti resta in mano è uno.
- 3: La cernita prosegue dopo il desiderio messo a fuoco. Le possibilità che ti servivano da parte cadono con le altre e lo scarto non si ferma.

## Otto di Coppe

### dritta

- 1: La partenza si compie su una cosa ancora intera, perché il congedo non attende nessun guasto per muoversi. Il tuo legame contava su una presenza che restasse.
- 2: Quel cercare un senso più alto nutre una fame tua che non ha ancora nome, là dove la faccenda in gioco voleva un custode fermo al suo posto fino alla fine.
- 3: Il congedo senza parole tira verso un senso che non ha ancora un nome. L'accordo rimasto in sospeso voleva presidiata proprio la cosa che ti lasci dietro.

### capovolta

- 1: La sosta sulla porta dura mentre quello che hai in gioco chiedeva una presenza intera in uno dei due luoghi, perché la partenza è cominciata dentro e il corpo è rimasto fermo.
- 2: Questo stare fra il restare e l'andare prosegue oltre il punto in cui una delle due case voleva la tua risposta, perché entrambe restano guardate e nessuna viene chiusa.
- 3: Un secondo luogo da tenere si aggiunge a quello che hai già, perché la soglia non consegna nessuno dei due. Le tue mani reggevano appena il primo.

## Nove di Coppe

### dritta

- 1: Questo appagamento fa bene a quello che hai già ottenuto, mentre la cosa che hai chiesto riguardava una faccenda non ancora avviata: la contentezza siede davanti alla tavola imbandita.
- 2: La pienezza mette al sicuro quello che hai raccolto e nello stesso gesto chiude la porta alla domanda successiva: davanti alla tavola servita la fame tace.
- 3: Arriva il contento dell'augurio esaudito proprio dove la faccenda che hai davanti chiedeva fame: il desiderio appagato posa le mani in grembo.

### capovolta

- 1: Verso il godimento a portata di mano tira questa sazietà di facciata, mentre quello che hai davanti guardava a un desiderio vero: il piacere consumato riempie l'ora, poi lascia il suo posto vuoto.
- 2: La soddisfazione messa in mostra porta in piazza una tua faccenda privata: la facciata chiede spettatori, cosicché quello che stavi valutando in silenzio diventa materia da far vedere.
- 3: Continua il consumo oltre il punto in cui la fame era passata: un piacere chiama il successivo, mentre quello che hai davanti aspettava che un desiderio venisse nominato.

## Dieci di Coppe

### dritta

- 1: L'armonia fra le persone di casa compie il cerchio degli affetti e lo tiene pieno: la gioia tocca i tuoi, mentre la decisione che il tuo lavoro chiede a te soltanto sta fuori dal tetto.
- 2: La pienezza condivisa occupa le ore che la tua scelta solitaria chiedeva vuote: l'amore attorno si fa ricchezza e tiene il tavolo apparecchiato per tutti.
- 3: Sotto gli occhi di parenti e vicini la casa in festa porta quello che il tuo riserbo teneva fra due persone: il legame felice diventa cosa di tutti.

### capovolta

- 1: Ognuno dei tuoi tira verso la propria parte, mentre il patto di casa chiedeva una parte sola: la distanza fra le persone sotto un tetto apre più fronti a tavola.
- 2: Nuove tensioni fra parenti si aggiungono a quello che la tua casa teneva già in piedi: la discordia porta altri fronti da presidiare sotto un tetto solo.
- 3: Viene a galla la crepa fra le persone di casa che le pareti di famiglia tenevano dentro: la distanza si fa visibile a chi entra e siede al tuo tavolo.

## Fante di Coppe

### dritta

- 1: La tenerezza appena nata fa bene alla tua vita interiore e porta poesia dentro di te, mentre quello che hai sul tavolo chiedeva una presa ferma. Il germoglio nutre il sentire, non la pratica.
- 2: Un'emozione fragile affiora e trova il suo posto nel tuo mondo intimo, dove è giusta e preziosa, mentre la faccenda aperta aveva bisogno di mani esperte. Il dono è reale e sta altrove.
- 3: Fiorisce in te una sensibilità che è un bene autentico per chi la sente la prima volta; la cosa concreta che attende una risposta non si nutre di quel fiore. Il bene c'è ed è rivolto dentro.

### capovolta

- 1: Il muro alzato intorno a una sensibilità giovane tiene pieno il varco da cui la tua faccenda attendeva una risposta sentita. Dentro c'è un cuore intatto; sopra c'è una parete nuova.
- 2: Dopo il primo colpo la chiusura occupa tutto lo spazio in cui al tuo legame serviva un'apertura piccola. Il riserbo è pieno quanto un mobile messo davanti alla porta.
- 3: Una protezione messa su in fretta riempie il passaggio che il tuo legame aveva bisogno di trovare libero, mentre il sentire resta vivo dietro di essa. La parete sta dove serviva il vuoto.

## Cavaliere di Coppe

### dritta

- 1: La proposta che arriva con grazia svela un sentimento che tenevi riservato, nel rapporto in cui la tua scelta era di restare sul generico.
- 2: Un corteggiamento garbato fa bene al gusto dell'incontro; la questione che hai posto riguarda un impegno già preso con qualcuno.
- 3: Il richiamo della bellezza porta il tuo sentimento verso chi lo invita, mentre la trattativa affettiva che avevi aperto chiedeva una parola sul domani.

### capovolta

- 1: Le promesse vaghe depositano parole da verificare, oltre i gesti che tu stavi già contando uno per uno nelle settimane passate.
- 2: Un'illusione senza appoggio si posa nel punto in cui il legame chiedeva prove durevoli: il discorso è bello, intanto la verifica che hai chiesto resta da fare.
- 3: Il detto sta nel posto che il fatto teneva libero: il rapporto che hai in corso aspettava un gesto compiuto e si trova davanti una frase.

## Regina di Coppe

### dritta

- 1: A chi ti sta davanti giova questa discesa nel fondo. Il dato da mettere sul tavolo aspetta e l'empatia porta il suo frutto sulle persone.
- 2: Nel fondo di chi hai vicino scende questa sensibilità. La faccenda da stabilire chiedeva il tuo giudizio e l'attenzione resta su quello che l'altro sente.
- 3: Questa comprensione mostra il fondo di chi hai davanti, proprio quando quel fondo stava coperto per un motivo. Quello che leggi negli altri viene a galla.

### capovolta

- 1: Il sentire di chi ti sta accanto entra nell'ora in cui il tuo serviva per decidere. Quello che provi arriva da fuori e sostituisce quello che era tuo.
- 2: Gli stati d'animo degli altri prendono il posto che il tuo sentire aveva sulla faccenda. Dentro di te parla l'acqua venuta da fuori.
- 3: Al carico che portavi si somma lo stato d'animo di altre persone da reggere. L'acqua di fuori entra senza argine e le tue braccia ne tenevano già abbastanza.

## Re di Coppe

### dritta

- 1: Questa calma giova a chi si appoggia a te e tiene aperto il porto per gli altri, là dove la faccenda su cui chiedi voleva un segno scomposto e non una tenuta esemplare.
- 2: Il governo adulto dei sentimenti ripara il tavolo dall'onda e nel medesimo comando serra lo scatto che avrebbe detto quanto quella cosa conta per te. L'altra parte aspettava quello.
- 3: La calma visibile mette allo scoperto il disordine di chi ti sta davanti: il riserbo su quel disordine era quanto teneva in piedi il discorso in corso.

### capovolta

- 1: L'umore del giorno siede al posto del governo e non lo restituisce. La faccenda che hai in gioco chiedeva quel posto libero, per una mano ferma che la tenesse.
- 2: Lo stato d'animo tira tutto verso quello che vuole ottenere e piega a quel fine la tua sensibilità matura. Quello su cui chiedi stava altrove, fuori da quel tornaconto.
- 3: Il sentimento usato come leva mostra a chi ti sta davanti il meccanismo con cui chiedi le cose, là dove l'accordo in gioco contava su quel meccanismo non visto.

## Asso di Denari

### dritta

- 1: Si aggiunge una cosa solida da coltivare dove le tue mani erano già piene: il seme offerto chiede terra, acqua, un angolo di tempo, mentre quello che porti avanti ne occupa altrettanto.
- 2: Questa solidità fa bene a quello che si pesa e si tiene in mano, mentre la faccenda che hai chiesto riguardava un chiarimento fra persone: il seme risponde al terreno che lo riceve.
- 3: Un principio concreto si apre proprio dove quello che hai già messo a terra chiedeva di essere chiuso: la materia nuova arriva intera, pronta per una semina che comincia da capo.

### capovolta

- 1: Verso il calcolo del rischio tira la tua attenzione, mentre la cosa che hai davanti sta ferma sul tavolo a portata di braccio: la stima del valore si prende il tempo della raccolta.
- 2: Un'apertura concreta resta posata dove l'hai lasciata, proprio mentre la faccenda su cui decidi chiedeva che fosse già in mano: il valore vero sta sotto la cifra che le hai dato.
- 3: La prudenza tiene quella cosa al sicuro sul tavolo e nello stesso gesto la chiude fuori dal conteggio di quello che hai in mano: il valore resta intatto, fermo dove sta.

## Due di Denari

### dritta

- 1: La giocoleria non lascia scendere niente, anche dove il tuo impegno chiedeva una cosa posata sul tavolo: le mani seguitano a passare da una all'altra, leggere, senza scegliere.
- 2: Il ritmo tiene piene le mani che la tua decisione chiedeva libere: ogni impegno passa all'altro con leggerezza e nessuno trova il tempo di stare giù.
- 3: Tenere insieme molte cose rende piena e viva la tua giornata: la leggerezza lavora per quella, mentre la cura lunga che il tuo progetto chiedeva sta davanti a mani in movimento.

### capovolta

- 1: Una cosa in più entra nel giro dove le tue mani ne reggevano già troppe: il ritmo rotto chiede di tenere anche quella e qualcosa comincia a scivolare.
- 2: Si rompe la cadenza mentre la tua giornata contava su un passo uguale: le cose in aria scendono fuori misura e la mano arriva dopo quella che cade.
- 3: Verso quella che sta scivolando corre tutta l'attenzione, mentre le altre faccende del tuo lavoro giravano a tempo e chiedevano la mano alzata.

## Tre di Denari

### dritta

- 1: L'opera a più mani aggiunge turni e incastri da tenere insieme, dove la tua giornata era già piena per conto suo. Il mestiere di chi costruisce accanto entra come materia buona da reggere.
- 2: Collaborare porta competenza vera sul cantiere e insieme porta la cura di tenere allineate mani che non sono le tue. Quello che cresce bene cresce con più pesi da portare.
- 3: Il riconoscimento del tuo lavoro arriva dentro un'impresa condivisa ed è proprio la condivisione a metterti in braccio un impegno ulteriore: tenere il passo di chi lavora al tuo fianco.

### capovolta

- 1: I compiti sovrapposti mandano due mani sullo stesso pezzo nell'ora in cui ne serviva una sola, mentre un altro pezzo del tuo cantiere resta senza nessuno. L'opera c'è: i tempi delle mani non combaciano.
- 2: Ruoli non distinti fanno cadere il doppio lavoro proprio quando il tuo progetto aveva bisogno di un solo responsabile per quel tratto. Il gruppo c'è ed è sfasato sul pezzo che conta.
- 3: Dove serviva una mano sola ne arrivano due mentre il tratto scoperto attende il suo turno: l'intesa fra chi costruisce cade fuori sincrono rispetto a quello che hai in corso.

## Quattro di Denari

### dritta

- 1: La mano chiusa sopra i beni che possiedi mette al sicuro il tuo avere e con quel gesto stesso blocca l'ingresso da cui l'apporto nuovo doveva arrivare.
- 2: Un controllo accurato sui beni tiene impegnato il margine che la tua trattativa serbava libero per muovere un'offerta a chi aspetta.
- 3: Il gesto di custodire non si interrompe quando il tuo bene è già al riparo: la stretta tiene, poi seguita a tenere anche sul punto che chiedeva una tua apertura.

### capovolta

- 1: La presa non si allenta dopo il segno in cui il tuo bene era già protetto: il timore di perdere insiste sulla stretta; il legame che hai in gioco chiedeva mani morbide.
- 2: Un timore di perdere mostra il prezzo che dai ai beni che hai, là dove la trattativa guadagnava dal silenzio su questa stima.
- 3: Il bisogno di trattenere porta altri beni sotto sorveglianza, in cima all'impegno che hai appena preso con qualcuno.

## Cinque di Denari

### dritta

- 1: Il freddo del fuori si sente nell'ora in cui ti occorreva sentirti dentro. La soglia resta davanti e la luce della stanza si vede dal vetro.
- 2: Alla finestra accesa resta appeso questo sguardo da fuori. La faccenda che hai fra le mani aspettava di essere ripresa e l'attenzione sta sul riparo degli altri.
- 3: Questa esclusione mostra la soglia che non avevi guardato, proprio quando il tuo legame con gli altri sembrava dato. Il dentro e il fuori hanno un confine visibile.

### capovolta

- 1: Il rientro al caldo arriva nell'ora in cui ti occorreva lo sguardo del fuori. La porta si apre sulla stanza e quello che vedevi dalla neve si perde.
- 2: Al corpo che aveva freddo giova questo tetto ritrovato. Il punto da decidere viveva della tua distanza e il sostegno riguarda la stanza.
- 3: Questo riparo difende il passo che rientra e nello stesso gesto chiude la veduta che avevi dal fuori. Il caldo accoglie e la finestra resta alle tue spalle.

## Sei di Denari

### dritta

- 1: La generosità rimette in moto lo scambio e tiene in piedi chi riceve la parte. Quello che hai in gioco voleva una cosa trattenuta per te fino in fondo.
- 2: Il piatto che pende dalla parte di chi dà ripara chi prende dalla mancanza e col medesimo gesto fissa chi dei due sta più in alto: la parità era quanto il tuo rapporto aveva in gioco.
- 3: Una cosa da rimandare indietro si aggiunge a quelle che l'altra mano tiene già, perché il dono pesato chiama il suo ritorno. Il legame che hai in gioco voleva mani libere.

### capovolta

- 1: Quel dare va alla mano che prende e a nessun'altra. La faccenda su cui chiedi aveva bisogno di una riserva tua intatta per essere portata fino in fondo.
- 2: La generosità tira verso la mano che non ricambia e porta là quello che hai, mentre il legame alla pari su cui chiedi voleva proprio quella parte.
- 3: Il dare prosegue oltre il punto in cui lo scambio aveva già avuto la sua parte, perché una mano che non rimanda niente non segna mai il termine. La tua riserva era quanto serviva.

## Sette di Denari

### dritta

- 1: Una pausa di chi valuta si apre proprio dove la cosa che hai davanti chiedeva una mano subito: la pianta sta crescendo col suo tempo, cosicché il gesto resta appoggiato all'attrezzo.
- 2: L'attesa custodisce il frutto fino al punto buono e nello stesso gesto tiene chiuso il raccolto che il tuo progetto voleva già nel paniere.
- 3: Il tempo della maturazione tiene pieno il periodo in cui serviva un atto: guardare crescere è l'occupazione di queste giornate, mentre quello che hai cominciato resta in fila per il suo turno.

### capovolta

- 1: La mano continua a tirare il frutto oltre il punto in cui il ramo si era fermato: l'impazienza prova un altro strappo, mentre il tuo raccolto chiedeva le sue settimane.
- 2: Verso il conteggio della resa tira questo sospetto sulla fatica spesa, mentre la faccenda che hai davanti guardava alla pianta: il dubbio sul seme sostituisce la cura.
- 3: Arriva lo strappo prima della stagione, mentre quello che hai seminato chiedeva il suo tempo intero: la fretta del raccolto giudica il seme dalla fatica che è costata.

## Otto di Denari

### dritta

- 1: La mano torna sullo stesso dettaglio un colpo per volta oltre il giorno in cui il tuo accordo chiedeva il pezzo consegnato: la finitura seguita a chiedere la misura esatta.
- 2: Il banco di lavoro tiene il mestiere al sicuro dentro i suoi confini: la cura del dettaglio tiene gli occhi bassi, mentre la tua promessa a chi aspetta stava ferma alla porta.
- 3: Dedizione e pratica paziente stanno su tutte le giornate che la tua faccenda larga chiedeva sgombre: il gesto ripetuto tiene accesa la lampada del banco dall'alba.

### capovolta

- 1: Il gesto esatto dura oltre il giorno in cui il senso che lo muoveva è uscito dalla porta: la mano tiene la misura, mentre la tua giornata chiedeva una ragione detta.
- 2: Arriva la monotonia sopra la cura viva che il tuo progetto chiedeva sul pezzo: il mestiere gira esatto e vuoto, con le ore scandite dal gesto e non dal gusto.
- 3: Si vede nel pezzo finito la mancanza di anima che il tuo lavoro teneva per sé: la misura è giusta e chi guarda sente che dentro non c'è nessuno.

## Nove di Denari

### dritta

- 1: L'autonomia che hai costruito fa bene al tuo giardino e lo tiene in fiore da sé, mentre la faccenda aperta chiedeva di poggiare su qualcuno. Il bene è pieno ed è rivolto al recinto.
- 2: Bastare a sé è un frutto vero del tuo lavoro e nutre la quiete dentro il recinto, dove tutto è a posto; il punto che attende una risposta vive invece di mani in più. Il dono resta dentro il muro.
- 3: Quello che hai messo insieme con le tue mani prospera senza chiedere niente a nessuno ed è giusto goderne, mentre la parte in gioco cresceva solo con un patto a due. L'agiatezza serve il tuo orto.

### capovolta

- 1: L'uscita non si arresta dove l'indipendenza reggeva: quello che hai guadagnato continua a spendersi per farsi vedere, mentre il margine che il tuo impegno teneva da parte si assottiglia a ogni mostra.
- 2: Mostrare quello che possiedi va avanti oltre il punto in cui la tua libertà si sosteneva da sé; la spesa prosegue ben dopo che il bisogno è stato coperto. Il recinto regge: si fa più sottile.
- 3: Continua a uscire più di quanto entra, perché la prova di quello che hai vale una spesa dopo l'altra, mentre la parte libera del tuo lavoro contava su un'uscita che si fermasse prima.

## Dieci di Denari

### dritta

- 1: Una ricchezza che dura porta frutto a chi viene dopo di te; il bisogno che hai portato chiede risposta dentro questa stagione.
- 2: Lo sguardo sulle radici attira il tuo interesse verso le generazioni; la questione che hai portato si gioca con un interlocutore unico.
- 3: La solidità costruita ti protegge dall'incertezza e nello stesso tempo trattiene la disponibilità da cui il cambiamento in esame poteva passare.

### capovolta

- 1: Un attrito sui beni comuni mette in piazza chi pretende che cosa dentro la parentela, là dove la tua pratica reggeva sul riserbo fra parenti.
- 2: La contesa fra chi dovrebbe condividere occupa il tavolo che il bene comune serbava per una gestione concorde: la tua parte resta piena di pretese.
- 3: Beni che appartengono a più di uno portano partite nuove da trattare, sopra il punto che hai messo sul tavolo.

## Fante di Denari

### dritta

- 1: Questo esercizio da allievo tiene pieno il tempo che la consegna ti chiedeva. Quello che impari cresce piano e il risultato da dare aspetta la tua mano.
- 2: Sullo studio tiene l'occhio questa applicazione. La prova da superare voleva il tuo tempo e l'attenzione sta sul compito da imparare.
- 3: Un compito nuovo da imparare entra dove tenevi già una faccenda cominciata. La promessa chiede applicazione e le tue giornate erano piene prima.

### capovolta

- 1: Al prossimo inizio guarda questa promessa. Il seguito di quello che avevi preso aspettava le tue mani e la pagina resta aperta allo stesso punto.
- 2: Dopo il momento di una mano al lavoro questa dichiarazione si rinnova. L'impegno si ridice e la pratica sta dove tu l'avevi lasciata.
- 3: Entra una promessa in più da tenere in sospeso sopra le faccende già cominciate. Lo studio resta sulla pagina e l'elenco dei tuoi impegni cresce di una riga.

## Cavaliere di Denari

### dritta

- 1: Questo metodo fa bene alla tenuta del tuo lavoro nel lungo tratto, là dove la faccenda su cui chiedi voleva una decisione presa in un colpo solo.
- 2: Le tappe regolari tengono piena ogni ora che hai, perché l'andatura non salta niente. La cosa che aspetti chiedeva un'ora sgombra, fuori da quel programma.
- 3: L'andatura prosegue uguale oltre il punto in cui serviva uno strappo, perché la costanza non conosce lo scatto. L'occasione che hai davanti chiedeva precisamente quello.

### capovolta

- 1: La prudenza tira verso la conservazione del piano intatto e tiene là tutte le tue cure. Quello che hai in gioco guardava una prima tappa fatta male piuttosto che nessuna.
- 2: Il rimando mette al riparo il progetto da ogni errore e col medesimo gesto lo chiude dentro il foglio. La prova sul campo era quanto il tuo accordo aspettava.
- 3: Quella costanza prosegue oltre il punto in cui quello che hai in gioco chiedeva una partenza, perché tiene fermo invece di avanzare e non smette per questo.

## Regina di Denari

### dritta

- 1: La cura tiene la casa al caldo e nello stesso gesto chiude la porta sulla faccenda che hai aperto fuori: chi provvede resta dove la dispensa chiede di essere riempita.
- 2: Questa generosità pratica fa bene a chi siede alla tua tavola, mentre la cosa che hai chiesto riguardava una partenza: le mani che nutrono lavorano su quello che è già in casa.
- 3: Le incombenze della provvista tengono pieno il tempo che serviva per altro: la spesa, il pasto, la stanza in ordine, mentre il tuo punto aperto aspetta un'ora libera fra una cosa e l'altra.

### capovolta

- 1: Si aggiungono bisogni altrui da coprire dove le tue mani erano già piene: ogni nome dell'elenco chiede la sua porzione, cosicché la cosa che riguarda te divide la provvista con tutti.
- 2: Verso i bisogni di tutti tira questa cura concreta, mentre la faccenda su cui decidi guardava alla parte che spetta a te: l'elenco si allunga, la riga col tuo nome resta da scrivere.
- 3: L'amministrazione tiene la famiglia al coperto e nello stesso gesto chiude fuori la tua razione: chi passa il pane a tutti tiene il piatto proprio vuoto.

## Re di Denari

### dritta

- 1: La generosità matura fa bene a quello che hai già costruito: l'abbondanza gira dentro la casa solida, mentre il passaggio nuovo che il tuo patto chiedeva sta davanti a una mano che amministra.
- 2: Altri beni da governare arrivano sopra quelli che il tuo lavoro teneva già in ordine: il successo concreto porta cose da reggere, una per una, con misura.
- 3: Mostra in pieno giorno la solidità che la tua discrezione teneva fra poche persone: la prosperità siede al tavolo con tutti e chi entra vede quanto c'è.

### capovolta

- 1: Il possesso difende quello che hai costruito e lo tiene fermo nella stessa presa: l'autorità di chi amministra trattiene il bene, mentre il tuo accordo chiedeva una cosa che circolasse.
- 2: La rigidità di chi comanda riempie lo spazio dove la tua scelta chiedeva aria: l'attaccamento al bene costruito detta la regola del tavolo e non lascia sedie libere.
- 3: Conservare il bene tira a sé la mano matura, mentre il passaggio di mano che il tuo patto aspettava guardava dal lato del dare.

## Asso di Spade

### dritta

- 1: La distinzione netta porta in piena luce quello che un'intesa tua teneva volutamente sfumato: il taglio separa il vero dal falso senza chiedere se quel confine andava mostrato.
- 2: Una lucidità che divide in due mette allo scoperto il punto grigio su cui il tuo accordo si reggeva comodamente. Il vero esce intero: esce anche quando stava bene coperto.
- 3: Dire le cose come stanno è un taglio che non lascia zone incerte ed è proprio l'incerto a scoprirsi, là dove la cosa che hai in corso lavorava di sottinteso. La chiarezza arriva nuda.

### capovolta

- 1: Il taglio portato con la mente offuscata aggiunge parole da ritirare sopra il carico che le tue mani tenevano già, perché la lama resta intera mentre il criterio che la guida è velato.
- 2: Una decisione presa nella nebbia mette fra le cose da reggere anche la riparazione di quello che hai detto male, dove le mani erano piene da prima. Lo strumento funziona; la distinzione no.
- 3: Parole affilate partono senza che il confine fra vero e falso sia chiaro ed è materia nuova da portare: ogni colpo lascia un pezzo da rimettere a posto accanto a quelli che hai già aperti.

## Due di Spade

### dritta

- 1: Il pareggio tenuto a occhi chiusi ti risparmia lo sbaglio e insieme chiude la vista sul punto che la questione metteva davanti a te.
- 2: Una sospensione in equilibrio sta nel punto in cui la tua pratica chiedeva una risposta scritta: quel posto è pieno del rinvio che hai scelto.
- 3: La chiusura degli occhi cade là dove il tuo caso chiedeva uno sguardo lungo: l'equilibrio tiene, intanto la decisione aspetta nel tuo cassetto.

### capovolta

- 1: Il blocco che cede rende visibile la scelta che avevi coperto, nel punto in cui la tua pratica reggeva sul non nominarla.
- 2: Una risposta torna a essere chiesta là dove il tuo caso aveva bisogno di un rinvio: la vista si schiarisce, intanto la pratica che hai aperto non è pronta per la firma.
- 3: La cessione di quel blocco serve alla tua lucidità; il fronte su cui hai chiesto resta fermo su una trattativa che non si è aperta.

## Tre di Spade

### dritta

- 1: La ferita si apre col suo bordo preciso nell'ora in cui ti occorreva il petto sgombro. Il colpo ha un nome e la pioggia cade sulla faccenda che tratti.
- 2: Questo dolore mostra il taglio che tu tenevi coperto, proprio quando il legame reggeva sul non detto. Il pianto nomina quello che restava senza parola.
- 3: Il taglio prosegue dopo la faccenda che l'ha aperto. Il legame che ti serviva intero riceve lo stesso colpo e il dolore passa il punto in cui bastava sentirlo.

### capovolta

- 1: Il perdono porta frutto al cuore che riprende fiato. La ragione del colpo aspettava di essere detta per intero e quella pace tocca il tuo petto.
- 2: Questa cicatrice difende il punto che ha sanguinato e nello stesso gesto chiude l'accesso a quello che tu avevi da dire. Il bordo si salda e la parola resta fuori.
- 3: Questo rimarginare va avanti dopo il colpo. La ragione che ti serviva intera finisce sotto la pelle nuova, anche nella parte che restava da chiarire.

## Quattro di Spade

### dritta

- 1: Il silenzio dopo la fatica rimette insieme le forze e il suo frutto è tutto là. La parola in tempo che la tua faccenda aspettava resta fuori da questo recupero.
- 2: La tregua ripara il recupero da ogni richiesta e col medesimo gesto chiude la stanza dove una risposta era attesa: quell'attesa era quanto hai in gioco.
- 3: Ritirarsi in quiete mette allo scoperto il posto che resta vuoto, là dove il tuo legame contava sul fatto che quel posto sembrasse sempre occupato.

### capovolta

- 1: La ripresa rimette tutto in moto: la tregua che teneva in pace la tua faccenda chiedeva di durare ancora un poco, perché le forze tornate non attendono il tavolo.
- 2: Il ritorno al movimento tira verso le cose che la sosta aveva messo da parte. Quello che hai in gioco stava proprio dentro il fermo che la quiete teneva.
- 3: Uscire dalla sosta rimette in luce una faccenda che la tregua teneva coperta: il riserbo su quel punto era quanto reggeva il tuo accordo.

## Cinque di Spade

### dritta

- 1: Questa riuscita fa bene alla posizione che hai conquistato, mentre la cosa che hai chiesto riguardava una compagnia: il campo resta in mano a chi lo tiene, con gli altri che si allontanano.
- 2: Il campo mostra il prezzo che restava fuori dal computo: le armi raccolte da terra dicono chi se ne è andato, mentre il tuo bilancio contava solo i punti guadagnati.
- 3: L'orgoglio va avanti a tenere il campo oltre il punto in cui la contesa si era conclusa: la mano resta chiusa sull'elsa, intanto che il tuo legame da ricucire aspetta.

### capovolta

- 1: La riconciliazione si affaccia proprio dove il tuo punto chiedeva che la differenza restasse detta: le armi scendono prima che il torto abbia avuto un nome.
- 2: Il perdono mette il legame al riparo e nello stesso gesto chiude la partita che la tua faccenda voleva aperta: le armi posate rinunciano a riscuotere la ragione.
- 3: Questa pace fa bene al rapporto fra le due parti, mentre quello che hai chiesto riguardava un riconoscimento: la mano tesa arriva a chi si era allontanato.

## Sei di Spade

### dritta

- 1: La traversata calma giova all'allontanamento che hai cominciato: il moto piano porta la barca fuori dall'acqua mossa, mentre la presenza ferma che il tuo legame chiedeva resta sulla riva di prima.
- 2: Verso la sponda più quieta tira il remo, mentre la cosa rimasta nel porto vecchio aspettava le tue mani: il passaggio tiene gli occhi avanti e l'acqua si fa piatta.
- 3: Il viaggio sull'acqua mette al coperto dalla tempesta e si lascia dietro la riva che il tuo legame teneva per casa: il tragitto si fa piano, un colpo di remo per volta.

### capovolta

- 1: Una valigia piena di roba vecchia entra nella barca dove il tuo passaggio chiedeva mani libere: il distacco porta con sé materia da tenere stretta.
- 2: Verso la riva lasciata gira il cuore, mentre la tua decisione guardava alla sponda davanti: la partenza avviene con metà dello sguardo indietro.
- 3: Il distacco chiede tempo anche dopo che la tua faccenda nuova era pronta a cominciare: la barca si muove, il cuore resta un poco al molo di prima.

## Sette di Spade

### dritta

- 1: Il silenzio con cui ti muovi tiene pieno il posto in cui il tuo legame aveva bisogno di una parola detta in chiaro. L'ingegno lavora bene e lavora senza annunciarsi.
- 2: Agire di tatto occupa lo spazio della dichiarazione aperta: la manovra laterale riesce e riempie il punto in cui la tua faccenda attendeva di essere messa in chiaro.
- 3: Prendere per la via laterale quello che di fronte non si otterrebbe riempie la casella della richiesta diretta, che il tuo accordo teneva libera per il momento giusto. L'arte riesce.

### capovolta

- 1: Il gioco tenuto coperto sale in superficie da sé e mostra la parte della storia che il tuo accordo manteneva fuori dal tavolo. Quello che emerge pesa su chi lo aveva nascosto.
- 2: Viene a galla quanto era stato taciuto ed esce in vista proprio il passaggio che la tua faccenda teneva sotto il livello dell'acqua. La trasparenza arriva da sola, non su invito.
- 3: Quello che stava sotto affiora e il pezzo nascosto si vede intero, mentre la cosa che hai in corso reggeva precisamente sul fatto che nessuno lo guardasse. L'emersione è in atto.

## Otto di Spade

### dritta

- 1: Il pensiero del vincolo tiene occupato il margine in cui la tua pratica chiedeva una mossa qualunque: dentro ci sta l'inventario dei tuoi limiti.
- 2: Una lista di legacci dichiarati impone calcoli da rifare ogni volta, addosso alla pratica che hai avviato e che aspetta una mossa.
- 3: Le corde e la benda tirano la tua attenzione sui limiti, mentre il punto che hai posto riguardava il margine già largo che hai dietro.

### capovolta

- 1: La spinta verso l'uscita va oltre il segno in cui bastava aprire la porta: il tuo margine è riconosciuto, poi lo slancio seguita sul fronte che chiedeva calma.
- 2: Una liberazione serve alla tua libertà di movimento; il fronte su cui hai chiesto resta legato a un impegno che hai firmato.
- 3: Il margine ritrovato fa vedere lo spazio che avevi, là dove la trattativa reggeva sul far credere che le tue mani fossero strette.

## Nove di Spade

### dritta

- 1: Questi pensieri non lasciano libero il posto del dato. Nelle ore senza sonno la mente racconta e il racconto occupa lo spazio della faccenda che hai davanti.
- 2: La veglia non si spegne col fatto che l'ha accesa. Le faccende che non la riguardano ricevono lo stesso pensiero notturno e la mente passa il punto in cui ti bastava guardare.
- 3: Entrano scene cupe da reggere sopra la faccenda vera da trattare. La mente ne fabbrica altre nelle ore vuote e il peso da tenere cresce senza che la tua giornata cambi.

### capovolta

- 1: Al timore della notte giova questo alleggerirsi. La veglia che ti serviva aperta chiedeva altro e il peso diviso torna leggero dalla parte della paura.
- 2: Questo dire mostra fuori quello che tenevi al coperto, proprio quando la faccenda riguardava soltanto te. Il racconto passa in parole e arriva a orecchie non scelte.
- 3: Il sollievo non si arresta alla paura. La cautela che ti conveniva tenere si scioglie col mattino, anche nel punto in cui la sorveglianza serviva.

## Dieci di Spade

### dritta

- 1: La resa riconosciuta chiude il contendere: la tua trattativa aveva bisogno che restasse aperto almeno un fronte da cui parlare.
- 2: Il fondo toccato resta visibile a tutto il tavolo. Il tuo riserbo su come stanno davvero le cose era la parte su cui l'accordo poggiava.
- 3: Questa chiusura prosegue oltre la cosa che era davvero esaurita e arriva a quello che stava ancora in piedi accanto. Il legame che hai in gioco apparteneva al secondo.

### capovolta

- 1: Il ricominciare da terra tiene occupate le tue mani con le fondamenta. La cosa che aspetti chiedeva un pezzo già pronto da consegnare subito.
- 2: La risalita tira tutto verso un principio tuo da costruire. L'accordo in sospeso guardava quello che restava in piedi da prima e contava di appoggiarsi là.
- 3: Un intero cominciamento da reggere si aggiunge alle cose che porti, perché di prima non resta materia da riusare. La faccenda che aspetta le tue ore ne vuole altrettante.

## Fante di Spade

### dritta

- 1: Chi osserva riporta allo scoperto quello che stava sotto il riserbo della faccenda che hai in corso: il rapporto parte appena raccolto, prima che le porte si aprissero da sole.
- 2: Una notizia riferita appena raccolta arriva proprio dove quello che hai davanti chiedeva una parola pesata: la vigilanza giovane racconta quello che vede mentre lo vede.
- 3: Il raccogliere informazioni va avanti oltre il punto in cui quello che sapevi bastava: ogni dettaglio nuovo chiede un'altra verifica, mentre la faccenda che hai davanti era già pronta.

### capovolta

- 1: La diceria mette in giro quello che la faccenda teneva riservato: una parola non verificata passa di bocca in bocca, cosicché quello che riguarda te viaggia prima di te.
- 2: Il chiacchiericcio tiene pieno il posto dell'informazione controllata: pensieri sparsi girano come se fossero notizie, mentre la tua faccenda aspetta una parola verificata.
- 3: Si aggiungono dicerie da smentire dove le tue mani erano già piene: ogni frase pungente lascia una coda da raccogliere, cosicché la faccenda che segui porta anche questo strascico.

## Cavaliere di Spade

### dritta

- 1: La carica tiene un solo scopo davanti e corre in linea retta anche dopo che il tuo accordo aveva chiesto un fermo per rileggere: quello che sta in mezzo resta dietro al galoppo.
- 2: Detta in corsa, la cosa vista finisce in mezzo al tavolo, mentre il tuo riserbo con quelle persone la teneva fuori: la mente rapida nomina lo scopo e non aspetta il giro di parole.
- 3: Il taglio netto fa bene allo scopo che hai già scelto: la determinazione lavora per quello, mentre il legame delicato che il tuo patto tiene in piedi sta davanti a una corsa che non devia.

### capovolta

- 1: Le parole affilate portano fuori quello che la tua prudenza teneva al coperto: la fretta dice prima di guardare e la cosa detta sta in mezzo alla stanza.
- 2: Scatta la decisione prima del tempo di lettura che il tuo accordo chiedeva: la mente taglia in corsa, con la lama alzata prima che la materia sia girata su tutti i lati.
- 3: Altre parole dette di fretta arrivano sopra quelle che le tue mani tenevano già da ricucire: l'impazienza porta nel discorso materia nuova, buttata lì mentre il passo corre.

## Regina di Spade

### dritta

- 1: La tua franchezza è un dono vero e fa bene alla nitidezza del tuo pensiero, mentre il legame in gioco chiedeva un margine di silenzio prima di sentirsi dire tutto. Il bene c'è: non arriva là.
- 2: Dire il vero senza giri serve alla chiarezza che hai conquistato e tiene puliti i tuoi confini; la cosa aperta sul tavolo cresceva invece su una frase non detta. Il dono è intero ed è altrove.
- 3: Confini chiari e parola onesta fanno un bene autentico a chi li porta, mentre quello che hai in corso si nutriva di un riserbo lasciato in piedi. La sincerità rende: rende ad altro.

### capovolta

- 1: La corazza che indossi ti protegge davvero e nello stesso gesto serra la fessura da cui il tuo legame attendeva di passare. Il giudizio affilato taglia fuori il rischio insieme al resto.
- 2: Una solitudine scelta tiene al sicuro la parte di te che non vuole essere toccata, mentre sigilla il punto in cui la faccenda aperta aveva bisogno di una mano tesa. Il riparo è saldo da ogni lato.
- 3: Difendersi con la durezza funziona: la stessa durezza chiude a chiave la conversazione da cui quello che hai in corso dipendeva. La lama rivolta a te sorveglia la porta.

## Re di Spade

### dritta

- 1: Il giudizio che pronunci espone il criterio con cui decidi, là dove la trattativa reggeva sul tenere riservato il tuo metro.
- 2: Una deliberazione limpida fa bene alla correttezza della materia che tratti; il legame su cui hai chiesto voleva indulgenza più che equità.
- 3: La lucidità con cui separi il vero continua dopo il segno in cui il tuo caso chiedeva di fermarsi: distingui una prima volta, poi torni a dividere le parti che andavano tenute insieme.

### capovolta

- 1: La freddezza con cui tieni la ragione sposta il tuo interesse sulla correttezza dell'argomento, mentre la questione che hai posto riguardava le persone dentro.
- 2: Un rigore senza tenerezza ti difende dal contraccolpo e con lo stesso gesto sigilla la fessura da cui la riconciliazione poteva passare.
- 3: Il bisogno di avere ragione porta discussioni da vincere, accanto ai legami che stavi tenendo su con le tue mani.
