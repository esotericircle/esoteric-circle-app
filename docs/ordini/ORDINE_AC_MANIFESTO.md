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

**Gruppi successivi:** le premesse da P6 a P12 si verificano quando si apre il
gruppo che le usa, e il loro esito si scrive qui allora.

## Le dodici voci

- **AC.01** L'interruttore dei Journal dall'arte si accende — FERMATA IN ATTESA DI DECISIONE
- **AC.02** Il vuoto sotto l'arte sparisce — APERTA
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
VOCI_APERTE: 10
VOCI_CHIUSE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
