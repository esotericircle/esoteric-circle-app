# ORDINE EE, I DONI DEL GIORNO, IL CONSIGLIO DEI MAESTRI, IL VIAGGIO DELLO SCIAMANO E I DATI SULL'ACCOUNT

**Sigla:** EE, riverificata sul ramo il 23 settembre 2026: in `docs/ordini`
non c'e' nessun `ORDINE_EE_*`, in `test/` nessuna `ordine_ee_guard`, e
**nessun documento del repo nomina un ordine EE** (ricerca su `docs/`,
`test/`, `lib/`, `tool/`: zero righe). **Data:** 23 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `0ebaaec8`,
l'ordine ED chiuso e la build 2275 consegnata.

VOCI_TOTALI: 14
VOCI_CHIUSE: 0
VOCI_APERTE: 14

Il rapporto stara' in `docs/ordini/RAPPORTO_ORDINE_EE.md`.

---

## LO SCARTO DI QUESTO MANIFESTO, dichiarato per primo

**Questo manifesto e' stato scritto dopo il codice delle voci 11, 12 e 13, e
la casa vuole il contrario.** La ragione: la voce 13 chiedeva per prima cosa
di verificare **quale versione delle funzioni fosse distribuita**, e quella
verifica ha trovato il server fermo al 16 settembre con sette commit di
scarto. Distribuire e' stata la prima cosa utile da fare, e da li' il lavoro
e' proseguito sulla causa. **Non e' una scusa: e' lo scarto, e sta qui in
cima perche' si veda.**

---

## GLI SCARTI FRA L'ORDINE E IL RAMO

1. **`tools/collaudo_dei_maestri.dart`** e' `tool/`, al singolare, come gia'
   per l'ordine ED.
2. **La voce 13 chiede di verificare le distribuzioni: erano tutte da fare, e
   le ho fatte io.** Questa macchina e' autenticata come
   `cloud@esotericircle.app` e ha la CLI di Firebase: **dal PC del fondatore
   non serve niente**. Le funzioni sul server erano ferme al **16 settembre**
   (`updateTime 2026-09-16T15:27`) contro **sette commit** del ramo su
   `functions/src/` fatti dopo.
3. **`statoDelCerchio` era gia' distribuita** dal 16 settembre, quindi il
   PASSO 8 di `DISTRIBUZIONI_DAL_TUO_PC.md` non era in sospeso come l'ordine
   suppone. Quello che mancava era tutto il resto.
4. **La causa vera della voce 12 non era il catalogo dei luoghi: era una
   porta mai aperta.** La callable `cercaIlLuogoNelMondo` esiste nel codice
   dal **16 settembre** (commit `bda25b14`, ordine DR) e il suo `createTime`
   sul server e' **2026-09-22T01:33:55**, cioe' la distribuzione di
   stanotte. **Per sei giorni la ricerca nel mondo ha chiamato una funzione
   che non esisteva, fallendo in silenzio** (`il_mondo_intero.dart:71-84`
   inghiotte l'errore e torna un elenco vuoto). **Padre: ordine DR**, il cui
   stesso commit avvertiva *"Il server va distribuito perche' la porta si
   apra"*.
5. **Il Viaggio dello Sciamano non ha un modulo suo.** L'ordine parla di *"una
   finestra schermata"* che il Viaggio apre: e' **la stessa**
   `DatiDiNascitaScreen` del menu' utente (`art_navigation.dart:89-91`).
   Stesso widget, stessa rotta. Quindi il censimento della voce 11 non trova
   tre porte ma **due**, ed e' una guardia a imporlo
   (`dati_nascita_sbloccano_test.dart`, Anello 5).
6. **Il Viaggio dello Sciamano non aveva nessuna porta verso il Cerchio**:
   zero chiamate al server in tutto `diario_dei_viaggi.dart`. Non era un
   difetto di sincronizzazione, era un dato che non aveva mai lasciato il
   telefono.
7. **E un dato veniva perso in transito, non dimenticato.** Il telefono
   spedisce nove campi dell'identita', fra cui la **forma di cortesia**
   (`cammino_da_custodire.dart:228`) e lo **scarto UTC**
   (`:236`); `IdentitaCustodita` in `functions/src/cammino.ts` ne dichiarava
   **sette**, e gli altri due venivano scartati al primo parsing. Il ramo del
   telefono che riadotta la forma **non si e' mai acceso in vita sua**, e il
   codice e' commentato come se funzionasse. **Padre: ordine CF voce 07**,
   che ha aggiunto l'invio senza il campo dall'altra parte.

---

## IL CENSIMENTO DELLA VOCE 11, OGNI PUNTO CHE CHIEDE UN LUOGO

**Le porte in cui la persona SCRIVE un luogo sono due**, e una guardia lo
impone. Tutti gli altri punti che "chiedono un luogo" o mandano a una di
queste due, oppure leggono la posizione dal GPS senza nessun elenco da
scrivere.

| # | dove | file e riga del campo | quale ricerca usa |
|---|---|---|---|
| 1 | Risveglio, passo del luogo di nascita | `onboarding_screen.dart:1579` | `RicercaDelLuogo` piu' `RicercaNelMondo` |
| 2 | Menu' utente, dati di nascita, luogo di nascita | `dati_di_nascita_screen.dart:310` | la stessa |
| 3 | Menu' utente, dati di nascita, dove vivi adesso | `dati_di_nascita_screen.dart:370` | la stessa |
| 4 | **Viaggio dello Sciamano** | non ha un campo suo: apre la 2 e la 3 | la stessa |
| 5 | Angelo Custode, Oroscopo, Sinastria VIP, Calendario | mandano alla 2 | la stessa |
| 6 | Specchio dei dati, rivelazione della carta natale | `completa_il_luogo.dart:31` e `:53` | la stessa |
| 7 | Il cielo di adesso, dal GPS | `sky_location.dart:184` | nessun elenco: geocodifica inversa |
| 8 | Dove sono adesso | `luogo_attuale.dart:40` | nessun elenco |
| 9 | Panoramica del cielo | `sky_overview_screen.dart:396` | nessun elenco |
| 10 | Sinastria, distanza fra due luoghi | `mappa_della_distanza.dart:133` | catalogo in sola lettura |

**La ricerca e' una sola e a due gradini**, da CF voce 08: prima il catalogo
locale (`ricerca_del_luogo.dart:41`), e **solo se tace** la domanda al mondo
(`:91`), che passa da `il_mondo_intero.dart` alla callable
`cercaIlLuogoNelMondo` e da li' a OpenStreetMap.

**La fonte dei luoghi**: `assets/data/luoghi.csv`, **40.848 righe** di cui
due di intestazione, quindi **circa 40.846 luoghi**, generato da
`tool/genera_luoghi.py`. Piu' un **seme compilato di 65 citta'** in
`city_catalog.dart:282-743`, che vale finche' l'asset non e' letto. Piu' il
mondo intero via OpenStreetMap, per tutto il resto.

---

## PARTE PRIMA, I DONI DEL GIORNO

## VOCE EE.01, ARCANO DELL'ALBA: IL MISCHIA

Al tocco di "Mischia" le carte si ricompongono in un mazzo, il mazzo si
mescola a vista e poi le carte si stendono di nuovo a ventaglio su tre righe.
La disposizione resta quella di adesso, e resta valida ogni regola gia'
decisa per l'Arcano dell'Alba, a partire dal verso deciso dal sistema e
invisibile prima del flip.

**APERTA.**

## VOCE EE.02, SOFFIO DEL DESTINO: RESPIRA IL SOFFIONE, E TUTTO SALE

Il cerchio d'oro sovrapposto sparisce: a seguire il respiro, allargandosi e
stringendosi, e' **il soffione stesso**. Il soffione e il riquadro "Preparati
a respirare" salgono, e lo spazio liberato va alla bolla descrittiva sotto,
che diventa piu' alta.

Il fondatore aveva gia' chiesto di togliere quel cerchio: **va cercato
sul ramo l'ordine che lo chiedeva e dichiarato perche' il cerchio e' ancora
li'**, col padre secondo la regola C.

**APERTA.**

## VOCE EE.03, RUNA DEL TRAMONTO: SETTE SERE DI FILA

Prima di cambiare qualunque cosa va dichiarato **col file e la riga** come la
striscia ricorda oggi le sere precedenti, cosa accade se si salta una sera,
quando e come nasce oggi il riassunto e dove finisce.

La regola diventa: il riassunto arriva **solo dopo sette Rune del Tramonto in
sette sere consecutive**, e una sera saltata fa ripartire la striscia dalla
prima. **L'utente lo capisce dalla schermata**: la frase la scrivo io, nel
tono di Caligo, e la giudica il fondatore sulla build. Alla settima sera il
riassunto entra da solo nel Cosmic Journal **come evento speciale**, distinto
dalle voci normali.

**APERTA.**

## VOCE EE.04, SIGILLO DEL SOGNO: UN TESTO GIUSTO E NON GENERICO

Va dichiarato come nasce il testo del riquadro, col file e la riga, e
verificato che **ogni fatto che afferma sia vero per quella persona e quella
notte**: fase e segno della Luna, aspetto con la Luna natale, richiamo alla
carta del giorno. **Ogni frase che vale uguale per chiunque** va sostituita
con cio' che i dati dicono davvero. Titolo e parte iniziale restano.

**APERTA.**

## VOCE EE.05, SIGILLO DEL SOGNO: IL SALUTO NON RIPETE IL TITOLO

Il titolo grande e' *"Lascia andare il pensiero, la notte non chiede visione,
chiede riposo."* e il testo sotto lo ripete parola per parola. Il saluto non
ripete il titolo, ne' per intero ne' quasi.

**APERTA.**

## VOCE EE.06, SIGILLO DEL SOGNO: VIA L'ETICHETTA "RESPIRO"

Sopra il titolo si legge *"Respiro · Il saluto di Medora"*. **"Respiro" e'
parola di firma di Aura** (`voce_del_maestro.dart:350`) e il Sigillo del
Sogno e' di **Medora** (`daily_elements.dart:10`). Quella parola viene dal
corpus delle dodici parole della notte, una per segno lunare:
`dream_rite_corpus.dart:145`, il segno **Acquario**. Va verificato che
nessun altro testo fisso del rito porti parole di firma di Aura o di Caligo,
con l'esito nel rapporto.

**APERTA.**

---

## PARTE SECONDA, LA CHAT E IL CONSIGLIO DEI MAESTRI

## VOCE EE.07, IL CHIARIMENTO NON COSTA

Un turno in cui il Maestro **chiede** un chiarimento o i dati che gli mancano
**non fa scendere nessun contatore**: ne' le domande, ne' gli approfondimenti,
ne' i confronti, ne' gli Eos. Il contatore scende solo sul turno in cui il
Maestro risponde nel merito.

**Lo scarto con l'ordine EB e' dichiarato**: `ORDINE_EB_MANIFESTO.md` voce
EB.06 dice *"Una domanda del Maestro e' una risposta vera, quindi consuma"*,
e il catalogo segna `consuma: si'` per la mossa 8. **Padre: EB voce 06.** Il
catalogo delle mosse si aggiorna qui, e il collaudo si rilancia sui tre
Maestri con le trascrizioni in `docs/collaudo/EE/`.

**APERTA.**

## VOCE EE.08, IL CONFRONTO COMPRATO CON GLI EOS

Un confronto comprato con gli Eos **compare subito nel contatore** come
disponibile, e una volta aperto mostra **tutti e tre i Maestri** piu' la
sintesi. Va dichiarato col file e la riga cosa e' stato comprato con quei 150
Eos, cosa e' stato consegnato, e cosa accade oggi a chi paga e riceve meno.

**APERTA.**

## VOCE EE.09, LA SINTESI CHE NON CONOSCE IL NOME

La sintesi comparativa comincia con *"Caro, non conosco il tuo nome, ma se
vuoi puoi dirmelo."* mentre nella stessa schermata Aura e Caligo chiamano il
fondatore per nome. La sintesi riceve i dati della persona come li ricevono i
Maestri, e non dice mai di non conoscere un nome che l'app conosce.

**APERTA.**

## VOCE EE.10, TESTI CORRETTI E COERENTI NEL CONSIGLIO

Due difetti gia' visti:

1. Caligo scrive *"la Tre di Denari"* e *"La Tre di Coppe"*: il genere giusto
   e' **"il Tre di Denari"**, e la regola vale per tutti i numeri e per tutti
   e tre i Maestri.
2. La sintesi comparativa **ripete** le tre risposte con frasi valide per
   chiunque (*"La Ruota della Fortuna, per tutti, segna un ciclo che si
   rinnova"*) invece di **confrontare** i tre sguardi: dove concordano, dove
   divergono e perche'.

Il collaudo si estende al Consiglio e alla sintesi su almeno una stesa vera.

**APERTA.**

---

## PARTE TERZA, IL VIAGGIO DELLO SCIAMANO E I DATI SULL'ACCOUNT

## VOCE EE.11, IL LUOGO NEL MODULO DEL VIAGGIO DELLO SCIAMANO

Nel modulo che il Viaggio apre quando mancano i dati, la ricerca del luogo
funziona come nel menu' utente. Il censimento per intero sta qui sopra.

**APERTA.**

## VOCE EE.12, TUTTI I LUOGHI DEL MONDO

La ricerca trova ogni citta', paese e villaggio del mondo, e **"Borgo di
Rivalta" si puo' scegliere**. Va dichiarato perche' mancava, col padre, quale
fonte si usa dopo il lavoro e quanti luoghi contiene.

**APERTA.**

## VOCE EE.13, I DATI DELLA PERSONA VIVONO SUL SUO ACCOUNT

Dati di nascita, progressi, traguardi e Viaggio dello Sciamano concluso
sopravvivono all'aggiornamento, al cambio di telefono e al login altrove.
Per ciascun tipo di dato va dichiarato dove viene salvato oggi, col file e la
riga, e dove dopo il lavoro.

**APERTA.**

## VOCE EE.14, "SCENDI" SOLO DOPO UNA SCELTA

Nel Viaggio dello Sciamano il pulsante "Scendi" e' attivo soltanto quando
l'utente ha scelto o scritto una domanda, oppure ha scelto "Solo incontro".

**APERTA.**
