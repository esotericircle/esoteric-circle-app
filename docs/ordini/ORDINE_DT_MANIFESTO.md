# ORDINE DT, I DONI DEL GIORNO, RIFONDAZIONE

**Sigla:** DT. **Data:** 17 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `65bd5811`,
con l'ordine DS consegnato nella build 2265.

**Nessuna build.** L'ordine lo vieta: se una build sembrasse necessaria, la
domanda va a Mauro.

**Venti voci, e una stima dichiarata prima di cominciare: dodici-quindici
ore.** Sopra la soglia di un'ora e mezza, quindi il lavoro si è fermato prima
di toccare un file e Mauro ha deciso, il 17 settembre 2026:

1. **tutto l'ordine, a fasi**, ognuna committata;
2. **il responso dell'Arcano dell'Alba si compone dal corpus, senza modello a
   runtime**: le tre letture per stato sono scritte a mano, e i registri e la
   guardia della sovrapposizione controllano il testo composto. Dove l'ordine
   dice *rigenerare* si ricompone con un'altra variante, e dopo tre tentativi
   si passa alla lettura successiva;
3. **nel Cammino il nuovo dono registra tutti e due i gesti**, `alba` e
   `oracolo`, così nessuno dei 46 traguardi che li nominano cambia;
4. **il Sigillo del Sogno richiama il dono della carta**: la parola quando la
   carta è zodiacale, l'azione o il respiro negli altri giorni.

VOCI_TOTALI: 20
VOCI_CHIUSE: 0
VOCI_APERTE: 20
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0

Il rapporto starà in `docs/ordini/RAPPORTO_ORDINE_DT.md`.

---

## LE VOCI

- **DT.01**, da cinque doni a quattro: via il Rito dell'Alba e l'Arcano del
  Giorno come voci autonome, nasce l'Arcano dell'Alba. **APERTA.**
- **DT.02**, l'Arcano dell'Alba: Medora, l'orario del mattino, un gesto solo,
  scegliere una carta coperta e girarla. **APERTA.**
- **DT.03**, solo i ventidue arcani maggiori, e nessun consumo del limite dei
  tarocchi. **APERTA.**
- **DT.04**, il verso lo decide il sistema, i dorsi non lo tradiscono, il
  rovescio attenua e non nega. **APERTA.**
- **DT.05**, il sacchetto di quarantaquattro stati senza reimbussolamento, e
  undici giorni prima che una carta torni. **APERTA.**
- **DT.06**, le attribuzioni della Golden Dawn nel corpus dei tarocchi.
  **APERTA.**
- **DT.07**, le tre famiglie e le tre forme del responso: respiro, azione,
  parola. **APERTA.**
- **DT.08**, i tre movimenti del responso, con compiti disgiunti. **APERTA.**
- **DT.09**, tre letture per stato, scelte senza ripetere. **APERTA.**
- **DT.10**, il filo con ieri, solo dove la relazione è documentata.
  **APERTA.**
- **DT.11**, i registri delle parole e delle aperture. **APERTA.**
- **DT.12**, la variabile per utente. **APERTA.**
- **DT.13**, la guardia contro la sovrapposizione interna. **APERTA.**
- **DT.14**, il Soffio del Destino alle tredici. **APERTA.**
- **DT.15**, il Sigillo del Sogno a Medora. **APERTA.**
- **DT.16**, la Runa del Tramonto invariata. **APERTA.**
- **DT.17**, l'architettura pronta per sei doni. **APERTA.**
- **DT.18**, il manifesto. **APERTA.**
- **DT.19**, guardia propria, sigillo, sbarramento. **APERTA.**
- **DT.20**, il rapporto. **APERTA.**

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

L'elenco si scrive a lavoro fatto, con ciò che ciascuno dimostra.
