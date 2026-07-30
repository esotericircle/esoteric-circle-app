# RIPRESA

Chi apre questo file deve poter continuare senza che Mauro racconti niente.

**Aggiornato**: dopo W1, ordine LA LARGHEZZA GIUSTA.
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
