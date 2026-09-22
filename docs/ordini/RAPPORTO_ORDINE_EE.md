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
| EE.10, i testi del Consiglio | si' | si' | no, ma **misurato**: dieci sintesi vere, vedi la sezione 4 |
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
| la sintesi passava dalla sorveglianza senza nessun controllo sul prodotto | `voce_sorvegliata.dart` | **PROVENIENZA IGNOTA** |
| nessuna regola sul genere delle carte | non esisteva | **PROVENIENZA IGNOTA** |
| il Mischia non componeva nessun mazzo | `tavolo_dei_ventidue.dart` | **PROVENIENZA IGNOTA** |
| il cerchio del respiro invece del soffione | `breath_destiny_screen.dart` | **nessun ordine**: la richiesta non e' mai entrata in un ordine scritto |

**Quell'ultima riga e' essa stessa un'informazione**: cercata su tutti i
manifesti e su `docs/`, la richiesta di togliere il cerchio non esiste da
nessuna parte. **Una tua parola si e' persa fra la chat e l'ordine**, ed e'
il motivo per cui il cerchio era ancora li'.

---

## 4. LA VOCE 10, E IL NUMERO CHE HA CAMBIATO LA CURA

**Il genere delle carte era la prima meta'**, ed era la piu' semplice: la
regola non esisteva, adesso nasce in un punto solo e arriva ai tre Maestri e
alla sintesi.

**La seconda meta' l'hai voluta estesa al collaudo**, e ha dato un numero che
non mi aspettavo.

**PRIMA HO MISURATO LA COSA SBAGLIATA.** La mia misura chiedeva se la sintesi
nominasse una relazione fra gli sguardi. Tre giri veri: **tre volte si'**. E
infatti la sintesi della tua cattura apre proprio con *"Le letture
convergono"*. La regola A dice che quando il rosso non scatta **si cambia la
grandezza, mai la soglia**, e rileggendo il tuo testo la grandezza giusta si
vede:

> *"Le letture convergono... Tutti gli sguardi sottolineano... Si evidenzia la
> maestria... La Ruota della Fortuna, per tutti..."*

**Non nomina mai nessuno dei tre.** Un confronto ha bisogno di due termini, e
i termini qui sono i Maestri.

**POI IL DIFETTO NON SI E' RIPRODOTTO.** Con la grandezza giusta, sullo stesso
identico materiale della tua cattura: **dieci giri veri, tre Maestri su tre
nominati tutte e dieci le volte**, col tuo profilo e senza, per escludere che
l'avesse gia' curato la voce 09. Prima di crederci ho verificato che il banco
non stesse misurando un'altra cosa: stesso modello, stessa istruzione, stesso
materiale costruito con gli stessi campi, stessa configurazione dell'app.

**Quindi quella sintesi non e' la regola, e' un'estrazione sfortunata**: al
massimo una su undici, per le prove che ho in mano.

**E QUESTO CAMBIA LA CURA, non la annulla.** Rafforzare l'istruzione qui non
era nemmeno misurabile, perche' il prima e' gia' verde: e' la trappola in cui
l'ordine EC voce 03 ci era gia' caduti. **Un difetto raro di un generatore si
prende con una rete**, ed e' la stessa forma che l'ordine EC ha dato alla voce
che si confonde: si guarda cio' che e' tornato e si richiede una volta sola.

**La sintesi era l'unica voce della catena a passare dalla sorveglianza senza
nessun controllo sul prodotto**: protetta dai guasti del trasporto, non da cio'
che tornava scritto. Adesso non lo e' piu'. Se il modello rende una sintesi
che non nomina nessuno dei Maestri, la si richiede; se anche la seconda non
nomina passa la prima, la persona non resta mai senza sintesi, e il guasto
resta scritto nel registro. **Padre: PROVENIENZA IGNOTA**, il controllo non e'
mai esistito.

**Il cancello e' a zero nomi, non a tre**, e la ragione e' la stessa della
voce ED.01: una sintesi che ne nomina due su tre sta confrontando, e
pretenderne tre farebbe richiedere una sintesi buona.

**CHIUSA**, e con dieci sintesi vere da leggere se vuoi giudicarle tu:
`docs/collaudo/ED/sintesi.md` tiene l'ultima per intero.

---

## 4bis. LA SUITE INTERA HA TROVATO SEI DIFETTI MIEI, E LI HO RIPARATI

**Sono tutti figli di quest'ordine, e nessuno stava nei file che avevo
toccato.** Questa e' l'unica cosa che conta di questa sezione: sei difetti
introdotti da me nelle voci 03, 07, 10, 11 e 13, e **tutti e sei invisibili
finche' non si fa girare la suite per intero**.

| difetto | dove | padre |
|---|---|---|
| un esito nuovo del turno non dichiarato nella tabella dei costi | `un_ripiego_non_costa_test.dart` | **ordine EE voce 07** |
| la guardia del catalogo cercava una riga intera che la voce 13 aveva spezzato in blocco | `il_catalogo_si_carica_anche_a_mani_vuote_test.dart` | **ordine EE voce 13** |
| la guardia della lingua ha preso per istruzione sulla persona una regola sul genere delle carte | `ogni_prompt_di_prosa_dichiara_la_forma_test.dart` | **ordine EE voce 10** |
| una prova difendeva la settimana come finestra mobile | `sunset_rune_memory_test.dart` | **ordine EE voce 03** |
| la striscia era misurata sulla regola di prima | `sunset_rune_screen_test.dart` | **ordine EE voce 03** |
| la frase *"La prima delle sette"* era cambiata e la prova la pretendeva | `sunset_rune_screen_test.dart` | **ordine EE voce 03** |

**TRE DI QUESTI SEI SONO PROVE CHE DIFENDEVANO LA REGOLA VECCHIA.** Tu hai
chiesto che la settimana diventasse **sette sere di fila**, e tre prove
scritte per la finestra mobile sono rimaste a pretendere il contrario. **Non
le ho cancellate**: le ho riscritte sulla regola nuova tenendo la lapide, cioe'
il commento che dice come si chiamavano, cosa pretendevano e quale voce le ha
cambiate, cosi' chi legge un rapporto vecchio capisce dov'e' finita quella
misura. Ed e' la stessa cosa fatta con la guardia del cerchio del soffio.

**E una riscrittura ha avuto bisogno della meta' che la tiene onesta.**
Sostituire *"i buchi non espellono"* con *"un buco spezza il filo"* sarebbe
passato anche con un codice che mostra sempre e solo l'ultima sera: accanto c'e'
adesso una prova che due sere attaccate restino attaccate, e l'ho vista rossa
innestando proprio quel difetto.

**Le due guardie degli altri due casi le ho legate al fatto invece che al
token**, perche' cadevano su un codice migliore e non su un difetto: una
cercava `if (identita.isExample) return;` per intero, l'altra la parola
*maschili* ovunque. L'esenzione della seconda ha un cancello suo, nato rosso
infilando un'istruzione sulla persona dentro la regola delle carte: **senza
quel cancello un'esenzione diventa un buco**.

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

**Tredici**, tutte sulla voce 10 e tutte sulla stessa sintesi: dieci per la
misura, tre per la misura sbagliata che ho buttato. Nessun'altra voce
dell'ordine ha toccato il modello, e le distribuzioni non costano chiamate.

**Le tre buttate sono la parte che vale la pena raccontare**: sono il prezzo
della regola A. Misuravano la grandezza sbagliata, e l'ho saputo **perche' le
ho fatte**, non perche' l'ho pensato.

Modello `gemini-2.5-flash` in `europe-west1`, lo stesso dell'app, con il
gettone della sessione `gcloud`. **Nessuna chiamata alle API Anthropic.**

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
