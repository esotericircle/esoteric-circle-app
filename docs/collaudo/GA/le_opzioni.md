# Le opzioni di Esoteric Circle, funzionalità attive

Voce GA.09, parte "l'elenco delle opzioni". Verificato sul codice del worktree `aspetta-testo-riallineamento-5a7bfd`, commit 19dc970e, il 21 ottobre 2026. Niente è stato eseguito a video: tutto viene dal sorgente. Dove non sono sicuro scrivo "da verificare" e dico dove guardare.

Le schede sono numerate F01 e poi da F03 a F34: F02, i domini dei Maestri, è fusa in F01. In tutto 33 funzionalità attive.

Segni usati nelle schede:
- `[O]` opzione che la persona sceglie (selettore, valore, interruttore, azione, condivisione). Una riga per controllo, i valori sono dentro la riga.
- `[P]` punto in cui cambia col piano.
- `[G]` limite giornaliero.
- `[E]` spesa o giro a Eos.

---

## 0. Fatti che valgono per tutte le funzioni

### 0.1 Come si decide cosa è attivo
- La fonte è `lib/core/arts/art_catalog.dart` (`ArtCatalog`, stato `attiva`, `premium`, `inArrivo`). Le arti attive sono 12 nei domini più 2 che vivono solo nel Passaporto (`soloNelPassaporto`: Angelo Custode e Test Archetipo).
- In questa build `AppFlags.isDemo = true` (`lib/core/config/app_flags.dart`, costante di compilazione): le schede "In arrivo" si vedono tutte (clessidra, tocco la gira, non si apre). Le arti in arrivo NON sono nell'elenco che segue.
- `lib/core/feature_flags/feature_catalog.dart` e `lib/core/santuario/function_shelf.dart` (7 funzioni, `docs/stato_funzioni.json`) non governano più la home: `FeatureTile` e `FeatureGrid` non sono montati da nessuna schermata. Da verificare solo se Remote Config può spegnere una scheda: `grep FeatureFlagService lib` trova soltanto `lib/app.dart` e `feature_tile.dart`, quindi il codice dice di no.
- Le 12 arti attive nei domini: Oroscopo Universale, Stesa di Tarocchi, Oracolo degli Angeli, Sinastria VIP, Sinastria Evolutiva, Il Respiro della Luna, Calendario Lunare Personale, Meditazione, Mappa del Viso, Estrazione Rune, Il Viaggio dello Sciamano, Sigillo dell'Intenzione. In più, fuori dai domini: i 4 Doni del giorno, il Cielo reale, la Chat e il LIVE, il Cerchio sociale e gli Enigmi, il Passaporto, i Sentieri, il Diario Cosmico, il Calendario degli eventi, l'Account con le sue schermate, i piani e il Borsellino.

### 0.2 Piani (`lib/core/entitlement/plan_catalog.dart`)
| Piano (nome a video) | Tier nel codice | Settimana | Mese | Anno | Dote Eos alla sottoscrizione | Bonus Eos mensili |
|---|---|---|---|---|---|---|
| Viandante | `free` | gratis, con banner in basso | | | 0 | no |
| L'Iniziato | `tier1` | 2,99 € | 9,99 € | 99,99 € | 500 | "Medio" |
| L'Adepto | `tier2` | 4,99 € | 19,99 € | 189,99 € | 1.500 | "Alto" |
| L'Illuminato | `tier3` | 6,99 € | 29,99 € | 279,99 € | 3.000 | "Massimo" |

Nel piano annuale due numeri cambiano (`nellAnnuale`): Iniziato 11 domande al giorno invece di 12; Adepto 55 minuti di LIVE al mese e 14 domande; Illuminato 95 minuti di LIVE e 18 domande. Il testo delle domande nella matrice dice 12/17/21, il server usa 12/17/21 per il mensile (`LIMITI.domande`): per l'annuale **da verificare** che numero applichi il server (`functions/src/budget.ts`).

### 0.3 Come si cambia piano per collaudare
- Percorso: barra sottile in alto, tocco sul volto > Account > "Abbonamento" (oppure Account > "Impostazioni" > "Il tuo piano") > schermata "I piani del Cerchio" > carta del piano > "Prova Viandante in Demo" (Viandante) oppure "Passa a [piano]" > "Attiva in Demo".
- Scrive il piano sul server (`attivaIlPianoInDemo`) e risincronizza i contatori. Se il server non risponde, lo snackbar dice "attivo solo su questo telefono": in quel caso i limiti del server restano quelli di prima. File: `lib/features/pricing/pricing_screen.dart`.
- Il pagamento vero non è integrato: la riga in fondo alla schermata dice "Nella demo i piani sono visibili ma il pagamento non è integrato".
- `showDemoControls` (`lib/features/home/widgets/demo_controls.dart`) esiste ma nessuna schermata lo apre.

### 0.4 Limiti giornalieri (budget del server, `functions/src/budget.ts` e matrice del piano)
Ordine: Viandante / Iniziato / Adepto / Illuminato.
| Budget | Dove si consuma | Limite al giorno | Riscatto con Eos (listino del server, `PREZZI_DEL_RISCATTO`) |
|---|---|---|---|
| domande | Chat dei Maestri | 3 / 12 / 17 / 21 | 80 |
| approfondimenti | "Vai più a fondo" in chat | 0 / 2 / 2 / 3 | 60 |
| confronti | "Chiedi anche agli altri" in chat | 0 / 1 / 2 / 3 | 150 |
| gettate | Estrazione Rune | 1 / 2 / 3 / 3 | 60 |
| stese | Stesa di Tarocchi (di qualunque numero di carte) | 1 / 3 / 3 / 5 | 150 |
| steseDaDieci | Croce Celtica, dentro le stese | 0 / 0 / 1 / 1 | nessun riscatto |
| sinastrie | Sinastria VIP | 3 / 5 / 5 / 25 | 150 |
| cieli | Confronto del cielo con un amico | 1 / 5 / 15 / 30 | 30 |
| sinastrieEvolutive | coppie nuove della Sinastria Evolutiva | 1 / 2 / 5 / 15 | 150 |
| oracoliAngeli | consultazioni dell'Oracolo | 1 / 3 / 5 / 6 | 100 |
Riscatto speciale: `riscatto_steseDieci` costa 400 Eos e ridà UNA stesa (non una Croce Celtica in più), solo se le stese del giorno sono finite e la Croce Celtica del giorno non è ancora stata fatta.

Altri limiti al giorno o alla settimana (fuori dal budget del server): segni agli amici 5/20/40/60 al giorno (`SEGNI_AL_GIORNO`) con massimo 3 alla stessa persona e stop dopo 2 non ricambiati; Discese nel Viaggio 1/1/1/2 al giorno e Segni all'animale 1 a settimana / 3 a settimana / 1 al giorno / 5 al giorno (ma vedi 0.6); gettate del Viaggio e sigilli vivi 1/2/3/5 insieme.

**Il giorno lo decide il server (fuso Europe/Rome, mezzanotte di Roma)**, non il telefono: `functions/src/giorno.ts`, commento in testa ("spostando l'ora avanti di un giorno tutti e quattro i budget tornavano interi"). Quindi spostare la data del telefono NON azzera i budget della tabella. Sposta invece le cose locali: finestre dei Doni del giorno, puntino d'oro delle arti del giorno, confine rituale a mezzogiorno della Runa, Calendario Lunare, Respiro, tetto del modello del Viaggio. Per "tornare il giorno dopo" sui budget serve aspettare la mezzanotte di Roma (o cambiare piano, che non azzera i contatori: da verificare).

### 0.5 Altre spese e guadagni di Eos
Spese (`lib/core/entitlement/listino_degli_eos.dart`, `lib/core/entitlement/pacchetti_di_eos.dart`):
- L'oroscopo completo di oggi (4 schede) 50. L'oroscopo dell'anno 300. Un mese di Calendario Lunare in più 60. Una proposta insieme del Calendario 50.
- Una carta degli Angeli da donare 30. Una scintilla da donare 30. Un sigillo da donare 80. Un indizio in più (Enigmi) 5. Il segno di chi ti ha riconosciuto 20. Un posto in più fra gli amici 100 (voce di listino: dove compare **da verificare**, `grep amicoInPiu lib` non trova schermate).
- Regalare Eos a un amico: da 100 a 500 al giorno, ma solo con Eos comprati o dote del piano, e oggi nessuno dei due esiste (`functions/src/sociale.ts` riga 1180 circa): di fatto non disponibile, da verificare a video.
- Conferma della spesa: sopra 100 Eos compare la conferma comune (`LaConfermaDellaSpesa`, soglia `sogliaDellaConferma = 100`).
- Pacchetti Manciata 300 Eos 2,99 €, Borsa 900 Eos 7,99 €, Scrigno 2.500 Eos 19,99 €: elencati nel Borsellino ma NON in vendita (`acquistiCollegatiAUnNegozio = false`). Nessun acquisto vero è possibile.
Guadagni: benvenuto 250 Eos; invito accolto 150 Eos a chi invita e 150 a chi arriva; condivisione di una card 30 (pubblica) o 15 (privata e card delle arti), massimo 3 condivisioni premiate al giorno (`TETTO_CONDIVISIONI_PREMIATE`); traguardi dei tre Sentieri (2.010 Eos per sentiero, 6.030 in tutto); dote e bonus mensili del piano.
Prezzo della stesa da riscattare: il listino locale (`ListinoDegliEos.stesaTreCarte`) dice 120, il server 150. Il telefono legge il prezzo dal server (`prezzoDelRiscatto`), quindi a video dovrebbe comparire 150: **da verificare a video**.

### 0.6 Cosa cambia perché la build è Demo (`AppFlags.isDemo = true`)
- Viaggio dello Sciamano: i tetti per piano delle discese e dei segni NON si applicano (`TettiDelViaggio.quanteAlGiorno` torna null in Demo). Resta il tetto del modello, 10 discese e 10 segni al giorno (`IlTettoDelleChiamate`), alzabile con l'interruttore "Tetto del modello alzato (Demo)". Comando "Ricomincia il viaggio (Demo)" nella soglia.
- Libro dei Sigilli: pulsante "Porta alla data (Demo)" per far scadere un sigillo.
- Chat dei Maestri: la memoria è accesa in ogni piano e il benvenuto riprende la memoria anche al Viandante.
- Sentieri: tutti i traguardi aperti (`Sentieri.chiedeIlTier` falso in Demo).
- Pagina piani: carta "Demo" e pulsanti "Attiva in Demo".

---

## 1. Schede per funzionalità

### F01. Home "Il Cerchio" e domini dei Maestri
- Si apre: all'avvio, prima schermata (voce "Il Cerchio" della barra in basso; le altre voci sono Medora, Aura, Calìgo, Passport). Dal dominio: barra in basso > nome del Maestro.
- File: `lib/features/santuario/santuario_screen.dart`, `le_righe_della_casa.dart`, `widgets/tue_arti_view.dart`, `lib/features/maestri/domain_screen.dart`, `lib/features/schede/la_scheda_dell_arte.dart`, `lib/core/arts/l_ordine_dei_domini.dart`.
- Barra sottile in alto: volto (apre Account), numero del livello, "Online N" (apre la tendina del Cerchio, F23), moneta (apre il Borsellino, F34).
- [O] Tocco sul cielo in cima (titolo del cielo, fase lunare): apre il Cielo reale (F20), dopo 3 secondi compare l'invito animato al tocco.
- [O] Carosello dei tre Maestri: tocco su un laterale lo porta al centro; tocco sul centro entra nel suo dominio.
- [O] Pulsante "Consulta" sotto il carosello: apre la chat del Maestro al centro (F21).
- [O] "Le arti preferite" (prima riga): matita "Scegli le tue arti" apre il foglio a spunte con tutte le arti vive raggruppate per Maestro; tetto 9 (`ArtiPreferiteController.tetto`); pressione lunga su una scheda la toglie. Lista di partenza: da verificare (`seiDellOrdineER` in `lib/core/arts/arti_preferite.dart`).
- [O] Dieci righe di schede, ognuna con "Vedi tutto": "Trova una risposta", "Per partner e amici", "Il cielo ti parla", "I più condivisi", "Conosci te stesso/a" (si accorda al genere), "Il tuo corpo", "La tua serenità", "La tua energia", "La tua intenzione", "Il tuo destino". Le arti attive dentro le righe: Rune, Tarocchi, Viaggio, Oracolo degli Angeli, Sinastria VIP, Sinastria Evolutiva, Oroscopo, Respiro (id `lunology`), Mappa del Viso, Sigillo, Meditazione, Calendario Lunare; il resto sono schede In arrivo.
- [O] Scheda di un'arte attiva: un tocco entra; la "i" in alto a destra gira la scheda e mostra le informazioni (la scheda girata dice "Tocca per entrare").
- [O] Scheda di un'arte In arrivo: clessidra in alto a sinistra, il tocco la gira e non la apre.
- [O] Dominio di Medora: scheda orizzontale "Consulta Medora" in cima, poi sezioni Astrologia, Cartomanzia, Compatibilità, Lunologia, Destino. Aura: Energia, Chakra, Fisiognomica. Calìgo: Divinazione, Rituali, Magia, Numerologia. Le schede attive dentro i domini sono le 12 arti del punto 0.1.
- [O] Striscia "I tuoi doni del giorno" sulla home: 4 caselle (F16 a F19), vedi sotto.
- [O] Primo approdo: i 5 fumetti che spiegano il Cerchio compaiono al primo avvio e si rivedono da Account (F30).
- [P] Nessuna differenza di piano sulla home.
- [G] Nessuno.
- [E] Nessuno.

---

### F03. Oroscopo Universale
- Si apre: Home > Medora (barra) > Astrologia > "Oroscopo Universale" (2 tocchi); oppure Home > riga "Il cielo ti parla" > scheda. Senza data di nascita manda a "I tuoi dati di nascita".
- File: `lib/features/horoscope/oroscopo_screen.dart` (4.692 righe), `il_periodo_view.dart`, `il_soggetto_dell_oroscopo.dart`, `oroscopo_per.dart`, `answer_depth.dart`, `lib/core/horoscope/astro_tradition.dart`, `lib/features/amici/amici_screen.dart`.
- [O] "Oroscopo per": chip con il tuo nome | chip "amico/a" (o il nome dell'amico scelto). L'amico si sceglie in "I tuoi amici" (nome, data, ora e luogo di nascita; "Salva"; icona "Togli" con conferma "Togliere [nome]?"). Un amico legge sul segno solare, senza carta natale.
- [O] Periodo (4 linguette): Giorno | Settimana | Mese | Anno.
- [O] Tradizione (7 linguette): Occidentale, Vedica, Cinese (attive); Maya, Celtica, Egizia, Araba (mostrano l'invito "Fase 4", non si leggono).
- [O] Scheda del giorno (4): Generale, Amore, Carriera, Fortuna. Per Settimana e Mese i riquadri per dominio con i tre giorni migliori.
- [O] Profondità su ogni scheda e su ogni riquadro: Breve | Lunga (selettore a due voci, "Lunga" porta il lucchetto se non aperta).
- [O] "Come nasce questa lettura" (punto interrogativo su ogni scheda).
- [O] Bottone finale: "Interroga il cielo" (Occidentale), "Interroga la Luna" (Vedica), "Apri l'almanacco" (Cinese).
- [O] Città: "scegli dove vivi adesso" quando il luogo manca (per l'Anno e per le ore).
- [O] Anno: "Il PDF del tuo anno" (o "Il PDF dell'anno di [nome]" per un amico).
- [O] Condividi: "Condividi" (Giorno), "Condividi la settimana", "Condividi il mese", "Condividi il tuo anno"; la card porta il premio in Eos.
- [P] Periodi: Giorno tutti; Settimana dall'Iniziato; Mese dall'Adepto; Anno si legge dall'Adepto (Illuminato col PDF), sotto si apre con 300 Eos.
- [P] Tradizioni: Occidentale a tutti. Vedica e Cinese: il Viandante vede "Solo il segno", la lettura del giorno dall'Iniziato (`livelloDellaLettura: 1`).
- [P] Lunga: Viandante solo con Eos e solo per oggi (foglio "Abbonati per avere sempre l'oroscopo completo"); Iniziato, Adepto e Illuminato sempre.
- [P] Oroscopo per gli amici: Viandante 0 / Iniziato 3 / Adepto 10 / Illuminato 50 (matrice, `AmiciOffline.posti`).
- [G] Nessun tetto al numero di letture (da verificare: nessun budget del server per l'Oroscopo).
- [E] "L'oroscopo completo di oggi, per tutte e quattro le schede" 50 Eos (Viandante). "L'oroscopo dell'anno" 300 Eos (Viandante e Iniziato). Posto amico in più 100 (listino, schermata da verificare).

### F04. Stesa di Tarocchi
- Si apre: Home > Medora > Cartomanzia > "Stesa di Tarocchi" (2 tocchi); oppure riga "Trova una risposta" o "I più condivisi".
- File: `lib/features/tarot/stesa_tre_carte_screen.dart`, `tarot_selectors.dart` (pannello "Scegli la tua stesa"), `lib/core/tarot/tarot_spread_type.dart`, `la_chiave_di_lettura.dart`, `i_mazzi_dei_tarocchi.dart`, `tarot_topic.dart`, `lib/features/horoscope/answer_depth.dart`.
- [O] Domanda, tendina "Scegli la tua domanda", 16 argomenti in 3 gruppi. Amore e sentimenti: Amore il quadro generale, Cosa prova per me, Un ritorno d'amore, Fiducia e tradimento, Un nuovo incontro, Scegliere tra due. Lavoro e denaro: Lavoro trovarlo o cambiarlo, Carriera e crescita, Denaro e fortuna, Un affare o una decisione. Vita e cammino: Il momento che vivo (predefinito), Una scelta o un bivio, Un cambiamento in arrivo, Famiglia e casa, Un'amicizia, Un progetto o un sogno.
- [O] Domanda scritta con parole proprie (campo libero; se c'è prevale sull'argomento).
- [O] Tipo di stesa (4): Una Carta; Tre Carte (Passato, Presente, Futuro; predefinita); Quattro Carte (Stesa a Croce); Dieci Carte (Stesa della Croce Celtica).
- [O] Chiave di lettura (4): Predittiva di Medora (predefinita), Riflessione, Esoterica, Archetipica.
- [O] Mazzo (3): Rider-Waite (predefinito), Marsiglia, Thoth. Marsiglia e Thoth si scaricano dal CDN (foglio "Il mazzo si scarica").
- [O] Profondità della lettura: Breve | Lunga.
- [O] Carte rovesciate: interruttore, acceso di partenza (se spento "solo dritte").
- [O] Sul tavolo: Taglia, Mischia (anche scuotendo il telefono), Suono | Muto; poi "Scegli N dal ventaglio" (N = 1, 3, 4 o 10) e "Leggi le Carte".
- [O] Dopo la lettura: "Il consiglio di Medora", "Parla con Medora" (apre la chat con la frase), apri la carta ingrandita, Carta Chiave, fonti, "Condividi" (card della stesa).
- [O] Riaprire la stessa stesa non spende un uso (la stesa si conserva con la stessa firma: `LaStesaConservata`).
- [P] Tipo: Una e Tre per tutti; Quattro Carte dall'Iniziato; Dieci Carte dall'Adepto.
- [P] Chiave: Riflessione dall'Iniziato; Esoterica e Archetipica dall'Adepto.
- [P] Mazzo: Marsiglia dall'Iniziato; Thoth dall'Adepto.
- [P] Lunga: dall'Iniziato.
- [P] Righe della matrice senza interfaccia trovata: "Il ritorno della carta" (Adepto), "Rileggere una stesa" (Illuminato), "Card della stesa da condividere" (tutti): `grep RigaDelPiano.ritornoDellaCarta lib` non trova nessuna schermata. Da verificare a video.
- [G] Stese 1 / 3 / 3 / 5 al giorno. Croce Celtica 0 / 0 / 1 / 1 al giorno (la Celtica fatta, il foglio dice "torna domani").
- [E] A stese finite il foglio "Le stese di oggi sono finite" offre il riscatto di una stesa (150 dal server) oppure, se la Celtica non è fatta, il riscatto da 400. Mai un riscatto per una seconda Croce Celtica.

### F05. Oracolo degli Angeli
- Si apre: Home > Medora > Cartomanzia > "Oracolo degli Angeli"; senza data di nascita manda a darla.
- File: `lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart`, `oracolo_share_card.dart`, `lib/core/oracolo_angeli/le_domande_dell_oracolo.dart`, `i_ruoli_e_l_estrazione.dart`.
- [O] Domanda: campo "Scrivi la tua domanda agli angeli" e pulsante "Affida la domanda".
- [O] Tema (7 chip, ognuno con dieci domande da scegliere): Amore, Lavoro, Famiglia, Amicizia, Una scelta, Il mio cammino, Serenità.
- [O] Scelta delle carte dal ventaglio dei dorsi, poi "Avvia la lettura". Tre carte: Angelo Custode (Cosa fare), Angelo del Cuore (Cosa sentire), Angelo dell'Intelletto (Cosa capire).
- [O] "Aggiungi l'ora di nascita" sulle carte coperte quando manca l'ora.
- [O] Su ogni carta: "Parla con Medora", "Mandala in dono" a un amico, il rito con Calìgo (rito propiziatorio con salmo, scelto dall'angelo), condividi la card.
- [O] "Nuova domanda" per ricominciare.
- [O] Sempre visibili: Angelo dell'ora e Messaggio del giorno.
- [P] Carte: il Viandante apre solo il Custode (le altre due sono "La carta dei tre angeli" con lucchetto); dall'Iniziato le tre.
- [P] Risposta lunga con salmo propiziatorio: dall'Iniziato ("La risposta lunga").
- [G] Consultazioni 1 / 3 / 5 / 6.
- [E] Consultazione in più 100 Eos. "Mandala in dono" 30 Eos (cenno e carta degli Angeli sono per tutti i piani).

### F06. Sinastria VIP
- Si apre: Home > Medora > Compatibilità > "Sinastria VIP" (senza data di nascita manda a darla); riga "Per partner e amici" o "I più condivisi".
- File: `lib/features/synastry/porta_della_sinastria.dart`, `sinastria_gallery_screen.dart`, `sinastria_vip_screen.dart`, `schermata_del_gemello.dart`, `collezione_screen.dart`, `il_foglio_del_tuo_volto.dart`, `lib/core/synastry/vip_catalog.dart`.
- [O] Tipo di sinastria (tendina, 3): "Sinastria con un VIP", "Confronta 2 VIP", "Trova il tuo gemello astrale VIP".
- [O] Scelta del VIP nella galleria: 50 VIP. Cerca per nome ("Cerca un VIP per nome"); categoria (Tutti, Cinema, Musica, Impresa, Icone, Sport); pulsante "Un VIP a caso"; fascia "In evidenza" (8 volti).
- [O] "Fai il confronto". Poi: "Cambia VIP", "Rimetti te al posto di [VIP]" / "Rimetti il tuo cielo al primo posto", "Apri la carta di [VIP]".
- [O] Il tuo volto nella cornice: "Usa la fotocamera" | "Scegli un'immagine dalla galleria" | foto del profilo.
- [O] Collezione delle coppie già scoperte.
- [O] Condividi (card della sinastria, con premio Eos).
- [P] Nessuna differenza di piano oltre al limite.
- [G] 3 / 5 / 5 / 25 al giorno.
- [E] Sinastria in più 150 Eos ("La riserva finita").

### F07. Sinastria Evolutiva
- Si apre: Home > Medora > Compatibilità > "Sinastria Evolutiva" (senza data di nascita manda a darla); riga "Per partner e amici". Si apre sullo studio di Medora.
- File: `lib/features/synastry/avvio_sinastria_evolutiva.dart`, `sinastria_evolutiva_screen.dart`, `la_nascita_dell_altra_persona.dart`, `lo_studio_di_medora.dart`, `lib/core/synastry_evolutiva/`.
- [O] "Scegli la persona" > "La sua nascita": codice (l'altra persona apre "La tua nascita" sul suo telefono e detta il codice; campo "Il codice" + "Leggi") oppure inserimento a mano: nome, data, ora (con "ora non nota").
- [O] "Condividi la mia nascita" (genera il tuo codice per l'altra persona).
- [O] Cambiare persona (ogni coppia nuova consuma un uso).
- [O] Cinque capitoli: L'attrazione, Le emozioni, La mente, La durata, Il destino.
- [O] "Oggi fra voi", "Intervalli di Keplero", "Tema Composito", ritratto della coppia, "momento giusto".
- [O] Condividi la card.
- [P] Capitoli: il Viandante legge 2 su 5; dall'Iniziato tutti i cinque.
- [P] Intervalli di Keplero: dall'Iniziato. Tema Composito, ritratto della coppia e momento giusto: dall'Adepto. Oggi fra voi: tutti.
- [P] `FeatureCatalog` dichiara `synastry_depth` premium tier2, `ArtCatalog` la dichiara attiva senza tier: vale il catalogo delle arti (il Viandante la apre), da verificare a video.
- [G] Coppie nuove 1 / 2 / 5 / 15.
- [E] Coppia in più 150 Eos ("Le coppie nuove di oggi sono finite").

### F08. Il Respiro della Luna (e Collana delle Lune)
- Si apre: Home > Medora > Lunologia > "Il Respiro della Luna" (id `lunology`; riga "Il cielo ti parla"). Si apre anche senza data di nascita. Ha il puntino d'oro finché non lo apri nel giorno.
- File: `lib/features/respiro_della_luna/il_respiro_della_luna_screen.dart`, `la_collana_delle_lune_screen.dart`, `gli_avvisi_del_respiro.dart`, `il_piano_del_respiro.dart`, `lib/core/lunario/`.
- [O] Respiro guidato sulla Luna: tieni premuto per inspirare, lascia per espirare (dito) oppure soffia nel microfono; tempi accordati alla fase (crescente 5 s / 3 s, calante 3 s / 5 s, sizigie 4 s / 4 s). A rito compiuto si accende la perla del giorno.
- [O] Il tempo sotto il dito: il righello scorre le ore (24 ore) o il mese; "Torna adesso".
- [O] Città: "Cerca la città" / cambio città, o posizione dal GPS (permesso; senza permesso resta il ripiego dichiarato).
- [O] "Avvisi della Luna" (foglio): interruttore "La Luna che sorge" (col nome della città); interruttore "Luna piena, nuova e Superluna" (fascia di quiete 23 a 7). Chiede il permesso delle notifiche.
- [O] La Collana delle Lune ("collana_vai_a_respirare", "collana_apri_scrigno", "collana_condividi"): perla del giorno, nome del ciclo, scrigno, condivisione.
- [O] Menu "Altro": porta al Calendario Lunare (F09).
- [O] Parola di Medora: tre righe al giorno; la Luna fuori corso, il giorno lunare.
- [P] Viandante: la Luna di quest'ora, il respiro di oggi, la perla del giorno, il tempo sotto il dito per 24 ore.
- [P] Dall'Iniziato: collana completa e scrigno, avvisi, tempo sotto il dito su tutto il mese ("Respiro della Luna: avvisi" e le altre due righe della matrice).
- [G] Una perla al giorno (un respiro compiuto accende il giorno); budget del server: nessuno.
- [E] Nessuna spesa offerta. La ricucitura di una perla (25 Eos, 3 per ciclo, 7 giorni indietro) e la collana a due (50) non compaiono: porte del server non pubblicate. "Respiriamo insieme" è stato tolto da card, matrice e prezzi (decisione GA). Da verificare a video che nessun tasto "Ricuci" sia visibile.

### F09. Calendario Lunare Personale
- Si apre: Home > Medora > Lunologia > "Calendario Lunare Personale"; riga "La tua intenzione". Dal Respiro > "Altro".
- File: `lib/features/lunario/calendario_lunare_screen.dart` (1.820 righe), `trova_il_giorno_insieme.dart`, `il_piano_del_lunario.dart`, `gli_eos_del_lunario.dart`, `i_promemoria_del_lunario.dart`, `lib/core/lunario/le_attivita_del_lunario.dart`.
- [O] Mese: si scorre avanti e indietro (non prima del mese in corso).
- [O] "Trova il giorno": 11 categorie (emblemi) e, dentro, 27 attività. Capelli e unghie (Taglio per farli crescere, Taglio per rinforzarli, Taglio delle unghie); Orto (Semina, Trapianto, Potatura, Raccolto); Piante e giardino (Rinvasi, Talee, Fiori, Piante da appartamento); Casa (Pulizie, Bucato e macchie, Traslochi, Lavori); Cucina e conserve (Conserve, Pane e lievitati); Vino e cantina (Travasi, Imbottigliamento); Bellezza (Depilazione, Trattamenti); Pesca; Inizi e firme; Viaggi; Amore (Primo appuntamento, Dichiarazione, Nozze).
- [O] Tocco su un giorno: foglio con il perché, il cielo di quel giorno, "da dove viene", promemoria per quel giorno, "Affida l'intenzione".
- [O] "I giorni tuoi" (Luna sul tuo Sole, ritorno lunare ecc.): richiedono l'ora di nascita, altrimenti "Aggiungi l'ora".
- [O] "Trova il giorno insieme": scelta degli amici del Cerchio, "Manda" la proposta.
- [O] "Condividi il mese" (card del mese).
- [O] Pulsante "Il Respiro" (porta a F08).
- [P] Mesi avanti: Viandante solo il mese in corso; Iniziato 1 mese dopo; Adepto e Illuminato 12 mesi avanti.
- [P] Categorie di "Trova il giorno": Viandante 1 (la prima, Capelli e unghie); dall'Iniziato tutte.
- [P] Promemoria: dall'Iniziato. "Trova il giorno insieme": dall'Adepto.
- [G] Nessun budget del server.
- [E] Un mese di Calendario Lunare in più 60 Eos (foglio "Più mesi avanti sono dell'[piano]"). Una proposta insieme 50 Eos.

### F10. Meditazione
- Si apre: Home > Aura (barra) > Energia > "Meditazione"; riga "La tua serenità".
- File: `lib/features/maestri/aura/meditation/meditation_screen.dart`, `pannello_della_libreria.dart`, `meditation_audio.dart`, `lib/core/maestro/libreria_dei_respiri.dart`, `frequenza_del_giorno.dart`.
- [O] "Scegli il sintomo" (libreria di 12 respiri, uno per sintomo): Senso di insicurezza, Ventre stretto, Mancanza di slancio, Respiro corto, Gola chiusa prima di parlare, Difficoltà di concentrazione, Pensieri che non si fermano, Ansia, Agitazione improvvisa, Tensione prima di un passo, Stanchezza della sera, Insonnia. Ogni pratica dura 2, 3, 5, 7 o 10 minuti e appartiene a una di 4 tradizioni: Suoni seme, Respiro di risonanza, Frequenze del solfeggio, Battiti binaurali.
- [O] Senza scelta del sintomo: sessione del giorno di 5 minuti con la frequenza del giorno della settimana (396, 417, 528, 639, 741, 852, 963 Hz).
- [O] Frequenza (menu "FREQUENZA", 9 voci): 432 Hz la corda calma, 528 Hz il fuoco, Battito theta onde lente, 396 la radice, 417 il sacro, 639 il cuore, 741 la gola, 852 il terzo occhio, 963 la corona.
- [O] Avvio e pausa: tocco sul loto che respira (o play).
- [O] "Pratica più corta" durante la sessione.
- [O] "Condividi il tuo respiro" (card alla fine). "Aura ricorda" (memoria della seduta).
- [P] Nessun cancello nel codice: il testo dell'Adepto promette "Oracoli secondari, meditazioni e frequenze", ma la schermata non legge il piano. Da verificare a video.
- [G] Nessuno.
- [E] Nessuno.

### F11. Mappa del Viso
- Si apre: Home > Aura > Fisiognomica > "Mappa del Viso"; righe "I più condivisi" e "Il tuo corpo". Usa la fotocamera.
- File: `lib/features/maestri/aura/face/face_constellation_screen.dart` (2.362 righe), `lib/core/face/`.
- [O] "Inquadra il tuo volto" (fotocamera) / "Rifai la lettura piena" (se c'è una lettura) > "Cattura la costellazione".
- [O] Senza fotocamera: "Non hai la fotocamera? Tocca qui" e "Preferisci scegliere a mano?" > "Scegli a mano": 11 categorie di tratti (Forma del volto, Fronte, Sopracciglia, Distanza degli occhi, Grandezza degli occhi, Naso, Labbra, Bocca, Mento, Mascella, Zigomi), "Scegli tutti i tratti" > "Vedi la tua costellazione".
- [O] "Le tue letture passate" e "La tua ultima lettura".
- [O] "Lega ai transiti": interruttore (il cielo di oggi si accosta alla lettura).
- [O] "Leggi un altro volto" (confronto fra due volti).
- [O] "Fonti e metodo". Condividi la card.
- [P] Nessuna differenza di piano (`QuanteLettureDelViso.limite` è nullo per tutti).
- [G] Nessuno.
- [E] Nessuno.

### F12. Test Archetipo (si apre dal Passaporto)
- Si apre: barra in basso "Passport" > tessera "Archetipo" (non sta nei domini: `soloNelPassaporto`). Scheda attiva con rotta in `art_navigation.dart`.
- File: `lib/features/maestri/aura/archetype/archetype_test_screen.dart`, `lib/core/archetypes/`.
- [O] Interruttore "Lega al cielo di oggi" (si decide PRIMA delle domande).
- [O] "Comincia": 12 domande da 4 risposte ciascuna; si può tornare indietro (da verificare).
- [O] Risultato su 12 archetipi (Innocente, Esploratore, Saggio, Eroe, Ribelle, Mago, Realista, Amante, Giullare, Custode, Sovrano, Creatore) con "La sua luce", "La sua ombra", "I dodici in te", "La lettura di oggi", "Nel tempo".
- [O] Condividi la card.
- [P] Nessuna differenza di piano nella matrice; il codice ha `ArchetypeAllowance`: 1 test al giorno al Viandante, 3 all'Iniziato, senza limite dall'Adepto.
- [G] Test al giorno 1 / 3 / illimitato / illimitato (client, `archetype_allowance.dart`). In più il test si rifà dopo 90 giorni (`RipetizioneDelTest.giorniDiAttesa`): vale il vincolo più stretto, la schermata dice "Potrai rifare il test fra N giorni, il [data]".
- [E] Nessuno.

### F13. Estrazione Rune
- Si apre: Home > Calìgo (barra) > Divinazione > "Estrazione Rune"; riga "Trova una risposta". Si apre sempre, anche senza data di nascita.
- File: `lib/features/maestri/caligo/rune/rune_draw_screen.dart` (2.594 righe), `lib/core/rituals/rune_cast.dart`, `la_lettura_delle_rune.dart`, `lib/core/domande/domande_del_cerchio.dart`.
- [O] Gettata (4 chip): Runa di Odino (una runa); Le tre Norne (tre rune: Urdhr ciò che fu, Verdhandi ciò che diviene, Skuld ciò che sarà); La Croce delle Cinque (cinque rune); Il getto sul telo (sorte libera, 7 rune sparse).
- [O] Domanda: campo "Oppure scrivila con le tue parole"; tendina "Scegli una domanda" con "Domande frequenti" e "Domande personali" (queste compaiono solo se l'app ha il dato: runa di ieri sera, parola di stamattina, animale guida, archetipo); oppure gettare senza domanda ("Puoi anche gettare senza domanda").
- [O] "Getta le rune" (gesto sul pozzo; fallback tattile).
- [O] Dopo il responso: "Getta ancora" (consuma un'altra gettata), risposta lunga (lucchetto), "Il sigillo del giorno" (bindrune), fonti e poemi, condividi la card.
- [P] Risposta lunga con il galdr della runa che decide: dall'Iniziato.
- [G] Gettate 1 / 2 / 3 / 3.
- [E] Gettata in più 60 Eos.

### F14. Il Viaggio dello Sciamano
- Si apre: Home > Calìgo > Rituali > "Il Viaggio dello Sciamano" (id `guide_animal`); riga "Trova una risposta". Senza data di nascita manda a darla.
- File: `lib/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart`, `il_diario_dei_viaggi_screen.dart`, `lib/core/viaggio/`.
- [O] "CON CHE COSA SCENDI" (tre vie): "Scegli" una delle sei domande (Una scelta da fare, Una persona, Un blocco che non si supera, Un tempo che non arriva, Una direzione da prendere, Qualcosa che è finito) | "Scrivila tu" (campo libero) | "Solo incontro".
- [O] "Scendi": la discesa. Prima della rivelazione i viaggi sono quattro, uno al giorno, in quattro giorni diversi (il testo dice "è il metodo"). Dal secondo viaggio la domanda è la porta; "Cambia la domanda", "Tengo questa domanda", "Comincio un altro viaggio".
- [O] "Scopri chi è [animale]": la rivelazione dell'animale di potere.
- [O] Dopo la rivelazione, tre azioni: "Scendi con una domanda", "Nutrilo" o "Nutrila" (il tamburo che nutre), "Chiedigli un segno" o "Chiedile un segno".
- [O] Nel Mondo di Sotto: nove ombre, "Seguine una"; "Passa la mano"; "Risali".
- [O] Responso: "Di' chi sei", "Rileggi i quattro strati", Diario dei viaggi, condividi la card o "Condividi come video".
- [O] Solo in Demo: "Ricomincia il viaggio (Demo)" e interruttore "Tetto del modello alzato (Demo)".
- [P] Discese al giorno: 1 / 1 / 1 / 2. Segni all'animale: 1 a settimana / 3 a settimana / 1 al giorno / 5 al giorno. Nutrire: sempre per tutti. (In Demo il client non li applica, vedi 0.6.)
- [G] Discese e segni come sopra; tetto del modello 10 + 10 al giorno.
- [E] Nessuno.

### F15. Sigillo dell'Intenzione (e Libro dei Sigilli)
- Si apre: Home > Calìgo > Magia > "Sigillo dell'Intenzione"; riga "La tua intenzione" o "I più condivisi". Il Libro dei Sigilli si apre da lì ("Apri il Libro dei Sigilli").
- File: `lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart`, `libro_dei_sigilli_screen.dart`, `lib/core/magic/intention_sigil.dart`, `libro_dei_sigilli.dart`.
- [O] "SCEGLI LA VIA" (3): Via Rossa (il cuore e il desiderio), Via Bianca (protezione e chiarezza), Via Verde (erbe e natura). Poi "Scrivi la tua intenzione".
- [O] Intenzione: campo "Scrivo qui cosa voglio, al presente..." (servono almeno due lettere diverse) oppure "Oppure parti da qui" (frasi proposte).
- [O] "Chiedi a Calìgo di riscriverla" / "Chiedi un'altra forma"; "Usa questa" per accettare la forma del metodo; "La frase resta come l'hai scritta". Su salute, figli, denaro e cause legali non riscrive.
- [O] "QUANDO TI CERCO": la data scelta (scadenza del sigillo).
- [O] "Traccia" il sigillo: la ruota, la rivelazione e il responso di Calìgo.
- [O] Libro dei Sigilli: sigilli vivi; alla scadenza si risponde "compiuto", "lasciato" (o resta scaduto); "Cambia la data"; solo Demo "Porta alla data (Demo)".
- [O] Card da donare ("Caricare i propri sigilli" sempre; "Scintilla e Sigillo da donare" dall'Adepto).
- [P] Sigilli vivi insieme: 1 / 2 / 3 / 5.
- [P] Sigillo da donare: dall'Adepto.
- [G] Nessun budget del server oltre ai sigilli vivi.
- [E] Sigillo da donare 80 Eos.

---

### F16. Arcano dell'Alba (dono del giorno, mattino)
- Si apre: home > striscia "I tuoi doni del giorno" > casella "Alba". Ora di apertura di partenza 07:00 (cambia in Notifiche, F31); prima dell'ora la casella è chiusa e dice "Si apre alle 07:00".
- File: `lib/features/rituals/arcano_dell_alba_screen.dart`, `lib/core/rituals/arcano_dell_alba/`, `lib/core/rituals/daily_elements.dart`, `finestra_del_dono.dart`.
- [O] Scegliere uno dei ventidue arcani maggiori coperti (tavolo dei ventidue) e girarlo.
- [O] Leggere la parola della carta, il dono e "perché" (Medora parla); "Condividi la parola".
- [O] Tocco su "i" della casella: cosa fai, perché, cosa ti resta.
- [P] Per tutti i piani.
- [G] Uno al giorno (giorno rituale locale).
- [E] Nessuno.

### F17. Soffio del Destino (dono del giorno, ore 13:00)
- Si apre: striscia > casella "Soffio" (apre alle 13:00 di partenza).
- File: `lib/features/rituals/breath_destiny_screen.dart`, `soffio_share_card.dart`, `lib/core/rituals/forma_del_soffio.dart`.
- [O] Gesto: "Soffia, oppure spazza col dito" (microfono con permesso, ripiego a dito); guida del respiro; il rito conta i giri.
- [O] Risposta del Soffio; condividi la card.
- [P] Tutti i piani. [G] Uno al giorno. [E] Nessuno.

### F18. La Runa del Tramonto (dono del giorno, sera)
- Si apre: striscia > casella "Tramonto" (accesa dopo il tramonto del luogo, 18:30 di partenza; la posizione si chiede una volta, se negata usa l'ora stimata).
- File: `lib/features/rituals/sunset_rune_screen.dart`, `sunset_rune_card.dart`, `lib/core/rituals/sunset_rune.dart`.
- [O] Estrarre la runa della sera dal mazzo delle ventiquattro (gesto "getta" sulla pietra); incisione; presagio da portare nella notte.
- [O] Permesso di posizione concesso o negato (il rito dice il perché).
- [O] Settimana delle rune, fonti, condividi.
- [P] Tutti i piani. [G] Una al giorno rituale (il confine del giorno è a mezzogiorno). [E] Nessuno.

### F19. Sigillo del Sogno (dono del giorno, ore 22:30)
- Si apre: striscia > casella "Notte".
- File: `lib/features/rituals/dream_rite_screen.dart`, `dream_rite_card.dart`, `lib/core/rituals/dream_rite_corpus.dart`.
- [O] "Dirada la nebbia": soffiare sul telefono oppure passare il dito (c'è anche "salta", `dream_fog_skip`).
- [O] Unire la costellazione del segno in cui si trova la Luna; il saluto della notte con la sua carta; "Da dove nasce questo dono".
- [O] Condividi la costellazione della notte.
- [P] Tutti i piani. [G] Uno al giorno. [E] Nessuno.

(Per i quattro Doni, le ore e l'accensione degli avvisi si cambiano in Notifiche, F31. Il tocco "i" sulla casella spiega a cosa serve.)

### F20. Cielo reale
- Si apre: Home > tocco sul cielo in cima (modo "adesso"); oppure Passaporto > "Cielo di nascita" (modo "nascita"). Dal Dono del Sogno il rimando al cielo.
- File: `lib/features/real_time_cosmo/cielo_reale_screen.dart` (circa 3.800 righe), `il_pannello_del_tempo.dart`, `lib/core/astro/real_time_cosmo/i_bersagli_del_cielo.dart`.
- [O] "Viaggia nel tempo" > "Scegli il giorno": "La tua nascita" | "Adesso" | ruote Giorno, Mese, Anno; luogo "Usa dove sei ora" | "Usa il luogo di nascita"; conferma "Portami lì".
- [O] Indicatore "Dove deve puntare l'indicatore?": 5 categorie (Il tuo cielo, Luna e Sole, Pianeti, Costellazioni, Nebulose e galassie); dentro ogni categoria "Il più alto adesso" oppure un bersaglio preciso.
- [O] "L'eclittica": mostra la strada del Sole, della Luna e dei pianeti.
- [O] "Esplora senza distrazioni" e "Riaccendi le scritte".
- [O] Puntare il telefono verso il cielo (giroscopio e bussola, con ripiego a trascinamento del dito); "Portala al centro dello schermo, poi tocca" riallinea la bussola su un astro vero.
- [O] "Fonti e metodo".
- [P] Nessuna differenza di piano (nessun uso del piano in `lib/features/real_time_cosmo`). Elenco completo dei controlli: da verificare in `cielo_reale_screen.dart`, righe 3250 a 3800.
- [G] Nessuno. [E] Nessuno.

### F21. Chat dei Maestri
- Si apre: nel dominio di un Maestro la scheda orizzontale "Consulta Medora / Consulta Aura / Consulta Calìgo", oppure il pulsante "Consulta" del carosello (3 tocchi dalla home al massimo).
- File: `lib/features/maestri/chat/maestro_chat_screen.dart`, `widgets/chat_composer.dart`, `chat_bubble.dart`, `chat_suggestions.dart`, `lib/features/maestri/ask/ask_maestri_screen.dart`, `lib/core/chat/`.
- [O] Scrivere nel campo, o dettare con il microfono del campo, o aprire le "stelline" con i suggerimenti ("Domande frequenti" e "Domande personali" del Maestro).
- [O] Su una risposta: "Vai più a fondo" (approfondimento); "Chiedi anche agli altri" (porta alla schermata del confronto/Consiglio con la "Sintesi comparativa" dei tre Maestri e "Continua con [Maestro]"); "Riprova" se fallisce; raccogliere la risposta (`chat_raccogli`, dicitura da verificare).
- [O] Menu in alto a destra (icona fumetto): "Nuova chat"; conversazioni passate (aprire, cancellare con il cestino e conferma); "Chat precedenti" (apre il Diario Cosmico filtrato per Maestro); "LIVE con [Maestro]" (apre F22).
- [O] Cancellare questa conversazione (conferma sì/no).
- [O] Sotto il campo: il residuo del giorno delle domande e degli approfondimenti.
- [P] Memoria dei Maestri: Viandante no; Iniziato "Esclusiva"; Adepto e Illuminato sì (nel codice la Demo la tiene accesa a tutti, vedi 0.6).
- [P] Sintesi comparativa dei Maestri: dall'Iniziato.
- [P] "Vai più a fondo": Viandante 0 (invito all'upgrade); dall'Iniziato 2 al giorno.
- [G] Domande 3 / 12 / 17 / 21; approfondimenti 0 / 2 / 2 / 3; confronti 0 / 1 / 2 / 3.
- [E] Domanda in più 80; approfondimento 60; confronto 150.

### F22. LIVE con i Maestri (voce)
- Si apre: chat > menu in alto a destra > "LIVE con Medora / Aura / Calìgo".
- File: `lib/features/maestri/live/schermata_live.dart`, `il_selettore_delle_voci.dart`, `lib/features/maestri/chat/widgets/la_porta_del_vivo.dart`, `functions/src/live.ts`.
- [O] Parlare: tieni premuto per parlare (microfono), il Maestro risponde a voce.
- [O] Scrivere: campo di testo e "Continua per iscritto" (se i minuti finiscono o non si parla).
- [O] Selettore dei timbri (icona "Scegli il timbro", voci Gemini e Chirp 3 HD): visibile solo se il server riconosce il fondatore (`eFondatore`): i collaudatori non lo vedono.
- [O] Chiudere (`live_chiudi`) e il conteggio del tempo (`live_tempo`).
- [P] Minuti di LIVE al mese: Viandante no, Iniziato no, Adepto 80 (55 nell'annuale), Illuminato 150 (95 nell'annuale). Come si presenta il LIVE a chi non ha minuti: da verificare (`la_porta_del_vivo.dart`).
- [G] Tetto mensile, non giornaliero. [E] Nessuno.

---

### F23. Il tuo Cerchio (amici, segni, doni, confronti)
- Si apre: Account > "Il tuo Cerchio"; "Online N" in alto apre la tendina con gli amici online.
- File: `lib/features/cerchio/il_tuo_cerchio_screen.dart`, `la_tendina_del_cerchio.dart`, `scheda_dell_amico_screen.dart`, `invita_nel_cerchio_screen.dart`, `profilo_nel_cerchio_screen.dart`, `confronto_del_cielo_screen.dart`, `lib/core/cerchio/`.
- [O] "Chiama nel tuo Cerchio": "Chiama chi conosci" (Apri la rubrica); "Manda il tuo invito" (Manda il link); "Siete vicini" (Mostra il mio codice, Inquadra il suo codice con la fotocamera, "Un codice nuovo"); "Hai il suo sigillo?" (Manda l'invito).
- [O] Richieste di legame ricevute: "Accetta" | "Non ora".
- [O] Scheda dell'amico: "Manda un segno" (18 segni in 3 categorie), "Confronta i cieli di oggi", "Un cenno di saluto", doni "Una scintilla" e "Un sigillo", "Regala Eos", togli o blocca.
- [O] I 18 segni. Personali: Ti penso, Buon cammino, Mi manchi, Sono con te, Hai fatto molta strada, Buona notte. Astrali: Guarda il tuo cielo, Chiedi alla Luna, Pesca la tua carta, Getta una runa, Chiedi a un Maestro, Cerca il tuo animale. Facciamo insieme: Confrontiamo i cieli, Facciamo la sinastria, Stessa carta oggi, Mostrami la tua runa, Che archetipo sei, Guarda il nostro glifo. Chi riceve risponde con risposte rapide o con una di 7 reazioni (Luce, Abbraccio, Grazie, Sorriso, Ci penso, Pernacchia, Occhi al cielo).
- [O] "Il tuo nome nel Cerchio" (profilo nel Cerchio): nome, icona ("La tua icona"), sigillo (Rinnova, Revoca), chi può invitarti (tutti | solo chi ha il tuo sigillo), persone bloccate ("Sblocca").
- [O] "Gli Enigmi del Cerchio" (F24).
- [P] Amici nel Cerchio: 3 / 15 / 50 / 150. Segni al giorno: 5 / 20 / 40 / 60. Confronti del cielo: 1 / 5 / 15 / 30. "Scintilla e Sigillo da donare": dall'Adepto. Il cenno e la carta degli Angeli: per tutti.
- [G] Segni 5 / 20 / 40 / 60 (max 3 alla stessa persona, stop dopo 2 non ricambiati); confronti del cielo come sopra.
- [E] Confronto del cielo in più 30; scintilla 30; sigillo 80; regalo di Eos 100 a 500 (di fatto non disponibile, vedi 0.5). Invito accolto: +150 Eos a te e a chi entra.

### F24. Gli Enigmi del Cerchio
- Si apre: Il tuo Cerchio > "Gli Enigmi del Cerchio". Senza il Ritratto compilato nessun enigma si apre.
- File: `lib/features/cerchio/enigmi/gli_enigmi_screen.dart`, `il_ritratto_screen.dart`, `l_indovinello_screen.dart`, `la_prova_screen.dart`, `lib/core/cerchio/gli_enigmi_del_cerchio.dart`.
- [O] "Il tuo Ritratto": "Compila il Ritratto"; interruttori "Non comparire negli Enigmi degli altri", "Il tuo archetipo negli Enigmi", "Il tuo animale guida negli Enigmi".
- [O] "Chi del Cerchio": "Apri Chi del Cerchio" (indovinelli con indizi numerati, "Un indizio in più").
- [O] "Chi ti ha riconosciuto": "Scopri il segno di chi ti ha riconosciuto".
- [O] "La Prova della settimana": "Fai la Prova"; "Presagio" (presagire prima la natura dell'altro); "Lettura a due".
- [O] "Le letture a due aperte": "Rispondi".
- [O] "Il Pellegrinaggio" (si apre nella settimana che porta alla luna piena) e "Chi legge il Cerchio".
- [P] Non risultano differenze di piano (da verificare nel server, `functions/src/gli_enigmi.ts`).
- [G] Ogni gioco dice quanto tempo gli resta (settimana).
- [E] Un indizio in più 5 Eos. Il segno di chi ti ha riconosciuto 20 Eos.

---

### F25. Passaporto
- Si apre: barra in basso > "Passport". Include il Test Archetipo (F12), l'Angelo Custode (F26), i Sentieri (F27), il Diario (F28), gli Eventi cosmici (F29).
- File: `lib/features/passport/cosmic_passport_screen.dart`, `lib/features/identity/circle_seal_screen.dart`.
- [O] "Prossimi Eventi Cosmici" (F29).
- [O] "I tuoi traguardi" (F27) e "I Ricordi del Cerchio" (F28, "Giorno per giorno, cosa hai fatto").
- [O] Cielo di nascita: apre il Cielo reale in modo "nascita" (F20).
- [O] "Il tuo Sigillo del Cerchio" (schermata, "Condividi il sigillo").
- [O] Carte: Cammino di vita (numero), Luna di nascita, Animale guida, Carta di nascita (carta ingrandita), Angeli (ventaglio, F26), Archetipo (tessera, F12), Carta natale. Il "Filo dei giorni".
- [P] Carta natale occidentale: Viandante lettura base; dall'Iniziato completa con transiti. Nessun uso del piano in `lib/features/passport`: da verificare a video dove cambi.
- [G] Nessuno. [E] Nessuno.

### F26. Angelo Custode personale (si apre dal Passaporto)
- Si apre: Passaporto > carta "Angeli" (ventaglio) > "I tuoi tre Angeli". Senza data di nascita manda a darla.
- File: `lib/features/angels/angels_screen.dart`, `angelo_ingrandito.dart`, `lib/core/angels/`.
- [O] I tre angeli (Custode, Cuore, Intelletto) calcolati da Sole, giorno e ora; tocco su un angelo per ingrandirlo.
- [O] "Affida una domanda ai tuoi angeli": apre l'Oracolo (F05).
- [O] "Come vengono scelti" e "Fonti e metodo".
- [P] Nessuna. [G] Nessuno. [E] Nessuno.

### F27. Sentieri e Traguardi (il Cammino)
- Si apre: Passaporto > "I tuoi traguardi"; oppure Diario Cosmico > vista "Il Cammino"; o dalla festa di un traguardo.
- File: `lib/features/sigilli/sentiero_screen.dart`, `la_mappa_del_sentiero.dart`, `card_del_traguardo.dart`, `celebrazione.dart`, `lib/core/sigilli/`.
- [O] I tre Sentieri: Costellazione personale (Medora; Stelle e Costellazioni), Albero della Vita (Calìgo; Frutti e Sefirot), Fiore di Loto (Aura; Perle e Fioriture), 55 traguardi ciascuno.
- [O] Tocco su un traguardo: dettaglio e "Condividi" la card (con premio Eos).
- [O] Celebrazione alla conquista di un traguardo.
- [P] Iniziato "obiettivi e traguardi per Maestro": nel codice i traguardi dopo il 20 chiedono il piano (`ultimoTraguardoGratuito = 20`), ma in Demo sono tutti aperti.
- [G] Condivisioni premiate: 3 al giorno. [E] I traguardi accreditano Eos (fino a 2.010 per sentiero).

### F28. Diario Cosmico (Ricordi)
- Si apre: Account > "Diario Cosmico"; Passaporto > "I Ricordi del Cerchio"; chat > menu > "Chat precedenti" (filtrato per Maestro).
- File: `lib/features/ricordi/ricordi_screen.dart`, `azioni_del_responso.dart`, `lib/core/ricordi/`.
- [O] Vista: "Il Cammino" | "I Ricordi".
- [O] Ricerca "Cerca fra le tue domande".
- [O] Scala del tempo: anno, mese, settimana, giorno ("Quel giorno").
- [O] Riaprire un ricordo e riprenderlo ("si riprende"); "Segna nel Diario"; le carte custodite ("Le tue carte").
- [O] Lettura del mese (testo del mese in prosa).
- [P] Viandante: Cammino e Ricordi; dall'Iniziato la lettura del mese; dall'Adepto con AI; Illuminato anche il report PDF (il PDF del Diario: da verificare, non trovato nel codice).
- [G] Nessuno. [E] Nessuno.

### F29. Calendario degli eventi cosmici
- Si apre: Passaporto > "Prossimi Eventi Cosmici" (titolo della schermata: "Il cielo che viene").
- File: `lib/features/calendario/calendario_degli_eventi_screen.dart`, `lib/core/sigilli/eventi_del_cielo.dart`.
- [O] Elenco degli eventi del cielo (di tutti) e delle date che ti riguardano.
- [O] "Dai al Cerchio la tua nascita": porta ai dati di nascita.
- [P] Nessuna. [G] Nessuno. [E] Nessuno. Controlli ulteriori: da verificare.

---

### F30. Account (menu utente)
- Si apre: barra sottile in alto > tocco sul volto. Titolo "Il tuo account".
- File: `lib/features/account/account_screen.dart`, `profile_screen.dart`, `dati_di_nascita_screen.dart`, `notifiche_screen.dart`, `riscatta_l_invito.dart`, `invita_un_amico.dart`.
- [O] "Profilo": nome nel Cerchio; avatar ("Scatta o scegli una foto", "Rimuovi la foto e usa il tuo segno", "Il tuo volto nel Cerchio": Scatta una foto | Scegli dalla galleria).
- [O] "I tuoi dati di nascita": data, "Ora di nascita", "Luogo di nascita" (ricerca città con il paese), "Dove vivi adesso", "Salva".
- [O] "Il tuo Cerchio" (F23).
- [O] "Invita un amico" (premio in Eos a te e a chi entra). "Chi ti ha invitato" (riscattare un invito).
- [O] Per chi ha accesso con email: "Verifica la tua email", "Cambia la tua email", "Cambia la Password".
- [O] Per chi è ospite: "Registra e conserva il tuo Cerchio" con le vie Google, Apple (su iOS) ed email (`custodia_del_cielo.dart`).
- [O] "Rivedi il primo approdo" (i cinque fumetti).
- [O] Interruttore "Tutorial all'apertura".
- [O] "Abbonamento" (F33), "Diario Cosmico" (F28), "Notifiche" (F31), "Impostazioni" (F32).
- [O] "Esci dal Cerchio" (conferma "Uscire dal Cerchio?").
- [O] "Privacy e dati": "Privacy policy", "Privacy e permessi", "Scarica i tuoi dati", "Cancella i tuoi dati" ("Ricominciare da zero?"), "Cancella il tuo account" (prima chiede "Prima di andare: perché?" e poi l'ultima conferma). Le ultime due sono IRREVERSIBILI: da fare solo su un account di collaudo.
- [P] Nessuna differenza di piano in questa schermata.
- [G] Nessuno. [E] Nessuno (l'invito dà Eos).

### F31. Notifiche
- Si apre: Account > "Notifiche".
- File: `lib/features/account/notifiche_screen.dart`, `lib/core/rituals/scelta_degli_avvisi.dart`, `avvisi_del_rito.dart`.
- [O] Per ognuno dei 4 Doni del giorno: interruttore (Arcano dell'Alba, Soffio del Destino, La Runa del Tramonto, Sigillo del Sogno) e "cambia l'ora" (07:00, 13:00, 18:30, 22:30 di partenza). Di partenza accesi Alba e Sogno.
- [O] "Dal cielo dell'Oroscopo": interruttori "L'ora d'oro" (serve la carta natale) e "Il Rahu Kalam" (arriva se si legge la tradizione vedica).
- [O] Permesso del telefono: "Il telefono non mi lascia ancora avvisarti. Tocca per concedere il permesso."
- [O] "Le chiamate arrivano?": "Guarda la coda" e "Provala adesso".
- [O] Il conto: "Un Dono ti chiama" / "N Doni ti chiamano".
- [P] Notifiche del Cerchio: Viandante "un mese di prova, poi gli avvisi del telefono"; dall'Iniziato "sempre, anche a Cerchio chiuso".
- [G] Nessuno. [E] Nessuno.

### F32. Impostazioni (con Suono e Privacy e permessi)
- Si apre: Account > "Impostazioni". Sottoschermate: "Suono" e "Privacy e permessi".
- File: `lib/features/settings/settings_screen.dart`, `suono_screen.dart`, `privacy_e_permessi_screen.dart`, `la_riga_della_lingua.dart`.
- [O] "Il tuo piano": porta a F33.
- [O] "Aspetto": interruttori "Riduci animazioni" (meno movimento e parallasse) e "Modalità semplice" (grafica alleggerita; abbassa il Quality Tier).
- [O] "Lingua": Italiano | English (selettore; i testi dei Maestri restano in italiano).
- [O] "Voce e sottotitoli": interruttore "Sottotitoli".
- [O] "Suono e vibrazione": comando grande che governa suoni e vibrazioni insieme.
- [O] "Suono" (si apre solo se il comando grande è acceso): "Effetti sonori" (interruttore) e "Volume degli effetti"; "Musica d'ambiente" (interruttore) e "Volume della musica".
- [O] "Account" (accesso e profilo). "Messa a punto" (riga che mostra cosa fa il movimento del cielo).
- [O] "Privacy e permessi": "Cosa diciamo di noi" (disclaimer, "Leggi il disclaimer per esteso"), "Cosa contiamo", "Da dove vengono i numeri", "Cosa tocca del telefono" (permessi di sistema: si concedono da qui).
- [P] Nessuna. [G] Nessuno. [E] Nessuno.

### F33. I piani del Cerchio (Abbonamento)
- Si apre: Account > "Abbonamento"; Impostazioni > "Il tuo piano"; l'invito "Guarda i piani" nel Borsellino e i fogli di upgrade.
- File: `lib/features/pricing/pricing_screen.dart`, `upgrade_invite.dart`, `lib/core/entitlement/plan_catalog.dart`.
- [O] Carta "Demo" (tutte le funzioni attive, per la presentazione).
- [O] Una carta per piano (Viandante, L'Iniziato, L'Adepto, L'Illuminato) con le sue voci; ciclo di prezzo Settimana | Mese | Anno per ogni piano (di partenza Anno).
- [O] "Prova Viandante in Demo" (piano gratuito) oppure "Passa a [piano]" > "Attiva in Demo" (cambia davvero il piano sul server, vedi 0.3).
- [O] "Confronto completo": tabella con tutte le righe della matrice (pubblicità, carta natale, oroscopi, memoria, amici, domande, stese, rune, sinastrie, Oracolo, Lunario, Respiro, notifiche, dote Eos e altre).
- [P] È la schermata che cambia il piano. Prezzi e dote nel punto 0.2.
- [G] Nessuno. [E] Nessuno (nessun acquisto reale).

### F34. Borsellino (Eos)
- Si apre: barra sottile in alto > moneta; anche dai fogli di spesa quando mancano Eos.
- File: `lib/design_system/components/borsellino.dart`, `lib/core/entitlement/registro_degli_eos.dart`, `pacchetti_di_eos.dart`, `spesa_degli_eos.dart`, `il_consenso_della_spesa.dart`.
- [O] Saldo (animato quando cambia).
- [O] "Cosa puoi fare oggi": un residuo per ogni limite del giorno del piano (domande, approfondimenti, confronti, gettate, stese, stese a dieci, sinastrie).
- [O] "La prossima ricarica": quando tornano gli Eos (guadagnati coi Sigilli, bonus mensile se il piano lo porta).
- [O] Pacchetti: Manciata di Eos 300 / 2,99 €; Borsa di Eos 900 / 7,99 €; Scrigno di Eos 2.500 / 19,99 € (solo elencati, non in vendita: il foglio lo dice).
- [O] "Guarda i piani" (porta a F33).
- [O] Conferma della spesa: ogni spesa sopra 100 Eos passa dalla conferma comune ("Procedi" | "Non ora").
- [P] Il testo del Borsellino cambia con il piano (bonus mensile sì o no).
- [G] I residui del giorno (tabella 0.4). [E] Tutte le spese del punto 0.5.

---

## 2. Cinque gruppi per cinque collaudatori

Ordinati per vicinanza di percorso nell'app. Il numero F rimanda alle schede sopra.

### Gruppo A: Medora, le carte e la coppia (6 funzioni)
Percorso comune: Home > Medora > Cartomanzia e Compatibilità, più la casella "Alba".
1. F16 Arcano dell'Alba (dono del mattino, striscia sulla home)
2. F04 Stesa di Tarocchi
3. F05 Oracolo degli Angeli
4. F26 Angelo Custode personale (dal Passaporto > Angeli, collega all'Oracolo)
5. F06 Sinastria VIP
6. F07 Sinastria Evolutiva
Punti di piano e giorno da coprire: stese 1/3/3/5 e Croce Celtica 0/0/1/1, tre carte dell'Oracolo (Viandante solo il Custode), capitoli 2 su 5, riscatti Eos 150/150/100.

### Gruppo B: Medora, il cielo e la Luna (6 funzioni)
Percorso comune: Home > Medora > Astrologia e Lunologia, tocco sul cielo, Passaporto.
1. F03 Oroscopo Universale (anche per un amico)
2. F20 Cielo reale
3. F08 Il Respiro della Luna
4. F09 Calendario Lunare Personale
5. F29 Calendario degli eventi cosmici
6. F19 Sigillo del Sogno (dono della sera, Luna di stanotte)
Punti di piano e giorno da coprire: periodi Giorno/Settimana/Mese/Anno, Vedica e Cinese, Lunga con 50 Eos al Viandante, anno con 300 Eos, mesi avanti 0/1/12, categorie di "Trova il giorno", avvisi e collana del Respiro.

### Gruppo C: Aura e Calìgo, corpo, rituali e magia (7 funzioni)
Percorso comune: barra in basso Aura e Calìgo, più le caselle "Soffio" e "Tramonto" della striscia.
1. F10 Meditazione
2. F11 Mappa del Viso
3. F17 Soffio del Destino
4. F13 Estrazione Rune
5. F14 Il Viaggio dello Sciamano
6. F15 Sigillo dell'Intenzione (con Libro dei Sigilli)
7. F18 La Runa del Tramonto
Punti di piano e giorno da coprire: gettate 1/2/3/3 e Lunga dall'Iniziato, sigilli vivi 1/2/3/5, discese e segni (attenzione alla Demo, punto 0.6), fotocamera e microfono con i loro ripieghi tattili.

### Gruppo D: Passaporto, Diario e conversazione (6 funzioni)
Percorso comune: barra in basso "Passport", menu della chat e Account > Diario Cosmico.
1. F25 Passaporto
2. F12 Test Archetipo
3. F27 Sentieri e Traguardi
4. F28 Diario Cosmico
5. F21 Chat dei Maestri
6. F22 LIVE con i Maestri
Punti di piano e giorno da coprire: domande 3/12/17/21, approfondimenti e confronti, memoria e sintesi, minuti di LIVE 0/0/80/150, lettura del mese dall'Iniziato.

### Gruppo E: Home, Cerchio sociale, account e piani (8 funzioni)
Percorso comune: avvio, barra in alto (volto, Online, moneta), Account.
1. F01 Home "Il Cerchio" e domini dei Maestri
2. F23 Il tuo Cerchio
3. F24 Gli Enigmi del Cerchio
4. F30 Account
5. F31 Notifiche
6. F32 Impostazioni (Suono, Privacy e permessi)
7. F33 I piani del Cerchio (cambio piano in Demo, serve anche agli altri gruppi)
8. F34 Borsellino (Eos)
Punti di piano e giorno da coprire: arti preferite, segni 5/20/40/60, amici 3/15/50/150, doni dall'Adepto, notifiche del Doni, spese Eos e conferma sopra 100. Il Gruppo E tocca account e dati: cancellazioni e regalo di Eos solo su account e dati di collaudo, mai di produzione.

Nota per tutti i gruppi: per provare un piano diverso si usa F33 (Account > Abbonamento > "Attiva in Demo"). Il giorno dopo dei budget del server non si ottiene spostando la data del telefono (punto 0.4).

---

## 3. Da verificare (con dove guardare)
1. Prezzo del riscatto della stesa: 150 (server, `functions/src/borsellino.ts` `PREZZI_DEL_RISCATTO`) o 120 (`ListinoDegliEos.stesaTreCarte`)? Guardare il foglio "Le stese di oggi sono finite" a video.
2. Righe di matrice senza interfaccia trovata: "Il ritorno della carta", "Rileggere una stesa", "Card della stesa da condividere" (`RigaDelPiano.ritornoDellaCarta`, `rileggereLaStesa`, `cardDellaStesa`), report PDF del Diario, "Albero della Vita dinamico", "Correlazione mood-transiti", "Transit tracker con alert", "Accesso anticipato". Possono comparire nei piani ma non avere un controllo.
3. "Oracoli secondari, meditazioni e frequenze" (Adepto): la Meditazione non legge il piano (`grep Tier lib/features/maestri/aura/meditation` non trova nulla).
4. Sinastria Evolutiva: `FeatureCatalog` la dice premium tier2, `ArtCatalog` attiva. Guardare cosa fa il Viandante.
5. Se spostare la data del telefono cambia qualcosa sui budget: il codice dice di no (giorno del server, `functions/src/giorno.ts`); cambia solo ciò che è locale.
6. Quale numero di domande/minuti applica il server nell'annuale (`nellAnnuale`, `functions/src/budget.ts`).
7. Quali controlli ha del tutto il Cielo reale e il Calendario degli eventi (`cielo_reale_screen.dart` righe 3250-3800; `calendario_degli_eventi_screen.dart`).
8. Dove compare "Un posto in più fra gli amici" (100 Eos) e se i limiti degli amici (3/10/50 dell'Oroscopo e 3/15/50/150 del Cerchio) hanno una schermata di riscatto.
9. Se il LIVE, per chi non ha minuti, mostra un invito o una porta chiusa (`la_porta_del_vivo.dart`).
10. Regalare Eos agli amici: probabilmente nessun Eos regalabile esiste (nessun accredito di acquisto o dote).
11. Gli stati dei traguardi dopo il 20° e il Passaporto per piano (`lib/features/passport` non legge il piano).
12. I pacchetti di Eos non si possono comprare: nessun test di acquisto è possibile (`acquistiCollegatiAUnNegozio = false`).
