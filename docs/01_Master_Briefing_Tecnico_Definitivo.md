MASTER BRIEFING TECNICO DEFINITIVO

**Esoteric Circle**

*Ecosistema Esoterico Immersivo Cross-Platform · App nativa Flutter*

Aggiornamento del Master Tecnico. Allineato a: Medora, Aura, Caligo; valuta Eos; famiglia Gemini 3.x su Vertex AI (Gemini 3 Pro per i Maestri, Gemini 3 Flash per i task ripetitivi, con strato di astrazione per salire alla versione stabile piu recente); voce Google (Gemini-TTS e Chirp 3 HD); generazione immagini su Vertex AI; deep link nativi; sistema ibrido potenziato. Giugno 2026. Nota: i nomi esatti delle versioni dei modelli vanno riverificati al momento dello sviluppo perche la cadenza di rilascio e rapida; lo strato di astrazione AIProvider consente l aggiornamento senza riscrivere il codice.

# Nota di versione: cosa cambia rispetto al V3

Questo documento è la versione definitiva del Master Tecnico. Mantiene l impianto solido del V3 ma aggiorna le scelte tecnologiche superate nei due mesi successivi alla stesura, e allinea tutto alle decisioni di progetto definitive. Le modifiche principali sono le seguenti.

| **Ambito** | **V3 (marzo 2026)** | **Definitivo (giugno 2026)** |
| --- | --- | --- |
| Modelli AI | Gemini 2.5 Pro e Flash | Famiglia Gemini 3.x su Vertex AI: Gemini 3 Pro per i Maestri, Gemini 3 Flash per i task ripetitivi, con strato di astrazione per salire alla versione stabile piu recente. Nomi esatti da confermare allo sviluppo. |
| Voce | ElevenLabs per il live, Google TTS per il batch | Interamente Google: Gemini-TTS per le risposte vive dei Maestri (tag emotivi), Chirp 3 HD per i contenuti batch |
| Generazione immagini | Imagen 3 | Generazione immagini su Vertex AI (famiglia Gemini Image / Imagen su Vertex) con immagine pilota di riferimento per la coerenza dell intero set; Leonardo AI in riserva. NEXOS non usato come via primaria per gli asset di brand coerenti. |
| Deep link | Firebase Dynamic Links | Deep link nativi (App Links Android, Universal Links iOS) sul dominio, perché i Dynamic Links sono stati dismessi |
| Nomi Maestri | Lyra, Arabella, Cagliostro | Medora, Aura, Caligo |
| Valuta | Stelle | Eos (moltiplicatore x10) |
| Animazioni | Rive completo da creare | Automazione integrale: tutte le animazioni (avatar in loop, effetto finto-3D, nebbia, Albero che si illumina, Sigilli) e tutti gli asset prodotti dall automazione (Rive, Lottie, shader, generazione immagini), senza lavorazione manuale iniziale. Unica eccezione l intro in After Effects dell utente. Rifinitura manuale facoltativa e posticipata. |
| Ottimizzazione AI | Sistema ibrido a scheletri | Sistema ibrido potenziato con context caching Vertex AI e pre-generazione batch estesa |

# 1. Visione architetturale e obiettivi strategici

Esoteric Circle è un ecosistema esoterico immersivo cross-platform che integra calcoli astronomici di precisione, motori di inferenza AI multimodali e una UI/UX di lusso definita Materico 2.5D. Mira a diventare leader globale del segmento esoterico digitale con un esperienza mistica, gamificata e socialmente connessa.

Decisione architetturale fondante (Strada C): l app è NATIVA, sviluppata in Flutter con un unico codebase per iOS e Android. Non esiste una demo separata: si sviluppa direttamente l app definitiva con feature flag, mostrando in grigio o semitrasparenza le funzioni MVP non ancora pronte. Lo sviluppo avviene con la Suite Claude, il runtime AI gira su Gemini e Vertex AI per sfruttare i crediti Google.

Metriche tecniche di successo:

| **KPI** | **Target** | **Motivazione** |
| --- | --- | --- |
| Frame Rate | 60fps costanti | UX premium fluida; i device deboli degradano al Quality Tier basso |
| Cold Start | < 1 secondo | Primo tap istantaneo via cache locale e preload |
| Risposta AI | < 3 secondi percepiti | Streaming SSE: primo token in 200-400ms |
| Dimensione App | < 80 MB | Limiti store; texture procedurali e compressione |
| Consumo batteria | < 15% per ora | Sessioni lunghe; AR e giroscopio degradano con Reduce Motion |
| Latenza API | < 500ms mediana | Precompute e cache; il Gateway evita l LLM per il 70% delle richieste |

# 2. Stack tecnologico e infrastruttura (Google Cloud Ecosystem)

Lo stack è Google-first per sfruttare i crediti del programma Google for Startups (stimati decine di migliaia di euro su 24 mesi), semplificare la compliance GDPR con data center europei e avere il path più diretto verso lo scale-up. Regola d oro: Claude costruisce l app, Gemini la fa girare.

| **Componente** | **Tecnologia** | **Costo in partnership** | **Motivazione** |
| --- | --- | --- | --- |
| Frontend mobile | Flutter 3.2x+ | Gratuito | Rendering nativo 60fps, AR nativa, shader, Rive e Lottie |
| Autenticazione | Firebase Auth + Firestore | Gratuito | OAuth Google/Apple, email, telefono, sync real-time |
| Database relazionale | Cloud SQL PostgreSQL + PostGIS | Gratuito | Carta natale, sinastria, dating geografico, pgvector per memoria |
| Database NoSQL | Firestore | Gratuito | Presence real-time, push, streak gamification |
| Cache distribuita | Memorystore Redis | Gratuito | Oroscopi cachati, sessioni, rate limiting, precompute oracoli |
| Compute serverless | Cloud Run | Gratuito | API principale, AI Gateway, batch job, scaling 0-1000 istanze |
| AI Maestri qualità alta | Gemini 3 Pro (ultima versione stabile su Vertex) | Gratuito | Ragionamento superiore, interpretazioni profonde, context ampio |
| AI task ripetitivi | Gemini 3 Flash (ultima versione stabile su Vertex) | Gratuito | Veloce ed economico: memoria, batch oroscopi, sintesi |
| Embedding semantica | Vertex AI text-embedding | Gratuito | Ricerca semantica storia conversazioni con pgvector |
| Immagini e asset | Generazione immagini Vertex AI (Gemini Image / Imagen su Vertex) | Gratuito | Carte, 72 Angeli, rune, cristalli, avatar, sfondi manga Destino |
| Voce live Maestri | Gemini-TTS (Vertex AI) | Gratuito (crediti) | Tag emotivi per dare tono a Medora, Aura, Caligo |
| Voce batch | Chirp 3 HD (Vertex AI) | Gratuito (crediti) | Oroscopi, affermazioni, meditazioni pre-generate |
| Archiviazione media | Cloud Storage + CDN | Gratuito | Artwork, audio, caching aggressivo |
| Push notifications | Firebase Cloud Messaging | Gratuito | Elementi quotidiani, alert transiti, match |
| Hosting web e deep link | Firebase Hosting + App/Universal Links | Gratuito | Landing, card condivisibili, viral loop |
| Pubblicità (solo Free) | Google AdMob | Ricavo | Banner inferiore e reward video |

Unica eccezione non Google rilevante: l API astrologica basata su effemeridi svizzere (vedi sezione 18), costo esterno contenuto. Resta uno strato di astrazione AIProvider che consente, in caso di necessità futura, di affiancare un provider AI alternativo senza riscrivere il codice.

## 2.1 Workflow di sviluppo con la Suite Claude (sezione nuova)

Lo sviluppo separa nettamente due ambienti per minimizzare i costi.

Architettura e pianificazione: Claude Opus (ultima versione disponibile, attualmente la serie Opus 4.x) su NEXOS, senza limiti di crediti. Qui si definiscono architettura, briefing, decisioni e revisioni. Costo zero per l utente.

Sviluppo operativo: account Claude dedicato con Code, Cowork, Managed Agents, Design. Qui si scrive ed esegue il codice.

Regola di ottimizzazione crediti: il modello giusto per il task giusto, usando sempre le versioni piu recenti della famiglia Claude. Haiku (ultima versione) per task semplici e ripetitivi (boilerplate, refactor banali, formattazione), Sonnet (ultima versione) per task intermedi (feature standard, test), Opus (ultima versione, via NEXOS) solo per architettura e problemi complessi. Cowork gestisce i task autonomi e schedulati; i Managed Agents sono agenti specializzati persistenti. I nomi esatti delle versioni vanno confermati al momento dello sviluppo.

Agenti specializzati da creare (uno per dominio, contesti puliti, lavoro parallelizzabile): Agente UI Flutter (schermate, widget, design system 2.5D), Agente Backend Google (Cloud Run, Firestore, Cloud SQL, API), Agente AI/Gemini (Gateway, prompt dei Maestri, sistema ibrido), Agente Debug (test e correzioni autonome). Le skill open source mature per Flutter e per il workflow agentico vanno installate da GitHub invece di reinventarle, dopo verifica di sicurezza.

# 3. Componenti core e motivazioni tecniche

Tre servizi Cloud Run compongono il backend: api-main (API REST principale in FastAPI, routing e validazione), ai-gateway (routing intelligente AI, caching, rate limiting), batch-worker (job schedulati via Cloud Scheduler: oroscopi notturni, asset Imagen, sintesi memoria, contenuti quotidiani pre-generati). In partnership il costo è zero; post-partnership resta contenuto perché si paga solo il compute effettivo.

Il viral loop nativo: quando un utente condivide una card (sinastria, Soffio del Destino, Runa del Tramonto, traguardo), il deep link nativo apre l app se installata, altrimenti porta allo store con contesto pre-compilato. Sostituisce i dismessi Firebase Dynamic Links con App Links su Android e Universal Links su iOS, ospitati sul dominio, a costo zero.

# 4. AI Gateway Layer: routing intelligente delle richieste

L AI Gateway è un microservizio leggero che decide, per ogni richiesta, se serve l LLM oppure se può essere servita da cache o database. Impatto: circa il 70% delle interazioni non tocca mai Gemini, latenza media sotto il secondo, costi AI ridotti di oltre il 60% rispetto a un architettura naive. Allineato ai nuovi modelli e alle nuove feature (Runa del Tramonto, Angeli, archetipi).

| **Tipo richiesta** | **Passa per LLM?** | **Fonte dati** | **Latenza target** |
| --- | --- | --- | --- |
| Oroscopo giornaliero/settimanale | No | Cache Redis + API astrologica | < 500ms |
| Carta natale (calcolo) | No | Effemeridi svizzere + DB | < 300ms |
| Significato base oracoli | No | Database statico curato | < 100ms |
| Oracolo del Giorno / Soffio / Runa del Tramonto | No (pre-generati) | Batch notturno + cache | < 100ms |
| Interpretazione personalizzata oracolo | Sì (parziale) | Significato base + contesto utente | 1-2s |
| Domanda aperta a un Maestro | Sì (full) | Query diretta a Gemini 3 Pro | 2-4s |
| Sinastria punteggio | No | Algoritmo matematico aspetti | < 200ms |
| Sinastria narrativa | Sì (parziale) | Punteggio precalcolato + Gemini narra | 1-2s |
| I-Ching / rune (lancio) | No | Calcolo deterministico + DB | < 200ms |
| Mood check | No | Salvataggio locale + DB | < 100ms |

# Da 5 a 11. Design System Materico 2.5D e motion design

Il design system Materico 2.5D resta integralmente valido e viene confermato: profondità e ombre senza rendering 3D pieno, per immersione e leggerezza. Comprende il Design Token System a tre layer (primitivi, semantici, di componente), le palette tematiche dei Maestri (viola galattico per Medora, verde smeraldo per Aura, rosso sangue e oro per Caligo), il sistema tipografico, il glassmorphism ottimizzato per le card, gli shader procedurali per texture e sfondi dinamici, e la parallasse con degradazione graceful sui device deboli. Questi elementi sono indipendenti dai modelli AI e non richiedono aggiornamenti. Su questa base, lo stile visivo degli asset di brand collezionabili e definito in Fase B come Total Metal multicolore: scena incisa e cesellata in rilievo bas-relief come su una lastra di metallo, con i colori naturali di ogni elemento resi come patine e smalti metallici colorati (non monocromo), entro il design system 2.5D; la cornice delle carte e fissa e identica per tutto il mazzo, in oro e blu Medora, e nel cartiglio cambiano solo il nome della carta e il numero romano. I tre sfondi immersivi dei Maestri fanno eccezione: sono in stile pittorico atmosferico, full-bleed e senza cornice, pensati per stare dietro l interfaccia con la parallasse multistrato.

# Da 12 a 13. Onboarding Il Risveglio e Home Il Santuario

Onboarding Il Risveglio in dieci step: raccoglie data (obbligatoria), ora (opzionale con spiegazione) e luogo di nascita, introduce i tre Maestri, calcola e mostra la carta natale con animazione astrolabio. Integra il primo momento wow del modulo spirituale (Angelo Custode e Test Archetipo) e il primo accenno al Rito dell Alba. La registrazione è progressiva: utente anonimo all inizio, account richiesto solo quando serve, telefono mai nel form ma raccolto dopo con scambio di valore.

Home Il Santuario: punto di ritorno naturale. Background immersivo per Maestro, le card degli elementi quotidiani (Oracolo del Giorno, Soffio del Destino, Rito dell Alba, Runa del Tramonto), oroscopo del giorno, mood tracker a un tap, bottom bar con i tre Maestri. Cambio di Maestro che trigga la transizione globale del tema colori.

# 14. I tre Maestri: personalità, voce e atmosfera sonora

Aggiornato ai nomi definitivi e alla nuova voce Google. Ogni Maestro ha voce generata con Gemini-TTS, sfruttando i tag emotivi per rendere il tono distintivo.

| **Maestro** | **Dominio** | **Tono e voce (Gemini-TTS)** | **Avatar e atmosfera** |
| --- | --- | --- | --- |
| Medora | Astrologia, cartomanzia, destino, Oracolo del Giorno | Elegante, melodico, pause drammatiche. Soprano/contralto femminile | Stella a otto punte, viola galattico; arpa celeste, silenzio deliberato |
| Aura | Chakra, energia, benessere, psiche/Jung, Soffio del Destino | Caldo, accogliente, respiri naturali. Mezzo-soprano femminile | Fiore di loto, verde smeraldo; campane tibetane, acqua, vento |
| Caligo | Rune, rituali, simbologia, magia, Cabala/Angeli, Runa del Tramonto | Profondo, solenne, enfasi drammatica. Basso/baritono maschile | Fiamma stilizzata, rosso e oro; tamburi bassi, crepitio di fiamme |

## 14.1 Animazione degli avatar dei Maestri (effetto wow, sezione nuova)

Gli avatar animati dei tre Maestri sono un effetto wow e vanno realizzati. Mauro fornisce le immagini base già pronte; il compito è animarle, non disegnarle. La pipeline rapida prevede di partire dall immagine statica esistente e generare gli stati di animazione (idle con respiro, speaking durante il parlato sincronizzato con il TTS, greeting di benvenuto) usando gli strumenti più veloci disponibili invece della creazione manuale frame per frame. L output finale è un file animato a stati integrabile in Flutter (Rive per gli avatar a stati, o sequenza ottimizzata), con fallback statico sui device deboli. Le altre animazioni dell app (flip carte, lancio rune, particelle, transizioni) restano gestite da Rive e Lottie con asset pronti o adattati, e dagli shader procedurali per gli sfondi.

# Da 15 a 17. Animazioni Rive, micro-interazioni Lottie, transizioni

Rive gestisce le animazioni a stati (astrolabio, flip delle carte, lancio rune, pendolo, orb dei Maestri, avatar). Lottie gestisce le micro-interazioni leggere (glow, feedback tattili, celebrazioni streak). Sette tipologie di transizione governano la navigazione, con regola di navigazione immersiva: durante i flussi (lettura, meditazione, chat con un Maestro, tappa di Destino) la UI esterna scompare per non distrarre. Approccio accelerato: per demo e MVP si privilegiano asset Lottie pronti e shader, riservando il tempo di rifinitura Rive agli avatar dei Maestri. Decisione di processo aggiornata: per guadagnare tempo, tutte le animazioni e gli asset grafici sono affidati all automazione (Rive, Lottie, shader e generazione AI), senza lavorazione manuale iniziale. Unica eccezione: l intro cinematografica e realizzata a mano dall utente in After Effects e integrata come video pre-renderizzato. La rifinitura manuale degli altri asset e delle animazioni resta facoltativa e successiva, da valutare a posteriori sui soli momenti wow se il risultato automatico non soddisfa.

# 18. Motore astrologico e API esterna (effemeridi svizzere)

Principio fondante confermato: i contenuti astrologici NON sono generati dall AI. Provengono da un API professionale basata sulle effemeridi svizzere (Swiss Ephemeris), con precisione astronomica. L AI interviene solo per personalizzare e interpretare su richiesta, mai per generare i dati base.

Tre ragioni: precisione (nessun LLM calcola le posizioni planetarie), coerenza (gli stessi dati natali devono restare identici nel tempo), credibilità (gli utenti esperti verificano i transiti). Le API Swiss Ephemeris con transiti in tempo reale partono da circa 29-39 euro al mese: è una delle pochissime spese fisse esterne, non coperta dai crediti Google. Va valutato il self-hosting della libreria (licenza una tantum) per azzerare il costo ricorrente quando il volume cresce.

Flusso a due binari. Binario batch: ogni notte un Cloud Scheduler recupera oroscopi, transiti e calendario lunare e li salva in cache. Binario on-demand: carta natale calcolata una volta alla registrazione e cachata in modo permanente; sinastria calcolata su richiesta e cachata per coppia; transiti personalizzati cachati 24 ore.

# 19. Oracoli autonomi

Cinque oracoli con motore proprio, assegnati ai Maestri secondo i domini riequilibrati. Tarocchi (Medora): 78 carte, più stese, schema dati completo, algoritmo di estrazione. Rune e I-Ching e pendolo e lettura fondi di caffè (Caligo): calcolo deterministico con interpretazione. Sfera di Cristallo e Oracolo dei Cristalli (Aura): visioni procedurali. Ogni oracolo ha animazione Rive dedicata e interpretazione nel tono del Maestro.

# Da 20 a 22. Cosmic Hunt AR, Radar Anima Gemella, Destino narrativo

Queste feature restano nelle fasi successive come da Briefing Progetto. Cosmic Hunt AR (motore di realtà aumentata geolocalizzata con nodi energetici), Radar Anima Gemella (dating con algoritmo di sinastria a punteggio 0-100 basato sugli aspetti, distanza, preferenze e fattori karmici), Destino narrativo (percorso in sette tappe verso l anima gemella con artwork generato da Imagen 4). Le specifiche tecniche del V3 restano valide, con generazione immagini aggiornata a Imagen 4 e nomi dei Maestri allineati.

# 23. Memory Layer compresso (3 strati + pgvector)

La memoria persistente dei Maestri, esclusiva dell abbonamento, usa tre strati: profilo cristallizzato (dati natali, archetipo, preferenze), riassunti compressi delle sessioni passate, messaggi verbatim con embedding. La ricerca semantica usa pgvector su Cloud SQL con indice ivfflat. Gli embedding sono gratuiti con la partnership. Conformità GDPR: retention configurabile, job notturno di pulizia, diritto all oblio con cancellazione selettiva.

Architettura della memoria: la memoria e globale e unica, condivisa da tutti e tre i Maestri con tre lenti di lettura, senza piani contestuali ne confidenze riservate al singolo Maestro, per coerenza con Lo Specchio dell'Anima. La profondita d'uso scala col tier (Free breve, Tier 1 medio, Tier 2 pattern e cicli, Tier 3 sintesi evolutiva) ma i ricordi non si cancellano mai: la scrittura e sempre attiva per tutti dal primo secondo, cambia solo la finestra di lettura per tier; salire di tier sblocca memoria gia presente. Regola anti-invenzione come requisito architetturale: il sistema recupera da pgvector solo i ricordi realmente presenti e passa al Maestro esclusivamente quei fatti, il prompt vincola la risposta a usarli e a dichiarare di non sapere se assenti. Diritto all'oblio in MVP con cancellazione selettiva, retention configurabile e job notturno di pulizia. Governance costi: la memoria profonda dei tier alti consuma piu contesto e piu token; il context caching di Vertex AI riduce ma non azzera il costo, quindi a scala resta una voce da monitorare attivamente, coerente col principio che i tier alti pagano di piu e quindi possono consumare di piu.

# 24. Sistema ibrido oracoli potenziato (riduzione costi e tempi AI)

Confermato e potenziato il principio degli scheletri con placeholder. Ogni oracolo ha un significato base universale in database statico curato; l AI non genera da zero ma riceve lo scheletro e riempie i placeholder personalizzando sul profilo utente. Risultato documentato: meno 50% di token, meno 50% di costo, meno 60% di latenza percepita.

Esempio di template per Gemini Flash: riceve profilo (segno solare, luna, ascendente), domanda, contesto, mood, il significato base dell oracolo e i transiti del giorno, e riscrive in massimo cento parole nel tono del Maestro. Niente generazione da zero, solo personalizzazione.

Tre potenziamenti rispetto al V3:

Context caching di Vertex AI: mette in cache la parte ripetuta dei prompt (system prompt dei Maestri, significati base), riducendo i token in input fino al 75-90%. Si somma al risparmio ibrido.

Pre-generazione batch estesa: oltre alle combinazioni frequenti di oracoli, anche Oracolo del Giorno, Soffio del Destino e Runa del Tramonto vengono generati una volta a notte con Gemini 3 Flash e serviti dalla cache, portando il loro costo per utente verso zero.

Caching a due livelli delle risposte ibride: copia esatta in Redis (24h) e template pre-generati in database (combinazioni segno per categoria di domanda).

Divisione applicata agli scheletri: gli scheletri con placeholder restano per i contenuti seriali e prevedibili, dove danno il massimo risparmio senza costo di sviluppo aggiuntivo, ovvero oroscopi dei dodici segni, significati base degli oracoli, elementi quotidiani e tutto cio che e pre-generabile in batch notturno. Per il dialogo libero Chiedi ai Maestri, dove ogni domanda e diversa e lo scheletro avrebbe poco senso, si lascia liberta alla AI, controllata dal limite del numero di parole e dai limiti giornalieri per tier. Questo accelera lo sviluppo e mantiene il costo prevedibile, perche il context caching e i limiti per tier governano la spesa al posto dello scheletro.

Profondita della risposta: la lunghezza richiesta dall utente (Breve, Media, Approfondita, dal Tier 1 in su) e un parametro che modula direttamente il numero massimo di token in output, quindi e anche una leva tecnica di controllo del costo per richiesta, oltre che una scelta di esperienza.

# Da 25 a 29. Streaming SSE, caching 3 livelli, quality tier, feature flags, preloading

Streaming SSE per le risposte LLM: il primo token arriva in 200-400ms, riducendo la percezione di attesa. Caching a tre livelli (locale sul device, CDN, edge Redis). Quality Tier dinamico a runtime: i device deboli degradano automaticamente effetti e animazioni per mantenere i 60fps. Feature flags via Firebase Remote Config: governano le funzioni MVP mostrate in grigio o semitrasparenza, ed è il meccanismo tecnico che realizza la demo presentabile sulla stessa base di codice della nativa. Predictive preloading degli asset in base al comportamento.

# 30. Voce: Gemini-TTS e Chirp 3 HD (sostituisce ElevenLabs)

La voce passa interamente a Google, eliminando ElevenLabs e il suo costo variabile. Strategia a due livelli.

Livello batch (Chirp 3 HD): contenuti statici uguali per tutti, generati di notte e serviti da CDN a latenza quasi nulla. Oroscopi, affermazioni, significati base degli oracoli, meditazioni, soundscape. Coperto dai crediti Google.

Livello live (Gemini-TTS): contenuti dinamici e personalizzati, generati in tempo reale. Risposte vocali dei tre Maestri, interpretazioni personalizzate, letture di sinastria. I tag emotivi di Gemini-TTS permettono di dare a Medora il tono elegante, ad Aura il calore, a Caligo la solennità. Coperto dai crediti Google.

Vantaggio rispetto al V3: il costo voce, che con ElevenLabs sarebbe stato variabile e potenzialmente alto a scala, viene azzerato durante la partnership, mantenendo qualità emotiva elevata.

# 31. Gestione latenza e ottimizzazioni real-time

Combinazione di streaming SSE, caching a tre livelli, preloading predittivo e routing del Gateway. Le query astrologiche sono precompute o cachate; le richieste AI vere sono minoritarie e ottimizzate con context caching. Obiettivo: latenza API mediana sotto 500ms e risposta AI percepita sotto 3 secondi.

# 32. Microservizi e architettura backend

Tre servizi Cloud Run (api-main, ai-gateway, batch-worker) containerizzati, con scaling automatico. Cloud SQL PostgreSQL con PostGIS e pgvector per dati relazionali, geografici e memoria; Firestore per real-time e gamification; Redis per cache e rate limiting. Cloud Scheduler per i job notturni. Cloud Storage e CDN per i media.

# 33. Sicurezza, abuse prevention e rate limiting

Rate limiting per utente e per endpoint (coerente con i limiti per tier: domande e stese giornaliere). Controllo anti-abuso sul referral via device fingerprint. Validazione lato server di tutte le richieste. Consensi GDPR con opt-in esplicito separati per email e WhatsApp marketing. Per le funzioni dating delle fasi successive: verifica telefonica, moderazione dei contenuti, sistema di report e blocco.

# 34. Produzione asset accelerata (sezione nuova)

Per recuperare il ritardo, gli asset si producono con AI invece che a mano, salvo rifinitura successiva.

Carte (tarocchi), 72 Angeli, rune, cristalli: generazione in batch con il modello di generazione immagini di Vertex AI (famiglia Gemini Image, in particolare Nano Banana Pro cioe Gemini 3 Pro Image, su Vertex), usando un prompt-template fisso e una immagine pilota di riferimento che garantiscono stile uniforme su tutto il set. Quello che a mano richiederebbe giorni si genera in minuti. Coperto dai crediti Google. In alternativa Leonardo AI con Style Reference o Custom Model quando serve una coerenza di stile superiore. Stile del set definito in Fase B: Total Metal multicolore inciso in rilievo, con carta pilota master Il Sole e cornice madre fissa oro e blu Medora; oltre alla pilota master si usa una pilota di riferimento per ogni famiglia (una carta, un Angelo, una runa, un cristallo, un ritratto VIP) per mantenere la coerenza dentro ciascuna classe. Le rune non sono carte ma pietre a contorni irregolari con solo il glifo runico inciso d oro; nome latinizzato e linea di delimitazione a runtime in Flutter, non incisi (un set di 24 pietre per tutte le lingue). Lancio con scuotimento, rune che cadono e si ordinano, nome e lettura sotto, scheda al tap. I 72 Angeli sono un set unico in palette Medora. Flusso operativo: esplorazione e ricerca dello stile su NEXOS e Nano Banana 2 (gratis, iterazione rapida), poi consolidamento della pilota e generazione in batch su Vertex AI con immagine di riferimento e upscaling al formato master.

Animali Guida: dodicesima famiglia di asset di brand, 12 animali (Lupo, Orso, Aquila, Gufo, Cervo, Serpente, Lince, Corvo, Cavallo, Volpe, Tartaruga, Falco) in stile metallico multicolore, posa di profilo con testa verso l osservatore, palette Caligo rosso e oro, oggetto isolato senza cornice, PNG con alpha per l animazione della nebbia che si dirada. Generati con Nano Banana Pro su Vertex, un prompt di scena per animale; mapping deterministico coi 12 archetipi junghiani (Lupo Esploratore, Orso Sovrano-Protettore, Aquila Visionario-Mago, Gufo Saggio, Cervo Innocente, Serpente Trasformatore, Lince Custode, Corvo Messaggero-Fuorilegge, Cavallo Eroe, Volpe Burlone, Tartaruga Radicamento, Falco Condottiero), fisso per la persona.

Aggiornamenti asset finali. Cristalli: 12 pietre a colore naturale reale e abito nativo distinto, oggetto isolato PNG alpha, oro sul cristallo non a cornice, scintille e pulse a runtime. Ritratti VIP: cornice unica universale a finestra ad arco, glifo zodiacale e nome a runtime (cartigli vuoti), solo data di nascita, mai foto reali. Rune: solo glifo inciso, nome e linea a runtime. La Sfera della Fortuna e il premio giornaliero di dominio Aura: reward a scala sempre assegnato in Eos e sblocchi, un tentativo gratuito al giorno con reset, aggancio allo streak, senza meccaniche di gambling ne loot box (nessun premio in denaro reale, nessuna giocata acquistata con denaro).

Avatar dei Maestri: partendo dalle immagini base fornite da Mauro, si generano gli stati di animazione (idle, speaking, greeting) e si esporta un file animato a stati per Flutter.

Micro-interazioni ed effetti: librerie Lottie pronte e shader procedurali, integrabili in minuti.

Sfondi dinamici e artwork Destino: generazione immagini su Vertex AI in batch notturno (o Leonardo AI in riserva). Gli sfondi dei tre Maestri sono in stile pittorico atmosferico full-bleed senza cornice (cielo stellato con costellazioni dorate per Medora, stanza alchemica calda per Caligo, giardino energetico per Aura), verticali a schermo, con spazio scuro centrale e inferiore per l interfaccia e struttura a piu piani per la parallasse.

Voce: Chirp 3 HD per il batch, Gemini-TTS per il live.

In seguito Mauro potrà sostituire i singoli asset che desidera rifinire a mano con Photoshop, Illustrator e After Effects, senza impatto sull architettura.

# 35. Guida cronologica operativa (sezione nuova)

Questa è la sequenza che porta dallo stato attuale all avvio dello sviluppo autonomo. Principio: prima tutto il lavoro umano (account, credenziali, asset), poi lo sviluppo dell agente in massima autonomia con pause di controllo programmate e risultati visivi lungo il percorso. Qui la guida è sintetica; il dettaglio passo passo sarà nel Briefing Operativo MVP.

## Fase A — Lavoro umano: account e credenziali (step by step di Mauro)

In questa fase Mauro esegue operazioni manuali guidate. Lo sviluppo non è ancora iniziato.

| **#** | **Azione di Mauro** | **Esito atteso** |
| --- | --- | --- |
| 1 | Creare account Claude dedicato e attivare Code, Cowork, Design, Agents | Ambiente di sviluppo pronto |
| 2 | Creare account Google Cloud e attivare i crediti Google for Startups | Crediti infrastruttura attivi |
| 3 | Creare il progetto Google Cloud e abilitare le API (Vertex AI, Cloud Run, Cloud SQL, Firestore, Storage) | Servizi backend disponibili |
| 4 | Creare il progetto Firebase (Auth, Firestore, Storage, Remote Config, Analytics, Crashlytics, Cloud Messaging) | Auth e servizi mobile pronti |
| 5 | Creare account Apple Developer e Google Play Console | Pubblicazione store possibile |
| 6 | Registrare account API astrologica (Swiss Ephemeris) e ottenere la chiave | Dati astrologici disponibili |
| 7 | Creare repository GitHub condiviso e collegarlo a Claude Code | Codebase versionato e accessibile |
| 8 | Raccogliere e salvare tutte le credenziali e le API key in un luogo sicuro | Le credenziali pronte per l agente |

## Fase B — Lavoro umano e assistito: asset

Mauro fornisce le immagini base degli avatar dei Maestri (già pronte). L agente, su indicazione, genera in batch gli altri asset con Imagen 4 (carte, 72 Angeli, rune, cristalli, sfondi) e anima gli avatar. Pausa di controllo: Mauro rivede visivamente gli asset generati e approva o chiede rigenerazione, prima di procedere.

## Fase C — Sviluppo autonomo dell agente con pause di controllo

Da qui l agente lavora in massima autonomia, debug incluso, fermandosi solo nei checkpoint visivi. Sequenza consigliata:

| **Checkpoint** | **Cosa costruisce l agente** | **Cosa vede Mauro alla pausa** |
| --- | --- | --- |
| C1 | Scaffolding progetto Flutter, design system 2.5D, navigazione, feature flags | App che parte, home navigabile con funzioni grigie |
| C2 | Onboarding Il Risveglio + carta natale via API astrologica | Onboarding reale e carta natale calcolata |
| C3 | I tre Maestri con avatar animati, chat AI via Gemini 3, voce Gemini-TTS | Maestri che parlano e rispondono |
| C4 | Elementi quotidiani (4 card) + oracoli core con sistema ibrido | Esperienza quotidiana funzionante |
| C5 | Sinastria Celeb + Cosmic Journal a tre sentieri + economia Eos | Leva virale e gamification attive |
| C6 | Moduli MVP residui, feature flag per le funzioni Coming soon, rifinitura | MVP/demo presentabile a fondatori e Google |

A ogni checkpoint l agente mostra il risultato visivo (build eseguibile o registrazione), Mauro approva o segnala correzioni, e l agente prosegue. Tra un checkpoint e l altro lo sviluppo e il debug procedono senza pause.

# 36. Stima costi infrastruttura

Durante la partnership Google la quasi totalità dei servizi infrastrutturali e AI è coperta dai crediti, quindi tendente a zero. Le sole spese esterne ricorrenti sono: API astrologica (circa 29-39 euro al mese, eliminabile con self-hosting della libreria), account Apple Developer (annuale) e Google Play Console (una tantum). Post-partnership, grazie al sistema ibrido, al context caching e alla pre-generazione batch, il costo AI resta basso e prevedibile anche a scala.

# 37. Rischi tecnici e mitigazioni

| **Rischio** | **Mitigazione** |
| --- | --- |
| Esaurimento crediti Claude in sviluppo | Modello giusto per task giusto, Opus su NEXOS per architettura, batch e checkpoint |
| Costo AI a runtime fuori controllo | Sistema ibrido, context caching, pre-generazione, Gateway che evita il 70% delle chiamate LLM |
| Deprecazione modelli o servizi | Strato di astrazione AIProvider; deep link nativi al posto dei Dynamic Links dismessi |
| Device deboli e performance | Quality Tier dinamico e degradazione graceful |
| Dipendenza da API astrologica esterna | Cache aggressiva e opzione self-hosting Swiss Ephemeris |
| Ritardo sulla deadline | Asset generati con AI, avatar animati rapidamente, feature flag invece di demo separata |

*Documento tecnico definitivo. Da questo deriva il Briefing Operativo MVP e Demo, che dettaglierà la guida cronologica passo passo e definirà le funzionalità attive e quelle Coming soon.*

## 38. Livello di visualizzazione obbligatorio (data-viz layer)

Ogni responso significativo dell app espone un livello grafico generato lato client prima del testo. Tecnicamente: componenti riutilizzabili di visualizzazione (barre animate, anelli percentuali, grafici a onde per il bioritmo, radar per gli archetipi, calendario per la fertilità). Le animazioni di riempimento sono leggere (Lottie o animazioni native Flutter) e soggette al Quality Tier dinamico. Il dato numerico (percentuale, punteggio) viene dal calcolo deterministico o dall API astrologica, non dall LLM; l LLM produce solo il testo di accompagnamento col sistema ibrido. Questo mantiene basso il costo e veloce la resa.

## 39. Pipeline asset grafici

Aggiornamento alla pipeline asset. La generazione degli asset di brand che richiedono coerenza di stile (carte dei tarocchi, 72 Angeli, rune, cristalli, sfondi, ritratti illustrati) avviene tramite il modello di generazione immagini di Vertex AI sullo stack Google, coperto dai crediti, perche consente di lavorare con immagine pilota di riferimento e prompt-template per la consistenza dell intero set. NEXOS resta utile per generazioni rapide e prototipazione testuale e di prompt, ma non e la via primaria per gli asset di brand coerenti, perche non garantisce il flusso con immagine di riferimento necessario alla consistenza (ad esempio la coerenza tra le 78 carte dei tarocchi). Leonardo AI con Style Reference e Custom Model addestrato sull immagine pilota master resta l opzione di riserva quando serve una coerenza di stile superiore non ottenibile altrimenti. Coerente con la decisione di processo: tutta la produzione di asset e affidata all automazione, senza rifinitura manuale iniziale, salvo l intro cinematografica realizzata dall utente in After Effects. Stile e regola pilota aggiornati in Fase B: lo stile del set e il Total Metal multicolore inciso in rilievo (carta pilota master Il Sole, cornice madre fissa oro e blu Medora, cartiglio con solo nome e numero variabili); oltre alla pilota master si produce una pilota di riferimento per ciascuna famiglia (carte, 72 Angeli, rune, cristalli, ritratti VIP), piu il dorso del mazzo come asset dedicato (luna e onde in metallo inciso, simmetrico). Le rune sono pietre a contorni irregolari, non carte; i tre sfondi Maestro sono in stile pittorico atmosferico. La fase esplorativa dello stile si conduce su NEXOS e Nano Banana 2 per iterare rapidamente e gratis sui prompt, mentre il consolidamento della pilota, l upscaling al formato master e la generazione in batch dell intero set avvengono su Vertex AI con immagine pilota di riferimento.

Leonardo AI con Style Reference e Custom Model addestrato sulla carta pilota master, per la coerenza di stile su tutto il set (carte, 72 Angeli, rune, cristalli, sfondi).

Requisito: usare la generazione privata (piano adeguato) così gli asset di brand non restano nella galleria pubblica.

Rifinitura umana in Photoshop sugli asset chiave (avatar dei Maestri, carte principali): facoltativa e posticipata. Per velocita, in prima battuta tutti gli asset sono generati e usati cosi come prodotti dall automazione; la rifinitura manuale dell utente interviene solo dopo, a posteriori, sui momenti wow che eventualmente non soddisfano. Nota copyright: l output puramente AI puo non essere registrabile, quindi sugli asset di brand chiave una rifinitura umana resta consigliata quando ci sara tempo, per rafforzare la titolarita.

Regola dell asset pilota: una carta perfetta come master prima della generazione in serie.

## 40. Rituali di Caligo: architettura a database curato

I rituali non sono generati liberamente dall LLM. Esiste un database curato di micro-rituali basati su pratiche reali documentate (candle magic, sigilli, mantra, bagni rituali, rune di protezione, cristalli). Alla richiesta dell utente, il sistema seleziona dal database il rito pertinente allo scopo e l LLM lo personalizza nel tono col sistema ibrido, senza inventare la sostanza. Filtri: esclusione dei rituali che agiscono sulla volontà di terzi; disclaimer sempre allegato. I rituali leggeri sono nel MVP, quelli guidati interattivi in Fase C.

## 41. Nuove funzionalità: note tecniche di calcolo

| **Funzionalità** | **Base di calcolo** | **Carico AI** |
| --- | --- | --- |
| Bioritmo | Formula sinusoidale deterministica sulla data di nascita (cicli 23, 28, 33 giorni) | Nullo per il grafico; LLM solo per il testo |
| Fertilità astrologica | Calcolo su carta natale e transiti (es. Luna, metodo Jonas) via motore astrologico | Nullo per le finestre; LLM per il commento |
| Numerologia | Riduzione numerica deterministica da data e nome | Nullo per il numero; LLM per l interpretazione |
| Interpretazione sogni | Input testo utente + simbolismo da database + carta natale | LLM pieno, con sistema ibrido sui simboli |
| Calendario lunare | Dati lunari dall API astrologica | Nullo; contenuti rituali pre-generati |

Coerente con il principio: i dati esatti vengono da calcoli deterministici o dall API svizzera, l AI aggiunge solo il testo. La regola di coerenza resta: i responsi a parità di domanda sono validi per la giornata.

## 42. Chiedi ai Maestri con categorie: routing

Nella Demo e in primo piano, Chiedi ai Maestri usa domande suggerite per categoria. Tecnicamente questo permette di pre-generare e cachare le risposte alle domande classiche più frequenti per profilo (segno, categoria), riducendo costo e latenza, esattamente come per gli oracoli. La domanda in testo libero resta gestita dall AI Gateway con query piena a Gemini, in secondo piano.

## 43. Lunologia: note tecniche

Tutti i dati lunari (fase, percentuale illuminazione, Luna nel segno, giorno lunare, Void of Course, calendario biodinamico) provengono dal motore astrologico su effemeridi svizzere, calcolo deterministico. Nessun carico LLM per i dati. L AI con sistema ibrido produce solo il testo dei consigli, pre-generabile e cachato per profilo. Il Void of Course si calcola dagli aspetti della Luna prima del cambio di segno. Componenti visivi dedicati (Luna 2.5D, calendario, indicatori di favorevolezza animati) coerenti col data-viz layer e col Quality Tier.

## 44. Costellazione del Viso: note tecniche

Acquisizione via videocamera in streaming con rilevamento dei punti caratteristici del volto (face landmark detection on-device, ML Kit o equivalente). I punti vengono renderizzati come stelle collegate da linee (overlay grafico in tempo reale, costellazione). I tratti rilevati si mappano sui 68 tratti della personologia di Edward Vincent Jones in un database curato. Approccio ibrido: lettura dei tratti stabile e coerente per la stessa persona (salvata), incrocio quotidiano con i transiti per la parte variabile. Elaborazione on-device dove possibile per privacy; nessuna immagine del volto conservata senza consenso esplicito (GDPR). Disclaimer obbligatorio.

## 45. Oroscopo a quattro versioni: note tecniche

Le quattro versioni (Generale, Amore, Carriera, Fortuna) per i 12 segni si pre-generano in batch notturno con Gemini 3 Flash a partire dai dati astrologici dell API, e si servono dalla cache a costo e latenza minimi. Ogni versione espone un indicatore numerico di favorevolezza per l area, calcolato in modo deterministico, reso come anello animato dal data-viz layer.

## 46. Nuove aree dell ecosistema: note di calcolo e dominio dati

| **Area** | **Fonte dati** | **Carico AI** |
| --- | --- | --- |
| Ritorni planetari (Saturn/Solar Return) | Calcolo deterministico via effemeridi svizzere | Nullo per il calcolo; LLM per la lettura |
| Astrologia cinese (Ba Zi) | Calcolo calendario cinese deterministico | Nullo per i dati; LLM per il testo |
| Astrologia vedica (Jyotish) | Effemeridi siderali, calcolo deterministico | Nullo per i dati; LLM per il testo |
| Astrocartografia | Linee planetarie su mappa, calcolo geografico | Nullo per le linee; LLM per le interpretazioni di zona |
| Feng Shui | Regole codificate + dati natali | Basso; LLM per i consigli |
| Carte angeliche / analisi aura | Database curato + estrazione | Sistema ibrido sui significati |
| Cosmic Academy | Contenuti editoriali pre-prodotti | Nullo a runtime |
| Animale Guida (Caligo) | Derivazione deterministica da carta natale + archetipo junghiano; fisso per la persona | Nullo per il calcolo dell animale; LLM ibrido per il testo e per il Messaggio da [nome animale] variabile sui transiti |
| Grafologia esoterica (Aura) | Parametri grafici misurabili dalla scrittura col dito (dimensione, pressione, inclinazione, spaziatura, ritmo) mappati su database curato | Basso; LLM ibrido per il testo, incrocio coi transiti per la parte variabile |
| Oracolo degli Angeli (Medora, Fase 2) | Estrazione casuale e stesa dal mazzo dei 72 Angeli (set grafico unico gia prodotto); nessun dato astrologico richiesto | Sistema ibrido sui significati angelici; esito oracolare variabile a ogni consultazione, distinto dall Angelo Custode fisso |

Principio confermato: i dati esatti vengono da calcoli deterministici o dall API svizzera, l AI aggiunge solo il testo col sistema ibrido. Le astrologie alternative sono gating premium (Tier 2 e 3) via feature flag e controllo dell entitlement.

## 47. Domini aggiornati: Angelo Custode e Cabala

L Angelo Custode personale (i 72 calcolati come grado astrologico dalla posizione del Sole) e una feature di dominio Medora: riusa interamente il motore astrologico su effemeridi svizzere, costo incrementale minimo. La Cabala, l Albero della Vita e il sistema cabalistico completo (Sefirot, 22 sentieri, Shem HaMephorash colto) restano di dominio Caligo. La distinzione e tra livello pop-astrologico (Medora) e livello esoterico colto (Caligo). Dal set unico dei 72 Angeli (palette Medora) deriva anche l Oracolo degli Angeli, una consultazione oracolare con estrazione e stesa dal mazzo dei 72 Angeli (modello delle carte oracolari angeliche), di dominio Medora e collocata in Fase 2: l esito e oracolare e variabile a ogni consultazione, distinto dall Angelo Custode identitario fisso. Riusa lo stesso set grafico, quindi a costo marginale basso; carico AI col sistema ibrido sui significati, disclaimer per intrattenimento e crescita personale.

## 48. La Runa del Tramonto: note tecniche

Elemento serale di Caligo. Lancio rune tramite scuotimento del dispositivo: rilevamento via accelerometro con soglia di shake, fallback a tap o swipe per i device non abilitati (principio trasversale dei sensori). Estrazione con vera casualita dal set rune, animazione Rive del lancio, significato base dal database statico, presagio personalizzato col sistema ibrido. Pre-generabile e cachabile per profilo come gli altri elementi quotidiani.

## 49. Karma: note tecniche

La cornice karmica e narrativa (nessun calcolo). La Lettura Karmica si basa sui Nodi Lunari (nodo nord e nodo sud) della carta natale, calcolati in modo deterministico dall API svizzera; l AI col sistema ibrido produce solo il testo interpretativo. Nessun carico LLM per il dato.

## 50. Animale Guida e Grafologia esoterica: note tecniche

Animale Guida (Caligo): l animale di potere si deriva in modo deterministico dalla carta natale incrociata con l archetipo junghiano dominante, con una tabella di mapping curata; e fisso e persistito nel profilo (Cosmic Passport), nessun carico LLM per il dato. La rivelazione usa un animazione di nebbia che si dirada (Rive o Lottie) e asset Imagen 4. Il richiamo Messaggio da [nome animale] e una card on-demand: il testo del giorno e prodotto col sistema ibrido sui transiti, pre-generabile e cachabile per profilo come gli altri contenuti identitari. Lo stesso modello dell Angelo Custode. Grafologia esoterica (Aura): acquisizione della scrittura tracciata col dito su canvas; estrazione di parametri grafici misurabili on-device (dimensione, pressione dove esposta, inclinazione, spaziatura, ritmo e ampiezza del tratto) mappati su un database curato di significati grafologici (Moretti, Crepieux-Jamin, Klages). Approccio ibrido: lettura di fondo stabile per la persona piu incrocio quotidiano coi transiti; l AI ibrida produce solo il testo. Gesto tattile nativo, nessun fallback sensori necessario. Componenti data-viz dedicati (linee dorate del tratto, indicatori a barre e anelli). Disclaimer obbligatorio.

## 51. Cartomanzia, gating e tooltip: note tecniche

Mazzi multipli: l artwork dei mazzi (Rider-Waite default, Marsiglia, Thoth) e un set di asset intercambiabile selezionabile a runtime; la logica della stesa e i significati restano gli stessi, indipendenti dal mazzo. Carte dritte e rovesciate: a ogni estrazione si assegna in modo casuale l orientamento; l artwork ruota di 180 gradi nell animazione del flip e il database dei significati espone due varianti per ogni carta, dritto e rovesciato, da cui il sistema ibrido genera il testo. Un flag utente, Includi carte rovesciate, attivo di default, governa il comportamento. Gating visivo e entitlement: lo stato di ogni funzione (attiva, in grigio per tier superiore, esaurita) e governato dai feature flag via Firebase Remote Config uniti al controllo dell entitlement del tier e dei contatori giornalieri (reset giornaliero); al tap su un elemento in grigio si mostra il tooltip di sblocco (abbonamento o acquisto in Eos di una richiesta aggiuntiva). Tooltip di trasparenza metodologica: testo statico per tipo di responso, mappato alla fonte metodologica, servito dal database senza alcun carico LLM. Localizzazione dei nomi carta (i18n): l artwork statico si genera con entrambi i cartigli, superiore e inferiore, completamente vuoti, senza alcun numero ne nome inciso. Sia il numerale o valore (numero romano per gli Arcani Maggiori, numero arabo o sigla di corte per i Minori, numero dell angelo per i 72 Angeli) sia il nome della carta sono widget di testo sovrapposti a runtime in Flutter con font dorato, risolti dal sistema di internazionalizzazione secondo la lingua dell utente. Un unico set di asset per tutte le lingue: aggiungere una lingua significa aggiungere il file di traduzioni, senza rigenerare o duplicare immagini. Coerente con la localizzazione via Firebase Remote Config e con il rollout per mercato (prima italiano, poi anglofoni, poi altri paesi).

## 52. Affinita Lunare e Sinastria Celeb: note tecniche e legali

Affinita Lunare: usa i dati di fase lunare gia calcolati dal motore lunare (effemeridi svizzere) per le due date di nascita; il punteggio di affinita e una formula deterministica sulla distanza tra le due fasi, nessun carico LLM per il dato, solo testo breve opzionale via sistema ibrido. Componenti data-viz dedicati (due lune affiancate, percentuale animata), card condivisibile con deep link. Sinastria Celeb: il calcolo usa la sola data di nascita del personaggio, dato di fatto non protetto; nel database VIP non si archiviano fotografie non licenziate ma ritratti illustrati prodotti internamente (o immagini a licenza libera verificata), per evitare violazioni di copyright fotografico e di diritto all immagine e di pubblicita. Ogni output espone un disclaimer di satira e intrattenimento. La conformita va verificata legalmente per mercato prima del lancio commerciale, con attenzione al diritto di pubblicita statunitense, variabile per stato.

## 53. Sigilli del Cammino: note tecniche

I Sigilli del Cammino sono uno stato di progressione persistito per utente e per sentiero (contatori dei traguardi, stato acceso/spento di ogni Sigillo, premi gia erogati). La logica e deterministica e a costo AI nullo: un traguardo si valida quando l evento corrispondente si verifica (carta natale creata, sessioni completate, oracoli estratti, eccetera). L accensione dell icona del Sigillo avviene sempre al raggiungimento del traguardo, indipendentemente dalla condivisione, cosi nessun utente resta escluso. La condivisione governa invece un bonus in Eos graduato per valore verificabile dell azione: massimo per l invito amico che genera un download, alto per la condivisione social pubblica, medio per la condivisione privata verificabile, nullo se nessuna azione ma con Sigillo comunque acceso. Il tetto giornaliero sulle azioni premiate e gestito dal rate limiter (coerente con la sezione sicurezza e abuse prevention). Le card dei traguardi seguono il formato condivisibile unico con deep link nativo. Le tre visualizzazioni (Albero, Costellazione, Loto) sono rese verticali con animazione di apertura dall alto e scorrimento a ritroso fino al punto utente, realizzate con Rive o Lottie e degradate dal Quality Tier sui device deboli. Il gating per tier (Free fino al ventesimo traguardo, journal completo dal Tier 1) e governato dai feature flag piu il controllo dell entitlement. La distinzione tra Albero della Vita contemplativo (statico, navigabile, in Demo e MVP) e Albero della Vita dinamico (il sentiero di Caligo che si illumina coi traguardi, Tier 3, Fase 2) resta valida: condividono gli asset 2.5D ma il primo non reagisce ai progressi, il secondo si.

## 54. Tre chiavi di lettura della cartomanzia: note tecniche

La stessa estrazione di carte (deterministica, dal motore oracoli) puo essere interpretata in tre chiavi selezionate dall utente prima della stesa. Il database dei significati estende le due varianti di orientamento (dritto/rovesciato) con tre profili interpretativi: predittivo (tono Medora), riflessione personale ispirato a Jodorowsky (Tarocco di Marsiglia, taglio di crescita non predittivo), esoterico-iniziatico (tono Caligo, mapping Arcano-sentiero dell Albero della Vita e archetipi). Il sistema ibrido riceve come scheletro la chiave scelta piu il significato base e produce solo il testo nel registro corrispondente; nessun costo di calcolo aggiuntivo, solo testo. La profondita (Breve/Media/Approfondita) modula i token in output. Citazione di Jodorowsky come ispirazione dichiarata, mai come marchio della funzione, con disclaimer divulgativo che la lettura e per intrattenimento e crescita personale. Controllo costi via limiti di stese giornaliere per tier: le tre chiavi restano disponibili a tutti dall MVP, senza gating dedicato.

## 55. Strategia asset e animazioni: automazione integrale (decisione di processo)

Per ridurre i tempi di sviluppo, la produzione di tutti gli asset grafici e di tutte le animazioni e affidata integralmente all automazione, senza lavorazione manuale in prima battuta. Asset statici (carte, 72 Angeli, rune, cristalli, sfondi, ritratti illustrati, avatar) nello stile Total Metal multicolore inciso definito in Fase B (carta pilota master Il Sole, cornice madre oro e blu Medora; rune come pietre; 72 Angeli set unico Medora; sfondi Maestro pittorici atmosferici): la ricerca dello stile si conduce su NEXOS e Nano Banana 2 per iterare rapidamente sui prompt, il consolidamento della pilota e la generazione in batch dell intero set con immagine di riferimento e upscaling avvengono su Vertex AI (Leonardo AI in riserva). Micro-interazioni e animazioni leggere con Lottie e animazioni native Flutter. Animazioni piu complesse (avatar in loop, effetto finto-3D del Maestro che esce dalla carta, nebbia che si dirada per l Animale Guida, Albero della Vita che si illumina, Sigilli del Cammino) realizzate con Rive e shader in modo automatico. Unica eccezione: l intro cinematografica (In principio era il nulla, countdown da 13,8 miliardi a zero, percorso dal Big Bang alla Terra) e prodotta a mano dall utente in After Effects e integrata come video pre-renderizzato. La rifinitura manuale dell utente (grafico esperto, con Photoshop, Illustrator, After Effects ed Envato) e una fase facoltativa e successiva: si valuta a posteriori, vedendo il risultato automatico, e si interviene solo sui momenti wow chiave che non soddisfano. Questa scelta e reversibile e non vincola nulla, perche ogni asset puo essere sostituito o rifinito in seguito.

## 56. Workflow Suite Claude: configurazione, implementazione, ottimizzazione

Separazione netta dei due ambienti per minimizzare i costi. Ambiente di architettura e pianificazione: Claude Opus ultima versione su NEXOS, crediti illimitati, costo zero per l utente; qui restano briefing, decisioni architetturali, revisioni e prompt di sistema dei Maestri. Ambiente di sviluppo operativo: account Claude dedicato a pagamento (piano Max, partenza consigliata Max 5x e salita a Max 20x solo se i limiti si saturano), su cui girano Claude Code, Cowork, Managed Agents, Design e le Skill. Su questo account l utente va guidato nella configurazione iniziale e nell ottimizzazione del consumo.

Configurazione consigliata. Claude Code: collegato al repository GitHub del progetto, con i quattro documenti guida caricati nel progetto per sfruttare il caching che non consuma limiti sul contenuto riusato. Managed Agents specializzati, uno per dominio con contesto pulito e lavoro parallelizzabile: Agente UI Flutter (schermate, widget, design system 2.5D), Agente Backend Google (Cloud Run, Firestore, Cloud SQL, API), Agente AI e Gemini (AI Gateway, prompt dei Maestri, sistema ibrido), Agente Debug (test e correzioni autonome). Cowork per i task autonomi e schedulati. Design come acceleratore di UX a monte, non come prodotto finale. Skill: installare quelle open source mature per Flutter e per il workflow agentico da fonti verificate, invece di reinventarle, dopo controllo di sicurezza.

Ottimizzazione del consumo. Regola del modello giusto per il task giusto: Haiku per il banale, Sonnet per lo standard, Opus solo per l architettura e via NEXOS quando possibile. Usare i progetti e il caching dei documenti per non ripagare il contesto a ogni messaggio. Raggruppare richieste correlate in un solo messaggio. Monitorare il consumo da Impostazioni, Utilizzo, dove si vedono le barre della sessione di cinque ore e i tetti settimanali, con il limite su Opus contato a parte. Pause di controllo solo ai sei checkpoint, sviluppo e debug continui tra un checkpoint e l altro per non frammentare le sessioni. I nomi e i limiti esatti dei piani e dei modelli vanno verificati al momento dell attivazione.
