# CONSEGNA, ORDINE DONI 1

Ramo `claude/doni-1-b1e463`, partito da
`origin/claude/esoteric-circle-master-order-e798aj` a `78c79be`.
Nessuna build, nessuna distribuzione, `versionCode` non toccato.
`STATO_VIVO.md` e `RIPRESA.md` non aperti in scrittura, per la deroga
dichiarata nell'ordine.

## Le sei premesse

| # | Premessa | Esito |
|---|---|---|
| 1 | Dove vive il Rito dell'Alba | dichiarata |
| 2 | I contenuti sono segnaposto | vera |
| 3 | La bolla non prende il colore del Maestro | vera |
| 4 | Le notifiche dei Doni | **non esistono** |
| 5 | Esiste il Maestro del giorno | vera |
| 6 | L'app sa calcolare il sorgere del sole | **FALSA** |

**1.** Contenuto e modello in `lib/core/rituals/dawn_gift.dart`, rotazione e
messaggi in `daily_rituals.dart`, l'elemento della striscia in
`daily_elements.dart`. A video in `lib/features/rituals/dawn_rite_screen.dart`,
`ritual_gift_card.dart` e `lib/features/santuario/daily_strip.dart`.

**2.** Vera. `provisionalOrientation` diceva che il contenuto sarebbe arrivato
dai contenuti verificati, `word` era nullo, tutto marcato `provisional: true`.

**3.** Vera. `daily_strip.dart` aveva `if (guide == null) return _gold;`, e
l'Alba ha `guide: null` perche' ruota. Da notare che la schermata piena usava
gia' la palette del Maestro: l'incoerenza era fra striscia e schermata.

**5.** Vera. `DailyRituals.dawnMaestro(date)`, e sopra c'e' gia'
`DailyElements.maestroFor(element, now)`, che e' la porta sola.

### 6, la falsa, e cosa ha comportato

L'unico motore di tempi solari era `SunsetTime`, e calcolava il **tramonto**:
costante `_altezzaTramonto`, riga finale `jSet = jTransit + h / 360.0`. Cercato
in tutto `lib`: nessun `sunrise`, nessuna `levata`, nessun sorgere. L'unico
`rising` era un flag di disegno per orientare l'icona del sole.

Il perimetro iniziale vietava `lib/core/astro/`, cioe' l'unico posto dove il
sorgere puo' stare. Mauro ha corretto il perimetro autorizzando **solo
aggiunte in coda** a `sunset_time.dart`. Il file non e' stato rinominato, come
richiesto, anche se il nome adesso mente: dice tramonto e contiene entrambi.

## LA RISPOSTA SULLE NOTIFICHE

**Il sistema non esiste, e non l'ho costruito.**

Non l'ho dedotto dalla presenza di un pacchetto, ho guardato chi chiama:
nessun pacchetto di notifiche in `pubspec.yaml`, nessuna chiamata in tutto
`lib` che programmi, invii o chieda il permesso di notificare, e quindi
nessuno che lo attivi.

Esiste solo la **dichiarazione di intenti**: `DailyElement.pushByDefault` col
commento "Unico punto di verita': di default solo Alba, Oracolo e Buonanotte
notificano", `DailyElement.id` descritto come l'id per il deep-link da notifica
push, e la voce `notifications` in `AppPermission`. Sono metadati che
descrivono un sistema mai costruito.

**Conseguenza rispettata**: nessun testo dell'Alba promette un avviso. La
fascia del risveglio si dichiara come informazione, non come sveglia.

## VOCE 1, cosa e' chiuso

### Il sorgere del sole, verificato contro fonte esterna

Aggiunto `SunsetTime.albaPerData`, in coda alla classe, senza toccare una riga
esistente. Sorgere e tramonto sono lo stesso calcolo con un segno diverso: il
tramonto e' il transito piu' l'angolo orario, il sorgere lo stesso meno.

**L'attesa non viene dalle costanti sotto esame**, come chiedeva l'ordine: i
riferimenti sono di `api.sunrise-sunset.org`, interrogata il 5 agosto 2026.

| Luogo e data | Scarto dalla fonte |
|---|---|
| Milano, 20 marzo 2026 | 2,35 minuti |
| Milano, 21 giugno 2026 | 1,70 minuti |
| Milano, 21 dicembre 2026 | 1,75 minuti |
| Sydney, 15 settembre 2026 | 2,03 minuti |

Casi polari: a Tromso in giugno e in dicembre torna null, e il chiamante
ripiega, mai un'eccezione. Stessa regola gia' in uso per il tramonto.

**Una duplicazione dichiarata e inchiodata.** Poiche' erano ammesse solo
aggiunte, il nucleo NOAA (transito e angolo orario) e' ripetuto dentro
`_estremiSolari` invece di essere estratto da `perData`. Due copie della stessa
formula sono il difetto piu' caro di questo progetto, quindi una prova pretende
che le due scritture restino d'accordo. **Quando sara' permesso modificare il
file, `perData` deve delegare a `_estremiSolari` e la duplicazione sparisce: e'
una riga**, e va fatta insieme alla rinomina in `solar_time.dart`.

### Nove forme, non un elenco di testi

`lib/core/rituals/rito_alba_corpus.dart`, tre forme per Maestro, ognuna con tre
momenti: **un gesto** da compiere, **un respiro contato** col suo numero, **una
parola da portare**. Quattro varianti per momento.

**Le combinazioni: 64 per forma, 576 in tutto.** Un elenco che ne desse
altrettante andrebbe scritto a mano cinquecento volte, e si esaurirebbe
comunque.

**L'innesto dal cielo vero.** Ogni variante dichiara di quale dato ha bisogno
fra fase lunare, segno della Luna e ora del sorgere. **Se il dato manca, la
variante non entra nella scelta**: chi non ha dato il luogo non riceve un rito
che nomina un'alba inventata, riceve un rito che nomina la Luna. I dati si
LEGGONO da `lib/core/astro/`, non si ricalcolano: `MoonPhase.forDate`,
`NightSky.moonSign`, `SunsetTime.albaPerData`.

**I tre non si somigliano, e una prova lo pretende.** Ogni forma viene pesata
sui tre lessici delle tre lenti, e deve pesare di piu' sulla propria. Medora
guarda avanti verso un'ora o un giorno, Aura tocca il corpo e mette il respiro
al centro (i suoi respiri hanno piu' giri di quelli degli altri due, ed e'
verificato), Caligo traccia o porta un segno.

**Via col dito su tutti e nove i gesti.** Nessun gesto usa sensori, per scelta,
quindi la via tattile non e' un ripiego tecnico ma la versione per chi il rito
lo fa da seduto, al buio o senza potersi muovere.

**Fonti e metodo**, nella forma dell'Estrazione Rune. Antico: la sandhya vandana
vedica, la shacharit ebraica, la salat al-fajr, e il respiro contato del
pranayama negli Yoga Sutra di Patanjali e nell'Hatha Yoga Pradipika. Moderno
dichiarato: la sequenza gesto piu' respiro piu' parola e' nostra, nessuna
tradizione la prescrive cosi'; e anche il Saluto al Sole, che si presenta come
antichissimo, e' come sequenza codificata del primo Novecento. Piu' un
paragrafo "Cosa non facciamo" che nega esplicitamente esiti.

### Il rito arriva a video

`DawnGift` porta il rito e non e' piu' `provisional`. Il segnaposto resta solo
come ripiego se il rito non si potesse comporre.

## VOCE 2, cosa e' chiuso

### Il colore

`_accentFor` prende il **Maestro**, non l'elemento, e il Maestro lo risolve
`DailyElements.maestroFor`, che gia' governa la rotazione. La bolla dell'Alba
prende blu, verde o rosso secondo chi porge il rito di oggi. L'oro fisso non
c'e' piu'.

### La fascia del risveglio

`FasciaDelRisveglio`: **un'ora dal sorgere vero del luogo della persona**.

`RitoAlba.avvisoDellaFascia` da' **tre righe, non un regolamento**: che esiste
una fascia e quale, con l'ora calcolata; che chi la rispetta riceve una riga in
piu' dal Maestro; che chi arriva dopo compie il rito per intero.

**Senza luogo la fascia non si dichiara.** Le tre righe cambiano e dicono che
serve il luogo di nascita, e una prova pretende che nell'avviso non compaia
**nessuna cifra oraria**. Stessa cosa nei casi polari.

**La riga del risveglio** arriva solo dentro la fascia, quattro varianti per
Maestro. Fuori fascia e' nulla, e senza luogo e' nulla per tutti: senza un'ora
vera non esiste un dentro e un fuori. **Il rito non si accorcia mai**: gesto,
respiro, parola e via tattile sono identici dentro e fuori.

## Le prove del rosso

Trentaquattro prove nuove in quattro file. Le dieci che l'ordine chiedeva:

| Prova del rosso | Esito | Cosa ha trovato |
|---|---|---|
| Due riti identici in trenta giorni | verde | niente, e nemmeno in 365 |
| Un rito che non nomina il cielo | verde | niente |
| Il rito di un Maestro dabile a un altro | verde | niente, ma e' la prova che ha guidato la scrittura |
| Un gesto senza via tattile | verde | niente |
| Una frase che promette un esito | verde | niente |
| La bolla con un colore non del Maestro | verde | niente |
| La fascia con un'ora fissa | verde | niente |
| La fascia dichiarata senza luogo | verde | niente |
| Il rito accorciato fuori fascia | verde | niente |
| La riga consegnata fuori fascia | verde | niente |

**Cosa hanno trovato le prove NON richieste**, che e' la parte utile:

1. **La prova sul sorgere ha trovato un mio errore di giorno.** Per Sydney con
   scarto di fuso zero avevo chiesto il 14 settembre invece del 15: l'ora del
   giorno era giusta a 3,4 minuti, ma il giorno era sbagliato di ventiquattro
   ore. Il metodo ancora il calcolo al giorno che gli si passa.

2. **Due prove gia' esistenti hanno trovato che la scheda del dono non regge il
   contenuto vero.** Finche' il dono era un segnaposto di tre righe ci stava
   sempre; col rito intero il pulsante della base finiva sotto il bordo e non
   era piu' toccabile. La scheda adesso scorre. **Non l'ho trovato io, l'ha
   trovato `rituals_test.dart`**, ed e' la ragione per cui quelle due prove
   sono state aggiornate e non aggirate.

3. **La prova trasversale sugli accenti ha trovato un difetto mio, grosso.**
   Avevo scritto tutto il corpus con gli apostrofi al posto degli accenti,
   `e'` invece di `è`, `piu'` invece di `più`: e' la convenzione dei COMMENTI
   di questo progetto, e l'ho portata dentro i testi che la persona legge.
   Erano **centocinque occorrenze** in tre file. `testo_a_video_test.dart` le
   ha prese tutte. Corretti solo i letterali, i commenti restano com'erano.
   Una frase e' stata riscritta invece che accentata: `dov'era` e' un'elisione
   legittima che l'elenco della prova non conosce, e allargare l'elenco di una
   prova trasversale per far passare il proprio testo e' il modo migliore per
   spegnerla.

4. **La cattura delle anteprime ha trovato uno sforamento di 98 pixel.**
   Finche' `word` era nulla il pulsante di condivisione non veniva mai
   costruito, e la riga in fondo alla scheda conteneva la sola spilla della
   costanza: ci stava sempre. Dal momento in cui il rito porta una parola vera i
   due elementi convivono, e la riga sforava. Adesso e' un `Wrap` e va a capo.
   **Questo difetto esisteva da sempre e nessuno poteva vederlo**, perche' la
   condizione che lo scatena, una parola vera, non si era mai verificata.

5. **La regola della virgola, violata ventiquattro volte.** `, e` prima di una
   congiunzione, in tutto il corpus. `language_rule_test.dart` le ha prese.
   L'ultima stava a cavallo di due righe del sorgente, con la virgola in fondo a
   un frammento e la `e` all'inizio del successivo: la mia correzione lavorava
   riga per riga e non la vedeva, la prova invece concatena i frammenti e la
   vedeva benissimo.

## LA CORREZIONE DEL LUOGO, chiesta prima del commit

Il rito usava il luogo di NASCITA. **Un'alba e' dove sei stamattina**: chi e'
nato a Sydney e vive a Milano vede sorgere il sole a Milano, e la fascia gli
sbagliava di ore.

**La posizione attuale esisteva gia'**, e l'ho enumerata invece di dedurla:
`geolocator: ^14.0.3` in `pubspec.yaml`; `Geolocator.requestPermission()` alla
riga 142 di `lib/core/astro/sky_location.dart`; `getCurrentPosition()` alle
righe 151 e 171; l'astrazione `SkyLocation` con `SkyPlace`, `RispostaPosizione`
e `EsitoPosizione`; e soprattutto **`resolveSeConcesso()`**, che legge la
posizione solo se il permesso c'e' gia', senza aprire richieste. C'era perfino
gia' `OrigineCoordinate`, con `dispositivo`, `nascita` e `nessuna`, e il
commento che dice che un cielo che non dichiara da dove e' guardato non si puo'
verificare: **il concetto era gia' stato riconosciuto, per la veduta del cielo,
e non era arrivato al rito**.

Cosa e' cambiato:

- Nuova `PosizioneDiStamattina`, che tiene coordinate, scarto di fuso e
  **origine**, con l'invariante che le prime due vengono sempre dalla stessa
  sorgente. Col dispositivo entrambe vengono dal telefono; senza, la longitudine
  **nasce** da `SunsetTime.longitudineDaFuso` sullo stesso scarto che poi
  riporta l'ora a muro, e la latitudine e' `latDiRipiego`. Non possono divergere
  per costruzione, e una prova lo verifica su quattro fusi diversi.
- `OrigineDellAlba` non riusa `OrigineCoordinate` perche' a quella manca il caso
  STIMATA e il file non si puo' modificare. Il caso `nascita` **non esiste**
  apposta: per l'alba non e' mai una risposta valida.
- **Con la posizione stimata dal fuso l'ora non si dichiara**, come nel caso
  senza luogo: la longitudine dedotta dall'offset puo' sbagliare di mezz'ora
  abbondante. In quel caso il rito non nomina nemmeno l'alba e usa la Luna.
- L'avviso senza posizione non parla piu' di luogo di nascita: chiede dove sei
  stamattina, e una prova pretende che la frase `luogo di nascita` non compaia.
- La schermata legge la posizione con `resolveSeConcesso` **dopo** aver composto
  il rito, e lo ricompone se arriva: nessuna finestra di sistema all'alba.

**Dove resta usato il luogo di nascita**, legittimamente: `profile_store.dart`
per la persistenza, `dati_di_nascita_screen.dart` e `onboarding_screen.dart` per
raccoglierlo, `sky_overview_screen.dart:532` come origine di ripiego della
veduta del cielo, e la carta natale via `natal_chart_controller`. Nel Rito
dell'Alba non entra piu' da nessuna parte, e una prova strutturale lo blocca.

## UNA PROVA GIA' ROSSA SUL CANONICO, che non e' mia

`test/ask_maestri_test.dart`, prova "I testi a video non usano il trattino
lungo e hanno accenti veri", **fallisce anche senza il mio lavoro**: verificato
mettendo da parte tutte le mie modifiche e rieseguendola sul solo `78c79be`.
L'asserzione che cade e' `testi.any((s) => RegExp('[àèéìòù]').hasMatch(s))`,
cioe' nessun testo mostrato dalla schermata "Chiedi ai Maestri" contiene un
accento vero.

Sta in `lib/features/maestri/`, cartella dell'altra sessione, quindi non l'ho
toccata. **Va segnalata a chi lavora li'**: e' il tipo di difetto che questa
prova esiste per prendere.

## Cosa NON e' il massimo

1. **La posizione si legge solo se il permesso c'e' gia'.** Il rito non apre una
   richiesta di sistema all'alba, il che e' giusto, ma vuol dire che chi non ha
   mai concesso la posizione non vedra' mai la fascia. Manca il punto in cui
   chiederla con garbo, e non e' questo.

2. **Nessuno conserva la posizione fra un avvio e l'altro.** `SkyLocation` la
   rilegge ogni volta dal sensore. Per il rito basta, ma e' la voce da mettere
   in coda insieme al luogo attuale nel profilo.

3. **Il nucleo NOAA e' scritto due volte** dentro `sunset_time.dart`, per il
   vincolo delle sole aggiunte. E' inchiodato da una prova, ma resta un debito
   con una riga di interesse.

4. **Il seme del rito e' una terza hash.** In `lib/core/rituals` ce ne sono gia'
   due private, in `sunset_rune.dart` e `guide_animal_day.dart`, ma lavorano su
   tipi diversi e unificarle cambierebbe la runa e l'animale che escono a
   tutti: un cambiamento di comportamento che quest'ordine non chiedeva. Debito
   dichiarato, merita un ordine suo.

5. **Il rito non usa i transiti**, che pure adesso esistono. Nomina la Luna e
   l'alba, non Marte in trigono: sarebbe stato oltre il perimetro, e la base del
   dono resta giustamente `provisional`.

6. **La riga del risveglio ha quattro varianti per Maestro**, contro le
   sessantaquattro del rito. Chi si alza presto ogni giorno la vede ripetersi
   dopo quattro giorni, molto prima del rito.

7. **Le notifiche non ci sono**, quindi la fascia la scopre solo chi apre l'app
   di sua iniziativa. Un'ora che premia senza nessuno che la ricordi premia chi
   gia' si sveglia presto.

## I numeri della chiusura

- **Prove nuove**: 34, in 4 file.
- **File nuovi**: 3 in `lib/core/rituals/`, 4 in `test/`.
- **File modificati**: 4, di cui `sunset_time.dart` in sola aggiunta.
- **Cartelle vietate toccate**: nessuna.
