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
6. **Il Dart** rigenerato a ogni pezzo finito in una copia pulita del ramo (nel worktree gli scrittori lavoravano ancora), con la guardia del corpus portata alla dichiarazione vera. Quattro spinte sul ramo.

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

La suite intera sul commit `eaa72255`, nella copia `C:/Users/user/fi0` portata in LF e verificata prima di lanciarla: **+7143 -7** (`flutter test -r expanded`, 66 minuti). I sette rossi, col loro padre: **uno la registrazione** di questo rapporto (`i_rapporti_consegnati_non_si_correggono`), che e' fatta dopo questa riga; **tre della prova della rotazione** (`la_rotazione_delle_varianti`), il mondo cambiato: coi registri consegnati la lettura di casa monta lo scheletro e poi il registro (voce FI.20) e la prova si aspettava lo scheletro da solo; riscritta con la lapide e vista rossa con la rotazione spenta (padre **FM.03**); **uno la tabella generata delle lunghezze** (`le_lunghezze_dei_responsi`), rigenerata: la bolla di posizione dei tarocchi passa da 160-258 a 270-365 caratteri perche' porta il registro (padre **FM.03**) e a video la bolla si allunga; **due frasi degli scrittori**: "Custodisci", il nome vecchio del menu, in te stesso (Quattro di Denari dritta 3, padre **FM.02**, presa da `i_nomi_del_menu_e_del_diario`) e "che hai dato, o ricevuto" nel passato (Re di Spade dritta 3, padre **FM.01**, presa da `niente_vocativo_a_schermo`), riscritte. I file dei sette rossi rifatti nella copia LF dopo le correzioni, con le guardie del corpus, del genere e dei testi a video: 36 su 36 verdi. La suite intera non e' stata rigirata dopo le correzioni: lo dira' il cancello di GitHub sul commit spinto.

## LA BUILD

Nessuna build (FM.07). La build è possibile, la ordina il fondatore. A video cambia il testo delle stese aperte: le carte della stesa a tre carte ruotano su tre varianti invece di una e i registri entrano nella lettura di casa secondo l'argomento.

**Aggiunta del 12 ottobre 2026, aggiunta 1 dell'ordine FM**: le richieste del fondatore dopo la consegna, voci da FM.08 a FM.14 del manifesto. Nessuna build: la ordina il fondatore.

**Aggiunta del 12 ottobre 2026, FM.08 APERTA IN ATTESA DI VERIFICA**: il Sigillo del Sogno ascolta solo l'aria (`BreathDetector(soloAria: true)`, `lib/core/sensi/l_aria_che_dirada.dart`): la forma del Soffio del Destino coi suoi numeri e il fondo della stanza imparato sulle ultime tre secondi, con l'aria almeno quattro volte piu' forte. Musica, voce, canzone che parte e ventilatore da 62, 62, 63 e 93 finestre a 0; il fiato 43 finestre. Prova: test/il_sigillo_si_dirada_solo_con_l_aria_test.dart. Manca il fiato vero sul telefono. Difetto: la soglia di volume nuda del Sigillo, PROVENIENZA IGNOTA (il diradamento col fiato esiste dall'ordine P e nessuna prova lo copriva: tutte usavano il pulsante tattile).

**Aggiunta del 12 ottobre 2026, FM.09 APERTA IN ATTESA DI VERIFICA**: il Soffio del Destino un poco piu' sensibile, energia minima da 0,0025 a 0,0018, planarita' da 0,15 a 0,12, finestre da 6 a 5; le guardie del soffio restano verdi (voce, musica e tonfo fuori, tre soffi dentro). Prova: lib/core/rituals/forma_del_soffio.dart. Senza una misura del fiato vero sul Realme la taratura e' una scelta di Code: da provare sul telefono.

**Aggiunta del 12 ottobre 2026, FM.10 CHIUSA**: la luna della home apre CieloRealeScreen in modo adesso; il pulsante sottile "Attiva macchina del tempo" porta il giorno scelto, il luogo, il viaggio e il pannello senza cambiare schermata (il modo sta nello stato). Prova: docs/collaudo/FM/aggiunta_1/a1_il_cielo_in_quattro_momenti.png.

**Aggiunta del 12 ottobre 2026, FM.11 CHIUSA**: il cielo della tua nascita del cielo reale nel Cosmic Passport e nella carta d'identita', che apriva lo stesso cielo di prima. Prova: test/il_cielo_reale_prende_il_posto_test.dart.

**Aggiunta del 12 ottobre 2026, FM.12 CHIUSA**: nell'onboarding la fase del cielo e' la macchina del tempo del cielo reale, con la nascita appena scritta passata alla schermata (il profilo li' non c'e' ancora) e "Leggi la tua carta" per proseguire. Prova: docs/collaudo/FM/aggiunta_1/a1_04_l_onboarding_la_macchina_dalla_nascita.png.

**Aggiunta del 12 ottobre 2026, FM.13 CHIUSA**: tolta la voce Real Time Cosmo dal menu utente ed eliminato il menu temporaneo `real_time_cosmo_screen.dart`, con due prove riscritte con la lapide. Prova: test/le_anteprime_dell_ordine_fg_test.dart.

**Aggiunta del 12 ottobre 2026, FM.14 CHIUSA**: le anteprime della stesa a croce e della Croce Celtica, coperte e scoperte; dieci carte in piedi larghe 26 punti a 360, quindi la Croce Celtica resta chiusa. Prova: docs/preview/FL/fl_croce_e_croce_celtica.png.

**Aggiunta del 12 ottobre 2026, decisioni e cose aperte dell'aggiunta 1**: il fondo della stanza nel Sigillo e' una decisione di Code, perche' un ventilatore e' largo come l'aria e la sola forma non lo ferma; un ascolto iniziale di un quarto di secondo e' stato scritto e tolto, nessun suono lo rendeva necessario. `SkyOverviewScreen`, il cielo di prima, non lo apre piu' nessuna schermata ma ha quattordici prove sue: si toglie con un ordine a parte. La guardia `cielo_nascita_vero` e' cieca dal 31 luglio (cerca l'assenza di "esempio" che la scheda non dice piu' e il secondo caso ha l'asserzione commentata): Regola B fatta su `onboarding_ordine` (docs/collaudo/FM/aggiunta_1/a1_regola_b.txt).

**Aggiunta del 12 ottobre 2026, i tre rossi della suite intera sul commit 1372edef, corretti prima della spinta**: `clamp` con i limiti invertiti in due punti (`lib/features/real_time_cosmo/cielo_reale_screen.dart` e `la_scritta_che_cede.dart`), quando il pie' di pagina del cielo di adesso (il pulsante FM.10) supera lo schermo su una scena bassa; padre FM.10, guardia nuova `test/la_scritta_cede_senza_lanciare_test.dart`, vista rossa su tre innesti. `test/birth_sky_test.dart` riscritta con la lapide per il cielo reale al posto di `SkyOverviewScreen` nel Cosmic Passport; padre FM.11. La tabella `docs/tipografia/spazi.md` rigenerata (174 vuoti verticali, non piu' 177): il mondo cambiato, non un difetto.

**Aggiunta del 12 ottobre 2026, aggiunta 2 dell'ordine FM, voci FM.15-FM.18**: il fondatore, guardando le anteprime della Croce Celtica in piedi, ha chiesto quattro correzioni. La Croce Celtica in piedi passa da due righe da cinque a righe bilanciate, al piu' quattro per riga (per dieci carte, 4+3+3): `FilaAlzata.per` distingue una croce a quattro (che resta a forma di croce), una riga sola, o righe bilanciate; l'etichetta sale da due a quattro righe, cosi' nessuna parola resta tagliata. Prova: `test/il_tavolo_di_medora_test.dart`, viste rosse due Regole A (le righe tornano cinque per riga; l'etichetta torna a due righe senza l'ultima parola).

**Aggiunta del 12 ottobre 2026, FM.16**: le carte appoggiate sul tavolo, piu' grandi. Il tetto di larghezza (0,34 volte il piano, che non vincolava mai le stese a piu' colonne) e' tolto; il margine del campo e' stato stretto da 0,86 a 0,97 volte il piano, cercato a mano fra 0,86 e 0,99 (il massimo prima che la guardia 'le carte di ogni stesa stanno dentro il campo del velluto' cadesse), misura in `docs/collaudo/FM/aggiunta_1/a1_margine_del_tavolo.txt`. La carta sola sul tavolo passa da 149 a 170 punti; la croce a quattro da 53 a 60 punti. **Dichiarazione onesta**: per le stese su piu' righe logiche (la croce a quattro, la Croce Celtica) il vero limite non e' un numero nel codice ma l'altezza del campo reale del velluto disegnato nell'immagine; oltre il margine trovato, le carte uscirebbero dal bordo ricamato. Guardie nuove in `test/il_tavolo_di_medora_test.dart`, viste rosse su due Regole A (il tetto torna a 0,34; il margine torna a 0,86).

**Aggiunta del 12 ottobre 2026, FM.17**: la distanza fra la carta in piedi e la sua etichetta, da 16 punti (SpacingTokens.md) a 4 (SpacingTokens.xxs, il piu' stretto dei token). Insieme sono saliti anche lo spazio riservato sotto ogni riga di carte (da 44 e 64 a 28 e 84 punti, per tenere conto delle quattro righe della voce FM.15) e il numero di righe dell'etichetta nel calcolo dell'altezza della scena. Prova: lib/features/tarot/stesa_tre_carte_screen.dart.

**Aggiunta del 12 ottobre 2026, FM.18**: il galleggio delle carte in piedi (`TiltListener.fluttuazioneDi`, gia' nel codice da prima di quest'ordine) non tocca mai l'etichetta sotto, nemmeno con la distanza stretta a quattro punti della voce FM.17: l'ampiezza del galleggio, 2,2 punti, e' stata resa una costante pubblica (`TiltListener.ampiezzaDelGalleggio`) e una guardia nuova, `test/il_galleggio_non_tocca_la_scritta_test.dart`, confronta la distanza carta-etichetta col doppio dell'ampiezza: margine di 1,8 punti, vista rossa alzando l'ampiezza a quattro punti.

**Aggiunta del 12 ottobre 2026, il registro delle guardie**: due guardie nuove, `test/la_scritta_cede_senza_lanciare_test.dart` e `test/il_galleggio_non_tocca_la_scritta_test.dart`, piu' sei casi nuovi dentro `test/il_tavolo_di_medora_test.dart` (gia' contata nel registro). Il manifesto sale da quattordici a diciotto voci; sedici chiuse, due aperte (FM.08 e FM.09, che aspettano ancora il fiato vero sul telefono).

**Aggiunta del 12 ottobre 2026, la suite intera sul commit 14927a49**: +7159 -4 (66 minuti). Quattro rossi, tutti corretti e rifatti verdi, nessuno un difetto nuovo: il registro delle guardie dichiarava 756 ma ne elencava 754 (mancavano le due righe tabellari delle guardie nuove `la_scritta_cede_senza_lanciare` e `il_galleggio_non_tocca_la_scritta`, aggiunte); `test/le_stese_del_cerchio_test.dart` pretendeva ancora il vecchio ordine dietro-a-sinistra/davanti-a-destra della Croce Celtica, invertito da Waite nell'ordine precedente: riscritta con la lapide, vista rossa tornando al vecchio ordine; `test/la_stesa_si_legge_intera_test.dart` (ordine EQ voce 05) pretendeva una distanza fissa di almeno otto punti fra carta e scritta, valore superato dalla voce FM.17: riscritta per misurare il solo invariante che conta ora, che la scritta non tocchi mai la carta (>=0), vista rossa con una distanza negativa; tornare a sedici punti resta verde di proposito, perche' rispetta ancora l'invariante (docs/collaudo/FM/aggiunta_1/a1_regola_a.txt).
