# ORDINE FA, LE ICONE, I NOMI E LE PROMESSE

**Sigla:** FA. **Data dell'ordine:** 4 ottobre 2026, due pezzi. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`, nessun altro. **Partenza:**
commit `31821ce2`, la testa vista dall'Architetto, col lavoro dell'ordine EZ.

**Regole in primo piano.** R5, la prova di vista con l'innesto verificato
entrato (registro `docs/collaudo/FA/regola_a_fa.txt`). R9, la build la ordina
il fondatore: questo ordine non ne fa. R11, nessuna chiamata al modello. R14,
nessuna voce aumenta il costo.

**Le funzioni non sono pubblicate.** Le voci FA.01, FA.04 e FA.05 cambiano
anche il server: il comando per il fondatore sta nel rapporto.

VOCI_TOTALI: 6
VOCI_CHIUSE: 4
VOCI_APERTE: 2
VOCI_DA_FARE: 0

## VOCE FA.01, VIA LE CARTE DALLE ICONE DEL PROFILO

**CHIUSA.** Le famiglie delle icone sono tre: i dodici emblemi dei segni, i
dodici animali guida, le dodici statue degli archetipi, trentasei icone. La
famiglia degli Arcani esce, sul telefono (`FamigliaDelleIcone`) e sul server
(`QUANTE_ICONE`, `FAMIGLIE_DELLE_ICONE`) nello stesso movimento. L'Arcano
personale non si tocca: resta calcolato dalla nascita e resta nel Cosmic
Passport, e la riga e' scritta in `le_icone_del_cerchio.dart`. Il ripiego di
un codice non piu' valido e' il segno solare della persona
(`IconaDelProfilo.valida` sul telefono, `iconaDelSegno` sul server), il
primo della lista solo se il segno non si conosce. Ogni testo che contava
quattro set ne dice tre. Le tre famiglie restano intere nel tondo col margine
dell'ordine EZ. Il server allineato va pubblicato.

DOMANDA: "Io eviterei gli arcani e qualunque carta come profilo utente, starebbero irriconoscibili. Usa emblemi, segni, archetipi, animali che sono in 3d e ben riconoscibili"
PROVA: test/gli_arcani_escono_dalle_icone_test.dart
MISURA: icone prima 58 in 4 famiglie, dopo 36 in 3, uguali al server (12, 12, 12); codici di un Arcano nei dati di prova di partenza 3 persone (le anteprime EZ), che ricadono sul loro segno (Toro, Gemelli, Pesci); il profilo di una persona dei Pesci che aveva l'Arcano 1 diventa segno:11, prima segno:0 per chiunque; icone con pixel nella corona 0 su 36
ACCETTAZIONE: nella vetrina delle icone non ci sono piu' carte, e chi aveva scelto un Arcano vede l'emblema del suo segno

## VOCE FA.02, IL SEGNO NUMERO 15 DICE IL VERO

**CHIUSA.** Il segno 15 diventa "Sfidami con un VIP": chi riceve legge
"Qualcuno ti sfida: con quale VIP fai più scintille?", risponde "Accetto la
sfida" o "Più tardi", e la prima risposta apre la Sinastria VIP, la porta che
esiste davvero. L'identificativo `facciamoLaSinastria` non cambia, la
categoria resta quella delle richieste (sei), e accanto c'e' il commento con
la data: quando nascera' la sinastria fra amici il segno tornera' a parlare
di voi due. Le richieste aprono adesso da un punto solo,
`rottaDellaRichiesta`.

DOMANDA: "l'unica sinastria disponibile è la sinastria Vip, quindi credo che il collegamento sia a questa. Appena faremo la sinastria per amici o sinastria approfondita, aggiorneremo il collegamento"
PROVA: test/i_segni_dicono_il_vero_test.dart
MISURA: segni che promettono una cosa e ne aprono un'altra prima 1 su 18, dopo 0; richieste con una destinazione che non si raggiunge 0 su 6
ACCETTAZIONE: fra le richieste nella scheda di un amico c'e' "Sfidami con un VIP", e chi la riceve, toccando "Accetto la sfida", entra nella Sinastria VIP

## VOCE FA.03, LA CATTURA CHE MOSTRA UN'ALTRA SCHERMATA

**CHIUSA.** Era la possibilita' (a): la cattura, non l'app. La vetrina non
aveva schede, era un elenco unico che scorreva; la cattura degli archetipi
trascinava oltre la fine dell'elenco, che non si muoveva, e fotografava la
stessa schermata di quella degli Arcani. Con tre famiglie l'elenco scorreva
appena e l'errore sarebbe tornato su animali e archetipi: la vetrina mostra
adesso una famiglia alla volta, con le tre scelte in cima, e si apre sulla
famiglia dell'icona di oggi. La guardia apre la vetrina vera, tocca ogni
famiglia e confronta le tre schermate a coppie.

DOMANDA: "Le catture docs/preview/prima_dopo/ez01_vetrina_gli_arcani_dopo.png e ez01_vetrina_gli_archetipi_dopo.png mostrano la stessa schermata"
PROVA: test/le_catture_della_vetrina_sono_diverse_test.dart
MISURA: pixel diversi (oltre 32 su 765) nel rettangolo delle icone: prima fra Arcani e archetipi la stessa schermata (0,26 per cento misurato dall'Architetto; differenza massima 30 su 765 misurata qui), dopo segni e animali 24,80 per cento, segni e archetipi 24,03, animali e archetipi 10,63, la stessa schermata due volte 0,00; soglia 5 per cento
ACCETTAZIONE: nella vetrina delle icone le tre scelte in cima mostrano ciascuna la sua famiglia

## VOCE FA.04, IL SIGILLO QUANDO DUE NOMI COINCIDONO

**APERTA IN ATTESA DI VERIFICA.** In un elenco del Cerchio il sigillo compare
accanto al nome solo quando due o piu' nomi coincidono nella forma dei nomi
riservati (`LeRegoleDelNome.formaDelNome`), e allora su tutti quelli che
coincidono: piccolo, dopo il nome, nel grigio delle didascalie. La regola
vive in `NomeDellaPersona` ed `ElencoDelCerchio` (`disegni_del_cerchio.dart`)
e la usano la riga di una persona (`RigaDellaPersona`, cioe' il tuo Cerchio
e la tendina) e le persone bloccate, che prima portavano sempre il sigillo
sotto il nome. Il server porta adesso il sigillo anche nella presenza e
nella tendina: va pubblicato.

DOMANDA: "Eco Corvo Mite" compare due volte con due icone diverse e due stati diversi, cioe' due persone che la schermata non distingue
PROVA: test/il_sigillo_quando_due_nomi_coincidono_test.dart
MISURA: in un elenco con due nomi uguali per l'occhio (maiuscole e spazi diversi) sigilli a schermo 2 su 2, sul terzo 0; senza collisioni 0 su 3; nel tuo Cerchio coi due "Eco Corvo Mite" prima 0, dopo 2 (R7KQ e M4XR), su Stella Lieve 0
ACCETTAZIONE: nel tuo Cerchio due persone che si chiamano allo stesso modo mostrano il loro sigillo accanto al nome, e le altre no

## VOCE FA.05, LA SOGLIA DELLE LETTURE, E LA VOCE EZ.03 SI CHIUDE

**APERTA IN ATTESA DI VERIFICA.** La soglia nuova: non piu' di dieci letture
per apertura della tendina; la ricostruzione dell'istantanea resta una sola
ogni trenta secondi per tutto il Cerchio, condivisa, e non conta. Per
restarci sempre, qualunque sia il numero degli amici, la presenza porta
l'elenco degli amici e la tendina trova gli amici presenti con UNA domanda
chiusa a sei (`AMICI_NELLA_TENDINA`): quattro letture fisse piu' sei. Gli
elenchi si aggiornano nello stesso punto e nella stessa transazione dei
legami. La voce EZ.03 e' chiusa nel suo manifesto con la riga che nomina
questo ordine. Aspetta la pubblicazione delle funzioni e dell'indice nuovo.

DOMANDA: "Ti consiglio di misurare la soglia su un uso realistico"
PROVA: test/la_tendina_non_supera_dieci_letture_test.dart
MISURA: letture di un'apertura contate sul codice della tendina e delle funzioni che chiama: prima 4 fisse piu' una per ogni amico presente, senza tetto; dopo al massimo 10 (tetto 1, identita' 1, legami 1, blocchi 1, amici presenti al massimo 6), letture dentro un giro 0; l'apertura che ricostruisce l'istantanea prima 1.006, dopo 44, condivisa; soglia 10
ACCETTAZIONE: la tendina mostra al massimo sei amici presenti e risponde come prima

## VOCE FA.06, LA FRASE NEUTRA, E BASTA UNA

**CHIUSA.** Il segno "Hai fatto molta strada" ha una forma sola: "Qualcuno ha
visto quanta strada hai fatto." Le due varianti di genere sono tolte, con la
ragione accanto. Gli altri diciassette, riletti con lo stesso occhio, non
presuppongono il genere di chi legge: le risposte sono alla prima persona e i
participi ("Pescata", "Gettata", "È arrivato") parlano della carta, della
runa e dell'animale.

DOMANDA: "la forma neutra si legge meglio per tutti"
PROVA: test/i_segni_dicono_il_vero_test.dart
MISURA: righe e risposte dei segni 73, col genere di chi legge prima 1 segno (marcato con tre forme), dopo 0; marche del genere nei segni prima 1, dopo 0; le forme cercate prendono le righe di prima 3 su 3
ACCETTAZIONE: il segno "Hai fatto molta strada" ricevuto dice "Qualcuno ha visto quanta strada hai fatto." a chiunque
