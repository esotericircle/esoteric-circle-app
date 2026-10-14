# MANIFESTO DELL'ORDINE FT, LA SINASTRIA EVOLUTIVA FRA PERSONE REALI

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_FT_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FT.md`. L'ordine chiama la funzione "Sinastria approfondita": il 14 ottobre 2026, a lavoro in corso, il fondatore ha scritto "Cambia nome ovunque da Sinastria Approfondita a sinastria evolutiva", e nell'app, nel codice e in questo manifesto si chiama Sinastria evolutiva (commit 9ac1c8e6). Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA; una voce aperta dice che cosa aspetta e porta le sue prove.

VOCI_TOTALI: 15
VOCI_CHIUSE: 10
VOCI_APERTE: 5
VOCI_DA_FARE: 0

## VOCE FT.01

**CHIUSA.** `assets/img/sinastria/` e `brand_assets/sinastria/` dichiarate in `pubspec.yaml` e in `docs/stato_asset.json`, il video con la sua impronta; le due pose di Medora scontornate col metodo dell'ordine FS, nessun asset ritoccato nei colori.

DOMANDA: "Nessuno e' ancora dichiarato nel pubspec ne' in docs/stato_asset.json: lo fa la voce FT.01"
PROVA: docs/collaudo/FT/ft01_scontorno.txt
MISURA: pixel di bordo con alone chiaro, contro lo scontorno ingenuo, da 4.766 a 14 su 8.334 (astrolabio) e da 5.936 a 9 su 10.588 (mani aperte); pixel trasparenti 657.354 e 650.855 su 1.075.200; impronta SHA-256 del video in docs/stato_asset.json

## VOCE FT.02

**APERTA IN ATTESA DI VERIFICA.** Lo studio di Medora come sfondo, il video dell'astrolabio che parte all'apertura una volta, nello stesso riquadro e taglio, e si ferma sull'ultimo fotogramma; scena ferma a mani aperte con Riduci Movimento, con la grafica alleggerita e col video che non si carica; audio sotto l'interruttore del suono dell'app e muto col telefono in silenzioso; il cosmo resta sotto la scena. Provato nelle prove e nelle anteprime, non guardato sul telefono.

ASPETTA: il fondatore, alla prossima build che ordinera': aprire la Sinastria evolutiva sul telefono e guardare il video partire, fermarsi sull'ultimo fotogramma e tacere col telefono in silenzioso. Il filmato vero non si cattura in una prova headless.
DOMANDA: lo sfondo d'atmosfera della Stesa "e' piaciuto ai fondatori"
PROVA: test/la_scena_della_sinastria_e_un_filmato_test.dart
MISURA: riquadro del filmato nello sfondo misurato con ORB e RANSAC, 251 punti buoni su 300, scala 1,04654 contro 720/688 = 1,04651, dal pixel 0 al 1223 (docs/collaudo/FT/ft02_allineamento.txt); dieci prove del filmato verdi, la grafica alleggerita rossa sull'innesto del tier non letto

## VOCE FT.03

**APERTA IN ATTESA DI VERIFICA.** Le due strade della nascita dell'altra persona: a mano (con "Non conosco l'ora", e allora la Luna tace e la lettura lo dice), oppure la lettura a due telefoni: chi condivide preme "Condivido la mia nascita" e detta un codice di sei caratteri che vale cinque minuti e una lettura sola; chi legge lo scrive nel modulo. La nascita sta solo nel consenso sul server, mai nel profilo pubblico. Le due porte del server (`condividiLaNascita`, `leggiLaNascita`) sono scritte e provate, non pubblicate.

ASPETTA: il fondatore, che pubblica le due porte: cd functions && firebase deploy --only functions:condividiLaNascita,functions:leggiLaNascita --project esoteric-circle; poi due telefoni alla prossima build. Senza la pubblicazione il modulo dice che il Cerchio non risponde e la strada a mano resta. La pubblicazione delle funzioni e' negata a Code.
DOMANDA: "la lettura a due telefoni"
PROVA: test/la_lettura_a_due_telefoni_test.dart
MISURA: nessuna nascita parte prima del gesto del consenso (rossa sull'innesto che la manda all'apertura); campi mandati 4, nessuno del profilo pubblico; prove del server 245 su 245 col consenso che vale una volta e scade a cinque minuti; con l'ora non nota la Luna fuori da aspetti, Composito e Keplero (test/l_ora_non_nota_fa_tacere_la_luna_test.dart, rossa su due prove su due con l'innesto)

## VOCE FT.04

**APERTA IN ATTESA DI VERIFICA.** Il legame amore si apre solo se tutte e due le persone hanno sedici anni compiuti al giorno della lettura, con una riga sobria "Il legame amore si apre dai sedici anni." e nessuna spiegazione sull'eta' dell'altro. Il controllo vive nell'app e sul server: nella lettura a due telefoni il server lo rifa' con la nascita che ha nel consenso, e un suo no chiude l'amore anche se l'app direbbe si'.

ASPETTA: la stessa pubblicazione delle due porte della voce FT.03: il controllo del server vive in `leggiLaNascita`.
DOMANDA: "l'amore dai 16 anni in su"
PROVA: test/lo_sbarramento_di_eta_sul_legame_amore_test.dart
MISURA: rossa a 15 anni e 364 giorni, verde a 16 anni e 0 giorni, sui due lati della coppia, nell'app e nelle prove del server (functions/src/sinastria_evolutiva.test.ts, rossa sull'innesto che apre sempre); il no del server vale fra due adulti (test/la_sinastria_evolutiva_a_video_test.dart, rossa sull'innesto che lo ignora)

## VOCE FT.05

**CHIUSA.** Undici punti per persona (i dieci di IlCieloDiMeeus e il Nodo Nord medio, calcolato accanto a lui senza una seconda porta), cinque aspetti tolemaici con gli orbi gia' approvati della Sinastria VIP, tutto deterministico e senza modello.

DOMANDA: "Prova del calcolo contro una fonte terza su almeno dieci coppie, con gli scarti dichiarati."
PROVA: test/la_sinastria_evolutiva_contro_il_riferimento_test.dart
MISURA: dieci coppie, venti nascite dal 1905 al 2088 contro Swiss Ephemeris (serie Moshier): scarto massimo sui punti 0,004982 gradi (Nodo Nord), dichiarato un centesimo; aspetti dal riferimento 315, diversi 0, al limite dell'orbo 0; rossa col Nodo spostato di due centesimi; Nodo Nord da solo 0,004885 gradi su dieci istanti, dichiarato 0,0055 (docs/collaudo/FT/ft05_nodo_nord.txt)

## VOCE FT.06

**CHIUSA.** Cinque capitoli (attrazione, emozioni, mente, durata, destino) col loro medaglione, quattro legami col loro, il legame che cambia la lettura e non il calcolo; ogni capitolo col titolo che e' gia' la risposta, tre paragrafi col secondo nel riquadro, cosa fare, e il Da dove viene in corsivo. L'immagine della coppia del segno del Sole composito apre la lettura e il ritratto.

DOMANDA: "Il responso e' in cinque capitoli: l'attrazione, le emozioni, la mente, la durata, il destino."
PROVA: test/la_lettura_evolutiva_test.dart
MISURA: duecento letture composte, cinque capitoli e tre paragrafi ciascuna, nessun segnaposto rimasto; il legame lavoro cambia il titolo del capitolo rispetto all'amore (test/la_sinastria_evolutiva_a_video_test.dart); anteprime ft_viandante_2 e ft_viandante_3 guardate

## VOCE FT.07

**CHIUSA.** Il Tema Composito dei punti medi secondo Robert Hand, esclusivo dell'Adepto, col Da dove viene che cita Hand e dice in una riga che cos'e' un punto medio.

DOMANDA: "Il Tema Composito dei punti medi secondo Robert Hand (Planets in Composite, 1975). Esclusiva del piano Adepto."
PROVA: test/la_lettura_evolutiva_test.dart
MISURA: punto medio sull'arco piu' corto, provato anche a cavallo dello zero; per il Viandante la voce e' chiusa col lucchetto e il suo tocco apre l'invito (test/la_sinastria_evolutiva_a_video_test.dart); anteprime ft_adepto_2 e ft_viandante_5 guardate

## VOCE FT.08

**CHIUSA.** Gli intervalli di Keplero fra quattro coppie di punti, con la corda divisa disegnata prima del testo e la consonanza nominata; il Da dove viene cita l'Harmonices Mundi, libro IV. Le corde senza consonanza dicono il loro testo una volta sola.

DOMANDA: "Gli intervalli armonici fra i punti delle due persone, letti secondo l'Harmonices Mundi di Keplero, 1619, come rapporti musicali."
PROVA: test/la_lettura_evolutiva_test.dart
MISURA: ogni consonanza cade nei suoi gradi con orbo di due, una sola per distanza; testi di Keplero ripetuti nella stessa lettura da 1 a 0 (il difetto visto nell'anteprima ft_adepto_1, ora provato in test/la_sinastria_evolutiva_a_video_test.dart)

## VOCE FT.09

**CHIUSA.** Oggi fra voi, una lettura breve di come il cielo di oggi tocca la coppia, dai transiti veri; non e' nata una seconda porta: la porta del cielo del giorno sulla coppia (`MoltiplicatoreCeleste.accensione`) e' la stessa della Sinastria VIP, generalizzata.

DOMANDA: "da' a tutti e due una ragione per tornare ogni giorno"
PROVA: test/il_cielo_del_giorno_e_una_porta_sola_test.dart
MISURA: trecento coppie, il moltiplicatore della VIP identico al bit a prima della generalizzazione (rossa con un mezzo grado d'orbo in piu' innestato); Oggi fra voi cambia col giorno e dice sempre qualcosa (test/la_lettura_evolutiva_test.dart); anteprima ft_viandante_2 col glifo del pianeta, prima un quadratino vuoto

## VOCE FT.10

**CHIUSA.** Il Momento giusto per l'Adepto: al piu' tre giorni favorevoli nei prossimi sessanta, per il legame scelto, ognuno col suo transito e la ragione; nessun giorno detto sbagliato o pericoloso.

DOMANDA: "Consapevolezza, mai fatalismo: nessun giorno e' detto sbagliato o pericoloso."
PROVA: test/la_lettura_evolutiva_test.dart
MISURA: al piu' tre giorni, distanti fra loro, dentro i sessanta; i testi del corpus passano il controllo del futuro detto come certezza (0 difetti su 1.231); anteprima ft_adepto_3 con le date in colonna, prima disallineate

## VOCE FT.11

**CHIUSA.** Il ritratto della coppia da tenere e condividere, esclusivo dell'Adepto: la statuetta della coppia del segno della relazione, il titolo del Composito e i cinque titoli dei capitoli coi loro medaglioni, senza nessun dato di nascita.

DOMANDA: "Il ritratto della coppia da tenere e condividere."
PROVA: docs/preview/FT/ft11_il_ritratto_della_coppia_dopo.png
MISURA: righe del sorgente della card che leggono una nascita, un giorno o una longitudine 0 (l'unica riga che nomina la nascita e' il commento che la vieta); la card e' disegnata fuori campo solo durante lo scatto e passa dalla porta di condivisione di casa

## VOCE FT.12

**CHIUSA.** Il corpus scritto da Code col metodo dell'ordine FM: gli schedari prima, i testi poi, in `docs/corpus/sinastria_evolutiva/`, portati in lib dal generatore senza modello e fermati dal controllo su seconda persona, marca del genere, virgola prima di e, accenti, trattino lungo e futuro detto come certezza.

DOMANDA: "Chi scrive il corpus": "Code"
PROVA: docs/collaudo/FT/lettori_ciechi/esito_2.txt
MISURA: 1.231 testi, 0 difetti al controllo; lettori ciechi (agenti di Code, mai Gemini) 69 su 70 e 68 su 70 in due giri, ogni prova sopra la soglia di otto su dieci; titoli che ripetono lo stesso attacco nella stessa lettura 0

## VOCE FT.13

**APERTA IN ATTESA DI VERIFICA.** I piani: le coppie nuove al giorno 1, 2, 5 e 15; al Viandante Oggi fra voi intero e due capitoli su cinque; Keplero dall'Iniziato; Composito, ritratto e momento giusto dall'Adepto; la coppia in piu' a 150 Eos, col prezzo detto prima del gesto, e finite le coppie l'invito con le due strade, mai un vicolo cieco. Le righe stanno in PlanCatalog e nella descrizione dei quattro piani. Il budget `sinastrieEvolutive` sul server e' scritto e non pubblicato, e finche' il listino non lo porta l'app non conta.

ASPETTA: il fondatore, che pubblica le funzioni del borsellino e dello stato: cd functions && firebase deploy --only functions:statoDelCerchio,functions:muoviGliEos --project esoteric-circle. Fino ad allora le coppie nuove non si contano.
DOMANDA: alla domanda sulla tabella dei piani: "Lo decide Code"
PROVA: test/la_sinastria_evolutiva_si_conta_test.dart
MISURA: col listino di oggi gesti mandati 0 su 5 letture; col listino nuovo la seconda coppia del Viandante chiusa e riscattata a 150 Eos; il ponte apre l'invito a coppie finite (test/il_ponte_conta_le_coppie_nuove_test.dart); highlights dei piani da 10, 15, 14 e 11 a 11, 16, 15 e 12

## VOCE FT.14

**APERTA IN ATTESA DI VERIFICA.** Le porte: la scheda nel dominio di Medora e nella home apre la Sinastria evolutiva (la Sinastria VIP resta com'e'), il segno 15 "Facciamo la sinastria" la apre con l'amico a cui e' mandato, il confronto del cielo con un amico porta il passaggio "Andate più a fondo, con la Sinastria evolutiva"; per chi non e' Adepto si condivide la card del capitolo.

ASPETTA: il fondatore, alla prossima build: toccare la scheda nella home, un segno 15 ricevuto e il pulsante in fondo al confronto del cielo, e condividere una card dal telefono.
DOMANDA: "Appena faremo la sinastria per amici o sinastria approfondita, aggiorneremo il collegamento"
PROVA: test/i_segni_dicono_il_vero_test.dart
MISURA: anteprime ft14_confronto_in_fondo prima (senza passaggio) e dopo (col passaggio), ft14_la_card_del_capitolo; il segno 15 dice il vero sulla funzione che apre

## VOCE FT.15

**CHIUSA.** La consegna: manifesto con la sua guardia, rapporto, STATO_VIVO e registro delle guardie; anteprime prima e dopo a 360 per 797 con densita' 3 in `docs/preview/FT/`, guardate; nessuna build e nessun giro col modello.

DOMANDA: "La suite intera una volta sola alla fine, con prove del client e del server. Nessun rosso si consegna."
PROVA: docs/ordini/RAPPORTO_ORDINE_FT.md
MISURA: anteprime 6 prima e dopo e 13 solo dopo, guardate una per una, sette difetti trovati e corretti (il glifo del pianeta, il velo della barra, il testo di Keplero ripetuto, la colonna delle date, il titolo troncato, l'etichetta del consenso, il passaggio viola); suite intera e prove del server: i numeri nel rapporto
