# RAPPORTO DELL'ORDINE FZ, L'ANIMALE DI POTERE CHE SI RIVELA NEL VIAGGIO

17-19 ottobre 2026. Testo dell'ordine, con l'aggiunta FZA eseguita dentro di
lui: `docs/ordini/ORDINE_FZ_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FZ_
MANIFESTO.md`, 15 voci: 12 chiuse, 3 aperte in attesa di verifica, 0 da
fare. Ramo `claude/esoteric-circle-master-order-e798aj`.

**Nota sulla registrazione**: due registrazioni di questo rapporto (impronte
`6c340c4d...` e `491e9540...`) sono state tolte dal registro e rifatte prima
che il cancello di GitHub desse il primo verde, quindi prima di una vera
consegna vista da Mauro. La prima volta per la rinumerazione FZA.01-FZA.05 in
FZ.10-FZ.14 (vedi sotto, "il secondo rosso del cancello"); la seconda per
aggiungere la sezione che documenta il debito preesistente trovato e curato
dallo stesso giro del cancello. Nessuna correzione nel corpo dopo questa.

## LE PREMESSE CADUTE

- **Il rischio previsto per la persona (b)** (`docs/collaudo/FZ/simulazioni/
  previsioni.md`): che il secondo strato narrativo del Diario potesse
  ripetersi in modo sbagliato quando la persona segue un animale nuovo mai
  seguito prima. Verificato nel codice e a video: non e' un difetto. Gli
  strati narrativi sono globali per la domanda, non per animale
  (`le_parole_del_cammino.dart`, ordine DQ); il conteggio per animale (il
  "pezzo" della carta) e' un sistema diverso e separato, che conta per nome
  dell'ombra che guida, non dello strato narrativo.
- **La correzione "tre ombre verticali e grandi"**, fatta a video durante la
  simulazione di FZ.09 e confermata con tre catture (`verify19_19ott.png`,
  `verify33_19ott.png`, `verify37_19ott.png`, commit `30436c21`), e'
  superata poche ore dopo dall'arrivo dell'ordine FZA: la `Column` di tre
  sagome che misurava non esiste piu', sostituita dalla griglia tre per tre
  di FZ.10 (FZA.01 nel testo originale dell'aggiunta). La sua guardia
  (`test/le_tre_ombre_sono_verticali_e_grandi_test.dart`) e' stata tolta dal
  ramo: misurava un soggetto che non c'e' piu', e una guardia su un
  soggetto sparito e' una guardia che non sorveglia niente, non uno
  storico da tenere.
- **Il sospetto sul pulsante "Scendi" nella persona (l)** (FZ.13, FZA.04
  nel testo originale dell'aggiunta): dieci
  tocchi senza risposta, `uiautomator dump` in errore, VM Service
  irraggiungibile. La controprova (un altro elemento sulla stessa
  schermata ha risposto subito) ha escluso che fosse lo stesso difetto
  generale di CPU gia' trovato e corretto in questo stesso ordine: resta
  PROVENIENZA IGNOTA, non confermato, non investigato oltre.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FZ.01, l'animale si trova, non si calcola | `test/le_ombre_che_ritornano_test.dart` |
| FZ.02, una sola porta, fissa dal riconoscimento | `test/l_animale_guida_ha_una_porta_sola_test.dart` |
| FZ.03, le impronte raccontano le scelte | `test/la_soglia_e_una_scena_piena_test.dart` |
| FZ.04, la carta intera da grattare | `test/il_gesto_che_scosta_test.dart` |
| FZ.05, il video al posto degli zoom | `test/la_sequenza_del_cammino_test.dart` |
| FZ.06, il peso dei video | `test/i_video_del_cammino_si_scaricano_test.dart` |
| FZ.07, fonti e metodo detti giusti | `test/le_fonti_del_viaggio_dicono_il_vero_test.dart` |
| FZ.08, la rivelazione si condivide come video | `test/condividi_la_rivelazione_in_video_test.dart` |
| FZ.10, nove ombre, se ne segue una | `test/le_nove_ombre_stanno_tutte_a_schermo_test.dart` |
| FZ.11, le ombre nuove a caso per ogni persona | `test/le_ombre_che_ritornano_test.dart` |
| FZ.12, nessun numero di animali in vista | `test/nessun_numero_di_animali_in_vista_test.dart` |
| FZ.14, il riquadro segue la carta, non taglia le gambe | `test/il_riquadro_dell_animale_segue_la_carta_test.dart` |

## LE VOCI APERTE E CHE COSA ASPETTANO

| voce | che cosa e' fatto | che cosa aspetta |
|---|---|---|
| FZ.09, la simulazione da persona | a, b, f complete; e, g parziali; difetto critico di CPU trovato e risolto | Mauro: le credenziali dell'account di prova per c, d e il resto di e, g |
| FZ.13, la simulazione delle nove ombre | h completa; i parziale (2 discese); l interrotta da un episodio non confermato | Mauro: le stesse credenziali, per completare i e ripetere l |
| FZ.15, la consegna | manifesto, guardia, rapporto, STATO_VIVO, registro guardie, push sul ramo canonico | il verde di GitHub sul commit consegnato; le due voci sopra |

## VOCE PER VOCE, COL PADRE DI OGNI DIFETTO

Le voci, coi loro DOMANDA, PROVA e MISURA, sono per intero nel manifesto;
qui il padre di ogni difetto (Regola C) e cio' che il manifesto non dice.

- **FZ.01, FZ.02, FZ.03**: nessun difetto trovato, sostituzione di una
  regola del progetto (la derivazione dal segno solare, ordine DC) con una
  regola nuova voluta dal fondatore. Padre della vecchia regola: ordine DC
  voci 04-09.
- **FZ.04**: padre ordini DI voce 10 e DQ voce 05 (il velo sulla sola
  sagoma, che questa voce sostituisce). Nessun difetto, solo sostituzione.
- **FZ.05, FZ.06**: nessun difetto; nuova funzione, coi 12 video forniti
  dal fondatore misurati fotogramma per fotogramma.
- **FZ.07**: nessun difetto; il pannello non citava ancora il legame
  segno/animale ne' lo stile, mancava solo la riga sulla messa in scena.
- **FZ.08**: nessun difetto nella prima meta' (condivisione); la seconda
  meta' (il video nella risalita che rivela) era stata lasciata
  esplicitamente aperta dal commit `c785e2ad` stesso, chiusa nel commit
  successivo `5ef0d3e3`.
- **FZ.09**: il difetto critico di CPU e' PROVENIENZA IGNOTA (nessuna voce
  di questo ordine tocca `sequenza_intro.dart` o `la_scena_in_video.dart`);
  causa tecnica isolata col VM Service, due `VideoPlayerController` mai
  smaltiti. L'incidente della perdita delle preferenze dell'account di
  prova e' un errore operativo di Code durante la pulizia del device
  (comando di copia mal costruito dopo aver gia' cancellato il backup),
  non un difetto del codice dell'app: l'app ha reagito correttamente
  mostrando l'onboarding e offrendo il rientro con l'account.
- **FZ.10, FZ.11**: padre FZ.01 (il numero fisso a tre e l'ordine del
  catalogo, mai specificato come regola, solo come implementazione) e il
  rilievo dell'Architetto del 19 ottobre 2026, approvato dal fondatore.
- **FZ.12**: padre nessuno specifico; richiesta diretta del fondatore in
  vista di un catalogo futuro piu' grande.
- **FZ.13**: vedi FZ.09 per il difetto di CPU (stesso padre, PROVENIENZA
  IGNOTA) e per l'incidente operativo.
- **FZ.14**: PROVENIENZA IGNOTA. Il riquadro a 1,35 esisteva gia' nella
  prima stesura di FZ.05 (commit `7b69556f`, la_risalita) e non e' stato
  toccato da nessuna voce successiva fino alla segnalazione del fondatore.

## LE SIMULAZIONI, PERSONA PER PERSONA

Diario completo, passo per passo, con ogni tentativo e ogni cattura, in
`docs/collaudo/FZ/simulazioni/note_di_percorso.md`; le previsioni scritte
prima di testare in `docs/collaudo/FZ/simulazioni/previsioni.md`.

- **(a) chi segue sempre la stessa ombra**: completata. Riconoscimento alla
  quarta discesa confermato, nessun difetto.
- **(b) chi cambia ombra ogni volta**: completata. Il rischio previsto sul
  secondo strato narrativo e' caduto (vedi "Le premesse cadute"); nessun
  difetto trovato.
- **(c) chi aveva gia' concluso col vecchio sistema**: avviata con
  l'autorizzazione esplicita del fondatore ("Sei autorizzato a fare
  tutto"), scrivendo a mano la chiave legacy nel file delle preferenze del
  device. Punto 1 confermato (nessun avviso bloccante al riavvio). Punti 2
  e 3 (stesso animale nel Passaporto/Ritratto/Bosco; possibilita' di
  continuare a scendere) non piu' verificabili dopo l'incidente operativo
  sulle preferenze (vedi sotto): restano APERTI.
- **(d) chi era a meta' e riparte**: non avviata sul device. Lo stesso
  identico scenario (vecchia chiave a meta', nessuna conclusione) e'
  pero' coperto in modo rigoroso e ripetibile da
  `test/la_migrazione_delle_ombre_test.dart`, con SharedPreferences finte
  e controllate: chi era a meta' perde l'ombra gia' seguita e riceve
  l'avviso di una riga.
- **(e) chi fa una domanda e riceve sì, guarda meglio, no**: parziale. Un
  solo gesto provato ("Chiedigli un segno", rete disattivata apposta per
  la regola SPESE): risposta immediata dalla via di riserva ("Il Cavallo
  si allontana... non adesso"), confermato che non c'e' piu' attesa
  infinita. Mancano gli altri due gesti e la chiamata vera al modello
  (richiede il si' di Mauro con stima di spesa, R2).
- **(f) chi apre il Viaggio senza rete e con Riduci Movimento**: completata.
  Quarta discesa e rivelazione del Cavallo verificate con WiFi e dati
  disattivati: nessun riquadro vuoto, nessun crash, immagini ferme al
  posto dei video.
- **(g) chi condivide la rivelazione come video**: parziale. Confermato il
  preambolo: senza il pezzo video scaricato compare solo "Di' chi sei",
  mai "Condividi come video"; il foglio di condivisione di sistema si apre
  con l'immagine pronta e annullarlo lascia l'app pulita. Manca il caso
  col video davvero scaricato e condiviso.
- **(h) chi guarda tutte le nove ombre, esce e rientra**: completata.
  Griglia tre per tre confermata alla prima discesa; uscita vera (`am
  force-stop`, non solo il tasto Home) e rientro hanno ritrovato le nove
  ombre identiche, nella stessa identica disposizione, confrontate pixel
  per pixel fra due catture separate da un riavvio completo del processo.
- **(i) chi segue ombre diverse fino a riconoscerne una**: parziale, due
  discese su almeno quattro necessarie. Confermato: le due griglie di
  nove sono diverse fra loro; l'ombra gia' seguita (il Corvo) torna fra
  le nove alla seconda discesa, coerente con FZ.01; gli strati narrativi
  del Diario contano le discese totali, non le apparizioni di un singolo
  animale.
- **(l) chi sceglie sempre ombre diverse per sei discese**: interrotta
  dall'episodio del pulsante "Scendi" (vedi "Le premesse cadute"). Le due
  discese della persona (i), fatte sullo stesso device nello stesso
  periodo, avevano gia' mostrato gruppi sempre diversi con ombre mai viste
  abbondanti, coerente con quanto (l) avrebbe dovuto verificare.

**L'incidente operativo sulle preferenze dell'account di prova**: nel
tentativo di restituire il device allo stato precedente alla simulazione
(c), un comando ha cancellato il backup conservato sulla sdcard
(`prefs_persona_c.xml`) e poi, nello stesso errore, troncato a zero byte il
file `FlutterSharedPreferences.xml` live dell'account "ProvaFZ": errore
di sequenza di Code (il comando di ripristino e' stato scritto dopo aver
gia' cancellato la sua stessa fonte), non un difetto del codice dell'app.
Riavviata l'app per capire la conseguenza: ha mostrato correttamente
l'onboarding "Il Risveglio" con l'opzione "Faccio gia' parte del Cerchio.
Accedi e ritrova il tuo cammino", segno che la custodia sull'account
dell'ordine EE (Firestore) e' viva e il rientro e' possibile. Non avendo
le credenziali dell'account di prova, Code non ha proseguito oltre il
foglio di accesso (toccato "Più tardi"): il device resta sulla schermata
di apertura, pulito e stabile, pronto per un rientro quando Mauro dara' le
credenziali o ne creera' di nuove.

## LE SCELTE DI CODE CON LA RAGIONE

- **Voce FZ.14 per il riquadro che tagliava le gambe**: la richiesta e'
  arrivata in chat durante l'esecuzione dell'ordine, con uno screenshot,
  fuori dal testo scritto di FZ e di FZA. Trattata come una voce a se'
  (non piegata dentro FZ.10, che parla delle ombre della discesa, non del
  riquadro della risalita) perche' tocca un file e un widget diversi, con
  una sua prova gia' scritta e verde. Numerata FZ.14, in coda alle voci
  dell'aggiunta FZA e prima della consegna, con la stessa convenzione gia'
  usata dall'ordine FX per la sua aggiunta FXA: un manifesto, una sigla
  sola, le voci dell'aggiunta continuano la numerazione dell'ordine.
- **Seme deterministico con FNV-1a a 31 bit**: riusato lo stesso pattern
  gia' in uso in `sunset_rune.dart` per la stessa esigenza (un numero
  pseudocasuale ripetibile da una stringa, dentro i limiti di
  `Random(seed)` di Dart), invece di inventarne uno nuovo.
- **FZ.09 e FZ.13 dichiarate APERTA IN ATTESA DI VERIFICA invece che
  CHIUSA**: il testo dell'ordine lega esplicitamente la consegna (FZ.15)
  al completamento delle simulazioni di FZ.09. Con le persone (c), (d) e
  il resto di (e), (g), (i), (l) non completate sul device, dichiarare
  CHIUSA sarebbe stata esattamente la forma di errore che il protocollo
  della chiusura (ordine EH) esiste per impedire: una misura vicina alla
  domanda del fondatore, non la domanda stessa.
- **Nessun secondo tentativo di accesso dopo l'incidente sulle
  preferenze**: senza le credenziali dell'account di prova, insistere
  avrebbe significato indovinare o creare un nuovo account senza che fosse
  necessario; piu' sicuro fermarsi su una schermata nota e stabile e
  chiedere a Mauro.
- **Codice, test e documentazione pushati sul ramo canonico anche senza la
  consegna finale di FZ.15**: il lavoro verificabile (158 prove verdi
  della zona Viaggio/Animale Guida, oltre alle prove della zona piu' ampia)
  e' pronto e non deve restare solo sul filesystem locale in attesa delle
  simulazioni rimaste, che dipendono da un gesto di Mauro.

## IL SECONDO ROSSO DEL CANCELLO, E IL DEBITO PREESISTENTE TROVATO E CURATO

Dopo la correzione delle righe PROVA e MISURA (commit `0a9bfced`), il cancello
di GitHub e' caduto di nuovo sul commit `412716da`, questa volta su dieci
rossi diversi nel job "analyze e sbarramento". **Verificato confrontando col
commit immediatamente precedente a questo ordine (`707fb155`)**: nove di quei
dieci rossi erano gia' presenti PRIMA che quest'ordine toccasse qualunque
cosa, debito di ordini precedenti mai arrivato al cancello finale; uno solo
(il manifesto FZ assente dal sigillo dei manifesti) era causato da questo
ordine. Curati tutti, col padre di ciascuno dove si e' trovato:

- **Il manifesto FZ assente dal sigillo** (`test/i_manifesti_sono_sigillati_
  test.dart`): causato da questo ordine, il manifesto nuovo non era ancora
  nella tavola `vociMisurate`. Aggiunta la riga `'FZ': 15`.
- **Le voci FZA.01-FZA.05 non contate dal lettore dei manifesti**: causato
  da questo ordine. Il lettore condiviso (`test/lettore_dei_manifesti.dart`)
  conta le voci sulla sigla del nome del file (qui "FZ"), e "FZA.01" non
  contiene "FZ." seguito da una cifra: restava fuori dal conto. Rinumerate
  le voci dell'aggiunta da FZA.01-FZA.05 a FZ.10-FZ.14, con "La consegna"
  spostata a FZ.15, la stessa convenzione gia' usata dall'ordine FX con la
  sua aggiunta FXA (vedi `docs/ordini/ORDINE_FX_MANIFESTO.md`, voci
  FX.13-FX.20). Il manifesto, il rapporto e la guardia dell'ordine
  aggiornati di conseguenza.
- **Il corpus dei sentieri non allineato al codice** (`test/i_sentieri_
  nascono_dal_dato_test.dart`, `test/i_quattro_campi_e_il_sigillo_test.dart`):
  causato da questo ordine. FZA.03 aveva tolto "dodici" dal testo di
  `sentiero_albero.dart` scrivendo direttamente nel file generato, senza
  toccare la sua fonte vera: il file e' prodotto da `tool/genera_corpus_f.
  py` a partire da `tool/corpus_traguardi_dati.py`, e quella fonte diceva
  ancora "I dodici Animali Guida, con il tuo fra loro". Corretta la fonte,
  rigenerato `docs/corpus/Traguardi_165_Revisione_F.json` e i tre file Dart
  dei sentieri (byte identici a quelli gia' nel ramo, prova che la scrittura
  a mano aveva gia' indovinato il testo giusto). **Trovato per strada**: lo
  script scriveva il JSON senza `newline='\n'`, e su Windows questo
  traduceva ogni riga in CRLF, gonfiando il diff a 7762 righe per un solo
  campo cambiato; corretto anche quello nello script.
- **`i_video_del_cammino_si_scaricano_test.dart` senza cardinale dichiarato**
  (`test/ordine_cm_guard_test.dart`, `test/ogni_guardia_dichiara_quanto_
  guarda_test.dart`): padre, l'ordine FZ stesso, voce FZ.06 (commit
  `7b69556f`, prima di questa consegna). Una prova usava `.listSync()` per
  verificare che un download fallito non lasciasse file a meta', uno scopo
  legittimo ma che la guardia non sa distinguere da una scansione aperta.
  Riscritta senza scansione: controlla direttamente i due soli percorsi che
  un download di un animale puo' lasciare (la cartella di lavoro e quella
  finale), che e' anche una prova piu' precisa di quella di prima.
- **`ffmpeg_kit_flutter_new_min_gpl` non classificato** (`test/le_chiavi_di_
  ios_ci_sono_tutte_test.dart`): padre, l'ordine FZ stesso, voce FZ.08
  (commit `c785e2ad`). Letta la cartella `ios/` del pacchetto (2.6.7): il
  podspec dipende solo da `Flutter` e vendorizza le sue xcframework
  (ffmpegkit e le librerie libav*), il plugin Objective-C non importa nessun
  framework sensibile di Apple. Classificato `null`, nessuna chiave richiesta.
- **La cattura finta di `condividi_la_rivelazione_in_video_test.dart` senza
  rapporto di pixel dichiarato** (`test/corredo_anteprime_test.dart`): padre,
  l'ordine FZ stesso, voce FZ.08. `writeAsBytesSync([1, 2, 3])` scrive un
  pezzo video finto di tre byte per simulare un download gia' avvenuto, non
  un'anteprima che qualcuno guardera': la guardia lo confondeva perche'
  cerca la sola sottostringa `writeAsBytes`. Aggiunta l'eccezione dichiarata,
  con la ragione.
- **Due violazioni della regola della virgola** (`test/language_rule_
  test.dart`): PROVENIENZA IGNOTA per quella in `guide_animal_corpus.dart`
  (la frase non e' stata toccata dalle voci di questo ordine, solo una frase
  vicina nello stesso campo); padre FZ.05 (commit `7b69556f`) per quella in
  `il_cammino_dell_animale.dart`, un messaggio di `assert`. Tolte le due
  virgole prima di "e".
- **Una frase con l'apostrofo al posto dell'accento** (`test/testo_a_video_
  test.dart`): padre FZ.06 (commit `7b69556f`), `i_video_del_cammino_
  scaricati.dart` riga 215, un `debugPrint`. Corretto "e\\'" in "è".
- **Il censimento della tipografia disallineato** (`test/tipografia_nel_
  dato_test.dart`): PROVENIENZA IGNOTA (un miglioramento di un ordine non
  identificato aveva abbassato il debito vero senza rigenerare il
  censimento). Rigenerato con `dart run tool/censimento_tipografia.dart`:
  77 misure in 33 file, contro le 78 in 34 dichiarate.
- **Due cartelle di `pubspec.yaml` assenti dal manifesto degli asset**
  (`test/stato_asset_test.dart`): padre FZ.04 e FZ.05 (commit `4acde9c2` e
  `7b69556f`), le carte da grattare e le scene vuote del Mondo di Sotto.
  Aggiunte `assets/img/mondo_di_sotto/carte/` e `assets/img/mondo_di_sotto/
  scene_vuote/` a `docs/stato_asset.json`.

Verificato in locale, tutto il gruppo insieme: 93 prove verdi su sedici file
di guardia. `flutter analyze` pulito sui file toccati.

## MIGLIORIE PROPOSTE, SENZA COSTRUIRLE

- **Una vista nel Diario dei Viaggi che elenchi tutte le carte scoperte,
  un animale accanto all'altro**: notata assente durante la persona (i);
  oggi il progresso per animale si legge solo dal codice o dalle prove,
  non da una schermata.
- **Credenziali fisse e note per un account di prova standard**, scritte
  in un posto che sopravviva a un reset del device di collaudo: avrebbe
  permesso a Code di rientrare da solo dopo l'incidente di oggi, invece di
  lasciare il device in attesa di Mauro.
- **Un comando unico e sicuro per il backup delle preferenze del device di
  collaudo** (invece di comandi `adb shell` scritti a mano ogni volta),
  che non permetta la sequenza che ha causato l'incidente di oggi
  (cancellare la fonte prima di averla usata).

**Aggiunta del 20 ottobre 2026, ordine FZ, la seconda simulazione da persona.**
Decisioni del fondatore: "Tutto, come l'ordine"; pubblicare i video; rifare
la FZ.04; lasciare il server com'e'. Profilo anonimo nuovo sul Realme,
giorni simulati spostando la data del telefono di collaudo; note in
`docs/collaudo/FZ/simulazioni/note_di_percorso.md`, catture `v2_*`.
Undici difetti veri trovati e curati, ognuno col suo padre e una guardia
vista rossa (registro delle guardie da 827 a 838):
1. la cenere veniva via tutta alla prima discesa (padre FZ.04,
   `la_cenere_resta_sui_pezzi_di_domani`, commit `b793c4af`);
2. dopo Risali il responso stava sotto la piega (padre FZ.14,
   `il_responso_si_vede_appena_risali`, `1183d3b2`);
3. le discese sparivano dal Diario: il sacchetto del Viaggio superava il
   tetto del server e il telefono adottava la copia vecchia (padre EE.13,
   aggravato da FZ.04, `il_viaggio_pesante_non_torna_indietro`, `1183d3b2`);
4. i video del cammino non erano mai stati pubblicati (padre FZ.06;
   pubblicati col si' del fondatore, `tool/pubblica_i_video_del_cammino.py`);
5. il video si scaricava solo nel segno, mai alla carta che si scopre
   (padre FZ.06, `il_video_della_carta_si_scarica_mentre_si_scopre`,
   `d3d0491e`);
6. la carta della FZ.04: la testa si vedeva al terzo pezzo, la carta stava
   dietro le barre, le carte a meta' mancavano nel Diario; il volto si
   apriva da solo con un Diario vecchio (padre FZ.04,
   `il_volto_si_scopre_per_ultimo`, `le_carte_a_meta_stanno_nel_diario`,
   `fe18050e`, `c3b74295`, `f19d3c44`); per parola del fondatore si gratta
   l'immagine dell'animale di lato;
7. il cammino in alto mostrava la sagoma nitida dell'animale prima del
   riconoscimento (padre DE.09, `il_cammino_non_rivela_l_animale`,
   `c3b74295`);
8. "Condividi come video" non funzionava sul telefono: `drawtext` non c'e'
   nella libreria Android (padre FZ.08, prova
   `condividi_la_rivelazione_in_video_test.dart`, `41585ba7`); persona (g)
   completata;
9. dopo un riavvio i video scaricati si dimenticavano (padre FZ.06,
   `i_video_gia_scaricati_si_ritrovano`, `47d80821`);
10. la riserva del segno diceva si' o no a caso a una domanda aperta (padre
    DI.14, `a_una_domanda_aperta_il_segno_non_dice_si`, `036dffda`);
11. chi era a meta' col vecchio sistema non riceveva l'avviso (padre FZ.02,
    `l_avviso_della_migrazione_arriva_al_viaggio`, `7ab00db3`).
In piu', per richiesta del fondatore: il pulsante "Scopri chi e'" nella
soglia dopo la rivelazione, con le qualita' del Passport in un popup
(`il_tuo_animale_dalla_soglia`, `33970c3d`); e corretti i testi che
legavano l'animale al segno ("Dal tuo cielo, Leone"; "Rivelalo dal mio
cielo"), padre FZ.07. **Restano aperte** FZ.09 (la parte "modello vero"
della persona (e): App Check rifiuta la build di debug, nessuna risposta del
modello e nessuna spesa), FZ.13 (la persona (l), tre giorni su sei) e
FZ.15. **Regola B**, confessata dove non e' stata rispettata: vedi il
registro delle guardie.
