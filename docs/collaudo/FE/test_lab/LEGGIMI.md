# Firebase Test Lab, ordine FE voce 21

Notte del 6 ottobre 2026. La prova che gira sul telefono è
`integration_test/il_filo_resta_libero_test.dart`. Misura cinque cose:

- quanto resta fermo il filo principale col calcolo degli eventi in arrivo,
  prima e dopo la porta `IlCieloCheArriva`;
- quanto costa comporre l'istruzione di ogni Maestro;
- una risposta vera per ognuno dei tre Maestri, misurando la pausa più lunga
  del filo principale mentre la risposta arriva;
- l'apertura del LIVE dei tre Maestri.

## FE.21.2, il dispositivo

Il catalogo di Test Lab conta 208 modelli, letto con `gcloud firebase test
android models list` il 6 ottobre 2026. **Il Redmi Note 14 Pro 5G non c'è.**
L'unico Xiaomi è lo **Xiaomi 14 (`houji`)**, fisico, con Android 15 (API 35)
e HyperOS. Android 16, che è il sistema del Redmi che è caduto, nel catalogo
c'è solo su Samsung, Pixel e Nothing. Ho scelto lo Xiaomi perché ha lo stesso
sistema del produttore del telefono che è caduto.

### Giro 1, prova strumentata: non è partita

Matrice `matrix-1rh64u6ryqgzm`, esito *Test timed out* dopo 10 minuti. File in
`giro_1/`. **La prova non è mai partita**, e non è un difetto dell'app.
HyperOS ha rifiutato l'avvio dell'attività dal processo di prova, come si
legge nel registro:

`ActivityTaskManager: Abort background activity starts from 10347`

`FlutterTestRunner: launchActivity failed`

È il divieto di Xiaomi di aprire attività dallo sfondo. Sul telefono vero si
toglie da un'impostazione, che Test Lab non permette di cambiare.

### Giro 2, prova Robo: passato

Matrice `5586416649478358685`, esito *Passed*, file in `giro_2_robo/`. Robo
apre l'app dal launcher, e l'APK costruito con `-Ptarget` ha come ingresso
la prova stessa, quindi le misure finiscono nel registro. Righe vere,
nell'estratto `giro_2_robo/registro_estratto.txt`:

- eventi in arrivo di 400 giorni **sul filo principale: 795 ms**. Così faceva
  la 2298, due volte per ogni istruzione. **Dalla porta, fuori dal filo: il
  filo resta fermo al massimo 13 ms**;
- istruzione con una nascita: Medora 13 ms, Aura 2 ms, Caligo 2 ms;
- risposta vera di Medora: filo fermo al massimo 37 ms, 414 caratteri;
- risposta vera di Aura: 12 ms, 570 caratteri;
- risposta vera di Caligo: 11 ms, 411 caratteri;
- **il LIVE dei tre Maestri non si apre**, con ragione `nonEPerTe`.
  L'account di Test Lab è anonimo e non ha diritto al LIVE
  (`ilDirittoAlLive`). Dargli il diritto vorrebbe dire scrivere a mano i dati
  di produzione, e quello è vietato. Il LIVE dei tre Maestri resta provato
  sul Realme (FE.05).

Lo Xiaomi 14 è un telefono di fascia alta. Il Redmi Note 14 Pro 5G è più
lento, e lì i 2 × 795 ms diventano i secondi che hanno fatto scattare l'ANR.

## FE.21.3, il costo di un giro

Dalla pagina ufficiale dei prezzi
(`firebase.google.com/docs/test-lab/usage-quotas-pricing`, letta il 6 ottobre
2026): **5 dollari l'ora per un dispositivo fisico**, a minuti arrotondati
per eccesso. Si paga solo il tempo della prova, non l'installazione. Il piano
Blaze ha **30 minuti gratuiti al giorno** sui dispositivi fisici.

| Giro | Minuti pagabili | Costo a listino |
|---|---|---|
| 1, strumentata, tempo scaduto | 12 (dalle 00:22:34 alle 00:33:47) | 1,00 dollari |
| 2, Robo | 1 (23 secondi) | 0,08 dollari |

Tredici minuti in tutto, **dentro i 30 gratuiti del giorno: costo vero zero**.
Un giro che funziona, come il secondo, costa 8 centesimi a listino.

## FE.21.4, Test Lab non sostituisce le registrazioni sul Realme

Test Lab non sostituisce le registrazioni della voce di FE.05 sul Realme, per
tre ragioni:

- su Test Lab il LIVE non si apre, perché l'account non ne ha diritto;
- non c'è un microfono che parla al Maestro;
- non si registra l'audio che esce dal telefono.

Test Lab prova il filo principale e le risposte scritte su un telefono Xiaomi.
La voce si prova sul Realme.

## FE.21.1, l'emulatore

Lo stesso profilo del Redmi è in `../emulatore/`. Su questo PC l'emulatore non
parte, perché la virtualizzazione è spenta nel firmware
(`../emulatore/avvio_su_questo_pc.txt`).

## L'impalcatura e' stata tolta, e perche'

Il 6 ottobre 2026, alle 02:15, la build di rilascio e' caduta:
`GeneratedPluginRegistrant.java:144: error: package
dev.flutter.plugins.integration_test does not exist`. Con Flutter 3.44.5 il
registro dei plugin chiama `integration_test` anche nella build di rilascio,
benche' il pacchetto sia marcato come dipendenza di sviluppo, e la sua classe
nella build di rilascio non c'e'. La stessa caduta avrebbe fermato la build
2299. Padre: ordine FE voce 21.2, cioe' io.

Per questo la dipendenza `integration_test`, la cartella `integration_test/`
e `android/app/src/androidTest/` sono state tolte, e `pubspec.yaml` e
`android/app/build.gradle.kts` sono tornati identici al byte a prima della
voce 21. I due sorgenti restano qui in `sorgenti/` con l'estensione `.txt`, cosi'
l'analisi non li compila. Per rifare un giro su Test Lab vanno rimessi al loro
posto insieme alla dipendenza, il giro va fatto con la build di debug, e
l'impalcatura va tolta di nuovo prima di qualunque build di rilascio.
