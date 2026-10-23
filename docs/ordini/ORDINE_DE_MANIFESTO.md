# ORDINE DE, IL VIAGGIO DELLO SCIAMANO, SECONDA STESURA

**Sigla:** DE. **Verificata libera**: in `docs/ordini/` esistono i manifesti
DA, DB, DC e DD, e nessun DE. L'ordine resta DE e non si rinomina.

**Data di apertura:** 11 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`, l'unico.
**Regola che governa tutto:** **IL CODICE MUOVE, GLI ASSET VESTONO.**

VOCI_TOTALI: 16
VOCI_APERTE: 2
VOCI_CHIUSE_DALLA_PROVA_A_VIDEO: DE.16, l 11 settembre 2026

## LO STATO, AL 11 SETTEMBRE 2026 A NOTTE FONDA

**Quindici voci su sedici chiuse. Una resta aperta, e resta aperta per una
ragione che non dipende da me.** DE.16, la prova visiva sul telefono, e' stata
fatta l'11 settembre 2026 in mattinata e ha trovato **sei difetti**: sono tutti
riparati, e la storia sta qui sotto. Resta aperta **DE.04**, che aspetta Imagen
sul progetto, e **DE.05**, che aspetta tre file dal fondatore.

### LE DUE APERTE, in cima e non in fondo

**DE.04, l'ingrandimento dei dodici animali. BLOCCATA, e la premessa
dell'ordine e' falsa.**

L'ordine dice: *"usando l'upscaling di Imagen su Vertex AI, che il progetto ha
gia' configurato"*. **Verificato, e non e' cosi'.** Chiesto al progetto quali
modelli raggiunge:

```
python -c "import google.genai as g; c=g.Client(vertexai=True,
  project='esoteric-circle', location='global'); print([m.name for m in
  c.models.list()])"
```

**Ventisette modelli, e nessuno e' Imagen.** Quelli che toccano le immagini
sono quattro, e sono tutti Gemini: `gemini-3-pro-image`,
`gemini-3.1-flash-image`, `gemini-3.1-flash-image-preview`,
`gemini-3.1-flash-lite-image`. La chiamata diretta all'endpoint di Imagen, in
tre regioni diverse e con quattro nomi di modello, torna sempre:

> Publisher model `projects/esoteric-circle/locations/us-central1/publishers/
> google/models/imagegeneration@002` was not found or your project does not
> have access to it.

**E NON HO USATO GEMINI AL SUO POSTO, ed e' una decisione.** Un modello che
genera immagini **rigenera**, e l'ordine lo vieta con la sua ragione: *"NON si
rigenerano... l'animale che si scopre con la lente deve essere identico a
quello che si trova nel Passaporto e fra i dodici totem. Due lupi diversi nella
stessa app rompono la promessa."* Nessun modello generativo puo' garantire che
occhi e bocca restino identici, e il controllo che l'ordine chiede su ognuna
**non e' un controllo che si passa, e' un controllo che si fallisce**.

**LO STRUMENTO E' SCRITTO E PRONTO**: `tool/ingrandisci_animali.py`. Separa il
colore dall'alpha, riempie le zone trasparenti col colore del bordo perche'
l'upscaler non inventi un fondo che sborda sui contorni, manda il colore a
Imagen e **ingrandisce la maschera a parte con Lanczos**, che su un canale alpha
gia' antialiasato interpola senza inventare. Le due meta' si rimettono insieme,
e **la sagoma resta quella al pixel**.

**QUELLO CHE SERVE DA TE, ed e' una cosa sola**: abilitare l'API di Imagen sul
progetto `esoteric-circle` dalla console di Google Cloud, oppure dirmi che si
puo' spendere per farlo. Poi:

```
python tool/ingrandisci_animali.py tutti
```

**DE.16, la prova visiva sul telefono. FATTA, e questa riga corregge quella di
prima, che diceva NON FATTA.** L'11 settembre 2026 fra le 10:45 e le 11:02, sul
767f596c con la build 2246, il viaggio e' stato percorso per intero: soglia,
domanda, quattro discese, lente, tre ombre, rivelazione, card. Le catture
stanno in `docs/catture/de_df/`.

**E ha trovato SEI DIFETTI che nessuna delle guardie al banco vedeva.** Questa
e' la riga piu' importante di tutto il manifesto, e va letta prima delle altre:
**le sedici voci erano chiuse con i numeri, e l'app a video era sbagliata lo
stesso.** Chi legge questo manifesto deve sapere che un numero verde non e' una
schermata giusta.

| # | che cosa si vedeva | dove nasceva | come e' stato chiuso |
|---|---|---|---|
| 1 | **alla seconda e alla terza discesa l'animale si vedeva intero, testa compresa**, mentre lo schermo prometteva *"la lente scopre solo dove puo', oggi"* | ordine DE voce 03: il buco della lente si ritagliava dal velo con uno `ShaderMask` e `BlendMode.dstIn`, e sul telefono quella maschera cancellava **il velo intero** invece del suo cerchio | il velo si dipinge senza nessuna maschera di fusione: coltre e fantasma interi, e sopra **un ritaglio circolare** dell'animale nitido con dentro il gradiente che torna alla coltre sul raggio |
| 2 | *"Non e nuovo"*, *"Questa non e la prima volta"*, *"lo avevi gia' trovato di la"* | ordine DE voce 11, le otto forme del richiamo | tre accenti rimessi |
| 3 | *"ti rimanda l'ombra che non e' tua, un altra volta"* | ordine DE voce 11, stessa lista | apostrofo elisivo rimesso |
| 4 | **sulla card che si condivide**: *"mi ha trovato il 11 settembre 2026"* | ordine DE voce 08 | l'articolo si elide davanti a **otto** e a **undici**, e a nessun altro giorno del mese |
| 5 | *"E' il Lince. Adesso lo conosci."* | ordine DE voce 08: il genere dei dodici non stava nel codice, stava solo nei testi del corpus | `GuideAnimal.femminile`, quattro su dodici: Aquila, Lince, Tartaruga, Volpe |
| 6 | **quattro discese, la stessa terna di ombre nelle stesse tre posizioni** | ordine DE voce 03: la terna dipende dall'animale del giorno, che nel giorno non cambia | la terna resta quella (serve al meccanismo: vince l'ombra seguita piu' volte), **cambia l'ordine** a ogni discesa |

**Il primo difetto e' il piu' istruttivo, e merita le sue righe.** Lo
sorvegliavano due guardie, tutte e due verdi e tutte e due a ragione:
`la_testa_non_si_vede_prima_della_quarta_test` misurava la **geometria**, cioe'
che il cerchio non toccasse la testa, e non la toccava; una guardia nuova
scritta apposta misurava **l'albero dei widget**, cioe' che il velo fosse
costruito e opaco, e lo era, anche con le animazioni spente come sul
dispositivo. **Il velo era costruito, era opaco, e non dipingeva niente.**

Fra l'albero e i pixel c'era la maschera di fusione. **Percio' la guardia
definitiva non guarda ne' i numeri ne' l'albero: rasterizza la scena e misura
quanto e' NITIDO il rettangolo della testa**, confrontandolo con lo stesso
rettangolo alla quarta discesa, quando il velo e' caduto. Centootto fotogrammi,
dodici animali per tre discese per tre posizioni della lente sul bordo alto
dell'area: **il rapporto peggiore fra testa velata e testa scoperta e' 0,209**,
cioe' la testa velata e' cinque volte meno nitida. Con il velo tolto a mano lo
stesso numero va a **1,000**, ed e' cosi' che la guardia e' stata vista rossa
prima di essere creduta.

**Perche' la nitidezza e non la luce.** Perche' la luce media mente: sotto il
velo il fantasma sfocato si vede, ed e' voluto (*"la sagoma complessiva si
intuisce sempre"*), quindi sulla testa del Lupo faceva 57,3 velata contro 86,0
scoperta, due numeri troppo vicini; e sul Cervo faceva 15,4 velata contro 14,9
scoperta, cioe' **il contrario**, perche' il suo rettangolo della testa e'
largo e in gran parte sfondo trasparente. La nitidezza separa: 4,85 contro
35,63 sul Lupo, 2,03 contro 9,72 sul Cervo.

**LE CATTURE, una per una, con cio' che portano scritto:**

| file | che cosa prova | il testo che si legge |
|---|---|---|
| `de16_01_soglia.png` | **DE.01**, la soglia occupa lo schermo intero | *IL MONDO DI SOTTO / Scopri il tuo animale guida / Dodici ti aspettano. Uno verra' con te.* |
| `de16_02_titolo_due_righe.png` | **DE.02**, il titolo spezzato nella card di Caligo | *VIAGGIO / dello / SCIAMANO*, e sotto *Scopri il tuo animale guida* |
| `de16_09_impronte.png` | **DE.09**, il cammino delle quattro impronte | *Si e' mostrato una volta su 4*, con la prima impronta piena e tre cerchi vuoti |
| `de16_03_tunnel.png` | **DE.06**, la discesa | *Tieni premuto per scendere* |
| `de16_04_nebbia.png` | la nebbia alla fine della discesa | *Apri la nebbia con la mano* |
| `de16_05_lente.png` | il buco aperto dal dito dentro la nebbia | *Apri la nebbia con la mano* |
| `de16_06_tre_ombre_vere.png` | **DE.03**, le tre ombre sono le **sagome vere** dei dodici, non piu' un quadrupede disegnato da una formula | *Di profilo, che si allontana.* |
| `de16_07_quarta_discesa.png` | **DE.03**, alla quarta il velo cade e la testa si vede | *Il velo e' caduto.* |
| `de16_08a_rivelazione.png` | **DE.08**, il nome si dice solo alla fine | *E' il Lince. Adesso lo conosci.* **(cattura del difetto 5, prima della riparazione)** |
| `de16_08b_card.png` | **DE.08**, la card che si condivide | *MI HA TROVATO LINCE*, *mi ha trovato il 11 settembre 2026* **(cattura del difetto 4)**, *Di' chi sei* |
| `de16_11_scena_che_parla.png` | **DE.11**, la scena che si ricorda di quelle prima | *Il Mondo di Sotto ti rimanda l'ombra che non e' tua, un altra volta.* **(cattura del difetto 3)** |
| `difetto_lente_troppo_grande.png`, `difetto_lente_terza_discesa.png` | **il difetto 1**, seconda e terza discesa | *Passa il dito: la lente scopre solo dove puo', oggi* con l'animale interamente scoperto |
| `difetto_stessa_terna_di_ombre.png` | **il difetto 6** | la stessa terna della discesa precedente, nelle stesse posizioni |

**Tre catture portano il difetto e non la prova**, e si tengono apposta: un
manifesto che mostrasse solo le schermate riuscite racconterebbe una giornata
che non c'e' stata.

### LE QUATTORDICI CHIUSE

| voce | che cos'e' | il numero che la chiude |
|---|---|---|
| **DE.01** | la soglia a schermo pieno | **cento per cento** della finestra, 390 per 844 su 390 per 844, misurato sui punti dipinti |
| **DE.02** | il titolo su due righe e la promessa che cambia | tre righe `VIAGGIO / dello / SCIAMANO`, riga di mezzo al **62 per cento** del corpo; la descrizione cambia alla **quarta** discesa e non prima |
| **DE.03** | la lente | **15.876** posizioni provate, dodici animali per tre discese; il caso piu' stretto lascia **3,3 punti** fra la lente e la testa del cavallo |
| **DE.05** | i tre asset nuovi | **BLOCCATA sui file del fondatore**, ma lo slot esiste: vedi sotto |
| **DE.06** | la discesa | **venti** secondi la prima, **nove** dalla seconda |
| **DE.07** | il verso | **slot vuoto per scelta**: i dodici file non ci sono e il momento resta muto |
| **DE.08** | la card della rivelazione | passa dal punto unico della condivisione |
| **DE.09** | le quattro impronte | un cammino, e ogni impronta e' la sagoma vera dell'ombra seguita quella volta |
| **DE.10** | l'apparizione | **1,69 volte a settimana** misurate su mille giorni, cinque porte prima del caso |
| **DE.11** | le scene che si parlano | **cinque** scene indietro, e il perche' e' scritto |
| **DE.12** | l'animale lontano | avviso all'apertura e tamburo che toglie **sette** giorni, uno al giorno, al massimo tre |
| **DE.13** | il secondo animale | **proposta, non montata**: vedi sotto |
| **DE.14** | i tetti per piano | 1, 3, 7, 20 col listino degli Eos; la rivelazione resta **una al giorno per tutti** e non si compra; in Demo ogni limite cade |
| **DE.15** | le quattro domande | risposte nella Sezione Zero, con i file e i numeri |

### DE.05, cosa manca davvero

La cartella `assets/img/mondo_di_sotto/` **non esiste** sul ramo. I due slot
sono montati da prima di questo ordine (`SfondoDelMondoDiSotto`), e il terzo,
la parete del tunnel, chiede anche codice che **non e' stato scritto** perche'
non c'e' niente da vestire.

**I tre file attesi, coi nomi esatti:**

- `assets/img/mondo_di_sotto/soglia_bosco_v1.webp`, verticale 9:16
- `assets/img/mondo_di_sotto/fondo_nebbia_v1.webp`, 1080 per 2040
- `assets/img/mondo_di_sotto/tunnel_parete_v1.webp`, 1024 per 1024

**LA SCALA DI RIPETIZIONE DELLA PARETE, che l'ordine chiede di dichiarare
anche prima del file: SEI GIRI SULL'INTERA DISCESA.**

**Perche' sei.** La galleria e' fatta di anelli che scorrono verso il punto di
fuga; la texture e' 1024 per 1024 e piastrella nelle due direzioni. Con **due o
tre giri** le radici arrivano a schermo larghe come rami, e una radice larga un
terzo di schermo dentro una galleria stretta si legge come un ostacolo invece
che come una parete. Con **dodici o piu'** il disegno scende sotto i dieci pixel
per elemento e diventa **grana**: a quel punto la texture non si vede piu' e
tanto valeva non metterla. **Sei giri su venti secondi** fanno **tre secondi e
un terzo per giro**, cioe' una radice che entra e esce dal campo in poco piu'
di tre secondi: il tempo in cui l'occhio la riconosce senza averla studiata.

### DE.13, LA PROPOSTA DEL SECONDO ANIMALE, e decide il fondatore

*"Non montarlo. Proponilo nel referto con la soglia di tempo che suggerisci,
cosa succede al primo animale, e cosa vede il Passaporto."*

**LA SOGLIA CHE PROPONGO: diciotto mesi dalla rivelazione, e almeno quaranta
discese.**

**Perche' due condizioni e non una.** Il tempo da solo premierebbe chi ha
smesso: uno che ha riconosciuto il suo animale e non e' piu' sceso si vedrebbe
arrivare un secondo animale dopo un anno e mezzo di assenza, che e' il
contrario di cio' che la tradizione racconta. Le discese da sole premierebbero
chi corre. **Insieme dicono: e' passato molto tempo E lo hai frequentato.**

**Perche' diciotto mesi.** Harner parla di animali di potere che *"vanno e
vengono nel corso di una vita"*, e una vita non e' una stagione. Sotto l'anno
il secondo animale sarebbe una funzione nuova travestita da tradizione; oltre i
due anni non lo vedrebbe quasi nessuno. **Diciotto mesi e' il punto in cui una
persona che usa ancora l'app ha davvero cambiato qualcosa di se'**, ed e' anche
oltre l'orizzonte in cui una novita' si legge come una ricompensa.

**Perche' quaranta discese.** E' circa una ogni due settimane per diciotto
mesi: la soglia di chi c'e' stato davvero, senza chiedere una costanza da
atleta.

**CHE COSA SUCCEDE AL PRIMO ANIMALE: NON SE NE VA, e questa e' la parte su cui
non transigerei.** *"Quell'animale restera' con lei da li' in avanti"* e' la
promessa scritta sulla soglia alla prima discesa, ed e' scritta in
`LaPromessaDelViaggio.treCoseDaSapere`. **Un secondo animale che cancella il
primo trasforma quella promessa in una bugia a diciotto mesi di distanza**, che
e' il genere di cosa che una persona non perdona.

Propongo invece: **il primo resta e diventa il piu' anziano.** Il secondo si
affaccia ai margini di una scena, e la persona **sceglie se seguirlo**. Se lo
segue, si riaprono le quattro discese, e alla fine ne ha **due**. Se non lo
segue, non succede niente e non si insiste: l'offerta torna dopo altri sei
mesi.

**COSA VEDE IL PASSAPORTO: due caselle, non una.** La casella dell'Animale
diventa **Gli animali**, col primo in grande e il secondo accanto, piu'
piccolo, con la sua data. **Sotto, una riga sola**: *"Ti ha trovato il <data>"*
per ognuno. Nessun conteggio, nessuna barra, nessun *"2 su 12"*: la voce DC.04
ha gia' vietato i numeri da videogioco in questo dominio, e due animali non
sono un punteggio.

**E IL COSTO DI COSTRUZIONE E' QUASI ZERO**, che e' la ragione per cui vale la
pena: *"questo riapre l'esperienza dei quattro giorni una seconda volta, anni
dopo, senza costruire niente di nuovo"*. Le quattro discese, la lente, le
impronte, la card e il verso esistono gia'. Quello che serve e': la soglia, la
scelta di seguirlo o no, e la seconda casella del Passaporto.

---

## ORDINE SOSPESO DAL FONDATORE L 11 SETTEMBRE 2026

**Il fondatore ha interrotto questo ordine a meta** con l ORDINE DF, urgente e
straordinario, dopo aver fatto quattro letture di tarocchi con la stessa
domanda e aver trovato i primi due paragrafi **identici al carattere** in tutte
e quattro. Le sue parole: *"IO ESIGO CHE OGNI RISPOSTA SIA DIVERSA ANCHE SE
DOVESSI FARE 100 LETTURE CONSECUTIVE CON LA STESSA DOMANDA"*.

**Che cosa e chiuso**, con la guardia vista rossa e le prove verdi:

- **DE.01** la soglia a schermo pieno, cento per cento della finestra misurato
- **DE.02** il titolo su due righe e la promessa che cambia alla quarta discesa
- **DE.03** la lente, il rettangolo della testa dei dodici, le tre aree
- **DE.06** la discesa a venti secondi e poi nove
- **DE.09** le quattro impronte che formano un cammino
- **DE.12** l avviso all apertura e il tamburo che riavvicina
- **DE.14** i tetti per piano e la Demo senza limiti

**Che cosa e montato ma senza guardia propria**: DE.07 (lo slot dei dodici
versi, oggi vuoto per scelta) e DE.08 (la card della rivelazione).

**Che cosa resta aperto**: DE.04 (l ingrandimento dei dodici con Imagen),
DE.05 (i tre asset che fornisce il fondatore), DE.10 (l apparizione fuori dal
Viaggio), DE.11 (le scene che si parlano), DE.13 (la proposta del secondo
animale), DE.16 (la prova visiva sul telefono), piu le guardie di DE.07 e
DE.08 e il referto finale.

**Nessuna consegna e stata fatta su questo ordine.** Si riprende dopo DF.


---

## SEZIONE ZERO, LA RICOGNIZIONE SOTTO LA REGOLA ZERO

*"Il testo di questo ordine non e' una fonte attendibile sullo stato del
codice. Verifica ogni affermazione sul ramo prima di agire e dichiara ogni
differenza."*

Qui sotto c'e' cio' che ho verificato **prima di toccare una riga**, con i
file e i numeri. Dove l'ordine e il ramo dicono due cose diverse, la
differenza e' dichiarata per esteso.

### Che cosa esiste oggi, e dove

**I sei file del Viaggio, in `lib/features/maestri/caligo/viaggio/`:**

| file | righe | che cosa fa |
|---|---:|---|
| `viaggio_dello_sciamano_screen.dart` | 967 | le cinque fasi: soglia, discesa, nebbia, incontro, risalita |
| `la_nebbia_e_l_animale.dart` | 447 | `PittoreDellaNebbia` e `PittoreDellAnimale` |
| `il_tunnel_che_scende.dart` | 283 | `PittoreDelTunnel`, gli anelli della galleria |
| `il_bosco_della_soglia.dart` | 268 | `PittoreDelBosco`, diciotto tronchi e l'apertura |
| `la_girandola_degli_animali.dart` | 134 | i dodici totem che passano in ombra |
| `sfondo_del_mondo_di_sotto.dart` | 61 | lo slot: l'immagine quando c'e', il dipinto quando manca |

**I sei file del nucleo, in `lib/core/viaggio/`:** `diario_dei_viaggi.dart`,
`i_quattro_viaggi.dart`, `l_annuncio_dell_animale.dart`,
`la_domanda_del_viaggio.dart`, `scena_del_viaggio.dart`,
`vocabolario_del_viaggio.dart`.

### LE QUATTRO DOMANDE DELLA VOCE DE.15, rispose con i file e i numeri

#### UNO. La voce DC.08, il nutrimento e la nitidezza, e' montata oggi?

**SI', ed e' montata per intero.** Vive in
`lib/core/viaggio/scena_del_viaggio.dart:85`, nella classe
`NitidezzaDellaScena`, e i numeri sono questi:

- **`nitida = 0.66`**, la soglia sotto la quale la scena si dichiara velata;
- **`velata = 0.33`**, la soglia sotto la quale si dichiara confusa;
- **`dopoQuantiGiorniSiAllontana = 7`**: fino a sette giorni la nitidezza e'
  piena, cioe' 1.0;
- **`quandoDiventaVago = 28`**: a ventotto giorni la nitidezza e' al minimo;
- **fra i due la curva e' LINEARE**, in `dopoGiorni()`;
- **`quantiGiorniValeUnNutrimento = 7`**: un nutrimento sposta indietro
  l'orologio di una settimana.

**Che cosa succede a chi non scende per tre settimane, cioe' a ventuno
giorni.** Ventuno cade fra sette e ventotto: la frazione percorsa e'
(21 - 7) / (28 - 7) = 14 / 21 = 0,667, quindi la nitidezza vale circa
**0,333**.

**E QUI HO SBAGLIATO IO, e lo correggo dove l'ho scritto invece di
riscriverlo.** La prima stesura di questa risposta diceva che a ventun giorni
si legge la riga della scena **confusa**. E' falso, e la guardia della voce
DE.12 me l'ha stampato in faccia: 0,3333 e' **maggiore** di `velata` = 0,33,
quindi la riga che si legge e' quella della scena **velata**, cioe' *"La scena
e' velata: e' passato tempo. Il tamburo lo richiama."*, e gli elementi
leggibili sono **due su tre**. Per leggere la riga della scena confusa bisogna
arrivare a **ventidue giorni**.

**Non e' un dettaglio di un decimale**: e' la differenza fra due frasi diverse
e fra due e un elemento della risposta. **Un numero dedotto a mente non e' un
numero misurato**, ed e' esattamente cio' che la Regola ZERO dice del testo di
un ordine e che vale anche per il mio referto.

**E' gia' cablata nella schermata**, non e' codice orfano:
`viaggio_dello_sciamano_screen.dart` la chiama alla riga 217 (per la
composizione della scena), alla 229 (che la deposita nel Diario), alla 775
(la densita' della nebbia), e alle 911, 917 e 918 mostra la riga sotto la
chiave `viaggio_nitidezza`.

**CONSEGUENZA PER LA VOCE DE.12, e la scrivo prima di scrivere codice: DE.12
NON DUPLICA NIENTE, LA COMPLETA.** Tre dei suoi cinque pezzi ci sono gia'
(la nitidezza come misura, la curva col tempo, la riga come constatazione e
non come rimprovero). **Mancano i due che contano di piu':** l'avviso
**all'apertura** (oggi la riga si legge solo alla risalita, cioe' **dopo**
essere sceso: chi apre la soglia non sa niente) e **la via del ritorno in un
gesto solo** (oggi `quantiGiorniValeUnNutrimento` esiste come numero e
**nessuna schermata offre il gesto che lo spende**).

#### DUE. Le quattro aperture fra cui si sceglie la porta: codice o immagini?

**NE' L'UNO NE' L'ALTRO: NON ESISTONO.** Questa e' la differenza piu' grande
fra il testo dell'ordine e il ramo, e la dichiaro per esteso.

Cercate in `lib/` le quattro parole `tana`, `crepa`, `pozzo` e `tronco`:
**nessuna occorrenza nel Viaggio**. Cercate `varco` e `apertura`: `varco`
esiste, ma e' **un'altra cosa**, cioe' `VarcoNellaNebbia`, il buco che la
mano apre nella nebbia dopo la discesa, e `apertura` compare solo come
l'apertura nella terra dipinta dal bosco, che e' **una sola**
(`PittoreDelBosco.apertoAX = 0.5`, `apertoAY = 0.62`).

**Quello che si sceglie oggi sulla soglia non sono quattro porte, sono TRE
VIE**, e sono le tre dell'enum `ViaDellaDomanda`: **scelta** (una delle sei
domande gia' scritte), **scritta** (la propria), **incontro** (nessuna
domanda, si scende solo per incontrarlo). Sono il **con che cosa** si scende,
non il **da dove**.

**Quindi non ci sono quattro asset mancanti dall'elenco della voce DE.05:**
ce ne sarebbero quattro da inventare insieme alla funzione che li userebbe, e
quella funzione non e' in questo ordine. **Non la costruisco**, e l'ordine non
la chiede: chiede di sapere. Adesso si sa.

#### TRE. L'orizzonte del Mondo di Sotto, e in quale fascia si aprono i varchi

**L'ordine dice "poco meno di meta' altezza". Sul ramo NON E' COSI'.**

Il fondo del Mondo di Sotto e' dipinto da `PittoreDellaNebbia._ilMondoDiSotto`
in `la_nebbia_e_l_animale.dart`, e l'orlo del terreno sta a
**`size.height * 0.62`**, cioe' al **sessantadue per cento dell'altezza
contato dall'alto**: il cielo prende il 62 per cento, la terra il 38.
**E' gia' un orizzonte basso**, e il documento che ne chiedeva uno basso e'
soddisfatto.

**In quale fascia si aprono davvero i varchi, che e' la parte della domanda
che conta.** I varchi non hanno una fascia loro: li apre il dito, e
`_laNebbia` monta un `GestureDetector` con `behavior: HitTestBehavior.opaque`
su tutto il corpo, quindi **un varco si puo' aprire ovunque, orizzonte
compreso**. Il raggio e' `lato * 0.22 * quantoEAperto`, cioe' il ventidue per
cento del **lato lungo**: su una finestra 1080 x 2040 sono circa
**449 pixel di raggio**, quasi novecento di diametro, cioe' **piu' larghi
dello schermo**. Un solo varco copre una fascia altissima, e **tre varchi
bastano** (`_apriIlVarco`: `if (_varchi.length >= 3)`), quindi in pratica la
nebbia si apre su tutta la scena e non su una fascia.

**La differenza conta, e conta al contrario di come l'ordine se l'aspettava:**
non e' l'orizzonte a essere troppo alto, e' **il varco a essere troppo
grande** perche' una fascia voglia dire qualcosa.

#### QUATTRO. Il conteggio delle domande del Viaggio: condiviso o suo?

**E' SUO, ed e' completamente separato.** Sono due contatori che non si
parlano, e li descrivo tutti e due.

**Il contatore del Viaggio** vive in `lib/core/viaggio/diario_dei_viaggi.dart`,
metodo `siPuoScendereOggi({required bool giaRiconosciuto})`. Non e' un tetto:
e' **una discesa per giorno di calendario**, confrontando la data dell'ultimo
viaggio con quella di oggi. Vale **solo finche' l'animale non e' riconosciuto**
(`if (giaRiconosciuto) return true`), quindi dopo la quarta discesa **non c'e'
nessun limite di nessun genere**. L'archivio e' locale, in
`SharedPreferences` sotto la chiave `viaggio.diario`, e **l'orologio e' quello
del telefono**.

**Il contatore dei Maestri** vive in
`lib/core/entitlement/question_allowance.dart`, e' per tier, ed e' elencato in
`lib/core/entitlement/budget_del_giorno.dart` insieme ad altri cinque budget
(approfondimenti, confronti, gettate, stese, sinastrie). **Il giorno glielo
dice il server** (`_giornoDelServer`, stringa opaca), proprio perche' spostare
l'ora del telefono avanti di un giorno rimetteva interi tutti i budget, e la
cosa era stata verificata eseguendo.

**PERCHE' SONO DUE, e la ragione regge.** Misurano due cose diverse: il
Viaggio conta **un rito che deve cadere in quattro giorni diversi perche' lo
dice il metodo di Harner**, i Maestri contano **quante risposte l'abbonamento
paga**. Il primo e' una regola di contenuto e non si compra, il secondo e' un
tetto commerciale e si compra con gli Eos.

**MA LA DOMANDA HA RAGIONE SULLA PARTE CHE SCOTTA**, e lo scrivo perche'
sara' il lavoro della voce DE.14: **dopo la rivelazione** il Viaggio comincia
a fare esattamente cio' che fanno i Maestri, cioe' **rispondere a domande**, e
la' i due contatori misurerebbero la stessa cosa. Quindi il confine e'
questo, e la voce DE.14 lo incide nel codice:

- **le quattro discese del riconoscimento** restano al contatore del Viaggio,
  una al giorno per tutti, **fuori dal tier e fuori dagli Eos**;
- **le domande dopo la rivelazione** entrano nel listino dei budget, cioe' in
  `BudgetDelGiorno`, dove c'e' gia' il posto, la riga del residuo e la porta
  della spesa.

Cosi' i due contatori **non divergono**, perche' non misurano mai la stessa
cosa.

### LE ALTRE DIFFERENZE FRA IL TESTO DELL'ORDINE E IL RAMO

**DE.01, la soglia.** L'ordine dice che la soglia sta in un riquadro, ed e'
vero: `_ilBoscoDellaSoglia` e' un `ClipRRect` con un `AspectRatio(1.15)`
dentro una colonna che scorre. **Lo slot dell'immagine esiste gia'**
(`SfondoDelMondoDiSotto`, che mostra `assets/img/mondo_di_sotto/soglia_bosco_v1.webp`
e ripiega sul bosco dipinto), quindi la voce e' un lavoro di **forma**, non di
aggancio.

**DE.05, i tre asset.** La cartella **`assets/img/mondo_di_sotto/` NON
ESISTE** sul ramo: nessuno dei tre file c'e'. I due slot dichiarati ci sono
davvero (`SfondoDelViaggio.bosco` e `SfondoDelViaggio.fondo`), e l'ordine ha
ragione a dire che il terzo, la parete del tunnel, chiede anche codice: oggi
`PittoreDelTunnel` dipinge gli anelli e **non ha nessun aggancio a una
texture**.

**DE.06, la durata della discesa.** L'ordine dice *"da quaranta a novanta
secondi"*. Sul ramo, `_quantoDura` in `viaggio_dello_sciamano_screen.dart` da'
**45 secondi alla prima discesa e 20 dalla seconda in poi**. Il novanta non
esiste piu'. La voce resta valida (venti e poi otto o dieci), ma il numero di
partenza e' 45, non 90.

**Il difetto di verita' delle sagome, e la sfumatura che l'ordine non ha.**
`PittoreDellAnimale` e' **davvero** una formula: disegna un corpo, quattro
zampe, un collo, una testa con due orecchie e una coda, tutto da un seme.
L'ordine dice che *"l'ombra che segui non e' l'animale che poi ti tocca"*:
**il seme pero' e' `a.name.hashCode`**, cioe' il nome dell'ombra che si sta
scegliendo, quindi la corrispondenza fra ombra e animale **c'e'**. Quello che
non c'e' e' la **somiglianza**: due semi diversi danno due quadrupedi
leggermente diversi, e nessuno dei dodici e' quel quadrupede. **La conclusione
dell'ordine resta giusta, la causa e' un'altra**: non e' che l'ombra sia
scollegata, e' che **l'ombra non e' un ritratto**, e per quattro dei dodici
(aquila, corvo, falco, gufo, e in un altro modo il serpente) e' **una specie
sbagliata**.

**Il corpo dei dodici.** `assets/img/animali/` ha dodici WebP con alpha vero,
piu' dodici miniature in `assets/img_thumb/animali/`. Le misure sono queste,
lette dai file:

| animale | larghezza x altezza |
|---|---|
| aquila | 688 x 807 |
| cavallo | 878 x 844 |
| cervo | 765 x 933 |
| corvo | 847 x 704 |
| falco | 805 x 749 |
| gufo | 537 x 865 |
| lince | 689 x 875 |
| lupo | 898 x 760 |
| orso | 900 x 736 |
| serpente | 808 x 772 |
| tartaruga | 936 x 688 |
| volpe | 894 x 575 |

**L'ordine dice "attorno a 900 per 760", ed e' la misura del lupo.** Le altre
undici vanno da 537 a 936 di larghezza e da 575 a 933 di altezza: **non sono
tutte della stessa forma**, e la lente dovra' misurarsi sulla forma di
ognuna, non su una misura sola.

**E l'ordine ha ragione sull'originale piu' grande: non c'e'.**
`output/animali/` esiste soltanto nel checkout principale, fuori da questo
albero e fuori da Git, e i PNG la' dentro sono **alle stesse identiche
misure**. La pipeline che li ha fatti e' `animali.py`, sempre fuori dal
repository, e passa da Vertex AI col modello `gemini-3-pro-image` sul progetto
`esoteric-circle`.

**La porta unica della condivisione esiste** ed e'
`lib/core/condivisione/porta_della_condivisione.dart`. La prova che enumera
i chiamanti **non si chiama come dice il commento dentro quel file**: il
commento nomina `test/una_sola_porta_per_condividere_test.dart`, che **non
esiste**. Le prove vere sono quattro, e la piu' vicina a quel mestiere e'
`test/i_tre_pulsanti_condividono_davvero_test.dart`. **Chi cita un file cita
qualcosa che si puo' aprire**, quindi quel commento va corretto in questo
ordine. La voce DE.08 passera' comunque dalla porta, senza scriverne
un'altra.

**La chiave della demo esiste ed e' una sola:** `AppFlags.isDemo` in
`lib/core/config/app_flags.dart`, oggi `true`, letta come **valore di
partenza di un parametro** in sei punti (per esempio
`ArtCatalog...({bool demo = AppFlags.isDemo})`). E' gia' la forma che la voce
DE.14 pretende: **un codice solo, due configurazioni**.

---

## LE SEDICI VOCI

*(Ogni voce si chiude qui sotto con cio' che e' stato fatto, cio' che e' stato
misurato e cio' che si e' visto sul telefono.)*
