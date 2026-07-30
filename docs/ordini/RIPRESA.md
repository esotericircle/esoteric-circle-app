# RIPRESA

Chi apre questo file deve poter continuare senza che Mauro racconti niente.

**Aggiornato**: durante V1, ordine LE QUATTRO VOCI E IL LIVELLO SENSORIALE.
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

- [~] **V1** la bolla e l'avatar. **Il codice e' corretto, la MISURA no.**
      Vedi la sezione dedicata qui sotto: e' la cosa piu' importante di questo
      file.
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
- [ ] **S1** il motore audio reale dietro `TonePlayer`, UNA dipendenza sola.
      Oggi `SilentTonePlayer` genera i byte e li scarta, e nel pubspec non c'e'
      nessuna dipendenza di riproduzione: c'e' `record`, che registra soltanto.
- [ ] **S2** l'aptica, quattro schemi in un punto solo. Sono **17 chiamate
      dirette a `HapticFeedback` in 7 file** da ricondurre: animal_journey,
      rune_draw_screen, chat_composer, maestro_reveal_screen,
      natal_chart_reveal, sunset_rune_screen, stesa_senses.
- [ ] **S3** i cinque suoni, slot predisposti e ripiego silenzioso. L'elenco dei
      file che Mauro deve fornire e' gia' scritto in cima a
      `docs/ordini/ESITO_SENSORIALE.md`.
- [ ] **S4** transizioni, versione semplice DICHIARATA: una sola, la carta del
      Maestro verso il suo dominio.
- [ ] **S5** l'interruttore unico Suono e Vibrazione nelle Impostazioni. Oggi
      `SettingsController` ha solo `reduceAnimations`, `simpleMode` e
      `subtitles`.

## V1, lo stato esatto: leggere prima di toccare

**Cosa e' stato corretto nel codice.** In `santuario_screen.dart` il margine fra
il carosello e la zona d'ingresso e' passato dal due al sei per cento
dell'altezza (`carouselBottom = entryBottom + entryZone + h * 0.06`, riga 332).
Il trio risale e la bolla scende.

**Cosa NON e' stato provato, ed e' il punto.** Il test
`test/bolla_non_copre_avatar_test.dart` misura per immagine, come l'ordine
chiede, ma **oggi e' cieco**: con la prova di vista, cioe' rimettendo il margine
difettoso al due per cento, il test resta VERDE. Quindi non denuncia il difetto
che deve denunciare, e il suo verde non vale come prova. La nota sta anche in
testa a quel file.

**Perche' e' cieco, cioe' la diagnosi che non va rifatta da zero.** Tre tentativi
in fila, ognuno con la sua scoperta:

1. Partendo dalla riga esatta della cima della bolla si trova subito il bordo
   oro della bolla stessa: distanza sempre zero.
2. Partendo sei pixel sopra si trova l'ombra del pulsante, che dipinge FUORI dal
   proprio rettangolo: distanza sempre due punti, identica qualunque cosa si
   spostasse. E' il segnale che ha smascherato il tentativo.
3. Partendo sessanta pixel sopra si salta l'ombra ma anche la zona dove il
   contatto avviene, quindi il test passa sempre.

**Le due strade da provare**, in ordine di promessa:

- Isolare la figura per COLORE invece che per luminosita': la figura dei Maestri
  ha carnati e tessuti, il pulsante ha il blu di Medora e l'oro. Un filtro sulla
  tinta distingue i due dove la luminosita' non ce la fa.
- Fotografare la sola striscia fra il fondo della carta, che si legge dal
  riquadro del carosello, e la cima della bolla: dentro quella striscia
  qualunque pixel dipinto e' un difetto, senza bisogno di riconoscere cosa sia.

La seconda e' piu' semplice e probabilmente basta.

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
