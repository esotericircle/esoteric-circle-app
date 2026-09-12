# ESITO 1: LA SUITE TORNA VERDE, E IL SUONO SI FERMA

## La stima, scritta prima di toccare il codice

### Voce 1, l'overflow della striscia

**Piena.** La diagnosi e' gia' fatta e non la rifaccio: `daily_strip.dart`
attorno alla riga 671, altezza fissa contro un'etichetta che a 360 punti occupa
due righe. Le due strade rientrate non le ripeto.

**La strada che scelgo, motivata in una riga**: l'etichetta sta su una riga
sola, perche' la striscia e' una fascia di icone e alzarla mangerebbe lo spazio
dell'eroe, che a 797 punti di altezza e' gia' stretto.

**Il rischio vero non e' l'overflow, e' la sbirciatura.** Le due cose vivono
nello stesso posto: la larghezza di ogni elemento decide sia se l'etichetta va a
capo sia quanti elementi entrano nello schermo. Stringere per far entrare
l'etichetta su una riga potrebbe far entrare anche il quarto dono per intero,
che sarebbe l'errore opposto. La quantita' visibile va fissata come dato, non
lasciata al caso.

### Voce 2, il suono che non si ferma

**Piena, e le tre cause sono davvero tre.** La piu' grave e' la B: in tutto
`lib/` non esiste un solo osservatore del ciclo di vita, quindi non e' che
l'audio si fermi male, e' che nessuno gli dice mai di fermarsi.

**Dove metto il governo**: nel guscio dell'app, in un punto solo, non nella
Meditazione. Le porte sono tutte le schermate che suonano, oggi due e domani
dieci.

**Sulla causa C dichiaro adesso quale delle due strade prendo**: rendo vera la
dichiarazione, cioe' un motore solo condiviso, invece di ammorbidire il commento.
Un commento che mente e' peggio di un difetto, perche' chi legge smette di
verificare.

**Nota che mi riguarda.** Tutte e tre nascono dalla stessa modifica, S1, quando
il lettore reale e' diventato il predefinito. La stessa modifica ha rotto in
silenzio due catture di anteprima. La lezione la scrivo qui perche' valga:
quando cambia un predefinito, si cerca chi altro passa da quella strada prima di
chiudere.

### Cosa non faccio

Non prendo altre voci. Se finisco in anticipo consegno e mi fermo.

## Stato voce per voce

### Voce 1, l'overflow della striscia: CHIUSA

**I difetti erano due, non uno.** Il primo e' quello segnalato: il titolo "I tuoi
doni del giorno" a 360 punti andava a capo e rubava dieci punti a una fascia di
altezza fissa. Corretto vincolandolo a una riga sola, la strada dichiarata prima
di scrivere. Il secondo l'ho trovato mentre le prove restavano rosse a 1170: la
riga con l'etichetta del Dono piu' il cerchio "?" sbordava di lato. Corretto
facendola rimpicciolire invece che sbordare.

**La sbirciatura del quarto Dono adesso e' un DATO**, `DailyStrip.sbirciaturaMinima`,
e la larghezza della casella si RICAVA da quel dato. Prima era il contrario: la
sbirciatura era quello che avanzava, e a 390 tornava per fortuna.

**Il numero non e' piu' sparso nel layout**: c'era una costante di larghezza nel
widget privato, adesso c'e' una funzione pubblica `larghezzaCasella` che chiunque
puo' interrogare, prove comprese.

**Prova di vista passata**: la prova sulla sbirciatura e' rossa sul codice vecchio.
Il primo tentativo di scriverla misurava il cerchio "?", che sta al centro della
casella e quindi risulta gia' fuori quando la casella sporge di poco: diceva zero
a entrambe le larghezze. La misura corretta si ricava dal layout.

### Voce 2, il suono che non si ferma: CHIUSA, con un limite dichiarato

**Causa A.** `MeditationScreen.dispose` adesso ferma il lettore.

**Causa B.** Esiste `GuardiaDelSuono` in `core/sensi/`, montata nel guscio
dell'app e non in una schermata. Ferma il suono su `paused` e anche su
`inactive`, perche' una telefonata in arrivo toglie il primo piano senza mettere
in pausa. Al ritorno **non riparte da sola**: chi rientra non ha chiesto di
risentire un tono di mezz'ora prima.

**Causa C.** Ho reso vera la dichiarazione invece di ammorbidire il commento, come
avevo dichiarato: costruttore privato, istanza `condiviso`, e una prova che
enumera i punti di costruzione in tutto `lib` e cade se diventano due.

**IL LIMITE.** La prova di vista sulla causa A non passa: togliendo lo `stop()`
dal `dispose` il test resta verde, e non ho saputo spiegare da dove venga la
fermata che osservo. Le cause B e C sono provate, la A e' corretta nel codice ma
**non protetta**. Sta in `RIPRESA.md` come voce da riprendere.

## La suite

**1138 prove verdi, zero errori di analisi.** Le sei rosse erano sei cause
distinte, e nessuna era "il test era vecchio":

1. Una violazione della regola sulla virgola in una frase che avevo scritto io.
2. `permesso_posizione_test` senza archivio preferenze finto.
3. Il manifesto degli asset senza `assets/audio/`, cartella nata con S1.
4. `stesa_sensi_test` che pretendeva ancora il secondo catalogo sonoro
   `audio/stesa_*`, rimosso in S3 quando i suoni del Cerchio sono diventati cinque.
5. Il bersaglio del cielo nel Santuario: e' una colonna alta e il suo centro cade
   nella zona delle carte, che stanno sopra nello Stack. La prova toccava il
   centro, l'utente tocca il titolo. E pretendeva il pre-avviso della posizione
   con i servizi OFFLINE, dove la sorgente e' spenta di proposito: quel dialogo
   ha tre prove sue con la sorgente accesa.
6. La cattura della Stesa finiva con un timer ancora vivo.

## Una cosa trovata che resta aperta

Il tocco sul ventaglio nella cattura della Stesa avverte *the widget is actually
off-screen*: a 360 punti il ventaglio esce dallo schermo. Il test adesso passa
perche' il timer non resta appeso, ma **l'avviso resta e il difetto e' vero**.
Non era una voce di questo ordine, e sta in `RIPRESA.md`.
