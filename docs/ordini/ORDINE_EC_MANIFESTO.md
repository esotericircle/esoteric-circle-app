# ORDINE EC, IL COLLAUDO DEI MAESTRI CON GEMINI VERO E IL VERSO NEL RICORDO CUSTODITO

**Sigla:** EC, la prima libera dopo EB: verificato sul ramo che in
`docs/ordini` non c'e' nessun `ORDINE_EC_*`, in `test/` nessuna
`ordine_ec_guard`, e che nessun documento nomina un ordine EC. **Data:** 21
settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`. Parte
dal commit `bc64a71c`, l'ordine EB chiuso.

VOCI_TOTALI: 6
VOCI_CHIUSE: 6
VOCI_APERTE: 0

Il rapporto stara' in `docs/ordini/RAPPORTO_ORDINE_EC.md`.

---

## GLI SCARTI FRA L'ORDINE E IL RAMO

1. **L'ordine dice che `stesa_tre_carte_screen.dart:1734` scrive i nomi delle
   carte.** Sul ramo di oggi la riga e' la **1733**, dentro il
   `ResponsoDaCustodire` che comincia a `:1728`. Il fatto e' esatto, la riga
   si e' spostata di una.
2. **Il difetto e' piu' largo di come l'ordine lo descrive, e in due modi.**
   Primo: non e' solo la Stesa, e' anche **l'Estrazione Rune**
   (`rune_draw_screen.dart:1628`, `r.rune.name` nudo). Secondo, e piu' grave:
   **il verso che due arti gia' salvano non arriva mai al disegno**, vedi la
   voce EC.05.
3. **Il verso non e' perduto: vive nel TESTO custodito**, per la Stesa e per
   l'Estrazione. E' cio' che rende possibile il recupero della voce EC.06, e
   l'ordine lo prevede senza saperlo.

---

## PARTE PRIMA, IL COLLAUDO DELLE CHAT CON GEMINI VERO

## VOCE EC.01, IL COLLAUDO

**La strada e' quella dell'app, con una differenza sola e dichiarata.** Il
collaudo guida un `MaestroChatController` vero: l'instradamento, il cancello
delle arti dell'ordine EB, i contatori e la memoria degli inviti sono quelli
che girano sul telefono. **Cambia il trasporto**: l'app parla a Vertex con
l'SDK di Firebase e un gettone di App Check, che sul banco non si ottiene
(dichiarato dal 2 agosto 2026 in `lib/services/firebase/attestazione.dart`);
il collaudo parla **allo stesso modello, nella stessa regione**, con una
chiamata REST e il gettone della sessione `gcloud`. Istruzione di sistema,
modello, regione e configurazione arrivano dagli stessi punti del codice:
`MaestroPersona.systemInstruction`,
`FirebaseMaestroAiProvider.kMaestroChatModel`, `europe-west1`,
`MisuraDellaRisposta`.

**Sta in `tool/collaudo_dei_maestri.dart`** e si rilancia con un comando solo:

```
flutter test tool/collaudo_dei_maestri.dart
```

**Le sedici mosse sono quelle del catalogo dell'ordine EB voce 07**, con gli
stessi numeri. Dove la mossa ha senso solo dentro una conversazione, il
collaudo la costruisce a piu' scambi. **La mossa 7, il messaggio vuoto, non
manda niente al modello** ed e' gia' misurata nella suite
(`un_rifiuto_vale_per_tutta_la_conversazione_test.dart`): qui non si spreca
una chiamata per guardare un ramo che torna prima.

**Il caso esatto del fatto del 21 settembre 2026 e' la mossa 3**, per intero:
il testo che la porta di approfondimento compone dopo l'ordine EB voce 01,
con la domanda *"Lavoro e carriera"* e le carte Il Papa, Re di Spade e Dieci
di Spade, e subito dopo *"Ma io non voglio fare un'altra stesa di tarocchi.
Voglio solo la tua interpretazione"*.


### Fatto

`tool/collaudo_dei_maestri.dart`, diciassette prove, una per mossa e per
Maestro. **Il giro finale e' pulito**: zero cadute, zero parole di firma
altrui, **diciassette chiamate a Gemini piu' una domanda chiusa al giudice**.

**La mossa 3 e' il caso del fondatore per intero**, e passa: Medora
interpreta Il Papa, il Re di Spade e il Dieci di Spade con la domanda
*"Lavoro e carriera"*, e al rifiuto *"non voglio fare un'altra stesa"* non
ripropone niente e risponde.

**Una cosa e' stata sistemata nel banco e non nel prodotto**: mancava
`TestWidgetsFlutterBinding.ensureInitialized()`, e la mossa 4 finiva in un
ripiego con *"Il cielo non e' ancora aperto su questo telefono"*. Non era
l'app: era il banco senza binding, e il guasto arrivava come se fosse vero.

**CHIUSA.**

## VOCE EC.02, I CONTROLLI SU OGNI RISPOSTA

Sei controlli, uno per regola dell'ordine EB, tutti automatici. **Cinque sono puri e vivono in `tool/controlli_del_collaudo.dart`**, dove una prova senza rete li fa cadere su difetti costruiti; il sesto chiede al modello:

| controllo | voce di EB | come si misura |
|---|---|---|
| risponde nel merito, nessun invito al posto della risposta | EB.02 | la risposta non contiene nessuno dei quindici inviti ne' delle quindici etichette dei pulsanti di `immersive_intents.dart`, **e** contiene le parole che quella mossa pretende, come i nomi delle carte |
| il pulsante solo se l'utente lo chiede | EB.03 | l'`intentId` della bolla c'e' se e solo se il turno lo dichiara |
| niente ripetizioni e niente proposte rifiutate | EB.05 | nessuna risposta identica a una gia' data nella conversazione; nessun `intentId` dopo un rifiuto |
| quando mancano i dati il Maestro li chiede | EB.06 | una domanda chiusa a Gemini, a temperatura zero: *sta dicendo di non aver capito, oppure chiede di chiarire?* Un elenco di frasi non insegue la lingua libera, e ci ha provato tre volte |
| i contatori scendono solo sulla risposta vera | EB.04 | il contatore sceso e' pari ai turni dichiarati costosi |
| ogni Maestro con la sua voce | EB.08 | si **conta** ogni parola di firma altrui e il giro la riporta; fa cadere solo **due o piu' nella stessa risposta**, perche' su testo generato un cancello binario misura la fortuna del giro. Sulle frasi che scriviamo noi il cancello resta a zero |

**La meta' positiva conta quanto quella negativa.** Non basta che il Maestro
non devii: sulla mossa 1 e sulla 3 la risposta **deve nominare le carte**, o
non sta rispondendo nel merito di quello che e' stato chiesto.


### Fatto

**I controlli stanno in `tool/controlli_del_collaudo.dart`, separati da chi
li esegue**, e li prova senza rete
`test/i_controlli_del_collaudo_prendono_i_difetti_test.dart`. E' la regola A
applicata a un collaudo che costa: **una regola che si puo' provare solo
pagando non la prova nessuno**, quindi il difetto si costruisce invece di
aspettare che il modello sbagli. Sette controlli, sette rossi su difetti
costruiti, piu' una prova che una risposta pulita non fa cadere niente.

**Tre controlli erano gia' caduti su risposte vere durante i sette giri**, ed
e' una prova piu' forte: il chiarimento, il contatore e il lessico.

**UN CONTROLLO HA CAMBIATO STRUMENTO TRE VOLTE PRIMA DI MISURARE LA COSA
GIUSTA, e va scritto perche' insegna.** Il chiarimento cercava prima il punto
interrogativo, poi un elenco di frasi, poi un elenco piu' lungo. Caligo lo
chiedeva ogni volta con parole nuove: *"Chiedo la tua data di nascita"*, poi
*"Non comprendo il tuo segno. Riformula"*, poi *"Le tue parole non sono un
segno chiaro [...] Poni un quesito"*. **Tutte e tre le volte il comportamento
era giusto e l'elenco sbagliato**, e allungarlo ancora sarebbe stato
inseguire la lingua di ieri. Adesso la domanda la fa il modello, chiusa, a
temperatura zero: la grandezza misurata e' la stessa, lo strumento no.

**E UNO HA SMESSO DI ESSERE UN CANCELLO, dichiarato invece che nascosto.** Il
divieto incrociato del lessico, su testo **generato**, passava da una
violazione su quindici risposte a tre e viceversa, su mosse diverse a ogni
giro, senza che il codice cambiasse in mezzo. **Un cancello binario su un
generatore misura la fortuna del giro, non il prodotto.** Adesso si misura il
tasso, che il giro riporta e la trascrizione scrive, e resta cancello una
cosa sola: **due o piu' parole di firma altrui nella stessa risposta**, che
non e' una parola scappata ma il registro di un altro Maestro che passa
attraverso. **Sulle frasi che scriviamo noi il cancello resta chiuso a
zero**, e le guardie ci sono.

**CHIUSA.**

## VOCE EC.03, LE CADUTE SI RIPARANO


### Fatto

**Tre difetti trovati dal collaudo e riparati, piu' uno del banco.**

**1. La premessa della lettura ridetta era una frase sola per i tre, e diceva
"cielo".** Trovata al primo giro, sulla mossa 10 fatta ad Aura: *"Me l'hai
gia' chiesto oggi. Il cielo di oggi non e' cambiato"*, detta anche da Aura e
da Caligo. E' lo stesso difetto del benvenuto della voce EB.08, in un punto
che quell'ordine non aveva guardato, e **pesa piu' di quanto sembri**: e' una
delle pochissime frasi che il Maestro dice senza passare dal modello, quindi
nessuna istruzione puo' correggerla. Adesso `LaLetturaDelGiorno.premessaDi`
ne ha una per Maestro. **Padre: PROVENIENZA IGNOTA**, nasce col file.

**2. Davanti a un messaggio incomprensibile il Maestro non diceva di non
aver capito**: Caligo chiedeva la data di nascita, che per capire *"asdf
qwerty zzz"* non serve a niente. Aggiunta una riga a `LaRispostaNelMerito`:
*"Se non capisci quello che ti e' stato scritto, dillo e chiedi che cosa
intende [...] non chiedere dati che non ti servono"*. **Padre: EB voce 06**,
che diceva di chiedere cio' che manca senza dire di non inventare un bisogno.

**3. Il divieto incrociato del lessico veniva violato, e rafforzare la frase
non e' bastato.** Fra il primo giro e il secondo le violazioni sono passate
da una a tre **dopo** aver reso l'istruzione piu' ferma: **scrivere la regola
piu' forte non la fa rispettare**. E' nata una rete,
`lib/core/maestro/la_voce_non_si_confonde.dart`, dentro `VoceSorvegliata`:
guarda cio' che torna e, se la voce si e' confusa, **chiede un'altra volta**.
Un ritentativo solo, e se anche la seconda si confonde passa quella con meno
parole altrui e il guasto va nel registro: **una risposta imperfetta vale
piu' di nessuna risposta**. Dopo la rete: da tre violazioni su quindici a
zero su diciassette. **Padre: PROVENIENZA IGNOTA**, e' un comportamento del
modello, non una riga di codice.

**4. Il banco non inizializzava il binding**, e una mossa finiva in un
ripiego che sembrava un guasto del prodotto.

**L'istruzione di sistema e' cambiata due volte in quest'ordine, e non in
silenzio**: le impronte sono state riregistrate e le vecchie sono scese nello
storico con la data e con cio' che le ha fatte cadere. **La misura
dell'attribuzione cieca era gia' dichiarata non valida e resta tale**: e' uno
dei due rossi accettati.

**CHIUSA.**

## VOCE EC.04, LE TRASCRIZIONI PER IL GIUDIZIO DI MAURO

Le conversazioni del giro finale stanno in `docs/collaudo/EC/`, una per mossa
e per Maestro, in italiano e leggibili da una persona, con accanto l'esito di
ogni controllo. **Il tono e l'illusione della persona vera non li misura
nessun controllo**: li giudica il fondatore leggendo quelle pagine, e il
rapporto non li da' per verificati.


### Fatto

Diciassette trascrizioni in `docs/collaudo/EC/`, una per mossa e per Maestro,
con la domanda, la risposta per intero, il pulsante se c'e', le parole di
firma altrui incontrate e l'esito di ogni controllo. Accanto, `_chiamate.txt`
col conto delle chiamate, del giudice, il modello e la regione.

**Il tono e l'illusione della persona vera non li misura nessun controllo**,
e in fondo a ogni trascrizione c'e' scritto. Li giudica il fondatore
leggendo: **nel rapporto non sono dati per verificati.**

**CHIUSA.**

---

## PARTE SECONDA, IL VERSO NEL RICORDO CUSTODITO

## VOCE EC.05, I RICORDI NUOVI SALVANO IL VERSO

### Il censimento: le dodici arti che custodiscono un Ricordo

`ResponsoDaCustodire` e' definito in
`lib/features/ricordi/azioni_del_responso.dart:55-72` e porta quattro campi:
`arte`, `titolo`, `testo` e `dati`. Viene travasato in un `RicordoCustodito`
(`lib/core/ricordi/ricordo_custodito.dart:45-128`) e salvato in due posti: sul
telefono in `SharedPreferences` sotto la chiave `ricordi.custoditi`
(`scrigno_dei_custoditi.dart:118-125`) e sul server in
`users/{uid}/custoditi/{chiave}` con la callable `custodisciIlResponso`
(`functions/src/ricordi.ts:229-248`). **L'identita' e' `minuti.arte`**
(`ricordo_custodito.dart:89-92`), quindi un Ricordo si puo' riscrivere in
posto.

I punti che costruiscono un `ResponsoDaCustodire` sono **dodici**, e
coincidono con `ArtiConResponso.tutte`
(`lib/core/ricordi/arti_con_responso.dart:71-176`):

| # | arte | file:riga | cosa mette nei `dati` | ha carte o rune? |
|---|---|---|---|---|
| 1 | `stesa` | `stesa_tre_carte_screen.dart:1728` | `carte`, coi nomi **nudi** (riga 1733) | **si'** |
| 2 | `gettata` | `rune_draw_screen.dart:1622` | `gettata`, `rune` coi nomi **nudi** (riga 1628) | **si'** |
| 3 | `alba` | `arcano_dell_alba_screen.dart:171` | `carta` nuda, **`verso`**, `parola` (righe 183-187) | **si'** |
| 4 | `tramonto` | `sunset_rune_screen.dart:2365` | `runa`, **`verso`** (righe 2370-2373) | **si'** |
| 5 | `oroscopo` | `oroscopo_screen.dart:1675` | `segno` | no |
| 6 | `sinastria` | `sinastria_vip_screen.dart:1106` | `vip`, `punteggio` | no |
| 7 | `sogno` | `dream_rite_screen.dart:1074` | `maestro` | no |
| 8 | `soffio` | `breath_destiny_screen.dart:847` | nessun dato | no |
| 9 | `sigillo` | `sigillo_intenzione_screen.dart:793` | `via` | no |
| 10 | `animale_guida` | `guide_animal_screen.dart:768` | `animale` | no |
| 11 | `viso` | `face_constellation_screen.dart:1793` | `tratto`, `categoria` | no |
| 12 | `archetipo` | `archetype_test_screen.dart:978` | `archetipo` | no |

**Le arti con carte o rune sono quattro, non una.** L'ordine ne nomina una.

### Dove sta il verso oggi, arte per arte

| arte | nei `dati` | nel `testo` | esito |
|---|---|---|---|
| `stesa` | **no** | **si'**: `TarotSpread.reading` compone con `displayName` (`tarot_spread.dart:74-77`) | il verso si legge e non si disegna |
| `gettata` | **no** | **si'**: il presagio nomina ogni runa col verso (`rune_presage.dart:424-444`) | idem |
| `alba` | **si'** (riga 185) | **si'**: `cartaColVerso` (`responso_dell_alba.dart:104-106`) | il dato c'e' e **nessuno lo legge** |
| `tramonto` | **si'** (riga 2372) | **no**: il testo e' la riga di corpus del verso giusto ma non lo nomina | **e' l'unica che funziona** |

### IL DIFETTO PIU' GRAVE, CHE L'ORDINE NON NOMINA

**Il verso che due arti gia' salvano non arriva mai al disegno dei tarocchi.**
In `lib/features/ricordi/ricordi_screen.dart` il ramo della carta torna a
`:1060-1068` con `TarotCardArt`, e la rotazione che capovolge una figura in
ombra sta **dopo**, a `:1079-1081`. Il commento di quella rotazione parla di
rune e di rune sole. Quindi:

- una carta rovesciata in un Ricordo si disegna **sempre dritta**, anche
  quando il dato dice il contrario;
- l'Arcano dell'Alba, che il verso lo salva da sempre, non lo ha mai mostrato;
- `ArtworkDelRicordo` legge `dati['verso']` per il solo `tramonto`
  (`artwork_del_ricordo.dart:131`), e per l'`alba` non lo legge affatto
  (`:125-127`).

**Padre: PROVENIENZA IGNOTA.** La rotazione nasce per le rune e nessun ordine
risulta aver considerato le carte.

### Cosa cambia col lavoro

Le due arti che perdono il verso lo salvano; l'`alba` lo fa leggere; il
disegno capovolge anche le carte. Le otto arti senza carte ne' rune restano
invariate.


### Fatto

**Tre difetti, non uno.**

**1. La Stesa e l'Estrazione non salvavano il verso**, e adesso lo salvano in
una chiave sua, `versi`, una voce per figura e nello stesso ordine dei nomi.
**Il nome resta nudo** perche' e' con quello che il Ricordo ritrova la figura
nel mazzo: cambiarlo in `displayName` avrebbe rotto il riconoscimento, e la
carta sarebbe sparita invece di girarsi.

**2. Il verso salvato non arrivava al disegno delle carte.** In
`ricordi_screen.dart` il ramo della carta tornava con `TarotCardArt`
**prima** della rotazione, e quella rotazione parlava di rune e di rune sole.
`TarotCardArt` sapeva gia' disegnare una carta rovesciata, `reversed`:
mancava chi glielo dicesse. **L'Arcano dell'Alba il verso lo salvava da
sempre e non lo ha mai mostrato.** **Padre: PROVENIENZA IGNOTA**, la
rotazione nasce per le rune.

**3. `ArtworkDelRicordo` leggeva il verso per il solo `tramonto`.** Adesso lo
legge per tutte e quattro, e un Ricordo vecchio senza quella chiave resta
leggibile com'e': dove l'elenco dei versi non arriva, la figura vale dritta.

**La misura, prima e dopo**, sulle quattro arti con figure: prima **due su
quattro** non salvavano il verso e **una su quattro** lo mostrava; adesso
**quattro su quattro** lo salvano e **quattro su quattro** lo mostrano.

Guardia `test/il_ricordo_custodito_porta_il_verso_test.dart`, col cardinale
minimo sulle quattro arti, **nata rossa sui tre difetti insieme**. Legge il
sorgente senza i commenti, perche' i commenti di questa cura nominano il
difetto che cura.

**Prodotto e agganciato; a video lo vede il fondatore aprendo un Ricordo con
una carta rovesciata.** **CHIUSA.**

## VOCE EC.06, I RICORDI GIA' SALVATI: IL VERSO SI RECUPERA DOVE SI PUO'

**Decisione del fondatore del 21 settembre 2026**, alla domanda sui Ricordi
gia' salvati senza verso: *"Recupera dove si puo'"*.

**Il recupero e' possibile perche' il verso non e' perduto: sta nel testo.**
Per la Stesa il testo custodito e' `TarotSpread.reading`, che nomina ogni
carta con `displayName`, cioe' col rovescio accordato. Per l'Estrazione il
testo e' il presagio, che dice *"in merkstave (rovesciata)"* o *"diritta"*.
Dove il testo lo dice, il verso si ricostruisce; **dove non lo dice, il
Ricordo resta com'e'**: nessun verso inventato.

**Non esiste nessuna migrazione sul ramo**, verificato: nessun campo di
versione in `RicordoCustodito.aMappa()` (`ricordo_custodito.dart:94-102`) e
nessun codice che riscriva i dati di un custodito esistente.


### Fatto

**Il recupero legge il testo, perche' e' li' che il verso e' rimasto.**
`lib/core/ricordi/il_verso_recuperato.dart`: per la Stesa cerca il nome della
carta seguito dalla parola del rovescio accordata al suo genere, che e'
esattamente come `DrawnCard.displayName` l'ha scritto; per l'Estrazione
guarda cosa segue il nome della runa nella terza parte del presagio, *"in
merkstave"*, *"rovesciata"*, *"diritta"* o *"dritta"*.

**NESSUN VERSO SI INVENTA, ed e' la regola che comanda su tutte.** Se il
testo non dice il verso di **anche una sola** figura di quel Ricordo, il
Ricordo resta esattamente com'e'. Un elenco a meta' scriverebbe *dritta* dove
non si sa, e **un Ricordo senza verso non dice niente, un Ricordo con un
verso supposto dice il falso**.

**Dove gira**: in `ScrignoDeiCustoditi.carica()`, cioe' alla prima apertura
dopo l'aggiornamento. **Una volta sola e innocuo se si ripete**: un Ricordo
che la chiave ce l'ha gia' non viene nemmeno guardato, quindi al secondo giro
non c'e' niente da fare e lo scrigno non si riscrive.

**Non si perde niente.** Il recupero passa da `RicordoCustodito.conDati`, che
rifa' lo stesso Ricordo cambiando i soli dati: data, arte, Maestro, titolo,
testo e come e' nato restano quelli, e i dati vecchi pure. La guardia lo
misura campo per campo.

**L'esito misurato su sette Ricordi costruiti apposta: tre recuperati,
quattro rimasti com'erano, nessuno perso.** I quattro intatti sono i casi
giusti: due col testo che non dice il verso, uno che la chiave ce l'ha gia',
uno di un'arte senza figure.

Guardia `test/il_verso_si_recupera_dove_si_puo_test.dart`, col cardinale
minimo sui casi, **vista rossa con due innesti**: inventare *dritta* dove non
si sa, e rifare il lavoro a ogni apertura.

**Prodotto e agganciato; a video lo vede il fondatore aprendo un Ricordo
vecchio con una carta rovesciata.** **CHIUSA.**

---

## LE GUARDIE

**Regola A**: ogni guardia nuova si vede rossa con un difetto innestato a
mano e verificato col grep, e chi gira su un insieme scoperto a esecuzione
dichiara il suo cardinale minimo.

**Regola B**: le guardie che gia' coprono queste zone si vedono rosse prima,
e la data va in `docs/guardie.md`. Le zone sono due: le chat dei Maestri
(ordine EB) e i Ricordi custoditi, dove la guardia principale e'
`ogni_custodito_ritrova_la_sua_arte_test.dart`. **Quella guardia asserisce il
verso per il solo `tramonto`** (`:197-220`), ed e' l'unica asserzione sul
verso in tutta la suite.

**Regola C**: ogni difetto e' attribuito, o porta per esteso **PROVENIENZA
IGNOTA**.
