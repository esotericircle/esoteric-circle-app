# ESITO dell'ORDINE UNICO: I DATI, IL CERCHIO, L'ONBOARDING

## Dichiarazione, scritta prima di toccare il codice

Tredici voci. Ne ho gia' trovate tre leggendo, e le dichiaro adesso perche'
cambiano la stima.

**D3, la seconda porta e' in `onboarding_screen.dart:562`**: il sottotitolo
del passo dice ancora "accorderemo ogni frase al vocativo che preferisci". Ne
avevo corretta un'altra e non questa, che e' esattamente il difetto che
l'ordine mi contesta per la terza volta. Cerchero' tutte le porte e ne
dichiarero' il numero.

**B1, la causa e' in `MaestroController._setKey`**: `if (key == _activeKey)
return`. All'ingresso la chiave e' gia' quella giusta, quindi non parte
nessuna notifica e la scena resta com'era nata, cioe' neutra. E' la stessa
famiglia del nome minuscolo e del limite della chat: una regola applicata alla
transizione invece che allo stato.

**A2, il difetto e' `enabled: _timeKnown == true`**: con lo stato iniziale
nullo, ne' acceso ne' spento, quella condizione e' falsa, quindi i selettori
nascono disabilitati. La regressione l'ho introdotta io togliendo la
preselezione, e me ne assumo la responsabilita'.

**La stima, per gruppi.**

- **Parte 1 (A1, A2): piena, e per prima.** Tolgono dati alla persona, quindi
  hanno la precedenza su tutto. A1 ha gia' un `PopScope` che evidentemente non
  copre il gesto di sistema: devo capire perche', e questa e' la sola incognita
  vera della parte 1.
- **Parte 2 (B1, B2, B3, B4): B1, B2 e B3 piene.** B4 e' una funzione intera:
  scaffale precompilato dalla Risonanza, cuore dentro l'arte, cuore alla
  pressione lunga, matita con l'elenco a spunte, tetto, ripristino,
  persistenza. La dichiaro **piena, con una riserva sulla matita**: se il
  tempo stringe, la versione semplice e' lo scaffale precompilato piu' il
  cuore, senza l'elenco a spunte, e lo dico.
- **Parte 3 (C1, C2, C3, C4): piene.** C2 chiede di guardare a meta'
  animazione, che e' il posto giusto dove cercarlo.
- **Parte 4 (D1, D2, D3): D1 e D3 piene.**

**Su D2 devo essere chiaro subito.** L'ordine chiede di verificarlo "sull'app
in esecuzione e non solo con un test". Non ho un emulatore ne' un dispositivo:
posso rigenerare le anteprime e guardarle, che e' piu' di un test e meno di
un'app in mano. Quindi su D2 faro' la correzione e la verifica per immagine, e
**non dichiarero' chiuso cio' che non ho visto muoversi**: lo scrivero' come
verificato per immagine, non in esecuzione.

**Se il tempo finisce**, finiscono le ultime: prima la matita di B4, poi C4,
poi D2. Mai la parte 1.

## Stato voce per voce

### A1, il gesto che portava via i dati: CHIUSA

**Le porte erano due, non una.** La prima nell'onboarding: `canPop: _step ==
_Step.accoglienza` lasciava uscire dal primo passo. Sembrava innocuo, perche' al
primo passo non c'e' ancora niente da perdere, ma l'onboarding e' una rotta
spinta SOPRA lo shell: uscirne non chiude l'app, rivela la home che sta gia'
sotto. Bastava retrocedere fino al primo passo e insistere una volta.

La seconda porta era il **Risveglio**, che non aveva nessun `PopScope`. Il
Maestro si assegna alla rivelazione, cioe' all'ultima fase, quindi uscire prima
voleva dire entrare nel Cerchio senza Maestro, per di piu' senza che
l'onboarding tornasse a proporsi, dato che il lanciatore lo aveva gia'
considerato gestito. Questa porta l'ordine non la nominava: l'ho trovata
cercando la gemella.

Adesso, in tutti e due, il gesto retrocede di un passo come la freccia e dal
primo non fa nulla. L'unica uscita dal Risveglio e' la rivelazione, che usa
`pop` diretto proprio perche' `maybePop` passerebbe dal PopScope.

**Quattro test**, tre visti rossi prima: al terzo passo il gesto torna al
secondo, dal primo non apre la home, insistendo sette volte non apre la home,
dal Risveglio non si esce.

Un'asserzione l'ho **tolta invece di adattarla**: controllava
`needsOnboarding`, che nasce falso finche' il controller non ha letto le
preferenze, quindi sarebbe stata verde a prescindere dal difetto.

### A2, i selettori dell'ora: CHIUSA

**Regressione mia**, come avevo scritto nella stima: `enabled: _timeKnown ==
true` con `_timeKnown` che parte nullo e' sempre falso, quindi i selettori
nascevano spenti e per scegliere l'ora bisognava passare da "Non la so" e
tornare indietro.

Tre cose corrette insieme:

- I selettori sono **sempre** usabili. Toccarne uno vale come dire che l'ora si
  sa, quindi non serve dichiararlo due volte.
- `_hour` e `_minute` sono diventati **nullabili**, quindi l'invito "Ora" e
  "Minuti" che nel codice esisteva gia' ora si vede davvero. Prima le pillole
  dichiaravano 12 e 00, un'ora che nessuno aveva scelto e che finiva dritta
  nella carta natale.
- **Contrasto del quadrante alzato**: il cerchio dell'orologio da 0,45 a 0,75,
  le tacche da 0,75 e 0,40 a 0,95 e 0,65, e la velatura da 0,35 a 0,55 quando
  l'ora e' dichiarata ignota.

**Cinque test**, quattro visti rossi, su **entrambe le altezze**. Le due altezze
stanno in due prove separate: rimontare due volte nella stessa prova non
ripartiva pulito, e il verde che ne usciva diceva piu' sul test che sullo
schermo.

### B1, il colore al primo ingresso: CHIUSA

**La causa non era quella che avevo scritto nella stima.** Avevo indicato
l'uscita anticipata di `MaestroController._setKey`, ma quel controller e'
corretto: non notificare quando nulla cambia e' giusto. La causa vera stava in
`_CircleArtTile._open`, cioe' **nella tessera che apre l'arte**: era lei a
virare il tema prima di navigare. Funzionava per chi passava da li' e per
nessun altro. Chi apriva la stessa arte dallo scaffale del proprio Maestro,
dalla chat o da una rotta diretta entrava col colore di chi stava guardando
prima, e al primo ingresso col neutro. Per di piu' il ripristino era
condizionato a `previous != null`, quindi partendo dal neutro il colore
dell'arte restava addosso al Cerchio anche dopo essere usciti.

E' la quarta volta che incontro la stessa forma: **una regola messa in una
porta mentre le porte sono molte**. Quindi il colore ora si dichiara nello
stato, non nella transizione: `MaestroScope` accetta un proprietario, e quando
c'e' vince sempre, senza nemmeno osservare il Maestro attivo, cosi' un cambio di
tema avvenuto fuori non fa virare il colore sotto i piedi di chi sta usando
l'arte. **Tredici rotte** lo dichiarano, assegnate leggendo `art_catalog`, non a
intuito.

**Diciotto test.** Uno di essi, il primo che avevo scritto, misurava l'assenza
di `operator ==` su `MaestroPalette` invece del difetto: confrontava oggetti che
non sono mai uguali fra loro, quindi era rosso anche nel caso che doveva
passare. L'ho riscritto sul colore primario, che e' la cosa che si vede.

### B2, ogni bolla nel colore del suo Maestro: CHIUSA

Le bolle erano tutte nel viola condiviso: la striscia diceva a parole di chi
fosse ogni arte, con una scritta piccola sotto il nome, senza mostrarlo. Ora il
colore del proprietario sta nel fondo, nel bordo, nel cerchietto dell'icona e
nel nome del Maestro, col viola condiviso che resta sotto velato, cosi' la
striscia rimane una striscia sola e non tre accostate.

La tessera e' diventata pubblica, come il painter del sigillo, per la stessa
ragione: il colore di una bolla deve poter essere misurato senza montare
l'intero dominio coi suoi servizi.

**Due test**, entrambi visti rossi. Il secondo l'ho dovuto **riscrivere**: la
prima versione chiedeva che la componente dominante coincidesse, ma il verde
smeraldo di Aura ha di suo una componente blu alta, e sul viola quel blu passa
davanti al verde di un centesimo pur restando inequivocabilmente il colore di
Aura. Adesso misura la **vicinanza**: ogni bolla deve stare piu' vicina al
proprio Maestro che a ciascuno degli altri due.

### B3, i Doni fuori dall'elenco: CHIUSA

L'Oracolo del Giorno e la Runa del Tramonto stavano in **due posti nella stessa
schermata**: nella striscia del giorno in cima, che e' la loro casa, e di nuovo
nell'elenco delle funzioni sotto l'eroe. Tolti dall'elenco.

**Tre test**: nessun Dono nell'elenco, l'elenco resta abitato con almeno sei
voci vive, tutti e tre i Maestri restano rappresentati. Gli ultimi due servono a
non scambiare un doppione con un buco.

Il manifest `docs/stato_funzioni.json` e' stato allineato: il suo test lo ha
preso, ed e' andata come deve andare.

### B4, "Le tue arti": CHIUSA IN VERSIONE PIENA

Avevo dichiarato una riserva sulla matita. **Non serve: consegnata intera.**

Le tre regole vivono nel **dato**, in `lib/core/arts/arti_preferite.dart`, non
nelle schermate che lo mostrano.

1. **Non parte mai vuoto.** Il seme sono le arti vive del Maestro assegnato piu'
   una per ciascuno degli altri due, deterministico, senza numeri casuali. Non
   parte nemmeno monocolore: chi nasce con Caligo vede anche che Medora e Aura
   esistono. Prima della Risonanza il seme e' la prima arte viva di ciascuno,
   quindi abitato comunque. Anche il primissimo frame, prima che il disco
   risponda, mostra il seme invece di un vuoto: un lampo di scaffale spoglio
   all'avvio sarebbe indistinguibile dal difetto.
2. **Svuotandolo torna il seme.** Togliere l'ultima arte ripristina, e la
   schermata lo dice.
3. **Nessun piano lo tocca.** Un test legge il file e verifica che le parole
   tier, entitlement, premium, abbonamento e PlanCatalog non compaiano nel
   codice. Guarda solo il codice e non i commenti, perche' i commenti quelle
   parole le nominano proprio per dire che non si usano.

Il tetto e' **sei**: le arti vive sono nove, quindi sei lascia una scelta vera
senza ridiventare l'elenco completo. Chi prova ad aggiungere la settima se lo
sente dire, invece di vedere il tocco ignorato in silenzio.

**Il cuore sta in un punto solo.** Invece di metterlo a mano in nove schermate
ho creato `SogliaArte`, che porta insieme il colore del proprietario e il cuore:
le nove rotte d'arte passano da li', quindi chi aggiunge un'arte domani ottiene
entrambe le cose con una riga. Il cuore c'e' **dentro** l'arte, in alto a
destra, perche' si decide che un'arte piace mentre la si usa, e sulla bolla
tramite la **pressione lunga**, che dice sempre cosa e' successo.

**Un difetto trovato mentre lavoravo**: `rune_draw` e `magic_sigil`, cioe'
l'Estrazione Rune e il Sigillo dell'Intenzione, sono arti vive che nell'elenco
del Santuario non c'erano, quindi dal Santuario non si raggiungevano. Ora sono
fra le selezionabili, che e' il modo giusto di rimediare.

**Sedici test** in due file, nove sul dato e sette a schermo.
