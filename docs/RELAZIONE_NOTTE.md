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
