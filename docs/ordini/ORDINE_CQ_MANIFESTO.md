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

## AGGIUNTA CQ6, LA BUILD 2223 SUL TELEFONO E IL MOOD DEL CERCHIO

Il 4 settembre 2026 il fondatore ha provato la build 2223 sul telefono e ha
riaperto tredici voci, poi ne ha mandate altre dagli screenshot di una gettata
a tre rune, e infine ha dettato **il mood che vale per tutta l'app**:

> *"in titolo accattivante come prima risposta che riassuma tutta la risposta.
> sotto la risposta diretta che risponde alla domanda dell'utente: cosa
> significa per me? e adesso cosa devo fare. piu' sotto il tasto approfondisci
> per quegli utenti che cercano approfondimento e professionalita'. ogni
> responso deve diventare virale."*

**LA RISPOSTA ALLA DOMANDA SULLA VIRALITA', perche' da li' discende la card.**
Il fondatore ha chiesto di ragionare sul perche' uno condividerebbe un
responso. Le persone non condividono informazioni: **condividono identita'**.
Un responso si manda quando chi lo legge pensa *questo sono io* e vuole che gli
altri lo sappiano. Da qui tre vincoli misurabili: una frase sola al centro, il
simbolo che e' uscito a LUI e non un marchio, il testo di servizio ai bordi.

**E LA RAGIONE UNICA DELLE SETTE RIAPERTURE STA NEL CONTO DELLE ORE**: sette
volte su sette la guardia che aveva chiuso la voce misurava un pezzo sano
accanto al pezzo rotto. Da qui la regola nuova: **una voce nata da qualcosa che
il fondatore ha VISTO si chiude solo con una guardia che monta la schermata e
misura cio' che si vede.**

## AGGIUNTA CQ7, IL COLLAUDO A VIDEO COL TELEFONO COLLEGATO

Il 5 settembre 2026 il fondatore ha collegato l'Android e ha chiesto la prova
di accensione e **la verifica a vista di tutti i Doni**, poi anche di Oroscopo,
Tarocchi ed Estrazione Rune. La build 2226 e' stata accesa sull'archivio gia'
caricato: processo vivo, primo fotogramma disegnato, nessun crash, numero letto
DAL DISPOSITIVO 2226.

**E QUI SI VEDE A COSA SERVE IL COLLAUDO A VIDEO.** Tre difetti veri sono
usciti in un'ora, e nessuno di loro era visibile a una prova che gira senza
schermo: due li ha visti il fondatore, uno l'ho visto io guardando le immagini
del telefono. Tutte e tre le guardie nuove **sono nate rosse senza innesto**,
perche' il difetto era gia' in produzione.

**E DUE COSE CHE AVEVO RIPORTATO COME DIFETTI NON LO ERANO.** Il responso del
Soffio scorre, misurato: quattrocento punti su una trascinata di quattrocento.
I due zeri che mi avevano fatto dire il contrario erano miei, un controller
nullo e un dito posato al centro di una carta che ha il centro fuori schermo.
**Chi misura male trova difetti che non esistono**, ed e' la stessa specie di
errore che trova sane le cose rotte.

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
- **CQ.16** Pezzo secondo 2.01, i cinque Doni rivisti frase per frase. **CHIUSA**: i quattro strati della legge dei testi sono misurati su tutte e quattro le schermate dei cinque Doni, e due non li avevano. L'Arcano non portava nessuna fonte; il Tramonto la aveva solo dietro un pulsante in barra, cioe' chi legge il responso non incontrava mai da dove viene la runa. **Una risposta che non si puo' risalire chiede di essere creduta.**
- **CQ.17** Pezzo secondo 2.02, l'Alba e il Soffio dicevano lo stesso. **CHIUSA.**
- **CQ.18** Pezzo secondo 2.03, il rito annunciato che non esiste. **CHIUSA.**
- **CQ.19** Pezzo secondo 2.04, la parola del giorno non dice a cosa serve. **CHIUSA**: l'etichetta diceva "Parola del giorno", che e' il nome di una casella. Adesso dice di portarsela dietro, e sotto c'e' scritto dove va a finire.
- **CQ.20** Pezzo secondo 2.05, l'Arcano non era individuale. **CHIUSA.**
- **CQ.21** Pezzo secondo 2.06, lo stesso difetto sul Tramonto. **CHIUSA**, e la premessa era falsa: misurato, il Tramonto compone la sua chiave con la nascita intera e due nascite diverse vedono la stessa runa 34 sere su 365.
- **CQ.22** Pezzo secondo 2.07, il Sigillo del Giorno non dice a cosa serve. **CHIUSA**, e la fermata era una ricerca fatta male: **il Sigillo del Giorno esiste**, e' la bindrune che chiude ogni gettata di rune. Cercarlo fra i NOMI delle schermate invece che DENTRO le schermate ha prodotto una fermata dove c'era lavoro. Sotto il disegno c'era la nota della tradizione, che dice che cosa E' una bindrune e niente su cosa te ne fai: adesso c'e' prima la riga dell'uso, e la tradizione scende in fondo dove sta la fonte.
- **CQ.23** Pezzo secondo 2.08, la runa rovesciata senza lettura. **CHIUSA**, e la premessa era falsa: misurato su tutte e ventiquattro le rune nei due versi, righe vuote zero e righe uguali zero. Le otto simmetriche sono l'unico caso, e in tradizione non hanno verso d'ombra.
- **CQ.24** Pezzo secondo 2.09, la domanda della parola senza risposta. **CHIUSA**: il richiamo della sera diceva che parola era e finiva li', cioe' un fatto e non una risposta. Adesso dice che ha attraversato il giorno e che adesso si chiude.
- **CQ.25** Pezzo secondo 2.10, il responso della runa singola troppo lungo. **CHIUSA**: misurato, la scheda intera porta 264 caratteri contro i 50 della sola risposta, **cinque volte e un quarto**. A una runa sola il simbolo, la Voce e la strofa stanno dietro una porta che si apre in posto; a tre e a cinque rune restano dove erano, perche' li' sono il corpo della lettura.
- **CQ.26** Pezzo secondo 2.11, i caratteri ancora piccoli. **CHIUSA**: il ruolo etichetta valeva DODICI punti in duecentotre posti.
- **CQ.27** Pezzo secondo 2.12 e 2.13, il Cammino murava. **CHIUSA**: 112 soddisfatti e 13 accesi prima, 112 e 112 dopo.
- **CQ.28** Pezzo secondo 2.14, la curva non monotona. **FERMATA SU DECISIONE DEL FONDATORE**: il fondatore ha chiesto di non toccarla.
- **CQ.29** Pezzo secondo 2.15, il ponte fra il motore delle date e la chat. **CHIUSA**: il blocco entra nell'istruzione di sistema con al massimo tre eventi e il prossimo gradino del Cammino, senza promettere niente, e se non c'e' niente da dire non compare affatto. Passa dal contesto natale e non da un parametro nuovo, perche' `reply` e' implementato da undici doppioni nelle prove.
- **CQ.30** Pezzo secondo 2.16, i promemoria, misurare e non costruire. **CHIUSA**: la misura sta in `docs/promemoria/misura.md`. Ventuno eventi con una data calcolabile entro l'orizzonte, venti entro l'anno, cinque personali, e **sedici avvisi in un anno**, uno ogni ventitre giorni. Non e' un flusso.
- **CQ.31** Aggiunta 4.01 e 4.02, i manifesti arretrati e la chiusura di CG. **CHIUSA.**
- **CQ.32** Aggiunta 4.03 e 4.04, questo manifesto e la REGOLA F. **CHIUSA.**
- **CQ.33** Aggiunta 6.01, i caratteri dei Doni, la TERZA volta che il fondatore lo chiede. **CHIUSA**: la misura sta in `docs/doni/misura_per_misura.md`, Dono per Dono e riga per riga, perche' le prime due volte si erano contate le schermate e non i ruoli.
- **CQ.34** Aggiunta 6.02 e 6.06, il fischio che usciva dai responsi. **CHIUSA**: non era un file negli asset ne' il tema ne' un `InkWell`, era un tono **sintetizzato**, cioe' esattamente la cosa che nessuna delle tre guardie di allora poteva vedere. Guardia nuova `nessun_suono_sintetizzato_esce_dai_responsi`.
- **CQ.35** Aggiunta 6.03, la bolla "La risposta" che ricompariva in fondo al responso. **CHIUSA.**
- **CQ.36** Aggiunta 6.04, la riga blu che non si vedeva sul cosmo. **CHIUSA**: il contrasto era giusto, il fondo dichiarato no. Sul nero dichiarato il blu misura 4,58 e passa; sul cosmo vero misura **3,15**. Guardia nuova `nessun_accento_dichiara_un_fondo_che_non_ha`, che confronta le due superfici invece del solo rapporto.
- **CQ.37** Aggiunta 6.05, le stelle che non si toccavano. **CHIUSA**: la guardia di allora misurava la FUNZIONE che calcola la quota della stella, mai cosa le sta sopra una volta disegnata. Guardia nuova `la_stella_si_tocca_davvero`.
- **CQ.38** Aggiunta 6.07, i cuoricini a destra ma non centrati. **CHIUSA**: la guardia della voce 1.02 pretendeva che il cuore NON si intersecasse con la freccia Indietro, che e' una cosa diversa dallo stare alla quota del titolo. Guardia nuova `il_cuore_e_centrato_col_titolo`.
- **CQ.39** Aggiunta 6.08, il suono della carta che non si sentiva. **CHIUSA**, e la misura dice che **non si era mai sentito da quando esiste**: usciva dalla porta, e un secondo suono lo fermava nello stesso fotogramma. Guardia nuova `la_carta_suona_toccandola`.
- **CQ.40** Aggiunta 6.09, la terza carta che sembrava aprire un'altra schermata. **CHIUSA**: l'ingrandimento di Medora era legato a `_complete` e scattava insieme allo svuotamento del ventaglio. Adesso aspetta il RESPONSO. Guardia nuova `la_terza_carta_non_apre_una_schermata`.
- **CQ.41** Aggiunta 6.10, **la piu' grave secondo il fondatore**, la domanda libera senza risposta. **CHIUSA**: la domanda entra nel responso e ci si legge. Guardia nuova `la_domanda_entra_nel_responso`, e due pretese accoppiate che restavano verdi sono state separate, perche' il consiglio finisce con la domanda e togliere l'apertura non toglieva le parole.
- **CQ.42** Aggiunta 6.11, l'Estrazione Rune intatta. **CHIUSA.**
- **CQ.43** Aggiunta 6.12, la porta della Demo che non si trovava piu'. **CHIUSA**: il controllo del comando poggiava su uno **sha scritto a mano**, che invecchia a ogni consegna. Guardia nuova `un_comando_di_distribuzione_ha_il_suo_controllo`.
- **CQ.44** Aggiunta 6.13, il conto delle ore, chiesto per nome. **CHIUSA**: sta in `docs/ordini/CQ_CONTO_DELLE_ORE.md`, e porta anche la ragione unica per cui sette voci dichiarate chiuse non lo erano sul telefono, cioe' che **sette volte su sette la guardia misurava un pezzo sano accanto al pezzo rotto**.
- **CQ.45** Aggiunta 6.14, "e la ultimo quarto", dagli screenshot delle rune. **CHIUSA**: la fase lunare si dice come si dice, e passa da `MoonPhase.comeSiDice`.
- **CQ.46** Aggiunta 6.15, le misure diverse dentro la stessa scheda di runa. **CHIUSA**: quattro corpi in una bolla sola, adesso uno.
- **CQ.47** Aggiunta 6.16, la stessa formula dell'eco ripetuta su tutte e tre le rune. **CHIUSA**: la domanda si nomina UNA volta sola, sulla prima runa.
- **CQ.48** Aggiunta 6.17, il Sigillo del Giorno che non rispondeva. **CHIUSA**: adesso risponde con cio' che le tre rune intrecciate portano INSIEME, e non ripete le tre letture.
- **CQ.49** Aggiunta 6.18, il collaudo a video in autonomia. **CHIUSA**: `tool/collaudo_a_video.py` apre l'app sul telefono, tocca e rilegge l'albero. Nasce dalla riga del conto delle ore: una voce nata da uno screenshot non si chiude con una guardia che legge il sorgente.
- **CQ.50** Aggiunta 6.19, la parete di testo delle gettate. **CHIUSA**: una scheda di runa portava **611 caratteri**, la gettata a tre 1833, la Croce delle Cinque 3055. A vista su tre rune si passa da 1499 caratteri a 690, e le fonti scendono dietro la porta per TUTTE le gettate, non piu' per la sola runa singola.
- **CQ.51** Aggiunta 6.20, i tre paragrafi delle bolle, giallo bianco giallo, dettati dal fondatore. **CHIUSA.**
- **CQ.52** Aggiunta 6.21, il tetto del piano nuovo, il 49 invece di 50. **CHIUSA**: la gettata fatta in Demo restava a intaccare il tetto dell'Illuminato. Adesso chi sale trova il tetto intero e chi scende e risale non guadagna niente. Guardia nuova `il_tetto_del_piano_nuovo_nasce_intero`.
- **CQ.53** Aggiunta 6.22, i paragrafi della bolla della runa con misure diverse fra loro. **CHIUSA.**
- **CQ.54** Aggiunta 6.23, **VENTI PUNTI, E UNA MISURA SOLA.** **CHIUSA**: la prosa che si legge vale venti in tutta l'app. Per un giro c'e' stato accanto un ruolo nuovo, `letturaAmpia`, per non spostare le schermate che reggevano: era **un secondo conto della stessa cosa**, e la guardia della misura unica lo ha detto subito. Dieci misure scritte a mano sotto i quindici punti, sette nel Tramonto e tre nel Sigillo del Sogno, sono tornate ai ruoli.
- **CQ.55** Aggiunta 6.24, **DA DOVE NASCE**, la porta unica dell'approfondimento. **CHIUSA**: un componente solo per nove arti. Non si chiama "Approfondisci" perche' quella parola dice cosa fa il pulsante; "Da dove nasce" dice cosa trovi dietro, ed e' anche la promessa che il Cerchio fa da sempre, che nulla e' inventato.
- **CQ.56** Aggiunta 6.25, **IL TITOLO E' GIA' LA RISPOSTA.** **CHIUSA**: i nove titoli dei Doni avevano il cielo per soggetto e la parola del giorno in coda, dopo una subordinata. Adesso il soggetto e' chi legge e la parola sale in testa: da 62 caratteri di media a 39. Guardia nuova `il_mood_del_cerchio`.
- **CQ.57** Aggiunta 6.26, **LA CARD CHE UNO MANDA DAVVERO.** **CHIUSA**: una frase sola al centro, il simbolo SUO e non un logo, il testo di servizio ai bordi, nove sedicesimi. Montata sulle Rune, le altre arti la prendono nell'ordine dopo, e la guardia lo dichiara invece di fingere che siano gia' tutte passate. Guardia nuova `la_card_si_manda`.
- **CQ.58** Aggiunta 6.09 riaperta, il ventaglio dei tarocchi spariva alla terza carta. **CHIUSA**: la prima cura aveva rimesso cio' che ARRIVA, le carte e il pulsante, senza guardare cio' che SPARISCE. Alla terza carta se ne andava tutto il blocco legato a `!_complete`, **ventaglio compreso**: la pagina perdeva il suo oggetto piu' grande in un colpo. Adesso il ventaglio se ne va col RESPONSO e non con l'ultima carta, attenuato al quaranta per cento per dire che ha finito. Guardia nuova dentro `la_terza_carta_non_apre_una_schermata`, nata rossa: prima 1, dopo 0.
- **CQ.59** Aggiunta 6.27, la materia storica apriva la scena dell'Estrazione Rune. **CHIUSA**: prima ancora di gettare si leggevano Tacito e la Germania al capitolo dieci, l'Edda poetica, la Voluspa, la Gylfaginning e il metodo di calcolo. E' l'informazione messa all'inizio, cioe' l'opposto della legge del mood. Adesso resta a vista il nome della gettata e la materia scende dietro `Da dove nasce`. Guardia nuova `la_materia_storica_non_apre_la_scena`, nata rossa: venti blocchi a vista dei quali uno di materia storica, zero porte.
- **CQ.60** Aggiunta 6.29, la frase degli Angeli portava un numero scritto a mano. **CHIUSA**: diceva "Tre nomi dalla tradizione dei settantadue" e ne mostrava DUE, perche' il terzo nasce dall'ora di nascita e quell'ora non era stata data. Il numero adesso viene dalla lista, e quando il terzo manca **si dice perche'**. Guardia nuova `il_numero_degli_angeli_segue_il_dato`, nata rossa su tutte e due le pretese.
- **CQ.61** Aggiunta 6.28, il responso del Soffio. **CHIUSA**, e la premessa era falsa: il responso SCORRE, quattrocento punti su una trascinata di quattrocento. Resta vero che e' alto 878 punti dentro una finestra di 263, cioe' se ne vede il trenta per cento, e **dargli piu' spazio si e' provato e misurato**: a cinque contro quattro la scheda copre 15,1 punti del pulsante del respiro, a quattro contro cinque ne copre 90,4, e quello e' un difetto che Mauro aveva gia' fatto riparare. Due pretese vere in conflitto su uno schermo che non cresce: la proporzione resta sei contro tre e la guardia misura la RAGGIUNGIBILITA', che e' cio' che si puo' garantire. Se il trenta per cento non basta, la via e' una decisione sul Soffio, non un numero.

VOCI_TOTALI: 61
VOCI_CHIUSE: 60
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 1
