# RAPPORTO DELL'ORDINE FH, REAL TIME COSMO, LA PROFONDITA'

**Il cielo vero adesso ha profondita'.** Un velo solo alla volta, piu' leggero, con le linee delle figure e il peso della loro brillantezza. Un indicatore unico col suo menu. Il cielo di adesso parte dalla Luna, che ha il suo volto vero. Un orizzonte che si attraversa, la Via Lattea, cinque oggetti del cielo profondo con le loro schede, l'aria che indebolisce le stelle basse, le stelle cadenti degli sciami, l'eclittica. Il ritorno ha due tempi e la marca del genere. Dentro l'ordine e' arrivata l'aggiunta della **Macchina del tempo e della Luna protagonista**: un giorno qualunque fra il 1900 e il 2100, indietro o avanti, col pulsante che fa partire la corsa.

Ramo di lavoro `fg-verifica-premesse`, spinto su `claude/esoteric-circle-master-order-e798aj`. Partenza `1f63c0a4`, 9-10 ottobre 2026. Testo: `docs/ordini/ORDINE_FH_TESTO.md` con la risposta del fondatore alla fermata; aggiunta in `docs/ordini/ORDINE_FH_AGGIUNTA_MACCHINA_DEL_TEMPO_E_LUNA.md` (seconda stesura, che sostituisce `ORDINE_FH_AGGIUNTA_MACCHINA_DEL_TEMPO.md`).

**Stima dichiarata all'inizio** (C2): 28-32 ore, ridichiarata dopo la parte 4 senza cambi. Per l'aggiunta: 9-11 ore dichiarate alla fermata, poi la seconda stesura ha aggiunto la sezione della Luna.

## LE VOCI E LA LORO PROVA, IN TRENTA SECONDI

| voce | stato | prova |
| --- | --- | --- |
| parte 0, i file da fuori del ramo | CHIUSA | `test/real_time_cosmo_ogni_asset_ha_il_suo_file_test.dart` |
| parte 1, un velo alla volta | CHIUSA | `test/real_time_cosmo_un_velo_solo_test.dart`, `docs/preview/FH/fh_02_il_cielo_di_adesso_a_sud.png` |
| parte 2, il velo si alleggerisce | CHIUSA | `docs/preview/FH/fh_03_il_cielo_verso_est.png` |
| parte 3, le linee delle figure | CHIUSA | `test/real_time_cosmo_nessuna_linea_inventata_test.dart` |
| parte 4, il peso secondo la brillantezza | CHIUSA | `test/real_time_cosmo_il_peso_segue_il_dato_test.dart` |
| parte 5, l'indicatore unico col menu | CHIUSA | `docs/preview/FH/fh_05_il_menu_le_categorie.png`, `test/real_time_cosmo_il_sole_porta_il_suo_avviso_test.dart` |
| parte 6, il cielo di adesso parte dalla Luna | CHIUSA | `docs/preview/FH/fh_10_la_luna_non_c_e.png`, `fh_11_la_vista_parte_dalla_luna.png` |
| parte 7, l'orizzonte che si attraversa | CHIUSA | `docs/preview/FH/fh_12_lo_skyline.png`, `fh_13_attraverso_il_terreno.png`, `fh_22_la_scheda_sotto_l_orizzonte.png` |
| parte 8, il ritorno a due tempi | CHIUSA | `test/real_time_cosmo_il_riavvolgimento_test.dart`, `docs/preview/FH/fh_14_il_rallentamento.png` |
| parte 8, aggiunta del fondatore (anni e data) | CHIUSA | `docs/preview/FH/fh_16_la_corsa_con_la_data.png` |
| parte 9, la Via Lattea | CHIUSA | `test/real_time_cosmo_la_via_lattea_test.dart`, `docs/preview/FH/fh_02_il_cielo_di_adesso_a_sud.png` |
| parte 10, il cielo profondo | CHIUSA | `test/real_time_cosmo_le_schede_non_vengono_dal_modello_test.dart`, `docs/preview/FH/fh_18_la_scheda_del_cielo_profondo.png` |
| parte 11, l'aria fra noi e le stelle | CHIUSA | `test/real_time_cosmo_l_aria_test.dart`, `docs/preview/FH/fh_12_lo_skyline.png` |
| parte 12, le stelle cadenti | CHIUSA | `test/real_time_cosmo_le_stelle_cadenti_test.dart`, `docs/preview/FH/fh_19_una_stella_cadente.png` |
| parte 13, l'eclittica | CHIUSA | `test/real_time_cosmo_l_eclittica_test.dart`, `docs/preview/FH/fh_20_l_eclittica.png` |
| parte 14, i due difetti dalla FG | CHIUSA | `test/real_time_cosmo_la_scritta_cede_il_posto_test.dart`, `docs/preview/FG/fg_07_il_ritorno_l_arrivo.png` |
| parte 15, guardie e prove di vista | CHIUSA | `docs/collaudo/FH/prove_di_vista.txt` |
| aggiunta, la Macchina del tempo | APERTA IN ATTESA DI VERIFICA | `docs/collaudo/FH/aggiunta_i03_il_pannello_con_la_nascita.png`; manca la misura C5 sul Realme |

Le voci si dicono chiuse sulle prove e sulle anteprime a 360 per 797 punti logici. **Nessuna e' stata collaudata sul telefono dal fondatore**: la build la ordina lui (C6). Una build di prova, autorizzata per la Macchina del tempo, e' sul Realme dal commit `a0d2dded`.

## PARTE 0, I FILE DA FUORI DEL RAMO (commit `d1351e40`)

DOMANDA: "consegna dell'Architetto del 9 ottobre 2026" (i dieci asset del cosmo, le linee delle figure, il corpus delle schede)
PROVA: test/real_time_cosmo_ogni_asset_ha_il_suo_file_test.dart
MISURA: file copiati al byte: 0 prima, 13 dopo (dieci asset per 802.958 byte, le linee con 24 figure, 187 coppie e 193 stelle HIP tutte nel catalogo, il corpus di 6.789 byte)

IMMAGINI: nessuna, la parte non ha schermo.
ACCETTAZIONE: nessuna verifica sul telefono.

## PARTI 1 E 2, UN VELO ALLA VOLTA E PIU' LEGGERO (commit `a4cd7bc7`)

DOMANDA: "l'emblema dovrebbe comparire quando si inquadra la costellazione, che attualmente non si vede perche' completamente coperta dall'emblema"; "l'emblema dovrebbe essere piu' evanescente, semi trasparente"
PROVA: test/real_time_cosmo_un_velo_solo_test.dart
MISURA: veli disegnati insieme, al piu' 1 su 360 fotogrammi di spazzata (5 veli diversi accesi); alfa media dei pixel visibili dei dodici veli da 101,7 a 62,0

Si accende solo il velo della costellazione il cui centro e' piu' vicino all'asse della camera, con isteresi di cinque gradi. Il cambio e' una dissolvenza in uscita seguita da una in entrata, quindi in nessun fotogramma i veli sono due. La velatura nuova (0,42 e pavimento 0,26) si applica a runtime sull'asset, in un isolato, coi byte premoltiplicati; la scala passa da 1,25 a 1,05.
IMMAGINI: prima `docs/preview/FG/fg_02`, `fg_03`; dopo `docs/preview/FH/fh_02`, `fh_03`.
ACCETTAZIONE: Real Time Cosmo, Il cielo di adesso; muovi il telefono da un segno all'altro: si accende un emblema solo, leggero, e le stelle sotto si vedono.

## PARTE 3, LE LINEE DELLE FIGURE (commit `7da0dadb`)

DOMANDA: "le costellazioni riconoscibili grazie alle linee che uniscono le stelle; linee scritte dall'Architetto"
PROVA: test/real_time_cosmo_nessuna_linea_inventata_test.dart
MISURA: coppie disegnate: 0 prima, 187 su 187 dopo, su 72 direzioni; una chiamata di disegno per fotogramma

Mappa da HIP a indice prodotta dal generatore, col binario identico al byte (fatto 1). Spessore 2,0 per la figura del velo e 1,2 per le altre, nella stessa chiamata. La guardia 7.5 e' riscritta sulla provenienza: si disegnano solo le 187 coppie del file (fatto 4).
IMMAGINI: prima `fg_02`, dopo `fh_02`.
ACCETTAZIONE: le figure dorate dei segni hanno le loro linee; nessuna linea fuori dalle 24 figure.

## PARTE 4, IL PESO SECONDO LA BRILLANTEZZA VERA (commit `32ac42cd`)

DOMANDA: "le costellazioni sembrano messe in fila"
PROVA: test/real_time_cosmo_il_peso_segue_il_dato_test.dart
MISURA: forza dello Scorpione 1,00, del Leone 0,83, del Cancro 0,35 (prima tutte 1)

Forza uguale alla radice del conto delle stelle della figura fino alla quarta magnitudine, diviso il conto della figura piu' ricca, cioe' lo Scorpione con 16; il numero viene dal file (fatto 2). Il segno della persona non scende mai sotto 0,70.
IMMAGINI: prima `fh_02` al commit `7da0dadb`, dopo `fh_02`.
ACCETTAZIONE: lo Scorpione e il Leone si vedono piu' forti del Cancro e dei Pesci.

## PARTE 5, L'INDICATORE UNICO COL MENU (commit `a63f4ba5`)

DOMANDA: "non vorrei cento frecce come indicatori, basta un indicatore che se ci fai click puoi scegliere dove deve puntare"
PROVA: test/real_time_cosmo_il_sole_porta_il_suo_avviso_test.dart
MISURA: indicatori a schermo, da 1 freccia fissa sul segno a 1 indicatore col menu di 5 categorie (24 costellazioni, 5 oggetti profondi)

La scelta automatica punta al piu' alto sopra l'orizzonte o al primo che sorge, e lo dichiara. Sotto l'orizzonte l'indicatore dice l'ora in cui sorge, con la regola unica `primoIstanteSopra`. Col Sole alto compare "Non guardare il Sole direttamente" prima della direzione.
IMMAGINI: prima `fg_03`, dopo `fh_05`, `fh_06`, `fh_07`, `fh_08`, `fh_09`.
ACCETTAZIONE: tocca la scritta dell'indicatore: si apre il menu, scegli Nebulose e galassie, poi le Pleiadi; l'indicatore punta li'.

## PARTE 6, IL CIELO DI ADESSO PARTE DALLA LUNA (commit `64816897`)

DOMANDA: "il cielo sopra di te adesso secondo me dovrebbe partire centrato sulla luna, e' l'unico elemento che cambia perche' ha le fasi ed e' un effetto wow"
PROVA: docs/preview/FH/fh_11_la_vista_parte_dalla_luna.png
MISURA: il 20 ottobre 2026 alle 18 UTC la vista parte dalla Luna (prima da sud a 40 gradi); l'8 ottobre alle 20 UTC, con la Luna sotto l'orizzonte, parte da Vega e dice che la Luna sorge alle 05:33

La Luna si disegna col suo asset attraverso LunaReale, senza eccezioni alla guardia una_luna_sola (fatto 4).
IMMAGINI: prima `fg_02`, dopo `fh_10`, `fh_11`.
ACCETTAZIONE: apri Il cielo di adesso: la vista e' sulla Luna, o sull'astro piu' brillante con la riga che dice quando la Luna sorge.

## PARTE 7, L'ORIZZONTE CHE SI ATTRAVERSA (commit `78c5117a`)

DOMANDA: "la funzione e' a 360 gradi e la Luna si deve poter trovare passando oltre l'orizzonte"
PROVA: docs/preview/FH/fh_22_la_scheda_sotto_l_orizzonte.png
MISURA: opacita' del terreno 1,00 con lo sguardo all'orizzonte, 0,55 da venti gradi sotto in giu' (prima la terra non c'era e il cielo sotto valeva 0,32); la scheda di kappa Virginis, 28 gradi sotto l'orizzonte, dice "sorge alle 08:30"

La sagoma dell'asset e' avvolta sui 360 gradi, con colline fino a 3,6 gradi, e sotto c'e' la calotta nera. I punti cardinali stanno a cinque gradi, sopra lo skyline. Difetti trovati qui e curati: la densita' contava le stelle coperte dal terreno (236 punti; ora si conta la luce che arriva all'occhio: 191, 194, 211); il corredo trovava il rapporto di pixel non dichiarato nelle anteprime FH (padre: FH parte 1); l'anteprima del Sole trovava due "sorge alle" (padre: FH parte 6).
IMMAGINI: prima `fg_02`, dopo `fh_12`, `fh_13`, `fh_22`.
ACCETTAZIONE: abbassa il telefono sotto l'orizzonte: il terreno diventa un velo e dietro c'e' il cielo dall'altra parte della Terra; tocca una stella li': la scheda dice quando sorge.

## PARTE 8, IL RITORNO A DUE TEMPI, CON LA MARCA DEL GENERE (commit `60c62696`, aggiunta `037e43f2`)

DOMANDA: "la Luna che cambia le fasi mentre il cosmo gira"; "Non basto il numero degli anni, ma bisogna scrivere anche la parola anni a fianco il numero [...] sotto inserirei la data odierna"
PROVA: test/real_time_cosmo_il_riavvolgimento_test.dart
MISURA: lunazioni mostrate nell'ultimo anno, da 24 compresse in 7 secondi a 12,36 in 8 secondi (al piu' 42 gradi di fase per istante); fase della corsa entro 6,68 gradi; a meta' corsa "34 anni" e "26 giugno 2022"

La corsa va fino a un anno prima della nascita, poi l'ultimo anno si percorre a giorni siderali interi, con le stelle ferme e la Luna agganciata al centro. La frase d'arrivo e' "QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI [NATO|NATA|VENUTO AL MONDO]". La stima della fase e' diventata a tratti (all'istante 98 la stima vecchia mancava il candidato migliore: 12,1 gradi dove se ne potevano avere 2,88; padre: FG parte 3). Il contatore copriva la Luna nel rallentamento (padre: questa parte, voce 8.4): curato, e dall'aggiunta il blocco sta al 72 per cento.
IMMAGINI: prima `fg_06`, `fg_07`; dopo `fh_14`, `fh_15`, `fh_16`.
ACCETTAZIONE: La macchina del tempo, Viaggia nel tempo con la tua nascita scelta: l'eta' con la parola "anni" e la data scendono insieme, poi l'ultimo anno lento con la Luna che cambia fase al centro.

## PARTE 9, LA VIA LATTEA (commit `06646faa`)

DOMANDA: "almeno la via Lattea inseriamola"
PROVA: test/real_time_cosmo_la_via_lattea_test.dart
MISURA: centro galattico a 266,40 e -28,94 gradi; scarto fra la rotazione e la porta del cielo 9,2e-8; prima la Via Lattea non c'era

Le stelle passano per la fenditura scura lungo il Cigno, come in cielo. Il taglio dell'asset a 45,5 gradi dal piano si spegne col colore dei vertici. Nell'asset restano due cuciture interne deboli, alle colonne 134 e 1320 (salti 3,73 e 4,39 contro una mediana di 1,95): le segnalo, non le ho toccate.
IMMAGINI: prima `fg_02`, dopo `fh_02`, `fh_10`.
ACCETTAZIONE: guarda verso il Cigno: la Via Lattea passa li', sotto le stelle.

## PARTE 10, I CINQUE OGGETTI DEL CIELO PROFONDO (commit `1c762b68`)

DOMANDA: "decisione del fondatore del 9 ottobre 2026, piu' il corpus dell'Architetto"
PROVA: test/real_time_cosmo_le_schede_non_vengono_dal_modello_test.dart
MISURA: schede uguali al corpus parola per parola, 5 su 5 (prima 0); Andromeda larga 21 punti a 70 gradi di campo

Le schede vengono dal corpus attraverso il generatore `tool/le_schede_del_cielo_profondo.py`; la riga pratica la compone il motore. La guardia e' nata rossa sul serio: l'id del Doppio Ammasso era sbagliato nel generatore (padre: questa parte).
IMMAGINI: prima `fg_02`, dopo `fh_17`, `fh_18`.
ACCETTAZIONE: tocca Andromeda in cima al salto da Mirach: la scheda ha le quattro parti del corpus e la riga di adesso.

## PARTE 11, L'ARIA FRA NOI E LE STELLE (commit `4e8fd6a8`)

DOMANDA: "proposta dell'Architetto approvata dal fondatore il 9 ottobre 2026" (estinzione, scintillio, alone)
PROVA: test/real_time_cosmo_l_aria_test.dart
MISURA: estinzione 0,28 magnitudini a trenta gradi, 10,36 all'orizzonte (prima 0); densita' ritarata da 143, 143, 176 a 170, 169, 210 col capo largo da 4,55 a 4,75

IMMAGINI: prima `fh_12` al commit `78c5117a`, dopo `fh_12`.
ACCETTAZIONE: guarda l'orizzonte: le stelle basse sono piu' deboli e ambrate, scintillano appena, e il fondo schiarisce verso lo skyline.

## PARTE 12, LE STELLE CADENTI (commit `8529688a`)

DOMANDA: "proposta dell'Architetto approvata dal fondatore il 9 ottobre 2026" (le meteore dei sette sciami)
PROVA: test/real_time_cosmo_le_stelle_cadenti_test.dart
MISURA: sette sciami con la data dell'ordine; una meteora vive al piu' 54 fotogrammi (0,9 secondi); Perseidi 100 all'ora al massimo e 36,8 due giorni e mezzo dopo; prima nessuna meteora

La prima stesura limitava la nascita fra 15 e 80 gradi dal radiante e lontano dal Perseo non nasceva niente (padre: questa parte): ora 10-120 gradi.
IMMAGINI: dopo `fh_19`.
ACCETTAZIONE: la notte del 12 agosto, verso il Perseo: ogni pochi minuti una scia sottile parte dal radiante e si spegne.

## PARTE 13, L'ECLITTICA (commit `571c2b20`)

DOMANDA: "proposta dell'Architetto approvata dal fondatore il 9 ottobre 2026" (l'eclittica con la sua etichetta, spegnibile)
PROVA: test/real_time_cosmo_l_eclittica_test.dart
MISURA: punti a 0,0016 gradi dal cerchio dell'eclittica J2000; filo da 0 a 1, acceso di default

Difetti visti e curati (padre: questa parte): l'etichetta su una riga era tagliata e cadeva sotto il pie' di pagina, l'interruttore era attaccato al bordo.
IMMAGINI: dopo `fh_20`, `fh_21`.
ACCETTAZIONE: un filo dorato sottile con il suo nome; nel menu dell'indicatore l'interruttore L'eclittica lo spegne.

## PARTE 14, I DUE DIFETTI RIMASTI DALLA FG (commit `44ef0321`)

DOMANDA: "rapporto di Code sull'ordine FG, 9 ottobre 2026" (la scritta sul nome di un pianeta; l'Ariete tagliato)
PROVA: test/real_time_cosmo_la_scritta_cede_il_posto_test.dart
MISURA: sovrapposizioni della scritta coi nomi nei casi costruiti, da 3 su 3 con la regola spenta a 0 su 4

14.1: la regola viveva dalla parte 5, ora e' una funzione pura provata. 14.2: **difetto della scena, non della cattura**. La cattura e' lo schermo intero, e la figura tagliata in `fg_07` e' il Toro, non l'Ariete: attraversa il bordo sinistro perche' la FG accendeva tutti i veli in quadro. Con un velo solo all'arrivo l'Ariete e' intero (`fh_15`).

## PARTE 15, GUARDIE E PROVE DI VISTA (commit `c87ad561`)

DOMANDA: "per ognuna delle otto guardie si fa la prova di vista, con l'iniezione verificata prima di leggere l'esito"
PROVA: docs/collaudo/FH/prove_di_vista.txt
MISURA: guardie cadute con l'innesto entrato e il file ripristinato al byte: 9 su 9 (le otto della parte 15 e un_solo_tempo)

Registro delle guardie da 725 a 732. Il primo giro dello strumento era caduto sul ripristino per un blocco di Windows, lasciando un innesto in `le_linee_in_scena.dart`. L'ho riportato alla versione commessa senza differenze, e lo strumento ora riprova la scrittura.

## L'AGGIUNTA, LA MACCHINA DEL TEMPO E LA LUNA PROTAGONISTA (commit `3580126e`, `a0d2dded`, `40f1c849`)

DOMANDA: "vorrei che l'utente possa selezionare la data a cui vuole riavvolgere il tempo oppure avanzare nel futuro"; "la luna e' molto piccola. Non dovrebbe essere piu' grande e davanti a tutti?"; "voglio un pulsante per l'utente che premera' quando vuole fare partire l'animazione"
PROVA: docs/collaudo/FH/aggiunta_i03_il_pannello_con_la_nascita.png
MISURA: Luna a riposo 54 px di diametro, al colmo della corsa 270 px; alone del pianeta piu' grande in campo 27 px di raggio (prima fino a 60 px, piu' del disco lunare); fotogrammi al secondo nella corsa sul Realme: NON ANCORA MISURATI

**APERTA IN ATTESA DI VERIFICA**: la C5 vuole i fotogrammi della corsa sul Realme, e sul Realme le tre scale di animazione sono a 0, cioe' Riduci Movimento acceso, quindi la corsa non parte. La richiesta di riaccenderle e' girata al fondatore. Le registrazioni I7 e I8 aspettano la stessa cosa.

### Le misure A1-A8, fatte prima del codice

- **A1**: `real_time_cosmo_screen.dart:122` "Il ritorno indietro nel tempo" (la voce del menu); `cielo_reale_screen.dart:1899` "Il ritorno nel tempo" (il titolo, la forma corta delle catture); i commenti `cielo_reale_screen.dart:4` e `typography_tokens.dart:137`; `traguardo.dart:18` "Il ritorno nel tempo" e' un altro concetto (i giorni di seguito dei sigilli) e non e' rinominato. Nessuna occorrenza negli asset.
- **A2**: `lib/features/real_time_cosmo/real_time_cosmo_screen.dart`, classe `RealTimeCosmoScreen`, voci `_SceltaDelCielo`, tutte e tre con l'articolo.
- **A3**: la porta e' `IlCieloDiMeeus`, per esempio `static double longitudine(CorpoCeleste corpo, double jdUt)`. Accetta un istante arbitrario solo dentro la finestra verificata, che era dal 31/12/1899 alle 0 UT al 1/1/2100 alle 0 UT, e fuori solleva `FuoriDalCieloVerificato`. Alla fermata il fondatore ha scelto di estendere la verifica: ora la finestra arriva al 1/1/2101 alle 12 UT, misurata contro il JPL DE440s su 72 istanti (Luna entro 11,0 secondi d'arco contro i 12,6 dichiarati, commit `3580126e`).
- **A4**: `Celestial.equatorialToHorizontal({required double raDeg, required double decDeg, required double latDeg, required double lstDeg})`; l'ora siderale viene da `Celestial.localSiderealDegrees(jd, longitudine)` dentro `CieloInUnIstante.calcola`.
- **A5**: no, le stelle restano J2000: la seconda riga di G1 resta com'e', non riscritta. Pianeti, Sole e Luna escono da Meeus all'equinozio vero della data.
- **A6**: la nascita arriva da `ProfileController.identity.birthMoment` con `IlFusoDellaNascita.inUtc`. Durate 1,8 s (eta'), 7 s (corsa), 8 s (rallentamento), 3,2 s (arrivo). Il blocco di testo stava a meta' altezza nella corsa (cattura 02 del fondatore, dal 40 al 61 per cento) e in alto nel rallentamento (cattura 01, dal 12 al 33 per cento).
- **A7**: disco della Luna di raggio max(9, punti per grado) a riposo, cioe' 9 punti a 70 gradi; l'alone di LunaReale arriva a 4,6 raggi. I pianeti seguono la regola delle stelle col tetto di 20 punti, alone compreso. La Luna ha una scala propria.
- **A8**: in lib 163 letture di `DateTime.now`; nel Real Time Cosmo una sola, `cielo_reale_screen.dart:350`, ora spostata in `IlTempoDelCosmo`. Fuori dal Real Time Cosmo non si toccano (C4): le letture nei file che chiamano il motore del cielo sono in `lettura_del_giorno.dart`, `il_filo_del_consulto.dart`, `i_responsi_di_oggi.dart`, `sorgente_natale.dart`, `ora_rituale.dart`, `synastry_report.dart`, `calendario_degli_eventi_screen.dart`, `oroscopo_screen.dart`, `archetype_test_screen.dart`, `face_constellation_screen.dart`, `guide_animal_screen.dart`, `rune_draw_screen.dart`, `maestro_chat_controller.dart`, `maestro_chat_screen.dart`, `onboarding_screen.dart`, `cosmic_passport_screen.dart`, `azioni_del_responso.dart`, `breath_destiny_screen.dart`, `dream_rite_screen.dart`, `santuario_screen.dart`, `sky_overview_screen.dart`, `sinastria_vip_screen.dart`, `stesa_tre_carte_screen.dart`, `le_funzioni_del_cielo.dart`, `maestro_persona.dart`.

### Cosa c'e', e le scelte dichiarate

- **La rinomina** (B): "La macchina del tempo" nel menu e nel titolo. Il sottotitolo della voce parlava solo del ritorno alla nascita: ora dice "Scegli un giorno fra il 1900 e il 2100 e il cielo corre fin li', indietro o avanti. Si parte dalla tua nascita." **Scelta mia, da confermare.**
- **IlTempoDelCosmo** (C1-C3) e la guardia `un_solo_tempo` (C2): 25 file guardati, 0 letture fuori posto, vista rossa. **E8**: le stelle non si ricalcolano dal catalogo, si girano con i tre assi della porta unica.
- **Il pannello del tempo** (D): scorciatoie, tre ruote, la riga del luogo e il pulsante "Viaggia nel tempo". **La D6 e' cambiata dalla frase del fondatore sul pulsante**: le scorciatoie scelgono il giorno, la corsa parte dal pulsante.
- **La corsa** (E): **verso la nascita, partendo dopo, restano i due tempi della parte 8** (H5 ed E3); verso ogni altro giorno ci sono sei secondi fissi (E1). Verso la nascita partendo da prima scorre l'anno: l'eta' prima della nascita non esiste. Gli istanti restano veri anche nei sei secondi: sopra 430 giorni con la regola FG a velocita' costante, fra 12 e 430 a giorni siderali interi, sotto 12 continui.
- **La Luna protagonista** (F): camera agganciata per tutta la corsa, fattore di scena 1-5-1, terra al venti per cento, la Luna per ultima, nessun pianeta con l'alone oltre il disco lunare, il filo scuro sul lembo.
- **Le fonti** (G): le quattro righe dell'Architetto nel foglio della Macchina.
- **Un difetto visto sul Realme e curato** (padre: questa aggiunta, voce E9): con Riduci Movimento si vedeva per 1,8 secondi l'eta' di oggi prima del salto (commit `40f1c849`).

### I file toccati

`lib/features/real_time_cosmo/il_tempo_del_cosmo.dart` (nuovo), `il_pannello_del_tempo.dart` (nuovo), `cielo_reale_screen.dart`, `pittore_del_cielo.dart`, `real_time_cosmo_screen.dart`; `lib/core/astro/real_time_cosmo/il_riavvolgimento.dart`, `il_cielo_in_un_istante.dart`; `lib/core/astro/meeus/il_cielo_di_meeus.dart`; `lib/design_system/components/luna_reale.dart`; `lib/design_system/tokens/typography_tokens.dart` (un commento); `lib/features/maestri/widgets/foglio_delle_fonti.dart`; `tool/riferimenti_del_cielo_jpl.py`, `docs/collaudo/FD/riferimenti_del_cielo.csv`; le prove `test/real_time_cosmo_la_macchina_del_tempo_test.dart`, `test/un_solo_tempo_test.dart`, `test/le_anteprime_della_macchina_del_tempo_test.dart`, `test/il_cielo_di_meeus_contro_il_jpl_test.dart`, `test/real_time_cosmo_la_via_lattea_test.dart`, `test/le_anteprime_dell_ordine_fg_test.dart`, `test/le_anteprime_dell_ordine_fh_test.dart`; `docs/guardie.md`, `docs/tipografia/spazi.md`.

### Le catture

In `docs/collaudo/FH/`:
- I1, il menu: `aggiunta_i01_il_menu_rinominato.png`, e quella vera dal Realme, `aggiunta_realme_i01_il_menu.png`;
- I2, il titolo e i comandi: `aggiunta_i02_il_titolo_e_i_comandi.png`;
- I3, il pannello con la nascita: `aggiunta_i03_il_pannello_con_la_nascita.png`;
- I4 e I5, il 1900 e il 2100: `aggiunta_i04_il_cielo_del_1900.png`, `aggiunta_i05_il_cielo_del_2100.png`;
- I6, l'arrivo sulla nascita: `aggiunta_i06_l_arrivo_sulla_nascita.png`;
- la Luna grande nella corsa, in anteprima: `aggiunta_i07_anteprima_la_luna_grande_nella_corsa.png`;
- I9, il salto con Riduci Movimento: `aggiunta_i09_il_salto_con_riduci_movimento.png`;
- I10, i due stati del luogo: `aggiunta_i10_il_luogo_di_nascita.png`, `aggiunta_i10_il_luogo_attuale.png`;
- I11, la Luna quasi piena il 28 ottobre 2026: `aggiunta_i11_la_luna_quasi_piena.png`;
- I12, le fonti: `aggiunta_i12_le_fonti_della_macchina.png`.

Le catture del Realme che mostrano la data e il luogo di nascita del profilo restano fuori dal repository: il profilo potrebbe essere di una persona vera. Le registrazioni I7 e I8 e la cattura I9 dal telefono aspettano le animazioni riaccese.

## I DIFETTI E I LORO PADRI (Regola C)

- Densita' 236 col terreno: FH parte 7, voce 7.3.
- Rapporto di pixel non dichiarato nelle anteprime FH: FH parte 1.
- Due "sorge alle" nell'anteprima del Sole: FH parte 6.
- Fase della corsa a 12,1 gradi: FG parte 3 (la stima con la sola velocita' del giorno), scoperta dalle date della FH parte 8.
- Contatore sulla Luna nel rallentamento: FH parte 8, voce 8.4.
- Id del Doppio Ammasso nel generatore: FH parte 10.
- Meteore che non nascevano lontano dal radiante: FH parte 12.
- Etichetta dell'eclittica tagliata e coperta: FH parte 13.
- Pannello senza MaestroScope, prova delle fonti che non scorreva, prova della rotazione tautologica: aggiunta, sezioni D, G ed E8.
- L'eta' di 1,8 secondi con Riduci Movimento: aggiunta, voce E9.
- Il ripristino caduto nel primo giro delle prove di vista: FH parte 15, lo strumento.

## LA SUITE INTERA

Una volta sola (C3), sul commit `de2abc5e`, in un worktree temporaneo con i fine riga LF (`C:/Users/user/fg`), in 67 minuti: **7.036 passate, 2 rosse**, nessuna saltata. Erano tutte e due di questo lavoro e sono curate nel commit finale, e le due guardie le ho rifatte girare verdi:

- `i_testi_seguono_i_nomi_nuovi_test.dart`: il bersaglio della Luna di nascita si chiamava "La tua Luna di nascita", nome di un traguardo che non esiste piu' (padre: FH parte 5). Ora e' "La Luna della tua nascita", lo stesso titolo della scheda.
- `il_censimento_dei_grigi_test.dart`: il bottone del luogo nel pannello del tempo era oro in stile corpo, e sui fondi dei Maestri arrivava a un contrasto fra 5,42 e 6,69 contro 7 (padre: aggiunta, voce D5). Ora ha lo stile delle azioni di casa, etichetta in goldLight.

Dopo il commit `de2abc5e` sono entrate solo la prova della 7.4 (una prova, provata da sola) e queste due correzioni, provate con le loro guardie e con le anteprime FH e della Macchina.

`flutter analyze` sul progetto intero: nessun problema.

**Aggiunta del 10 ottobre 2026, ordine FH, risposta dell'Architetto alle tre conferme.** Il sottotitolo della voce del menu e' quello dell'Architetto, verbatim: "Il cielo di un giorno qualunque, dal 1900 al 2100. Si parte da quello della tua nascita." Il pulsante della schermata resta "Viaggia nel tempo"; quello che conferma il giorno nel pannello del tempo dice "Portami lì". Nell'app la corsa parte da tutti e due: dal pulsante della schermata col giorno scelto, e dal pannello dopo la scelta; la scheda del menu utente non ha un pulsante, si tocca la scheda intera. PROVA: docs/collaudo/FH/aggiunta_i01_il_menu_rinominato.png, docs/collaudo/FH/aggiunta_i03_il_pannello_con_la_nascita.png.

**Aggiunta del 10 ottobre 2026, ordine FH, la larghezza della Via Lattea.** Il codice non da' per scontata la larghezza 1456: la maglia legge larghezza e altezza dall'immagine (lib/features/real_time_cosmo/la_via_lattea_in_scena.dart, riga 64), la colonna e' larghezza/2 meno la longitudine per larghezza/360, la riga viene dall'altezza, e nessuna prova guarda le dimensioni dell'asset. Con l'asset largo 1336 la maglia funziona com'e', purche' copra 360 gradi per 180. Danno invece per scontata la forma di oggi due testi: il commento della misura in lib/core/astro/real_time_cosmo/la_via_lattea.dart (colonna 728 di 1456, il taglio a 45,5 gradi) e la nota_cosmo di docs/stato_asset.json ("2 a 1" e "802.958 byte in tutto"). Si riscrivono quando arriva l'asset nuovo, con le misure rifatte su di lui.

**Aggiunta del 10 ottobre 2026, ordine FH, una mia misura sbagliata.** Le "due cuciture interne deboli, alle colonne 134 e 1320" della parte 9 erano rumore: salti di 2,25 volte quello tipico, contro i 2,1 che l'Architetto ha misurato come rumore dentro l'immagine. La cucitura vera e' sul bordo, fra la colonna 0 e la 1455, nella fascia delle righe 360-449 (scarto medio 13,9, massimo 28 su 255, misura dell'Architetto). La mia misura del bordo faceva la media su tutte le righe (4,34) e diluiva proprio quella fascia. Padre: FH parte 9, la misura dell'asset. Gli asset non si toccano: quello corretto arriva dall'Architetto.

**Aggiunta del 10 ottobre 2026, ordine FH, la consegna della 2304.** Consegnata la build 2304, release 4j4ocmuj7gmo0, dal commit 13e9e1a5 verde su GitHub, accesa sul Realme prima del caricamento (processo vivo, primo fotogramma, nessun FATAL EXCEPTION, numero letto dal telefono 2304), distribuita a cloud@esotericircle.app con 1 accettato. I banchi col modello: il giro intero sul commit a48e1d19 aveva il percorso C al 70 per cento contro 80 (oscillazione del modello: lo stesso percorso aveva fatto 100 e 90 l'8 ottobre, e nessun file del consulto e' cambiato); per scelta del fondatore il solo caso C e' stato rifatto sullo stesso codice dei banchi, 10 su 10 in 54 secondi e 0,04 euro. Dal commit 31047010 la consegna confronta solo i file che i banchi raggiungono, senza i commenti. PROVA: docs/collaudo/banchi_col_modello/2026-10-10.txt, docs/collaudo/banchi_col_modello/2026-10-10-giro1.txt, docs/versione_distribuita.json. Restano aperte la C5 e le registrazioni I7 e I8: aspettano le animazioni del Realme a 1x, che porta il fondatore.
