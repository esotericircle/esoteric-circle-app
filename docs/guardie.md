# IL REGISTRO DELLE GUARDIE

Ordine CL voce 05, riportato ai conti veri dall'ordine CM voci 01 e 03.
**Casa unica della conoscenza sulle guardie di questo progetto.** Una riga per
guardia, e la colonna che conta e' la penultima: **una guardia che non e' mai
stata vista rossa non e' una guardia, e' una speranza.**

## Che cos'e' una guardia, e cosa non lo e'

E' una guardia una prova che asserisce su un'**assenza** oppure su un
**insieme scoperto a esecuzione**: legge i sorgenti e ci cerca dentro, scorre
elenchi di file o di rotte o di chiavi, scatta fotografie e le confronta,
oppure pretende che qualcosa NON ci sia.

**Non** e' una guardia la prova che chiama una funzione con un valore e ne
verifica il risultato: quella non puo' essere cieca, perche' se la funzione
sparisce non compila.

La differenza e' tutta qui: **una prova che asserisce su un valore fallisce
quando il valore e' sbagliato; una che asserisce su un insieme diventa VERDE
quando l'insieme e' vuoto.**

## Le quattro specie di cecita'

1. **Vuota per costruzione.** L'insieme e' vuoto, il ciclo non gira, la prova
   e' verde senza aver guardato niente.
2. **Cieca al bersaglio.** L'insieme non e' vuoto ma non contiene la classe
   da sorvegliare.
3. **Scollegata.** Verifica un componente vero e funzionante che nessuno usa.
4. **Degradata.** Era viva, una modifica le ha tolto il bersaglio, e invece
   di diventare rossa e' diventata muta.

## LA QUADRATURA, voce CM.01

**Le categorie devono sommare al totale, o una delle due cifre e' falsa.**
Prima di quest'ordine il registro dava tre numeri che non chiudevano, e nessuno
poteva dire quale fosse sbagliato. Qui sotto la somma e' scritta, e la riga del
totale e' un controllo, non un ornamento.

| categoria | quante |
| --- | ---: |
| Guardie che passano dalla porta comune | 122 |
| Guardie con un cardinale proprio dichiarato | 97 |
| Guardie che non scoprono nessun insieme di file | 167 |
| **Somma delle categorie** | **386** |
| **Guardie secondo la definizione** | **386** |

**Ricontate il 10 settembre 2026, dopo l'ordine DD**, che ha portato **undici
guardie nuove**: il totale sale da 375 a **386** e le tre categorie a **122, 97 e
167**. Le nuove sono `il_cuoricino_e_uno_solo_a_schermo`,
`le_nove_frequenze_si_vedono_tutte`, `numero_e_colore_hanno_la_stessa_altezza`,
`i_conteggi_della_chat_stanno_stretti`, `la_parola_del_giorno_si_vede_nella_frase`,
`il_cerchio_del_soffio_riempie_la_scena`, `i_doni_si_aprono_alla_loro_ora`,
`la_meditazione_ha_il_suo_cielo`, `il_giallo_delle_rune_parla_adesso`,
`il_soffio_si_riconosce_dalla_forma` e `la_luna_non_si_sposta`, piu'
`dream_rite_screen`, che esisteva e **il registro non elencava**.

**E una riga elencava un file che non esiste piu'**:
`la_libreria_si_apre_e_il_rito_si_compone_test.dart`, rinominata durante
l'ordine DD in `la_libreria_si_apre_e_la_pratica_parte_test.dart`. Il registro
la nominava ancora col nome vecchio, e la prova che lo sorveglia lo ha detto:
**una guardia che il registro non trova e' una guardia che nessuno sa se gira**.

**Ricontate il 10 settembre 2026, dopo l'ordine DC**, che ha portato **una guardia nuova** dalla porta comune, `nessun_pittore_dipinge_sul_nulla`: il totale sale da 374 a **375** e le tre categorie a **120, 94 e 161**. E' nata rossa due volte, sulla riproduzione del difetto e sull'innesto, e nasce dal difetto piu' silenzioso di quest'ordine: un `CustomPaint` senza figlio e senza `size` dipinge su una tela di area nulla, e nessuna guardia dei pittori poteva vederlo perche' tutte scelgono da se' la misura su cui dipingono.

**Ricontate il 9 settembre 2026, dopo gli ordini CX, CY e DB**, che hanno
portato **dodici guardie nuove**: il totale sale da 362 a **374**, e le tre
categorie a **119, 94 e 161**. Le dodici sono tutte nate rosse, e la colonna
della prova ne porta la data.

Le due righe in grassetto **coincidono**, contate il 7 settembre 2026, e
ricontate lo stesso giorno dopo l'ordine CW, che ha portato **otto guardie
che il registro non conosceva**: 119 piu' 73 piu' 153 fanno 345, e 230 mai
viste rosse piu' 115 viste rosse fanno gli stessi 345.

**E le tre categorie erano false, scoperto con l'ordine CQ voce 5.05.** Dicevano
3, 39 e 235: sommavano al totale giusto e nessuna delle tre era il numero che la
tavola qui sotto porta scritto nella sua colonna. **La guardia non se ne era
accorta perche' controllava soltanto che le tre cifre sommassero fra loro**, cioe'
la coerenza di tre numeri inventati insieme. Era la seconda specie di cecita', la
guardia cieca al bersaglio, dentro il documento che quella tavola la definisce.
Adesso i tre numeri sono contati sulla colonna, e il 7 settembre 2026
sono **119, 70 e 148**. Il 9 settembre 2026, dopo gli ordini CX, CY e DB, la
stessa colonna dice **119, 94 e 161**.

**E il registro aveva una seconda cecita', trovata con l'ordine CS.** Le due
prove che lo sorvegliano camminano **dal registro verso i file**: prendono le
righe che il registro nomina e verificano che dicano il vero. Nessuna camminava
nel verso opposto, cioe' dai file che esistono verso il registro, quindi **una
guardia scritta e mai registrata non faceva scattare niente**. Il registro
poteva quadrare perfettamente su se stesso mentre **ventotto guardie vive non
ci comparivano affatto**, e la cifra della porta comune diceva centoquindici
perche' contava le proprie righe invece delle prove che da quella porta
passano davvero: erano centodiciotto.

La prova che mancava e' `nessuna guardia della porta comune resta fuori dal
registro`, dentro `test/il_registro_delle_guardie_quadra_test.dart`. Guarda le
guardie della porta comune perche' sono le uniche riconoscibili a macchina
senza giudizio; le altre specie restano affidate a chi scrive.

La terza
categoria non e' un debito: sono guardie che sorvegliano un'assenza, una
fotografia o un elenco che non vive in `lib`, e per loro un cardinale sui file
Dart non vorrebbe dire niente. **Il debito, quello vero, e' chiuso: zero
guardie scoprono un insieme dentro `lib` senza dichiarare quanto guardano.**

## LE DUE POPOLAZIONI, voce CM.03

**Il 79 e il 17 dell'ordine CL non erano in contraddizione: contavano insiemi
diversi, e nessuno dei due lo diceva.** E' la stessa malattia che il progetto
combatte nel codice, due conti della stessa cosa, arrivata dentro i documenti.

| | quante | contata come |
| --- | ---: | --- |
| File di prova nella cartella `test` | 776 | `ls test/*.dart` |
| Di questi, censiti come guardie | 306 | righe della tavola qui sotto |
| File di prova che scorrono i sorgenti | 137 | grep di `Directory('lib')`, `sorgentiDiLib`, `sorgentiDiCartelle`, `listSync` |
| **Guardie** censite che scorrono i sorgenti | 132 | i 137 di sopra che hanno una riga nella tavola |
| Di questi, che passano dalla porta comune | 115 | grep delle quattro porte, `sorgentiDiLib(`, `sorgentiDiCartelle(`, `fileScoperti(`, `righeDiLib(` |

**E QUI DUE CONTI DELLA STESSA COSA TORNAVANO A NON TORNARE, E IL COLPEVOLE
ERA IL COMANDO.** Fino all'ordine CQ questo paragrafo diceva che la tavola
classificava **108** guardie "dalla porta comune" mentre il grep ne trovava
**100**, e attribuiva le otto righe di differenza a una classificazione sbagliata
da riparare a mano una per una.

**Non c'era niente da riparare.** Il grep cercava due nomi, `sorgentiDiLib(` e
`sorgentiDiCartelle(`, e le porte comuni sono **quattro**: mancavano
`fileScoperti(` e `righeDiLib(`. Contate tutte e quattro, i file che passano da
una porta sono **116**, e i **111** censiti nella tavola sono esattamente quelli
che hanno anche una riga: i cinque di scarto sono prove che usano una porta senza
essere guardie secondo la definizione. **Il numero della tavola era giusto da
sempre, e per tre ordini si e' dato per sbagliato un dato vero sulla parola di un
comando scritto male.** Provenienza: ordine CM voce 03, che ha scritto il grep.

Il **17** dell'ordine CL contava le guardie censite che scorrono i sorgenti
**e** avevano gia' un cardinale proprio. Il **79** contava, su **tutti** i file
di prova, quelli che scorrevano i sorgenti senza cardinale. Denominatori
diversi: 247 contro 711. La differenza fra le due popolazioni e' di **3** file,
prove che leggono i sorgenti senza essere guardie secondo la definizione.

**Come si evita che ricapiti.** Ogni numero scritto qui dice su quale insieme
e' contato, nella stessa riga. Un numero senza il suo denominatore non entra in
questo registro.

## I numeri, contati il 7 settembre 2026

| | |
| --- | ---: |
| File di prova totali | 797 |
| **Guardie secondo la definizione** | **374** |
| Guardie che scorrono i sorgenti di `lib` | 136 |
| Di queste, passate alla porta comune | 119 |
| Guardie che scoprono un insieme in `lib` senza cardinale | **0** |
| **Guardie mai viste rosse** | **230** |
| Di queste, **provate e restate VERDI col difetto dentro** | **2** |
| **Guardie viste rosse almeno una volta** | **127** |

Le guardie viste rosse sono **88 su 306**, il **28.8 per cento**, contate il 6 settembre 2026 con l'ordine CR.

**LE OTTO DELL'ORDINE CR SORVEGLIANO UNA FUNZIONE CHE ERA FINTA.** La Costellazione del Viso produceva un responso anche fotografando un muro, e la prima di queste otto e' nata rossa senza innesto perche' il difetto era in produzione. **E due volte la Regola A ha trovato una PRETESA DEBOLE invece di un difetto**: la vitalita' della scansione guardava la sequenza intera invece delle singole pose, e il tetto dei due segni dell'espressione era provato su un volto che non poteva produrne piu' di uno. Corrette, otto innesti su otto rossi.

**LE DUE DELLA TERZA TORNATA SONO NATE ROSSE SENZA INNESTO**, e non e' un vezzo: il fondatore aveva collegato il telefono e chiesto la verifica a vista dei Doni, e i difetti erano gia' in produzione. Sorvegliano la materia storica che apriva la scena dell'Estrazione Rune e il numero degli Angeli che era scritto a mano nella frase invece di venire dalla lista.

**LE TREDICI CHE L'ORDINE CQ AGGIUNGE QUI SONO TUTTE NATE ROSSE**, e le loro
prove stanno in `docs/ordini/CQ_prova_del_rosso.txt`, una sezione per guardia
con l'innesto verificato col grep prima di leggere l'esito. Sorvegliano il
tetto del piano che si rinnova, la gettata a tre rune che risponde alla
domanda, il suono della carta, la stella toccabile, la terza carta che non apre
una schermata, il fondo dichiarato, i suoni sintetizzati, il controllo del
comando di distribuzione, il cuore centrato col titolo, il soffio che non si
accavalla, la domanda dentro il responso, **il mood del Cerchio** e **la card
che si manda**.

Prima dell'ordine
CL erano nove su duecentoquarantadue, il 3,7. L'ordine CM ne ha portate venti;
l'ordine CO ne aggiunge quindici; **l'ordine CP ne aggiunge dieci**, tre
guardie nuove nate rosse (`le_regole_dei_traguardi_sono_rispettate`,
`l_evento_che_arma_e_la_condizione_scritta`,
`aprire_e_chiudere_non_e_un_cammino`), due guardie esistenti viste rosse con
un innesto prima di toccare la loro zona
(`la_costanza_non_chiede_piu_i_giorni_di_fila`, `il_prossimo_e_il_prossimo`,
che non sono censite qui) e cinque guardie censite che la riscrittura del
corpus ha fatto cadere davvero, riparate una per una.

**LE PROVE DEL ROSSO DELL'ORDINE CP STANNO SCRITTE**, in
`docs/ordini/CP_prova_del_rosso.txt`: ventiquattro innesti, uno per pretesa,
ognuno verificato col grep prima di leggere l'esito. Ventitre hanno fatto
rossa la pretesa attesa. **Il ventiquattresimo e' rimasto verde, ed e'
l'informazione piu' utile del giro**: tolto il conto una volta al giorno per
gesto, la guardia dell'abuso resta verde, perche' quel freno nella revisione F
non protegge nulla che la scala e il corpus non proteggano gia'. Resta come
seconda serratura, e adesso e' scritto che e' una seconda e non la prima.

**E UNA CECITA' VERA, colta dalla Regola B.** Sostituendo la soglia di
`StessaOraPerGiorni` con uno zero, `le_condizioni_costruite` restava verde in
tutte e tre le sue prove: provava che la condizione si accende, mai che
TRATTIENE. Difetto della voce BW.07, riparato con un caso negativo nato
rosso.

**Le due che sono restate VERDI col difetto dentro sono l'informazione piu'
utile di questa tavola.** Non sono guardie rotte: sono guardie che sorvegliano
una cosa diversa da quella che si credeva coprissero.
`le_feste_e_le_regole_che_le_trattengono` sorveglia le REGOLE della coda delle
feste e non il flusso che le apre, quindi un ritorno anticipato dentro
`guardaCosaSiAccende` le passa davanti; `la_spirale_di_stelle` sorveglia il
MOTO e il conto delle stelle e non la loro forma, quindi un alone che se le
mangia le passa davanti. Tutte e due adesso hanno accanto una guardia che
copre cio' che loro non coprono.

## Come si legge la tavola

**Cardinale minimo**: quante cose deve trovare per potersi dire verde. "Dalla
porta comune" vuol dire che passa da `sorgentiDiLib()` o da
`sorgentiDiCartelle()`, che il minimo lo dichiarano per tutti. "Non scopre
insiemi in `lib`" vuol dire che il cardinale sui file Dart non la
riguarderebbe: sorveglia un'assenza, una fotografia, un elenco che vive
altrove.

**Priorita'**: 2 sono le guardie su proprieta' gia' violate in passato, 3 tutte
le altre.

| guardia | cosa sorveglia | specie esposte | cardinale minimo | vista rossa | prio |
| --- | --- | --- | --- | --- | --- |
| `accenti_veri_test.dart` | accenti veri | 1 | dalla porta comune | CO | 2 |
| `accents_test.dart` | accents | 1 | non scopre insiemi di file | mai | 3 |
| `alone_dietro_le_figure_test.dart` | alone dietro le figure | 4, 1 | non scopre insiemi di file | mai | 3 |
| `anteprime_non_velate_test.dart` | anteprime non velate | 1 | proprio, dichiarato | mai | 3 |
| `anteprime_ordine_e_test.dart` | anteprime ordine e | 4 | non scopre insiemi di file | mai | 3 |
| `aprire_e_chiudere_non_e_un_cammino_test.dart` | otto aperture della stessa funzionalita non fanno feste | 1 | proprio, dichiarato | 03/09/2026, CP | 2 |
| `arti_preferite_test.dart` | arti preferite | 1 | non scopre insiemi di file | mai | 3 |
| `aspetti_di_oggi_test.dart` | aspetti di oggi | 1, 2 | dalla porta comune | mai | 3 |
| `attestazione_non_ferma_la_voce_test.dart` | attestazione non ferma la voce | 1, 2 | dalla porta comune | mai | 3 |
| `aura_dice_solo_cio_che_ricorda_test.dart` | aura dice solo cio che ricorda | 1, 2 | proprio, dichiarato | 09/09/2026, DB | 2 |
| `avvisi_del_rito_test.dart` | avvisi del rito | 1, 2 | dalla porta comune | mai | 3 |
| `barra_arte_non_si_copre_test.dart` | barra arte non si copre | 1, 2 | dalla porta comune | mai | 3 |
| `bolla_non_copre_avatar_test.dart` | bolla non copre avatar | 4 | non scopre insiemi di file | mai | 3 |
| `bolla_non_copre_test.dart` | bolla non copre | 1 | non scopre insiemi di file | mai | 3 |
| `carosello_ruota_test.dart` | carosello ruota | 1 | non scopre insiemi di file | mai | 3 |
| `carta_natale_arriva_test.dart` | carta natale arriva | 1, 2 | dalla porta comune | mai | 3 |
| `chi_misura_il_testo_usa_la_scala_test.dart` | chi misura il testo usa la scala | 1, 2 | dalla porta comune | 01/09/2026, CM | 3 |
| `cielo_segue_la_posizione_test.dart` | cielo segue la posizione | 4 | non scopre insiemi di file | mai | 3 |
| `cio_che_non_ho_visto_non_lo_descrivo_test.dart` | cio che non ho visto non lo descrivo | 1, 2 | proprio, dichiarato | 09/09/2026, CX | 2 |
| `codemagic_regge_lo_schema_test.dart` | codemagic regge lo schema | 1, 2 | proprio, dichiarato | mai | 3 |
| `codice_senza_testo_test.dart` | codice senza testo | 1, 2 | dalla porta comune | mai | 2 |
| `colore_del_dono_test.dart` | colore del dono | 1, 2, 4 | proprio, dichiarato | mai | 3 |
| `corpus_rune_attestato_test.dart` | corpus rune attestato | 1, 2 | proprio, dichiarato | mai | 3 |
| `corredo_anteprime_test.dart` | corredo anteprime | 1, 2 | non scopre insiemi di file | mai | 3 |
| `cosa_dicono_i_doni_test.dart` | cosa dicono i Doni | 1 | non scopre insiemi di file | 04/09/2026, CQ | 3 |
| `cosmo_e_interruttori_test.dart` | cosmo e interruttori | 1, 2 | dalla porta comune | mai | 3 |
| `costellazione_ripetuta_test.dart` | costellazione ripetuta | 1, 2 | dalla porta comune | mai | 3 |
| `dati_nascita_sbloccano_test.dart` | dati nascita sbloccano | 1, 2 | dalla porta comune | mai | 3 |
| `dove_si_spendono_eos_test.dart` | dove si spendono eos | 1, 2 | dalla porta comune | 01/09/2026, CM, cardinale al caricamento | 3 |
| `due_volti_danno_misure_diverse_test.dart` | due volti diversi danno misure diverse, lo stesso si somiglia | 1, 2 | proprio, dichiarato | 06/09/2026, CR | 2 |
| `due_volti_diversi_danno_responsi_diversi_test.dart` | due volti diversi non ricevono lo stesso responso | 1, 2 | proprio, dichiarato | 08/09/2026, CX | 1 |
| `entitlement_soldi2_test.dart` | entitlement soldi2 | 1, 2 | dalla porta comune | mai | 3 |
| `etichette_e_lettura_test.dart` | etichette e lettura | 1, 2 | proprio, dichiarato | CO | 3 |
| `fase_lunare_vera_test.dart` | fase lunare vera | 1, 2 | non scopre insiemi di file | mai | 3 |
| `free_astro_client_test.dart` | free astro client | 1, 2 | dalla porta comune | mai | 3 |
| `gli_accenti_non_sono_inchiostro_test.dart` | gli accenti dei Maestri non sono inchiostro | 1, 2 | dalla porta comune | CO, nata rossa sul difetto vero | 2 |
| `gli_ancoraggi_vengono_dall_arte_test.dart` | gli ancoraggi vengono dall arte | 4, 1 | non scopre insiemi di file | mai | 3 |
| `gli_eos_hanno_un_nome_test.dart` | gli eos hanno un nome | 1, 2, 4 | dalla porta comune | mai | 3 |
| `i_caratteri_dichiarati_esistono_test.dart` | i caratteri dichiarati esistono | 1, 2 | proprio, dichiarato | mai | 2 |
| `i_cinque_doni_rispettano_la_legge_dei_testi_test.dart` | i cinque Doni rispettano la legge dei testi | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `i_cinque_elementi_colorano_e_si_leggono_test.dart` | i cinque elementi colorano e si leggono | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `dream_rite_screen_test.dart` | la schermata del Sigillo del Sogno | 1 | non scopre insiemi di file | 10/09/2026, DD (rossa sul difetto vero: la Parola dell Alba non arrivava a video) | 2 |
| `i_doni_si_aprono_alla_loro_ora_test.dart` | i doni si aprono alla loro ora | 1, 2 | proprio, dichiarato | 10/09/2026, DD (rossa: 73 risposte sbagliate su 120 col difetto innestato) | 1 |
| `i_doni_si_agganciano_test.dart` | i doni si agganciano | 1, 2 | proprio, dichiarato | mai | 3 |
| `i_due_grigi_si_distinguono_test.dart` | i due grigi si distinguono | 1, 4 | non scopre insiemi di file | mai | 2 |
| `i_due_pulsanti_del_soffio_si_leggono_test.dart` | i due pulsanti del soffio si leggono | 1, 2 | non scopre insiemi di file | 07/09/2026, CW | 2 |
| `i_grigi_si_leggono_test.dart` | i grigi si leggono | 1 | dalla porta comune | 01/09/2026, CN | 2 |
| `i_maestri_non_coprono_il_cielo_test.dart` | i maestri non coprono il cielo | 1, 2 | non scopre insiemi di file | mai | 3 |
| `i_maestri_non_perdono_la_testa_test.dart` | i maestri non perdono la testa | 4, 1 | non scopre insiemi di file | mai | 3 |
| `i_maestri_sanno_cosa_arriva_test.dart` | i Maestri sanno cosa arriva | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `i_maestri_sui_pixel_e_non_sui_rettangoli_test.dart` | i maestri sui pixel e non sui rettangoli | 4 | non scopre insiemi di file | mai | 3 |
| `i_manifesti_sono_sigillati_test.dart` | i manifesti sono sigillati | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `i_movimenti_dicono_il_guadagno_test.dart` | i movimenti dicono il guadagno | 1, 2 | non scopre insiemi di file | mai | 3 |
| `i_nomi_non_si_sovrappongono_test.dart` | i nomi non si sovrappongono | 4 | non scopre insiemi di file | mai | 3 |
| `i_nove_ereditati_test.dart` | i nove ereditati | 1, 2 | dalla porta comune | mai | 3 |
| `i_piani_del_cielo_si_muovono_test.dart` | i piani del cielo si muovono | 4, 1 | non scopre insiemi di file | mai | 3 |
| `i_promemoria_a_una_settimana_misurati_test.dart` | i promemoria a una settimana, misurati | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `i_punti_del_volto_sono_veri_test.dart` | i punti del volto stanno dentro i 478 della mesh | 1, 2 | proprio, dichiarato | 06/09/2026, CR | 2 |
| `i_punti_sono_davvero_quelle_parti_del_viso_test.dart` | i punti sono davvero quelle parti del viso | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `i_ricordi_hanno_una_rotta_sola_test.dart` | i ricordi hanno una rotta sola | 1, 2 | dalla porta comune | mai | 3 |
| `i_testi_da_leggere_hanno_una_misura_sola_test.dart` | i testi da leggere hanno una misura sola | 1, 2 | non scopre insiemi di file | mai | 3 |
| `i_testi_del_dono_non_stanno_sulla_carta_test.dart` | i testi del dono non stanno sulla carta | 1, 2 | dalla porta comune | mai | 3 |
| `i_testi_seguono_i_nomi_nuovi_test.dart` | i testi seguono i nomi nuovi | 1, 2 | dalla porta comune | 01/09/2026, CM | 3 |
| `i_tre_esiti_del_permesso_test.dart` | i tre esiti del permesso | 1, 2 | non scopre insiemi di file | mai | 3 |
| `i_tre_lucchetti_del_cielo_test.dart` | i tre lucchetti del cielo | 1, 2, 4 | proprio, dichiarato | mai | 3 |
| `i_tre_maestri_dominano_la_home_test.dart` | i tre maestri dominano la home | 4 | non scopre insiemi di file | mai | 3 |
| `i_tre_sentieri_si_disegnano_test.dart` | i tre sentieri si disegnano | 4 | non scopre insiemi di file | mai | 3 |
| `icona_cerchio_capture_test.dart` | icona cerchio capture | 4 | non scopre insiemi di file | mai | 3 |
| `il_benvenuto_e_la_dote_test.dart` | il benvenuto e la dote | 1, 2 | dalla porta comune | mai | 3 |
| `il_bordo_dei_piani_non_si_vede_test.dart` | il bordo dei piani non si vede | 4, 1 | non scopre insiemi di file | mai | 3 |
| `il_borsellino_si_aggiorna_ovunque_test.dart` | il borsellino si aggiorna ovunque | 1, 2 | dalla porta comune | mai | 3 |
| `il_borsellino_si_vede_sempre_test.dart` | il borsellino si vede sempre | 1, 2 | dalla porta comune | mai | 3 |
| `il_busto_e_la_forma_del_maestro_test.dart` | il busto e la forma del maestro | 1, 2 | dalla porta comune | mai | 3 |
| `i_conteggi_della_chat_stanno_stretti_test.dart` | i conteggi della chat stanno stretti | 1 | non scopre insiemi di file | 10/09/2026, DD (rossa due volte: 32 punti di aria su 16, e 0 di respiro con lo zero innestato) | 1 |
| `il_cambio_dell_email_test.dart` | il cambio dell email | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_campo_di_scrittura_e_opaco_test.dart` | il campo di scrittura e opaco | 4 | non scopre insiemi di file | mai | 3 |
| `il_capo_alzato_e_abbassato_non_si_scambiano_test.dart` | il capo alzato e abbassato non si scambiano | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `il_catalogo_copre_il_mondo_test.dart` | il catalogo copre il mondo | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_cerchio_del_soffio_riempie_la_scena_test.dart` | il cerchio del soffio riempie la scena | 1 | non scopre insiemi di file | 10/09/2026, DD (rossa sul difetto vero: 35,9 per cento invece di 70) | 1 |
| `il_censimento_dei_grigi_test.dart` | il censimento dei grigi | 1, 2 | proprio, dichiarato | 01/09/2026, CI | 2 |
| `il_censimento_delle_stringhe_dice_il_vero_test.dart` | il censimento delle stringhe dice il vero | 1, 2 | dalla porta comune | mai | 2 |
| `il_centro_viaggia_col_gesto_test.dart` | il centro viaggia col gesto | 1, 2 | proprio, dichiarato | 09/09/2026, DB | 2 |
| `il_cielo_arriva_al_maestro_test.dart` | il cielo arriva al maestro | 1, 2 | dalla porta comune | mai | 3 |
| `il_cielo_di_nascita_si_muove_test.dart` | il cielo di nascita si muove | 2, 4 | non scopre insiemi di file | mai | 3 |
| `il_cielo_dice_da_dove_test.dart` | il cielo dice da dove | 1, 2 | dalla porta comune | mai | 3 |
| `il_cielo_si_muove_davvero_test.dart` | il cielo si muove davvero | 4 | non scopre insiemi di file | mai | 3 |
| `il_cielo_si_muove_test.dart` | il cielo si muove | 1, 2, 4 | dalla porta comune | mai | 3 |
| `il_compimento_dei_tre_sentieri_test.dart` | il compimento dei tre sentieri | 4, 1 | non scopre insiemi di file | mai | 3 |
| `il_confronto_ha_il_suo_tetto_test.dart` | il confronto ha il suo tetto | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_consiglio_in_oro_test.dart` | il consiglio in oro | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_consiglio_mostra_tre_voci_test.dart` | il consiglio mostra tre voci | 1, 2 | dalla porta comune | mai | 3 |
| `il_consiglio_non_si_riscrive_test.dart` | il consiglio non si riscrive | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_continua_come_restituisce_il_cammino_test.dart` | il continua come restituisce il cammino | 1, 2 | dalla porta comune | mai | 3 |
| `il_conto_e_uno_solo_test.dart` | il conto e uno solo | 1, 2 | dalla porta comune | mai | 3 |
| `il_cuore_e_centrato_col_titolo_test.dart` | il cuore e centrato col titolo | 1 | non scopre insiemi di file | 04/09/2026, CQ | 2 |
| `il_cuore_non_copre_niente_test.dart` | il cuore non copre niente | 1 | proprio, dichiarato | mai | 2 |
| `il_cuore_sta_sempre_nello_stesso_angolo_test.dart` | il cuore dei preferiti sta sempre nello stesso angolo | 1, 2 | proprio, dichiarato | 10/09/2026, DD | 3 |
| `il_cuoricino_e_uno_solo_a_schermo_test.dart` | il cuoricino e uno solo, a schermo | 1, 2 | dalla porta comune | 10/09/2026, DD (rossa due volte: 2 cuori nell oroscopo dopo il responso, 2 nel fotogramma della ricomposizione) | 1 |
| `il_disco_dell_oracolo_dice_cosa_e_test.dart` | il disco dell oracolo dice cosa e | 1 | non scopre insiemi di file | mai | 3 |
| `il_dono_risponde_prima_di_chiedere_test.dart` | il Dono risponde prima di chiedere | 1, 2, 3 | proprio, dichiarato | CO | 2 |
| `il_filo_si_traccia_test.dart` | il filo si traccia | 1, 2 | dalla porta comune | mai | 3 |
| `il_foglio_dell_email_dice_cosa_non_va_test.dart` | il foglio dell email dice cosa non va | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_freno_del_gesto_ripetuto_test.dart` | il freno del gesto ripetuto | 1, 2 | proprio, dichiarato | 03/09/2026, CQ | 2 |
| `il_fuso_che_il_server_accetta_test.dart` | il fuso che il server accetta | 1, 2 | dalla porta comune | 03/09/2026, CQ | 1 |
| `il_giallo_delle_rune_parla_adesso_test.dart` | il giallo delle rune parla adesso | 1 | non scopre insiemi di file | 10/09/2026, DD (rossa sul difetto vero: 3 prose dorate su 9 invece di 1) | 1 |
| `il_gating_non_ha_fondi_bianchi_test.dart` | il gating non ha fondi bianchi | 1 | dalla porta comune | mai | 3 |
| `il_gemello_ha_la_sua_schermata_test.dart` | il gemello ha la sua schermata | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_genere_non_si_indovina_test.dart` | il genere non si indovina | 1, 2 | dalla porta comune | mai | 3 |
| `il_giorno_si_conta_dalla_porta_test.dart` | il giorno si conta dalla porta | 1, 2 | dalla porta comune | mai | 3 |
| `il_gradino_aspetta_il_congedo_test.dart` | il gradino aspetta il congedo | 1 | proprio, dichiarato | mai | 2 |
| `il_journal_arriva_in_fondo_test.dart` | il journal arriva in fondo | 4, 1 | non scopre insiemi di file | mai | 3 |
| `il_lettore_riceve_la_musica_test.dart` | il lettore riceve la musica | 4 | non scopre insiemi di file | mai | 3 |
| `il_listino_vivo_test.dart` | il listino vivo | 1 | dalla porta comune | mai | 3 |
| `il_livello_visivo_prima_del_testo_nei_riti_test.dart` | il livello visivo prima del testo nei riti | 1, 2 | dalla porta comune | mai | 3 |
| `il_loto_respira_coi_tempi_di_chi_respira_test.dart` | il loto respira coi tempi di chi respira | 1, 2 | non scopre insiemi di file | 08/09/2026, CZ | 2 |
| `il_loto_riempie_la_scena_test.dart` | il loto riempie la scena | 1 | proprio, dichiarato | 09/09/2026, DB | 2 |
| `il_loto_si_riempie_coi_giorni_test.dart` | il loto si riempie coi giorni | 1, 2 | non scopre insiemi di file | 08/09/2026, CZ | 2 |
| `il_luogo_di_nascita_e_la_sua_nazione_test.dart` | il luogo di nascita e la sua nazione | 4, 1 | non scopre insiemi di file | mai | 3 |
| `il_luogo_pulsa_e_si_trova_test.dart` | il luogo pulsa e si trova | 4 | non scopre insiemi di file | mai | 3 |
| `il_maestro_non_resta_muto_test.dart` | il maestro non resta muto | 1 | non scopre insiemi di file | mai | 3 |
| `il_mantra_di_oggi_ha_il_suo_riquadro_test.dart` | il mantra di oggi ha il suo riquadro | 1, 2 | non scopre insiemi di file | 07/09/2026, CW | 2 |
| `il_menu_delle_notifiche_si_tocca_test.dart` | il menu delle notifiche si tocca | 1 | non scopre insiemi di file | mai | 3 |
| `il_mian_xiang_non_promette_test.dart` | il Mian Xiang non promette e non diagnostica | 1, 2 | proprio, dichiarato | 06/09/2026, CR | 2 |
| `il_mood_del_cerchio_test.dart` | il mood del Cerchio: titolo corto, una porta sola, venti punti | 1, 2 | dalla porta comune | 04/09/2026, CQ | 2 |
| `il_motore_delle_eclissi_test.dart` | il motore delle eclissi | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_motore_locale_e_per_oggi_test.dart` | il motore locale e per oggi | 1, 2 | dalla porta comune | mai | 3 |
| `il_muro_non_passa_piu_test.dart` | il muro non passa piu | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `il_nome_breve_dell_oroscopo_test.dart` | il nome breve dell oroscopo | 1 | non scopre insiemi di file | mai | 3 |
| `il_nome_del_consiglio_test.dart` | il nome del consiglio | 1, 2 | dalla porta comune | mai | 3 |
| `il_nome_dichiara_la_sua_forma_test.dart` | il nome dichiara la sua forma | 1, 2 | dalla porta comune | mai | 2 |
| `il_numero_degli_angeli_segue_il_dato_test.dart` | il numero degli Angeli segue il dato, non la stringa | 1, 2 | proprio, dichiarato | 05/09/2026, CQ | 2 |
| `il_pannello_ha_due_titoli_test.dart` | il pannello ha due titoli | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_passaporto_porta_a_sbloccare_test.dart` | il passaporto porta a sbloccare | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_permesso_appena_dato_accende_tutte_e_cinque_test.dart` | il permesso appena dato accende tutte e cinque | 1, 2 | proprio, dichiarato | 07/09/2026, CW | 2 |
| `il_piano_attivo_e_i_suoi_tetti_test.dart` | il piano attivo e i suoi tetti | 1 | proprio, dichiarato | mai | 2 |
| `il_pozzo_in_attesa_non_e_un_vuoto_test.dart` | il pozzo in attesa non e un vuoto | 4, 1 | non scopre insiemi di file | mai | 3 |
| `il_pozzo_non_ha_lacqua_rossa_test.dart` | il pozzo non ha lacqua rossa | 4 | non scopre insiemi di file | mai | 3 |
| `il_quaderno_dei_sogni_non_torna_test.dart` | il quaderno dei sogni non torna | 1, 2 | dalla porta comune | 03/09/2026, CP | 3 |
| `il_registro_delle_guardie_quadra_test.dart` | il registro delle guardie quadra | 1, 2 | dalla porta comune | 01/09/2026, CM | 3 |
| `il_respiro_vive_nel_soffio_test.dart` | il respiro vive nel soffio | 1, 2 | dalla porta comune | mai | 3 |
| `il_responso_del_viso_non_e_sempre_lo_stesso_test.dart` | il responso del viso non e sempre lo stesso | 1, 2 | proprio, dichiarato | 08/09/2026, CX | 1 |
| `il_responso_e_lo_stesso_fino_a_mezzanotte_test.dart` | il responso e lo stesso fino a mezzanotte | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_retro_vergine_ha_una_porta_sola_test.dart` | il retro vergine ha una porta sola | 1, 2 | dalla porta comune | mai | 2 |
| `il_rientro_non_muore_in_silenzio_test.dart` | il rientro non muore in silenzio | 1 | non scopre insiemi di file | mai | 3 |
| `il_ripiego_del_cielo_non_e_un_vicolo_cieco_test.dart` | il ripiego del cielo non e un vicolo cieco | 4 | non scopre insiemi di file | 07/09/2026, CS | 3 |
| `il_ripiego_non_si_traveste_da_carta_test.dart` | il ripiego non si traveste da carta | 1, 2 | dalla porta comune | mai | 3 |
| `il_ritorno_non_e_una_porta_di_servizio_test.dart` | il ritorno non e una porta di servizio | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `il_secondo_strato_e_premium_test.dart` | il secondo strato e premium | 1, 2 | dalla porta comune | mai | 3 |
| `il_seguito_scende_sotto_test.dart` | il seguito scende sotto | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_sentiero_si_legge_test.dart` | il sentiero si legge | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_sigillo_del_giorno_dice_a_cosa_serve_test.dart` | il Sigillo del Giorno dice a cosa serve | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `il_sigillo_del_giorno_e_un_sigillo_test.dart` | il sigillo del giorno e un sigillo | 4 | non scopre insiemi di file | mai | 3 |
| `il_sigillo_del_sogno_nomina_un_maestro_solo_test.dart` | il sigillo del sogno nomina un maestro solo | 1, 2 | non scopre insiemi di file | 07/09/2026, CW | 2 |
| `il_simbolo_si_compone_test.dart` | il simbolo si compone | 1, 2 | dalla porta comune | mai | 3 |
| `il_soffio_si_riconosce_dalla_forma_test.dart` | il soffio si riconosce dalla forma | 1 | proprio, dichiarato | 10/09/2026, DD (rossa sul difetto vero: 3 aperture false su 3 con la soglia di volume) | 1 |
| `il_soffio_non_si_accavalla_test.dart` | il soffio non si accavalla | 1 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `il_soffio_non_somiglia_all_alba_test.dart` | il soffio non somiglia all alba | 2, 4 | non scopre insiemi di file | mai | 3 |
| `il_solco_scava_la_pietra_vera_test.dart` | il solco scava la pietra vera | 4 | non scopre insiemi di file | mai | 3 |
| `il_suono_dice_il_vero_test.dart` | il suono dice il vero | 1, 2 | non scopre insiemi di file | CO | 3 |
| `il_suono_si_ferma_test.dart` | il suono si ferma | 1, 2 | dalla porta comune | mai | 3 |
| `il_target_ios_e_il_massimo_dei_plugin_test.dart` | il target ios e il massimo dei plugin | 1, 2 | non scopre insiemi di file | mai | 3 |
| `il_tetto_del_piano_nuovo_nasce_intero_test.dart` | il tetto del piano nuovo nasce intero | 1, 4 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `il_titolo_del_respiro_sta_sul_velo_test.dart` | il titolo del respiro sta sul velo | 4 | non scopre insiemi di file | mai | 3 |
| `il_titolo_non_si_rompe_test.dart` | il titolo non si rompe | 1, 2 | dalla porta comune | mai | 3 |
| `il_titolo_non_stampa_sul_contenuto_test.dart` | il titolo non stampa sul contenuto | 1, 2, 4 | non scopre insiemi di file | mai | 3 |
| `il_velo_e_uno_solo_test.dart` | il velo e uno solo | 1 | dalla porta comune | 01/09/2026, CL | 3 |
| `il_ventaglio_vive_subito_test.dart` | il ventaglio vive subito | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `il_video_e_lo_sfondo_della_rivelazione_test.dart` | il video e lo sfondo della rivelazione | 1 | non scopre insiemi di file | mai | 3 |
| `il_volto_nel_tondo_test.dart` | il volto nel tondo | 4 | non scopre insiemi di file | mai | 3 |
| `il_volto_non_esce_dal_dispositivo_test.dart` | il volto non esce dal dispositivo, verificato negli import | 1, 2 | proprio, dichiarato | 06/09/2026, CR | 2 |
| `il_volto_non_si_misura_schiacciato_test.dart` | il volto non si misura schiacciato | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `il_volume_non_resta_giu_test.dart` | il volume non resta giu | 4 | non scopre insiemi di file | mai | 3 |
| `il_vuoto_sotto_i_maestri_test.dart` | il vuoto sotto i maestri | 1 | non scopre insiemi di file | mai | 3 |
| `intro_test.dart` | intro | 1, 2 | dalla porta comune | mai | 3 |
| `l_account_dice_chi_sei_e_come_uscire_test.dart` | l account dice chi sei e come uscire | 1, 2 | non scopre insiemi di file | mai | 3 |
| `l_alba_e_il_soffio_non_dicono_lo_stesso_test.dart` | l Alba e il Soffio non dicono lo stesso | 1, 2 | proprio, dichiarato | 03/09/2026, CQ | 2 |
| `l_alba_e_il_soffio_non_dicono_mai_lo_stesso_test.dart` | l alba e il soffio non dicono mai lo stesso | 1, 2 | proprio, dichiarato | 07/09/2026, CW | 2 |
| `l_alba_e_individuale_test.dart` | l alba e individuale | 4 | non scopre insiemi di file | 06/09/2026, CS | 3 |
| `l_alba_non_si_ripete_mai_test.dart` | l alba non si ripete mai | 1, 2 | proprio, dichiarato | 08/09/2026, CY | 2 |
| `l_alba_si_legge_test.dart` | l alba si legge | 1, 2, 4 | dalla porta comune | CO | 3 |
| `l_anello_del_livello_test.dart` | l anello del livello | 4 | non scopre insiemi di file | 03/09/2026, CP | 3 |
| `l_arcano_del_giorno_test.dart` | l arcano del giorno | 1, 2 | proprio, dichiarato | mai | 3 |
| `l_arcano_e_del_singolo_test.dart` | l Arcano e del singolo | 1, 2 | proprio, dichiarato | 03/09/2026, CQ | 2 |
| `l_asserzione_non_pesca_il_suo_commento_test.dart` | l asserzione non pesca il suo commento | 1, 2 | proprio, dichiarato | 08/09/2026, CZ | 2 |
| `l_effetto_non_aspetta_la_piattaforma_test.dart` | l effetto non aspetta la piattaforma | 1, 2, 4 | dalla porta comune | 03/09/2026, CQ | 1 |
| `l_emblema_sta_nel_suo_riquadro_test.dart` | l emblema sta nel suo riquadro | 4 | non scopre insiemi di file | mai | 3 |
| `l_espressione_non_diagnostica_test.dart` | l espressione legge muscoli, non stati d animo | 1, 2 | proprio, dichiarato | 06/09/2026, CR | 2 |
| `l_evento_che_arma_e_la_condizione_scritta_test.dart` | ogni gradino si accende con la quantita che dichiara, e non con una di meno | 1, 2 | proprio, dichiarato | 03/09/2026, CP | 2 |
| `l_intro_zittisce_la_musica_test.dart` | l intro zittisce la musica finche dura | 2, 3 | non scopre insiemi di file | CO | 2 |
| `l_invito_non_cade_sulla_fase_lunare_test.dart` | l invito al cielo non cade sul nome della fase | 4 | non scopre insiemi di file | 08/09/2026, CZ | 1 |
| `l_onboarding_riconosce_e_propone_test.dart` | l onboarding riconosce e propone | 1, 2 | dalla porta comune | mai | 3 |
| `la_barra_scivola_sopra_test.dart` | la barra scivola sopra | 1 | non scopre insiemi di file | mai | 3 |
| `la_barra_sottile_e_la_casa_unica_test.dart` | la barra sottile e la casa unica | 1, 2 | dalla porta comune | mai | 3 |
| `la_bolla_dei_traguardi_test.dart` | la bolla dei traguardi | 1, 2 | non scopre insiemi di file | mai | 3 |
| `la_bolla_respira_in_fondo_test.dart` | la bolla respira in fondo | 4 | non scopre insiemi di file | mai | 3 |
| `la_card_del_respiro_e_diversa_ogni_volta_test.dart` | la card del respiro e diversa ogni volta | 1, 2 | proprio, dichiarato | 09/09/2026, DB | 2 |
| `la_card_del_viso_dice_il_vero_test.dart` | la card del viso dice il vero | 1 | proprio, dichiarato | 09/09/2026, CX | 2 |
| `la_card_del_viso_porta_all_app_test.dart` | la card del viso porta all app | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `la_card_si_manda_test.dart` | la card si manda: una frase, un simbolo suo, poco altro | 1, 3 | dalla porta comune | 04/09/2026, CQ | 2 |
| `la_card_vecchia_e_demolita_test.dart` | la card vecchia e demolita | 1, 2 | dalla porta comune | mai | 3 |
| `la_carta_di_nascita_si_vede_test.dart` | la carta di nascita si vede | 4 | non scopre insiemi di file | 07/09/2026, CS | 3 |
| `la_carta_girata_suona_test.dart` | il suono della carta esce dalla porta unica | 3 | non scopre insiemi di file | CO | 2 |
| `la_carta_natale_sopravvive_test.dart` | la carta natale sopravvive | 1, 2 | dalla porta comune | mai | 3 |
| `la_carta_suona_toccandola_test.dart` | la carta suona toccandola | 1, 4 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `la_catena_dei_dati_di_nascita_test.dart` | la catena dei dati di nascita | 1, 2 | dalla porta comune | mai | 3 |
| `la_celebrazione_offre_sempre_la_condivisione_test.dart` | la celebrazione offre sempre la condivisione | 1, 2 | dalla porta comune | mai | 3 |
| `la_chat_lascia_spazio_alla_conversazione_test.dart` | la chat lascia spazio alla conversazione | 4 | non scopre insiemi di file | 07/09/2026, CT | 3 |
| `la_chat_non_si_apre_sul_vuoto_test.dart` | la chat non si apre su mezzo schermo di vuoto | 1, 2 | non scopre insiemi di file | CO | 3 |
| `la_chat_si_legge_test.dart` | la chat si legge | 2, 4, 1 | non scopre insiemi di file | mai | 3 |
| `la_chiave_e_il_consiglio_si_vedono_test.dart` | la chiave e il consiglio si vedono | 1, 2, 4 | proprio, dichiarato | CO | 3 |
| `la_colonna_dei_suggerimenti_non_esiste_piu_test.dart` | la colonna dei suggerimenti non esiste piu | 1 | dalla porta comune | mai | 3 |
| `la_corsa_dello_zodiaco_test.dart` | la corsa dello zodiaco | 1 | proprio, dichiarato | mai | 3 |
| `la_domanda_entra_nel_responso_test.dart` | la domanda entra nel responso | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `la_domanda_libera_si_trova_test.dart` | la domanda libera si trova | 1 | non scopre insiemi di file | 03/09/2026, CQ | 3 |
| `la_domanda_scelta_arriva_al_responso_test.dart` | la domanda scelta arriva al responso | 1, 2 | dalla porta comune | mai | 3 |
| `la_domanda_viene_prima_test.dart` | la domanda viene prima | 4, 1 | non scopre insiemi di file | mai | 3 |
| `la_fascia_in_fondo_alla_home_test.dart` | la fascia in fondo alla home | 1 | non scopre insiemi di file | mai | 3 |
| `la_festa_aspetta_la_riflessione_test.dart` | la festa aspetta la riflessione | 1, 2 | dalla porta comune | mai | 3 |
| `la_figura_della_card_nasce_dalle_misure_test.dart` | la figura della card nasce dalle misure | 1, 2 | proprio, dichiarato | 09/09/2026, CX | 2 |
| `la_freccia_del_fumetto_si_vede_test.dart` | la freccia del fumetto si vede | 1, 2 | non scopre insiemi di file | mai | 3 |
| `la_frequenza_la_assegna_aura_test.dart` | la frequenza la assegna aura | 1, 2 | non scopre insiemi di file | 08/09/2026, CZ | 2 |
| `la_galleria_vip_si_capisce_test.dart` | la galleria vip si capisce | 1 | proprio, dichiarato | mai | 3 |
| `la_gettata_a_tre_rune_risponde_test.dart` | la gettata a tre rune risponde alla domanda | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `la_home_non_copre_e_non_tronca_test.dart` | la home non copre e non tronca | 1 | non scopre insiemi di file | mai | 3 |
| `la_home_non_rallenta_al_ritorno_test.dart` | la home non rallenta al ritorno | 1 | non scopre insiemi di file | mai | 3 |
| `la_lampadina_si_accende_al_traguardo_test.dart` | la lampadina si accende al traguardo | 4 | non scopre insiemi di file | 03/09/2026, CP | 3 |
| `la_lampadina_si_distingue_test.dart` | la lampadina si distingue | 4, 1 | non scopre insiemi di file | mai | 3 |
| `la_libreria_si_apre_e_la_pratica_parte_test.dart` | la libreria si apre e il rito si compone | 1, 4 | proprio, dichiarato | 09/09/2026, DB | 2 |
| `la_meditazione_ha_il_suo_cielo_test.dart` | la meditazione ha il suo cielo | 1 | non scopre insiemi di file | 10/09/2026, DD (rossa: zero cieli montati col difetto innestato) | 1 |
| `la_maschera_segue_solo_un_volto_vero_test.dart` | la maschera segue solo un volto vero | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `la_materia_storica_non_apre_la_scena_test.dart` | la materia storica non apre la scena, sta dietro la porta | 1, 2 | proprio, dichiarato | 05/09/2026, CQ | 2 |
| `la_meditazione_non_nomina_malattie_test.dart` | la meditazione non nomina malattie | 1, 2 | proprio, dichiarato | 09/09/2026, DB | 2 |
| `la_misura_del_ritorno_test.dart` | la misura del ritorno | 1, 2 | dalla porta comune | mai | 3 |
| `la_musica_parte_davvero_test.dart` | la musica parte davvero | 4 | non scopre insiemi di file | mai | 3 |
| `la_musica_riprende_solo_se_stava_suonando_test.dart` | la musica riprende solo se stava suonando | 1, 2 | non scopre insiemi di file | 07/09/2026, CW | 2 |
| `la_musica_segue_il_luogo_test.dart` | la musica segue il luogo | 1, 2 | dalla porta comune | CO | 3 |
| `la_nota_non_mente_test.dart` | la nota non mente | 1, 2 | dalla porta comune | mai | 3 |
| `la_parola_del_giorno_si_vede_nella_frase_test.dart` | la parola del giorno si vede nella frase | 1, 2 | dalla porta comune | 10/09/2026, DD (rossa tre volte con la parola nuda innestata) | 1 |
| `la_parola_dice_a_cosa_serve_test.dart` | la parola del giorno dice a cosa serve | 1 | non scopre insiemi di file | 04/09/2026, CQ | 2 |
| `la_parola_torna_la_sera_test.dart` | la parola del giorno torna la sera | 1 | proprio, dichiarato | 09/09/2026, CY | 2 |
| `la_parola_voce_resta_allaudio_test.dart` | la parola voce resta allaudio | 1 | dalla porta comune | mai | 3 |
| `la_porta_della_sinastria_test.dart` | la porta della sinastria | 1 | non scopre insiemi di file | mai | 3 |
| `la_registrazione_non_interrompe_il_risveglio_test.dart` | la registrazione non interrompe il risveglio | 1, 2 | dalla porta comune | mai | 3 |
| `la_riga_del_campo_e_pulita_test.dart` | la riga del campo e pulita | 4, 1 | non scopre insiemi di file | mai | 3 |
| `la_runa_cade_e_non_e_gia_li_test.dart` | la runa cade e non e gia li | 1, 2 | proprio, dichiarato | mai | 3 |
| `la_runa_rovesciata_ha_la_sua_lettura_test.dart` | la runa rovesciata ha la sua lettura | 1, 2 | proprio, dichiarato | mai | 2 |
| `la_runa_singola_non_e_una_lezione_test.dart` | la runa singola non e una lezione | 1 | non scopre insiemi di file | 04/09/2026, CQ | 2 |
| `la_scansione_non_salta_avanti_test.dart` | la scansione non salta avanti, e la vitalita e strutturale | 1, 2 | proprio, dichiarato | 06/09/2026, CR | 2 |
| `la_scansione_si_puo_sempre_rifare_test.dart` | la scansione si puo sempre rifare, e si vede | 1, 2 | non scopre insiemi di file | 08/09/2026, CX | 1 |
| `la_scena_non_copre_la_conversazione_test.dart` | la scena non copre la conversazione | 1, 2, 4 | proprio, dichiarato | mai | 3 |
| `la_sentinella_dorme_in_secondo_piano_test.dart` | la sentinella dorme in secondo piano | 1, 2 | non scopre insiemi di file | 08/09/2026, CY | 2 |
| `la_soglia_del_viso_ha_due_momenti_test.dart` | la soglia del viso ha due momenti | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `la_spirale_di_stelle_test.dart` | la spirale di stelle | 2, 4 | non scopre insiemi di file | CO, RESTATA VERDE col difetto dentro | 3 |
| `la_stella_che_chiama_il_tocco_test.dart` | la stella che chiama il tocco | 4 | non scopre insiemi di file | mai | 3 |
| `la_stella_non_finisce_sotto_il_testo_test.dart` | la stella non finisce sotto il testo | 1, 2, 4 | proprio, dichiarato | 03/09/2026, CQ | 2 |
| `la_stella_si_tocca_davvero_test.dart` | la stella si tocca davvero | 1, 4 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `la_stesa_comincia_quando_lo_dici_test.dart` | la stesa comincia quando lo dici tu | 1, 2 | non scopre insiemi di file | 04/09/2026, CQ | 2 |
| `la_stesa_si_capisce_test.dart` | la stesa si capisce | 1, 2, 4 | proprio, dichiarato | CO | 3 |
| `la_striscia_delle_arti_anche_in_home_test.dart` | la striscia delle arti anche in home | 1, 2 | dalla porta comune | mai | 3 |
| `la_sveglia_trova_chi_la_riceve_test.dart` | la sveglia trova chi la riceve | 1, 2 | proprio, dichiarato | 08/09/2026, CZ | 2 |
| `la_terza_carta_non_apre_una_schermata_test.dart` | la terza carta non apre una schermata | 1 | proprio, dichiarato | 10/09/2026, DD (rossa due volte: cardinale 6 su 7, e gli slot in coda invece che in testa) | 2 |
| `la_testa_del_maestro_non_si_taglia_test.dart` | la testa del Maestro non si taglia a lettere grandi | 1, 2 | proprio, dichiarato | CO | 2 |
| `la_testata_non_copre_il_maestro_test.dart` | la testata non copre il maestro | 1, 2 | non scopre insiemi di file | mai | 3 |
| `la_verifica_degli_angeli_e_vera_test.dart` | la verifica degli angeli e vera | 4 | non scopre insiemi di file | 06/09/2026, CS | 3 |
| `la_voce_account_nelle_impostazioni_e_viva_test.dart` | la voce account nelle impostazioni e viva | 1, 2 | non scopre insiemi di file | mai | 3 |
| `language_rule_test.dart` | language rule | 1, 2 | dalla porta comune | 01/09/2026, CL | 2 |
| `le_chiavi_di_ios_ci_sono_tutte_test.dart` | le chiavi di ios ci sono tutte | 4 | non scopre insiemi di file | mai | 3 |
| `le_cinque_chiamate_partono_tutte_test.dart` | le cinque chiamate partono tutte | 1, 2 | proprio, dichiarato | 07/09/2026, CW | 2 |
| `le_cose_che_dichiarano_il_falso_test.dart` | le cose che dichiarano il falso | 1, 2 | dalla porta comune | mai | 2 |
| `le_descrizioni_hanno_una_misura_sola_test.dart` | le descrizioni hanno una misura sola | 1, 2 | dalla porta comune | mai | 3 |
| `le_due_cose_che_non_servivano_test.dart` | le due cose che non servivano | 1, 2 | dalla porta comune | mai | 3 |
| `le_feste_e_le_regole_che_le_trattengono_test.dart` | le feste e le regole che le trattengono | 1, 2 | proprio, dichiarato | CO, RESTATA VERDE col difetto dentro | 3 |
| `le_feste_si_vedono_diverse_test.dart` | le feste si vedono diverse | 2, 4, 1 | non scopre insiemi di file | mai | 3 |
| `le_nove_frequenze_si_vedono_tutte_test.dart` | le nove frequenze si vedono tutte | 1, 2 | proprio, dichiarato | 10/09/2026, DD (rossa: nove etichette su nove andavano a capo, fino a sette righe) | 1 |
| `le_fonti_dei_respiri_dicono_il_vero_test.dart` | le fonti dei respiri dicono il vero | 1 | proprio, dichiarato | 10/09/2026, DD (rossa due volte: sintomo ripetuto, sintomo orfano) | 2 |
| `le_fonti_della_meditazione_dicono_il_vero_test.dart` | le fonti della meditazione dicono il vero | 1, 2 | non scopre insiemi di file | 08/09/2026, CZ | 2 |
| `le_frasi_della_custodia_dicono_il_vero_test.dart` | le frasi della custodia dicono il vero | 1, 2 | dalla porta comune | mai | 3 |
| `le_parole_dicono_tieni_premuto_test.dart` | le parole dicono tieni premuto | 1, 2 | dalla porta comune | mai | 3 |
| `le_pietre_sono_scontornate_test.dart` | le pietre sono scontornate | 1 | non scopre insiemi di file | mai | 3 |
| `le_push_dei_doni_test.dart` | le push dei doni | 1, 2 | dalla porta comune | mai | 3 |
| `le_regole_dei_traguardi_sono_rispettate_test.dart` | le undici regole del fondatore su ogni singolo gradino | 1, 2 | dalla porta comune | 03/09/2026, CP | 2 |
| `le_sette_chiavi_del_collaudo_test.dart` | le sette chiavi del collaudo | 1, 2 | dalla porta comune | mai | 3 |
| `le_soglie_della_scansione_sono_provvisorie_test.dart` | le soglie della scansione sono provvisorie, ROSSA APPOSTA | 4 | non scopre insiemi di file | 06/09/2026, CR | 2 |
| `le_stelle_della_festa_sono_stelle_test.dart` | le stelle della festa sono stelle, sui pixel | 2 | proprio, dichiarato | CO | 3 |
| `lo_sbarramento_distingue_i_rossi_test.dart` | lo sbarramento distingue i rossi | 1, 2 | proprio, dichiarato | 01/09/2026, CM, il terzo cancello | 3 |
| `lo_scuotimento_ha_una_porta_sola_test.dart` | lo scuotimento ha una porta sola | 1, 2 | dalla porta comune | mai | 2 |
| `lo_spazio_dentro_lo_scroll_test.dart` | lo spazio dentro lo scroll | 1, 2 | dalla porta comune | mai | 3 |
| `lo_specchio_dell_istante_arriva_test.dart` | lo specchio dell istante arriva | 4 | non scopre insiemi di file | 06/09/2026, CR | 3 |
| `mai_piu_blu_sul_loto_test.dart` | mai piu blu sul loto | 4, 1 | non scopre insiemi di file | mai | 3 |
| `miniature_intere_test.dart` | miniature intere | 1, 2 | dalla porta comune | mai | 3 |
| `motore_audio_unico_test.dart` | motore audio unico | 1, 2 | dalla porta comune | mai | 3 |
| `nessun_accento_dichiara_un_fondo_che_non_ha_test.dart` | nessun accento dichiara un fondo che non ha | 1, 2 | dalla porta comune | 04/09/2026, CQ | 2 |
| `nessun_anello_si_dipinge_fuori_dal_suo_riquadro_test.dart` | nessun anello si dipinge fuori dal suo riquadro | 4 | non scopre insiemi di file | 07/09/2026, CT | 3 |
| `nessun_campo_dice_di_aspettare_test.dart` | nessun campo dice di aspettare | 1, 2 | proprio, dichiarato | mai | 3 |
| `nessun_catch_muto_test.dart` | nessun catch muto | 1 | dalla porta comune | 01/09/2026, CN | 3 |
| `nessun_foglio_e_bianco_test.dart` | nessun foglio e bianco | 1, 2 | proprio, dichiarato | mai | 3 |
| `nessun_invito_a_un_permesso_e_muto_test.dart` | nessun invito a un permesso e muto | 1, 2 | non scopre insiemi di file | mai | 3 |
| `nessun_pittore_dipinge_sul_nulla_test.dart` | nessun pittore dipinge sul nulla | 1, 2 | dalla porta comune | 10/09/2026, DC | 1 |
| `nessun_punto_cade_dentro_il_titolo_test.dart` | nessun punto cade dentro il titolo | 1, 2 | non scopre insiemi di file | 07/09/2026, CW | 2 |
| `nessun_quadrato_rosso_test.dart` | nessun quadrato rosso | 4 | non scopre insiemi di file | mai | 3 |
| `nessun_rosso_attraversa_una_consegna_test.dart` | nessun rosso attraversa una consegna | 1, 2 | proprio, dichiarato | 08/09/2026, CZ | 2 |
| `nessun_suono_che_non_hai_scelto_test.dart` | nessun suono che non hai scelto | 1, 2, 4 | dalla porta comune | 03/09/2026, CQ | 1 |
| `nessun_suono_sintetizzato_esce_dai_responsi_test.dart` | nessun suono sintetizzato esce dai responsi | 1, 2 | dalla porta comune | 04/09/2026, CQ | 2 |
| `nessun_testo_finisce_sotto_test.dart` | nessun testo finisce sotto | 4, 1 | non scopre insiemi di file | mai | 3 |
| `nessun_traguardo_resta_indietro_test.dart` | nessun traguardo resta indietro | 1, 2 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `nessuna_azione_committa_da_sola_test.dart` | nessuna azione committa da sola | 1 | dalla porta comune | mai | 3 |
| `nessuna_frase_esce_due_volte_test.dart` | nessuna frase esce due volte | 1, 2 | proprio, dichiarato | 08/09/2026, CY | 2 |
| `nessuna_promessa_di_memoria_integrale_test.dart` | nessuna promessa di memoria integrale | 1, 2 | proprio, dichiarato | mai | 3 |
| `nessuna_sorgente_resta_accesa_in_sottofondo_test.dart` | nessuna sorgente resta accesa in sottofondo | 1, 2 | dalla porta comune | 07/09/2026, CT | 2 |
| `nessuno_disegna_oltre_la_tela_test.dart` | nessuno disegna oltre la tela | 1, 2 | proprio, dichiarato | mai | 3 |
| `niente_eco_test.dart` | niente eco | 1, 2 | dalla porta comune | 01/09/2026, CM | 3 |
| `niente_resta_di_te_test.dart` | niente resta di te | 1, 2 | proprio, dichiarato | mai | 3 |
| `niente_sottolineature_gialle_test.dart` | niente sottolineature gialle | 1, 2 | dalla porta comune | mai | 3 |
| `niente_vocativo_a_schermo_test.dart` | niente vocativo a schermo | 1, 2 | dalla porta comune | mai | 3 |
| `nome_ovunque_test.dart` | nome ovunque | 1, 2 | non scopre insiemi di file | mai | 3 |
| `nove_arti_test.dart` | nove arti | 1, 2 | dalla porta comune | mai | 3 |
| `numero_e_colore_hanno_la_stessa_altezza_test.dart` | numero e colore hanno la stessa altezza | 1 | non scopre insiemi di file | 10/09/2026, DD (rossa sul difetto vero: 61,0 contro 84,0) | 1 |
| `ogni_arte_dichiara_la_fonte_test.dart` | ogni arte dichiara la fonte | 4 | non scopre insiemi di file | 06/09/2026, CS | 3 |
| `ogni_arte_entra_nel_cammino_test.dart` | ogni arte entra nel cammino | 1, 2 | non scopre insiemi di file | 03/09/2026, CP | 3 |
| `ogni_budget_dichiara_il_suo_residuo_test.dart` | ogni budget dichiara il suo residuo | 1, 2 | dalla porta comune | CO | 2 |
| `ogni_categoria_misura_qualcosa_test.dart` | ogni categoria misura qualcosa, e il numero si legge | 1, 2 | proprio, dichiarato | 08/09/2026, CX | 1 |
| `ogni_condivisione_dichiara_gli_eos_test.dart` | ogni condivisione dichiara gli eos | 1, 2 | dalla porta comune | mai | 2 |
| `ogni_freccia_mantiene_test.dart` | ogni freccia mantiene | 1, 2 | proprio, dichiarato | 31/08/2026, CG | 3 |
| `ogni_guardia_dichiara_quanto_guarda_test.dart` | ogni guardia dichiara quanto guarda | 1, 2 | dalla porta comune | mai | 2 |
| `ogni_perla_porta_alla_sua_voce_test.dart` | ogni perla porta alla sua voce | 1 | non scopre insiemi di file | mai | 3 |
| `ogni_rotta_passa_dal_nero_test.dart` | ogni rotta passa dal nero | 1, 2 | dalla porta comune | mai | 3 |
| `ogni_schermata_dichiara_la_barra_test.dart` | ogni schermata dichiara la barra | 1 | dalla porta comune | mai | 2 |
| `ogni_sensore_ha_il_suo_ripiego_test.dart` | ogni sensore ha il suo ripiego | 1, 2 | dalla porta comune | mai | 3 |
| `ogni_tessera_che_apre_lo_dice_test.dart` | ogni tessera che apre lo dice | 1, 2 | non scopre insiemi di file | mai | 3 |
| `ogni_testo_dice_da_dove_nasce_test.dart` | ogni testo dice da dove nasce | 4 | non scopre insiemi di file | 07/09/2026, CS | 3 |
| `ogni_traguardo_acceso_ha_la_sua_festa_test.dart` | ogni traguardo acceso ha la sua festa | 1, 2 | proprio, dichiarato | 08/09/2026, CZ | 2 |
| `ogni_via_dice_cosa_si_accetta_test.dart` | ogni via dice cosa si accetta | 1, 2 | proprio, dichiarato | mai | 3 |
| `ora_di_nascita_test.dart` | ora di nascita | 1, 2 | dalla porta comune | mai | 3 |
| `ora_e_luogo_sopravvivono_test.dart` | ora e luogo sopravvivono | 1, 2 | dalla porta comune | mai | 3 |
| `ora_si_puo_correggere_test.dart` | ora si puo correggere | 1, 2 | dalla porta comune | mai | 3 |
| `ordine_ch_guard_test.dart` | ordine ch guard | 1, 2 | non scopre insiemi di file | mai | 3 |
| `ordine_cl_guard_test.dart` | ordine cl guard | 4 | non scopre insiemi di file | mai | 3 |
| `ordine_cm_guard_test.dart` | ordine cm guard | 1, 2 | dalla porta comune | mai | 2 |
| `ordine_cn_guard_test.dart` | ordine cn guard | 1, 2 | non scopre insiemi di file | 01/09/2026, CN, sul manifesto vero | 3 |
| `ordine_co_guard_test.dart` | ordine co guard | 1, 2 | proprio, dichiarato | CO, nata rossa sul manifesto assente | 3 |
| `ordine_cp_guard_test.dart` | ordine CP guard | 1, 2 | proprio, dichiarato | mai | 2 |
| `ordine_cq_guard_test.dart` | ordine CQ guard | 1, 2 | proprio, dichiarato | mai | 2 |
| `palette_sensoriale_test.dart` | palette sensoriale | 1, 2 | dalla porta comune | 01/09/2026, CN | 3 |
| `passport_carta_natale_test.dart` | passport carta natale | 1, 2 | dalla porta comune | mai | 3 |
| `passport_test.dart` | passport | 1 | non scopre insiemi di file | mai | 3 |
| `porta_dati_nascita_test.dart` | porta dati nascita | 1, 2 | dalla porta comune | mai | 3 |
| `prima_dopo_capture_test.dart` | prima dopo capture | 4, 1 | non scopre insiemi di file | mai | 3 |
| `pulsante_non_copre_carta_test.dart` | pulsante non copre carta | 4 | non scopre insiemi di file | mai | 3 |
| `quante_costellazioni_distinte_test.dart` | quante costellazioni distinte esistono | 1 | proprio, dichiarato | 09/09/2026, CX | 2 |
| `ronda_dei_motori_test.dart` | ronda dei motori | 1, 2 | proprio, dichiarato | mai | 3 |
| `rune_draw_screen_test.dart` | rune draw screen | 1 | non scopre insiemi di file | mai | 3 |
| `santuario_shelf_test.dart` | santuario shelf | 1 | non scopre insiemi di file | mai | 3 |
| `scegliere_la_gettata_non_getta_test.dart` | scegliere la gettata non getta | 1, 2 | proprio, dichiarato | 03/09/2026, CQ | 2 |
| `scelta_del_soffio_resta_test.dart` | scelta del soffio resta | 1, 2 | non scopre insiemi di file | mai | 3 |
| `scena_unica_test.dart` | scena unica | 1, 2 | proprio, dichiarato | mai | 3 |
| `screenshot_capture_test.dart` | screenshot capture | 1, 4 | non scopre insiemi di file | 01/09/2026, CI | 3 |
| `segno_non_e_parametro_test.dart` | segno non e parametro | 1 | non scopre insiemi di file | mai | 3 |
| `segno_vero_test.dart` | segno vero | 1 | non scopre insiemi di file | mai | 3 |
| `senza_volto_non_c_e_responso_test.dart` | senza volto non c e responso: il cancello della scansione | 1, 2 | proprio, dichiarato | 06/09/2026, CR | 2 |
| `sigillo_al_centro_test.dart` | sigillo al centro | 1 | non scopre insiemi di file | mai | 3 |
| `simboli_dello_zodiaco_test.dart` | simboli dello zodiaco | 1, 2 | dalla porta comune | mai | 3 |
| `sinastria_accents_test.dart` | sinastria accents | 1 | non scopre insiemi di file | mai | 3 |
| `stato_asset_test.dart` | stato asset | 1 | non scopre insiemi di file | 01/09/2026, CN | 3 |
| `stesa_tre_carte_test.dart` | stesa tre carte | 1 | non scopre insiemi di file | mai | 3 |
| `sunset_incisione_pixel_test.dart` | sunset incisione pixel | 4 | non scopre insiemi di file | mai | 3 |
| `tarot_accordo_rovescio_test.dart` | tarot accordo rovescio | 1, 2 | dalla porta comune | mai | 3 |
| `tarot_cartigli_test.dart` | tarot cartigli | 4 | non scopre insiemi di file | mai | 3 |
| `testi_falsi_test.dart` | testi falsi | 1, 2 | proprio, dichiarato | mai | 3 |
| `testo_a_video_test.dart` | testo a video | 1, 2 | dalla porta comune | 01/09/2026, CL | 2 |
| `tipografia_minimi_test.dart` | tipografia minimi | 1 | dalla porta comune | mai | 3 |
| `un_comando_di_distribuzione_ha_il_suo_controllo_test.dart` | un comando di distribuzione ha il suo controllo | 1, 3 | proprio, dichiarato | 04/09/2026, CQ | 2 |
| `un_ripiego_non_costa_test.dart` | un ripiego non costa | 1, 2 | dalla porta comune | mai | 3 |
| `un_solo_istante_test.dart` | un solo istante | 1, 2 | non scopre insiemi di file | mai | 3 |
| `una_barra_sola_test.dart` | una barra sola | 1 | non scopre insiemi di file | mai | 3 |
| `una_festa_alla_volta_e_il_fondo_si_oscura_test.dart` | una festa alla volta e il fondo si oscura | 1, 2, 4 | non scopre insiemi di file | mai | 3 |
| `una_figura_sola_test.dart` | una figura sola | 2, 4, 1 | non scopre insiemi di file | mai | 3 |
| `una_luna_sola_test.dart` | una luna sola | 1, 4 | dalla porta comune | mai | 3 |
| `una_porta_per_il_confronto_test.dart` | una porta per il confronto | 1, 2 | dalla porta comune | mai | 2 |
| `una_porta_sola_per_larchetipo_test.dart` | una porta sola per larchetipo | 1, 2, 4 | dalla porta comune | mai | 2 |
| `una_prova_dichiara_il_suo_istante_test.dart` | una prova dichiara il suo istante | 1, 2 | non scopre insiemi di file | 03/09/2026, CP | 2 |
| `una_sola_ora_per_l_alba_test.dart` | una sola ora per l alba | 1, 2 | non scopre insiemi di file | 08/09/2026, CZ | 2 |
| `una_sola_porta_per_i_transiti_test.dart` | una sola porta per i transiti | 1, 2 | dalla porta comune | mai | 3 |
| `una_spirale_per_volta_test.dart` | una spirale per volta | 1, 2 | dalla porta comune | mai | 3 |
| `una_voce_alla_volta_test.dart` | una voce alla volta | 1, 2 | dalla porta comune | mai | 3 |
| `una_voce_sola_sulla_festa_test.dart` | sulla festa suona una voce sola | 2, 3 | non scopre insiemi di file | CO | 2 |
| `zz_misura_corpus_test.dart` | zz misura corpus | 4 | non scopre insiemi di file | mai | 3 |
