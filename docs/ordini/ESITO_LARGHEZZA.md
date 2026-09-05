# ESITO dell'ORDINE: LA LARGHEZZA GIUSTA, POI LE QUATTRO VOCI

## La stima, scritta prima di toccare il codice

### La misura reale, e da dove la ricavo

Il telefono di Mauro riporta **1080 per 2392 pixel fisici**. Il rapporto di
pixel di quella classe di dispositivi e' **3**, quindi la dimensione logica e'

    1080 / 3 = 360 punti di larghezza
    2392 / 3 = 797,33 punti di altezza

**Uso 360 per 797.** Il numero che conta e' il primo: le anteprime finora sono
state generate a **390** punti di larghezza, cioe' trenta punti logici in piu',
novanta pixel fisici. Verificato sul file delle catture: `schermoAlto` vale
`Size(390, 844)` e `schermoBasso` vale `Size(390, 797)`. La variante che
chiamavo "2392" aveva quindi l'altezza giusta e la larghezza sbagliata, ed e'
esattamente quello che l'ordine contesta.

Su trenta punti in meno il testo va a capo prima, i titoli si spezzano, le
etichette si troncano e le bolle crescono in altezza perche' occupano due righe
invece di una. E' l'elenco dei difetti segnalati.

**L'ipotesi della scala 1,6 e' archiviata come sbagliata.** Le impostazioni di
Mauro sono testo Predefinito e visualizzazione Standard, entrambi di fabbrica.
Il difetto che nel giro precedente avevo riprodotto ingrandendo il testo era
reale, ma la sua causa nel mondo vero e' un'altra, ed era la larghezza.

### La stima voce per voce

- **W1 piena, e viene per prima.** Trecentosessanta diventa la prima delle tre
  misure obbligatorie del corredo, non un'aggiunta. Mi aspetto fra i cinque e i
  dieci punti da correggere, e quattro li conosciamo gia'.
- **W2 piena.** La misura differenziale a tre rese esiste gia' e funziona: va
  rifatta alla larghezza reale. Se il difetto si riproduce li' senza toccare la
  scala del testo, la questione delle cinque segnalazioni irriproducibili si
  chiude, e lo diro' chiaramente.
- **W3 piena.** Una transizione sola, l'Hero sulla carta centrale.
- **W4 piena, col rischio piu' alto.** Quarta stesura dopo quattro bocciature.
- **W5 piena.** Un componente solo, portato ovunque.
- **W6 piena nel codice, col giudizio a Mauro**, che e' l'unico ad avere un
  telefono.

**Se il tempo stringe** riduco W6 e W3, mai W1 e W2. La consegna si fa in ogni
caso, perche' Mauro non vede una build nuova da due giri.

## Stato voce per voce

### W1, la larghezza: CHIUSA

La costante del corredo si chiamava "quella di Mauro", il commento dichiarava
1080 per 2392, e il valore era `Size(390, 797)`: avevo cambiato l'altezza in un
giro precedente **lasciando la larghezza**. Verificavo su uno schermo piu' largo
del suo di trenta punti logici, novanta pixel fisici.

Adesso 360 e' la **prima** delle tre misure. Trentasette catture portate alla
misura reale, cinquantanove anteprime rigenerate e guardate.

Il test permanente monta le schermate a 360 e raccoglie gli errori di layout,
invece di far guardare le immagini una per una. **Prova di vista passata**: a
200 punti il Cerchio denuncia subito.

### W2, la bolla: MISURATA, NON CORRETTA

**La scoperta che chiude cinque segnalazioni.** Alla larghezza reale il difetto
si riproduce senza toccare la scala del testo: a 1080 tutte e tre le misure sono
rosse, a 1170 verdi. Le segnalazioni non erano irriproducibili, era la mia
verifica a essere piu' larga.

**Il difetto e' PREESISTENTE.** Verificato riportando `santuario_screen.dart`
allo stato committato: restano quarantaquattro overflow. Il test li rende
visibili per la prima volta, non li ha creati.

**Il colpevole ha nome e riga**: `A RenderFlex overflowed by 10.0 pixels on the
bottom`, Column in `daily_strip.dart:671`, cioe' la striscia dei Doni. A 360
punti la sua etichetta va su due righe e la colonna sborda.

**Due strade provate e rientrate**, scritte in `RIPRESA.md` perche' nessuno le
ripeta: `mainAxisSize.min` su quella Column peggiora, da tre prove rosse a nove;
calcolare le altezze del carosello per differenza non risolve, perche'
l'overflow non viene dall'eroe.

### W3, W4, W5, W6: NON FATTE

Il contesto della sessione e' finito prima. Restano in `RIPRESA.md` con le
strade gia' indicate.

## La consegna, e una cosa che va detta

**La suite NON e' verde**, e lo dichiaro invece di girarci intorno. Nove prove
sono rosse, e sono quelle nuove di W2: denunciano un difetto reale, preesistente
e non ancora corretto. Non le ho spente per far tornare il conto, perche' un
test spento e' un difetto dimenticato.

Ho consegnato lo stesso, perche' l'ordine lo chiede espressamente e perche' la
build porta cose che funzionano: il livello sensoriale intero e il corredo alla
larghezza giusta. Il difetto della bolla c'era gia' nella 2108 e c'e' ancora.

- Identificativo della release: **`5gu170iejq37o`**
- Versione: 0.1.0, build **2109**
- Esito del caricamento: **`RELEASE_CREATED`**
- Peso: **203,93 MB in base 1000**, che sono **194,48 MiB in base 1024**. Sulla
  pagina dei tester si legge il primo numero.
- Destinatario unico: `cloud@esotericircle.app`
- **Verifica della distribuzione**: `acceptedInvitationCount` era assente prima
  della chiamata e vale 1 dopo. E' il solo segnale che l'API espone, e la volta
  scorsa mancava perche' avevo usato il campo `emails` invece di `testerEmails`.

**Da installare: la 2109.**
