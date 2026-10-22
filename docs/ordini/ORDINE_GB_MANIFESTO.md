# MANIFESTO DELL'ORDINE GB, L'OROSCOPO SI APRE SENZA CONGELARSI, TUTTI I FILMATI SI SALTANO, LE STESE RICALCOLATE E LE CURE DEL RAPPORTO GA

Testo dell'ordine, parola per parola: `D:\Clienti Roogly\Rituali Cartomanzia\App\ORDINE_GB_Esoteric_Circle.md`.
Rapporto: `docs/ordini/RAPPORTO_ORDINE_GB.md`. Una voce CHIUSA porta sotto di se'
DOMANDA, PROVA e MISURA; una voce APERTA dice che cosa aspetta e porta le sue
prove; una voce DA FARE non e' ancora cominciata o non e' ancora a prova. **In
quest'ordine nessuna voce e' CHIUSA**: ogni funzione toccata aspetta la
simulazione da persona (FZ.09) e quella del bambino (GA.09) sul Realme, che
l'ordine chiede per ogni voce, e la build di questa consegna non e' ancora
stata provata a video. GB.01 e' una premessa caduta (si veda sotto); GB.10 e'
un divieto dichiarato, senza lavoro.

VOCI_TOTALI: 13
VOCI_CHIUSE: 0
VOCI_APERTE: 11
VOCI_DA_FARE: 0
VOCI_PREMESSA_CADUTA: 1
VOCI_DIVIETO: 1

## VOCE GB.01

**PREMESSA CADUTA.** Il fondatore, nella stessa conversazione che ha aperto
questo ordine, ha confermato che il congelamento dell'Oroscopo era gia' stato
curato dall'ordine precedente (GA.14 e la voce GB.02 di questo stesso
ordine): *"Il congelamento è già stato curato dall'ordine precedente. Puoi
ignorare la voce"*. Nessuna misura nuova e' stata presa: l'account di
collaudo sul Realme non ha una carta natale completa (soloSegno), quindi il
calcolo pesante che la voce indagava (aspetti, transiti, case) non entra mai
in gioco su quell'account, ed e' la stessa ragione per cui la voce GA.15
era rimasta aperta. Nessun lavoro svolto su questa voce.

## VOCE GB.02

**APERTA IN ATTESA DI VERIFICA.** Ogni scena si salta anche scorrendo, non
solo col tocco secco: `IlToccoCheSalta` (il punto unico dell'ordine FU.15,
dieci schermate) risponde ora a `onVerticalDragStart` e
`onHorizontalDragStart` oltre a `onTap`. La ruota dell'Oroscopo si vede per
intero una volta al giorno: `LaRuotaDiOggi` tiene la memoria del giorno
civile (disco, persistente fra sessioni) e una memoria di sessione sincrona
(`vistaOggiSubito`, scaldata da `segna()`), che la schermata usa per
decidere sul colpo se avviare il video o fermarlo subito con
`RegiaDellaScena.fermaSubito` (mai un `await` davanti all'avvio: un giro
del disco prima dell'avvio faceva cadere dodici prove della scena che
misurano l'apertura al centesimo di secondo, trovato e corretto nello stesso
giro di lavoro, commit `60a82d00`).

DOMANDA: "bisogna fare in modo che con un click il video possa sparire in
dissolvenza [...] e la regola dei filmati di scena all'inizio delle
funzionalità: si saltano al semplice tap o con scrolling"
PROVA: `test/ogni_scena_si_salta_anche_scorrendo_test.dart`,
`test/la_ruota_si_vede_una_volta_al_giorno_test.dart`
MISURA: funzioni con filmato d'ingresso che rispondono anche allo
scorrimento, da 0 a 10 su 10 (`test/ogni_scena_si_salta_col_tocco_test.dart`
le elenca tutte); fotogrammi persi all'apertura dell'Oroscopo dopo la
correzione della regressione, 0 su 13 prove della scena

ASPETTA: la simulazione da persona e quella del bambino sul Realme, build di questa consegna.

## VOCE GB.03

**APERTA IN ATTESA DI VERIFICA.** La caccia agli altri blocchi: dodici
funzioni attive misurate sul Realme, build di rilascio, stesso account e
stessa rete, con lo stesso metodo dell'Oroscopo (logcat Choreographer, due
tocchi per funzione, riportata la peggiore). Nessuna ha perso fotogrammi
all'apertura: tutte alla pari col riferimento (l'Oroscopo gia' curato).
Nessun altro blocco paragonabile al vecchio Oroscopo prima della cura e'
stato trovato.

DOMANDA: "Bisogna risolvere e indagare se c'è qualche altro problema"
PROVA: `docs/collaudo/GB/gb03_tabella_tempi.md`
MISURA: funzioni misurate 12, sopra soglia 0, fotogrammi persi in ognuna 0

ASPETTA: nessuna cura da verificare, perche' nessun difetto e' stato trovato. Resta la conferma che la misura vale ancora sulla build finale di questa consegna.

## VOCE GB.04

**APERTA IN ATTESA DI VERIFICA.** Il costo delle stese torna a separare la
Croce Celtica dalle altre: `tool/i_limiti_degli_annuali.py` non usa piu' un
costo uniforme (il vecchio `STESA`, 1950 gettoni "per ogni piano, prudente")
ma `STESA_PICCOLA` e `STESA_DIECI`, misurati sul testo vero che
`LaLetturaDellaStesa` costruisce (nessuna chiamata al modello, R2), con la
proposta del fondatore applicata (una stesa da dieci al giorno, le altre da
quattro carte). Col metodo nuovo, sei stese all'Adepto restano al 30,8 per
cento mensile e al 31,2 annuale; dieci all'Illuminato al 31,3 e al 31,6:
sopra il tetto del 30 per cento in ogni ciclo. Il numero sicuro per entrambi
i cicli resta quello di oggi, 3, 3 e 5: nessun numero e' cambiato nella
matrice del telefono ne' nel server.

DOMANDA: "potrebbe essere una soluzione limitare 1 sola stesa a 10 carte al
giorno?"
PROVA: `test/gb04_la_misura_della_richiesta_segue_il_codice_vero_test.dart`,
`test/i_limiti_degli_annuali_test.dart`, `docs/costi/i_limiti_degli_annuali.txt`
MISURA: costo di una stesa fino a quattro carte da 0,00203 (uniforme) a
0,00209 dollari; costo della Croce Celtica da 0,00203 a 0,00240; con sei
stese l'Adepto arriverebbe al 30,8 per cento mensile (sopra il tetto del
30); numero sicuro per entrambi i cicli, invariato, 3, 3 e 5

ASPETTA: la decisione del fondatore se cambiare il prezzo dei piani per aprire spazio a 6 e 10 (non e' un conto diverso che li fa entrare: la stesa costa quello che costa).

## VOCE GB.05

**APERTA IN ATTESA DI VERIFICA.** La carta "Hai chiesto a..." filtra per
Maestro. `IlFiloInCima.siMostra` mostrava la scheda in qualunque chat non
fosse quella del Maestro a cui la domanda era stata posta, anche se quel
Maestro non aveva mai fatto parte del consulto: nella chat di Aura
compariva "Hai chiesto a Calìgo" di un consulto che Aura non aveva mai
toccato. Ora la scheda compare solo nella chat di un Maestro che e'
davvero coinvolto (la domanda gli e' stata posta, o ha gia' detto il suo
parere).

DOMANDA: "la carta non filtra per Maestro" (rapporto GA, punto 5)
PROVA: `test/il_filo_in_cima_test.dart`
MISURA: prova con due Maestri e due domande, prima e dopo: nella chat di un
Maestro mai coinvolto nel consulto, la scheda compariva sempre (difetto),
ora non compare mai; nella chat di un Maestro che ha davvero risposto, la
scheda compare con i pareri veri

ASPETTA: la simulazione da persona e quella del bambino sul Realme, build di questa consegna.

## VOCE GB.06

**APERTA IN ATTESA DI VERIFICA.** Il limite delle domande ai Maestri ha
un'uscita. Il messaggio "le domande di oggi sono finite" non aveva nessun
pulsante, nessun prezzo, nessun invito ai piani. `ChatBubble` mostra ora,
sotto il testo (diverso per ogni Maestro, non toccato), lo stesso pulsante
per tutti e tre: apre l'invito gia' usato dalla schermata Chiedi
(`showUpgradeInvite`), col prezzo del riscatto letto dal server attraverso
`corredoDelRiscatto`, mai scritto a mano.

DOMANDA: "il messaggio non ha pulsante ne' il prezzo (80 Eos) ne' un invito
ai piani, e ogni Maestro dice una frase diversa" (rapporto GA, punto 6)
PROVA: `test/gb06_il_limite_ha_una_uscita_test.dart`
MISURA: Maestri col pulsante dell'uscita, da 0 a 3 su 3; prezzo mostrato
letto dal server (80 Eos nella prova, con un server finto che lo dichiara),
mai scritto a mano nel codice del pulsante

ASPETTA: la simulazione da persona e quella del bambino sul Realme, build di questa consegna.

## VOCE GB.07

**APERTA IN ATTESA DI VERIFICA.** "Quel giorno" riapre la conversazione
vera e dice l'anno. La rotta mostrava solo il titolo e il riferimento del
turno, mai la conversazione vera, e nessuna data. `MaestroChatScreen`
riceve ora `apriConversazioneId`: il controllore apre quella conversazione
come ultimo passo del proprio `init()` (mai in gara con la conversazione
nuova, che altrimenti la sovrascriveva: difetto trovato e corretto nello
stesso giro di lavoro), e una striscia dice la data con l'anno attraverso
`LinguaDegliEventi.dataConAnno`.

DOMANDA: "il Diario si riapre in 'Quel giorno' senza la chat; non ha l'anno"
(rapporto GA, punto 7)
PROVA: `test/gb07_quel_giorno_riapre_la_conversazione_test.dart`
MISURA: messaggi veri della conversazione mostrati dopo la riapertura, da 0
(solo titolo e riferimento) a tutti quelli della conversazione di quel
giorno; anno mostrato nella striscia, da assente a presente ("27 agosto
2025" nella prova)

ASPETTA: la simulazione da persona e quella del bambino sul Realme, build di questa consegna.

## VOCE GB.08

**APERTA IN ATTESA DI VERIFICA.** Crashlytics su iPhone, la prova che
segnala. Nuovo `ProvaCrashlytics`, dietro `kProvaCrashlyticsAttiva` (spento,
stesso disegno di `kDiagnosiAttiva` in `briciole.dart`): quando acceso a
mano, manda un errore di prova non fatale una sola volta per installazione,
solo su iOS. Guardia gemella che fa cadere il verde se il flag resta acceso
per distrazione in una consegna ordinaria.

DOMANDA: "Crashlytics su iPhone tace da settembre: o l'app non cade, o non
segnala. Non ho modo di distinguere i due casi da qui" (rapporto GA, punto 8)
PROVA: `test/la_consegna_parte_senza_la_prova_di_crashlytics_test.dart`
MISURA: il flag `kProvaCrashlyticsAttiva` e' spento in questa consegna (0,
non 1); la guardia cade se qualcuno lo accende per distrazione

ASPETTA: **PASSO MANUALE DEL FONDATORE** (numerato nel rapporto): accendere il flag a mano, fare una build, installarla su TestFlight, aprire l'app una volta sull'iPhone, guardare Crashlytics dopo qualche minuto, poi rispegnere il flag.

## VOCE GB.09

**APERTA IN ATTESA DI VERIFICA.** Il dominio Fortuna non parla piu' di
relazioni. La settima casa della Fortuna diceva "Fortuna in coppia", con un
titolo e tre righe sull'aiuto di "chi ti sta accanto": lettura ambigua con
l'Amore. Riscritta in `docs/corpus/oroscopo.md` come alleanza di lavoro o
d'affari (un socio, un collega, un progetto), senza toccare nessun altro
dominio e senza chiamare il modello (R2). Lo strumento di rigenerazione
(`tool/_gen_oroscopo.py`) produce oggi un testo diverso byte per byte dal
file committato per sola formattazione delle liste, non per contenuto: un
difetto a parte, segnalato qui e non curato in questa voce.

DOMANDA: "Il dominio 'Fortuna' dell'Oroscopo parla di relazioni e occasioni"
(rapporto GA, punto 12)
PROVA: `test/gb09_la_fortuna_non_parla_di_relazioni_test.dart`,
`test/le_ancore_dell_oroscopo_test.dart`
MISURA: testi della Fortuna con parole di relazione, da 1 (casa 7, "in
coppia") a 0 su 72 testi letti; testi con temi delicati (ordine S voce 17),
0 su 72, prima e dopo

ASPETTA: la simulazione da persona e quella del bambino sul Realme (vedere davvero una scheda Fortuna con la casa 7 attiva), build di questa consegna.

## VOCE GB.10

**DIVIETO DICHIARATO, NESSUN LAVORO SVOLTO.** Il fondatore, 22 ottobre 2026:
*"per ora lasciamo così il respiro della luna, la faccio valutare ai
fondatori"*. Il Respiro della Luna e la Collana delle Lune non sono stati
toccati, a parte la data mostrata (voce GB.11, un'eccezione scoped e gia'
approvata dal fondatore nel rapporto GA, "Ok per tutto"). Le funzioni del
server del Respiro restano esportate.

## VOCE GB.11

**APERTA IN ATTESA DI VERIFICA.** Una sola data per la Luna piena e la Luna
nuova. Il Calendario degli eventi mostrava il giorno in cui la finestra
d'illuminazione si apre (24 ottobre, 7 novembre), il Respiro della Luna e
la Collana il picco esatto della stessa Luna (26 ottobre, 9 novembre,
`IlMotoreLunare.lunePieneFra`/`luneNuoveFra`): due letture dello stesso
evento. `ProssimiEventi` (la fonte del Calendario) corregge ora, dopo la
scansione che trova quale evento e in che finestra cercare, solo la data
di `luna_piena` e `luna_nuova` al picco esatto della stessa fonte che il
Respiro usa gia': una fonte sola, non due calcoli che per caso coincidono.
Gli altri eventi della Luna (nel segno, primo e ultimo quarto) restano
datati al giorno in cui cominciano, come l'ordine DS voce 08 chiedeva. Il
Respiro della Luna e la Collana non sono stati toccati (GB.10): leggevano
gia' il picco esatto da `IlMotoreLunare`.

DOMANDA: "Il Calendario degli eventi e il Respiro della Luna dicono la
stessa data: quella del picco esatto della Luna piena e della Luna nuova
(26 ottobre e 9 novembre)"
PROVA: `test/gb11_una_sola_data_per_la_luna_test.dart`
MISURA: Lune piene confrontate col picco esatto di `IlMotoreLunare`, 11 su
11 uguali; Lune nuove, 11 su 11; la Luna piena di fine ottobre data al 26
ottobre (non piu' al 24), la Luna nuova di inizio novembre al 9 novembre
(non piu' al 7)

ASPETTA: la simulazione da persona e quella del bambino sul Realme (il Calendario degli eventi e il Respiro della Luna fianco a fianco), build di questa consegna.

## VOCE GB.12

**APERTA IN ATTESA DI VERIFICA.** I versetti di Martini tengono la virgola.
La guardia che la fa valere (`test/language_rule_test.dart`, raccolta
`salmi_martini`) esisteva gia' dall'ordine GA; qui la regola permanente
entra in CLAUDE.md con le parole del fondatore e il punto unico da cui la
guardia la legge.

DOMANDA: "confermo eccezione" (sulla virgola prima di "e" nei versetti di
Martini, Passigli 1842, citati alla lettera)
PROVA: `test/language_rule_test.dart`, `CLAUDE.md`
MISURA: l'eccezione e' scritta in CLAUDE.md, da assente a presente; la
guardia resta verde, le stesse 9 prove di prima e dopo

ASPETTA: nessuna verifica a video: e' una regola di codice e di documento, non una schermata.

## VOCE GB.13

**APERTA IN ATTESA DI VERIFICA.** La consegna: manifesto, guardia del
manifesto, rapporto, STATO_VIVO, registro delle guardie aggiornati (da 880
a 883). CLAUDE.md porta le regole permanenti di GB.02 e GB.12. Nessun
numero e' cambiato nel server in questo ordine (GB.04 conclude che i
numeri restano quelli di oggi): nessuna pubblicazione delle funzioni da
fare. R3: nessuna build per i tester in questo ordine.

DOMANDA: "In locale solo le prove della voce e le guardie della zona
toccata; la suite intera sul cancello di GitHub. L'ordine si consegna solo
col verde di GitHub. Nessuna build per i tester"
PROVA: `docs/ordini/RAPPORTO_ORDINE_GB.md`
MISURA: voci chiuse 0 su 13, aperte 10, da fare 0, premessa caduta 1,
divieto 1; guardie nel registro da 880 a 883

ASPETTA: il verde di GitHub sul commit consegnato, e la simulazione da persona e quella del bambino sul Realme per ogni funzione toccata (GB.02, GB.05, GB.06, GB.07, GB.09, GB.11).
