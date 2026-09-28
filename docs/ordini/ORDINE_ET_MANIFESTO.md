# ORDINE ET, I MAESTRI DICONO QUELLO CHE SCRIVONO, TRENTA DOMANDE A OGNI MAESTRO, IL LIVE, LE RUNE, IL VIAGGIO E IL RETRO DELLE SCHEDE

**Sigla:** ET, verificata sul ramo il 28 settembre 2026: in `docs/ordini`
l'ultimo manifesto era `ORDINE_ER_MANIFESTO.md`, in `docs/collaudo` l'ultima
cartella ER; nessun `ORDINE_ES`, `ORDINE_ET`, `docs/collaudo/ES` o
`docs/collaudo/ET`. La sigla ES e' data all'ordine dell'Oroscopo, che il
fondatore lancia dopo questo.
**Data dell'ordine:** 28 settembre 2026, in due pezzi.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Partenza:** commit `ec88e0d9` dell'ordine ER, col cancello di GitHub verde
su quel commit (tredici controlli su tredici). **Questo ordine non consegna
niente**: le build le ordina il fondatore. E il fondatore l'ha ordinata a
lavoro finito, il 28 settembre sera: *"Quando hai finito tutto, crea nuova
Build e consegna su AppTester e pronta per codemagic"*, la 2288 (rapporto,
sezione LA CONSEGNA).

Le quattro voci aperte dell'ordine ER proseguono qui: ER.11 nella ET.05,
ER.12 nella ET.06, ER.01 nella ET.07, ER.02 nella ET.08; nel manifesto ER
ognuna ha la riga che lo dice.

**La stima dichiarata al fondatore prima di cominciare**: circa 18-25 ore.
La sua scelta: *"Tutto, a blocchi"*, prima le voci rapide e sicure, poi i
banchi di testo, con commit e spinta a ogni voce chiusa.

VOCI_TOTALI: 10
VOCI_CHIUSE: 1
VOCI_APERTE: 9
VOCI_DA_FARE: 0

Le prove stanno in `docs/collaudo/ET/`, quelle del telefono di prova
(Realme 767f596c) in `docs/collaudo/ET/realme/`. **Una voce che si vede a
schermo e' chiusa solo con la sua cattura dal Realme**, le animazioni con la
loro registrazione dello schermo.

---

## PARTE 1, LE TRENTA DOMANDE AI TRE MAESTRI, RILIEVI DEL FONDATORE

## VOCE ET.01, IL BANCO DELLE TRENTA DOMANDE

**APERTA IN ATTESA DI VERIFICA**: nessuno dei cinque risultati arriva al 30
su 30 per Maestro e canale; la sessione sul Realme ha dieci domande di
Medora e sette di Caligo, le altre si fanno col contingente del giorno dopo.

Il banco (`tool/collaudo_et01.dart`): le trenta domande dell'ordine, una
conversazione per Maestro, per canale e per esecuzione, due persone diverse,
il controller vero dell'app con tutte le sue reti e il modello vero; 360
risposte per giro, lette alla cieca da quattro agenti per fase con le
stesse regole (`docs/collaudo/ET/ciechi/`). La via, di Code: la posizione
detta come lettura e presa sempre (`LaPosizioneDellaLettura`, con le
aperture che girano da una risposta all'altra e la domanda aperta senza
apertura forzata); la rete della prima frase che gira intorno; la rete delle
certezze (`LeCertezzeDelMaestro`: il futuro fuori da una condizione, l'esito,
i sentimenti degli altri; la risposta si chiede di nuovo nominando la
certezza, e le frasi certe che restano si tolgono, mai la prima ne' il
consiglio); le riparazioni degli errori di italiano ricorrenti del banco
(`LItalianoDelMaestro`); il cielo dei pianeti che il calcolo smentisce non
arriva a schermo.

Alla cieca, su 360 risposte, dalla partenza (commit `ec88e0d9`) al codice che
resta (giro5): prima frase che risponde da 79 a 256; nel merito da 162 a 262;
risposte con una certezza da 18 a 22 (al giro2 erano 37: la rete le ha
riportate giu', non a zero); errori di italiano da 49 a 47; presentazioni in
apertura da 30 a 0. Le tabelle per Maestro e canale stanno nella prova e nel
rapporto. Il costo: 531 chiamate per giro contro 409, circa 1,41 dollari.
Aura resta la piu' bassa (prima frase 19 e 15 in chat, 16 e 20 nel LIVE).

**Sul Realme**, le sette risposte di Caligo nel LIVE lette una per una:
prima frase che risponde 2 su 7, contro 22 su 30 al banco. La causa era
nell'ingresso e in un difetto mio (padre questa voce): la trascrizione del
LIVE scrive le domande senza punto interrogativo (13 su 17), e senza "?" la
regola della posizione le leggeva aperte. Corretta nel solo LIVE
(`LaPosizioneDellaLettura.comeDomandaDetta`, chiamata dal controller), con
la guardia rossa sul codice di prima; la prima stesura, che valeva anche
nella chat scritta, l'ha presa la suite. Al banco con le trenta domande
scritte come le scrive la voce, nel LIVE, alla cieca: prima frase che
risponde da 47 a 109 su 180, nel merito da 66 a 114, certezze da 4 a 8
(`docs/collaudo/ET/trenta_domande_a_voce/conti.txt`). Sul telefono si
misura con la build di prova che porta la cura.

DOMANDA: "Bisogna fare delle prove, 30 domande per ogni maestro, con domande classiche q più frequenti. Gli utenti faranno domande personali e anche intime nella maggior parte dei casi. Ma anche per la fortuna e lavoro."; "Le persone vogliono risposte dirette, Senza tanti giochi di parole e cercano consigli e guide anche su domande generiche." (ordine ER, voce ER.01); le domande del fondatore da farsi su ogni funzionalità, del 27 settembre: "trasparenza, coerenza, verità e funzionalità", "c'è qualcosa di inventato?"; le trenta domande le ha scritte l'Architetto, su richiesta del fondatore.
PROVA: docs/collaudo/ET/trenta_domande/conti.txt
MISURA: su 360 risposte alla cieca, prima frase che risponde da 79 a 256, nel merito da 162 a 262, risposte con una certezza da 18 a 22, errori di italiano da 49 a 47, presentazioni in apertura da 30 a 0; risultato chiesto 30 su 30 per Maestro e canale, non raggiunto

## VOCE ET.02, LA VOCE, IL TESTO A VIDEO E LA CHAT DICONO LE STESSE PAROLE

**APERTA IN ATTESA DI VERIFICA**: testo a video e chat sono misurati sul
Realme e dicono le stesse parole; la voce non e' ancora ritrascritta
dall'audio del telefono, perche' la registrazione dello schermo non la
prende.

La via, di Code: nel LIVE il controller taglia la risposta alle frasi che il
Maestro dice (tre, quattro alla domanda con piu' parti, voce ET.06) **prima
di salvarla**, cosi' la chat salva le parole della voce e non la risposta
intera; le riparazioni dell'italiano (`LItalianoDelMaestro.ripara`) stanno
prima del taglio, e la rete delle certezze nel LIVE guarda solo la parte
detta. Sul telefono il registro lo mostra al turno 6 di Caligo: la prima
frase anticipata alla voce era di una stesura poi rifatta da una rete, e la
voce ha detto la frase nuova, quella che sta in chat.

Sul Realme, sessione di Caligo, sette turni: il testo a video (fotogramma di
fine risposta dalla registrazione) e la chat (catture con le risposte
aperte) dicono le stesse parole del Maestro in 7 turni su 7; in chat, sotto
l'ultima risposta, c'e' in piu' l'invito a tornare che l'app compone da sola
(ordine EJ voce 05), e va detto al fondatore perche' e' il caso della sua
domanda. **La voce**: la registrazione ha l'audio del telefono, ma la
traccia e' muta in tutti i turni, perche' LiveKit suona come una chiamata e
Android non lascia registrare quel flusso. Si misura col microfono del PC,
con le domande del giorno dopo.

DOMANDA: "Deve anche verificare che quello che il maestro dice corrisponda a quello che ha detto. Ho provato a fare Domande simili consecutive e le risposte, non solo non erano adeguate , ma la trascrizione nella chat era diversa e più corta."
PROVA: docs/collaudo/ET/voce_testo_chat.txt
MISURA: sul Realme, testo a video e chat con le stesse parole del Maestro in 7 turni su 7 (Caligo); voce ritrascritta dall'audio del telefono in 0 turni su 17, da fare

## VOCE ET.03, DOMANDE SIMILI DI FILA, OGNUNA LA SUA RISPOSTA

**APERTA IN ATTESA DI VERIFICA**: nessuna seconda risponde alla domanda di
prima, ma sei seconde ripetono ancora la prima e due cambiano posizione
senza dire perche'; sul Realme le coppie nel LIVE si fanno col contingente
del giorno dopo.

Le cinque coppie di domande simili di fila dell'ordine (1 e 2, 3 e 4, 7 e 8,
23 e 24, 25 e 26) stanno dentro il banco della ET.01, nella stessa
conversazione, e la lettura alla cieca le giudica accanto alla prima. La via
e' quella della ET.01: le aperture che girano con le risposte gia' date
(`LaPosizioneDellaLettura.inizio` col giro) e la regola del Maestro che non
ridice cio' che ha gia' detto.

Alla cieca, sulle 60 seconde di coppia per giro, dalla partenza al giro5:
seconde che rispondono alla domanda di prima 0 e 0; seconde che ripetono la
prima da 10 a 6; posizioni cambiate senza dire perche' da 1 a 2 (alla
partenza quasi nessuna prima frase prendeva posizione, quindi non c'era
posizione da cambiare); seconde nel merito da 25 a 41.

DOMANDA: "Ho provato a fare Domande simili consecutive e le risposte, non solo non erano adeguate [...]"; le domande del fondatore da farsi su ogni funzionalità, del 27 settembre: "trasparenza, coerenza, verità e funzionalità".
PROVA: docs/collaudo/ET/trenta_domande/conti.txt
MISURA: su 60 seconde di coppia alla cieca, seconde che rispondono alla prima da 0 a 0, seconde che ripetono da 10 a 6, posizioni cambiate senza perche' da 1 a 2, seconde nel merito da 25 a 41

## PARTE 2, IL LIVE, DECISIONI DEL FONDATORE SUL RAPPORTO ER

## VOCE ET.04, IL LIVE NON SI CHIUDE MENTRE LA PERSONA PARLA

**APERTA IN ATTESA DI VERIFICA**: le domande del DOPO sono 17 e l'ordine ne
chiede almeno 20; le tre che mancano si fanno col contingente del giorno
dopo.

La via, di Code: quando l'orecchio del LIVE ha sentito almeno un secondo di
voce chiara e la trascrizione torna vuota, la seconda si chiede senza la
regola che fa ignorare le voci lontane o registrate
(`LaTrascrizione.trascriviSenzaSottofondo`), e una voce chiara senza parole
conta come presenza, non come silenzio. Strada facendo e' uscito un secondo
difetto: dieci secondi dopo la chiusura per silenzio, con la registrazione
dello schermo accesa, l'app moriva con un aborto nativo di WebRTC, perche'
la stanza si staccava soltanto (padre EG.04, commit `1104da29`); adesso si
stacca e si libera (`_lasciaLaStanza`), e la prova della stanza l'ha vista
non morire.

Sul Realme, da -19 a -28,5 dB: PRIMA (build 2287) 17 domande sentite, 17
con parole, 0 vuote su voce chiara, 0 chiusure mentre la persona parlava;
DOPO (build di prova, Medora e Caligo) 17 dette, 17 con parole, 0 vuote, 0
chiusure mentre parlava; due volte la prima trascrizione e' tornata vuota e
la seconda ha dato le parole. Le parole giuste sono un'altra cosa: nel DOPO
12 domande su 17 trascritte uguali parola per parola, e "Ma mi ama ancora"
diventa "Ma mia, ma ancora" in tutte e due le sessioni; la prima
trascrizione non e' cambiata dalla partenza, il padre e' PROVENIENZA IGNOTA.

DOMANDA: dal rapporto ER: "il difetto è la trascrizione vuota [...] Non l'ho toccato: è un ordine a parte, se lo vuoi."; domanda girata al fondatore: "Confermi le mie tre scelte e l'ordine per la trascrizione, insieme alla ER.01?", risposta: "Confermo, dobbiamo risolvere tutto."
PROVA: docs/collaudo/ET/trascrizione.txt
MISURA: sul Realme, domande trascritte con parole da 17 su 17 sentite (prima) a 17 su 17 (dopo), vuote su voce chiara da 0 a 0, chiusure per silenzio mentre la persona parla da 0 a 0; domande del dopo 17 su almeno 20

## VOCE ET.05, IL VOLTO DEL LIVE RESTA IN LITE

**CHIUSA.**

Il LIVE di quest'ordine parte in lite: il registro delle funzioni (Cloud
Logging, funzione `apriunasessionelive`, messaggio "LIVE aperto") dice
*"maestro medora qualita lite"* alle 09:47:54 UTC del 28 settembre, cioe'
l'apertura della prova della voce della ET.04 sul Realme, e cosi' le altre
cinque aperture della mattina. Code non legge Firestore: il campo
`configurazione/live.qualita` l'ha messo il fondatore, nell'ordine ER.

Le misure sono quelle della ER.11 (dieci turni per qualita'): il Maestro si
sente a 5.146 ms in standard e a 5.300 in lite; dalla risposta al primo
audio al volto 354 ms in standard e 40 in lite. Accanto, la sessione di
oggi in lite, diciassette turni: si sente a 4.977 ms di mediana, il volto
parla a 5.507 (con l'avvertenza, scritta nella prova, delle domande gia'
dette quel giorno). **La voce ER.11 si chiude qui**, con la riga nel suo
manifesto.

DOMANDA: dal rapporto ER: "ER.11, il volto in lite: resta o torna standard?"; il consiglio dell'Architetto: "Volto del LIVE: resta in lite. [...] dal primo audio al volto passano 40 millisecondi invece di 354. In pratica il volto parla insieme alla voce."; risposta: "Confermo, dobbiamo risolvere tutto."
PROVA: docs/collaudo/ET/live_lite.txt
MISURA: aperture del LIVE di quest'ordine in lite nel registro delle funzioni, 6 su 6 (la prima 09:47:54 UTC); "il Maestro si sente" da 5146 ms in standard a 5300 in lite, dalla risposta al primo audio al volto da 354 a 40 ms (voce ER.11, dieci turni per qualita'); nella sessione di oggi in lite si sente a 4977 ms di mediana su 17 turni

## VOCE ET.06, QUATTRO FRASI QUANDO LA DOMANDA HA PIÙ PARTI

**APERTA IN ATTESA DI VERIFICA**: le forme sono rispettate in tutte e 72 le
risposte del banco; il merito della seconda esecuzione (18 su 36) sta sotto
il 23 che l'ordine chiede, e la durata vera della voce si misura sul Realme.

Il Maestro dice tre frasi, quattro quando la domanda ha piu' parti (almeno
due frasi di almeno due parole, cioe' un fatto e la domanda; almeno due
punti interrogativi; almeno due desideri): `LeTreFrasiDelLive.haPiuParti`.
Il taglio lo fa il controller prima di salvare, cosi' la chat dice le parole
della voce (ET.02). Il banco (`tool/collaudo_et01.dart` con `DOMANDE=er12`)
fa le dodici domande del LIVE dell'ordine EQ ai tre Maestri col codice di
oggi, due esecuzioni, 72 risposte nuove; la regola del modello
(`rispostaDettaAVoce`) chiede la quarta frase solo alla domanda a piu' parti.
A macchina: domande con piu' parti 30 su 72; risposte a una domanda di una
parte in piu' di tre frasi 0; in piu' di quattro 0; finite a meta' frase 0;
durata stimata della voce, mediana, 20,8 secondi (ER.12: 22,8 e 23,9 dopo il
taglio a tre). Alla cieca, con la regola dell'ordine EQ voce 03: nel merito
20 e 18 su 36; le domande a piu' parti con tutte le parti toccate 14 e 12 su
15.

DOMANDA: dal rapporto ER: "ER.12, tre frasi o quattro. [...] Puoi tenere tre frasi sempre, oppure farne dire quattro quando la domanda ha più parti."; il consiglio dell'Architetto: "ER.12: quattro frasi quando la domanda ha più parti."; risposta: "Confermo, dobbiamo risolvere tutto."

## PARTE 3, LE RUNE E IL VIAGGIO, VOCI APERTE DELL'ORDINE ER

## VOCE ET.07, LE RUNE ARRIVANO AI NUMERI DELL'ORDINE ER

**APERTA IN ATTESA DI VERIFICA**: nessuna delle tre misure arriva al
risultato (20 su 20, 24 su 24, zero errori); l'attesa sul Realme su dieci
gettate e la cattura di una lettura scritta a mano restano da fare con la
build di prova finale.

**La via, di Code, in tre stesure misurate alla cieca contro la partenza**
(il codice dell'ordine ER, fatto girare da una copia staccata al commit
`ec88e0d9`, perche' l'istruzione delle rune eredita le regole comuni che la
ET.01 cambia): lo schema chiede la risposta in poche parole ("inBreve")
prima di scriverla; la prima frase non e' una formula (un atteggiamento al
posto del gesto o del fatto); ogni pietra nomina la sua posizione e la cosa
chiesta, o la giornata; la cornice di Caligo non arriva piu' al modello, che
ne ripeteva l'immagine, e senza domanda il modello sa di che giorno parla;
la virgola fra il nome della runa e il verbo si chiude; tre chiamate, e
all'ultima una lettura scartata soltanto per la forma si mostra
(`LaLetturaDelleRune.siMostraComunque`): la lettura di casa resta per cio'
che non si puo' mostrare (il confine, un pezzo che manca).

Alla cieca, terza stesura contro partenza nello stesso fascicolo: dirette 12
e 14 su 20 (partenza 12 e 14); pietre tutte lette 20 e 21 su 24 (partenza 18
e 15); errori 4 e 5 (partenza 7 e 5). Cento gettate con la stessa domanda:
letture uguali 0; cadute sulla lettura di casa 3, tutte per il confine del
responso (partenza 10). **Il costo**: 56 chiamate per 24 letture contro 29-31,
circa 0,0079 dollari a gettata contro 0,0041, e il tempo del modello per
lettura, mediana, da 4,2 a 8,7-9,3 secondi. Le guardie sulle pietre pagano;
quelle della prima frase costano e non muovono le dirette: la scelta di
tenerle o toglierle e' del fondatore (rapporto).

DOMANDA: dalla ER.01: "Le persone vogliono risposte dirette, Senza tanti giochi di parole e cercano consigli e guide anche su domande generiche."; domanda girata al fondatore: "Confermi le mie tre scelte e l'ordine per la trascrizione, insieme alla ER.01?", risposta: "Confermo, dobbiamo risolvere tutto."

## VOCE ET.08, LA RISERVA DEL VIAGGIO PRENDE POSIZIONE

**APERTA IN ATTESA DI VERIFICA**: la riserva prende posizione e non esce mai
dalla domanda; il 20 su 20 della prima frase non arriva (14 e 15), per le
risposte del modello che reggono alle guardie ma restano vaghe; la cattura di
una discesa dal Realme resta da fare.

La riserva, adesso: quando nessuna risposta del modello ha retto, la prima
frase dell'ultima scartata passa da sola dalle stesse guardie e, se regge, e'
la risposta (`LaScenaDalModello.conLaPrimaFrase`); altrimenti, se il modello
aveva scelto una posizione, la riserva la dice come lettura dei segni del
viaggio e rimanda al gesto subito sotto, con tre frasi per posizione che si
alternano, e alla domanda aperta dice il passo
(`IlResponsoDelViaggio.rispostaCheSiSchiera`); senza modello resta la voce di
casa. E la prima frase che annuncia una condizione e non la dice si chiede di
nuovo. La prima stesura metteva la frase della posizione anche senza modello,
e le guardie della voce che si ricorda e del tema che arriva alla risposta
l'hanno presa: corretta.

Alla cieca, col gesto nel fascicolo per partenza e dopo: prima frase che
prende posizione 14 e 15 su 20 (partenza 15 e 12); riserve che prendono
posizione 3 su 3 (partenza 0 su 4); riserve che parlano di cose che la
domanda non ha 0 (partenza 3).

DOMANDA: dal rapporto ER: "La proposta: una riserva che dica la posizione che il modello aveva scelto sull'oggetto della domanda, anche quando la sua risposta è stata scartata. Se la vuoi, è un ordine a parte."; il consiglio dell'Architetto: "ER.02: sì alla riserva che prende posizione, come la propone Code."; risposta: "Confermo, dobbiamo risolvere tutto."

## PARTE 4, IL RETRO DELLE SCHEDE, RILIEVO DEL FONDATORE

## VOCE ET.09, IL TESTO DEL RETRO DELLE SCHEDE SI LEGGE

**APERTA IN ATTESA DI VERIFICA**: misurata in prova e vista sul Realme a
360 punti (build di prova del 28 settembre, `prova_et_2`), con le catture dei
tre formati in home e del dominio e la registrazione della scheda che si
gira; mancano le catture a 402 punti. Sul Realme 402 punti vogliono il
cambio della misura dello schermo nelle impostazioni del telefono, che non
si toccano; sull'iPhone 13 del fondatore (390 punti, collegato dal 28
settembre) c'e' la 2287, che questa voce non la porta: servono una build
TestFlight, che la ordina il fondatore, o il suo si' a cambiare la misura
dello schermo del Realme per la prova.

**Sul telefono, due difetti della prima stesura, padre questa voce (commit
`76ceca48`, mio)**, visti e corretti prima di chiudere:
- il testo del retro grande era sottolineato due volte in giallo: e' lo
  stile di ripiego di Flutter, perche' il retro grande sta nell'Overlay
  della radice, fuori dalla Material della schermata
  (`docs/collaudo/ET/realme/et09_prima_stesura_orizzontale.jpg`). Adesso ha
  sopra una Material trasparente; la guardia misurava la grandezza del testo
  e non il suo stile, e adesso misura anche la sottolineatura (rossa sul
  difetto innestato);
- su iPhone il secondo tocco nello stesso angolo cadeva sul retro grande,
  che apre l'arte, invece di rigirare la scheda: la prova
  `le_schede_su_iphone` l'ha presa. Adesso l'angolo della scheda nella riga
  resta suo.

Catture a 360 punti, dopo le correzioni: `et09_retro_verticale_360.jpg`
(Stesa di Tarocchi), `et09_retro_orizzontale_360.jpg` (Estrazione Rune),
`et09_retro_quadrata_360.jpg` (Sinastria VIP),
`et09_retro_oroscopo_home_360.jpg` e `et09_retro_dominio_360.jpg`
(l'Oroscopo in home e nel dominio di Medora, lo stesso testo alla stessa
misura), la registrazione `et09_giro_verticale.mp4`, tutte in
`docs/collaudo/ET/realme/`.

**Il padre** (Regola C): il retro mette il testo in un `FittedBox` che lo
rimpicciolisce finche' entra nella scheda, dall'ordine EO voce 02 (commit
`220d12d0`, 26 settembre), quando in home le schede erano larghe 184 punti e
il testo restava alla sua misura. L'ordine EP voce 02 le ha portate a 162 e
la voce ER.09 (mia) a 128 e 137, alte 77 le orizzontali: da li' il testo
scende fino a cinque punti. Nessuna prova misurava il testo del retro.

**La via**: in una scheda di casa il testo intero alla misura dei domini non
entra, per geometria (una scheda orizzontale lascia 89 per 45 punti al
testo). Girata in home, dalla meta' del giro il retro esce dalla scheda e
cresce fino alla misura della scheda nei domini, sopra la riga, centrato
sulla scheda e dentro lo schermo; la "i" lo rigira, il resto fa cio' che fa
il retro nei domini, un tocco fuori lo richiude
(`lib/features/schede/la_scheda_dell_arte.dart`, `_IlRetroGrande`). Nei
domini niente cambia. Guardia nuova
`test/il_retro_delle_schede_si_legge_test.dart`, rossa sul codice di prima.

DOMANDA: "Inserisci anche che i testi nel rovescio delle schede sono minuscoli, quasi illeggibili."

## PARTE 5, LA NUOVA INTRO, AGGIUNTA DEL FONDATORE

## VOCE ET.10, LA NUOVA INTRO, OTTIMIZZATA

**APERTA IN ATTESA DI VERIFICA**: il file nel pacchetto e' fatto e misurato;
manca la registrazione dello schermo dal Realme dell'intro intera, per il
giudizio del fondatore. La build di prova finale e' sul Realme, ma l'intro
li' non parte: il telefono ha le animazioni di sistema a zero, Flutter lo
legge come "riduci il movimento" (`MediaQuery.disableAnimations`) e
`SequenzaIntro` in quel caso la salta, per scelta. Le impostazioni del
telefono non si toccano: la registrazione la fa il fondatore, o da' il suo
si' a riaccendere le animazioni per la prova e rispegnerle dopo.

Aggiunta del fondatore del 28 settembre, pomeriggio. Della cartella
`D:\Clienti Roogly\Rituali Cartomanzia\App\Intro` si e' letto solo
Intro-Test-4.mp4, che resta li'. Il convertito e' rifatto dal sorgente in
due passate, H.264 High a 3,3 Mbit/s, la quantizzazione adattiva per i cieli
scuri, l'audio copiato: 1080x1920, 24 fotogrammi, 14 secondi, 336
fotogrammi come il sorgente, 6.122.280 byte (Intro-Test-3 ne pesava
6.152.840), SSIM 0,995 sul sorgente, l'audio a -14,1 dB di media e -1,7 di
picco come il sorgente. Nei fotogrammi affiancati, anche al cento per cento
nel buio, nessuna banda e nessun blocco che il sorgente non abbia gia'.
Intro-Test-3 e' uscito dalla cartella, che entra intera nel pacchetto.

**Aggiunta 2 del fondatore, 28 settembre sera: la versione 5.** La voce
vale per Intro-Test-5 al posto di Intro-Test-4, con lo stesso comando e le
stesse prove; della cartella si e' letto solo Intro-Test-5.mp4. Il
convertito: 1080x1920, 24 fotogrammi, 14 secondi, 336 fotogrammi come il
sorgente, **6.116.324 byte** (il sorgente 23.104.762), SSIM 0,995, PSNR
medio 47,7 dB e minimo 42,3, l'audio copiato a -14,2 dB di media e -1,7 di
picco come il sorgente. Nei fotogrammi affiancati e nel ritaglio al cento
per cento della nebulosa scura, anche con la luminosita' triplicata, nessuna
banda e nessun blocco che il sorgente non abbia gia'. `SequenzaIntro.video`
nomina Intro-Test-5; Intro-Test-4 e' uscita dalla cartella. Prima di
toccare la zona, la guardia `intro_test` vista rossa col video che non c'e'
(Regola B).

DOMANDA: "Mi serve un mini ordine da aggiungere a ET. Bisogna sostituire la intro attuale con quella che trovi in app/intro file intro-test-4.mp4. ovviamente è da ottimizzare"; "Ti hai accesso anche a "rituali cartomanzia/app/intro"", la cartella D:\Clienti Roogly\Rituali Cartomanzia\App\Intro; aggiunta 2: "Ho creato una nuova cersione della intro da sostituire e la 5".
PROVA: docs/collaudo/ET/intro.txt
MISURA: file dell'intro nel pacchetto diversi da Intro-Test-5 ottimizzata da 1 (Intro-Test-4) a 0; peso 6.116.324 byte contro i 6.152.840 dell'intro di prima; durata 14,000 s, risoluzione 1080x1920 e 24 fotogrammi al secondo uguali al sorgente; differenza di livello dell'audio 0 dB; registrazione dal Realme da fare
