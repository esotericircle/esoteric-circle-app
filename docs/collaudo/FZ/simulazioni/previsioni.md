# PREVISIONI PRIMA DELLA SIMULAZIONE, ordine FZ voce FZ.09

Scritte prima di toccare il Realme, come la regola pretende. Ogni persona
porta le decisioni previste, comprese quelle sbagliate: la simulazione le
prova tutte e segna cosa e' successo davvero.

Device: Realme 767f596c. App fatta girare con `flutter run -d 767f596c`
(debug, mai una build distribuita: l'ordine dice "Nessuna build"). Dati di
produzione mai toccati: l'app sul telefono di collaudo e' la sua, non un
account vero.

## a) Chi segue sempre la stessa ombra e la riconosce alla quarta discesa

Previsto:
1. Alla soglia, sceglie "scritta" o "libera" e scende.
2. All'incontro vede tre ombre; tocca sempre la PRIMA proposta (posizione,
   non nome: le ombre non hanno nome finche' non sono riconosciute).
3. Alla lente gratta il pezzo 0 (il piu' basso) della carta di quell'ombra.
4. Risale, legge il responso, torna alla soglia per un'altra discesa (stesso
   giorno o il giorno dopo, a scelta della prova).
5. Ripete scegliendo la stessa posizione tre volte in piu' (discese 2, 3, 4).
   **Previsione sbagliata da provare apposta**: le tre ombre proposte alla
   discesa 2 potrebbero NON essere nello stesso ordine della discesa 1 (sono
   scelte dalla porta `treOmbreProposte`, non fissate): la persona deve
   riconoscere l'ombra per NOME una volta che ne ha gia' seguita una, non per
   posizione. Si prova a toccare per nome dalla discesa 2 in poi.
6. Alla quarta volta che segue la STESSA ombra, alla lente gratta il pezzo 3
   (il volto): previsto che qui scatti il riconoscimento, compaia il nome,
   la card della rivelazione e il pulsante "Di' chi sei".
7. **Verifica incrociata**: il Diario (icona libro) mostra quattro discese,
   tutte sulla stessa ombra/animale.

## b) Chi cambia ombra ogni volta e si trova con quattro carte a meta'

Previsto:
1. Discesa 1: segue l'ombra A (una delle tre proposte). Alla lente gratta
   il pezzo 0 della carta di A.
2. Discesa 2: le tre ombre proposte includono ora A (ordine FZ.01: "le ombre
   gia' seguite tornano sempre") e due nuove; la persona scientemente ne
   segue una diversa, B. Alla lente: pezzo 0 della carta di B (non il
   pezzo 1 di A: B non e' mai stata seguita).
3. Discesa 3: segue C (nuova), stesso esito: pezzo 0 di C.
4. Discesa 4: a questo punto A, B, C hanno 1 apparizione ciascuna, nessuna
   a 4: previsto che la quarta discesa NON riconosca nessun animale (nessuna
   ombra ha raggiunto quattro). Si segue di nuovo A: previsto pezzo 1 di A
   (la seconda volta di A, non la quarta discesa assoluta).
5. **Verifica nel Diario dei Viaggi**: le carte di A, B, C scoperte a meta'
   si vedono tutte insieme, ciascuna col suo numero di pezzi (ordine FZ.04:
   "una accanto all'altra"). Previsto: A a 2 pezzi, B e C a 1 pezzo.
6. **Previsione del rischio piu' concreto**: la carta `_laLente` usa
   `scelteInOrdine.where((s) => s == nome).length`, quindi il pezzo deve
   corrispondere SEMPRE all'ombra che si sta seguendo quella discesa, mai a
   quella piu' seguita in assoluto. Si controlla a vista (non solo nel
   codice) che la carta giusta si apra ogni volta.

## c) Chi aveva gia' concluso il viaggio col vecchio sistema e riapre l'app

Previsto (serve un Diario preparato a mano con la vecchia chiave
`viaggio.riconosciuto=true` e nessuna chiave nuova, o scrivendola con adb
dentro `shared_preferences` del telefono di collaudo, mai su un account
vero):
1. All'apertura, nessuna domanda, nessun avviso bloccante: l'animale del
   segno di nascita e' gia' fissato, senza una `SnackBar` di migrazione
   (la migrazione FZ.02 dice "nessun avviso" per chi aveva concluso).
2. Il Passaporto, Il Ritratto e il Bosco del Cerchio mostrano lo stesso
   animale, mai due diversi.
3. Il Viaggio permette di chiedere un segno all'animale (FZ.01: "non c'e'
   un massimo", si continua a scendere per consultare).

## d) Chi era a meta' e riparte

Previsto (Diario preparato con 2 discese vecchio-stile sulla stessa ombra,
nessuna chiave di migrazione):
1. All'apertura del Viaggio compare una `SnackBar` una tantum: *"Il
   riconoscimento del tuo animale guida segue ora la regola delle ombre: il
   tuo cammino riparte da qui."*
2. Le due vecchie discese NON contano piu' per il riconoscimento: la persona
   deve seguire la stessa ombra altre quattro volte, non altre due.
3. Il Diario mostra ancora le due vecchie discese come storia (scena,
   domanda, risposta), ma la carta di quell'animale e' scoperta a zero
   pezzi, non a due.

## e) Chi fa una domanda all'animale e riceve si', guarda meglio e no

Previsto (serve un animale gia' riconosciuto, o si arriva al riconoscimento
dentro la stessa simulazione):
1. Si apre "Chiedi un segno", si scrive una domanda, si tocca "Chiedi".
2. Senza un video scaricato (prima esecuzione sul telefono di collaudo, se
   la rete non ha ancora portato il pezzo "centro"): la carta resta sulla
   posa, la riga arriva comunque (la correzione di oggi: niente attesa
   infinita). **Previsione sbagliata da provare apposta**: se il download
   e' gia' avvenuto (il telefono ha rete), ci si aspetta che il video del
   gesto giusto (arrivo+centro per si', centro per guarda meglio, uscita per
   no) parta davvero, non un vecchio zoom dell'illustrazione.
3. Si ripete la domanda tre volte di seguito per vedere tutti e tre i gesti
   (il modello o la riserva decidono, non la persona): si confronta il gesto
   mostrato con la riga di testo, devono dire la stessa cosa.
4. **Spesa**: se il tetto tecnico lo permette, la domanda puo' chiamare il
   modello vero (Gemini). Questo e' un costo a consumo: la simulazione resta
   sulla via di riserva (nessuna chiamata reale senza il si' di Mauro, vedi
   regola SPESE), verificando solo che la riserva risponda sempre e nel
   repertorio chiuso.

## f) Chi apre il Viaggio senza rete e con Riduci Movimento acceso

Previsto:
1. Riduci Movimento acceso nelle impostazioni di sistema del telefono di
   collaudo, e la rete dati/WiFi spenta.
2. Alla lente, scena della soglia, incontro, segno: nessun video parte da
   nessuna parte; ogni carta e ogni gesto restano sulla loro posa (immagine
   ferma, sempre nel pacchetto).
3. Nessun riquadro vuoto, nessun errore a schermo, nessun crash: la
   funzione resta completamente usabile (si puo' grattare la carta, seguire
   un'ombra, chiedere un segno) solo senza animazione video.
4. Riaccesa la rete e aperta di nuovo la stessa schermata, il download del
   video parte da solo (senza bisogno di un comando esplicito).

## g) Chi condivide la rivelazione come video

Previsto (serve un animale appena rivelato E il suo pezzo "centro" gia'
scaricato: su rete lenta o appena riconosciuto potrebbe non esserlo ancora,
nel qual caso il pulsante "Condividi come video" non deve nemmeno
comparire, solo "Di' chi sei"):
1. Col pezzo scaricato, compare il secondo pulsante "Condividi come video"
   sotto "Di' chi sei".
2. Toccandolo, FFmpeg scrive il titolo e la data sopra il pezzo "centro" e
   apre il foglio di condivisione di sistema con un video pronto, non
   un'attesa senza fine o un crash.
3. **Previsione a rischio concreto, la piu' probabile da trovare rossa**:
   e' la prima volta che FFmpeg gira su un telefono vero per questo ordine
   (le prove automatiche usano un esecutore finto). Possibile che il plugin
   nativo non si registri, o che il font estratto non si legga, o che il
   comando fallisca per una ragione che nessuna prova in locale poteva
   vedere. Si guarda il log del telefono (`adb logcat`) per capire cosa e'
   successo davvero.
4. Annullando la condivisione dal foglio di sistema (senza scegliere
   un'app), l'app deve restare come prima, senza crash e senza un secondo
   file lasciato a meta'.
