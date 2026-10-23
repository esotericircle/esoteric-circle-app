ORDINE FX, IL RESPIRO DELLA LUNA
Esoteric Circle. Ramo claude/esoteric-circle-master-order-e798aj, nessun altro.
Testa vista dall'Architetto il 15 ottobre 2026 alle 15:20: becf304 (ordine FV
consegnato, verde di GitHub sul commit 22c57e58). Questo ordine si esegue a
ordine FW consegnato, col verde di GitHub sul suo commit di consegna.

Leggi l'ordine per intero, dalla prima all'ultima voce, prima di scrivere
codice.

CODE PORTA A TERMINE TUTTO L'ORDINE, OGNI VOCE, FINO ALLA CONSEGNA. Non si
ferma a metà, non rimanda voci, non lascia lavoro da ordinare di nuovo. Se il
contesto si stringe, comprime i rapporti e non il lavoro. L'unica fermata
ammessa è una premessa falsa.

REGOLA ZERO. Verifica tutto sul ramo, anche ciò che l'ordine dà per certo.
REGOLA UNO. Code non si ferma, risolve. Chi decide: 1 Code, 2 agenti e
subagenti, 3 l'Architetto per ultimo.

======================================================================
FONTI DI QUESTO ORDINE
======================================================================
- Parole del fondatore del 15 ottobre 2026, citate nelle voci.
- Briefing Progetto Definitivo V13, sezione 38 (Lunologia: Il Respiro della
  Luna), ridefinita in questo ordine dalla proposta approvata (voce FX.00).
- Master Briefing Tecnico V13, sezioni 41 e 43 (dati lunari dal motore,
  Luna fuori corso, nessun carico per il modello).
- Linee Guida UX V13, sezioni 3 (la card condivisibile), 26, 27 e 28.
- La proposta dell'Architetto del 15 ottobre 2026 approvata dal fondatore,
  riportata nelle voci.
- L'ordine FV consegnato: il motore lunare, le lune della NASA, il
  Calendario Lunare, i piani del lunario.
- Il Dial-A-Moon e la serie "Moon Phase and Libration, 2026" dello
  Scientific Visualization Studio della NASA (https://svs.gsfc.nasa.gov/5587/)
  e le linee guida della NASA sull'uso delle immagini
  (https://nasa.gov/nasa-brand-center/images-and-media).
I quattro V13 stanno in D:\Clienti Roogly\Rituali Cartomanzia\App\Briefing
Definitivi\V13. Le copie in docs/ del ramo sono ancora le vecchie: per questo
ordine valgono i V13.

======================================================================
LE PARTI DI QUESTO ORDINE
======================================================================
PARTE A, voci da FX.00 a FX.03: l'idea, gli asset, la scena, la Luna di
quest'ora.
PARTE B, voci da FX.04 a FX.08: il respiro, la collana delle lune, dov'è la
Luna adesso, la parola di Medora, gli avvisi.
PARTE C, voci da FX.09 a FX.11: Respiriamo insieme, i piani e gli Eos, la
porta.
La consegna, voce FX.12, è unica per tutte le parti.

======================================================================
LA FUNZIONE IN UNA RIGA
======================================================================
Il Respiro della Luna è l'appuntamento di ogni giorno con la Luna vera di
quest'ora sopra la città della persona: un minuto di respiro accordato alla
fase, una perla al giorno nella collana delle lune; alla Luna nuova Medora
consegna la collana del ciclo. Fonte: il fondatore, 15 ottobre 2026: "deve
stupire i fondatori e colpire l'utente tanto da farlo tornare ogni giorno.
Usiamo nano banana, video e tutto ciò che serve per una funzionalità
esclusiva e d'impatto"; sulla proposta: "Approvato".

======================================================================
PREMESSE DA ABBATTERE
======================================================================
Verificale tutte sulla testa del ramo prima di toccare il codice, ognuna col
suo comando. Una falsa ferma la voce che la usa, non l'ordine.
P1. La cartella D:\Clienti Roogly\Rituali Cartomanzia\App\Respiro della Luna
    Scena\ contiene:
    - medora_il_respiro_della_luna_v1.mp4 (1080 per 1920, otto secondi, 24
      fotogrammi al secondo, 7,1 MB, con traccia audio). L'Architetto ha
      tolto dal video dei nastri d'argento comparsi fra il terzo e il sesto
      secondo; lo scarto medio fra l'ultimo fotogramma del video e
      respiro_ultimo_fotogramma_v1 è 6,8 livelli su 255;
    - respiro_primo_fotogramma_v1.jpg (Luna velata),
      respiro_ultimo_fotogramma_v1.jpg (Luna piena dipinta),
      respiro_cielo_senza_luna_v1.jpg (la stessa scena senza la Luna), tutti
      1080 per 1920. Sull'ultimo fotogramma l'Architetto ha misurato il disco
      della Luna dipinta: centro a x 540, y 378, raggio circa 250 pixel;
    - Collana\: perla_finestra_v1.png (il centro scuro dove va la Luna vera),
      perla_spenta_v1.png, perla_accesa_v1.png, fermaglio_falce_v1.png,
      catenella_v1.png, medaglia_luna_piena_v1.png, scrigno_collana_v1.png,
      tutti su fondo trasparente;
    - Bussola\: quadrante_bussola_v1.png (centro blu scuro vuoto),
      ago_falce_v1.png (punta verso l'alto), scia_di_luna_v1.png (luce
      d'argento su fondo trasparente), tutti su fondo trasparente;
    - Consegna\: medora_la_consegna_della_collana_v1.mp4 (1080 per 1920, otto
      secondi, 24 fotogrammi al secondo, 5,2 MB, con traccia audio; scarto
      sull'ultimo fotogramma 6,6), consegna_primo_fotogramma_v1.jpg,
      consegna_ultimo_fotogramma_v1.jpg;
    - Lavoro\: gli originali di Nano Banana, il video grezzo di Veo, i fogli
      dei pezzi e cattura_dora_app_luna_v1.jpg. Restano fuori dal ramo,
      tranne la cattura (voce FX.01).
P2. lib/core/lunario/il_motore_lunare.dart (IlMotoreLunare) e
    lib/core/lunario/il_giorno_lunare.dart (GiornoLunare, CambioDiSegno,
    IntervalloFuoriCorso) sono il motore lunare in un punto solo
    dell'ordine FV voce FV.04.
P3. lib/core/lunario/le_lune_della_nasa.dart e le_lune_della_nasa.g.dart
    portano le trenta lune vere della serie SVS 5587 in
    assets/img/calendario_lunare/lune/, scelte per elongazione; la fonte è
    già citata in lib/core/legal/fonti_dei_dati.dart.
P4. lib/core/arts/art_catalog.dart porta la voce lunology, titolo "Il
    Respiro della Luna", ArtState.inArrivo, ArtPhase.mvp, con un testo della
    scheda che descrive ancora la versione del Briefing V13 sezione 38.
P5. lib/services/breath_detector.dart coglie il soffio col microfono per il
    Soffio del Destino (lib/features/rituals/breath_destiny_screen.dart); il
    permesso del microfono è dichiarato su Android e iOS e il testo di iOS
    nomina il Soffio del Destino.
P6. lib/core/motion/l_orientamento_del_telefono.dart legge la bussola del
    telefono (magnetometro) e l'inclinazione da sensors_plus.
P7. lib/core/astro/luogo_attuale.dart dà il luogo della persona con
    latitudine e longitudine.
P8. lib/services/avvisi_locali.dart è il punto degli avvisi del telefono.
P9. lib/core/entitlement/tier.dart: free, tier1, tier2, tier3. Il fondatore
    chiama Viandante il free e Iniziato il tier1.
P10. lib/features/scene/la_scena_in_video.dart porta il lettore e la regia
    comuni delle scene e il tocco che salta (IlToccoCheSalta).
P11. lib/core/cerchio/il_cerchio_sociale.dart e
    functions/src/il_cerchio_sociale.ts portano gli amici del Cerchio.
P12. docs/ordini/ non contiene nessun file ORDINE_FX_*; CLAUDE.md porta la
    regola SPESE del 14 ottobre 2026 e la regola della suite su GitHub.

======================================================================
REGOLE FISSE
======================================================================
R1. Ogni voce porta la sua fonte. Le scelte di Code si scrivono nel
    rapporto con la ragione accanto.
R2. SPESE. Questa funzione non chiama Gemini né altri servizi a consumo, né
    durante l'ordine né quando gira: calcolo sul telefono, corpus scritto da
    Code, immagini della NASA. Nessun giro dei banchi.
R3. Nessuna build. Le build le ordina il fondatore. Nessuna pubblicazione
    delle funzioni sul server: il lavoro sul server si scrive, si prova e
    non si pubblica; il comando per pubblicarlo va nel rapporto.
R4. Niente dati di produzione, nemmeno sul telefono di collaudo. Nessuna
    credenziale chiesta in chat.
R5. Le Regole A e B delle guardie: ogni prova nuova vista rossa con
    l'innesto verificato prima di leggere l'esito; la zona toccata vista
    rossa prima di toccarla. Quando il rosso non scatta si cambia la
    grandezza misurata, mai la soglia.
R6. Ogni voce chiusa porta DOMANDA, PROVA, MISURA. Ogni affermazione visiva
    è una cattura o una misura. Una voce che si vede solo sul telefono resta
    APERTA IN ATTESA DI VERIFICA.
R7. Lingua: italiano con gli accenti veri, mai il trattino lungo, mai la
    virgola prima di "e" o di "ed", il tu, la marca del genere a tre vie dove
    il testo parla di chi legge.
R8. LA REGOLA DI CASA SUI TESTI. Ogni testo, scritto da Code, sta nella voce
    di Medora e segue queste regole:
    - niente salute: il respiro è un rito, mai una terapia, un esercizio
      medico o una cura dell'ansia; nessuna promessa sul corpo o sul sonno;
    - niente soldi e investimenti;
    - nessuna promessa di esito: la Luna indica il momento, non garantisce
      il risultato;
    - ciò che viene da una tradizione si cita con la sua fonte; ciò che non
      è documentato si dice chiave di Medora, mai tradizione;
    - il disclaimer di casa, come nelle altre arti.
R9. LA GRAFICA È DIPINTA, NON DISEGNATA. Fonte: il fondatore, 15 ottobre
    2026: "Usiamo nano banana, video e tutto ciò che serve". Scena, perle,
    fermaglio, catenella, medaglia, scrigno, quadrante, ago e scia sono gli
    asset di P1; le Lune sono le foto della NASA. Flutter disegna solo
    testo, posizioni, dissolvenze, opacità, rotazioni e movimenti di quegli
    asset. Nessuna Luna, perla, cornice, bussola o icona disegnata dal codice
    al loro posto. Guardia: rossa se un widget di questa funzione disegna una
    Luna, un cerchio decorativo o un'icona di Material al posto di un asset.
R10. Il giro dell'utente prima di chiudere una voce: percorri la funzione
    come una persona, il primo giorno e il secondo; poi confrontala col
    Calendario Lunare e con l'Oracolo degli Angeli, dichiarando ogni
    differenza. Migliorie ed effetti wow li proponi nel rapporto, senza
    costruirli.
R11. Restano com'erano: il Calendario Lunare (di lui cambia solo il
    collegamento della voce FX.11), il Calendario degli Eventi, l'Affinità
    Lunare, il Soffio del Destino (il rilevatore del soffio si riusa, il suo
    comportamento non cambia), l'Oroscopo e il Cerchio. Il motore lunare di
    FV non si duplica: si estende dove serve.
R12. Il manifesto docs/ordini/ORDINE_FX_MANIFESTO.md coi quattro marcatori,
    la sua guardia, il rapporto e STATO_VIVO.

======================================================================
FX.00 L'IDEA, CHE SOSTITUISCE LA SEZIONE 38 DEL BRIEFING
======================================================================
Fonte: la proposta dell'Architetto del 15 ottobre 2026, approvata dal
fondatore ("Approvato"); il fondatore: "Avevamo lasciato il respiro della
Luna indietro giusto? Per una retention giornaliera?".
- Il Calendario Lunare serve a scegliere un giorno nel mese; il Respiro
  della Luna è l'appuntamento con la Luna di adesso, ogni giorno, in un
  minuto. Il calendario biodinamico e i consigli per categoria della
  sezione 38 vivono già nel Calendario Lunare ("Trova il giorno") e qui non
  si ripetono: il Respiro porta alla porta del Calendario (voce FX.11).
- Scrivi nel rapporto la differenza fra le due arti in tre righe, come la
  leggerà chi apre l'app.

======================================================================
FX.01 GLI ASSET NEL RAMO
======================================================================
Fonte: il fondatore, 15 ottobre 2026, sul video della scena: "Si salva"; sul
video della consegna: "Va bene questo per ora"; sugli asset, la proposta
approvata; P1.
- Copia nel ramo i file di P1 fuori da Lavoro\: le immagini in
  assets/img/respiro_della_luna/ (webp, mantenendo la trasparenza dei png),
  i due video ricompressi col metodo dell'ordine FU voce FU.12 in
  brand_assets/respiro_della_luna/. Dichiarali in pubspec.yaml (i video con
  la loro impronta, come nell'ordine FS) e in docs/stato_asset.json. Peso
  prima e dopo, una cattura dello stesso fotogramma prima e dopo, lo scarto
  sull'ultimo fotogramma come in FS voce A2.
- Nessun asset si rigenera o si ritocca nei colori.
- La scia di luna si posa in fusione schermo o con la sua trasparenza:
  misura su una cattura che non lasci un riquadro visibile.
- La cattura che il fondatore ha ricevuto da Dora,
  Lavoro\cattura_dora_app_luna_v1.jpg, entra in
  docs/collaudo/FX/catture_fondatore/ e si cita nel rapporto: è un'app di
  servizio sulla Luna, da cui si prendono i dati (percentuale di luce,
  sorgere, tramonto e culminazione col conto alla rovescia, distanza, tempo
  da scorrere, bussola), mai l'aspetto.

======================================================================
FX.02 LA SCENA
======================================================================
Fonte: Linee Guida V13 sezione 28; il fondatore, 14 ottobre 2026: "No, si
ripete sempre il video, ma si può sfumare saltare con un click"; 15 ottobre
2026: "parte all'apertura della funzionalità e basta"; P1, P10.
- All'apertura del Respiro parte medora_il_respiro_della_luna_v1.mp4, una
  volta per apertura, dal lettore e dalla regia comuni di P10: Medora
  respira sulla terrazza e la Luna velata si svela fino a piena.
- Sull'ultimo fotogramma la Luna dipinta lascia il posto alla Luna vera
  della voce FX.03: in dissolvenza il fondo diventa
  respiro_cielo_senza_luna_v1 e sopra, nel posto e nella misura del disco
  dipinto (P1, rimisuralo), compare la foto della NASA nella fase di
  adesso. Misura su una cattura che il passaggio non salti di posizione né
  di misura.
- Con Riduci Movimento, con la grafica alleggerita o se il video non si
  carica: scena ferma su respiro_cielo_senza_luna_v1 con la Luna vera.
  Audio e tocco che salta come nelle altre scene.

======================================================================
FX.03 LA LUNA DI QUEST'ORA
======================================================================
Fonte: la proposta approvata; la cattura di Dora (FX.01); Briefing V13
sezione 38 (la fase con la percentuale reale, la grande Luna che si può
ruotare); P2, P3, P7.
- LA FOTO VERA, ORA PER ORA. La Luna al centro è la foto della serie SVS
  dell'anno (una per ogni ora, con la fase e la librazione vere), presa dal
  Dial-A-Moon della NASA per l'ora in corso. Verifica sulla pagina dello
  SVS l'indirizzo, il formato e le condizioni d'uso alla data dell'ordine e
  citale nel rapporto. Senza rete o se la NASA non risponde, la foto è
  quella delle trenta lune locali di P3 più vicina per elongazione: la
  funzione non resta mai senza Luna. La Luna ruota di 180 gradi per chi sta
  nell'emisfero sud, come nel Calendario. Le regole della NASA sono quelle
  dell'ordine FV voce FV.03: la citazione già presente, nessun logo, nessuna
  frase che lasci intendere un'approvazione, la NASA mai nominata nei testi
  di Medora.
- SOTTO LA LUNA, dal motore di P2 per il luogo di P7: la percentuale di
  luce; il sorgere, il tramonto e la culminazione della Luna con il conto
  alla rovescia ("sorge tra 32 minuti"); la distanza dalla Terra in
  chilometri, con l'avviso di Superluna quando la Luna piena cade vicino al
  perigeo (dichiara nel rapporto la soglia scelta e la sua fonte); quanto
  manca alla prossima Luna piena e alla prossima nuova. Se il motore di FV
  non calcola sorgere, tramonto, culminazione o distanza, lo si estende lì, nel punto solo; poi si prova contro effemeridi pubblicate con lo scarto
  massimo in minuti e in chilometri dichiarato.
- IL TEMPO SOTTO IL DITO. Trascinando il dito in orizzontale il tempo
  scorre avanti e indietro: la Luna cambia fase e foto sotto il dito, i
  numeri si aggiornano, uno scatto della vibrazione segna il passaggio da
  una fase principale all'altra. Un tocco riporta ad adesso. Fino a dove si
  scorre dipende dal piano (voce FX.10).
- La Luna risponde al tocco con una piccola rotazione e un respiro di luce,
  come chiede la sezione 38 ("si può ruotare"), sempre con la foto vera.

======================================================================
FX.04 IL RESPIRO
======================================================================
Fonte: la proposta approvata ("Un minuto di respiro guidato accordato alla
fase: con la Luna crescente l'inspiro è più lungo, con la calante l'espiro";
"il microfono sente il soffio, ripiego tattile"); le regole del progetto sui
sensori col ripiego tattile; P5.
- Un minuto di respiro guidato. La Luna si accende con l'inspiro e si
  vela con l'espiro; un anello di luce, fatto con la perla accesa o la scia
  di P1, accompagna il ritmo. Con la Luna crescente l'inspiro dura più
  dell'espiro, con la calante il contrario, alla Luna piena e alla nuova
  sono pari: scrivi i tempi scelti nel rapporto.
- Il soffio si coglie col rilevatore di P5, riusato senza cambiarne il
  comportamento per il Soffio del Destino. Ripiego tattile sempre presente
  e sempre attivo: si tiene premuto per inspirare e si lascia per espirare.
  Il testo del permesso del microfono su iOS si aggiorna perché nomini anche
  il Respiro della Luna; l'app non registra e non conserva audio.
- È CHIAVE DI MEDORA. Il respiro accordato alla fase non viene da nessuna
  tradizione documentata: nei testi si dice chiave di Medora, mai
  tradizione (R8). Disclaimer di casa sotto il rito.
- Il respiro di oggi si compie una volta al giorno: a rito finito si
  accende la perla del giorno (voce FX.05). Si può rifare quante volte si
  vuole, la perla resta una.

======================================================================
FX.05 LA COLLANA DELLE LUNE
======================================================================
Fonte: la proposta approvata ("Ogni giorno respirato aggiunge alla tua
collana una perla dipinta con la fase vera di quel giorno. Una lunazione è
di 29 o 30 perle. Il giorno saltato resta una perla scura, senza punizioni.
A collana completa, alla Luna nuova, Medora te la consegna con un video
breve e ne comincia una nuova. La collana del mese è la card da
condividere"); sul prezzo della perla ricucita: il fondatore, 15 ottobre
2026: "lo decide code"; P1, P3.
- La collana segue la lunazione vera, da Luna nuova a Luna nuova, dal
  motore di P2: 29 o 30 perle secondo il ciclo in corso.
- Ogni giorno respirato: perla_finestra con dentro la Luna vera di quel giorno (P3); per un attimo perla_accesa quando entra. Ogni giorno
  saltato: perla_spenta. Nessun testo di rimprovero, nessuna striscia persa.
- Le perle stanno sulla catenella, chiusa dal fermaglio_falce; a collana
  completa si aggiunge la medaglia_luna_piena.
- ALLA LUNA NUOVA, alla prima apertura dopo l'istante della Luna nuova,
  parte medora_la_consegna_della_collana_v1.mp4 una volta sola per ciclo:
  Medora apre lo scrigno; poi lo scrigno_collana con la collana vera della
  persona, perla per perla; poi comincia la collana nuova. Le regole della
  scena come in FX.02, col tocco che salta. Se la persona non ha respirato
  nessun giorno del ciclo, la consegna non parte.
- RICUCIRE UNA PERLA. Una perla spenta degli ultimi giorni del ciclo in
  corso si può ricucire con gli Eos. Il prezzo, quante perle per ciclo e
  fino a quanti giorni indietro li decide Code e li scrive nel rapporto con
  la ragione, guardando il listino del lunario di FV.
- LA CARD DELLA COLLANA. La collana del ciclo diventa la card condivisibile
  delle Linee Guida V13 sezione 3, sullo scrigno, col nome del ciclo e il
  numero di perle accese; il passaggio di condivisione è quello delle altre
  card dell'app.
- Le collane passate restano in un piccolo scrigno delle collane, una per
  ciclo.

======================================================================
FX.06 DOV'È LA LUNA ADESSO
======================================================================
Fonte: la proposta approvata ("alzi il telefono e una scia d'argento ti
guida verso la Luna nel cielo vero. Se è sopra l'orizzonte: Esci, è lì");
la cattura di Dora (la bussola); P1, P2, P6, P7.
- Il quadrante_bussola con l'ago_falce: l'ago punta verso l'azimut della
  Luna adesso, dal motore di P2 per il luogo di P7, letto con la bussola e
  l'inclinazione di P6. La scia_di_luna sale dal centro verso la direzione e
  l'altezza della Luna; quando il telefono punta la Luna, una vibrazione
  breve e la Luna vera al centro del quadrante.
- Se la Luna è sopra l'orizzonte, Medora dice di uscire a guardarla; se è
  sotto, dice quando sorge.
- Ripiego senza bussola o con la bussola da tarare: la direzione e
  l'altezza scritte ("a sud-est, alta 32 gradi") e l'invito a tarare.
- Prova l'azimut e l'altezza contro effemeridi pubblicate per tre città e
  dichiara lo scarto massimo in gradi.

======================================================================
FX.07 LA PAROLA DI MEDORA
======================================================================
Fonte: la proposta approvata ("Tre righe di oggi: la Luna nel segno, il
giorno lunare e la Luna fuori corso in tempo reale"); Briefing V13 sezione
38; Master V13 sezioni 41 e 43; P2.
- Tre righe al giorno nella voce di Medora: la Luna nel segno e l'ora in
  cui cambia; la Luna fuori corso in tempo reale, con l'ora di fine ("fino
  alle 16:42 la Luna è fuori corso"); il giorno lunare. Testi dal corpus
  scritto da Code, nessuna chiamata al modello (R2).
- LA LUNA FUORI CORSO viene dalla tradizione astrologica: cita la fonte
  documentata che il motore di FV già usa. Il consiglio pratico che
  l'accompagna sta nei confini di R8.
- I TRENTA GIORNI LUNARI della sezione 38 entrano solo se il loro sistema
  di simboli e significati è documentato su fonti citate; altrimenti non si
  mostrano e il rapporto dice perché, con le fonti cercate. Lo stesso vale
  per il giorno lunare già calcolato da FV.

======================================================================
FX.08 GLI AVVISI
======================================================================
Fonte: la proposta approvata ("La Luna sorge adesso a Piacenza; ogni giorno
l'orario cambia. Poi la Luna piena, la nuova, la Superluna"); P8.
- Avvisi locali dal punto di P8, ognuno attivabile e disattivabile: la Luna
  che sorge nel luogo della persona; la Luna piena e la Luna nuova
  all'istante esatto; la Superluna. Il testo dell'avviso nomina la città
  ("La Luna sorge adesso a Piacenza").
- Nessun avviso di notte fonda: scrivi nel rapporto la fascia oraria scelta
  e come si comporta un sorgere che cade fuori fascia.

======================================================================
FX.09 RESPIRIAMO INSIEME
======================================================================
Fonte: la proposta approvata ("Alla Luna piena, all'ora esatta, un rito
collettivo di un minuto: vedi quante persone stanno respirando con te in
quel momento e quali amici del Cerchio. Puoi invitare un amico a completare
la collana insieme"; "la collana a due si completa solo se respirate tutti e
due"); P11.
- All'istante della Luna piena si apre, per un'ora, il respiro collettivo:
  lo stesso minuto della voce FX.04, con il numero di persone che stanno
  respirando in quel momento in tutta l'app e i nomi degli amici del
  Cerchio fra loro. Il conteggio passa dal server, senza dati personali
  oltre a quelli che il Cerchio già mostra.
- LA COLLANA A DUE. Una persona invita un amico del Cerchio: per il ciclo
  in corso nasce una collana comune, la cui perla del giorno si accende solo
  se respirano tutti e due. La card della collana a due porta i due nomi.
- Il server si scrive e si prova, non si pubblica (R3): i comandi nel
  rapporto.

======================================================================
FX.10 I PIANI E GLI EOS
======================================================================
Fonte: il fondatore, 15 ottobre 2026, sulla tabella proposta: "1 ok"; sul
prezzo in Eos: "lo decide code"; il fondatore, 8 ottobre 2026, sul tier 2
che non si distingue abbastanza e su qualche funzionalità esclusiva di tier
2 e tier 3; P9.
- Viandante (free): la Luna di quest'ora coi suoi numeri, il respiro di
  oggi, la parola di Medora, la perla del giorno. Il tempo sotto il dito
  scorre solo nelle 24 ore di oggi.
- Iniziato (tier1): la collana completa con la consegna alla Luna nuova e lo
  scrigno delle collane, gli avvisi, il tempo sotto il dito su tutto il
  mese.
- Tier 2 e tier 3: in più Respiriamo insieme con la collana a due e la
  bussola verso la Luna. È un'esclusiva di questi piani.
- Ciò che un piano non ha si vede col lucchetto e la sua porta verso il
  piano giusto, come nel lunario di FV. Il listino degli Eos (la perla
  ricucita e ogni giro in più) lo decide Code nel rapporto, coerente col
  listino del lunario.

======================================================================
FX.11 LA PORTA
======================================================================
Fonte: il fondatore, 15 ottobre 2026, sui due calendari: "Separati e
collegati"; P4.
- Il Respiro della Luna esce dal Coming soon: in art_catalog.dart diventa
  ArtState.attiva, ArtPhase.mvp resta. Il testo della scheda si riscrive
  perché dica il vero di ciò che la funzione fa oggi.
- La porta sta nel dominio di Medora, nella sezione Lunologia.
- Il Respiro e il Calendario Lunare restano due arti separate e collegate:
  dal Respiro una porta "Trova il giorno nel mese" apre il Calendario; dal
  Calendario una porta apre il Respiro di oggi.

======================================================================
FX.12 LA CONSEGNA
======================================================================
Fonte: regole fisse R3, R6, R12.
- Manifesto, guardia del manifesto, rapporto, STATO_VIVO e registro delle
  guardie aggiornati. Anteprime prima e dopo a 360 per 797, densità 3, in
  docs/preview/FX/, guardate prima di chiuderle: la scena ferma con la Luna
  vera, il respiro, la collana a metà ciclo, lo scrigno della consegna, la
  bussola, la card della collana.
- In locale girano solo le prove della voce e le guardie della zona
  toccata; la suite intera la fa il cancello di GitHub a ogni push, come
  vuole la regola di CLAUDE.md del 14 ottobre 2026. L'ordine si consegna
  solo col verde di GitHub sul commit consegnato. Nessun rosso si consegna.
- Nessuna build. Le voci che si vedono solo sul telefono (i video, il
  soffio, la bussola, la vibrazione, gli avvisi) restano APERTE IN ATTESA DI
  VERIFICA: il fondatore ordina la build quando vuole guardarle.

FORMATO DEL RAPPORTO
Prime righe: le premesse cadute, con il comando che le ha fatte cadere. Poi
voce per voce DOMANDA, PROVA, MISURA. Poi le scelte di Code con la ragione:
l'indirizzo e le condizioni del Dial-A-Moon, gli scarti del motore esteso
(sorgere, tramonto, culminazione, distanza, azimut e altezza), la soglia
della Superluna con la fonte, i tempi del respiro per fase, la fascia oraria
degli avvisi, il listino degli Eos, le fonti cercate per i trenta giorni
lunari e la decisione presa. Poi i comandi per pubblicare il lavoro sul
server. In fondo le migliorie e gli effetti wow proposti, senza costruirli.
