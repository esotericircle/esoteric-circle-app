# RAPPORTO DELL'ORDINE FM, IL CORPUS POSIZIONALE DEI TAROCCHI PASSA A CODE

12 ottobre 2026. Testo: `docs/ordini/ORDINE_FM_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FM_MANIFESTO.md`, 7 voci, tutte chiuse. Il corpus posizionale è completo: **7.020 testi su 7.020 e 468 registri su 468**, nel Dart e nella fonte.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FM.01 le varianti 2 e 3 di passato, presente e futuro | `docs/corpus/tarocchi_posizione/schedario_passato.md` |
| FM.02 le quattro posizioni intatte della Croce Celtica | `docs/corpus/tarocchi_posizione/schedario_dietro.md` |
| FM.03 i registri delle carte | `docs/corpus/tarocchi_posizione/schedario_registri.md` |
| FM.04 il controllo della seconda persona | `docs/collaudo/FM/fm04_regola_a.txt` |
| FM.05 gli schedari e la loro soglia | `docs/collaudo/FM/lettori_ciechi/esito_1.txt` |
| FM.06 il Dart rigenerato e il cardinale minimo | `lib/core/tarot/le_carte_nella_posizione_dati.dart` |
| FM.07 nessuna build | `docs/ordini/RAPPORTO_ORDINE_FM.md` |

## LE PREMESSE

- **P1, sbagliata in un punto.** I conti delle posizioni nominate sono esatti, ma la premessa non nomina `dietro.md`, la quinta carta della Croce Celtica, che l'ordine FK voce 8 aveva aggiunto vuota: 468 righe vuote su 468. I testi mancanti erano **3.276**, non 2.808 e le posizioni che tenevano chiusa la stesa a dieci carte erano quattro. Corretta come da regola: `dietro` è nella voce FM.02.
- **P2, vera nella sostanza.** Lo strumento fa i controlli descritti; le righe sono 544, non 537 e le funzioni si sono spostate di qualche riga.
- **P3, vera.** Nessun controllo della seconda persona: ora c'è (FM.04).
- **P4, vera.** Nessuno schedario per posizione. Esisteva `mappa_delle_gemelle.md`, che però traccia i confini fra le carte e non fra le posizioni.

## COSA È STATO FATTO, IN ORDINE

1. **Il controllo del tu, prima di tutto (FM.04).** In `controlla_testo` un testo passa se porta almeno un segno della seconda persona: un pronome (tu, ti, te, tuo...), un verbo breve (hai, sei, puoi...), un presente frequente (senti, stringi; non quelli che sono anche nomi, come cerchi), o una desinenza che in italiano è solo del tu (futuro in -rai, imperfetto in -avi ed -evi, condizionale in -resti, infiniti e gerundi col "ti"). Le parole che finiscono allo stesso modo senza essere del tu (aperti, brevi, chiavi, offerti...) non contano. Visto rosso su due innesti prima di contare. **Il numero: 311 testi su 4.212 non lo passavano**, tutti riparati con il minimo di parole cambiate.
2. **Uno strumento per chi riempie**, `tool/riempi_la_posizione.py`: non reinventa i controlli, usa quelli di `genera_carte_nella_posizione.py` testo per testo e scrive nella fonte solo i testi che passano; gli altri tornano indietro col difetto. Scrive su un file accanto e poi lo scambia, così un blocco di Windows non può troncare la fonte.
3. **Gli otto schedari (FM.05)**, accanto al corpus: per ogni posizione che cosa chiede, la fonte (Waite 1911 per la Croce Celtica, Etteilla e Eden Gray per la stesa a tre carte), la gemella e il confine; poi, carta per carta, una riga QUI (ciò che la carta dice in questa posizione) e NON (ciò che direbbe nella gemella). Le righe di posizione le ho scritte io, quelle delle carte gli scrittori, **prima** dei testi.
4. **I testi**, scritti da nove scrittori in parallelo, uno per file: 936 per passato, presente e futuro, 1.872 per le quattro posizioni della Croce Celtica, 468 registri, 311 riparazioni.
5. **La misura**, due giri di lettori ciechi (sotto).
6. **Il Dart** rigenerato a ogni pezzo finito in una copia pulita del ramo (nel worktree gli scrittori lavoravano ancora), con la guardia del corpus portata alla dichiarazione vera. Tre spinte sul ramo.

## LA SOGLIA DEGLI SCHEDARI, E LA MISURA (FM.05)

La decide Code. Per ogni posizione dieci testi a caso, cinque suoi e cinque della gemella, mescolati; un lettore che non ha scritto niente li legge con le due definizioni e dice a quale posizione appartiene ciascuno. Per i registri, a quale dei tre ambiti. **Soglia: otto su dieci, in due giri con campioni e lettori diversi.** Lo strumento è nel repo, `tool/i_lettori_ciechi_del_corpus.py`, i fascicoli, le chiavi e le risposte in `docs/collaudo/FM/lettori_ciechi/`.

| prova (contro la gemella) | giro 1 | giro 2 |
|---|---|---|
| passato (presente) | 10 su 10 | 10 su 10 |
| presente (futuro) | 10 su 10 | 10 su 10 |
| futuro (presente) | 9 su 10 | 10 su 10 |
| te stesso (consultante) | 10 su 10 | 10 su 10 |
| la casa (te stesso) | 10 su 10 | 10 su 10 |
| speranze o timori (esito) | 10 su 10 | 10 su 10 |
| dietro (sotto) | 10 su 10 | 10 su 10 |
| registri (tre ambiti) | 10 su 10 | 10 su 10 |

L'unico errore, nel giro 1: un testo del presente (Asso di Denari capovolta) letto come futuro, perché dice "rischia di sfuggirti". **Che cosa misura e che cosa no**: misura che la posizione si riconosce; non misura che la carta si riconosca dal testo senza il nome, che era il difetto del corpus dell'11 ottobre (copre al 59,4 per cento). Gli scrittori avevano la regola e la fonte delle immagini davanti, ma quella prova non è stata fatta in quest'ordine.

## LE DECISIONI DI CODE

1. **Il "voi" vale come seconda persona** ("Due di voi", "vi tiene insieme"): la persona è dentro quel voi.
2. **I registri non si rivolgono alla persona** (dicono di che cosa parla la carta in un ambito): per loro valgono gli stessi controlli dei testi tranne il tu e la lunghezza è fra 60 e 220 caratteri.
3. **La Croce Celtica resta chiusa, ma non più per i testi.** Le dieci posizioni hanno la fonte. La fila in piedi del tavolo di Medora (ordine FL voce 05) metterebbe dieci carte affiancate larghe ventisei punti a 360: illeggibili. Si apre quando il tavolo a dieci carte sarà disegnato ed è la prossima cosa da ordinare se la si vuole viva. Il commento nel codice lo dice (`lib/core/tarot/tarot_spread_type.dart`).
4. **Le intestazioni** dei file riempiti dicono "scritte da Code dall'ordine FM", come chiede l'ordine e quelle delle posizioni nuove dicono da dove vengono i testi (la prova FJ.4 lo pretende).

## I DIFETTI E IL LORO PADRE (Regola C)

- **311 testi senza il tu.** Padre: chi li ha scritti, prima che la regola fosse misurata. Carta sola, esito, lato e consultante: il corpus dell'Architetto (ordine FI, aggiunte A1 e A4 e il commit 394e9c5); i due del futuro: la variante 1 del 27 settembre (ordine EQ voce 04).
- **Cinque frasi prese dalla guardia del genere** (`il_genere_non_si_indovina`), tutte con un participio che concorda con la cosa ma segue un verbo al tu ("Temi che la festa resti rimandata"): una della riparazione del Cavaliere di Coppe in carta sola (padre **FM.04**), una del presente (padre **FM.01**), tre di speranze o timori (padre **FM.02**). Riscritte senza participio; il dizionario non si allenta.
- **"La vitrina" per "la vetrina"** in carta sola, Nove di Denari capovolta: **PROVENIENZA IGNOTA** (corpus dell'Architetto, voce non rintracciabile). Corretto.
- **Lo strumento di riempimento apriva la fonte in scrittura diretta**: padre **FM.04**, il mio strumento; cinque scrittori hanno visto un blocco di Windows (errno 22) a metà scrittura, il file non si è troncato. Ora scrive accanto e scambia.
- **La prova FK "le posizioni senza fonte stanno solo nella Croce Celtica chiusa"** è caduta perché le posizioni senza fonte sono diventate zero: non un difetto, il mondo cambiato. Riscritta con la lapide (ogni posizione ha la sua fonte), rossa togliendo la fonte del dietro.
- **I fine riga di `copre.md`** cambiati nel worktree senza nessun testo cambiato: **PROVENIENZA IGNOTA**, riportati come nel repo.

**Segnalazioni degli scrittori, verificate**: le forme col genere nella fonte dei significati (`tarot_card.dart`, "sei diventato duro", "sei stanco") stanno tutte dentro la marca `[maschile|femminile|neutra]`: non è un difetto. Le parole vietate colpiscono anche fuori senso ("eredità della casa" nel Dieci di Denari, "il vino rovesciato", "ad alta voce"): gli scrittori le hanno girate ed è il prezzo di un controllo semplice. In futuro e in speranze o timori molte varianti cominciano con le stesse parole fra carte diverse ("Nei prossimi tempi", "Speri... Temi..."): la regola vale solo dentro la stessa carta e una stesa mostra una carta per posizione, ma letti di seguito suonano uniformi.

## LE GUARDIE

**Regola B**: `il_corpus_delle_posizioni` vista rossa prima di toccare il corpus (`docs/collaudo/FM/fm_regola_b.txt`). **Regola A**: il controllo del tu, due innesti e la prova riscritta di `la_stesa_di_n_carte`, rossa togliendo la fonte del dietro (`docs/collaudo/FM/fm04_regola_a.txt`); `ordine_fm_guard`, nuova, rossa col marcatore delle chiuse alzato e con una voce rinominata. La guardia del corpus dichiara adesso le quindici posizioni a tre varianti e i registri consegnati e il suo cardinale minimo sale da 4.212 a 7.020 testi.

## LA SUITE

SUITE_FINALE

## LA BUILD

Nessuna build (FM.07). La build è possibile, la ordina il fondatore. A video cambia il testo delle stese aperte: le carte della stesa a tre carte ruotano su tre varianti invece di una e i registri entrano nella lettura di casa secondo l'argomento.
