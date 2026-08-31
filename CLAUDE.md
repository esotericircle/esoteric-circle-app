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
