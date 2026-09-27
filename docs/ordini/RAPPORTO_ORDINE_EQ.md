# RAPPORTO DELL'ORDINE EQ

Le chat che rispondono e la stesa di tarocchi che interpreta. Ordine e lavoro
del 27 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`.
Manifesto `docs/ordini/ORDINE_EQ_MANIFESTO.md`, prove in `docs/collaudo/EQ/`,
quelle del telefono in `docs/collaudo/EQ/realme/`. Le tue consegne: *"Tutto, a
parti"*, prima le chat, poi i tarocchi, poi i difetti delle catture; e
*"Lascia stare i riferimenti a iPhone 17, non è collegato e non posso usarlo
ancora. Solo gli screenshot sono corretti e appartengono a iPhone 17"*.
**Questo ordine non consegna niente**: la build fatta qui e' una build di
prova, codice 0.1.0+2284, installata sul Realme per le catture e mai
consegnata.

**Il conto**: 12 voci, **3 chiuse**, **8 aperte in attesa di verifica**,
**1 da fare** (EQ.10).

## LE VOCI CHIUSE, CON LA LORO PROVA

- **EQ.01, la riga d'oro non si ripete**:
  `docs/collaudo/EQ/realme/eq01_eq07_build_eq_presentazione_senza_riga_d_oro_e_residuo_dei_confronti.png`.
  Sul Realme, la tua conversazione rifatta con Calìgo: presentazioni con la
  riga d'oro **da 1 a 0**, righe d'oro ripetute **da 3 su 4 a 0 su 2**. Nel
  collaudo, due giri per Maestro: righe uguali o simili a una gia' data **da
  3 su 30 a 0 su 22**, presentazioni con la riga **da 6 su 12 a 0 su 12**,
  righe che chiedono di rifare il passo appena fatto **da 2 su 12 a 0 su 12**
  (`docs/collaudo/EQ/eq01_righe_d_oro.txt`).
- **EQ.08, i messaggi sotto la casella**:
  `docs/collaudo/EQ/realme/eq08_build_eq_casella_alta_conversazione_sopra.png`.
  Punti di conversazione sotto il bordo alto della casella **da 74 a 0**, a
  360 e 402 punti; sul Realme la conversazione si ferma sopra la casella
  anche quando cresce a cinque righe.
- **EQ.09, il fondo dei contatori**:
  `docs/collaudo/EQ/realme/eq09_build_eq_scorrendo_niente_dietro_i_contatori.png`.
  Punti in cui la conversazione puo' dipingere dietro i contatori **da 674 a
  0**; la fascia ha la tinta della testata; sul Realme, scorrendo, dietro le
  due righe non passa niente.

## LE VOCI APERTE, E PERCHE'

- **EQ.02, il Maestro risponde con la sua arte.** Prime frasi che rimandano
  a un altro Maestro **da 9 a 0**, ma parti della domanda senza risposta da
  15 a **8 su 28**, non a 0. E sul Realme Calìgo, alla domanda delle tue
  catture, ha risposto per sentenze: *"Prendi un solo sentiero alla volta.
  Non disperdere la tua forza."*
  (`docs/collaudo/EQ/realme/eq02_build_eq_tre_desideri_scegline_uno.png`).
- **EQ.03, le risposte nel merito anche nel LIVE.** Sale, non arriva al
  pieno: sotto, la sezione intera.
- **EQ.04, la stesa interpreta davvero.** Non arriva a 20 su 20; sul Realme una stesa su tre e' finita nella lettura di casa: sotto.
- **EQ.05, EQ.06, EQ.11, EQ.12, le quattro voci grafiche dei tarocchi.**
  Misurate nelle prove a 402 punti con iOS e a 360; sul Realme si vedono
  come atteso
  (`docs/collaudo/EQ/realme/eq04_eq05_eq12_build_eq_carta_chiave_scritta_staccata_e_consiglio_intero.png`,
  `docs/collaudo/EQ/realme/eq06_build_eq_riepilogo_sotto_le_carte.png`,
  `docs/collaudo/EQ/realme/eq11_build_eq_titolo_su_una_riga.png`). Restano
  aperte per la regola 5 dell'ordine: le chiudi tu, guardandole sull'iPhone.
- **EQ.07, i contatori.** Il residuo dei confronti adesso dice di che cosa,
  e sul Realme i contatori scendono quando si usano; ma **"Vai più a fondo"
  non risponde** (sotto, fra i difetti); c'e' anche una domanda per te.

## EQ.03, LE RISPOSTE NEL MERITO, ANCHE NEL LIVE

Nelle tue catture, a *"Ok, le ho scritte e adesso cosa faccio?"*, Calìgo nel
LIVE rispondeva *"Il tuo gesto è compiuto. Ora lascia che il tempo faccia il
suo corso."*.

**Come ho misurato.** Dodici domande di seguito per Maestro, nella stessa
conversazione, fra cui le due delle tue catture; nel LIVE con Flash-Lite, nel
LIVE con Flash e in chat; due giri per modo; Gemini vero in europe-west1;
prima sul codice di prima dell'ordine, dopo sul codice curato
(`tool/collaudo_eq03.dart`). **Il merito non l'ha deciso Gemini**: ho scritto
e tarato quattro volte un giudice Gemini su risposte vere che avevo letto a mano; sul gruppo di controllo e' arrivato al massimo a 33 giudizi giusti su
43 (`docs/collaudo/EQ/eq03/il_giudice_gemini_non_basta.txt`). L'ha deciso una
lettura con una regola scritta (`docs/collaudo/EQ/eq03/regola_della_lettura.md`),
fatta da agenti di lettura sulle trascrizioni senza verdetti e controllata
sulle 78 risposte che avevo etichettato io: 76 accordi su 78.

**La cura, in tre ritocchi.**
- **L'istruzione**: il Maestro parte da cio' che la persona ha appena fatto
  o raccontato e le da' il passo dopo; "aspetta" da solo non e' una
  risposta; nel LIVE la prima frase dice che cosa fare in concreto.
- **Gli esempi da ricopiare escono**: l'apertura di Medora portava *"Scrivi
  stasera a chi ti ha ferito e proponi di vedervi sabato mattina"*: Flash-Lite la ricopiava a chi non aveva nominato ferite. Il registro di
  Aura le vietava di nominare qualunque momento, quindi anche il passo: adesso
  Aura da' un passo nella vita della persona e il corpo le dice come farlo.
- **Una rete a valle**: se le prime due frasi dicono soltanto di aspettare,
  la risposta si chiede di nuovo, una volta, con una nota che spiega che
  cosa fare di un'attesa. Un'attesa con una misura ("fra tre giorni") passa.

**I numeri** (`docs/collaudo/EQ/eq03_nel_merito.txt`), risposte nel merito su
72 (dodici domande, tre Maestri, due giri):

| | prima | dopo |
|---|---|---|
| LIVE con Flash-Lite | 18 | 36 e 27 |
| LIVE con Flash | | 52 e 54 |
| chat (Flash) | 46 | 45 e 42 |
| la domanda delle tue catture nel LIVE, su 6 | 0 | 3 con Flash |

**Il modello del LIVE torna Flash.** L'ordine dice *"per il LIVE resta il
modello che risponde nel merito; fra due che rispondono nel merito, il più
veloce"*: Flash-Lite non risponde nel merito, quindi resta Flash. **Costa
attesa**: sul Realme, dalla fine della tua domanda al Maestro che parla,
mediana **6,4 secondi** su sei turni, contro i **4,8** dell'ordine EO con
Flash-Lite, **1,6 secondi in piu'**. E costa denaro: un turno del LIVE,
stimato dal listino con circa 5.200 gettoni d'istruzione, sale da circa
**0,0006 a circa 0,002 dollari**.

**Sul Realme** (`docs/collaudo/EQ/realme/eq03_live_medora/`,
`docs/collaudo/EQ/realme/eq03_live_caligo/`), con la voce detta dalle casse
del PC: a *"Ok, le ho scritte e adesso cosa faccio?"* Medora risponde *"Ora
che hai messo per iscritto i tuoi desideri... Scegli un giorno..."*, senza
nessuna attesa; in chat Calìgo da' un passo, *"Pronuncia a voce alta la tua
priorità davanti a uno specchio"*
(`docs/collaudo/EQ/realme/eq03_build_eq_chat_le_ho_scritte.png`).

**Perche' resta aperta, detto senza sconti.** Nel LIVE con Flash la domanda
delle tue catture riceve una risposta nel merito 3 volte su 6, non 6.
**La chat non e' migliorata**: 46 su 72 prima, 45 e 42 dopo; alla domanda
delle tue catture in chat da 3 su 6 a 1 su 6. Aura e' la piu' debole (in chat 5 e 4 su 12); fra un giro e l'altro lo stesso Maestro passa da 11 a 5
su 12: il modello varia molto da una conversazione all'altra. Le risposte di
Flash nel LIVE sono piu' lunghe delle tre frasi che la forma chiede.

**L'attribuzione cieca e' rifatta** sull'istruzione nuova: 95,0, 93,3 e 98,3
per cento, media **95,6**, contro l'89,1 dell'ordine EO
(`docs/collaudo/EQ/attribuzione_eq03/`).

## EQ.04, LA RISPOSTA ALLA TUA DOMANDA: "UNA INTERPRETAZIONE LA FA VERAMENTE?"

**Prima di quest'ordine, no.** Il consiglio di Medora si componeva da elenchi
di frasi fisse, scelte da un filo nato dalle tre carte; sotto ogni carta
c'era il significato del suo verso, lo stesso nel passato, nel presente e nel
futuro e per qualunque domanda. Misurato con giudici tarati su undici casi
noti: risposte dirette alla domanda nelle prime due frasi **1 su 20**, carte
lette nella loro posizione e sulla domanda **0 su 60**.

**Adesso si'.** Dopo, due giri con dati diversi: risposte dirette **19 e 17
su 20**, carte lette sulla domanda **53 e 43 su 60**, letture uguali su cento
**0** (`docs/collaudo/EQ/tarocchi/dopo_giro_1/letture.md`,
`docs/collaudo/EQ/tarocchi/dopo_giro_2/letture.md`).

**La stessa domanda, le stesse carte, prima e dopo.** *"Il mio ex tornerà da
me?"*, Sei di Denari, Asso di Spade, La Stella.

Prima (`docs/collaudo/EQ/tarocchi/prima/letture.md`, lettura 9):
> Le tre carte rispondono a «Il mio ex tornerà da me?». Non a una domanda in
> generale. È una carta concreta: parla di cose che si toccano, non di grandi
> destini. Il vantaggio c'è. Ed è alla tua portata.

Dopo (`docs/collaudo/EQ/tarocchi/dopo_giro_1/letture.md`, lettura 9):
> Le carte non indicano un ritorno del tuo ex in questo momento. Questo
> perché la Stella, la carta chiave, mostra che ti aspetta un percorso di
> ritrovamento della serenità per te, piuttosto che il ritorno di una
> situazione passata.
>
> Presente, Asso di Spade: L'Asso di Spade indica che nel presente hai una
> chiarezza improvvisa sulla situazione con il tuo ex.

### La via scelta e il perche'

- **Una chiamata a Flash per la lettura intera**, col ragionamento spento e
  la risposta in sei campi (risposta, passato, presente, futuro, legame,
  consiglio). Riceve la tua domanda, l'argomento, la carta chiave della
  schermata e, per ogni carta, il suo significato tradizionale. **Il testo
  della posizione non gli arriva piu'**: nelle sonde lo parafrasava invece di
  leggere la carta sulla domanda.
- **I 468 testi delle carte nella loro posizione** (78 carte, due versi, tre
  posizioni), scritti una volta sola con Flash dal significato che l'app gia'
  porta, controllati a macchina e riletti uno per uno: 45 corretti a mano
  (`docs/corpus/tarocchi_nella_posizione.md`). Servono alla lettura di casa,
  che adesso sotto ogni carta dice che cosa significa in quella posizione.
- **Le guardie a valle**, come per il Sigillo: tetti di lunghezza, il nome di
  ogni carta nel suo testo, niente cifre, il confine del responso, nessun
  genere dato a chi legge contro la forma che ha scelto. Il trattino lungo e
  la virgola con la "e" si correggono invece di buttare la lettura.
- **Fino a tre richieste dentro dieci secondi**: la seconda e la terza solo
  se la lettura e' tornata e una guardia l'ha scartata, col motivo scritto.
  Se il solo difetto e' il genere, una richiesta breve riscrive le frasi
  colpevoli; finiti i tentativi, quelle frasi si tolgono, mai dalla risposta.
- **Senza modello** (rete assente, tempo scaduto) parla la lettura di casa.
- **Nessuna cache: la quota servita dalla cache e' 0**: le stese ordinate
  con il loro verso sono 78 x 77 x 76 x 8 = 3.651.648, per 16 argomenti fanno
  58 milioni di chiavi. Con un'app giovane una chiave non tornerebbe quasi mai; ogni lettura legge anche la domanda scritta.

**Quanto costa, quanto si aspetta.** Costo medio di una stesa **0,00177 e
0,00191 dollari** nei due giri; tempo dal PC mediano **3,7 secondi**. **Sul
Realme**, tre stese con tre domande diverse
(`docs/collaudo/EQ/realme/eq04_build_eq_attesa_della_stesa.txt`), dal tocco
su "Leggi le Carte" al testo: **3931 e 4011 millesimi** con la lettura del
modello, che apre con *"Le carte indicano che non è il momento giusto per
cambiare lavoro questo inverno"*; **una volta su tre** la chiamata non e'
tornata entro dieci secondi e a **10001 millesimi** e' arrivata la lettura di
casa, che apre ancora in modo criptico
(`docs/collaudo/EQ/realme/eq04_build_eq_stesa_2_lettura_di_casa_dopo_10_secondi.png`).

## EQ.07, CHE COSA CONTA CIASCUN CONTATORE

- **"Oggi hai 50 domande ai Maestri"**, nella testata: le domande scritte in
  chat. Scende a ogni domanda scritta, **non nel LIVE**: i turni del LIVE non
  consumano domande per la decisione dell'ordine EG voce 06. Sul Realme con
  la build di prova: 48, 47, 46, 45, una per domanda in chat.
- **"Oggi hai 30 approfondimenti"**, nella testata: i "Vai più a fondo"
  sotto una risposta. Sul Realme non scende perche' il tasto non risponde.
- **Sotto la bolla, accanto a "Chiedi anche agli altri"**: i confronti fra i
  Maestri, cioe' la stessa domanda chiesta anche agli altri due. Diceva
  soltanto "Oggi te ne restano 20 su 20": accanto a "50 domande" si leggeva
  come un conto sbagliato. Adesso dice **"Oggi hai 20 confronti fra i
  Maestri"**; sul Realme da 20 a 19 al tocco
  (`docs/collaudo/EQ/realme/eq07_build_eq_confronti_19_su_20.png`).
- **Le stese** da 20 a 19 a 18
  (`docs/collaudo/EQ/realme/eq07_build_eq_stese_19_su_20.png`).

## EQ.10, LA PILLOLA BIANCA: DOVE SONO ARRIVATO

Sul Realme non compare. In ascolto, sette secondi fotografati ogni 0,4: 0
pixel bianchi nella sua zona, nessuna finestra di sistema oltre alle barre
(`docs/collaudo/EQ/eq10_indagine.txt`). Poi con la voce vera, detta dalle
casse del PC: due dettature, 54 fotogrammi, 0 pixel bianchi
(`docs/collaudo/EQ/realme/eq10_dettatura_con_la_voce/`). La lente e la barra
di selezione di Flutter hanno un'altra forma e sono scure. Nella tua cattura
la freccia d'invio e' spenta: il campo era vuoto, la pillola non viene dal
testo dettato. **Non ho cambiato niente alla cieca.**

## TRE DOMANDE PER TE

1. **I turni del LIVE devono contare come domande?** Le quattro risposte
   delle tue catture hanno la forma del LIVE; nel LIVE le domande non
   scendono, per la decisione dell'ordine EG voce 06.
2. **Accetti 1,6 secondi in piu' di attesa nel LIVE per un Maestro che
   risponde nel merito?** Con Flash nel merito 52 e 54 su 72, con Flash-Lite
   36 e 27; attesa sul Realme 6,4 secondi contro 4,8; un turno da circa
   0,0006 a circa 0,002 dollari. Consiglio: si', e' la regola che l'ordine
   ha dato. Se no, si torna a Flash-Lite con una riga.
3. **Su quale telefono e con quale tastiera hai visto la pillola bianca?**
   Sul Realme non si riproduce in nessun modo.

## COSA HO TROVATO STRADA FACENDO, CON IL SUO PADRE

**Difetti trovati e non curati in quest'ordine:**
- **"Vai più a fondo" non risponde.** Sul Realme, tre tocchi in due risposte
  diverse: niente, ne' il seguito ne' l'invito del piano; il contatore resta
  a 30 (`docs/collaudo/EQ/realme/difetto_build_eq_vai_piu_a_fondo_non_risponde.png`).
  "Chiedi anche agli altri", nella stessa bolla, funziona. **PROVENIENZA
  IGNOTA**: l'ordine EQ non ha toccato il percorso dell'approfondimento.
- **La dettatura si ferma alla prima parola.** Una frase detta per 8,7
  secondi ha scritto soltanto *"vorrei"*, poi la dettatura ha smesso di
  ascoltare. **PROVENIENZA IGNOTA**: la dettatura non e' stata toccata da
  quest'ordine, l'ultimo ritocco e' dell'ordine EG.
- **La lettura di casa della stesa apre ancora in modo criptico**, *"Le tre
  carte rispondono a «...». Non a una domanda in generale."*. Parla solo
  senza rete o quando la chiamata non torna. Padre dell'apertura: **ordine
  DF** (commit `185ac548`). Padre dell'attesa finita in lei sul Realme:
  **EQ.04**, perche' una chiamata sola che non torna consuma tutti i dieci
  secondi.

**Difetti curati, con il loro padre:**
- **Due rossi sul cancello di GitHub**, sul commit `6d4bfb04`, tutti e due
  miei: il ventaglio fuori campo dopo due pescaggi, 854,5 punti su 844
  (padre **EQ.05**, piu' **EQ.06**), curato: 842,5; la colonna delle
  posizioni della card misurata senza dichiarare la scala (padre **EQ.06**).
- **L'esempio di Medora ricopiato**, *"Scrivi stasera a chi ti ha
  ferito..."*: padre **ordine EK voce 02** (commit `a936c133`). Tolto.
- **Il registro di Aura che le vietava ogni momento, quindi anche il passo**:
  padre **ordine BP voce 2** (commit `e67a38b5`), ripreso dall'ordine EK.
  Riscritto.
- **Nel LIVE Flash-Lite rispondeva con la sola riga d'oro ripetuta**: padre
  **EQ.01**, prima stesura, che la lasciava per non dare una bolla vuota.
  Adesso si chiede di nuovo.
- **I giudici Gemini erano ciechi**: quello dei tarocchi, nella prima
  stesura, approvava due volte su tre il testo di casa, identico per ogni
  posizione e ogni domanda; quello delle chat accettava le massime e i
  rimandi. Padre: **EQ.04** ed **EQ.03**, miei. Il primo rifatto e tarato
  su undici casi noti; il secondo sostituito dalla lettura con la regola
  scritta.
- **La guardia dell'attesa di Medora nella stesa era cieca alla durata**:
  `la_stesa_si_capisce` restava verde con l'attesa a zero. **PROVENIENZA
  IGNOTA**. Ora guarda ogni 100 millesimi fino al minimo.
- **Il criterio del genere accusava "solo" nel senso di "soltanto"**: padre
  **ordine DL voce 06**. Ristretto il criterio, non il dizionario.
- **La guardia del titolo del consiglio era cieca**: misurava a 328 punti,
  piu' del riquadro vero. Padre **ordine BU voce 01**. Riscritta sul
  paragrafo dipinto.
- **Scivoloni miei nel lavoro, nessuno arrivato nel codice**: una prova del
  titolo nata cieca a scala 1,0 (padre **EQ.12**), rifatta anche a 1,3; un
  innesto sbagliato su `il_titolo_non_si_rompe`, rifatto sul difetto vero;
  il controller della chat toccato prima di vedere rossa la sua guardia,
  provata poi sulla versione di HEAD; sul Realme una domanda ripetuta nello
  stesso giorno ha ricevuto la risposta in memoria *"Me l'hai già chiesto
  oggi"*; la cattura del LIVE l'ho rifatta con Medora.

## LE GUARDIE

Sette nuove, tutte viste rosse con l'innesto verificato col grep e ogni file
tornato identico: `la_riga_d_oro_che_non_va_data`, `prima_la_sua_arte`,
`la_stesa_si_legge_intera`, `i_messaggi_stanno_fra_i_contatori_e_la_casella`,
`ordine_eq_guard`, `la_stesa_interpreta_davvero` e
`le_risposte_nel_merito_anche_nel_live` (quattordici innesti). Registro a
**546** (`docs/guardie.md`).

## I COMMIT

Spinti sul ramo e verificati con `git ls-remote`:
- `0873b98c` EQ.01, EQ.02, EQ.08
- `3b1073db` EQ.05, EQ.06, EQ.11, EQ.12
- `6d4bfb04` il manifesto e la sua guardia
- `7c7596d6` EQ.04
- `eb94acd5` EQ.07, EQ.09
- `47ee7b83` EQ.03
- `69c7af7d` la build di prova sul Realme: le catture, EQ.01, EQ.08 ed EQ.09 chiuse
