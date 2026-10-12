# RAPPORTO DELL'ORDINE FL, LO SFONDO DEL TAVOLO E LA STESA SUL PIANO

12 ottobre 2026. Testo: `docs/ordini/ORDINE_FL_TESTO.md`, in due pezzi. Manifesto: `docs/ordini/ORDINE_FL_MANIFESTO.md`, 15 voci: le dieci dell'ordine e le cinque richieste che il fondatore ha scritto in chat guardando le anteprime mentre lavoravo (FL.11-FL.15). Tutte e quindici chiuse. Le voci a video sono state guardate nelle anteprime del motore delle prove, a 1080 per 2391, non sul telefono: la build la ordina il fondatore.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| FL.01 lo sfondo nuovo con Medora dietro il tavolo | `test/il_tavolo_di_medora_test.dart` |
| FL.02 l'ordine dall'alto | `test/il_tavolo_di_medora_test.dart` |
| FL.03 le carte nella prospettiva del piano | `docs/preview/FL/fl_croce_le_carte_coperte.png` |
| FL.04 la chiave grande come le altre, con la luce | `test/la_chiave_e_il_consiglio_si_vedono_test.dart` |
| FL.05 si girano una alla volta, si alzano un secondo dopo | `docs/collaudo/FL/fl_la_sequenza_in_cinque_fotogrammi.png` |
| FL.06 il tocco apre il significato generico | `test/la_carta_si_apre_al_tocco_test.dart` |
| FL.07 il responso uguale | `test/stesa_tre_carte_test.dart` |
| FL.08 la cartella nel pubspec | `pubspec.yaml` |
| FL.09 le decisioni di Code | `docs/ordini/RAPPORTO_ORDINE_FL.md` |
| FL.10 nessuna build | `docs/ordini/RAPPORTO_ORDINE_FL.md` |
| FL.11 le carte coperte prima della stesa | `docs/preview/FL/fl_tre_carte_le_carte_coperte.png` |
| FL.12 la testa che sfiora la barra | `test/il_tavolo_di_medora_test.dart` |
| FL.13 il bagliore stretto sui quattro lati | `docs/preview/FL/fl_sequenza_5_in_piedi.png` |
| FL.14 le altre stese e gli altri due mazzi | `docs/preview/FL/fl_tre_mazzi_croce.png` |
| FL.15 il tappetino blu | `assets/img/tavolo/tavolo_medora_v2.webp` |

## COSA VEDE IL FONDATORE APRENDO LA STESA

In cima la scena: lo sfondo col tavolo e Medora dietro, tagliata alla vita, con la testa che sfiora la barra del titolo. Sotto il selettore delle opzioni di stesa, il riquadro delle 78 carte con Mischia, Taglia e Suono, poi il pulsante: tutto come prima. Le carte scelte si posano coperte sul velluto, inclinate come il tavolo, ai posti della stesa (una carta, tre carte o croce). Premuto il pulsante resta la riflessione di Medora; poi le carte si girano una alla volta e un secondo dopo l'ultima si alzano affiancate e piu' grandi sopra il tavolo. La carta chiave e' grande come le altre e ha un orlo di luce d'oro di 14 punti che esce dai quattro lati. Toccando una carta in piedi si apre il suo significato generico. Il responso sotto e' quello di prima. Il mazzo scelto (Rider-Waite, Marsiglia o Thoth) si vede anche sul tavolo.

Le anteprime: `docs/preview/FL/fl_tre_carte_le_carte_coperte.png`, `fl_croce_le_carte_coperte.png`, i cinque fotogrammi `fl_sequenza_*.png`, `fl_tappetino_blu_tre_momenti.png` e le tre strisce `fl_tre_mazzi_una_carta.png`, `fl_tre_mazzi_tre_carte.png`, `fl_tre_mazzi_croce.png`, ognuna coi tre mazzi.

## LE PREMESSE

- **P1, vera.** CosmosBackground e MedoraStage erano lo sfondo e Medora; le righe si erano spostate con l'aggiunta 2 FK.
- **P2, non piu' vera.** Dall'aggiunta 2 FK, voce A10, la schermata leggeva gia' `PostoSulTavolo` (`TavoloDellaStesa.disponi`), ma stendeva le carte in piano, frontali. FL.03 ha messo quei posti nella prospettiva del velluto.
- **P3, vera.** 688 per 1536 contro 1080 per 2392: l'immagine si ingrandisce di 1,57 volte. Si vede nelle anteprime come una lieve morbidezza del velluto e delle stelle, non come pixel. **Proposta di Code (FL.09): rigenerare lo sfondo ad almeno 1080 per 2400, con la stessa inquadratura**, cosi' che il velluto, il bordo ricamato e il medaglione restino dove sono: allora basta sostituire il file, come per il tappetino blu e la geometria del tavolo non cambia. Vale anche per il busto di Medora, 1142 per 977, che a schermo si allarga a circa 864 pixel e regge.
- **P4, vera.** 1,10 e 0,86, tolte (FL.04).

## LE DECISIONI DI CODE (FL.09)

1. **La scena e' alta fino al bordo davanti del tavolo** e il drappo del velluto scende dietro il selettore. Cosi' le carte coperte e il selettore stanno insieme nel primo schermo (FL.11) e a responso pronto la scena cresce quanto serve alla fila in piedi e alle sue scritte.
2. **I nomi delle carte prima del responso sono tolti.** Con le carte coperte sul tavolo, il nome scritto sotto avrebbe rivelato la carta prima della sequenza.
3. **La fila in piedi e' una fila anche per la croce.** L'ordine dice "una affiancata all'altra"; la croce resta croce sul tavolo e in piedi diventa una fila di quattro nell'ordine di lettura. Le scritte della fila si allargano al piu' fino allo spazio fra due carte (8 punti): "IL CONSULTANTE" scende di corpo invece di coprire "IL LATO".
4. **La luce della chiave e' fatta di anelli concentrici**, non di un'ombra col blur, che nel motore delle anteprime usciva come una barra dagli spigoli netti. Dopo due giri col fondatore e' un orlo di 14 punti uguale sui quattro lati, appena piu' vivo in basso.
5. **Il tappetino blu e' `tavolo_medora_v2.webp`** e la v1 rossa e' tolta dal binario: resta nella storia del ramo, commit f7447a3. La v2 coincide con la v1 al pixel nella geometria del velluto (misurato sovrapponendo gli angoli del campo e i due bordi alle due immagini), quindi nessuna costante del tavolo e' cambiata.
6. **La schermata ha un mazzo di partenza** (`StesaTreCarteScreen.mazzo`), come aveva gia' la stesa di partenza: le anteprime aprono Marsiglia e Thoth senza la tendina. Un mazzo non scaricato si disegna col Rider-Waite, come dalla tendina.

E una cosa che non ho deciso e dichiaro: `lib/features/tarot/medora_stage.dart` non e' piu' importato da nessun file di `lib` (MedoraStage non e' piu' montato, il busto del Maestro lo nomina solo in un commento); lo usano ancora due prove per `MedoraExpression`. L'ho lasciato: toglierlo vuol dire riscrivere quelle prove e non e' nel perimetro dell'ordine.

## I DIFETTI E IL LORO PADRE (Regola C)

- **Le scritte delle posizioni sotto il titolo**, viste dal fondatore nella prima anteprima: padre **FL.01**, la mia prima scena, alta quanto l'immagine tagliata e non quanto le carte con le loro scritte. Corretto con FL.11.
- **Sul tavolo le carte girate erano sempre Rider-Waite**, anche con Marsiglia scelta: padre **FL.03**, la carta sul tavolo (`_CartaSulTavolo`) disegnava `TarotCardArt` senza il mazzo. Trovato da me controllando la richiesta FL.14, prima che il fondatore lo vedesse. Ora il tavolo riceve la faccia dalla schermata (`FacciaDellaCarta`, che legge il mazzo della stesa) e la guardia lo misura.
- **Le etichette della croce in piedi accavallate**: padre **FL.05**, la fila in piedi, che ereditava la larghezza delle etichette (1,6 volte la carta) pensata dall'aggiunta 2 FK voce A10 per il tavolo in piano, dove i posti stanno a 1,15 larghezze.
- **La luce della chiave che non si vedeva, poi troppo larga**: padre **FL.04**, i miei due primi disegni. Il fondatore li ha guardati tutti e due.
- **La prova del piano che non poteva cadere**: padre **FL.03**, la mia guardia, che confrontava l'omografia con gli angoli del campo presi dal codice. Primo innesto VERDE; cambiata la grandezza misurata, non la soglia: gli angoli si confrontano col bordo ricamato misurato a mano sull'immagine e l'innesto e' rosso.
- **Un innesto che non era un difetto**: mio, nella Regola A della FL.14 (`null ?? f` vale `f`). Rifatto con un difetto vero, rosso. Scritto nel registro della Regola A.
- **La faccia trasparente nel terzo fotogramma della sequenza**: padre **FL.05**, la cattura che non precaricava le immagini. Era la cattura, non l'app: con le immagini precaricate la faccia c'e'.
- **La cattura dei mazzi ferma su Marsiglia**: padre **FL.14**, la mia cattura. Un'immagine letta dal file col tempo finto della prova non finisce mai e resta nella cache. Ora si precarica prima di aprire la schermata.
- **Tre timer appesi in tre prove** alla chiusura della schermata durante la sequenza: padre **FL.05**, `Future.delayed` nella sequenza; ora i timer si cancellano alla chiusura.

## LE GUARDIE

**Regola B**: prima di toccare la scena sono state viste rosse `la_chiave_e_il_consiglio_si_vedono`, `medora_non_resta_sola` e `la_terza_carta_non_apre_una_schermata` (`docs/collaudo/FL/fl_regola_b.txt`); date aggiornate in `docs/guardie.md`.

**Regola A**: `il_tavolo_di_medora` (nuova, cardinale proprio) e' rossa su dodici difetti innestati in quattordici giri, col primo verde e rifatto cambiando la grandezza e il mio innesto sbagliato rifatto (`docs/collaudo/FL/fl_regola_a.txt`). `ordine_fl_guard` (nuova) e' rossa col marcatore delle chiuse alzato e con una voce rinominata. Il registro passa da 749 a 751 guardie.

**Prove riscritte con la lapide**, perche' la scena e' cambiata: `il_ventaglio_vive_subito`, `la_terza_carta_non_apre_una_schermata`, `la_stesa_si_capisce` (P.05), `la_chiave_e_il_consiglio_si_vedono` (BV.04, che pretendeva la chiave piu' grande del venti per cento e ora pretende il contrario, con la luce), `stesa_coreografia` (Medora dietro il tavolo), `stesa_tre_carte_test`.

## LA SUITE

SUITE_FINALE

## LA BUILD

Nessuna build (FL.10). La build e' possibile, la ordina il fondatore. Da guardare sul telefono: la sequenza dopo il pulsante (i tempi sono misurati nel motore delle prove, non sul Realme), la luce della chiave e lo sfondo ingrandito di 1,57 volte (P3).
