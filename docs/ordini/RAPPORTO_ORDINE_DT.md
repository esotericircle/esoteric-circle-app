# RAPPORTO DELL'ORDINE DT, I DONI DEL GIORNO, RIFONDAZIONE

**Data:** 17 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_DT_MANIFESTO.md`. **Nessuna build**: l'ordine
la vieta, e nessuna e' stata costruita.

**Ventisette voci**: le venti dell'ordine e le sette del chiarimento dello
stesso giorno. **Ventisei chiuse, una ferma: DT.05, in attesa della decisione di Mauro sulla distribuzione della funzione `cammino`. **L'ordine non e' chiuso.****

L'ordine segue la sequenza che l'ordine chiede per il rapporto: scarti per
voce, file toccati, riferimenti al Rito dell'Alba e all'Arcano del Giorno,
test, sbarramento, lacune e decisioni.

---

## 1. GLI SCARTI, VOCE PER VOCE

Regola DT.00.A: dove l'ordine non corrisponde al ramo non si e' adattato il
codice all'ordine. Gli scarti sono questi, con il file e la riga.

- **DT.01, DT.02 e DT.06, i nomi degli arcani.** L'ordine scrive *Il
  Bagatto* e *Le Stelle*; il corpus scrive **Il Mago** e **La Stella**
  (`docs/corpus/tarocchi.md`, righe 9 e 41) e il catalogo li nomina uguale
  (`lib/core/tarot/tarot_card.dart`, righe 157 e 374). **Si sono usati i nomi
  del corpus**, con la corrispondenza nella tabella del manifesto. Il corpus
  numera inoltre **La Giustizia VIII e La Forza XI** (righe 23 e 29), come i
  mazzi prima del Waite Smith: l'attribuzione segue il nome, Bilancia e Leone.
- **DT.03, il budget dei tarocchi.** L'ordine chiede che il dono *non consumi
  il budget di consultazioni dei tarocchi*: **un budget dei tarocchi separato
  non esiste**. C'e' il limite delle **stese** in
  `lib/core/entitlement/question_allowance.dart`, righe 578-611
  (`limiteStese`, `steseRimaste`, `registraStesa`). La prova misura quello.
- **DT.05, la persistenza al cambio di dispositivo.** L'approccio esistente e'
  il cammino custodito: `lib/core/cammino/cammino_da_custodire.dart` e
  `functions/src/cammino.ts`. **Il server scarta i campi che non conosce**
  (`leggiCammino`, righe 116-175 prima della modifica): il diario dell'Alba
  **non viaggiava** senza toccare il server. Il campo e' stato aggiunto nei due
  lati con la sua fusione e le sue prove, **ma la funzione non e' distribuita**:
  finche' non lo e', il diario sopravvive alla chiusura dell'app e non al cambio
  di telefono. E' la ragione per cui la voce e' ferma.
- **DT.09, DT.11, DT.12 e DT.13 contro un modello.** L'ordine le scriveva per una
  generazione a runtime; **l'Arcano del Giorno di oggi non passava da nessun
  modello** (`lib/core/rituals/arcano_del_giorno.dart`, righe 56-95 prima di
  toglierlo). Mauro ha deciso il corpus senza modello, e il chiarimento ha
  riscritto le tre voci (DT.21-24).
- **DT.10, la relazione "stessa famiglia".** Con la regola dell'ordine due
  zodiacali qualunque sono in relazione, e cosi' due planetarie: il filo con
  ieri compare **279 giorni su 590** nella simulazione della prova. Non e' uno
  scarto col codice ma una conseguenza della regola scritta: la si riporta
  perche' sia una scelta e non una sorpresa.
- **DT.14, le push del server.** L'ora del Soffio la manda il telefono
  (`functions/src/push.ts`, `scriviLeScelteDellePush`): il server non la scrive
  a mano, e l'allineamento alle tredici e' gia' dell'app. **I testi del server
  invece sono scritti a mano** (`functions/src/push.ts`, righe 71-92): il dono
  dell'alba dice *"Solleva l'alba"* e il Sigillo firma *Caligo*. Sono giusti per
  la build 2265, che e' installata, e sbagliati per la prossima: **non sono
  stati cambiati**, vedi le decisioni.
- **DT.15, il Sigillo e il suo Maestro.** L'ordine chiede di togliere il
  meccanismo che sceglie la voce. **Il Sigillo non leggeva `guide`**: leggeva
  `DailyRituals.nightMaestro` (`lib/features/rituals/dream_rite_screen.dart`,
  riga 176, e `lib/core/rituals/dream_rite_corpus.dart`, riga 235). Tolto
  quello, il Maestro passa dalla porta dei doni. **La mappa dei gesti dei
  sentieri resta com'e'**: `sogno` e' del sentiero di Caligo e `alba` di quello
  di Aura (`lib/core/sensi/voce_del_responso.dart`, righe 81-90, e il generato
  `maestro_del_gesto.dart`), perche' e' la struttura dei traguardi della
  revisione F e non il Maestro del dono.
- **DT.17, l'architettura per sei doni.** Vedi la sezione dei numeri scritti
  a mano, dentro il paragrafo 2.
- **DT.22, "l'unica leva".** Il chiarimento dice che l'unica leva contro la
  collisione e' la quantita' di letture con l'ordine di consumo. **C'e' una
  seconda leva, piu' piccola**: il primo movimento si compone da 48 aperture
  per 4 clausole nell'ordine della persona. Lascia uguali il dono e la chiusura
  di Medora, che sono cio' che si condivide, quindi la conclusione del
  chiarimento resta vera sulla sostanza.
- **DT.24, "scrivili prima del corpus".** Le prove sono state scritte e **viste
  rosse sul corpus vuoto** prima che il corpus entrasse nel repo. Le letture
  pero' erano gia' state **abbozzate nello spazio di lavoro** quando il
  chiarimento e' arrivato: lo si dichiara. La bozza e' stata poi riscritta per
  cinque giri contro le prove: 50 ritocchi di aperture, 8 coppie di versi, i
  nomi dei simboli, un tema delicato e una previsione certa.
- **DT.25, la Carta del giorno.** Il percorso che la calcolava per conto suo
  esisteva: `lib/core/chat/la_carta_del_giorno_in_chat.dart` chiamava
  `ArcanoDelGiorno.di`. E' stato tolto con tutto `arcano_del_giorno.dart`.
- **DT.26, i pulsanti.** Sono **quindici**, come l'ordine DS li aveva lasciati.

## 2. I FILE TOCCATI, CON IL MOTIVO

Tre commit di lavoro dopo la consegna DS (`65bd5811`): **141 file**, 19 nuovi,
22 tolti, 100 modificati, piu' i documenti di chiusura. Qui per gruppo, col
motivo.

### Nuovi, il motore dell'Arcano dell'Alba (`lib/core/rituals/arcano_dell_alba/`)

| file | motivo | voci |
|---|---|---|
| `attribuzioni_degli_arcani.dart` | le ventidue attribuzioni della Golden Dawn, le tre famiglie, i governi dei pianeti e le cinque relazioni documentate per il filo | 06, 07, 10 |
| `sacchetto_dell_alba.dart` | i quarantaquattro stati senza reimbussolamento, la distanza di un quarto del ciclo, l'estrazione fra i soli stati componibili, la lettura che non si fida del salvato | 04, 05 |
| `lettura_dell_alba.dart` | la forma di una lettura del corpus: carta, verso, numero, parola, dono, Medora | 09, 21 |
| `letture_dell_alba_dati.dart` | **generato** da `docs/corpus/tarocchi.md`: 132 letture, tre per stato | 09, 21 |
| `forme_dell_alba.dart` | le 48 aperture del primo movimento, le clausole per famiglia, le frasi del filo per relazione | 08, 10, 12 |
| `responso_dell_alba.dart` | la composizione dei tre movimenti da una lettura, un'apertura, una clausola e il filo | 08, 10 |
| `diario_dell_alba.dart` | il diario della persona: seme, sacchetto, code delle letture, registri, ripieghi, ultima consegna; l'estrazione del giorno | 05, 11, 12, 22, 23 |
| `archivio_dell_alba.dart` | il diario sul disco, la carta di oggi per chi la chiede, l'adozione dal cammino del Cerchio | 05, 25 |

### Nuovi, altrove

| file | motivo | voci |
|---|---|---|
| `lib/core/responsi/scelta_senza_ripetere.dart` | **l'impianto unico anti ripetizione**, estratto dalla Stesa | 27 |
| `lib/features/rituals/arcano_dell_alba_screen.dart` | la schermata: tre carte coperte, il giro, i tre movimenti | 02, 04, 08 |
| `tool/genera_letture_dell_alba.py` | genera i dati dal corpus, perche' il corpus si tocchi alla fonte | 21 |
| `docs/ordini/ORDINE_DT_MANIFESTO.md` | il manifesto | 18 |
| sei prove nuove, la guardia dell'ordine e l'aiuto `test/nucleo_del_responso.dart` | nella sezione dei test | 19, 24 |

### Tolti

| file | motivo |
|---|---|
| `lib/features/rituals/dawn_rite_screen.dart`, `day_oracle_screen.dart` | i due doni fusi nell'Arcano dell'Alba (DT.01) |
| `lib/features/rituals/ritual_view.dart`, `dove_sei_adesso.dart` | rimasti senza chiamanti dopo le due schermate: contati col grep dei chiamanti |
| `lib/core/rituals/arcano_del_giorno.dart` | il percorso che calcolava la carta per conto suo (DT.25) |
| sette prove | nella sezione dei test, col motivo una per una |
| dieci anteprime `docs/preview/rito-alba*.png`, `alba-ponte-al-soffio.png`, `arcano-*.png` | ritraevano schermate tolte |

### Modificati, lib

| file | motivo | voci |
|---|---|---|
| `lib/core/rituals/daily_elements.dart` | quattro doni; `oracle` tolto; Medora all'alba e al Sogno; le fasce dalle ancore; `numeroDellAvviso`, `conArticolo`, `elencoInFrase`, `quantiInLettere` | 01, 14, 15, 17 |
| `lib/core/rituals/avvisi_del_rito.dart`, `scelta_degli_avvisi.dart`, `lib/services/avvisi_locali.dart` | l'avviso dell'Arcano dell'Alba, la spiegazione composta, l'id per dono, il 1102 da spegnere, i nomi dei canali | 01, 14, 17 |
| `lib/core/permissions/app_permission.dart`, `registro_dei_permessi.dart`, `lib/core/rituals/chiamata_del_primo_giorno.dart`, `lib/features/account/notifiche_screen.dart` | il testo del permesso composto dai doni, non piu' costante | 01, 17 |
| `lib/core/rituals/filo_del_giorno.dart`, `lib/features/rituals/dream_rite_screen.dart`, `lib/core/rituals/dream_rite_corpus.dart`, `daily_rituals.dart` | il Sigillo a Medora e il richiamo del dono della carta dall'archivio (decisione di Mauro) | 15 |
| `lib/core/chat/la_carta_del_giorno_in_chat.dart`, `lib/features/maestri/chat/maestro_chat_controller.dart`, `maestro_chat_screen.dart` | la Carta del giorno letta dall'estrazione | 25 |
| `lib/core/chat/immersive_intents.dart`, `lib/features/maestri/art_navigation.dart`, `immersive_navigation.dart`, `chat_openers.dart` | il pulsante che apriva l'Arcano del Giorno apre l'Arcano dell'Alba | 26 |
| `lib/features/santuario/daily_strip.dart`, `lib/features/shell/dove_si_vede_la_barra.dart` | quattro caselle; la schermata nuova fra quelle senza barra | 01, 02 |
| `lib/core/ricordi/arti_con_responso.dart`, `conti_delle_arti.dart`, `lib/core/sigilli/gesti_delle_arti.dart` | le arti tolte, l'eccezione dichiarata senza azioni, i due gesti sulla schermata nuova | 01, 02 |
| `lib/core/sigilli/sentiero_loto.dart`, `sentiero_costellazione.dart`, `lib/features/passport/cosmic_passport_screen.dart`, `lib/features/sigilli/la_mappa_del_sentiero.dart` | i nomi dei gesti; i due sentieri **generati** da `tool/corpus_traguardi.py` | 01 |
| `lib/core/cammino/cammino_da_custodire.dart`, `custode_del_cammino.dart` | il diario dell'Alba nel cammino custodito | 05 |
| `lib/core/identity/cio_che_e_tuo.dart`, `scarico_dei_tuoi_dati.dart` | il diario e' un dato della persona: si cancella e si scarica | 05 |
| `lib/core/responsi/confine_del_responso.dart` | il nome della carta *La Morte* non e' la morte rivolta alla persona | 08 |
| `lib/design_system/theme/abito_del_responso.dart`, `lib/features/rituals/ritual_gift_card.dart` | l'abito di giorno e i rami dell'Alba tolti | 01 |
| `lib/core/tarot/voce_della_stesa.dart` | la Stesa passa dall'impianto unico | 27 |
| `lib/core/entitlement/plan_catalog.dart`, `lib/core/l10n/app_strings.dart` | i nomi; due righe del piano fuse in una | 01 |

### Modificati, server, strumenti e documenti

| file | motivo | voci |
|---|---|---|
| `functions/src/cammino.ts`, `cammino.test.ts` | il campo del diario, il suo peso massimo e la fusione che tiene il piu' avanti. **Non distribuito** | 05 |
| `tool/corpus_traguardi.py`, `docs/corpus/Traguardi_165_Revisione_F.json` | i nomi dei gesti alla fonte | 01 |
| `docs/corpus/tarocchi.md` | l'attribuzione in ogni maggiore e la sezione delle 132 letture | 06, 09, 21 |
| `docs/guardie.md` | il registro a 434: quattro righe nuove, sei tolte, il paragrafo del ricalcolo | 19 |
| `docs/responsi/lunghezze.md`, `docs/tipografia/spazi.md`, `docs/tipografia/alba_contrasto.md`, `docs/testi/cosa_dicono_i_doni.md` | **rigenerati** dalle loro prove | 01 |
| 52 prove modificate | nella sezione dei test | 19 |

### I numeri scritti a mano (DT.17)

DT.17 chiede che aggiungere un sesto dono non sia una caccia ai numeri. Il
censimento ha cercato *cinque*, *5*, gli elenchi dei nomi dei doni, gli
indici per posizione e gli `switch` sui doni, in `lib`, `functions` e `test`.

**Resi composti dall'enumerazione**, cioe' un dono nuovo li aggiorna da solo:

| dove | prima | adesso |
|---|---|---|
| `DailyElements.current`, `lib/core/rituals/daily_elements.dart` | una catena di `if` sulle ore dei cinque doni | l'ultimo dono la cui ancora e' passata, dalle ancore ordinate |
| `AvvisiDelRito.idDelDono`, `avvisi_del_rito.dart` | `1100 + indice` nell'enumerazione: togliere un dono spostava gli id degli altri | `1100 + numeroDellAvviso`, **un numero fisso per dono**; il 2 dell'`oracle` non torna |
| `AvvisiDelRito.spiegazione` e il testo del permesso in `app_permission.dart` | *"Sono cinque avvisi al giorno"* coi cinque nomi scritti | `quantiInLettere` ed `elencoInFrase` |
| le prove dei doni | *"cinque"* in una trentina di punti | il numero letto da `DailyElement.values` |

**Restano scritti a mano**, e per ognuno chi se ne accorge se il sesto dono manca:

| dove | cosa | chi se ne accorge se manca il sesto |
|---|---|---|
| la dichiarazione di `DailyElement` | ancora, Maestro, titolo, `numeroDellAvviso` per dono | **il compilatore**: ogni valore dell'enumerazione li pretende |
| `daily_strip.dart`, righe 34-41 e 100-107; `AvvisiDelRito.testoDelDono`, riga 373 | la rotta, l'icona e il testo dell'avviso di ogni dono | **il compilatore**: sono `switch` esaustivi senza `default` |
| `lib/core/sigilli/gesti_delle_arti.dart` | il gesto e la schermata di ogni dono | `ogni_arte_entra_nel_cammino` |
| `lib/services/avvisi_locali.dart` | il canale Android di ogni dono | `cinque_avvisi_uno_per_dono` |
| `lib/core/ricordi/arti_con_responso.dart` | le arti con le tre azioni e quelle senza | `ogni_custodito_ritrova_la_sua_arte` |
| `lib/features/shell/dove_si_vede_la_barra.dart` | le schermate senza barra | `ogni_schermata_dichiara_la_barra` |
| `cosmic_passport_screen.dart`, `_nomi`, riga 1329; `la_mappa_del_sentiero.dart`, `nomeDellArte`, riga 88 | il nome del gesto nella frase | **nessuna guardia**: il passaporto salta in silenzio un gesto senza nome (riga 1352) e la mappa ripiega su *"La casa di"* col Maestro (riga 110) |
| `SceltaDegliAvvisi.accesiDiPartenza`, `scelta_degli_avvisi.dart`, riga 71 | quali doni sono accesi alla prima apertura | **nessuno**: e' una scelta di prodotto per dono, e un dono nuovo partirebbe spento |
| `lib/core/entitlement/plan_catalog.dart` | le righe del piano, una per funzione | `entitlement_test`, che conta le righe |
| `functions/src/push.ts`, righe 59, 71-92 e 116-121 | `DONI`, `TESTI` e `ID_DEL_DONO` del server | **nessuno sul telefono**: e' il server, e oggi porta ancora `oracle` per la build 2265 (decisione 3) |
| `DailyElements.quantiInLettere`, `daily_elements.dart`, riga 260 | le parole da zero a dieci | la prova di `daily_elements_test`; oltre dieci doni serve una parola in piu' |
| `DailyStrip.larghezzaCasella`, riga 353 | `utile / 3` | **non e' il numero dei doni**: sono le caselle intere visibili prima della sbirciatura, e con sei doni la fascia scorre come con quattro |

**Il cinque residuo in `lib` sta solo nei commenti.** Quelli che raccontano un
ordine passato (*"RISCRITTA PER I CINQUE DONI. Ordine BC voce 05"*) restano,
perche' sono storia. Tre commenti che descrivevano il presente e dicevano
*cinque* sono stati corretti a lavoro chiuso:
`lib/core/ricordi/riassunti_del_tempo.dart`, riga 51,
`lib/core/rituals/chiamata_del_primo_giorno.dart`, riga 39, e
`cosmic_passport_screen.dart`, riga 1349.

## 3. I RIFERIMENTI AL RITO DELL'ALBA E ALL'ARCANO DEL GIORNO

Il censimento e' stato fatto su `lib`, `test`, `tool`, `functions`, `assets` e
`docs`, con le chiavi di traduzione, le chiavi dei widget, le preferenze, i
canali, i gesti e gli eventi. **La voce `DailyElement.dawn` non ha cambiato
nome**: e' l'Arcano dell'Alba, e le preferenze, le serie e i canali salvati
col nome `dawn` restano di chi li aveva.

| riferimento | dove | trattamento |
|---|---|---|
| il dono `oracle` | `lib/core/rituals/daily_elements.dart` | **tolto**; `dawn` diventa l'Arcano dell'Alba, Medora, 7:00 |
| *"Rito dell'Alba"* e *"Arcano del Giorno"* come titoli dei doni | `daily_elements.dart`, `plan_catalog.dart` (due righe del piano fuse in una), `registro_dei_permessi.dart`, `app_strings.dart` (`day_oracle`), `immersive_intents.dart` (pulsante) | **rinominati** in *Arcano dell'Alba* |
| *"Sono cinque avvisi al giorno"* coi cinque nomi | `avvisi_del_rito.dart` (`spiegazione`), `app_permission.dart` | **composti dai doni** (`elencoInFrase`, `quantiInLettere`) |
| titolo e testo dell'avviso dell'alba | `avvisi_del_rito.dart` (`titolo`, `testo`, `testoDelDono`) | **riscritti**: *"L'Arcano dell'Alba"*, *"La tua carta di oggi ti aspetta coperta."*; il testo dell'`oracle` tolto |
| l'id dell'avviso per posizione | `avvisi_del_rito.dart` (`idDelDono`) | **numero fisso per dono** (`numeroDellAvviso`), il 1102 dell'Arcano del Giorno fra le chiamate di prima da spegnere |
| i canali Android `rito_alba`, `dono_dawn`, `dono_oracle` | `lib/services/avvisi_locali.dart` | nomi a video **rinominati**, id dei canali **invariati**; `dono_oracle` **tolto** dalla dichiarazione |
| il Soffio *"a metà mattina"* | `avvisi_locali.dart` | **"a metà giornata"**, voce 14 |
| la scelta di partenza coi cinque doni | `scelta_degli_avvisi.dart` | `oracle` **tolto** |
| il gesto `oracolo` fra i conti dei doni | `lib/core/ricordi/conti_delle_arti.dart` | **tolto** dai doni: il gesto resta nel cammino, lo registra l'Arcano dell'Alba |
| i gesti `alba` e `oracolo` e le loro schermate | `lib/core/sigilli/gesti_delle_arti.dart` | **tutti e due** su `arcano_dell_alba_screen.dart` (decisione del cammino) |
| i nomi dei gesti nel passaporto e nella mappa dei sentieri | `cosmic_passport_screen.dart`, `la_mappa_del_sentiero.dart` | `alba` e `oracolo` **nominano l'Arcano dell'Alba** |
| le frasi dei traguardi, 30 col Rito dell'Alba e 18 con l'Arcano del Giorno | `tool/corpus_traguardi.py` (`ARTE`), generati in `docs/corpus/Traguardi_165_Revisione_F.json`, `sentiero_loto.dart`, `sentiero_costellazione.dart` | **rinominati alla fonte e rigenerati**: 78 righe cambiate, solo il nome |
| le arti con responso `alba` e `oracolo` | `lib/core/ricordi/arti_con_responso.dart` | **tolte** da quelle con le tre azioni e **dichiarate** in `senzaAzioni` col perche'; i custoditi di prima dell'`oracolo` si leggono ancora (`artwork_del_ricordo.dart` invariato) |
| le aperture della chat `ChatOpeners.alba` e `oracolo` | `chat_openers.dart` | **tolte**: nessuno le chiamava piu' |
| il pulsante della chat verso `day_oracle` | `art_navigation.dart`, `immersive_navigation.dart`, `ImmersiveTarget.arcanoDelGiorno` | **apre l'Arcano dell'Alba**; il bersaglio **rinominato** `arcanoDellAlba`; l'id d'arte `day_oracle` resta, perche' e' la chiave dei conti |
| la carta del giorno calcolata in chat | `la_carta_del_giorno_in_chat.dart`, `maestro_chat_controller.dart`, `maestro_chat_screen.dart` | **legge l'estrazione del giorno**; la nascita passata al controller **tolta**, non serviva piu' a niente |
| `ArcanoDelGiorno` | `lib/core/rituals/arcano_del_giorno.dart` | **tolto**; `CartaDiNascitaDeiTarocchi` resta, la usa l'onboarding |
| `DawnRiteScreen`, `DayOracleScreen` | `lib/features/rituals/` | **tolte**; con loro `ritual_view.dart` e `dove_sei_adesso.dart`, rimaste senza chiamanti |
| i rami dell'Alba nella scheda del dono | `ritual_gift_card.dart` | **tolti** il rituale di oggi, la parola con la lente e la domanda di ieri; la scheda serve il Soffio |
| `DailyRituals.nightMaestro` | `daily_rituals.dart`, `dream_rite_screen.dart`, `dream_rite_corpus.dart` | **tolto**: il Sigillo passa dalla porta dei doni, Medora |
| la parola dell'alba richiamata la sera | `filo_del_giorno.dart` (`segnaLaParola`, chiave `filo.parola_del_giorno`), `dream_rite_screen.dart` | **tolta la chiave sua**: il Sigillo legge **il dono della carta** dall'archivio dell'Alba (decisione di Mauro); l'estrazione delle rune (`rune_draw_screen.dart`, riga 145) la chiede a `parolaDiStamattina` per le domande del Cerchio, e adesso la riceve dall'archivio dell'Alba, solo quando la carta di oggi e' zodiacale |
| l'abito di giorno dell'Alba | `abito_del_responso.dart` | **tolto**: tutti i doni portano la notte |
| l'elenco delle schermate senza barra | `dove_si_vede_la_barra.dart` | `ArcanoDellAlbaScreen` **al posto** delle due |
| i fondali dell'alba | `assets/ritual_backgrounds/dawn_sky_night.png`, `dawn_sky_day.png`, `dawn_sun.png` | **restano nel bundle** e nessuna schermata li monta piu': da decidere se toglierli |
| le anteprime | `docs/preview/rito-alba*.png`, `alba-ponte-al-soffio.png`, `arcano-*.png` | **tolte**; nascono `arcano-alba-coperte.png`, `arcano-alba-girata.png`, `arcano-alba-responso.png` |
| la tabella del contrasto | `docs/tipografia/alba_contrasto.md` | **rigenerata** sull'Arcano dell'Alba |
| le push del server | `functions/src/push.ts` (`DONI`, `TESTI`, `ID_DEL_DONO`) e la copia compilata | **non toccate**: sono compatibili con le due build e i testi cambiano col rilascio, vedi le decisioni |
| analitiche | `RegistroDelRitorno`: `ritoCompiuto` col contesto del gesto, `ritornoDaAvviso` col nome del dono | **nessun cambio di nome**: `alba` e `dawn` restano le chiavi; `oracolo` continua ad arrivare dal gesto |
| i documenti storici | `docs/ordini/*`, `docs/RELAZIONE_NOTTE.md`, `docs/consegne/*`, i briefing | **non toccati**: raccontano cio' che era vero allora |
| le prove | 31 file che non compilavano e altri che misuravano i doni tolti | **riallineate, ridotte o tolte** una per una, nella sezione dei test |

## 4. I TEST, E COSA DIMOSTRANO

### Le prove nuove, viste rosse prima

| prova | cosa dimostra | voci | come e' stata vista rossa |
|---|---|---|---|
| `test/le_ventidue_attribuzioni_test.dart` | tre piu' sette piu' dodici fa ventidue; ogni maggiore del mazzo ha **una** attribuzione e nessuna resta senza carta; ogni pianeta e ogni segno una volta; le ventidue attribuzioni dell'ordine carta per carta; le relazioni del filo su coppie di cui la tradizione sa la risposta (stesso elemento, governo nei due sensi, opposizione, quadratura, famiglia) | 06, 10 | La Luna portata ai pianeti: 3, 8, 11 |
| `test/il_sacchetto_dell_alba_test.dart` | **44 stati, ogni stato una volta per ciclo, la stessa carta mai prima di 11 estrazioni anche fra due cicli**, su 120 semi per 6 cicli; zero cicli ricomposti a meta'; il verso non segue la carta (prima uscita rovescia fra il 45 e il 55 per cento); il sacchetto sopravvive alla chiusura; sette salvataggi rotti o vuoti si ricompongono senza bloccare | 04, 05 | finestra tolta: la carta torna dopo una estrazione; prova di componibilita' tolta: un ciclo ricomposto a meta' |
| `test/il_corpus_dell_alba_regge_test.dart` | almeno tre letture per stato, numerate; **la famiglia decide la forma** (parola solo alle zodiacali, e il dono la porta); carte diverse danno responsi diversi e i due versi della stessa carta hanno la stessa forma e un altro dono; **le letture dello stesso stato non condividono il nucleo**; parole, aperture del dono e di Medora tutte distinte e piu' aperture del primo movimento che giorni; **nessun movimento fa il compito di un altro su 1.048.320 combinazioni** di lettura, apertura, clausola e filo; la lingua; il file dei dati coincide col corpus; il rilevatore vede un caso costruito apposta e non vede cio' che non c'e' | 07, 08, 09, 11, 13, 24 | corpus vuoto: otto rosse; una chiusura di Medora innestata sul suo dono nei dati: una caduta |
| `test/il_diario_dell_alba_test.dart` | una sola estrazione al giorno; **in tre cicli per 25 persone nessuna parola e nessuna apertura si ripete dentro il ciclo, 24 parole a ciclo, ripieghi a zero, e ogni stato consuma le sue tre letture**; il registro salta la lettura che lo viola, la lascia in coda, e al secondo ciclo senza letture libere consegna e conta; il filo con ieri solo con relazione, mai il primo giorno, spezzato da un giorno saltato; **due persone con lo stesso stato leggono testi diversi**; la collisione misurata al variare delle letture; il diario riletto continua identico; cinque salvataggi rotti non bloccano | 05, 09, 10, 11, 12, 22, 23, 27 | l'impianto unico che prende sempre il primo candidato: tre rosse qui e due nella Stesa |
| `test/l_arcano_dell_alba_si_gira_test.dart` | carte coperte uguali per dorso e misura, **nessun comando oltre al ritorno**, nessuna faccia montata prima del gesto; girata la carta, la faccia porta il verso estratto e arrivano i tre movimenti; **il verso non lo decide la carta toccata**; nella prima meta' del giro solo il dorso; **il limite delle stese non si muove e nel cammino entrano alba e oracolo**; riaperto il dono la carta e' quella; **il dorso ruotato di mezzo giro scarta in media 5,37 su 255 e in nessun punto oltre 48** | 02, 03, 04 | la carta toccata che decide il caso; il gesto dell'oracolo tolto: due rosse |
| `functions/src/cammino.test.ts`, due prove nuove | il diario dell'Alba si legge intero e non oltre il suo peso; **fra due diari vince il piu' avanti**, e un telefono nuovo lo riceve | 05 | il server che vince sempre: una rossa |
| `test/intent_routing_test.dart`, riscritta | **estratto l'Arcano dell'Alba, la chat nomina la stessa carta e lo stesso verso**, tre domande, senza modello; senza carta girata la chat non ne estrae una seconda | 25 | la carta del giorno che ignora l'estrazione: tre rosse |
| `test/daily_elements_test.dart`, riscritta | **quattro doni nell'ordine delle ore**; le fasce, alle 13 il Soffio; ogni minuto del giorno appartiene al dono dell'ultima ancora, senza nomi a mano; **Medora all'alba e al Sogno in tutti i 366 giorni**; il numero dell'avviso e' del dono e il 2 non torna; `oracle` non apre niente; i nomi a video; l'elenco e il numero in lettere composti dai doni | 01, 14, 15, 17 | Sigillo senza Maestro: due rosse |
| `test/il_sigillo_del_sogno_nomina_un_maestro_solo_test.dart`, riscritta | nei tre giorni che la rotazione dava a tre Maestri diversi, **il Sigillo nomina Medora e nessun altro**, a video | 15 | Sigillo senza Maestro: due giorni su tre rossi |
| `test/il_confine_del_responso_test.dart`, allargata | **29.994 responsi composti dell'Arcano dell'Alba** dentro il confine; il nome della Morte non e' la morte rivolta alla persona, la morte in minuscolo si' | 08, 13 | i nomi dei simboli tolti dall'eccezione: due rosse |

### Le prove riallineate, e cosa hanno perso o guadagnato

| prova | trattamento | perche' |
|---|---|---|
| `l_arcano_del_giorno_test.dart` | **tolta** | misurava `ArcanoDelGiorno`, tolto; le sue pretese (solo maggiori, stessa carta tutto il giorno, varieta', gesto `oracolo`) le portano il sacchetto, il diario e la schermata |
| `il_disco_dell_oracolo_dice_cosa_e_test.dart` | **tolta** | misurava il disco della schermata dell'Arcano del Giorno |
| `il_permesso_appena_dato_accende_tutte_e_cinque_test.dart` | **tolta** | misurava il permesso chiesto dal Rito dell'Alba; il menu' Notifiche riprogramma tutte le chiamate dopo il permesso (`notifiche_screen.dart`, riga 148) |
| `il_mantra_di_oggi_ha_il_suo_riquadro_test.dart` | **tolta** | il riquadro del rituale era della scheda dell'Alba |
| `la_parola_dice_a_cosa_serve_test.dart` | **tolta** | l'etichetta della parola era della scheda dell'Alba |
| `i_testi_del_dono_non_stanno_sulla_carta_test.dart` | **tolta** | misurava la vista rituale dell'Arcano del Giorno, uscita col dono |
| `l_alba_dice_dove_sei_test.dart` | **tolta** | misurava la riga del luogo del Rito dell'Alba, uscita col dono |
| `daily_elements_test.dart` | **riscritta** | quattro doni, fasce dalle ancore, Medora, numeri degli avvisi |
| `il_sigillo_del_sogno_nomina_un_maestro_solo_test.dart` | **riscritta** | Medora nei tre giorni che la rotazione dava a tre Maestri |
| `intent_routing_test.dart` | **riscritta la carta del giorno** | la carta della chat e' l'Arcano dell'Alba estratto |
| `l_arcano_e_del_singolo_test.dart` | **riscritta la meta' dell'Arcano** | due persone vedono lo stesso stato 11 giorni su 365, attesi 8,3 |
| `i_cinque_doni_incrociano_la_carta_test.dart` | **ridotta** | tolte le misure dell'Arcano del Giorno e del Rito dell'Alba; restano Sigillo, Runa e Soffio |
| `colore_del_dono_test.dart` | **ridotta** | tolte le misure del colore della parola sul vetro chiaro dell'Alba; resta il punto solo dell'accento, col cardinale |
| `il_soffio_non_somiglia_all_alba_test.dart` | **ridotta** | tolti i confronti fra l'abito del giorno e quello della notte; nessun dono porta piu' il giorno |
| `le_due_cose_che_non_servivano_test.dart` | **ridotta** | tolte le tre misure della parola condivisa dall'Alba |
| `la_parola_del_giorno_si_vede_nella_frase_test.dart` | **ridotta e riallineata** | tolto il ripiego del mantra; la seconda frase e' il richiamo del dono di una carta del corpus |
| `dove_sei_adesso_test.dart` | **ridotta** | tolto il gruppo della riga del luogo; restano il luogo attuale e il catalogo |
| `i_doni_si_agganciano_test.dart` | **ridotta e riallineata** | tolto il gruppo P.16 dell'Arcano del Giorno; il filo della sera passa dall'archivio |
| `il_censimento_dei_caratteri_test.dart` | **riallineata e allargata** | l'Arcano dell'Alba coperto e girato; i glifi delle icone non sono testo |
| `l_alba_si_legge_test.dart` | **riallineata** | il contrasto misurato sull'Arcano dell'Alba, prima e dopo il gesto |
| `il_responso_si_legge_ovunque_test.dart`, `il_confine_del_responso_test.dart`, `i_doni_e_la_chat_davanti_all_anatomia_test.dart`, `le_lunghezze_dei_responsi_test.dart` | **riallineate** | misurano i testi dell'Arcano dell'Alba al posto di quelli dell'Arcano del Giorno |
| `la_parola_torna_la_sera_test.dart`, `dream_rite_screen_test.dart` | **riallineate** | il dono della carta torna la sera, dall'archivio |
| `cinque_avvisi_uno_per_dono_test.dart`, `le_cinque_chiamate_partono_tutte_test.dart`, `le_notifiche_arrivano_davvero_test.dart`, `il_menu_delle_notifiche_si_tocca_test.dart`, `cancellare_dimentica_tutto_test.dart` | **riallineate** | il numero dei doni letto dall'enumerazione; il 1102 fra le chiamate da spegnere; la Runa al posto dell'Arcano dove serviva un dono qualunque |
| `daily_strip_test.dart`, `santuario_test.dart`, `navigation_test.dart`, `i_doni_si_aprono_alla_loro_ora_test.dart`, `fascia_del_risveglio_test.dart` | **riallineate** | le ore nuove: alle tredici il Soffio di Aura, al mattino e di notte Medora |
| `ogni_dono_dice_chi_parla_test.dart`, `nessun_accento_dichiara_un_fondo_che_non_ha_test.dart`, `i_testi_da_leggere_hanno_una_misura_sola_test.dart`, `i_cinque_doni_rispettano_la_legge_dei_testi_test.dart`, `il_dono_risponde_prima_di_chiedere_test.dart`, `le_descrizioni_hanno_una_misura_sola_test.dart`, `le_condizioni_costruite_test.dart`, `nessun_invito_a_un_permesso_e_muto_test.dart`, `ogni_schermata_dichiara_la_barra_test.dart`, `una_barra_sola_test.dart`, `nessun_catch_muto_test.dart` | **riallineate** | la schermata dell'Arcano dell'Alba al posto delle due tolte negli elenchi dei sorgenti |
| `ogni_custodito_ritrova_la_sua_arte_test.dart`, `ogni_pulsante_della_chat_apre_cio_che_promette_test.dart`, `cosa_dicono_i_doni_test.dart`, `entitlement_test.dart`, `la_catena_dei_dati_di_nascita_test.dart`, `i_due_pulsanti_del_soffio_si_leggono_test.dart`, `rituals_test.dart`, `testo_a_video_test.dart` | **riallineate** | i numeri seguono il dato (quattro doni, 31 righe del piano, 14 consumatori della nascita, 8 chiavi dei custoditi) e le arti senza azioni dichiarate; le elisioni *mezz'* e *nient'* |

## 5. LO SBARRAMENTO

**Girato intero sull'albero finale**, dopo il ribasamento sopra CODEMAGIC2 e
con la build a 2266, prima della spinta.

**Il giro del 17 settembre sera, sul commit `0b1bc191`**:

| parte | esito |
|---|---|
| la suite Flutter | **5.460 prove passate, 11 saltate, 5 cadute** |
| le prove del server | **100 su 100** |
| il corredo a scala 1,3 | **179 schermate montate, 13 catture cadute** |

**Le cinque cadute della suite, una per una:**

1. *l'attribuzione cieca e' valida su QUESTA istruzione* e 2. *le soglie delle
   quattro pose sono state misurate su un telefono*: **i due rossi accettati**.
3. *il ramo locale non ha commit che il remoto non conosce*: si chiude
   spingendo.
4. `ordine_dt_guard_test`, *i marcatori dicono il vero*: **difetto mio, della
   chiusura del manifesto**. Riscrivendo DT.05 avevo lasciato lo stato senza il
   punto dentro il grassetto, e la guardia non lo contava. Corretto.
5. `il_corpus_dell_alba_regge_test`, *il file dei dati dice cio' che dice il
   corpus*: **difetto mio, di DT.21**. Dopo il cambio di ramo git ha riscritto
   `docs/corpus/tarocchi.md` coi fine riga di Windows, e la prova confrontava
   righe con un ritorno a capo in coda. Su GitHub, che lavora con fine riga
   Unix, non sarebbe caduta. La prova adesso normalizza i fine riga.

**Il corredo a scala massima ha fermato l'archivio per la ragione opposta**:
le sue tredici cadute sono tutte accettate, ma **due righe accettate non
zittivano piu' niente**, *il dono col colore del Maestro, giorno 0 e giorno 1*.
Quelle due catture fotografavano il Rito dell'Alba che cambiava colore col
Maestro di turno, e **le ha tolte DT.01** insieme al rito e alla rotazione. Le
due righe sono state **tolte** da `tool/rossi_accettati.txt`, come il terzo
cancello pretende, e il manifesto dell'ordine CM scende da quindici a
**tredici** schermate, con la ragione scritta: non e' una cura, e' la
schermata che non c'e' piu'. **Nessuna riga e' stata aggiunta.**

**Dopo le correzioni**: le cinque prove toccate, cioe' la guardia CM, la
guardia DT, il corpus dell'Alba, lo sbarramento che distingue i rossi e il
sigillo dei manifesti, **50 prove, tutte verdi**. Lo sbarramento intero si
rifa' dopo la spinta, che chiude anche la terza caduta, e il suo gettone e'
quello che la consegna della 2266 pretende.

**Rossi accettati**: nessuna riga e' stata aggiunta a
`tool/rossi_accettati.txt`. Il primo giro, del 17 settembre alle 13:16, e'
stato fermato a 3.831 prove con due sole cadute per lasciare il posto
all'ordine CODEMAGIC2; non conta.

**Ritocchi fatti a lavoro chiuso, prima di questo giro**:

- `docs/tipografia/alba_contrasto.md` usciva **diverso a ogni giro**: la prova
  fissava il giorno e il caso ma non il seme della persona, quindi cambiavano
  lettura e aperture, e tre testi spezzati in blocchi da `ParagrafiDiLettura`
  uscivano *senza chiave*. Adesso il seme e' fissato e la chiave si cerca anche
  sull'antenato: due giri identici al byte, zero righe senza chiave
  (`test/l_alba_si_legge_test.dart`).
- tre commenti di `lib` che descrivevano il presente con *cinque* doni.
- le anteprime rigenerate: 179 catture verdi; le tre nuove dell'Arcano
  dell'Alba **guardate** (carte coperte uguali, il Matto dritto con la clausola
  dell'Aria, il dono e la chiusa di Medora interi).

### La build 2266

**Rifatto dopo la spinta**, sul commit `1cd53548`: **solo rossi accettati,
l'archivio si produce**, gettone scritto per la build **2266** con **5.463
prove**; server 100 su 100; corredo a scala 1,3 con 179 schermate e le sole
tredici catture accettate. Il cancello di GitHub sullo stesso commit: **verde**.

**La consegna.** Comando `flutter build apk --release --target-platform
android-arm64`, 204.480.471 byte, `tool/verifica_apk.py` verde su tutte le
famiglie. **La prima prova di accensione e' caduta**, e non per l'app: lo
schermo del Realme era spento (`mWakefulness=Asleep`), il processo era vivo e
nessun FATAL. Svegliato lo schermo, **processo vivo, primo fotogramma
disegnato, nessun FATAL**, numero letto dal dispositivo 2266. Consegnata con
App Distribution: release `63a4ae30vh3d8`, un invito accettato, registro da
2265 a 2266. **La build iOS la lancia Mauro su Codemagic**, dopo la spunta
verde del commit che porta questo rapporto.

**Guardata a video sul Realme 767f596c, alle 18:00 del 17 settembre**: i dati
di prima ci sono (*il Cerchio custodisce 15 tuoi momenti*); la striscia ha
**quattro doni**, Alba, Soffio acceso alle 18, Tramonto e Notte; l'Arcano
dell'Alba apre con **tre dorsi uguali e il solo ritorno**; girata la carta
centrale, **l'Imperatrice dritta, lettera doppia di Venere**, il dono e la
chiusa di Medora interi, nessun FATAL nel registro.

**UN DIFETTO VISTO A VIDEO, E NESSUNA PROVA LO CERCAVA.** La carta girata alle
18:01 si apriva con *"Stamani hai rivelato l'Imperatrice"*. **Quattordici
aperture su quarantotto nominano il mattino** (*Stamattina*, *Al tuo
risveglio*, *Nel primo mattino*, *Questa mattina* e altre dieci in
`lib/core/rituals/arcano_dell_alba/forme_dell_alba.dart`), ma la carta si gira
a qualunque ora dopo le sette: circa **tre volte su dieci** chi la gira dopo il
mattino legge una frase falsa. Padre: **ordine DT, voce 08**, la scrittura
delle aperture. Non l'ho corretto dentro questa build: e' testo del corpus, e
una correzione chiede una build nuova. Vedi la decisione 17.

## 6. LE LACUNE APERTE E LE DECISIONI DI MAURO

**Nessun rosso e' stato aggiunto a `tool/rossi_accettati.txt`.**

1. **Il deploy delle funzioni del cammino (DT.05).** Il campo `arcanoDellAlba`
   e la sua fusione stanno in `functions/src/cammino.ts` con le prove verdi, e
   sono **additivi**: un telefono con la build 2265 non li manda e non li legge.
   Finche' non si distribuisce, il diario dell'Alba non passa da un telefono
   all'altro. La funzione da distribuire e' `statoDelCerchio`
   (`functions/src/cerchio.ts`, riga 437, e' lei a chiamare `leggiCammino` e
   `fondiCammini`). **Mauro ha dato il via il 17 settembre**; il permesso di
   questa sessione ha rifiutato la distribuzione in produzione, e non l'ho
   aggirato. **Il comando e il suo controllo sono il PASSO 8** di
   `docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md`. **Per questo DT.05 e' ferma.**
2. **Il numero delle letture per stato (DT.22).** Due persone con lo stesso
   stato nello stesso giorno leggono lo stesso dono con probabilita' **uno su
   n**, se n sono le letture; misurato sulla simulazione:

   | letture per stato | stesso dono, atteso | stesso dono, misurato | letture da scrivere | stesso testo intero, atteso |
   |---:|---:|---:|---:|---:|
   | 3 | 33,3 % | 36,7 % | 132 | circa 0,17 % |
   | 5 | 20,0 % | 22,0 % | 220 | circa 0,10 % |
   | 8 | 12,5 % | 14,3 % | 352 | circa 0,07 % |
   | 10 | 10,0 % | (non misurato nel giro finale) | 440 | circa 0,05 % |

   Lo stato di oggi coincide fra due persone circa **un giorno su 44**, quindi
   la probabilita' che due persone qualunque condividano lo stesso dono nello
   stesso giorno e' circa **1 su 44n**: 1 su 132 con tre letture, 1 su 352 con
   otto. **Raccomandazione: otto letture per stato**, 352 in tutto. E' il punto
   in cui la collisione scende sotto un ottavo e le 220 letture nuove restano un
   lavoro di scrittura sostenibile, che passa dalle stesse prove sul corpus.
   Oltre, ogni lettura in piu' toglie poco. **Il numero lo sceglie Mauro.**
3. **I testi delle push del server (DT.01, DT.14, DT.15).** In
   `functions/src/push.ts` il dono dell'alba dice *"La tua parola del giorno ti
   aspetta. Solleva l'alba."* e il Sigillo firma *Caligo*. Vanno cambiati **nello
   stesso momento** in cui si distribuisce la build nuova: prima, sbaglierebbero
   per chi ha la 2265. **Raccomandazione**: dawn *"Medora", "La tua carta di
   oggi ti aspetta coperta."*; night titolo *"Medora"*; la voce `oracle` resta
   finche' esistono telefoni con la 2265, perche' il numero 1102 e' ancora il
   loro.
4. **Il conflitto fra DT.02 e l'ordine CG voci 06 e 08.** CG pretende che ogni
   responso offra Custodisci, Parlane e Condividi; DT.02 vieta ogni comando
   sull'Arcano dell'Alba. **Si e' applicato DT.02**, l'ordine piu' recente e piu'
   preciso, e l'eccezione e' dichiarata per nome in
   `lib/core/ricordi/arti_con_responso.dart` (`senzaAzioni`). Se Mauro vuole
   Custodisci e Parlane sull'Arcano dell'Alba, e' una riga di codice e una
   eccezione tolta.
5. **La domanda di Medora dalla Stesa.** Il Rito dell'Alba la mostrava il
   mattino dopo (ordine P voce 18). **L'Arcano dell'Alba non la mostra**, perche'
   DT.08 non ammette niente fuori dai tre movimenti. La Stesa continua a
   scriverla (`FiloDelGiorno.segnaLaDomanda`) e oggi **nessuno la legge**.
   **Raccomandazione**: portarla nella chat di Medora come apertura del giorno
   dopo, oppure smettere di scriverla. Lo stesso vale per `FiloDelGiorno.laLente`,
   la lente approvata per la parola, che nessuna schermata usa piu'.
6. **L'aspetto di giorno.** L'abito chiaro esisteva per il solo Rito
   dell'Alba. L'Arcano dell'Alba e' su una scena scura, e l'abito del giorno non
   lo porta piu' nessun dono (`lib/design_system/theme/abito_del_responso.dart`).
   Se l'Arcano dell'Alba debba avere una luce di mattino e' una scelta di
   disegno.
7. **L'incrocio con la carta natale (ordine CE voce 13).** L'Arcano del Giorno
   incrociava il giorno con la carta natale dei tarocchi; **l'Arcano dell'Alba
   no**, perche' estrae dal sacchetto della persona. Il testo del tutorial oggi
   non lo promette, ma la promessa era scritta come intenzione del fondatore.
8. **La permission degli avvisi.** Il Rito dell'Alba chiedeva il permesso
   delle notifiche alla prima apertura; l'Arcano dell'Alba non lo chiede, perche'
   e' un comando. Lo chiedono ancora la chiamata del primo giorno e il menu'
   Notifiche. **Raccomandazione**: verificarlo sul telefono con la prossima build.
9. **Le carte coperte sono tre.** L'ordine dice *fra carte coperte* senza un
   numero; tre stanno larghe su 360 punti. E' una costante della schermata
   (`ArcanoDellAlbaScreen.carteCoperte`), e nessun conto dipende da lei.
10. **I due sentieri che adesso dicono lo stesso dono.** Con la decisione del
    cammino i traguardi di `alba` (Loto) e di `oracolo` (Costellazione) nominano
    entrambi l'Arcano dell'Alba: alcune frasi si somigliano, per esempio *"Hai
    compiuto l'Arcano dell'Alba in 3 giorni diversi"* e *"in 2 giorni diversi"*
    su due sentieri. La struttura dei traguardi e' della revisione F: se
    riscriverla lo decide Mauro.
11. **La build.** L'ordine la vietava; **Mauro l'ha ordinata il 17
    settembre**, a lavoro finito. La 2266 e' nella sezione dello sbarramento,
    con la prova di accensione sul Realme. Le anteprime nuove sono
    `docs/preview/arcano-alba-coperte.png`, `arcano-alba-girata.png` e
    `arcano-alba-responso.png`.

12. **La legge dei testi (ordine CQ voce 2.01) e l'Arcano dell'Alba.** La
    legge vuole in fondo, breve, la fonte; negli altri doni la fonte sta dietro
    un tocco (`gift_base_panel`, `sunset_provenienza`, `dream_provenienza`).
    DT.02 vieta ogni comando oltre alla carta e DT.08 ogni cosa fuori dai tre
    movimenti: **l'Arcano dell'Alba non ha lo strato della fonte**, e la
    tradizione si legge soltanto nella clausola del primo movimento (*"lettera
    madre dell'Aria"*, *"nel segno del Leone"*). La guardia
    `i_cinque_doni_rispettano_la_legge_dei_testi` lo dichiara a riga 41 invece
    di misurarlo. **Raccomandazione**: tenere la clausola come fonte, perche'
    nomina la tradizione in poche parole senza un comando in piu'. Se Mauro
    vuole la fonte in fondo, e' una riga sotto Medora senza tocco.
13. **I fondali dell'alba.** `assets/ritual_backgrounds/dawn_sky_night.png`,
    `dawn_sky_day.png` e `dawn_sun.png` restano nel bundle e **nessun file di
    `lib` o di `test` li nomina** (grep del 17 settembre). Pesano sulla build
    senza mostrarsi. **Raccomandazione**: toglierli, oppure usarli come scena
    dell'Arcano dell'Alba se Mauro vuole la luce del mattino (decisione 6).
14. **Quattro cose scritte che nessuno legge piu'.** `FiloDelGiorno.laLente`,
    `domandaDiIeri` e `segnaLaDomanda` (decisione 5) e la chiave
    `filo.parola_del_giorno`, che i telefoni con la 2265 hanno ancora sul disco
    e che nessuno cancella: **la cancellazione dei dati la prende lo stesso**,
    perche' `cio_che_e_tuo.dart` toglie il prefisso `filo.`.
15. **Due persone e lo stesso stato: 11 giorni su 365.** La prova di
    `l_arcano_e_del_singolo` misura due diari reali per un anno: lo stesso
    stato esce **11 giorni**, attesi 8,3 con il caso puro. Lo scarto e'
    dentro la variazione di un singolo anno e non viene dal sacchetto, che non
    lega due persone: ciascuna estrae col suo caso. E' la base del calcolo della
    decisione 2.
16. **I gesti dei sentieri.** `lib/core/sensi/voce_del_responso.dart`, righe 86 e 89, lega
    `sogno` al sentiero di Caligo e `alba` a quello di Aura: e' la struttura
    dei traguardi della revisione F e **non e' stata toccata**, anche se oggi il
    Sigillo e l'Arcano dell'Alba sono di Medora: la mappa segue
    `sentieroDelGesto`, scritto dal generatore dei traguardi. Se il sentiero debba seguire il Maestro del dono lo
    decide Mauro, ed e' una riscrittura dei traguardi, non una riga.
17. **Le aperture che nominano il mattino.** Due strade. **La prima,
    raccomandata**: le quattordici aperture si riscrivono senza l'ora, come le
    altre trentaquattro (*"Oggi hai scoperto"*, *"Ora hai in mano"*), e una
    guardia vieta nelle aperture le parole del mattino. Costa un giro di
    corpus e una build. **La seconda**: il diario sceglie le aperture del
    mattino solo prima di mezzogiorno. Tiene il colore del risveglio, ma
    aggiunge una condizione che si deve provare e che divide il registro delle
    aperture in due. **La scelta e' di Mauro**, e con la correzione va la build
    successiva.
