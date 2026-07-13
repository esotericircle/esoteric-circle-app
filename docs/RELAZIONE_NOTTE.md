# Relazione della notte

Sessione notturna autonoma. Un task alla volta, in ordine. Dopo ogni task:
`flutter analyze` pulito, test verdi, screenshot headless committati, una riga
qui. Niente che richieda console Firebase, telefono, generazione immagini su
Vertex o credenziali. Niente pubblicazioni, niente PR.

## Task 1, schermata "Il cielo sopra di te" — FATTO

Costruita la schermata vera che si apre dal tocco sul cielo del Santuario, al
posto del segnaposto. Cosa contiene:

- Cielo ancorato all'ora di adesso: nuovo motore `lib/core/astro/night_sky.dart`
  che, dalla data, calcola la longitudine eclittica reale del Sole e quindi le
  costellazioni all'opposizione, cioè quelle alte a mezzanotte stanotte.
- Luna nella fase reale del momento (motore `moon_phase` già esistente).
- Corpi toccabili ed evidenziati: la Luna e le tre costellazioni alte, ciascuno
  con etichetta e una riga breve di cosa è, nella voce di Medora. Toccando un
  corpo la scheda in basso mostra la sua riga.
- La volta scorre col giroscopio (via `ParallaxController`), con ripiego allo
  scorrimento del dito per chi non ha il sensore, e si ferma con Riduci
  Movimento.
- Freccia Indietro che torna al Santuario, mai un vicolo cieco. Il cielo del
  Santuario apre già questa schermata (stessa route), ora non più segnaposto.
- I pianeti restano segnaposto dichiarato in schermo, in attesa del motore a
  effemeridi.

Limite dichiarato, non finto: nel repo non esisteva un motore del cielo di
nascita con catalogo J2000 e coordinate equatoriali reali da riusare. C'erano
gli asterismi stilizzati ma fedeli dello zodiaco (`zodiac_figures.dart`) e la
Luna reale. Ho costruito su quelli, usando astronomia vera per ciò che non
dipende dal luogo (posizione del Sole, opposizione). Il posizionamento reale
rispetto all'orizzonte, con stelle nominate e pianeti, richiede il motore a
effemeridi e la posizione dell'osservatore: resta il passo successivo.

Test: `test/night_sky_test.dart` (segno del Sole per stagione, costellazioni
opposte al Sole, longitudine in range, accenti puliti) e
`test/sky_overview_test.dart` (corpi presenti e toccabili, scheda, freccia
Indietro). Screenshot: `docs/preview/cielo-sopra-di-te.png`.

Dubbi aperti per te: la geometria delle costellazioni è ancora l'asterismo
stilizzato, non la posizione reale in alt-azimut. Serve decidere se il motore
del cielo userà un catalogo J2000 con la posizione GPS dell'utente (richiede
permesso di localizzazione) oppure una veduta simbolica indipendente dal luogo.

## Task 2, riconciliazione delle persone dei Maestri — FATTO

Allineati i prompt di sistema, i suggerimenti e i testi al canone.

- Regole comuni: aggiunta l'anatomia del responso a quattro strati (il segno
  grafico lo dà l'app, poi sintesi, testo narrato, infine invito o domanda) e
  la regola anti invenzione, con la memoria dichiarata unica e condivisa fra i
  tre, letta da ciascuno con la propria lente: usa solo i dati nel contesto, se
  un dato manca lo dichiara con garbo, tono di custodia mai punitivo. Restano
  le regole di lingua, il disclaimer una sola volta, niente consigli medici,
  legali o finanziari, niente promesse deterministiche.
- Medora: voce del cielo e delle carte, elegante e materna non sdolcinata,
  ancorata al dato astrologico reale, evita oroscopi generici e toni da fiera.
- Aura: voce del respiro del corpo e dell'anima, invita a un piccolo gesto,
  valida l'emozione senza amplificarla, base psicologica reale, evita promesse
  terapeutiche e linguaggio da guru.
- Caligo: custode di rune e riti, saggio potente e luminoso non oscuro, magia
  bianca rossa e blu mai nera, immagini di fuoco metallo nebbia e soglie mai
  horror, nessun rito sulla volontà di terzi, riformulato come crescita,
  protezione o abbondanza.
- Suggerimenti: le cinque categorie canoniche (amore, lavoro, fortuna,
  successo, relazioni) declinate nel dominio di ciascun Maestro, in testa alle
  Domande frequenti; le Domande personali restano sui tre luminari.

Test: accenti puliti, niente trattino lungo, niente proposizione dopo la
virgola con "e" nelle stringhe visibili. Screenshot delle tre chat rigenerati.

Nota per te: le cinque categorie sono in testa alle Domande frequenti, non
ancora come schede a sé. Se le vuoi come tab dedicate (amore, lavoro, fortuna,
successo, relazioni) è un piccolo passo di UI in più, dimmelo.

## Task 3, strato di memoria a livelli — FATTO

Il memory layer vive dietro il repository astratto già esistente, che aveva
profilo, fatti durevoli, sintesi di sessione e cronologia completa. Aggiunto
quel che mancava:

- Cancellazione GDPR: nuovo `deleteAllData()` nell'interfaccia e nelle due
  implementazioni. Su Firestore cancella a blocchi la cronologia di ogni
  Maestro, poi i documenti dei Maestri, poi il profilo, tutto e solo sotto
  l'utente corrente. L'isolamento per utente c'era già (users/{uid}), ora
  provato con un test.
- Ganci verso i livelli profondi, predisposti e non attivi
  (`memory_hooks.dart`): `SemanticIndexHook` per pgvector su Cloud SQL e
  `HistoryArchiveHook` per l'archiviazione su Cloud Storage, con
  implementazioni a vuoto di default. Sono cablati in `appendMessage` e in
  `deleteAllData` dei due repository: oggi non fanno nulla, domani basta
  iniettare l'implementazione vera al posto di quella a vuoto, senza toccare
  chat né repository.
- Chat collegata alla memoria: era già così. Il controller carica profilo,
  memoria calda e cronologia all'apertura, persiste ogni messaggio, e ogni tre
  turni distilla e aggiorna fatti e sintesi. I ricordi rilevanti tornano nel
  contesto passato all'AI. La regola anti invenzione è nella persona (Task 2).

Test: `test/memory_repository_test.dart` copre il contratto sul falso in
memoria e sul falso Firestore (`fake_cloud_firestore`, aggiunto alle
dev_dependencies): giro completo di profilo, memoria e cronologia, chiamata
delle prese profonde, cancellazione GDPR, isolamento per utente, ordine di
rilettura. `test/chat_memory_test.dart` prova che la conversazione si persiste
e che i ricordi tornano nel contesto, più l'aggiornamento della memoria dal
distillato.

Blocco onesto: la validazione su Firestore reale resta a te dalla console, qui
non ci sono credenziali né emulatore. Da verificare lì: che le regole di
sicurezza consentano la cancellazione ricorsiva e la neghino fra utenti
diversi.

Dubbio aperto per te: la cancellazione GDPR è pronta come capacità del
repository, ma non c'è ancora una schermata Impostazioni con il bottone
"Cancella i miei dati". Serve decidere dove metterlo; è un piccolo passo di UI.

## Task 4, consegna — FATTO

- `flutter analyze` pulito, nessun problema.
- Tutti i test verdi: 55 test, unità e widget e catture headless.
- Screenshot in `docs/preview/` di ogni schermata nuova o cambiata:
  - nuova: `cielo-sopra-di-te.png` (la schermata del cielo del momento);
  - cambiate da Task 2: `medora/aura/caligo-chat-suggerimenti.png` (le cinque
    categorie declinate) e i relativi stati vuoti, che mostrano i nuovi chip
    d'avvio.

### Cosa ho saltato e perché

Niente è stato saltato del tutto, ma due limiti restano dichiarati, non finti:

- Task 1: nel repo non c'era un motore del cielo di nascita con catalogo J2000
  e coordinate equatoriali reali da riusare. Ho costruito la schermata su ciò
  che è reale (asterismi fedeli, Luna reale, posizione del Sole per sapere cosa
  è alto stanotte) e ho dichiarato in schermo e qui che il posizionamento reale
  in alt-azimut e i pianeti arrivano col motore a effemeridi. Non ho finto un
  motore astronomico completo.
- Task 3: la validazione su Firestore reale resta a te dalla console, qui non
  ci sono credenziali né emulatore. Ho provato la logica sul falso Firestore e
  sul falso in memoria.

Come da paletti: non ho toccato console Firebase, telefono, generazione
immagini su Vertex o credenziali. Non ho pubblicato nulla, non ho aperto PR.

### Dubbi aperti per te

1. Motore del cielo: userà un catalogo J2000 con la posizione GPS dell'utente
   (serve il permesso di localizzazione) o una veduta simbolica indipendente
   dal luogo? Da questo dipende quanto la schermata diventa "vera".
2. Le cinque categorie dei suggerimenti (amore, lavoro, fortuna, successo,
   relazioni) sono in testa alle Domande frequenti. Le vuoi come schede a sé?
3. Cancellazione GDPR: la capacità è pronta nel repository, manca la schermata
   Impostazioni con il bottone "Cancella i miei dati". Dove lo mettiamo?
4. Da validare su Firestore reale: le regole di sicurezza devono permettere la
   cancellazione ricorsiva del proprio dato e negarla fra utenti diversi.

---

# Secondo batch

## Task 1, Il cielo sopra di te immersivo — FATTO

La schermata non è più uno schema ma una volta densa ed esplorabile.

- Campo stellato denso su tre piani (circa 260, 120 e 44 stelle di dimensione e
  luminosità varie) che si muovono a velocità diverse col giroscopio e col
  trascinamento del dito, cosi' nasce la profondità. Riduci Movimento appiattisce
  la parallasse (i piani si muovono insieme) e ferma il giroscopio.
- Tela più ampia dello schermo: scorrendo o inclinando si rivela altro cielo ai
  lati e in alto. La Luna e le costellazioni alte stanotte sono distribuite su
  questa tela.
- Accenno di Via Lattea, una fascia soffusa in diagonale.
- Forme corrette codificate a mano in `lib/core/astro/sky_catalog.dart`: i dodici
  segni piu' alcune brillanti (Orione, Orsa Maggiore, Cassiopea, Cigno). Il
  Sagittario è la teiera, lo Scorpione il gancio, il Leone la falce. Le
  costellazioni sono immerse nel campo, le stelle piu' brillanti piu' grandi,
  unite da linee dorate sottili.
- Corpi toccabili con etichetta e riga di Medora, come prima. La nota sui pianeti
  è ora in-world, piccola ed elegante: "I pianeti si uniranno presto al tuo
  cielo."

Test: `sky_overview_test` e `night_sky_test` restano verdi; il fondo denso è
coperto dalla cattura headless `docs/preview/cielo-sopra-di-te.png`.

Dubbio aperto: le forme sono asterismi corretti in un frame locale, non ancora
posizioni reali in alt-azimut. Il salto a un cielo geolocalizzato richiede il
motore a effemeridi e la posizione dell'utente, come già annotato.

## Task 2, schermata Impostazioni — FATTO

Nuova schermata Impostazioni in stile 2.5D e nella palette del Maestro attivo,
raggiungibile in modo pulito da un ingranaggio nell'angolo del Cosmic Passport.

- Aspetto: "Riduci animazioni" (si riversa su `MediaQuery.disableAnimations`,
  cosi' tutto il codice che rispetta Riduci Movimento lo onora) e "Modalità
  semplice" (abbassa la qualità grafica a bassa).
- Voce e sottotitoli: "Sottotitoli" attivi di default, segnaposto in attesa del
  passo voce, la preferenza si conserva.
- Privacy e dati: "Cancella i miei dati" chiama la cancellazione GDPR già
  costruita, con una conferma chiara e un messaggio di custodia non punitivo
  ("Non è una perdita, è il tuo diritto"), e un riscontro gentile al termine.
- Account: segnaposto "Dietro il velo".

Le preferenze vivono in `SettingsController` (`lib/core/settings/`), persistite
best effort su `shared_preferences`. Test: `test/settings_test.dart` (gli
interruttori aggiornano le preferenze, la cancellazione GDPR chiede conferma e
azzera davvero i dati, la schermata è raggiungibile dal Passport). Screenshot:
`docs/preview/impostazioni.png`.

## Task 3, cartolina condivisibile del cielo — FATTO

Nella schermata Il cielo sopra di te c'è ora un bottone Condividi (in alto a
destra) che genera una card costruita apposta, non uno screenshot.

- La cartolina (`lib/features/santuario/sky_postcard.dart`) è disegnata su un
  canvas verticale ad alta risoluzione (1080x1920) via `PictureRecorder` ed
  esportata in PNG: il cielo di stanotte (Luna nella fase reale piu' le
  costellazioni alte con le forme corrette), la data in italiano, il marchio
  Esoteric Circle, una riga poetica nella voce di Medora (a rotazione per
  giorno) e l'invito discreto "Scopri il tuo cielo".
- Il bottone apre il foglio di condivisione del sistema (`share_plus`) con
  l'immagine (scritta in un file temporaneo via `path_provider`) e un testo
  precompilato con hashtag. Su Instagram l'immagine va nelle Storie, per gli
  altri passa il testo.

Test: `test/sky_postcard_test.dart` (la cartolina genera un PNG valido ad alta
risoluzione, data e testo di condivisione corretti, righe poetiche con accenti
giusti e senza "e" dopo la virgola). Screenshot: `docs/preview/cartolina-cielo.png`.

Blocco onesto: l'apertura reale del foglio di condivisione e il salvataggio in
Storie si vedono solo su device (canali di piattaforma). Qui è coperta la
generazione della cartolina, non l'apertura del foglio.

## Consegna del secondo batch

- `flutter analyze` pulito, 63 test verdi.
- Screenshot nuovi o cambiati in `docs/preview/`: `cielo-sopra-di-te.png`
  (immersivo), `impostazioni.png` (nuova), `cartolina-cielo.png` (nuova).
- Dipendenze aggiunte: `share_plus`, `path_provider` (condivisione),
  `fake_cloud_firestore` (test, dal batch precedente).

### Dubbi aperti per te (secondo batch)

1. Cielo immersivo: le forme sono asterismi corretti in un frame locale, non
   posizioni reali in alt-azimut. Il cielo geolocalizzato richiede il motore a
   effemeridi e la posizione dell'utente.
2. Impostazioni: "Modalità semplice" oggi forza la qualità grafica bassa;
   quando arriverà il rilevamento automatico del device andrà armonizzata.
3. Cartolina: la condivisione va provata su device reale (Instagram Storie,
   altre app). Vuoi anche un formato quadrato per il feed, oltre al verticale?

---

# Terzo batch

## Punto 1, regola di lingua (virgola piu "e") — FATTO

La riga della cartolina "La Luna non ha fretta, e stanotte nemmeno tu" era gia'
stata riscritta nel batch precedente in "La Luna non ha fretta: stanotte
nemmeno tu". Ho poi setacciato tutti i testi visibili e generati (persona dei
Maestri, suggerimenti, testi del cielo, cartolina, copy delle schermate):
nessun'altra proposizione inizia con "e" dopo la virgola nelle stringhe
visibili. Le uniche occorrenze di ", e" restano nei commenti di codice, fuori
dal canone. Nuovo `test/language_rule_test.dart` che segnala la violazione nei
testi statici (persona, suggerimenti, cielo, cartolina).

## Punto 2, dominio pubblico — FATTO

Il dominio corretto è esotericircle.app (non .com). Centralizzato in un solo
punto di configurazione del brand, `lib/core/brand/brand.dart` (`Brand.name`,
`Brand.domain`, `Brand.url`). La cartolina legge da qui il marchio e il
dominio, cosi' non divergono. Screenshot `cartolina-cielo.png` rigenerato col
dominio corretto.

## Punto 3, interruttori spenti per default — FATTO

"Riduci animazioni" e "Modalità semplice" partivano già spenti (i default del
`SettingsController` sono false); i sottotitoli restano attivi di default. Reso
esplicito con un test unitario dedicato.

## Punto 4, cartolina in formato quadrato — FATTO

La cartolina ora ha due formati: verticale 1080x1920 (Storia) e quadrato
1080x1080 (feed). Il layout si adatta con posizioni relative all'altezza e font
in scala. Alla condivisione il bottone apre un foglio che offre la scelta,
"Storia" o "Feed", poi genera e condivide il formato scelto. Test: la cartolina
si genera nei due formati con le dimensioni corrette, il selettore mostra le
due opzioni. Screenshot: `cartolina-cielo.png` (verticale) e
`cartolina-cielo-quadrata.png` (quadrato).

## Punto 5, avvio geolocalizzato del cielo — FATTO

Aprendo "Il cielo sopra di te" dal Santuario, un pre-avviso gentile nella voce
di Medora chiede il permesso di posizione e spiega a cosa serve, prima della
richiesta secca del sistema. Accettando, la longitudine e la latitudine
orientano la volta sul luogo reale (spostamento simbolico del centro della
volta); se il permesso manca o il sensore non c'e', ripiego elegante alla
veduta attuale, senza vicoli ciechi. La precisione piena in alt-azimut resta al
motore a effemeridi, dichiarata sia nel pre-avviso sia nella scheda in-world. La
posizione e' dietro l'astrazione `SkyLocation` (`lib/core/astro/sky_location.dart`):
`GeolocatorSkyLocation` reale, `DisabledSkyLocation` di default per test e
anteprime. Permessi aggiunti a Info.plist (iOS) e AndroidManifest. Test: col
luogo disponibile compare il pre-avviso e l'accettazione orienta e lo dichiara;
col permesso negato ripiega con un messaggio; col momento fissato (cielo di
nascita, test) non chiede mai nulla. Screenshot: `cielo-avvio-posizione.png`
(pre-avviso) e `cielo-sopra-di-te.png` (veduta pulita).

## Punto 6, cielo di nascita immersivo — FATTO

Il cielo di nascita riusa lo stesso motore immersivo del cielo di adesso (tre
piani di stelle dense con parallasse giroscopio piu' dito, tela piu' ampia dello
schermo ed esplorabile, accenno di Via Lattea, forme reali degli asterismi,
corpi toccabili con etichetta e riga). La differenza: e' ancorato al momento di
nascita e fisso (identita'), quindi la Luna e le costellazioni sono quelle della
notte di nascita, non di adesso; e non chiede mai la posizione. Realizzato con un
flag `birth` su `SkyOverviewScreen` e una `birthRoute(birthMoment:)`: cambia
titolo ("Il tuo cielo di nascita"), voce di Medora sull'identita' e testo della
cartolina. E' connesso dove gia' vive, il portale "Il tuo cielo di nascita" nel
Cosmic Passport, ora attivo (le altre voci restano dietro il velo). Finche'
l'onboarding non raccoglie nascita e luogo reali, usa un momento d'esempio,
dichiarato in-world nella scheda. Test: la volta di nascita e' fissa, parla di
identita' e non chiede il luogo; il portale del passaporto la apre. Screenshot:
`cielo-di-nascita.png` e `passport.png` (portale attivo).

## Note e dubbi del terzo batch

- Orientamento sul luogo (Punto 5): la longitudine e la latitudine danno uno
  spostamento simbolico della volta, non la proiezione alt-azimut reale, che
  resta al motore a effemeridi (dichiarato in-world). Quando arrivera' il motore,
  qui si innesta il calcolo esatto.
- Momento di nascita d'esempio (Punto 6): segnaposto in attesa di BirthIdentity
  dalle effemeridi. Il collegamento e' pronto: bastera' passare il momento reale
  a `birthRoute`.

# Quarto batch

## Punto 1, correzioni al cielo — FATTO

a) La nota in basso del cielo di nascita non e' piu' troncata: tolti il tetto di
due righe e i puntini, ora va a capo per intero. b) Nel pre-avviso della
posizione (e nelle note in-world del cielo) e' sparito il gergo "alt-azimut":
al suo posto "la posizione esatta di ogni astro nel cielo arriva col motore a
effemeridi", in italiano semplice, mantenendo l'onesta' che la precisione piena
arriva con le effemeridi. Test aggiornato alla nuova dicitura. Screenshot:
`cielo-di-nascita.png` e `cielo-avvio-posizione.png`.

## Punto 2, due fatti deterministici del Passport attivi — FATTO

Attivate le due tessere che nascono dalla sola data di nascita, oggi con valore
reale calcolato. Numero della vita: numerologia pitagorica deterministica
(`lib/core/identity/numerology.dart`), riduzione della data conservando i numeri
maestri 11, 22, 33, con titolo, riga di significato ed emblema a sigillo dorato.
Fase lunare di nascita: fase e segno lunare del giorno di nascita
(`lib/core/identity/birth_moon.dart`), riusando il renderer della Luna gia'
esistente e la longitudine lunare reale (nuovo `NightSky.moonEclipticLongitude`
e `moonSign`), con riga di significato. Tutto dietro il modello `BirthIdentity`:
finche' l'onboarding non fornisce la data vera usano `BirthIdentity.example`,
dichiarato in-world ("Valore d'esempio: si compone con la tua data"), e si
popolano da soli passando un'identita' reale. Le voci che richiedono servizi o
asset esterni (carta natale, Angelo, Archetipo, Animale guida) restano dietro il
velo. Test: numerologia deterministica e numeri maestri, fase lunare coerente
col motore, longitudine nel giro, il passaporto mostra i valori e nasconde la
nota d'esempio con identita' reale. Screenshot: `passport.png`.

## Punto 3, Chiedi ai Maestri con sintesi comparativa — FATTO

Nuova schermata "Chiedi ai Maestri" (`lib/features/maestri/ask/`), raggiungibile
da una via discreta nel Santuario. Si scrive una domanda e si sceglie di
interpellare un Maestro, due o tutti e tre (chip nella palette di ciascuno,
almeno uno resta sempre scelto). Ciascun Maestro risponde dalla sua lente di
dominio, secondo il canone Personas, nell'anatomia a quattro strati (colpo
d'occhio, testo, invito; il livello visivo lo dà la UI). Quando i Maestri sono
piu' di uno, in testa compare una sintesi comparativa che mostra le lenti sullo
stesso tema. Le risposte usano l'oracolo locale in ripiego
(`lib/services/ai/maestro_oracle.dart`), deterministico e senza rete: la chiamata
vera a Gemini su Vertex resta al device, dietro `MaestroAiProvider`. Stati
coperti: vuoto, una lente senza sintesi, tre lenti con sintesi, e il vincolo che
l'ultimo Maestro non si puo' togliere. Test: `maestro_oracle_test.dart` (lenti,
ordine fisso, sintesi, determinismo) e `ask_maestri_test.dart` (i quattro stati).
Screenshot: `chiedi-ai-maestri.png` (vista comparativa) e i Santuario con la
nuova via.

## Punto 4, Meditazione di Aura con suono e cimatica — FATTO

Nuova schermata di meditazione nel dominio di Aura (`lib/features/maestri/aura/
meditation/`), raggiungibile da una tessera attiva nel dominio. Tre strati che
nascono l'uno dall'altro. Suono generato a runtime, senza file esterni: un
`ToneGenerator` sintetizza campioni PCM16 stereo (e li avvolge in un WAV in
memoria) per i preset a 432 Hz, 528 Hz e un battito binaurale theta, dove il
battito nasce dalla differenza fra i due canali, con invito a mettere le cuffie.
Visualizzatore a cimatica: un mandala di geometria sacra (due rose sovrapposte a
simmetria radiale, la cui ricchezza cresce con la frequenza del preset) che
pulsa col respiro, con nodi luminosi sulle punte e un cuore che respira. Guida
al respiro: cerchio che si apre inspirando e si chiude espirando, con l'etichetta
della fase. Fondamento onesto: "Cornice di benessere, non cura. Le frequenze
Solfeggio e il 432 sono tradizione culturale, non un fatto medico", senza
ripetere il disclaimer. La riproduzione vera sul canale audio del sistema resta
al device, dietro `TonePlayer`: in headless si usa il lettore silenzioso, che
genera comunque i toni. Test: `meditation_test.dart` (sintesi PCM, frequenza per
attraversamenti dello zero, WAV valido, battito binaurale, stati della schermata,
tessera solo nel dominio di Aura). Screenshot: `meditazione-aura.png`.

## Note e dubbi del quarto batch

- Suono della meditazione (Punto 4): la sintesi dei toni e' reale e verificata,
  ma la riproduzione sul canale audio del sistema richiede il plugin nativo sul
  device (come la chiamata a Vertex). Oggi il lettore di default e' silenzioso e
  genera i byte senza emetterli: la prova dell'audio resta al device.
- Chiedi ai Maestri (Punto 3): le risposte sono dell'oracolo locale a scheletro,
  deterministico. Sono coerenti col dominio ma non personalizzate sul profilo
  dell'utente: la lettura vera, con memoria e Gemini su Vertex, resta al device.
- Cimatica (Punto 4): il mandala e' un'evocazione fedele nello spirito delle
  figure di Chladni, non una simulazione fisica delle onde stazionarie. Se vuoi
  la simulazione vera dei nodi di Chladni per una data frequenza, e' un passo in
  piu' che posso fare.

# Quinto blocco (sessione lunga)

## Task 1, correzioni di lingua e testo — FATTO

a) Nella UI la parola "lenti" e' diventata "sguardi" (sintesi comparativa, intro
e stato vuoto di Chiedi ai Maestri); "lenti" resta solo come concetto interno
(la classe `MaestroLens`, i commenti). b) Il sottotitolo di Chiedi ai Maestri e'
ora "Una domanda sola, gli sguardi dei Maestri a confronto", senza la "e" dopo
la virgola. c) Il controllo automatico di lingua e' rinforzato: segnala la
sequenza virgola piu' "e"/"ed" anche a meta' frase, con un test dedicato, e un
setaccio profondo che scandaglia tutte le stringhe del codice sotto lib/
(unendo le stringhe adiacenti spezzate a capo), cosi' nessun copy sfugge. Nessuna
violazione trovata dopo la sistemazione. d) Nella meditazione il chip "Battito
theta" non e' piu' troncato: etichetta e sottotitolo vanno a capo per intero.
Screenshot: `meditazione-aura.png`, `chiedi-ai-maestri.png`.

## Task 2, tier ed entitlement piu schermata prezzi — FATTO

Esteso l'entitlement gia' presente (Tier free, tier1, tier2, tier3). Nuovo
contatore locale delle domande ai Maestri per il Free
(`lib/core/entitlement/question_allowance.dart`): una domanda singola al giorno,
azzeramento al cambio di giorno, orologio iniettabile per i test e persistenza
best effort; il Tier a pagamento non consuma il contatore e il confronto a piu'
Maestri e' riservato al pagamento (`canCompare`). Nuovo catalogo dei piani
(`plan_catalog.dart`) con nome, richiamo e benefici per i quattro livelli
(Gratuito, Cerchio, Cerchio d'Oro, Cerchio Astrale). Schermata prezzi in 2.5D
(`features/pricing/pricing_screen.dart`) con i piani, i benefici, il piano
attuale e il consigliato in evidenza; il pagamento non e' integrato nella Demo,
dichiarato in-world, con un'attivazione di prova in Demo. Invito gentile
all'upgrade riusabile (`upgrade_invite.dart`), mai un vicolo cieco, con la via ai
piani. Entrata dalle Impostazioni ("Il tuo piano"). Test: contatore giornaliero
e rollover, piani, schermata prezzi e attivazione in Demo, invito che porta ai
piani. Screenshot: `piani.png`.

## Task 3, Chiedi ai Maestri ridisegnato — FATTO

Tolta la bolla "Chiedi ai Maestri" dal Santuario: non si sovrappone piu' ai
busti. Il chiedere ora parte dentro il dominio di un Maestro, da una tessera
"Chiedi a {Maestro}". Si pone una domanda, il Maestro risponde dal suo sguardo,
e sotto la risposta compare l'invito "Chiedi anche a un altro Maestro", che porta
lo stesso tema allo sguardo di un secondo o terzo Maestro e mostra in cima la
sintesi comparativa. Regole di accesso legate all'entitlement del Task 2: il Free
ha una sola domanda singola al giorno; il confronto a piu' Maestri e le domande
oltre la prima sono del Tier a pagamento, con l'invito gentile all'upgrade quando
il limite e' raggiunto, mai un vicolo cieco. Le risposte usano l'oracolo locale
in ripiego; la chiamata vera a Vertex resta al device. Test aggiornati: partenza
dal dominio con una risposta e l'invito, il Free bloccato sul confronto e sulla
seconda domanda con l'upgrade, il Tier a pagamento che aggiunge lo sguardo e la
sintesi. Screenshot: `chiedi-ai-maestri.png` (nuova vista) e i Santuario senza la
bolla.

## Task 4, i quattro rituali quotidiani — FATTO

Costruiti i quattro rituali del giorno con contenuti deterministici reali dalla
data (`lib/core/rituals/`), livello visivo prima del testo e ogni sensore con
ripiego tattile universale (impalcatura condivisa `RitualView`). Ognuno nel suo
dominio, con la sua schermata e il suo screenshot.
- Rito dell'Alba: a rotazione tra i tre Maestri di giorno in giorno, messaggio
  del mattino nella voce del Maestro di turno; appare nel dominio di chi tocca
  oggi. Gesto tattile. Screenshot `rito-alba.png`.
- Soffio del Destino (Aura): microfono per il soffio sul device, con ripiego a
  gesto tattile (tenere premuto) sempre valido. Screenshot `soffio-destino.png`.
- Oracolo del Giorno (Medora): rivelazione al giroscopio sul device, con ripiego
  allo scorrimento del dito. Screenshot `oracolo-giorno.png`.
- La Runa del Tramonto (Caligo): estrazione di una runa dell'Elder Futhark
  (ventiquattro segni con significato reale), deterministica dal giorno. Il glifo
  runico e' disegnato a tratti via codice (`rune_strokes.dart`), non un carattere
  di font: cosi' e' sempre leggibile, senza dipendere dal blocco runico Unicode
  ne' da un asset. Screenshot `runa-tramonto.png`.
Dove serve, l'arte definitiva di brand e' dichiarata segnaposto (in arrivo dal
bucket), il resto e' reale. Test: contenuti deterministici, rotazione dell'alba,
Futhark completo, e per ogni schermata il livello visivo prima del testo con il
ripiego tattile che rivela il responso.

## Task 5, consegna del blocco 5 — FATTO

- `flutter analyze` pulito, nessun problema.
- Tutti i test verdi: 128 test, unita', widget e catture headless.
- Screenshot in `docs/preview/` di ogni schermata nuova o cambiata: `piani.png`
  (i piani del Cerchio), `chiedi-ai-maestri.png` (il nuovo flusso dal dominio),
  `rito-alba.png`, `soffio-destino.png`, `oracolo-giorno.png`, `runa-tramonto.png`
  (i quattro rituali), `meditazione-aura.png` (chip corretto), i Santuario senza
  la bolla, e le Impostazioni con "Il tuo piano".

### Cosa ho fatto, task per task
- Task 1: "lenti" e' diventato "sguardi" nella UI, sottotitolo di Chiedi ai
  Maestri senza la "e" dopo la virgola, controllo di lingua rinforzato (segnala
  la virgola piu' "e" a meta' frase e scandaglia tutte le stringhe del codice),
  chip Battito theta non piu' troncato.
- Task 2: contatore locale delle domande del Free (una al giorno), catalogo dei
  piani e schermata prezzi 2.5D, invito all'upgrade riusabile. Pagamento non
  attivo nella Demo, dichiarato.
- Task 3: Chiedi ai Maestri ridisegnato, parte dal dominio del Maestro con
  l'invito a portare la domanda a un altro e la sintesi comparativa; regole di
  accesso per tier.
- Task 4: i quattro rituali del giorno, contenuti deterministici reali, livello
  visivo prima del testo, sensori con ripiego tattile universale.

### Cosa ho saltato e i dubbi per te
- Niente e' stato saltato del tutto. Restano scelte tue e limiti dichiarati:
- Prezzi dei piani (Task 2): ho messo nomi e benefici, non i prezzi, che sono una
  decisione di business. Servono importi e nomi definitivi dei tier, poi
  l'acquisto reale col modello reader dal web. L'attivazione "in Demo" e' solo
  per provare i tier sul simulatore, chiaramente etichettata, non un pagamento.
- Limite giornaliero (Task 2 e 3): il contatore e' locale al dispositivo. Un
  limite vero, non aggirabile cambiando device, richiede l'enforcement lato
  server: e' il passo con il backend.
- Risposte dei Maestri (Task 3): sono dell'oracolo locale a scheletro,
  deterministico e coerente col dominio, ma non personalizzato sul profilo. La
  lettura vera, con memoria e Gemini su Vertex, resta al device.
- Sensori dei rituali (Task 4): microfono e giroscopio sono provati qui solo dal
  ripiego tattile, che vale sempre. Il comportamento reale del sensore si prova
  sul device.
- Arte dei rituali (Task 4): i glifi runici sono disegnati a tratti, fedeli ma
  tracciati a mano. L'arte incisa di brand e gli sfondi definitivi arrivano dal
  bucket: dove serve, e' dichiarato segnaposto.
- Rito dell'Alba (Task 4): appare nel dominio del Maestro di turno oggi, non in
  un hub dedicato dei rituali. Se lo vuoi come hub unico, e' un piccolo passo.

# Sesto blocco

## 1. Schermata prezzi ai quattro livelli canonici — FATTO

Ricostruita la schermata prezzi coi quattro livelli ufficiali (Viandante,
L'Iniziato, L'Adepto, L'Illuminato), ciascuno con identita', i tre cicli di
prezzo (settimana, mese, anno con equivalenza mensile e sconto) e i vantaggi in
evidenza. Nella card de L'Iniziato la Memoria AI dei Maestri e' il primo
vantaggio, come leva di conversione. In cima, dietro il flag `AppFlags.isDemo`,
una card "Demo" col badge "Piano Attuale" che sblocca tutto per la
presentazione; il badge e' tolto dal Viandante e messo sulla Demo, e nell'MVP la
card Demo sparisce da sola restando i quattro livelli. Tabella comparativa
completa con tutte le righe e i valori richiesti, scorribile in orizzontale,
senza troncare nulla. Testo persistente in basso: "Nella demo i piani sono
visibili ma il pagamento non è integrato." Il contatore delle domande e' ora per
tier (1, 5, 10, illimitate). Test: livelli, prezzi, mappa comparativa, contatore
per tier, schermata con Demo e senza. Screenshot: `piani.png`.

## 2. Instradamento della chat verso le funzioni immersive — FATTO

Quando in chat l'utente chiede un'esperienza che ha gia' una funzione immersiva
dedicata, il Maestro non genera una lettura a testo con l'AI: riconosce l'intento
e invita ad aprire la funzione. Un classificatore leggero e deterministico
(`lib/core/chat/intent_classifier.dart`), solo parole chiave e sinonimi, nessuna
chiamata AI, intercetta la richiesta; l'allow-list per Maestro vive in un file di
configurazione dedicato (`immersive_intents.dart`), estendibile senza toccare la
logica. Medora: stesa di carte, carta natale, sinastria vip, oroscopo del giorno.
Aura: meditazione, breathwork, costellazione del viso, scan dei chakra, frequenze.
Caligo: rune, sigillo, I-Ching, pendolo, rituale con candela. Il Maestro risponde
in carattere con una frase breve e un pulsante che apre la funzione (deep link
interno): dove la schermata esiste gia' (Oracolo del Giorno, Meditazione, Runa)
si apre, dove e' ancora dietro il velo un invito elegante "arriva presto", mai un
vicolo cieco. Questo scambio non chiama l'AI e non consuma la domanda del giorno;
le domande vere del dominio restano risposte normali in chat. Test:
`intent_routing_test.dart` (classificazione per Maestro, allow-list, parola
intera, instradamento senza AI, domanda normale che chiama l'AI). Screenshot:
`chat-instradamento.png`.

## 3. Card Rito dell'Alba, Maestro di turno visibile — FATTO

La tessera del Rito dell'Alba ora mostra a colpo d'occhio chi guida oggi: il suo
avatar, il suo nome ("Oggi la guida è di ...") e il suo colore di tema. La
rotazione resta deterministica sul giorno dell'anno. Test: nel dominio del
Maestro di turno la card compare e lo nomina, negli altri no. Screenshot:
`card-rito-alba.png`.
