# Le affermazioni di Da dove viene e del metodo, ordine EU voce 14

1 ottobre 2026.

Questo file contiene ogni frase fissa (o modello di frase coi segnaposti, riportato tale e quale) che l'Oroscopo mostra nella riga "Da dove viene" e nella nota del punto interrogativo del metodo ("Come nasce questa lettura"), in Occidentale, Vedica e Cinese, per Giorno, Settimana e Mese, Anno; accanto a ognuna, la fonte che il codice o il corpus le dà. L'Architetto le verifica una per una. Fatto leggendo i file, non a memoria: le frasi dei tre corpora sono estratte riga per riga dal file (la parte dopo " || ", e le note del metodo), quelle del codice sono copiate dal sorgente con la riga. File letti: `docs/corpus/oroscopo_cinese.md`, `docs/corpus/oroscopo_vedico.md`, `docs/corpus/oroscopo_annuale.md`, `lib/core/horoscope/la_lettura_cinese.dart`, `lib/core/horoscope/oroscopo_cinese_data.dart`, `lib/core/horoscope/la_lettura_vedica.dart`, `lib/core/horoscope/oroscopo_vedico_data.dart`, `lib/core/horoscope/il_livello_del_cielo.dart`, `lib/core/horoscope/corrente_del_cielo.dart`, `lib/core/horoscope/il_numero_e_il_colore.dart`, `lib/core/horoscope/il_metodo_del_responso.dart`, `lib/core/horoscope/la_settimana_del_cielo.dart`, `lib/features/horoscope/il_periodo_view.dart`, `lib/core/horoscope/l_annuale.dart`, `lib/core/horoscope/l_anno_delle_tradizioni.dart`, `lib/core/horoscope/horoscope.dart` e `lib/features/horoscope/oroscopo_screen.dart` (per sapere che cosa va a video), nello stato del worktree del 1 ottobre 2026, con le modifiche della EU Aggiunta non ancora committate.

## Come si legge

- **Stato**: "fonte dichiarata" quando il corpus (nella frase, nella nota del suo caso, nella regola del suo gruppo o della sua sezione) o il codice (nella frase o nel commento accanto) nomina un'opera, un autore con la sua opera o una pagina di riferimento per ciò che la frase afferma. **SENZA FONTE** quando non ne nomina nessuna, oppure quando il repository stesso dichiara che ciò che la frase afferma è una scelta dell'app o una lettura moderna. Nessuna fonte è stata aggiunta da chi ha scritto questo file: dove il repository non la dà, la riga dice SENZA FONTE.
- **Livello**: "caso" se la fonte nomina proprio questo caso (la casa, la tara, il rapporto, il verso); "regola" se la fonte è quella della regola generale del gruppo e non del significato del singolo caso; "nessuna" se non c'è fonte.
- **Dove**: file e riga. Per i corpora la riga è quella della frase; la parte "TESTO" prima di " || " non è riportata, perché non va nella riga "Da dove viene". Le frasi dei corpora vanno nell'app attraverso i file generati `oroscopo_cinese_data.dart`, `oroscopo_vedico_data.dart` e `oroscopo_annuale_data.dart`.
- Le frasi fra parentesi graffe sono modelli: `{a | b}` elenca le varianti scritte nel codice. Le note del metodo sono divise frase per frase, perché ogni frase afferma una cosa diversa.
- "Fatto di calcolo" nella nota vuol dire che la frase dice una posizione, una data o un'ora calcolate dall'app e non un insegnamento della tradizione: resta SENZA FONTE perché il codice non nomina un'opera, ma all'Architetto basta guardare che il fatto sia detto bene.

## Occidentale

### Giorno

La riga "Da dove viene" della scheda del Giorno è `rigaDelLivello` di `IlLivelloDelCielo.per` (`lib/core/horoscope/horoscope.dart:282-283`, mostrata in `oroscopo_screen.dart:3017-3026`); la Fortuna aggiunge la riga del numero e del colore (`horoscope.dart:326-341`).

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-G-001 | Dal cielo di oggi: {pianeta} in {aspetto} {al punto natale}; {secondo passaggio}. | lib/core/horoscope/il_livello_del_cielo.dart:217-228 | Robert Hand, Planets in Transit (1976), introduzione, per i lenti che fanno il clima; William Lilly, Christian Astrology (1647), libro I, per l'orbe della Luna (lib/core/horoscope/il_livello_del_cielo.dart, commento righe 50-57) | regola | fonte dichiarata | la riga nomina i due passaggi che pesano di più; i pesi di benefici e malefici "della tradizione" (righe 17-19, 61-68) e l'orbita di due gradi (riga 59) non citano opere |
| O-G-002 | la Luna in {aspetto} {al tuo Sole \| alla tua Venere \| al tuo Marte \| al tuo Giove} di nascita (voce della riga qui sopra, la Luna del giorno) | lib/core/horoscope/il_livello_del_cielo.dart:103-127, 192-197 | William Lilly, Christian Astrology (1647), libro I: la metà dei dodici gradi della Luna (lib/core/horoscope/il_livello_del_cielo.dart, commento righe 83-86) | caso | fonte dichiarata | il corpo natale di ogni dominio (righe 89-97) non cita opere |
| O-G-003 | Oggi nessun passaggio stretto parla a questo campo. | lib/core/horoscope/il_livello_del_cielo.dart:226 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione; la soglia dei due gradi non ha fonte |
| O-G-004 | Dalla Luna di oggi in {segno}, nella tua {ordinale} casa solare{, aspetto}; {il Sole \| Venere \| Marte \| Giove} è in {segno}, nella tua {ordinale}. | lib/core/horoscope/il_livello_del_cielo.dart:247-253 | nessuna | nessuna | **SENZA FONTE** | le case solari, l'aspetto fra segni e i pesi senza carta (righe 23-35, 144-152) non citano opere |
| O-G-005 | {aspetto} della riga qui sopra: "nel tuo segno", "in sestile al tuo segno", "in trigono al tuo segno", "in quadratura al tuo segno", "in opposizione al tuo segno" | lib/core/horoscope/il_livello_del_cielo.dart:154-163 | nessuna | nessuna | **SENZA FONTE** | aspetto fra il segno della Luna e il segno solare |
| O-G-006 | Il numero è il tuo giorno personale, dalla tua data di nascita e da quella di oggi. | lib/core/horoscope/il_numero_e_il_colore.dart:123-130 | nessuna opera: il commento (righe 21-26) nomina l'autore, "come Hans Decoz", senza un titolo | nessuna | **SENZA FONTE** | riga della Fortuna |
| O-G-007 | Il numero è il giorno universale di oggi, dalla sola data. | lib/core/horoscope/il_numero_e_il_colore.dart:123-124, 130 | nessuna | nessuna | **SENZA FONTE** | riga della Fortuna, senza data di nascita |
| O-G-008 | Il colore è quello di {Il Sole \| La Luna \| Mercurio \| Venere \| Marte \| Giove \| Saturno}, il pianeta del passaggio più stretto di oggi. | lib/core/horoscope/il_numero_e_il_colore.dart:94-99, 130 | William Lilly, Christian Astrology (1647), libro I, capitoli VIII-XV, voce "Colours"; Agrippa, De occulta philosophia (1533), I.49 (lib/core/horoscope/il_numero_e_il_colore.dart, commento righe 13-20) | caso | fonte dichiarata | la scelta del pianeta del passaggio più stretto è una regola dell'app; i colori: oro, argento, grigio azzurro, verde, rosso, blu zaffiro, nero piombo (righe 49-57) |
| O-G-009 | Il colore è quello di {pianeta}, signore del segno in cui oggi sta la Luna ({segno}). | lib/core/horoscope/il_numero_e_il_colore.dart:102-108, 130 | William Lilly, Christian Astrology (1647), libro I, capitoli VIII-XV, voce "Colours"; Agrippa, De occulta philosophia (1533), I.49 (lib/core/horoscope/il_numero_e_il_colore.dart, commento righe 13-20); domicili: Tolomeo, Tetrabiblos I.17 (commento righe 18-19) | caso | fonte dichiarata |  |

### Settimana e Mese

In fondo a ogni dominio "Da dove viene: il momento chiave è ..."; nella Lunga i tre giorni migliori con la loro riga; sotto, il riquadro "Da dove viene: il cielo della settimana" o "del mese" coi fatti del periodo (`il_periodo_view.dart:181-226`).

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-S-001 | Da dove viene: il momento chiave è {momento chiave} | lib/features/horoscope/il_periodo_view.dart:188-189 | nessuna | nessuna | **SENZA FONTE** | la regola del momento chiave (lib/core/horoscope/la_settimana_del_cielo.dart:182-185) non cita opere |
| O-S-002 | {giorno} alle {ora}: la Luna forma {un trigono \| un sestile \| una congiunzione} {al tuo Sole \| alla tua Venere \| al tuo Marte \| al tuo Giove} di nascita. | lib/core/horoscope/la_settimana_del_cielo.dart:603-623, 249-254 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione; la scelta del primo aspetto favorevole e del corpo di ogni dominio non cita opere |
| O-S-003 | {giorno} alle {ora}: {Luna nuova \| Primo quarto \| Luna piena \| Ultimo quarto} in {segno}, nella tua {ordinale} casa[ solare], quella {materia della casa}. | lib/core/horoscope/la_settimana_del_cielo.dart:627-652 | nessuna | nessuna | **SENZA FONTE** | le dodici materie di lib/core/horoscope/corrente_del_cielo.dart:140-153: "di come ti presenti", "delle tue risorse", "degli scambi vicini", "delle radici e della casa", "di ciò che ti dà gioia", "del lavoro di ogni giorno", "dei legami che contano", "di ciò che si condivide nel profondo", "degli orizzonti larghi", "di ciò che costruisci in pubblico", "degli amici e dei desideri", "del ritiro e del silenzio"; il commento (lib/core/horoscope/corrente_del_cielo.dart:134-139) le dice "definizioni correnti della tradizione occidentale" senza opera; la casa del dominio (lib/core/horoscope/corrente_del_cielo.dart:97-115) "la tradizione" senza opera |
| O-S-004 | Da dove viene: nessuna fase della Luna e nessun passaggio esatto in questo periodo: il cielo scorre senza un momento solo. | lib/features/horoscope/il_periodo_view.dart:186-187; lib/core/horoscope/la_settimana_del_cielo.dart:639-640 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione |
| O-S-005 | Da dove viene: {pianeta} in {aspetto} {al punto natale}; {secondo passaggio}. (uno dei tre giorni migliori, nella Lunga) | lib/features/horoscope/il_periodo_view.dart:175, 237-242; lib/core/horoscope/il_livello_del_cielo.dart:228 | Robert Hand, Planets in Transit (1976), introduzione, per i lenti che fanno il clima; William Lilly, Christian Astrology (1647), libro I, per l'orbe della Luna (lib/core/horoscope/il_livello_del_cielo.dart, commento righe 50-57) | regola | fonte dichiarata | è la riga del Giorno, detta per un giorno che non è oggi |
| O-S-006 | Da dove viene: la Luna del giorno in {segno}, nella tua {ordinale} casa solare{, aspetto}; {corpo} è in {segno}, nella tua {ordinale}. (uno dei tre giorni migliori) | lib/features/horoscope/il_periodo_view.dart:243-245; lib/core/horoscope/il_livello_del_cielo.dart:247-253 | nessuna | nessuna | **SENZA FONTE** | come la riga senza carta del Giorno |
| O-S-007 | Da dove viene: quel giorno nessun passaggio stretto parla a questo campo. (uno dei tre giorni migliori) | lib/features/horoscope/il_periodo_view.dart:246; lib/core/horoscope/il_livello_del_cielo.dart:227 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione |
| O-S-008 | {giorno} alle {ora}: {Luna nuova \| Primo quarto \| Luna piena \| Ultimo quarto} in {segno}, nella tua {ordinale} casa[ solare]. (riquadro "Da dove viene: il cielo della settimana \| del mese") | lib/core/horoscope/la_settimana_del_cielo.dart:384-391; lib/features/horoscope/il_periodo_view.dart:202-213 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione; le fasi sono misurate contro il JPL (commit 7e1db15d), non una tradizione |
| O-S-009 | {giorno}: {il Sole \| Mercurio \| Venere \| Marte \| Giove \| Saturno} {entra \| torna} in {segno}[, retrogrado \| , retrograda]. (riquadro) | lib/core/horoscope/la_settimana_del_cielo.dart:397-403 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione |
| O-S-010 | {giorno} alle {ora}: {specie dell'eclissi} in {segno}, nella tua {ordinale} casa[ solare]. (riquadro) | lib/core/horoscope/la_settimana_del_cielo.dart:405-425 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione; il commento dice il motore "verificato col canone" senza nominarlo |
| O-S-011 | Nessun ingresso e nessuna fase della Luna in {la settimana \| il mese}. (riquadro) | lib/features/horoscope/il_periodo_view.dart:206-208 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione |
| O-S-012 | Senza ora e luogo di nascita {la settimana \| il mese} si legge sul tuo segno e sulle case solari. (riquadro) | lib/features/horoscope/il_periodo_view.dart:214-218 | nessuna | nessuna | **SENZA FONTE** | avvertenza di metodo |
| O-S-013 | Senza l'ora di nascita {la settimana \| il mese} si legge sui tuoi pianeti, con le case solari al posto di quelle della carta. (riquadro) | lib/features/horoscope/il_periodo_view.dart:219-221 | nessuna | nessuna | **SENZA FONTE** | avvertenza di metodo |

### Anno

La riga "Da dove viene" dell'Anno è la parte dopo " || " delle frasi di `docs/corpus/oroscopo_annuale.md` (`l_annuale.dart:138-145`), più le righe del livello e, nella Lunga, `doveSta` (`l_annuale.dart:164-165`). Prima le righe scritte nel codice, poi il corpus, sezione per sezione.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-001 | Il livello viene dal Sole della tua Rivoluzione Solare in casa {n}, {angolare \| succedente \| cadente}. | lib/core/horoscope/l_annuale.dart:177-178, 64-74 | Volguine, regola dell'angolarità (lib/core/horoscope/l_annuale.dart, commento righe 40-44); l'opera è "The Technique of Solar Returns" (corpus annuale, riga 527, capitoli e pagine non verificati) | regola | fonte dichiarata | Generale |
| O-A-002 | Il livello viene da Venere nella casa {n}, {angolare \| succedente \| cadente}. | lib/core/horoscope/l_annuale.dart:188-189 | Volguine, regola dell'angolarità (lib/core/horoscope/l_annuale.dart, commento righe 40-44); l'opera è "The Technique of Solar Returns" (corpus annuale, riga 527, capitoli e pagine non verificati) | regola | fonte dichiarata | Amore |
| O-A-003 | Il livello viene da Saturno nella casa {n}, {angolare \| succedente \| cadente}: più è in vista, più il lavoro chiede. | lib/core/horoscope/l_annuale.dart:198-201 | nessuna per "più è in vista, più il lavoro chiede": il commento (righe 43-44 e 200) lo dice senza opera | nessuna | **SENZA FONTE** | Lavoro; l'angolarità da sola ha la fonte di Volguine, l'inversione per Saturno no |
| O-A-004 | Il livello viene da Giove nella casa {n}, {angolare \| succedente \| cadente}. | lib/core/horoscope/l_annuale.dart:210-211 | Volguine, regola dell'angolarità (lib/core/horoscope/l_annuale.dart, commento righe 40-44); l'opera è "The Technique of Solar Returns" (corpus annuale, riga 527, capitoli e pagine non verificati) | regola | fonte dichiarata | Fortuna |
| O-A-005 | Al tuo compleanno {Venere \| Giove} era in {segno}, nella casa {n} del tuo anno: una casa angolare, dove per la tradizione il pianeta è fra i protagonisti dell'anno. | lib/core/horoscope/l_annuale.dart:80-93 | Volguine, regola dell'angolarità (lib/core/horoscope/l_annuale.dart, commento righe 40-44); l'opera è "The Technique of Solar Returns" (corpus annuale, riga 527, capitoli e pagine non verificati) | caso | fonte dichiarata | Lunga di Amore e Fortuna (doveSta) |
| O-A-006 | Al tuo compleanno {Venere \| Giove} era in {segno}, nella casa {n} del tuo anno: una casa succedente, dove per la tradizione il pianeta lavora in secondo piano. | lib/core/horoscope/l_annuale.dart:80-93 | Volguine, regola dell'angolarità (lib/core/horoscope/l_annuale.dart, commento righe 40-44); l'opera è "The Technique of Solar Returns" (corpus annuale, riga 527, capitoli e pagine non verificati) | caso | fonte dichiarata | doveSta |
| O-A-007 | Al tuo compleanno {Venere \| Giove} era in {segno}, nella casa {n} del tuo anno: una casa cadente, dove per la tradizione il pianeta resta sullo sfondo. | lib/core/horoscope/l_annuale.dart:80-93 | Volguine, regola dell'angolarità (lib/core/horoscope/l_annuale.dart, commento righe 40-44); l'opera è "The Technique of Solar Returns" (corpus annuale, riga 527, capitoli e pagine non verificati) | caso | fonte dichiarata | doveSta |
| O-A-008 | L'Ascendente del tuo anno è in {segno}. | lib/core/horoscope/l_annuale.dart:173-175 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione; ripiego che vale solo se la frase del corpus non ha la parte dopo " \|\| ", cioè mai col corpus di oggi |
| O-A-009 | Venere nella tua Rivoluzione Solare cade nella casa {n}. | lib/core/horoscope/l_annuale.dart:183-186 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione; ripiego, come sopra |
| O-A-010 | Il Medio Cielo del tuo anno è in {segno}. | lib/core/horoscope/l_annuale.dart:194-196 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione; ripiego, come sopra |
| O-A-011 | Giove nella tua Rivoluzione Solare cade nella casa {n}. | lib/core/horoscope/l_annuale.dart:205-208 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione; ripiego, come sopra |

**Corpus annuale, 1. Ascendente in Ariete**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-012 | L'Ascendente del tuo anno è in Ariete: dà ai dodici mesi un tono diretto, impaziente, voglioso di cominciare. | docs/corpus/oroscopo_annuale.md:73 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-013 | L'Ascendente della tua Rivoluzione Solare cade in Ariete: la tradizione lo legge come un anno di iniziativa, con la fretta come unico pericolo. | docs/corpus/oroscopo_annuale.md:74 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-014 | Il segno che sorge al tuo compleanno è l'Ariete: per la tradizione è energia che vuole un bersaglio, senza il quale si fa irritazione. | docs/corpus/oroscopo_annuale.md:75 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Toro**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-015 | L'Ascendente del tuo anno è in Toro: dà ai dodici mesi un passo lento e concreto, legato al corpo, alla casa, alle entrate. | docs/corpus/oroscopo_annuale.md:78 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-016 | L'Ascendente della tua Rivoluzione Solare è in Toro: la tradizione lo lega al piacere dei sensi e alla cura delle risorse. | docs/corpus/oroscopo_annuale.md:79 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-017 | Al tuo compleanno sorge il Toro: per la tradizione è il segno che premia la costanza e custodisce ciò che vale. | docs/corpus/oroscopo_annuale.md:80 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Gemelli**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-018 | L'Ascendente del tuo anno è in Gemelli: dà ai dodici mesi un clima rapido, fatto di incontri, messaggi e brevi spostamenti. | docs/corpus/oroscopo_annuale.md:83 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-019 | L'Ascendente della tua Rivoluzione Solare è in Gemelli: la tradizione ne fa un anno di studio e di parola, con il rischio della dispersione. | docs/corpus/oroscopo_annuale.md:84 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-020 | Al tuo compleanno sorgono i Gemelli: il segno dà all'anno un tono curioso e mobile, che passa dai contatti vicini. | docs/corpus/oroscopo_annuale.md:85 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Cancro**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-021 | L'Ascendente del tuo anno è in Cancro: porta i dodici mesi verso la casa e verso le persone di cui ti prendi cura. | docs/corpus/oroscopo_annuale.md:88 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-022 | L'Ascendente della tua Rivoluzione Solare è in Cancro: la tradizione lo lega alla famiglia, alla casa, alle radici. | docs/corpus/oroscopo_annuale.md:89 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-023 | Al tuo compleanno sorge il Cancro: per la tradizione è un segno protettivo, che dà molto quando si sente al sicuro. | docs/corpus/oroscopo_annuale.md:90 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Leone**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-024 | L'Ascendente del tuo anno è in Leone: dà ai dodici mesi il bisogno di mostrarsi e di mettere in luce un talento. | docs/corpus/oroscopo_annuale.md:93 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-025 | L'Ascendente della tua Rivoluzione Solare è in Leone: la tradizione lo lega a creatività, gioco e figli, con l'avvertenza dell'orgoglio ferito. | docs/corpus/oroscopo_annuale.md:94 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-026 | Al tuo compleanno sorge il Leone: per la tradizione è il segno che chiede cuore più che prudenza. | docs/corpus/oroscopo_annuale.md:95 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Vergine**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-027 | L'Ascendente del tuo anno è in Vergine: dà ai dodici mesi un tono pratico, rivolto alle abitudini, al lavoro quotidiano, alla salute. | docs/corpus/oroscopo_annuale.md:98 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-028 | L'Ascendente della tua Rivoluzione Solare è in Vergine: la tradizione lo lega al servizio e al perfezionamento. | docs/corpus/oroscopo_annuale.md:99 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-029 | Al tuo compleanno sorge la Vergine: per la tradizione è un segno attento ai dettagli, che rende quando è gentile con sé. | docs/corpus/oroscopo_annuale.md:100 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Bilancia**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-030 | L'Ascendente del tuo anno è in Bilancia: porta i dodici mesi verso accordi, alleanze e collaborazioni. | docs/corpus/oroscopo_annuale.md:103 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-031 | L'Ascendente della tua Rivoluzione Solare è in Bilancia: la tradizione lo lega alle relazioni e alla bellezza, con il rischio dell'indecisione. | docs/corpus/oroscopo_annuale.md:104 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-032 | Al tuo compleanno sorge la Bilancia: per la tradizione l'equilibrio ha due piatti, il tuo e quello degli altri. | docs/corpus/oroscopo_annuale.md:105 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Scorpione**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-033 | L'Ascendente del tuo anno è in Scorpione: dà ai dodici mesi profondità e intensità. | docs/corpus/oroscopo_annuale.md:108 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-034 | L'Ascendente della tua Rivoluzione Solare è in Scorpione: la tradizione lo lega alle risorse condivise e a ciò che finisce per fare posto al nuovo. | docs/corpus/oroscopo_annuale.md:109 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-035 | Al tuo compleanno sorge lo Scorpione: per la tradizione è un segno riservato e tenace, che porta le cose fino in fondo. | docs/corpus/oroscopo_annuale.md:110 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Sagittario**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-036 | L'Ascendente del tuo anno è in Sagittario: apre i dodici mesi a viaggi, studi e orizzonti nuovi. | docs/corpus/oroscopo_annuale.md:113 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-037 | L'Ascendente della tua Rivoluzione Solare è in Sagittario: la tradizione ne fa un anno di studio e di partenze, con il rischio delle promesse fatte in fretta. | docs/corpus/oroscopo_annuale.md:114 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-038 | Al tuo compleanno sorge il Sagittario: per la tradizione è il segno della fiducia e della ricerca di senso. | docs/corpus/oroscopo_annuale.md:115 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Capricorno**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-039 | L'Ascendente del tuo anno è in Capricorno: dà ai dodici mesi un tono serio e costruttivo, fatto di obiettivi lontani. | docs/corpus/oroscopo_annuale.md:118 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-040 | L'Ascendente della tua Rivoluzione Solare è in Capricorno: la tradizione lo lega alla carriera e alla maturità. | docs/corpus/oroscopo_annuale.md:119 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-041 | Al tuo compleanno sorge il Capricorno: per la tradizione è un segno sobrio, che rende quando sa anche fermarsi. | docs/corpus/oroscopo_annuale.md:120 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Acquario**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-042 | L'Ascendente del tuo anno è in Acquario: dà ai dodici mesi bisogno di libertà e di idee nuove. | docs/corpus/oroscopo_annuale.md:123 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-043 | L'Ascendente della tua Rivoluzione Solare è in Acquario: la tradizione lo lega agli amici, ai gruppi, al futuro. | docs/corpus/oroscopo_annuale.md:124 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-044 | Al tuo compleanno sorge l'Acquario: per la tradizione dà il meglio quando l'originalità ha uno scopo. | docs/corpus/oroscopo_annuale.md:125 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 1. Ascendente in Pesci**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-045 | L'Ascendente del tuo anno è in Pesci: dà ai dodici mesi un tono sensibile e intuitivo, attento ai sogni e alle coincidenze. | docs/corpus/oroscopo_annuale.md:128 (frase 1) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-046 | L'Ascendente della tua Rivoluzione Solare è in Pesci: la tradizione lo lega alla compassione e alla vita interiore. | docs/corpus/oroscopo_annuale.md:129 (frase 2) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-047 | Al tuo compleanno sorgono i Pesci: per la tradizione è un segno che assorbe molto, anche ciò che non è suo. | docs/corpus/oroscopo_annuale.md:130 (frase 3) | Marion March e Joan McEvers, "The Only Way to Learn About Tomorrow" (ACS), citati da Georgia Stathis, "Solar Returns, Part I" (Kepler College); Cafe Astrology, "Solar Returns: Ascendant" (corpus, riga 21) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 1**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-048 | Il Sole della tua Rivoluzione Solare cade nella casa 1, quella della persona e del corpo: l'anno è centrato su di te. | docs/corpus/oroscopo_annuale.md:135 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-049 | Il Sole dell'anno è in casa 1: la tradizione legge questa posizione come un anno di rinascita personale. | docs/corpus/oroscopo_annuale.md:136 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-050 | Il Sole della tua Rivoluzione Solare è nella casa 1, la casa dell'io: lì, per gli autori, si concentra l'attività dell'anno. | docs/corpus/oroscopo_annuale.md:137 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 2**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-051 | Il Sole della tua Rivoluzione Solare cade nella casa 2, quella del denaro, dei beni e dei talenti concreti. | docs/corpus/oroscopo_annuale.md:140 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-052 | Il Sole dell'anno è in casa 2: la tradizione lega questa casa alle risorse e anche a ciò che stimi. | docs/corpus/oroscopo_annuale.md:141 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-053 | Il Sole della tua Rivoluzione Solare è nella casa 2, la casa delle risorse: lì si concentra l'attività dell'anno. | docs/corpus/oroscopo_annuale.md:142 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 3**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-054 | Il Sole della tua Rivoluzione Solare cade nella casa 3, quella della parola, dello studio e degli scambi. | docs/corpus/oroscopo_annuale.md:145 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-055 | Il Sole dell'anno è in casa 3: la tradizione lega questa casa ai fratelli, ai vicini e ai brevi viaggi. | docs/corpus/oroscopo_annuale.md:146 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-056 | Il Sole della tua Rivoluzione Solare è nella casa 3, la casa della mente e delle comunicazioni. | docs/corpus/oroscopo_annuale.md:147 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 4**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-057 | Il Sole della tua Rivoluzione Solare cade nella casa 4, quella della casa, della famiglia e delle radici. | docs/corpus/oroscopo_annuale.md:150 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-058 | Il Sole dell'anno è in casa 4: la tradizione lega questa casa all'abitazione, alle origini e alla fine dei cicli. | docs/corpus/oroscopo_annuale.md:151 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-059 | Il Sole della tua Rivoluzione Solare è nella casa 4, la casa delle fondamenta e della vita privata. | docs/corpus/oroscopo_annuale.md:152 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 5**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-060 | Il Sole della tua Rivoluzione Solare cade nella casa 5, quella dell'amore, del gioco e della creatività. | docs/corpus/oroscopo_annuale.md:155 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-061 | Il Sole dell'anno è in casa 5: la tradizione lega questa casa alle opere proprie e anche ai figli. | docs/corpus/oroscopo_annuale.md:156 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-062 | Il Sole della tua Rivoluzione Solare è nella casa 5, la casa del piacere e di ciò che accende: lì si concentra l'attività dell'anno. | docs/corpus/oroscopo_annuale.md:157 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 6**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-063 | Il Sole della tua Rivoluzione Solare cade nella casa 6, quella del lavoro quotidiano e della salute. | docs/corpus/oroscopo_annuale.md:160 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-064 | Il Sole dell'anno è in casa 6: la tradizione lega questa casa al servizio e ai collaboratori. | docs/corpus/oroscopo_annuale.md:161 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-065 | Il Sole della tua Rivoluzione Solare è nella casa 6: per la tradizione chiede metodo, non sacrificio. | docs/corpus/oroscopo_annuale.md:162 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 7**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-066 | Il Sole della tua Rivoluzione Solare cade nella casa 7, quella del partner, dei soci e degli accordi. | docs/corpus/oroscopo_annuale.md:165 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-067 | Il Sole dell'anno è in casa 7: la tradizione lega questa casa agli impegni, ai contratti e anche ai rivali dichiarati. | docs/corpus/oroscopo_annuale.md:166 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-068 | Il Sole della tua Rivoluzione Solare è nella casa 7, la casa dell'altro: lì si concentra l'attività dell'anno. | docs/corpus/oroscopo_annuale.md:167 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 8**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-069 | Il Sole della tua Rivoluzione Solare cade nella casa 8, quella di ciò che finisce e di ciò che si rinnova. | docs/corpus/oroscopo_annuale.md:170 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-070 | Il Sole dell'anno è in casa 8: la tradizione lega questa casa alle risorse condivise, alle eredità e alle trasformazioni interiori. | docs/corpus/oroscopo_annuale.md:171 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-071 | Il Sole della tua Rivoluzione Solare è nella casa 8: per la tradizione rinnova ciò che accetta di cambiare. | docs/corpus/oroscopo_annuale.md:172 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 9**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-072 | Il Sole della tua Rivoluzione Solare cade nella casa 9, quella dei viaggi lontani, degli studi e delle grandi domande. | docs/corpus/oroscopo_annuale.md:175 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-073 | Il Sole dell'anno è in casa 9: la tradizione lega questa casa agli studi superiori, all'estero e alla legge. | docs/corpus/oroscopo_annuale.md:176 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-074 | Il Sole della tua Rivoluzione Solare è nella casa 9, la casa degli orizzonti lontani e della ricerca di senso. | docs/corpus/oroscopo_annuale.md:177 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 10**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-075 | Il Sole della tua Rivoluzione Solare cade nella casa 10, quella della carriera e della vita pubblica. | docs/corpus/oroscopo_annuale.md:180 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-076 | Il Sole dell'anno è in casa 10: la tradizione legge il Sole vicino al Medio Cielo come uno dei segnali più forti di esposizione. | docs/corpus/oroscopo_annuale.md:181 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-077 | Il Sole della tua Rivoluzione Solare è nella casa 10, la casa della reputazione: lì si concentra l'attività dell'anno. | docs/corpus/oroscopo_annuale.md:182 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 11**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-078 | Il Sole della tua Rivoluzione Solare cade nella casa 11, quella degli amici, dei gruppi e dei progetti comuni. | docs/corpus/oroscopo_annuale.md:185 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-079 | Il Sole dell'anno è in casa 11: la tradizione lega questa casa alle speranze e ai protettori. | docs/corpus/oroscopo_annuale.md:186 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-080 | Il Sole della tua Rivoluzione Solare è nella casa 11, la casa delle amicizie e dei gruppi: lì si concentra l'attività dell'anno. | docs/corpus/oroscopo_annuale.md:187 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 2. Sole in casa 12**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-081 | Il Sole della tua Rivoluzione Solare cade nella casa 12, quella del riposo, della riflessione e del lavoro silenzioso. | docs/corpus/oroscopo_annuale.md:190 (frase 1) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-082 | Il Sole dell'anno è in casa 12: la tradizione legge questa casa come ritiro, il tempo che prepara un ciclo nuovo. | docs/corpus/oroscopo_annuale.md:191 (frase 2) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-083 | Il Sole della tua Rivoluzione Solare è nella casa 12, la casa nascosta: l'attività dell'anno si concentra nella vita interiore. | docs/corpus/oroscopo_annuale.md:192 (frase 3) | March e McEvers, citati da Stathis, "Solar Returns, Part I"; Cafe Astrology, "Interpreting Solar Returns" (corpus, riga 27) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 1**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-084 | Venere nella tua Rivoluzione Solare cade nella casa 1, quella della persona e di come ci si mostra agli altri. | docs/corpus/oroscopo_annuale.md:197 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-085 | Venere è nella casa 1 della tua Rivoluzione Solare, vicino all'Ascendente: la tradizione la legge come un segnale favorevole per il fascino. | docs/corpus/oroscopo_annuale.md:198 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-086 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 1, che parla di te prima che degli altri: il piacere e l'armonia partono da lì. | docs/corpus/oroscopo_annuale.md:199 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 2**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-087 | Venere nella tua Rivoluzione Solare cade nella casa 2, quella delle risorse e di ciò che dà sicurezza. | docs/corpus/oroscopo_annuale.md:202 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-088 | Venere è nella casa 2 della tua Rivoluzione Solare: la tradizione la lega al piacere unito alla stabilità e a guadagni che vengono dalla bellezza o dall'arte. | docs/corpus/oroscopo_annuale.md:203 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-089 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 2, che riguarda ciò che possiedi e ciò che stimi: l'amore passa da lì. | docs/corpus/oroscopo_annuale.md:204 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 3**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-090 | Venere nella tua Rivoluzione Solare cade nella casa 3, quella delle parole, dei messaggi e degli incontri vicini. | docs/corpus/oroscopo_annuale.md:207 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-091 | Venere è nella casa 3 della tua Rivoluzione Solare: la tradizione la lega al corteggiamento leggero e a rapporti più dolci con fratelli e vicini. | docs/corpus/oroscopo_annuale.md:208 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-092 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 3, che riguarda il modo di comunicare: per questo il garbo conta. | docs/corpus/oroscopo_annuale.md:209 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 4**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-093 | Venere nella tua Rivoluzione Solare cade nella casa 4, quella della casa in cui vivi, della famiglia e delle radici. | docs/corpus/oroscopo_annuale.md:212 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-094 | Venere è nella casa 4 della tua Rivoluzione Solare: la tradizione la lega all'armonia domestica, all'intimità e alla vita in famiglia. | docs/corpus/oroscopo_annuale.md:213 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-095 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 4, il punto delle origini: gli affetti più vecchi tornano in primo piano. | docs/corpus/oroscopo_annuale.md:214 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 5**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-096 | Venere nella tua Rivoluzione Solare cade nella casa 5, quella del gioco, del piacere e del corteggiamento. | docs/corpus/oroscopo_annuale.md:217 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-097 | Venere è nella casa 5 della tua Rivoluzione Solare, che la tradizione chiama la sua gioia: è una delle posizioni più favorevoli. | docs/corpus/oroscopo_annuale.md:218 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-098 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 5, legata anche alla creatività: l'affetto passa da ciò che si fa insieme per piacere. | docs/corpus/oroscopo_annuale.md:219 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 3. Venere in casa 6**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-099 | Venere nella tua Rivoluzione Solare cade nella casa 6, quella delle abitudini e della vita di tutti i giorni. | docs/corpus/oroscopo_annuale.md:222 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-100 | Venere è nella casa 6 della tua Rivoluzione Solare: la tradizione la lega a un lavoro più gradevole e agli incontri che nascono lì. | docs/corpus/oroscopo_annuale.md:223 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-101 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 6, che è anche la casa del servizio: per questo serve distinguere la cura dal sacrificio. | docs/corpus/oroscopo_annuale.md:224 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 7**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-102 | Venere nella tua Rivoluzione Solare cade nella casa 7, quella della coppia e dei legami a due. | docs/corpus/oroscopo_annuale.md:227 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-103 | Venere è nella casa 7 della tua Rivoluzione Solare: la tradizione la considera un segnale favorevole per unioni e accordi. | docs/corpus/oroscopo_annuale.md:228 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-104 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 7, che è la casa dell'altro: l'affetto passa da chi hai di fronte. | docs/corpus/oroscopo_annuale.md:229 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 8**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-105 | Venere nella tua Rivoluzione Solare cade nella casa 8, quella dell'intimità e di ciò che si mette in comune. | docs/corpus/oroscopo_annuale.md:232 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-106 | Venere è nella casa 8 della tua Rivoluzione Solare: la tradizione la lega ai legami che si trasformano e a vantaggi economici che passano dal partner. | docs/corpus/oroscopo_annuale.md:233 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-107 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 8, che riguarda le risorse e le emozioni condivise: qui l'affetto chiede fiducia. | docs/corpus/oroscopo_annuale.md:234 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 9**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-108 | Venere nella tua Rivoluzione Solare cade nella casa 9, quella dei viaggi, dei luoghi lontani e degli orizzonti larghi. | docs/corpus/oroscopo_annuale.md:237 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-109 | Venere è nella casa 9 della tua Rivoluzione Solare: la tradizione la lega a un amore che fa crescere, allo studio, alla fede e agli incontri all'estero. | docs/corpus/oroscopo_annuale.md:238 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-110 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 9, che parla di mete e di senso: l'affetto cerca una direzione condivisa. | docs/corpus/oroscopo_annuale.md:239 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 10**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-111 | Venere nella tua Rivoluzione Solare cade nella casa 10, quella della vita pubblica e di ciò che tutti vedono. | docs/corpus/oroscopo_annuale.md:242 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-112 | Venere è nella casa 10 della tua Rivoluzione Solare: la tradizione la lega ai legami che diventano ufficiali e ai favori nel lavoro. | docs/corpus/oroscopo_annuale.md:243 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-113 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 10, che è anche la casa della carriera: per questo affetti e lavoro si sfiorano. | docs/corpus/oroscopo_annuale.md:244 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 11**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-114 | Venere nella tua Rivoluzione Solare cade nella casa 11, quella degli amici, dei gruppi e dei progetti comuni. | docs/corpus/oroscopo_annuale.md:247 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-115 | Venere è nella casa 11 della tua Rivoluzione Solare: la tradizione la lega alle amicizie affettuose e ai desideri che trovano appoggio. | docs/corpus/oroscopo_annuale.md:248 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-116 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 11, che è la casa delle amicizie: l'affetto prende il tono di un'intesa fra pari. | docs/corpus/oroscopo_annuale.md:249 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 3. Venere in casa 12**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-117 | Venere nella tua Rivoluzione Solare cade nella casa 12, quella del ritiro e di ciò che resta nascosto. | docs/corpus/oroscopo_annuale.md:252 (frase 1) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-118 | Venere è nella casa 12 della tua Rivoluzione Solare: la tradizione la lega alle vecchie ferite da chiudere e ai legami segreti, che chiedono chiarezza. | docs/corpus/oroscopo_annuale.md:253 (frase 2) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-119 | Nella Rivoluzione Solare di quest'anno Venere sta nella casa 12, il luogo della vita interiore: l'affetto lavora dietro le quinte. | docs/corpus/oroscopo_annuale.md:254 (frase 3) | Cafe Astrology, "Interpreting Solar Returns"; Chris Brennan, "Hellenistic Astrology" (2017), capitolo sui dodici luoghi, per la gioia di Venere nella casa 5 (corpus, riga 33) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 4. Giove in casa 1**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-120 | Giove nella tua Rivoluzione Solare cade nella casa 1, quella della persona e dell'iniziativa. | docs/corpus/oroscopo_annuale.md:259 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-121 | Giove è nella casa 1 della tua Rivoluzione Solare: la tradizione avverte che qui allarga ogni cosa, anche il corpo. | docs/corpus/oroscopo_annuale.md:260 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-122 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 1, vicino all'Ascendente: la tradizione lo legge come una protezione. | docs/corpus/oroscopo_annuale.md:261 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 4. Giove in casa 2**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-123 | Giove nella tua Rivoluzione Solare cade nella casa 2, quella del denaro, dei beni e dei talenti concreti. | docs/corpus/oroscopo_annuale.md:264 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-124 | Giove è nella casa 2 della tua Rivoluzione Solare: la tradizione avverte che qui allarga le possibilità e insieme le spese. | docs/corpus/oroscopo_annuale.md:265 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-125 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 2, che riguarda ciò che possiedi: le occasioni hanno una forma materiale. | docs/corpus/oroscopo_annuale.md:266 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 4. Giove in casa 3**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-126 | Giove nella tua Rivoluzione Solare cade nella casa 3, quella delle parole, dello studio e dei contatti vicini. | docs/corpus/oroscopo_annuale.md:269 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-127 | Giove è nella casa 3 della tua Rivoluzione Solare: la tradizione lo lega agli studi, ai brevi spostamenti e ai buoni rapporti con fratelli e vicini. | docs/corpus/oroscopo_annuale.md:270 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-128 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 3, che è la casa degli scambi: le opportunità passano da ciò che si dice e si scrive. | docs/corpus/oroscopo_annuale.md:271 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 4. Giove in casa 4**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-129 | Giove nella tua Rivoluzione Solare cade nella casa 4, quella della casa in cui vivi e della famiglia. | docs/corpus/oroscopo_annuale.md:274 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-130 | Giove è nella casa 4 della tua Rivoluzione Solare: la tradizione lo lega alla protezione domestica e ai benefici che vengono dalle radici. | docs/corpus/oroscopo_annuale.md:275 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-131 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 4, che riguarda le fondamenta della vita privata: le opportunità crescono dalle basi. | docs/corpus/oroscopo_annuale.md:276 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 4. Giove in casa 5**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-132 | Giove nella tua Rivoluzione Solare cade nella casa 5, quella del piacere, del gioco e della creatività. | docs/corpus/oroscopo_annuale.md:279 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-133 | Giove è nella casa 5 della tua Rivoluzione Solare: la tradizione lo lega all'amore, ai figli e alla creatività, con l'avvertenza di non eccedere nel rischio. | docs/corpus/oroscopo_annuale.md:280 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-134 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 5, che è anche la casa del gioco e delle scommesse: per questo l'entusiasmo va tenuto a misura. | docs/corpus/oroscopo_annuale.md:281 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 4. Giove in casa 6**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-135 | Giove nella tua Rivoluzione Solare cade nella casa 6, quella del lavoro quotidiano e dei collaboratori. | docs/corpus/oroscopo_annuale.md:284 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-136 | Giove è nella casa 6 della tua Rivoluzione Solare: la tradizione lo lega alle abitudini e alla salute, con l'avvertenza che qui chiede misura. | docs/corpus/oroscopo_annuale.md:285 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-137 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 6, che è la casa del lavoro e del servizio: le opportunità prendono la forma di incarichi. | docs/corpus/oroscopo_annuale.md:286 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 4. Giove in casa 7**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-138 | Giove nella tua Rivoluzione Solare cade nella casa 7, quella dei soci, dei partner e delle alleanze. | docs/corpus/oroscopo_annuale.md:289 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-139 | Giove è nella casa 7 della tua Rivoluzione Solare: la tradizione lo considera favorevole alle unioni, ai contratti e alle cause. | docs/corpus/oroscopo_annuale.md:290 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-140 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 7, che è la casa dell'altro: le opportunità passano dalle persone con cui ti leghi. | docs/corpus/oroscopo_annuale.md:291 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 4. Giove in casa 8**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-141 | Giove nella tua Rivoluzione Solare cade nella casa 8, quella delle risorse condivise: prestiti, mutui ed eredità. | docs/corpus/oroscopo_annuale.md:294 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-142 | Giove è nella casa 8 della tua Rivoluzione Solare: la tradizione lo lega alle trasformazioni e ai benefici che vengono da altri, per esempio dal partner. | docs/corpus/oroscopo_annuale.md:295 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-143 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 8, che riguarda ciò che finisce e si rinnova: qui le opportunità restano nascoste finché non si fa spazio. | docs/corpus/oroscopo_annuale.md:296 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 4. Giove in casa 9**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-144 | Giove nella tua Rivoluzione Solare cade nella casa 9, quella dei viaggi, degli studi e dei paesi stranieri. | docs/corpus/oroscopo_annuale.md:299 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-145 | Giove è nella casa 9 della tua Rivoluzione Solare, per la tradizione una delle più congeniali a lui: formazione, pubblicazioni, questioni di legge. | docs/corpus/oroscopo_annuale.md:300 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-146 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 9, che è la casa dell'insegnamento: le opportunità passano da chi insegna e da chi impara. | docs/corpus/oroscopo_annuale.md:301 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 4. Giove in casa 10**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-147 | Giove nella tua Rivoluzione Solare cade nella casa 10, quella della carriera e della vita pubblica. | docs/corpus/oroscopo_annuale.md:304 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-148 | Giove è nella casa 10 della tua Rivoluzione Solare, vicino al Medio Cielo: la tradizione lo legge come uno dei segnali migliori per la reputazione. | docs/corpus/oroscopo_annuale.md:305 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-149 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 10, quella che mette in vista: ciò che fai si vede più del solito. | docs/corpus/oroscopo_annuale.md:306 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 4. Giove in casa 11**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-150 | Giove nella tua Rivoluzione Solare cade nella casa 11, quella degli amici, dei gruppi e dei protettori. | docs/corpus/oroscopo_annuale.md:309 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-151 | Giove è nella casa 11 della tua Rivoluzione Solare, che la tradizione chiama il Buon Demone: è la sua gioia. | docs/corpus/oroscopo_annuale.md:310 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-152 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 11, che è la casa delle speranze e degli appoggi: le opportunità hanno molti volti. | docs/corpus/oroscopo_annuale.md:311 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 4. Giove in casa 12**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-153 | Giove nella tua Rivoluzione Solare cade nella casa 12, quella del ritiro, del riposo e della vita interiore. | docs/corpus/oroscopo_annuale.md:314 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-154 | Giove è nella casa 12 della tua Rivoluzione Solare: la tradizione lo lega all'aiuto discreto e a una protezione nascosta. | docs/corpus/oroscopo_annuale.md:315 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-155 | Nella Rivoluzione Solare di quest'anno Giove sta nella casa 12, che agisce dietro le quinte: le opportunità maturano lontano dagli sguardi. | docs/corpus/oroscopo_annuale.md:316 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Cafe Astrology, "Interpreting Solar Returns"; Brennan, capitolo citato, per la gioia di Giove nella casa 11; Stathis e Cafe Astrology per i pianeti sugli angoli (corpus, riga 39) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 1**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-156 | Saturno nella tua Rivoluzione Solare cade nella casa 1, quella della persona: lì chiede maturità e responsabilità verso di te, corpo compreso. | docs/corpus/oroscopo_annuale.md:321 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-157 | La tradizione legge Saturno nella casa 1 della Rivoluzione Solare, vicino all'Ascendente, come un peso: ne fa un anno di impegno personale. | docs/corpus/oroscopo_annuale.md:322 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-158 | Saturno nella tua Rivoluzione Solare è nella casa 1, la casa di chi sei: il pianeta della disciplina porta lì il lavoro dell'anno. | docs/corpus/oroscopo_annuale.md:323 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 2**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-159 | Saturno nella tua Rivoluzione Solare cade nella casa 2, quella del denaro e dei beni, dove chiede disciplina con le risorse. | docs/corpus/oroscopo_annuale.md:326 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-160 | Con Saturno nella casa 2 della Rivoluzione Solare i risparmi si costruiscono con pazienza: la tradizione avverte contro le spese d'impulso. | docs/corpus/oroscopo_annuale.md:327 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-161 | Saturno nella tua Rivoluzione Solare è nella casa 2, la casa delle risorse: qui il lavoro rende piano e guarda lontano. | docs/corpus/oroscopo_annuale.md:328 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 5. Saturno in casa 3**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-162 | Saturno nella tua Rivoluzione Solare cade nella casa 3, quella dello studio, delle parole e dei documenti, dove chiede disciplina. | docs/corpus/oroscopo_annuale.md:331 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-163 | Con Saturno nella casa 3 della Rivoluzione Solare la tradizione vede un apprendimento impegnativo e responsabilità verso fratelli o vicini. | docs/corpus/oroscopo_annuale.md:332 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-164 | Saturno nella tua Rivoluzione Solare è nella casa 3, la casa della parola: lì il pianeta della misura fa pesare ciò che si dice. | docs/corpus/oroscopo_annuale.md:333 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 4**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-165 | Saturno nella tua Rivoluzione Solare cade nella casa 4, quella della famiglia e dell'abitazione, dove porta le responsabilità dell'anno. | docs/corpus/oroscopo_annuale.md:336 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-166 | Con Saturno nella casa 4 della Rivoluzione Solare si rinforzano le fondamenta, anche materiali: la tradizione lega questa posizione a doveri verso i genitori. | docs/corpus/oroscopo_annuale.md:337 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-167 | Saturno nella tua Rivoluzione Solare è nella casa 4, la casa delle radici: il lavoro dell'anno sta dietro la porta di casa. | docs/corpus/oroscopo_annuale.md:338 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 5**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-168 | Saturno nella tua Rivoluzione Solare cade nella casa 5, quella del piacere e della creatività, dove chiede struttura. | docs/corpus/oroscopo_annuale.md:341 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-169 | Con Saturno nella casa 5 della Rivoluzione Solare amore e figli portano responsabilità: la tradizione suggerisce serietà, non rinuncia. | docs/corpus/oroscopo_annuale.md:342 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-170 | Saturno nella tua Rivoluzione Solare è nella casa 5, la casa di ciò che si crea: qui il lavoro dell'anno è creativo e vuole disciplina. | docs/corpus/oroscopo_annuale.md:343 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 6**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-171 | Saturno nella tua Rivoluzione Solare cade nella casa 6, quella del lavoro quotidiano e della salute, dove chiede organizzazione. | docs/corpus/oroscopo_annuale.md:346 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-172 | Con Saturno nella casa 6 della Rivoluzione Solare si consolida un metodo di lavoro: la tradizione avverte contro la fatica accumulata. | docs/corpus/oroscopo_annuale.md:347 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-173 | Saturno nella tua Rivoluzione Solare è nella casa 6, la casa dei compiti di ogni giorno: qui le responsabilità stanno nelle cose piccole. | docs/corpus/oroscopo_annuale.md:348 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 7**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-174 | Saturno nella tua Rivoluzione Solare cade nella casa 7, quella del partner e dei soci, dove chiede impegni di relazione e patti definiti. | docs/corpus/oroscopo_annuale.md:351 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-175 | Con Saturno nella casa 7 della Rivoluzione Solare i legami si fanno seri o si rivedono: la tradizione chiede lealtà e chiarezza. | docs/corpus/oroscopo_annuale.md:352 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-176 | Saturno nella tua Rivoluzione Solare è nella casa 7, la casa degli altri: il lavoro dell'anno si fa in due, con soci e contratti. | docs/corpus/oroscopo_annuale.md:353 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 5. Saturno in casa 8**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-177 | Saturno nella tua Rivoluzione Solare cade nella casa 8, quella delle risorse condivise: debiti, tasse ed eredità chiedono ordine. | docs/corpus/oroscopo_annuale.md:356 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-178 | Con Saturno nella casa 8 della Rivoluzione Solare l'anno chiede di chiudere ciò che è finito: la tradizione lo legge come un passaggio. | docs/corpus/oroscopo_annuale.md:357 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-179 | Saturno nella tua Rivoluzione Solare è nella casa 8, la casa di ciò che sta in profondità: lì il lavoro dell'anno tocca le paure. | docs/corpus/oroscopo_annuale.md:358 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 9**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-180 | Saturno nella tua Rivoluzione Solare cade nella casa 9, quella degli studi superiori e dei viaggi lontani, dove chiede un lavoro serio. | docs/corpus/oroscopo_annuale.md:361 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-181 | Con Saturno nella casa 9 della Rivoluzione Solare si consolidano le convinzioni: la tradizione avverte che i viaggi lontani chiedono più preparazione. | docs/corpus/oroscopo_annuale.md:362 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-182 | Saturno nella tua Rivoluzione Solare è nella casa 9, la casa del senso e delle idee: lì cadono le responsabilità dell'anno. | docs/corpus/oroscopo_annuale.md:363 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 10**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-183 | Saturno nella tua Rivoluzione Solare cade nella casa 10, quella della carriera e della vita pubblica, dove chiede responsabilità visibili. | docs/corpus/oroscopo_annuale.md:366 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-184 | Con Saturno nella casa 10 della Rivoluzione Solare la carriera si consolida: la tradizione lo considera un anno di prove, con un riconoscimento da guadagnare. | docs/corpus/oroscopo_annuale.md:367 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-185 | Saturno nella tua Rivoluzione Solare è nella casa 10, la casa della reputazione: lì le responsabilità dell'anno sono pubbliche. | docs/corpus/oroscopo_annuale.md:368 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 11**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-186 | Saturno nella tua Rivoluzione Solare cade nella casa 11, quella degli amici e dei gruppi, dove porta le responsabilità dell'anno. | docs/corpus/oroscopo_annuale.md:371 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-187 | Con Saturno nella casa 11 della Rivoluzione Solare si prende un ruolo in un progetto comune: la tradizione avverte contro le promesse facili degli altri. | docs/corpus/oroscopo_annuale.md:372 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-188 | Saturno nella tua Rivoluzione Solare è nella casa 11, la casa delle speranze: lì il lavoro dell'anno riguarda il futuro. | docs/corpus/oroscopo_annuale.md:373 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 5. Saturno in casa 12**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-189 | Saturno nella tua Rivoluzione Solare cade nella casa 12, quella della vita interiore e del ritiro: lì il lavoro dell'anno è interiore. | docs/corpus/oroscopo_annuale.md:376 (frase 1) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-190 | Con Saturno nella casa 12 della Rivoluzione Solare il lavoro è silenzioso: la tradizione lega questa posizione a fatiche nascoste. | docs/corpus/oroscopo_annuale.md:377 (frase 2) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-191 | Saturno nella tua Rivoluzione Solare è nella casa 12, l'ultima del cerchio: lì le responsabilità sono invisibili e preparano il ciclo che viene. | docs/corpus/oroscopo_annuale.md:378 (frase 3) | Astrelle, "How to Read a Solar Return Chart"; Mary Fortier Shea per Saturno come maestro di maturità (corpus, righe 45 e 47) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Ariete**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-192 | Il Medio Cielo della tua Rivoluzione Solare è in Ariete: la direzione del lavoro è l'iniziativa. | docs/corpus/oroscopo_annuale.md:383 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-193 | Con il Medio Cielo della Rivoluzione Solare in Ariete l'anno è adatto a mettersi in proprio o a guidare un progetto: la tradizione avverte contro gli scontri con chi sta sopra. | docs/corpus/oroscopo_annuale.md:384 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-194 | Il Medio Cielo della tua Rivoluzione Solare cade in Ariete, segno di chi apre la strada: per questo il lavoro dell'anno vuole azione. | docs/corpus/oroscopo_annuale.md:385 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Toro**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-195 | Il Medio Cielo della tua Rivoluzione Solare è in Toro: la direzione del lavoro è la concretezza. | docs/corpus/oroscopo_annuale.md:388 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-196 | Con il Medio Cielo della Rivoluzione Solare in Toro l'anno è adatto ad attività legate alla bellezza, al cibo, alla terra e al denaro: vale la costanza più della velocità. | docs/corpus/oroscopo_annuale.md:389 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-197 | Il Medio Cielo della tua Rivoluzione Solare cade in Toro, segno che premia la costanza: per questo l'anno consolida invece di cambiare. | docs/corpus/oroscopo_annuale.md:390 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Gemelli**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-198 | Il Medio Cielo della tua Rivoluzione Solare è in Gemelli: la direzione del lavoro è la comunicazione. | docs/corpus/oroscopo_annuale.md:393 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-199 | Con il Medio Cielo della Rivoluzione Solare in Gemelli l'anno è adatto a portare avanti più attività insieme; il rischio di questo segno è la dispersione. | docs/corpus/oroscopo_annuale.md:394 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-200 | Il Medio Cielo della tua Rivoluzione Solare cade in Gemelli, segno curioso e mobile: per questo il lavoro dell'anno vuole prontezza. | docs/corpus/oroscopo_annuale.md:395 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Cancro**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-201 | Il Medio Cielo della tua Rivoluzione Solare è in Cancro: la direzione del lavoro è la cura. | docs/corpus/oroscopo_annuale.md:398 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-202 | Con il Medio Cielo della Rivoluzione Solare in Cancro l'anno è adatto a lavorare da casa o in un ambiente familiare: la tradizione lega il Cancro al pubblico. | docs/corpus/oroscopo_annuale.md:399 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-203 | Il Medio Cielo della tua Rivoluzione Solare cade in Cancro, segno che dà molto quando si sente al sicuro: per questo il lavoro dell'anno vuole empatia. | docs/corpus/oroscopo_annuale.md:400 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Leone**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-204 | Il Medio Cielo della tua Rivoluzione Solare è in Leone: la direzione del lavoro è la visibilità. | docs/corpus/oroscopo_annuale.md:403 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-205 | Con il Medio Cielo della Rivoluzione Solare in Leone l'anno è adatto a ruoli creativi o di guida, su ciò che dà orgoglio. | docs/corpus/oroscopo_annuale.md:404 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-206 | Il Medio Cielo della tua Rivoluzione Solare cade in Leone, segno generoso che chiede cuore e non prudenza: per questo nel lavoro dell'anno conta la convinzione. | docs/corpus/oroscopo_annuale.md:405 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Vergine**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-207 | Il Medio Cielo della tua Rivoluzione Solare è in Vergine: la direzione del lavoro è la precisione. | docs/corpus/oroscopo_annuale.md:408 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-208 | Con il Medio Cielo della Rivoluzione Solare in Vergine l'anno è adatto alla salute, all'analisi e all'artigianato, campi in cui vale la qualità. | docs/corpus/oroscopo_annuale.md:409 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-209 | Il Medio Cielo della tua Rivoluzione Solare cade in Vergine, segno attento ai dettagli e al perfezionamento: per questo il lavoro dell'anno vuole metodo. | docs/corpus/oroscopo_annuale.md:410 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Bilancia**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-210 | Il Medio Cielo della tua Rivoluzione Solare è in Bilancia: la direzione del lavoro è la collaborazione. | docs/corpus/oroscopo_annuale.md:413 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-211 | Con il Medio Cielo della Rivoluzione Solare in Bilancia l'anno è adatto all'arte, al diritto e alle relazioni pubbliche, con contratti equi. | docs/corpus/oroscopo_annuale.md:414 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-212 | Il Medio Cielo della tua Rivoluzione Solare cade in Bilancia, segno della bellezza e dell'equilibrio: per questo il lavoro dell'anno vuole tatto e forma. | docs/corpus/oroscopo_annuale.md:415 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Scorpione**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-213 | Il Medio Cielo della tua Rivoluzione Solare è in Scorpione: la direzione del lavoro è la profondità. | docs/corpus/oroscopo_annuale.md:418 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-214 | Con il Medio Cielo della Rivoluzione Solare in Scorpione l'anno è adatto alla finanza, alla ricerca e alla psicologia, campi in cui si lavora a carte coperte. | docs/corpus/oroscopo_annuale.md:419 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-215 | Il Medio Cielo della tua Rivoluzione Solare cade in Scorpione, segno della trasformazione: per questo il lavoro dell'anno rinnova ciò che non regge più. | docs/corpus/oroscopo_annuale.md:420 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Sagittario**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-216 | Il Medio Cielo della tua Rivoluzione Solare è in Sagittario: la direzione del lavoro è l'espansione. | docs/corpus/oroscopo_annuale.md:423 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-217 | Con il Medio Cielo della Rivoluzione Solare in Sagittario l'anno è adatto all'insegnamento, all'editoria, ai viaggi e all'estero. | docs/corpus/oroscopo_annuale.md:424 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-218 | Il Medio Cielo della tua Rivoluzione Solare cade in Sagittario, segno fiducioso: la tradizione avverte contro le promesse fatte troppo in fretta. | docs/corpus/oroscopo_annuale.md:425 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Capricorno**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-219 | Il Medio Cielo della tua Rivoluzione Solare è in Capricorno: la direzione del lavoro è l'ambizione. | docs/corpus/oroscopo_annuale.md:428 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-220 | Con il Medio Cielo della Rivoluzione Solare in Capricorno l'anno è adatto a ruoli di responsabilità: la tradizione vede nel Capricorno il segno naturale del Medio Cielo. | docs/corpus/oroscopo_annuale.md:429 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-221 | Il Medio Cielo della tua Rivoluzione Solare cade in Capricorno, segno dei risultati che vengono dalla costanza più che dalla fortuna. | docs/corpus/oroscopo_annuale.md:430 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Acquario**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-222 | Il Medio Cielo della tua Rivoluzione Solare è in Acquario: la direzione del lavoro è l'innovazione. | docs/corpus/oroscopo_annuale.md:433 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-223 | Con il Medio Cielo della Rivoluzione Solare in Acquario l'anno è adatto alla tecnologia, ai gruppi e ai progetti sociali, senza perdere autonomia. | docs/corpus/oroscopo_annuale.md:434 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-224 | Il Medio Cielo della tua Rivoluzione Solare cade in Acquario, segno indipendente che guarda al futuro: per questo il lavoro dell'anno vuole cambiamento. | docs/corpus/oroscopo_annuale.md:435 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 6. Medio Cielo in Pesci**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-225 | Il Medio Cielo della tua Rivoluzione Solare è in Pesci: la direzione del lavoro è l'ispirazione. | docs/corpus/oroscopo_annuale.md:438 (frase 1) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-226 | Con il Medio Cielo della Rivoluzione Solare in Pesci l'anno è adatto all'arte, alla cura e alla spiritualità, con compiti e compensi ben definiti. | docs/corpus/oroscopo_annuale.md:439 (frase 2) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-227 | Il Medio Cielo della tua Rivoluzione Solare cade in Pesci, segno che assorbe molto, anche ciò che non è suo: per questo l'anno chiede confini nei ruoli. | docs/corpus/oroscopo_annuale.md:440 (frase 3) | Alexandre Volguine, "The Technique of Solar Returns" (1976, edizione originale 1937), per come lo riportano Astrotheme e Scribd (corpus, righe 45 e 47; riga 527: "Capitoli e pagine non verificati direttamente") | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 1**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-228 | La Luna della tua Rivoluzione Solare cade nella casa 1: lì le emozioni dell'anno stanno in superficie e si sentono di più. | docs/corpus/oroscopo_annuale.md:445 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-229 | La Luna dell'anno è in casa 1: per gli autori porta un'emotività accentuata, fatta di umori che cambiano. | docs/corpus/oroscopo_annuale.md:446 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-230 | La Luna della tua Rivoluzione Solare è nella casa 1, la casa della persona: le emozioni dell'anno riguardano prima di tutto te. | docs/corpus/oroscopo_annuale.md:447 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 7. Luna in casa 2**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-231 | La Luna della tua Rivoluzione Solare cade nella casa 2, quella del denaro e dei beni: lì cerca sicurezza il clima emotivo dell'anno. | docs/corpus/oroscopo_annuale.md:450 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-232 | La Luna dell'anno è in casa 2: la tradizione lega questa posizione a entrate che oscillano come le fasi della Luna. | docs/corpus/oroscopo_annuale.md:451 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-233 | La Luna della tua Rivoluzione Solare è nella casa 2, la casa delle cose possedute: è lì che il cuore dell'anno cerca stabilità. | docs/corpus/oroscopo_annuale.md:452 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 3**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-234 | La Luna della tua Rivoluzione Solare cade nella casa 3, quella della mente e delle conversazioni. | docs/corpus/oroscopo_annuale.md:455 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-235 | La Luna dell'anno è in casa 3: questa casa riguarda i fratelli, i vicini e i brevi viaggi. | docs/corpus/oroscopo_annuale.md:456 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-236 | La Luna della tua Rivoluzione Solare è nella casa 3, la casa della parola: è lì che si muovono le emozioni dell'anno. | docs/corpus/oroscopo_annuale.md:457 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 4**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-237 | La Luna della tua Rivoluzione Solare cade nella casa 4, quella della casa e della famiglia. | docs/corpus/oroscopo_annuale.md:460 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-238 | La Luna dell'anno è in casa 4: la tradizione lega questa posizione ai cambi di casa o a un ritorno alle radici. | docs/corpus/oroscopo_annuale.md:461 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-239 | La Luna della tua Rivoluzione Solare è nella casa 4, la casa della famiglia e dell'intimità: è lì che si raccolgono le emozioni dell'anno. | docs/corpus/oroscopo_annuale.md:462 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 5**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-240 | La Luna della tua Rivoluzione Solare cade nella casa 5, quella della gioia, dell'amore e della creatività. | docs/corpus/oroscopo_annuale.md:465 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-241 | La Luna dell'anno è in casa 5: la tradizione lega questa posizione alla creazione e anche ai figli. | docs/corpus/oroscopo_annuale.md:466 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-242 | La Luna della tua Rivoluzione Solare è nella casa 5, la casa del gioco e del piacere: è lì che vanno le emozioni dell'anno. | docs/corpus/oroscopo_annuale.md:467 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 6**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-243 | La Luna della tua Rivoluzione Solare cade nella casa 6, quella del quotidiano, del lavoro e del corpo. | docs/corpus/oroscopo_annuale.md:470 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-244 | La Luna dell'anno è in casa 6: la tradizione lega questa posizione alla cura della salute e a cambi nella routine. | docs/corpus/oroscopo_annuale.md:471 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-245 | La Luna della tua Rivoluzione Solare è nella casa 6, la casa del lavoro di ogni giorno: è lì che si sentono le emozioni dell'anno. | docs/corpus/oroscopo_annuale.md:472 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 7**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-246 | La Luna della tua Rivoluzione Solare cade nella casa 7: per gli autori rende le relazioni emotivamente centrali. | docs/corpus/oroscopo_annuale.md:475 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-247 | La Luna dell'anno è in casa 7: la tradizione avverte che qui l'umore degli altri pesa sul tuo. | docs/corpus/oroscopo_annuale.md:476 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-248 | La Luna della tua Rivoluzione Solare è nella casa 7, la casa dell'altro: le emozioni dell'anno passano dalle relazioni. | docs/corpus/oroscopo_annuale.md:477 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 7. Luna in casa 8**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-249 | La Luna della tua Rivoluzione Solare cade nella casa 8: lì il clima emotivo dell'anno si fa intenso e profondo. | docs/corpus/oroscopo_annuale.md:480 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-250 | La Luna dell'anno è in casa 8: la tradizione lega questa posizione al lavoro interiore e anche al denaro condiviso. | docs/corpus/oroscopo_annuale.md:481 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-251 | La Luna della tua Rivoluzione Solare è nella casa 8, la casa di ciò che finisce: lì le emozioni dell'anno vanno in profondità. | docs/corpus/oroscopo_annuale.md:482 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 9**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-252 | La Luna della tua Rivoluzione Solare cade nella casa 9, quella dei viaggi, degli studi e degli orizzonti lontani. | docs/corpus/oroscopo_annuale.md:485 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-253 | La Luna dell'anno è in casa 9: questa casa riguarda la ricerca spirituale e i paesi stranieri. | docs/corpus/oroscopo_annuale.md:486 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-254 | La Luna della tua Rivoluzione Solare è nella casa 9, la casa dei viaggi e della ricerca di senso: lì le emozioni dell'anno cercano orizzonti. | docs/corpus/oroscopo_annuale.md:487 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 10**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-255 | La Luna della tua Rivoluzione Solare cade nella casa 10: per gli autori carriera e vita pubblica si caricano di emozioni. | docs/corpus/oroscopo_annuale.md:490 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-256 | La Luna dell'anno è in casa 10: la tradizione lega questa posizione a cambiamenti nella carriera e a una maggiore esposizione. | docs/corpus/oroscopo_annuale.md:491 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |
| O-A-257 | La Luna della tua Rivoluzione Solare è nella casa 10, la casa della vita pubblica: lì le emozioni dell'anno si vedono. | docs/corpus/oroscopo_annuale.md:492 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | caso | fonte dichiarata | la fonte nomina proprio questa casa |

**Corpus annuale, 7. Luna in casa 11**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-258 | La Luna della tua Rivoluzione Solare cade nella casa 11: amici e gruppi sono la fonte di conforto dell'anno. | docs/corpus/oroscopo_annuale.md:495 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-259 | La Luna dell'anno è in casa 11: questa casa riguarda le amicizie nuove e i desideri. | docs/corpus/oroscopo_annuale.md:496 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-260 | La Luna della tua Rivoluzione Solare è nella casa 11, la casa degli amici e dei gruppi: lì le emozioni dell'anno si condividono. | docs/corpus/oroscopo_annuale.md:497 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

**Corpus annuale, 7. Luna in casa 12**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-A-261 | La Luna della tua Rivoluzione Solare cade nella casa 12: lì il clima emotivo dell'anno è interiore e raccolto. | docs/corpus/oroscopo_annuale.md:500 (frase 1) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-262 | La Luna dell'anno è in casa 12: la tradizione lega questa posizione a emozioni nascoste. | docs/corpus/oroscopo_annuale.md:501 (frase 2) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |
| O-A-263 | La Luna della tua Rivoluzione Solare è nella casa 12, la casa del ritiro: lì le emozioni dell'anno restano dentro. | docs/corpus/oroscopo_annuale.md:502 (frase 3) | Cafe Astrology, "Interpreting Solar Returns" e "Solar Returns: The Moon"; Astrelle, "How to Read a Solar Return Chart" (corpus, riga 51) | regola | fonte dichiarata | la fonte dà che cosa indica il pianeta o l'angolo nella Rivoluzione, non il significato del singolo segno o della singola casa |

### Note del metodo

Il punto interrogativo della scheda (`oroscopo_screen.dart:2957-2975`) mostra `card.metodo` o, se manca, `IlMetodoDelResponso.delGiorno`: nell'Occidentale del Giorno è sempre questa seconda, nell'Anno le note del corpus annuale. La Settimana e il Mese non hanno il punto interrogativo del metodo.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| O-M-001 | La prima frase viene dalla Luna di oggi: il segno in cui si trova, contato dal tuo segno solare, dice in quale casa solare passa. | lib/core/horoscope/il_metodo_del_responso.dart:20-22 | nessuna | nessuna | **SENZA FONTE** | Giorno, tutte le schede; vedi le Osservazioni |
| O-M-002 | Il resto viene dai transiti di oggi sulla tua carta natale, calcolati sul telefono dalle effemeridi: i pianeti che passano sui tuoi pianeti di nascita e nelle tue case. | lib/core/horoscope/il_metodo_del_responso.dart:24-27 | nessuna | nessuna | **SENZA FONTE** | con la carta completa; vedi le Osservazioni |
| O-M-003 | Il resto viene dai transiti di oggi sui tuoi pianeti di nascita, calcolati sul telefono dalle effemeridi. Senza l'ora di nascita le case non si calcolano. | lib/core/horoscope/il_metodo_del_responso.dart:28-31 | nessuna | nessuna | **SENZA FONTE** | carta senza ora |
| O-M-004 | Il resto è scelto per il tuo segno e per il giorno fra le frasi di Medora: senza ora e luogo di nascita non c'è una carta su cui calcolare i transiti. | lib/core/horoscope/il_metodo_del_responso.dart:32-35 | nessuna | nessuna | **SENZA FONTE** | solo il segno |
| O-M-005 | Il livello da due a cinque viene dalla Luna di oggi e dal pianeta di questo campo: dal segno in cui si trovano rispetto al tuo e dalle case solari che attraversano. Tre vuol dire un giorno neutro. | lib/core/horoscope/il_metodo_del_responso.dart:38-41 | nessuna | nessuna | **SENZA FONTE** | solo il segno |
| O-M-006 | Il livello da due a cinque viene dai passaggi di oggi che parlano a questo campo: quelli armonici lo alzano, quelli tesi lo abbassano. Contano di più quanto sono stretti. | lib/core/horoscope/il_metodo_del_responso.dart:42-44 | nessuna | nessuna | **SENZA FONTE** | con la carta; le regole con fonte della voce EU.09 (Hand, Lilly) non sono nella nota |
| O-M-007 | Il numero è il giorno personale della numerologia, dalla tua data di nascita e da quella di oggi. | lib/core/horoscope/il_metodo_del_responso.dart:47-49 | nessuna (Hans Decoz è nominato, senza opera, solo nel commento di lib/core/horoscope/il_numero_e_il_colore.dart) | nessuna | **SENZA FONTE** | Fortuna |
| O-M-008 | Il colore è quello tradizionale del pianeta che oggi pesa di più per te, dai colori di William Lilly. | lib/core/horoscope/il_metodo_del_responso.dart:49-51 | William Lilly, nella frase; l'opera e i capitoli nel commento di lib/core/horoscope/il_numero_e_il_colore.dart (righe 13-20): Christian Astrology, libro I, capitoli VIII-XV | caso | fonte dichiarata | Fortuna |
| O-M-009 | Il tuo anno si legge dalla Rivoluzione Solare: il tema calcolato nell'istante in cui il Sole torna al grado esatto che aveva alla tua nascita, nel luogo in cui ti trovi al compleanno. | docs/corpus/oroscopo_annuale.md:509 (notaGenerale) | Astrotheme, "Solar Return: Definition and Principles"; Volguine, "The Technique of Solar Returns"; Mary Fortier Shea, maryshea.com (corpus, "Il metodo", riga 7) | regola | fonte dichiarata | Anno, Generale |
| O-M-010 | Da quel tema leggo l'Ascendente, per il tono dell'anno, la casa del Sole, per dove va l'energia, la casa della Luna, per il clima emotivo. | docs/corpus/oroscopo_annuale.md:509 (notaGenerale) | March e McEvers citati da Stathis; Cafe Astrology (corpus, righe 21, 27, 51) | regola | fonte dichiarata | Anno, Generale |
| O-M-011 | Qui leggo la casa in cui cade Venere per l'amore, Giove per la fortuna, Saturno per il lavoro nella tua Rivoluzione Solare, insieme al segno del Medio Cielo per la direzione del lavoro. | docs/corpus/oroscopo_annuale.md:512 (notaDomini) | Cafe Astrology; Astrelle; Volguine (corpus, righe 33, 39, 45) | regola | fonte dichiarata | Anno, Amore, Lavoro, Fortuna |
| O-M-012 | Un pianeta vicino al confine fra due case può cadere nella casa accanto con un altro sistema di case. | docs/corpus/oroscopo_annuale.md:512 (notaDomini) | nessuna | nessuna | **SENZA FONTE** | avvertenza di calcolo |
| O-M-013 | Le case sono equali: dodici settori di trenta gradi a partire dall'Ascendente dell'anno, perché il calcolo avviene sul tuo telefono. | docs/corpus/oroscopo_annuale.md:515 (notaTutte) | nessuna: il corpus (riga 11) la dichiara "scelta di calcolo" e scrive "Nessuno degli autori citati prescrive le case equali" | nessuna | **SENZA FONTE** | Anno, tutte le schede |
| O-M-014 | Sono le indicazioni della tradizione per i dodici mesi da un compleanno all'altro, non previsioni: dicono che cosa conviene, la scelta resta tua. | docs/corpus/oroscopo_annuale.md:515 (notaTutte) | Shea, il tema dell'anno valido da un compleanno al successivo (corpus, riga 9) | regola | fonte dichiarata | il resto della frase è un'avvertenza |

## Vedica

### Giorno

La riga "Da dove viene" della Generale mette insieme la frase della Chandra Bala, quella della Tara Bala (o la riga senza ora di nascita), quella del Rahu Kalam, nella Lunga quella del giorno della settimana, e la riga del livello (`la_lettura_vedica.dart:344-353`). Amore, Lavoro e Fortuna: la frase del caso, nella Lunga la riga della Luna col tema del dominio e, nella Fortuna, quella del giorno della settimana, poi la riga del livello (`la_lettura_vedica.dart:380-389`). Prima le righe scritte nel codice, poi il corpus.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-001 | Con l'ora di nascita leggo anche la tua stella, la Tara Bala: oggi la Luna è in {nakshatra}, {traduzione}. | lib/core/horoscope/la_lettura_vedica.dart:274-279 | B. V. Raman, Muhurtha, cap. III (commento righe 29-30); traduzioni dei nakshatra: Monier-Williams (commento righe 46-47) | regola | fonte dichiarata | Generale, senza l'ora di nascita |
| V-G-002 | Il livello viene dalla Luna di oggi {nel segno}, nella tua {ordinale} casa dalla Luna di nascita ({favorevole \| di attenzione \| sfavorevole \| Chandrashtama}); e dalla tua tara di oggi, {Janma ... Parama Mitra} ({esito}). | lib/core/horoscope/la_lettura_vedica.dart:349-352, 463-473 | Brihat Samhita 104, Phaladeepika 26 (commento righe 27-28); Raman, Muhurtha III (righe 29-30) e la citazione di Raman "These three should be satisfactorily disposed" (righe 475-478); esiti della tara come Drik (righe 113-114) | regola | fonte dichiarata | Generale; la scala dei punti da due a cinque è dell'app |
| V-G-003 | Oggi la Luna passa {nel segno}, nella tua {ordinale} casa contata dalla Luna di nascita; per l'amore contano la settima casa, dell'unione, con la quinta, del cuore che si apre. | lib/core/horoscope/la_lettura_vedica.dart:383-385, 498-500 | nessuna per la quinta come cuore: la nota del metodo (righe 554-555) la dice "lettura moderna" | nessuna | **SENZA FONTE** | Amore, Lunga; la settima ha fonte (BPHS cap. 11, righe 552-554) |
| V-G-004 | Oggi la Luna passa {nel segno}, nella tua {ordinale} casa contata dalla Luna di nascita; per il lavoro conta la decima casa, del lavoro e del nome. | lib/core/horoscope/la_lettura_vedica.dart:383-385, 501-502 | Phaladeepika 26.1 per il conto dalla Luna; Brihat Parashara Hora Shastra, cap. 11 per i significati (lib/core/horoscope/la_lettura_vedica.dart:552-554) | caso | fonte dichiarata | Lavoro, Lunga |
| V-G-005 | Oggi la Luna passa {nel segno}, nella tua {ordinale} casa contata dalla Luna di nascita; per la fortuna contano la seconda casa, dei beni, con l'undicesima, dei guadagni. | lib/core/horoscope/la_lettura_vedica.dart:383-385, 503-505 | Phaladeepika 26.1; Brihat Parashara Hora Shastra, cap. 11 (lib/core/horoscope/la_lettura_vedica.dart:552-554) | caso | fonte dichiarata | Fortuna, Lunga |
| V-G-006 | Il livello viene dalla Luna di oggi nella tua {ordinale} casa dalla Luna di nascita: la Luna in ottava, il giorno più delicato. | lib/core/horoscope/la_lettura_vedica.dart:387-388, 512-514 | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (corpus vedico, righe 142-144) | caso | fonte dichiarata | Amore, Lavoro, Fortuna |
| V-G-007 | Il livello viene dalla Luna di oggi nella tua {ordinale} casa dalla Luna di nascita: la Luna attraversa la {settima \| quinta \| decima \| seconda \| undicesima}. | lib/core/horoscope/la_lettura_vedica.dart:387-388, 515-521 | Brihat Parashara Hora Shastra, cap. 11 (lib/core/horoscope/la_lettura_vedica.dart:552-554); Chandra Bala: Brihat Samhita 104, Phaladeepika 26 (commento righe 27-28) | caso | fonte dichiarata | con la quinta dell'Amore: la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere) |
| V-G-008 | Il livello viene dalla Luna di oggi nella tua {ordinale} casa dalla Luna di nascita: la Luna guarda la {settima \| quinta \| decima \| seconda \| undicesima} dalla settima da sé. | lib/core/horoscope/la_lettura_vedica.dart:387-388, 522-529 | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314) | caso | fonte dichiarata | il commento del codice accanto rimanda solo alle specifiche (6.3); la fonte la dà il corpus |
| V-G-009 | Il livello viene dalla Luna di oggi nella tua {ordinale} casa dalla Luna di nascita: Luna favorevole. | lib/core/horoscope/la_lettura_vedica.dart:387-388, 531 | Chandra Bala: Brihat Samhita 104, Phaladeepika 26 (commento righe 27-28) | regola | fonte dichiarata |  |
| V-G-010 | Il livello viene dalla Luna di oggi nella tua {ordinale} casa dalla Luna di nascita: Luna di attenzione. | lib/core/horoscope/la_lettura_vedica.dart:387-388, 532-536 | Chandra Bala: Brihat Samhita 104, Phaladeepika 26 (commento righe 27-28) | regola | fonte dichiarata |  |
| V-G-011 | Il livello viene dalla Luna di oggi nella tua {ordinale} casa dalla Luna di nascita: Luna sfavorevole. | lib/core/horoscope/la_lettura_vedica.dart:387-388, 537 | Chandra Bala: Brihat Samhita 104, Phaladeepika 26 (commento righe 27-28) | regola | fonte dichiarata |  |
| V-G-012 | Oggi governa {pianeta}: il colore del giorno è il {colore}, dal Brihat Jataka; il numero, {numero}, viene dalla numerologia indiana moderna, non dai testi antichi. | lib/core/horoscope/la_lettura_vedica.dart:393-397, 91-99 | Brihat Jataka, nella frase; corpus: Brihat Jataka 2.5 per i colori, Cheiro 1926 per i numeri (righe 263-266) | caso | fonte dichiarata | riga della Fortuna; per Venere il codice dice "bianco screziato" (riga 97), il corpus "lo screziato" (riga 275) |

**Corpus vedico, 1. Casa 1: la Luna torna nel tuo segno** (nota del caso nel corpus: Fonte: Brihat Samhita 104.8, "pasti, letti e vesti eccellenti"; Phaladeepika 26.12, "nascita di fortuna".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-013 | Oggi la Luna torna {segno_luna}, dove stava alla tua nascita: nella tradizione indiana è un giorno di pasti, letti e vesti eccellenti. | docs/corpus/oroscopo_vedico.md:83 (frase 1) | Brihat Samhita 104.8, "pasti, letti e vesti eccellenti"; Phaladeepika 26.12, "nascita di fortuna". (Casa 1: la Luna torna nel tuo segno); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-014 | La Luna è di nuovo nel tuo segno di nascita: è la prima casa della Chandra Bala, che la tradizione indiana conta fra le favorevoli. | docs/corpus/oroscopo_vedico.md:84 (frase 2) | Brihat Samhita 104.8, "pasti, letti e vesti eccellenti"; Phaladeepika 26.12, "nascita di fortuna". (Casa 1: la Luna torna nel tuo segno); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-015 | Con la Luna nel tuo segno i testi antichi parlano di benessere semplice, di tavola buona e letto comodo; la Phaladeepika la chiama "nascita di fortuna". | docs/corpus/oroscopo_vedico.md:85 (frase 3) | Brihat Samhita 104.8, "pasti, letti e vesti eccellenti"; Phaladeepika 26.12, "nascita di fortuna". (Casa 1: la Luna torna nel tuo segno); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 2: la Luna sulla casa dei beni** (nota del caso nel corpus: Fonte: Brihat Samhita 104.8, "perdita di beni e ostacoli"; Phaladeepika 26.12, "perdita di ricchezza"; Drik: di attenzione (Puja Needed).)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-016 | Oggi la Luna passa sulla seconda casa dalla tua Luna di nascita, quella dei beni: la tradizione indiana la legge come un giorno di attenzione. | docs/corpus/oroscopo_vedico.md:92 (frase 1) | Brihat Samhita 104.8, "perdita di beni e ostacoli"; Phaladeepika 26.12, "perdita di ricchezza"; Drik: di attenzione (Puja Needed). (Casa 2: la Luna sulla casa dei beni); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-017 | La Luna è nella seconda casa dalla tua Luna di nascita, che la Chandra Bala mette fra le case di attenzione: la Brihat Samhita parla di ostacoli. | docs/corpus/oroscopo_vedico.md:93 (frase 2) | Brihat Samhita 104.8, "perdita di beni e ostacoli"; Phaladeepika 26.12, "perdita di ricchezza"; Drik: di attenzione (Puja Needed). (Casa 2: la Luna sulla casa dei beni); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-018 | Con la Luna in seconda casa la Brihat Samhita parla di beni che scivolano via; la Phaladeepika di perdita di ricchezza. | docs/corpus/oroscopo_vedico.md:94 (frase 3) | Brihat Samhita 104.8, "perdita di beni e ostacoli"; Phaladeepika 26.12, "perdita di ricchezza"; Drik: di attenzione (Puja Needed). (Casa 2: la Luna sulla casa dei beni); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 3: la Luna del coraggio** (nota del caso nel corpus: Fonte: Brihat Samhita 104.8, "vesti, affetti e beni in abbondanza"; Phaladeepika 26.12, "successo".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-019 | Oggi la Luna sta nella terza casa dalla tua Luna di nascita: per la tradizione indiana è una delle case favorevoli, quella del successo. | docs/corpus/oroscopo_vedico.md:101 (frase 1) | Brihat Samhita 104.8, "vesti, affetti e beni in abbondanza"; Phaladeepika 26.12, "successo". (Casa 3: la Luna del coraggio); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-020 | La Luna in terza casa, contata dalla tua Luna di nascita, dà forza alle iniziative: la Phaladeepika la riassume in una parola, "successo". | docs/corpus/oroscopo_vedico.md:102 (frase 2) | Brihat Samhita 104.8, "vesti, affetti e beni in abbondanza"; Phaladeepika 26.12, "successo". (Casa 3: la Luna del coraggio); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-021 | Con la Luna nella terza casa i testi antichi parlano di successo e di vesti, affetti e beni in abbondanza. | docs/corpus/oroscopo_vedico.md:103 (frase 3) | Brihat Samhita 104.8, "vesti, affetti e beni in abbondanza"; Phaladeepika 26.12, "successo". (Casa 3: la Luna del coraggio); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 4: la Luna inquieta** (nota del caso nel corpus: Fonte: Brihat Samhita 104.8 (il nativo è "crudele come un serpente", cioè irrequieto e pungente); Phaladeepika 26.12, "paura".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-022 | Oggi la Luna passa sulla quarta casa dalla tua Luna di nascita, che la tradizione indiana legge come un giorno di inquietudine. | docs/corpus/oroscopo_vedico.md:110 (frase 1) | Brihat Samhita 104.8 (il nativo è "crudele come un serpente", cioè irrequieto e pungente); Phaladeepika 26.12, "paura". (Casa 4: la Luna inquieta); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-023 | La Luna in quarta casa dalla tua Luna di nascita è fra le sfavorevoli: la Brihat Samhita dice che rende irrequieti e pungenti come un serpente. | docs/corpus/oroscopo_vedico.md:111 (frase 2) | Brihat Samhita 104.8 (il nativo è "crudele come un serpente", cioè irrequieto e pungente); Phaladeepika 26.12, "paura". (Casa 4: la Luna inquieta); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-024 | Con la Luna nella quarta casa i testi antichi parlano di timori: la Phaladeepika la riassume nella parola "paura". | docs/corpus/oroscopo_vedico.md:112 (frase 3) | Brihat Samhita 104.8 (il nativo è "crudele come un serpente", cioè irrequieto e pungente); Phaladeepika 26.12, "paura". (Casa 4: la Luna inquieta); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 5: la Luna stanca** (nota del caso nel corpus: Fonte: Brihat Samhita 104.9, "umiliazione, malanni e ostacoli"; Phaladeepika 26.12, "dolore"; Drik: di attenzione.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-025 | Oggi la Luna è nella quinta casa dalla tua Luna di nascita: la tradizione indiana la legge come una casa di attenzione, fatta di ostacoli. | docs/corpus/oroscopo_vedico.md:119 (frase 1) | Brihat Samhita 104.9, "umiliazione, malanni e ostacoli"; Phaladeepika 26.12, "dolore"; Drik: di attenzione. (Casa 5: la Luna stanca); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-026 | La Luna in quinta casa dalla tua Luna di nascita porta, secondo la Phaladeepika, "dolore"; il Drik Panchang la segna come giorno di attenzione. | docs/corpus/oroscopo_vedico.md:120 (frase 2) | Brihat Samhita 104.9, "umiliazione, malanni e ostacoli"; Phaladeepika 26.12, "dolore"; Drik: di attenzione. (Casa 5: la Luna stanca); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-027 | Con la Luna nella quinta casa dalla tua Luna di nascita la Brihat Samhita parla di umiliazione e di ostacoli. | docs/corpus/oroscopo_vedico.md:121 (frase 3) | Brihat Samhita 104.9, "umiliazione, malanni e ostacoli"; Phaladeepika 26.12, "dolore"; Drik: di attenzione. (Casa 5: la Luna stanca); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 6: la Luna che vince** (nota del caso nel corpus: Fonte: Brihat Samhita 104.9, "ricchezza, agio e rovina dei nemici"; Phaladeepika 26.12, "libertà dalla malattia".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-028 | Oggi la Luna passa sulla sesta casa dalla tua Luna di nascita: per la tradizione indiana è il giorno in cui si superano gli intoppi. | docs/corpus/oroscopo_vedico.md:128 (frase 1) | Brihat Samhita 104.9, "ricchezza, agio e rovina dei nemici"; Phaladeepika 26.12, "libertà dalla malattia". (Casa 6: la Luna che vince); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-029 | La Luna in sesta casa dalla tua Luna di nascita è fra le favorevoli: la tradizione indiana dice che dà forza al corpo e alla testa. | docs/corpus/oroscopo_vedico.md:129 (frase 2) | Brihat Samhita 104.9, "ricchezza, agio e rovina dei nemici"; Phaladeepika 26.12, "libertà dalla malattia". (Casa 6: la Luna che vince); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-030 | Con la Luna nella sesta casa i testi antichi parlano di avversari che perdono terreno: la Brihat Samhita dice "rovina dei nemici". | docs/corpus/oroscopo_vedico.md:130 (frase 3) | Brihat Samhita 104.9, "ricchezza, agio e rovina dei nemici"; Phaladeepika 26.12, "libertà dalla malattia". (Casa 6: la Luna che vince); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 7: la Luna dell'incontro** (nota del caso nel corpus: Fonte: Brihat Samhita 104.9, "ricchezza e rispetto"; Phaladeepika 26.12, "felicità".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-031 | Oggi la Luna è nella settima casa dalla tua Luna di nascita, quella dell'altro: la tradizione indiana la dà favorevole. | docs/corpus/oroscopo_vedico.md:137 (frase 1) | Brihat Samhita 104.9, "ricchezza e rispetto"; Phaladeepika 26.12, "felicità". (Casa 7: la Luna dell'incontro); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-032 | La Luna in settima casa dalla tua Luna di nascita porta, secondo la Brihat Samhita, "ricchezza e rispetto". | docs/corpus/oroscopo_vedico.md:138 (frase 2) | Brihat Samhita 104.9, "ricchezza e rispetto"; Phaladeepika 26.12, "felicità". (Casa 7: la Luna dell'incontro); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-033 | Con la Luna nella settima casa i testi parlano di felicità condivisa: "felicità" è la parola che la Phaladeepika usa per questo giorno. | docs/corpus/oroscopo_vedico.md:139 (frase 3) | Brihat Samhita 104.9, "ricchezza e rispetto"; Phaladeepika 26.12, "felicità". (Casa 7: la Luna dell'incontro); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 8: Chandrashtama, la Luna in ottava** (nota del caso nel corpus: Fonte: Brihat Samhita 104.9, "paura dei mali"; Phaladeepika 26.12, "eventi avversi"; Raman, *Muhurtha* cap. III, fra le case da evitare. Il nome proprio è Chandrashtama, "la Luna nell'ottava".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-034 | Oggi la Luna passa sull'ottava casa dalla tua Luna di nascita. In India questo giorno ha un nome, Chandrashtama, "la Luna nell'ottava". | docs/corpus/oroscopo_vedico.md:147 (frase 1) | Brihat Samhita 104.9, "paura dei mali"; Phaladeepika 26.12, "eventi avversi"; Raman, *Muhurtha* cap. III, fra le case da evitare. Il nome proprio è Chandrashtama, "la Luna nell'ottava". (Casa 8: Chandrashtama, la Luna in ottava); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-035 | È il tuo giorno di Chandrashtama, la Luna nell'ottava casa dalla tua Luna di nascita, che il Muhurtha di Raman mette fra le case da evitare. | docs/corpus/oroscopo_vedico.md:148 (frase 2) | Brihat Samhita 104.9, "paura dei mali"; Phaladeepika 26.12, "eventi avversi"; Raman, *Muhurtha* cap. III, fra le case da evitare. Il nome proprio è Chandrashtama, "la Luna nell'ottava". (Casa 8: Chandrashtama, la Luna in ottava); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-036 | La Luna in ottava casa è, per la tradizione indiana, il momento più delicato del suo giro intorno alla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:149 (frase 3) | Brihat Samhita 104.9, "paura dei mali"; Phaladeepika 26.12, "eventi avversi"; Raman, *Muhurtha* cap. III, fra le case da evitare. Il nome proprio è Chandrashtama, "la Luna nell'ottava". (Casa 8: Chandrashtama, la Luna in ottava); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 9: la Luna lontana** (nota del caso nel corpus: Fonte: Brihat Samhita 104.10, "prigionia e dolore"; Phaladeepika 26.12, "malattia"; Drik: di attenzione.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-037 | Oggi la Luna è nella nona casa dalla tua Luna di nascita: la tradizione indiana la legge come un giorno di attenzione, in cui ci si sente trattenuti. | docs/corpus/oroscopo_vedico.md:156 (frase 1) | Brihat Samhita 104.10, "prigionia e dolore"; Phaladeepika 26.12, "malattia"; Drik: di attenzione. (Casa 9: la Luna lontana); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-038 | La Luna in nona casa dalla tua Luna di nascita chiede riguardo per il corpo: il Drik Panchang la segna fra i giorni di attenzione. | docs/corpus/oroscopo_vedico.md:157 (frase 2) | Brihat Samhita 104.10, "prigionia e dolore"; Phaladeepika 26.12, "malattia"; Drik: di attenzione. (Casa 9: la Luna lontana); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-039 | Con la Luna nella nona casa dalla tua Luna di nascita i testi antichi parlano di impedimenti; la Brihat Samhita usa la parola "prigionia". | docs/corpus/oroscopo_vedico.md:158 (frase 3) | Brihat Samhita 104.10, "prigionia e dolore"; Phaladeepika 26.12, "malattia"; Drik: di attenzione. (Casa 9: la Luna lontana); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 10: la Luna che fa** (nota del caso nel corpus: Fonte: Brihat Samhita 104.10, "gli ordini saranno eseguiti, successo nel lavoro"; Phaladeepika 26.12, "desideri realizzati".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-040 | Oggi la Luna passa sulla decima casa dalla tua Luna di nascita, quella dell'azione: la Brihat Samhita dice che "gli ordini saranno eseguiti". | docs/corpus/oroscopo_vedico.md:165 (frase 1) | Brihat Samhita 104.10, "gli ordini saranno eseguiti, successo nel lavoro"; Phaladeepika 26.12, "desideri realizzati". (Casa 10: la Luna che fa); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-041 | La Luna in decima casa dalla tua Luna di nascita sostiene il lavoro e la reputazione: la tradizione indiana la conta fra le case favorevoli. | docs/corpus/oroscopo_vedico.md:166 (frase 2) | Brihat Samhita 104.10, "gli ordini saranno eseguiti, successo nel lavoro"; Phaladeepika 26.12, "desideri realizzati". (Casa 10: la Luna che fa); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-042 | Con la Luna nella decima casa la Phaladeepika parla di "desideri realizzati"; la Brihat Samhita di successo nel lavoro. | docs/corpus/oroscopo_vedico.md:167 (frase 3) | Brihat Samhita 104.10, "gli ordini saranno eseguiti, successo nel lavoro"; Phaladeepika 26.12, "desideri realizzati". (Casa 10: la Luna che fa); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 11: la Luna dei guadagni** (nota del caso nel corpus: Fonte: Brihat Samhita 104.10, "prosperità e amicizie nuove"; Phaladeepika 26.12, "gioia".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-043 | Oggi la Luna è nell'undicesima casa dalla tua Luna di nascita, quella dei frutti: la tradizione indiana la dà tra le migliori. | docs/corpus/oroscopo_vedico.md:174 (frase 1) | Brihat Samhita 104.10, "prosperità e amicizie nuove"; Phaladeepika 26.12, "gioia". (Casa 11: la Luna dei guadagni); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-044 | La Luna in undicesima casa dalla tua Luna di nascita porta, secondo la Brihat Samhita, "prosperità e amicizie nuove". | docs/corpus/oroscopo_vedico.md:175 (frase 2) | Brihat Samhita 104.10, "prosperità e amicizie nuove"; Phaladeepika 26.12, "gioia". (Casa 11: la Luna dei guadagni); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-045 | Con la Luna nell'undicesima casa i testi antichi parlano di prosperità e di gioia: "gioia" è la parola della Phaladeepika. | docs/corpus/oroscopo_vedico.md:176 (frase 3) | Brihat Samhita 104.10, "prosperità e amicizie nuove"; Phaladeepika 26.12, "gioia". (Casa 11: la Luna dei guadagni); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 1. Casa 12: la Luna che spende** (nota del caso nel corpus: Fonte: Brihat Samhita 104.10 (ferite); Phaladeepika 26.12, "spesa".)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-046 | Oggi la Luna passa sulla dodicesima casa dalla tua Luna di nascita, quella delle uscite: la tradizione indiana la conta fra le sfavorevoli. | docs/corpus/oroscopo_vedico.md:182 (frase 1) | Brihat Samhita 104.10 (ferite); Phaladeepika 26.12, "spesa". (Casa 12: la Luna che spende); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-047 | La Luna in dodicesima casa dalla tua Luna di nascita porta stanchezza e spese: "spesa" è la parola della Phaladeepika. | docs/corpus/oroscopo_vedico.md:183 (frase 2) | Brihat Samhita 104.10 (ferite); Phaladeepika 26.12, "spesa". (Casa 12: la Luna che spende); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-048 | Con la Luna nella dodicesima casa dalla tua Luna di nascita i testi parlano di ciò che se ne va. | docs/corpus/oroscopo_vedico.md:184 (frase 3) | Brihat Samhita 104.10 (ferite); Phaladeepika 26.12, "spesa". (Casa 12: la Luna che spende); Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 1, Janma: la tua stessa stella** (nota del caso nel corpus: Raman: "danger to body"; Drik: Not Good. Raman aggiunge che è buona per seminare, comprare terre e cominciare a studiare.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-049 | Oggi la Luna è nella tua stella di nascita, {nakshatra_nascita}: la tradizione indiana chiama questo giorno Janma, "la nascita". | docs/corpus/oroscopo_vedico.md:199 (frase 1) | Raman: "danger to body"; Drik: Not Good. Raman aggiunge che è buona per seminare, comprare terre e cominciare a studiare. (Tara 1, Janma: la tua stessa stella); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-050 | La Luna torna sulla tua stella, {nakshatra_nascita}: è la tara Janma, che Raman dà buona per seminare e cominciare a studiare, non per il resto. | docs/corpus/oroscopo_vedico.md:200 (frase 2) | Raman: "danger to body"; Drik: Not Good. Raman aggiunge che è buona per seminare, comprare terre e cominciare a studiare. (Tara 1, Janma: la tua stessa stella); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-051 | È il tuo giorno di Janma, la Luna sulla stella della tua nascita: nella Tara Bala è la prima delle nove, buona per cominciare a studiare. | docs/corpus/oroscopo_vedico.md:201 (frase 3) | Raman: "danger to body"; Drik: Not Good. Raman aggiunge che è buona per seminare, comprare terre e cominciare a studiare. (Tara 1, Janma: la tua stessa stella); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 2, Sampat: la ricchezza** (nota del caso nel corpus: Raman: "wealth and prosperity"; Drik: Very Good.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-052 | La stella di oggi, {nakshatra_oggi}, è per te Sampat, "la ricchezza": è la seconda contata dalla tua, che il Drik Panchang dà molto buona. | docs/corpus/oroscopo_vedico.md:206 (frase 1) | Raman: "wealth and prosperity"; Drik: Very Good. (Tara 2, Sampat: la ricchezza); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-053 | Oggi la stella della Luna ti è amica: è Sampat, la seconda dalla tua stella di nascita, che la tradizione indiana dà propizia. | docs/corpus/oroscopo_vedico.md:207 (frase 2) | Raman: "wealth and prosperity"; Drik: Very Good. (Tara 2, Sampat: la ricchezza); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-054 | Sampat è la stella della prosperità: nella Tara Bala di Raman e del Drik Panchang è uno dei giorni più propizi dei nove. | docs/corpus/oroscopo_vedico.md:208 (frase 3) | Raman: "wealth and prosperity"; Drik: Very Good. (Tara 2, Sampat: la ricchezza); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 3, Vipat: il pericolo** (nota del caso nel corpus: Raman: "dangers, losses and accidents"; Drik: Bad.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-055 | La stella di oggi, {nakshatra_oggi}, è per te Vipat, "il pericolo": la terza contata dalla tua, che la tradizione indiana chiede di attraversare con attenzione. | docs/corpus/oroscopo_vedico.md:213 (frase 1) | Raman: "dangers, losses and accidents"; Drik: Bad. (Tara 3, Vipat: il pericolo); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-056 | Oggi la tradizione indiana ti dà Vipat, la stella delle perdite: nella Tara Bala è la terza delle nove. | docs/corpus/oroscopo_vedico.md:214 (frase 2) | Raman: "dangers, losses and accidents"; Drik: Bad. (Tara 3, Vipat: il pericolo); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-057 | Con Vipat, la terza tara, Raman consiglia di evitare le cose importanti; il Drik Panchang la segna fra i giorni sfavorevoli. | docs/corpus/oroscopo_vedico.md:215 (frase 3) | Raman: "dangers, losses and accidents"; Drik: Bad. (Tara 3, Vipat: il pericolo); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 4, Kshema: il benessere** (nota del caso nel corpus: Raman: "prosperity"; Drik: Good.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-058 | La stella di oggi, {nakshatra_oggi}, è per te Kshema, "il benessere": la quarta contata dalla tua, che la tradizione indiana dà buona. | docs/corpus/oroscopo_vedico.md:220 (frase 1) | Raman: "prosperity"; Drik: Good. (Tara 4, Kshema: il benessere); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-059 | Oggi hai Kshema, la stella della prosperità tranquilla: nella Tara Bala è la quarta delle nove, fra quelle favorevoli. | docs/corpus/oroscopo_vedico.md:221 (frase 2) | Raman: "prosperity"; Drik: Good. (Tara 4, Kshema: il benessere); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-060 | Con Kshema, la quarta tara, la tradizione indiana vede un giorno sereno; Raman la lega alla prosperità. | docs/corpus/oroscopo_vedico.md:222 (frase 3) | Raman: "prosperity"; Drik: Good. (Tara 4, Kshema: il benessere); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 5, Pratyak: l'ostacolo** (nota del caso nel corpus: Raman: "obstacles"; Drik: Not Good (la chiama Pratyari).)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-061 | La stella di oggi, {nakshatra_oggi}, è per te Pratyak, "l'ostacolo": la quinta contata dalla tua, che la tradizione indiana non dà favorevole. | docs/corpus/oroscopo_vedico.md:227 (frase 1) | Raman: "obstacles"; Drik: Not Good (la chiama Pratyari). (Tara 5, Pratyak: l'ostacolo); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-062 | Oggi hai Pratyak, la quinta delle nove tare: nella Tara Bala è la stella che rallenta, quella che Raman chiama degli ostacoli. | docs/corpus/oroscopo_vedico.md:228 (frase 2) | Raman: "obstacles"; Drik: Not Good (la chiama Pratyari). (Tara 5, Pratyak: l'ostacolo); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-063 | Con Pratyak, la stella dell'ostacolo, la Tara Bala segna un giorno poco favorevole: è la quinta contata dalla tua stella di nascita. | docs/corpus/oroscopo_vedico.md:229 (frase 3) | Raman: "obstacles"; Drik: Not Good (la chiama Pratyari). (Tara 5, Pratyak: l'ostacolo); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 6, Sadhana: la riuscita** (nota del caso nel corpus: Raman: "realisation of ambitions"; Drik: Very Good (la chiama Sadhaka).)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-064 | La stella di oggi, {nakshatra_oggi}, è per te Sadhana, "la riuscita": la sesta contata dalla tua, per la tradizione indiana fra le più favorevoli. | docs/corpus/oroscopo_vedico.md:234 (frase 1) | Raman: "realisation of ambitions"; Drik: Very Good (la chiama Sadhaka). (Tara 6, Sadhana: la riuscita); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-065 | Oggi hai Sadhana, la sesta delle nove tare: Raman la lega alla realizzazione delle ambizioni, il Drik Panchang la dà molto buona. | docs/corpus/oroscopo_vedico.md:235 (frase 2) | Raman: "realisation of ambitions"; Drik: Very Good (la chiama Sadhaka). (Tara 6, Sadhana: la riuscita); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-066 | Con Sadhana, la stella della riuscita, la Tara Bala segna uno dei giorni migliori dei nove: è la sesta contata dalla tua stella di nascita. | docs/corpus/oroscopo_vedico.md:236 (frase 3) | Raman: "realisation of ambitions"; Drik: Very Good (la chiama Sadhaka). (Tara 6, Sadhana: la riuscita); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 7, Naidhana: la fine** (nota del caso nel corpus: Raman: "dangers", da evitare per le imprese importanti; Drik: Totally Bad.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-067 | La stella di oggi, {nakshatra_oggi}, è per te Naidhana, la settima contata dalla tua: la tradizione indiana la considera la più delicata delle nove. | docs/corpus/oroscopo_vedico.md:241 (frase 1) | Raman: "dangers", da evitare per le imprese importanti; Drik: Totally Bad. (Tara 7, Naidhana: la fine); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-068 | Oggi hai Naidhana, "la fine". Non è un presagio: nella Tara Bala è il giorno che la tradizione indiana lascia alle chiusure, non agli inizi. | docs/corpus/oroscopo_vedico.md:242 (frase 2) | Raman: "dangers", da evitare per le imprese importanti; Drik: Totally Bad. (Tara 7, Naidhana: la fine); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-069 | Con Naidhana, la settima tara, Raman sconsiglia le imprese importanti; il Drik Panchang la segna come il giorno meno adatto dei nove. | docs/corpus/oroscopo_vedico.md:243 (frase 3) | Raman: "dangers", da evitare per le imprese importanti; Drik: Totally Bad. (Tara 7, Naidhana: la fine); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 8, Mitra: l'amico** (nota del caso nel corpus: Raman: "good"; Drik: Good.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-070 | La stella di oggi, {nakshatra_oggi}, è per te Mitra, "l'amico": l'ottava contata dalla tua, che la tradizione indiana dà buona. | docs/corpus/oroscopo_vedico.md:248 (frase 1) | Raman: "good"; Drik: Good. (Tara 8, Mitra: l'amico); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-071 | Oggi hai Mitra, l'ottava delle nove tare: nella Tara Bala è la stella amica, che Raman e il Drik Panchang danno buona. | docs/corpus/oroscopo_vedico.md:249 (frase 2) | Raman: "good"; Drik: Good. (Tara 8, Mitra: l'amico); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-072 | Con Mitra, la stella dell'amico, la tradizione indiana vede un cielo amico: è l'ottava contata dalla tua stella di nascita. | docs/corpus/oroscopo_vedico.md:250 (frase 3) | Raman: "good"; Drik: Good. (Tara 8, Mitra: l'amico); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 2. Tara 9, Parama Mitra: il grande amico** (nota del caso nel corpus: Raman: "very favourable"; Drik: Good.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-073 | La stella di oggi, {nakshatra_oggi}, è per te Parama Mitra, "il grande amico": per Raman è la più favorevole delle nove. | docs/corpus/oroscopo_vedico.md:255 (frase 1) | Raman: "very favourable"; Drik: Good. (Tara 9, Parama Mitra: il grande amico); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-074 | Oggi hai Parama Mitra, la nona contata dalla tua stella di nascita: nella Tara Bala il cielo ti è amico fino in fondo. | docs/corpus/oroscopo_vedico.md:256 (frase 2) | Raman: "very favourable"; Drik: Good. (Tara 9, Parama Mitra: il grande amico); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |
| V-G-075 | Con Parama Mitra, la nona e ultima tara, la tradizione indiana dà la giornata per propizia: Raman la dice molto favorevole. | docs/corpus/oroscopo_vedico.md:257 (frase 3) | Raman: "very favourable"; Drik: Good. (Tara 9, Parama Mitra: il grande amico); B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | caso | fonte dichiarata |  |

**Corpus vedico, 3. Una riga per ogni giorno**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-076 | Oggi è Ravivara, il giorno del Sole. Il suo colore è il rosso, il suo numero l'uno. | docs/corpus/oroscopo_vedico.md:270 (frase Domenica) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | caso | fonte dichiarata |  |
| V-G-077 | Oggi è Somavara, il giorno della Luna. Il suo colore è il bianco, il suo numero il due. | docs/corpus/oroscopo_vedico.md:271 (frase Lunedì) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | caso | fonte dichiarata |  |
| V-G-078 | Oggi è Mangalavara, il giorno di Marte. Il suo colore è il rosso, il suo numero il nove. | docs/corpus/oroscopo_vedico.md:272 (frase Martedì) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | caso | fonte dichiarata |  |
| V-G-079 | Oggi è Budhavara, il giorno di Mercurio. Il suo colore è il verde, il suo numero il cinque. | docs/corpus/oroscopo_vedico.md:273 (frase Mercoledì) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | caso | fonte dichiarata |  |
| V-G-080 | Oggi è Guruvara, il giorno di Giove. Il suo colore è il giallo, il suo numero il tre. | docs/corpus/oroscopo_vedico.md:274 (frase Giovedì) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | caso | fonte dichiarata |  |
| V-G-081 | Oggi è Shukravara, il giorno di Venere. Il suo colore è lo screziato, il suo numero il sei. | docs/corpus/oroscopo_vedico.md:275 (frase Venerdì) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | caso | fonte dichiarata |  |
| V-G-082 | Oggi è Shanivara, il giorno di Saturno. Il suo colore è il nero, il suo numero l'otto. | docs/corpus/oroscopo_vedico.md:276 (frase Sabato) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | caso | fonte dichiarata |  |

**Corpus vedico, 3. Varianti generiche della stessa riga**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-083 | Oggi governa {pianeta}: nella settimana indiana ogni giorno ha il suo pianeta, che dà alla giornata un colore e un numero. | docs/corpus/oroscopo_vedico.md:283 (frase 1) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | regola | fonte dichiarata |  |
| V-G-084 | Il giorno è di {pianeta}: nella settimana indiana il colore e il numero di oggi sono i suoi. | docs/corpus/oroscopo_vedico.md:284 (frase 2) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | regola | fonte dichiarata |  |
| V-G-085 | Nella settimana indiana oggi è il giorno di {pianeta}, che ha un colore e un numero suoi. | docs/corpus/oroscopo_vedico.md:285 (frase 3) | colori: Varahamihira, Brihat Jataka 2.5; numeri: numerologia indiana moderna, Cheiro 1926 (corpus, sezione 3, righe 263-266) | regola | fonte dichiarata |  |

**Corpus vedico, 4. La Luna nella settima (h = 7)** (nota del caso nel corpus: Chandra Bala favorevole; la Luna attraversa la casa dell'unione.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-086 | Oggi la Luna attraversa la settima casa dalla tua Luna di nascita, quella dell'unione: per la tradizione indiana è un passaggio favorevole. | docs/corpus/oroscopo_vedico.md:300 (frase 1) | BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291); Chandra Bala favorevole: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-087 | La Luna è nella settima casa contata dalla tua Luna di nascita, che i testi indiani chiamano la casa del legame e del coniuge. | docs/corpus/oroscopo_vedico.md:301 (frase 2) | BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291); Chandra Bala favorevole: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |
| V-G-088 | Con la Luna nella settima casa, quella dell'unione, la tradizione indiana vede rispetto e felicità condivisa: è una Chandra Bala favorevole. | docs/corpus/oroscopo_vedico.md:302 (frase 3) | BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291); Chandra Bala favorevole: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | caso | fonte dichiarata |  |

**Corpus vedico, 4. La Luna nella quinta (h = 5)** (nota del caso nel corpus: Casa del cuore, ma la Chandra Bala è di attenzione: emozioni forti e un po' di stanchezza.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-089 | Oggi la Luna passa sulla quinta casa dalla tua Luna di nascita, letta qui come quella del cuore; la Chandra Bala però è di attenzione. | docs/corpus/oroscopo_vedico.md:309 (frase 1) | nessuna per ciò che la frase afferma | nessuna | **SENZA FONTE** | la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere); la sola Chandra Bala di attenzione ha fonte (Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76)) |
| V-G-090 | La Luna è nella quinta casa contata dalla tua Luna di nascita, la casa dei sentimenti, in un giorno che la tradizione indiana dà per faticoso. | docs/corpus/oroscopo_vedico.md:310 (frase 2) | nessuna per ciò che la frase afferma | nessuna | **SENZA FONTE** | la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere); la sola Chandra Bala di attenzione ha fonte (Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76)) |
| V-G-091 | Con la Luna in quinta casa, letta come il cuore che si apre, la Chandra Bala è di attenzione: emozioni forti e un po' di stanchezza. | docs/corpus/oroscopo_vedico.md:311 (frase 3) | nessuna per ciò che la frase afferma | nessuna | **SENZA FONTE** | la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere); la sola Chandra Bala di attenzione ha fonte (Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76)) |

**Corpus vedico, 4. La Luna nel tuo segno guarda la settima (h = 1)** (nota del caso nel corpus: La Luna guarda per intero la settima casa da sé (BPHS 26.2-5).)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-092 | Oggi la Luna è nel tuo segno di nascita e da lì guarda dritta la settima casa, quella dell'unione: nei testi indiani la Luna guarda per intero la settima da sé. | docs/corpus/oroscopo_vedico.md:317 (frase 1) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | caso | fonte dichiarata |  |
| V-G-093 | La Luna sta nel tuo segno di nascita e guarda la tua settima casa, la casa del legame (BPHS 26.2-5). | docs/corpus/oroscopo_vedico.md:318 (frase 2) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | caso | fonte dichiarata |  |
| V-G-094 | Con la Luna nel tuo segno di nascita il suo sguardo cade sulla settima casa, quella dell'altro: per la tradizione indiana l'attenzione altrui ti cerca. | docs/corpus/oroscopo_vedico.md:319 (frase 3) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | caso | fonte dichiarata |  |

**Corpus vedico, 4. La Luna nell'undicesima guarda la quinta (h = 11)** (nota del caso nel corpus: La Luna in una casa favorevole guarda la casa del cuore.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-095 | Oggi la Luna sta nell'undicesima casa dalla tua Luna di nascita, quella delle amicizie: da lì guarda la quinta, la casa del cuore. | docs/corpus/oroscopo_vedico.md:325 (frase 1) | nessuna per ciò che la frase afferma | nessuna | **SENZA FONTE** | la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere); lo sguardo dalla settima ha fonte (BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314)) |
| V-G-096 | La Luna guarda la tua quinta casa, letta come il cuore che si apre, da un posto favorevole della Chandra Bala. | docs/corpus/oroscopo_vedico.md:326 (frase 2) | nessuna per ciò che la frase afferma | nessuna | **SENZA FONTE** | la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere); lo sguardo dalla settima ha fonte (BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314)) |
| V-G-097 | Con la Luna nell'undicesima casa la tradizione indiana vede gioia; da lì il suo sguardo arriva sulla quinta, la casa del cuore. | docs/corpus/oroscopo_vedico.md:327 (frase 3) | nessuna per ciò che la frase afferma | nessuna | **SENZA FONTE** | la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere); lo sguardo dalla settima ha fonte (BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314)) |

**Corpus vedico, 4. Favorevole (h = 3, 6, 10)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-098 | Oggi la Luna non tocca le case dell'amore, la settima e la quinta, ma sta in un posto favorevole della Chandra Bala. | docs/corpus/oroscopo_vedico.md:332 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata | nomina la quinta fra le case dell'amore: la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere) |
| V-G-099 | La Luna transita in una casa favorevole contata dalla tua Luna di nascita, lontana dalla settima e dalla quinta che parlano d'amore. | docs/corpus/oroscopo_vedico.md:333 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata | nomina la quinta fra le case dell'amore: la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere) |
| V-G-100 | La Chandra Bala di oggi è favorevole: la Luna sostiene la giornata senza passare sulle case dell'unione e del cuore. | docs/corpus/oroscopo_vedico.md:334 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata | nomina la quinta fra le case dell'amore: la quinta come casa del cuore è dichiarata "lettura moderna" dal corpus (righe 291-293: nel BPHS 11.6 è la casa dei figli e del sapere) |

**Corpus vedico, 4. Di attenzione (h = 2, 9)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-101 | Oggi la Luna sta in una casa che la tradizione indiana chiede di trattare con cura: la Chandra Bala è di attenzione. | docs/corpus/oroscopo_vedico.md:339 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata |  |
| V-G-102 | La Luna transita in una delle case che la Chandra Bala dà di attenzione, contate dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:340 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata |  |
| V-G-103 | Il cielo di oggi non favorisce i chiarimenti: la Luna è in una casa di attenzione rispetto alla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:341 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata |  |

**Corpus vedico, 4. Sfavorevole (h = 4, 12)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-104 | Oggi la Luna è in una casa sfavorevole contata dalla tua Luna di nascita, una delle tre che la Chandra Bala sconsiglia. | docs/corpus/oroscopo_vedico.md:346 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata |  |
| V-G-105 | La Luna passa in una casa che la tradizione indiana dà per sfavorevole nel conto della Chandra Bala, fatto dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:347 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata |  |
| V-G-106 | Il cielo di oggi appesantisce: la Luna sta in una casa sfavorevole rispetto alla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:348 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.8, la settima "Wife" (corpus, sezione 4, riga 291) | regola | fonte dichiarata |  |

**Corpus vedico, 4. Chandrashtama, la Luna in ottava (h = 8)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-107 | Oggi è il tuo giorno di Chandrashtama: la Luna passa nell'ottava casa dalla tua Luna di nascita, il momento più delicato del suo giro. | docs/corpus/oroscopo_vedico.md:353 (frase 1) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144) | caso | fonte dichiarata |  |
| V-G-108 | Con la Luna nell'ottava casa dalla tua Luna di nascita, che in India ha il nome di Chandrashtama, la tradizione indiana consiglia calma. | docs/corpus/oroscopo_vedico.md:354 (frase 2) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144) | caso | fonte dichiarata |  |
| V-G-109 | La Luna è in ottava rispetto alla tua Luna di nascita: è Chandrashtama, un giorno che la tradizione indiana chiede di non forzare. | docs/corpus/oroscopo_vedico.md:355 (frase 3) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144) | caso | fonte dichiarata |  |

**Corpus vedico, 5. La Luna nella decima (h = 10)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-110 | Oggi la Luna attraversa la decima casa dalla tua Luna di nascita, quella della professione e dell'autorità. | docs/corpus/oroscopo_vedico.md:368 (frase 1) | BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | caso | fonte dichiarata |  |
| V-G-111 | La Luna è nella casa della professione: con la Luna in decima la Brihat Samhita dice che gli ordini saranno eseguiti, con successo nel lavoro. | docs/corpus/oroscopo_vedico.md:369 (frase 2) | BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | caso | fonte dichiarata |  |
| V-G-112 | Con la Luna in decima casa, quella che i testi indiani legano alla professione e all'onore, il lavoro viene in luce. | docs/corpus/oroscopo_vedico.md:370 (frase 3) | BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | caso | fonte dichiarata |  |

**Corpus vedico, 5. La Luna nella quarta guarda la decima (h = 4)** (nota del caso nel corpus: La Luna guarda la casa del lavoro da una casa sfavorevole.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-113 | Oggi la Luna guarda la decima casa, quella del lavoro, dalla quarta, la casa delle radici: una posizione che la Chandra Bala dà per sfavorevole. | docs/corpus/oroscopo_vedico.md:376 (frase 1) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363); Chandra Bala sfavorevole: Brihat Samhita 104.8, Phaladeepika 26.12 (sezione 1, casa 4) | caso | fonte dichiarata | lo sguardo dalla quarta alla decima applica la regola dello sguardo della sezione 4 |
| V-G-114 | La Luna tiene lo sguardo sulla casa del lavoro, ma da un posto inquieto: la quarta casa dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:377 (frase 2) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363); Chandra Bala sfavorevole: Brihat Samhita 104.8, Phaladeepika 26.12 (sezione 1, casa 4) | caso | fonte dichiarata | lo sguardo dalla quarta alla decima applica la regola dello sguardo della sezione 4 |
| V-G-115 | Con la Luna in quarta casa lo sguardo cade sulla decima, la casa della professione, ma la posizione è fra quelle sfavorevoli della Chandra Bala. | docs/corpus/oroscopo_vedico.md:378 (frase 3) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363); Chandra Bala sfavorevole: Brihat Samhita 104.8, Phaladeepika 26.12 (sezione 1, casa 4) | caso | fonte dichiarata | lo sguardo dalla quarta alla decima applica la regola dello sguardo della sezione 4 |

**Corpus vedico, 5. Favorevole (h = 1, 3, 6, 7, 11)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-116 | Per il lavoro il cielo di oggi è buono: la Luna transita in una casa favorevole contata dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:383 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |
| V-G-117 | La Luna sta in un posto favorevole della Chandra Bala, la forza della Luna contata dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:384 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |
| V-G-118 | La Luna di oggi è in una delle case favorevoli rispetto alla tua Luna di nascita, anche se non tocca la decima, quella della professione. | docs/corpus/oroscopo_vedico.md:385 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |

**Corpus vedico, 5. Di attenzione (h = 2, 5, 9)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-119 | La Luna transita in una casa che la Chandra Bala dà di attenzione, contata dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:390 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |
| V-G-120 | Il cielo di oggi chiede cura: la Luna è in una posizione di attenzione rispetto alla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:391 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |
| V-G-121 | Nella Chandra Bala la Luna di oggi cade in una delle tre case di attenzione, quelle da trattare con prudenza. | docs/corpus/oroscopo_vedico.md:392 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |

**Corpus vedico, 5. Sfavorevole (h = 12)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-122 | Oggi la Luna è nella dodicesima casa dalla tua Luna di nascita, quella delle uscite: una posizione sfavorevole della Chandra Bala. | docs/corpus/oroscopo_vedico.md:397 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |
| V-G-123 | La Luna in dodicesima casa, per la tradizione indiana, porta stanchezza: è una delle posizioni sfavorevoli nel conto dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:398 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |
| V-G-124 | Il cielo di oggi disperde: la Luna sta nella casa delle uscite, la dodicesima dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:399 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | regola | fonte dichiarata |  |

**Corpus vedico, 5. Chandrashtama, la Luna in ottava (h = 8)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-125 | Oggi è Chandrashtama, la Luna nell'ottava casa dalla tua Luna di nascita: la tradizione indiana sconsiglia di firmare contratti o cambiare lavoro. | docs/corpus/oroscopo_vedico.md:404 (frase 1) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | caso | fonte dichiarata |  |
| V-G-126 | Con la Luna nell'ottava casa dalla tua Luna di nascita la tradizione indiana mette il giorno fra quelli da non forzare. | docs/corpus/oroscopo_vedico.md:405 (frase 2) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | caso | fonte dichiarata |  |
| V-G-127 | La Luna è in ottava dalla tua Luna di nascita: in India questo giorno si chiama Chandrashtama e si dedica alla calma. | docs/corpus/oroscopo_vedico.md:406 (frase 3) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144); BPHS 11.11, la decima; Brihat Samhita 104.10 (corpus, sezione 5, righe 361-363) | caso | fonte dichiarata |  |

**Corpus vedico, 6. La Luna nella seconda (h = 2)** (nota del caso nel corpus: Casa dei beni, ma la Chandra Bala è di attenzione.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-128 | Oggi la Luna passa sulla seconda casa dalla tua Luna di nascita, quella dei beni, ma la Chandra Bala di questa posizione è di attenzione. | docs/corpus/oroscopo_vedico.md:420 (frase 1) | BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Chandra Bala di attenzione: Brihat Samhita 104.8, Phaladeepika 26.12 (sezione 1, casa 2) | caso | fonte dichiarata |  |
| V-G-129 | La Luna è nella seconda casa contata dalla tua Luna di nascita, che i testi indiani legano ai beni, al cibo e alla famiglia. | docs/corpus/oroscopo_vedico.md:421 (frase 2) | BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Chandra Bala di attenzione: Brihat Samhita 104.8, Phaladeepika 26.12 (sezione 1, casa 2) | caso | fonte dichiarata |  |
| V-G-130 | Con la Luna in seconda casa, la casa dei beni, la tradizione indiana invita a custodire: i testi parlano di beni che scivolano via. | docs/corpus/oroscopo_vedico.md:422 (frase 3) | BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Chandra Bala di attenzione: Brihat Samhita 104.8, Phaladeepika 26.12 (sezione 1, casa 2) | caso | fonte dichiarata |  |

**Corpus vedico, 6. La Luna nell'undicesima (h = 11)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-131 | Oggi la Luna attraversa l'undicesima casa dalla tua Luna di nascita, quella dei guadagni: per la tradizione indiana è un giorno di frutti. | docs/corpus/oroscopo_vedico.md:427 (frase 1) | BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Brihat Samhita 104.10 (sezione 1, casa 11) | caso | fonte dichiarata |  |
| V-G-132 | La Luna è nell'undicesima casa contata dalla tua Luna di nascita, che i testi indiani legano alle entrate e alla prosperità. | docs/corpus/oroscopo_vedico.md:428 (frase 2) | BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Brihat Samhita 104.10 (sezione 1, casa 11) | caso | fonte dichiarata |  |
| V-G-133 | Con la Luna nella casa dei guadagni, l'undicesima, la Brihat Samhita parla di prosperità e di amicizie nuove. | docs/corpus/oroscopo_vedico.md:429 (frase 3) | BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Brihat Samhita 104.10 (sezione 1, casa 11) | caso | fonte dichiarata |  |

**Corpus vedico, 6. La Luna nella quinta guarda l'undicesima (h = 5)** (nota del caso nel corpus: La Luna guarda la casa dei guadagni da una casa di attenzione.)

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-134 | Oggi la Luna guarda l'undicesima casa, quella dei guadagni, dalla quinta: un posto che la tradizione indiana dà per faticoso. | docs/corpus/oroscopo_vedico.md:435 (frase 1) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Chandra Bala di attenzione: Brihat Samhita 104.9, Phaladeepika 26.12 (sezione 1, casa 5) | caso | fonte dichiarata |  |
| V-G-135 | La Luna tiene d'occhio la tua casa dei guadagni dalla quinta casa, una posizione di attenzione nel conto dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:436 (frase 2) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Chandra Bala di attenzione: Brihat Samhita 104.9, Phaladeepika 26.12 (sezione 1, casa 5) | caso | fonte dichiarata |  |
| V-G-136 | Con la Luna in quinta casa lo sguardo arriva sulla casa dei guadagni, ma da una posizione che la Chandra Bala dà di attenzione. | docs/corpus/oroscopo_vedico.md:437 (frase 3) | BPHS 26.2-5, la Luna guarda per intero la settima da sé (corpus 4, riga 314); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414); Chandra Bala di attenzione: Brihat Samhita 104.9, Phaladeepika 26.12 (sezione 1, casa 5) | caso | fonte dichiarata |  |

**Corpus vedico, 6. Favorevole (h = 1, 3, 6, 7, 10)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-137 | Per la fortuna il cielo di oggi è buono: la Luna transita in una casa favorevole contata dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:442 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |
| V-G-138 | La Luna sta in un posto favorevole rispetto alla tua Luna di nascita, pur senza toccare le case dei beni e dei guadagni. | docs/corpus/oroscopo_vedico.md:443 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |
| V-G-139 | Nella Chandra Bala la Luna di oggi cade in una delle case favorevoli, quelle che la tradizione indiana dà per propizie. | docs/corpus/oroscopo_vedico.md:444 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |

**Corpus vedico, 6. Di attenzione (h = 9)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-140 | Oggi la Luna è nella nona casa dalla tua Luna di nascita, una posizione che la Chandra Bala dà di attenzione. | docs/corpus/oroscopo_vedico.md:449 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |
| V-G-141 | Il cielo di oggi non ama le spese impulsive: con la Luna in nona casa la tradizione indiana parla di impedimenti. | docs/corpus/oroscopo_vedico.md:450 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |
| V-G-142 | La Luna in nona casa rende il giorno un po' stretto per la tradizione indiana: è una delle posizioni di attenzione della Chandra Bala. | docs/corpus/oroscopo_vedico.md:451 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |

**Corpus vedico, 6. Sfavorevole (h = 4, 12)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-143 | Oggi la Luna è in una casa sfavorevole per i beni, contata dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:456 (frase 1) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |
| V-G-144 | La Luna transita in una delle case che la Chandra Bala dà per sfavorevoli, contate dalla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:457 (frase 2) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |
| V-G-145 | Il cielo di oggi fa uscire più di quanto entra: la Luna sta in una posizione sfavorevole rispetto alla tua Luna di nascita. | docs/corpus/oroscopo_vedico.md:458 (frase 3) | Chandra Bala: Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | regola | fonte dichiarata |  |

**Corpus vedico, 6. Chandrashtama, la Luna in ottava (h = 8)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-146 | Oggi è Chandrashtama, la Luna nell'ottava casa dalla tua Luna di nascita: la tradizione indiana sconsiglia investimenti e prestiti. | docs/corpus/oroscopo_vedico.md:463 (frase 1) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | caso | fonte dichiarata |  |
| V-G-147 | Con la Luna in ottava dalla tua Luna di nascita la tradizione indiana dedica il giorno alla calma, senza decisioni grandi. | docs/corpus/oroscopo_vedico.md:464 (frase 2) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | caso | fonte dichiarata |  |
| V-G-148 | La Luna è nell'ottava casa rispetto alla tua Luna di nascita: è il giorno che in India chiamano Chandrashtama, il più delicato del suo giro. | docs/corpus/oroscopo_vedico.md:465 (frase 3) | Brihat Samhita 104.9; Phaladeepika 26.12; Raman, Muhurtha cap. III (sezione 1, casa 8, righe 142-144); BPHS 11.3, la seconda; BPHS 11.12, l'undicesima (corpus, sezione 6, righe 412-414) | caso | fonte dichiarata |  |

**Corpus vedico, 7. Il Rahu Kalam deve ancora venire**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-149 | È il Rahu Kalam, l'ora e mezza circa che la tradizione indiana lascia a Rahu. | docs/corpus/oroscopo_vedico.md:481 (frase 1) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-150 | È il Rahu Kalam di oggi: nella tradizione indiana in quel tempo si evita di cominciare, non di continuare. | docs/corpus/oroscopo_vedico.md:482 (frase 2) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-151 | È il Rahu Kalam, un'ora e mezza circa che in India si lascia passare: è il tempo di Rahu, che la tradizione indiana considera un pianeta d'ombra. | docs/corpus/oroscopo_vedico.md:483 (frase 3) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-152 | Fra le {inizio} e le {fine} oggi cade il Rahu Kalam, l'ora e mezza che la tradizione indiana lascia a Rahu. | docs/corpus/oroscopo_vedico.md:484 (frase 4) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |

**Corpus vedico, 7. Il Rahu Kalam è in corso**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-153 | Adesso è Rahu Kalam, l'ora e mezza che la tradizione indiana lascia a Rahu: finisce alle {fine}. | docs/corpus/oroscopo_vedico.md:488 (frase 1) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-154 | Siamo dentro il Rahu Kalam di oggi: nella tradizione indiana in queste ore si evita di cominciare, non di continuare. | docs/corpus/oroscopo_vedico.md:489 (frase 2) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-155 | Fino alle {fine} è Rahu Kalam, l'ora e mezza in cui la tradizione indiana evita di dare inizio alle cose. | docs/corpus/oroscopo_vedico.md:490 (frase 3) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |

**Corpus vedico, 7. Il Rahu Kalam è già passato**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-156 | Era il Rahu Kalam di oggi, l'ora e mezza che la tradizione indiana lascia a Rahu. | docs/corpus/oroscopo_vedico.md:494 (frase 1) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-157 | Oggi il Rahu Kalam è stato fra le {inizio} e le {fine}: è il tempo che la tradizione indiana lascia a Rahu. | docs/corpus/oroscopo_vedico.md:495 (frase 2) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-158 | Il momento di Rahu è alle spalle: il Rahu Kalam di oggi era fra le {inizio} e le {fine}. | docs/corpus/oroscopo_vedico.md:496 (frase 3) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |

**Corpus vedico, 7. Manca la città**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-G-159 | È il Rahu Kalam: dipende dall'alba e dal tramonto del luogo in cui sei. | docs/corpus/oroscopo_vedico.md:500 (frase 1) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-160 | È il Rahu Kalam, un ottavo del tempo fra l'alba e il tramonto: per questo cambia da un luogo all'altro. | docs/corpus/oroscopo_vedico.md:501 (frase 2) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |
| V-G-161 | È il Rahu Kalam, l'ora e mezza che la tradizione indiana lascia a Rahu. | docs/corpus/oroscopo_vedico.md:502 (frase 3) | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario, non un testo; la regola "si evita di cominciare, non di continuare" (riga 472) sta nella stessa sezione |

### Settimana e Mese

Ogni giorno del periodo è la scheda del Giorno di quella data (`la_settimana_del_cielo.dart:534-593`): il "Da dove viene" del periodo riporta quello del giorno migliore. Non c'è riquadro del cielo.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-S-001 | Da dove viene: il giorno migliore, {giorno}: {la riga "Da dove viene" della scheda del Giorno vedico di quel giorno} | lib/core/horoscope/la_settimana_del_cielo.dart:583-584; lib/features/horoscope/il_periodo_view.dart:184-185 | nessuna per la cornice | nessuna | **SENZA FONTE** | la scelta del giorno migliore (il livello più alto, a parità il primo) è dell'app; le frasi riportate dopo i due punti sono quelle del Giorno, con lo stato scritto alle loro righe |
| V-S-002 | Da dove viene: {la riga "Da dove viene" del Giorno di quella data, con la prima lettera minuscola} (uno dei tre giorni migliori, nella Lunga) | lib/features/horoscope/il_periodo_view.dart:175, 246 | nessuna per la cornice | nessuna | **SENZA FONTE** | come sopra |

### Anno

La riga "Da dove viene" dell'Anno vedico (`l_anno_delle_tradizioni.dart:173-194`): Generale Giove e Saturno, Amore Giove (e Saturno se è la Sade Sati), Lavoro Saturno, Fortuna Giove.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-A-001 | Al tuo compleanno del {data} Giove era in {rashi}, nella tua {ordinale} casa dalla Luna di nascita: una casa favorevole. | lib/core/horoscope/l_anno_delle_tradizioni.dart:173-175 | Phaladeepika, cap. 26: Giove favorevole in 2, 5, 7, 9 e 11 (commento righe 58-60 e 146-147) | caso | fonte dichiarata | il capitolo è dato senza verso |
| V-A-002 | Al tuo compleanno del {data} Giove era in {rashi}, nella tua {ordinale} casa dalla Luna di nascita: non una delle sue case favorevoli. | lib/core/horoscope/l_anno_delle_tradizioni.dart:173-175 | Phaladeepika, cap. 26 (commento righe 58-60) | caso | fonte dichiarata |  |
| V-A-003 | Saturno era in {rashi}, nella tua {ordinale} casa dalla Luna di nascita: una casa favorevole. | lib/core/horoscope/l_anno_delle_tradizioni.dart:176-178 | Phaladeepika, cap. 26: Saturno favorevole in 3, 6 e 11 (commento righe 58-60 e 148) | caso | fonte dichiarata |  |
| V-A-004 | Saturno era in {rashi}, nella tua {ordinale} casa dalla Luna di nascita: non una delle sue case favorevoli. | lib/core/horoscope/l_anno_delle_tradizioni.dart:176-178 | Phaladeepika, cap. 26 (commento righe 58-60) | caso | fonte dichiarata |  |
| V-A-005 | Saturno era in {rashi}, nella tua {ordinale} casa dalla Luna di nascita: è la Sade Sati. | lib/core/horoscope/l_anno_delle_tradizioni.dart:176-178, 149 | nessuna: il commento (righe 60-62) dice "la tradizione la legge come sette anni e mezzo di prova" senza opera | nessuna | **SENZA FONTE** | abbassa l'Amore e la Generale (righe 183-187) |

### Note del metodo

Il Giorno: `_metodo` (`la_lettura_vedica.dart:541-557`), che prende tre voci del glossario del corpus (righe 514, 518, 524). L'Anno: `l_anno_delle_tradizioni.dart:195-200`.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| V-M-001 | La Luna di oggi è siderale, con l'ayanamsa di Lahiri, letta all'alba del luogo. | lib/core/horoscope/la_lettura_vedica.dart:545-546 | nessuna: il commento (righe 43-44) la dice "la convenzione del panchang" | nessuna | **SENZA FONTE** | Giorno, tutte le schede |
| V-M-002 | Chandra Bala: "forza della Luna", la casa in cui transita la Luna contata dalla Luna di nascita. | lib/core/horoscope/la_lettura_vedica.dart:546; docs/corpus/oroscopo_vedico.md:514 | Varahamihira, Brihat Samhita 104.4 e 104.8-10; Mantreshvara, Phaladeepika 26.2 e 26.12; Drik Panchang, Chandrabalam (corpus, sezione 1, righe 74-76) | regola | fonte dichiarata | voce del glossario |
| V-M-003 | Tara Bala: "forza della stella", il nakshatra di oggi contato da quello di nascita, a gruppi di nove. | lib/core/horoscope/la_lettura_vedica.dart:548; docs/corpus/oroscopo_vedico.md:518 | B. V. Raman, Muhurtha, cap. III; Drik Panchang, Tarabalam (corpus, sezione 2, righe 192-193) | regola | fonte dichiarata | Generale |
| V-M-004 | Senza l'ora di nascita la tua stella non si sa: la Tara Bala manca. | lib/core/horoscope/la_lettura_vedica.dart:549 | nessuna | nessuna | **SENZA FONTE** | avvertenza di calcolo |
| V-M-005 | Rahu Kalam: "il tempo di Rahu", un ottavo del giorno di luce da non usare per cominciare cose nuove. | lib/core/horoscope/la_lettura_vedica.dart:550; docs/corpus/oroscopo_vedico.md:524 | Drik Panchang, pagine "Rahu Kaal" e "Hindu Sunrise" (corpus, sezione 7, righe 475-477) | regola | fonte dichiarata | la fonte è un sito di calendario |
| V-M-006 | Si calcola dall'alba e dal tramonto del luogo, come Drik Panchang. | lib/core/horoscope/la_lettura_vedica.dart:550-551 | Drik Panchang, nella frase (pagine "Rahu Kaal" e "Hindu Sunrise", corpus righe 475-477) | caso | fonte dichiarata | la fonte è un sito di calendario |
| V-M-007 | Le case si contano dalla Luna di nascita (Phaladeepika 26.1); i significati sono quelli del Brihat Parashara Hora Shastra, cap. 11. | lib/core/horoscope/la_lettura_vedica.dart:552-554 | Phaladeepika 26.1; Brihat Parashara Hora Shastra, cap. 11, nella frase | caso | fonte dichiarata | Amore, Lavoro, Fortuna |
| V-M-008 | La quinta casa come cuore che si apre è una lettura moderna. | lib/core/horoscope/la_lettura_vedica.dart:554-555 | nessuna: la frase stessa la dichiara lettura moderna | nessuna | **SENZA FONTE** | Amore, Lavoro, Fortuna |
| V-M-009 | L'anno vedico va da compleanno a compleanno. | lib/core/horoscope/l_anno_delle_tradizioni.dart:195 | nessuna | nessuna | **SENZA FONTE** | Anno |
| V-M-010 | Giove e Saturno sono siderali, con l'ayanamsa di Lahiri, al tuo compleanno, e si contano dalla Luna di nascita (gochara): le case favorevoli sono quelle della Phaladeepika, cap. 26, Giove in 2, 5, 7, 9 e 11, Saturno in 3, 6 e 11. | lib/core/horoscope/l_anno_delle_tradizioni.dart:195-199 | Phaladeepika, cap. 26, nella frase | caso | fonte dichiarata | Anno; l'ayanamsa di Lahiri non ha fonte |
| V-M-011 | La Sade Sati è Saturno nella dodicesima, nella prima o nella seconda casa dalla Luna di nascita. | lib/core/horoscope/l_anno_delle_tradizioni.dart:199-200 | nessuna | nessuna | **SENZA FONTE** | Anno |

## Cinese

### Giorno

La riga "Da dove viene" della Generale: la frase del rapporto fra i due animali, quella del guardiano, nella Lunga quella del Dio della Gioia, e la riga del livello (`la_lettura_cinese.dart:125-132`). Amore, Lavoro e Fortuna: la frase del dio del giorno, nella Lunga la presentazione del dio e, nella Fortuna, la frase del Dio della Ricchezza, poi la riga del tema (`la_lettura_cinese.dart:186-191`). La Fortuna ha in fondo la riga del colore e dei numeri (riga 198). Prima le righe scritte nel codice, poi il corpus.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-001 | Il livello viene dal rapporto fra {l'animale del giorno} di oggi e {il tuo animale}: {rapporto}. | lib/core/horoscope/la_lettura_cinese.dart:129-131 | Sanming Tonghui: le tabelle del rapporto (commento righe 16-18; nota del metodo, lib/core/horoscope/oroscopo_cinese_data.dart:549-550) | regola | fonte dichiarata | Generale; i livelli da due a cinque (righe 389-406) sono una scelta dell'app, il commento rimanda alle specifiche |
| C-G-002 | {rapporto} = "armonia, una delle sei coppie" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | 三命通会: l'accordo è l'unione di yin e yang (regola 1.1, riga 40); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata | lo stesso caso del corpus 1.1 |
| C-G-003 | {rapporto} = "tripla armonia" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36), capitolo sulle tre armonie | caso | fonte dichiarata | lo stesso caso del corpus 1.2; la regola 1.2 (riga 49) non nomina opere: vale la fonte della sezione |
| C-G-004 | {rapporto} = "scontro, i due animali sono opposti" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | 黄历, gli almanacchi, senza titolo d'opera (regola 1.3, riga 60); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36), capitolo sugli scontri | caso | fonte dichiarata | lo stesso caso del corpus 1.3 |
| C-G-005 | {rapporto} = "punizione" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | 三命通会: punizione dell'ingratitudine, dell'arroganza, della scortesia (regola 1.4, riga 69); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata | lo stesso caso del corpus 1.4 |
| C-G-006 | {rapporto} = "punizione di sé" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | la regola 1.4 (riga 69) mette 辰, 午, 酉, 亥 fra i rami che puniscono se stessi, col 三命通会; 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata | lo stesso caso del corpus 1.5; la regola 1.5 (riga 78) non nomina opere |
| C-G-007 | {rapporto} = "danno" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | 三命通会: ognuno dei due rompe l'accordo dell'altro (regola 1.6, riga 87); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata | lo stesso caso del corpus 1.6 |
| C-G-008 | {rapporto} = "armonia che punisce" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | "i testi la chiamano 刑合", senza titolo (regola 1.7, riga 96); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | lo stesso caso del corpus 1.7; la coppia doppia non ha un capitolo suo nella fonte |
| C-G-009 | {rapporto} = "lo stesso animale" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | nessuna: la regola 1.8 (riga 105) dice "Nella tradizione i rami uguali si rafforzano (比)" senza opera, e che lo stesso animale "non è uno dei rapporti classificati" della fonte di sezione 1 | nessuna | **SENZA FONTE** | lo stesso caso del corpus 1.8 |
| C-G-010 | {rapporto} = "nessun rapporto nelle tabelle" | lib/core/horoscope/la_lettura_cinese.dart:377-387 | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | lo stesso caso del corpus 1.9; il caso è l'assenza dei rapporti classificati; la regola 1.9 (riga 114) non nomina opere |

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-011 | Il dio di oggi nel BaZi è il Compagno (比肩): il giorno ha il tuo stesso elemento con la tua stessa polarità. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:511-512 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-012 | Il dio di oggi nel BaZi è il Rivale (劫财): il tuo stesso elemento, con polarità opposta, cioè contende ciò che hai. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:513-514 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-013 | Il dio di oggi nel BaZi è il Nutrimento (食神): il tuo elemento lo genera, stessa polarità, cioè ciò che produci con calma. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:515-516 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-014 | Il dio di oggi nel BaZi è l'Ufficiale Ferito (伤官): il tuo elemento lo genera, polarità opposta, cioè espressione che rompe le regole. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:517-518 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-015 | Il dio di oggi nel BaZi è la Ricchezza indiretta (偏财): il tuo elemento lo governa, stessa polarità, cioè guadagni che arrivano di lato. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:519-520 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-016 | Il dio di oggi nel BaZi è la Ricchezza diretta (正财): il tuo elemento lo governa, polarità opposta, cioè il guadagno regolare. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:521-522 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-017 | Il dio di oggi nel BaZi sono le Sette Uccisioni (七杀): governa il tuo elemento, stessa polarità, cioè pressione, sfida. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:523-524 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-018 | Il dio di oggi nel BaZi è l'Ufficiale diretto (正官): governa il tuo elemento, polarità opposta, cioè regola, responsabilità, riconoscimento. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:525-526 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-019 | Il dio di oggi nel BaZi è il Sigillo indiretto (偏印): genera il tuo elemento, stessa polarità, cioè sostegno insolito, intuizione. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:527-528 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |
| C-G-020 | Il dio di oggi nel BaZi è il Sigillo diretto (正印): genera il tuo elemento, polarità opposta, cioè protezione, studio, cura. | lib/core/horoscope/la_lettura_cinese.dart:169-171; lib/core/horoscope/oroscopo_cinese_data.dart:529-530 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | caso | fonte dichiarata | presentazione del dio, nella Lunga di Amore, Lavoro e Fortuna; la spiegazione è la tabella del corpus, righe 239-248 |

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-021 | Per il denaro: divide la Ricchezza, in forma leggera. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: il Compagno; regole del corpus 3.1 (righe 252-319) |
| C-G-022 | Per il denaro: contende la Ricchezza. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: il Rivale; regole del corpus 3.1 (righe 252-319) |
| C-G-023 | Per il denaro: genera la Ricchezza. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: il Nutrimento; regole del corpus 3.1 (righe 252-319) |
| C-G-024 | Per il denaro: genera la Ricchezza, con impeto. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: l'Ufficiale Ferito; regole del corpus 3.1 (righe 252-319) |
| C-G-025 | Per il denaro: la Ricchezza è di turno. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: la Ricchezza indiretta; regole del corpus 3.1 (righe 252-319) |
| C-G-026 | Per il denaro: la Ricchezza è di turno. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: la Ricchezza diretta; regole del corpus 3.1 (righe 252-319) |
| C-G-027 | Per il denaro: la Ricchezza va verso obblighi e pressioni. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: le Sette Uccisioni; regole del corpus 3.1 (righe 252-319) |
| C-G-028 | Per il denaro: la Ricchezza va verso posizione e doveri. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: l'Ufficiale diretto; regole del corpus 3.1 (righe 252-319) |
| C-G-029 | Per il denaro: non tocca la Ricchezza. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: il Sigillo indiretto; regole del corpus 3.1 (righe 252-319) |
| C-G-030 | Per il denaro: non tocca la Ricchezza. | lib/core/horoscope/la_lettura_cinese.dart:190, 285, 434-445 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Fortuna, dio: il Sigillo diretto; regole del corpus 3.1 (righe 252-319) |
| C-G-031 | Per il lavoro: il tema è la rete dei pari. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: il Compagno; regole del corpus 3.2 (righe 326-389) |
| C-G-032 | Per il lavoro: il tema è la concorrenza fra pari. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: il Rivale; regole del corpus 3.2 (righe 326-389) |
| C-G-033 | Per il lavoro: doma l'Ufficiale. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: il Nutrimento; regole del corpus 3.2 (righe 326-389) |
| C-G-034 | Per il lavoro: ferisce l'Ufficiale. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: l'Ufficiale Ferito; regole del corpus 3.2 (righe 326-389) |
| C-G-035 | Per il lavoro: nutre l'Ufficiale. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: la Ricchezza indiretta; regole del corpus 3.2 (righe 326-389) |
| C-G-036 | Per il lavoro: nutre l'Ufficiale. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: la Ricchezza diretta; regole del corpus 3.2 (righe 326-389) |
| C-G-037 | Per il lavoro: l'Ufficiale è di turno, come pressione. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: le Sette Uccisioni; regole del corpus 3.2 (righe 326-389) |
| C-G-038 | Per il lavoro: l'Ufficiale è di turno. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: l'Ufficiale diretto; regole del corpus 3.2 (righe 326-389) |
| C-G-039 | Per il lavoro: trasforma l'Ufficiale in sostegno. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: il Sigillo indiretto; regole del corpus 3.2 (righe 326-389) |
| C-G-040 | Per il lavoro: trasforma l'Ufficiale in sostegno. | lib/core/horoscope/la_lettura_cinese.dart:190, 284, 446-457 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Lavoro, dio: il Sigillo diretto; regole del corpus 3.2 (righe 326-389) |
| C-G-041 | Per il legame: {relazione con la Ricchezza, come sopra}; per un uomo la Ricchezza è il legame. | lib/core/horoscope/la_lettura_cinese.dart:190, 283, 464-465 | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata | Amore, genere maschile |
| C-G-042 | Per il legame: {relazione con l'Ufficiale, come sopra}; per una donna l'Ufficiale è il legame. | lib/core/horoscope/la_lettura_cinese.dart:190, 283, 466-467 | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata | Amore, genere femminile |
| C-G-043 | Per il legame: {relazione con l'Ufficiale} e {relazione con la Ricchezza}. | lib/core/horoscope/la_lettura_cinese.dart:190, 283, 468 | nessuna: la serie neutra è "scelta dell'app, non della tradizione" (corpus 3.5, riga 535) | nessuna | **SENZA FONTE** | Amore, genere non dichiarato |
| C-G-044 | Il giorno è di {elemento}: il suo colore nella tradizione è il {colore}, i suoi numeri {numeri}. | docs/corpus/oroscopo_cinese.md:605; lib/core/horoscope/la_lettura_cinese.dart:174-175, 198 | 礼记·月令 per il colore; 河图 (He Tu) come lo dà il 周易·系辞上 per i numeri (corpus 4.1, riga 603) | caso | fonte dichiarata | riga del colore e dei numeri, in fondo alla Fortuna |
| C-G-045 | Elemento del giorno: {elemento}. Colore {colore}, numeri {numeri}, secondo la figura dello He Tu. | docs/corpus/oroscopo_cinese.md:606; lib/core/horoscope/la_lettura_cinese.dart:174-175, 198 | 礼记·月令 per il colore; 河图 (He Tu) come lo dà il 周易·系辞上 per i numeri (corpus 4.1, riga 603) | caso | fonte dichiarata | riga del colore e dei numeri, in fondo alla Fortuna |
| C-G-046 | Oggi governa {elemento}. Nella tradizione cinese gli appartengono il {colore} e i numeri {numeri}. | docs/corpus/oroscopo_cinese.md:607; lib/core/horoscope/la_lettura_cinese.dart:174-175, 198 | 礼记·月令 per il colore; 河图 (He Tu) come lo dà il 周易·系辞上 per i numeri (corpus 4.1, riga 603) | caso | fonte dichiarata | riga del colore e dei numeri, in fondo alla Fortuna |

**Corpus cinese, 1.1 Armonia (六合 Liu He)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-047 | Oggi è il giorno di {animale_giorno}, che nella tradizione cinese si accorda con {animale_tuo}: è una delle sei coppie in armonia. | docs/corpus/oroscopo_cinese.md:43 (frase 1) | 三命通会: l'accordo è l'unione di yin e yang (regola 1.1, riga 40); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |
| C-G-048 | Il giorno lo guida {animale_giorno}: il suo ramo e quello del tuo animale formano una delle sei armonie, due metà che si completano. | docs/corpus/oroscopo_cinese.md:44 (frase 2) | 三命通会: l'accordo è l'unione di yin e yang (regola 1.1, riga 40); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |
| C-G-049 | Il ramo di oggi e quello del tuo anno di nascita sono una coppia che la tradizione cinese chiama "accordo": è una giornata in armonia col tuo animale. | docs/corpus/oroscopo_cinese.md:45 (frase 3) | 三命通会: l'accordo è l'unione di yin e yang (regola 1.1, riga 40); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |

**Corpus cinese, 1.2 Tripla armonia (三合 San He)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-050 | Il ramo di {animale_giorno} e quello di {animale_tuo} appartengono alla stessa terna, il gruppo che la tradizione cinese lega a {elemento_terna}: un'intesa più larga di una coppia. | docs/corpus/oroscopo_cinese.md:52 (frase 1) | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36), capitolo sulle tre armonie | caso | fonte dichiarata | la regola 1.2 (riga 49) non nomina opere: vale la fonte della sezione |
| C-G-051 | Oggi guida {animale_giorno}, che sta nella stessa terna del tuo animale: nell'almanacco cinese le terne sono alleanze. | docs/corpus/oroscopo_cinese.md:53 (frase 2) | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36), capitolo sulle tre armonie | caso | fonte dichiarata | la regola 1.2 (riga 49) non nomina opere: vale la fonte della sezione |
| C-G-052 | Il giorno di {animale_giorno} è alleato del tuo anno: i vostri sono due dei tre rami che insieme fanno {elemento_terna}. | docs/corpus/oroscopo_cinese.md:54 (frase 3) | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36), capitolo sulle tre armonie | caso | fonte dichiarata | la regola 1.2 (riga 49) non nomina opere: vale la fonte della sezione |

**Corpus cinese, 1.3 Scontro (六冲 Chong)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-053 | Oggi è il giorno di {animale_giorno}, che sta di fronte al tuo animale: l'almanacco cinese lo chiama scontro. | docs/corpus/oroscopo_cinese.md:63 (frase 1) | 黄历, gli almanacchi, senza titolo d'opera (regola 1.3, riga 60); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36), capitolo sugli scontri | caso | fonte dichiarata |  |
| C-G-054 | Il ramo di oggi è l'opposto del tuo. Gli almanacchi cinesi lo scrivono in chiaro: oggi si scontra con {animale_tuo}. | docs/corpus/oroscopo_cinese.md:64 (frase 2) | 黄历, gli almanacchi, senza titolo d'opera (regola 1.3, riga 60); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36), capitolo sugli scontri | caso | fonte dichiarata |  |
| C-G-055 | È un giorno di scontro col tuo animale: nella tradizione cinese il ramo di oggi sta di fronte a quello del tuo anno. | docs/corpus/oroscopo_cinese.md:65 (frase 3) | 黄历, gli almanacchi, senza titolo d'opera (regola 1.3, riga 60); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36), capitolo sugli scontri | caso | fonte dichiarata |  |

**Corpus cinese, 1.4 Punizione (三刑 Xing)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-056 | Il ramo di oggi e il tuo sono legati da ciò che la tradizione cinese chiama punizione: non un castigo, un attrito che nasce da un eccesso. | docs/corpus/oroscopo_cinese.md:72 (frase 1) | 三命通会: punizione dell'ingratitudine, dell'arroganza, della scortesia (regola 1.4, riga 69); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |
| C-G-057 | Oggi {animale_giorno} e {animale_tuo} formano una delle tre punizioni, i gruppi di rami che nella tradizione cinese si puniscono a vicenda. | docs/corpus/oroscopo_cinese.md:73 (frase 2) | 三命通会: punizione dell'ingratitudine, dell'arroganza, della scortesia (regola 1.4, riga 69); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |
| C-G-058 | È una giornata di attrito col tuo animale, secondo l'almanacco cinese: il ramo di oggi e quello del tuo anno stanno in uno dei gruppi che si puniscono. | docs/corpus/oroscopo_cinese.md:74 (frase 3) | 三命通会: punizione dell'ingratitudine, dell'arroganza, della scortesia (regola 1.4, riga 69); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |

**Corpus cinese, 1.5 Punizione di sé (自刑)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-059 | Oggi è il giorno del tuo stesso animale: la tradizione cinese dice che {animale_tuo} con se stesso si punisce. | docs/corpus/oroscopo_cinese.md:81 (frase 1) | la regola 1.4 (riga 69) mette 辰, 午, 酉, 亥 fra i rami che puniscono se stessi, col 三命通会; 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata | la regola 1.5 (riga 78) non nomina opere |
| C-G-060 | È il giorno del tuo animale, nella forma che l'almanacco cinese chiama punizione di sé: Drago, Cavallo, Gallo e Maiale puniscono se stessi quando il giorno ha il loro ramo. | docs/corpus/oroscopo_cinese.md:82 (frase 2) | la regola 1.4 (riga 69) mette 辰, 午, 酉, 亥 fra i rami che puniscono se stessi, col 三命通会; 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata | la regola 1.5 (riga 78) non nomina opere |
| C-G-061 | Il ramo di oggi è il tuo. Per {animale_tuo} la tradizione cinese lo legge come un giorno in cui ci si inciampa da soli. | docs/corpus/oroscopo_cinese.md:83 (frase 3) | la regola 1.4 (riga 69) mette 辰, 午, 酉, 亥 fra i rami che puniscono se stessi, col 三命通会; 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata | la regola 1.5 (riga 78) non nomina opere |

**Corpus cinese, 1.6 Danno (六害 Hai)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-062 | Il giorno è di {animale_giorno}, che disturba l'accordo del tuo animale: la tradizione cinese lo chiama danno. | docs/corpus/oroscopo_cinese.md:90 (frase 1) | 三命通会: ognuno dei due rompe l'accordo dell'altro (regola 1.6, riga 87); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |
| C-G-063 | Il ramo di oggi e quello del tuo anno sono una delle sei coppie del danno: nella tradizione cinese ognuno dei due rompe l'accordo dell'altro. | docs/corpus/oroscopo_cinese.md:91 (frase 2) | 三命通会: ognuno dei due rompe l'accordo dell'altro (regola 1.6, riga 87); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |
| C-G-064 | È un giorno di danno per {animale_tuo}, dice l'almanacco cinese: il ramo di oggi e il suo stanno in una delle sei coppie che si danneggiano. | docs/corpus/oroscopo_cinese.md:92 (frase 3) | 三命通会: ognuno dei due rompe l'accordo dell'altro (regola 1.6, riga 87); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | caso | fonte dichiarata |  |

**Corpus cinese, 1.7 Armonia che punisce (巳申, Serpente e Scimmia)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-065 | Oggi {animale_giorno} e {animale_tuo} si accordano e si puniscono insieme: la tradizione cinese conosce questa coppia doppia e la chiama accordo con attrito. | docs/corpus/oroscopo_cinese.md:99 (frase 1) | "i testi la chiamano 刑合", senza titolo (regola 1.7, riga 96); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | la coppia doppia non ha un capitolo suo nella fonte |
| C-G-066 | È una coppia doppia: Serpente e Scimmia sono insieme una delle sei armonie e una delle punizioni, armonia e attrito nello stesso legame. | docs/corpus/oroscopo_cinese.md:100 (frase 2) | "i testi la chiamano 刑合", senza titolo (regola 1.7, riga 96); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | la coppia doppia non ha un capitolo suo nella fonte |
| C-G-067 | Il ramo di oggi e il tuo si cercano e si urtano: nei testi cinesi questa coppia è un accordo che porta con sé un attrito. | docs/corpus/oroscopo_cinese.md:101 (frase 3) | "i testi la chiamano 刑合", senza titolo (regola 1.7, riga 96); 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | la coppia doppia non ha un capitolo suo nella fonte |

**Corpus cinese, 1.8 Stesso animale**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-068 | Oggi è il giorno di {animale_giorno}, il tuo stesso animale: ritorna ogni dodici giorni. Nella tradizione cinese i rami uguali si rafforzano. | docs/corpus/oroscopo_cinese.md:108 (frase 1) | nessuna: la regola 1.8 (riga 105) dice "Nella tradizione i rami uguali si rafforzano (比)" senza opera, e che lo stesso animale "non è uno dei rapporti classificati" della fonte di sezione 1 | nessuna | **SENZA FONTE** |  |
| C-G-069 | Il ramo di oggi è il tuo: nella tradizione cinese due rami uguali stanno fianco a fianco e si rafforzano. | docs/corpus/oroscopo_cinese.md:109 (frase 2) | nessuna: la regola 1.8 (riga 105) dice "Nella tradizione i rami uguali si rafforzano (比)" senza opera, e che lo stesso animale "non è uno dei rapporti classificati" della fonte di sezione 1 | nessuna | **SENZA FONTE** |  |
| C-G-070 | È il giorno del tuo animale: la tradizione cinese non gli dà un peso particolare, perché non è uno dei rapporti classificati. | docs/corpus/oroscopo_cinese.md:110 (frase 3) | nessuna: la regola 1.8 (riga 105) dice "Nella tradizione i rami uguali si rafforzano (比)" senza opera, e che lo stesso animale "non è uno dei rapporti classificati" della fonte di sezione 1 | nessuna | **SENZA FONTE** |  |

**Corpus cinese, 1.9 Nessun rapporto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-071 | Oggi guida {animale_giorno}, che col tuo animale non ha legami nella tradizione cinese: né accordo né urto. Il giorno si legge meglio dal suo guardiano. | docs/corpus/oroscopo_cinese.md:117 (frase 1) | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | il caso è l'assenza dei rapporti classificati; la regola 1.9 (riga 114) non nomina opere |
| C-G-072 | Fra {animale_giorno} e {animale_tuo} oggi non c'è un rapporto classico: né accordo, né terna, né scontro, né punizione, né danno. | docs/corpus/oroscopo_cinese.md:118 (frase 2) | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | il caso è l'assenza dei rapporti classificati; la regola 1.9 (riga 114) non nomina opere |
| C-G-073 | Fra il ramo del giorno e quello del tuo anno non c'è nessun accordo e nessuno scontro: è il caso più frequente nelle tabelle della tradizione cinese. | docs/corpus/oroscopo_cinese.md:119 (frase 3) | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | il caso è l'assenza dei rapporti classificati; la regola 1.9 (riga 114) non nomina opere |
| C-G-074 | Il ramo di oggi e il tuo non si cercano e non si respingono: dal lato degli animali la giornata è libera e a parlare resta il guardiano del giorno. | docs/corpus/oroscopo_cinese.md:120 (frase 4) | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | il caso è l'assenza dei rapporti classificati; la regola 1.9 (riga 114) non nomina opere |
| C-G-075 | Oggi {animale_giorno} passa accanto al tuo animale senza toccarlo, dice la tradizione cinese: fra i due rami non c'è nessun legame. | docs/corpus/oroscopo_cinese.md:121 (frase 5) | 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | il caso è l'assenza dei rapporti classificati; la regola 1.9 (riga 114) non nomina opere |

**Corpus cinese, 2.1 Stabilire (建 Jian)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-076 | Il guardiano di oggi è Stabilire, il primo dei dodici: nel calendario cinese è il giorno in cui qualcosa si mette in piedi. | docs/corpus/oroscopo_cinese.md:135 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-077 | Oggi veglia Stabilire: la tradizione cinese lo vuole per gli inizi e per mettersi in viaggio, lo sconsiglia per i lavori di scavo. | docs/corpus/oroscopo_cinese.md:136 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-078 | Stabilire guida il giorno: fra i dodici guardiani è quello adatto a prendere un incarico, non ai grandi spostamenti di cose. | docs/corpus/oroscopo_cinese.md:137 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.2 Togliere (除 Chu)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-079 | Oggi il guardiano è Togliere: la tradizione cinese lo dedica a ciò che si porta via, dal pulire al curarsi al liberarsi del vecchio. | docs/corpus/oroscopo_cinese.md:143 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-080 | Togliere veglia sul giorno: è il guardiano che il calendario cinese lega al pulire e al liberarsi del vecchio. | docs/corpus/oroscopo_cinese.md:144 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-081 | È una giornata di Togliere, dice l'almanacco cinese: buona per curarsi e per liberarsi del vecchio, sconsigliata per partenze e traslochi. | docs/corpus/oroscopo_cinese.md:145 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.3 Pieno (满 Man)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-082 | Oggi veglia Pieno, il guardiano del raccolto: il calendario cinese lo lega alle celebrazioni e agli incontri di famiglia. | docs/corpus/oroscopo_cinese.md:151 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-083 | Il guardiano Pieno dice abbondanza: è adatto a cercare un guadagno, non a prendere un nuovo incarico. | docs/corpus/oroscopo_cinese.md:152 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-084 | È un giorno di Pieno: la tradizione cinese lo vuole per le celebrazioni e i guadagni, non per i traslochi né per i lavori di terra. | docs/corpus/oroscopo_cinese.md:153 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.4 Livellare (平 Ping)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-085 | Il guardiano di oggi è Livellare: nel calendario cinese è il giorno adatto a riparare, sistemare e abbellire. | docs/corpus/oroscopo_cinese.md:159 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-086 | Oggi veglia Livellare: la tradizione cinese lo vuole per sistemare e lo sconsiglia per ciò che chiama "scavare canali", cioè aprire strade nuove. | docs/corpus/oroscopo_cinese.md:160 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-087 | Livellare guida il giorno: fra i dodici guardiani è quello che vuole sistemare ciò che c'è, non aprire strade nuove. | docs/corpus/oroscopo_cinese.md:161 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.5 Fissare (定 Ding)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-088 | Oggi veglia Fissare: la tradizione cinese lo lega a ciò che deve restare, dai piani alle decisioni che devono durare. | docs/corpus/oroscopo_cinese.md:167 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-089 | Il guardiano Fissare chiede stabilità: l'almanacco cinese lo dà adatto alle decisioni che devono durare e sconsigliato per liti e cause. | docs/corpus/oroscopo_cinese.md:168 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-090 | È un giorno di Fissare: nel calendario cinese va bene per pianificare, mentre partenze e liti hanno giorni migliori. | docs/corpus/oroscopo_cinese.md:169 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.6 Tenere (执 Zhi)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-091 | Il guardiano di oggi è Tenere: la tradizione cinese lo vuole per trattenere, non per lasciare andare. | docs/corpus/oroscopo_cinese.md:175 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-092 | Oggi veglia Tenere: per compravendite e partenze l'almanacco cinese consiglia altri giorni. | docs/corpus/oroscopo_cinese.md:176 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-093 | Tenere guida il giorno: nel calendario cinese è adatto a costruire, piantare e portare a termine, non a commerciare. | docs/corpus/oroscopo_cinese.md:177 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.7 Rompere (破 Po)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-094 | Oggi il guardiano è Rompere, il più severo dei dodici: gli almanacchi cinesi sconsigliano di cominciare cose importanti. | docs/corpus/oroscopo_cinese.md:183 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-095 | Rompere veglia sul giorno: gli almanacchi cinesi ne scrivono "nessuna impresa conviene" e lo tengono buono per demolire il vecchio. | docs/corpus/oroscopo_cinese.md:184 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-096 | È un giorno di Rompere: la tradizione cinese lo vuole solo per demolire il vecchio e per cercare cure. | docs/corpus/oroscopo_cinese.md:185 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.8 Pericolo (危 Wei)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-097 | Il guardiano di oggi è Pericolo: la tradizione cinese chiede prudenza con l'altezza e con l'acqua, sconsiglia di salire in alto e di andare per mare. | docs/corpus/oroscopo_cinese.md:191 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-098 | Oggi veglia Pericolo: il calendario cinese lo dà adatto alle cerimonie e al raccoglimento, non ai traslochi. | docs/corpus/oroscopo_cinese.md:192 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-099 | Pericolo guida il giorno: fra i dodici guardiani è quello che vuole cautela, soprattutto dove si sale in alto. | docs/corpus/oroscopo_cinese.md:193 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.9 Compiere (成 Cheng)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-100 | Oggi veglia Compiere, uno dei guardiani più favorevoli: la tradizione cinese lo vuole per ciò che deve arrivare in fondo. | docs/corpus/oroscopo_cinese.md:199 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-101 | Il guardiano Compiere porta a termine: nel calendario cinese è adatto agli accordi, sconsigliato per liti e cause. | docs/corpus/oroscopo_cinese.md:200 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-102 | È un giorno di Compiere: accordi, partenze e inizi di coppia vanno bene secondo l'almanacco cinese, liti e cause no. | docs/corpus/oroscopo_cinese.md:201 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.10 Raccogliere (收 Shou)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-103 | Il guardiano di oggi è Raccogliere: la tradizione cinese lo lega al raccolto e ai frutti da incassare. | docs/corpus/oroscopo_cinese.md:207 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-104 | Oggi veglia Raccogliere: fra i dodici guardiani è quello adatto a incassare e a raccogliere i frutti. | docs/corpus/oroscopo_cinese.md:208 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-105 | Raccogliere guida il giorno: il calendario cinese lo dà buono per studiare e per mettere da parte, mentre le partenze le rimanda. | docs/corpus/oroscopo_cinese.md:209 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.11 Aprire (开 Kai)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-106 | Oggi veglia Aprire, il guardiano delle porte che si aprono: la tradizione cinese lo vuole per inaugurare, presentarsi, chiedere. | docs/corpus/oroscopo_cinese.md:215 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-107 | Il guardiano Aprire invita a farsi vedere: nel calendario cinese è il giorno adatto a chiedere e a cominciare. | docs/corpus/oroscopo_cinese.md:216 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-108 | È un giorno di Aprire: buono per gli inizi, secondo l'almanacco cinese, che lascia fuori solo i lavori di terra e i riti funebri. | docs/corpus/oroscopo_cinese.md:217 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 2.12 Chiudere (闭 Bi)**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-109 | Il guardiano di oggi è Chiudere: la tradizione cinese lo lega al riposo e a ciò che si mette al sicuro. | docs/corpus/oroscopo_cinese.md:223 (frase 1) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-110 | Oggi veglia Chiudere: l'almanacco cinese lo sconsiglia per le inaugurazioni e per cercare guadagni, lo vuole per mettere al sicuro. | docs/corpus/oroscopo_cinese.md:224 (frase 2) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |
| C-G-111 | Chiudere guida il giorno: l'almanacco cinese lo sconsiglia per aprire un'attività e per partire. | docs/corpus/oroscopo_cinese.md:225 (frase 3) | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | nessuna fonte propria del singolo guardiano |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 比肩, il Compagno**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-112 | Il dio di oggi nel BaZi è il Compagno: il giorno ha il tuo stesso elemento con la tua stessa polarità e divide con te ciò che c'è. | docs/corpus/oroscopo_cinese.md:257 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-113 | Il Compagno è di turno: nel BaZi chi ha il tuo stesso elemento contende la Ricchezza in forma leggera. Ciò che c'è si spartisce fra pari. | docs/corpus/oroscopo_cinese.md:258 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-114 | È la giornata del Compagno, il dio che ha il tuo stesso elemento: nel BaZi contende la Ricchezza, ma senza strappi. | docs/corpus/oroscopo_cinese.md:259 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 劫财, il Rivale**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-115 | Il dio di oggi nel BaZi è il Rivale, che la tradizione chiama "chi prende la ricchezza". | docs/corpus/oroscopo_cinese.md:264 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-116 | Il Rivale è di turno: ha il tuo stesso elemento con polarità opposta. Non annuncia un furto, dice che oggi il denaro tende a uscire. | docs/corpus/oroscopo_cinese.md:265 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-117 | È la giornata del Rivale, che nel BaZi contende ciò che hai: il suo nome cinese vuol dire alla lettera "rapina della ricchezza". | docs/corpus/oroscopo_cinese.md:266 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 食神, il Nutrimento**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-118 | Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera e lui a sua volta genera la Ricchezza. È la vena da cui nasce il guadagno. | docs/corpus/oroscopo_cinese.md:271 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-119 | Il Nutrimento è di turno: nel BaZi è ciò che produci con calma. La regola dice che genera la Ricchezza: il guadagno viene da ciò che sai fare. | docs/corpus/oroscopo_cinese.md:272 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-120 | È la giornata del Nutrimento: il tuo elemento lo genera con la stessa polarità. Nel BaZi alimenta la Ricchezza senza fretta. | docs/corpus/oroscopo_cinese.md:273 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 伤官, l'Ufficiale Ferito**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-121 | Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta. È talento che corre e genera la Ricchezza, ma con impeto. | docs/corpus/oroscopo_cinese.md:278 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-122 | L'Ufficiale Ferito è di turno: nel BaZi genera la Ricchezza come il Nutrimento, però è l'espressione che rompe le regole. | docs/corpus/oroscopo_cinese.md:279 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-123 | È la giornata dell'Ufficiale Ferito: nel BaZi la sua forza è creare ciò che porta guadagno, il suo rischio è l'impeto con cui lo fa. | docs/corpus/oroscopo_cinese.md:280 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 偏财, la Ricchezza indiretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-124 | Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. È il denaro delle occasioni, che arriva di lato. | docs/corpus/oroscopo_cinese.md:285 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-125 | La Ricchezza indiretta è di turno: nel BaZi è il denaro che circola, quello che non viene dal guadagno regolare. | docs/corpus/oroscopo_cinese.md:286 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-126 | È la giornata della Ricchezza indiretta: il tuo elemento la governa. Nel BaZi sono occasioni e denaro che circola, in entrata come in uscita. | docs/corpus/oroscopo_cinese.md:287 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 正财, la Ricchezza diretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-127 | Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. È il denaro guadagnato con metodo. | docs/corpus/oroscopo_cinese.md:292 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-128 | La Ricchezza diretta è di turno: nel BaZi è il guadagno regolare, frutto del lavoro, quello che non sorprende. | docs/corpus/oroscopo_cinese.md:293 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-129 | È la giornata della Ricchezza diretta: nel BaZi è ciò che il tuo elemento governa con le sue forze, il frutto che gli spetta. | docs/corpus/oroscopo_cinese.md:294 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 七杀, le Sette Uccisioni**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-130 | Il dio di oggi nel BaZi sono le Sette Uccisioni, la pressione: governano il tuo elemento. La regola dice che la Ricchezza le nutre, cioè va verso gli obblighi. | docs/corpus/oroscopo_cinese.md:299 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-131 | Le Sette Uccisioni sono di turno: nel BaZi governano il tuo elemento con la stessa polarità. La Ricchezza si consuma per farvi fronte. | docs/corpus/oroscopo_cinese.md:300 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-132 | È la giornata delle Sette Uccisioni: nel BaZi sono pressione e sfida. Sul denaro prendono la forma di richieste che vengono da fuori. | docs/corpus/oroscopo_cinese.md:301 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 正官, l'Ufficiale diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-133 | Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta. La Ricchezza lo nutre, quindi il denaro va verso posizione e doveri. | docs/corpus/oroscopo_cinese.md:306 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-134 | L'Ufficiale diretto è di turno: nel BaZi è regola, responsabilità, riconoscimento. La Ricchezza lo alimenta. | docs/corpus/oroscopo_cinese.md:307 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-135 | È la giornata dell'Ufficiale diretto: nella lettura dei Dieci Dei consuma la Ricchezza, che si spende per i doveri prima che per i desideri. | docs/corpus/oroscopo_cinese.md:308 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 偏印, il Sigillo indiretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-136 | Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità e non tocca la Ricchezza. Il suo sostegno ha una forma insolita. | docs/corpus/oroscopo_cinese.md:313 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-137 | Il Sigillo indiretto è di turno: nel BaZi è sostegno insolito e intuizione. Con la Ricchezza non ha legami, né per darla né per toglierla. | docs/corpus/oroscopo_cinese.md:314 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-138 | È la giornata del Sigillo indiretto: nella lettura dei Dieci Dei i Sigilli generano il tuo elemento e lasciano ferma la Ricchezza. | docs/corpus/oroscopo_cinese.md:315 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.1 Fortuna (guarda alla Ricchezza), 正印, il Sigillo diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-139 | Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta. Protegge più che arricchire. | docs/corpus/oroscopo_cinese.md:320 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-140 | Il Sigillo diretto è di turno: nel BaZi è protezione, studio, cura. Porta sostegno, non guadagno. | docs/corpus/oroscopo_cinese.md:321 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |
| C-G-141 | È la giornata del Sigillo diretto: nella lettura dei Dieci Dei i Sigilli non toccano la Ricchezza, la lasciano dov'è. | docs/corpus/oroscopo_cinese.md:322 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.1 (riga 252) e le regole dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 比肩, il Compagno**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-142 | Il dio di oggi nel BaZi è il Compagno: il giorno ha il tuo stesso elemento con la tua stessa polarità. Sul lavoro sono i pari grado, le persone come te. | docs/corpus/oroscopo_cinese.md:330 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-143 | Il Compagno è di turno: nel BaZi chi ha il tuo stesso elemento sta al tuo fianco, non sopra di te. Per il lavoro vuol dire collaborazione orizzontale. | docs/corpus/oroscopo_cinese.md:331 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-144 | È la giornata del Compagno: nella scheda del lavoro il BaZi guarda all'Ufficiale, l'autorità, mentre il Compagno porta il confronto fra pari. | docs/corpus/oroscopo_cinese.md:332 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 劫财, il Rivale**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-145 | Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta e contende ciò che hai. Sul lavoro è la concorrenza fra pari. | docs/corpus/oroscopo_cinese.md:336 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-146 | Il Rivale è di turno: nel BaZi ha il tuo stesso elemento, quindi ti somiglia, ma contende ciò che hai. | docs/corpus/oroscopo_cinese.md:337 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-147 | È la giornata del Rivale: nella lettura dei Dieci Dei lui e il Compagno portano sul lavoro la gara fra chi sta allo stesso livello. | docs/corpus/oroscopo_cinese.md:338 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 食神, il Nutrimento**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-148 | Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità. È ciò che produci con calma, il talento che lavora senza sforzo. | docs/corpus/oroscopo_cinese.md:343 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-149 | Il Nutrimento è di turno: la regola del BaZi dice che doma le Sette Uccisioni, cioè che il talento tiene a bada la pressione. | docs/corpus/oroscopo_cinese.md:344 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-150 | È la giornata del Nutrimento: nella lettura dei Dieci Dei è la vena che produce, quella che il tuo elemento genera da sé. | docs/corpus/oroscopo_cinese.md:345 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 伤官, l'Ufficiale Ferito**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-151 | Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta. La regola dice che urta l'Ufficiale, cioè i superiori e le regole. | docs/corpus/oroscopo_cinese.md:350 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-152 | L'Ufficiale Ferito è di turno: nel BaZi è l'espressione che rompe le regole. Quando incontra l'Ufficiale, che è l'autorità, nasce attrito. | docs/corpus/oroscopo_cinese.md:351 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-153 | È la giornata dell'Ufficiale Ferito: nella lettura dei Dieci Dei è il dio che attacca l'Ufficiale, cioè la regola, l'autorità, la carriera. | docs/corpus/oroscopo_cinese.md:352 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 偏财, la Ricchezza indiretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-154 | Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Sono le occasioni che arrivano di lato. | docs/corpus/oroscopo_cinese.md:357 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-155 | La Ricchezza indiretta è di turno: la regola del BaZi dice che la Ricchezza nutre l'Ufficiale, cioè che le risorse alimentano la carriera. | docs/corpus/oroscopo_cinese.md:358 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-156 | È la giornata della Ricchezza indiretta: nel BaZi è ciò che circola e arriva di lato. Letta sul lavoro, nutre l'Ufficiale, cioè la carriera. | docs/corpus/oroscopo_cinese.md:359 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 正财, la Ricchezza diretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-157 | Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Sono le risorse regolari, frutto del lavoro. | docs/corpus/oroscopo_cinese.md:364 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-158 | La Ricchezza diretta è di turno: la regola del BaZi dice che la Ricchezza nutre l'Ufficiale, cioè che il frutto del lavoro sostiene la posizione. | docs/corpus/oroscopo_cinese.md:365 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-159 | È la giornata della Ricchezza diretta: nel BaZi è il guadagno regolare, frutto del lavoro. Letta sul lavoro, dà peso a chi procede con ordine. | docs/corpus/oroscopo_cinese.md:366 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 七杀, le Sette Uccisioni**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-160 | Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità. Sono una forza che mette alla prova. | docs/corpus/oroscopo_cinese.md:370 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-161 | Le Sette Uccisioni sono di turno: nel BaZi stanno con l'Ufficiale diretto fra ciò che controlla il tuo elemento, cioè la regola e l'autorità. | docs/corpus/oroscopo_cinese.md:371 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-162 | È la giornata delle Sette Uccisioni: nella lettura dei Dieci Dei governano il tuo elemento. Sul lavoro vogliono dire pressione e sfida. | docs/corpus/oroscopo_cinese.md:372 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 正官, l'Ufficiale diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-163 | Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta. È regola, responsabilità, riconoscimento. | docs/corpus/oroscopo_cinese.md:376 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-164 | L'Ufficiale diretto è di turno: nel BaZi è ciò che controlla il tuo elemento, cioè la regola, l'autorità, la carriera. | docs/corpus/oroscopo_cinese.md:377 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-165 | È la giornata dell'Ufficiale diretto: nella lettura dei Dieci Dei è il dio a cui la scheda del lavoro guarda per primo. | docs/corpus/oroscopo_cinese.md:378 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 偏印, il Sigillo indiretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-166 | Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità. È intuizione, sostegno insolito, studio personale. | docs/corpus/oroscopo_cinese.md:383 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-167 | Il Sigillo indiretto è di turno: la regola del BaZi dice che i Sigilli trasformano l'Ufficiale in sostegno. Qui il sostegno passa dall'intuizione. | docs/corpus/oroscopo_cinese.md:384 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-168 | È la giornata del Sigillo indiretto: nella lettura dei Dieci Dei genera il tuo elemento e ti sostiene in una forma insolita. | docs/corpus/oroscopo_cinese.md:385 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.2 Lavoro (guarda all'Ufficiale), 正印, il Sigillo diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-169 | Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta. È protezione, studio, cura, che vengono dall'alto. | docs/corpus/oroscopo_cinese.md:390 (frase 1) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-170 | Il Sigillo diretto è di turno: la regola del BaZi dice che l'Ufficiale genera il Sigillo che sostiene te. L'autorità diventa insegnamento. | docs/corpus/oroscopo_cinese.md:391 (frase 2) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |
| C-G-171 | È la giornata del Sigillo diretto: nel BaZi l'Ufficiale genera il Sigillo e il Sigillo sostiene te. Per questo si parla di protezione dall'alto. | docs/corpus/oroscopo_cinese.md:392 (frase 3) | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | la regola generale 3.2 (riga 326) e le regole in più dei singoli dei non nominano opere |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 比肩, il Compagno**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-172 | Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Nell'amore di una donna porta altre persone nel quadro. | docs/corpus/oroscopo_cinese.md:400 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-173 | Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. Nell'amore di una donna porta altre persone nel quadro. | docs/corpus/oroscopo_cinese.md:401 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-174 | Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Nell'amore di una donna porta altre persone nel quadro. | docs/corpus/oroscopo_cinese.md:402 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 劫财, il Rivale**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-175 | Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell'amore di una donna porta altre persone nel quadro. | docs/corpus/oroscopo_cinese.md:406 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-176 | Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell'amore di una donna porta altre persone nel quadro. | docs/corpus/oroscopo_cinese.md:407 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-177 | Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Nell'amore di una donna porta altre persone nel quadro. | docs/corpus/oroscopo_cinese.md:408 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 食神, il Nutrimento**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-178 | Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell'amore è dolcezza, piacere semplice. | docs/corpus/oroscopo_cinese.md:412 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-179 | Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell'amore è dolcezza, piacere semplice. | docs/corpus/oroscopo_cinese.md:413 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-180 | Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Nella scheda dell'amore è dolcezza, piacere semplice. | docs/corpus/oroscopo_cinese.md:414 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 伤官, l'Ufficiale Ferito**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-181 | Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Urta l'Ufficiale, la figura del partner: per una donna è il segno classico dell'attrito. | docs/corpus/oroscopo_cinese.md:419 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-182 | Oggi è di turno l'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Urta l'Ufficiale, la figura del partner: per una donna è il segno classico dell'attrito. | docs/corpus/oroscopo_cinese.md:420 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-183 | Nel BaZi il giorno di oggi ti porta l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Urta l'Ufficiale, la figura del partner: per una donna è il segno classico dell'attrito. | docs/corpus/oroscopo_cinese.md:421 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 偏财, la Ricchezza indiretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-184 | Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner. | docs/corpus/oroscopo_cinese.md:426 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-185 | Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner. | docs/corpus/oroscopo_cinese.md:427 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-186 | Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner. | docs/corpus/oroscopo_cinese.md:428 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 正财, la Ricchezza diretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-187 | Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner. | docs/corpus/oroscopo_cinese.md:433 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-188 | Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner. | docs/corpus/oroscopo_cinese.md:434 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-189 | Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La Ricchezza nutre l'Ufficiale, che per una donna è la figura del partner. | docs/corpus/oroscopo_cinese.md:435 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 七杀, le Sette Uccisioni**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-190 | Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l'amante o il legame intenso, che mette alla prova. | docs/corpus/oroscopo_cinese.md:440 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-191 | Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l'amante o il legame intenso, che mette alla prova. | docs/corpus/oroscopo_cinese.md:441 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-192 | Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. Per una donna sono l'amante o il legame intenso, che mette alla prova. | docs/corpus/oroscopo_cinese.md:442 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 正官, l'Ufficiale diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-193 | Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell'unione. | docs/corpus/oroscopo_cinese.md:447 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-194 | Oggi è di turno l'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell'unione. | docs/corpus/oroscopo_cinese.md:448 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-195 | Nel BaZi il giorno di oggi ti porta l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. Per una donna è il partner, la figura dell'unione. | docs/corpus/oroscopo_cinese.md:449 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 偏印, il Sigillo indiretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-196 | Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner. | docs/corpus/oroscopo_cinese.md:453 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-197 | Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner. | docs/corpus/oroscopo_cinese.md:454 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-198 | Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner. | docs/corpus/oroscopo_cinese.md:455 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.3 Amore, per una donna (guarda all'Ufficiale), 正印, il Sigillo diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-199 | Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner. | docs/corpus/oroscopo_cinese.md:459 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-200 | Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner. | docs/corpus/oroscopo_cinese.md:460 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |
| C-G-201 | Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nell'amore di una donna i Sigilli addolciscono l'Ufficiale, la figura del partner. | docs/corpus/oroscopo_cinese.md:461 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.3, riga 396) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 比肩, il Compagno**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-202 | Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner. | docs/corpus/oroscopo_cinese.md:469 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-203 | Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner. | docs/corpus/oroscopo_cinese.md:470 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-204 | Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. Per un uomo contende la Ricchezza, che è la figura della partner. | docs/corpus/oroscopo_cinese.md:471 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 劫财, il Rivale**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-205 | Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner. | docs/corpus/oroscopo_cinese.md:476 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-206 | Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner. | docs/corpus/oroscopo_cinese.md:477 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-207 | Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. Per un uomo la contesa riguarda la Ricchezza, che è la figura della partner. | docs/corpus/oroscopo_cinese.md:478 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 食神, il Nutrimento**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-208 | Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:483 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-209 | Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:484 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-210 | Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. Genera la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:485 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 伤官, l'Ufficiale Ferito**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-211 | Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:490 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-212 | Oggi è di turno l'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:491 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-213 | Nel BaZi il giorno di oggi ti porta l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. Genera con impeto la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:492 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 偏财, la Ricchezza indiretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-214 | Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l'incontro. | docs/corpus/oroscopo_cinese.md:497 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-215 | Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l'incontro. | docs/corpus/oroscopo_cinese.md:498 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-216 | Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. Per un uomo è la figura della compagna non ufficiale, l'incontro. | docs/corpus/oroscopo_cinese.md:499 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 正财, la Ricchezza diretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-217 | Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile. | docs/corpus/oroscopo_cinese.md:504 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-218 | Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile. | docs/corpus/oroscopo_cinese.md:505 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-219 | Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. Per un uomo è la figura della moglie, la compagna stabile. | docs/corpus/oroscopo_cinese.md:506 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 七杀, le Sette Uccisioni**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-220 | Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro. | docs/corpus/oroscopo_cinese.md:511 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-221 | Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro. | docs/corpus/oroscopo_cinese.md:512 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-222 | Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La Ricchezza, la figura della partner, si consuma verso di loro. | docs/corpus/oroscopo_cinese.md:513 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 正官, l'Ufficiale diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-223 | Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. L'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:517 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-224 | Oggi è di turno l'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. L'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:518 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-225 | Nel BaZi il giorno di oggi ti porta l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. L'Ufficiale consuma la Ricchezza, che per un uomo è la figura della partner. | docs/corpus/oroscopo_cinese.md:519 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 偏印, il Sigillo indiretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-226 | Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell'amore è il bisogno di pensare. | docs/corpus/oroscopo_cinese.md:523 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-227 | Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell'amore è il bisogno di pensare. | docs/corpus/oroscopo_cinese.md:524 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-228 | Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. Nella scheda dell'amore è il bisogno di pensare. | docs/corpus/oroscopo_cinese.md:525 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.4 Amore, per un uomo (guarda alla Ricchezza), 正印, il Sigillo diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-229 | Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell'amore è cura, famiglia, radici. | docs/corpus/oroscopo_cinese.md:529 (frase 1) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-230 | Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell'amore è cura, famiglia, radici. | docs/corpus/oroscopo_cinese.md:530 (frase 2) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |
| C-G-231 | Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. Nella scheda dell'amore è cura, famiglia, radici. | docs/corpus/oroscopo_cinese.md:531 (frase 3) | 渊海子平, "论六亲"; 子平真诠, "论六亲" (corpus 3.4, riga 465) | caso | fonte dichiarata |  |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 比肩, il Compagno**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-232 | Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge come le persone che hai intorno. | docs/corpus/oroscopo_cinese.md:539 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-233 | Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge come le persone che hai intorno. | docs/corpus/oroscopo_cinese.md:540 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-234 | Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge come le persone che hai intorno. | docs/corpus/oroscopo_cinese.md:541 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 劫财, il Rivale**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-235 | Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell'amore lo legge come le persone che hai intorno. | docs/corpus/oroscopo_cinese.md:545 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-236 | Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell'amore lo legge come le persone che hai intorno. | docs/corpus/oroscopo_cinese.md:546 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-237 | Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell'amore lo legge come le persone che hai intorno. | docs/corpus/oroscopo_cinese.md:547 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 食神, il Nutrimento**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-238 | Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell'amore lo legge come il tuo modo di esprimerti. | docs/corpus/oroscopo_cinese.md:551 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-239 | Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell'amore lo legge come il tuo modo di esprimerti. | docs/corpus/oroscopo_cinese.md:552 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-240 | Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell'amore lo legge come il tuo modo di esprimerti. | docs/corpus/oroscopo_cinese.md:553 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 伤官, l'Ufficiale Ferito**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-241 | Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. La scheda dell'amore lo legge come il tuo modo di esprimerti. | docs/corpus/oroscopo_cinese.md:557 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-242 | Oggi è di turno l'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. La scheda dell'amore lo legge come il tuo modo di esprimerti. | docs/corpus/oroscopo_cinese.md:558 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-243 | Nel BaZi il giorno di oggi ti porta l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. La scheda dell'amore lo legge come il tuo modo di esprimerti. | docs/corpus/oroscopo_cinese.md:559 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 偏财, la Ricchezza indiretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-244 | Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La scheda dell'amore la legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:563 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-245 | Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. La scheda dell'amore la legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:564 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-246 | Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La scheda dell'amore la legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:565 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 正财, la Ricchezza diretta**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-247 | Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La scheda dell'amore la legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:569 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-248 | Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. La scheda dell'amore la legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:570 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-249 | Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La scheda dell'amore la legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:571 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 七杀, le Sette Uccisioni**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-250 | Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell'amore le legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:575 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-251 | Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell'amore le legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:576 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-252 | Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell'amore le legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:577 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 正官, l'Ufficiale diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-253 | Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell'amore lo legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:581 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-254 | Oggi è di turno l'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell'amore lo legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:582 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-255 | Nel BaZi il giorno di oggi ti porta l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell'amore lo legge come la figura dell'altro. | docs/corpus/oroscopo_cinese.md:583 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 偏印, il Sigillo indiretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-256 | Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell'amore legge i Sigilli come la cura. | docs/corpus/oroscopo_cinese.md:587 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-257 | Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell'amore legge i Sigilli come la cura. | docs/corpus/oroscopo_cinese.md:588 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-258 | Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La scheda dell'amore legge i Sigilli come la cura. | docs/corpus/oroscopo_cinese.md:589 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 3.5 Amore, serie neutra (genere non dichiarato), 正印, il Sigillo diretto**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-259 | Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell'amore legge i Sigilli come la cura. | docs/corpus/oroscopo_cinese.md:593 (frase 1) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-260 | Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell'amore legge i Sigilli come la cura. | docs/corpus/oroscopo_cinese.md:594 (frase 2) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |
| C-G-261 | Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell'amore legge i Sigilli come la cura. | docs/corpus/oroscopo_cinese.md:595 (frase 3) | nessuna: la regola 3.5 (riga 535) dice "scelta dell'app, non della tradizione" | nessuna | **SENZA FONTE** | solo il calcolo del dio ha la fonte della sezione 3 |

**Corpus cinese, 4.2 Direzione (Generale: Dio della Gioia; Fortuna: Dio della Ricchezza), Generale**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-262 | Gli almanacchi cinesi mettono oggi il Dio della Gioia a {direzione_gioia}: il posto viene dal tronco del giorno. | docs/corpus/oroscopo_cinese.md:616 (frase 1) | 协纪辨方书, tabella degli almanacchi (corpus 4.2, riga 613) | caso | fonte dichiarata |  |
| C-G-263 | La direzione del giorno è {direzione_gioia}, dove l'almanacco cinese colloca il Dio della Gioia. | docs/corpus/oroscopo_cinese.md:617 (frase 2) | 协纪辨方书, tabella degli almanacchi (corpus 4.2, riga 613) | caso | fonte dichiarata |  |
| C-G-264 | Il Dio della Gioia oggi sta a {direzione_gioia}, secondo il calendario cinese, che ne dà il posto giorno per giorno. | docs/corpus/oroscopo_cinese.md:618 (frase 3) | 协纪辨方书, tabella degli almanacchi (corpus 4.2, riga 613) | caso | fonte dichiarata |  |

**Corpus cinese, 4.2 Direzione (Generale: Dio della Gioia; Fortuna: Dio della Ricchezza), Fortuna**

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-G-265 | L'almanacco cinese pone oggi il Dio della Ricchezza a {direzione_ricchezza}: il posto viene dal tronco del giorno. | docs/corpus/oroscopo_cinese.md:621 (frase 1) | 协纪辨方书, tabella degli almanacchi (corpus 4.2, riga 613) | caso | fonte dichiarata |  |
| C-G-266 | La direzione della ricchezza oggi è {direzione_ricchezza}, secondo il calendario cinese e la tabella degli almanacchi. | docs/corpus/oroscopo_cinese.md:622 (frase 2) | 协纪辨方书, tabella degli almanacchi (corpus 4.2, riga 613) | caso | fonte dichiarata |  |
| C-G-267 | Il Dio della Ricchezza, dicono gli almanacchi cinesi, oggi sta a {direzione_ricchezza}. | docs/corpus/oroscopo_cinese.md:623 (frase 3) | 协纪辨方书, tabella degli almanacchi (corpus 4.2, riga 613) | caso | fonte dichiarata |  |

### Settimana e Mese

Come nella Vedica: il "Da dove viene" del periodo riporta quello del giorno migliore.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-S-001 | Da dove viene: il giorno migliore, {giorno}: {la riga "Da dove viene" della scheda del Giorno cinese di quel giorno} | lib/core/horoscope/la_settimana_del_cielo.dart:583-584; lib/features/horoscope/il_periodo_view.dart:184-185 | nessuna per la cornice | nessuna | **SENZA FONTE** | la scelta del giorno migliore è dell'app; le frasi riportate sono quelle del Giorno, con lo stato scritto alle loro righe |
| C-S-002 | Da dove viene: {la riga "Da dove viene" del Giorno di quella data, con la prima lettera minuscola} (uno dei tre giorni migliori, nella Lunga) | lib/features/horoscope/il_periodo_view.dart:175, 246 | nessuna per la cornice | nessuna | **SENZA FONTE** | come sopra |

### Anno

La stessa riga per i quattro domini (`l_anno_delle_tradizioni.dart:117-127`), qui divisa frase per frase.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-A-001 | L'anno {del \| della} {animale} va dal {data} al {data}. | lib/core/horoscope/l_anno_delle_tradizioni.dart:117-118 | nessuna | nessuna | **SENZA FONTE** | fatto di calcolo, non un'affermazione della tradizione (Capodanno lunare) |
| C-A-002 | Con {il tuo animale}, il tuo animale: {rapporto}. | lib/core/horoscope/l_anno_delle_tradizioni.dart:118-119 | Sanming Tonghui (commento righe 46-49), con le stesse parole del Giorno: vedi le righe del {rapporto} nel Giorno cinese | regola | fonte dichiarata | il {rapporto} "lo stesso animale" resta senza fonte come nel Giorno |
| C-A-003 | Tai Sui, il signore dell'anno: non lo offendi. | lib/core/horoscope/l_anno_delle_tradizioni.dart:120-121 | nessuna: il commento (righe 50-54) rimanda alle "cinque relazioni degli almanacchi" senza opera | nessuna | **SENZA FONTE** |  |
| C-A-004 | Tai Sui, il signore dell'anno: lo offendi, {hai lo stesso animale dell'anno \| il tuo animale gli si oppone \| il tuo animale e quello dell'anno si puniscono \| il tuo animale e quello dell'anno si danneggiano \| il tuo animale e quello dell'anno si rompono}. | lib/core/horoscope/l_anno_delle_tradizioni.dart:120-121, 69-96 | nessuna: "le cinque relazioni degli almanacchi" (righe 50-54) e le sei rotture (righe 87-96) senza opera | nessuna | **SENZA FONTE** | lo stesso animale e la rottura abbassano l'anno di un gradino (righe 111-115) |

### Note del metodo

Il Giorno: `notaGenerale` per la Generale, `notaDei` per Amore e Lavoro, `notaDei` e `notaColore` per la Fortuna (`la_lettura_cinese.dart:148, 192-194`; testo in `oroscopo_cinese_data.dart:549-554`, uguale al corpus, righe 627-629). L'Anno: `l_anno_delle_tradizioni.dart:128-132`.

| N. | Frase (citata esatta, segnaposti tali e quali) | Dove | Fonte dichiarata | Livello | Stato | Nota |
|---|---|---|---|---|---|---|
| C-M-001 | L'animale del giorno è il ramo del giorno nel ciclo dei sessanta; il rapporto col tuo animale viene dalle tabelle del Sanming Tonghui (1578). | docs/corpus/oroscopo_cinese.md:627; lib/core/horoscope/oroscopo_cinese_data.dart:549-550 | Sanming Tonghui (1578), nella frase; 三命通会 (Sanming Tonghui, 1578), libro II, capitoli sui sei accordi, le tre armonie, i tre castighi, i sei danni, gli scontri; 五行大义 (Wuxing Dayi), capitoli sugli accordi, gli scontri, i castighi e i danni (corpus, sezione 1, riga 36) | regola | fonte dichiarata | Generale |
| C-M-002 | Il guardiano è uno dei dodici del calendario, contato dal mese solare; il consiglio viene dal solo guardiano, non dall'almanacco intero. | docs/corpus/oroscopo_cinese.md:627; lib/core/horoscope/oroscopo_cinese_data.dart:549-550 | 淮南子·天文训 per la successione; 钦定协纪辨方书 (1739) per la regola degli almanacchi; adatto e sconsigliato dalla sintesi sohu.com/a/727671351_121819358 riscontrata su huangli999.com e huangli888.com (corpus, sezione 2, riga 127) | regola | fonte dichiarata | Generale; vedi le Osservazioni |
| C-M-003 | Il tuo giorno di nascita ha un tronco celeste, il giorno di oggi un altro: il loro rapporto fra i cinque elementi dà uno dei Dieci Dei del BaZi. | docs/corpus/oroscopo_cinese.md:628; lib/core/horoscope/oroscopo_cinese_data.dart:551-552 | 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Amore, Lavoro, Fortuna |
| C-M-004 | La scheda legge quel dio come lo leggono lo Yuanhai Ziping e il Ziping Zhenquan. | docs/corpus/oroscopo_cinese.md:628; lib/core/horoscope/oroscopo_cinese_data.dart:551-552 | Yuanhai Ziping e Ziping Zhenquan, nella frase; 渊海子平 ("论十神", "论六亲") e 子平真诠 ("论六亲") (corpus, sezione 3, riga 231) | regola | fonte dichiarata | Amore, Lavoro, Fortuna; vedi le Osservazioni |
| C-M-005 | Colore e numeri sono quelli dell'elemento del giorno nella tradizione, non colori o numeri portafortuna. | docs/corpus/oroscopo_cinese.md:629; lib/core/horoscope/oroscopo_cinese_data.dart:553-554 | 礼记·月令 per il colore; 河图 (He Tu) come lo dà il 周易·系辞上 per i numeri (corpus 4.1, riga 603) | regola | fonte dichiarata | Fortuna |
| C-M-006 | L'anno cinese va da Capodanno lunare a Capodanno lunare. | lib/core/horoscope/l_anno_delle_tradizioni.dart:128 | nessuna | nessuna | **SENZA FONTE** | Anno; fatto di calendario |
| C-M-007 | Il rapporto fra il tuo animale e quello dell'anno viene dalle tabelle del Sanming Tonghui; | lib/core/horoscope/l_anno_delle_tradizioni.dart:128-130 | Sanming Tonghui, nella frase | regola | fonte dichiarata | Anno |
| C-M-008 | il Tai Sui e le cinque relazioni che lo offendono (stesso animale, opposizione, punizione, danno, rottura) vengono dagli almanacchi cinesi. | lib/core/horoscope/l_anno_delle_tradizioni.dart:130-132 | nessuna: "gli almanacchi cinesi" sono un genere, non un'opera | nessuna | **SENZA FONTE** | Anno |

## Lette e non contate

Frasi lette durante il lavoro che non stanno né nella riga "Da dove viene" né nella nota del metodo delle schede, e quindi non sono nel conteggio:

- `CorrenteDelCielo.notaDelLivello` (`corrente_del_cielo.dart:633-641, 684-693`): il ripiego senza carta o senza ora; si mostra sotto le schede, col consulto (`oroscopo_screen.dart:1490-1492`), non in "Da dove viene".
- `IlCieloDelSegno.approfondita` e `fraseDi` (`il_cielo_del_segno.dart:46-68`): usano `materiaDelleCase`, ma nessuno in `lib` chiama `approfondita` (grep del 1 ottobre 2026).
- `materiaDelleCase` entra in "Da dove viene" solo attraverso il momento chiave del periodo (riga O-S-003) ed è citata là.
- Le righe di domani e del secondo momento (`LaLetturaCinese.domani` e `fattoDelGiorno`, `LaLetturaVedica.domani` e `fattoDelGiorno`, `il_domani.dart`).
- "Adatto a" e "Meglio evitare" dei guardiani (corpus cinese, sezione 2; `OroscopoCineseData.consigliDelGuardiano`): dalla EU Aggiunta nessun file di `lib` li legge.
- Le voci del glossario vedico che `_metodo` non usa (Rashi, Nakshatra, Chandrashtama, i nove esiti, Vara, Rahu; corpus vedico righe 511-526).
- La nota della tradizione col punto interrogativo della testata (`la_testa_della_tradizione.dart:232-241`, `LeNoteDelleTradizioni`): è la nota della tradizione, non il metodo della scheda.
- I testi dell'Architetto in `docs/corpus/eu/`: scrivono essi stessi che il cielo "sta solo nella riga Da dove viene, che non è in questo file".
- Le parti "TESTO" prima di " || " dei tre corpora: dalla EU Aggiunta non vanno più a video.

## Osservazioni per l'Architetto

Quattro cose viste leggendo, che non sono fonti ma toccano la verità di ciò che le righe dicono. Il padre è il lavoro della EU Aggiunta non ancora committato (`horoscope.dart`, `la_lettura_cinese.dart`, `la_lettura_vedica.dart`, `l_annuale.dart` modificati nel worktree): ha cambiato da dove vengono i testi senza cambiare queste note, mentre `il_metodo_del_responso.dart:12-14` chiede che chi cambia il modo in cui un responso nasce cambi anche la nota.

1. O-M-001 e O-M-002 dicono che la prima frase viene dalla Luna di oggi e il resto dai transiti; `horoscope.dart:285-311` scrive che titolo e paragrafi vengono adesso dal corpus del Giorno occidentale nella fascia del livello, e che "il cielo sta solo in rigaDelLivello".
2. C-M-002 dice "il consiglio viene dal solo guardiano": i consigli del guardiano (`consigliDelGuardiano`) non sono più letti da nessun file di `lib`.
3. C-M-004 dice che la scheda legge il dio "come lo leggono lo Yuanhai Ziping e il Ziping Zhenquan": il testo della scheda viene adesso dal corpus EU nella fascia del livello del dio; il dio resta nel "Da dove viene".
4. V-S-001, V-S-002, C-S-001 e C-S-002 riportano sotto la data di un altro giorno la riga del Giorno così com'è, e quella riga dice "Oggi" e "di oggi" (per esempio V-G-013, "Oggi la Luna torna {segno_luna}...", e C-G-001, "... di oggi e ..."). È lo stesso difetto che l'Occidentale ha già corretto con `oggi: false` (`il_livello_del_cielo.dart:179-184`). Padre: ordine EU voce 02, `LaSettimanaDelCielo.dalleSchede` (`la_settimana_del_cielo.dart:534-593`), aggiunto nel worktree e non ancora committato (`git log -S dalleSchede` non trova commit). Visto leggendo il codice, non a video.

Una differenza di parola, non di fonte: per il venerdì il corpus vedico dice "lo screziato" (riga 275, nel "Da dove viene") e il codice "bianco screziato" (`la_lettura_vedica.dart:97`, nella riga della Fortuna). PROVENIENZA IGNOTA fra ordine ES voce 09 e i suoi seguiti: non è stata cercata nella storia.

## Conteggio

| Tradizione | Frasi | Fonte dichiarata | SENZA FONTE |
|---|---|---|---|
| Occidentale | 299 | 268 | 31 |
| Vedica | 179 | 164 | 15 |
| Cinese | 281 | 239 | 42 |
| Totale | 759 | 671 | 88 |

### Le frasi SENZA FONTE

**Occidentale**

- O-G-003: Oggi nessun passaggio stretto parla a questo campo.
- O-G-004: Dalla Luna di oggi in {segno}, nella tua {ordinale} casa solare{, aspetto}; {il Sole | Venere | Marte | Giove} è in {segno}, nella tua {o...
- O-G-005: {aspetto} della riga qui sopra: "nel tuo segno", "in sestile al tuo segno", "in trigono al tuo segno", "in quadratura al tuo segno", "in...
- O-G-006: Il numero è il tuo giorno personale, dalla tua data di nascita e da quella di oggi.
- O-G-007: Il numero è il giorno universale di oggi, dalla sola data.
- O-S-001: Da dove viene: il momento chiave è {momento chiave}
- O-S-002: {giorno} alle {ora}: la Luna forma {un trigono | un sestile | una congiunzione} {al tuo Sole | alla tua Venere | al tuo Marte | al tuo Gi...
- O-S-003: {giorno} alle {ora}: {Luna nuova | Primo quarto | Luna piena | Ultimo quarto} in {segno}, nella tua {ordinale} casa[ solare], quella {mat...
- O-S-004: Da dove viene: nessuna fase della Luna e nessun passaggio esatto in questo periodo: il cielo scorre senza un momento solo.
- O-S-006: Da dove viene: la Luna del giorno in {segno}, nella tua {ordinale} casa solare{, aspetto}; {corpo} è in {segno}, nella tua {ordinale}. (u...
- O-S-007: Da dove viene: quel giorno nessun passaggio stretto parla a questo campo. (uno dei tre giorni migliori)
- O-S-008: {giorno} alle {ora}: {Luna nuova | Primo quarto | Luna piena | Ultimo quarto} in {segno}, nella tua {ordinale} casa[ solare]. (riquadro "...
- O-S-009: {giorno}: {il Sole | Mercurio | Venere | Marte | Giove | Saturno} {entra | torna} in {segno}[, retrogrado | , retrograda]. (riquadro)
- O-S-010: {giorno} alle {ora}: {specie dell'eclissi} in {segno}, nella tua {ordinale} casa[ solare]. (riquadro)
- O-S-011: Nessun ingresso e nessuna fase della Luna in {la settimana | il mese}. (riquadro)
- O-S-012: Senza ora e luogo di nascita {la settimana | il mese} si legge sul tuo segno e sulle case solari. (riquadro)
- O-S-013: Senza l'ora di nascita {la settimana | il mese} si legge sui tuoi pianeti, con le case solari al posto di quelle della carta. (riquadro)
- O-A-003: Il livello viene da Saturno nella casa {n}, {angolare | succedente | cadente}: più è in vista, più il lavoro chiede.
- O-A-008: L'Ascendente del tuo anno è in {segno}.
- O-A-009: Venere nella tua Rivoluzione Solare cade nella casa {n}.
- O-A-010: Il Medio Cielo del tuo anno è in {segno}.
- O-A-011: Giove nella tua Rivoluzione Solare cade nella casa {n}.
- O-M-001: La prima frase viene dalla Luna di oggi: il segno in cui si trova, contato dal tuo segno solare, dice in quale casa solare passa.
- O-M-002: Il resto viene dai transiti di oggi sulla tua carta natale, calcolati sul telefono dalle effemeridi: i pianeti che passano sui tuoi piane...
- O-M-003: Il resto viene dai transiti di oggi sui tuoi pianeti di nascita, calcolati sul telefono dalle effemeridi. Senza l'ora di nascita le case...
- O-M-004: Il resto è scelto per il tuo segno e per il giorno fra le frasi di Medora: senza ora e luogo di nascita non c'è una carta su cui calcolar...
- O-M-005: Il livello da due a cinque viene dalla Luna di oggi e dal pianeta di questo campo: dal segno in cui si trovano rispetto al tuo e dalle ca...
- O-M-006: Il livello da due a cinque viene dai passaggi di oggi che parlano a questo campo: quelli armonici lo alzano, quelli tesi lo abbassano. Co...
- O-M-007: Il numero è il giorno personale della numerologia, dalla tua data di nascita e da quella di oggi.
- O-M-012: Un pianeta vicino al confine fra due case può cadere nella casa accanto con un altro sistema di case.
- O-M-013: Le case sono equali: dodici settori di trenta gradi a partire dall'Ascendente dell'anno, perché il calcolo avviene sul tuo telefono.

**Vedica**

- V-G-003: Oggi la Luna passa {nel segno}, nella tua {ordinale} casa contata dalla Luna di nascita; per l'amore contano la settima casa, dell'unione...
- V-G-089: Oggi la Luna passa sulla quinta casa dalla tua Luna di nascita, letta qui come quella del cuore; la Chandra Bala però è di attenzione.
- V-G-090: La Luna è nella quinta casa contata dalla tua Luna di nascita, la casa dei sentimenti, in un giorno che la tradizione indiana dà per fati...
- V-G-091: Con la Luna in quinta casa, letta come il cuore che si apre, la Chandra Bala è di attenzione: emozioni forti e un po' di stanchezza.
- V-G-095: Oggi la Luna sta nell'undicesima casa dalla tua Luna di nascita, quella delle amicizie: da lì guarda la quinta, la casa del cuore.
- V-G-096: La Luna guarda la tua quinta casa, letta come il cuore che si apre, da un posto favorevole della Chandra Bala.
- V-G-097: Con la Luna nell'undicesima casa la tradizione indiana vede gioia; da lì il suo sguardo arriva sulla quinta, la casa del cuore.
- V-S-001: Da dove viene: il giorno migliore, {giorno}: {la riga "Da dove viene" della scheda del Giorno vedico di quel giorno}
- V-S-002: Da dove viene: {la riga "Da dove viene" del Giorno di quella data, con la prima lettera minuscola} (uno dei tre giorni migliori, nella Lu...
- V-A-005: Saturno era in {rashi}, nella tua {ordinale} casa dalla Luna di nascita: è la Sade Sati.
- V-M-001: La Luna di oggi è siderale, con l'ayanamsa di Lahiri, letta all'alba del luogo.
- V-M-004: Senza l'ora di nascita la tua stella non si sa: la Tara Bala manca.
- V-M-008: La quinta casa come cuore che si apre è una lettura moderna.
- V-M-009: L'anno vedico va da compleanno a compleanno.
- V-M-011: La Sade Sati è Saturno nella dodicesima, nella prima o nella seconda casa dalla Luna di nascita.

**Cinese**

- C-G-009: {rapporto} = "lo stesso animale"
- C-G-043: Per il legame: {relazione con l'Ufficiale} e {relazione con la Ricchezza}.
- C-G-068: Oggi è il giorno di {animale_giorno}, il tuo stesso animale: ritorna ogni dodici giorni. Nella tradizione cinese i rami uguali si rafforz...
- C-G-069: Il ramo di oggi è il tuo: nella tradizione cinese due rami uguali stanno fianco a fianco e si rafforzano.
- C-G-070: È il giorno del tuo animale: la tradizione cinese non gli dà un peso particolare, perché non è uno dei rapporti classificati.
- C-G-232: Il dio di oggi nel BaZi è il Compagno: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge come le persone...
- C-G-233: Oggi è di turno il Compagno, fra i Dieci Dei del BaZi: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge...
- C-G-234: Nel BaZi il giorno di oggi ti porta il Compagno: ha il tuo stesso elemento e la tua stessa polarità. La scheda dell'amore lo legge come l...
- C-G-235: Il dio di oggi nel BaZi è il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell'amore lo legge...
- C-G-236: Oggi è di turno il Rivale, fra i Dieci Dei del BaZi: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell...
- C-G-237: Nel BaZi il giorno di oggi ti porta il Rivale: ha il tuo stesso elemento con polarità opposta, contende ciò che hai. La scheda dell'amore...
- C-G-238: Il dio di oggi nel BaZi è il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La scheda dell'am...
- C-G-239: Oggi è di turno il Nutrimento, fra i Dieci Dei del BaZi: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. L...
- C-G-240: Nel BaZi il giorno di oggi ti porta il Nutrimento: il tuo elemento lo genera con la stessa polarità, è ciò che produci con calma. La sche...
- C-G-241: Il dio di oggi nel BaZi è l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le regole. La sch...
- C-G-242: Oggi è di turno l'Ufficiale Ferito, fra i Dieci Dei del BaZi: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe l...
- C-G-243: Nel BaZi il giorno di oggi ti porta l'Ufficiale Ferito: il tuo elemento lo genera con polarità opposta, è l'espressione che rompe le rego...
- C-G-244: Il dio di oggi nel BaZi è la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La scheda dell'amore la legge come l...
- C-G-245: Oggi è di turno la Ricchezza indiretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con la stessa polarità. La scheda dell'amore...
- C-G-246: Nel BaZi il giorno di oggi ti porta la Ricchezza indiretta: il tuo elemento la governa con la stessa polarità. La scheda dell'amore la le...
- C-G-247: Il dio di oggi nel BaZi è la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La scheda dell'amore la legge come la fi...
- C-G-248: Oggi è di turno la Ricchezza diretta, fra i Dieci Dei del BaZi: il tuo elemento la governa con polarità opposta. La scheda dell'amore la...
- C-G-249: Nel BaZi il giorno di oggi ti porta la Ricchezza diretta: il tuo elemento la governa con polarità opposta. La scheda dell'amore la legge...
- C-G-250: Il dio di oggi nel BaZi sono le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La scheda dell...
- C-G-251: Oggi sono di turno le Sette Uccisioni, fra i Dieci Dei del BaZi: governano il tuo elemento con la stessa polarità, sono pressione e sfida...
- C-G-252: Nel BaZi il giorno di oggi ti porta le Sette Uccisioni: governano il tuo elemento con la stessa polarità, sono pressione e sfida. La sche...
- C-G-253: Il dio di oggi nel BaZi è l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. La scheda dell'am...
- C-G-254: Oggi è di turno l'Ufficiale diretto, fra i Dieci Dei del BaZi: governa il tuo elemento con polarità opposta, è regola e responsabilità. L...
- C-G-255: Nel BaZi il giorno di oggi ti porta l'Ufficiale diretto: governa il tuo elemento con polarità opposta, è regola e responsabilità. La sche...
- C-G-256: Il dio di oggi nel BaZi è il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione. La sched...
- C-G-257: Oggi è di turno il Sigillo indiretto, fra i Dieci Dei del BaZi: genera il tuo elemento con la stessa polarità, è sostegno insolito e intu...
- C-G-258: Nel BaZi il giorno di oggi ti porta il Sigillo indiretto: genera il tuo elemento con la stessa polarità, è sostegno insolito e intuizione...
- C-G-259: Il dio di oggi nel BaZi è il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell'amore legg...
- C-G-260: Oggi è di turno il Sigillo diretto, fra i Dieci Dei del BaZi: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda...
- C-G-261: Nel BaZi il giorno di oggi ti porta il Sigillo diretto: genera il tuo elemento con polarità opposta, è protezione e cura. La scheda dell'...
- C-S-001: Da dove viene: il giorno migliore, {giorno}: {la riga "Da dove viene" della scheda del Giorno cinese di quel giorno}
- C-S-002: Da dove viene: {la riga "Da dove viene" del Giorno di quella data, con la prima lettera minuscola} (uno dei tre giorni migliori, nella Lu...
- C-A-001: L'anno {del | della} {animale} va dal {data} al {data}.
- C-A-003: Tai Sui, il signore dell'anno: non lo offendi.
- C-A-004: Tai Sui, il signore dell'anno: lo offendi, {hai lo stesso animale dell'anno | il tuo animale gli si oppone | il tuo animale e quello dell...
- C-M-006: L'anno cinese va da Capodanno lunare a Capodanno lunare.
- C-M-008: il Tai Sui e le cinque relazioni che lo offendono (stesso animale, opposizione, punizione, danno, rottura) vengono dagli almanacchi cinesi.

