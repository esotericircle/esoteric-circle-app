ORDINE FV, IL CALENDARIO LUNARE PERSONALE: L'ALMANACCO DI MEDORA
Esoteric Circle. Ramo claude/esoteric-circle-master-order-e798aj, nessun altro.
Testa vista dall'Architetto il 15 ottobre 2026 alle 02:10: 8511447 (ordine FU
in corso, voce FU.15 nel ramo). Questo ordine si esegue a ordine FU
consegnato, col verde di GitHub sul suo commit di consegna.

Leggi l'ordine per intero, dalla prima all'ultima voce, prima di scrivere
codice.

CODE PORTA A TERMINE TUTTO L'ORDINE, OGNI VOCE, FINO ALLA CONSEGNA. Non si
ferma a metà, non rimanda voci, non lascia lavoro da ordinare di nuovo. Se il
contesto si stringe, comprime i rapporti e non il lavoro. L'unica fermata
ammessa è una premessa falsa.

REGOLA ZERO. Verifica tutto sul ramo, anche ciò che l'ordine dà per certo.
REGOLA UNO. Code non si ferma, risolve. Chi decide: 1 Code, 2 agenti e
subagenti, 3 l'Architetto per ultimo.

======================================================================
FONTI DI QUESTO ORDINE
======================================================================
- Parole del fondatore del 15 ottobre 2026, citate nelle voci.
- Briefing Progetto Definitivo V13, sezione 38 (Lunologia).
- Master Briefing Tecnico V13, sezioni 41 (Calendario lunare: dati lunari
  dal motore, nessun carico per il modello, contenuti pre-generati) e 43
  (Lunologia: note tecniche, Luna fuori corso, calendario biodinamico).
- Linee Guida UX V13, sezioni 3 (la card condivisibile), 26, 27 e 28.
- La proposta dell'Architetto del 15 ottobre 2026 approvata dal fondatore,
  riportata nelle voci.
- Le linee guida della NASA sull'uso delle immagini
  (https://nasa.gov/nasa-brand-center/images-and-media) e la pagina dello
  Scientific Visualization Studio sulla fase della Luna
  (https://svs.gsfc.nasa.gov/5612/), lette dall'Architetto il 15 ottobre 2026.
I quattro V13 stanno in D:\Clienti Roogly\Rituali Cartomanzia\App\Briefing
Definitivi\V13. Le copie in docs/ del ramo sono ancora le vecchie: per questo
ordine valgono i V13.

======================================================================
LE PARTI DI QUESTO ORDINE
======================================================================
PARTE A, voci da FV.01 a FV.04: gli asset, la scena in video, le lune vere
della NASA, il motore lunare.
PARTE B, voci da FV.05 a FV.09: il mese di trenta lune, "Trova il giorno",
i giorni tuoi, il promemoria, l'intenzione alla Luna nuova.
PARTE C, voci da FV.10 a FV.13: "Trova il giorno insieme", la card del
mese, i piani e gli Eos, la porta.
La consegna, voce FV.14, è unica per tutte le parti.

======================================================================
LA FUNZIONE IN UNA RIGA
======================================================================
Il Calendario Lunare è l'almanacco personale di Medora: il mese è fatto di
trenta lune vere; la persona sceglie cosa vuole fare e i giorni giusti si
accendono d'oro col loro perché; sul mese compaiono i giorni che sono solo
suoi; un promemoria la avvisa il giorno prima; con gli amici del Cerchio
trova il giorno buono per tutti. Fonte: proposta dell'Architetto del 15
ottobre 2026; il fondatore: "Siz approvo tutto".

======================================================================
PREMESSE DA ABBATTERE
======================================================================
Verificale tutte sulla testa del ramo prima di toccare il codice, ognuna col
suo comando. Una falsa ferma la voce che la usa, non l'ordine.
P1. La cartella D:\Clienti Roogly\Rituali Cartomanzia\App\Calendario Lunare
    Scena\ contiene sette file: lunario_almanacco_chiuso_v1.jpg,
    lunario_almanacco_aperto_v1.jpg, medora_apre_l_almanacco_v1.jpg,
    medora_regge_il_mese_v1.jpg (768 per 1376),
    lunario_primo_fotogramma_v1.jpg, lunario_ultimo_fotogramma_v1.jpg
    (1080 per 1920), medora_almanacco_di_luce_v1.mp4 (1080 per 1920, otto
    secondi, 24 fotogrammi al secondo, 7,8 MB, con traccia audio).
P2. La sottocartella Elementi\ della stessa cartella contiene 29 file:
    - undici emblemi delle attività, 512 per 512 su fondo trasparente:
      emb_capelli_v1.png, emb_orto_v1.png, emb_piante_v1.png,
      emb_casa_v1.png, emb_conserve_v1.png, emb_vino_v1.png,
      emb_bellezza_v1.png, emb_pesca_v1.png, emb_inizi_v1.png,
      emb_viaggi_v1.png, emb_amore_v1.png;
    - nove sigilli, 512 per 512 su fondo trasparente:
      sig_tuo_ritorno_lunare_v1.png, sig_luna_sul_tuo_sole_v1.png,
      sig_luna_nel_tuo_segno_v1.png, sig_tua_fase_di_nascita_v1.png (cornice
      d'oro, i giorni tuoi), sig_thun_radice_v1.png, sig_thun_foglia_v1.png,
      sig_thun_fiore_v1.png, sig_thun_frutto_v1.png,
      sig_luna_fuori_corso_v1.png (cornice d'argento);
    - luce_alone_oro_v1.png, luce_scia_oro_v1.png, seme_di_luce_v1.png: luci
      su fondo nero, da posare in fusione schermo (il nero sparisce);
    - castone_luna_v1.png: il castone d'argento, 512 per 512, interno
      trasparente;
    - card_mese_sfondo_v1.jpg: lo sfondo notturno della card, 768 per 1376;
    - quattro fogli originali da cui l'Architetto ha ritagliato i pezzi:
      foglio_emblemi_a_v1.jpg, foglio_emblemi_b_v1.jpg,
      foglio_sigilli_v1.jpg, foglio_luci_v1.jpg. Restano fuori dal ramo.
P3. lib/core/arts/art_catalog.dart porta la voce lunar_calendar, titolo
    "Calendario Lunare Personale", ArtState.inArrivo, ArtPhase.faseSuccessiva;
    lib/core/arts/gli_sfondi_delle_schede.dart le dà lo sfondo
    Calendario-Lunare; lib/features/santuario/le_righe_della_casa.dart la
    mette nella riga la_tua_intenzione.
P4. Il motore del cielo sul telefono è lib/core/astro/meeus/ (posizioni di
    Luna e pianeti, verificate contro Swiss Ephemeris dall'ordine FT); la
    fase viene da lib/core/astro/moon_phase.dart, che la prende da Celestial;
    la Luna di nascita da lib/core/identity/birth_moon.dart. Nel ramo non
    esistono oggi né il calcolo della Luna fuori corso né il calendario
    biodinamico: la sola voce che li nomina è il testo di art_catalog.dart.
P5. Il Respiro della Luna (lunology) non è costruito: ArtState.inArrivo.
P6. lib/features/scene/la_scena_in_video.dart porta il lettore e la regia
    comuni delle scene e il tocco che salta il video (IlToccoCheSalta),
    dall'ordine FU voce FU.15.
P7. lib/features/synastry/la_tua_nascita_per_una_lettura.dart è il gesto
    con cui una persona dà la sua nascita per una lettura sola, col suo
    consenso (ordine FT); lib/core/cerchio/il_cerchio_sociale.dart e
    functions/src/il_cerchio_sociale.ts portano gli amici del Cerchio.
P8. lib/services/avvisi_locali.dart è il punto degli avvisi del telefono
    (flutter_local_notifications in pubspec.yaml).
P9. lib/core/legal/fonti_dei_dati.dart elenca le fonti dei dati dell'app e
    non nomina oggi la NASA.
P10. lib/core/astro/luogo_attuale.dart dà il luogo della persona con
    latitudine e longitudine.
P11. docs/ordini/ non contiene nessun file ORDINE_FV_*; CLAUDE.md porta la
    regola SPESE del 14 ottobre 2026 e la regola della suite su GitHub.

======================================================================
REGOLE FISSE
======================================================================
R1. Ogni voce porta la sua fonte. Le scelte di Code si scrivono nel
    rapporto con la ragione accanto.
R2. SPESE. Questa funzione non chiama Gemini né altri servizi a consumo, né
    durante l'ordine né quando gira: tutto è calcolo sul telefono e corpus
    scritto da Code (Master V13 sezione 41). Nessun giro dei banchi.
R3. Nessuna build. Le build le ordina il fondatore. Nessuna pubblicazione
    delle funzioni sul server: il lavoro sul server si scrive, si prova e
    non si pubblica; il comando per pubblicarlo va nel rapporto.
R4. Niente dati di produzione, nemmeno sul telefono di collaudo. Nessuna
    credenziale chiesta in chat.
R5. Le Regole A e B delle guardie: ogni prova nuova vista rossa con
    l'innesto verificato prima di leggere l'esito; la zona toccata vista
    rossa prima di toccarla. Quando il rosso non scatta si cambia la
    grandezza misurata, mai la soglia.
R6. Ogni voce chiusa porta DOMANDA, PROVA, MISURA. Ogni affermazione visiva
    è una cattura o una misura. Una voce che si vede solo sul telefono resta
    APERTA IN ATTESA DI VERIFICA.
R7. Lingua: italiano con gli accenti veri, mai il trattino lungo, mai la
    virgola prima di "e" o di "ed", il tu, la marca del genere a tre vie dove
    il testo parla di chi legge.
R8. LA REGOLA DI CASA SUI TESTI. Ogni testo, scritto da Code, sta nella voce
    di Medora e segue queste regole:
    - niente salute: nessuna regola lunare su interventi, cure, dentista,
      diete, digiuni o farmaci;
    - niente soldi e investimenti;
    - nessuna promessa di esito: la Luna indica il momento, non garantisce
      il risultato;
    - ciò che viene da una tradizione si cita con la sua fonte; ciò che non
      è documentato si dice chiave di Medora, mai tradizione;
    - il disclaimer di casa, come nelle altre arti.
R9. LA GRAFICA È DIPINTA, NON DISEGNATA. Fonte: il fondatore, 15 ottobre
    2026: "vorrei evitare il più possibile la grafica procedurale". Lune,
    emblemi, sigilli, aloni, scia, castone, seme e sfondo della card sono gli
    asset di P1 e P2 e le foto della voce FV.03. Flutter disegna solo testo,
    posizioni, dissolvenze, opacità e movimenti di quegli asset. Nessuna
    forma lunare, cornice o icona disegnata dal codice al loro posto.
    Guardia: rossa se un widget di questa funzione disegna una Luna, un
    cerchio decorativo o un'icona di Material al posto di un asset.
R10. Il giro dell'utente prima di chiudere una voce: percorri la funzione
    come una persona e confrontala con la Stesa di Tarocchi e con l'Oracolo
    degli Angeli, dichiarando ogni differenza. Migliorie ed effetti wow li
    proponi nel rapporto, senza costruirli.
R11. Restano com'erano: le altre arti di Lunologia (il Respiro della Luna
    resta inArrivo, l'Affinità Lunare resta com'è), l'Oroscopo, la Sinastria
    evolutiva e il Cerchio. Il motore lunare nuovo della voce FV.04 vive in
    un punto solo e il Respiro della Luna lo userà quando sarà costruito.
R12. Il manifesto docs/ordini/ORDINE_FV_MANIFESTO.md coi quattro marcatori,
    la sua guardia, il rapporto e STATO_VIVO.

======================================================================
FV.01 GLI ASSET NEL RAMO
======================================================================
Fonte: il fondatore, 15 ottobre 2026: "Va bene Salva" sul video e sugli
asset della scena; "Approvo cominciamo" sull'elenco degli asset; "Approvo"
sulle undici categorie; sulla card: "Ma perché la tavola è bianca? Ok il
bianco e il tondo della luna, ma la luna risplende di notte", da cui la
tavola notturna di P2.
- Copia nel ramo i sette file di P1 e i 25 pezzi di P2 (i quattro fogli
  originali restano fuori): le immagini in assets/img/calendario_lunare/
  convertite in webp mantenendo la trasparenza, il video ricompresso (voce
  FV.02) in brand_assets/calendario_lunare/. Dichiarali in pubspec.yaml (il
  video con la sua impronta, come nell'ordine FS) e in docs/stato_asset.json.
- Nessun asset si rigenera o si ritocca nei colori: lo stile è approvato dal
  fondatore.
- Le tre luci di P2 si posano in fusione schermo: misura su una cattura che
  il fondo nero non lasci un riquadro visibile sullo sfondo della scena.

======================================================================
FV.02 LA SCENA: L'ALMANACCO DI LUCE
======================================================================
Fonte: Linee Guida V13 sezione 28; proposta dell'Architetto approvata dal
fondatore il 15 ottobre 2026 ("Siz approvo tutto"); sul video: "Va bene
Salva"; il fondatore, 14 ottobre 2026: "No, si ripete sempre il video, ma si
può sfumare saltare con un click"; il fondatore, 15 ottobre 2026: "parte
all'apertura della funzionalità e basta"; P6.
- All'apertura del Calendario parte medora_almanacco_di_luce_v1.mp4, una
  volta per apertura, dal lettore e dalla regia comuni di P6: Medora apre
  l'almanacco, le pagine sfogliano, una luce d'argento sale e si apre nel
  velo che lei regge a braccia alzate.
- Il video si ricomprime prima di entrare nel ramo col metodo dell'ordine
  FU voce FU.12, col peso prima e dopo e una cattura dello stesso
  fotogramma prima e dopo. L'audio resta solo se la scena lo suona (Linee
  Guida sezione 28).
- Si ferma sull'ultimo fotogramma, che coincide con
  lunario_ultimo_fotogramma_v1: misura lo scarto come in FS voce A2.
  L'Architetto ha misurato uno scarto medio di 9,5 livelli su 255.
- L'ultimo fotogramma resta come sfondo fisso del Calendario. Sopra, in
  dissolvenza, compare il mese di trenta lune della voce FV.05, posato sul
  velo. L'Architetto ha misurato il velo sull'ultimo fotogramma: dal 21 al 78
  per cento della larghezza del video, dal 19 al 64 per cento dell'altezza.
  Rimisuralo e mappalo tenendo conto del taglio del video sullo schermo del
  telefono. La griglia può essere più grande del velo e lasciarlo sotto come
  alone, come le carte della Sinastria VIP nell'ordine FU voce FU.14.
- Il tocco che salta il video passa dal punto unico di P6.
- Ripieghi obbligatori: con Riduci Movimento, con la grafica alleggerita o se
  il video non si carica, scena ferma lunario_ultimo_fotogramma_v1 col mese
  sopra in dissolvenza. Audio come nella Stesa: solo con l'interruttore del
  suono acceso e il telefono non in silenzioso, senza prendere il fuoco
  audio.

======================================================================
FV.03 LE LUNE VERE DELLA NASA
======================================================================
Fonte: il fondatore, 15 ottobre 2026, "Approvo cominciamo" sulla proposta
dell'Architetto: "A, foto vere della Luna"; linee guida della NASA lette
dall'Architetto il 15 ottobre 2026.
- Ogni giorno del mese mostra la Luna vera di quel giorno: una fotografia
  dello Scientific Visualization Studio della NASA (la serie "Moon Phase and
  Libration", la stessa di https://svs.gsfc.nasa.gov/5612/), non una Luna
  disegnata. Scarica dal sito dello Studio le immagini di una lunazione
  intera, una per ogni giorno lunare, trenta in tutto; Code sceglie la
  lunazione e la risoluzione e le dichiara, con l'indirizzo di ogni file.
- Ogni immagine si scontorna sul disco della Luna su fondo trasparente e
  sta in assets/img/calendario_lunare/lune/ in webp. Il giorno del
  calendario prende l'immagine con l'elongazione più vicina a quella
  calcolata dal motore per quel giorno, a mezzogiorno locale. Misura e
  dichiara lo scarto massimo di fase fra l'immagine scelta e il cielo vero.
- Ogni Luna sta nel castone_luna_v1 di P2, col numero del giorno in testo
  Flutter.
- La Luna si vede come la vede la persona: per chi sta nell'emisfero sud
  (P10) l'immagine ruota di 180 gradi. Verifica la regola sulla fonte e
  dichiarala.
- LE REGOLE DELLA NASA, da rispettare tutte. Le immagini della NASA in
  genere non sono coperte da copyright negli Stati Uniti; la NASA va citata
  come fonte. Quindi:
  - una riga in lib/core/legal/fonti_dei_dati.dart (P9): "Immagini della
    Luna: NASA's Scientific Visualization Studio", con l'indirizzo;
  - nessun logo della NASA, da nessuna parte;
  - nessuna frase che lasci intendere che la NASA approvi o sponsorizzi
    l'app;
  - nei testi di Medora la NASA non si nomina mai: le linee guida vietano
    nei prodotti con intelligenza artificiale frasi come "secondo la NASA".
  Verifica di nuovo le linee guida alla data dell'ordine e cita nel
  rapporto il testo letto.

======================================================================
FV.04 IL MOTORE LUNARE, IN UN PUNTO SOLO
======================================================================
Fonte: Master V13 sezioni 41 e 43; Briefing Progetto V13 sezione 38; P4.
- Un punto solo nel codice calcola, per ogni giorno e nell'ora locale della
  persona: la fase e l'elongazione; il segno della Luna e l'ora in cui
  cambia; la Luna fuori corso, cioè l'intervallo dall'ultimo aspetto
  maggiore della Luna a un pianeta fino al suo ingresso nel segno
  successivo (Master V13 sezione 43); il giorno lunare; il tipo di giorno
  del calendario biodinamico. Usa le posizioni di lib/core/astro/meeus/,
  nessun secondo motore.
- La Luna fuori corso si prova contro una fonte esterna: almeno venti
  intervalli di un anno confrontati con effemeridi pubblicate, con lo
  scarto massimo in minuti dichiarato. Code sceglie gli aspetti maggiori e
  i corpi secondo la definizione classica e li dichiara con la fonte.
- IL CALENDARIO BIODINAMICO. Il metodo di Maria Thun lega il giorno al
  passaggio della Luna davanti alle costellazioni vere dello zodiaco, di
  grandezza diseguale, non ai segni: radice, foglia, fiore, frutto. Verifica
  il metodo e i confini delle costellazioni su fonti documentate, citale nel
  codice e nel rapporto. Si usa il metodo, mai le tabelle copiate da un
  calendario pubblicato. Se un confine non si documenta, il tipo di giorno
  non si mostra e il rapporto dice perché.
- I giorni del mese si calcolano sul telefono, senza rete. Dichiara il
  tempo di calcolo di un mese e di dodici mesi.

======================================================================
FV.05 IL MESE DI TRENTA LUNE
======================================================================
Fonte: proposta dell'Architetto del 15 ottobre 2026, voce 1 ("Il mese di
trenta lune"); il fondatore: "Siz approvo tutto".
- La griglia del mese ha sette colonne, la settimana parte dal lunedì, i
  nomi dei giorni e del mese in italiano. Ogni giorno è la sua Luna vera
  (FV.03) nel castone, col numero del giorno.
- All'apertura, quando il video si ferma, le lune si accendono a cascata
  dalla Luna nuova alla piena, un giorno dopo l'altro. Con Riduci Movimento
  compaiono tutte insieme in dissolvenza.
- Il giorno di oggi si riconosce al primo sguardo. Sotto ogni Luna, piccoli,
  i sigilli del giorno quando servono: la Luna fuori corso
  (sig_luna_fuori_corso_v1) e, nelle categorie dell'orto e delle piante, il
  tipo di giorno biodinamico (sig_thun_*).
- Il tocco su un giorno apre il suo foglio: la fase e il nome italiano, il
  segno della Luna e l'ora in cui cambia, le ore fuori corso, il giorno
  lunare, il tipo biodinamico. Il formato è quello del responso (Linee Guida
  V13 sezione 26), col "Da dove viene" in fondo.
- Si passa da un mese all'altro scorrendo, nei limiti del piano (FV.12).

======================================================================
FV.06 TROVA IL GIORNO
======================================================================
Fonte: proposta dell'Architetto del 15 ottobre 2026, voce 2; sulle
categorie, il fondatore: "Non ci sono altre cose da fare oltre semina,
taglio, ecc?" e, sulla lista di undici categorie dell'Architetto,
"Approvo".
- Sopra il mese, la fila degli undici emblemi di P2. Ogni categoria ha le
  sue attività:
  - Capelli e unghie (emb_capelli): taglio per farli crescere, taglio per
    rinforzarli, taglio delle unghie.
  - Orto (emb_orto): semina, trapianto, potatura, raccolto.
  - Piante e giardino (emb_piante): rinvasi, talee, fiori, piante da
    appartamento.
  - Casa (emb_casa): pulizie, bucato e macchie, traslochi, lavori.
  - Cucina e conserve (emb_conserve): conserve, pane e lievitati.
  - Vino e cantina (emb_vino): travasi, imbottigliamento.
  - Bellezza (emb_bellezza): depilazione, trattamenti.
  - Pesca (emb_pesca).
  - Inizi e firme (emb_inizi).
  - Viaggi (emb_viaggi).
  - Amore (emb_amore): primo appuntamento, dichiarazione, nozze.
- Il tocco su un'attività: la scia d'oro (luce_scia_oro_v1) passa sul mese
  come la mano di Medora, i giorni migliori si accendono con l'alone d'oro
  (luce_alone_oro_v1), i giorni da evitare si spengono in opacità. Con Riduci
  Movimento niente scia: gli aloni compaiono in dissolvenza.
- LE REGOLE. Per ogni attività Code scrive il corpus delle regole lunari con
  la fonte di ciascuna: la tradizione degli almanacchi e dei lunari
  contadini italiani (per esempio il Barbanera, stampato dal 1762); Maria
  Thun per l'orto e le piante; l'astrologia elettiva classica per amore,
  inizi e viaggi (per esempio la Luna crescente, non fuori corso, nei segni
  che la tradizione indica). Una regola senza fonte non entra. Le ore fuori
  corso tolgono l'oro a inizi, firme, amore e viaggi.
- Il modo in cui più fattori fanno un giorno d'oro è la chiave di Medora e
  si dichiara così. Ogni giorno d'oro mostra al tocco il suo perché in
  chiaro, per esempio: "Luna crescente, in Leone, fuori corso solo dalle 3
  alle 5".
- R8 vale per ogni regola: nessuna attività di salute, nessun consiglio sui
  soldi, nessuna promessa di esito.

======================================================================
FV.07 I GIORNI TUOI
======================================================================
Fonte: proposta dell'Architetto del 15 ottobre 2026, voce 3 ("I giorni
tuoi"); il fondatore: "Siz approvo tutto".
- Sul mese compaiono quattro segni che solo la persona vede, coi sigilli
  d'oro di P2:
  - il ritorno della sua Luna, cioè il giorno in cui la Luna torna al grado
    della sua Luna di nascita (sig_tuo_ritorno_lunare);
  - la Luna sul suo Sole (sig_luna_sul_tuo_sole);
  - la Luna nel suo segno solare (sig_luna_nel_tuo_segno);
  - il giorno in cui torna la fase lunare della sua nascita
    (sig_tua_fase_di_nascita), come contenuto simbolico, nel solco della
    decisione del fondatore del 4 settembre 2026 sulla "PRIMA VIA, LA
    SIMBOLICA": nessun calcolo di fertilità, nessuna parola sulla
    fecondità.
- Senza l'ora di nascita, i segni che dipendono dalla Luna di nascita (il
  ritorno della Luna e la fase di nascita) tacciono e al loro posto c'è
  l'invito a inserire l'ora, con la stessa regola che l'ordine FT dà alla
  Luna quando l'ora non è nota.
- Ogni segno ha il suo testo breve nella voce di Medora, dal corpus.

======================================================================
FV.08 IL PROMEMORIA
======================================================================
Fonte: proposta dell'Architetto del 15 ottobre 2026, voce 4 ("Il
promemoria senza fatica"); P8.
- Su un giorno d'oro la persona fissa la sua attività con un tocco. Il
  giorno prima, all'ora che Code sceglie e dichiara, arriva l'avviso del
  telefono nella voce di Medora, per esempio: "Domani la Luna è giusta per i
  capelli".
- Passa dal punto degli avvisi di P8 e dalla richiesta del permesso che
  l'app usa già. Senza permesso il promemoria resta segnato sul mese e
  l'app lo dice, senza vicoli ciechi.
- Le attività fissate si vedono sul mese con l'emblema piccolo della
  categoria; si tolgono con un tocco.

======================================================================
FV.09 L'INTENZIONE ALLA LUNA NUOVA
======================================================================
Fonte: il fondatore, 15 ottobre 2026: "non mi piace la cosa
dell'intenzione, lo trovo impegnativo, ma lasciamolo per ora"; proposta
dell'Architetto, voce 6: "leggerissima".
- Sul giorno della Luna nuova compare il seme di luce (seme_di_luce_v1). Chi
  vuole scrive la sua intenzione in una riga; alla Luna piena Medora gliela
  ricorda con un avviso. Nessun'altra tappa, nessun obbligo, nessun
  richiamo se la persona non scrive niente.
- L'intenzione è privata: non va sulla card e non va al Cerchio.

======================================================================
FV.10 TROVA IL GIORNO INSIEME
======================================================================
Fonte: proposta dell'Architetto del 15 ottobre 2026, voce 5; Linee Guida V13
sezione 27 ("Come renderla social e virale? Perché la persona dovrebbe
coinvolgere i propri amici?"); P7.
- La persona sceglie uno o più amici del Cerchio e un'attività fra cena,
  viaggio, trasloco e le attività della voce FV.06. Il calendario accende i
  giorni buoni per tutti: le regole della voce FV.06 più, per chi ha dato la
  sua nascita, i suoi giorni della voce FV.07.
- La nascita di un amico passa solo col suo consenso esplicito, una volta
  per lettura, col gesto di P7; non entra mai nel profilo pubblico e non
  resta sul telefono di chi chiede. Senza il consenso valgono solo le
  regole della voce FV.06.
- La persona manda la proposta del giorno; gli amici la ricevono nell'app e
  rispondono sì, no o un altro giorno d'oro. Riusa ciò che il Cerchio ha già
  per gli inviti e i messaggi (P7); se serve un lavoro nuovo sul server, si
  scrive e si prova senza pubblicarlo (R3).
- Un amico che non è ancora nel Cerchio riceve l'invito con la pagina
  dell'invito che l'app usa già.

======================================================================
FV.11 LA CARD DEL MESE
======================================================================
Fonte: Linee Guida V13 sezione 3 (la card condivisibile, formato unico,
verticale per le storie, palette di Medora, sigillo del Maestro, watermark,
logo, collegamento diretto); proposta dell'Architetto, voce "Social e
virale"; sullo sfondo: il fondatore, 15 ottobre 2026, "la luna risplende di
notte".
- La card usa card_mese_sfondo_v1 di P2. L'Architetto ha misurato il campo
  centrale vuoto: dal 13 all'87 per cento della larghezza, dal 24 all'80 per
  cento dell'altezza. Rimisuralo. Nel campo vanno le trenta lune vere del
  mese e, se la persona ha scelto un'attività, i suoi giorni d'oro.
- In alto il titolo del mese; in basso il sigillo di Medora, il logo e il
  collegamento diretto, come vuole la sezione 3.
- Mai dati di nascita sulla card: niente giorni tuoi, niente intenzione.
  Guardia: rossa se un dato della voce FV.07 o FV.09 entra nella card.

======================================================================
FV.12 I PIANI E GLI EOS
======================================================================
Fonte: proposta dell'Architetto del 15 ottobre 2026, "Piani ed Eos
(proposta)"; il fondatore: "Siz approvo tutto"; Linee Guida V13 sezione 27,
PER I PIANI.
- Viandante: il mese in corso con le fasi e i giorni tuoi, "Trova il giorno"
  per una categoria.
- Iniziato: tutte le categorie, i promemoria, il mese successivo.
- Adepto e Illuminato: dodici mesi avanti, "Trova il giorno insieme".
- Con gli Eos: un mese avanti in più oppure una proposta insieme.
- I numeri dei limiti e degli Eos li decide Code dentro la matrice dei limiti
  in vigore; li scrive nel rapporto. Le righe nuove entrano in PlanCatalog e
  nella descrizione dei piani. Ogni voce chiusa è Premium bloccata col
  lucchetto e l'invito, mai un vicolo cieco. Se il listino del server deve
  cambiare (functions/src/borsellino.ts), il lavoro sul server si scrive e
  non si pubblica (R3).

======================================================================
FV.13 LA PORTA
======================================================================
Fonte: il fondatore, 15 ottobre 2026: "In aggiunta. Iniziamo con il
calendario lunare"; P3.
- Il Calendario Lunare esce dal Coming soon: in art_catalog.dart diventa
  ArtState.attiva e ArtPhase.mvp. Il titolo resta "Calendario Lunare
  Personale". Il testo della scheda si riscrive perché dica il vero di ciò
  che la funzione fa oggi.
- La porta sta nel dominio di Medora, nella sezione Lunologia; resta anche
  nella riga della home dove già sta (P3), con lo sfondo Calendario-Lunare.

======================================================================
FV.14 LA CONSEGNA
======================================================================
Fonte: regole fisse R3, R6, R12.
- Manifesto, guardia del manifesto, rapporto, STATO_VIVO e registro delle
  guardie aggiornati. Anteprime prima e dopo a 360 per 797, densità 3, in
  docs/preview/FV/, guardate prima di chiuderle: il mese di trenta lune,
  "Trova il giorno" con gli aloni, un foglio del giorno, i giorni tuoi, la
  card.
- In locale girano solo le prove della voce e le guardie della zona
  toccata; la suite intera la fa il cancello di GitHub a ogni push, come
  vuole la regola di CLAUDE.md del 14 ottobre 2026. L'ordine si consegna
  solo col verde di GitHub sul commit consegnato. Nessun rosso si consegna.
- Nessuna build. Le voci che si vedono solo sul telefono restano APERTE IN
  ATTESA DI VERIFICA: il fondatore ordina la build quando vuole guardarle.

FORMATO DEL RAPPORTO
Prime righe: le premesse cadute, con il comando che le ha fatte cadere. Poi
voce per voce DOMANDA, PROVA, MISURA. Poi le scelte di Code con la ragione:
la lunazione e le trenta immagini della NASA con i loro indirizzi, lo
scarto di fase misurato, la definizione della Luna fuori corso e lo scarto
in minuti contro la fonte esterna, i confini delle costellazioni di Maria
Thun con le fonti, il corpus delle regole per attività con le fonti, l'ora
del promemoria, la tabella dei piani. Poi i comandi per pubblicare il lavoro
sul server, se ce n'è. In fondo le migliorie e gli effetti wow proposti,
senza costruirli.
