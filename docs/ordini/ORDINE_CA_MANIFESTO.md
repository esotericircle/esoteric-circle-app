# ORDINE CA, LA SINASTRIA VIP

Ordine del fondatore del 28 agosto 2026, sette voci, con la REGOLA ZERO (il
testo dell'ordine non e' affidabile e ogni fatto si verifica sul ramo) e la
REGOLA UNO (non ci si ferma: si risolve e si riporta). Guardia
`test/ordine_ca_guard_test.dart`.

**Assorbe la voce BZ.09**, che era la prima meta' di CA.01 e di CA.07: quel
lavoro non e' stato rifatto, e' stato spostato dove l'ordine lo vuole.

## Le sette voci

- **CA.01** La porta d'ingresso. **CHIUSA.** Entrando si vedono per prime le due carte col titolo sopra e le tre scelte; la galleria e' il passo dopo.
- **CA.02** Il tocco sulla carta sbagliata. **CHIUSA.** Ogni casella chiede il volto per se': la carta che si tocca e' la carta che cambia.
- **CA.03** L'animazione di riflessione. **CHIUSA.** Dura 5.000 millesimi invece di 4.100 e porta DUE carte, una per cerchio.
- **CA.04** I testi nuovi. **CHIUSA.** Il corpus revisione B e' in vigore, e i tre pezzi che non esistevano ci sono.
- **CA.05** L'attualita' dei personaggi. **CHIUSA.** Due campi nuovi, la regola dei novanta giorni, e la strada del server per tenerli aggiornati senza pubblicare.
- **CA.06** La possibilita' d'incontro. **CHIUSA.** I valori mostrati vanno da 16 a 100 invece che da 3 a 21.
- **CA.07** Le carte dell'elenco. **CHIUSA.** Da 101 a 165 punti dipinti, e restano dentro uno schermo da 320.

VOCI_TOTALI: 7
VOCI_APERTE: 0
VOCI_CHIUSE: 7

## CA.01, la porta d'ingresso

**Parole del fondatore:** "LA SINASTRIA VIP DEVE PARTIRE con la schermata dove
ci sono le 2 carte in alto dove l'utente puo' scegliere il VIP a destra e a
sinistra c'e' la carta dell'utente con titolo sopra La Tua Compatibilita' con un
VIP", e "le bolle di fai sinastria vip oppure calcola il tuo gemello astrale VIP
devono stare nella prima schermata che vede l'utente e non nella schermata di
scelta del vip".

Nasce `PortaDellaSinastria`: il titolo, le due carte affiancate, il bottone che
apre il responso e le tre scelte. La galleria torna a fare un mestiere solo,
scegliere un volto e restituirlo a chi l'ha aperta.

**LA FORMA DELLE TRE SCELTE ERA MIA DA DECIDERE, E LA DICHIARO: TRE PORTE IN
FILA**, tutte visibili. La ragione e' quella dell'Architetto, ed e' misurabile:
il gemello astrale non chiede di scegliere nessuno ed e' la funzione piu'
condivisibile dell'app; dietro una tendina costerebbe due gesti e una parola che
non promette niente, e una funzione virale che chiede due gesti non e' piu'
virale. **Si rovescia con una riga**: `PortaDellaSinastria.leTreScelteInFila` a
falso e le stesse tre voci diventano la tendina che il fondatore aveva in mente.
Le due forme leggono lo stesso elenco, quindi nessuna delle due puo' restare
indietro.

**Il rosso**: puntando l'arte di nuovo sulla galleria, la prova dell'ingresso
stampa "aprendo la Sinastria VIP si monta altro" e cade.

## CA.02, la carta che si tocca e' la carta che cambia

**Parole del fondatore:** "toccando la carta di sinistra per cambiare quel
personaggio, viene cambiato sempre quello di destra".

**Era vero, e la causa era una riga.** Nel responso, "Cambia questo VIP" faceva
`Navigator.maybePop()`, cioe' tornava indietro di UNA rotta: e sotto c'era
sempre la galleria che aveva scelto il SECONDO. **La pila del Navigator non sa
quale casella volevi.** Adesso le due caselle vivono nella porta, ognuna sa qual
e', e la galleria restituisce il volto con `Navigator.pop(vip)` a chi l'ha
aperta.

**Il rosso**: facendo riempire alla carta di sinistra la casella di destra, la
prova stampa "a sinistra [Tu], a destra [Bad Bunny]" e cade nominando il difetto
del fondatore.

## CA.03, l'animazione di riflessione

**Parole del fondatore:** "l'animazione e' troppo veloce e sembra bloccarsi a
meta', e il testo che compare sotto non si fa in tempo a leggerlo", e "quando ci
sono 2 VIP dovrebbero comparire le due carte nei rispettivi cerchi che si
fondono tra loro".

| cosa | prima | adesso |
| --- | --- | --- |
| ogni aspetto acceso | 380 millesimi | **900** |
| la sovrapposizione dei due cerchi | 880 | **1.200** |
| il tetto della scena | 6.000 | **8.000** |
| la scena a video, misurata fotogramma per fotogramma | 4.100 | **5.000** |
| le carte durante la fusione | una | **due**, 33 fotogrammi su 33 |

Il nome dell'aspetto e' un testo, e trecentottanta millesimi sono meno del tempo
che serve a leggere tre parole.

**Un difetto trovato allungando i tempi**: con zero aspetti il momento degli
aspetti dura zero, quindi all'ultimo fotogramma risultava compiuto e
`clamp(0, -1)` faceva cadere la scena. Due cieli che non si toccano sono un caso
vero, non un errore.

## CA.04, i testi nuovi

Il corpus **revisione B** dell'Architetto sostituisce per intero
`docs/corpus/sinastria_testi.md`, e il codice non lo copia: `TestiDellaSinastria`
nasce da quel documento e `test/il_corpus_della_sinastria_test.dart` rilegge il
documento e pretende che ogni frase dell'app sia sua. **166 frasi confrontate,
zero fuori dal corpus.**

I tre pezzi che non esistevano, adesso a schermo:

- **la frase sopra il cerchio**, che sostituisce l'etichetta dentro il cerchio.
  Dipendeva dalla sola fascia, cioe' **cinque** frasi in tutto: adesso nasce
  dalla relazione fra i due segni E dalla fascia, cioe' **trentacinque**;
- **il titolo della bolla**, che prima non c'era: la bolla apriva sempre con "Il
  fatto e' questo";
- **la nota, fuori dalla bolla e in corpo minore**, dove finiscono l'ora di
  nascita ignota, il luogo ignoto e la data dell'attualita'. Occupavano tre
  righe su otto **dentro** il testo che deve diventare virale.

Il corpo della bolla e' cucito in quattro frasi: apertura sui due segni, cielo
reso leggibile (**prima cosa significa, poi come si chiama**), il personaggio con
la sua attualita', la stoccata finale. Aperture, stoccate e sfide si scelgono a
rotazione deterministica per coppia, come gia' faceva la chiusura ironica: la
stessa coppia legge sempre lo stesso responso, coppie diverse ne leggono di
diversi.

**La regola che governa ogni riga, e non si negozia**: nessun testo dell'app
afferma qualcosa sulla vita privata, sui sentimenti, sulla salute o sui guai di
una persona reale.

**Il rosso**: sopra il cerchio le frasi distinte sono 35 e la prova cade sotto
30; tolta la nota dalla sua casa, la prova trova il disclaimer dentro la bolla e
cade.

## CA.05, l'attualita' dei personaggi

**Parole del fondatore:** "io vorrei dei riferimenti alla vita reale del VIP,
qualcosa di aggiornato sempre".

**Uno.** Il catalogo ha due campi nuovi, `attualita` e `attualitaVerificataIl`,
e la regola dei novanta giorni: oltre, il fatto non e' piu' attualita' e il
testo lo salta senza che si veda. Nel catalogo compilato sono **vuoti per tutti
e cinquanta**, e non e' una dimenticanza: il corpus dice che il fatto "lo scrive
chi aggiorna il catalogo", e io non invento fatti sulla vita di nessuno.

**Due, la strada per tenerli aggiornati.** E' quella che l'ordine BX ha gia'
aperto per lo stato in vita: il documento **`catalogo/vip` su Firestore**, campo
`attualita`, una voce per nome con `testo` e `verificata_il`. La callable
`statoDelCerchio`, che l'app chiede a ogni apertura, la porta insieme allo stato
in vita: **nessun canale nuovo, e nessun modello lasciato libero di raccontare
la vita di una persona.** Il fatto entra come dato verificabile, scritto da una
persona, e una voce scritta male si butta invece di indovinarla.

**LA FONTE SCELTA E OGNI QUANTO SI AGGIORNA, che l'ordine chiede di
dichiarare.** La fonte e' **il comunicato o la pagina ufficiale del
personaggio o del suo lavoro** (l'annuncio del disco, il tabellone del torneo,
la scheda del film): sono fatti professionali, pubblici e datati, e nessuno di
loro parla della vita privata. La cadenza e' **trimestrale**, che e' la stessa
finestra dei novanta giorni: un fatto piu' vecchio non compare, quindi
aggiornare piu' di rado vorrebbe dire mostrare solo la presentazione. Per lo
stato in vita la fonte e' **anagrafica** (il comunicato ufficiale della
famiglia o dell'ente, non il costume) e la cadenza e' **all'occorrenza**, perche'
li' l'errore si vede subito ed e' grave.

**I due rossi**: con un fatto verificato ieri il testo lo porta; con lo stesso
fatto verificato sei mesi fa non lo porta piu' e la frase regge lo stesso.
Correggendo lo stato in vita dal server, il catalogo compilato dice "in vita" e
l'app dice "scomparso" senza nessuna pubblicazione, il testo passa al passato e
la stoccata diventa quella sobria della memoria.

## CA.06, la possibilita' d'incontro

**Il fatto:** sulla build 2211 la possibilita' d'incontro segnava 1,8 per cento.
L'ordine BX aveva chiuso il rilievo come FALSO, e la sua motivazione era giusta
a meta': non era la possibilita' a essere sempre bassissima, era la misura,
fatta con una citta' sola. **La misura e' stata corretta; il valore che la
persona vede no.**

La causa stava nel disegno della barra: `bars` portava gia' l'indice sulla
scala, ma la riga che disegna buttava via quel numero e ridisegnava la
percentuale cruda, che su una scala da cento e' una barra vuota per tutti.

E la scala stessa era il tetto teorico, cioe' **la persona piu' esposta del
catalogo che vive nella tua stessa citta'**: un caso che quasi nessuno incontra.
Su venti coppie i valori mostrati stavano fra il 3 e il 21 per cento di quel
tetto. La scala di lettura adesso e' **un quinto del tetto**, che e' la misura
vera del campo.

| grandezza misurata, sulle stesse venti coppie | prima | adesso |
| --- | --- | --- |
| intervallo dei valori mostrati | da 3 a 21, cioe' **18** | da 16 a 100, cioe' **84** |
| gradini in parole diversi | 3 | **4** |

**Il numero vero non sparisce**: la percentuale con la virgola sta nella riga
sotto la barra, insieme al perche'.

## CA.07, le carte dell'elenco

Chiusa con la voce BZ.09 e verificata qui: il massimo della colonna passa da 132
a 168, quindi le colonne da tre a due, e il ritratto **dipinto** da 101 a **165
punti**, misurato coi rettangoli trasformati e non con quelli di layout, secondo
il precedente dell'ordine BA. Le tre carte restano dentro lo schermo anche a
**320** di larghezza.
