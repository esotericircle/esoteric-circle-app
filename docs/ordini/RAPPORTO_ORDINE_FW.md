# RAPPORTO DELL'ORDINE FW, I VIDEO DI SCENA DEI TRE MAESTRI: DOMINI E CHAT

15 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_FW_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FW_MANIFESTO.md`, 6 voci: 4 chiuse, 2 aperte in attesa di verifica, 0 da fare. Ramo `claude/esoteric-circle-master-order-e798aj`, eseguito a ordine FV consegnato. Nessuna build, nessuna chiamata a pagamento, nessun dato di produzione toccato (R2, R3, R4).

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FW.01, gli asset nel ramo | `docs/collaudo/FW/fw01_asset.txt` |
| FW.02, il peso | `docs/collaudo/FW/fw01_asset.txt` |
| FW.05, i due video di Caligo | `docs/collaudo/FW/fw05_regola_a.txt` |
| FW.06, la consegna | `docs/ordini/RAPPORTO_ORDINE_FW.md` |

## LE VOCI APERTE E CHE COSA ASPETTANO

| voce | che cosa e' fatto | che cosa aspetta |
|---|---|---|
| FW.03, la scena del dominio | video, velo e busto corretti, guardie verdi | il fondatore, sul telefono alla prossima build: il video vero, il tocco, il ritorno al dominio |
| FW.04, la scena della chat | video, tocco scoperto da un difetto di composer, salita alla prima risposta | il fondatore, sul telefono alla prossima build: il video vero, il tocco, la salita |

## LE PREMESSE, COL COMANDO CHE LE HA VERIFICATE

- **P1, vera.** Le sei cartelle con i video e i loro fotogrammi esistono in `D:\Clienti Roogly\Rituali Cartomanzia\App\`, alle misure dichiarate (1080x1920, otto secondi, 24 fotogrammi al secondo, con traccia audio).
- **P2, vera.** `lib/features/scene/la_scena_in_video.dart` porta `LettoreDiScena`, `RegiaDellaScena`, `IlToccoCheSalta`, `IlFilmatoCheSfuma`, dall'ordine FU voce FU.15.
- **P3, vera.** `lib/features/maestri/domain_screen.dart` aveva `CosmosBackground` come fondo, con l'ingresso alla chat e i pilastri sopra.
- **P4, caduta in parte.** `lib/features/maestri/chat/maestro_chat_screen.dart` mostrava gia' `ChatEmptyState` col busto fermo e il benvenuto prima del primo messaggio, ma **nel codice non esisteva nessuna animazione di salita della figura alla prima risposta**: lo scambio fra la chat vuota e quella coi messaggi era un `AnimatedSwitcher` con dissolvenza semplice, senza movimento verticale. La salita e la scomparsa descritte dall'ordine non erano gia' nel codice: inventate in questo ordine (voce FW.04) con una `SlideTransition` aggiunta allo stesso `AnimatedSwitcher`.
- **P5, vera.** `lib/features/maestri/chat/chat_openers.dart` esiste: la chat puo' aprirsi gia' con una domanda scritta e inviata.
- **P6, vera.** `lib/features/maestri/maestro_screen.dart`, prima di questo ordine, non montava nessuna scena in video: solo `BustoDelMaestro` fermo.
- **P7, vera.** `docs/ordini/` non conteneva nessun file `ORDINE_FW_*` prima di questo ordine; `CLAUDE.md` porta la regola SPESE e quella della suite su GitHub.

## VOCE PER VOCE

Le righe DOMANDA, PROVA e MISURA di ogni voce stanno nel manifesto. Qui cosa e' stato fatto e dove.

- **FW.01, chiusa.** `tool/gli_asset_dell_ordine_fw.py`: porta i sei video e i dodici fotogrammi da `D:\Clienti Roogly\Rituali Cartomanzia\App\` in `brand_assets/maestri_scena/` (video) e `assets/img/maestri_scena/` (fotogrammi webp), con lo scambio di Caligo gia' applicato (voce FW.05). Dichiarati in `pubspec.yaml` e `docs/stato_asset.json` con l'impronta SHA-256 di ogni video.
- **FW.02, chiusa.** Lo stesso script ricomprime ogni video col metodo dell'ordine FU voce FU.12 (H.264 qualita' costante 26, preset lento, AAC 96 kbit/s) prima di scriverlo nel ramo.
- **FW.03, aperta.** `lib/core/maestro/la_scena_del_maestro.dart` (`LaScenaDelMaestro`, un punto solo per video e fotogrammi di ogni posto); `lib/features/maestri/domain_screen.dart` (diventato `StatefulWidget`, monta `RegiaDellaScena`, il fondo e' ora l'ultimo fotogramma della scena, il velo sopra misurato e corretto due volte, vedi I DIFETTI); `lib/features/maestri/maestro_screen.dart` (`spazioScena` per lasciare lo spazio alla scena, e il busto tolto quando la scena c'e', vedi I DIFETTI).
- **FW.04, aperta.** `lib/features/maestri/chat/widgets/chat_empty_state.dart` (`figura` sostituisce il busto quando una scena e' passata); `lib/features/maestri/chat/maestro_chat_screen.dart` (`RegiaDellaScena` propria per la chat, il tocco che salta scoperto nel suo spazio vero dopo il difetto del composer muto, la `SlideTransition` per la salita alla prima risposta).
- **FW.05, chiusa.** I nomi nel ramo gia' scambiati da `tool/gli_asset_dell_ordine_fw.py` (voce FW.01); `test/ogni_video_dei_maestri_e_nel_suo_posto_test.dart` lega ogni video al suo fotogramma e al suo posto.
- **FW.06, chiusa.** Questo rapporto, il manifesto e la sua guardia (`test/ordine_fw_guard_test.dart`), STATO_VIVO, il registro delle guardie, le sei anteprime in `docs/preview/FW/`.

## I DIFETTI TROVATI GUARDANDO LE ANTEPRIME VERE (R6)

Nessuna prova esistente, prima di guardare le anteprime, controllava questi due punti: ne' la presenza del busto duplicato ne' il contrasto reso davvero a schermo, perche' entrambi sono proprieta' del COMPOSTO finale (scena piu' contenuto sopra), non di un singolo widget isolato che una prova headless controlla facilmente. Trovati e corretti nello stesso ordine, prima della consegna, in un commit dedicato dopo il primo commit del codice FW.

1. **Il busto duplicava la figura del Maestro nel dominio.** `MaestroScreen` mostrava sempre `BustoDelMaestro`, anche quando `DomainScreen` gia' mostra la scena a tutto schermo (che gia' porta la figura intera, R8): il risultato era una Medora grande dietro e una piccola sopra, visibile sulla prima cattura di `fw06_medora_dominio_ferma_dopo.png`. Padre del difetto: la voce FW.03 di questo stesso ordine, che ha aggiunto la scena senza togliere il busto che la precedeva. Corretto nascondendo il busto quando `spazioScena > 0`; le due guardie dell'ordine I che presidiavano il busto (`test/il_busto_e_la_forma_del_maestro_test.dart`, `test/art_catalog_test.dart`) aggiornate per la nuova eccezione, con la lapide che racconta com'era prima.
2. **Il velo sotto il titolo non dipingeva nulla.** `IgnorePointer(child: DecoratedBox(...))` non era dentro un `Positioned.fill`: in uno `Stack`, un figlio non posizionato senza una sua misura intrinseca collassa a dimensione zero, quindi il velo pensato per scurire il fondo sotto "LE ARTI DI X" non compariva mai, su nessuno dei tre domini. Su Medora e Caligo il difetto non si vedeva perche' la scena a quell'altezza e' gia' scura per conto sua; su Aura, dove le lanterne del tempio sono chiare proprio li', il titolo e la riga sotto cadevano su un fondo quasi bianco. Misurato sulla cattura vera (`docs/collaudo/FW/fw03_contrasto_sulla_cattura.py`, il colore piu' frequente della fascia, mai il pixel piu' chiaro ne' la media): 1,35 e 1,43, molto sotto la soglia 4,5. Padre del difetto: la voce FW.03, lo stesso errore di composizione del punto 1. Corretto aggiungendo `Positioned.fill` e spostando i fermi del velo da [0,42; 0,62] a [0,28; 0,46] (pronto alla sua forza quando comincia il contenuto, non ancora a meta' strada), con la forza piena alzata da 0,72 a 0,80: rimisurato dopo, 5,53 e 5,22, sopra soglia anche sul punto piu' chiaro della scena di Aura.

## IL GIRO DELL'UTENTE (R10)

Le sei scene aperte come una persona, due volte di fila, sulle anteprime a 360x797 densita' 3 (`docs/preview/FW/`, scena ferma: il filmato vero gira solo sul telefono, R3):

- **Il dominio.** Il viso di ogni Maestro resta scoperto nella meta' alta, leggibile; il titolo e la riga sotto si leggono bene dopo la correzione del velo; i pilastri nella barra restano sopra la scena, sempre toccabili. Confronto con la Stesa (`tavolo_medora`, l'ordine FL): la' Medora e' un busto disegnato apposta per il tavolo, qui e' la figura intera della scena fotografata; coerente con R8, nessuna figura disegnata al posto del fotogramma.
- **La chat.** La scena non e' a tutto schermo come nel dominio, ma una carta incorniciata sopra il fondo cosmico scuro gia' esistente (`CosmosBackground`), con l'avatar circolare sopra e il benvenuto sotto, su sfondo quasi nero: il contrasto non ha richiesto nessuna correzione, verificato a occhio su tutte e tre le catture. Confronto con l'Oracolo degli Angeli (ordine FU): la' la scena della Scala di Giacobbe e' a tutto schermo come il dominio dei Maestri, non incorniciata come la chat; la differenza e' voluta dall'ordine (P4, "al posto della figura ferma di ChatEmptyState", che era gia' una carta incorniciata, non un fondo a tutto schermo) e non e' un'incoerenza da segnalare.

Nessun'altra differenza dichiarata.

## MIGLIORIE ED EFFETTI WOW PROPOSTI, NON COSTRUITI

- **Il velo del dominio potrebbe diventare un gradiente a due colori** (il colore profondo della palette sfumato verso un accenno del colore primario del Maestro) invece del solo colore profondo: darebbe al dominio una tinta piu' viva nella fascia di lettura, mantenendo lo stesso contrasto misurato. Non costruito: cambierebbe l'aspetto visivo gia' approvato nelle catture di questo ordine, e serve il si' del fondatore prima di toccarlo.
- **Nella chat, la carta della scena potrebbe allargarsi leggermente quando il video e' in corso** (una lieve scala, 1,0 a 1,02) per dare un accenno di profondita' al momento in cui il video gira, poi tornare alla misura normale quando si ferma o sfuma. Non costruito: e' un dettaglio di movimento in piu' che l'ordine non ha chiesto, e in Fase C ogni nuova animazione va provata sul Quality Tier basso prima di entrare.
- **Un suono breve, gia' previsto dall'interruttore generale, al momento in cui la scena del dominio sfuma col tocco**: oggi il tocco e' silenzioso. Non costruito: l'ordine FU voce FU.09 dice gia' che l'audio della scena suona solo se la scena stessa lo prevede nella sua traccia, e aggiungere un suono di interazione separato e' una decisione di prodotto che l'ordine FW non ha chiesto.

## IL VERDE DI GITHUB

Da scrivere dopo il push, in coda a questo rapporto (R3, R6: nessun rosso si consegna).

**Aggiunta del 15 ottobre 2026, ordine FW**: il fondatore, vista l'anteprima di questa consegna, ha corretto la scelta descritta sopra in "IL GIRO DELL'UTENTE" per la chat ("non a tutto schermo come nel dominio, ma una carta incorniciata"): *"E' inaccettabile il riquadro in mezzo alla schermata con il maestro. Trova soluzione elegante e professionale. Il video deve essere a tutto schermo"*. La scena della chat e' salita a sfondo intero di `MaestroChatScreen` (prima stava dentro `ChatEmptyState`, come un riquadro nel contenuto), con lo stesso principio del dominio: fondo fotografato, velo in basso per il saluto, `Positioned.fill` esplicito. La correzione ha preso due difetti in piu', trovati guardando l'anteprima e non da nessuna prova: il volto di `_PresenzaARiposo` (la presenza per il vuoto fra barra e primo messaggio, ordine CO voce 12) restava visibile sopra la scena piena, perche' tolta la figura dalla chat vuota lo spazio sopra il saluto si era allargato; e il gesto che rivela la barra nascosta (ordine EJ voce 09) non trovava piu' zona scorribile a sufficienza per lo stesso motivo. Entrambi corretti: niente presenza a riposo prima del primo messaggio, `ChatEmptyState` riempie tutta l'altezza disponibile col saluto ancorato in basso. Una prova nuova (`test/la_scena_della_chat_e_un_filmato_test.dart`, "la scena della chat copre tutto lo schermo") vista rossa due volte: la prima sul codice gia' a tutto schermo ma ancora dentro il `SafeArea` (709 punti su 797, perche' `SafeArea` toglie comunque l'alto anche con `extendBodyBehindAppBar`), corretta spostando la scena fuori da lui. Le 196 prove della zona e le sei anteprime rigenerate e riguardate di nuovo, tutte verdi; `flutter analyze` pulito sui file toccati.

**Aggiunta del 15 ottobre 2026, ordine FW**: il cancello di GitHub sul commit 4dcc4502 (la correzione della chat a tutto schermo) e' stato rosso su un difetto vero, padre la stessa voce: `test/screenshot_capture_test.dart` non compilava piu', perche' citava `ChatEmptyState.altezzaMinimaDelBusto`, un campo tolto quando il busto ha smesso di avere un'altezza propria da misurare (la scena e' a tutto schermo per costruzione). Non trovato prima della consegna perche' `flutter analyze` era girato solo sui file toccati, mai sul progetto intero: il difetto viveva in un file non toccato da questa voce. Il compile error ha fatto cadere tre pezzi del cancello in cascata: `analyze`, `analyze e sbarramento`, e il corredo a scala massima (una sola schermata montata invece delle almeno centocinquanta richieste, perche' il file che le monta non si caricava). La prova CI.01 (ordine CI voce 01) riscritta per misurare solo cio' che le compete davvero, il saluto che si legge intero sopra il compositore anche al carattere massimo, senza piu' confrontare l'altezza della scena con quella canonica del busto. `flutter analyze` sull'intero progetto pulito; `screenshot_capture_test.dart` per intero, 203 su 203 verdi; le 196 prove della zona di nuovo verdi. Commit della correzione: `1621d1df`.
