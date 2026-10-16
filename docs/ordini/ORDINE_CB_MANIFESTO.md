# ORDINE CB, IL PRIMO APPRODO E CIO' CHE RESTA DI UNA PERSONA

Ordine del fondatore del 29 agosto 2026, cinque voci, arrivato in due pezzi.
Guardia `test/ordine_cb_guard_test.dart`.

Porta le sue tre regole, che sono quelle degli ordini precedenti irrigidite:

- **REGOLA ZERO.** Il testo dell'ordine non e' affidabile: ogni affermazione si
  verifica sul ramo prima di lavorarci, e cio' che risulta falso si scrive nel
  rapporto invece di eseguirlo.
- **REGOLA UNO.** Non ci si ferma davanti a un ostacolo: si risolve, e se non si
  puo' risolvere si riporta cosa manca e perche'.
- **REGOLA DUE.** Le decisioni lasciate a me si prendono e si motivano per
  iscritto, non si rimandano al fondatore.

## Le cinque voci

- **CB.01** Il diario dei sogni si elimina. **CHIUSA.** Il quaderno non esiste piu' in `lib/`, il Rito del Sogno resta intero, e tre gradini dell'Albero dormono dichiarati.
- **CB.02** Il tutorial di primo approdo, cinque fumetti. **CHIUSA.** Cinque fumetti, 172 parole, 52 secondi di lettura; quattro bersagli veri e lo skip su tutti e cinque.
- **CB.03** Cambio email e reimpostazione password dal menu' utente. **CHIUSA.** La password si cambiava e si reimpostava gia'; nasce il cambio dell'email, che passa dalla verifica sull'indirizzo nuovo.
- **CB.04** Le sette chiavi che sopravvivono alla cancellazione. **CHIUSA.** Nessuna delle sette sopravvive: misurate prima e dopo su tutte e tre le vie della cancellazione.
- **CB.05** Il limite di conservazione dei dati. **CHIUSA.** Sette categorie censite, cinque scadenze sul server e due sul telefono, ognuna con la sua ragione; la privacy policy dice quello che il codice fa.

VOCI_TOTALI: 5
VOCI_CHIUSE: 5
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

### La frase di accettazione della voce CB.01

**Apri il Rito del Sogno e arriva fino al saluto della notte: sotto la
frase di Caligo non c'e' piu' nessun tasto per annotare il sogno, e il
rito finisce com'era prima che il quaderno esistesse.**

## QUELLO CHE RESTA NELLE MANI DEL FONDATORE

**Il lavoro notturno delle scadenze e' scritto ma NON distribuito.** Distribuire
una funzione chiede la sessione `firebase` che vive sul PC del fondatore, e
nessuna credenziale passa da qui. Il comando esatto, da lanciare dalla cartella
del repository:

```
cd functions && npm run build && cd .. && npx firebase deploy --only functions:pulisciLeScadenze
```

Se il primo tentativo muore su `Cannot determine backend specification. Timeout
after 10000`, non e' il codice, e' il tempo che la CLI si da' per analizzarlo:
si rilancia con `FUNCTIONS_DISCOVERY_TIMEOUT=120` davanti.

**Finche' non e' distribuito, sul server non cancella niente**, e le scadenze
del telefono invece valgono da subito, perche' vivono dentro l'app.

## LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE

La REGOLA ZERO chiede di non fidarsi del testo. Otto affermazioni verificate sul
ramo `claude/sessione-di-prova-1f7cac`, testa `e7aa2f11`, prima di scrivere una
riga. **Cinque erano vere, tre no.**

| # | l'ordine dice | esito | cosa ho trovato davvero |
| --- | --- | --- | --- |
| P1 | esiste un solo manifesto d'ordine aperto | **vera** | c'era solo `ORDINE_CA_MANIFESTO.md` |
| P2 | l'ordine CA e' chiuso in tutte le sue voci | **vera** | marcatori 7 totali, 0 aperte, 7 chiuse |
| P3 | il diario dei sogni e' fatto di quei pezzi | **vera** | tutti trovati: la chiave `sogni.annotati`, i due pulsanti, il provider, la riga della dimenticanza, l'anteprima e tre prove |
| P4 | non esiste nessun tutorial | **vera** | l'unica occorrenza della parola e' un commento che dice che quella scena NON e' un tutorial |
| P5 | dal menu' utente non si cambiano ne' email ne' password | **META' FALSA** | la password si cambia gia': la riga `cambia_parola` chiama `updatePassword`, e `sendPasswordResetEmail` esiste. **Non esiste il cambio EMAIL**: zero occorrenze di `updateEmail` e `verifyBeforeUpdateEmail` in tutto il codice |
| P6 | sette chiavi sopravvivono alla cancellazione | **FALSA** | tutte e sette sono gia' coperte dai prefissi di `CioCheETuo`: `luogo.`, `device.id`, `filo.`, `avvisi.`, `maestro.`, `sunset_rune`. La voce CB.04 resta utile lo stesso, perche' quello che nessuno ha mai fatto e' **misurarle prima e dopo**, sulle due strade della cancellazione |
| P7 | `ProfileStore.clear()` e' cablato solo nella vista di debug | **vera** | unica chiamata in `lib/features/debug/app_check_debug_view.dart:127` |
| P8 | nessun dato ha una scadenza | **FALSA IN UN PUNTO** | il codice del secondo fattore scade davvero: `functions/src/secondo_fattore.ts:143` confronta `Date.now()` con `dati.scade`. Tutto il resto non ha scadenza, e la voce CB.05 vale |

## CB.01, il diario dei sogni si elimina

**Parole del fondatore:** "elimina tutta sta roba che non so cosa sia", "cancella
il diario dei sogni", e la ragione: "non c'e' nessun diario di sogni o simile".

**Da dove veniva, che e' la parte che conta.** Il quaderno non l'ha chiesto
nessuno e non sta in nessun briefing: e' nato dall'ordine BX voce 10 per
svegliare tre gradini del corpus dei Traguardi che parlavano di sogni ANNOTATI.
Una funzione costruita per far tornare un conto interno, non per servire una
persona. **Questo e' il difetto di metodo che la voce chiude**, e per questo la
guardia nuova non sorveglia soltanto i file: sorveglia la strada per cui
tornerebbe.

**Cosa e' uscito**, tutto verificato a codice:

| cosa | dove stava |
| --- | --- |
| la classe del quaderno | `lib/core/rituals/diario_dei_sogni.dart`, cancellato |
| il foglio per annotare | `lib/features/rituals/annota_il_sogno.dart`, cancellato |
| i due pulsanti del rito | `dream_annota` e `dream_rileggi` in `dream_rite_screen.dart` |
| il provider | `lib/app.dart` |
| la riga della dimenticanza | `dimenticanza_della_memoria_viva.dart` |
| i due gesti alla regia | `sogno_annotato` e `sogno_riletto`, tolti dal generatore |
| l'anteprima | `docs/preview/annota-il-sogno.png`, cancellata col suo scatto |
| le prove del quaderno | cinque, in `le_condizioni_costruite_test.dart` |

**Il Rito del Sogno resta intero**, perche' toglierlo nessuno l'ha chiesto: esce
solo il quaderno che gli era stato attaccato sopra. Resta Coming soon
l'Interpretazione dei Sogni, il gradino 19 del corpus, che e' la cosa che il
fondatore aveva in mente.

### I TRE FATTI CHE LA VOCE CHIEDE DI DICHIARARE

**1. La chiave `sogni.annotati` vive gia' sui telefoni.** Chi ha installato una
build da meta' agosto in poi ce l'ha sul disco, e da sola l'app non la
tocchera' mai piu'. **Il prefisso `sogni.` RESTA nell'elenco della
cancellazione**, cosi' quel dato se ne va comunque il giorno che la persona
cancella tutto. Toglierlo sarebbe stato pulito nel codice e falso sul telefono.

**2. Quattro gradini dell'Albero dipendevano dal quaderno, ma solo tre
davvero.** Il quarto, `cal_04`, chiede `GestiCompiuti('sogno', 1)`, e quel gesto
lo manda il Rito: resta vivo e raggiungibile. Gli altri tre passano a
**dormienti dichiarati**, col perche' scritto dentro la condizione, e non
scritto a mano: **l'ha fatto il generatore**, che e' la ragione per cui esiste.

| gradino | nome | Eos |
| --- | --- | --- |
| `cal_17` | Il sogno riletto | 20 |
| `cal_31` | Il sogno che si ripete | 30 |
| `cal_32` | Il tuo Animale nel sogno | 30 |

**Il conto degli Eos raggiungibili cala di 80** su 6.030 totali, cioe' l'1,3 per
cento. I dormienti in app passano da 51 a 54, ed e' un numero che il fondatore
deve vedere cambiare: sta scritto qui e lo stampa la prova.

**3. L'anteprima `annota-il-sogno.png` e' stata cancellata** dal corredo insieme
allo scatto che la produceva, perche' un'anteprima di una schermata che non
esiste piu' e' una bugia illustrata.

**Il rosso, dimostrato e non promesso.** `test/il_quaderno_dei_sogni_non_torna_test.dart`
sorveglia sette pezzi dentro tutti i 473 file Dart di `lib/`. Rimettendo a mano
la sola stringa `dream_annota` in `dream_rite_screen.dart` la prova e' diventata
rossa e ha detto quale pezzo e in quale file; tolta la stringa, e' tornata
verde. L'iniezione e' stata verificata col `grep` PRIMA di leggere l'esito.

## CB.02, il tutorial di primo approdo

**Parole del fondatore:** "facciamo una via di mezzo, da 5 fumetti tutorial da
leggere in 1 minuto", e dal 28 agosto "un brevissimo tuttorial (disattivabile,
skip) solo appena l'utente approda per la prima volta nella Home il cerchio".

I cinque testi sono dell'Architetto e si usano come sono scritti. Due frasi del
quinto sono state corrette, ed e' la voce stessa a chiederlo.

### LA GEOMETRIA VERA, misurata prima di puntare le frecce

L'ordine chiedeva di verificarla e di dichiarare cosa avessi trovato. **La
descrizione del fondatore corrisponde alla scena, tutti e cinque i bersagli
esistono.** Le barre in alto sono davvero due, una sopra l'altra:

| fumetto | cosa punta | dove vive |
| --- | --- | --- |
| 1, Sei nel Cerchio | niente, e' la soglia | nessuna freccia, come l'ordine chiede |
| 2, I tre Maestri | il carosello dei tre volti | `santuario_screen.dart` |
| 3, Esplora | la barra in basso, che porta scritto **ESPLORA** | `barra_del_cerchio.dart` |
| 4, I Doni del Giorno | la striscia dei doni, seconda barra dall'alto | `daily_strip.dart` |
| 5, Eos | la barra sottile in cima: profilo, eventi cosmici, borsellino | `barra_dell_identita.dart` |

### LA VERIFICA OBBLIGATORIA SUI TESTI, e cosa ne e' uscito

L'ordine impone di misurare tre affermazioni e di **correggere il testo** se
non sono vere. Due lo erano, una no.

- **Fumetto 2, le materie dei tre Maestri: VERO.** Il codice dice Medora
  "Astrologia, Cartomanzia, Destino", Aura "Chakra, Energia, Archetipi",
  Caligo "Rune, Rituali, Cabala". Testo lasciato com'era.
- **Fumetto 4, i doni a ore diverse: VERO.** Sono cinque e a cinque ore
  diverse: 7, 10, 13, 18 e 22. Testo lasciato com'era.
- **Fumetto 5, gli Eos: FALSO IN DUE PUNTI, e il testo e' stato corretto.**
  1. "da ogni responso che condividi" prometteva un premio senza fine. Il
     server ne paga al massimo **tre al giorno** (`TETTO_CONDIVISIONI_PREMIATE`
     vale 3): dal quarto in poi la condivisione non vale un Eos. Adesso il
     testo dice "dai primi responsi che condividi".
  2. "per aprire cio' che ancora dorme" prometteva di sbloccare le funzioni in
     arrivo. Gli Eos non aprono niente di dormiente: comprano una domanda o una
     lettura in piu' quando il giorno e' finito (`PREZZI_DEL_RISCATTO`: domanda
     80, gettata 60, approfondimento 60, confronto 150, stesa 250). Adesso il
     testo dice quello.
  3. **Aggiunta la via di guadagno piu' frequente**, che il testo non
     nominava: l'accredito di ogni giorno, 20 Eos al piano Viandante.

### UNA VIRGOLA CADUTA, E NESSUNA PAROLA

Il quarto fumetto finiva con "si ricevono, e chi torna li trova". La regola
della lingua di questo progetto vieta una proposizione dopo la virgola con
"e", e l'ordine chiede di usare i testi dell'Architetto come sono scritti: le
due regole si toccavano su quella riga. **E' caduta la virgola, non una
parola**, ed e' lo stesso precedente dell'ordine CA, dove trentasei frasi del
corpus della Sinastria hanno perso la virgola e non il senso.

### IL MINUTO, misurato

I cinque fumetti sono **172 parole**, titoli compresi. A 200 parole al minuto,
che e' il numero peggiore della lettura silenziosa in italiano, fanno **52
secondi**. La prova lo stampa e cade sopra le 200 parole. Alla persona il
minuto lo dichiara il primo fumetto, con le parole dell'Architetto: "Un minuto
e sai muoverti".

### COSA HA TROVATO L'ANTEPRIMA, CHE NESSUNA PROVA CERCAVA

Le cinque anteprime a 360 punti logici hanno trovato **due difetti veri**, e
tutte le prove erano verdi:

1. **La riga dei tasti sfondava di 35 punti** sull'ultimo fumetto, dove il
   pulsante dice "Entra nel Cerchio". Adesso il conto e lo skip stanno sopra e
   il pulsante prende tutta la riga, che a un dito e' anche piu' facile.
2. **Il fumetto dei Maestri usciva dal fondo dello schermo**: appeso sotto un
   carosello alto 274 punti su 797, il tasto Avanti finiva fuori e il tocco non
   lo trovava. Adesso l'ingombro della carta si misura con un `TextPainter`
   prima di posarla, e il fumetto va dal lato che il corpus chiede se ci sta,
   dall'altro lato se ci sta quello, e in ogni caso resta dentro lo schermo.

Le cinque immagini sono in `docs/preview/primo-approdo-1.png` fino alla `-5`.

### La frase di accettazione della voce CB.02

**Cancella i dati dell'app e rifai l'onboarding: appena arrivi nel Cerchio
partono i cinque fumetti, il primo al centro e gli altri quattro con la freccia
sulla cosa di cui parlano. Da "Rivedi il primo approdo" nel menu' utente
tornano quando vuoi.**

## CB.03, il cambio dell'email dal menu' utente

**Origine dichiarata:** il 27 agosto il fondatore ha fatto una DOMANDA, "dal
menu' utente e' possibile cambiare email e password?". Il 29 l'ha resa ordine.

**La premessa era vera a meta', e la meta' falsa e' dichiarata sopra.** La
password si cambia dal menu' dall'ordine AZ voce 12, e si reimposta per email
dalla porta d'ingresso dall'ordine AZ voce 05. **Non esisteva il cambio
dell'email**: zero `updateEmail` e zero `verifyBeforeUpdateEmail` in tutto il
codice.

**Cosa c'e' adesso**: una voce nuova nel menu', `cambia_email`, che apre un
foglio solo, e un metodo nuovo sulla porta dell'identita' che passa da
`verifyBeforeUpdateEmail`.

**Perche' la verifica e non la scrittura secca, che e' la scelta che conta.**
Con `updateEmail` l'account si sposta subito sull'indirizzo scritto, anche su
uno sbagliato di una lettera: da quel momento la persona non entra piu' e non
recupera piu' la parola, perche' la via del recupero passa da quella stessa
casella. Con `verifyBeforeUpdateEmail` il messaggio va all'indirizzo NUOVO e
l'account cambia solo quando quel messaggio viene aperto: fino ad allora il
vecchio vale ancora. Un errore di battitura non porta via il Cerchio a nessuno.

**Il rosso, dimostrato**: sostituito `verifyBeforeUpdateEmail` con
`updateEmail`, verificato col `grep` che l'iniezione fosse avvenuta, la prova
e' diventata rossa dicendo "si scrive l'email nuova senza verificarla".

### La frase di accettazione della voce CB.03

**Entra con email e password, apri il menu' utente e tocca "Cambia la tua
email": scrivi un indirizzo nuovo e ti arriva li' un messaggio. Finche' non lo
apri, entri ancora con l'indirizzo di prima.**

## CB.04, le sette chiavi del collaudo

**La fonte non e' l'Architetto**: e' un collaudo indipendente del 28 agosto
2026, verdetto NON REGGE, che ha letto il codice. Il collaudo e' ANTERIORE
all'ordine BZ voce 01, che ha introdotto `CioCheETuo`, e stabilire se le sette
chiavi fossero dentro o fuori da quel lavoro era il primo compito della voce.

**L'esito: la premessa e' falsa, e nessuna delle sette sopravvive.** Non perche'
il collaudo fosse sciatto, ma perche' il lavoro fatto DOPO di lui l'ha resa
falsa: BZ.01 ha unito le due liste divergenti in una verita' sola, e quelle
sette chiavi ci sono finite dentro tutte.

### LA MISURA, PRIMA E DOPO, PER OGNI CHIAVE

Si scrivono le sette chiavi vere nelle preferenze, si chiama la via vera, si
conta cosa resta. Le tre vie che l'app espone finiscono tutte nella stessa
funzione, `DimenticanzaDelTelefono.dimentica`, che legge `CioCheETuo`.

| # | chiave del collaudo | prefisso che la copre | prima | dopo l'oblio | dopo l'azzeramento |
| --- | --- | --- | --- | --- | --- |
| 1 | `luogo.attuale` | `luogo.` | c'e' | non c'e' | non c'e' |
| 2 | `device.id` | `device.id` | c'e' | non c'e' | non c'e' |
| 3 | `filo.parola_del_giorno` | `filo.` | c'e' | non c'e' | non c'e' |
| 4 | `filo.domanda_di_medora` | `filo.` | c'e' | non c'e' | non c'e' |
| 5 | `avvisi.alba.giaChiesto` | `avvisi.` | c'e' | non c'e' | non c'e' |
| 6 | `maestro.welcome.rotation.medora` | `maestro.` | c'e' | non c'e' | non c'e' |
| 7 | `sunset_rune.settimana` | `sunset_rune` | c'e' | non c'e' | non c'e' |

**Sette su sette prima, zero su sette dopo**, su tutte e tre le vie: l'oblio
totale, l'azzeramento che tiene l'account, e `ProfileStore.clear()`.

**E cio' che non e' di nessuno resta in piedi**, misurato nello stesso giro:
`settings.` e `app_check_debug_token` sopravvivono, perche' dicono come e'
regolato il telefono e non chi lo usa.

**Il nono fatto del collaudo, verificato: vero.** `natal.chart.v1` non
sopravvive.

### L'OTTAVO FATTO, e la decisione che chiedeva

Il collaudo dichiara che `ProfileStore.clear()` e' cablato in un solo punto,
`lib/features/debug/app_check_debug_view.dart:127`, cioe' una vista di debug.
**E' vero, ed e' senza conseguenze.** `clear()` non ha una lista sua: chiama la
stessa dimenticanza che chiamano le vie vere. Non e' una porta che nessuno
apre, e' un altro nome della stessa porta. **Decisione: resta com'e'.** Toglierlo
non guadagnerebbe niente e romperebbe la vista di debug; dargli una lista
propria ricreerebbe esattamente la seconda verita' che BZ.01 ha eliminato.

### LA GUARDIA DI BZ.01 COPRE QUESTE CHIAVI, verificato

L'ordine chiedeva di controllarlo. `test/niente_resta_di_te_test.dart` non
elenca chiavi: legge tutti i file di `lib/`, trova ogni chiave che l'app scrive
o legge, e pretende che un prefisso la copra. Le sette ci finiscono dentro
perche' ci finisce dentro tutto. **La prova nuova aggiunge l'altra meta'**:
quella legge il codice, questa scrive le chiavi vere e misura cosa resta.

### La frase di accettazione della voce CB.04

**Cancella i tuoi dati dal menu' utente, poi riapri l'app: non c'e' piu' la
parola del giorno, non c'e' piu' la posizione, e i Maestri ti salutano come se
fosse la prima volta. Le impostazioni di grafica e movimento sono ancora le
tue.**

## CB.05, il limite di conservazione dei dati

**Parole del fondatore:** "sara' Code a decidere per quanto tempo ogni dato o
categoria di dati rimarra' memorizzato secondo il miglior rapporto
logica/costo, magari facendosi guidare dall'esperienza di altre app. decide
Code, non l'hai ancora capito? e chiaramente deve motivarlo."

**Il criterio applicato, dichiarato prima dei numeri.** Un dato si tiene finche'
vale piu' di quanto costa. Vale se qualcuno lo rilegge, se regge un conto, se
difende da un abuso. Costa in spazio, in righe da scorrere a ogni conto e in
superficie esposta: un dato che non c'e' piu' non si perde e non si ruba.

### IL CENSIMENTO, dove vive ogni cosa e quanto restava PRIMA

**Sul telefono**, `SharedPreferences`, ventotto prefissi governati da
`CioCheETuo`:

| categoria | cosa contiene | quanto restava | cosa la cancellava |
| --- | --- | --- | --- |
| profilo, nascita, carta natale | nome, giorno e ora di nascita, luogo, ruota | per sempre | solo la cancellazione |
| cammino, Sigilli, borsellino | gesti contati, traguardi accesi, saldo | per sempre | solo la cancellazione |
| letture del viso | fino a 40 letture con la loro data | per sempre, ma non piu' di 40 | solo la cancellazione |
| storico dell'Archetipo | fino a 40 test con la loro data | per sempre, ma non piu' di 40 | solo la cancellazione |
| coppie della Sinastria | i VIP confrontati | per sempre | solo la cancellazione |
| registro del borsellino | ultimi 8 movimenti | si limita da solo | solo la cancellazione |
| filo del giorno | parola e domanda di oggi | si riscrive ogni giorno | solo la cancellazione |
| interruttori | permesso chiesto, avviso proposto, ingresso fatto | per sempre | solo la cancellazione |

**Sul server**, Firestore in europe-west1:

| categoria | dove | quanto restava | cosa la cancellava |
| --- | --- | --- | --- |
| stato, borsellino, abbonamento | `users/{uid}/stato` | per sempre | `cancellaIlCerchio` |
| memoria dei Maestri | `users/{uid}/maestri/*/messages` | per sempre | `cancellaIlCerchio` |
| movimenti degli Eos | `users/{uid}/movimenti` | per sempre | `cancellaIlCerchio` |
| segni dei consumi | `users/{uid}/consumi` | per sempre | `cancellaIlCerchio` |
| impronte antifrode | `lapidi_del_benvenuto` | per sempre, per disegno | niente, e' dichiarato nella policy |
| perche' di chi se ne va | `congedi` | per sempre | niente, e' anonimo |
| codice del secondo fattore | `users/{uid}/stato/secondo_fattore` | **gia' scadeva**, 10 minuti | il documento va con l'account |

**La premessa P8 dell'ordine era falsa in un punto**, ed e' questo: il codice
del secondo fattore una scadenza ce l'aveva gia'.

### LE SCADENZE DECISE, con la ragione di ognuna

**Sul server**, `functions/src/scadenze.ts`, portate via da un lavoro notturno
alle 03:30 di Roma:

| categoria | quanto resta | perche' proprio quel tempo |
| --- | --- | --- |
| segni dei consumi | **30 giorni** | impediscono di pagare due volte lo stesso gesto, e un identificativo di movimento non torna mai dopo un mese |
| memoria dei Maestri | **12 mesi** | la memoria lunga e' il valore del prodotto e un Maestro che ricorda l'anno scorso vale; oltre l'anno nessuno rilegge e ogni messaggio pesa sul contesto |
| movimenti degli Eos | **24 mesi** | e' il registro con cui si spiega un saldo contestato, e due anni coprono ogni contestazione ragionevole; il saldo resta, perche' non e' storia |
| impronte antifrode | **24 mesi** | dopo due anni chi torna e' una persona nuova per davvero, e tenere un'impronta per sempre e' sproporzionato al fine |
| perche' di chi se ne va | **24 mesi** | si leggono a stagioni, e dopo due anni parlano di un'app che non esiste piu' |

**Sul telefono**, `lib/core/identity/scadenze_del_telefono.dart`, potate
all'apertura di quella memoria:

| categoria | quanto resta | perche' |
| --- | --- | --- |
| letture del viso | **24 mesi** | il gradino del volto che cambia guarda indietro un mese e il limite guarda l'oggi: due anni coprono ogni regola con margine, e la lettura del proprio volto e' un dato del corpo |
| storico dell'Archetipo | **24 mesi** | la regola del test guarda gli ultimi tre mesi e la scheda mostra l'ultimo: cio' che sta piu' indietro non lo apre nessuno |

### COSA NON SCADE, e non e' una dimenticanza

- **Cammino, Sigilli, borsellino, carta natale, profilo, coppie della
  Sinastria.** Non sono storia, sono cio' che la persona ha guadagnato o dato.
  Farli scadere vorrebbe dire togliere a qualcuno il suo lavoro mentre non
  guarda. Se ne vanno con la cancellazione, e solo con quella.
- **Gli interruttori** (`avvisi.`, `permesso.`, `onboarding.`, `device.id`).
  Non raccontano niente di nessuno, e scaderli farebbe solo ricomparire
  domande gia' fatte.
- **Gli account fermi da anni.** Ci ho pensato ed e' la decisione piu' delicata
  di questa voce: molte app cancellano chi non entra da due o tre anni.
  **Non l'ho fatto, e dichiaro perche'**: cancellare l'account di qualcuno
  senza avvisarlo prima e' inaccettabile, e il canale per avvisarlo, cioe'
  un'email di preavviso mandata dal server, oggi non esiste. Decidere una
  scadenza che non posso costruire sarebbe una promessa, e questo ordine
  chiede cose costruite. **Resta come proposta da ordinare**, insieme al
  canale che la rende onesta.

### LA POLICY DICE QUELLO CHE IL CODICE FA

La privacy policy vive dentro l'app dall'ordine BH voce 07 e diceva "Finche' il
tuo account vive", che da oggi non e' piu' vero. La sezione "Quanto li
conserviamo" adesso porta i tempi decisi, ed e' una prova a legarla al codice:
se un numero cambia in `scadenze.ts` e non cambia nella policy, la prova cade.

### La frase di accettazione della voce CB.05

**Apri il menu' utente, Privacy e dati, e leggi "Quanto li conserviamo": ci
sono i tempi veri, categoria per categoria, e sono gli stessi numeri che il
server usa per cancellare.**

## LE SCELTE CHE HO PRESO IO E PERCHE'

La REGOLA DUE chiede che ogni decisione lasciata a me sia scritta e motivata.

- **CB.04, `ProfileStore.clear()` resta com'e'.** E' vero che lo chiama solo
  la vista di debug, ed e' senza conseguenze: non ha una lista sua, chiama la
  stessa dimenticanza delle vie vere. Dargliene una propria ricreerebbe la
  seconda verita' che l'ordine BZ voce 01 ha appena eliminato.
- **CB.05, il criterio scelto: un dato si tiene finche' vale piu' di quanto
  costa.** Vale se qualcuno lo rilegge, se regge un conto, se difende da un
  abuso. Costa in spazio, in righe da scorrere e in superficie esposta.
- **CB.05, cio' che una persona ha guadagnato o dato non scade mai.** Cammino,
  Sigilli, borsellino, carta natale, profilo, coppie della Sinastria: farli
  scadere vorrebbe dire togliere a qualcuno il suo lavoro mentre non guarda.
- **CB.05, gli account fermi da anni NON si cancellano**, anche se molte app lo
  fanno. Cancellare senza avvisare prima e' inaccettabile, e il canale per
  avvisare, cioe' un'email di preavviso dal server, oggi non esiste. Decidere
  una scadenza che non posso costruire sarebbe una promessa, e quest'ordine
  chiede cose costruite.
- **CB.05, la pulizia del telefono si fa aprendo la memoria, non con un
  servizio all'avvio.** Quello e' l'unico momento in cui quella lista viene
  aperta davvero, e un servizio a parte farebbe lo stesso lavoro nell'istante
  in cui alla persona serve la scena.
- **CB.05, sul server e' un lavoro notturno con un tetto per giro.** Cancellare
  mentre qualcuno legge farebbe pagare a quella persona un lavoro che non le
  serve; un giro senza tetto morirebbe a meta' senza sapere dove.
- **CB.01, il prefisso `sogni.` resta nella cancellazione.** Il codice non
  scrive piu' quella chiave, ma i telefoni ce l'hanno: tenerlo e' l'unico modo
  perche' la cancellazione dica il vero anche a chi ha una build vecchia.
- **CB.01, i tre gradini dormono invece di sparire.** Toglierli dal corpus
  avrebbe cambiato il totale dei 165 e falsato ogni conto costruito su quello.
  Dormienti dichiarati e' la strada che questo progetto ha gia' scelto per tutto
  cio' che oggi non si puo' raggiungere.
- **CB.02, il tutorial non nasce acceso: si arma.** Una chiave lo innesca, e
  la scrive l'onboarding quando finisce. Se partisse dal solo "non l'ho mai
  visto", partirebbe anche sopra ogni prova e ogni anteprima, dove il disco e'
  sempre vuoto: e' la famiglia di guasti che questo progetto ha gia' pagato col
  provider preteso.
- **CB.02, i bersagli si iscrivono invece di essere cercati.** Un `GlobalKey`
  piantato dentro la barra sarebbe unico in tutto l'albero, e due Santuari
  montati insieme, cosa che le prove fanno, farebbero cadere l'app con una
  chiave duplicata.
- **CB.02, il fumetto sta dove ci sta, e se non ci sta da nessuna parte resta
  dentro lo schermo.** L'ingombro si misura col `TextPainter` prima di posare
  la carta. Al centro, come faceva la prima stesura, il fumetto dei Maestri
  copriva per intero i Maestri di cui parla.
- **CB.02, il comando per rivederlo sta nel menu' utente vicino al nome**, non
  dentro Privacy e dati: non e' un dato ne' una impostazione, e' la
  spiegazione dell'app. Al tocco riporta al Cerchio, perche' i cinque fumetti
  puntano cose che vivono solo li'.
- **CB.02, una zona non visibile non salta il fumetto**: la carta si mostra al
  centro senza freccia. Saltarlo lascerebbe un buco nel racconto, e puntare una
  freccia verso il nulla sarebbe peggio.
- **CB.03, il cambio email si mostra solo a chi entra con email e parola.** A
  chi entra con Google o con Apple l'indirizzo lo governa il fornitore: da qui
  si cambierebbe solo la copia di Firebase, e la stessa persona si ritroverebbe
  due indirizzi per lo stesso Cerchio. E' la regola gia' scelta per la parola.
- **CB.03, la riautenticazione non si chiede prima.** Chiederla a tutti
  costerebbe un gesto a chiunque per un caso che riguarda solo chi e' dentro da
  tanto: si prova, e se Firebase chiede un accesso recente si dice cosa fare.
- **CB.03, nessun tetto ai tentativi scritto da noi.** Il ritmo lo governa gia'
  Firebase: un secondo tetto nostro sarebbe un numero inventato che diverge dal
  primo il giorno che il primo cambia.
- **CB.03, il cancello dell'email diventa una funzione sola.** La regola stava
  scritta a mano dentro la registrazione: copiarla nel menu' avrebbe fatto due
  regole che il giorno dopo dicono cose diverse.
- **CB.01, il perche' del sonno viene dal generatore, non da una riga scritta a
  mano.** I tre gradini si sono addormentati da soli togliendo i due gesti
  dall'elenco di quelli vivi: il Dart e' la conseguenza del dato, come era gia'
  la sua legge.
