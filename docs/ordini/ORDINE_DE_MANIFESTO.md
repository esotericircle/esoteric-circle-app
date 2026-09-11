# ORDINE DE, IL VIAGGIO DELLO SCIAMANO, SECONDA STESURA

**Sigla:** DE. **Verificata libera**: in `docs/ordini/` esistono i manifesti
DA, DB, DC e DD, e nessun DE. L'ordine resta DE e non si rinomina.

**Data di apertura:** 11 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`, l'unico.
**Regola che governa tutto:** **IL CODICE MUOVE, GLI ASSET VESTONO.**

VOCI_TOTALI: 16
VOCI_APERTE: 16

---

## SEZIONE ZERO, LA RICOGNIZIONE SOTTO LA REGOLA ZERO

*"Il testo di questo ordine non e' una fonte attendibile sullo stato del
codice. Verifica ogni affermazione sul ramo prima di agire e dichiara ogni
differenza."*

Qui sotto c'e' cio' che ho verificato **prima di toccare una riga**, con i
file e i numeri. Dove l'ordine e il ramo dicono due cose diverse, la
differenza e' dichiarata per esteso.

### Che cosa esiste oggi, e dove

**I sei file del Viaggio, in `lib/features/maestri/caligo/viaggio/`:**

| file | righe | che cosa fa |
|---|---:|---|
| `viaggio_dello_sciamano_screen.dart` | 967 | le cinque fasi: soglia, discesa, nebbia, incontro, risalita |
| `la_nebbia_e_l_animale.dart` | 447 | `PittoreDellaNebbia` e `PittoreDellAnimale` |
| `il_tunnel_che_scende.dart` | 283 | `PittoreDelTunnel`, gli anelli della galleria |
| `il_bosco_della_soglia.dart` | 268 | `PittoreDelBosco`, diciotto tronchi e l'apertura |
| `la_girandola_degli_animali.dart` | 134 | i dodici totem che passano in ombra |
| `sfondo_del_mondo_di_sotto.dart` | 61 | lo slot: l'immagine quando c'e', il dipinto quando manca |

**I sei file del nucleo, in `lib/core/viaggio/`:** `diario_dei_viaggi.dart`,
`i_quattro_viaggi.dart`, `l_annuncio_dell_animale.dart`,
`la_domanda_del_viaggio.dart`, `scena_del_viaggio.dart`,
`vocabolario_del_viaggio.dart`.

### LE QUATTRO DOMANDE DELLA VOCE DE.15, rispose con i file e i numeri

#### UNO. La voce DC.08, il nutrimento e la nitidezza, e' montata oggi?

**SI', ed e' montata per intero.** Vive in
`lib/core/viaggio/scena_del_viaggio.dart:85`, nella classe
`NitidezzaDellaScena`, e i numeri sono questi:

- **`nitida = 0.66`**, la soglia sotto la quale la scena si dichiara velata;
- **`velata = 0.33`**, la soglia sotto la quale si dichiara confusa;
- **`dopoQuantiGiorniSiAllontana = 7`**: fino a sette giorni la nitidezza e'
  piena, cioe' 1.0;
- **`quandoDiventaVago = 28`**: a ventotto giorni la nitidezza e' al minimo;
- **fra i due la curva e' LINEARE**, in `dopoGiorni()`;
- **`quantiGiorniValeUnNutrimento = 7`**: un nutrimento sposta indietro
  l'orologio di una settimana.

**Che cosa succede a chi non scende per tre settimane, cioe' a ventuno
giorni.** Ventuno cade fra sette e ventotto: la frazione percorsa e'
(21 - 7) / (28 - 7) = 14 / 21 = 0,667, quindi la nitidezza vale circa
**0,333**. E' **esattamente sul confine di `velata`**, quindi la riga che si
legge e' quella della scena confusa: *"L'animale e' lontano e la scena resta
confusa. Il tamburo lo richiama."*

**E' gia' cablata nella schermata**, non e' codice orfano:
`viaggio_dello_sciamano_screen.dart` la chiama alla riga 217 (per la
composizione della scena), alla 229 (che la deposita nel Diario), alla 775
(la densita' della nebbia), e alle 911, 917 e 918 mostra la riga sotto la
chiave `viaggio_nitidezza`.

**CONSEGUENZA PER LA VOCE DE.12, e la scrivo prima di scrivere codice: DE.12
NON DUPLICA NIENTE, LA COMPLETA.** Tre dei suoi cinque pezzi ci sono gia'
(la nitidezza come misura, la curva col tempo, la riga come constatazione e
non come rimprovero). **Mancano i due che contano di piu':** l'avviso
**all'apertura** (oggi la riga si legge solo alla risalita, cioe' **dopo**
essere sceso: chi apre la soglia non sa niente) e **la via del ritorno in un
gesto solo** (oggi `quantiGiorniValeUnNutrimento` esiste come numero e
**nessuna schermata offre il gesto che lo spende**).

#### DUE. Le quattro aperture fra cui si sceglie la porta: codice o immagini?

**NE' L'UNO NE' L'ALTRO: NON ESISTONO.** Questa e' la differenza piu' grande
fra il testo dell'ordine e il ramo, e la dichiaro per esteso.

Cercate in `lib/` le quattro parole `tana`, `crepa`, `pozzo` e `tronco`:
**nessuna occorrenza nel Viaggio**. Cercate `varco` e `apertura`: `varco`
esiste, ma e' **un'altra cosa**, cioe' `VarcoNellaNebbia`, il buco che la
mano apre nella nebbia dopo la discesa, e `apertura` compare solo come
l'apertura nella terra dipinta dal bosco, che e' **una sola**
(`PittoreDelBosco.apertoAX = 0.5`, `apertoAY = 0.62`).

**Quello che si sceglie oggi sulla soglia non sono quattro porte, sono TRE
VIE**, e sono le tre dell'enum `ViaDellaDomanda`: **scelta** (una delle sei
domande gia' scritte), **scritta** (la propria), **incontro** (nessuna
domanda, si scende solo per incontrarlo). Sono il **con che cosa** si scende,
non il **da dove**.

**Quindi non ci sono quattro asset mancanti dall'elenco della voce DE.05:**
ce ne sarebbero quattro da inventare insieme alla funzione che li userebbe, e
quella funzione non e' in questo ordine. **Non la costruisco**, e l'ordine non
la chiede: chiede di sapere. Adesso si sa.

#### TRE. L'orizzonte del Mondo di Sotto, e in quale fascia si aprono i varchi

**L'ordine dice "poco meno di meta' altezza". Sul ramo NON E' COSI'.**

Il fondo del Mondo di Sotto e' dipinto da `PittoreDellaNebbia._ilMondoDiSotto`
in `la_nebbia_e_l_animale.dart`, e l'orlo del terreno sta a
**`size.height * 0.62`**, cioe' al **sessantadue per cento dell'altezza
contato dall'alto**: il cielo prende il 62 per cento, la terra il 38.
**E' gia' un orizzonte basso**, e il documento che ne chiedeva uno basso e'
soddisfatto.

**In quale fascia si aprono davvero i varchi, che e' la parte della domanda
che conta.** I varchi non hanno una fascia loro: li apre il dito, e
`_laNebbia` monta un `GestureDetector` con `behavior: HitTestBehavior.opaque`
su tutto il corpo, quindi **un varco si puo' aprire ovunque, orizzonte
compreso**. Il raggio e' `lato * 0.22 * quantoEAperto`, cioe' il ventidue per
cento del **lato lungo**: su una finestra 1080 x 2040 sono circa
**449 pixel di raggio**, quasi novecento di diametro, cioe' **piu' larghi
dello schermo**. Un solo varco copre una fascia altissima, e **tre varchi
bastano** (`_apriIlVarco`: `if (_varchi.length >= 3)`), quindi in pratica la
nebbia si apre su tutta la scena e non su una fascia.

**La differenza conta, e conta al contrario di come l'ordine se l'aspettava:**
non e' l'orizzonte a essere troppo alto, e' **il varco a essere troppo
grande** perche' una fascia voglia dire qualcosa.

#### QUATTRO. Il conteggio delle domande del Viaggio: condiviso o suo?

**E' SUO, ed e' completamente separato.** Sono due contatori che non si
parlano, e li descrivo tutti e due.

**Il contatore del Viaggio** vive in `lib/core/viaggio/diario_dei_viaggi.dart`,
metodo `siPuoScendereOggi({required bool giaRiconosciuto})`. Non e' un tetto:
e' **una discesa per giorno di calendario**, confrontando la data dell'ultimo
viaggio con quella di oggi. Vale **solo finche' l'animale non e' riconosciuto**
(`if (giaRiconosciuto) return true`), quindi dopo la quarta discesa **non c'e'
nessun limite di nessun genere**. L'archivio e' locale, in
`SharedPreferences` sotto la chiave `viaggio.diario`, e **l'orologio e' quello
del telefono**.

**Il contatore dei Maestri** vive in
`lib/core/entitlement/question_allowance.dart`, e' per tier, ed e' elencato in
`lib/core/entitlement/budget_del_giorno.dart` insieme ad altri cinque budget
(approfondimenti, confronti, gettate, stese, sinastrie). **Il giorno glielo
dice il server** (`_giornoDelServer`, stringa opaca), proprio perche' spostare
l'ora del telefono avanti di un giorno rimetteva interi tutti i budget, e la
cosa era stata verificata eseguendo.

**PERCHE' SONO DUE, e la ragione regge.** Misurano due cose diverse: il
Viaggio conta **un rito che deve cadere in quattro giorni diversi perche' lo
dice il metodo di Harner**, i Maestri contano **quante risposte l'abbonamento
paga**. Il primo e' una regola di contenuto e non si compra, il secondo e' un
tetto commerciale e si compra con gli Eos.

**MA LA DOMANDA HA RAGIONE SULLA PARTE CHE SCOTTA**, e lo scrivo perche'
sara' il lavoro della voce DE.14: **dopo la rivelazione** il Viaggio comincia
a fare esattamente cio' che fanno i Maestri, cioe' **rispondere a domande**, e
la' i due contatori misurerebbero la stessa cosa. Quindi il confine e'
questo, e la voce DE.14 lo incide nel codice:

- **le quattro discese del riconoscimento** restano al contatore del Viaggio,
  una al giorno per tutti, **fuori dal tier e fuori dagli Eos**;
- **le domande dopo la rivelazione** entrano nel listino dei budget, cioe' in
  `BudgetDelGiorno`, dove c'e' gia' il posto, la riga del residuo e la porta
  della spesa.

Cosi' i due contatori **non divergono**, perche' non misurano mai la stessa
cosa.

### LE ALTRE DIFFERENZE FRA IL TESTO DELL'ORDINE E IL RAMO

**DE.01, la soglia.** L'ordine dice che la soglia sta in un riquadro, ed e'
vero: `_ilBoscoDellaSoglia` e' un `ClipRRect` con un `AspectRatio(1.15)`
dentro una colonna che scorre. **Lo slot dell'immagine esiste gia'**
(`SfondoDelMondoDiSotto`, che mostra `assets/img/mondo_di_sotto/soglia_bosco_v1.webp`
e ripiega sul bosco dipinto), quindi la voce e' un lavoro di **forma**, non di
aggancio.

**DE.05, i tre asset.** La cartella **`assets/img/mondo_di_sotto/` NON
ESISTE** sul ramo: nessuno dei tre file c'e'. I due slot dichiarati ci sono
davvero (`SfondoDelViaggio.bosco` e `SfondoDelViaggio.fondo`), e l'ordine ha
ragione a dire che il terzo, la parete del tunnel, chiede anche codice: oggi
`PittoreDelTunnel` dipinge gli anelli e **non ha nessun aggancio a una
texture**.

**DE.06, la durata della discesa.** L'ordine dice *"da quaranta a novanta
secondi"*. Sul ramo, `_quantoDura` in `viaggio_dello_sciamano_screen.dart` da'
**45 secondi alla prima discesa e 20 dalla seconda in poi**. Il novanta non
esiste piu'. La voce resta valida (venti e poi otto o dieci), ma il numero di
partenza e' 45, non 90.

**Il difetto di verita' delle sagome, e la sfumatura che l'ordine non ha.**
`PittoreDellAnimale` e' **davvero** una formula: disegna un corpo, quattro
zampe, un collo, una testa con due orecchie e una coda, tutto da un seme.
L'ordine dice che *"l'ombra che segui non e' l'animale che poi ti tocca"*:
**il seme pero' e' `a.name.hashCode`**, cioe' il nome dell'ombra che si sta
scegliendo, quindi la corrispondenza fra ombra e animale **c'e'**. Quello che
non c'e' e' la **somiglianza**: due semi diversi danno due quadrupedi
leggermente diversi, e nessuno dei dodici e' quel quadrupede. **La conclusione
dell'ordine resta giusta, la causa e' un'altra**: non e' che l'ombra sia
scollegata, e' che **l'ombra non e' un ritratto**, e per quattro dei dodici
(aquila, corvo, falco, gufo, e in un altro modo il serpente) e' **una specie
sbagliata**.

**Il corpo dei dodici.** `assets/img/animali/` ha dodici WebP con alpha vero,
piu' dodici miniature in `assets/img_thumb/animali/`. Le misure sono queste,
lette dai file:

| animale | larghezza x altezza |
|---|---|
| aquila | 688 x 807 |
| cavallo | 878 x 844 |
| cervo | 765 x 933 |
| corvo | 847 x 704 |
| falco | 805 x 749 |
| gufo | 537 x 865 |
| lince | 689 x 875 |
| lupo | 898 x 760 |
| orso | 900 x 736 |
| serpente | 808 x 772 |
| tartaruga | 936 x 688 |
| volpe | 894 x 575 |

**L'ordine dice "attorno a 900 per 760", ed e' la misura del lupo.** Le altre
undici vanno da 537 a 936 di larghezza e da 575 a 933 di altezza: **non sono
tutte della stessa forma**, e la lente dovra' misurarsi sulla forma di
ognuna, non su una misura sola.

**E l'ordine ha ragione sull'originale piu' grande: non c'e'.**
`output/animali/` esiste soltanto nel checkout principale, fuori da questo
albero e fuori da Git, e i PNG la' dentro sono **alle stesse identiche
misure**. La pipeline che li ha fatti e' `animali.py`, sempre fuori dal
repository, e passa da Vertex AI col modello `gemini-3-pro-image` sul progetto
`esoteric-circle`.

**La porta unica della condivisione esiste** ed e'
`lib/core/condivisione/porta_della_condivisione.dart`. La prova che enumera
i chiamanti **non si chiama come dice il commento dentro quel file**: il
commento nomina `test/una_sola_porta_per_condividere_test.dart`, che **non
esiste**. Le prove vere sono quattro, e la piu' vicina a quel mestiere e'
`test/i_tre_pulsanti_condividono_davvero_test.dart`. **Chi cita un file cita
qualcosa che si puo' aprire**, quindi quel commento va corretto in questo
ordine. La voce DE.08 passera' comunque dalla porta, senza scriverne
un'altra.

**La chiave della demo esiste ed e' una sola:** `AppFlags.isDemo` in
`lib/core/config/app_flags.dart`, oggi `true`, letta come **valore di
partenza di un parametro** in sei punti (per esempio
`ArtCatalog...({bool demo = AppFlags.isDemo})`). E' gia' la forma che la voce
DE.14 pretende: **un codice solo, due configurazioni**.

---

## LE SEDICI VOCI

*(Ogni voce si chiude qui sotto con cio' che e' stato fatto, cio' che e' stato
misurato e cio' che si e' visto sul telefono.)*
