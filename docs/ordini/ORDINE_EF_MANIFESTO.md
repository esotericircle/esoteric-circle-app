# ORDINE EF, IL SOFFIO DEL DESTINO RIFATTO E GUARDATO PRIMA DI CONSEGNARLO

**Sigla:** EF, riverificata sul ramo il 23 settembre 2026: in `docs/ordini`
non c'e' nessun `ORDINE_EF_*` e in `test/` nessuna `ordine_ef_guard`.
**Data:** 23 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `b7f84d7b`,
l'ordine EE chiuso e la build 2276 consegnata.

VOCI_TOTALI: 5
VOCI_CHIUSE: 5
VOCI_APERTE: 0

Il rapporto stara' in `docs/ordini/RAPPORTO_ORDINE_EF.md`.

**Il fatto del fondatore, verbatim**: *"il soffione fa cagare, addirittura
peggio di prima. Giudica tu da screenshot, ASSURDO! MA A CHE CAZZO SERVONO LE
PROVE A VIDEO CHE FA CODE? MA LE FA? Inoltre se soffio al microfono, NON
FUNZIONA, DEVO PER FORZA USARE IL DITO!"*

**E ha ragione sulla domanda piu' scomoda.** Nel rapporto dell'ordine EE e'
scritto *"le due animazioni si giudicano solo a video"*, e poi a video non le
ha guardate nessuno. **Questi difetti si vedono in una cattura**, senza nessun
giudizio di gusto: un riquadro che copre la figura, una fotografia ritagliata
male in mezzo a un'app incisa in oro.

---

## PERCHE' NESSUNA GUARDIA LI HA VISTI, E NON E' UNA SCUSA

La ragione e' scritta nero su bianco dentro `il_soffione_respira_test.dart`,
righe 26-30, dall'ordine EE stesso:

> *"l'immagine del soffione arriva da un asset PNG che nelle prove non si
> carica, e il pittore senza immagine **esce subito**, lasciando una tela vuota
> da misurare"*

`_BreathScenePainter.paint` comincia con `if (dandelion == null) return;`
(`breath_destiny_screen.dart:1116`). **Sotto `flutter test` quell'immagine e'
sempre nulla**, quindi in ogni prova di layout mai fatta su questa schermata il
soffione semplicemente non esiste: nessuna prova poteva accorgersi che un
riquadro lo copre, perche' nella prova non c'era niente da coprire.

La guardia `il_soffione_respira` aggira il problema dando al pittore
un'immagine sintetica, e misura il disegno. **Ma misura il pittore da solo, non
la schermata**: il riquadro "Preparati a respirare" non sta nel pittore, sta
nell'albero dei widget sopra di lui. **Le due meta' non si sono mai incontrate
in nessuna misura**, ed e' esattamente li' che vive il difetto.

**La cura strutturale e' la voce 03**, e per questo va fatta per prima: un
soffione disegnato in codice non ha nessun asset da caricare, quindi **c'e'
anche nelle prove**, e da quel momento in poi una misura sulla schermata intera
puo' vederlo.

---

## VOCE EF.01, IL SOFFIONE SI VEDE PER INTERO E LA BOLLA CRESCE DAVVERO

**UNO SCARTO GROSSO, TROVATO PRIMA DI TOCCARE NIENTE: NELLA FASE DEL RESPIRO
IL SOFFIONE NON C'E'.** Nel rito prima si soffia e poi si respira: `_reveal()`
scatta a soffio finito e solo allora compare la guida. Quando la persona
respira, `progress` vale uno e l'opacita' della testa e' `1 - progress`, cioe'
zero. **Il fondatore, messo davanti al fatto, ha confermato che il rito e'
giusto cosi'**: *"All'apertura viene richiesta un'azione all'utente: soffia sul
soffione oppure spezza con il dito. Dopo si apre veramente la funzione dove c'e'
il tasto per avviare la meditazione con il respiro"*.

**Quindi la figura che deve vedersi intera e respirare e' il dono**, che e'
gia' di suo un soffione di luce d'oro, e prima del soffio e' il soffione
inciso.

**E LA MISURA DELL'ORDINE EE ERA FALSA.** `il_soffione_respira` dichiarava
*"71,0 per cento al culmine"* dipingendo il pittore con soffio a zero e
respiro in corso: **una combinazione che a video non esiste mai**. Padre:
ordine EE voce 02.

### Il difetto, e perche' non poteva non succedere

Due sistemi decidevano due posizioni sulla stessa scena: il pittore metteva la
figura a `h * 0.46` con numeri suoi, il layout centrava il riquadro nella
propria zona. **E la rincorsa inseguiva un anello che non esiste piu'**:
l'ordine EE voce 02 ha svuotato la figura del respiro
(`figura: const SizedBox.shrink()`) e ha lasciato vivo `_allineaLAnello`, che
da allora trascinava tutto il riquadro su un punto largo zero, cioe' sopra la
figura. **Padre: ordine EE voce 02.**

### La cura, e i numeri

La geometria sta in `SuperficiDelSoffio` e **la leggono sia il pittore sia il
layout**: non e' un margine azzeccato, e' un'impossibilita' di sovrapporsi. Il
riquadro non insegue piu', **si appoggia** sotto il fondo dichiarato della
figura, e lo stesso fondo lo legge anche l'invito al gesto.

**E su schermo stretto a cedere e' la figura, non il riquadro**, scelta
dichiarata: `quotaMassimaDellaFigura`.

Misurato su ventiquattro geometrie, dalla guardia nuova
`il_riquadro_non_copre_la_figura`:

| | margine peggiore fra figura e riquadro |
|---|---|
| prima | **meno 47,0 punti**, cioe' figura coperta |
| dopo | **piu' 8,0 punti** |

**LA BOLLA, MISURATA, E IL RISULTATO E' PICCOLO E VA DETTO.** Sulla cattura
della 2276 la bolla comincia a y=1697 su 2392, dentro una scena alta circa
2062 punti: **66,3 per cento**. Dopo il lavoro, misurata al banco a 411 per
914: **65,9 per cento**. **Mezzo punto, non di piu'**, e la ragione e' che le
due meta' della voce 01 tirano in direzioni opposte: una figura che deve stare
scoperta e prendere almeno il settanta per cento della larghezza occupa
verticalmente cio' che alla bolla non resta. **Cio' che e' cambiato davvero
non e' la dimensione della bolla: e' che la figura adesso si vede.**

### E LA BOLLA, TERZA PASSATA: IL COLPEVOLE ERA UN ALTRO

Le prime due passate hanno tolto il riquadro da sopra la figura e separato le
due fasi, e la bolla ha guadagnato **mezzo punto percentuale**. Il fondatore
l'ha visto subito: *"l'AREA DEDICATA ALLA DESCRIZIONE IN BASSO E' TROPPO
PICCOLA, TI HO FATTO ALZARE TUTTO"*.

**Il colpevole era il pavimento fisso dei sei noni**, ereditato dall'ordine
2164 voce 8, che teneva la zona del respiro a 529 punti quando ne chiedeva
479. Nasceva quando la zona era decisa da un rapporto e non c'era nessuna
misura da credere; adesso il riquadro si appoggia a un fondo dichiarato e la
misura e' deterministica, quindi il pavimento vale **solo al primo
fotogramma**.

**E per alzare ancora ho dovuto rimpicciolire la figura**, perche' era gia'
attaccata al bordo di sopra: la quota dell'ordine DD voce 03 scende da
settanta a **cinquantasei** per decisione del fondatore, e la guardia porta la
lapide che lo dice. Quella pretesa nasceva da un cerchio che ne prendeva
trentasei.

**Misurato sul Realme, sulla schermata vera:**

| | build 2276 | dopo |
|---|---|---|
| dove comincia la bolla | y 1697 su 2400 | **y 1200** |
| righe di testo visibili | tre | **sei** |
| tetto del riquadro, al banco | 542 | **248** |
| punti che restano alla bolla | 276 | **415** |

**CHIUSA.**

## IL DIFETTO PIU' GRANDE DELL'ORDINE NON ERA IN NESSUNA VOCE

**Il fatto del fondatore, verbatim**: *"L'animazione del soffione ha sempre
funzionato, quindi non dire cazzate e sistemalo"*, e poi *"il soffio sonoro ha
funzionato, ma l'immagine e' cambiata di botto e non c'e' stata animazione con
i petali che si sono staccati e allontanati dal centro del soffione"*.

**Aveva ragione lui.** Le animazioni giravano: **duravano venti volte meno**.
Quando la piattaforma dichiara `disableAnimations`, Flutter non spegne un
`AnimationController`, **ne moltiplica la durata per 0,05**, ed e' il
comportamento di partenza. Su Android quel flag viene dalla scala di durata
degli animatori, **un numero che moltissimi mettono a zero per far sembrare il
telefono piu' rapido**: sul Realme del fondatore le tre scale sono a zero,
lette con `adb shell settings get global`, e **non si toccano**.

| animazione | durata dichiarata | durata vera sul telefono |
|---|---|---|
| volo dei semi | 900 ms | **45 ms** |
| respiro guidato | 28 s | **1,4 s** |

La schermata diceva *"Il respiro e' compiuto"* dopo otto secondi. **Cura**:
`AnimationBehavior.preserve` sui tre motori del rito, che e' il modo
documentato di dire che quell'animazione e' il contenuto e non un
abbellimento. Guardia `le_animazioni_del_rito_non_si_accorciano`, nata rossa
togliendolo.

**E c'erano due interruttori NOSTRI oltre a quello di Flutter**: `_complete()`
saltava del tutto il volo dei semi sotto Riduci Movimento, e il respiro
restava bloccato alla misura ferma. Tolti tutti e due: resta legata a quel
flag la sola decorazione, il luccichio d'ambiente e il vento che devia i semi.

**HO SBAGLIATO DIAGNOSI DUE VOLTE PRIMA DI ARRIVARCI, e va scritto.** Ho
detto al fondatore che era il telefono ad avere le animazioni spente: falso.
Poi che era il nostro codice a spegnerle: vero solo a meta'. La causa vera
l'ha trovata **una cattura del telefono che diceva "compiuto" troppo presto**,
non una lettura del codice.

**Verificato dopo la cura, sul telefono:**

| | prima | dopo |
|---|---|---|
| il respiro e' ancora in corso a 25 secondi | no | **si'** |
| escursione della figura fra i fotogrammi | 0 px | **142 px** |

---

## VOCE EF.02, OTTO RESPIRI

**SCARTO DICHIARATO: LA PREMESSA E' FALSA, E IL FONDATORE HA DECISO.**

L'ordine chiede di dichiarare *"quale ordine e quale commit lo avevano cambiato
in tre"*. **Nessuno l'ha cambiato.** I numeri del respiro non sono una
costante: arrivano dal **rito del giorno**.
`breath_destiny_screen.dart:794-796` legge `_gift!.rito!.tempi` e
`_gift!.rito!.giri`, e `rito_alba_corpus.dart` contiene **trentasei riti** con
cadenze diverse, fra cui `tempi: 4, giri: 8` alla riga 422. Quello di oggi e'
`tempi: 5, giri: 3` alla riga 203. La scritta la genera
`TestiDelRespiro.formaDi()` **da quei numeri**, apposta perche' non possa mai
mentire sull'animazione, e quel file lo dichiara: *"una riga che dichiara
quattro tempi mentre la figura ne conta sei e' peggio di nessuna riga, e questo
progetto l'ha gia' pagato una volta"*.

Quindi *"Otto volte"* che il fondatore ricordava **era un altro giorno con un
altro rito**, non una versione precedente del codice.

Messo davanti alla scelta il 23 settembre 2026, con la conseguenza dichiarata
(cadenza fissa vorrebbe dire ottanta secondi di respiro invece di trenta, e il
Soffio scollegato dal rito del giorno), il fondatore ha risposto **"Lascio come
sta, decide il rito"**.

**CHIUSA come scarto: nessuna riga di codice cambiata, e la ragione e' scritta
qui.**

## VOCE EF.03, NEL MOMENTO DEL SOFFIO IL SOFFIONE D'ORO INCISO

La fotografia esce dalla schermata. Al suo posto `SoffioneInciso`, disegnato in
codice nello stesso vocabolario d'oro di `FormaDelDono`: pappi su una sfera di
Fibonacci, ognuno col suo ombrellino di filamenti, ricettacolo, stelo curvo con
le brattee. I semi che volano erano gia' indipendenti dalla fotografia e
continuano a volare.

**Da dove veniva la fotografia.** `breath_dandelion.png` entra col commit
`21f46cf0`, *"Soffio del Destino: motore proprio a livelli, semi al soffio,
dono di Aura"*. **Padre: PROVENIENZA IGNOTA** per esteso: quel commit non porta
sigla d'ordine, e la scelta di usare una fotografia in un'app incisa in oro non
e' scritta in nessun manifesto.

**SCARTO SUL PACCHETTO, DICHIARATO.** L'ordine chiede che la fotografia esca
anche dal pacchetto. **Non l'ho tolta**, perche' la usa anche
`soffio_share_card.dart`, la card da condividere, che sta **fuori dal perimetro
di quest'ordine**. Toglierla dal pacchetto romperebbe una superficie che
l'ordine dice di non toccare. Serve una parola del fondatore.

**E LA VOCE 03 E' LA CURA STRUTTURALE, non solo estetica.** Il pittore usciva
subito senza immagine, e sotto `flutter test` l'immagine manca sempre: **la
schermata era cieca a ogni prova di layout**. Adesso il soffione c'e' anche
nelle prove, ed e' per questo che la guardia della voce 01 puo' esistere.

Misurato: prima del soffio il soffione inciso prende **57,7 per cento** della
larghezza.

**Verificata a video sul Realme**, cattura `docs/collaudo/EF/1_prima_del_soffio.png`:
soffione d'oro inciso, intero, senza alone ne' gambo spezzato, con l'invito
sotto. Prima del soffio prende il **46,5 per cento** della larghezza.

**CHIUSA.**

## VOCE EF.04, IL SOFFIO AL MICROFONO FUNZIONA

**LA CATENA FUNZIONA, MISURATA SUL TELEFONO DEL FONDATORE.** Il permesso
risulta **concesso** (`dumpsys package`), il flusso rende campioni senza
interruzioni, e con un rumore a banda larga vero, che spettralmente e' cio'
che e' un soffio, la catena scatta: **energia 0,0628 contro una soglia di
0,0025, planarita' 0,369 contro 0,15**, e il dono si e' aperto.

**Il difetto che teneva il rito fermo non era il riconoscimento, era dopo.**
Vedi la voce 05: `_complete()` non aveva nessuna guardia di rientro, e il
riconoscimento del soffio e' un fermo. Ogni pacchetto audio faceva ripartire
il volo da zero, annullando il futuro precedente: **il dono non si rivelava
mai**. A video sembrava che il microfono non funzionasse.

**Cosa resta alla prova del fondatore**: un soffio vero, che solo una persona
puo' dare. Se non scattasse, adesso il registro dice **quale dei due filtri**
lo ferma, perche' la riga stampa energia e planarita' accanto alle loro
soglie. E il `catch` muto che nascondeva i guasti del microfono non c'e' piu'.

**CHIUSA per cio' che si poteva verificare qui, e dichiarata per il resto.**

## VOCE EF.05, OGNI STATO SI GUARDA PRIMA DI CONSEGNARE

**E GUARDARE HA TROVATO DUE DIFETTI CHE NESSUN ORDINE NOMINAVA, ed e' la
risposta alla domanda del fondatore.**

**Il primo, in una cattura del banco**: l'invito *"Soffia, oppure spazza col
dito"* stava appoggiato in mezzo alla testa del soffione. Stessa malattia del
riquadro, fase diversa. Guardia nuova, nata rossa: rimettendolo dov'era copre
fino a **81,6 punti** su ventiquattro geometrie.

**Il secondo, solo sul telefono, ed e' il piu' grave dell'ordine: la
schermata restava bloccata per sempre.** Dopo il soffio il soffione spariva,
il dono restava a meta' e l'invito non se ne andava piu'. Il registro lo
conferma: il microfono macinava campioni all'infinito, segno che la
rivelazione non era mai scattata. **Causa**: `_complete()` senza guardia di
rientro, e `FormaDelSoffio.eSoffio` e' un fermo che resta acceso, quindi ogni
pacchetto audio faceva ripartire l'animazione da zero; riavviare un
`AnimationController` **annulla** il suo `TickerFuture`, e un futuro annullato
non chiama il `then`. **PROVENIENZA IGNOTA**: il rientro non e' mai stato
guardato da nessun ordine. Era nascosto dal ramo di Riduci Movimento, che
rivelava il dono nello stesso fotogramma; tolto quel ramo in quest'ordine, il
blocco e' venuto a galla alla prima prova a video.

**Il terzo, segnalato dal fondatore guardando la sua stessa cattura**: *"il
titolo in alto troncato con dei puntini"*. La cura esisteva gia',
`TitoloCheNonSiRompe` dall'ordine S voce 05, e ventidue schermate la usano; il
Soffio aveva un `Text` nudo.

**E AGGANCIARE IL COMPONENTE GIUSTO NON BASTAVA.** Quel componente evita che
una parola si spezzi a meta', ma quando il titolo intero vuole piu' righe di
quelle concesse **rende lo stesso una misura**: il testo non si rompe,
l'ultima riga sparisce. L'ordine DQ voce 14 l'aveva gia' pagato sul Viaggio,
dove la barra diceva *"Il Viaggio dello"*. Sostituire il widget e fermarsi li'
sarebbe stato dichiarare una cura senza misurarne l'esito: adesso c'e' la
misura, **sulla geometria vera del Realme, 360 punti e non i 390 del banco**,
perche' su 390 il titolo ci sta e una guardia montata li' sarebbe stata verde
davanti alla cattura. Con due azioni nella barra restano **208 punti**, e il
titolo ci sta intero a corpo venti su due righe.

**LE CATTURE, in `docs/collaudo/EF/`**, fatte sul Realme 767f596c:

| cattura | cosa mostra | esito dei criteri |
|---|---|---|
| `1_prima_del_soffio` | soffione inciso intero, invito sotto, **titolo per intero su due righe** | tutti passati |
| `3_prima_di_respirare` | dono intero, riquadro sotto, bolla a sei righe | tutti passati |
| `4_inspira` | primo giro del respiro | tutti passati |
| `5_secondo_giro` | secondo giro | tutti passati |
| `6_respiro_compiuto` | il rito chiuso | tutti passati |
| `7_il_responso` | la scheda del dono | tutti passati |

**LE CATTURE SONO STATE RIFATTE DUE VOLTE**, e la prima serie e' stata buttata: era stata presa prima della correzione del titolo, quindi **mostrava troncato cio' che il rapporto dichiarava intero**. Una cattura che contraddice il rapporto che dovrebbe provare e' peggio di nessuna cattura.

**Cosa NON e' stato catturato, e si dichiara**: il volo dei semi. Dura
novecento millisecondi e `screencap` ne impiega circa settecento fra uno
scatto e l'altro: fra due catture il volo si chiude. Che duri davvero e' stato
misurato per altra via, sul respiro, che dura ventotto secondi ed e'
campionabile.

**E IL RESPIRO, MISURATO SUL TELEFONO, PRIMA E DOPO:**

| | prima | dopo |
|---|---|---|
| il respiro e' ancora in corso a 25 secondi | no, finito entro 8 | **si'** |
| escursione della figura fra i fotogrammi | **0 px** | **142 px**, 13,1 punti percentuali |

**CHIUSA.**

---

## PROTOCOLLO DELLE GUARDIE

**Regola B, le guardie che coprono questa zona, viste rosse prima di toccarla.**
Da compilare mentre si lavora.

**Regola A, le guardie nuove, ognuna col suo innesto.**
Da compilare mentre si lavora.

**Regola C, ogni difetto col suo padre.**
Da compilare mentre si lavora.
