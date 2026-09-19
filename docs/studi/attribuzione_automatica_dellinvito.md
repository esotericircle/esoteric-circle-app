# L'attribuzione automatica dell'invito: la strada per Android e per iOS

Ordine CE voce 17. **Questo documento non costruisce niente**: e' lo studio che
il fondatore ha chiesto per decidere, e il codice si scrivera' quando lo
ordinera'.

## Da dove nasce

Parole del fondatore, verbatim, sul popup che ha incontrato usando l'app senza
registrarsi:

> "Se un utente accetta di scaricare l'app, dopo la mia condivisione, il
> tracciamento e premio deve essere automatico! cosa serve?"

E la sua decisione, dopo che gli e' stato riportato che su Android il dato
dell'installazione arriva dal Play Store mentre oggi l'app arriva da App
Distribution e da TestFlight:

> "C chiedi a Code la soluzione più automatica e discreta per Google e Apple."

L'ordine CE voce 02 ha tolto il popup dal Santuario, e il fondatore ha
accettato che **per ora nessuno riscuota i 60 Eos**, con la condizione che
questo vada sistemato **prima della pubblicazione**.

## I TRE FATTI, verificati sul ramo

**1. L'app oggi non gestisce nessun collegamento in arrivo.** Verificato:

- `android/app/src/main/AndroidManifest.xml` ha un solo `intent-filter`, quello
  di `MAIN` e `LAUNCHER`. Nessun `VIEW`, nessun `BROWSABLE`, nessun `autoVerify`.
- `ios/Runner/Info.plist` ha un solo `CFBundleURLTypes`, ed e' lo schema di
  ritorno dell'accesso Google (il `REVERSED_CLIENT_ID`): non e' un collegamento
  all'app, e' il rientro dell'autenticazione. Nessun `Associated Domains`.
- Nel `pubspec.yaml` non c'e' `app_links`, non c'e' `uni_links`, non c'e'
  `install_referrer`.

**2. `riscattaLInvito` esiste, e' distribuita e paga.** Verificato: vive in
`functions/src/cerchio.ts` come `onCall`, con le tre difese gia' misurate
dall'ordine CC voce 08 (il codice non e' l'uid di chi lo usa, il pagamento sta
in una transazione, il movimento porta un identificativo fisso e non si paga due
volte). **La porta a mano resta nel menu' Account**, e chi ha un codice puo'
ancora riscuoterlo.

**3. Firebase Dynamic Links e' stato spento da Google.** Verificato alla fonte,
`firebase.google.com/support/dynamic-links-faq`: **spento il 25 agosto 2025**,
tutti i link, sia sui domini propri sia sui sottodomini `page.link`, hanno
smesso di funzionare. Google indirizza a due strade: i fornitori terzi di
attribuzione (Adjust, AppsFlyer, Branch, Kochava, Singular) per la parita' di
funzioni, oppure **App Links su Android e Universal Links su iOS** per il solo
collegamento dopo l'installazione.

**Quindi la strada che il progetto avrebbe usato tre anni fa non esiste piu'.**

## ANDROID: la strada praticabile

### Cosa serve

Il dato dell'attribuzione su Android arriva dal **Play Install Referrer API**:
quando qualcuno tocca un link del Play Store che porta un parametro
`&referrer=`, il Play Store conserva quella stringa e la consegna all'app alla
prima apertura. E' il meccanismo nativo, non chiede permessi alla persona, e non
mostra niente: **e' la cosa piu' automatica e piu' discreta che esista su
Android**, che e' esattamente cio' che il fondatore ha chiesto.

- **Pacchetti**: sul lato Flutter serve un ponte al `com.android.installreferrer`
  di Google. Esiste `android_play_install_referrer` su pub.dev; in alternativa un
  `MethodChannel` scritto a mano, che e' una quarantina di righe di Kotlin
  contro una dipendenza in piu'.
- **Codice nativo**: poco. La libreria di Google si collega con
  `InstallReferrerClient`, risponde una volta e si chiude. Il ponte a mano e'
  un `MethodChannel` e un `BroadcastReceiver` che non serve nemmeno.
- **Server**: nessuna funzione nuova. La stringa del referrer contiene il codice
  dell'invito, e si passa alla `riscattaLInvito` che esiste gia'. **Il premio,
  le difese e l'idempotenza restano dove sono.**
- **Chi condivide**: il link di condivisione cambia forma. Oggi si condivide un
  codice; domani si condividerebbe
  `https://play.google.com/store/apps/details?id=<pacchetto>&referrer=<codice>`.

### Cosa si puo' provare senza una build vera, e cosa no

- **Si puo' provare**: che il ponte legga una stringa e la passi alla porta,
  con una finta al posto del client di Google; che un referrer malformato non
  paghi; che il codice arrivi al server nella forma giusta. Sono prove di
  unita' e valgono.
- **NON si puo' provare**: che il Play Store consegni davvero quella stringa.
  **Il referrer lo mette il Play Store, e solo il Play Store**: un'app
  installata da App Distribution, da un file `.apk` o da Android Studio riceve
  una stringa vuota. Questo e' il punto che blocca oggi.

### Cosa richiede la pubblicazione

**Serve almeno una traccia interna del Play Store.** Basta la traccia di test
interno, che non chiede la revisione completa e si apre a una lista di indirizzi:
da li' il referrer funziona come in produzione. **Non serve pubblicare
l'app al mondo**, e questa e' la notizia buona: la prova si puo' fare mesi
prima della pubblicazione vera.

### Quali dati escono dal telefono, e verso chi

La stringa del referrer va da Google Play all'app, e dall'app al server del
Cerchio. **Contiene il codice dell'invito e nient'altro**, se il link si
costruisce cosi'. Non c'e' nessun identificativo pubblicitario, nessun
fornitore terzo, nessun profilo: e' un dato che il Cerchio genera e che torna al
Cerchio. **Per il fondatore e' la strada piu' discreta possibile**, e va detto
nell'informativa che il codice dell'invito viaggia col link.

### Il costo, in ore

| lavoro | ore |
| --- | --- |
| il ponte al Play Install Referrer, con le sue prove | 4 |
| il link di condivisione che porta il referrer | 2 |
| il giro dal referrer alla `riscattaLInvito` gia' esistente | 3 |
| la prova vera su una traccia interna del Play Store | 3 |
| **totale Android** | **12** |

## iOS: la strada praticabile, e perche' e' piu' stretta

### Il fatto che decide tutto

**Su iOS non esiste nessun equivalente del Play Install Referrer.** Apple non
consegna all'app il parametro del link da cui l'installazione e' partita. E'
una scelta di piattaforma, e nessun pacchetto la aggira: i fornitori terzi di
attribuzione la aggirano con l'impronta del dispositivo, che e' esattamente cio'
che il fondatore chiama indiscreto e che Apple stessa vieta nelle sue regole.

Restano due strade oneste.

### Strada A: Universal Links, che copre chi ha gia' l'app

Un `Universal Link` porta dentro l'app chi la ha gia' installata. **Non risolve
il caso dell'invito**, che e' per definizione chi l'app non ce l'ha, ma e' il
mattone su cui la strada B si appoggia.

- **Cosa serve**: la capacita' `Associated Domains` nel progetto Xcode, il file
  `apple-app-site-association` servito dal dominio del Cerchio su HTTPS senza
  redirezioni, e il pacchetto `app_links` sul lato Flutter.
- **Codice nativo**: pochissimo, e' quasi tutta configurazione.
- **Si prova senza una build vera?** No. Gli Universal Links chiedono
  l'associazione firmata fra app e dominio: si provano su un dispositivo con una
  build vera, e TestFlight basta.

### Strada B: il ponte della pagina web, che copre chi l'app non ce l'ha

E' la strada che i fornitori terzi vendono, ridotta all'osso e senza fornitori
terzi.

1. Chi condivide manda un link a una pagina del dominio del Cerchio, con il
   codice dell'invito dentro: `https://<dominio>/invito/<codice>`.
2. Quella pagina, se l'app c'e', si apre dentro l'app grazie all'Universal Link
   della strada A, e il codice arriva subito.
3. Se l'app non c'e', la pagina manda all'App Store **e conserva il codice**.
   Qui sta il punto delicato: conservarlo lato server legandolo a qualcosa che
   sopravviva all'installazione. Le vie oneste sono due, e nessuna e' perfetta:
   - **La via del pannello**: dopo l'installazione, alla prima apertura, l'app
     mostra il codice gia' scritto nel campo e chiede solo di confermare. Non e'
     automatico al cento per cento, ma e' **un tocco invece di una digitazione**,
     e non porta via nessun dato.
   - **La via degli appunti**: la pagina copia il codice negli appunti e l'app
     lo legge alla prima apertura. **Su iOS questo mostra un avviso di sistema**
     ("l'app ha incollato dagli appunti"), quindi non e' discreto e va scartato.

**La via onesta su iOS e' la prima**, e va detto al fondatore che su iOS
"automatico al cento per cento" non e' ottenibile senza un fornitore terzo che
prende l'impronta del dispositivo.

### Cosa richiede la pubblicazione

Il file `apple-app-site-association` chiede il dominio **e l'App ID di
produzione**, che si ottiene aprendo la scheda dell'app su App Store Connect.
Non serve pubblicare, serve la scheda.

### Il costo, in ore

| lavoro | ore |
| --- | --- |
| Associated Domains, il file sul dominio, la verifica | 4 |
| la pagina ponte con il codice | 4 |
| il giro dall'Universal Link alla `riscattaLInvito` | 3 |
| il campo precompilato alla prima apertura | 3 |
| la prova su TestFlight con un dispositivo vero | 4 |
| **totale iOS** | **18** |

## Cosa consiglio, e perche'

**Le due piattaforme non si equivalgono, e fingere che si equivalgano
costerebbe caro.** Su Android l'attribuzione automatica e' un fatto della
piattaforma e costa dodici ore. Su iOS l'automatismo pieno non esiste senza
prendere l'impronta del dispositivo, che e' contro la discrezione che il
fondatore chiede e contro le regole di Apple.

Quindi: **Android automatico, iOS a un tocco**, e la stessa `riscattaLInvito`
sotto tutte e due. Trenta ore in tutto, e nessun fornitore terzo dentro l'app.

## IL DEBITO, dichiarato

**Fino a quando questo non e' fatto, nessuno riscuote i 60 Eos dell'invito
automaticamente.** La porta a mano nel menu' Account resta l'unica via, e il
fondatore lo ha accettato per la fase di demo con la condizione che si sistemi
**prima della pubblicazione**.

Il debito e' scritto anche in `docs/ordini/RIPRESA.md` e nel manifesto
dell'ordine CE, cosi' non lo tiene in vita soltanto una conversazione.
