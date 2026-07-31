# RIPRESA

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
