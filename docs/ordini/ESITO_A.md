# ESITO dell'ORDINE A, il rifacimento immersivo

Eseguito da Claude Code il 28 luglio 2026, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

## Prima di tutto: il push non passa

La coda chiede di provarlo per primo. Provato, anche togliendo di mezzo il
gestore delle credenziali interattivo: il remoto risponde `No anonymous write
access` e l'autenticazione fallisce. Non ci sono credenziali utilizzabili in
questo ambiente, `gh` non e' installato, nessun token in variabile d'ambiente.
Non ho insistito, come da istruzione. I commit fermi in locale sono ora sette.

## Cosa e' stato fatto, cosa no

Di questo ordine sono stati eseguiti **A1** e **A7**. I punti A2, A3, A4, A5 e
A6 NON sono stati toccati.

La ragione e' la stessa che l'ordine dichiara di condividere: meglio consegnare
cose intere e verificate. A1 e' bloccante, perche' senza quello l'APK di stanotte
non si installa nemmeno; A7 e' lo strumento che serve a Mauro per provare il
resto. Gli altri cinque punti sono rifacimenti profondi che meritano lo stesso
trattamento dei tre Angeli, non una passata veloce in coda a un lavoro lungo.

## A1, il numero di versione: FATTO

Il difetto era reale e fermava tutto: la release di stanotte portava
`versionCode` **1** contro il **2001** di quella del giorno prima, quindi Android
si rifiutava di installarla sopra. Il 2001 non era voluto, veniva da
`--split-per-abi`, che somma duemila per l'ABI arm64; togliendo lo split il
numero e' tornato a uno senza che nessuno se ne accorgesse.

La correzione ha tre pezzi.

1. `pubspec.yaml` porta ora `version: 0.1.0+2100`, sopra la soglia che il
   vecchio schema poteva raggiungere. Il commento sul campo spiega perche'.
2. `docs/versione_distribuita.json` registra l'ultimo numero davvero consegnato
   a un telefono, oggi 2001. Si aggiorna dopo ogni distribuzione riuscita.
3. `test/versione_build_test.dart` legge il numero dal pubspec, cioe' dall'unica
   sorgente che vale per ogni modo di costruire, poi lo confronta con quel
   file.

**Prova del rosso eseguita**: col pubspec ancora a `+1` il test fallisce dicendo
`Expected: a value greater than <2001>, Actual: <1>`, cioe' nomina esattamente il
difetto. Dopo la correzione passa.

Criterio numerico: *il numero di versione della build nuova e' maggiore di 2001*.
Misurato: **2100**, contro 2001. Passa.

## A7, ripristino del Risveglio in debug: FATTO

Una riga nelle Impostazioni, sotto quella del token di App Check, con la stessa
regola di visibilita': compare solo quando i servizi dichiarano di essere fuori
dalla release, quindi in release non esiste.

Al tocco azzera profilo, identita' e stato del rito, poi riapre l'onboarding
tornando prima alla radice della navigazione, cosi' il Risveglio non resta
appeso sotto la pila delle Impostazioni da cui il comando e' partito.

Due pezzi nuovi, entrambi minimi: `OnboardingController.reset()`, che rimette il
rito allo stato di chi non l'ha mai fatto, piu' `ProfileStore.clear()`, che
toglie
le otto chiavi del profilo una per una invece di svuotare tutte le preferenze,
perche' li' dentro stanno anche cose che del profilo non sono, come il token di
debug di App Check.

## Suite, APK, consegna

`flutter test`: **809 test verdi**, erano 807. `flutter analyze`: pulito.

APK: `build/app/outputs/flutter-apk/app-debug.apk`, **244.450.769 byte, cioe'
233,13 MiB**, uno solo, arm64. Il controllo di integrita' passa: otto famiglie
complete in piena e in miniatura.

Il numero di versione dentro l'archivio e' stato verificato, non dedotto:
`flutter.versionCode=2100` in `android/local.properties`, e la sequenza di byte
del 2100 si trova nel manifest compilato dell'APK, mentre quella del vecchio
2001 non c'e'.

Consegna riuscita, destinatario unico `cloud@esotericircle.app`: release
**0.1.0 (2100)**, che si installa sopra la 2001 di ieri.

- Pagina per i tester:
  `https://appdistribution.firebase.google.com/testerapps/1:425821975933:android:1b1ca4db8d4df69b940814/releases/5mr2obhs3qir8`

Dopo la consegna `docs/versione_distribuita.json` e' stato portato a 2100, e li'
il lucchetto ha mostrato un difetto suo: chiedeva un numero strettamente
maggiore dell'ultimo distribuito, quindi appena registrato il 2100 la suite
diventava rossa contro se stessa. La regola vera e' un'altra: Android rifiuta un
versionCode piu' basso di quello installato, mentre lo stesso numero si
sovrascrive senza storie. Il test ora verifica che il numero non SCENDA, che e'
il vincolo che il telefono impone davvero.

## A2, A3, A4, A5, A6: NON FATTI

Restano interi, coi loro criteri numerici non misurati.

- **A2**, il sistema di scena: le otto classi che disegnano il cielo restano
  otto, le due iscrizioni all'accelerometro restano due, l'ampiezza da sensore
  resta a **2,16 px** sul piano principale contro i 24 px chiesti, il rapporto
  fra dito e sensore resta fra nove e quindici a uno contro il tre a uno
  chiesto, il fondale resta ripetuto in tre schermate, `ScrollReveal` resta
  legato al montaggio invece che alla posizione nello schermo.
- **A3**, il permesso di posizione: nessun comando toccabile, nessuna via
  d'uscita dal rifiuto permanente, due meccanismi di pre-avviso ancora
  conviventi.
- **A4**, il carosello dei Maestri: nessuna transizione animata, nessun
  trascinamento orizzontale.
- **A5**, le due animazioni di trionfo: il Sigillo resta nel terzo alto mentre
  la frase dice di posare il dito al centro, l'Animale Guida resta senza la
  nebbia che si dirada.
- **A6**, i tre punti di disposizione: il nome Medora va ancora a capo, l'avatar
  copre ancora i titoli, la silhouette e' ancora quella.

## Nota sull'Indice delle Prescrizioni

La coda chiede di rileggere `claude/Indice_delle_Prescrizioni_Esoteric_Circle`
nel Project prima di aprire ogni ordine, per chiudere righe ASSENTE o VIOLATA
senza costo aggiuntivo. Quel documento vive nel Project di Cowork, a cui da qui
non ho accesso: nel repository non c'e'. Se serve che lo consulti, va depositato
in `docs/`, come e' stato fatto per gli ordini.
