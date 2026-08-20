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

Da riempire alla voce AS.12 con l'esito vero. Se il telefono compare si
accende e si guarda; altrimenti si dichiara qui, e le voci visive restano
FERMATE IN ATTESA DI DECISIONE.

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
- **AS.02** Le feste sono sempre quelle nuove, e esplodono dal centro. Stato: FERMATA IN ATTESA DI DECISIONE
  (**L'ENUMERAZIONE HA TROVATO IL DIFETTO, ed era piu' semplice di quanto
  sembrasse.** Le strade che portano a una celebrazione sono DUE, e le sceglie
  una riga sola dentro `Celebrazione.festeggiaInsieme`: un traguardo GRANDE, o
  il primo Sigillo in assoluto, apre la scena a schermo pieno; **tutti gli
  altri aprono la FASCIA**, che mostrava il solo glifo del Maestro senza
  nessuna particella. I grandi sono quindici su centosessantacinque: la fascia
  e' il caso normale, e "la maggior parte dei casi" di Mauro era alla lettera
  il novanta per cento delle feste.
  Adesso la fascia riceve lo stesso `PittoreDellaFesta` della scena grande,
  con lo stesso Maestro scelto dal traguardo piu' importante e la stessa posa a
  Riduci Movimento: una porta sola, non due che si somigliano.
  **TUTTE E TRE DAL CENTRO, decisione di Mauro.** `DirezioneDellaFesta` resta
  un'enumerazione ma con un valore solo, e la guardia che pretendeva TRE
  direzioni diverse adesso ne pretende UNA: non e' una guardia allentata, e'
  la stessa guardia che sorveglia la decisione nuova, col perche' scritto
  accanto.
  **Un difetto trovato strada facendo, per misura.** Con la direzione unica,
  gli angoli delle particelle erano tirati a sorte, e con le QUARANTA rune di
  Caligo i quadranti risultavano sbilanciati del 115 per cento: un'esplosione
  sbilanciata si legge come una direzione. Adesso ogni particella prende la sua
  fetta di giro dall'indice e il caso decide solo lo scarto dentro la fetta.
  Misurato dopo: medora 13,4 per cento, aura 25,7, caligo 28,8, tutti sotto il
  55 ammesso.
  **LE NOVE ANTEPRIME NASCONO DALLA SCENA VERA**, non piu' da
  `tool/anteprime_delle_feste.dart` che compone il pittore a mano: la guardia
  dei quadranti legge quelle immagini, quindi finche' nascevano da uno
  strumento sorvegliava lo strumento. E lo scope porta il Maestro del sentiero,
  che mancava: la prima cattura mostrava la festa di Caligo coi colori del
  Maestro corrente.
  Guardia nuova `test/anche_la_festa_breve_ha_la_materia_test.dart`, che monta
  la fascia vera e conta i pixel che cambiano in alto: 28, 11 e 24 su mille coi
  tre sentieri. **Prova del rosso col pittore congelato**: 4, 3 e 5, e la
  soglia sta in mezzo a otto, tarata sui due stati e non scelta a occhio)
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
- **AS.05** Si legge, e la card del traguardo si sfoltisce. Stato: APERTA
  (i grigi sotto contrasto tornano in regola; via la bolla del prossimo
  traguardo)
- **AS.06** Il Rito dell'Alba. Stato: APERTA
  (via il rettangolo sotto il sole; testi piu' grandi e meno; la parola del
  giorno legata al testo)
- **AS.07** Il Soffio del Destino. Stato: APERTA
  (lo stelo sparisce dopo i petali; testi piu' grandi e sfoltiti)
- **AS.08** L'Oracolo del Giorno diventa l'Arcano del Giorno. Stato: APERTA
  (una carta dei soli Arcani Maggiori e una risposta per la giornata; il gesto
  del cammino resta `oracolo`)
- **AS.09** La Runa del Tramonto. Stato: APERTA
  (l'avviso della posizione misurato; la pietra cade e non e' gia' li'; via
  "Gira la Runa"; merkstave dice anche rovesciata; un piccolo rito
  propiziatorio)
- **AS.10** Il Rito del Sogno diventa il Sigillo del Sogno. Stato: APERTA
  (il nome cambia ovunque; la linea si traccia invece di comparire)
- **AS.11** Le arti del Maestro saltano all'occhio. Stato: APERTA
  (la riga delle arti diventa la prima cosa che si vede dopo il nome)
- **AS.12** Il corpus D, il manifesto, la suite e la build 2187. Stato: APERTA
  (la costanza non chiede piu' giorni consecutivi ma tanti giorni dentro un
  arco piu' largo; rigenerare i sentieri, suite intera, build e consegna)

## I marcatori, contati sulle righe

VOCI_TOTALI: 12
VOCI_APERTE: 8
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 4
