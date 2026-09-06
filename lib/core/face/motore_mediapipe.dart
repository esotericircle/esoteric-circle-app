import 'dart:typed_data';
import 'dart:ui';

import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'face_classifier.dart';
import 'motore_del_volto.dart';
import 'punti_del_volto.dart';

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
    _rilevatore = await FaceDetectorProcessor.create();
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
    final mesh = esito.meshResult;
    // **NESSUN VOLTO: SI RESTITUISCE NULLA.** Qui vive, alla fonte, la regola
    // di CR.01: davanti a un muro non nasce nessun dato, e chi chiama non
    // trova niente da sostituire con una sagoma.
    if (mesh == null || mesh.landmarks.isEmpty) return null;

    final geometria = mesh.estimateGeometry();
    final posa = geometria.headPose;
    return LetturaDelVolto(
      contorni: PuntiDelVolto.contorniDa(mesh.landmarks),
      yaw: posa.yawDegrees,
      pitch: posa.pitchDegrees,
      roll: posa.rollDegrees,
      espressione: espressione.process(mesh) ?? const {},
      punti: mesh.landmarks,
    );
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
