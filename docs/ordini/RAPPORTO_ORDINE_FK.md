# RAPPORTO DELL'ORDINE FK, IL DART NON RIGENERATO, LA FONTE DI WAITE, LA FONTE DEI SIGNIFICATI

11 ottobre 2026, sera. Testo: `docs/ordini/ORDINE_FK_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FK_MANIFESTO.md`, 36 voci: 33 chiuse, 3 aperte in attesa di verifica, 0 da fare. Partito da `24cf424`, spinto su `claude/esoteric-circle-master-order-e798aj`.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FK.01 la cartella a 24cf424 | `docs/collaudo/FK/il_punto_di_partenza.txt` |
| FK.02 il Dart rigenerato | `docs/collaudo/FK/il_dart_e_la_fonte.txt` |
| FK.03 la dichiarazione della guardia vera | `test/il_corpus_delle_posizioni_test.dart` |
| FK.04 i 22 gruppi del lato rinfrescati | `docs/collaudo/FK/il_dart_e_la_fonte.txt` |
| FK.05 il colore delle guardie del corpus | `docs/collaudo/FK/fk_regola_b.txt` |
| FK.06 prima i registri | `docs/ordini/RAPPORTO_ORDINE_FK.md` |
| FK.07 la variante 1 non si riscrive | `docs/ordini/RAPPORTO_ORDINE_FK.md` |
| FK.08 dietro col suo file | `lib/core/tarot/tarot_spread.dart` |
| FK.09 la trascrizione basta | `docs/ordini/RAPPORTO_ORDINE_FK.md` |
| FK.10 la grandezza della guardia | `test/la_fonte_dei_significati_non_si_confonde_test.dart` |
| FK.11 la glossa vera della quinta carta | `docs/corpus/tarocchi_posizione/dietro.md` |
| FK.12 il confine fra sotto e dietro | `docs/corpus/tarocchi_posizione/dietro.md` |
| FK.13 le regole di citazione | `docs/corpus/tarocchi_posizione/verifica_waite_1911.md` |
| FK.14 la forma mozza non era nel ramo | `docs/collaudo/FK/i_grep_di_waite.txt` |
| FK.15 "this crowns him" da vedere | `lib/core/tarot/tarot_spread.dart` |
| FK.16 il luogo esatto | `lib/core/tarot/tarot_spread_type.dart` |
| FK.19 le tre voci senza cardine | `docs/collaudo/FK/correzioni_della_fonte.md` |
| FK.20 Tre di Coppe e Temperanza | `docs/collaudo/FK/correzioni_della_fonte.md` |
| FK.21 i due reperti ritirati | `lib/core/tarot/tarot_spread.dart` |
| FK.22 la testata del lato | `docs/corpus/tarocchi_posizione/lato.md` |
| FK.23 la mappa delle gemelle | `docs/corpus/tarocchi_posizione/mappa_delle_gemelle.md` |
| FK.24 il verbale FI | `docs/STATO_VIVO.md` |
| FK.25 ventidue carte-verso | `docs/ordini/ORDINE_FJ_MANIFESTO.md` |
| FK.26 le undici voci di FJ | `docs/ordini/ORDINE_FJ_MANIFESTO.md` |
| FK.27 i controlli di casa prima della suite | `docs/collaudo/FK/le_quattro_frasi_della_fonte.txt` |
| FK.28 le guardie viste rosse prima | `docs/collaudo/FK/fk_regola_b.txt` |
| FK.29 i dieci rossi di FJ attribuiti | `docs/ordini/RAPPORTO_ORDINE_FJ.md` |
| FK.30 la matrice dei mazzi | `lib/core/tarot/i_mazzi_dei_tarocchi.dart` |
| FK.31 i mazzi fuori dall'APK | `lib/core/tarot/i_mazzi_scaricati.dart` |
| FK.32 niente CDN ne' R2 | `lib/core/tarot/i_mazzi_scaricati.dart` |
| FK.33 nessuna build | `docs/ordini/RAPPORTO_ORDINE_FK.md` |
| FK.34 le premesse di FJ attribuite | `docs/ordini/RAPPORTO_ORDINE_FJ.md` |
| FK.36 il rapporto e il manifesto | `docs/ordini/RAPPORTO_ORDINE_FK.md` |

Aperte in attesa di verifica: FK.17 e FK.18, le due collisioni di senso, che verifica un lettore alla prossima prova appaiata; FK.35, il report di fatturazione che non ho aperto.

## LA PARTE 1, IL DART

**Il tool si e' fermato, e il difetto era nella fonte.** Due righe con la parola del rovescio: `docs/corpus/tarocchi_posizione/carta_sola.md` riga 361 (Il Giudizio capovolta, variante 2, "ti si è rovesciato", padre il commit 3aa3ba33) e `docs/corpus/tarocchi_posizione/esito.md` riga 623 (Cinque di Coppe dritta, variante 3, "si è rovesciato", padre il commit 6b313596). L'ordine diceva di dichiararle. Le ho dichiarate **e corrette**, con la parola piu' piccola che tiene il senso ("invertito", "versato"), perche' fermavano tutta la Parte 1 e il fondatore mette Code primo nelle decisioni. Poi i controlli di casa sui testi nuovi, prima della suite (FK.27), hanno preso due participi maschili veri, nessun falso allarme: "ti sei conquistato" nel lato (Nove di Denari capovolta, padre f5d6fced) e "quello che sei stato" nell'esito (Il Giudizio capovolta, padre 6b313596), corretti togliendo il genere. Tutte e quattro con prima e dopo in `docs/collaudo/FK/le_quattro_frasi_della_fonte.txt`, perche' l'Architetto le possa rifare a modo suo.

Dopo: il tool esce con 0, **2.340 testi su 7.020**, uguali uno per uno alla fonte (`docs/collaudo/FK/il_dart_e_la_fonte.txt`, confronto con un'espressione regolare indipendente dal tool); i 22 gruppi vecchi del lato sono quelli che l'Architetto elencava, e non ne resta nessuno. La guardia del corpus era rossa prima (490 scostamenti) e verde dopo.

## LE DECISIONI DI CODE, CON LA RAGIONE

**FK.06, prima i registri.** I registri entrano nella richiesta al modello a ogni lettura della stesa a tre carte, che e' l'unica aperta: 468 testi cambiano subito tutte le letture col modello. Le sette posizioni della Croce Celtica sono 3.276 testi e non cambiano nessuna lettura finche' la Croce non ha la sua schermata (`costruita` e' falso).

**FK.07, la variante 1 non si riscrive.** Togliere lo stampo ha dato 377 su 381 contro 375 su 381: due giudizi, meno di quanto due giri qualsiasi ballano. Riscrivere 468 testi per due giudizi non regge. Le varianti 2 e 3 si scrivono col repertorio contro lo stampo, e la rotazione mostra la variante 1 una volta su tre: lo stampo si diluisce senza riscrivere niente.

**FK.08, `dietro` ha un file proprio, `davanti` no.** La glossa vera della sesta carta, "the influence that is coming into action and will operate in the near future", e' il futuro della stesa a tre carte. Quella della quinta, "the influence that is just passed, or is now passing away", nomina due stati che il passato della stesa a tre carte non regge, e il suo confine con la quarta, "the foundation or basis of the matter, that which has already passed into actuality", e' il piu' costoso della stesa. Costo 468 testi, non 936. Fatto: `SpreadPosition.dietro`, il tool, il file vuoto `dietro.md` con la glossa intera in testa, la Croce Celtica che al quinto posto legge `dietro`, la guardia e la prova delle stese a quindici posizioni.

**FK.09, la trascrizione basta.** Nessuna riga del ramo cita le glosse estese (FK.14), le formule brevi e il luogo si leggono sulla trascrizione, e chi cita dichiara il grado della fonte. Un facsimile servirebbe solo a una citazione letterale pubblicata: oggi non ce n'e' nessuna. Nessuna spesa chiesta al fondatore.

**FK.10, la grandezza della guardia sulla fonte.** La guardia tiene le sue tre regole (radici rare per le coppie note sotto 5,0, nessuna frase di sei parole fra carte diverse, nessuna altra coppia sopra il massimo di oggi) e da quest'ordine anche le nove coppie che una persona ha trovato leggendo (FK.17, FK.18, FK.19): da 28 a 37. Una misura sulle parole non vede le collisioni di sinonimi, e nessuna grandezza diversa le vedrebbe: per quelle decide il lettore, la guardia impedisce soltanto che due voci gia' separate tornino a somigliarsi nelle parole. Un fatto che conferma il quarto numero dell'Architetto: correggendo altre carte la radice "inter" e' diventata piu' rara e il Quattro di Coppe dritto e capovolto e' salito da solo a 7,61; la guardia l'ha preso e l'ho corretto.

**FK.20, il Tre di Coppe e la Temperanza.** Per il Tre di Coppe cede il metro: l'amicizia e' proprio il cardine che lo separa dal Quattro di Bastoni, che e' la festa della soglia e del traguardo; togliendola, le due voci collidono. Per la Temperanza cede la fonte: "guarisce" e' una promessa sulla salute che il metro vieta, e Waite non la dice (la Temperanza e' "Economy, moderation, frugality, management, accommodation"); diventa "La misura che accorda" e "il ritmo giusto".

**FK.24, i verbali.** Restano il verbale del loro ordine e non si riscrivono, ma un numero non si contraddice: "diciassette file di posizione" era vero all'ordine FI e porta adesso la data, con quattordici e quindici fra parentesi.

## LA PARTE 4, LA FONTE DEI SIGNIFICATI

Quattordici correzioni in `lib/core/tarot/tarot_card.dart`, nomi intatti, marche del genere conservate intere, ognuna con prima, dopo e gemelle in `docs/collaudo/FK/correzioni_della_fonte.md`; le coppie prima e dopo in `docs/collaudo/FK/la_fonte_prima_e_dopo.txt`. L'Imperatrice e la Regina di Denari dritte da 21,13 a 3,66 di radici rare in comune; il Sole e la Regina di Bastoni dritti da 12,38 a 4,36; il Quattro capovolto e il Re di Denari capovolto da 7,33 a 0; il Sei e la Regina di Bastoni capovolti, che condividevano "un dubbio su di te", da 3,95 a 0. Le capovolte di FK.17 e FK.18 erano gia' a zero: sono collisioni di senso, e restano aperte finche' un lettore non le riconosce. **Gruppi del corpus che queste correzioni rendono riscrivibili**, in tutte le posizioni gia' scritte: L'Imperatrice capovolta, Regina di Denari dritta, Il Sole dritta, Regina di Bastoni dritta e capovolta, Quattro di Denari dritta e capovolta, Re di Denari capovolta, Nove di Bastoni capovolta, Asso di Coppe capovolta, La Temperanza dritta e capovolta, Quattro di Coppe dritta.

## LE GUARDIE VISTE ROSSE PRIMA, CON LA DATA (FK.28)

Tutte l'11 ottobre 2026, prima di toccare la loro zona (`docs/collaudo/FK/fk_regola_b.txt`): `il_corpus_delle_posizioni` (rossa senza innesto, lo scarto era vero), `la_fonte_dei_significati_non_si_confonde`, `il_genere_non_si_indovina`, `language_rule`, `tarot_interpretazione` (al secondo innesto: il primo era sbagliato mio), `le_stese_del_cerchio` (al secondo innesto: il primo non combaciava), `ordine_fj_guard`. Date aggiornate in `docs/guardie.md` per le cinque che stanno nel registro; `tarot_interpretazione` e `le_stese_del_cerchio` sono prove, non guardie del registro, e la loro prova del rosso sta nello stesso file. Nessuna guardia e' rimasta verde sul difetto giusto.

## LE UNDICI VOCI DI FJ (FK.26)

Chiuse da quest'ordine: FJ.08, FJ.26, FJ.27, FJ.28, FJ.29, FJ.36 (vincoli, l'ordine FJ e' finito), FJ.13 (la matrice, decisa dal fondatore in FK.30), FJ.35 (la grandezza, decisa in FK.10). Aperte: FJ.05 con una **ragione nuova** (la croce a quattro ha adesso nel Dart la fonte di tutte e tre le sue posizioni e le manca solo la schermata); FJ.12 con la stessa ragione, lo sguardo sul telefono, alla build che il fondatore ordinera' coi corpus pieni; FJ.16 con la stessa ragione, i lettori, che ora guardano anche FK.17-FK.19.

## LE PREMESSE DI QUEST'ORDINE CHE NON TORNANO

- FK.01: i commit entrati dopo la consegna di FJ sono **sei**, non due (6b31359, 8611673, f5d6fce, 3aa3ba3, 019612d, 24cf424).
- FK.02: il tool non poteva girare sulla fonte com'era; due righe lo fermavano.
- FK.03: `registriConsegnati = false` non e' una dichiarazione sbagliata: i registri sono 0 su 468.
- FK.08: un file proprio per `dietro` costa 468 testi; 936 era il costo dei due insieme.
- FK.24: a 24cf424 i file nella cartella del corpus erano **diciotto**, non diciassette: quattordici posizioni, registri.md e **tre** reperti (c'e' anche verifica_waite_1911.md). Oggi, con dietro.md, diciannove.
- FK.35: il documento dei costi dice che servirebbe il ruolo di visualizzatore; l'account di Code e' gia' amministratore della fatturazione. Il limite vero e' un altro: l'esportazione dei costi in BigQuery non e' attiva.

## LA SUITE

SUITE_FINALE
