ORDINE FM
Il corpus posizionale dei tarocchi passa a Code
12 ottobre 2026
Ramo unico: claude/esoteric-circle-master-order-e798aj

Parole del fondatore, 12 ottobre 2026: "Adesso ho il problema di finire i
corpus e mi stavo chiedendo se poteva concludere Code il lavoro al tuo
posto." Questo ordine fa esattamente quello. Dove l'intestazione dei file
del corpus dice "scritte dall'Architetto", da oggi si legge "scritte da
Code".

PREMESSE, contate sul ramo il 12 ottobre 2026. Leggerle prima delle voci.

P1. Lo stato del corpus, contato riga per riga in
docs/corpus/tarocchi_posizione/, quindici file da 468 righe ciascuno,
7.020 testi in tutto:
  piene, zero righe vuote: copre, attraversa, corona, sotto, carta_sola,
    consultante, lato, esito
  312 righe vuote ciascuno: passato, presente, futuro
  468 righe vuote ciascuno: se_stesso, la_casa, speranze_o_timori, registri
Mancano 2.808 testi su 7.020.
FONTE: conteggio delle righe che cominciano con "- " e di quelle che
finiscono col due punti seguito dal nulla.

P2. Lo strumento esiste gia': tool/genera_carte_nella_posizione.py, 537
righe. Controlla la lunghezza fra 110 e 280 caratteri, il nome della carta,
il verso nominato, le cifre, il trattino lungo, la parola voce, la virgola
seguita da "e" oppure "ed", la marca del genere, le promesse, le previsioni
certe e la somiglianza di Jaccard sopra 0,6; poi scrive
lib/core/tarot/le_carte_nella_posizione_dati.dart. Chi riempie non deve
reinventarlo.
FONTE: il file citato, funzioni controlla_testo alla riga 195 e controlla
alla riga 232.

P3. Una regola scritta nelle intestazioni non e' misurata da nessuno.
L'intestazione di ogni file del corpus dice "rivolte alla persona col tu",
ma in controlla_testo non c'e' nessun controllo della seconda persona. Una
regola che nessuno misura e' una regola che non esiste.
FONTE: lettura della funzione controlla_testo, righe 195-230.

P4. Non c'e' nel repo nessuno schedario per posizione, cioe' nessun
documento che dica, carta per carta, che cosa quella carta dice in QUELLA
posizione e non dice nella posizione gemella. Le regole nelle intestazioni
valgono per tutte le posizioni allo stesso modo.
FONTE: ricerca di "schedario" sotto l'intero repo, zero risultati.

VOCI.

FM.01. LE VARIANTI 2 E 3 DI PASSATO, PRESENTE E FUTURO.
Da fare: riempire le 312 righe vuote di ciascuno dei tre file
docs/corpus/tarocchi_posizione/{passato,presente,futuro}.md, cioe' le
varianti 2 e 3 per ognuna delle 156 carte-verso, 936 testi in tutto. La
variante 1 e' gia' scritta e resta: le nuove due partono con parole diverse
dalla prima e non le somigliano, come pretende il controllo di Jaccard.
Regole: quelle scritte in testa a ciascun file, piu' il controllo nuovo
della voce FM.04.
FONTE: l'intestazione dei tre file e la premessa P1.

FM.02. LE TRE POSIZIONI INTATTE DELLA CROCE CELTICA.
Da fare: riempire per intero
docs/corpus/tarocchi_posizione/{se_stesso,la_casa,speranze_o_timori}.md,
468 righe ciascuno, 1.404 testi. Sono le tre posizioni che oggi tengono
chiusa la stesa a dieci carte.
FONTE: l'intestazione dei tre file e la premessa P1.

FM.03. I REGISTRI DELLE CARTE.
Da fare: riempire docs/corpus/tarocchi_posizione/registri.md, 468 righe. Non
e' una posizione: per ogni carta e per ogni verso vuole tre righe, una per
gruppo dell'argomento, amore, lavoro, vita, e ognuna dice di che cosa parla
quella carta in quell'ambito. E' il metodo di Dora, voce FI.20. I tre gruppi
sono pieni tutti e tre o il tool si ferma.
FONTE: l'intestazione di registri.md.

FM.04. IL CONTROLLO DELLA SECONDA PERSONA, VISTO ROSSO PRIMA.
Da fare: aggiungere a controlla_testo, in
tool/genera_carte_nella_posizione.py, il controllo che ogni testo si rivolga
alla persona col tu, come l'intestazione di ogni file pretende gia' e come
la premessa P3 dice che nessuno misura.
Regola A dell'ordine CM: il controllo nuovo non si scrive senza averlo visto
rosso. Si prende un testo gia' nel corpus, lo si riscrive a mano in terza
persona, si verifica COL GREP che il testo storto sia davvero entrato nel
file, e solo dopo si legge l'esito. Se il rosso non scatta si cambia la
grandezza misurata, mai la soglia.
Poi si misura quanti testi gia' scritti non passano il controllo nuovo, si
scrive il numero nel rapporto e si riparano.
FONTE: l'intestazione dei file del corpus, la premessa P3 e l'ordine CM
Regola A, riportata in CLAUDE.md.

FM.05. LO SCHEDARIO PER POSIZIONE, DENTRO IL REPO.
Da fare: prima di riempire una posizione, scrivere nel repo lo schedario di
quella posizione, cioe' il documento che dice che cosa la posizione chiede a
una carta e in che cosa si distingue dalla posizione gemella. Lo schedario
sta accanto al corpus, in docs/corpus/tarocchi_posizione/, un file per
posizione, e resta nel repo quando il lavoro finisce.
Il motivo sta nella premessa P4: senza lo schedario le posizioni diverse
ricevono testi intercambiabili, e la posizione smette di dire qualcosa.
Dove lo schedario e la soglia da raggiungere li decide Code: l'Architetto
non impone ne' la forma del documento ne' il modo di verificarlo.
FONTE: la premessa P4 e le parole del fondatore del 12 ottobre 2026,
"Eventuali modifiche, adattamenti e miglioramenti li decide Code".

FM.06. LA RIGENERAZIONE DEL DART E IL CARDINALE MINIMO.
Da fare: finita ogni posizione, rilanciare
python tool/genera_carte_nella_posizione.py
e verificare che lib/core/tarot/le_carte_nella_posizione_dati.dart porti i
testi nuovi, non la mappa vuota. Se esiste o si puo' scrivere una guardia
che conti i testi del Dart, questa dichiara il suo cardinale minimo, come
pretende la Regola A dell'ordine CM, altrimenti su un insieme vuoto e' verde
senza aver guardato niente.
FONTE: l'intestazione dei file del corpus e l'ordine CM Regola A.

FM.07. LA BUILD LA ORDINA IL FONDATORE.
Finito il lavoro, si riferisce cosa e' pronto e si attende il suo ordine.
Nessuna build di iniziativa.
FONTE: regola permanente del progetto.

L'ORDINE DI ESECUZIONE.
FM.04 per prima, cosi' tutto quello che si scrive dopo nasce gia' misurato.
Poi, per ogni posizione, prima lo schedario della voce FM.05 e poi i testi.
L'ordine fra FM.01, FM.02 e FM.03 lo decide Code. Se il lavoro va in piu'
sessioni, si spinge sul ramo a ogni posizione finita, mai alla fine di
tutto: cio' che resta fuori dal ramo e' lavoro che si perde.

REGOLE FISSE CHE VALGONO SU OGNI VOCE.
Ramo unico claude/esoteric-circle-master-order-e798aj, nessun altro ramo.
Mai il trattino lungo, commenti e rapporto in italiano, accenti veri.
Ogni voce si chiude col protocollo della chiusura, ordine EH: DOMANDA con le
parole del fondatore alla lettera, PROVA con il percorso di un file che
esiste davvero nel repo, MISURA col numero prima e il numero dopo. Una voce
prodotta ma non ancora guardata si scrive APERTA IN ATTESA DI VERIFICA.
Le voci sui testi generati si misurano su almeno due esecuzioni con dati
diversi: se i due testi coincidono, la voce non e' chiusa.
Chi tocca una zona coperta da una guardia la vede rossa prima di metterci
mano e aggiorna la data in docs/guardie.md, Regola B dell'ordine CM.
Ogni difetto nominato nel rapporto e' attribuito alla voce che l'ha causato,
oppure porta scritto PROVENIENZA IGNOTA per esteso, Regola C.
In cima al rapporto l'elenco delle voci chiuse con accanto la prova di
ciascuna. Alla consegna si registra con
python tool/i_rapporti_consegnati.py RAPPORTO_ORDINE_FM.md
Al termine si aggiorna docs/STATO_VIVO.md nella sezione giusta, mai come
addendum, senza condensare il resto.
