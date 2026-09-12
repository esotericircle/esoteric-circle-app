# ESITO: NIENTE SI DISEGNA SENZA POTER DIRE DOV'ERA

## L'ipotesi era giusta, e la causa strutturale e' piu' larga

Verificata prima di correggere, come nell'ordine precedente dove l'ipotesi era
sbagliata. Qui **regge**, ma il difetto non e' un ramo di ripiego che tace: e'
che **la SELEZIONE dei corpi e la loro SCHEDA leggono due fonti diverse.**

- La selezione viene da `NightSky.constellationsHighTonight`, che ricava le
  figure all'opposizione dalla longitudine del Sole: un calcolo **simbolico**,
  che non guarda l'orizzonte.
- La scheda le cerca nell'**istantanea vera**, proiettata sull'orizzonte del
  luogo.

Quando una figura scelta ha tutte le stelle sotto il suolo non compare
nell'istantanea, il ciclo non la trova, e il metodo tornava **nullo**: la figura
veniva disegnata lo stesso, perche' gli slot vanno riempiti, e restava muta.

**La misura**, dal luogo dichiarato nel pannello Fonti, 45,6736 e 8,8348:

| istante | selezione | nell'istantanea |
|---|---|---|
| 6 luglio 1975, 9:30 | Gemelli, Cancro, Toro | 32,2 / 14,1 / 54,6 gradi |
| 15 giugno 1990, 14:30 | Leone, Vergine, Cancro | 34,5 / **meno 1,4** / 48,0 |

La Luna dello stesso istante del 1990 e' del tutto sotto il suolo, e veniva
disegnata anche lei.

## La strada scelta: la (b), e il perche' in una riga

**Il corpo compare e dichiara che era sotto, con l'ora in cui sorge.** Con slot
fissi la strada (a) lascerebbe un buco o promuoverebbe un corpo diverso da
quello che il cielo ha davvero all'opposizione, e la schermata perderebbe
proprio la figura di cui la persona e' venuta a leggere.

### Cosa NON ho fatto, e lo dichiaro

La strada (b) parlava anche di mostrare il corpo **velato, spento, sotto una
linea d'orizzonte**. **Ho fatto la dichiarazione, non il velo**: la Luna del
1975 compare piena luce in alto e la sua scheda dice che quella notte era sotto
l'orizzonte. La regola dell'ordine e' soddisfatta, perche' il corpo dichiara
dov'era, ma il segno visivo manca e senza toccare la scheda non si vede.

Resta aperto in RIPRESA.md come voce a se': e' una modifica al disegno, e non la
apro a meta' in coda a questa.

## L'ora di sorgere, che il motore non sapeva calcolare

L'ordine la dava per gia' disponibile: **non lo era.** Ho aggiunto `quandoSorge`
in `sky.dart`, che cerca l'attraversamento dell'orizzonte nelle ventiquattro ore
successive, a passi di dieci minuti e poi al minuto. Torna nullo se il corpo non
sorge affatto, e in quel caso la dichiarazione resta senza ora invece di
inventarla.

## Dove vive la regola, e le porte

**Vive in `testoDellaScheda` e `sottoLOrizzonte`, funzioni di PRIMO LIVELLO** in
`sky_overview_screen.dart`. Prima stavano dentro `_SkyBody`, una classe privata:
**una regola chiusa in una classe che nessuno puo' nominare non e' provabile, e
quello che non si prova torna.** Per la stessa ragione ne e' uscita anche
`direzione`.

**LE PORTE SONO DUE, e le ho enumerate invece di visitarle**: il cielo di
stanotte e il cielo di nascita sono la **stessa classe** con `birth` vero o
falso, quindi passano tutte e due per la stessa funzione. Non ci sono due
correzioni gemelle: c'e' una funzione sola che le serve entrambe, e il parametro
`birth` decide solo come si declina la frase. La prova enumera **tutti e due**.

**E' la quindicesima volta.** La forma e' sempre quella: una regola vale per la
porta da cui e' arrivata la segnalazione, e non per l'altra.

## Il pannello Fonti e metodo nel cielo di nascita

**C'e' gia', verificato**: il pulsante sta nell'AppBar senza condizione su
`birth`, e il contenuto legge `cielo.istanteLocale`, che nel cielo di nascita e'
l'istante di nascita. Non serviva aggiungerlo, serviva guardarlo.

## L'ora di riferimento non e' piu' "a mezzanotte" per tutti

`aCheOra` e' il punto solo che la decide: **"a mezzanotte"** per il cielo di
stanotte, **"alla tua ora di nascita"** per quello di nascita. Prima la riga
diceva "a mezzanotte" anche nel cielo di nascita, dove non era vero: la
correzione della voce precedente aveva sistemato una porta sola. Sedicesima
occorrenza, trovata mentre chiudevo la quindicesima.

## Le prove

Cinque, e **non guardano l'Ariete**: enumerano tutti i corpi di tutti e due i
cieli, e una passa **un anno intero** a undici giorni di distanza. Pretendono
gradi e direzione, oppure la dichiarazione esplicita che il corpo stava sotto,
e che chi da' un numero dica anche a che ora.

**Prova di vista fatta**: rimesso il `return null` di prima, la prova sull'anno
cade con *"Bilancia viene disegnato e la sua scheda non dice niente"*.
**Lo dichiaro perche' e' importante**: i due casi singoli, il 1990 e la
mezzanotte del 2026, restano VERDI anche col difetto dentro, perche' in quei due
istanti nessuna figura era del tutto assente. **Sono l'enumerazione e l'anno a
prendere il difetto, non l'istante scelto bene.**

Una prova l'ho scritta male e me l'ha detto lei: cercavo l'attraversamento
dell'orizzonte sulla Vergine del 1990, che sta a meno 1,4 gradi, cioe' SOPRA la
soglia. Ora il caso lo cerca la prova, invece di fidarsi di quello che credevo.

## La frase di accettazione

**Apri "Il tuo cielo di nascita" e tocca una figura qualunque: o ti dice quanti
gradi, in che direzione e a che ora, oppure ti dice che quella notte era sotto
l'orizzonte e a che ora sorse. Nessuna figura mostra il solo nome.**
