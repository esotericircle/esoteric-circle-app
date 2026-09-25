# ORDINE EM, IL LIVE CHE ASCOLTA GIUSTO, LE VOCI SCELTE E TRE DECISIONI SU EK

**Sigla:** EM, riverificata sul ramo il 25 settembre 2026 prima di
cominciare: in `docs/ordini` nessun `ORDINE_EM_*`, in `test/` nessuna
`ordine_em_guard`; il ramo remoto era a `8a44fa3f`. **Data dell'ordine:** 25
settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Le due scelte del fondatore prima di cominciare**, a una domanda con la
stima dichiarata di circa 18-20 ore di lavoro:

- *"Tutto, una build"*: tutte le dodici voci, le prove sul telefono e una
  build sola alla fine;
- per il respiro vero, che nessuno al PC puo' dare al Realme,
  *"Sintetico, poi il mio"*: si lavora e si misura col rumore vero della stanza e un
  respiro sintetico suonato dalle casse del PC, e le voci EM.04 ed EM.05
  restano in attesa della sua prova col respiro vero sul suo telefono.

**E una frase del fondatore arrivata durante il lavoro, che alza la misura
della voce EM.04**: *"Non è solo il respiro, ma potrebbe sempre esserci un
rumore di fondo in qualunque ambiente. Io uso "Ok Google" giornalmente con TV
accesa e gemini riconosce la mia voce Senza problemi. Ho bisogno dello stesso
livello di accuratezza e tolleranza"*.

VOCI_TOTALI: 12
VOCI_CHIUSE: 6
VOCI_APERTE: 6

Le prove stanno in `docs/collaudo/EM/`.

---

## I FATTI VERIFICATI SUL RAMO PRIMA DI TOCCARE IL CODICE

### 1. Il microfono decide solo sul volume

`lib/features/maestri/live/il_silenzio_vero.dart`, righe 76-107: un pezzo
d'audio e' parlato se il suo livello sta 12 decibel sopra il fondo imparato
per cominciare, 4 per continuare. Non guarda altro. Il respiro vicino al
microfono, un ventilatore o una televisione superano il fondo come la voce,
e finche' superano la soglia la frase non si chiude e l'orologio dei trenta
secondi non conta (`schermata_live.dart`, righe 323-330: il secondo e'
silenzio solo se `_orecchio.staParlando` e' falso).

### 2. Il registratore usa la sorgente di serie del telefono

`lib/services/voce/l_orecchio_del_live.dart`, righe 82-86: `RecordConfig`
senza `androidConfig`, cioe' `AndroidAudioSource.defaultSource`, senza
soppressione del rumore ne' dell'eco. Il pacchetto `record_android` 1.5.2
offre la sorgente `voiceCommunication` e i tre filtri del sistema
(`NoiseSuppressor`, `AcousticEchoCanceler`, `AutomaticGainControl`).

### 3. L'elenco delle voci non scorre

`lib/features/maestri/live/il_selettore_delle_voci.dart`, righe 97-151: le
candidate stanno in una `Column` con `mainAxisSize.min` dentro il foglio, e
nessuno scorrimento. Sedici voci di Calìgo non stanno nello schermo.

### 4. Domanda e risposta sono lo stesso testo, e il volto prende lo spazio che resta

`schermata_live.dart`: il volto sta in un `Expanded` (riga 666) e sotto c'e'
il sottotitolo, alto quanto il suo testo fino al venti per cento dello
schermo (righe 667-684). La domanda lo riempie in `_turno` (riga 478) e la
risposta lo sostituisce in `_dillo` (riga 526). Quando si fa una domanda il
testo lungo della risposta di prima diventa la domanda corta, e il volto si
allarga; quando comincia la risposta il testo si allunga, e il volto si
stringe. La domanda, a video, sparisce.

### 5. La voce scelta vive in memoria per servizio

`functions/src/live.ts`, righe 770-805: la scelta si legge da
`configurazione/live` al massimo una volta al minuto e resta in una
variabile del modulo. `scegliLaVoce` la azzera (riga 944), ma ogni porta del
server gira in un servizio Cloud Run suo, con la sua memoria: la porta che
parla nel LIVE, `laVoceDelMaestro`, non sa che la scelta e' cambiata finche'
il suo minuto non scade. E nel suo registro non scrive quale voce ha usato
(righe 1057-1066): che la voce sia stata applicata non si puo' leggere da
nessuna parte. **Sul registro del server**, la sera del 24 settembre 2026,
il fondatore ha scelto Despina per Medora alle 22:38:07 UTC e Orus per
Calìgo alle 22:47:04; `configurazione/live.voci` porta tutte e due, letto il
25 settembre.

---

## VOCE EM.01, "LAURA" DIVENTA "AURA" NEL LIVE DI AURA

Fonte: `docs/ordini/ORDINE_EK_MANIFESTO.md`, voce EK.03, e la risposta del
fondatore del 25 settembre 2026, *"Sì"*, alla regola solo per il LIVE di
Aura.

**Fatto**: `LaTrascrizione.nelLiveDi` (`lib/services/voce/l_orecchio_del_live.dart`)
scrive "Aura" dove la trascrizione scrive "Laura", **solo nel LIVE di Aura** e
solo come parola intera; la schermata la applica a ogni frase trascritta. La
domanda girata al fondatore era la regola solo per il LIVE di Aura, sapendo che
una Laura vera di cui la persona parla diventerebbe "Aura". Prova nuova
`test/la_risposta_arriva_prima_e_aura_si_scrive_giusta_test.dart`, vista rossa
portando la regola sul LIVE di Medora (`regola_a_client_em`).

**La misura della voce EK.03 nel LIVE di Aura**, le sei frasi con i
diciannove nomi (`docs/collaudo/EM/em01_i_nomi_nel_live_di_aura.txt`): sulla
2280 18 nomi giusti su 19, Aura scritta "Laura"; sulla 2281 finale **19 su
19**, nessun "Laura", le sei frasi intere. In questo giro la regola non e'
dovuta intervenire: la misura dice il risultato a video, la prova dice la
regola. Nello stesso giro hanno lavorato due salvagenti della voce EM.04: la
frase 3, tornata vuota dalla trascrizione anticipata, e' arrivata intera dalla
seconda; il controllo vuoto della frase 4 non l'ha scartata.

**Con questa voce si chiude la voce EK.03**, come vuole l'ordine: il suo
manifesto porta la chiusura.

**CHIUSA.**
DOMANDA: "Sì"
PROVA: docs/collaudo/EM/em01_i_nomi_nel_live_di_aura.txt
MISURA: nomi giusti nelle sei frasi della voce EK.03 nel LIVE di Aura, da 18 su 19 (Aura scritta "Laura") a 19 su 19

## VOCE EM.02, LE VOCI CHIRP 3 HD NEL LIVE, CON UN'ECCEZIONE SOLO PER LA VOCE

Fonte: `docs/ordini/ORDINE_EK_MANIFESTO.md`, sezione "Fuori dalle voci", la
frase del fondatore *"Prova ad aggiungere anche le voci Chirp nel
selettore"* e la sua risposta del 25 settembre 2026, *"Sì"*, all'eccezione
limitata alla voce sull'endpoint "eu".

**Fatto sul server** (`functions/src/live.ts`, pubblicato il 25 settembre
2026): fra le candidate del selettore, accanto alle voci di Gemini, ci sono
le trenta voci italiane Chirp 3 HD, con gli stessi nomi e lo stesso genere
(quattordici femminili per Medora e Aura, sedici maschili per Calìgo), col
nome `Chirp3-HD-<Nome>` e la famiglia scritta sotto il nome. Parlano a
flusso, PCM a 24 kHz, **solo dall'endpoint `eu-texttospeech.googleapis.com`**,
mai da "global". Primo audio misurato al banco fra 210 e 318 millesimi
(`docs/collaudo/EM/chirp_primo_suono.txt`), contro 0,66-0,75 secondi di Flash
TTS.

**L'eccezione e' scritta dove vive la regola**: in
`lib/core/config/la_regione_dei_dati.dart`, `eccezioniDellaVoce`, con la data
e questa voce come fonte, e nella riga della voce di `CLAUDE.md`. La guardia
nuova `test/le_voci_stanno_in_europa_test.dart` pretende che ogni host di
sintesi nominato in `lib` e in `functions/src` stia in europe-west1 o fra le
eccezioni, e che l'eccezione sia una sola, "eu", per le Chirp 3 HD, senza
"global". Vista rossa due volte: con l'indirizzo delle Chirp portato a
"global", e con l'eccezione tolta (`regola_a_europa_1` e `_2`). Le prove del
server delle candidate e dell'endpoint "eu" sono cadute togliendo le Chirp
dalle candidate e portando l'endpoint a "global" (`regola_a_server_em`).

**Non e' verificata in un LIVE vero sul Realme**: il selettore lo aprono solo
i fondatori, e l'account del Realme (`iToukegmg2P3LBmlyYGJjkxvFbs1`) non e' in
`configurazione/live.fondatori`. La scrittura su Firestore di produzione e'
stata fermata due volte dal controllo automatico dell'ambiente, anche dopo
l'autorizzazione del fondatore; non si e' aggirato. Chiesto al fondatore di
aggiungerlo dalla console, in chat e con una notifica.

**APERTA IN ATTESA DI VERIFICA.** Il giudizio sulla voce e' del fondatore
per ordine. La prova: scegliere una voce Chirp nel selettore e parlare nel
LIVE; il registro del server, riga "voce del Maestro", scrive la voce, la
famiglia e il punto, `eu-texttospeech.googleapis.com`.

## VOCE EM.03, L'ATTRIBUZIONE CIECA LA CHIUDE IL FONDATORE

Fonte: `docs/ordini/ORDINE_EK_MANIFESTO.md`, voce EK.05, e la risposta del
fondatore del 25 settembre 2026: *"Si il 96 è sufficiente per chiuderla."*

**Fatto.** `ImprontaDellIstruzione.chiusaDalFondatore`
(`lib/services/ai/impronta_dell_istruzione.dart`) passa da falso a vero, col
commento che porta le parole del fondatore, e la riga della prova *"l'attribuzione
cieca l'ha chiusa il fondatore"* esce da `tool/rossi_accettati.txt`: una riga
che non cade piu' va tolta, o lo sbarramento ferma la build. La misura non si
rifa': e' quella dell'ordine EK, media 96,1 per cento, 173 su 180, ed e' su
quella che il fondatore ha deciso.

**Le guardie.** Regola B: la prova era rossa per costruzione nello
sbarramento della 2280, la sera del 24 settembre 2026. Dopo il cambio e'
verde, uscita vera in `docs/collaudo/EM/attribuzione_chiusa.txt`.

**CHIUSA.**
DOMANDA: "Si il 96 è sufficiente per chiuderla."
PROVA: docs/collaudo/EM/attribuzione_chiusa.txt
MISURA: la prova "l'attribuzione cieca l'ha chiusa il fondatore" da rossa a verde; righe sue in tool/rossi_accettati.txt da 1 a 0

## VOCE EM.04, IL MICROFONO SENTE IL RESPIRO E LA RISPOSTA NON PARTE

Fonte: il fondatore, 25 settembre 2026: *"il microfono è troppo sensibile,
rileva anche solo il respiro, è molto grave perché fin quando il microfono
rileva il minimo rumore, la risposta non parte."* E la sua frase sulla
televisione, qui sopra.

**La causa, due volte.** Prima (fatto 1): il microfono decideva sul solo
volume, e il respiro, un ventilatore o una televisione valevano come voce.
Padre: ordine EJ voce 01. **Prima stesura della cura** (commit `f80e2ced`):
la voce deve essere voce, misurata con l'autocorrelazione fra 70 e 400 cicli
al secondo (`LaMisuraDellaVoce`, soglia 0,55: voce vera al 91 per cento,
respiro e fruscio allo zero), la sorgente delle chiamate con la soppressione
del rumore, e una stanza che ricorda il sottofondo. **Sul Realme, con la
televisione finta, quella stesura ha tenuto aperta una frase per 141,6
secondi** (scena tv1): la stanza imparava solo dai pezzi sotto la soglia
d'inizio, e una televisione piu' forte della soglia non si imparava mai.
Padre: questa stessa voce, prima stesura.

**Il secondo giro** (commit `61bdfd13` e `a7786aef`):

- contro il sottofondo decide la media dell'energia di mezzo secondo, e la
  stanza impara la stessa grandezza;
- una frase aperta su un suono continuo (meno del 35 per cento del tempo
  preso per silenzio) chiede un controllo ogni tre secondi: la trascrizione
  decide, e `IlGiudizioDellaFrase` la scarta se e' solo sottofondo (la stanza
  impara il livello), o la chiude quando le parole smettono di crescere;
- la stanza dimentica dopo dieci secondi senza voce, e il sottofondo vale
  solo con almeno quaranta pezzi di voce recenti: una parola detta piano non
  diventa sottofondo;
- **una frase che sta sopra il sottofondo conosciuto non si scarta e non si
  impara** (scena tv4: un controllo e' tornato vuoto sulla domanda vera e la
  stanza ha imparato la voce della persona, da -26 a -19 dB; padre: questa
  voce, il controllo); senza sottofondo conosciuto servono due controlli
  vuoti di fila, e una frase chiusa vuota non si impara mai;
- con un sottofondo la frase comincia 400 ms prima della voce vicina: il
  secondo di audio di prima portava parole della televisione attaccate ad
  "Aura", e la trascrizione la perdeva cinque volte su cinque;
- il segno `[SILENZIO]` non entra piu' nella domanda (scena tv1, a video e in
  chat; padre: ordine EJ voce 01, che lo toglieva solo quando era la risposta
  intera);
- **una frase con piu' di un secondo di voce vera che torna vuota si
  trascrive di nuovo**, e se torna vuota ancora il Maestro dice *"Non ho
  sentito bene: me lo ripeti?"* e l'orologio del silenzio riparte (build
  finale, stanza silenziosa: "Sono dello Scorpione con ascendente Sagittario
  e la Luna in Capricorno" e' tornata vuota, la domanda si e' persa e il LIVE
  si e' chiuso per silenzio; padre: questa voce, la trascrizione anticipata
  della voce EM.11 presa senza una seconda prova).

**Le misure sul Realme**, scena per scena, in
`docs/collaudo/EM/em04_em05_televisione_e_respiro.txt`: con la televisione
accesa la frase di sola televisione si scarta al primo controllo, la stanza
impara il sottofondo a -26/-27 dB, la televisione non apre piu' frasi, e la
domanda con due pause di un secondo e mezzo si chiude fra 1.995 e 2.004 ms
dopo la fine del parlato e parte, con 9, 10 e 10 parole su 11 (prima: la
frase restava aperta 141,6 secondi e la risposta non partiva). Col respiro
sintetico la frase si chiude a 1.994-1.997 ms e parte. Il vincolo della voce
EJ.01 regge: le due pause di pensiero di un secondo e mezzo non troncano mai.

**Le guardie.** Nuove, tutte viste rosse con un innesto (Regola A, uscite in
scratchpad): `test/la_televisione_non_tiene_aperta_la_frase_test.dart`,
ventisei prove, con la televisione fatta dei 243 pezzi di voce veri della
scena tv1 (una prova e' rimasta verde al primo innesto, quella che cercava la
guardia dello scarto con `indexOf`: senza la riga valeva -1; riscritta e vista
rossa). Regola B: `il_microfono_sente_la_voce_non_il_respiro_test.dart` e
`il_microfono_del_live_non_tronca_test.dart` viste rosse all'inizio del
lavoro; tre prove della prima stesura riscritte con la lapide (la chiusura
con la televisione entro 2.600 ms e non a 2.100; il sottofondo della
televisione alternata a -40,4 e non -38).

Era **APERTA IN ATTESA DI VERIFICA**: la scelta del fondatore, *"Sintetico,
poi il mio"*, voleva il respiro vero e la televisione vera sul suo telefono.
Al banco la persona era la voce di Windows dalle casse del PC, che il modello
puo' scambiare per un apparecchio come la televisione: un pezzo breve in
mezzo alla domanda e' caduto in due scene su cinque.

**La chiude il fondatore sulla build 2281**, con l'ordine EN voce 10 del 25
settembre 2026: *"Microfono calibrato molto bene."*
(`docs/collaudo/EN/en10_verifiche_del_fondatore_sulla_2281.txt`).

**CHIUSA.**
DOMANDA: "Microfono calibrato molto bene."
PROVA: docs/collaudo/EN/en10_verifiche_del_fondatore_sulla_2281.txt
MISURA: frase di sola televisione tenuta aperta, da 141,6 secondi a scartata ai controlli; chiusura della domanda con la televisione accesa a 2,0 secondi dalla fine del parlato; giudizio del fondatore sul suo telefono, 1 su 1

## VOCE EM.05, DOPO 30 SECONDI IL LIVE NON SI FERMA E CONSUMA CREDITI

Fonte: il fondatore, 25 settembre 2026: *"Dopo 30 secondi non si blocca da
solo e continua a consumare crediti."*

**La causa** e' quella della voce EM.04: finche' il respiro o la televisione
valevano come voce, la persona "parlava" e l'orologio dei trenta secondi non
contava. Padre: ordine EJ voce 01. La cura e' quella della voce EM.04; la
chiusura della sessione di Protoface c'era gia' dall'ordine EJ
(`sessions/{id}/end`).

**Sul Realme**, in tutte le scene del banco, il LIVE si e' chiuso da solo:
*"LIVE: chiusa dopo 30 secondi di silenzio"* con la televisione ancora
accesa (scene tv2, tv3, tv5) e col respiro sintetico (respiro1, respiro2).
**Sul server**, registro di Cloud Run: la sessione della scena tv2 aperta
alle 01:50:19 UTC, *"LIVE chiuso dal telefono"* alle 01:52:34; i secondi
addebitati del mese, letti a ogni apertura, sono passati da 11.850 a 11.987,
**137 secondi per una sessione di 135**: dopo la chiusura non si paga piu'
niente. Tutto in `docs/collaudo/EM/em04_em05_televisione_e_respiro.txt`.

**APERTA IN ATTESA DI VERIFICA**, con la voce EM.04: il respiro vero e la
televisione vera sono la prova del fondatore.

## VOCE EM.06, LA VOCE SCELTA NEL SELETTORE NON SI APPLICA

Fonte: il fondatore, 25 settembre 2026: *"Quando seleziono la voce nel
selettore anche se scelgo una voce diversa, questa non viene applicata
realmente, funziona solo il preview della voce."*

**La causa** (fatto 5): la scelta si leggeva al massimo una volta al minuto,
in memoria di ogni servizio Cloud Run, e la porta che parla nel LIVE non
sapeva che era cambiata; e nessun registro diceva quale voce aveva parlato.
Padre: ordine EJ voce 02, che ha messo la scelta in memoria per un minuto.

**Fatto sul server** (pubblicato il 25 settembre 2026): la scelta si rilegge
da `configurazione/live` se ha piu' di tre secondi (`LA_SCELTA_VALE_MS`), in
ogni servizio; e ogni voce del Maestro scrive nel registro la riga *"voce del
Maestro"* con la voce, la famiglia, il modello e il punto. Prova nuova in
`functions/src/live.test.ts`, *"la voce scelta si rilegge entro tre secondi e
il registro dice quale voce ha parlato"*, vista rossa riportando il tempo a
un minuto e togliendo la voce dal registro (`regola_a_server_em`).

**Nel LIVE vero, sul Realme, con le scelte che il fondatore aveva gia'
fatto** la sera del 24 settembre (Despina per Medora, Orus per Calìgo): il
registro del server scrive *"voce del Maestro"* con Orus per le tre frasi di
Calìgo e Despina per il saluto di Medora; Aura, senza scelta, con Autonoe
(`docs/collaudo/EM/em06_em12_le_voci_nel_live.txt`). Prima nessun registro
diceva quale voce avesse parlato.

**APERTA IN ATTESA DI VERIFICA.** Per ordine la chiude una registrazione di
un LIVE dopo la scelta, con la voce uguale all'anteprima: il selettore sul
Realme aspetta l'account fra i fondatori (voce EM.02), e il confronto con
l'anteprima e' del fondatore. La voce EJ.02 resta aperta finche' lui non la
verifica.

## VOCE EM.07, L'ELENCO DELLE VOCI NON SCORRE

Fonte: il fondatore, 25 settembre 2026: *"Non posso scorrere le voci, lo
scorrimento non funziona."*

**La causa** (fatto 3): le candidate stavano in una `Column` senza
scorrimento. Padre: ordine EJ voce 02, che ha scritto il selettore; l'elenco
e' cresciuto con l'ordine EK (tutte le voci del genere) e con la voce EM.02
(le Chirp), fino a trentadue per Calìgo.

**Fatto**: l'elenco e' un `ListView` dentro un `Flexible`, e il foglio arriva
all'85 per cento dello schermo (`il_selettore_delle_voci.dart`). La prova
nuova `test/il_selettore_scorre_e_il_microfono_riparte_test.dart` monta le
trentadue candidate di Calìgo, scorre fino all'ultima, `Chirp3-HD-Sadaltager`,
e la sceglie; vista rossa rendendo l'elenco fermo
(`NeverScrollableScrollPhysics`, `regola_a_client_em`).

**APERTA IN ATTESA DI VERIFICA**: la registrazione dello schermo del Realme
aspetta l'account fra i fondatori (voce EM.02).

## VOCE EM.08, DOPO IL SELETTORE IL MICROFONO NON FUNZIONA PIÙ

Fonte: il fondatore, 25 settembre 2026: *"Quando torno indietro dal
selettore, il microfono non funziona più."*

**La causa**: il registratore del LIVE si apriva col modo di serie, che
chiede il fuoco audio e alla prima perdita si mette in pausa per sempre (la
ripresa esiste solo nel modo `pauseResume` di `record_android`); l'anteprima
delle voci suona con un lettore che chiede il fuoco. Padre: ordine EJ voce
01, che ha aperto il microfono col modo di serie.

**Fatto**: il microfono non chiede e non perde il fuoco
(`AudioInterruptionMode.none`, in `LOrecchioDelLive.configurazione`), e il
selettore chiude il microfono prima di aprirsi e lo riapre alla chiusura,
anche se cade (`_apriIlSelettore`, con un `finally`); mentre si sceglie la
voce l'orologio del silenzio non conta. Prove nella stessa
`test/il_selettore_scorre_e_il_microfono_riparte_test.dart`, viste rosse
rimettendo il modo `pause` e togliendo la chiusura del microfono prima del
selettore (`regola_a_client_em`).

**APERTA IN ATTESA DI VERIFICA**: la registrazione sul Realme con selettore,
ritorno e domanda aspetta l'account fra i fondatori (voce EM.02).

## VOCE EM.09, LA DOMANDA A VIDEO SOPRA LA RISPOSTA

Fonte: il fondatore, 25 settembre 2026: *"Quando faccio una domanda, la
domanda dovrebbe comparire in grande e in giallo anche nel testo subito
sopra la risposta, invece adesso compare solo la risposta."*

**La causa** (fatto 4): domanda e risposta erano lo stesso testo, e la
risposta cancellava la domanda. Padre: ordine EG voce 05, che ha fatto il
sottotitolo alto quanto il suo testo.

**Fatto**: `LaScenaDelLive` (`lib/features/maestri/live/la_scena_del_live.dart`)
e' la composizione che la schermata monta: una zona del testo di altezza
fissa, con **la domanda sopra, nella serif della lettura in grassetto e in
oro**, 20 punti, e la risposta sotto, nel corpo da 16, che scorre. Sul
Realme la prima stesura usava il maiuscoletto dei titoli, grande ma faticoso
su una frase lunga (cattura della scena tv1); la guardia di casa
`etichette_e_lettura` ha preso la serif rossa, e la domanda e' entrata fra le
sue frasi brevi ammesse, con la motivazione scritta. Prova nuova
`test/la_scena_del_live_non_salta_test.dart`, vista rossa dimezzando la zona
del testo quando c'e' una domanda e rimettendo la risposta al posto della
domanda (`regola_a_client_em`).

**Sul Realme** (scena tv3, build di collaudo): la domanda in oro sopra la
risposta durante la risposta, tre righe, e la risposta sotto; tre catture
affiancate, ascolto, attesa, risposta.

**CHIUSA.**
DOMANDA: "Quando faccio una domanda, la domanda dovrebbe comparire in grande e in giallo anche nel testo subito sopra la risposta, invece adesso compare solo la risposta."
PROVA: docs/collaudo/EM/em09_em10_ascolto_domanda_risposta.jpg
MISURA: righe della domanda a video mentre il Maestro risponde, da 0 a 3; corpo della domanda 20 punti contro i 16 della risposta

## VOCE EM.10, L'IMMAGINE DEL MAESTRO CHE CAMBIA MISURA DI SCATTO

Fonte: il fondatore, 25 settembre 2026: *"Quando faccio una domanda
l'immagine del maestro s'ingrandisce di botto e poi si riduce di botto
quando inizia a rispondere."*

**La causa** (fatto 4): il volto stava in un `Expanded` sopra un
sottotitolo alto quanto il suo testo, e la barra dell'ascolto compariva e
spariva. Padre: ordine EG voce 05.

**Fatto**: nella `LaScenaDelLive` la zona del testo ha un'altezza fissa, il
27 per cento dello spazio, e la riga dello stato e il posto della barra ci
sono sempre, anche vuoti.

**La misura.** In una prova di widget, finestra 390x844, la disposizione
della 2280 ricostruita (commit `8a44fa3f`, righe 664-708) e la scena di
adesso: il volto era alto 680 punti al saluto, 669 in ascolto, 656 alla
domanda e **567 alla risposta lunga**, 89 punti in meno di colpo quando il
Maestro comincia a rispondere; adesso **497 in tutti e quattro i momenti**
(`docs/collaudo/EM/em10_volto_prima_e_adesso.txt`). Il volto e' piu' piccolo
di prima, e non cambia piu'. **Sul Realme**, scena tv3: 43 catture
dall'ascolto alla risposta, l'arco d'oro del volto 731x915 pixel nella stessa
posizione in tutte e 43 (`docs/collaudo/EM/em10_arco_del_volto.txt`; la prima
misura prendeva per arco anche la domanda scritta in oro sotto il volto, e
l'area e' stata ristretta al bordo dell'arco).

**CHIUSA.**
DOMANDA: "Quando faccio una domanda l'immagine del maestro s'ingrandisce di botto e poi si riduce di botto quando inizia a rispondere."
PROVA: docs/collaudo/EM/em10_volto_prima_e_adesso.txt
MISURA: altezza del volto fra la domanda e la risposta, da 656 e 567 punti a 497 e 497; sul Realme 1 rettangolo dell'arco su 43 catture

## VOCE EM.11, L'ATTESA PRIMA DELLA RISPOSTA

Fonte: il fondatore, 25 settembre 2026: *"Da quando faccio una domanda a
quando ottengo risposta passano diversi secondi, circa 4."*

**La causa**, misurata sul Realme con la 2280 frase per frase: dopo i due
secondi di silenzio che chiudono la frase, la trascrizione cominciava solo a
frase chiusa e prendeva da 1,31 a 1,93 secondi; poi la chat, da 1,59 a 4,44,
e il primo audio, da 0,60 a 0,74. Padre: ordine EJ voce 01, che trascrive a
frase chiusa.

**Fatto** (commit `f80e2ced`): la trascrizione comincia quando la frase va in
pausa, a 700 millesimi di silenzio (`IlSilenzioVero.silenzioDiPausa`,
`_inPausa` nella schermata), e se la frase si chiude con quella stessa pausa e'
gia' pronta. I due secondi dell'ordine EJ restano, per non troncare. Il
registro scrive l'attesa pezzo per pezzo (*"LIVE ATTESA"*, fino all'evento del
volto che parla) e, dalla chat, *"CHAT TEMPI"*. Prova nuova
`test/la_risposta_arriva_prima_e_aura_si_scrive_giusta_test.dart`, vista rossa
togliendo la condizione della stessa pausa (`regola_a_client_em`).

**La misura** (`docs/collaudo/EM/em11_l_attesa_pezzo_per_pezzo.txt`): la
trascrizione, dopo la chiusura, e' passata **da 1.311-1.930 millesimi a
0-451** (1.387 quando serve la seconda prova della voce EM.04). Con una
risposta nuova della chat il primo audio arriva a 5,0-5,1 secondi dalla fine
della domanda, contro 5,8-9,1 della 2280 (mediana 6,3), e il volto parla a 6,5.

**Cosa resta, e non e' di quest'ordine deciderlo.** La chat, da 1,4 a 4,7
secondi secondo la lunghezza della risposta: le risposte del LIVE durano da 15
a 60 secondi di voce, e dentro la chat due scritture su Firestore costano circa
mezzo secondo. I due secondi di silenzio, che accorciati riportano la domanda
troncata della voce EJ.01. Protoface, da 1,3 a 1,6 secondi dal primo audio al
volto che parla, fuori dal nostro codice. Le strade per scendere ancora sono
scelte del fondatore: risposte del LIVE piu' brevi, o la voce che comincia
mentre la chat scrive, che oggi non si puo' fare senza saltare i controlli
della risposta intera (troncatura, ancoraggio, cielo smentito).

**APERTA IN ATTESA DI VERIFICA**: *"circa 4"* secondi li ha contati il
fondatore sul suo telefono; se l'attesa di adesso gli basta lo dice lui.

## VOCE EM.12, LE VOCI DI CALÌGO RALLENTATE

Fonte: il fondatore, 25 settembre 2026: *"qualunque voce di Caligo è
rallentata."*

**La causa**: il modo della voce di Calìgo portava parole sul timbro, e
**qualunque parola sul timbro rallenta**: col modo "con voce grave e matura di
uomo, con calma naturale" le sedici voci parlavano fra 9,1 e 11,1 caratteri
al secondo, e il parlato italiano naturale sta fra 13 e 15. Padre: ordine EK,
sezione "Fuori dalle voci", che ha scritto i modi per Maestro.

**Fatto sul server** (pubblicato il 25 settembre 2026): il modo di Calìgo e'
*"Leggi in italiano, con la pronuncia di un madrelingua italiano, a ritmo di
conversazione:"*; il timbro lo da' la voce scelta. Vale per tutte le voci di
Calìgo, anche quella di partenza, perche' il server prende sempre il modo
per Maestro. Prova nuova in `functions/src/live.test.ts`, *"il modo di Calìgo
non porta le parole che lo rallentano"*, vista rossa mettendo "con calma"
nel modo (`regola_a_server_caligo`).

**La misura**, sul testo lungo dell'ordine EK, Gemini 2.5 Flash TTS in
europe-west1: prima fra 9,1 e 11,1 caratteri al secondo, mediana 10,1 su
sedici voci; dopo fra 11,8 e 15,3, mediana 13,5 su trentasette misure in tre
giri (`docs/collaudo/EM/caligo/ritmo_delle_voci.txt`), con le sedici
registrazioni prima e dopo nella stessa cartella. **Nel LIVE vero sul Realme**,
con Orus, la voce scelta dal fondatore: una risposta di 331 caratteri in 24,0
secondi di voce, **13,8 caratteri al secondo** pause comprese
(`docs/collaudo/EM/em06_em12_le_voci_nel_live.txt`).

Era **APERTA IN ATTESA DI VERIFICA**: il giudizio all'orecchio era del
fondatore, per ordine. **Lo ha dato sulla build 2281**, con l'ordine EN voce
10 del 25 settembre 2026: *"Voce Caligo ok."*

**CHIUSA.**
DOMANDA: "Voce Caligo ok."
PROVA: docs/collaudo/EN/en10_verifiche_del_fondatore_sulla_2281.txt
MISURA: caratteri al secondo di Calìgo, da 9,1-11,1 a 11,8-15,3 (13,8 nel LIVE vero con Orus); giudizio all'orecchio del fondatore, 1 su 1
