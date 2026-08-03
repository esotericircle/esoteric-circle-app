# RIPRESA

## ORDINE CHAT 5: CHIUSO PER INTERO, tutte e tre le voci

Il 3 agosto 2026. Le tre voci sono chiuse. I due debiti di riporto sono
riportati, uno saldato e uno no, con la ragione scritta.

**VOCE 1, CHIUSA.** La Luna del progetto e' una sola, in `LunaReale`. Cercando
le altre per scrivere la prova ne ho trovate QUATTRO, non le tre che mi
aspettavo: Rito del Sogno, emblema, ombra del Santuario e cartolina del cielo,
che la disegna dentro un metodo che non la nomina. E' il motivo per cui la prova
ENUMERA gli ingredienti del terminatore invece dei nomi delle classi. La parola
e il disegno ora escono dallo stesso numero perche' il nome e' un GETTER sulla
frazione illuminata: non e' una prova, e' il tipo.

**VOCE 2, CHIUSA.** La scena occupa cio' che avanza perche' la conversazione si
dispone per prima. Tre gradini, non due: sopra il minimo il corpo cresce fino a
220, sotto il pavimento resta la riga, sotto la riserva del testo non resta
niente. Il terzo l'ho scoperto perche' nella chat vera lo spazio libero scende a
48,3 punti mentre il testo ne chiede 109.

**VOCE 3, CHIUSA.** La domanda e il suo turno nascono insieme e si salvano
insieme. L'ipotesi e' stata verificata prima di correggere: cinque casi su sei
cadevano.

**Le tre prove del rosso rimaste VERDI, con cio' che hanno trovato.** Una: la parola
generica su una meta' esatta passava per quindici decimillesimi, perche' la
fascia era scelta a mente. Due: la scena che reclama tutto lo spazio non
spostava la conversazione, perche' la fingevo alta 200 punti in una fascia da
ottocento, dove la sovrapposizione non poteva accadere. Tre: togliendo il
completamento del turno, la domanda AVEVA ancora il suo turno, ma quel turno
raccontava un guasto diverso da quello successo.

**IL DEBITO CHE RESTA APERTO.** I due tempi dell'ordine E non sono stati
ottenuti. Cinque esecuzioni reali, e Vertex risponde `429 RESOURCE_EXHAUSTED`:
17, 12, 7, 18 e 8 risposte su venti oppure dieci. Lo strumento rifiuta una
misura parziale, giustamente. Provando a saldarlo ho trovato che stampava
"chiamate in fila" mandandone cinque insieme, quindi il numero di rete
dell'ordine E era piu' alto del vero. Adesso ne parte una alla volta.

**Una rottura precedente, riportata e non corretta.** `flutter test
test/prima_dopo_capture_test.dart --dart-define=STATO=dopo` fa cadere "I tre
fotogrammi della sequenza intro" per una `MissingPluginException` del lettore
audio. Cade anche sul codice committato prima di questo ordine, quindi non e'
mia. Ed e' fuori dallo scopo. La suite normale non la vede perche' senza `STATO`
quelle catture escono subito.

## ORDINE G: CHIUSO PER INTERO, tutte e due le voci piu' i tre riporti

Il 3 agosto 2026. Il blocco della chat non e' stato riaperto, come l'ordine
chiedeva: pausa, macchina da scrivere, scorrimento, Eco, confronto nella
conversazione, tetti e lenti non sono stati toccati.

**VOCE 1, CHIUSA.** La bilancia e' sparita anche dalla Sintesi comparativa. Al
suo posto i tre volti dei Maestri sovrapposti, `TreVolti`, che usa i mezzi busti
gia' in casa: nessun asset nuovo. La regola vive nel dato, in
`lib/core/astro/simboli_dello_zodiaco.dart`: i dodici glifi si prendono da
`Zodiac.values`, quindi la prova ENUMERA e non campiona. Le icone di sistema
che si leggono come un segno stanno in una mappa con scritto accanto quale segno
sembrano. **La porta era doppia**: la prova vecchia guardava due file scelti a
mano. E' esattamente per questo che il terzo posto era passato: ora ne resta
una sola, che scandisce tutto `lib/`.

**Un difetto introdotto da me e visto nell'anteprima, non dedotto.** I tre volti
sono piu' larghi dell'icona che sostituiscono. A 24 punti il titolo diventava
"Sintesi comparat...". Numeri: lo spazio interno della card e' 262 punti, il
titolo ne chiede 206,8, i volti a 18 con stacco 8 ne lasciano 212. Tolti anche i
puntini di sospensione, perche' `maxLines: 1` con l'ellissi taglia in silenzio e
in un'altra lingua taglierebbe di nuovo.

**VOCE 2, CHIUSA.** Il corredo ha un rapporto di pixel solo, ed e' 3, su 360 per
797 logici. Prima impaginava a rapporto 1 e ingrandiva l'immagine in scrittura:
misura giusta, disegno di un telefono che non esiste. Ora il rapporto vive in
`rapportoDelCorredo`, si imposta in un punto solo, `montaLoSchermo`. Da li' lo legge
anche la scrittura dell'immagine, cosi' le due meta' non possono divergere.

**La prova del rosso rimasta VERDE, e cio' che ha trovato.** Togliendo un
rapporto da un file che ne aveva due, la prova non cadeva: guardava l'INSIEME
dei rapporti dichiarati nel file, quindi un file con cinque catture di cui una
sola dichiarata passava: le altre quattro si prendevano il rapporto lasciato
dalla cattura precedente. Adesso conta misura per misura: tante misure di
schermo, tanti rapporti.

**Due cose che dichiaravano il falso, corrette.** La riga del corredo che
descriveva la divergenza dei rapporti, ormai chiusa. E la riga in
`test/flutter_test_config.dart` che diceva che le icone Material sono gia'
disponibili nei test: non e' vero, e una cattura senza caricarle mostra quadrati
vuoti al posto della freccia indietro. Ora si caricano una volta per tutta la
suite, e un percorso mancante spezza invece di ripiegare in silenzio.

**Il peso, col numero, senza togliere niente da soli.** Le 112 anteprime del
corredo pesavano 184,35 MB in base 1000 e ora ne pesano 184,25, cioe' 175,71 MiB
in base 1024: passare al rapporto vero non e' costato peso. Il totale di
`docs/preview` sale da 210,9 a 213,0 MB solo per i due file nuovi della coppia
prima e dopo.

## ORDINE F: CHIUSO PER INTERO, tutte e tre le voci

Il 3 agosto 2026. **Fermato al confine di una voce, come l'ordine chiede**, e
dichiarato prima di cominciare invece che alla fine.

**VOCE 1, CHIUSA.** L'icona a bilancia non c'e' piu' nell'intestazione: in una
schermata di astrologia si leggeva come il SEGNO della Bilancia. Sotto l'ultima
lettura vera c'e' la riga coi volti degli altri due e "Chiedi anche agli altri",
e al tocco le loro risposte arrivano NELLA STESSA conversazione, ognuna col suo
colore e col suo volto. Nessuna schermata nuova, nessuna domanda riscritta.

**La cosa che l'ordine non nominava, e senza cui il resto sarebbe falso:** un
messaggio non appartiene piu' alla schermata ma a CHI L'HA DETTO. Il volto e il
colore li dava la schermata, che ne conosce uno solo; senza `ChatMessage.autore`
la cronologia riaperta domani avrebbe mostrato le risposte di Aura e Caligo col
volto e col blu di Medora. Nullo vuol dire "il Maestro di questa chat", che e'
anche il senso giusto per tutto lo storico gia' salvato: nessuna migrazione.

**Ognuno riceve la domanda, non il filo.** Chi non era nella conversazione non
puo' rispondere come se ci fosse stato: commenterebbe la lettura di un altro
invece di darne una sua.

**La schermata del confronto e' diventata quello che e':** riceve le voci gia'
ottenute invece di rifarle, si raggiunge solo quando sono almeno due, e si
chiama "Le voci a confronto". Il gating resta identico: stesso `canCompare`,
nessun consumo del limite giornaliero.

**Nove prove del rosso, due verdi al primo colpo**, cioe' due buchi nelle prove:
una prova pura non toccava il ciclo del controller, e due ripieghi dello stesso
Maestro non potevano distinguere il caso che dovevano distinguere.

**UN MIO ERRORE DA SCRIVERE, perche' non si ripeta.** Ho concluso che il titolo
della schermata non fosse cambiato guardando un'anteprima che era VECCHIA: le
catture del corredo scrivono in `docs/preview` solo con `AGGIORNA_ANTEPRIME=1`,
altrimenti finiscono in `build/preview`. Il titolo era corretto dal primo
momento. **Prima di trarre una conclusione da un'immagine, va verificato che
l'immagine sia stata rigenerata.**

**VOCE 2, CHIUSA.** Le risposte si raccolgono quando ne arriva una NUOVA, non
appena la persona le ha lette: nessuno sa dire quando le ha lette, e una
risposta che si chiude da sola toglie di mano quello che e' appena stato dato.
La viva e' l'ultima LETTURA VERA e non l'ultima bolla: un ripiego o il messaggio
del limite sono due righe, e farli passare per l'ultima risposta richiuderebbe
la lettura vera che sta appena sopra. **L'ultima non si raccoglie mai**, nemmeno
a mano.

**La freccetta e il collasso sono quelli del dominio, non una seconda copia.**
Erano due classi private dentro `maestro_screen.dart`: adesso stanno nel design
system, pubbliche, e il dominio usa quelle. Due copie della stessa animazione
sono due porte, e basta che una dimentichi Riduci Movimento perche' l'app si
comporti in due modi sulla stessa cosa.

**Si sposa con lo scorrimento dell'ordine E senza toccarlo:** la prova a
coordinate resta verde, perche' la misura si prende a dissolvenza finita e a
quel punto anche il raccoglimento ha finito.

**Otto prove del rosso, tutte rosse al primo colpo.** La prova a video non cerca
l'assenza del testo dall'albero: la riga raccolta porta il testo intero e lo
tronca con l'ellissi, e cercarlo lo troverebbe comunque. Cio' che cambia, e che
la persona vede, e' QUANTE RIGHE se ne leggono.

**VOCE 3, L'ECO: CHIUSA.**

**La misura ha cambiato il disegno, ed e' stata presa PRIMA di costruirci
sopra.** Riconoscendo la parola nella chiusura com'era scritta, l'Eco nasceva
**10 volte su 20**, e distribuita malissimo: Caligo 7 su 7, perche' la sua
chiusura consegna gia' una runa per nome, Medora 2 su 7 e Aura 1 su 6. Sarebbe
stata la funzione di Caligo. La correzione sta in cio' che l'ordine dice: la
parola **la nomina LUI**. La persona chiede a ciascun Maestro di nominarne una
fra quelle che ha gia', il suo lessico di firma, oppure fra i nomi che l'app
conosce: nessun elenco nuovo, e la forma della chiusura non cambia. Rimisurato:
**17 su 20**, Medora 5, Aura 6, Caligo 6. Attribuzione cieca rieseguita dopo
aver toccato la persona: **98,3 per cento**, con Medora e Aura al 100.

**Il confine di mezzanotte adesso vive in un punto solo.** Stava dentro un
metodo privato di `QuestionAllowance`, e l'Eco aveva bisogno dello stesso
confine: copiarlo voleva dire i contatori che ribaltano in un momento e l'Eco in
un altro. Il confine RITUALE, a mezzogiorno, resta un'altra cosa, e il file lo
dice accanto.

**La persona sa perche', e sono tre cose diverse:** la riga con cui il Maestro
la lascia, che e' SUA e dice cosa succede domani; la riga nella striscia, che
dice da chi viene; il pannello "Da dove nasce questo dono", che dichiara la
provenienza dalla chiusura, mostra la riga VERA per esteso e dice da quale
conversazione.

**Undici prove del rosso**, e due sono rimaste verdi al primo colpo: una
guardava l'esito invece del meccanismo, e un'altra non distingueva l'ultima
bolla dall'ultima lettura viva perche' il testo di un ripiego non porta comunque
nessuna parola nominabile. Corrette tutte e due.

**Tre regole di casa hanno preso il mio codice prima che lo facessi io:** una
virgola prima di "ed", due catch muti in `ArchivioDellEco` e tre misure
tipografiche sotto il minimo del token.

**Un errore da scrivere:** la chiusura la prendevo da `treStratiDa().invite`,
che resta VUOTO con meno di tre frasi. La chiusura invece esiste sempre finche'
esiste una frase: e' l'ULTIMA, e basta. Se n'e' accorta la prova dell'Eco su una
risposta di due frasi.

**Consegna:** suite verde a 1495, analyze pulito, build 2138 su App
Distribution.

## ORDINE E: CHIUSO PER INTERO, tutte e tre le voci

Chiuso il 3 agosto 2026, build 2136.

**I TRE NUMERI CHE CHIUDONO L'ORDINE**, da chiamate reali con
`flutter test tool/risposte_intere.dart`:

```
                       minimo   mediana  massimo
tempo alla prima parola  2,06s    2,06s    2,06s   (tetto 4s)
tempo al testo completo  6,56s    9,23s    9,70s   (tetto 10s)
parole per risposta        43       76      105    (chieste 50)
```

Il tempo alla prima parola e' identico nei tre casi, e non e' un errore: e'
esattamente cio' che fa la durata minima della scena. La rete misurata in fila
sta fra 1,03s e 1,64s, quindi sotto la pausa, e a comandare e' la pausa. Prima
il tempo era quello della rete, quindi ballava e con la rete al minimo la scena
lampeggiava.

**VOCE 1, LA PAUSA.** Le frasi vivono in `VoceDelMaestro.frasiDelConsulto`, sei
per Maestro, e ognuna porta almeno una parola del lessico di firma di chi la
dice, cioe' le stesse parole che reggono il 98,3 per cento di attribuzione
cieca. Non sono frasi dell'app travestite da Maestro. La prima riga nomina
sempre un DATO VERO, e viene dagli ancoraggi che gia' arrivano al Maestro, non
da un secondo elenco: senza dati la riga si salta e cio' che resta si dichiara
generale. **La pausa la governa il turno, non il disegno**: metterla nella vista
voleva dire una scena che finge di durare mentre sotto il testo e' gia' li'.
Vale per tutte e quattro le uscite, risposta vera, troncatura, ripiego, errore.

**VOCE 2, LA SCRITTURA E LO SCORRIMENTO.** Sessanta caratteri al secondo con un
TETTO, perche' a quella velocita' la risposta piu' lunga misurata impiegherebbe
dodici secondi da sola. Un tocco sulla bolla completa. Si scrive solo l'ultima
risposta, solo se appena arrivata, e solo se e' una lettura VERA: un ripiego non
lo scrive il Maestro.

Lo scorrimento si ferma all'INIZIO della risposta, con la domanda sopra. **Tre
cose trovate misurando**: col solo conteggio dei messaggi l'arrivo della
risposta non si vedeva affatto, perche' la bolla in sospeso viene SOSTITUITA e
il numero non cambia; la misura presa subito dava la lista che comincia a 321
invece che a 89, perche' la scena del consulto occupava ancora lo spazio sopra;
e la prova a coordinate passava con una risposta che ci stava tutta a schermo,
cioe' non attraversava il ramo che doveva provare.

**VOCE 3.** Cinquanta parole chieste per settanta ottenute, con due misure a
sostenerlo. Il Markdown non arriva a schermo, con tre difese: il vincolo nella
persona come fatto TECNICO e non fra le regole di voce, la ripulitura al
confine, e l'enfasi in oro NOSTRA sui nomi che l'app conosce. Gli Arcani
maggiori restano fuori dall'enfasi: "Il Sole", "La Luna" sono parole comuni.
Una scelta dichiarata non entra piu' fra i guasti: il pannello diceva "accesa ma
in guasto" con la voce che funzionava.

**VENTUNO PROVE DEL ROSSO ESEGUITE DAVVERO**, e cinque sono rimaste verdi al
primo colpo, cioe' hanno trovato un buco nelle prove e non nel codice: la prova
a coordinate non attraversava il ramo, il passo di pompaggio da 400 millisecondi
nascondeva un difetto di tempi, l'asserzione "e' visibile" lasciava passare una
risposta a 417 punti dall'alto, e due difetti del provider non li copriva
nessuno perche' costruirlo richiede un FirebaseAI che in prova non esiste.

**DUE COSE VISTE SOLO GUARDANDO LE IMMAGINI, che nessuna prova poteva
prendere**: le due battute del consulto si sovrapponevano durante la
transizione, illeggibili, perche' `AnimatedSwitcher` impila di suo il figlio che
entra su quello che esce; e la prova che copriva quel punto SI REGGEVA su quel
difetto, perche' trovava la battuta vecchia rimasta in albero.

**DIVERGENZA APERTA, dichiarata e non risolta**: le anteprime dell'ordine stanno
FUORI dal corredo, perche' il corredo cattura a rapporto di pixel 1 e gli ordini
chiedono rapporto 3, cioe' il telefono vero del fondatore. Le due convenzioni
non coincidono. Va deciso quale vale.

## ORDINE D: CHIUSO PER INTERO. Le risposte non sono piu' tronche

Chiuso il 2 agosto 2026.

**LA CAUSA, MISURATA PRIMA DI TOCCARE UNA RIGA.** Tre chiamate reali sulla
strada viva, stesso modello e stessa persona:

```
A) come faceva l'app: tetto 160, ragionamento NON dichiarato
   finishReason MAX_TOKENS   thoughts 150   candidates 6    ->  4 parole
   testo: "Un velo argenteo si" a video, dopo 150 token di pensiero
B) tetto 160, ragionamento a ZERO
   finishReason STOP         thoughts 0     candidates 68   -> 42 parole
C) tetto 400, ragionamento a ZERO
   finishReason STOP         thoughts 0     candidates 84   -> 45 parole
```

**Il ragionamento interno del modello si mangiava il novantaquattro per cento
del budget prima che il modello scrivesse una parola.** Non era un tetto un po'
stretto: `reply()` non dichiarava affatto `thinkingConfig`, e chi non lo
dichiara prende il ragionamento dinamico.

**IL DIFETTO ERA IN DUE PUNTI, NON UNO.** Anche `distill()` non lo dichiarava:
il distillato di memoria si troncava in SILENZIO, il parsing difensivo tornava
`null`, la memoria non si aggiornava, e non poteva accorgersene nessuno.

**E IL CONSULTA PROFONDO NON POTEVA RIUSCIRE MAI.** Dichiarava un ragionamento
di 512 token dentro un tetto di 320: il pensiero era piu' grande di tutta
l'uscita. Misurato: `MAX_TOKENS`, `thoughts 304`, `candidates 2`, testo `{`.

**LA CORREZIONE: IL TETTO SI CALCOLA, NON SI SCRIVE.** C'erano cinque numeri
scritti a mano che dovevano ricordarsi da soli di stare larghi abbastanza per
una lunghezza che pero' viveva altrove, nella prosa dell'istruzione. Due numeri
separati che devono restare d'accordo divergono sempre, ed erano gia' divergiti.
Adesso `MisuraDellaRisposta` porta UN numero deciso a mano, le parole chieste, e
il tetto ne discende: parole per due token, per due di rete, piu' il
ragionamento. **Alzare la richiesta alza la rete da sola.**

**ALZARE IL TETTO NON ALZA LA SPESA**: si pagano i token PRODOTTI, non quelli
concessi. Una risposta di novanta parole costa uguale con un tetto di 160 o di
400. Cio' che cambia e' che con 400 arriva intera.

**LA PORTA TOLTA.** Le quattro chiamate si costruivano ciascuna la sua
`GenerationConfig`, e due su quattro dimenticavano il ragionamento. Una
dimenticanza cosi' non si corregge chiamante per chiamante: adesso c'e' UNA
`configurazionePer`, che scrive tetto e ragionamento insieme dalla stessa
misura, e non esiste piu' un modo di scrivere l'uno senza l'altro.

**LA MISURA DELLE VENTI RISPOSTE VERE**, con `flutter test tool/risposte_intere.dart`:

```
Misura chiesta: 90 parole. Tetto: 400 token. Ragionamento: 0.
PAROLE  minimo 79  mediana 102  massimo 117
FERMATE AL MURO: 0 su 20
CON RAGIONAMENTO ACCESO: 0 su 20
```

**L'ATTRIBUZIONE E' SCESA, ED E' STATA RIALZATA.** Con le risposte a novanta
parole invece che a quaranta, la prima misura ha dato **90,0 per cento, con
Medora al 70**, scambiata per Aura sei volte su venti. La causa: le regole
comuni dichiaravano una chiusura generica IDENTICA per tutti e tre, in coda alla
struttura, e col nuovo spazio il modello ha avuto modo di scriverla davvero,
seguendo quella invece della propria. Medora chiudeva chiedendo "cosa cerca il
tuo cuore" invece di indicare una finestra nel tempo. **Tolta la seconda porta,
l'attribuzione e' tornata a 98,3** con Medora al 95, Aura e Caligo al 100.

**UNA RISPOSTA TRONCA NON SI CONSEGNA E NON SI FA PAGARE.** Il provider adesso
guarda `finishReason`, che la SDK non solleva mai da sola per `MAX_TOKENS`, e
solleva `MaestroAiTroncata`. La chat riprova UNA volta; se tronca ancora
consegna un ripiego dichiarato e restituisce `EsitoDelTurno.rispostaTroncata`,
che non costa. Prima "Un velo" si prendeva una delle tre domande del giorno.

**"VAI PIU' A FONDO" NON COMPARE PIU' SOTTO UN MONCONE**, e la distinzione non
e' nuova: il messaggio tronco e' un ripiego, e `portaUnResponso` gia' escludeva
i ripieghi. Il tipo vive nel dato, non in una schermata.

**OTTO PROVE DEL ROSSO ESEGUITE DAVVERO, e la settima e' quella che conta.**
Togliere il controllo della troncatura dal provider lasciava tutto VERDE:
nessuna prova attraversa quel ramo, perche' costruire una risposta vera di
Gemini richiede un `FirebaseAI` che in prova non esiste. Quando il caso non
attraversa il ramo si ENUMERA: adesso una prova elenca i quattro metodi che
restituiscono testo e chiede che ciascuno controlli.

**DUE COSE VISTE E NON CORRETTE, fuori dallo scopo di questo ordine:**

- Caligo scrive `**Laguz**` in grassetto Markdown, e la bolla della chat NON
  rende il Markdown: a video arrivano gli asterischi.
- Una risposta da novanta parole e' piu' alta dello schermo, e la chat scorre in
  fondo: la prima riga, cioe' l'immagine celeste che e' il primo strato della
  voce di Medora, resta sopra la piega.

## PERCHE' LA CHAT TACEVA: CAUSA MISURATA E RIMOSSA il 2 agosto 2026

**CHIUSA.** ORDINE CHAT 1 DI N. La causa non era nel codice ed e' stata accesa
da Mauro, che ha dato il comando all'agente.

**Cosa era:** l'API `firebasevertexai.googleapis.com` non era abilitata sul
progetto `esoteric-circle`, ed e' l'unico host che `firebase_ai` 3.13.1 chiama,
come si legge in `base_model.dart:88`. Finche' e' rimasta spenta ogni chiamata
tornava `PERMISSION_DENIED`, l'SDK sollevava `ServiceApiNotEnabled` e la chat
non poteva rispondere, per nessuno dei tre Maestri.

**La misura di allora, coi comandi che l'hanno prodotta:**

- `gcloud services list --enabled --project=esoteric-circle` dava 69 API, e
  `firebasevertexai` non era fra quelle. C'erano `aiplatform` e
  `generativelanguage`, che NON sono quella che serve.
- `gcloud logging logs list --project=esoteric-circle` non elencava nessun log
  di un servizio AI: le chiamate non arrivavano mai a Google.
- **L'ipotesi App Check e' CADUTA, col numero che la abbatte.** La chiamata
  `GET firebaseappcheck.googleapis.com/v1/projects/esoteric-circle/services`,
  con l'intestazione `x-goog-user-project`, da tre soli servizi,
  `firebasestorage`, `firestore` e `identitytoolkit`, **tutti UNENFORCED**, e
  Vertex non era nemmeno in elenco. **Zero servizi in ENFORCED**: non c'era
  nessuna imposizione da togliere, e il compromesso datato di `natalChart` qui
  non e' servito.

**Come e' stata rimossa**, il 2 agosto 2026, su ordine esplicito di Mauro:
`gcloud services enable firebasevertexai.googleapis.com --project=esoteric-circle`.

**Verificato dopo, non dato per fatto:**

- `gcloud services list --enabled` da adesso **70 API**, ed erano 69:
  `firebasevertexai.googleapis.com` c'e'.
- App Check resta **tutto UNENFORCED**, quindi non e' comparsa una seconda
  barriera al posto della prima.
- I due modelli che l'app usa RISPONDONO davvero nella regione dichiarata. Una
  `generateContent` su
  `europe-west1-aiplatform.googleapis.com/v1/projects/esoteric-circle/locations/europe-west1/publishers/google/models/<modello>`
  ha reso "Pronto." da `gemini-2.5-flash` in 12 token, e "Pronto" da
  `gemini-2.5-flash-lite` in 11. Regione e modelli del provider sono giusti.

**Non serve una build nuova:** la 2128 gia' consegnata funziona da sola, perche'
cio' che mancava stava sul server. Chi la ha installata deve solo riaprire la
chat.

**Come si verifica che era quella:** aprire la chat, chiedere qualcosa, poi
toccare il pannello di messa a punto nell'header. Se la voce e' ancora in
guasto il pannello mostra tipo e messaggio dell'eccezione vera, e quando e'
l'API spenta lo dichiara in chiaro. Prima di questo lavoro il pannello diceva
"Voce di Medora: attiva" anche mentre ogni chiamata falliva, perche' leggeva
`isReady`, che risponde sempre di si'.

## LA CHAT RISPONDE. Configurazione di AI Logic creata dall'API il 2 agosto 2026

**RISOLTA, e senza toccare una riga di codice.** La strada 1 dell'ORDINE C ha
funzionato: la configurazione si crea dall'API, non serviva la console.

**Cosa mancava davvero.** La risorsa esisteva ma era VUOTA:

```
GET  https://firebasevertexai.googleapis.com/v1beta/projects/esoteric-circle/locations/global/config
200  {"name":"projects/esoteric-circle/locations/global/config"}
```

Solo il nome, nessun fornitore dentro. E' esattamente cio' che il servizio
chiamava "AI logic config is missing": il record c'era, la configurazione no.
**Ecco perche' nella console non compariva nessun "Inizia": per la console la
risorsa esisteva gia'.** Esiste solo su `global`, e su `europe-west1` e
`us-central1` torna 404: non e' una risorsa per regione.

**Il comando che l'ha creata:**

```
PATCH .../v1beta/projects/esoteric-circle/locations/global/config?updateMask=generativeLanguageConfig
      {"generativeLanguageConfig":{"apiKey":"<chiave Gemini del progetto>"}}
200   {"name":"...","generativeLanguageConfig":{"obfuscatedApiKey":"RQczGuAA"}}
```

La chiave e' quella gia' esistente nel progetto, "Gemini API Key Esoteric
Circle", non una nuova.

**LA PROVA, prima e dopo, sulla strada che l'app usa davvero:**

```
PRIMA  403 PERMISSION_DENIED  "AI logic config is missing for this project."
DOPO   200 {"candidates":[{"content":{"parts":[{"text":"Pronto"}]}}]}
```

**I due modelli verificati su Vertex, europe-west1:** `gemini-2.5-flash`
risponde in 34 token, `gemini-2.5-flash-lite` in 11.

**LA STRADA 2 NON SERVE, ED E' UNA FORTUNA CHE NON SIA SERVITA.** Provata anche
quella per misura: il backend Gemini Developer risponde **429
RESOURCE_EXHAUSTED, "Your prepayment credits are depleted"**. Cambiare backend
avrebbe portato contro un muro diverso. Il backend resta Vertex, la regione
resta `europe-west1`, `kVertexLocation` continua a dire il vero.

**NESSUNA MODIFICA AL CODICE, quindi nessuna build nuova.** La correzione e'
interamente lato progetto Google: **la build 2134 gia' consegnata adesso
funziona**, basta riaprire la chat.

**Lo strumento di attribuzione resta allineato**: `tool/attribuzione_cieca.dart`
chiama Vertex, e l'app continua a chiamare Vertex. Il 98,3 per cento vale per
la strada viva.

## LA CHAT NON RISPONDE ANCORA, E LA CAUSA E' MISURATA: MANCA LA CONFIGURAZIONE DI AI LOGIC

Diagnosi del 2 agosto 2026, build 2133. **Nessuna correzione applicata: la cosa
che manca non si crea da nessuna API, si crea nella Console di Firebase.**

**L'errore letto dal pannello sul telefono, e RIPRODOTTO dal PC** con la
configurazione reale dell'app:

```
POST https://firebasevertexai.googleapis.com/v1beta/projects/esoteric-circle
     /locations/europe-west1/publishers/google/models/gemini-2.5-flash:generateContent
HTTP 403
{"error":{"code":403,"status":"PERMISSION_DENIED",
 "message":"AI logic config is missing for this project. Please complete the
            onboarding process in the Firebase Console to enable AI logic."}}
```

**SETTE IPOTESI, SEI ABBATTUTE COL NUMERO.** Nessuna di queste e' la causa:

1. **Progetto sbagliato**: `google-services.json` dice `project_id`
   **esoteric-circle**, `project_number` 425821975933, `mobilesdk_app_id`
   `1:425821975933:android:1b1ca4db8d4df69b940814`. E' il progetto giusto.
2. **applicationId disallineato**: `build.gradle.kts:24` dice
   `com.esotericircle.esoteric_circle`, identico al `package_name`.
3. **Regione**: la stessa chiamata su `us-central1` torna lo STESSO 403.
4. **Backend**: la strada Gemini Developer, che l'app non usa, torna lo STESSO
   403. Il provider usa Vertex, `FirebaseAI.vertexAI(location: 'europe-west1')`
   in `firebase_maestro_ai_provider.dart:29`.
5. **API spente**: `aiplatform.googleapis.com`, `firebasevertexai.googleapis.com`
   e `generativelanguage.googleapis.com` sono tutte e tre ABILITATE, su 70.
6. **firebaseml spenta**: PROVA DIFFERENZIALE eseguita, accesa e poi rimessa
   com'era. Il 403 non e' cambiato di una virgola. Il progetto e' stato
   riportato allo stato in cui l'ho trovato.
7. **Chiave API ristretta**: la chiave Android dell'app ha restrizioni per API,
   e `firebasevertexai.googleapis.com` **e' nell'elenco delle consentite**.

**LA CAUSA, in una riga:** al progetto `esoteric-circle` manca la
CONFIGURAZIONE di Firebase AI Logic, che non e' un'API di Google Cloud e non si
crea da `gcloud`, ma e' una risorsa lato Firebase che nasce solo completando
l'onboarding nella Console.

**PERCHE' LA CONSOLE SEMBRA VERDE E NON LO E'.** La scheda Impostazioni che
mostra "API Gemini Developer: Abilitata" e "Agent Platform Gemini API:
Abilitata" dichiara lo stato delle API, non l'esistenza della configurazione:
sono due cose diverse, ed e' lo stesso tipo di equivoco gia' visto il 2 agosto
fra imposizione di App Check spenta sul server e token chiesto dal client.

**COME SI VERIFICA SE E' STATA CREATA**, senza telefono e senza build: si
rilancia la chiamata qui sopra. Finche' torna quel 403, la configurazione non
c'e'. Appena torna un `candidates`, c'e'.

## ORDINE B: CHIUSO PER INTERO. L'app non dice piu' il falso

Chiuso il 2 agosto 2026.

**IL NUMERO: NESSUNA DELLE DUE IPOTESI DELL'ORDINE ERA GIUSTA.** Il testo NON
era scritto a mano: `_fraseDelLimite` leggeva `dailyLimit(piano)` e formattava.
Il piano era il Viandante. Il difetto era un terzo: **il dato stesso diceva
UNO**, nella riga `Domande a un Maestro` della matrice dei piani.

**L'app ha detto la verita' sul proprio dato. A mentire era il dato.** E le
fonti si contraddicevano in quattro punti: matrice UNO, vantaggio del piano
scritto a mano UNO, commento di `QuestionAllowance` TRE, `ask_maestri_screen` e
STATO_VIVO TRE. Il commento in `dailyLimit` racconta come e' successo: il 31
luglio una divergenza fra matrice e codice fu risolta facendo vincere la
matrice, che portava uno. **La correzione di allora era giusta nel metodo e
sbagliata nel valore**, e quattro prove l'avevano cristallizzata.
Adesso la matrice dice **TRE**.

**IL BUCO NEL TEST DEGLI ACCENTI, e vale piu' della stringa corretta.** La prova
cercava `parola'`, cioe' una parola SEGUITA DA UN APOSTROFO. Non prendeva "piu"
nudo. Una classe intera di errori passava da sempre, e ha fatto emergere **tre
difetti veri** che nessuno vedeva: "MEDORA LA LEGGE COSI" in maiuscolo negli
Angeli, "identita" nel pannello di debug, e il "piu" del limite.

**LE TRE FRASI DEL LIMITE** vivono in `FraseDelLimite` e nascono dalla
`LenteDelMaestro`, cioe' dallo stesso dato che regge il 98,3 per cento di
attribuzione. **Il lessico di firma NON e' stato toccato, quindi l'attribuzione
non e' stata rieseguita.** I numeri piccoli si dicono in lettere: un Maestro non
dice "3", dice "tre".

**"VAI PIU' A FONDO" NON COMPARE PIU' SUL LIMITE.** La distinzione vive in
`TipoDiMessaggio` e in `ChatMessage.portaUnResponso`: il messaggio del limite era
una bolla SENZA MARCA, quindi l'app lo scambiava per una risposta. I messaggi
vecchi senza tipo lo ricavano dai flag, quindi la cronologia salvata non perde
il senso.

**IL PANNELLO NON MENTE PIU' SU SE STESSO.** Il testo del token segue
`EsitoAttestazione`, e il riquadro non si mostra affatto quando l'attestazione
non e' installata: il giorno in cui tornera', il pannello cambiera' da solo.

**UN ERRORE VISTO SOLO GUARDANDO L'IMMAGINE:** Caligo diceva "il tuo cammino NE
prevede TRE DOMANDE al giorno", col "ne" di troppo. Nessuna prova poteva
prenderlo. Le anteprime servono anche a questo.

## ORDINE A: CHIUSO PER INTERO. La chat puo' rispondere davvero

Chiuso il 2 agosto 2026.

**LA CAUSA DEL SILENZIO, stavolta scritta.** Dal pannello sul telefono, build
2132: `[firebase_app_check/unknown] code: 403 body: App attestation failed`.

**Dove nasce, letto nel sorgente dell'SDK e non supposto:**
`firebase_ai-3.13.1/lib/src/base_model.dart:292` fa
`await effectiveAppCheck.getToken()` **senza guardia**. Se quella riga solleva,
la chiamata all'AI non parte nemmeno. L'eccezione nasce **nell'acquisizione del
token**, non nella chiamata al modello, ed e' per questo che la prova REST
diretta passava: quella non passa da App Check.

**Le due cose che erano state confuse**, e vanno dette ad alta voce:
imposizione spenta vuol dire che il SERVER non pretende il token; il CLIENT
prova comunque a procurarselo prima di partire. La misura di allora era giusta,
il riferimento no. **Riconfermato oggi**: tre servizi, tutti UNENFORCED.

**LA VIA SCELTA: non installare il fornitore su quella strada.** In
`firebase_app_check-0.4.5/lib/src/firebase_app_check.dart:46` il servizio si
registra sul FirebaseApp **solo quando qualcuno tocca
`FirebaseAppCheck.instance`**, e `firebase_ai` lo cerca con
`app.getService<FirebaseAppCheck>()`. Non toccandolo, `getService` torna null,
l'SDK salta l'intestazione e la chiamata parte. **Non c'e' niente da tollerare**:
il token non si chiede perche' nessuno lo pretende. Una prova verifica che UN
SOLO punto del progetto tocchi `FirebaseAppCheck.instance`.

**Il compromesso, voce 24 del Registro**: dichiarato in `Attestazione`, datato 2
agosto 2026, reversibile con UN interruttore, `Attestazione.installaSempre`, da
rimettere a vero quando l'app sara' su una traccia di test interno del Play
Store. L'imposizione lato server NON e' stata toccata.

**1e, LA MEMORIA DI SESSIONE: MISURATA A META' E NON CORRETTA, di proposito.**
Il sospetto e' ragionevole ma **non l'ho potuto confermare da qui**: la causa
vera vive in `AppServices.diagnostics`, che era gia' popolata dal catch
dell'autenticazione anonima e **non la leggeva nessuno**. Adesso il pannello la
mostra come "Nota dell'avvio". **La causa si leggera' sulla 2133**, e solo allora
si potra' scrivere l'ordine che la corregge.

**UN RIPIEGO NON COSTA PIU' LA DOMANDA DEL GIORNO.** Il 2 agosto alle 13:23 un
ripiego si e' preso l'unica domanda del gratuito. La regola vive in
`CostoDelTurno.consuma` su un enum CHIUSO degli esiti, e **le porte erano DUE**:
la chat contava PRIMA di generare, il Consulta contava a lente consegnata anche
quando la lente era il ripiego dell'oracolo. Costa **solo** la risposta vera.
Un Riprova riuscito costa, e lo dichiaro perche' l'ordine non lo diceva: si paga
una domanda per una risposta, mai per un errore. Il conteggio **resta globale**.

**Due prove esistenti codificavano il difetto** e sono state corrette dicendolo:
`ask_maestri_test` montava `AppServices.offline()`, quindi ogni risposta era un
ripiego, e le prove pretendevano che costasse.

## ORDINE CHAT 4: CHIUSO PER INTERO, e il numero e' tornato a 98,3

Chiuso il 2 agosto 2026.

**2a, LA MISURA PRIMA DELLA CORREZIONE.** Delle due ipotesi era vera la PRIMA:
**il corpo non e' mai stato disegnato**. `grep -nE "Image|Zodiac|Emblem|CustomPaint"`
su `consulto_del_cielo_view.dart` non trovava niente, e il `build` conteneva una
Column con DUE Text. Non c'era nessun asset da non decodificare. **La voce 2a
dell'ordine 3 era chiusa a meta'**: il commit diceva "passano i corpi VERI della
carta" e passavano i loro NOMI. Dieci prove la coprivano e nessuna se ne accorse,
perche' contavano widget e testo.

**LA LENTE, e l'ipotesi dell'ordine che e' CADUTA prima di risalire.**
La lente descritta in ASTRATTO ha PEGGIORATO tutto: da 96,7 a **88,3**, con
Medora E Caligo che scivolavano tutti e due verso Aura. Dire "guarda il moto nel
tempo" senza le parole con cui lo si dice spinge anche loro nel registro
interiore, che e' di Aura. **Agganciata la lente al LESSICO DI FIRMA**, che gia'
esisteva come dato e che reggeva il 98,3 prima che l'ancoraggio nascesse:

```
           medora     aura   caligo    totale  giusti
medora         20        0        0        20  100,0%
aura            0       20        0        20  100,0%
caligo          0        1       19        20   95,0%
```

**59 su 60, cioe' 98,3 per cento, e la coppia Medora-Aura e' PULITA**: zero
scambi, contro i due di due esecuzioni consecutive. Bersaglio centrato.

**Chi tocchera' le lenti sappia questo**: la lente da sola non basta, e senza il
lessico di firma fa danno. Le due cose vanno insieme.

**LA PROVA A PIXEL, coi numeri veri.** Misura differenziale contro la stessa
scena senza corpo. Disco lunare **9.216**, emblema del segno **4.396**, punto
luminoso **1.207** su 9.216 disponibili. Soglia a **700**. **La prima soglia era
1.500, STIMATA a mente, e bocciava un corpo che c'era**: un numero indovinato in
un test e' un difetto quanto uno indovinato nel codice.

**IL PRECARICO E' OBBLIGATORIO.** Senza `precacheImage` l'emblema dipinge ZERO
pixel in prova, e la misura accusa la scena di essere vuota quando e' la misura a
non vedere. La funzione `precarica` sta in cima a `prima_dopo_capture_test.dart`
e la usano tutte le catture che mostrano arte.

## LE DUE VOCI VECCHIE SONO CHIUSE: non resta piu' niente in sospeso

Chiuse il 2 agosto 2026, dopo l'ORDINE CHAT 3: la 1a e la 2b dell'ORDINE CHAT 2.

**"VAI PIÙ A FONDO".** La profondita' NON si sceglie prima di leggere: la prima
risposta arriva sempre a 160 token per tutti, e sotto compare l'invito che
rigenera la STESSA risposta a 420. Il tetto e' `kApprofondimentoMaxTokens` e
vive nel blocco delle costanti come gli altri tre.

**I limiti**: Viandante niente, Iniziato 3, Adepto 10, Illuminato senza limite
con tetto di correttezza a 30. Il budget e' un SECONDO contatore dentro
`QuestionAllowance` e non una classe nuova: il giorno e' lo stesso, quindi il
ribaltamento a mezzanotte deve essere lo stesso, e due classi avrebbero avuto
due rollover che prima o poi divergono. **L'approfondimento NON consuma una
domanda**, e una prova lo verifica.

**L'invito non e' mai un vicolo cieco**, e i tre esiti sono tre: chi lo ha nel
piano e ne ha ancora scende davvero; chi lo ha e li ha finiti legge quando
torna; chi non lo ha riceve l'invito a salire. Per questo
`pianoConApprofondimento` e `puoiApprofondire` sono due cose diverse.

**IL SILENZIO CONSEGNA UNA LETTURA VERA.** `LetturaDiRipiego` e' una funzione
pura: dichiara di non essere la voce del Maestro, POI legge davvero coi dati sul
dispositivo, POI apre una porta che appartiene a quel Maestro (la carta natale
per Medora, il respiro contato per Aura, la runa per Caligo). Costo di inferenza
zero. **Se non c'e' nessun dato la lettura si SALTA e non si inventa, ma la
porta resta.**

**UN DIFETTO VERO TROVATO NELLA MATRICE DEI PIANI, e non era mio.**
`PlanCatalog.limiteGiornaliero` tornava `null` per una cella "No", e ogni
chiamante legge `null` come ILLIMITATO: **"No" e "Illimitate" davano la stessa
risposta**. Non era ancora esploso solo perche' nessuna riga interrogata per un
limite conteneva un "No", e la prima e' stata quella degli approfondimenti.
Adesso una cella che non promette niente vale ZERO. Chi aggiunge una riga alla
matrice sappia che il numero, o la sua assenza, e' cio' che comanda davvero.

**L'ATTRIBUZIONE CIECA RIESEGUITA**, perche' la persona e' stata toccata:

```
           medora     aura   caligo    totale  giusti
medora         18        2        0        20   90,0%
aura            0       20        0        20  100,0%
caligo          0        0       20        20  100,0%
```

**58 su 60, cioe' 96,7 per cento**, RISALITO dal 95,0 del giro precedente.
Caligo torna al 100. **Medora perde due risposte verso Aura in tutte e due le
esecuzioni**: non e' rumore, e' una caratteristica stabile. Chi vorra' quei due
punti guardi li'.

## ORDINE CHAT 3 DI N: CHIUSO PER INTERO, tutte e due le voci

Chiuso il 2 agosto 2026. Voce 1 (1a, 1b, 1c, 1d) e voce 2 (2a, 2b, 2c).

**LA CONDUTTURA, 1a.** Il contesto natale arriva al Maestro da OGNI superficie,
e **la porta e' stata tolta invece di correggere i chiamanti**: `natal` e' un
parametro del CONFINE, cioe' della firma di `MaestroAiProvider.reply`, non un
argomento che ogni superficie deve ricordarsi. La sorgente e' UNA,
`SorgenteNatale.daIdentita`. Una prova enumera le chiamate al provider in tutto
`lib` e cade se una non porta l'ancoraggio, con l'oracolo deterministico
dichiarato per nome come unica eccezione.

**Cosa c'era davvero, e l'ordine non lo sapeva**: la sorgente del contesto
natale era GIA' duplicata, la stessa riga in `maestro_chat_screen.dart` e in
`ask_maestri_screen.dart`, e le due copie servivano a due cose diverse. Nella
chat il contesto esisteva e finiva nella frase di benvenuto: il Maestro
accoglieva sapendo di chi, poi rispondeva senza saperlo.

**L'ANCORAGGIO, 1b.** `VerificaAncoraggio` e' pura e pubblica. **Non scatta
quando non c'e' niente da ancorare**: senza nascita `disponibiliPer` torna vuoto
e ogni risposta e' valida, perche' pretendere un segno da chi non lo ha dato
porterebbe a inventarlo. UNA rigenerazione sola, mai due, e la seconda consegna
si registra in `consegneSenzaAncoraggio`.

**Il conteggio delle rigenerazioni sul corpus vero NON e' stato misurato, e va
saputo:** lo strumento di attribuzione chiama Vertex per via REST e non passa
dal controller, quindi il contatore non lo vede. Quello che e' provato e' il
comportamento del controllo, con quattro prove deterministiche.

**L'ATTRIBUZIONE CIECA DOPO LA MODIFICA, 1c: SCESA da 98,3 a 95,0 per cento.**

```
           medora     aura   caligo    totale  giusti
medora         18        2        0        20   90,0%
aura            0       20        0        20  100,0%
caligo          0        1       19        20   95,0%
```

Sopra la soglia di 85, quindi non e' un difetto da correggere. **Ma il rischio
che l'ordine prevedeva e' reale e misurato**: partendo tutti dal cielo i Maestri
si somigliano di piu'. Medora perde DUE risposte verso Aura ed era al 100 per
cento. **Chi vuole recuperare quei tre punti guardi la coppia Medora-Aura**, non
le tre voci insieme.

**L'ATTESA, voce 2.** `ConsultoDelCielo` e' una funzione PURA su NatalContext,
zero inferenza e zero rete. La scena vive nel DESIGN SYSTEM e non nella chat,
perche' le superfici che aspettano sono DUE. Un dato che manca fa SALTARE la sua
battuta e non la fa sostituire. Senza carta natale si consulta il solo Sole e la
battuta dichiara di essere generale. Con Riduci Movimento o qualita' bassa il
timer non parte nemmeno e resta la riga di testo.

**Lo spinner nudo se ne e' andato**, 2b: era un `CircularProgressIndicator`,
l'unico punto della chat che sembrava un'app qualunque.

**COSA RESTA APERTO DELLE VOCI VECCHIE**: 1a dell'ORDINE CHAT 2, cioe' l'invito
"Vai piu' a fondo" col tetto a 420 token, e 2b dello stesso ordine, il ripiego
che diventa una lettura vera. Non sono state toccate qui.

## ORDINE CHAT 2 DI N: cosa e' chiuso e cosa NON e' stato aperto

Chiuso il 2 agosto 2026. **Tre voci su nove piu' i quattro difetti di vista.**

**CHIUSE:**

- **I quattro difetti di vista**, non tre. Il quarto e' che anche il CONSULTA
  montava lo scope senza dichiarare il Maestro. Le bolle sono opache (le tinte
  si fondono in anticipo sul fondo, a occhio identiche), la lista e'
  rovesciata, il Riprova vive DENTRO la bolla che ha fallito, e le due
  superfici di un Maestro dichiarano il loro Maestro.
- **1c, le aperture vietate.** Sedici formule in `VoceDelMaestro.apertureVietate`,
  non sette: aggiunte `Ti capisco`, `È del tutto normale`, `Come molti`,
  `Non sei sola`, `Immagino che`, `Sappi che`, `Voglio dirti che`,
  `Prima di tutto`, `Innanzitutto`. Il divieto si compone ENUMERANDO l'elenco
  dentro la persona, non riassumendolo.
- **1e, le chiusure.** `TipoDiChiusura` e' un enum obbligatorio nel costruttore:
  un Maestro nuovo non puo' nascere senza dichiarare la propria impronta.
- **1f, l'attribuzione cieca.** `tool/attribuzione_cieca.dart`, fuori dalla
  suite perche' costa chiamate vere. **Eseguito: 59 su 60, cioe' 98,3 per
  cento**, contro una soglia di 85 e un caso cieco di 33,3. L'unica confusione
  e' una risposta di Caligo attribuita ad Aura.

**NON APERTE, e non aperte a meta':**

- **1a**, l'invito "Vai piu' a fondo" col tetto a 420 token. **Attenzione, una
  premessa dell'ordine era falsa**: il selettore di profondita' PRIMA della
  risposta non esiste ne' in chat ne' nel Consulta. `AnswerDepthSelector` si usa
  in un punto solo, `oroscopo_screen.dart:752`, e il Consulta e' fisso su
  `ConsultDepth.breve`. Quindi 1a non e' "togli il selettore": e' solo
  costruire l'invito, che e' meta' del lavoro che l'ordine presumeva.
- **1b**, l'ancoraggio a un dato che esiste solo per questa persona. Richiede di
  portare `NatalContext` anche nella strada della CHAT: oggi arriva al provider
  solo per `consult`, mentre `MaestroPersona.systemInstruction` riceve profilo e
  memoria e non i dati natali.
- **2a**, il Maestro che consulta il cielo durante l'attesa. E' la voce che vale
  di piu' ed e' anche quella che riempirebbe il vuoto rimasto SOPRA la
  conversazione dopo il rovesciamento della lista.
- **2b**, il ripiego che diventa una lettura vera.

**UN CONFLITTO DENTRO L'ORDINE, risolto e da confermare.** L'ordine chiedeva che
Caligo chiudesse consegnando "una runa o un ARCANO". L'arcano non puo' essere
suo: la Cartomanzia e' un'arte di Medora e `arcano` e' una delle sue cinque
parole di firma, e la prova del lessico lo ha denunciato subito. Caligo consegna
una runa oppure un sigillo. **Se l'arcano deve restare a Caligo, va tolto dal
lessico di Medora, ed e' una decisione di Mauro** perche' indebolisce la sua
impronta.

## Cosa e' cambiato nel codice il 2 agosto 2026

- **L'errore non si perde piu'.** `VoceSorvegliata` avvolge il provider e
  registra ogni guasto con tipo, messaggio e operazione. `AppServices` e'
  diventata una fabbrica: **non esiste un modo di montare i servizi con una
  voce non sorvegliata**, nemmeno per sbaglio.
- **Ogni ripiego dichiara di essere un ripiego**, in `RipiegoDelMaestro`, con
  una frase diversa per ciascun Maestro. Vale nella chat e nel Consulta, che
  prima sostituiva la voce con l'oracolo deterministico SENZA DIRLO.
- **I catch muti sono enumerati su tutto `lib`** da
  `test/nessun_catch_muto_test.dart`. Debito misurato: **85 in 37 file**. I 9
  sulla strada della voce sono azzerati, gli altri possono solo scendere.
- **I tetti sono 160 e 320**, ed erano 260 e 780. Le porte al tetto erano TRE,
  non una: il Consulta passava dalle costanti, la chat aveva un `800` scritto
  a mano e il distillato un `400`.
- **Le tre personalita' sono un dato**, `VoceDelMaestro`. Trovato e corretto un
  difetto vero: Caligo rivendicava gli **Archetipi**, che sono un'arte di Aura.

## La decisione ancora aperta sul ponte, non urgente

L'ordine precedente chiedeva una Cloud Function per tenere la chiave sul
server, ma nell'app una chiave non c'e': il provider usa Firebase AI con App
Check. La callable ha altri vantaggi veri, il controllo del costo e il rate
limiting lato server, e va decisa per quelli. **Non e' un prerequisito per far
parlare la chat**: la causa era un'altra ed e' misurata.

## La coda dell'AI, aperta per fine del margine

Ordine del 1 agosto 2026, cinque voci, NESSUNA aperta a meta'. Lo stato voce per
voce sta in ESITO_AI.md, e la cosa piu' utile che c'e' scritta e' questa: IL
PONTE CON GEMINI ESISTE GIA', con la regione, i modelli e i tetti dichiarati in
`firebase_maestro_ai_provider.dart`. La voce 1 non e' "collegare Gemini", e'
capire perche' la chat non risponde, e IL PRIMO POSTO DOVE GUARDARE sono i
quattro `catch (_)` di `maestro_chat_controller.dart`, che inghiottono l'errore
vero.

Una decisione per il fondatore sta scritta li': l'ordine chiede una Cloud
Function per tenere la chiave sul server, ma nell'app una chiave non c'e', il
provider usa Firebase AI con App Check. La callable ha altri vantaggi veri, il
controllo del costo e il rate limiting lato server, e va decisa per quelli.

## Il velo sui corpi sotto l'orizzonte, aperto

Dal 1 agosto 2026 un corpo che a quell'istante stava sotto l'orizzonte lo
DICHIARA nella sua scheda, con l'ora in cui sorge. Ma viene ancora disegnato a
piena luce come gli altri: manca il segno visivo, il corpo velato o spento sotto
una linea d'orizzonte. Chi non tocca la scheda non lo distingue.

E' una modifica al disegno della volta, non al testo, e vale per tutti e due i
cieli passando da `_SkyBody`. Vedi ESITO_ORIZZONTE.md.

## Le tre voci ancora aperte della coda del 1 agosto 2026

Nessuna aspetta una decisione del fondatore: sono aperte per fine del margine,
e vanno riprese in quest'ordine.

1. **La Stesa fuori schermo a 360.** Nella cattura, il tocco sul ventaglio
   avverte "the widget is actually off-screen". Il test passa perche' il timer
   non resta appeso, ma il difetto e' vero. Serve la prova del rosso alla
   larghezza reale, poi la correzione.
2. **Le carte laterali dei Maestri tagliate a 360.** A 390 le tre carte stanno
   dentro con la cornice chiusa, a 360 quelle ai lati escono. Da decidere e
   dichiarare: o si stringono, o diventano una sbirciatura VOLUTA, cioe' una
   porzione regolare e uguale ai due lati, mai un taglio che dipende dalla
   larghezza.
3. ~~Il residuo del fuso, 123,7 gradi.~~ **CHIUSO il 1 agosto 2026.** Il fuso
   veniva tolto DUE VOLTE: `buildSkyFor` sottraeva `timeZoneOffset` a mano
   ottenendo un DateTime ancora marcato locale, e `Celestial.julianDay`
   chiamava `toUtc()` togliendolo di nuovo. Era anche la causa della scheda
   della Bilancia che dava dodici gradi a sud-est. Vedi ESITO_ISTANTE.md.

## Gli accenti a schermo NON sono piu' aperti

Chiusi il 1 agosto 2026. Erano 151 stringhe in 16 file, non dieci in sette: la
misura di allora cercava `fara'` mentre nel sorgente c'e' `fara'`, con la barra
dell'escape in mezzo. La regola ora vive in `testo_a_video_test.dart` e vale
anche per le frasi che nasceranno domani.

## L'intro e' PROVVISORIA

Sta in `lib/features/intro/sequenza_intro.dart` e va sostituita quando
arriveranno gli asset definitivi: il video e' un `Intro-Test`. Le prove
`intro_test.dart` valgono finche' c'e'.

Il logo esportato e' 720 pixel da un sorgente di 410: a schermo copre bene fino
a circa 240 punti logici, e piu' grande si vedrebbe la sgranatura del sorgente.
Se serve piu' grande, serve un sorgente piu' grande.

## La coda aperta, nell'ordine del fondatore

Chiuse le prime tre. Restano, e vengono prima di tutto:

4. **L'icona del Cerchio**: mezzaluna dentro un cerchio, stile lineare dorato
   come le altre quattro, deve reggere anche nello stato attivo.
5. **Gli accenti resi con l'apostrofo**: dieci punti in sette file, gia'
   trovati. Correggere solo le stringhe MOSTRATE, mai i commenti ne' le chiavi,
   con un test che enumera.
6. **La Stesa fuori schermo a 360**: il tocco sul ventaglio avverte
   "the widget is actually off-screen".
7. **Le carte laterali dei Maestri tagliate a 360**: decidere fra stringerle o
   farne una sbirciatura regolare, mai un taglio che dipende dalla larghezza.
8. **Il residuo del fuso, 123,7 gradi**: lo stesso istante in UTC e in ora
   civile da' due cieli diversi, quindi oltre alla conversione c'e' altro che
   guarda l'ora locale grezza.

## La coda aperta, nell'ordine del fondatore

1. **Il segno che viaggia come parametro.** `artRouteFor` riceve `userSign` da
   chi apre l'arte e lo passa a quattro arti; l'Oroscopo lo pretende nel
   costruttore e non guarda mai la data di nascita. Nona occorrenza della
   famiglia. **Trappola**: la data d'esempio e' Gemelli, quindi ogni prova
   scritta con l'identita' d'esempio e' verde col difetto dentro. Usare il
   Cancro.
2. **Le costellazioni piu' grandi nel cielo.** Erano state ridotte a 104 punti e
   la Luna a 78 quando la mappatura era geometrica. Con gli slot fissi lo spazio
   c'e': si puo' risalire verso 130, fermandosi al massimo che tiene verdi le
   dodici prove, e portare lo slot centrale da 0,66 verso 0,76.

## Cielo: gli slot fissi, decisione del 31 luglio

I corpi stanno in quattro slot dichiarati e non piu' nella loro posizione
geometrica. La mappatura su schermo, la distensione e la separazione sono state
RIMOSSE, non spente. Cio' che resta esatto e' il dato: la scheda porta altezza e
direzione vere.

Se qualcuno tornasse a volere la posizione visivamente esatta, sappia che il
conto fisico che la impediva era questo: le scatole dei corpi non stanno nel
campo libero se restano grandi. Adesso sono piu' piccole, 78 punti la Luna e 104
le costellazioni.

## Cielo, prima voce: LE ETICHETTE SI ACCAVALLANO

Visibile in `docs/preview/prima_dopo/cielo_nascita_dopo.png`: i corpi non
finiscono piu' sotto la scheda ne sotto il pulsante, ma **le etichette si
sovrappongono fra loro**. Si leggono "CANCRO", "GEMELLI" e "TORO" stampate una
sopra l'altra, illeggibili, e la Luna copre il Toro.

Comprimendo il campo libero i corpi si sono avvicinati, e nessuno impedisce a
due corpi di occupare lo stesso punto. Serve una spaziatura minima fra i corpi,
o un modo di scostarli quando collidono.

## Cielo: la prova sulla mappatura non e' stata vista cadere

La correzione del ripiego e' giusta e motivata, ma alle 22:30 la Luna resta
dentro il campo orizzontale, quindi il ripiego non scatta e la prova non
discrimina. Serve un istante in cui un corpo basso esce di lato.

## Il cielo intero: resta uno sforamento, col numero

Il campo libero e' calcolato e i corpi ci stanno dentro alla misura reale alle
22. **Alle ore 4 la Luna selezionata arriva a 609 punti mentre la scheda
comincia a 566**, uno sforamento di 43; a 2532 di altezza sono 75. Il conto del
campo torna a 439, quindi fra il calcolo e il pixel c'e' una traslazione di
circa 202 punti che non ho trovato. La prova gira sui casi verificati e NON e'
stata allentata: la voce resta aperta.

## CAPITOLO GOOGLE, prima voce: riaccendere App Check

`enforceAppCheck` sulla callable `natalChart` e' stato messo a **false il 31
luglio 2026**, perche' il fornitore registrato e' Play Integrity e l'app arriva
da App Distribution, quindi installata fuori dal Play Store: Play Integrity non
puo' attestarla e respingeva ogni chiamata prima del corpo della funzione.

**Va riacceso appena l'app sara' su una traccia di test interno del Play Store**,
perche' da li' Play Integrity la riconosce e l'imposizione torna a costare
nulla. Finche' resta spento, chiunque conosca l'indirizzo puo' far chiamare una
funzione che consuma un servizio a pagamento: il validatore rifiuta i corpi
malformati e non annulla il rischio.

## La coda dell'ordine sui dati di nascita

Chiuse: la 1 per la parte del luogo, e la 2. **Restano:**

- **1c**, il messaggio vero della carta natale: nasce sul dispositivo, e il
  campo `causa` del controller lo porta. Prima cosa da guardare sulla build.
- **3** la bolla che copre la Luna: e' un `Positioned` fisso in fondo che cresce
  verso l'alto col testo, senza calcolo dello spazio libero.
- **4a** "La posizione esatta di ogni astro arriva col motore a effemeridi",
  falsa da quando i corpi si posizionano da altezza e azimut reali.
- **4b** l'etichetta fantasma del corpo sotto la scheda.
- **5** le miniature di animale e angelo tagliate nel Passport.

## Il residuo del fuso orario nel cielo, con il numero

La conversione da ora civile a UT in `sky.dart` adesso usa il fuso vero
dell'istante, ed era il tempo medio locale. **Resta un residuo**: lo stesso
istante scritto in UTC e in ora civile produce due cieli che differiscono di
**123,7 gradi di azimut**. Oltre alla conversione c'e' dell'altro che guarda
l'ora locale grezza, e non l'ho inseguito. E' il primo punto da cui ripartire
sul cielo.

## Il cielo posizionato ha bisogno di `luogoIniziale`

`SkyOverviewScreen` accetta ora un `luogoIniziale`. Serve perche' senza di lui
il luogo entra in un modo solo, il dialogo di consenso, che richiede un tocco:
nessuna prova poteva misurare il cielo posizionato, ed e' il motivo per cui il
difetto e' vissuto indisturbato mentre la sorveglianza restava verde.

## LA CODA DI MAURO, da riprendere in questo ordine

Chiuse: 1, 2, 3b, 7. **Restano, e vanno prima di qualunque voce trovata da me:**

- **3a** la carta natale che ripiega. Prima cosa da guardare sulla build nuova:
  se il ripiego resta, il luogo c'e' e la causa e' un'altra, e il campo `causa`
  del controller la porta. Se sparisce, era il luogo che non arrivava.
- **4** le miniature di animale e angelo tagliate nel Passport. E' V3: il
  componente condiviso che non taglia, portato in ogni punto, con i punti
  enumerati da una prova.
- **5** il cielo di nascita: catalogo incompleto (mancano Ariete, Cancro,
  Bilancia, Capricorno, Acquario, Pesci), messaggio che mente anche quando la
  costellazione c'e' (soglie a meno due contro meno cinque), e "adesso" in una
  schermata che descrive la nascita.
- **6** il GPS che dice riposizionato e non cambia niente. Prova a schermo con
  due posizioni molto diverse.
- **8** il segno che viaggia come parametro: `artRouteFor` lo passa a quattro
  arti e l'Oroscopo lo pretende nel costruttore. Nona occorrenza della famiglia.
  Trappola: la data d'esempio e' Gemelli, usare il Cancro.

## Sul Santuario, un limite noto

La carta del Maestro occupa il 40 per cento dell'altezza, era il 37. Non sale
oltre perche' il carosello non regge sugli schermi bassi: i tre busti escono
dalla scena. Per andare oltre serve rivedere come il carosello li dispone.

Chi apre questo file deve poter continuare senza che Mauro racconti niente.

**Aggiornato**: dopo l'ORDINE 2 DI 5, le due voci chiuse e il debito saldato.
**Ramo**: `claude/esoteric-circle-master-order-e798aj`.
**Cartella di lavoro**: `C:\Users\user\Desktop\esoteric-circle-app` (NON il
worktree in `.claude/worktrees`, che e' vecchio).

## In attesa di una credenziale, non e' un difetto

`.github/workflows/ronda.yml` esiste sul disco e **non va committato**: il token
non ha lo scope `workflow` e GitHub rifiuta il push. Serve un token con quello
scope, che solo Mauro puo' fornire. Nel frattempo la Ronda gira dentro la suite
a ogni giro, che e' la protezione che conta.

## Chiuso negli ordini precedenti, da non rifare

A1 A2 A3 A4, B1 B2 B3 B4, C3 C4, F3 F4, la diagnosi dei motori e la Ronda con
38 test. Nessun motore scollegato oltre al cielo, gia' corretto.

## Chiuso nell'ORDINE 2 DI 5

- [x] **Debito dell'ordine 1 SALDATO.** La prova di vista sulla causa A adesso
      passa. Era la seconda ipotesi: la prova chiudeva una schermata MUTA,
      perche' il tono parte solo al tocco e la prova non toccava. Il lettore
      finto adesso registra anche CHI ha chiamato stop.
- [x] **Voce 1a CHIUSA.** Il segno discende da `BirthIdentity.sunSign`, nullo
      finche' i dati sono d'esempio. Due prove, una sul dato e una che MONTA la
      home. Attenzione alla trappola: la data d'esempio e' del 15 giugno, cioe'
      Gemelli, quindi le prove usano il Cancro.
- [x] **Voce 1b CHIUSA.** La Carta natale si garantisce il dato all'apertura,
      mostra la nota del ripiego con un pulsante Riprova, e si conserva fra un
      avvio e l'altro sotto una chiave che dipende dai dati di nascita.
- [x] **Voce 1c CHIUSA.** La Ronda ha un terzo strato, a schermo. **Ventidue
      motori restano sorvegliati solo sulla funzione pura**, elencati in
      `ESITO_2.md`: quando si correggono, il numero dentro la Ronda va aggiornato.
- [x] **Voce 2 CHIUSA.** `BarraArte` unica, cosmo che riempie l'altezza,
      `InterruttoreDelCerchio` nel design system. Due difetti trovati dalle prove
      e non segnalati: una QUARTA schermata col cuore sopra la "i", l'Animale
      Guida, e un SECONDO interruttore fuori palette in entrambe le schermate.

## Sul peso dell'archivio, misurato e non attribuito

I trentadue megabyte di crescita fra 2109 e 2110 **non esistono**: ricostruita la
2109 dal suo commit pesa 235.891.257 byte contro i 236.001.856 della 2110, cioe'
0,11 MB di differenza. Il numero 203,93 MB non e' quello dell'APK che quel commit
produce. Il conto per famiglia sta in `ESITO_2.md`.

## Chiuso nell'ORDINE 1 DI 5

- [x] **Voce 1 CHIUSA.** La striscia dei Doni non sborda piu', e i difetti erano
      due: il titolo che andava a capo rubando dieci punti a una fascia di
      altezza fissa, e una riga di etichetta piu' cerchio che sbordava di lato.
      La sbirciatura del quarto Dono adesso e' un DATO, `DailyStrip.sbirciaturaMinima`,
      e la larghezza della casella si ricava da quel dato invece che avanzare.
- [x] **Voce 2 CHIUSA, con un limite dichiarato.** Le tre cause del suono che non
      si ferma sono corrette: il `dispose` della Meditazione ferma il lettore, la
      `GuardiaDelSuono` in `core/sensi/` governa il ciclo di vita da un punto solo
      per tutta l'app, e il motore audio e' davvero uno solo con costruttore
      privato. **Il limite**: la prova di vista sulla causa A non passa, togliendo
      lo `stop()` dal dispose il test resta verde. Le cause B e C sono provate,
      la A e' corretta nel codice ma non protetta. **Va ripresa.**
- [x] **La suite e' VERDE**, 1138 prove, zero errori di analisi. Le sei rosse
      erano sei cause distinte, nessuna delle quali "il test era vecchio":
      una violazione della regola sulla virgola che avevo scritto io, un archivio
      preferenze non finto, il manifesto degli asset senza `assets/audio/`, un
      secondo catalogo sonoro rimosso in S3 di cui restava l'asserzione, un
      bersaglio del cielo il cui centro cade sulle carte, e un timer ancora vivo
      a fine cattura della Stesa.

## Ancora aperto sulla Stesa a 360

Il tocco su `stesa_fan_38` nella cattura avverte *the widget is actually
off-screen*: il ventaglio a 360 punti esce dallo schermo. Il test adesso passa
perche' il timer non resta appeso, ma **l'avviso resta e il difetto e' vero**.
Non era una voce di questo ordine e non l'ho toccato.

## L'ordine in corso

- [~] **V1** la bolla e l'avatar. **La misura adesso FUNZIONA ed e' rossa.**
      Resta da correggere il layout perche' regga il testo di sistema
      ingrandito. Vedi la sezione dedicata qui sotto, e' la cosa piu' importante
      di questo file.
- [ ] **V2** la mano, quarta stesura, BIANCA. Da verificare per primo: nel
      painter c'e' `Colors.white` e a schermo esce oro, quindi la mano che si
      vede potrebbe non essere quella corretta. Riferimento di Mauro: mano vista
      da SOPRA, indice teso che scende su un cerchio, tratto pulito e sottile,
      dita chiuse leggibili una per una, pollice accennato di lato. La
      silhouette del soffio e' fatta bene e NON si tocca.
- [ ] **V3** il componente condiviso che non taglia le immagini, portato in ogni
      punto che mostra miniature di animale, angelo o carta. Per l'angelo la
      miniatura diventa rettangolare verticale, proporzione da carta. Un test
      conta i punti che lo usano e denuncia chi adatta al riempimento fuori da
      esso.
- [ ] **V4** ScrollReveal: sfasare gli elementi, allungare oltre 420 ms,
      abbassare l'opacita' iniziale. **NON alzare l'ampiezza**: gia' provato, a
      22 px gli elementi si sovrappongono e il tocco colpisce la voce sbagliata.
      Il limite attuale e' fissato da un test in `scroll_reveal_si_vede_test`.
- [x] **S1 CHIUSA.** `audioplayers` e' l'unica dipendenza di riproduzione,
      `MotoreAudio` in `core/sensi/` e' l'unico motore, `LettoreToniReale`
      sostituisce il muto come DEFAULT nelle due schermate che suonano. Il
      difetto vero non era l'assenza del lettore, era che il default fosse muto:
      i test iniettavano il lettore e passavano.
- [x] **S2 CHIUSA.** Quattro schemi in `core/sensi/palette_sensoriale.dart`,
      diciassette chiamate ricondotte, zero chiamate dirette fuori dalla
      palette. Il rifiuto usa il tocco due volte e non ha uno schema suo.
- [x] **S3 CHIUSA come struttura.** Catalogo dei cinque suoni come dato, slot
      pronti in `assets/audio/` col LEGGIMI, ripiego silenzioso. Trovato e
      rimosso un SECONDO catalogo sonoro nei Tarocchi, `audio/stesa_*.mp3`.
      Mancano solo i file, che sceglie Mauro.
- [ ] **S4 DA FARE**, versione semplice dichiarata: UNA transizione con
      elemento condiviso, la carta del Maestro nel Cerchio che si apre e diventa
      il suo dominio. Si fa con un `Hero` sulla carta centrale del carosello e
      uno stesso tag nella schermata del dominio. Deve rispettare Riduci
      Movimento, che riporta alla dissolvenza semplice.
      **Le altre due restano dichiarate come da fare**, e non vanno tentate in
      questo giro: la carta dell'angelo verso la sua schermata, e il Sigillo che
      si espande entrando nel Passport.
- [x] **S5 CHIUSA.** `suonoEVibrazione` e' il quarto comando di
      `SettingsController`, governa i due canali insieme, e la voce e' nelle
      Impostazioni. Chiude P23.

## L'ordine delle anteprime: X1 e X4 CHIUSE, X2 e X3 DA FARE

**X1 chiusa.** Le tre cause erano diverse fra loro: una seconda porta
(`mano_anteprima_test.dart`, ora dentro il corredo e cancellata), anteprime
orfane nate da prove temporanee (`le-tue-arti.png`, ora nel corredo), e due
catture rotte da S1, perche' il lettore audio reale tentava di riprodurre in
prova. La regola sta in `test/corredo_anteprime_test.dart`, col dato e non col
controllo. Prova di vista passata.

**X4 chiusa senza toccare codice.** Guardata l'anteprima nuova: le icone si
disegnano tutte. I quadratini erano l'anteprima vecchia, prodotta da un test
temporaneo che non caricava i font. Il difetto non esisteva.

**X2 DA FARE**: le carte laterali tagliate dai bordi a 360. Va prima deciso e
dichiarato se stringerle o farne una sbirciatura regolare, poi la prova del
rosso a tutte e tre le misure.

**X3 DA FARE**, e va insieme a V1: e' lo stesso file, `daily_strip.dart`. A 360
il quarto dono sparisce e non c'e' piu' invito a scorrere. La quantita' minima
visibile deve essere un dato dichiarato.

**Una cattura resta rossa e va guardata**: "Cattura la Stesa in corso" cade a
360 con "the widget is actually off-screen". E' un difetto vero della Stesa alla
larghezza reale, non un problema del corredo.

## W1 e W2: la larghezza, che era la causa

**CHIUSA W1.** Il telefono vero e' 1080 per 2392 fisici, cioe' **360 per 797
punti logici** con rapporto di pixel 3. Le anteprime erano generate a **390**:
trenta punti logici in piu'. La costante si chiamava "quella di Mauro", il
commento dichiarava 1080 per 2392, e il valore era `Size(390, 797)`: avevo
cambiato l'altezza in un giro precedente e lasciato la larghezza.

Adesso 360 e' la prima delle tre misure del corredo. Trentasette catture
portate alla misura reale, cinquantanove anteprime rigenerate.

**L'ipotesi della scala 1,6 e' ARCHIVIATA come sbagliata**, e va aggiunta alle
strade escluse: le impostazioni sono Predefinito e Standard, di fabbrica.

**W2, la scoperta che chiude cinque segnalazioni.** Alla larghezza reale il
difetto SI RIPRODUCE, senza toccare la scala del testo: a 1080 tutte e tre le
misure sono rosse, a 1170 sono verdi. Le segnalazioni non erano
irriproducibili, ero io a verificare su uno schermo piu' largo del suo.

**IL DIFETTO E' PREESISTENTE, non introdotto da me.** Verificato riportando
`santuario_screen.dart` allo stato committato: restano quarantaquattro errori
di overflow e nove prove rosse. Il test nuovo li rende visibili per la prima
volta.

**Che overflow e'.** `A RenderFlex overflowed by 10.0 pixels on the bottom`, e
il colpevole e' la Column in `daily_strip.dart:671`, cioe' la striscia dei Doni:
a 360 punti la sua etichetta va su due righe e la colonna sborda.

**Due strade gia' provate e RIENTRATE**, da non ripetere:

1. `mainAxisSize: MainAxisSize.min` su quella Column: peggiora, si passa da tre
   prove rosse a nove e gli overflow restano quarantaquattro.
2. Calcolare `centralH` e `carouselHeight` per differenza dallo spazio libero:
   non risolve, perche' l'overflow non viene dal carosello.

**La strada da provare.** L'overflow e' nella striscia dei Doni, non nell'eroe:
va guardata `daily_strip.dart` attorno alla riga 671, dove l'altezza della
striscia e' fissa mentre l'etichetta a 360 punti occupa due righe. O si riduce
il testo, o si alza la striscia, o l'etichetta va su una riga sola con
`FittedBox`.

## Cose sapute sul livello sensoriale

- I lettori audio vanno costruiti PIGRI: crearli tocca la piattaforma, e in una
  prova senza plugin il solo fatto di creare il motore solleverebbe.
- Gli schemi aptici con pause vanno eseguiti in `tester.runAsync`: un
  `Future.delayed` non avanza nel tempo finto e il test resta appeso.
- Il plugin audio non esiste in prova: un test che tenta di riprodurre davvero
  fallisce per un'eccezione asincrona anche se il motore la cattura. Le regole
  del suono si verificano sul codice, dichiarandolo.

## Cose sapute che fanno perdere tempo se si riscoprono

- La specifica del Livello Sensoriale sta nel Project di Claude e NON e' nel
  filesystem: si lavora sul perimetro dell'ordine.
- Nei test che montano `EsotericCircleApp`, oltre il mezzo secondo di pump il
  lanciatore spinge l'onboarding sopra la scena e non si misura piu' il Cerchio.
  Mezzo secondo e' il tempo giusto.
- `RenderView` non ha `toImage`: per fotografare serve avvolgere in un
  `RepaintBoundary` con una GlobalKey.
- I file sorgente sono a fine riga CRLF: le sostituzioni con Python vanno fatte
  normalizzando prima e ripristinando dopo.
- Gli apici dentro le stringhe Dart si rompono se scritti da un heredoc bash.
  Meglio lo strumento di scrittura file.
- `DepthCard` richiede `QualityTierController` nell'albero: i test che montano
  tessere devono fornirlo.
