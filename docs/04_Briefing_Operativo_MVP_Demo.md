BRIEFING OPERATIVO MVP E DEMO

**Esoteric Circle**

*Dalla selezione delle funzionalità alla guida cronologica per lo sviluppo*

Terzo documento guida, derivato dal Briefing Progetto e dal Master Tecnico Definitivo.
Giugno 2026

# PARTE I — Inquadramento operativo

## 1. Scopo del documento

Questo è il terzo documento guida del progetto, dopo il Briefing Progetto Definitivo (la visione e le funzionalità) e il Master Tecnico Definitivo (l architettura e lo stack). Qui si traduce tutto in operativo: quali funzionalità entrano nella Demo e quali nell MVP, come si vivono le esperienze immersive, e soprattutto la guida cronologica passo passo che porta dallo stato attuale all avvio dello sviluppo autonomo. È il documento che si tiene aperto durante il lavoro.

## 2. I due obiettivi: Demo e MVP

Vanno tenuti distinti perché hanno scopi diversi.

La Demo serve a impressionare i fondatori e Google per la candidatura al programma Startup. Deve dimostrare in pochi minuti viralità, unicità ed esecuzione. Alcune funzioni sono pienamente attive, altre sono visibili ma in grigio o semitrasparenza con badge Coming soon.

L MVP è la versione di lancio reale al pubblico, dove tutte le funzioni core sono attive.

Punto fondamentale: Demo e MVP sono lo stesso codice. Non si costruisce nulla di separato. La Demo è semplicemente lo stato dell app nativa Flutter a un certo punto dello sviluppo, con i feature flag che spengono le funzioni non ancora pronte. Questo è ciò che rende la presentazione credibile: a Google si mostra un prodotto vero che gira su un device, non un prototipo.

## 3. Il punto di stop della Demo e il congelamento dello scope

Il punto di stop è il momento in cui la Demo è pronta da presentare: tutte le funzioni del Livello 1 sono attive e rifinite, tutte le altre sono visibili in grigio. Da lì si prosegue verso l MVP completo senza interrompere.

Regola di disciplina approvata: dopo questo documento lo scope della Demo è congelato. Nessuna nuova funzionalità entra nella Demo finché non è consegnata. Ogni nuova idea, per quanto valida, viene registrata in una lista per le fasi successive. Questa disciplina è ciò che permette di arrivare alla presentazione senza rincorrere un traguardo che si sposta. L utente non ha una scadenza fissa: si procede alla massima velocità possibile mantenendo qualità altissima e risultato ultra professionale.

# PARTE II — La mappa delle funzionalità

## 4. I tre livelli

Ogni funzionalità è classificata in tre livelli, secondo cosa serve mostrare a Google e cosa è sostenibile nei tempi.

Livello 1, attivo nella Demo: l effetto wow e il valore unico, pienamente funzionante.

Livello 2, grigio nella Demo ma attivo nell MVP: importante ma meno spettacolare in cinque minuti, oppure tecnicamente più pesante.

Livello 3, fasi successive: assente o grigio, sviluppato dopo il lancio.

## 5. I quattro elementi quotidiani (tutti attivi nella Demo)

Sono trasversali e contati a parte rispetto alle funzioni dei Maestri. Ciascuno ha la sua notifica push personalizzabile a orario sfalsato, e tutte le card restano disponibili in app anche senza notifica.

| **Elemento** | **Maestro** | **Ora** | **Cosa fa** |
| --- | --- | --- | --- |
| Rito dell Alba | A rotazione tra i tre | ~7:00 | Micro-rito fisico di 2-3 minuti da eseguire davvero |
| Soffio del Destino | Aura | ~10:30 | Verità cosmica poetica del giorno, condivisibile |
| Oracolo del Giorno (giroscopico) | Medora | ~12:30 | Messaggio astrologico sulla carta natale; esperienza col telefono alzato al cielo |
| La Runa del Tramonto | Caligo | ~18:00 | Lancio serale delle rune tramite scuotimento del cellulare (con fallback tattile), con presagio runico per la notte |

## 6. Le tre funzionalità distintive per Maestro (attive nella Demo)

In aggiunta agli elementi quotidiani, ogni Maestro ha tre funzioni attive che ne dimostrano il dominio. La selezione bilancia per ciascun Maestro una funzione virale, una differenziante e una classica ben eseguita.

### 6.1 Medora — Astrologia, cartomanzia, destino (blu chiaro e oro)

Stesa a tre carte col ventaglio. La funzionalità principale voluta dai fondatori, la cartomanzia seria e professionale. Meccanica dettagliata nella Parte III.

Sinastria Celeb. La leva virale: compatibilità con un personaggio famoso, card condivisibile. Dimostra a Google il potenziale di crescita organica.

Carta natale interattiva con transiti. La ruota natale 2.5D con i pianeti che si posizionano, alimentata dalle API svizzere. Mostra il cuore astrologico serio. Inoltre Medora ospita l Angelo Custode personale (i 72 calcolati dalla data di nascita), feature identitaria e virale.

### 6.2 Aura — Energia, benessere, psiche (verde smeraldo e oro)

Test Archetipo junghiano. Gancio virale nobilitato da Jung: l utente scopre il suo archetipo e lo condivide. Acquisizione organica e percezione premium.

Costellazione del Viso (videocamera). Analisi del volto via videocamera con i punti del viso che si illuminano e formano una costellazione personale, poi l interpretazione. Basata sulla personologia di Edward Vincent Jones (68 tratti), approccio ibrido tratti stabili piu transiti. Effetto wow immediato, ideale da mostrare a Google. Sostituisce il Mood Tracker, che resta nell MVP.

Meditazione o breathwork con la voce. Esperienza immersiva e calma che mostra la voce Gemini-TTS e un lato premium e contemplativo.

### 6.3 Caligo — Rune, simbologia, Cabala, Angeli (rosso e oro)

Albero della Vita contemplativo. Schermata navigabile 2.5D delle dieci Sefirot e dei sistemi cabalistici, alto impatto wow visivo, tecnicamente leggera perche statica.

Estrazione delle Rune con interpretazione. L oracolo simbolico di Caligo, con l animazione del lancio e la lettura nel suo tono di saggio potente.

Animale Guida personale. L animale di potere dell utente, di dominio Caligo, radicato nel core shamanism documentato (Michael Harner). E una feature identitaria e virale: si calcola in modo deterministico dalla carta natale incrociata con l archetipo junghiano, quindi e fisso per la persona e non cambia a ogni consultazione, come l Angelo Custode. Si rivela con un animazione di nebbia che si dirada (coerente col nome Caligo, nebbia), genera asset grafici suggestivi via Imagen 4 e una card altamente condivisibile. L animale entra nel profilo identitario dell utente (Cosmic Passport), accanto all Angelo Custode e all archetipo. Da qui l utente puo richiamare on-demand la card Messaggio da [nome animale], il cui contenuto varia ogni giorno sui transiti mentre l animale resta fisso. Sostituisce il Sigillo magico tra le funzioni distintive in Demo perche piu virale; il Sigillo resta attivo nell MVP e nel modulo rituali. Disclaimer per intrattenimento e crescita personale.

## 7. Tabella riassuntiva: cosa è attivo, grigio o assente nella Demo

| **Funzionalità** | **Stato nella Demo** |
| --- | --- |
| Intro cinematografica | Attiva (video pre-renderizzato) |
| Onboarding Il Risveglio + carta natale | Attiva |
| Rivelazione del Maestro col soffio | Attiva (con fallback gesto) |
| 4 elementi quotidiani | Attivi |
| Medora: stesa 3 carte, Sinastria Celeb, carta natale interattiva, Angelo Custode | Attive |
| Aura: Costellazione del Viso, Test Archetipo, meditazione con voce | Attive |
| Caligo: Estrazione Rune, Albero della Vita contemplativo, Animale Guida | Attive |
| Chat AI con i tre Maestri + voce | Attiva (account demo con memoria pre-popolata) |
| Home Il Santuario, colori, parallasse, effetti | Attivi |
| Cosmic Journal a tre sentieri | Visibile; riempimento dinamico Coming soon |
| Sezione Oracoli estesa (I-Ching, pendolo, cristalli, fondi caffè) | Grigio Coming soon |
| Chiromanzia ibrida | Grigio Coming soon |
| Economia Eos e gamification completa | Parziale; mostrata, non tutto attivo |
| Schermata prezzi tier | Visibile (pagamento non integrato in demo) |
| Cosmic Dating, AR, Pet Astrology, tradizioni non occidentali | Assenti o grigio (fasi successive) |

# PARTE III — L esperienza utente immersiva (le meccaniche wow)

## 8. Intro cinematografica

L intro è un video pre-renderizzato realizzato dall utente in After Effects (qualunque formato e dimensione), non generato da AI. Racconta: schermo nero con voce femminile in eco che recita In principio era il nulla, il punto bianco che esplode nel Big Bang, la corsa tra galassie e pianeti con countdown da 13,8 miliardi a zero, l arrivo sulla Terra dove appaiono in semitrasparenza i tre Maestri, e infine il firmamento dinamico che apre l onboarding.

Note tecniche: prevedere un primo frame statico identico all inizio del video per evitare lo sfarfallio bianco al caricamento; prevedere un fallback per i device lenti; ottimizzare il peso del file per non gonfiare l app.

## 9. Onboarding Il Risveglio e assegnazione del Maestro

Raccoglie data (obbligatoria), ora (opzionale con spiegazione) e luogo di nascita, calcola la carta natale via API svizzere e la mostra con animazione. Durante l onboarding emergono il primo momento wow del modulo spirituale (Angelo Custode) e il Test Archetipo.

Registrazione veloce: quando durante l onboarding o dopo serve creare l account, oltre a email e telefono si offre il social login Google e Apple tramite Firebase Auth, la via a piu basso attrito. Coerente con la registrazione progressiva del Briefing Progetto: utente anonimo all inizio, account solo quando serve, telefono mai nel form. Su iOS, offrendo login social di terzi, si offre anche Sign in with Apple come da linee guida App Store.

Telefono via scambio di valore e promozione interna. Il numero non entra mai nel form: si raccoglie dopo, offrendo dal Tier 1 una funzione opzionale di consegna via WhatsApp o SMS (oroscopo giornaliero, alert transiti, Runa del Tramonto), visibile in grigio nel Free. Il gating al Tier 1 copre il costo reale del canale; il valore comunicato e la comodita della consegna proattiva, non il contenuto, gratis in app. L attivazione si promuove con una sezione animata inline (preferita) e un popup saltuario, con frequency cap, opzione non mostrare piu, mai bloccante e mai nei flussi immersivi. Consenso GDPR separato per WhatsApp e SMS.

Assegnazione del Maestro: deriva dalla carta natale e dall archetipo emerso, non da un survey freddo. È un incontro naturale, più immersivo. L utente può comunque cambiare Maestro liberamente in qualsiasi momento.

## 10. La rivelazione del Maestro col soffio

Dopo l assegnazione, il Maestro si rivela con un gesto rituale basato sul microfono (soffio), con fallback tattile universale.

| **Maestro** | **Gesto col soffio** | **Fallback a gesto** |
| --- | --- | --- |
| Medora | Soffia sulla sfera di cristallo: il fumo si dissolve | Sfregata sulla sfera (stile gratta e vinci) |
| Caligo | Soffia per spegnere la candela | Tap o swipe sulla candela |
| Aura | Soffia per disperdere il soffione (dente di leone) | Swipe che disperde il soffione |

Il microfono è l esperienza premium, il gesto è il fallback per chi nega il permesso o ha un microfono inadatto. Principio trasversale (sezione 14).

## 11. La meccanica della stesa di Medora

La stesa a tre carte (Passato, Presente, Futuro) è la funzionalità principale, e la sua meccanica è studiata per creare il massimo senso di destino personale.

Medora appare e con un animazione apre il mazzo a ventaglio (carte coperte) che esce dalle sue mani con effetto finto-3D.

Medora invita a scegliere con l istinto. Facoltativamente l utente può scuotere il telefono per mescolare (con fallback tap).

L utente tocca tre carte del ventaglio; ognuna si stacca e vola nella sua posizione.

Le carte si girano una a una con il flip animato, rivelando l artwork.

Medora narra l interpretazione personalizzata con voce Gemini-TTS: prima ogni posizione, poi la sintesi.

Si genera la card condivisibile con cornice blu e oro di Medora.

La Croce Celtica a dieci carte resta una stesa premium, troppo lunga per la Demo. Le stese nella tradizione hanno numero di carte fisso: 1 (carta singola), 3 (Passato-Presente-Futuro), 7 (Relazione), 10 (Croce Celtica).

## 12. L Oracolo del Giorno con esperienza giroscopica

Sui dispositivi abilitati, l utente alza il telefono verso il cielo: un cielo stellato dinamico si muove con il giroscopio, e quando inquadra la zona del proprio segno o transito, l elemento si illumina. Trovato il punto, si genera la card condivisibile dell oroscopo. Sui device non abilitati la funzione si disabilita e si sostituisce con un gesto del dito (swipe o tap per trovare il segno). È la modalità con cui si vive l elemento quotidiano Oracolo del Giorno di Medora.

## 13. La chiromanzia ibrida (Coming soon nella Demo)

La lettura della mano adotta la Strada ibrida: la fotocamera identifica alcuni tratti stabili della mano (che restano coerenti nel tempo), e il responso del giorno li combina con i transiti astrologici del momento. Così la base è reale e coerente (la tua mano è la tua mano) ma il messaggio quotidiano cambia perché cambia il cielo. Questo evita l effetto slot-machine e regge il claim l app diversa per tutti e differente per ognuno. Richiede il riconoscimento immagine, quindi è classificata Coming soon nella Demo e attivata in una fase immediatamente successiva.

## 14. Principio trasversale: sensori con fallback obbligatorio

Regola d oro del progetto: ogni esperienza basata su sensori (giroscopio, microfono, fotocamera) deve sempre avere un fallback a gesto tattile. Si crea l effetto wow su chi ha il dispositivo adatto, senza mai escludere nessuno. Vale per il soffio, il giroscopio dell oroscopo, lo scuotimento della stesa e la chiromanzia.

## 15. La regola di coerenza dei responsi

Per proteggere la credibilità, ogni oracolo segue una regola chiara: una stesa o estrazione, a parità di domanda, resta valida per la giornata. La stessa domanda nello stesso giorno dà lo stesso responso, perché il cielo del giorno è quello; cambia il giorno dopo. Questo rende vero il claim diverso ogni giorno ed evita che l utente, ripetendo la stessa azione, scopra esiti casuali contraddittori. La distinzione di fondo: ciò che racconta chi sei (carta natale, linee della mano, Angelo Custode, archetipo) è stabile; ciò che racconta cosa ti aspetta oggi (transiti, oracoli, presagi) varia con il cielo.

# PARTE IV — Il sistema visivo della Demo

## 16. Colori dei Maestri e stati dell app

| **Maestro** | **Colore prevalente** | **Note** |
| --- | --- | --- |
| Medora | Blu chiaro con inserti e linee oro | Per fondi e testo usare un blu più profondo: l oro su blu chiaro ha contrasto debole (WCAG) |
| Caligo | Rosso con inserti e linee oro | Oro su rosso regge bene |
| Aura | Verde smeraldo con inserti e linee oro | Oro su verde regge bene |
| Stato neutro | Viola scuro con oro, o nero notte stellato | Quando nessun Maestro è selezionato |

Quando un Maestro è selezionato, lo sfondo e l aura dell app assumono il suo colore. Ogni Maestro ha uno sfondo personalizzato che ne richiama le peculiarità.

## 17. Caligo: saggio potente, non signore oscuro

Caligo è ispirato a una persona reale (Gaetano): alchimista, ritualista, studioso di simboli e rune. Usa magia bianca, rossa e blu, non nera, sebbene la conosca. È saggio e imponente: l associazione a notte e oscurità nasce solo dalla sua presenza e dal suo potere, non da una natura malvagia. Va scritto e disegnato come custode che conosce sia la luce sia l ombra, autorevole e luminoso nella saggezza. Questo tono va fissato nei prompt AI per non renderlo ambiguo, e rende coerente l assegnazione a lui de La Runa del Tramonto.

## 18. Gli effetti visivi della Demo

Avatar dei Maestri sempre in animazione loop (es. Medora gioca con le carte che spariscono e riappaiono).

Maestro dentro la propria carta con effetto finto-3D: il personaggio su un layer davanti, la carta dietro fissa, con zoom o parallasse (anche legato al giroscopio) per l effetto di chi esce dalla carta.

Sfondo con parallasse dinamico multistrato, con UI, icone e pulsanti sopra.

Sfondi personalizzati per Maestro: cielo stellato con carte fluttuanti per Medora; stanza alchemica con candele, rune e fumo per Caligo; giardino energetico con petali e onde di chakra per Aura. Realizzati in stile pittorico atmosferico full-bleed senza cornice (a differenza delle carte in Total Metal), verticali a schermo, con spazio scuro centrale e inferiore per l interfaccia e piu piani per la parallasse; per Medora costellazioni dorate su cielo blu profondo, per Caligo la stanza alchemica calda non cupa, per Aura il giardino energetico verde e oro.

Onda luminosa del colore del Maestro che si propaga dal punto toccato.

Aura del Maestro che pulsa col respiro anche in idle.

Transizione tra Maestri come dissolvenza cromatica dell intera interfaccia.

Card condivisibili con la cornice e la palette del Maestro che le ha prodotte, riconoscibili sui social.

Tutti gli effetti sono regolati dal Quality Tier dinamico: pieni sui device potenti, semplificati su quelli deboli per mantenere i 60fps e la batteria.

## 19. Tooltip e coachmark per gli utenti meno esperti

Piccoli cerchi con punto di domanda, semitrasparenti, vicino agli elementi meno ovvi (soffio, giroscopio, valuta Eos). Si attivano solo al tocco, quindi non disturbano gli esperti, e compaiono una volta in modo gentile alla prima apertura di una schermata nuova. Concilia il principio non spiegare l app, falla vivere con l aiuto a chi è meno pratico.

## 20. Claude Design come acceleratore concreto

Claude Design si usa a monte per disegnare rapidamente le schermate e i flussi prima di codificarli, dando all Agente UI Flutter un riferimento visivo preciso che velocizza lo sviluppo. Non è il prodotto finale: i mockup vengono tradotti in widget Flutter nativi. È prezioso soprattutto nella fase iniziale di impostazione del design.

# PARTE V — La guida cronologica operativa passo passo

Principio: prima tutto il lavoro umano (account, credenziali, asset), poi lo sviluppo dell agente in massima autonomia con checkpoint visivi sul simulatore. Lo step-by-step si usa solo per le operazioni manuali dell utente; per lo sviluppo del codice l agente lavora autonomo, debug incluso.

## 21. Fase A — Lavoro umano: account e credenziali

Operazioni manuali guidate. Lo sviluppo non è ancora iniziato.

| **#** | **Azione dell utente** | **Esito** |
| --- | --- | --- |
| 1 | Creare account Claude dedicato e attivare Code, Cowork, Design, Agents | Ambiente di sviluppo pronto |
| 2 | Creare account Google Cloud e attivare i crediti Google for Startups | Crediti infrastruttura attivi |
| 3 | Creare il progetto Google Cloud e abilitare le API (Vertex AI, Cloud Run, Cloud SQL, Firestore, Storage) | Servizi backend disponibili |
| 4 | Creare il progetto Firebase (Auth, Firestore, Storage, Remote Config, Analytics, Crashlytics, Cloud Messaging) | Auth e servizi mobile pronti |
| 5 | Creare account Apple Developer e Google Play Console | Pubblicazione possibile |
| 6 | Registrare account API astrologica (Swiss Ephemeris) e ottenere la chiave | Dati astrologici disponibili |
| 7 | Creare account Leonardo AI SOLO come riserva (piano con generazione privata e custom model); la via primaria e la generazione immagini su Vertex AI, gia coperta dallo stack Google | Pipeline grafica esterna pronta |
| 8 | Creare repository GitHub condiviso e collegarlo a Claude Code | Codebase versionato |
| 9 | Raccogliere tutte le credenziali e le API key in un luogo sicuro | Credenziali pronte per l agente |

## 22. Fase B — Asset, con pausa di controllo

La generazione grafica usa Nano Banana Pro (Gemini 3 Pro Image) su Vertex AI, coperto dai crediti Google, coperto dai crediti, con immagine pilota di riferimento e prompt-template per garantire la coerenza di stile su tutto il set (carte, 72 Angeli, rune, cristalli, sfondi, ritratti). NEXOS non e la via primaria per gli asset di brand coerenti, perche non garantisce il flusso con immagine di riferimento necessario alla consistenza tra gli elementi (ad esempio le 78 carte dei tarocchi). Leonardo AI con Style Reference e Custom Model resta opzione di riserva quando serve una coerenza superiore non ottenibile altrimenti. Esito della Fase B: lo stile del set e il Total Metal multicolore inciso in rilievo (carta pilota master Il Sole, cornice madre fissa oro e blu Medora, cartiglio con solo nome e numero variabili); le rune sono pietre a contorni irregolari, i 72 Angeli un set unico in palette Medora, gli sfondi Maestro pittorici atmosferici, piu il dorso del mazzo come asset dedicato. La ricerca dello stile si conduce su NEXOS e Nano Banana 2 per iterare rapidamente e gratis sui prompt, mentre il consolidamento della pilota, l upscaling al formato master e il batch dell intero set avvengono su Vertex AI con immagine di riferimento; Leonardo AI resta la riserva. Localizzazione dei nomi carta: l app parte dal mercato italiano, poi anglofono e poi altri paesi gradualmente; percio l artwork si genera con entrambi i cartigli, superiore e inferiore, vuoti: sia il numerale o valore sia il nome carta sono stringhe sovrapposte a runtime da Flutter nella lingua dell utente, cosi un unico set pulito vale per tutte le lingue. Un solo set di 78 artwork vale per tutte le lingue; le pilote generate con i nomi in inglese restano valide solo come test di stile, in produzione il cartiglio va lasciato pulito.

Aggiornamenti Fase B (asset finali validati). Rune: solo glifo d oro su pietra di basalto, PNG alpha, senza cornice; nome latinizzato e linea a runtime in Flutter, non incisi; lancio con scuotimento, rune che cadono e si ordinano, nome e lettura di Caligo sotto, scheda al tap. Cristalli: famiglia di 12 (Ametista, Quarzo rosa, Citrino, Quarzo trasparente, Ossidiana, Malachite, Corniola, Lapislazzuli, Occhio di tigre, Acquamarina, Turchese, Selenite), colore naturale reale e abito nativo distinto, oggetto isolato PNG alpha, oro sul cristallo non a cornice, scintille e pulse a runtime. Ritratti VIP: 50 per la Demo in 5 categorie, cornice VIP unica universale a finestra ad arco, glifo zodiacale e nome a runtime (cartigli vuoti), solo data di nascita, mai foto reali; disclaimer di satira nel disclaimer unico di registrazione, non su ogni card. La Sfera della Fortuna (dominio Aura) e il premio giornaliero: sfera avvolta da nube diradata col soffio o col dito, premio sempre dato in Eos e sblocchi, un tentativo gratis al giorno, aggancio allo streak, senza meccaniche di gambling.

Animali Guida: dodicesima famiglia di asset, 12 animali (Lupo, Orso, Aquila, Gufo, Cervo, Serpente, Lince, Corvo, Cavallo, Volpe, Tartaruga, Falco) in stile metallico multicolore, posa di profilo con testa verso l osservatore, palette Caligo rosso e oro, oggetto isolato senza cornice, PNG con alpha per l animazione della nebbia. Un prompt di scena per animale; mapping deterministico coi 12 archetipi junghiani (Lupo Esploratore, Orso Sovrano-Protettore, Aquila Visionario-Mago, Gufo Saggio, Cervo Innocente, Serpente Trasformatore, Lince Custode, Corvo Messaggero-Fuorilegge, Cavallo Eroe, Volpe Burlone, Tartaruga Radicamento, Falco Condottiero), da carta natale e archetipo, fisso per la persona. Da validare il primo blocco prima di completare la famiglia.

Principio aggiornato della Fase B: automazione integrale. Per guadagnare tempo, tutti gli asset grafici e tutte le animazioni (statiche, micro-interazioni e animazioni complesse) sono prodotti dall automazione senza lavorazione manuale iniziale. L unica eccezione e l intro cinematografica, realizzata dall utente in After Effects. La pausa di controllo dell utente resta, ma serve a decidere a posteriori quali eventuali momenti wow rifinire a mano, non a bloccare lo sviluppo.

Regola dell asset pilota: creare prima UNA carta perfetta nello stile definitivo (il master). Da quella, addestrare il custom model di Leonardo e generare in serie tutto il mazzo, i 72 Angeli, le rune, i cristalli, gli sfondi, mantenendo coerenza di stile. La carta perfetta di riferimento e Il Sole; oltre alla pilota master si crea una pilota di riferimento per ogni famiglia (una carta, un Angelo, una runa, un cristallo, un ritratto VIP, uno sfondo) per garantire la coerenza dentro ciascuna classe di asset. Le rune sono pietre, non carte.

Avatar dei Maestri: partendo dalle immagini base fornite dall utente, generare gli stati di animazione (idle con respiro, speaking sincronizzato col TTS, greeting) ed esportare un file animato a stati per Flutter.

Rifinitura umana sugli asset di brand: per velocita, in prima battuta NON si rifinisce nulla a mano. Tutti gli asset e tutte le animazioni si usano cosi come generati dall automazione. La rifinitura manuale dell utente (Photoshop, After Effects) e facoltativa e successiva: si valuta a posteriori, vedendo il risultato, e interviene solo sui momenti wow che eventualmente non soddisfano. Resta consigliata, quando ci sara tempo, una rifinitura sugli asset di brand chiave per rafforzare la titolarita del copyright, perche l output puramente AI puo non essere registrabile.

Voce: test delle voci Gemini-TTS in italiano come checkpoint, per verificare che i tre toni (elegante, caldo, solenne) siano convincenti prima di costruirci sopra.

Intro: integrare il video After Effects dell utente.

Database VIP per la Sinastria Celeb: 150-200 personaggi rappresentati con ritratti illustrati nello stile 2.5D dell app, ora nello stile Total Metal multicolore inciso con cornice oro e blu Medora e il glifo zodiacale del personaggio (o immagini a licenza libera verificata), mai fotografie non licenziate; date di nascita verificate da fonti primarie. Script di raccolta scritto dall agente.

Pausa di controllo: l utente rivede visivamente gli asset generati e approva o chiede rigenerazione prima di procedere allo sviluppo.

## 23. Fase C — Sviluppo autonomo con checkpoint visivi

Da qui l agente lavora in autonomia, debug incluso, fermandosi solo ai checkpoint. A ogni checkpoint l utente vede il risultato sul simulatore smartphone (emulatore Android e simulatore iOS con hot reload), naviga le schermate come un utente finale, approva o segnala correzioni. Tra i checkpoint lo sviluppo non si ferma.

| **Checkpoint** | **Cosa costruisce l agente** | **Cosa vede l utente sul simulatore** |
| --- | --- | --- |
| C1 | Scaffolding Flutter, design system 2.5D, navigazione, feature flags, colori dei Maestri | App che parte, home navigabile, funzioni grigie visibili |
| C2 | Intro + Onboarding Il Risveglio + carta natale via API svizzere + soffio del Maestro | Apertura cinematografica e onboarding reale |
| C3 | I tre Maestri con avatar animati, chat AI Gemini 3, voce Gemini-TTS, memoria pre-popolata demo | Maestri che parlano, rispondono e ricordano |
| C4 | I 4 elementi quotidiani (incluso Oracolo giroscopico e Runa del Tramonto) | Esperienza quotidiana completa e immersiva |
| C5 | Le 3 funzioni per Maestro: stesa col ventaglio, Sinastria Celeb, carta natale; Costellazione del Viso, Test Archetipo, meditazione; Rune, Albero contemplativo, Animale Guida | Tutte le funzioni wow della Demo attive |
| C6 | Cosmic Journal a 3 sentieri (riempimento Coming soon), economia Eos, rifinitura, feature flag finali | Demo completa e presentabile a Google |

# PARTE VI — Aspetti operativi trasversali

## 24. Pagamenti esterni (modello reader app)

Per ridurre le commissioni di Apple e Google, gli abbonamenti ricorrenti si acquistano fuori dall app, sul sito o web app esterna (modello Netflix, Disney+, Spotify), e l app legge solo lo stato dell abbonamento per sbloccare i contenuti. Approccio a doppio binario: i microacquisti di Eos restano in-app per comodità, gli abbonamenti passano dal web dove si risparmia.

Cautele approvate: le regole reader app e dei link esterni differiscono per mercato (negli USA, dopo la sentenza Epic, i link esterni non pagano commissione; in Europa Apple e Google applicano una commissione ridotta e requisiti di compliance, come la sincronizzazione delle transazioni). La verifica dello stato abbonamento tra web e app va costruita come componente dedicato (webhook, verifica, anti-frode) con fallback. La modalità esatta di presentazione del link va definita con cura per Italia, Europa e USA, perché un errore di compliance può causare il rifiuto dallo store. Nella Demo la schermata prezzi è visibile ma il pagamento non è integrato.

## 25. Economia Eos nella Demo

Nella Demo si mostra la valuta Eos, il premio di benvenuto di 250 Eos e la logica di guadagno e spesa, ma non tutta la gamification deve essere pienamente attiva. Si dimostra il concetto (reset giornaliero, esperienze acquistabili con Eos) senza costruire ogni meccanismo. Il monitoraggio del consumo dei crediti Google va attivato fin da subito per non trovarsi a secco a metà sviluppo.

## 26. Database VIP per la Sinastria Celeb

Per la Demo bastano 50 VIP minimo, idealmente 150-200 per l MVP, rilevanti per il pubblico (per l Italia: personaggi noti, calciatori, cantanti). Foto da fonti pubbliche a licenza libera, date di nascita verificate solo da fonti primarie perché date errate circolano online e danneggiano la credibilità. Suggerimento per la presentazione: iniziare la Demo dalla Sinastria Celeb inserendo un VIP rilevante per chi è in sala, è il momento che cattura l attenzione. Per evitare problemi di copyright fotografico e di diritto all immagine e di pubblicita, si preferiscono ritratti illustrati e stilizzati nello stile 2.5D dell app al posto delle fotografie reali; in alternativa solo immagini a licenza libera verificata. Il calcolo si basa sulla sola data di nascita, dato non protetto. Ogni risultato porta un disclaimer di satira e intrattenimento, senza implicare rapporti o approvazioni del personaggio. Validazione legale di proprieta intellettuale prima del lancio commerciale, soprattutto per gli Stati Uniti.

## 27. Checklist finale e definizione del punto di stop

La Demo è pronta quando: l intro parte pulita; l onboarding calcola la carta natale reale; i tre Maestri parlano con voce e memoria; i quattro elementi quotidiani funzionano; le nove funzioni distintive sono attive e rifinite; gli effetti visivi e i colori sono in opera; le funzioni Coming soon sono visibili in grigio; la schermata prezzi è presente.

Sotto-insieme prioritario da rifinire al 100% per la presentazione di cinque minuti a Google: intro, onboarding con carta natale, rivelazione del Maestro col soffio, Sinastria Celeb, stesa col ventaglio, Angelo Custode. Questo è il percorso che deve essere perfetto; il resto deve funzionare bene ma è secondario nella demo dal vivo.

Raggiunto il punto di stop, lo scope è congelato e si prosegue verso l MVP completo senza interruzioni.

*Documento operativo definitivo. Insieme al Briefing Progetto e al Master Tecnico, costituisce la guida completa per avviare lo sviluppo di Esoteric Circle.*

## 28. Chiedi ai Maestri nella Demo (con categorie)

Chiedi ai Maestri entra nella Demo come funzione attiva, perché è il cuore dell app. Nella Demo parte dalle domande suggerite per categoria (amore, lavoro, fortuna, successo, relazioni): l utente tocca una domanda pronta, il Maestro risponde con voce Gemini-TTS e card. La domanda in testo libero resta attiva ma in secondo piano. Questo dimostra il cuore relazionale, accelera lo sviluppo e i test e aiuta gli utenti meno esperti. Si conta come funzione trasversale, non riduce le tre funzioni distintive per Maestro.

## 29. Regola grafica trasversale anche nella Demo

Tutte le funzioni attive nella Demo applicano la regola del livello visivo immediato: percentuali animate, barre, grafici a onde, radar, calendari, con micro-animazioni. La Sinastria Celeb in particolare mostra la percentuale grande che sale e le barre per aspetto, perché è il momento clou della presentazione a Google. Questa resa visiva è parte di ciò che fa percepire l app come moderna e non testuale.

## 30. Caligo nella Demo: identità e ali

Caligo va presentato come saggio potente e custode, non come signore oscuro. Usa magia bianca, rossa e blu. Graficamente puo essere alleggerito con ali d angelo per renderlo meno cupo, mantenendo l autorevolezza. Gli Angeli colti e la Cabala restano nel suo dominio. Il suo elemento serale resta La Runa del Tramonto. Tra le sue funzioni distintive in Demo entra l Animale Guida (animale di potere del core shamanism), feature identitaria e virale che si rivela con la nebbia che si dirada, tematicamente coerente col nome Caligo. L animale e fisso per la persona, calcolato da carta natale e archetipo, e si consulta on-demand con la card Messaggio da [nome animale]. Il Sigillo magico personale esce dalle distintive di Demo e resta attivo nell MVP e nel modulo rituali.

## 31. Rituali di Caligo nella Demo e MVP

Se nella Demo l utente chiede a Caligo un rituale, la risposta attinge al database di micro-rituali reali (candela, sigillo, mantra, parola-intenzione), mai inventati. Nella Demo e MVP solo micro-rituali leggeri; i rituali guidati interattivi in Fase C. Sempre con disclaimer. Esclusi i rituali che agiscono sulla volontà di terzi: riformulati come riti di crescita personale, protezione e abbondanza.

## 32. Nuove funzionalità: collocazione per fase

Le funzioni aggiunte all ecosistema entrano nella roadmap, non nella Demo (scope congelato), salvo l Animale Guida che entra in Demo e MVP tra le distintive di Caligo. Collocazione suggerita: Sigillo magico personale attivo nell MVP (uscito dalle distintive di Demo); grafologia esoterica (dominio Aura) in Fase 4 come terza lettura profonda della persona accanto a Costellazione del Viso e analisi dell aura. Oracolo degli Angeli (dominio Medora) in Fase 2: consultazione con estrazione e stesa dal mazzo dei 72 Angeli (modello delle carte oracolari angeliche reali), esito oracolare variabile, distinto dall Angelo Custode identitario fisso e dal suo Messaggio del giorno; riusa il set grafico unico dei 72 Angeli, disclaimer per intrattenimento e crescita personale.

| **Funzionalità** | **Fase** | **Nota** |
| --- | --- | --- |
| Calcolo fertilità | Fase successiva | Forte leva ads, lancio dedicato |
| Bioritmo grafico | Fase successiva (anticipabile) | Calcolo semplice, basso costo, alto impatto visivo |
| Interpretazione sogni | Fase successiva | Popolare e universale |
| Numerologia | Fase successiva | Calcolo semplice |
| Calendario lunare personale | Fase successiva (anticipabile) | Richiamo quotidiano forte |
| Compatibilità tra amici | Fase viralità sociale | Richiede massa critica |
| Oracolo degli Angeli | Fase 2 | Stesa del mazzo dei 72 Angeli (dominio Medora), riusa il set grafico unico; distinto dall Angelo Custode |

Nella Demo queste appaiono in grigio Coming soon dove pertinente, per mostrare la ricchezza dell ecosistema senza svilupparle ora.

## 33. Costi vivi da anticipare (senza crediti startup ancora)

L utente non ha ancora i crediti Google for Startups: servono per candidarsi e per candidarsi serve la Demo. Quindi va anticipato un budget contenuto. Per la Demo l infrastruttura Google è coperta dal trial gratuito di 300 USD per 90 giorni.

| **Voce** | **Costo Demo** | **Nota** |
| --- | --- | --- |
| Infrastruttura Google | ~0 | Trial gratuito 300 USD / 90 giorni |
| Claude (Max con Code) | ~100-200/mese | Per le settimane di sviluppo attivo |
| Leonardo AI (solo se serve come riserva) | ~30-60/mese | Solo periodo produzione asset, poi disdire |
| API astrologica | ~30-40/mese o 0 | Self-hosting Swiss Ephemeris azzera il costo |
| Google Play Console | 25 una tantum | Solo se pubblichi in beta |
| Apple Developer | 99/anno | Rimandabile: demo su Android o simulatore |

Stima totale realistica per la Demo: circa 300-700 euro, concentrati in pochi mesi. Dopo aver ottenuto i crediti startup (fino a 350mila USD per startup AI), infrastruttura e runtime tornano a costo quasi zero. App operativa nel periodo intermedio senza crediti: circa 150-400 euro al mese.

## 34. Stima tempi (indicativa, senza scadenza fissa)

| **Fase** | **Chi** | **Tempo attivo** |
| --- | --- | --- |
| A, account | Utente | Poche ore + 3-7 giorni di attese esterne |
| B, asset | Utente (curatela) + agente (script) | 1-2 settimane utente |
| C, sviluppo | Agente autonomo | 3-6 settimane, utente solo ai 6 checkpoint |

Demo completa: circa 5-9 settimane di calendario con sovrapposizione delle fasi. Stima indicativa, non promessa al giorno: il tempo reale dipende dalle iterazioni per la qualità ultra professionale richiesta.

| **Maestro** | **Funzioni attive nella Demo** |
| --- | --- |
| Medora | Stesa 3 carte col ventaglio; Sinastria Celeb; Carta natale interattiva |
| Aura | Costellazione del Viso (videocamera); Test Archetipo; Meditazione con voce |
| Caligo | Estrazione Rune; Albero della Vita contemplativo; Animale Guida |

## 35. Oroscopo a quattro versioni (in MVP e Demo)

L oroscopo nella Demo mostra le quattro schede Generale, Amore, Carriera, Fortuna, ciascuna con il proprio indicatore visivo di favorevolezza. E leggero e ad alto valore percepito, quindi entra gia nell MVP e nella Demo.

## 36. Roadmap a cinque fasi (collocazione operativa)

Le nuove aree non entrano nella Demo (scope congelato). Collocazione concordata, con le astrologie alternative come valore premium dei Tier 2 e 3.

| **Fase** | **Contenuti chiave** |
| --- | --- |
| MVP | Astrologia occidentale; oroscopo 4 versioni; Costellazione del Viso in Demo; Animale Guida e Messaggio da [nome animale] in Demo; Sigillo magico attivo in MVP |
| Fase 2 (mesi 1-3) | Il Respiro della Luna; Saturn e Solar Return; chiromanzia; sogni; Pet Astrology; Albero dinamico e compatibilita 3 livelli (Tier 3); Affinita Lunare (compatibilita di fase lunare condivisibile); Oracolo degli Angeli (stesa del mazzo dei 72 Angeli, Medora) |
| Fase 3 (mesi 3-6) | Astrologia cinese e vedica (premium Tier 2-3); numerologia; Feng Shui; sinastria avanzata; Cosmic Wrapped |
| Fase 4 (mesi 6-9) | Maya, celtica, egizia, araba (premium); astrocartografia; Cosmic Academy; carte angeliche; analisi aura; grafologia esoterica; rituali guidati |
| Fase 5 (mesi 9-12+) | Cosmic Dating e AR; sogni lucidi; rituali stagionali e Rituale Collettivo Live; Flusso Cosmico; Allineamenti Celesti |

Le astrologie alternative entrano come esclusive premium dei Tier 2 e 3, diventando un motore di conversione verso gli abbonamenti alti.

## 37. La Runa del Tramonto: meccanica serale (Caligo)

L elemento serale di Caligo e La Runa del Tramonto. Meccanica: alle ~18:00 l utente lancia le rune scuotendo il cellulare (con fallback a gesto tattile per i device non abilitati), una runa o un sigillo viene estratto con animazione, e Caligo offre un breve presagio o consiglio runico da portare nel sonno. Chiude il cerchio della giornata nel tono notturno e nella tradizione runica di Caligo. Condivisibile come card. L Angelo Custode e il suo eventuale messaggio appartengono ora a Medora, non piu a Caligo.

## 38. Karma, affermazioni e frequenze: collocazione

Karma (Medora): cornice filosofica trasversale gia dall MVP; Lettura Karmica sui Nodi Lunari in fase successiva. Arte delle convinzioni e affermazioni (Aura): affermazioni quotidiane nell MVP, percorso guidato di convinzioni in fase 2. Frequenze sonore e sound healing (Aura): libreria base 432 e 528 Hz e binaural beats nell MVP a corredo di meditazioni e sleep stories, espansione nelle fasi successive. Tutte applicano la regola grafica trasversale.

## 39. Animale Guida e Messaggio da [nome animale] (Caligo)

L Animale Guida e una feature identitaria di dominio Caligo, radicata nel core shamanism documentato (Michael Harner). Si compone di due strati. Lo strato fisso e l animale di potere in se, calcolato in modo deterministico dalla carta natale incrociata con l archetipo junghiano: e unico e immutabile per la persona, come l Angelo Custode, e non e un oracolo a esito variabile. Si rivela una volta sola con l animazione della nebbia che si dirada, coerente col nome Caligo (nebbia), con asset grafici via Imagen 4 e card condivisibile. Lo strato variabile e il richiamo Messaggio da [nome animale]: una card consultabile on-demand quando l utente vuole, il cui contenuto cambia di giorno in giorno perche calcolato sui transiti del momento, mentre l animale resta sempre lo stesso. L Animale Guida abita il profilo identitario dell utente (Cosmic Passport) accanto all Angelo Custode e all archetipo, e non si sovrappone alla carta natale astrologica tecnica, che ne e solo il motore di calcolo. Entra in Demo e MVP tra le tre funzioni distintive di Caligo, al posto del Sigillo magico. Disclaimer per intrattenimento e crescita personale.

## 40. Grafologia esoterica (Aura)

La grafologia esoterica e una lettura della personalita a partire dalla scrittura a mano, di dominio Aura. Base reale e documentata: la grafologia codificata (sistema Moretti in Italia, Crepieux-Jamin in Francia, Klages in Germania), disciplina metodologica con manuali consolidati. Approccio ibrido come la Costellazione del Viso e la chiromanzia: i tratti grafici sono stabili e coerenti nel tempo per la persona (lettura di fondo), mentre l incrocio quotidiano con i transiti da la sfumatura variabile. L utente scrive una parola, una frase breve o la propria firma sullo schermo col dito: essendo un gesto tattile nativo, qui il problema del fallback sensori non si pone. Il sistema rileva parametri grafici misurabili (dimensione, pressione dove esposta dal device, inclinazione, spaziatura, ritmo e ampiezza del tratto) e li mappa su un database curato di significati grafologici; l AI col sistema ibrido produce il testo nel tono di Aura. Livello visivo immediato: mentre l utente scrive, il tratto si trasforma in linee luminose dorate, i punti chiave si illuminano e compaiono indicatori a barre o anelli (energia, emotivita, razionalita, apertura), e la firma diventa un sigillo personale animato, coerente con la Costellazione del Viso. Collocazione: Fase 4, come terza lettura profonda della persona accanto a Costellazione del Viso e analisi dell aura. Disclaimer per intrattenimento e crescita personale.

## 41. Gating visivo universale e esaurimenti (MVP e tutte le versioni)

Lo stesso gating visivo della Demo vale in pianta stabile in MVP e in tutte le versioni. Tutte le funzioni, comprese quelle dei tier superiori, restano sempre visibili ma in grigio o non attive per chi non vi ha accesso; al tap compare un tooltip del tipo disponibile con l abbonamento e il nome del livello. Per gli esaurimenti giornalieri (reset giornaliero): quando finiscono domande, stese o richieste del giorno, l icona diventa grigia e al tap un tooltip propone due strade, acquistare una richiesta aggiuntiva con gli Eos oppure salire di livello per togliere il limite. Mostrare sempre cio che si sta perdendo e una leva di conversione costante e non invasiva. Realizzato con i feature flag via Firebase Remote Config piu il controllo dell entitlement.

## 42. Tooltip di trasparenza metodologica su ogni responso

Ogni responso espone un piccolo punto interrogativo che al tap apre una nota brevissima sulla tradizione o metodo usato per quel calcolo (per esempio Nodi Lunari per il Karma, personologia di E.V. Jones per il volto, core shamanism per l Animale Guida, effemeridi svizzere per la carta natale). Rafforza professionalita e credibilita, e contenuto statico a costo zero, resta discreto. Convenzione trasversale gia dalla Demo.

## 43. Profondita della risposta e cartomanzia

Profondita della risposta: l utente puo scegliere Breve, Media o Approfondita; nel Free la lunghezza e fissa, la scelta si sblocca dal Tier 1 e la modalita Approfondita e riservata ai livelli superiori. Cartomanzia: piu mazzi selezionabili (Rider-Waite default, Marsiglia, Thoth, solo artwork diverso) e carte che possono uscire dritte o rovesciate, con interruttore Includi carte rovesciate attivo di default. Per la Demo restano attive le funzioni gia congelate; queste convenzioni si applicano pienamente in MVP. Tre chiavi di lettura (in MVP): prima di ogni stesa l utente sceglie il metodo di interpretazione, oltre alla profondita. Chiave predittiva (Medora, divinatoria); chiave di riflessione personale ispirata alla Tarologia di Alejandro Jodorowsky (crescita e consapevolezza, non predittiva, Tarocco di Marsiglia); chiave esoterica e iniziatica (Caligo, archetipi e Albero della Vita). Jodorowsky citato come ispirazione dichiarata, con disclaimer divulgativo. Tutte e tre attive dall MVP; il controllo dei costi e gia garantito dai limiti di stese giornaliere per tier, quindi non e necessario riservare la terza chiave a un tier (resta accessibile a tutti come differenziatore).

## 44. I Sigilli del Cammino: traguardi del Cosmic Journal

Sistema di traguardi gamificato dei tre sentieri del Cosmic Journal, modello tessera punti. Circa 50 mini-traguardi per sentiero (i Sigilli) piu cinque grandi traguardi a 10, 20, 30, 40, 50 sempre visibili in anticipo. Ogni mini-traguardo genera una card condivisibile e accende sempre l icona del Sigillo al raggiungimento del traguardo, cosi nessuno resta escluso, compresi gli utenti senza social; la condivisione assegna un bonus Eos graduato per valore verificabile dell azione (massimo per invito amico che porta un download, alto per social pubblico, medio per condivisione privata verificabile, zero se nessuna azione ma con Sigillo comunque acceso). Curva prudente: mini 10 Eos (primi tre a 20); grandi 80, 150, 250, 400, 600. Circa 1.960 Eos per sentiero, 5.880 sui tre, una tantum diluita nel tempo; resta il tetto giornaliero sulle condivisioni premiate. Primi tre Sigilli aggancio trasversali: crea carta natale, primo completamento Cosmic Passport, prima Sinastria Celeb.

Visualizzazione verticale con apertura dall alto: all ingresso si mostra il traguardo 50 in piena luce, poi lo scorrimento plana verso il basso e si ferma sul punto raggiunto. Caligo: Albero della Vita, mini-traguardi Frutti dell Albero, grandi traguardi Sefirot Maggiori fino a Keter. Medora: Costellazione personale, mini-traguardi Stelle del Cammino, grandi traguardi Costellazioni. Aura: Fiore di Loto, mini-traguardi Petali del Risveglio, grandi traguardi Fioriture. Attivazione per tier: journal e Sigilli attivi nel Free fino al ventesimo traguardo; dal ventunesimo il journal completo si sblocca dal Tier 1, con gli Eos gia accumulati che restano nel wallet. Nella Demo il Cosmic Journal resta mostrato con riempimento Coming soon (scope congelato); il sistema completo dei Sigilli e attivo dall MVP.

## 45. Modulo memoria persistente: Specchio dell'Anima, Filo dei Temi, Diritto all'oblio

La memoria e globale e unica, condivisa dai tre Maestri con tre lenti (Medora destino, Aura energia, Caligo simbolo), senza confidenze riservate al singolo Maestro. Scrive sempre per tutti dal primo secondo, rivela a strati per tier, non cancella mai: salire di tier sblocca memoria gia presente (leva di conversione), il downgrade lascia i ricordi latenti e intatti. Lo Specchio dell'Anima e un pulsante dedicato che mostra la sintesi dell'utente vista dai tre Maestri, breve nel Free e biografia evolutiva nei tier alti, card virale a costo basso. Regola anti-invenzione come requisito architetturale: si passano al Maestro solo i ricordi recuperati da pgvector, mai inventati, con ponte allo Specchio per le domande di riepilogo. In MVP entrano Il Filo dei Temi (richiamo dei temi ricorrenti) e il Diritto all'oblio (cancellazione selettiva, obbligo GDPR come feature di fiducia). Restano in roadmap Fase 2 la Linea del Tempo dell'Anima, la Lettera dal Maestro, la Capsula del Tempo e il Momento di sintesi annuale, per non violare il congelamento dello scope Demo.
