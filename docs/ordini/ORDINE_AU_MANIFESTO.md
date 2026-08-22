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
- **AU.01** Medora, l'alpha dalla luminanza. Stato: APERTA
- **AU.02** Aura torna grande come le altre. Stato: APERTA
- **AU.03** Il corpus si corregge qui. Stato: CHIUSA
  (**TUTTE E VENTITRE' LE CORREZIONI HANNO MORSO**, e il conto dell'ordine non
  torna: l'ordine annuncia diciotto correzioni e poi ne elenca ventitre', cioe'
  DODICI condizioni sotto un titolo che dice dieci piu' UNDICI nomi. Si e'
  applicato l'elenco, che e' il dato, e non il titolo, che e' il riassunto.
  Le scrive `tool/genera_corpus_d2.py`, che CADE se una correzione non trova
  la sua voce: una correzione che non morde e' peggio di una mancante, perche'
  sembra fatta. **GLI EOS NON SI SONO MOSSI**, ricontati sul file nuovo: 165
  gradini, 2.010 per sentiero, 6.030 in tutto.
  **I RISVEGLIATI SONO OTTO, non sette.** Oltre ai sette che l'ordine nomina
  c'e' `med_51`, che l'ordine faceva riscrivere senza elencarlo fra i
  risvegliati: tolto il "dodici mesi di seguito" la condizione diventa
  costruibile da sola. I dormienti del codice generato passano da 25 a 17, e i
  17 che restano hanno tutti una ragione vera e dichiarata, non aritmetica:
  cinque per un motore che non esiste, eclissi e meditazione, gli altri per
  dettagli che la scena non manda.
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
- **AU.05** I Maestri non coprono piu' niente. Stato: APERTA
- **AU.06** Una festa, un traguardo. Stato: APERTA
- **AU.07** La card del traguardo, dignita' e tipografia. Stato: APERTA
- **AU.08** Il grigio che non si legge, censimento totale. Stato: APERTA
- **AU.09** Le perle del Loto al centro dei fiori. Stato: APERTA
- **AU.10** La pila che non torna indietro. Stato: APERTA
- **AU.11** Il borsellino si aggiorna ovunque. Stato: APERTA
- **AU.12** L'Arcano del Giorno, i testi sopra la carta. Stato: APERTA
- **AU.13** Il tooltip dei tre sentieri. Stato: APERTA

## I marcatori

VOCI_TOTALI: 14
VOCI_APERTE: 11
VOCI_CHIUSE: 3
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
