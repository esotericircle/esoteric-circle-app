# ORDINE CX, LA COSTELLAZIONE DEL VISO

8 settembre 2026. Nasce dalla prova diretta del fondatore sul suo telefono.
Esperienza sua parole, **parzialmente positiva**.

## LE PAROLE DEL FONDATORE, alla lettera

> visto che stai lavorando alla costellazione del viso, ti do la mia esperienza
> parzialmente positiva. i punti negativi: ho fatto la scansione con cappellino
> con sopracciglia e fronte occultate, dopo la scansione ho fatto la foto del
> muro e inoltre il responso mi descriveva fronte e sopracciglia anche se
> nascoste. devi sistemare, trova soluzione elegante e professionale. quando
> andro' a vedere le scorse scansioni e risultati vorro' vedere la foto del
> viso e non del muro che dovrebbe essere vietato. la card generata per la
> condivisione dovrebbe ovviamente riportare la foto del Viso e informazioni
> accurate oltre che un titolo accattivante. pensa ad un effetto Wow: perche'
> l'utente dovrebbe condividere e perche' un amico dovrebbe sentirsi spinto a
> scaricare l'app per avere la stessa esperienza?

## I FATTI, separati uno per uno

Si scrivono come **sintomi osservati**, non come soluzioni: la causa e la forma
le sceglie e le misura chi esegue, secondo la regola di casa del 27 agosto.

- **CX.01** La scansione e' stata accettata **col cappellino**, con fronte e
  sopracciglia occultate. Esito atteso: una zona del viso coperta si riconosce,
  e chi scansiona lo sa prima di ricevere il responso.
- **CX.02** Dopo la scansione la fotografia **del muro** e' stata accettata.
  Esito atteso: un fotogramma senza un viso non produce nessun responso e
  nessun ricordo. Parole sue: *"che dovrebbe essere vietato"*.
- **CX.03** Il responso **descriveva fronte e sopracciglia anche se nascoste**.
  Esito atteso: cio' che non si e' visto non si descrive, e il responso resta
  intero senza fingere di aver visto.
- **CX.04** Nelle **scansioni passate** vuole rivedere **la foto del viso**, non
  quella del muro.
- **CX.05** La **card di condivisione** deve portare la foto del Viso,
  informazioni accurate e un **titolo accattivante**.
- **CX.06** **L'EFFETTO WOW.** Due domande sue, e sono la misura della voce:
  *"perche' l'utente dovrebbe condividere"* e *"perche' un amico dovrebbe
  sentirsi spinto a scaricare l'app per avere la stessa esperienza?"*

## I FATTI AGGIUNTI DAL FONDATORE MENTRE IL LAVORO ERA IN CORSO

8 settembre 2026, tre messaggi arrivati durante l'esecuzione. Si scrivono qui
con le sue parole, perche' un fatto detto a meta' lavoro e' un fatto come gli
altri.

- **CX.07** *"la lettura dovrebbe avvertire inizialmente di togliere cappelli o
  occhiali o altri accessori che potrebbero nascondere i tratti"*. Esito
  atteso: chi comincia la scansione sa **prima** cosa la rovina.
- **CX.08** *"nel caso ci siano ugualmente, il responso dovrebbe indicarlo"*, e
  *"anche magari nel caso di piercing e orecchini che cmq non nascondono i
  tratti"*. Esito atteso: il responso dichiara cosa non ha potuto vedere,
  invece di descriverlo lo stesso.
- **CX.09** *"destra e sinistra vanno invertiti"* nelle pose della scansione.
  Esito atteso: la posa chiesta e la posa che la macchina aspetta sono la
  stessa, dal punto di vista di chi si guarda nello specchio della fotocamera
  frontale.

### E UNA COSA CHE MEDIAPIPE NON PUO' DIRE

Verificato nel pacchetto `mediapipe_face_mesh` 2.9.0 prima di progettare
qualunque cosa: `FaceMeshLandmark` porta **solo x, y e z**, nessun campo di
visibilita' o di presenza per singolo punto. Quindi **non esiste modo di
chiedere al modello quali punti abbia visto e quali abbia dedotto**: la
distinzione fra visto e supposto, che la CAUSA B nomina, non si ottiene
interrogando la mesh. O si misura sulla fotografia, o si dichiara. La via
indicata dal fondatore, avvertire prima e dichiarare dopo, e' la sola che non
finge una certezza che il modello non ha.

## LA PREMESSA DA VERIFICARE PRIMA DI TOCCARE QUALSIASI COSA

**L'ordine CR del 6 settembre 2026 dice di aver gia' riparato il muro.** Le sue
parole nel registro: *"La Costellazione del Viso produceva un responso anche
fotografando un muro, e la prima di queste otto e' nata rossa senza innesto
perche' il difetto era in produzione."*

Quindi delle due l'una, e va stabilito **prima** di scrivere una riga:

1. o la build che il fondatore ha in mano e' **anteriore** a CR, e allora il
   difetto e' vecchio e la cura c'e' gia';
2. o la cura di CR **non copre** il caso che lui ha incontrato, e allora quella
   voce misurava un pezzo sano accanto al pezzo rotto, che in questo progetto
   e' successo sette volte su sette in un'aggiunta sola.

**Non si scrive niente finche' non si sa quale delle due.**

### RISOLTA, ed e' la seconda

Verificato col grafo dei commit, non a memoria. I quattro commit che portano la
cura del Viso dell'ordine CR sono **tutti antenati** del commit `ec1a967e` che
ha portato `pubspec` a 0.1.0+2229, cioe' della build consegnata su App
Distribution il 6 settembre, release `2715l6h56u188`:

| commit | cosa porta | dentro la 2229 |
| --- | --- | ---: |
| `386d17be` | *"La cattura del Viso passa dal ripiego, perche' la vecchia strada era il muro"* | si' |
| `a58fd6ab` | CR.09, la maschera dei punti veri | si' |
| `ab6cf394` | *"Ordine CR seconda stesura: il muro, il responso a caso, il capo che si scambia"* | si' |
| `85695835` | lo stato vivo della seconda stesura | si' |

Sono antenati anche della 2231 installata sul dispositivo di collaudo la notte
fra il 7 e l'8 settembre.

**Quindi la cura c'era, e il difetto e' passato sopra di lei.** E' la famiglia
che questo progetto ha gia' pagato sette volte in un'aggiunta sola: **la
guardia misurava un pezzo sano accanto al pezzo rotto.** La prima cosa da
riparare non e' il muro: e' capire che cosa quella guardia stava guardando
mentre il muro passava.

## LE DUE CAUSE, LETTE NEL CODICE PRIMA DI TOCCARLO

Non sono ancora provate sul telefono: sono lette nel sorgente e vanno viste
rosse prima di curarle. Si scrivono qui perche' la lettura e' gia' fatta.

### CAUSA A, il cancello giudica i contorni e poi si fotografa altro

In `face_constellation_screen.dart`, dopo che il cancello ha detto che il volto
c'e', l'ordine delle operazioni e' questo:

```dart
final contorni = (esito as VoltoTrovato).contorni;
final reading = FaceClassifier.leggi(contorni);   // il responso nasce QUI
final cost = FaceConstellation.da(contorni);
String? foto;
try {
  if (_camera != null) {
    await _camera!.stopImageStream();
    final x = await _camera!.takePicture();       // la foto si scatta DOPO
    foto = x.path;
  }
```

**Il responso nasce dai contorni vivi, la fotografia si scatta dopo, e nessuno
guarda cosa c'e' dentro la fotografia.** Il cancello certifica i CONTORNI; la
foto e' un'altra cosa, presa in un istante successivo, da una fotocamera che nel
frattempo puo' guardare qualunque cosa.

E' esattamente cio' che il fondatore descrive: **il responso era il suo, la foto
era il muro.** La cura dell'ordine CR non e' stata aggirata, ha fatto il suo
lavoro sul pezzo che le era stato dato da guardare. **Guardava il pezzo sano
accanto al pezzo rotto**, e il pezzo rotto era la fotografia, che nessuna
guardia ha mai esaminato.

Spiega **CX.02** e **CX.04** con un difetto solo.

### CAUSA B, la mesh inventa i punti che non vede

MediaPipe posa i suoi punti anche sulle zone coperte: e' un modello che
**deduce** la forma del volto, non un misuratore che si rifiuta quando non
vede. Sotto un cappello i punti della fronte e delle sopracciglia ci sono lo
stesso, plausibili e falsi.

`FaceClassifier.leggi(contorni)` riceve quei punti e non ha modo di sapere quali
siano stati visti e quali dedotti: **nel tipo dei contorni non esiste la
differenza fra visto e supposto.** Quindi descrive la fronte di chi porta il
cappello, e lo fa con la stessa sicurezza con cui descrive il mento.

Spiega **CX.01** e **CX.03**.

**Le due cause sono indipendenti**, e questo conta: curarne una lascia l'altra
in piedi. Nessuna delle due si cura alzando una soglia.

### CAUSA C, le scansioni passate non hanno nessuna foto da mostrare

`lib/core/face/face_history.dart` lo dichiara nel suo stesso commento:

> Nessuna immagine e nessuna foto: si salva solo la lettura dei tratti, che
> sono testo.

Quindi **CX.04 non e' un difetto da riparare, e' una funzione da costruire**:
oggi lo storico non mostra il muro, non mostra niente. La fotografia vive solo
in memoria per la durata della sessione, dentro `_fotoPath`, e serve a due
cose: il fondo del responso e il fondo della card.

**E questo apre una decisione che non e' mia.** Esiste una guardia,
`il_volto_non_esce_dal_dispositivo`, e una regola di casa che dice che il volto
non lascia il telefono. Conservare le fotografie **sul dispositivo** non la
viola, ma cambia cosa l'app tiene di una persona, e va deciso e scritto: quante
se ne conservano, per quanto, come si cancellano. Si propone, non si decide da
soli.

### CAUSA D, la card la foto ce l'ha gia', e sbiadita per ordine suo

`face_share_card.dart` posa la fotografia dietro la costellazione **a opacita'
0,35**. Non e' una dimenticanza: e' cio' che il fondatore stesso aveva chiesto
nell'ordine CR voce 10, parole sue, *"la costellazione composta, protagonista;
il volto molto sbiadito sotto"*.

Adesso dice che la card *"dovrebbe ovviamente riportare la foto del Viso"*. Le
due richieste non si contraddicono per forza: se la foto sotto era quella del
muro, una card con un muro sbiadito dietro sembra una card senza volto. **Prima
di cambiare l'opacita' si cura la CAUSA A**, e poi si guarda la card con dentro
una faccia vera. Cambiare il disegno adesso vorrebbe dire curare il sintomo di
un difetto che sta altrove.

## COSA RESTA FUORI

L'ordine CW e' chiuso e consegnato prima di questo: la build che il fondatore
ricevera' su App Distribution **non contiene** il lavoro sul Viso, e questo
manifesto esiste perche' quella distinzione non si perda.
