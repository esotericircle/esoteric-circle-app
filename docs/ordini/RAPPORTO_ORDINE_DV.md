# RAPPORTO DELL'ORDINE DV, MESSAGGI MAI SCRITTI E DOMANDE DOPPIE

**Data:** 18 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_DV_MANIFESTO.md`. **Nessuna build** nella
prima parte, come l'ordine chiedeva; dopo le correzioni il fondatore ha chiesto
la consegna: **Android 2269**, release `61j48k0b827oo`, accesa sul Realme; iOS
da lanciare su Codemagic.

**Dodici voci, dodici chiuse**: le otto dell'ordine e le quattro nate dalle correzioni del fondatore dopo la consegna, sezione 9.

---

## 1. DA DOVE ARRIVAVANO QUEI MESSAGGI, E PERCHE' ERANO DOPPI

**Perche' erano doppi: la coda verso il server.** Nell'app vera ogni scrittura
della memoria passa dal server: si accoda in
`FirestoreMaestroMemoryRepository._daMandare` e parte da `_svuotaLaCoda`. La
chat salva la domanda senza aspettare e subito dopo salva il turno del Maestro
(la risposta, il turno in attesa, o l'invito di un instradamento). Le due
scritture svuotavano la coda **insieme**: ognuna leggeva il primo elemento,
cioe' la stessa domanda, e la mandava. Il server scrive ogni messaggio con un
documento nuovo (`functions/src/cerchio.ts`, operazione `messaggio`, `add`),
quindi la domanda finiva scritta due volte. Poi la seconda corsa toglieva da una
coda gia' vuota e sollevava un errore, che l'app inghiotte perche' la
cronologia non deve fermare la chat.

Misurato al banco **prima di toccare il codice**, con un server finto che fa cio'
che fa quello vero e risponde con un ritardo, come la rete:

| domanda | cosa scriveva il server |
|---|---|
| *Lettura generale energia oggi* | domanda, domanda, risposta |
| *Carta del giorno* | domanda, domanda, invito dell'Arcano dell'Alba |
| *Estrai una runa per me* | domanda, domanda, invito delle rune |

**E' esattamente cio' che si vede nelle catture del fondatore.** *"Carta del
giorno"* quattro volte in due coppie separate da una risposta sono due invii,
ognuno scritto due volte.

**Da dove arrivavano: non tutti dall'app.** Due delle domande delle catture non
le ha scritte ne' il fondatore ne' l'app:

- ***"Carta del giorno"* l'ho scritta io**, sul telefono del fondatore e col suo
  account, con `adb input text`, durante la prova a video dell'ordine DS del 17
  settembre. Sta nel rapporto di quell'ordine, catture 08a, 08b e 08c. Non e'
  una domanda suggerita: nel pannello di Medora c'e' *"Tira una carta per me"*.
- ***"Lettura generale energia oggi"* non compare in nessuna versione del
  codice**, su nessun ramo. Non e' una domanda dell'app. Non so chi l'abbia
  scritta: puo' essere una prova a video di un ordine precedente, come la carta
  del giorno, o una dettatura. **PROVENIENZA IGNOTA.**

Le altre tre sono dell'app: *"Estrai una runa per me"* e *"Quale rito sostiene
un mio traguardo?"* sono nel pannello di Caligo, la domanda del soffio e'
l'apertura con cui il Soffio del Destino apre la chat di Aura.

**Il raddoppio invece riguarda tutte**, perche' nasce nel salvataggio e non nel
modo in cui la domanda arriva.

---

## 2. I CONTATORI

| domanda | chiama il modello | consuma una domanda | il punto del codice |
|---|---|---|---|
| *Carta del giorno* | no | no | `maestro_chat_controller.dart`, `_ricevi`: l'instradamento torna prima di `_generate` |
| *Estrai una runa per me* | no | no | idem |
| *Lettura generale energia oggi* | una volta | una | `_ricevi` → `_generate`, poi `contatore.record` se `CostoDelTurno.consuma` |
| *Quale rito sostiene un mio traguardo?* | una volta | una | idem |
| **il doppione** | **no** | **no** | nasceva in `_svuotaLaCoda`, dopo l'invio: non passa ne' da `_generate` ne' da `record` |

Misurato col contatore vero in `la_chat_non_raddoppia_le_domande_test.dart`,
*i contatori*.

**Il contatore avrebbe dovuto muoversi di uno per ciascuna delle due domande
al modello**, la prima volta che venivano fatte nel giorno. Che sul telefono sia
rimasto a dieci su dieci **non si spiega dal codice della chat**: il conto
locale sale, e alla sincronizzazione il telefono prende il numero che dice il
server (`QuestionAllowance.sincronizza`, `_count = stato.spesi['domande']`).
Le strade possibili sono tre, e distinguerle chiede il telefono o il server:

1. la domanda era gia' stata fatta quel giorno, e la seconda volta la lettura
   viene ridetta senza costo (ordine DS voce 08);
2. la risposta non era una risposta vera ma un ripiego, che non costa;
3. il server non ha contato il consumo, e alla sincronizzazione ha riportato
   il telefono a zero.

**Non ho fatto la verifica sul telefono**: vorrebbe dire fare domande vere col
tuo account e consumare il tuo budget, e dopo *"Carta del giorno"* non voglio
scrivere niente di mio nella tua cronologia senza che tu lo decida.

---

## 3. DOVE NASCE, E SE RESTA

- **Nel salvataggio.** I doppioni esistono davvero nei dati. Non nel
  caricamento e non nella presentazione.
- **Resta dopo aver chiuso e riaperto l'app**, perche' la chat riaperta rilegge
  dal server: e' cio' che il fondatore vedeva.

---

## 4. LA CORREZIONE

1. **La coda corre una volta sola.** Chi arriva mentre un'altra corsa sta
   svuotando la aspetta; gli elementi aggiunti li prende la corsa in atto; se
   alla fine ne resta qualcuno ne parte una nuova. Controllo e assegnazione
   stanno nello stesso passo senza attese in mezzo.
2. **L'invio accetta una chiamata alla volta su tutte le strade.** La guardia
   che c'era si alzava solo dentro la generazione, quindi gli instradamenti e
   la lettura gia' data accettavano un secondo invio: un doppio tocco sul
   pannello diventava due domande.
3. **La cronologia si legge senza i doppioni gia' scritti**
   (`CronologiaSenzaDoppioni`): due domande uguali una dietro l'altra, nella
   stessa conversazione, senza niente in mezzo. Nessun gesto le puo' produrre,
   perche' dopo ogni domanda c'e' sempre un turno del Maestro; una domanda
   ripetuta davvero ha la sua risposta in mezzo, e resta.

---

## 5. I DOPPIONI GIA' SCRITTI

**Il telefono li nasconde gia'**, a schermo e nel contesto che torna al modello:
chi aggiorna l'app non li vede piu'.

**Nei dati restano**, e vanno tolti perche' sono dati falsi su una persona:
finiscono nelle sintesi settimanali della memoria e nei Ricordi del Cerchio.
Lo strumento e' `functions/src/pulisci_doppioni.ts`, con la stessa regola del
telefono (`functions/src/doppioni.ts`, provata in `doppioni.test.ts`). Dal tuo
PC, nella cartella `functions`:

```
npm run build
node lib/pulisci_doppioni.js
```

Senza argomenti **conta e basta** e stampa quante cronologie, quanti messaggi e
quanti doppioni. Si legge il conto, e solo dopo si lancia con `--davvero`.
Serve una sessione con i permessi sul progetto
(`gcloud auth application-default login`).

**La seconda difesa e' fatta** (voce DV.09, dopo il via del fondatore): il
telefono decide l'identificativo del messaggio prima di accodarlo, e il server
crea il documento con quel nome, quindi anche un reinvio vero, per esempio dopo
una rete caduta, non raddoppia. Tocca il server, quindi **va distribuita dal
tuo PC**:

```
firebase deploy --only functions:scriviLaMemoria
```

Finche' non e' distribuita, il server vecchio salva l'identificativo come un
campo in piu' e non fa danni.

---

## 6. LE PROVE, E QUELLE VISTE ROSSE

| prova | vista rossa con |
|---|---|
| `nessun_messaggio_si_scrive_due_volte_test.dart` | la coda di prima: *Carta del giorno* scritta due volte e RangeError |
| `la_chat_non_raddoppia_le_domande_test.dart`, le cinque domande | la coda di prima: nove prove rosse sui tre Maestri |
| `la_chat_non_raddoppia_le_domande_test.dart`, il doppio tocco | l'invio senza la guardia all'ingresso |
| `la_chat_non_raddoppia_le_domande_test.dart`, i doppioni gia' scritti | la lettura senza la pulizia |
| `functions/src/doppioni.test.ts` | sei casi, gli stessi della prova del telefono |

**Perche' al banco il difetto non si vedeva**: tutte le prove della chat usavano
il repository in memoria, che non ha la coda. Le prove nuove usano il
repository vero con un server finto fedele (`test/server_fedele_della_memoria.dart`).

---

## 7. IL PADRE DEL DIFETTO

**Ordine N voce 2e, commit `7797f63c` dell'11 agosto 2026**: *"Contatori,
memoria e saldo Eos vivono sul server"*. Quel commit ha fatto nascere **due code
uguali**, una per i consumi del contatore e una per la memoria. Quella del
contatore e' nata protetta, con un commento che dice *"due gesti di seguito ne
avviavano due, e la seconda toglieva dalla coda un elemento che la prima aveva
gia' tolto. Trovato dalla prova"*. **Quella della memoria no.** E' la famiglia
delle due porte: lo stesso difetto curato in un posto e lasciato nell'altro.

Dall'11 agosto quindi ogni domanda ai Maestri, su ogni telefono, e' stata
scritta due volte.

---

## 8. LE CATTURE

Dodici, in `docs/collaudo/DV/`: per Medora, Caligo e Aura, la chat dopo una
domanda suggerita **toccata due volte**, la chat aperta da un Dono del Giorno, e
le stesse due riaperte da app chiusa, cioe' con un repository nuovo che rilegge
dal server. In tutte e dodici la domanda compare una volta sola.

**Sono catture del banco, non del telefono.** L'ordine vieta la build, e senza
una build il codice corretto non arriva sul telefono. Al banco la chat usa il
repository vero e un server fedele, ma il Maestro che risponde e' finto: dice la
stessa riga per tutti e tre, e per questo anche Aura parla di stelle. **Le
catture dal telefono vengono con la prossima build, quando la ordini.**

---

## 9. LE CORREZIONI DOPO LA CONSEGNA

Mauro, letto il rapporto: *"ok per la seconda difesa e per tutti i consigli che
ritieni utili"*; e sull'Arcano dell'Alba, con due catture dal telefono, il testo
attaccato ai bordi del pannello e *"il gesto di oggi"* che non era un gesto.

- **DV.09, la seconda difesa**: sezione 5.
- **DV.10, l'errore inghiottito.** Il difetto della coda e' rimasto un mese
  senza traccia perche' la chat annotava il guasto in un log che si legge solo
  col debugger. Adesso ogni guasto innocuo arriva a Crashlytics come non
  fatale, con la frase che dice cosa si stava facendo. La chat continua come
  prima.
- **DV.11, il pannello**: sedici punti di margine per lato (prima zero, misurato
  a video) e il gesto nel suo riquadro, con un filo d'oro, il titolo, il gesto,
  il titolo *Perché* e il perche'.
- **DV.12, il gesto e' un gesto.** Tutti i 528 gesti del corpus riscritti come
  azioni concrete, con un oggetto, un numero o un tempo precisi, e ognuno col suo
  perche'. Li ho letti tutti e ne ho ritoccati 61: frasi che parlavano solo a un
  uomo (*"sei gia' arrivato"*, *"da solo"*, *"te stesso"*), ore che mentono a chi
  gira la carta piu' tardi (*"entro mezzogiorno"*), due *"Dì"* senza apostrofo,
  qualche frase che dava per scontata una situazione. Lo sbarramento ne ha
  trovati altri quattro: un *"sei disposto"*, due *"a quattr'occhi"* che la
  guardia degli apostrofi legge come accenti mancati, e un gesto della Stella
  che parlava di terapie e di guarigione della persona, fuori dal confine del
  responso. Esempio, la Luna dritta
  del telefono: prima *"Accetta una confusione senza risolverla"*; adesso
  **gesto** *"Prendi un foglio e scrivi tre domande che oggi ti mettono in
  confusione, senza cercare risposte."*, **perche'** *"Scritte, le domande
  escono dalla testa e ti stanno davanti."*

**Padri**, cercati nella storia con `git log -S`:

- DV.11: il margine solo in alto nasce con la schermata, **ordine DT**, commit
  `47b3c2be` del 17 settembre 2026; l'**ordine DU** gli ha messo sotto il velo
  (commit `f8c33e41`) senza aggiungere i lati.
- DV.12: *"Accetta una confusione"* e la forma *"atteggiamento: azione"*
  entrano con le 528 letture, **ordine DU voce 12**, commit `ebaee64b` del 17
  settembre 2026. Le voci DU.08 e DU.09 volevano la parola dentro il dono, e
  molti doni la mettevano in un verbo d'atteggiamento.
- DV.10: l'annotazione solo nel log nasce con `annotaGuastoInnocuo`, commit
  `fe4395dd` del 2 agosto 2026. Il commit non dice l'ordine: **PROVENIENZA
  IGNOTA** per la voce.
