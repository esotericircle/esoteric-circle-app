# ESITO: IL CIELO IN TEMPO REALE E LA POSIZIONE

## La catena, anello per anello

L'ordine chiede dove si spezza. Si spezzava al **quarto**, quello dichiarato
come piu' sospetto, e per il motivo esatto che l'ordine sospettava.

1. **Il permesso e le coordinate: REGGE.** La sorgente restituisce i numeri.
2. **Le coordinate al controller: REGGE.** Arrivano in `_place`.
3. **Il passaggio al motore: REGGE.** `_calcolaCielo` chiama `buildSkyFor` con
   quelle coordinate, e il risultato finisce in `_cielo`.
4. **Dal calcolo al pixel: SI SPEZZAVA QUI.** I corpi ricevevano `slot`, una
   costante grafica normalizzata: `_moonSlot = Offset(0.5, 0.13)` e tre
   `_highSlots` fissi. Il cielo calcolato entrava solo in `datoDiAdesso`, cioe'
   nel TESTO della scheda che si apre toccando un corpo. **La posizione cambiava
   la didascalia e non dove le cose stanno.** Concedere il permesso non poteva
   cambiare la scena, perche' non c'era niente che potesse cambiarla.
5. **Il ridisegno: REGGE.** `setState` c'era e faceva il suo lavoro.

**La misura del difetto**: da Milano e da Sydney, allo stesso istante, la scena
differiva per **zero pixel**.

## La correzione

I corpi si posizionano da altezza e azimut reali: `postoNelCielo` converte i
gradi in coordinate di schermo rispetto al centro della veduta, e chi sta sotto
l'orizzonte non si disegna affatto. Le costellazioni prendono il posto dalla
loro stella piu' luminosa sopra l'orizzonte.

## La prova, e i TRE modi in cui e' nata cieca

Vale la pena scriverli, perche' sono la parte piu' istruttiva del lavoro.

1. **Passavo un istante fisso.** La schermata chiede la posizione solo quando il
   momento e' l'adesso reale: con `now` valorizzato non la chiedeva, e la prova
   contava zero pixel per il motivo sbagliato.
2. **Confrontavo l'intera scena.** Cambiano anche il banner e le didascalie,
   quindi la prova restava verde pure coi corpi inchiodati.
3. **Confrontavo la posizione ASSOLUTA di un corpo.** La camera della parallasse
   sposta tutta la scena insieme, e produceva decine di punti di scarto senza
   che l'astronomia c'entrasse.

La misura che regge confronta le **distanze fra coppie di corpi**: sono
invarianti rispetto alla camera e cambiano solo se il cielo e' stato
ricalcolato. **Prova di vista passata**: rimessi gli slot fissi, cade.

Ho dovuto aggiungere alla schermata un `luogoIniziale`: senza, il luogo entrava
in un modo solo, il dialogo di consenso, che richiede un tocco. Un dato
ottenibile solo con una mano umana e' un dato che nessuna misura raggiunge, ed
e' il motivo per cui questo difetto e' vissuto indisturbato.

## Il fuso orario: corretto, e resta un residuo che dichiaro

La conversione da ora civile a UT usava il tempo medio locale, `lon / 15 * 60`,
mentre chi chiama passa l'ora civile: ventiquattro minuti d'errore d'inverno e
ottantaquattro d'estate, cioe' fino a ventuno gradi di rotazione della volta.
Adesso usa il fuso vero dell'istante.

**Il residuo, misurato**: la prova che chiedeva lo stesso cielo per lo stesso
istante scritto in UTC e in ora civile cade lo stesso, con uno scarto di **123,7
gradi di azimut**. Oltre alla conversione c'e' dell'altro che guarda l'ora locale
grezza. Non l'ho inseguito, non lascio una prova rossa in suite, e il numero sta
in `RIPRESA.md` come punto da cui ripartire.

## La Ronda

Il Cielo del momento entra nello Strato a schermo. I motori sorvegliati solo
sulla funzione pura scendono da ventidue a ventuno.
