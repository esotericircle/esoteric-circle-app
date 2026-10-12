# MANIFESTO DELL'ORDINE FM, IL CORPUS POSIZIONALE DEI TAROCCHI PASSA A CODE

Testo dell'ordine: `docs/ordini/ORDINE_FM_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FM.md`.

Una voce per ciascuna delle sette voci dell'ordine, e da FM.08 a FM.14 le richieste del fondatore in chat del 12 ottobre 2026, dopo la consegna (l'aggiunta 1). La premessa P1 era sbagliata in un punto: non nominava `dietro.md`, la quinta carta della Croce Celtica, vuota a 468 righe su 468 dall'ordine FK voce 8; i testi da scrivere erano quindi 3.276 e non 2.808 e le posizioni che tenevano chiusa la stesa a dieci carte quattro e non tre. `dietro` sta nella voce FM.02. Una voce CHIUSA porta sotto di sé DOMANDA, PROVA e MISURA.

VOCI_TOTALI: 14
VOCI_CHIUSE: 12
VOCI_APERTE: 2
VOCI_DA_FARE: 0

## VOCE FM.01

**CHIUSA.** Le varianti 2 e 3 di passato, presente e futuro.

DOMANDA: "Adesso ho il problema di finire i corpus e mi stavo chiedendo se poteva concludere Code il lavoro al tuo posto."
PROVA: docs/corpus/tarocchi_posizione/schedario_passato.md
MISURA: righe vuote in passato, presente e futuro da 936 a 0 (936 testi nuovi, nessuno che cominci come la variante 1 della stessa carta); testi della variante 1 del futuro senza il tu da 2 a 0; lettori ciechi che riconoscono la posizione contro la gemella, due giri: passato 10 e 10 su 10, presente 10 e 10, futuro 9 e 10

## VOCE FM.02

**CHIUSA.** Le quattro posizioni intatte della Croce Celtica: te stesso, la casa, speranze o timori e, per la premessa sbagliata, il dietro.

DOMANDA: "Adesso ho il problema di finire i corpus e mi stavo chiedendo se poteva concludere Code il lavoro al tuo posto."
PROVA: docs/corpus/tarocchi_posizione/schedario_dietro.md
MISURA: righe vuote in se_stesso, la_casa, speranze_o_timori e dietro da 1.872 a 0; posizioni senza fonte da 4 a 0; lettori ciechi, due giri: te stesso 10 e 10 su 10, la casa 10 e 10, speranze o timori 10 e 10, dietro 10 e 10; la Croce Celtica resta chiusa per il tavolo (dieci carte in piedi larghe 26 punti a 360), non più per i testi

## VOCE FM.03

**CHIUSA.** I registri delle carte, coi tre gruppi.

DOMANDA: "Adesso ho il problema di finire i corpus e mi stavo chiedendo se poteva concludere Code il lavoro al tuo posto."
PROVA: docs/corpus/tarocchi_posizione/schedario_registri.md
MISURA: registri da 0 a 468 su 468 (amore, lavoro, vita per 156 carte-verso, fra 60 e 220 caratteri); `registriConsegnati` da falso a vero; lettori ciechi che riconoscono l'ambito fra tre, due giri: 10 e 10 su 10

## VOCE FM.04

**CHIUSA.** Il controllo della seconda persona, visto rosso prima e i testi riparati.

DOMANDA: "aggiungere a controlla_testo, in tool/genera_carte_nella_posizione.py, il controllo che ogni testo si rivolga alla persona col tu"
PROVA: docs/collaudo/FM/fm04_regola_a.txt
MISURA: innesti rossi 2 su 2 ("tua" che diventa "sua", "hai" che diventa "ha", entrati verificati col grep, file tornati al byte); testi già scritti senza il tu 311 su 4.212 (carta sola 169, esito 134, lato 4, futuro 2, consultante 2), riparati: da 311 a 0 e 0 su 7.020 a corpus intero

## VOCE FM.05

**CHIUSA.** Lo schedario di ogni posizione, nel repo, scritto prima dei testi, con la sua soglia.

DOMANDA: "Eventuali modifiche, adattamenti e miglioramenti li decide Code"
PROVA: docs/collaudo/FM/lettori_ciechi/esito_1.txt
MISURA: schedari da 0 a 8 (sette posizioni e i registri), righe carta per carta da 0 a 1.248; soglia decisa da Code, otto su dieci testi riconosciuti in due giri con campioni diversi: giro 1 79 su 80, giro 2 80 su 80, nessuna prova sotto 9 su 10

## VOCE FM.06

**CHIUSA.** Il Dart rigenerato a ogni posizione finita e la guardia che conta i testi col suo cardinale minimo.

DOMANDA: "finita ogni posizione, rilanciare python tool/genera_carte_nella_posizione.py e verificare che lib/core/tarot/le_carte_nella_posizione_dati.dart porti i testi nuovi, non la mappa vuota"
PROVA: lib/core/tarot/le_carte_nella_posizione_dati.dart
MISURA: scheletri nel Dart da 4.212 a 7.020 su 7.020, registri da 0 a 468 su 468; la guardia `il_corpus_delle_posizioni` conta con `cardinaleMinimo` i testi dichiarati, da 4.212 a 7.020; spinte sul ramo a ogni pezzo finito 4

## VOCE FM.07

**CHIUSA.** Nessuna build di iniziativa.

DOMANDA: "Finito il lavoro, si riferisce cosa e' pronto e si attende il suo ordine. Nessuna build di iniziativa."
PROVA: docs/ordini/RAPPORTO_ORDINE_FM.md
MISURA: build costruite 0; numero della versione nel pubspec cambiato 0

## VOCE FM.08

**APERTA IN ATTESA DI VERIFICA.** Il Sigillo del Sogno dirada la nebbia solo con l'aria, riconosciuta come il Soffio del Destino, e sopra il fondo della stanza. Manca la prova del fiato vero sul telefono.

DOMANDA: "nei doni del giorno, il microfono del sigillo della notte è troppo sensibile e "diradare la nebbia" si sblocca con solo la musica di sottofondo o un leggero rumore  di fondo"
PROVA: test/il_sigillo_si_dirada_solo_con_l_aria_test.dart
MISURA: finestre che diradano la nebbia, col volume di prima e adesso: musica di sottofondo da 62 a 0, voce alla radio da 62 a 0, canzone che parte dopo la quiete da 63 a 0, ventilatore da 93 a 0; fiato dopo la quiete da 47 a 43, fiato sopra il ventilatore da 47 a 43

## VOCE FM.09

**APERTA IN ATTESA DI VERIFICA.** Il Soffio del Destino un poco più sensibile, e lo stesso parametro nel Sigillo del Sogno. Manca la prova del fiato vero sul telefono.

DOMANDA: "Il soffio del destino, invece, è troppo difficile. Aumenta la sensibilità del soffio di poco e usa lo stesso parametro per il sigillo del sogno."
PROVA: lib/core/rituals/forma_del_soffio.dart
MISURA: energia minima da 0,0025 a 0,0018; planarità minima da 0,15 a 0,12 (la voce misurata a 0,05); finestre di fila da 6 a 5 (da 192 a 160 millisecondi); suoni che non sono soffi aperti dalla forma 0 su 3 prima e dopo; soffi riconosciuti 3 su 3 prima e dopo

## VOCE FM.10

**CHIUSA.** La luna della home apre il cielo di adesso, con un pulsante sottile "Attiva macchina del tempo" che porta i selettori della data.

DOMANDA: "1 "il cielo di adesso" va inserito in home sostituendo l'attuale "il cielo sopra di te adesso" (credo sia solo un cambio link collegamento), ma vorrei che all'interno della schermata del cielo in tempo reale aggiungessi un pulsante in basso sottile "attiva macchina del tempo" dove al click compaiono i selettori di data della macchina del tempo."
PROVA: docs/collaudo/FM/aggiunta_1/a1_il_cielo_in_quattro_momenti.png
MISURA: schermata aperta dalla luna da SkyOverviewScreen a CieloRealeScreen in modo adesso; pulsante sottile da 0 a 1, alto al più 44 punti; selettori della data prima del tocco 0, dopo il tocco 1 (giorno scelto, luogo, Viaggia nel tempo, pannello)

## VOCE FM.11

**CHIUSA.** Il cielo della tua nascita del cielo reale nel Cosmic Passport, e nella carta d'identità che apriva lo stesso cielo di prima.

DOMANDA: "2 "il cielo della tua Nascita"  va sostituito nel Cosmic Password."
PROVA: test/il_cielo_reale_prende_il_posto_test.dart
MISURA: ingressi al cielo di nascita sul cielo di prima da 2 (Cosmic Passport, carta d'identità) a 0, sul cielo reale da 0 a 2

## VOCE FM.12

**CHIUSA.** La macchina del tempo nell'onboarding, dove si rivela il cielo di nascita, dalla nascita appena scritta.

DOMANDA: "La macchina del tempo va inserita e sostituita nell'onboarding, quando viene rivelato il cielo di nascita, dopo che l'utente ha inserito i dati di nascita."
PROVA: docs/collaudo/FM/aggiunta_1/a1_04_l_onboarding_la_macchina_dalla_nascita.png
MISURA: fase del cielo del Risveglio da SkyOverviewScreen a CieloRealeScreen in modo macchina del tempo; giorno di partenza dal dato appena scritto (3 marzo 1985 nella prova), non dal profilo; "Leggi la tua carta" porta avanti l'onboarding 1 su 1 (onboarding_ordine_test verde)

## VOCE FM.13

**CHIUSA.** La voce Real Time Cosmo tolta dal menu utente, col suo menu temporaneo.

DOMANDA: "Dopo puoi eliminare il menù RealTime Cosmo dal menù utente."
PROVA: test/le_anteprime_dell_ordine_fg_test.dart
MISURA: voci Real Time Cosmo nel menu utente da 1 a 0; file del menu temporaneo (real_time_cosmo_screen.dart) da 1 a 0

## VOCE FM.14

**CHIUSA.** Le anteprime della stesa a quattro carte e della Croce Celtica a dieci, coperte e scoperte.

DOMANDA: "Vorrei vedere anche qualche anteprima della funzionalità tarocchi, della stesa a 4 carte e della stesa croce Celtica a 10 carte con le carte coperte e scoperte."
PROVA: docs/preview/FL/fl_croce_e_croce_celtica.png
MISURA: anteprime mandate 4 su 4 (croce coperta, croce scoperta, Croce Celtica coperta, Croce Celtica scoperta); larghezza di una carta della Croce Celtica in piedi 26 punti a 360, illeggibile: la Croce Celtica resta chiusa
