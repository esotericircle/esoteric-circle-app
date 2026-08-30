# ORDINE CE, DICIASSETTE VOCI

Ordine del fondatore del 30 agosto 2026, arrivato in tre pezzi. Guardia
`test/ordine_ce_guard_test.dart`.

Porta le tre regole degli ordini precedenti:

- **REGOLA ZERO.** Il testo di quest'ordine non e' affidabile e l'Architetto che
  lo ha scritto non e' affidabile: ogni affermazione si verifica sul ramo prima
  di lavorarci. Parole del fondatore: "qualunque cosa tu rilevi o pensi o scrivi
  sia sempre sbagliata e Code deve controllare tutto, anche se 1+1=2".
- **REGOLA UNO.** Code non si ferma davanti a un ostacolo, risolve.
- **REGOLA DUE.** Le decisioni delegate si prendono e si motivano per iscritto;
  quelle non delegate si riportano come fatti.

## Le diciassette voci

- **CE.01** I consensi in un percorso unico alla registrazione. **CHIUSA.** Un atto solo, il pulsante stesso; la misura del ritorno e' un interruttore separato che nasce spento, perche' un consenso pre-acceso non e' libero.
- **CE.02** Via i due popup dal Santuario. **CHIUSA.** Nessuno dei due fogli esce piu' da li'. La porta a mano nel menu' Account resta, con la ragione scritta.
- **CE.03** Il sotto menu' dedicato. **CHIUSA.** "Privacy e permessi": disclaimer, interruttore della misura, fonti dei dati e permessi di sistema, tutti e quattro dentro, e nelle Impostazioni restano due righe.
- **CE.04** Il conteggio residuo prima del gesto. **CHIUSA.** Tutti e sei i budget hanno una casa sola, `BudgetDelGiorno`, e una prova li enumera: da cinque punti muti su otto si passa a zero.
- **CE.05** Il pulsante di consenso esplicito dove si spendono Eos. **CHIUSA.** La casa unica esiste, si difende dal doppio tocco e paga sull'esito. **Oggi nessun punto dell'app spende Eos**, misurato: la prova che enumera i chiamanti e' la trappola per il primo che nascera'.
- **CE.06** Il borsellino quando gli Eos non bastano. **CHIUSA.** L'avvertenza, i tre pacchetti col loro prezzo e la seconda via, l'abbonamento. Nessun pulsante che finge un acquisto che non avviene.
- **CE.07** I tre prezzi annuali nuovi. **CHIUSA.** 99,90, 189,90 e 279,90, e gli sconti ricalcolati dal prezzo: 16, 21 e 22 per cento invece di 24, 25 e 25.
- **CE.08** L'illimitato si elimina ovunque. **CHIUSA.** Nove celle nell'app e cinque sul server, piu' la logica che traduceva la parola in "nessun tetto". Adesso una cella che dicesse "Illimitato" varrebbe zero.
- **CE.09** I pacchetti di Eos. **CHIUSA.** Tre: 300 Eos a 2,99, 900 a 7,99, 2.500 a 19,99. Nessuno arriva ai 6.030 che il Cammino conia.
- **CE.10** L'uniformazione dei testi da leggere. **APERTA.**
- **CE.11** I 119 titoli gialli. **APERTA.**
- **CE.12** I suggerimenti al primo uso. **APERTA.**
- **CE.13** L'incrocio nei Doni del Giorno. **APERTA.**
- **CE.14** La spirale della festa che non si legge come spirale. **APERTA.**
- **CE.15** Il censimento delle stringhe per la traduzione. **APERTA.**
- **CE.16** Il motore delle eclissi. **APERTA.**
- **CE.17** L'attribuzione automatica dell'invito: studio e rapporto. **APERTA.**

VOCI_TOTALI: 17
VOCI_CHIUSE: 9
VOCI_APERTE: 8
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

## LE AFFERMAZIONI DI QUESTO ORDINE CHE HO TROVATO FALSE

Ventitre' premesse verificate sulla testa del ramo, commit `4f3fdc4`, prima di
toccare una riga.

| # | esito | cosa ho trovato |
| --- | --- | --- |
| P01 | **vera** | testa `4f3fdc4`, "Build 2214 consegnata su App Distribution" |
| P02 | **vera** | "Privacy e dati" con quattro voci in quell'ordine |
| P03 | **vera** | sezione "Permessi" separata, una voce sola, `Geolocator.openAppSettings()` |
| P04 | **vera** | foglio montato dal Santuario, e chi lo chiude senza scegliere se lo ritrova |
| P05 | **vera** | `MemoriaDellInvito.segnaChiesta()` viene chiamata PRIMA di mostrarlo |
| P06 | **vera** | il campo dice "Il codice, o il link intero", e gli appunti si leggono solo sul tocco. **Zero occorrenze della parola email in quel file** |
| P07 | **vera** | `sinastrieRimaste` esiste in `question_allowance.dart:515` e nessun file sotto `lib/features` la legge |
| P08 | **vera al numero** | otto punti che registrano un consumo, contati uno per uno |
| P09 | **vera** | quattro budget dichiarati: domande, approfondimenti, confronti, gettate. Mancano stese e sinastrie |
| P10 | **vera** | `CostoInChiaro` e `SpesaDegliEos` esistono e nessuno li chiama |
| P11 | **vera** | `lettura()` e' `body(size: 18)` con interlinea 1,55, e i due responsi la usano |
| P12 | **VERA A META'** | la Runa del Tramonto usa davvero `body(size: 17)` in due punti. **Ma l'Arcano del Giorno usa gia' `lettura()`** su un testo e `corpo()` su un altro: non e' "l'Arcano usa corpo", e' che ne ha due |
| P14 | **vera** | `docs/tipografia/censimento.md` porta `TOTALE_CENSITO: 225` |
| P15 | **vera** | 89,90, 179,90 e 269,90 in `plan_catalog.dart` |
| P16 | **vera** | l'illimitato vive nella matrice e la logica che lo traduce sta alla riga 217 dello stesso file |
| P17 | **vera** | nessun pacchetto di Eos nel codice |
| P18 | **vera** | il seme dell'Arcano viene da `giorno.year * 10000 + giorno.month * 100 + giorno.day` |
| P19 | **vera** | `angolo: caso.nextDouble() * 2 * math.pi` |
| P20 | **vera** | tre gradini con quella ragione esatta |
| P21 | **vera** | nessun `.arb`, nessuna `lib/l10n` |
| P22 | **vera** | un solo `intent-filter`, MAIN/LAUNCHER, e nessuno dei tre pacchetti |
| P23 | **vera** | `riscattaLInvito` c'e' ed e' distribuita |

**P13 non e' stata verificata prima di CE.10** e lo dichiaro: e' la premessa
sulle schermate che si vedono prima di un responso, ed e' materia di quella
voce. Si verifica li', non qui, perche' verificarla due volte a distanza di
lavoro vorrebbe dire misurarla su un codice diverso.

## LE SCELTE CHE HO PRESO IO E PERCHE'

### CE.01

- **Un solo atto attivo, ed e' il pulsante stesso.** Sopra le vie d'accesso c'e'
  una riga che dice cosa si accetta, col nome della policy toccabile. Premere
  "Continua con Google" e' l'accettazione. E' lecito perche' la privacy policy e
  le condizioni non sono un consenso ai sensi del GDPR: sono un'informativa e un
  contratto. Una casella in piu' sarebbe l'ostacolo che il fondatore ha chiesto
  di togliere, e la legge non la chiede.
- **La misura del ritorno e' l'unica cosa qui dentro che il GDPR chiama
  consenso, e nasce SPENTA.** Un consenso pre-acceso non e' libero e sarebbe
  illecito: il fondatore ha chiesto "la piu' veloce e non invasiva **che
  rispetti le norme**", e questa e' l'unica forma che rispetta tutte e tre le
  parole. Sta nella stessa schermata, quindi non e' un passo in piu' e non e' un
  popup: accenderla costa un tocco.
- **I consensi vivono in UN punto solo**, dentro `VieDellaCustodia`, che e' il
  componente che offre le vie d'accesso in tutte e tre le schermate che le
  mostrano. Montarli accanto a ognuna avrebbe fatto tre copie che divergono.
- **Chi non si registra non viene contato.** L'app si usa per intero senza
  registrarsi e, tolti i due fogli, questa e' l'unica porta dove il consenso si
  puo' dare: chi non passa di li' resta `nonChiesto` e il registro non manda
  niente. E' la scelta piu' veloce, la meno invasiva e l'unica che regge davanti
  alle norme, perche' contare qualcuno che non ha mai avuto modo di dire di no
  sarebbe contare senza consenso.

### CE.02

- **La porta per riscattare a mano RESTA nel menu' Account.** Il fondatore ha
  chiesto di togliere i popup, non ogni strada. Senza quella porta il premio da
  sessanta Eos diventerebbe irraggiungibile anche per chi lo volesse, mentre
  cosi' resta soltanto scomodo. Una prova lo sorveglia.

### CE.03

- **Il nome e' "Privacy e permessi".** Dentro ci sono due famiglie: cosa il
  Cerchio sa di te e cosa puo' toccare del telefono. Un nome piu' elegante che
  dicesse meno avrebbe costretto ad aprirlo per sapere cosa contiene.
- **La collocazione assolve la licenza CC BY 4.0.** Quella licenza pretende che
  l'attribuzione sia RAGGIUNGIBILE, non che stia in prima pagina: due tocchi da
  una schermata di sistema sono il modo in cui ogni app assolve questo obbligo,
  e l'obbligo resta assolto perche' l'elenco delle fonti e' dentro l'app e non
  in un commento del codice, che era il difetto di prima dell'ordine CC.
- **L'ordine interno va dal generale al concreto**: cosa diciamo di noi, cosa
  contiamo, da dove vengono i numeri, cosa tocchiamo del telefono.
- **Due titoli sono stati accorciati dopo aver guardato l'anteprima**: "Cosa il
  Cerchio dice di se'" e "Cosa puo' toccare del telefono" andavano a capo
  lasciando una parola orfana sulla seconda riga. Adesso sono "Cosa diciamo di
  noi" e "Cosa tocca del telefono", e stanno su una riga sola a 360 punti.

### CE.04

- **I sei budget vivono in un elenco, `BudgetDelGiorno`.** Il difetto non era
  che mancasse un conto: era che i sei budget non avessero un posto dove stare
  insieme. Con l'elenco la prova puo' ENUMERARE, e il budget che nasce domani o
  si dichiara o cade.
- **La riga condivisa non e' obbligatoria, il fatto si'.** Due schermate
  leggevano gia' il proprio contatore e lo passavano al pezzo che avevano:
  pretendere una forma sola avrebbe voluto dire riscrivere schermate che il
  fondatore non ha toccato. La prova cerca il fatto, cioe' che il numero si
  veda, non da quale widget esca.
- **La guardia legge il CODICE e non i commenti**, e questa riga nasce da un
  rosso che non e' scattato: tolta la riga del residuo dalla Sinastria, la
  prova restava verde perche' trovava il nome del contatore dentro il commento
  che avevo appena scritto sopra. Una guardia che legge i propri commenti
  misura se stessa.

### CE.07

- **Gli sconti non si scrivono, si calcolano dal prezzo.** Erano 24, 25 e 25
  per cento; col prezzo nuovo sono **16, 21 e 22**, che e' esattamente lo
  "sconto minore" che il fondatore ha chiesto. Il conto e'
  `1 - annuale / (mensile * 12)`. Anche il per-mese e' rifatto.
- **Settimanale e mensile non si toccano**, ed e' un fatto misurato: i numeri
  che il fondatore ha indicato come nuovi erano gia' quelli in vigore.

### CE.08

- **I tetti dell'Illuminato, e la ragione di ognuno.** Domande **50**,
  approfondimenti **30**, confronti **20**, carte singole **50**, gettate
  **50**, sinastrie **25**. Il criterio e' il suo: ampio da non raggiungere con
  uso intensivo, ma un tetto. Ogni numero e' almeno il triplo del piano sotto,
  e nessuno e' avvicinabile da una persona in un giorno: chi fa cinquanta
  gettate in ventiquattro ore e' il bot che lui teme.
- **Anche i piani sotto perdono l'illimitato**: le gettate erano senza tetto
  dall'Iniziato in su, e adesso valgono 20, 30 e 50.
- **La LOGICA e' stata tolta, non solo le parole.** C'era
  `if (cella.contains('illimitat')) return null`, e il nullo ogni chiamante lo
  legge come "nessun tetto": togliere la parola dalle celle avrebbe lasciato la
  porta aperta al primo che la riscrive. Adesso una cella che dicesse
  "Illimitato" cade in fondo alla funzione e vale **zero**: nel dubbio si
  sbaglia dalla parte del tetto, non dell'abuso.
- **Il server per primo.** `functions/src/budget.ts` aveva cinque celle a
  `null`, e il server e' il sovrano: chi chiama la callable direttamente non
  passa da nessuna schermata. Togliere l'illimitato solo dall'app avrebbe
  lasciato il tetto vero aperto.

### CE.05

- **Un fatto misurato che cambia la portata della voce: oggi nessun punto
  dell'app spende Eos.** `SpesaDegliEos.perLaVoce` non ha nessun chiamante
  sotto `lib/features`, e nemmeno `muoviGliEos`. La porta non ripara quindi un
  difetto in vigore: e' la casa che il primo punto che spendera' Eos dovra'
  attraversare, e la prova enumera i chiamanti perche' nessuno nasca fuori.
- **Il doppio tocco si ferma nella porta e non nel chiamante.** Un chiamante
  che se lo dimentica spende due volte: qui il pulsante si spegne al primo
  tocco e torna quando la chiamata e' finita.
- **Il consumo si paga sull'esito.** Se la spesa non riesce, cio' che viene
  dopo non parte e non si addebita niente. E' la stessa legge di
  `CostoDelTurno` sulla chat, verificata: paga solo quando la risposta e'
  arrivata davvero.

### CE.06 e CE.09

- **Tre pacchetti, e non due ne' cinque.** Con due la scelta e' "poco o tanto"
  e chi ha un bisogno medio si pente in tutti e due i casi; con cinque il
  listino diventa un problema da risolvere e chi voleva solo finire una lettura
  abbandona.
- **300, 900 e 2.500 Eos**, commisurati al conio del Cammino, che e' 2.010 per
  sentiero e 6.030 in tutto. Il piccolo tappa un buco, il medio copre una
  settimana, il grande sta appena sotto un sentiero intero. **Nessuno arriva ai
  6.030**, ed e' una scelta: il Cammino deve restare la via piu' ricca.
- **2,99, 7,99 e 19,99 euro**, cioe' da 0,0100 a 0,0080 per Eos: la scala c'e'
  ed e' mite. Uno sconto forte sul grande spingerebbe a comprare scorte invece
  di abbonarsi, e il pacchetto deve restare una comodita' mentre l'abbonamento
  resta la strada.
- **Nessun pulsante che finge.** Gli acquisti veri non sono collegati a nessun
  negozio, e l'ordine dice che in quel caso ci si ferma e lo si dichiara a
  schermo: il borsellino mostra cosa saranno i pacchetti e dice che arrivano con
  la pubblicazione. Una costante sola, `acquistiCollegatiAUnNegozio`, si
  spegnera' il giorno che il negozio esiste.

## IL DEBITO DA CHIUDERE PRIMA DELLA PUBBLICAZIONE

**Nessuno puo' piu' riscuotere il premio dell'invito senza cercarlo.** Con la
voce CE.02 il foglio che lo chiedeva e' sparito, e il fondatore lo ha accettato
per iscritto: "e' una demo per ora, si toglie e accettiamo che per ora nessuno
riscuote i 60 EOS, **ma va sistemato prima della pubblicazione**". La strada
automatica e' materia della voce CE.17, che produce lo studio. Il debito e'
scritto anche in `docs/ordini/RIPRESA.md`, cosi' non lo tiene in vita soltanto
una conversazione.

## CE.01, CE.02 e CE.03, le misure

| misura | prima | dopo |
| --- | ---: | ---: |
| fogli che il Santuario mostra a chi non ha chiesto niente | 2 | **0** |
| punti dell'app dove il consenso alla misura si puo' dare | 1, un foglio | **1**, dentro la registrazione |
| interruttore della misura alla registrazione | non esisteva | nasce **spento** |
| voci nella sezione "Privacy e dati" | 4 | **2** |
| sezioni delle Impostazioni | 6 | **5**, "Permessi" e' entrata nel sotto menu' |
| voci dentro il sotto menu' | 0 | **4** |
| tocchi per arrivare all'attribuzione delle fonti | 1 | **2** |

### Il rosso, dimostrato tre volte

**CE.02.** Rimessa nel Santuario la chiamata a `DomandaDellaMisura.chiedi`,
verificato col grep che il nome ci fosse **prima** di leggere l'esito: la prova
e' diventata rossa dicendo "fogli ancora montati dal Santuario 1". Tolta, verde.

**CE.01.** Fatto nascere acceso l'interruttore della misura, verificato col grep
**prima** di leggere l'esito: la prova e' diventata rossa dicendo
"l'interruttore nasce acceso? true". Rimesso spento, verde.

**CE.03.** Sostituito il disclaimer del sotto menu' con una frase scritta a
mano, verificato col grep che `disclaimerCornice` non ci fosse piu' **prima** di
leggere l'esito: la prova e' diventata rossa dicendo "voci dentro il sotto menu'
3 su 4". Rimesso, verde.

### Le anteprime

`docs/preview/privacy-e-permessi.png` e `impostazioni.png`, a 360 punti,
rigenerate e guardate. La prima ha fatto trovare i due titoli che andavano a
capo male.

### Le frasi di accettazione

**CE.01.** Apri la registrazione: sopra i pulsanti c'e' una riga che dice cosa
accetti, col nome della privacy policy toccabile, e un interruttore spento per
farti contare i gesti. Nessuna finestra, nessun passo in piu'.

**CE.02.** Usa l'app senza registrarti quanto vuoi: non esce piu' nessun foglio
che ti chiede se qualcuno ti ha invitato o se puoi essere contato.

**CE.03.** Impostazioni, Privacy e dati: due righe sole. La prima porta a
Privacy e permessi, e li' dentro c'e' tutto il blocco.
