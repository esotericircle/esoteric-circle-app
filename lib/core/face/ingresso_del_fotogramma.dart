import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Il formato dei byte che la fotocamera consegna al motore del volto.
enum FormatoDelFotogramma {
  /// Android: un piano solo, luminanza e crominanza intrecciate.
  nv21,

  /// iOS: quattro byte per punto, blu verde rosso e trasparenza.
  bgra,
}

/// **COME UN FOTOGRAMMA ENTRA NEL MOTORE, per piattaforma.** Ordine DS voce
/// 06, 17 settembre 2026.
///
/// **Il fatto**: sui telefoni dei fondatori, che sono tutti iPhone, la
/// Costellazione del Viso non rilevava nessun volto. **La causa erano tre
/// scelte scritte una volta sola per tutti i telefoni**, e giuste solo su
/// Android:
///
/// 1. **il formato.** La fotocamera chiedeva NV21, che su iOS non esiste:
///    `camera_avfoundation` lo fa ricadere in BGRA, e il motore leggeva quei
///    byte come se fossero NV21;
/// 2. **la rotazione.** Al modello arrivava l'orientamento del sensore. Su
///    iOS il plugin consegna il fotogramma **gia' girato come il
///    dispositivo** (`updateOrientation` sull'uscita video), quindi girarlo
///    ancora di novanta gradi metteva il volto di lato;
/// 3. **lo specchio.** Su iOS la frontale e' **gia' specchiata** dal plugin
///    (`isVideoMirrored`), e specchiarla una seconda volta la raddrizzava al
///    contrario.
///
/// **Le tre scelte adesso stanno qui, insieme**, perche' sono una scelta
/// sola: chi ne cambia una senza le altre rompe la catena. Sono le stesse che
/// l'esempio di `mediapipe_face_mesh` 2.9.0 usa per la fotocamera.
///
/// **Su Android non cambia niente**: formato, rotazione e specchio sono
/// identici a com'erano prima di quest'ordine, e una guardia lo pretende.
@immutable
class IngressoDelFotogramma {
  const IngressoDelFotogramma._({
    required this.formato,
    required this.giraColDispositivo,
    required this.specchiaLaFrontale,
  });

  /// L'ingresso di Android, com'era prima dell'ordine DS.
  static const android = IngressoDelFotogramma._(
    formato: FormatoDelFotogramma.nv21,
    giraColDispositivo: false,
    specchiaLaFrontale: true,
  );

  /// L'ingresso di iOS.
  static const ios = IngressoDelFotogramma._(
    formato: FormatoDelFotogramma.bgra,
    giraColDispositivo: true,
    specchiaLaFrontale: false,
  );

  /// L'ingresso della piattaforma su cui gira l'app.
  static IngressoDelFotogramma per(TargetPlatform piattaforma) =>
      piattaforma == TargetPlatform.iOS ? ios : android;

  final FormatoDelFotogramma formato;

  /// Vero quando il fotogramma arriva gia' girato come il dispositivo, e al
  /// modello si da' l'orientamento del dispositivo invece di quello del
  /// sensore.
  final bool giraColDispositivo;

  /// Vero quando la frontale va specchiata qui, perche' il plugin non lo fa.
  final bool specchiaLaFrontale;

  /// I gradi di ogni orientamento del dispositivo.
  static const Map<DeviceOrientation, int> gradiDelDispositivo = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  /// La rotazione da dare al modello, e **la stessa** da usare per sapere se
  /// il fotogramma ha i lati scambiati: il modello e la maschera devono
  /// girare dello stesso angolo, o i punti non cadono sul volto.
  int rotazione({
    required int sensore,
    required DeviceOrientation dispositivo,
  }) =>
      giraColDispositivo ? (gradiDelDispositivo[dispositivo] ?? 0) : sensore;

  /// Se il fotogramma va specchiato prima di arrivare al modello.
  bool specchiata({required bool frontale}) => specchiaLaFrontale && frontale;
}
