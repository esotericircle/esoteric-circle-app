# Distribuire il server del Cerchio, i due comandi che restano a Mauro

Ordine N. Il codice del server e le regole di sicurezza sono scritti, provati
e nel repository, ma **non sono ancora in vigore sul progetto Google**: da
questa macchina non si puo' distribuire, perche' serve l'accesso al progetto
`esoteric-circle` con le credenziali che stanno sul PC di Mauro.

Finche' i due comandi qui sotto non vengono eseguiti, l'app funziona lo
stesso, e questo e' voluto: senza server risponde la porta spenta e si resta
sui numeri locali, come dichiarato in `docs/SENZA_RETE.md`. Ma **i limiti
restano aggirabili e la memoria continua a morire alla reinstallazione**, che
e' esattamente cio' che l'ordine N e' venuto a chiudere.

## Prima di tutto: accedi

```bash
firebase login
```

Si apre il browser. Basta una volta sola su questa macchina.

## Comando 1, le regole di sicurezza

```bash
firebase deploy --only firestore:rules --project esoteric-circle
```

**Cosa fa.** Manda `firestore.rules` al progetto. Da quel momento il telefono
puo' LEGGERE il proprio ramo e non puo' piu' scriverci nulla: contatori del
giorno, saldo Eos e memoria si scrivono solo dalle funzioni.

**Perche' e' urgente.** Fino a oggi `firebase.json` non nominava nemmeno le
regole, quindi nessun comando le distribuiva: sul progetto e' in vigore quello
che c'e' nella console, e nessuno sa cosa sia. Questo comando chiude la
questione una volta per tutte.

## Comando 2, le funzioni

```bash
firebase deploy --only functions --project esoteric-circle
```

**Cosa fa.** Distribuisce le cinque callable nuove in `europe-west1`:
`statoDelCerchio`, `consumaDelGiorno`, `muoviGliEos`, `scriviLaMemoria`,
`cancellaIlCerchio`, accanto a `natalChart` che c'era gia'.

**Quanto dura.** La prima volta qualche minuto: Google costruisce
un'immagine per ogni funzione.

**Se chiede di abilitare qualche API** (Cloud Build, Artifact Registry,
Cloud Run) rispondi di si': sono i mattoni con cui Firebase costruisce le
funzioni, e il progetto e' gia' sul piano Blaze.

## L'ordine conta

Prima le regole, poi le funzioni. Al contrario, per il tempo che passa fra i
due comandi, esisterebbero funzioni che scrivono su un database che accetta
ancora le scritture del client, e due sorgenti di verita' insieme sono peggio
di una sbagliata.

## Cosa resta da fare in console, e solo li'

1. **I fornitori di accesso.** In Firebase, Authentication, Sign-in method:
   accendi **Google** e **Apple**. Senza, i due pulsanti "Continua con..."
   esistono nell'app ma il fornitore rifiuta. L'email e' gia' accesa.
2. **Il consenso di Apple** va configurato quando ci sara' la build iOS:
   serve il Service ID sul portale Apple. Su Android il pulsante di Apple non
   compare, quindi non blocca niente adesso.

## Come si verifica che sia andata

- **Le regole**: nella console, Firestore, Regole: la data di pubblicazione
  deve essere di adesso e il testo deve contenere `allow write: if false`.
- **Le funzioni**: nella console, Functions: devono comparire le cinque nuove
  in `europe-west1`.
- **Dal telefono**: apri l'app, fai tre gettate di rune, chiudi, sposta
  l'orologio del telefono avanti di un giorno, riapri. Le gettate devono
  restare finite. Prima di questo lavoro tornavano intere.

## Le prove che girano da qui, senza distribuire niente

```bash
cd functions && npm test
```

Le regole del server (limiti, confine del giorno, borsellino) provate senza
rete.

```bash
cd functions && npm run test:regole
```

Le regole di sicurezza VERE, caricate nell'emulatore Firestore e attaccate
come farebbe un client. Serve un JDK: su questa macchina c'e' quello di
Android Studio, e il comando lo trova da solo se `JAVA_HOME` punta a
`C:\Program Files\Android\Android Studio\jbr`.
