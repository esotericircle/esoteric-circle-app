# SENZA RETE, la scelta dichiarata

Ordine N, voce 2e. Una scelta dichiarata vale, una scelta implicita no: questo
documento dice cosa si puo' fare senza rete, cosa si sospende e come si
riconcilia al ritorno. Le stesse righe stanno accanto al codice, in
`lib/core/entitlement/question_allowance.dart` e in
`lib/services/memory/firestore_maestro_memory_repository.dart`.

## Il principio

Il Cerchio si apre e si usa anche in metropolitana. Cio' che si sospende senza
rete e' solo cio' che, fatto al buio, farebbe **perdere denaro alla persona o
al progetto**: il resto continua, e il server ha l'ultima parola quando la
rete torna.

## Cosa si puo' fare senza rete

- **Aprire l'app, la home, il cielo, le Arti.** Il cielo e' calcolato in
  locale, la carta natale e' conservata sul dispositivo.
- **I riti del giorno**: Rito dell'Alba, Runa del Tramonto, Soffio, Sogno.
  Sono calcolo locale e corpus, non chiedono niente a nessuno.
- **Le gettate di rune e le altre arti a budget.** Il gesto si compie, il
  conto locale cala, e il consumo si mette in coda col suo identificativo.
- **Leggere la memoria dei Maestri** gia' scaricata: le letture di Firestore
  passano dalla cache, che l'SDK tiene per conto suo.
- **Ricevere le chiamate del giorno**: sono avvisi locali, programmati dal
  dispositivo, non da un servizio remoto.

## Cosa si sospende

- **Le risposte dei Maestri**, che vivono su Gemini: senza rete non c'e'
  nessuna voce, e l'app lo dice invece di inventare.
- **Spendere Eos.** Il saldo e' denaro: non si anticipa al buio. Chi prova a
  spendere senza rete riceve un no chiaro, non un forse.
- **La custodia dell'account** (Google, Apple, email): tutte e tre passano dal
  fornitore, e senza rete non si possono nemmeno cominciare.
- **L'oblio**: cancellare a meta' e' peggio che non cancellare. Si aspetta la
  rete e si dichiara.

## Come si riconcilia al ritorno

1. **Ogni gesto ha il suo identificativo.** Un consumo accodato porta con se'
   una stringa unica; il server tiene il segno di ogni identificativo gia'
   visto e, se lo rivede, ripete la risposta di allora senza contare due
   volte. E' cio' che rende innocuo ogni ritentativo.
2. **La coda parte in ordine e si ferma al primo che non passa.** Mandare un
   gesto fuori ordine cambierebbe chi ha esaurito cosa.
3. **In caso di disaccordo vince il server, sempre.** Se mentre si era offline
   il budget era gia' finito (per esempio da un altro telefono con lo stesso
   account), al ritorno il server dice di no e il conto locale si allinea al
   suo, anche quando questo vuol dire togliere qualcosa che il telefono si era
   gia' preso. La persona non paga nulla per quel gesto: lo ha gia' fatto.
4. **Le scritture della memoria si accodano in RAM** e partono alla prima che
   riesce. Se l'app muore prima del ritorno della rete, quei turni non sono
   ricordati: e' la perdita dichiarata, e si preferisce a un turno scritto sul
   telefono che il server non conoscera' mai.
5. **Il giorno resta quello dell'ultima risposta del server** finche' il
   server non ne dice un altro. L'orologio del dispositivo non fa piu'
   ribaltare niente: se non si e' mai parlato col server (primo avvio senza
   rete) vale il ripiego locale, che e' meglio di un'app che non conta nulla.

## Cosa NON si fa, e perche'

- **Non si scrive dritto su Firestore** nemmeno quando sarebbe comodo: le
  regole lo vietano e la comodita' di oggi e' il limite decorativo di domani.
- **Non si inventa un giorno nuovo** perche' l'orologio dice che e' passata la
  mezzanotte: era esattamente il modo di azzerare i contatori spostando l'ora.
- **Non si mostra un saldo diverso da quello del server**: il numero che si
  vede senza rete e' l'ultimo che il server ha detto, non una stima.
