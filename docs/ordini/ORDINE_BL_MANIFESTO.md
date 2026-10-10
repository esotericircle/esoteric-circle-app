# ORDINE BL, LA PORTA DEL GIORNO IN TUTTI I PUNTI RIMASTI

Ordine del fondatore del 25 agosto 2026, aperto dall'esito di BK voce 06. Vale
il mandato esteso di BF. Ramo `claude/esoteric-circle-master-order-e798aj`,
guardia `test/ordine_bl_guard_test.dart`.

## Da dove nasce

L'ordine BK ha misurato che `Horoscope.dayOfYear` contava i giorni sottraendo
due istanti locali, e che con l'ora legale di mezzo quella sottrazione non fa
giorni interi. La cura e' la porta unica `ConfineDelGiorno.giornoDellAnno`.
La stessa formula pero' sopravviveva in altri cinque punti, e uno pesa piu'
degli altri: `daily_rituals.dart` decide con quel numero il Maestro del Rito
dell'Alba, cioe' il primo gesto della giornata e il piu' ripetuto dell'app.

Parole del fondatore, sulla ragione per cui l'ordine si apre subito: "per i
sette mesi dell'ora legale chi apre l'app fra mezzanotte e l'una riceve il
dono di ieri col Maestro di ieri".

## Il confine, stretto apposta

Si sostituisce la formula e nient'altro. Le cinque funzioni non si rivedono,
non si migliorano, non si toccano in nessun altro punto: la loro revisione ha
il suo posto nella coda del fondatore e non si anticipa qui.

## Le premesse, tutte verificate vere sulla testa 3974762

- **P1 VERA**: la formula vecchia sopravvive in cinque punti di CODICE, e sono
  quelli dell'ordine: `sky_postcard.dart:53`, `striscia_altre_arti.dart:75`,
  `voce_del_dono.dart:81`, `daily_rituals.dart:11`,
  `consiglio_finale.dart:124`. Il grep ne trova sette: le altre due,
  `horoscope.dart:110` e `confine_del_giorno.dart:41`, sono i COMMENTI che
  descrivono il difetto curato da BK, non codice.
- **P2 VERA**: `striscia_altre_arti` e `consiglio_finale` contano da
  `DateTime(2026)`, cioe' da un'origine fissa che attraversa gli anni, e non
  dall'anno corrente.
- **P3 VERA**: `ConfineDelGiorno.giornoDellAnno` esiste, prende anno, mese e
  giorno civili e conta in UTC.
- **P4 VERA**: `GuardianAngels.dayOfYear` conta sul calendario con la tabella
  cumulativa dei mesi, e non si tocca.

## IL DIFETTO NON E' UNO SOLO, e la misura lo dice

L'ordine descrive un difetto solo, il numero che cambia alle una di notte.
Misurato, i punti si dividono in due famiglie, e la seconda fa un danno
diverso e peggiore.

**Tre punti NON normalizzano** (`sky_postcard`, `striscia_altre_arti`,
`daily_rituals`): l'ora entra nel conto, e il numero cambia **alle 01:00**
invece che a mezzanotte. Misurato con `TZ=Europe/Rome`, 5 agosto 2026: 215
alle 00:00, 216 dalle 01:00.

**Due punti normalizzano gia' a mezzanotte** (`voce_del_dono`,
`consiglio_finale`): dentro il giorno sono stabili, quindi il difetto di BK
li' non si vede. Ma sottraggono lo stesso due istanti locali, e nei due giorni
del cambio d'ora il conto sbaglia il PASSO. Misurato con `TZ=Europe/Rome`:

| giorno | numero |
|---|---|
| 28 marzo 2026 | 86 |
| **29 marzo 2026** | **87** |
| **30 marzo 2026** | **87** |
| 24 ottobre 2026 | 295 |
| **25 ottobre 2026** | **296** |
| **26 ottobre 2026** | **298** |

In primavera **un giorno si ripete**: il 29 e il 30 marzo pescano la stessa
voce, quindi chi apre il dono il 30 riceve parola per parola quello del 29.
In autunno **un giorno si salta**: il numero 297 non esiste mai, e la voce che
gli corrisponde non esce nemmeno una volta all'anno. Per tutti i mesi
dell'ora legale, in piu', il numero resta sfasato di uno.

## Le voci

- **BL.00** Il manifesto con la guardia. CHIUSA: questo file e `test/ordine_bl_guard_test.dart`.
- **BL.01** La sostituzione nei cinque punti. CHIUSA: tutti e cinque passano da `ConfineDelGiorno`. I tre che contano dall'anno corrente usano `giornoDellAnno`; i due con l'origine fissa del 2026 usano `giorniDa(DateTime(2026), ...)`, e **la base non si e' mossa**: cambia il modo di contare, mai il numero di partenza, o si spostano rotazioni gia' viste dalle persone. La porta si e' allargata di un metodo solo, `giorniDa`, e `giornoDellAnno` adesso chiama quello: il conto vero e' scritto una volta sola, o sarebbe nata la seconda porta da cui tutto questo e' cominciato. **MISURA CHE CHIUDE**: `grep -rn "difference(DateTime(" lib/` restituisce **zero** righe di codice; le due che restano sono i commenti di `horoscope.dart` e `confine_del_giorno.dart` che il difetto lo NOMINANO per spiegarlo. Guardia: `test/il_giorno_si_conta_dalla_porta_test.dart`, una sola per tutti e cinque i punti, che enumera l'intera cartella `lib` e pretende di aver guardato piu' di cento file, cosi' non puo' diventare una bugia verde se `lib` si sposta. **Rosso dimostrato**: rimessa la formula vecchia in `daily_rituals.dart` e verificata l'iniezione PRIMA di leggere l'esito, la guardia cade nominando file e riga.
- **BL.02** La prova numerica dove il comportamento si vede. CHIUSA: misurata sul Rito dell'Alba, l'unico dei cinque in cui la persona vede cambiare qualcosa. Con `TZ=Europe/Rome`, il 5 agosto 2026 il Maestro e' lo STESSO alle 00:00, alle 00:59, alle 01:00, alle 12:00 e alle 23:59, e CAMBIA attraversando la mezzanotte. **La prova misura il fuso prima di misurare il Maestro**: confronta lo scarto di gennaio con quello di luglio e, se l'ora legale non c'e', si dichiara SALTATA invece di passare per il motivo sbagliato. In UTC infatti la prova numerica risulta saltata e le altre quattro restano verdi. **Rosso dimostrato**: con la formula vecchia, e col fuso italiano provato dal fatto stesso che la prova NON e' stata saltata, alle 01:00 il Maestro risulta Medora invece di Aura, cioe' il dono di ieri nella prima ora del giorno.

MARCATORI, per la guardia:
VOCI_TOTALI: 3
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 3
