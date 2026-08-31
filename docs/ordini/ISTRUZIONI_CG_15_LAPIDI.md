# CG.15, IL GESTO CHE RESTA DAL PC DEL FONDATORE

Ordine CG voce 15. Scritto il 31 agosto 2026.

**Nessuna credenziale passa dalla chat.** Qui non si chiede nessun segreto
incollato: si chiede solo di lanciare due comandi dal tuo PC.

## COSA E' GIA' FATTO

**La lapide del tuo account e' cancellata.** Misurato sul dato vero:

| quando | lapidi | quali |
| --- | --- | --- |
| prima | 3 | `maobatta@gmail.com`, `cloud@esotericircle.app`, una gia' col pepe |
| dopo | 2 | `cloud@esotericircle.app`, una gia' col pepe |

Da adesso, se rifai l'onboarding con `maobatta@gmail.com`, il Cerchio ti da'
di nuovo i 250 Eos del benvenuto.

## COSA RESTA, E PERCHE' NON L'HO FATTO IO

**Una lapide sola, quella di `cloud@esotericircle.app`, e' ancora col sale
vuoto.** Vuol dire che chiunque conosca quell'indirizzo puo' calcolare la sua
impronta e sapere che ha gia' incassato il benvenuto.

**Per ripesarla serve il pepe, e il pepe non si legge dall'esterno.** Sta in
Secret Manager e non deve uscire da li': l'unico posto che puo' calcolare
l'impronta nuova e' una funzione del server, che il segreto ce l'ha montato.

**Il lavoro e' gia' scritto e prova le sue decisioni**, in
`functions/src/lapidi.ts`. Non e' una callable ed e' voluto: una via che
accettasse un indirizzo e riscrivesse una lapide sarebbe una superficie nuova
su un dato antifrode, e chiunque la raggiungesse potrebbe provare indirizzi e
leggere dalle risposte chi ha gia' incassato. E' un lavoro a orario, gli
indirizzi sono dichiarati nel codice, e **si spegne da solo**: quando la lapide
col sale vuoto non c'e' piu', non trova niente e non fa niente.

**Non l'ho distribuito io**, e la ragione e' semplice: distribuire le funzioni
cambia la produzione, e in questo ordine tu hai ordinato la build dell'app, non
una distribuzione del server. E' una tua decisione, non mia.

## I DUE COMANDI, in ordine

**1. Distribuisci il lavoro delle lapidi.**

```bash
cd functions && npx firebase deploy --only functions:sistemaLeLapidi --project esoteric-circle
```

**2. Fallo girare subito, invece di aspettare le 3:50 di stanotte.**

```bash
npx gcloud scheduler jobs run firebase-schedule-sistemaLeLapidi-europe-west1 --location europe-west1 --project esoteric-circle
```

## COME VERIFICARE CHE SIA ANDATA

Il conto delle lapidi non cambia (restano due), ma l'impronta di
`cloud@esotericircle.app` non deve piu' essere riconoscibile col sale vuoto.

```bash
npx firebase firestore:get lapidi_del_benvenuto --project esoteric-circle
```

**Cosa si deve vedere**: nessuna delle due lapidi ha come identificativo
`b24dc7957aecb2ec0aa3902815fa0e46d762655d165d8646078d068101fee0b5`, che e' lo
SHA-256 nudo di quell'indirizzo. Se quell'identificativo c'e' ancora, il giro
non e' passato oppure il segreto non era montato sulla funzione.

## E POI SI PUO' TOGLIERE

Il giorno che la verifica qui sopra e' pulita, l'elenco
`LAPIDI_DA_SISTEMARE` si puo' svuotare e la funzione togliere: **non resta
nessun interruttore acceso che qualcuno debba ricordarsi di chiudere**, che e'
la parte che l'ordine chiedeva di decidere e di motivare.
