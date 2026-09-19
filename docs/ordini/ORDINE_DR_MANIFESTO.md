# ORDINE DR, I GEMELLI

**Sigla:** DR. **Data:** 16 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Segue l'ordine DQ, commit
`bc81dcde`, build 2264 consegnata ai fondatori.

**Da dove nasce**: il fondatore ha accoppiato nella Sinastria VIP un
personaggio con se' stesso, tre volte, e la scheda si legge come un guasto.
**La decisione**: quel caso non si vieta, diventa un easter egg che nomina il
gesto e lo esagera.

**Questo ordine non tocca il calcolo astrologico e non tocca nessun numero che
la persona legge.** Cambiano le parole intorno ai numeri.

**NESSUNA BUILD**: quando le voci sono chiuse e la suite e' verde, ci si ferma.

**DIECI VOCI, SOPRA IL TETTO DI SEI DEL COLLAUDO, e lo dichiaro qui.** Le
sei voci da DR.01 a DR.06 erano in corso quando il fondatore ne ha aggiunte
altre quattro. Il tetto del collaudo esiste perche' oltre sei voci nessuno
riesce piu' a tenere in testa che cosa e' stato provato e che cosa no: sopra
quel tetto la prova a video deve scegliere, e la scelta la faccio qui invece
di lasciarla al caso.

**LE SEI PIU' RISCHIOSE, quelle che vanno provate a video per prime**, e il
perche' di ognuna:

1. **DR.07**, la domanda libera: tocca la strada che porta a schermo ogni
   parola del Viaggio, cambia il numero di chiamate al modello e introduce un
   caso in cui l'app **non risponde**. E' la voce che puo' rompere di piu'.
2. **DR.10**, i luoghi: cambia un asset che tutta l'app legge all'avvio, e
   una carta natale sbagliata non si accorge da sola.
3. **DR.02**, il numero dello specchio: se una battuta finisse su una barra
   che non e' la piu' bassa, la scheda direbbe il falso.
4. **DR.05**, i tre guasti di ogni coppia di VIP: toccano il testo di
   **tutte** le coppie, non solo dei gemelli.
5. **DR.09**, il nutrimento dimezzato: un tempo che si accorcia puo' tagliare
   a meta' un suono o un'animazione che partiva con lui.
6. **DR.08**, il tamburo che tace: togliere un suono puo' lasciare un tocco
   senza nessun ritorno.

Restano fuori dalla prova a video, e sono le meno rischiose: DR.01, che e' una
porta di tre righe con la sua prova; DR.03 e DR.04, che sono testi e si
leggono; DR.06, che e' il manifesto e il rapporto.

VOCI_TOTALI: 11
VOCI_CHIUSE: 11
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DR.md`.

---

## LE SEI PREMESSE, RIMISURATE

Regola DR.00.A: ogni numero dell'ordine e' stato rimisurato sul ramo a
`bc81dcde`. Dove il mio numero diverge da quello dell'ordine sta scritto qui
accanto, col metodo di tutti e due.

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| P1, il caso di due VIP identici non e' riconosciuto da nessuna parte | `SynastryReport.fraDueVip` alla riga 291, `ResponsoDellaSinastria.fraDueVip` alla riga 112, nessun confronto | **le due righe coincidono**; cercato in tutto `lib` ogni confronto fra i due lati e ogni parola che somigli al caso: nessuna porta, nessuna guardia, nessun testo. La porta `PortaDellaSinastria` e la schermata `SinastriaVipScreen` passano i due VIP e basta | **VERA** |
| P2, la riga che presenta i due stampa due volte la stessa frase | righe 130 e seguenti | **righe 130-132**, `'Da una parte ' + _ilPersonaggio(primo, seme) + '; dall\\'altra ' + _ilPersonaggio(secondo, seme + 1)`: con lo stesso VIP le due meta' differiscono solo per il seme, che sceglie la giuntura | **VERA** |
| P3, il punto fermo viene tolto anche dove serviva | riga finale di `_ilPersonaggio` | **riga 214**, e c'e' una **seconda strada che l'ordine non nomina**: `_chiusa(frase, conNome)` alla riga 223 toglie il punto allo stesso modo, ed e' quella che si prende quando il personaggio non ha attualita', cioe' **per tutti e cinquanta i VIP del catalogo di oggi**. La cura vale per tutte e due | **VERA, e piu' larga di come e' scritta** |
| P4, l'apertura da' del tu a chi non e' nessuno dei due | riga 223 di `testi_della_sinastria.dart`, "Sei un SEGNO_A" | **riga 223 confermata**. E il difetto e' piu' largo: **non e' solo il "sei un"**, sono anche i "vi" e i "vostra" (*"vi capite prima di parlare"*, *"la fisica e' dalla vostra parte"*), che con due VIP parlano alla coppia come se fosse chi guarda. Le aperture sono 7 relazioni per 3 righe, **21 testi**, e vanno riscritte in terza persona per il caso fra due VIP | **VERA, e piu' larga di come e' scritta** |
| P5, della coppia si mostra solo il secondo | tre posti | **righe 136, 137 e 139**: `_laNota(vip: secondo)`, `laSfida(nome: secondo.name)`, `_luogoDiResidenza(secondo)`. Tre posti, esattamente | **VERA** |
| P6, con due temi identici quasi tutte le misure sono costanti | `altre_affinita.dart`, 106 righe; terraComune 92, ritmo 34 o 52, vitaQuotidiana 70 | **106 righe confermate**. `terraComune` torna 92 sullo stesso elemento (riga 48); `ritmo` torna 34 se la qualita' e' la stessa e vale cardinale, 52 negli altri due casi (riga 75), e la qualita' e' `indice % 3`; `vitaQuotidiana` con la sola Luna congiunta alla Luna fa `50 + 0,45 * 45 = 70,25`, arrotondato **70** (righe 94 e 104). **Aritmetica corretta, nessun guasto** | **VERA** |

**E una misura che l'ordine non chiedeva, ma che cambia una prova**: nel
catalogo ci sono **cinquanta VIP, con cinquanta nomi diversi, cinquanta stem
diversi e cinquanta date di nascita diverse**. Contate leggendo
`vip_catalog.dart` con un'espressione sui campi, non a occhio. Quindi **la
coppia "due personaggi diversi nati lo stesso giorno" oggi non esiste nel
catalogo**: la prova della voce DR.01 la costruisce a mano, con due VIP finti
che condividono la data, e questo va detto perche' una prova che pescasse dal
catalogo sarebbe verde senza aver guardato niente.

---

## LE VOCI

- **DR.01**, i gemelli si riconoscono in un posto solo: una porta sola,
  accanto al calcolo, che confronta l'identita' del personaggio e non la data
  ne' il segno. **CHIUSA**
- **DR.02**, il numero resta quello vero e sono le battute a spiegarlo: il
  cerchio e le sei barre mostrano il calcolo, e i testi spiegano perche' non
  e' cento e perche' la barra piu' bassa e' quella li', guardando la barra
  vera. **CHIUSA**
- **DR.03**, il corpus dei gemelli: testi tutti nuovi, registro esagerato, il
  bersaglio della satira e' sempre la scelta di chi guarda e mai la persona
  reale, e gli scomparsi restano fuori. **CHIUSA**
- **DR.04**, la sorpresa che non si ripete: dodici righe sopra il cerchio,
  dodici titoli e dodici chiuse, un seme che porta dentro quante volte quella
  persona ha gia' fatto i gemelli, e il testo fermo dentro una stessa
  apertura. **CHIUSA**
- **DR.05**, i tre guasti che valgono per ogni coppia di VIP: il punto fermo,
  l'apertura che da' del tu, il primo che sparisce. **CHIUSA**
- **DR.06**, le guardie, il manifesto e il rapporto. **CHIUSA**
- **DR.07**, la domanda libera arriva intera: il tema non apre piu' gli
  strati, il modello si ritenta fino a tre volte col motivo dello scarto, e
  quando non passa niente l'app tace e la discesa non si consuma. **CHIUSA**
- **DR.08**, il tamburo tace durante la discesa e resta la musica: il gesto,
  la riga e la vibrazione restano. **CHIUSA**
- **DR.09**, il nutrimento dimezzato: da quaranta secondi a venti, misurati
  nel codice. **CHIUSA**
- **DR.10**, le frazioni e i paesi piccoli si trovano, e la fonte e'
  OpenStreetMap. **CHIUSA**
- **DR.11**, la scheda del responso non sale piu' sul respiro, e non per un
  rapporto fisso fra due zone. **CHIUSA**

---

## DR.10, LA FONTE CAMBIA, E PERCHE' LA SOGLIA NON ERA LA LEVA

**La prova che decide, rimisurata.** "Borgo di Rivalta" **non esiste in
GeoNames**, a nessuna soglia di abitanti: il dump italiano non contiene quel
nome. Nella provincia di Piacenza c'e' solo *Rivalta Trebbia*, con popolazione
zero. Quindi **nessun abbassamento di soglia lo avrebbe mai trovato**: avevo
cominciato togliendo la soglia alle localita' italiane e portando il mondo da
quindicimila a mille abitanti, il catalogo passava da 40.846 a 141.429 righe e
**il luogo continuava a non esserci**. Quelle modifiche sono state tolte: erano
la leva sbagliata, ed e' la decisione del fondatore ad averlo detto per primo.

| via | righe del catalogo | peso | trova Borgo di Rivalta |
|---|---:|---:|---|
| com'era | 40.846 | 1,7 MB | **no** |
| senza soglia in Italia, mondo sopra mille | 141.429 | 5,9 MB | **no** |
| senza soglia in Italia, mondo sopra cinquecento | 186.848 | 8,1 MB | **no** |
| `allCountries` di GeoNames, tutto | oltre otto milioni | **421.682.512 byte compressi** | si', ma non e' un asset |
| **OpenStreetMap, chiesto** | il catalogo resta com'e' | **zero byte in piu'** | **si'** |

**Il mondo intero si puo' solo chiedere**, e questa e' la misura che lo dice.

**Chi chiama, e perche' non il telefono.** Decisione del fondatore del 16
settembre: chiama **il nostro server**. Verso OpenStreetMap ci si presenta con
una identita' sola invece che con un telefono per persona; i risultati si
mettono da parte **una volta per tutti** invece che una volta per ciascuno; e
il giorno che servisse un fornitore con una chiave, la chiave sta nel server e
non dentro un'app che vive su un repository pubblico.

**Cosa NON cambia, ed e' meta' del lavoro.** Il catalogo offline resta e
risponde per primo, senza rete: chi scrive "Roma" trova Roma **senza far
partire nessuna chiamata**. La domanda esce di casa soltanto quando l'elenco
offline e' vuoto, che e' esattamente lo schermo su cui il fondatore ha letto
"non l'ho trovato". Il fuso orario, che OpenStreetMap non da', lo mette il
luogo in catalogo piu' vicino al punto.

**La catena provata contro il servizio vero**, il 16 settembre 2026, non solo
nelle prove:

| domanda | risposta |
|---|---|
| Borgo di Rivalta | Loc. Borgo di Rivalta, Piacenza, 44,95028 / 9,59096, in 1.218 ms |
| Gazzola | due luoghi, **Piacenza e Treviso**: gli omonimi restano distinti |
| Cefalu' con l'accento | Cefalu', Palermo |
| Ouagadougou | Ouagadougou, Burkina Faso |
| un nome che non esiste | elenco vuoto, nessun errore |

**Il debito dichiarato**: la porta nuova vive nel server, e **il server va
distribuito** con `firebase deploy --only functions`, che e' un comando del
fondatore. Finche' non e' distribuita, l'app si comporta esattamente come
prima: il catalogo offline risponde, e la domanda al mondo torna a mani vuote
senza mostrare nessun errore a nessuno.

---

## DR.11, I NUMERI RIMISURATI COME L'ORDINE CHIEDE

**Quanti punti sono coperti adesso.** L'ordine chiede di rimisurare, e la
misura non e' su un telefono: e' su una **griglia di trentasei geometrie**,
sei altezze per tre coppie di barre di sistema per due scale del testo, tutte
larghe 360 punti come il Realme del collaudo.

| misura | prima della cura | dopo |
|---|---:|---:|
| geometrie in cui la scheda sale sopra la guida | **29 su 36** | **0 su 36** |
| la peggiore, a 640 punti con barre 48/48 e scala 1,3 | **93,7 punti coperti** | **8,0 di margine** |
| sul caso della guardia del 2164, 797 con barre 40/24 e scala 1,0 | **3,9 punti coperti** | **16,0 di margine** |
| margine minimo su tutta la griglia | negativo in 29 casi | **8,0 punti** |

**E perche' la guardia di allora non l'ha ripreso.**
`il_pulsante_del_soffio_non_e_coperto_test.dart` e' ancora verde oggi, e lo
era anche mentre il fondatore guardava il difetto: misura **una geometria
sola**, 360 per 797 con barre 40 e 24 a scala uno, e li' misura il
**pulsante**, non la bolla intera. Il pulsante aveva quattro punti di
margine; la bolla sotto di lui ne era gia' sotto di 3,9. **Quattro punti non
sono un margine, sono un avanzo**, e una prova che guarda un telefono solo
dice com'e' andata li', non se la forma regge.

**Dove il difetto e' irriducibile, e va dichiarato.** Su uno schermo da 640
punti con novantasei punti di barre e il testo alla scala massima, **la guida
non ci sta**: non per colpa della colonna, ma perche' l'anello insegue il
disco, che sta nella scena, e la rincorsa la trascinava sotto il bordo dello
schermo. Li' l'inseguimento adesso si ferma al bordo: **l'anello resta un po'
sopra il centro del disco invece che dentro, e la bolla resta tutta leggibile
e premibile.** E' l'unico scambio possibile fra le due cose. Sulle altre
trentacinque geometrie quel limite non tocca niente.

---

## LE DECISIONI DI FORMA, PRESE DA ME

- **Nel codice i gemelli si chiamano LO SPECCHIO**, e la parola *gemello*
  resta dov'era. Nel progetto `GemelloAstrale` esiste gia' e vuol dire
  tutt'altro: e' il VIP col cielo piu' vicino al tuo, ordine BO voce 10.
  Chiamare *gemelli* anche questo caso metterebbe due significati sulla stessa
  parola dentro la stessa cartella, che e' la famiglia di difetti delle due
  porte. Nei testi che la persona legge e nei documenti la parola *gemelli*
  resta quella del fondatore.
- **L'identita' del personaggio e' lo `stem`**, cioe' il nome del file del
  ritratto, che il catalogo porta gia' e che e' unico per tutti e cinquanta.
  Quando lo stem manca si ricade sul nome. Non la data, non il segno: due VIP
  diversi possono condividere la data, e quella e' una coincidenza.


---

## LE MISURE DELLE QUATTRO VOCI NUOVE

Regola di verifica: rimisurato tutto sul ramo a `bc81dcde`.

### DR.07, la domanda libera

| cosa dice l'ordine | la mia misura | esito |
|---|---|---|
| `il_tema_della_domanda_libera.dart`, trecento righe | **300 righe esatte** | **vera** |
| la parola *quando* vale 3 punti sul tema attesa | **vera**, riga 120: `('quando', 3)` | **vera** |
| il minimo per decidere e' 2 | **vera**, riga 62: `minimoPerDecidere = 2` | **vera** |
| sposare, matrimonio e nozze non esistono in nessuna tabella | **vera**: cercate in tutto `lib`, **zero occorrenze** | **vera** |
| le aperture degli strati vengono dal corpus di casa | **vera, e so da dove**: `LaVoceDelMondoDiSotto.riprendeLaDomanda`, dodici righe che nominano il tema, fra cui *"Quello che ti pesa e' {breve}"* e *"Giu' ti aspettava {breve}"*. Entrano come **prima frase del paragrafo della risposta** quando la risposta del modello **non regge alle guardie**: `il_responso_del_viaggio.dart` riga 298 sostituisce il paragrafo intero col testo del modello, quindi la ripresa per tema si vede **solo quando il modello e' stato scartato** | **vera** |
| il primo e il quarto strato aprivano con le stesse sei parole | **non misurabile da me**: non ho la discesa del fondatore. La strada per cui succede pero' esiste ed e' misurabile, ed e' quella qui sopra | **da riprovare a video** |

**IL CONTO DEI TENTATIVI, e qui il numero dell'ordine non torna.**

L'ordine calcola: *"con due tentativi si arriva al 97,5 per cento, con tre al
99,6"*, partendo dall'84,3 per cento dell'ordine DQ. **L'84,3 e' gia' il
numero DOPO la seconda chiamata**, non prima: nel rapporto DQ sta scritto
*"risposta dal modello: prima 64,2, dopo 84,3 per cento, su 1.100 discese"*.

Rifacendo il conto sui miei numeri misurati: al primo colpo passa il **64,2**
per cento; la seconda chiamata recupera **(84,3 - 64,2) / (100 - 64,2) = il
56,1 per cento** di cio' che restava. Se il terzo tentativo recuperasse con la
stessa efficacia del secondo, si arriverebbe a **93,1 per cento**, non al
99,6: la differenza e' che i tentativi **non sono indipendenti**, perche' chi
sbaglia due volte sullo stesso strato tende a sbagliare per la stessa ragione.

**Le chiamate in piu'**: nell'ordine DQ sono state misurate **1.856 chiamate
della scena su 1.100 discese**, cioe' 68,7 seconde chiamate ogni cento
discese. Il terzo tentativo scatta solo dove dopo la seconda resta ancora una
riga scartata. La stima dell'ordine, diciotto chiamate in piu' ogni cento
discese, e' **plausibile ma non verificata**: il numero vero lo da' la prova a
mille e cento discese col modello vero, e sta nel rapporto.

### DR.08, il tamburo nella discesa

Il suono della discesa e' `IlTamburoDellaDiscesa`, in
`lib/core/sensi/catalogo_suoni.dart` riga 260, e suona
`assets/audio/mondo_di_sotto/tamburo_discesa.mp3`. Lo accende
`PaletteSensoriale` riga 151. Il colpo del dito e' `IlColpoDelTamburo`, riga
236, ed e' un file diverso.

### DR.09, il nutrimento

**Quaranta secondi**, letti dal codice e non a occhio:
`IlTamburoCheNutre.quantoDura = Duration(seconds: 40)`, in
`lib/features/maestri/caligo/viaggio/il_tamburo_che_nutre.dart` riga 77. La
meta' esatta e' **venti secondi**.

### DR.10, i luoghi, e qui l'ordine sbaglia su un fatto che cambia la scelta

| cosa dice l'ordine | la mia misura |
|---|---|
| `luoghi.csv` porta 40.846 luoghi | **vero**: 40.846 righe di luogo, piu' due righe di intestazione. Il file pesa **1.608.472 byte** |
| 8.438 italiane e 32.408 estere | **da rifare col metodo giusto**: il terzo campo e' la sigla della provincia per l'Italia e il **nome della nazione** per l'estero, quindi non e' mai vuoto. Contate per forma della sigla, due lettere maiuscole, le italiane sono **8.438** e le estere **32.408**: i due numeri dell'ordine sono **giusti** |
| Gazzola sta alla riga 4.899 | **vera**: `Gazzola;;PC;44.9601;9.5490;0`, riga 4.899 del file |
| Borgo di Rivalta non c'e' | **vera** |
| il catalogo ha i comuni e non le frazioni | **vera, e so perche'**: il catalogo lo genera `tool/genera_luoghi.py` dai dump GeoNames, e il filtro italiano prende i comuni (`ADM3`) piu' le sole localita' **sopra i tremila abitanti**; il mondo viene da `cities15000`, cioe' sopra i quindicimila abitanti |

**E IL FATTO CHE CAMBIA LA SCELTA, misurato e non dedotto: "Borgo di Rivalta"
NON ESISTE IN GEONAMES.** Ho scaricato il dump `IT.txt` del 16 settembre 2026,
15.937.333 byte, e cercato: **zero righe**. Nella provincia di Piacenza
GeoNames conosce **"Rivalta Trebbia"** (localita', zero abitanti dichiarati) e
**"Castello di Rivalta"** (un castello, non un luogo abitato). Il nome che i
fondatori hanno scritto non c'e' in nessuna forma.

**OpenStreetMap invece lo conosce esattamente**: interrogato Nominatim, una
riga, *"Loc. Borgo di Rivalta, Rivalta Trebbia, Gazzola, Piacenza,
Emilia-Romagna, 29010, Italia"*, a 44,9502818 e 9,5909568, tipo *hamlet*.

**Quindi le due strade dell'ordine non sono due prezzi della stessa cosa**:
allargare il catalogo con la fonte che il progetto gia' usa **non fa passare
la prova che l'ordine chiama decisiva**, perche' quella fonte quel nome non ce
l'ha. La prova *"Borgo di Rivalta si trova"* si supera solo per due strade:
una geocodifica in rete, oppure una fonte dati diversa da GeoNames, cioe'
OpenStreetMap, con la sua licenza ODbL al posto della CC BY di oggi.

**Questa e' una divergenza che cambia la natura del lavoro e non solo la sua
misura**, e la regola DR.00.A dice di fermarsi e riportarla: vedi la voce
DR.10 nel rapporto.
