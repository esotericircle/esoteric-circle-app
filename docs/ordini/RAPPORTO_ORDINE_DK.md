# RAPPORTO DELL'ORDINE DK, LE ULTIME CORREZIONI, LA BUILD E LA PROVA A VIDEO

**Voce DK.08.** 14 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`.
**Build 2250, consegnata** a un solo destinatario, `cloud@esotericircle.app`.
Lo stato voce per voce sta nel manifesto `docs/ordini/ORDINE_DK_MANIFESTO.md`;
le schermate della prova a video stanno in `docs/collaudo/DK/`, un file per
punto.

---

## 1. Che cosa aspetta il fondatore

1. **Il punto 16 non passa.** Fra le risposte del tema *scelta* c'e' *"Chiedi a
   te stesso quale racconterai meglio fra dieci anni."*: sul telefono e'
   uscita all'ottava discesa. Dice a chi legge di essere un uomo. Una riga di
   `lib/core/viaggio/la_voce_del_mondo_di_sotto.dart`, la 286; la proposta e'
   *"Chiediti quale racconterai meglio fra dieci anni."* Non l'ho cambiata:
   la build era gia' costruita e consegnata come l'ordine la chiedeva. Una
   correzione adesso vorrebbe una build nuova che nessuno ha ordinato.
2. **Due azioni dicono due tempi diversi.** *"Dormici una notte e rileggi
   questa riga domattina. Entro stasera."* e *"Datti tre giorni. Alla fine
   scegli comunque. Domani mattina, appena ti alzi."*: il gesto ha gia' il suo
   tempo dentro, mentre il *quando* attaccato dopo lo contraddice. Visti a video, nella
   quarta e nell'ottava risalita.
3. **Il punto 14 passa solo in parte.** La risposta nomina **il tema** della
   domanda, mai la sua persona o la sua cosa. Alla domanda *"Mia sorella non mi
   parla da due anni e non so se cercarla"* il tema e' stato *scelta*. La
   risposta dice *"La paura e' di perdere l'altra, non di prendere questa"*,
   che accanto a una sorella si legge male. Se la risposta deve nominare la
   domanda con le sue parole, e' un lavoro nuovo, non una correzione.
4. **Il punto 7 non l'ho potuto vedere fotogramma per fotogramma**: il
   perche' sta al punto. Il fondatore lo guardi a occhio: e' mezzo secondo alla
   fine del filmato.
5. **I due materiali mancano ancora, come previsto**: il file del tamburo e i
   trentasei disegni dei gesti. Non sono guasti; sotto, al capitolo 6.
6. **Tre righe di lingua** viste leggendo le risalite, fuori dai venti punti:
   al capitolo 5.

---

## 2. Le misure del rito

| misura | valore |
|---|---|
| suite intera, prima della build | 5.131 passate, 2 saltate (le prove col modello vero, senza token), **2 rosse, i due rossi di legge** |
| corredo a scala del testo 1,3 | 167 passate, 15 rosse, tutte e quindici nel registro degli accettati |
| sbarramento | *"ROSSI ACCETTATI, E SOLO QUELLI"*, gettone scritto col numero 2250 e 5.131 prove |
| comando | `flutter build apk --release`, dall'albero a `d213e808` |
| numero letto con `aapt2` dall'archivio | versionCode **2250**, versionName 0.1.0 |
| archivio | 196.990.253 byte, sha1 `7ca209bdd726c67f14a017d0c02b4425efc4e4d8` |
| guardato dentro prima di caricare | 668 voci negli asset, 9 librerie arm64-v8a, 8 famiglie dell'arte, nessuna incompleta |
| prova di accensione | processo vivo, primo fotogramma disegnato, nessun FATAL EXCEPTION, numero letto dal telefono 2250 |
| release | `1m17moklvopao`, RELEASE_CREATED, note rilette dal server |
| destinatario | `cloud@esotericircle.app`, **inviti accettati 1** alla rilettura |
| registro | `docs/versione_distribuita.json` da 2249 a 2250, scritto dalla consegna |

**Due correzioni per arrivare alla build**, gia' nel manifesto alla voce DK.06:
lo sbarramento non leggeva i rossi dopo le prove saltate (padre BZ.02); una
cattura a scala 1,3 toccava un comando rimasto fuori dallo schermo.

---

## 3. La scena dal modello, prima e dopo la voce DK.03

Stessi undici casi della voce DJ.11, col modello vero, cento discese per caso.

| caso | prima | dopo |
|---|---|---|
| Una scelta da fare | 89 | 95 |
| Una persona | 97 | 95 |
| Un blocco che non si supera | 99 | 97 |
| Un tempo che non arriva | 94 | 92 |
| Una direzione da prendere | 77 | 97 |
| Qualcosa che e' finito | 66 | 100 |
| *Mia sorella diventera' presto mamma?* | 78 | 95 |
| *Devo lasciare il mio lavoro per aprire qualcosa di mio?* | 90 | 93 |
| *Perche' con mio padre finisce sempre in lite?* | 93 | 94 |
| *Da mesi non riesco a finire niente di quello che comincio.* | 90 | 95 |
| *Ho chiuso con Luca dopo sei anni, e adesso?* | 97 | 96 |
| **in media** | **88,2** | **95,4** |

I tempi scaduti sono passati da 93 a 4 su 1.100 discese. Sul telefono il
segno col modello ha risposto in circa un secondo e mezzo. La prima domanda
scritta a mano l'ha capita il modello: la tabella di riserva, da sola, non
l'avrebbe capita.

---

## 4. La prova a video, punto per punto

**Il telefono**: Realme RMX3081, Android 13, 1080 per 2400, la build 2250
installata e verificata col numero. **La luminosita' era a meta'**, 2047 su
4095 in manuale: non l'ho toccata. Le tre scale delle animazioni del
telefono sono a zero; nemmeno quelle le ho toccate, sono impostazioni di
sistema.

**Come ho guardato.** Una schermata per ogni punto; per i punti che si muovono
una raffica di schermate scattate dal telefono stesso, una ogni 0,26 secondi,
con la differenza fra un fotogramma e il successivo per sapere quando lo
schermo si muove. Il telefono non ha `screenrecord`. Il registratore di schermo
di sistema non l'ho usato: salva nella galleria personale del telefono e
riprende anche le notifiche. Per la fluidita' ho letto dal compositore di
Android l'istante in cui ogni fotogramma e' andato a schermo. **Il suono non
l'ho sentito**: ho letto da AudioFlinger il volume con cui l'app lo riproduce.

**Lo stato del Viaggio**: a zero discese all'inizio, a zero discese alla
fine. In mezzo nove discese contate, fino al riconoscimento e oltre; alla fine
il comando di demo *"Ricomincia il viaggio"* per rifare la prima discesa del
punto 8, abbandonata senza risalire. Non ho toccato il profilo, l'account o i
dati di nascita.

| # | punto | esito | come si vede |
|---|---|---|---|
| 1 | le tre righe alla prima apertura | **passa** | a zero discese si leggono tutte e tre: dove ti trovi sotto il titolo, cosa stai facendo sopra *Scendi*, cosa otterrai sotto |
| 2 | le quattro impronte in alto, spente, con la frase sotto | **passa** | quattro cerchi spenti e *"Non si e' ancora mostrato, ne mancano quattro."*; dopo tre discese tre impronte della Volpe |
| 3 | il primo fotogramma fermo, mai nero | **passa** | le radici dal primo istante; fermo per cinque secondi senza tocco |
| 4 | il dito muove il filmato, lo rallenta e lo ferma | **passa** | dito alzato a 5,2 s: il moto scende 7,3, 5,3, 5,4, poi zero a 5,72 s, cioe' in circa mezzo secondo; ripremuto risale 4,4, 7,7, 9,3; nessun salto. Il compositore: sessanta fotogrammi al secondo, mai oltre 33 ms fra due fotogrammi mentre il dito si posa e si alza |
| 5 | l'alone sotto il dito si vede e pulsa | **passa** | il cerchio d'oro sta sotto il dito e cambia raggio da un fotogramma all'altro in tutte e tre le pressioni |
| 6 | le radici nel tratto piu' scuro | **passa, con una riserva** | il tratto piu' scuro del filmato e' al secondo 2,08, luminosita' media 13 su 255; sul telefono le radici si staccano dal fondo di 14-23 livelli: nella schermata si vedono. **La riserva**: la schermata non porta con se' la retroilluminazione, mentre l'occhio sul telefono a meta' luminosita' non l'ho |
| 7 | alla fine del filmato la dissolvenza verso la nebbia | **non provabile fotogramma per fotogramma** | in tutte e tre le raffiche il telefono smette di dare schermate per 0,8-2,1 s proprio alla fine del filmato, tutte le catture insieme. **Lo schermo invece non si ferma**: il compositore dice sessanta fotogrammi al secondo per tutto il passaggio, con due soli intervalli lunghi, 66 e 50 ms. Prima c'e' la luce dorata, dopo la nebbia. Da guardare a occhio |
| 8 | *"Salta la discesa"* dopo 1,5 s alla seconda, mai alla prima | **passa** | seconda discesa: assente a 1,44 s, presente a 1,75; prima discesa, dopo *Ricomincia*: dopo cinque secondi c'e' solo *"Tieni premuto per scendere"* |
| 9 | il bordo segue la mano | **passa** | una passata in diagonale scopre una striscia in diagonale |
| 10 | finito il quarto non si scopre piu' niente | **passa** | *"Per oggi hai scostato abbastanza."*; dopo nove passate sul resto del corpo e sulla testa, zero pixel cambiati |
| 11 | la testa resta coperta | **passa** | alla seconda discesa, col quarto intero ancora da spendere, sette passate sulla testa: zero pixel cambiati; una passata sul corpo subito dopo ne scopre 7.555. Alla quarta discesa *"Oggi il velo cade da solo."* |
| 12 | uscendo e rientrando lo scoperto resta scoperto | **passa** | uscita dall'app e rientro: velo identico al pixel. Uscita dal Viaggio a meta' discesa e rientro: identico al pixel. Fra una discesa e la successiva: identico al pixel |
| 13 | titolo, risposta, gesto, da dove viene, in ordine | **passa** | in tutte e nove le risalite |
| 14 | la risposta nomina la domanda, scritta a mano | **passa in parte** | *"Devo lasciare il lavoro in banca per aprire una bottega di ceramica"*: *"La domanda riguardava la scelta."* *"Mia sorella non mi parla da due anni e non so se cercarla"*: di nuovo *"la scelta"*. Nomina il tema, non la domanda: vedi il capitolo 1 |
| 15 | nessuna frase coi due punti annidati | **passa** | nove risalite lette per intero, mai piu' di un due punti in una frase. Nella terza il titolo della voce DK.01, *"E' finito e va bene cosi'"* |
| 16 | col profilo femminile nessun testo al maschile | **non passa** | *"Chiedi a te stesso quale racconterai meglio fra dieci anni."*, a video all'ottava risalita. Il profilo femminile non l'ho impostato: si sceglie solo nell'onboarding e cambiarlo vorrebbe dire toccare l'account del fondatore. **Non serve**: il Viaggio non legge la forma con cui ci si rivolge a chi legge, quindi i suoi testi sono gli stessi per ogni profilo. Ho passato in rassegna tutte le stringhe del Viaggio, trentacinque file: questa e' l'unica che ho trovato |
| 17 | il cursore *"Volume degli effetti"* | **passa, misurato e non udito** | il cursore si muove e resta dove lo si lascia anche dopo la chiusura dell'app. Con l'effetto *carta* della stesa di Medora, AudioFlinger legge **-8 dB col cursore al 40 per cento e 0 dB al 100**: 20 log10 di 0,4 fa -7,96. La musica resta a -4,4 dB, il suo 60 per cento, in tutti e due i casi. Il cursore e' tornato al 100, com'era |
| 18 | spariscono le cose della rivelazione, compaiono le tre azioni | **passa** | niente impronte, niente righe del percorso, niente scelta della domanda; *"La Volpe resta con te"*, *Scendi con una domanda*, *Nutrila*, *Chiedile un segno* |
| 19 | il tamburo nutre e l'animale si avvicina anche muto | **passa** | quaranta colpi: gli anelli si allargano a ogni colpo, la nebbia si dirada, la Volpe si fa grande e vicina. Il tamburo e' muto perche' il file non c'e' |
| 20 | il segno risponde con l'illustrazione e una riga sulla domanda | **passa** | *"Devo accettare il nuovo lavoro a Milano"*: *"Ti sta guardando"*, poi la Volpe si avvicina nell'illustrazione e la riga *"La Volpe si avvicina. Vai avanti per questa nuova opportunita' lavorativa."* |

**Diciassette punti passano, uno passa in parte, uno non passa, uno non si e'
potuto provare fotogramma per fotogramma.**

---

## 5. I difetti trovati e i loro padri

| difetto | dove | padre |
|---|---|---|
| *"Chiedi a te stesso..."* dice a chi legge di essere un uomo | `la_voce_del_mondo_di_sotto.dart:286`, risposte del tema *scelta* | **DG.07**, commit `6691242e`. **La guardia non l'ha visto** perche' cerca un verbo seguito da un participio o da un aggettivo, *sei stanco*, *essere sicuro*, mentre il riflessivo *te stesso* non ha verbo davanti: la forma della guardia e' della voce **DI.05** |
| il gesto e il suo *quando* dicono due tempi | `cosaPuoiFare` righe 425 e 434 con l'elenco `quando` | **DG.07**, `6691242e`. La regola della voce DI.05 impedisce al *quando* di ripetere l'apertura, non di contraddire il gesto |
| *"Chiudila piano. Poi non tornarci a controllare. Prendilo cosi'."*: femminile e maschile sulla stessa cosa, *qualcosa che e' finito* | riga 363 con la coda della riga 386 | **DG.07**, `6691242e` |
| **saltando la discesa le radici spariscono di colpo** e a svanire nella nebbia e' il tunnel di riserva: *"cio' che svanisce e' cio' che si stava guardando"*, dice il commento, ma qui non e' cosi'. Fuori dai venti punti, visto nella raffica del salto | `_cioCheSiStavaGuardando` in `viaggio_dello_sciamano_screen.dart` | **DI.09** |

Visti e lasciati, perche' non sono difetti: la card della rivelazione dice
*"MI HA TROVATO VOLPE"*, senza articolo, come un nome proprio. Se il fondatore
lo vuole con l'articolo, e' una riga.

---

## 6. Le due cose che mancano e non sono guasti

- **Il file del tamburo**, `assets/audio/mondo_di_sotto/tamburo_discesa.mp3`:
  la discesa e il nutrimento restano muti. A video il nutrimento funziona lo
  stesso, punto 19.
- **I trentasei disegni dei gesti**, `assets/img/mondo_di_sotto/gesti/`,
  un file per animale e per gesto: il segno risponde con l'illustrazione
  intera che si muove, punto 20.

Le cartelle ci sono, ognuna col suo `LEGGIMI.md` che dice nomi e misure dei
file attesi.

---

## 7. I file di `docs/` toccati dalla voce DK.04

Uno solo, `docs/02_Briefing_Progetto_Definitivo.md`. I briefing 01, 03 e 04 non
citavano la Domanda al Maestro reale. Nient'altro e' cambiato nel file.

| riga | tolto |
|---|---|
| 307 | *", Maestro reale"*, in fondo alla cella del Tier 3 |
| 315 | *"una domanda al mese al Maestro reale con risposta entro quarantotto ore (ponte verso i consulti premium); "* |
| 343 | la riga intera *"\| Domanda al Maestro reale \| No \| No \| No \| 1/mese \|"* |
| 497 | *"Maestro reale, "*, nella riga del Tier 3 |
