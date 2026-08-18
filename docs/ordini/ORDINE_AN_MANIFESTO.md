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
- **AN.03** La schermata del Calendario degli Eventi — APERTA
- **AN.04** La sincronia dei premi persi parte davvero all'avvio — APERTA
- **AN.05** Il listino vivo: costi in chiaro, residui, spesa vera — APERTA
- **AN.06** Il gating onesto a due strade — APERTA
- **AN.07** Il benvenuto, l'accredito del giorno e la dote dei piani — APERTA
- **AN.08** La condivisione si paga solo se avviene davvero — APERTA
- **AN.09** Il manifesto, la suite, la build 2182 — APERTA

## I marcatori, contati sulle righe

VOCI_TOTALI: 9
VOCI_APERTE: 7
VOCI_CHIUSE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
