# ORDINE CB, IL PRIMO APPRODO E CIO' CHE RESTA DI UNA PERSONA

Ordine del fondatore del 29 agosto 2026, cinque voci, arrivato in due pezzi.
Guardia `test/ordine_cb_guard_test.dart`.

Porta le sue tre regole, che sono quelle degli ordini precedenti irrigidite:

- **REGOLA ZERO.** Il testo dell'ordine non e' affidabile: ogni affermazione si
  verifica sul ramo prima di lavorarci, e cio' che risulta falso si scrive nel
  rapporto invece di eseguirlo.
- **REGOLA UNO.** Non ci si ferma davanti a un ostacolo: si risolve, e se non si
  puo' risolvere si riporta cosa manca e perche'.
- **REGOLA DUE.** Le decisioni lasciate a me si prendono e si motivano per
  iscritto, non si rimandano al fondatore.

## Le cinque voci

- **CB.01** Il diario dei sogni si elimina. **CHIUSA.** Il quaderno non esiste piu' in `lib/`, il Rito del Sogno resta intero, e tre gradini dell'Albero dormono dichiarati.
- **CB.02** Il tutorial di primo approdo, cinque fumetti. **APERTA.**
- **CB.03** Cambio email e reimpostazione password dal menu' utente. **APERTA.**
- **CB.04** Le sette chiavi che sopravvivono alla cancellazione. **APERTA.**
- **CB.05** Il limite di conservazione dei dati. **APERTA.**

VOCI_TOTALI: 5
VOCI_CHIUSE: 1
VOCI_APERTE: 4
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

### La frase di accettazione della voce CB.01

**Apri il Rito del Sogno e arriva fino al saluto della notte: sotto la
frase di Caligo non c'e' piu' nessun tasto per annotare il sogno, e il
rito finisce com'era prima che il quaderno esistesse.**

## LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE

La REGOLA ZERO chiede di non fidarsi del testo. Otto affermazioni verificate sul
ramo `claude/sessione-di-prova-1f7cac`, testa `e7aa2f11`, prima di scrivere una
riga. **Cinque erano vere, tre no.**

| # | l'ordine dice | esito | cosa ho trovato davvero |
| --- | --- | --- | --- |
| P1 | esiste un solo manifesto d'ordine aperto | **vera** | c'era solo `ORDINE_CA_MANIFESTO.md` |
| P2 | l'ordine CA e' chiuso in tutte le sue voci | **vera** | marcatori 7 totali, 0 aperte, 7 chiuse |
| P3 | il diario dei sogni e' fatto di quei pezzi | **vera** | tutti trovati: la chiave `sogni.annotati`, i due pulsanti, il provider, la riga della dimenticanza, l'anteprima e tre prove |
| P4 | non esiste nessun tutorial | **vera** | l'unica occorrenza della parola e' un commento che dice che quella scena NON e' un tutorial |
| P5 | dal menu' utente non si cambiano ne' email ne' password | **META' FALSA** | la password si cambia gia': la riga `cambia_parola` chiama `updatePassword`, e `sendPasswordResetEmail` esiste. **Non esiste il cambio EMAIL**: zero occorrenze di `updateEmail` e `verifyBeforeUpdateEmail` in tutto il codice |
| P6 | sette chiavi sopravvivono alla cancellazione | **FALSA** | tutte e sette sono gia' coperte dai prefissi di `CioCheETuo`: `luogo.`, `device.id`, `filo.`, `avvisi.`, `maestro.`, `sunset_rune`. La voce CB.04 resta utile lo stesso, perche' quello che nessuno ha mai fatto e' **misurarle prima e dopo**, sulle due strade della cancellazione |
| P7 | `ProfileStore.clear()` e' cablato solo nella vista di debug | **vera** | unica chiamata in `lib/features/debug/app_check_debug_view.dart:127` |
| P8 | nessun dato ha una scadenza | **FALSA IN UN PUNTO** | il codice del secondo fattore scade davvero: `functions/src/secondo_fattore.ts:143` confronta `Date.now()` con `dati.scade`. Tutto il resto non ha scadenza, e la voce CB.05 vale |

## CB.01, il diario dei sogni si elimina

**Parole del fondatore:** "elimina tutta sta roba che non so cosa sia", "cancella
il diario dei sogni", e la ragione: "non c'e' nessun diario di sogni o simile".

**Da dove veniva, che e' la parte che conta.** Il quaderno non l'ha chiesto
nessuno e non sta in nessun briefing: e' nato dall'ordine BX voce 10 per
svegliare tre gradini del corpus dei Traguardi che parlavano di sogni ANNOTATI.
Una funzione costruita per far tornare un conto interno, non per servire una
persona. **Questo e' il difetto di metodo che la voce chiude**, e per questo la
guardia nuova non sorveglia soltanto i file: sorveglia la strada per cui
tornerebbe.

**Cosa e' uscito**, tutto verificato a codice:

| cosa | dove stava |
| --- | --- |
| la classe del quaderno | `lib/core/rituals/diario_dei_sogni.dart`, cancellato |
| il foglio per annotare | `lib/features/rituals/annota_il_sogno.dart`, cancellato |
| i due pulsanti del rito | `dream_annota` e `dream_rileggi` in `dream_rite_screen.dart` |
| il provider | `lib/app.dart` |
| la riga della dimenticanza | `dimenticanza_della_memoria_viva.dart` |
| i due gesti alla regia | `sogno_annotato` e `sogno_riletto`, tolti dal generatore |
| l'anteprima | `docs/preview/annota-il-sogno.png`, cancellata col suo scatto |
| le prove del quaderno | cinque, in `le_condizioni_costruite_test.dart` |

**Il Rito del Sogno resta intero**, perche' toglierlo nessuno l'ha chiesto: esce
solo il quaderno che gli era stato attaccato sopra. Resta Coming soon
l'Interpretazione dei Sogni, il gradino 19 del corpus, che e' la cosa che il
fondatore aveva in mente.

### I TRE FATTI CHE LA VOCE CHIEDE DI DICHIARARE

**1. La chiave `sogni.annotati` vive gia' sui telefoni.** Chi ha installato una
build da meta' agosto in poi ce l'ha sul disco, e da sola l'app non la
tocchera' mai piu'. **Il prefisso `sogni.` RESTA nell'elenco della
cancellazione**, cosi' quel dato se ne va comunque il giorno che la persona
cancella tutto. Toglierlo sarebbe stato pulito nel codice e falso sul telefono.

**2. Quattro gradini dell'Albero dipendevano dal quaderno, ma solo tre
davvero.** Il quarto, `cal_04`, chiede `GestiCompiuti('sogno', 1)`, e quel gesto
lo manda il Rito: resta vivo e raggiungibile. Gli altri tre passano a
**dormienti dichiarati**, col perche' scritto dentro la condizione, e non
scritto a mano: **l'ha fatto il generatore**, che e' la ragione per cui esiste.

| gradino | nome | Eos |
| --- | --- | --- |
| `cal_17` | Il sogno riletto | 20 |
| `cal_31` | Il sogno che si ripete | 30 |
| `cal_32` | Il tuo Animale nel sogno | 30 |

**Il conto degli Eos raggiungibili cala di 80** su 6.030 totali, cioe' l'1,3 per
cento. I dormienti in app passano da 51 a 54, ed e' un numero che il fondatore
deve vedere cambiare: sta scritto qui e lo stampa la prova.

**3. L'anteprima `annota-il-sogno.png` e' stata cancellata** dal corredo insieme
allo scatto che la produceva, perche' un'anteprima di una schermata che non
esiste piu' e' una bugia illustrata.

**Il rosso, dimostrato e non promesso.** `test/il_quaderno_dei_sogni_non_torna_test.dart`
sorveglia sette pezzi dentro tutti i 473 file Dart di `lib/`. Rimettendo a mano
la sola stringa `dream_annota` in `dream_rite_screen.dart` la prova e' diventata
rossa e ha detto quale pezzo e in quale file; tolta la stringa, e' tornata
verde. L'iniezione e' stata verificata col `grep` PRIMA di leggere l'esito.

## LE SCELTE CHE HO PRESO IO E PERCHE'

La REGOLA DUE chiede che ogni decisione lasciata a me sia scritta e motivata.

- **CB.01, il prefisso `sogni.` resta nella cancellazione.** Il codice non
  scrive piu' quella chiave, ma i telefoni ce l'hanno: tenerlo e' l'unico modo
  perche' la cancellazione dica il vero anche a chi ha una build vecchia.
- **CB.01, i tre gradini dormono invece di sparire.** Toglierli dal corpus
  avrebbe cambiato il totale dei 165 e falsato ogni conto costruito su quello.
  Dormienti dichiarati e' la strada che questo progetto ha gia' scelto per tutto
  cio' che oggi non si puo' raggiungere.
- **CB.01, il perche' del sonno viene dal generatore, non da una riga scritta a
  mano.** I tre gradini si sono addormentati da soli togliendo i due gesti
  dall'elenco di quelli vivi: il Dart e' la conseguenza del dato, come era gia'
  la sua legge.
