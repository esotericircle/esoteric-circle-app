# Il corpus dell'Oracolo degli Angeli

Ordine FU voci FU.05 e FU.07, 15 ottobre 2026. Il fondatore, alla domanda su chi scrive il corpus: "Code"; e "Gli angeli devono essere di Medora, decisione di Dora". Sulla divisione: Medora dà il messaggio, Caligo dà il rito dell'angelo ("Si, approvo tutto"). Metodo dell'ordine FM e del corpus della Sinastria evolutiva: prima gli schedari (questo file), poi i testi, scritti da agenti in parallelo e mandati a `tool/il_corpus_dell_oracolo.py riempi`, che scrive nella fonte solo ciò che passa i controlli.

**Nessun testo di questa cartella è generato dal modello** (regola R2 dell'ordine FU e regola SPESE di CLAUDE.md): il modello, nella consultazione, scrive solo il titolo e il paragrafo che legano la domanda alle tre carte (voce FU.04). Il grosso del testo viene da qui, gratis.

## I numeri, fissati dal disegno

| File | Voce | Celle | Varianti per cella | Testi |
|---|---|---|---|---|
| custode.md | Medora: l'Angelo Custode, che cosa fare | 72 | 3 messaggi | 216 |
| cuore.md | Medora: l'Angelo del Cuore, che cosa sentire | 72 | 3 messaggi | 216 |
| intelletto.md | Medora: l'Angelo dell'Intelletto, che cosa capire | 72 | 3 messaggi | 216 |
| rito.md | Caligo: il rito nei venti minuti dell'angelo | 72 | 2 riti | 144 |
| **Totale** | | | | **792** (648 messaggi più 144 riti) |

Perché tre varianti per i messaggi: la stessa carta può uscire due volte di fila nella stessa posizione, e il messaggio del giorno (voce FU.08) ruota fra le varianti; con tre varianti la stessa persona non rilegge la stessa frase prima del terzo giorno. Perché due per il rito: il rito è un gesto da ripetere, non una lettura; due varianti bastano a non farlo diventare una formula.

## Come sono fatte le celle

- Una cella per angelo, intestazione `## NN Nome`: NN il numero a due cifre (da 01 a 72), Nome il `seedName` di `lib/core/angels/angel_catalog.dart` (per esempio `## 01 Vehuiah`, `## 02 Jeliel`).
- custode, cuore, intelletto: tre righe `- messaggio 1:`, `- messaggio 2:`, `- messaggio 3:`.
- rito: due righe `- rito 1:`, `- rito 2:`.
- Il generatore scrive `lib/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart` con `const Map<String, List<String>> corpusDellOracolo`, chiave `<file>|<NN>|<campo>` (per esempio `custode|01|messaggio`, `rito|72|rito`), valore le varianti in ordine.

## Le tre posizioni, e il confine fra loro

La persona affida una domanda; l'Angelo Custode porta la carta di cosa fare, l'Angelo del Cuore quella di cosa sentire, l'Angelo dell'Intelletto quella di cosa capire. Ogni carta è uno dei 72. Il messaggio è dunque **l'angelo estratto letto dalla posizione in cui è caduto**.

- **custode, che cosa fare.** Il testo porta il nucleo dell'angelo in un'azione e **finisce con un gesto concreto e piccolo**, fattibile oggi o in settimana: scrivi, togli, rimetti in ordine, dì una frase. **Mai l'invito a chiamare o telefonare a qualcuno**, ordine FV aggiunta voce FVA.01 del 15 ottobre 2026: il fondatore, "Il consiglio di chiamare qualcuno sarebbe già una presa di posizione"; il controllo lo ferma. Il verbo all'imperativo c'è sempre.
- **cuore, che cosa sentire.** Il testo dice che cosa accogliere, che cosa lasciar salire, dove pesa e dove scalda il nucleo dell'angelo. **Nessun gesto da eseguire**: un permesso a sentire, un'emozione nominata con precisione.
- **intelletto, che cosa capire.** Il testo dice che cosa vedere chiaro: **una distinzione netta** che l'angelo insegna (questo, non quello), il meccanismo dietro la situazione. Nessun gesto, nessuna emozione al centro.

Il confine: un messaggio del cuore che finisce con un compito è caduto nel custode; un messaggio dell'intelletto che parla di come ti senti è caduto nel cuore. I lettori ciechi (agenti, mai Gemini) leggono messaggi mescolati e dicono a quale posizione appartengono: la soglia è otto su dieci.

## Le due voci

- **Medora** (custode, cuore, intelletto): calda, colta, concreta. Parla a te, in seconda persona singolare. Può nominare l'angelo col suo nome a video (quello del Corpus, `lib/core/angels/angel_lore.dart`: Ieliel e non Jeliel, Cahethel e non Cahetel). Ciò che la fonte documenta lo può dire come tradizione ("la tradizione lo lega a"), **solo** se sta nel campo del dominio documentato; tutto il resto è **chiave di lettura sua** ("io lo leggo così", "nella mia lettura"), mai "la tradizione dice".
- **Caligo** (rito): asciutto, rituale, essenziale. Frasi brevi, imperativi. Come vivere il rito dell'angelo nei suoi venti minuti del giorno: un gesto semplice, una candela, il silenzio, il nome dell'angelo pronunciato. **Non cita il testo del salmo né l'ora**: li scrive l'app accanto, dalla fonte. **Nessun sigillo dell'angelo**: la sua fonte non è verificata (voce FU.07). Nessuna promessa: il rito non serve a ottenere.

## Le regole di ogni testo (le controlla lo strumento)

- **Italiano con gli accenti veri**: è, più, perché, già, così, può, ciò. Mai `e'`, `piu'`, `perche'`. Gli apostrofi ammessi sono solo le elisioni dell'elenco della guardia `testo_a_video` (l', un', dell', nell', quell', c', po'...): "cos'è" e "dov'è" non passano, si scrive "che cosa è", "dove si trova".
- **Mai una virgola prima di "e" o di "ed".** Se serve una pausa, punto o due punti.
- **Mai il trattino lungo**, e mai il trattino usato come lineetta.
- **Il tu a chi legge**, mai il voi.
- **Il genere di chi legge non si indovina**: nessun aggettivo o participio che concorda con te ("sei pronto", "sei stanca" no). Si scrive neutro ("hai la forza", "ti senti in pace") oppure con la marca a tre vie `[maschile|femminile|neutra]`. Lo controlla lo stesso criterio della guardia di casa (`lib/core/chat/le_forme_del_genere.dart`, via `tool/forme_del_genere_dei_testi.dart`). Niente vocativi ("caro", "cara").
- **Nessuna certezza sul futuro**: nessun verbo al futuro (sarai, avrai, otterrai, accadrà, succederà, arriveranno), mai "sicuramente", "per sempre", "vedrai che", "garantito". Si parla al presente, di inclinazioni e di ciò che conviene fare.
- **La POLITICA DI PUBBLICAZIONE** di `docs/corpus/angeli.md` (regola R8): niente salute, malattia, guarigione, fertilità, longevità, sensi del corpo, medicina; nessuna promessa di esito (vittoria, protezione, ricchezza, ritrovamento, liberazione letterale, successo); niente angeli contrari, niente goetia né demoni, niente nomi alternativi non attestati. Niente vita privata di terzi: nessuna affermazione su ciò che un'altra persona pensa, fa o nasconde. Mai gioco, sfida, punteggio.
- **Nessuna cifra**: l'ora e il salmo li scrive l'app.
- **Nessun nome di un altro angelo** dentro la cella.
- **Lunghezze**: messaggio da 160 a 320 caratteri, un paragrafo; rito da 100 a 240.
- **Le varianti della stessa cella** dicono lo stesso angelo nella stessa posizione con attacchi e gesti diversi: non cominciano con la stessa parola e non si somigliano oltre 0,5 (Jaccard sulle parole). Lo stesso angelo non dice la stessa cosa in due posizioni. Nessun attacco di due parole apre più di dodici testi di un file. Nessun testo è uguale a un altro in tutto il corpus.

## La prova vista rossa

`test/il_corpus_dell_oracolo_test.dart` pretende i 792 testi, nessuna cella vuota, nessun testo uguale a un altro, il Dart generato uguale alla fonte e nessuna parola vietata dalla politica. L'innesto e l'esito sono scritti in fondo a questo file, nella sezione **L'innesto**.

## Lo schedario degli angeli

Per ogni angelo: il nome a video, la fonte con la riga di `docs/corpus/angeli.md`, il nucleo da cui partono le tre posizioni e il rito, la politica che lo riguarda, la **gemella** da cui deve distinguersi. Le gemelle sono coppie: ogni angelo ha per gemella l'angelo che gli somiglia di più fra i 72, e i lettori ciechi leggono messaggi mescolati di una coppia e dicono di quale dei due è ciascuno.

### 01 Vehuiah

- **Nome a video**: Vehuiah. Coro: Serafini. Segno: Ariete.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 52; dominio riga 62, chiave di lettura riga 64, eccesso e difetto riga 66; lib/core/angels/angel_lore.dart, voce 1.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la volontà che apre: cominciare senza aspettare il permesso di nessuno.
- **Gemella**: 45 Sealiah (la volontà applicata alle cose lente: rimettere in moto ciò che si era fermato). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 02 Jeliel

- **Nome a video**: Ieliel. Coro: Serafini. Segno: Ariete.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 72; dominio riga 82, chiave di lettura riga 84, eccesso e difetto riga 86; lib/core/angels/angel_lore.dart, voce 2.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il legame che tiene: tornare alla stessa persona dopo il disaccordo.
- **Politica**: La tradizione parla anche di fecondità: NON si usa (politica). Niente possesso dell'altra persona.
- **Gemella**: 48 Mihael (la fedeltà come pratica quotidiana: restare presente nel legame anche quando non restituisce). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 03 Sitael

- **Nome a video**: Sitael. Coro: Serafini. Segno: Ariete.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 92; dominio riga 102, chiave di lettura riga 104, eccesso e difetto riga 106; lib/core/angels/angel_lore.dart, voce 3.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la parola mantenuta e le opere lente, quelle che si misurano in anni.
- **Gemella**: 44 Yelahiah (la rettitudine sotto pressione: tenere la parola proprio quando costa). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 04 Elemiah

- **Nome a video**: Elemiah. Coro: Serafini. Segno: Ariete.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 112; dominio riga 122, chiave di lettura riga 124, eccesso e difetto riga 126; lib/core/angels/angel_lore.dart, voce 4.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il discernimento su chi hai intorno: l'ostacolo reale distinto dal tumulto interiore.
- **Politica**: Niente nemici, niente rivincita.
- **Gemella**: 42 Mikael (l'ordine interiore che vede le cose come stanno prima di prendere posizione; gli accordi). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 05 Mahasiah

- **Nome a video**: Mahasiah. Coro: Serafini. Segno: Ariete.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 132; dominio riga 142, chiave di lettura riga 144, eccesso e difetto riga 146; lib/core/angels/angel_lore.dart, voce 5.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): stare in pace senza cedere; lo studio; il riavvicinamento fra chi si è allontanato.
- **Gemella**: 26 Haaiah (il punto d'incontro dove gli altri vedono lo scontro; la coerenza fra promessa e azione). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 06 Lelahel

- **Nome a video**: Lelahel. Coro: Serafini. Segno: Ariete.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 152; dominio riga 162, chiave di lettura riga 164, eccesso e difetto riga 166; lib/core/angels/angel_lore.dart, voce 6.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il talento che chiarisce e non abbaglia: l'uso che fai delle tue capacità.
- **Politica**: La tradizione di Lenain parla di guarigione: NON si usa (politica, angelo 6).
- **Gemella**: 54 Nithael (riconoscere la bellezza e mostrarla agli altri; ciò che dura oltre chi l'ha fatto). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 07 Achaiah

- **Nome a video**: Achaiah. Coro: Serafini. Segno: Toro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 172; dominio riga 182, chiave di lettura riga 184, eccesso e difetto riga 186; lib/core/angels/angel_lore.dart, voce 7.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la pazienza che continua a osservare: il tempo lungo dell'apprendere.
- **Gemella**: 58 Yeialel (la forza mentale della fatica lunga: guardare una cosa finché ne vedi la causa). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 08 Cahetel

- **Nome a video**: Cahethel. Coro: Serafini. Segno: Toro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 192; dominio riga 202, chiave di lettura riga 204, eccesso e difetto riga 206; lib/core/angels/angel_lore.dart, voce 8.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la gratitudine concreta: il rapporto fra la fatica e il frutto, la casa.
- **Politica**: Niente beni promessi, niente raccolto come ricchezza.
- **Gemella**: 30 Omael (la pazienza che prepara il terreno; perseverare quando nulla sembra muoversi). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 09 Haziel

- **Nome a video**: Haziel. Coro: Cherubini. Segno: Toro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 228; dominio riga 238, chiave di lettura riga 240, eccesso e difetto riga 242; lib/core/angels/angel_lore.dart, voce 9.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la clemenza consapevole: perdonare per non portare più il peso, dare senza aprire un debito.
- **Gemella**: 10 Aladiah (ricominciare senza cancellare: lasciare che un errore smetta di definirti). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 10 Aladiah

- **Nome a video**: Aladiah. Coro: Cherubini. Segno: Toro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 248; dominio riga 258, chiave di lettura riga 260, eccesso e difetto riga 262; lib/core/angels/angel_lore.dart, voce 10.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): ricominciare senza cancellare: lasciare che un errore smetta di definirti.
- **Politica**: Il dominio cita il corpo: NON si usa (politica, angelo 10).
- **Gemella**: 09 Haziel (la clemenza consapevole: perdonare per non portare più il peso, dare senza aprire un debito). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 11 Lauviah

- **Nome a video**: Lauviah. Coro: Cherubini. Segno: Toro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 268; dominio riga 278, chiave di lettura riga 280, eccesso e difetto riga 282; lib/core/angels/angel_lore.dart, voce 11.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la costanza che regge quando l'entusiasmo è finito; ciò che vali e ciò che gli altri vedono.
- **Politica**: Niente successo promesso, niente fortuna.
- **Gemella**: 22 Yeiayel (il lavoro solido che regge nel tempo; la visibilità usata bene). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 12 Hahaiah

- **Nome a video**: Hahaiah. Coro: Cherubini. Segno: Toro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 288; dominio riga 298, chiave di lettura riga 300, eccesso e difetto riga 302; lib/core/angels/angel_lore.dart, voce 12.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il rifugio interiore: il silenzio, i sogni, la discrezione su ciò che ti viene confidato.
- **Gemella**: 62 Iah-Hel (la saggezza del silenzio scelto: ritirarti un momento prima di rispondere). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 13 Iezalel

- **Nome a video**: Iezalel. Coro: Cherubini. Segno: Gemelli.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 308; dominio riga 318, chiave di lettura riga 320, eccesso e difetto riga 322; lib/core/angels/angel_lore.dart, voce 13.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la fedeltà come memoria attiva: tenere insieme un gruppo senza comandarlo.
- **Gemella**: 61 Umabel (l'affinità: sentire l'altra persona senza confonderti; le amicizie scelte). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 14 Mebahel

- **Nome a video**: Mebahel. Coro: Cherubini. Segno: Gemelli.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 328; dominio riga 338, chiave di lettura riga 340, eccesso e difetto riga 342; lib/core/angels/angel_lore.dart, voce 14.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): dire le cose come stanno senza ferire; la giustizia applicata prima a te; gli accordi.
- **Gemella**: 18 Caliel (distinguere il fatto dall'opinione e pronunciarsi senza alzare il tono). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 15 Hariel

- **Nome a video**: Hariel. Coro: Cherubini. Segno: Gemelli.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 348; dominio riga 358, chiave di lettura riga 360, eccesso e difetto riga 362; lib/core/angels/angel_lore.dart, voce 15.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): mettere ordine nelle idee: l'intuizione che diventa metodo.
- **Gemella**: 31 Lecabel (il dettaglio senza perdere l'insieme; l'idea che diventa un metodo che funziona). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 16 Hekamiah

- **Nome a video**: Hakamiah. Coro: Cherubini. Segno: Gemelli.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 368; dominio riga 378, chiave di lettura riga 380, eccesso e difetto riga 382; lib/core/angels/angel_lore.dart, voce 16.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): restare al proprio posto e parlare chiaro con chi comanda.
- **Politica**: Niente conflitto armato.
- **Gemella**: 33 Yehuiah (stare dentro una struttura senza perderti; distinguere il ruolo dalla persona). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 17 Lauviah II

- **Nome a video**: Lauviah II. Coro: Troni. Segno: Gemelli.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 408; dominio riga 418, chiave di lettura riga 420, eccesso e difetto riga 422; lib/core/angels/angel_lore.dart, voce 17.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la rivelazione che arriva di notte, trattata come un dato da verificare.
- **Gemella**: 46 Ariel (la percezione che precede la prova: accorgersi del dettaglio e verificarlo). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 18 Caliel

- **Nome a video**: Caliel. Coro: Troni. Segno: Gemelli.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 428; dominio riga 438, chiave di lettura riga 440, eccesso e difetto riga 442; lib/core/angels/angel_lore.dart, voce 18.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): distinguere il fatto dall'opinione e pronunciarsi senza alzare il tono.
- **Gemella**: 14 Mebahel (dire le cose come stanno senza ferire; la giustizia applicata prima a te; gli accordi). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 19 Leuviah

- **Nome a video**: Leuviah. Coro: Troni. Segno: Cancro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 448; dominio riga 458, chiave di lettura riga 460, eccesso e difetto riga 462; lib/core/angels/angel_lore.dart, voce 19.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la memoria che ricostruisce e chiude le questioni rimaste aperte, senza rinfacciare.
- **Gemella**: 66 Manakel (reggere il peso senza farlo pesare; la discrezione; la crescita lenta che non si forza). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 20 Pahaliah

- **Nome a video**: Pahaliah. Coro: Troni. Segno: Cancro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 468; dominio riga 478, chiave di lettura riga 480, eccesso e difetto riga 482; lib/core/angels/angel_lore.dart, voce 20.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): cambiare direzione a metà strada; ciò che decidi non negoziabile.
- **Gemella**: 55 Mebahiah (rendere gesto quotidiano ciò che consideri giusto; la parola che consola; ciò che trasmetti). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 21 Nelchael

- **Nome a video**: Nelchael. Coro: Troni. Segno: Cancro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 488; dominio riga 498, chiave di lettura riga 500, eccesso e difetto riga 502; lib/core/angels/angel_lore.dart, voce 21.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): lo studio che sopporta di non capire subito; trasmettere ciò che sai.
- **Gemella**: 53 Nanael (il silenzio e il tempo lungo dello studio; essere una persona su cui si può contare). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 22 Yeiayel

- **Nome a video**: Ieiaiel. Coro: Troni. Segno: Cancro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 508; dominio riga 518, chiave di lettura riga 520, eccesso e difetto riga 522; lib/core/angels/angel_lore.dart, voce 22.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il lavoro solido che regge nel tempo; la visibilità usata bene.
- **Politica**: Niente fama promessa, niente commercio come guadagno.
- **Gemella**: 11 Lauviah (la costanza che regge quando l'entusiasmo è finito; ciò che vali e ciò che gli altri vedono). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 23 Melahel

- **Nome a video**: Melahel. Coro: Troni. Segno: Cancro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 528; dominio riga 538, chiave di lettura riga 540, eccesso e difetto riga 542; lib/core/angels/angel_lore.dart, voce 23.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la prevenzione più della riparazione: la costanza nelle piccole attenzioni di ogni giorno.
- **Politica**: Il dominio di Lenain parla di rimedi, piante, acqua che risana e protezione dalle armi: NON si usa nulla (politica). Si lavora solo la costanza che previene.
- **Gemella**: 28 Seheiah (la prudenza che guarda avanti; il passo sostenibile; le abitudini che reggono). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 24 Haheuiah

- **Nome a video**: Haheuiah. Coro: Troni. Segno: Cancro.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 548; dominio riga 558, chiave di lettura riga 560, eccesso e difetto riga 562; lib/core/angels/angel_lore.dart, voce 24.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il confine che poni intorno a te; stare accanto a chi è fuori posto.
- **Politica**: Esilio e prigionia solo come immagine interiore, mai letterali.
- **Gemella**: 71 Haiaiel (il coraggio della decisione presa a mente fredda; saper dire no; difendere chi non si difende). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 25 Nith-Haiah

- **Nome a video**: Nithhaiah. Coro: Dominazioni. Segno: Leone.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 590; dominio riga 600, chiave di lettura riga 602, eccesso e difetto riga 604; lib/core/angels/angel_lore.dart, voce 25.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il silenzio che precede la parola; le intuizioni che arrivano quando smetti di cercarle.
- **Gemella**: 51 Hahasiah (voler sapere come funziona una cosa prima di metterci le mani: il metodo). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 26 Haaiah

- **Nome a video**: Haaiah. Coro: Dominazioni. Segno: Leone.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 610; dominio riga 620, chiave di lettura riga 622, eccesso e difetto riga 624; lib/core/angels/angel_lore.dart, voce 26.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il punto d'incontro dove gli altri vedono lo scontro; la coerenza fra promessa e azione.
- **Gemella**: 05 Mahasiah (stare in pace senza cedere; lo studio; il riavvicinamento fra chi si è allontanato). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 27 Yerathel

- **Nome a video**: Ierathel. Coro: Dominazioni. Segno: Leone.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 630; dominio riga 640, chiave di lettura riga 642, eccesso e difetto riga 644; lib/core/angels/angel_lore.dart, voce 27.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): portare chiarezza senza condannare; tenere una posizione senza colpire.
- **Gemella**: 64 Mehiel (dare forma viva a un'idea, per iscritto o a parole; unire il sentire al ragionare). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 28 Seheiah

- **Nome a video**: Seheiah. Coro: Dominazioni. Segno: Leone.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 650; dominio riga 660, chiave di lettura riga 662, eccesso e difetto riga 664; lib/core/angels/angel_lore.dart, voce 28.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la prudenza che guarda avanti; il passo sostenibile; le abitudini che reggono.
- **Politica**: Il dominio cita l'ascolto del corpo e la longevità: NON si usa (politica).
- **Gemella**: 23 Melahel (la prevenzione più della riparazione: la costanza nelle piccole attenzioni di ogni giorno). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 29 Reiyel

- **Nome a video**: Reiiel. Coro: Dominazioni. Segno: Leone.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 670; dominio riga 680, chiave di lettura riga 682, eccesso e difetto riga 684; lib/core/angels/angel_lore.dart, voce 29.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): riconoscere ciò che ti trattiene e scioglierlo senza rancore; le credenze ereditate.
- **Politica**: Liberazione solo interiore.
- **Gemella**: 52 Imamiah (riconoscere un tuo errore senza farne una condanna; uscire dalle situazioni chiuse dentro di te). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 30 Omael

- **Nome a video**: Omael. Coro: Dominazioni. Segno: Leone.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 690; dominio riga 700, chiave di lettura riga 702, eccesso e difetto riga 704; lib/core/angels/angel_lore.dart, voce 30.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la pazienza che prepara il terreno; perseverare quando nulla sembra muoversi.
- **Politica**: La tradizione parla di fecondità: NON si usa (politica).
- **Gemella**: 08 Cahetel (la gratitudine concreta: il rapporto fra la fatica e il frutto, la casa). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 31 Lecabel

- **Nome a video**: Lecabel. Coro: Dominazioni. Segno: Vergine.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 710; dominio riga 720, chiave di lettura riga 722, eccesso e difetto riga 724; lib/core/angels/angel_lore.dart, voce 31.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il dettaglio senza perdere l'insieme; l'idea che diventa un metodo che funziona.
- **Gemella**: 15 Hariel (mettere ordine nelle idee: l'intuizione che diventa metodo). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 32 Vasariah

- **Nome a video**: Vasariah. Coro: Dominazioni. Segno: Vergine.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 730; dominio riga 740, chiave di lettura riga 742, eccesso e difetto riga 744; lib/core/angels/angel_lore.dart, voce 32.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la giustizia temperata dalla clemenza: distinguere l'errore dalla persona.
- **Gemella**: 47 Asaliah (il senso della misura fra le persone: cercare il vero prima del comodo). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 33 Yehuiah

- **Nome a video**: Iehuiah. Coro: Potenze. Segno: Vergine.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 767; dominio riga 777, chiave di lettura riga 779, eccesso e difetto riga 781; lib/core/angels/angel_lore.dart, voce 33.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): stare dentro una struttura senza perderti; distinguere il ruolo dalla persona.
- **Gemella**: 16 Hekamiah (restare al proprio posto e parlare chiaro con chi comanda). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 34 Lehahiah

- **Nome a video**: Lehahiah. Coro: Potenze. Segno: Vergine.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 787; dominio riga 797, chiave di lettura riga 799, eccesso e difetto riga 801; lib/core/angels/angel_lore.dart, voce 34.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la calma che tiene mentre gli altri alzano la voce: la forza che sceglie di non esplodere.
- **Gemella**: 60 Mitzrael (riparare ciò che si è rotto, dentro di te o fra te e un altro; la pazienza al posto della rivincita). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 35 Chavakiah

- **Nome a video**: Chavakhiah. Coro: Potenze. Segno: Vergine.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 807; dominio riga 817, chiave di lettura riga 819, eccesso e difetto riga 821; lib/core/angels/angel_lore.dart, voce 35.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il primo passo verso chi hai ferito: scegliere il legame al posto della ragione.
- **Politica**: Famiglia senza nominare i ruoli; eredità NON si usa (politica).
- **Gemella**: 39 Rehael (il rispetto dato prima di essere meritato; guardare chi ti è vicino senza il conto aperto degli anni). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 36 Menadel

- **Nome a video**: Menadel. Coro: Potenze. Segno: Vergine.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 827; dominio riga 837, chiave di lettura riga 839, eccesso e difetto riga 841; lib/core/angels/angel_lore.dart, voce 36.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il lavoro come luogo dove diventi qualcuno; restare finché il posto ha da insegnare.
- **Politica**: Impieghi ottenuti, abbondanza, ritrovare ciò che è perduto: NON si usano (politica, angelo 36).
- **Gemella**: 56 Poyel (chiedere poco senza togliere peso a ciò che chiedi; rialzarsi più che salire). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 37 Aniel

- **Nome a video**: Aniel. Coro: Potenze. Segno: Bilancia.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 847; dominio riga 857, chiave di lettura riga 859, eccesso e difetto riga 861; lib/core/angels/angel_lore.dart, voce 37.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): rompere un cerchio che si ripete: la decisione lucida di smettere di girare intorno.
- **Gemella**: 43 Veuliah (la disciplina che porta a termine; ricominciare dopo una caduta netta). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 38 Haamiah

- **Nome a video**: Haamiah. Coro: Potenze. Segno: Bilancia.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 867; dominio riga 877, chiave di lettura riga 879, eccesso e difetto riga 881; lib/core/angels/angel_lore.dart, voce 38.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il gesto ripetuto che tiene insieme il senso: il rito che ricorda chi sei.
- **Politica**: Niente protezione promessa (politica, angelo 38).
- **Gemella**: 41 Hahahel (la coerenza fra ciò che dici di credere e ciò che fai quando nessuno guarda). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 39 Rehael

- **Nome a video**: Rehael. Coro: Potenze. Segno: Bilancia.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 887; dominio riga 897, chiave di lettura riga 899, eccesso e difetto riga 901; lib/core/angels/angel_lore.dart, voce 39.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il rispetto dato prima di essere meritato; guardare chi ti è vicino senza il conto aperto degli anni.
- **Politica**: Sofferenza mentale NON si usa (politica, angelo 39). Mai nominare padre, madre, figlio: "chi ti ha cresciuto", "chi viene dopo di te".
- **Gemella**: 35 Chavakiah (il primo passo verso chi hai ferito: scegliere il legame al posto della ragione). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 40 Ieiazel

- **Nome a video**: Ieiazel. Coro: Potenze. Segno: Bilancia.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 907; dominio riga 917, chiave di lettura riga 919, eccesso e difetto riga 921; lib/core/angels/angel_lore.dart, voce 40.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la consolazione che non nega il dolore; uscire da ciò che ti tiene chiuso; la scrittura.
- **Politica**: Prigioni solo interiori, mai liberazione letterale (politica, angelo 40).
- **Gemella**: 65 Damabiah (la sorgente interna; ciò che scorre; i legami che si sciolgono senza rancore). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 41 Hahahel

- **Nome a video**: Hahahel. Coro: Virtù. Segno: Bilancia.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 947; dominio riga 957, chiave di lettura riga 959, eccesso e difetto riga 961; lib/core/angels/angel_lore.dart, voce 41.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la coerenza fra ciò che dici di credere e ciò che fai quando nessuno guarda.
- **Gemella**: 38 Haamiah (il gesto ripetuto che tiene insieme il senso: il rito che ricorda chi sei). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 42 Mikael

- **Nome a video**: Mikael. Coro: Virtù. Segno: Bilancia.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 967; dominio riga 977, chiave di lettura riga 979, eccesso e difetto riga 981; lib/core/angels/angel_lore.dart, voce 42.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): l'ordine interiore che vede le cose come stanno prima di prendere posizione; gli accordi.
- **Gemella**: 04 Elemiah (il discernimento su chi hai intorno: l'ostacolo reale distinto dal tumulto interiore). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 43 Veuliah

- **Nome a video**: Veualiah. Coro: Virtù. Segno: Scorpione.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 987; dominio riga 997, chiave di lettura riga 999, eccesso e difetto riga 1001; lib/core/angels/angel_lore.dart, voce 43.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la disciplina che porta a termine; ricominciare dopo una caduta netta.
- **Politica**: Nessun successo promesso.
- **Gemella**: 37 Aniel (rompere un cerchio che si ripete: la decisione lucida di smettere di girare intorno). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 44 Yelahiah

- **Nome a video**: Ielahiah. Coro: Virtù. Segno: Scorpione.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1007; dominio riga 1017, chiave di lettura riga 1019, eccesso e difetto riga 1021; lib/core/angels/angel_lore.dart, voce 44.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la rettitudine sotto pressione: tenere la parola proprio quando costa.
- **Politica**: Vittoria, conflitti armati: NON si usano (politica, angelo 44).
- **Gemella**: 03 Sitael (la parola mantenuta e le opere lente, quelle che si misurano in anni). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 45 Sealiah

- **Nome a video**: Sealiah. Coro: Virtù. Segno: Scorpione.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1027; dominio riga 1037, chiave di lettura riga 1039, eccesso e difetto riga 1041; lib/core/angels/angel_lore.dart, voce 45.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la volontà applicata alle cose lente: rimettere in moto ciò che si era fermato.
- **Politica**: La tradizione parla di salute: NON si usa (politica, angelo 45).
- **Gemella**: 01 Vehuiah (la volontà che apre: cominciare senza aspettare il permesso di nessuno). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 46 Ariel

- **Nome a video**: Ariel. Coro: Virtù. Segno: Scorpione.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1047; dominio riga 1057, chiave di lettura riga 1059, eccesso e difetto riga 1061; lib/core/angels/angel_lore.dart, voce 46.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la percezione che precede la prova: accorgersi del dettaglio e verificarlo.
- **Politica**: Ritrovare risorse o oggetti: NON si promette.
- **Gemella**: 17 Lauviah II (la rivelazione che arriva di notte, trattata come un dato da verificare). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 47 Asaliah

- **Nome a video**: Asaliah. Coro: Virtù. Segno: Scorpione.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1067; dominio riga 1077, chiave di lettura riga 1079, eccesso e difetto riga 1081; lib/core/angels/angel_lore.dart, voce 47.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il senso della misura fra le persone: cercare il vero prima del comodo.
- **Gemella**: 32 Vasariah (la giustizia temperata dalla clemenza: distinguere l'errore dalla persona). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 48 Mihael

- **Nome a video**: Mihael. Coro: Virtù. Segno: Scorpione.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1087; dominio riga 1097, chiave di lettura riga 1099, eccesso e difetto riga 1101; lib/core/angels/angel_lore.dart, voce 48.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la fedeltà come pratica quotidiana: restare presente nel legame anche quando non restituisce.
- **Politica**: La tradizione parla di fertilità: NON si usa (politica, angelo 48).
- **Gemella**: 02 Jeliel (il legame che tiene: tornare alla stessa persona dopo il disaccordo). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 49 Vehuel

- **Nome a video**: Vehuel. Coro: Principati. Segno: Sagittario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1130; dominio riga 1140, chiave di lettura riga 1142, eccesso e difetto riga 1144; lib/core/angels/angel_lore.dart, voce 49.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il metro alto usato per riconoscere il valore degli altri; la parola che mette d'accordo.
- **Gemella**: 50 Daniel (passare dal dubbio alla scelta; vedere le ragioni dell'altro prima di giudicarle). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 50 Daniel

- **Nome a video**: Daniel. Coro: Principati. Segno: Sagittario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1150; dominio riga 1160, chiave di lettura riga 1162, eccesso e difetto riga 1164; lib/core/angels/angel_lore.dart, voce 50.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): passare dal dubbio alla scelta; vedere le ragioni dell'altro prima di giudicarle.
- **Gemella**: 49 Vehuel (il metro alto usato per riconoscere il valore degli altri; la parola che mette d'accordo). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 51 Hahasiah

- **Nome a video**: Hahasiah. Coro: Principati. Segno: Sagittario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1170; dominio riga 1180, chiave di lettura riga 1182, eccesso e difetto riga 1184; lib/core/angels/angel_lore.dart, voce 51.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): voler sapere come funziona una cosa prima di metterci le mani: il metodo.
- **Politica**: Medicina e pietra filosofale: NON si usano (politica, angelo 51).
- **Gemella**: 25 Nith-Haiah (il silenzio che precede la parola; le intuizioni che arrivano quando smetti di cercarle). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 52 Imamiah

- **Nome a video**: Imamiah. Coro: Principati. Segno: Sagittario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1190; dominio riga 1200, chiave di lettura riga 1202, eccesso e difetto riga 1204; lib/core/angels/angel_lore.dart, voce 52.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): riconoscere un tuo errore senza farne una condanna; uscire dalle situazioni chiuse dentro di te.
- **Politica**: Prigioni e nemici: NON si usano (politica, angelo 52).
- **Gemella**: 29 Reiyel (riconoscere ciò che ti trattiene e scioglierlo senza rancore; le credenze ereditate). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 53 Nanael

- **Nome a video**: Nanael. Coro: Principati. Segno: Sagittario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1210; dominio riga 1220, chiave di lettura riga 1222, eccesso e difetto riga 1224; lib/core/angels/angel_lore.dart, voce 53.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il silenzio e il tempo lungo dello studio; essere una persona su cui si può contare.
- **Gemella**: 21 Nelchael (lo studio che sopporta di non capire subito; trasmettere ciò che sai). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 54 Nithael

- **Nome a video**: Nithael. Coro: Principati. Segno: Sagittario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1230; dominio riga 1240, chiave di lettura riga 1242, eccesso e difetto riga 1244; lib/core/angels/angel_lore.dart, voce 54.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): riconoscere la bellezza e mostrarla agli altri; ciò che dura oltre chi l'ha fatto.
- **Politica**: Longevità: NON si usa.
- **Gemella**: 06 Lelahel (il talento che chiarisce e non abbaglia: l'uso che fai delle tue capacità). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 55 Mebahiah

- **Nome a video**: Mebahiah. Coro: Principati. Segno: Capricorno.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1250; dominio riga 1260, chiave di lettura riga 1262, eccesso e difetto riga 1264; lib/core/angels/angel_lore.dart, voce 55.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): rendere gesto quotidiano ciò che consideri giusto; la parola che consola; ciò che trasmetti.
- **Politica**: Generazione come figli e fertilità: NON si usano (politica, angelo 55).
- **Gemella**: 20 Pahaliah (cambiare direzione a metà strada; ciò che decidi non negoziabile). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 56 Poyel

- **Nome a video**: Poyel. Coro: Principati. Segno: Capricorno.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1270; dominio riga 1280, chiave di lettura riga 1282, eccesso e difetto riga 1284; lib/core/angels/angel_lore.dart, voce 56.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): chiedere poco senza togliere peso a ciò che chiedi; rialzarsi più che salire.
- **Politica**: Mezzi e fortuna: NON si promettono.
- **Gemella**: 36 Menadel (il lavoro come luogo dove diventi qualcuno; restare finché il posto ha da insegnare). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 57 Nemamiah

- **Nome a video**: Nemamiah. Coro: Arcangeli. Segno: Capricorno.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1309; dominio riga 1319, chiave di lettura riga 1321, eccesso e difetto riga 1323; lib/core/angels/angel_lore.dart, voce 57.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il discernimento fra sostanza e apparenza; decidere in fretta senza tradire ciò che hai capito.
- **Politica**: Vittoria e liberazione dei prigionieri: NON si usano (politica, angelo 57).
- **Gemella**: 69 Rochel (vedere lontano senza fretta di giudicare; fare chiarezza dove le tracce sono coperte). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 58 Yeialel

- **Nome a video**: Ieialel. Coro: Arcangeli. Segno: Capricorno.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1329; dominio riga 1339, chiave di lettura riga 1341, eccesso e difetto riga 1343; lib/core/angels/angel_lore.dart, voce 58.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la forza mentale della fatica lunga: guardare una cosa finché ne vedi la causa.
- **Politica**: Vista e guarigione: NON si usano (politica, angelo 58).
- **Gemella**: 07 Achaiah (la pazienza che continua a osservare: il tempo lungo dell'apprendere). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 59 Harahel

- **Nome a video**: Harahel. Coro: Arcangeli. Segno: Capricorno.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1349; dominio riga 1359, chiave di lettura riga 1361, eccesso e difetto riga 1363; lib/core/angels/angel_lore.dart, voce 59.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): apprezzare senza svalutare; conservare e far circolare ciò che sai.
- **Politica**: Denaro e fertilità: NON si usano (politica, angelo 59).
- **Gemella**: 67 Eyael (trovare bellezza dove altri passano oltre; i cambiamenti che trasformano senza rompere). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 60 Mitzrael

- **Nome a video**: Mitzrael. Coro: Arcangeli. Segno: Capricorno.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1369; dominio riga 1379, chiave di lettura riga 1381, eccesso e difetto riga 1383; lib/core/angels/angel_lore.dart, voce 60.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): riparare ciò che si è rotto, dentro di te o fra te e un altro; la pazienza al posto della rivincita.
- **Politica**: Guarigione della mente: NON si usa (politica, angelo 60).
- **Gemella**: 34 Lehahiah (la calma che tiene mentre gli altri alzano la voce: la forza che sceglie di non esplodere). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 61 Umabel

- **Nome a video**: Umabel. Coro: Arcangeli. Segno: Acquario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1389; dominio riga 1399, chiave di lettura riga 1401, eccesso e difetto riga 1403; lib/core/angels/angel_lore.dart, voce 61.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): l'affinità: sentire l'altra persona senza confonderti; le amicizie scelte.
- **Gemella**: 13 Iezalel (la fedeltà come memoria attiva: tenere insieme un gruppo senza comandarlo). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 62 Iah-Hel

- **Nome a video**: Iahhel. Coro: Arcangeli. Segno: Acquario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1409; dominio riga 1419, chiave di lettura riga 1421, eccesso e difetto riga 1423; lib/core/angels/angel_lore.dart, voce 62.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la saggezza del silenzio scelto: ritirarti un momento prima di rispondere.
- **Gemella**: 12 Hahaiah (il rifugio interiore: il silenzio, i sogni, la discrezione su ciò che ti viene confidato). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 63 Anauel

- **Nome a video**: Anauel. Coro: Arcangeli. Segno: Acquario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1429; dominio riga 1439, chiave di lettura riga 1441, eccesso e difetto riga 1443; lib/core/angels/angel_lore.dart, voce 63.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la percezione dell'unità fra le cose: il punto in cui due interessi diversi si incontrano.
- **Politica**: Protezione dagli incidenti e salute: NON si usano (politica, angelo 63).
- **Gemella**: 68 Habuhiah (la generosità pratica: dare senza contare e senza aspettare riconoscimento). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 64 Mehiel

- **Nome a video**: Mehiel. Coro: Arcangeli. Segno: Acquario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1449; dominio riga 1459, chiave di lettura riga 1461, eccesso e difetto riga 1463; lib/core/angels/angel_lore.dart, voce 64.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): dare forma viva a un'idea, per iscritto o a parole; unire il sentire al ragionare.
- **Gemella**: 27 Yerathel (portare chiarezza senza condannare; tenere una posizione senza colpire). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 65 Damabiah

- **Nome a video**: Damabiah. Coro: Angeli. Segno: Acquario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1489; dominio riga 1499, chiave di lettura riga 1501, eccesso e difetto riga 1503; lib/core/angels/angel_lore.dart, voce 65.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la sorgente interna; ciò che scorre; i legami che si sciolgono senza rancore.
- **Politica**: Malefici e protezione: NON si usano (politica).
- **Gemella**: 40 Ieiazel (la consolazione che non nega il dolore; uscire da ciò che ti tiene chiuso; la scrittura). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 66 Manakel

- **Nome a video**: Manakel. Coro: Angeli. Segno: Acquario.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1509; dominio riga 1519, chiave di lettura riga 1521, eccesso e difetto riga 1523; lib/core/angels/angel_lore.dart, voce 66.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): reggere il peso senza farlo pesare; la discrezione; la crescita lenta che non si forza.
- **Politica**: Il sonno come cura: NON si usa.
- **Gemella**: 19 Leuviah (la memoria che ricostruisce e chiude le questioni rimaste aperte, senza rinfacciare). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 67 Eyael

- **Nome a video**: Eiael. Coro: Angeli. Segno: Pesci.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1529; dominio riga 1539, chiave di lettura riga 1541, eccesso e difetto riga 1543; lib/core/angels/angel_lore.dart, voce 67.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): trovare bellezza dove altri passano oltre; i cambiamenti che trasformano senza rompere.
- **Gemella**: 59 Harahel (apprezzare senza svalutare; conservare e far circolare ciò che sai). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 68 Habuhiah

- **Nome a video**: Habuhiah. Coro: Angeli. Segno: Pesci.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1549; dominio riga 1559, chiave di lettura riga 1561, eccesso e difetto riga 1563; lib/core/angels/angel_lore.dart, voce 68.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): la generosità pratica: dare senza contare e senza aspettare riconoscimento.
- **Politica**: Fertilità, guarigione e raccolti: NON si usano (politica, angelo 68). Il dominio documentato a video è vuoto: tutto è chiave di lettura di Medora.
- **Gemella**: 63 Anauel (la percezione dell'unità fra le cose: il punto in cui due interessi diversi si incontrano). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 69 Rochel

- **Nome a video**: Rochel. Coro: Angeli. Segno: Pesci.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1569; dominio riga 1579, chiave di lettura riga 1581, eccesso e difetto riga 1583; lib/core/angels/angel_lore.dart, voce 69.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): vedere lontano senza fretta di giudicare; fare chiarezza dove le tracce sono coperte.
- **Politica**: Ritrovare oggetti ed eredità: NON si usano (politica).
- **Gemella**: 57 Nemamiah (il discernimento fra sostanza e apparenza; decidere in fretta senza tradire ciò che hai capito). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 70 Jabamiah

- **Nome a video**: Iabamiah. Coro: Angeli. Segno: Pesci.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1589; dominio riga 1599, chiave di lettura riga 1601, eccesso e difetto riga 1603; lib/core/angels/angel_lore.dart, voce 70.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): trasformare le situazioni invece di subirle: una fine che diventa inizio.
- **Politica**: Rigenerazione fisica: NON si usa (politica).
- **Gemella**: 72 Mumiah (saper chiudere: portare a termine per ricominciare puliti). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 71 Haiaiel

- **Nome a video**: Haiaiel. Coro: Angeli. Segno: Pesci.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1609; dominio riga 1619, chiave di lettura riga 1621, eccesso e difetto riga 1623; lib/core/angels/angel_lore.dart, voce 71.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): il coraggio della decisione presa a mente fredda; saper dire no; difendere chi non si difende.
- **Politica**: Armi e protezione: NON si usano (politica).
- **Gemella**: 24 Haheuiah (il confine che poni intorno a te; stare accanto a chi è fuori posto). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

### 72 Mumiah

- **Nome a video**: Mumiah. Coro: Angeli. Segno: Pesci.
- **Fonte**: docs/corpus/angeli.md, voce alla riga 1629; dominio riga 1639, chiave di lettura riga 1641, eccesso e difetto riga 1643; lib/core/angels/angel_lore.dart, voce 72.
- **Il nucleo** (chiave di lettura di Medora, mai detta come tradizione): saper chiudere: portare a termine per ricominciare puliti.
- **Politica**: Longevità, tatto e salute: NON si usano (politica, angelo 72).
- **Gemella**: 70 Jabamiah (trasformare le situazioni invece di subirle: una fine che diventa inizio). Un testo che si potrebbe spostare nella gemella senza perdere senso è caduto fuori dal suo angelo.
- **custode** (cosa fare): il gesto che mette in pratica il nucleo; chiude con un'azione piccola e concreta, fattibile oggi o in settimana.
- **cuore** (cosa sentire): che cosa accogliere davanti al nucleo, dove si sente la sua forza e dove pesa la sua ombra; nessun gesto da eseguire, un permesso a sentire.
- **intelletto** (cosa capire): la distinzione che il nucleo insegna, detta netta (questo, non quello); nessun gesto, nessuna emozione al centro.
- **rito** (Caligo): un gesto semplice nei venti minuti dell'angelo, legato al nucleo; le due varianti con gesti diversi.

## Gli esiti dello strumento

Testi scritti da sette agenti in parallelo (custode, cuore e intelletto in due fasce di 36 angeli ciascuno, il rito in una), solo con `riempi`. Scartati al primo invio e riscritti: custode 17 su 216, cuore 9 su 216, intelletto 15 su 216, rito 4 su 144. I difetti più frequenti: la seconda persona non riconosciuta (testi solo all'imperativo, senza "ti", "te", "tuo"), la virgola prima di "e", parole che la politica ferma per radice ("successivo", "sterile", "ereditate", "vista", "contrario"), il genere di chi legge ("essere riconosciuta"), "promesso" come formula di certezza, una lunghezza fuori misura, una parola ripetuta ("piano piano").

`python tool/il_corpus_dell_oracolo.py controlla` sulla fonte piena: **DIFETTI: 0 su 792 testi**. `conta`: custode 216, cuore 216, intelletto 216, rito 144, totale 792.

## L'innesto

Regola A delle guardie: `test/il_corpus_dell_oracolo_test.dart` vista rossa prima di leggerne il verde, 15 ottobre 2026.

1. **Parola vietata.** Nel .g.dart generato, nel primo messaggio di `custode|01|messaggio`, "una cosa nuova che aspetta" è diventato "una guarigione nuova che aspetta"; il grep di "guarigione" sul file lo trova alla riga 11. Esito: **rossa su due prove**, "il Dart generato coincide con la fonte" (`custode|01|messaggio variante 1`) e "nessuna parola vietata dalla politica" (`"guarigione"`, una parola vietata trovata su 792 testi guardati).
2. **Testo doppio.** Rigenerato il .g.dart, la riga della seconda variante di `custode|01|messaggio` è stata sostituita con la prima; il grep di "una cosa nuova che aspetta" la conta due volte. Esito: **rossa su due prove**, "nessun testo è uguale a un altro" e "il Dart generato coincide con la fonte".
3. Rigenerato con `genera` (il grep conta di nuovo una sola occorrenza): **verde**, quattro prove su quattro; 792 testi, 288 celle, nessuna mancante, nessuna vuota, parole vietate 0.

## I lettori ciechi

Agenti di Code che non hanno scritto i testi, mai Gemini (regola R2). `tool/i_lettori_ciechi_dell_oracolo.py`: per giro due prove dei ruoli (dieci messaggi mescolati delle tre posizioni, tre opzioni) e quattro prove delle gemelle (dieci messaggi di due angeli gemelli, cinque per angelo, col nucleo dei due come opzioni), col nome dell'angelo tolto dal testo. Soglia otto su dieci per prova, due giri con semi diversi. Fascicoli, chiavi, risposte ed esiti in `docs/collaudo/FU/lettori_ciechi/`.

| Giro | Prova | Esito |
|---|---|---|
| 1 | ruoli 1, ruoli 2 | 10 su 10, 10 su 10 |
| 1 | gemelle 23-28, 19-66, 70-72, 34-60 | 10, 10, 10, 10 su 10 |
| 2 | ruoli 1, ruoli 2 | 10 su 10, 10 su 10 |
| 2 | gemelle 59-67, 63-68, 38-41, 14-18 | 9, 10, 10, 10 su 10 |

Totale 119 su 120; l'unico errore è la terza variante di Eyael (67) in intelletto.md, sul progetto distinto dal desiderio ben descritto, letta come Harahel (59). Nessuna prova sotto soglia: nessun testo è stato riscritto dopo i lettori.

