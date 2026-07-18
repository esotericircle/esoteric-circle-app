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

Cosa e' davvero nel bundle dell'app: il `pubspec.yaml` dichiara come asset `assets/`, `assets/data/`, `assets/fonts/`, `assets/ritual_backgrounds/`, `brand_assets/avatars/`, `brand_assets/santuario/`, piu' le sei famiglie esoteriche in `assets/img/<famiglia>/` e `assets/img_thumb/<famiglia>/`. In `brand_assets/` ci sono i tre avatar dei Maestri (una posa ciascuno), il tempio del Santuario, un intro di prova, i fondali dei riti. Le sei famiglie ora SONO nel bundle, in WebP a due misure: piena in `assets/img/` (a fuoco o ingrandita) e miniatura in `assets/img_thumb/` (viste con piu' carte), per un totale di circa 77,6 MB, con i dorsi inclusi (79 tarocchi, 73 angeli, 50 ritratti VIP, 24 rune_bone, 12 animali, 12 cristalli). Niente streaming per la Demo: la Demo apre tutto in locale. I master PNG originali (825 MB) restano solo in `output/` sul PC di Mauro, fuori dal repo. L'aggancio dell'arte alle voci dei cataloghi passa dal resolver `lib/core/assets/family_image.dart`. Stato reale verificato dell'aggancio dopo la modellazione dei Corpus (`docs/corpus/`): cinque famiglie su sei ora hanno il catalogo nel codice con lo stem legato all'arte.

- Rune: 24 su 24. Tutte le voci di `kElderFuthark` in `lib/core/rituals/runes.dart` portano lo stem (ordine Futhark, slug del file uguale al nome runa) piu' i testi dritto e ombra dal Corpus. La Runa del Tramonto mostra l'arte incisa reale della pietra, con ripiego sul glifo disegnato se manca. Accesa a video nel rito.
- Tarocchi: 78 su 78. Nuovo catalogo `lib/core/tarot/tarot_card.dart` (`TarotDeck.cards`), 22 Maggiori legati per nome nell'ordine Rider-Waite piu' 56 Minori (Asso 01, Fante 11, Cavaliere 12, Regina 13, Re 14), ognuno con dritto e rovescio dal Corpus, piu' dorso `tar_rw_dorso_medora_v1`. Catalogo modellato e arte legata; nessuna schermata live lo consuma ancora.
- Animali guida: 12 su 12. Nuovo catalogo `lib/core/rituals/animal_catalog.dart` (`AnimalCatalog.animals`), i dodici con arte, stem `ani_<slug>_v1`. I cinque animali senza arte del Corpus restano fuori dal catalogo immagini. Catalogo modellato e arte legata; nessuna schermata live lo consuma ancora.
- Cristalli: 12 su 12. Nuovo catalogo `lib/core/rituals/crystal_catalog.dart` (`CrystalCatalog.crystals`), ognuno con chakra, elemento, testo e stem dal Corpus. Catalogo modellato e arte legata; nessuna schermata live lo consuma ancora.
- VIP: 50 su 50. `VipCatalog.vips` in `lib/core/synastry/vip_catalog.dart` ora porta le 50 voci reali da `docs/corpus/vip.json`, ognuna con nome, stem e segno solare. La Sinastria VIP e' cablata con `FamilyImage`: miniatura nel selettore, ritratto pieno sul polo a fuoco. Accesa a video nella schermata.
- Angeli: 72 su 72 nel bundle, fuori dalla Demo. Non modellati in questo passaggio, restano senza catalogo nel codice: nessuno stem legato finche' il Corpus angeli non viene modellato.

La fonte macchina dello stato asset e' `docs/stato_asset.json`. La sua parte bundle_versionato e' sotto lucchetto di CI: `test/stato_asset_test.dart` verifica che le cartelle asset dichiarate nel pubspec coincidano col manifest, che i conteggi dei file in `brand_assets/` coincidano, e che i conteggi delle sei famiglie coincidano sia nelle piene sia nelle miniature; se sposti o togli anche un solo file la spunta verde cade. La parte output_non_versionato non e' verificabile in CI, perche' `output/` non e' su Git: la controlla l'agente revisore-stato dal ponte col PC di Mauro.

Asset ancora da produrre davvero: i mezzi busti animati dei tre Maestri per il Santuario, il gatto grigio di Medora.

## Stato per area

Legenda stato: prodotto (esiste), agganciato (collegato e gira nell'app), verificato a video (guardato su device o simulatore in questa fase). Le voci "fatto" qui sotto sono prodotte e agganciate secondo i report di Code, la conferma a video su device resta da rifare al prossimo checkpoint visivo.

- Onboarding Il Risveglio: fatto (carta natale ornata, cielo di nascita J2000, cosmo profondo, risonanza, rito del soffio, ponte identita' con NatalFacts, accenti corretti a ce5b75e). Prodotto e agganciato; da riconfermare a video al prossimo checkpoint visivo.
- Cosmo profondo: fatto. Santuario Il Cerchio: fatto nella messa in scena base. Prodotto e agganciato; da riconfermare a video al prossimo checkpoint visivo.
- Doni del Giorno: Alba e Soffio validati; Oracolo, Runa, Sogno presenti.
- Funzioni live nel function_shelf: Sinastria VIP, Oracolo del Giorno, Runa del Tramonto, Meditazione. Non ancora live: Stesa a Tre Carte, Test Archetipo, Costellazione del Viso. La fonte macchina di questo stato e' `docs/stato_funzioni.json`, allineata al codice da `test/stato_funzioni_test.dart` nel verde della CI: se il manifest e `lib/core/santuario/function_shelf.dart` divergono, la spunta verde cade.
- Backend carta natale FreeAstroAPI: callable Firebase natalChart costruita (162b94b), con base URL gia' corretto a `https://api.freeastroapi.com` (340fd4a). Non ancora deployata: secret in Secret Manager, App Check e `firebase deploy --only functions` restano da fare a mano dal PC di Mauro.
- Contenuti testuali: undici Corpus scritti nel Project, circa 620 voci verificate sulle tradizioni. Cinque Corpus ora modellati e in `docs/corpus/` e legati al codice (tarocchi con dritto e rovescio, rune con dritto e ombra, animali, cristalli, VIP). Manca la modellazione del dettaglio per singolo angelo.

## Fronti aperti, in ordine

1. FreeAstroAPI: base URL gia' corretto (340fd4a); restano il secret in Secret Manager, App Check e `firebase deploy --only functions` dal PC di Mauro.
2. Import asset: da `output/` a `brand_assets/` piu' pubspec e aggancio. Regole: rune_bone non rune; non il contact sheet VIP; fronti delle carte; nomi minuscoli; ridimensionare i pesanti.
3. Contenuti mancanti: dettaglio dei 72 angeli da fonte verificata e loro modellazione. I rovesciati dei tarocchi e i merkstave delle rune ora sono modellati nei cataloghi (`tarot_card.dart`, `runes.dart`).
4. Alcuni cristalli sono da rifare grezzi: Medora preferisce le pietre grezze. Il catalogo dodici su dodici e' modellato e legato all'arte, ma alcune arti vanno risostituite con la versione grezza.
5. Aggancio dei Corpus e degli asset ai widget (NatalPoetics, Oracolo, domini dei Maestri). Cataloghi tarocchi, animali e cristalli modellati e legati all'arte, ma ancora senza schermata live che li consumi.
6. Attivare le tre funzioni non live per completare le nove distintive del checkpoint C5.
7. Chat viva dei Maestri, checkpoint C3.
8. Chiusura Demo, checkpoint C6: economia Eos, prezzi, feature flag, badge Coming soon.

## Regole ferree

Prima di parlare, verificare. Italiano sempre. Mai il trattino lungo. Mai una proposizione dopo la virgola con "e". Accenti veri nei testi a video. Tradizioni reali con disclaimer una sola volta. Consapevolezza, mai fatalismo, mai giudizio. Runtime Gemini e Vertex, mai le API Anthropic. Nessun segreto nel repo. Non creare o aggiornare codice o documenti senza conferma di Mauro, mai come addendum, non condensare. Modello giusto al task giusto.
