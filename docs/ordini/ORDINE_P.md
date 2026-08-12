ORDINE P

CODE PORTA A TERMINE TUTTO L'ORDINE, OGNI VOCE, FINO ALLA CONSEGNA. Non si ferma
a meta', non rimanda voci, non lascia lavoro da ordinare di nuovo. Se il contesto
si stringe, comprime i rapporti e non il lavoro. L'unica fermata ammessa e' una
premessa falsa.


===============================================================================
LEGGE DI CONSEGNA. SI LEGGE PRIMA DI TOCCARE IL CODICE
===============================================================================

Nessuna consegna parziale e' accettata. L'ordine ha 32 voci numerate da P.01 a
P.32. Le voci non si rinumerano, non si accorpano, non si reinterpretano, non si
dichiarano gia' coperte da un'altra voce. Ogni voce si chiude da sola con la sua
misura.

Se una voce risulta impossibile o poggia su una premessa falsa, Code si ferma su
quella voce, lo scrive, e prosegue con le altre. Non la salta in silenzio e non
la dichiara chiusa. Una premessa falsa abbattuta vale quanto una voce chiusa, ma
va dichiarata come premessa falsa e non come chiusura.

IL MANIFESTO. Code crea docs/ordini/ORDINE_P_MANIFESTO.md come primissima azione,
prima di qualunque modifica al codice, con le 32 righe da P.01 a P.32, ciascuna
con stato APERTA. Ogni voce chiusa porta la riga a CHIUSA con accanto il file
toccato, la misura e il nome del test che la sorveglia. In fondo al file, in
formato leggibile a macchina:

    VOCI_TOTALI: 32
    VOCI_CHIUSE: <n>
    VOCI_FERMATE_SU_PREMESSA_FALSA: <n>

LA GUARDIA. test/ordine_p_guard_test.dart legge il manifesto e FALLISCE finche'
VOCI_CHIUSE piu' VOCI_FERMATE_SU_PREMESSA_FALSA e' minore di VOCI_TOTALI. Finche'
quel test e' rosso l'ordine non e' consegnato, la build non si fa e il rapporto
non si scrive. Non e' una promessa, e' un test che non passa.

IL RAPPORTO FINALE riproduce tutte e 32 le righe, in ordine, ciascuna col suo
stato. Un rapporto che ne elenca meno di 32 non e' valido e l'ordine si considera
non consegnato.

Regole di casa che valgono per tutto l'ordine. Prova del rosso obbligatoria dove
indicata: nessun difetto e' ammissibile se non esiste un test che fallisce sul
codice PRIMA della correzione, e quando una guardia non scatta si cambia la
grandezza misurata, mai la soglia. Nessun numero indovinato dentro un test. Le
anteprime si guardano alla larghezza reale e non si deduce dal nome del file.
Riduci Movimento non toglie mai contenuto. Nessun trattino lungo nei testi a
video.


===============================================================================
PREMESSE DA ABBATTERE
===============================================================================

Si verificano prima di correggere, e l'esito si dichiara anche quando la premessa
cade. Una premessa caduta risparmia un giro, quindi vale.

1. Che il cielo in parallasse sia fermo per una modifica recente e non per una
   condizione di piattaforma o per Riduci Movimento attivo.
2. Che la carta estratta cambi perche' il mazzo viene rigenerato, e non perche'
   la carta e' ricalcolata a ogni ricostruzione da un seme che dipende dallo
   stato del mazzo.
3. Che i testi dell'Alba siano piccoli. Vanno misurati: potrebbero essere a norma
   di dimensione e fuori norma di contrasto, e le due cose si correggono in modo
   diverso.
4. Che l'Oracolo del Giorno sia rotto e non semplicemente privo di dato in certe
   condizioni.
5. Che i nove difetti ereditati della Sezione F siano ancora aperti. Alcuni
   potrebbero essere caduti con gli ordini recenti. Quale sia quale non si scrive
   a memoria: si riverifica uno per uno.


===============================================================================
SEZIONE A. I PRESIDI. PRIORITA' ASSOLUTA
===============================================================================

-------------------------------------------------------------------------------
P.01  IL CIELO DI SFONDO TORNA A SCORRERE
-------------------------------------------------------------------------------

Il cielo in parallasse e' tornato fisso. Non e' la prima volta. Va rimesso in
moto e va capito PERCHE' si e' fermato, perche' la causa vale piu' della
correzione: se la causa non si nomina, si ripete.

Ordine di lavoro. Prima si trova il commit che lo ha fermato, con git log -S sul
simbolo che governa il movimento e con git bisect se il primo non basta. Poi si
scrive nel rapporto il commit, la data e la ragione per cui quella modifica fu
fatta. Solo dopo si corregge.

Criterio di chiusura: il fondo si muove in tutte le schermate dove si muoveva
prima della regressione, e l'elenco di quelle schermate e' dichiarato in un punto
solo del codice, non dedotto a mente.

-------------------------------------------------------------------------------
P.02  TRE LUCCHETTI SUL CIELO, DIVERSI FRA LORO
-------------------------------------------------------------------------------

Un solo test non basta: e' gia' stato aggirato una volta. Servono tre presidi che
falliscono per ragioni diverse, cosi' che nessuna modifica futura possa spegnerli
tutti insieme senza accorgersene.

Lucchetto uno, il dato. Un test monta lo sfondo, avanza il tempo di N fotogrammi
e verifica che la traslazione applicata sia cambiata. Misura il valore, non la
presenza dell'animazione.

Lucchetto due, il pixel. Un test differenziale cattura due fotogrammi distanti e
verifica che un numero minimo di pixel del solo strato di fondo sia cambiato.
Prende il caso in cui il valore si muove e nessuno lo dipinge.

Lucchetto tre, l'enumerazione. Un test enumera le schermate che dichiarano di
usare il fondo cosmico e cade col nome della classe se una di esse non riceve il
fondo in movimento. Prende il caso in cui il movimento resta vivo in una
schermata e muore nelle altre.

Per ognuno dei tre va eseguito il rosso: si spegne il movimento e si allega
l'output del fallimento. Un lucchetto che non e' stato visto fallire non e' un
lucchetto.

Quarto test: con Riduci Movimento attivo il fondo e' fermo E il contenuto e'
tutto presente. Riduci Movimento non toglie mai contenuto.

-------------------------------------------------------------------------------
P.03  NON SI SPEDISCE SU ROSSO, E QUESTA VOLTA E' UN BLOCCO
-------------------------------------------------------------------------------

La build 2171 e' stata spedita con due test rossi. La regola che lo vieta esiste,
ma vive in un documento, e un documento non ferma niente.

Sbarramento nello script di build: se la suite non e' interamente verde, la build
NON si produce. Non un avviso, non una nota nel rapporto: il comando esce con
errore e non genera l'archivio. L'unico scavalco possibile e' una variabile
d'ambiente esplicita il cui nome compare obbligatoriamente nel rapporto della
consegna, cosi' che una spedizione su rosso resti possibile ma sia impossibile
che avvenga in silenzio.

Prova del rosso: si rompe volontariamente un test, si lancia la build, si
verifica che non produca l'archivio, si allega l'output.


===============================================================================
SEZIONE B. STESA DI TAROCCHI
===============================================================================

-------------------------------------------------------------------------------
P.04  LA CARTA ESTRATTA NON CAMBIA MAI PIU'. DIFETTO GRAVISSIMO
-------------------------------------------------------------------------------

Il fatto, dagli screenshot delle 03:13 e delle 03:14. Nella posizione PASSATO
compare prima La Papessa, con la frase Il sapere del silenzio. Dopo una mischia,
nella stessa posizione, compare Re di Coppe rovesciato, con la frase L'onda
trattenuta. La carta gia' scelta dalla persona e' stata riestratta.

Non e' un difetto grafico. E' la distruzione della sola cosa che rende una stesa
una stesa: che la carta uscita sia QUELLA, e che l'abbia scelta l'utente. Se
cambia, la persona capisce che il responso non dipende da lei, e il prodotto
muore in quel momento.

REGOLA, scritta come legge del dominio. Una carta, una volta assegnata a una
posizione della stesa, e' IMMUTABILE fino alla chiusura della stesa. Mischia e
taglio operano SOLTANTO sulle carte non ancora estratte. Il mazzo residuo si
rimescola, la stesa no.

Prima di correggere si verifica quale delle due cause sia vera, e l'esito si
dichiara anche se cade:

  a) il mazzo viene rigenerato e la stesa rilegge dalle posizioni del mazzo
     nuovo, quindi le carte gia' uscite puntano a indici che nel frattempo si
     sono spostati;
  b) la carta e' derivata a ogni ricostruzione da un seme che include lo stato
     del mazzo, quindi non e' mai stata salvata, veniva ricalcolata ogni volta e
     sembrava stabile solo perche' nulla la disturbava.

La correzione e' diversa nei due casi. Nel primo si separano le due collezioni.
Nel secondo si salva la carta come dato e non come funzione.

Prove a guardia, tre, perche' una sola lascia passare la condizione scritta al
contrario:
  1. estrae una carta, esegue una mischia, cade se la carta nella posizione e'
     diversa;
  2. esegue una mischia con zero carte estratte e cade se l'ordine del mazzo NON
     cambia, cosi' nessuno chiude il difetto congelando anche il mescolamento;
  3. la stessa cosa col taglio.

-------------------------------------------------------------------------------
P.05  L'ANIMAZIONE DEL TAGLIO SI CAPISCE
-------------------------------------------------------------------------------

Oggi non si capisce cosa succede. Il taglio racconta quattro momenti distinti,
nell'ordine, e ognuno deve essere leggibile:

  1. le carte stese a ventaglio SI RICOMPONGONO in un mazzo unico, al centro;
  2. il mazzo SI DIVIDE IN DUE META', che si separano visibilmente;
  3. le due meta' SI RICOMPONGONO in un mazzo solo, con la meta' inferiore che va
     sopra;
  4. il mazzo SI RISTENDE A VENTAGLIO.

Ogni momento ha una durata dichiarata in un punto solo del codice, non numeri
sparsi nei widget. Il totale sta sotto la soglia oltre la quale un'animazione
diventa attesa: se la supera si accorciano le fasi, non se ne salta una.

Le carte gia' estratte NON partecipano: restano nelle loro posizioni, immobili,
per tutta l'animazione. E' anche il modo visivo di dire alla persona cio' che
P.04 dice nel dato.

Con Riduci Movimento le quattro fasi diventano quattro stati statici in
dissolvenza. Non spariscono.

Prova: quattro anteprime a 1080x2391, una per fase, nel corredo, piu' un test che
verifica che le posizioni delle carte estratte non cambino di un punto durante
l'intera animazione.

-------------------------------------------------------------------------------
P.06  MEDORA CI PENSA, PRIMA DI RISPONDERE
-------------------------------------------------------------------------------

Oggi, finita la selezione, i responsi appaiono di colpo. Un responso istantaneo
e' un responso letto da un archivio, ed e' esattamente cio' che la persona
percepisce.

Fra l'ultima carta scelta e la comparsa del primo responso si inserisce
un'attesa in sovrimpressione: una figura che gira o si compone, il ritratto di
Medora, e una riga che dice cosa sta accadendo, del tipo Medora osserva le tre
carte insieme. Le righe sono almeno tre, si alternano, sono nella voce di Medora
e non sono generiche.

ATTESA MINIMA GARANTITA, come gia' fatto per il consulto: anche se il testo e'
pronto in cento millisecondi la scena resta il tempo di almeno due frasi
complete; se il testo tarda l'attesa continua senza saltare ne' lampeggiare. E'
la correzione gia' chiusa alla voce 40 del Registro dei Difetti e si riusa invece
di riscriverla.

Nessuno stato senza uscita: se la generazione fallisce compare il ripiego con la
sua etichetta e il suo Riprova, mai una schermata che resta a girare.

-------------------------------------------------------------------------------
P.07  LA BOLLA CHIAVE E' LA BOLLA DELLA CARTA
-------------------------------------------------------------------------------

La carta chiave smette di avere una bolla propria e diventa uno STATO di una
delle tre bolle di Passato, Presente e Futuro. La bolla che contiene la carta
chiave si distingue: blu piu' intenso, bordo acceso, e una marcatura piccola che
dice perche' e' quella. La distinzione deve essere visibile senza leggere, cioe'
da un colpo d'occhio.

Va misurata e non stimata: la differenza fra la bolla chiave e le altre due si
misura a pixel in modo differenziale, con una soglia dichiarata, e un test cade
se la differenza scende sotto quella soglia. Una evidenziazione che si vede solo
a chi sa che c'e' non e' una evidenziazione.

-------------------------------------------------------------------------------
P.08  DUE BOLLE SPARISCONO
-------------------------------------------------------------------------------

Si elimina la bolla LA CARTA CHIAVE, resa inutile da P.07.
Si elimina la bolla LE CARTE CHE DIALOGANO.

Eliminare vuol dire togliere il widget, i suoi testi, la sua generazione e il
costo in token della sua generazione. Non nasconderla dietro un flag. Un test
enumera le bolle del responso e cade se una delle due riappare.

-------------------------------------------------------------------------------
P.09  IL CONSIGLIO DI MEDORA E' LA PRIMA COSA, ED E' LA PIU' LUNGA
-------------------------------------------------------------------------------

Oggi il consiglio e' scarno e arriva per ultimo. E' la bolla che la persona porta
via, quindi va invertito tutto.

E' LA PRIMA CHE SI GENERA E LA PRIMA CHE SI LEGGE, sopra le tre bolle delle
carte.

HA PIU' TESTO. Il tetto di lunghezza di questa bolla e' distinto dagli altri e
piu' alto, dichiarato nel blocco unico delle costanti insieme agli altri tetti,
mai scritto a mano nel punto di chiamata.

LA DOMANDA CHE TI LASCIO sparisce come bolla e diventa la chiusura del consiglio:
ultimo paragrafo, dentro lo stesso testo, dopo una riga di stacco. Non e' un
titolo nuovo, e' come finisce cio' che Medora dice.

Il consiglio poggia sulle tre carte insieme e le nomina, non e' un testo generico
appeso in fondo. Un test verifica che il testo contenga riferimento ad almeno due
delle tre carte uscite, altrimenti e' una frase che vale per qualunque stesa e la
persona se ne accorge alla seconda lettura.

RETENTION. Il consiglio si chiude con una domanda perche' la domanda e' cio' che
riporta la persona domani. La domanda va quindi SALVATA e ricomparire il giorno
dopo nel dono del mattino, con la formula Ieri Medora ti ha lasciato questa
domanda. Senza questo, la domanda e' un finale carino che nessuno ricorda.

-------------------------------------------------------------------------------
P.10  IL TESTO SOTTO LA CARTA SMETTE DI ANDARE A CAPO OGNI DUE PAROLE
-------------------------------------------------------------------------------

Negli screenshot il testo sotto la carta scelta e' largo quanto la carta, quindi
L'onda / trattenuta. occupa due righe mentre alla sua destra due terzi della
larghezza sono vuoti.

Il nome della carta, l'eventuale ROVESCIATO e la frase di sintesi vanno su una
colonna che usa la larghezza disponibile, non quella della miniatura. Il
ROVESCIATO smette di essere maiuscoletto piccolo e diventa una marcatura
leggibile.

Misura di chiusura: nessuna riga di quel blocco contiene meno di quattro parole
quando lo spazio orizzontale disponibile ne consentirebbe di piu'. Anteprima
prima e dopo alla larghezza reale.


===============================================================================
SEZIONE C. RITO DELL'ALBA
===============================================================================

-------------------------------------------------------------------------------
P.11  MISURARE PRIMA DI CORREGGERE
-------------------------------------------------------------------------------

Per ogni testo del Rito dell'Alba, una riga con: file e numero di riga, ruolo
tipografico invocato, dimensione renderizzata effettiva, colore del testo, colore
effettivo del fondo dietro quel testo dopo opacita', sfocature e sovrapposizioni,
e rapporto di contrasto calcolato con la formula di luminanza relativa WCAG.
Nessuna correzione prima che la tabella esista. Si salva in
docs/tipografia/alba_contrasto.md.

-------------------------------------------------------------------------------
P.12  IL REGIME CHIARO DIVENTA UFFICIALE
-------------------------------------------------------------------------------

Il pannello chiaro dell'Alba resta e diventa il SECONDO REGIME CROMATICO
DICHIARATO dell'app. Motivo: l'alba e' l'unico momento in cui un'app notturna ha
una ragione narrativa per schiarire, e buttarla via per uniformita' impoverisce
il prodotto. Ma va governato, non tollerato: finche' esistono due regimi e uno
solo e' governato dai token, nessun presidio automatico puo' proteggere l'altro,
ed e' cosi' che il difetto e' nato.

Nascono nei token: superficieChiara, testoSuChiaro, testoMutoSuChiaro,
accentoSuChiaro. Ogni schermata che usa il regime chiaro lo dichiara
esplicitamente, e un test enumera le schermate che dipingono un fondo chiaro e
cade col nome della classe se una di esse non lo dichiara.

Soglie. Testo di lettura e di corpo: minimo 4.5 a 1. Titoli da 24 punti in su, o
da 19 in grassetto: minimo 3 a 1. Etichette: 4.5 a 1 senza sconti, perche' sono
le piu' piccole.

-------------------------------------------------------------------------------
P.13  LE ETICHETTE DELL'ALBA
-------------------------------------------------------------------------------

PAROLA DEL GIORNO, MONITO DEL GIORNO, ANCORA NATALE, TRANSITO ATTIVO OGGI e ogni
loro sorella: ruolo didascalia, cioe' 16, non etichetta; niente maiuscoletto;
colore che soddisfi 4.5 a 1 sul fondo reale.

Se l'oro non ce la fa sul chiaro, e non ce la fara', sul regime chiaro l'oro
diventa colore di filetti e bordi e non di testo.

-------------------------------------------------------------------------------
P.14  IL PRESIDIO SI ESTENDE AL CONTRASTO
-------------------------------------------------------------------------------

Il censimento tipografico misura le dimensioni e non vede questo difetto:
SOTTO_IL_PAVIMENTO a zero resta vero mentre il testo e' illeggibile. Un testo a
18 punti in oro su avorio e' meno leggibile di un testo a 14 in bianco su nero.

Si affianca tool/censimento_contrasto.dart, che produce nello stesso formato dei
marcatori esistenti:

    COPPIE_CENSITE: <n>
    SOTTO_IL_CONTRASTO: <n>

Il test di guardia esistente legge anche questi due e fallisce se
SOTTO_IL_CONTRASTO sale rispetto al valore registrato. Stessa logica a cricchetto
degli altri: puo' solo scendere.

Prova del rosso: il test sulle etichette dell'Alba deve FALLIRE sul codice attuale
prima della correzione. Se non fallisce e' sbagliata la misura, e si cambia la
misura, mai la soglia.

-------------------------------------------------------------------------------
P.15  L'ALBA ENTRA NEI PRESIDI INTOCCABILI
-------------------------------------------------------------------------------

Insieme al cielo in parallasse e agli altri gia' registrati.


===============================================================================
SEZIONE D. I DONI DEL GIORNO
===============================================================================

Legge che governa tutta la sezione: un dono che si esaurisce quando lo apri non
produce ritorni. Un dono che apre qualcosa che si chiude piu' tardi, si'.

-------------------------------------------------------------------------------
P.16  L'ORACOLO DEL GIORNO RICOSTRUITO
-------------------------------------------------------------------------------

Oggi non funziona. Prima si accerta in che modo non funziona, con la condizione
esatta che lo rompe, poi si ricostruisce.

Requisiti. Il cielo reagisce al giroscopio, con RIPIEGO TATTILE OBBLIGATORIO per
chi non ha il sensore o lo ha negato. Una riga, prima del gesto, dice cosa la
persona sta per ricevere: nessuno compie un gesto senza sapere cosa ne esce.
Nessuno stato senza uscita: se la generazione fallisce compare il ripiego con
Riprova, mai una schermata muta.

-------------------------------------------------------------------------------
P.17  OGNI RITO DICHIARA COSA FA, PERCHE', E COSA RESTA
-------------------------------------------------------------------------------

Ogni rito, in testa, dichiara tre cose in forma breve: COSA FAI, PERCHE', COSA TI
RESTA. La terza e' quella che oggi manca ovunque, ed e' la sola che produce
ritorno.

Dentro questa voce: la frase tre dentro e tre fuori, sei giri, corti come i
tratti SPARISCE come testo e diventa un respiro guidato a schermo, con la figura
che si espande e si contrae e le tre parole gia' approvate al posto giusto. Una
istruzione criptica scritta e' un compito; un respiro guidato e' un'esperienza.

Si riusa il respiro gia' costruito per il Soffio del Destino e non se ne scrive un
secondo: due respiri nello stesso progetto sarebbero un'altra occorrenza della
famiglia delle due porte.

-------------------------------------------------------------------------------
P.18  I DONI SI AGGANCIANO FRA LORO
-------------------------------------------------------------------------------

LA PAROLA DEL GIORNO oggi ha una ragione d'essere che non si vede. Gliela si da':
la Parola del mattino viene RICHIAMATA LA SERA, dentro il Rito del Sogno, con la
formula Stamattina la tua parola era X. Da quel momento la Parola non e' un
ornamento, e' un filo fra due momenti della giornata.

LA RUNA DEL TRAMONTO entra nel Sogno: la sera, il Sogno la nomina.

IL RITO DEL SOGNO DIVENTA LA CHIUSURA DEL GIORNO. Negli screenshot si chiude gia'
con Buonanotte, ha la costellazione, il saluto di Caligo e la card da
condividere: la forma c'e'. Manca che raccolga la giornata. Con la Parola e la
runa dentro, il Sogno smette di essere un rito autoconcluso e diventa il rito
della buonanotte, che e' quello che il nome promette.

LA DOMANDA LASCIATA DA MEDORA nella stesa, se c'e' stata, compare nel dono del
mattino successivo, come da P.09.


===============================================================================
SEZIONE E. TRAGUARDI E COSMIC JOURNAL
===============================================================================

-------------------------------------------------------------------------------
P.19  I 165 TRAGUARDI
-------------------------------------------------------------------------------

Tre sentieri, 55 traguardi ciascuno: 50 mini piu' 5 grandi. I cinque grandi
arrivano dopo il decimo, il ventesimo, il trentesimo, il quarantesimo e il
cinquantesimo mini, che e' il modello della tessera punti gia' fissato nei
briefing V5. Totale 165.

Identita' gia' fissate nei briefing e non modificabili qui. Medora: Costellazione
personale, mini Stelle del Cammino, grandi Costellazioni. Aura: Fiore di Loto,
mini Petali del Risveglio, grandi Fioriture. Caligo: Albero della Vita, mini
Frutti dell'Albero, grandi Sefirot Maggiori fino a Keter.

Ogni traguardo porta quattro campi e nessuno puo' essere vuoto: nome, obiettivo,
perche' conta, cosa apre. Il quarto e' la regola di ammissione: un traguardo che
non apre niente non entra nell'elenco.

I 165 TESTI SONO NELL'ALLEGATO A, si usano verbatim, Code non ne inventa e non ne
riformula nemmeno uno. Se al momento di eseguire l'allegato non c'e', questa voce
si ferma dichiarando premessa mancante e le altre 31 proseguono.

Vincoli gia' decisi da rispettare. Curva Eos: mini 10, i primi tre a 20; grandi
80, 150, 250, 400, 600. I primi tre Sigilli di aggancio sono trasversali, cioe'
carta natale creata, primo Cosmic Passport completato, prima Sinastria. Nel Free
il journal e' vivo fino al ventesimo traguardo per sentiero. IN DEMO TUTTI I
TRAGUARDI SONO VIVI SU OGNI SENTIERO, per decisione di Mauro dell'11 agosto 2026.

CONTRADDIZIONE DA CHIUDERE IN QUESTA VOCE. Le Linee Guida UX, sezione 17, dicono
due cose opposte sui Sigilli sospesi. Vale questa, e le due frasi vanno allineate:
IL SIGILLO SI ACCENDE SEMPRE AL RAGGIUNGIMENTO DEL TRAGUARDO, a prescindere dalla
condivisione. La condivisione governa soltanto il bonus in Eos.

Prova: un test enumera i 165 traguardi e cade se uno solo dei quattro campi e'
vuoto, se il totale non fa 165, o se un sentiero non ne ha esattamente 55.

-------------------------------------------------------------------------------
P.20  LA CELEBRAZIONE
-------------------------------------------------------------------------------

Ogni traguardo raggiunto si celebra. Non un messaggio in un angolo: ANIMAZIONE A
TUTTO SCHERMO oppure sovrimpressione piena, con il simbolo del sentiero che si
accende, il nome del traguardo, la card condivisibile gia' pronta e il salto
diretto al punto del journal dove il Sigillo si e' appena acceso.

Due intensita': piena per i cinque grandi traguardi, breve ma sempre a tutto
schermo per i mini, perche' cinquanta celebrazioni lunghe diventano un ostacolo.

Con Riduci Movimento la celebrazione diventa statica e NON sparisce: la persona
vede comunque il simbolo acceso, il nome e la card.

-------------------------------------------------------------------------------
P.21  IL SIGILLO SOSPESO SI COMPORTA COME DECISO
-------------------------------------------------------------------------------

Sigillo acceso al raggiungimento. Pulsazione lenta e marcatura sul sospeso. Al
tocco si riapre la card e si puo' condividere anche settimane dopo incassando
l'Eos in attesa. Nessun buco muto nel journal.

Un test enumera gli stati possibili del Sigillo e cade se ne esiste uno che
lascia il journal con una casella grigia dopo un traguardo raggiunto.


===============================================================================
SEZIONE F. I NOVE DIFETTI EREDITATI
===============================================================================

Sono voci vecchie del Registro dei Difetti, mai richiuse. Alcune potrebbero
essere cadute con gli ordini recenti: quale sia quale non si scrive a memoria, si
riverifica una per una. Per ciascuna il rapporto dichiara uno di tre esiti, e
solo questi tre: gia' chiusa da un ordine precedente, con la prova che lo
dimostra; ancora aperta e chiusa adesso, con la misura; ancora aperta e non
chiudibile in questo ordine, con la ragione.

P.22  IL VELO SUI CORPI SOTTO L'ORIZZONTE. Un corpo sotto l'orizzonte lo dichiara
      nella scheda ma e' ancora disegnato a piena luce. Manca il segno visivo,
      cioe' il corpo velato o spento sotto una linea d'orizzonte. Vale per tutti
      e due i cieli, passando da _SkyBody.

P.23  IL LUOGO ATTUALE NEL PROFILO CONTRO QUELLO DI NASCITA. Il Rito dell'Alba
      usa il luogo di NASCITA: chi e' nato a Sydney e vive a Milano riceve l'alba
      di Sydney, con lo scarto di fuso preso dal telefono e le coordinate dal
      luogo di nascita, cioe' i due dati vengono da posti diversi. Sono tre cose
      dentro una voce e vanno insieme: il campo del luogo attuale nel profilo, la
      conservazione della posizione fra un avvio e l'altro, e il punto in cui
      chiedere il permesso con garbo. La terza pesa piu' delle altre: chi non ha
      mai concesso la posizione non vedra' mai la fascia. Il ripiego coerente
      esiste gia' nello stesso file, longitudineDaFuso piu' latDiRipiego.

P.24  LA GIUNTURA DELL'OROSCOPO CHE RIPETE SE STESSA, perche' varia sul giorno e
      non sul dominio. Vincolo: il fatto non si fa variare, sopra un fatto si apre
      un ventaglio di dizione e mai di sostanza. Le quarantotto ancore del corpus
      sono materiale di Mauro, si guardano frase per frase e non si fanno di
      corsa.

P.25  LA CARD DA CONDIVIDERE DELL'OROSCOPO SENZA TRANSITO. La card mostra la sola
      frase del segno; il transito vero, nell'immagine che la gente manda agli
      altri, non compare. Farcelo entrare e' scelta di composizione visiva: si
      propone a Mauro con due anteprime, non si decide da soli.

P.26  IL PRATO DEL SOFFIO. Non e' un fondale: e' un livello dentro un pittore di
      236 righe che nella stessa tela disegna anche il soffione e i semi che
      volano al soffio, cioe' il gesto del rito. Togliere il prato obbliga a
      decidere cosa succede al soffione. La destinazione esiste gia' ed e'
      precedentata: CosmosBackground, gia' usata dal Rito del Sogno.

P.27  LE SEDICI ANTEPRIME CHE MONTANO UNA SCENA CHE L'APP NON MONTA, in quattro
      flussi: Risveglio, Costellazione del Viso, Animale Guida, Estrazione Rune.
      Criterio: un'anteprima deve essere montata come e' montato cio' che prova.
      Il nome del file e' un buon indizio e non e' il criterio.

P.28  IL GESTO DI CONDIVIDERE IN TREDICI POSTI. Tredici punti che fanno la stessa
      cosa sono tredici occasioni di farla in modo diverso. Va ricondotto a un
      punto solo, con la prova che enumera i chiamanti invece di visitarne uno.

P.29  LA RINOMINA DI sunset_time.dart IN solar_time.dart. Il file contiene anche
      il sorgere, quindi il nome dichiara il falso. Si fa quando non ci sono due
      sessioni aperte, perche' farla durante un parallelismo fa saltare l'unione.

P.30  URUZ NON SCONTORNATA. L'asset sorgente ha il 94,3 per cento dei pixel
      opachi e un rettangolo nero attorno alla pietra, ereditato fedelmente dal
      retro vergine. Si vede a occhio nudo fra le altre ventitre'. L'asset e'
      sotto lucchetto di CI.


===============================================================================
SEZIONE G. CONSEGNA
===============================================================================

-------------------------------------------------------------------------------
P.31  IL MANIFESTO E LA GUARDIA
-------------------------------------------------------------------------------

Come descritto nella legge di consegna in testa.
docs/ordini/ORDINE_P_MANIFESTO.md creato per primo, prima di qualunque modifica
al codice. test/ordine_p_guard_test.dart rosso finche' le 32 voci non hanno tutte
uno stato terminale.

-------------------------------------------------------------------------------
P.32  IL RAPPORTO
-------------------------------------------------------------------------------

Riproduce tutte e 32 le righe con stato, misura, file toccati e nome dei test.

Porta le anteprime alla larghezza reale per P.05, P.07, P.10 e P.20.
Porta gli output rossi eseguiti per P.02, P.03, P.04 e P.14.
Dichiara tutte le premesse abbattute, comprese quelle cadute.

La build si numera come dice Mauro. Non si riusa un numero gia' esistente e non
si sceglie da soli.
