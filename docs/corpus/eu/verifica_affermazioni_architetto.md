# La verifica delle 88 affermazioni senza fonte

Aggiornata il 2 ottobre 2026: O-M-006, V-M-001 e C-G-069 senza la virgola prima della "e".

L'Architetto, 2 ottobre 2026. Risponde a `docs/collaudo/EU/affermazioni.md` (ordine EU, voce 14). Ogni riga dice l'esito e, dove serve, il testo nuovo da mettere al posto del vecchio, carattere per carattere. Le sigle sono quelle del file di Code.

Esiti:
- **CALCOLO**: la frase dice un fatto calcolato dall'app ed è detta bene; resta com'è e non ha bisogno di una fonte della tradizione.
- **FONTE**: la frase è vera; la fonte qui accanto va scritta nella nota del suo caso, nel corpus o nel commento del codice.
- **SCELTA**: la frase dice una regola dell'app; resta, col testo nuovo che lo dichiara.
- **NUOVO TESTO**: la frase si sostituisce col testo indicato.

## Occidentale

- O-G-003: CALCOLO. La soglia dei due gradi è una scelta dell'app: la dichiara la nota O-M-006 nuova.
- O-G-004: CALCOLO. Le case solari sono la pratica moderna per chi non ha l'ora di nascita: lo dichiara la nota O-M-004 nuova.
- O-G-005: FONTE. Gli aspetti fra segni (stesso segno, sestile, quadratura, trigono, opposizione) sono quelli di Tolomeo, Tetrabiblos, libro I, cap. 13.
- O-G-006, O-G-007: FONTE. Giorno personale e giorno universale della numerologia moderna (Florence Campbell, Your Days Are Numbered, 1931).
- O-S-001, O-S-002, O-S-003, O-S-004, O-S-006, O-S-007, O-S-008, O-S-009, O-S-010, O-S-011, O-S-012, O-S-013: CALCOLO.
- O-A-003: FONTE. Le case angolari, succedenti e cadenti e la forza delle angolari sono di William Lilly, Christian Astrology (1647), libro I, le dignità accidentali. Il passaggio dalla casa al livello è una regola dell'app: la nota dell'anno lo dice già.
- O-A-008, O-A-009, O-A-010, O-A-011: CALCOLO.
- O-M-001: NUOVO TESTO: "Il titolo e il testo sono scelti fra le letture di Medora per il livello di oggi: favorevole, in equilibrio o in salita."
- O-M-002: NUOVO TESTO: "Il livello viene dai transiti di oggi sulla tua carta natale, calcolati sul telefono dalle effemeridi: i pianeti che passano sui tuoi pianeti di nascita e nelle tue case."
- O-M-003: NUOVO TESTO: "Il livello viene dai transiti di oggi sui tuoi pianeti di nascita, calcolati sul telefono dalle effemeridi. Senza l'ora di nascita le case non si calcolano."
- O-M-004: NUOVO TESTO: "Senza ora e luogo di nascita non c'è una carta: il livello viene dalla Luna di oggi e dal pianeta di questo campo, con le case solari contate dal tuo segno, come fa l'astrologia moderna per chi non ha l'ora di nascita."
- O-M-005: NUOVO TESTO: "Il livello da due a cinque viene dalla Luna di oggi e dal pianeta di questo campo: dal segno in cui si trovano rispetto al tuo e dalle case solari che attraversano. Tre vuol dire un giorno neutro. È una regola dell'app costruita sugli aspetti fra segni di Tolomeo."
- O-M-006: NUOVO TESTO: "Il livello da due a cinque viene dai passaggi di oggi che parlano a questo campo, entro due gradi: quelli armonici lo alzano e quelli tesi lo abbassano; contano di più quanto sono stretti. È una regola dell'app costruita sugli aspetti di Tolomeo."
- O-M-007: NUOVO TESTO: "Il numero è il giorno personale della numerologia moderna, dalla tua data di nascita e da quella di oggi."
- O-M-012: CALCOLO.
- O-M-013: SCELTA, già dichiarata dalla frase.

## Vedica

- V-G-003: FONTE. La settima casa dell'unione: Brihat Parashara Hora Shastra, cap. 11; la quinta come cuore è la lettura moderna dichiarata da V-M-008.
- V-G-089, V-G-090, V-G-091: FONTE. La Luna in quinta dalla Luna di nascita non è fra le posizioni buone del gochara: Phaladeepika, cap. 26; Brihat Samhita, cap. 104. La quinta come cuore è la lettura moderna dichiarata da V-M-008.
- V-G-095, V-G-096, V-G-097: FONTE. La Luna in undicesima è fra le posizioni buone del gochara (Phaladeepika, cap. 26); ogni pianeta guarda per intero la settima casa da sé, quindi dall'undicesima guarda la quinta (Brihat Parashara Hora Shastra, cap. 26).
- V-S-001, V-S-002: CALCOLO. Il difetto della parola "oggi" sotto la data di un altro giorno resta da correggere (ordine EV).
- V-A-005: FONTE, come V-M-011 nuova.
- V-M-001: NUOVO TESTO: "La Luna di oggi è siderale, con l'ayanamsa di Lahiri, quella adottata dal governo indiano nel 1955; il giorno si legge all'alba del luogo, come nei Panchang."
- V-M-004: NUOVO TESTO: "Senza l'ora di nascita la tua stella di nascita può non essere certa, perché la Luna cambia stella circa una volta al giorno: per questo la Tara Bala non si calcola."
- V-M-008: SCELTA, già dichiarata dalla frase.
- V-M-009: NUOVO TESTO: "L'anno va da compleanno a compleanno: è una scelta dell'app, che guarda Giove e Saturno nel giorno del tuo compleanno."
- V-M-011: NUOVO TESTO: "La Sade Sati, i sette anni e mezzo di Saturno nella dodicesima, nella prima e nella seconda casa dalla Luna di nascita, è una lettura della tradizione indiana costruita sul gochara: per la Phaladeepika, cap. 26, Saturno dà frutti buoni solo in 3, 6 e 11."

## Cinese

- C-G-009, C-G-043: CALCOLO.
- C-G-068: NUOVO TESTO: "Oggi è il giorno di {animale_giorno}, il tuo stesso animale: ritorna ogni dodici giorni." Motivo: "i rami uguali si rafforzano" non ha fonte. Per il Drago, il Cavallo, il Gallo e il Maiale lo stesso animale è già la punizione di sé nel codice (`l_almanacco_cinese.dart`) e questa frase per loro non esce.
- C-G-069: NUOVO TESTO: "Il ramo di oggi è il tuo: torna ogni dodici giorni; per il tuo animale non è uno dei rapporti che la tradizione classifica."
- C-G-070: FONTE. I rapporti classificati fra i rami (armonia, tripla armonia, scontro, punizione, danno) sono quelli del Sanming Tonghui di Wan Minying (1578).
- Da C-G-232 a C-G-261: FONTE. Le definizioni dei Dieci Dei sono esatte. Per il Compagno e il Rivale come fratelli, amici e pari, la Ricchezza diretta come la moglie per un uomo e l'Ufficiale diretto come il marito per una donna: Shen Xiaozhan, Ziping Zhenquan (XVIII secolo), i capitoli sui dieci dei e sui sei parenti; Xu Dasheng, Yuanhai Ziping (dinastia Song).
- C-S-001, C-S-002: CALCOLO. Il difetto della parola "oggi" sotto la data di un altro giorno resta da correggere (ordine EV).
- C-A-001: CALCOLO.
- C-A-003, C-A-004: FONTE. Il Tai Sui e le relazioni che lo offendono (stesso animale, scontro, punizione, danno, rottura) sono quelli degli almanacchi annuali cinesi (Tong Shu).
- C-M-006: NUOVO TESTO: "L'anno cinese va da Capodanno lunare a Capodanno lunare, come nello zodiaco popolare; il BaZi lo fa cominciare invece a Lichun, l'inizio della primavera."
- C-M-008: NUOVO TESTO: "il Tai Sui e le cinque relazioni che lo offendono (stesso animale, scontro, punizione, danno, rottura) vengono dagli almanacchi annuali cinesi, il Tong Shu."

## Le altre note del metodo superate

- C-M-002: NUOVO TESTO: "Il guardiano del giorno è uno dei dodici del calendario, contato dal mese solare."
- C-M-004: NUOVO TESTO: "La scheda prende il livello da quel dio come lo leggono lo Yuanhai Ziping e il Ziping Zhenquan; il testo è scelto per quel livello."

## Le righe scritte da Code nell'ordine EU (rapporto EU, "Per l'Architetto", punto 8)

Lette e approvate così come sono: la riga dell'anno vedico (Giove e Saturno dalla Luna di nascita al compleanno, con le case favorevoli della Phaladeepika, cap. 26), la riga dell'anno cinese col Tai Sui, le due note del metodo dell'anno (con V-M-009, V-M-011, C-M-006 e C-M-008 nuove qui sopra), la riga "il giorno migliore, ...:" della Settimana e del Mese vedici e cinesi, la riga "Il colore è quello del Sole". Da oggi sono materiale dell'Architetto.

## Le altre decisioni

- Il colore vedico del venerdì: "screziato", nel "Da dove viene" e nella riga della Fortuna (Brihat Jataka, cap. 2: il colore di Venere è variegato).
- La variante del Rahu Kalam senza l'ora: NUOVO TESTO: "Siamo dentro il Rahu Kalam di oggi, dalle {inizio} alle {fine}."
- La riga della ruota che ripete il primo passaggio di "Da dove viene": NUOVO TESTO: "Guardalo sulla tua carta, nella tua {ordinale} casa."
- Due giorni migliori di fila con lo stesso "Da dove viene": il secondo dice "Da dove viene: lo stesso passaggio di {giorno della settimana} {data}."
