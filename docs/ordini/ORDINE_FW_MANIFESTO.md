# MANIFESTO DELL'ORDINE FW, I VIDEO DI SCENA DEI TRE MAESTRI: DOMINI E CHAT

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_FW_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FW.md`. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA; una voce aperta dice che cosa aspetta e porta le sue prove. Nessuna build e nessuna chiamata a pagamento in questo ordine (R2, R3): le voci che si vedono solo sul video vero sul telefono restano APERTA IN ATTESA DI VERIFICA.

VOCI_TOTALI: 6
VOCI_CHIUSE: 4
VOCI_APERTE: 2
VOCI_DA_FARE: 0

## VOCE FW.01

**CHIUSA.** I sei video di scena dei tre Maestri e i loro dodici fotogrammi (primo e ultimo per ogni posto) nel ramo: i video ricompressi (voce FW.02) in `brand_assets/maestri_scena/`, i fotogrammi in `assets/img/maestri_scena/` convertiti in webp qualita' 88 alla misura d'origine. Dichiarati in `pubspec.yaml` e in `docs/stato_asset.json` con la loro impronta SHA-256. I nomi nel ramo dicono il posto (dominio o chat di ogni Maestro), non la cartella di origine: lo scambio dei due video di Caligo segue la voce FW.05.

DOMANDA: "Copia i sei video e i loro dodici fotogrammi di P1 nel ramo: i video ricompressi in brand_assets/maestri_scena/, i fotogrammi in assets/img/maestri_scena/ convertiti in webp."
PROVA: docs/collaudo/FW/fw01_asset.txt
MISURA: sei video con la loro impronta SHA-256 in docs/stato_asset.json; dodici webp in assets/img/maestri_scena/; tabella cartella di origine, nome nel ramo, posto nell'app in docs/collaudo/FW/fw01_asset.txt; test/ogni_video_dei_maestri_e_nel_suo_posto_test.dart lega ogni video alla sua impronta e al suo posto, 2 su 2 verdi

## VOCE FW.02

**CHIUSA.** Ogni video ricompresso col metodo dell'ordine FU voce FU.12 (H.264 qualita' costante 26, preset lento, audio AAC 96 kbit/s, perche' ogni scena vive muta finche' l'interruttore del suono non la fa suonare) prima di entrare nel ramo, alla misura d'origine 1080x1920.

DOMANDA: "il timore che il peso dei video sia eccessivo" e la richiesta di ottimizzarli, 14 ottobre 2026.
PROVA: docs/collaudo/FW/fw01_asset.txt
MISURA: peso totale dei sei video da 54.914.776 a 23.712.465 byte (54,9 a 23,7 MB); per video, da/a: medora_dominio 11,1/4,6 MB, medora_chat 12,0/5,0 MB, caligo_dominio 11,1/5,3 MB, caligo_chat 9,8/4,2 MB, aura_dominio 5,4/2,3 MB, aura_chat 5,5/2,4 MB; scarto medio sul fotogramma a 4 secondi, prima e dopo, fra 1,74 e 3,20 su 255 per i sei video (docs/collaudo/FW/*_fotogramma_4s_*.png); scarto dell'ultimo fotogramma contro la scena ferma dichiarata, da 5,81 a 12,32 su 255

## VOCE FW.03

**APERTA IN ATTESA DI VERIFICA.** All'apertura del dominio di ogni Maestro parte il suo video (regia comune `RegiaDellaScena`), si ferma sull'ultimo fotogramma che resta come fondo fisso al posto di `CosmosBackground`; un tocco in qualunque punto lo fa sfumare, senza aprire per sbaglio un pilastro o la chat; con Riduci Movimento la scena resta ferma da subito. Il viso del Maestro non si copre: il contenuto del dominio comincia al 37 per cento dell'altezza dello schermo, uguale per i tre Maestri, e il busto ritagliato di `MaestroScreen` non compare piu' nel dominio (altrimenti la figura si vedeva due volte, corretto in questo stesso ordine dopo averlo visto sull'anteprima vera). Un velo scurisce il fondo da dove comincia il contenuto, misurato e corretto due volte in questo ordine: prima perche' non dipingeva nulla (mancava `Positioned.fill`), poi perche' arrivava a piena forza dopo l'inizio del testo.

ASPETTA: il fondatore, alla prossima build: aprire il dominio di ognuno dei tre Maestri, guardare il video partire e fermarsi sull'ultimo fotogramma, toccare lo schermo e vedere il video sfumare; tornare al dominio da un'arte o dalla chat e verificare se il video riparte (scelta di Code: solo se l'apertura del dominio e' una nuova apertura della schermata, cioe' una nuova `State`, non un semplice ritorno nello stack di navigazione, per coerenza con le altre scene dell'ordine FU che non ripartono ad ogni ritorno).
DOMANDA: "La home dei domini, non la Home dei tre maestri", sul video di scena per la home del dominio di ogni Maestro, "per coerenza"; 15 ottobre 2026.
PROVA: test/la_scena_del_dominio_e_un_filmato_test.dart
MISURA: 7 prove verdi (tre di apertura, una per Maestro, piu' tocco, scena ferma, Riduci Movimento, tocco che non naviga); vista rossa con l'innesto `onSalta: () {}` verificato col grep (docs/collaudo/FW/fw03_regola_a.txt); il busto duplicato e il velo senza `Positioned.fill` trovati guardando `docs/preview/FW/fw06_aura_dominio_ferma_dopo.png`, non dalla sola lettura del codice: contrasto del titolo e della riga sotto, prima della correzione 1,35 e 1,43 (sotto 4,5), dopo 5,53 e 5,22, misurato da docs/collaudo/FW/fw03_contrasto_sulla_cattura.py sul colore piu' frequente della fascia (la moda, non il pixel piu' chiaro ne' la media). Un quarto difetto, trovato dal cancello di GitHub e non da nessuna cattura: con lo spazio al 46 per cento la scheda "Consulta" (la prima azione del dominio) finiva sotto la barra Esplora, sempre in vista sul dominio, e un tocco su di lei veniva assorbito dalla barra invece di aprire la chat (test/il_maestro_non_resta_muto_test.dart, che naviga l'app vera). Portato al 37 per cento e tolto un margine di spaziatura ridondante sopra il titolo quando la scena c'e' gia': la scheda torna sopra la barra con margine, il viso resta scoperto.

## VOCE FW.04

**APERTA IN ATTESA DI VERIFICA.** All'apertura della chat di ogni Maestro, prima del primo messaggio, parte il suo video al posto del busto fermo di `ChatEmptyState`; un ciclo solo, si ferma sull'ultimo fotogramma che resta col benvenuto; un tocco lo fa sfumare senza bloccare il composer, sempre toccabile (il velo del tocco che salta copre solo lo spazio sopra il composer, non l'intero corpo: un primo tentativo col velo su tutta la schermata rendeva muto il pulsante di invio, scoperto da una prova che inviava un messaggio mentre il video girava). Alla prima risposta la scena sale e sfuma, anche se il video sta ancora girando (la risposta non aspetta la fine del video). **La scena e' a tutto schermo**, come il dominio (FW.03): la prima stesura la mostrava dentro un riquadro sopra il saluto, e il fondatore l'ha corretta vista l'anteprima, "E' inaccettabile il riquadro in mezzo alla schermata con il maestro [...] il video deve essere a tutto schermo". Il benvenuto resta leggibile sopra la scena piena grazie a un velo in basso, misurato come quello del dominio.

ASPETTA: il fondatore, alla prossima build: aprire la chat di ognuno dei tre Maestri, guardare il video partire a tutto schermo e fermarsi col benvenuto, toccare lo schermo e vedere il video sfumare, scrivere un messaggio e vedere la scena salire e scomparire alla prima risposta.
DOMANDA: "Ha poco senso 3 cicli per le chat. Gia' alla prima risposta la figura del maestro sale verso l'alto e scompare per fare spazio alla Chat", 15 ottobre 2026, e "E' inaccettabile il riquadro in mezzo alla schermata con il maestro. Trova soluzione elegante e professionale. Il video deve essere a tutto schermo", lo stesso giorno, vista l'anteprima della prima stesura. Premessa P4 dell'ordine corretta: nel codice esistente prima di questo ordine non c'era nessuna animazione di salita della figura, un semplice scambio istantaneo; inventata qui con una `SlideTransition` negativa in Y dentro l'`AnimatedSwitcher` gia' in uso per il passaggio fra la chat vuota e quella coi messaggi.
PROVA: test/la_scena_della_chat_e_un_filmato_test.dart
MISURA: 6 prove verdi (apertura prima del primo messaggio, tocco che sfuma, scena ferma col fotogramma giusto, Riduci Movimento, salita e scomparsa alla prima risposta anche a video ancora in corso, scena che copre lo schermo intero); vista rossa con l'innesto `onSalta: () {}` (docs/collaudo/FW/fw04_regola_a.txt) e di nuovo con la prova dello schermo intero appena scritta, su codice gia' a tutto schermo ma ancora dentro il `SafeArea` (709 punti su 797, docs/collaudo/FW/fw04_tutto_schermo_regola_a.txt); due difetti in piu' trovati dalla stessa correzione, non dalla prova: il volto di `_PresenzaARiposo` restava visibile sopra la scena piena (tolto prima del primo messaggio), il gesto che rivela la barra nascosta (EJ.09) non trovava piu' zona scorribile a sufficienza dopo che il saluto, da solo, si era ristretto (`ChatEmptyState` ora riempie tutta l'altezza disponibile)

## VOCE FW.05

**CHIUSA.** I due video di Caligo scambiati rispetto alle cartelle di origine: `caligo_il_vortice_v1.mp4` (il vortice di fuoco, da Caligo Chat Scena) va nel DOMINIO col fotogramma `caligo_chat_ultimo_fotogramma_v1`; `caligo_la_runa_della_sera_v1.mp4` (il cerchio di fuoco sul tavolo, da Caligo Dominio Scena) va nella CHAT col fotogramma `caligo_dominio_ultimo_fotogramma_v1`. La coppia giusta verificata misurando lo scarto prima di collegarla: il fotogramma giusto da' sempre lo scarto piu' basso.

DOMANDA: "l'ultimo video di Caligo dove lo avvolge il fuoco, io lo userei per il suo dominio essendo di forte impatto e l'altro per la chat", 15 ottobre 2026.
PROVA: docs/collaudo/FW/fw05_regola_a.txt
MISURA: scarto della coppia giusta 9,78 (dominio) e 12,01 (chat) su 255; scarto della coppia scambiata 18,67 e 18,59, quasi il doppio; test/ogni_video_dei_maestri_e_nel_suo_posto_test.dart cade se una coppia si scambia, vista rossa scambiando davvero i due file e verificando l'impronta SHA-256 dopo lo scambio (docs/collaudo/FW/fw05_regola_a.txt), poi ripristinata e riletta identica byte per byte

## VOCE FW.06

**CHIUSA.** La consegna: manifesto con la sua guardia, rapporto, STATO_VIVO e registro delle guardie aggiornati; anteprime a 360 per 797, densita' 3, in `docs/preview/FW/`, guardate una per una prima di chiudere le voci (hanno trovato quattro difetti veri in due giri, scritti nelle voci FW.03 e FW.04, l'ultimo dopo che il fondatore ha visto la consegna e ha chiesto la scena della chat a tutto schermo). Nessuna build, nessuna chiamata a pagamento.

DOMANDA: "L'ordine si consegna solo col verde di GitHub sul commit consegnato. Nessun rosso si consegna."
PROVA: docs/ordini/RAPPORTO_ORDINE_FW.md
MISURA: anteprime guardate 6 (dominio e chat ferme per i tre Maestri), rigenerate e riguardate altre due volte dopo la correzione della chat; difetti trovati guardandole 4 (busto duplicato e velo del contrasto nel dominio; scena della chat dentro un riquadro, invece che a tutto schermo come chiesto dopo la consegna, e i due difetti che quella correzione ha scoperto, il volto a riposo sopra la scena piena e il gesto della barra nascosta senza piu' zona scorribile); il verde di GitHub sul commit consegnato e' scritto nel rapporto
