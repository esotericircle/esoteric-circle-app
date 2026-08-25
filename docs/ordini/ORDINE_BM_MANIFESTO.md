# ORDINE BM, I CARATTERI CHE NON CI SONO E IL ROSSO DEI PIANI

Ordine del fondatore del 25 agosto 2026. Vale il mandato esteso di BF. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bm_guard_test.dart`.

## Le parole del fondatore, e il vincolo che pongono

"sono stanco di fare 3 giri di code per una revisione. bisogna fare e finire
una revisione con 1 giro". Quindi cio' che la ricognizione trova si cura qui,
e non apre un ordine successivo.

## Le premesse, verificate sulla testa a5a1c8a

- **P1 VERA**: il `pubspec.yaml` dichiarava DUE sole famiglie, Cinzel ed
  EBGaramond, e in `assets/fonts` vivevano tre file, i due `.ttf` e
  `OFL_NOTICE.txt`.
- **P2 VERA**: il codice ne citava TRE: Cinzel, NotoSansSymbols e
  CormorantGaramond.
- **P3 VERA NELLA SOSTANZA, precisata nel numero**: i punti di CODICE che
  citano `NotoSansSymbols` sono **due**, `natal_wheel.dart:392` e
  `natal_chart_reveal.dart:381`, tutti e due nominati dall'ordine. Il terzo
  che il grep trova, `natal_chart.dart:125`, e' un commento di
  documentazione, non codice.
- **P4 VERA**: `CormorantGaramond` e' citata in un punto solo,
  `sigillo_intenzione_screen.dart:604`.
- **P5 VERA**: `natal_chart_reveal.dart` disegna il Sole con un
  `CustomPainter` dichiarando che il glifo non e' nel font dei simboli.
- **P6 VERA**: il buco e' solo sui caratteri, non sugli asset immagine.

## BM.00, LA RICOGNIZIONE

**Le famiglie citate contro quelle dichiarate.** Citate dal codice: Cinzel
(dichiarata), EBGaramond (dichiarata, anche come ripiego in `natal_wheel`),
NotoSansSymbols (NON dichiarata, curata da BM.01), CormorantGaramond (NON
dichiarata, in attesa di decisione con BM.02). `sky_postcard.dart` passa la
famiglia per posizione a un suo aiutante, e i valori veri sono Cinzel ed
EBGaramond: nessun fantasma li'.

**I glifi che passano davvero alla famiglia dei simboli, uno per uno.** Sono
**venticinque**, e il censimento a occhio ne avrebbe mancati tre:
- i **dodici** segni zodiacali, da `Zodiac.values` (`natal_wheel:216` e
  `natal_chart_reveal:344`);
- i **dieci** corpi celesti, da `CorpoCeleste.values` (`natal_wheel:403` e
  `natal_chart_reveal:341`);
- **tre punti in piu' che nessuno aveva censito**, e che escono dal client di
  FreeAstroAPI (`free_astro_client.dart`, tabella `_planetIt`): il Nodo Nord
  ☊, Chirone ⚷ e Lilith ⚸. Arrivano da fuori, finiscono in
  `PlanetPosition.glyph` e vanno diritti nella ruota natale.

**Quali di questi il carattere ha davvero**, misurato sui file scaricati da
Google Fonts:

| famiglia | segni (12) | corpi (10) | punti extra (3) |
|---|---|---|---|
| Noto Sans Symbols, 179,3 KB | **12** | 9, manca ☉ | **3** |
| Noto Sans Symbols 2, 1,2 MB | 0 | 1, il solo ☉ | 0 |

Il Sole (U+2609) **non c'e' nel font intero**, quindi la dichiarazione che il
progetto portava da tempo ("il glifo del Sole non e' nel font simboli") era
vera, e adesso e' misurata. Symbols 2 lo avrebbe, ma pesa 1,2 MB e di utile
porterebbe quel solo glifo: non entra, e il Sole resta disegnato a mano nei
due punti che gia' lo disegnavano.

**Altri asset dichiarati e mancanti nel dominio della ruota e del cielo**:
nessuno. Il buco era solo sui caratteri.

**I rossi della suite con `TZ=Europe/Rome`**: vedi BM.04 e la coda in fondo.

## Le voci

- **BM.00** La ricognizione. CHIUSA: questo capitolo.
- **BM.01** Il carattere dei simboli astronomici. CHIUSA: Noto Sans Symbols e' entrato in `assets/fonts/NotoSansSymbols-subset.ttf` ed e' dichiarato nel `pubspec.yaml`; `OFL_NOTICE.txt` porta la sua riga di licenza, la nota sul sottoinsieme e il motivo per cui il Sole non c'e'. **PESO**: il font intero pesa 179,3 KB, ridotto ai 24 glifi che l'app passa davvero pesa **5,1 KB**, cioe' il **97,1 per cento in meno**; verificato dopo il taglio che nessuno dei 24 sia andato perduto. **MISURA CHE CHIUDE**: caricato il carattere dal file DICHIARATO NEL PUBSPEC e non da un percorso battuto nella prova, tutti e **24** i glifi hanno larghezza maggiore di zero e **nessuno** ha la larghezza del ripiego, cioe' zero rettangoli vuoti. La prova elenca i glifi dal codice (`Zodiac.values`, `CorpoCeleste.values` e la tabella del client letta dal sorgente), quindi un glifo nuovo domani entra da solo. **Rosso dimostrato**: tolta la famiglia dal pubspec e verificata l'assenza PRIMA di leggere l'esito, cadono due prove, quella della famiglia fantasma e quella del file dichiarato.
- **BM.02** Il carattere del Sigillo d'Intenzione. FERMATA IN ATTESA DI DECISIONE: le tre anteprime sono prodotte a 360 punti logici, identiche in tutto tranne il carattere, e consegnate al fondatore. Le lettere in questione sono le ventuno dell'alfabeto italiano disposte attorno alla ruota, cioe' la parte identitaria della scena. **COSTO di (c)**: `CormorantGaramond` intero pesa 283,4 KB, ridotto alle ventuno lettere della ruota pesa **6,7 KB**, il 97,7 per cento in meno, con lo stesso metodo usato per i simboli in BM.01. **UN LIMITE DELL'ANTEPRIMA (a), DICHIARATO**: in prova, senza carattere caricato, Flutter ripiega su un font di collaudo che rende ogni lettera come un rettangolo pieno, e infatti nella (a) si vedono quadratini gialli. Non e' cio' che il fondatore vede sul telefono: li' il ripiego e' il carattere di SISTEMA, che su iOS e su Android e' diverso e in nessuno dei due e' un Garamond. La (a) quindi non serve a giudicare la bellezza di oggi, serve a mostrare che oggi quel testo non ha un carattere del progetto: e' il telefono a sceglierlo. Le due immagini fedeli sono la (b) e la (c). Nessun file e' stato portato dentro e il codice non e' stato toccato: le tre anteprime si sono ottenute caricando file diversi sotto lo stesso nome di famiglia.
- **BM.03** La guardia contro il prossimo carattere fantasma. CHIUSA: `test/i_caratteri_dichiarati_esistono_test.dart` enumera `lib` e pretende che ogni famiglia citata sia dichiarata nel pubspec. Strutturale apposta: cade in qualunque ambiente e non dipende dal dispositivo, come la guardia del tempo civile di BL, perche' un carattere che manca non fa rumore da nessuna parte e si vede soltanto, e solo su certi telefoni. **La prova del rosso ha trovato un buco nella prova stessa, e l'ha fatto cambiare**: la prima stesura guardava solo `fontFamily:` e `family:` scritti per nome, e iniettando un carattere inventato in `sky_postcard.dart`, che passa la famiglia come argomento POSIZIONALE, restava verde. Cambiata la grandezza misurata e non la soglia: adesso cerca anche le funzioni che dichiarano un parametro `String family` e guarda i letterali delle loro chiamate, tenendo solo quelli che somigliano a un nome di carattere. Con l'iniezione ripetuta la guardia cade nominando file e funzione. Una sola eccezione, DICHIARATA nel codice della prova con la sua ragione e la sua scadenza: `CormorantGaramond`, in attesa della decisione del fondatore su BM.02.
- **BM.04** Il rosso di `i_piani_del_cielo_si_muovono`. CHIUSA: **il difetto era nella prova, e il codice e' stato dimostrato sano prima di dirlo.** Delle due misure del file cade la seconda, e non sullo spostamento: cade sulla riga che pretende che il piano vicino dipinga almeno un pixel riconoscibile. La causa e' la maschera cromatica del vicino, portata dall'ordine AM voce 02 a `r > 150 && r - b > 60`: **due soglie che nella scena vera nessun pixel raggiunge**. Misurato sull'immagine dipinta davvero, 400 per 800 punti senza pianeti: i pixel piu' caldi hanno **r fra 98 e 148** e scarto rosso-blu **fra 27 e 30**, col massimo assoluto di scarto a **43**; l'intera scena porta **62** pixel con scarto oltre 10 e **zero** oltre 45. La ragione e' aritmetica: le particelle si dipingono con `goldSoft` (240, 215, 123) a mezza opacita' su un fondo dove il blu domina, quindi il rosso composto non arriva a 150 e lo scarto non arriva a 60. Il piano dunque dipinge, e la prova era diventata cieca. Maschera portata a `r > 90 && r - b > 25`, che viene dalla misura e non da una stima: sta sopra gli aloni del fondo, che a 0,22 di opacita' restano sotto lo scarto di 25, e prende i **29** pixel che quattordici cerchietti da uno o due punti possono dipingere. Con la maschera curata la prova e' verde, e il piano medio si sposta di 28 punti contro i 30 attesi, dentro la tolleranza di 2 che il file gia' dichiarava. **Rosso dimostrato**: rimessa la maschera irraggiungibile, la prova torna a dire che il piano vicino e' sparito dalla scena.

MARCATORI, per la guardia:
VOCI_TOTALI: 5
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 4
