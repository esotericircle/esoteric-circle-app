# RAPPORTO DELL'ORDINE FZ, L'ANIMALE DI POTERE CHE SI RIVELA NEL VIAGGIO

17-19 ottobre 2026. Testo dell'ordine, con l'aggiunta FZA eseguita dentro di
lui: `docs/ordini/ORDINE_FZ_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FZ_
MANIFESTO.md`, 15 voci: 12 chiuse, 3 aperte in attesa di verifica, 0 da
fare. Ramo `claude/esoteric-circle-master-order-e798aj`.

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
  di FZA.01. La sua guardia (`test/le_tre_ombre_sono_verticali_e_grandi_
  test.dart`) e' stata tolta dal ramo: misurava un soggetto che non c'e'
  piu', e una guardia su un soggetto sparito e' una guardia che non
  sorveglia niente, non uno storico da tenere.
- **Il sospetto sul pulsante "Scendi" nella persona (l)** (FZA.04): dieci
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
| FZA.01, nove ombre, se ne segue una | `test/le_nove_ombre_stanno_tutte_a_schermo_test.dart` |
| FZA.02, le ombre nuove a caso per ogni persona | `test/le_ombre_che_ritornano_test.dart` |
| FZA.03, nessun numero di animali in vista | `test/nessun_numero_di_animali_in_vista_test.dart` |
| FZA.05, il riquadro segue la carta, non taglia le gambe | `test/il_riquadro_dell_animale_segue_la_carta_test.dart` |

## LE VOCI APERTE E CHE COSA ASPETTANO

| voce | che cosa e' fatto | che cosa aspetta |
|---|---|---|
| FZ.09, la simulazione da persona | a, b, f complete; e, g parziali; difetto critico di CPU trovato e risolto | Mauro: le credenziali dell'account di prova per c, d e il resto di e, g |
| FZA.04, la simulazione delle nove ombre | h completa; i parziale (2 discese); l interrotta da un episodio non confermato | Mauro: le stesse credenziali, per completare i e ripetere l |
| FZ.10, la consegna | manifesto, guardia, rapporto, STATO_VIVO, registro guardie, push sul ramo canonico | il verde di GitHub sul commit consegnato; le due voci sopra |

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
- **FZA.01, FZA.02**: padre FZ.01 (il numero fisso a tre e l'ordine del
  catalogo, mai specificato come regola, solo come implementazione) e il
  rilievo dell'Architetto del 19 ottobre 2026, approvato dal fondatore.
- **FZA.03**: padre nessuno specifico; richiesta diretta del fondatore in
  vista di un catalogo futuro piu' grande.
- **FZA.04**: vedi FZ.09 per il difetto di CPU (stesso padre, PROVENIENZA
  IGNOTA) e per l'incidente operativo.
- **FZA.05**: PROVENIENZA IGNOTA. Il riquadro a 1,35 esisteva gia' nella
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

- **Numerazione FZA.05 per il riquadro che tagliava le gambe**: la
  richiesta e' arrivata in chat durante l'esecuzione dell'ordine, con uno
  screenshot, fuori dal testo scritto di FZ e di FZA. Trattata come una
  voce a se' (non piegata dentro FZA.01, che parla delle ombre della
  discesa, non del riquadro della risalita) perche' tocca un file e un
  widget diversi, con una sua prova gia' scritta e verde.
- **Seme deterministico con FNV-1a a 31 bit**: riusato lo stesso pattern
  gia' in uso in `sunset_rune.dart` per la stessa esigenza (un numero
  pseudocasuale ripetibile da una stringa, dentro i limiti di
  `Random(seed)` di Dart), invece di inventarne uno nuovo.
- **FZ.09 e FZA.04 dichiarate APERTA IN ATTESA DI VERIFICA invece che
  CHIUSA**: il testo dell'ordine lega esplicitamente la consegna (FZ.10)
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
  consegna finale di FZ.10**: il lavoro verificabile (158 prove verdi
  della zona Viaggio/Animale Guida, oltre alle prove della zona piu' ampia)
  e' pronto e non deve restare solo sul filesystem locale in attesa delle
  simulazioni rimaste, che dipendono da un gesto di Mauro.

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
