# MANIFESTO DELL'ORDINE GD, I VIDEO DI INGRESSO AI DOMINI, LA STESA DI TAROCCHI, L'ORACOLO DEGLI ANGELI, LA SINASTRIA EVOLUTIVA, IL RESPIRO DELLA LUNA E IL CIELO IN TEMPO REALE

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_GD_TESTO.md` (copia
di `D:\Clienti Roogly\Rituali Cartomanzia\App\ORDINE_GD_Esoteric_Circle.md`).
Rapporto: `docs/ordini/RAPPORTO_ORDINE_GD.md`. Una voce CHIUSA porta sotto di
se' DOMANDA, PROVA e MISURA; una voce APERTA dice che cosa aspetta e porta le
sue prove. Le dodici premesse sono state verificate sulla testa del ramo
`02522987` prima di toccare qualunque cosa: tutte vere. Le parti A (GD.01-GD.03),
D (GD.13-GD.22) ed E/F (GD.23-GD.25) le hanno eseguite tre agenti su rami
locali partiti da `02522987` e fusi qui; i loro resoconti stanno in
`docs/collaudo/GD/parte_a.md`, `parte_d.md` e `parte_ef.md`. La Regola A di
ogni guardia nuova sta in `docs/collaudo/GD/regola_a_principale.txt`,
`regola_a_a.txt`, `regola_a_d.txt` e `regola_a_ef.txt`. Il collaudo sul Realme
(simulazione da persona e del bambino) sta in `docs/collaudo/GD/le_opzioni.md`
e `docs/collaudo/GD/simulazioni/`, su una build di rilascio installata solo sul
telefono di collaudo col si' del fondatore in chat ("Autorizzo la build
locale"), mai distribuita.

Restano aperte due voci: GD.03 (mancano le arti dipinte dei chakra) e GD.21
(la porta del server va pubblicata dal fondatore). GD.26 e' chiusa col verde di
GitHub sul commit `78aff744`, scritto in coda al rapporto.

VOCI_TOTALI: 26
VOCI_CHIUSE: 24
VOCI_APERTE: 2
VOCI_DA_FARE: 0
VOCI_PREMESSA_CADUTA: 0
VOCI_DIVIETO: 0

## VOCE GD.01

**CHIUSA.** Nel palmo di Medora, a video finito o saltato, compare l'emblema
dipinto del segno solare della persona (`assets/img/zodiac/zod_<segno>.webp`),
mai mentre il video gira; senza data di nascita il palmo resta vuoto. Visto sul
Realme: il segno dei Gemelli sopra la mano tesa, lo stesso dell'avatar. PADRE:
la scena senza dono nasce con l'ordine FW voce FW.03 (commit `09948086`); la
promessa della personalizzazione non ha lasciato traccia scritta,
PROVENIENZA IGNOTA.

DOMANDA: "nei video di ingresso ai domini mancano le personalizzazioni promesse: Medora alla fine mostra la mano aperta e dovrebbe comparire il segno zodiacale dell'utente, ma non compare"
PROVA: `docs/collaudo/GD/simulazioni/catture/gd01_medora_gemelli_realme.png`
MISURA: simboli nel palmo a scena ferma, prima 0 e dopo 1; due persone di segno diverso vedono prima 0 e dopo 2 simboli diversi (Cancro e Ariete, `test/gd_il_dono_nel_palmo_test.dart`); opacita' del segno a video in corso 0, a video finito 1.

## VOCE GD.02

**CHIUSA.** I due video di Calìgo si sono scambiati (il cerchio di fuoco apre il
dominio, il vortice la chat) e nella mano aperta del dominio c'e' la pietra
dipinta della runa del tramonto di quel giorno, la stessa estrazione del rito
della sera. Visto sul Realme, dominio e chat. Da far guardare al fondatore: il
video del vortice, che ora apre la chat, ha una runa Dagaz dipinta dentro il
video, fissa per tutti. PADRE: lo scambio di prima e' dell'ordine FW voce FW.05
(commit `09948086`); la runa mai comparsa ha la stessa origine della GD.01,
PROVENIENZA IGNOTA per la promessa.

DOMANDA: "Per Caligo bisogna scambiare il video introduttivo della chat con quello del dominio e nella sua mano aperta dovrebbe comparire la runa del tramonto del giorno, se non sbaglio"
PROVA: `docs/collaudo/GD/simulazioni/catture/gd02_caligo_dominio_runa_realme.png`
MISURA: impronta del video del dominio prima `05b6636e` (il vortice) dopo `5965a25b` (il cerchio di fuoco), della chat il contrario; rune nel palmo prima 0 dopo 1; due sere diverse per la stessa persona danno prima 0 e dopo 2 pietre diverse (`test/gd_il_dono_nel_palmo_test.dart`).

## VOCE GD.03

**APERTA IN ATTESA DI VERIFICA.** Il chakra del giorno esiste come dato
(`ChakraDelGiorno.di`), ma nel ramo, nella sua storia e nella cartella del
fondatore non c'e' nessun simbolo dipinto dei chakra: disegnarlo violerebbe R8,
quindi il palmo di Aura resta vuoto, come l'ordine prevede nel suo ripiego. Si
chiude quando arrivano sette arti dipinte dei chakra (nomi proposti
`assets/img/chakra/chakra_N_<nome>_v1.webp`, punto del loto gia' misurato a x
530, y 1015 sul fotogramma 1080 per 1920). PADRE: nessun difetto di codice; la
grafica mancante non ha un ordine che l'abbia chiesta, PROVENIENZA IGNOTA.

DOMANDA: "Aura non ricordo, proponi tu"
PROVA: `docs/collaudo/GD/simulazioni/catture/gd03_aura_dominio_realme.png`
MISURA: chakra del giorno come dato: presente; simboli dipinti dei sette chakra nel ramo: prima 0, dopo 0; simboli nel palmo di Aura: prima 0, dopo 0.

## VOCE GD.04

**CHIUSA.** La riga "Su questa domanda le carte hanno già parlato oggi" compare
solo quando la stessa domanda dello stesso giorno ha dato le stesse identiche
carte; al rientro le carte si scelgono di nuovo, e la stesa identica riletta
non si conta due volte. Visto sul Realme: stessa domanda, prima di scegliere e
con carte diverse, nessuna riga. PADRE: ordine FI voci 26, 27 e 41 (commit
`12569ac9`), che al rientro riconsegnava le carte conservate con la riga gia'
scritta.

DOMANDA: "nei tarocchi, dopo aver fatto la prima domanda, se provo a fare un'altra lettura mi dice sempre «su questa domanda le carte hanno già parlato oggi: sono le stesse di prima» ma non è assolutamente vero anche perché devo ancora scegliere le carte. Questa scritta deve uscire solo nella caso raro in cui pongo la stessa identica domanda ed escono le stesse identiche carte nello stesso giorno"
PROVA: `test/gd04_le_carte_hanno_gia_parlato_test.dart`
MISURA: riga presente nei sei casi, prima (innesto della regola vecchia) domanda nuova no, stessa domanda prima di scegliere si', carte diverse si', stesse carte si', giorno dopo no; dopo no, no, no, no, si', no. Catture: `docs/collaudo/GD/simulazioni/catture/gd04_stessa_domanda_carte_diverse.png`.

## VOCE GD.05

**CHIUSA.** Con la Lunga la prima risposta della Stesa porta due paragrafi in
piu', il secondo nel riquadro "La contemplazione propiziatoria", anche quando
il modello non torna: l'approfondimento di casa nasce dai testi documentati
della carta chiave (il suo ostacolo) e dai gesti della domanda che il "Cosa
fare adesso" non ha detto. Visto sul Realme a rete spenta. PERCHE' LA PROVA ERA
VERDE: lo dichiara il rapporto, alla voce. PADRE: ordine GA voci GA.03 e GA.05
(commit `8208cbcf`), che scriveva "Sempre Breve" per la lettura di casa e una
prova che lo pretendeva.

DOMANDA: "la profondità lunga nella prima risposta NON FUNZIONA: non compaiono i 2 paragrafi aggiuntivi di cui il 2ndo in riquadro con il titolo che avevi scelto"
PROVA: `test/gd05_la_lunga_della_stesa_test.dart`
MISURA: pezzi della prima risposta con la Lunga senza modello, prima 2 (risposta e cosa fare) dopo 4 (piu' approfondimento e riquadro col titolo); col modello 4 e 4; responsi Lunghi su 768 provati, prima 192 dopo 384, 0 difetti di misura. Cattura: `docs/collaudo/GD/simulazioni/catture/gd05_stesa_lunga_3_riquadro.png`.

## VOCE GD.06

**CHIUSA.** Il pulsante rotondo di invio non esiste piu': scritta o scelta la
domanda il mazzo si accende da solo, scelte le carte si accende "Avvia la
lettura". Le consultazioni del giorno si guardano al primo dorso toccato. La
regola permanente in `CLAUDE.md` e' aggiornata con la lapide di GC.11. Visto sul
Realme nei tre stati. PADRE: ordine FY voce FY.15 (l'affido col pulsante) e
ordine GC voce GC.11 (la freccia d'invio).

DOMANDA: "nell'oracolo degli angeli bisogna eliminare il pulsante rotondo di invio nella bolla delle domande: quando l'utente ha scelto la domanda semplicemente il riquadro delle carte da scegliere si attiva e dopo che ha scelto le carte il pulsante giallo di avvio lettura si attiva"
PROVA: `test/gd_l_oracolo_degli_angeli_test.dart`
MISURA: pulsanti rotondi d'invio nei file di lib, prima 1 dopo 0; mazzo acceso con la domanda scritta senza altri tocchi, prima no dopo si'; "Avvia la lettura" acceso a carte scelte, si'. Catture: `docs/collaudo/GD/simulazioni/catture/gd06_1_domanda_non_data.png`, `gd06_2_domanda_data_mazzo_acceso.png`, `gd06_3_carte_scelte_avvia_acceso.png`.

## VOCE GD.07

**CHIUSA.** Dopo la lettura le tre carte stanno in verticale e la loro fila
occupa il 94 per cento della larghezza, con un margine del 3 per cento ai lati.
Visto sul Realme. PADRE: ordine GC voce GC.14 (le carte in piedi larghe 0,23
dello schermo, centrate sui posti dell'altare).

DOMANDA: "Dopo la lettura le carte si mettono in verticale e si devono ingrandire di più, fino ad occupare quasi tutta l'area orizzontale"
PROVA: `test/gd_l_oracolo_degli_angeli_test.dart`
MISURA: fila delle tre carte in piedi su 390 punti, prima 281,4 (72,2 per cento) dopo 366,6 (94,0 per cento); ogni carta 118,3 per 177,4 punti. Cattura: `docs/collaudo/GD/simulazioni/catture/gd07_carte_in_piedi_94_per_cento.png`.

## VOCE GD.08

**CHIUSA.** Sotto "Affida una nuova domanda" non c'e' piu' la bolla dell'angelo
del momento. Visto sul Realme. PADRE: ordine GC voce GC.08 (l'angelo dell'ora
spostato in fondo, dopo la lettura).

DOMANDA: "Alla fine del responso NON DEVE COMPARIRE LA BOLLA DELL'ANGELO DEL MOMENTO sotto il pulsante «affida una nuova domanda»"
PROVA: `test/gd_l_oracolo_degli_angeli_test.dart`
MISURA: elementi sotto "Affida una nuova domanda", prima 1 (la bolla dell'angelo dell'ora) dopo 0. Cattura: `docs/collaudo/GD/simulazioni/catture/gd08_fondo_del_responso.png`.

## VOCE GD.09

**CHIUSA.** Il messaggio sulla rete non esiste piu' in nessun caso. Visto sul
Realme a rete spenta, il caso che prima lo mostrava. PADRE: ordine GA voce GA.06
(commit `312a2f1d`).

DOMANDA: "compare sempre il messaggio di assenza di rete: eliminalo completamente, non dovrà mai comparire in nessuna caso!"
PROVA: `test/gd_l_oracolo_degli_angeli_test.dart`
MISURA: file di lib che contengono la frase, prima 1 dopo 0; righe a video nel responso dai doni, prima 1 dopo 0. Cattura: `docs/collaudo/GD/simulazioni/catture/gd10_oracolo_lunga_1_senza_rete.png`.

## VOCE GD.10

**CHIUSA.** Con la Lunga la prima risposta dell'Oracolo porta due paragrafi in
piu', il secondo nel riquadro "Il salmo propiziatorio", col modello e senza:
sulla via dei doni l'approfondimento nasce dai gesti scritti per il Cuore e
l'Intelletto sulla domanda, il salmo dalla raccolta di Martini. Visto sul
Realme a rete spenta. PERCHE' LA PROVA DI GC.19 ERA VERDE: lo dichiara il
rapporto, alla voce. PADRE: ordine GA voci GA.03, GA.04 e GA.05 (commit
`89ae8a24`), dove la Lunga esisteva solo nella lettura del modello.

DOMANDA: "la profondità lunga NON FUNZIONA ANCORA nella prima risposta dove dovrebbe comparire 2 paragrafi in più di cui il secondo in riquadro con titolo! Quante volte devo chiederlo?"
PROVA: `test/gd_l_oracolo_degli_angeli_test.dart`
MISURA: pezzi della prima risposta con la Lunga senza modello, prima 2 dopo 4 col riquadro "Il salmo propiziatorio"; col modello 4; Lunghe dai doni provate su 72 angeli in stesa a una e a tre carte, 144 su 144 a misura. Cattura: `docs/collaudo/GD/simulazioni/catture/gd10_oracolo_lunga_2_salmo_e_gd11_scheda_1.png`.

## VOCE GD.11

**CHIUSA.** La scheda di ogni carta apre con la testata (la carta, il posto, il
nome, il dono, tre righe allo stesso margine), poi il suo messaggio aperto
(titolo e un solo paragrafo, senza riquadro), poi i dettagli e le azioni. I due
segni hanno la stessa misura e la stessa colonna. Visto sul Realme. PADRE:
ordine GC voci GC.15 e GC.18 (il messaggio chiuso in fondo, dopo coro,
tradizione e chi e').

DOMANDA: "la risposta delle singole carte è all'inizio poco elegante, confusionario, non ordinata e non allineata con icone di dimensioni diverse, spazi che sembra che manchi qualcosa e, inoltre, la prima cosa che vuole vedere l'utente è la risposta, L'UTENTE NON GLIENE FREGA NIENTE DEI DETTAGLI VUOLE LA RISPOSTA! Sistema elegantemente tutte le risposte delle singole carte"
PROVA: `test/gd_l_oracolo_degli_angeli_test.dart`
MISURA: misure dei segni nelle tre schede, prima 48 e 34 punti dopo 28 e 28; margine della carta 17,0 punti in tutte e tre; colonna dei segni 101,0 in tutte e tre; messaggio prima dei dettagli, prima no dopo si' in tre su tre. Catture: `docs/collaudo/GD/simulazioni/catture/gd11_scheda_messaggio_e_dettagli.png`, `gd11_scheda_carta_coperta.png`.

## VOCE GD.12

**CHIUSA.** In cima al responso la terna fare, sentire, capire compare una volta
sola; la scala colorata e' uscita e al suo posto c'e' la mappa dei nove cori
nelle tre sfere, coi segni dipinti dei cori, che accende i cori degli angeli
usciti e lo dichiara in una frase. E' la stessa in tutta la funzione. La regola
permanente in `CLAUDE.md` e' aggiornata. Visto sul Realme. PADRE: ordine GC
voci GC.15 (le carte uscite in cima con la terna) e GC.18 (la scala che la
ripeteva).

DOMANDA: "la prima cosa che l'utente vede del responso è doppia: vede in colonna «fare, sentire, capire» e poi subito sotto con a fianco gli angeli e poi in riquadro con una scala colorata che non serve a niente e non aggiunge nulla, le stesse cose. Serve un restauro del responso e inserimento di infografica che veramente dica qualcosa e abbia un valore aggiunto"
PROVA: `test/gd_l_oracolo_degli_angeli_test.dart`
MISURA: volte che "FARE" compare in cima al responso, prima 2 dopo 1; cori accesi a video uguali a quelli calcolati dagli angeli usciti (prova: Vehuel, Reiiel, Habuhiah, cori {3, 6, 8} attesi e accesi); con l'innesto di un valore scritto a mano {0} la prova cade. Cattura: `docs/collaudo/GD/simulazioni/catture/gd12_responso_dall_alto_prima_cura.png`.

## VOCE GD.13

**CHIUSA.** Il video della Sinastria copre tutto lo schermo, la domanda "Con chi
vuoi scoprire la tua compatibilità?" sta sopra la testa di Medora e resta un
solo pulsante. Visto sul Realme. PADRE: ordine FT voce FT.02 (commit
`c63de67d`) e ordine FY voce FY.11 (commit `0046fa96`).

DOMANDA: "Video introduzione bello, ma è tagliato per fare spazio a testo e pulsante, ma perché è tagliato? Il video copre tutta l'area del telefono e sopra testi e pulsante [...] Prima di tutto, via tutto il testo e lascia solo il pulsante sotto. Sopra la testa di Medora inserisci il testo «Con chi vuoi scoprire la tua compatibilità?»"
PROVA: `docs/collaudo/GD/simulazioni/catture/gd13_sinastria_ingresso.png`
MISURA: area coperta dal video a 390 per 844 punti, prima 82,1 per cento dopo 100 per cento; righe di testo sotto il titolo, prima 2 dopo 0; pulsanti 1 (`test/gd_la_sinastria_evolutiva_test.dart`).

## VOCE GD.14

**CHIUSA.** Il pulsante apre una tendina semitrasparente dal fondo con la scelta
guidata fra online e offline; online vuoto informa e invita, l'invito del
Cerchio si chiude con la freccia e torna alla tendina senza uscire. Visti sul
Realme il primo passo, online vuoto, l'invito, il ritorno, offline vuoto e
offline pieno; online pieno solo nella prova (il telefono di collaudo non ha
amici nel Cerchio, e crearne vorrebbe dire scrivere dati sul server). Cura
trovata nella simulazione: la domanda della scena e il pulsante filtravano
sotto le righe della tendina, ora si dissolvono. PADRE: ordine FT voce FT.14 e
ordine FY voce FY.11.

DOMANDA: "Quando l'utente fa click sul pulsante in basso, si apre verso l'alto una tendina in semitrasparenza con la scelta guidata, uno alla volta, tra on-line e offline."
PROVA: `docs/collaudo/GD/simulazioni/catture/gd14_4_ritorno_nella_tendina.png`
MISURA: passi guidati prima 0 dopo 2; stati provati 4 nella prova e 5 sul Realme; dal ritorno dall'invito la Sinastria resta aperta, si' (`test/gd_la_sinastria_evolutiva_test.dart`).

## VOCE GD.15

**CHIUSA.** Il modulo dei dati sta nella misura tipografica dei Tarocchi, coi tre
campi nei riquadri della casa. Cure trovate nella simulazione: i selettori di
data e ora erano le finestre grigie di sistema, ora sono nel tema della casa;
la frase del modulo dava il maschile ("quando è nato"), ora e' neutra. PADRE:
ordine FT voce FT.03 (commit `ce7906e5`); la frase col genere, ordine GD parte
D, curata qui.

DOMANDA: "La schermata di inserimento dati non va bene, è scarna e confusionaria e Senza un minimo di cura grafica"
PROVA: `test/gd_la_sinastria_evolutiva_test.dart`
MISURA: testi fuori dalla misura tipografica, prima 9 su 14 dopo 0 su 22; campi nei riquadri della casa, prima 0 dopo 3. Cattura: `docs/collaudo/GD/simulazioni/catture/gd15_modulo_prima_cura_scritte_sotto.png`.

## VOCE GD.16

**CHIUSA.** Le quattro icone dipinte dei legami, una sola scelta alla volta; un
altro legame e' una sinastria nuova. Visto sul Realme. PADRE: ordine FT voci
FT.06 e FT.13.

DOMANDA: "L'utente potrà scoprire la sinastria solo di una tipologia alla volta, quindi o Amore o Amicizia o Famiglia o Lavoro. Se vorrà la sinastria di un'altra tipologia, dovrà rifare una sinastria nuova"
PROVA: `test/gd_la_sinastria_evolutiva_test.dart`
MISURA: legami scelti dopo tre tocchi su tre icone, 1; coppie rimaste al piano 15, poi 14 dopo la prima lettura, 14 alla rilettura, 13 con un altro legame. Cattura: `docs/collaudo/GD/simulazioni/catture/gd16_legami_pulsante_spento.png`.

## VOCE GD.17

**CHIUSA.** Breve e Lunga nella Sinastria: la Lunga aggiunge due paragrafi alla
prima risposta, il secondo nel riquadro "Il filo che vi lega"; lucchetto e
invito per chi non ha il piano. La Sinastria evolutiva non chiama nessun
modello: la Lunga viene dal corpus, quindi non esiste un ripiego che la
perda. Visto sul Realme. PADRE: funzione nuova, nessun difetto.

DOMANDA: "Inoltre ci sarà il selettore di profondità breve o lunga. Lunga sarà esclusiva degli utenti premium a pagamento che aggiungerà solo alla prima risposta del responso 2 paragrafi di cui il secondo in riquadro con titolo"
PROVA: `test/gd_la_sinastria_evolutiva_test.dart`
MISURA: paragrafi della prima risposta, Breve 3 e Lunga 5; riquadro col titolo 1; Lunghe composte su 160 coppie per legame, 160 su 160. Cattura: `docs/collaudo/GD/simulazioni/catture/gd17_lunga_2_il_filo_che_vi_lega.png`.

## VOCE GD.18

**CHIUSA.** Il pulsante si accende coi dati completi, parte la riflessione di
Medora e alla fine sul tavolo compare la statua del segno della relazione,
grande e scontornata. Cura trovata nella simulazione: intorno alle statue
restava un alone nero spesso, ora tolto dallo strumento dello scontorno. PADRE:
ordine FT voce FT.06; l'alone, ordine GD parte D, curato qui.

DOMANDA: "Quando avrà inserito i dati si attiverà il pulsante «scopri la compatibilità» Al click sul pulsante, si avvia l'animazione di riflessione come per oroscopo o tarocchi e alla fine comparirà sul tavolo di Medora la statua grande scontornata simbolo della risultato della sinastria"
PROVA: `docs/collaudo/GD/simulazioni/catture/gd18_riflessione.png`
MISURA: altezza della statua, prima 0 dopo 345,1 punti su 844 (40,9 per cento); pixel scuri nella fascia del bordo della statua dei Gemelli, prima 59193 dopo 26029 (`tool/scontorna_le_statue_della_sinastria.py`).

## VOCE GD.19

**CHIUSA.** Il responso apre con le barre dopo il titolo, calcolate dalla
sinastria, e ogni bolla ha la stessa infografica. Cura trovata nella
simulazione: nella bolla stretta le etichette andavano a capo a meta' parola,
ora stanno su una riga. PADRE: ordine FT voci FT.06 e FT.08; le etichette,
ordine GD parte D, curate qui.

DOMANDA: "Il responso mostrerà già all'inizio o quasi, magari dopo il titolo, le barre di infografica. E ogni bolla dovrà avere la sua infografica"
PROVA: `test/gd_la_sinastria_evolutiva_test.dart`
MISURA: barre dopo il titolo prima 0 dopo 5, uguali al ricalcolo dagli aspetti; bolle con la stessa infografica 8. Cattura: `docs/collaudo/GD/simulazioni/catture/gd19_barre_dopo_il_titolo.png`.

## VOCE GD.20

**CHIUSA.** La lista degli amici offline e' una sola: la Sinastria e l'Oroscopo
passano dalla stessa porta. Visto sul Realme: Giulia, scritta nella Sinastria,
sta nella lista "Gli stessi amici dell'Oroscopo". PADRE: ordine FT voce FT.14.

DOMANDA: "la lista di amici offline, devono essere condivisi tra le funzionalità, adesso c'è per l'oroscopo, ma devono essere condivise con le altre funzionalità di compatibilità che verranno"
PROVA: `test/gd20_gli_amici_offline_hanno_una_porta_sola_test.dart`
MISURA: file di lib che toccano la lista, 1 prima e 1 dopo; funzioni che passano dalla porta, prima 1 dopo 2. Cattura: `docs/collaudo/GD/simulazioni/catture/gd14_6_offline_pieno_gd20_dalla_sinastria.png`.

## VOCE GD.21

**APERTA IN ATTESA DI VERIFICA.** La lettura arriva all'amico del Cerchio, senza
dati di nascita; a chi non e' nel Cerchio niente. Provato nel giro fra due
identita' di collaudo finte e nelle prove del server. Resta aperta perche' la
porta `mandaLaSinastria` va pubblicata dal fondatore (comando nel rapporto),
poi si vede sul telefono. PADRE: funzione nuova, nessun difetto.

DOMANDA: proposta dell'Architetto approvata dal fondatore con "2 si"
PROVA: `test/gd21_la_sinastria_arriva_all_amico_test.dart`
MISURA: letture consegnate fra due identita' prima 0 dopo 1, capitoli uguali 5 su 5, dati di nascita nel corpo 0; consegne a chi non e' nel Cerchio 0.

## VOCE GD.22

**CHIUSA.** Sulla scheda della coppia la riga viva di "Oggi fra voi" cambia ogni
giorno e la rilettura non scala nessun contatore. Vista sul Realme il 23
ottobre; il giorno dopo l'ha misurato la prova, perche' spostare la data del
telefono e' un'impostazione di sistema. PADRE: nessun difetto, funzione nuova
sui testi dell'ordine FT voce FT.09.

DOMANDA: proposta dell'Architetto approvata dal fondatore con "3 ok"
PROVA: `test/gd_la_sinastria_evolutiva_test.dart`
MISURA: righe diverse in due giorni, 2 su 2; coppie rimaste alla rilettura, prima 14 dopo 14. Cattura: `docs/collaudo/GD/simulazioni/catture/gd18_statua_prima_cura_alone.png`.

## VOCE GD.23

**CHIUSA.** Nel Respiro della Luna il microfono non c'e' piu': si tiene premuto
sulla Luna per inspirare ed espirare, il dito sollevato ferma luce e conteggio,
ripremendo si riprende. Visto sul Realme nei tre stati. PADRE: ordine FX voce
FX.04 (commit `08f4b578`) e ordine FY voce FY.06 (commit `6c26c958`).

DOMANDA: "per il respiro della luna e solo nella funzione «Respira», espira e inspira con il microfono non funziona perché è difficile determinare se l'utente sta inspirando o espirando, elimina il microfono e lascia solo «tieni premuto per inspirare e per espirare»."
PROVA: `test/gd23_il_respiro_col_solo_dito_test.dart`
MISURA: chiamate al canale del microfono nel rito, prima 3 dopo 0; nomi del microfono nel sorgente, prima 3 dopo 0; giro col dito sollevato per 5 secondi fermo. Catture: `docs/collaudo/GD/simulazioni/catture/gd23_1_prima_del_gesto.png`, `gd23_3_dito_sollevato_fermo.png`.

## VOCE GD.24

**CHIUSA.** Il video di Medora va avanti sull'inspiro e indietro sull'espiro,
comandato per posizione su un tratto con un fotogramma chiave per fotogramma,
e si ferma col dito sollevato. Visto sul Realme (il viso alzato all'inspiro) e
misurato: nessun fotogramma perso. PADRE: ordine FX voce FX.02 (il video montato
solo come scena d'apertura).

DOMANDA: "eravamo d'accordo se non sbaglio, che il video di Medora doveva andare avanti e indietro seguendo «espira e inspira» e per questo avevamo creato il video apposta con Medora che inspira ed espira"
PROVA: `docs/collaudo/GD/simulazioni/gd24_fotogrammi_realme.txt`
MISURA: posizione chiesta al lettore, prima nessuna dopo 2166 ms a meta' inspiro, 4458 ms in cima, 2500 ms a meta' espiro; col dito sollevato 0 posizioni nuove in 3 secondi; sul Realme 703 fotogrammi in 12,6 secondi, 0 persi.

## VOCE GD.25

**CHIUSA.** Entrando nel cielo in tempo reale, e nel cielo dell'onboarding,
compare "Alza il telefono al Cielo", piena per tre secondi e poi in
dissolvenza. Visto sul Realme. PADRE: funzione nuova, nessun difetto.

DOMANDA: "quando si accede al cielo in tempo reale deve comparire una scritta che scompare dopo 3 secondi in disoolvenza «Alza il telefono al Cielo», questo anche nell'onboarding"
PROVA: `test/gd25_alza_il_telefono_al_cielo_test.dart`
MISURA: opacita' della scritta, prima 0 a ogni istante dopo 1,0 a 0,5 s, 1,0 a 2 s, 0,5 a 3,5 s, 0 a 4 s, uguale nelle due schermate. Catture: `docs/collaudo/GD/simulazioni/catture/gd25_cielo_all_ingresso.png`, `gd25_cielo_dopo_quattro_secondi.png`.

## VOCE GD.26

**CHIUSA.** La consegna: manifesto, rapporto con le due dichiarazioni di GD.05
e GD.10, STATO_VIVO, verde di GitHub sul commit `78aff744`
(`refs/verde/78aff7446214675f93d9c9074d96ffed6174072f`), scritto in coda al
rapporto. Nessuna build per i tester e nessuna pubblicazione sul server: i
comandi sono nel rapporto.

DOMANDA: "Si consegna solo col verde, e il commit del verde va scritto nel rapporto."
PROVA: `docs/ordini/RAPPORTO_ORDINE_GD.md`
MISURA: voci del manifesto 26 su 26 con uno stato; verde di GitHub sul commit della consegna, prima assente dopo presente (`refs/verde/78aff744`, 0 rossi nuovi).
