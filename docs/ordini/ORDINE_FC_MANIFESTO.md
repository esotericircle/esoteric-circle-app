# ORDINE FC, L'OROSCOPO UNIVERSALE, UNA PORTA SOLA E IL VERDE CHE DICE IL VERO

**Sigla:** FC. **Data dell'ordine:** 4 ottobre 2026, tre pezzi e un'Aggiunta (la voce FC.09). **Ramo:**
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

VOCI_TOTALI: 9
VOCI_CHIUSE: 8
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

**APERTA.** Delle sette rosse ereditate una e' chiusa e sei restano rosse,
DICHIARATE: nessuna si cancella e nessuna si allenta, e tutte e sette sono
rosse dalla nascita, volute dal loro ordine e scritte fra i rossi accettati
di `tool/rossi_accettati.txt`.

- **ACCELERA, chiusa.** La sua voce aperta, ACCELERA.03, aspettava la prima
  consegna col verdetto di GitHub: era arrivata con la 2287 il 28 settembre
  2026 e nessuno aveva aggiornato il manifesto. Rossa dal 26 settembre 2026
  (commit `91c21317`). Cura (1), il lavoro era fatto: il manifesto porta la
  chiusura con la prova ricalcolata dal registro delle versioni.
- **CR.13, rossa dichiarata** dal 6 settembre 2026 (commit `6734d8c3`):
  pretende che le soglie della scansione a quattro pose siano misurate su un
  telefono. Cura (1), la guardia ha ragione: serve il fondatore davanti al
  Realme che gira la testa, coi valori letti da una riga di registro; nessun
  agente puo' farlo da solo.
- **EI, rossa dichiarata** dal 23 settembre 2026 (commit `83084b8b`): EI.10
  aspetta il soffio vero del fondatore sul Soffio del Destino.
- **EJ, rossa dichiarata** dal 24 settembre 2026 (commit `8aa44dcd`): sette
  voci aspettano il giudizio del fondatore (il selettore delle voci, i
  mezzibusti, Calìgo all'orecchio, lo stato d'oro della pastiglia) o un
  bersaglio non ancora raggiunto (le risposte dirette).
- **EK, rossa dichiarata** dal 24 settembre 2026 (commit `9100412c`): il
  controllo dopo la risposta aspetta la scelta del fondatore, i volti il suo
  sguardo.
- **EM, rossa dichiarata** dal 25 settembre 2026 (commit `55ab1bda`): quattro
  voci aspettano che il fondatore aggiunga l'account del Realme ai fondatori
  del LIVE dalla console (Code non scrive dati di produzione), una la
  televisione vera, una (EM.11) ha gia' il suo no e prosegue in altri ordini.
- **EN, rossa dichiarata** dal 25 settembre 2026 (commit `201ac46f`): l'attesa
  del LIVE (il fondatore ha detto che deve diminuire), la cornice del volto,
  il testo della risposta delle 09:54 che vive solo nella sua chat.

La forma usata dalle guardie dall'ordine EQ in poi (le aperte dichiarate e
non pretese a zero) per queste cinque sarebbe la cura (3), e contraddice la
REGOLA G del fondatore (un ordine e' finito solo con zero voci aperte): non
si applica senza un suo si'.

DOMANDA: "Il fatto: sulla testa del ramo la suite intera ha sette prove rosse ereditate, e nessun rapporto le aveva mai dichiarate"
PROVA: docs/collaudo/ACCELERA/le_consegne_col_cancello_di_github.txt
MISURA: rosse ereditate prima 7, dopo 6; ognuna con la data e il commit in cui lo e' diventata, e con cio' che serve per chiuderla
ACCETTAZIONE: nel rapporto leggo per ognuna delle sette rosse cosa pretende, da quando e' rossa e cosa serve per chiuderla

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
stessa sera. La prima stesura era una riga in cima alla rubrica che portava
al Cerchio, senza chiamare la tendina; guardandola il fondatore ha chiesto
due pulsanti invece di un'altra schermata. Adesso in cima a "I tuoi amici"
ci sono **Offline** a sinistra e **Online** a destra, col numero degli amici
online e il cerchietto verde (pieno quando qualcuno c'e', velato quando
nessuno c'e' o il numero non si sa). **Di default e' scelto Offline**, gli
amici scritti dalla persona come prima; **Online** mostra gli amici del
Cerchio presenti adesso, con la stessa riga della tendina (`AmicoPresente`,
resa pubblica e scritta una volta), e sotto la strada al Cerchio intero;
senza nessuno nel Cerchio, l'invito. Il codice sta in
`lib/features/amici/gli_amici_online.dart`; la riga di prima
(`il_ponte_verso_il_cerchio.dart`) e' tolta.

**IL COSTO, CHE LA PRIMA FORMA NON AVEVA.** Il numero e l'elenco vengono
dalla tendina del Cerchio: la rubrica la chiede **al piu' una volta per
apertura**, e mai quando la tendina ha meno di un minuto (si riusa), quando
nel Cerchio non c'e' nessuno (il numero e' zero, ed e' vero) o quando il
Cerchio e' chiuso per eta'. Una chiamata legge 5 documenti (misurati dalla
guardia `la_tendina_non_supera_dieci_letture`) e ne scrive 1 (il tetto della
porta): circa **0,0000027 euro, 0,27 centesimi ogni mille aperture**. E' una
deroga alla regola R14 chiesta dal fondatore con le sue parole, e la scrivo
qui per esteso. Il riuso di un minuto tiene la rubrica lontana dal tetto
della tendina, trenta chiamate l'ora. **Nessuno zero inventato**: senza la
tendina accanto a Online non c'e' un numero, e l'elenco dice che il Cerchio
non risponde, con Riprova.

**Le due rubriche restano due**: il selettore le mette sotto lo stesso
titolo, non le fonde. Il verso contrario, dal Cerchio alla rubrica delle
schede, oggi non esiste; non si costruisce qui. I testi nuovi ("I tuoi amici
del Cerchio che sono qui adesso.", la riga del silenzio) sono segnaposto
dichiarati: li scrive l'Architetto; gli altri sono quelli gia' in uso nella
tendina e nell'invito.

DOMANDA: "in amico vorrei che comparissero anche gli amici online"; e poi "inserire 2 pulsanti: a sinistra offline e a destra online con a fianco il numero di amici online e un cerchietto verde. Di default è selezionato il pulsante offline che mostra gli amici creati dall'utente e se clicca su online compaiono gli amici online."
PROVA: test/il_cerchio_si_vede_dalla_rubrica_test.dart
MISURA: amici online visibili dalla rubrica prima 0 (la rubrica mostrava solo le schede), dopo 1 su 1 nella prova (Stella Lieve su Online, nascosta su Offline); pulsante scelto all'apertura Offline; chiamate della tendina all'apertura: 0 con la tendina fresca, 1 senza tendina, 0 riaperta subito dopo, 1 con la tendina vecchia di due minuti, 0 senza amici nel Cerchio (numero 0); col Cerchio che non risponde nessun numero; catture in docs/preview/prima_dopo/fc09_rubrica_offline_dopo.png, fc09_rubrica_online_dopo.png, fc09_rubrica_online_nessuno_nel_cerchio_dopo.png
ACCETTAZIONE: aprendo "I tuoi amici" vedo Offline scelto coi miei amici e, accanto a Online, quanti amici sono online col cerchietto verde; toccando Online compaiono loro, e toccando uno di loro si apre la sua scheda
