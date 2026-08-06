# ORDINE ESPLORA, la striscia di navigazione che si ritrae

Ordine di Mauro del 6 agosto 2026, copiato qui per intero prima di cominciare,
cosi' chi riprende lo trova senza doverlo ricostruire da una conversazione.

## Il nome, con la storia della decisione

**Si chiama ESPLORA.** Deciso da Mauro il 6 agosto 2026, chiuso, non si riapre.

Nelle Decisioni Approvate del 4 agosto 2026 il nome scelto era **Sentieri**, con
"Esplora" scartato perche' giudicato corretto ma da app qualunque; "Viaggia" invece
scartato perche' nell'app viaggio e' gia' il viaggio del giorno dell'Animale
Guida: la stessa parola con due significati e' la confusione gia' pagata con
la bilancia letta come segno zodiacale.

**Quella riga e' superata, per la stessa ragione che l'aveva scritta.**
Verificato nel repository il 6 agosto 2026: "sentieri" e' gia' occupato, due
volte, in posti centrali.

- `docs/02_Briefing_Progetto_Definitivo.md`, sezione 13, si intitola **"Cosmic
  Journal a tre sentieri"**: i sentieri sono tre, uno per Maestro, ciascuno con
  la propria palette, con la barra complessiva che li attraversa.
- Nello stesso briefing l'**Albero della Vita** ha dieci Sefirot e **ventidue
  sentieri** corrispondenti ai ventidue Arcani.

Nove occorrenze nel solo briefing di progetto, altre nei tre restanti. Chiamare
Sentieri la striscia di navigazione avrebbe dato alla stessa parola due
significati dentro la stessa app, che e' esattamente il difetto per cui era
stato scartato "Viaggia".

**Nota su dove viveva la decisione.** Le Decisioni Approvate del 4 agosto 2026
non stanno nel repository: cercate il 6 agosto in tutti i `.md` sotto `docs/`,
non esiste ne' un documento con quel nome ne' una riga che scarti "Esplora"
come nome di navigazione. La decisione e' quindi registrata qui e in
`STATO_VIVO.md`, non aggiornata altrove, perche' non c'era niente da
aggiornare.

## La regola, per intero

- Si chiama **ESPLORA**.
- Si riduce a una **linguetta sottile** col solo titolo e una freccetta verso
  l'alto. La linguetta resta **sempre visibile**: mai un vicolo cieco.
- **Si chiude scorrendo verso il basso**, cioe' quando la persona legge, e
  **torna scorrendo verso l'alto**.
- **Nessun timer.** Una striscia che si abbassa da sola mentre il dito ci sta
  andando manda il tocco a vuoto oppure colpisce cio' che sta sotto.
- Si presenta **aperta soltanto alla primissima apertura in assoluto**, che si
  riconosce da `onboarding.done`. Mai a ogni ritorno.
- **Assente nelle esperienze immersive**: stesa, riti, meditazione. Li' non c'e'
  nemmeno richiusa.
- Con **Riduci Movimento** cambia stato senza transizione.
- Contiene le vie verso il Cerchio e verso i tre domini.
- I **Doni restano solo in home**.
- Compare **anche nelle chat dei Maestri**, come scorciatoia: e' li' che nasce
  il problema che l'ha generata, cioe' che da chat, Consiglio e ritorno a un
  altro Maestro tornare alla home diventa lungo.
- Il **tasto indietro non salta alla home** e non schiaccia la pila: torna alla
  schermata precedente. Si evita soltanto che la **stessa** schermata finisca
  due volte nella pila: se dal Consiglio si torna da un Maestro la cui chat e'
  gia' aperta piu' in basso, ci si **torna** invece di aprirne una seconda.
  Cosi' la catena chat, Consiglio, chat non cresce oltre tre schermate.

## Dove vive la regola

Attorno ad `AppShell`, **in un posto solo**, mai dentro le singole schermate:
sarebbe la ventunesima occorrenza della famiglia delle due porte.

L'elenco delle immersive e' **nuovo e dichiarato**. **Non** si ricava da
`ImmersiveTarget` in `lib/core/chat/immersive_intents.dart`, che elenca dove la
chat instrada e contiene Oroscopo, carta natale e sinastria, che immersive non
sono. Va scritto con la ragione accanto. Una prova enumera le schermate e cade
se una nuova non e' classificata ne' in un modo ne' nell'altro.

## Le prove chieste, ognuna col rosso eseguito davvero

1. L'enumerazione di **tutte** le schermate, con presenza e assenza attese.
2. Lo scorrimento nei due versi: scende scorrendo giu', risale scorrendo su.
3. Nessun timer chiude la striscia.
4. La catena chat, Consiglio, chat non supera tre schermate nella pila.
5. L'apertura automatica avviene solo la primissima volta.

## Le anteprime chieste

A 1080x2391, col precache prima della cattura, senza banner di debug, montate
come e' montato cio' che provano:

- la linguetta chiusa dentro una chat;
- la striscia aperta;
- la home alla primissima apertura;
- una schermata immersiva dove non c'e' affatto.

## Vincoli di lavorazione

Commit a ogni pezzo chiuso, per percorsi espliciti. **Nessuna build**: la ordina
Mauro. Nessuna prova calcola l'atteso dalla costante che sorveglia, nessun
ripiego muto, nessuna costante che dichiara il falso.

## Lo stato di partenza, come l'ho trovato il 6 agosto 2026

Le premesse dell'ordine sono state verificate una per una prima di scrivere
codice. Quattro erano false, quindi vale la pena che restino scritte.

| premessa | esito |
|---|---|
| la striscia esiste | **vera**: `SantuarioBottomBar`, istanziata in un punto solo, `app_shell.dart` |
| compare in quali schermate | **due sole**: Santuario e Cosmic Passport, perche' `ShellView` ha due valori |
| reagisce allo scorrimento | **falsa**: sta ferma, il solo `NotificationListener` alimenta la parallasse |
| compare nelle chat | **falsa**: la chat e' una rotta spinta sopra il guscio, col proprio Scaffold |
| regola contro il doppione nella pila | **falsa**: non esiste, cercati `popUntil`, `withName`, `pushReplacement` |
| si sa la primissima apertura | **vera**: `OnboardingController`, chiave `onboarding.done` |
| elenco delle immersive | **vera a meta'**: `ImmersiveTarget` esiste ma elenca altro |

A schermo la striscia oggi non ha un nome unico: ha cinque voci, Il Cerchio, i
tre Maestri, Passport.

---

# ESITO, 6 agosto 2026

Commit `7fec270` (la striscia, il punto unico, le prove) e `65f4b41` (le quattro
anteprime). Suite verde, nessuna build: la ordina Mauro.

## Cosa e' chiuso

- **Il punto unico.** `EsploraScope` nel `builder` di `MaterialApp`, che
  avvolge il Navigator intero: e' il solo posto che vede anche le chat, che
  sono rotte spinte sopra il guscio col proprio Scaffold. Nessuna schermata sa
  di Esplora. L'osservatore riconosce il **tipo** del widget della rotta.
- **L'elenco dichiarato**, `lib/features/shell/esplora_schermate.dart`, con tre
  stati e la ragione di ciascuno accanto.
- **La linguetta e la striscia**, sempre visibili dove devono, assenti nelle
  immersive, senza timer, aperte da sole solo alla primissima apertura.
- **La regola contro il doppione**, sul tipo della schermata.
- **Otto rossi eseguiti davvero**, cinque sul comportamento e tre
  sull'enumerazione. Venti prove verdi fra i quattro file toccati.
- **Quattro anteprime** catturate sull'app intera.

## Le tre cose imparate sbagliando

1. La palette si legge da `MaestroController.activeKey`: Esplora vive sopra
   `MaestroScope`, quindi `context.palette` cade e la striscia non compariva.
2. La prima passata sull'albero va fatta a mano in `initState`: la rotta
   iniziale viene spinta prima che lo scope si monti.
3. Una prova cieca nascondeva un difetto vero: `find.byType` salta cio' che sta
   fuori scena; contando le rotte il rosso ha mostrato che
   `EsploraNavigazione.osservatore` non era collegato.

---

# LE SEI VOCI APERTE

Rilievi dell'Architetto, in coda alle voci di Mauro. **Nessuna e' stata
eseguita:** sono scritte perche' chi riprende non le ricostruisca da una
conversazione.

## A. Nella home ci sono due barre sovrapposte

Nell'anteprima `esplora-aperta.png` la striscia Esplora sta **sopra**
`SantuarioBottomBar` e la copre in parte, con le due che mostrano **le stesse quattro
vie**. Nel Santuario e nel Passport, cioe' le due sole schermate dove
`ShellView` mostra la barra del guscio, Esplora duplica invece di accorciare.

**E' una decisione di Mauro, non una correzione.** Le due strade sono: o Esplora
sparisce dove la barra del guscio c'e' gia', oppure la sostituisce e si porta
dentro anche il **Passport**, che oggi ha una voce nella barra e non ne ha una
in Esplora.

**Non eseguire nulla su questa voce senza una risposta di Mauro.**

## B. Le etichette escono sottolineate

Tutte e cinque: `Esplora` nella linguetta, piu' `Il Cerchio`, `Medora`, `Caligo`,
`Aura` nella striscia aperta. Visibile in `esplora-aperta.png` e in
`esplora-linguetta-in-chat.png`.

**Ipotesi, da verificare prima di correggere e da dichiarare anche se cade:**
non e' una `decoration` scritta a mano, e' la firma di un `Text` senza un
antenato `Material`, perche' Esplora vive nello `Stack` del builder.

Se l'ipotesi regge, la correzione **non** e' mettere `TextDecoration.none` sui
quattro stili, che curerebbe il sintomo in quattro punti: e' avvolgere la
striscia in un `Material` con tipo trasparente, cioe' in **un posto solo**.

## C. La striscia copre il contenuto in fondo

Misurato sulle anteprime a 1080x2391: la linguetta e' alta **105 pixel**, cioe'
35 punti logici; la striscia aperta **186 pixel**, cioe' 62 punti. In
`esplora-linguetta-in-chat.png` copre meta' di "Scrivi a Medora" e il pulsante
di invio; con la striscia aperta il campo di scrittura sparisce.

Il posto della correzione e' **`EsploraScope`**, non le singole schermate. Il
modo: **non** un margine grezzo sul figlio, ma un `MediaQuery` che aggiunge quei
punti al `padding` basso, cosi' ogni `SafeArea` gia' esistente ne tiene conto da
sola.

Le due altezze vanno dichiarate come costanti **con una prova che le confronta
con la resa vera**, altrimenti diventano due costanti che dichiarano il falso.

## D. Un'anteprima non prova quello che dichiara

`esplora-prima-apertura.png` mostra **Il Risveglio**, cioe' la soglia, dove
Esplora per progetto non c'e'. La prova chiesta dall'ordine, cioe' la home alla
primissima apertura con la striscia gia' aperta, **resta senza immagine**.

L'anteprima della soglia e' utile e si tiene, con un nome che dica cos'e'.

## E. `onChiudi` non e' usato

In `_Aperta` il costruttore lo pretende, `EsploraStriscia` glielo passa, e
dentro `build` non compare mai. O si collega, o si toglie.

## F. Due rilievi, di costo e di silenzio

**Il costo.** `_aggiornaSchermata` visita l'albero **intero** a ogni push e a
ogni pop, dentro un post frame callback che costa un frame in piu' per ogni
cambio di rotta. Va **misurato** sulla Stesa a settantotto carte, non stimato.

**Il silenzio.** Quando nessuna schermata dichiarata viene trovata, `siVede` e'
falso e la striscia sparisce senza dire niente. La prova che enumera protegge il
**sorgente**, non il caso a **runtime**: quello e' un ripiego che non dichiara di
esserlo.


---

# ESITO DEL 6 AGOSTO, SECONDA TORNATA: la causa vera delle due barre

Commit `b7b0651`. Chiude le voci A gia' aperta in altra forma, B e F.

## La causa non era quella che sembrava

Sul telefono, nella 2153, nel Santuario si vedevano due barre. L'ipotesi era che
il difetto vivesse nella prima passata fatta a mano in `initState`, cioe' che
alla prima valutazione l'albero non fosse ancora completo. **Quell'ipotesi e'
caduta, misurata montando l'app dall'avvio vero:** al primo `pump` e a 900 ms nel
Santuario Esplora era gia' ASSENTE.

Il difetto stava dopo. `_aggiornaSchermata` girava **una volta per evento di
navigazione**, dentro un post frame callback, e in quel momento la rotta
**uscente** era ancora montata. Tornando dal dominio l'albero conteneva ancora
`DomainScreen`, la decisione diceva `presente`, e **nessun altro evento arrivava
a correggerla**: la striscia restava accesa sopra la barra del guscio, e ci
restava.

La correzione: la schermata in cima si chiede alla **pila** dell'osservatore, che
in `didPop` toglie la rotta subito, quindi `pila.last` e' gia' quella giusta
quando l'evento arriva. Cade con essa anche il costo della visita all'albero
intero a ogni push e a ogni pop, che era il rilievo F.

## Le quattro premesse cadute, misurate

| premessa dell'ordine | esito |
|---|---|
| due barre nel Santuario | **falsa al primo fotogramma**: a `pump` e a 900 ms Esplora era assente |
| sparisce dopo un push e un pop | **falsa e invertita**: dopo il pop **compariva** e restava |
| due barre anche nei domini | **falsa**: nel dominio non esiste nessuna `BottomNavigationBar`, ed Esplora e' una sola |
| tutte e cinque le etichette sottolineate | **vera solo per la linguetta**: le altre erano della barra del guscio |

## Le etichette

L'ipotesi del `Text` senza antenato `Material` **reggeva**: la linguetta usciva
con `TextDecoration.underline`, mentre le voci della barra del guscio, che un
`Material` ce l'hanno, uscivano con `none`. La correzione e' un `Material`
trasparente attorno alla striscia, in un posto solo.

## La prova guardava la cosa sbagliata

Quella di prima verificava lo stato **assestato**, ed e' per questo che era
rimasta verde mentre sul telefono si vedevano due barre. Ora guarda il **primo
fotogramma** e poi il **ritorno da un push**. Rosso eseguito rimettendo la visita
all'albero: la striscia resta accesa dopo il pop e la prova cade.

## Cosa resta aperto

Le voci **1b, 1c, 1d, 1f**, la **voce 2** sui Doni e la **voce 3** sull'aura
passano a una sessione nuova: i tocchi nelle chat, il movimento continuo, le
liste che non devono divergere, i Doni che nominano il Maestro, la leggibilita'
del Soffio e l'alone dietro le figure.


---

# LA STRISCIA NON ESISTE PIU', 6 AGOSTO 2026

**Decisione di Mauro, presa il 6 agosto 2026 guardando l'anteprima.** La striscia
Esplora e' stata TOLTA da tutta l'app. Al suo posto resta una barra sola, quella
STORICA del guscio, che porta il titolo ESPLORA e si vede anche dove prima non
arrivava.

## Perche'

Erano due superfici per le stesse cinque destinazioni: la barra storica dentro
`AppShell`, visibile nel Santuario e nel Passport perche' `ShellView` ha due
valori, e la striscia sopra il Navigator, che copriva il resto. Due barre che
dicono la stessa cosa sono una di troppo, e nella fascia bassa se ne vedevano
gli effetti: cinque voci dorate della striscia piu' un titolo dorato producevano
una riga illeggibile.

## Cosa e' stato tolto

`lib/features/shell/esplora.dart`, `lib/features/shell/esplora_schermate.dart`,
le loro prove e le sei anteprime `esplora-*.png`. Nessun riferimento resta.

## Cosa si e' SALVATO, perche' era lavoro misurato

- **Il governo del movimento continuo**, che legge il DITO e non l'avanzamento
  nella lista: in una lista rovesciata come la chat lo stesso gesto darebbe il
  verso opposto. Vive ora in `lib/features/shell/barra_del_cerchio.dart`.
- **Il `MediaQuery` che fa posto al contenuto** invece di coprirlo, con lo
  spazio che cambia a soglia e non a ogni pixel di scorrimento.
- **La regola contro il doppione nella pila**, che serve ancora e serve di piu':
  la barra porta alle stesse destinazioni da ogni schermata, quindi senza di lei
  bastano due tocchi per impilare due domini uguali. Vive in
  `NavigazioneDellaBarra.apriUnaVoltaSola`, e una prova mostra che senza di lei
  i domini vivi diventano due.
- **L'elenco unico delle vie**, `vie_del_cerchio.dart`, che la barra storica
  legge gia'.

## Dove si vede la barra, elenco chiuso

`lib/features/shell/dove_si_vede_la_barra.dart`, con accanto il nome di classe
di ogni schermata dell'app. Cinque la portano: `SantuarioScreen`,
`CosmicPassport`, `DomainScreen`, `MaestroChatScreen` e `AskMaestriScreen`, che
e' il nome di classe del Consiglio del Cerchio. Tutto il resto no, compresi i
cinque Doni del giorno e le esperienze immersive.

## Le misure

Altezza della barra 123 punti col titolo compreso, corsa 123, confrontate con la
resa vera. Il titolo e' smorzato, `ColorTokens.textMuted` a corpo 11, sopra le
voci: e' una nota di servizio e non una sesta destinazione.

## Le tre cose imparate spostando la barra

1. **`InkWell` pretende un `Material` antenato.** Dentro il guscio glielo dava
   lo Scaffold; sopra il Navigator non c'e' nessuno Scaffold e la barra non si
   costruiva affatto. Se lo porta lei, in un posto solo.
2. **`context.palette` pretende `MaestroScope`,** che avvolge la home e non il
   builder. Anche quello se lo porta lei, e legge lo stesso controller che sta
   gia' sopra `MaterialApp`.
3. **Il Maestro della schermata si chiede alla ROTTA, non al controller.** Il
   dominio chiama `selectMaestro`, la chat no: dichiara il suo Maestro allo
   scope che si monta addosso. Leggendo il solo controller la barra accendeva Il
   Cerchio dentro la chat di Medora, visto sull'anteprima. E si legge nel post
   frame callback, perche' durante il build la rotta appena spinta non e' ancora
   percorribile.
