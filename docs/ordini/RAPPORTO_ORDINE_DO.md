# RAPPORTO DELL'ORDINE DO, IL SIGILLO DELL'INTENZIONE DIVENTA UN OGGETTO CHE VIVE

15 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`. Il
manifesto con le quindici voci sta in `docs/ordini/ORDINE_DO_MANIFESTO.md`.

---

## 1. LE PREMESSE

Tutte e dieci **vere** sul commit `b885e2dd`, quindi l'ordine e' partito. La
tavola con l'esito di ciascuna sta nel manifesto. Le tre da verificare che
decidevano il lavoro: la riformulazione la faceva **una tabella**, non un
modello (P6); il segno e' **deterministico** dal testo (P7); la via **si
deduceva** dalle parole (P8).

---

## 2. LE CINQUE DOMANDE, CON LA SCHERMATA CHE RISPONDE

Le schermate vengono dal Realme 767f596c, in una build di profilo firmata
come la release e installata sopra senza cancellare i dati; stanno in
`docs/collaudo/DO/`. Il telefono ha le animazioni di sistema spente, quindi
il cammino si mostra gia' tracciato, come vuole Riduci Movimento.

| domanda | cosa si vede | schermata |
|---|---|---|
| **E adesso?** | a tracciamento finito la riga *"Adesso lascialo lavorare. Lo ritrovi nel Libro dei Sigilli quando vuoi e ti cerco io alla data che hai scelto."*, sotto *"La data: 15 ottobre 2026."*, poi il Libro e lo sfondo | `05_e_adesso.jpg` |
| **Cosa mi rimane?** | il Libro con due vivi, la loro luce e la data, e un compiuto sigillato nell'oro | `14_il_libro_due_vivi_e_un_compiuto.jpg`, `14b_il_libro_i_compiuti.jpg` |
| **Cosa ho ottenuto?** | alla data la domanda con le tre risposte; *Si e' compiuto* porta alla scheda, dove resta il testo che nomina l'intenzione | `12_la_domanda_alla_scadenza.jpg`, `13_il_compimento_resta.jpg` |
| **Cosa me ne faccio?** | *Imposta come sfondo*, le tre scelte, *"Fatto: il sigillo e' sul tuo telefono."*; lo sfondo **applicato davvero**, vedi il punto 2.1 | `06_le_tre_scelte_dello_sfondo.jpg`, `19_fatto_il_sigillo_e_sul_telefono.jpg` |
| **Cosa devo fare?** | il segno spento, la riga *"Ripassa il segno col dito..."*; ripassato col dito, il segno si accende e la riga dice *"Il segno si e' acceso. Si carica di nuovo domani."* | `10_la_scheda_prima_della_carica.jpg`, `11_la_carica_ha_acceso_il_segno.jpg` |

Le altre schermate chieste dalla voce DO.13: le tre righe alla prima
apertura, `01_le_tre_righe_alla_prima_apertura.jpg` e
`02_scrittura_cosa_ti_restera.jpg`; il tracciamento di un sigillo nuovo,
`04_il_tracciamento_e_il_sigillo_nuovo.jpg`; il limite del piano, *"Il tuo
piano tiene 5 sigilli vivi insieme: sono tutti aperti..."* col pulsante per
il Libro, `15_il_limite_del_piano.jpg`.

### 2.1 Lo sfondo, a schermo vero

Impostato davvero sul telefono, prima sulla schermata di blocco, poi su
entrambe. **La schermata di blocco il Realme non ce l'ha**: nessun codice di
sblocco e nessuna schermata di blocco (`CredentialType None`,
`isKeyguardShowing=false` anche a schermo spento), quindi al risveglio si
torna dritti all'app. Lo sfondo di blocco risulta impostato nel sistema
(`dumpsys wallpaper`, *Lock wallpaper state* nuovo). **La prova a schermo
vero e' la Home**: il fondo della Via Bianca, il segno nella fascia centrale,
il logo in basso, l'orologio del telefono in alto. **Quella cattura non sta
nel repository**, perche' mostra tutte le app installate sul telefono del
fondatore: gli e' stata mandata a parte.

**La cornice.** Guardando la cattura, il fondatore ha scritto: *"Il glifo
dovra' essere piu' grande e, visivamente, meglio se avra' un cerchio come
cornice. Buttato li' cosi', sembra uno scarabocchio"*. Adesso il glifo sta in
un anello nel colore della via, col filo interno dei sigilli incisi, e la
cornice prende tutto il 55 per cento della larghezza che la voce DO.07
concede; il glifo passa dal 42 al 47 per cento. Le prove pretendono l'anello
in sedici punti e il glifo a 0,415 del lato, e sono state viste rosse. Oltre
il 55 per cento si va solo su parola del fondatore.

**Sul telefono adesso c'e' il sigillo come sfondo**, sulla Home e sul blocco:
si toglie da Impostazioni, Sfondo. Nel Libro restano i sigilli della prova,
cinque vivi e uno compiuto: si chiudono con *Lo lascio andare*.

### 2.2 Il profilo femminile

Il telefono non cambia profilo da solo. **Lo prova la schermata vera al
banco**: col profilo femminile e un modello finto che risponde al maschile,
nessun maschile arriva a schermo (`sigillo_schermata_test`). **E lo prova la
sonda col modello vero**: dieci sigilli su trenta col profilo femminile,
dieci col maschile, dieci senza forma; **genere sbagliato arrivato a schermo:
zero**, in ognuna delle sette sonde.

---

## 3. IL COSTO DI UN SIGILLO COMPLETO

Misurato alla sonda finale, Gemini 2.5 Flash su europe-west1, trenta sigilli
completi col titolo, il responso, la riformulazione e il compimento: **103
chiamate, 36.146 token in ingresso e 4.321 in uscita**. Ai prezzi dell'ordine
DJ voce 03, 0,30 dollari per milione in ingresso e 2,50 in uscita, **un
sigillo completo costa 0,00072 dollari**, con 3,4 chiamate in media: la
seconda chiamata per il pezzo scartato, e la riformulazione che sui temi
delicati non parte. La carica non costa niente: non chiama nessun modello.

---

## 4. LE RIGHE SCARTATE DALLE GUARDIE, PER MOTIVO

Trenta intenzioni vere, tre forme a rotazione. *Prima* e' la prima sonda
che ha parlato col modello, con le guardie del Viaggio soltanto; *dopo* e'
la sonda finale, con le guardie nate dalle sonde. Si contano i tentativi
scartati.

| pezzo | motivo | prima | dopo |
|---|---|---:|---:|
| titolo | stato di un terzo | 7 | 5 |
| titolo | promessa | 1 | 3 |
| titolo | diagnosi | 1 | 2 |
| titolo | tempo nel titolo | 2 | 4 |
| titolo | nome proprio | 1 | 0 |
| titolo | prima persona | 0 | 1 |
| risposta | stato di un terzo | 6 | 12 |
| risposta | nome proprio | 4 | 1 |
| risposta | previsione certa | 0 | 6 |
| risposta | gergo | 1 | 5 |
| risposta | promessa | 1 | 2 |
| risposta | diagnosi | 1 | 2 |
| risposta | sgrammaticato | 0 | 4 |
| risposta | prima persona | 1 | 1 |
| risposta | virgola con la e | 1 | 1 |
| risposta | troppo lunga | 3 | 0 |
| risposta | non nomina la domanda | 0 | 1 |

**Cosa arriva dal modello**, prima e dopo: titoli 18 e 23 su trenta, responsi
12 e 14, compimenti 27 e 25, riformulazioni 30 e 16. **Le riformulazioni
sono scese apposta**: alla prima sonda passavano tutte e trenta, e fra
queste c'erano *"Io vinco la mia causa"*, *"Sono fertile e il mio corpo e'
pronto"*, *"Io sono ora completamente guarita"* a chi non aveva scelto un
genere, *"Io mi prendo cura del mio corpo, della Via Verde, delle erbe e
della natura"*.

### 4.1 Le famiglie trovate leggendo i testi accettati, e chiuse

Sette sonde, ognuna letta per intero prima di cambiare una riga. Ogni
famiglia ha la sua guardia e il suo rosso.

- **La riformulazione**: la via infilata nella frase, l'*Io* in apertura, un
  terzo come soggetto, l'*io* rovesciato in fondo, le promesse sui temi
  delicati. Sui temi delicati Caligo non riscrive e lo dice a video.
- **Il titolo**: che ripete l'intenzione o apre col suo verbo in prima
  persona, *"Ritrovo la salute"*, *"Apro il tuo cuore"*; che decide una
  scelta aperta, *"La tua partenza da Roma"*; che promette un esito,
  *"La tua salute ritrovata"*, *"La tua vittoria in causa"*, *"Il tuo
  guadagno di diecimila euro"*; il verbo fatto nome, *"Il tuo apprendere il
  pianoforte"*.
- **Il responso**: l'intenzione copiata in prima persona; il verbo voltato al
  tu e dato per fatto, *"Trovi una casa con un giardino."*; il gergo e il
  potere del sigillo, *"energia"*, *"manifestare"*, *"sigillo potente"*,
  *"il tuo percorso"*, *"possa"*; *"Esso"* come soggetto, che adesso diventa
  *"Il segno"*.
- **Il compimento**: *"Il tuo liberarti dall'ansia si e' compiuto"*; *"come
  il sigillo aveva predetto"*; *"Che la tua energia fluisca"*; le persone
  cambiate, *"i miei figli"* diventato *"le tue figlie"* a un profilo
  femminile; Caligo che dice *"Sono lieta"*.

---

## 5. I TESTI PASSATI DALLA CONCORDANZA

**Nessuno dei testi di casa porta un genere, quindi nessuna marca**: la
guardia di casa `il_genere_non_si_indovina` li legge tutti col dizionario
DL.06 ad ogni suite, ed e' verde.

- `lib/core/magic/la_voce_del_sigillo.dart`: le tre righe della voce DO.01,
  il perche' del non leggersi, la riga della voce DO.04, la domanda e le tre
  risposte, il titolo e il testo della chiamata, il compimento di casa, la
  riga del lasciato, i due messaggi del limite, **dodici titoli e sei
  responsi di casa**.
- Le schermate: `sigillo_intenzione_screen.dart`, `libro_dei_sigilli_screen.dart`,
  `i_pezzi_del_sigillo.dart`, `il_segno_del_sigillo.dart`: le etichette, le
  righe della carica, la riga dei temi delicati, le due righe di iPhone, gli
  esiti dello sfondo.
- `lib/core/magic/intention_sigil.dart`: la riformulazione di tabella,
  **l'unico testo trovato col genere**, *"mi rendo degno di un legame
  vero"*, che una donna riceveva al maschile. La guardia DL.06 guarda la
  seconda persona e questa frase e' in prima: nessuna prova poteva vederla.
  Adesso e' *"Apro il mio cuore a un legame vero e ricambiato"*. Padre: il
  commit `28628dad` del 29 luglio 2026, la prima stesura del Sigillo come
  terza arte distintiva di Caligo.
- I testi del modello passano dalle guardie con la forma scelta; la
  riformulazione, in prima persona, da `genereDellaPrimaPersona`.

---

## 6. I GUASTI TROVATI, CON IL LORO PADRE

Tutti curati prima della release, ognuno con la guardia vista rossa.

1. **Lo sfondo faceva ripartire l'app.** Impostato lo sfondo, il sistema
   ricalcola i colori del tema (ThemeOverlayController) e ricrea l'attivita':
   col motore legato all'attivita', Flutter ripartiva dalla home, e la persona
   non vedeva nemmeno *"Fatto"*. Visto nel registro del telefono: *got new
   colors* e subito dopo un motore nuovo. Cura: il motore sta nella cache e
   si distrugge solo quando l'attivita' finisce davvero. Padre: questa voce,
   DO.07; nessuna prova al banco poteva vederlo.
2. **Il tasto indietro si perdeva dopo la ricreazione.** Nato dalla cura del
   punto 1: col ritorno di sistema di Android 13 Flutter registra il suo
   ascolto solo quando il framework cambia stato, e l'attivita' ricreata
   nasceva senza. Un indietro chiudeva l'app. Cura: se il motore e'
   ritrovato, l'ascolto si rimette. Padre: DO.07, la prima cura del punto 1.
3. **Il segno spento non si vedeva nelle miniature del Libro**: rosso su una
   scheda rossa, sottile mezzo pixel. Cura: un disco scuro sotto il segno e
   un tratto mai sotto un pixel e mezzo. Padre: DO.06.
4. **Il nome della Via Rossa sulla scheda misurava 3,6 a uno.** Adesso e'
   schiarito, 5,9. Padre: DO.06.
5. **"Caligo non ha risposto" era falso** quando la risposta arrivava e le
   guardie la scartavano. Adesso: *"Caligo non ha trovato una forma migliore:
   la frase resta la tua."* Padre: DO.09.

**Nella suite intera, prima delle cure**, sedici guardie di casa sono
diventate rosse sul codice nuovo: la virgola con la *e*, i catch muti,
l'aptica fuori dalla sua porta, il foglio fuori dal velo, il genere deciso
fuori dalla porta, le misure tipografiche scritte a mano, un'etichetta su
due righe, un testo narrato senza `ParagrafiDiLettura`, il permesso
SET_WALLPAPER senza voce nel registro, il prompt non dichiarato, due
schermate non classificate per la barra, la chiave di iOS e la dipendenza
gal non classificate, l'anteprima del Sigillo. Padre di tutte: le voci di
quest'ordine. **Il debito delle misure tipografiche scritte a mano e' sceso
da 81 a 75**, e il censimento e' rigenerato.

---

## 7. COSA RESTA, DETTO

- **Sul banco i testi del modello non arrivano**: la build di profilo usa il
  fornitore di prova di App Check, e il servizio l'ha respinto (*"Too many
  attempts"*). Sul banco si sono visti i testi di casa; i testi veri li
  provano le sonde. La conferma sulla release sta al punto 8.
- **iPhone non e' stato provato**: questa macchina non costruisce per iOS.
  *"Salva nelle foto"* passa da gal, con la chiave di sola aggiunta; nessuno
  l'ha visto funzionare.
- **La chiamata alla data non si e' vista arrivare**: e' il 15 ottobre. Le
  cinque chiamate sono in coda nel sistema, lette con `dumpsys alarm`.
- **Il limite del Viandante, un sigillo, lo prova la prova**: la Demo sul
  telefono e' al piano piu' alto, e nessun comando dell'app lo cambia. Il
  limite visto a video e' quello di cinque.
- **I responsi dal modello sono circa uno su due**: la guardia dei terzi del
  Viaggio e' stretta, e l'ordine dice di non allentarla. Gli altri sono la
  voce di casa, che nomina l'intenzione.
- **Qualche titolo del modello resta goffo senza essere sbagliato**, *"La tua
  calma prima esami"*: la sonda finale ne ha visto uno su trenta.
- **Regola B non rispettata alla lettera**: le guardie della schermata del
  Sigillo non sono state viste rosse prima di toccarla; sono state riscritte
  sul percorso nuovo e viste rosse dopo.
- **Al risveglio del telefono si mette davanti Clean Master**, un'app di terzi
  installata sul Realme. Non e' stata toccata: si e' usciti col tasto Home.
- **All'accensione dello schermo c'era una richiesta di sicurezza di Google**
  per l'account del fondatore, su una campagna di Google Ads. Non e' stata
  toccata, e il fondatore l'ha chiusa lui.

---

## 8. LA RELEASE SUL TELEFONO

**Build 2263**, sbarramento passato con 5.242 prove e i soli rossi
accettati, installata sul Realme sopra la build di prova, consegnata con App
Distribution: release `2qkl8t1n8lkgg`, un invito accettato, registro da 2262
a 2263. **Il primo sbarramento era caduto per colpa mia**: due frasi con la
virgola prima della *e*, aggiunte all'istruzione del modello dopo la prima
suite senza rifare girare la prova della lingua. Tolte, lo sbarramento e'
ripartito da capo.

Sulla release, **quello che il banco non poteva mostrare**:

- **il compimento dal modello**: portato alla data un sigillo della prova,
  *Si e' compiuto* ha dato *"Hai fatto crescere il tuo lavoro con
  pazienza."*, `21_release_il_compimento_dal_modello.jpg`;
- **la riformulazione dal modello**: *"Voglio ritrovare la calma nelle mie
  giornate"* e' diventata *"Ritrovo la calma nelle mie giornate"*,
  `22_release_la_riformulazione_di_caligo.jpg`;
- **il titolo e il responso dal modello** sul sigillo nuovo: *"La tua calma
  nelle giornate"*, *"Il tuo sigillo custodisce la calma che ritrovi. E' un
  segno per la tua serenita' quotidiana. Il segno veglia sulla tranquillita'
  delle tue giornate."*, `23_release_il_titolo_e_il_responso_dal_modello.jpg`;
- **lo sfondo con la cornice** applicato su entrambe le schermate, *"Fatto:
  il sigillo e' sul tuo telefono."*, `24_release_fatto.jpg`; l'app riaperta
  e' tornata sulla schermata del Sigillo, senza ripartire. La cattura della
  Home e' stata mandata al fondatore a parte, perche' mostra le sue app. Il
  launcher di Realme scurisce lo sfondo, e l'anello sulla Home e' piu' tenue
  che nell'immagine composta.

---

## 9. LA RIGA FINALE

**Il Sigillo dell'Intenzione e' chiuso**, con la build 2263: le cinque
domande hanno la loro risposta a schermo, sul telefono vero. **Restano
aperti, e sono detti al punto 7**: iPhone mai provato, la chiamata alla data
da vedere arrivare il 15 ottobre, e la conferma del fondatore sulla misura
del glifo sullo sfondo, che oltre il 55 per cento cresce solo su sua
parola.
