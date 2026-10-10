# ORDINE FB, TUTTI GLI AMICI NELLA TENDINA

**Sigla:** FB. **Data dell'ordine:** 4 ottobre 2026, un pezzo. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`, nessun altro. **Partenza:**
commit `6d0ba515`, la testa col lavoro dell'ordine FA.

**Regole in primo piano.** R5, la prova di vista con l'innesto verificato
entrato (registro `docs/collaudo/FB/regola_a_fb.txt`). R9, la build la ordina
il fondatore: questo ordine non ne fa. R11, nessuna chiamata al modello. R14,
nessuna voce aumenta il costo: misurato in euro coi prezzi del catalogo di
Google, nel rapporto.

**Le funzioni non sono pubblicate.** La voce FB.01 cambia il server: il
comando per il fondatore sta nel rapporto. Nessun indice nuovo: il file degli
indici torna a zero indici composti, come la produzione (letta il 4 ottobre
2026, zero).

VOCI_TOTALI: 3
VOCI_CHIUSE: 2
VOCI_APERTE: 1
VOCI_DA_FARE: 0

## VOCE FB.01, TUTTI GLI AMICI PRESENTI, SENZA TETTO

**APERTA IN ATTESA DI VERIFICA.** Il tetto dei sei (`AMICI_NELLA_TENDINA`) e'
tolto, sul server e nel nome. La presenza non sta piu' in un documento per
persona: sta nella sua voce dentro uno di novantasei frammenti condivisi
(`cerchio_presenze/{k}`), e l'istantanea, ricostruita dai frammenti, porta
tutti i presenti non invisibili. La tendina incrocia IN MEMORIA l'istantanea
coi legami che legge gia': zero letture per amico. L'istantanea la ricostruisce
solo il passo della presenza (una volta ogni trenta secondi per tutto il
Cerchio, a turno preso in transazione), mai la tendina, che la legge com'e';
legge solo i frammenti che esistono, e cancella quelli rimasti vuoti, cosi'
con pochi presenti non costa piu' dell'ordine FA. Il
telefono non riceve mai l'elenco dei presenti: la tendina restituisce solo gli
amici di chi chiede. I due tetti stanno insieme: il documento dell'istantanea
tiene al massimo cinquemila presenti, e i frammenti ne reggono 5.760. Il
telefono mostra tutti gli amici che riceve, scorrendo. Il server va
pubblicato; finche' non lo e', la tendina in produzione e' quella di prima.

DOMANDA: "la tendina deve mostrare TUTTI gli amici presenti, non sei"
PROVA: test/la_tendina_non_supera_dieci_letture_test.dart
MISURA: letture di un'apertura contate sul codice della tendina: prima (ordine FA) 4 fisse piu' gli amici presenti fino a 6, cioe' 10 con 10 amici presenti e 10 con 150, e se l'apertura trovava l'istantanea vecchia la rifaceva (44 letture con l'ordine EZ, 102 nella prima stesura di questa voce coi frammenti); dopo 5 con 10 amici presenti e 5 con 150 (tetto, identita', legami, blocchi, istantanea), letture dentro un giro 0, tetti sugli amici 0; amici presenti a schermo con 150 presenti prima 6, dopo 150 righe viste scorrendo; una voce dell'istantanea al massimo 172 byte, ne stanno 6.096 in un mebibyte, il tetto dichiarato 5.000 occupa 860.350 byte, l'82,0 per cento, e la prova cade sopra l'85; i frammenti reggono 5.760 presenti a un passo al minuto; la ricostruzione legge il turno e i frammenti che esistono, 2 documenti con un presente solo e 97 con mille come con centomila, una volta ogni trenta secondi per tutto il Cerchio; costo in euro al mese con N presenti tutto il mese (docs/collaudo/FB/i_costi_in_euro.txt), prima e dopo: 1 presente 0,53 e 0,27, 10 presenti 1,25 e 0,83, 100 presenti 6,55 e 5,74, 1.000 presenti 56,10 e 42,41, 5.000 presenti 528,31 e 201,69
ACCETTAZIONE: aprendo la tendina con molti amici presenti, li vedo tutti scorrendo, e sotto di loro c'e' ancora "Il Cerchio adesso"

## VOCE FB.02, IL SIGILLO SEMPRE FRA I BLOCCATI

**CHIUSA.** Nell'elenco delle persone bloccate il sigillo c'e' sempre, anche
senza nomi uguali, con la ragione scritta accanto nel codice: e' l'unico
elenco in cui un errore di persona fa un danno, perche' sbloccare la persona
sbagliata riapre la porta a chi si era voluto tenere fuori. Il sigillo sta
sotto il nome, com'era prima dell'ordine FA: accanto, nella riga stretta fra il
pallino e "Sblocca", riduceva il nome a "Brina Lu...", visto nell'anteprima.
Negli altri elenchi resta la regola dell'ordine FA voce 04. E quella regola
aveva un difetto, trovato guardando l'anteprima: nome e sigillo stavano in un
solo testo coi puntini in coda, e dove la riga era stretta i puntini
mangiavano proprio il sigillo. Adesso si accorcia il nome e il sigillo resta
intero.

DOMANDA: "nell'elenco dei bloccati il sigillo va mostrato sempre: e' l'unico elenco in cui un errore di persona fa un danno"
PROVA: test/il_sigillo_sempre_fra_i_bloccati_test.dart
MISURA: righe dei bloccati col sigillo disegnato intero (largo quanto il suo testo, prima di "Sblocca") e col nome intero, su tre bloccati dai nomi tutti diversi: prima 0 su 3, dopo 3 su 3 (Z9P0 35,8 su 35,8 punti, H3TW 48,7 su 48,7, Q8LM 45,6 su 45,6); sigilli negli altri elenchi senza nomi uguali, il tuo Cerchio e la tendina, prima 0, dopo 0; coi due "Eco Corvo Mite" sigilli a schermo 2 su 2, come con l'ordine FA
ACCETTAZIONE: fra le persone bloccate leggo sotto ogni nome il suo sigillo, e nel resto del Cerchio il sigillo compare solo accanto a due nomi uguali

## VOCE FB.03, IL RAPPORTO EZ COME CONSEGNATO

**CHIUSA.** Il rapporto dell'ordine EZ ha di nuovo il corpo consegnato
(l'impronta del corpo e' quella del commit `31821ce2`), e in coda una riga
sola dice che l'ordine FA ha chiuso EZ.03 fissando la soglia, con la data e la
prova. Il manifesto EZ resta com'e'. La guardia che pretendeva l'elenco in
cima uguale al manifesto di oggi era sbagliata, ed e' corretta: e'
`ogni_voce_chiusa_porta_la_sua_prova_test.dart`, e spingeva a falsare un
rapporto consegnato, perche' una voce chiusa da un ordine successivo poteva
entrare nell'elenco in cima solo riscrivendolo. Adesso una voce chiusa dopo e'
in regola se una riga `**Aggiunta del` in coda la nomina con la sua prova. La
regola vale da qui in avanti e ha la sua guardia: ogni rapporto consegnato ha
nel registro `docs/ordini/RAPPORTI_CONSEGNATI.txt` l'impronta del suo corpo.

DOMANDA: "il rapporto consegnato non si corregge nel corpo: si aggiunge una riga in coda"
PROVA: test/i_rapporti_consegnati_non_si_correggono_test.dart
MISURA: righe del corpo del rapporto EZ diverse dalla consegna prima 1, dopo 0; righe in coda prima 0, dopo 1; rapporti col corpo protetto da un'impronta prima 0, dopo 50; voci chiuse dopo la consegna trovate nelle aggiunte in coda 1 (EZ.03)
ACCETTAZIONE: il rapporto EZ dice i numeri consegnati, e la chiusura di EZ.03 la leggo nell'ultima riga
