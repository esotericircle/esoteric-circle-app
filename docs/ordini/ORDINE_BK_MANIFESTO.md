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
- **BK.02** Il responso non compare al tocco. CHIUSA: i due booleani `_interrogato` e `_interrogazione` sono diventati UNA fase (`_FaseDelConsulto`, quattro valori), e le schede appartengono alla fase che viene DOPO la riflessione: finche' si riflette non sono in albero affatto, non nascoste ne' trasparenti. **MISURA che chiude**: dal tocco fino alla fine della riflessione i caratteri del responso presenti nell'albero dei widget sono **0**, controllati ogni 100 millesimi su tutte e quattro le schede, e 0 anche nel primo fotogramma dopo il tocco. Guardia: `test/la_riflessione_del_cielo_si_vede_test.dart`. **Rosso dimostrato**: reintrodotta la condizione vecchia (schede montate durante la riflessione con `scrivendo` falso) e verificata l'iniezione PRIMA di leggere l'esito, il primo fotogramma dopo il tocco porta **480 caratteri** invece di 0, cioe' il responso intero. La grandezza misurata esclude il sottoalbero della riflessione: il secondo momento nomina lo stesso transito con cui i testi sono scritti, e contarlo avrebbe accusato la cura del difetto che ha tolto.
- **BK.03** I due momenti della riflessione, col cielo vero. CHIUSA: `lib/core/horoscope/riflessione_del_cielo.dart` porta le durate e il fatto da nominare, `lib/features/horoscope/riflessione_del_cielo_view.dart` la corona dei corpi e la riga dei momenti. Primo momento: i corpi VERI del giorno attorno all'emblema, ognuno all'angolo della sua longitudine eclittica presa dalle effemeridi con l'istante fisso di `TransitiDelGiorno`. Secondo momento: la riga di `CorrenteDelCielo.fattoDelGiorno`, la stessa porta della chiamata del mattino, mai scritta a mano; senza cielo vero dichiara "La lettura di oggi parla al tuo segno" e non finge un transito. **MISURE**: riflessione piena **2.800** millesimi (finestra 2.800..3.200), ogni momento **1.400** (soglia 1.200), prima scheda intera a **3.400** dal tocco (tetto 3.500), quarta a **5.500** (tetto 6.000). **COME si rispetta il tetto, scelta dichiarata**: le schede si compongono a CASCATA, 600 millesimi ciascuna con passo 700, e non piu' tutte insieme a 2.600. Due tetti diversi hanno senso solo se le schede non finiscono insieme: chi apre legge la Generale mentre le altre si compongono. **Fatto che corregge una premessa dell'ordine**: i 2.600 millesimi non "si sommavano", le quattro schede scrivevano in PARALLELO e finivano insieme; il tetto era violato lo stesso, perche' con la riflessione davanti la prima scheda sarebbe stata intera a 5.400. **Riduci Movimento**: i due momenti restano, fermi e con la stessa durata; il ritorno anticipato che li saltava e' stato tolto. **Rosso dimostrato**: portato un momento a 1.000 millesimi, cadono la durata intera (2.000 contro 2.800) e la soglia del momento (1.000 contro 1.200).
- **BK.04** La soglia e la rivelazione. CHIUSA: al tocco `PaletteSensoriale.momento` con aptica `tocco` (la vibrazione leggera chiesta) e suono `soglia`; alla comparsa del responso `suona` con `rivelazione`. Nessun asset nuovo, nessun secondo interruttore: tutto passa dalla porta unica dietro `suonoEVibrazione`. **MISURA**: soglia a **0** millesimi dal tocco, rivelazione a **2.800**, distanza 2.800 contro una coda della soglia di 500, quindi nessuna sovrapposizione; ciascuno parte **una volta sola** per consulto, contato fino a otto secondi dopo il gesto. Guardia: `test/la_soglia_e_la_rivelazione_dell_oroscopo_test.dart`. **Rosso dimostrato**: fatta ripartire la soglia al secondo momento, cadono due prove (la soglia risulta emessa 2 volte invece di 1). Aggiunta a `PaletteSensoriale` la spia `@visibleForTesting`, perche' i suoni si potessero CONTARE: finora si verificavano leggendo il sorgente, e una prova strutturale dice se una riga esiste, non se il suono e' partito una volta o due. In prova il canale della piattaforma riceve una risposta vuota, o l'attesa dell'aptica non finisce mai e il suono non parte: e' l'ambiente, non il codice.
- **BK.05** L'attesa piena una volta al giorno. CHIUSA: `MemoriaDellaRiflessione` sul disco, con `ConfineDelGiorno.chiaveDi` come unica autorita' del confine e nessun `DateTime.now()` dentro la schermata; si legge all'apertura e si segna al TOCCO, perche' aprire l'Oroscopo senza interrogarlo non consumi la prima volta del giorno. Finche' il disco non ha risposto vale la riflessione PIENA: nel dubbio si aspetta di piu', mai di meno. **MISURE**: prima interrogazione del giorno **2.800** millesimi, dalla seconda **1.000** (finestra 0,8..1,2), e dopo il confine di nuovo 2.800. I due momenti nella breve sono compressi, non saltati. **Rosso dimostrato**: col disco portato a ieri l'attesa piena torna, col disco a oggi non torna; il confine spostato di un minuto oltre la mezzanotte rende di nuovo piena l'attesa.
- **BK.06** Il responso e' lo stesso fino a mezzanotte, e si dimostra. CHIUSA: la regola esisteva gia' e questa voce la BLOCCA. Guardia: `test/il_responso_e_lo_stesso_fino_a_mezzanotte_test.dart`. **MISURA**: a otto istanti sparsi dentro lo stesso giorno civile (da 00:00 a 23:59) i quattro testi, l'apertura, il numero fortunato e il colore del giorno sono IDENTICI carattere per carattere; attraversando il confine cambiano. **Rosso dimostrato DUE volte, e la prima ha insegnato qualcosa**: l'iniezione chiesta dall'ordine, il seme che guarda l'ora con `DateTime.now().hour`, lasciava le prove VERDI, perche' in prova l'orologio di sistema e' fermo e tutti i responsi cambiavano allo stesso modo. Invece di abbassare la soglia si e' cambiata la grandezza misurata: una prova nuova vieta `DateTime.now()` nei cinque file che compongono il responso, e con quella l'iniezione cade nominando file e riga. La seconda iniezione, l'istante dei transiti che segue l'ora invece dell'ora fissa, fa cadere il confronto carattere per carattere.

## Due cose trovate GUARDANDO, e dichiarate

**Il font dei simboli astronomici non e' un asset di questo repository.**
`lib/design_system/components/natal_wheel.dart` disegna i glifi dei pianeti
col carattere `NotoSansSymbols`, ma in `pubspec.yaml` ci sono due sole
famiglie, Cinzel e EBGaramond, e in `assets/fonts/` due soli file. Sul
telefono quel nome cade sul carattere di sistema, che di solito i simboli li
ha; in prova su niente, e la prima anteprima della corona mostrava dieci
quadratini vuoti. Per questo i corpi della riflessione sono DISCHI dorati con
gerarchia (i due luminari piu' grandi) e non glifi: una scena che si vede solo
dove il sistema e' generoso non e' una scena. **Il debito resta e riguarda la
ruota natale**, che quei glifi li mostra davvero: va deciso se portare il font
fra gli asset o disegnare anche li'. Non e' materia di quest'ordine.

**Un difetto di lingua, trovato perche' l'anteprima si guarda.**
`CorrenteDelCielo.fattoDelGiorno` componeva "Oggi Sole forma un trigono alla
tua Luna di nascita", senza l'articolo: lo stesso errore che `colSuoArticolo`
esiste da tempo per impedire, e che nessuna prova prendeva perche' fino a
quest'ordine quella frase non era mostrata da nessuna parte. Corretta usando
il mattone che c'era gia', e adesso una prova la sorveglia.

MARCATORI, per la guardia:
VOCI_TOTALI: 7
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 7
