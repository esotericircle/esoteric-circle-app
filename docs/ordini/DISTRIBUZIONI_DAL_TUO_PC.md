# LE DISTRIBUZIONI CHE ASPETTANO IL TUO PC

Ordine CH voce 12, scritto il 31 agosto 2026; aggiornato dall'ordine CN
voce 15 il 1 settembre 2026, che ci aggiunge la distribuzione della build
ai fondatori. **Questo e' l'unico foglio di
istruzioni sulle distribuzioni pendenti**: il foglio delle lapidi, che stava a
parte, e' confluito qui dentro. Due fogli per lo stesso PC sono due verita' su
cosa manca.

**Nessuna credenziale passa da qui.** Questo file dice cosa lanciare, non cosa
custodire. Non c'e' nessun segreto da incollare da nessuna parte.

**Come si legge.** Ogni passo ha il comando esatto da copiare, e sotto **cosa
devi leggere a video** per sapere che e' andata bene. Se quello che leggi non
somiglia a quello scritto qui, fermati e dimmelo: non serve che capisca il
perche'.

Tutti i comandi si lanciano da PowerShell, nella cartella del progetto.

---

## PASSO 0. PORTA LA TUA CARTELLA ALLA TESTA NUOVA

**Perche' viene prima di tutto.** Nella tua cartella,
`C:\Users\user\Desktop\esoteric-circle-app`, il lavoro dell'ordine CG oggi
**non c'e'**. Verificato il 31 agosto 2026: `docs/ordini/ORDINE_CG_MANIFESTO.md`
non c'e', `functions/src/lapidi.ts` non c'e', e il puntatore del ramo non viene
toccato dal 15 agosto 2026. **Se distribuissi da li' adesso, manderesti in
produzione la versione di due ordini fa.**

```powershell
cd C:\Users\user\Desktop\esoteric-circle-app
git pull --ff-only
```

**Cosa devi leggere.** Un elenco di file cambiati e in fondo una riga tipo
`Fast-forward`. Poi verifica con questo:

```powershell
git log --oneline -1
```

**Cosa devi leggere**: la riga deve cominciare con lo sha della testa di
oggi oppure con uno piu' recente, e NON con `078d24b4`. **La testa del 1
settembre 2026, ordine CN, comincia con ``345b5ccb``.**

**Se `git pull` si rifiuta** dicendo qualcosa su modifiche locali, vuol dire
che in quella cartella c'e' del lavoro non salvato. Non forzare niente:
scrivimelo e lo guardiamo insieme.

---

## PASSO 1. INSTALLA LE DIPENDENZE DEL SERVER

Si fa una volta sola, e serve perche' i comandi dopo funzionino.

```powershell
cd C:\Users\user\Desktop\esoteric-circle-app\functions
npm install
```

**Cosa devi leggere**: qualche riga di avanzamento e in fondo `added N
packages` oppure `up to date`. Gli avvisi che cominciano con `npm warn` sono
normali e non fermano niente.

---

## PASSO 2. LE FUNZIONI DEI RICORDI

**Sono sei, e sono quelle che fanno salire il Cosmic Journal sul server.**

```powershell
cd C:\Users\user\Desktop\esoteric-circle-app\functions
npx firebase deploy --only functions:scriviIRicordi,functions:leggiIRicordi,functions:leggiIMovimenti,functions:custodisciIlResponso,functions:leggiICustoditi,functions:lasciaIlResponso --project esoteric-circle
```

**Cosa devi leggere**: sei righe che finiscono con `functions[...] Successful
create operation` oppure `Successful update operation`, e in fondo
`Deploy complete!`.

**Cosa smette di essere finto.** Dopo questa distribuzione, sul telefono:

- i tuoi Ricordi si salvano sul server e non solo sul telefono, quindi
  reinstallando l'app li ritrovi;
- **Custodisci** sotto ogni responso funziona davvero, e cio' che custodisci
  resta per sempre;
- **Le tue card** si riempiono anche su un telefono nuovo;
- i movimenti degli Eos nei Ricordi arrivano con due anni di storia invece
  degli otto mesi che il telefono tiene.

Prima di questa distribuzione tutto questo vive solo sul telefono e sparisce
con l'app.

---

## PASSO 3. LA SFOCATURA SETTIMANALE

**E' il lavoro che tiene basso il conto della memoria dei Maestri.** Gira da
solo il lunedi' alle 4:10.

```powershell
cd C:\Users\user\Desktop\esoteric-circle-app\functions
npx firebase deploy --only functions:sfocaLeConversazioni --project esoteric-circle
```

**Cosa devi leggere**: una riga `functions[sfocaLeConversazioni(...)]
Successful create operation` e in fondo `Deploy complete!`.

**Cosa smette di essere finto.** I Maestri cominciano a ricordare le
conversazioni vecchie in forma sintetica invece che dimenticarle. Non si vede
subito: il primo giro e' il lunedi' successivo.

---

## PASSO 4. LE LAPIDI DEL BENVENUTO

**Cosa e' gia' fatto.** La lapide del tuo account e' cancellata. Misurato sul
dato vero:

| quando | lapidi | quali |
| --- | --- | --- |
| prima | 3 | `maobatta@gmail.com`, `cloud@esotericircle.app`, una gia' col pepe |
| dopo | 2 | `cloud@esotericircle.app`, una gia' col pepe |

Da adesso, se rifai l'onboarding con `maobatta@gmail.com`, il Cerchio ti da' di
nuovo i 250 Eos del benvenuto.

**Cosa resta, e perche' non l'ho fatto io.** Una lapide sola, quella di
`cloud@esotericircle.app`, e' ancora col sale vuoto: vuol dire che chiunque
conosca quell'indirizzo puo' calcolare la sua impronta e sapere che ha gia'
incassato il benvenuto. Per ripesarla serve il pepe, e **il pepe non si legge
dall'esterno**: sta in Secret Manager e non deve uscire da li'. L'unico posto
che puo' calcolare l'impronta nuova e' una funzione del server, che il segreto
ce l'ha montato.

Il lavoro e' gia' scritto in `functions/src/lapidi.ts`. **Non e' una via
raggiungibile dall'esterno ed e' voluto**: una via che accettasse un indirizzo
e riscrivesse una lapide sarebbe una superficie nuova su un dato antifrode, e
chiunque la raggiungesse potrebbe provare indirizzi e leggere dalle risposte
chi ha gia' incassato. E' un lavoro a orario, gli indirizzi sono scritti nel
codice, e **si spegne da solo**: quando la lapide col sale vuoto non c'e' piu',
non trova niente e non fa niente.

**1. Distribuisci il lavoro delle lapidi.**

```powershell
cd C:\Users\user\Desktop\esoteric-circle-app\functions
npx firebase deploy --only functions:sistemaLeLapidi --project esoteric-circle
```

**Cosa devi leggere**: `Successful create operation` e `Deploy complete!`. Se
compare una riga che nomina `BENVENUTO_PEPPER` e dice che il segreto non
esiste, fermati e dimmelo: vuol dire che il pepe non e' mai stato creato, e
quello e' un passo diverso.

**2. Fallo girare subito, invece di aspettare le 3:50 di stanotte.**

```powershell
npx gcloud scheduler jobs run firebase-schedule-sistemaLeLapidi-europe-west1 --location europe-west1 --project esoteric-circle
```

**Cosa devi leggere**: nessun messaggio di errore. Questo comando non stampa
niente quando riesce.

**3. Verifica che sia andata.**

```powershell
npx firebase firestore:get lapidi_del_benvenuto --project esoteric-circle
```

**Cosa devi leggere**: le lapidi restano due, ma **nessuna** deve avere come
identificativo
`b24dc7957aecb2ec0aa3902815fa0e46d762655d165d8646078d068101fee0b5`. Se quello
c'e' ancora, il giro non e' passato oppure il segreto non era montato.

**Cosa smette di essere finto.** Niente che tu possa vedere sul telefono: e'
una cura su un dato antifrode. Il giorno che la verifica qui sopra e' pulita,
l'elenco `LAPIDI_DA_SISTEMARE` si puo' svuotare e la funzione togliere, e non
resta nessun interruttore acceso da ricordarsi di chiudere.

---

## PASSO 5. LE PUSH, E QUI DEVO DIRTI UNA COSA PRIMA

**Il lato server delle push e' pronto e si puo' distribuire. Il lato app NON
c'e' ancora**, e l'ho misurato invece di ricordarmelo: la classe che sul
telefono raccoglie il gettone delle notifiche e manda le tue scelte al server,
`CustodeDellePush`, esiste col suo corpo e le sue prove ma **nessuno la monta
dentro l'app**, e l'unica porta collegata e' quella spenta.

**Quindi**: distribuire adesso queste tre funzioni non ti fara' arrivare
nessuna notifica push, perche' il telefono non manda mai il suo gettone. Non e'
un errore di questo foglio, e' lo stato del lavoro: la voce CG.16 aveva
consegnato la parte uno, cioe' il cancello del mese di prova, i testi e il lato
server, e il resto era dichiarato e non fatto.

**Puoi distribuirle lo stesso**, e non fanno danno: il lavoro a orario gira
ogni quindici minuti, non trova nessun gettone da spingere e non fa niente.
Oppure puoi aspettare che l'app abbia la sua porta. **La scelta e' tua**, e se
mi dici di farla la faccio.

```powershell
cd C:\Users\user\Desktop\esoteric-circle-app\functions
npx firebase deploy --only functions:scriviLeScelteDellePush,functions:togliLeScelteDellePush,functions:spingiIDoni --project esoteric-circle
```

**Cosa devi leggere**: tre righe `Successful create operation` e
`Deploy complete!`.

---

## SE UN COMANDO MUORE MENTRE ANALIZZA

E' la cosa che succede piu' spesso, e non vuol dire che qualcosa sia rotto.
Riconosci il caso cosi': il comando resta fermo su una riga che parla di
`analyzing` oppure di `Building` e poi esce con un errore di tempo scaduto.

**Cosa fare, in ordine.**

1. **Rilancia lo stesso comando, identico.** Distribuire due volte non fa
   danno: la seconda volta si limita ad aggiornare quello che c'e' gia'.
2. **Se muore ancora, distribuisci meno funzioni per volta.** Prendi il comando
   del passo che stava fallendo e togli tutte le funzioni tranne una, poi
   rilancia una funzione alla volta. Per esempio, invece delle sei dei Ricordi
   insieme:

   ```powershell
   npx firebase deploy --only functions:scriviIRicordi --project esoteric-circle
   ```

   e poi le altre cinque, una per volta, cambiando solo il nome dopo
   `functions:`.
3. **Se muore anche una funzione sola**, fermati e mandami quello che leggi a
   video. Non e' piu' un problema di tempo.

---

## PASSO 6. LA BUILD AI FONDATORI

**Questa la faccio io, e questo passo serve solo se un giorno devi rifarla tu.**
La build 2218 dell'ordine CN e' gia' costruita e consegnata dal mio lato: la
trovi in Firebase App Distribution, e chi e' nel gruppo dei tester la riceve
per posta.

**Se devi rifarla dal tuo PC**, in ordine:

```powershell
cd C:\Users\user\Desktop\esoteric-circle-app
flutter build apk --release
```

**Cosa devi leggere.** In fondo una riga che comincia con la spunta e dice
`Built build\app\outputs\flutter-apk\app-release.apk`, con un peso fra
parentesi. Se leggi `FAILURE` fermati e mandami quello che vedi.

Poi la consegna, che vuole una sessione gcloud attiva:

```powershell
$env:COMANDO_DI_BUILD = "flutter build apk --release"
python tool/consegna.py build/app/outputs/flutter-apk/app-release.apk "Le note della build"
```

**Cosa devi leggere.** Righe che dicono che l'archivio e' stato ispezionato,
caricato e distribuito, e in fondo il numero della release. Lo strumento
aggiorna da solo `docs/versione_distribuita.json`: **non scrivere quel file a
mano**, e' esattamente il passo che saltava prima che questo strumento
esistesse.

**Se la consegna si ferma dicendo qualcosa sul token**, la tua sessione gcloud
e' scaduta:

```powershell
gcloud auth login
```

e poi rilancia la consegna. **Nessuna chiave e nessun segreto si incolla da
nessuna parte**: il token si prende al volo e dura un'ora.

---

## COME SAI CHE HAI FINITO

Lancia questo, che elenca tutto quello che c'e' sul server:

```powershell
npx firebase functions:list --project esoteric-circle
```

**Cosa devi leggere**: nell'elenco devono comparire, oltre a quelle vecchie,
`scriviIRicordi`, `leggiIRicordi`, `leggiIMovimenti`, `custodisciIlResponso`,
`leggiICustoditi`, `lasciaIlResponso`, `sfocaLeConversazioni` e
`sistemaLeLapidi`. Le tre delle push ci sono solo se hai fatto il passo 5.
