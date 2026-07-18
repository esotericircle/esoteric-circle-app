# STATO VIVO, Esoteric Circle

Questo file, `docs/STATO_VIVO.md`, e' la fonte sovrana unica dello stato del progetto, la fonte mutabile canonica. La copia MEMORIA_E_STATO nel Project di Mauro e' solo uno specchio: in caso di conflitto fra le due, vince sempre STATO_VIVO. Le due copie vanno tenute allineate, ma la sovranita' sta qui. Chiunque lavori, Claude Code o l'Architetto in Cowork, lo legge per primo e lo aggiorna dopo aver lavorato. Sopra STATO_VIVO c'e' solo la realta': in caso di dubbio prevale il codice reale, non questo file: quando affermi qualcosa, prima verifica sul filesystem e sul repo.

Regola numero uno: prima di dire cosa e' fatto, cosa manca o quanti sono, VERIFICA. Leggi il file, conta la cartella, guarda il branch. Non parlare a memoria. Questo file esiste perche' due errori non si ripetano: la perdita del recupero carta natale per lavoro su branch divergenti, e l'aver parlato a stima invece di leggere lo stato reale.

## Ambiente e accessi verificati

- Repository: esotericircle/esoteric-circle-app. Branch canonico `claude/esoteric-circle-master-order-e798aj`, contiene tutto. Branch storici da non cancellare: `claude/esoteric-circle-c1-bd5xtr`, `claude/cosmo-profondita-home-e798aj` (commit b7be8f6). Cercare su altri branch prima di reimplementare.
- Working tree locale di Mauro: `C:\Users\user\Desktop\esoteric-circle-app`. Contiene il repo piu' la cartella `output/` con gli asset sorgente e gli script Python che li generano. La cartella `output/` non e' versionata su Git.
- L'Architetto in Cowork raggiunge il PC di Mauro con un ponte (device desktop-aktdgut) e legge il repo su GitHub in sola lettura. Prima di chiedere a Mauro dove sta un file, lo cerca da solo.

## Asset grafici, conteggio verificato a mano il 17 luglio 2026

Prodotti da Mauro, in `output/`, pubblicati su CDN dagli script publish. Conteggio dei pezzi finiti al primo livello, contati cartella per cartella:

- Tarocchi Rider-Waite: mazzo COMPLETO 78 su 78 (22 Maggiori piu' 56 Minori), piu' dorso Medora e cartella interni.
- Angeli custodi: 72 su 72, piu' dorso Medora e cartella interni.
- Ritratti VIP: 50 finiti, piu' cartella sorgenti _raw e un contact sheet, che non si usa. Il numero 50 coincide col CLAUDE.md.
- Rune buone rune_bone: 24 su 24. La vecchia serie rune (24) e' superata, non si usa.
- Animali guida: 12 su 12.
- Cristalli: 12 su 12, con manifest.

Cosa e' davvero nel bundle dell'app: il `pubspec.yaml` dichiara come asset solo `assets/`, `assets/data/`, `assets/fonts/`, `assets/ritual_backgrounds/`, `brand_assets/avatars/`, `brand_assets/santuario/`. In `brand_assets/` ci sono i tre avatar dei Maestri (una posa ciascuno), il tempio del Santuario, un intro di prova, i fondali dei riti. Nessuna famiglia esoterica e' dentro il bundle. Quindi il lavoro che resta sugli asset non e' disegnare, e' importare da `output/` a `brand_assets/`, dichiarare nel pubspec, agganciare ai widget, oppure servire dal CDN a runtime.

La fonte macchina dello stato asset e' `docs/stato_asset.json`. La sua parte bundle_versionato e' sotto lucchetto di CI: `test/stato_asset_test.dart` verifica che le cartelle asset dichiarate nel pubspec e i conteggi dei file in `brand_assets/` coincidano col manifest, e la spunta verde cade se divergono. La parte output_non_versionato non e' verificabile in CI, perche' `output/` non e' su Git: la controlla l'agente revisore-stato dal ponte col PC di Mauro.

Asset ancora da produrre davvero: i mezzi busti animati dei tre Maestri per il Santuario, il gatto grigio di Medora.

## Stato per area

Legenda stato: prodotto (esiste), agganciato (collegato e gira nell'app), verificato a video (guardato su device o simulatore in questa fase). Le voci "fatto" qui sotto sono prodotte e agganciate secondo i report di Code, la conferma a video su device resta da rifare al prossimo checkpoint visivo.

- Onboarding Il Risveglio: fatto (carta natale ornata, cielo di nascita J2000, cosmo profondo, risonanza, rito del soffio, ponte identita' con NatalFacts, accenti corretti a ce5b75e). Prodotto e agganciato; da riconfermare a video al prossimo checkpoint visivo.
- Cosmo profondo: fatto. Santuario Il Cerchio: fatto nella messa in scena base. Prodotto e agganciato; da riconfermare a video al prossimo checkpoint visivo.
- Doni del Giorno: Alba e Soffio validati; Oracolo, Runa, Sogno presenti.
- Funzioni live nel function_shelf: Sinastria VIP, Oracolo del Giorno, Runa del Tramonto, Meditazione. Non ancora live: Stesa a Tre Carte, Test Archetipo, Costellazione del Viso. La fonte macchina di questo stato e' `docs/stato_funzioni.json`, allineata al codice da `test/stato_funzioni_test.dart` nel verde della CI: se il manifest e `lib/core/santuario/function_shelf.dart` divergono, la spunta verde cade.
- Backend carta natale FreeAstroAPI: callable Firebase natalChart costruita (162b94b), con base URL gia' corretto a `https://api.freeastroapi.com` (340fd4a). Non ancora deployata: secret in Secret Manager, App Check e `firebase deploy --only functions` restano da fare a mano dal PC di Mauro.
- Contenuti testuali: undici Corpus scritti nel Project, circa 620 voci verificate sulle tradizioni, non ancora agganciati al codice. Mancano i rovesciati dei tarocchi, i merkstave delle rune, il dettaglio per singolo angelo.

## Fronti aperti, in ordine

1. FreeAstroAPI: base URL gia' corretto (340fd4a); restano il secret in Secret Manager, App Check e `firebase deploy --only functions` dal PC di Mauro.
2. Import asset: da `output/` a `brand_assets/` piu' pubspec e aggancio. Regole: rune_bone non rune; non il contact sheet VIP; fronti delle carte; nomi minuscoli; ridimensionare i pesanti.
3. Contenuti mancanti: rovesciati dei tarocchi, merkstave delle rune, dettaglio dei 72 angeli da fonte verificata.
4. Aggancio dei Corpus e degli asset ai widget (NatalPoetics, Oracolo, domini dei Maestri).
5. Attivare le tre funzioni non live per completare le nove distintive del checkpoint C5.
6. Chat viva dei Maestri, checkpoint C3.
7. Chiusura Demo, checkpoint C6: economia Eos, prezzi, feature flag, badge Coming soon.

## Regole ferree

Prima di parlare, verificare. Italiano sempre. Mai il trattino lungo. Mai una proposizione dopo la virgola con "e". Accenti veri nei testi a video. Tradizioni reali con disclaimer una sola volta. Consapevolezza, mai fatalismo, mai giudizio. Runtime Gemini e Vertex, mai le API Anthropic. Nessun segreto nel repo. Non creare o aggiornare codice o documenti senza conferma di Mauro, mai come addendum, non condensare. Modello giusto al task giusto.
