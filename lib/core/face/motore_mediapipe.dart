import 'dart:typed_data';
import 'dart:ui';

import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'face_classifier.dart';
import 'inclinazione_del_capo.dart';
import 'motore_del_volto.dart';
import 'punti_del_volto.dart';
import 'soglie_del_rilevamento.dart';

/// **IL MOTORE VERO: MediaPipe Face Mesh.** Ordine CR voce 02, 6 settembre
/// 2026.
///
/// **Perche' questo e non ML Kit**, che il progetto usava: ML Kit Face Mesh ha
/// la documentazione solo per Android e non restituisce i coefficienti
/// dell'espressione. Sarebbero due funzioni diverse su due telefoni diversi, e
/// CR.07 non si potrebbe nemmeno aprire.
///
/// **NIENTE ESCE DAL DISPOSITIVO.** Questa classe non importa nessun client di
/// rete e non scrive niente su disco: i fotogrammi entrano dalla fotocamera,
/// attraversano i modelli in memoria e vengono lasciati andare. E' una
/// garanzia che si legge dagli import, non una promessa scritta a parole.
class MotoreMediaPipe extends MotoreDelVolto {
  MotoreMediaPipe();

  FaceDetectorProcessor? _rilevatore;
  FaceMeshProcessor? _mesh;
  FaceBlendshapesProcessor? _espressione;
  FaceMeshInferencePipeline? _catena;

  @override
  Future<void> avvia() async {
    _rilevatore = await FaceDetectorProcessor.create(
      // La soglia del pacchetto decide cosa vale la pena di analizzare.
      // La nostra, piu' severa, decide a chi si da' un responso, e si
      // applica dopo, sul punteggio del rilevamento scelto.
      minDetectionConfidence: SoglieDelRilevamento.confidenzaDelRilevatore,
    );
    // **v2 e non v1**: il pacchetto lo raccomanda, e la v1 resta il default
    // solo per non rompere chi la usa gia'.
    _mesh = await FaceMeshProcessor.create(model: FaceMeshModel.v2);
    _espressione = await FaceBlendshapesProcessor.create();
    _catena = FaceMeshInferencePipeline(
      detector: _rilevatore!,
      mesh: _mesh!,
      // **L'ADDOLCIMENTO E' ACCESO, e serve alla scansione.** Senza, i punti
      // ballano fra un fotogramma e l'altro e gli angoli della testa
      // tremolano: una posa entrerebbe e uscirebbe dalla soglia da sola, e la
      // tenuta di CR.03 non si compirebbe mai.
      landmarkSmoothing: const LandmarkSmoothingOptions(),
      // **L'INSEGUIMENTO E' SPENTO, ED E' LA CORREZIONE PIU' IMPORTANTE
      // DI QUESTO ORDINE.** Ordine CR voce 01, seconda stesura.
      //
      // Con l'inseguimento acceso, che e' il modo in cui questa catena
      // nasce, dopo il primo aggancio **il rilevatore non gira piu'** e
      // la mesh continua a posare punti dentro la regione che stava
      // seguendo. Il pacchetto lo scrive: *"Null when the frame was
      // served by landmark tracking, in which case the detector did not
      // run"*. Chi completava la scansione col proprio viso e poi
      // inquadrava una parete riceveva ancora punti, perche' nessuno
      // stava piu' cercando un volto.
      //
      // Spento, il rilevatore gira su OGNI fotogramma. Costa di piu', e
      // il prezzo si paga volentieri: e' la differenza fra una scansione
      // e una messa in scena.
      enableLandmarkTracking: false,
    );
  }

  @override
  Future<LetturaDelVolto?> leggi({
    required Uint8List byte,
    required int larghezza,
    required int altezza,
    required int rotazione,
    required bool specchiata,
    required int byteDiRiga,
  }) async {
    final catena = _catena;
    final espressione = _espressione;
    if (catena == null || espressione == null) return null;

    final frame = FaceMeshNv21Image.tryFromSinglePlane(
      bytes: byte,
      width: larghezza,
      height: altezza,
      bytesPerRow: byteDiRiga,
    );
    if (frame == null) return null;

    final esito = catena.processNv21(
      frame,
      rotationDegrees: rotazione,
      mirrorHorizontal: specchiata,
    );
    // **DUE GIUDIZI, E SI PRETENDONO TUTTI E DUE.** Ordine CR voce 01,
    // seconda stesura.
    //
    // Prima qui bastava che la lista dei punti non fosse vuota, e una
    // lista non vuota non dice niente su cosa ci sia davanti
    // all'obiettivo: la mesh posa punti ovunque le si dica di posarli.
    // Il rilevatore dice **che li' c'e' una faccia**, la mesh dice
    // **quanto bene i suoi punti si sono posati sopra**, e sotto una
    // delle due soglie non nasce nessun dato.
    final rilevato = esito.selectedDetection;
    if (rilevato == null ||
        rilevato.score < SoglieDelRilevamento.confidenzaDelRilevatore) {
      return null;
    }
    final mesh = esito.meshResult;
    if (mesh == null ||
        mesh.landmarks.isEmpty ||
        mesh.score < SoglieDelRilevamento.confidenzaDellaMesh) {
      return null;
    }

    final geometria = mesh.estimateGeometry();
    final posa = geometria.headPose;
    return LetturaDelVolto(
      // La forma del fotogramma entra nella conversione: senza, ogni
      // rapporto fra una larghezza e un'altezza esce schiacciato.
      contorni: PuntiDelVolto.contorniDa(
        mesh.landmarks,
        proporzioneDelFotogramma: mesh.imageHeight <= 0
            ? 1.0
            : mesh.imageWidth / mesh.imageHeight,
      ),
      // **GLI ANGOLI VENGONO DAI PUNTI, NON DAL PACCHETTO.** Ordine CR
      // voce 03, seconda stesura.
      //
      // `pitchDegrees` e' documentato come "Up/down head rotation in
      // degrees" e **non dichiara da che parte cresce**. La prima
      // stesura ha dato per buono che positivo volesse dire mento
      // alzato: sul telefono del fondatore la posa "guarda in basso" si
      // compiva ALZANDO il viso. Adesso i due angoli si ricavano dalla
      // profondita' dei punti, con un segno che una guardia prova
      // ruotando una testa sintetica di un angolo noto.
      //
      // Il rollio resta quello del pacchetto: non guida nessuna posa, e
      // per l'inclinazione di lato una convenzione sbagliata non manda
      // nessuno a inseguire un gesto impossibile.
      yaw: InclinazioneDelCapo.gradiDiProfilo(mesh.landmarks),
      pitch: InclinazioneDelCapo.gradi(mesh.landmarks),
      roll: posa.rollDegrees,
      espressione: espressione.process(mesh) ?? const {},
      punti: mesh.landmarks,
      confidenzaDelRilevamento: rilevato.score,
      confidenzaDellaMesh: mesh.score,
      proporzioneDelFotogramma: mesh.imageHeight <= 0
          ? 1.0
          : mesh.imageWidth / mesh.imageHeight,
    );
  }

  @override
  Future<bool> laFotoHaUnVolto({
    required Uint8List rgba,
    required int larghezza,
    required int altezza,
  }) async {
    final r = _rilevatore;
    if (r == null) return false;
    if (larghezza <= 0 || altezza <= 0) return false;
    // I byte devono bastare per l'immagine dichiarata: un fotogramma
    // troncato darebbe un rifiuto che sembra "non c'e' nessun volto" mentre
    // il volto c'era e i dati no.
    if (rgba.length < larghezza * altezza * 4) return false;
    final esito = r.process(
      FaceMeshImage(pixels: rgba, width: larghezza, height: altezza),
    );
    // `primaryDetection`, non `selectedDetection`: quest ultimo esiste
    // sull esito della catena, non su quello del solo rilevatore, e i due
    // tipi si somigliano abbastanza da farlo credere.
    final scelto = esito.primaryDetection;
    // **LA STESSA SOGLIA DEL FOTOGRAMMA VIVO.** Una soglia piu' bassa qui
    // vorrebbe dire che l'immagine che si conserva puo' essere piu' incerta
    // di quella che ha prodotto il responso, e la fotografia e' proprio la
    // cosa che la persona rivedra' fra un mese.
    return scelto != null &&
        scelto.score >= SoglieDelRilevamento.confidenzaDelRilevatore;
  }

  @override
  Future<void> spegni() async {
    // I contesti nativi si chiudono a mano: un finalizzatore li prenderebbe
    // prima o poi, e "prima o poi" su una fotocamera vuol dire memoria
    // occupata mentre la persona e' gia' in un'altra schermata.
    _rilevatore?.close();
    _mesh?.close();
    _espressione?.close();
    _rilevatore = null;
    _mesh = null;
    _espressione = null;
    _catena = null;
  }
}

/// Le coordinate di un punto della mesh nel riquadro di mille per mille che il
/// classificatore dei tratti usa da sempre.
Offset puntoDa(FaceMeshLandmark l) => Offset(l.x * 1000, l.y * 1000);

/// Estensione di comodo per leggere un contorno dai suoi indici.
extension ContornoDaIndici on List<FaceMeshLandmark> {
  List<Offset> lungo(List<int> indici) =>
      [for (final i in indici) if (i < length) puntoDa(this[i])];
}

/// Il tipo che il classificatore si aspetta, ricostruito dai landmark.
typedef ContorniDelVolto = FaceContours;
