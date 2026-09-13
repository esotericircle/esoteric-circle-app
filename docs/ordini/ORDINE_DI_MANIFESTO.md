# ORDINE DI, IL VIAGGIO DELLO SCIAMANO DIVENTA UN PERCORSO

**Sigla:** DI. **Data:** 12 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`.

**Vincolo permanente:** tutta l'intelligenza a runtime gira su Gemini e
Vertex AI, mai su API Anthropic. **Nessuna build senza ordine del fondatore.**

VOCI_TOTALI: 17
VOCI_CHIUSE: 14
VOCI_SBLOCCATE_E_APERTE: 0

---

## DI.09, prima cosa: IL VIDEO. VERIFICATO E NEL RAMO

L'ordine chiede di verificare il file **prima di qualunque altra cosa**, e di
fermarsi se non c'e'. **Alla prima verifica non c'era**: la testa remota era
`e0e8b825`, e il file non stava su nessuno dei tredici rami remoti, ne' nella
cartella del progetto, ne' fra Desktop, Download, Documenti, Video e il disco
D:. La voce e' rimasta ferma, senza video sostitutivi e senza segnaposto.

**Il fondatore l'ha poi caricato**, e prima di copiarlo:

| misura | attesa | trovata |
|---|---|---|
| dimensione | 2.262.337 byte | 2.262.337 byte |
| SHA-256 | `0db19531...c12c77d` | identica, sul file caricato e sulla copia |
| misura | 720 x 1280 | 720 x 1280 |
| cadenza | 24 fps | 24/1 |
| durata | 8,000 s | 8,000000 s |
| fotogrammi | 192 | 192 dichiarati e **192 contati** uno per uno |
| codifica | H.264 high | h264, profilo High |
| audio | muto | un solo flusso |
| indice in testa | si' | `ftyp moov free mdat` |

Copiato senza ricodifica ne' rinomina in
`brand_assets/mondo_di_sotto/discesa_v1.mp4`, commit `2928464c`, e **il blob sul
remoto ha la stessa impronta**. La cartella e' dichiarata nel pubspec accanto a
`brand_assets/sentieri/` e `docs/stato_asset.json` la conosce.

---

## DI.09, LA DISCESA DIVENTA UN VIDEO GOVERNATO DAL DITO. CHIUSA NEL CODICE

**Cosa vede la persona adesso.** Dopo la soglia, lo schermo pieno mostra il
primo fotogramma del filmato del fondatore: il bosco dall'alto e le radici che
convergono nel buco. Il tamburo comincia a battere prima del dito. Col dito
premuto il filmato va, e sotto il polpastrello pulsa un alone d'oro alla
cadenza del tamburo; col dito alzato il filmato rallenta in mezzo secondo e si
ferma, e il tamburo continua. Dalla seconda discesa, dopo un secondo e mezzo,
in basso compare *"Salta la discesa"*. In fondo, la luce dorata dell'ultimo
fotogramma si scioglie nella nebbia in mezzo secondo.

**Dove sta.** `lib/features/maestri/caligo/viaggio/la_discesa_in_video.dart`,
nuovo, e la schermata del Viaggio lo monta al posto del tunnel a `Timer`.

| voce dell'ordine | come e' fatta | chi la pretende |
|---|---|---|
| dito premuto: play | al tocco `velocita(0.1)` e `avvia`, nello stesso istante | *il dito governa il filmato* |
| dito alzato: da 1.0 a 0 in 500 ms, poi pause | dieci gradini da 50 ms, 0,9 ... 0,1 e al decimo `sospendi` | *la rampa del dito* e *il dito governa il filmato* |
| dito ripremuto: da 0 a 1.0 in 500 ms | al tocco un decimo, poi nove gradini: uno pieno a 450 ms | *la rampa del dito* |
| nessun `seekTo` | la parola non c'e' nel sorgente, e `avvia` a filmato finito non chiama `play`, che tornerebbe all'inizio con un salto | *il lettore vero non salta mai* |
| si inizializza mentre si sceglie la domanda | il lettore nasce con la soglia, `initState` della schermata | la strada di ogni prova del Viaggio |
| primo fotogramma fermo, mai nero | `discesa_v1_primo_fotogramma.webp` sotto, e il filmato sopra **solo dopo il primo fotogramma vero**: una texture appena nata puo' essere nera | *mai uno schermo nero*, fotografata: 2,4 per cento di nero, varianza 549 |
| tamburo separato, continuo, anche a dito alzato | quarto lettore del motore unico, in ciclo, dalla palette; la musica gli scende sotto finche' batte | *il tamburo comincia con la discesa* |
| alone sotto il polpastrello, circa 4,5 al secondo | `AloneDelPolpastrello`, col `Timer` e non col controller; il primo battito cade sul tocco | *l alone sta sotto il polpastrello* e *pulsa a quattro battiti e mezzo*: 45 in dieci secondi |
| nessuna barra di avanzamento | nessun indicatore nel sorgente | *il lettore vero non salta mai e non mostra barre* |
| dissolvenza di 500 ms verso la nebbia | sopra la nebbia svanisce l'ultimo fotogramma vero, poi il decodificatore si libera | *alla fine del filmato*: 1,00, 0,52 a meta', poi niente |
| "Salta la discesa" dalla seconda, dopo 1,5 s | fuori dalla zona del dito, cosi' toccarlo non fa partire il filmato | *alla prima non si salta* e *dalla seconda compare* |
| il tunnel resta come riserva | se il lettore fallisce si scende nel tunnel, con la stessa rampa e la stessa durata | *se il filmato non si prepara* e *la discesa dura quanto il filmato*: 8,22 s |
| il codice mai raggiunto del pittore | tolto: diciotto anelli, spirale e filo di luce, che si disegnavano solo senza roccia | `la_discesa_riempie_lo_schermo`, riscritta sul widget vero |
| riprendere da `RivelazioneInVideo` | stessa porta, `LettoreDellaDiscesa`, stessa promessa di non lanciare, stessa copertura `BoxFit.cover` | |
| nessuna dipendenza nuova | `video_player` e `audioplayers` c'erano gia' | |

**LA DURATA E' CAMBIATA, e lo dico per nome.** La discesa durava venti secondi
col dito premuto, ordini DE voce 06 e DG voce 06. Adesso dura quanto il
filmato, otto secondi, e con la rampa del tocco 8,22. Le due costanti
`primaDiscesa` e `discesaConosciuta` non ci sono piu', e la guardia che le
misurava si chiama adesso `la_discesa_dura_quanto_il_filmato`. Anche la
dissolvenza verso la nebbia passa da un secondo e due decimi a mezzo secondo,
come chiede l'ordine.

**IL TAMBURO NON SUONA ANCORA, perche' il file non c'e'.** Nel progetto non
esiste nessun suono di tamburo: il *tamburo* del richiamo e' una vibrazione. Lo
slot e' pronto, `assets/audio/tamburo_della_discesa.mp3`, e le misure per
sceglierlo stanno in `assets/audio/LEGGIMI.md`: tamburo a cornice, 4,5 battiti
al secondo, anello senza cucitura. Non l'ho sintetizzato: il fondatore ha gia'
detto del responso che un suono che non ha scelto lui non lo vuole. Finche'
manca la discesa resta muta e la musica non si abbassa sotto un silenzio.

**UN SECONDO DIFETTO, trovato dalla suite intera, e chiuso.** La guardia `nessuna_sorgente_resta_accesa_in_sottofondo` ha preso il lettore del filmato, che non ascoltava il ciclo di vita dell'app. Il filmato e' muto, ma `video_player` al ritorno riprende da solo cio' che stava andando: chi riceveva una telefonata col dito premuto, tornando, avrebbe visto la discesa ripartire senza dito. Adesso ci si ferma allo stato `inactive`, prima che `video_player` guardi. **Padre: DI.09**, prima stesura.

**UN DIFETTO TROVATO STRADA FACENDO, e chiuso.** La prova della durata ha
visto un battito da cinquanta millisecondi restare acceso dopo ogni discesa: il
dito che si alza dopo la fine arriva lo stesso al widget smontato, perche' il
sistema consegna l'alzata a chi ha ricevuto il tocco. Adesso a discesa finita
non si riaccende niente. **Padre: questa stessa voce, DI.09**, nella prima
stesura del widget.

**COSA NON HO POTUTO VEDERE.** Tutto cio' che sta qui sopra e' misurato al
banco, con un lettore finto per il filmato. Il filmato vero sul telefono, cioe'
la fluidita' della rampa di `setPlaybackSpeed` su Android e il passaggio dal
fotogramma fermo alla texture, si vede solo con una build, e **nessuna build
parte senza l'ordine del fondatore**.

**LE GUARDIE, tutte viste rosse.**

| rosso innestato | esito |
|---|---|
| il filmato a schermo prima del primo fotogramma | rossa |
| il primo fotogramma tolto, resta il fondo | rossa: varianza della scena 0 contro 549 |
| la rampa che si ferma al primo gradino | rossa |
| l'alone che non si disegna | rossa |
| *Salta* anche alla prima discesa | rossa |
| *Salta* dentro la zona del dito | rossa: il tocco fa partire il filmato |
| sopra la nebbia svanisce il tunnel invece del filmato | rossa |
| il tamburo che si ferma col dito | rossa |
| il tamburo chiesto senza file | rossa |
| il tunnel di riserva che non arriva mai | rossa |
| un `seekTo` nel lettore vero | rossa |
| il filmato che ignora l'app che se ne va | rossa: al ritorno ripartiva senza dito |
| la durata riportata a venti secondi | rossa: 20,22 s |
| la roccia ferma, nel tunnel di riserva | rossa: 0,0 per cento della parete cambiata |
| la roccia spinta fuori dalla finestra | rossa: 8,3 per cento dipinto |

**Due non erano rossi al primo giro, e l'errore era mio.** La grana del primo
fotogramma si misurava sulla finestra intera, dove la barra e la scritta
facevano varianza da sole; e l'innesto del pulsante aveva le virgolette nel
filtro della prova, che non girava affatto. Misurata la grana dentro la scena,
e innestato il pulsante davvero dentro la zona del dito, rossi tutti e due. Il
ripristino dopo ogni innesto e' stato verificato al byte.

---

## DI.03, LA SCENA NASCE DALLA PERSONA. CHIUSA NEL CODICE E PROVATA COL MODELLO VERO

**La porta al modello e' aperta** (`lib/core/viaggio/la_scena_dal_modello.dart`).
La chiamata parte a discesa finita, quando il tema della domanda libera e' gia'
capito, e ha la nebbia e l'incontro per rispondere; alla risalita si aspetta al
massimo due secondi. Il modello riceve la domanda per esteso, il tema, il nome
dell'animale, **la carta natale dalla porta unica dei Maestri**
(`SorgenteNatale`: Sole, Luna, Ascendente, numero di vita), il riassunto della
memoria del Diario e i pezzi delle ultime cinque scene; sceglie **quattro id
da quattro elenchi chiusi**, e l'uscita non puo' essere altro. La risposta si
legge prima di usarla: id del vocabolario, un gesto che quel corpo sa fare,
nessuna parola ripetuta, al massimo un pezzo gia' visto. **Se qualcosa non
torna decide la via deterministica, che resta, e il guasto va nel registro dei
guasti, mai alla persona.** Tetto tecnico della DI.15.

**LA PROVA CHE L'ORDINE CHIEDE, col modello vero.** Trenta discese con la
stessa domanda, *"Devo lasciare il mio lavoro per aprire qualcosa di mio?"*, e
lo stesso giorno, da tre profili, dieci ciascuno, con memoria e scene
precedenti che crescono come nell'app. L'istruzione e' quella esportata dalla
Dart carattere per carattere. Col modello montato, `gemini-2.5-flash` su
`europe-west1`:

| discesa | P1: Lupo, Sole Cancro, Luna Scorpione, Asc. Pesci, 7 | P2: Aquila, Sole Leone, Luna Ariete, Asc. Sagittario, 1 | P3: Tartaruga, Sole Capricorno, Luna Toro, Asc. Vergine, 4 |
|---|---|---|---|
| 1 | bivio, seme, aspetta, nebbia | bivio, chiave, si mette in mezzo, nebbia | bivio, seme, aspetta, alba |
| 2 | grotta, porta chiusa, mostra i denti, notte | radura, fuoco acceso, si ferma, alba | soglia, porta chiusa, si mette in mezzo, nebbia |
| 3 | scala, chiave, ti precede, alba | scala, porta chiusa, si volta, notte | bivio, chiave, ti precede, alba |
| 4 | fiume, acqua ferma, si accuccia, pioggia | cima, seme, ti precede, alba | scala, cerchio tracciato, si accuccia, notte |
| 5 | cerchio di pietre, specchio, si volta, notte | soglia, maschera, aspetta, pioggia | fiume, acqua ferma, aspetta, nebbia |
| 6 | soglia, ombra non tua, si mette in mezzo, nebbia | bosco fitto, ombra non tua, guarda in alto, nebbia | radura, fuoco acceso, si volta, notte |
| 7 | bivio, seme, aspetta, alba | bivio, chiave, si mette in mezzo, notte | grotta, seme, scava, pioggia |
| 8 | grotta, fuoco acceso, scava, notte | fiume, acqua ferma, si allontana, alba | soglia, porta chiusa, si mette in mezzo, nebbia |
| 9 | scala, chiave, ti precede, nebbia | radura, fuoco acceso, si volta, notte | bivio, filo, ti precede, alba |
| 10 | ponte, porta chiusa, mostra i denti, pioggia | scala, porta chiusa, ti precede, notte | scala, chiave, guarda in alto, notte |

**Quale elemento del profilo ha mosso quale pezzo**, con la prova a un elemento
per volta: il primo profilo con un solo elemento cambiato, dieci discese per
variante. Il numero e' la distanza fra le scelte, da 0, le stesse, a 1, nessuna
in comune.

| cambia soltanto | luogo | cosa | gesto | momento |
|---|---|---|---|---|
| l'animale, Lupo in Aquila | 0,30 | 0,30 | 0,50 | 0,10 |
| la carta natale, quella di P2 | 0,30 | 0,30 | 0,30 | 0,10 |
| memoria e scene precedenti, tolte | 0,80 | 0,50 | 0,70 | 0,70 |

**Si legge cosi'.** La domanda tiene fermo il punto di partenza: il *bivio*
torna in tutti e tre i profili, ed e' giusto per *una scelta da fare*.
**L'animale muove soprattutto il gesto**, perche' cambiano i gesti possibili e
cambia il corpo; **la carta natale muove luogo, cosa e gesto in misura
simile**; **la memoria e le scene precedenti muovono tutto**, perche' sono cio'
che impedisce di ripetersi. Fra profili le distanze stanno fra 0,1 e 0,5 su
luogo, cosa e gesto: le scene differiscono in modo leggibile, e i tre profili
non si scambiano mai la stessa sequenza.

**Le misure delle trenta discese**: trenta risposte valide su trenta, **zero**
che l'app scarterebbe, sedici scene su ventisette che riprendono un pezzo delle
precedenti, tempo mediano 0,69 secondi e peggiore 0,88, **904 token in ingresso
e 40 in uscita**, cioe' circa quattro decimi di millesimo di dollaro a discesa
coi prezzi di Gemini 2.5 Flash, sotto la stima dell'ordine. **Col modello
dell'ordine**, `gemini-3.6-flash` su `global`, stessa prova: trenta su trenta,
zero scartate, quindici riprese su ventisette, tempo mediano 1,27 secondi e
peggiore 3,21, 1.100 token in ingresso e 42 in uscita. La scelta fra i due
resta del fondatore.

**DUE DIFETTI CHE SOLO IL MODELLO VERO POTEVA TROVARE, e chiusi.**

- **Il ragionamento troncava ogni risposta.** I Flash *pensano* prima di
  rispondere, e il pensiero si conta nel tetto dell'uscita: Gemini 3.6 Flash
  rispondeva *"Here"* e si fermava, trenta volte su trenta. Nell'app nessuno
  diceva di non pensare nemmeno a Gemini 2.5 Flash: **ogni scena sarebbe caduta
  sulla riserva** senza che nessuna prova se ne accorgesse. Adesso le tre
  chiamate del Viaggio spengono il ragionamento da un posto solo,
  `LaDomandaCapita.ragionamentoPer`, e una guardia lo pretende.
- **Il modello ricopiava le scene precedenti.** Con la prima istruzione,
  *"se un elemento ha senso, riprendilo"*, riprendeva qualcosa in ventisei
  scene su ventisette, e un profilo tornava dieci volte al bivio col seme.
  Adesso l'istruzione chiede di non ripetersi e ammette un pezzo ripreso al
  massimo, e la lettura della risposta lo pretende.

**E UNA RIGA DI MEMORIA RISCRITTA.** Il riassunto che il Diario scrive per i
Maestri, e che adesso arriva anche al modello, diceva *"e' sceso nel Mondo di
Sotto"*: dice *"ha fatto N discese"*.

**La guardia**, `la_scena_nasce_dalla_persona`: dieci rossi.

---

## DI.11, DI.12, DI.13 e DI.14, LA VITA DOPO IL RICONOSCIMENTO. CHIUSE NEL CODICE

**DI.11, cosa sparisce e cosa compare.** Alla quarta discesa spariscono le
quattro impronte, il conteggio, le tre righe della voce DI.07, la girandola dei
dodici candidati; e dalla quinta in poi la riga *"E' il Lupo. Adesso lo
conosci."* e la card da condividere, che tornavano **a ogni discesa**. Al loro
posto l'animale a figura intera e scoperto, il suo nome, e le due righe
dell'ordine, **accordate col genere**: l'ordine le scrive al maschile, e quattro
animali su dodici sono femmine. *"La Volpe resta con te. Scendi quando hai una
domanda."*, *"Si allontana se la lasci sola. Il tamburo la richiama."*. Sotto,
tre azioni e non di piu': **Scendi con una domanda**, **Nutrilo** o **Nutrila**,
**Chiedigli** o **Chiedile un segno**. La scelta della domanda compare solo
quando si tocca la prima.

**DI.12, si scende per chiedere.** Stessa meccanica: la domanda, il filmato
saltabile, la nebbia, l'incontro con l'animale **scoperto**, e la risposta
**senza la lente**, perche' il velo e' caduto. I tetti sono quelli della DI.15.

**DI.13, il tamburo che nutre** (`il_tamburo_che_nutre.dart`). A schermo pieno,
sul fondo della galleria: la pelle del tamburo pulsa in basso alla cadenza del
tamburo, si batte col dito dove si vuole, e **finche' un colpo e' caduto
nell'ultimo secondo e poco piu' l'animale continua ad avvicinarsi** dall'orizzonte
al primo piano mentre la nebbia intorno si dirada. Quaranta secondi **di
battito**, non d'orologio: se si smette, l'animale si ferma e aspetta. Nessun
numero, nessuna barra. Alla fine *"Il Cavallo e' vicino a te."* e la riga dello
stato, com'era. **Il nutrimento e' aperto sempre**, e conta un giorno solo anche
se lo si fa piu' volte: la regola dell'ordine DE, *"tornare costa tornare"*,
resta vera per quest'altra strada. Il pulsante in un clic dell'ordine DE non
c'e' piu'; dalla soglia di prima del riconoscimento, *"Richiamalo col tamburo"*
apre lo stesso rito.

**DI.14, il segno** (`il_segno_dell_animale.dart`, `il_segno_che_risponde.dart`).
Una domanda in una riga; l'animale risponde con **uno dei sei gesti
dell'ordine**, detti per ogni animale (un uccello porta *nel becco* e si *posa*,
il Serpente si *raccoglie*), e **una riga sola**. Il modello sceglie il gesto e
la figura portata da elenchi chiusi e scrive la riga; la riga si legge prima di
mostrarla (lunghezza, due punti annidati, participi riferiti a chi legge), e se
qualcosa non torna risponde la riserva deterministica, senza dirlo. Il segno si
conserva nel Diario. Tetti della DI.15 e tetto tecnico.

**DUE COSE DA DIRE PER QUELLO CHE SONO.**

- **Il gesto e' l'illustrazione che si muove**, non un disegno per gesto: per
  ogni animale c'e' un'illustrazione sola, e sei gesti per dodici animali sono
  settantadue disegni che non esistono. L'animale si volta ruotando, si
  avvicina crescendo, si allontana rimpicciolendo, si siede abbassandosi,
  guarda lontano spostandosi, e *porta qualcosa* con una luce che nasce dove
  sta la sua bocca. **I disegni veri dei gesti sono un lavoro da ordinare.**
- **Il modello del segno e' quello della domanda capita**, scelta B, finche' il
  fondatore non sceglie: `gemini-2.5-flash-lite` su `europe-west1`. Il modello
  dell'ordine, Gemini 3.5 Flash Lite, esiste solo su `global`.

**VISTE, non solo provate.** Le tre schermate nuove sono state fotografate al
banco e guardate: la prima fotografia del tamburo mostrava **la nebbia sopra
l'animale**, che a meta' rito non si vedeva arrivare, e un rito fermo perche'
il tempo era misurato con un cronometro; tutte e due corrette prima di
chiudere.

**La guardia**, `la_vita_dopo_il_riconoscimento`: dieci rossi.

---

## DI.15, I LIMITI PER PIANO. CHIUSA NEL CODICE

**La matrice resta la fonte unica**, e ha tre righe nuove coi valori
dell'ordine parola per parola:

| riga | Viandante | Iniziato | Adepto | Illuminato |
|---|---|---|---|---|
| Discese nel Mondo di Sotto | 1 al giorno | 1 al giorno | 1 al giorno | 2 al giorno |
| Segni chiesti all'animale guida | 1 a settimana | 3 a settimana | 1 al giorno | 5 al giorno |
| Nutrire l'animale guida | Sempre | Sempre | Sempre | Sempre |

**Nutrimento: *Sempre*, e non *illimitato*.** L'ordine dice illimitato, e la
ragione e' che il nutrimento non chiama nessun modello; ma la parola e' uscita
dal listino con l'ordine CE voce 08 per decisione del fondatore, e una guardia
enumera le celle. *Sempre* promette la stessa cosa.

**I tetti la leggono.** `TettiDelViaggio` non ha piu' la sua mappa (uno, tre,
sette e venti, dall'ordine DE voce 14): legge le discese dalla matrice. **Prima
del riconoscimento resta una discesa al giorno per tutti**, anche per
l'Illuminato che dopo ne ha due: e' il metodo, quattro viaggi in quattro
giorni. I segni si leggono con `PlanCatalog.limiteDelPeriodo`, che distingue il
giorno dalla settimana: la lettura di prima avrebbe dato al Viandante sette
segni a settimana invece di uno. La settimana e' quella che scorre.

**Al tetto nessun muro.** La riga del rifiuto diceva *"Con gli Eos puoi farne
un'altra"*, e **nessuna strada del codice ha mai venduto una discesa**: era una
promessa falsa. Adesso dice quando si torna e offre il nutrimento, col nome
dell'animale e non con un pronome, che al maschile sbaglierebbe su quattro
animali su dodici: *"La tua discesa di oggi e' fatta. Puoi scendere di nuovo
domani. Intanto puoi nutrire la Volpe: il tamburo e' sempre aperto."*. Per i
segni, il giorno in parole: *"Un altro segno potrai chiederlo giovedi'."*. E
*"Oggi sei gia' sceso"*, per chi aspetta il metodo, e' diventato *"La discesa di
oggi e' gia' fatta"*.

**Il tetto tecnico**, `IlTettoDelleChiamate`: dieci chiamate al modello al
giorno per persona, contate una per una, perche' una discesa con la domanda
scritta a mano ne fa due. Oltre, decidono le vie di riserva e la persona non se
ne accorge. In Demo non conta, come ogni tetto del Viaggio. **Oggi lo usa la
domanda capita**; la scena del modello e i segni lo useranno con le loro voci.

**Cosa resta da dire.** `TettiDelViaggio.siPuoComprareAncora` rispondeva *si'*
dopo la rivelazione, cioe' dichiarava in codice una vendita che non esiste.
Adesso risponde di no. La funzione resta, perche' l'ordine non la nomina.

**La guardia**, `i_limiti_del_viaggio_stanno_nella_matrice`: sei rossi.

---

## DI.04, DI.05 e DI.06, LA SCENA PARLA BENE. CHIUSE NEL CODICE

**DI.04, l'animale ha un nome.** Nella scena l'animale era *"l'animale"* in
tutte le forme, e il Lupo e il Corvo davano scene identiche. Adesso e' `{Chi}`:
**dopo il riconoscimento** il suo nome con l'articolo giusto (*il Lupo*,
*l'Aquila*, *la Lince*), alternato col pronome *lui* o *lei*, mai con la parola
generica. **Prima del riconoscimento il nome non si dice**, perche' la regola
dell'ordine DG vuole il nome alla quarta discesa e non prima: la scena lo
chiama *la sagoma*, che e' cio' che la persona ha visto e seguito
nell'incontro. Alla quarta discesa, quella della rivelazione, la scena dice gia'
il nome. **E il nome ha portato un difetto nuovo, chiuso subito**: *"l'Aquila
mostra i denti"*. La composizione adesso non pesca i gesti che il corpo di un
animale non sa fare (gli uccelli non mostrano i denti, non scavano, non si
accucciano; la Tartaruga e il Cervo non mostrano i denti; il Serpente non
scava e non si accuccia). Il vocabolario non e' stato toccato.

**DI.05, niente due punti annidati, niente persona che balla.**

- le otto forme di *da dove viene* finiscono con una frase intera e non piu'
  coi due punti, e la scena le segue **senza la sua apertura**
  (`testoSenzaApertura`); le tre aperture coi due punti sono state riscritte;
- **il controllo in composizione**: `LaVoceDelMondoDiSotto.cuci` unisce i pezzi
  del responso, e se un pezzo che finisce coi due punti precede una frase che
  li ha anche lei, i suoi diventano un punto. Dopo i due punti si continua in
  minuscolo;
- tutte le forme in seconda persona singolare; l'unico plurale, *"Tu e il Lupo
  siete..."*, nomina il compagno nella stessa frase;
- nessun participio al maschile riferito a chi legge: *"Sei sceso"*, *"Sei
  arrivato"*, *"Sei andato"* sono spariti da aperture, riprese e risposte;
- nessuna parola piena ripetuta nella stessa scena: *ti porta* e' diventato
  *ti guida* (accanto a *la porta chiusa*), e la composizione scarta il gesto
  che ripete una parola delle altre figure (*l'acqua ferma* e *si ferma*) e la
  cosa che ripete il luogo (*il cerchio di pietre* e *il cerchio tracciato a
  terra*);
- **riletti per intero** con questo metro: le ventiquattro forme della scena,
  le dodici aperture, le dodici chiusure, le otto forme del richiamo e tutti i
  frammenti della voce del Mondo di Sotto. Sono stati riscritti anche: le
  riprese della domanda che accordavano col tema (*"Con te e' scesa un tempo che
  non arriva"*, *"Hai chiesto di la scelta"*), le forme del richiamo che
  accordavano un pronome maschile con qualunque figura (*"La chiave lo avevi
  gia' trovato"*), *"Fai questo: Fai la telefonata"*, e il quando che ripeteva
  l'apertura (*"Il passo di oggi: ... Oggi."*).

**DI.06, le chiusure chiudono.** Dodici chiusure riscritte: riportano alla
domanda, consegnano la scena come cosa da tenere, o dicono quando rileggerla.
**Due sole** restano sul non decifrare subito, *"Non tradurla subito:
ricordala."* e *"Il senso arriva dopo."*. E a chi scende senza domanda nessuna
chiusura parla della domanda: l'ho trovato leggendo i responsi per intero.

**UNA REGRESSIONE MIA, presa dalla guardia dell'ordine DF.** Nella prima
stesura il filo che sceglie forma, apertura e chiusura veniva ricreato per ogni
scelta, e apertura e chiusura, dodici l'una, uscivano sempre appaiate: gli
scheletri distinti su cento discese erano scesi da 99 a 66. Rimesso un filo
solo, e la scena porta adesso anche **l'impronta della sua discesa**, come gia'
i paragrafi della voce: due discese che pescano gli stessi quattro pezzi non
dicono piu' la stessa frase. **Misure DF sul Viaggio adesso: A 100 su 100, B
100 su 100, C 30,2 per cento, D 1.**

**La guardia**, `la_scena_parla_bene`, tredici rossi innestati a mano.

---

## DI.07 e DI.08, LE TRE INFORMAZIONI E LE QUATTRO IMPRONTE. CHIUSE NEL CODICE

**DI.07.** Tre righe nella soglia, i testi dell'ordine parola per parola, e
restano **fino al riconoscimento**:

- *dove ti trovi*, sotto il titolo: *"Il Mondo di Sotto e' il luogo dove gli
  sciamani scendono per incontrare l'animale che li accompagna. Ci si arriva per
  un'apertura nella terra."*
- *cosa stai facendo*, sopra il pulsante: *"Scendi con una domanda. L'animale ti
  mostra una scena. La scena e' la risposta."*
- *cosa otterrai*, subito sotto il pulsante: *"Si mostra quattro volte prima di
  farsi riconoscere. Poi resta con te."*

**Cosa se n'e' andato, per nome.** Le tre cose da sapere dell'ordine DE voce 02
(*"In quattro discese conoscerai il nome..."*, *"Da quel momento resta con
te"*, *"Potrai consultarlo..."*), che si leggevano solo prima della prima
discesa, e la riga *"Dodici ti aspettano. Uno verra' con te."*. L'ordine vuole
**tre righe in tutto**, e le tre nuove dicono le stesse cose con in piu' la
domanda e la risposta, che mancavano per tre viaggi su quattro. Non e' una
funzione cancellata: e' lo stesso posto con il testo che l'ordine detta.

**DI.08.** Le quattro impronte stanno **ferme in alto**, sotto la barra, fuori
dalla lista che scorre: a soglia scorsa restano dove sono. Sotto, la riga in
parole: *"Si e' mostrato due volte, ne mancano due."*, *"Non si e' ancora
mostrato, ne mancano quattro."*, *"Si e' mostrato tre volte, ne manca una."*.
Prima era *"Si e' mostrato 2 volte su 4"*, cioe' un punteggio: adesso nessuna
riga del cammino usa una cifra, nemmeno quella del Passaporto. Dopo il
riconoscimento il cammino sparisce, come dice la voce DI.11.

**UN DIFETTO VISTO GUARDANDO, e nessuna prova lo cercava.** Nella fotografia
della soglia la prima impronta era tagliata di sotto e l'ultima di sopra: i
centri cadevano sul bordo della scatola, e lo Stack le ritagliava. Adesso i
centri stanno nel rettangolo rientrato di mezza impronta, e la guardia
pretende ogni impronta dentro la sua scatola. **Padre: ordine DE voce 09**, che
ha disegnato il cammino.

**La guardia**, `la_soglia_e_una_scena_piena`, che non era nel registro: sei
rossi innestati a mano, uno per pretesa.

---

## DI.01, IL TEMA DELLA DOMANDA ARRIVA DAVVERO. CHIUSA

**La premessa dell'ordine e' vera, riletta sul codice.** Lo schermo assegnava
`_temaScelto = d.tema`, l'etichetta *"Una scelta da fare"*; la voce del Mondo di
Sotto cercava `d.id == idDomanda`, l'identificatore `scelta`. E c'era una
seconda riga col confronto sbagliato, quella che decideva quale domanda
apparisse accesa.

**Il campo faceva tre mestieri**: portava l'etichetta, portava `'incontro'` per
la terza via, e faceva da semaforo per saltare il controllo del testo. E'
questo che ha permesso a un'etichetta di entrarci senza che niente se ne
accorgesse.

**LA CURA E' IL TIPO.** `TemaDellaDomanda` e' un enum dei sei temi,
`_temaScelto` e' un `TemaDellaDomanda?`, e l'id delle sei domande **non si
scrive piu' a mano**: si legge dall'enum. **Scrivere l'etichetta dove va il
tema non compila**, provato: il compilatore dice *"A value of type 'String'
can't be assigned to a variable of type 'TemaDellaDomanda?'"*. La terza via e il
semaforo si leggono dalla via scelta. Il diario salva l'id e lo ritraduce in
parole per il riassunto dei Maestri, capendo anche i diari vecchi, che
contengono le etichette.

**LA PROVA FA LA STRADA INTERA**, perche' la guardia dell'ordine DG voce 07 era
verde proprio chiamando il compositore direttamente, con l'id giusto in mano:
**misurava il contenuto, non la strada**. `il_tema_della_domanda_arriva_alla_risposta`
tocca la domanda sullo schermo, scende col dito, apre la nebbia, segue
l'ombra, risale, e legge la risposta **come arriva a schermo**. **Sei domande,
sei riprese.** Vista rossa: col tema nullo nella chiamata, sei cadute su sei.

**Cosa si legge a schermo adesso**, e va detto perche' **non e' ancora
eccellente**: *"Con te e' scesa un tempo che non arriva"* sbaglia il genere;
*"Sei sceso"* da' per scontato un lettore uomo; *"era qualcosa che e' finito.
E' finito."* ripete. Rientrano nella rilettura integrale della voce DI.05.

### Il censimento della stessa famiglia

L'ordine chiede di censire ogni punto dove un'etichetta per persone viene
confrontata con un identificatore stabile. **Tre passate**: i confronti diretti
fra un campo id e un campo etichetta (nessuno); le undici funzioni che cercano
per id una stringa venuta da fuori, coi loro chiamanti (tutte con id scritti
dal codice, e due verificate a fondo: il segno del ricordo dell'oroscopo, che
chi lo rilegge accetta di proposito in tre forme, e i pianeti degli eventi del
cielo, `sun` da tutte e due le parti); le etichette usate come chiave di mappa
o di confronto. **Due parenti veri**:

1. **La matrice dei piani cercava le righe per etichetta**, e ogni ricerca a
   etichetta non trovata ripiegava in silenzio: `haMemoria` su **vero**, cioe'
   la memoria dei Maestri gratis per tutti; `limiteGiornaliero` su **nullo**,
   cioe' illimitato, l'abuso chiuso dall'ordine CE voce 08; `haProfondita` su
   **falso**, cioe' la Profonda tolta a chi l'ha pagata. Bastava ritoccare una
   parola della tabella. E le etichette erano scritte **due volte**, nella
   matrice e nelle costanti `rigaDomande` e sorelle. **Curata col tipo**:
   `RigaDelPiano`, dieci chiavi, ricerche per chiave, l'etichetta resta per la
   tabella. I nomi delle costanti sono gli stessi, e' cambiato il loro tipo.
2. **Il registro lunare delle rune del tramonto era indicizzato col nome
   italiano della fase.** Qui il nome e' l'identita' stessa della fase nel
   modulo lunare, e passarlo a un tipo vorrebbe dire rifare il motore
   astronomico: **curato con una guardia**, che pretende che le chiavi del
   registro siano esattamente i nomi che la fase sa produrre.

**E la cura della matrice ha reso piu' forte una prova vecchia**, che ha
subito trovato due righe con un numero che non sono tetti d'uso: *Eos in dono
alla sottoscrizione*, una quantita' regalata una volta, e *Domanda al Maestro
reale*, **una quota mensile di un servizio umano che nel codice non impone
nessuno**. Dichiarate per nome e ragione. **La seconda va al fondatore**:
l'Illuminato si vede promettere *"una domanda al mese al Maestro reale,
risposta entro 48 ore"*, e niente la implementa.

**LE GUARDIE:** `il_tema_della_domanda_arriva_alla_risposta` e
`le_etichette_non_fanno_da_chiave`, registro a **397**.

---

## DI.02, LA DOMANDA LIBERA VIENE CAPITA. CHIUSA NEL CODICE

**La premessa e' vera.** Nessun classificatore esisteva: il testo della
persona entrava in un punto solo, come ingresso dell'hash che sceglie i pezzi
della scena. E c'era di peggio: appena si scriveva nel campo, lo schermo
azzerava il tema, quindi la risposta usava sempre le frasi *"senza domanda"*.

**LA VIA DI RISERVA**, `IlTemaDellaDomandaLibera`, una tabella di parole e
locuzioni per tema, coi pesi: tre per le locuzioni che dicono **cosa si sta
chiedendo**, uno per i nomi che dicono **di chi o di cosa si parla**, quattro
per le perdite. A parita', a zero, **o sotto i due punti**, il tema resta nullo.

### La tabella che l'ordine chiede, a rete staccata

| ok | domanda | atteso | ottenuto | punti |
|---|---|---|---|---|
| SI | Mia sorella diventerà presto mamma? | attesa | attesa | attesa 6, persona 2 |
| SI | Quando arriverà la risposta del colloquio? | attesa | attesa | attesa 7 |
| SI | Aspetto da mesi una notizia che non arriva mai. | attesa | attesa | attesa 8, blocco 1 |
| SI | Riuscirò finalmente ad avere un figlio? | attesa | attesa | attesa 6, persona 1 |
| SI | Devo accettare il nuovo lavoro o restare dove sono? | scelta | scelta | scelta 7 |
| SI | Non so se trasferirmi a Milano o rimanere qui. | scelta | scelta | scelta 9 |
| SI | Firmo il contratto oppure aspetto un’offerta migliore? | scelta | scelta | attesa 3, scelta 7 |
| SI | Quale delle due case dovrei comprare? | scelta | scelta | scelta 3 |
| SI | Cosa prova davvero Marco per me? | persona | persona | persona 4 |
| SI | Posso fidarmi della mia collega? | persona | persona | persona 4 |
| SI | Perché mia madre è sempre così fredda con me? | persona | persona | persona 3 |
| SI | Perché non riesco mai a finire quello che inizio? | blocco | blocco | blocco 4 |
| SI | Ho paura di parlare in pubblico e mi blocco ogni volta. | blocco | blocco | blocco 8 |
| SI | Come faccio a smettere di rimandare tutto? | blocco | blocco | blocco 8 |
| SI | Che strada devo prendere nella vita? | direzione | direzione | scelta 1, direzione 6 |
| SI | Mi sento perso, non so cosa voglio fare da grande. | direzione | direzione | direzione 9 |
| SI | Qual è il mio scopo? | direzione | direzione | direzione 3 |
| SI | Come supero la fine della mia relazione? | finito | finito | finito 3 |
| SI | Mio padre è morto e non riesco ad andare avanti. | finito | finito | persona 1, blocco 3, finito 8 |
| SI | Mi hanno licenziato dopo dieci anni, e adesso? | finito | finito | finito 6 |

**Venti su venti.** Ma va detto come si legge questo numero: le domande del
gruppo dell'ordine le ho scritte io prima della tabella, e la tabella le
conosceva mentre la scrivevo. **E' una prova di regressione, non una misura.**

### La misura onesta, e come ci si e' arrivati

1. Un **secondo gruppo** di dodici domande doveva essere indipendente, e non
   lo era: la tabella ne ricalcava parola per parola le locuzioni. Il suo
   dodici su dodici non misurava niente, **e l'ho dichiarato invece di
   tenerlo**.
2. Congelata la tabella, un **terzo gruppo** scritto dopo: **3 capite su
   12, e 2 SBAGLIATE**, *"Mia figlia e' felice con il suo ragazzo?"* finita
   nell'attesa e *"Cosa dovrei cambiare per sentirmi piu' realizzato?"* nella
   scelta.
3. Due cambi di principio, e non ritocchi su quelle domande: **una parola
   d'argomento da sola non decide** (minimo due punti), e **il figlio e' una
   persona** (stava nell'attesa per colpa di *"avere un figlio"*).
4. Congelata di nuovo, un **quarto gruppo** scritto dopo: **4 capite su 12,
   zero sbagliate**. E' la misura onesta di oggi.

**La guardia pretende zero temi sbagliati, non un numero di giusti**: senza
tema si cade sul ramo senza domanda, che l'ordine dice legittimo; col tema
sbagliato la persona riceve una risposta su un'altra cosa. **La tabella da
sola capisce una domanda su tre: e' una rete di sicurezza prudente, il capire
e' del modello.**

### LA VIA PRINCIPALE, col modello

`LaDomandaCapita`: chiamata secca, temperatura zero, istruzione costruita dalle
sei domande scritte, e **risposta vincolata a un elenco chiuso**
(`text/x.enum`): il modello non puo' scrivere altro che uno dei sei id.
**Due secondi di pazienza**, poi la tabella, senza che la persona se ne
accorga; il guasto va nel registro dei guasti, mai alla persona. **La
classificazione parte al tocco di Scendi e lavora durante i venti secondi della
discesa**: quando si risale e' pronta da un pezzo.

**I MODELLI DELL'ORDINE ESISTONO, MA SOLO DALL'ENDPOINT `global`.** Verificato
il 12 settembre 2026 contando i token con ogni modello: `gemini-3.5-flash-lite`
e `gemini-3.6-flash` rispondono da `global` e danno 404 da `europe-west1`,
dove l'app fissa Vertex di proposito. **E' una scelta di residenza dei dati, ed
e' del fondatore.** Provati col modello vero sulle 56 domande di prova, con la
stessa istruzione e lo stesso elenco chiuso:

| | giuste | tempo mediano | peggiore | oltre 2 s |
|---|---|---|---|---|
| `gemini-2.5-flash-lite`, `europe-west1` | 53 su 56 | 0,44 s | 1,30 s | 0 |
| `gemini-3.5-flash-lite`, `global` | 54 su 56 | 0,69 s | **20,04 s** | 1 |

**Misurati con l'istruzione che il codice usa davvero**: una prima misura era
stata fatta su una formulazione poi corretta dalle guardie di casa, e si e'
rifatta. **Due misure di fila hanno trovato su `global` una chiamata da circa
venti secondi** (18,99 e 20,04): coi due secondi di pazienza la persona non se
ne accorge, perche' decide la tabella, ma e' un dato per la scelta. La
differenza di precisione fra i due modelli e' **una domanda su 56**.

**Finche' il fondatore non sceglie, e' montato il primo**, che tiene i dati in
Europa e non ha mai sforato i due secondi: modello e regione sono una
costante ciascuno.

**La domanda del fondatore, adesso, a rete staccata:** *"Mia sorella
diventera' presto mamma?"* riceve *"Sotto sei andato per un tempo che non
arriva. Datti una data. Se passa, hai la tua risposta."* Prima riceveva *"Non
hai chiesto niente. Hai visto lo stesso."* **E' una risposta sull'attesa, ma
non ancora sulla sua domanda**: non nomina ne' la sorella ne' il diventare
madre. Quello e' il lavoro delle voci DI.03 e DI.04.

**LE GUARDIE:** `la_domanda_libera_viene_capita`, con la via di riserva, i
quattro gruppi, e il modello iniettato in cinque comportamenti (giusto, con le
virgolette, fuori dai sei, in errore, oltre i due secondi: la persona aspetta
2,002 secondi); e la strada intera con la domanda scritta a mano. Viste rosse:
col minimo per decidere a uno, due temi sbagliati nominati; senza la
classificazione al tocco di Scendi, la frase senza domanda.
