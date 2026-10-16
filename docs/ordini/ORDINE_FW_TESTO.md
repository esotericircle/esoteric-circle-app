ORDINE FW, I VIDEO DI SCENA DEI TRE MAESTRI: DOMINI E CHAT
Esoteric Circle. Ramo claude/esoteric-circle-master-order-e798aj, nessun altro.
Testa vista dall'Architetto il 15 ottobre 2026 alle 11:55: a0dab57 (ordine FV
in corso, voce FVA.02 nel ramo). Questo ordine si esegue a ordine FV
consegnato, col verde di GitHub sul suo commit di consegna.

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
- Parole del fondatore del 14 e del 15 ottobre 2026, citate nelle voci.
- Linee Guida UX V13, sezione 28 (la scena in video).
- Gli ordini FS, FT e FU: il lettore e la regia comuni delle scene, il tocco
  che salta, la ricompressione dei video (FU voce FU.12), la misura dello
  scarto sull'ultimo fotogramma (FS voce A2).
- Le misure dell'Architetto sui sei video, riportate in P1.
I quattro V13 stanno in D:\Clienti Roogly\Rituali Cartomanzia\App\Briefing
Definitivi\V13. Le copie in docs/ del ramo sono ancora le vecchie: per questo
ordine valgono i V13.

======================================================================
LE PARTI DI QUESTO ORDINE
======================================================================
PARTE A, voci FW.01 e FW.02: gli asset nel ramo e il loro peso.
PARTE B, voci da FW.03 a FW.05: la scena del dominio, la scena della chat, i
due video di Caligo.
La consegna, voce FW.06, è unica per tutte le parti.

======================================================================
LA FUNZIONE IN UNA RIGA
======================================================================
Ogni Maestro accoglie la persona con un suo video di scena all'apertura del
proprio dominio e all'apertura della propria chat; il video si ferma
sull'ultimo fotogramma e un tocco lo fa sfumare; nella chat la figura sale
e scompare alla prima risposta. Fonte: il fondatore, 15 ottobre 2026, sul
video di scena per la home del dominio e per la chat di ogni Maestro, "per
coerenza".

======================================================================
PREMESSE DA ABBATTERE
======================================================================
Verificale tutte sulla testa del ramo prima di toccare il codice, ognuna col
suo comando. Una falsa ferma la voce che la usa, non l'ordine.
P1. Sul PC del fondatore, in D:\Clienti Roogly\Rituali Cartomanzia\App\,
    sei cartelle con i video e i loro fotogrammi. Tutti i video sono 1080
    per 1920, otto secondi, 24 fotogrammi al secondo, con traccia audio.
    Lo scarto medio misurato dall'Architetto tra l'ultimo fotogramma del
    video e l'immagine dell'ultimo fotogramma, in livelli su 255, sta tra
    parentesi.
    - Medora Dominio Scena\: medora_planetario_v1.mp4 (11,1 MB; scarto
      10,9), medora_planetario_primo_fotogramma_v1.jpg,
      medora_planetario_ultimo_fotogramma_v1.jpg, più planetario_sfondo_v1.jpg
      e medora_mano_tesa_v1.jpg, pezzi di lavoro.
    - Medora Chat Scena\: medora_l_invito_v1.mp4 (12,0 MB; scarto 12,6),
      medora_chat_primo_fotogramma_v1.jpg,
      medora_chat_ultimo_fotogramma_v1.jpg, più planetario_sfondo_v1.jpg e
      medora_luce_offerta_v1.jpg, pezzi di lavoro.
    - Caligo Dominio Scena\: caligo_la_runa_della_sera_v1.mp4 (9,8 MB;
      scarto 12,4), caligo_dominio_primo_fotogramma_v1.jpg,
      caligo_dominio_ultimo_fotogramma_v1.jpg, più biblioteca_sfondo_v1.jpg,
      biblioteca_rune_rosse_v1.jpg e caligo_fiamma_della_runa_v1.jpg, pezzi
      di lavoro.
    - Caligo Chat Scena\: caligo_il_vortice_v1.mp4 (11,1 MB; scarto 10,1),
      caligo_chat_primo_fotogramma_v1.jpg,
      caligo_chat_ultimo_fotogramma_v1.jpg.
    - Aura Dominio Scena\: aura_il_centro_di_oggi_v1.mp4 (5,4 MB; scarto
      5,9), aura_dominio_primo_fotogramma_v1.jpg,
      aura_dominio_ultimo_fotogramma_v1.jpg, più aura_santuario_v1.jpg, pezzo
      di lavoro.
    - Aura Chat Scena\: aura_il_respiro_sul_loto_v1.mp4 (5,5 MB; scarto
      6,3), aura_chat_primo_fotogramma_v1.jpg,
      aura_chat_ultimo_fotogramma_v1.jpg.
    I pezzi di lavoro restano fuori dal ramo.
P2. lib/features/scene/la_scena_in_video.dart porta il lettore e la regia
    comuni delle scene (LettoreDiScena) e il tocco che salta il video
    (IlToccoCheSalta), dall'ordine FU voce FU.15.
P3. lib/features/maestri/domain_screen.dart è la home del dominio di un
    Maestro: oggi il suo fondo è CosmosBackground, sopra stanno l'ingresso
    alla chat e i pilastri del dominio (widgets/domain_pillars.dart).
P4. lib/features/maestri/chat/maestro_chat_screen.dart apre la chat; prima
    del primo messaggio mostra ChatEmptyState
    (chat/widgets/chat_empty_state.dart) col busto del Maestro
    (widgets/busto_del_maestro.dart) e il suo benvenuto; alla prima risposta
    la figura del Maestro sale verso l'alto e scompare per fare spazio alla
    chat. Verifica dove vive oggi questo movimento e annotalo nel rapporto.
P5. lib/features/maestri/chat/chat_openers.dart: la chat può aprirsi già con
    una domanda scritta e inviata.
P6. La home generale dei tre Maestri (lib/features/maestri/maestro_screen.dart
    o chi la porta oggi) non ha video di scena.
P7. docs/ordini/ non contiene nessun file ORDINE_FW_*; CLAUDE.md porta la
    regola SPESE del 14 ottobre 2026 e la regola della suite su GitHub.

======================================================================
REGOLE FISSE
======================================================================
R1. Ogni voce porta la sua fonte. Le scelte di Code si scrivono nel
    rapporto con la ragione accanto.
R2. SPESE. Questo ordine non chiama Gemini né altri servizi a consumo, né
    durante l'ordine né quando gira. Nessun giro dei banchi.
R3. Nessuna build. Le build le ordina il fondatore. Nessuna pubblicazione
    delle funzioni sul server.
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
R8. I VIDEO E I FOTOGRAMMI SONO APPROVATI DAL FONDATORE. Nessun video si
    rigenera, si taglia nel contenuto o si ritocca nei colori; si
    ricomprime soltanto (voce FW.02). Nessuna figura del Maestro, alone o
    sfondo disegnati dal codice al posto dei fotogrammi. Fonte: il
    fondatore, 15 ottobre 2026, "La teniamo", "Tieni l'ultimo video e
    salvalo", "Tienilo, salvalo e andiamo avanti", "Salva".
R9. LE REGOLE DI OGNI SCENA, le stesse della Stesa, della Sinastria e
    dell'Oracolo: il video parte a ogni apertura, una volta per apertura,
    mai a ogni consultazione o a ogni messaggio; si ferma sull'ultimo
    fotogramma; un tocco in qualunque punto lo fa sfumare sulla scena ferma;
    con Riduci Movimento, con la grafica alleggerita o se il video non si
    carica, si vede solo l'ultimo fotogramma; l'audio suona solo con
    l'interruttore del suono acceso e il telefono non in silenzioso, senza
    prendere il fuoco audio. Fonte: il fondatore, 14 ottobre 2026: "No, si
    ripete sempre il video, ma si può sfumare saltare con un click"; 15
    ottobre 2026: "parte all'apertura della funzionalità e basta"; P2.
R10. Il giro dell'utente prima di chiudere una voce: apri ogni dominio e
    ogni chat dei tre Maestri come una persona, anche due volte di fila; poi confrontali con la Stesa di Tarocchi e con l'Oracolo degli Angeli,
    dichiarando ogni differenza. Migliorie ed effetti wow li proponi nel
    rapporto, senza costruirli.
R11. Restano com'erano: la home generale dei tre Maestri, senza video
    (il fondatore: "nella home generale dei tre Maestri non si può mettere
    un video"; P6); le arti dei domini e le loro scene; il contenuto, le
    risposte e il comportamento della chat oltre a ciò che scrive la voce
    FW.04.
R12. Il manifesto docs/ordini/ORDINE_FW_MANIFESTO.md coi quattro marcatori,
    la sua guardia, il rapporto e STATO_VIVO.

======================================================================
FW.01 GLI ASSET NEL RAMO
======================================================================
Fonte: il fondatore, 15 ottobre 2026, sui sei video tenuti (R8); P1.
- Copia nel ramo i sei video e i loro dodici fotogrammi di P1 (i pezzi di
  lavoro restano fuori): i video ricompressi (voce FW.02) in
  brand_assets/maestri_scena/, i fotogrammi in assets/img/maestri_scena/
  convertiti in webp. Dichiarali in pubspec.yaml (i video con la loro
  impronta, come nell'ordine FS) e in docs/stato_asset.json.
- I nomi nel ramo dicono il posto in cui ciascun video vive nell'app e non
  la cartella da cui viene: i due video di Caligo seguono la voce FW.05.
  Scrivi nel rapporto la tabella cartella di origine, nome nel ramo, posto
  nell'app.

======================================================================
FW.02 IL PESO
======================================================================
Fonte: il fondatore, 14 ottobre 2026, sul timore che il peso dei video sia
eccessivo e sulla richiesta di ottimizzarli; FU voce FU.12.
- Ogni video si ricomprime col metodo dell'ordine FU voce FU.12 prima di
  entrare nel ramo. Nel rapporto, per ognuno: peso prima e dopo, una cattura
  dello stesso fotogramma prima e dopo, la misura dello scarto fra i due.
- L'audio resta solo se la scena lo suona (Linee Guida sezione 28, R9).
- Misura lo scarto fra l'ultimo fotogramma del video ricompresso e il suo
  fotogramma ferma come in FS voce A2; confrontalo con quello di P1.
- Dichiara nel rapporto il peso totale che i sei video aggiungono
  all'installazione.

======================================================================
FW.03 LA SCENA DEL DOMINIO
======================================================================
Fonte: il fondatore, 15 ottobre 2026: "La home dei domini, non la Home dei
tre maestri"; sul video di scena per la home del dominio di ogni Maestro,
"per coerenza"; R9; P2, P3.
- All'apertura del dominio di ogni Maestro parte il suo video, dal lettore e
  dalla regia comuni di P2:
  - Medora: medora_planetario_v1.mp4, ultimo fotogramma
    medora_planetario_ultimo_fotogramma_v1;
  - Caligo: caligo_il_vortice_v1.mp4, ultimo fotogramma
    caligo_chat_ultimo_fotogramma_v1 (voce FW.05);
  - Aura: aura_il_centro_di_oggi_v1.mp4, ultimo fotogramma
    aura_dominio_ultimo_fotogramma_v1.
- L'ultimo fotogramma resta come fondo fisso del dominio al posto di
  CosmosBackground. L'ingresso alla chat e i pilastri restano sopra,
  leggibili: misura il contrasto del testo sul fondo nuovo e, se serve, posa
  un velo come nelle altre scene. Il viso del Maestro non si copre.
- Il tocco che salta il video passa dal punto unico di P2 e non apre per
  sbaglio un pilastro o la chat.
- Tornando al dominio da una sua arte o dalla chat il video riparte solo se
  l'app lo tratta come una nuova apertura del dominio: scegli, scrivi la
  scelta nel rapporto con la ragione e tienila uguale per i tre Maestri.

======================================================================
FW.04 LA SCENA DELLA CHAT
======================================================================
Fonte: il fondatore, 15 ottobre 2026: "Ha poco senso 3 cicli per le chat.
Già alla prima risposta la figura del maestro sale verso l'alto e scompare
per fare spazio alla Chat"; R9; P2, P4, P5.
- All'apertura della chat di ogni Maestro, prima del primo messaggio, parte
  il suo video al posto della figura ferma di P4:
  - Medora: medora_l_invito_v1.mp4, ultimo fotogramma
    medora_chat_ultimo_fotogramma_v1;
  - Caligo: caligo_la_runa_della_sera_v1.mp4, ultimo fotogramma
    caligo_dominio_ultimo_fotogramma_v1 (voce FW.05);
  - Aura: aura_il_respiro_sul_loto_v1.mp4, ultimo fotogramma
    aura_chat_ultimo_fotogramma_v1.
- Un ciclo solo: il video si ferma sull'ultimo fotogramma, che resta con il
  benvenuto finché arriva la prima risposta. Alla prima risposta la scena
  sale verso l'alto e scompare come fa oggi la figura, con lo stesso
  movimento e lo stesso tempo.
- Se la prima risposta arriva mentre il video gira (P5), il video sfuma
  sull'ultimo fotogramma e poi la scena sale: la risposta non aspetta la
  fine del video.
- Una chat riaperta con una conversazione già in corso si comporta come oggi
  la figura: scrivi nel rapporto cosa fa e perché.
- Il benvenuto resta leggibile sopra la scena: misura il contrasto come in
  FW.03.

======================================================================
FW.05 I DUE VIDEO DI CALIGO
======================================================================
Fonte: il fondatore, 15 ottobre 2026: "l'ultimo video di Caligo dove lo
avvolge il fuoco, io lo userei per il suo dominio essendo di forte impatto e
l'altro per la chat".
- Le cartelle del PC portano i nomi di prima dello scambio: il video del
  vortice di fuoco (caligo_il_vortice_v1.mp4) sta in Caligo Chat Scena\ ma va
  nel DOMINIO, col fotogramma caligo_chat_ultimo_fotogramma_v1; il video del
  cerchio di fuoco sul tavolo (caligo_la_runa_della_sera_v1.mp4) sta in
  Caligo Dominio Scena\ ma va nella CHAT, col fotogramma
  caligo_dominio_ultimo_fotogramma_v1.
- Prima di collegarli, verifica la coppia video e fotogramma misurando lo
  scarto: il fotogramma giusto è quello con lo scarto di P1, l'altro dà uno
  scarto molto più alto.
- Una prova lega ogni video del ramo al suo fotogramma e al suo posto
  nell'app, per i tre Maestri: cade se una coppia si scambia.

======================================================================
FW.06 LA CONSEGNA
======================================================================
Fonte: regole fisse R3, R6, R12.
- Manifesto, guardia del manifesto, rapporto, STATO_VIVO e registro delle
  guardie aggiornati. Anteprime prima e dopo a 360 per 797, densità 3, in
  docs/preview/FW/, guardate prima di chiuderle: per ogni Maestro il dominio
  sulla scena ferma e la chat sulla scena ferma col benvenuto.
- In locale girano solo le prove della voce e le guardie della zona
  toccata; la suite intera la fa il cancello di GitHub a ogni push, come
  vuole la regola di CLAUDE.md del 14 ottobre 2026. L'ordine si consegna
  solo col verde di GitHub sul commit consegnato. Nessun rosso si consegna.
- Nessuna build. Le voci che si vedono solo sul telefono (il video che
  gira, il tocco, la salita della scena alla prima risposta) restano APERTE
  IN ATTESA DI VERIFICA: il fondatore ordina la build quando vuole
  guardarle.

FORMATO DEL RAPPORTO
Prime righe: le premesse cadute, con il comando che le ha fatte cadere. Poi
voce per voce DOMANDA, PROVA, MISURA. Poi le scelte di Code con la ragione:
la tabella dei sei video (cartella di origine, nome nel ramo, posto
nell'app), i pesi prima e dopo e il totale, gli scarti misurati, il velo e i
contrasti, il ritorno al dominio, la chat riaperta. In fondo le migliorie e
gli effetti wow proposti, senza costruirli.
