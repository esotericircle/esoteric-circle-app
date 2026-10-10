# RAPPORTO DELL'ORDINE FI, LA STESA DI TAROCCHI

**Le stese, le posizioni, le chiavi, la stesa che si conserva e la matrice dei piani sono nel codice; i mazzi aspettano una decisione del fondatore e il corpus aspetta i testi dell'Architetto.** Cinque stese con la loro geometria, diciassette posizioni, quattro chiavi di lettura con la loro tradizione che arrivano al modello, la stesa compiuta che non si puo' piu' rilanciare nella giornata, dieci righe nuove nella matrice e la tendina che dice da quale piano si apre una voce. In piu' la correzione di taglio e mescolamento chiesta dal fondatore l'11 ottobre.

Ramo di lavoro `fg-verifica-premesse`, spinto su `claude/esoteric-circle-master-order-e798aj`. Partenza `8b113c79`, 10 e 11 ottobre 2026. Testo: `docs/ordini/ORDINE_FI_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FI_MANIFESTO.md`. Da dove si riparte: `docs/ordini/RIPRESA.md`, sezione dell'ordine FI.

## LE VOCI E LA LORO PROVA, IN TRENTA SECONDI

| voce | stato | prova |
| --- | --- | --- |
| FI.01 le cinque stese | CHIUSA | `test/le_stese_del_cerchio_test.dart` |
| FI.02 la geometria come dato | CHIUSA | `test/le_stese_del_cerchio_test.dart` |
| FI.03 la regola di Dora sull'esito | APERTA IN ATTESA DI VERIFICA | si aggancia con il corpus della croce |
| FI.04 le diciassette posizioni | CHIUSA | `test/le_stese_del_cerchio_test.dart` |
| FI.05 "Te stesso" con la marca del genere | CHIUSA | `test/le_stese_del_cerchio_test.dart` |
| FI.06 le quattro chiavi | CHIUSA | `test/le_chiavi_e_la_matrice_dei_tarocchi_test.dart`, `docs/preview/prima_dopo/fi_selettori_chiave_dopo.png` |
| FI.07 la chiave arriva al modello | CHIUSA | `test/la_stesa_interpreta_davvero_test.dart` |
| FI.08 la lettura di casa si dichiara | CHIUSA | `test/la_stesa_interpreta_davvero_test.dart` |
| FI.13 il peso dei due mazzi | APERTA IN ATTESA DI VERIFICA | `docs/collaudo/FI/peso_dei_mazzi.txt`; la decisione e' del fondatore |
| FI.16 i cartigli | CHIUSA | `docs/collaudo/FI/cartigli.txt` |
| FI.26 il seme non decide piu' la stesa compiuta | CHIUSA | `test/la_stesa_si_conserva_test.dart` |
| FI.27 la stesa si conserva per la giornata | CHIUSA | `test/la_stesa_si_conserva_test.dart` |
| FI.28 il gesto resta vivo nella stesa in corso | CHIUSA | `test/la_carta_estratta_non_cambia_test.dart` |
| FI.32 la matrice dei tarocchi | CHIUSA | `test/le_chiavi_e_la_matrice_dei_tarocchi_test.dart`, `docs/preview/prima_dopo/fi_selettori_tipo_dopo.png` |
| FI.41 la guardia della stesa conservata | CHIUSA | `test/la_stesa_si_conserva_test.dart` |
| FI.45 le anteprime prima e dopo | APERTA IN ATTESA DI VERIFICA | fatte quelle dei selettori; le altre con le stese a video |
| il mazzo nel riquadro (segnalazione dell'11 ottobre) | CHIUSA | `test/il_mazzo_resta_nel_riquadro_test.dart` |
| parti 4, 5 e 7 | NON APERTE | vedi R10 e la ripresa |

Le voci si dicono chiuse sulle prove e sulle anteprime a 360 per 797 punti logici. **Nessuna e' stata vista sul telefono**: la build la ordina il fondatore (R9).

## LE PREMESSE

Le dodici premesse dell'ordine, verificate sul repository prima di toccare una riga, il 10 ottobre alle 22 circa: **tutte vere.** P1 (tre stese, solo la prima disponibile), P2 (tre posizioni), P3 (ReadingKey e TarotDeckStyle), P4 (`Random().nextInt` alla riga 165 quando il seme e' nullo), P5 (468 testi, con la generazione dichiarata in testa), P6 (`POSIZIONI = ('passato', 'presente', 'futuro')`), P7 (La Giustizia `tar_rw_11_la-giustizia_v1`, La Forza `tar_rw_08_la-forza_v1`), P8 (79 file `tar_rw_` e 79 miniature), P9 (le due cartelle solo nella copia principale sul disco, nessun file nel ramo), P10, P11 (tre gruppi, sedici argomenti), P12 (l'istruzione nomina le tre posizioni a testo fisso).

**La premessa PA1 dell'aggiunta sulla scrittura dei corpus e' falsa nella lettera**, e l'aggiunta e' ferma come prescrive: in `docs/corpus/` ci sono 26 voci (17 file `.md`, 7 `.json`, le cartelle `eu/` e `rune/`), non quattordici; e cinque `.md` non dichiarano in testa ne' chi li ha scritti ne' come (`oroscopo_annuale.md`, `oroscopo_cinese.md`, `oroscopo_vedico.md`, `stesa_interpretazione.md`, `tarocchi.md`). Vero che uno solo, `tarocchi_nella_posizione.md`, dichiara Gemini 2.5 Flash. **Nessun testo del corpus e' stato generato col modello in quest'ordine** (A2: niente da spostare in `docs/corpus/scartati_FI/`). **A9: delle diciassette posizioni ha la fonte pronta nessuna nella forma nuova** (tre varianti e i registri); le tre posizioni della stesa a tre carte (passato, presente, futuro) hanno la fonte di oggi, una variante; le quattordici nuove (cartaSola, consultante, lato, esito, consiglio, ostacolo, ambiente, copre, attraversa, corona, sotto, seStesso, laCasa, speranzeOTimori) aspettano i testi dell'Architetto, e i diciotto file vuoti della fonte (A4) si creano quando PA1 e' riscritta.

## R10, FIN DOVE SONO ARRIVATO

Dichiarato all'inizio: chiudere le parti 1, 2, 3, 6 e 8 con le loro guardie (diciotto voci), misurare FI.13 e FI.16, lasciare intatte le parti 4, 5 e 7. Arrivato: chiuse FI.01, 02, 04, 05, 06, 07, 08, 16, 26, 27, 28, 32 e 41, piu' la correzione del riquadro; aperte in attesa FI.03 (si vede solo con la croce a video), FI.13 (decisione del fondatore), FI.45 (le anteprime delle stese che non sono ancora a video). Della parte 8 restano FI.33 e FI.47, che vivono a video con la carta sola, e FI.34 e' rispettata (nessun prezzo in Eos). **FI.35, scritto come chiede l'ordine:** i quattro briefing dicono che le chiavi di lettura restano accessibili a tutti senza gating; il fondatore ha deciso il contrario il 10 ottobre 2026 ("tabella ok"), e la decisione del fondatore vince sul briefing. L'inserimento nei briefing lo decide lui a parte.

## VOCE FI.01, FI.02, FI.04, FI.05: LE STESE E LE POSIZIONI (commit `6daf8be5`)

DOMANDA: "bisogna inserire la stesa a 1 carta e quelle delle tradizioni piu' popolari"
PROVA: test/le_stese_del_cerchio_test.dart
MISURA: stese da 3 a 5, posizioni da 3 a 17, posti sul tavolo dichiarati da 0 a 25; la stesa a tre carte legge ancora le sue 3 posizioni (26 usi nel codice e 34 nelle prove portati su `SpreadPosition.treCarte`)

`TarotSpreadType` porta per ogni stesa le posizioni nell'ordine di lettura, il posto sul tavolo di ogni carta (`PostoSulTavolo`, centro in larghezze di carta, e la carta di traverso) e la fonte per il Foglio delle Fonti. La croce di Dora e' una croce (consultante in basso, lato a sinistra, lato a destra, esito in alto), la Croce Celtica e' la figura di Waite (la seconda di traverso sulla prima, la terza sopra, la quarta sotto, la quinta dietro, la sesta davanti, il bastone a destra dal basso in alto). Il lato torna due volte nella croce: il posto lo dice l'indice. "Te stesso" e' `[Te stesso|Te stessa|Tu]`. Le stese nuove portano nomi con "Stesa" (Stesa a una Carta, Stesa a Croce, Stesa del Ferro di Cavallo, Stesa della Croce Celtica), come la regola di casa del titolo; nei selettori si leggono col nome corto e con la descrizione dell'ordine ("La carta sola", "La croce", "Il ferro di cavallo", "La Croce Celtica"). **Restano Coming soon** finche' non hanno il corpus e il tavolo a video.

**La prova della stesa da tre stese difendeva la regola vecchia** ed e' riscritta con la lapide (`stesa_tre_carte_test.dart`, cinque stese e solo quella a tre carte aperta). **Un buco di copertura trovato con la Regola B:** `stesa_tre_carte_test` diventava rossa sfasando le posizioni in `TarotSpread.draw`, ma restava verde sfasandole in `TarotSpread.dalMazzo`, che e' quella della schermata; la prova nuova guarda tutte e due.

IMMAGINI: `docs/preview/prima_dopo/fi_selettori_tipo_prima.png` e `fi_selettori_tipo_dopo.png`: la tendina delle stese per il Viandante, da tre voci a cinque.

ACCETTAZIONE: aprendo la Stesa di Tarocchi, nella tendina "Tipo di stesa" Mauro vede cinque voci, Una Carta, Tre Carte, Quattro Carte, Sette Carte e Dieci Carte, con "La carta sola", "Passato, Presente, Futuro", "La croce", "Il ferro di cavallo" e "La Croce Celtica" sotto; solo Tre Carte si sceglie, le altre portano il lucchetto con "Coming soon"; la stesa a tre carte si fa come prima.

## VOCE FI.06, FI.07, FI.08: LE QUATTRO CHIAVI (commit `740c20eb`, `9fd8f065`)

DOMANDA: "eliminerei quella di Caligo e inserirei tradizione e fonti reali" e "confermo che voglio la quarta"
PROVA: test/le_chiavi_e_la_matrice_dei_tarocchi_test.dart
MISURA: chiavi da 3 a 4, etichette col nome di una persona o di un Maestro da 2 a 0, chiavi che cambiano l'istruzione al modello da 0 a 3, righe che dichiarano la lettura di casa da 0 a 1

`ReadingKey` vive ora in `lib/core/tarot/la_chiave_di_lettura.dart` (i selettori la riesportano): Predittiva di Medora (Etteilla, anni 1780), Riflessione (Jodorowsky e Costa, La Voie du Tarot, 2004, non predittiva, nota etica invariata), Esoterica (Waite 1911 e l'Alba Dorata), Archetipica (Nichols e Pollack, 1980). La chiave entra nell'istruzione come voce prima dell'ultima riga (`chiave.voce`); **la Predittiva lascia l'istruzione identica a prima**, cosi' la stesa approvata non cambia di una parola; con la Riflessione "anche la carta del futuro si legge come una tendenza da riconoscere, mai come un annuncio". Quando il modello non risponde, sotto la domanda: "Questa è la lettura di casa, nella chiave Predittiva di Medora, non nella chiave Esoterica." (`stesa_lettura_di_casa`). Le due tradizioni con la virgola prima di "e" erano cadute sotto la regola della lingua: le opere stanno fra parentesi. Tre prove a video nuove in `la_stesa_interpreta_davvero_test.dart`: la voce arriva al modello, la riga c'e' senza modello con un'altra chiave, e non c'e' con la Predittiva.

IMMAGINI: `docs/preview/prima_dopo/fi_selettori_chiave_prima.png` ("Riflessione Jodorowsky" ed "Esoterica Caligo", Coming soon) e `fi_selettori_chiave_dopo.png` (Riflessione "Dall'Iniziato", Esoterica e Archetipica "Dall'Adepto").

ACCETTAZIONE: col piano Viandante la tendina "Chiave di lettura" mostra Predittiva di Medora scelta, Riflessione con la nota su Jodorowsky e il lucchetto "Dall'Iniziato", Esoterica e Archetipica col lucchetto "Dall'Adepto"; toccandone una si apre l'invito al piano. Con l'Adepto si scelgono tutte e quattro, e la lettura cambia voce; a telefono senza rete, con una chiave diversa dalla Predittiva, sotto la domanda compare la riga della lettura di casa.

## VOCE FI.32: LA MATRICE DEI TAROCCHI (commit `740c20eb`)

DOMANDA: "tabella ok"
PROVA: test/le_chiavi_e_la_matrice_dei_tarocchi_test.dart
MISURA: righe della matrice da 41 a 51; righe esistenti toccate (carte al giorno, stesa da dieci): 0

Le dieci righe nuove: Stesa a croce (dall'Iniziato), Ferro di cavallo (dall'Adepto), Chiave Riflessione (dall'Iniziato), Chiavi Esoterica e Archetipica (dall'Adepto), Mazzo di Marsiglia (dall'Iniziato), Mazzo Thoth (dall'Adepto), Stesa nella versione lunga (dall'Iniziato), Il ritorno della carta (dall'Adepto), Rileggere una stesa (dall'Illuminato), Card della stesa da condividere (a tutti). Si leggono con `PlanCatalog.apre`; `PlanCatalog.dalPiano` dice a video da quale piano si apre una voce. **Due difetti trovati e chiusi strada facendo:** la Lunga della stesa era chiusa per tutti, anche per chi la pagava (`bloccata: (d) => d.premium`, PROVENIENZA IGNOTA, introdotta dal commit `43ba034d` del 20 luglio 2026, prima degli ordini a lettere); la tendina scriveva "Coming soon" anche sulle voci che esistono e che il piano chiude, come la stesa da dieci per il Viandante (padre: ordine EX voce 02, commit `7a6bf8ba`, che ha chiuso la stesa da dieci per piano senza cambiare la scritta). Mazzi, ritorno della carta, rilettura e card stanno nella tabella come nell'app: visibili, Coming soon dove si usano.

ACCETTAZIONE: nella pagina dei piani Mauro legge le dieci righe nuove coi Sì e i No della sua tabella; nella stesa la Lunga si sceglie dall'Iniziato in su.

## VOCE FI.16: I CARTIGLI (misura, nessun commit di asset)

DOMANDA: "Misura la fascia dei due cartigli su TUTTE le definitive dei due mazzi"
PROVA: docs/collaudo/FI/cartigli.txt
MISURA: carte misurate da 4 a 156, carte con testo nei cartigli 0; un testo inciso a mano su una copia fa scostare da 263 a 1630 pixel

Metodo nel file: lo scarto pixel per pixel, in grigio, fra la fascia di ogni cartiglio e la stessa fascia della cornice vuota del mazzo, con i pixel oltre 40 livelli contati. La cornice e' montata identica sopra ogni carta, e su nessuna delle 156 un solo pixel si scosta di oltre 40.

## VOCE FI.13: IL PESO DEI DUE MAZZI (misura, decisione del fondatore)

Il comando e i numeri stanno in `docs/collaudo/FI/peso_dei_mazzi.txt`: **54.871.350 byte, 54,9 MB in base 1000 e 52,3 MiB in base 1024** (Marsiglia 23.486.770 piu' 3.524.306 di miniature, Thoth 24.695.910 piu' 3.164.364). La cartella assets passerebbe da 151.736.466 byte a circa 206,6 MB, l'archivio della 2305 da 260.267.304 byte a circa 315 MB. **La crescita cambia la decisione, e la domanda e' girata a Mauro:** i due mazzi dentro l'app come il Rider-Waite, oppure sul bucket con CDN e scaricati alla prima scelta del mazzo, come i briefing prevedono per le famiglie grafiche.

## VOCE FI.26, FI.27, FI.28, FI.41: LA STESA SI CONSERVA (commit `12569ac9`)

DOMANDA: "il tuo suggerimento", cioe' la via che conserva
PROVA: test/la_stesa_si_conserva_test.dart
MISURA: rientri con la stessa domanda che ritrovano le stesse carte da 0 a 1 su 1; carte spese per rileggere la stesa conservata da 3 a 0; innesti che fanno cadere la guardia 2 su 2

`LaStesaConservata` (chiave `tarot.stesa_conservata`) conserva per la giornata, quando il responso si apre e si paga, la stesa compiuta con la sua firma: il tipo di stesa e la domanda (scritta senza maiuscole, spazi doppi e punteggiatura finale; senza domanda scritta, l'argomento). Chi riapre la stessa stesa con la stessa domanda, finche' non ha preso una carta, ritrova le carte gia' posate e la riga di Medora "Su questa domanda le carte hanno già parlato oggi: sono le stesse di prima."; rileggerla non spende carte. Il motore del mescolamento non e' toccato: taglio, mescolamento e scuotimento restano vivi dentro la stesa in corso. La memoria sta fra cio' che e' tuo, nello scarico dei dati e fra le memorie custodite, come il presagio delle rune. La guardia monta l'app dall'avvio vero coi servizi offline, apre la stesa dalla rotta di produzione senza seme, pesca, apre il responso, esce e rientra: "prima [Tre di Spade (rovescia), Sei di Bastoni, La Torre (rovescia)], dopo il rientro [lo stesso]"; rossa con la ricerca spenta e con la conservazione spenta.

ACCETTAZIONE: Mauro fa una stesa a tre carte su una domanda, apre il responso, esce e rientra con la stessa domanda: le tre carte sono gia' posate e sono le stesse, con la riga di Medora sopra il pulsante; il responso si riapre senza spendere carte. Con una domanda diversa la stesa e' nuova; il giorno dopo, con la stessa domanda, anche.

## LA SEGNALAZIONE DELL'11 OTTOBRE: IL MAZZO NEL RIQUADRO (commit `02fb1c02`)

DOMANDA: "quando faccio "taglia" o "mischia" il mazzo esce dal riquadro dell'animazione mentre dovrebbe stare al centro"
PROVA: test/il_mazzo_resta_nel_riquadro_test.dart
MISURA: punti di carta fuori dal bordo alto del riquadro nel taglio da 17 a 0; scarto del mazzo dal centro della fascia da 25 punti a meno di 2

La fascia del ventaglio e' alta una carta piu' 34 punti, e il mazzo si componeva a -8, cioe' sopra il suo bordo alto; nel taglio la meta' di sopra saliva di altri 26 punti e il ritaglio la mangiava. Adesso il mazzo sta al centro della fascia e la meta' di sopra sale di 14 (`kSaliteDelTaglio`). **Padre: ordine H, commit `809d0c5d` dell'11 agosto 2026** ("Le sedici anteprime dell'ordine H"), trovato con `git log -S`. **Il messaggio del commit `02fb1c02` attribuisce il difetto all'ordine P voce 05: e' sbagliato**, scritto prima di cercare; il padre giusto e' questo.

IMMAGINI: confronto a meta' taglio e a meta' mescolamento, prima e dopo, reso in prova (le carte col solo bordo, senza i dorsi): prima la meta' destra del taglio e il mazzo mescolato hanno la cima tagliata, dopo stanno interi al centro del riquadro.

ACCETTAZIONE: toccando "Taglia" il mazzo si divide in due blocchi che restano interi dentro la fascia del ventaglio; toccando "Mischia" il mazzo si mescola al centro della fascia, senza la cima tagliata.

## REGOLA B, LE ZONE TOCCATE

- `stesa_tre_carte_test`: rossa con le posizioni sfasate in `TarotSpread.draw`, prima di toccare le posizioni (verde su `dalMazzo`: il buco detto sopra).
- `la_stesa_interpreta_davvero_test`: rossa col conto delle posizioni sfasato, prima di toccarlo.
- **`le_etichette_non_fanno_da_chiave_test`: vista rossa con una chiave ripetuta nella matrice DOPO aver toccato la matrice, non prima.** Confessato: la Regola B e' stata rispettata in ritardo.

## REGOLA A, LE GUARDIE NUOVE

`la_stesa_si_conserva_test` (rossa con la ricerca della stesa conservata spenta e con la conservazione spenta) e `il_mazzo_resta_nel_riquadro_test` (rossa con la quota vecchia del mazzo e con la salita vecchia del taglio): ogni innesto entrato verificato col grep e il file ripristinato al byte. Registro delle guardie da 735 a 737.

## LE ROSSE CHE NON SONO DIFETTI

Nel worktree di lavoro, coi fine riga CRLF, due prove cadono e nella copia in LF passano: `online_nella_barra_e_gli_eventi_nel_passport_test` e `la_televisione_non_tiene_aperta_la_frase_test`, provate sul commit di partenza, sull'ultimo commit FI e coi file della parte 6, sempre verdi in LF. `niente_lavoro_non_spinto_test` cade finche' il lavoro non e' spinto.
