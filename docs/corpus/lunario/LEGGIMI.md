# Il corpus del Calendario Lunare

Ordine FV voci FV.06 (Trova il giorno) e FV.07 (I giorni tuoi), 15 ottobre
2026. Metodo degli altri corpus del ramo (l'Oracolo degli Angeli, la
Sinastria evolutiva): la fonte sta in file di testo leggibili, uno strumento
senza modello la controlla e genera il Dart. **Nessun testo di questa
cartella viene da Gemini o da un altro modello** (regola R2 dell'ordine FV e
regola SPESE di CLAUDE.md): lo scrive Code, dalle tradizioni che cita.

## I tre file

- **fonti.md**: le fonti vere, una per cella "### id" con quattro righe
  (`citazione`, `indirizzo`, `letta`, `dice`). Ogni regola di `regole.md` deve
  puntare a una o piu' fonti di qui.
- **regole.md**: le regole lunari per attivita', una per cella "### id". Le
  legge e le applica `lib/core/lunario/le_regole_del_lunario.dart`.
- **testi.md**: i testi che non sono legati a una regola (oggi solo i quattro
  giorni tuoi di FV.07), organizzati in sezioni "## sezione" con righe "-
  chiave: testo".

## La grammatica di regole.md

Ogni cella porta queste righe, in un ordine qualsiasi:

```
### id_della_regola
- attivita: nomeAttivita[,altraAttivita...]
- quando: chiave=valore[,valore2,...][; chiave2=valore...]
- peso: +N   (oppure)   - effetto: toglie_oro
- fonti: id1[, id2...]
- detto: il testo breve che compare nel perche' del giorno
```

**id_della_regola** e' un nome snake_case, unico in tutto il file.

**attivita** sono uno o piu' nomi dell'enum `AttivitaDelLunario` (lib/core/
lunario/le_attivita_del_lunario.dart), per esempio `semina`, `nozze`,
`primoAppuntamento,dichiarazione,nozze`. Una regola con piu' attivita' vale
per ciascuna.

**quando** e' la condizione: dentro una chiave, piu' valori separati da
virgola sono in OR (vale se il giorno combacia con uno qualsiasi); piu' chiavi
separate da punto e virgola sono in AND (devono valere tutte insieme). Le
chiavi valide e i loro valori:

- `luce`: `crescente` (dalla Luna nuova alla piena) o `calante` (dalla piena
  alla nuova). Legge `GiornoLunare.crescente`.
- `fase`: una delle otto fasi di `FaseLunare` per nome dell'enum: `nuova`,
  `crescente`, `primoQuarto`, `gibbosaCrescente`, `piena`, `gibbosaCalante`,
  `ultimoQuarto`, `calante`. Legge `GiornoLunare.fase`.
- `segno`: uno o piu' segni di `Zodiac` per nome inglese minuscolo (`aries`,
  `taurus`, `gemini`, `cancer`, `leo`, `virgo`, `libra`, `scorpio`,
  `sagittarius`, `capricorn`, `aquarius`, `pisces`). Legge
  `GiornoLunare.segno`.
- `bio`: uno dei quattro tipi di `TipoBiodinamico` per nome dell'enum:
  `radice`, `foglia`, `fiore`, `frutto`. Legge
  `GiornoLunare.tipoBiodinamico`: **tace** (la regola non vale, ne' a favore
  ne' contro) quando il giorno non ha un tipo biodinamico documentato
  (l'Ofiuco di `IlMotoreLunare.confiniDelleCostellazioni`), non viene
  trattato come un difetto del giorno.
- `fuoricorso`: `si` o `no`. Legge `GiornoLunare.haFuoriCorso`.

**peso** e' un intero con segno: positivo spinge il giorno verso l'oro,
negativo verso l'evitare. Il segno piu' si puo' omettere (`peso: 2` vale come
`peso: +2`), il segno meno no.

**effetto: toglie_oro** e' l'alternativa a `peso` per le regole della Luna
fuori corso (R8 dell'ordine FV: "Le ore fuori corso tolgono l'oro a inizi,
firme, amore e viaggi"): quando una regola con questo effetto vale, il
giorno NON PUO' essere oro per quella attivita', indipendentemente dalla
somma dei pesi. Una regola non porta mai `peso` ed `effetto` insieme: chi ne
ha bisogno scrive due regole.

**fonti** sono uno o piu' id di `fonti.md`, separati da virgola.

**detto** e' il testo che compare nella lista `EsitoDelGiorno.perche` quando
la regola contribuisce. **Eccezione**: le regole con `fuoricorso=si` nella
condizione non usano `detto` per il perche' a video, perche'
`LeRegoleDelLunario.valuta` compone al suo posto la riga vera con gli orari
di `GiornoLunare.fuoriCorso` (per esempio "Fuori corso dalle 3:10 alle
5:40"), come vuole l'ordine FV: il `detto` resta comunque obbligatorio e
controllato, perche' documenta la regola a chi legge la fonte e serve da
riparo se il calcolo degli orari dovesse mai mancare.

## La politica dei testi (R7, R8)

Lo stesso linguaggio di casa degli altri corpus, piu' le parole proprie di
R8:

- italiano con gli accenti veri (è, più, perché, già, così, può, cioè),
  nessun apostrofo che non sia un'elisione vera;
- mai una virgola prima di "e" o di "ed";
- mai il trattino lungo;
- nessuna parola ripetuta due volte di fila;
- nessun verbo al futuro detto come certezza, nessuna formula di certezza
  ("sicuramente", "garantito", "vedrai che"...);
- **niente salute**: nessuna regola o testo su interventi, cure, dentista,
  diete, digiuni, farmaci, guarigione;
- **niente soldi e investimenti**: nessuna regola o testo su guadagno,
  investimento, garanzia di ritorno;
- **nessuna promessa di esito**: la Luna indica il momento, non garantisce
  il risultato (niente "successo assicurato", "vittoria certa");
- **niente fertilita' o fecondita'**: la fase di nascita (FV.07) e' un
  contenuto simbolico, non un calcolo di concepimento (PRIMA VIA, LA
  SIMBOLICA, 4 settembre 2026);
- **la NASA non si nomina mai** nei testi di Medora (le immagini della Luna
  sono della NASA per la voce FV.03, ma la voce non lo dice: le linee guida
  della NASA vietano, nei prodotti con intelligenza artificiale, frasi come
  "secondo la NASA");
- **cio' che viene da una tradizione si cita con la sua fonte**: ogni regola
  di regole.md punta a una fonte vera di fonti.md. Cio' che non e'
  documentato si dichiara `chiave_di_medora` (vedi sotto), mai tradizione.
- il disclaimer di casa (come nelle altre arti) si mostra una sola volta
  a onboarding, mai qui: questo corpus non lo ripete.

## Chiave di Medora

`fonti.md` porta una fonte speciale, `chiave_di_medora`, che non e' una
fonte vera: dichiara che un testo o un modo di combinare le regole viene
dalla lettura propria di Medora e non da una tradizione. **Nessuna regola di
questo corpus la usa da sola** come unica fonte: ogni attivita' del
contratto (`AttivitaDelLunario`) ha almeno una regola con una fonte
documentata vera, e lo strumento lo controlla. La chiave di Medora resta
dichiarata per il modo in cui piu' regole insieme fanno un giorno d'oro (la
somma dei pesi e l'effetto `toglie_oro`), che e' una scelta di progetto e
non una tradizione, e per qualunque testo futuro che non abbia una fonte
citabile.

## Perche' il `detto` non e' sempre quello che si vede a video

Per `luce`, `fase`, `bio` e `fuoricorso` il valore della condizione e' unico
o la frase e' vera per costruzione (una fase ha un nome solo, un tipo
biodinamico ha un nome solo). Per `segno` le regole di questo corpus usano
spesso un insieme di segni (per esempio i quattro mobili): il `detto` allora
descrive la CATEGORIA ("in un segno mobile"), non il singolo segno, perche'
resta vero qualunque segno dell'insieme sia quello vero del giorno. Una
regola che vuole nominare un segno solo lo mette da solo in `segno=`.

## La prova vista rossa

`test/il_corpus_del_lunario_test.dart` pretende che il Dart generato
coincida con la fonte rigenerata, che ogni regola abbia una fonte vera, che
ogni attivita' del contratto abbia almeno una regola con una fonte diversa
da `chiave_di_medora`, e che nessun testo porti una parola vietata da R7 o
R8. L'innesto e l'esito sono nel rapporto dell'ordine, non qui: questo file
descrive solo la forma del corpus, non la sua storia.
