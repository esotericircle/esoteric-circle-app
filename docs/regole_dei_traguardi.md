# LE REGOLE DEI TRAGUARDI

**Definitive.** Ordine CP voce 04, 3 settembre 2026, scritte da Claude Code su
mandato del fondatore.

Questo file non racconta un ordine: **governa il corpus per sempre.** Un
manifesto dice cosa è stato fatto una volta; queste regole dicono cosa può
esistere. Ogni regola qui sotto è scritta perché una prova possa verificarla su
ogni singolo gradino, non perché un lettore possa approvarla, e la prova che le
verifica è `test/le_regole_dei_traguardi_sono_rispettate_test.dart`.

**Il vincolo che il fondatore ha ripetuto tre volte: devono essere definitive.**
Una regola che vale finché non si trova il prossimo caso non è una regola. Per
questo ognuna porta con sé il modo in cui si misura: dove non c'è una misura,
non c'è una regola, c'è un'intenzione.

---

## LE UNDICI REGOLE DEL FONDATORE, e come diventano misure

Sono la sua decisione del 17 agosto 2026, più la decisione del 3 settembre.
La colonna di destra è ciò che la prova controlla su **ogni** gradino.

| # | La regola, sue parole | Come si misura |
| --- | --- | --- |
| 1 | Non più di un traguardo alla volta | **La scala.** Da ogni sentiero può maturare solo il gradino che chi cammina sta per prendere, e il Cammino ne accende **uno per volta**, che occupa il posto finché la sua festa non è congedata. Verificato da `il_gradino_aspetta_il_congedo_test` e `aprire_e_chiudere_non_e_un_cammino_test`. |
| 2 | Non possono capitare contemporaneamente | Due gradini con lo **stesso costo in giorni** non possono nominare **lo stesso gesto**: se lo facessero, un solo evento li renderebbe maturi insieme. E la simulazione conta le contese: sotto il dieci per cento. |
| 3 | Piuttosto più articolato e difficile | In **ogni fascia dalla seconda in poi, almeno la metà** dei gradini chiede più di un conteggio: un fatto del cielo, un'ora rituale, una costanza dentro un arco, o più arti nello stesso giorno. Misurato: 8, 7, 8 e 8 su 11. |
| 4 | Facili all'inizio, più difficili verso la fine | Il **costo in giorni** non diminuisce mai lungo un sentiero, e ogni fascia sta dentro la sua banda dichiarata. |
| 5 | Raggiungibile, con sforzo sempre maggiore | Nessun gradino è irraggiungibile: ogni gesto nominato ha una schermata che lo manda, ogni evento nominato ha una data futura calcolabile, e la simulazione di un anno non lascia **nessun** gradino soddisfatto e mai acceso. |
| 6 | La ricerca porta a scoprire nuove funzionalità | Ogni gradino dichiara la **porta che apre**, e i gesti di un sentiero sono tutti nominati almeno una volta nelle prime tre fasce. |
| 7 | Legare a eventi astrologici rari | Ogni fascia dalla seconda in poi contiene almeno **tre** gradini legati a una finestra del cielo, e il gradino grande di ogni fascia è **sempre** una finestra del cielo. |
| 8 | I Maestri devono saperlo | Il contesto delle chat porta lo stato del Cammino e gli eventi del cielo in arrivo. **Non è ancora costruito**, e il corpus non lo può soddisfare da solo: il motore delle date esiste (`ProssimiEventi`), il ponte verso la chat no. Dichiarato aperto. |
| 9 | Promemoria almeno una settimana prima | Ogni evento del cielo nominato da un gradino ha una **data futura calcolabile** entro l'orizzonte di 400 giorni: è la condizione perché un promemoria possa partire, ed è verificata su tutti e 23 gli eventi nominati. **Chi manda l'avviso non è ancora costruito**, e resta dichiarato aperto. |
| 10 | Si calibra sull'MVP, una volta sola | Nessun gradino nomina un gesto che nessuna schermata manda, e **i dormienti sono zero**: nella revisione E erano cinquantuno. Un gradino che chiede un gesto senza schermata non è difficile, è irraggiungibile. |
| 11 | I 165 restano IL Cammino, chiuso e finibile | Il corpus ha esattamente **165** gradini, **55** per sentiero, **2.010** Eos per sentiero e **6.030** in tutto. |
| + | Il gradino non matura finché il precedente non è congedato | Vedi la regola 1: è la stessa misura, letta alla lettera. |

### Perché il posto unico non bastava, e il numero che lo ha detto

La regola 1 era stata scritta come **un posto solo**: un gradino acceso occupa
il Cammino finché la sua festa non è congedata. Quel freno regge contro il
gesto ripetuto e **non regge contro il cielo**.

Misurato su trecentosessantacinque giorni, un utente nuovo che compie tutte e
venti le arti nel giorno peggiore dell'anno vedeva **tredici feste**: in una
giornata con più pianeti retrogradi insieme si aprono molte finestre del cielo
contemporaneamente, e ognuna arma il suo gradino. Erano più delle **otto** che
il fondatore ha visto sul telefono.

Con la scala il conto è un altro, e si legge nella stessa simulazione: il
giorno peggiore dell'anno porta **tre** feste, la media è esattamente tre, e
non c'è cielo abbastanza ricco da farne di più.

**Il rischio della scala è noto e si dichiara.** Un gradino irraggiungibile la
bloccherebbe per sempre, ed è il difetto che l'ordine AS chiuse per le serie
consecutive. Nella revisione F non ce ne sono: ogni gesto nominato ha una
schermata che lo manda, ogni evento nominato ha una data futura calcolabile, e
due guardie lo pretendono su tutti e 165.

**La conseguenza da dire ad alta voce**: il primo gradino di ogni sentiero è un
pezzo dell'identità, e finché non si prende quel sentiero non avanza. Chi non
legge mai la Costellazione del Viso non avanza sul Fiore di Loto. È un cancello,
ed è voluto: la regola 6 chiede che la ricerca del traguardo porti a scoprire
funzioni nuove, e questo è il modo più diretto di chiederlo.

---

## LA GRANDEZZA CENTRALE: IL COSTO IN GIORNI

**Un traguardo si misura in giorni, non in tocchi.** È la grandezza che risponde
al fatto del fondatore, *"hai scelto dei traguardi che si possono fare tutti in
una singola sessione"*: un gradino che costa sette giorni non si può fare in una
sessione, e nessun trucchetto lo accorcia.

Il costo è il **minimo numero di giorni rituali distinti** in cui la condizione
può essere soddisfatta da chi ci prova apposta. Si calcola dalla condizione,
non si dichiara a mano, e **vive come proprietà della condizione stessa**
(`CondizioneDelTraguardo.costoInGiorni`): il generatore ne calcola una sua
copia in Python per ordinare i gradini, e la guardia che pretende il costo non
decrescente confronta di fatto le due. Se un giorno divergessero, la scala
salterebbe e la guardia diventerebbe rossa.

| condizione | costo in giorni |
| --- | ---: |
| `GestiCompiuti(g, n, inGiorniDiversi: true)` | n |
| `GestiCompiuti(g, 1)` | 1 |
| `GiorniDentroUnArco(rito, n, arco)` | n |
| `GiorniDiSeguito(rito, n)` | n |
| `StessaOraPerGiorni(g, n)` | n |
| `GestoNellOraGiusta(g, ora, n)` | n |
| `GestiNelloStessoGiorno([...])` | 1 |
| `GiornateInsieme([...], n)` | n |
| `VarietaDelDettaglio(g, chiave, n)` | n, se il gesto dà un valore al giorno |
| `RitornoAlMaestro(sentiero, n)` | n + 1 |
| `RitornoAlRito(rito, n)` | n + 1 |
| `RitornoDopoAssenza(n)` | n + 1 |
| `FinestraDelCielo(evento, ...)` | l'attesa tipica dell'evento, dalla tavola qui sotto |
| `PezzoDellIdentita(pezzo)` | 1 |
| `GradiniAlleSpalle(sentiero, n)` | il costo dell'n-esimo gradino di quel sentiero |
| `GestoDelCerchio(g, n)` | n |

**Perché una volta al giorno.** Dall'ordine CP voce 02 lo stesso gesto con gli
stessi dettagli conta **una volta sola nella giornata rituale**: è ciò che rende
il costo in giorni una misura vera e non una speranza. Senza quella regola,
"dieci gettate" si chiuderebbe in dieci minuti.

### Le bande delle cinque fasce

| fascia | costo in giorni | gradini |
| --- | --- | ---: |
| Primi giorni | da 1 a 8 | 11 |
| Prima settimana | da 9 a 30 | 11 |
| Primo mese | da 31 a 90 | 11 |
| La stagione | da 91 a 190 | 11 |
| L'anno | da 191 a 365 | 11 |

La prima banda arriva a **otto** e non a sette perché il gradino grande della
prima fascia è una finestra del cielo, e il primo quarto di Luna si aspetta al
peggio otto giorni: la banda segue il cielo, non il contrario.

**Esattamente un gradino per sentiero costa un giorno solo**, ed è il primo.
Da qui viene il numero che il fondatore può contare: **tre feste nella prima
sessione**, una per Maestro, e non una di più.

### I tre gradini da un giorno sono i tre pezzi dell'identità

Un pezzo dell'identità si ha **una volta e per sempre**, quindi la sua
condizione non può chiedere due giorni: costa uno, sempre. Unito alla regola 4,
che vieta alla scala di scendere, questo obbliga il gradino di identità a stare
in **prima posizione**, e ne ammette **uno solo per sentiero**.

Non è una limitazione subita, è il disegno giusto: la prima cosa che il Cammino
festeggia è **chi sei** (la carta natale da Medora, la Costellazione del Viso
da Aura, l'Animale Guida da Caligo), non quanto sei stato bravo.

### La famiglia segue la condizione, e non si sceglie a mano

Le guardie contano le famiglie per sapere di che natura è un sentiero: una
famiglia scritta a mano direbbe di un gradino una cosa che il suo codice non
fa. La tavola è in `tool/corpus_traguardi.py` e vale per tutti e 165.

| condizione | famiglia |
| --- | --- |
| `PezzoDellIdentita` | identità |
| `GestiCompiuti`, `VarietaDelDettaglio` | profondità |
| `GiorniDentroUnArco`, `GiorniDiSeguito`, `StessaOraPerGiorni` | ritorno |
| `GestoNellOraGiusta`, `FinestraDelCielo` | cielo |
| `GiornateInsieme` con due gesti | giornata |
| `GiornateInsieme` con tre o più | ampiezza |
| `GestoDelCerchio` | cerchio |

**Due arti nello stesso giorno sono una giornata chiusa, tre o più sono
ampiezza fra le arti.** Non è una sfumatura: una coppia si chiude dentro un
rito solo, tre arti obbligano ad attraversare il Cerchio.

### L'attesa tipica degli eventi del cielo

Non è una probabilità: è **quanto si aspetta, al peggio ragionevole**, perché un
evento raro vale come traguardo solo se l'attesa è quella che si dichiara.

| evento | attesa in giorni | | evento | attesa in giorni |
| --- | ---: | --- | --- | ---: |
| luna_crescente, luna_calante | 2 | | solstizio, equinozio | 91 |
| primo_quarto, ultimo_quarto | 8 | | eclissi | 90 |
| luna_piena, luna_nuova | 15 | | mercurio_retrogrado | 60 |
| luna_nel_tuo_segno | 28 | | mercurio_diretto | 120 |
| luna_nel_segno_opposto | 28 | | giove_retrogrado, saturno_retrogrado | 120 |
| transito_sulla_luna | 30 | | giove_diretto, saturno_diretto | 240 |
| transito_sull_ascendente | 45 | | sole_nel_tuo_segno | 180 |
| transito_sul_sole | 45 | | venere_retrograda, venere_diretta | 290 |
| transito_su_venere, transito_su_marte | 60 | | marte_retrogrado, marte_diretto | 390 |
| tre_transiti_insieme | 180 | | luna_piena_nel_tuo_segno | 365 |
| | | | luna_nuova_nel_tuo_segno | 365 |
| | | | ritorno_solare | 365 |

---

## LA REGOLA CHE VALE PIÙ DI TUTTE: LA CONDIZIONE SI DICHIARA, NON SI DEDUCE

Il corpus della revisione E scriveva la condizione **in italiano** e un
generatore di milleseicento righe la traduceva in codice con regole di
riconoscimento del testo. È la fessura da cui la condizione scritta e l'evento
che la arma possono divergere senza che nessuno se ne accorga: cambiare una
parola nella frase cambiava la condizione, e riscrivere la frase per renderla
più bella poteva cambiare ciò che l'app misurava.

**Dalla revisione F il corpus dichiara la condizione in forma strutturata**, e
il generatore la trascrive senza interpretare niente. La frase italiana resta,
ma è **descrizione** e non **sorgente**: si può riscrivere senza toccare il
comportamento, e non può più contraddirlo.

Questa è anche la risposta strutturale alla voce CP.07: la condizione scritta e
l'evento che la arma non sono più due cose che devono coincidere, **sono la
stessa cosa dichiarata una volta.**

---

## LE REGOLE DI FORMA, verificate una per una

1. **165 gradini**, 55 per sentiero, 11 per fascia, 10 mini e 1 grande.
2. **Gli Eos non cambiano**: mini 10/20/30/45/55, grandi 40/60/80/100/130,
   2.010 per sentiero, 6.030 in tutto. Cambiarli avrebbe conseguenze
   nell'economia degli Eos e nella matrice dei piani, che li citano.
3. **Il grande di ogni fascia è l'ultimo**, in posizione 11, 22, 33, 44, 55.
4. **Ogni id è unico** e vale `<prefisso>_<posizione>`.
5. **Nessun gesto inventato**: ogni gesto nominato esiste in `GestiDelleArti`.
6. **Nessuna chiave di dettaglio inventata**: ogni chiave nominata è una di
   quelle che una schermata manda davvero. Sono dodici, e l'elenco vive nella
   prova.
7. **Nessun evento del cielo inventato**: ogni evento esiste in
   `EventiDelCielo.tutti`.
8. **Nessun gradino vivo nomina un gesto senza schermata.** Chi lo farebbe è
   dormiente dichiarato, con scritto che cosa lo sveglia.
9. **Ogni gradino dichiara la porta che apre**, e nessuna porta è vuota.
10. **Nessuna condizione si ripete identica** in tutto il corpus.

---

## COSA NON È UNA REGOLA, e perché si dice

**Non c'è una regola sul numero di feste al giorno.** Sarebbe una regola sul
corpus scritta per rimediare a un difetto della macchina, e la macchina è già
riparata: il posto unico del congedo garantisce che non se ne veda più di una
alla volta, e il conto di una volta al giorno per gesto garantisce che ripetere
non produca premi. Una regola in più qui sarebbe una cintura sopra una cintura,
e nasconderebbe quale delle due tiene davvero.

**Non c'è una regola sulla bellezza dei nomi.** Non si può misurare, quindi non
è una regola: è mestiere.
