# MANIFESTO DELL'ORDINE FX, IL RESPIRO DELLA LUNA

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_FX_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FX.md`. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA; una voce aperta dice che cosa aspetta e porta le sue prove. Nessuna build in questo ordine (R3), nessuna chiamata a pagamento: le voci che si vedono solo sul telefono, o che aspettano una pubblicazione sul server, restano aperte.

VOCI_TOTALI: 13
VOCI_CHIUSE: 5
VOCI_APERTE: 8
VOCI_DA_FARE: 0

## VOCE FX.00

**CHIUSA.** Il Calendario Lunare sceglie un giorno nel mese; il Respiro della Luna e' l'appuntamento con la Luna di adesso, ogni giorno, in un minuto: un minuto di respiro accordato alla fase, una perla al giorno nella collana, la consegna di Medora alla Luna nuova. Il calendario biodinamico e i consigli per categoria della sezione 38 del Briefing V13 restano nel Calendario Lunare ("Trova il giorno"): qui non si ripetono. Dal Respiro una porta "Trova il giorno nel mese" apre il Calendario; dal Calendario una porta "Il Respiro" apre il Respiro di oggi (FX.11).

DOMANDA: "Avevamo lasciato il respiro della Luna indietro giusto? Per una retention giornaliera?"; la proposta dell'Architetto, approvata con "Approvato"
PROVA: `lib/core/arts/art_catalog.dart`
MISURA: le tre righe della differenza sono quelle sopra, le stesse del nuovo teaser di `art_catalog.dart`; nessun contenuto della sezione 38 duplicato nel Respiro (verificato a mano confrontando le due voci del catalogo, `lunology` e `lunar_calendar`)

## VOCE FX.01

**CHIUSA.** I file di P1 nel ramo, fuori da `Lavoro\`: i due video ricompressi (H.264 qualita' costante 26, preset lento, AAC 96 kbit/s, lo stesso metodo FU.12) in `brand_assets/respiro_della_luna/`; le immagini in `assets/img/respiro_della_luna/`, `collana/` e `bussola/` convertite in webp mantenendo la trasparenza; dichiarati in `pubspec.yaml` e `docs/stato_asset.json`. La cattura di Dora in `docs/collaudo/FX/catture_fondatore/`. La scia di luna ha trasparenza vera (canale alfa non costante, verificato pixel per pixel). Nessun asset rigenerato o ritoccato.

DOMANDA: "Si salva" sul video della scena; "Va bene questo per ora" sul video della consegna
PROVA: `docs/collaudo/FX/fx01_asset.txt`
MISURA: dodici immagini da 2.883.869 a 940.142 byte in tutto; `medora_il_respiro_della_luna_v1.mp4` da 7.146.087 a 2.120.306 byte, scarto sull'ultimo fotogramma 6,70 su 255; `medora_la_consegna_della_collana_v1.mp4` da 5.197.255 a 2.159.176 byte, scarto 6,57 su 255; totale da 16.946.578 a 5.560.344 byte; `scia_di_luna_v1.webp`, 1523x798, alfa da 0 a 255 su 834.721 e 380.630 pixel, non costante; `docs/stato_asset.json` coerente con `pubspec.yaml`, 61 voci su 61, verificato con un parser indipendente

## VOCE FX.02

**APERTA IN ATTESA DI VERIFICA.** La scena del Respiro, sulla stessa schermata di FX.03 e FX.04 (`IlRespiroDellaLunaScreen`): all'apertura parte `medora_il_respiro_della_luna_v1.mp4` dal lettore e dalla regia comuni (P10), una volta per apertura; sull'ultimo fotogramma la Luna dipinta lascia il posto, in dissolvenza, alla Luna vera di FX.03. Con Riduci Movimento, grafica alleggerita o video che non carica, scena ferma su `respiro_cielo_senza_luna_v1` con la Luna vera; audio e tocco che salta come le altre scene.

ASPETTA: il fondatore, alla prossima build che ordinera': aprire il Respiro e vedere il video partire e fermarsi sull'ultimo fotogramma. Il video vero non si cattura in una prova headless.
DOMANDA: "No, si ripete sempre il video, ma si può sfumare saltare con un click"; "parte all'apertura della funzionalità e basta"
PROVA: `test/il_respiro_della_luna_test.dart`, `docs/preview/FX/fx0234_respiro_scena_ferma.png`
MISURA: `test/il_respiro_della_luna_test.dart` 7 su 7 verdi; `flutter analyze` pulito. **Un difetto vero preso dalla prima anteprima vera, non da una prova**: la scena restava completamente nera, le immagini non avevano finito di decodificarsi al momento dello scatto; non e' un difetto della schermata ma della cattura, corretto nella prova con `precacheImage` dentro `runAsync`, come gia' fa `test/le_anteprime_del_lunario_test.dart` (`docs/preview/FX/fx0234_respiro_scena_ferma.png`, rigenerata, la scena si vede).

## VOCE FX.03

**APERTA IN ATTESA DI VERIFICA.** La Luna al centro e' la foto vera dell'ora in corso, presa dal Dial-A-Moon della NASA (`IlDialAMoon`, indirizzo e condizioni verificati il 16 ottobre 2026 su svs.gsfc.nasa.gov/5587/, `docs/collaudo/FX/fx03_dial_a_moon_verifica.md`); senza rete o fuori dalla serie 2026 ricade sulle trenta lune locali per elongazione, la funzione non resta mai senza Luna. Sotto la Luna: la percentuale di luce, il sorgere o il tramonto col conto alla rovescia (a seconda che la Luna sia sopra o sotto l'orizzonte), la distanza in chilometri con l'avviso di Superluna, quanto manca alla prossima piena e alla prossima nuova (`DatiDellaLunaDiQuestOra`, composizione pura delle porte astronomiche di P2 e P7, nessun calcolo nuovo). Il tempo scorre sotto il dito su una striscia dedicata (non sulla Luna stessa: i due gesti, scorrere il tempo e tenere premuto per respirare in FX.04, vivono su due zone diverse, altrimenti si confonderebbero allo stesso tocco), con uno scatto della vibrazione al cambio di fase principale; la corsa e' di 24 ore per il Viandante, di un mese per chi ha il piano (FX.10). La Luna risponde al tocco con una piccola rotazione e un respiro di luce, lo stesso gesto che FX.04 porta a compimento.

ASPETTA: il fondatore, alla prossima build: vedere la Luna vera, scorrere il tempo sotto il dito e sentire lo scatto al cambio di fase. La foto vera scaricata dalla NASA non si cattura in una prova headless, solo il suo ripiego locale.
DOMANDA: "LA FOTO VERA, ORA PER ORA... sorge tra 32 minuti... Trascinando il dito in orizzontale il tempo scorre avanti e indietro... si può ruotare"
PROVA: `test/la_luna_di_quest_ora_test.dart`, `test/il_dial_a_moon_test.dart`, `test/il_sorgere_della_luna_test.dart`, `test/la_distanza_della_luna_test.dart`, `test/la_posizione_orizzontale_della_luna_test.dart`, `docs/collaudo/FX/fx03_pannello_regola_a.txt`, `docs/preview/FX/fx0234_respiro_scena_ferma.png`
MISURA: `test/la_luna_di_quest_ora_test.dart` 6 su 6; `test/il_dial_a_moon_test.dart` 9 su 9 (indirizzo e fotogramma per istanti dentro e fuori la serie 2026, ripiego su errore e su risposta non-200, rotazione); distanza della Luna verificata contro Meeus 47.a e quattro perigei/apogei 2026, scarto massimo 0,4 km; sorgere/tramonto/culminazione contro USNO e timeanddate.com per tre citta', scarto massimo 1 minuto; azimut e altezza contro timeanddate.com, scarto massimo 0,78 gradi prima della parallasse diurna, sotto 0,1 grado dopo averla applicata. **Due difetti veri presi dalla prima anteprima vera, non da una prova**: il titolo tagliato a "Il ..." (tre azioni di testo nella barra non lasciavano spazio al titolo, corretto con `TitoloCheNonSiRompe` e un'unica porta "Altro"); il pannello sotto la Luna, con sei righe di testo, cresceva abbastanza da toccare il centro della Luna e il tocco sostenuto smetteva di accenderla (presa da `test/il_respiro_della_luna_test.dart`, gia' esistente, non da un innesto), condensato a tre righe con `maxLines` ed ellissi, `docs/collaudo/FX/fx03_pannello_regola_a.txt`.

## VOCE FX.04

**APERTA IN ATTESA DI VERIFICA.** Un minuto di respiro guidato, la Luna si accende con l'inspiro e si vela con l'espiro, un anello di perle accese ne segue il ritmo; coi tempi accordati alla fase (crescente 5s/3s, calante 3s/5s, sizigie 4s/4s, chiave di Medora, mai tradizione, R8). Il gesto e' doppio e sempre attivo: tenuto giu' col dito o sentito dal microfono (`BreathDetector`, lo stesso del Soffio del Destino, riusato senza cambiarne il comportamento) valgono la stessa cosa. A rito compiuto si accende la perla del giorno sulla Collana (FX.05); si puo' rifare quante volte si vuole, la perla resta una.

ASPETTA: il fondatore, alla prossima build: respirare col dito e col microfono, vedere la Luna accendersi e velarsi, vedere la perla accendersi sulla collana al rito compiuto.
DOMANDA: "Un minuto di respiro guidato accordato alla fase: con la Luna crescente l'inspiro è più lungo, con la calante l'espiro"; "il microfono sente il soffio, ripiego tattile"
PROVA: `test/il_respiro_della_luna_test.dart`
MISURA: 7 su 7 verdi (tempi per fase accordati alla fase di oggi, flag "respirato oggi" idempotente, il gesto doppio che accende e vela la Luna, tenuto giu' e lasciato). `flutter analyze` pulito.

## VOCE FX.05

**APERTA IN ATTESA DI VERIFICA.** La collana segue la lunazione vera (`IlMotoreLunare.luneNuoveFra`): 29 o 30 perle secondo il ciclo in corso. Ogni giorno respirato diventa `perla_finestra` con la Luna vera di quel giorno; ogni giorno saltato resta `perla_spenta`, nessun rimprovero. Le perle stanno sulla catenella, chiusa dal fermaglio; a collana completa si aggiunge la medaglia. Alla Luna nuova, se almeno un giorno del ciclo e' stato respirato, parte una volta sola la scena della consegna (`medora_la_consegna_della_collana_v1.mp4`), poi comincia la collana nuova. Una perla spenta recente si puo' ricucire (costo e limiti scelti da Code, coerenti col listino del lunario: 25 Eos, fino a 3 perle per ciclo, fino a 7 giorni indietro), ma solo con un credito gia' comprato: **la schermata non mostra mai un tasto "Ricuci" senza un credito vero da spendere** (Linee Guida UX V13 sezione 4, "quando la fonte non ha parlato il numero non si indovina"), finche' la porta server che vende la ricucitura non e' pubblicata resta un invito ad aspettare, non una spesa finta. La collana del ciclo e' la card condivisibile, sullo scrigno; le collane passate restano in un piccolo scrigno delle collane.

ASPETTA: il fondatore, alla prossima build: respirare qualche giorno e vedere le perle accendersi, vedere la scena della consegna alla Luna nuova, condividere la card. La pubblicazione della porta server che vende la ricucitura (non scritta in questo ordine: nessuna voce del listino della ricucitura ha ancora una callable, R3).
DOMANDA: "Ogni giorno respirato aggiunge alla tua collana una perla dipinta con la fase vera di quel giorno. Una lunazione è di 29 o 30 perle. Il giorno saltato resta una perla scura, senza punizioni. A collana completa, alla Luna nuova, Medora te la consegna con un video breve e ne comincia una nuova. La collana del mese è la card da condividere"; sul prezzo della perla ricucita, "lo decide code"
PROVA: `test/la_collana_delle_lune_test.dart`, `docs/preview/FX/fx05_collana_in_corso.png`
MISURA: 9 prove verdi (il numero di perle dalla lunazione vera, i giorni respirati accesi e i passati spenti, la ricucitura coi suoi due limiti rispettati, la consegna che non parte senza giorni respirati, `segnaConsegnata` che archivia e non rifa' partire, la schermata vera che mostra la collana e ricuce una perla spenta). **Un difetto vero preso da una prova gia' esistente**: la prova presumeva un tasto "Ricuci" sempre presente, mentre la schermata corretta lo mostra solo con un credito gia' comprato; la prova simula ora il credito (come fara' la porta server quando sara' pubblicata) invece di aspettarsi una spesa finta. Anteprima guardata: lo scrigno e le perle si vedono con l'asset vero, nessun disegno procedurale; resta da confermare sul telefono la leggibilita' del testo dei chip di ricucitura, piccolo nella cattura.

## VOCE FX.06

**APERTA IN ATTESA DI VERIFICA.** Il quadrante resta fermo a schermo; l'ago e la scia (asset, mai disegno procedurale) ruotano con lo scarto fra l'azimut che il telefono guarda adesso e l'azimut vero della Luna (`posizioneOrizzontaleDellaLuna`, con la parallasse diurna). Sotto 12 gradi di separazione angolare vera il telefono "punta la Luna": una vibrazione breve e la foto vera della Luna (`LeLuneDellaNasa`) al centro del quadrante. Se la Luna e' sopra l'orizzonte, un invito a uscire a guardarla; se sotto, quando sorge (`prossimoSorgere`). Ripiego senza bussola o con la bussola instabile: direzione e altezza scritte in parole, con l'invito a tarare descrivendo un otto.

ASPETTA: il fondatore, alla prossima build: alzare il telefono e vedere l'ago puntare verso la Luna vera, sentire la vibrazione quando la trova, vedere il ripiego scritto senza bussola.
DOMANDA: "alzi il telefono e una scia d'argento ti guida verso la Luna nel cielo vero. Se è sopra l'orizzonte: Esci, è lì"
PROVA: `test/la_bussola_della_luna_test.dart`
MISURA: 11 prove verdi (l'ago che ruota dello scarto giusto verso la Luna vera, il ripiego testuale senza sensore). Azimut e altezza verificati contro timeanddate.com per tre citta', scarto massimo 0,78 gradi senza la parallasse diurna, sotto 0,1 grado dopo averla applicata (la correzione vera che la bussola usa). **Un difetto vero**, trovato in integrazione e non da un innesto: la bussola usava l'altezza geocentrica nuda invece di quella topocentrica gia' corretta e verificata altrove nello stesso ordine, corretto sostituendo la composizione a mano con `posizioneOrizzontaleDellaLuna`.

## VOCE FX.07

**CHIUSA.** Tre righe al giorno nella voce di Medora: la Luna nel segno e l'ora in cui cambia (o, se oggi non cambia, lo dice); la Luna fuori corso in tempo reale con l'ora di fine, dalla tradizione di William Lilly (la stessa fonte del motore lunare); il giorno lunare, solo il numero. Nessuna chiamata al modello (R2): corpus scritto da Code. Cercato con WebSearch un sistema di significati documentato per i trenta giorni lunari nella tradizione popolare europea: nessuna fonte seriamente citabile trovata (il tithi induista nomina solo i primi quindici giorni ed e' un'altra tradizione); la terza riga resta il solo numero, nessun significato inventato.

DOMANDA: "Tre righe di oggi: la Luna nel segno, il giorno lunare e la Luna fuori corso in tempo reale"
PROVA: `test/la_parola_di_medora_del_respiro_test.dart`
MISURA: 9 prove verdi (la riga del segno prima e dopo il cambio, la riga del fuori corso nei tre casi dichiarati, il giorno lunare). Ricerca sui trenta giorni lunari dichiarata senza esito nel commento del file, con le fonti cercate.

## VOCE FX.08

**APERTA IN ATTESA DI VERIFICA.** Tre avvisi, ognuno attivabile e disattivabile: la Luna che sorge nel luogo della persona (il testo nomina la citta'), la Luna piena e la Luna nuova all'istante esatto, con l'avviso di Superluna quando la piena cade sotto 361.885 km dal perigeo (criterio di Richard Nolle 1979, la definizione piu' citata in italiano). Nessun avviso fra le 23 e le 7: un sorgere o una sizigia in quella fascia si salta, non si rimanda, perche' un avviso tardivo direbbe il falso.

ASPETTA: il fondatore, alla prossima build: accendere gli avvisi e vedere arrivare quello della Luna che sorge nel giorno giusto, con l'orario vero e il nome della citta'.
DOMANDA: "La Luna sorge adesso a Piacenza; ogni giorno l'orario cambia. Poi la Luna piena, la nuova, la Superluna"
PROVA: `test/gli_avvisi_del_respiro_test.dart`
MISURA: 9 prove verdi (il sorgere che nomina la citta' e rispetta la fascia di quiete, le sizigie con l'orario vero del motore, la soglia della Superluna sopra/sotto/esattamente al confine, i due interruttori persistiti). **Un difetto vero**, trovato integrando l'estensione astronomica di FX.02-04: la prova calcolava il sorgere in proprio con la porta generica del Real Time Cosmo invece che con `prossimoSorgere` (la soglia precisa di Meeus 15.1 con la parallasse vera), 16 minuti di scarto tra le due; corretto usando la stessa porta della produzione.

## VOCE FX.09

**APERTA IN ATTESA DI VERIFICA.** All'istante della Luna piena si apre, per un'ora, il respiro collettivo: le porte server `respiroInsiemeEntra` e `respiroInsiemeConteggio` (scritte e non pubblicate, R3) contano quante persone stanno respirando e quali amici del Cerchio fra loro, senza dati personali oltre a quelli che il Cerchio gia' mostra. La collana a due nasce da un invito fra due amici veri (`invitaCollanaADue`, `rispondiCollanaADue`): la sua perla del giorno si accende solo se entrambi segnalano il respiro fatto (`segnalaRespiroDelGiornoPerLaCollanaADue`). E' un'esclusiva di Adepto e Illuminato (FX.10); chi non ce l'ha nel piano puo' comprare un assaggio o una collana a due a Eos, crediti locali (`GliEosDelRespiro`) finche' il server non pubblica anche l'acquisto.

ASPETTA: la pubblicazione delle sei porte server (R3, nessuna pubblicazione senza il si' del fondatore e la stima del costo); la UI che mostra il contatore e la card a due nomi, non costruita in questo ordine (i modelli `RespiroInsiemeStato` e `CollanaADue` sono pronti, in `lib/core/cerchio/il_cerchio_sociale.dart`, con un commento che dice a chi tocca costruirla).
DOMANDA: "Alla Luna piena, all'ora esatta, un rito collettivo di un minuto: vedi quante persone stanno respirando con te in quel momento e quali amici del Cerchio. Puoi invitare un amico a completare la collana insieme"; "la collana a due si completa solo se respirate tutti e due"
PROVA: `test/il_respiro_della_luna_sociale_e_piani_test.dart`, `functions/src/il_respiro_della_luna.test.ts`
MISURA: 11 prove Dart verdi, 5 prove TypeScript pure verdi; `npm test` del server 258 su 258 (incluse le guardie EY.16 e EZ.04 aggiornate a 34 porte sociali). **Due difetti veri trovati e corretti nella stessa voce**: `dataCivileValida` non rifiutava "2026-02-30" (`Date.parse` normalizza invece di fallire), corretto ricomponendo la data con `Date.UTC` e confrontando anno/mese/giorno; l'export di `segnalaRespiroDelGiornoPerLaCollanaADue` spezzava `onCall(` su una riga diversa da `export const`, e la guardia EY.16 (che conta le porte riga per riga) non lo vedeva, corretto riportando la dichiarazione su una riga sola.

## VOCE FX.10

**APERTA IN ATTESA DI VERIFICA.** La matrice vera (`PlanCatalog`, righe `RigaDelPiano.respiro*`): il Viandante ha la Luna di quest'ora, il respiro di oggi, la parola di Medora, la perla del giorno, col tempo sotto il dito solo nelle 24 ore di oggi; l'Iniziato aggiunge la collana completa con la consegna e lo scrigno, gli avvisi, il tempo sotto il dito su tutto il mese; Adepto e Illuminato aggiungono Respiriamo insieme con la collana a due e la bussola. Il listino (`ListinoDegliEos`): perla ricucita 25 Eos (sotto il confronto del cielo in piu' del lunario, 30, perche' non sblocca niente di nuovo), un assaggio di Respiriamo insieme 40 Eos, una collana a due 50 Eos (lo stesso prezzo della proposta insieme del lunario, stesso gesto a due persone). Ogni voce chiusa dal piano resta Premium bloccata col lucchetto e l'invito, mai un vicolo cieco.

ASPETTA: la pubblicazione delle porte server che spendono davvero gli Eos per questi acquisti (non scritte in questo ordine: nessuna callable "compra" per le tre voci del listino del Respiro, R3); la decisione del fondatore su quando aprirle.
DOMANDA: il fondatore, sulla tabella proposta, "1 ok"; sul prezzo in Eos, "lo decide code"
PROVA: `test/il_respiro_della_luna_sociale_e_piani_test.dart`
MISURA: la matrice coperta dalle stesse 11 prove di FX.09 (il Viandante non ha nulla oltre il gratuito, i piani superiori aprono le voci giuste); listino verificato contro `test/il_listino_vivo_test.dart` e `test/la_lunga_si_apre_con_gli_eos_test.dart`, nessuna regressione.

## VOCE FX.11

**CHIUSA.** Il Respiro della Luna esce dal Coming soon (`art_catalog.dart`, `ArtState.attiva`), col teaser riscritto (FX.00) e la sua rotta vera in `art_navigation.dart` (`case 'lunology'`). La porta sta nel dominio di Medora, sezione Lunologia. Dal Respiro, il foglio "Altro" porta "Trova il giorno nel mese" al Calendario; dal Calendario, un pulsante "Il Respiro" nella barra apre il Respiro di oggi: due arti separate e collegate.

DOMANDA: "Separati e collegati" sui due calendari
PROVA: `test/art_catalog_test.dart`
MISURA: 23 prove verdi in `test/art_catalog_test.dart`, incluso il test che ogni arte dichiarata attiva nel catalogo ha una rotta vera, verde anche con `lunology` aggiunta (nessuna riga rossa nuova); le due porte reciproche verificate a mano nel codice (`respiro_vai_al_calendario` in `lib/features/lunario/calendario_lunare_screen.dart`, `case 'lunology'` in `lib/features/maestri/art_navigation.dart`), con le chiavi dichiarate per una prova di navigazione futura.

## VOCE FX.12

**CHIUSA.** Manifesto, guardia del manifesto (voce implicita, verificata dalla quadratura dei marcatori), rapporto, STATO_VIVO e registro delle guardie aggiornati. La guardia della grafica dipinta (R9) estesa a `lib/features/respiro_della_luna/`, vista rossa su un innesto verificato col grep (`docs/collaudo/FX/fx12_grafica_del_respiro_regola_a.txt`), che ha anche trovato e corretto un falso positivo in un commento di `la_bussola_della_luna.dart`. Due anteprime vere generate e guardate (`docs/preview/FX/`), non solo rigenerate: hanno preso due difetti veri (il titolo tagliato, la scena nera) prima di questa consegna. In locale sono girate solo le prove della voce e le guardie della zona toccata; la suite intera la fa il cancello di GitHub.

DOMANDA: le regole fisse R3, R6, R9, R12 dell'ordine
PROVA: `docs/ordini/RAPPORTO_ORDINE_FX.md`
MISURA: registro delle guardie passato da 796 a 797 (vedi `docs/guardie.md`); il verde di GitHub sul commit di consegna e' scritto in coda al rapporto.
