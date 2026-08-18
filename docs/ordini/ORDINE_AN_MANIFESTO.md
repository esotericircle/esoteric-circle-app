# ORDINE AN. LA BARRA CAMBIA VESTE, NASCE IL CALENDARIO, E GLI EOS SI SPENDONO

Nove voci, da AN.01 ad AN.09. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `69ff2d6` il 18 agosto 2026.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: APERTA, CHIUSA,
FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE. Finche' una riga
e' APERTA la guardia `test/ordine_an_guard_test.dart` resta rossa. Le voci
che si vedono (AN.02, AN.03, AN.05, AN.06, AN.08) a cura fatta e guardia
verde vanno in FERMATA IN ATTESA DI DECISIONE: le chiude il collaudo di
Mauro sulla build di AN.09. Un commit per voce; suite intera UNA volta ad
AN.09.

## Perche' quest'ordine esiste

Il collaudo di Mauro sulla 2181 e le sue decisioni del 18 agosto: il cosmo
va bene; la barra piace ma cambia contenuto (volto e nome a sinistra,
calendario degli eventi al centro, borsellino a destra, via segno e
Ascendente); il tocco al centro apre il Calendario degli Eventi. Il
borsellino e' VIVO, le cinque porte IAM sono aperte e l'arretrato e'
arrivato, quindi entra in scena l'economia: costi in chiaro, gating a due
strade, benvenuto, accredito del giorno e dote di sottoscrizione.

Decisioni di Mauro del 18 agosto: le azioni premiate (login, oracolo,
soffio, mood, meditazione, video) sono ELIMINATE e non si predispone nulla
per loro; il bonus della condivisione resta vivo e l'utente va informato di
quando il premio arriva davvero; la dote in Eos alla sottoscrizione entra
nei piani. Regola chiarita: il saldo Eos non si azzera MAI, a mezzanotte
locale si rinnovano solo i tetti d'uso gratuiti del giorno.

## Le premesse, verificate una per una il 18 agosto 2026

1. **P1 VERA.** La barra e' `lib/features/shell/barra_dell_identita.dart`,
   30 punti chiusa (riga 49) e 66 aperta (riga 53), col componente
   `_SegnoEAscendente` alle righe 214 e 238.
2. **P2 VERA.** `lib/core/sigilli/eventi_del_cielo.dart` (246 righe) porta
   l'elenco completo degli eventi e legge lo stato di OGGI dalle fonti
   uniche; NON esiste nessun calcolo della prossima occorrenza, e la parola
   "prossim" non compare nel file. Le eclissi non ci sono.
3. **P3 VERA.** `lib/core/identity/nome_proprio.dart` esiste.
4. **P4 VERA, misurata con gcloud.** Tutte e cinque le callable
   (muoviglieos, statodelcerchio, consumadelgiorno, scrivilamemoria,
   cancellailcerchio) hanno `allUsers` con `run.invoker`: il borsellino
   server e' vivo.
5. **P5 VERA nella sostanza, con un limite dichiarato.** La cartella
   `claude/Decisioni_Approvate` NON sta nel repository, vive nel Project di
   Mauro e da qui non e' leggibile. I numeri li porta l'ordine stesso e i
   briefing li confermano dove si sovrappongono:
   `docs/02_Briefing_Progetto_Definitivo.md` riga 292 e 490 dice il
   benvenuto di 250 Eos, e la tabella di riga 282 dice carta extra 50,
   stesa completa 250, domanda extra 80, sinastria extra 150. Il 120 della
   stesa a tre carte non sta nei briefing e arriva dall'ordine come
   decisione di Mauro: si applica come tale, dichiarandolo.
6. **P6 VERA.** `lib/core/entitlement/plan_catalog.dart` esiste coi piani;
   dei costi in Eos per arte e della dote per piano non c'e' traccia nel
   client.
7. **P7 VERA.** `functions/src/borsellino.ts` righe 58-60 porta
   invito_con_download 60, social_pubblico 30, condivisione_privata 15, e
   riga 69 `TETTO_CONDIVISIONI_PREMIATE = 3`.
8. **P8 VERA, riverificata.** In
   `lib/core/condivisione/porta_della_condivisione.dart` tutti e tre i
   metodi (`testo` riga 31, `daFile` riga 52, `immagine` riga 74) fanno
   `await SharePlus.instance.share(...)` e poi `return true`, senza mai
   leggere l'esito. E share_plus lo restituisce: nel platform interface
   7.1.0 c'e' `class ShareResult` con `status`, e
   `ShareResultStatus` ha success, dismissed e unavailable.
9. **P9 VERA.** Nessuna attribuzione dell'installazione esiste nel
   progetto: nessun Dynamic Link, nessun Install Referrer, nel codice e nel
   pubspec.

## Le nove voci

- **AN.01** Il motore della prossima data — CHIUSA
  (`lib/core/astro/prossimi_eventi.dart`: la prossima occorrenza di ogni
  evento si trova scandendo i giorni futuri e CHIEDENDO a
  `EventiDelCielo.diOggi`, quindi nessun secondo motore astronomico;
  orizzonte dichiarato di 400 giorni; la data e' l'INIZIO dell'evento, non
  ogni giorno in cui dura, altrimenti un mese di Sole nel tuo segno
  riempirebbe il calendario; gli stati continui, Luna crescente e calante,
  non sono appuntamenti e restano fuori; gli eventi personali si calcolano
  solo con segno o carta, e senza non compaiono. DUE DIFETTI TROVATI
  MISURANDO e curati: i giorni si contavano con Duration e il cambio d'ora
  legale spostava il solstizio di un giorno, ora si contano sul calendario;
  e gli eventi di ATTRAVERSAMENTO (solstizi, equinozi, ritorno solare,
  ritorni diretti) il motore di oggi li segnala a mezzanotte DOPO che
  l'istante e' passato, quindi la data vera e' il giorno prima e si corregge
  in un punto solo. Prove contro fonte terza: prossima Luna piena 27 agosto
  2026 e prossimo solstizio 21 dicembre 2026, piu' la coerenza su 21 eventi
  confrontati col motore di oggi; guardia il_motore_della_prossima_data con
  rosso provato)
- **AN.02** La barra cambia veste — FERMATA IN ATTESA DI DECISIONE
  (a sinistra il volto E il nome proprio dal profilo, che passa dalla
  normalizzazione del dato e senza nome resta il solo volto; al centro il
  prossimo evento col conto alla rovescia in lingua del Cerchio, dal motore
  della voce 01, e a parita' di data vince l'evento personale; a destra il
  borsellino; segno e Ascendente escono e `_SegnoEAscendente` e' stato tolto
  invece che lasciato spento; da aperta il centro mostra i prossimi TRE
  eventi con le date e i tocchi navigano, volto all'account, borsellino al
  borsellino, centro al Calendario; da chiusa il primo tocco apre e basta.
  Tre difetti trovati MISURANDO e GUARDANDO e curati: le tre righe
  traboccavano di 43 punti e ora si adattano, l'altezza aperta e' salita a
  88, e la riga del centro si troncava in "Saturno retrogrado, og..." che e'
  una notizia a meta'. Guardia la_barra_sottile_e_la_casa_unica con nove
  prove e rosso provato; anteprima rigenerata e guardata; chiude il collaudo
  di Mauro sulla 2182)
- **AN.03** La schermata del Calendario degli Eventi — FERMATA IN ATTESA DI DECISIONE
  (`lib/features/calendario/calendario_degli_eventi_screen.dart`, si apre dal
  centro della barra; elenco cronologico a orizzonte dichiarato di 90 giorni
  piu' i grandi appuntamenti personali anche oltre, perche' il ritorno solare
  capita una volta l'anno; gli eventi DI TUTTI e i TUOI si distinguono a
  colpo d'occhio per icona e colore; ogni voce porta nome in lingua, data
  vera, quanto manca e una riga di significato su tradizioni reali, senza
  imperativi, sorvegliato dalla guardia; senza identita' restano gli eventi
  di tutti piu' un invito con un pulsante che porta davvero ai dati di
  nascita, mai un vicolo cieco; nasce anche `LinguaDegliEventi`, la porta
  unica dei nomi e dei significati. UN DIFETTO VERO TROVATO E CURATO: la
  lettura `watch<ZodiacController?>()` chiede a Provider un tipo DIVERSO da
  quello registrato e tornava sempre nulla, quindi gli appuntamenti
  personali non comparivano mai, ne' qui ne' nella barra. Altri difetti
  trovati GUARDANDO l'anteprima: accenti mangiati dalla concatenazione e un
  "oggi" scritto due volte. Guardia il_calendario_degli_eventi con sei prove
  e rosso provato, guardie della lingua verdi, anteprima nuova
  calendario-degli-eventi.png guardata; chiude il collaudo sulla 2182)
- **AN.04** La sincronia dei premi persi parte davvero all'avvio — CHIUSA
  (causa trovata per enumerazione sui tre candidati dell'ordine: non era
  l'ordine di avvio del guardiano ne' un errore inghiottito, era il
  CATENACCIO consumato a vuoto, e la ragione intera nessuno dei tre la
  nominava: il diario si carica da disco in modo asincrono, l'app lancia
  `carica()` dal provider senza attenderlo, e il guardiano gira al primo
  fotogramma utile quando quella lettura e' ancora in volo; la sincronia
  guardava un cammino VUOTO, non trovava premi da riprendere e bruciava il
  suo "una volta per sessione" per tutta la sessione, ed e' il saldo rimasto
  a zero che Mauro ha visto sulla 2181. Cura: il diario dichiara quando e'
  pronto, anche se la lettura fallisce, e la sincronia lo aspetta; guardia
  la_sincronia_parte_da_sola che riproduce l'attimo vero, col caricamento in
  volo, e rosso provato)
- **AN.05** Il listino vivo: costi in chiaro, residui, spesa vera — FERMATA IN ATTESA DI DECISIONE
  (nasce `ListinoDegliEos`, la porta unica dei prezzi coi cinque numeri
  approvati, 50 carta extra, 120 stesa a tre carte come deciso da Mauro il
  18 agosto, 150 sinastria, 80 domanda, 250 stesa completa, ognuno col suo
  tetto giornaliero per piano legato ai budget che il server gia' conosce;
  nasce `SpesaDegliEos`, la porta unica della spesa, che chiede al SERVER e
  applica il saldo che il server risponde, mai un conteggio locale, e non
  procede su nessun esito diverso da riuscito; nasce `CostoInChiaro`, che
  prima di spendere dice il residuo del giorno e, finito il gratuito, il
  costo della prossima, con lo stato onesto quando gli Eos non bastano;
  soglia della conferma dichiarata a 100 Eos. Guardia il_listino_vivo con
  otto prove, fra cui l'enumerazione sui 413 sorgenti che vieta un prezzo
  scritto a mano fuori dal listino, e rosso provato; chiude il collaudo di
  Mauro sulla 2182)
- **AN.06** Il gating onesto a due strade — FERMATA IN ATTESA DI DECISIONE
  (nasce `StradeDelloSblocco`, la porta unica che dice davanti a ogni
  lucchetto quale strada esiste davvero: un extra a consumo mostra il costo
  in Eos E l'abbonamento che lo include, con la strada di oggi per prima;
  cio' che gli Eos non comprano mai, memoria dei Maestri, voce, profondita',
  compatibilita' a tre livelli e le altre sette funzioni di relazione
  continuativa, mostra SOLO l'abbonamento; il Coming soon resta separato dal
  Premium perche' li' non c'e' niente da comprare. Ogni strada porta la sua
  riga e quella degli Eos porta il costo dal listino. Guardia
  il_gating_a_due_strade con quattro prove, fra cui la coerenza fra le due
  regole (niente di quel che gli Eos non comprano ha un prezzo nel listino),
  e rosso provato; chiude il collaudo di Mauro sulla 2182)
- **AN.07** Il benvenuto, l'accredito del giorno e la dote dei piani — APERTA
- **AN.08** La condivisione si paga solo se avviene davvero — APERTA
- **AN.09** Il manifesto, la suite, la build 2182 — APERTA

## I marcatori, contati sulle righe

VOCI_TOTALI: 9
VOCI_APERTE: 3
VOCI_CHIUSE: 2
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 4
