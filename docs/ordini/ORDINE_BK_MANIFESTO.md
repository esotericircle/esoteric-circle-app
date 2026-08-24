# ORDINE BK, LA REVISIONE DELL'OROSCOPO

Ordine del fondatore del 24 agosto 2026, dal collaudo dell'Oroscopo. Vale il
mandato esteso di BF. Ramo `claude/esoteric-circle-master-order-e798aj`,
guardia `test/ordine_bk_guard_test.dart`.

## Le parole del fondatore, registrate

Sul nome in home: "la funzionalita' Oroscopo Personalizzato si chiamera' solo
oroscopo cosi' il font sara' piu' grande in home".

Sul difetto: "l'ho appena provato e la pausa con animazione di riflessione NON
C'E'! il risultato dell'oroscopo arriva di botto, il testo compare con effetto
macchina da scrivere."

Sulla riflessione: "dopo il click sul pulsante interroga il cielo, non venisse
fuori istantaneamente il risultato, prima dovrebbero esserci 2 animazioni di
riflessione leggibili di 3 secondi credo in totale, per fare sembrare che sia
una risposta elaborata e impegnativa e non automatica".

Sull'attesa piena una volta al giorno: "riduci il tempo di attesa, ma alla
mezzanotte ripristina il conteggio cosi' la prima volta con l'oroscopo
originale l'utente aspetta di piu', ma le successive consultazioni saranno
esattamente le stesse".

Sulla stabilita' del responso: "controlla che il risultato sia uguale fino a
mezzanotte. mi sembra che era questa la regola".

## Le dieci premesse, tutte verificate vere sulla testa del ramo

Verificate su `9675d016` PRIMA di toccare una riga di codice. Nessuna e' falsa,
quindi l'ordine si esegue per intero.

- **P1 VERA**: `_etichetteBrevi` in `lib/core/arts/arti_preferite.dart` riga 73
  porta UNA sola voce, `'tarot_spread_three': 'Tarocchi'`, e non porta
  `'horoscope'`.
- **P2 VERA**: `lib/features/santuario/widgets/tue_arti_view.dart` riga 113
  prende il titolo da `ArtiPreferiteController.etichettaBreve(id) ?? arte.title`.
- **P3 VERA**: `lib/core/arts/art_catalog.dart` righe 223 e 224, l'arte
  `'horoscope'` ha `title: 'Oroscopo Personalizzato'`.
- **P4 VERA**: la bolla dello scaffale e' `ShelfCard` in
  `lib/features/santuario/santuario_screen.dart`, e il titolo sta in un
  `FittedBox(fit: BoxFit.scaleDown)` con `maxLines: 1` alle righe 1920..1927,
  quindi un titolo lungo viene RIMPICCIOLITO e non troncato.
- **P5 VERA**: in `lib/features/horoscope/oroscopo_screen.dart` righe 127 e 128
  `_interrogato` e `_interrogazione` diventano veri nello STESSO `setState`; la
  riga 325 monta le schede con `if (_interrogato)` e la riga 328 passa
  `scrivendo: !_interrogazione`.
- **P6 VERA**: nel build di `_ResponsoCheSiScrive` la variabile `attiva` vale
  `widget.scrivendo && !widget.giaScritto() && !_completato &&
  !MediaQuery.of(context).disableAnimations`, e alla riga 665 il ciclo dei
  paragrafi ha la condizione `if (!attiva || i <= _inScrittura)`: con `attiva`
  falsa TUTTI i paragrafi entrano in albero, e `TestoCheSiScrive` con
  `attiva: false` porta il moto a `value = 1`, cioe' testo intero e fermo.
- **P7 VERA**: `_durataInterrogazione` riga 117 vale `Duration(seconds: 2)`,
  `_durataScrittura` riga 122 vale `Duration(milliseconds: 2600)`.
- **P8 VERA**: `Horoscope.baseSeed(signIndex, dayOfYear, year, domainIndex)` a
  `lib/core/horoscope/horoscope.dart` riga 136, e
  `TransitiDelGiorno.istanteDi` a `lib/core/astro/transiti_del_giorno.dart`
  riga 39 fissa l'istante a `oraDelloScatto = 12` UTC del giorno civile deciso
  da `ConfineDelGiorno.chiaveDi`.
- **P9 VERA**: `git ls-files assets/audio` elenca `soglia.mp3` e
  `rivelazione.mp3`, insieme a `firma.mp3`, `principio.mp3`, `rifiuto.mp3` e
  `rito_compiuto.mp3`.
- **P10 VERA**: `lib/core/santuario/function_shelf.dart` righe 81 e 82, l'id
  `'horoscope'` ha gia' `title: 'Oroscopo'`. Non e' lo scaffale che BK.01
  corregge e non si tocca.

## Il difetto, in una riga

La pausa esiste nel codice e non e' mai visibile: al tocco `_interrogato`
diventa vero e le schede montano subito, mentre `scrivendo` vale falso per due
secondi, e con `scrivendo` falso il responso si costruisce INTERO. La macchina
da scrivere parte poi, su un testo gia' letto.

## Le voci

- **BK.00** Il manifesto con la guardia. CHIUSA: questo file e `test/ordine_bk_guard_test.dart`.
- **BK.01** Il nome breve in home. CHIUSA: `'horoscope': 'Oroscopo'` aggiunta a `_etichetteBrevi` in `lib/core/arts/arti_preferite.dart`; catalogo e `function_shelf.dart` non toccati. **MISURA a 360 punti logici**, letta dal render object del `FittedBox` della bolla: col nome lungo lo spazio concesso e' 228,00 e quello voluto 286,62, quindi fattore **0,7955** e corpo reso **14,32**; col nome breve il voluto scende a 110,10, quindi fattore **1,0000** e corpo reso **18,00**, cioe' il corpo pieno del token. Il testo reso sale del **25,71 per cento** (rapporto 1,2571) e il titolo sta dentro la bolla (110,10 contro 228,00). Anteprima a 360 guardata: "Oroscopo" si legge allo stesso corpo di "Tarocchi" e "Sinastria VIP". Guardia: `test/il_nome_breve_dell_oroscopo_test.dart`, che misura la CATENA VERA (`etichettaBreve(id) ?? arte.title`) e non un titolo scritto a mano, enumera lo scaffale e pretende il catalogo intatto. **Rosso dimostrato**: tolta la voce dalla mappa e verificata l'assenza PRIMA di leggere l'esito, cadono entrambe le prove (fattore 0,7955 invece di 1,0 e etichette brevi 1 invece di 2). Aggiornato `test/le_arti_preferite_test.dart`, che pretendeva l'Oroscopo senza etichetta breve.
- **BK.02** Il responso non compare al tocco. APERTA.
- **BK.03** I due momenti della riflessione, col cielo vero. APERTA.
- **BK.04** La soglia e la rivelazione. APERTA.
- **BK.05** L'attesa piena una volta al giorno. APERTA.
- **BK.06** Il responso e' lo stesso fino a mezzanotte, e si dimostra. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 7
VOCI_APERTE: 5
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 2
