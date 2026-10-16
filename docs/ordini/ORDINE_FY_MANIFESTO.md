# MANIFESTO DELL'ORDINE FY, LE CORREZIONI DEL FONDATORE SULLA BUILD 2312

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_FY_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FY.md`. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA; una voce aperta dice che cosa aspetta e porta le sue prove. Il testo dice "Nessuna build" (R3); il fondatore, in chat il 16 ottobre 2026, "Quando hai finito ogni voce, Senza eccezione, consegna build". Lavoro diviso fra Code (parte A, FY.21 e FY.22 per la Luna, la consegna) e tre agenti in worktree, uniti nel ramo: le barre del titolo (FY.20, commit 3e209661), l'Oracolo degli Angeli (parte C, commit 0f8ef9f1), le Sinastrie (parte B, commit 14e660c6).

VOCI_TOTALI: 23
VOCI_CHIUSE: 19
VOCI_APERTE: 4
VOCI_DA_FARE: 0

## VOCE FY.01

**CHIUSA.** Il Calendario Lunare grigio. L'eccezione vera, letta dai registri del Realme sulla build 2312 aprendo il Calendario Lunare Personale dal dominio di Medora: `Invalid argument(s): 134.66666666666666` in `double.clamp`, `calendario_lunare_screen.dart` riga 593. La cima della griglia del mese si calcolava con `(velo.top - 12).clamp(cima + 4, velo.top)`: sul telefono la barra dell'identita' aggiunge la sua altezza al margine alto, la barra del titolo finisce piu' in basso dell'orlo del velo, il primo limite supera il secondo e `clamp` lancia; in una build di rilascio e' il quadro grigio a tutto schermo. Padre FV.02. Corretta la causa: la cima e' la piu' bassa fra l'orlo del velo e il fondo della barra. Nella barra del titolo "Il Respiro" in testo, che spezzava il titolo in "Calenda rio" (stessa cattura), e' diventato l'icona dipinta del respiro. Guardia nuova: l'app vera coi margini del Realme (75 punti in alto, 48 in basso), a 360 e 430 punti col testo a 1,0 e 1,3, entra in ogni arte che ha una rotta e cade se un'eccezione arriva al quadro d'errore.

DOMANDA: "il calendario lunare mostra una schermata grigia a tutto schermo"
PROVA: `test/ogni_arte_si_apre_senza_quadro_grigio_test.dart`
MISURA: arti che si aprono sul quadro grigio coi margini veri, da 1 su 14 (il Calendario, in 4 combinazioni su 4) a 0 su 14

## VOCE FY.02

**CHIUSA.** Via la Bussola. Tolti dal Respiro della Luna la voce della barra in basso, la schermata, il widget `la_bussola_della_luna.dart` con la sua prova, i tre pezzi dipinti di `assets/img/respiro_della_luna/bussola/` (con `pubspec.yaml` e `docs/stato_asset.json`), l'icona della barra, e dai piani (FX.10) la riga che la vendeva ("Respiriamo insieme, con la collana a due e la bussola verso la Luna" e' ora "con la collana a due"). Resta `la_posizione_orizzontale_della_luna.dart`, che serve ai dati della Luna. La barra in basso resta con Luna e Respiro.

DOMANDA: "Respiro della luna, la bussola elimanala, non serve a nulla"
PROVA: `docs/collaudo/FY/giro_della_luna/02_scena_ferma_coi_dati.png`
MISURA: voci della barra in basso da 3 a 2; file della Bussola nel ramo da 5 (widget, prova, tre pezzi dipinti) a 0; righe dei piani che la vendono da 1 a 0

## VOCE FY.03

**CHIUSA.** La Luna senza cornice nera. La foto del Dial-A-Moon e' un JPEG col cielo nero e la parte in ombra nera: il ritaglio tondo di FXA.09 lasciava l'anello nero fra il disco e il ritaglio e l'ombra come un disco nero. Adesso la luce della foto diventa la sua opacita' (`LaLunaSenzaFondoNero`, alfa pari a quattro volte la luminanza): il nero sparisce e sul cielo resta cio' che la Luna illumina. Padre FXA.09 (FX.03 per la foto). Misura su una foto vera della NASA (fotogramma 7000, nei dati di prova) posata sul blu del cielo.

DOMANDA: "La luna presenta una cornice contorno nero"
PROVA: `test/la_luna_non_ha_la_cornice_nera_test.dart`
MISURA: luce dell'anello del bordo del disco contro il cielo (41,92): da 0,51 (senza il filtro) a 41,92

## VOCE FY.04

**CHIUSA.** Scorre tutto, la Luna resta. Nessun riquadro che scorre dentro la schermata: uno scorrimento solo, la schermata intera, con dentro la scena e Medora. Quando il disco della Luna esce in alto, la Luna si fissa in cima, piu' piccola, su una striscia dipinta col nome della fase, la percentuale e l'ora; toccarla riporta su. Sostituisce la regola della scena ferma in alto di FXA.09.

DOMANDA: "Non vogliono riquadro a scorrimento, semplicemente scorre tutto compreso Medora, ma la luna resta sempre presente"
PROVA: `test/scorre_tutto_e_la_luna_resta_test.dart`
MISURA: scorrimenti nella schermata, da 2 (la pagina ferma e il riquadro dei dati) a 1; Luna visibile dopo 600 punti di scorrimento, da 0 a 1 (la Luna fissa a piena opacita' in cima)

## VOCE FY.05

**CHIUSA.** Medora torna col Respiro. Toccando Respiro la schermata torna in cima e la scena e' intera, Medora fino al marmo, e il rito si fa davanti a lei: sotto la Luna, sul mare, il gesto del momento e il giro.

DOMANDA: "Medora torna quando utente fa click su "respiro""
PROVA: `test/scorre_tutto_e_la_luna_resta_test.dart`
MISURA: cima della scena dopo il tocco su Respiro, da -400 punti (rimasta scorsa) a 0; scena intera nella voce Respiro, da tagliata alle spalle a tutta l'altezza del fotogramma

## VOCE FY.06

**APERTA IN ATTESA DI VERIFICA.** Il respiro che funziona. Tre cause vere, nessuna nel calcolo del rito. (1) Il microfono misurava il volume grezzo, e un respiro alla distanza di un telefono non arriva alla soglia di 0,12: adesso conta la forma dell'aria (`BreathDetector(soloAria: true)`, la stessa misura del Soffio del Destino e del rito del sogno), che vale uno quando passa il fiato; padre FX.04. (2) Il giro e il gesto stavano nel pannello sotto la scena, fuori dallo schermo del Realme: chi teneva premuto non vedeva niente avanzare; adesso "Tieni premuto sulla Luna", "Inspira", "Espira", "Giro 1 di 8" e "Respiro compiuto" sono scritti sulla scena, sotto la Luna; padre FXA.09. (3) Lo stato del gesto cambiava senza ridisegnare la schermata, e "Inspira" non compariva; preso dalla prova nuova, padre FX.04. La Luna velata a riposo sale dal 32 al 55 per cento, perche' senza il fondo nero la falce quasi spariva. Il testo dice come si usa il microfono: "soffia piano verso il telefono". Senza permesso del microfono il gesto resta, e l'avviso di casa e' quello di sempre.

ASPETTA: il fondatore, sul telefono: il soffio nel microfono vero, che una prova non puo' fare.
DOMANDA: "Il respiro non funziona ne con microfono né con gesto"
PROVA: `test/il_respiro_si_compie_test.dart`
MISURA: giri interi fino alla perla accesa, col dito da 1 a 1 (gia' compiuto in prova) e col soffio di un microfono finto da 0 (la soglia del volume) a 1; testi del rito visibili sulla scena, da 0 a 2

## VOCE FY.07

**CHIUSA.** Il collegamento al Calendario Lunare. La riga "Trova il giorno giusto nel mese", con l'icona del calendario, c'era in fondo ai dati, ma sul Realme lo spazio dei dati sotto la scena mostrava un dato e mezzo, e la riga non si raggiungeva; e il Calendario, aperto, cadeva sul quadro grigio (FY.01). Adesso scorre tutta la schermata e la riga si raggiunge; il giro di prova la tocca e il Calendario si apre senza eccezioni.

DOMANDA: "Nessun collegamento al calendario lunare"
PROVA: `test/il_giro_della_luna_fy_test.dart`
MISURA: aperture del Calendario dalla riga, senza eccezioni: da 0 a 1 nel giro di prova coi margini veri

## VOCE FY.08

**APERTA IN ATTESA DI VERIFICA.** La Collana intera e leggibile. **Il testo, fatto**: nel velluto restano solo il mese e le perle accese, in grande ("Ottobre", "0 di 30", "perle accese"); la guida passa su una striscia dipinta sotto lo scrigno, a misura di lettura. Padre FXA.01. **Lo scrigno intero, premessa caduta**: l'ovale d'argento esce dai bordi della pittura stessa (`collana_nello_scrigno_spenta_v1`, 1438 per 2576: argento sulle colonne di bordo per 40 righe a sinistra e 43-45 a destra, nel punto piu' largo dell'ovale). Nessuna impaginazione lo mostra intero senza una pittura nuova, piu' larga, con margine intorno all'ovale; le immagini le genera il fondatore, la richiesta e' nel rapporto.

ASPETTA: il fondatore: le due pitture dello scrigno (spenta e accesa) allargate, con margine intorno all'ovale; poi le perle si rimisurano sul file nuovo.
DOMANDA: "La collana della luna è tagliata ai lati e il testo è illeggibile"
PROVA: `test/la_collana_si_legge_test.dart`
MISURA: misura a schermo del testo piu' piccolo della Collana, da 8,2 punti (il nome del ciclo a 320) a sopra i 12 punti a 320, 360, 390 e 430

## VOCE FY.09

**CHIUSA.** Gli avvisi della Luna detti chiari. In cima al foglio: "Gli avvisi della Luna arrivano sul telefono anche quando l'app è chiusa."; sotto ogni interruttore la riga di cio' che arriva e quando: "Ti avviso quando la Luna sorge a Piacenza" (la citta' del luogo, o "dove sei"), "Ti avviso all'ora esatta della Luna piena e della Luna nuova. Ti avviso quando arriva una Superluna.".

DOMANDA: "gli avvisi della luna non si capisce a cosa servono"
PROVA: `test/gli_avvisi_e_le_date_si_capiscono_test.dart`
MISURA: interruttori con la riga di cio' che arriva e quando, da 0 su 2 a 2 su 2

## VOCE FY.10

**CHIUSA.** Le righe dei dati centrate. Lo Stack della riga dipinta non aveva allineamento e metteva il contenuto in alto: le righe senza medaglione, piu' basse dei 48 punti della striscia, stavano 6 punti sopra il centro. Padre FXA.09. Adesso il contenuto e' al centro verticale della striscia.

DOMANDA: "Le info che attualmente scorrono non sono tutte allineate verticalmente al centro del proprio riquadro"
PROVA: `test/le_righe_dei_dati_sono_centrate_test.dart`
MISURA: scarto massimo fra il centro del testo e il centro della striscia, da 6 punti a sotto 2, a 320, 360, 390 e 430 col testo a 1,0 e 1,3

## VOCE FY.11

**APERTA IN ATTESA DI VERIFICA.** La Sinastria evolutiva intera. **Premessa caduta**: il sospetto dell'ordine, FXA.08, non era la causa principale. Il ponte `AvvioSinastriaEvolutiva` (ordine FT voce FT.14, commit ce7906e5) era uno Scaffold nero che al primo fotogramma spingeva "La sua nascita" (codice, "Fai leggere la tua nascita"): scena e lettura arrivavano solo dopo aver dato la nascita. E la FXA.08 (commit 1487d580) aveva avvolto il resto della Sinastria in `IlRestoDopoLaScena` senza l'attesa massima della regia comune, perche' la Sinastria ha un lettore suo: un video che non parte lasciava il resto nascosto per sempre. Adesso il ponte apre subito lo studio di Medora; sulla scena ferma, in fondo, la scelta "Con chi leggo il tuo cielo?" col pulsante dipinto "Scegli la persona"; la lettura compare sotto la stessa scena. Il lettore della Sinastria ha due attese: 4 secondi per partire, la durata piu' 4 per arrivare in fondo. Lavoro di un agente in parallelo (commit 14e660c6, nel ramo).

ASPETTA: il fondatore, sul telefono: aprire la Sinastria evolutiva e vedere lo studio di Medora, non lo schermo nero.
DOMANDA: "La sinastria evolutiva inizia con una schermata nera e le funzioni social, niente altro"
PROVA: `test/la_sinastria_evolutiva_si_apre_sulla_scena_test.dart`
MISURA: scena dello studio all'apertura dalla rotta dell'arte, da 0 a 1; pulsante della scelta nella prima schermata a cinque misure, 5 su 5; video che non si prepara, non parte o si blocca, resto nascosto per sempre da 3 casi su 3 a 0

## VOCE FY.12

**CHIUSA.** Il cuore al centro. Nella porta della Sinastria VIP le carte stavano centrate sulle cornici dipinte e il cuore sul cuore dipinto, e le due cose insieme non lasciavano il cuore a meta' (padre FU voce FU.14); nel responso il cuore era fisso a 90 punti dalla cima (commit 869e2cdf, Blocco 6.5, PROVENIENZA IGNOTA). Adesso le carte hanno il centro all'altezza del cuore dipinto e il cuore sta a meta' dello spazio fra le due, in orizzontale e in verticale. Allargata al responso, che il fondatore non ha nominato, perche' la cattura mostrava lo stesso difetto (scelta dell'agente, commit 14e660c6).

DOMANDA: "Sinastria VIP devi centrare il cuore tra le due carte"
PROVA: `test/il_cuore_sta_fra_le_due_carte_test.dart`
MISURA: scarto verticale del cuore dalla meta' fra le carte nella porta, da 7,67-11,33 punti a 0,00; scarto orizzontale da 0,50-0,74 a 0,00; nel responso da 15,5 punti a 0,00; 48 schermi da 320 a 430 punti

## VOCE FY.13

**CHIUSA.** Dieci domande per argomento. Per ognuno dei sette argomenti dell'Oracolo, dieci domande proposte nella voce di Medora, diverse fra loro, ognuna riconosciuta dal telefono come del suo argomento; il pannello dice quante sono e che scorrono. Corrette anche quattro domande vecchie che il telefono non riconosceva. Padre FU voce FU.03, che ne prevedeva tre. Lavoro di un agente in parallelo (commit 0f8ef9f1, nel ramo).

DOMANDA: "Oracolo Angeli: 10 domande suggerite per argomento"
PROVA: `test/le_dieci_domande_dell_oracolo_test.dart`
MISURA: domande per argomento da 3 a 10 (70 in tutto); somiglianza massima fra due domande 0,44 (sotto 0,5); domande riconosciute fuori dal loro argomento 0

## VOCE FY.14

**CHIUSA.** Via la nascita prestata e la domanda per un amico, dall'Oracolo: la sua parte "per un amico", la sua logica, le varianti delle due schermate della nascita per l'Oracolo; la riga del piano si chiama ora `oracoloLunga` e i testi dei piani non vendono piu' la lettura per un amico. La Sinastria evolutiva resta com'era. Restano inutilizzati lo scopo 'oracolo' sul server e un parametro nel client del Cerchio: toglierli chiede una pubblicazione delle funzioni. Padre FU voce FU.09.

DOMANDA: "Elimina presta la tua nascita e chiedi per un amico"
PROVA: `test/l_oracolo_si_sceglie_e_si_avvia_test.dart`
MISURA: voci "Chiedi per un amico" e "Presta la tua nascita" sull'Oracolo da 2 a 0 ai quattro piani; righe dei piani che vendono "per un amico" da 2 a 0

## VOCE FY.15

**CHIUSA.** Le carte si scelgono. Affidata la domanda, si apre il mazzo coperto col ventaglio della Stesa (`StesaFan`) coi 72 dorsi degli Angeli; una riga dice quale carta si sceglie e chi la porta; ogni dorso scelto si posa sull'altare nella sua posizione, e la carta e' quella del dorso toccato. La guardia dell'ordine DU, che diceva il ventaglio solo della Stesa, ammette ora anche l'Oracolo (FY.15 chiede "il gesto delle altre stese"). Padre FU voci FU.02 e FU.03.

DOMANDA: "Non si possono scegliere le carte"
PROVA: `test/l_oracolo_si_sceglie_e_si_avvia_test.dart`
MISURA: carte uscite uguali agli angeli sotto i dorsi toccati, da 0 (estrazione a caso senza scelta) a 3 su 3, su due scelte diverse

## VOCE FY.16

**CHIUSA.** Il pulsante che avvia la lettura: "Avvia la lettura", dipinto, spento fino alla terza carta. Nulla parte da solo. Padre FU voce FU.02.

DOMANDA: "Non c'è pulsante per avviare la lettura"
PROVA: `test/l_oracolo_si_sceglie_e_si_avvia_test.dart`
MISURA: cose partite da sole in 10 secondi con le tre carte scelte, 0; chiamate dopo il pulsante, 1

## VOCE FY.17

**CHIUSA.** Sotto le carte non resta il video. Quando le carte si girano, sotto non si vedono piu' i dorsi dipinti dell'ultimo fotogramma: `AltareVuoto` prende dal primo fotogramma la fascia dell'altare senza carte, sfumata. Padre FU voce FU.02.

DOMANDA: "Le carte si girano con sotto le carte coperte del video"
PROVA: `docs/collaudo/FY/oracolo/fy17_altare.txt`
MISURA: luminanza ai lati della carta di taglio, da 106,0 (il dorso dipinto, 107,8) a 28,2 (l'altare vuoto, 28,1)

## VOCE FY.18

**CHIUSA.** Ogni carta ha la sua descrizione: chi e' (numero, coro, arcangelo), che cosa porta dalla tradizione col segno "Lenain, 1823", e il suo messaggio. L'angelo 68, Habuhiah, nel corpus non ha la tradizione: per lui la lettura di Medora, detta come tale. Padre FU voce FU.06.

DOMANDA: "Le singole carte non hanno descrizione"
PROVA: `test/l_oracolo_si_sceglie_e_si_avvia_test.dart`
MISURA: carte estratte con la descrizione da 0 a 3 su 3; angeli del mazzo con descrizione e fonte, 72 su 72 (Lenain 71, lettura di Medora 1)

## VOCE FY.19

**CHIUSA.** Una sola coppia di risposta: il titolo e un riquadro; i due paragrafi della risposta Lunga stanno dentro lo stesso riquadro, i messaggi del Custode e dell'Intelletto nelle loro bolle, "Da dove viene" sotto le carte. Padre FU voce FU.06 e ordine FN (il riquadro della Lunga).

DOMANDA: "La prima descrizione è troppo lunga con risposta, riquadro e ancora risposta e riquadro. Basta una coppia"
PROVA: `test/l_oracolo_si_sceglie_e_si_avvia_test.dart`
MISURA: riquadri nel responso da 2 (Adepto) a 1; blocchi di testo fra il titolo e le carte fuori dal riquadro, da 2 a 0

## VOCE FY.20

**CHIUSA.** Le barre del titolo sempre semitrasparenti. Due cause: veli scritti a mano che salivano al 90 o 92 per cento quando il testo passava sotto il titolo (Sinastria evolutiva, ordine FT voce FT.15; Oracolo, ordine FU; Oroscopo, ordine EU voce 19) e barre a fondo pieno (Respiro, Collana, le due nascite delle Sinastrie: ordini FT.03, FX; le altre PROVENIENZA IGNOTA); e il tema che lasciava acceso il passaggio di Material 3 scorrendo (elevazione 3 con ombra e tinta della superficie, comportamento di fabbrica, PROVENIENZA IGNOTA). Adesso il tema comune spegne quel passaggio, il velo comune e' `AppTheme.veloDellaBarra` (0,6), e ogni barra dell'app ci sta sotto in ogni stato; la regola permanente e' in CLAUDE.md. La striscia dell'identita' in alto (volto, Online, Eos, velo 0,92) non porta un titolo e non e' stata toccata: decide il fondatore. Lavoro di tre agenti in parallelo e di Code.

DOMANDA: "Quando scorro in alto, la barra del titolo compare solida di botto e non più trasparente"; "Tutte le barre del titolo di ogni funzionalità devono restare sempre semitrasparenti, tutte e per sempre"
PROVA: `test/le_barre_del_titolo_restano_semitrasparenti_test.dart`
MISURA: barre del titolo sopra il velo comune in almeno uno stato, da 8 su 65 a 0 su 65; barre che scorse prendevano elevazione 3, da circa 50 a 0; Oroscopo scorso da 0,92 a 0,60

## VOCE FY.21

**CHIUSA.** La simulazione di ogni funzione: il giro intero come una persona, in prova d'integrazione, con le catture guardate una per una. Respiro della Luna, Calendario Lunare e Collana: 9 catture in `docs/collaudo/FY/giro_della_luna/` (apertura col video, scena ferma, scorrimento con la Luna fissa, la riga del Calendario e il Calendario, il rito davanti a Medora, "Inspira", "Respiro compiuto", la Collana con la perla di oggi). Oracolo degli Angeli: 16 catture in `docs/collaudo/FY/oracolo/`. Le due Sinastrie: 17 catture in `docs/collaudo/FY/sinastrie/`. Il video e' sempre un lettore finto, che lo dice: il video vero si guarda sul telefono.

DOMANDA: "Code deve fare simulazione per ogni funzionalità qui sopra"
PROVA: `test/il_giro_della_luna_fy_test.dart`
MISURA: funzioni con il giro intero e le catture, da 0 a 6 su 6 (Calendario, Respiro, Collana, Sinastria evolutiva, Sinastria VIP, Oracolo); catture in tutto 42

## VOCE FY.22

**CHIUSA.** Le date sotto il righello intere: si mostra solo la data che sta tutta dentro lo schermo, nei suoi 160 punti. Padre FXA.09.

DOMANDA: "le date sotto il righello del Respiro sono tagliate ai lati ("venerdì" a sinistra)" (l'Architetto, su fy_fondatore_04.jpg)
PROVA: `test/gli_avvisi_e_le_date_si_capiscono_test.dart`
MISURA: date tagliate ai lati lungo un giorno intero, da presenti a ogni ora a 0, a 320, 360, 390 e 430 punti

## VOCE FY.23

**APERTA IN ATTESA DI VERIFICA.** La consegna. Le nove catture del fondatore in `docs/collaudo/FY/catture_fondatore/`; manifesto, guardia del manifesto (`test/ordine_fy_guard_test.dart`), rapporto, STATO_VIVO e registro delle guardie aggiornati; in locale solo le prove delle voci e le guardie delle zone toccate, la suite intera sul cancello di GitHub. Il fondatore ha chiesto in chat la build alla fine di tutte le voci, al posto del "Nessuna build" del testo (R3).

ASPETTA: il fondatore, sul telefono, con la build consegnata: le voci che si vedono solo li' (FY.06, FY.08, FY.11).
DOMANDA: "Quando hai finito ogni voce, Senza eccezione, consegna build"
PROVA: `docs/ordini/RAPPORTO_ORDINE_FY.md`
MISURA: voci dell'ordine con DOMANDA, PROVA e MISURA, 23 su 23; voci chiuse 19, aperte in attesa di verifica 4
