# ORDINE AR. IL CIELO TORNA A MUOVERSI, E IL CAMMINO RINASCE

Undici voci, da AR.01 ad AR.11. Ramo `claude/esoteric-circle-master-order-e798aj`,
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
- **AR.10** La barra sottile si semplifica. Stato: FERMATA IN ATTESA DI DECISIONE
  (**via il nome e via l'apertura**, e sono due decisioni di Mauro che ne
  superano due sue precedenti, scritte accanto al codice: il nome accanto al
  volto veniva dall'ordine AN voce 02, il ritiro automatico dall'ordine AO
  voce 02. La barra ha UN solo stato, trenta punti; spariscono lo stato
  esteso, la transizione, la vista dei tre eventi dentro la barra e **i due
  ascoltatori che vivevano sopra tutta l'app** per ritirarla: senza uno stato
  aperto non c'e' piu' niente da ritirare, e ogni tocco e ogni scorrimento
  smettono di passare di li'.
  **I tre bersagli portano dove devono al PRIMO tocco**: volto all'account,
  "Eventi Cosmici" al Calendario, borsellino al borsellino. Il volto riceve
  la via dall'osservatore della pila e non da `Navigator.of`, perche' la
  barra vive nel `builder` di `MaterialApp`, che AVVOLGE il Navigator: e' il
  motivo per cui al primo tentativo il tocco non apriva niente.
  **L'area di tocco si allarga in LARGHEZZA e non in altezza**, ed e' una
  misura dichiarata: sotto la fascia comincia il contenuto della schermata,
  quindi un bersaglio piu' alto della barra gli ruberebbe i tocchi. Ogni
  bersaglio prende tutta l'altezza della barra e almeno 44 punti di
  larghezza.
  **L'anteprima col saldo a quattro cifre ha trovato un difetto vero**, ed e'
  esattamente cio' che la coda chiedeva di verificare: con una larghezza
  FISSA il borsellino sbordava di ventisette pixel su "9.956". Adesso e' una
  larghezza MINIMA. Anteprime `barra-home.png` e `barra-saldo-lungo.png`
  rigenerate dall'app vera e guardate.
  **Due prove hanno cambiato oggetto, non sono state allentate**: quelle che
  pretendevano lo stato aperto e il saluto per nome sono uscite dalla loro
  casa, che dichiara dove vive adesso la pretesa, e
  `test/la_barra_ha_un_solo_stato_test.dart` pretende con cinque prove un
  solo stato, l'assenza del nome e i tre bersagli al primo tocco.
  **Nessun telefono ha acceso questa cura**: la chiude il collaudo sulla 2186)

- **AR.11** Il gesto porta con se' cio' che la scena sa. Stato: CHIUSA
  (`RegiaDelCammino.dopoUnGesto` prende `Map<String, Object?> dettagli`, e il
  diario li registra per `gesto.chiave` con quante volte ogni valore e'
  comparso: con questa forma sola si risponde sia alla VARIETA' (quanti
  valori diversi: tutti e quattro i semi) sia alla COINCIDENZA (quante volte
  torna il piu' insistente: la stessa carta in due stese).
  **Quanto pesa, dichiarato**: al massimo 128 valori distinti per chiave, che
  tiene tutti i domini veri con margine (78 carte, 24 rune, 16 argomenti, 4
  semi). Oltre il tetto non entrano valori NUOVI e quelli gia' presenti
  continuano a contare: si perde la varieta' oltre il tetto, mai una
  coincidenza gia' cominciata. Non e' uno storico: niente date, niente
  ordine. I dettagli si azzerano con la rinascita della voce 06.
  **IL RAPPORTO PER L'ARCHITETTO, punto per punto.** Passano dettagli, e sono
  quelli che la scena aveva gia' in mano:
  la STESA le tre carte (`carte`), i loro semi (`semi`), quali erano Arcani
  Maggiori (`maggiori`) e l'argomento del ventaglio (`argomento`);
  la GETTATA il modo scelto (`modo`);
  il TRAMONTO la runa incisa (`runa`);
  la SINASTRIA il ritratto scelto (`vip`);
  l'ARCHETIPO il profilo dominante appena calcolato (`archetipo`);
  l'ANIMALE GUIDA l'animale derivato dal segno (`animale`);
  l'OROSCOPO il periodo interrogato (`periodo`).
  **Non passano dettagli, e la ragione e' che non ne hanno**: alba, soffio,
  oracolo e sogno registrano un rito che non ha varianti da distinguere;
  passaporto, numero della vita, carta natale, ora e luogo di nascita sono
  pezzi dell'identita', che o ci sono o non ci sono; il viso e il sigillo
  compiono un gesto unico.
  **Cosa NON arriva alla regia senza cambiare architettura**, ed e' la parte
  che serve all'Architetto per scrivere le condizioni: le RUNE USCITE dalla
  gettata non si possono passare dal punto che registra il gesto, perche' li'
  la gettata e' solo autorizzata e le pietre non sono ancora estratte (serve
  un secondo momento, dopo l'estrazione); la MEDITAZIONE e i CHAKRA non
  chiamano affatto la regia, quindi per loro non esiste nemmeno il gesto,
  prima ancora dei dettagli; e le DOMANDE ai Maestri restano fuori per
  decisione di Mauro.
  Guardia `test/il_gesto_porta_i_dettagli_test.dart` con sei prove, fra cui
  l'enumerazione dei punti che devono passare i loro dettagli. Rosso provato
  togliendo il passaggio da un punto solo)

## I marcatori, contati sulle righe

VOCI_TOTALI: 11
VOCI_APERTE: 6
VOCI_CHIUSE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 4
