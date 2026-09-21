# ORDINE EB, LE CHAT DEI MAESTRI: OGNI MOSSA DELL'UTENTE HA LA SUA RISPOSTA, E LA RISPOSTA ARRIVA SEMPRE

**Sigla:** EB, la prima libera dopo EA: verificato sul ramo, in `docs/ordini`
non c'e' nessun `ORDINE_EB_*`, in `test/` nessuna `ordine_eb_guard`, e nessun
documento nomina un ordine EB. **Data:** 21 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `1c7a1eb4`
(build 2274 consegnata).

**Dichiarazione del fondatore sul tempo, 21 settembre 2026:** *"non
m'interessa quanto tempo ci vorra', ma devi creare un ordine che preveda ogni
mossa ed eviti ogni errore"*.

VOCI_TOTALI: 8
VOCI_CHIUSE: 0
VOCI_APERTE: 8

Il rapporto stara' in `docs/ordini/RAPPORTO_ORDINE_EB.md`.

---

## IL FATTO, E LA CAUSA MISURATA

**Il fatto**, dalle due catture del fondatore del 21 settembre 2026, fatte sul
Realme alle 03:24 e alle 03:25. Stesa di tarocchi con domanda *lavoro e
carriera*, responso ottenuto, tocco su *Parlane con Medora*. La chat si apre
col testo *"Nella mia stesa sono uscite Il Papa, Re di Spade e Dieci di Spade.
Come si legge questa sequenza sulla mia situazione?"*, che porta le carte ma
non la domanda. All'invio Medora risponde *"Le carte vogliono essere viste,
non raccontate. Vieni, stendiamole insieme."* con il pulsante *Apri la Stesa
di Tarocchi*. Il fondatore scrive *"Ma io non voglio fare un'altra stesa di
tarocchi. Voglio solo la tua interpretazione"* e riceve **la stessa identica
frase e lo stesso pulsante**.

**LA CAUSA, misurata e non dedotta.** Il classificatore
(`lib/core/chat/intent_classifier.dart:15-32`) cerca le parole chiave
dell'arte dentro il testo e, se le trova, il controller manda l'invito e
**torna prima di chiamare il modello**
(`lib/features/maestri/chat/maestro_chat_controller.dart:651-671`). Non c'e'
nessuna nozione di intenzione: c'e' la presenza di una parola.

Passate al classificatore le frasi vere delle due catture, il 21 settembre
2026:

| frase | cosa decide |
|---|---|
| `Nella mia stesa sono uscite Il Papa, Re di Spade e Dieci di Spade. Come si legge questa sequenza sulla mia situazione?` | **instrada alla Stesa** |
| `Ma io non voglio fare un'altra stesa di tarocchi. Voglio solo la tua interpretazione` | **instrada alla Stesa** |
| `non voglio una stesa` | **instrada alla Stesa** |
| `niente tarocchi, interpretami quelle che ho gia'` | **instrada alla Stesa** |
| `interpreta le carte che sono uscite` | nessun instradamento |

**La negazione pesa zero**: dire *non voglio* una cosa la chiede esattamente
come chiederla. E **la domanda preimpostata si autodistrugge**: contiene la
parola *stesa*, quindi il testo che porta le carte da interpretare viene letto
come richiesta di estrarne altre.

**Padre del difetto: PROVENIENZA IGNOTA.** Il classificatore a parole chiave
nasce col file e nessun ordine risulta averlo introdotto ne' averne discusso
i limiti; la prova che lo codifica, `test/intent_routing_test.dart`, non porta
sigla d'ordine in testata.

## GLI SCARTI FRA L'ORDINE E IL RAMO

L'ordine chiede di riportare ogni smentita col file e la riga.

1. **Le porte di approfondimento sono tredici, non dodici piu' una da
   verificare**, e l'ordine DX le aveva contate giuste: dodici *Parlane con* e
   un *Continua con*. Confermate per tre vie indipendenti: tredici metodi in
   `lib/features/maestri/chat/chat_openers.dart`, dodici montaggi di
   `AzioniDelResponso(` in `lib` piu' un `initialUserMessage:` diretto in
   `lib/features/maestri/ask/ask_maestri_screen.dart:424`, e dodici voci in
   `ArtiConResponso.tutte` (`lib/core/ricordi/arti_con_responso.dart:71-176`).
2. **`docs/ordini/ORDINE_DX_MANIFESTO.md:121-133` porta numeri di riga vecchi
   di una decina di righe** rispetto al ramo di oggi: dice
   `oroscopo_screen.dart:1671`, oggi la chiamata sta a `:1682`. Le righe giuste
   sono quelle di questo manifesto.
3. **La testata di `chat_openers.dart:4-7` dice il falso**: *"la chat si apre
   gia' con una domanda scritta e inviata dall'utente"*. Dall'ordine DX voce 01
   il testo **aspetta nel campo** e parte solo al tocco dell'utente
   (`lib/features/maestri/chat/maestro_chat_screen.dart:93-99, 851-852`).
   Documentazione rimasta indietro alla cura.
4. **`EsitoDelTurno.limiteRaggiunto` ed `EsitoDelTurno.instradamento` non li
   costruisce nessuno** (`lib/core/entitlement/esito_del_turno.dart:30,33`):
   i due rami tornano prima, con un `return` nudo. L'effetto coincide con la
   regola, ma a tenerlo in piedi e' il `return`, non l'elenco chiuso che
   quell'enum dichiara di essere.
5. **`initialTheme` e' un secondo canale di precompilazione che nessuno usa**
   (`maestro_chat_screen.dart:72,88,107,166,852`): nessun chiamante in `lib`
   lo passa.
6. **`PortaDellaSpesa` non e' montata da nessuna schermata**
   (`lib/design_system/components/porta_della_spesa.dart:50`), e il suo
   commento alle righe 31-32 lo dichiara.

---

## VOCE EB.01, LA DOMANDA PREIMPOSTATA PORTA ANCHE LA DOMANDA

### Il censimento delle tredici porte, com'e' oggi

| # | da dove | Maestro | compositore | cosa porta oggi | porta la domanda? |
|---|---|---|---|---|---|
| 1 | Oroscopo, `lib/features/horoscope/oroscopo_screen.dart:1682` | Medora | `chat_openers.dart:101` | il segno | l'arte non ha una domanda |
| 2 | **Stesa di Tarocchi**, `lib/features/tarot/stesa_tre_carte_screen.dart:1738` | Medora | `chat_openers.dart:106` | **i soli nomi delle carte**, da `c.card.name` | **NO** |
| 3 | Sinastria VIP, `lib/features/synastry/sinastria_vip_screen.dart:1116` | Medora | `chat_openers.dart:111` | nome del VIP e percentuale | l'arte non ha una domanda |
| 4 | Test dell'Archetipo, `lib/features/maestri/aura/archetype/archetype_test_screen.dart:985` | Aura | `chat_openers.dart:79` | l'archetipo dominante | l'arte non ha una domanda |
| 5 | Costellazione del Viso, `lib/features/maestri/aura/face/face_constellation_screen.dart:1800` | Aura | `chat_openers.dart:84` | il tratto dominante | l'arte non ha una domanda |
| 6 | Estrazione delle Rune, `lib/features/maestri/caligo/rune/rune_draw_screen.dart:1632` | Caligo | `chat_openers.dart:64` | la gettata e le rune | l'arte non ha una domanda |
| 7 | Animale Guida, `lib/features/maestri/caligo/animal/guide_animal_screen.dart:775` | Caligo | `chat_openers.dart:31` | il nome dell'animale | l'arte non ha una domanda |
| 8 | Sigillo dell'Intenzione, `lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart:799` | Caligo | `chat_openers.dart:116` | **l'intenzione scritta dalla persona** | porta un'intenzione, non una domanda |
| 9 | Arcano dell'Alba, `lib/features/rituals/arcano_dell_alba_screen.dart:190` | Medora | `chat_openers.dart:129` | la carta **col verso** e il gesto | l'arte non ha una domanda |
| 10 | Soffio del Destino, `lib/features/rituals/breath_destiny_screen.dart:853` | Aura | `chat_openers.dart:120` | il testo del responso | l'arte non ha una domanda |
| 11 | Runa del Tramonto, `lib/features/rituals/sunset_rune_screen.dart:2376` | Caligo | `chat_openers.dart:59` | la runa **col verso** | l'arte non ha una domanda |
| 12 | Sigillo del Sogno, `lib/features/rituals/dream_rite_screen.dart:1081` | Medora | `chat_openers.dart:136` | tutto il saluto del rito | l'arte non ha una domanda |
| 13 | **Consiglio dei Maestri**, `lib/features/maestri/ask/ask_maestri_screen.dart:424` | quello toccato | `chat_openers.dart:52` | **la domanda posta al Consiglio** | **SI'** |

**IL FONDATORE AVEVA RAGIONE, E LA CURA ESISTE GIA': E' APPLICATA A UNA PORTA
SU TREDICI.** Il commento di `chat_openers.dart:46-51` dice, del Consiglio:
*"era l'unica porta che apriva una conversazione vuota: chi ci entrava trovava
un Maestro che non sapeva niente della domanda a cui aveva appena risposto"*.
E' esattamente il difetto che il fondatore ha incontrato sulla Stesa, gia'
riconosciuto e curato altrove.

**Delle tredici arti, una sola oltre al Consiglio ha una domanda da portare, ed
e' la Stesa di Tarocchi.** Verificato: il tema da tendina vive in
`TarotSetup.topic` (`lib/features/tarot/tarot_selectors.dart:65`), la domanda
scritta a mano in `TarotSetup.domandaLibera` (`:86`) col getter ripulito
`domandaScritta` (`:89-92`). **La domanda e' gia' a video 143 righe sopra il
punto che compone l'apertura della chat**
(`stesa_tre_carte_screen.dart:1595-1598`, chiave `stesa_domanda_a_video`,
contro la chiamata a `:1738`), ed e' gia' lavorata dal motore del responso, che
ne ricava la lente fra sedici
(`lib/core/tarot/domanda_della_persona.dart:110-136`). **A lasciarla cadere e'
la sola chat.**

**E la Stesa perde anche il verso.** Passa `c.card.name`
(`stesa_tre_carte_screen.dart:1739`) e non `DrawnCard.displayName`
(`lib/core/tarot/tarot_spread.dart:40-41`), che e' il nome col rovescio
accordato. E' **l'unica porta con carte o rune che perde il verso**: l'Arcano
dell'Alba lo porta (`arcano_dell_alba_screen.dart:191`) e la Runa del Tramonto
pure (`sunset_rune_screen.dart:2378-2380`). Una carta rovesciata interpretata
come dritta e' un responso sbagliato, non una sfumatura.

### Cosa portano dopo il lavoro

| # | porta | cosa cambia |
|---|---|---|
| 2 | Stesa di Tarocchi | porta **la domanda** (quella scritta a mano se c'e', altrimenti l'etichetta del tema) e **le carte col verso** |
| 1, 3..12 | le altre undici | invariate: quelle arti una domanda non ce l'hanno, e aggiungerne una finta sarebbe peggio che non averla |
| 13 | Consiglio | invariata: porta gia' la domanda |

**Resta valido l'ordine DX voce 01**: il testo aspetta nel campo e parte solo
quando l'utente invia.

---

## VOCE EB.02, IL MAESTRO RISPONDE SEMPRE

**Oggi non risponde sempre, e il punto e' uno solo**: quando il classificatore
riconosce una parola chiave, il controller manda l'invito e torna
(`maestro_chat_controller.dart:651-671`), senza mai interpellare il modello.
L'invito **prende il posto della risposta**, che e' precisamente cio' che la
voce vieta.

**La cura: l'instradamento smette di essere un'alternativa alla risposta.** Il
modello viene chiamato sempre, salvo il caso in cui aprire la funzione E' la
risposta nel merito, cioe' quando l'utente sta chiedendo di farla adesso: e'
il caso che la voce 03 nomina per esteso (*"per esempio quando chiede una
stesa nuova"*). In ogni altro caso il Maestro risponde.

**Lettura dichiarata delle voci 02 e 03 insieme**, perche' prese alla lettera
si sfiorano: quando l'utente chiede *"fammi una stesa"*, aprire la Stesa non
e' un invito che prende il posto della risposta, e' la risposta. Quando
l'utente chiede l'interpretazione di carte che ha gia', la risposta e'
l'interpretazione, e nessun pulsante puo' sostituirla.

---

## VOCE EB.03, IL PULSANTE SOLO SE L'UTENTE LO CHIEDE

### Il censimento dei pulsanti verso una funzione

**Il meccanismo e' uno solo.** Il pulsante si disegna se e solo se la bolla
porta un `intentId` (`lib/features/maestri/chat/widgets/chat_bubble.dart:337`,
chiave `intent_open_$intentId` a `:617`), e un `intentId` lo mette solo il ramo
dell'instradamento (`maestro_chat_controller.dart:664`). **Non esiste nessun
altro punto in `lib` che produca un pulsante verso una funzione dentro una
bolla della chat.**

**Gli intenti sono quindici**, tutti in
`lib/core/chat/immersive_intents.dart:52-258`:

| Maestro | intento | parole chiave | riga |
|---|---|---|---|
| Medora | Stesa di Tarocchi | stesa, stendi le carte, leggi le carte, tira le carte, tarocchi, arcani | 54 |
| Medora | Carta Natale | carta natale, tema natale, mappa natale, carta del cielo | 69 |
| Medora | Sinastria VIP | sinastria, compatibilita con, affinita con, con un vip, con una celebrita | 82 |
| Medora | Oroscopo del giorno | oroscopo del giorno, oroscopo di oggi, oroscopo oggi, previsione del giorno | 96 |
| Medora | Arcano dell'Alba | carta del giorno, arcano del giorno, arcano dell'alba, carta di oggi, arcano di oggi, tira una carta, pesca una carta, una carta per me | 123 |
| Aura | Meditazione | meditazione, meditare, medita, rilassami, rilassarmi | 141 |
| Aura | Respiro | breathwork, respirazione, respiro guidato, esercizio di respiro | 155 |
| Aura | Costellazione del viso | costellazione del viso, lettura del viso, morfopsicologia | 168 |
| Aura | Scan dei Chakra | chakra, scan dei chakra, scansione dei chakra, centri energetici | 180 |
| Aura | Frequenze | frequenze, frequenza sonora, suoni curativi, battito binaurale | 193 |
| Caligo | Estrazione Rune | lancio delle rune, tira le rune, getta le rune, runa, rune, futhark | 208 |
| Caligo | Sigillo dell'Intenzione | sigillo, sigillo magico, simbolo magico | 223 |
| Caligo | I-Ching | i-ching, i ching, iching, esagramma | 230 |
| Caligo | Pendolo | pendolo, radioestesia | 238 |
| Caligo | Rito della candela | rituale con candela, rito della candela, candela, magia con la candela | 245 |

**Le parole chiave piu' pericolose sono quelle che nominano il responso invece
della richiesta**: `arcani`, `runa`, `rune`, `chakra`, `sigillo`, `candela`,
`carta del cielo`. Sono parole che chiunque usa per parlare di cio' che ha
gia' ottenuto, e oggi bastano da sole ad aprire la funzione.

### Come diventa

**Un cancello stretto al posto di un cancello largo**, e la ragione e'
aritmetica: oggi un cancello che non scatta vuol dire **nessuna risposta**,
quindi il cancello e' stato fatto largo; domani un cancello che non scatta
vuol dire **una risposta vera**, quindi lo si puo' fare stretto senza costo.
**Si sposta il rischio dalla parte in cui l'errore non si vede.**

Perche' il pulsante compaia servono tutte e quattro:

1. **la parola dell'arte**, come oggi;
2. **un segno di richiesta** nella stessa frase, cioe' una forma che chiede di
   farla adesso (fammi, facciamo, voglio, vorrei, apri, apriamo, stendi,
   stendiamo, tira, tiriamo, lancia, lanciamo, getta, gettiamo, fai, puoi
   fare, mi fai, posso avere);
3. **nessuna negazione** che la governi (non, niente, nessun, nessuna, senza,
   mai, invece di, al posto di, piuttosto che, basta con);
4. **nessun riferimento a un responso gia' ottenuto** (ho gia', sono uscite,
   mi e' uscita, mi e' uscito, nella mia stesa, che ho fatto, appena fatto,
   la mia estrazione, ho estratto, ho tirato, ho gettato).

E due regole di conversazione, che vengono dalla voce 05:

5. **l'invito di quell'arte non e' gia' stato dato in questa conversazione**;
6. **l'utente non ha rifiutato quell'arte in questa conversazione**: un
   rifiuto chiude quel cancello per il resto della conversazione.

---

## VOCE EB.04, CIO' CHE NON E' UNA RISPOSTA NON CONSUMA

### Il censimento dei consumi

**La regola vive gia' in un punto solo**, `CostoDelTurno.consuma`
(`lib/core/entitlement/esito_del_turno.dart:65-66`), e dice:
`esito == EsitoDelTurno.rispostaVera`. I sette esiti dichiarati:

| esito | riga | consuma |
|---|---|---|
| `rispostaVera` | `esito_del_turno.dart:7` | **SI', ed e' l'unico** |
| `ripiego` | `:10` | no |
| `rispostaTroncata` | `:21` | no |
| `erroreDiAttestazione` | `:24` | no |
| `erroreGenerico` | `:27` | no |
| `limiteRaggiunto` | `:30` | no, e **non lo costruisce nessuno** |
| `instradamento` | `:33` | no, e **non lo costruisce nessuno** |

**I tre contatori e dove scendono:**

| contatore | metodo | unico punto di chiamata dalla chat | quando |
|---|---|---|---|
| domande del giorno | `QuestionAllowance.record` (`lib/core/entitlement/question_allowance.dart:660-667`) | `maestro_chat_controller.dart:680-682` e `:932-936` (il Riprova) | solo su `rispostaVera` |
| approfondimenti | `QuestionAllowance.registraApprofondimento` (`question_allowance.dart:245-254`) | `maestro_chat_controller.dart:884-885` | solo a seguito consegnato e non vuoto |
| confronti | `QuestionAllowance.registraConfronto` (`question_allowance.dart:380`) | `maestro_chat_screen.dart:407` | al tocco di *chiedi agli altri* |

**Gli Eos non scendono mai per un turno di chat.** Scendono solo nella strada
del riscatto, cioe' quando la persona compra un uso di un budget esaurito:
`QuestionAllowance.riscatta` (`question_allowance.dart:872-904`), innescata da
`upgrade_invite.dart:192`, dai tre punti `maestro_chat_screen.dart:459-475`
(approfondimenti), `:382-395` (confronti) e `ask_maestri_screen.dart:220-233`
(domande). **Sempre al tocco di un pulsante, mai per effetto di una risposta.**

**Le quattordici frasi che il Maestro emette senza chiamare il modello**, e
nessuna consuma: lettura gia' data (`maestro_chat_controller.dart:595-606`),
limite raggiunto (`:616-627`), instradamento (`:653-670`), turno interrotto
riaperto (`:527-538`), voce non configurata (`:1118-1126`), ripiego dopo due
troncature (`:1040-1054`), ripiego su guasto (`:1142-1160`), etichetta sotto
la bolla (`chat_bubble.dart:329`), e gli inviti al riscatto
(`maestro_chat_screen.dart:370-376`, `:387-396`, `:464-475`,
`ask_maestri_screen.dart:225-234`, `upgrade_invite.dart:194-205`), piu' il
seguito tutto ripetizione (`maestro_chat_controller.dart:873-879`).

### Cosa cambia

**Niente nel comportamento: la voce 04 e' gia' rispettata dal ramo, e questo
e' un fatto da dichiarare invece di fingere un lavoro.** Il fondatore ha
chiesto che cio' che non e' una risposta non consumi, e cio' che non e' una
risposta non consuma.

**Cambia la tenuta.** I due esiti che nessuno costruisce reggono solo grazie a
un `return` anticipato: il giorno che qualcuno toglie quel `return`, l'elenco
chiuso non protegge piu' niente. Il lavoro li fa **costruire davvero**, cosi'
la regola passa da `CostoDelTurno` come per tutti gli altri, e una guardia
pretende che ogni esito dichiarato sia prodotto da almeno un punto del codice.

---

## VOCE EB.05, NIENTE RIPETIZIONI E NIENTE PROPOSTE GIA' RIFIUTATE

**Oggi niente lo impedisce.** L'invito e' una costante
(`immersive_intents.dart:66` per la Stesa), e il ramo che lo manda non guarda
la conversazione: manda la stessa stringa ogni volta che la parola compare.
`lib/core/chat/cronologia_senza_doppioni.dart` riguarda **le domande
dell'utente** duplicate da un difetto della coda del server (ordine DV), non
le frasi del Maestro.

**Il lavoro:** un invito gia' dato non si ripete mai nella stessa
conversazione, e un'arte rifiutata resta chiusa per il resto della
conversazione. Dove il cancello non scatta piu', **il Maestro risponde**: non
tace e non ripete.

---

## VOCE EB.06, QUANDO MANCANO I DATI, IL MAESTRO LI CHIEDE

Con la voce 01 il responso di partenza viaggia **dentro il testo**, quindi il
caso dei dati mancanti si restringe. Resta per chi riapre una conversazione
vecchia o scrive senza passare da una porta.

**Il lavoro** sta nell'istruzione di sistema: quando manca qualcosa per
rispondere, il Maestro **chiede** cio' che gli serve con la sua voce, e non
rimanda a una funzione. Finche' non risponde nel merito non consuma, e questo
il ramo lo garantisce gia' (voce 04).

---

## VOCE EB.07, IL CENSIMENTO DELLE CHAT E IL CATALOGO DI OGNI MOSSA

### Il censimento delle chat

**Le chat sono tre, una per Maestro, e la schermata e' una sola**
(`lib/features/maestri/chat/maestro_chat_screen.dart`, controller
`maestro_chat_controller.dart`): il Maestro e' un parametro, non una
schermata diversa.

**Le porte da cui si aprono sono quindici**: le tredici della voce 01, piu'
due che aprono una chat vuota, `lib/features/maestri/maestro_screen.dart:655`
e `lib/features/maestri/art_intro_screen.dart:114`.

**I testi preimpostati sono tredici**, tutti in `chat_openers.dart`, tutti
composti da funzioni deterministiche senza AI.

**Le risposte preconfezionate sono le quattordici della voce 04**, piu' i
quindici inviti di `immersive_intents.dart`.

**Le istruzioni date a Gemini** vivono in
`lib/services/ai/maestro_persona.dart`: le regole comuni a `_commonRules`
(riga 35), la voce del singolo Maestro a `voceDi` (riga 133), che compone dal
dato di `VoceDelMaestro.di` (`lib/core/maestro/voce_del_maestro.dart:258` per
Medora, `:297` per Aura, `:340` per Caligo).

### Il catalogo delle mosse

Il catalogo lo scrive e lo esegue chi lavora, per decisione del fondatore del
21 settembre 2026 (*"Code procede"*). **Per ogni mossa: cosa fa il Maestro,
cosa dice, se compare un pulsante, se qualcosa viene consumato.**

| # | mossa dell'utente | cosa fa il Maestro | pulsante | consuma |
|---|---|---|---|---|
| 1 | chiede di interpretare un responso che ha gia' | interpreta quel responso, con la domanda a cui rispondeva | **no** | si', e' una risposta |
| 2 | chiede un responso nuovo di un'arte del suo dominio | apre quell'arte: qui l'invito **e'** la risposta | **si'** | no, il costo vive nell'arte |
| 3 | rifiuta una proposta del Maestro | prende atto in una riga e **risponde alla richiesta vera** che c'e' sotto; quell'arte resta chiusa per il resto della conversazione | **no, mai piu' per quell'arte** | si' |
| 4 | chiede una funzione che il Maestro non governa | nomina il Maestro giusto e non risponde al posto suo (regola gia' viva, `maestro_persona.dart:167-170`) | no | si' |
| 5 | pone una domanda fuori dal suo dominio ma dentro l'esoterico | risponde per quanto le sue arti permettono, e indica chi ne sa di piu' | no | si' |
| 6 | pone una domanda fuori dall'esoterico | risponde da persona, con la sua voce, e riporta al proprio terreno senza rimproverare | no | si' |
| 7 | manda un messaggio vuoto | niente parte: il campo non invia un testo vuoto | no | no |
| 8 | manda un messaggio incomprensibile | **chiede cosa intende**, con la sua voce (voce 06) | no | si', e' una risposta |
| 9 | scrive in un'altra lingua | risponde nella lingua della persona, se la sa riconoscere, altrimenti nella lingua dell'app; la regola vive in `lib/core/l10n/la_lingua_del_modello.dart` | no | si' |
| 10 | ripete la stessa richiesta uguale | **non ripete la stessa risposta**: riconosce di averne gia' parlato e porta un passo in piu' | no | si' |
| 11 | insulta o provoca | non risponde all'insulto e non si scusa: riporta la conversazione al motivo per cui e' li', con la sua voce | no | si' |
| 12 | tocca un argomento su cui il progetto impone cautela (salute, denaro, morte, gravidanza, legge) | nessuna promessa e nessuna diagnosi, come gia' vietato (`VoceDelMaestro.promesseVietate`), e indirizza a chi di dovere | no | si' |
| 13 | chiede al Maestro se e' una persona vera | non mente e non recita un copione: risponde con la sua voce restando se stesso | no | si' |
| 14 | chiede una funzione che nell'app non c'e' ancora | lo dice, senza promettere date | no | si' |
| 15 | manda solo un saluto o un ringraziamento | risponde breve, come farebbe una persona, senza aprire una lettura | no | si' |
| 16 | chiede di cancellare o dimenticare quello che ha detto | dice cosa puo' e cosa no, e indica dove si cancella davvero | no | si' |

Le mosse 13, 14, 15 e 16 non erano nell'elenco dell'ordine: le ha aggiunte
chi ha scritto il catalogo, come l'ordine chiede.

---

## VOCE EB.08, LE TRE PERSONALITA' E L'ILLUSIONE DELLA PERSONA VERA

### Come vivono nel codice, oggi

Le tre voci stanno **nel dato**, in `lib/core/maestro/voce_del_maestro.dart`:

| Maestro | riga | timbro | lessico di firma |
|---|---|---|---|
| Medora | `:258` | *voce del cielo e delle carte*, blu profondo e oro | cielo, transito, ascendente, arcano, lama |
| Aura | `:297` | calda e presente, senza fretta | respiro, centro, radice, corona, sentire |
| Caligo | `:340` | custode dei segni antichi e dei riti, rosso e oro | runa, presagio, soglia, sentiero, sigillo |

Ognuna porta registro, materia, apertura, chiusura, cio' che non dice mai, e
il **divieto incrociato** ricavato dagli altri due
(`maestro_persona.dart:162-165`, ordine BP voce 1). **La fondazione c'e'.**

### Cosa lavora contro l'illusione, e va tolto

**I quindici inviti di `immersive_intents.dart` sono frasi fatte, costanti,
identiche a ogni ripetizione, e non passano dalla voce del Maestro.** Sono il
punto esatto in cui l'illusione si rompe, ed e' il punto che il fondatore ha
visto due volte di fila. Dove l'invito resta legittimo, cioe' la mossa 2 del
catalogo, **la frase nasce dalla voce del Maestro** e non da una costante.

---

## LE GUARDIE

**Regola B, gia' eseguita prima di mettere mano.** Le guardie della zona sono
state viste rosse il 21 settembre 2026 con tre innesti in
`lib/core/chat/immersive_intents.dart` e `lib/core/chat/intent_classifier.dart`:
la Stesa passata a Caligo, il confine di parola tolto al classificatore,
l'invito della Stesa cambiato. **Tutti e tre hanno fatto cadere
`test/intent_routing_test.dart`.** Un quarto innesto provato, togliere la sola
parola `stesa` dall'elenco, **non ha fatto cadere niente, e giustamente**: la
parola `tarocchi` copre la stessa frase da sola, quindi era un innesto
ridondante e non un buco della guardia. Registrato in `docs/guardie.md`.

**Regola A**, per le guardie nuove: ognuna si vede rossa con un difetto
innestato a mano e verificato col grep, e chi gira su un insieme scoperto a
esecuzione dichiara il suo cardinale minimo.

**Regola C**: ogni difetto di questo ordine e' attribuito. Il classificatore a
parole chiave e' **PROVENIENZA IGNOTA**; la domanda che non arriva alla chat
della Stesa e' **PROVENIENZA IGNOTA** allo stesso modo, perche'
`ChatOpeners.stesa` nasce col file con la sola lista delle carte.
