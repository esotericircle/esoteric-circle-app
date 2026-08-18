# ORDINE AM. IL COSMO TORNA VIVO, LA CAPSULA SE NE VA, NASCE LA BARRA SOTTILE

Cinque voci, da AM.01 ad AM.05. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `9bf7a72` il 18 agosto 2026.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: APERTA, CHIUSA,
FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE. Finche' una riga
e' APERTA la guardia `test/ordine_am_guard_test.dart` resta rossa. Le voci
che si vedono sul telefono (AM.01, AM.02, AM.04) a cura fatta e guardia
verde vanno in FERMATA IN ATTESA DI DECISIONE: le chiude il collaudo di
Mauro sulla build di AM.05. Un commit per voce; suite intera UNA volta ad
AM.05.

## Perche' quest'ordine esiste

Il collaudo di Mauro sulla 2180, dal telefono vero. Parole sue: il cosmo non
funziona ancora, aprendo una funzionalita' e tornando alla home tutto e' PIU'
RALLENTATO; fin dall'inizio non c'e' piu' la profondita' e il movimento di
prima, sembra che manchi un livello di stelle; la capsula in alto a destra va
tolta immediatamente, e al suo posto nasce una barra sottile persistente con
account, borsellino, segno zodiacale e ascendente, che al tocco scende e
ingrandisce il contenuto. La decisione e' secca: quei quattro contenuti
compaiono SOLO nella barra.

Il borsellino non e' in quest'ordine: la porta IAM delle callable la apre
Mauro dalla console, e la voce AL.05 resta in attesa di quel passo.

## Le premesse, verificate una per una il 18 agosto 2026

1. **P1 VERA.** La capsula e' `lib/features/shell/capsula_dell_identita.dart`,
   montata in `lib/app.dart` riga 341 sopra il Navigator; la moneta sta in
   `assets/brand/moneta_eos.webp` (5.474 byte) e resta buona per la barra.
2. **P2 VERA.** Il cosmo si sospende via RouteObserver (`didPushNext` riga
   132, `didPopNext` riga 145, `osservatoreDelCielo` riga 101) e il limite
   alle sole rotte opache arriva da AL.01 (`b39a40c`); le scorte e i regimi
   dei piani vengono da AJ.02 (`cdfe0c8`).
3. **P3 VERA per definizione.** I due difetti del cosmo sono il collaudo di
   Mauro sulla 2180 installata, non un'ipotesi dell'Architetto: lentezza che
   compare TORNANDO in home da una funzionalita', e profondita' e movimento
   persi fin dall'avvio come se mancasse un livello di stelle.
4. **P4 VERA.** L'Ascendente non si calcola in locale: `natal_identity.dart`
   riga 59 dichiara che cio' che il luogo determina davvero, Ascendente e
   case, qui non si calcola. Arriva dalla callable `natalChart`.
5. **P5 VERA.** Dodici emblemi in `assets/img/zodiac/` e dodici miniature in
   `assets/img_thumb/zodiac/`, dichiarati nel pubspec alle righe 203 e 204.

## Le cinque voci

- **AM.01** La lentezza che si accumula al ritorno in home — APERTA
- **AM.02** La profondita' perduta e il livello che manca — APERTA
- **AM.03** La capsula se ne va, e le testate restano pulite — APERTA
- **AM.04** La barra sottile persistente in alto, casa unica — APERTA
- **AM.05** Il manifesto, la suite, la build 2181 — APERTA

## I marcatori, contati sulle righe

VOCI_TOTALI: 5
VOCI_APERTE: 5
VOCI_CHIUSE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
