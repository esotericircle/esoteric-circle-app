# ORDINE BE, il manifesto

**IL COLLAUDO DELLA 2199 E LA PULIZIA DEL VECCHIO.** Dieci voci, dalla BE.00
alla BE.09, sul ramo `claude/esoteric-circle-master-order-e798aj`. Nasce dal
collaudo del fondatore sulla build 2199, con gli screenshot agli atti.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_be_guard_test.dart`
conta sulle righe.

## Le premesse, verificate prima di lavorare

**Tutte le premesse del fondatore reggono alla verifica. Tre cause sono gia'
individuate sul codice, e si dichiarano qui.**

### BE.02: la causa e' una rotta senza nome

La barra sottile non deve vedersi nell'onboarding, e la regola c'e'
(`soglieSenzaBarraSottile` la elenca). Ma `schermataInCima()` legge
`pila.last`: quando il selettore di giorno, mese o anno apre la sua tendina,
in cima alla pila c'e' la `PopupRoute` del menu, il suo nome non e'
conosciuto, e **per il nulla la barra si vede**, scritto nel commento stesso
del file. La tendina poi le scorre sopra. Due difetti, una causa.

### BE.05: la card vecchia e' la FORMA BREVE della celebrazione

`Celebrazione.festeggiaInsieme` ha due strade: i traguardi grandi e il primo
in assoluto montano la rotta piena (spirale, CONGRATULAZIONI, data), tutti
gli altri passano da `mostraLaSovrimpressione`, la sovrimpressione breve su
velo scuro senza spirale e senza data. E' esattamente la schermata "IL PRIMO
MATTINO" dello screenshot: non un relitto dimenticato, una strada ancora
dichiarata nel codice, che la decisione di questo ordine demolisce.

### BE.07 punto 3: i dati tornano perche' il backup di Android riporta l'identita'

Le regole di backup escludono `FlutterSharedPreferences.xml` (per la
fotografia del volto), **ma non escludono le preferenze di Firebase Auth**:
alla reinstallazione Android ripristina i gettoni di accesso, l'app torna a
parlare al server con la STESSA identita' di prima, e il server le rende
saldo e traguardi. Il fondatore ha visto 270 Eos su un'app "mai registrata"
perche' l'identita' era tornata dal backup senza che nessuno glielo dicesse.
E' insieme il difetto della voce 07 e una strada d'abuso della voce 08.

### BE.03: la premessa regge, e la strada di BD.03 non basta

La regione a griglia dell'ordine BD e' stata guardata sugli screenshot del
fondatore: su Parigi, Seul e New York la sagoma non si riconosce, ha ragione
lui. I poligoni grossolani del planisfero funzionano da lontano e non
reggono lo zoom. La fonte vera era gia' nominata nel codice come lavoro di
un altro giorno: **Natural Earth, pubblico dominio**. Quel giorno e' questo.

### BE.06 punto 1: la voce BB.08 si riapre

Dichiarata chiusa col responso BB, sul telefono del fondatore il tocco resta
muto. La snackbar di BB.08 vive nella schermata della Runa del Tramonto; la
card "Non so dove sei" del Rito dell'Alba e' un'altra strada, e va guardata
per conto suo.

## Le voci

- **BE.00** Manifesto e verifica delle premesse. Stato: CHIUSA
- **BE.01** I Maestri: lo spazio sotto e la fluttuazione. Stato: CHIUSA
- **BE.02** L'onboarding sotto la barra. Stato: CHIUSA
- **BE.03** La citta' straniera. Stato: APERTA
- **BE.04** La bolla dei sentieri: titolo e frase. Stato: CHIUSA
- **BE.05** La card vecchia va demolita. Stato: CHIUSA
- **BE.06** Il Rito dell'Alba: posizione muta e testi sul mare. Stato: APERTA
- **BE.07** La cancellazione immediata e il ritorno dei dati. Stato: APERTA
- **BE.08** Il sistema anti abuso, censimento completo. Stato: APERTA
- **BE.09** Il peso del traguardo, presentato per la scelta. Stato: APERTA

## L'ordine di lavoro, deciso qui

1. **BE.05**, la demolizione: e' la piu' netta, e libera le feste appena
   sistemate.
2. **BE.04**, la bolla dei sentieri: titolo e frase.
3. **BE.02**, la rotta senza nome: una causa, due difetti.
4. **BE.01**, i Maestri: spazio sotto e fluttuazione.
5. **BE.06**, l'Alba: leggibilita' e la posizione muta.
6. **BE.03**, le nazioni vere: l'asset nuovo di Natural Earth.
7. **BE.07**, la cancellazione immediata: telefono, server e backup insieme.
8. **BE.08**, il censimento anti abuso, che sulla 07 poggia.
9. **BE.09**, la presentazione del nodo del peso, nel rapporto.

## I marcatori

VOCI_TOTALI: 10
VOCI_APERTE: 5
VOCI_CHIUSE: 5
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
