# RIPRESA

Chi apre questo file deve poter continuare senza che Mauro racconti niente.
Si aggiorna a ogni voce chiusa.

**Aggiornato**: inizio dell'ordine LE QUATTRO VOCI E IL LIVELLO SENSORIALE.
**Ultimo commit**: `f81a6d4`, spinto.
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

Quattro voci piu' cinque del livello sensoriale.

- [ ] **V1** la bolla non copre l'avatar, il trio risale. Misura sull'area
      DIPINTA, non sul riquadro del widget. Due altezze: 2532 e 2392.
- [ ] **V2** la mano, quarta stesura, BIANCA. Sospetto da verificare per primo:
      nel painter c'e' `Colors.white` e a schermo esce oro, quindi la mano che
      si vede potrebbe non essere quella corretta.
- [ ] **V3** il componente che non taglia le immagini, portato ovunque.
- [ ] **V4** ScrollReveal: sfasare, allungare, abbassare l'opacita' iniziale.
      NON alzare l'ampiezza: gia' provato, a 22 px il tocco colpisce la voce
      sbagliata.
- [ ] **S1** il motore audio reale dietro `TonePlayer`, una dipendenza sola.
- [ ] **S2** l'aptica, quattro schemi, 17 chiamate dirette da ricondurre.
- [ ] **S3** i cinque suoni, slot predisposti e ripiego silenzioso.
- [ ] **S4** transizioni, versione semplice dichiarata: una sola.
- [ ] **S5** l'interruttore unico Suono e Vibrazione.

## Da dove ripartire

Dalla prima voce non spuntata qui sopra. La stima e' gia' dichiarata in
`docs/ordini/ESITO_SENSORIALE.md`, non va rifatta.

## Cose sapute che fanno perdere tempo se si riscoprono

- La specifica del Livello Sensoriale sta nel Project di Claude e NON e' nel
  filesystem: si lavora sul perimetro dell'ordine.
- Nel pubspec non c'e' nessuna dipendenza di riproduzione audio. C'e' `record`,
  che registra soltanto.
- I file sorgente sono a fine riga CRLF: le sostituzioni con Python vanno fatte
  normalizzando prima e ripristinando dopo.
- Gli apici dentro le stringhe Dart si rompono se scritti da un heredoc bash.
  Meglio lo strumento di scrittura file.
