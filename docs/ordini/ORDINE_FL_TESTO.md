ORDINE FL, PEZZO 1 DI 2
Stesa di Tarocchi, lo sfondo del tavolo e la stesa sul piano
12 ottobre 2026
Ramo unico: claude/esoteric-circle-master-order-e798aj

Questo ordine arriva in due pezzi. Il pezzo 1 porta le premesse e le voci
FL.01, FL.02, FL.03, FL.04. Il pezzo 2 porta FL.05, FL.06, FL.07, FL.08,
FL.09, FL.10 e le regole fisse. Non cominciare prima di avere tutti e due.

PREMESSE, verificate sul ramo il 12 ottobre 2026. Leggerle prima delle voci.

P1. Oggi lo sfondo della schermata non e' un'immagine: e' CosmosBackground,
importato alla riga 31 di lib/features/tarot/stesa_tre_carte_screen.dart, e
Medora e' MedoraStage, costruita alla riga 1466, con bustoFactor alla riga
1476 che vale MedoraStage.bustoPieno a responso in scena e 0.34 prima.
FONTE: i file citati.

P2. PostoSulTavolo, il posto di ogni carta sul tavolo per ogni stesa, esiste
gia' in lib/core/tarot/tarot_spread_type.dart ed e' popolato per tutte le
stese, ma non c'e' nessuna occorrenza sotto lib/features/: la schermata
dispone le carte per conto proprio.
FONTE: ricerca di PostoSulTavolo sotto lib/features/, zero risultati.

P3. L'immagine dello sfondo misura 688 per 1536 pixel. Lo schermo del
telefono del fondatore ne misura 1080 per 2392. L'immagine e' quindi piu'
piccola dello schermo e verra' ingrandita per riempirlo.
FONTE: misura del file assets/img/tavolo/tavolo_medora_v1.webp.

P4. La carta chiave oggi si distingue per la sola grandezza: in
stesa_tre_carte_screen.dart la riga 2096 porta scalaDellaChiave = 1.10 e la
riga 2097 scalaDelleAltre = 0.86, applicate alla riga 2216.
FONTE: le righe citate.

VOCI.

FL.01. LO SFONDO NUOVO CON MEDORA SOPRA.
Parole del fondatore: "SFONDO NUOVO con sovrapposta Medora tagliata alla
vita come se fosse dietro il tavolo" e "L'immagine va tagliata in alto in
modo che la testa di Medora sia visibile e non tagliata dalla barra del
titolo superiore".
Da fare: mettere assets/img/tavolo/tavolo_medora_v1.webp come sfondo della
schermata, e sopra di esso assets/img/tavolo/medora_busto_v1.webp, che e'
gia' tagliata alla vita appena sotto la fila di carte piu' bassa, in modo
che nessuna carta resti mozzata. Medora va collocata in modo che il bordo
lontano del panno di velluto le passi davanti alla vita, e la sua testa
resti interamente sotto la barra del titolo, mai tagliata da quella.
FONTE: le parole del fondatore del 12 ottobre 2026.

FL.02. L'ORDINE DEGLI ELEMENTI DALL'ALTO IN BASSO.
Parole del fondatore: "Subito sotto il tavolo il selettore delle opzioni di
stesa. Subito sotto il riquadro con la scelta delle 78 carte con i pulsanti
mischia e taglia, tutto com'e' adesso in app. Sotto il riquadro il pulsante.
Tutta la meccanica resta com'e' adesso."
Da fare: dall'alto in basso, la barra del titolo, lo sfondo nuovo col tavolo
e Medora, poi il selettore delle opzioni di stesa, poi il riquadro della
scelta delle 78 carte coi pulsanti Mischia e Taglia, poi il pulsante Leggi
le Carte. Il selettore, il riquadro delle 78 carte, Mischia, Taglia, Suono,
lo scuoti per mischiare e il pulsante restano esattamente quelli di oggi,
nell'aspetto e nel funzionamento: nessuno di questi va ridisegnato.
Le catture della schermata di oggi, consegnate dal fondatore, stanno in
docs/collaudo/FL/schermata_di_oggi_ventaglio.jpg e
docs/collaudo/FL/schermata_di_oggi_responso.jpg.
FONTE: le parole del fondatore del 12 ottobre 2026.

FL.03. LE CARTE SI STENDONO SUL TAVOLO NELLA PROSPETTIVA DEL TAVOLO.
Parole del fondatore: "Le carte scelte si stendono sul tavolo mantenendo la
stessa prospettiva del tavolo."
Da fare: le carte scelte si posano sul piano del tavolo dell'immagine,
inclinate come il piano, non frontali. I posti sul tavolo sono quelli che
PostoSulTavolo dichiara gia' per la stesa attiva, come dice la premessa P2.
La cattura docs/collaudo/FL/esempio_stesa_a_croce.jpg, consegnata dal
fondatore, mostra la disposizione a croce come lui la vuole vedere.
FONTE: le parole del fondatore del 12 ottobre 2026.

FL.04. LA CARTA CHIAVE SI ILLUMINA DA SOTTO E NON E' PIU' GRANDE.
Parole del fondatore: "La Carta chiave e' illuminata da sotto, non e' piu'
grande."
Da fare: togliere la differenza di grandezza fra la carta chiave e le altre,
cioe' le due costanti della premessa P4, e distinguere la chiave con una
luce che sale da sotto la carta.
FONTE: le parole del fondatore del 12 ottobre 2026.

FINE DEL PEZZO 1. Attendi il pezzo 2 prima di cominciare.

---

ORDINE FL, PEZZO 2 DI 2
Segue il pezzo 1. Insieme fanno un ordine solo.

FL.05. LA SEQUENZA DOPO IL PULSANTE.
Parole del fondatore: "Dopo aver premuto il pulsante e dopo l'animazione di
riflessione, le carte si girano sul tavolo una alla volta e dopo un secondo
dall'ultima girata, si mettono in verticale ingrandendosi per rendersi ben
visibile all'utente."
Da fare: premuto il pulsante resta l'animazione di riflessione che c'e'
oggi; poi le carte, ancora coperte sul tavolo nella prospettiva del piano,
si girano una alla volta; un secondo dopo che l'ultima si e' girata, si
alzano in verticale ingrandendosi, una affiancata all'altra, ben visibili.
FONTE: le parole del fondatore del 12 ottobre 2026.

FL.06. IL CLICK SULLA CARTA MOSTRA IL SIGNIFICATO GENERICO.
Parole del fondatore: "Se faccio click su una carta, mi viene mostrato il
suo significato generico."
Da fare: toccando una carta si apre in sovrimpressione il significato
generale di quella carta, non il testo del responso gia' scritto sotto.
Questa voce e' la stessa che l'ordine FK porta gia' sullo stesso difetto: se
in FK e' gia' stata eseguita, qui si verifica soltanto che valga anche sulle
carte alzate dal tavolo.
FONTE: le parole del fondatore dell'11 e del 12 ottobre 2026.

FL.07. IL RESPONSO RESTA UGUALE.
Parole del fondatore: "Per quanto riguarda tutto il responso resta uguale a
prima."
Da fare: non toccare nulla del responso sotto le carte, ne' il titolo, ne' i
tre paragrafi col secondo nel riquadro, ne' le bolle per carta, ne' il
corsivo finale del da dove viene.
FONTE: le parole del fondatore del 12 ottobre 2026.

FL.08. GLI ASSET E IL PUBSPEC.
Le due immagini sono gia' sul ramo, commit f7447a3:
  assets/img/tavolo/tavolo_medora_v1.webp   lo sfondo nuovo
  assets/img/tavolo/medora_busto_v1.webp    Medora tagliata alla vita
La cartella assets/img/tavolo/ e' nuova: in pubspec.yaml la riga assets:
alla riga 258 non e' ricorsiva, quindi la cartella va dichiarata da sola,
come e' gia' stato fatto per assets/audio/animali/ alla riga 247.
FONTE: pubspec.yaml righe 247 e 258, e il commit f7447a3.

FL.09. LE DECISIONI DI MERITO SONO DI CODE.
Parole del fondatore: "Eventuali modifiche, adattamenti e miglioramenti li
decide Code."
Da fare: dove questo ordine lascia uno spazio, decide Code, senza girare la
domanda all'Architetto ne' al fondatore. Vale anche per la premessa P3:
l'immagine e' piu' piccola dello schermo, e se Code ritiene che vada
rigenerata piu' grande lo dichiara nel rapporto, con la misura.
FONTE: le parole del fondatore del 12 ottobre 2026.

FL.10. LA BUILD LA ORDINA IL FONDATORE.
Finito il lavoro, si riferisce cosa e' pronto e si attende il suo ordine.
Nessuna build di iniziativa.
FONTE: regola permanente del progetto.

REGOLE FISSE CHE VALGONO SU OGNI VOCE DEL PEZZO 1 E DEL PEZZO 2.
Ramo unico claude/esoteric-circle-master-order-e798aj, nessun altro ramo.
Mai il trattino lungo, commenti e rapporto in italiano.
Ogni voce si chiude col protocollo della chiusura, ordine EH: DOMANDA con le
parole del fondatore alla lettera, PROVA con il percorso di un file che
esiste davvero nel repo, MISURA col numero prima e il numero dopo. Una voce
prodotta ma non ancora guardata si scrive APERTA IN ATTESA DI VERIFICA.
Chi tocca una zona coperta da una guardia la vede rossa prima di metterci
mano e aggiorna la data in docs/guardie.md, Regola B dell'ordine CM.
Ogni difetto nominato nel rapporto e' attribuito alla voce che l'ha causato,
oppure porta scritto PROVENIENZA IGNOTA per esteso, Regola C.
In cima al rapporto l'elenco delle voci chiuse con accanto la prova di
ciascuna. Alla consegna si registra con
python tool/i_rapporti_consegnati.py RAPPORTO_ORDINE_FL.md
Al termine si aggiorna docs/STATO_VIVO.md nella sezione giusta, mai come
addendum, senza condensare il resto.

FINE DELL'ORDINE FL.
