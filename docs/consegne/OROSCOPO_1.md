# CONSEGNA, ORDINE OROSCOPO 1 DI 2

Ramo `claude/oroscopo-1-b1e463`, partito da
`origin/claude/esoteric-circle-master-order-e798aj` a `9da9f5c`.
Nessuna build, nessuna distribuzione, `versionCode` non toccato.
`STATO_VIVO.md` e `RIPRESA.md` non aperti in scrittura, per la deroga
dichiarata nell'ordine.

## Prima di tutto: l'oroscopo a schermo NON e' cambiato

Ed e' corretto. Quest'ordine costruisce il motore. Le quattro schede continuano
a nascere dall'hash FNV-1a, esattamente come ieri, perche' il testo che usera'
i transiti e' l'ordine 2 di 2. Chi apre l'app oggi non vede niente di nuovo.

## L'esito delle otto premesse

Tutte e otto vere, verificate sul ramo prima di scrivere codice.

| # | Premessa | Esito |
|---|---|---|
| 1 | `celestial.dart` espone `sunEclipticLongitude`, `moonEquatorial`, `moonIllumination`, in locale | vera |
| 2 | `night_sky.dart` ha una SECONDA `sunEclipticLongitude` piu' `moonEclipticLongitude` | vera |
| 3 | `archetype_sky.dart` espone `pianetiDelGiorno` e alimenta `ArchetypeTransits` | vera |
| 4 | I consumatori stanno in `lib/features/maestri/aura/`, fuori dal perimetro | vera |
| 5 | Nessun motore locale calcola oltre Sole e Luna | vera |
| 6 | La carta conservata ha le longitudini dei tredici corpi | vera |
| 7 | `AspectType` e `ChartAspect` esistono in `lib/core/astro/` | vera |
| 8 | Il cielo e' stato verificato contro fonti terze il 1 agosto 2026 | vera |

**Sulla 5, i corpi davvero calcolabili in locale prima di quest'ordine erano
due**: Sole, per longitudine eclittica; Luna, per longitudine, posizione
equatoriale e illuminazione. Nient'altro. I nomi degli altri pianeti comparivano
solo in `natal_poetics.dart` e `resonance.dart`, che sono testo interpretativo e
tabelle di corrispondenza, non calcolo.

**Sulla 8**, la verifica sta in `docs/ordini/ESITO_ISTANTE.md`: due istanti per
Milano, confronto con un calcolo indipendente, coincidenza alla prima cifra
decimale, ed e' bloccata da `un_solo_istante_test.dart`.

### Una correzione all'ordine, che non e' una premessa ma va detta

L'ordine dice che gli algoritmi di Meeus sono quelli **che questo progetto usa
gia'** ed e' **la fonte con cui il cielo e' stato verificato il 1 agosto**.
Nessuna delle due cose risulta: la parola Meeus non compare in nessun file del
repository, ne' nel codice, ne' nelle prove, ne' nei documenti, e
`ESITO_ISTANTE.md` chiama la sua fonte terza soltanto "calcolo indipendente",
senza nominarla. Le formule che c'erano SONO della famiglia di Meeus, cioe' le
serie a bassa precisione dell'Astronomical Almanac, ma non erano attribuite.
Ho usato Meeus lo stesso, perche' e' una fonte reale e citabile, e adesso e'
citata nel codice accanto ai valori. Non ho ereditato una citazione che non
c'era.

## VOCE 1, cosa e' chiuso

### Una porta sola, e prima erano cinque

Prima di quest'ordine la longitudine eclittica si calcolava a mano in cinque
punti: due per il Sole, tre per la Luna, ciascuna con una troncatura diversa
della stessa serie.

Adesso c'e' `lib/core/astro/effemeridi.dart`, e risponde da solo alla domanda
"dove sta questo corpo a questo istante". Tutti gli altri lo chiamano.
**Nessuna firma pubblica e' cambiata**: `Celestial.sunEclipticLongitude`,
`Celestial.moonEquatorial`, `Celestial.moonIllumination`,
`NightSky.sunEclipticLongitude`, `NightSky.moonEclipticLongitude`,
`NightSky.sunSign`, `NightSky.moonSign`, `MoonPhase.forDate` e
`ArchetypeSky.pianetiDelGiorno` rispondono come prima. Non sono entrato in
`lib/features/maestri/`, `lib/core/chat/` ne' `lib/core/entitlement/`.

**Il Sole non si e' mosso di un millesimo.** Le due copie erano gia' la stessa
formula scritta due volte, quindi unificarle e' stato un puro spostamento. Una
prova ricalcola la formula vecchia a mano e pretende la coincidenza a 1e-9.

**La Luna invece si e' mossa, ed e' il punto.** Le tre versioni non erano
d'accordo fra loro. Misurato su tremila giorni, lo scarto massimo della nuova
serie unica contro le tre vecchie:

| Contro la vecchia | Termini | Scarto massimo |
|---|---|---|
| `moonIllumination` | 3 | **0,5303 gradi** |
| `moonEquatorial` | 6 | **0,3332 gradi** |
| `NightSky.moonEclipticLongitude` | 10 | **0,2140 gradi** |

Mezzo grado di disaccordo dentro la stessa app, sullo stesso corpo, allo stesso
istante. La serie unica e' la piu' ricca delle tre piu' il termine da 0,214
gradi che solo `moonEquatorial` aveva, quindi non e' un compromesso fra le tre:
le migliora tutte. Lo dimostra il confronto con la fonte terza qui sotto.

### I corpi aggiunti, coi numeri della verifica

Aggiunti **Mercurio, Venere, Marte, Giove, Saturno**, per moto kepleriano dagli
elementi orbitali medi di Meeus, *Astronomical Algorithms*, 2a edizione, tavola
31.A, con il passaggio a geocentrico del capitolo 33 e la correzione del tempo
luce.

**La fonte terza e' JPL Horizons**, il sistema di effemeridi del Jet Propulsion
Laboratory, interrogato il 4 agosto 2026 per la longitudine eclittica
geocentrica apparente all'equinozio della data. Tre date distanti fra loro piu'
di sei mesi. Scarto in gradi fra il motore locale e Horizons:

| Corpo | 2026-02-15 | 2026-08-24 | 2027-03-02 |
|---|---|---|---|
| Sole | 0,0040 | 0,0062 | 0,0004 |
| Luna | 0,1542 | 0,0928 | 0,0949 |
| Mercurio | 0,0084 | 0,0002 | 0,0077 |
| Venere | 0,0078 | 0,0054 | 0,0039 |
| Marte | 0,0131 | 0,0121 | 0,0424 |
| Giove | 0,0117 | 0,0216 | 0,0191 |
| Saturno | 0,0853 | 0,1414 | 0,1037 |

Tutti sotto il decimo di grado tranne Luna e Saturno, che stanno sotto i due
decimi. L'orbo piu' stretto che l'app usa e' due gradi, quindi lo scarto piu'
grande e' quattordici volte piu' piccolo della soglia che decide se un aspetto
c'e'. I valori di Horizons stanno nella prova, non aggiustati.

**I corpi NON aggiunti, con la ragione.** Urano, Nettuno e Plutone: gli elementi
di Meeus li coprono, ma muovono da uno a tre gradi l'anno, quindi un loro
aspetto resta aperto per mesi e non distingue un giorno dall'altro. Entreranno
quando ci sara' una funzione che ne ha bisogno. Nodo Nord, Chirone e Lilith:
non sono corpi a moto kepleriano nello stesso senso e vogliono una trattazione
loro. Tutti e sei restano disponibili sul LATO NATALE, che arriva dalle
effemeridi svizzere e li ha gia'.

### L'istante e' uno solo per il giorno civile

`lib/core/astro/transiti_del_giorno.dart`. L'istante e' **mezzogiorno UTC del
giorno civile**: mezzogiorno perche' e' il punto piu' lontano dai due bordi,
quindi qualunque momento della giornata dista al massimo dodici ore da quello
usato; UTC perche', scelto il giorno, l'istante non deve piu' dipendere da dove
sta il dispositivo.

**QUALE sia il giorno lo dice `ConfineDelGiorno`**, che non ho toccato di una
riga e di cui non ho scritto un secondo. Una prova blocca il testo esatto dei
suoi due metodi e pretende che la definizione resti una sola in tutto `lib`.

**Nessuna rete, nessuna cache.** Non c'e' nessun compromesso da dichiarare,
perche' la chiamata al giorno per dispositivo che la prima stesura accettava
come debito semplicemente non nasce. Non ho aggiunto memoria: rifare il calcolo
costa meno che ricordarselo, e una cache introdotta senza una misura sarebbe un
secondo posto dove lo stesso dato puo' divergere.

## VOCE 2, cosa e' chiuso

`lib/core/astro/aspetti_di_oggi.dart`. Aritmetica pura sul dispositivo: zero
rete, zero AI, zero costo.

### Il modello e' uno solo, esteso

`ChartAspect` e `AspectType` erano gia' in `lib/core/astro/natal_chart.dart` e
non ne ho affiancato un secondo. Li ho **estesi**:

- `AspectType` guadagna `angoloEsatto`, con la fonte accanto: sono i cinque
  aspetti tolemaici, Tolomeo, *Tetrabiblos* I.13, ricavati dividendo il cerchio
  per uno, due, tre, quattro e sei.
- `ChartAspect` guadagna `aId`, `bId`, `separazione` e `orbe`. Per i transiti la
  convenzione e' dichiarata: `a` e' il corpo in transito, `b` quello natale.

Gli aspetti dei transiti SONO `ChartAspect`, non un tipo parallelo.

### Gli orbi, e cosa e' scelta invece che fonte

Questa e' la parte dove ho fatto come fa il progetto coi corpora, cioe'
dichiarare la divergenza invece di sceglierla in silenzio.

**Saldo nelle fonti**: che gli orbi dei transiti siano piu' stretti di quelli
natali, perche' un transito e' una finestra che si apre e si chiude e non un
tratto permanente; e che la Luna in transito voglia l'orbo piu' stretto di
tutti, perche' percorre mezzo grado ogni ora.

**Divergente**: il numero esatto. Le tavole natali arrivano a dieci gradi sugli
aspetti maggiori e otto sul sestile, mentre per i transiti le fonti consultate
stanno fra uno e cinque gradi. Non esiste una tavola canonica da copiare.

**Scelta del progetto**, dentro quella forbice e marcata come scelta: cinque
gradi sugli aspetti maggiori, quattro sul sestile che in ogni tavola prende meno
degli altri, due sulla Luna in transito. Sta scritto accanto ai valori, non in
fondo a un file.

### Le due origini, dichiarate

Il lato natale viene dalle effemeridi svizzere per la callable `natalChart`, il
lato transito dal motore locale. Sono due sorgenti diverse per la stessa
grandezza. Misurato: lo scarto locale contro Horizons e' al massimo 0,1542
gradi, l'orbo piu' stretto e' due gradi. Lo scarto e' tredici volte piu' piccolo
della soglia, quindi in pratica non sposta nessun aspetto. Sta scritto accanto
al calcolo perche' chi lo trovera' fra sei mesi sappia che le origini sono due.

### Senza carta natale non si finge

Chi non ha dato ora e luogo ha un cielo essenziale, cioe' il solo segno solare:
la lista torna vuota e `AspettiDiOggi.livello` dichiara cosa resta
raggiungibile, fra `soloSegno`, `cartaSenzaOra` e `cartaCompleta`. Ascendente e
Medio Cielo entrano negli aspetti solo con l'ora di nascita.

### Cosa produce, e cosa NON produce

Produce `List<ChartAspect>` ordinata per orbo crescente, dal piu' stretto al
piu' largo, perche' nella tradizione un aspetto e' tanto piu' forte quanto piu'
e' vicino all'esatto. Ogni voce porta corpo in transito, corpo natale, tipo e
orbo. **Nessun testo**: il testo e' l'ordine 2 di 2.

## LE PORTE DELL'OROSCOPO, elenco completo

Enumerate, non campionate. Al 4 agosto 2026 il contenuto delle schede nasce da
**due porte nel codice** che leggono **quattro serbatoi nel corpus**.

### Le due porte

1. **`lib/core/horoscope/horoscope.dart`**, la porta principale.
   - `Horoscope.cardFor` produce titolo, testo, indicatore e, sulla scheda
     Fortuna, numero fortunato e colore. Seme `_fnv1a([segno, giorno, anno,
     dominio])`.
   - `Horoscope.openingFor` produce l'apertura personalizzata della scheda
     Generale, stesso seme derivato.
   - `Horoscope.vocativeFor` produce il vocativo dal profilo, ed e' l'unico
     pezzo che gia' oggi non viene dall'hash.
   - `Horoscope.disclaimer` rimanda al corpus.

2. **`lib/features/horoscope/oroscopo_share_card.dart:43`**, la porta che stava
   in un angolo. La card da condividere **non usa le schede che riceve**: si
   ricalcola la sintesi leggendo `HoroscopeData.anchors[sign.id]![0][1]`
   direttamente. Se l'ordine 2 di 2 sostituisse solo `Horoscope`, l'immagine
   condivisa continuerebbe a mostrare il testo vecchio, ed e' l'angolo esatto in
   cui l'oroscopo continuerebbe a mentire.

### I quattro serbatoi

Tutti in `lib/core/horoscope/horoscope_data.dart`: `anchors` (titolo e sintesi
per segno e dominio), `dayPools` (la corrente del giorno per dominio),
`openings` (le aperture), `palettes` (i colori del giorno). Piu' `disclaimer`,
che e' una riga fissa.

### Quello che NON e' una porta

Nessun percorso AI produce oggi il contenuto dell'Oroscopo: la ricerca su
`lib/services/ai/` e `lib/core/maestro/` non trova nessun riferimento. Il
commento in `horoscope.dart` che parla di Gemini descrive un futuro, non un
ramo vivo. `horoscope_visuals.dart` e `tradition_glyph.dart` disegnano e non
compongono testo. `AnswerDepth` governa il permesso, non il contenuto.

Una prova blocca questo elenco: se qualcuno apre una terza porta sul corpus,
cade e chiede di dichiararla.

**L'hash NON e' stato tolto**, e una prova pretende che resti. Toglierlo adesso
lascerebbe le schede vuote.

## Le prove del rosso, viste cadere

Dodici, tutte guardate rosse prima di essere guardate verdi, rimettendo il
difetto invece di fidarsi. Due erano cieche e le ha smascherate la mutazione.

| Prova del rosso | Esito | Cosa ha trovato |
|---|---|---|
| Una seconda funzione per la stessa longitudine | rossa | **Un falso positivo mio**: l'impronta `280.460` colpiva anche `gmstDegrees`, che usa `280.46061837` e non e' il Sole. Il confronto ora e' sul numero intero |
| Il Sole spostato dall'unificazione | rossa | niente, la formula e' identica |
| Un transito che cambia dentro lo stesso giorno civile | rossa | niente |
| `ConfineDelGiorno` modificato | rossa | niente, e' intatto |
| Una chiamata di rete nel calcolo | rossa | niente |
| Un corpo consegnato senza verifica | **cieca, poi corretta** | cercava il NOME del corpo, che compare anche nella tavola delle tolleranze: un corpo con tolleranza e senza riferimento passava. Ora pretende la riga dei valori, piu' una prova di completezza a runtime |
| Una firma usata da `features/maestri` cambiata | rossa | niente |
| Un orbo senza fonte citata accanto | rossa | niente |
| Un secondo modello degli aspetti | **cieca, poi corretta** | contava i FILE e non le definizioni: due modelli scritti nello stesso file le passavano sotto il naso. Ora conta le definizioni |
| Un aspetto calcolato con una chiamata di rete | rossa | niente |
| L'elenco che non dipende dalla carta natale | rossa | niente |
| Aspetti prodotti senza carta natale | rossa | niente |

## Cosa NON e' il massimo, e perche'

1. **Cinque pianeti su otto.** Urano, Nettuno e Plutone mancano per scelta
   dichiarata, non per difficolta'. Un oroscopo che non nomina mai Plutone dice
   meno di uno che lo nomina, e la ragione (troppo lenti per distinguere un
   giorno) e' buona per l'Oroscopo quotidiano ma non lo sarebbe per un
   responso sui cicli lunghi. Quando servira' un'arte sui cicli, andranno messi.

2. **Saturno e la Luna a un decimo e mezzo di grado.** Va benissimo per gli
   orbi, ma se un giorno si volesse mostrare "Luna a 12 gradi 04 del Leone",
   quel secondo decimale non e' affidabile. Le serie andrebbero allungate.

3. **La posizione e' geometrica, non apparente.** Manca l'aberrazione della luce
   e la nutazione, che valgono una ventina di secondi d'arco. Dentro le
   tolleranze, ma e' uno scarto sistematico e non casuale.

4. **La verifica e' su tre date.** L'ordine ne chiedeva almeno tre e sono tre.
   Con tre punti si vede se una formula e' giusta, non si vede il comportamento
   ai bordi, per esempio vicino alle stazioni retrograde dove i pianeti
   rallentano. Una verifica su cento date costerebbe poco e direbbe di piu'.

5. **La retrogradazione non c'e'.** La carta natale porta `retrograde` per ogni
   pianeta, il motore dei transiti no. Per gli aspetti non serve, per il testo
   dell'ordine 2 di 2 probabilmente si', perche' un Mercurio retrogrado e' una
   cosa che si dice.

6. **L'ordinamento per rilevanza e' solo l'orbo.** Un trigono di Giove largo
   quattro gradi finisce sotto una quadratura di Mercurio stretta un grado, e
   c'e' una tradizione che direbbe il contrario, perche' i corpi lenti pesano
   piu' dei veloci. Ho scelto la regola che non richiede pesi inventati, ma e'
   una scelta e non l'unica.

7. **Il motore non e' collegato a niente.** Nessuna schermata lo chiama. E'
   voluto, l'ordine lo dice, ma finche' non arriva l'ordine 2 di 2 questo codice
   e' verificato e inerte.

## AGGIUNTA ALL'ORDINE, le quattro cose prima del testo

Arrivata a lavoro gia' consegnato. Tutta aritmetica sui dati che il motore
produceva gia': non e' nato nessun secondo motore.

### 1. I transiti nelle case natali

`lib/core/astro/transiti_nelle_case.dart`. `casaDi` dice in quale casa cade una
longitudine, `perIlGiorno` da' la casa di ogni corpo per quella carta.

**Le case NON sono larghe trenta gradi.** Con le domificazioni per tempo possono
essere molto diverse fra loro, quindi si misura l'arco vero fra due cuspidi
invece di dividere il giro per dodici. Una prova percorre tutti i 3600 decimi di
grado e pretende che ognuno stia in una casa e in una sola, compreso lo
scavalcamento dello zero dell'Ariete.

**Senza ora di nascita non ci sono case, e non si inventano.** Le cuspidi
discendono dall'orizzonte locale all'istante della nascita: senza l'ora
`NatalChart` non le porta, e qui torna vuoto. E' la bugia piu' pericolosa fra
quelle possibili, perche' e' anche la piu' bella da leggere.

### 2. I moti retrogradi

`Effemeridi.retrogrado` e `Effemeridi.velocitaGiornaliera`. Non si legge da una
tabella: si guarda dove sta il corpo un mezzo giorno prima e un mezzo giorno
dopo, e se la longitudine cala il pianeta sta tornando indietro visto dalla
Terra.

Verificato contro cio' che dice il libro, non contro me stesso: **Mercurio
risulta retrogrado fra i 45 e gli 80 giorni nel 2026**, che sono le tre o quattro
retrogradazioni da tre settimane della manualistica; i tre lenti fra i 120 e i
190 giorni, cioe' i circa cinque mesi l'anno in cui la Terra li scavalca. Sole e
Luna non risultano mai retrogradi, e non e' una convenzione scritta a mano: la
loro longitudine geocentrica cresce sempre, quindi il calcolo lo dice da solo.

### 3. Aspetti applicativi o separativi

`ChartAspect.applicativo`, riempito confrontando l'orbo di oggi con quello di
domani. Vero se l'aspetto si sta stringendo, falso se si sta sciogliendo, nullo
quando non e' stato calcolato: negli aspetti interni alla carta la domanda non ha
senso, perche' la carta e' ferma.

### 4. I tre lenti, e una fonte che ho dovuto cambiare

Aggiunti Urano, Nettuno e Plutone. **Ma la tavola di Meeus non andava bene, e
l'ha detto la verifica.**

| Corpo | Con Meeus 31.A | Con gli elementi JPL |
|---|---|---|
| Urano | **0,9486 gradi di errore** | 0,0001 / 0,0005 / 0,0040 |
| Nettuno | **0,6308 gradi di errore** | 0,0066 / 0,0167 / 0,0059 |
| Plutone | non presente nella tavola | 0,0055 / 0,0149 / 0,0038 |

Urano e Nettuno si perturbano forte a vicenda e gli elementi medi non lo
raccontano: sbagliavano dieci volte piu' di Giove e Saturno. Plutone in quella
tavola non c'e' proprio, perche' la sua orbita e' troppo eccentrica e inclinata.
Tutti e tre sono passati agli elementi kepleriani approssimati del JPL,
E. M. Standish, *Keplerian Elements for Approximate Positions of the Major
Planets*, validi dal 1800 al 2050, portati dall'equinozio J2000 a quello della
data aggiungendo la precessione generale in longitudine.

Se non avessi verificato, avrei consegnato un Urano sbagliato di quasi un grado
dicendo che veniva da Meeus.

**L'orbo dei lenti e' due gradi**, stretto come quello della Luna ma per la
ragione opposta: la Luna corre troppo, questi stanno quasi fermi, e con cinque
gradi lo stesso aspetto resterebbe aperto per anni.

### Il limite dichiarato: si sa SE, non si sa QUANDO

`Effemeridi.giorniDiIncertezza`, e la ragione sta scritta accanto al calcolo.

Lo scarto misurato su Saturno e' 0,1414 gradi su un pianeta che percorre circa
0,03 gradi al giorno: sono **quasi cinque giorni di incertezza su quando un
transito e' esatto**. Per dire che l'aspetto C'E' va benissimo, perche' l'orbo e'
due gradi, quattordici volte lo scarto. Per dire "il transito e' esatto oggi"
no, e **nessun testo dell'ordine 2 di 2 lo deve affermare**. Il caso peggiore
sono proprio i lenti: precisissimi in posizione, lentissimi in moto, quindi il
giorno esatto e' l'unica cosa che il motore non sa dare.

### La porta nell'angolo e' chiusa

`oroscopo_share_card.dart` non legge piu' `HoroscopeData`. `HoroscopeCard`
guadagna il campo `synthesis`, valorizzato da `Horoscope.cardFor`, e la card lo
prende dalla scheda che gia' riceve.

**Non cambia un pixel oggi**, perche' e' la stessa stringa: cambia che adesso
passa dalla porta buona, quindi quando l'ordine 2 di 2 sostituira' la
composizione, l'immagine che la gente manda agli altri seguira' da sola. Le
porte dell'Oroscopo sono passate da due a **una**, e la prova che le enumera
adesso ne pretende una sola.

## I numeri della chiusura

- **Suite intera**: 1581 prove, tutte verdi, **9 minuti e 40 secondi**. E' la
  corsa fatta DOPO le correzioni alle due prove cieche: la corsa precedente,
  8 minuti e 53, non valeva piu' perche' tre file di prova erano cambiati dopo.
- **`flutter analyze`**: 57 problemi prima del mio lavoro, 57 dopo. **Zero
  problemi nuovi**, verificato mettendo da parte le modifiche e rimisurando.
- **File nuovi**: 3 in `lib/core/astro/`, 3 in `test/`.
- **File modificati**: 3, tutti in `lib/core/astro/`.
- **Cartelle vietate toccate**: nessuna.
