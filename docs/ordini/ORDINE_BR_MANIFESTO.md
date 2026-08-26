# ORDINE BR, IL VIDEO DELLA RIVELAZIONE A SCHERMO INTERO

Ordine del fondatore del 26 agosto 2026. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_br_guard_test.dart`. Testa di partenza `cb5ffb26`.

**Parole del fondatore, che sono la premessa di tutto questo ordine**: "il video
di rivelazione dei maestri e' stato inserito dentro la carta, la carta che
solitamente sta dietro al maestro, mentre il video eravamo d'accordo che sarebbe
stata full screen come sfondo e inoltre il video si dovrebbe fermare all'ultimo
frame in modo che resti come immagine fissa". E poi: "il video va sotto come
sfondo e sopra ci metti i testi, info ecc. ma tienili come sono adesso in basso
cosi' copre solo la parte bassa del video, quindi dalla vita in giu' di ogni
maestro".

**L'ORDINE BQ AVEVA FATTO ESATTAMENTE CIO' CHE GLI ERA STATO CHIESTO, e cio' che
gli era stato chiesto era sbagliato.** Questo ordine non corregge un errore di
BQ: corregge la specifica. Niente di BQ.02 e BQ.03 e' stato toccato fuori dai
punti nominati qui sotto, e in particolare **la regola per cui il ritratto fermo
sta SEMPRE in albero sotto al video e' viva e vale ancora**: e' scritta in
`velo_di_rivelazione.dart` e misurata da due prove.

## Le premesse, verificate sulla testa cb5ffb26 prima di scrivere una riga

- **P1 VERA.** `lib/features/onboarding/widgets/maestro_card.dart` montava
  `VeloDiRivelazione` dentro lo `Stack` della carta, righe 160-171, in un
  `Positioned(bottom: 8)` con `SizedBox(width: widget.width, height:
  widget.height + 58)`. Parola per parola come l'ordine la descrive.
- **P2 VERA.** `lib/features/onboarding/widgets/velo_di_rivelazione.dart`, nel
  `build`, tornava `const SizedBox.shrink()` quando `lettore.finito` era vero:
  la riga era `if (lettore == null || !lettore.pronto || lettore.finito)`. Il
  filmato si toglieva da solo appena finiva, scoprendo l'immagine sotto.
- **P3 VERA.** `_LettoreConVideoPlayer.disegna()` usava
  `FittedBox(fit: BoxFit.contain, ...)`.
- **P4 VERA, con una precisazione che non cambia la sostanza.**
  `maestro_reveal_screen.dart` costruiva la `Column` con, nell'ordine:
  l'etichetta (`La rivelazione` o `Il tuo Maestro`), il nome del Maestro, un
  `Expanded` con dentro `Center` e poi l'`AnimatedSwitcher` fra `_RitualStage` e
  `MaestroCardReveal`, e in fondo `_RevealedFooter`. La precisazione: fra un
  pezzo e l'altro ci sono `SizedBox` di spaziatura, il piede sta dentro un
  `if (_revealed)` e nel ramo `else` c'e' l'invito a soffiare. Nessuno di questi
  dettagli e' stato spostato.
- **P5 VERA, misurata con `ffprobe` e non creduta sulla parola.** I tre file in
  `brand_assets/maestri/`: `medora_rivelazione.mp4` 720x1280,
  `caligo_rivelazione.mp4` 720x1280, `aura_rivelazione.mp4` 1080x1920. Il
  rapporto e' 0,5625 per tutti e tre, cioe' 9 a 16 esatto. Tutti e tre H.264
  High a 8 bit, 24 fotogrammi al secondo, 241 fotogrammi, 10,0417 secondi,
  nessuna traccia audio.

## Le tre voci

- **BR.00** La ricognizione, scritta prima di cambiare una riga. **CHIUSA**. Il
  video della rivelazione compariva in **un punto solo** dell'app,
  `maestro_card.dart` righe 156-171, dentro la cornice della carta; il percorso
  del file lo compone `RivelazioneInVideo.assetDi` e il lettore vive dietro
  l'interfaccia `LettoreDiRivelazione`, entrambi in
  `lib/core/maestro/rivelazione_in_video.dart`. La carta `MaestroCardReveal`
  veniva montata anch'essa in **un punto solo** di `lib/`,
  `maestro_reveal_screen.dart` riga 247, dentro l'`AnimatedSwitcher`, piu' due
  montaggi nelle prove (`il_video_del_maestro_si_rivela_test.dart`) e uno
  indiretto in `nessuno_disegna_oltre_la_tela_test.dart` e in
  `prima_dopo_capture_test.dart`, che montano la schermata intera. **COSA FA
  `video_player` QUANDO LA RIPRODUZIONE ARRIVA IN FONDO, e non e' una stima: e'
  una misura, perche' l'intera voce BR.02 dipendeva da questa risposta.** Con
  una piattaforma finta al posto di quella vera, portato il filmato alla fine:
  `pronto` resta vero, `finito` diventa vero, **i lettori liberati sono zero**,
  la vista della piattaforma e' **ancora in albero** e porta **lo stesso numero
  di prima**, viste costruite `[1, 1]`, e la posizione e' `0:00:10.000000`,
  cioe' la durata. Quindi la texture non viene ne' smontata ne' sostituita e la
  voce BR.02 puo' andare avanti. **Cio' che questa misura NON puo' dire**: se la
  superficie nativa conservi i pixel dell'ultimo quadro e' cosa del
  decodificatore, non di Flutter, e in una prova headless non c'e' nessun
  decodificatore da interrogare. Per questo BR.02 non ci scommette sopra, vedi
  la rete sotto al filmato descritta li'. La misura vive in
  `test/il_video_e_lo_sfondo_della_rivelazione_test.dart`, gruppo BR.00.

- **BR.01** Il video e' lo sfondo, non un inquilino della carta. **CHIUSA**.
  Il velo e' uscito da `maestro_card.dart` ed e' diventato il
  **primo figlio** dello `Stack` di `maestro_reveal_screen.dart`, con
  `fit: StackFit.expand`: primo figlio vuol dire strato piu' basso, e
  `StackFit.expand` gli da' le misure intere della schermata senza nessun
  `Positioned`. Il taglio e' passato da `BoxFit.contain` a `BoxFit.cover`. Il
  testo in alto, la carta e il piede coi pulsanti sono rimasti dove erano, con
  la stessa misura, e si disegnano dopo, quindi sopra. **La carta con la cornice
  non si monta affatto finche' il filmato e' a video**, in riproduzione o fermo:
  non e' un ramo dell'`AnimatedSwitcher`, perche' una dissolvenza di sei decimi
  avrebbe fatto sfumare il Maestro della cornice SOPRA il Maestro del filmato,
  cioe' proprio il secondo Maestro che questa voce vieta. La carta torna,
  identica a com'era, in tutti i casi in cui il filmato non c'e': file assente,
  codec rifiutato, lettore fallito, Riduci Movimento acceso, ed e' la voce BQ.03
  che resta viva. **MISURE, sullo schermo di riferimento 360x797 punti**: il
  velo misura **360 per 797**, cioe' i due numeri dello schermo e non quelli
  della carta; nell'albero vero il velo e' l'elemento numero **5** e il piede il
  numero **27**, quindi il piede si disegna dopo, verificato visitando gli
  elementi in ordine di figlio e non a occhio; il piede e' alto **136,0 punti su
  797, il 17,1 per cento** della schermata, contro un tetto del 38; il filmato
  1080x1920 viene disegnato a **448,3 per 797,0** su uno schermo 360x797, cioe'
  esce dai lati invece di lasciare bande, e con `contain` avrebbe lasciato due
  bande da **78,5 punti**; in **20 fotogrammi su 20** del passaggio i Maestri a
  video sono **uno**, mai due e mai zero; con Riduci Movimento i lettori creati
  sono **zero** e la carta e' in albero.

- **BR.02** Il filmato si ferma sull'ultimo fotogramma e ci resta. **CHIUSA**.
  Quando la riproduzione arriva in fondo non si chiude niente e non si smonta
  niente: `finito` diventa vero e lo dichiara, ma il lettore resta vivo e la sua
  vista resta in albero. Il fermo dura finche' la persona non lascia la
  schermata, senza timer e senza dissolvenza. **MISURE**: su **30 fotogrammi su
  30** controllati uno per uno dopo la fine, il filmato e' ancora a video e il
  lettore e' ancora vivo; il ritratto della carta non e' in albero in **nessuno
  dei 30**; cinque secondi dopo la fine il fermo e' ancora li'; dieci aperture e
  chiusure della schermata creano **dieci** lettori e ne lasciano vivi **zero**.
  **L'APP CHE PASSA IN SECONDO PIANO CONTINUA A CHIUDERE IL FILMATO**, come
  faceva prima e per la stessa ragione, e al ritorno si scopre la carta col
  ritratto fermo: **e' un esito dichiarato e non un difetto nascosto**, misurato
  in due tempi perche' un'app in pausa non disegna (il decodificatore liberato
  si conta subito, cio' che la persona vede si guarda al ritorno). Al ritorno il
  filmato **non riparte da solo**: un filmato che ricomincia mentre qualcuno sta
  leggendo il suo primo momento sarebbe peggio del ritratto.

## La prova del rosso, eseguita su tutte e due le voci

Per ognuna il difetto e' stato rimesso nel sorgente, **l'iniezione e' stata
verificata dentro il file con un `grep` prima di leggere l'esito**, e il numero
qui sotto e' quello che la prova ha stampato da rossa. Nessuna soglia e' stata
toccata.

- **BR.01.** Il velo rimesso dentro un `SizedBox(width: 240, height: 340 + 58)`,
  cioe' le misure della carta. Verifica dell'iniezione: `width: 240` trovato a
  riga 260. La prova ha stampato `il velo misura 240 per 398, lo schermo 360 per
  797` ed e' caduta con `Expected: <360.0>` e `Actual: <240.0>`, messaggio "il
  velo e' largo 240.0 invece di 360.0: non e' lo sfondo della schermata, e'
  l'inquilino di qualcosa di piu' stretto". **Da notare, ed e' un limite
  dichiarato**: con quell'iniezione le altre prove della voce restavano verdi,
  perche' misurano l'ordine dello `Stack` e l'assenza della carta, che quel
  difetto non tocca. La misura che tiene la voce e' quella delle dimensioni.
- **BR.02.** Rimesso il ritorno a `SizedBox.shrink()` alla fine del filmato:
  `if (lettore == null || !lettore.pronto || lettore.finito)`. Verifica
  dell'iniezione: `lettore.finito) {` trovato a riga 172. La prova e' caduta
  **al fotogramma 0** dopo la fine, con `Expected: <1>` e `Actual: <0>`, e con
  lei e' caduta anche "Il fermo non ha timer: cinque secondi dopo e' ancora
  li'". Due rossi su un difetto solo.

## Cio' che l'ordine ha cambiato, file per file

- `lib/features/onboarding/widgets/velo_di_rivelazione.dart`: il velo e' a
  schermo pieno, `cover` invece di `contain`, non si toglie piu' alla fine del
  filmato, e dichiara a chi lo monta quando il filmato e' a video con un
  `ValueNotifier<bool>` che scrive dentro lo stesso `setState` che lo ridisegna.
  **Il segnale nello stesso `setState` non e' un dettaglio**: e' cio' che rende
  impossibile il fotogramma con due Maestri o con nessuno, ed e' misurato.
- `lib/features/onboarding/widgets/maestro_card.dart`: il velo e' uscito, e con
  lui il parametro `fabbricaDelVideo`. La carta e' tornata quella di prima, e in
  cima al file c'e' scritto perche'.
- `lib/features/onboarding/maestro_reveal_screen.dart`: la schermata e' uno
  `Stack` col velo sotto e tutto il resto sopra, tiene il `ValueNotifier` e lo
  libera, la carta non si monta quando il filmato copre, il piede ha preso la
  chiave `reveal_footer` perche' una misura lo trovi per nome, e la porta
  `fabbricaDelVideo` e' salita qui dalla carta.
- `test/attorno_alla_rivelazione.dart`, nuovo: l'impalcatura minima attorno alla
  schermata, i due controller che legge dal contesto, lo schermo pinnato a
  360x797 e il banco dei lettori finti. Prima le prove montavano la carta e
  bastavano due righe; adesso montano la schermata, e questa impalcatura scritta
  in ogni file avrebbe divergito al primo controller aggiunto.
- `test/il_video_del_maestro_si_rivela_test.dart`: le misure dell'ordine BQ sono
  **le stesse**, prese sul nuovo punto di montaggio. Le prove adesso montano la
  schermata e compiono il rito del soffio, altrimenti misurerebbero un pezzo di
  app che non esiste piu'. L'unica riga che cambia senso e' "alla fine del video
  il Maestro non sparisce mai": il ritratto che resta in albero non e' piu'
  quello della carta, e' quello che il velo tiene sotto al filmato.
- `test/il_video_e_lo_sfondo_della_rivelazione_test.dart`, nuovo: le misure di
  BR.00, BR.01 e BR.02.
- `test/ordine_br_guard_test.dart`, nuovo: la guardia di questo manifesto.

**UNA GUARDIA DI CASA HA PRESO IL MIO CODICE NUOVO, e nessuna delle dodici prove
che ho scritto io la guardava.** Il ritratto sotto al filmato era un
`Image.asset(maestro.avatarAsset, ...)` scritto dentro il velo, e
`il_busto_e_la_forma_del_maestro_test` pretende che la scelta dell'immagine del
Maestro viva in un punto solo, enumerato file per file: il velo era una seconda
porta. **Non e' stato aggiunto all'elenco, che sarebbe stato il modo di far
tacere la guardia**: la figura intera e' uscita da `maestro_card.dart` come
`RitrattoInteroDelMaestro`, una porta sola con la sua altezza dichiarata, e
adesso la carta e il velo disegnano la stessa figura passando di li'. Due punti
che scelgono la stessa immagine divergono al primo cambiamento. L'ha trovata la
suite intera e non la rilettura, ed e' il terzo ordine di fila in cui succede.

## Due cose che restano vere e vanno sapute

**IL RITRATTO SOTTO AL FILMATO NON E' A SCHERMO PIENO, ed e' voluto.** Sotto al
velo, ogni volta che c'e' un filmato da disegnare, c'e' il ritratto del Maestro:
e' la regola dell'ordine BQ, ed e' la rete che rende impossibile il rettangolo
nero anche il giorno che una texture si svuotasse. Quel ritratto pero' e' alto
398 punti, la stessa altezza a cui la carta lo disegna, e non a schermo pieno con
`cover`: a schermo pieno, sul telefono di riferimento a rapporto 3, sarebbero
2391 pixel fisici contro i **1700** della tela su cui gli avatar sono stati
normalizzati, e la prova `nessuno_disegna_oltre_la_tela` esiste per impedire
esattamente quello. Sotto al filmato non si vede comunque mai; il giorno che si
vedesse, si vedrebbe il Maestro alla misura giusta invece di un Maestro sfocato.

**LA STRISCIA IN CIMA RESTA AL COSMO, e questo ordine non la prende.** Il velo
riempie tutta l'area che la schermata riceve, ed e' cio' che le misure dicono.
Nell'app vera pero' la schermata vive dentro `ImmersiveScaffold`, che mette il
suo contenuto dentro una `SafeArea` con `top` attivo: sopra al velo resta la
striscia della barra di stato, alta quanto il rientro del telefono, e li' si vede
il cosmo e non il filmato. Prendersi anche quella striscia vuol dire disegnare
fuori dai propri limiti, e in questo repository c'e' una prova, `nessuno disegna
oltre la tela`, nata apposta contro quel genere di scorciatoia; l'alternativa
pulita e' dare alla fase della rivelazione un'impalcatura sua senza `SafeArea` in
cima, che tocca un componente condiviso da tutti i flussi del Risveglio. **Non e'
stato fatto e non e' stato nascosto: e' una decisione del fondatore, non mia.**

## Cio' che questo ordine non ha toccato

La scena del soffio prima della rivelazione. I tre file video, che restano quelli
che sono: sono un test, due su tre portano il watermark, tutti e tre andranno
rifatti. Ogni altro punto in cui l'avatar del Maestro compare, e in particolare i
tre busti in santuario e in maestri. La versione nel `pubspec.yaml`, che si tocca
solo al momento della consegna. **Non si e' costruito e non si e' consegnato: la
build la fa il fondatore dal suo PC.**

## La suite, alla chiusura dell'ordine

**3.675 prove verdi e 2 rosse**, con `TZ=Europe/Rome`, **ad albero davvero fermo**: l'impronta `sha1` di tutti i sorgenti sotto `lib`, `test`, `docs`, `tool` e del `pubspec.yaml`, presa prima del primo test e dopo l'ultimo, e' la stessa, `fb965114`. I due rossi sono i due dichiarati: l'attribuzione cieca, rossa per dichiarazione dall'ordine BP, e `niente_lavoro_non_spinto`, che si chiude col commit e con la spinta. Il giro precedente ne aveva tre, e il terzo era la guardia del busto qui sopra. `flutter analyze`: **zero avvisi**.

**I due file che la suite riscrive da se'**, e che entrano nel commit di chiusura: l'anteprima `docs/preview/prima_dopo/icona_cerchio_accanto.png`, rigenerata dalle catture, e `docs/tipografia/alba_contrasto.md`, che cambia solo il fine riga. Rigenerati al primo giro e **identici al secondo**, quindi non ballano.

MARCATORI, per la guardia:
VOCI_TOTALI: 3
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 3
