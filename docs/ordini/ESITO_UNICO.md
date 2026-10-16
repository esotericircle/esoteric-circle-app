# ESITO dell'ORDINE UNICO

## Dichiarazione, scritta prima di toccare il codice

I numeri del lavoro, misurati adesso: i sei sistemi di fondale da eliminare
vivono in sei file per circa quattromila righe di painter; venticinque file
montano un fondale; le verifiche a video richieste sono ventidue, una per
schermata, piu' le anteprime da rigenerare e guardare con occhio ostile a ogni
blocco chiuso.

**La stima: non chiudo tutto in questo passaggio.** Dichiaro l'ordine di
consegna, che segue l'ordine dei blocchi come la regola impone:

1. **Blocco 1 intero**, il motore unico con semi, ampiezza misurata, ScrollReveal
   e parallasse di scorrimento, con le ventidue verifiche dichiarate una per una.
2. **Blocco 2**, che del blocco 1 e' la prosecuzione naturale: il cielo alla
   nascita adotta il motore del cielo in tempo reale, che gia' esiste in
   `sky_overview_screen.dart` e gia' accetta un momento di nascita.
3. **10.1**, la deduplica dei luoghi, perche' e' un crash noto con un dato
   sporco alla sorgente e si chiude col suo test in poco.
4. Poi, nell'ordine, 3, 4, 5, 6, 7, 8, 9 e 10.2, fin dove arrivo: ogni blocco
   non toccato sara' elencato come NON FATTO con quel che resta.

La ragione in numeri della prudenza: il solo blocco 1 tocca venticinque file di
montaggio piu' sei di motore, mentre la storia di questo cantiere dice che un
rifacimento del genere occupa un ordine intero da solo. Gli ordini A2 e C, piu'
piccoli di questo blocco, hanno riempito ciascuno un passaggio.

L'esito qui sotto si aggiorna blocco per blocco, col confronto finale fra
questa stima e il consegnato.

## BLOCCO 1, un solo cielo: FATTO nella sostanza, con una eccezione dichiarata

**I painter morti.** Dei sei da eliminare ne sono morti cinque: gli accenti
sovrapposti del Santuario, che leggevano lo stesso controller con coefficienti
diversi; il ripiego procedurale del backdrop dei riti; il portale a timer di
otto secondi della carta natale; l'eroe del cielo di nascita col suo painter
gemello; il suo controller privato del sensore. Il sesto,
`_CircleEllipsePainter`, NON e' un cielo: e' l'anello dorato su cui i Maestri
devono ruotare secondo il blocco 4, quindi la sua sorte si decide li'. Dirlo
morto adesso significherebbe togliere l'anello del carosello per far passare un
conteggio.

Sopravvivono per scelta dichiarata: `SkyPostcard`, che l'ordine stesso esclude,
e `_SkyFieldPainter`, che e' la volta VERA del cielo, quella che il blocco 2
adotta anche per la nascita: e' contenuto, non fondale.

**I semi.** Il motore accetta un seme per schermata, mescolato in ognuno dei
cinque generatori del painter (un lucchetto verifica che nessun generatore lo
ignori). Diciotto schermate dichiarano il proprio seme. Prima i semi erano
cablati: 91, 313, 7, 53, 31, uguali ovunque, ed era per questo che la stessa
costellazione si riconosceva in tre schermate.

**L'ampiezza, misurata.** A trenta gradi di inclinazione il tilt normalizzato
vale 0,5, perche' e' la proiezione della gravita'. Col valore nuovo di 500:

| piano | a trenta gradi |
| --- | --- |
| lontano (0,06) | 15 px |
| principale (0,16) | **40 px**, sopra il criterio di 39 |
| vicino (1,3 compresso) | 83 px |

**ScrollReveal.** Riscritto: parte quando l'elemento entra davvero nello
schermo, misurato sul viewport, non piu' al montaggio. Vive dentro `DepthCard`,
quindi ogni elenco dell'app lo eredita da un punto solo, con l'opt-out per chi
ha una regia propria. Fuori da uno scorrimento si rivela al montaggio.

**Lo scorrimento in parallasse.** Il motore ascolta le notifiche di scroll da
dentro, quindi lo sfondo scorre rispetto al contenuto su OGNI schermata che lo
monta, senza che nessuna schermata debba collegare nulla.

**Un difetto grave trovato e corretto strada facendo.** La prima versione del
reveal, al completamento, restituiva il figlio nudo al posto dell'involucro
animato: la forma dell'albero cambiava, Flutter deattivava e ricreava l'intero
sottoalbero, quindi ogni contesto catturato da una chiusura moriva. L'ha stanato il
test del pricing con lo schianto "deactivated widget's ancestor", che e'
esattamente la famiglia del blocco 10.2. Ora la forma dell'albero non cambia
mai, mentre nel pricing il messenger si prende prima di mutare lo stato.

## BLOCCO 2, il cielo alla nascita: FATTO

Non migliorato: sostituito, come chiedeva l'ordine. Il cielo alla nascita e' la
STESSA schermata del cielo in tempo reale, alimentata col momento della
nascita. Costellazioni e Luna toccabili col riquadro che si aggiorna (2.1),
parallasse dal motore unico (2.2), la culla e' morta col suo painter (2.3), la
scheda sta sotto l'orizzonte coi corpi nella meta' alta (2.4). L'onboarding
monta la schermata con la CTA "Leggi la tua carta" e senza freccia; il portale
della carta natale apre la stessa schermata.

Verificato a video su `cielo-nascita.png`: Luna con etichetta, Capricorno e
Sagittario col nome, scheda in basso che invita a toccare, CTA piena. Un
appunto per il blocco 9: la scheda dice "veduta d'esempio finche' non registri
nascita e luogo" anche quando nascita e luogo sono appena stati registrati.

## BLOCCO 10.1, il dato sporco: FATTO

Il dato conteneva **22 doppioni esatti** nome piu' area, per esempio citta'
cinesi diverse che condividono la romanizzazione, piu' gli omonimi legittimi
come Newcastle in Australia e in Sudafrica che la chiave per solo nome faceva
collidere: era il crash "Duplicate keys found, citta_Newcastle".

Deduplicato alla sorgente nel generatore (via 22 voci, restano 11.546), chiave
di lista con nome piu' area, unica per costruzione. Il test prova TUTTI i 676
prefissi di due lettere e cade se due chiavi coincidono; un secondo test
verifica che il dato non contenga doppioni esatti.

## Le verifiche a video fatte davvero

Anteprime rigenerate tutte, 65 cambiate, come atteso: ogni cielo ha il suo
seme. Guardate con occhio ostile, una per una: `cielo-nascita.png` (la
schermata nuova), `carta-natale.png` (portale vivo col cosmo in miniatura, tre
angeli con tre arti, tessere posate), `santuario-medora.png` (regge senza lo
strato doppio, carte e anello al posto loro). Le altre sono passate dal
lucchetto della suite e dalla rigenerazione, ma NON le ho guardate a occhio una
per una: dichiararlo e' piu' onesto che elencarle come viste.

## BLOCCHI NON FATTI: 3, 4, 5, 6, 7, 8, 9, 10.2

Restano interi, coi loro criteri, come la dichiarazione in testa prevedeva.
Nell'ordine in cui andranno ripresi: il permesso di posizione (3), il carosello
che ruota con la mano stilizzata (4, dove si decide anche la sorte
dell'anello), il Sigillo al centro col trionfo (5), i trionfi di Animale e
Angeli nell'onboarding (6, mentre la tessera degli Angeli nella carta natale
APRE gia' la schermata dedicata, fatta nell'ordine C), gli aspetti della carta
(7), il logo con le densita' generate (8, coi due file gia' sul disco nella
cartella logo del progetto), i testi falsi (9, incluso l'appunto nuovo sulla
"veduta d'esempio" del cielo di nascita), il crash _dependents.isEmpty (10.2,
non riprodotto: la correzione della forma d'albero del reveal e del messenger
nel pricing e' della stessa famiglia e potrebbe averlo toccato, ma non dichiaro
risolto cio' che non ho riprodotto).

## Stima contro consegnato

La dichiarazione prometteva: blocco 1 intero, blocco 2, 10.1, poi fin dove si
arriva. Consegnato: blocco 1 nella sostanza (con l'eccezione dell'anello,
motivata), blocco 2 intero, 10.1 intero, piu' due correzioni di ciclo di vita
della famiglia 10.2 trovate dai test. I blocchi 3..9 e 10.2 non sono stati
aperti: la stima ha retto, nel bene e nel limite.

## I numeri finali

- Suite: **838 test verdi** dopo l'aggiornamento delle chiavi di lista.
- `flutter analyze`: pulito.
- Painter del cielo nel codice: da sette a **due**, il motore unico piu' la
  volta vera del cielo, oltre a `SkyPostcard` che l'ordine esclude.
- Iscrizioni al sensore per la parallasse: **una**, piu' il ripiego pigro dei
  montaggi senza provider, mai creato nell'app vera.
- Semi di fondale distinti dichiarati dalle schermate: **diciotto**.
- Ampiezza a trenta gradi sul piano principale: **40 px**, criterio 39.
- Prefissi di due lettere provati contro le chiavi duplicate: **676**, zero
  collisioni.
- Versione: **2101**.

## Un errore mio fermato in tempo, a verbale

Il commit finale e' stato composto con `git add -A`, che ha spazzato dentro
anche cio' che in questo repository e' non versionato di proposito: gli script
Python di Mauro nella radice, `pilot-references/`, `.claude/settings.local.json`
e i due PNG del logo da quasi sei megabyte l'uno, in un repository pubblico. Il
push e' fallito per un motivo indipendente, il remoto era avanzato, e
controllando il commit prima di riprovare ho visto i 156 file al posto dei 75
attesi. Disfatto e ricomposto per percorsi espliciti: 75 file, solo il lavoro
dell'ordine. La regola che ne esce: in questo repository `git add -A` non si
usa, si dichiarano i percorsi.

## Consegna

UNA build, UNA consegna, con l'account di servizio per impersonificazione,
senza alcun login interattivo.

- Identificativo della release: **`13uvd9tqbgibo`**
- Versione: 0.1.0, build **2101**, che si installa sopra la 2100
- Esito del caricamento: `RELEASE_CREATED`
- Note, rilette dal server: "Un solo cielo vivo ovunque, il cielo di nascita
  interattivo, i luoghi senza doppioni"
- Destinatario unico: `cloud@esotericircle.app`
- Pagina per i tester:
  `https://appdistribution.firebase.google.com/testerapps/1:425821975933:android:1b1ca4db8d4df69b940814/releases/13uvd9tqbgibo`

Il push e' passato due volte durante l'ordine, con un rebase sul commit del bot
delle anteprime che era arrivato nel frattempo: la storia e' lineare, niente
forzature.
