# RAPPORTO DELL'ORDINE FV, IL CALENDARIO LUNARE PERSONALE: L'ALMANACCO DI MEDORA

15 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_FV_TESTO.md`; testo dell'aggiunta: `docs/ordini/ORDINE_FV_Aggiunta_Esoteric_Circle.md`. Manifesto: `docs/ordini/ORDINE_FV_MANIFESTO.md`, 17 voci: 14 chiuse, 3 aperte in attesa di verifica, 0 da fare. Ramo `claude/esoteric-circle-master-order-e798aj`, partenza 8511447. Nessuna build, nessun deploy, nessun dato di produzione toccato. Una chiamata vera al modello, autorizzata dal fondatore per questa sola occasione (FVA.02, R2): venti consultazioni, costo reale 0,003418 dollari. Il lavoro e' stato diviso fra Code e cinque agenti in worktree (gli asset e il video, il motore lunare, la schermata e il corpus delle regole, i giorni tuoi, il sociale e i piani), uniti nel ramo con un commit di unione per gruppo.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FV.01, gli asset nel ramo | `docs/collaudo/FV/fv01_asset.txt` |
| FV.03, le lune vere della NASA | `docs/collaudo/FV/fv03_lune.txt` |
| FV.04, il motore lunare | `test/il_motore_lunare_contro_le_effemeridi_test.dart` |
| FV.05, il mese di trenta lune | `test/il_calendario_lunare_a_video_test.dart` |
| FV.06, Trova il giorno | `test/il_corpus_del_lunario_test.dart` |
| FV.07, i giorni tuoi | `test/i_giorni_tuoi_test.dart` |
| FV.08, il promemoria | `test/il_calendario_lunare_a_video_test.dart` |
| FV.09, l'intenzione alla Luna nuova | `test/il_calendario_lunare_a_video_test.dart` |
| FV.11, la card del mese | `test/la_card_del_mese_test.dart` |
| FV.13, la porta | `test/art_catalog_test.dart` |
| FV.14, la consegna | `docs/ordini/RAPPORTO_ORDINE_FV.md` |
| FV.15, l'Oracolo risponde come i Maestri | `test/l_oracolo_degli_angeli_test.dart` |
| FV.16, la prima esecuzione vera del modello | `docs/collaudo/FV/fva02_venti_consultazioni.txt` |
| FV.17, le altre risposte del fondatore | `docs/STATO_VIVO.md` |

## LE VOCI APERTE E CHE COSA ASPETTANO

| voce | che cosa e' fatto | che cosa aspetta |
|---|---|---|
| FV.02, la scena dell'Almanacco di Luce | video ricompresso, velo rimisurato, scarti dichiarati | il fondatore, sul telefono alla prossima build |
| FV.10, Trova il giorno insieme | client e server scritti e provati, 253 prove su 253 | la pubblicazione di `proponiGiornoInsieme` e `rispondiAlGiorno`, poi due telefoni |
| FV.12, i piani e gli Eos | matrice, listino, lucchetti, server scritto e provato | la pubblicazione di `compraUnMeseDelLunario` e `compraUnaPropostaInsiemeDelLunario` |

## LE PREMESSE, COL COMANDO CHE LE HA VERIFICATE

Sul commit di partenza 8511447; le cartelle del fondatore lette in `D:\Clienti Roogly\Rituali Cartomanzia\App\`. Lo script e la sua uscita intera stanno in `docs/collaudo/FV/premesse.txt`.

- **P1, vera.** `ls "Calendario Lunare Scena"` da' sette file (la sottocartella Elementi a parte) alle misure dichiarate.
- **P2, caduta in parte.** `ls "Calendario Lunare Scena\Elementi"` da' **trenta** file, non ventinove: oltre ai 25 pezzi dichiarati e ai quattro fogli originali, c'e' `card_mese_sfondo_v1.png`, una seconda tavola non dichiarata dall'ordine. Confrontata col JPG: scarto medio dal colore 150,04 su 255, color medio (206,204,198) contro (50,58,77); e' la tavola chiara che il fondatore aveva scartato il 15 ottobre 2026 ("Ma perché la tavola è bianca?"). Lasciata fuori dal ramo, il JPG notturno e' quello usato.
- **P3, vera.** `grep -n "lunar_calendar" lib/core/arts/art_catalog.dart` trova la voce, `ArtState.inArrivo`, `ArtPhase.faseSuccessiva`.
- **P4, vera.** `moon_phase.dart` e `birth_moon.dart` esistono; `grep -ri "fuori corso\|biodinamic" lib/` non trova nessun calcolo, solo il testo di `art_catalog.dart`.
- **P5, vera.** `lunology` e' `ArtState.inArrivo` nel catalogo.
- **P6, vera.** `lib/features/scene/la_scena_in_video.dart` porta `LettoreDiScena`, `RegiaDellaScena`, `IlToccoCheSalta`.
- **P7, vera.** `la_tua_nascita_per_una_lettura.dart` e il gesto del consenso esistono (ordine FT); `il_cerchio_sociale.dart`/`.ts` portano gli amici.
- **P8, vera.** `avvisi_locali.dart` e `flutter_local_notifications` in `pubspec.yaml`.
- **P9, vera.** `fonti_dei_dati.dart` non nominava la NASA prima di questo ordine.
- **P10, vera.** `luogo_attuale.dart` da' latitudine e longitudine.
- **P11, vera.** Nessun file `ORDINE_FV_*` in `docs/ordini/` prima di questo ordine; la regola SPESE e quella della suite su GitHub in `CLAUDE.md`.

**Una premessa falsa nata durante l'ordine, non dell'ordine stesso.** Un agente ha ricevuto da Code la premessa "il corpus del lunario esiste gia'", falsa: nessun commit l'aveva mai portato nel ramo (`git log --all --oneline -- docs/corpus/lunario/` vuoto al momento). L'agente l'ha segnalata come premessa falsa, per la Regola B di quest'ordine non si e' fermato e ha scritto il corpus da zero, con le sue fonti. Nessun lavoro si e' perso: il corpus scritto regge le sue stesse prove.

## VOCE PER VOCE

Le righe DOMANDA, PROVA e MISURA di ogni voce stanno nel manifesto. Qui cosa e' stato fatto e dove.

- **FV.01, chiusa.** `assets/img/calendario_lunare/` e `brand_assets/calendario_lunare/`, dichiarati in `pubspec.yaml` e `docs/stato_asset.json`.
- **FV.02, aperta.** `lib/features/lunario/la_geometria_del_velo.dart`: il velo rimisurato sull'ultimo fotogramma vero, non il rettangolo placeholder dell'Architetto.
- **FV.03, chiusa.** `lib/core/lunario/le_lune_della_nasa.dart` e `.g.dart` (trenta coppie percorso/elongazione), `lib/core/legal/fonti_dei_dati.dart` (l'attribuzione).
- **FV.04, chiusa.** `lib/core/lunario/il_motore_lunare.dart` (404 righe), `lib/core/astro/meeus/il_cielo_di_meeus.dart` (la longitudine J2000 con la precessione rigorosa, aggiunta per questa voce).
- **FV.05, chiusa.** `lib/features/lunario/calendario_lunare_screen.dart`, la griglia e la cascata (`_cascata`, `_IlMese`, `_LaLunaAccesa`).
- **FV.06, chiusa.** `lib/core/lunario/le_regole_del_lunario.dart`, `docs/corpus/lunario/` (fonti, regole, testi, LEGGIMI), `tool/il_corpus_del_lunario.py`.
- **FV.07, chiusa.** `lib/core/lunario/i_giorni_tuoi.dart`, `il_segno_del_giorno_tuo.dart`: calcolati solo su `IlCieloDiMeeus`.
- **FV.08, chiusa.** `lib/features/lunario/i_promemoria_del_lunario.dart`, sul punto degli avvisi P8.
- **FV.09, chiusa.** L'intenzione in `calendario_lunare_screen.dart`, classificata memoria del telefono in `le_memorie_custodite.dart` e aggiunta a `scarico_dei_tuoi_dati.dart`.
- **FV.10, aperta.** `lib/features/lunario/trova_il_giorno_insieme.dart` (537 righe), `gli_eos_del_lunario.dart`; sul server `proponiGiornoInsieme` e `rispondiAlGiorno` in `il_cerchio_sociale.ts`.
- **FV.11, chiusa.** `lib/features/lunario/la_card_del_mese.dart`, col `FittedBox` aggiunto dopo il difetto trovato dalle anteprime (vedi I DIFETTI).
- **FV.12, aperta.** Quattro righe nuove in `plan_catalog.dart` (`RigaDelPiano.lunarioMesi`, `lunarioTutteLeCategorie`, `lunarioPromemoria`, `lunarioInsieme`), due voci in `listino_degli_eos.dart`; sul server `compraUnMeseDelLunario` e `compraUnaPropostaInsiemeDelLunario`.
- **FV.13, chiusa.** `art_catalog.dart`: `ArtState.attiva`, teaser riscritto.
- **FV.14, chiusa.** Questo rapporto, il manifesto e la sua guardia, STATO_VIVO, il registro delle guardie, le anteprime.
- **FV.15, chiusa.** `lib/core/oracolo_angeli/la_lettura_dell_oracolo.dart` (l'istruzione legge `MaestroPersona.temaDelicato` e `ConfineDelResponso.perIlModello`), `oracolo_degli_angeli_screen.dart` (`_LaCura` tolta), `la_domanda_delicata.dart` cancellato.
- **FV.16, chiusa.** `il_banco_dell_oracolo_degli_angeli`, in `tool/banchi_col_modello/`, il banco nuovo che ha eseguito le venti consultazioni.
- **FV.17, chiusa.** `docs/STATO_VIVO.md`, sezione dell'ordine FU, righe in coda a `RAPPORTO_ORDINE_FU.md`.

## LE SCELTE DI CODE, CON LA RAGIONE

- **La lunazione e le trenta immagini della NASA.** Serie "Moon Phase and Libration, 2026" (`svs.gsfc.nasa.gov/5587/`), presa dalla Luna nuova dell'11 ottobre 2026 (ora del motore) a quella del 9 novembre: e' la lunazione che contiene oggi, 15 ottobre 2026. Ogni immagine e' il fotogramma con l'elongazione piu' vicina a quella del motore a mezzogiorno locale, fra i fotogrammi orari della serie. Indirizzi e SHA-256 di ciascuna in `docs/collaudo/FV/fv03_lune.txt`. Scarto di fase misurato: peggiore 1,62 punti percentuali, contro mooninfo.
- **La definizione della Luna fuori corso.** I sette corpi tradizionali (Sole, Mercurio, Venere, Marte, Giove, Saturno, oltre alla Luna stessa come corpo in moto), la definizione classica di William Lilly (*Christian Astrology*, 1647) ripresa anche da Henry Coley (*Clavis Astrologiae*, 1676): dall'ultimo aspetto maggiore (congiunzione, sestile, quadratura, trigono, opposizione, piu' i quattro aspetti minori 30-150-210-330 usati da alcuni autori classici) fino all'ingresso nel segno successivo. Urano, Nettuno e Plutone esclusi, non conosciuti dalla tradizione che definisce il fuori corso. Scarto misurato: 14,3 secondi contro Swiss Ephemeris su 163 intervalli del 2026, 0,92 minuti contro Moon Tracks su 27 intervalli di ottobre-novembre.
- **I confini delle costellazioni di Maria Thun.** Non i segni zodiacali (30 gradi uguali), le costellazioni vere, di grandezza diseguale: i confini IAU di Delporte (1930, su B1875) nella trascrizione di Roman (1987, VizieR VI/42), proiettati sull'eclittica J2000 con la precessione rigorosa di Meeus (*Astronomical Algorithms*, equazioni 21.5 e 21.7), non la precessione approssimata gia' nel motore. Tredici confini sull'eclittica, con l'Ofiuco: radice/foglia/fiore/frutto seguono il metodo (elemento del segno), mai le tabelle gia' stampate di un calendario biodinamico pubblicato.
- **Il corpus delle regole per attivita', con le fonti.** 36 regole su 13 fonti per 27 attivita': il Barbanera (dal 1762) per le attivita' di casa e di raccolto, Maria Thun per orto e piante, Lilly e Coley per l'astrologia elettiva di amore, inizi e viaggi, il folklore siciliano di Giuseppe Pitre' per le usanze di capelli e bellezza. Una regola senza fonte non e' entrata nel corpus (controllato da `tool/il_corpus_del_lunario.py`).
- **L'ora del promemoria.** Le 20:00 del giorno prima: dopo cena, prima che la persona pianifichi il giorno dopo, e abbastanza lontano dalla mezzanotte da non sembrare un avviso dell'ultimo minuto.
- **La tabella dei piani.**

| piano | mesi avanti | categorie di "Trova il giorno" | promemoria | "Trova il giorno insieme" |
|---|---|---|---|---|
| Viandante | il mese in corso | 1 (col lucchetto sulle altre dieci) | no | no (invito a una proposta a 50 Eos) |
| Iniziato | 1 mese dopo | tutte e undici | si' | no (stesso invito) |
| Adepto | 12 mesi avanti | tutte e undici | si' | si' |
| Illuminato | 12 mesi avanti | tutte e undici | si' | si' |

  Un mese extra costa 60 Eos (fra il confronto del cielo in piu', 30, e il posto in piu' fra gli amici, 100, che resta per sempre); una proposta insieme costa 50 Eos (coordina piu' persone, piu' di un gesto fra due a 30, meno di un posto permanente a 100). Nessuna chiamata al modello in nessuna delle due spese (R2): il Calendario Lunare non chiama mai Gemini ne' Vertex, a nessun piano.
- **"Cena" non e' entrata come nuova attivita'.** La voce FV.10 proponeva di aggiungerla a viaggio e trasloco; viaggi e traslochi erano gia' nel corpus di FV.06 (`viaggi`, `traslochi`), e aggiungere "cena" avrebbe voluto dire toccare `le_attivita_del_lunario.dart` (il contratto condiviso con l'agente che in parallelo scriveva il motore delle regole su quello stesso file) e, per R9, preparare un emblema dipinto che P2 non porta. Rimandata: proposta in fondo.

## DA DECIDERE PER IL FONDATORE

1. **Le pubblicazioni sul server**: `proponiGiornoInsieme` e `rispondiAlGiorno` (FV.10), `compraUnMeseDelLunario` e `compraUnaPropostaInsiemeDelLunario` (FV.12). Comando: `cd functions && firebase deploy --only functions:proponiGiornoInsieme,functions:rispondiAlGiorno,functions:compraUnMeseDelLunario,functions:compraUnaPropostaInsiemeDelLunario --project esoteric-circle`. Fino ad allora "Trova il giorno insieme" non manda la proposta davvero e gli acquisti a Eos non si contano.
2. **Il video dell'Almanacco di Luce sul telefono** (FV.02): provato headless e nelle anteprime, manca il giro vero.
3. **La decisione sulla voce FU.04**: il formato del modello dell'Oracolo non regge ancora nel 30% delle risposte vere (FVA.02/FV.16); il fondatore decide se alzare i tetti, restringere il filtro "guari" o accettare il tasso misurato.
4. **"Cena" come attivita' nuova**, rimandata per non toccare un contratto condiviso a meta' lavoro: un emblema dipinto e una riga di corpus la aggiungerebbero in un ordine dedicato.

## IL GIRO DELL'UTENTE, CONTRO LA STESA E L'ORACOLO (R10)

Ho fatto il giro come lo farebbe una persona, sulle anteprime e sulle prove a video.

- **Si entra** dalla scheda nella home o dal dominio di Medora, Lunologia. Il video dell'Almanacco parte, un tocco lo salta, come nella Stesa e nell'Oracolo. A differenza loro, il Calendario non chiede niente prima di mostrarsi: non un mazzo, non una domanda, il mese e' gia' li'.
- **La prima impressione** e' piu' densa della Stesa e dell'Oracolo: trenta lune, undici emblemi, i sigilli dei giorni tuoi, tutti nella stessa schermata. La riga sotto gli emblemi ("Tocca un giorno per leggerlo...") e' il solo testo di orientamento, contro il campo della domanda ben piu' esplicito delle altre due arti.
- **Il tocco su un giorno** apre il foglio nel formato del responso delle altre arti: colpo d'occhio (la Luna nel castone), sintesi (il titolo), testo (fase, segno, fuori corso, giorno lunare), Da dove viene. Coerente.
- **"Trova il giorno"** e' un gesto che la Stesa e l'Oracolo non hanno: scegliere un'attivita' prima di vedere il responso, non dopo. La scia d'oro che passa sul mese (come la mano di Medora, dice l'ordine) e' l'unico momento della funzione con un movimento oltre la cascata d'apertura.
- **Che cosa la persona si potrebbe chiedere.** "Perche' questo giorno e' spento?": il tocco sul giorno (non solo su quelli d'oro) dice il perche' anche per i giorni da evitare, verificato nel codice (`EsitoDelGiorno.perche` non e' vuoto nei casi deterministici provati). "I sigilli sotto la luna, cosa sono?": nessun tocco diretto sul sigillo apre una spiegazione; il foglio del giorno lo spiega quando si apre il giorno intero, ma il sigillo da solo non e' toccabile. Proposto in fondo come miglioria minima.

## LE GUARDIE

Nove guardie nuove di quest'ordine, tutte viste rosse con un innesto verificato col grep prima di leggere l'esito: `il_motore_lunare_contro_le_effemeridi`, `le_regole_del_lunario`, `il_corpus_del_lunario`, `i_giorni_tuoi`, `il_calendario_lunare_a_video`, `il_lunario_sociale_e_piani`, `ordine_fv_guard`, `la_grafica_del_lunario_e_dipinta` (R9, dal giro dell'utente) e `la_card_del_mese` (dalle anteprime). Il registro delle guardie passa da 783 a 792.

## LE ANTEPRIME

In `docs/preview/FV/`, a 360 per 797 con densita' 3, guardate una per una.

- **Il mese e i giorni tuoi** (`fv_lunario_1_mese_e_giorni_tuoi_dopo.png`): la griglia di ottobre dal lunedi', oggi col suo alone, i sigilli dei giorni tuoi visibili.
- **"Trova il giorno" con gli aloni** (`fv_lunario_2_trova_il_giorno_aloni_dopo.png`): Orto e Semina scelti, due giorni accesi d'oro con l'alone, due spenti.
- **Il foglio del giorno** (`fv_lunario_3_foglio_del_giorno_dopo.png`): fase, segno, giorno lunare, tipo biodinamico, Da dove viene.
- **La card del mese** (`fv_lunario_4_la_card_del_mese_dopo.png`): titolo, trenta lune, due giorni d'oro, la firma di Medora e del Cerchio.
- **Difetto trovato guardandole, uno, corretto**: la fascia della firma della card traboccava (voce FV.11), perche' nessuna prova aveva mai montato la card prima di questa consegna.

## I DIFETTI E IL LORO PADRE (REGOLA C)

- **La casella del giorno di "Trova il giorno insieme" disegnava una stella di Material al posto del sigillo dipinto** (R9). Padre: voce FV.10, scritta prima che la guardia `la_grafica_del_lunario_e_dipinta` esistesse. Corretto prima di scrivere la guardia.
- **La card del mese traboccava di 11-17 pixel nella fascia della firma.** Padre: voce FV.11, mai montata da nessuna prova. Corretto con un `FittedBox`, con la guardia `la_card_del_mese` scritta subito dopo.
- **Il bersaglio della bisezione degli ingressi nei segni era mezzo grado oltre il confine vero**, uno scarto sistematico di circa 50 minuti. Padre: voce FV.04, lo stesso lavoro che la Regola A ha scoperto prima della consegna.
- **Il primo giro del cancello di GitHub sul commit 7398994b e' stato rosso**, su rossi tutti risalenti a voci di quest'ordine: il manifesto e la guardia dell'ordine (non ancora scritti a quel commit), quattro righe nuove del Calendario Lunare non registrate dove i numeri erano dichiarati a mano (gli elenchi dei piani e la mappa comparativa in `test/entitlement_test.dart`, le callable del cammino in `test/il_cerchio_custodisce_il_cammino_test.dart`, cinque chiavi di dati mai mostrate senza la loro esenzione in `test/accenti_veri_test.dart`). Padre: le voci FV.10, FV.12 e FV.15 (quest'ultima per le callable nuove che la aggiunta non aveva contato). Tutti corretti e rifatti in locale, verdi, prima di questa consegna.

## MIGLIORIE ED EFFETTI WOW PROPOSTI, NON COSTRUITI

1. **Il tocco sul sigillo spiega da solo.** Un tocco diretto sul sigillo di Luna fuori corso o del tipo biodinamico, sotto la Luna, apre un fumetto corto ("Luna fuori corso dalle 3 alle 5") invece di aspettare l'apertura del giorno intero.
2. **"Cena" come attivita' nuova**, con un emblema dipinto e una riga di corpus propria: la miglioria piu' chiesta dalle Linee Guida sulla viralita' ("una cena romantica nel giorno giusto").
3. **Lo storico dei mesi d'oro.** Dopo tre mesi di uso, Medora mostra quale categoria la persona ha scelto piu' spesso: una ragione per tornare che nasce dai dati della persona, come la miglioria 5 del rapporto FU.
4. **Il promemoria che si ripete.** Oggi un'attivita' fissata avvisa una volta; chi semina ogni Luna crescente potrebbe fissare la categoria, non il singolo giorno, e ricevere il promemoria ogni volta che si accende d'oro.
5. **La card animata nella condivisione**, un breve respiro della Luna del giorno prima dello scatto statico, come la Sinastria VIP fa col suo Sipario.

## LA SUITE INTERA

Per la regola del 14 ottobre 2026 la suite intera la fa il cancello `verde.yml` di GitHub a ogni push: in locale sono girate solo le prove delle voci e le guardie della zona toccata, piu' volte nel corso dell'ordine. Il verdetto del cancello sul commit consegnato si scrive nella riga in coda.

**Aggiunta del 15 ottobre 2026, ordine FV**: il cancello sul commit 6a79b3f7 (il primo con il manifesto a 17 voci) e' stato rosso su un difetto vero, uno solo: `test/gli_eos_hanno_un_nome_test.dart`, "l'elenco dei punti e' completo, e la prova se ne accorge". I due pulsanti a Eos del Calendario Lunare ("Un mese di Calendario Lunare in più", "Una proposta insieme", voce FV.12) scrivevano il prezzo a mano (`'$costo Eos'`) invece di passare da `ListinoDegliEos.prezzo`, come fa `avvio_sinastria_evolutiva.dart` per lo stesso invito (`showUpgradeInvite`, che porta gia' l'icona del denaro del Cerchio): corretto, e due righe di `debugPrint` in `gli_eos_del_lunario.dart` riformulate per lo stesso motivo, perche' non mostrano niente a video. Padre: voce FV.12, che non seguiva la convenzione gia' in uso altrove. Commit della correzione: `fcf91139`.

**Aggiunta del 15 ottobre 2026, ordine FV**: il verdetto della suite intera e' del cancello di GitHub (`verde.yml`), **verde sul commit 22c57e58e927f2ac2c63479a170015613c2ca5bf**, segno `refs/verde/22c57e58e927f2ac2c63479a170015613c2ca5bf`. Undici pezzi, tutti passati. L'ordine FV, con l'aggiunta FVA.01-03, e' consegnato su questo commit.

**Aggiunta del 15 ottobre 2026, ordine FW**: il fondatore ha provato a pubblicare le quattro callable di FV.10 e FV.12 e il deploy e' caduto: "Error: No function matches the filter: default:compraUnMeseDelLunario". Le quattro esistevano in `functions/src/il_cerchio_sociale.ts` ma non erano mai state aggiunte al blocco `export { ... } from "./il_cerchio_sociale";` di `functions/src/index.ts`, il file che Firebase guarda per decidere che cosa pubblicare: padre, la voce FV.12 stessa. Corretto nell'ordine FW (commit `820863e2`), con la guardia del cammino (`test/il_cerchio_custodisce_il_cammino_test.dart`) estesa a verificare che ogni callable sia davvero riesportata, vista rossa con l'innesto verificato col grep. Il fondatore ha ripetuto il deploy con successo: `compraUnMeseDelLunario`, `compraUnaPropostaInsiemeDelLunario`, `proponiGiornoInsieme` e `rispondiAlGiorno`, tutte create in europe-west1, Node.js 22, esito positivo.
