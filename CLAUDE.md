# Esoteric Circle, istruzioni per l'agente di sviluppo

Questo file e' letto automaticamente da Claude Code all'apertura del repository. Definisce come si lavora su questo progetto. La fonte di verita' completa sono i quattro briefing in `docs/`. In caso di dubbio, i briefing prevalgono su questo riassunto e non vanno mai condensati ne modificati senza conferma esplicita di Mauro.

## Protocollo Verita' e Memoria, si applica sempre, prima di tutto

Questa e' la regola che viene prima di ogni altra, per Claude Code e per l'Architetto in Cowork. Serve a chiudere per sempre il problema delle dimenticanze e delle affermazioni a memoria.

1. All'apertura, leggi `docs/STATO_VIVO.md`. E' lo stato vivo del progetto, la fonte mutabile canonica, e la fonte sovrana unica dello stato: la copia MEMORIA_E_STATO nel Project di Mauro e' solo uno specchio, e in caso di conflitto fra le due vince sempre STATO_VIVO. Le due copie vanno tenute allineate. Sopra STATO_VIVO c'e' solo la realta' del codice.
2. Prima di affermare cosa e' fatto, cosa manca, cosa esiste o quanti sono, VERIFICA sul filesystem e sul repo. Apri il file, conta la cartella, guarda il branch. Non rispondere mai a memoria ne a stima. Quando dai un dato, sappi da dove viene.
3. Distingui sempre tre stati per un asset o una funzione: prodotto, agganciato al codice, verificato a video. Non confonderli.
4. Se un lavoro sembra perso, cercalo sugli altri branch prima di dire che non esiste o di reimplementarlo.
5. Al termine di un task, aggiorna `docs/STATO_VIVO.md` integrando la novita' nella sezione giusta, mai come addendum, senza condensare il resto.
6. Per i controlli di stato pesanti esiste l'agente `custode-memoria` in `.claude/agents/`. Invocalo all'inizio per farti dare lo stato reale verificato, e alla fine per far aggiornare STATO_VIVO. Il suo unico compito e' tenere vera la memoria.

## Protocollo delle guardie, si applica a ogni ordine

Ordine CM voci 04, 05, 06 e 07, 1 settembre 2026. Nasce da un numero: prima
dell'ordine CL, **su duecentoquarantadue guardie soltanto nove erano mai state
viste rosse**, il tre virgola sette per cento. Tutte le altre erano verdi, e
di nessuna si sapeva se quel verde volesse dire qualcosa.

### Regola A, una guardia nasce rossa

**Nessuna guardia nuova si scrive senza averla vista rossa.** La prova del
rosso non e' un passo successivo da fare quando avanza tempo: e' parte dello
scrivere la guardia, come compilare fa parte dello scrivere il codice. Si
introduce a mano il difetto che la guardia deve prendere, si verifica **col
grep** che il difetto sia davvero entrato nel file, e solo dopo si legge
l'esito. Chi legge l'esito senza aver verificato l'innesto non sta misurando
la guardia, sta misurando un errore suo.

Quando il rosso non scatta, **si cambia la grandezza misurata, mai la
soglia**. Abbassare la soglia finche' la prova cade e' il modo piu' rapido di
costruire una guardia che non serve a niente.

Una guardia che gira su un insieme scoperto a esecuzione **dichiara il suo
cardinale minimo**, cioe' quante cose si aspetta di trovare, altrimenti su un
insieme vuoto e' verde senza aver guardato niente. Le porte comuni stanno in
`test/sorgenti_di_lib.dart`, il cardinale in `test/cardinale_minimo.dart`.

### Regola B, chi tocca una zona la prova rossa prima

**Chi lavora su una zona gia' coperta da una guardia la vede rossa PRIMA di
metterci mano**, e aggiorna la data nel registro `docs/guardie.md`. Serve a
sapere se la rete che sta per proteggere il lavoro e' viva o e' un ricordo.
Costa un minuto e vale un ordine intero: e' esattamente cosi' che nell'ordine
CM la guardia che sorveglia le altre e' stata colta mentre si degradava,
**dentro lo stesso lavoro che la stava degradando**, invece di tre ordini
dopo.

Se la guardia non diventa rossa, quella guardia non copre piu' la zona, e la
prima cosa da riparare e' lei, non il lavoro che si era venuti a fare.

### Regola C, ogni difetto ha un padre

**Ogni difetto nominato in un rapporto e' attribuito alla voce che l'ha
causato**, con il suo numero d'ordine e di voce. Quando non si riesce a
risalire, si scrive **PROVENIENZA IGNOTA** per esteso, e quella dicitura e'
essa stessa un'informazione: dice che il difetto e' entrato senza lasciare
traccia, che e' la cosa piu' preoccupante che possa dirsene.

Un difetto senza padre torna. Un elenco di difetti senza padri non insegna
niente a chi lo legge, e trasforma il rapporto in un lamento.

## Cosa stai costruendo

Esoteric Circle, app nativa Flutter con un solo codebase per iOS e Android, primo ecosistema esoterico completo (astrologia, cartomanzia, chakra, rituali, rune, Cabala) guidato da tre Maestri AI con memoria persistente. Non esiste una demo separata: si sviluppa direttamente l'app definitiva con il pattern del feature flagging. Le funzioni non ancora pronte restano visibili ma in grigio con badge Coming soon. Lo stato dell'app a un certo punto dello sviluppo (checkpoint C6) e' cio' che si presenta a Google, ed e' gia' il codice della nativa finale.

## Regola d'oro dello stack

Claude costruisce l'app, Gemini la fa girare. Tutta l'AI a runtime (oracoli, sinastria, memory, risposte dei Maestri) usa Vertex AI e Gemini, MAI le API Anthropic, per non bruciare crediti inesistenti. Resta uno strato di astrazione AIProvider che consente di cambiare provider senza riscrivere il codice.

## Modello operativo in Fase C

- Sviluppo alla massima autonomia, debug incluso. Non chiedere micro-conferme a ogni passo: progetta, scrivi, testa, correggi, itera, riporta il risultato.
- Fermati solo ai sei checkpoint (C1..C6) per la revisione visiva di Mauro sul simulatore o su device.
- Lo step by step si usa solo per le operazioni manuali di Mauro (account, credenziali, pannelli web). Mauro non conosce Python ne Redis: se servono, guidalo presupponendo zero conoscenza pregressa.

## Regole non negoziabili

- **UN RAMO SOLO.** Il lavoro si spinge sul solo ramo `claude/esoteric-circle-master-order-e798aj`, e nessun altro ramo si crea senza un ordine che lo dica per nome. Il lavoro dell'ordine CG e' finito in parte su un ramo laterale che il fondatore non aveva chiesto, e chi avesse aperto il canonico non avrebbe trovato ne' la rinomina in card ne' la build: due rami che dicono cose diverse sullo stesso ordine sono due verita'. Rimediato con l'ordine CH del 31 agosto 2026.
- Non usare mai il trattino lungo. Usa formulazioni alternative.
- Rispondi e commenta sempre in italiano.
- Ogni funzione esoterica poggia su tradizioni reali e documentate, con disclaimer. Il disclaimer si mostra una sola volta a onboarding e registrazione, mai su ogni card o responso.
- Ogni esperienza basata su sensori (giroscopio, microfono, fotocamera, accelerometro) ha sempre un fallback a gesto tattile.
- Livello visivo prima del testo, in ogni responso significativo (anatomia del responso a quattro strati: colpo d'occhio visivo, sintesi in una frase, testo narrato, azione).
- Non condensare, riassumere o rimuovere contenuti dai documenti. Integra le novita' nelle sezioni corrette, mai come addendum.
- Segreti mai nel codice ne su Git. In locale stanno in `.secrets/` (gia' escluso da .gitignore), in produzione in Secret Manager. Le chiavi API non vanno mai in chiaro nel codice.

## Stack e ambiente

- Frontend: Flutter stable, design system Materico 2.5D (profondita' e ombre senza 3D pieno), 60fps con Quality Tier dinamico.
- Runtime AI: Vertex AI e Gemini (Gemini 3 Pro per i Maestri, Gemini 3 Flash per i task ripetitivi). Voce: Gemini-TTS per il live, Chirp 3 HD per il batch. I nomi esatti dei modelli vanno riverificati allo sviluppo.
- Backend: tre servizi Cloud Run (api-main, ai-gateway, batch-worker), Firestore (real-time, gamification), Cloud SQL Postgres con pgvector (memory layer a tre strati), Redis (cache, rate limiting), Cloud Storage e CDN.
- Auth: Firebase Auth con Google, Apple, email. Telefono mai nel form, raccolto dopo con scambio di valore. Registrazione progressiva a basso attrito.
- Progetto Google: esoteric-circle, organizzazione cloud-org, regione europe-west1. Firebase piano Blaze sul billing trial (300 USD, scadenza circa 23/09/2026). Firestore edizione Standard, location europe-west1. Remote Config con parametro demo_mode gia' pubblicato.
- Dati astrologici: FreeAstroAPI basata su effemeridi svizzere. I contenuti astrologici NON sono generati da AI, l'AI interpreta e personalizza soltanto.
- AI Gateway: circa il 70% delle richieste non tocca l'LLM (cache, database, calcolo deterministico). Sistema ibrido a scheletri, context caching, pre-generazione batch notturna.

## Feature flag

Governati da Firebase Remote Config uniti al controllo dell'entitlement del tier. Ogni funzione e' in uno di tre stati: Attiva, Coming soon (grigio o semitrasparenza con badge, tap mostra anticipo elegante), Premium bloccata (lucchetto e invito all'upgrade). Mai un vicolo cieco.

## Modello giusto per il task giusto

Haiku per il banale e ripetitivo (boilerplate, refactor semplici, formattazione). Sonnet per i task standard (feature, test). Opus per architettura e problemi complessi.

## Asset

- `brand_assets/avatars/` i tre Maestri: Medora (blu e oro, astrologia e cartomanzia), Aura (verde smeraldo e oro, chakra ed energia), Caligo (rosso e oro, rune e magia). PNG con canale alpha.
- `brand_assets/intro/` intro cinematografica pre-renderizzata (Intro-Test-1.mp4).
- Famiglie grafiche di brand su bucket Google (master privato piu' CDN pubblico, europe-west1): 78 tarocchi piu' dorso, 72 Angeli piu' dorso, 24 rune, 12 cristalli, 50 ritratti VIP, 12 animali guida. Stile Total Metal multicolore inciso, cornice madre oro e blu Medora. Numeri e nomi delle carte sono testo sovrapposto a runtime in Flutter (i18n), gli artwork hanno i cartigli vuoti: un solo set vale per tutte le lingue.

## Checkpoint corrente

C1. Vedi lo scope dettagliato e la mappa completa dei checkpoint in `docs/HANDOFF_FASE_C.md`.

## Dove guardare

- `docs/STATO_VIVO.md`: lo stato vivo del progetto, da leggere per primo e aggiornare dopo ogni task.
- `docs/HANDOFF_FASE_C.md`: dossier operativo di handoff (repo, feature flag, manifest asset, scope C1, stato Fasi A e B).
- `docs/` i quattro briefing definitivi, fonte di verita' assoluta.
