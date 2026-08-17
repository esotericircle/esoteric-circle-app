# ORDINE AJ. LA FLUIDITA' TORNA, I BORDI SPARISCONO, E LA HOME SI SISTEMA

Cinque voci, da AJ.01 a AJ.05. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `7a61b0c` il 17 agosto 2026.

## Perche' quest'ordine esiste

Quattro voci di Mauro del 17 agosto, dal telefono vero: aprendo qualunque
funzionalita' tutto diventa a scatti; inclinando il telefono la parallasse
mostra la LINEA marcata del bordo dei piani; lo spazio esagerato fra i tre
Maestri e le arti deve sparire; la sezione diventa "Le arti preferite".

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: CHIUSA, FERMATA SU
PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE, APERTA. Finche' una riga e'
APERTA la guardia `test/ordine_aj_guard_test.dart` resta rossa. Le voci non
si rinumerano e non si accorpano.

## Le premesse, verificate una per una il 17 agosto 2026

1. **P1 VERA, enumerata per intero** (l'elenco coi conti e' nel rapporto
   della voce AJ.01): venti file di lib/features creano MaskFilter o shader
   dentro paint(); i peggiori nel cammino per fotogramma con un repeat()
   vivo sono `ritual_object.dart` (ramo Aura: circa 87 MaskFilter piu' 2
   shader a fotogramma, repeat 6s), `dream_rite_screen.dart` (circa 70
   createShader a fotogramma, repeat 12s), `maestro_reveal_screen.dart` (22
   MaskFilter piu' un Ticker che fa setState a ogni fotogramma),
   `resonance_screen.dart` (6 per fotogramma, repeat 3s per tre istanze,
   senza guardia Riduci Movimento), `meditation_screen.dart` (9 piu' due
   tracciati da 721 punti a fotogramma, repeat 11s senza guardia),
   `sunset_rune_screen.dart` (repeat 3,4s senza guardia),
   `breath_destiny_screen.dart` e `dawn_rite_screen.dart` (repeat 8s e 7s),
   `intertwined_auras`, `nature_emblem`, `sky_thread`, `day_oracle` (repeat
   nel montaggio). Fuori dal fotogramma ma cari: `sky_overview_screen.dart`
   (circa 50 MaskFilter per passata, solo su pan) e `seal_painter.dart`
   (7 per passata, one-shot).
2. **P2 VERA.** I sensori passano da `parallax_controller.dart`;
   `sunset_rune_screen` e `stesa_senses` si iscrivono anche per conto loro.
   La schermata COPERTA da una rotta opaca non viene rasterizzata, ma i suoi
   controller a repeat() continuano a girare e i suoi ascoltatori della
   parallasse continuano a ricostruire: lavoro di build e notifiche vive
   sotto una funzionalita' aperta.
3. **P3 VERA, colpevoli nominati.** Il pumpAndSettle del sentiero non
   converge per DUE animazioni infinite: `CosmosBackground._controller`
   (repeat 30s, sempre montato, ri-armato a ogni build) e
   `_SigilloPulsante._motore` (repeat 3s, uno per ogni riga che pulsa, e le
   righe sono tutte montate perche' la colonna non e' pigra).
4. **P4 VERA, verificata sulla misura.** I piani della cache del cosmo sono
   grandi ESATTAMENTE quanto lo schermo (`_dipingiUnaVolta` usa
   size per densita', senza margine) e la parallasse sposta il piano vicino
   fino a 165 punti (tilt saturo a 1, ampiezza 500, profondita' efficace
   0,331): il bordo entra nell'inquadratura, ed e' la linea di Mauro.
5. **P5 VERA nella sostanza, col numero vero.** Il vuoto reso fra il
   pulsante d'ingresso al dominio e il titolo "Le tue arti", misurato sulla
   schermata montata a 360, e' di 184,0 punti (158,0 dalla riga delle arti
   del Maestro). L'ordine diceva circa 215.
6. **P6 FALSA SU UN NOME, e ci si ferma su quello.** Le arti attive del
   catalogo sono NOVE e otto nomi coincidono con l'elenco; la nona e'
   "Stesa di Tarocchi" (id `tarot_spread_three`), non "Tarocchi". La scelta
   sul nome e' di Mauro: rinominare la voce del catalogo o tenere il nome
   lungo nello scaffale.

## Le cinque voci

- **AJ.01** Gli scatti spariscono: la regola del cielo vale per tutti — FERMATA IN ATTESA DI DECISIONE
  (le cure trasversali sono fatte: la schermata coperta si sospende (cielo
  fermo e niente ascolto della parallasse sotto una rotta, conto dei sospesi
  provato sull'app vera) e i tre repeat scoperti hanno la guardia di Riduci
  Movimento; il pumpAndSettle del sentiero converge sotto quelle guardie.
  RESTANO, dichiarate coi numeri del censimento: le cure per sprite dei
  pittori che sfocano per fotogramma, nell'ordine ritual_object (87 filtri a
  fotogramma, solo onboarding), dream_rite (70 shader), maestro_reveal (22
  piu' il Ticker), meditation e sky_overview. Il metro CPU delle prove vede
  il paint e non il raster, dove le sfocature pesano: 1,4-3,1 millesimi a
  fotogramma misurati sul ritual_object. La chiusura vera e' il telefono di
  Mauro, come la voce prescrive.)
- **AJ.02** La linea ai bordi sparisce — CHIUSA
  (l'ultima parola resta al telefono di Mauro, inclinandolo)
- **AJ.03** Lo spazio esagerato in home sparisce — CHIUSA
- **AJ.04** Le arti preferite, e le altre — FERMATA SU PREMESSA FALSA
  (P6: "Tarocchi" non esiste nel catalogo, esiste "Stesa di Tarocchi".
  ANNOTAZIONE del 17 agosto: Mauro ha deciso, nome breve "Tarocchi" nello
  scaffale e catalogo intatto; il lavoro riparte e SI CHIUDE nell'ordine AK,
  voci 01 e 02. Lo stato di questa riga non cambia e nulla si rinumera.)
- **AJ.05** Il manifesto e il rapporto — CHIUSA

## I marcatori, contati sulle righe

VOCI_TOTALI: 5
VOCI_APERTE: 0
VOCI_CHIUSE: 3
VOCI_FERMATE_SU_PREMESSA_FALSA: 1
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
