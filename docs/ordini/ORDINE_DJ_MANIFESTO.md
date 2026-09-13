# ORDINE DJ, LA VOCE DEL VIAGGIO E LE CODE APERTE

**Sigla:** DJ. **Data:** 13 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Segue l'ordine DI, commit
`86a95f25`, e ne chiude le pendenze.

**Vincolo permanente:** tutta l'intelligenza a runtime gira su Gemini e
Vertex AI, mai su API Anthropic. **Nessuna build senza ordine del fondatore.**

VOCI_TOTALI: 11
VOCI_CHIUSE: 6
VOCI_SBLOCCATE_E_APERTE: 5

---

## DJ.01, I TITOLI DA OTTO A VENTIQUATTRO PER TEMA. CHIUSA

`LaVoceDelMondoDiSotto.titoliPerTema` porta i centoquarantaquattro titoli
dell'ordine, ventiquattro per tema, **nell'ordine in cui il fondatore li ha
scritti**. Il doppione del tema *finito*, *"Quello che hai imparato resta"*, e'
uscito. La struttura non cambia: restano costanti, resta il filo che li
sceglie. I quattro titoli senza domanda sono quelli di prima.

**Tre titoli hanno la forma che rispetta le regole permanenti del
fondatore**, e il senso non cambia:

| scritto nell'ordine | a schermo | la regola |
|---|---|---|
| *Non ti serve essere sicuro* | *Non ti serve la certezza* | la seconda persona non dice il genere di chi legge |
| *Se arrivasse domani, saresti pronto* | *Se arrivasse domani, avresti tutto pronto* | la stessa |
| *E' finito, e va bene cosi'* | *E' finito: va bene cosi'* | nessuna proposizione dopo la virgola comincia con la *e*; ed e' la forma che il titolo aveva gia' |

**Le guardie le hanno viste tutte e tre**, col testo dell'ordine scritto
parola per parola: `language_rule` la virgola, `la_scena_parla_bene` il
*saresti pronto*. **Il terzo, *essere sicuro*, `la_scena_parla_bene` non lo
vedeva**: cercava l'aggettivo al maschile soltanto dopo il verbo coniugato,
*sei, eri, saresti, sarai, fossi*. E' la Regola B che ha trovato una guardia
cieca prima del lavoro. Adesso cerca anche dopo *essere, esserne, stare,
restare, rimanere, sentirti*, e col testo dell'ordine e' rossa sui due
maschili.

**La misura, prova a cento discese senza rete, coi soli titoli nuovi**: il
titolo piu' ripetuto su cento discese scende da 13 o 14 volte a **5**, in
tutti i temi e nelle domande libere capite. Le cinque misure restano dentro
le soglie: C al massimo 37,4, D al massimo 2.

---

## DJ.02, LA MEMORIA DEI TITOLI GIA' VISTI. CHIUSA

**Il principio e' del fondatore, ed e' quello che ha deciso la forma**:
aumentare i titoli sposta la ripetizione, ricordarsi cosa la persona ha gia'
letto la toglie.

**Dove sta la memoria.** Nel Diario, accanto a cio' che gia' si conserva per
ogni discesa, e senza strutture nuove: `UnViaggio` porta il **titolo** che la
discesa ha mostrato, e con lui la **risposta** e l'**azione** cosi' come
stanno nei loro elenchi. La stessa discesa riaperta mostra lo stesso titolo,
perche' si conserva e non si ricalcola. I Diari scritti prima dell'ordine DJ
non hanno questi campi, restano nulli e la voce li salta. **La composizione
sta in un posto solo**: `IlResponsoDelViaggio.componi` riceve la storia del
Diario e `comeSiConserva` restituisce la discesa da segnare, e li chiamano
tutti e due la schermata e la prova a cento discese.

**Il mazzo dei titoli e' un giro fisso per tema**, mescolato una volta: il
titolo di oggi e' quello che viene dopo l'ultimo letto su quel tema, saltando
quelli gia' usciti nel mazzo in corso, e il mazzo finito ricomincia **nello
stesso ordine**. Cosi' lo stesso titolo non torna prima di ventiquattro
discese sullo stesso tema **in qualunque finestra**, non soltanto nel primo
mazzo: un mazzo rimescolato a ogni azzeramento avrebbe potuto rimettere
l'ultimo titolo di un giro in testa a quello dopo. **I quattro titoli senza
domanda restano com'erano**, anche nel modo di sceglierli: nel mazzo fisso
tornavano ogni quattro discese insieme alla stessa risposta, e la
somiglianza era al 40,0 per cento.

**Le risposte escludono le ultime sei lette sullo stesso tema**, come dice
l'ordine. **E l'azione esclude le ultime dieci lette su qualunque tema**:
l'ordine non lo chiede, ed e' lo stesso principio. Le venti azioni sono le
stesse per tutti i temi, e chi alterna i temi poteva leggere la stessa azione
due giorni di fila. Lo dichiaro come estensione.

**IL DIFETTO CHE LA MEMORIA HA SCOPERTO NEI CICLI.** Con ventiquattro titoli
il ciclo della risposta, che saltava avanti di un posto ogni sessanta giorni,
riportava **lo stesso titolo con la stessa risposta ogni ventiquattro
giorni**. Un calcolo su ogni partenza possibile ha misurato, per ogni
periodo di salto, dopo quanti giorni torna la coppia, dopo quanti tornano
insieme titolo e risposta, e la distanza minima della risposta:

| risposte | salto | la coppia torna | titolo e risposta insieme | la risposta torna |
|---|---|---|---|---|
| 12 | 60, prima | 200 giorni | 24 giorni | 11 |
| 12 | **11, adesso** | **220 giorni** | **oltre 263 giorni** | **11** |
| 8, senza tema | 40, prima e adesso | 140 giorni | i titoli girano a parte | 7 |
| 8, senza tema | 20, scartato | 160 giorni | | 7 |

Il salto di venti per le risposte senza tema e' stato scartato **dalla
prova, non dal calcolo**: la coppia restava unica piu' a lungo, ma una
domanda libera andava al 40,7 per cento.

**Per chi scende ogni giorno sullo stesso tema i cicli bastano da soli**, e
la memoria non cambia niente. Per chi scende in un altro modo il nucleo, cioe'
la coppia risposta e azione, prende il primo posto del ciclo che non ripete
una delle ultime sei risposte, una delle ultime dieci azioni o una coppia gia'
letta su quel tema; e fra questi, se c'e', quello che non riporta il titolo di
oggi con una risposta o un'azione con cui e' gia' uscito.

**Le stesure scartate, con la loro misura**, prova a cento discese senza rete:

| stesura | la misura che l'ha fatta cadere |
|---|---|
| risposta e azione che saltano ciascuna per conto suo | C fino all'80,0 per cento: la coppia smetteva di essere unica, e le cornici, che dipendono dalla coppia, tornavano identiche |
| fra i posti possibili quello letto piu' lontano | l'azione dopo 18 discese invece di 20, e la C al 71,2 per cento |
| il titolo confrontato solo con la sua ultima uscita | stesso titolo, risposta e cornice a quarantotto discese, C al 71 per cento |
| la regola del titolo anche senza tema | con quattro titoli chiudeva ogni strada, la stessa azione a una discesa di distanza |
| la coda della risposta dalla coppia | *Il resto e' rumore* due volte con la stessa risposta, C al 40,0 per cento: adesso la coda gira col giro della risposta, e la stessa risposta non torna con la stessa coda per dodici giri |

**La misura, a stesura finale**, prova a cento discese senza rete: C fra 28,6
e 34,4 per cento su tutte le coppie, D al massimo 2, **F: nessuna finestra di
ventiquattro discese con un titolo ripetuto**, in tutti i temi e nelle tre
domande libere capite; la stessa azione dopo 20 discese, la stessa risposta
dopo 11. **Il titolo piu' ripetuto su cento discese: 5 volte**, era 13 o 14.

**La guardia nuova**, `test/la_voce_si_ricorda_test.dart`, scende come la
prova a cento discese non scende: sullo stesso tema ogni 11, 12 e 20 giorni,
e a temi alternati. **Sette rossi**, uno per pretesa e piu': con la memoria
spenta 59 risposte ripetute ogni undici giorni, 37 finestre su 37 con un
titolo ripetuto ogni dodici, 29 azioni ripetute a temi alternati; senza il
divieto della coppia 49 coppie ripetute ogni venti giorni; il mazzo che salta
un posto, quattro prove rosse; il titolo che non si conserva, la discesa
riaperta rossa. **Il primo rosso ha trovato la guardia cieca**: col solo passo
di dodici giorni la pretesa sulla risposta era verde anche senza memoria, e i
passi sono diventati tre.

---

## DJ.04, LA FRASE DELL'INGRESSO AL VELO. CHIUSA, CON UNA PREMESSA DA CORREGGERE

**La premessa dell'ordine non corrisponde al codice, e lo dico prima di
tutto.** L'ordine dice che l'ingresso al velo oggi recita *"Trascina il dito
per svelare"*. **Quella frase non e' del velo**: e' della rivelazione del
Maestro nell'onboarding, `maestro_reveal_screen.dart`, dove si soffia sulla
candela, sulla sfera o sul soffione, oppure si trascina il dito sull'oggetto.
Li' di cenere non ce n'e', e *"Scosta la cenere con il dito"* sarebbe falsa.
Il mio rapporto dell'ordine DI la citava fra le frasi cambiate, ed e'
probabilmente da li' che e' nato lo scambio.

**La frase che accoglie al velo di cenere** era *"Passa il dito e scosta la
cenere."*, in `il_velo_che_si_scosta.dart`. **Adesso e' quella del
fondatore**: *"Scosta la cenere con il dito."*

**La rivelazione del Maestro resta com'e'.** Se il fondatore vuole che parli
anche lei la lingua della sua materia, la proposta e' nel rapporto: una
frase per oggetto, perche' la candela, la sfera e il soffione non si toccano
nello stesso modo.

**La prova.** Nessuna guardia pretendeva la frase dell'ingresso. La pretesa
sta ora in `il_gesto_che_scosta`, sulla schermata vera, arrivati al velo:
rossa con la frase di prima, verde con quella nuova.

---

## DJ.07, IL CONTO DELLE DISCESE NEL DIARIO. CHIUSA

**Il difetto**, dall'ordine DC voci 04, 05, 06, 08 e 09: `quanteDiscese` era
la lunghezza della lista, e la lista ne conserva novanta. Dalla novantunesima
discesa il conto restava fermo, il riassunto per i Maestri diceva *"ha fatto
90 discese"* per sempre, e il numero della discesa smetteva di entrare nel
seme della scena.

**Adesso e' un conto suo**, sotto la chiave `viaggio.quante`, che cresce a
ogni discesa anche quando la lista, piena, ne lascia uscire una. La lista
resta a novanta. La chiave sta sotto il prefisso `viaggio.`, quindi lo scarico
dei dati e la dimenticanza la prendono con le altre senza cambiare niente; il
comando di demo che fa ricominciare la toglie per nome.

**Ogni punto che diceva quante discese sono state fatte passava gia' da
`quanteDiscese`**, contato col grep: la schermata del Viaggio in tredici punti,
il Passaporto, il Santuario, la schermata dei Maestri, il riassunto, il nome
che si puo' dire e il seme della scena. **Uno solo leggeva la lista
direttamente**: il conto noto a chi non puo' aspettare, in `carica`, che ora
legge il conto. `cheTorna` guarda ancora la lista, ed e' giusto: conta gli
elementi delle scene conservate, non le discese.

**Chi aveva gia' un Diario comincia dalla sua lista.** Chi aveva passato le
novanta discese riparte da novanta: le discese uscite dalla lista non si
possono piu' contare, e da li' il conto cresce giusto. Il conto non vale mai
meno della lista, anche se sul telefono fosse scritto male.

**La prova**, `test/il_conto_delle_discese_non_si_ferma_test.dart`:
novantacinque discese danno novantacinque nel conto, nel riassunto e nel
Diario riaperto, con la lista a novanta; un Diario di prima comincia da
novanta e va a novantuno; un conto sotto la lista non vale; il comando di demo
lo azzera. **Rossa col conto di prima**, due prove su tre.

---

## DJ.05, SI TOGLIE IL CODICE CHE NESSUNO RAGGIUNGE. CHIUSA

**`siPuoComprareAncora` e' uscita**, con la costante `laRivelazioneSiCompra`
che esisteva soltanto per lei. La regola che difendevano resta, e resta
sorvegliata **dove una discesa si potrebbe vendere davvero**: la prova dei
tetti non chiama piu' la funzione, pretende che il listino dei budget del
server, `functions/src/budget.ts`, non abbia un budget per le discese, per il
Viaggio, per la rivelazione o per i segni, e che nessuno dei trentacinque file
del Viaggio importi le due porte che spendono gli Eos. **Due rossi**: un
budget `discese` innestato nel server, e un import della porta del Cerchio
innestato nei tetti.

**IL CENSIMENTO.** Uno script ha letto i trentacinque file del Viaggio,
11.614 righe, e per ognuno dei 445 simboli dichiarati (tipi, membri statici,
metodi e getter pubblici, funzioni) ha contato i riferimenti nel resto di
`lib` e nelle prove; poi ha cercato le condizioni costanti. **La prima
stesura era cieca**: scriveva lo stesso file in due modi, contava la riga
della dichiarazione come un riferimento, e nessun simbolo poteva risultare
orfano. Corretta, ha trovato quindici simboli che nessun punto di `lib`
chiama e un `if (true)`.

**Tolti perche' mai raggiunti**, righe commenti compresi, e il padre di ogni
orfano, da `git log -S`:

| simbolo | file | righe | come e' rimasto senza chiamanti |
|---|---|---|---|
| `siPuoComprareAncora` e `laRivelazioneSiCompra` | `tetti_del_viaggio.dart` | 17 | nate cosi', ordine DE voce 14; dalla voce DI.15 tornavano sempre falso |
| `siPuoNutrireOggi` | `diario_dei_viaggi.dart` | 12 | dalla voce DI.13, mia: il tamburo e' aperto sempre e conta un giorno solo |
| `siPuoScendereOggi` | `diario_dei_viaggi.dart` | 12 | dalla voce DE.14: la porta vera e' `TettiDelViaggio.siPuoScendere` |
| `quanteNeRestano` | `tetti_del_viaggio.dart` | 14 | nata senza chiamanti, voce DE.14 |
| `contorniDellaSagoma` | `i_quattro_viaggi.dart` | 6 | dalle voci DE.07, DE.08 e DE.09: il Passaporto racconta l'avvicinamento con una riga, non coi contorni |
| `quanteOmbre` | `i_quattro_viaggi.dart` | 3 | dalle voci DG.01-06: le ombre fra cui scegliere non ci sono piu' |
| `quantoDuraUnVarco` | `la_nebbia_e_l_animale.dart` | 7 | nata senza chiamanti, voce DC.07 |
| `leTreInformazioni` | `la_promessa_del_viaggio.dart` | 6 | nata senza chiamanti, voci DI.07 e DI.08, mie |
| `alGiro` | `la_voce_del_mondo_di_sotto.dart` | 10 | dalla voce DI.16, mia: i posti si leggono da `mescolato` |
| il ramo `if (true)` | `viaggio_dello_sciamano_screen.dart` | 2 | resto di una condizione tolta: il verso dell'animale si chiede sempre, senza condizione |

**Stavano in `lib` e servivano soltanto alle prove**: spostati nelle prove,
dove si leggono. Una costante o una funzione in `lib` che nessuna schermata
usa dice a chi legge che l'app la usa.

| simbolo | righe tolte da lib | dove sta adesso |
|---|---|---|
| `DoveStaLaTesta.quantiSono` | 5 | le due prove della testa contano `DoveStaLaTesta.nomi` |
| `chiusureSulNonDecifrare` | 4 | il due, nella prova `la_scena_parla_bene` |
| `LAnnuncioDellAnimale.parolePromesse` | 16 | la lista, col suo perche', nella prova dell'annuncio |
| `LApparizione.quanteASettimana` | 11 | la funzione, nella prova dell'apparizione |
| `GirandolaDegliAnimali.quantiSonoDavvero` | 5 | la prova conta i totem **a schermo**, per file, invece di chiedere il numero a una funzione |
| `IlBoscoDellaSoglia.quantiTronchi` | 4 | nessuna prova la chiamava |

**Resa raggiungibile invece di tolta**: `IQuattroViaggi.siPuoNominare`, *il
nome si dice alla quarta discesa*. `IlResponsoDelViaggio` riscriveva la
stessa regola a mano; adesso la chiede alla funzione, e la regola sta in un
posto solo.

**Le prove che difendevano una regola ancora viva passano dalla porta vera**:
i quattro giorni del riconoscimento da `TettiDelViaggio.siPuoScendere` col
conto del Diario; il tamburo dalla regola della voce DI.13, quattro colpi
nello stesso giorno avvicinano quanto uno; la Demo senza tetti da
`siPuoScendere` a novecentonovantanove discese. **Le due prove dei contorni
della sagoma sono uscite con la funzione**: difendevano una cosa che nessuna
schermata disegna.

**Il conto**: 145 righe tolte da `lib`, 25 aggiunte, tutte commenti che
dicono che cosa c'era e perche' e' uscito. Analisi a zero.

**I limiti del censimento, detti.** Trova i simboli senza chiamanti e le
condizioni costanti. **Non trova** un parametro passato sempre con lo stesso
valore, come il `sopraLaRoccia` che la voce DI.09 aveva trovato leggendo, ne'
un ramo che dipende da un valore che nella realta' non arriva mai. I membri
privati li sorveglia gia' l'analisi, che e' a zero. Il ramo della Demo non e'
morto: dipende da una chiave di configurazione, `AppFlags.isDemo`.

---

## DJ.08, I GESTI DEL SEGNO DA SEI A TRE. CHIUSA

**Il repertorio e' di tre gesti, per tutti e dodici gli animali**, con le
parole e i significati dell'ordine:

| gesto | nel file | vuol dire | come lo fa |
|---|---|---|---|
| si avvicina | `si_avvicina` | la risposta e' si', oppure vai avanti | *ti si avvicina* |
| si volta | `si_volta` | guarda meglio, non hai visto tutto | *si volta a guardare dietro di se'* |
| si allontana | `si_allontana` | la risposta e' no, oppure non adesso | *si allontana di qualche passo*; gli uccelli *in volo*, il Serpente *strisciando* |

**Il significato entra nell'istruzione al modello**, gesto per gesto, e
l'istruzione gli chiede di scegliere il gesto il cui significato risponde
alla domanda e di scrivere la riga con quel significato: prima il modello
sceglieva un gesto senza sapere che cosa volesse dire. **La via di riserva
dice la stessa cosa**: tre letture per gesto, coi significati dell'ordine,
nessuna col genere di chi legge. Lo schema della risposta non ha piu' il
campo della cosa portata.

**Usciti col gesto che la portava**: la cosa portata nel segno, nel Diario e
nello schema, e la luce che nasceva dove sta la bocca. I segni conservati
prima dell'ordine con uno dei tre gesti tolti restano righe da rileggere:
il nome del gesto e la riga sono testo, e nessuno li riporta al repertorio.

**I trentasei disegni** hanno il nome che dice l'ordine,
`assets/img/mondo_di_sotto/gesti/<animale>_<gesto>_v1.webp`, dove `<animale>`
e' il nome delle dodici illustrazioni: `lupo` da `ani_lupo_v1`. Li elenca
`GestiDelSegno.disegniAttesi`, e il `LEGGIMI.md` della cartella li scrive
tutti per chi li disegnera'. **La cartella e' dichiarata nel pubspec anche da
vuota**, e il manifesto degli asset la conosce: il giorno che un disegno
arriva, il segno lo mostra senza che nessuno tocchi il codice. **Oggi ci sono
zero disegni su trentasei.**

**Finche' un disegno manca, il segno mostra l'illustrazione intera
dell'animale, che si muove col gesto, e la riga.** Si chiede al pacchetto se
il disegno c'e', come per il verso dell'animale, e la risposta si ricorda;
finche' il pacchetto non ha risposto si vede l'illustrazione, mai un
riquadro vuoto. **Quando il disegno c'e'** compare mentre il gesto accade, e
l'illustrazione non si muove piu': il gesto e' gia' disegnato.

**Le prove**, in `la_vita_dopo_il_riconoscimento`: i tre gesti e i loro nomi
nei file, i tre gesti tolti rifiutati se il modello li scrive, i tre
significati nell'istruzione, la riserva che su cento domande dice cio' che il
suo gesto vuol dire, i trentasei nomi nella forma dell'ordine e nel LEGGIMI,
la cartella nel pubspec, e il segno a schermo con il disegno e senza. **Due
rossi**: il disegno ignorato anche quando c'e', e l'istruzione senza i
significati. Una pretesa era sbagliata la prima volta, ed era la prova: in
Dart il confine di parola non riconosce la *i* accentata di *si'*.

---
