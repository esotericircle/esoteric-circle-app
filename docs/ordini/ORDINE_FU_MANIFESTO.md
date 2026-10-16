# MANIFESTO DELL'ORDINE FU, L'ORACOLO DEGLI ANGELI E LE SCENE DELL'OROSCOPO E DELLA SINASTRIA VIP

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_FU_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FU.md`. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA; una voce aperta dice che cosa aspetta e porta le sue prove. Nessuna build e nessuna chiamata vera al modello in questo ordine (R2, R3): le voci che si vedono solo sul telefono, e quella dei testi scritti dal modello, restano aperte.

VOCI_TOTALI: 17
VOCI_CHIUSE: 9
VOCI_APERTE: 8
VOCI_DA_FARE: 0

## VOCE FU.01

**CHIUSA.** I dieci file dell'Oracolo nel ramo: le immagini in `assets/img/oracolo_angeli/` convertite in webp alla stessa misura, il video in `brand_assets/oracolo_angeli/` con la sua impronta, dichiarati in `pubspec.yaml` e in `docs/stato_asset.json`; nessun asset rigenerato ne' ritoccato nei colori. I cartigli della ruota dello sfondo non sono 72 verificabili (fra 32 e 34 sulla meta' visibile, circa 64-68 in tutto): nessun testo la chiama "ruota dei 72 nomi" e il Da dove viene non la cita. Le due pose di Medora non sono scontornate, perche' la scena ferma di ripiego e' l'ultimo fotogramma intero e non le usa staccate dallo sfondo.

DOMANDA: "Copia i dieci file di P1 nel ramo: le immagini in assets/img/oracolo_angeli/ convertite in webp, il video in brand_assets/oracolo_angeli/."
PROVA: docs/collaudo/FU/fu01_asset.txt
MISURA: nove immagini da 5.580.047 a 1.279.956 byte in tutto; video da 6.587.484 a 2.867.869 byte, SHA-256 836f8d69...0f; cartigli contati 32-34 sulla meta' destra, quindi non 72 verificabili

## VOCE FU.02

**APERTA IN ATTESA DI VERIFICA.** La scena della Scala di Giacobbe: il video parte all'apertura, una volta per apertura, dal primo fotogramma, e si ferma sull'ultimo, che resta come scena per tutta la consultazione coi tre dorsi sull'altare; la domanda affidata sale lungo la scala in lettere di luce disegnate da Flutter con le parole vere della persona; poi i tre dorsi si girano nelle tre carte vere, in prospettiva, nella posizione esatta dell'altare; una nuova domanda non fa ripartire il video. Ripieghi con Riduci Movimento, grafica alleggerita e video che non si carica; audio sotto l'interruttore del suono, muto col telefono in silenzioso.

ASPETTA: il fondatore, alla prossima build che ordinera': aprire l'Oracolo sul telefono, guardare il video partire e fermarsi, affidare una domanda e vedere le lettere salire e le carte girarsi sull'altare. Il filmato vero non si cattura in una prova headless.
DOMANDA: sul momento del video, "parte all'apertura della funzionalità e basta"
PROVA: test/l_oracolo_degli_angeli_a_video_test.dart
MISURA: scarto fra l'ultimo fotogramma del video e la scena ferma 8,42 su 255 (l'Architetto 8,35; contro il primo fotogramma 20,51), in docs/collaudo/FU/fu01_asset.txt; angoli delle carte girate sugli angoli dei dorsi dipinti a 360, 390 e 430 punti (test/l_altare_dell_oracolo_test.dart, rossa col segno della prospettiva rovesciato); cinque prove a video verdi, una aperta del video in tutta la consultazione

## VOCE FU.03

**CHIUSA.** La domanda libera, oppure una delle 21 proposte in sette temi (amore, lavoro, famiglia, amicizia, scelta, crescita, serenita') scritte da Code; tre angeli diversi estratti a caso fra i 72 sul telefono, uno per ruolo: il Custode porta cosa fare, il Cuore cosa sentire, l'Intelletto cosa capire, col medaglione del ruolo e il nome dell'angelo della persona che la porta. Senza l'ora di nascita la terza carta resta coperta con l'invito "Aggiungi l'ora di nascita". Nome e numero delle carte sono testo sovrapposto in Flutter.

DOMANDA: "credo sia indispensabile far fare una domanda libera all'utente oltre a quelle proposte da noi"
PROVA: test/l_oracolo_degli_angeli_test.dart
MISURA: duecento estrazioni, tre angeli diversi in tutte, uno per ruolo (rossa con lo stesso angelo innestato su due carte, docs/collaudo/FU/regola_a_l_oracolo_degli_angeli.txt); portatori uguali ai tre angeli della persona; senza l'ora la terza carta coperta e il suo nome non va al modello; anteprime fu_oracolo_1_domanda, fu_oracolo_1b_proposte e fu_oracolo_6_carta_coperta guardate

## VOCE FU.04

**APERTA IN ATTESA DI VERIFICA.** Una chiamata sola per consultazione a Gemini 2.5 Flash-Lite in europe-west1, con l'etichetta `oracolo_angeli` e la chiamata finta nelle prove: il modello scrive solo il titolo che e' la risposta e il paragrafo nel riquadro (piu' i due paragrafi della Lunga); il primo e il terzo paragrafo vengono dal corpus, gratis. Tetto dei token in uscita 300 per la Breve e 600 per la Lunga. Senza rete, oltre otto secondi o con una risposta che non regge (trattino lungo, parole vietate, tetti superati), parla il solo corpus col titolo del tema riconosciuto, e lo dice a video. Le domande delicate non estraggono carte: Medora risponde con cura e indica il 112.

ASPETTA: il fondatore vede le venti risposte vere (docs/collaudo/FV/fva02_venti_consultazioni.txt) e decide se alzare il tetto di 420 caratteri sul riquadro e sull'approfondimento, restringere la parola vietata "guari" ai soli usi sanitari, o accettare il tasso di ripiego sul corpus misurato. Finche' non decide, la voce resta aperta: il formato non regge ancora in ogni risposta.
DOMANDA: "La B" (Gemini risponde proprio alla frase scritta) e "Per la B dobbiamo cercare di minimizzare il costo, come fatto per i tarocchi"
PROVA: docs/collaudo/FV/fva02_venti_consultazioni.txt
MISURA: ordine FV aggiunta FVA.02, 15 ottobre 2026, prima esecuzione vera: venti consultazioni (dieci Brevi, dieci Lunghe), costo reale 0,003418 dollari contro la stima di 0,005 euro al massimo; risposta dal modello in 14 su 20 (70%); nelle altre sei ha parlato il corpus: quattro per il riquadro sopra il tetto di 420 caratteri (421 a 554), una per l'approfondimento2 sopra tetto (447), una per la parola vietata "guari" su "guarire" in senso non sanitario. Padre di entrambi i difetti: questa stessa voce, il tetto dei caratteri e il filtro delle parole vietate, mai provati prima con risposte vere

## VOCE FU.05

**CHIUSA.** Il corpus nella voce di Medora scritto da Code: per ognuno dei 72 angeli e dei tre ruoli tre varianti, 648 messaggi, piu' due varianti del rito di Caligo per angelo, 144; gli schedari con la fonte, il nucleo, la politica e la gemella in `docs/corpus/oracolo_angeli/LEGGIMI.md`; il generatore `tool/il_corpus_dell_oracolo.py` li porta in `lib/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart` senza modello, e il controllo li ferma su seconda persona, marca del genere, virgola prima di e, accenti, trattino lungo, futuro detto come certezza e parole vietate dalla politica.

DOMANDA: alla domanda su chi scrive il corpus, "Code"
PROVA: docs/collaudo/FU/lettori_ciechi/esito_2.txt
MISURA: 792 testi, 288 celle, celle mancanti 0, difetti al controllo 0; lettori ciechi (agenti di Code, mai Gemini) 60 su 60 al primo giro e 59 su 60 al secondo, ogni prova sopra la soglia; prova test/il_corpus_dell_oracolo_test.dart rossa su due innesti

## VOCE FU.06

**CHIUSA.** Il responso: il titolo che e' la risposta passa da TitoloDelResponso; tre paragrafi nell'ordine Custode, Cuore, Intelletto, il secondo nel riquadro; il Da dove viene breve in corsivo coi 72 nomi dal versetto triplice dell'Esodo 14,19-21, Lenain 1823 e i tre angeli della persona, e la riga che dice che il legame con la domanda lo scrive Medora; la Lunga, dal piano Adepto, aggiunge dopo i tre paragrafi un riquadro con due paragrafi senza spostare il titolo ne' il Da dove viene; "Parlane con Medora" su ogni bolla.

DOMANDA: "Tre paragrafi, uno per carta nell'ordine Custode, Cuore, Intelletto; il secondo nel riquadro."
PROVA: test/l_oracolo_degli_angeli_a_video_test.dart
MISURA: titolo del responso uguale a quello scritto dal modello finto; paragrafi 3, il secondo uguale al riquadro; bolle 3 con il Parlane ciascuna; la Lunga chiede 4 campi invece di 2 (test/l_oracolo_degli_angeli_test.dart); anteprime fu_oracolo_4_responso e fu_oracolo_5_bolla_e_rito guardate

## VOCE FU.07

**CHIUSA.** Sotto ogni carta, chiuso finche' la persona non lo apre, "Il rito con Caligo": il salmo dell'angelo dalla sua scheda, il momento del rito nei venti minuti governati da quell'angelo in ora locale, e il testo breve di Caligo dal corpus della voce FU.05. Nessun sigillo dell'angelo.

DOMANDA: "lascere com'è la Cabala Colta a Caligo" e "Si, approvo tutto" sulla divisione: Medora da' il messaggio, Caligo da' il rito
PROVA: test/l_oracolo_degli_angeli_test.dart
MISURA: momento del rito dell'angelo 1 "dalle 00:00 alle 00:20", del 2 "dalle 00:20 alle 00:40", del 72 "dalle 23:40 alle 00:00"; il rito chiuso all'inizio e aperto al tocco (test/l_oracolo_degli_angeli_a_video_test.dart); riti nel corpus 144, due per angelo

## VOCE FU.08

**CHIUSA.** L'angelo dell'ora, calcolato dall'ora locale del telefono con la stessa regola dell'Angelo dell'Intelletto, in un punto solo (`LOraDegliAngeli`), cambia da se' ogni venti minuti; il messaggio del giorno dai tre angeli della persona, un testo al giorno dal corpus con la rotazione delle varianti, senza modello.

DOMANDA: "Perché la persona dovrebbe tornare il giorno dopo?"
PROVA: test/l_oracolo_degli_angeli_test.dart
MISURA: angelo dell'ora uguale all'Angelo dell'Intelletto su 1.440 minuti su 1.440; prossimo cambio all'inizio dei venti minuti seguenti; in nove giorni almeno sette messaggi diversi, tutti dal corpus; alle 10:05 l'angelo 31 "dalle 10:00 alle 10:20" a video

## VOCE FU.09

**APERTA IN ATTESA DI VERIFICA.** La card nel formato unico (`lib/features/angels/oracolo/oracolo_share_card.dart`), mandata dal Condividi del responso con la porta della Stesa: le tre carte con posizione e nome, il titolo, il marchio; mai la domanda, mai i nomi dei tre angeli della persona, che direbbero la nascita (il Cuore viene dal giorno dell'anno); se il titolo ripete la domanda, al suo posto va il titolo del tema. La carta in dono a un amico del Cerchio sulla strada dei doni che c'era (`mandaUnDono`, dono `angelo`, carta da 1 a 72), col pulsante "Mandala in dono, 30 Eos" prima del gesto e la conferma unica della spesa. La domanda per un amico, dall'Adepto, col gesto della lettura a due telefoni dell'ordine FT: la nascita passa solo col codice, una volta per lettura, col consenso che dichiara lo scopo `oracolo` e porta il minuto locale; "Presta la tua nascita" a ogni piano. Il lavoro sul server e' scritto e provato, non pubblicato.

ASPETTA: `mandaUnDono`, `condividiLaNascita` e `leggiLaNascita` **pubblicate dal fondatore il 15 ottobre 2026** (europe-west1, Node.js 22, esito positivo). Resta il telefono: il dono, la domanda per un amico e la card, alla prossima build.
DOMANDA: "La card condivisibile nel formato unico (Linee Guida sezione 3): le tre carte e il titolo. Mai la domanda stampata, mai dati di nascita."
PROVA: test/l_oracolo_degli_angeli_sociale_e_piani_test.dart
MISURA: arti che condividono senza immagine da 1 (oracolo_angeli) a 0 su 13 (test/custodisci_e_parlane_test.dart, DW.08); testi sulla card 16, occorrenze della domanda 0, dei tre angeli della persona 0, di date o ore 0; pulsanti del dono col prezzo da 0 a 3, doni partiti prima della conferma 0; campi del consenso per l'Oracolo 6 (i 4 dell'ordine FT piu' scopo e minuto locale), campi a mano nel modulo per l'Oracolo 0; prove del server 250 su 250

## VOCE FU.10

**APERTA IN ATTESA DI VERIFICA.** Consultazioni al giorno 1, 3, 5 e 6 per Viandante, Iniziato, Adepto e Illuminato. Al Viandante l'angelo dell'ora, il messaggio del giorno e un assaggio dal solo corpus, senza modello: si scopre il Custode, Cuore e Intelletto col lucchetto e l'invito all'Iniziato. L'Iniziato ha le tre carte con la risposta Breve, col lucchetto sulla Lunga e sulla domanda per un amico; dall'Adepto la Lunga e la domanda per un amico. La consultazione in piu' a 100 Eos (budget `oracoliAngeli`), la carta in dono a 30 Eos; finite le consultazioni, l'invito con le due strade. La Lunga si legge dalla matrice (`RigaDelPiano.oracoloLungaEAmico`); quattro righe nuove nella matrice e una nella descrizione di ogni piano. Il budget del server e' scritto e non pubblicato, e finche' il listino non lo porta l'app non conta.

ASPETTA: `statoDelCerchio` e `muoviGliEos` **pubblicate dal fondatore il 15 ottobre 2026** (esito positivo). Da adesso le consultazioni si contano davvero; resta la prossima build per guardare i lucchetti e l'invito.
DOMANDA: "I numeri dei limiti e degli Eos li decide Code dentro la matrice dei limiti in vigore e la regola del tetto del costo"
PROVA: test/l_oracolo_degli_angeli_sociale_e_piani_test.dart
MISURA: limiti nella matrice, nel listino e nel server [1, 3, 5, 6], prima nessun limite; chiamate al modello nell'assaggio del Viandante 0; lucchetti del Viandante 2, dell'Iniziato 1 piu' quello della domanda per un amico, dell'Adepto 0; chiamate oltre il limite senza riscatto 0, riscatto a 100 Eos che riapre il contatore; caso peggiore del mensile dell'Illuminato dal 29,7 al 29,9 per cento del netto, sotto il tetto del 30 (docs/costi/i_limiti_degli_annuali.txt); righe della matrice da 54 a 58, righe dei piani da 11 a 12 (test/entitlement_test.dart)

## VOCE FU.11

**APERTA IN ATTESA DI VERIFICA.** L'Oracolo degli Angeli esce dal Coming soon: attivo nel catalogo, si apre dalla sua scheda nella riga Cartomanzia del dominio di Medora e nella riga "Trova una risposta" della home, passando dalla soglia unica col suo cuore; dalla schermata dei tre angeli un pulsante porta all'Oracolo. Entra nei conti delle arti, nei gesti del cammino, nel Diario coi numeri dei tre angeli e nelle fonti.

ASPETTA: il fondatore, alla prossima build: toccare la scheda nella home e nel dominio di Medora, e il pulsante dalla schermata dei tre angeli.
DOMANDA: "iniziamo dallo sviluppo dell'oracolo degli angeli"
PROVA: test/tue_arti_schermata_test.dart
MISURA: arti vive senza soglia unica da 1 (angels_oracle) a 0; arti attive senza la tavola delle fonti da 1 a 0; il custodito dell'Oracolo ritrova le sue tre immagini (test/ogni_custodito_ritrova_la_sua_arte_test.dart); il censimento delle porte del Parlane lo conosce (docs/ordini/ORDINE_DX_MANIFESTO.md)

## VOCE FU.12

**CHIUSA.** I tre video nuovi ricompressi prima di entrare nel ramo, in H.264 a qualita' costante 26 col preset lento, alla loro misura d'origine, con l'audio AAC a 96 kbit/s perche' le tre scene lo suonano. La misura a 720 punti e' stata scartata: la polvere d'oro del Sipario si impastava.

DOMANDA: "la mia preoccupazione è che il peso sia eccessivo ovvero verrà ottimizzato, giusto?"
PROVA: docs/collaudo/FU/fu01_asset.txt
MISURA: Oracolo da 6,6 a 2,9 MB, Oroscopo da 10,5 a 4,0 MB, Sinastria VIP da 18,0 a 8,1 MB, in tutto da 35,0 a 15,0 MB; scarto dello stesso fotogramma a 4 secondi prima e dopo 3,40, 2,54 e 4,07 su 255; a 720 sarebbe salito a 4,68 e 6,21 (docs/collaudo/FU/fu12_vip_1080_contro_720.png)

## VOCE FU.13

**APERTA IN ATTESA DI VERIFICA.** La scena dell'Oroscopo: il video della ruota dello zodiaco parte una volta per apertura e si ferma sull'ultimo fotogramma; nel globo entra in dissolvenza l'emblema grande del segno della persona nella tradizione aperta, nelle dodici sedi gli emblemi dei dodici segni piu' tenui con quello della persona nella sede del Sole; per le tradizioni senza dodici segni le sedi restano accese e vuote; poi la lettura sale sopra la scena, che resta ferma e velata. Cambiando tradizione il video non riparte. Testi, periodi e calcoli non cambiano.

ASPETTA: il fondatore, alla prossima build: aprire l'Oroscopo, guardare il video, gli emblemi che entrano e la lettura che sale; e il nome maya con l'apostrofo, che nelle prove mostra due quadrati.
DOMANDA: "alla fine lei resta con davanti il segno dell'utente, magari facendo vedere anche tutti gli altri"
PROVA: test/la_scena_dell_oroscopo_e_un_filmato_test.dart
MISURA: scarto ultimo fotogramma contro la scena ferma 10,33 su 255 (l'Architetto 11,9), spostamento -0,58 e +0,28 pixel, scala 1,0000; globo e dodici sedi a 30 gradi l'una dall'altra con meno di mezzo grado di scarto; contrasto sulle righe sopra il globo 7,36, 8,21 e 8,11 (docs/collaudo/FU/fu13_scena_oroscopo.txt); dodici prove verdi, otto innesti tutti rossi; anteprime fu13 prima e dopo guardate

## VOCE FU.14

**APERTA IN ATTESA DI VERIFICA.** La porta della Sinastria VIP: il Sipario delle Stelle parte una volta per apertura, l'ultimo fotogramma resta come sfondo al posto del cosmo, l'interfaccia di prima compare in dissolvenza; le due carte centrate sulle due cornici di luce rimisurate, grandi quanto il cuore fra le due consente; le cornici restano sotto come alone. Testi, scelte e pulsanti invariati.

ASPETTA: il fondatore, alla prossima build: aprire la Sinastria VIP e guardare il sipario aprirsi e le carte posarsi sulle cornici; e decidere se lo sfondo deve restare inchiodato allo schermo mentre si scorre (oggi scorre con le carte, per non lasciarle fuori dalle cornici).
DOMANDA: "I volti all'interno delle carte sono già piccoli e servono carte più grandi possibili"
PROVA: test/la_scena_della_sinastria_vip_e_un_filmato_test.dart
MISURA: carte a 360x797 da 144,0x216,0 a 152,3x228,5 punti (+5,8% di lato, +11,9% d'area), il limite e' il cuore a 4,0 punti; cornici rimisurate x 167..465 e 614..912, y 736..1232 sul video da 1080x1920; scarto ultimo fotogramma 7,70 su 255 (l'Architetto 7,6), in docs/collaudo/FU/fu14_scena_vip.txt; tredici prove, diciotto innesti tutti rossi; anteprime fu14 prima e dopo guardate

## VOCE FU.15

**APERTA IN ATTESA DI VERIFICA.** Il tocco che salta il video, in un punto solo (`IlToccoCheSalta` in `lib/features/scene/la_scena_in_video.dart`): un tocco ovunque mentre il video gira lo fa sfumare in 450 millisecondi sulla scena ferma, e quello che il video preparava compare subito; il tocco non vale anche come scelta. Ci passano la Stesa, la Sinastria evolutiva, l'Oracolo degli Angeli, l'Oroscopo e la Sinastria VIP.

ASPETTA: il fondatore, alla prossima build: toccare lo schermo mentre gira il video in ognuna delle cinque scene.
DOMANDA: "bisogna fare in modo che con un click il video possa sparire in dissolvenza. Dopo un po' stanca, se qualcuno accede spesso o ripetutamente"
PROVA: test/ogni_scena_si_salta_col_tocco_test.dart
MISURA: scene che aprono un video trovate 5, fuori dal tocco 0, cardinale minimo dichiarato 5; rossa con la Stesa fuori dal tocco (docs/collaudo/FU/regola_a_ogni_scena_si_salta.txt); il tocco salta senza scegliere nella Stesa, nella Sinastria evolutiva, nell'Oracolo, nell'Oroscopo e nella Sinastria VIP, ognuna con la sua prova vista rossa

## VOCE FU.16

**CHIUSA.** "Compatibilità a tre livelli, esclusiva" tolta dalla card dell'Illuminato e la riga "Compatibilità a tre livelli" dalla tabella dei piani, con la lapide; `synastry_three_levels` tolta da soloAbbonamento; i commenti di strade_dello_sblocco, listino_degli_eos e art_catalog corretti; le prove riscritte.

DOMANDA: "hai inserito di togliere la promessa falsa sulla compatibilità a tre livelli?" e "Ok, scrivilo"
PROVA: test/la_compatibilita_a_tre_livelli_non_si_promette_test.dart
MISURA: stringhe di lib lette 61.458, promesse trovate da 2 a 0; vantaggi dell'Illuminato da 12 a 11, righe della matrice da 55 a 54, voci di soloAbbonamento da 7 a 6; rossa con la riga rimessa e con la promessa spezzata in due letterali

## VOCE FU.17

**CHIUSA.** La consegna: manifesto con la sua guardia, rapporto, STATO_VIVO e registro delle guardie; anteprime a 360 per 797 con densita' 3 in `docs/preview/FU/`, guardate una per una; in locale solo le prove delle voci e le guardie della zona, la suite intera sul cancello di GitHub; nessuna build e nessun giro col modello.

DOMANDA: "L'ordine si consegna solo col verde di GitHub sul commit consegnato. Nessun rosso si consegna."
PROVA: docs/ordini/RAPPORTO_ORDINE_FU.md
MISURA: anteprime guardate 21 (6 prima e 7 dopo delle scene dell'Oroscopo e della Sinastria VIP, 8 dell'Oracolo), difetti trovati guardandole 3 (proposte troncate, pannello sul volto di Medora, titolo VIP salito di 56 punti); il verde di GitHub sul commit consegnato e' scritto nel rapporto

## GUARDIE RIMOSSE DOPO LA CONSEGNA

La voce FU.04 qui sopra nomina, dentro la sua MISURA, la prova
`test/l_oracolo_risponde_con_cura_test.dart`: quella frase resta scritta
cosi' com'era il 15 ottobre 2026, perche' il manifesto non si condensa ne'
si riscrive. La guardia che nominava non c'e' piu'.

GUARDIA RIMOSSA: l_oracolo_risponde_con_cura_test - ordine FV aggiunta voce FVA.01, 15 ottobre 2026: il fondatore ha tolto tutta la parte delle domande delicate dell'Oracolo ("elimina tutta la parte e ciò che riguarda alle domande sensibili, non lo abbiamo fatto per le altre funzionalità"); l'Oracolo segue adesso la stessa regola delle chat dei Maestri (MaestroPersona.temaDelicato) col confine del responso, e ogni domanda estrae le tre carte come le altre. La misura sul riconoscimento delle domande sensibili vive adesso dentro test/l_oracolo_degli_angeli_test.dart, voce "nessun numero e nessun invito a chiamare qualcuno".
