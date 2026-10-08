# ORDINE FF, GLI ENIGMI DEL CERCHIO

**Sigla:** FF, libera sul ramo canonico. **Data dell'ordine:** 7 ottobre 2026,
in tre pezzi, con l'aggiunta 1 dell'8 ottobre (i corpora marcati e la Soglia
del Sonno). **Ramo:** `claude/esoteric-circle-master-order-e798aj`, nessun
altro. **Partenza:** commit `d483eae6`; i commit dell'ordine sono
`git log d483eae6..HEAD`. Il testo del fondatore alla lettera sta in
`docs/ordini/ORDINE_FF_TESTO.md`, e ogni DOMANDA qui sotto viene da li'.

**Regole in primo piano.** R1 ogni voce dichiara la sua fonte; R2 le premesse
si abbattono con la misura; R3 si enumera, non si campiona; R4 e R5 le
Regole A e B (gli innesti in `docs/collaudo/FF/regola_a_ff.txt`, F1-F43); R6
ogni affermazione visiva e' una cattura o una misura; R7 nessun rosso si
consegna; R8 niente dati di produzione; R9 il manifesto coi marcatori, la
guardia e il sigillo; R10 nessuna credenziale in chat; R11 prima di scrivere
si misura cio' che esiste; **R12 costo AI zero**: nessuna voce chiama un
modello; **R13 nessun testo libero**.

**Le voci.** Le nove dell'ordine sono FF.01-FF.09. Le undici dell'aggiunta 1,
che il fondatore chiama FF.A1-FF.A11, sono qui FF.10-FF.20 nello stesso
ordine (FF.10 e' la A1, FF.20 la A11): il lettore dei manifesti riconosce
una voce dal suo numero. La A12 dice cosa non fare e non e' una voce.

VOCI_TOTALI: 20
VOCI_CHIUSE: 13
VOCI_APERTE: 7
VOCI_DA_FARE: 0

**Perche' sette restano aperte, e cosa le chiude.** L'8 ottobre il
fondatore ha pubblicato le funzioni e il collaudo sul Realme col server
vero ha chiuso il Ritratto (FF.02) e la Prova (FF.05), e ha trovato cinque
difetti, curati lo stesso giorno (titoli tagliati dalla freccia, riga del
Ritratto muta al lettore di schermo, cursore che diceva per cento,
"restano 1 giorno", seconda sfida verso chi ne ha gia' una aperta); le
correzioni sono viste nelle anteprime, non sul telefono, perche' il
fondatore ha scelto "Niente build per ora". Restano aperte: Chi del Cerchio
e gli indizi (FF.03, FF.04, e la cattura 06 della FF.20), che vogliono
quattro persone del Cerchio col Ritratto compilato, e il profilo di
collaudo ha due amici, nessuno col Ritratto; la presenza (FF.01), che vuole
due telefoni accesi insieme; il Pellegrinaggio, che si apre il 19 ottobre,
e la sfida scaduta che si chiude alla prima lettura, il 9 ottobre (FF.06,
FF.07); le push su iPhone (FF.09), che vogliono la build iOS di Codemagic.
La seconda sfida rifiutata dal server vuole un secondo deploy delle
funzioni.

## LE SCELTE DEL FONDATORE

- 8 ottobre 2026: *"Se puoi correggi tu errori e difetti dell'architetto,
  non posso continuare a fare 10 ordini per ogni lavoro"*. Supera la A12
  ("non riscrivere i testi dei due corpora"): i difetti trovati sono corretti
  (FF.10).
- 8 ottobre 2026, alla domanda sul giro dei banchi col modello che il
  cancello della consegna pretende (5,51 dollari l'ultimo, il 7 ottobre):
  "Niente build per ora".

## LE PREMESSE ABBATTUTE

- **"Senza limite dall'Adepto in su"** (FF.04.5, FF.05.3): l'ordine CE voce
  08 ha tolto ogni illimitato (`functions/src/budget.ts:41`, "illimitato mi
  espone all'abuso o uso incontrollato o bot"). Tetti ampi: indovinelli 3,
  10, 50, 150; scommesse 1, 3, 15, 45 (`functions/src/gli_enigmi.ts`).
- **"In grigio o semitrasparenza ... come le altre arti non ancora vive"**
  (FF.A8): le altre arti in arrivo hanno l'immagine piena con la clessidra
  dorata, per scelta scritta (`lib/core/arts/art_catalog.dart:56`, "mai un
  velo che le renda illeggibili"). La Soglia e' come le altre.
- **"Il testo che iOS mostra dentro la finestra di sistema"** (FF.09.4): iOS
  non lascia testo all'app nella finestra delle notifiche; la frase sta nel
  foglio che la precede.
- **P1 e P2**: vere come dette, i file stavano solo nella cartella
  principale. **P3**: il dizionario della guardia del genere non conosceva
  "una parola sola", ne conosce 43 dopo un verbo di seconda persona: vedeva
  7 dei 34 testi marcati (`docs/collaudo/FF/genere/p3_il_dizionario_della_guardia.txt`).
- **"I corpora sono a zero virgole"** (messaggio dell'8 ottobre): ne
  restavano due per file, a capo riga; e il conteggio in fondo al Ritratto
  non era corretto. Sistemati dall'Architetto nella versione delle 00:52.

## VOCE FF.01, LA PRESENZA NON SI SPEGNE IN SECONDO PIANO

**APERTA IN ATTESA DI VERIFICA.** Finestra di cinque minuti
(`functions/src/presenza.ts`); il telefono che va sullo sfondo fa scrivere
l'ora dell'uscita (`scriviLUscita`) invece di togliere la presenza. La
chiude il deploy delle funzioni e il collaudo con due telefoni.

DOMANDA: "se l'utente mette l'app in background il conto degli utenti online scende: credo che fino a quando l'app è aperta anche in background, quell'utente deve risultare online"
PROVA: functions/src/presenza.test.ts e test/chi_esce_dal_cerchio_esce_dal_conto_test.dart
MISURA: finestra 90 -> 300 secondi; scritture di una sessione di dieci minuti 12 prima e 12 dopo; numero letto da B con l'altro sullo sfondo 2, 1, 1, 2 prima e 2, 2, 2, 2 dopo; sullo sfondo da 4 minuti online, da 6 no
ACCETTAZIONE: so che il codice c'e' e quando si vede sul telefono

## VOCE FF.02, IL RITRATTO

**CHIUSA.** Sul Realme, l'8 ottobre col server vero, le otto proposte
dalla carta, poi le altre dodici fino a venti, il pulsante acceso solo a
venti, il Ritratto scritto dalla porta ilMioRitratto e i giochi aperti
subito dopo. Visti li' due difetti, curati e provati nelle anteprime: la
riga muta al lettore di schermo e il titolo tagliato. Venti caratteristiche
fra le 120 del corpus, otto proposte dalla carta (Sole, Luna, Ascendente, giorno di
nascita), si chiude solo a venti, si cambia dal profilo, il server lo
restituisce solo a chi lo possiede e fotografa quello del gioco
all'apertura.

DOMANDA: "Ogni persona ha un Ritratto: venti caratteristiche scelte da una lista di centoventi"
PROVA: docs/collaudo/FF/realme/09_il_ritratto_venti_scelte.png
MISURA: sul telefono scelte 8 -> 20 e pulsante spento -> acceso, Ritratto scritto 1 su 1, giochi chiusi -> aperti (10_enigmi_dal_server.png); righe che dicono se sono scelte 0 -> 20 (prova b, innesto F46); proposte 8 su 8 deterministiche, 0 libere; carte diverse 2 su 2 proposte diverse; Ritratto con 19 caratteristiche 0 chiusure; letture del Ritratto sul server 5, tutte dello stesso uid; anteprime 01 e 02
ACCETTAZIONE: so che il Ritratto e' fatto e quando lo vedo sul telefono

## VOCE FF.03, IL MOTORE DEGLI INDIZI

**APERTA IN ATTESA DI VERIFICA.** Sul Realme non si gioca: servono quattro
persone del Cerchio col Ritratto compilato, il profilo di collaudo ne ha 0
(11_chi_del_cerchio_senza_quattro_ritratti.png). Una porta sola, `functions/src/gli_indizi.ts`:
fonti in elenco chiuso senza comportamenti, primo indizio gratis poi 5 Eos
in transazione col saldo nuovo nella risposta, punti 3/2/1/0,5.

DOMANDA: "andare a tentativi non ha senso ed è frustrante, ci vorrebbero degli indizi, una sorta di caccia al tesoro"
PROVA: functions/src/gli_indizi.test.ts e test/gli_indizi_hanno_una_porta_sola_test.dart
MISURA: costi degli indizi 0, 5, 5 Eos; punti 3, 2, 1, 0,5; fonti 5, di comportamento 0; porte che chiedono un indizio 1 (Chi del Cerchio)
ACCETTAZIONE: so come costano gli indizi e quanto valgono

## VOCE FF.04, CHI DEL CERCHIO

**APERTA IN ATTESA DI VERIFICA.** Sul Realme il server risponde "Servono
quattro persone del tuo Cerchio col Ritratto compilato: per ora ne trovo
0": il profilo di collaudo ha due amici, nessuno col Ritratto. La chiude
una partita con quattro profili col Ritratto. Quattro volti fra chi ha il Ritratto e
non si e' tolto, la domanda da un dato vero che appartiene a uno solo, il
risultato subito; all'indovinato il numero e i segni (20 Eos l'uno), mai il
nome; l'interruttore nel Ritratto e nel profilo; limiti 3/10/50/150.

DOMANDA: "il gioco indovina chi, indovina chi è l'archetipo di un utente, oppure chi è il mago del cerchio secondo te"
PROVA: functions/src/gli_enigmi.test.ts e test/gli_enigmi_a_video_test.dart
MISURA: su un Cerchio di otto con tre fuori dai giochi, 0 apparizioni in 200 partite; identificativi nel ritorno 0; domande con la risposta di uno solo 40 su 40; anteprime 03, 04, 05
ACCETTAZIONE: so che il gioco c'e' e che nessun nome viaggia

## VOCE FF.05, LA PROVA

**CHIUSA.** Sul Realme, l'8 ottobre col server vero: le dieci domande
della settimana di "Quello che comincia", il punteggio 57 calcolato dal
server con la figura Il Sentiero, il punteggio nella pagina degli Enigmi e
una scommessa di 62 su Collaudo Due registrata. Visti li' due difetti,
curati e provati nelle anteprime: il cursore che diceva "50%" al lettore di
schermo, e la pagina del risultato senza un'azione (adesso "Sfida i tuoi
amici", anteprima 10). Il tema dal cielo del lunedi' con la porta di Meeus, dieci domande della settimana, il punteggio calcolato dal
server coi pesi del corpus, la figura della fascia, la scommessa finche'
l'amico non l'ha fatta.

DOMANDA: "proponiamo al cerchio un test di personalità il cui punteggio determina la personalità o altra caratteristica dell'utente, e gli altri prima di scoprire il punteggio devono indovinarlo"
PROVA: docs/collaudo/FF/realme/13_la_prova_il_punteggio_dal_server.png
MISURA: sul telefono risposte 10 su 10, punteggio dal server 1 (57, Il Sentiero), scommesse registrate 0 -> 1 (15_la_scommessa_registrata.png); quattro settimane del 2026 con quattro temi diversi (1, 2, 4, 5); punteggio di dieci risposte uguale due volte (57); scommessa dopo la Prova 0 piazzate; settimane del 2026 lette 52; anteprime 06 e 07
ACCETTAZIONE: so che la Prova cambia col cielo e quando la vedo

## VOCE FF.06, LE SFIDE

**APERTA IN ATTESA DI VERIFICA.** Sul Realme col server vero: la sfida a
Collaudo Due aperta per ventiquattro ore e la classifica di chi conosce il
Cerchio (17_la_sfida_aperta.png). Visto li' un difetto: con la sfida aperta
il pulsante restava e ogni tocco ne apriva un'altra, con un'altra notifica;
curato sul telefono e sul server (`sfidaGiaAperta`, innesti F48 e F49), e
la parte del server vuole un secondo deploy. Il Pellegrinaggio si apre il
19 ottobre. Nessuna classifica sulle qualita', il
Pellegrinaggio per ogni piano con la barra di ciascuno (un passo al giorno
per rito, meta che nessuno raggiunge da solo), la classifica dentro il
Cerchio, la sfida a due dall'Iniziato per ventiquattro ore.

DOMANDA: "le sfide, perché funzionano sempre, ma bisogna sviluppare tutto, accetto proposte"
PROVA: test/gli_enigmi_rispettano_le_regole_test.dart e functions/src/gli_enigmi.test.ts
MISURA: righe con classifica e qualita' 0; barra 4, 3, 2, 1 e 10 mancanti; meta da soli 15 contro 7 passi possibili; sfida scaduta col punto a chi ha giocato 1 su 1; anteprime 08 e 09
ACCETTAZIONE: so che le sfide giudicano i gesti e non le persone

## VOCE FF.07, I TEMPI

**APERTA IN ATTESA DI VERIFICA.** Sul Realme la Prova dice "Finisce fra 3
giorni e 16 ore" e la sfida il suo tempo; li' diceva "restano 1 giorno",
curato in "finisce fra". La sfida a Collaudo Due scade il 9 ottobre: la
chiude la prima lettura dopo, e il Pellegrinaggio il 19. Ogni gioco aperto dice quanto gli resta;
la sfida scaduta si chiude alla prima lettura; la luna piena del
Pellegrinaggio e' il passaggio dell'opposizione, non l'inizio dell'evento
dei Doni.

DOMANDA: "Nessun gioco si ferma in attesa che una persona apra l'app."
PROVA: test/i_tempi_dei_giochi_test.dart e test/gli_enigmi_a_video_test.dart
MISURA: giochi aperti col tempo che resta 3 su 3 (Prova, sfida, Pellegrinaggio); luna piena di ottobre 2026 il 26 contro il 24 della prima stesura
ACCETTAZIONE: so che ogni gioco dice il suo tempo

## VOCE FF.08, LE CONTRADDIZIONI DICHIARATE

**CHIUSA.** Quattro verdetti (CAMBIA_DICHIARANDO separato da CONTRADDICE),
soglia di due a tradimento per percorso, scritta nella taratura del giudice.
Per la R12 i giri non si rigiudicano: riclassificazione senza modello dei
61 giri gia' giudicati.

DOMANDA: "Il giudice dei banchi del filo, senza sapere cosa stiamo misurando, divide le contraddizioni in due"
PROVA: docs/collaudo/FF/le_contraddizioni_dichiarate.txt
MISURA: 137 contraddizioni su 3560 risposte, dichiarate col perche' 0, col solo annuncio 7, a tradimento 137; percorsi oltre due 4 su 356 con qualunque conto
ACCETTAZIONE: so i due numeri e la soglia nuova

## VOCE FF.09, LE NOTIFICHE PUSH SU IPHONE

**APERTA IN ATTESA DI VERIFICA.** `aps-environment` production, il modo in
sottofondo per la spinta silenziosa, il recapito riletto al si' del
permesso e dopo il recapito APNs, la frase del fondatore nel foglio prima
della finestra di sistema. La chiude la build iOS di Codemagic, che parte
solo a mano.

DOMANDA: "la build iOS non ha l'autorizzazione aps-environment, quindi sull'iPhone le notifiche push non si registrano"
PROVA: test/le_push_arrivano_su_iphone_test.dart e test/le_push_sono_montate_test.dart
MISURA: pezzi della catena presenti 3 su 3; innesti rossi 8 su 8 (F5-F11, F42); recapito riletto al si' del permesso 1 su 1
ACCETTAZIONE: so cosa manca perche' la notifica arrivi davvero

## VOCE FF.10, I DUE CORPORA MARCATI NEL WORKTREE

**CHIUSA.** Copiati e confrontati al byte; corretti i difetti trovati (il
neutro di 37, 100 e 119, il "che" delle fasce 0-25 dei temi 3 e 4, tre
marche a capo riga) e riallineati nella cartella principale.

DOMANDA: "Copia nel worktree, in docs/corpus/, questi due file"
PROVA: docs/collaudo/FF/i_corpora_e_gli_asset.txt
MISURA: sha256 dell'Architetto 5a1ce252 e 8e0a3647, uguali al byte; difetti corretti 7; dopo la correzione cartelle uguali al byte 2 su 2
ACCETTAZIONE: so quali file uso e cosa ho cambiato

## VOCE FF.11, LA MARCA DEL GENERE, LA REGOLA

**CHIUSA.** Una porta sola, `IlTestoDegliEnigmi`: la forma dichiarata a chi
compila o fa la Prova, il neutro in ogni indizio. Nessun terzo caso.

DOMANDA: "quando un tratto esce come indizio su un'altra persona, si prende SEMPRE il neutro"
PROVA: test/il_genere_non_si_indovina_test.dart
MISURA: tratto 21 a una donna "quella", a un uomo "quello", come indizio "la persona" con 4 forme correnti su 4
ACCETTAZIONE: so dove si sceglie la forma

## VOCE FF.12, LA GUARDIA DEL GENERE

**CHIUSA.** La guardia legge la marca: cinque prove nuove, viste rosse.

DOMANDA: "il suo dizionario non conosce le altre forme"
PROVA: test/il_genere_non_si_indovina_test.dart
MISURA: innesti rossi 4 su 4 (F16-F19); marche nei corpora 37, malformate 0; testi dei corpora risolti 504 in 4 forme, marche rimaste 0
ACCETTAZIONE: so che una marca rotta non arriva a video

## VOCE FF.13, LA RIGENERAZIONE

**CHIUSA.** Rigenerati col generatore, contati.

DOMANDA: "Rigenera con il tuo generatore e dichiara nel manifesto, contati e non stimati"
PROVA: docs/collaudo/FF/il_conto_dei_corpora.txt
MISURA: Ritratto 120 tratti, fuoco 27, terra 32, aria 26, acqua 30, libere 5, 12 marcati, 13 marche; Prove 6 temi, 12 domande, 48 risposte, 4 fasce per tema, 288 pesi, 22 marche (2, 2, 3, 4, 3, 8)
ACCETTAZIONE: so che i numeri tornano con quelli dell'Architetto

## VOCE FF.14, I TRE ASSET NEL WORKTREE

**CHIUSA.** Copiati e confrontati al byte, misure giuste, nessun testo
dentro le immagini.

DOMANDA: "Copia nel worktree, in assets/schede/, questi tre file"
PROVA: docs/collaudo/FF/i_corpora_e_gli_asset.txt
MISURA: sha256 928c6b4b, 4d133751, e0514044, uguali al byte 3 su 3; misure 800x1000, 800x800, 1280x720
ACCETTAZIONE: so che le immagini sono quelle del fondatore

## VOCE FF.15, L'ARTE NUOVA NEL DOMINIO DI AURA

**CHIUSA.** `soglia_del_sonno` nel catalogo, nella sezione Energia di Aura
dopo le Sleep Stories, nella stessa forma delle altre (id, titolo, teaser,
icona, stato, fase, cornice; nessun campo sottotitolo: la descrizione e' il
teaser, sul retro della scheda). Vista sul Realme col pacchetto locale 2302
l'8 ottobre 2026.

DOMANDA: "serve mini ordine aggiuntivo per code per aggiungerlo alla home e al dominio di Aura"
PROVA: docs/collaudo/FF/soglia_del_sonno/03_il_dominio_di_aura.png
MISURA: dominio di Aura in Energia 1 su 1, sul telefono dopo le Sleep Stories; arti di Aura 24 -> 25
ACCETTAZIONE: so dove sta l'arte e quando la vedo

## VOCE FF.16, LA SCHEDA IN HOME

**CHIUSA.** Nella riga La tua serenità, accanto alle Sleep Stories, coi tre
sfondi scelti dal formato della riga come per tutte: orizzontale in home,
verticale in Vedi tutto e nel dominio. Vista sul Realme.

DOMANDA: "La scheda entra nella categoria La tua serenità della home"
PROVA: docs/collaudo/FF/soglia_del_sonno/01_la_riga_della_home.png
MISURA: arti in home 67 -> 68; titoli composti 201 -> 204; catture dal Realme 2 su 2
ACCETTAZIONE: so dove la trovo in home

## VOCE FF.17, LO STATO COMING SOON

**CHIUSA.** In arrivo, Fase 3, con la clessidra dorata; al tocco si gira e
dice "In arrivo, Fase 3", nessuna pagina. Senza velo grigio, come le altre
(premessa abbattuta). Visto sul Realme.

DOMANDA: "La scheda si vede, è disabilitata, in grigio o semitrasparenza, con la clessidra dorata in alto a sinistra"
PROVA: docs/collaudo/FF/soglia_del_sonno/02b_al_tocco_in_arrivo_fase_3.png
MISURA: pagine aperte al tocco 0 sul telefono e nella prova; clessidra 1 su 1
ACCETTAZIONE: so che si vede e non apre niente

## VOCE FF.18, I CENSIMENTI

**CHIUSA.** Ogni censimento trovato da P6 aggiornato col numero prima e
dopo; `docs/stato_asset.json` non conta `assets/schede` e non cambia.

DOMANDA: "Iscrivi l'arte nuova in ogni censimento trovato dalla P6"
PROVA: test/gli_sfondi_delle_schede_test.dart
MISURA: WebP 246 -> 249, usati 240 -> 243, sfondi 67 -> 68, arti in home 67 -> 68, titoli 201 -> 204, censimenti aggiornati 7
ACCETTAZIONE: so che nessun conto resta falso

## VOCE FF.19, LE GUARDIE DELLA SCHEDA

**CHIUSA.** Sei prove nuove, viste rosse.

DOMANDA: "Guardie nuove, ciascuna vista rossa prima della cura"
PROVA: test/la_soglia_del_sonno_test.dart
MISURA: innesti rossi 5 su 5 (F20-F24); sfondi uguali al fondatore 3 su 3
ACCETTAZIONE: so che la scheda e' sorvegliata

## VOCE FF.20, LA PROVA DI VISTA

**APERTA IN ATTESA DI VERIFICA.** Le catture 01, 02 e 03 vengono dal
Realme col pacchetto locale 2302 (piu' la 02b, il tocco). Le 04, 05 e 06
no: sul Realme il genere si dichiara solo nell'onboarding, e rifarlo
cancellerebbe i dati del telefono di collaudo (571 momenti custoditi), e la
06 vuole una partita vera, quindi il deploy. Dal Realme c'e' la forma che
il profilo di collaudo ha, il neutro (07); la 04 (donna), la 05 (uomo) e la
06 (indizio) sono anteprime a 360x797 della stessa schermata. Sul Realme si
e' visto anche un difetto, il codice "NOT_FOUND" a video con la porta non
pubblicata, curato (00).

DOMANDA: "il giudizio visivo e' mio"
PROVA: docs/collaudo/FF/genere/07_sul_realme_il_profilo_senza_genere_legge_il_neutro.png
MISURA: catture dal telefono 3 su 6 (01, 02, 03), anteprime 3 su 6 (04, 05, 06); il neutro sul telefono 1 (07)
ACCETTAZIONE: so quali catture mancano e perche'
