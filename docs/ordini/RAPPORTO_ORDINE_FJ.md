# RAPPORTO DELL'ORDINE FJ, IL LATO, I MAZZI, LA FONTE DEI SIGNIFICATI

11 ottobre 2026. Testo: `docs/ordini/ORDINE_FJ_TESTO.md` (tre pezzi, l'aggiunta, l'aggiunta 2). Manifesto: `docs/ordini/ORDINE_FJ_MANIFESTO.md`, 43 voci: 29 chiuse, 11 aperte in attesa di verifica, 3 da fare (la suite finale e i due rapporti, che sono questo). Ramo di lavoro `fg-verifica-premesse`, spinto su `claude/esoteric-circle-master-order-e798aj`.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | stato | prova |
|---|---|---|
| FJ.01 il lato arrivato dritto | CHIUSA | `docs/collaudo/FJ/il_lato_e_il_tool.txt` |
| FJ.02 il tool non si ferma | CHIUSA | `docs/collaudo/FJ/il_lato_e_il_tool.txt` |
| FJ.04 la provenienza non si perde | CHIUSA | `docs/collaudo/FJ/fj_parte1_regola_a.txt` |
| FJ.06 FI.17 aggiornata | CHIUSA | `docs/ordini/ORDINE_FI_MANIFESTO.md` |
| FJ.07 le posizioni che mancano a ogni stesa | CHIUSA | `docs/ordini/ORDINE_FI_MANIFESTO.md` |
| FJ.09 il predefinito nel binario, gli altri sul bucket | CHIUSA | `docs/collaudo/FJ/il_bucket_dei_mazzi.txt` |
| FJ.10 le tre misure dei mazzi | CHIUSA | `docs/collaudo/FJ/peso_dei_mazzi.txt` |
| FJ.11 il predefinito gia' nel binario | CHIUSA | `docs/collaudo/FJ/peso_dei_mazzi.txt` |
| FJ.14 la ragione della Parte 3 | CHIUSA | `docs/collaudo/FJ/correzioni_della_fonte.md` |
| FJ.15 la regola fissa | CHIUSA | `docs/collaudo/FJ/correzioni_della_fonte.md` |
| FJ.17 le sei frasi che giudicano | CHIUSA | `docs/collaudo/FJ/correzioni_della_fonte.md` |
| FJ.18 i cinque confini porosi | CHIUSA | `docs/collaudo/FJ/la_fonte_prima_e_dopo.txt` |
| FJ.19 la massima che cade | CHIUSA | `docs/collaudo/FJ/correzioni_della_fonte.md` |
| FJ.20 i due punti vuoti | CHIUSA | `docs/collaudo/FJ/correzioni_della_fonte.md` |
| FJ.21 ritirata | CHIUSA | `docs/ordini/ORDINE_FJ_TESTO.md` |
| FJ.22 solo le carte nominate | CHIUSA | `docs/collaudo/FJ/correzioni_della_fonte.md` |
| FJ.23 il testo della posizione fuori dalla richiesta | CHIUSA | `lib/core/tarot/la_lettura_dal_modello.dart` |
| FJ.24 la condizione per rimisurarla | CHIUSA | `lib/core/tarot/la_lettura_dal_modello.dart` |
| FJ.25 dove sta la regola | CHIUSA | `lib/core/tarot/la_lettura_dal_modello.dart` |
| FJ.30 (A1) i tre errori riscontrati | CHIUSA | `docs/ordini/ORDINE_FJ_TESTO.md` |
| FJ.31 (A2) il commit del lato preso | CHIUSA | `docs/collaudo/FJ/il_lato_e_il_tool.txt` |
| FJ.32 (A3) la fonte e' il Dart, nomi intatti | CHIUSA | `docs/collaudo/FJ/correzioni_della_fonte.md` |
| FJ.33 (A4) la Parte 3 dalle voci dell'ordine | CHIUSA | `docs/collaudo/FJ/correzioni_della_fonte.md` |
| FJ.34 (A5) FJ.21 ritirata | CHIUSA | `docs/ordini/ORDINE_FJ_TESTO.md` |
| FJ.38 (B1) il ferro di cavallo tolto | CHIUSA | `lib/core/tarot/tarot_spread_type.dart` |
| FJ.39 (B2) la ragione per intero | CHIUSA | `lib/core/tarot/tarot_spread_type.dart` |
| FJ.40 (B3) le quattro cose tolte | CHIUSA | `lib/core/tarot/tarot_spread.dart` |
| FJ.41 (B4) niente perso | CHIUSA | `docs/corpus/tarocchi_posizione/lato.md` |
| FJ.42 (B5) il conto nel manifesto | CHIUSA | `docs/ordini/ORDINE_FJ_MANIFESTO.md` |

Aperte in attesa di verifica, con la ragione nel manifesto: FJ.05 (la rotazione del lato non si vede a video finche' la croce a quattro e' chiusa), FJ.12 (i mazzi dal bucket, manca lo sguardo sul telefono), FJ.13 (il blocco per piano dei mazzi), FJ.16 (le collisioni di sinonimi le verifica un lettore), FJ.35 (la grandezza della guardia sulla fonte), e i vincoli FJ.08, FJ.26-FJ.29, FJ.36.

## I PUNTI DEL RAPPORTO

**1. Il file del lato e il tool.** Righe `## ` 78, righe di verso 156, testi pieni 468, righe vuote 0. Il tool non si e' fermato: uscita 0, scheletri da 468 a 936, una posizione con le tre varianti. Le quattro correzioni dell'Architetto ci sono e la parola voce non c'e' piu' (`docs/collaudo/FJ/il_lato_e_il_tool.txt`).

**2. Il comando e la suite.** `python tool/genera_carte_nella_posizione.py`, poi la suite intera in una copia del worktree coi fine riga LF. Sul commit della Parte 1 (`d1b3035b`): +7085 -2. I due rossi erano due guardie di casa su due testi del lato, tutti e due falsi positivi: `il_genere_non_si_indovina` su "purche' la direzione resti incollata agli occhi tuoi" (il soggetto e' la direzione, non chi legge), `nessuna_promessa_di_memoria_integrale` su "Il dolore comincia a sfumare [...] senza cancellarne la memoria" (e' il lutto, non la memoria dell'app). Dichiarati frase per frase con la ragione, come la casa fa coi corpora; la seconda guardia ha avuto per questo la sua mappa. La memoria di casa diceva di far girare le guardie di casa su un corpus nuovo prima della suite: non l'ho fatto, e la suite le ha prese. Sul commit `eb7bb337`, con la Parte 3, la Parte 2 e l'aggiunta 2 dentro: +7089 -10, tutti miei, tutte guardie di casa sul codice nuovo della Parte 2 e una prova vecchia: l'anteprima dei mazzi catturata a densita' 2 invece di 3; il rapporto non ancora registrato; `crypto` da dichiarare nella tavola delle API di iOS; due `catch` muti nel servizio dei mazzi; il dialogo del download senza il suo fondo dichiarato; i megabyte scritti col punto invece che dalla lingua (`NumeroDelCerchio`); due mie prove che elencavano cartelle senza dichiarare quanto guardavano (riscritte senza elencare niente); un "e'" con l'apostrofo in una stringa; e la prova delle stese che ne contava ancora cinque. Padre di tutti e dieci: quest'ordine, Parte 2 e aggiunta 2. Corretti, e rifatte le prove una per una. Il giro finale, sul commit `6ac63e99`: **+7098 -1**, e l'unico rosso e' la guardia dei rapporti consegnati, che chiede di registrare proprio questo rapporto: registrato alla consegna, la guardia torna verde.

**3. La rotazione.** Coi testi veri del lato, nella catena dell'app (conta le uscite, poi la lettura di casa): La Torre dritta e capovolta, tre uscite e tre testi diversi, alla quarta torna il primo (`docs/collaudo/FJ/rotazione_del_lato.txt`). La stesa riaperta nello stesso giorno non conta: la prova FI.18 dall'avvio vero, che riapre anche il responso. **FI.18 resta aperta**, e la ragione e' un fatto del codice: il lato sta solo nella croce a quattro, che resta chiusa (FJ.7), e le tre posizioni della stesa aperta hanno una variante sola. Sul telefono non c'e' oggi nessuna strada che mostri due varianti della stessa posizione.

**4. FI.17 e le posizioni mancanti.** FI.17 aggiornata e lasciata aperta. Dopo l'aggiunta 2: a una carta manca `cartaSola`; la tre carte e' aperta; alla croce a quattro mancano `consultante` ed `esito`; alla Croce Celtica `copre`, `attraversa`, `corona`, `sotto`, `seStesso`, `laCasa`, `speranzeOTimori`, `esito`. Tabella in FJ.07 e in FI.17.

**5. Il paragrafo di provenienza.** `prepara` non lo cancellava: crea solo i file che mancano, non riscrive mai uno che esiste. Ho aggiunto alla guardia del corpus la pretesa che ogni posizione con testi porti la sua provenienza in testa: rossa togliendola dal lato e dal passato (`docs/collaudo/FJ/fj_parte1_regola_a.txt`).

**6. Le tre misure.** Marsiglia 23.486.770 byte (296.058 per carta), Thoth 24.695.910 (309.128 per carta). Il predefinito, il Rider-Waite, **era gia' nel binario** in WebP: 26.292.806 byte piu' 4.535.868 di miniature, 30,8 MB, **sotto i 40**. Riconvertito dai master non cambia: i master di tutti e tre i mazzi sono 853x1280, mentre la carta ingrandita a densita' 3 ne vorrebbe 960x1440, e nessuna sorgente li porta. L'archivio resta 260.267.304 byte (`docs/collaudo/FJ/peso_dei_mazzi.txt`). Sul bucket, con le miniature: Marsiglia 26.863.488 byte, Thoth 27.702.826.

**7. Lettura pubblica, non URL firmati.** I file sono l'arte dei mazzi, fatta per essere mostrata; il bucket `esoteric-circle-assets-cdn` e' gia' pubblico per le altre famiglie; gli URL firmati vorrebbero un servizio su Cloud Run da pubblicare, che Code non pubblica, senza proteggere niente che non sia gia' a schermo. Nessuna credenziale nell'app. **Cloud CDN davanti al bucket non c'e'** (nessun backend bucket nel progetto): l'app legge la `base` dal manifest, quindi il giorno che c'e' cambia il manifest e non l'app. Metterlo e' un bilanciatore con un costo: domanda per il fondatore.

**8. Le modifiche alla fonte dei significati.** Tutte e 26, con carta, campo, frase prima, frase dopo e gemelle, in `docs/collaudo/FJ/correzioni_della_fonte.md`. Le ho fatte in `lib/core/tarot/tarot_card.dart` (aggiunta A3); `docs/corpus/tarocchi.md` e' una copia piu' vecchia e gia' divergente, che nessun tool usa per generare il Dart, e non l'ho toccata. Voci che ho deciso di non toccare: le gemelle (Regina di Coppe, Asso di Coppe, Quattro e Otto di Denari, Otto e Sette di Bastoni, i Due, Sei di Denari, Cinque di Denari, Nove di Spade, Cavaliere di Bastoni, Sette di Spade, Sette di Denari), perche' FJ.22 vieta le carte non nominate e la correzione sta sempre dal lato della carta nominata. Due scelte da dichiarare: il Dieci di Spade dritta, tolta l'alba e la risalita, scendeva a 82 caratteri e la prova di casa del testo ricco ne vuole 120; ho aggiunto il tratto della sua sintesi, "La fine e la resa", non cio' che avevo tolto. E le voci di una frase sola le ho spezzate sul punto, perche' la stessa prova ne vuole due.

**9. FJ.19.** Cade la massima del Tre di Bastoni capovolta, "un ritardo non e' un no". Era proprio il "ritardo" che lo confondeva con l'Otto di Bastoni (FJ.16 punto 4), e l'asse nuovo del Tre e' il ritorno in una forma diversa dall'attesa. La massima del Sette di Denari dice il suo tratto, la valutazione del raccolto, e resta.

**10. I gruppi del lato che la correzione rende riscrivibili.** Le 21 carte-verso la cui fonte e' cambiata: Re di Coppe capovolta, Cavaliere di Denari capovolta, Fante di Denari dritta e capovolta, Tre di Bastoni capovolta, Gli Amanti capovolta, Dieci di Coppe capovolta, Regina di Denari capovolta, Dieci di Spade dritta e capovolta, Fante di Bastoni capovolta, Nove di Bastoni capovolta, La Giustizia capovolta, Dieci di Denari capovolta, Quattro di Bastoni capovolta, Fante di Coppe capovolta, Cinque di Spade capovolta, Due di Denari capovolta, Fante di Spade dritta, Quattro di Denari dritta, Quattro di Coppe dritta, Nove di Denari capovolta. Le cinque rimaste a zero su tre (Re di Coppe, Cavaliere di Denari, Fante di Denari, Gli Amanti, Tre di Bastoni, tutte capovolte) ci sono tutte.

**11. I difetti inseriti apposta nelle guardie nuove.** Tutti caduti al primo giro: due per la provenienza (lato e passato), uno per la rotazione sui testi veri, due per la guardia del manifesto FJ (`docs/collaudo/FJ/fj_parte1_regola_a.txt`), tre per la guardia sulla fonte, quattro per il download dei mazzi (`docs/collaudo/FJ/fj_guardie_nuove_regola_a.txt`). Registro da 740 a 743.

**12. Le guardie viste rosse dopo, e non prima.** Il corpus delle posizioni l'ho visto rosso dopo aver rigenerato il Dart col lato, e dopo aver tolto il ferro di cavallo. Prima di toccare `tarot_card.dart` ho visto rosse `il_genere_non_si_indovina` e `language_rule` (`docs/collaudo/FJ/fj_parte3_regola_b.txt`); il terzo innesto l'ho messo io fuori zona, su `tarot_accordo_rovescio`, che sorveglia le schermate e non i testi della fonte. La tendina dei selettori, la carta ingrandita e la faccia della carta le ho toccate senza vedere rossa prima `stesa_tre_carte_test` e le prove delle anteprime: confessato qui.

**13. Le voci dell'ordine che poggiano su un fatto sbagliato.**
- Le tre fonti assenti dal ramo, riconosciute dall'Architetto (FJ.A1).
- FJ.11: il predefinito non va messo nel binario, **c'e' gia'**, dall'ordine di luglio.
- FJ.10 "alle dimensioni che servono davvero": la dimensione che servirebbe e' piu' grande delle sorgenti.
- FJ.13: il blocco per piano dei due mazzi esiste gia' (matrice FI voce 32, decisione del fondatore); la voce chiedeva di lasciarli aperti. Ho tenuto la decisione del fondatore.
- FJ.16 punto 13: "la tua sensibilita' e' una forza" sta nella Regina di Coppe **dritta**, non capovolta. Punto 7: la frase della Regina di Denari non e' "parola per parola" l'asse del Sei: il concetto e' lo stesso, le parole in comune di fila sono una. Punto 2: "Muovi qualcosa, anche di piccolo" e "Anche un piccolo gesto rimette in moto" non sono la stessa frase, sono la stessa idea.
- FJ.5 e FJ.7: il lato si vede a video solo con la croce a quattro aperta; e la croce, come la carta sola e la Croce Celtica, non si apre con le sole ondate: `costruita` e' falso per tutte, manca la schermata che le stende.
- FJ.7: la stesa nuova che si apre col minor numero di testi e' quella a una carta (`cartaSola`, una ondata), non la croce (due).
- FJ.12 dava per esistente Cloud CDN davanti al bucket: non c'e'.
- Un fatto che l'ordine non vedeva: Marsiglia e Thoth hanno cornici, targhe, nomi e numeri propri (il Bagatto, la Casa di Dio, IIII; l'Aggiustamento, la Lussuria, la Principessa). Scaricare il mazzo non bastava: le targhe le ho misurate sulle cornici con la finestra trasparente, e la carta si disegna col suo mazzo (anteprima `docs/preview/prima_dopo/fj_i_tre_mazzi_dopo.png`).

**14. Il tool sul file spinto dall'Architetto** non si e' fermato, nessuna riga nominata.

**15. Conflitti col commit 65fceaae**: nessuno. Preso con `git merge --ff-only`, un solo file.

**16. La guardia sulla fonte.** Non esisteva: le tre prove che misurano somiglianze (`cento_letture_uguali`, `tarot_interpretazione`, `la_stesa_si_capisce`) confrontano letture intere. L'ho scritta, ma **la soglia che l'aggiunta chiede non esiste**, e lo dicono i numeri (`docs/collaudo/FJ/la_fonte_prima_e_dopo.txt`): con la Jaccard sulle parole le tredici collisioni stavano fra 0 e 0,18 e altre coppie arrivavano a 0,22, mediana 0, quindi nessuna soglia le separa. Ho cambiato la grandezza: le radici rare in comune (in non piu' di sei voci), pesate per rarita'. Prima delle correzioni le coppie nominate sopra 5,0 erano 11 su 28 (7 di FJ.16, 4 di FJ.18), massimo 17,47; **dopo 0 su 28, massimo 4,36**. Ma 9 delle 23 coppie di FJ.16 avevano zero radici rare in comune gia' prima: sono collisioni di sinonimi, e nessuna misura sulle parole le vede. E fra le coppie che nessuno ha nominato, le piu' alte sembrano collisioni vere: L'Imperatrice e la Regina di Denari dritte (abbondanza, nutrire, fiorire, mani, terra, progetti; 21,13) e il Sole e la Regina di Bastoni dritti (calore, luce, scaldare), che e' la coppia che l'Architetto ricordava dalle nove in coda. La guardia regge quindi tre regole misurabili: le 28 coppie note sotto 5,0; nessuna frase di sei parole di fila fra due carte diverse (oggi la piu' lunga e' di cinque, e sono formule); nessuna altra coppia sopra il massimo di oggi, 23,6. La scelta della grandezza definitiva e' dell'Architetto.

**17. Le voci dell'aggiunta che poggiano su un fatto sbagliato.** FJ.A6 chiede una soglia che cada sulle tredici e non sul resto: non esiste per nessuna misura sulle parole (punto 16). FJ.A3 dice che le stringhe della fonte passano per la marca del genere: vero, ma le voci nominate ne portavano una sola, la Giustizia capovolta, che e' caduta con la frase che la portava.

## L'AGGIUNTA 2, IL FERRO DI CAVALLO

**1.** `consiglio`, `ambiente` e `ostacolo` comparivano davvero solo nel ferro di cavallo: nel codice in `tarot_spread_type.dart` (le sue sette posizioni), in `tarot_spread.dart` (l'elenco), nel tool, nel file dati (vuoti) e in tre prove. In piu' c'era una riga che l'aggiunta non nominava: "Ferro di cavallo, 7 carte" nella matrice dei piani (`plan_catalog.dart`), tolta con una lapide. Prima di togliere i tre file della fonte ho contato i testi pieni: 0, 0, 0.

**2.** La suite dopo la rimozione: +7098 -1 sul commit `6ac63e99`, lo stesso giro del punto 2; il rosso e' la registrazione di questo rapporto.

**3.** Il manifesto porta il conto di FJ.B5 in FJ.07 e FJ.42: quattordici posizioni, una piena, tre con la variante 1, dieci vuote; 936 scheletri su 6.552.

**4.** Un fatto sbagliato nell'aggiunta: la tabella di FJ.B5 dice che la carta sola aspetta solo `cartaSola` e la croce a quattro `consultante` ed `esito`. Per i testi e' cosi', ma nessuna delle tre stese si apre con le sole ondate: `costruita` e' falso per tutte e tre, e una stesa si apre solo se la schermata la sa stendere.

**Aggiunta del 11 ottobre 2026, ordine FJ, le voci chiuse alla consegna**: FJ.03, la suite intera, con la prova docs/collaudo/FJ/la_suite_finale.txt (+7098 -1 sul commit 6ac63e99, e il rosso era la registrazione di questo rapporto); FJ.37 e FJ.43, i due rapporti, con la prova docs/ordini/RAPPORTO_ORDINE_FJ.md.

**Aggiunta del 11 ottobre 2026, ordine FK, le voci chiuse dopo la consegna (FK.26)**: FJ.08, FJ.26, FJ.27, FJ.28, FJ.29 e FJ.36, i vincoli chiusi a ordine finito, con la prova docs/ordini/RAPPORTO_ORDINE_FJ.md; FJ.13, il blocco dei mazzi per piano deciso dal fondatore, con la prova docs/ordini/ORDINE_FK_TESTO.md; FJ.35, la grandezza della guardia decisa da Code, con la prova test/la_fonte_dei_significati_non_si_confonde_test.dart. Restano aperte FJ.05, FJ.12 e FJ.16, con la ragione nel manifesto.

**Aggiunta del 11 ottobre 2026, ordine FK, la correzione di un conto (FK.25)**: il punto 10 scrive "Le 21 carte-verso", ma l'elenco dello stesso punto ne nomina 22, e contate su docs/collaudo/FJ/correzioni_della_fonte.md le 26 correzioni toccano 22 carte-verso e 20 carte. Padre: ordine FJ, il mio conto alla consegna.
