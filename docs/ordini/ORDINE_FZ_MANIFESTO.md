# MANIFESTO DELL'ORDINE FZ, L'ANIMALE DI POTERE CHE SI RIVELA NEL VIAGGIO

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_FZ_TESTO.md` (porta
anche l'aggiunta FZA, eseguita dentro l'ordine e consegnata con la sua
consegna, voce FZ.10). Rapporto: `docs/ordini/RAPPORTO_ORDINE_FZ.md`. Una
voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA; una voce aperta dice
che cosa aspetta e porta le sue prove.

VOCI_TOTALI: 15
VOCI_CHIUSE: 12
VOCI_APERTE: 3
VOCI_DA_FARE: 0

## VOCE FZ.01

**CHIUSA.** L'animale si trova, non si calcola. Esce la derivazione dal
segno solare: l'animale si riconosce quando la stessa ombra e' stata seguita
quattro volte, non per forza di fila, con le ombre gia' seguite che tornano
sempre fra le proposte della discesa successiva. Porta unica nuova
`AnimaleDiPotere`, logica pura in `LeOmbreCheRitornano`
(`lib/core/viaggio/le_ombre_che_ritornano.dart`). **Il numero delle ombre
proposte a ogni discesa, tre nella prima stesura, sale a nove con FZA.01**
(voce sotto): la regola del riconoscimento alla quarta volta e del ritorno
delle ombre gia' seguite resta la stessa, verificata di nuovo con nove. Nel
file di prova, il gruppo "FZ.01: il riconoscimento arriva alla quarta, mai
prima".

DOMANDA: "La 2." (l'animale che si rivela nel viaggio, con la regola delle
quattro apparizioni di Harner); "3 si" alla domanda dell'Architetto
"L'animale viene riconosciuto quando la persona ha seguito la stessa ombra
quattro volte, come dice Harner?"
PROVA: `test/le_ombre_che_ritornano_test.dart`
MISURA: su 100 persone con scelte diverse (12 sempre la stessa ombra, 88
con due ombre alternate), il riconoscimento non arriva mai prima della
quarta volta della stessa ombra e arriva sempre esattamente a quella
quarta volta; su un giro completo dei dodici animali ripetuto quattro
volte, nessun riconoscimento prima del trentasettesimo passo

## VOCE FZ.02

**CHIUSA.** Una sola porta, fissa dal riconoscimento. L'animale riconosciuto
diventa fisso e unico in tutta l'app; prima del riconoscimento ovunque si
mostrerebbe l'animale compare la sua sagoma in ombra con "Non ancora
rivelato". `GuideAnimalDerivation.forSign` non decide piu' l'animale di
nessuno: resta viva solo per la migrazione una tantum
(`DiarioDeiViaggi.completaMigrazioneFZ02`). Esce anche la regola delle
quattro impronte sul segno (`le_quattro_impronte.dart`): le impronte restano
il disegno del cammino, la regola e' quella di FZ.01. La migrazione una
tantum ha la sua prova diretta in `test/la_migrazione_delle_ombre_test.dart`.

DOMANDA: "1 si. 2 si. 3 si. 4 si." alle domande dell'Architetto: "1.
L'animale, una volta riconosciuto alla quarta discesa, resta fisso per
sempre e vale in tutta l'app? 2. Prima che sia riconosciuto, nel
Passaporto, nel Bosco e nella card social si vede un'ombra con scritto
'non ancora rivelato'? 4. Chi ha gia' concluso il viaggio, te compreso,
tiene il suo animale? E chi e' a meta' riparte."
PROVA: `test/l_animale_guida_ha_una_porta_sola_test.dart`
MISURA: i punti del codice che derivavano l'animale dal segno solare, da 11 (commit `8dfe2b55`) a 0; la guardia della porta unica
scansiona oltre 500 file di `lib/`, zero colpevoli; alla migrazione,
chi aveva gia' concluso (vecchia chiave a vero) tiene l'animale del suo
segno senza avviso, chi era a meta' riparte da zero con un avviso di una
riga, chi apre l'app per la prima volta non riceve nessun avviso

## VOCE FZ.03

**CHIUSA.** Le impronte e il cammino raccontano le scelte. Il cammino di
impronte mostra le ombre seguite davvero, una impronta per discesa, con la
sagoma di quell'ombra; alla quarta impronta dello stesso animale il cammino
arriva all'animale.

DOMANDA: "La 2." (FZ.01), e le impronte dell'ordine DE voce 09
PROVA: `test/la_soglia_e_una_scena_piena_test.dart`
MISURA: con due discese su quattro fatte, le impronte lasciate sono 2 su 4
(`viaggio_impronta_0`, `viaggio_impronta_1`) e le restanti 2 l'anello vuoto
(`viaggio_impronta_vuota_2`, `viaggio_impronta_vuota_3`)

## VOCE FZ.04

**CHIUSA.** La carta intera da grattare. `IlVeloDellAnimale` (sagoma, testa
protetta fino alla quarta) e' sostituito da `LaCartaInQuattroPezzi`: quattro
fasce uguali su una carta intera, nessuna protetta, ogni pezzo si gratta
col dito, anche il volto. Riusa senza modifiche il pittore della cenere, la
grana e le braci.

DOMANDA: "vorrei migliorare il 'gratta e scopri' con una card tutta da
scoprire a pezzi, ma non l'animale da scoprire, ma una card intera, una
schermata quasi intera. La card dell'animale da grattare"; "Stile A"
PROVA: `test/il_gesto_che_scosta_test.dart`
MISURA: ogni pezzo grattato manualmente, controllati oltre 12*5 casi (ogni
animale del catalogo, piu' discese ciascuno), nessun pezzo cade da solo;
il pittore della cenere resta continuo su oltre 12*3*500 celle controllate,
con oltre 12*3*25 punti del tracciato dentro la forma vera di ogni pezzo

## VOCE FZ.05

**CHIUSA.** Il video dell'animale al posto degli zoom. `LaSequenzaDelCammino`
(pura) decide quali pezzi far girare per ognuno dei tre gesti del segno e
per la rivelazione; `IlCamminoDellAnimale` fa girare i pezzi uno dopo
l'altro con dissolvenza di 0,3s alla giuntura e 0,5s sulla scena vuota alla
fine; niente video con Riduci Movimento, la posa resta lo strato di fondo
sempre. `IlCamminoDellAnimale` ha la sua prova diretta in
`test/il_cammino_dell_animale_test.dart`.

DOMANDA: "per risparmiare anche sul peso, direi un solo video: un terzo con
l'animale che si avvicina, un terzo che si ferma e si mette in posa e un
terzo che si gira e torna indietro"; "nel secondo terzo... fa il suo verso
(ululato per il lupo) e poi si allontana"
PROVA: `test/la_sequenza_del_cammino_test.dart`
MISURA: i 3 pezzi del video (arrivo, centro, uscita) si incatenano per
ciascuno dei 3 gesti dal fotogramma esatto del file dei tagli di ognuno
dei 12 animali; con Riduci Movimento acceso i video in esecuzione
scendono da 1 a 0, resta la sola posa ferma

## VOCE FZ.06

**CHIUSA.** Il peso dei video. I 12 video, ricompressi da
`tool/gli_asset_dell_ordine_fz.py`, scendono da 13-14 MB a 3,6-4,3 MB
ciascuno con scarto visivo di 3,3-3,7 su 255, misurato su catture
affiancate. `IVideoDelCamminoScaricati` scarica i tre pezzi e la posa
insieme dal manifesto, verifica ogni file con la sua impronta SHA-256,
riscarica un file sbagliato una volta. Senza rete: la carta resta ferma
sulla posa.

DOMANDA: "teme che il peso dei video sia eccessivo e vuole che vengano
ottimizzati"; "per risparmiare anche sul peso, direi un solo video"
PROVA: `test/i_video_del_cammino_si_scaricano_test.dart`
MISURA: peso dei 12 video, da 13-14 MB a 3,6-4,3 MB ciascuno (tutti sotto
la soglia dei 4-5 MB puntata); scarto visivo 3,3-3,7/255; un file con
impronta sbagliata viene riscaricato una volta prima di arrendersi

## VOCE FZ.07

**CHIUSA.** Fonti e metodo detti giusti. Il pannello "Fonti e metodo" del
Viaggio cita Michael Harner (The Way of the Shaman, 1980) e le quattro
apparizioni; dice che le ombre fra cui scegliere sono la messa in scena di
questa app, non la tradizione di Harner (una visione libera); non nomina
piu' il legame fra segno solare e animale ne lo stile in metallo.

DOMANDA: "Non c'e' bisogno di dichiarare lo stile metallico"; regola del
progetto, ogni funzione esoterica su tradizioni reali con disclaimer
PROVA: `test/le_fonti_del_viaggio_dicono_il_vero_test.dart`
MISURA: il foglio cita Harner e le quattro apparizioni (1 su 1); righe sul
legame segno solare/animale nel foglio, da assenti restano assenti (la
riga non c'era, non andava tolta); parole proibite (stile, metallico,
bronzo, ecc.) cercate nel testo del foglio, 0 trovate

## VOCE FZ.08

**CHIUSA.** La rivelazione si condivide come video. La card della
rivelazione si condivide anche come video verticale: il centro del video
dell'animale (il verso), col titolo del giorno e la data sovrascritti via
FFmpeg (`ffmpeg_kit_flutter_new_min_gpl`, nota di licenza GPL/x264 per il
fondatore prima di uno store). Nella schermata, un secondo pulsante
"Condividi come video" accanto a "Di' chi sei", visibile solo se il pezzo
centro e' gia' scaricato. **La meta' rimasta aperta dal primo commit**, la
risalita che rivela, e' stata chiusa subito dopo: `_laRisalita` monta
`IlCamminoDellAnimale` con `LaSequenzaDelCammino.rivelazione` al posto
dell'illustrazione ferma, solo sulla discesa che rivela, provata in
`test/il_cammino_a_strati_test.dart`. Il filtro del titolo ha la sua prova
diretta in `test/il_filtro_del_titolo_in_video_test.dart`.

DOMANDA: risposte dell'Architetto alle domande delle funzionalita', punto
9, approvate dal fondatore il 17 ottobre 2026 alle 20:16 ("Procedi con
l'ordine")
PROVA: `test/condividi_la_rivelazione_in_video_test.dart`
MISURA: 5 controlli su 5 sul comando FFmpeg generato (contiene il pezzo
centro, "MI HA TROVATO", il nome dell'animale, la data e la codifica video
corretta, libx264 con audio copiato); alla risalita che rivela, il
widget del cammino video sostituisce l'illustrazione ferma, da assente a
presente (vista rossa prima, verde dopo); le 106 prove della zona del
Viaggio restano tutte verdi a quel commit

## VOCE FZ.09

**APERTA IN ATTESA DI VERIFICA.** La simulazione da persona, obbligatoria e
permanente. La regola e' scritta in CLAUDE.md (Regole non negoziabili).
Completate sul Realme 767f596c: persona (a) chi segue sempre la stessa
ombra; persona (b) chi cambia ombra ogni volta; persona (f) chi apre il
Viaggio senza rete. Parziali: persona (e), un solo gesto su tre provato
("Chiedigli un segno" con rete disattivata, via di riserva confermata);
persona (g), solo il preambolo (nessun pezzo video scaricato mostra solo
"Di' chi sei", mai "Condividi come video"). **Non completate**: persona (c),
fermata a meta' dall'arrivo dell'ordine FZA (punto 1 confermato, nessun
avviso bloccante al riavvio con la chiave legacy scritta a mano; punti 2 e
3, lo stesso animale nel Passaporto/Ritratto/Bosco e la possibilita' di
continuare a scendere, non piu' verificabili: vedi l'incidente sotto);
persona (d), chi era a meta' e riparte, non avviata sul device (coperta
pero' da `la_migrazione_delle_ombre_test.dart`, automatica e rigorosa, che
replica esattamente questo scenario). **Durante il lavoro e' stato trovato,
isolato e corretto un difetto critico preesistente**, non causato da
quest'ordine (PROVENIENZA IGNOTA: nessuna voce di FZ tocca i file
coinvolti): un consumo di CPU anomalo (80-126%) dovuto a due
`VideoPlayerController` mai smaltiti (`SequenzaIntro`, il lettore comune
delle scene) bloccava i tocchi sulle schermate con sfondo animato;
risolto, confermato a video con un giro di navigazione reale e completo
senza un solo blocco. **Incidente operativo durante la pulizia del
device**: nel tentativo di ripristinare il backup delle preferenze della
persona (c) (`/sdcard/prefs_persona_c.xml`), un comando di copia mal
costruito ha cancellato quel backup e poi troncato a zero byte il file
`FlutterSharedPreferences.xml` live dell'account di prova "ProvaFZ":
errore di Code, non un difetto del codice dell'app. L'app ha reagito nel
modo corretto (mostra l'onboarding "Il Risveglio" con "Faccio gia' parte
del Cerchio", la custodia sull'account dell'ordine EE resta viva su
Firestore), ma il rientro richiede le credenziali dell'account di prova,
che Code non ha: il device e' stato lasciato sulla schermata di apertura,
pulito e stabile, senza altri tentativi.

ASPETTA: Mauro, le credenziali dell'account di prova "ProvaFZ" (o un nuovo
account di prova) per completare sul device le persone (c) punti 2-3, (d),
il resto di (e) e (g); oppure l'autorizzazione a considerare sufficiente la
prova automatica equivalente gia' verde per (d).
DOMANDA: "Voglio che prima della consegna... Code deve fare sempre
obbligatoriamente e per ogni funzionalita', una simulazione realistica
dell'ordine... si metta nei panni di un utente e simuli i suoi
comportamenti e scelte e preveda decisioni, cosi' da rilevare eventuali
Bug"
PROVA: `docs/collaudo/FZ/simulazioni/previsioni.md`,
`docs/collaudo/FZ/simulazioni/note_di_percorso.md`,
`docs/collaudo/FZ/simulazioni/catture/`
MISURA: persone simulate con esito completo, da 0 a 3 su 7 (a, b, f);
parziali con esito utile, 2 su 7 (e, g); non avviate o interrotte, 2 su 7
(c, d); difetto critico di CPU, da presente (bloccava i tocchi su ogni
schermata con sfondo animato) a assente (`sendPlatformMessage` nel
campione CPU, da 1076 a 93 campioni; `uiautomator dump` da sempre fallito
a riuscito al primo colpo)

## VOCE FZ.10

**APERTA IN ATTESA DI VERIFICA.** La consegna. Dipende da FZ.09 e FZA.04,
entrambe ancora aperte: il testo dell'ordine lo dice esplicitamente
("L'ordine si consegna solo col verde di GitHub e con le simulazioni di
FZ.09 fatte e guardate"). Fatto: manifesto, guardia del manifesto
(`test/ordine_fz_guard_test.dart`), rapporto, STATO_VIVO e registro delle
guardie aggiornati; codice e test pushati sul ramo canonico. Da verificare:
il verde di GitHub sul commit consegnato (in corso), e le simulazioni
rimaste aperte sopra.

ASPETTA: il verde di GitHub sul commit consegnato; Mauro, per le
simulazioni rimaste di FZ.09 e FZA.04 (vedi le rispettive voci).
DOMANDA: regole fisse R3, R6, R11; FZ.09
PROVA: `docs/ordini/RAPPORTO_ORDINE_FZ.md`
MISURA: voci dell'ordine con DOMANDA, PROVA e MISURA, 15 su 15; voci chiuse
12, aperte in attesa di verifica 3

## VOCE FZA.01

**CHIUSA.** Nove ombre, se ne segue una. A ogni discesa compaiono nove
ombre al posto di tre (`LeOmbreCheRitornano.ombreProposte`,
`quanteOmbreSiPropongono = 9`, quante il catalogo ne ha se sono meno di
nove). Restano le regole di FZ.01. `viaggio_dello_sciamano_screen.dart`,
`_lIncontro`: da una `Column` di tre sagome a una griglia tre per tre,
tutte visibili senza scorrere a ogni larghezza fra 320 e 430 punti, ogni
bersaglio ben oltre i 44 punti minimi. Il numero delle proposte ha la sua
prova diretta nel gruppo "FZA.01" di `test/le_ombre_che_ritornano_test.dart`.

DOMANDA: "ma si che base vengono scelte? Non mi piace il fatto che siano
cmq riconoscibili e, quindi, pensavo di farli diventare 9 e l'utente puo'
sceglierne solo 1"; "Preferisco 9 ombre, anche se riconoscibili, perche'
con lince, volpe e lupo cmq sarebbero simili e mettono piu' curiosita'"
PROVA: `test/le_nove_ombre_stanno_tutte_a_schermo_test.dart`
MISURA: sagome a schermo, da 3 a 9, sempre `findsNWidgets(9)` a 320, 375 e
430 punti, senza scorrere; bersaglio di ogni sagoma, da non misurato a
sempre oltre i 44 punti minimi (larghezza e altezza); le nove proposte sono
sempre nove nomi diversi, anche senza nessuna discesa fatta o con il
catalogo ridotto a sette animali (allora le proposte sono sette)

## VOCE FZA.02

**CHIUSA.** Le ombre nuove a caso per ogni persona. Le ombre mai viste che
completano il gruppo, e il posto di tutte e nove nella griglia, nascono da
un seme FNV-1a su identita' del dispositivo (`DeviceId.corrente()`, gia'
usato per i Doni deterministici) piu' numero della discesa. Stessa persona,
stessa discesa: stesso gruppo, negli stessi posti. Persone diverse: gruppi
diversi. Prova diretta nel gruppo "FZA.02" di
`test/le_ombre_che_ritornano_test.dart`.

DOMANDA: il rilievo dell'Architetto, 19 ottobre 2026, leggendo che le
ombre nuove completavano il gruppo "nell'ordine del catalogo" (quindi alla
prima discesa tutti vedevano le stesse ombre), approvato dal fondatore
("Vai")
PROVA: `test/le_ombre_che_ritornano_test.dart`
MISURA: su 100 persone diverse alla prima discesa, gruppi diversi visti da
1 (il difetto segnalato: tutti uguali) a 100 su 100; la stessa persona che
rientra nella stessa discesa, stesso gruppo negli stessi posti (identico);
la stessa persona a discese diverse, gruppo diverso (il seme include il
numero della discesa); due persone con la stessa unica ombra gia' seguita,
gruppi comunque diversi (padre del difetto: FZ.01, che non specificava
l'ordine delle ombre nuove)

## VOCE FZA.03

**CHIUSA.** Nessun numero di animali in vista. Due testi visibili corretti:
`sentiero_albero.dart` ("I dodici Animali Guida" -> "Gli Animali Guida del
catalogo"), `bosco_del_cerchio.dart` ("Dodici animali accompagnano..." ->
"Gli animali accompagnano..."); le fonti del Viaggio e il pannello
dell'Animale Guida, "le tre ombre" -> "le ombre". `GirandolaDegliAnimali`
resa iniettabile (`animali`, di serie `AnimalCatalog.animals`) per poterla
misurare con un catalogo esteso.

DOMANDA: "un domani, ne potrei aggiungere altri, visto che da nessuna
parte viene indicato il numero degli animali"
PROVA: `test/nessun_numero_di_animali_in_vista_test.dart`
MISURA: scansione di oltre 500 file di `lib/` nel perimetro del Viaggio
per "dodici animal..." o "12 animal..." in stringhe visibili (i commenti
non contano), da testi trovati (il sentiero e il bosco) a 0; con un
tredicesimo animale finto aggiunto al catalogo in prova,
`LeOmbreCheRitornano.ombreProposte` propone 13 ombre (non piu' bloccato a
12) e `GirandolaDegliAnimali` disegna 26 immagini (13 animali, dorso piu'
illustrazione ciascuno, da `findsNWidgets(26)`)

## VOCE FZA.04

**APERTA IN ATTESA DI VERIFICA.** La simulazione delle nove ombre. Persona
(h), chi guarda tutte le nove ombre alla prima discesa, esce e rientra:
**completata**, griglia tre per tre confermata, uscita vera (`am
force-stop`) e rientro hanno ritrovato le nove ombre identiche, nella
stessa identica disposizione, confrontate pixel per pixel. Persona (i), chi
segue un'ombra e il giorno dopo ne segue un'altra fino a riconoscere un
animale diverso: **parziale**, due discese su (almeno) quattro necessarie
alla quarta ombra diversa; confermato che le due griglie sono diverse fra
loro, che l'ombra gia' seguita torna fra le nove, e che gli strati
narrativi del Diario contano le discese totali. Persona (l), chi sceglie
sempre ombre diverse per sei discese: **interrotta**, un episodio di tocco
non risposto sul pulsante "Scendi" (`uiautomator dump` falliva con "could
not get idle state"), verificato con la controprova (un altro elemento
sulla stessa schermata ha risposto subito) e non confermato come difetto
vero: PROVENIENZA IGNOTA, non investigato oltre per restare nel tempo
della consegna. Nessuna delle tre persone ha potuto proseguire oltre
l'incidente operativo descritto in FZ.09 (perdita delle preferenze locali
dell'account di prova).

ASPETTA: Mauro, le credenziali dell'account di prova (vedi FZ.09) per
completare (i) fino al riconoscimento e ripetere (l) oltre l'episodio
inconcluso.
DOMANDA: "Sul Realme, con la stessa regola di FZ.09, almeno queste persone
in piu': h) chi alla prima discesa guarda tutte le nove ombre, esce,
rientra e ritrova le stesse; i) chi segue un'ombra... fino a riconoscere un
animale diverso dal primo; l) chi sceglie sempre ombre diverse per sei
giorni di fila"
PROVA: `docs/collaudo/FZ/simulazioni/note_di_percorso.md` (sezioni "ORDINE
FZA"), `docs/collaudo/FZ/simulazioni/catture/fza*_19ott.png`
MISURA: persone completate, 1 su 3 (h); parziali con comportamento chiave
confermato, 1 su 3 (i, 2 discese su almeno 4); interrotte da un episodio
non confermato, 1 su 3 (l)

## VOCE FZA.05

**CHIUSA.** Il riquadro dell'animale segue la forma vera della carta, non
taglia le gambe. Richiesta arrivata in chat durante l'esecuzione di
quest'ordine, con screenshot: il Cavallo appariva tagliato alle zampe nella
risalita. Causa: `AspectRatio` del riquadro a 1,35 (orizzontale), mentre le
dodici carte (`assets/img/mondo_di_sotto/carte/*_carta_da_grattare_v1.
webp`) sono tutte 1080x1920 (verticali); con `BoxFit.cover` il riquadro
largo mostrava solo una fetta centrale stretta dell'immagine. Corretto a
1080/1920, il rapporto vero della carta: ora l'animale si vede per intero
o quasi, a ogni larghezza.

DOMANDA: "Vorrei che l'animale non fosse tagliato alle gambe, anche perche'
con gli altri animali piu' piccoli, ne verrebbe tagliato molto del corpo.
Assicurati che tutti gli animali si vedano interamente o quasi, puoi
tagliare sia in alto che in basso, trova la soluzione migliore"
PROVA: `test/il_riquadro_dell_animale_segue_la_carta_test.dart`
MISURA: rapporto larghezza/altezza del riquadro della risalita, da 1,35 a
0,5625 (1080/1920, misurato `closeTo` con tolleranza 0,01), lo stesso
rapporto nativo delle dodici carte
