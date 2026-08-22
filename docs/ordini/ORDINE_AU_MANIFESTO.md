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
- **AU.04** La mano ferma. Stato: APERTA
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
VOCI_APERTE: 12
VOCI_CHIUSE: 2
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
