# ORDINE BO, LA REVISIONE DELLA SINASTRIA CELEB

Ordine del fondatore del 25 agosto 2026. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bo_guard_test.dart`. Testa di partenza `d51669a`.

## Le premesse, verificate prima di scrivere una riga

- **P1 VERA.** `SynastryReport.forPair(Zodiac user, Vip vip)` prende un segno e
  un VIP, e del VIP usa SOLO `vip.sign` per i numeri: le quattro barre, la
  fascia e la riga di relazione nascono da separazione, elementi e modalita'.
  L'unico altro dato del VIP che entra e' la frase sul carattere, presa da
  `_vipCharacters` per stem. Nessun pianeta, nessuna ora, nessun luogo.
- **P2 VERA, e il conto torna esatto.** Cinquanta VIP su dodici segni: 8
  Cancro, 5 Sagittario, 5 Bilancia, 5 Capricorno, 5 Acquario, 4 Vergine, 4
  Leone, 3 Toro, 3 Scorpione, 3 Pesci, 3 Gemelli, 2 Ariete. Le coppie di VIP
  che condividono il segno, e che quindi danno allo stesso utente lo stesso
  responso numerico, sono **93**, contate.
- **P3 VERA.** `((lo * 7 + hi * 13) % 39) / 10 + 0.2` sugli indici dei due
  segni, fra 0,2 e 4,0 per cento. Non conosce citta', paese, ne' se il VIP e'
  vivo. Anche la battuta sotto la barra nasce dallo stesso resto.
- **P4 VERA.** `Vip` ha cinque campi: `name`, `sign`, `note`, `category`,
  `stem`. Nessun campo per ora, luogo, citta' attuale, stato in vita,
  esposizione pubblica.
- **P5 VERA.** Giorgio Armani e Steve Jobs sono nel catalogo e l'app promette
  a chi li sceglie una possibilita' di incontro.
- **P6 VERA.** `sinastria_vip_screen.dart` ha UN solo `AnimationController`,
  1.100 millesimi, che muove insieme il cerchio e le quattro barre.
  `sinastria_gallery_screen.dart` non ne ha nessuno: la fascia In evidenza e'
  una `ListView.separated` e la griglia una `GridView`.
- **P7 VERA.** Esistono e si riusano: `NatalWheel` in
  `design_system/components/natal_wheel.dart`, oggi montata dal solo
  `NatalChartReveal`; il motore in `lib/core/astro/`, e in particolare
  `Effemeridi.tutte(jd)`, che da' Sole, Luna, Mercurio, Venere, Marte, Giove e
  Saturno **in aritmetica locale, senza rete**, piu' `Celestial.julianDay` e
  `Celestial.localSiderealDegrees` per l'Ascendente; la parallasse dei piani;
  `UserPhotoController`; `SinastriaShareCard`. **Piu' uno che l'ordine non
  nominava e serve a BO.09**: `assets/data/nazioni.csv`, i contorni delle
  nazioni gia' nel repository, letti da `nazioni_del_mondo.dart`, e
  `assets/data/luoghi.csv` con le coordinate dei luoghi.
- **P8, RISPOSTA: NO, e la porta non esiste.** Dalla schermata della Sinastria
  non si raggiunge la carta natale in nessun modo. La ruota vive in
  `NatalChartReveal`, montata dal Passaporto Cosmico
  (`cosmic_passport_screen.dart`) e dal Risveglio (`risveglio_journey.dart`).
  La Sinastria legge `BirthIdentity` solo per ricavarne il segno solare, e in
  mancanza di profilo ripiega su `BirthIdentity.example`.

## BO.00, LA RICOGNIZIONE

**I gesti della schermata, e quali sono senza risposta.** Nella schermata del
VIP i gesti sono quattro: la freccia indietro, il polo dell'utente (che apre
il foglio della foto), il tasto Condividi e il tasto Cambia VIP. **Il ritratto
del VIP non ha nessun gesto**, ed e' esattamente il difetto 2 del fondatore.
Non rispondono al dito nemmeno il cerchio grande, le quattro barre e il testo
del responso: si guardano e basta. Nella galleria rispondono le mattonelle,
la barra di ricerca, i filtri di categoria e la fascia In evidenza.

**Le stringhe scritte a mano.** Tutte quelle a video stanno nel sorgente della
schermata e non in un corpus: 'Sinastria VIP', 'Aggiungi la tua foto',
'Modifica la tua foto', 'Preparo la card', 'Cambia VIP', 'La tua foto nella
cornice', la riga lunga sulla privacy della foto, i tre tasti del foglio
della foto e 'Non riesco a preparare la card ora.'. I testi del responso
stanno in `synastry_report.dart` come costanti, non come dato: quattro
chiusure ironiche, quattro battute sull'incontro, cinquanta frasi di
carattere.

**I rossi della suite con TZ=Europe/Rome.** Le prove del dominio Sinastria
(`synastry_test.dart`, `sinastria_gallery_test.dart`,
`sinastria_accents_test.dart`, `segno_non_e_parametro_test.dart`) sono
**35 verdi su 35**. Sulla suite intera, misurata sull'albero fermo alla
chiusura dell'ordine BN, resta **un rosso solo e dichiarato**, l'attribuzione
cieca in `i_doni_e_la_chat_davanti_all_anatomia_test.dart`, che solo il
fondatore puo' rimisurare dal suo PC con una sessione gcloud attiva.

**Asset e caratteri citati e non dichiarati.** Nel dominio della Sinastria
nessuno: i due soli asset citati sono il ritratto del VIP, che si risolve da
`FamilyImage`, e `VipFrame.asset`. Nessun `fontFamily` scritto a mano.

## Le voci

- **BO.00** La ricognizione. CHIUSA: questo capitolo.
- **BO.01** Il catalogo che sa abbastanza. CHIUSA: `Vip` porta adesso la data in tre numeri, l'ora con la sua affidabilita', il luogo di nascita con le coordinate, la citta' di oggi quando e' pubblica, lo stato in vita con l'anno della scomparsa, l'esposizione su una scala dichiarata e **una fonte per ogni campo compilato** (`fonti`). **LA DECISIONE PIU' IMPORTANTE E' UN CAMPO LASCIATO VUOTO**: l'ora di nascita e' `ignota` per **cinquanta su cinquanta**, e non per pigrizia. Nessuna delle fonti pubbliche a disposizione cita un registro, l'Ascendente si sposta di un grado ogni quattro minuti, e il vincolo V4 vieta la congettura spacciata per certezza: mezza lettura costruita su cinquanta orari indovinati sarebbe stata esatta e falsa insieme. La scala `AffidabilitaDellOra` e tutto il ramo dell'Ascendente esistono e sono provati, cosi' il giorno che una fonte con registro arriva costa una riga per VIP. **MISURE**: cinquanta su cinquanta dichiarano lo stato in vita **con la sua fonte**; ogni campo compilato porta la sua fonte e **nessuna fonte cita un campo vuoto**, che e' il verso opposto e altrettanto sporco; i due scomparsi noti, Giorgio Armani e Steve Jobs, risultano tali col loro anno, e nessuno degli altri quarantotto porta un anno di scomparsa; cinquanta su cinquanta hanno il luogo di nascita con coordinate possibili; **ventisette** dichiarano la citta' di oggi, e nessuno scomparso la dichiara. **UNA PROVA IN PIU', che l'ordine non chiedeva e che ha guadagnato il suo posto**: la data e' passata da stringa a tre numeri, e un giorno sbagliato nella conversione sarebbe stato invisibile: si ricalcola il segno solare dalla data e si pretende che sia quello dichiarato, cinquanta su cinquanta. **Rosso dimostrato**: tolta la fonte del luogo a Rihanna, la prova cade col suo nome; la prima iniezione, un commento davanti alla riga, e' stata verificata inefficace prima di leggere l'esito e rifatta togliendo la riga davvero. **Guadagno di contorno**: `note` era un campo e adesso e' una lettura dai tre numeri, quindi la data non puo' piu' vivere in due copie, e la riga dei dodici mesi italiani, scritta a mano in quattro file, ha adesso una porta comune in `lib/core/astro/data_italiana.dart` da cui la Sinastria passa.
- **BO.02** La sinastria vera, dal cielo intero. CHIUSA: `lib/core/synastry/cielo_della_sinastria.dart`. Il responso non prende piu' un segno ma **due cieli**, calcolati da `Effemeridi` in aritmetica locale, senza rete e senza chiave: Sole, Luna, Mercurio, Venere, Marte e l'Ascendente quando ora e luogo ci sono. **Mercurio e' un sesto punto che l'ordine non nominava, ed e' una scelta dichiarata**: la schermata mostra da sempre una barra chiamata "Intesa mentale", e calcolarla senza il pianeta che nella tradizione la regge avrebbe voluto dire misurare la testa coi pianeti del cuore. Gli aspetti sono i cinque tolemaici con **orbi di sinastria dichiarati**, sei gradi sui maggiori e quattro sul sestile, e non quelli dei transiti: un transito e' una finestra che si chiude in giorni e va tenuta stretta, un aspetto di sinastria descrive un rapporto che non cambia. Il testo apre col FATTO, quale punto di lui tocca quale punto tuo e a quanti gradi dall'angolo esatto. **MISURA CHE CHIUDE**: per una stessa persona di prova le coppie di VIP con responso numerico identico passano da **93 a ZERO** su 1.225 possibili; gli otto del Cancro, che da soli facevano 28 coppie identiche, danno adesso otto responsi distinti. **ALTRE MISURE**: oltre quaranta VIP su cinquanta hanno almeno un aspetto vero col cielo di prova, e il responso nomina sempre il piu' stretto; lo stesso paio da' sempre lo stesso esito, testo compreso; senza ora del VIP la lettura lo dichiara e **l'Ascendente non si calcola**, invece di ancorarlo a mezzogiorno; l'Ascendente della persona esiste solo con ora **e** luogo. **UNA VERIFICA INDIPENDENTE DELL'ASCENDENTE**, perche' una formula nuova che nessuno controlla e' un numero qualunque: per chi nasce all'alba dell'equinozio il Sole deve stare vicino all'Ascendente, ed e' il controllo che ogni manuale usa; misurato, **meno di 15 gradi**. **Rosso dimostrato**: rimesso il cielo del VIP sul solo segno solare, le coppie identiche risalgono a **149** e la prova cade. **CIO' CHE E' STATO TOLTO E NON SPOSTATO**: `_separation`, `_modality`, `_complementary`, `_tension` e `_relationLine`, cioe' tutta l'aritmetica dei segni e le sei righe generiche che ne nascevano. Erano il difetto, non un pezzo da conservare. Il corpus dei caratteri e le chiusure ironiche restano intatti: parlano della persona, non del calcolo. **DUE DIFETTI DI LINGUA TROVATI DALLE GUARDIE DI CASA**, e vale la pena scriverli: la prima stesura diceva "il suo Luna" e scriveva `e'` e `cio'` con l'apostrofo invece dell'accento vero. Adesso ogni punto del cielo dichiara il proprio genere, come gia' fa il residuo dei budget, e gli accenti sono veri.
- **BO.03** La possibilita' di incontro che si spiega. APERTA.
- **BO.04** Chi non c'e' piu' cambia domanda. APERTA.
- **BO.05** Il cielo dei volti. APERTA.
- **BO.06** La chiamata e la sovrapposizione. APERTA.
- **BO.07** Il verdetto che si compone. APERTA.
- **BO.08** La carta si apre e la lettura si esplora. APERTA.
- **BO.09** La mappa della distanza. APERTA.
- **BO.10** Il gemello astrale. APERTA.
- **BO.11** La card della sfida. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 12
VOCI_APERTE: 9
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 3
