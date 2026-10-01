# ORDINE EV, I RILIEVI DEI FONDATORI, I PREZZI E LA VERIFICA DEI TESTI

**Sigla:** EV, verificata sul ramo sul commit `0f7a0625`: in `docs/ordini`
l'ultimo manifesto era `ORDINE_EU_MANIFESTO.md` e non esisteva `ORDINE_EV`;
in `docs/collaudo` non esisteva la cartella EV. **Data dell'ordine:** 2
ottobre 2026 (il lavoro e' del 1 ottobre sul calendario del PC).
**Ramo:** `claude/esoteric-circle-master-order-e798aj`, nessun altro.
**Partenza:** commit `0f7a0625`, col segno `refs/verde/0f7a0625...` presente.

**Il pezzo 2 non e' arrivato.** L'ordine diceva "PEZZO 1 DI 2 [...] Il pezzo
2 porta le voci dell'Architetto"; il fondatore ha scritto "Hai già tutto
l'ordine". Le voci EV.07 e EV.08 (fra cui la prosecuzione di EU.14, che nel
manifesto EU ha la riga "Prosegue nell'ordine EV, voce EV.08") non sono in
questo manifesto perche' nessuno le ha scritte: si aggiungono quando arrivano.

**La regola 6 ("questo ordine non consegna niente") e' superata dal
fondatore** in coda al pezzo 1: "Alla fine di tutto, crea nuova Build, test su
Cell e consegna su AppTester e dimmi quando posso lanciare codemagic".

Le voci EV.51-EV.57 sono le segnalazioni del fondatore arrivate durante il
lavoro, numerate da Code dopo il posto delle voci dell'Architetto.

VOCI_TOTALI: 13
VOCI_CHIUSE: 4
VOCI_APERTE: 9
VOCI_DA_FARE: 0

Le prove stanno in `docs/collaudo/EV/`, quelle del telefono di prova (Realme
767f596c) in `docs/collaudo/EV/realme/`. **Le catture del Realme vengono da
una build di collaudo** costruita dallo stesso commit con
`--dart-define=CATTURE_PERMESSE=true`: dalla voce EV.56 la build consegnata
protegge lo schermo e le catture escono nere.

## VOCE EV.01, TUTTI I PREZZI A 99

**CHIUSA.** Iniziato 2,99, 9,99 e 99,99; Adepto 4,99, 19,99 e 189,99;
Illuminato 6,99, 29,99 e 279,99 (`lib/core/entitlement/plan_catalog.dart`), gli
sconti annuali ricalcolati e detti a video (17, 21 e 22 per cento, al mese
8,33, 15,83 e 23,33). Sul Realme la casella diceva "SETTIM..." e "189,99" con
l'euro a capo: corretto nella stessa voce, nome e prezzo stanno interi su una
riga (`test/i_prezzi_dei_piani_stanno_interi_test.dart`). L'elenco dei
prodotti da impostare negli store sta nel rapporto: nel codice non c'e'
nessun prodotto degli store, i nomi sono una proposta.

DOMANDA: "Gli abbonamenti e quindi foni riferimento sono cambiati in 2,99 - 9,99 - 19,99 - 29,99"; domanda girata al fondatore: "Li porto anche loro a ,99 (4,99, 6,99, 99,99, 189,99, 279,99)?", risposta: "Si, tutto a 99".
PROVA: docs/collaudo/EV/realme/ev01_adepto_prezzi_interi.png
MISURA: prezzi che non finiscono in ,99, prima 5 su 9, dopo 0 su 9; sconti a video diversi dal calcolo 0 su 3; nomi di periodo e prezzi tagliati o a capo a 360 punti, prima 5 su 18 al carattere normale e 15 su 18 al massimo, dopo 0 e 0

## VOCE EV.02, "TRACCIA IL SIGILLO" CHE NON SI TOCCA

**APERTA IN ATTESA DI VERIFICA**: guardata sul Realme, manca l'iPhone di
collaudo, che ha la build 2288 e non ha ancora una build dal commit della voce
(regola 12: la lancia il fondatore con Codemagic).

Perche' era spento, e lo era anche nel codice di partenza: il pulsante si
accendeva solo con `abbastanza && !_riformulando && _proposta == null`. Dopo
"Chiedi a Calìgo di riscriverla" la proposta di Calìgo restava in sospeso
sopra il campo, fuori vista con la tastiera aperta, e il pulsante restava
spento senza dire perche' finche' non la si usava o scartava. Padre: ordine
DO (commit `de03a1ea`, il Sigillo dell'Intenzione che diventa un oggetto che
vive). Adesso il pulsante dice che cosa fa e lo fa: "Scrivi la tua intenzione"
(porta il cursore nel campo), "Calìgo sta riscrivendo la frase", "Traccia con
la forma di Calìgo", "Traccia il sigillo"; il tracciamento chiude la tastiera.
Sul Realme: intenzione scritta, giorno scelto, tastiera aperta, un tocco, il
sigillo tracciato e la tastiera chiusa
(`realme/ev02_tastiera_aperta_pulsante_acceso.png`,
`realme/ev02_dopo_un_tocco_sigillo_tracciato.png`, la registrazione
`realme/ev02_sigillo_con_la_tastiera.mp4`, 40 secondi, presa a meta' del
gesto). Prova: `test/il_sigillo_si_traccia_sempre_test.dart`, 0 su 4
situazioni con un tocco a vuoto (innesto A3 rosso).

DOMANDA: "nel sigillo non posso fare click su "traccia il sigillo""

## VOCE EV.03, MEDORA CONOSCE IL CIELO DI OGNI GIORNO

**APERTA IN ATTESA DI VERIFICA**: chiusa per la chat (banchi e Realme), il
LIVE passa dalla stessa porta del modello ma non e' stato provato a voce sul
Realme.

Perche' negava: al modello arrivavano sei pianeti e la regola "Non nominare
Urano, Nettuno e Plutone" (padre: ordine ET voce 01, quando le effemeridi non
li avevano), e il cielo di oggi arrivava solo a chi aveva i dati di nascita
(padre: ordine DS voce 08). Adesso il modello riceve due funzioni,
`cielo_del_giorno` e `cielo_del_periodo` (`lib/services/ai/le_funzioni_del_cielo.dart`),
che la libreria esegue sul telefono col motore delle effemeridi dell'app
(`lib/core/astro/il_cielo_per_il_maestro.dart`): posizioni e gradi dei dieci
corpi, retrogradi, segno e fase della Luna, aspetti, eclissi, transiti sulla
carta natale, ingressi, stazioni e lune di un periodo fino a un anno. La
descrizione porta il cielo di oggi gia' calcolato. Quando il modello rimanda
("devo consultare il cielo") o risponde a memoria sul cielo di un altro tempo,
l'app lo sollecita una volta. La rete del cielo detto non toglie piu' le frasi
vere sugli altri giorni chiesti, e controlla "la tua Luna" e "il tuo segno"
contro i dati di nascita. Il registro del Realme con tre date diverse:
`docs/collaudo/EV/registro_tre_domande_realme.txt`.

DOMANDA: "Medora in chat deve sapere qual è la situazione astrale oggi e di ogni giorno di qualunque mese e anno".
PROVA: docs/collaudo/EV/medora_e_il_cielo.txt
MISURA: fatti del cielo negati o sbagliati nelle venti risposte, prima 13 su 20 (docs/collaudo/EV/medora_e_il_cielo_prima.txt), dopo 0 su 20 in due esecuzioni con persone diverse (medora_e_il_cielo.txt e medora_e_il_cielo_persona2.txt, verdetti in docs/collaudo/EV/medora_verdetti.md); sul Realme 3 domande con date diverse, 3 risposte giuste, 4 chiamate alla funzione nel registro

## VOCE EV.04, MEDORA NON NEGA IL RESPONSO DA CUI PARTE LA DOMANDA

**CHIUSA.** Ogni responso che compare (le azioni sotto il responso, in tutte
le arti) si ricorda per il giorno (`lib/core/chat/i_responsi_di_oggi.dart`,
fino a dodici); "Parlane con..." lo segna come partenza; il Maestro li riceve
nell'istruzione, quello di partenza per intero e per primo, con la regola di
non negarli e di non chiedere quale. L'Oroscopo passa a Medora anche il "Da
dove viene" di ogni scheda. Vale anche quando la persona scrive a mano. Padre
del difetto: ordine CG voci 06 e 08, "Parlane con..." passava alla chat una
frase sola col segno. Sul Realme: dall'Oroscopo, "Parlane con Medora", "Che
cosa vuol dire il transito che ho letto sotto la Generale di oggi?", Medora
risponde col transito della scheda ("il Sole in Bilancia di oggi è in
quadratura al tuo Urano di nascita").

DOMANDA: "Medora nega il transito del responso dell'oroscopo o altra funzionalità da cui parte la domanda."
PROVA: docs/collaudo/EV/medora_e_il_responso.txt
MISURA: risposte che negano o ignorano il responso di partenza, prima 9 su 10 (medora_e_il_responso_prima.txt), dopo 0 su 10 in due esecuzioni con persone e semi diversi (medora_e_il_responso.txt e medora_e_il_responso_persona2.txt); sul Realme 1 su 1 risposta col transito della scheda (docs/collaudo/EV/realme/ev04_medora_dice_il_transito_del_responso.png)

## VOCE EV.05, L'IPHONE BLOCCATO CON LA TASTIERA APERTA

**APERTA IN ATTESA DI VERIFICA**: manca l'iPhone di collaudo con una build dal
commit della voce.

Da quale schermata: **non si e' trovata**. Sul Realme col codice di partenza
e nelle prove la tastiera si chiudeva gia' tornando indietro; la cattura dei
fondatori viene da un iPhone con una build vecchia. **PROVENIENZA IGNOTA.** Il
blocco: nei 21 rapporti dell'iPhone di collaudo (`pymobiledevice3 crash ls`)
nessuno e' dell'app (un JetsamEvent del 7 settembre, rapporti di sistema);
Crashlytics non ha l'esportazione verso BigQuery (nessun dataset nel progetto),
quindi da qui non si legge: il fondatore lo apre nella console di Firebase.
La cura, difensiva: l'app chiude la tastiera da se' quando una pagina si
chiude senza un campo col fuoco e quando si cambia scheda nella barra
(`lib/design_system/la_tastiera_si_chiude.dart`). Sul Realme: chat, foglio
dell'amico e Sigillo, tre ritorni con la tastiera aperta, 0 con la tastiera
rimasta aperta (`dumpsys input_method`, mInputShown=false dopo ogni ritorno).

DOMANDA: "A un certo punto, iPhone si è bloccato in home con la testiera aperta e ha dovuto riavviare."

## VOCE EV.06, "ONLINE" FERMO A 1

**APERTA IN ATTESA DI VERIFICA**: la funzione chiEOnline nuova si pubblica
con la consegna della 2290, e il conto a due telefoni si misura quando il
telefono del fondatore ha la build nuova.

Perche' restava a 1, letto nel database (`docs/collaudo/EV/online.txt`): una
chiamata ogni due minuti e una finestra di 150 secondi; un telefono in pausa
restava contato e non chiedeva piu', uno nuovo si vedeva solo alla chiamata
successiva dell'altro. Padre: ordine ES voce 15 (commit `78d1388c`). Cura: una
chiamata al minuto, finestra di 90 secondi, e chi va in pausa esce dal conto
subito. Sul Realme con la build nuova "ONLINE 2" mentre un secondo telefono
era aperto (`realme/ev06_online_2_build_2290.png`).

DOMANDA: "Dopo cinque minuti o cmq da ieri l'indicatore"ONLINE" RESTA FERMO A 1 sia sul mio Cell e sia sul realme collegato."

## VOCE EV.51, LE RICHIESTE DI "NOTE DI KEEP"

**CHIUSA.** Non vengono dall'app: l'archivio non chiede nessun permesso sugli
account, la registrazione con Google consegna un account solo coi dati di
base, e le notifiche sono di Google Play Services per l'app Keep.

DOMANDA: "Difetto grave: [...] nelle notifiche sono arrivate richieste di accesso a tutti i miei account Google."
PROVA: docs/collaudo/EV/note_di_keep.txt
MISURA: permessi dell'archivio che toccano gli account, 0 su 18; scope aggiunti alla registrazione con Google, 0

## VOCE EV.52, L'EMBLEMA DELL'ARCHETIPO PERSO DOPO LA REINSTALLAZIONE

**APERTA IN ATTESA DI VERIFICA**: si vede solo reinstallando e registrandosi
col proprio account, che e' un gesto del fondatore.

Perche': il Cerchio custodiva l'archetipo (dominante e giorno) e lo
rimandava, e nessuno lo rimetteva sul telefono: tornavano gli Eos, i Sigilli,
l'Alba e il Viaggio, l'archetipo no. Padre: ordine AP voce 01 (commit
`d2f41ba0`, il cammino custodito senza la strada del ritorno dell'archetipo).
Adesso `ArchetypeHistory.adottaDalCerchio` lo riprende quando il telefono non
ne ha uno, guardando il disco e non solo la memoria. Prova:
`test/l_archetipo_torna_dal_cerchio_test.dart` (innesto A10 rosso). Il
Cerchio custodisce il dominante e il giorno, non le dodici percentuali.

DOMANDA: "Dopo la reinstallazione e dopo la registrazione con mia email, però, ho perso l'emblema dell'archetipo e mi chiede di rifarlo."

## VOCE EV.53, IL VIAGGIO DELLO SCIAMANO CHE TORNA AL PRIMO CAMMINO

**APERTA IN ATTESA DI VERIFICA**: corretta e pubblicata sul server (funzione
statoDelCerchio, 1 ottobre 2026); si vede col secondo cammino fatto e l'app
riaperta.

Perche': il server sceglieva il Viaggio piu' avanti leggendo `quante` e
`riconosciuto`, il telefono li manda come `viaggio.quante` e
`viaggio.riconosciuto`: ogni Viaggio valeva zero, a parita' vinceva il server,
fermo per sempre sulla prima copia ricevuta, e a ogni riapertura la riscriveva
sul telefono. Padre: ordine EE voce 13 (commit `1abe154b`), le due meta' mai
provate insieme. Prova: `functions/src/cammino.test.ts`, due prove rosse sul
codice di partenza e verdi dopo. **Il secondo cammino del fondatore non torna**:
la copia vecchia aveva gia' riscritto il telefono; dal prossimo cammino resta.

DOMANDA: "sono al primo cammino del viaggio dello sciamano, fsccionil secondo e va tutto ok. Poi chiudo l'app e la riapro e il cammino torna al primo, come se non avessi fatto già il secondo."

## VOCE EV.54, I TRE ANGELI NELLA BOLLA DEL PASSAPORTO

**CHIUSA.** La bolla mostra le carte di tutti gli angeli della persona a
ventaglio, il Custode davanti, e i loro nomi.

DOMANDA: "Inoltre, ne Passport, nella bolla scheda degli angeli, mi fa vedere la Carta solo del primo, ma in verità sono 3"
PROVA: docs/collaudo/EV/realme/ev_angeli_tre_nel_passaporto.png
MISURA: carte nella bolla, prima 1, dopo 3 su 3; nomi nella bolla, prima 1, dopo 3 su 3 (test/la_bolla_degli_angeli_ne_mostra_tre_test.dart, innesto A11 rosso)

## VOCE EV.55, LA SCHEDA DELLE NOTIFICHE: NON ALL'AVVIO, AL PRIMO DONO

**APERTA IN ATTESA DI VERIFICA**: sul Realme il permesso c'e' gia', quindi
il foglio non compare; si vede su un telefono che non l'ha mai concesso.

All'avvio nessuna scheda (padre della scheda all'avvio: ordine BZ voce 04);
alla prima apertura di un Dono un foglio "Attiva le notifiche": "Ti avviso
quando i tuoi Doni sono pronti. Puoi attivarle e disattivarle dal menù
Notifiche.", 91 caratteri, pulsante "Attiva". Il foglio dei permessi scorre
se non ci sta, cosi' il pulsante non finisce sotto la barra. Prova:
`test/le_notifiche_si_chiedono_al_primo_dono_test.dart` (innesti A17, A18,
A19 rossi).

DOMANDA: "Il pulsante giallo non si può cliccare perché è sotto il menù esplora. Il testo è eccessivo. Cmq elimina tutta la scheda all'avvio. Serve solo una scheda "Attiva le notifiche" quando l'utente apre la prima volta un dono e con il testo minimo indispensabile Senza dire 4 notifiche al giorno e altri dettagli." e "Aggiungi aggiungi magari, che potrà attivare e disattivare le notifiche dal menù notifiche"

## VOCE EV.56, NIENTE CATTURE DELLO SCHERMO

**APERTA IN ATTESA DI VERIFICA**: si chiude con la cattura nera dalla build consegnata. Su Android lo schermo si protegge all'avvio (`FLAG_SECURE`): niente
cattura, niente registrazione, l'anteprima fra le app recenti nera. Su iOS il
sistema non lascia a un'app il modo di impedire una cattura.

DOMANDA: "Inoltre, vorrei disattivassi la possibilità di fare screenshot"
PROVA: docs/collaudo/EV/realme/ev56_cattura_dalla_build_consegnata.png
MISURA: catture leggibili dalla build consegnata sul Realme, 0 su 1 (l'immagine e' nera); dalla build di collaudo 1 su 1

## VOCE EV.57, "ONLINE" CHE CAMBIA NUMERO

**APERTA IN ATTESA DI VERIFICA**, con la voce EV.06. Il numero e' quello delle
persone con l'app aperta in tutto il mondo, letto dal database del Cerchio:
non ha niente a che vedere con la rete locale. Cambiava perche' i telefoni
chiedevano ogni due minuti e chi chiudeva restava contato due minuti e mezzo;
con la 2290 e la funzione nuova chi chiude esce subito e chi apre entra entro
un minuto.

DOMANDA: "Devi sistemare l'indicatore ONLINE che continua a cambiare numero di utenti online. Honio dubbio che indichi il numero degli utenti nella mia rete locale."
