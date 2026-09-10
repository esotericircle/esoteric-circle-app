# ORDINE DA, LE QUATTRO IDEE DEL MANIFESTO DB

**10 settembre 2026.** Ramo `claude/esoteric-circle-master-order-e798aj`.

**DA DOVE VIENE QUEST'ORDINE.** Chiudendo l'ordine DB, *La Meditazione che
ricorda*, avevo scritto nella voce DB.12 sei cose che il lavoro aveva fatto
venire in mente e che l'ordine non chiedeva. Il fondatore ha risposto
*"procedi con i tuoi consigli e suggerimenti"*, e poi ha nominato quattro di
quelle cose per esteso: **il respiro da solo per chi medita sdraiato e non
puo' tenere il dito, l'ora del Soffio che segue la persona, la sessione
interrotta che porta una pratica piu' corta, il Sigillo del Sogno che legge il
respiro della giornata.**

**PERCHE' LA SIGLA E' DA E NON DC.** Mentre chiudevo questo lavoro e' arrivato
l'ordine DC del fondatore, *Il Viaggio dello Sciamano*, e il progetto vuole
che le sigle non si scavalchino. Le lettere erano arrivate fino a CZ piu' DB,
e **nessun file cominciava per DA**: questo lavoro ha preso la prima libera, e
l'ordine del fondatore ha tenuto la sua.

---

## DA.01, IL DITO CHE SCIVOLA A OCCHI CHIUSI

**Il fatto.** L'app chiede di respirare a occhi chiusi. A occhi chiusi il dito
scivola, e uno scivolo di un attimo valeva come un dito alzato: il respiro si
chiudeva a meta' e il successivo ripartiva da zero.

**La cura, e il numero.** Un distacco sotto **duecento millisecondi** e'
rumore, non una decisione. `sogliaDelTremolio` sta in
`lib/core/sensi/respiro_guidato_dal_dito.dart`, e quando il dito torna giu'
dentro quella finestra **l'inspiro riprende col suo tempo** invece di
ricominciare. I tremolii assorbiti si contano, cosi' il numero esiste e si
puo' guardare.

## DA.02, IL RESPIRO CHE NON E' UN RESPIRO

**Il fatto.** Se l'app va in secondo piano col dito giu', quel mezzo respiro
dura minuti. Finiva nella media, nella figura della card e nella memoria: un
respiro da sette minuti spostava tutto quello che veniva dopo.

**La cura, e il numero.** Sopra **sessanta secondi** un respiro si scarta,
perche' `respiroPiuLungoCheAbbiaSenso` dice che oltre quel confine non e' piu'
un respiro. **Gli scartati si contano**: un dato buttato in silenzio e' un
dato che nessuno potra' mai rimettere in discussione.

## DA.04, L'ORA DEL SOFFIO SEGUE CHI RESPIRA

**Il fatto, e la prima stesura era mia e sbagliata.** Avevo scritto un confine
a **distanza**: non piu' di sei ore dall'ora di partenza. **Non serviva il
caso per cui era nato.** Chi respira alle 22 sta a dodici ore da meta'
mattina, quindi la proposta non poteva mai arrivarci, ed era proprio quella la
persona da servire.

**La cura.** Il confine e' **un'ora e non una distanza**: mai fra l'una e le
sei del mattino. `lib/core/maestro/ora_del_respiro.dart`, con
`nonPrimaDelle` e `nonDopoLe` in un punto solo.

## DA.05, LA PRATICA CHE STA NEL TUO TEMPO

**Il fatto.** A chi lascia a meta' piu' di **una sessione su tre**, Aura
propone una pratica piu' corta invece di ripetere quella che non finisce.

**E LA GUARDIA HA TROVATO UN DIFETTO PIU' GRANDE DELLA VOCE.** La libreria
delle pratiche **non aveva niente sotto i cinque minuti**: la proposta
esisteva, la legge era scritta, e non c'era niente da proporre. **Era una
porta che arrivava a mani vuote**, la stessa famiglia di difetto che l'ordine
DC ha poi trovato altre due volte. Aggiunte due pratiche brevi vere, da due e
da tre minuti.

## DA.06, IL SIGILLO DEL SOGNO LEGGE IL RESPIRO DI OGGI

**Il fatto.** Il Sigillo del Sogno chiedeva una cosa generica. Adesso, **se
oggi si e' respirato**, porta un fatto della giornata: quanto e' durato il
respiro, quante volte ci si e' fermati.
`lib/core/maestro/il_respiro_di_oggi.dart`.

**E se oggi non si e' respirato, non inventa niente.** Un fatto che non c'e'
non si sostituisce con uno verosimile.

---

## Le guardie

| guardia | prove | cosa sorveglia |
| --- | ---: | --- |
| `il_dito_scivola_e_il_respiro_regge_test.dart` | 7 | il tremolio assorbito, il respiro troppo lungo scartato, i due conti |
| `la_meditazione_si_adatta_a_chi_respira_test.dart` | 13 | l'ora del Soffio, la mediana della durata, la pratica piu' corta che esiste davvero, il respiro di oggi |

**Tutte e due nate rosse**, e la seconda ha trovato il difetto della libreria
vuota mentre nasceva.

---

VOCI_TOTALI: 5
VOCI_CHIUSE: 5
VOCI_APERTE: 0
SIGLA_PRESA: DA, la prima libera, per non scavalcare l'ordine DC del fondatore
GUARDIE_NUOVE: 2
PROVE_NUOVE: 20
DIFETTI_TROVATI_DALLE_GUARDIE_MENTRE_NASCEVANO: 2
PREMESSE_MIE_CADUTE_ALLA_MISURA: 1, il confine a distanza della voce DA.04
PORTE_CHE_ARRIVAVANO_A_MANI_VUOTE: 1, la libreria senza pratiche brevi
