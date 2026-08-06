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
