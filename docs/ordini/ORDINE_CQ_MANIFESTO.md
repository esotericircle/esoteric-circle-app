# ORDINE CQ

Le regressioni del telefono, i testi che non rispondono, e il Cammino che
murava. 3 settembre 2026, ramo `claude/esoteric-circle-master-order-e798aj`.

---

## REGOLA ZERO: LE PREMESSE VERIFICATE PRIMA DI LAVORARE

**Tre premesse dell'ordine sono risultate false o imprecise, e la verifica ha
cambiato il lavoro.**

**1. "Nessuna lettura del piano da' trenta gettate."** FALSA. Il trenta e' il
tetto dell'Adepto, e discende dal piano come tutti gli altri. Le ore degli
screenshot lo dicono: la schermata delle Rune col "29 su 30" e' delle **20:09**,
quella dei Piani con l'Illuminato attivo in Demo e' delle **20:13**, quattro
minuti DOPO. Alle 20:09 il telefono era sull'Adepto. Non esiste nessuna terza
lettura: ogni punto che nomina il tetto delle gettate passa dalla matrice, e una
guardia lo pretende leggendo il sorgente.

**2. "La runa rovesciata non ha una lettura." NON CONFERMATA.** Misurato su
tutte e ventiquattro le rune nei due versi: righe vuote zero, righe uguali fra
dritto e rovescio zero. Su 365 sere di Tramonto, 93 rune escono rovesciate e
tutte e 93 portano la loro riga d'ombra. Anche il getto libero le legge tutte.
Le otto simmetriche sono l'unico caso senza lettura propria, e non e' un
difetto: capovolte sono identiche a se stesse. **La voce resta aperta in attesa
di sapere dove l'hai vista**, e intanto la guardia sorveglia la legge.

**3. "La Runa del Tramonto ha lo stesso difetto dell'Arcano." FALSA.** Il
Tramonto compone la sua chiave con la nascita INTERA, ora e minuti compresi.
Misurato con lo stesso metro dell'Arcano: due nascite diverse vedono la stessa
runa 34 sere su 365, contro le 15 attese da due estrazioni indipendenti.
L'Arcano il difetto ce l'aveva, il Tramonto no.

---

## PEZZO PRIMO, LE REGRESSIONI

### CQ1.01 e 1.01-bis — Il piano attivo e i suoi tetti

Il piano viveva in DUE posti che non si parlavano mai: `EntitlementService`
dentro il telefono, che il pulsante "Attiva in Demo" cambiava, e
`users/<uid>/stato/abbonamento.piano` su Firestore, **che nessuno scriveva** e
che valeva `free` per tutti. I tetti in se' non divergevano: a divergere era
quale piano ciascuna parte credesse attivo.

Adesso il pulsante chiama una callable nuova, `attivaIlPianoInDemo`, che nasce
chiusa a chiave. **Il passo che serve dal tuo PC sta nel PASSO 7 di
`docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md`.**

Secondo difetto della stessa voce: al no del server il client scriveva un
milione di gettate spese, e a schermo diventava "le trenta gettate del giorno
sono state fatte" dopo UNA gettata.

### CQ1.02 — Il cuore torna in alto a destra

Chiuso prima del rilancio. La guardia non misura l'angolo, che e' una scelta:
misura che il riquadro del cuore **non si interseca** con la freccia ne' col
punto interrogativo.

### CQ1.03 — Il ventaglio vive subito, il pulsante apre il responso

Si sceglie appena la schermata si apre. Il pulsante c'e' da subito, spento, e si
accende sulla terza carta: **e' lui che apre la lettura ed e' lui che consuma la
stesa.** Tre carte posate e poi ripensarci non costa piu' niente.

Provenienza: **ordine CO voce 07**, dello stesso giorno, che aveva messo il
pulsante PRIMA delle carte.

**La guardia e' di scena e non di sorgente, apposta.** La prima stesura di
questa voce aveva lasciato il pulsante dentro il blocco delle carte da pescare,
dove spariva esattamente quando doveva accendersi: nessuna lettura del file lo
avrebbe visto.

### CQ1.04 — Il suono della carta

**Due difetti, tutti e due gia' misurati nella coda dell'ordine CN, tutti e due
curati sulla musica e mai sugli effetti.** `play` di audioplayers non e' una
chiamata che finisce: attende un evento dalla piattaforma e, se non arriva,
resta appesa per sempre senza sollevare niente. E il lettore chiede di partenza
il fuoco audio esclusivo, che la musica di questa app non molla mai.

Curato anche il lettore dei toni, che aveva lo stesso identico `await`: era il
battito theta della Meditazione e del Sigillo del Sogno.

### CQ1.05 — La domanda libera si trova

Il campo c'era, e stava in fondo al pannello dopo altre cinque tendine, mentre
le domande suggerite stanno in cima. La guardia dell'ordine CO voce 05
pretendeva solo l'ORDINE e non la DISTANZA. Adesso sta subito sotto le
suggerite e prende la riga intera.

### CQ1.06 — Scegliere la gettata non getta

Provenienza: **ordine BF voce 05.a**. Le pillole restano dopo il responso, ed
e' giusto; toccarle adesso sceglie e basta, e getta il pulsante. Le pillole
sono salite sopra il pulsante, perche' adesso sono il primo dei due gesti.

### CQ1.07 — La stella non finisce sotto il testo

La costellazione vive in una fascia alta il 46 per cento dello schermo e il
blocco del testo comincia esattamente li'. Lo spostamento della parallasse
portava la stella fino a centosettantasei punti piu' in basso, cioe' dentro
l'area del testo, che mangia il tocco su tutta la sua superficie: **il dito
arrivava sulla riga "Tocca la stella che pulsa" invece che sulla stella.**

**PROVENIENZA IGNOTA.** La mappa della stella e il blocco del testo sono nati in
ordini diversi e nessuno dei due ha mai nominato l'altro.

### CQ1.08 — Nessun suono che tu non abbia scelto

**Ogni comando Material chiama il ritorno di sistema quando lo si preme, e su
Android quel richiamo fa suonare al SISTEMA il suo click e vibrare il
telefono.** In tutta l'app non c'era un solo `enableFeedback` scritto: valeva
ovunque il vero di fabbrica, su trentatre `InkWell` e su tutti i pulsanti del
tema.

**Nessuna guardia lo aveva mai visto, e non per distrazione**: il catalogo dei
suoni sorveglia i file negli asset, e il click di sistema non e' un file.

**PROVENIENZA IGNOTA**: e' il comportamento di fabbrica di Flutter.

**I tredici file audio che l'app puo' emettere**, perche' tu possa dire quali
non hai scelto: `firma`, `rivelazione`, `principio`, `rito_compiuto`, `soglia`,
`rifiuto`, `pietra`, `festa`, `carta`, `eos`, `custodisci`, `respiro_dentro`,
`respiro_fuori`. Sono tutti dichiarati nel catalogo e tutti esistono: una
guardia nuova pretende che i due insiemi coincidano nei due versi.

### CQ1.09 — Le push non sono mai partite

Ventitre chiamate a `scriviLeScelteDellePush` e ventitre 400, e la raccolta
`push_dei_doni` che non esiste. **Dei tre controlli scattava il SECONDO, il
fuso.** Il telefono mandava il nome corto di Dart, che su Android e' `CEST` o
`CET`, e il server pretende `Area/Citta`.

Adesso il nome IANA si ricava dal database dei fusi, che era gia' nel progetto
per gli avvisi locali, cercando la zona che si comporta come il telefono adesso
E fra sei mesi. **Il nome che esce puo' non essere quello che ti aspetti** (per
l'Italia esce `Africa/Ceuta`, che ha gli stessi scarti tutto l'anno): al server
serve per convertire un'ora, e due zone che si comportano uguale sono
intercambiabili per quello.

Provenienza: **ordine CI voce 07**, dove il controllo del server e il valore del
client sono nati nella stessa voce e non si sono mai parlati.

**AppCheck**: le ventitre validazioni fallite passano perche' `enforceAppCheck`
e' false su tutte e sei le famiglie di callable. Non l'ho acceso: accenderlo
senza un token di debug registrato chiuderebbe fuori il tuo telefono. E' un
passo che vuole il tuo PC e una decisione tua.

### CQ1.10 — Il rosso a intermittenza

Cadeva tre volte su quindici **coi numeri stampati sempre uguali**: non falliva
una misura, moriva l'isolato. `ParallaxController` nel costruttore si abbona
all'accelerometro e accende un `Ticker`, e in un test nudo l'errore del canale
arriva asincrono mentre il ticker resta acceso.

**Le soglie non sono state toccate.** Su venti giri, venti verdi.

### CQ1.11 — Il verde che valeva piu' di un rosso

Nella prova del rosso dell'ordine CP un innesto era rimasto verde. La
spiegazione di allora era giusta, ma **un freno che nessuna guardia vede e' un
freno che sparisce.** La guardia nuova misura il CONTATORE, che e' il posto dove
il freno agisce, invece delle feste, che sono un effetto lontano protetto da due
cause.

### CQ1.12 — Gli indici creati a mano

Le tre eccezioni create dalla console adesso sono dichiarate in
`firestore.indexes.json`, e sono quattro col gruppo dei ricordi. Una guardia del
server pretende che ogni gruppo interrogato dal giro notturno abbia la sua riga:
senza, chi rifa' il progetto da zero trova il giro rotto senza nessuna traccia.

### Il difetto del rilancio — Le monete

Il volo si fermava quando nessun borsellino dichiarava un riquadro misurabile, e
alla chiusura della festa la barra sta ancora tornando: **il suono usciva e le
monete no.** Adesso c'e' un ripiego, l'angolo in alto a destra.

E il tintinnio esce al **sessantacinque per cento**. Il volume e' una proprieta'
del suono e sta nel catalogo, accanto alla durata: e' l'unico dei tredici
abbassato, e una guardia pretende che resti l'unico.

---

## PEZZO SECONDO, LA LEGGE DEI TESTI

### CQ2.00 — La misura, prima di toccare un testo

`docs/testi/cosa_dicono_i_doni.md` porta le tre righe che ognuno dei cinque Doni
dichiara di se stesso. **Tutti e cinque si aprivano con un compito**, non solo
l'Arcano.

### CQ2.02 — L'Alba e il Soffio

Non si somigliavano: il Soffio costruiva il suo dono chiamando lo stesso rito
dell'Alba con la sola data, quindi **il rito, la parola e la risposta erano
letteralmente lo stesso oggetto.** Adesso il Soffio porta la sua materia, i
transiti veri sulla carta di chi legge. Il gesto e la parola restano comuni,
perche' il rito e' lo stesso.

Provenienza: **ordine CE voce 09**.

### CQ2.03 — Il rito annunciato che non c'era

Via `IL RITO DI OGGI` e le sue tre righe, da tutte e quattro le schermate. Il
componente e' stato cancellato, non solo smontato. Le tre righe restano sul dato
e descrivono il Dono nel menu' degli avvisi, dove una descrizione serve.

### CQ2.05 — L'Arcano e' del singolo

Nel seme entrava il solo NUMERO della carta natale, da uno a ventidue: **due
persone con la stessa carta natale vedevano lo stesso Arcano tutti i giorni, per
sempre**, anche nate a vent'anni di distanza. Adesso entra la nascita intera.

Misurato su quattordici coppie con la stessa carta natale: prima coincidevano
365 giorni su 365, adesso il caso peggiore e' 34 e la media 6,1.

Provenienza: **ordine CE voce 13**.

### CQ2.11 — I caratteri, la quarta volta

**Il ruolo `etichetta` valeva DODICI punti**, e il commento accanto diceva "vale
esattamente il pavimento" senza scrivere quanto fosse quel pavimento: duecentotre
usi in settantanove sorgenti, accanto a una prosa da diciotto.

**Il censimento non guardava i ruoli, solo le schermate**: cio' che non compare
li' dentro non esisteva. E' la quarta cecita' di quel documento in quattro
ordini.

Adesso quattordici, e non sedici perche' il maiuscoletto spaziato a sedici
manderebbe a capo le etichette lunghe. **La barra del Santuario resta a dodici**
per decisione dichiarata: l'ordine CF voce 03 l'ha abbassata da centotrentaquattro
a centododici punti perche' tu l'hai chiesta piu' bassa, e portarla a quattordici
avrebbe restituito otto di quei ventidue punti.

### CQ2.12 e CQ2.13 — Il Cammino murava

**L'ordine chiedeva di provare il difetto prima di curarlo, ed e' il difetto
piu' grosso di tutto l'ordine.**

Su 400 giorni di uso onesto con dodici arti al giorno:

| | prima | dopo |
| --- | --- | --- |
| traguardi soddisfatti | 112 | 112 |
| accesi | **13** | **112** |
| soddisfatti e mai accesi | **99** | **0** |
| ritardo massimo | 9 giorni | 0 giorni |
| gradini accesi sui tre sentieri | 4, 6, 3 | 36, 39, 37 |

I tre sentieri restavano fermi su "I cieli degli altri", "Quattro pietre girate"
e "Il tuo Archetipo", cioe' su arti che chi fa i Doni del giorno non tocca. **La
scala dell'ordine CP voce 01 non ritardava: murava.**

La cura e' la tua voce 2.13: **il tetto ferma la scena, mai l'accensione ne' gli
Eos.** Adesso maturano tutti i soddisfatti, si accendono tutti e i loro Eos
arrivano tutti; la scala vive in `meritaLaScena`, che decide chi si vede.

---

## CIO' CHE RESTA APERTO

**CQ2.01, 2.04, 2.06 (non confermata), 2.07, 2.08 (non confermata), 2.09, 2.10,
2.14, 2.15, 2.16.** I testi dei cinque Doni sono stati misurati e liberati dal
compito che li apriva, e l'Arcano e il Soffio hanno la loro materia; la
riscrittura frase per frase dei cinque responsi, il ponte fra il motore delle
date e la chat, e la misura dei promemoria non sono state fatte in questo giro.

---

## LE VOCI E IL LORO STATO

**Sigillato con l'ordine CQ voce 4.03, 4 settembre 2026.** REGOLA F: un ordine
non e' finito finche' il suo manifesto non e' sigillato coi marcatori
terminali, e senza sigillo il Collaudatore degli Ordini non lo vede affatto.

**Sette voci restano APERTE e il sigillo lo dice.** La guardia
`i_manifesti_sono_sigillati_test.dart` resta rossa finche' non sono zero, ed e'
la stessa legge di consegna che l'ordine CG ha portato per tre giorni: **un
manifesto sigillato con stati falsi e' peggio di un manifesto non sigillato.**

- **CQ.01** Pezzo primo 1.01, il piano attivo e i suoi tetti. **CHIUSA**, e la callable resta da distribuire dal PC del fondatore, PASSO 7.
- **CQ.02** Pezzo primo 1.02, il cuore sopra la freccia. **CHIUSA.**
- **CQ.03** Pezzo primo 1.03, il ventaglio vive subito. **CHIUSA.**
- **CQ.04** Pezzo primo 1.04, il suono della carta. **CHIUSA.**
- **CQ.05** Pezzo primo 1.05, la domanda libera si trova. **CHIUSA.**
- **CQ.06** Pezzo primo 1.06, scegliere la gettata non getta. **CHIUSA.**
- **CQ.07** Pezzo primo 1.07, la stella sotto il testo. **CHIUSA.**
- **CQ.08** Pezzo primo 1.08, nessun suono non scelto. **CHIUSA**, e i tredici file del catalogo sono elencati nel referto perche' il fondatore dica quali non ha scelto.
- **CQ.09** Pezzo primo 1.09, le push non partivano. **CHIUSA** per il fuso; **AppCheck resta spento** e accenderlo e' una decisione del fondatore col suo PC.
- **CQ.10** Pezzo primo 1.10, il rosso a intermittenza. **CHIUSA.**
- **CQ.11** Pezzo primo 1.11, il verde che valeva piu' di un rosso. **CHIUSA.**
- **CQ.12** Pezzo primo 1.12, gli indici creati a mano. **CHIUSA.**
- **CQ.13** Rilancio 1, da dove viene il trenta. **CHIUSA**: e' il tetto dell'Adepto, e le ore degli screenshot lo dicono.
- **CQ.14** Rilancio, le monete che non volavano e il loro volume. **CHIUSA.**
- **CQ.15** Pezzo secondo 2.00, cosa dicono i Doni, misurato. **CHIUSA.**
- **CQ.16** Pezzo secondo 2.01, i cinque Doni rivisti frase per frase. **APERTA**: i cinque Doni sono stati misurati e liberati dal compito che li apriva, e la riscrittura di ogni responso non e' stata fatta.
- **CQ.17** Pezzo secondo 2.02, l'Alba e il Soffio dicevano lo stesso. **CHIUSA.**
- **CQ.18** Pezzo secondo 2.03, il rito annunciato che non esiste. **CHIUSA.**
- **CQ.19** Pezzo secondo 2.04, la parola del giorno non dice a cosa serve. **APERTA.**
- **CQ.20** Pezzo secondo 2.05, l'Arcano non era individuale. **CHIUSA.**
- **CQ.21** Pezzo secondo 2.06, lo stesso difetto sul Tramonto. **FERMATA SU PREMESSA FALSA**: misurato, il Tramonto compone la sua chiave con la nascita intera e due nascite diverse vedono la stessa runa 34 sere su 365.
- **CQ.22** Pezzo secondo 2.07, il Sigillo del Giorno non dice a cosa serve. **FERMATA IN ATTESA DI DECISIONE**: nell'app non esiste nessuno "Sigillo del Giorno". Ci sono il Sigillo del Sogno, il Sigillo del Cerchio e il Sigillo dell'Intenzione, e serve sapere quale dei tre.
- **CQ.23** Pezzo secondo 2.08, la runa rovesciata senza lettura. **FERMATA SU PREMESSA FALSA**: misurato su tutte e ventiquattro le rune nei due versi, righe vuote zero e righe uguali zero. Le otto simmetriche sono l'unico caso, e in tradizione non hanno verso d'ombra.
- **CQ.24** Pezzo secondo 2.09, la domanda della parola senza risposta. **APERTA.**
- **CQ.25** Pezzo secondo 2.10, il responso della runa singola troppo lungo. **APERTA.**
- **CQ.26** Pezzo secondo 2.11, i caratteri ancora piccoli. **CHIUSA**: il ruolo etichetta valeva DODICI punti in duecentotre posti.
- **CQ.27** Pezzo secondo 2.12 e 2.13, il Cammino murava. **CHIUSA**: 112 soddisfatti e 13 accesi prima, 112 e 112 dopo.
- **CQ.28** Pezzo secondo 2.14, la curva non monotona. **FERMATA SU DECISIONE DEL FONDATORE**: il fondatore ha chiesto di non toccarla.
- **CQ.29** Pezzo secondo 2.15, il ponte fra il motore delle date e la chat. **APERTA.**
- **CQ.30** Pezzo secondo 2.16, i promemoria, misurare e non costruire. **APERTA.**
- **CQ.31** Aggiunta 4.01 e 4.02, i manifesti arretrati e la chiusura di CG. **CHIUSA.**
- **CQ.32** Aggiunta 4.03 e 4.04, questo manifesto e la REGOLA F. **CHIUSA.**

VOCI_TOTALI: 32
VOCI_CHIUSE: 22
VOCI_APERTE: 6
VOCI_FERMATE_SU_PREMESSA_FALSA: 2
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 1
