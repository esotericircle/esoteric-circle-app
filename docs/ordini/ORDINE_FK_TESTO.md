# ORDINE FK, IL DART NON RIGENERATO, LA FONTE DI WAITE, LA FONTE DEI SIGNIFICATI

Il testo dell'Architetto come e' arrivato l'11 ottobre 2026 in tre pezzi. Trascritto senza toccarlo.

---

# ORDINE FK, IL DART NON RIGENERATO, LA FONTE DI WAITE, LA FONTE DEI SIGNIFICATI
# Architetto, 11 ottobre 2026. Ramo claude/esoteric-circle-master-order-e798aj.

# FK, pezzo 1 di 3

L'ordine ha otto parti in tre pezzi. Questo pezzo porta le Parti 1 e 2.

ATTENZIONE SUL PUNTO DI PARTENZA. Il tuo rapporto dell'ordine FJ dichiara il
remoto a d169c7ec, e lo era quando l'hai scritto. Non lo è più: il remoto è a
24cf424, verificato con git ls-remote l'11 ottobre 2026 alle 20.32. Due commit
sono entrati dopo la tua consegna, e sono miei.

Ogni voce dichiara la sua fonte. Le fonti di questo ordine sono sei:
le frasi del fondatore in chat l'11 ottobre 2026; il tuo rapporto dell'ordine
FJ col suo numero di punto; il manifesto dell'ordine FJ con la sua voce; il
ramo al commit 24cf424, col file e la riga; i documenti
docs/STATO_VIVO.md e docs/corpus/tarocchi_posizione/verifica_waite_1911.md,
con la sezione; i documenti dei costi in docs/costi/.

DICHIARAZIONE DEL FONDATORE SULL'ORDINE, parola sua dell'11 ottobre 2026:
"NON VOGLIO ALCUN TIPO DI TUA INIZIATIVA NELL'ORDINE". Quest'ordine non porta
nessuna proposta dell'Architetto. Dove una decisione serve, la voce porta i
numeri misurati e dice che la scelta è tua, e il fondatore ha stabilito nello
stesso scambio che l'Architetto non decide: "In ordine di importanza: 1 Code,
2 agenti e subagenti, 3 tu. Ma meglio che tu non decida niente se possibile."


## PARTE 1, IL DART NON RIGENERATO

È la sola parte che cambia oggi un fatto dell'app: tre posizioni piene nella
fonte non sono nel codice. L'ordine di esecuzione delle altre parti è tuo.

### FK.01 Il pull, prima di qualunque altra cosa

FONTE: il ramo, git ls-remote del 11 ottobre 2026.

Porta la tua cartella a 24cf424 prima di toccare qualsiasi file. I due commit
che non hai sono 019612d (lo stato vivo del corpus posizionale) e 24cf424 (la
fonte di Waite verificata, più il documento
docs/corpus/tarocchi_posizione/verifica_waite_1911.md, 257 righe, nuovo).

Se la tua cartella ha modifiche non committate, fermati e dillo: non le
sovrascrivo io a scatola chiusa.

### FK.02 Rigenera il Dart dei testi nella posizione

FONTE: docs/STATO_VIVO.md, sezione "IL CORPUS POSIZIONALE DEI TAROCCHI, LO
STATO CONTATO SUL RAMO (11 ottobre 2026, sera)", e la voce FI.39.

Lo stato contato sul ramo: nella fonte ci sono 2.340 testi su 6.552, cioè
quattro posizioni complete a 468 (lato, consultante, esito, carta_sola), tre
a 156 (passato, presente, futuro, la sola variante 1) e sette a zero. Nel
Dart lib/core/tarot/le_carte_nella_posizione_dati.dart ce ne sono 936 di
quattro posizioni sole: passato 156, presente 156, futuro 156, lato 468.
L'ultimo commit che ha toccato quel file è d169c7ec, cioè la tua consegna di
FJ, prima dei quattro commit del corpus.

Quindi i 1.404 testi di cartaSola, consultante ed esito non sono nell'app, e
registriDelleCarte è la mappa vuota (riga 2201).

Lancia python tool/genera_carte_nella_posizione.py. Se si ferma, il difetto è
nella fonte e lo dichiari con la riga esatta.

### FK.03 Alza variantiDichiarate

FONTE: il ramo, test/il_corpus_delle_posizioni_test.dart, e la voce FI.39.

Quel file dichiara ancora cartaSola: 0, consultante: 0, esito: 0 e
registriConsegnati = false, mentre le prime tre fonti sono piene a 468.
La guardia pretende per sua testata che la dichiarazione sia vera.

Flutter non è installato nell'ambiente dell'Architetto: l'esito di quella
guardia non è stato letto e non viene dichiarato di che colore sia. Si
dichiara soltanto che la dichiarazione e la fonte non coincidono.

### FK.04 I ventidue gruppi del lato che nel Dart sono vecchi

FONTE: docs/STATO_VIVO.md, stessa sezione.

Dentro il Dart, ventidue gruppi carta-verso del lato divergono da lato.md,
confrontati testo per testo: sono esattamente i ventidue gruppi riscritti dal
commit f5d6fce, fra cui Gli Amanti capovolta, La Giustizia capovolta e Tre di
Bastoni capovolta. Sono 66 testi agganciati in una stesura superata.

La rigenerazione di FK.02 li rinfresca. Verifica che dopo il giro non resti
nessuna divergenza fra lato.md e il Dart, e dichiara come l'hai verificato.

### FK.05 Dichiara il colore delle guardie del corpus

FONTE: docs/STATO_VIVO.md, stessa sezione, che dichiara di non aver letto
l'esito.

Dopo FK.02 e FK.03, fai girare le guardie del corpus delle posizioni e
dichiara il loro esito. Vale la Regola B del protocollo delle guardie: le
zone che questa parte tocca sono già coperte da guardie, quindi quelle
guardie si vedono rosse PRIMA di metterci mano, e la data si aggiorna nel
registro docs/guardie.md.


## PARTE 2, LE CINQUE DECISIONI CHE IL FONDATORE ASSEGNA A TE

FONTE DI TUTTA LA PARTE 2: frase del fondatore in chat l'11 ottobre 2026,
"1 Code, 2 agenti e subagenti, 3 tu. Ma meglio che tu non decida niente se
possibile", pronunciata sulle quattro decisioni che l'Architetto gli aveva
girato, più la quinta che tu avevi girato all'Architetto.

Ogni voce porta la misura e non porta una proposta. Decidi tu, e scrivi nel
rapporto la ragione della scelta.

### FK.06 I registri prima oppure dopo le sette posizioni che mancano

docs/corpus/tarocchi_posizione/registri.md ha 468 posti, 0 pieni, contati con
grep -c sulle righe "- amore:", "- lavoro:" e "- vita:", 78 carte e 156
carte-verso. La sua testata dice che un gruppo è pieno in tutte le 156
carte-verso o vuoto in tutte, e che i registri valgono solo coi tre gruppi
pieni, altrimenti il tool si ferma.

Il dato che pesa sulla scelta: i registri non si mostrano alla persona,
entrano nella richiesta al modello come taglio, in
lib/core/tarot/la_lettura_dal_modello.dart righe 337-352, per la voce FJ.23.

Le sette posizioni che mancano sono copre, attraversa, corona, sotto,
se_stesso, la_casa e speranze_o_timori, a zero testi su 468 ciascuna.

### FK.07 Lo stampo della variante 1 di passato, presente e futuro

Lo stampo è la ripetizione delle cinque forme che
lib/core/tarot/la_lettura_dal_modello.dart riga 276 prescrive al modello:
"scrivi al presente", "tendi a", "puoi", "potresti", "rischi di", "la
situazione tende a".

La misura, dalla sezione 21.2 del metro del corpus: lo stampo è stato tolto
da centoventisei gruppi riscrivendo la sola parte che lo conteneva, e in
prova cieca i gruppi senza stampo hanno fatto 377 su 381 contro 375 su 381
con lo stampo, cioè più zero virgola cinque punti.

La variante 1 delle tre posizioni sono 468 testi.

La misura della prevenzione, sugli stessi strumenti: l'apertura più frequente
della posizione carta sola, scritta col repertorio delle alternative, compare
in 15 testi su 468; quella dell'esito, scritta senza repertorio, ne occupava
40 su 468.

### FK.08 Se dietro e davanti prendono un file proprio

Oggi non hanno file e leggono il corpus di passato e futuro: verificato in
lib/core/tarot/tarot_spread.dart riga 19, in tarot_spread_type.dart righe 95
e 96 e nell'elenco di dieciCarte, che al quinto e al sesto posto mette
SpreadPosition.passato e SpreadPosition.futuro.

Dargli un file proprio costa 936 testi, cioè un quinto in più di tutto il
lavoro che resta sul corpus.

Il dato nuovo che cambia la domanda sta in FK.11: la glossa di Waite per la
quinta carta nomina due stati e non uno, e la forma mozza che il progetto
citava li teneva insieme.

### FK.09 Se la trascrizione di grado basso basta, oppure se il facsimile si compra

Lo stato della fonte sta in
docs/corpus/tarocchi_posizione/verifica_waite_1911.md, sezione finale: fonte
citabile sì, ma di grado basso, una sola trascrizione senza facsimile.

Nessuna scansione dell'edizione Rider 1911 è stata raggiunta. Su archive.org
esistono sette esemplari e nessuno è di quell'edizione: sono riedizioni 1959,
1971 e 1975 in prestito limitato. Le due copie a testo pieno di archive.org
sono stampe della pagina web di sacred-texts, riconoscibili dal piedipagina
"pkt0102.htm (1 of 5) [13/10/2002]". HathiTrust e Project Gutenberg hanno
risposto ROBOTS_DISALLOWED, Wikisource URL_NOT_FOUND.

Il fondatore ha dichiarato in passato la disponibilità a comprare le fonti
che non si riescono a leggere. Se la tua scelta è comprare, la voce torna a
lui perché è una spesa con la sua carta, e il fondatore ha dichiarato l'11
ottobre 2026: "Sto pagando con la carta".

### FK.10 La grandezza della guardia sulla fonte dei significati

La voce FJ.35 del tuo manifesto dichiara: "la soglia che l'aggiunta chiede
non esiste... La scelta della grandezza è dell'Architetto: i numeri nel
rapporto". Il fondatore ha stabilito che l'Architetto non decide, quindi la
scelta torna a te coi numeri misurati.

Primo numero, dal tuo rapporto: nove collisioni su ventitré hanno zero radici
rare in comune perché sono collisioni di sinonimi, e nessuna misura lessicale
le vede.

Secondo numero, misurato dall'Architetto sulle 156 voci di
lib/core/tarot/tarot_card.dart al commit 24cf424, contando gli n-grammi di
parole condivisi fra carte diverse, campi upright e reversed:
- frasi di sei parole condivise fra due carte: ZERO coppie;
- frasi di cinque parole: CINQUE coppie;
- frasi di quattro parole: VENTINOVE coppie, in gran parte riempitivi come
  "è il momento di".

Le cinque coppie a cinque parole, per nome:
- Il Matto dritta e Gli Amanti dritta, "il cielo ti chiede di";
- Il Carro dritta e Re di Bastoni dritta, "è il momento di prendere";
- Asso di Bastoni dritta e Asso di Denari dritta, "è il momento giusto per";
- Sei di Bastoni capovolta e Regina di Bastoni capovolta, "un dubbio su di te";
- Sette di Coppe dritta e Regina di Denari dritta, "con i piedi a terra".

Terzo numero, che mostra il limite della misura: L'Imperatrice capovolta e
Regina di Denari capovolta hanno Jaccard 0,000, cioè non condividono una sola
parola di contenuto, e dicono la stessa cosa. Vedi FK.16.

Quarto numero, sulla fragilità della misura: la coppia Quattro di Denari e Re
di Denari capovolta era stata registrata a 0,06 e con un tokenizzatore
diverso misura 0,038. Il numero si muove secondo come si spezzano le parole.

Nota: la tua voce FJ.35 dichiara che la guardia regge già tre regole
misurabili, e una delle tre è "nessuna frase di sei parole in comune". La
misura dell'Architetto dice che oggi quella regola è vera con zero coppie.

---

# FK, pezzo 2 di 3
# Porta le Parti 3 e 4.


## PARTE 3, LA FONTE DI WAITE, VERIFICATA ALLA LETTERA

FONTE DI TUTTA LA PARTE 3: il documento
docs/corpus/tarocchi_posizione/verifica_waite_1911.md, entrato nel ramo col
commit 24cf424, 257 righe. Le citazioni sono state lette due volte: da un
agente di ricerca sulla trascrizione dell'Internet Sacred Text Archive
(https://sacred-texts.com/tarot/pkt/pkt0307.htm, Parte III sezione 7, "An
Ancient Celtic Method of Divination") e poi di persona dall'Architetto sulla
stessa pagina.

### FK.11 La glossa della quinta carta nomina due stati, non uno

I documenti del progetto citano per la quinta carta, cioè dietro, la forma
"the influence that is just passed or passing away".

Il testo del volume è:
"This is behind him. It gives the influence that is just passed, or is now
passing away."

La forma del progetto ha perso una virgola e due parole, is now. Non è una
svista ortografica: "that is just passed" vuol dire appena trascorso e
concluso, "or is now passing away" vuol dire che sta svanendo in questo
momento. Sono due cose diverse, e la forma mozza le teneva insieme.

La stringa "the influence that is just passed or passing away" risulta
ASSENTE dal volume. Quella con la virgola e con is now risulta presente come
sottostringa esatta.

### FK.12 Il confine fra sotto e dietro va ritracciato sul testo vero

Nel volume, la quarta carta, cioè sotto, è:
"This is beneath him. It shews the foundation or basis of the matter, that
which has already passed into actuality and which the Significator has made
his own."

Quindi sotto è il passato diventato fondamento, e dietro è il passato appena
staccato oppure in dissoluzione adesso. Il confine fra le due è il più
costoso della stesa a dieci carte e poggiava sulla forma mozza di FK.11.

Conseguenza diretta su FK.08: dietro non ha file proprio e legge il corpus di
passato.md, che oggi porta una variante sola. La domanda che la decisione
deve risolvere è se un testo solo possa reggere entrambi gli stati che Waite
distingue.

La sesta carta, cioè davanti, verificata nello stesso giro:
"This is before him. It shews the influence that is coming into action and
will operate in the near future."
La grafia è shews, arcaica, non shows.

### FK.13 Delle cinque citazioni controllate una sola è fedele

Controllate per sottostringa esatta, non a memoria.

FEDELE, con una riserva: la terza carta.
"It represents (a) the Querent's aim or ideal in the matter; (b) the best
that can be achieved under the circumstances, but that which has not yet been
made actual."
La riserva: il soggetto nel volume è It e non This card, quindi la parentesi
quadra che i nostri documenti mettono è nostra ed è obbligatoria.

ALTERATE, quattro:
- settima carta, tre difetti: virgole al posto dei trattini, shows per shews,
  circumstance per circumstances;
- ottava carta, un difetto: "matter, for instance" per "matter--for instance";
- decima carta, un difetto: shown per shewn;
- quinta carta: il caso di FK.11.

Due regole della fonte, da tenere presenti ogni volta che si cita:
- il volume usa le grafie arcaiche shews e connexion;
- ogni glossa comincia con la formula parlata ("This covers him.", "This
  crosses him." e via così), quindi citare solo la seconda frase dà una
  glossa mozza.

### FK.14 La forma mozza non è in nessun file del ramo

Cercata col grep su docs/, lib/, test/ e tool/ al commit 019612d, cioè prima
che il documento di Waite entrasse: "passing away", "just passed", "passed or
passing", "shews", "his house", "aim or ideal" e "what will come" non danno
nessuna riga. La stessa ricerca senza distinzione di maiuscole su tutto il
repository, escluso .git/, non trova niente.

Le glosse estese non sono mai entrate nel ramo: vivono nei documenti di
progetto e fuori da qui. Quindi questa correzione non ha nessuna riga di
codice da riscrivere.

Il metodo del grep sta accanto al risultato perché un grep che non trova
niente si confonde facilmente con un grep fatto male.

Ciò che il ramo cita di Waite sono quattro punti soli, tutti aperti e letti:
- lib/core/tarot/tarot_spread.dart righe 15-19, le sei formule brevi più
  l'equivalenza dietro e davanti con passato e futuro;
- lib/core/tarot/tarot_spread_type.dart righe 123-124, la stringa fonte;
- lib/core/tarot/la_chiave_di_lettura.dart righe 37-38, la tradizione della
  chiave Esoterica;
- docs/ordini/ORDINE_FI_TESTO.md righe 92-93, 129-131 e 152.

### FK.15 La formula "this crowns him" non è verificata

Il reperto di Waite elenca le formule parlate di prima, seconda, quarta,
quinta e sesta carta, e per la terza riporta l'attacco "It represents". La
formula "this crowns him", che tarot_spread.dart riga 15-19 e l'ordine FI
elencano fra le sei, NON è verificata da questo reperto e non si dichiara né
giusta né sbagliata.

Non la correggere e non la confermare: dichiara nel rapporto che resta da
vedere.

### FK.16 Il luogo esatto è Parte III sezione 7, non "capitolo"

lib/core/tarot/tarot_spread_type.dart righe 123-124 scrive:
'Arthur Edward Waite, The Pictorial Key to the Tarot, 1911, capitolo "An
Ancient Celtic Method of Divination".'

Nel volume è la Parte III, sezione 7. La stessa imprecisione sta
nell'ordine FI.

Correggila quando toccherai quelle stringhe, non prima: non vale una
modifica per sé.


## PARTE 4, LA FONTE DEI SIGNIFICATI

### FK.17 L'Imperatrice e Regina di Denari, la collisione che nessuna misura vede

FONTE: il tuo rapporto dell'ordine FJ, sezione delle decisioni che servono,
dove hai scritto che fra le coppie che nessuno ha nominato due sembrano
collisioni vere; più la misura dell'Architetto su
lib/core/tarot/tarot_card.dart al commit 24cf424.

La collisione è sulla CAPOVOLTA, e la misura lessicale dà Jaccard 0,000,
cioè le due voci non condividono una sola parola di contenuto.

L'Imperatrice capovolta, "La cura dimenticata":
"La creatività sembra bloccata, oppure [ti sei scordato di rivolgere a te
stesso|...] l'attenzione che dai a tutto il resto. Prima di far fiorire
fuori, torna a nutrire la tua radice."

Regina di Denari capovolta, "La cura dispersa":
"Ti occupi della casa, dei conti, dei bisogni di tutti: nell'elenco delle
cose da curare il tuo nome non compare."

Dicono la stessa cosa con zero parole in comune. È la dimostrazione piena
della tua voce FJ.35: nessuna misura lessicale può prendere questa coppia.

Sulla DRITTA la stessa coppia condivide invece una frase letterale,
"fioriscono nelle tue mani", che su tutte e settantotto le carte compare in
queste due e in nessun'altra.

### FK.18 Il Sole e Regina di Bastoni

FONTE: la stessa.

Jaccard 0,059 sulla dritta e 0,067 sulla capovolta, cioè praticamente zero,
con la stessa immagine della luce che qualcosa copre.

Il Sole capovolta: "L'entusiasmo è trattenuto, la luce c'è ma fatichi a
sentirla sulla pelle. Non è che il sole se ne sia andato, è che qualcosa lo
copre."
Regina di Bastoni capovolta: "Un dubbio su di te, o una gelosia che offusca
la tua luce. Torna al tuo centro."

Sulla dritta le due voci hanno la stessa chiusa in due forme: "lascia che la
tua luce scaldi anche chi ti sta vicino" contro "la tua fiamma scalda chi ti
sta intorno".

### FK.19 Le tre voci della fonte che non danno un cardine

FONTE: docs/corpus/tarocchi_posizione/collisioni_della_fonte.md, sezione 8,
coi casi segnalati dagli scrittori e verificati sulla fonte.

- Quattro di Denari: la voce DRITTA porta dentro il monito della propria
  capovolta, quindi i due versi non hanno un confine.
- Nove di Bastoni capovolta: il tratto distintivo la fonte lo dà in forma
  NEGATIVA, cioè dicendo che cosa la carta non è.
- Asso di Coppe capovolta: il tratto va DEDOTTO dalla voce dritta, perché la
  voce capovolta non lo nomina.

### FK.20 I due conflitti fra la fonte e il metro dei testi

FONTE: lo stesso documento, sezione 9.

- Tre di Coppe: la voce inchioda un ambito che il metro dei testi vieta di
  nominare.
- La Temperanza: la voce usa una parola vietata come esito dichiarato.

Sono conflitti fra due regole di casa, non difetti di scrittura: la fonte dice
una cosa e il metro ne vieta la parola. Decidi quale delle due cede e
scrivilo.

### FK.21 Due reperti dell'Architetto SONO RITIRATI, e la ragione sta qui

L'Architetto aveva annunciato al fondatore due difetti che la verifica sul
ramo ha smentito. Non eseguirli, e la voce esiste perché resti la traccia.

- "L'etichetta Te stesso dà un genere nella stessa interfaccia in cui i testi
  hanno l'obbligo di non darlo": FALSO.
  lib/core/tarot/tarot_spread.dart riga 43 porta già
  seStesso('[Te stesso|Te stessa|Tu]'), cioè la marca, e la riga 41 lo
  dichiara per esteso.
- "Nella variante 1 del futuro quarantotto testi su settantotto capovolte
  scrivono la forza come un rischio": FALSO. Contati sul file, sono DUE su
  settantotto.

Meccanismo dell'errore dell'Architetto, dichiarato per intero: i due numeri
venivano dal rapporto di un agente e sono stati riportati senza ricontarli
sul ramo.

---

# FK, pezzo 3 di 3
# Porta le Parti 5, 6, 7 e 8, più le regole fisse.


## PARTE 5, QUATTRO NUMERI FALSI NEI DOCUMENTI

FONTE DI TUTTA LA PARTE 5: i conteggi del Custode della Memoria sul ramo al
commit 019612d, riportati in docs/STATO_VIVO.md, sezione del corpus
posizionale. Un numero falso in un documento di stato non è una questione di
stile.

### FK.22 lato.md dice cinque carte irriconoscibili, il reperto ne elenca dodici

La testata di docs/corpus/tarocchi_posizione/lato.md dice "le cinque carte
che restano irriconoscibili", mentre
docs/corpus/tarocchi_posizione/collisioni_della_fonte.md oggi ne elenca
dodici in tabella.

### FK.23 mappa_delle_gemelle.md dice diciassette posizioni

docs/corpus/tarocchi_posizione/mappa_delle_gemelle.md dice "la stessa per
tutte e diciassette", mentre le posizioni sono quattordici dall'aggiunta 2
dell'ordine FJ.

### FK.24 Il verbale FI dice diciassette file di posizione

Il bullet dell'ordine FI in docs/STATO_VIVO.md dice "diciassette file di
posizione". Oggi i file di posizione sono quattordici, e i file nella
cartella sono diciassette: quattordici posizioni, registri.md e i due
reperti. Lo stesso bullet si corregge da sé fra parentesi con "quattordici
posizioni in tutto", quindi la riga si contraddice.

I bullet storici degli ordini sono il verbale di quegli ordini: il Custode
non li ha toccati. Decidi tu se si correggono oppure se restano come verbale.

### FK.25 Il verbale FJ dice ventuno carte-verso, sono ventidue

Il bullet dell'ordine FJ dice "26 correzioni su 21 carte-verso". Contate su
docs/collaudo/FJ/correzioni_della_fonte.md: 26 voci, VENTIDUE carte-verso
distinte, venti carte distinte. Né ventuno carte né ventuno carte-verso.


## PARTE 6, LE UNDICI VOCI CHE L'ORDINE FJ LASCIA APERTE

FONTE: docs/ordini/ORDINE_FJ_MANIFESTO.md, le voci che portano "APERTA IN
ATTESA DI VERIFICA". Nessun rilievo si esclude: sono tutte e undici,
nominate.

### FK.26 Le undici voci, una per una

FJ.05, FJ.08, FJ.12, FJ.13, FJ.16, FJ.26, FJ.27, FJ.28, FJ.29, FJ.35, FJ.36.

Per ciascuna: dichiara nel rapporto di FK se quest'ordine la chiude, se la
lascia aperta con la stessa ragione di prima, oppure se la ragione è cambiata.
Una voce che resta aperta con una ragione nuova è un'informazione; una che
resta aperta e nessuno la guarda è una voce dimenticata.

Quattro di loro (FJ.26, FJ.27, FJ.28, FJ.29) sono vincoli che il manifesto
dichiara di chiudere "a ordine finito": l'ordine FJ è finito e consegnato, e
il suo rapporto è registrato. Dichiara se adesso si chiudono.

FJ.35 è la voce della guardia sulla fonte, e la sua decisione è FK.10.
FJ.16 è la voce delle collisioni, e le due nuove sono FK.17 e FK.18.
FJ.12 è la voce del download dei mazzi, e il fondatore ha deciso su di essa
in FK.31 e FK.32.


## PARTE 7, LE TRE DEBOLEZZE CHE HAI DICHIARATO SU TE STESSO

FONTE: il tuo rapporto dell'ordine FJ, sezione "Errori miei, scritti nel
rapporto". Entrano nell'ordine perché le hai dichiarate tu, e una debolezza
dichiarata e mai ripresa torna.

### FK.27 I controlli di casa sui testi nuovi, prima della suite

Hai dichiarato: "Non ho fatto girare i controlli di casa sui testi del LATO
prima della suite intera, come la memoria di casa chiede. Ne sono usciti due
falsi allarmi, che ho dichiarato frase per frase."

Quest'ordine porta 1.404 testi nuovi nel Dart con FK.02. Fai girare i
controlli di casa su quei testi PRIMA della suite intera, e dichiara quanti
falsi allarmi sono usciti e su quali frasi.

### FK.28 Le guardie viste rosse dopo, non prima

Hai dichiarato: "Alcune guardie le ho viste rosse solo dopo aver toccato le
loro zone, non prima come vuole la regola."

È la Regola B del protocollo delle guardie, CLAUDE.md. Per ogni zona che
quest'ordine tocca, la guardia che la copre si vede rossa PRIMA, e la data si
aggiorna in docs/guardie.md. Nel rapporto scrivi l'elenco delle guardie viste
rosse prima, con la data.

Se una guardia non diventa rossa, quella guardia non copre più la zona, e la
prima cosa da riparare è lei.

### FK.29 I dieci rossi del secondo giro

Hai dichiarato dieci rossi al secondo giro della suite, tutti controlli di
casa sul codice nuovo dei mazzi, e li hai corretti tutti, attribuendoli
all'ordine FJ Parte 2 e aggiunta 2 come padre.

Non c'è niente da rifare: la voce esiste perché la Regola C del protocollo
delle guardie è stata rispettata e va riconosciuto.


## PARTE 8, LE DECISIONI DEL FONDATORE E CIÒ CHE NON SI FA

FONTE DI TUTTA LA PARTE 8: frasi del fondatore in chat l'11 ottobre 2026.

### FK.30 Il blocco dei mazzi per piano resta quello della matrice

Il fondatore: "1 va bene la matrice attuale con limitazioni."

Resta quello che hai tenuto: Marsiglia dall'Iniziato, Thoth dall'Adepto, la
matrice dell'ordine FI voce 32. La voce FJ.13, che chiedeva di lasciare i
mazzi aperti, è superata da questa decisione.

Il prezzo in Eos per chi non ha il piano NON è deciso: non inventarlo.

### FK.31 I due mazzi restano fuori dall'APK

Il fondatore: "Ok, allora lasciali fuori."

Decisione presa sui numeri: Marsiglia e Thoth con le miniature pesano
54.566.314 byte, quindi tenerli sul bucket costa 0,001 dollari al mese di
spazio e 0,003 dollari ogni persona che sceglie un mazzo diverso dal
predefinito, cioè 3 dollari ogni mille. Metterli nell'APK porterebbe l'arte
dei tarocchi a 82,8 MB contro i 30,8 di oggi, e il tetto dei 40 MB è del
fondatore, ordine FI.

Quindi: niente cambia sui mazzi. Il Rider-Waite resta nel binario, Marsiglia
e Thoth restano sul bucket, scaricati alla scelta.

### FK.32 Niente Cloud CDN e niente Cloudflare R2, per ora

Il fondatore: "vorrei passare il bucket a cloudflare R2... Ma cmq non adesso.
Per ora restiamo così."

Non toccare niente: nessun bilanciatore, nessun backend bucket, nessuna
migrazione. L'app legge la base dal manifest
(lib/core/tarot/i_mazzi_scaricati.dart riga 51,
https://storage.googleapis.com/esoteric-circle-assets-cdn/), quindi il giorno
che si cambia, cambia il manifest e non l'app: la scelta resta reversibile
senza una versione nuova.

I numeri su cui la decisione è stata presa, da
docs/costi/stima_costi_30_giorni.md: Cloud Storage costa 0,02 dollari al mese
ed è spazio occupato, con 8,7 MB in uscita e 49 richieste in trenta giorni; i
costi fissi di tutto il progetto sono 0,18 dollari al mese; un Application
Load Balancer per il CDN costerebbe circa 18 dollari al mese fissi.

### FK.33 Nessuna build

Il fondatore: "la Build quando ci saranno tutti i corpus di ogni posizione."

Non ordinare e non chiedere una build. Oggi quattro posizioni su quattordici
sono complete e tre hanno una variante sola. La voce FJ.12 resta aperta per
lo sguardo sul telefono, e lo sguardo arriverà alla build che il fondatore
ordinerà quando i corpus saranno pieni.

I due punti che quella build dovrà guardare, dal tuo rapporto, restano
scritti: il download vero di un mazzo dal bucket, e i nomi lunghi del
Marsiglia che nella targa stretta vanno su due righe piccole
(docs/preview/prima_dopo/fj_i_tre_mazzi_dopo.png).

### FK.34 Le cinque premesse sbagliate dell'ordine FJ erano dell'Architetto

FONTE: il tuo rapporto dell'ordine FJ, sezione "Premesse sbagliate
dell'ordine, segnalate all'Architetto".

Le cinque, riconosciute: il Rider-Waite era già nell'app e non andava messo;
non esistono originali più grandi di 853x1280; la frase gemella del Fante di
Coppe sta nella Regina di Coppe DRITTA e non capovolta; la frase della Regina
di Denari non è parola per parola quella del Sei di Denari, è lo stesso
concetto; davanti al bucket non c'è Cloud CDN.

Meccanismo, uno solo per tutte e cinque: l'ordine FJ è stato scritto leggendo
i documenti invece di aprire tarot_card.dart, il bucket e la console.

Non c'è niente da eseguire. La voce esiste per la Regola C del protocollo
delle guardie: ogni difetto ha un padre, e il padre di questi cinque è
l'ordine FJ dell'Architetto.

### FK.35 Il ruolo Visualizzatore fatturazione, se il fondatore lo concede

FONTE: docs/costi/stima_costi_30_giorni.md, sezione "Che cosa non si è potuto
misurare, e perché", punto 1.

Quel documento dichiara che il report Fatturazione e l'esportazione dei costi
in BigQuery non sono leggibili dal tuo account, e che servirebbe il ruolo
"Visualizzatore fatturazione" sul conto di fatturazione. È anche il solo modo
di sapere quanto del credito di prova è stato usato.

Il fondatore ha dichiarato l'11 ottobre 2026: "Sto pagando con la carta".

Non chiedere credenziali in chat e non chiederle al fondatore qui: se il
ruolo arriva, te ne accorgi perché il report si apre. Se non arriva, la misura
resta quella stimata e lo dichiari.

### FK.36 Il rapporto dell'ordine

Il rapporto va in docs/ordini/RAPPORTO_ORDINE_FK.md, e in cima porta l'elenco
delle voci chiuse con accanto la prova di ciascuna, come il Protocollo della
chiusura pretende, così il fondatore controlla in trenta secondi.

Alla consegna registra il rapporto con
python tool/i_rapporti_consegnati.py RAPPORTO_ORDINE_FK.md.

Il manifesto va in docs/ordini/ORDINE_FK_MANIFESTO.md, con una voce per
ciascuna delle 36 voci di quest'ordine.


## LE REGOLE FISSE, che valgono su ogni voce

UN RAMO SOLO. Il lavoro si spinge sul solo ramo
claude/esoteric-circle-master-order-e798aj. Nessun altro ramo si crea.

IL PROTOCOLLO DELLA CHIUSURA, ordine EH. Una voce si scrive CHIUSA solo se
sotto di lei il manifesto porta tre righe leggibili da una macchina:
DOMANDA, con le parole del fondatore alla lettera; PROVA, un percorso di un
file che esiste davvero nel repo; MISURA, la grandezza col numero prima e il
numero dopo. Una voce prodotta e agganciata ma non ancora guardata si scrive
APERTA IN ATTESA DI VERIFICA, non CHIUSA. "Verificato a video" non è una
prova, è una promessa.

IL PROTOCOLLO DELLE GUARDIE, ordine CM. Regola A: nessuna guardia nuova si
scrive senza averla vista rossa, col difetto innestato a mano e verificato
col grep, e quando il rosso non scatta si cambia la grandezza misurata, mai
la soglia. Una guardia su un insieme scoperto a esecuzione dichiara il suo
cardinale minimo. Regola B: chi lavora su una zona già coperta la vede rossa
PRIMA, e aggiorna la data in docs/guardie.md. Regola C: ogni difetto nominato
in un rapporto è attribuito alla voce che l'ha causato, col numero d'ordine e
di voce, e dove non si risale si scrive PROVENIENZA IGNOTA per esteso.

IL PROTOCOLLO VERITÀ E MEMORIA. Leggi docs/STATO_VIVO.md per primo e
aggiornalo al termine, integrando nella sezione giusta, mai come addendum,
senza condensare il resto. Prima di affermare cosa è fatto, cosa manca o
quanti sono, VERIFICA sul filesystem e sul repo.

UN RAPPORTO CONSEGNATO NON SI CORREGGE NEL CORPO, ordine FB voce 03. Riceve
solo righe in coda che cominciano con "**Aggiunta del" e portano la data e
l'ordine.

I MODELLI STANNO NELLA REGIONE DEI DATI, ordine DJ voce 03. Solo modelli
disponibili in europe-west1, con la sola eccezione delle voci Chirp 3 HD
all'endpoint multiregionale "eu", ordine EM voce 02.

SEGRETI MAI NEL CODICE NÉ SU GIT. In locale stanno in .secrets/, in
produzione in Secret Manager. Nessuna credenziale passa dalla chat.

NIENTE TRATTINO LUNGO nei testi, e mai la virgola prima della congiunzione e
oppure ed. Commenti e rapporti in italiano.

SE UNA PREMESSA DI QUEST'ORDINE È SBAGLIATA, dillo e non eseguirla. L'ordine
FJ ne portava cinque, elencate in FK.34, e le hai trovate tu. Vale di nuovo.
