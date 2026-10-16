# RAPPORTO DELL'ORDINE FY, LE CORREZIONI DEL FONDATORE SULLA BUILD 2312

16 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_FY_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FY_MANIFESTO.md`, 23 voci: 19 chiuse, 4 aperte in attesa di verifica, 0 da fare. Ramo `claude/esoteric-circle-master-order-e798aj`. Lavoro diviso fra Code e tre agenti in worktree, uniti nel ramo: le barre del titolo (commit 3e209661), l'Oracolo degli Angeli (commit 0f8ef9f1), le Sinastrie (commit 14e660c6).

## LE PREMESSE CADUTE

- **FY.08, lo scrigno intero**: l'ovale d'argento esce dai bordi della pittura stessa (`collana_nello_scrigno_spenta_v1`, 1438 per 2576: argento sulle colonne di bordo per 40 righe a sinistra e 43-45 a destra). Nessuna impaginazione lo mostra intero: serve una pittura nuova (la richiesta e' in fondo).
- **FY.11, il sospetto FXA.08**: la causa principale dello schermo nero era il ponte della Sinastria evolutiva (ordine FT voce FT.14), uno Scaffold nero che chiedeva subito la nascita; la FXA.08 c'entrava per un secondo motivo (il lettore della Sinastria senza l'attesa massima).
- **FY.01, la prima ipotesi di Code**: il quadro grigio non si riproduceva coi margini di prova di 24 punti; l'eccezione vera e' arrivata dai registri del Realme (il margine alto vero e' 75 punti, con la barra dell'identita').

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FY.01, il Calendario grigio | `test/ogni_arte_si_apre_senza_quadro_grigio_test.dart` |
| FY.02, via la Bussola | `docs/collaudo/FY/giro_della_luna/02_scena_ferma_coi_dati.png` |
| FY.03, la Luna senza cornice nera | `test/la_luna_non_ha_la_cornice_nera_test.dart` |
| FY.04, scorre tutto e la Luna resta | `test/scorre_tutto_e_la_luna_resta_test.dart` |
| FY.05, Medora torna col Respiro | `test/scorre_tutto_e_la_luna_resta_test.dart` |
| FY.07, il collegamento al Calendario | `test/il_giro_della_luna_fy_test.dart` |
| FY.09, gli avvisi detti chiari | `test/gli_avvisi_e_le_date_si_capiscono_test.dart` |
| FY.10, le righe centrate | `test/le_righe_dei_dati_sono_centrate_test.dart` |
| FY.12, il cuore al centro | `test/il_cuore_sta_fra_le_due_carte_test.dart` |
| FY.13, dieci domande per argomento | `test/le_dieci_domande_dell_oracolo_test.dart` |
| FY.14, via la nascita prestata e l'amico | `test/l_oracolo_si_sceglie_e_si_avvia_test.dart` |
| FY.15, le carte si scelgono | `test/l_oracolo_si_sceglie_e_si_avvia_test.dart` |
| FY.16, il pulsante che avvia | `test/l_oracolo_si_sceglie_e_si_avvia_test.dart` |
| FY.17, sotto le carte niente video | `docs/collaudo/FY/oracolo/fy17_altare.txt` |
| FY.18, ogni carta descritta | `test/l_oracolo_si_sceglie_e_si_avvia_test.dart` |
| FY.19, una coppia sola | `test/l_oracolo_si_sceglie_e_si_avvia_test.dart` |
| FY.20, le barre semitrasparenti | `test/le_barre_del_titolo_restano_semitrasparenti_test.dart` |
| FY.21, la simulazione | `test/il_giro_della_luna_fy_test.dart` |
| FY.22, le date intere | `test/gli_avvisi_e_le_date_si_capiscono_test.dart` |

## LE VOCI APERTE E CHE COSA ASPETTANO

| voce | che cosa e' fatto | che cosa aspetta |
|---|---|---|
| FY.06, il respiro che funziona | soffio misurato come aria, gesto e giro scritti sulla scena, prove col dito e col soffio finto | il fondatore, sul telefono: il soffio nel microfono vero |
| FY.08, la Collana | testo grande nel velluto, guida sotto lo scrigno | la pittura allargata dello scrigno |
| FY.11, la Sinastria evolutiva | si apre sullo studio di Medora, scelta sulla scena, attese del video | il fondatore, sul telefono |
| FY.23, la consegna | documenti, guardie, verde, build | il fondatore, sul telefono |

## VOCE PER VOCE, COL PADRE DI OGNI DIFETTO

Le voci, coi loro DOMANDA, PROVA e MISURA, sono per intero nel manifesto; qui il padre di ogni difetto (Regola C) e cio' che il manifesto non dice.

- **FY.01**: padre FV.02 (il `clamp` della cima della griglia del mese). L'eccezione vera dai registri del Realme: `Invalid argument(s): 134.66666666666666`, `calendario_lunare_screen.dart:593`. Nella barra del Calendario "Il Respiro" in testo e' diventato l'icona dipinta del respiro (il titolo si spezzava in "Calenda rio"): padre FX.11.
- **FY.02**: nessun difetto, una scelta del fondatore; la Bussola veniva da FX.06.
- **FY.03**: padre FXA.09 (il ritaglio tondo lasciava l'anello nero), FX.03 per la foto.
- **FY.04, FY.05**: padre FXA.09 (la scena ferma in alto col riquadro dei dati che scorreva sotto).
- **FY.06**: tre cause vere. Il microfono a soglia di volume (padre FX.04); il giro fuori dallo schermo (padre FXA.09); lo stato del gesto che non ridisegnava (padre FX.04, preso dalla prova nuova).
- **FY.07**: padre FXA.09 (lo spazio dei dati sotto la scena) e FV.02 (il Calendario che cadeva).
- **FY.08**: il testo, padre FXA.01; lo scrigno tagliato, la pittura stessa (consegnata cosi', PROVENIENZA IGNOTA nel ramo: e' l'asset).
- **FY.09**: padre FX.08 (gli avvisi senza spiegazione).
- **FY.10**: padre FXA.09 (lo Stack della riga senza allineamento).
- **FY.11**: padre FT voce FT.14 (il ponte nero) e FXA.08 (il lettore senza attesa).
- **FY.12**: porta, padre FU voce FU.14; responso, commit 869e2cdf (Blocco 6.5), PROVENIENZA IGNOTA.
- **FY.13**: padre FU voce FU.03. **FY.14**: padre FU voce FU.09. **FY.15, FY.16, FY.17**: padre FU voce FU.02 (e FU.03). **FY.18**: padre FU voce FU.06. **FY.19**: padre FU voce FU.06 e ordine FN.
- **FY.20**: i veli al 90-92 per cento, padri FT voce FT.15 (Sinastria evolutiva), FU (Oracolo), EU voce 19 (Oroscopo); i fondi pieni, FT voce FT.03 (le due nascite) e FX (Respiro e Collana); il passaggio di Material 3 nel tema, PROVENIENZA IGNOTA (comportamento di fabbrica mai spento).
- **FY.22**: padre FXA.09 (il filtro delle date largo 120 punti oltre i bordi).

## LE SCELTE DI CODE, CON LA RAGIONE

- **La Luna senza fondo nero con la luce che diventa opacita'**, non con la fusione schermo: un filtro di colore su una sola immagine, senza il costo della fusione che sul Realme e' gia' stato misurato alto.
- **La Luna velata a riposo al 55 per cento invece del 32**: senza il fondo nero la falce al 32 quasi spariva, e "Tieni premuto sulla Luna" non diceva dove.
- **Il microfono sulla forma dell'aria** (`soloAria`), la stessa misura gia' collaudata nel Soffio del Destino e nel rito del sogno, e il testo che dice di soffiare piano verso il telefono.
- **Nella Collana solo il mese nel velluto** ("Ottobre"), perche' "Collana di ottobre" arrivava a 8 punti; "Collana" e' gia' nel titolo.
- **Respiriamo insieme resta senza pulsante**: la sua schermata non c'e' (FX.09), e la FXA.03 ha tolto le funzioni promesse e non fatte.
- **La guardia del quadro grigio apre l'app vera**, non le schermate da sole, coi margini del telefono vero: e' l'unico modo in cui il difetto si e' fatto vedere.
- **Il velo comune delle barre e' 0,6** (scelta dell'agente delle barre, con il contrasto del titolo misurato a 3,48 sul colore piu' chiaro); la Sinastria evolutiva e le due nascite stanno a 0,45, sotto il comune.
- **Le scelte degli agenti**, nei loro dettagli: il mazzo dell'Oracolo nella pagina e non sopra la scena; le consultazioni contate all'affidare; il fondo senza carte composto dai fotogrammi gia' nel ramo; la scelta della persona della Sinastria evolutiva in fondo allo schermo, sulla scena; il cuore della VIP allargato al responso.

## CONFLITTI CON DECISIONI GIA' SCRITTE

- Ordine DU, "il ventaglio della Stesa resta della Stesa": la guardia ammette ora anche l'Oracolo (FY.15); il no dell'ordine DU all'Arcano dell'Alba resta.
- Ordine FU.14: le carte della VIP centrate sulle cornici anche in verticale e il cuore sul cuore dipinto, incompatibili con FY.12: ha vinto FY.12.
- Ordine EU voce 19, la barra dell'Oroscopo velata almeno al 90 per cento: ora fra il 50 e il 60 (FY.20). La striscia dell'identita' resta al 92, difesa dalla stessa EU: decide il fondatore.
- Ordine FN e FU.06, il riquadro separato della Lunga nell'Oracolo: non c'e' piu' (FY.19).

## LA RICHIESTA AL FONDATORE, PER FY.08

Le due pitture dello scrigno della Collana, `collana_nello_scrigno_spenta_v1` e `collana_nello_scrigno_accesa_v1`, rigenerate piu' larghe, con un margine di velluto scuro di almeno il 6 per cento della larghezza intorno all'ovale d'argento, cosi' che l'ovale stia tutto dentro l'immagine; le perle nella stessa posizione relativa fra le due pitture. Poi Code rimisura i centri delle perle sul file nuovo (`le_perle_della_collana_v1.json`).

## MIGLIORIE PROPOSTE, NON COSTRUITE

- Con le dieci domande aperte il pannello dell'Oracolo copre il volto di Medora (cattura `fy21_04`).
- Nella porta della Sinastria VIP i pulsanti e le tre scelte sono ancora widget di Material, non pezzi dipinti (R8), e nell'Oracolo il dono e il rito con Caligo.
- Nella risposta Lunga dell'Oracolo il modello ripete fra riquadro e approfondimento: si cura nell'istruzione, ma la misura chiede una chiamata e il si' del fondatore.
- Lo scopo 'oracolo' sul server e il parametro rimasto nel client del Cerchio: si tolgono con una pubblicazione delle funzioni.
- Un velo sfumato sotto la barra della Sinastria evolutiva, perche' il testo che le passa sotto si spenga invece di leggersi attraverso.

**Aggiunta del 16 ottobre 2026, ordine FY, la conferma del fondatore sul ventaglio**: "Ok per il ventaglio", Mauro, 16 ottobre 2026. Il ventaglio della scelta delle carte e' ammesso nella Stesa e nell'Oracolo degli Angeli; tutte le altre funzioni restano escluse, e la guardia dell'ordine DU (`ordine_du_guard_test.dart`) resta com'e', con le due eccezioni dichiarate.

**Aggiunta del 16 ottobre 2026, ordine FY, voce FY.08 (la Collana intera), chiusa con la prova `test/la_collana_si_vede_intera_test.dart`**: il fondatore ha mandato le pitture v2 con l'ovale intero (`collana_nello_scrigno_spenta_v2`, `collana_nello_scrigno_accesa_v2`, 1438 per 2576) e le posizioni in `le_perle_della_collana_v2.json`, con la Luna al centro come medaglia. Nel ramo da `tool/gli_asset_della_collana_v2.py`: 33 ritagli riletti identici, la collana completa composta coi ritagli contro la pittura accesa a 0,47 su 255 di scarto medio, le v1 tolte dal ramo (36 file). Righe d'argento sulle colonne di bordo da 40-45 a 0. A schermo la finestra della pittura dalla riga 400 alla 2172, l'ovale col suo margine di circa cento pixel tutto intorno: l'ovale largo 270, 304, 329 e 334 punti a 320, 360, 390 e 430 (prima, a 360, circa 185). Il mese sopra la Luna, le perle accese sotto. Catture in `docs/collaudo/FY/collana_v2/`; la prova e' caduta stringendo la finestra sull'ovale (riga 600 invece di 400: "l'ovale e' tagliato in alto"), file ripristinato con lo sha1 identico. Il manifesto passa a 20 voci chiuse e 3 aperte.

**Aggiunta del 16 ottobre 2026, ordine FY, i rossi del cancello sui commit e7f97182 e e4c19424**: tutti i pezzi della suite verdi, quattro rossi nuovi nello sbarramento, riprodotti in locale e corretti. `test/tipografia_nel_dato_test.dart`, i vuoti verticali scesi da 175 a 174 senza censimento rigenerato (padre FY parte C, l'Oracolo): rigenerato. `test/etichette_e_lettura_test.dart`, la frase "dieci domande di Medora, scorri per leggerle" scritta come etichetta su due righe (padre FY.13): ora nello stile della lettura breve. `test/le_descrizioni_hanno_una_misura_sola_test.dart`, i paragrafi del riquadro e dell'approfondimento dell'Oracolo con lo stile in una variabile, che la guardia non riconosce, e l'approfondimento fuori dalla porta comune (padre FY.19): ora `ParagrafiDiLettura` con `TypographyTokens.lettura` scritto accanto. `test/corredo_anteprime_test.dart`, tre catture senza il rapporto di pixel del corredo (padri FY.08 per la Collana, FY.21 per le Sinastrie, FY.17 per l'Oracolo): la Collana ora a rapporto tre, le altre due dichiarate fra le eccezioni con la loro ragione.

**Aggiunta del 16 ottobre 2026, ordine FY, la consegna**: il cancello di GitHub e' verde sul commit 1c034564 (`refs/verde/1c034564d75cf91513019724dcdef4d3cdd27dcc`); la build 2313, costruita da quel commit, e' consegnata con App Distribution (release 3aic94nssphh8, registro da 2312 a 2313), dopo averla guardata sul Realme 767f596c: il Calendario Lunare si apre col mese, senza quadro grigio e senza eccezioni nei registri del telefono; nel Respiro la Luna senza cornice nera e la barra a due voci; nel rito, tenendo premuto sulla Luna, "Inspira", il giro e l'anello di perle accesi sulla scena. Restano aperte in attesa del fondatore sul telefono FY.06 (il soffio nel microfono vero), FY.11 (la Sinastria evolutiva) e FY.23.
