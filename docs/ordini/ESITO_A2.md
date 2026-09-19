# ESITO dell'ORDINE A2, un solo sistema di scena

## Dichiarazione, scritta prima di toccare il codice

**No, non chiudo questo ordine per intero.** Arrivo fin qui: l'ampiezza del
movimento coi suoi due criteri numerici, cioe' i 24 px logici e il rapporto tre
a uno, piu' la seconda iscrizione all'accelerometro, che e' un pezzo
circoscritto. L'unificazione dei sette painter in uno NON la faccio.

Il perche', detto con numeri invece che con aggettivi: i sette painter da fondere
vivono in sei file diversi, mentre ventidue file di `lib/features/` li montano.
Ognuna
di quelle ventidue schermate ha una resa da confrontare a video prima e dopo, e
l'ordine giustamente chiede che nessuna perda il proprio aspetto. Non e' il
numero di righe a rendere pesante il lavoro: e' il numero di verifiche visive
che lo chiudono: quelle non si possono comprimere senza consegnare un
rifacimento che nessuno ha guardato.

Preferisco consegnare l'ampiezza misurata e verificata, che e' il difetto che
Mauro sente in mano quando dice "si sposta di due millimetri", piuttosto che un
motore unificato non guardato su ventidue schermate.

## Il push

Riprovato per primo, come chiede la coda. Fallisce ancora: senza gestore
interattivo il remoto risponde `No anonymous write access`, con il gestore
attivo git cerca `/dev/tty`, che qui non esiste. Nove commit fermi in locale.

## Cosa e' stato fatto, coi numeri

### L'ampiezza del movimento

Il numero che l'utente sente in mano, sul piano di riferimento del cielo, cioe'
il campo stellare, che ha profondita' 0,16:

| | prima | adesso |
| --- | --- | --- |
| ampiezza dichiarata (`tiltRange`) | 18 | 150 |
| spostamento massimo da sensore | **2,88 px** | **24,00 px** |
| spostamento massimo dal dito | 19,20 px | 19,20 px |
| rapporto dito su sensore, asse Y | **6,67 a 1** | **0,80 a 1** |
| rapporto dito su sensore, asse X | non applicabile | non applicabile |

Sull'asse orizzontale il dito non tocca il piano del cosmo di fondo, che si
muove in orizzontale solo per inclinazione: il rapporto e' zero, quindi rispetta
il tetto di tre a uno per costruzione. Il valore di 2,16 px citato dall'ordine
nasce dalla profondita' 0,12; nel codice quel piano ha profondita' 0,16, quindi
il valore vero di partenza era 2,88 px. Cambia la seconda cifra, non la
sostanza.

Alzare l'ampiezza da sola avrebbe mandato fuori scena il piano piu' vicino, che
ha profondita' 1,3: con 150 di ampiezza si sarebbe spostato di 195 px. Per
questo la profondita' oltre il piano di riferimento viene compressa a un
quarto: il vicino si sposta ora di **66,75 px**, cioe' resta piu' mobile del
piano di riferimento, che e' il senso della parallasse, senza uscire dalla
quinta. Il piano lontano (0,06) si sposta di 9 px, meno del principale, come
deve essere.

Quattro test in `test/ampiezza_parallasse_test.dart` misurano tutto questo,
compreso il valore vecchio, cosi' non ci si torna per sbaglio.

### La seconda iscrizione all'accelerometro

`birth_sky_hero.dart` teneva un `ParallaxController` privato, cioe' un secondo
lettore dello stesso sensore con filtri e tempi propri: due componenti potevano
raccontare due inclinazioni diverse nello stesso istante. Ora la schermata legge
il controller condiviso dal Provider, come tutte le altre.

Restano nel codice due altre iscrizioni all'accelerometro, in
`rune_draw_screen.dart` e `ritual_view.dart`, ma servono a un'altra cosa: colgono
lo SCUOTIMENTO, non l'inclinazione, con una soglia loro. Fonderle nel
sistema di scena non e' un lavoro di questo ordine e non ha senso farlo qui.
Iscrizioni per la parallasse: da due a **una**.

## Le anteprime, confrontate una per una

Rigenerate tutte. Ne sono cambiate sei. Quattro dipendono dall'ora reale
(`cielo-sopra-di-te`, `cielo-avvio-posizione`, `medora-chat`,
`striscia-del-giorno`) e sono state riportate indietro, come sempre. Le altre
due sono cambiate per il lavoro di ieri sugli Angeli, non per questo ordine:
`carta-natale` e `guide-animale-passport`.

L'ampiezza della parallasse NON cambia le anteprime. Va detto, perche' quella
e' una
verifica che non si puo' fare da qui: le catture sono headless, il sensore e'
fermo, quindi il tilt vale zero e tutti i piani stanno nella posizione di
riposo. Che il movimento adesso si senta e' garantito dalla misura, 24 px contro
2,88, non dalle immagini. La conferma vera la da' il telefono.

### Un difetto trovato guardando, non dai test

Nella carta natale la tessera dei tre Angeli mostra **una sola miniatura invece
di tre**, coi tre nomi scritti di fianco per esteso. Le tre immagini sono
richieste correttamente, una per angelo, quindi il difetto sta nel montaggio o
nella decodifica delle altre due dentro la cattura. Il test conta le arti
distinte nella schermata dedicata, dove sono tre, senza guardare questa
tessera:
per questo non l'ha colto.

Non lo correggo qui, perche' questo ordine ha un oggetto solo e la regola dice
di non passare ad altro. Va messo in coda: e' un difetto mio, introdotto ieri.

## Cosa NON e' stato fatto

L'unificazione dei sette painter in uno. Le classi che disegnano un cielo di
fondo vivo restano **sette**, il criterio ne chiede una. Di conseguenza restano
aperti anche i criteri sulle quattro schermate che devono reagire al sensore e
sui quattro semi diversi: dipendono dal motore unificato.

## Suite, APK, consegna

`flutter test`: **813 test verdi**, erano 809. `flutter analyze`: pulito.

APK unico arm64, **270.966.056 byte, cioe' 258,41 MiB**, integrita' verde su
otto famiglie. Numero di versione 2100, non inferiore al richiesto.

Il peso e' cresciuto di 25 MiB rispetto alla build di ieri, che ne pesava 233,13,
e la ragione non e' il codice di questo ordine: dentro l'archivio ci sono le
librerie native di ML Kit per TUTTE le architetture, cioe'
`libface_detector_v2_jni.so` anche per x86_64 (9,7 MiB) e armeabi-v7a (5,4 MiB)
oltre a quella arm64. `--target-platform android-arm64` filtra le librerie di
Flutter, non quelle dei plugin, quindi il peso oscilla fra una build e l'altra a
seconda di cosa Gradle ha in cache. Va affrontato in un ordine suo.

Va anche detto che il mio controllo di integrita' non ha colto la differenza:
guarda le otto famiglie di asset, non le librerie native ne' le altre cartelle
dichiarate nel pubspec. Fa quello per cui e' nato, cioe' impedire un APK senza
carte, non e' un guardiano del peso.

Consegna riuscita, destinatario unico `cloud@esotericircle.app`, release
**0.1.0 (2100)**:
`https://appdistribution.firebase.google.com/testerapps/1:425821975933:android:1b1ca4db8d4df69b940814/releases/3134ge012tmv8`

## Che cosa resta all'Architetto per il prossimo giro

L'unificazione vera conviene spezzarla per famiglia di schermate, non per
painter: un ordine per il cosmo di fondo (`CosmosBackground` piu' i due accenti
del Santuario), uno per i cieli stellati veri (`BirthSkyHero` e
`_SkyFieldPainter`, che gia' condividono la matematica), uno per i fondali
ornamentali (`RitualBackdrop` e `_PortalSkyPainter`). Tre ordini a oggetto
singolo, ciascuno con le sue anteprime da confrontare, invece di uno che li
tiene insieme tutti.
