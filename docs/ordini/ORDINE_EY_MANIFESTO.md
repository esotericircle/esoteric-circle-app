# ORDINE EY, IL MOTORE SOCIALE DEL CERCHIO

**Sigla:** EY. **Data dell'ordine:** 4 ottobre 2026, tre pezzi, piu' l'EY
Aggiunta 1 (la P10 corretta, l'EY.06 riscritta col premio a 150, la voce nuova
EY.17). **Ramo:** `claude/esoteric-circle-master-order-e798aj`, nessun altro.
**Partenza:** commit `784dd20b`.

**La regola R9 (la build non la fare) e' superata da una frase del fondatore
del 4 ottobre 2026**: "Finisci tutto e vai anche oltre. Non consegnare ordini
parziali, ogni voce deve essere terminata. Alla fine fai test su Cell collegato
al PC e poi consegna nuova build su AppTester e pronta per Codemagic".

**Nessuna chiamata al modello** in nessuna voce (regola R11): il motore sociale
e' deterministico. **App Check resta spento** (premessa P9). **Gli amici
offline restano sul telefono** (legge L2): nessuna voce li fa salire.

**I testi dei segni e delle risposte sono segnaposto dichiarati** di Code
(`lib/core/cerchio/i_segni_del_cerchio.dart`): vanno riscritti
dall'Architetto. Gli identificativi restano, perche' li conosce il server.

VOCI_TOTALI: 17
VOCI_CHIUSE: 2
VOCI_APERTE: 15
VOCI_DA_FARE: 0

## VOCE EY.01, LO PSEUDONIMO E IL SIGILLO

**APERTA IN ATTESA DI VERIFICA.** Il secondo campo nel passo del nome
dell'onboarding, gia' compilato col nome iniziatico (appellativo, simbolo dai
set del progetto, qualita'), che non contiene mai il nome proprio. Le regole
del nome vivono in un dato solo, `functions/src/il_nome_del_cerchio.json`,
letto dal server e portato dal telefono come asset; la porta `scegliIlNome`
decide (forma, riservati sulla forma normalizzata con i caratteri di altri
alfabeti e le cifre riportati al latino, offensive, nome lasciato da meno di
novanta giorni, cadenza di trenta giorni). Il sigillo, quattro caratteri
dell'alfabeto di Crockford, lo assegna il server in transazione e non cambia.
Aspetta la pubblicazione delle funzioni e la prova a video sul Realme.

DOMANDA: "nella schermata di richiesta del nome inserirei un campo per inserire lo pseudonimo per i social (che dovrà essere unico e non occupato da altri)"
PROVA: test/il_nome_del_cerchio_test.dart, test/il_nome_nel_cerchio_nell_onboarding_test.dart, functions/src/il_nome_del_cerchio.test.ts
MISURA: riservati 15 nomi, forme provate 264 sul server e 219 sul telefono, passate 0 (prima del campo: nessun controllo); nomi veri 55, caduti 0; verdetti condivisi telefono e server 46 su 46 uguali; generatore su 1000 nascite: 974 nomi diversi, 0 col nome proprio, 0 rifiutati; elenchi 56 appellativi e 62 qualita' (soglie 50 e 60); filtro offensivo 32 radici e 24 parole
ACCETTAZIONE: nel Risveglio, al passo del nome, sotto il tuo nome compare "Con quale nome vuoi essere trovato nel Cerchio?" col nome gia' scritto; "Medora" dice "Questo nome è del Cerchio"; nel profilo del Cerchio leggi il tuo sigillo di quattro caratteri

## VOCE EY.02, IL PROFILO PUBBLICO, E CIO' CHE NON CONTIENE MAI

**APERTA IN ATTESA DI VERIFICA.** La collezione `profili/{uid}`, separata dal
ramo privato e chiusa a ogni lettura diretta dalle regole di Firestore, porta
sette campi e nient'altro (`CAMPI_DEL_PROFILO_PUBBLICO`); la scrive una sola
riga, `profiloDi(uid).set(pubblico)`, sempre passata da `soloIlPubblico`. Il
segno arriva dal telefono come segno, mai come data. La cancellazione
dell'account e l'azzeramento dei dati tolgono il profilo, i legami e i codici
e mettono il sigillo in quarantena novanta giorni.

DOMANDA: approvazione del fondatore del 4 ottobre 2026 dei punti 1 e 2 e legge L3
PROVA: functions/src/sociale.test.ts ("il profilo pubblico porta sette campi e niente altro")
MISURA: campi del profilo pubblico 7; campi vietati che passano da un documento sporco (nome proprio, nascita, ora, luogo, email, foto, posizione) 0 su 7; porte che scrivono il profilo pubblico 1
ACCETTAZIONE: un amico vede di te nome, icona, segno e Maestro, e mai la data di nascita

## VOCE EY.03, IL MENU' DEL PROFILO

**APERTA IN ATTESA DI VERIFICA.** "Il tuo nome nel Cerchio", dal Profilo: il
nome e il sigillo in alto, il cambio del nome con la cadenza e il giorno in cui
si riapre, la vetrina delle icone dai quattro set (le non incontrate spente
con la riga da dove si aprono), chi ti vede, chi puo' invitarti, il link da
rinnovare o revocare, i doni ricevuti, le persone bloccate con lo sblocco.

DOMANDA: "dovrà esserci nel menù utente la possibilità di inserire o cambiare lo pseudonimo oltre che cambiare icona del profilo o altre personalizzazioni"
PROVA: test/le_schermate_del_cerchio_test.dart, test/i_numeri_del_cerchio_sociale_test.dart
MISURA: icone 58 nei quattro set, con l'arte esistente 58 su 58, uguali ai conti del server 4 famiglie su 4; la scelta dell'icona arriva al server col suo codice
ACCETTAZIONE: Profilo, "Il tuo nome nel Cerchio": tocchi l'icona e scegli un segno; gli animali che non hai incontrato sono spenti e dicono dove si aprono

## VOCE EY.04, L'INVITO

**APERTA IN ATTESA DI VERIFICA.** Due vie: il link `esotericircle.app/i/CODICE`
(pagina del server per chi non ha l'app, richiesta di legame per chi ce l'ha) e
il codice da inquadrare, sei caratteri per cinque minuti, mostrato in QR e
scritto, letto dalla fotocamera con ML Kit sul telefono e scrivibile a mano
(fallback a gesto tattile). Chi puo' invitarti: tutti o solo col sigillo.
Venti inviti al giorno, mai due alla stessa persona senza risposta.

DOMANDA: documento Analisi_ChatGPT_Social_Spiritual_Universe, sezioni 3.1 e 3.2, approvato dal fondatore il 4 ottobre 2026
PROVA: test/le_schermate_del_cerchio_test.dart (la richiesta), functions/src/sociale.test.ts (le difese)
MISURA: difese dell'invito 9 su 9 provate (se stessi, blocco, invito in attesa, rifiuto recente, solo col sigillo, tetto di venti, posti); nessun legame prima del tocco, 0 chiamate a chiediIlLegame prima di "Entra nel suo Cerchio"
ACCETTAZIONE: due telefoni vicini: uno mostra il codice, l'altro lo inquadra e vede "Nome ti chiama nel suo Cerchio"; un tocco e siete amici

## VOCE EY.05, I QUATTRO STATI, E IL BLOCCO CHE NON SI ANNUNCIA

**APERTA IN ATTESA DI VERIFICA.** Il semaforino nei quattro stati (spento,
arancione chiaro, arancione pieno, verde); il rosso solo fra le persone
bloccate del profilo. Il blocco agisce sull'identificativo, non avvisa, e
scioglie il legame in silenzio; il rifiuto non avvisa e vale trenta giorni.

DOMANDA: "un semaforino a fianco al nome indica se è amico (acceso verde), invitato non accettato (acceso arancione) oppure bloccato (acceso rosso)"
PROVA: test/le_schermate_del_cerchio_test.dart, functions/src/sociale.test.ts
MISURA: stati del semaforo 4, rosso fra gli stati degli elenchi 0; chi e' bloccato negli elenchi del Cerchio 0
ACCETTAZIONE: nel tuo Cerchio vedi il verde accanto agli amici e l'arancione accanto a chi ti invita; il rosso lo trovi solo nel profilo, fra i bloccati

## VOCE EY.06, L'INVITO CHE SI SA DA DOVE VIENE

**APERTA IN ATTESA DI VERIFICA.** La domanda dell'invito esiste (CC.08,
montata con DW.05) e rispetta i tre punti: si chiede una volta sola
(`MemoriaDellInvito`, segnata prima di aprire il foglio), gli appunti si
leggono solo sul tocco di Incolla, si tiene solo cio' che ha la forma di un
codice nostro. Non e' stata toccata. Il premio sale a 150 Eos a testa nel
codice (`EOS_DELL_INVITO_ACCOLTO`, `EOS_A_CHI_ARRIVA_CON_UN_INVITO`): fino
alla pubblicazione delle funzioni il server paga ancora sessanta. La cifra che
la persona legge resta del server.

DOMANDA: "Fai ordine aggiuntivo EY 1 con 150 EOS per invito"
PROVA: test/l_invito_porta_qualcuno_test.dart, test/l_invito_porta_il_suo_premio_test.dart
MISURA: premio nel codice prima 60 e 60, dopo 150 e 150; numeri scritti nel client 0; punti della domanda rispettati 3 su 3
ACCETTAZIONE: chi entra col tuo invito e incolla il codice riceve 150 Eos, e tu altrettanti, col motivo scritto nel borsellino

## VOCE EY.07, QUANTI AMICI, PER PIANO

**CHIUSA.** I posti del legame fra account vivono nella matrice dei piani
(`RigaDelPiano.legami`: 3, 15, 50, 150), il server li ripete in
`POSTI_DEL_LEGAME` e una prova pretende che coincidano. Nessun senza limite.
Il posto in piu' e' la voce `amicoInPiu` a 100 Eos. **Rilievo riportato e non
corretto**: per gli amici offline il listino (`amicoInPiu`,
`gratisAlGiorno[Tier.tier3]` nullo) e la matrice (`'Senza limite'`) dicono
ancora illimitato all'Illuminato, contro la decisione del 29 agosto 2026: lo
decide il fondatore.

DOMANDA: approvazione integrale della tabella del punto 8, 4 ottobre 2026
PROVA: test/i_numeri_del_cerchio_sociale_test.dart
MISURA: posti del server uguali alla matrice 4 piani su 4; posti senza limite 0 su 4
ACCETTAZIONE: nella pagina dei Piani compare "Amici nel Cerchio: 3, 15, 50, 150"

## VOCE EY.08, LA TENDINA DELL'INDICATORE ONLINE

**APERTA IN ATTESA DI VERIFICA.** L'indicatore online si tocca e scende la
tendina come un velo: i tuoi amici presenti con cosa stanno facendo in forma
generica e due gesti, il Cerchio adesso per arte, al massimo dodici persone
simili col criterio scritto. L'istantanea si rifa' al massimo ogni trenta
secondi per tutto il Cerchio; la presenza porta l'arte come categoria chiusa.

DOMANDA: "la vorrei che con un click sul l'indicatore online, scendesse una tendina con tutti gli utenti online o magari solo gli amici online e con loro poter interagire"
PROVA: functions/src/sociale.test.ts (la misura delle letture), test/le_schermate_del_cerchio_test.dart
MISURA: letture per telefono in un'ora con mille presenti: istantanea 841, via ingenua 120.000; persone simili al massimo 12, deterministiche sul giorno e su chi guarda
ACCETTAZIONE: tocchi "Online" in alto e scende la tendina coi tuoi amici e il Cerchio per arte

## VOCE EY.09, CHI SI VEDE, CHI NON SI VEDE

**APERTA.** Visibilita' predefinita ai soli amici, presenza pubblica con una
scelta esplicita, invisibilita' gratuita per tutti, minorenni visibili ai soli
amici senza nessuna etichetta. **Aspetta la decisione del fondatore sotto i
quattordici anni**: in Italia il consenso lo presta chi esercita la
responsabilita' genitoriale, e l'ordine vieta di costruire qui un meccanismo.

DOMANDA: "presenza visibile a tutti", con la visibilita' predefinita ai soli amici e la regola sui minorenni
PROVA: functions/src/sociale.test.ts, test/i_numeri_del_cerchio_sociale_test.dart
MISURA: minorenni con presenza pubblica 0; etichette "minorenne" a schermo 0
ACCETTAZIONE: nel profilo del Cerchio "Tutto il Cerchio" dice cosa comporta; "invisibile" e' gratuito

## VOCE EY.10, I SEGNI DEL CERCHIO

**APERTA IN ATTESA DI VERIFICA.** Diciotto segni in tre categorie (sei per
categoria), ognuno col suo disegno animato nella palette di chi lo manda e da
due a tre risposte; le richieste aprono la loro funzione. Zero testo libero.
Tetti per piano dalla matrice (5, 20, 40, 60), tre alla stessa persona, due non
ricambiati. La notifica nomina la cosa.

DOMANDA: "Io pensavo a un lista di domande preimpostate e risposte preimpostate"
PROVA: test/il_cerchio_non_ha_testo_libero_test.dart, test/i_numeri_del_cerchio_sociale_test.dart
MISURA: campi di testo libero nelle schermate sociali 0 (3 campi, tutti identita'); campi di testo recapitati dal server 0; segni per categoria 6, 6, 6
ACCETTAZIONE: dalla scheda di un amico mandi "Ti penso"; sul suo telefono arriva "Nome ti ha mandato un segno"

## VOCE EY.11, LE REAZIONI

**APERTA IN ATTESA DI VERIFICA.** Sette reazioni disegnate, due negative; una
reazione risponde solo a un segno ricevuto (l'unica porta che le accetta lo
pretende), privata fra i due, dentro il tetto dei segni.

DOMANDA: "per antipatia pensavo ad una emoticon che fa la pernacchia con la lingua"
PROVA: functions/src/sociale.test.ts, test/le_schermate_del_cerchio_test.dart
MISURA: porte che accettano reazioni 1, e la reazione si guarda dopo il segno ricevuto; reazioni sul segno mandato 0
ACCETTAZIONE: sotto un segno ricevuto tocchi la linguaccia, e chi l'ha mandato la vede accanto al suo segno

## VOCE EY.12, I DONI

**APERTA.** Il cenno gratuito, la scintilla a 30 e il sigillo a 80 nel
listino, dall'Adepto in su; prezzo dichiarato prima, pagato sull'esito nella
stessa transazione della consegna, mai Eos a chi riceve. Il cenno a un
presente non amico una volta sola. **Il Gift Eos e' costruito con la sua
regola e resta aperto come l'ordine prescrive**: gli Eos comprati non hanno
una porta che li accredita e la dote del piano non si accredita ancora
(`borsellino.ts`), quindi oggi i regalabili valgono zero per tutti.

DOMANDA: "anche la possibilità di inviare regali/doni oppure dimostrare simpatia [...] alcune a pagamento EOS e poche basilari gratuite"
PROVA: functions/src/sociale.test.ts, test/i_numeri_del_cerchio_sociale_test.dart
MISURA: prezzi nel listino uguali al server 2 su 2; Eos coniati a chi riceve un dono 0; gift con Eos guadagnati gratis accettati 0
ACCETTAZIONE: da Adepto mandi una scintilla, ti si tolgono 30 Eos e lei la trova nel suo profilo

## VOCE EY.13, IL CONFRONTO DEL CIELO

**APERTA IN ATTESA DI VERIFICA.** Le due icone, il cerchio dell'affinita' e le
quattro barre della Sinastria VIP, i due titoli dell'oroscopo di oggi, la riga
del giorno, il pannello Fonti e metodo. Il calcolo usa `AltreAffinita` e la
Luna di oggi; e' sul segno, e lo dice. Tetto 1, 5, 15, 30 sul budget `cieli`,
uno in piu' a 30 Eos.

DOMANDA: "l'oroscopo e segno vanno bene per iniziare"
PROVA: test/il_confronto_del_cielo_e_simmetrico_test.dart
MISURA: coppie 78, giorni 29, confronti 2.262, diversi fra i due versi 0; cielo del giorno: prima della cura 1 valore in trenta giorni per Leone e Pesci (la Luna non contava), dopo 4 valori
ACCETTAZIONE: aprite tutti e due il confronto dello stesso giorno: leggete lo stesso numero

## VOCE EY.14, IL GLIFO DEL LEGAME

**APERTA IN ATTESA DI VERIFICA.** Un segno a tratti sul cerchio, generato dai
due sigilli e dai due segni, uguale dai due lati; un tratto si accende in ogni
giorno in cui tutti e due si sono mandati qualcosa, e lo tiene il server.
Dichiarato nel pannello Fonti e metodo della scheda dell'amico.

DOMANDA: approvazione del punto 2 delle migliorie, 4 ottobre 2026
PROVA: test/il_glifo_del_legame_test.dart, functions/src/sociale.test.ts
MISURA: coppie 500, diversi fra i due lati 0, forme distinte 500; su 2.000 glifi col bastone di una runa 0, uguali a una runa 0
ACCETTAZIONE: nella scheda di un amico vedi il vostro glifo; il giorno in cui vi scambiate un segno si accende un tratto

## VOCE EY.15, IL LINK DENTRO LA CARD

**APERTA IN ATTESA DI VERIFICA.** La porta unica della condivisione aggiunge
il link d'invito col codice opaco, in un posto solo (`conIlLink`), in tre vie
su quattro (lo scarico dei propri dati resta fuori, dichiarato); senza codice
la card parte com'era, ripiego dichiarato. Il premio della condivisione non e'
stato toccato.

DOMANDA: misura dell'Architetto su porta_della_condivisione.dart
PROVA: test/il_link_d_invito_non_porta_l_uid_test.dart, test/i_nove_ereditati_test.dart (P.28 estesa)
MISURA: vie della porta senza il link 0 su 3; chiamanti che condividono 25 in 21 file (l'ordine ne contava dodici)
ACCETTAZIONE: condividi una card dell'oroscopo su WhatsApp: in fondo c'e' esotericircle.app/i/ col tuo codice

## VOCE EY.16, IL TETTO PER IDENTITA' SULLE PORTE SOCIALI

**CHIUSA.** Sedici porte sociali, ognuna col suo tetto per identita' e per
finestra (`TETTI_DELLE_PORTE`), contato in transazione prima di ogni altra cosa,
con la riga che dice quanto manca. La tendina ha il tetto piu' stretto. La
guardia che enumera le callable e' stata estesa al file nuovo (13 diventano 29)
e pretende il tetto in ogni porta sociale. App Check non e' stato toccato.

DOMANDA: Sicurezza_dell_App_Esoteric_Circle.md, sezione 3
PROVA: test/il_cerchio_custodisce_il_cammino_test.dart
MISURA: porte sociali 16, senza tetto 0; callable contate 29
ACCETTAZIONE: nessuna a video: la si legge nel rapporto

## VOCE EY.17, IL CODICE DELL'INVITO DIVENTA OPACO

**APERTA IN ATTESA DI VERIFICA.** Il codice lo genera il server, opaco, con un
meccanismo solo e due durate (link trenta giorni, rinnovabile e revocabile;
vicino cinque minuti). I testi non portano piu' l'uid: lasciano la porta del
Maestro e il codice lo mette la porta della condivisione. Il formato vecchio
resta accettato al riscatto come compatibilita' dichiarata, con la scadenza
scritta (`FINE_DELLA_COMPATIBILITA`).

DOMANDA: "Ok per i tuoi suggerimenti", sul link che porta l'uid in chiaro
PROVA: test/il_link_d_invito_non_porta_l_uid_test.dart, functions/src/sociale.test.ts
MISURA: punti che condividono o compongono un invito 25, con un uid 0 (prima: 2, l'invito dal menu' e la festa del Sigillo)
ACCETTAZIONE: il link che mandi dal menu' finisce con /i/ e otto caratteri, e non contiene piu' il lungo codice di prima
