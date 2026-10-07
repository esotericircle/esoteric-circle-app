# La giornata d'uso tipo, misurata il 7 ottobre 2026

Domanda del fondatore, ordine FE, punto 4: *"in una giornata d'uso tipo di un
utente, quante chiamate al modello partono davvero, e quante di quelle
avrebbero potuto essere servite senza chiamarlo"*. Solo misura: niente e'
stato costruito ne' curato.

## Come

Sul Realme 767f596c con la build 2301 in produzione (account di collaudo,
piano Illuminato), un'azione alla volta con almeno un minuto fra l'una e
l'altra; ogni ora e' in `ore.txt` (UTC). Le chiamate al modello sono quelle
che Cloud Monitoring conta su `firebasevertexai.googleapis.com`, il servizio
da cui l'app chiama Gemini (i banchi chiamano Vertex direttamente e non
entrano), minuto per minuto: `monitoring.txt`, letto con
`tool/le_chiamate_dell_app.py 2026-10-07T15:04:00Z 2026-10-07T15:36:00Z`.

La giornata tipo, dichiarata prima di misurare: aprire l'app, i Doni del
Giorno, tre domande diverse a un Maestro, un "Vai più a fondo", la stessa
domanda ripetuta nello stesso giorno, una stesa di tarocchi, una gettata di
rune. La Runa del Tramonto si apre alle 18:30 e alle 17:08 non si poteva
aprire (`04_tramonto.png`); il Diario non e' entrato (la navigazione ha
aperto la Sinastria VIP, senza sceglierne una).

## Il numero

**7 chiamate al modello**, tutte con risposta 200.

| Azione (ora UTC) | Chiamate | Da dove viene il testo |
|---|---|---|
| Apertura dell'app (15:05) | 0 | |
| Arcano dell'Alba, carta girata (15:09) | 0 | letture scritte a mano (`lib/core/rituals/arcano_dell_alba/responso_dell_alba.dart:16`) |
| Soffio del Destino (15:11) | 0 | transiti veri e varianti scritte (`lib/core/rituals/risposta_del_dono.dart:24`) |
| Domanda 1 a Medora (15:12) | 5 in tutto per le tre domande: due ne fanno 2, una 1 | il modello; la seconda chiamata e' la correzione di una rete del turno |
| Domanda 2 (15:14) | | |
| Domanda 3 (15:17) | | |
| Vai piu' a fondo (15:19) | 0 | il seguito era gia' scritto nello stesso turno (ordine EX voce 04) |
| La domanda 1 ripetuta (15:20) | 0 | la lettura gia' data oggi, dalla conversazione (`lib/core/chat/la_lettura_del_giorno.dart`), domanda non consumata |
| Stesa di tarocchi, "Leggi le carte" (15:25) | 2 | il modello |
| Gettata di rune, tre Norne (15:28) | 0 | corpus scritto (`lib/features/maestri/caligo/rune/rune_draw_screen.dart:353`) |

La ripartizione delle 7 chiamate fra le azioni viene dagli orari: Monitoring
le conta a minuti, e una risposta con la sua correzione puo' cadere a cavallo
di due minuti. Il totale e' contato, non ricostruito.

## Quante avrebbero potuto essere servite senza chiamarlo

**Nessuna delle 7 con una cache o col database.** Ogni chiamata parte da un
testo che e' solo di questa persona: la sua domanda a Medora, o le sue tre
carte con la sua stesa. Una cache le servirebbe solo a chi scrive la stessa
domanda o tira le stesse carte, e la ripetizione nello stesso giorno, che e'
il caso in cui succede, e' gia' servita senza modello (la riga delle 15:20).

Delle 7, **2 o 3 sono seconde chiamate**: la correzione di una risposta che
una rete del turno ha scartato. Non le toglie un gateway: le toglie una prima
risposta che non va corretta.

Le azioni che gia' oggi non chiamano il modello sono **6 su 10**
(l'apertura dell'app, i due Doni aperti, il "Vai più a fondo", la domanda
ripetuta, la gettata di rune; le altre 4 sono le tre domande e la stesa): non per un gateway, ma perche' quelle funzioni sono
scritte su corpus, calcolo o conversazione gia' presente.
