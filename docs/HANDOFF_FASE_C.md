# Dossier di Handoff Fase C, Esoteric Circle

Documento operativo che porta dallo stato attuale all'avvio dello sviluppo autonomo con Claude Code. Non sostituisce i quattro briefing, che restano la fonte di verita' completa e non vanno condensati. Qui si raccoglie cio' che serve all'agente per partire allineato con il checkpoint C1.

## 1. Stato dell'ambiente di sviluppo (PC Windows)

Completato e verificato:

- Node.js, npm e Git installati e funzionanti.
- Flutter stable installato, flutter doctor a posto per Android (toolchain, licenze).
- Android Studio con Android SDK e command-line tools. Emulatore con accelerazione hardware rinviato: ai checkpoint si usera' un device Android reale via USB.
- Claude Code installato e autenticato sull'account Claude dedicato (Max 5x).
- Firebase CLI e Google Cloud CLI installati e autenticati sull'account cloud@esotericircle.app, progetto esoteric-circle.
- Repository esoteric-circle-app clonato in locale e collegato.
- Asset base versionati in brand_assets (tre avatar e intro).
- Segreti protetti: .gitignore aggiornato, cartella .secrets ignorata da Git, vault in locale, chiavi esposte ruotate.

Visual Studio con i componenti C++ resta segnalato da flutter doctor ma non serve, riguarda solo le app desktop Windows.

## 2. Stato Fase A (account e credenziali)

Quasi completa.

- Identita' e Google Cloud: pronti. Progetto esoteric-circle, org cloud-org, billing trial 300 USD attivo fino a circa il 23/09/2026, regione europe-west1.
- Firebase: pronto, piano Blaze sul trial, Firestore Standard e Storage in europe-west1, Remote Config con demo_mode pubblicato. Registrazione app Android e iOS e Crashlytics e Messaging rinviati alla Fase C.
- API astrologica: FreeAstroAPI piano Entry attiva.
- Claude: account dedicato Max 5x pronto.
- GitHub: repository privato pronto.
- Gemini e Google AI Studio: chiave presente (ruotata dopo l'esposizione, la nuova va usata via Secret Manager in produzione, mai in chiaro).

Unico blocco esterno: gli account Store (Apple Developer 99/anno e Google Play Console 25 una tantum) sono in attesa del codice D-U-N-S per Esoteric Circle SRLS, pratica gratuita che richiede fino a circa 30 giorni. Non blocca lo sviluppo, blocca solo la pubblicazione sugli store.

## 3. Stato Fase B (asset)

Famiglie grafiche statiche completate e validate con Nano Banana Pro su Vertex: 78 tarocchi piu' dorso, 72 Angeli piu' dorso, 24 rune, 12 cristalli, 50 ritratti VIP, 12 animali guida. Motore, metodo (interno multicolore che riempie la finestra, overlay cornice madre, cartigli e glifi e nomi a runtime) e bucket (master privato piu' CDN pubblico, europe-west1) consolidati.

Ancora aperto, da chiudere al checkpoint C3 vedendo gli avatar montati nell'app:

- Armonizzazione dello stile di Caligo (fotografico) verso Medora e Aura (dipinti), mantenendo il volto.
- Luce di contorno (rim light dorato o rosso) e alone per staccare Caligo dagli sfondi scuri.
- Crop a mezzo busto dei tre Maestri per chat e bottom bar, tenendo il full body come master.
- Animazione degli avatar a stati (idle, speaking, greeting) da esportare per Flutter.
- Verifica finale del canale alpha e dei bordi (pelliccia e capelli di Caligo).

Intro cinematografica: pronta e versionata (Intro-Test-1.mp4).

## 4. Struttura del repository proposta

Alla creazione dello scaffolding, Claude Code organizza il codice cosi':

- `lib/core/` configurazione, tema, costanti, routing, gestione feature flag ed entitlement.
- `lib/design_system/` token 2.5D (primitivi, semantici, di componente), palette dei tre Maestri, tipografia, glassmorphism, shader, componenti riutilizzabili del data-viz layer.
- `lib/features/` una cartella per dominio funzionale (onboarding, home, maestri, oracoli, astrologia, benessere, journal, sinastria).
- `lib/services/` client verso Firebase, AI Gateway, motore astrologico, storage, memoria.
- `assets/` asset consumati dall'app a runtime (icone, lottie, shader, riferimenti).
- `brand_assets/` sorgenti di brand versionati (avatars, intro). Gia' presente.
- `docs/` questo dossier e i quattro briefing.

## 5. Design system 2.5D, palette dei Maestri

- Medora: blu con inserti e linee oro. Per fondi e testo usare un blu profondo, l'oro su blu chiaro ha contrasto debole (WCAG).
- Caligo: rosso con inserti e linee oro.
- Aura: verde smeraldo con inserti e linee oro.
- Stato neutro: viola scuro con oro, oppure nero notte stellato.

Al cambio di Maestro l'intera interfaccia fa una dissolvenza cromatica sul colore del Maestro attivo. Sfondi dei tre Maestri in stile pittorico atmosferico full-bleed senza cornice, con spazio scuro centrale e inferiore per l'interfaccia e piu' piani per la parallasse. Tutti gli effetti sono regolati dal Quality Tier dinamico.

## 6. Mappa dei feature flag per la Demo (checkpoint C6)

Attive nella Demo:

- Intro cinematografica, Onboarding Il Risveglio con carta natale, rivelazione del Maestro col soffio (con fallback gesto).
- Quattro elementi quotidiani: Rito dell'Alba (a rotazione), Soffio del Destino (Aura), Oracolo del Giorno giroscopico (Medora), La Runa del Tramonto (Caligo).
- Medora: stesa a tre carte col ventaglio, Sinastria Celeb, carta natale interattiva, Angelo Custode.
- Aura: Costellazione del Viso (videocamera), Test Archetipo, meditazione con voce.
- Caligo: estrazione Rune, Albero della Vita contemplativo, Animale Guida.
- Chiedi ai Maestri con categorie, chat con voce e memoria pre-popolata demo.
- Home Il Santuario, colori, parallasse, effetti.
- Schermata prezzi tier (pagamento non integrato in demo).

Coming soon (visibili in grigio nella Demo):

- Cosmic Journal a tre sentieri (struttura visibile, riempimento dinamico Coming soon).
- Sezione Oracoli estesa (I-Ching, pendolo, cristalli, fondi di caffe), chiromanzia ibrida.
- Economia Eos e gamification completa, mostrate in parte.

Assenti o grigio (fasi successive): Cosmic Dating e AR, Pet Astrology, tradizioni non occidentali, e tutto il resto della roadmap a cinque fasi.

Dettaglio completo di stati e limiti per tier nei briefing (Briefing Operativo sezione 7 e Briefing Progetto Parte IV).

## 7. Manifest degli asset

Sorgenti nel repo:

- `brand_assets/avatars/` Medora-1.png, Aura-1.png, Caligo-1.png (PNG alpha).
- `brand_assets/intro/` Intro-Test-1.mp4.

Famiglie di brand su bucket Google (master privato piu' CDN pubblico, europe-west1), da collegare a runtime:

- Tarocchi: 78 carte piu' dorso. Cornice madre oro e blu Medora, cartigli vuoti, numero romano e nome a runtime. Carte dritte e rovesciate (rotazione 180 gradi, doppia variante di significato).
- 72 Angeli piu' dorso: set unico in palette Medora. Usati per Angelo Custode (Medora) e per l'Oracolo degli Angeli (Fase 2).
- 24 rune: pietre a contorni irregolari, solo glifo inciso d'oro, nome latinizzato e linea a runtime.
- 12 cristalli: colore naturale reale e abito nativo distinto, oggetto isolato PNG alpha.
- 50 ritratti VIP: cornice unica universale a finestra ad arco, glifo e nome a runtime, solo data di nascita, mai foto reali.
- 12 animali guida: metallici multicolore, oggetto isolato, mappati sui 12 archetipi junghiani.

Regola i18n trasversale: un solo set di artwork per tutte le lingue, i testi si sovrappongono a runtime.

## 8. Scope del checkpoint C1

Cosa costruisce l'agente:

- Scaffolding del progetto Flutter, con la struttura di cartelle della sezione 4.
- Design system 2.5D di base: token, palette dei tre Maestri, tipografia, primi componenti.
- Navigazione principale e Home Il Santuario navigabile.
- Meccanismo dei feature flag via Remote Config e degli stati delle funzioni (attiva, Coming soon, premium bloccata).
- Cambio di Maestro con dissolvenza cromatica del tema.

Cosa vede Mauro alla pausa C1: l'app che parte, la home navigabile, le funzioni non ancora pronte visibili in grigio, i colori dei Maestri che cambiano.

Criterio di uscita: l'app compila e gira su device reale, la navigazione di base funziona, il sistema di feature flag e' operativo.

## 9. Sequenza completa dei checkpoint

- C1: scaffolding, design system, navigazione, feature flag, colori dei Maestri.
- C2: intro piu' onboarding Il Risveglio piu' carta natale via FreeAstroAPI piu' soffio del Maestro.
- C3: i tre Maestri con avatar animati, chat AI Gemini, voce Gemini-TTS, memoria pre-popolata demo. Qui si chiudono le rifiniture avatar della sezione 3.
- C4: i quattro elementi quotidiani, incluso Oracolo giroscopico e Runa del Tramonto.
- C5: le tre funzioni per Maestro (stesa col ventaglio, Sinastria Celeb, carta natale; Costellazione del Viso, Test Archetipo, meditazione; Rune, Albero contemplativo, Animale Guida).
- C6: Cosmic Journal a tre sentieri (riempimento Coming soon), economia Eos, rifinitura, feature flag finali. Demo presentabile a Google.

Tra un checkpoint e l'altro lo sviluppo e il debug procedono senza pause.

## 10. Come applicare questo handoff (prossima sessione al PC)

1. Copiare `CLAUDE.md` nella radice del repository esoteric-circle-app.
2. Creare la cartella `docs/` e mettervi questo dossier e i quattro briegfing (in markdown o testo, cosi' Claude Code li legge).
3. Commit e push.
4. Aprire Claude Code nella cartella del progetto e avviare il checkpoint C1.

I quattro briefing vanno portati nel repo perche' Claude Code legge il repository, non il progetto chat. Posso generare io le versioni markdown fedeli dei quattro briefing, senza condensarle, come passo successivo su tua conferma.

## 11. Decisioni aperte e rischi

- Motore astrologico: FreeAstroAPI attiva; valutare in seguito il self-hosting della libreria Swiss Ephemeris per azzerare il costo ricorrente a scala.
- Consumo crediti Claude in sviluppo: modello giusto per task giusto, pause solo ai sei checkpoint.
- Costo AI a runtime: sistema ibrido, context caching, pre-generazione batch, Gateway che evita il 70% delle chiamate LLM.
- Store bloccati sul D-U-N-S: la Demo puo' girare su device reale o simulatore senza account store.
- Rifiniture avatar (sezione 3) da chiudere al C3.
