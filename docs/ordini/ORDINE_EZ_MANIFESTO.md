# ORDINE EZ, IL CERCHIO SENZA DIFETTI

**Sigla:** EZ. **Data dell'ordine:** 4 ottobre 2026, tre pezzi (Parte A i
difetti, Parte B le decisioni del fondatore, Parte C il materiale
dell'Architetto). **Ramo:** `claude/esoteric-circle-master-order-e798aj`,
nessun altro. **Partenza:** commit `983a9cfc`, la testa vista
dall'Architetto, col lavoro dell'ordine EY consegnato nella build 2296.

**Regole in primo piano.** R5, la prova di vista con l'innesto verificato
entrato (registro `docs/collaudo/EZ/regola_a_ez.txt`). R9, la build la ordina
il fondatore: questo ordine non ne fa. R11, nessuna chiamata al modello. R14,
nessuna voce aumenta il costo: le letture si misurano prima e dopo. R15, un
controllo o e' collegato o e' dichiarato inattivo.

**Le funzioni non sono pubblicate.** Le voci EZ.03, EZ.04, EZ.07 ed EZ.08
cambiano il server: il comando per il fondatore sta nel rapporto. Senza la
pubblicazione il telefono di oggi continua a funzionare come prima.

VOCI_TOTALI: 8
VOCI_CHIUSE: 5
VOCI_APERTE: 3
VOCI_DA_FARE: 0

## VOCE EZ.01, LE ICONE SI VEDONO INTERE DENTRO IL CERCHIO

**APERTA IN ATTESA DI VERIFICA.** L'icona del profilo si disegnava gia' da un
componente solo, `IconaTonda` (la premessa Q2 era falsa: sette chiamate in
cinque file, nessun altro punto legge l'immagine). Il difetto stava tutto li':
l'immagine riempiva il tondo (`BoxFit.cover` dentro un `ClipOval`) e per gli
Arcani il taglio era spostato in alto. Adesso l'immagine sta intera nel
QUADRATO INSCRITTO nel tondo utile, dentro l'anello: lato uguale al diametro
utile per 0,7071, arrotondato per difetto al punto. Il cerchio e l'anello
restano quelli. Il ritaglio tondo e' tolto, perche' avrebbe nascosto il
difetto che la prova cerca. Aspetta il giudizio visivo del fondatore: gli
archetipi (statue alte e sottili) e gli Arcani (carte intere, nessuna
immagine dell'Arcano senza cornice nel progetto) a 44 e 64 punti diventano
piccoli, e il punto 4 dell'ordine lo porta a lui.

DOMANDA: "le immagini profilo proposte all'interno del cerchio e tutte sono tagliate dalla cornice del cerchio, vorrei che la figura o emblema si vedesse bene e non venga tagliato"
PROVA: test/le_icone_stanno_intere_nel_tondo_test.dart
MISURA: pixel del soggetto nella corona (dentro l'anello, fuori dal quadrato inscritto), rese dentro la prova: icone che ne avevano prima 58 su 58 a 112 punti (la Regola A, A1, rimette il riempimento), dopo 0 su 58 a 112 punti e 0 su 58 a 44 punti; margine per lato a 112 punti 18,5 punti (16,5 per cento), a 44 punti 8 punti (18 per cento); punti che leggono l'immagine fuori dal componente 0, chiamate del componente 7 in 5 file
ACCETTAZIONE: nella vetrina delle icone, nel tuo Cerchio e nella scheda di un amico ogni figura si vede intera dentro il tondo, senza teste, zampe o cornici tagliate

## VOCE EZ.02, IL CONFRONTO DEL CIELO CAMBIA DAVVERO OGNI GIORNO

**CHIUSA.** Il cielo di oggi prende la longitudine vera della Luna
(`NightSky.moonEclipticLongitude`, che chiede a `Effemeridi`, la porta sola
del cielo) e la misura dal punto d'incontro dei due segni, il punto medio dei
loro gradi centrali su cui la tradizione costruisce la carta composita: Luna
vicina, giornata che accorda; Luna opposta, giornata che mette alla prova. La
base resta quella di `AltreAffinita` e dell'aspetto fra i segni: il cielo la
sposta di al massimo venti punti, e per lasciargli posto la base si avvicina
al cinquanta di tre decimi, uguale per tutte le coppie. Per due segni opposti
vale il punto medio che viene prima nella ruota, una regola che non dipende
dall'ordine dei due. Tutto sul telefono, nessuna chiamata. La prova che
pretendeva greaterThan(1) su Leone e Pesci e' sostituita, con la lapide.

DOMANDA: "bisogna assolutamente sistemare tutto"
PROVA: test/il_confronto_del_cielo_e_simmetrico_test.dart
MISURA: valori distinti in trenta giorni consecutivi dal 4 ottobre 2026, sulle 78 coppie: prima da 3 a 7 (mediana 4, la peggiore Ariete e Toro con 3, Leone e Pesci 4), dopo da 18 a 25 (mediana 22, la peggiore Bilancia e Pesci con 18, Leone e Pesci 22), soglie 15 per coppia e 20 di mediana; in quattro finestre di stagioni diverse il minimo dopo e' 17; salto massimo fra due giorni prima 11, dopo 6 in tutte e quattro le finestre, soglia 12; differenze fra i due versi 0 su 2.262 confronti, prima e dopo
ACCETTAZIONE: aprendo il confronto con lo stesso amico due giorni di fila il numero cambia, di pochi punti, e chi e' molto compatibile resta in alto

## VOCE EZ.03, LE LETTURE DELLA TENDINA SCENDONO

**CHIUSA.** Chiusa dall'ordine FA voce 05 (4 ottobre 2026), che ha fissato la
soglia vera: non piu' di dieci letture per ogni apertura della tendina, la
ricostruzione esclusa perche' condivisa; un'apertura ne legge al massimo
dieci (`test/la_tendina_non_supera_dieci_letture_test.dart`). Quello che
segue e' com'era scritto prima. Sulla soglia: il costo che cresceva con le persone e' sceso di
venti volte, ma nello scenario dell'ordine EY (sessanta aperture in un'ora)
le letture fisse di ogni apertura bastano da sole a superare centocinquanta,
e nessun disegno le toglie. Il numero e la scelta stanno nel rapporto.
L'istantanea non contiene piu' tutti i presenti: porta i conteggi per arte,
presi con le aggregazioni di Firestore, e una vetrina di al massimo
ventiquattro presenti visibili a tutti e maggiorenni da cui il server sceglie
le dodici persone simili. Gli amici presenti si leggono con una domanda
mirata sulle loro sole presenze. Ogni istanza del server tiene l'istantanea in
memoria per trenta secondi. Il passo della presenza non rilegge piu'
l'identita' a ogni minuto: la scheda si scrive al primo passo e la
aggiornano le porte del profilo. La finestra resta novanta secondi, il passo
sessanta, l'istantanea al massimo ogni trenta. Tre indici nuovi in
`firestore.indexes.json`.

DOMANDA: "non voglio altri costi da sostenere, tutto deve essere deterministico. La soglia di costi max al 30% deve essere rispettato ed è già raggiunta"
PROVA: functions/src/sociale.test.ts
MISURA: letture col metodo di `lettureAllOra` (un documento letto, un'aggregazione ogni mille voci d'indice, una domanda vuota), mille presenti: UN'APERTURA che trova l'istantanea da rifare prima 1.006, dopo 44; in un'ora con sessanta aperture e cento telefoni che chiedono prima 901, dopo 323 (soglia 150 non raggiunta: 60 aperture per 5 letture fisse fanno 300); in un'ora con sei aperture prima 90, dopo 32; il passo della presenza in un'ora prima 120, dopo 61
ACCETTAZIONE: aprendo la tendina si vedono gli stessi amici presenti, gli stessi conteggi per arte e le stesse persone simili di prima

## VOCE EZ.04, IL CERCHIO SOCIALE SI APRE A QUATTORDICI ANNI

**APERTA IN ATTESA DI VERIFICA.** Sotto i quattordici anni le funzioni
sociali non si aprono: nessun profilo pubblico, nessuna presenza, nessun
legame, nessun segno, nessun dono, nessun confronto. Nessun consenso
genitoriale costruito. Tutto il resto dell'app resta intero, ed e' scritto
sopra la regola. L'eta' viene solo dalla data di nascita gia' nel profilo; il
telefono la dichiara alla sola porta che la riceve, il server la scrive nel
documento del tetto e ogni altra porta la trova nella stessa transazione del
tetto, senza una lettura in piu'. Sotto i quattordici si legge una riga sola,
"Il Cerchio si apre a quattordici anni", senza etichette. Dai quattordici ai
diciotto resta quello che l'EY.09 ha costruito. Aspetta la pubblicazione delle
funzioni e la prova sul telefono.

DOMANDA: "Per ogni domanda approvo tuoi suggerimenti"
PROVA: test/il_cerchio_si_apre_a_quattordici_anni_test.dart
MISURA: porte sociali del server 16, senza la soglia 0, la soglia prima del conto del tetto; gesti sociali del telefono a tredici anni 15, porte arrivate al server 1 su 16 (quella che riceve l'eta'), prima 16 su 16; porte aperte sotto i quattordici sul server 1 (la stessa); il compleanno apre il Cerchio al primo ingresso utile
ACCETTAZIONE: con una data di nascita di tredici anni il tuo Cerchio, la tendina e il profilo dicono soltanto "Il Cerchio si apre a quattordici anni", e le arti restano tutte aperte

## VOCE EZ.05, IL GIFT EOS SI DICHIARA, INVECE DI FALLIRE

**CHIUSA.** Nella scheda dell'amico "Regala Eos" non e' piu' un pulsante che
tenta e fallisce: e' la vetrina dichiarata, col badge "Dietro il velo" che
l'app usa gia' altrove e la riga "Si apre quando gli abbonamenti e i
pacchetti di Eos saranno acquistabili". La regola resta scritta sul server
(`decidiIlGift`): solo Eos comprati o della dote, mai quelli guadagnati
gratis, da cento a cinquecento al giorno. Si apre cambiando una sola riga,
`IlCerchioSociale.ilGiftEosEAperto`, nell'ordine che rendera' acquistabili
abbonamenti e pacchetti. Niente costruito sugli acquisti.

DOMANDA: "Per ogni domanda approvo tuoi suggerimenti"
PROVA: test/il_gift_eos_si_dichiara_test.dart
MISURA: porte del server che alzano gli Eos regalabili 0; pulsanti che tentano di spendere nella scheda prima 1, dopo 0; porte chieste dopo il tocco sulla voce velata 0 (regalaGliEos mai)
ACCETTAZIONE: nella scheda di un amico "Regala Eos" si vede velato, col badge e la riga che dice da cosa si apre, e il tocco non apre niente

## VOCE EZ.06, GLI AMICI OFFLINE HANNO UN NUMERO ANCHE ALL'ILLUMINATO

**CHIUSA.** Viandante 0, Iniziato 3, Adepto 10, Illuminato 50. Il numero vive
nella matrice dei piani, la sola fonte che `AmiciOffline.posti` legge, con la
ragione accanto: un amico offline e' una scheda coi dati di nascita di una
persona che non ha dato nessun consenso, un legame e' una persona che ha
accettato, e per questo qui si sta sotto i legami (3, 15, 50, 150). Il
listino perde il nullo dell'Illuminato e il posto in piu' resta `amicoInPiu`
a 100 Eos. Chi ha gia' piu' di cinquanta schede le tiene tutte e non ne
aggiunge, e la riga glielo dice; la spesa di un posto che non basterebbe non
compare.

DOMANDA: "illimitato mi espone all'abuso o uso incontrollato o bot"
PROVA: test/gli_amici_offline_hanno_un_numero_test.dart
MISURA: piani senza limite nella matrice prima 1 su 4, dopo 0 su 4; nel listino prima 1 su 4, dopo 0 su 4; posti per piano dopo 0, 3, 10, 50; schede perse da chi ne aveva 55: 0
ACCETTAZIONE: nella pagina dei Piani la riga "Oroscopo per gli amici" dice 50 per l'Illuminato

## VOCE EZ.07, I FILE DEL DOMINIO E LA PAGINA DEL LINK SENZA STORE

**APERTA IN ATTESA DI VERIFICA.** I due file di verifica del dominio ESISTONO
GIA' e sono pubblicati: Firebase Hosting li genera da se' per le app
registrate nel progetto, su `esoteric-circle.web.app/.well-known/`, coi
valori veri (Android `com.esotericircle.esoteric_circle` con l'impronta
SHA-256 della firma di rilascio B4:0D...8C:B6, uguale a quella letta
dall'APK di rilascio con `apksigner`; Apple
`Z3T97U389U.com.esotericircle.esotericCircle`). Copie statiche nel repo li
avrebbero sostituiti e congelati: non le ho scritte. Cio' che impediva al link
di aprire l'app senza chiedere era altrove, e l'ho curato: il filtro Android
di `esoteric-circle.web.app/i/` senza `autoVerify`, e i diritti iOS senza
`applinks:esoteric-circle.web.app`. Il dominio `esotericircle.app` oggi non
risponde. La pagina del link non rimanda piu' a store che non esistono: mostra
il codice grande e copiabile con la riga "Scarica Esoteric Circle e incolla
questo codice quando ti registri"; gli indirizzi degli store vivono in un dato
solo, `INDIRIZZI_DEGLI_STORE`, vuoto, e vuoti i pulsanti non compaiono.
Aspetta la pubblicazione della funzione della pagina e una build per i link.

DOMANDA: "Per ogni domanda approvo tuoi suggerimenti"
PROVA: functions/src/sociale.test.ts
MISURA: rimandi a uno store nella pagina col dato di oggi prima 2, dopo 0; col dato pieno 2; file di verifica pubblicati e letti il 4 ottobre 2026 2 su 2, impronta SHA-256 uguale a quella dell'APK 1 su 1; host dei link d'invito con la verifica Android prima 0 su 2, dopo 1 su 2 (l'altro non risponde); domini nei diritti iOS prima 1, dopo 2
ACCETTAZIONE: un link d'invito aperto da un telefono con l'app installata apre l'app senza chiedere; aperto senza l'app mostra il codice da copiare e nessun pulsante verso uno store

## VOCE EZ.08, I DICIOTTO SEGNI DEL CERCHIO, COI TESTI VERI

**CHIUSA.** I diciotto segni portano i testi dell'Architetto: il titolo sul
pulsante di chi manda, la riga di chi riceve, le risposte. Gli identificativi
del server non sono cambiati: ai diciotto di prima stanno i diciotto nuovi,
nella stessa categoria. La regola dei segni astrali e' scritta sopra la
categoria: un segno invita a guardare il cielo, non dichiara mai un fatto del
cielo. Le sei richieste aprono ciascuna la sua funzione al tocco della prima
risposta; la sinastria si apre sulla sua porta, perche' il Cerchio non porta
la nascita di un amico. Il server conta adesso le risposte nuove (tre per
"Ti penso", due per gli altri): nessun numero e' salito, quindi il server di
oggi accetta gia' tutto.

DOMANDA: "I testi dei segni sono provvisori, scritti da me: li deve riscrivere l'Architetto"
PROVA: test/i_segni_del_cerchio_hanno_i_testi_veri_test.dart
MISURA: segni 18, per categoria 6, 6 e 6, incompleti 0, richieste che non aprono niente 0; righe segnaposto prima 18 segni su 18, dopo 0; righe astrali che affermano un fatto del cielo prima 4 su 6 segni, dopo 0 su 24 righe; righe con un nome 0; identificativi e risposte diversi dal server 0
ACCETTAZIONE: un segno "Chiedi alla Luna" ricevuto dice "Qualcuno ti manda dalla Luna di stanotte." con il nome di chi lo manda sotto
