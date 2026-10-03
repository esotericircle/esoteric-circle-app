# RAPPORTO DELL'ORDINE EJ

Il microfono che non tronca, le voci da scegliere, le risposte che dicono
qualcosa, la barra che si nasconde e la pastiglia "Dal vivo". Ordine del 25
settembre 2026 con l'aggiunta dello stesso giorno; lavoro del 24 settembre
2026 sull'orologio della macchina. Ramo `claude/esoteric-circle-master-order-e798aj`.
Manifesto `docs/ordini/ORDINE_EJ_MANIFESTO.md`, prove in `docs/collaudo/EJ/`.

## LE VOCI CHIUSE, CON LA LORO PROVA

- **EJ.01, il microfono non tronca**: `docs/collaudo/EJ/live/giro_3_realme.txt`.
  La domanda di prova, quattro frasi con pause di 1,5, 1,3 e 1,6 secondi
  dette dal portatile al Realme: prima arrivava 1 frase su 4, adesso 4 su 4.
  Col pulsante tenuto premuto arriva intera una frase di 25,9 secondi con
  pause di 3 secondi.
- **EJ.07, nessuna anticipazione dei doni**: `docs/collaudo/EJ/risposte/_rigiudizio.txt`.
  12 anticipazioni su 18 risposte prima, 0 su 18 in ciascuno dei quattro giri
  dopo.
- **EJ.09, la barra Esplora non occupa spazio**: `docs/collaudo/EJ/barra_e_pastiglia/medora_apertura.png`.
  All'apertura della chat la barra e' sotto il bordo in 3 chat su 3; la
  conversazione guadagna 112 punti, 336 pixel misurati sul Realme.

## LE VOCI CHE RESTANO APERTE, E PERCHE'

- **EJ.02, il selettore delle voci**, in attesa di verifica: il selettore c'e'
  e il server e' distribuito, ma la voce la sceglie il fondatore
  ascoltandola, e il Realme di collaudo non e' un fondatore, quindi il
  selettore e' fotografato dall'app (`docs/collaudo/EJ/voci/selettore_medora.png`).
- **EJ.03, i mezzibusti sfocati**, aperta: la causa e' misurata, e non sono le
  immagini. Serve una decisione del fondatore, sotto.
- **EJ.04, si dice Calìgo**, in attesa di verifica: le registrazioni ci sono,
  il giudizio e' dell'orecchio del fondatore.
- **EJ.05, niente ripetizioni**, aperta: le chiusure ripetute sono a zero, ma
  i dati della persona tornano ancora in 3-7 risposte su 18.
- **EJ.06, risposte dirette**, aperta: le risposte non dirette scendono da 15
  su 18 a 7-10 su 18, non a zero.
- **EJ.08, l'italiano corretto**, aperta: un errore vero su 72 risposte dopo.
- **EJ.10, la pastiglia "Dal vivo"**, in attesa di verifica: lo stato grigio
  e i tre fogli sono guardati sul Realme, lo stato d'oro solo nella resa
  dell'app, perche' il Realme ha il piano del Viandante.

---

## PARTE PRIMA, IL LIVE

### EJ.01, il microfono

Il LIVE non usa piu' il riconoscitore di Android. Registra, decide lui quando
la frase e' finita (due secondi di silenzio vero dopo aver parlato, mai col
silenzio iniziale) e manda la frase intera a Gemini flash-lite in europe-west1
per la trascrizione. Il microfono si tiene premuto per parlare senza limiti.

**Tre giri sul Realme, tre cure.** Il primo ha trovato la soglia sbagliata e
il microfono chiuso durante le trascrizioni; il secondo ha misurato i livelli
veri del telefono (silenzio fra -85 e -91 dB, voce che attacca a -42, code
fra -58 e -75) e ha portato l'isteresi; il terzo ha portato il microfono che
non si chiude mai e le frasi che si uniscono se la persona riprende a parlare.
Nel terzo giro la domanda e' arrivata intera, e anche la seconda. Visti e
curati anche la sessione tenuta viva dal rumore, gli a capo nella
trascrizione e la coda della voce del volto.

**Scarti**: la prova la fa il portatile, non una persona: la sua voce arriva al
microfono del telefono a strappi di un secondo, che e' un banco piu' duro di
una persona che parla vicino. E il portatile dice "Medora" mentre la
trascrizione scrive "Mezz'ora": il nome del Maestro non e' dato alla
trascrizione, non e' curato.

### EJ.02, il selettore delle voci

Sedici candidate, cinque per Medora e per Aura e sei per Calìgo, scelte sulle
preferenze del fondatore (anziane e profonde per Medora e Calìgo, giovane e
calma per Aura) e tutte chiamate davvero in europe-west1. Ogni candidata dice
la stessa frase del suo Maestro, registrata in `docs/collaudo/EJ/voci/`. La
voce scelta si scrive su Firestore e vale per tutti senza una build. Tre
funzioni nuove sul server, riservate ai fondatori, distribuite.

### EJ.03, i mezzibusti sfocati: le misure

| cosa | misura |
| --- | --- |
| immagini sorgente | PNG 1.700 per 1.200 (Aura 1.200 per 1.200), figura larga 983-1.505 px |
| video ricevuto dal telefono | 384 per 384 nei primi secondi, poi 512 per 512, 21-25 fotogrammi al secondo |
| finestra del volto sul Realme | 936 per 1.170 pixel veri |
| parte del video che si vede | 61,9 per cento in larghezza, 77,4 in altezza |
| ingrandimento | circa 3,9 volte col 384, circa 2,95 col 512 |
| livello di oggi | standard, il predefinito |
| costo standard | 3 crediti per 165 secondi fatturati |
| costo pro | 3 crediti per 155 secondi fatturati, e video uguale: 384 poi 512 |

Prove: `docs/collaudo/EJ/volto/misure.txt`, `volto_standard.png`,
`volto_pro.png`. **Le immagini non sono troppo piccole**: la figura e' due o
tre volte piu' grande dell'intero fotogramma che arriva. **Il limite e' il
flusso di Protoface**, e il livello pro non l'ha cambiato: costa uguale, un
credito al minuto arrotondato, e manda lo stesso video. **Decisione del
fondatore**: una finestra piu' piccola, che ingrandisce meno, oppure chiedere
a Protoface se esiste un'uscita piu' grande di 512 pixel. Il livello si
cambia da Firestore, `configurazione/live.qualita`, ed e' tornato al
predefinito.

### EJ.04, Calìgo

La riga 31 del file del fondatore cambiata, e nessun'altra. Nell'app il nome
arriva alla voce scritto con l'accento. Un'indicazione nel modo di parlare e'
stata provata e scartata: la voce la leggeva ad alta voce. Registrazioni in
`docs/collaudo/EJ/nome/`.

---

## PARTE SECONDA, LE RISPOSTE DEI MAESTRI

Sei domande vere per Maestro, Gemini vero in europe-west1, la chat vera. Un
giro prima e quattro dopo; tutte le fasi rigiudicate con gli stessi giudici.

| conto, su 18 risposte | prima | dopo | dopo2 | dopo3 | dopo4 |
| --- | ---: | ---: | ---: | ---: | ---: |
| chiusure ripetute | 15 | 0 | 0 | 0 | 0 |
| frasi vietate | 0 | 0 | 0 | 0 | 0 |
| dati della persona ripetuti | 17 | 3 | 3 | 5 | 7 |
| anticipazioni dei doni | 12 | 0 | 0 | 0 | 0 |
| risposte non dirette | 15 | 7 | 9 | 10 | 7 |
| senza passo concreto | 13 | 1 | 2 | 0 | 1 |
| errori di regola | 0 | 0 | 0 | 0 | 0 |
| errori di grammatica | 0 | 0 | 0 | 1 | 0 |

Per Maestro, nel giro `dopo4`: Medora 4 risposte non dirette su 6, Aura 1,
Calìgo 2. Il primo giro prima, le cui trascrizioni sono state sovrascritte,
aveva 6 errori di regola su 18 (Calìgo). L'unico errore di grammatica dopo e'
di Aura: *"senti il calmo del tuo respiro"*.

**Da dove nascevano**: la riga ripetuta e le anticipazioni le scriveva
l'app, non Gemini; i tre dati li imponeva una regola nostra. I padri stanno in
fondo.

**L'attribuzione cieca** e' stata rifatta sull'istruzione nuova, tre giri:
95,0, 100,0 e 91,7 per cento, media 95,6 (172 su 180), giro piu' basso sopra
la soglia di 85. Tre giri precedenti, 98,3, 91,7 e 98,3, erano su una stringa
di Medora con un esempio che diceva "sentire", parola di firma di Aura: la
guardia del lessico l'ha presa e l'esempio e' stato riscritto, e quei giri
stanno nello storico. **Il giro `dopo4` del collaudo e' stato fatto con
quell'esempio**, gli altri tre giri dopo senza nessuno dei due: l'esempio
riscritto e' passato dall'attribuzione cieca, non dal collaudo delle risposte.
`ImprontaDellIstruzione.attribuzioneValida` e' diventata vera, le impronte
sono aggiornate con lo storico, e il rosso accettato che la riguardava e'
tolto dal registro. Prove in `docs/collaudo/EJ/attribuzione/`. **E' una
riga che il fondatore aveva confermato rossa nell'ordine BY**: la condizione
scritta era che nessun giro cadesse sotto 85, e nessuno ci cade, ma la
decisione di considerarla chiusa e' sua.

---

## AGGIUNTA, LE VOCI 09 E 10

**EJ.09.** Nelle chat dei Maestri la barra si apre ritirata, compare quando il
dito scende verso i messaggi di prima e si ritira quando si torna a leggere o
si tocca il campo. La lista della chat non le tiene piu' il posto. La regola
ferrea su Esplora prende l'eccezione per iscritto in `docs/STATO_VIVO.md`.
**Lettura dichiarata**: "riprende a leggere" e' letto sul dito, non su un
temporizzatore, perche' la regola del 6 agosto vieta una barra che si abbassa
da sola.

**EJ.10.** La pastiglia sta sopra l'icona della conversazione nuova, perche'
in fila avrebbe tolto al nome del Maestro lo spazio per starci. Per farla
stare, **la riga delle arti sotto il nome si rimpicciolisce un poco**, visibile
nelle catture: e' la prima cosa da guardare. Il foglio porta le parole di
ciascun Maestro, non la sua voce registrata: "con la sua voce" e' letto come
nel resto del progetto, il suo modo di parlare. Il LIVE e' aperto al tier 2
sul server (`apertoAlTier2: true`), quindi un Adepto che tocca la pastiglia
d'oro entra davvero.

---

## LE CHIAMATE A GEMINI

| cosa | chiamate |
| --- | ---: |
| collaudo, risposte dei Maestri (5 giri) | 112 |
| collaudo, domande ai giudici (5 giri) | 616 |
| rigiudizio di tutte le fasi | 324 |
| grammatica di tutte le fasi | 90 |
| attribuzione cieca, 3 giri da 60 risposte e 60 giudizi | 360 |
| **totale contato** | **1.502** |

Non contati: il primo giro prima, sovrascritto; le tarature dei giudici
rifatte durante il lavoro; le voci registrate con Gemini-TTS (19 file, piu' i
ritentativi per il limite di richieste); le trascrizioni e le risposte del
LIVE sul telefono. Tutto su `gemini-2.5-flash` e `gemini-2.5-flash-lite` in
europe-west1. **Il costo non e' misurato**: le chiamate non registrano i
gettoni, e la fattura del giorno non e' ancora leggibile. Protoface: quattro
sessioni di prova; le prime tre, lette dal registro del server, sono costate
10 crediti (da 141 a 151). La quarta, quella del giro 3, si leggera' alla
prossima apertura del LIVE.

---

## SCARTI FRA L'ORDINE E IL RAMO

- Le sedici catture della 2278 non sono arrivate nel messaggio.
- Nell'app non c'era nessuna regola di pronuncia da correggere: la regola
  sbagliata stava solo nel file del fondatore, riga 31.
- La riga ripetuta e le anticipazioni le scriveva l'app,
  `lib/core/maestro/consiglio_finale.dart` righe 178-249, non Gemini.
- I tre dati li imponeva una regola nostra, `lib/services/ai/maestro_persona.dart`
  righe 481-483, con la rigenerazione del controller righe 1136-1157.
- Il corpo della sessione LIVE non dichiarava la qualita',
  `functions/src/live.ts` righe 285-313.
- La regola ferrea su Esplora, `docs/STATO_VIVO.md`, che la voce 09 chiede di
  cambiare: cambiata solo nelle chat, per iscritto.
- La Regola B e' stata applicata a lavoro gia' cominciato, non prima di
  mettere mano alle zone.

## I PADRI DEI DIFETTI

- Invito ripetuto e anticipazioni: commit `927f8db0` del 4 agosto 2026,
  **entrato fuori da ogni ordine**.
- Tre dati in ogni risposta: ordine Chat 3 voce 1, commit `eedd9f9c`.
- Il microfono che chiudeva dopo un secondo e mezzo: ordine EG voce 05,
  commit `3687c223`.
- La guardia cieca dell'emblema: ordine 2164 voce 6.
- Il rumore che teneva viva la sessione e il microfono chiuso fra le frasi:
  ordine EJ voce 01, la prima stesura di questo ordine.
- Le tre guardie di casa cadute sulla barra ritirata: ordine EJ voce 09.
- Le cadute delle regole di casa sul codice nuovo: ordine EJ voci 01, 02, 06,
  08 e 10.
- "Medora" trascritto "Mezz'ora": ordine EJ voce 01, non curato.

## BUILD

Nessuna build consegnata su App Distribution. Quattro build locali installate
sul Realme per le prove. **Una build per il fondatore servirebbe** a fargli
provare il microfono con la sua voce, i timbri col selettore e la barra nelle
chat: si fa solo col suo ordine.
