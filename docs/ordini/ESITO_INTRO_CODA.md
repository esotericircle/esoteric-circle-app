# ESITO: L'INTRO, POI LE CINQUE VOCI RIMASTE

## 1. L'INTRO DAVANTI A TUTTO, **chiusa**

Consegnata alla **2123** e riparata alla **2124**. Il dettaglio completo sta in
[ESITO_INTRO.md](ESITO_INTRO.md): la sequenza, la scelta del logo completo, la
firma che cede il posto alla voce, il peso, e le porte.

**La riparazione conta piu' della prima consegna.** Sulla 2123 si sentiva la
voce e si vedeva il Risveglio: l'intro era viva e SEPOLTA, perche' stava dentro
`home`, cioe' dentro la route iniziale, e il Risveglio non e' un ramo
dell'albero, e' un `push`. Una route spinta sopra copre chi sta sotto, audio
compreso. Ora sta nel `builder` del MaterialApp, che avvolge il Navigator
intero.

**Le prove che c'erano non potevano prenderlo**: montavano la sola
`SequenzaIntro`, dove un Navigator non c'e'. La prova nuova monta l'app intera,
ed e' rossa col codice di prima e verde con questo. L'ho verificata in tutti e
due i sensi.

## 2. L'ICONA DEL CERCHIO, **chiusa**

La mezzaluna dentro il cerchio, chiesta dal fondatore il 30 luglio.

**E' disegnata e non scelta**: fra le icone di Material una falce dentro un
anello non esiste, e sovrapporre `brightness_3` a `circle` darebbe due tratti di
peso diverso che a 21 punti si vedono. Il disegno sta in
`lib/design_system/components/icona_del_cerchio.dart`, con un tratto solo,
dichiarato una volta, nel riquadro di 24 delle icone lineari di Material.

**Il disco che genera la falce e' spostato a destra**, e non e' un capriccio: la
falce pesa tutta dalla parte della sua schiena, quindi un disco centrato dava
una falce appoggiata al bordo sinistro con un vuoto a destra. L'ho corretta due
volte guardando l'immagine.

Immagini: `icona_cerchio_prima.png`, `icona_cerchio_dopo.png`.
**Un limite dichiarato**: nella terza, `icona_cerchio_accanto.png`, le icone di
Material compaiono come quadrati vuoti, perche' in prova headless il loro font
non si disegna. Quell'immagine prova la MISURA, identica, non il peso del
tratto, che va guardato sull'app.

**Frase di accettazione**: *nella barra in basso, la voce "Il Cerchio" ha una
mezzaluna dentro un cerchio dorato, della stessa misura delle altre quattro.*

## 3. GLI ACCENTI RESI CON L'APOSTROFO, **chiusa**

**Erano 151 stringhe in 16 file, non dieci in sette.** La misura di allora aveva
trovato dieci punti perche' cercava `fara'` mentre nel sorgente c'e' `fara\'`,
con la barra dell'escape in mezzo, e perche' non guardava affatto le stringhe a
doppi apici. **Una ricerca che torna quasi a zero e' una ricerca da rifare, non
una buona notizia**: la prima volta che ho rimisurato con l'escape normalizzato
il conto e' passato da 0 a 115, e col resto delle desinenze a 151.

**Ho toccato solo le frasi mostrate.** Mai i commenti, dove l'apostrofo al posto
dell'accento e' la convenzione voluta di questo progetto, e mai le chiavi ne' i
percorsi, riconosciuti perche' non hanno spazi dentro. Le ELISIONI restano
intatte, ed e' la parte delicata: `l'anno`, `un'ora`, `po'`, `vent'anni`,
`qualcos'altro` hanno l'apostrofo giusto, e trasformarle sarebbe stato un errore
peggiore di quello che si correggeva.

**Due errori miei, trovati misurando e non indovinando**, e li scrivo perche'
sono la ragione per cui il lavoro e' andato bene la terza volta:
1. la prima passata sostituiva anche sull'apice di CHIUSURA della stringa, e
   "gradi" diventava una parola accentata. Ho visto 1145 sostituzioni invece di
   150 e mi sono fermato a guardarle invece di committare;
2. la seconda scriveva dentro le interpolazioni `${...}`, dove c'e' codice e non
   testo, e ha rotto `sunset_rune.dart`. Ora le interpolazioni si mettono da
   parte e si rimettono dopo.

Ho corretto anche i prompt di sistema dei Maestri, che non sono mostrati alla
persona: un prompt che scrive `Profondita'` insegna al modello a scrivere cosi',
e quello che il modello scrive lo legge la persona.

**LA REGOLA ORA VIVE IN UNA PROVA**, `testo_a_video_test.dart`, che enumera
tutte le stringhe di `lib` e cade se una frase mostrata usa l'apostrofo come
accento. Vale anche per le frasi che nasceranno domani. Al primo giro ha trovato
quattro elisioni che il mio elenco non conosceva, `vent'`, `trent'`,
`quarant'`, `qualcos'`: la prova ha corretto me, che e' il suo mestiere.

**Frase di accettazione**: *in Risonanza si legge "la lettura si fara' piu'
precisa" con gli accenti veri, e cosi' in tutte le altre schermate.*

## 4, 5, 6: **aperte**, e il motivo

La Stesa fuori schermo a 360, le carte laterali dei Maestri tagliate, e il
residuo del fuso a 123,7 gradi restano **aperte per fine del margine**, non per
una decisione che manchi. Nessuna delle tre ha bisogno del fondatore: sono
scritte in RIPRESA.md nell'ordine in cui vanno riprese.
