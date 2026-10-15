# RAPPORTO DELL'ORDINE FU, L'ORACOLO DEGLI ANGELI E LE SCENE DELL'OROSCOPO E DELLA SINASTRIA VIP

15 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_FU_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FU_MANIFESTO.md`, 17 voci: 9 chiuse, 8 aperte in attesa di verifica, 0 da fare. Ramo `claude/esoteric-circle-master-order-e798aj`, partenza fcae7e1d. Nessuna build, nessuna chiamata a Gemini o a Vertex, nessun deploy, nessun dato di produzione toccato. Il lavoro e' stato diviso fra Code e quattro agenti in parallelo (il corpus, la scena dell'Oroscopo, la scena della Sinastria VIP, il sociale e i piani), ognuno nel suo worktree e unito nel ramo con un commit di unione.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FU.01, gli asset dell'Oracolo nel ramo | `docs/collaudo/FU/fu01_asset.txt` |
| FU.03, la domanda e le tre carte | `test/l_oracolo_degli_angeli_test.dart` |
| FU.05, il corpus scritto da Code e i lettori ciechi | `docs/collaudo/FU/lettori_ciechi/esito_2.txt` |
| FU.06, il formato del responso | `test/l_oracolo_degli_angeli_a_video_test.dart` |
| FU.07, il rito con Caligo | `test/l_oracolo_degli_angeli_test.dart` |
| FU.08, l'angelo dell'ora e il messaggio del giorno | `test/l_oracolo_degli_angeli_test.dart` |
| FU.12, il peso dei video | `docs/collaudo/FU/fu01_asset.txt` |
| FU.16, la promessa falsa tolta | `test/la_compatibilita_a_tre_livelli_non_si_promette_test.dart` |
| FU.17, la consegna | `docs/ordini/RAPPORTO_ORDINE_FU.md` |

## LE VOCI APERTE E CHE COSA ASPETTANO

| voce | che cosa e' fatto | che cosa aspetta |
|---|---|---|
| FU.02, la scena della Scala di Giacobbe | provata a video headless e nelle anteprime, scarto 8,42 su 255 | il fondatore, sul telefono alla prossima build |
| FU.04, la risposta col modello | una chiamata, tetti, ripiego del corpus, domande delicate, tutto con la chiamata finta | il si' alla prima esecuzione vera, stimata in 0,005 euro |
| FU.09, il dono, la domanda per un amico, la card | client e server scritti e provati, server 250 su 250 | la pubblicazione di `mandaUnDono`, `condividiLaNascita` e `leggiLaNascita`, poi due telefoni |
| FU.10, i piani e gli Eos | matrice, listino, tetto del costo, budget del server scritto | la pubblicazione di `statoDelCerchio` e `muoviGliEos` |
| FU.11, la porta | scheda attiva nella home e nel dominio di Medora, passaggio dai tre angeli | il fondatore, sul telefono alla prossima build |
| FU.13, la scena dell'Oroscopo | provata headless, anteprime prima e dopo | il fondatore, sul telefono alla prossima build |
| FU.14, la scena della Sinastria VIP | provata headless, carte da 144x216 a 152,3x228,5 | il fondatore, sul telefono, e la scelta sullo sfondo che scorre |
| FU.15, il tocco che salta il video | punto unico, cinque scene, guardia col cardinale 5 | il fondatore, un tocco in ognuna delle cinque scene |

## LE PREMESSE, COL COMANDO CHE LE HA VERIFICATE

Sul commit di partenza fcae7e1d; le cartelle del fondatore lette in `D:\Clienti Roogly\Rituali Cartomanzia\App\`. Lo script e la sua uscita intera stanno in `docs/collaudo/FU/premesse.txt`.

- **P7, caduta in parte.** `git grep -n -i "oracolo degli angeli" fcae7e1d -- lib` trova `art_catalog.dart:289`: una funzione chiamata Oracolo degli Angeli esisteva gia', come card Coming soon (`state: ArtState.inArrivo`). E' quella che la voce FU.11 fa uscire dal Coming soon, con l'id che aveva (`angels_oracle`). La cartella `assets/img/oracolo/` (5 file, `git ls-tree`) non e' nominata da nessun file del ramo (`git grep "assets/img/oracolo"` vuoto): non si e' toccata, e l'Oracolo vive in `assets/img/oracolo_angeli/`.
- **P14, caduta in parte.** `git grep -l "VideoPlayerController\|LettoreDellaScena" fcae7e1d -- lib` trova otto file: oltre alla Stesa e alla Sinastria evolutiva aprono un video l'intro, la rivelazione del Maestro, il velo dell'onboarding e la discesa del Viaggio dello Sciamano. Il tocco che salta copre le cinque scene che l'ordine nomina; gli altri video l'ordine non li nomina e non si sono toccati (R10). La discesa poi non parte da sola: la governa il dito (ordine DI voce 09). Proposta in fondo.
- **P1, vera.** `ls` e `ffprobe` sulla cartella dell'Oracolo: dieci file, le misure dichiarate, il video 720x1280 e 8,000 secondi.
- **P2, vera.** `git ls-tree --name-only fcae7e1d assets/img/angeli/ | grep -c "ang_[0-9][0-9]_.*_v1.webp"` da' 72, e c'e' `ang_dorso_medora_v1.webp`.
- **P3, vera.** `minutesPerAngel = 20` alla riga 55 di `guardian_angels.dart`; l'Intelletto e' `Angel?`, nullo senza l'ora.
- **P4, vera.** La POLITICA DI PUBBLICAZIONE alla riga 7 di `docs/corpus/angeli.md`; `git cat-file -e fcae7e1d:docs/angeli_verifica_lenain.md` riesce.
- **P5, vera.** `typedef ChiamataDellaStesa` alla riga 26 di `la_lettura_dal_modello.dart`.
- **P6, vera.** `angels_screen.dart` mostra Custode, Cuore e Intelletto della triade.
- **P8, vera.** Nessun file `ORDINE_FU_*` in `docs/ordini/`.
- **P9, vera.** La regola SPESE alla riga 161 di CLAUDE.md.
- **P10, vera.** Sette file, il video 1080x1920, 8 secondi, 10.487.384 byte.
- **P11, vera.** La rivelazione mostra l'emblema che riceve; in `assets/img/zodiac/` ci sono 12 emblemi occidentali, 12 cinesi, 2 vedici propri e 4 emblemi di tradizione.
- **P12, vera.** Sei file, il video 1080x1920, 8 secondi, 17.966.855 byte.
- **P13, vera.** Il titolo "La Tua Compatibilità con un VIP" alla riga 296 di `porta_della_sinastria.dart`.
- **P15, vera.** `plan_catalog.dart` righe 376 e 918.

## LA STIMA IN EURO DI UNA CONSULTAZIONE COL MODELLO

Dal listino Vertex letto il 15 ottobre 2026 sulla pagina ufficiale dei prezzi (`https://cloud.google.com/vertex-ai/generative-ai/pricing`, oggi reindirizzata a quella di Agent Platform), riga **Gemini 2.5 Flash-Lite**: 0,10 USD per milione di token in ingresso, 0,40 USD per milione in uscita, ragionamento compreso.

I token misurati con la chiamata finta (`test/l_oracolo_degli_angeli_test.dart`, riga stampata "FU.04 STIMA"): 2.812 caratteri in ingresso, circa **804 token** contati prudenti a 3,5 caratteri per token; in uscita al piu' **300** nella Breve e **600** nella Lunga, che sono i tetti della chiamata.

- **Breve**: 804 x 0,10 / 1.000.000 + 300 x 0,40 / 1.000.000 = **0,0002 USD**.
- **Lunga**: 804 x 0,10 / 1.000.000 + 600 x 0,40 / 1.000.000 = **0,0003 USD**.
- In euro, col cambio prudente di un euro per dollaro: **0,0002 euro e 0,0003 euro** al massimo. Al cambio di 1,1204 dollari per euro sono 0,00018 e 0,00029.
- **La prima esecuzione vera**, venti consultazioni (dieci Brevi e dieci Lunghe su domande diverse), costa al piu' **0,005 euro**. Non e' partita: aspetta il si' del fondatore (R2, regola SPESE). Il conto intero sta in `docs/collaudo/FU/fu04_listino_e_stima.txt`.

## VOCE PER VOCE

Le righe DOMANDA, PROVA e MISURA di ogni voce stanno nel manifesto. Qui cosa e' stato fatto e dove.

- **FU.01, chiusa.** `tool/gli_asset_dell_ordine_fu.py`: immagini in webp a qualita' 88 alla stessa misura, impronte SHA-256, dichiarazione in `pubspec.yaml` e in `docs/stato_asset.json`. Le nove immagini dell'Oracolo da 5.580.047 a 1.279.956 byte. I cartigli della ruota contati 32-34 sulla meta' visibile: non sono 72 verificabili, nessun testo dice "ruota dei 72 nomi". Le pose non scontornate: il ripiego e' l'ultimo fotogramma intero.
- **FU.02, aperta.** `lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart` e `la_geometria_dell_altare.dart`. I tre dorsi mappati sull'ultimo fotogramma (centri a 274,5, 539,5 e 805,5 pixel, base a 1685, larghezza 235 in basso e 195 in alto); la carta si gira con una prospettiva misurata in modo che gli angoli cadano sugli angoli dipinti a ogni larghezza. Le lettere di luce sono un pittore di Flutter con la domanda vera. Scarto ultimo fotogramma contro la scena ferma 8,42 su 255.
- **FU.03, chiusa.** `lib/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart` (`EstrazioneDellOracolo.estrai`, il caso passato da fuori), `le_domande_dell_oracolo.dart` (sette temi, ventuno proposte, nel formato di `domanda_della_persona.dart`).
- **FU.04, aperta.** `lib/core/oracolo_angeli/la_lettura_dell_oracolo.dart`: una chiamata con la porta della Stesa (`FirebaseAI.vertexAI` in europe-west1, `ClientConEtichetta` con l'etichetta nuova `oracolo_angeli`), risposta in JSON con lo schema, pazienza otto secondi. Le domande delicate in `la_domanda_delicata.dart`, riconosciute sul telefono anche senza accenti e poi nell'istruzione. **L'app non ha ancora un percorso di aiuto coi suoi contatti** (cercato sul ramo: nessun numero, nessuna schermata): la cura indica il 112. I contatti da aggiungere sono proposti piu' sotto.
- **FU.05, chiusa.** Lavoro di un agente: `docs/corpus/oracolo_angeli/` (LEGGIMI con gli schedari, custode, cuore, intelletto, rito), `tool/il_corpus_dell_oracolo.py` (controlla e genera), `tool/i_lettori_ciechi_dell_oracolo.py`. 792 testi, 0 difetti; lettori ciechi 60 su 60 e 59 su 60.
- **FU.06, chiusa.** Il responso in `_IlResponso`: TitoloDelResponso, ResponsoInTreParagrafi col riquadro, Da dove viene, la Lunga con l'approfondimento, una bolla per carta col medaglione, la carta, il Parlane e il rito.
- **FU.07, chiusa.** `_IlRitoConCaligo`: il momento da `LOraDegliAngeli.momentoDelRito`, il salmo dalla scheda dell'angelo, il testo dal corpus.
- **FU.08, chiusa.** `lib/core/oracolo_angeli/l_ora_degli_angeli.dart`: un punto solo per l'ora e il messaggio del giorno.
- **FU.09, aperta.** Lavoro di un agente: `oracolo_share_card.dart` (la card), `IlCerchioSociale.mandaUnaCartaDegliAngeli` (il dono sulla porta `mandaUnDono`), il gesto della lettura a due telefoni con `perLOracolo`, `GliAngeliDiUnAmico.daNascitaPrestata`. Sul server: lo scopo e il minuto locale nel consenso, il dono `angelo` da 30 Eos.
- **FU.10, aperta.** Lavoro di un agente: quattro righe nuove nella matrice dei piani, il budget `oracoliAngeli` [1, 3, 5, 6], il riscatto a 100 Eos, `tool/i_limiti_degli_annuali.py` esteso e `docs/costi/i_limiti_degli_annuali.txt` rifatto.
- **FU.11, aperta.** `art_catalog.dart` (attiva, con la lapide), `art_navigation.dart`, i conti, i gesti, gli arti con responso, l'artwork del ricordo, le aperture della chat, il foglio delle fonti, il pulsante dalla schermata dei tre angeli. La scheda era gia' nella riga Cartomanzia del dominio di Medora e in "Trova una risposta" della home: da attiva, si apre.
- **FU.12, chiusa.** H.264 a qualita' costante 26 col preset lento, AAC a 96 kbit/s: da 35,0 a 15,0 MB per i tre video.
- **FU.13, aperta.** Lavoro di un agente: `lib/features/horoscope/la_scena_dell_oroscopo.dart` e `oroscopo_screen.dart`. Scarto 10,33; globo e sedi misurati; contrasto sopra il globo da 7,36 a 8,21.
- **FU.14, aperta.** Lavoro di un agente: `porta_della_sinastria.dart` con `IlPalcoDellaSinastriaVip`. Carte +5,8% di lato; scarto 7,70.
- **FU.15, aperta.** `lib/features/scene/la_scena_in_video.dart`: `LettoreDiScena`, `RegiaDellaScena`, `IlToccoCheSalta`, `IlFilmatoCheSfuma`, `LaScenaFermaCheAppare`. La Stesa e la Sinastria evolutiva ci passano senza cambiare altro.
- **FU.16, chiusa.** Lavoro di un agente: `plan_catalog.dart`, `strade_dello_sblocco.dart`, `listino_degli_eos.dart`, `art_catalog.dart`, le prove riscritte con la lapide.
- **FU.17, chiusa.** Questo rapporto, il manifesto e la sua guardia, STATO_VIVO, il registro delle guardie, le anteprime.

## LE SCELTE DI CODE, CON LA RAGIONE

- **Il modello e il tetto dei token.** Gemini 2.5 Flash-Lite, gia' verificato in europe-west1 (`LaRegioneDeiDati`), e non Flash dei Maestri: il modello scrive due campi corti che legano la domanda alle carte, il resto e' corpus. Tetto in uscita 300 per la Breve (titolo al piu' 80 caratteri, riquadro al piu' 420) e 600 per la Lunga (due paragrafi in piu' da 420). L'istruzione fissa sta in testa alla richiesta, uguale per tutti, cosi' la cache implicita del modello la puo' riusare fra persone diverse.
- **Che cosa scrive il modello.** Solo il titolo e il riquadro, cioe' il secondo paragrafo, che parte dal Cuore. Il primo e il terzo vengono dal corpus. Senza modello il riquadro e' il testo del Cuore nel corpus, e il titolo e' quello del tema riconosciuto: la persona legge "risposta dal solo corpus", mai una risposta finta spacciata per letta.
- **Le domande proposte.** Sette temi (amore, lavoro, famiglia, amicizia, scelta, crescita, serenita'), tre domande ciascuno, tutte aperte e senza esito promesso ("Che cosa mi chiede questo amore adesso?", non "Tornera'?"). Nessun tema e' aperto all'inizio: le proposte si aprono toccando un tema, cosi' il pannello lascia il volto di Medora alla scena.
- **La tabella dei piani.**

| piano | consultazioni al giorno | che cosa ha |
|---|---|---|
| Viandante | 1 | angelo dell'ora, messaggio del giorno, assaggio dal solo corpus: il Custode si scopre, Cuore e Intelletto col lucchetto e l'invito |
| Iniziato | 3 | le tre carte, risposta Breve; lucchetto sulla Lunga e sulla domanda per un amico |
| Adepto | 5 | la Lunga e la domanda per un amico |
| Illuminato | 6 | come l'Adepto |

  La consultazione in piu' costa 100 Eos, fra la domanda in piu' (80) e la stesa a tre carte (120). La carta in dono costa 30 Eos, come la scintilla: un oggetto singolo che resta nel profilo. **I numeri vengono dal tetto del costo**: col ciclo piu' stretto, il mensile dell'Illuminato, la proposta iniziale (Adepto 7, Illuminato 15) sforava il 30 per cento del netto; a 7 si arrivava al 29,97, a 6 ci si ferma al 29,9, e l'Adepto annuale a 5 sta al 29,8. L'assaggio del Viandante non chiama il modello: costo zero.
- **I numeri del corpus.** 72 angeli per 3 ruoli per 3 varianti, 648 messaggi, piu' 72 riti per 2 varianti, 144: 792 testi in 288 celle. Tre varianti per il messaggio perche' lo stesso angelo nella stessa posizione esce di rado e la rotazione copre tre uscite prima di ripetersi; due per il rito perche' si apre solo a richiesta.
- **La grandezza nuova delle carte VIP.** Da 144,0x216,0 a 152,3x228,5 punti a 360x797 (+5,8% di lato, +11,9% d'area). Centrate sulle cornici di luce, come vuole l'ordine, il limite che vince e' il cuore dipinto fra le due: a 4,0 punti dalla carta VIP. Carte piu' grandi vorrebbero dire rinunciare al centraggio o spostare il cuore.
- **I video a misura d'origine.** A 720 punti l'Oroscopo e il Sipario perdevano dettaglio (scarto 4,68 e 6,21 contro 2,54 e 4,07), e nel Sipario la polvere d'oro si impastava: cattura in `docs/collaudo/FU/fu12_vip_1080_contro_720.png`.

## DA DECIDERE PER IL FONDATORE

1. **La prima esecuzione vera del modello**, 0,005 euro per venti consultazioni: serve il si' in chat.
2. **Le pubblicazioni sul server**: `mandaUnDono`, `condividiLaNascita`, `leggiLaNascita` (FU.09), `statoDelCerchio` e `muoviGliEos` (FU.10). Comando: `cd functions && firebase deploy --only functions:mandaUnDono,functions:condividiLaNascita,functions:leggiLaNascita,functions:statoDelCerchio,functions:muoviGliEos --project esoteric-circle`. Fino ad allora le consultazioni non si contano, il dono dice che il Cerchio non risponde, e col server di oggi un codice prestato per la Sinastria evolutiva si leggerebbe anche dall'Oracolo.
3. **I contatti di aiuto per le domande delicate.** Proposta, da verificare sulla fonte prima di metterli in app: il **112**, numero unico di emergenza europeo (gia' in app); **Telefono Amico Italia, 02 2327 2327** (telefonoamico.it), ascolto per chi e' in difficolta'; **1522**, numero antiviolenza e antistalking del Dipartimento per le Pari Opportunita' (1522.eu); **Telefono Azzurro, 19696** (azzurro.it), per i minori. Per un'app in piu' lingue i numeri vanno scelti col paese della persona.
4. **Lo sfondo della Sinastria VIP**: oggi scorre con le carte, cosi' le carte non escono dalle cornici. Se lo vuoi inchiodato allo schermo, le carte si separano dalle cornici appena si scorre.
5. **Gli altri video dell'app** (premessa P14): l'intro, la rivelazione del Maestro e il velo dell'onboarding non hanno il tocco che salta. Se vuoi, si portano sul punto unico con un ordine.

## IL GIRO DELL'UTENTE, CONTRO LA STESA (R9)

Ho fatto il giro come lo farebbe una persona, sulle anteprime e sulle prove a video, accanto alla Stesa.

- **Si entra** dalla scheda nella home o dal dominio di Medora, oppure dai tre angeli. Il video parte, e un tocco lo salta, come nella Stesa. Si arriva a Medora davanti alla scala, coi tre dorsi sull'altare e il campo della domanda: la Stesa chiede prima il mazzo e la stesa, l'Oracolo chiede solo la domanda. Un passo in meno.
- **La domanda.** La Stesa propone domande dentro una tendina, l'Oracolo per temi. Nella prima anteprima le proposte erano troncate coi puntini e il pannello copriva il volto di Medora: corretto (padre: voce FU.03).
- **Le carte.** Nella Stesa le carte volano dal mazzo; qui la domanda sale in lettere lungo la scala e le carte si girano dove sono. Piu' raccolto, ed e' giusto per gli angeli.
- **Il responso.** Stesso schema della Stesa: titolo che risponde, tre paragrafi col riquadro, Da dove viene, bolle col Parlane. In piu' il rito di Caligo sotto ogni carta e il dono. Il responso e' lungo: chi vuole solo la risposta la trova nel titolo e nel riquadro.
- **Dopo.** "Affida una nuova domanda" non rifa' partire il video. L'angelo dell'ora e il messaggio del giorno danno una ragione per tornare domani, che la Stesa non ha.
- **Che cosa la persona si potrebbe chiedere.** "Perche' la terza carta e' coperta?": la carta lo dice, e il pulsante porta a mettere l'ora. "Chi sono questi tre angeli che portano le carte?": la bolla dice "La porta il tuo Angelo Custode, Lauviah", ma la schermata non spiega da dove vengono; il Da dove viene lo dice in una riga.

## LE GUARDIE

Dieci guardie nuove, tutte viste rosse su un innesto verificato col grep, registrate in `docs/guardie.md`. Il registro passa da 774 a 784: porta comune 159, cardinale proprio 273, senza insiemi 352.

- `ogni_scena_si_salta_col_tocco`, dalla porta comune col cardinale delle cinque scene.
- `il_corpus_dell_oracolo`, `l_altare_dell_oracolo`, `l_oracolo_degli_angeli`, `l_oracolo_risponde_con_cura`, `l_oracolo_degli_angeli_a_video`, `l_oracolo_degli_angeli_sociale_e_piani`.
- `la_scena_della_sinastria_vip_e_un_filmato`, `la_scena_dell_oroscopo_e_un_filmato`.
- `ordine_fu_guard`, rossa sulla voce FU.17 finche' questo rapporto non esisteva.
- Le prove della Regola A delle guardie di Code stanno in `docs/collaudo/FU/regola_a_*.txt`; quelle degli agenti in `fu13_innesti.txt`, `fu14_scena_vip.txt` e nella sezione L'innesto di `docs/corpus/oracolo_angeli/LEGGIMI.md`.
- **Le guardie di casa cadute per l'arte nuova**, undici, sono state la prova del rosso piu' onesta: rosse per il lavoro, prima di ogni correzione. Le tavole aggiornate col nome dell'Oracolo: soglia unica, fonti, scaffale, fila delle arti, cammino, custodito, censimento DX; un'etichetta su due righe, un trattino lungo in una stringa del codice, "piu" senza accento. Padre: voce FU.11, l'arte resa attiva, e voce FU.04, le stringhe della lettura e della cura.
- **Regola B mancata, confessata**: `entitlement_test` non e' stata vista rossa prima di toccare la matrice; e' caduta per il lavoro stesso (voce FU.10) ed e' stata aggiornata con la ragione.

## LE ANTEPRIME

In `docs/preview/FU/`, a 360 per 797 con densita' 3, guardate una per una.

- **Oracolo**, solo dopo (prima era una card Coming soon): la domanda, le proposte, l'angelo dell'ora, le carte girate, il responso, la bolla col rito e il dono, la carta coperta, la cura.
- **Oroscopo**, prima e dopo: l'apertura con gli emblemi, il testo sul globo, la tradizione cinese, la maya; dopo anche la lettura salita.
- **Sinastria VIP**, prima e dopo: la porta e le scelte.
- **Difetti trovati guardandole, tre, tutti corretti**: le proposte troncate e il pannello sul volto di Medora (voce FU.03); il titolo della porta VIP salito di 56 punti (voce FU.14, trovato dall'agente).

## I DIFETTI E IL LORO PADRE (REGOLA C)

- **Il consenso della lettura a due telefoni non portava l'ora locale.** Padre: ordine FT voce FT.03. Da solo non bastava per l'Angelo dell'Intelletto di un amico; colmato per il solo scopo Oracolo (voce FU.09).
- **Il nome maya "7 Akʼbʼal" mostra due quadrati al posto dell'apostrofo** nel carattere delle prove, uguale sul commit di partenza. **PROVENIENZA IGNOTA**: da guardare sul telefono, dove il carattere puo' essere diverso.
- **La scheda "Amico/a" dell'Oroscopo** porta una barra che indovina il genere a meta'. C'era prima dell'ordine e la voce FU.13 non doveva toccare i testi (R10). PROVENIENZA IGNOTA sull'ordine che l'ha scritta; da correggere in un ordine sui testi.
- **Quattro rossi di casa del lavoro sul sociale** (una virgola prima di "e", un'etichetta su due righe, un vuoto scritto in numero, un InkWell col click): padre voci FU.09 e FU.10, corretti prima del commit.

## MIGLIORIE ED EFFETTI WOW PROPOSTI, NON COSTRUITI

1. **La scala che si accende col nome.** Quando le lettere arrivano in cima, i gradini della scala si accendono uno a uno e il nome dell'angelo del Custode resta scritto in luce sull'arco per un istante: il colpo d'occhio prima del testo.
2. **Il salmo detto da Caligo.** Nel rito, un tocco fa leggere a Caligo il numero del salmo e il momento, con la sua voce del LIVE: il rito diventa un appuntamento.
3. **L'angelo dell'ora come notifica scelta.** Chi lo vuole riceve, una volta al giorno all'ora che sceglie, il nome dell'angelo che governa quei venti minuti e una riga del corpus: nessun modello, costo zero.
4. **Il dono che si apre.** Chi riceve la carta in dono la vede arrivare coperta sull'altare di Medora e la gira col dito, come nell'Oracolo.
5. **Il diario degli angeli.** Dopo dieci consultazioni, Medora mostra quale angelo ti e' uscito piu' spesso e in che ruolo: una ragione per tornare che nasce dai dati della persona.
6. **Il tocco che salta, imparato.** Dopo tre aperture saltate di fila, la scena parte gia' corta (gli ultimi due secondi): rispetta chi entra spesso senza togliere il video a chi entra la prima volta.

## LA SUITE INTERA

Per la regola del 14 ottobre 2026 la suite intera la fa il cancello `verde.yml` di GitHub a ogni push: in locale sono girate solo le prove delle voci e le guardie della zona, poche alla volta. L'ultima corsa di zona sul ramo unito con tutte le voci: 102 prove su 102 verdi (le prove dell'Oracolo, sociale e piani, DW.08, entitlement, etichette, lingua, accenti, registro, censimento DX, scene, tipografia, genere). Il verdetto del cancello sul commit consegnato si scrive nella riga in coda.
