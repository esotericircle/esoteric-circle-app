# RAPPORTO DELL'ORDINE FX, IL RESPIRO DELLA LUNA

16 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_FX_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FX_MANIFESTO.md`, 13 voci: 5 chiuse, 8 aperte in attesa di verifica, 0 da fare. Ramo `claude/esoteric-circle-master-order-e798aj`, eseguito a ordine FW consegnato (commit e86d09ef, verde di GitHub). Nessuna build, nessuna chiamata a pagamento, nessun dato di produzione toccato (R2, R3, R4).

Lavoro diviso fra Code e sei agenti in worktree, uniti nel ramo: l'estensione astronomica (distanza, sorgere/tramonto, bussola), gli asset, il Dial-A-Moon, il respiro e la collana, la bussola con la parola di Medora e gli avvisi, Respiriamo insieme coi piani e il listino. Code ha fatto la saldatura finale: la "Luna di quest'ora" con i suoi numeri, il tempo sotto il dito, le porte fra le arti, la guardia della grafica dipinta, il manifesto, il rapporto, STATO_VIVO e il registro delle guardie.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FX.00, l'idea | `lib/core/arts/art_catalog.dart` |
| FX.01, gli asset nel ramo | `docs/collaudo/FX/fx01_asset.txt` |
| FX.07, la parola di Medora | `test/la_parola_di_medora_del_respiro_test.dart` |
| FX.11, la porta | `test/art_catalog_test.dart` |
| FX.12, la consegna | `docs/ordini/RAPPORTO_ORDINE_FX.md` |

## LE VOCI APERTE E CHE COSA ASPETTANO

| voce | che cosa e' fatto | che cosa aspetta |
|---|---|---|
| FX.02, la scena | video, regia, ripieghi | il fondatore, sul telefono: il video vero |
| FX.03, la Luna di quest'ora | foto vera, numeri, tempo sotto il dito | il fondatore, sul telefono: la foto vera dalla NASA, il trascinamento |
| FX.04, il respiro | tempi, gesto doppio, perla | il fondatore, sul telefono: il microfono vero |
| FX.05, la collana | perle, consegna, ricucitura (locale) | il fondatore, sul telefono: la consegna vera; la pubblicazione della porta che vende la ricucitura |
| FX.06, la bussola | ago, scia, ripiego | il fondatore, sul telefono: i sensori veri |
| FX.08, gli avvisi | tre avvisi, fascia di quiete | il fondatore, sul telefono: una notifica vera |
| FX.09, Respiriamo insieme | sei porte server scritte, modelli pronti | la pubblicazione delle porte; la UI del contatore e della card a due, non costruita |
| FX.10, i piani e gli Eos | matrice, listino | la pubblicazione delle porte che spendono gli Eos |

## LE PREMESSE, COL COMANDO CHE LE HA VERIFICATE

Tutte vere sulla testa del ramo, verificate prima di toccare il codice.

- **P1, vera.** `D:\Clienti Roogly\Rituali Cartomanzia\App\Respiro della Luna Scena\` contiene esattamente i file dichiarati: il video della scena e i tre fotogrammi alla radice, `Collana\` con sette pezzi, `Bussola\` con tre, `Consegna\` col video e i due fotogrammi, `Lavoro\` con gli originali (verificato con `ls`).
- **P2, vera.** `lib/core/lunario/il_motore_lunare.dart` e `il_giorno_lunare.dart` sono il motore lunare in un punto solo, come l'ordine FV voce FV.04 li ha lasciati.
- **P3, vera.** `lib/core/lunario/le_lune_della_nasa.dart` porta le trenta lune vere, citate in `lib/core/legal/fonti_dei_dati.dart`.
- **P4, vera.** `lib/core/arts/art_catalog.dart` portava `lunology` con `ArtState.inArrivo` e un teaser della vecchia sezione 38.
- **P5, vera.** `lib/services/breath_detector.dart` esiste, usato dal Soffio del Destino con permesso dichiarato su Android e iOS.
- **P6, vera.** `lib/core/motion/l_orientamento_del_telefono.dart` legge la bussola e l'inclinazione da `sensors_plus`.
- **P7, vera.** `lib/core/astro/luogo_attuale.dart` da' il luogo della persona.
- **P8, vera.** `lib/services/avvisi_locali.dart` e' il punto degli avvisi del telefono.
- **P9, vera.** `lib/core/entitlement/tier.dart`: free, tier1, tier2, tier3, Viandante e Iniziato nei nomi del fondatore.
- **P10, vera.** `lib/features/scene/la_scena_in_video.dart` porta il lettore e la regia comuni.
- **P11, vera.** `lib/core/cerchio/il_cerchio_sociale.dart` e `functions/src/il_cerchio_sociale.ts` portano gli amici del Cerchio.
- **P12, vera.** `docs/ordini/` non conteneva nessun `ORDINE_FX_*` prima di questo ordine.

## VOCE PER VOCE, LE SCELTE DI CODE CON LA RAGIONE

- **FX.00.** Le tre righe della differenza fra Calendario Lunare e Respiro sono nel teaser nuovo di `art_catalog.dart`, non un documento a parte: cosi' restano quello che l'utente legge davvero, non una nota interna che puo' divergere.
- **FX.01.** `tool/gli_asset_dell_ordine_fx.py`, sul modello di `gli_asset_dell_ordine_fw.py`: stesso metodo di ricompressione (H.264 CRF 26, preset slow, AAC 96 kbit/s), stessa conversione WebP con l'alfa verificato pixel per pixel. Sottocartelle `collana/` e `bussola/` dentro `assets/img/respiro_della_luna/`, per tenere separati i due gruppi di asset senza inventare una convenzione nuova.
- **FX.02-03-04.** Le tre voci vivono sulla stessa schermata perche' sono la stessa esperienza: separarle in tre schermate avrebbe moltiplicato le transizioni per un gesto che il fondatore ha descritto come uno solo, l'apertura del Respiro. **Il tempo sotto il dito scorre su una striscia propria, non sulla Luna**: tenere premuto per respirare (FX.04) e trascinare per scorrere il tempo (FX.03) sono due gesti che, sullo stesso punto di contatto, si confonderebbero al primo tocco. **Il Dial-A-Moon ha un timeout di 4 secondi** e ricade sempre sul ripiego locale: l'app non deve mai restare in attesa di una rete che non risponde.
- **FX.05.** Il nome del ciclo, "Collana di \<mese\>", e' il mese della Luna nuova che apre il ciclo: un nome semplice, letto una volta, che non chiede alla persona di contare le lunazioni. **La ricucitura resta locale**: nessuna porta server la vende ancora (R3), e la schermata non finge una spesa che non succede (vedi "scelte sui prezzi" sotto).
- **FX.06.** La soglia di aggancio della bussola, 12 gradi di separazione angolare vera, sta nel mezzo della forchetta 10-15 della voce: il magnetometro grezzo di un telefono senza la taratura di sistema sbaglia facilmente di qualche grado, e una soglia piu' stretta avrebbe fatto sfarfallare l'incontro.
- **FX.07.** Cercato con WebSearch un sistema di significati documentato per i trenta giorni lunari nella tradizione popolare europea (16 ottobre 2026, "30 lunar days meanings folklore age of the moon documented source", "lunar day meanings folklore"): nessuna fonte seriamente citabile. Il tithi induista (wisdomlib.org, ficino.sourcelibrary.org) nomina solo i primi quindici giorni a cicli di tre ed e' un'altra tradizione: non entra. La terza riga resta il solo numero.
- **FX.08.** La soglia della Superluna, 361.885 km, e' il criterio di Richard Nolle (1979), verificato il 16 ottobre 2026 come la definizione piu' citata in italiano (GreenMe, MeteoWeb, che a loro volta citano l'UAI e Timeanddate); non e' un criterio dell'International Astronomical Union, ma e' quello che il pubblico italiano legge quando sente "Superluna". Fascia di quiete 23-7: un sorgere o una sizigia in quella fascia **si salta**, non si rimanda, perche' un avviso che dice "la Luna sorge adesso" quando e' sorta alle tre del mattino sarebbe falso.
- **FX.09 e FX.10, i prezzi in Eos**: perla ricucita 25 Eos (sotto il confronto del cielo in piu' del lunario, 30 Eos, perche' non sblocca niente di nuovo, solo un giorno passato); un assaggio di Respiriamo insieme 40 Eos (fra il confronto del cielo, 30, e la Lunga del giorno, 50: sblocca per una Luna piena intera, non per un giorno); una collana a due 50 Eos (lo stesso prezzo della proposta insieme del lunario, stesso gesto a due persone). Nessuna delle tre voci del listino ha ancora una porta server che la spenda davvero: scritte le callable di FX.09 che contano e invitano, non quelle che vendono, perche' l'ordine non le ha chieste per nome e inventarle avrebbe allargato il perimetro senza il si' del fondatore.
- **FX.11.** Il Calendario Lunare e il Respiro restano due arti: una porta sola a testa, non un menu' comune, perche' il fondatore ha chiesto "separati e collegati", non "uniti".
- **FX.12.** La guardia della grafica dipinta (R9) e' un file nuovo e non un'estensione della gemella del lunario, perche' quella scorre `/lunario/` e la UI del Respiro vive in `lib/features/respiro_della_luna/`, fuori da quella sottostringa.

## IL GIRO DELL'UTENTE (R10)

Le schermate aperte come una persona, sulle anteprime a 360x797 densita' 3 (`docs/preview/FX/`, guardate due volte: la prima cattura e la correzione):

- **Il Respiro.** La scena si apre sulla terrazza di Medora, la Luna vera al centro (il ripiego locale nell'anteprima, senza rete), il titolo su due righe leggibile, il pannello sotto con i numeri e le tre righe di Medora unite, il pannello del gesto sotto ancora. Confronto col Calendario Lunare (ordine FV): la' la scena resta sullo sfondo di un mese intero disegnato sopra; qui la scena e' quasi tutto lo schermo, con solo due pannelli stretti sotto, perche' il Respiro e' un gesto di un minuto e non una griglia da consultare. Confronto con l'Oracolo degli Angeli (ordine FU): la' la Luna non compare; non c'e' un termine di paragone diretto nella stessa famiglia.
- **La Collana.** La card con lo scrigno e la catenella, le perle vere appese; sotto, i chip di ricucitura dei giorni spenti recenti. Confronto col Calendario Lunare: la card della collana e quella del mese condividono lo stesso principio (sfondo del Maestro, sigillo, numero), ma la collana e' verticale e appesa invece che una griglia.

Nessun'altra differenza dichiarata.

## IL VERDE DI GITHUB

Da scrivere dopo il push, in coda a questo rapporto (R3, R6: nessun rosso si consegna).

## I COMANDI PER PUBBLICARE IL LAVORO SUL SERVER, QUANDO IL FONDATORE DARA' IL SI'

Nessuno di questi comandi e' stato eseguito (R3). Dentro `functions/`, dopo `npm run build`:

```
firebase deploy --only functions:respiroInsiemeEntra,functions:respiroInsiemeConteggio,functions:invitaCollanaADue,functions:rispondiCollanaADue,functions:segnalaRespiroDelGiornoPerLaCollanaADue,functions:leCollaneADue
```

Non esistono ancora le porte che vendono la perla ricucita, l'assaggio di Respiriamo insieme o la collana a due: nessuna voce del listino del Respiro ha una callable "compra", perche' l'ordine non le ha chieste per nome.

## MIGLIORIE ED EFFETTI WOW PROPOSTI, NON COSTRUITI

- **La UI di "Respiriamo insieme"** (il contatore e la card a due nomi) non e' costruita: i modelli lato client sono pronti (`RespiroInsiemeStato`, `CollanaADue`), ma disegnarla senza che le porte server siano pubblicate significherebbe mostrare un numero che la fonte non ha ancora detto, contro la regola di casa sui numeri senza fonte (Linee Guida UX V13 sezione 4). Da costruire quando la pubblicazione arriva.
- **Un conto alla rovescia fino alla prossima Luna piena** sulla schermata principale, per invogliare a tornare apposta quel giorno per Respiriamo insieme: non costruito, e' un invito in piu' che l'ordine non ha chiesto.
- **La scia di luna della bussola in fusione schermo**, oltre alla sua trasparenza gia' vera: potrebbe intensificare il bagliore quando il telefono e' vicino alla Luna. Non costruito: la trasparenza dell'asset gia' basta, e un blend aggiuntivo e' un dettaglio visivo che l'ordine non ha chiesto.
- **Il testo dei chip di ricucitura**, piccolo nella cattura della collana: da controllare sul telefono vero prima di decidere se ingrandirlo, perche' una cattura automatica a volte non riflette la resa reale del carattere (verificato altrove nel progetto).
