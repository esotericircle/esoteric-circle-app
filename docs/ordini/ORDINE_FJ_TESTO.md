# ORDINE FJ, IL LATO, I MAZZI, LA FONTE DEI SIGNIFICATI

Il testo dell'Architetto come e' arrivato l'11 ottobre 2026, in tre pezzi (il primo in due messaggi), con l'aggiunta della stessa sera. Trascritto senza toccarlo.

---

# ORDINE FJ, pezzo 1 di 3
# Architetto, 11 ottobre 2026. Ramo claude/esoteric-circle-master-order-e798aj, da 93c0a635.

L'ordine ha cinque parti in tre pezzi. Questo pezzo porta le Parti 1 e 2.
Si esegue in ordine: prima la Parte 1, che sblocca una funzione che aspettava da
giorni, poi la Parte 2.

Ogni voce dichiara la sua fonte. Le fonti di questo ordine sono tre: le frasi del
fondatore in chat l'11 ottobre 2026; il documento di progetto
`claude/Prova_Appaiata_Corpus_Tarocchi_2026-10-11.md`, citato col capitolo; il tuo
rapporto dell'ordine FI che il fondatore mi ha girato.


## PARTE 1, LA FONTE DELLA POSIZIONE LATO

### FJ.1 Il file

FONTE: documento `claude/Prova_Appaiata_Corpus_Tarocchi_2026-10-11.md`, capitolo 7.3.

Il fondatore ti consegna il file `lato.md`. Va in
`docs/corpus/tarocchi_posizione/lato.md`, al posto del file vuoto che c'e' adesso.

Contenuto: 78 carte, 156 carte-verso, 468 testi, le varianti 1, 2 e 3 tutte piene.
**E' la prima posizione delle diciassette con tutte e tre le varianti.**

Prima di sostituire, verifica che il file che ricevi abbia esattamente:
- 78 righe che iniziano con `## `;
- 156 righe `### dritta` oppure `### capovolta`;
- 468 righe `- 1: `, `- 2: `, `- 3: ` non vuote;
- zero righe `- 1:`, `- 2:`, `- 3:` vuote.
Se uno dei quattro numeri non torna, fermati e dillo: il file e' arrivato storto.

### FJ.2 I controlli sono gia' passati, e questo e' un fatto da verificare non da credere

FONTE: documento citato, capitolo 7.3.

Ho applicato al file, prima di consegnarlo, le funzioni `controlla_testo` e
`controlla` di `tool/genera_carte_nella_posizione.py` alla revisione 93c0a635,
ricopiate una per una: lunghezza 110-280, verso nominato, nome della propria carta
dentro il testo, cifre, trattino lungo, la parola voce, virgola seguita da e oppure
ed, marca del genere, le dodici promesse, le dodici previsioni certe, doppioni,
prime parole delle tre varianti diverse fra loro, Jaccard sopra 0,6.

Esito: quattro colpe trovate e corrette da me, poi zero.
Le quattro corrette, perche' devi poterle ritrovare:
- Il Mago capovolta variante 3: la parola voce, sostituita con parola;
- Re di Coppe capovolta variante 3: la parola voce, sostituita con apertamente;
- Tre di Denari capovolta variante 1: la parola voce, e la frase riscritta col tu
  singolare invece della seconda plurale;
- Il Giudizio capovolta variante 2: "una sentenza", che il tuo controllo prende come
  promessa legale, sostituita con "un rimprovero".

**Non prendere per buono questo elenco: rilancia il tool e guarda che non si fermi.**
Se si ferma, il difetto e' mio e lo dichiari con la riga esatta.

### FJ.3 Il rilancio e le guardie

FONTE: `docs/corpus/tarocchi_posizione/lato.md`, paragrafo "Come si tocca".

Poi la suite intera, non solo le guardie del corpus: la posizione LATO entra in
`lib/core/tarot/le_carte_nella_posizione_dati.dart` e quel file e' letto anche dalla
rotazione e dalla lettura di casa.

### FJ.4 Il paragrafo di provenienza va preservato

FONTE: `tool/genera_carte_nella_posizione.py`, funzioni `prepara` e `leggi_vecchio`.

Nella testa di `lato.md`, dopo il paragrafo "Come si tocca", c'e' un paragrafo che
dice da dove vengono i tre varianti e con quale misura sono state scelte, come
`passato.md` ha il suo per la variante 1.

Verifica che `prepara`, quando rigenera i file della fonte, **non lo cancelli**. Se
lo cancella, lo preserva come fa per quello di `passato.md`, e se quel meccanismo
non esiste lo aggiungi. Un paragrafo di provenienza perso significa che fra un mese
nessuno sa piu' da dove vengono 468 testi.

### FJ.5 La rotazione diventa visibile, e FI.18 si chiude

FONTE: tuo rapporto dell'ordine FI, voce FI.18: "A video non si puo' vedere finche'
una posizione ha una variante sola: si guarda alla prima ondata dell'Architetto."

Questa e' la prima ondata. Con tre varianti sul LATO, `LeUsciteDelleCarte` si puo'
guardare a video: la stessa carta nello stesso verso nella posizione LATO mostra la
variante 1 alla prima uscita, la 2 alla seconda, la 3 alla terza, poi ricomincia.

Fai la prova di vista con tre uscite della stessa carta e verso, e con una stesa
riaperta nello stesso giorno, che non deve contare. Poi chiudi FI.18 con la prova.

### FJ.6 FI.17 si aggiorna, non si chiude

FONTE: tuo rapporto, voce FI.17.

FI.17 oggi dice: "tre posizioni della stesa a tre carte hanno la variante 1, le
varianti 2 e 3 e le altre quattordici posizioni aspettano".

Diventa: una posizione su diciassette ha tutte e tre le varianti, il LATO; tre hanno
la variante 1; tredici aspettano. La voce resta APERTA.

### FJ.7 La croce di Dora resta chiusa, e va detto nel manifesto

FONTE: `lib/core/tarot`, commento su `SpreadPosition`: "La croce di Dora: il
consultante in basso, i due lati, l'esito in alto."

La croce di Dora usa tre posizioni distinte: `consultante`, `lato` due volte e
`esito`. Con il solo LATO completo **non si apre**, e non va aperta.

Scrivi nel manifesto, nella voce che governa l'apertura delle stese nuove, quali
posizioni mancano a ciascuna stesa e quante ne ha ciascuna. Serve a me per decidere
l'ordine delle ondate: le prossime due saranno `consultante` ed `esito`, perche'
sono quelle che aprono la prima stesa nuova.

### FJ.8 Che cosa non cambia

FONTE: tuo rapporto dell'ordine FI.

La stesa a tre carte resta aperta e intatta. Le altre stese nuove restano chiuse e
non mostrano il testo del verso al posto di quello della posizione. Nessuna delle
tredici posizioni ancora vuote va riempita da un modello.


## PARTE 2, FI.13: I MAZZI

### FJ.9 La decisione

FONTE: frase del fondatore in chat l'11 ottobre 2026: "Fi.13 lo decide code o tu".
La decisione e' dell'Architetto e la motivo, perche' una decisione non motivata
nessuno la puo' rivedere.

**Il mazzo predefinito dentro l'app. Gli altri mazzi sul bucket dietro CDN, con
cache permanente sul dispositivo.**

Le due ragioni, e sono entrambe vincolanti:
1. I tarocchi sono la funzione centrale dell'app e devono funzionare senza rete, al
   primo avvio, nel metro e in aereo. Quindi **un** mazzo deve stare nel binario.
2. I mazzi sono un catalogo che crescera', e un catalogo che cresce nel binario fa
   pagare ogni aggiunta a tutti: una release dello store per ogni mazzo nuovo, e un
   download piu' grosso anche per chi usa un mazzo solo. Sul bucket un mazzo nuovo
   si pubblica senza toccare l'app, e si puo' legare a un piano.

### FJ.10 La misura che manca, e si fa prima di eseguire

FONTE: tuo rapporto, voce FI.13: "54.871.350 byte, 54,9 MB in base 1000, 52,3 MiB
in base 1024, archivio da 260.267.304 byte a circa 315 MB".

Quella misura e' dei due mazzi insieme. Prima di eseguire misura e scrivi:
- il peso di **ciascuno** dei due mazzi separatamente, e il peso medio per carta;
- il peso del mazzo predefinito dopo la conversione in WebP a qualita' alta, alle
  dimensioni che servono davvero allo schermo piu' grande su cui l'app gira, non
  alla risoluzione delle definitive;
- il peso del bundle oggi, e quanto diventa col mazzo predefinito dentro.

Se il mazzo predefinito convertito supera i 40 MB, fermati e dimmelo prima di
proseguire: a quel punto la decisione va rifatta e la rifaccio io col numero.

### FJ.11 Il mazzo predefinito

FONTE: decisione FJ.9.

Il predefinito e' il mazzo su cui e' costruito tutto il corpus dei tarocchi, cioe'
quello a cui si riferiscono `carte.json`, le figure e i 468 testi del LATO. Va negli
asset dell'app, in WebP, alle dimensioni di cui sopra.

### FJ.12 I mazzi sul bucket

FONTE: decisione FJ.9.

- Cloud Storage dietro Cloud CDN, nel progetto Google dell'app.
- Un **manifest JSON sul bucket** con l'elenco dei mazzi, per ciascuno la versione,
  l'elenco dei file, la dimensione e un hash per file. L'app legge il manifest, non
  indovina i percorsi: cosi' un mazzo nuovo non richiede una release.
- Il download parte **solo** quando la persona scegle quel mazzo. Mai all'avvio, mai
  in automatico, mai tutti i mazzi insieme.
- Download in blocco con avanzamento visibile e possibilita' di annullare, poi
  **cache permanente** sul dispositivo: scaricato una volta, funziona offline per
  sempre, e la cache non si svuota da sola.
- Verifica dell'hash di ogni file dopo il download. Un file che non torna si
  riscarica una volta, poi il mazzo resta non installato e l'app lo dice.
- Se il download non riesce, l'app **resta sul mazzo predefinito** e lo dice in una
  riga, senza schermate di errore e senza perdere la stesa in corso.
- Nessuna credenziale nel codice dell'app: il bucket e' in lettura pubblica per i
  file dei mazzi, oppure dietro URL firmati generati da Cloud Run. Scegli tu e
  dichiara quale, con la ragione.

### FJ.13 Che cosa sbloccare per quale piano

FONTE: documento di progetto `claude/` sui piani e i limiti, piu' la decisione FJ.9.

Il predefinito e' di tutti e non si blocca mai: e' la funzione centrale.
Il secondo mazzo e i futuri sono il candidato naturale a stare dietro un piano.
**Non implementare nessun blocco adesso**: predisponi il campo nel manifest, lascia
tutti i mazzi aperti, e gira a me la domanda su quale piano e quale prezzo in Eos,
che la porto al fondatore con le domande delle funzionalita'.

# fine del pezzo 1 di 3

---

# ORDINE FJ, pezzo 2 di 3
# Parte 3, le correzioni alla fonte dei significati

FONTE DI TUTTA LA PARTE 3: documento di progetto
`claude/Prova_Appaiata_Corpus_Tarocchi_2026-10-11.md`, capitolo 10, piu' i quattro
rapporti degli scrittori dell'11 ottobre 2026.

## FJ.14 Perche' questa parte esiste, e non e' una pulizia di stile

Ventotto carte-verso su centocinquantasei della posizione LATO sbagliavano in
entrambe le stesure candidate: un lettore esperto che leggeva il testo senza il nome
non arrivava alla carta. Sono state riscritte da zero partendo dal tratto che la
fonte da' alla carta e non alla carta con cui i lettori la scambiavano, e sono
passate dal 22,0 al 51,2 per cento.

**Cinque sono rimaste a zero su tre anche dopo la riscrittura**: Re di Coppe
capovolta, Cavaliere di Denari capovolta, Fante di Denari capovolta, Gli Amanti
capovolta, Tre di Bastoni capovolta. Tutti e quattro gli scrittori avevano
dichiarato, **prima** della misura, che per quelle carte la fonte non da' nessun
tratto che le separi dalla gemella, e la misura li ha confermati.

La sesta, Dieci di Coppe capovolta, e' salita da zero a due su tre **solo perche' lo
scrittore ha scartato metà della sua fonte**, la clausola "o nella coppia", che e' la
stessa materia del Due di Coppe capovolta.

Quindi: nessun testo puo' aggirare il difetto, perche' il difetto e' nel significato.
Si corregge `carte.json`.

## FJ.15 La regola fissa di questa parte, e vale per ogni singola modifica

Ogni modifica si verifica **contro la carta gemella**, e non si corregge una voce
creando una collisione nuova con una terza carta. Prima di scrivere una voce nuova:
leggi la voce della carta, quella della gemella nominata qui e quelle delle altre
carte dello stesso seme nei ranghi vicini; dopo averla scritta, rileggi le tre e
chiediti se un lettore le distingue.

Dove togli una frase, **non la sostituisci con una parafrasi**: la togli e lasci che
la voce sia piu' corta. Una voce piu' corta e distinta vale piu' di una lunga e
indistinguibile.

Ogni modifica va scritta nel rapporto con: la carta, il verso, la frase prima, la
frase dopo, la gemella contro cui l'hai verificata.

## FJ.16 Le tredici collisioni che rendono due carte indistinguibili

1. **Re di Coppe capovolta** collide con Regina di Coppe e con Asso di Coppe
   capovolta: condividono l'immagine dell'onda e dell'acqua trattenuta. Il tratto
   proprio del Re, il **governo** delle emozioni, esiste nella voce ma non e' il suo
   asse. Va portato al centro, e l'onda va togliata o lasciata a una sola delle tre.
2. **Cavaliere di Denari capovolta** collide con Quattro di Denari capovolta:
   l'immobilita' da prudenza. In piu' "Muovi qualcosa, anche di piccolo" e' la stessa
   frase del Fante di Denari capovolta, e "paura di sbagliare" e' identica all'Asso
   di Bastoni capovolta. Il tratto proprio del Cavaliere e' che lo stallo e' **sul
   cammino**, cioe' c'e' una strada e una meta verso cui non si avanza: nel Quattro
   c'e' una mano chiusa su quello che si possiede, e non c'e' nessuna strada.
3. **Fante di Denari capovolta** collide con Otto di Denari capovolta e con Cavaliere
   di Denari capovolta: il gesto piccolo che rimette in moto quello che era fermo. Il
   gesto minimo resti a una carta sola.
4. **Tre di Bastoni capovolta** collide con Otto di Bastoni capovolta: la parola
   ritardo apre entrambe le voci. Il tratto proprio del Tre, l'attesa che rientra in
   una **forma diversa** da quella prevista, e' una mezza riga e va diventare l'asse.
5. **Gli Amanti capovolta** collide con Due di Denari, Due di Spade e Due di Coppe:
   la divisione fra due termini pari. Manca che i due termini sono **valori propri di
   chi legge**, non due opzioni esterne.
6. **Dieci di Coppe capovolta** collide con Due di Coppe capovolta: la clausola "o
   nella coppia" piu' la cura per via di parola. **La coppia appartiene al Due, il
   Dieci e' il gruppo sotto lo stesso tetto**: la clausola va togliata dal Dieci.
7. **Regina di Denari capovolta** collide con Sei di Denari: la frase "Rimetti
   equilibrio tra dare e ricevere" e' parola per parola l'asse del Sei. Va togliata
   dalla Regina, il cui tratto e' la cura materiale di tutto quello che le sta intorno
   con se stessa fuori dall'elenco.
8. **Dieci di Spade capovolta** collide con Cinque di Denari capovolta e con Nove di
   Spade capovolta: "una ripresa", "il peggio alle spalle", "l'alba torna" stanno
   identiche in tutte e tre. Il tratto proprio del Dieci e' la risalita **da terra
   dopo una chiusura completa**, che riparte da zero.
9. **Fante di Bastoni capovolta** collide con Cavaliere di Bastoni capovolta:
   "slancio" piu' "incanalare l'energia che si disperde" in entrambe. Una delle due
   rinuncia a quel lessico. L'asse che le separa, dedotto dalle voci ma non scritto:
   nel Cavaliere la dispersione e' **nello spazio**, mille direzioni senza rotta; nel
   Fante e' **nel tempo**, si accende e si spegne prima dei frutti.
10. **Nove di Bastoni capovolta** collide con Sette di Bastoni capovolta: la
    stanchezza difensiva. Il solo tratto proprio del Nove e' la mezza riga "ti difendi
    anche da chi vorrebbe solo avvicinarsi", cioe' **l'altro non e' un avversario**:
    va rafforzata, perche' se cade il gruppo diventa indistinguibile.
11. **La Giustizia capovolta** collide con Sette di Spade capovolta: "verita' che
    eviti" e "onesta' con te stesso". La materia propria della Giustizia, la
    **conseguenza non riconosciuta** e il conto aperto a proprio nome, e' tutta nel
    verso dritto. Il capovolto deve nominarla.
12. **Dieci di Denari capovolta** collide con Quattro di Bastoni capovolta: radici,
    fondamenta e armonia stanno in entrambe. Il tratto proprio del Dieci sono **beni
    e famiglia e patrimonio**: la contesa corre dentro la famiglia su cose che
    appartengono a piu' di una persona. Il Quattro di Bastoni capovolta va riscritto
    senza fondamenta e senza radici.
13. **Fante di Coppe capovolta** collide con Regina di Coppe capovolta: la stessa
    formula di chiusura, "sentire molto e' un dono" contro "la tua sensibilita' e' una
    forza". Due carte dello stesso seme chiudono con la stessa tesi, ed e' la ragione
    per cui quattro lettori su sei sono andati alla Regina.

## FJ.17 Le sei frasi che giudicano o comandano dentro la fonte

FONTE: documento citato, capitolo 10.2.

La regola della posizione vieta al testo di decidere se la forza aiuti o intralci.
Dove la fonte decide al posto del testo, lo scrittore deve scartare quella parte, e
quello che resta e' meno di quello che la carta ha. Si riscrivono come
**constatazione**, non come consiglio.

1. Cinque di Spade capovolta: "Fare il primo passo verso la pace non e' perdere, e'
   scegliere meglio". Rassicurazione piu' comparativo di valore.
2. Due di Denari capovolta: "minacciano di farti cadere tutto". Scritta in forma di
   allarme.
3. Fante di Spade dritta: "La curiosita' e' preziosa". Aggettivo di giudizio.
4. Dieci di Denari capovolta: "La ricchezza vera e' anche l'armonia". Giudizio, piu'
   l'opposizione vero contro falso.
5. La Giustizia capovolta: "Guardala in faccia con calma". E' un ordine.
6. Quattro di Denari dritta: "La stabilita' e' buona, l'attaccamento un po' meno".

## FJ.18 I cinque confini porosi fra i due versi della stessa carta

FONTE: documento citato, capitolo 10.3.

1. **Dieci di Denari**: il capovolto prescrive "Cura cio' che dura davvero, oltre il
   guadagno di oggi", che e' la materia del dritto.
2. **Quattro di Coppe**: il dritto dice "Alza lo sguardo, qualcosa di buono ti
   aspetta" e il capovolto "Esci dal torpore e torni a sentire": la stessa uscita
   dall'apatia. Il dritto e' stato svuotato della sua materia propria, che e' la
   **sazieta' e il rifiuto dell'offerta che sta accanto**.
3. **Dieci di Spade**: l'alba e' spesa due volte, nel dritto e nel capovolto, e
   condivisa con entrambi i versi del Nove di Spade.
4. **Nove di Bastoni**: lo scudo compare nei due versi con significato invertito,
   "poi potrai posare lo scudo" nel dritto e "abbassa un poco lo scudo" nel capovolto.
5. **Nove di Denari**: il tratto che separa il capovolto dal Quattro di Denari
   capovolta, cioe' **l'autonomia gia' conquistata con le proprie mani**, sta nella
   voce del dritto e non in quella del capovolto, dove serve.

## FJ.19 La contraddizione fra due massime di carte che escono nella stessa stesa

FONTE: documento citato, capitolo 10.4.

Tre di Bastoni capovolta afferma "un ritardo non e' un no, spesso e' solo un tempo
diverso". Sette di Denari capovolta afferma "a volte il raccolto tarda perche' il
seme era quello sbagliato, non il tempo". Sono la tesi e l'antitesi sulla stessa
domanda, e le due carte possono uscire nella stessa stesa. Una delle due massime
cade: scegli quale e dichiara la ragione.

## FJ.20 I due punti che la fonte lascia vuoti

FONTE: documento citato, capitolo 10.5.

1. **Nove di Denari capovolta**: "eccessi" senza dire di che cosa. Spese, consumo,
   concessioni: va specificato, perche' altrimenti ogni scrittore scegliera' da se'.
2. **Fante di Denari dritta**: il tratto forte della carta e' imprigionato nella
   formula "un passo studiato dopo l'altro", che un testo non puo' citare perche'
   ricopierebbe la fonte. Va riformulata in modo che il tratto resti e la formula no.

## FJ.21 Le nove collisioni gia' in coda

FONTE: `fonti_delle_stese.md`, le collisioni che la fonte dell'app non distingue,
fra cui Regina di Bastoni dritta contro Sole dritto.

Erano in coda da prima di questo ordine e si lavorano con lo stesso metodo e la
stessa regola fissa FJ.15.

## FJ.22 Che cosa non si fa in questa parte

Non si toccano le voci delle carte che non sono nominate qui. Centoventotto
carte-verso su centocinquantasei funzionano, e una modifica alla loro fonte
rischierebbe testi che oggi portano alla loro carta.

Non si riscrivono i 468 testi del LATO per adeguarli alla fonte corretta. Si
corregge la fonte, si scrive nel rapporto quali gruppi la correzione rende
riscrivibili, e la riscrittura la ordino io dopo averla misurata.

# fine del pezzo 2 di 3

---

# ORDINE FJ, pezzo 3 di 3
# Parti 4 e 5, piu' il rapporto

## PARTE 4, IL CONTESTO CHE ARRIVA AL MODELLO

### FJ.23 La decisione

FONTE: tuo rapporto dell'ordine FI, paragrafo "Da decidere: cosa arriva al modello",
piu' la frase del fondatore "Sei autorizzato" dell'11 ottobre 2026.

**Il testo della posizione resta fuori dalla richiesta al modello.** Al modello va il
registro dell'argomento, come fai adesso. Nella lettura senza modello il testo della
posizione resta dov'e', subito prima del registro.

La ragione, ed e' la stessa che ho misurato oggi su un altro piano: nelle prove
dell'ordine EQ il modello ricopiava il testo della posizione con altre parole invece
di leggere la carta sulla domanda. Dargli un testo pronto gli offre una risposta da
parafrasare, e lui la prende. E' lo stesso difetto per cui un testo che vale per
venti carte non e' il testo di quella carta: la fluidita' copre l'assenza di
sostanza, e nessun controllo di forma la vede.

### FJ.24 La condizione per rimisurarla

FONTE: documento citato, capitoli 1 e 2.

La decisione si rivede solo con una misura, e la misura non e' un giudizio a vista su
qualche risposta. Si fa col disegno appaiato: le due condizioni, col testo della
posizione e senza, **nello stesso giro**, sulla stessa lista di domande, giudicate da
lettori che non sanno quale risposta viene da quale condizione, bilanciate in modo
che ogni lettore ne veda lo stesso numero delle due.

La ragione per cui serve quel disegno e non una prova piu' semplice: la prova a giri
separati, una condizione per giro con giudici nuovi ogni volta, ha un errore di nove
punti. E' stato misurato l'11 ottobre su quattrocentoventiquattro testi identici
parola per parola, dove cinquantatre giudizi sono passati da giusto a sbagliato e
tredici nel verso opposto a corpus fermo. Un confronto fra due giri separati non
distingue niente di piu' piccolo di dieci punti.

### FJ.25 Dove si scrive

La decisione FJ.23 va dove sta la regola di che cosa entra nella richiesta al
modello, con la ragione in una riga e il rimando a FJ.24 per la condizione di
revisione. Non in un addendum: nella sezione che governa quella regola.


## PARTE 5, CHE COSA NON SI FA

### FJ.26 Non si usa `controlla3.py` per approvare un testo

FONTE: documento citato, capitolo 6.

`controlla3.py` e' il mio metro, non il tuo tool, e non sta nel ramo. Lo dico perche'
se ti arriva non devi usarlo come criterio: l'11 ottobre ho misurato che **nessuna**
delle sue trenta regole di forma migliora la riconoscibilita' della carta, e sette la
peggiorano. I testi che le violavano dicevano la carta meglio degli altri, perche'
quelle forme portavano concretezza.

Il corpus del LATO che ti consegno ha quattrocentosedici difetti al mio metro ed e' il
piu' riconoscibile che esista. **Non si corregge.** Il tuo tool ha le sue regole, che
sono poche e diverse, e quelle si rispettano: sono gia' rispettate.

### FJ.27 Non si riscrive un gruppo che la fonte non distingue dalla gemella

FONTE: documento citato, capitolo 5.5.

Lo scrittore produrra' un testo onesto che nessun lettore riconoscera', come
dimostrano le cinque carte rimaste a zero su tre dopo essere state riscritte da zero.
Prima si corregge la fonte, poi si riscrive.

### FJ.28 Non si riempie nessuna posizione con un modello

FONTE: `docs/corpus/tarocchi_posizione/passato.md`, paragrafo sulla variante 1: "E'
l'unica parte del corpus dei tarocchi scritta da un modello; le varianti 2 e 3 le
scrive l'Architetto."

Le tredici posizioni ancora vuote e le varianti 2 e 3 di passato, presente e futuro
aspettano me. Nessuna di esse va generata.

### FJ.29 Non si ordina la build

FONTE: regola del fondatore.

La build la ordina lui. Se serve, la domanda si gira a me e io la porto a lui.


## IL RAPPORTO

1. I quattro numeri di FJ.1 sul file ricevuto, e se il tool si e' fermato.
2. Il comando esatto di FJ.3 e l'esito della suite intera, col totale e i rossi.
3. La prova di vista della rotazione di FJ.5: tre uscite della stessa carta e verso,
   piu' una stesa riaperta nello stesso giorno che non conta. FI.18 chiusa o aperta,
   con la ragione.
4. FI.17 aggiornata, e le posizioni mancanti a ciascuna stesa come chiede FJ.7.
5. Se `prepara` conservava il paragrafo di provenienza oppure lo cancellava, e che
   cosa hai fatto.
6. Le tre misure di FJ.10, e se il mazzo predefinito convertito supera i 40 MB.
7. Per il bucket: lettura pubblica oppure URL firmati, con la ragione della scelta.
8. Per ogni modifica alla fonte dei significati: carta, verso, la frase prima, la
   frase dopo, la gemella contro cui l'hai verificata. Le voci che hai deciso di non
   toccare, con la ragione.
9. Per FJ.19: quale delle due massime cade, e perche'.
10. Quali gruppi del corpus la correzione della fonte rende riscrivibili, che e' la
    lista da cui parte la mia prossima ondata.
11. I difetti che hai inserito apposta nelle guardie nuove e se sono caduti tutti al
    primo giro.
12. Le guardie delle zone che hai toccato che hai visto rosse **dopo** averci
    lavorato e non prima, come hai fatto per FI.
13. Qualunque voce di questo ordine che poggia su un fatto sbagliato. L'ultima volta
    due scrittori hanno verificato una mia premessa sulla fonte e l'hanno rifiutata, e
    avevano ragione: fallo anche tu.

# fine dell'ordine FJ

---

# ORDINE FJ, AGGIUNTA
# Architetto, 11 ottobre 2026. Ramo claude/esoteric-circle-master-order-e798aj.
# Si legge insieme all'ordine FJ, che resta valido in tutto tranne dove questa
# aggiunta lo corregge. Dove le due si contraddicono, vince questa.

Le fonti di questa aggiunta sono quattro: le frasi del fondatore in chat l'11
ottobre 2026; il tuo rapporto dell'ordine FI e il tuo messaggio sui tre blocchi;
i file del ramo a 93c0a635, verificati oggi uno per uno; i rapporti dei quattro
scrittori dell'11 ottobre 2026.


## FJ.A1 I tre errori dell'ordine FJ, e il meccanismo di ciascuno

Li dichiaro prima delle correzioni, perche' servono a non fidarti delle fonti che
cito senza verificarle. Tu ne hai trovati tre e avevi ragione su tutti e tre.

1. Ho citato `claude/Prova_Appaiata_Corpus_Tarocchi_2026-10-11.md` come fonte di
   quasi tutte le voci. **Quel documento vive nella knowledge base del progetto e
   non nel ramo.** Meccanismo: ho dato per scontato che tu vedessi la mia stessa
   memoria.
2. Ho chiamato la fonte dei significati `carte.json`. **Quel file non esiste nel
   ramo.** Meccanismo: e' il nome della copia estratta che ho nel mio ambiente di
   lavoro, e ho citato la copia invece dell'originale.
3. Ho citato `fonti_delle_stese.md` come fonte di nove collisioni fra carte. Quel
   file esiste nel mio ambiente, ma e' un documento sulle **fonti storiche delle
   stese** e non contiene nessuna lista di collisioni. Meccanismo: ho fuso due cose
   diverse in una voce, e non ho aperto il file prima di citarlo.

Il quarto errore non era nell'ordine ma nel modo: ti ho fatto passare `lato.md` dal
fondatore quando potevo spingerlo io. L'ho spinto, ed e' la voce qui sotto.


## FJ.A2 FJ.1 e' GIA' ESEGUITA: il file e' sul ramo

FONTE: commit `65fceaa` sul ramo, verificato con `ls-remote` e poi riclonando.

`docs/corpus/tarocchi_posizione/lato.md` **e' gia' riempito sul ramo**. Non aspettare
nessun file e non generare niente.

- commit `65fceaa`, padre `93c0a635`;
- un solo file toccato, 479 righe aggiunte e 468 togliate;
- verificato sul remoto riclonando da zero: 78 righe `## `, 156 righe
  `### dritta` oppure `### capovolta`, **468 righe `- 1: `, `- 2: `, `- 3: ` piene,
  zero righe vuote**;
- il messaggio del commit porta le quattro colpe che ho corretto prima di spingere e
  la prova da eseguire.

Quello che resta a te, in quest'ordine:

1. `git pull` sul ramo. Se hai lavoro non spinto, il mio commit tocca **solo** quel
   file e non entra in conflitto con il codice.
2. `python tool/genera_carte_nella_posizione.py`. **Non deve fermarsi.** Se si ferma,
   il difetto e' mio: fermati e dichiara la riga esatta che il tool nomina.
3. La suite intera, non solo le guardie del corpus: la posizione entra in
   `lib/core/tarot/le_carte_nella_posizione_dati.dart`, che e' letto anche dalla
   rotazione e dalla lettura di casa.
4. Il resto della Parte 1 dell'ordine FJ come scritto: il paragrafo di provenienza da
   preservare in `prepara` (FJ.4), la prova di vista della rotazione e FI.18 da
   chiudere (FJ.5), FI.17 da aggiornare e non chiudere (FJ.6), le posizioni mancanti
   di ogni stesa da scrivere nel manifesto e la croce di Dora che resta chiusa (FJ.7).

I quattro testi che ho corretto io prima di spingere, perche' devi poterli ritrovare:

- Il Mago capovolta variante 3: la parola voce, sostituita con parola;
- Re di Coppe capovolta variante 3: la parola voce, sostituita con apertamente;
- Tre di Denari capovolta variante 1: la parola voce, e la frase riportata al tu
  singolare invece della seconda plurale;
- Il Giudizio capovolta variante 2: "una sentenza", che il tuo controllo prende come
  promessa legale, sostituita con "un rimprovero".

**Non prenderli per buoni dal mio elenco: li ritrovi rilanciando il tool.**


## FJ.A3 La fonte dei significati: il Dart, non un JSON

FONTE: `lib/core/tarot/tarot_card.dart` sul ramo, verificato oggi.

Le correzioni della Parte 3 si fanno in **`lib/core/tarot/tarot_card.dart`**, che
porta le 78 carte con quattro campi di significato ciascuna:

- `uprightSummary`, la sintesi del verso dritto;
- `upright`, il testo pieno del verso dritto;
- `reversedSummary`, la sintesi del capovolto;
- `reversed`, il testo pieno del capovolto.

Dove l'ordine FJ dice `carte.json`, si legge questo file e questi quattro campi.

Tre conseguenze che un file di dati non avrebbe avuto, e che vanno gestite:

1. **E' codice.** Ogni modifica passa per la suite intera, non per le sole guardie
   del corpus: quelle stringhe sono lette dalla lettura di casa, dalla richiesta al
   modello e dalle schermate.
2. **Le stringhe passano per `LaMarcaDelGenere.risolvi`.** Dove una voce contiene la
   marca del genere, va riscritta conservandola intera nella forma
   `[maschile|femminile|neutra]`, e la guardia `il_genere_non_si_indovina` va
   rifatta girare.
3. **Il tool del corpus legge questo stesso file come mazzo**
   (`MAZZO = lib/core/tarot/tarot_card.dart`): se una modifica cambia il **nome** di
   una carta, i 468 testi del LATO non si agganciano piu'. **I nomi non si toccano**,
   solo le quattro voci di significato.


## FJ.A4 La Parte 3 NON e' bloccata

FONTE: le voci da FJ.16 a FJ.20 dell'ordine FJ.

Il documento che ho citato e che non esiste nel ramo **non ti serve per eseguirla**.
Il contenuto delle ventisei correzioni e' scritto per esteso dentro l'ordine:

- FJ.16, le tredici collisioni, ciascuna con la carta, la gemella e che cosa
  condividono nella fonte;
- FJ.17, le sei frasi che giudicano o comandano, ciascuna con la carta, il verso e la
  frase esatta;
- FJ.18, i cinque confini porosi fra i due versi della stessa carta;
- FJ.19, la contraddizione fra le due massime di Tre di Bastoni capovolta e Sette di
  Denari capovolta;
- FJ.20, i due punti che la fonte lascia vuoti.

Ogni citazione del documento in quelle voci va letta come **riferimento**, non come
prerequisito. Se una voce ti sembra incompleta senza il documento, fermati su quella
voce e nominala: ti scrivo il pezzo che manca. **Non eseguirla a intuito**, perche'
una collisione riparata a intuito ne crea un'altra.

Resta valida la regola fissa FJ.15: ogni modifica si verifica contro la carta
gemella, non si crea una collisione nuova con una terza carta, e dove togli una frase
non la sostituisci con una parafrasi ma lasci la voce piu' corta.


## FJ.A5 FJ.21 e' ritirata

FONTE: FJ.A1 punto 3.

La voce FJ.21 dell'ordine FJ, "le nove collisioni gia' in coda", **si cancella**: non
ha una fonte che esista.

**Non cercare quelle nove collisioni e non ricostruirle.** Se esistono, le ritrovo io
con la misura e te le mando come voce nuova, nella forma di FJ.16, con la carta, la
gemella e che cosa condividono.

Le ventisei correzioni delle voci da FJ.16 a FJ.20 restano tutte valide: quelle
vengono dai rapporti dei quattro scrittori e dalla misura, e la misura le ha
confermate per cinque carte su cinque.


## FJ.A6 La voce che vale piu' delle ventisei correzioni: una guardia sulla fonte

FONTE: decisione dell'Architetto, motivata dalla misura di FJ.14.

Le ventisei correzioni riparano le collisioni che conosciamo. **Niente impedisce che
la prossima modifica a una voce ne crei una nuova**, ed e' esattamente cosi' che sono
nate quelle che stiamo correggendo: nessuno misurava se due carte dicessero la stessa
cosa.

Da fare nello stesso ordine, prima o dopo le correzioni:

1. Dimmi se esiste gia' una guardia che misuri la somiglianza fra le voci di due
   carte diverse in `tarot_card.dart`. **Cerca, non rispondere a memoria.**
2. Se non esiste, scrivila, sul modello dei controlli che il tool del corpus fa gia'
   sui testi:
   - per ogni coppia delle 156 carte-verso, la somiglianza di Jaccard fra i due testi
     pieni, e separatamente fra le due sintesi;
   - cade sopra una soglia, e la soglia la scegli **misurando prima lo stato
     attuale**: deve cadere sulle tredici collisioni di FJ.16 e non su tutto il resto,
     altrimenti non e' una guardia, e' un allarme sempre acceso;
   - cade anche quando due carte condividono una **frase intera**, cioe' una sequenza
     di parole sopra una lunghezza che scegli tu: e' il caso di "Rimetti equilibrio
     tra dare e ricevere", che sta identica in Regina di Denari capovolta e nell'asse
     di Sei di Denari;
   - cade anche quando il verso dritto e il capovolto della **stessa** carta si
     somigliano sopra la soglia: e' il caso dei cinque confini porosi di FJ.18.
3. Scrivi nel rapporto la misura prima e dopo: quante coppie cadono sopra la soglia
   prima delle correzioni e quante dopo. **E' il numero che dice se la Parte 3 ha
   funzionato**, e senza di esso le ventisei correzioni sono atti di fede.
4. Inserisci nella guardia almeno tre difetti apposta e dichiara se sono caduti tutti
   al primo giro, come fai di regola.


## FJ.A7 L'ordine di esecuzione, con una correzione al tuo

FONTE: tuo messaggio sui tre blocchi, piu' decisione dell'Architetto.

Approvo il tuo ordine con una correzione, e la motivo: **viene prima quello che
sblocca il lavoro di altri, poi quello che e' soltanto lungo.**

1. **Parte 1**, adesso, perche' il file c'e'. Sblocca FI.18, che aspetta da giorni, e
   mi dice con FJ.7 quali posizioni scrivere per prime.
2. **FJ.10**, le tre misure dei mazzi e il limite dei 40 MB. Se il mazzo predefinito
   convertito lo supera, fermati: la decisione la rifo' io col numero.
3. **FJ.23**, il contesto al modello. E' una riga di decisione da iscrivere dove sta
   la regola, con la ragione e il rimando a FJ.24 per la condizione di revisione.
4. **Parte 3 piu' FJ.A6**, le correzioni alla fonte e la guardia. **Prima della
   Parte 2**, e questa e' la correzione al tuo ordine: le correzioni alla fonte
   sbloccano la mia prossima ondata di testi, il download dei mazzi non sblocca
   nessun altro.
5. **Parte 2**, il download dei mazzi dal bucket, per ultima, come proponi tu.

Se la Parte 3 si rivela piu' lunga delle diverse ore che prevedi per la Parte 2,
fermati a meta' e dimmelo: la spezziamo per carte, non si spezza l'ordine.


## FJ.A8 Che cosa si aggiunge al rapporto

Oltre alle tredici voci del rapporto dell'ordine FJ:

14. Se il tool si e' fermato sul file che ho spinto, con la riga esatta che nomina.
15. Se il mio commit `65fceaa` ha creato conflitti col tuo lavoro non spinto, e
    quali.
16. Per FJ.A6: se la guardia esisteva, e la misura prima e dopo con la soglia che hai
    scelto e la ragione.
17. Quali voci di questa aggiunta poggiano ancora su un fatto sbagliato. Hai trovato
    tre miei errori in un colpo e avevi ragione su tutti e tre: continua a farlo.

# fine dell'aggiunta FJ
