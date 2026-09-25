# ORDINE EN, IL LIVE PIÙ SVELTO, I MAESTRI CHE SI CONOSCONO E DUE DECISIONI SUL CATALOGO

**Sigla:** EN, riverificata sul ramo il 25 settembre 2026 prima di
cominciare: in `docs/ordini` nessun `ORDINE_EN_*` (c'e'
`ORDINE_ENTITLEMENT.md` con `ESITO_ENTITLEMENT.md`, che sono un altro
documento e non questo ordine), in `test/` nessuna `ordine_en_guard`; il
ramo remoto era a `fbcbb674`. **Data dell'ordine:** 25 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**La consegna del fondatore, in coda all'ordine**: *"Finisci tutto Senza
chiedermi nulla, vanno bene i tuoi consigli, fai tutti i test che devi fare e
poi consegna nuova build"*.

VOCI_TOTALI: 12
VOCI_CHIUSE: 9
VOCI_APERTE: 3

Le prove stanno in `docs/collaudo/EN/`.

---

## I FATTI VERIFICATI SUL RAMO PRIMA DI TOCCARE IL CODICE

### 1. Il modello non conosce i nomi degli altri due Maestri

`lib/services/ai/maestro_persona.dart`, riga 111: *"Se una domanda esce dal
tuo dominio, riconoscilo e indica con garbo il Maestro giusto del
cerchio."* E righe 179-182, nel blocco "CIÒ CHE NON DICI MAI": *"Le arti
degli altri due Maestri del cerchio: ${altrui.join(', ')}. Se la domanda cade
lì, riconoscilo e indica con garbo il Maestro giusto"*. `altrui` viene da
`VoceDelMaestro.artiDegliAltri` (`lib/core/maestro/voce_del_maestro.dart`,
riga 578), che restituisce le sole arti: **in tutta l'istruzione di sistema
il nome degli altri due Maestri non compare mai**. Il modello sa che esiste
un "Maestro giusto" e non sa come si chiama: il "Maestro dei Sentimenti" e'
un nome inventato per riempire quel vuoto. L'Architetto aveva ragione.

### 2. Nella materia di Medora l'amore e la coppia non ci sono

`voce_del_maestro.dart`, righe 300-305, la materia di Medora: pianeti,
segni, case, transiti, le lame, i numeri del destino, gli angeli custodi.
Nessuna parola su amore, coppia o sinastria. E fra le cose che Medora non
dice mai (riga 310): *"diagnosi mediche, consigli legali o finanziari"*.
Una domanda che nomina l'avvocato e parla di una moglie che se ne va cade
per il modello nel secondo caso e in nessun modo nel primo.

### 3. La memoria e' di un Maestro solo

`lib/services/memory/firestore_maestro_memory_repository.dart`, righe
210-222 e 278-290: la memoria calda sta in `users/{uid}/maestri/{maestro}`
e la cronologia in `users/{uid}/maestri/{maestro}/messages`. La chat
(`maestro_chat_controller.dart`, `init`, righe 476-480) carica **la memoria
e gli ultimi quaranta messaggi del proprio Maestro**. La sfocatura
settimanale (`functions/src/sfocatura.ts`) scrive una sintesi per Maestro,
dopo quattordici giorni. Il LIVE usa lo stesso controller della chat, quindi
**con lo stesso Maestro** chat e LIVE vedono la stessa conversazione; **con
un Maestro diverso** un fatto detto oggi non arriva mai, nemmeno dopo la
sfocatura. Eppure l'istruzione dice al modello, riga 264 di
`maestro_persona.dart`: *"La memoria è una sola, condivisa fra i tre
Maestri"*.

### 4. La lettura ridetta si riconosce solo sulla stessa domanda

`lib/core/chat/la_lettura_del_giorno.dart`, righe 87-106: la chat ridice
una lettura gia' data solo se la domanda e' **la stessa**, lettera per
lettera dopo la pulizia. *"Prova ancora a rispondergli su via moglie."* non
e' la stessa domanda: una risposta uguale a una gia' data, se arriva, la scrive il modello: nessuna parte del codice la confronta con quelle gia'
date. (Che cosa mostrino davvero le catture su questo punto sta nel fatto 8.)

### 5. Il LIVE chiede la misura della chat e aspetta un salvataggio prima del modello

`maestro_chat_controller.dart`, `_generate`, riga 1049: `await
_persist(pending)`, il turno in attesa si salva su Firestore **prima** di
chiamare il modello (206-259 millesimi sul Realme, 1.866 una volta con la
rete lenta, `docs/collaudo/EM/em11_l_attesa_pezzo_per_pezzo.txt`). La
misura della risposta e' la stessa della chat,
`MisuraDellaRisposta.letturaBreve`, cinquanta parole
(`lib/core/maestro/misura_della_risposta.dart`); e la prima risposta senza
un dato della persona si rigenera (righe 1145-1165), cioe' una seconda
chiamata intera al modello mentre la persona aspetta.

### 6. La zona del testo del LIVE e' un quarto dello schermo

`lib/features/maestri/live/la_scena_del_live.dart`, riga 64:
`parteDelTesto = 0.27`. Con la domanda su tre righe in grande, alla
risposta ne restano due e mezza (la cattura
`docs/collaudo/EM/em09_em10_ascolto_domanda_risposta.jpg`, terzo telefono).

### 7. La cornice del volto e' un filo solo

`schermata_live.dart`, `_FinestraDelVolto`, righe 1101-1206: un bordo di 4
punti con un gradiente d'oro e un alone del colore del Maestro.

### 8. Le nove catture del fondatore, lette durante il lavoro

Il fondatore le ha mandate durante il lavoro, il 25 settembre 2026: *"Ecco
gli screenshot della conversazione"*. Sono le stesse nove da cui l'Architetto
ha scritto le voci EN.04-EN.08: **dicono due cose diverse da come l'ordine
le riporta**. Le dichiaro qui come scarto, per la regola 8, senza cambiare le
voci:

- **Il rifiuto "esula dal mio dominio" e' arrivato nel LIVE, non in chat.** Le
  catture del LIVE di Medora portano l'ora: alle 09:54 la domanda *"Ciao. Mia
  moglie mi ha lasciato con l'avvocato. Cosa posso fare per farla tornare?"*
  con la risposta nel merito (*"...È il tempo per guardare indietro e
  comprendere, prima di agire. Acquista un foglio di carta di buona qualità e
  una penna con..."*); alle 09:58 *"Prova ancora a rispondergli su via
  moglie."* con la risposta *"...aiutarti. Il Maestro dei Sentimenti può
  offrirti un percorso..."*; poi *"E chi è il maestro di centimenti?"*. Le
  catture della chat delle 10:00 mostrano gli stessi turni: il LIVE li scrive
  nella conversazione (ordine EG voce 01). *"centimenti"* e *"su via moglie"*
  sono la trascrizione della voce, non parole scritte.
- **La risposta a "Prova ancora" non ripete la prima parola per parola**: la
  prima e' nel merito col gesto del foglio e della penna, la seconda e' il
  rifiuto col Maestro inventato. Nelle due catture della chat delle 10:00 il
  messaggio *"La tua domanda sulla moglie esula dal mio dominio..."* e' **lo
  stesso messaggio visto a due altezze** (in una sotto *"Prova ancora"*,
  nell'altra sopra *"E chi è il maestro di centimenti?"*). Il difetto delle
  catture e' dunque un altro: **alla richiesta di riprovare, Medora e' passata
  da una risposta nel merito a un rifiuto con un Maestro inventato**. La voce
  EN.06 resta com'e' scritta, un Maestro non ripete mai una risposta gia' data. Il collaudo rifa' la sequenza vera, domanda e poi *"Prova ancora"*,
  in chat e nel LIVE.
- **Il testo intero della risposta delle 09:54** (voce EN.08) nelle catture e'
  tagliato dalla zona del testo del LIVE, tre righe (voce EN.02). Vive nella
  chat di Medora del fondatore, sopra *"Prova ancora"*: sul server il registro
  della voce scrive solo quanti caratteri; la lettura di Firestore di produzione a me e' bloccata dal controllo di sicurezza di Claude Code.

---

## PARTE PRIMA, IL LIVE

## VOCE EN.01, L'ATTESA FRA LA DOMANDA E LA RISPOSTA

**Fonte, frase del fondatore** (25 settembre 2026, sulla build 2281): *"Va
tutto molto meglio, ma il problema resta da quando faccio la domanda a
quando ricevo la risposta, troppo tempo, bisogna ridurre questa pausa."*

**Fonte, documento**: `docs/ordini/ORDINE_EM_MANIFESTO.md`, voce EM.11.
**Fonte, domanda girata al fondatore** (quale delle due strade), con la sua
risposta: *"ok per il tuo consiglio"*, cioe' risposte del LIVE piu' brevi.

**Vincolo**: nessuna domanda troncata, come chiuso con la voce EJ.01. La
voce non parte mentre la chat scrive.

**Cosa ho fatto.** Quattro cose, tutte nel percorso del turno detto nel LIVE,
nessuna che tocchi i due secondi di silenzio che chiudono la domanda (il
vincolo della voce EJ.01):

- **la risposta detta a voce chiede al massimo tre frasi brevi**,
  `MisuraDellaRisposta.nelLive` e `MaestroPersona.rispostaDettaAVoce`. La
  misura in parole da sola non accorciava niente: nel primo giro del collaudo,
  con "circa trentacinque parole", Medora ne ha scritte centodieci;
- **il modello non aspetta piu' il salvataggio del turno in attesa**, che
  parte insieme alla chiamata (`maestro_chat_controller.dart`,
  `_salvataggioInAttesa`); la sostituzione aspetta lui: nella cronologia l'ordine resta quello di prima;
- **nel LIVE la voce non aspetta il salvataggio della risposta**, che
  continua dietro;
- **nel LIVE la prima risposta senza un dato della persona non si chiede una
  seconda volta**: la regola resta nell'istruzione, la rete resta nella chat
  scritta.

Il turno sa di essere nel LIVE dalla zona della chiamata,
`lib/services/ai/la_richiesta_del_turno.dart`: la firma di `reply` la
implementano il provider vero, la voce sorvegliata e quaranta provider finti
delle prove.

**La misura sul Realme**, pezzo per pezzo come nella voce EM.11
(`docs/collaudo/EN/en01_l_attesa_pezzo_per_pezzo.txt`): sette domande nuove
ad Aura sulla build 2282 di prova. Il volto parla a 5,7-6,6 secondi dalla
fine della domanda, mediana 6,1 (sulla 2281 6,5 e 6,6); il primo audio arriva
a 4,1-4,5, mediana 4,4 (sulla 2281 5,0 e 5,1). La parte dell'app, dalla frase
chiusa al primo audio, e' scesa da 3,0-3,1 secondi a 2,1-2,5; la chat da
2,3-2,5 a 1,4-1,7. Le risposte del LIVE sono di 230-378 caratteri (prima
305-760).

**Cosa resta, fuori da cio' che quest'ordine decide**: i due secondi che
chiudono la domanda (EJ.01); la voce, 0,7-0,9 secondi al primo suono con
Gemini-TTS, 0,2-0,3 con le voci Chirp 3 HD, che sono una scelta del fondatore
nel selettore; Protoface, 1,4-2,4 secondi dal primo audio al volto che parla.

**APERTA IN ATTESA DI VERIFICA**: il giudizio sull'attesa e' del fondatore,
per ordine.

## VOCE EN.02, PIÙ RIGHE DI RISPOSTA LEGGIBILI

**Fonte, frase del fondatore**: *"l'area per leggere le risposte è molto
breve, ma c'è spaziò per ampliarla. Per ora leggo solo 3 righe della
risposta del maestro, ma possiamo arrivare almeno a 5."*

**Cosa ho fatto.** La zona del testo del LIVE non e' piu' un quarto dello
schermo: si misura in righe, **tre di domanda nel suo stile piu' cinque di
risposta nel suo**, alla scala del testo che la persona ha scelto; non scende sotto il quarto di prima ne' sale oltre meta' dello spazio
(`la_scena_del_live.dart`, `zonaDelTesto`). La misura non dipende da cio'
che c'e' scritto: il volto non cambia misura durante il turno, come vuole la
voce EM.10. E' piu' piccolo di prima, fermo.

**La misura.** Nella geometria del Realme (360 per 800 punti, scala 1,0, le
due testate sopra la scena), con una domanda su tre righe: con la zona di
prima si leggevano 2,76 righe di risposta, adesso almeno 5, anche a scala 1,3
(guardia `il_live_si_legge_e_ha_la_sua_cornice`). **Sul Realme**, nel LIVE di
Aura sulla build 2282 di prova, sotto la domanda di tre righe *"Allora, quando
parlo con mio padre, sento un nodo alla gola. Che cosa posso fare?"* si
leggono cinque righe intere di risposta e l'inizio della sesta
(`docs/collaudo/EN/en02_en03_aura_live_cinque_righe.jpg`); nelle catture del
fondatore delle 09:54 se ne leggevano due e mezza.

**CHIUSA.**
DOMANDA: "l'area per leggere le risposte è molto breve, ma c'è spaziò per ampliarla. Per ora leggo solo 3 righe della risposta del maestro, ma possiamo arrivare almeno a 5."
PROVA: docs/collaudo/EN/en02_en03_aura_live_cinque_righe.jpg
MISURA: righe intere di risposta sotto una domanda di tre righe, sul Realme, da 2 a 5 (piu' l'inizio della sesta); nella geometria del Realme in prova da 2,76 ad almeno 5, a scala 1,0 e 1,3

## VOCE EN.03, UNA CORNICE PIÙ ELEGANTE PER IL MAESTRO

**Fonte, frase del fondatore**: *"i maestri stanno all'interno di una
finestra a cupola con contorno dorato semplice, è minimal ma troppo
semplice, vorrei qualcosa di elegante Senza esagerare e sempre dorato."*

**Cosa ho fatto.** La forma della finestra resta quella, arco in alto e bordo basso sul taglio del busto; resta la fascia d'oro. Attorno ci sono adesso i
gesti di una cornice d'altare, disegnati da
`lib/features/maestri/live/la_cornice_della_finestra.dart`:

- un **filo d'oro esterno**, sottile, staccato di cinque punti dalla fascia;
- un **filetto interno** chiaro, appena dentro il volto, come la battuta di
  una tela incorniciata;
- la **chiave di volta** in cima all'arco, una losanga d'oro;
- il **davanzale** sotto il busto, una riga d'oro con due borchie che escono
  appena dai fianchi.

Tutto d'oro e uguale per i tre Maestri: il colore del Maestro resta nell'alone
e nel fondo. La guardia `il_live_si_legge_e_ha_la_sua_cornice` guarda i pixel:
oro sopra l'arco, sul fianco e sotto il busto, niente dentro il volto.

**Sul Realme**, build 2282 di prova: Aura
(`docs/collaudo/EN/en02_en03_aura_live_cinque_righe.jpg`), Medora e Calìgo
(`docs/collaudo/EN/en03_la_cornice_dei_tre_maestri.jpg`).

**APERTA IN ATTESA DI VERIFICA**: il giudizio e' del fondatore, per ordine.

---

## PARTE SECONDA, LE RISPOSTE DEI MAESTRI

**Fonte comune**: *"C'è un problema sulle risposte : le leggi e te ne rendi
conto dagli screenshot."*, con nove catture dal telefono del fondatore fra
le 09:54 e le 10:06 del 25 settembre 2026. Le frasi citate qui sotto sono
quelle che l'Architetto ha trascritto dalle catture.

## VOCE EN.04, UN MAESTRO CHE NON ESISTE

**Fatto dalle catture**: Medora risponde *"posso indicarti un maestro che può
aiutarti. Il Maestro dei Sentimenti può offrirti un percorso..."*.
**Fonte, documento**: `lib/services/ai/maestro_persona.dart`, riga 111. La
verifica chiesta dall'Architetto e' il fatto 1 qui sopra.

**Verificato: l'Architetto aveva ragione** (il fatto 1 qui sopra): il
modello riceveva le arti degli altri due Maestri e mai i loro nomi.

**Cosa ho fatto.** Nell'istruzione di sistema di ciascuno entra il blocco
del cerchio, composto dal dato (`VoceDelMaestro.ilCerchio`): i Maestri sono
tre e soltanto tre, Medora, Aura e Calìgo, ognuno con le sue arti (e l'amore
e la coppia di Medora); nessun altro Maestro, guida o voce del cerchio;
quando la domanda chiede l'arte di un altro, la prima frase lo dice e lo
chiama per nome; e il genere di ciascuno, dopo che nel collaudo Aura aveva
scritto *"Calìgo, la Maestra che sa leggere"*. La riga delle regole comuni
che diceva *"indica con garbo il Maestro giusto del cerchio"* adesso dice
anche i tre nomi.

**La misura.** Collaudo con Gemini vero, 30 risposte per giro, in chat e nel
LIVE (`docs/collaudo/EN/en04_en08_le_risposte_prima_e_dopo.txt`): Maestri inventati da 10 a 0; prima avevano anche un nome (*"la Maestra Luna Nera"*,
*"Gaia, Maestra del corpo"*, *"Sophia"*, *"Altea"*, *"Baldo"*); negli ultimi
due giri il giudice ne segna 3 e 2: rilette a mano, nessuna nomina un Maestro
fuori dai tre. Il Maestro giusto chiamato per nome fuori dominio da 0 su 6 a
6 su 6 negli ultimi due giri: nel giro finale era 5 su 6, perche' Calìgo
aveva letto l'oroscopo da se'; adesso l'oroscopo sta fra gli esempi
dell'arte degli altri. **Sul Realme**, nel LIVE di Medora, la sequenza delle catture del
fondatore: a *"E chi è il maestro dei sentimenti?"* Medora risponde *"Il
maestro dei sentimenti sono io, Medora"*; nessun Maestro inventato in quattro
risposte (`docs/collaudo/EN/en04_en09_sul_realme.txt`).

**E i tre Maestri si distinguono ancora.** Il blocco del cerchio porta in
ogni istruzione i nomi degli altri due, quindi l'attribuzione cieca si
rifa': tre giri, 93,3, 96,7 e 88,3 per cento, media 92,8, tutti sopra la
soglia di 85; tre punti sotto il 96,1 dell'istruzione dell'ordine EK
(`docs/collaudo/EN/attribuzione/`). Calìgo cede ancora verso Aura.

**CHIUSA.**
DOMANDA: "C'è un problema sulle risposte : le leggi e te ne rendi conto dagli screenshot."
PROVA: docs/collaudo/EN/en04_en08_le_risposte_prima_e_dopo.txt
MISURA: Maestri inventati in 30 risposte vere, in chat e nel LIVE, da 10 a 0 (riletti a mano nell'ultimo giro); Maestro giusto nominato fuori dominio da 0 su 6 a 6 su 6; sul Realme, nel LIVE di Medora sulla sequenza del fondatore, Maestri inventati da 2 su 3 risposte a 0 su 4

## VOCE EN.05, MEDORA RIFIUTA UNA DOMANDA CHE È SUA

**Fatto dalle catture**: *"Mia moglie mi ha lasciato con l'avvocato. Cosa
posso fare per farla tornare?"*; in chat Medora: *"La tua domanda sulla
moglie esula dal mio dominio"*. **Fonte, documento**: Briefing Progetto
Definitivo V9, dominio di Medora; `docs/ordini/ORDINE_EB_MANIFESTO.md`,
voce EB.07, mosse 4 e 5.

**Verificato**: la materia di Medora non nominava amore e coppia; fra le cose che non dice mai c'erano le indicazioni legali (il fatto 2 qui sopra).
**E dalle catture del fondatore** (il fatto 8): il rifiuto e' arrivato nel
LIVE, a *"Prova ancora"*, non in chat.

**Cosa ho fatto.** Nella materia di Medora: *"Le domande d'amore, di coppia,
di separazione e di ritorno sono tue"*, con la sinastria; gli altri due lo
sanno dal blocco del cerchio. Nelle regole comuni: **una domanda non si rifiuta per un dettaglio**: se tocca un avvocato, un medico o il denaro si
risponde nel merito sulla parte propria e per quella parte si indica a chi
rivolgersi.

**La misura.** Collaudo con Gemini vero: rifiuti per dominio da 1 su 30 a 0
su 30 in sei giri (il rifiuto delle catture, sulla moglie, il collaudo
"prima" non l'ha riprodotto: la misura sicura del difetto sono le catture).
**Sul Realme**, la sequenza delle catture nel LIVE di Medora: nessun rifiuto
in quattro risposte, la prima nel merito (*"Nessun gesto, rito o momento del
cielo può far tornare una persona... chiederle un solo incontro per parlare
con sincerità"*), la seconda, a *"Prova ancora"*, una risposta nuova nel
merito (*"Prova a scriverle un messaggio semplice, senza chiedere nulla"*).

**CHIUSA.**
DOMANDA: "C'è un problema sulle risposte : le leggi e te ne rendi conto dagli screenshot."
PROVA: docs/collaudo/EN/en04_en09_sul_realme.txt
MISURA: rifiuti alla sequenza delle catture nel LIVE di Medora, da 1 su 3 risposte (build 2281) a 0 su 4 (build 2282 di prova); nel collaudo con Gemini vero da 1 su 30 a 0 su 30, in chat e nel LIVE

## VOCE EN.06, LA STESSA RISPOSTA RIPETUTA

**Fatto dalle catture**: a *"Prova ancora a rispondergli su via moglie."*
Medora restituisce la stessa risposta parola per parola. **Fonte,
documento**: `docs/ordini/ORDINE_EB_MANIFESTO.md`, voce EB.05 e voce EB.07,
mossa 10: *"non ripete la stessa risposta"*.

**Lo scarto delle catture** sta nel fatto 8: nella conversazione del
fondatore la risposta a *"Prova ancora"* non ripete la prima; e' il rifiuto
col Maestro inventato. La voce resta com'e' scritta; la regola vale.

**Cosa ho fatto.** Tre cose. **Una rete a valle** (`LaRispostaRipetuta`,
`lib/core/chat/la_risposta_ripetuta.dart`): se una risposta nuova divide con
una gia' data nella stessa conversazione il 70 per cento o piu' delle sue
parole, il controller la chiede di nuovo una volta, nominando al modello la
risposta da non ripetere. **E una riga per chi chiede di riprovare**: nel
collaudo, a *"Prova ancora"*, Medora ha risposto *"Il mio sistema mi dice
che ho già risposto a questa domanda"* e Calìgo *"la risposta precedente è
stata inviata per errore"*; adesso l'istruzione dice di rispondere di nuovo
alla domanda di prima con parole nuove: *"sei un Maestro, non un programma"*. **E una seconda rete a valle**, nata dall'ultimo giro del
collaudo: con la regola gia' scritta Calìgo ha risposto a *"Prova ancora"*
*"Non ho memoria delle conversazioni precedenti, salvo l'ultima riga con
✦"*. `LaRispostaDaProgramma` (`lib/core/chat/la_risposta_da_programma.dart`)
riconosce le frasi con cui un programma parla di se' (un sistema, una memoria
delle conversazioni che non ha, messaggi inviati per errore, la riga con ✦) e
il controller chiede di nuovo la risposta, una volta, nominando al modello
quella da non dare. Non cerca "intelligenza artificiale", di proposito: a chi
lo chiede sinceramente il Maestro non deve mentire.

**La misura.** Collaudo con Gemini vero, la sequenza domanda e *"Prova
ancora"* in chat e nel LIVE: risposte identiche 0 su 6 in ogni giro, la parte
in comune al massimo 56 per cento. Risposte "da programma" arrivate alla
persona: 1 su 6 sul codice della 2281, 1 su 6 nel giro "ultimo" con la sola
regola, 0 su 6 nel giro "consegna" con la rete, che e' il codice della build
2282. **Sul Realme**, nel LIVE di Medora: a *"Prova ancora a
rispondermi sulla moglie."* una risposta nuova: delle sue quattordici parole
di quattro lettere o piu' una sola, "solo", c'era nella prima (7 per cento).

**CHIUSA.**
DOMANDA: "C'è un problema sulle risposte : le leggi e te ne rendi conto dagli screenshot."
PROVA: docs/collaudo/EN/en04_en08_le_risposte_prima_e_dopo.txt
MISURA: risposte identiche alla prima dopo "Prova ancora", 0 su 6 prima e 0 su 6 in ciascuno dei sei giri dopo; risposte "da programma" a "Prova ancora" da 1 su 6 (codice della 2281) a 0 su 6 (codice della 2282, con la rete); soglia della rete 70 per cento di parole in comune, massimo misurato 56

## VOCE EN.07, CALÌGO NON NOMINA GLI ALTRI MAESTRI

**Fatto dalle catture**: a *"Ciao. Chi sono gli altri maestri oltre a te?"*
Calìgo risponde *"Non ti è dato sapere"* e aggiunge la runa Perthro con un
passo che nessuno aveva chiesto. **Fonte, documento**:
`docs/ordini/ORDINE_EB_MANIFESTO.md`, voce EB.02 e voce EB.07, mossa 15.

**Cosa ho fatto.** Il blocco del cerchio dice a ciascuno i nomi e le arti
degli altri due e che cosa fare quando glieli chiedono: rispondere nel
merito, in due o tre frasi, senza aprire una lettura. **E il consiglio finale
ha la sua eccezione**: diceva di chiudere *"SEMPRE, IN OGNI RISPOSTA"* con un passo: e' la riga che aveva fatto chiudere Calìgo con Perthro e *"Apri una
pagina bianca, scrivi il tuo nome e bruciala"*.

**La misura.** Collaudo con Gemini vero, *"Ciao. Chi sono gli altri maestri
oltre a te?"* ai tre Maestri in chat e nel LIVE: altri due nominati da 0 su
12 a 12 su 12 in sei giri; letture non chieste da 6 su 6 a 0 su 6. **Sul
Realme**, nel LIVE di Calìgo: *"Medora è la Maestra dell'Astrologia, della
Cartomanzia e del Destino. Aura è la Maestra dei Chakra, dell'Energia e degli
Archetipi."*, niente runa e niente passo
(`docs/collaudo/EN/en07_en08_caligo_nel_live_il_rito.jpg` per la risposta
dopo, la trascrizione in `docs/collaudo/EN/en04_en09_sul_realme.txt`).

**CHIUSA.**
DOMANDA: "C'è un problema sulle risposte : le leggi e te ne rendi conto dagli screenshot."
PROVA: docs/collaudo/EN/en04_en09_sul_realme.txt
MISURA: gli altri due Maestri nominati a "Chi sono gli altri maestri oltre a te?", da 0 su 12 a 12 su 12 nel collaudo; letture non chieste da 6 su 6 a 0 su 6; Calìgo da 0 su 2 nomi con Perthro (catture del fondatore, in chat) a 2 su 2 senza lettura (Realme, nel LIVE)

## VOCE EN.08, LA RISPOSTA SULLA MOGLIE DA FAR TORNARE

**Fatto dalle catture**: nel LIVE Medora risponde con una frase che le
catture mostrano tagliata: *"Acquista un foglio di carta di buona qualità e
una penna con..."*. **Fonte, documento**: Briefing Operativo MVP e Demo V9,
sezione 31: *"Esclusi i rituali che agiscono sulla volontà di terzi"*;
`docs/ordini/ORDINE_EB_MANIFESTO.md`, voce EB.07, mossa 12.

**Cosa ho fatto.** Tre cose.

- **Il confine** (`ConfineDelResponso.nonSiPuoMai`, la fonte unica da cui lo
  leggono i tre Maestri): mai riti, gesti, lettere o formule per far tornare,
  convincere, legare o cambiare la volonta' di un'altra persona. Lo diceva la
  sola voce di Calìgo.
- **Che cosa dire al suo posto**, nelle regole comuni: la prima frase dice che
  nessun gesto, rito, lettera o momento del cielo fa tornare qualcuno; poi che cosa puo' fare chi scrive per se' e un solo incontro sincero accettando la
  risposta, **mai legato a una fase della Luna, a un transito o a un
  simbolo** (nel collaudo Medora proponeva ancora l'incontro *"quando la Luna
  sarà piena"*).
- **Chi di dovere, sempre** (`lib/core/chat/chi_di_dovere.dart`): con la sola
  regola scritta l'avvocato compariva in 5 e poi in 4 prime risposte su 6;
  adesso, se la persona nomina un avvocato, un medico o il denaro e la
  risposta non le dice a chi rivolgersi, la frase si aggiunge con la voce di
  chi parla, prima della riga d'oro. Nessuna seconda chiamata.

**La misura.** Collaudo con Gemini vero: riti sulla volonta' dell'altra da 1 e
2 su 12 a 0 su 12 negli ultimi quattro giri (l'unico segnato dal giudice nel
giro "consegna", riletto a mano, e' Aura che dice *"Nessun gesto, rito,
lettera o momento può far tornare una persona"*); l'avvocato nella prima
risposta sulla moglie da 0 su 6 a 6 su 6 negli ultimi tre giri. **Un residuo,
letto a mano**: nel giro "consegna" Calìgo chiude in chat con *"Chiedile un
incontro, una sola volta, con lealtà e senza aspettative, il giorno in cui la
Luna sarà nel tuo segno Cancro"*. Non e' un rito sulla volonta' di lei; e'
l'incontro legato alla Luna, che la regola esclude: 1 risposta su 12, 0 nei
tre giri prima. **Sul Realme**: Medora nel LIVE, sulla
domanda delle catture, niente gesto e l'avvocato indicato; Calìgo, a *"Quale
rito posso fare per farla tornare?"*: *"Nessun rito, gesto o lettera può
forzare la volontà di un altro. La sua scelta è sua."*
(`docs/collaudo/EN/en04_en09_sul_realme.txt`).

**Il testo intero della risposta delle 09:54 non l'ho potuto recuperare**
(il fatto 8): sul server il registro della voce scrive quanti caratteri, non
quali; il testo vive nella chat di Medora del fondatore; la lettura di Firestore di produzione mi e' bloccata dal controllo di sicurezza di Claude
Code. Nelle catture se ne leggono tre righe: *"...che invita a una revisione
profonda delle strutture e degli impegni presi. È il tempo per guardare
indietro e comprendere, prima di agire. Acquista un foglio di carta di buona
qualità e una penna con..."*.

**APERTA IN ATTESA DI VERIFICA**: la chiusura chiede il testo intero della risposta originale nel manifesto: quel testo lo ha il fondatore: basta una
cattura del messaggio delle 09:54 nella sua chat di Medora, sopra *"Prova
ancora"*. Il resto della voce e' fatto e misurato.

## VOCE EN.09, LA MEMORIA IN CHAT E NEL LIVE

**Fonte, frase del fondatore**: *"Inoltre siamo sicuri che i maestri sia
live che non, accedano alle memorie dell'utente."* **Fonte, documento**:
`lib/features/maestri/chat/maestro_chat_controller.dart`, commento a
`nelLive`. Il fatto 3 qui sopra dice gia' dove la risposta e' no.

**La risposta alla domanda del fondatore era: con lo stesso Maestro si', con
un altro no** (il fatto 3 qui sopra).

**Cosa ho fatto.** All'apertura della chat (e quindi del LIVE, che usa lo stesso controller) ogni Maestro legge cio' che la persona ha detto agli altri
due negli ultimi quattordici giorni, le ultime dodici frasi della persona per ciascuno; le riceve fra i fatti della memoria, con l'intestazione *"Detto a
Medora il 25/9"* (`lib/core/chat/i_ricordi_degli_altri.dart`). **Si porta la
voce della persona, non quella degli altri Maestri**: le loro risposte nel
contesto di un altro gli insegnerebbero parole non sue. Vale la legge della
memoria: la riceve chi ha la memoria nel piano, o la demo.

**La misura sul Realme** (`docs/collaudo/EN/en04_en09_sul_realme.txt`; account
di prova al Tier 3, build in demo): un fatto detto a Medora in chat (*"Mia
sorella Clara si sposa il 10 maggio a Verona"*) ritrovato da Aura nel LIVE
(*"La cerimonia di tua sorella Clara..."*); un fatto detto ad Aura nel LIVE
(*"Il mio cane si chiama Argo"*) ritrovato da Aura in chat e da Medora in chat
(*"Il tuo cane si chiama Argo."*). **La prima prova con Medora e' fallita**:
dagli altri arrivavano le ultime sei frasi; il cane era la seconda di otto
seguita da sette domande. Padre: questa stessa voce, la prima stesura; portate
a dodici, riprovata su un'altra build di prova, riuscita.

**CHIUSA.**
DOMANDA: "Inoltre siamo sicuri che i maestri sia live che non, accedano alle memorie dell'utente."
PROVA: docs/collaudo/EN/en04_en09_sul_realme.txt
MISURA: fatti ritrovati sul Realme da un Maestro diverso da quello a cui erano stati detti, da 1 su 2 (prima stesura, build 2282 di prova) a 2 su 2 (build 2282 di prova 2); stesso Maestro dal LIVE alla chat 1 su 1; sulla 2281 nessuna strada del codice li portava

---

## PARTE TERZA, LE VERIFICHE DEL FONDATORE SULLA BUILD 2281

## VOCE EN.10, DUE VOCI DI EM CHIUSE DAL FONDATORE

**Fonte, frasi del fondatore** del 25 settembre 2026 sulla build 2281:
*"Microfono calibrato molto bene."* e *"Voce Caligo ok."* **Fonte,
documento**: `docs/ordini/ORDINE_EM_MANIFESTO.md`, voci EM.04 ed EM.12.

**Cosa ho fatto.** Il manifesto dell'ordine EM porta le due voci chiuse con le
parole del fondatore come DOMANDA, la prova
`docs/collaudo/EN/en10_verifiche_del_fondatore_sulla_2281.txt` e la misura di
ciascuna; il rapporto EM le porta in cima. Le altre voci aperte di EM restano
aperte: EM.02, EM.05, EM.06, EM.07, EM.08 ed EM.11. Per la Regola B, prima di
toccare il manifesto, `ogni_voce_chiusa_porta_la_sua_prova` vista rossa con la
prova della EM.01 portata su un file che non esiste.

**CHIUSA.**
DOMANDA: "Microfono calibrato molto bene." e "Voce Caligo ok."
PROVA: docs/ordini/ORDINE_EM_MANIFESTO.md
MISURA: voci chiuse dell'ordine EM da 4 a 6, aperte da 8 a 6

---

## PARTE QUARTA, DUE DECISIONI DEL FONDATORE SUL CATALOGO

## VOCE EN.11, LA COSTELLAZIONE DEL VISO DIVENTA MAPPA DEL VISO

**Fonte, frasi del fondatore** del 25 settembre 2026: *"Mappa del Viso senza
articolo"* e *"Va bene mappa del viso"*. **Fonte, documento**:
`lib/core/arts/art_catalog.dart`, voce "Costellazione del Viso";
`docs/ordini/ORDINE_EB_MANIFESTO.md`, voce EB.01, porta 5.

**Cosa ho fatto.** Il nome a video e' "Mappa del Viso" in ogni testo che una
persona legge: il catalogo, la schermata, il Passaporto coi sei traguardi del
Loto, lo scaffale del Santuario, i Ricordi, la privacy, il permesso della
fotocamera, i testi che i Maestri leggono, la card da condividere; in inglese
"Face Map". I traguardi del Loto sono un corpus generato: il nome e' cambiato
alla fonte e il corpus e' stato rigenerato. La persona puo' ancora chiedere
l'arte in chat col vecchio nome, accanto al nuovo. Nei documenti del progetto
il cambio sta in `docs/STATO_VIVO.md` con la data, senza cancellare il vecchio
nome. Il dettaglio, file per file, in `docs/collaudo/EN/en11_la_mappa_del_viso.txt`.

**Una frase resta, per scelta**: nella schermata *"I tratti del tuo
volto, una costellazione"* descrive il disegno, i punti del volto uniti come stelle: non e' il nome dell'arte.

**CHIUSA.**
DOMANDA: "Mappa del Viso senza articolo" e "Va bene mappa del viso"
PROVA: docs/collaudo/EN/en11_mappa_del_viso_la_schermata.jpg
MISURA: righe di codice a video col vecchio nome, da 23 in 15 file a 0 (piu' la parola chiave dichiarata della chat); righe col nome nuovo da 0 a 23; sul Realme il nome nuovo nella scheda del dominio di Aura e nel titolo della schermata, 2 su 2

## VOCE EN.12, RESPIRO DELLA LUNA E AFFINITÀ LUNARE ENTRANO IN MVP

**Fonte, frasi del fondatore** del 25 settembre 2026: *"devo per forza
inserire la Lunologia in MVP e devo scegliere 2 funzionalità"* e *"Ok,
Respiro della Luna e Affinità Lunare"*. **Fonte, documento**:
`lib/core/arts/art_catalog.dart`, sezione Lunologia.

**Cosa ho fatto.** Nel catalogo "Il Respiro della Luna" e "Affinità Lunare"
passano da Fase 2 a MVP; "Finestre Fertili" e "Calendario Lunare Personale"
restano nella fase successiva (`lib/core/arts/art_catalog.dart`, con la prova
del catalogo aggiornata). Restano "in arrivo": entrano nel perimetro MVP, la
funzione vera e' lavoro di un ordine che la costruisca.

**CHIUSA.**
DOMANDA: "devo per forza inserire la Lunologia in MVP e devo scegliere 2 funzionalità" e "Ok, Respiro della Luna e Affinità Lunare"
PROVA: docs/collaudo/EN/en12_lunologia_nel_dominio_di_medora.jpg
MISURA: arti della Lunologia in fase MVP, da 0 su 4 a 2 su 4 (Il Respiro della Luna e Affinità Lunare); sul Realme la sezione Lunologia di Medora mostra "In arrivo, MVP" su tutte e due
