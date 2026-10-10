# ESITO: LE ANTEPRIME DIMENTICATE, E I TRE DIFETTI CHE SI VEDONO SOLO A 360

## La stima, scritta prima di toccare il codice

Restano aperte dall'ordine precedente **V1, V2, V3, V4 e S4**, e vanno prima.
Poi X1..X4. Dichiaro qui l'ordine in cui lavoro e cosa mi aspetto.

### Quello che faccio per primo, e perche'

**X1 sale in cima**, prima ancora di V1. Non per importanza, per dipendenza:
finche' esiste una seconda porta che genera anteprime fuori dalle tre misure, ogni
verifica visiva che faccio su V1, V2, V3 e X2 puo' guardare un'immagine alla
larghezza sbagliata. Correggere la porta prima significa che tutto il resto del
lavoro si vede davvero.

E' la settima volta che incontro la stessa forma, e stavolta la conto: **una
regola messa in una porta quando le porte sono due**. Il nome minuscolo, il
limite delle domande, la parola "vocativo", il colore del Maestro, la nomenclatura
lunare, i participi con la virgola, e adesso le anteprime.

### La stima voce per voce

- **X1 piena.** Dodici anteprime da rigenerare e guardare, piu' la seconda porta
  da chiudere. La regola va nel DATO: un test che enumera le catture e cade se
  una non dichiara la misura reale. Prova di vista obbligatoria.
- **X2 piena, con una decisione da dichiarare.** Fra stringere le carte e fare
  una sbirciatura regolare, scelgo di dichiararlo dopo aver guardato l'anteprima
  nuova: la scelta giusta dipende da quanto sporge oggi. Quello che non faccio e'
  lasciare un taglio che dipende dalla larghezza.
- **X3 piena, e insieme a V1.** L'ordine lo dice e ha ragione: la striscia dei
  Doni e' lo stesso file dell'overflow che ho gia' diagnosticato in V1,
  `daily_strip.dart:671`. Due passate sullo stesso file sarebbero due occasioni
  di rompere.
- **X4 non e' ancora una voce.** Guardo l'immagine nuova e poi dico se il difetto
  esiste. Se i quadratini spariscono chiudo senza toccare codice, e lo scrivo.
  Non attribuisco una causa prima di aver guardato.
- **V1 piena**, con la diagnosi gia' fatta e due strade gia' rientrate, scritte
  in `RIPRESA.md`.
- **V2 piena, col rischio piu' alto**: quattro bocciature.
- **V3 e V4 piene.**
- **S4 in versione semplice gia' dichiarata**: una transizione sola.

**Se il tempo stringe**, per ultime V4 e S4. Mai X1, perche' e' quella che rende
vere tutte le altre verifiche.

## Stato voce per voce

### X1, le dodici anteprime: CHIUSA

**Le cause erano tre, e nessuna era "mi sono dimenticato".**

1. **Una seconda porta.** `mano_anteprima_test.dart` scriveva dritto in
   `docs/preview` senza passare dal corredo. E' la settima volta che incontro
   questa forma, e stavolta l'ho contata. La cattura e' entrata nel corredo e il
   file separato non esiste piu'.
2. **Anteprime orfane.** Nate da prove temporanee poi cancellate: nessuno le
   rigenerava. `le-tue-arti.png` era ancora a 390 per 844, uno schermo che non
   esiste.
3. **Due catture rotte, e questa l'ho introdotta io con S1.** Da quando il
   lettore audio reale e' il default, aprire la Meditazione tenta di riprodurre
   e in prova il plugin non c'e': la cattura cadeva e l'anteprima smetteva di
   aggiornarsi **in silenzio**. E' il difetto peggiore dei tre, perche' non si
   annuncia.

La regola sta nel DATO: un test enumera le catture e cade se una non parte dalla
misura reale, se qualcuno scrive fuori dal corredo, o se un'anteprima non ha un
generatore. **Prova di vista passata**: rimessa una cattura a 390, il test la
denuncia col numero di riga.

### X4, i quadratini: NON ERA UN DIFETTO

Guardata l'anteprima nuova come chiede l'ordine, prima di attribuire qualunque
causa: le icone si disegnano tutte, la matita, le scintille, il cuore, le carte,
la meditazione, il dado runico e le frecce.

I quadratini erano l'anteprima **vecchia**, prodotta dal test temporaneo che non
caricava i font delle icone. **Chiuso senza toccare codice.**

### X2, X3, V1, V2, V3, V4, S4: NON FATTE

Il contesto della sessione e' finito prima. Stanno in `RIPRESA.md` con le strade
gia' indicate.

### Una cosa trovata che non era nell'ordine

La cattura "Stesa in corso" cade a 360 con *the widget is actually off-screen*:
e' un difetto vero della Stesa alla larghezza reale, che a 390 non si vedeva.

## La consegna

**Non fatta in questa sessione.** La suite non e' stata letta e restano aperte
sei voci: consegnare adesso vorrebbe dire consegnare senza verifica, che e' la
cosa che l'ordine vieta espressamente.
