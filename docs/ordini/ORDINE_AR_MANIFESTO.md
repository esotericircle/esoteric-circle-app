# ORDINE AR. IL CIELO TORNA A MUOVERSI, E IL CAMMINO RINASCE

Dieci voci, da AR.01 ad AR.10. Ramo `claude/esoteric-circle-master-order-e798aj`,
verificato sulla testa `ad400d4` il 19 agosto 2026. La voce AR.10 e' la coda
che Mauro ha aggiunto a ordine gia' iniziato, e vive qui dentro.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: APERTA, CHIUSA,
FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE. Finche' una riga
e' APERTA la guardia `test/ordine_ar_guard_test.dart` resta rossa.
**AR.01 viene prima di tutto**: se non si chiude, le altre non si consegnano.

## La nota di metodo, e nasce da un rimprovero giusto

I FATTI MISURATI e le IPOTESI stanno in due elenchi separati. I fatti portano
il comando o il file e la riga con cui chiunque li rifa'. Le ipotesi sono
dichiarate tali e ognuna porta la misura che la conferma o la smentisce.
**Nessuna ipotesi va eseguita come se fosse una premessa vera**, e se una
misura smentisce l'Architetto si scrive nel rapporto e si prosegue sulla
causa vera.

## L'accensione, dichiarata in testa

**NESSUN TELEFONO SU QUESTA MACCHINA, e non per scelta.** Eseguito come chiede
la voce AR.09: `flutter doctor` dice Android toolchain a posto (SDK 36.1.0) e
"Connected device (3 available)", che sono Windows, Chrome ed Edge;
`flutter config --android-sdk` eseguito e accettato; `flutter devices` dopo il
config trova ancora zero dispositivi Android; e l'adb dell'SDK,
`platform-tools/adb.exe devices`, risponde con l'elenco VUOTO. Quindi nessun
telefono e' collegato, e le voci visive restano FERMATE IN ATTESA DI
DECISIONE: le chiude il collaudo di Mauro sulla 2186.

## I fatti misurati, rifatti qui

- **F1 CONFERMATO.** `git diff 69ff2d6..ad400d4 -- lib/core/motion/parallax_controller.dart`
  e' vuoto: zero righe. La formula e' quella approvata sulla 2181.
- **F3 CONFERMATO per misura.** Con tilt saturo la corsa vale polvere 30,0,
  fondo 80,0, medio 105,5, vicino 165,5: identica alla tabella dell'ordine,
  scarto zero.
- **F6 CONFERMATO come lettura del codice**, ma vedi la voce AR.01: non ha le
  conseguenze che l'ordine gli attribuiva.

## Il percorso del movimento e' congelato

**Da AR.01 in poi nessun ordine tocca `cosmos_background.dart` o
`parallax_controller.dart` senza misurare la corsa dei piani prima e dopo,
contro la tabella di F3, e scriverla nel rapporto.** La misura si rifa' con
`flutter test test/il_cielo_si_muove_davvero_test.dart`, che stampa i quattro
numeri.

## Il vincolo permanente, riportato come vuole l'ordine AO

**LA SCRITTA ESPLORA E IL SUO MENU' A SCOMPARSA NON SI TOCCANO.** Decisione di
Mauro del 17 agosto 2026.

## Le voci

- **AR.01** Il cielo si muove della corsa che gli spetta. Stato: FERMATA IN ATTESA DI DECISIONE
  (**LE MISURE, e due ipotesi dell'ordine sono cadute.** Nasce
  `test/il_cielo_si_muove_davvero_test.dart`, che risponde a due domande
  diverse: se la formula da' la corsa giusta, e se il cielo a schermo la usa.
  **La corsa e' esatta**: polvere 30,0, fondo 80,0, medio 105,5, vicino
  165,5, cioe' la tabella di F3 con scarto zero, e a mezza inclinazione
  esattamente la meta'.
  **I2 E' FALSA, e va detto perche' era il sospetto numero due.** Il `read` al
  posto del `watch` non impedisce il movimento: `_CosmosPainter` nasce con
  `super(repaint: Listenable.merge([animation, parallax]))` e ricalcola gli
  offset DENTRO `paint`, quindi ridipinge a ogni notifica del sensore anche
  senza ricostruire il widget. Misurato montando la scena vera: inclinando il
  controller dei provider cambiano 876 pixel su mille, e su quindici
  notifiche il cielo cambia quindici volte su quindici. **La prova del rosso
  chiesta dall'ordine, cioe' rimettere il `read`, NON scatta**, ed e' la
  dimostrazione che quella non era la causa.
  **Cade anche il sospetto del provider nullabile**: `context.watch` col tipo
  nullabile TROVA il controller registrato, misurato con la stessa prova.
  **I1 e I3 non sono misurabili senza telefono**, e per questo nasce cio' che
  l'ordine chiede: `lib/features/settings/riga_di_messa_a_punto.dart`, in
  fondo alle Impostazioni, dice "Sensore vivo" o "Sensore spento",
  l'inclinazione e quanti punti sta correndo il piano di fondo sugli 80
  attesi. Provata: da ferma dice 0,0 punti, a fondo corsa 80,0.
  **La cura che vale comunque**: senza sensore la deriva di ripiego valeva
  1,9 punti sul piano di fondo, cioe' il "si sposta di due millimetri";
  adesso, e SOLO quando `sensorActive` e' falso, usa un range di 250 con la
  stessa profondita' efficace della corsa, cioe' 40 punti sul fondo e 83 sul
  vicino. E le due domande hanno due nomi: `ascoltaIlSensore` non e' piu' lo
  stesso booleano che arma il giro lento.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo sulla 2186)
- **AR.02** I tre sentieri nascono dal dato. Stato: APERTA
  (165 voci VERBATIM da `docs/corpus/Traguardi_165_Revisione_B.json`, somma
  Eos 2.010 per sentiero e 6.030 in tutto)
- **AR.03** La legge e' provata, non promessa. Stato: APERTA
  (enumerazione a coppie: due traguardi non possono maturare sullo stesso
  gesto; scala, famiglie disgiunte, un gradino per gesto)
- **AR.04** La curva si misura, non si spera. Stato: APERTA
  (feste nella prima settimana, nel primo mese, nel primo trimestre, e i
  numeri vanno nel rapporto anche se sono brutti)
- **AR.05** I gradini dormienti sono dichiarati, non finti. Stato: APERTA
  (un dormiente non arma mai, non accredita mai, e la scala non si blocca)
- **AR.06** Il cammino riparte pulito, una volta sola. Stato: FERMATA IN ATTESA DI DECISIONE
  (nasce `lib/core/cammino/rinascita_del_cammino.dart`, la casa unica
  dell'azzeramento. **La generazione del cammino non e' la versione del
  formato**: quella dice come sono fatti i campi, questa quale CAMMINO si sta
  percorrendo, e oggi vale due. Le chiavi si cancellano PER NOME e non per
  prefisso: un `removeWhere` su "cammino." avrebbe portato via anche la
  generazione stessa, e il giorno che qualcuno mettesse il saldo sotto quel
  prefisso lo avrebbe portato via in silenzio.
  **IL SALDO EOS NON SI AZZERA**, e la chiave `allowance.saldoEos` e' nominata
  nel codice come quella che resta, con due prove che la difendono: una sul
  comportamento e una sul DATO, cosi' cade anche chi la aggiungesse
  all'elenco senza far girare niente.
  **Il diario svuota anche la MEMORIA**: cancellare le chiavi e lasciare i
  conti vivi dentro l'oggetto li avrebbe riscritti tali e quali al primo
  salvataggio.
  **Il server dimentica PRIMA di fondere**, e l'ordine dei due passi e'
  sorvegliato da una prova che legge `cerchio.ts`: la fusione difende sempre
  il numero piu' alto, quindi fondere e poi dimenticare avrebbe riportato
  indietro il cammino vecchio tutto intero. L'azzeramento viaggia dentro
  `statoDelCerchio`, che parte gia' a ogni apertura: **nessuna callable
  nuova**, e la premessa P4 dell'ordine AP resta intatta.
  La riga onesta e' un foglio dal basso in tono di Maestro, mai una SnackBar,
  mostrato una volta sola e mai a un Cerchio nuovo, che di quella perdita non
  ha nulla da sapere.
  Sette prove, e i TRE rossi chiesti dall'ordine provati uno per uno. Uno di
  quei rossi non scattava, e il difetto era nella prova: chiedeva a lib quali
  chiavi controllare, quindi togliendone una non la cercava piu'. Adesso
  l'elenco della prova e' suo.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo sulla 2186)
- **AR.07** "Il prossimo" mostra il prossimo. Stato: FERMATA IN ATTESA DI DECISIONE
  (**la causa non era la scheda, era il momento.** La festa si apre
  nell'istante in cui il traguardo matura, e la ricerca del "primo non
  acceso" trovava proprio lui se l'accensione non era ancora arrivata al
  diario. La cura non prova a mettere in fila due eventi asincroni, che e' la
  famiglia di difetti piu' cara di questo progetto: `prossimoDi` prende
  `escludendo`, la scena le passa gli id che sta celebrando, e la risposta
  smette di dipendere dall'ordine di arrivo.
  **Con la festa unita il prossimo e' quello del sentiero della FESTA**, cioe'
  del traguardo piu' importante fra i celebrati: e' la stessa regola con cui
  la scena sceglie Maestro e intensita' (ordine AO voce 05), e prima si
  prendeva `sentieri.first`, che segue l'ordine in cui i traguardi sono
  dichiarati. A sentiero finito non si annuncia nessun prossimo, invece di
  ripetere l'ultimo.
  Guardia `test/il_prossimo_e_il_prossimo_test.dart` con cinque prove, la
  prima delle quali riproduce il difetto prima di curarlo. Rosso provato
  togliendo l'esclusione dalla scena.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo sulla 2186)
- **AR.08** I testi seguono i nomi nuovi. Stato: APERTA
  (ogni posto prende il nome dal dato, e una prova cade se un nome vecchio
  sopravvive)
- **AR.09** Il manifesto, la suite, l'accensione e la build 2186. Stato: APERTA
  (stati veri; suite intera una volta; numero a 2186; l'accensione non si
  salta e il suo esito va in testa)
- **AR.10** La barra sottile si semplifica. Stato: APERTA
  (coda di Mauro del 19 agosto, che supera due sue decisioni precedenti: via
  il nome, via l'apertura, un solo stato da 30 punti, e i tre bersagli
  navigano al PRIMO tocco)

## I marcatori, contati sulle righe

VOCI_TOTALI: 10
VOCI_APERTE: 7
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 3
