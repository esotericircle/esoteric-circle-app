# ORDINE AC. IL JOURNAL SI ACCENDE, LA FESTA SI CALMA, L'IDENTITA' SI COMPLETA

Dodici voci, da AC.01 a AC.12. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse scritte dall'Architetto sulla testa `1b214383`.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Gli stati ammessi sono quattro:

- **CHIUSA**, il lavoro e' finito e provato;
- **FERMATA SU PREMESSA FALSA**, la voce chiedeva di correggere qualcosa che
  misurato non risulta;
- **FERMATA IN ATTESA DI DECISIONE**, il lavoro di Code e' finito e resta solo
  una scelta di Mauro;
- **APERTA**, e finche' una riga e' aperta la guardia
  `test/ordine_ac_guard_test.dart` resta rossa.

**Le voci non si rinumerano, non si accorpano e non si dichiarano coperte da
un'altra.** I marcatori in fondo si contano sulle righe, non si scrivono a
memoria: la guardia cade se dicono un numero diverso da quello che le righe
portano.

**Le voci si prendono due o tre alla volta, nell'ordine delle sezioni**, e a ogni
gruppo chiuso questo file si aggiorna e si riporta. Non si apre il gruppo
successivo con il precedente non riconciliato.

## Le premesse, e quando si abbattono

Ogni premessa si verifica prima di eseguire la voce che la usa, non tutte
all'inizio: una premessa verificata due giorni prima di essere usata e' una
premessa vecchia.

**Gruppo della Sezione A, verificate il 16 agosto 2026 sulla testa `1b214383`:**

1. **P1 VERA.** `lib/features/sigilli/journal_dall_arte.dart` riga 46 dice
   `static const bool acceso = false;`.
2. **P2 VERA, e le due dichiarazioni opposte sono queste.** Il commento sopra
   l'interruttore, righe 31 e seguenti, dice che a cinquantacinque accesi il
   disegno non arriva in fondo perche' chiede un tracciato di qualche migliaio di
   rettangoli disgiunti. Il commento dentro `PittoreDelleLuci.paint`, righe 208 e
   216, dice che le forme si uniscono in due tracciati e che restano al massimo
   cinquantacinque riquadri, "non i migliaia di rettangoli che nell'ordine T
   avevano messo in ginocchio l'anteprima". Quale delle due valga oggi lo dice la
   misura chiesta dalla voce AC.01, non questa riga.
3. **P3 VERA.** In `docs/preview` ci sono nove anteprime dei Journal, contate.
4. **P4 VERA.** `lib/features/sigilli/sentiero_screen.dart` dichiara
   `quotaDelDisegno = 0.58` alla riga 84 e la usa alla riga 220 come
   `vincoli.maxHeight * quotaDelDisegno`.
5. **P5 VERA.** `lib/features/sigilli/pittore_della_festa.dart` costruisce un
   solo `math.Random`.

**La premessa della AC.02 e' caduta MISURANDO, il 16 agosto 2026.** La P4 e' vera
alla lettera, ma la misura da cui la voce nasce era presa sulle ANTEPRIME, che
compongono la scena con una quota di 0,73, mentre la schermata vera usa 0,58 e
una larghezza ridotta dai margini. Misurato sul riquadro vero, 328 per 429,8
punti: l'arte entra per ALTEZZA su tutti e tre i sentieri, quindi il vuoto sopra
e sotto e' **zero**, e cio' che avanza sta ai LATI, il 12,8 per cento sulla
Costellazione e il 26,3 sull'Albero e sul Loto. La guardia sta in
`test/l_arte_riempie_il_riquadro_test.dart`.

**Gruppi successivi:** le premesse da P6 a P12 si verificano quando si apre il
gruppo che le usa, e il loro esito si scrive qui allora.

## AC.01b, il blocco da aprire per PRIMO alla prossima sessione

**La AC.01a e' fatta e misurata**, e i tre sentieri stanno dentro il tetto dei
cento millesimi: Costellazione 18,80, Albero 19,68, Loto 25,82, contro i 71,89,
100,39 e 287,60 di prima. La causa vera era nelle cinquantacinque sottrazioni
booleane, non nei migliaia di rettangoli, che a 2,8 millesimi erano innocenti.

**Resta l'accensione, e si apre da fermo perche' e' la prima volta che quel ramo
arriva a una persona.** Contiene sei cose e nessuna in piu':

- **a)** `ArteDelSentiero.acceso` passa a `true`, **per tutti e tre insieme**.
  Nessun interruttore per sentiero: i tre numeri stanno dentro il tetto, quel
  lavoro non serve piu' e la costante unica resta unica.
- **b)** **Il commento sopra l'interruttore si RISCRIVE**, perche' adesso siamo
  nel caso 2. Dice tre cose: qual era la causa vera, cioe' le sottrazioni
  booleane e non i rettangoli; come e' stata tolta, cioe' il complemento
  calcolato per righe; quale tetto sorveglia adesso quel ramo, coi tre numeri.
  Il vecchio non si tiene accanto al nuovo, si sostituisce.
- **c)** **Il generatore delle nove immagini**, col criterio della P.27: una
  anteprima si monta come e' montato cio' che prova. Non la schermata nuda ma
  quella vera, dentro la sua soglia, con la barra, l'elenco sotto e il comando
  del tocco, alla larghezza reale. Tre sentieri per due, dodici e cinquantacinque
  accesi.
- **d)** **Dentro quelle stesse immagini si vedono le bande laterali della
  AC.02**, il 6,4 per cento per lato sulla Costellazione e il 13,1 su Albero e
  Loto. Si portano, non si correggono: la decisione e' di Mauro e si prende
  guardando.
- **e)** La guardia `il_journal_arriva_in_fondo_test.dart` resta e sorveglia il
  tetto con l'interruttore acceso: da quel momento cade se qualcuno appesantisce
  il disegno, che e' il verso giusto per una guardia.
- **f)** La voce si dichiara CHIUSA **solo dopo** che Mauro ha guardato le nove.
  Fino ad allora resta FERMATA IN ATTESA DI DECISIONE, che e' lo stato giusto e
  non una formalita'.

## Le dodici voci

- **AC.01** L'interruttore dei Journal dall'arte si accende — FERMATA IN ATTESA DI DECISIONE
- **AC.02** Il vuoto sotto l'arte sparisce — FERMATA SU PREMESSA FALSA
- **AC.03** Le particelle della festa smettono di saltare — CHIUSA
- **AC.04** Mai due celebrazioni di seguito — APERTA
- **AC.05** Nessun traguardo celebra due volte — APERTA
- **AC.06** Tre pezzi dell'identita' diventano gesti — APERTA
- **AC.07** Tre traguardi nuovi, coi testi gia' scritti — APERTA
- **AC.08** L'icona degli Eos diventa la moneta — APERTA
- **AC.09** L'attribuzione cieca di Caligo — APERTA
- **AC.10** Le due cricchette, T.02 e U.02 — APERTA
- **AC.11** La Costellazione illeggibile a dodici accesi — APERTA
- **AC.12** Il manifesto e il rapporto — APERTA

## I marcatori, contati sulle righe

VOCI_TOTALI: 12
VOCI_APERTE: 9
VOCI_CHIUSE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 1
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
