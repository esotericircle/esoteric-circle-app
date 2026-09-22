# RAPPORTO DELL'ORDINE EE, I DONI DEL GIORNO, IL CONSIGLIO, IL VIAGGIO E I DATI SULL'ACCOUNT

23 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`,
partenza dal commit `0ebaaec8`. Manifesto in
`docs/ordini/ORDINE_EE_MANIFESTO.md`, col censimento della voce 11 per
intero.

---

## IN CIMA: COSA DEVI FARE DAL TUO PC

**Niente.**

L'ordine chiedeva di verificare le distribuzioni e, se questa macchina
avesse avuto l'accesso, di farle io. **Ce l'ha**: e' autenticata come
`cloud@esotericircle.app` e ha la CLI di Firebase. Funzioni e hosting sono
distribuiti, verificato sul server e non sulla parola.

L'unica cosa che resta e' **guardare l'app**, e per quello serve una build,
che hai gia' autorizzato per la fine del lavoro.

---

## 1. LE QUATTORDICI VOCI

| voce | prodotto | agganciato | verificato a video |
|---|---|---|---|
| EE.01, il Mischia | si' | si' | **no, lo giudichi tu** |
| EE.02, il soffione respira | si' | si' | **no, lo giudichi tu** |
| EE.03, sette sere di fila | si' | si' | no: servono sette sere vere |
| EE.04, il testo della notte | si' | si' | no, ma **misurato**: dieci saluti diversi su dieci nascite |
| EE.05, il saluto non ripete | si' | si' | no, ma misurato su dodici segni |
| EE.06, via "Respiro" | si' | si' | **il tono delle tre parole nuove lo giudichi tu** |
| EE.07, il chiarimento non costa | si' | si' | no: si vede chiedendo un chiarimento vero |
| EE.08, il confronto comprato | si' | si' | **no: si vede comprando davvero** |
| EE.09, la sintesi e il nome | si' | si' | no: si vede aprendo un Consiglio |
| EE.10, i testi del Consiglio | **meta'** | meta' | vedi la sezione 4 |
| EE.11, il luogo nel Viaggio | si' | si' | no: si vede scrivendo una citta' |
| EE.12, tutti i luoghi del mondo | la porta e' aperta | si' | **no: dipende anche dalla rete del telefono** |
| EE.13, i dati sull'account | si' | si' | **no: si vede aggiornando l'app** |
| EE.14, "Scendi" dopo una scelta | si' | si' | no, ma misurato sulla schermata vera |

---

## 2. GLI SCARTI FRA L'ORDINE E IL RAMO

Tutti col file e la riga, e stanno per intero nel manifesto. I due che
cambiano il quadro:

1. **La porta verso i luoghi del mondo non era mai stata aperta.** La
   callable `cercaIlLuogoNelMondo` esiste nel codice dal 16 settembre (commit
   `bda25b14`, ordine DR) e il suo `createTime` sul server e'
   **2026-09-22T01:33:55**: la distribuzione fatta durante quest'ordine. Per
   sei giorni la ricerca nel mondo ha chiamato una funzione inesistente,
   **fallendo in silenzio**.
2. **Il Viaggio dello Sciamano non ha un modulo suo**: apre la stessa
   `DatiDiNascitaScreen` del menu' utente, e la apre **se e solo se**
   l'identita' e' d'esempio. E' questo che rendeva il difetto della voce 11
   invisibile dall'altra porta.

---

## 3. OGNI DIFETTO COL SUO PADRE

| difetto | dove | padre |
|---|---|---|
| il catalogo dei luoghi non si caricava proprio dove serviva | `dati_di_nascita_screen.dart:85` | **PROVENIENZA IGNOTA** |
| il tasto Salva usciva senza luogo, in silenzio | stessa schermata | **PROVENIENZA IGNOTA** |
| la porta verso OpenStreetMap non distribuita | `functions/src/cercatore_di_luoghi.ts` | **ordine DR** |
| il Viaggio non lasciava mai il telefono | `diario_dei_viaggi.dart` | **PROVENIENZA IGNOTA** |
| forma di cortesia e scarto UTC scartati dal server | `functions/src/cammino.ts:39` | **ordine CF voce 07** |
| "Scendi" attivo senza nessuna scelta | `viaggio_dello_sciamano_screen.dart` | **ordine DC voce 05**, ripreso da DQ voce 03 |
| "Respiro", "Radice" e "sentire" nel rito di Medora | `dream_rite_corpus.dart` | **PROVENIENZA IGNOTA** |
| il saluto ripeteva il titolo | `dream_rite_corpus.dart` | **ordine CO voce 17** |
| la giornata presa dalla Luna di stanotte | `dream_rite_corpus.dart` | **PROVENIENZA IGNOTA** |
| la settimana era una finestra mobile, non una serie | `sunset_rune_memory.dart` | **PROVENIENZA IGNOTA** |
| il chiarimento consumava | `esito_del_turno.dart` | **ordine EB voce 06** |
| il Consiglio chiedeva al piano invece che ai rimasti | `ask_maestri_screen.dart` | **ordine BG voce 05** |
| la sintesi non riceveva il profilo | `maestro_persona.dart` | **PROVENIENZA IGNOTA** |
| nessuna regola sul genere delle carte | non esisteva | **PROVENIENZA IGNOTA** |
| il Mischia non componeva nessun mazzo | `tavolo_dei_ventidue.dart` | **PROVENIENZA IGNOTA** |
| il cerchio del respiro invece del soffione | `breath_destiny_screen.dart` | **nessun ordine**: la richiesta non e' mai entrata in un ordine scritto |

**Quell'ultima riga e' essa stessa un'informazione**: cercata su tutti i
manifesti e su `docs/`, la richiesta di togliere il cerchio non esiste da
nessuna parte. **Una tua parola si e' persa fra la chat e l'ordine**, ed e'
il motivo per cui il cerchio era ancora li'.

---

## 4. LA META' DELLA VOCE 10 CHE NON E' STATA FATTA, E PERCHE'

**Il genere delle carte e' fatto.** La regola nasce in un punto solo e arriva
ai tre Maestri e alla sintesi.

**La sintesi che ripete invece di confrontare NON e' fatta**, e non si
dichiara chiusa. L'istruzione **gia' chiede** di *"mettere a confronto le
loro prese di posizione, dove convergono e dove divergono, senza ripetere per
intero ogni lettura"*, e il modello non la rispetta.

**E' esattamente il quadro dell'ordine EC voce 03**, che ha insegnato due
cose: che rafforzare una frase non la fa rispettare, e che **senza una misura
prima e dopo non si sa se una cura ha funzionato**. Quella misura vuole un
giro di collaudo sul Consiglio con una stesa vera, e **non e' stata fatta**:
il collaudo dei Maestri oggi prova le chat, non il Consiglio, ed estenderlo
e' un lavoro suo.

**Dichiarato invece che dato per chiuso.**

---

## 5. COSA RESTA AL TUO GIUDIZIO, E NON LO DO PER FATTO

**Le due animazioni si giudicano solo a video.** Il Mischia in tre tempi e il
soffione che respira: le guardie dicono che il codice fa cio' che l'ordine
chiede, **non che sia bello da guardare**.

**Tre parole nuove del Sigillo del Sogno**, al posto di quelle di Aura:
**Terra** per il Toro, **Spazio** per l'Acquario, e *"hai dato a qualcuno un
posto dove stare"* per il Cancro.

**La frase delle sette sere**, che l'ordine ha lasciato scrivere a me: *"La
prima di sette sere di fila. Salti una sera e il filo si spezza: si riparte
da qui."*

**Il Viaggio dello Sciamano che ricompare** dopo un aggiornamento: si vede
solo aggiornando l'app, ed e' la ragione piu' forte per la build.

**Il confronto comprato**: che il contatore mostri il credito appena
comprato si vede solo comprando davvero.

---

## 6. LE CHIAMATE A GEMINI E IL LORO COSTO

**Zero.** Nessuna chiamata al modello in tutto l'ordine: le voci del Consiglio
sono state curate leggendo il codice e misurando col collaudo gia' esistente,
e la meta' della voce 10 che avrebbe richiesto un giro vero e' **dichiarata
non fatta** invece di essere chiusa a occhio.

Le distribuzioni non costano chiamate al modello.

---

## 7. UNA COSA CHE HO IMPARATO, E VALE OLTRE QUEST'ORDINE

**Un difetto che si vede da una porta sola non e' un difetto raro: e' un
difetto che la seconda porta nasconde.** Tre volte in quest'ordine:

- il catalogo dei luoghi non si caricava **solo** quando la schermata veniva
  aperta dal Viaggio, cioe' **solo** nel caso in cui serviva;
- il Consiglio chiedeva al piano, e il difetto si vedeva **solo** comprando
  con gli Eos invece di abbonarsi;
- la sintesi non conosceva il nome, e si vedeva **solo** in fondo a una
  schermata dove gli altri due Maestri lo usavano.

**In tutti e tre i casi la porta che funzionava faceva da alibi a quella che
non funzionava.** Quando un fatto dice *"da qui si', da li' no"*, la domanda
giusta non e' cosa c'e' di rotto nella porta rotta: e' **cosa hanno di
diverso le due porte**, che nel primo caso era una riga di `return`.
