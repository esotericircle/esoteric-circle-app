# RAPPORTO DELL'ORDINE FT, LA SINASTRIA EVOLUTIVA FRA PERSONE REALI

14 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_FT_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FT_MANIFESTO.md`, 15 voci: 10 chiuse, 5 aperte in attesa di verifica, 0 da fare. Ramo `claude/esoteric-circle-master-order-e798aj`, partenza 67960540. Nessuna build, nessuna chiamata a Gemini o a Vertex, nessun dato di produzione toccato.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FT.01, gli asset dichiarati e le pose senza bianco | `docs/collaudo/FT/ft01_scontorno.txt` |
| FT.05, undici punti e cinque aspetti contro Swiss Ephemeris | `test/la_sinastria_evolutiva_contro_il_riferimento_test.dart` |
| FT.06, i cinque capitoli e i quattro legami | `test/la_lettura_evolutiva_test.dart` |
| FT.07, il Tema Composito | `test/la_lettura_evolutiva_test.dart` |
| FT.08, gli intervalli di Keplero | `test/la_lettura_evolutiva_test.dart` |
| FT.09, Oggi fra voi sulla porta sola del cielo del giorno | `test/il_cielo_del_giorno_e_una_porta_sola_test.dart` |
| FT.10, il Momento giusto | `test/la_lettura_evolutiva_test.dart` |
| FT.11, il ritratto della coppia | `docs/preview/FT/ft11_il_ritratto_della_coppia_dopo.png` |
| FT.12, il corpus scritto da Code e i lettori ciechi | `docs/collaudo/FT/lettori_ciechi/esito_2.txt` |
| FT.15, la consegna | `docs/ordini/RAPPORTO_ORDINE_FT.md` |

## LE VOCI APERTE E CHE COSA ASPETTANO

| voce | che cosa e' fatto | che cosa aspetta |
|---|---|---|
| FT.02, lo studio di Medora e il video dell'astrolabio | provato con la guardia e nelle anteprime | il fondatore, sul telefono alla prossima build |
| FT.03, le due persone e il consenso sulla nascita | a mano e a due telefoni, server provato (`npm test` 245 su 245) | la pubblicazione di `condividiLaNascita` e `leggiLaNascita` |
| FT.04, l'amore dai sedici anni | nell'app e nel server, rossa e verde al confine | la stessa pubblicazione della FT.03 |
| FT.13, i piani e gli Eos | matrice, card dei piani, ponte con l'invito | la pubblicazione di `statoDelCerchio` e `muoviGliEos` |
| FT.14, la porta, il segno 15 e il sociale | provate le porte e il segno | il fondatore, sul telefono alla prossima build |

**IL NOME.** L'ordine la chiama "Sinastria approfondita". A lavoro in corso il fondatore ha scritto: "Cambia nome ovunque da Sinastria Approfondita a sinastria evolutiva". Fatto ovunque nel commit 9ac1c8e6: testi a schermo, classi, file, la cartella del corpus e il budget del server (`sinastrieEvolutive`, non ancora pubblicato, quindi senza nessun dato da migrare). Restano apposta due cose. L'id di catalogo `synastry_depth`, che e' la chiave dei conti e nasce con l'ordine ER. I file immagine delle schede `assets/schede/Sinastria-Approfondita-*.webp`, che la persona non legge. Il testo dell'ordine, copiato parola per parola, dice ancora "approfondita".

## LE PREMESSE, COL COMANDO CHE LE HA VERIFICATE

Sulla testa di partenza 67960540.

- **P1, vera.** `git ls-tree --name-only 67960540 assets/img/sinastria/ | wc -l` da' 29.
- **P2, vera.** `ffprobe -show_entries stream=width,height,duration` su `brand_assets/sinastria/medora_astrolabio_in_polvere_v1.mp4` da' 720 per 1280 e 8,000 secondi.
- **P3, vera.** `git show 67960540:pubspec.yaml | grep -c sinastria/` da' 0, e lo stesso per `docs/stato_asset.json`.
- **P4, vera.** Lette con Pillow dal commit: le due pose sono RGB, 1120 per 960, senza canale alfa.
- **P5, vera nel calcolo, con una precisazione.** Nessun punto dell'app calcola il Nodo Nord. `git grep -i north_node` trova pero' tre file: `free_astro_client.dart` riceve gia' il Nodo da FreeAstroAPI come etichetta, `resonance.dart` e `natal_poetics.dart` lo nominano. Il Nodo della Sinastria evolutiva e' calcolato offline, accanto a IlCieloDiMeeus.
- **P6, cade alla lettera.** `git ls-tree --name-only 67960540 lib/core/synastry/` elenca 16 file, non solo VIP, Gemello e Specchio: ci sono anche `altre_affinita`, `perche_proprio_lui`, `possibilita_di_incontro`, `tempi_della_chiamata` e altri della famiglia della VIP. `cielo_del_giorno_sulla_coppia.dart` c'e', come dice la premessa. Nessuna voce poggiava sulla parte caduta.
- **P7, vera.** `RigaDelPiano.sinastria` e `RigaDelPiano.confronti` ci sono in `plan_catalog.dart`.
- **P8, cade a meta'.** Il segno 15 apriva la Sinastria VIP, ma dall'ordine FA il suo testo non era piu' "Facciamo la sinastria": era "Leggiamoci con un VIP" (`git show 67960540:lib/core/cerchio/i_segni_del_cerchio.dart`, righe 205-221). La voce FT.14 l'ha riportato a "Facciamo la sinastria", adesso che apre la sinastria fra voi due.
- **P9, vera.** `soloIlPubblico` in `functions/src/il_cerchio_sociale.ts` porta nome, icona, segno, Maestro, gradino e sigillo: nessuna data di nascita.
- **P10, vera.** `git show 67960540:CLAUDE.md | grep -c SPESE` da' 2; il commit 0bd3637f e' quello della regola.
- **P11, vera.** `git ls-tree --name-only 67960540 docs/ordini/ | grep -c ORDINE_FT` da' 0.

## VOCE PER VOCE

Le righe DOMANDA, PROVA e MISURA di ogni voce stanno nel manifesto. Qui cosa e' stato fatto e dove.

- **FT.01, chiusa.** Cartelle dichiarate, il video con la sua impronta SHA-256, le due pose scontornate da `tool/scontorna_le_pose_della_sinastria.py`. Pixel con alone chiaro sul bordo: da 4.766 a 14 e da 5.936 a 9.
- **FT.02, aperta.** `lib/features/synastry/lo_studio_di_medora.dart`. Il riquadro del video nello sfondo misurato con ORB e RANSAC: dal pixel 0 al 1223, scala 1,04654. Ripieghi: Riduci Movimento, grafica alleggerita e video che non si carica, tutti a mani aperte. L'audio sotto l'interruttore del suono e muto in silenzioso. Aspetta il telefono.
- **FT.03, aperta.** Due strade.
  - **A mano**: il modulo "La sua nascita", con "Non conosco l'ora". Allora la Luna tace, perche' in mezza giornata si sposta piu' dell'orbo del sestile, e la lettura lo dice in una riga.
  - **A due telefoni**: chi condivide apre "La tua nascita", preme "Condivido la mia nascita" e detta il codice; chi legge lo scrive in "Hai un codice?". Server: `condividiLaNascita` e `leggiLaNascita`, con tetti da 30 l'ora come la tendina, scritte e provate, non pubblicate.
- **FT.04, aperta.** `legame_e_eta.dart` nell'app; `legameApribile` ed `esitoDellaLettura` sul server. Il server rifa' il conto con il giorno di chi legge e con la nascita che ha nel consenso. Un suo no chiude l'amore anche fra due adulti. Aspetta la pubblicazione delle due porte.
- **FT.05, chiusa.** `cielo_evolutivo.dart`, il Nodo in `IlCieloDiMeeus.longitudineDelNodoNord`. Contro Swiss Ephemeris: scarto massimo 0,004982 gradi, 315 aspetti, nessuno diverso.
- **FT.06, chiusa.** `la_lettura_evolutiva.dart` e `sinastria_evolutiva_screen.dart`.
- **FT.07, chiusa.** `IlComposito` in `il_composito_e_keplero.dart`.
- **FT.08, chiusa.** `IntervalliDiKeplero`. Dall'anteprima: tre corde su quattro senza consonanza ripetevano lo stesso testo. Adesso il testo della "nessuna" si dice una volta.
- **FT.09, chiusa.** `OggiFraVoi` sulla porta generalizzata `MoltiplicatoreCeleste.accensione`, la stessa della VIP: identica al bit su trecento coppie.
- **FT.10, chiusa.** `IlMomentoGiusto`: sessanta giorni, al piu' tre giorni favorevoli, mai un giorno detto sbagliato.
- **FT.11, chiusa.** `RitrattoDellaCoppia` in `il_ritratto_della_coppia.dart`.
- **FT.12, chiusa.** 1.231 testi in `docs/corpus/sinastria_evolutiva/`, `tool/il_corpus_della_sinastria.py`. Lettori ciechi `tool/i_lettori_ciechi_della_sinastria.py`: 69 su 70 e 68 su 70.
- **FT.13, aperta.** La tabella dei piani qui sotto; il ponte che conta le coppie nuove con l'invito (Eos o piano). La scheda della home si apre a tutti i piani: era Premium dall'Adepto e avrebbe tenuto fuori il Viandante dal suo assaggio. Aspetta la pubblicazione di `statoDelCerchio` e `muoviGliEos`: fino ad allora non si conta niente.
- **FT.14, aperta.** Porte d'ingresso:
  - la scheda nel dominio di Medora;
  - il segno 15;
  - il passaggio in fondo al confronto del cielo;
  - la card del capitolo da condividere per chi non e' Adepto.

  La scheda della home non promette piu' i "tre livelli, astrale, angelico e archetipico" dell'ordine ER, che la lettura non ha. Aspetta il telefono.
- **FT.15, chiusa.** Questo rapporto, il manifesto con la guardia, il registro (da 766 a 773), STATO_VIVO, le anteprime.

## LE SCELTE DI CODE, CON LA RAGIONE

- **Undici punti, non dieci.** L'ordine dice "dieci punti, compreso il Nodo Nord". IlCieloDiMeeus porta dieci corpi, dal Sole a Plutone. Togliere un pianeta per arrivare a dieci col Nodo sarebbe stato arbitrario: quale? Sono i dieci corpi piu' il Nodo medio, e i lenti pesano poco perche' i capitoli leggono le coppie della tradizione (Davison 1977, Arroyo 1979, Schulman 1984 per i nodi).
- **Gli orbi.** Quelli gia' approvati della Sinastria VIP (`AspettiDiSinastria.orbo`): sei gradi sugli aspetti maggiori, quattro sul sestile. Non nasce una seconda tavola di orbi per la stessa tradizione. Per Keplero, due gradi intorno a ogni consonanza: una distanza deve cadere in una consonanza sola.
- **Il gesto della lettura a due telefoni.** Il codice "vicino" che il Cerchio usa gia' per gli inviti da fare insieme: sei caratteri dell'alfabeto senza lettere ambigue, cinque minuti. Non un QR nuovo ne' un gesto di vicinanza nuovo: niente codice nuovo da fidarsi, e una forma che le persone del Cerchio conoscono gia'. Il consenso e' il pulsante, con la riga che dice prima cosa succede. La nascita vive solo in `consensi_nascita/{codice}` e chi la legge cancella il documento. Le porte sociali sono chiuse sotto i quattordici anni: li' la lettura a due telefoni non c'e', e resta la strada a mano.
- **La tabella dei piani.** Nessuna chiamata al modello, quindi il tetto del costo non pesa: i numeri servono solo contro l'abuso.

  | | Viandante | Iniziato | Adepto | Illuminato |
  |---|---|---|---|---|
  | coppie nuove al giorno | 1 | 2 | 5 | 15 |
  | capitoli | due su cinque | cinque | cinque | cinque |
  | Oggi fra voi | si' | si' | si' | si' |
  | Keplero | no | si' | si' | si' |
  | Composito, ritratto, momento giusto | no | no | si' | si' |

  La coppia in piu' costa 150 Eos, col prezzo detto prima del gesto. Al Viandante un assaggio vero: un capitolo d'attrazione e uno d'emozioni bastano a far venire voglia degli altri tre. Riaprire una coppia gia' letta non si conta.
- **I numeri del corpus.** 1.231 testi:
  - 720 per i capitoli (5 capitoli, 4 legami, 4 toni, 3 varianti per titolo, apertura e fare);
  - 225 per i contatti (15 coppie di punti, 5 aspetti, 3 varianti);
  - 124 per il Composito (10 coppie, 3 famiglie e la cella "nessuno", 2 titoli e 2 testi);
  - 18 per Keplero;
  - 144 per Oggi fra voi e il Momento giusto, esattamente i 144 dell'ordine.
- **La nascita a mano senza luogo.** Il modulo non chiede il luogo, e l'ora scritta si prende in tempo universale. Per una nascita italiana l'errore e' di una o due ore: la Luna si sposta di mezzo grado o un grado, gli altri punti di poco. Il rimedio e' un campo del luogo, proposto qui sotto.

## DA DECIDERE PER IL FONDATORE

- **"Compatibilità a tre livelli, esclusiva"** resta nella card dell'Illuminato e nella matrice (`plan_catalog.dart`, riga "Compatibilità a tre livelli", esclusiva dell'Illuminato). Era la promessa dell'ordine ER per questa stessa scheda. Non l'ho tolta: e' una riga di un piano e non la decide Code. Ma oggi nessuna parte dell'app la esegue.
- **Le pubblicazioni**:
  - `cd functions && firebase deploy --only functions:condividiLaNascita,functions:leggiLaNascita --project esoteric-circle`, per la lettura a due telefoni e il controllo dell'eta' sul server;
  - `cd functions && firebase deploy --only functions:statoDelCerchio,functions:muoviGliEos --project esoteric-circle`, per il conto delle coppie nuove e il riscatto a 150 Eos.

## IL GIRO DELL'UTENTE, CONTRO LA SINASTRIA VIP

- **Si entra**:
  - dalla scheda nella home, accanto alla VIP;
  - dal segno 15;
  - dal confronto del cielo con un amico.

  Si scrive o si legge col codice la nascita dell'altra persona, e si apre lo studio di Medora.
- **Diversa dalla VIP, per scelta.** La persona dall'altra parte e' vera, non un VIP di catalogo. Il responso e' in cinque capitoli e non in un punteggio. C'e' il legame, che cambia la lettura. La VIP ha l'ascendente quando l'ora e' nota; l'evolutiva no: confronta due nascite e non chiede il luogo.
- **Uguale alla VIP.** Il formato del responso di casa, il Diario, il Parlane con Medora, la card da condividere, gli orbi.
- **La VIP non e' cambiata.** La porta del cielo del giorno e' stata generalizzata e resta identica al bit per la VIP.

## LE GUARDIE

- **Regola A.** Tutte le prove nuove viste rosse su un innesto verificato col conteggio prima di leggere l'esito:
  - la grafica alleggerita non letta;
  - la Luna rimessa nel cielo senza ora;
  - il Nodo spostato di due centesimi;
  - mezzo grado d'orbo in piu' nella porta del cielo del giorno;
  - la nascita mandata all'apertura, prima del consenso;
  - il no del server ignorato;
  - sul server, l'amore sempre aperto;
  - il manifesto col marcatore alzato, una voce rinominata e una voce aperta senza ASPETTA.

  Un innesto non e' entrato al primo colpo (Windows teneva il file aperto): quel giro non conta, ripetuto finche' il conteggio ha detto che l'innesto c'era.
- **Prove della regola vecchia, riscritte con la lapide.** La scheda `synastry_depth` Premium e coi tre livelli (`art_catalog_test`). Le prove della scheda Premium, che adesso usano un'arte Premium dichiarata dalla prova (`i_domini_a_schede_test`, `le_schede_dell_arte_test`). Le guardie del server EY.16 ed EZ.04, da 22 a 24 porte.
- **Un errore mio, riparato.** Durante il cambio di nome un `dart format` su tutto `lib` e `test` ha riformattato 233 file estranei. Rimessi com'erano dal commit prima di qualunque commit, verificati uno per uno: nel cambio restano solo i file del nome.

## LE ANTEPRIME

In `docs/preview/FT/`, a 360 per 797 punti con densita' 3, guardate una per una.

- **Prima e dopo**: la card del Viandante, la tabella dei piani, il fondo del confronto del cielo. Il "prima" e' girato su 53dd7be2, in una copia a parte.
- **Solo dopo**, perche' prima non c'erano: la lettura del Viandante (cinque catture), quella dell'Adepto (tre), il modulo della nascita, "La tua nascita", l'invito a coppie finite, il ritratto della coppia, la card del capitolo.
- **Sette difetti visti nelle anteprime e corretti**:
  - il glifo di Marte usciva come un quadratino vuoto: ora nel carattere dei simboli, e il Sole, che il carattere non ha, disegnato come nella ruota natale;
  - la barra del titolo trasparente lasciava il titolo sopra il testo: il velo leggero all'apertura resta, quello denso arriva appena si scorre;
  - Keplero ripeteva lo stesso testo;
  - le date del Momento giusto non stavano in colonna;
  - il titolo "La nascita dell'altra persona" era troncato;
  - l'etichetta del consenso era chiara sull'oro;
  - il passaggio "Fai leggere la tua nascita" era viola sul fondo scuro.

## MIGLIORIE ED EFFETTI WOW PROPOSTI, NON COSTRUITI

1. **La ruota doppia.** I due cieli su una ruota sola, i tuoi punti dentro e i suoi fuori, con le linee degli aspetti che si accendono capitolo per capitolo mentre scorri: il livello visivo prima del testo.
2. **La corda che suona.** Negli Intervalli di Keplero, toccare una corda fa sentire l'intervallo vero (quinta, quarta, terza) con un campione breve: Keplero voleva proprio che si ascoltasse.
3. **Il luogo nella nascita a mano**, dal catalogo dei luoghi gia' in casa: il tempo universale giusto e la Luna esatta anche senza il codice.
4. **Il ricordo della coppia.** La stessa coppia rivista dopo un mese mostra cosa e' cambiato in Oggi fra voi e nel Momento giusto: una ragione per tornare.
5. **Il codice a due telefoni come piccolo rito.** Medora che soffia il codice sullo schermo di chi condivide e lo raccoglie su quello di chi legge, con lo stesso video dell'astrolabio in polvere.
6. **Il ritratto animato**: la statuetta della coppia che gira lentamente nella card condivisa come video breve per le storie.

## LA SUITE INTERA

La corsa unica di fine ordine, sul commit e41f5b99, in locale nella copia LF `C:/Users/user/ecs`: 7.304 prove, 7.288 verdi e **16 rosse**, in 82 minuti (riletto dal file della corsa). Il fondatore: "80 minuti, troppo", poi "ok per GitHub ma deve diventare la regola per tutte le sessioni". Da qui la suite intera la fa il cancello `verde.yml` su GitHub (sei pezzi in parallelo, 13-15 minuti), regola scritta in CLAUDE.md. Il cancello su e41f5b99 si era fermato al primo rosso, quindi sui pezzi della suite pareva verde: i rossi veri erano quelli della copia locale.

**I sedici rossi e il loro padre (Regola C), tutti corretti**:
- **Voce FT.03, la lettura a due telefoni** (commit da84ea99):
  - `cosmo_e_interruttori`: lo `Switch` di Material nel modulo, ora `InterruttoreDelCerchio`;
  - `etichette_e_lettura`: un `Text` nel ruolo di lettura, ora `ParagrafiDiLettura`;
  - `language_rule`: una virgola prima di "e";
  - `una_prova_dichiara_il_suo_istante`: l'orologio vero in una prova;
  - `il_cerchio_custodisce_il_cammino`: le porte del server da 35 a 37, adesso dichiarate e motivate.
- **Voce FT.13, la scheda aperta a tutti i piani** (commit 8e682889). Un'arte attiva deve stare nelle tavole di casa:
  - `ogni_arte_dichiara_la_fonte`, due casi: la tavola, e il foglio "Fonti e metodo" che adesso sta nella barra della lettura;
  - `tue_arti_schermata`: la soglia unica col cuore, ora sulla rotta;
  - `i_ricordi_sono_nella_demo`: fuori dallo scaffale, dichiarato;
  - `le_altre_arti_del_cerchio`: la fila delle arti da scoprire.
- **Voce FT.06**, la lettura a video (commit abc9a63b):
  - `nessun_suono_che_non_hai_scelto`: un `InkWell` col click di sistema;
  - `le_porte_di_approfondimento_non_mandano_da_sole`: il Parlane non censito, ora nel censimento del manifesto DX;
  - `la_carta_natale_sopravvive`: `comeCarta`, una carta costruita in proprio e mai usata, tolta.
- **Voce FT.15, la consegna**:
  - `ogni_voce_chiusa_porta_la_sua_prova`: l'elenco delle voci chiuse in cima a questo rapporto mancava;
  - `i_manifesti_sono_sigillati`: il manifesto FT nel sigillo, 15 voci;
  - `i_rapporti_consegnati_non_si_correggono`: questo rapporto registrato alla consegna.
- **Falso positivo di una guardia, PROVENIENZA: ordine FH** (`real_time_cosmo_nessuna_seconda_porta_sull_astronomia`). Il suo `kepler` prendeva gli Intervalli di Keplero, che sono musica fra longitudini gia' calcolate e non un motore delle orbite. Corretta con la lapide in `kepler(?!o)`: rossa su un innesto vero (`risolviKepler`), verde sul codice.

Le prove della zona, rifatte dopo le correzioni in due giri: tutte verdi (86 piu' 1 nel primo giro, la sola rossa corretta e rifatta col secondo, 31 su 31). Il verdetto della suite intera e' quello del cancello di GitHub sul commit consegnato, nella riga in coda.

**Aggiunta del 15 ottobre 2026, ordine FT**: il verdetto della suite intera e' del cancello di GitHub (`verde.yml`), **verde sul commit d779f271** in 11 minuti, segno `refs/verde/d779f27171b1df511b3c02417f74cfe5b67b939c`. Sul commit 47163cb7, consegnato con questo rapporto, il cancello aveva trovato due rossi nuovi: `barra_arte_non_si_copre` e `il_cuore_e_il_tooltip_non_si_toccano`. Padre: voce FT.13, la correzione che metteva il foglio delle fonti nella barra senza `AngoloDellaBarra`. Corretti nel commit d779f271.
