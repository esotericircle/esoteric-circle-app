# ORDINE FC, L'OROSCOPO UNIVERSALE, UNA PORTA SOLA E IL VERDE CHE DICE IL VERO

**Sigla:** FC. **Data dell'ordine:** 4 ottobre 2026, tre pezzi e due Aggiunte (la voce FC.09 il 4 ottobre, le voci FC.10 e FC.11 il 5 ottobre 2026). **Ramo:**
`claude/esoteric-circle-master-order-e798aj`, nessun altro. **Partenza:**
commit `bcf8eaff`, la testa col lavoro dell'ordine FB.

**Regole in primo piano.** R16, il giro dell'utente: l'oroscopo proprio e
quello di un amico percorsi uno dopo l'altro, sul codice e sul Realme. R17,
le proposte di Code in fondo al rapporto. R9: la build l'ha ordinata il
fondatore il 4 ottobre 2026 (*"Alla fine fai tutti i test che servono su Cell
e poi consegna build pronta anche per codemagic"*). R11, nessuna chiamata al
modello in piu': le letture sono quelle che esistono. R14, nessuna voce
aumenta il costo: tutto sul telefono, nessuna porta del server nuova.

**Le voci FC.03, FC.04, FC.05 e FC.06 sono figlie della FC.02**: la porta
unica le ha chiuse insieme, e ognuna ha la sua riga e la sua misura.

VOCI_TOTALI: 11
VOCI_CHIUSE: 10
VOCI_APERTE: 1
VOCI_DA_FARE: 0

## VOCE FC.01, L'OROSCOPO SI CHIAMA UNIVERSALE

**CHIUSA.** Ovunque si legge il nome dell'arte si legge "Oroscopo
Universale": il catalogo delle arti (la fonte unica delle schede della home,
del dominio di Medora, della striscia delle altre arti, dell'introduzione
all'arte e del Santuario) e il pulsante della chat di Medora, che era scritto
a parte. Gli identificativi non si toccano: `horoscope`, il gesto `oroscopo`,
le chiavi. I commenti al presente dicono il nome nuovo; le lapidi raccontano
il passato col nome di allora. I documenti vivi sono allineati; i manifesti,
i rapporti consegnati e i registri di collaudo restano com'erano. I quattro
briefing non si toccano e non usano il nome come nome dell'arte.

DOMANDA: "il nome oroscopo personalizzato vorrei cambiarlo", "Oroscopo universale"
PROVA: test/l_oroscopo_si_chiama_universale_test.dart
MISURA: il nome come nome proprio nel repo prima 78 occorrenze in 46 file (2 a video in 2 file, 12 commenti in 10, 14 nelle prove in 9, 49 nei documenti in 26, 0 nel server e nelle notifiche, 1 uso comune nei briefing); dopo, a video 0 su 806 file di lib guardati, 80 con la parola oroscopo nei testi; ricerca sulle stringhe ricomposte (adiacenti, concatenate, due virgolette, maiuscole e minuscole, fino a due parole in mezzo)
ACCETTAZIONE: nella home, nel dominio di Medora e nel pulsante della chat leggo "Oroscopo Universale"

## VOCE FC.02, UNA PORTA SOLA PER L'OROSCOPO

**CHIUSA.** L'oroscopo e' una schermata sola, `OroscopoScreen`, e riceve di
chi e' la lettura: di chi usa l'app, oppure di un amico
(`OroscopoScreen.perUnAmico`). La schermata dell'amico,
`LOroscopoDellAmicoScreen`, non c'e' piu'. Cio' che cambia col soggetto sta
in un posto solo, `IlSoggettoDellOroscopo`, in nove punti scritti: il nome
nel titolo, i dati di nascita, la lettura sul segno solare, il neutro, la
card regalo, cio' che e' solo di chi guarda (il Sigillo dei Tre Cieli e
l'avviso del compleanno), i dati che mancano, l'anno sul luogo di nascita,
il cielo del fondale. La schermata non legge piu' i dati di nascita da
sola. Cio' che esisteva solo per l'amico e che era giusto e' portato dentro:
la riga "Oroscopo per" col cambio di amico, la rivelazione della testa della
tradizione per quell'amico (con la stessa chiave di prima, quindi le teste
gia' viste restano viste), il premio della condivisione, il segno detto di
lui ("Il segno di Lucia è Capricorno"). E' la ventiduesima occorrenza della
famiglia delle due porte: l'ordine ES voce 12 aveva fatto nascere una
seconda schermata invece di far passare questa per un soggetto diverso.

DOMANDA: "Quando faccio un oroscopo per un amico e scelgo l'amico, mi compare l'oroscopo di botto, senza pulsante e senza animazione di riflessione"; "Lo sfondo è nero"; "il responso non è uguale: mancano le infografiche come negli altri"; "manca la scelta tra giornaliero, settimanale, mensile, annuale"
PROVA: test/l_oroscopo_e_uno_solo_test.dart
MISURA: cose che l'oroscopo mostra, enumerate (fondale, "Oroscopo per", periodi, tradizioni, gesto, nessuna scheda prima del gesto, le quattro schede, i selettori di profondita', la card): per se' 9 su 9, per l'amico prima 6 su 9 (senza fondale, periodi e card dell'oroscopo), dopo 9 su 9; letture dirette dei dati di nascita nella schermata dopo 0; differenze dichiarate nel soggetto 9; schermate dell'oroscopo prima 2, dopo 1
ACCETTAZIONE: aprendo l'oroscopo di un amico vedo la stessa schermata del mio, col suo nome in alto e il suo segno

## VOCE FC.03, IL GESTO E LA RIFLESSIONE CI SONO SEMPRE

**CHIUSA.** Chiusa dalla FC.02, e dall'interruttore tolto. La condizione
della premessa H2 (`!InterrogaIlCielo.ancheFuoriDalGiorno || ...`) non c'e'
piu', e nemmeno l'interruttore: serviva solo alle prove, per leggere i
periodi senza toccare, e adesso le prove toccano il gesto come una persona
(`test/il_gesto_nelle_prove.dart`). Sul Realme, prima, il gesto dell'amico
c'era ma il tocco non mostrava nessuna scena: il bottone spariva, per due
secondi non si vedeva niente, poi le schede comparivano in fondo. Adesso
l'amico ha la stessa scena: la corona dei corpi attorno all'emblema, i due
momenti della riflessione al posto delle schede, la corsa dello zodiaco, la
cascata, la vibrazione e il suono alla comparsa.

DOMANDA: "Quando faccio un oroscopo per un amico e scelgo l'amico, mi compare l'oroscopo di botto, senza pulsante e senza animazione di riflessione"
PROVA: test/l_oroscopo_e_uno_solo_test.dart
MISURA: secondi dal tocco alla prima scheda, prima riflessione del giorno, per se' 4,0 e per l'amico 4,0; schede nell'albero prima del tocco 0 per tutti e due; periodi col gesto per l'amico prima 1 su 12 (il solo Giorno, tre tradizioni), dopo 12 su 12 (quattro periodi per tre tradizioni, `il_gesto_in_tutti_i_periodi_test.dart`); letture senza il tocco 0
ACCETTAZIONE: toccando "Interroga il cielo" nell'oroscopo di un amico vedo la riflessione, poi le schede una dopo l'altra

## VOCE FC.04, IL FONDALE COSMICO, NON IL NERO

**CHIUSA.** Chiusa dalla FC.02: l'oroscopo dell'amico monta lo stesso
fondale dell'oroscopo, `CosmosBackground`, con la parallasse dei piani e le
nebulose sull'accento di Medora, e Riduci Movimento e il Quality Tier basso
lo fermano come ovunque. Il seme del cielo e' del soggetto: il 5 per se',
e per ogni amico il suo, deterministico dall'identificativo (500 piu' un
numero fra 0 e 399), uguale fra un'apertura e l'altra. E sul cosmo e'
passata anche la lista "I tuoi amici", che e' il primo passo di questo giro
ed era nera (seme 37).

DOMANDA: "Lo sfondo è nero"
PROVA: test/l_oroscopo_e_uno_solo_test.dart
MISURA: fondali cosmici nell'oroscopo dell'amico prima 0 (`Scaffold(backgroundColor: palette.deepest)`), dopo 1 (`CosmosBackground`, il sistema unificato che esiste); nella lista degli amici prima 0, dopo 1; catture prima e dopo, accanto, in docs/preview/prima_dopo/fc*
ACCETTAZIONE: l'oroscopo di un amico e la lista degli amici stanno sul cielo stellato come il resto dell'app

## VOCE FC.05, LE STESSE INFOGRAFICHE

**CHIUSA.** Chiusa dalla FC.02: le schede dell'amico sono le stesse schede,
con le stesse infografiche nello stesso ordine. Due infografiche vogliono la
carta natale, e di un amico la carta non c'e': non si disegnano vuote, si
tolgono, e il perche' sta scritto nella prova (la ruota del passaggio mostra
il transito di oggi su un pianeta della carta; l'ora d'oro e' l'ora in cui
la Luna tocca un punto della carta).

DOMANDA: "il responso non è uguale: mancano le infografiche come negli altri"
PROVA: test/l_oroscopo_e_uno_solo_test.dart
MISURA: infografiche dell'oroscopo proprio con la carta 5 (il livello del dominio, le ore del giorno, il numero e il colore della Fortuna, la ruota del passaggio, l'ora d'oro); dell'amico prima 1 (il livello del dominio), dopo 3, e 2 tolte col perche'; disegnate vuote 0
ACCETTAZIONE: le schede dell'oroscopo di un amico hanno il livello, le ore del giorno, il numero e il colore come le mie

## VOCE FC.06, GIORNO, SETTIMANA, MESE, ANNO ANCHE PER L'AMICO

**CHIUSA.** Chiusa dalla FC.02: il selettore dei periodi e' lo stesso, coi
limiti del piano di chi guarda; l'anno viene dalla Rivoluzione Solare
dell'amico, sul suo luogo di nascita (dove vive adesso non si sa); dove
manca l'ora di nascita la riga lo dice con le parole della schermata, al
neutro e col nome dell'amico, e non porta ai dati di chi guarda. Gli Eos
che aprono un anno sono di chi guarda (l'unica borsa dell'app), e l'anno
aperto si ricorda per soggetto: aprire l'anno di Lucia non apre il proprio.

DOMANDA: "manca la scelta tra giornaliero, settimanale, mensile, annuale"
PROVA: test/l_oroscopo_e_uno_solo_test.dart
MISURA: periodi a video per l'amico prima 0 (il solo Giorno, senza selettore), dopo 4 su 4 a ogni piano; apribili per l'amico uguali a quelli di chi guarda, Viandante giorno e anno, Iniziato giorno settimana anno, Illuminato i quattro; anno aperto con gli Eos per Lucia {2026}, per se' {} (prima l'anno dell'amico non c'era)
ACCETTAZIONE: nell'oroscopo di un amico scelgo giorno, settimana, mese o anno come nel mio, e quello che il mio piano non apre mi invita al piano

## VOCE FC.07, LE SETTE PROVE ROSSE DEL RAMO

**CHIUSA.** Chiusa dalla FC.11.1 il 5 ottobre 2026, con la cura che il
fondatore ha scelto. Delle sette rosse ereditate:

- **ACCELERA, chiusa il 4 ottobre 2026** (cura (1), il lavoro era fatto): la
  sua voce aperta aspettava la prima consegna col verdetto di GitHub, arrivata
  con la 2287 il 28 settembre 2026 senza che il manifesto lo dicesse. Rossa
  dal 26 settembre 2026, commit `91c21317`.
- **CR.13**, rossa dal 6 settembre 2026 (commit `6734d8c3`), e **le guardie
  degli ordini EI** (23 settembre, `83084b8b`), **EJ** (24 settembre,
  `8aa44dcd`), **EK** (24 settembre, `9100412c`), **EM** (25 settembre,
  `55ab1bda`) ed **EN** (25 settembre, `201ac46f`): pretendevano un gesto del
  fondatore che sul ramo non esiste (il soffio, una testa davanti al
  telefono, l'orecchio, lo sguardo, una scrittura in console, una cattura
  della sua chat). Il fondatore, il 5 ottobre 2026, ha scelto la cura (3)
  della FC.11.1: la prova gira sul ramo e pretende che ogni voce aperta, e le
  soglie non misurate, dicano in una riga `ASPETTA:` quale gesto aspettano.
  Diciannove voci su diciannove lo dicono, e la CR.13 lo dice nel file delle
  soglie. La REGOLA G cede per queste cinque guardie, sulla sua parola.

DOMANDA: "Le sette prove rosse rimaste sul ramo si curano dentro questa aggiunta. Non si segnalano, non si elencano con la causa in attesa di un ordine futuro, non si marcano come note: si curano."
PROVA: test/le_voci_aperte_dicono_cosa_aspettano.dart
MISURA: rosse ereditate prima 7, dopo 0; voci aperte dei cinque ordini che dicono quale gesto aspettano prima 0 su 19, dopo 19 su 19; righe del registro dei rossi accettati per queste rosse prima 2, dopo 0
ACCETTAZIONE: nella suite intera non c'e' piu' nessuna delle sette rosse, e ogni voce aperta di quei cinque ordini dice quale mio gesto aspetta

## VOCE FC.08, IL CANCELLO ESEGUE LA SUITE INTERA

**CHIUSA.** La premessa H10 non regge: il cancello di GitHub esegue gia' la
suite intera, dall'ordine ACCELERA, in sei pezzi paralleli (circa dieci
minuti), e cade per ogni rosso che nessuno ha accettato. Il difetto vero era
che un verde con dei rossi accettati e un verde pieno si leggevano uguali:
l'elenco stava nel registro, che senza credenziali non si legge. Adesso la
macchina finale, a verde, pubblica un'annotazione con quanti e quali rossi
ha accettato (`tool/il_verdetto_del_cancello.sh`, modo `verde`). Che il
cancello diventi rosso per una prova rossa e' provato sui registri veri di un
giro di GitHub, con una prova rossa innestata.

DOMANDA: "Il difetto vero non sono le sette rosse: e' che il verde che leggiamo tutti non dice quello che crediamo dica"
PROVA: docs/collaudo/FC/il_cancello_diventa_rosso.txt
MISURA: cosa esegue il cancello prima e dopo: analisi, suite intera in 6 pezzi, corredo a scala 1,3, server e chiusure, decisione finale (prima e dopo uguale); rossi accettati detti dal verde prima 0 (solo nel registro chiuso), dopo 12 righe per nome, che coprono 17 prove rosse; uscita della decisione finale sui registri veri 0, con una prova rossa innestata 1
ACCETTAZIONE: aprendo un verde del cancello leggo, nelle annotazioni, quanti e quali rossi ha accettato

## VOCE FC.09, GLI AMICI ONLINE NELLA RUBRICA DEGLI AMICI

**CHIUSA.** Ordine FC Aggiunta 1, nella forma che il fondatore le ha dato la
stessa sera, e con la risposta dell'Architetto del 4 ottobre 2026 (i due
testi definitivi, la deroga alla R14 approvata col vincolo del tetto
condiviso, il chiarimento sull'icona nera). In cima a "I tuoi amici" ci sono
**Offline** a sinistra e **Online** a destra, col numero degli amici online
e il cerchietto verde (pieno quando qualcuno c'e', velato quando nessuno c'e'
o il numero non si sa). **Di default e' scelto Offline**, gli amici scritti
dalla persona come prima; **Online** mostra gli amici del Cerchio presenti
adesso, con la stessa riga della tendina (`AmicoPresente`, resa pubblica e
scritta una volta), e sotto la strada al Cerchio intero; col Cerchio vuoto
"Il tuo Cerchio è ancora da chiamare." (intatto) e l'invito. Il codice sta in
`lib/features/amici/gli_amici_online.dart`; la riga della prima stesura
(`il_ponte_verso_il_cerchio.dart`) e' tolta.

**I due testi del fondatore**, carattere per carattere e provati dalla
guardia: il sottotitolo di Online "Chi del tuo Cerchio è qui con te,
adesso." e, quando la tendina non arriva e non c'e' un ultimo dato noto, "Il
Cerchio non risponde in questo momento. Riprova fra poco."
(`IlCerchioSociale.rigaDellaTendinaCheNonArriva`, la stessa nella tendina).
La riga dell'ora e' anche lei del fondatore dal 5 ottobre 2026 (Aggiunta della
voce FC.10, parte prima): "Il Cerchio come era alle 21:47.", identica nella
tendina e nella rubrica, con l'ora in cui l'istantanea e' stata presa nel
formato del telefono (ventiquattro ore, o dodici con AM e PM:
`lib/features/cerchio/l_ora_del_telefono.dart`). **L'ultimo dato vale
un'ora**: oltre l'ora non si mostra, si cancella dalla memoria e dal
telefono, e compare "Il Cerchio non risponde in questo momento. Riprova fra
poco." Prova: `test/l_ultimo_dato_vale_un_ora_test.dart`.

**IL COSTO, APPROVATO.** La rubrica chiede la tendina **al piu' una volta per
apertura**, e mai quando la tendina ha meno di un minuto (si riusa), quando
nel Cerchio non c'e' nessuno (il numero e' zero, ed e' vero) o quando il
Cerchio e' chiuso per eta'. Una chiamata legge 5 documenti (misurati dalla
guardia `la_tendina_non_supera_dieci_letture`) e ne scrive 1 (il tetto della
porta): circa **0,0000027 euro, 0,27 centesimi ogni mille aperture**.

**IL TETTO CONDIVISO NON SI VEDE COME UN GUASTO.** Il tetto di trenta
chiamate l'ora e' della porta `laTendinaDelCerchio`, e adesso la chiamano la
tendina e la rubrica: e' condiviso. Quando la richiesta non arriva (il tetto
o la rete) il Cerchio sociale tiene l'ultima tendina arrivata
(`tendinaNonAggiornata`), e tutte e due le schermate la mostrano con l'ora a
cui e' stata presa, senza nessun messaggio di guasto. L'ultima tendina sta
anche sul telefono (`cerchio.ultimaTendina`, con lo uid di chi l'ha
ricevuta, tolta all'uscita), cosi' l'ultimo dato noto c'e' anche se l'app si
riapre dentro l'ora del tetto. Il testo del guasto compare solo quando un
ultimo dato noto non c'e' mai stato.

**L'ICONA NERA ERA LA CATTURA, NON LA RIGA (causa a).** La prima anteprima
dello stato Online era stata scattata senza caricare prima le icone del
Cerchio, come invece fanno le anteprime del Cerchio. Rifatta in un processo
nuovo, con lo stesso codice e lo stesso dato, cambiando solo il caricamento:
senza, il tondo di Stella e' nero (luminosita' media 20,5, 771 pixel chiari su
10000); con le icone caricate c'e' la lince (39,5, 2391 su 10000). Il
percorso dell'icona nel codice e' uno solo e la guardia lo prova: il server
mette `icona` in ogni amico presente della tendina, `PersonaDelCerchio.da` la
legge, `AmicoPresente` la passa con `conSemaforo` che la conserva, e
`RigaDellaPersona` la disegna con `IconaTonda`; la riga Online riceve
`assets/img_thumb/animali/ani_lince_v1.webp` per `animale:6`. La lista
Offline non ha icone: le schede degli amici scritti non ne hanno.

**Le due rubriche restano due**, e i due pulsanti si fermano li': la fusione
e' una decisione del fondatore, non presa. Il verso contrario, dal Cerchio
alla rubrica delle schede, oggi non esiste; non si costruisce qui.

DOMANDA: "in amico vorrei che comparissero anche gli amici online"; e poi "inserire 2 pulsanti: a sinistra offline e a destra online con a fianco il numero di amici online e un cerchietto verde. Di default è selezionato il pulsante offline che mostra gli amici creati dall'utente e se clicca su online compaiono gli amici online."; e il vincolo: "Quando il tetto è raggiunto, l'app NON mostra un errore: mostra l'ultimo dato noto con l'ora a cui è stato preso."
PROVA: test/il_cerchio_si_vede_dalla_rubrica_test.dart
MISURA: amici online visibili dalla rubrica prima 0 (la rubrica mostrava solo le schede), dopo 1 su 1 nella prova (Stella Lieve su Online, nascosta su Offline); pulsante scelto all'apertura Offline; chiamate della tendina all'apertura: 0 con la tendina fresca, 1 senza tendina, 0 riaperta subito dopo, 1 con la tendina vecchia di due minuti, 0 senza amici nel Cerchio (numero 0); messaggi di guasto a video col tetto raggiunto prima 1 nella rubrica (la riga del tetto, letta sul codice di 15b6461d e non misurata), dopo 0 nella rubrica, 0 nella tendina, 0 nella rubrica dopo la riapertura dell'app, con "Il Cerchio come era alle" e l'ora dell'ultima tendina (meno di un'ora; oltre si cancella); chiamate alla porta della tendina 3 da due schermate e un tetto solo sul server (30); l'icona di Stella nel tondo, luminosita' media 20,5 senza le icone caricate e 39,5 con; catture: docs/preview/prima_dopo/fc09_rubrica_offline_dopo.png, fc09_rubrica_online_dopo.png (Cerchio popolato), fc09_rubrica_online_nessuno_nel_cerchio_dopo.png (Cerchio vuoto), fc09_rubrica_online_ultimo_dato_dopo.png (tetto raggiunto, ultimo dato noto con l'ora), fc09_rubrica_online_non_risponde_dopo.png (errore senza ultimo dato), fc09_rubrica_online_senza_icone_caricate_dopo.png (la prova dell'icona nera); prima: fc_amici_lista_prima.png
ACCETTAZIONE: aprendo "I tuoi amici" vedo Offline scelto coi miei amici e, accanto a Online, quanti amici sono online col cerchietto verde; toccando Online compaiono loro con la loro icona, e se il Cerchio ha detto basta per un po' vedo gli ultimi che c'erano con l'ora, mai un messaggio di guasto

## VOCE FC.10, L'EMBLEMA DELL'AMICO SCRITTO E LA PORTA SOLA DEL SEGNO

**CHIUSA.** Ordine FC, Aggiunta del 5 ottobre 2026. Ogni amico scritto porta
nel tondo l'emblema del suo segno solare (`LEmblemaDellAmico`, che riusa
`IconaTonda` del Cerchio coi margini dell'ordine EZ e le icone dei segni
della famiglia del Cerchio: nessun asset nuovo), nella rubrica, nel bottone
dell'amico di "Oroscopo per", nel titolo del suo oroscopo e nel dialogo che
lo toglie. La card da condividere porta gia' l'emblema del suo segno come
protagonista. **Mai un tondo nero**: finche' l'immagine non c'e', la prima
lettera del nome; l'amico senza data sul ramo non esiste (il modulo non
salva senza data, e dal primo giorno, `50747b54`, un dato senza data non si
legge).

**IL SEGNO DAL SOLE VERO, DA UNA PORTA SOLA.** `IlSegnoDelCielo`
(`lib/core/astro/il_segno_del_cielo.dart`): il Sole di Meeus della libreria
del cielo (`IlSoleDiNascita`, misurato contro il JPL fra il 1900 e il 2100),
all'ora di nascita o a mezzogiorno, nel fuso del luogo. **Scelta presa e
dichiarata**: l'ordine diceva la libreria che il confronto del cielo usa per
la Luna, cioe' `NightSky` sopra `Effemeridi`; quel motore e' verificato dal
2020 al 2030 e la guardia `il_motore_locale_e_per_oggi` vieta di usarlo per
una nascita, quindi il Sole viene dal calcolo per le nascite della stessa
libreria, che c'era gia' (nessun secondo calcolo del cielo). Cancellate
`Zodiac.fromDate` e la sua tabella di date, `NightSky.sunSign`,
`NightSky.moonSign`, `IlCieloDelSegno.segnoDi`, il `_segnoDi` del cielo
detto, `CieloDiSinastria.segnoDiLongitudine`, `LAnnuale.segno`,
`TemaDellaRivoluzione.segno`, `_signFromLon` e `_signOfLongitude`; tutti i
chiamanti passano dalla porta. La frase del metodo e' nel foglio delle fonti
dell'oroscopo. Il costo: zero letture e zero scritture.

DOMANDA: "Emblema del segno zodiacale, aggiungi e riscrivi ordine"
PROVA: test/l_emblema_dell_amico_test.dart
MISURA: amici scritti con l'emblema prima 0, dopo tutti (3 su 3 nella prova, 12 segni su 12); strade dalla data al segno prima 6 piu' 13 conti dei trenta gradi a mano, dopo 1 porta (test/il_segno_ha_una_porta_sola_test.dart, rossa con una gemella innestata); giorni dal 1900 al 2100 col segno diverso dalle date fisse 1084 su 73414, in 27 giorni del calendario (docs/collaudo/FC/le_cuspidi_del_segno.txt); chiamate al server all'apertura della rubrica prima 0, dopo 0; tondi vuoti nella rubrica Offline prima dell'immagine prima 3 su 3, dopo 0; catture in docs/preview/prima_dopo/fc09_rubrica_offline_dopo.png
ACCETTAZIONE: nella rubrica ogni amico ha l'emblema del suo segno, lo stesso che dice il suo oroscopo, anche chi e' nato nel giorno in cui il Sole cambia segno

## VOCE FC.11, LA SUITE TUTTA VERDE E IL CANCELLO CHE LA ESEGUE

**APERTA IN ATTESA DI VERIFICA.** Ordine FC, Aggiunta del 5 ottobre 2026.
Prima parte, **nessun rosso si consegna**: le sei rosse ereditate curate con la cura (3) scelta dal
fondatore (la FC.07), le due rosse che avevo portato io con la prova del
tetto curate passando dalla porta comune dei sorgenti, e i dieci rossi del
corredo a scala 1,3 curati nel codice (il distintivo del Sole del Risveglio,
la custodia del cielo, la tendina della galleria VIP, la barra che si ritira
della sua altezza vera): il registro dei rossi accettati non ha piu' righe.
Seconda parte, **il cancello esegue tutto**: il cancello eseguiva gia' tutti i 1248 file, ma 11 casi si
saltavano a ogni giro e il suo numero contava solo le passate. Le sei
anteprime girano sempre e scrivono solo a richiesta; i cinque casi col
modello vero stanno fra gli strumenti (`tool/banchi_col_modello/`), perche'
chiamano Gemini, costano e misurano il modello e non il ramo; cinque prove
che potevano saltarsi da sole lo pretendono adesso; lo sbarramento conta
passate, rosse e saltate di ogni pezzo e cade se un caso e' saltato; il
server scrive il rapporto spec, che nomina le sue cadute. **Resta da vedere
il cancello su GitHub coi numeri nuovi**: per questo la voce aspetta la
verifica, e si chiude nella riga in coda al rapporto con i numeri del giro.

DOMANDA: "Il cancello su GitHub deve eseguire tutte le prove del ramo, non una parte [...] dichiara nel rapporto il numero di prove eseguite dal cancello prima e dopo la cura, più il numero di prove che esistono sul ramo. I tre numeri devono coincidere dopo."
PROVA: test/il_cancello_esegue_tutte_le_prove_test.dart
MISURA: casi eseguiti dal cancello prima 6692 (6685 passati e 7 rossi, giro 37215562849) su 6703 casi del ramo, 11 saltati; dopo, i casi del cancello e quelli della suite intera locale sullo stesso commit, scritti nella riga in coda al rapporto; rossi accettati prima 12 righe per 17 prove, dopo 0; file di prova che si saltano da soli prima 6, dopo 0
ACCETTAZIONE: il verde di GitHub dice quanti casi ha eseguito, sono tutti quelli del ramo, e nessuno e' rosso
