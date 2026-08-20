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

**E L'EMULATORE NON E' UNA STRADA, con la causa esatta.** Chiudendo la voce
AR.09 si e' provato lo stesso, perche' un fatto non si eredita: l'unico AVD
e' `Pixel_8`, `flutter emulators --launch Pixel_8` esce con codice 1, e il
log dell'emulatore dice la ragione per intero, `x86_64 emulation currently
requires hardware acceleration! CPU acceleration status: Android Emulator
hypervisor driver is not installed on this machine`. Nemmeno senza finestra e
con la grafica software (`-no-window -gpu swiftshader_indirect`) si aggira:
`adb devices` resta vuoto. La barriera e' un driver di kernel, e installarlo
non e' cosa che l'agente faccia da solo: serve Mauro, come amministratore,
oppure un telefono col debug USB.

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
- **AR.02** I tre sentieri nascono dal dato. Stato: CHIUSA
  (**la fonte e' la revisione C**, arrivata a ordine iniziato: la B non si usa
  piu' e resta come storia. Nasce `tool/genera_sentieri_dal_corpus.py`, che
  legge il file e scrive i tre file Dart, i quali dichiarano di essere
  generati: centosessantacinque voci trascritte a mano introducono errori
  silenziosi, e un errore silenzioso in un traguardo si scopre solo il giorno
  in cui non si accende.
  Le condizioni passano da REGOLE dichiarate, e nascono i tre costruttori che
  il corpus nuovo richiede: `VarietaDelDettaglio` (tutti e quattro i semi),
  `CoincidenzaDelDettaglio` (la stessa carta in due stese) e
  `GradiniAlleSpalle` (la Dedizione), tutti e tre appoggiati ai dettagli della
  voce 11.
  **Gli Eos non si calcolano piu'**: venivano da una formula, adesso vengono
  dal dato voce per voce, e la somma torna, 2.010 per sentiero e 6.030 in
  tutto. Una formula e un dato che dicono la stessa cosa sono due verita' che
  un giorno divergono.
  **L'ordine delle regole e' sostanza, e una misura lo ha dimostrato**: messa
  in fondo, una regola generosa traduceva "le dodici Lune del tuo segno" in
  "una Luna nel tuo segno", cioe' un traguardo lungo un anno diventava lo
  stesso di uno da un giorno, e la guardia della legge lo ha scoperto
  accusandoli di essere lo stesso traguardo.
  Guardia `test/i_sentieri_nascono_dal_dato_test.dart` con sette prove:
  conta, somma, confronta nome per nome col file, e pretende che i file
  dichiarino di essere generati)
- **AR.03** La legge e' provata, non promessa. Stato: CHIUSA
  (non una simulazione, che prova solo la strada percorsa: si ENUMERANO gli
  eventi minimi, uno per gesto conosciuto, e si guarda se qualcuno accende due
  traguardi insieme. Zero. Si enumerano poi i gesti per sentiero: nessuno ne
  tocca due, tranne quelli comuni a tutti per progetto, che la prova dichiara
  invece di ignorare. E si pretende che ogni combinazione di giornata NOMINI i
  gesti che la completano, perche' una che non li nomina maturerebbe allo
  scadere del giorno, cioe' quando nessuno guarda)
- **AR.04** La curva si misura, non si spera. Stato: CHIUSA
  (**i numeri, col modello dichiarato**: utente tipo, tre aperture a
  settimana, e un modello PESSIMISTA per costruzione, perche' non insegue il
  cielo, non cerca la varieta' e non spera nelle coincidenze. Nove feste nella
  prima settimana, ventidue nel primo mese, ventidue nel primo trimestre, e
  mai piu' di tre in un giorno, cioe' una per sentiero come vuole la legge.
  **Il numero brutto, e va detto**: il secondo e il terzo mese sono a ZERO.
  Chi apre tre volte a settimana ma non incontra un evento del cielo, non
  prova arti diverse e non ha coincidenze, dopo il primo mese non vede piu'
  nessuna festa. Non e' un difetto del codice: e' la forma della curva, ed e'
  la misura su cui Mauro decide se ritoccarla)
- **AR.05** I gradini dormienti sono dichiarati, non finti. Stato: CHIUSA
  (**sono DICIOTTO e non cinque**, e i tredici in piu' li dichiaro io col
  motivo tecnico: cinque li dichiara il corpus (tre eclissi senza motore, due
  meditazioni senza fine); tre chiedono la fase lunare, che non viaggia coi
  dettagli del gesto; tre chiedono la costanza LUNGA su un evento del cielo
  (dodici Lune di seguito), e il diario conta la serie dei giorni, non quella
  degli eventi; tre chiedono un gesto ogni mese per un anno, e i gesti non si
  tengono mese per mese; uno chiede il presagio del tramonto, che la scena non
  manda; uno la durata del soffio; uno l'archetipo riletto coi transiti; uno
  "a un anno dal primo", e il diario non tiene quando un gesto e' stato
  compiuto la prima volta.
  Nasce la condizione `Dormiente`, che porta il perche' NEL DATO e risponde
  falso a qualunque stato. La sua firma include l'id, perche' diciotto
  dormienti con la stessa ragione avevano la stessa firma e la guardia della
  legge li accusava di accendersi tutti insieme.
  **Le serrature sono due**, e una prova le sorveglia entrambe: la condizione
  che non matura mai e il salto dentro il motore. La scala li scavalca, cosi'
  nessun sentiero si ferma su un gradino irraggiungibile. Rosso provato sulla
  seconda serratura)
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
- **AR.08** I testi seguono i nomi nuovi. Stato: CHIUSA
  (una prova prende gli 88 nomi della revisione B che nella C non esistono
  piu' e cerca chi li nomina ancora: zero. **Il confronto e' sui nomi INTERI
  fra apici e non sulle sottostringhe**, ed e' una misura, non un dettaglio:
  cercando pezzi, "Cinque mattine" accusava "Cinque mattine di seguito", che
  e' un nome vivo. Un commento di una prova che citava due nomi vecchi e'
  stato riscritto. La guardia salta se stessa, perche' i nomi vecchi li nomina
  per mestiere)
- **AR.09** Il manifesto, la suite, l'accensione e la build 2186. Stato: CHIUSA
  (stati veri qui sopra; l'accensione tentata e non riuscita, con la causa
  scritta in testa; `npm test` nelle funzioni verde, 34 prove su 34; suite
  Flutter intera: 3.024 verdi e SETTE rossi, che sono esattamente i sette
  di legge gia dichiarati (l attribuzione cieca, che si rimisura solo dal PC
  di Mauro con gcloud; il disegno di albero e quello di loto fuori tela;
  un_traguardo_acceso_pesa_uguale; e le tre guardie degli ordini AC, T e U
  ancora aperti). L OTTAVO ROSSO, che di legge non era, e stato trovato e
  curato: vedi la coda della cattura dell Oroscopo; numero a 0.1.0+2186 e consegna
  all'App Distribution.
  **LE CODE DEL CORPUS NUOVO, e sono la parte che nessuno aveva previsto.**
  Cambiare i centosessantacinque traguardi ha fatto cadere prove che non
  parlavano di traguardi, e in ogni caso si e' cercata la causa invece di
  spostare la soglia:
  il LISTINO DEL SERVER conosceva `traguardo_grande_10..50` e due soli
  scaglioni per i piccoli, mentre il corpus C mette i grandi su 11, 22, 33,
  44, 55 e fa salire i piccoli da 10 a 55 Eos: gli accrediti dei grandi
  sarebbero tornati errore e i piccoli sarebbero stati pagati un quinto.
  Adesso il valore dipende SOLO dalla posizione, che nei tre sentieri paga
  uguale, il listino ha i suoi 55 prezzi e la somma di un sentiero fa 2.010
  Eos come dice il corpus. La prova non elenca piu' i motivi a mano: li legge
  dal listino vero e confronta anche il prezzo, e il rosso l'ha nominata su
  tutti e tre i sentieri.
  Il PASSAPORTO cercava una voce di barra che la voce 10 ha tolto, e le sue
  feste tornavano a coprire lo schermo perche' la rinascita della voce 06
  spegneva i Sigilli che la prova aveva acceso: misurato, la card restava a
  930 punti per dieci passi di seguito.
  Il PANNO DI TACITO misurava 62 pixel di bordo rettilineo su 60 ammessi, e
  l'arte non era stata toccata: bisezionando i commit e' verde fino al
  manifesto e rosso da AR.01 in poi, perche' il cielo senza sensore adesso
  deriva quaranta punti invece di due millimetri e la finestra del pozzo
  prende dentro il fondo. Ora il cielo sta fermo mentre si misura il panno:
  si e' tolto dal campo cio' che non si stava misurando, non si e' alzata la
  soglia.
  Gli accenti mancanti si sono corretti nel GENERATORE, non nei file
  generati, perche' correggerli a valle li avrebbe fatti tornare al primo
  rigenero)
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
VOCI_APERTE: 0
VOCI_CHIUSE: 7
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 4
