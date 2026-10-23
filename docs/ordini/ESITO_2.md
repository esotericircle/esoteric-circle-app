# ESITO 2: I MOTORI CHE NON PARLANO ALLA SCHERMATA, E LA BARRA IN ALTO

## La stima, scritta prima di toccare il codice

### Il debito dell'ordine 1

**Piena, e l'ipotesi dell'Architetto e' quasi certamente giusta.** La Guardia del
Suono e' montata nel guscio, quindi vive nell'albero anche in prova, e il
`pumpWidget` che smonta l'albero le fa fare il suo mestiere. Il test vedeva il
suono fermo e non sapeva chi l'aveva fermato: era la mia stessa correzione della
causa B a mascherare la causa A.

**La strada che scelgo**: la seconda, il lettore finto registra CHI ha chiamato
`stop`. La prima strada, montare senza Guardia, proverebbe il dispose in un
albero che non e' quello vero, e domani qualcuno rimonterebbe la Guardia
lasciando la prova cieca di nuovo. Registrare il chiamante regge in entrambi gli
alberi.

**Escludo la seconda ipotesi in due minuti**: se la prova chiude senza aver mai
avviato la riproduzione, lo `stop` e' ininfluente comunque, e in quel caso la
prova deve prima far partire il suono. Lo verifico prima di scrivere.

### Voce 1a, il segno cablato a Gemelli

**Piena.** I due ripieghi sono dichiarati e non li riscopro. Il lavoro vero non
e' toglierli, e' dare alla frase una fonte che non dipenda da chi si ricorda di
riempire un controller.

**La strada che scelgo, motivata**: il segno discende dalla DATA DI NASCITA
persistita in `ProfileController`, che il Passport gia' usa con
`NightSky.sunSign`. Non aggiungo persistenza a `ZodiacController`, perche'
sarebbe un secondo posto dove vive la stessa verita', ed e' esattamente la
famiglia di difetto che questo progetto ha gia' incontrato otto volte.

**La trappola la conosco e la dichiaro**: la data di prova dell'app e il
`BirthIdentity.example` sono entrambi del 15 giugno 1990, che e' Gemelli, quindi
una prova con l'identita' d'esempio e' verde col difetto e senza. La prova del
rosso usa il Cancro del fondatore.

**Il rischio vero**: la frase senza segno. Se la data manca, non invento un
segno, quindi serve una frase che regga senza nominarlo. Quella frase e' testo
di prodotto, non codice, e la scrivo con la stessa cura del resto.

### Voce 1b, la carta natale in caricamento eterno

**Piena, ed e' tre lavori distinti**, non uno: la chiamata che non parte, lo
stato di errore che non si vede, la conservazione fra un avvio e l'altro.

**Dove metto la garanzia**: nella schermata `NatalChartReveal`, che garantisce il
proprio dato all'apertura. Non nel Passport, perche' le porte sono piu' di una e
metterla in una porta e' la famiglia di difetto gia' contata. Le porte le
enumero con una prova.

**Il rischio piu' alto e' la conservazione.** Una carta natale conservata male e'
peggio di una non conservata: se cambia la data di nascita e la carta resta
quella vecchia, la persona vede il cielo di un altro. La chiave di conservazione
deve dipendere dai dati di nascita, non essere una chiave fissa.

### Voce 1c, la Ronda misurata dove l'utente guarda

**Piena, ed e' quella che vale di piu' nel tempo.** La terza domanda posta sulla
funzione pura e' una misura cieca: cambia l'input e la Ronda resta verde mentre
a schermo non si muove niente.

**Dichiaro quali motori restano sorvegliati solo sulla funzione pura**: si
compila a lavoro fatto, dopo aver letto l'elenco vero dei motori della Ronda.

### Voce 2a, il cuore che copre le informazioni

**Piena, e non correggo tre schermate.** Il difetto non e' in nessuna delle tre:
e' che non esiste un posto solo dove si dichiarano le azioni della barra
d'arte, quindi due autori diversi hanno messo due cose nello stesso angolo. Un
componente solo, e le azioni si dispongono senza sovrapporsi per costruzione.

**La prova del rosso misura i rettangoli**, non conta i widget: due icone possono
esistere entrambe ed essere una sopra l'altra.

### Voce 2b, la fascia nera

**Piena, e correggo la causa.** Il fondo non riempie l'altezza quando l'avviso
compare. L'avviso non c'entra: e' solo l'occasione che rivela il fondo corto.

### Voce 2c, i due interruttori fuori palette

**Piena.** Se un interruttore d'insieme non esiste nel design system ne creo uno
e enumero chi usa `Switch` direttamente, cosi' il terzo che arriva non ricomincia.

### Le tre correzioni alla consegna

- **Destinatario unico**: `cloud@esotericircle.app` soltanto. Era un mio errore,
  ho copiato la riga di una consegna vecchia senza rileggere la regola.
- **I trentadue megabyte**: li misuro con `verifica_apk.py` sui due archivi prima
  di dire da dove vengono. Non attribuisco la causa senza il conto.
- **`acceptedInvitationCount`**: si legge PRIMA di caricare, e trovo la chiamata
  giusta. L'HTML al posto del JSON di solito vuol dire endpoint sbagliato.

### Cosa non faccio

Non prendo altre voci. Se finisco in anticipo consegno e mi fermo.

## Stato voce per voce

### Il debito dell'ordine 1: SALDATO

Era la seconda ipotesi, quella data per meno probabile: **la prova chiudeva una
schermata muta.** Il tono della Meditazione parte solo al tocco, e la prova non
lo toccava mai, quindi lo `stop` mancante non cambiava niente. Non misurava
male, non misurava affatto.

Ho applicato anche la seconda protezione suggerita, perche' regge nel tempo: il
lettore finto registra CHI ha chiamato `stop`, e la prova pretende che sia il
dispose. Senza, la Guardia del Suono potrebbe fermare il tono al posto suo e
nessuno se ne accorgerebbe. **Prova di vista passata.**

### Voce 1a, il segno cablato: CHIUSA

Il segno e' una proprieta' del DATO di nascita, `BirthIdentity.sunSign`, ed e'
nullo finche' i dati sono quelli d'esempio. Le tre frasi del Santuario hanno una
versione intera che regge senza nominarlo.

**Una distinzione che ho dovuto fare**: le rotte delle arti chiedono un segno che
esista sempre, perche' un oroscopo senza segno non e' una cosa. Quelle ricevono
il segno della data che c'e' comunque, anche quella d'esempio dichiarata
in-world. La frase no: li' un segno che non e' il tuo e' una bugia detta alla
persona.

**Due prove, e la seconda e' quella che conta**: una sul dato, una che MONTA LA
HOME e pretende che il testo cambi al cambiare della data. Prova di vista
passata su entrambe.

### Voce 1b, la carta natale: CHIUSA

Tre lavori distinti: la chiamata che adesso parte dalla schermata, lo stato di
errore che si vede con la nota e il pulsante Riprova, la conservazione fra un
avvio e l'altro sotto una chiave che dipende dai dati di nascita.

**La conservazione tiene la RISPOSTA e non il modello**: se domani
l'interpretazione migliora, il cielo gia' scaricato ne beneficia senza
riscaricare niente. E c'e' una prova apposta perche' cambiando la data la carta
vecchia non venga riusata: sotto una chiave fissa sarebbe peggio del non
conservarla.

### Voce 1c, la Ronda a schermo: CHIUSA, con l'elenco dichiarato

La Ronda ha un terzo strato, **Strato a schermo**, e i due motori di questa voce
ci sono: il Segno solare e la Carta natale.

**I VENTIDUE MOTORI CHE RESTANO SORVEGLIATI SOLO SULLA FUNZIONE PURA**, come
l'ordine chiede di dichiarare senza correggerli adesso:

Cielo del momento, Segno lunare, Fase lunare, Illuminazione lunare, Risonanza,
Numero della vita, Animale Guida, Animale del giorno, Angeli custodi, Test
Archetipo, Costellazione del Viso, Tarocchi stesa, Tarocchi lettura, Oroscopo,
Doni del giorno, Rune getto, Sigillo intenzione, Sinastria VIP, Limiti dei
piani, Identita di nascita, Fatti natali, Luna di nascita.

Il numero e' scritto dentro la Ronda: quando cala, la prova cade e chiede di
aggiornare anche questo elenco, cosi' non si perde il conto di cosa e' davvero
coperto.

### Voce 2, la barra e la coerenza: CHIUSA

**2a.** Il difetto non era in nessuna delle tre schermate: era che non esisteva
un posto solo dove le azioni della barra si dichiarano. Adesso c'e' `BarraArte`,
le azioni stanno in una riga e non possono sovrapporsi. **La prova ha trovato una
QUARTA schermata** che la segnalazione non nominava, l'Animale Guida: stesso
difetto, mai guardata. E' il motivo per cui le porte si enumerano.

**2b.** Lo Stack del cosmo prendeva l'altezza del contenuto, quindi con un
contenuto corto il cielo finiva dove finiva lui. Corretta la causa.

**2c. I due interruttori erano QUATTRO**: oltre a "Lega al cielo di oggi" c'era
"Lega ai transiti" in entrambe le schermate. E non bastava il pollice, gia'
dorato: la traccia restava grigia da spenta e viola da accesa. C'e'
`InterruttoreDelCerchio` nel design system.

## Le tre correzioni alla consegna

### 1. Destinatario unico: FATTO

Solo `cloud@esotericircle.app`. Alla 2110 avevo copiato la riga di una consegna
vecchia senza rileggere la regola del 29 luglio.

### 2. I trentadue megabyte: MISURATI, E NON ESISTONO FRA QUELLE DUE BUILD

Non ho attribuito la causa: ho ricostruito la 2109 dal suo commit e l'ho pesata.

| Build | Byte | Base 1000 | Base 1024 |
|---|---|---|---|
| 2109 ricostruita dal commit `6196c21` | 235.891.257 | 235,9 MB | 225,0 MiB |
| 2110 consegnata | 236.001.856 | 236,0 MB | 225,1 MiB |

**La differenza vera e' 110.599 byte, cioe' 0,11 MB.** Non trentadue.

Le verifiche che escludono le altre spiegazioni:

- Gli asset entrati fra le due build pesano **386 KB in tutto**: i cinque MP3 e
  cinque immagini dell'oracolo. Il `git diff --stat` degli asset e' quello.
- Il `pubspec.yaml` fra le due build cambia **solo il numero di versione**.
- Il `build.gradle.kts` e' **identico**: gli `abiFilters` con `arm64-v8a` e
  `armeabi-v7a` c'erano gia' prima della 2109, quindi entrambe le build hanno le
  stesse due architetture. Il codice nativo pesa 46,2 MB piu' 37,4 MB non
  compressi, ed e' la voce piu' grande dopo gli asset, ma e' la stessa nelle due.

**Conclusione**: il peso di 203,93 MB attribuito alla 2109 non e' quello
dell'APK che quel commit produce. Non so da quale misura venga quel numero, e
non lo invento: quello che posso dire con l'archivio in mano e' che fra le due
build il peso e' lo stesso a meno di un decimo di megabyte, e che i cinque MP3
non c'entrano perche' pesano 96 KB, come l'ordine gia' sospettava.

Il conto per famiglia dell'archivio attuale, per averlo scritto: mazzo tarocchi
26,3 MB, angeli 25,0 MB, ritratti VIP 12,7 MB, archetipi 7,2 MB, sfondi rituali
4,9 MB, miniature tarocchi 4,5 MB, miniature angeli 4,2 MB, miniature VIP 2,8
MB, rune 2,1 MB, miniature archetipi 2,0 MB, avatar 1,7 MB.

### 3. Il conteggio degli inviti: TROVATA LA CHIAMATA, E IL CAMPO NON ESISTE QUI

L'HTML al posto del JSON veniva dall'endpoint sbagliato: avevo chiesto i tester
sotto l'APP, e stanno sotto il PROGETTO.

```
GET https://firebaseappdistribution.googleapis.com/v1/projects/425821975933/testers
```

Con questa, letta **prima** del caricamento, i tester sono due:
`cloud@esotericircle.app`, ultima attivita' 30 luglio 2026 alle 15:07, e
`info@esotericircle.com`, ultima attivita' 28 luglio 2026.

**`acceptedInvitationCount` non c'e' perche' e' un campo dei GRUPPI**, e
`GET /projects/425821975933/groups` risponde `{}`: in questo progetto non esiste
nessun gruppo, i tester sono assegnati uno per uno. Il campo che l'ordine chiede
non e' perso: non esiste per come e' configurata questa distribuzione. Il dato
equivalente e' `lastActivityTime`, che vale solo per chi ha davvero aperto
l'invito, e lo riporto prima e dopo.
