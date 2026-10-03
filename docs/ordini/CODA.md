# CODA DEGLI ORDINI, Esoteric Circle

Riscritta dall'Architetto in Cowork il 29 luglio 2026, dopo due ordini chiusi solo in parte.

## Che cosa è cambiato, e perché

I due ordini precedenti contenevano molte voci ciascuno. In entrambi i casi si sono chiuse le voci leggere e il rifacimento pesante è rimasto intatto. Un elenco si svuota sempre dal lato leggero, e la colpa è dell'elenco, non di chi lo esegue.

Quindi la coda cambia forma: **un ordine, un oggetto.** Non più liste. Ogni ordine contiene una cosa sola, e se è pesante non ha voci facili accanto che possano assorbire il tempo.

Cambia anche una regola: **la stima si dichiara all'inizio, non alla fine.** Prima di scrivere codice, dì se ce la fai e fin dove arrivi. Scoprirlo dopo un'ora ci è già costato due giri.

Resta ferma la cosa giusta che hai fatto due volte: meglio consegnare intero e verificato che abbozzato. Quel principio non si tocca. Cambia solo la dimensione di quello che si chiede.

## La sequenza

1. **`ORDINE_CORRENTE.md`** — Un solo sistema di scena. È il rifacimento più grosso che resta, ed è quello che Mauro vede ogni volta che apre l'app. Ha un oggetto solo, apposta.
2. Poi **ci si ferma** e decide l'Architetto, che avrà visto l'esito.

Gli ordini in attesa, da non aprire senza istruzione:
- `ORDINE_B_REGOLE_DELLA_CASA.md`, le otto regole trasversali violate.
- `ORDINE_ENTITLEMENT.md`, le sette verifiche sui soldi.
- Le voci di A ancora aperte: permesso di posizione, carosello dei Maestri, animazione del Sigillo e dell'Animale Guida, i tre punti di disposizione, il ripristino del Risveglio in debug. Ognuna diventerà un ordine a oggetto singolo oppure entrerà nella revisione della funzionalità a cui appartiene.

## Il push, prima di tutto

Otto commit fermi in locale, l'ultimo `09d18e9`. Prova:

```
git -C "C:\Users\user\Desktop\esoteric-circle-app" push origin claude/esoteric-circle-master-order-e798aj
```

Se il gestore delle credenziali vuole una finestra interattiva e fallisce, scrivilo in testa all'esito e prosegui. Lo sblocca Mauro.

## Regole che valgono sempre

Una build e una distribuzione alla fine dell'ordine, destinatario unico `cloud@esotericircle.app`.

Non toccare mai `docs/STATO_VIVO.md`.

Prima di aprire un ordine, rileggi `claude/Indice_delle_Prescrizioni_Esoteric_Circle` nel Project: se il blocco può chiudere anche altre righe marcate ASSENTE o VIOLATA senza costo aggiuntivo, fallo e dillo nell'esito.

Italiano. Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e. Accenti veri.

## IN CODA, dall'ordine S: la guardia dei 165 traguardi contro l'Allegato A

**Chiesta da Mauro il 13 agosto 2026**, insieme alla guardia delle diciassette
cornici, che invece e' stata fatta subito (`test/le_cornici_coincidono_con_la_fonte_test.dart`).

**LA RAGIONE PER CUI NON SI FA ADESSO NON E' IL COSTO, ed e' importante.** Per i
traguardi non esiste una regola di verbatim da presidiare. La CORREZIONE DI MAURO
DEL 12 AGOSTO 2026, che il manifesto dell'ordine P registra sulla voce P.19, dice:
le tre guardie quantitative dell'ordine O vincono sull'Allegato A, gli obiettivi non
si sostituiscono, e **dall'Allegato si prendono nome, perche' conta e cosa apre DOVE
MIGLIORANO**. "Dove migliorano" non e' verbatim: e' adozione selettiva, e una
guardia che pretendesse la coincidenza carattere per carattere farebbe cadere una
regola che nessuno ha dato.

**LA MISURA, perche' il numero conti piu' dell'impressione.** L'Allegato A porta
**150** traguardi (50 per sentiero, con i nomi M01 fino a M50 e cosi' per A e C). Il
codice ne porta **165** (55 per sentiero: 50 mini piu' 5 grandi). Dei 150 nomi
dell'Allegato, il codice ne porta verbatim **OTTO**: gli altri 142 sono testi
diversi, per esempio "La prima luce", "Il passaporto", "Lo specchio degli altri",
"Il segno che sale", "Tre albe di fila", "La prima stesa". Le due liste non
divergono per una lettera: sono due insiemi diversi.

**LE TRE STRADE, e la scelta e' di Mauro perche' e' materiale suo.**
1. **Guardia limitata all'adottato:** per i traguardi il cui NOME viene
   dall'Allegato, il perche' conta e il cosa apre devono coincidere con la fonte.
   Oggi sarebbero otto. Costo basso, e presidia esattamente cio' che la correzione
   del 12 agosto ammette.
2. **Riallineamento all'Allegato:** i 165 del codice si riportano ai testi
   dell'Allegato dove l'Allegato ha una voce corrispondente. Non e' una prova, e' un
   lavoro di contenuto sui testi, e va deciso voce per voce da chi li ha scritti.
3. **Niente guardia, e sta scritto perche':** i traguardi restano governati dalle
   guardie quantitative dell'ordine O e dalla correzione del 12 agosto, che sono
   presidiate. Questa e' la situazione di oggi, e senza una riga come questa nessuno
   saprebbe che e' una scelta e non una dimenticanza.

**Nel frattempo NON e' vero che i traguardi non hanno guardie:** ne hanno sei
quantitative (`test/i_traguardi_del_cammino_test.dart` e le prove
dell'ordine O), che contano le posizioni, la curva Eos, l'obbligatorieta' del campo
cosa apre e l'aritmetica per sentiero. Cio' che manca e' solo il confronto coi TESTI
della fonte.
