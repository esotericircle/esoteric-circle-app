# ESITO dell'ORDINE: IL CERCHIO UNIFICATO E LA VERITA' DEL CIELO

## Dichiarazione, scritta prima di toccare il codice

**Un conteggio, prima di tutto.** L'ordine dice undici voci, e le voci
etichettate sono **quindici**: A1..A4, B1..B5, C1..C4, D1..D2. Lo dico subito
perche' alla fine dovro' rendere conto di ognuna, e un numero sbagliato in
apertura diventa una voce dimenticata in chiusura.

### D2 e' gia' chiusa, e la risposta e' che non c'era un difetto

Ho scaricato gli archivi **effettivamente caricati**, non ricostruzioni, dal
`binaryDownloadUri` delle due release.

| | byte reali | MiB, base 1024 | MB, base 1000 |
|---|---|---|---|
| 2107 | 203.739.279 | 194,30 | **203,74** |
| 2108 | 203.767.883 | 194,33 | **203,77** |

**La pagina dei tester dice 203,74 per la 2107, e coincide al centesimo.** Non
sono due file diversi: e' lo stesso file misurato in due unita'. Io ho
dichiarato MiB in base 1024, la pagina mostra MB in base 1000. Nessuno dei due
numeri e' sbagliato, e non ho dichiarato un peso che non fosse quello
consegnato, ma **ho dichiarato l'unita' senza dirlo**, e in un rapporto di
consegna quello e' un difetto mio.

**x86_64 non c'e'.** Le cartelle sotto `lib/` nell'archivio caricato sono due:

- `lib/arm64-v8a` 44,1 MiB
- `lib/armeabi-v7a` 5,2 MiB

La somiglianza fra la differenza di 9,4 MB e il peso che avevo attribuito a
x86_64 e' una **coincidenza**: 203,74 meno 194,30 fa 9,44, ed e' esattamente il
rapporto fra le due unita' su un file di questa taglia, non un'architettura
residua. L'esclusione funziona.

**Una cosa vera l'ho trovata comunque**: `armeabi-v7a` pesa 5,2 MiB ed e' dentro
l'archivio pur avendo compilato con `--target-platform android-arm64`. Arriva
dai plugin, come era successo per x86_64. Si puo' togliere, e lo faro'.

### La stima delle altre quattordici

**Parte 1, e viene prima perche' riguarda cio' che l'app AFFERMA.**

- **A1 piena.** La causa che l'ordine indica l'ho verificata: `MoonPhase.forDate`
  usa il mese sinodico medio, e sei file lo chiamano. Il motore vero,
  `Celestial.moonIllumination`, lavora sull'elongazione. Si toglie il primo, non
  si allinea.
- **A2 piena, ed e' la piu' incerta di tutto l'ordine.** Sono tre difetti in
  uno, e il terzo, il banner che dichiara un esito mai avvenuto, e' il piu'
  grave perche' e' una bugia a schermo. Il rischio non e' scrivere il codice, e'
  che il ricalcolo del cielo sulle coordinate del dispositivo richieda di
  toccare la catena che porta la posizione al motore.
- **A3 piena.** Dove un dato non sara' calcolabile lo dichiarero' invece di
  riempire con una frase generica.
- **A4 piena.** E' la piu' semplice: i valori esistono gia', vanno mostrati.

**Parte 2.**

- **B1 piena, ed e' un errore mio da correggere.** L'ordine precedente diceva
  che "Le tue arti" SOSTITUISCE "Le funzioni del Cerchio". Ho aggiunto la nuova
  e lasciato la vecchia: nel Santuario ci sono `TueArtiView` e
  `_FunctionShelfView` uno sotto l'altro. Verificato sul file.
- **B2, B3, B4 piene.** Le pillole diventano bolle grandi, e il colore del
  proprietario che le pillole avevano gia' giusto si porta sulle bolle.
- **B5 piena.** Era dichiarata risolta e non lo era: la misura guardava il
  riquadro del widget mentre l'avatar sborda con `Clip.none`. E' il difetto per
  cui ho gia' cancellato due test in un ordine precedente, quindi stavolta la
  misura deve guardare l'area DISEGNATA.

**Parte 3.**

- **C1 piena, col rischio piu' alto di tutte.** Quarta stesura, e le prime tre
  sono state bocciate. Stavolta ho un riferimento preciso, e soprattutto so che
  il colore era sbagliato: avevo scritto `Colors.white` nel painter del
  Santuario, quindi se a schermo e' oro **la mano che si vede non e' quella che
  ho corretto**, ed e' la prima cosa che verifichero'.
- **C2 piena.** Senza toccare l'ampiezza, che ho gia' provato e non si puo'
  alzare: durata, opacita' di partenza e sfasamento.
- **C3 piena.** C'e' un timer che nasconde la scelta, e va tolto su tutti e tre
  i Maestri.
- **C4 piena.** "Sei arrivata fin qui, o arrivato" e' un elenco di participi, e
  nell'ordine precedente avevo cercato le barre e non le virgole. Cerchero'
  entrambe le forme.

**Parte 4.**

- **D1 e' quella su cui non posso promettere.** La mia verifica precedente
  poggiava su `acceptedInvitationCount`, comparso dopo la distribuzione: non e'
  una prova, perche' tu la 2108 non la vedi. L'API non espone i tester di una
  release, `v1alpha` risponde 404, e l'endpoint `:distribute` risponde 200 anche
  a un'email malformata. Provero' altre strade, fra cui la CLI ufficiale con
  l'account di servizio, e **dichiarero' consegnato solo se la vedrai
  nell'elenco**. Se non ci riesco lo scrivo invece di girarci intorno.

**Se il tempo finisce**, finiscono per ultime C2 e A4. Mai la Parte 1.

## L'ordine accodato, e una voce che si fonde

A lavoro iniziato e' arrivato l'ORDINE IL CERCHIO E IL PASSPORT, con F1..F4, da
eseguire dopo questo.

**F1 e B5 sono la stessa voce**: la bolla del dominio che cade sopra la figura
del Maestro. F1 la descrive meglio e aggiunge cio' che a B5 mancava, cioe' un
criterio misurabile e la risalita del trio. Quindi la faccio **una volta sola**,
col criterio piu' stringente di F1, e la dichiaro chiusa per entrambi gli
ordini: due correzioni sulla stessa cosa sono esattamente quello che l'ordine
accodato chiede di evitare.

Le voci diventano diciotto: quindici piu' quattro, meno una che si fonde. Una
build sola e una consegna sola, come l'ordine accodato consente.

## Stato voce per voce

### A1, la fase lunare sbagliata di un giorno: CHIUSA

**Le cause erano due, e la seconda non era nell'ordine.**

La prima e' quella indicata: `MoonPhase.forDate` partiva dal mese sinodico
MEDIO, cioe' da una luna nuova di riferimento piu' una durata costante, mentre
`Celestial.moonIllumination` calcolava l'elongazione vera. Ho misurato la
divergenza sull'istante del massimo attorno al 29 luglio 2026: il motore medio
lo mette alle 12:00, quello vero alle 18:00.

**La seconda causa e' quella che si vedeva davvero, ed e' nel NOME.** La soglia
delle fasi principali valeva 0,035 di ciclo, cioe' circa un giorno intero da
ogni lato: misurato, il nome "Luna piena" restava a schermo per
**quarantanove ore**. Ecco perche' l'app dichiarava Luna piena il 30 luglio con
la sizigia il 29: non era l'istante a sbagliare di un giorno, era la finestra
del nome a coprire due giorni. Adesso la finestra e' dodici ore per lato, quindi
copre il giorno della sizigia e non quello dopo.

**La terza porta della nomenclatura.** Cercando ogni punto che dichiara una
fase, come l'ordine chiede, ho trovato in `natal_identity.dart` una SECONDA
funzione di nomi, con soglie sulla frazione illuminata invece che sulla posizione
nel ciclo. Coerente in se', diversa dall'altra: la stessa Luna prendeva due nomi
a seconda di chi la chiedeva. Ora delega a `MoonPhase.nomeItaliano`, che e'
l'unico posto dove un nome di fase nasce.

Il mese medio e' stato **tolto**, non allineato: `MoonPhase` resta come forma
comoda e non calcola piu' niente per conto proprio, che e' la sostituzione
promessa dalla sua stessa vecchia docstring. `julianDay` delega a `Celestial`,
perche' due formule per il giorno giuliano sarebbero due motori di nuovo.

**Tredici test**, cinque visti rossi. Fra questi: le sizigie note di gennaio e
agosto 2024 e di marzo 2025, la durata del nome attorno a ciascuna, il fatto che
ventiquattro ore dopo la sizigia il nome sia cambiato, e un confronto su oltre
cento date fra la nomenclatura del passaporto e quella del Santuario.

Un test verifica anche che il nome nasca dal CICLO e non dalla sola luce: due
istanti con la stessa illuminazione, uno crescente e uno calante, devono avere
nomi diversi. Una soglia sulla sola luce non lo distingue, ed era il difetto
della funzione che ho tolto.
