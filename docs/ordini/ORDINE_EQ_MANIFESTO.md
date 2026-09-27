# ORDINE EQ, LE CHAT CHE RISPONDONO E LA STESA DI TAROCCHI CHE INTERPRETA

**Sigla:** EQ, verificata sul ramo il 27 settembre 2026: in `docs/collaudo`
l'ultima cartella era EP, nessun `ORDINE_EQ_*`, nessuna `docs/collaudo/EQ`.
**Data dell'ordine:** 27 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Le consegne del fondatore, a ordine aperto**: alla domanda su come
procedere, *"Tutto, a parti"*: prima le chat (EQ.01-03), poi i tarocchi
(EQ.04-06), poi i difetti delle catture (EQ.07-12), con un commit per voce;
e *"Lascia stare i riferimenti a iPhone 17, non è collegato e non posso
usarlo ancora. Solo gli screenshot sono corretti e appartengono a iPhone
17"*: le voci grafiche si provano alla misura dell'iPhone 17 Pro, 402 per
874 punti con la piattaforma iOS nelle prove, e si guardano sul Realme.
**Questo ordine non consegna niente**: le build le ordina il fondatore.

VOCI_TOTALI: 12
VOCI_CHIUSE: 5
VOCI_APERTE: 7
VOCI_DA_FARE: 0

Le prove stanno in `docs/collaudo/EQ/`; quelle viste sul telefono di prova
(Realme 767f596c, 360 per 800 punti) in `docs/collaudo/EQ/realme/`. Una
voce prodotta ma non ancora guardata sul Realme e' APERTA IN ATTESA DI
VERIFICA: le catture si fanno con una build sola, a voci finite.

**La build di prova**, 27 settembre 2026, installata sul Realme e mai
consegnata: `flutter build apk --release` dal ramo con tutte le voci, codice
0.1.0+2284 come la build che il Realme aveva, nessun file tracciato toccato
dalla costruzione. Le catture con quella build si chiamano
`realme/*_build_eq_*`.

**Le risposte del fondatore al rapporto**, 27 settembre 2026: *"1 I turni
Live contano come domande. 2 no. L'attesa deve diminuire, non aumentare. 3
la pillola bianca è un'invenzione dell'architetto, lascia perdere. Prosegui
con tutto Senza fermarti"*. Il lavoro che ne e' seguito sta nelle voci EQ.03,
EQ.04, EQ.07 ed EQ.10. **Una seconda build di prova**, dal commit `34e56fcb`,
stesso codice 0.1.0+2284, installata sul Realme e non consegnata: le catture
con lei si chiamano `realme/*_build_eq2_*`. **Una terza**, dal commit
`781d7beb`, per l'attesa del LIVE: `realme/*_build_eq3_*`.

---

## PARTE 1, LA CHAT

## VOCE EQ.01, LA RIGA D'ORO NON SI RIPETE

Nelle catture la stessa riga d'oro, *"Scrivi su un foglio di carta bianca
tre cose che vorresti realizzare"*, chiudeva la presentazione, la risposta
sui tre desideri, *"Ok, gli ho scritto adesso."* nel LIVE e *"Ok, le ho
scritte e adesso cosa faccio?"*: quattro righe, tre ripetute, una sotto la
presentazione, due dopo un passo gia' fatto.

- **L'esempio esce dall'istruzione** (`ConsiglioFinale.istruzione`): il
  modello lo ricopiava, e nel collaudo "prima" Medora nel LIVE ha scritto
  proprio *"Stasera scrivi su un foglio le tre cose che vuoi dirgli"*.
  L'eccezione si allarga a chi saluta o chiede che cosa fa il Maestro o come
  puo' aiutarlo; e un passo appena fatto non si chiede di rifare.
- **A valle, `IlPassoDaNonDare`** (lib/core/chat): la riga si toglie sotto
  una presentazione, quando e' uguale o simile a una gia' data (la misura di
  casa, 0,32, piu' due parole piene in comune, tarata su 1.202 coppie vere
  dei collaudi EJ, EK ed EN) e quando chiede di rifare il verbo del passo
  appena detto fatto (*"le ho scritte"* e *"Scrivi..."*). Vale anche nel LIVE.
- **La bolla** non mostra la riga, ne' l'invito a tornare, sotto la risposta
  a una presentazione, anche nelle conversazioni gia' salvate.
- **Il LIVE, mentre il testo arriva**, si ferma alla stella: una riga che le
  reti tolgono non passa a video nemmeno per un istante.
- **Un difetto trovato dal collaudo e curato** (padre: questa voce, prima
  stesura): nel LIVE Flash-Lite ha risposto con la sola riga d'oro della
  risposta prima; la regola la lasciava per non consegnare una bolla vuota.
  Adesso una risposta fatta della sola riga da togliere si chiede di nuovo,
  una volta, e se torna uguale arriva la lettura di ripiego, mai la riga.

**CHIUSA.** Sul Realme, con la build di prova, la conversazione delle catture
rifatta con Calìgo in chat: alla presentazione nessuna riga d'oro, e gli
altri Maestri nominati solo in fondo
(`realme/eq01_eq07_build_eq_presentazione_senza_riga_d_oro_e_residuo_dei_confronti.png`);
le due righe d'oro dei turni dopo sono diverse fra loro e nessuna chiede di
rifare il passo appena detto fatto (`realme/eq02_build_eq_tre_desideri_fine.png`,
`realme/eq03_build_eq_chat_le_ho_scritte.png`).
DOMANDA: "C'è un grosso problema con le chat e sono incazzato nero!"; "Unisci tutto all'ordine prossimo credo EQ"
PROVA: docs/collaudo/EQ/realme/eq01_eq07_build_eq_presentazione_senza_riga_d_oro_e_residuo_dei_confronti.png
MISURA: sul Realme, conversazione delle catture rifatta: presentazioni con la riga d'oro da 1 (catture) a 0, righe d'oro ripetute da 3 su 4 (catture) a 0 su 2; nel collaudo (docs/collaudo/EQ/eq01_righe_d_oro.txt) a schermo, due giri con dati diversi per ciascun Maestro: righe d'oro uguali o simili a una gia' data da 3 su 30 a 0 su 22 (catture: 3 su 4); presentazioni con la riga d'oro da 6 su 12 a 0 su 12 (catture: 1); righe che chiedono di rifare il passo appena fatto da 2 su 12 a 0 su 12; quattro giri di fila puliti sull'istruzione definitiva

## VOCE EQ.02, IL MAESTRO RISPONDE CON LA SUA ARTE

La regola del cerchio dell'ordine EN, *"la tua prima frase lo dice e lo
chiama per nome"*, e' sostituita: il Maestro risponde sempre nel merito con
la sua arte, a ogni parte della domanda; l'altro Maestro si nomina solo in
fondo, in una frase, come consiglio in piu'. Restano le parole di firma, le
arti degli altri due che non si usano e chi di dovere.

- **L'istruzione**: il blocco del cerchio (`VoceDelMaestro.ilCerchio`), le
  due righe del dominio (`MaestroPersona`), la risposta nel merito con le
  domande a piu' parti e col si' o il no in prima frase
  (`LaRispostaNelMerito`), e il controllo prima di scrivere in fondo
  all'istruzione.
- **A valle, `IlRimandoInFondo`**: la prima frase che nomina un altro Maestro
  si sposta in fondo al corpo, prima della riga d'oro. Nel collaudo, con la
  regola gia' scritta, Medora ha aperto ancora con *"Non posso indicarti un
  rito... perché i riti sono l'arte di Calìgo"*.
- **L'attribuzione cieca e' rifatta**: 96,7, 98,3 e 95,0 per cento, media
  96,7 (174 su 180), contro l'89,1 dell'ordine EO.

**APERTA IN ATTESA DI VERIFICA**, e non solo per la cattura dal Realme: le
parti della domanda senza risposta scendono da 15 a 8 su 28, non a 0.
Calìgo resta il piu' debole: alla domanda delle catture risponde a volte in
generale, per sentenze. **E sul Realme, con la build di prova, lo ha fatto
davanti alla domanda delle catture**: *"Prendi un solo sentiero alla volta.
Non disperdere la tua forza."* e la riga *"Scegli una sola priorità fra la
compagna, l'Australia o il lavoro"*, cioe' proprio cio' che il controllo
finale vieta (`realme/eq02_build_eq_tre_desideri_scegline_uno.png`).
DOMANDA: domanda girata al fondatore: "Chat: quando la domanda tocca l'arte di un altro Maestro (es. l'amore chiesto a Calìgo), come deve rispondere?", risposta: "Prima la sua arte" ("Risponde sempre nel merito con la sua arte (Calìgo: un rito per l'amore). L'altro Maestro lo nomina solo in fondo, come consiglio in più. Cambia la regola dell'ordine EN.")
PROVA: docs/collaudo/EQ/eq02_domande_di_confine.txt
MISURA: su diciotto domande di confine per giro (sei per Maestro, fra cui quella delle catture), prime frasi che rimandano a un altro Maestro da 9 a 0; parti della domanda senza risposta, stesso giudice, da 15 a 8 su 28; attribuzione cieca da 89,1 a 96,7 per cento

## VOCE EQ.03, LE RISPOSTE NEL MERITO, ANCHE NEL LIVE

Nelle catture del LIVE, a *"Ok, le ho scritte e adesso cosa faccio?"*
Calìgo risponde *"Il tuo gesto è compiuto. Ora lascia che il tempo faccia il
suo corso."*: non dice niente.

**Il collaudo** (`tool/collaudo_eq03.dart`): dodici domande di seguito per
Maestro, fra cui le due delle catture, nel LIVE con Flash-Lite, nel LIVE con
Flash e in chat, due giri per modo, Gemini vero in europe-west1; prima sul
codice di prima dell'ordine (commit `168d7cce`), dopo sul codice curato.
**Il merito non lo decide Gemini**: quattro stesure del giudice, tarate su
risposte vere etichettate a mano, nel controllo sono arrivate a 33, 33 e 29
su 43 (`eq03/il_giudice_gemini_non_basta.txt`). Lo decide una lettura con la
regola scritta (`eq03/regola_della_lettura.md`), fatta da agenti di lettura
sulle trascrizioni senza verdetti e controllata sulle 78 risposte che avevo
etichettato a mano: 76 accordi.

**La cura, in tre ritocchi misurati.**
- **L'istruzione**: la regola comune dice di partire da cio' che la persona
  ha appena fatto o raccontato e di darle il passo dopo, e che "aspetta" da
  solo non e' una risposta (`LaRispostaNelMerito`); il controllo finale
  chiede se la prima frase parte da li' e se ogni frase vale per lei sola; la
  forma del LIVE chiede che la prima frase dica che cosa fare in concreto
  (`MaestroPersona.rispostaDettaAVoce`).
- **Gli esempi da ricopiare escono**: l'apertura di Medora portava *"Scrivi
  stasera a chi ti ha ferito e proponi di vedervi sabato mattina"*, che
  Flash-Lite ricopiava come riga d'oro a chi non aveva nominato ferite (tre
  volte su dodici nel "prima"). Il registro di Aura le vietava ogni momento
  ("Non nomini mai il futuro né una data") e con lui il passo: adesso
  risponde con un passo nella vita della persona e il corpo le dice come
  farlo, legato a un gesto e mai a un giorno.
- **La rete a valle** (`LaRispostaDAttesa`): se le prime due frasi dicono
  soltanto di aspettare ("il tuo gesto è compiuto", "ora attendi la sua
  risposta", "il tuo compito è la pazienza"), il controller chiede la
  risposta di nuovo, una volta, con una nota che dice che cosa fare di
  un'attesa; l'attesa misurata passa. Vale in chat e nel LIVE.

**Il modello del LIVE: Flash.** L'ordine dice *"per il LIVE resta il modello
che risponde nel merito; fra due che rispondono nel merito, il più veloce"*.
Letti con la stessa regola: Flash-Lite nel merito 18 su 72 prima, 36 e 27 su
72 nei due giri dopo; Flash 52 e 54 su 72. Flash-Lite non risponde nel
merito, quindi resta Flash (`FirebaseMaestroAiProvider.kMaestroLiveModel`).
Il tempo del modello mediano sale da 781 a 1175 millesimi dal PC; **sul
Realme, dalla fine della domanda al Maestro che parla, mediana 6,4 secondi
su sei turni** (Medora 6986, 6468, 6111; Calìgo 8210, 6039, 6322 ms), contro
i 4,8 dell'ordine EO con Flash-Lite. Il costo di un turno del LIVE, stimato
dal listino e dalla lunghezza dell'istruzione (circa 5.200 gettoni),
sale da circa 0,0006 a circa 0,002 dollari.

**Sul Realme** (`realme/eq03_live_medora/`, `realme/eq03_live_caligo/`), con la
voce detta dalle casse del PC: a *"Ok, le ho scritte e adesso cosa faccio?"*
Medora risponde *"Ora che hai messo per iscritto i tuoi desideri... Scegli un
giorno... e descrivi per iscritto quale desiderio"*, senza nessuna attesa; a
*"Ok, gli ho scritto adesso."* Calìgo chiede che cosa intende; in chat, alla
domanda delle catture, Calìgo da' un passo (*"Pronuncia a voce alta la tua
priorità davanti a uno specchio"*). Le risposte di Flash nel LIVE sono piu'
lunghe delle tre frasi che la forma chiede.

**La risposta del fondatore sull'attesa**: *"2 no. L'attesa deve
diminuire, non aumentare."* **Prima un fatto**: i 4,8 secondi dell'ordine EO
erano misurati su risposte gia' date quel giorno, che la chat restituiva in
2-7 millesimi senza chiedere niente al modello
(`docs/collaudo/EO/live/logcat_eo14_dopo_*.txt`): quel numero non ha mai
contenuto il modello. Padre: ordine EO voce 14, una misura che rispondeva a
un'altra domanda. **Poi la cura, dove l'attesa si lascia accorciare senza
togliere il merito** (`docs/collaudo/EQ/live_attesa/attesa_del_live.txt`):
- **la voce della prima frase si compone mentre il modello scrive**
  (`LaVoceAnticipata`) e **il flusso verso il volto si apre col suo primo
  pezzo**: dalla risposta al primo audio al volto, mediana da 709 millesimi a
  2 nella seconda build di prova, 373 nella terza. La voce parte ancora solo
  dalla risposta passata dalle reti, come ha deciso il fondatore con l'ordine
  EM;
- **la trascrizione in pausa parte a 400 millesimi di silenzio invece di
  700**, perche' torni in tempo per la regola della domanda finita a 1,3
  secondi: sul Realme due frasi su cinque si sono chiuse a 1,83 secondi
  invece di 2. La chiusura resta a due secondi per le frasi che non finiscono
  con una domanda, come ha voluto il fondatore con l'ordine EJ;
- **la tappa "si sente"** nel registro, dall'energia dell'audio ricevuto dal
  volto: la persona sente il Maestro fra 0,1 e 0,6 secondi prima di quando
  LiveKit se ne accorge ("il volto parla").

**I numeri, sul Realme**, mediane dalla fine della domanda: "il volto parla"
da 6.468 millesimi (prima build di prova, sette turni) a 6.072 (seconda,
sette turni) e 6.226 (terza, cinque turni, due con la trascrizione rifatta);
**"si sente" 5.710**. **Cio' che resta e non si accorcia senza una scelta del
fondatore**: due secondi di silenzio prima di chiudere una frase che non
finisce con una domanda (ordine EJ), circa un secondo e mezzo del volto di
Protoface dal primo audio alla voce, circa un secondo e mezzo fra
trascrizione e modello. **Un difetto trovato**, PROVENIENZA probabile ordine
EM voce 04: due frasi su cinque sono tornate vuote dalla trascrizione in pausa; una e' arrivata come *"E adesso"* invece di *"ho provato a
camminare scalza sull'erba come mi hai detto. E adesso?"*. L'istruzione
della trascrizione chiede di ignorare le voci di sottofondo come la radio: la voce sintetica delle casse del PC lo sembra: si e' visto anche con la
pausa a 700 millesimi, una volta su sette. Non cambiato alla cieca.

**La chat**: la regola della prima frase concreta del LIVE, portata nella
chat, al banco e letta alla cieca insieme alla chat di prima dagli stessi
lettori, fa 42 su 72 contro 47: non migliora, e' tolta
(`docs/collaudo/EQ/eq03_chat_prima_frase_alla_cieca.txt`).

**APERTA IN ATTESA DI VERIFICA**: il merito sale ma non arriva al pieno, e
alla domanda delle catture il LIVE con Flash risponde nel merito 3 volte su 6
nel collaudo; l'attesa scende di poco; Aura resta la piu' debole (in chat 5 e 4 su 12); la chat non
migliora (46 su 72 prima, 45 e 42 dopo) e fra un giro e l'altro lo stesso
Maestro passa da 11 a 5 su 12.
DOMANDA: "C'è un grosso problema con le chat e sono incazzato nero!"; "Unisci tutto all'ordine prossimo credo EQ"
PROVA: docs/collaudo/EQ/eq03_nel_merito.txt
MISURA: risposte nel merito su dodici domande di seguito, tre Maestri, due giri: LIVE con Flash-Lite da 18 su 72 prima a 36 e 27 su 72 dopo, LIVE con Flash 52 e 54 su 72 dopo; alla domanda delle catture nel LIVE da 0 su 6 prima a 3 su 6 con Flash; dalla fine della domanda al volto che parla, sul Realme, mediana da 6.468 ms (prima build di prova) a 6.072 e 6.226 ms; il Maestro si sente a 5.710 ms; i 4,8 secondi dell'ordine EO erano misurati senza modello

## PARTE 2, LA STESA DI TAROCCHI

## VOCE EQ.04, LA STESA INTERPRETA DAVVERO

**La via scelta.** Una chiamata a Flash per la lettura intera
(`lib/core/tarot/la_lettura_dal_modello.dart`), col ragionamento spento e la
risposta in sei campi: la risposta, le tre carte, il legame, il consiglio.
Riceve la domanda, l'argomento, la carta chiave della schermata e per ogni
carta il significato tradizionale. Le guardie guardano a valle: tetti, il nome
di ogni carta, niente cifre, il confine del responso, nessun genere dato a chi
legge contro la sua forma; il trattino lungo e la virgola con la "e" si
correggono. Fino a tre richieste in dieci secondi, col motivo dello scarto
scritto; se il solo difetto e' il genere, una richiesta breve riscrive le
frasi colpevoli nominando la parola; finiti i tentativi, quelle frasi si
tolgono, mai dalla risposta. **Senza modello** la lettura di casa ha sotto
ogni carta il testo della sua posizione, uno dei 468 scritti una volta sola
(`docs/corpus/tarocchi_nella_posizione.md`). **Nessuna cache**: 58 milioni di
chiavi fra stese ordinate, versi e argomenti, la quota servita dalla cache e'
0. La schermata aspetta la lettura dentro la scena di Medora e ne scrive il
tempo nel registro (`STESA TEMPI`).

**Misure, coi giudici tarati su undici casi noti**
(`docs/collaudo/EQ/tarocchi/taratura_dei_giudici.txt`): prima, la lettura di
casa, risposte dirette 1 su 20 e carte lette sulla domanda 0 su 60; dopo, due
giri con dati diversi dello stesso codice, 19 e 17 su 20 e 53 e 43 su 60;
letture uguali su cento 0 in tutti e tre. Costo medio di una stesa 0,00177 e
0,00191 dollari; tempo dal PC mediano 3,7 secondi in tutti e due i giri.

**Sul Realme, con la build di prova**, tre stese con tre domande diverse
(`realme/eq04_build_eq_attesa_della_stesa.txt`): dal tocco su "Leggi le Carte"
al testo **3931 e 4011 millesimi** con la lettura del modello; una volta la
chiamata non e' tornata entro i dieci secondi e a **10001 millesimi** e'
arrivata la lettura di casa, che apre ancora con *"Le tre carte rispondono a
«...». Non a una domanda in generale."*
(`realme/eq04_build_eq_stesa_2_lettura_di_casa_dopo_10_secondi.png`). Nelle
altre due la prima frase risponde: *"Le carte indicano che non è il momento
giusto per cambiare lavoro questo inverno"*.

**La richiesta di riserva** (`LaLetturaDellaStesa.primaCheTorna`): se dopo
4,5 secondi la chiamata non e' tornata ne parte una seconda uguale: vince la prima che torna. Padre del difetto: questa voce, che ritentava solo dopo
una lettura tornata. Guardia `la_stesa_ha_una_richiesta_di_riserva` (tre innesti rossi, piu' uno finto riconosciuto e rifatto sul difetto vero). Sul
Realme con la seconda build di prova, una stesa letta dal modello in 7.458
millesimi, con due chiamate e una riscrittura del genere, nessuna riserva
servita (`realme/eq04_build_eq2_attesa_della_stesa.txt`,
`realme/eq04_build_eq2_stesa_letta_dal_modello.png`). **La lettura di casa
apre ancora in modo criptico** (padre dell'apertura: ordine DF, commit
`185ac548`); con la riserva parla solo senza rete o se anche la seconda
chiamata non torna.

**APERTA IN ATTESA DI VERIFICA**: le misure non arrivano a 20 su 20 e 60 su 60; sul Realme una stesa su tre era finita nella lettura di casa; la
riserva e' provata nelle prove e non ancora vista scattare sul telefono.
DOMANDA: "Il fondatore si lamenta che facendo una stesa tarocchi con domanda generica, ma anche con domanda specifica e personale LE RISPOSTE SONO TROPPO CRIPTICHE, SONO QUASI SENZA SENSO. SCRIVE QUALCOSA ,MA NON DICE NULLA."; "Ma una interpretazione la fa veramente o sono testi buttati lì tanto per accontentare?"
PROVA: docs/collaudo/EQ/tarocchi/dopo_giro_1/letture.md
MISURA: risposte dirette nelle prime due frasi da 1 su 20 a 19 e 17 su 20 (due giri); carte lette nella posizione e sulla domanda da 0 su 60 a 53 e 43 su 60; errori di concordanza, contati a mano, da 3 su 20 letture ("c'e' stata Quattro di Coppe") a 0 su 40; letture uguali su cento 0 prima e dopo; sul Realme dal tocco al testo 3931 e 4011 ms col modello, 10001 ms col ripiego una volta su tre

## VOCE EQ.05, LA SCRITTA SOTTO LA CARTA CHIAVE

La carta chiave era ingrandita col solo disegno attorno al suo centro:
debordava sotto di un ventesimo della sua altezza e copriva "PRESENTE",
mentre le vicine si ritiravano di sette centesimi. Adesso le tre carte
crescono e si ritirano dal loro bordo basso, e ogni scritta sta a sedici
punti dalla sua carta; lo spazio delle parole "Carta Chiave" si misura sulla
larghezza della carta, che ora sale tutta verso l'alto.

**APERTA IN ATTESA DI VERIFICA**: sul Realme con la build di prova si vede come atteso (`realme/eq04_eq05_eq12_build_eq_carta_chiave_scritta_staccata_e_consiglio_intero.png`); resta aperta finche' il fondatore non la guarda sull'iPhone, regola 5 dell'ordine.
DOMANDA: "Inoltre, esteticamente, la parola "passato, presente o passato" sotto alla carta chiave ingrandita e attaccata alla carta grande."; "Ti segnalo che gli screenshot sono di un iPhone 17 pro."
PROVA: test/la_stesa_si_legge_intera_test.dart
MISURA: distanza fra la carta chiave e la sua scritta da circa -6 punti (la carta la copriva) a 16,0, uguale alle altre due (16,0 e 16,0), a 402 punti con iOS e a 360; scritte allineate, scarto 0,0 punti

## VOCE EQ.06, IL RIEPILOGO SOTTO LE CARTE E LA CARD DA CONDIVIDERE

- **Nella card da condividere** la colonna delle posizioni era di 74 punti
  fissi e "PRESENTE" andava a capo in "PRESENT" ed "E". Adesso e' larga
  quanto la posizione piu' lunga misurata col carattere vero, piu' otto
  punti, e nessuna va a capo.
- **Nel riepilogo sotto le carte** il segno del verso stava in un `Wrap`
  unico e andava dove c'era posto. Adesso posizione e nome stanno sulla prima
  riga, il segno e la sintesi sulla seconda: il segno comincia la seconda
  riga in tutte e tre.

**APERTA IN ATTESA DI VERIFICA**: sul Realme con la build di prova si vede come atteso (`realme/eq06_build_eq_riepilogo_sotto_le_carte.png`); resta aperta finche' il fondatore non la guarda sull'iPhone, regola 5 dell'ordine. La card da condividere sul Realme si vede solo come miniatura nel foglio di condivisione.
DOMANDA: "Il riepilogo delle estrazioni subito sotto le 3 carte ci sono difetti come la parola "presente" con la "e" finale a capo."; "Ti segnalo che gli screenshot sono di un iPhone 17 pro."
PROVA: test/la_stesa_si_legge_intera_test.dart
MISURA: parole spezzate nella card da condividere da 1 a 0 ("PRESENTE" larga 79,4 nella colonna di 88,0); righe del riepilogo col segno del verso fuori posto da 1 a 0 (bordo sinistro dei segni 24,0 e 24,0, a 402 con iOS e a 360)

## PARTE 3, I DIFETTI DELLE CATTURE

## VOCE EQ.07, I CONTATORI DELLA CHAT

Un fatto e' misurato. Sul Realme di prova, con la stessa build 2284 delle
catture, il contatore delle domande scende: 50, poi 49 dopo una domanda in
chat, poi 48 dopo la seconda restando nella chat (`docs/collaudo/EQ/realme/`).
Le quattro risposte delle catture hanno la forma del LIVE, due frasi brevi, e
i turni del LIVE non consumano domande per la decisione dell'ordine EG voce
06: e' la domanda per il fondatore, nel rapporto.

**La bolla dice di che cosa e' il residuo.** "Chiedi anche agli altri" conta
i confronti fra i Maestri, un tetto diverso dalle domande, e diceva soltanto
*"Oggi te ne restano 20 su 20"*: adesso *"Oggi hai 20 confronti fra i
Maestri"*, con la forma di ogni altro residuo dell'app
(`QuestionAllowance.residuoDiCosa`) e le parole del suo budget, le stesse in
"Chiedi ai Maestri".

**Sul Realme con la build di prova** i contatori usati scendono: le domande
48, 47, 46, 45 una per domanda in chat (`realme/eq07_build_eq_domande_48.png`,
`realme/eq07_build_eq_domande_47.png`), mentre i turni del LIVE non le
toccano; i confronti da 20 a 19 al tocco su "Chiedi anche agli altri"
(`realme/eq07_build_eq_confronti_19_su_20.png`); le stese da 20 a 19 a 18
(`realme/eq07_build_eq_stese_19_su_20.png`). La bolla dice *"Oggi hai 20
confronti fra i Maestri"*.

**Gli approfondimenti non si potevano usare.** Sul Realme, con la prima
build di prova, tre tocchi su "Vai più a fondo" in due risposte diverse non
hanno fatto niente, ne' il seguito ne' l'invito del piano, e il contatore e'
rimasto a 30 (`realme/difetto_build_eq_vai_piu_a_fondo_non_risponde.png`).
**La causa, misurata col modello vero** (`tool/sonda_del_seguito.dart`,
`docs/collaudo/EQ/eq07_il_seguito_arriva.txt`): il seguito si chiedeva con
la domanda di prima come ultimo turno della persona e con la sua istruzione
sepolta sotto le regole della prima risposta; il modello rispondeva di nuovo
alla domanda, il filtro delle ripetizioni buttava tutto e il controller
tornava senza dire niente. Il seguito arrivava **1 volta su 9 tocchi**; 2 su 9 sul codice di prima dell'ordine: PROVENIENZA IGNOTA, il difetto c'era
gia'. **La cura**: il seguito si chiede dopo la risposta gia' data, con la
sua istruzione per ultima e senza le regole della prima risposta; un seguito
tutto ripetuto si chiede di nuovo una volta; la stella taglia solo dalla
stella; un tocco che non trova niente lo dice. Dopo, **9 su 9 e 9 su 9**.
Guardia `il_seguito_arriva_davvero` (sette innesti, tutti rossi); e una
guardia di casa cieca: `il_seguito_scende_sotto` restava verde togliendo
l'istruzione del seguito dall'istruzione del Maestro.

**I turni del LIVE contano come domande**, per la risposta del fondatore:
un turno a voce costa una domanda e il limite del giorno vale anche nel
LIVE (lapide sulla prova dell'ordine EG voce 06,
`il_live_consuma_solo_i_suoi_minuti`).

**CHIUSA.** Sul Realme con la seconda build di prova: una domanda in chat,
domande da 45 a 44 (`realme/eq07_build_eq2_domande_44.png`); "Vai più a
fondo", il seguito nella bolla e approfondimenti da 30 a 29
(`realme/eq07_build_eq2_approfondimenti_29_su_30.png`,
`realme/eq07_build_eq2_il_seguito_nella_bolla.png`); cinque turni del LIVE,
domande da 44 a 39, poi altri due, 37
(`realme/eq07_build_eq2_domande_39_dopo_cinque_turni_del_live.png`,
`realme/eq07_build_eq2_domande_37_dopo_altri_due_turni_del_live.png`); le
stese a 17.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ", dopo l'elenco dell'Architetto che nominava i contatori; "1 I turni Live contano come domande."
PROVA: docs/collaudo/EQ/realme/eq07_build_eq2_domande_39_dopo_cinque_turni_del_live.png
MISURA: contatori che scendono quando si usano, sul Realme da 3 su 5 (prima build di prova: domande in chat, confronti e stese si; approfondimenti e turni del LIVE no) a 5 su 5 (domande in chat 45, 44; turni del LIVE 44, 39, 37; approfondimenti 30, 29; confronti 20, 19; stese 18, 17); seguiti arrivati al tocco, al banco col modello vero, da 1 su 9 a 9 su 9 e 9 su 9; righe dei residui che non dicono di che cosa, da 1 a 0

## VOCE EQ.08, I MESSAGGI SOTTO LA CASELLA E SOTTO IL MENU'

La conversazione si ritaglia sopra il bordo alto della casella di
scrittura, seguendo la barra del Cerchio quando scende e sale
(`_TaglioSopraLaCasella` nella chat).

Le catture "prima", sul Realme con la build 2284:
`realme/eq08_build_2284_prima_testo_sotto_la_casella_e_la_barra.png` (con la
barra aperta, *"necessità della struttura. Non agire d'impulso"* si legge
sotto la casella e dietro "ESPLORA") e
`realme/eq08_build_2284_prima_la_bolla_finisce_dietro_la_barra.png` (la fine
della bolla, "Vai più a fondo" e "Chiedi anche agli altri", resta dietro la
casella e non risale).

**CHIUSA.** Sul Realme con la build di prova, chat piena: la conversazione si
ferma sopra il bordo alto della casella anche quando la casella cresce a
cinque righe (`realme/eq08_build_eq_casella_alta_conversazione_sopra.png`), a
riposo e scorrendo; la fine della bolla, "Vai più a fondo" e "Chiedi anche
agli altri", risale sopra la casella
(`realme/eq01_eq07_build_eq_presentazione_senza_riga_d_oro_e_residuo_dei_confronti.png`).
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ", dopo l'elenco dell'Architetto che nominava il testo sotto la casella.
PROVA: docs/collaudo/EQ/realme/eq08_build_eq_casella_alta_conversazione_sopra.png
MISURA: punti di conversazione visibili sotto il bordo alto della casella, a 360 e 402 punti, da 74 a 0 (test/i_messaggi_stanno_fra_i_contatori_e_la_casella_test.dart); sul Realme testo della conversazione sotto la casella da presente (build 2284) ad assente

## VOCE EQ.09, IL FONDO DEI CONTATORI

Sul Realme con la 2284 il ritratto di Caligo in cima alla conversazione
passava dietro le due righe dei contatori mentre si scorreva
(`realme/eq09_build_2284_prima_il_ritratto_dietro_i_contatori.png`): il
ritaglio della voce EQ.08 fermava il fondo della conversazione e lasciava
libera la cima. **Due cure**: la conversazione si ritaglia anche al suo bordo
alto, e la fascia dei contatori ha la tinta della testata, da un punto solo
(`_ChatAppBar.fondo`), con quattro punti sotto le righe.

**CHIUSA.** Sul Realme con la build di prova, scorrendo, la conversazione
sparisce sotto il bordo della fascia dei contatori, che ha la tinta della
testata: dietro le due righe non passa niente
(`realme/eq09_build_eq_scorrendo_niente_dietro_i_contatori.png`).
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ", dopo l'elenco dell'Architetto che nominava i messaggi dietro i contatori.
PROVA: docs/collaudo/EQ/realme/eq09_build_eq_scorrendo_niente_dietro_i_contatori.png
MISURA: punti in cui la conversazione puo' dipingere dietro i contatori, a 360 e 402 punti, da 674 a 0; fascia dei contatori con la tinta della testata, da 0 a 1 (docs/collaudo/EQ/eq09_la_fascia_e_la_cima.txt); sul Realme testo dietro i contatori scorrendo da presente (build 2284) ad assente

## VOCE EQ.10, LA PILLOLA BIANCA DELLA DETTATURA

**Ritirata dal fondatore**, alla domanda del rapporto: *"la pillola bianca
è un'invenzione dell'architetto, lascia perdere"*. Quello che segue e'
l'indagine com'era.

L'indagine e' fatta e non ha ancora trovato chi la disegna
(`docs/collaudo/EQ/eq10_indagine.txt`). Sul Realme con la 2284: in ascolto
nessuna pillola, anche in sette secondi di silenzio fotografati ogni 0,4
secondi (0 pixel bianchi su 128.000 nella sua zona, in dodici fotogrammi, e
nessuna finestra di sistema oltre alle barre); la lente del testo e la barra
di selezione di Flutter hanno un'altra forma e sono scure. Nella cattura del
fondatore la freccia d'invio e' spenta, quindi il campo era vuoto: la
pillola non viene dal testo dettato. **Poi con la voce vera**, detta dalle casse del PC al Realme con la build di
prova (`realme/eq10_dettatura_con_la_voce/`): due dettature, 54 fotogrammi,
**0 pixel bianchi** nella zona sopra la casella in tutti; nessuna finestra
oltre all'app, alla tastiera e alle barre di sistema. La pillola non si
riproduce su questo telefono. **Trovato invece un altro difetto**: la frase
detta durava 8,7 secondi e la dettatura ha scritto soltanto *"vorrei"*, poi
ha smesso di ascoltare. PROVENIENZA IGNOTA: la dettatura non e' stata
toccata da quest'ordine (ultimo ritocco, ordine EG). Niente e' stato
cambiato alla cieca: serve sapere dal fondatore su quale telefono e con
quale tastiera compare la pillola.

**La dettatura che si ferma alla prima parola, curata.** Padre, trovato
dopo: ordine CI voce 05, commit `6c21083c`. Il `pauseFor` di tre secondi del
plugin non misura il silenzio ma il tempo dall'ultimo risultato cambiato; la dettatura prendeva la prima chiusura del riconoscitore di Android, che
ascolta un enunciato alla volta, come la fine. Adesso `IlDettatoCheContinua`
(`lib/core/voce/il_dettato_che_continua.dart`) apre un enunciato nuovo
finche' la persona parla, tiene le parole gia' dette, chiude su un
enunciato senza parole, sullo stop o dopo un minuto. Guardia
`il_dettato_non_si_ferma_alla_prima_parola` (quattro innesti, tutti rossi).

**CHIUSA.** Sul Realme con la seconda build di prova, la stessa prova di
prima, voce detta dalle casse del PC con una pausa di due secondi in mezzo:
tre enunciati di seguito, poi la chiusura sul silenzio; nel campo la frase
intera, *"vorrei ritrovare la calma alla sera perché quando torno dal lavoro
sento il petto chiuso io non riesco ad addormentarmi prima dell'una di
notte"* (`realme/eq10_build_eq2_dettatura_frase_intera.png`,
`realme/eq10_build_eq2_dettatura_testo_del_campo.txt`).
DOMANDA: "3 la pillola bianca è un'invenzione dell'architetto, lascia perdere"; il difetto della dettatura l'ha trovato l'indagine di questa voce, sul Realme
PROVA: docs/collaudo/EQ/realme/eq10_build_eq2_dettatura_frase_intera.png
MISURA: parole dette arrivate nel campo della dettatura, sul Realme, da 1 parola ("vorrei") su una frase di 8,7 secondi, prima build di prova, a 24 parole su 24 (due capite male: "alla" per "la", "io" per "e"); pillole bianche da cercare da 1 a 0, per decisione del fondatore

## VOCE EQ.11, IL TITOLO DELLA STESA SU UNA RIGA

"Stesa di Tarocchi" usa il titolo che non si rompe con una riga sola: la
misura scende quanto serve, entro il minimo del titolo.

**APERTA IN ATTESA DI VERIFICA**: sul Realme con la build di prova si vede come atteso (`realme/eq11_build_eq_titolo_su_una_riga.png`); resta aperta finche' il fondatore non la guarda sull'iPhone, regola 5 dell'ordine.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ"; "Ti segnalo che gli screenshot sono di un iPhone 17 pro."
PROVA: test/la_stesa_si_legge_intera_test.dart
MISURA: righe del titolo da 2 a 1, a 402 punti con iOS e a 360

## VOCE EQ.12, "IL CONSIGLIO DI MEDORA" INTERO

Era un `Text` con `maxLines: 1` e il ritorno a capo acceso: "IL CONSIGLIO
DI" sulla prima riga, "MEDORA" sulla seconda buttata via. Adesso usa il
titolo che non si rompe, a una riga e allineato a sinistra. **La guardia che
lo sorvegliava era cieca**: misurava a 328 punti, piu' del riquadro vero, e
restava verde; riscritta sul paragrafo dipinto.

**APERTA IN ATTESA DI VERIFICA**: sul Realme con la build di prova si vede come atteso (`realme/eq04_eq05_eq12_build_eq_carta_chiave_scritta_staccata_e_consiglio_intero.png`); resta aperta finche' il fondatore non la guarda sull'iPhone, regola 5 dell'ordine.
DOMANDA: "Unisci tutto all'ordine prossimo credo EQ"; "Ti segnalo che gli screenshot sono di un iPhone 17 pro."
PROVA: test/la_stesa_si_legge_intera_test.dart
MISURA: titoli tagliati da 1 a 0 ("IL CONSIGLIO DI MEDORA" su una riga, non tagliato, a 402 punti con iOS e a 360)
