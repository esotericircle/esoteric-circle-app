# ORDINE AT, il manifesto

**LE TRE TRANSIZIONI DI STELLE.** Undici voci, dalla AT.00 alla AT.10, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

**SOSTITUISCE INTEGRALMENTE la voce AS.02**, che resta FERMATA SU DECISIONE DEL
FONDATORE: tutto il lavoro fatto o previsto sulle feste dei traguardi va
demolito, non adattato.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_at_guard_test.dart`
conta sulle righe.

## L'avvertenza di metodo, riportata come l'ordine chiede

Il ramo non e' sul remoto perche' il push non passa, quindi l'Architetto NON ha
potuto leggere il codice dell'ordine AS. Cio' che riguarda file toccati da AS
e' dichiarato IPOTESI e va misurato. Cio' che viene dalle misure del fondatore
e' fatto.

## I fatti, rifatti qui

- **F1 CONFERMATO.** In `transition/` ci sono `Star-Transition-8.mov`, `9` e
  `10`, piu' i due archivi zip sorgente.
- **F3 CONFERMATO al byte.** 132.336.243, 136.640.302 e 142.754.571.
- **I2 ABBATTUTA, ed e' la scoperta piu' importante di questa apertura.**
  L'ipotesi era che i `.mov` non fossero tracciati da git. **Lo sono, e non
  solo: sono gia' DENTRO TRE COMMIT**, `64eef3c3` (AS.08), `f24e7a10` (AS.09)
  e `9c50242d` (AS.10). Sono 411 MB di video entrati nella storia, e sono la
  causa del push che non passa: vedi la voce AT.01.

## Le premesse dell'ordine, e una che cade

- **P1 ABBATTUTA da F2**, come l'ordine stesso dichiara: `pix_fmt=argb`, il
  canale alpha esiste.
- **P2 DA VERIFICARE con una prova reale**, non con la documentazione: si
  carica il file convertito con `ui.instantiateImageCodec` e si pretende
  `frameCount` uguale a 50 e alpha minore di 255 nel primo fotogramma.
- **UNA PREMESSA DELLE REGOLE DI CASA E' FALSA, e si dichiara invece di
  aggirarla.** L'ordine dice che il corpus di riferimento e'
  `Traguardi_165_Revisione_D2.json`. **Quel file non esiste sul disco**:
  `docs/corpus/` contiene B, C e D. Il corpus vivo resta la revisione D finche'
  la D2 non arriva, e le sette condizioni impossibili che la D2 doveva
  correggere restano dichiarate dormienti come nell'ordine AS voce 12.

## Le voci

- **AT.00** Il manifesto prima di tutto. Stato: CHIUSA
  (questo file, nato prima di ogni altra modifica, con la guardia che pretende
  zero voci APERTE alla consegna)
- **AT.01** Igiene del repository. Stato: CHIUSA
  (**L'IPOTESI I2 E' ABBATTUTA, E LA MISURA E' PEGGIORE DELL'IPOTESI.**
  `git ls-files transition/` elencava tutti e tre i `.mov`, e `git log` diceva
  che erano gia' DENTRO TRE COMMIT: `64eef3c3` (AS.08), `f24e7a10` (AS.09) e
  `9c50242d` (AS.10). Quattrocentoundici megabyte di video entrati nella storia
  con un `git add -A`.
  **E' LA CAUSA DEL PUSH CHE NON PASSAVA**, e la sessione precedente aveva
  sbagliato bersaglio: si era dato la colpa alla mole del repository e alle
  anteprime, e si era riprovato per ore cambiando trasporto, buffer e
  compattazione. Non era la rete e non erano le credenziali: erano
  quattrocento megabyte da trasferire in tre commit.
  **La cura in quattro passi, con l'output nel rapporto**: `git rm --cached -r
  transition/`, la riga `transition/` in `.gitignore`, e poi la riscrittura dei
  commit non spinti con `git filter-branch --index-filter`, perche' togliere i
  file dall'indice non li toglie dalla storia. I commit riscritti non erano mai
  stati pubblicati, quindi non si e' toccato niente che altri avessero visto:
  otto commit, messaggi e granularita' intatti.
  **VERIFICATO**: `git log 620db435..HEAD -- transition/` non trova piu' niente,
  e **il push e' passato**, `620db435..a608cdcb`. L'ordine AS intero e' adesso
  sul remoto.)
- **AT.02** Conversione dei tre video in WebP animati. Stato: FERMATA SU PREMESSA FALSA
  (**LA CONVERSIONE E' RIUSCITA, E TRE MISURE SU QUATTRO DICONO DI NO.**
  I tre file esistono, Flutter li apre e la loro durata e' 2000 millesimi
  ESATTI in tutti e tre: la premessa P2 e' VERA, Flutter decodifica il WebP
  animato con alpha.
  **1. IL FILE DI MEDORA E' OPACO, ed e' il fatto che ferma la voce.**
  `Star-Transition-8.mov` ha alpha 255 su tutti i fotogrammi, misurato sul
  SORGENTE con `alphaextract` prima ancora di convertire: ai fotogrammi 0, 10,
  25 e 49 l'alpha medio vale 255, 255, 255, 255, mentre il 9 fa 0, 0, 236, 0 e
  il 10 fa 0, 9, 233, 0. **Il fatto F2 e' vero sui parametri e falso sul
  contenuto**: `pix_fmt=argb` c'e', ma quel canale non e' usato, e i tre file
  NON sono identici fra loro come l'ordine dichiarava. La sua transizione
  coprirebbe lo schermo per due secondi interi e al frame 21 non si vedrebbe
  niente sotto: la regia della voce 05 sarebbe invisibile per un Maestro su
  tre.
  **La via c'e', e la decisione e' dell'Architetto**: il file 8 ha fondo NERO
  (luminanza media 0, 0, 210, 0 agli stessi fotogrammi), quindi l'alpha si puo'
  RICOSTRUIRE dalla luminanza con `alphamerge`. Provato: il file esce a
  7.258.986 byte a 720 e qualita' 78, quindi andrebbe tarato. **Le tre
  opzioni**: (a) arriva un sorgente nuovo per Medora; (b) si ricostruisce
  l'alpha dalla luminanza, con la resa che cambia perche' le stelle sfumano coi
  loro stessi grigi; (c) Medora usa uno dei due file buoni, e due Maestri
  condividono la transizione. Non si sceglie da soli.
  **2. `frameCount` NON E' 50**: vale 40 per medora, 25 per caligo, 39 per
  aura. La causa e' `libwebp`, che FONDE i fotogrammi identici invece di
  ripeterli: i chunk `ANMF` portano durate di 40, 80 e 160 millesimi e la somma
  fa 2000 esatti in tutti e tre. **Nessun contenuto e' perso**, e la regia
  della voce 05 lavora sul TEMPO e non sull'indice, quindi il frame 21 resta
  l'istante 800. Ma il vincolo dell'ordine dice 50, e 50 non e'.
  **3. IL PESO DI AURA E' FUORI**: 2.706.460 byte contro il tetto di 2.000.000,
  e la somma fa 6.212.554 contro 6.000.000. La scala di rimedio dell'ordine e'
  stata percorsa tutta: 3.804.052 a qualita' 78 e 720 di larghezza, 3.520.664 a
  qualita' 70, 2.706.460 a 600 di larghezza, che e' il limite sotto il quale
  l'ordine vieta di scendere. Provato anche a qualita' 55, per sapere: 2.512.974,
  cioe' il peso e' dominato dalla quantita' di movimento e non dalla qualita'
  del fotogramma.
  Pesi finali dichiarati: medora **1.515.670**, caligo **1.990.424**, aura
  **2.706.460**. Guardia `test/il_webp_animato_si_decodifica_test.dart`, che
  misura peso, `frameCount`, durata e alpha di ciascuno e **dichiara** che
  medora e' opaco: il giorno che arriva un sorgente nuovo quella riga cade e
  qualcuno se ne accorge)
- **AT.03** Demolizione dell'apparato precedente. Stato: CHIUSA
  (**DEMOLITO, non disattivato con un interruttore.** Sono spariti dal
  repository: `direzione_della_festa.dart` con la sua enumerazione di direzioni
  e materie, `pittore_della_festa.dart` con le particelle,
  `tool/anteprime_delle_feste.dart`, i richiami dentro `celebrazione.dart` sia
  nella scena grande sia nella fascia breve, le nove anteprime
  `festa_<maestro>_<tempo>.png` piu' `festa_unita_tre.png`, e cinque prove che
  sorvegliavano quell'apparato.
  **MUORE LA PIOGGIA DI RUNE DI CALIGO dell'ordine V**, che era una decisione
  di Mauro del 15 agosto 2026: viene sostituita dalle transizioni, e sta
  scritto nel commit e qui invece di sparire in silenzio. Con lei muoiono le
  stelle dal centro di Medora e il polline dal basso di Aura.
  **Cio' che NON e' morto, e il perche'.** La risposta "di chi e' la festa
  quando i traguardi sono piu' di uno" viveva dentro il file demolito ma serve
  ancora, perche' decide quale transizione parte: rinasce come
  `MaestroDellaFesta` dentro il lettore nuovo, con la stessa regola dell'ordine
  AO voce 05.
  **CRITERIO DI CHIUSURA VERIFICATO**: `direzione_della_festa` non compare piu'
  in nessun file; `PittoreDellaFesta` e `FesteDeiMaestri` nemmeno.
  **I glifi `spa_rounded` e `local_florist` erano gia' usciti dalle feste con
  l'ordine AQ voce 02, ma erano rimasti nel Passaporto**, dove facevano lo
  stesso danno: `spa_rounded` E' un fiore di loto, quindi l'Albero e il Loto
  portavano lo stesso fiore. Adesso il Passaporto usa i tre segni disegnati da
  noi. Restano nel solo `art_catalog.dart`, dove sono le icone della
  Meditazione e dei Chakra e non c'entrano col Cammino)
- **AT.04** Il lettore di transizione. Stato: FERMATA IN ATTESA DI DECISIONE
  (il componente `lib/features/sigilli/transizione_di_stelle.dart` e' scritto
  come l'ordine prescrive, e ogni vincolo e' sorvegliato da una riga:
  `ui.instantiateImageCodec`, un Ticker nostro a venticinque fotogrammi,
  `getNextFrame` un fotogramma per volta, **mai una `List<ui.Image>`**, mai
  `Image.asset`, il fotogramma corrente dipinto a schermo intero da un
  `CustomPainter` **senza `MaskFilter` ne' shader**.
  **L'indice nasce dal TEMPO e non dal conto dei tick**: `(millesimi /
  40).floor()` limitato a 0..49, cosi' un fotogramma saltato non fa scivolare
  la sequenza e il frame 21 resta l'istante 800 anche coi fotogrammi fusi da
  `libwebp`.
  **La memoria si misura, non si promette**: al massimo due immagini vive in un
  istante, e un contatore lo rende verificabile. Dopo lo smontaggio della scena
  il contatore torna a ZERO, misurato dalla guardia.
  **Resta FERMATA perche' M4 e M5 vogliono un dispositivo**: quanti fotogrammi
  si dipingano davvero sui cinquanta attesi, e il picco di memoria da DevTools,
  li chiude il collaudo del fondatore)
- **AT.05** La regia e il frame 21. Stato: CHIUSA
  (la transizione parte quando la scena viene montata e copre lo schermo; la
  scheda e' INVISIBILE fino allo stacco e compare **di colpo**, senza
  dissolvenza ne' scala ne' rimbalzo, perche' e' il lampo della stella a
  coprire il taglio. Si nasconde con `Visibility` e non con un'opacita' a zero,
  che sarebbe una dissolvenza che comincia; `maintainSize` tiene l'ingombro,
  cosi' quando compare non salta niente. Dal frame 21 al 50 le stelle
  continuano sopra la scheda, e finita la corsa il lettore si smonta.
  **UNA PROVA HA TROVATO UN VICOLO CIECO, ed e' la cosa piu' importante di
  questa voce**: se il filmato non si apre, il frame 21 non arriva mai e la
  scheda resta invisibile **per sempre**, cioe' una festa che non mostra il
  traguardo. Succede davvero nelle prove, dove il codec non si apre. Adesso due
  orologi fanno da rete: uno scopre la scheda agli 800 millesimi comunque,
  l'altro chiude la transizione ai 2000. Quando tutto va bene il lettore arriva
  sempre per primo e la rete non guida niente.
  Guardia `test/lo_stacco_arriva_al_frame_21_test.dart`, che monta la scena
  vera dei tre sentieri. **La prima stesura misurava la cosa sbagliata**:
  contava i widget con `find.text` e li trovava anche a 400 millesimi, perche'
  la scheda E' nell'albero, tenuta li' da `maintainSize`. Adesso legge lo stato
  vero, `Visibility.visible`)
- **AT.06** Una festa, un traguardo. Stato: CHIUSA
  (**il lettore non viene mai montato due volte insieme**, e lo garantiscono
  due cose misurate: il catenaccio `FesteInCorso`, che esisteva gia' e rifiuta
  una festa se una e' a schermo, e il fatto che **un solo punto in tutto `lib`
  monta il lettore**, contato dalla guardia.
  **IL CONFINE CON L'ORDINE AU E' RISPETTATO e dichiarato**: la coda dei
  traguardi in attesa, la distanza fra due feste e la regola che i gradini
  dell'identita' non maturino in blocco restano materia della voce AU.03, e
  questo ordine non le tocca)
- **AT.07** Cosa compare al frame 21. Stato: CHIUSA
  (al frame 21 compaiono INSIEME, nello stesso fotogramma, l'immagine del
  traguardo e la parola di premio **CONGRATULAZIONI**, sopra ogni altro testo.
  Sta dentro la scheda invisibile, quindi non puo' comparire prima nemmeno per
  sbaglio, e la guardia lo pretende guardando dove sta nel sorgente. Durante i
  primi venti fotogrammi lo schermo e' solo stelle.
  **IL CONFINE CON L'ORDINE AU E' RISPETTATO**: il contenuto della card, cioe'
  il nome, la descrizione, la riga dell'ora e gli Eos, e' materia della voce
  AU.04. Qui si e' deciso soltanto QUANDO quel contenuto entra in scena)
- **AT.08** Assegnazione per Maestro. Stato: FERMATA IN ATTESA DI DECISIONE
  (l'assegnazione e' scritta ed e' quella dell'ordine: `stella_medora.webp` ai
  traguardi di Medora, `stella_caligo.webp` a quelli di Caligo,
  `stella_aura.webp` a quelli di Aura, e un traguardo senza dominio usa quello
  di Medora. La guardia verifica che i tre filmati esistano e siano diversi fra
  loro, e nessuna altra differenza e' stata aggiunta.
  **Resta fermata per una ragione sola, che viene dalla voce 02**: il filmato
  di Medora e' OPACO, quindi per un Maestro su tre l'assegnazione oggi
  produrrebbe uno schermo coperto per due secondi. Si chiude quando
  l'Architetto sceglie fra le tre opzioni)
- **AT.09** Misure di accettazione. Stato: FERMATA IN ATTESA DI DECISIONE
  (**M1, misurata**: i tre WebP pesano 1.515.670, 1.990.424 e 2.706.460 byte,
  in tutto 6.212.554. L'APK passa da 161.176.931 byte (la 2187) a quello
  dichiarato nel rapporto: la differenza e' il peso dei tre filmati meno le
  particelle e le dieci anteprime demolite.
  **M2, misurata con `ui.instantiateImageCodec`**: `frameCount` vale 40, 25 e
  39, non 50, perche' `libwebp` fonde i fotogrammi identici. La durata totale
  e' 2000 millesimi esatti in tutti e tre, e la regia lavora sul tempo.
  **M3, M4 e M5 NON SONO STATE MISURATE**, e l'ordine prevede questo caso:
  `adb devices` risponde vuoto e l'emulatore muore su `Android Emulator
  hypervisor driver is not installed on this machine`, verificato di nuovo
  oggi con `-accel-check`. Non si inventano numeri da una prova a tavolino.
  **Quello che si e' potuto misurare senza dispositivo**, e che riguarda M5:
  il lettore tiene al massimo DUE immagini vive in un istante, e dopo lo
  smontaggio della scena il contatore torna a zero, misurato dalla guardia. Il
  picco vero in megabyte lo dira' DevTools sul telefono)
- **AT.10** Fallback, solo se misurato. Stato: CHIUSA
  (**il fallback NON serve, perche' P2 non e' caduta.** La voce dice "se e solo
  se P2 cade": misurato con `ui.instantiateImageCodec` sui tre file veri,
  Flutter APRE il WebP animato, restituisce i fotogrammi uno per uno con la
  loro durata e somma 2000 millesimi esatti. La sequenza APNG non si propone e
  non si improvvisa niente.
  **Cio' che di P2 non torna e' il conteggio, non la decodifica**, ed e'
  riportato nella voce 02: `frameCount` vale 40, 25 e 39 perche' `libwebp`
  fonde i fotogrammi identici. Non e' un fallimento della decodifica e non
  cambia cosa si vede, quindi non fa scattare questa voce)

## I marcatori, contati sulle righe

VOCI_TOTALI: 11
VOCI_APERTE: 0
VOCI_CHIUSE: 7
VOCI_FERMATE_SU_PREMESSA_FALSA: 1
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 3
