# ORDINE FI, LA STESA DI TAROCCHI

Il testo dell'Architetto come e' arrivato, in tre pezzi la sera del 10 ottobre 2026, con l'aggiunta sulla scrittura dei corpus e la segnalazione del fondatore su taglio e mescolamento dell'11 ottobre. Trascritto senza toccarlo.

---

ORDINE FI, LA STESA DI TAROCCHI, PEZZO 1 DI 3
Esoteric Circle, 10 ottobre 2026. Ramo: claude/esoteric-circle-master-order-e798aj.
Testa vista alle 22:02 del 10 ottobre: 8b113c7943452918627c1999c3beccedae0a31dd.

PREMESSE DA ABBATTERE
Verificale sul repository PRIMA di toccare una riga. Se anche una sola e' falsa,
fermati e riportala senza eseguire nulla.

P1. lib/core/tarot/tarot_spread_type.dart contiene l'enum TarotSpreadType con tre
    voci: treCarte disponibile, setteCarte e dieciCarte non disponibili.
P2. lib/core/tarot/tarot_spread.dart contiene l'enum SpreadPosition con tre sole
    voci: passato, presente, futuro.
P3. lib/features/tarot/tarot_selectors.dart contiene ReadingKey con predittiva,
    riflessione, esoterica, e TarotDeckStyle con riderWaite, marsiglia, thoth.
P4. In lib/features/tarot/stesa_tre_carte_screen.dart il seme della stesa nasce da
    Random().nextInt quando widget.seed e' nullo, cioe' a ogni apertura.
P5. docs/corpus/tarocchi_nella_posizione.md porta 468 testi, 78 carte per 2 versi
    per 3 posizioni, e dichiara in testa come e' stato generato.
P6. tool/genera_carte_nella_posizione.py esiste e la sua costante POSIZIONI vale
    ('passato', 'presente', 'futuro').
P7. In lib/core/tarot/tarot_card.dart ogni carta porta il campo stem col nome del
    file d'arte, e La Giustizia ha stem tar_rw_11_la-giustizia_v1 mentre La Forza
    ha stem tar_rw_08_la-forza_v1.
P8. assets/img/mazzo-tarocchi/ contiene 79 file, tutti col prefisso tar_rw_, e
    assets/img_thumb/mazzo-tarocchi/ ne contiene altri 79.
P9. Le cartelle assets/Mazzo Marsiglia/ e assets/Mazzo Thoth/ NON sono sul ramo:
    esistono solo nella copia di lavoro sul disco.
P10. lib/core/entitlement/plan_catalog.dart ha haLaStesaDaDieci e la riga
     RigaDelPiano.stesaDaDieci.
P11. lib/core/tarot/tarot_topic.dart contiene TarotTopicGroup con tre voci, amore,
     lavoro, vita, e TarotTopic con sedici argomenti.
P12. In lib/core/tarot/la_lettura_dal_modello.dart l'istruzione che parte verso il
     modello nomina le tre posizioni passato, presente e futuro a testo fisso.

REGOLE DI CASA, valgono per tutto l'ordine
R1. Un ramo solo, quello in testa. Nessun ramo nuovo.
R2. Mai il trattino lungo. Mai la virgola prima di "e" o di "ed". Accenti veri nei
    testi a video. Tutto in italiano.
R3. Non condensare, non riassumere, non riformattare nessun documento. Le novita'
    entrano nella sezione giusta o in una sezione nuova.
R4. Prove mirate durante le voci, la suite intera UNA volta sola in fondo, prima
    del push e del rapporto.
R5. Ogni guardia nuova nasce rossa: si inietta il difetto, si verifica COL GREP che
    sia entrato nel file, e solo dopo si legge l'esito. Quando il rosso non scatta
    si cambia la grandezza misurata, mai la soglia.
R6. Chi tocca una zona gia' coperta da una guardia la vede rossa PRIMA di metterci
    mano, e aggiorna la data nel registro docs/guardie.md.
R7. Ogni difetto nominato nel rapporto e' attribuito alla voce che l'ha causato, con
    numero d'ordine e di voce. Quando non si risale si scrive PROVENIENZA IGNOTA.
R8. Si commette a ogni voce chiusa, non tutto alla fine.
R9. La build la ordina Mauro. Se serve, la domanda si gira a lui.
R10. Dichiara all'inizio, in numeri, fin dove arrivi in questo ordine. Questo e' un
     ordine grande: se il margine non basta, chiudi per intero le parti che apri e
     lascia le altre intatte, scrivendo in docs/ordini/RIPRESA.md da dove si
     riparte. Non aprire cio' che non puoi chiudere ne' verificare.

PARTE 1. IL CATALOGO DELLE STESE

Fonte: Mauro, 10 ottobre 2026, "bisogna inserire la stesa a 1 carta e quelle delle
tradizioni piu' popolari"; le posizioni della stesa a quattro vengono da Dora,
trascritte da Mauro il 10 ottobre; il ferro di cavallo e' scelta di Mauro, "3 ferro
di cavallo".

FI.01 Le cinque stese. Porta TarotSpreadType da tre voci a cinque, con le posizioni
di ciascuna come dato e non come stringa nella schermata.

  unaCarta     1 carta   "La carta sola"
     posizioni: cartaSola
     fonte: la carta del giorno della cartomanzia, forma minima della lettura
  treCarte     3 carte   "Passato, Presente, Futuro"
     posizioni: passato, presente, futuro
     fonte: Etteilla per le posizioni fisse, anni 1780; diffusa da Eden Gray,
     The Tarot Revealed, 1960
  croceQuattro 4 carte   "La croce"
     posizioni, nell'ordine di lettura: consultante (in basso), lato (a sinistra),
     lato (a destra), esito (in alto)
     fonte: il tirage en croix della tradizione francese, letto col mazzo di
     Marsiglia; la variante dei due lati aperti e' la lettura del Cerchio
  setteCarte   7 carte   "Il ferro di cavallo"
     posizioni: passato, presente, futuro, consiglio, ambiente, ostacolo, esito
     fonte: forma diffusa nella cartomanzia moderna, senza autore documentato, e
     questo si dichiara nel Foglio delle Fonti invece di inventarle un'origine
  dieciCarte   10 carte  "La Croce Celtica"
     posizioni, nell'ordine di Waite: copre, attraversa, corona, sotto, passato,
     futuro, seStesso, laCasa, speranzeOTimori, esito
     fonte: Arthur Edward Waite, The Pictorial Key to the Tarot, 1911, capitolo
     "An Ancient Celtic Method of Divination"

  La quinta e la sesta posizione della Croce Celtica sono il "dietro" e il "davanti"
  di Waite: riusano passato e futuro e non sono posizioni nuove.

FI.02 La geometria e' un dato. Ogni stesa dichiara dove va ogni carta sul tavolo,
non in fila. La croce di Dora e' una croce: la prima in basso, la seconda a
sinistra, la terza a destra, l'ultima in alto. La Croce Celtica e' la figura di
Waite, con la seconda carta messa di traverso sulla prima. Le coordinate vivono
accanto alle posizioni, cosi' la schermata le legge invece di disporle a mano.

FI.03 La regola di lettura della croce di Dora, parole sue trascritte da Mauro:
"l'ultima carta, quella sopra, e' l'esito della domanda, pero' passa attraverso le
due carte laterali che sono consigli o ostacoli". Il testo dell'esito si compone
dopo i due lati e li nomina: non e' un verdetto isolato.

PARTE 2. LE DICIASSETTE POSIZIONI

FI.04 Porta SpreadPosition da tre a diciassette voci. Tre esistono gia' e non si
toccano. Le quattordici nuove, con l'etichetta a video fra virgolette:

  cartaSola        "La carta"          la stesa a una carta
  consultante      "Il consultante"    la croce di Dora, in basso
  lato             "Il lato"           la croce di Dora, a sinistra e a destra
  esito            "L'esito"           croce di Dora, ferro di cavallo, Croce Celtica
  consiglio        "Il consiglio"      ferro di cavallo
  ostacolo         "L'ostacolo"        ferro di cavallo
  ambiente         "L'ambiente"        ferro di cavallo
  copre            "Ciò che copre"     Croce Celtica, prima carta
  attraversa       "Ciò che attraversa" Croce Celtica, seconda carta, di traverso
  corona           "Ciò che corona"    Croce Celtica, terza carta
  sotto            "Il fondamento"     Croce Celtica, quarta carta
  seStesso         "Te stesso"         Croce Celtica, settima carta
  laCasa           "La tua casa"       Croce Celtica, ottava carta
  speranzeOTimori  "Speranze o timori" Croce Celtica, nona carta

  Fonte delle sette etichette della Croce Celtica: Waite, 1911, che per le prime sei
  usa le formule "this covers him", "this crosses him", "this crowns him", "this is
  beneath him", "this is behind him", "this is before him".

FI.05 L'etichetta "Te stesso" cade sotto la guardia del genere: la forma a video
passa dal blocco di cortesia come ogni altro testo rivolto alla persona.

PARTE 3. LE QUATTRO CHIAVI DI LETTURA

Fonte: Mauro, 10 ottobre 2026, "eliminerei quella di Caligo e inserirei tradizione e
fonti reali" e "confermo che voglio la quarta".

FI.06 ReadingKey diventa:

  predittiva   "Predittiva di Medora"
    tradizione: la cartomanzia divinatoria di Etteilla, pseudonimo di Jean-Baptiste
    Alliette, primo cartomante professionista a pubblicare metodi di lettura, anni
    1780. Resta la chiave viva per tutti.
  riflessione  "Riflessione"
    tradizione: la Tarologia di Alejandro Jodorowsky e Marianne Costa, La Voie du
    Tarot, 2004. Lettura dichiaratamente NON predittiva. Nota etica invariata:
    ispirazione dichiarata, mai un marchio.
  esoterica    "Esoterica"
    tradizione: Arthur Edward Waite, The Pictorial Key to the Tarot, 1911, e
    l'Ordine Ermetico dell'Alba Dorata. Sostituisce "Esoterica Caligo", che
    sparisce: era un nome di casa messo accanto a una persona reale.
  archetipica  "Archetipica"
    tradizione: Sallie Nichols, Jung and Tarot, 1980, e Rachel Pollack,
    Seventy-Eight Degrees of Wisdom, 1980. Una chiave sola con due fonti, non due.

FI.07 La chiave non moltiplica il corpus: cambia il registro con cui il modello
racconta lo scheletro, come prescrive il Master Briefing Tecnico. Nel prompt la
chiave entra come istruzione di voce. Con la Riflessione il modello legge anche la
posizione futuro come tendenza e mai come annuncio, perche' quella scuola non
predice.

FI.08 La lettura di casa, quella che si mostra quando il modello non risponde, resta
nella chiave predittiva e lo DICHIARA a chi legge, invece di spacciare un ripiego
per la chiave scelta.

---

ORDINE FI, PEZZO 2 DI 3

PARTE 4. I TRE MAZZI

Fonte: Mauro, 10 ottobre 2026, "i mazzi sono già pronti", piu' il suo messaggio coi
percorsi; e "La tradizione deve essere rispettata, non dovevi nemmeno chiedermelo,
cosa risponderei se un professionista lo notasse?".

FI.09 Il difetto che questa parte chiude, misurato dall'Architetto. Il catalogo lega
ogni carta al suo file col campo stem, scritto a mano. Sui ventidue arcani maggiori
il Rider-Waite e il Marsiglia portano nomi diversi su SETTE numeri, e due di questi
sono uno scambio vero di carta:

  numero 1   Il Mago        contro  Il Bagatto
  numero 5   L'Ierofante    contro  Il Papa
  numero 8   LA FORZA       contro  LA GIUSTIZIA
  numero 11  LA GIUSTIZIA   contro  LA FORZA
  numero 13  La Morte       contro  L'Arcano senza nome
  numero 16  La Torre       contro  La Casa di Dio
  numero 17  Le Stelle      contro  La Stella

Il Thoth ha lo stesso scambio con nomi suoi: l'VIII e' l'Aggiustamento, l'XI e' la
Lussuria, le corti sono Principessa, Principe, Regina, Cavaliere al posto di Fante,
Cavaliere, Regina, Re, e il seme dei Denari si chiama Dischi.

Chi sostituisse soltanto il prefisso del file metterebbe l'immagine della Forza sotto
il nome della Giustizia. Non si sostituisce il prefisso: si scrive una TABELLA DI
CORRISPONDENZA per mazzo, settantotto righe ciascuna, dove ogni carta del catalogo
dichiara il suo file in quel mazzo.

FI.10 Il Marsiglia. La tabella esiste gia' ed e' assets/Mazzo Marsiglia/
ELENCO_DEFINITIVO.md sul disco: settantotto voci, verificate dall'Architetto come
complete, senza numeri mancanti e senza doppioni. Quel file dichiara testualmente
che tutti i file della cartella che non vi compaiono sono versioni scartate. Si
prendono SOLO i file che l'elenco nomina. Fonte della tradizione da scrivere nel
Foglio delle Fonti: Tarot de Marseille di Nicolas Conver, 1760.

FI.11 Il Thoth. In quella cartella non esiste nessun elenco definitivo: vale
l'ultima versione presente per ciascuna carta, che e' la v1 per tutte tranne il
Cinque di Dischi, che e' alla v3. Scrivi tu assets/Mazzo Thoth/ELENCO_DEFINITIVO.md
nella stessa forma di quello del Marsiglia, con dentro la fonte della tradizione,
Aleister Crowley e Frieda Harris, The Book of Thoth, 1944. L'assenza di quell'elenco
era un debito, non una licenza a scegliere.

FI.12 Che cosa entra nel ramo. Dalle due cartelle entrano SOLO i webp definitivi,
mai i png, mai le versioni scartate, mai la sottocartella Correzioni del Marsiglia,
che contiene dieci immagini generate e non ancora integrate. Vanno in
assets/img/mazzo-marsiglia/ e assets/img/mazzo-thoth/, con le miniature in
assets/img_thumb/, come gia' fa il Rider-Waite, e si dichiarano nel pubspec.

FI.13 Misura obbligatoria da riportare nel rapporto. Il solo Rider-Waite pesa oggi
26 MB di immagini piu' 4,5 MB di miniature, e l'intera cartella assets pesa 147 MB.
Misura quanto pesano i due mazzi nuovi e quanto cresce l'archivio consegnato, con il
comando esatto che ha prodotto la misura e il peso in base 1000 e in base 1024. Se
la crescita e' tale da cambiare la decisione, fermati e gira la domanda a Mauro
invece di deciderla.

FI.14 I nomi delle carte seguono la tradizione del mazzo scelto. Decisione di Mauro:
la tradizione si rispetta. Quindi esistono TRE elenchi di nomi localizzati, uno per
mazzo: chi sceglie il Thoth legge La Lussuria e Il Principe di Coppe, chi sceglie il
Marsiglia legge Il Bagatto e La Casa di Dio, chi resta sul Rider-Waite legge La
Forza e Il Re di Coppe. Nome e numero restano stringhe sovrapposte a runtime, come
prescrivono i briefing, e i cartigli restano vuoti.

FI.15 La numerazione segue il mazzo. Nel Marsiglia i numeri si scrivono alla maniera
antica, IIII, VIIII, XIIII, XVIIII, il Matto non ha numero e il XIII non ha nome.
Questi sono i tratti per cui un cartomante riconosce un mazzo di Marsiglia vero.

FI.16 Verifica dei cartigli prima di committare. L'Architetto ha aperto quattro
carte definitive, Il Matto v4, Il Bagatto v2, La Ruota della Fortuna v3 e Il Re di
Denari v3, e i cartigli erano vuoti. Quattro su centocinquantasei. Misura la fascia
dei due cartigli su TUTTE le definitive dei due mazzi, con un metodo che distingua
un incavo liscio da un testo inciso, e riporta i nomi esatti dei file che portano
testo. Quelli vanno rigenerati e la rigenerazione e' lavoro di Mauro, non tuo: li
elenchi e ti fermi su quelli.

PARTE 5. IL CORPUS

Fonte: Mauro, 10 ottobre 2026, sulla ripetizione, "il tuo suggerimento", e sul
metodo di Dora, "se possibile vorrei che applicassimo anche il suo metodo".

FI.17 Tre varianti per ogni scheletro. Oggi ogni carta ha un testo per verso e per
posizione, quindi la stessa carta nella stessa posizione rilegge sempre la stessa
riga. Il conto che lo misura: in sessanta giorni un Viandante fa sessanta stese e
pesca sessanta volte da centocinquantasei carte-verso per posizione, con circa undici
ripetizioni attese. Con tre varianti scelte a rotazione serve la QUARTA uscita della
stessa carta nello stesso verso e nella stessa posizione perche' un testo si ripeta,
e in sessanta giorni la probabilita' scende sotto un caso su mille.

FI.18 La rotazione si guida dalla memoria, non dal caso. La variante che si mostra
dipende da quante volte quella carta e' gia' uscita a quella persona in quella
posizione: la prima volta la prima, la seconda volta la seconda, la terza la terza,
poi si ricomincia. Deterministico, come ogni elemento oracolare di questa app.

FI.19 Il ritorno della carta si dice. Quando una carta torna nella stessa posizione,
la lettura lo nomina: "questa carta ti era gia' uscita, allora era capovolta". E' la
memoria che diventa visibile, e trasforma la ripetizione da difetto in pregio.

FI.20 I REGISTRI, il metodo di Dora. Parole sue, trascritte da Mauro: la carta del
Diavolo "da una parte potrebbero essere attaccamenti, dinamiche tossiche, ma la
carta del Diavolo e' anche, per esempio, i soldi", e il ruolo "dipende sempre dal
contesto della domanda". L'app ha gia' il dato che serve: TarotTopicGroup, con tre
gruppi, amore e sentimenti, lavoro e denaro, vita e cammino.

Quindi il corpus guadagna un dato nuovo: per ogni carta e per ogni verso, TRE
registri, uno per gruppo, una riga ciascuno, che dicono di che cosa parla quella
carta in quell'ambito. Sono 78 per 2 per 3, cioe' 468 righe. Il registro si sceglie
dal gruppo dell'argomento, che la persona ha scelto dalla tendina: resta
deterministico e non dipende dal modello.

FI.21 Lo scheletro non decide il peso. Questa e' la seconda parte del metodo di
Dora, parole sue: "quello che fa e' l'insieme delle carte anche". Lo scheletro della
posizione lato dice che cosa quella carta mette sulla strada, senza chiamarla
consiglio ne' ostacolo. Il peso nasce quando la lettura si compone, dall'insieme
delle carte e dalla domanda. Non si lega il ruolo al verso: la Torre dritta non e'
un consiglio, e legarlo al verso lo renderebbe falso ogni volta che la persona
spegne l'interruttore delle carte rovesciate.

FI.22 Il consultante e' la situazione reale. Terzo audio di Dora: "la prima e' sempre
il consultante, la situazione reale, cioe' la situazione attuale". Lo scheletro di
quella posizione guarda chi chiede e il punto in cui si trova, non il futuro.

FI.23 I numeri del corpus. Diciassette posizioni per centocinquantasei carte-verso
per tre varianti fanno 7.956 scheletri, dei quali 468 esistono gia' in una sola
variante. Piu' 468 registri. Da generare: 7.956 testi. Si genera con lo stesso tool
che esiste gia', tool/genera_carte_nella_posizione.py, esteso alle posizioni nuove,
alle varianti e ai registri, con gli stessi controlli di oggi: la marca del genere,
i limiti di lunghezza, nessuna promessa su salute, denaro, leggi o morte, nessuna
previsione data per certa, nessun doppione e nessuna coppia con somiglianza di
Jaccard sopra 0,6.

FI.24 Il corpus si tocca alla fonte. Il markdown in docs/corpus/ resta la fonte e il
Dart si rigenera, mai il contrario. La fonte si divide in file leggibili invece di
diventare un unico markdown da mezzo megabyte.

FI.25 La rilettura e' dell'Architetto, non tua. Genera, fai girare i controlli,
riporta quanti testi hanno richiesto piu' di una rigenerazione e quanti non passano
dopo tre tentativi. Non correggere a mano i testi che non passano: elencali.

---

ORDINE FI, PEZZO 3 DI 3

PARTE 6. LA STESA SI CONSERVA

Fonte: Mauro, 10 ottobre 2026, alla domanda sulle tre vie del determinismo, "il tuo
suggerimento", cioe' la via che conserva.

FI.26 Il difetto. Il seme della stesa nasce dal caso a ogni apertura della schermata,
quindi chi esce e rientra con la stessa domanda vede carte diverse e puo' rilanciare
finche' non esce il responso che gli piace. Il Master Briefing Tecnico prescrive il
contrario, testualmente "la stessa estrazione di carte (deterministica, dal motore
oracoli)", e RETENTION alla legge 6 vieta la ricompensa variabile sui responsi.

FI.27 La cura. Una stesa fatta su una domanda resta quella per la giornata: chi
riapre la stessa stesa con la stessa domanda ritrova le sue carte, e la schermata lo
dice con una riga in personaggio invece di far finta di niente. Si conserva accanto
alla memoria che gia' esiste, senza toccare il motore del mescolamento.

FI.28 Il gesto resta vivo. Taglio, mescolamento e scuotimento continuano a
funzionare DENTRO la stesa in corso, come oggi. Cio' che non cambia piu' e' la stesa
gia' compiuta su quella domanda.

PARTE 7. LA CARD DA CONDIVIDERE

Fonte: Mauro, 10 ottobre 2026, "la card deve essere generata per poterla
condividere".

FI.29 Ogni stesa produce una card nel formato unico delle card virali dell'app. Sopra
la domanda, sotto le carte vere nella loro geometria, col dorso e la cornice del
mazzo scelto, e il nome di ogni carta nella tradizione del suo mazzo. La card si rende
da sola, quindi l'anteprima si cattura isolata ed e' corretto farlo.

FI.30 Nella card non entra il responso per intero: entra la sintesi in una frase.
Il responso resta nell'app, che e' il posto dove si legge.

FI.31 La card vale per tutte e cinque le stese, con la figura che cambia con la
geometria. Per la Croce Celtica la figura e' la croce di Waite, non una fila.

PARTE 8. I PIANI

Fonte: Mauro, 10 ottobre 2026, "tabella ok", e per il Viandante "vorrei mantenere le
opzioni di base come sono adesso con stesa a 3 carte e 1 carta, chiave di lettura
Medora, mazzo rider-waite e profondita' breve".

FI.32 La matrice. Viandante, Iniziato, Adepto, Illuminato.

  Stese          1 e 3        piu' la 4      piu' la 7 e la 10    tutte
  Chiavi         Predittiva   piu' Rifles.   piu' Esot. e Arch.   tutte
  Mazzi          Rider-Waite  piu' Marsig.   piu' Thoth           tutti
  Profondita'    Breve        Lunga          Lunga                Lunga
  Carte al giorno  3            6              10                  15
  Ritorno carta  no           no             si'                  si'
  Rilettura      no           no             no                   si'
  Card           si'          si'            si'                  si'

La riga delle carte al giorno e quella della stesa a dieci dall'Adepto esistono gia'
nel PlanCatalog e NON si toccano. Le altre righe sono nuove.

FI.33 La stesa a una carta pesa una carta sul budget del giorno. Risposta di Mauro
del 10 ottobre, "si". Conseguenza da scrivere a video: il Viandante che usa la carta
sola resta con due carte, e la stesa a tre quel giorno non gli entra. La schermata
glielo dice PRIMA che scelga, non dopo.

FI.34 Nessun prezzo in Eos su questa funzione. Non e' stato deciso nessun prezzo, e
dove non c'e' decisione non si inventa un numero.

FI.35 Questa matrice supera i quattro briefing in un punto, e va scritto nel
rapporto: i briefing dicono che le chiavi di lettura restano accessibili a tutti
senza gating. Mauro ha deciso il contrario il 10 ottobre 2026, e la decisione del
fondatore vince sul briefing. L'inserimento nei briefing lo decide lui a parte.

PARTE 9. GUARDIE, PROVE E MISURE

FI.36 Guardia dei mazzi. Enumera tutte e settantotto le carte del catalogo per ognuno
dei tre mazzi e cade se un file dichiarato non esiste, se una carta non ha il suo
file in quel mazzo, oppure se due carte diverse puntano allo stesso file. Dichiara
il cardinale minimo: settantotto per mazzo, tre mazzi.

FI.37 Guardia della Forza e della Giustizia. Cade se nel Marsiglia o nel Thoth la
carta che il catalogo chiama La Forza punta a un file il cui nome contiene
"giustizia" o "aggiustamento", e viceversa. E' la prova del difetto che questa parte
chiude, quindi va vista rossa sul codice di prima.

FI.38 Guardia dei cartigli. Misura la fascia dei due cartigli su tutte le carte dei
tre mazzi e cade nominando il file se ne trova uno che porta testo inciso.

FI.39 Guardia del corpus. Enumera le diciassette posizioni per le centocinquantasei
carte-verso per le tre varianti e cade se manca anche un solo testo, se due testi
sono uguali, oppure se una terna comincia tre volte con la stessa parola. Cardinale
minimo dichiarato: 7.956.

FI.40 Guardia dei registri. Cade se una carta non ha i suoi tre registri, uno per
gruppo.

FI.41 Guardia della stesa conservata. Monta l'app dall'avvio vero, fa una stesa su
una domanda, esce dalla schermata, rientra con la stessa domanda e pretende le stesse
carte. Non montare il widget in isolamento: questo e' un difetto di collegamento, e
in isolamento passerebbe per la ragione sbagliata.

FI.42 Guardia della rotazione. Pretende che la stessa carta nella stessa posizione
mostri tre testi diversi alla prima, alla seconda e alla terza uscita, e che alla
quarta ricominci dalla prima.

FI.43 Prova di vista su ogni guardia nuova: si rimette il difetto, si verifica col
grep che sia entrato nel file, e solo dopo si legge l'esito.

FI.44 Misure da riportare nel rapporto, in numeri col metodo con cui sono state
prese: il peso dei due mazzi nuovi e la crescita dell'archivio; i token di ingresso e
di uscita di una stesa a tre carte e di una a dieci, perche' il costo cresce con le
carte e oggi quel numero non esiste; quanti testi del corpus hanno richiesto piu' di
una rigenerazione.

FI.45 Anteprime prima e dopo a 360 per 797 punti logici con rapporto di pixel 3, in
docs/preview/prima_dopo/, per la schermata dei selettori, per la croce di Dora, per
il ferro di cavallo, per la Croce Celtica e per la card. Se un'anteprima mostra un
ripiego, non ci si misura sopra niente e lo si dichiara.

PARTE 10. QUELLO CHE NON SI TOCCA

FI.46 La stesa a tre carte com'e' oggi, i suoi 468 testi, il suo tavolo, il ventaglio,
il taglio e lo scuotimento. Questa e' la stesa che Mauro ha gia' approvato a video.

FI.47 L'Arcano dell'Alba, che e' un'altra cosa dalla stesa a una carta: lui pesca da
solo, senza domanda, senza scelta di mazzo ne' di chiave, e vive nei doni del giorno.
La differenza si dichiara a video in una riga, cosi' chi le usa tutte e due sa perche'
esistono tutte e due.

FI.48 Il budget delle carte estratte e la sua matrice.

FI.49 Il Confine del Responso e il blocco di cortesia: ogni testo nuovo ci passa
attraverso come quelli di oggi.

FI.50 Il determinismo dell'elemento oracolare. Le carte discendono da persona, giorno
e domanda, mai dal caso del modello. Il modello varia la DIZIONE, mai la sostanza.

CONSEGNA
Rapporto in docs/ordini/RAPPORTO_ORDINE_FI.md, con per ogni voce chiusa: la misura in
numeri col suo metodo, le immagini prima e dopo, e la frase di accettazione che dice a
Mauro che cosa deve vedere sul telefono per considerarla chiusa. Aggiorna
docs/STATO_VIVO.md integrando le novita' nelle sezioni giuste, mai come addendum e
senza condensare il resto. La build NON si fa senza che la ordini Mauro: se serve,
girale la domanda.

---

FI AGGIUNTA, LA SCRITTURA DEI CORPUS
Esoteric Circle, 11 ottobre 2026. Ramo invariato.
Fonte: Mauro, 11 ottobre 2026, "i corpus li ha sempre creati l'architetto o sbaglio?"
e "voglio il risultato migliore".

PREMESSA DA ABBATTERE
PA1. In docs/corpus/ ci sono quattordici file di corpus. Tredici dichiarano in testa
     di essere materiale dell'Architetto, curatela o testi scritti a mano, e uno solo,
     tarocchi_nella_posizione.md, dichiara di essere stato generato da Gemini 2.5
     Flash il 27 settembre 2026.
     Se e' falsa, fermati e riportala.

COSA CAMBIA

A1. ANNULLA la parte di FI.23 e di FI.25 che ti assegna la generazione dei testi.
    **Tu non generi nessun testo del corpus con il modello.** La regola di casa e'
    quella dei tredici file su quattordici: i corpora li scrive l'Architetto. Il
    corpus del 27 settembre e' l'eccezione, ed e' anche quello che ha richiesto 45
    correzioni a mano su 468 testi, piu' i due difetti di metodo che hai trovato tu.

A2. Se hai GIA' generato dei testi eseguendo FI.23, non cancellarli: spostali in
    docs/corpus/scartati_FI/ e dichiara nel rapporto quanti sono e per quali
    posizioni. Non entrano nell'app e non entrano nella fonte.

A3. QUELLO CHE RESTA TUO, e vale per intero:
    - il tool tool/genera_carte_nella_posizione.py esteso alle diciassette posizioni,
      alle tre varianti e ai tre registri, che **legge la fonte e scrive il Dart**,
      senza chiamare nessun modello;
    - i controlli che oggi vivono nel tool: marca del genere, lunghezza, nessuna
      promessa su salute, denaro, leggi o morte, nessuna previsione data per certa,
      nessun doppione, nessuna coppia con somiglianza di Jaccard sopra 0,6, i tre
      testi di una terna che cominciano con parole diverse;
    - le guardie FI.39 e FI.40, col loro cardinale minimo e la loro prova di vista;
    - il montaggio della lettura, cioe' come scheletro e registro si compongono
      insieme e come arrivano al modello a runtime.

A4. I FILE DELLA FONTE, pronti e vuoti. Crea in docs/corpus/ un file per ciascuna
    delle diciassette posizioni, nella forma esatta che il tool sa leggere, con
    tutte le settantotto carte e i due versi gia' scritti come intestazioni e le
    righe dei testi assenti. Piu' un file per i registri, con le settantotto carte,
    i due versi e i tre gruppi. L'Architetto li riempie e te li consegna.

    Il tool deve FERMARSI con un errore parlante quando una riga manca, come gia' fa
    oggi: una fonte incompleta non produce un file dati a meta'.

A5. LE ONDATE. I testi arrivano una posizione per volta, 468 testi per ondata. A ogni
    ondata tu rilanci il tool, fai girare le guardie e accendi la stesa che quella
    posizione completa. Non aspetti le diciassette ondate per fare il resto.

A6. FINCHE' IL CORPUS NON C'E', LA STESA RESTA COL LUCCHETTO. Le stese nuove si
    costruiscono per intero, geometria compresa, e restano Coming soon finche' tutte
    le loro posizioni non hanno il corpus. La stesa a tre carte resta viva e intatta,
    perche' le sue tre posizioni esistono gia'.

A7. NON SI RIPIEGA SUL TESTO DEL VERSO. Oggi, quando il corpus non porta una carta,
    il codice mostra il significato del suo verso. Per le posizioni nuove quel
    ripiego non va bene, perche' darebbe lo stesso testo in posizioni diverse: finche'
    il corpus manca, la stesa non si apre affatto.

A8. Tutto il resto dell'ordine FI vale invariato: le stese, le posizioni, le chiavi,
    i mazzi, la stesa che si conserva, la card, i piani, le guardie e le misure.
    Prosegui da li'.

A9. Nel rapporto dichiara quante delle diciassette posizioni hanno la fonte pronta e
    quante aspettano i testi dell'Architetto, con i nomi.

---

LA SEGNALAZIONE DEL FONDATORE, 11 ottobre 2026

"Aggiungo una piccola correzione da fare: quando faccio "taglia" o "mischia" il mazzo esce dal riquadro dell'animazione mentre dovrebbe stare al centro."
