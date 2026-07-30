# RIPRESA

Chi apre questo file deve poter continuare senza che Mauro racconti niente.

**Aggiornato**: durante V1, ordine LE QUATTRO VOCI DEL CERCHIO.
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

**LA MISURA ADESSO FUNZIONA E IL TEST E' ROSSO.** Questo e' il punto di
partenza per chi riprende: `test/bolla_non_copre_avatar_test.dart` denuncia il
difetto, quindi non va piu' costruita nessuna misura. Va corretto il codice
finche' quel test diventa verde.

**Le due condizioni senza le quali ogni misura era cieca**, trovate dopo sei
tentativi:

1. **L'avatar va precaricato** con `precacheImage`. Senza, non c'e' nessuna
   figura da coprire e ogni misura di occlusione risulta verde per forza. Non
   erano le misure a sbagliare, era la scena a essere vuota.
2. **Serve il testo di sistema ingrandito**, `TextScaler.linear(1.6)`. Con il
   testo a scala uno la bolla non raggiunge la figura nemmeno col margine
   difettoso: il difetto NON si riproduce. A 1,6 compare, perche' `entryZone` si
   misura a runtime e col testo grande la zona d'ingresso cresce e sale a
   mordere la figura. E' la condizione del telefono di Mauro.

**Cosa dice il test adesso**, a scala 1,6 e con margine al sei per cento: tutte e
tre le misure sono rosse. La bolla copre la figura, non ci sono gli otto punti
d'aria, e il trio risalito finisce sotto la striscia dei Doni.

**Cosa resta da fare.** Il layout deve reggere il testo grande. La strada:
`centralH` e `carouselHeight` sono frazioni fisse dell'altezza, quindi non
lasciano spazio quando `entryZone` cresce. Vanno calcolati per DIFFERENZA, cioe'
partendo dallo spazio che resta fra la striscia dei Doni e la zona d'ingresso
misurata, invece che da percentuali dell'altezza totale.

**Le sei strade sbagliate, per non riprovarle.** Sono scritte in testa al file di
test: riquadro del widget, riga della bolla, sei pixel sopra, sessanta pixel
sopra, striscia fra carta e bolla, differenziale a due rese dentro il rettangolo
della carta.

**Gli interruttori di prova** `disegnaIngresso` e `disegnaTrio` su
`SantuarioScreen` esistono per la misura differenziale a tre rese e vanno
tenuti: sono documentati nel loro punto di dichiarazione.

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
