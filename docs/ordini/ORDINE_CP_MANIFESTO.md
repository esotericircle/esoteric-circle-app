# ORDINE CP, I TRAGUARDI RISCRITTI DA ZERO

**Manifesto.** 3 settembre 2026.

**Da dove nasce.** Il fondatore ha collaudato la build la notte fra il 2 e il 3
settembre 2026 e ha visto **otto feste in due funzionalità**. Parole sue:
*"oggi in 2 funzionalita' mi sono dovuto vedere 8 feste! anche se funzionasse
hai scelto dei traguardi che si possono fare tutti in una singola sessione."*
E poi: *"riscriviamo tutti i traguardi da zero con regole definitive."*

---

## LE SEI PREMESSE DELL'ORDINE, VERIFICATE SUL RAMO

La Regola Zero dice che il testo dell'ordine è inaffidabile e che ogni fatto va
verificato prima di toccare una riga. Ecco l'esito.

| premessa dell'ordine | verificata | esito |
| --- | --- | --- |
| I traguardi si possono fare tutti in una singola sessione | Contati sul corpus della revisione E | **VERA in parte, e il numero è peggiore di come suona**: 45 gradini su 165 si chiudevano in una sessione, per **610 Eos**. Non tutti, ma abbastanza da riempire ogni sessione di feste. |
| Il gesto ripetuto arma due volte | Misurato sul diario | **VERA**: `segna` contava ogni chiamata, quindi otto aperture della stessa schermata drenavano otto gradini dall'arretrato dei soddisfatti. |
| Ci sono schermate che dichiarano un gesto che non è avvenuto | Censite tutte e 21 le schermate che mandano un gesto | **VERA per una sola**: il Soffio del Destino mandava `dettagli` che nessuna delle tre vie di completamento misurava. Corretto nella voce CP.03. |
| Il corpus dichiara la condizione in italiano e un generatore la deduce | Letto `tool/genera_sentieri_dal_corpus.py` | **VERA**: 1.634 righe di riconoscimento del testo. È la fessura strutturale da cui la condizione scritta e quella misurata possono divergere. |
| I dormienti sono pochi | Contati | **FALSA**: erano **51 su 165**, quasi un terzo del Cammino. |
| Il posto unico del congedo basta a chiudere il difetto | Simulato su 365 giorni | **FALSA, ed è la scoperta di quest'ordine**: vedi più sotto, "Le tredici feste". |

---

## LE REGOLE DEFINITIVE

Stanno per intero in **`docs/regole_dei_traguardi.md`**, e non in questo file:
un manifesto dice cosa è stato fatto una volta, le regole dicono cosa può
esistere. Sono scritte perché una prova possa verificarle su ogni singolo
gradino, e la prova è
`test/le_regole_dei_traguardi_sono_rispettate_test.dart`.

**La grandezza centrale è il costo in giorni**: il minimo numero di giorni
rituali distinti in cui una condizione può essere soddisfatta da chi ci prova
apposta. Un gradino che costa sette giorni non si fa in una sessione, e nessun
trucchetto lo accorcia. Vive come proprietà della condizione
(`CondizioneDelTraguardo.costoInGiorni`) e il generatore ne calcola una copia
indipendente in Python: la guardia che pretende il costo non decrescente
confronta di fatto le due.

---

## LE TREDICI FESTE, e perché la prima lettura della regola non bastava

La voce CP.01 era stata scritta come **un posto solo**: un gradino acceso
occupa il Cammino finché la sua festa non è congedata. Quel freno regge contro
il gesto ripetuto e **non regge contro il cielo**.

Misurato su 365 giorni, un utente nuovo che compie tutte e venti le arti nel
giorno peggiore dell'anno vedeva **tredici feste**: in una giornata con più
pianeti retrogradi insieme si aprono molte finestre del cielo
contemporaneamente, e ognuna arma il suo gradino. **Erano più delle otto che il
fondatore ha visto.**

La frase del fondatore, letta alla lettera, dice un'altra cosa: *"il gradino
non matura finché **il precedente** non è stato congedato."* Da ogni sentiero
può maturare solo il gradino che chi cammina sta per prendere. Con questa
lettura il giorno peggiore dell'anno porta **tre** feste, la media è
esattamente tre, e non c'è cielo abbastanza ricco da farne di più.

**Il rischio della scala si dichiara**: un gradino irraggiungibile la
bloccherebbe per sempre. Nella revisione F non ce ne sono, e due guardie lo
pretendono su tutti e 165.

**La conseguenza da dire ad alta voce**: il primo gradino di ogni sentiero è un
pezzo dell'identità, e finché non si prende quel sentiero non avanza. Chi non
legge mai la Costellazione del Viso non avanza sul Fiore di Loto. È un
cancello, ed è voluto.

---

## IL CORPUS, REVISIONE F, CONTATO

| | revisione E | revisione F |
| --- | ---: | ---: |
| Gradini | 165 | **165** |
| Per sentiero | 55 | **55** |
| Eos per sentiero | 2.010 | **2.010** |
| Eos in tutto | 6.030 | **6.030** |
| **Gradini che si chiudono in una sessione** | **45** | **3** |
| **Eos raggiungibili in una sessione** | **610** | **30** |
| **Dormienti** | **51** | **0** |
| Condizioni ripetute identiche | 0 | **0** |
| Specie di condizione usate | 16 | **7** |
| Gesti nominati | 31 | **20** |
| Gesti nominati senza una schermata che li mandi | 7 | **0** |
| Finestre del cielo | 21 | **48** |
| Eventi del cielo distinti nominati | 19 | **23** su 31 |

**Le famiglie, per sentiero.** Costellazione: cielo 17, profondità 19, ritorno
11, ampiezza 5, giornata 2, identità 1. Loto e Albero: cielo 17, profondità 18,
ritorno 12, ampiezza 5, giornata 2, identità 1.

**La scala dei costi**, uguale su tutti e tre i sentieri, in giorni:
1, 2, 2, 3, 3, 4, 4, 5, 5, 6, **8** · 9, 10, 12, 14, 15, 16, 18, 20, 25, 28,
**30** · 31, 35, 40, 45, 45, 55, 60, 60, 75, 80, **90** · 91, 100, 110, 120,
120, 140, 150, 160, 165, 170, **180** · 191, 200, 220, 240, 240, 280, 290, 300,
320, 340, **365**. In grassetto i cinque gradini grandi, che sono **sempre** una
finestra del cielo.

---

## VOCE CP.06, I DORMIENTI

**Zero.** Non sono stati svegliati: non sono stati scritti. La revisione F si
costruisce solo sui venti gesti che una schermata manda davvero e sui
trentuno eventi che il motore del cielo calcola. Un gradino dormiente resta un
gradino che qualcuno legge sul sentiero e non potrà mai prendere, e cinquantuno
erano quasi un terzo del Cammino.

Due conseguenze si dichiarano invece di lasciarle implicite:

- **La meditazione si è svegliata.** L'ordine BF le aveva dato una fine
  misurabile e il corpus della E la teneva addormentata lo stesso: adesso ha
  sei gradini, tutti vivi.
- **Tre premi sociali non hanno più un gradino.** L'invito accolto dipende da
  un'altra persona, e un gradino che dipende da qualcun altro non è
  raggiungibile da chi cammina. La porta resta, il conto arriva dal server, il
  premio in Eos si paga: solo, nessun gradino ci poggia sopra.

---

## VOCE CP.07, L'EVENTO CHE ARMA E LA CONDIZIONE SCRITTA

*"Non è una verifica a campione: è una riga per gradino."*

La prova è `test/l_evento_che_arma_e_la_condizione_scritta_test.dart`.

| misura | gradini guardati | esito |
| --- | ---: | --- |
| Si accende con la quantità che dichiara | **165** | 165 sì, **0 muti** |
| NON si accende con uno di meno | **165** | 165 trattengono, **0 generosi** |
| Una finestra del cielo non si apre col solo evento, senza il gesto | **48** | 48 trattengono |
| La catena intera dal gesto al gradino, per specie | 6 specie su 7 | tutte |

**E la fessura del testo è chiusa alla radice**: dalla revisione F la frase che
la persona legge **si compone dalla condizione**, quindi i numeri della frase
sono i numeri della condizione, perché vengono dallo stesso dato. Non possono
divergere nemmeno volendo.

---

## VOCE CP.08, LA SIMULAZIONE DI UN ANNO

Un anno di uso tipico: si apre l'app quasi ogni giorno, si salta un giorno ogni
undici e una settimana intera ogni tre mesi, si girano le arti.

| misura | revisione E | revisione F |
| --- | ---: | ---: |
| Feste il primo giorno | 3 | **1** |
| Feste cumulate alla prima settimana | — | **6** |
| Feste cumulate al primo mese | — | **12** |
| Feste cumulate al terzo mese | — | **29** |
| Feste in un anno | 68 | **55** |
| **Mesi senza nessuna festa** | **4** | **0** |
| Mesi vuoti con un gradino soddisfatto in attesa | 0 | **0** |
| Gradini soddisfatti e mai accesi a fine anno | 0 | **0** |
| Contese fra gradini sullo stesso evento | 0,6% | **0,5%** |
| **Il giorno peggiore dell'anno** | — | **2 feste** |

**Il criterio proposto, e resta aperto finché il fondatore non decide.**
Nessun giorno dell'anno deve portare **più di tre feste**. Tre è il numero dei
Maestri, ed è il massimo che la prima sessione può dare per costruzione. La
prova lo tiene già come soglia; il fondatore lo approva o lo cambia con una
riga.

**E la misura più dura**: un utente nuovo che compie **tutte e venti le arti**
nella prima sessione, provato su ognuno dei 365 giorni dell'anno, vede in media
**3,00 feste** e nel giorno peggiore **3**.

---

## VOCE CP.09, LA SIMULAZIONE DELL'ABUSO

La prova è `test/aprire_e_chiudere_non_e_un_cammino_test.dart`.

| cosa fa la persona | feste |
| --- | ---: |
| Apre e chiude la stessa funzionalità **otto volte di fila** in quattro minuti | **0** |
| Apre l'Oroscopo **quattro volte in due minuti**, cambiando orizzonte ogni volta | **0** |
| Alterna **due funzionalità, quattro aperture ciascuna** | **0** |
| Prova **sette arti diverse** in un giorno solo, da utente nuovo | **3** |
| Le stesse sette arti **senza mai congedare** una festa | **1** |

Le tre difese si sommano, e la prova le misura una per una: il conto una volta
al giorno per gesto e dettagli (CP.02), il posto unico del congedo dentro la
scala (CP.01), il costo in giorni del corpus (CP.05).

**Una regola di forma chiude l'abuso alla radice**: nessun gradino conta le
aperture, tutti contano i **giorni**. Il freno della voce CP.02 da solo non
bastava, e va detto: quel freno guarda il gesto insieme ai suoi dettagli,
quindi quattro aperture dell'Oroscopo su quattro orizzonti diversi sono quattro
chiavi diverse e passano. A trattenerle è il corpus.

---

## COSA È STATO TROVATO STRADA FACENDO

**Una guardia cieca, e la Regola B l'ha colta.** Sostituendo la soglia di
`StessaOraPerGiorni` con uno zero, cioè rendendo il gradino sempre raggiunto,
`le_condizioni_costruite_test` restava **verde in tutte e tre le sue prove**:
provava che la condizione si accende, mai che **trattiene**. Difetto della
voce **BW.07**, che scrisse la guardia senza il caso negativo. Riparata, e la
riparazione è nata rossa.

**Una guardia legata a un indirizzo invece che a un fatto.** La stessa
`le_condizioni_costruite` cercava **diciannove** gradini scrivendo il loro
identificativo: `med_34` non è più l'ora fedele, è il cielo del solstizio. Un
id è un indirizzo, e un indirizzo cambia. Adesso le condizioni si
**costruiscono**, e quattro specie che il corpus non usa più restano
sorvegliate lo stesso.

**Un elenco di espressioni regolari cieco a ogni specie nuova.**
`ogni_arte_entra_nel_cammino` leggeva i file dei sentieri come testo, con uno
schema per specie di condizione: `GiornateInsieme` non c'era, e sette gesti per
gradino sarebbero spariti dai nominati. Era già successo nell'ordine **AU** con
`GiorniDentroUnArco`. Adesso la domanda si fa all'oggetto, e una specie nuova
che non risponde **non compila**.

**Due difetti di lingua nelle frasi generate, trovati leggendole.**
"dell'tramonto", da una preposizione incollata senza tavola, e "L'arcano del
giorno", da `capitalize()` che alza la prima lettera e abbassa tutto il resto.
Nessuna prova che conta i gradini poteva vederli. Adesso il generatore si
rifiuta di scriverli e una guardia li ferma anche sui file generati.

**LA FRASE PIÙ LUNGA DEL CAMMINO ERA DI 178 CARATTERI, e non l'hanno trovata
le anteprime.** Contro i 66 della revisione E. Era `cal_53`: *"320 giornate
chiuse con il Bosco del Cerchio, la gettata di rune, la runa girata, il
Sigillo d'Intenzione, il Sigillo del Sogno e la Runa del Tramonto, tutte nello
stesso giorno."* Un elenco di sei arti dentro il testo che una persona legge
nel momento della festa non si legge: si scorre.

**Come si è visto, e vale più del rimedio.** Non dalle immagini: la cattura
della festa prende un fotogramma in cui la spirale di stelle copre il testo,
quindi la frase più lunga del Cammino **non compare in nessuna anteprima**.
L'ha trovata il conto dei caratteri, confrontato con quello della revisione
precedente. Da questo confronto sono usciti tre difetti nello stesso posto:
l'elenco delle sei arti, la coda spiegativa dell'ora rituale (*"quella del
cielo e non quella dell'orologio"*, che portava una frase a 101 caratteri) e la
porta più lunga del cammino, 82 caratteri.

Adesso: **frase più lunga 89 caratteri, nessuna sopra 90**, mediana 63 contro
i 53 della revisione E. Due arti si nominano, tre o più si contano.

**Un magazzino troppo corto.** `quantiGiorniPerRito` teneva **140** giorni per
rito, e la revisione F porta archi fino a **340**: i gradini lunghi sarebbero
stati muri silenziosi. Portato a **400**, dichiarato in circa novanta chilobyte
per l'intero cammino.

---

## COSA RESTA APERTO, con il suo nome

- **Regola 8, i Maestri devono saperlo.** Il motore delle date esiste
  (`ProssimiEventi`, orizzonte di 400 giorni, usato dal Calendario e dalla
  barra dell'identità); **il ponte verso il contesto delle chat no.** Il corpus
  non lo può soddisfare da solo.
- **Regola 9, i promemoria a una settimana.** Ogni evento nominato dai 165 ha
  una data futura calcolabile, ed è verificato su tutti e 23. **Chi manda
  l'avviso non è ancora costruito.**
- **Il criterio della voce CP.08** è proposto, non approvato.

---

QUANTE FESTE VEDE OGGI UN UTENTE CHE APRE E CHIUDE LA STESSA FUNZIONALITÀ OTTO
VOLTE DI FILA, PRIMA E DOPO QUESTO ORDINE.

**Prima: otto. Dopo: zero.**

---

## LE VOCI E IL LORO STATO

**Sigillato con l'ordine CQ voce 4.01, 4 settembre 2026.** Il Collaudatore
degli Ordini prende solo manifesti terminali e sigillati: senza questo blocco
saltava questo ordine e andava a ritroso, quindi **nessuno lo ha mai
collaudato**. Le due regressioni viste dal fondatore la sera del 3 settembre
nascono qui dentro e sarebbero state intercettate.

**Lo stato scritto e' quello vero, non quello comodo.** Un manifesto sigillato
con stati falsi e' peggio di un manifesto non sigillato, perche' fa passare il
Collaudatore su una menzogna.

- **CP.01** Il gradino non matura finche' il precedente non e' congedato. **FERMATA SU DECISIONE DEL FONDATORE**: la scala ha portato le feste del giorno peggiore da tredici a tre, e **ha murato il Cammino**. Misurato dall'ordine CQ voce 2.12: su quattrocento giorni di uso onesto, centododici traguardi soddisfatti e TREDICI accesi. Il fondatore ha deciso con la voce CQ 2.13 che il tetto ferma la scena e non l'accensione.
- **CP.02** Lo stesso gesto conta una volta al giorno. **CHIUSA.**
- **CP.03** I dettagli che dicevano il falso. **CHIUSA.**
- **CP.04** I centosessantacinque traguardi riscritti da zero. **CHIUSA.**
- **CP.05** Lo stato generoso costruito dal corpus. **CHIUSA.**
- **CP.06** I dormienti. **CHIUSA.**
- **CP.07** L'evento che arma e la condizione scritta. **CHIUSA.**
- **CP.08** La simulazione di un anno. **FERMATA IN ATTESA DI DECISIONE**: il criterio di accettazione e' proposto e **non approvato dal fondatore**. La simulazione c'e' ed e' verde, ma il numero che la dichiara buona non e' ancora stato deciso.
- **CP.09** La simulazione dell'abuso. **CHIUSA.**
- **CP.10** Il manifesto e la guardia dell'ordine. **CHIUSA.**

VOCI_TOTALI: 10
VOCI_CHIUSE: 8
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 1
