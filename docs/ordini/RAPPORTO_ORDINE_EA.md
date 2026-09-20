# RAPPORTO DELL'ORDINE EA, LE CORREZIONI DOPO LA 2272

19 e 20 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`,
partenza dal commit `007b360f` (build 2272). Il manifesto, con lo stato voce
per voce, sta in `docs/ordini/ORDINE_EA_MANIFESTO.md`.

## 1. COME STANNO LE VENTIDUE VOCI

Ventuno chiuse, una fermata. Le voci 20, 21 e 22 sono arrivate dal fondatore
mentre l'ordine era in corso.

| voce | cosa | stato |
|---|---|---|
| EA.01 | niente riga divisoria in cima al menu' della chat | chiusa |
| EA.02 | il tutorial solo sulla home | chiusa |
| EA.03 | la Ronda dei motori legge i rossi accettati | chiusa |
| EA.04 | due decisioni registrate nei documenti | chiusa |
| EA.05 | Runa del Tramonto ed Estrazione Rune senza astrologia | chiusa |
| EA.06 | la chat si apre sempre nuova e vuota | chiusa |
| EA.07 | si cancella una conversazione dal menu' | chiusa |
| EA.08 | il menu' della chat compatto | chiusa |
| EA.09 | i due contatori piu' vicini | chiusa |
| EA.10 | il login con Google dal menu' utente | chiusa |
| EA.11 | il selettore di Google si apre una volta sola | chiusa |
| EA.12 | il conteggio sempre attivo e anonimo | chiusa |
| EA.13 | i dati dopo il login | chiusa |
| EA.14 | registrazione e accesso su iPhone | **ferma in attesa delle mani del fondatore**, vedi sotto |
| EA.15 | il cancello di Codemagic aspetta il limite di GitHub | chiusa |
| EA.16 | la bolla della Carta di nascita | chiusa |
| EA.17 | il menu' utente viola su cosmo | chiusa |
| EA.18 | i tre testi legali in una pagina sola | chiusa |
| EA.19 | il link d'ingresso senza parola, e App Check | chiusa |
| EA.20 | il Soffio col microfono | chiusa |
| EA.21 | l'invito degli Eos sotto la barra | chiusa |
| EA.22 | la pietra di Ingwaz portava il segno di Othala | chiusa |

## 2. I DIFETTI, E CHI LI HA FATTI NASCERE

Regola C: ogni difetto ha un padre, e quando non si risale si scrive
**PROVENIENZA IGNOTA** per esteso.

| difetto | padre |
|---|---|
| la chat si apriva sulla conversazione di prima | DZ voce 01, che aveva chiuso il caso dei soli approfondimenti |
| il menu' della chat cominciava con una riga divisoria | EA.01 stessa, nata dalla DZ che ha aggiunto le conversazioni |
| il tutorial compariva sopra il foglio della registrazione | DY voce 01 |
| le callable del server erano undici e la guardia ne pretendeva undici | EA.07, che ne ha aggiunta una dodicesima |
| le catture della chat mostravano una chat vuota | EA.06 |
| una misura tipografica scritta a mano | EA.08 |
| la prova delle anteprime cadeva sulla soglia dell'arte | EA.05, che ha riscritto quella rotta |
| il Soffio col microfono non si apriva piu' | DD voce 01, che ha sostituito la soglia di volume con la planarita' spettrale tarata su un campione solo |
| l'invito degli Eos finiva sotto la barra | BG voce 05, che ha aggiunto la riga del riscatto a un foglio che non poteva crescere |
| il selettore di Google si apriva due volte | AX voce 01, che aveva scelto di rifare la strada per non riusare un gettone speso |
| la memoria restava sull'anonimo dell'avvio | **PROVENIENZA IGNOTA**: l'uid e' nato fisso col repository e nessun ordine risulta averlo reso tale |
| la pietra di Ingwaz portava Othala | **PROVENIENZA IGNOTA**: l'arte e' nata sbagliata dal modello generativo, e nessuna guardia guardava i segni |
| la privacy policy diceva "dalle Impostazioni" | CF voce 16, che ha spostato l'interruttore nel menu' utente senza toccare la policy |
| la privacy policy prometteva 24 mesi che nessuno manteneva | CC voce 09, che ha scritto la frase senza la scadenza |

## 3. I PASSI DI MAURO, FUORI DAL CODICE

Tutto quello che segue si fa una volta sola, e senza fretta: il codice e' gia'
pronto e aspetta.

### 3.1 Pubblicare le funzioni del server

Nel terminale, dalla cartella del progetto:

```bash
firebase deploy --only functions
```

Serve perche' quattro funzioni nuove vivono solo nel ramo e non sul server:
`cancellaLaConversazione` (EA.07), e le modifiche a `segnaLEvento` e alle
scadenze (EA.12). Finche' non si pubblica, cancellare una conversazione la
toglie solo dal telefono.

### 3.2 Pubblicare la pagina legale sul web

Serve l'indirizzo pubblico che Apple e Google chiedono nelle schede dell'app.
La pagina e' gia' scritta in `hosting/index.html`, e nasce dagli stessi testi
dell'app.

```bash
firebase deploy --only hosting
```

Finita la pubblicazione, il terminale stampa l'indirizzo, che sara' del tipo
`https://esoteric-circle.web.app`. Da li' la privacy policy si raggiunge
direttamente a `/privacy`, le condizioni a `/condizioni` e il disclaimer a
`/disclaimer`.

**Se vuoi il tuo dominio** `esotericircle.app` al posto di quello di
Firebase: nella console di Firebase, sezione **Hosting**, pulsante **Aggiungi
dominio personalizzato**, si scrive `esotericircle.app` e la console mostra
due righe da copiare nel pannello dove hai comprato il dominio (sono due
record di tipo A). Dopo qualche ora il certificato si attiva da solo. **Questo
passo serve anche al link d'ingresso** del punto 3.4: il link torna su
`https://esotericircle.app/entra`, e quell'indirizzo deve esistere.

### 3.3 Accendere il link d'ingresso senza parola

Nella console di Firebase, progetto **esoteric-circle**:

1. menu' a sinistra, **Build** > **Authentication**, scheda **Sign-in
   method**;
2. nella riga **Email/Password**, che e' gia' attiva, si apre la matita a
   destra;
3. dentro c'e' un secondo interruttore, **Email link (passwordless
   sign-in)**: si accende e si salva. Il primo interruttore si lascia acceso:
   serve a chi ha gia' una parola.
4. stessa schermata, scheda **Settings** > **Authorized domains**: deve
   esserci `esotericircle.app`. Se non c'e', **Add domain** e lo si scrive.
   Senza questo passo Firebase rifiuta di mandare il link.

### 3.4 Far riconoscere il link ai due telefoni

Android e iPhone aprono l'app al posto del browser solo se il dominio dice di
conoscerli. Firebase Hosting pubblica i due file necessari da solo **dopo**
che le app sono registrate:

1. console di Firebase, **Impostazioni progetto** (la rotella in alto a
   sinistra) > scheda **Generali**, in fondo ci sono le tue app;
2. per l'app **Android**, campo **Impronte digitali del certificato SHA**:
   deve esserci l'impronta SHA-256 della chiave con cui firmi. Se non c'e', si
   prende cosi', dalla cartella del progetto:

   ```bash
   keytool -list -v -keystore android/app/esoteric-circle-upload.jks -alias upload
   ```

   Chiede la parola del keystore, poi stampa varie righe: serve quella che
   comincia con `SHA256:`. Si copia e si incolla nella console con **Aggiungi
   impronta digitale**.
3. per l'app **iPhone**, campi **ID team** e **ID bundle**: l'ID bundle e'
   `com.esotericircle.esotericCircle`, l'ID team e' il codice di dieci
   caratteri che si legge in alto a destra su developer.apple.com.
4. fatto questo, si rifa' `firebase deploy --only hosting`: la pubblicazione
   porta con se' i due file che i telefoni leggono
   (`assetlinks.json` per Android, `apple-app-site-association` per iPhone).

### 3.5 App Check, quando l'app sara' sul Play Store

App Check e' gia' nel codice e **oggi resta spento nelle build di prova**, per
una ragione misurata: Play Integrity non sa attestare un'app installata da App
Distribution, e accenderlo adesso fermerebbe ogni chiamata delle tue build.
Quando l'app sara' su una traccia di test interno del Play Store:

1. nel codice si mette `installaSempre = true` in
   `lib/services/firebase/attestazione.dart` (e' un interruttore solo);
2. console di Firebase, **Build** > **App Check**: si registra l'app Android
   con **Play Integrity** e quella iPhone con **App Attest**;
3. si guarda per qualche giorno la scheda **API** con l'imposizione ancora
   spenta: li' si vede quante chiamate arrivano col gettone;
4. quando sono quasi tutte col gettone, si accende l'imposizione, e nel
   codice del server si mette `enforceAppCheck: true`.

## 4. COSA RESTA, E PERCHE'

**EA.14, registrazione e accesso su iPhone.** Non si puo' chiudere da qui: non
ho un iPhone e il simulatore non parte su questa macchina. Il codice delle tre
vie e' lo stesso per i due sistemi, e le parti che su iPhone si comportano
diversamente sono dichiarate: Apple e' la sola via che passa da
`signInWithProvider`, il link d'ingresso ha il suo dominio dichiarato nei
diritti dell'app, e App Check su iPhone userebbe App Attest. **La prova vera
la fa il fondatore** con la build iOS di Codemagic, seguendo i passi del
punto 3.

**I due rossi accettati** restano rossi per scelta, come prima dell'ordine, e
sono elencati in `tool/rossi_accettati.txt`.

## 4bis. IL DIFETTO CHE LA CONSEGNA HA FATTO USCIRE

La 2273 e' stata consegnata e guardata sul telefono. **Aperto il foglio del
link e toccato il campo, appena la tastiera saliva i due pulsanti si
disegnavano sopra il testo e sopra il campo**: "Mandami il link" copriva
l'indirizzo appena scritto. Ricontrollato tre minuti dopo per escludere un
fotogramma di passaggio: c'era ancora. **Padre: EA voce 19.**

La causa, misurata e non immaginata: `AlertDialog` tiene titolo, contenuto e
pulsanti in tre scomparti, e quando lo spazio non basta **titolo e pulsanti
si servono per primi**. Al banco, coi numeri del telefono, lo scomparto del
contenuto risultava alto **zero punti**. Il foglio adesso e' una colonna sola
dentro un solo scorrimento.

**La lezione non e' la cura, e' la guardia.** La prima stesura girava in una
finestra comoda, 390 per 844 punti, e restava **verde** su un difetto che si
vedeva a occhio. E' diventata rossa solo dopo aver letto i numeri veri dal
telefono. Una guardia che misura geometria vale quanto la finestra in cui
gira.

**Riparato e consegnato con la 2274**, release `09le7u4m4jiig`, e visto a
video con la tastiera aperta.

## 5. IL LAVORO A VIDEO

Tutto cio' che tocca lo schermo e' **prodotto e agganciato**, e si vede con la
build di quest'ordine: il menu' compatto della chat, il menu' utente viola su
cosmo, la bolla della Carta di nascita, l'invito degli Eos che non finisce piu'
sotto la barra, la pietra di Ingwaz, la pagina legale unica, il disclaimer
all'ingresso, il foglio dell'email col link.

**Il Soffio col microfono e il link d'ingresso li puo' provare solo il
fondatore**: il primo perche' nessuno qui puo' soffiare nel telefono, il
secondo perche' aspetta i passi in console.
