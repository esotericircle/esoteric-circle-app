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

- **AS.01** L'inclinazione si misura dal riposo, non dalla gravita'. Stato: APERTA
  (nasce una posizione di riposo che diventa lo zero; il tilt e' la deviazione;
  il guadagno e' tarato perche' quindici gradi diano quasi tutta la corsa. La
  riga di messa a punto mostra tutti e due gli assi)
- **AS.02** Le feste sono sempre quelle nuove, e esplodono dal centro. Stato: APERTA
  (enumerare le strade che portano a una celebrazione e farle passare da una
  porta sola; tutte e tre le feste esplodono dal centro come quella di Medora)
- **AS.03** Il borsellino si aggiorna al traguardo. Stato: APERTA
  (dove si ferma l'accredito, per enumerazione; un accredito rifiutato resta in
  attesa e riprova)
- **AS.04** Ogni Sigillo acceso si tocca, su tutti e tre i sentieri. Stato: APERTA
  (enumerare gli elementi toccabili, grandi e piccoli, e provare che ciascuno
  apra la card del suo traguardo)
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
VOCI_APERTE: 12
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
