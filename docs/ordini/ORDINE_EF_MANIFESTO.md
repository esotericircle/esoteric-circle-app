# ORDINE EF, IL SOFFIO DEL DESTINO RIFATTO E GUARDATO PRIMA DI CONSEGNARLO

```
ORDINE: EF
DATA: 23 settembre 2026
RAMO: claude/esoteric-circle-master-order-e798aj
PARTENZA: b7f84d7b
VOCI: 5
VOCI_CHIUSE: 0
VOCI_APERTE: 5
```

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

**APERTA**, in attesa delle catture della voce 05.

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

**APERTA**, in attesa delle catture della voce 05.

## VOCE EF.04, IL SOFFIO AL MICROFONO FUNZIONA

Soffiare nel microfono fa volare i semi. La causa dichiarata col file e la
riga. Il gesto col dito resta come alternativa, che
`CLAUDE.md` rende obbligatoria. Nel rapporto: cosa e' verificato qui e cosa
resta alla prova del fondatore, perche' un soffio vero lo puo' dare solo una
persona.

**APERTA.**

## VOCE EF.05, OGNI STATO SI GUARDA PRIMA DI CONSEGNARE

Col lavoro installato sul Realme, una cattura per ogni stato: prima di
cominciare, "Inspira", "Espira", il momento del soffio, il volo dei semi, il
responso. Ogni cattura confrontata coi criteri, uno per uno, con l'esito nel
rapporto. Le catture finali in `docs/collaudo/EF/`.

**APERTA.**

---

## PROTOCOLLO DELLE GUARDIE

**Regola B, le guardie che coprono questa zona, viste rosse prima di toccarla.**
Da compilare mentre si lavora.

**Regola A, le guardie nuove, ognuna col suo innesto.**
Da compilare mentre si lavora.

**Regola C, ogni difetto col suo padre.**
Da compilare mentre si lavora.
