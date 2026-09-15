# ORDINE BV, I DIFETTI CHE IL FONDATORE VEDE SULLA 2209

Ordine del fondatore del 27 agosto 2026, sostituito dal fondatore stesso mentre
era in corso. Guardia `test/ordine_bv_guard_test.dart`.

**Come si legge questo ordine, parole del fondatore**: "sostituisci l'ordine
precedente con questo di seguito perche' l'architetto continua a prendere
decisioni sbagliate che puoi prendere tu con maggiore efficienza". Dentro
l'ordine ci sono i fatti osservati sulla build 2209 e l'esito atteso, **non le
soluzioni**: la causa la trova chi esegue e la cura la sceglie chi esegue. Ogni
forma scelta e' misurata e il numero e' scritto qui.

## Le sei voci

- **BV.01** Le sottolineature gialle sui due ingrandimenti. **CHIUSA.** La
  causa non era la trasparenza del velo, che l'ordine BU aveva
  gia' reso nero pieno: erano righe DISEGNATE. Un testo senza un `Material` fra
  i suoi antenati ricade sul `DefaultTextStyle` di sistema, che porta una doppia
  sottolineatura gialla, e una rotta aperta con `showGeneralDialog` un `Material`
  non ce l'ha. Le due rotte adesso se lo mettono, e una prova le enumera tutte.
- **BV.02** La festa che copre la riflessione. **CHIUSA.** L'ordine BU aveva
  messo la dichiarazione dove l'animazione parte, e per la festa che nasce
  mentre gira era giusto; il caso vero e' un altro, ed e' quello che il fondatore
  continuava a vedere: posando l'ultima carta il traguardo matura NELLO STESSO
  GESTO, e la festa trovava la scena ancora libera. Adesso chi sta per riflettere
  lo dichiara PRIMA di muovere il cammino. La galleria dei VIP era la quarta
  scena che animava senza dirlo, e adesso lo dice.
- **BV.03** I limiti delle stese e il censimento degli illimitati. **CHIUSA.**
  Le stese passano a `[1, 4, 7, 20]` su server e listino, e niente e' piu'
  illimitato su quella riga. Il censimento del resto e' qui sotto, con i numeri:
  **non e' stato toccato niente altro**, perche' quanto valgono quelle righe e'
  una decisione del fondatore.
- **BV.04** La carta chiave non si distingue. **CHIUSA.** La forma scelta e' la
  SCALA: la chiave e' piu' grande delle altre due del **10,0 per cento**, che si
  legge da un metro e non aggiunge un pixel sopra la figura. La cornice azzurra
  resta a filo del bordo e diventa piu' spessa.
- **BV.05** "Scegli la tua domanda" per prima e con un colore suo. **CHIUSA.**
  E' la prima tendina della griglia e porta il bagliore del Maestro invece del
  grigio delle altre, con un contrasto di **4,73 a 1** misurato sui pixel.
- **BV.06** Lo standard del responso su tutte le schermate. **CHIUSA.** Gli otto
  responsi dell'app portano tutti misura di lettura e colore primario; sei
  passano dalla porta unica dei paragrafi, e le due eccezioni sono dichiarate.
  Nessuna schermata trabocca, ne' a 360 per 797 ne' a 360 per 640.

## BV.01, le righe gialle: la causa e la prova

| misura | esito | preteso |
| --- | --- | --- |
| testi della carta aperta che ricadono sullo stile di sistema | 0 su 5 | 0 |
| testi del ritratto aperto che ricadono sullo stile di sistema | 0 su 3 | 0 |
| rotte aperte a mano in `lib`, e quante senza `Material` | 2, zero nude | 0 nude |

**Il rosso dimostrato**, con l'iniezione verificata nel sorgente prima di
leggere l'esito: tolto il `Material` da `carta_ingrandita.dart`, i testi che
ricadono sullo stile di sistema passano da 0 a **5 su 5**, e la prova stampa la
decorazione vera che ereditano, `TextDecoration.underline` di colore
`Color(alpha 1, red 1, green 1, blue 0)`, cioe' il giallo pieno che il fondatore
vedeva. **La cura e la causa coincidono**, e questo e' cio' che l'ordine BU non
aveva dimostrato.

## BV.02, la festa e la riflessione: l'ordine delle due righe

| misura | esito | preteso |
| --- | --- | --- |
| scene che dichiarano una riflessione e muovono il cammino | 3 | tutte in ordine |
| di queste, quante dichiarano DOPO aver mosso il cammino | 0 | 0 |
| riflessioni dichiarate sul sorgente | 4 su 4 | 4 |

**La grandezza misurata e' l'ORDINE delle due righe nel sorgente**, ed e' quella
da cui dipende tutto: una dichiarazione che arriva dopo la registrazione del
gesto lascia scoperto esattamente l'istante in cui il traguardo matura.

**Il rosso dimostrato**: spostata la dichiarazione della stesa sotto
`RegiaDelCammino.dopoUnGesto`, la prova cade e stampa il punto esatto, "dichiara
al carattere 29.990, muove il cammino al 29.453". Rimessa al suo posto, verde.

**Le scene sono passate da tre a quattro**: alla stesa, all'Oroscopo e alla
Sinastria si aggiunge la galleria dei VIP, dove l'annuncio copre l'intera
schermata del VIP e non la sola chiamata, perche' quella scena non sa quando
l'animazione finisce e legarla all'animazione avrebbe lasciato la festa in coda
senza nessuno a farla ripartire.

## BV.03, i limiti e il censimento degli illimitati

I limiti delle stese complete, sul server e sul listino:

| piano | stese al giorno |
| --- | --- |
| Viandante | 1 |
| Iniziato | 4 |
| Adepto | 7 |
| Illuminato | 20 |

**Il censimento di cio' che resta illimitato, che il fondatore ha chiesto.** Sul
server ci sono **sei budget**, e **sette celle senza tetto**:

| budget | piani senza tetto |
| --- | --- |
| domande | Illuminato |
| approfondimenti | Illuminato |
| confronti | Illuminato |
| gettate | Iniziato, Adepto, Illuminato |
| sinastrie | Illuminato |

Nel listino promettono ancora illimitato **sei righe**: `Confronti nel Cerchio`,
`Domande a un Maestro`, `Vai piu' a fondo`, `Tarocchi carta singola`, `Gettate
di rune`, `Sinastria VIP`. **Nessuna di queste e' stata toccata**: il fondatore
ha chiesto il conto, non la cura, e quanto valgano e' una sua decisione. Il conto
e' scritto dentro una prova, quindi una riga nuova che nascesse illimitata
farebbe cadere il conto invece di passare in silenzio.

**Il rosso dimostrato**: rimesso `null` nella cella dell'Illuminato delle stese,
le celle senza tetto passano da sette a **otto** e la prova cade nominando la
riga.

## BV.04, la carta chiave: la forma scelta e il suo numero

**La forma la decideva chi esegue, e la scelta e' la SCALA.** Una linea che
segue il bordo si confonde col profilo dorato della carta, ed e' cio' che il
fondatore ha detto guardando la 2209; una differenza di dimensione si legge da un
metro, non copre un pixel della figura e non aggiunge nessun colore sopra.

| misura | esito | preteso |
| --- | --- | --- |
| altezza della carta chiave contro le altre due | 162,8 contro 148,0 e 148,0 | almeno +8 per cento |
| scarto in percentuale | **+10,0 per cento** | >= 8 |
| larghezza della cornice contro il riquadro della carta | 108,5 contro 108,5 | uguali |
| aria fra la chiave cresciuta e la carta vicina | 3,1 punti | > 0 |
| carte fuori dai bordi su 360 per 797 | nessuna | nessuna |
| carte fuori dai bordi su 360 per 640 | nessuna | nessuna |
| azzurro attorno alla chiave contro le altre (misura BN.05) | 1.469 contro 0 e 275 | almeno una volta e mezza |

**La cornice staccata e' stata provata e scartata, col numero.** Staccarla di sei
punti si poteva, ma fra una carta e la vicina ci sono **otto punti soli**: con la
carta cresciuta del dieci per cento la cornice sporgeva di 11,5 punti e finiva
DENTRO la carta accanto, e la prova lo ha detto prima che lo vedesse il
fondatore. Fra le due strade si e' tenuta la scala, e alla linea e' bastato
passare da due a tre punti di spessore per non confondersi col bordo dorato.

**Il rosso dimostrato**: riportata la scala a 1,0, lo scarto passa da 10,0 a
**0,0 per cento** e la prova cade dicendo che a colpo d'occhio non si distingue.

## BV.05, la domanda per prima e col suo colore

| misura | esito | preteso |
| --- | --- | --- |
| ordine di lettura delle tendine | la domanda, il tipo di stesa, la chiave di lettura, il mazzo | la domanda per prima |
| colore del titolo della domanda | il bagliore del Maestro, `4C7BE8` | diverso dalle altre |
| colore del titolo delle altre | il grigio del testo secondario | - |
| contrasto sul fondo DIPINTO | **4,73 a 1** | >= 4,5 |
| contrasto su Medora, Aura e Caligo (fondo dichiarato) | 4,67, 9,10 e 5,05 | >= 4,5 |

**Il colore viene dalla palette, non da una costante nuova**: la prova legge il
bagliore dalla tendina stessa e lo confronta col colore dipinto. Il contrasto si
conta sul fondo che si vede davvero, non su quello dichiarato, perche' il
riquadro e' semitrasparente e sotto ci passa il cosmo.

**Due rossi dimostrati**: tolto il rilievo, il titolo della domanda torna dello
stesso colore delle altre e la prova cade; rimessa la domanda dopo il tipo di
stesa, l'ordine di lettura diventa "il tipo di stesa, la domanda, ..." e la prova
cade nominando la prima.

## BV.06, lo standard del responso su tutte le schermate

Lo standard nato con l'ordine BU sul consiglio di Medora e' fatto di quattro
cose: misura di lettura, colore primario, paragrafi separati dalla porta unica,
titolo oro sopra. **Gli otto responsi dell'app, misurati uno per uno:**

| responso | misura | colore | porta unica |
| --- | --- | --- | --- |
| l'Oroscopo | lettura | primario | spezza col metodo comune |
| la Sinastria | lettura | primario | si |
| le Rune | lettura | primario | si |
| gli Angeli | lettura | **primario, cambiato qui** | si |
| l'Archetipo | lettura | **primario, cambiato qui** | si |
| l'Animale Guida | **lettura, cambiata qui** | primario | **si, cambiato qui** |
| il Sogno | **lettura, cambiata qui** | primario | **si, cambiato qui** |
| l'Alba | **lettura, cambiata qui** | inchiostro della carta | no, dichiarato |

**Le due eccezioni alla porta unica si dichiarano.** L'Oroscopo scrive a macchina
e chiama `spezzaInParagrafi` da se', ed e' l'eccezione che la guardia di casa
gia' conosce. La carta dell'Alba e' un oggetto stampato che si condivide:
spezzarla in paragrafi ne cambierebbe l'ingombro, e li' l'ingombro e' fisso.

**Nessuna schermata trabocca, e nessuna si e' dovuta dichiarare inadatta.**

| schermata | 360 per 797 | 360 per 640 |
| --- | --- | --- |
| Animale Guida, messaggio del giorno | nessun traboccamento | nessun traboccamento |
| Sogno, saluto della notte | nessun traboccamento | nessun traboccamento |
| Alba, orientamento del giorno a 18 punti | nessun traboccamento | nessun traboccamento |

Agli Angeli e all'Archetipo e' cambiato **solo il colore**: la misura era gia'
quella di lettura, e un colore non muove un pixel di impaginazione. La prova
verifica proprio questo, che la misura non sia stata toccata insieme al colore.

**Il rosso dimostrato**: riportato il saluto del Sogno alla misura del corpo, il
censimento degli otto stampa "il Sogno SOTTO MISURA" e la prova cade nominando
file e riga.

## Le prove nuove e quelle allargate

Nuove: `test/niente_sottolineature_gialle_test.dart`,
`test/la_domanda_viene_prima_test.dart`,
`test/il_responso_si_legge_ovunque_test.dart`.
Allargate: `test/la_chiave_e_il_consiglio_si_vedono_test.dart` con le due misure
della voce 04, `test/la_festa_aspetta_la_riflessione_test.dart` col gruppo della
voce 02 e la quarta scena, `test/il_gating_della_stesa_test.dart` col censimento
degli illimitati. Adattata: `test/dream_rite_screen_test.dart`, che leggeva il
saluto come `Text` e adesso lo legge dal blocco narrato.

## La suite, alla chiusura dell'ordine

**3.724 prove verdi e 2 rosse**, con `TZ=Europe/Rome`, **ad albero davvero
fermo**: l'impronta `sha1` di tutti i sorgenti sotto `lib`, `test`, `docs`,
`tool`, `functions/src` e del `pubspec.yaml`, presa prima del primo test e dopo
l'ultimo, e' la stessa, `e484e6c1`. I due rossi sono i due dichiarati:
l'attribuzione cieca dall'ordine BP e `niente_lavoro_non_spinto`, che si chiude
col commit e con la spinta. `flutter analyze`: **zero avvisi**.

**Un rosso di passaggio, detto perche' e' successo**: nel giro diagnostico
`il_cielo_ha_i_suoi_livelli_test` era caduto, e da solo passava; nel giro buono
e' verde. Non e' stato toccato niente per farlo passare.

MARCATORI, per la guardia:
VOCI_TOTALI: 6
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 6
