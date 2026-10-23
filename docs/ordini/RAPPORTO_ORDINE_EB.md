# RAPPORTO DELL'ORDINE EB, LE CHAT DEI MAESTRI

21 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`,
partenza dal commit `1c7a1eb4` (build 2274 consegnata). Manifesto in
`docs/ordini/ORDINE_EB_MANIFESTO.md`, con i quattro censimenti e il catalogo
per intero.

**Sigla EB**, la prima libera dopo EA: verificato sul ramo che non esiste
nessun `ORDINE_EB_*` in `docs/ordini`, nessuna `ordine_eb_guard` in `test/`,
e che nessun documento nomina un ordine EB.

## 1. LE OTTO VOCI

Otto voci, **otto chiuse**.

| voce | cosa | stato |
|---|---|---|
| EB.01 | la domanda preimpostata porta anche la domanda | chiusa |
| EB.02 | il Maestro risponde sempre | chiusa |
| EB.03 | il pulsante solo se l'utente lo chiede | chiusa |
| EB.04 | cio' che non e' una risposta non consuma | chiusa |
| EB.05 | niente ripetizioni e niente proposte gia' rifiutate | chiusa |
| EB.06 | quando mancano i dati, il Maestro li chiede | chiusa |
| EB.07 | il censimento delle chat e il catalogo di ogni mossa | chiusa |
| EB.08 | le tre personalita' e l'illusione della persona vera | chiusa |

## 2. LA CAUSA DEL FATTO, MISURATA

Il classificatore cercava la parola dell'arte dentro il testo, e il controller
mandava l'invito **tornando prima di chiamare il modello**. Nessuna nozione di
intenzione: la presenza di una parola.

Passate al classificatore le frasi vere delle due catture, **quattro su cinque
instradavano alla Stesa**, compresa *"non voglio una stesa"*: **la negazione
pesava zero**. E la domanda preimpostata conteneva essa stessa la parola
*stesa*, quindi il testo che portava le carte da interpretare veniva letto
come richiesta di estrarne altre.

**Il numero della cura:** delle undici frasi che nominano un'arte senza
chiederla, prima ne passavano **nove**, adesso **zero**; delle sei che la
chiedono davvero, passano ancora **tutte e sei**.

## 3. I DIFETTI, E CHI LI HA FATTI NASCERE

Regola C: ogni difetto ha un padre, e dove non si risale si scrive
**PROVENIENZA IGNOTA** per esteso.

| difetto | padre |
|---|---|
| il classificatore instrada sulla presenza di una parola, e la negazione pesa zero | **PROVENIENZA IGNOTA**: nasce col file, nessun ordine risulta averlo introdotto, e la prova che lo codifica non porta sigla in testata |
| la chat che si apre dalla Stesa non porta la domanda | **PROVENIENZA IGNOTA**: `ChatOpeners.stesa` nasce col file con la sola lista delle carte |
| la Stesa manda al Maestro il nome della carta senza il verso | **PROVENIENZA IGNOTA**, stessa riga e stessa nascita |
| due esiti del turno dichiarati e mai costruiti | **PROVENIENZA IGNOTA**: l'enum nasce con l'ordine che ha creato `CostoDelTurno`, e i due rami tornavano gia' cosi' |
| il benvenuto uguale per i tre Maestri, col lessico di tutti e tre | **PROVENIENZA IGNOTA**: `MaestroWelcome` nasce con le due liste condivise |
| la testata di `chat_openers.dart` dice che la domanda preimpostata parte da sola | DX voce 01, che ha reso il testo in attesa nel campo senza aggiornare la testata |
| il manifesto DX porta numeri di riga vecchi di una decina di righe | DX stesso, e il ramo si e' mosso dopo |

## 4. GLI SCARTI FRA L'ORDINE E IL RAMO

Sei, tutti col file e la riga, elencati nel manifesto alla sezione *Gli scarti
fra l'ordine e il ramo*. **Il piu' utile e' il primo:** l'ordine chiedeva di
verificare se le porte fossero ancora dodici piu' una, e **l'ordine DX le
aveva contate giuste**: sono tredici, confermate per tre vie indipendenti.

## 5. UNA COSA VISTA E LASCIATA FUORI, DICHIARATA

A `stesa_tre_carte_screen.dart:1734` il `ResponsoDaCustodire` scrive i nomi
delle carte senza il verso, quindi **anche il Ricordo custodito lo perde**.
Non e' il testo che apre la chat e non e' il perimetro di quest'ordine;
toccarlo cambierebbe la forma di dati gia' scritti sui telefoni delle
persone. **Va misurato e deciso in un ordine suo.**

## 6. DUE CAMBI DI LEGGE, DICHIARATI INVECE CHE NASCOSTI

1. **`intent_routing` pretendeva che *"parlami dei miei chakra"* aprisse lo
   Scan.** Chi chiedeva PAROLE riceveva un pulsante e nessuna risposta: e' il
   difetto della voce 02 in un'altra arte. Adesso Aura risponde, e la persona
   puo' chiedere lo Scan quando vuole. La pretesa e' stata riscritta col suo
   perche' dentro.
2. **`consulta_maestro` contava le formule del pool del benvenuto** e ne
   pretendeva almeno dieci. Adesso conta i **benvenuti composti**, per ognuno
   dei tre, che e' la grandezza che una persona vede.

## 7. LE GUARDIE

**Regola B, eseguita prima di mettere mano.** Quattro innesti sulla zona
dell'instradamento, quattro rossi. **Un quinto innesto e' stato buttato
invece di credergli**: togliere la sola parola `stesa` non faceva cadere
niente, e giustamente, perche' la parola `tarocchi` copre la stessa frase da
sola. Si e' cambiata la grandezza innestata, non la soglia. **E una guardia
registrata e' rimasta verde sui primi tre innesti senza essere degradata**:
`ogni_pulsante_della_chat_apre_cio_che_promette` misura che un pulsante apra
l'arte che nomina, non chi scatta l'instradamento. Provata dentro la sua
zona, col quarto innesto, e' rossa. **Una guardia verde su un innesto non e'
automaticamente una guardia morta: prima si guarda se quell'innesto stava
nella sua zona.**

**Sette guardie nuove**, e il registro passa da 453 a **461**:

| guardia | voce | come e' stata vista rossa |
|---|---|---|
| `ordine_eb_guard` | tutte | da se': l'ordine nasce con otto voci aperte |
| `la_chat_sa_a_cosa_rispondono_le_carte` | 01 | tre innesti |
| `il_maestro_risponde_nel_merito` | 02, 05, 06 | tre innesti |
| `il_pulsante_solo_se_lo_chiedi` | 03 | **nata rossa sul difetto vero**: nove frasi su undici |
| `un_rifiuto_vale_per_tutta_la_conversazione` | 05, 07 | due innesti |
| `ogni_esito_del_turno_e_costruito` | 04 | **nata rossa**: due esiti a zero costruzioni, poi due innesti |
| `ogni_maestro_saluta_con_la_sua_voce` | 08 | **nata rossa**: dodici benvenuti identici su dodici, venti saluti col lessico altrui |
| `il_catalogo_delle_mosse_e_eseguito` | 07 | pretende le sedici mosse e che ogni posto esista |

**Due inciampi di casa, presi durante il lavoro.** La prima stesura della
guardia della voce 01 **pescava il proprio commento**, perche' il commento
che spiega la cura nomina il difetto che cura: adesso legge il sorgente senza
commenti. E la stessa guardia guardava tutto il file invece del solo sito di
chiamata, quindi confondeva la chat col Ricordo custodito.

## 8. COSA RESTA DA VEDERE A VIDEO, E CHI LO VEDE

**Cinque mosse del catalogo su sedici non dipendono dal modello**, e per
quelle il comportamento e' misurato. **Le altre undici le governa
l'istruzione di sistema**: nessuna prova deterministica puo' garantire che
Gemini la rispetti, e quello che si prova e' che **la regola gli arrivi**.
L'altra meta' la guarda il fondatore parlando coi Maestri.

**Nessuna build e' stata fatta**, come l'ordine impone. **Serve una build per
vedere a video** il testo nuovo che apre la chat dalla Stesa, i tre benvenuti
diversi e il comportamento della chat sulle frasi delle catture: se il
fondatore la vuole, lo dica e si fa.

**L'istruzione di sistema e' cambiata, e non in silenzio**: le tre impronte
sono state riregistrate e le vecchie sono scese nello storico con la data e
con cio' che le ha fatte cadere. **La misura dell'attribuzione cieca era gia'
dichiarata non valida prima di quest'ordine e resta tale**: e' uno dei due
rossi accettati, e nessuna riga di quest'ordine lo tocca.
