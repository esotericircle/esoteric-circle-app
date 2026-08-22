# ORDINE AU, il manifesto

**LA DEMO CHE NON FA ARRABBIARE.** Quattordici voci, dalla AU.00 alla AU.13,
sul ramo `claude/esoteric-circle-master-order-e798aj`.

**Nasce dai collaudi del fondatore sulle build 2187 e 2188.** Non e' un ordine
di funzioni nuove: e' un ordine di difetti visti a schermo, uno per uno, con
la riga diagnostica o lo screenshot che li prova. Per questo quasi tutte le
voci chiedono una MISURA PRIMA della cura: se il difetto non si misura, la
cura non si puo' verificare, e la voce resta APERTA.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_au_guard_test.dart`
conta sulle righe, e che nessuno puo' scrivere a mano senza che la guardia se
ne accorga.

## Cosa chiude di cio' che era rimasto aperto

L'ordine AT si era chiuso con quattro voci non terminali. Qui l'Architetto
decide su tre di esse:

- **AT.02**, il file di Medora opaco: decisa l'opzione (b), l'alpha si
  ricostruisce dalla luminanza. Diventa AU.01.
- **AT.09**, il peso di Aura fuori tetto: il tetto era troppo stretto e si
  alza. Diventa AU.02.
- **La premessa falsa del corpus D2**: non arriva da fuori, si scrive qui.
  Diventa AU.03.

## Le voci

- **AU.00** Il manifesto prima di tutto. Stato: CHIUSA
  (questo file, nato prima di ogni altra modifica, con la guardia
  `test/ordine_au_guard_test.dart` che pretende zero voci APERTE alla consegna.
  Due cure rispetto alla guardia sorella: il conto delle voci parte da zero
  perche' il manifesto va da AU.00 a AU.13, e il regex delle righe cerca AU)
- **AU.01** Medora, l'alpha dalla luminanza. Stato: CHIUSA
  (**LA RICOSTRUZIONE REGGE LA VERIFICA, e i numeri sono quelli di Aura.** Il
  fondo del file 8 e' nero, quindi la luminanza E' la maschera: gamma 0,75 come
  l'ordine indica, piu' una soglia sotto la quale il fondo diventa trasparente
  netto. Misurato con lo stesso metro usato sugli altri due: **quota di pixel
  quasi trasparenti 100,0 per cento al primo fotogramma e 100,0 all'ultimo**,
  sopra il novanta preteso, e **22,2 per cento al fotogramma dello stacco**,
  cioe' il fondo si vede attraverso, in linea con Aura che ne fa 20,7 e Caligo
  43,6. Peso 2.291.038 byte, dentro il tetto.
  **NON SI E' RIPIEGATO SULL'OPZIONE (c)**, come l'ordine vieta: Medora ha il
  suo filmato.
  **LA MISURA SI FA SUL TEMPO E NON SULL'INDICE**, e la prima stesura e' caduta
  proprio li': chiedere "il fotogramma 49" a un file che ne dichiara 25 non da'
  niente, perche' `libwebp` fonde gli identici. Con `fps=25` il fotogramma
  torna a essere l'istante, e sorgente e derivato danno lo stesso numero)
- **AU.02** Aura torna grande come le altre. Stato: CHIUSA
  (**AURA E' A 720 PER 1280 COME GLI ALTRI DUE, e il tetto nuovo non e'
  servito.** La diagnosi dell'ordine AT, "il peso dipende dal movimento e non
  dalla qualita'", era giusta a meta': **il peso dipendeva dal CANALE ALPHA,
  che `libwebp` comprime SENZA PERDITA anche quando il colore va a perdita**.
  Un alpha con duecentocinquantasei livelli di sfumatura costa piu'
  dell'immagine che accompagna, ed e' per questo che tutta la scala di rimedio
  tentata ieri (qualita' 78, 70, 55, larghezza 600) spostava cosi' poco.
  **Ridotta la maschera a otto gradini**, cioe' otto livelli di trasparenza
  invece di duecentocinquantasei, il peso crolla e nessuno vede la differenza:
  nessuno guarda una stella e conta le sfumature del suo alone.
  **I PESI FINALI: Medora 2.291.038, Caligo 1.075.716, Aura 1.900.416, somma
  5.267.170 byte.** Il tetto nuovo era 3 MB per file e 8,5 in tutto, ma la
  somma sta dentro anche il tetto VECCHIO di 6 MB, quello che aveva costretto
  Aura a rimpicciolirsi. **L'APK cresce di 5.267.170 byte invece dei 6.213.021
  della 2188, e i tre Maestri hanno la stessa dignita'.**
  **UN INCIDENTE, e si dichiara**: due processi di conversione lasciati vivi
  insieme hanno riscritto lo stesso file, e la misura ha letto un Medora da
  6.660.786 byte generato da quello vecchio. Trovato confrontando l'orario del
  file col conto stampato, e rifatto con un processo solo)
- **AU.03** Il corpus si corregge qui. Stato: CHIUSA
  (**TUTTE E VENTITRE' LE CORREZIONI HANNO MORSO**, e il conto dell'ordine non
  torna: l'ordine annuncia diciotto correzioni e poi ne elenca ventitre', cioe'
  DODICI condizioni sotto un titolo che dice dieci piu' UNDICI nomi. Si e'
  applicato l'elenco, che e' il dato, e non il titolo, che e' il riassunto.
  Le scrive `tool/genera_corpus_d2.py`, che CADE se una correzione non trova
  la sua voce: una correzione che non morde e' peggio di una mancante, perche'
  sembra fatta. **GLI EOS NON SI SONO MOSSI**, ricontati sul file nuovo: 165
  gradini, 2.010 per sentiero, 6.030 in tutto.
  **I RISVEGLIATI SONO SETTE, ESATTAMENTE QUELLI CHE L'ORDINE NOMINA, e per un
  poco ne avevo contato uno in piu' a torto.** La riscrittura di `med_51`
  sembrava averlo reso costruibile, e invece lo aveva reso PEGGIO che
  dormiente: "dodici volte hai letto l'Oroscopo mentre la Luna passava nel tuo
  segno" usciva dal generatore con la stessa identica condizione di `med_14`,
  che ne chiede UNA sola, quindi un traguardo dell'anno si sarebbe acceso alla
  prima lettura. **Lo ha trovato una prova che non c'entrava**, quella
  dell'ordine U che vieta due traguardi con la stessa firma, mentre lavoravo
  a tutt'altro. La causa: `FinestraDelCielo` guarda OGGI e non sa contare, e
  una condizione che chiede dodici eventi vuole una memoria per evento che il
  diario non tiene, la stessa che gia' rende dormienti `cal_50` e `aur_46`.
  Adesso il generatore se ne accorge e lo dichiara dormiente col suo perche'.
  **Anche quella regola nuova ha sbagliato alla prima stesura**, e la misura
  l'ha detto: spegneva altri tre traguardi a torto, perche' in "un Oroscopo
  letto in un giorno che porta TRE transiti" il tre descrive il giorno e non
  quante volte, e in "sotto l'ultimo QUARTO di Luna" trovava perfino un
  quattro. Adesso vale solo il numero di "N volte" o quello con cui la frase
  comincia. I dormienti del codice generato passano da 25 a 18, e i 18 che
  restano hanno tutti una ragione vera e dichiarata, non aritmetica.
  **LA LEGGE DELLA FINESTRA sta in tre posti**: nel corpus come dato, nel
  generatore che lo legge, e nella guardia
  `test/la_finestra_e_una_volta_e_mezza_test.dart`, che la ripete apposta
  invece di importarla, perche' una guardia che legge la regola dal posto che
  sorveglia non sorveglia niente.
  **LA GUARDIA ERA VERDE SENZA GUARDARE, due volte.** Prima cercava due cifre
  in condizioni che scrivono il primo numero in lettere, "Tre Oracoli
  nell'arco di 5 giorni", e non ne riconosceva nessuna delle ventiquattro;
  poi il confine di parola era scritto in una stringa non grezza, dove ``
  non e' un confine ma il carattere di ritorno indietro. Adesso ne riconosce
  ventiquattro, e messi tre veleni nel corpus, uno per ciascuna delle tre cose
  che pretende, cade su tutti e tre.
  **UN DIFETTO TROVATO DI PASSAGGIO**: l'intestazione dei tre file generati
  nominava la revisione C mentre il generatore leggeva la D. Adesso il nome
  viene dal percorso vero e non si puo' piu' scollare)
- **AU.04** La mano ferma. Stato: CHIUSA
  (**LE QUATTRO MISURE STANNO INSIEME, ed erano quelle che potevano
  litigare.** M1 sul tavolo: 0,000 punti, zero secco e non "quasi". M2 in mano
  fermo: **0,00 punti col tremore e 0,65 con la mano posata di lato, contro i
  32,8 misurati dal fondatore**. M3 quindici gradi: 62,1 punti sugli 80, sopra
  i 60 pretesi. M4: meta' corsa dopo UN campione, cioe' 66 millesimi, sotto i
  120. Guardia `test/la_mano_ferma_non_muove_il_cielo_test.dart`.
  **IL MODELLO SI E' VERIFICATO SULLA MISURA DEL FONDATORE PRIMA DI TOCCARE IL
  CODICE**: dalla riga diagnostica si risale alla deviazione vera con mano
  ferma, `atanh(0,41) / 5 = 0,0871` g, e rimessa nella formula di ieri quella
  deviazione da' **esattamente 32,8 punti**. E' cosi' che si e' scelta la zona
  morta invece di indovinarla: con lo 0,05 di partenza dell'ordine sarebbero
  restati 1,9 punti, cioe' appena sotto la soglia di 2, e un solo numero di
  margine su una misura sola non basta. Con 0,07 restano 0,9.
  **I TRE PEZZI SONO TUTTI E TRE DENTRO**: zona morta 0,07, sotto la quale il
  cielo non si muove affatto; filtro a un euro al posto del passa-basso fisso,
  che taglia basso quando la mano e' quasi ferma e alto quando il gesto e'
  veloce; curva col quadrato, piatta vicino allo zero e piena a fondo corsa.
  **IL GUADAGNO E' SALITO DA 5 A 34 E NON E' UN GUADAGNO ALZATO**: la
  deviazione ora entra al quadrato e ridotta della zona morta, quindi il
  numero davanti deve crescere perche' la corsa piena resti raggiungibile.
  **IL PASSA-BASSO FISSO E' STATO TOLTO**, non affiancato: tenerne uno dietro
  al filtro adattivo avrebbe rimesso il ritardo appena tolto.
  **I MAESTRI SI SONO MISURATI, non dati per scontati**: il Santuario li muove
  con `depth(0.5)` e `depth(0.28)`, che e' lo stesso `layerOffset`, e siccome
  la loro profondita' e' PIU' ALTA di quella del piano di fondo il tremore li'
  si vedrebbe di piu'. Con la mano ferma il Maestro centrale si sposta al piu'
  di **0,85 pixel** e quelli di lato di 0,72.
  **LO ZERO APPRESO DI AS.01 NON E' STATO TOCCATO** e la sua guardia resta
  verde, come le altre sei prove del cielo, 28 in tutto)
- **AU.05** I Maestri non coprono piu' niente. Stato: CHIUSA
  (**L'IPOTESI DEL FONDATORE ERA GIUSTA, E DUE CURE SU DUE SONO STATE
  MISURATE PRIMA DI SCEGLIERE.** Con la diagnostica `ultimaMisuraDelBusto`,
  messa apposta perche' l'ipotesi si potesse abbattere invece che credere: lo
  spazio concesso al busto e' **188,7 punti su schermo alto, 67,8 sul medio e
  MENO 24,2 sul basso**, mentre il pavimento ne pretendeva 220 comunque. Su
  uno schermo basso il numero e' NEGATIVO: il blocco del cielo e la zona
  d'ingresso insieme occupano gia' piu' di tutta la scena.
  **LA PRIMA CURA FUNZIONAVA ED E' STATA BUTTATA.** Allungava la scena e la
  lasciava scorrere quando lo spazio non concedeva il minimo: zero pixel
  coperti su tutte e tre le misure, busto a 220, e la guardia del 33 per cento
  della carta soddisfatta. Ma una scena piu' alta del viewport spinge i tre
  Maestri sotto il bordo, e **tre file di prove di navigazione sono diventati
  rossi**, `chat_header`, `accents` e `navigation`: il tocco sul busto
  centrale non apriva piu' il dominio, perche' il busto non era piu' a
  schermo. **Una home che per mostrare i Maestri chiede di scorrere non e'
  piu' la home**, e nessuna delle tre prove parlava di questo: e' stata la
  suite intera a dirlo, e solo dopo aver confrontato col ramo di partenza si e'
  saputo che quei rossi erano miei e non preesistenti.
  **ALLORA COMANDA IL VINCOLO**, e il minimo torna a essere un minimo vero,
  150 punti, sotto i quali una figura non si riconosce. **Sullo schermo da cui
  viene la segnalazione, 360 per 797, i pixel di testo coperti passano da
  4.323 a ZERO** e il busto prende 188,7 punti, il quattordici per cento in
  meno di prima.
  **SU MEDIO E BASSO IL CONFLITTO E' STRUTTURALE E SI DICHIARA**: con 67,8 e
  meno 24,2 punti concessi non esiste nessuna altezza del busto che vada bene,
  perche' il posto non c'e'. Li' il difetto non e' nel busto, e' nel blocco
  del cielo, e comprimerlo cambia cio' che si legge: **e' una decisione
  dell'Architetto e non si prende di nascosto dentro un'altra voce**. La
  guardia pretende zero dove lo spazio esiste e altrove pretende che non
  PEGGIORI, coi due numeri scritti.
  **UNA GUARDIA E' STATA RI-MIRATA e non allentata**: quella che pretendeva
  il 33 per cento dello spazio per la carta nasce da un difetto vero, 350
  punti VUOTI sopra la carta. Adesso sopra la carta non avanza piu' niente:
  c'e' il blocco del cielo, che fino a ieri il busto copriva. Pretendere
  ancora quella quota vorrebbe dire pretendere che la carta torni a coprire il
  testo. La regola cambia misura e non forza: la carta deve prendere TUTTO lo
  spazio che il vincolo le concede.
  **UN DIFETTO DELLA PROVA STESSA**: la prima stesura metteva rapporto 3 anche
  su un 720 per 1280, che e' un telefono a rapporto 2, e ne usciva uno schermo
  da 240 punti di larghezza che non esiste.
  **L'ordine di pila non e' stato invertito**, come l'ordine vieta)
- **AU.06** Una festa, un traguardo. Stato: CHIUSA
  (**LA REGOLA NUOVA SOSTITUISCE QUELLA DEL 16 AGOSTO, e le due vietavano cose
  diverse.** Quella di agosto vietava la RAFFICA, cinque scene di fila, e per
  evitarla univa i nomi in una scena sola: e' cosi' che e' nata la card che ne
  nominava cinque con centoventi Eos. Questa vieta i DUE NOMI nella stessa
  card, e la raffica la tiene lontana con la distanza: **una festa per apertura
  dell'app, tre ore di orologio fra due feste**, in
  `lib/core/sigilli/distanza_fra_le_feste.dart`.
  **Chi va per primo**: il piu' importante, cioe' il primo grande se c'e' e a
  parita' il primo per posizione. E' la stessa regola che sceglieva
  l'intensita' della festa unita, quindi la scena resta quella approvata.
  **IL PRIMO SIGILLO IN ASSOLUTO NON ASPETTA NESSUNO**: far attendere tre ore
  il primo premio sarebbe il contrario di cio' che l'ordine chiede.
  **LA CAUSA A MONTE, MISURATA: alla fine dell'onboarding maturano TRE
  gradini**, `med_1` la carta nata, `aur_10` il numero, `aur_19` l'ora esatta.
  Dopo la cura la persona ne vede festeggiare **UNO**, e gli altri due restano
  accesi nel sentiero con i loro Eos gia' accreditati: in attesa c'e' solo la
  festa.
  **UNA PARTE DELL'ORDINE NON E' STATA ESEGUITA ALLA LETTERA, e si dichiara.**
  L'ordine dice che gli altri "chiedono un gesto vero successivo": farlo
  vorrebbe dire cambiare le CONDIZIONI di quei gradini nel corpus, cioe'
  riaprire il file che la voce AU.03 ha appena chiuso, e cambiare quando un
  traguardo matura e' cosa diversa dal cambiare quando si festeggia. L'effetto
  che l'ordine cerca, una sola festa alla fine dell'onboarding, e' ottenuto.
  Se il fondatore vuole proprio che gli altri due NON si accendano, e' una
  correzione al corpus e va detta come tale.
  Guardia `test/una_festa_un_traguardo_test.dart`, che legge la regia e cade se
  qualcuno le ripassa due traguardi nella stessa card)
- **AU.07** La card del traguardo, dignita' e tipografia. Stato: CHIUSA
  (**LA PAROLA DI PREMIO STA SU UNA RIGA SOLA a tutte e tre le misure**: corpo
  32 su schermo largo, 27 sul medio, 23 sullo stretto, una riga sempre.
  **E LA PRIMA CURA NON BASTAVA, e la prova lo ha detto.** Bastava passare la
  parola al componente che gia' esisteva, `TitoloCheNonSiSpezza`, e invece su
  uno schermo da 320 punti restava spezzata lo stesso: quel componente
  scalava il corpo in proporzione, cioe' dava per scontato che dimezzando il
  corpo si dimezzi la larghezza. **Non e' vero quando lo stile porta una
  spaziatura fra le lettere**: quella e' un numero ASSOLUTO e non scala col
  corpo, e su "CONGRATULAZIONI", sedici lettere con 1,6 punti l'una, restano
  venticinque punti fissi che il conto non vedeva. Adesso il componente
  misura, e se non entra scende di un punto e rimisura.
  **LA GERARCHIA SI CALCOLA, non si scrive, e anche questo lo ha detto la
  prova.** Messi tre corpi fissi 34, 28 e 16, su uno schermo da 360 punti la
  parola di premio scendeva a 27 per entrare mentre il nome restava a 28:
  **a video il premio diventava piu' piccolo del nome**. Ora si misura prima
  il corpo con cui la parola entra e gli altri livelli scendono con lei: 27,
  19,4 e 16 sul medio.
  **IL MAIUSCOLO INTEGRALE E' SOLO DELLA PAROLA DI PREMIO.** Il nome arrivava
  in maiuscolo dal CORPUS, che marca cosi' i traguardi grandi, "LA
  COSTELLAZIONE NASCENTE": il dato resta, cambia la resa, e a video si legge
  "La costellazione nascente".
  **"OBIETTIVO RAGGIUNTO IL ..." C'E', e l'istante non e' stato inventato**:
  era gia' nel dato del Sigillo dall'ordine AP, `quandoSiEAcceso`, e nessuno
  lo mostrava. Per i Sigilli accesi prima che il diario tenesse la data la
  riga non compare affatto. La data si legge come la direbbe una persona, "14
  agosto alle 12:00", e l'anno compare solo se non e' quello in corso.
  Gli Eos sono rimasti dove sono. Guardia
  `test/la_parola_di_premio_sta_su_una_riga_test.dart`, sei prove.
  **UN DIFETTO TROVATO DI PASSAGGIO, e vive da due giorni**: la fascia breve
  della celebrazione aveva scritta tutta la regia dello stacco, i due
  interruttori, i due orologi della rete e la funzione del frame 21, **mai
  collegata a niente**. L'analisi lo diceva con due avvisi che nessuno aveva
  letto. Tolta la promessa invece di collegare la transizione: darle un
  secondo filmato vorrebbe dire due transizioni per una festa sola, che e'
  cio' che l'ordine AT voce 06 vieta.
  **Una guardia esistente e' stata RI-MIRATA e non allentata**: "al primo
  momento utile la festa in attesa arriva" restava vera, ma il primo momento
  utile adesso e' un'apertura nuova, perche' se ne vede una per apertura)
- **AU.08** Il grigio che non si legge, censimento totale. Stato: CHIUSA
  (**PERCHE' LE DUE CURE PRECEDENTI NON AVEVANO FUNZIONATO, e la ragione e'
  esattamente quella che l'ordine sospettava.** L'ordine AS voce 05 aveva
  alzato `textMuted` a `0xFFA39D8E` dichiarando "6,59 su Aura" e chiuso la
  voce. **Quel numero era misurato sul fondo sbagliato**: `auraDeep`, il fondo
  profondo della schermata, mentre quei testi stanno sulle CARD, cioe' su
  `auraSurface`, piu' chiara. Sul fondo vero facevano **4,40**, e sul vetro
  delle bolle **4,21**. Ecco perche' il fondatore continuava a non leggerli
  mentre la prova era verde: si misurava il fondo teorico.
  **IL CENSIMENTO ENUMERA: 625 punti del codice dipingono testo**, letti dai
  sorgenti uno per uno col loro ruolo tipografico, il loro colore e la loro
  opacita', per i fondi che quel testo tocca davvero, e fanno 4.926 misure.
  **Sotto la loro soglia erano 487. Adesso sono ZERO.**
  **DUE STESURE DELLA PROVA SONO STATE BUTTATE, e vale la pena dirlo.** La
  prima faceva il prodotto cartesiano di tutti i colori per tutte le opacita'
  trovate in giro: 4.347 righe in cui le peggiori erano "goldDeep all'8 per
  cento", che nel codice non e' un testo ma un'ombra. Un censimento che
  inventa combinazioni non censisce, fa rumore, e nel rumore il difetto vero
  si perde. La seconda misurava l'oro di Medora sul verde di Aura, cioe'
  inventava schermate che non esistono.
  **LE SOGLIE SONO DUE, come l'ordine detta**: 7,0 per i testi piccoli e 4,5
  per i titoli grandi, e il ruolo tipografico si legge dal codice. Senza
  questa distinzione il censimento avrebbe preteso 7,0 anche dall'oro di un
  titolo cerimoniale, e per ottenerlo l'oro andrebbe schiarito fino a non
  essere piu' oro: si curerebbe un difetto rovinando il marchio.
  **LE CORREZIONI SONO TRE.** `textMuted` da `0xFFA39D8E` a `0xFFD8D0BD`, che
  sul peggiore dei fondi veri fa 7,39; `textSecondary` da `0xFFC7C2B4` a
  `0xFFD7D2C2`, perche' faceva 6,68 su Aura; e **cinque punti in cui l'oro
  pieno faceva da testo piccolo** passano all'oro chiaro, che sullo stesso
  fondo passa da 5,47 a 8,06: il Passaporto, l'Oracolo del Giorno, la home,
  le tue arti e le impostazioni. I tre livelli di grigio restano tre.
  Guardia `test/il_censimento_dei_grigi_test.dart`, che cade se un solo punto
  scende sotto la sua soglia e pretende di trovarne almeno cinquanta prima di
  dichiarare qualcosa. Le sette prove di leggibilita' gia' esistenti, 43 in
  tutto, restano verdi)
- **AU.09** Le perle del Loto al centro dei fiori. Stato: CHIUSA
  (**IL CENSIMENTO SMENTISCE IN PARTE LA PREMESSA, e si dichiara.** Misurati
  tutti e centosessantacinque i bersagli dei tre sentieri con un tocco
  esattamente sul proprio centro: **i cinque grandi rispondono su tutti e
  tre**, cioe' le sfere al centro del fiore rispondono. Chi non rispondeva era
  l'opposto: **dieci mini del Loto e quattro della Costellazione**, che
  avevano il proprio centro dentro il raggio di tocco di un grande. Prima:
  costellazione 51 su 55, albero 55, loto 45.
  **LA CAUSA, misurata**: il raggio di tocco di un grande vale 0,029 della
  tela, cioe' 10,4 punti su 360, ma i punti dell'arte stanno anche a tre punti
  l'uno dall'altro. Il grande arrivava a coprire il centro del vicino, e
  toccando quel mini rispondeva lui.
  **LA CURA CHE FUNZIONAVA ERA SBAGLIATA, ed e' la lezione piu' cara di
  quest'ordine.** La prima cura SPOSTAVA i punti perche' nessuno restasse
  sepolto, e dava 55 su 55 su tutti e tre; l'anteprima sembrava integra. Ma i
  punti **non sono liberi: sono le perle DIPINTE nell'arte**, e gli ancoraggi
  si ricavano leggendo le immagini di `brand_assets/sentieri/`. Spostandoli si
  scollavano dal disegno. **Lo ha detto una prova che non stavo guardando**,
  quella che tocca la tela dove l'arte ha la perla e pretende che l'elenco
  vada a quel traguardo: era rossa, e diceva che il codice si era staccato
  dall'immagine. La geometria e' stata rimessa esattamente com'era.
  **LA CURA VERA STA NELLA REGOLA DEL TOCCO**: il raggio di un punto non
  supera mai meta' strada verso il vicino piu' vicino. Nessun punto si muove,
  il codice segue l'arte, e **rispondono 55 su 55 su tutti e tre**.
  **Anche la prova e' stata ri-mirata**: pretendeva che un grande rispondesse
  a meta' del raggio DISEGNATO, ma dove due perle stanno a sei punti quella
  meta' e' gia' casa d'altri, e pretenderlo vorrebbe dire pretendere che il
  vicino non risponda al proprio centro. Adesso chiede meta' del raggio VERO.
  Guardia `test/ogni_perla_risponde_al_suo_centro_test.dart`, sette prove)
- **AU.10** La pila che non torna indietro. Stato: CHIUSA
  (**LA MISURA DEL FONDATORE E' ESATTA AL NUMERO.** Rimesso il codice di prima
  per la prova del veleno: dieci aperture del menu' utente portano la pila da
  1 a **11**, cioe' dieci rotte impilate e dieci tocchi su indietro per tornare
  al principio. Adesso la portano da 1 a 2, e un tocco solo basta.
  **La regola esisteva gia' e non la si e' riscritta**: `apriUnaVoltaSola`,
  dell'ordine AL, spinge solo se quella destinazione non e' gia' viva piu' in
  basso. Il menu' utente e il Calendario non ci passavano perche' **nessuno
  aveva dato loro una destinazione da confrontare**: un dominio porta il suo
  Maestro, loro non hanno argomenti. Adesso ce l'hanno, `PortaDelCerchio`, ed
  e' un valore tipizzato e non una stringa, per la stessa ragione scritta
  allora: una stringa la si puo' scrivere "quasi uguale".
  **LE ROTTE IMPILABILI DALLA BARRA SONO TRE**, e affette erano DUE: il menu'
  utente e il Calendario. Il dominio dei Maestri passava gia' dalla porta
  giusta. Guardia `test/una_porta_aperta_non_si_riapre_test.dart`, che conta la
  pila e sorveglia anche la sorgente: nella barra puo' restare UNA sola spinta
  diretta, quella dentro `apriUnaVoltaSola`)
- **AU.11** Il borsellino si aggiorna ovunque. Stato: CHIUSA
  (**LA PREMESSA DELL'ORDINE NON REGGE ALLA MISURA, e si dichiara invece di
  correggerla in silenzio.** L'ordine dice che la causa e' che "il saldo si
  rilegge solo quando il Passport si monta". Cercato nel codice: **il Passport
  non legge affatto il saldo**, non lo nomina nemmeno; la barra e il
  borsellino ascoltano tutti e due lo stesso `QuestionAllowance`, che e'
  l'unica sorgente; e la lettura all'avvio c'e' gia', la fa il Custode del
  cammino dopo il primo fotogramma.
  **CENSITI I PUNTI CHE LEGGONO IL SALDO: 20, in 9 file**, il piu' carico e'
  la regia del cammino con sette. **Nessuno tiene una copia**: il censimento
  cade se qualcuno se ne fa una.
  **MA IL FATTO DEL FONDATORE E' VERO, e la causa e' un'altra.** Nella
  documentazione di `QuestionAllowance.sincronizza` sta scritto da sempre "si
  chiama all'avvio e al ritorno in primo piano": **la seconda meta' era
  falsa**. Contate le chiamate in tutto `lib`, erano due, tutte e due dentro
  il Custode e tutte e due all'avvio. Se la sincronia dell'avvio non riesce,
  perche' la rete e' lenta nel primo secondo o l'autenticazione non e' ancora
  pronta, **il saldo resta quello locale finche' l'app non viene riavviata**:
  zero in barra con quattrocentoquarantacinque sul server. Adesso l'app
  ascolta il ritorno in primo piano e rifa' la sincronia.
  **LE QUATTRO COSE DELL'ORDINE SONO MISURATE UNA PER UNA sul flusso vero**:
  il saldo arriva con la sola sincronia d'avvio (445 senza visitare niente);
  chi mostra il numero ascolta la stessa sorgente di chi lo aggiorna; un
  accredito cambia la cifra nell'istante in cui il server risponde, senza
  cambiare schermata; e **col server muto resta 445 e non zero**, perche' uno
  zero falso e' peggio di un numero vecchio.
  Guardia `test/il_borsellino_si_aggiorna_ovunque_test.dart`, cinque prove.
  **Un difetto della prova stessa, corretto**: il censimento segnalava
  `ritrovamento.dart` come copia del saldo, ed e' un PARAMETRO con un valore
  di partenza. Un censimento che scambia un parametro per uno stato manda a
  cercare un difetto che non c'e')
- **AU.12** L'Arcano del Giorno, i testi sopra la carta. Stato: CHIUSA
  (**L'IPOTESI E' CADUTA ALLA MISURA, e si dichiara.** L'ordine suppone che il
  testo si sia allungato con la revisione di AS, che adesso nomina gli Arcani
  Maggiori. Contati i caratteri sui due commit: **prima ne aveva 96** ("Il
  cielo di oggi ha una riga per te..."), **dopo ne ha 85**. Si e' ACCORCIATO.
  La causa era piu' vecchia: quella riga viveva in un `Positioned` col solo
  `bottom`, quindi senza nessun vincolo di larghezza, prendeva la propria
  larghezza naturale e lo `Stack` la tagliava. Col testo lungo il difetto
  c'era gia'.
  **E L'ANTEPRIMA HA TROVATO IL DIFETTO VERO, che nessuna misura di rettangoli
  poteva vedere.** Dato il vincolo, la riga smetteva di essere tagliata ai
  lati, cioe' faceva quello che l'ordine chiedeva per primo. Ma nell'immagine
  si vedeva **testo oro sopra il dorso d'ORO della carta**: dentro i bordi e
  illeggibile lo stesso. Un testo che sta nei margini e non si legge e' un
  testo che non c'e'. **Adesso la riga sta SOTTO la carta**, come l'ordine
  dice, "sopra o sotto, mai addosso".
  **La pillola del gesto resta sulla carta, e non e' una svista**: porta il
  proprio fondo e il proprio bordo, quindi si legge sopra qualunque cosa, ed
  e' il gesto: la sua casa e' li'.
  **QUANTI DONI ERANO MALATI: TUTTI E CINQUE.** L'impaginazione e' una sola,
  `ritual_view.dart`, quindi il difetto e la cura valgono per alba, soffio,
  oracolo, rune e notte insieme. Guardia
  `test/i_testi_del_dono_non_stanno_sulla_carta_test.dart`, che pretende anche
  di TROVARE la pillola prima di confrontarla, se no il confronto sarebbe
  contro un meno uno, cioe' verde per non aver trovato niente.
  **Nasce un'anteprima che mancava**: `arcano-prima-del-gesto.png`. Quella che
  c'era arrivava DOPO la rivelazione, quando la riga non c'e' piu': non poteva
  mostrare il difetto, ed e' per questo che nessuno se n'era accorto prima del
  fondatore.
  **Un errore di italiano corretto di passaggio**: "Una carta dei Arcani
  Maggiori" diventa "degli")
- **AU.13** Il tooltip dei tre sentieri. Stato: CHIUSA
  (**TRE COSE E BASTA**, in `lib/features/sigilli/la_mappa_del_sentiero.dart`:
  dove sei, "7 perle accese su 55, nella fascia primi giorni"; cosa manca, con
  le parole del corpus, "Due Riti dell'Alba, nell'arco di 3 giorni"; e da dove
  si comincia, un pulsante toccabile che porta all'arte, "Il Rito dell'Alba".
  Livello visivo prima del testo: il segno del sentiero in oro, e sotto le tre
  righe.
  **NON E' LA BOLLA CHE IL FONDATORE HA FATTO ELIMINARE**, e la differenza e'
  misurata: quella stava in HOME e arrivava senza che nessuno la chiedesse,
  questa sta DENTRO il sentiero e compare una volta sola al primo ingresso,
  poi solo dal punto interrogativo in alto a destra. Il conto e' PER SENTIERO:
  averla vista nel Loto non la spegne nell'Albero.
  **LA PORTA DELL'ARTE E' TOCCABILE, e nel corpus era solo testo.** Il
  traguardo dichiara "L'Estrazione delle Rune" come stringa, e una stringa non
  si tocca: qui il gesto della condizione, letto dalla sua firma, diventa la
  via che lo compie. Provati tutti e centosessantacinque i traguardi: **zero
  senza una porta da nominare**, perche' quando un gesto non ha una via propria
  si va alla casa del suo Maestro. Mai un vicolo cieco.
  **UN DETTAGLIO CHE SAREBBE DIVENTATO UN DIFETTO**: "presenza" nella firma di
  una finestra del cielo non e' un gesto, e' il modo di dire che basta esserci
  quel giorno; lasciarlo passare faceva cercare un'arte che non esiste.
  **LE NOVE ANTEPRIME DEI SENTIERI SONO STATE PROTETTE**: la mappa compare da
  sola al primo ingresso e le avrebbe coperte tutte, quindi quelle catture
  dichiarano di esserci gia' state. La mappa ha la sua, `mappa-del-sentiero.png`,
  **guardata e non solo generata**.
  Guardia `test/la_mappa_del_sentiero_test.dart`, sei prove, che pretende anche
  che i testi nel foglio siano AL PIU' TRE: un aiuto che diventa un elenco
  smette di aiutare)

## I marcatori

VOCI_TOTALI: 14
VOCI_APERTE: 0
VOCI_CHIUSE: 14
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
