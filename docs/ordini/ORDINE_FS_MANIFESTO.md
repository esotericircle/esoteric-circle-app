# MANIFESTO DELL'ORDINE FS, L'AGGIUNTA DEL VIDEO DELLA SCENA DELLA STESA E IL RISCATTO DELLA CROCE CELTICA

Rapporto: `docs/ordini/RAPPORTO_ORDINE_FS.md`. L'ordine FS del 13 ottobre 2026 (le dieci correzioni ai tarocchi dopo la build 2308) e' registrato in `docs/STATO_VIVO.md`, sezione "L'ORDINE FS", dove le sue dieci voci sono aperte in attesa della verifica a video sull'app vera: non hanno un manifesto, e questo non le riscrive. Questo manifesto porta le voci nate dopo, il 14 ottobre 2026, numerate di seguito: la FS.11 e la FS.12 sono le due voci dell'aggiunta "IL VIDEO DELLA SCENA DELLA STESA" (nell'ordine si chiamano FS.A1 e FS.A2), la FS.13 e' la decisione del fondatore in chat sul prezzo della Croce Celtica. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA; una voce aperta dice che cosa aspetta.

VOCI_TOTALI: 3
VOCI_CHIUSE: 1
VOCI_APERTE: 2
VOCI_DA_FARE: 0

## VOCE FS.11

**CHIUSA.** FS.A1 dell'aggiunta: `brand_assets/tavolo/` dichiarata in `pubspec.yaml` e in `docs/stato_asset.json`, e le due pose di Medora senza lo sfondo bianco, trasparenti intorno alla figura e senza aloni chiari sui bordi.

DOMANDA: "vorrei fare lo stesso lavoro che abbiamo fatto per animare lo sfondo dei tarocchi e così faremo per ogni funzionalità"
PROVA: docs/collaudo/FS/aggiunta_video/a1_scontorno.txt
MISURA: cartelle di brand_assets dichiarate nel pubspec da 5 a 6 e in pubspec_asset_attesi da 5 a 6; brand_assets_conteggi tavolo da assente a 1; pixel trasparenti delle pose da 0 a 688.501 (mazzo) e 664.616 (invito) su 1.072.960; pixel di bordo con alone chiaro, composti su un fondo scuro, da 4.963 a 15 su 7.312 (mazzo) e da 5.557 a 21 su 8.909 (invito), contro lo scontorno ingenuo, riletti dal file consegnato; cattura a1_pose_scontornate.jpg

## VOCE FS.12

**APERTA IN ATTESA DI VERIFICA.** FS.A2 dell'aggiunta: aprendo la Stesa il video del vortice prende il posto della scena ferma, nello stesso riquadro e con lo stesso taglio, una volta per apertura; si ferma sull'ultimo fotogramma e ci resta, e le carte fanno sopra quello che facevano; con Riduci Movimento, o se il video non si carica, la scena e' ferma con la posa dell'invito; l'audio sta sotto l'interruttore del suono dell'app e tace col telefono in silenzioso. Guardato sul Realme: il video parte, suona, si ferma e resta anche dopo l'uscita dall'app. Non guardato: il silenzioso del telefono, e la Stesa nell'app vera.

ASPETTA: il fondatore, sul telefono: suoneria in silenzioso o in vibrazione, aprire la Stesa, il video deve essere muto; e la Stesa nell'app vera alla prossima build che ordinera'. Su iOS il silenzioso non si legge (il sistema non lo dice alle app): li' il video suona come la musica dell'app.
DOMANDA: "vorrei fare lo stesso lavoro che abbiamo fatto per animare lo sfondo dei tarocchi e così faremo per ogni funzionalità"
PROVA: docs/collaudo/FS/aggiunta_video/a2_realme.txt
MISURA: ultimo fotogramma contro il tavolo fermo, sotto la vita di Medora, spostamento trovato -0,13 e +0,06 pixel del video (correlazione 0,9913), quattro angoli del velluto e medaglione a 0,0 pixel; posa dell'invito contro l'ultimo fotogramma, centro della figura a 0,2 pixel; guardia nuova la_scena_della_stesa_e_un_filmato rossa su 7 innesti su 7; sul Realme, livello dell'app 0 fotogrammi persi su 629, 634 e 640, a scatti 0, 0 e 1; scena prima e dopo l'uscita dall'app, scarto medio 0,063 su 255; traccia audio del video attiva a 0 dB con la suoneria normale

## VOCE FS.13

**APERTA IN ATTESA DI VERIFICA.** La Croce Celtica si riscatta intera, con un riscatto solo da 400 Eos che ridà le sue dieci carte, invece di quattro riscatti da tre carte per 600 Eos. Il prezzo sta sul server (il riscatto `steseDieci` in `functions/src/borsellino.ts`) e l'app lo offre solo se il listino del server lo porta: finche' le funzioni non sono pubblicate l'app nuova resta sulla strada di prima, 600 Eos con un consenso solo.

ASPETTA: il fondatore, che pubblica le due funzioni: cd functions && firebase deploy --only functions:statoDelCerchio,functions:muoviGliEos --project esoteric-circle. La pubblicazione delle funzioni e' negata a Code.
DOMANDA: "2 400 EOS"
PROVA: test/il_riscatto_copre_la_croce_celtica_test.dart
MISURA: Croce Celtica a carte esaurite da 600 Eos in 4 riscatti a 400 Eos in 1 riscatto, carte ridate 10; prove del server (npm test) 225 su 225, rossa col prezzo innestato a 600; guardia dell'app rossa sul codice di prima (+7 -3) e verde (+10)
