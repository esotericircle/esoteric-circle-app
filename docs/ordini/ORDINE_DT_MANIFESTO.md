# ORDINE DT, I DONI DEL GIORNO, RIFONDAZIONE

**Sigla:** DT. **Data:** 17 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `65bd5811`,
con l'ordine DS consegnato nella build 2265.

**Nessuna build.** L'ordine lo vieta: se una build sembrasse necessaria, la
domanda va a Mauro.

**Ventisette voci**: le venti dell'ordine e le sette del chiarimento dello
stesso giorno, che non è un ordine nuovo e le cui voci stanno qui accanto a
quelle che toccano. **E una stima dichiarata prima di cominciare:
dodici-quindici ore.** Sopra la soglia di un'ora e mezza, quindi il lavoro si è fermato prima
di toccare un file e Mauro ha deciso, il 17 settembre 2026:

1. **tutto l'ordine, a fasi**, ognuna committata;
2. **il responso dell'Arcano dell'Alba si compone dal corpus, senza modello a
   runtime**: le tre letture per stato sono scritte a mano. Nessuna chiamata a
   Vertex o a Gemini per questo dono. **Il chiarimento dello stesso giorno ne
   trae le conseguenze** e riscrive le voci 11, 12 e 13, che presupponevano una
   generazione: i registri non filtrano un testo appena generato ma scelgono
   quale lettura consegnare (DT.23), la variabile per utente è l'ordine in cui
   ciascuno consuma le letture (DT.22), e la guardia della sovrapposizione è
   una prova sul corpus e non un controllo a runtime (DT.24). **Non si rigenera
   niente e non si contano tentativi**: ciò che quei meccanismi dovevano
   garantire lo garantiscono la scelta fra letture già scritte e le prove che
   impediscono a un corpus sbagliato di entrare;
3. **nel Cammino il nuovo dono registra tutti e due i gesti**, `alba` e
   `oracolo`, così nessuno dei 46 traguardi che li nominano cambia;
4. **il Sigillo del Sogno richiama il dono della carta**: la parola quando la
   carta è zodiacale, l'azione o il respiro negli altri giorni.

VOCI_TOTALI: 27
VOCI_CHIUSE: 26
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0

Il rapporto starà in `docs/ordini/RAPPORTO_ORDINE_DT.md`.

---

## LE VOCI

- **DT.01**, da cinque doni a quattro: via il Rito dell'Alba e l'Arcano del
  Giorno come voci autonome, nasce l'Arcano dell'Alba. La voce `dawn` resta e
  diventa l'Arcano dell'Alba; `oracle` e' tolto; quattro voci e quattro icone
  nella striscia; ogni riferimento e' nel rapporto col suo trattamento.
  **CHIUSA.**
- **DT.02**, l'Arcano dell'Alba: Medora, le sette, un gesto solo, scegliere una
  carta coperta e girarla. `lib/features/rituals/arcano_dell_alba_screen.dart`:
  tre carte coperte uguali, nessun comando oltre al ritorno. **CHIUSA.**
- **DT.25**, la Carta del giorno di Medora e' l'Arcano dell'Alba di oggi, col
  suo verso, letta dall'archivio dell'estrazione; il calcolo per conto proprio
  (`ArcanoDelGiorno`) e' tolto; senza carta girata la chat invita e non estrae.
  **CHIUSA.**
- **DT.26**, i pulsanti della chat restano **quindici**, zero destinazioni
  sbagliate; nessuno porta al Rito dell'Alba o all'Arcano del Giorno; quello
  dell'Arcano apre l'Arcano dell'Alba. **CHIUSA.**
- **DT.03**, solo i ventidue arcani maggiori; il limite delle stese non si
  tocca, misurato a schermata. **CHIUSA.**
- **DT.04**, il verso lo decide il caso sicuro al tocco e non la carta toccata;
  la faccia compare dopo meta' giro; il dorso al mezzo giro scarta in media
  5,37 su 255; il rovescio attenua e non nega, nel corpus. **CHIUSA.**
- **DT.05**, il sacchetto di quarantaquattro stati senza reimbussolamento e
  undici estrazioni prima che una carta torni, provato su 120 semi per 6 cicli;
  il diario per persona sopravvive alla chiusura. **Il passaggio fra telefoni
  e' scritto nei due lati, provato e verde, ma `statoDelCerchio` non e'
  distribuita**: Mauro ha dato il via il 17 settembre, e il permesso di questa
  sessione ha rifiutato la distribuzione in produzione. Il comando e il suo
  controllo stanno nel PASSO 8 di `docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md`:
  si aspetta la distribuzione dal PC di Mauro.
  **FERMATA IN ATTESA DI DECISIONE.**
- **DT.06**, le ventidue attribuzioni della Golden Dawn nella riga di ogni
  maggiore del corpus dei tarocchi e nel codice. **CHIUSA.**
- **DT.07**, le tre famiglie e le tre forme: respiro, azione, parola; il
  contenuto nasce dalla carta. **CHIUSA.**
- **DT.08**, i tre movimenti con compiti disgiunti: la carta, il dono, Medora
  col filo in fondo. **CHIUSA.**
- **DT.09**, tre letture per stato, 132 nel corpus, scelte fra quelle non
  ricevute; la distanza fra letture misurata sul corpus. **CHIUSA.**
- **DT.21**, il responso e' a corpus: le voci 11, 12 e 13 riscritte qui sotto
  nella forma che funziona senza modello. **CHIUSA.**
- **DT.10**, il filo con ieri solo con una relazione documentata, mai il primo
  giorno e mai dopo un giorno saltato. **CHIUSA.**
- **DT.11**, i registri delle parole del giorno e delle aperture, per persona:
  nessuna parola e nessuna apertura di movimento si ripete dentro il ciclo di
  quarantaquattro giorni. **A corpus non filtrano un testo generato, scelgono la
  lettura** (DT.23); una prova simula tre cicli per venticinque persone.
  **CHIUSA.**
- **DT.23**, i registri come criterio di scelta: la lettura che violerebbe si
  salta e resta in coda; senza letture libere si consegna la meno recente e un
  contatore lo registra; zero su un ciclo completo. **CHIUSA.**
- **DT.27**, un solo impianto anti ripetizione: `SceltaSenzaRipetere`, nato
  dalla Stesa e usato dalla Stesa e dall'Alba. **CHIUSA.**
- **DT.12**, la variabile per utente e' l'ordine in cui ciascuno consuma le
  letture e le aperture, dal seme della persona; non esiste un seme di
  generazione. **CHIUSA.**
- **DT.22**, la collisione fra due persone nello stesso giorno misurata al
  variare delle letture per stato, con la tabella e la raccomandazione nel
  rapporto; **il numero lo sceglie Mauro**. **CHIUSA.**
- **DT.13**, la sovrapposizione interna: nessuno dei tre movimenti condivide il
  nucleo con un altro. **A corpus e' una prova sul corpus** (DT.24).
  **CHIUSA.**
- **DT.24**, la prova della sovrapposizione e quella della distanza girano sul
  corpus, su 1.048.320 combinazioni, e sono state viste rosse sul corpus vuoto
  prima che il corpus entrasse. **CHIUSA.**
- **DT.14**, il Soffio del Destino alle tredici, con testi, avvisi e prove.
  **CHIUSA.**
- **DT.15**, il Sigillo del Sogno a Medora, senza la rotazione. **CHIUSA.**
- **DT.16**, la Runa del Tramonto invariata, allineata nelle liste.
  **CHIUSA.**
- **DT.17**, l'architettura pronta per sei doni: le fasce dalle ancore, i
  numeri degli avvisi per dono, gli elenchi composti; i numeri rimasti scritti
  a mano sono nel rapporto. **CHIUSA.**
- **DT.18**, questo manifesto. **CHIUSA.**
- **DT.19**, la guardia propria, il sigillo e lo sbarramento. **CHIUSA.**
- **DT.20**, il rapporto, `docs/ordini/RAPPORTO_ORDINE_DT.md`. **CHIUSA.**

---

## LA REGOLA DI VERIFICA, E LE PREMESSE RISCONTRATE

**Regola DT.00.A**: ogni nome, file, campo, posizione e numero dell'ordine si
riscontra sul ramo prima di usarlo. Dove non corrisponde, **non si adatta il
codice all'ordine**: ci si ferma su quel punto, si applica il resto, e lo
scarto va nel rapporto col file e la riga che lo smentiscono.

| premessa | l'ordine dice | sul ramo | esito |
|---|---|---|---|
| `lib/core/rituals/daily_elements.dart` coi cinque doni | cinque | **cinque**, `enum DailyElement`: `dawn` Rito dell'Alba 7:00, `breath` Soffio del Destino 10:30, `oracle` Arcano del Giorno 13:00, `rune` La Runa del Tramonto 18:30, `night` Sigillo del Sogno 22:30 | **VERA** |
| l'enumerazione dei Maestri con medora, aura e caligo | tre | **tre**, `enum Maestro` in `lib/core/maestro/maestro.dart` | **VERA** |
| `lib/core/tarot/tarot_card.dart` col mazzo dei settantotto | 78 | **78**, `TarotDeck`, e i maggiori da `ArcanoDelGiorno.maggiori` | **VERA** |
| il corpus dei tarocchi sotto `docs/corpus/` | esiste | `docs/corpus/tarocchi.md`, sezione `## Arcani Maggiori` con una riga per carta e per verso | **VERA** |
| `docs/ordini/`, `test/`, `tool/sbarramento.sh`, `tool/rossi_accettati.txt` | esistono | esistono | **VERA** |
| il Sigillo del Sogno non ha un Maestro fisso | nessuno | `guide: null` | **VERA** |
| il Soffio passa alle tredici | oggi altrove | **oggi alle 10:30**, e le 13:00 sono l'ora dell'Arcano del Giorno, che se ne va | **VERA**, nessun conflitto d'orario dopo la fusione |
| il Rito dell'Alba ha un orario d'ancoraggio da conservare | da verificare | **7:00** | si conserva |
| il budget di consultazioni dei tarocchi | esiste | **non c'è un budget dei tarocchi separato**: c'è il limite delle **stese** in `lib/core/entitlement/question_allowance.dart`, intorno alla riga 586 | **DIVERGE NEL NOME**: la prova misura quel limite |
| i nomi degli arcani | Il Bagatto, Le Stelle | il corpus dice **Il Mago** e **La Stella**, e numera **La Giustizia VIII** e **La Forza XI** | **DIVERGE**: si usano i nomi del corpus, vedi sotto |
| i gesti del Cammino | non nominati | **`alba` 52 volte e `oracolo` 42** nei traguardi della revisione F, in **46 traguardi su 165** | **UNA DIPENDENZA CHE L'ORDINE NON NOMINA**: decisa da Mauro, un gesto vale per tutti e due |
| il responso "generato" | voci 11-13 | **l'Arcano del Giorno oggi è deterministico dal corpus**, non passa da nessun modello | **UNA SCELTA D'ARCHITETTURA**: decisa da Mauro, corpus senza modello |
| la parola del giorno | nasce solo dalle zodiacali | **il Sigillo del Sogno richiama la parola dell'alba** (`dream_rite_screen.dart`) | **UNA DIPENDENZA CHE L'ORDINE NON NOMINA**: decisa da Mauro, richiama il dono della carta |

---

## LE VENTIDUE ATTRIBUZIONI

Sistema della Golden Dawn, ripreso dal mazzo Waite Smith, sulla divisione del
Sefer Yetzirah. **I nomi sono quelli del corpus**; dove l'ordine usa un altro
nome la corrispondenza è scritta accanto.

| arcano, nome del corpus | nome nell'ordine | attribuzione | lettera | famiglia | forma del responso |
|---|---|---|---|---|---|
| 0 Il Matto | Il Matto | Aria | madre | elementale | respiro |
| XII L'Appeso | L'Appeso | Acqua | madre | elementale | respiro |
| XX Il Giudizio | Il Giudizio | Fuoco | madre | elementale | respiro |
| I Il Mago | **Il Bagatto** | Mercurio | doppia | planetaria | azione |
| II La Papessa | La Papessa | Luna | doppia | planetaria | azione |
| III L'Imperatrice | L'Imperatrice | Venere | doppia | planetaria | azione |
| X La Ruota della Fortuna | La Ruota della Fortuna | Giove | doppia | planetaria | azione |
| XVI La Torre | La Torre | Marte | doppia | planetaria | azione |
| XIX Il Sole | Il Sole | Sole | doppia | planetaria | azione |
| XXI Il Mondo | Il Mondo | Saturno | doppia | planetaria | azione |
| IV L'Imperatore | L'Imperatore | Ariete | semplice | zodiacale | parola |
| V Il Papa | Il Papa | Toro | semplice | zodiacale | parola |
| VI Gli Amanti | Gli Amanti | Gemelli | semplice | zodiacale | parola |
| VII Il Carro | Il Carro | Cancro | semplice | zodiacale | parola |
| XI La Forza | La Forza | Leone | semplice | zodiacale | parola |
| IX L'Eremita | L'Eremita | Vergine | semplice | zodiacale | parola |
| VIII La Giustizia | La Giustizia | Bilancia | semplice | zodiacale | parola |
| XIII La Morte | La Morte | Scorpione | semplice | zodiacale | parola |
| XIV La Temperanza | La Temperanza | Sagittario | semplice | zodiacale | parola |
| XV Il Diavolo | Il Diavolo | Capricorno | semplice | zodiacale | parola |
| XVII La Stella | **Le Stelle** | Acquario | semplice | zodiacale | parola |
| XVIII La Luna | La Luna | Pesci | semplice | zodiacale | parola |

**Tre più sette più dodici fa ventidue.**

**Sulla numerazione.** Il corpus numera La Giustizia VIII e La Forza XI, come
i mazzi precedenti al Waite Smith; l'attribuzione si lega al **nome**, non al
numero, e le due carte portano Bilancia e Leone come nella Golden Dawn.

## LE TRE FAMIGLIE

| famiglia | lettere | carte | forma | cosa chiede il dono |
|---|---|---|---|---|
| elementale | madri | 3 | **respiro** | stare dentro un elemento per la giornata, con il modo di farlo |
| planetaria | doppie | 7 | **azione** | una cosa precisa da compiere nella giornata |
| zodiacale | semplici | 12 | **parola** | la parola del giorno, nata dalla carta |

## I NUMERI DEL CICLO

| numero | quanto | da dove viene |
|---|---|---|
| stati | **44** | 22 arcani maggiori per 2 versi |
| giorni del ciclo | **44** | un'estrazione al giorno, ogni stato una volta sola |
| distanza minima fra due uscite della stessa carta | **11** | un quarto del ciclo, 44 diviso 4, in qualunque verso |
| letture per stato | **3** almeno | voce 9 |
| letture nel corpus | **132** | 44 stati per 3 letture |
| giorni prima che una lettura torni | **132** | ogni stato esce una volta ogni 44 giorni, e le sue tre letture si esauriscono in tre cicli |
| parole distinte nel corpus | **72** | 12 carte zodiacali per 2 versi per 3 letture |
| parole consegnate in un ciclo | **24** | le 12 zodiacali nei due versi |

---

## I TEST

### Le prove nuove, viste rosse prima

| prova | cosa dimostra | voci | come e' stata vista rossa |
|---|---|---|---|
| `test/le_ventidue_attribuzioni_test.dart` | tre piu' sette piu' dodici fa ventidue; ogni maggiore del mazzo ha **una** attribuzione e nessuna resta senza carta; ogni pianeta e ogni segno una volta; le ventidue attribuzioni dell'ordine carta per carta; le relazioni del filo su coppie di cui la tradizione sa la risposta (stesso elemento, governo nei due sensi, opposizione, quadratura, famiglia) | 06, 10 | La Luna portata ai pianeti: 3, 8, 11 |
| `test/il_sacchetto_dell_alba_test.dart` | **44 stati, ogni stato una volta per ciclo, la stessa carta mai prima di 11 estrazioni anche fra due cicli**, su 120 semi per 6 cicli; zero cicli ricomposti a meta'; il verso non segue la carta (prima uscita rovescia fra il 45 e il 55 per cento); il sacchetto sopravvive alla chiusura; sette salvataggi rotti o vuoti si ricompongono senza bloccare | 04, 05 | finestra tolta: la carta torna dopo una estrazione; prova di componibilita' tolta: un ciclo ricomposto a meta' |
| `test/il_corpus_dell_alba_regge_test.dart` | almeno tre letture per stato, numerate; **la famiglia decide la forma** (parola solo alle zodiacali, e il dono la porta); carte diverse danno responsi diversi e i due versi della stessa carta hanno la stessa forma e un altro dono; **le letture dello stesso stato non condividono il nucleo**; parole, aperture del dono e di Medora tutte distinte e piu' aperture del primo movimento che giorni; **nessun movimento fa il compito di un altro su 1.048.320 combinazioni** di lettura, apertura, clausola e filo; la lingua; il file dei dati coincide col corpus; il rilevatore vede un caso costruito apposta e non vede cio' che non c'e' | 07, 08, 09, 11, 13, 24 | corpus vuoto: otto rosse; una chiusura di Medora innestata sul suo dono nei dati: una caduta |
| `test/il_diario_dell_alba_test.dart` | una sola estrazione al giorno; **in tre cicli per 25 persone nessuna parola e nessuna apertura si ripete dentro il ciclo, 24 parole a ciclo, ripieghi a zero, e ogni stato consuma le sue tre letture**; il registro salta la lettura che lo viola, la lascia in coda, e al secondo ciclo senza letture libere consegna e conta; il filo con ieri solo con relazione, mai il primo giorno, spezzato da un giorno saltato; **due persone con lo stesso stato leggono testi diversi**; la collisione misurata al variare delle letture; il diario riletto continua identico; cinque salvataggi rotti non bloccano | 05, 09, 10, 11, 12, 22, 23, 27 | l'impianto unico che prende sempre il primo candidato: tre rosse qui e due nella Stesa |
| `test/l_arcano_dell_alba_si_gira_test.dart` | carte coperte uguali per dorso e misura, **nessun comando oltre al ritorno**, nessuna faccia montata prima del gesto; girata la carta, la faccia porta il verso estratto e arrivano i tre movimenti; **il verso non lo decide la carta toccata**; nella prima meta' del giro solo il dorso; **il limite delle stese non si muove e nel cammino entrano alba e oracolo**; riaperto il dono la carta e' quella; **il dorso ruotato di mezzo giro scarta in media 5,37 su 255 e in nessun punto oltre 48** | 02, 03, 04 | la carta toccata che decide il caso; il gesto dell'oracolo tolto: due rosse |
| `functions/src/cammino.test.ts`, due prove nuove | il diario dell'Alba si legge intero e non oltre il suo peso; **fra due diari vince il piu' avanti**, e un telefono nuovo lo riceve | 05 | il server che vince sempre: una rossa |
| `test/intent_routing_test.dart`, riscritta | **estratto l'Arcano dell'Alba, la chat nomina la stessa carta e lo stesso verso**, tre domande, senza modello; senza carta girata la chat non ne estrae una seconda | 25 | la carta del giorno che ignora l'estrazione: tre rosse |
| `test/daily_elements_test.dart`, riscritta | **quattro doni nell'ordine delle ore**; le fasce, alle 13 il Soffio; ogni minuto del giorno appartiene al dono dell'ultima ancora, senza nomi a mano; **Medora all'alba e al Sogno in tutti i 366 giorni**; il numero dell'avviso e' del dono e il 2 non torna; `oracle` non apre niente; i nomi a video; l'elenco e il numero in lettere composti dai doni | 01, 14, 15, 17 | Sigillo senza Maestro: due rosse |
| `test/il_sigillo_del_sogno_nomina_un_maestro_solo_test.dart`, riscritta | nei tre giorni che la rotazione dava a tre Maestri diversi, **il Sigillo nomina Medora e nessun altro**, a video | 15 | Sigillo senza Maestro: due giorni su tre rossi |
| `test/il_confine_del_responso_test.dart`, allargata | **29.994 responsi composti dell'Arcano dell'Alba** dentro il confine; il nome della Morte non e' la morte rivolta alla persona, la morte in minuscolo si' | 08, 13 | i nomi dei simboli tolti dall'eccezione: due rosse |

### Le prove riallineate, e cosa hanno perso o guadagnato

| prova | trattamento | perche' |
|---|---|---|
| `l_arcano_del_giorno_test.dart` | **tolta** | misurava `ArcanoDelGiorno`, tolto; le sue pretese (solo maggiori, stessa carta tutto il giorno, varieta', gesto `oracolo`) le portano il sacchetto, il diario e la schermata |
| `il_disco_dell_oracolo_dice_cosa_e_test.dart` | **tolta** | misurava il disco della schermata dell'Arcano del Giorno |
| `il_permesso_appena_dato_accende_tutte_e_cinque_test.dart` | **tolta** | misurava il permesso chiesto dal Rito dell'Alba; il menu' Notifiche riprogramma tutte le chiamate dopo il permesso (`notifiche_screen.dart`, riga 148) |
| `il_mantra_di_oggi_ha_il_suo_riquadro_test.dart` | **tolta** | il riquadro del rituale era della scheda dell'Alba |
| `la_parola_dice_a_cosa_serve_test.dart` | **tolta** | l'etichetta della parola era della scheda dell'Alba |
| `i_testi_del_dono_non_stanno_sulla_carta_test.dart` | **tolta** | misurava la vista rituale dell'Arcano del Giorno, uscita col dono |
| `l_alba_dice_dove_sei_test.dart` | **tolta** | misurava la riga del luogo del Rito dell'Alba, uscita col dono |
| `daily_elements_test.dart` | **riscritta** | quattro doni, fasce dalle ancore, Medora, numeri degli avvisi |
| `il_sigillo_del_sogno_nomina_un_maestro_solo_test.dart` | **riscritta** | Medora nei tre giorni che la rotazione dava a tre Maestri |
| `intent_routing_test.dart` | **riscritta la carta del giorno** | la carta della chat e' l'Arcano dell'Alba estratto |
| `l_arcano_e_del_singolo_test.dart` | **riscritta la meta' dell'Arcano** | due persone vedono lo stesso stato 11 giorni su 365, attesi 8,3 |
| `i_cinque_doni_incrociano_la_carta_test.dart` | **ridotta** | tolte le misure dell'Arcano del Giorno e del Rito dell'Alba; restano Sigillo, Runa e Soffio |
| `colore_del_dono_test.dart` | **ridotta** | tolte le misure del colore della parola sul vetro chiaro dell'Alba; resta il punto solo dell'accento, col cardinale |
| `il_soffio_non_somiglia_all_alba_test.dart` | **ridotta** | tolti i confronti fra l'abito del giorno e quello della notte; nessun dono porta piu' il giorno |
| `le_due_cose_che_non_servivano_test.dart` | **ridotta** | tolte le tre misure della parola condivisa dall'Alba |
| `la_parola_del_giorno_si_vede_nella_frase_test.dart` | **ridotta e riallineata** | tolto il ripiego del mantra; la seconda frase e' il richiamo del dono di una carta del corpus |
| `dove_sei_adesso_test.dart` | **ridotta** | tolto il gruppo della riga del luogo; restano il luogo attuale e il catalogo |
| `i_doni_si_agganciano_test.dart` | **ridotta e riallineata** | tolto il gruppo P.16 dell'Arcano del Giorno; il filo della sera passa dall'archivio |
| `il_censimento_dei_caratteri_test.dart` | **riallineata e allargata** | l'Arcano dell'Alba coperto e girato; i glifi delle icone non sono testo |
| `l_alba_si_legge_test.dart` | **riallineata** | il contrasto misurato sull'Arcano dell'Alba, prima e dopo il gesto |
| `il_responso_si_legge_ovunque_test.dart`, `il_confine_del_responso_test.dart`, `i_doni_e_la_chat_davanti_all_anatomia_test.dart`, `le_lunghezze_dei_responsi_test.dart` | **riallineate** | misurano i testi dell'Arcano dell'Alba al posto di quelli dell'Arcano del Giorno |
| `la_parola_torna_la_sera_test.dart`, `dream_rite_screen_test.dart` | **riallineate** | il dono della carta torna la sera, dall'archivio |
| `cinque_avvisi_uno_per_dono_test.dart`, `le_cinque_chiamate_partono_tutte_test.dart`, `le_notifiche_arrivano_davvero_test.dart`, `il_menu_delle_notifiche_si_tocca_test.dart`, `cancellare_dimentica_tutto_test.dart` | **riallineate** | il numero dei doni letto dall'enumerazione; il 1102 fra le chiamate da spegnere; la Runa al posto dell'Arcano dove serviva un dono qualunque |
| `daily_strip_test.dart`, `santuario_test.dart`, `navigation_test.dart`, `i_doni_si_aprono_alla_loro_ora_test.dart`, `fascia_del_risveglio_test.dart` | **riallineate** | le ore nuove: alle tredici il Soffio di Aura, al mattino e di notte Medora |
| `ogni_dono_dice_chi_parla_test.dart`, `nessun_accento_dichiara_un_fondo_che_non_ha_test.dart`, `i_testi_da_leggere_hanno_una_misura_sola_test.dart`, `i_cinque_doni_rispettano_la_legge_dei_testi_test.dart`, `il_dono_risponde_prima_di_chiedere_test.dart`, `le_descrizioni_hanno_una_misura_sola_test.dart`, `le_condizioni_costruite_test.dart`, `nessun_invito_a_un_permesso_e_muto_test.dart`, `ogni_schermata_dichiara_la_barra_test.dart`, `una_barra_sola_test.dart`, `nessun_catch_muto_test.dart` | **riallineate** | la schermata dell'Arcano dell'Alba al posto delle due tolte negli elenchi dei sorgenti |
| `ogni_custodito_ritrova_la_sua_arte_test.dart`, `ogni_pulsante_della_chat_apre_cio_che_promette_test.dart`, `cosa_dicono_i_doni_test.dart`, `entitlement_test.dart`, `la_catena_dei_dati_di_nascita_test.dart`, `i_due_pulsanti_del_soffio_si_leggono_test.dart`, `rituals_test.dart`, `testo_a_video_test.dart` | **riallineate** | i numeri seguono il dato (quattro doni, 31 righe del piano, 14 consumatori della nascita, 8 chiavi dei custoditi) e le arti senza azioni dichiarate; le elisioni *mezz'* e *nient'* |

