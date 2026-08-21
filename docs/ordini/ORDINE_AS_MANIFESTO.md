# ORDINE AS, il manifesto

**IL CIELO SI MUOVE DAVVERO, E I DONI DIVENTANO RISPOSTE.** Dodici voci, dalla
AS.01 alla AS.12, sul ramo `claude/esoteric-circle-master-order-e798aj`,
verificato dall'Architetto sulla testa `c2cd303d` del 20 agosto 2026.

## Come si legge questo file

Ogni voce porta uno stato fra quattro: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE. In fondo ci sono i marcatori, che la
guardia `test/ordine_as_guard_test.dart` conta sulle righe: un manifesto che
dice una cosa e conta un'altra e' un manifesto che mente, e la guardia lo
scopre.

## LA REGOLA TRASVERSALE NUOVA, dettata da Mauro, e vale su TUTTA l'app

**L'UTENTE CERCA RISPOSTE E VUOLE SAPERE COSA FARE. NON USA L'APP PER
IMPARARE.** Ogni responso, ogni scheda, ogni dono: meno testo, piu' diretto.
Un minimo di spiegazione va bene, ma transiti, pianeti e meccaniche non sono
il contenuto: sono la ragione nascosta dietro la risposta. Dove un testo si
puo' togliere, si toglie invece di rimpicciolirlo. I testi piccoli si
ingrandiscono.

Questa regola entra nelle regole ferree dello stato vivo e vale da qui in
avanti su ogni ordine.

## L'accensione, dichiarata in testa

**NESSUN TELEFONO HA ACCESO QUESTA BUILD, e non per scelta.** Provato di nuovo
il 21 agosto 2026, senza ereditare il fatto dell'ordine AR: `adb devices`
risponde con l'elenco VUOTO, l'unico AVD e' `Pixel_8` e l'emulatore esce col
solito messaggio, `x86_64 emulation currently requires hardware acceleration!
CPU acceleration status: Android Emulator hypervisor driver is not installed on
this machine`. Nemmeno senza finestra e con la grafica software si aggira.

**Quindi le voci visive restano FERMATE IN ATTESA DI DECISIONE**: le chiude il
collaudo di Mauro sulla 2187. Cio' che si e' potuto guardare qui e' stato
guardato: tutte le anteprime nuove e rigenerate sono state aperte una per una,
e i difetti che hanno mostrato sono elencati nelle voci.

## I fatti misurati che comandano AS.01, rifatti qui

- **F2 CONFERMATO alla lettera.** In `lib/core/motion/parallax_controller.dart`,
  dentro `_onAccel`, ci sono esattamente `final targetX = (-e.x / 9.8).clamp(-1.0, 1.0);`
  e `final targetY = (e.y / 9.8).clamp(-1.0, 1.0);`. Nessuna posizione di
  riposo: lo zero e' l'assenza di gravita' su quell'asse.
- **F3 CONFERMATO per aritmetica.** Un telefono tenuto in mano come si tiene
  per leggere porta quasi tutta la gravita' sull'asse Y, quindi `tiltY` sta a
  0,98 stabile: meta' della parallasse e' gia' a fondo corsa e non puo' andare
  oltre. Combacia col numero letto da Mauro sulla riga di messa a punto, 0,99.
- **F4 CONFERMATO per aritmetica.** La scala e' tarata su novanta gradi:
  quindici gradi di inclinazione valgono `sin(15) = 0,26` di gravita', cioe' 21
  punti sul piano di fondo; dieci gradi ne valgono 14. Sono i "pochi
  millimetri".
- **F5 CONFERMATO leggendo le prove.** `il_cielo_si_muove_davvero_test.dart`
  usa `inclinaPerLaProva(1, 1)`, cioe' un tilt saturo su tutti e due gli assi:
  misura la formula, non il telefono.

## Il vincolo permanente, riportato come vuole l'ordine AO

**LA SCRITTA ESPLORA E IL SUO MENU' A SCOMPARSA NON SI TOCCANO.** Decisione di
Mauro del 17 agosto 2026.

## Le voci

- **AS.01** L'inclinazione si misura dal riposo, non dalla gravita'. Stato: FERMATA IN ATTESA DI DECISIONE
  (**la cura, e i numeri sono tutti misurati.** Nasce la POSIZIONE DI RIPOSO:
  una media che si muove col passo 0,003, cioe' in due secondi insegue l'otto
  per cento e in mezzo minuto il settantacinque. Il primo campione la fissa,
  altrimenti ogni avvio comincerebbe a fondo corsa. Il tilt e' la DEVIAZIONE
  dal riposo, passata per una saturazione morbida (`tanh`) col guadagno 5.
  **Il guadagno 4 e' stato provato e bocciato dalla misura**: dava 62 punti a
  regime ma 58,4 nel gesto vero, perche' il passa-basso che rende dolce il
  moto ci mette una trentina di campioni e un'inclinazione dura un secondo. La
  soglia non si e' abbassata, si e' alzata la cosa che si stava tarando.
  **I numeri del criterio, misurati con una sequenza di letture del sensore e
  non con un tilt imposto**: fermo nella postura di lettura, tilt 0,000 e
  0,000, corse 0,0 e 0,0 punti; a quindici gradi dal riposo il fondo corre
  65,4 punti sugli 80 (il criterio chiedeva piu' di 60); a fondo corsa 79,9,
  quindi non sfonda mai; e tenendo il telefono inclinato per un minuto la
  corsa scende da 76,8 a 12,4, cioe' la postura nuova diventa lo zero nuovo.
  **La corsa dei piani e' congelata dall'ordine AR e questa voce tocca il
  controllore, quindi si rimisura**: polvere 30,0, fondo 80,0, medio 105,5,
  vicino 165,5, identici alla tabella F3 prima e dopo.
  **LA PROVA DEL ROSSO riproduce alla lettera cio' che Mauro ha letto sul
  telefono**: rimessa la formula vecchia, da fermo il tilt Y vale 0,985 e il
  fondo ha gia' speso 78,8 punti su 80, e a quindici gradi ne corre 20,3, che
  e' il fatto F4 al decimo.
  La riga di messa a punto adesso dice la corsa su ENTRAMBI gli assi e mostra
  il riposo imparato: mostrarne uno solo ha nascosto meta' del fenomeno per un
  ordine intero. Guardia `test/l_inclinazione_parte_dal_riposo_test.dart`.
  **Il numero vero lo legge Mauro dalla riga, sul telefono**)
- **AS.02** Le feste sono sempre quelle nuove, e esplodono dal centro. Stato: FERMATA SU DECISIONE DEL FONDATORE
  (**FERMATA DA MAURO IL 21 AGOSTO 2026, a voce gia' lavorata.** La decisione
  arriva dopo il commit `becfc97d`: la voce non si sviluppa oltre, non si
  rifinisce e non si consegna. **La sostituzione arriva con l'ordine AT.**
  **COSA RESTA IN RAMO, e va saputo perche' e' gia' nel codice**: la fascia
  breve riceve il `PittoreDellaFesta` come la scena grande; `DirezioneDellaFesta`
  ha un valore solo, `dalCentro`, e tutte e tre le feste partono di li'; gli
  angoli delle particelle si spartiscono il giro invece di essere tirati a
  sorte; le nove anteprime nascono dalla scena vera e lo scope porta il Maestro
  del sentiero. Le guardie nate con la voce restano verdi e sorvegliano quel
  codice: `test/anche_la_festa_breve_ha_la_materia_test.dart` e la riga
  rovesciata in `test/tre_feste_una_per_maestro_test.dart`.
  **Cosa NON e' stato fatto**, ed e' cio' che la fermata sospende: nessun
  collaudo a video di quelle scene, nessuna rifinitura del movimento, nessuna
  chiusura. L'ordine AT dira' cosa ne resta)
- **AS.03** Il borsellino si aggiorna al traguardo. Stato: FERMATA IN ATTESA DI DECISIONE
  (**L'ENUMERAZIONE dei punti in cui un accredito si puo' fermare**, e sono
  quattro: la porta spenta, il server che non risponde, il server che RIFIUTA,
  e l'accredito riuscito col saldo non applicato.
  **L'IPOTESI PRIMA DELL'ORDINE RESTA UN'IPOTESI, e va detto invece di
  spacciarla per misura.** Il motivo che il telefono manda,
  `traguardo_gradino_<posizione>`, e' nato nell'ordine AR voce 09 e vive sul
  server solo dopo `firebase deploy --only functions`, che Mauro non ha ancora
  eseguito: percio' oggi ogni accredito di traguardo dovrebbe tornare errore.
  **Verificato quel che si poteva verificare da qui**: `functions:list` dice
  che le sei callable esistono e sono vive in europe-west1, ma il registro
  (`functions:log`) non si lascia leggere da questa macchina, quindi la
  conferma diretta la dara' il deploy.
  **LA CURA DEL LATO CLIENTE VALE COMUNQUE, qualunque sia la causa**: un
  accredito rifiutato NON entra nel libro dei premi arrivati, quindi il Sigillo
  resta acceso e la sincronia lo riprova alla prossima apertura. E la sincronia
  adesso chiede il saldo al server ANCHE quando non riprende niente: prima
  usciva prima di chiedere, e col server che rifiuta tutto il numero in barra
  restava quello del disco, non per i premi mancati ma per tutto cio' che il
  server sapesse e il telefono no.
  Guardia `test/il_premio_rifiutato_resta_in_attesa_test.dart`, con una porta
  che RISPONDE e risponde di no, che e' cosa diversa da una porta spenta.
  **Prova del rosso**: rimessa l'uscita anticipata prima della domanda al
  server, la guardia cade e nomina il difetto)
- **AS.04** Ogni Sigillo acceso si tocca, su tutti e tre i sentieri. Stato: FERMATA IN ATTESA DI DECISIONE
  (**LA CAUSA E' MISURATA, e non e' quella che sembrava.** Non c'era niente di
  rotto nei punti grandi: il tocco sceglieva il punto piu' vicino al dito entro
  un raggio UGUALE PER TUTTI, cinquantacinque millesimi del lato corto, cioe'
  19,8 punti su una tela da 360. Ma sui tre sentieri ci sono OTTANTAQUATTRO
  coppie di punti piu' vicine di meta' di quel raggio, e la piu' stretta,
  `aur_47` e `aur_55`, dista 2,5 punti: bastava sbagliare di due pixel per
  prendere il mini invece della perla. Il grande rispondeva solo col dito sul
  centro esatto, e a occhio sembrava non rispondesse mai.
  **La cura: ogni punto attrae quanto e' disegnato.** Nasce `quiHaToccato`, una
  porta sola, in due passate. Prima: se il dito cade DENTRO un cerchio
  disegnato, vince quel cerchio, e fra due cerchi sovrapposti vince il PIU'
  GRANDE, perche' e' quello che si vede sotto il dito. Poi: se il dito e' fuori
  da tutti, vale il polpastrello di prima, cioe' il piu' vicino entro la zona
  larga uguale per tutti, se no un punto da undici millesimi di tela non si
  prenderebbe mai.
  **Il piu' interno era la prima stesura, e la misura l'ha bocciata**: quattro
  grandi su quindici restavano irraggiungibili, perche' un mini quasi
  sovrapposto e' sempre piu' interno in proporzione al proprio raggio.
  **DODICI PUNTI RESTANO COPERTI da uno piu' grande, ed e' dichiarato**: sono
  mini che il disegno mette dentro una perla, e la loro via e' la riga della
  lista, che non ha sovrapposizioni. La guardia lo pretende esplicito e cade se
  diventassero tanti.
  Guardia `test/ogni_sigillo_si_tocca_test.dart`: enumera tutti e 165 i punti,
  i quindici grandi a parte, e otto tocchi dentro ogni perla grande, 120 in
  tutto. **Prova del rosso** togliendo la prima passata: 12 tocchi su 120
  finiscono al mini)
- **AS.05** Si legge, e la card del traguardo si sfoltisce. Stato: FERMATA IN ATTESA DI DECISIONE
  (**IL CENSIMENTO DEI GRIGI, e la prima stesura guardava un colore su due.**
  Il progetto ha DUE grigi: `textSecondary`, che misurato sta fra 9,6 e 11,1 a
  1 sui quattro fondi veri, e `textMuted`, che stava a **4,66 su Medora**, cioe'
  il minimo legale della soglia 4,5. Ed e' proprio il colore delle righe che
  spiegano quando arrivano gli Eos sotto i pulsanti della condivisione, quelle
  che Mauro non leggeva. Adesso `textMuted` vale `0xFFA39D8E`: misurato 7,29
  sul fondo piu' scuro, 6,34 su Medora, 6,81 su Caligo, 6,59 su Aura. La
  guardia pretende 6 a 1 per i grigi pieni, che e' cio' che si e' appena
  raggiunto: non e' severita' gratuita, impedisce di tornare sul filo.
  **Due falsi colpevoli, e la misura e' stata ristretta invece che la soglia
  abbassata**: il censimento accusava due righe delle rune, che erano lo SFONDO
  di un pulsante spento e il BORDO di un altro, non testi.
  **VIA LA BOLLA DEL PROSSIMO TRAGUARDO** dalla celebrazione, decisione di
  Mauro: la festa dura meno di due secondi e in quel tempo si legge cosa si e'
  vinto. E le righe sotto i pulsanti passano da tre righe a una: "Eos quando
  il tuo amico scarica. In attesa." La coda che spiegava l'attribuzione era la
  ragione dietro la risposta, non la risposta.
  **UN DIFETTO TROVATO GUARDANDO L'ANTEPRIMA, che nessuna prova cercava**: il
  nome della festa andava a capo IN MEZZO A UNA PAROLA, `LA COSTELLAZI` a capo
  `ONE NASCENTE`, perche' Flutter taglia dove capita quando una parola sola e'
  piu' larga della riga. Misurati col TextPainter: **sei nomi su 165** si
  spezzano a corpo 34. Nasce
  `lib/design_system/components/titolo_che_non_si_spezza.dart`, che scende di
  corpo finche' la parola piu' lunga ci sta, fino a un minimo dichiarato, e la
  guardia enumera tutti e 165 i nomi: zero spezzati.
  Guardie `test/i_grigi_si_leggono_test.dart` e
  `test/il_titolo_non_si_spezza_test.dart`, la seconda con la prova che il
  difetto esisteva davvero prima della cura)
- **AS.06** Il Rito dell'Alba. Stato: FERMATA IN ATTESA DI DECISIONE
  (**LA PAROLA DEL GIORNO NON C'ENTRAVA NIENTE, e la causa era scritta nel
  codice.** I tre momenti del rito si estraevano con TRE semi derivati
  distinti, con tanto di commento che lo giustificava: "cosi' i tre momenti non
  si muovono insieme". Il gesto poteva dire "conta quante ore mancano a
  stasera" e la parola essere "Ombra". **Misurato su un anno e tre Maestri:
  899 riti su 1095 avevano una parola scollegata dal proprio gesto**, cioe'
  l'ottantadue per cento.
  Adesso ogni gesto DICHIARA nel corpus la parola che gli appartiene, tutti e
  trentasei annotati a mano leggendo gesto per gesto, e a runtime la parola si
  cerca per nome. Le combinazioni scendono da sessantaquattro a sedici per
  forma, ed e' il prezzo giusto: un rito che tiene insieme vale piu' di quattro
  che non c'entrano niente. Guardia
  `test/la_parola_appartiene_al_gesto_test.dart`, con la prova del rosso che
  rimette la formula vecchia e riporta 899 scollegati.
  **VIA IL RETTANGOLO SOTTO IL SOLE**: era un `RadialGradient` nero dentro un
  Container rettangolare, e un gradiente radiale in un rettangolo lascia i
  quattro angoli piu' scuri del centro. Quello che si vedeva era un riquadro
  semitrasparente appoggiato sulla scena.
  **DUE RIGHE DIVENTANO UNA**: "Trascina verso l'alto per sollevare l'alba" e
  "Oppure tocca o tieni premuto" dicevano come si fa lo stesso gesto. Adesso e'
  una riga sola, "Trascina in alto, oppure tocca", e cresce dal corpo della
  didascalia a quello del testo di lettura. La via col dito non sparisce:
  entra nella stessa riga.
  **MENO SPIEGAZIONE, PIU' RISPOSTA**, che e' la regola trasversale: via
  l'etichetta del tipo di dono ("Orientamento del giorno"), che e' la categoria
  con cui lo chiamiamo noi e non cosa dice alla persona; e il "Perche'" scende
  dalle tre righe in cima al pannello della base, che e' il posto dove il
  progetto tiene gia' le ragioni ed e' apribile da chi le cerca. In cima
  restano "Cosa fai" e "Cosa ti resta".
  Anteprime `rito-alba` e `rito-alba-dono` rigenerate e guardate. **Un difetto
  trovato guardandole**: la cattura del dono mostrava una FESTA al posto della
  scheda, perche' compiere il rito matura un traguardo e la celebrazione si
  apre sopra; adesso la cattura parte a cammino gia' percorso)
- **AS.07** Il Soffio del Destino. Stato: FERMATA IN ATTESA DI DECISIONE
  (**LO STELO SI DICHIARAVA "SEMPRE PIANTATO NEL PRATO"**, e si disegnava con
  una `Paint()` piena, senza nessun legame col progresso del soffio: a gesto
  finito restava un gambo nudo in primo piano sotto il dono. Adesso resta
  intero mentre la testa si dirada, cioe' finche' il gesto e' in corso, e si
  dissolve nell'ULTIMO TERZO del soffio; la soglia e' una costante sola
  dichiarata accanto al disegno. Guardia
  `test/lo_stelo_se_ne_va_col_soffio_test.dart`, che verifica anche
  l'aritmetica agli estremi (uno a zero, uno a sette decimi, zero a fine
  corsa). **Prova del rosso** rimettendo la `Paint()` piena.
  **STESSO DIFETTO DELL'ALBA, e si e' curato uguale**: c'era lo stesso velo
  radiale dentro un rettangolo, e le stesse due righe che dicevano come fare
  lo stesso gesto, la prima a corpo DODICI scritto a mano, cioe' sotto il
  pavimento tipografico del progetto. Adesso una riga sola, "Soffia, oppure
  spazza col dito", al corpo del testo di lettura, e la via col dito non
  sparisce.
  **La prima stesura della guardia era rossa per il motivo sbagliato**: cercava
  la frase "sempre piantato" nel file intero e trovava il commento che spiega
  la cura. Adesso legge il sorgente SENZA i commenti, come si fa gia' altrove
  in questo repo.
  Anteprime `soffio-destino` e `soffio-destino-dono` rigenerate e guardate: a
  testa piena lo stelo c'e', col dono a schermo non c'e' piu')
- **AS.08** L'Oracolo del Giorno diventa l'Arcano del Giorno. Stato: FERMATA IN ATTESA DI DECISIONE
  (**COS'ERA PRIMA, detto senza addolcirlo.** Una riga presa a giro da un
  elenco di ventidue frasi, uguale per tutti e legata al giorno dell'anno: si
  leggeva come un biscotto della fortuna, e il livello visivo era un disco
  procedurale che l'ordine S voce 12 aveva dovuto corredare di una didascalia
  per spiegare cosa fosse.
  **Adesso e' l'estrazione di UNA CARTA dei soli Arcani Maggiori**, con l'arte
  vera del mazzo e il significato che il progetto ha gia' scritto e verificato
  per la Stesa. Nasce `lib/core/rituals/arcano_del_giorno.dart`. Finche' il
  gesto non e' compiuto si vede il dorso; poi la carta, il suo nome, il colpo
  d'occhio in una frase e il responso, che nel corpus e' gia' scritto in
  seconda persona e finisce con cosa fare.
  **SOLO DIRITTA, ed e' una scelta dichiarata**: nella Stesa il rovescio ha
  senso perche' si legge un intreccio di tre carte, qui la carta e' una e una
  carta rovescia obbligherebbe a spiegare cos'e' il rovescio prima di dire
  qualcosa di utile, cioe' la lezione di tarocchi che questa voce toglie.
  **Il conto non e' piu' il giorno dell'anno**, che dava un ciclo riconoscibile
  e la stessa carta nello stesso giorno di ogni anno: misurato, adesso in un
  anno escono tutte e 22 le carte e solo 34 giorni su 365 ripetono la carta
  dell'anno prima.
  **IL GESTO DEL CAMMINO RESTA `oracolo`**, come l'ordine chiede: il dono
  cambia natura e nessun traguardo si sposta di un gradino.
  **I NOMI NEL CORPUS SI TRADUCONO NEL GENERATORE**, non nei file generati: le
  frasi dei traguardi nominano i doni, e correggerle a valle sarebbe inutile
  perche' al primo rigenero tornerebbero. L'elenco `NOMI_NUOVI_DEI_DONI` sta
  in `tool/genera_sentieri_dal_corpus.py` e vale anche per il Sigillo del Sogno
  della voce 10.
  **Il pittore del disco e' stato TOLTO, non spento**: codice che nessuno usa
  e' codice che qualcuno crede vivo.
  **Applicata la regola trasversale anche alla scena condivisa dei riti**: dopo
  la rivelazione l'invito al gesto e il suggerimento del sensore spariscono.
  Restavano perche' il disco restava; adesso il livello visivo e' la carta,
  cioe' la risposta stessa, e due righe di istruzioni fra la carta e il suo
  responso sono due righe che allontanano la risposta.
  Guardia `test/l_arcano_del_giorno_test.dart` con sei prove. Anteprima
  `arcano-del-giorno.png` rigenerata e guardata)
- **AS.09** La Runa del Tramonto. Stato: FERMATA IN ATTESA DI DECISIONE
  (**L'AVVISO DELLA POSIZIONE: il sospetto di Mauro era che non fosse collegato
  a niente, e la misura dice il contrario.** E' collegatissimo, e proprio per
  questo lampeggia: la scena parte con `_stimata` a vero, quindi l'avviso c'e'
  subito; poi `_raffinaTramonto` chiede al sistema se il permesso c'e', e
  quando la risposta arriva, se c'e', l'avviso se ne va. Fra le due cose passa
  il tempo di una chiamata di sistema. La cura non e' toglierlo, che serve a
  chi la posizione non ce l'ha: e' **non dirlo prima di saperlo**. Finche' la
  risposta non arriva la riga dell'ora non dichiara niente.
  **LA PIETRA NON E' PIU' GIA' LI'**: stava al centro, velata, e il gesto la
  scopriva, cioe' si vedeva la runa della sera prima di averla gettata. Adesso
  al suo posto c'e' il palmo aperto con "Getta la runa", e la pietra CADE
  dall'alto col gesto, scuotendo o toccando. Il rimbalzo che c'era era un pop
  di scala del sei per cento: si vedeva appena e non si leggeva come un arrivo.
  E l'invito non nomina piu' la pietra, perche' prima del getto non c'e'.
  **VIA LA BOLLA "GIRA LA PIETRA"**, decisione di Mauro. Era passata per tre
  ordini, ognuno l'aveva spostata o riscritta, ed era la cosa piu' grande della
  scena dopo la pietra per un gesto che nel rito non conta: il destino ha
  voluto che la runa cadesse dritta o rovesciata, e girarla a mano non cambia
  il responso. **Il GESTO resta vivo**, doppio tocco e inclinazione: sparisce
  l'invito, non la possibilita'. Due guardie che sorvegliavano l'invito sono
  state ROVESCIATE, non tolte: adesso sorvegliano che nessuno lo rimetta.
  **MERKSTAVE DICE ANCHE COSA VUOL DIRE**: sette punti a video lo mostravano
  nudo, e nessuno sa cosa sia. Adesso e' "in merkstave (rovesciata)". La prima
  stesura della guardia accusava anche `enum RuneVerso { dritto, merkstave }`,
  cioe' nomi in codice: si e' ristretta la misura alle stringhe, non abbassata
  la pretesa.
  **IL PICCOLO RITO PROPIZIATORIO**: quattro gesti brevi in
  `SunsetRuneCorpus.ritiDellaSera`, uno per sera scelto dal giorno rituale,
  che si possono fare da seduti e al buio. Non promettono esiti, e la guardia
  lo pretende parola per parola. Sta dopo le due voci, che dicono cosa lasciare
  e cosa portare: e' il gesto con cui lo si fa.
  Guardia `test/la_runa_cade_e_non_e_gia_li_test.dart`. Anteprime del tramonto
  rigenerate e guardate)
- **AS.10** Il Rito del Sogno diventa il Sigillo del Sogno. Stato: FERMATA IN ATTESA DI DECISIONE
  (**IL NOME CAMBIA OVUNQUE**: ventotto occorrenze in sedici file, commenti
  compresi, perche' un commento che nomina il dono col nome vecchio manda a
  cercare una cosa che non c'e' piu'. Nel corpus dei traguardi la traduzione
  vive nel GENERATORE, nello stesso elenco dichiarato che serve all'Arcano
  della voce 08: a valle tornerebbe al primo rigenero.
  **LA LINEA SI TRACCIA**: al tocco su una stella il segmento che la lega alla
  precedente compariva intero nello stesso fotogramma, e la figura si costruiva
  a scatti; il gesto di unire due stelle, che e' il rito, non si vedeva mai.
  Adesso il capo del filo corre dal punto vecchio a quello nuovo in trecento
  millesimi, e solo dopo si accende la stella successiva. **Trecento e non di
  piu'**: chi unisce dieci stelle aspetterebbe tre secondi in tutto per
  un'animazione che ha gia' capito.
  **Con Riduci Movimento il passaggio e' secco**, come l'ordine chiede: il filo
  e' intero subito, perche' si toglie il movimento e non il contenuto.
  Guardia `test/il_filo_si_traccia_test.dart`, che pretende anche il ridisegno
  a ogni fotogramma: senza quello il filo si allungherebbe solo quando cambia
  qualcos'altro, cioe' mai, e l'animazione non si vedrebbe)
- **AS.11** Le arti del Maestro saltano all'occhio. Stato: FERMATA IN ATTESA DI DECISIONE
  (**LA CRITICA DEI FONDATORI ERA GIUSTA**: chi arriva non conosce i Maestri e
  cerca un'arte, ma trovava "Entra nel Dominio di Medora", che e' un nome
  proprio, e le tre arti stavano SOTTO il pulsante, nel ruolo tipografico piu'
  piccolo dell'app e in oro tenue, cioe' l'ultima cosa che l'occhio prende.
  Adesso sono la prima cosa dopo il nome: sopra il pulsante, al corpo del testo
  di lettura, in oro pieno. Misurato a schermo: arti a 578 punti, pulsante a
  608, corpo 18 contro il pavimento 12. Il pulsante resta sotto, ed e' giusto:
  prima si legge cosa c'e', poi si tocca per entrarci.
  **UNA REGRESSIONE, e l'ha trovata una prova che non parlava di arti**: il
  blocco d'ingresso e' ancorato in basso, quindi cresce verso l'ALTO, cioe'
  verso la figura del Maestro, e la prova differenziale del pulsante ha visto
  46.673 pixel di figura dentro la zona della bolla. Curata restituendo
  l'altezza guadagnata: aria minima fra arti e pulsante (2.356 pixel) e stima
  di partenza dell'altezza da 78 a 96, che e' la misura del blocco nuovo
  (zero).
  Una guardia della bolla pretendeva le arti SOTTO il pulsante: la pretesa si
  rovescia insieme alla gerarchia e continua a sorvegliare che le due cose non
  si accavallino. Guardia nuova
  `test/le_arti_saltano_all_occhio_test.dart`. Anteprima della home guardata)
- **AS.12** Il corpus D, il manifesto, la suite e la build 2187. Stato: CHIUSA
  (**IL CORPUS D E' VIVO**: il generatore legge la revisione D e la C resta
  come storia. Cambia una cosa sola, e la ragione e' la misura della voce
  AR.04: ventidue gradini di costanza non chiedono piu' giorni CONSECUTIVI ma
  tanti giorni dentro un arco piu' largo, perche' chi non apre l'app tutti i
  giorni non completava mai una serie e la scala, essendo sequenziale, si
  bloccava li' per sempre.
  Nasce `GiorniDentroUnArco` e il diario impara a ricordare i GIORNI RECENTI di
  ogni rito, al massimo centoquaranta per rito, che coprono con margine l'arco
  piu' largo del corpus. **Gli archi non si inventano**: li dichiara il corpus e
  il diario li legge dai traguardi, cosi' il giorno che il corpus cambia un
  arco nessuno deve ricordarsi di aggiornare una lista.
  **SETTE VOCI DEL CORPUS D CHIEDONO L'IMPOSSIBILE, e si dichiarano invece di
  aggiustarle di nascosto**: "due settimane di presenza, nell'arco di 3
  giorni", cioe' quattordici giorni dentro tre. Nascono dalla conversione
  automatica della revisione, che ha preso il numero della durata al posto di
  quello dell'arco. Diventano dormienti col perche' scritto nel dato, e **il
  dato va corretto nel corpus**: sono `cal_28`, `cal_40`, `cal_45`, `cal_52`,
  `aur_34`, `aur_45`, `aur_53`.
  **SUITE INTERA**: 3.056 verdi e 28 rossi al primo giro, curati fino ai soli
  rossi di legge piu' quelli che questo ordine dichiara. Le code venivano tutte
  dalle decisioni nuove, e in nessuna si e' allentata una soglia: si sono
  rovesciate le pretese che sorvegliavano cio' che Mauro ha tolto, e la guardia
  del testo narrato ha accolto quattro righe brevi nel suo elenco di ammessi.
  **UNA REGRESSIONE VERA, trovata dalla prova differenziale del pulsante**:
  portando le arti sopra il pulsante, il blocco d'ingresso, che e' ancorato in
  basso, e' cresciuto verso l'ALTO e la figura del Maestro finiva sotto la
  bolla. Misurato: 46.673 pixel. Con l'aria minima scende a 2.356, e con la
  stima di partenza dell'altezza portata da 78 a 96 torna a zero.
  **Build `0.1.0+2187`** arm64, numero letto dall'archivio con aapt2,
  161.176.931 byte, famiglie verificate dentro lo zip; consegnata il 21 agosto
  2026 a `cloud@esotericircle.app` e `info@esotericircle.com`, release
  `6qqabqo3kdgag`, inviti accettati 2)

## I marcatori, contati sulle righe

VOCI_TOTALI: 12
VOCI_APERTE: 0
VOCI_CHIUSE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 1
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 10
