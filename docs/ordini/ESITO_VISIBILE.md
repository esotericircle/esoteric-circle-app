# ESITO dell'ORDINE SOLO CIO' CHE SI VEDE

## Dichiarazione, scritta prima di toccare il codice

Le diciannove voci non pesano uguale. Misurate adesso, si dividono in tre
famiglie.

**Chirurgiche, il codice esiste e va corretto o tolto** (dieci voci): V1 la
causa della costellazione ripetuta, V3 il ritorno indietro, V7 i testi falsi
(56 occorrenze di "provvisorio" o "segnaposto" sparse in 21 file), V10 il
pareggio e la A spezzata, V11 l'avatar e il nome alla fonte, V13 il pulsante
degli aspetti da togliere, V14 la linea storta da eliminare, V16 le
sovrapposizioni, V18 il .gitignore col blocco duplicato, V19 le due frasi in
STATO_VIVO.

**Da capire prima di correggere** (due voci): V2, il cielo di nascita che
ripiega sul dato d'esempio; V12, il permesso di posizione che non compare.
Tutte e due chiedono un test che monta l'app dall'avvio vero, che e' la forma
di test piu' lenta da scrivere in questo repository.

**Visivi nuovi, da disegnare da zero** (sette voci): V4 il planisfero a punti
che si illumina, V5 l'orologio con le lancette animate, V6 l'anteprima del
tono che si scrive, V8 il Sigillo al centro col trionfo, V9 i due trionfi di
Animale e Angeli, V15 il carosello che ruota davvero col dito, V17 la mano
con l'indice. Ognuno e' un painter o una coreografia nuova.

**La stima.** Chiudo le prime due famiglie per intero, dodici voci, piu' i
visivi nuovi fin dove arrivo, nell'ordine V17, V14, V4, V5, V8, V6, V9, V15.

La ragione in numeri della prudenza sui visivi: sette animazioni nuove, mentre la
storia di questo cantiere dice che una coreografia nuova ben fatta costa
quanto tre correzioni chirurgiche. Il carosello (V15) e' l'ultimo di
proposito: e' fisica di trascinamento su una schermata da 1192 righe, ed e'
la sola voce che potrebbe restare fuori senza compromettere le altre.

Le voci non aperte saranno elencate qui sotto col nome, mai scoperte alla
fine.

## Stato voce per voce

### V1, la costellazione ripetuta: CHIUSA

**Il rosso, prima della correzione.** `Zodiac.aries sta nello stesso punto con
due semi diversi`, atteso diverso da `Offset(0.2, 0.1)`, ottenuto
`Offset(0.2, 0.1)`. E `showZodiac` valeva `true` per difetto.

**Il perche', che era la parte importante.** La diagnosi dei diciotto semi era
sbagliata, me ne assumo la responsabilita': il seme muove stelle sparse,
nebulose e comete, mentre le dodici costellazioni zodiacali avevano l'ancora
scritta come costante nel codice e non leggevano il seme. Ogni fondale
dell'app disegnava lo stesso Ariete nello stesso angolo. Il criterio "zero
costellazioni ripetute" risultava verde perche' il test guardava i semi, non
l'asterismo.

**La correzione.** La volta ruota col seme: permutazione delle celle della
griglia, scarto dentro la cella, scala variabile e ribaltamento orizzontale,
tutto deterministico. In piu' l'asterismo e' SPENTO per difetto, quindi il
caso "compare ovunque" non puo' tornare per distrazione. Cinque test.

### V2, il cielo di nascita: CHIUSA, con due difetti invece di uno

**Il rosso, prima della correzione.** Il test sul percorso vero del Risveglio
trovava la parola "esempio" col luogo appena inserito. E il test sull'ora:
`mattina [virgo, libra, leo]`, `sera [virgo, libra, leo]`, identiche.

**Primo difetto, la bolla.** La frase era scritta a mano e non guardava mai il
profilo, quindi mentiva proprio a chi aveva compilato tutto. Ora la scheda sa
se la nascita e' registrata: dal profilo fuori dal Risveglio, dichiarata dal
flusso dentro, dove il profilo non e' ancora scritto e direbbe di no.

**Secondo difetto, trovato dal test sulla data nota.** Le costellazioni
ignoravano l'ora: il calcolo usava solo la longitudine del Sole, che cambia di
un grado al giorno. Chi nasceva alle sette del mattino e chi alle sette di
sera vedeva la stessa identica volta. Ora la volta ruota di quindici gradi
ogni ora, come ruota la Terra. Resta dichiarata l'approssimazione di tutto
quel file: la longitudine eclittica sta al posto dell'ascensione retta.

Il client FreeAstroAPI non c'entrava: questa schermata non lo chiama, calcola
in locale col motore deterministico. Il guasto era nel calcolo locale e nella
frase, non nel client.

### V3, tornare indietro nell'onboarding: CHIUSA

Freccia nella riga dei puntini dal secondo passo, piu' il gesto Indietro di sistema
che retrocede invece di uscire, uscendo solo dal primo passo. Prima il gesto
buttava fuori dal rito portandosi via tutto quello che era stato inserito.
Tre test, incluso quello che manda il messaggio `popRoute` vero della
piattaforma.

### V4, il planisfero a punti: NON APERTA

### V5, l'orologio dinamico: NON APERTA

### V6, l'anteprima animata del tono: NON APERTA

### V7, i testi falsi: CHIUSA

Tolte le frasi che dichiaravano l'Ascendente un segnaposto. Tolto il
distintivo "Provvisorio" dal Risveglio, piu' quello maiuscolo dalle cartoline dei
doni quotidiani, che il grep a mano non aveva trovato e il lucchetto si'. La
nota che spiega cosa comporta saltare un dato resta, perche' quella e' vera,
e perde solo il distintivo. L'ora non e' piu' precompilata: si parte da "Non
la so". Un lucchetto nuovo scandaglia le stringhe del sorgente, non i
commenti, poi cade se tornano quelle frasi, quel distintivo o una frase che
finisce col doppio punto.

### V8, il Sigillo al centro col trionfo: NON APERTA

E' la terza volta che viene chiesta, quindi la dichiaro per prima nel prossimo
passaggio.

### V9, i trionfi di Animale e Angeli: NON APERTA

La tessera degli Angeli nella carta natale APRE gia' la schermata dedicata,
fatta in un ordine precedente. Mancano i due trionfi nell'onboarding.

### V10, "Chi risuona in te": CHIUSA

Larghezza uguale per i tre, quindi MEDORA non spezza piu' la A. Il nome vive
in una scatola di altezza fissa su una riga sola, quindi le tre percentuali
cadono sulla stessa linea di base anche col vincitore piu' grande. E il 35 a
35: se due arrotondamenti collidono compare un decimale che li separa; se il
pareggio e' vero si dichiara il criterio, cioe' il fattore decisivo che il
motore gia' calcola. Quattro test.

### V11, avatar e nome: META', dichiarata qui

**Il nome: CHIUSO.** Si normalizza ALLA FONTE, dove entra. "mauro" diventa
Mauro, "MAURO" diventa Mauro, i composti tengono ogni iniziale, McDonald resta
McDonald perche' una maiuscola interna e' voluta. Sette test, col rosso prima.

**L'avatar che copre: NON VERIFICATO.** Ho messo la protezione (la carta si
rimpicciolisce invece di traboccare) ma il test che avevo scritto passava
anche TOGLIENDO la correzione, quindi non misurava il difetto: prendeva il
rettangolo del widget, mentre la testa esce dal box e quel rettangolo non la
vede. L'ho cancellato invece di lasciare un verde che non prova niente. La
protezione resta, la voce no.

### V12, il permesso di posizione: CHIUSA

**La causa.** Il tocco non faceva comparire nessuna richiesta di sistema
perche' si usciva PRIMA di chiederla, se il servizio di posizione del telefono
era spento. I permessi nel manifest c'erano gia'. Ora il permesso si chiede
per primo.

**E l'esito non e' piu' un null muto.** Concesso, negato, servizio spento e
non disponibile erano la stessa cosa, quindi la schermata non poteva ne'
spiegare ne' offrire la via giusta: chi negava e chi aveva il GPS spento
leggevano la stessa frase, sbagliata per uno dei due. Adesso concesso dichiara
l'orientamento, negato dichiara il ripiego sul cielo di nascita e apre i
permessi dell'app, servizio spento manda alle impostazioni del dispositivo.
Quattro test.

### V13, gli aspetti sempre accesi: CHIUSA

Il pulsante e' stato tolto col suo widget. Le linee passano da 0,8 px a 32 di
opacita' a 1,7 px a 58, col cerchio da 0,6 a 1,0: a densita' 1 il simulatore
le mostrava, su un telefono vero cadevano sotto il pixel fisico. Il
collegamento pianeta-bolla non e' stato toccato.

### V14, la linea storta: CHIUSA

Eliminata col suo painter e con la variabile che la alimentava.

### V15, il carosello che ruota: NON APERTA

Era l'ultima della mia dichiarazione, ed e' rimasta fuori come previsto.

### V16, le sovrapposizioni della Home: CORRETTA, NON VERIFICATA

La zona d'ingresso era alta 78 pixel per costante scritta a mano: adesso si
MISURA a schermo, quindi il carosello sa dove fermarsi anche col testo di
sistema ingrandito. Ma il test che avevo scritto passava anche col codice
vecchio, per lo stesso motivo di V11, quindi l'ho cancellato. La correzione resta,
la voce non la dichiaro chiusa.

### V17, la mano con l'indice: CHIUSA

Era due rettangoli arrotondati piu' un ovale, quindi a schermo si leggeva come un
cursore. Ora e' un contorno continuo con le tre nocche delle dita piegate a
destra e la gobba del pollice a sinistra: sono quelle due sagome a far
riconoscere una mano, non la presenza di un dito dritto. Guardata ingrandita
nell'anteprima, non dedotta.

Guardandola e' saltata fuori una sovrapposizione che nessuno aveva elencato:
la riga "Tocca il cielo" cadeva sopra il nome della fase lunare. Spostata.

### V18, il .gitignore: CHIUSA

Il blocco dei segreti compariva due volte, con la prima copia saldata alla
riga precedente, quindi la sua intestazione faceva parte di un pattern invece
di commentare. Ora e' unico. Ignorati i loghi sorgente, le preferenze locali
dell'agente e gli script personali della radice; `tool/` resta versionato,
verificato con `git check-ignore`.

### V19, l'Albero della Vita: CHIUSA

Le due sostituzioni letterali chieste, verificate una a una.

## Stima contro consegnato

Avevo dichiarato: le dodici voci chirurgiche e d'indagine per intero, piu' i
visivi nuovi nell'ordine V17, V14, V4, V5, V8, V6, V9, V15.

Consegnato: undici voci chiuse (V1, V2, V3, V7, V10, V12, V13, V14, V17, V18,
V19), una a meta' dichiarata (V11), una corretta senza prova (V16), sei non
aperte (V4, V5, V6, V8, V9, V15).

**Dove la stima ha sbagliato.** Avevo messo V11 e V16 fra le chirurgiche,
cioe' fra quelle che si chiudono e basta. Sono difetti di sovrapposizione, e
un difetto di sovrapposizione si riproduce solo se sai misurare l'area
DISEGNATA, che non e' il rettangolo del widget quando un elemento sfora col
Clip.none. Ho scritto due test che passavano anche togliendo la correzione: li
ho scoperti rifacendo la prova del rosso, poi li ho cancellati. Chiuderli
davvero vuol dire misurare i pixel dell'immagine catturata, che e' lavoro da
voce visiva, non da voce chirurgica.

I visivi nuovi sono rimasti sei su sette: e' andata peggio della stima, che ne
dava per probabili almeno due o tre. La ragione sta nelle indagini: V1, V2 e
V12 hanno richiesto ciascuna di trovare la causa vera, mentre V2 e V12 hanno
restituito due difetti ciascuna invece di uno.

## Cosa hanno mostrato le anteprime, guardate

Rigenerate tutte col precache: diciannove cambiate.

- `santuario-medora.png`: la linea storta non c'e' piu' (V14), la bolla del
  dominio non tocca l'avatar, le tre carte stanno al loro posto.
- `santuario-invito.png`, ingrandita tre volte: la mano si legge come una
  mano, con l'indice teso, le tre nocche e il pollice (V17). Guardandola ho
  visto che la riga "Tocca il cielo" cadeva sopra il nome della fase lunare,
  difetto che nessuno aveva elencato, quindi l'ho spostata.
- `cielo-nascita.png`: le costellazioni sono CAMBIATE rispetto alla cattura
  di ieri, da Capricorno e Sagittario a Pesci, Acquario e Capricorno. E' la
  prova a schermo che la correzione dell'ora di V2 morde davvero, non solo
  nel test.

  Guardandola ho trovato un secondo difetto non elencato: il nome
  "Capricorno" spariva dietro la scheda in basso, quindi una costellazione
  toccabile era di fatto invisibile. I tre slot dei corpi alti stavano a 0,52
  0,44 e 0,64 mentre la scheda occupa il terzo basso: ora sono a 0,46 0,38 e
  0,56, cosi' tutti e tre i nomi si leggono.
- `carta-natale.png`: il pulsante degli aspetti e' sparito (V13). Le linee
  d'aspetto non si vedono in questa anteprima perche' la carta d'anteprima e'
  quella essenziale, senza pianeti: lo spessore nuovo NON e' stato verificato
  a schermo, solo scritto. Lo dichiaro invece di darlo per buono.

## I numeri finali

- Suite: **869 test verdi**.
- `flutter analyze` su lib e test: pulito.
- Versione: **2102**.
- Voci chiuse con prova: **undici**. A meta' dichiarata: **una**. Corrette
  senza prova: **una**. Non aperte: **sei**.
- Difetti trovati da me guardando, non elencati nell'ordine: **due**, la riga
  dell'invito sopra la fase lunare e il nome della costellazione sotto la
  scheda.
- Test cancellati perche' passavano anche togliendo la correzione: **due**.
