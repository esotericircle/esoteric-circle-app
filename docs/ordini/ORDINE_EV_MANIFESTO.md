# ORDINE EV, I RILIEVI DEI FONDATORI, I PREZZI E LA VERIFICA DEI TESTI

**Sigla:** EV, verificata sul ramo sul commit `0f7a0625`: in `docs/ordini`
l'ultimo manifesto era `ORDINE_EU_MANIFESTO.md` e non esisteva `ORDINE_EV`;
in `docs/collaudo` non esisteva la cartella EV. **Data dell'ordine:** 2
ottobre 2026 (il lavoro e' del 1 ottobre sul calendario del PC).
**Ramo:** `claude/esoteric-circle-master-order-e798aj`, nessun altro.
**Partenza:** commit `0f7a0625`, col segno `refs/verde/0f7a0625...` presente.

**Il pezzo 2 e' arrivato il 1 ottobre sera**, dopo la consegna della 2291:
le voci dell'Architetto EV.07, EV.08 (la prosecuzione di EU.14), EV.09 ed
EV.10, con lo stesso manifesto e lo stesso rapporto. Il primo pomeriggio il
fondatore aveva scritto "Hai già tutto l'ordine" e il pezzo 1 e' stato
lavorato e consegnato da solo.

**La regola 6 ("questo ordine non consegna niente") e' superata dal
fondatore** in coda al pezzo 1: "Alla fine di tutto, crea nuova Build, test su
Cell e consegna su AppTester e dimmi quando posso lanciare codemagic".

Le voci EV.51-EV.60 sono le segnalazioni del fondatore arrivate durante il
lavoro, numerate da Code dopo il posto delle voci dell'Architetto.

VOCI_TOTALI: 20
VOCI_CHIUSE: 7
VOCI_APERTE: 13
VOCI_DA_FARE: 0

Le prove stanno in `docs/collaudo/EV/`, quelle del telefono di prova (Realme
767f596c) in `docs/collaudo/EV/realme/`. **Le catture del Realme vengono da
una build di collaudo** costruita dallo stesso commit con
`--dart-define=CATTURE_PERMESSE=true`: con la voce EV.56 la build consegnata
proteggeva lo schermo e le catture uscivano nere. Dalla voce EV.60 le catture
si fanno anche dalla build consegnata.

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

## VOCE EV.07, I CORPORA CORRETTI E IL CONFINE COM'ERA

**APERTA IN ATTESA DI VERIFICA**: aspetta i testi dell'Architetto per quindici
frasi.

I cinque corpora corretti dall'Architetto sono entrati nel ramo uguali byte per
byte (venti righe: le tre frasi al presente, le sedici senza "almanacco",
l'ellissi tolta), e i dati del codice si sono rigenerati
(`tool/_gen_oroscopo_eu.py`). Il confine del responso e' tornato com'era
prima dell'ordine EU: zero righe di differenza dal commit `103c0df4`,
l'eccezione `futuroDellaTuaScelta` (padre: EU Aggiunta, commit `67ca80b7`)
non c'e' piu'.

**La misura sui dodici corpora interi ha trovato quindici frasi, non tre.**
Il rapporto EU ne aveva nominate tre, guardando le sole schede che le prove
componevano; col confine di prima, sulle 6192 voci dei dodici corpora, le
frasi col futuro di un gesto sono quindici (otto cinesi, tre vediche del
Giorno, una della Settimana vedica, una dell'Occidentale della Settimana, e
"Scrivi la data in cui partirai davvero" dell'Occidentale del Giorno, che stava
nel commento dell'eccezione e non nel rapporto: padre del difetto di
misura, ordine EU voce EU.14, il rapporto che guardava un campione). Code non
riscrive i corpora: le quindici frasi sono dichiarate una per una, col file e
la riga, in `test/le_frasi_dei_corpora_in_attesa.dart`, e la guardia pretende
che nessun'altra frase superi il confine e che l'elenco resti vero.
Proposte di riscrittura nel rapporto, per l'Architetto.

DOMANDA: rapporto EU, "Per l'Architetto", punti 1, 2 e 3; Linee Guida, sezione 8, "IL CONFINE DEL RESPONSO, E VIVE IN UN PUNTO SOLO".
PROVA: docs/collaudo/EV/ev07_corpora_e_confine.txt
MISURA: corpora diversi dalla fonte, prima 5 su 12, dopo 0 su 12 (sha1); eccezioni del confine aggiunte nell'ordine EU, da 1 a 0; frasi dei corpora fuori dal confine, 15 su 6192 (col confine dell'ordine EU 10), tutte dichiarate in attesa dei testi dell'Architetto, non dichiarate 0

## VOCE EV.08, LA VERIFICA DELLE AFFERMAZIONI

**CHIUSA.** Il file dell'Architetto e' entrato in `docs/corpus/eu/` uguale
byte per byte; i diciassette "NUOVO TESTO" delle affermazioni sono nel codice e
nei corpora carattere per carattere (O-M-001..007 in
`il_metodo_del_responso.dart`; V-M-001 e V-M-004 in `la_lettura_vedica.dart`;
V-M-009, V-M-011, C-M-006 e C-M-008 in `l_anno_delle_tradizioni.dart`; C-G-068,
C-G-069, C-M-002 e C-M-004 nel corpus cinese, rigenerato); ogni "FONTE" e'
scritta accanto alla frase, nella nota del suo caso del corpus o nel commento
del codice; le righe scritte da Code nell'ordine EU restano, approvate.
`docs/collaudo/EV/affermazioni.md` e' rigenerato da
`tool/rigenera_affermazioni_ev.py`: 759 affermazioni, 722 con una fonte, 32
fatti di calcolo, 5 scelte dell'app, nessuna senza fonte; i "file:riga"
riportati allo stato di oggi. La guardia
`test/i_testi_nuovi_dell_architetto_sono_nel_codice_test.dart` cerca ogni
testo nuovo del file dell'Architetto, anche quelli della voce EV.09, nel file
dove vive (innesto A40 rosso).

Resta nel corpus cinese, nella regola del caso 1.8, la frase "Nella tradizione
i rami uguali si rafforzano", che l'Architetto ha giudicato senza fonte in
C-G-068: e' una nota, non va a video, e Code non l'ha toccata; e' nel
rapporto.

DOMANDA: "VERIFICA CHE L'INTERPRETAZIONE SIA REALE E NON INVENTATA E CHE NON SIA RIPETITIVA"; voce EU.14.
PROVA: docs/collaudo/EV/affermazioni.md
MISURA: affermazioni SENZA FONTE, prima 88 su 759, dopo 0 su 759; testi nuovi diversi dalla fonte, 0 su 20

## VOCE EV.09, LE RIFINITURE DEI "DA DOVE VIENE"

**APERTA IN ATTESA DI VERIFICA**: mancano le catture della Settimana Lunga
vedica e cinese dal Realme, con la build nuova.

Coi testi dell'Architetto: il venerdi' vedico e' "screziato" nella riga della
Fortuna come nel "Da dove viene" (prima "bianco screziato"); la variante del
Rahu Kalam in corso dice "Siamo dentro il Rahu Kalam di oggi, dalle {inizio}
alle {fine}."; la riga della ruota dice "Guardalo sulla tua carta, nella tua
{ordinale} casa." (`LaRigaDelPassaggio.riga`); quando due dei tre giorni
migliori di fila hanno lo stesso "Da dove viene", il secondo dice "Da dove
viene: lo stesso passaggio di giovedì 1 ottobre." (`IlPeriodoView.daDoveDelGiorno`);
sotto la data di un giorno che non e' oggi le righe della Vedica e della Cinese
non dicono "oggi" (`LaSettimanaDelCielo.senzaOggi`: "Oggi" in apertura si
toglie, "di oggi" diventa "di quel giorno"; padre: ordine EU voce 02). Guardia
`test/le_rifiniture_dei_da_dove_viene_test.dart`, innesti A35-A39 rossi.

DOMANDA: rapporto EU, "Per l'Architetto", punti 4, 7, 9 e 10; il fondatore, "evitare ripetizioni".
PROVA: test/le_rifiniture_dei_da_dove_viene_test.dart
MISURA: righe di altri giorni con "oggi", dopo 0 su 528; righe della ruota uguali al primo passaggio, dopo 0; giorni migliori di fila con la stessa riga intera, dopo 0

## VOCE EV.10, IL "RIVEDIAMOCI DOMANI" COL CIELO SBAGLIATO

**CHIUSA.** La riga e' l'invito a tornare di Medora, scritto dall'app e non
dal modello: `ConsiglioFinale.invitoDelRitorno`, calcolato da
`ProssimoCambioDellaLuna` sulle effemeridi dell'app (`Effemeridi`, attraverso
`NightSky`), con l'ora della risposta. Esiste anche nel codice di oggi. **Sulle
catture la data non si legge**: alle 7:30 del 29 settembre "Rivediamoci domani:
la Luna entra in Gemelli" era vero (ingresso alle 19:22 del 30); alle 7:30 del
30 l'app avrebbe detto "oggi, piu' tardi", alle 7:30 del 1 ottobre "domani:
Cancro". Misurando sessanta giorni sono usciti tre difetti veri, tutti
corretti: (1) l'ingresso si cercava dall'ora piena e un ingresso alle 23:25
contava come il giorno dopo, 9 inviti sbagliati su 240; (2) la fase si
riconosceva dal nome, che comincia dodici ore prima dell'istante esatto, e
dentro quelle ore l'invito saltava alla fase successiva ("Ripassa fra 8
giorni, per la Luna piena" con il Primo quarto la sera stessa), 92 inviti
sbagliati su 240; (3) la chat componeva l'invito con l'ora della risposta,
quindi una conversazione riaperta il giorno dopo diceva ancora "domani". Padri:
(1) e (2) ordine DS voce 08 (la ricerca ora per ora), (3) ordine EJ voce 05
(l'invito sotto l'ultima risposta, con l'ora del messaggio). Adesso l'istante
del cambio si cerca al minuto (l'ingresso col segno, la fase col cambio di
quarto dell'elongazione, `NightSky.quartoDelCiclo`), e la chat compone l'invito
con l'ora di chi legge. La stessa correzione nella rete del cielo detto
(`IlCieloDetto`), che contava i giorni allo stesso modo. Guardia
`test/gli_inviti_del_cielo_sono_veri_test.dart`, innesti A41b, A42 e A43 rossi.

DOMANDA: dall'Architetto, sulle catture dei fondatori; il fondatore, "VERIFICA CHE L'INTERPRETAZIONE SIA REALE E NON INVENTATA".
PROVA: docs/collaudo/EV/inviti_del_cielo.txt
MISURA: inviti con un evento del cielo sbagliato in sessanta giorni, quattro ore al giorno, prima 101 su 480 (ingressi 9 su 240, fasi 92 su 240), dopo 0 su 480

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

**CHIUSA.** Sul Realme, con la build 2290 costruita senza
`CATTURE_PERMESSE`, la finestra dell'app porta il segno `SECURE` e tre catture
su tre escono vuote (0 byte): il sistema le rifiuta. Su Android lo schermo si protegge all'avvio (`FLAG_SECURE`): niente
cattura, niente registrazione, l'anteprima fra le app recenti nera. Su iOS il
sistema non lascia a un'app il modo di impedire una cattura.

Superata il giorno stesso dalla voce EV.60, per decisione del fondatore: le
catture tornano.

DOMANDA: "Inoltre, vorrei disattivassi la possibilità di fare screenshot"
PROVA: docs/collaudo/EV/ev56_catture_bloccate.txt
MISURA: catture leggibili dalla build senza CATTURE_PERMESSE sul Realme, prima (build di collaudo) tutte quelle della cartella realme, dopo 0 su 3 (0 byte, finestra SECURE)

## VOCE EV.57, "ONLINE" CHE CAMBIA NUMERO

**APERTA IN ATTESA DI VERIFICA**, con la voce EV.06. Il numero e' quello delle
persone con l'app aperta in tutto il mondo, letto dal database del Cerchio:
non ha niente a che vedere con la rete locale. Cambiava perche' i telefoni
chiedevano ogni due minuti e chi chiudeva restava contato due minuti e mezzo;
con la 2290 e la funzione nuova chi chiude esce subito e chi apre entra entro
un minuto.

DOMANDA: "Devi sistemare l'indicatore ONLINE che continua a cambiare numero di utenti online. Honio dubbio che indichi il numero degli utenti nella mia rete locale."

## VOCE EV.58, LE MEMORIE CHE TORNANO COL TUO ACCOUNT

**APERTA IN ATTESA DI VERIFICA**: si vede solo disinstallando, reinstallando
e rientrando con lo stesso account, che e' un gesto del fondatore, e solo
dopo che la build nuova ha mandato almeno una volta le memorie al Cerchio.

Il fatto del fondatore e' la Runa del Tramonto (cinque sere, dopo la
reinstallazione una), ma il fondatore ha chiesto di cercare lo stesso difetto
in tutte le funzioni, e lo stesso difetto c'era. **Il censimento**: ogni
chiave che l'app scrive sul telefono e che `CioCheETuo` dichiara della
persona (40 prefissi) e' stata messa in una di tre caselle, e la prova
`test/le_memorie_tornano_col_tuo_account_test.dart` pretende che nessuna resti
senza casella:

- **tornano con le memorie del cammino** (7 prefissi, 12 famiglie): la Runa
  del Tramonto, i riti e il loro ultimo giorno, i dettagli del cammino
  (serie, ora del gesto, sentieri), i Sigilli del Libro, gli amici offline
  gia' posti, le sinastrie, gli Oroscopi aperti e comprati, le letture del
  mese, il Loto, i titoli delle conversazioni, gli avvisi scelti, il verso
  del Viaggio gia' udito;
- **hanno gia' una strada loro** (9 prefissi): l'Arcano dell'Alba, le arti
  preferite, il cammino, il profilo, il Viaggio, i Ricordi, il borsellino;
- **restano sul telefono, con la ragione scritta accanto** (26 prefissi):
  le impostazioni, i permessi, la posizione, i responsi di oggi, la cache
  della carta natale; e **per una promessa scritta nella schermata e
  nell'informativa** gli amici offline, le letture del viso e lo storico
  completo dell'archetipo, che restano sul telefono per scelta.

Le memorie viaggiano nel giro del Custode che c'era gia' (ogni rientro e ogni
riconoscimento): il telefono manda i valori col loro tipo, il server
(`functions/src/memorie.ts`) li unisce senza perdere niente (le liste per
identita', i numeri al piu' alto, le scelte del telefono prima), e il
telefono reinstallato li riprende quando non li ha. I Ricordi del Cosmic
Journal, che non arrivavano mai al Cerchio, si mandano e si riprendono una
volta per installazione. Le arti preferite: il telefono le manda solo quando
la persona le ha scelte (mai il seme), e quelle vincono.

**Padri.** Le sere del Tramonto stavano solo sul telefono dalla loro nascita
(commit `6d58b51f`, 26 luglio 2026, prima degli ordini a lettere); il
difetto e' dell'**ordine AP voce 01** (commit `d2f41ba0`), che ha costruito la
custodia del cammino elencando alcune famiglie e lasciando fuori le altre,
senza un censimento che dicesse quali. I Ricordi: **ordine CG voce 03**
(commit `0c4da6f7`), `sincronizza` scritta e mai chiamata. Le arti preferite
che tornavano indietro: **ordine AP voce 02**, a parita' vinceva il server e
il telefono mandava anche il seme.

**Cio' che non torna.** Le memorie partono dal telefono con questa build:
quello che e' andato perso prima (le cinque sere del fondatore, cancellate con
la disinstallazione) non era mai arrivato al Cerchio e non puo' tornare. Da
qui in avanti resta.

Prove: `test/le_memorie_tornano_col_tuo_account_test.dart` (innesto A27
rosso), `test/la_runa_del_tramonto_torna_col_tuo_account_test.dart` (A24,
A25, A28 rossi), `test/i_ricordi_tornano_col_tuo_account_test.dart` (A26
rosso), `functions/src/memorie.test.ts` e `functions/src/cammino.test.ts`
(innesti a mano rossi), in `docs/collaudo/EV/regola_a_ev.txt`.

DOMANDA: "Un'altra cosa che non mi ha riaccreditatto dopo la disinstallazione e reinstallazione con inserimento della stessa email sono gli storici del dono "runa del tramonto". Avevo già accumulato 5 "runa del tramonto" e adesso devo ricominciare da 1. [...] Se c'è una tipologia di problema, probabilmente c'è lo stesso problema con altre funzionalità, per logica. È tuo compito controllare dipendenze simili!"

## VOCE EV.59, IL VIAGGIO DELLO SCIAMANO CHE TACE

**APERTA IN ATTESA DI VERIFICA**: si vede sul telefono del fondatore, con una
domanda scritta e il primo pezzo dell'animale grattato.

Il fondatore: dopo la prima discesa con la domanda scritta, "Risali" portava a
"Oggi il Mondo di Sotto non ha parlato"; il numero dei cammini non avanzava, e
alla discesa dopo l'animale risultava gia' consumato. **Tre difetti, misurati.**
(1) Il silenzio: alla sonda del primo strato
(`tool/sonda_viaggio_primo_strato.dart`, la strada dell'app col modello vero)
8 discese su 12 finivano nel silenzio, quasi sempre per due guardie dello
stile, "non prende posizione" e "non nomina la domanda" (padre: ordine ES voce
25, la condizione che vuole un passo, 30 settembre; il silenzio dell'ordine DR
voce 07 era nato contro la voce di casa, non contro risposte del modello).
Adesso, quando nessuna risposta regge, l'ultima scartata per lo stile si
rilegge con le sole guardie dure (previsioni, promesse, decisioni gravi, terzi,
genere, scena) e, se regge, e' la risposta; un si' o un no a una domanda sul
"come" non passa mai (`LaScenaDalModello.senzaLeGuardieDelloStile`). (2) Il
cammino fermo: il silenzio non consuma la discesa, per regola, e il conto non
avanzava perche' quasi ogni discesa finiva li'. (3) L'animale gia' consumato:
la cenere scostata si salvava mentre si grattava, e il silenzio non la
rimetteva (padre: ordine DR voce 07 insieme alla cenere conservata dell'ordine
DQ voce 05); adesso il silenzio rimette la cenere com'era all'ingresso della
lente. Dalla stessa sonda, una guardia nuova: col profilo neutro il modello ha
scritto "se sei dispost a riconoscere", e nessuna guardia lo prendeva
(`LeGuardieDelResponso.parolaDelGenereTroncata`, PROVENIENZA IGNOTA).
Guardie: `test/il_viaggio_non_tace_per_lo_stile_test.dart` (innesti A31 e A34
rossi), `test/la_domanda_libera_arriva_intera_test.dart` (A32 rosso).

DOMANDA: "il viaggio dello sciamano NON FUNZIONA CAZZO! Dopo la prima parte con domanda personalizzata e dopo aver grattato la prima parte dell'animale, premo su "risali" e mi risponde xhe "oggi il mondo di sotto non ha parlato"" e "non aggiorna il numero di cammini effettuati, non dà risposte e, però, se scendo nuovamente l'animale risulta già consumato"
PROVA: docs/collaudo/EV/viaggio_primo_strato_dopo.txt
MISURA: discese al primo strato finite nel silenzio, prima 8 su 12 (docs/collaudo/EV/viaggio_primo_strato_prima.txt), dopo 3 su 18; celle dell'animale grattate e rimaste dopo un silenzio, prima 26 su 26, dopo 0

## VOCE EV.60, LE CATTURE DELLO SCHERMO TORNANO

**APERTA IN ATTESA DI VERIFICA**: si chiude con una cattura leggibile dalla
build consegnata.

Il fondatore, lo stesso giorno della voce EV.56: "Devi riattivare la
possibilità di fare screenshot, così non posso farli nemmeno per te". Adesso
le catture si fanno: l'avvio toglie il segno `FLAG_SECURE`, e la protezione
resta pronta per la build che la dichiara con `--dart-define=CATTURE_VIETATE=true`
(`lib/core/sensi/lo_schermo_protetto.dart`). Guardia
`test/lo_schermo_e_le_catture_test.dart`, innesto A33 rosso.

DOMANDA: "Devi riattivare la possibilità di fare screenshot, così non posso farli nemmeno per te."
