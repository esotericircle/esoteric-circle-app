# MANIFESTO DELL'ORDINE FM, IL CORPUS POSIZIONALE DEI TAROCCHI PASSA A CODE

Testo dell'ordine: `docs/ordini/ORDINE_FM_TESTO.md`. Rapporto: `docs/ordini/RAPPORTO_ORDINE_FM.md`.

Una voce per ciascuna delle sette voci dell'ordine. La premessa P1 era sbagliata in un punto: non nominava `dietro.md`, la quinta carta della Croce Celtica, vuota a 468 righe su 468 dall'ordine FK voce 8; i testi da scrivere erano quindi 3.276 e non 2.808 e le posizioni che tenevano chiusa la stesa a dieci carte quattro e non tre. `dietro` sta nella voce FM.02. Una voce CHIUSA porta sotto di sé DOMANDA, PROVA e MISURA.

VOCI_TOTALI: 7
VOCI_CHIUSE: 7
VOCI_APERTE: 0
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
MISURA: scheletri nel Dart da 4.212 a 7.020 su 7.020, registri da 0 a 468 su 468; la guardia `il_corpus_delle_posizioni` conta con `cardinaleMinimo` i testi dichiarati, da 4.212 a 7.020; spinte sul ramo a ogni pezzo finito 3

## VOCE FM.07

**CHIUSA.** Nessuna build di iniziativa.

DOMANDA: "Finito il lavoro, si riferisce cosa e' pronto e si attende il suo ordine. Nessuna build di iniziativa."
PROVA: docs/ordini/RAPPORTO_ORDINE_FM.md
MISURA: build costruite 0; numero della versione nel pubspec cambiato 0
