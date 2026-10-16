# Il titolo e il formato del responso

Ordine FK, aggiunta voci A1, A2 e A6, 11 ottobre 2026.

Questo documento sta nel ramo perché Code lo legga: fino all'ordine FK le
parole del fondatore sul titolo vivevano in due file del Project
(`Richieste_Verbatim_Aggiunte_2026-09-03` e `..._2026-09-11`) che Code non
raggiunge: arrivavano dentro gli ordini una funzione per volta. Il
riversamento di quei due file nel documento madre del Project spetta
all'Architetto (FK.A6). Qui ci sono le parole, la regola e dove vive nel codice.

## Le parole del fondatore, per intero

3 settembre 2026:

> le risposte devono partire con un titolo diretto che riassume tutto, un
> titolo che a colpo d'occhio è già una risposta diretta e poi sotto la
> risposta vera. è importante il concetto base: l'utente cerca prima di tutto
> risposte o una guida e se deve fare un rito deve sapere a che scopo, cosa
> ottiene... poi, giustamente, è giusto informarlo come è stata estratta questa
> parola e, informarlo dei transiti, pianeti, ecc perché deve sapere la fonte
> perché nulla viene inventato. ma questo in forma breve e verso la fine.
> quindi ogni risposta deve avere una gerarchia a partire dal titolo.

11 settembre 2026:

> titolo accattivante che riassume la risposta, poi la risposta descrittiva
> diretta e immediata, chiara e non criptica, divisa in paragrafi.

11 ottobre 2026:

> non si parla di righe ma di paragrafi... ti avevo anche indicato che ogni
> risposta doveva partire da un titolo.

> Prendi spunto dalle risposte dell'oroscopo come formattazione: 3 paragrafi,
> il secondo è evidenziato in riquadro e solo alla fine un piccolo paragrafo in
> corsivo 'da dove viene'.

> Nei tarocchi c'è anche la bolla per ogni carta e va bene, ognuno col titolo.

## La regola del titolo

1. Ogni responso parte da un titolo.
2. Il titolo è già la risposta: chi legge solo il titolo sa che cosa dice la
   lettura. Non è il nome dell'arte e non è il nome del simbolo da solo (il
   simbolo non apre mai, Linee Guida sezione 2).
3. Sotto il titolo viene la risposta vera, diretta e chiara, divisa in
   paragrafi.
4. Da dove viene la lettura (come è stata estratta, i transiti, la fonte) sta
   in fondo, in forma breve.

## Il formato del responso

Preso dall'Oroscopo vero, `lib/features/horoscope/oroscopo_screen.dart`:

- il titolo, che è la risposta a colpo d'occhio;
- tre paragrafi, non tre righe: la risposta, cosa puoi fare, poi lo sviluppo
  (per i tarocchi, come le carte si legano);
- il secondo paragrafo in un riquadro, `RiquadroInEvidenza`, lo stesso fondo
  appena dorato col filo d'oro dell'Oroscopo;
- alla fine un paragrafo piccolo, in corsivo, con l'etichetta "Da dove viene".

Nell'Oroscopo la Lunga ha quattro paragrafi e il riquadro sta sul terzo
(il fondatore, 1 ottobre 2026): quella regola resta. Il formato a tre
paragrafi col secondo nel riquadro è quello dell'11 ottobre: si applica dove
il responso ha tre paragrafi.

## Dove vive nel codice

- La regola e le parole: `lib/core/responsi/il_titolo_del_responso.dart`.
- Il titolo: `TitoloDelResponso`,
  `lib/design_system/components/titolo_del_responso.dart`. Ogni arte con un
  responso (`ArtiConResponso.tutte`) disegna il suo titolo da qui, direttamente
  o attraverso una porta dichiarata in `IlTitoloDelResponso.porte`.
- Il formato in tre paragrafi: `ResponsoInTreParagrafi`,
  `lib/design_system/components/il_responso_in_tre_paragrafi.dart`.
- La guardia: `test/ogni_responso_parte_dal_titolo_test.dart`, che enumera le
  arti e cade col nome di quella che non parte dal titolo comune; pretende anche
  che questo documento porti le parole del fondatore uguali a quelle del
  codice.
