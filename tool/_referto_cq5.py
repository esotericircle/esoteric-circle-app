# -*- coding: utf-8 -*-
"""CQ5: il referto si riscrive dalla sezione 5 in giu'."""
NL = chr(10)
A = chr(39)

P = 'docs/ordini/CQ_REFERTO.md'
grezzo = open(P, 'rb').read().decode('utf-8').replace(chr(13) + NL, NL)
taglio = grezzo.index('## 5. LE VOCI DICHIARATE CHIUSE E NON FATTE')
testa = grezzo[:taglio]
# La sezione 9, i difetti fuori ordine, si conserva parola per parola.
fuori = grezzo[grezzo.index("## 9. I DIFETTI TROVATI FUORI DALL" + A + "ORDINE"):]
fuori = fuori.replace("## 9. I DIFETTI TROVATI FUORI DALL" + A + "ORDINE",
                      "## 11. I DIFETTI TROVATI FUORI DALL" + A + "ORDINE")

coda = """## 5. LE VOCI DICHIARATE CHIUSE E NON FATTE

E' la risposta al numero che mi avevi chiesto il 3 settembre.

**Sette voci su settantatre, contate sui manifesti sigillati.**

| ordine | voce | cosa dichiarava | cosa aveva fatto davvero |
| --- | --- | --- | --- |
| CO | **07** | un pulsante per cominciare la lettura | ha messo il pulsante PRIMA delle carte e **bloccato la scelta**: si premeva per ottenere il permesso di scegliere |
| CO | **13** | i testi dei Doni non sono piu' piccoli | ha alzato la prosa a diciotto e **lasciato le etichette a dodici** in duecentotre posti |
| CO | **15** | la riga "IL RITO DI STAMATTINA" | scritta bene, e **annunciava un rito che non esiste** |
| CO | **17** | i responsi dei Doni nella gerarchia | la gerarchia c'e' e **la prima cosa che si legge restava un compito**, in tutti e cinque |
| CO | **20** | il cuore in un angolo solo | lo ha **spostato** a sinistra invece di centrarlo a destra, e li' si e' fuso con la freccia Indietro |
| CP | **01** | il gradino non matura finche' il precedente non e' congedato | ha portato le feste da tredici a tre e **ha murato il Cammino**: 13 gradini accesi su 112 guadagnati |
| CG | **16** | le notifiche push, una per Dono | era gia' stata corretta una volta dall'ordine CI, e **le push continuavano a non partire** |

**Nessuna di queste sette e' sigillata CHIUSA**, ed e' esattamente cio' che la
tua voce 4.01 chiedeva. Le sei di CO e CP sono FERMATE SU DECISIONE DEL
FONDATORE con scritto accanto chi le ha superate; CG.16 chiude con la voce CQ
1.09.

---

## 6. I SEI MANIFESTI, VOCE PER VOCE

| ordine | voci | chiuse | fermate | **aperte** |
| --- | ---: | ---: | ---: | ---: |
| CG | 16 | 16 | 0 | **0** |
| CM | 11 | 11 | 0 | **0** |
| CN | 16 | 15 | 1 | **0** |
| CO | 20 | 15 | 5 | **0** |
| CP | 10 | 9 | 1 | **0** |
| CQ | 32 | 31 | 1 | **0** |
| **totale** | **105** | **97** | **8** | **0** |

**Zero voci aperte su centocinque.** E' il marcatore finale che la REGOLA G
chiede, e la guardia di famiglia lo stampa a ogni giro:

    ORDINE CQ VOCE 4.04: ordini con voci ancora aperte nessuno
    ORDINE CQ: voci 32, aperte 0, fermate 1

La riga che teneva rossa quella guardia e' stata **tolta** da
`tool/rossi_accettati.txt`: era li' perche' CQ aveva sei voci aperte, e adesso
ne ha zero. Lasciarci il nome della prova sarebbe stato un permesso silenzioso,
cioe' un rosso futuro accettato senza che nessuno lo abbia deciso.

---

## 7. OGNI FERMATA, CON LA DECISIONE CHE LA FERMA

La tua REGOLA G dice che una FERMATA vale solo se poggia su una decisione che
hai preso per iscritto. Sono otto, e le elenco tutte con la tua parola accanto.

| ordine | voce | la decisione tua che la ferma |
| --- | --- | --- |
| CN | **05** | l'hai annullata tu prima che cominciasse |
| CO | **07** | "il pulsante e' stato messo PRIMA delle carte e ha bloccato la scelta": tu l'hai rovesciato con la voce CQ 1.03 |
| CO | **13** | "non ha chiuso la materia": tu hai riaperto le etichette con la voce CQ 1.02 |
| CO | **15** | tu hai fatto togliere tutto il blocco con la voce CQ 2.03 |
| CO | **17** | tu hai riscritto la legge dei testi nel pezzo secondo |
| CO | **20** | "ha spostato il cuore invece di centrarlo": tu l'hai ricentrato con la voce CQ 1.04 |
| CP | **01** | "ha murato il Cammino": tu hai ordinato la misura con la voce CQ 2.12 |
| CQ | **28** | tu hai chiesto di non toccare la curva |

**Tre fermate sono state disfatte oggi, perche' non erano fermate.**

- **CQ.21** e **CQ.23** dicevano FERMATA SU PREMESSA FALSA. Ma una premessa
  misurata falsa **non e' una decisione tua**: e' un lavoro finito che ha per
  esito "non c'era niente da curare". Adesso sono CHIUSE, con la misura
  accanto.
- **CP.08** diceva FERMATA IN ATTESA DI DECISIONE sul criterio della
  simulazione. **Non c'era nessuna decisione tua a fermarla**, c'era una
  proposta mia che aspettava una risposta che non ti avevo mai chiesto. Per la
  REGOLA G una voce che aspetta una decisione mai chiesta non e' fermata, e'
  aperta con un altro nome. Chiusa col criterio adottato: **nessun giorno
  dell'anno porta piu' di TRE feste**, che combacia col massimo misurato e non
  lascia margine. Se un cielo piu' ricco ne producesse quattro, la prova
  cadrebbe il giorno stesso.

---

## 8. LE SEI VOCI CHE ERANO APERTE, E COME SI SONO CHIUSE

- **CQ.16**, i cinque Doni frase per frase. I quattro strati misurati su tutte
  e quattro le schermate: **due non li avevano**. L'Arcano non portava nessuna
  fonte, il Tramonto la aveva solo dietro un pulsante in barra, cioe' chi legge
  il responso non incontrava mai da dove viene la runa. **Una risposta che non
  si puo' risalire chiede di essere creduta.** Adesso l'Arcano dice da quale
  arcano e da quale posizione natale nasce, e il Tramonto cita la strofa vera.
- **CQ.19**, la parola del giorno. Diceva "Parola del giorno", che e' il nome
  di una casella. Adesso dice di portarsela dietro, e sotto c'e' scritto dove
  va a finire.
- **CQ.22**, il Sigillo del Giorno. **La fermata era una ricerca fatta male**:
  il Sigillo del Giorno esiste, e' la bindrune che chiude ogni gettata di rune.
  Cercarlo fra i NOMI delle schermate invece che DENTRO le schermate ha
  prodotto una fermata dove c'era lavoro. Sotto il disegno c'era la nota della
  tradizione, che dice bene che cosa E' una bindrune e niente su cosa te ne
  fai: adesso c'e' prima la riga dell'uso, e la tradizione scende in fondo dove
  sta la fonte.
- **CQ.24**, la domanda della parola senza risposta. Il richiamo della sera
  diceva che parola era e finiva li'. Adesso dice che ha attraversato il giorno
  e che adesso si chiude.
- **CQ.25**, la runa singola. Misurato: la scheda intera porta 264 caratteri
  contro i 50 della sola risposta, **cinque volte e un quarto**. A una runa
  sola il simbolo, la Voce e la strofa stanno dietro una porta che si apre in
  posto; a tre e a cinque rune restano dove erano, perche' li' sono il corpo
  della lettura.
- **CQ.29**, il ponte fra il motore delle date e la chat. Il blocco entra
  nell'istruzione di sistema con al massimo tre eventi e il prossimo gradino
  del Cammino, senza promettere niente, e se non c'e' niente da dire non
  compare affatto.
- **CQ.30**, i promemoria. La misura sta in `docs/promemoria/misura.md`:
  ventuno eventi con una data calcolabile, venti entro l'anno, cinque
  personali, e **sedici avvisi in un anno**, uno ogni ventitre giorni. Non e'
  un flusso, e per questo si poteva misurare invece di costruire.

---

## 9. LA PROVA DI ACCENSIONE E' STATA SALTATA, E LO DICO AD ALTA VOCE

**NESSUN DISPOSITIVO HA ACCESO QUESTA BUILD.**

Lo salto per tuo ordine esplicito del 4 settembre 2026, voce CQ 5.04: non sei
al PC, non hai il telefono collegato, e hai dichiarato che non installi la
2223. Il numero e la firma dell'archivio sono letti dall'archivio, non da un
telefono, e questa e' l'unica cosa che posso garantirti di questa build.

La stessa riga sta nelle note della build su App Distribution, perche' chi la
scarica lo legga prima di installarla.

**Vale solo per questa consegna.** Alla prossima, con te al PC, la prova di
accensione torna obbligatoria e non chiedo di saltarla.

---

## 10. LA BUILD

| | |
| --- | --- |
| numero | **2224** |
| gruppo | il gruppo di collaudo che il progetto usa gia' |
| prova di accensione | **saltata per tuo ordine, voce CQ 5.04** |

Non e' la 2223. La 2223 era stata costruita e tu hai detto che non la
installavi: consegnartela di nuovo col vecchio numero avrebbe voluto dire
chiederti di fidarti che dentro fosse cambiato qualcosa.

"""

nuovo = testa + coda + fuori
open(P, 'wb').write(nuovo.encode('utf-8'))
print('REFERTO RISCRITTO,', nuovo.count(NL), 'righe')
