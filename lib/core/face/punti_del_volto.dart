import 'dart:ui';

import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'face_classifier.dart';

/// **DOVE STANNO I TRATTI DENTRO I 478 PUNTI.** Ordine CR voci 02 e 05, 6
/// settembre 2026.
///
/// **LA FONTE, DICHIARATA.** Questi indici sono i gruppi canonici della
/// MediaPipe Face Mesh, quelli che Google pubblica insieme al modello nelle
/// costanti `FACEMESH_FACE_OVAL`, `FACEMESH_LEFT_EYE`, `FACEMESH_RIGHT_EYE`,
/// `FACEMESH_LEFT_EYEBROW`, `FACEMESH_RIGHT_EYEBROW` e `FACEMESH_LIPS`. Non
/// sono scelti da noi e non sono stimati: sono il modo in cui quel modello
/// nomina le parti del volto.
///
/// **IL PACCHETTO NON LI ESPONE**, verificato cercandoli nei suoi sorgenti: da'
/// i triangoli della maglia ma non i gruppi. Quindi vivono qui, in un posto
/// solo, con una guardia che verifica che siano indici veri.
///
/// **SINISTRA E DESTRA SONO QUELLE DEL SOGGETTO**, come nel modello: l'occhio
/// che MediaPipe chiama *left* e' l'occhio sinistro della persona, che sullo
/// schermo di una fotocamera frontale specchiata appare a destra. La
/// convenzione si dichiara qui una volta perche' e' la sorgente classica degli
/// scambi silenziosi.
class PuntiDelVolto {
  const PuntiDelVolto._();

  /// Il contorno esterno del volto, dalla fronte al mento e ritorno.
  static const List<int> ovale = [
    10, 338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288, 397, 365,
    379, 378, 400, 377, 152, 148, 176, 149, 150, 136, 172, 58, 132, 93,
    234, 127, 162, 21, 54, 103, 67, 109,
  ];

  /// Il sopracciglio sinistro del soggetto.
  static const List<int> sopraccioSinistro = [
    276, 283, 282, 295, 285, 300, 293, 334, 296, 336,
  ];

  /// Il sopracciglio destro del soggetto.
  static const List<int> sopraccioDestro = [
    46, 53, 52, 65, 55, 70, 63, 105, 66, 107,
  ];

  /// L'occhio sinistro del soggetto.
  static const List<int> occhioSinistro = [
    263, 249, 390, 373, 374, 380, 381, 382, 362, 466, 388, 387, 386, 385,
    384, 398,
  ];

  /// L'occhio destro del soggetto.
  static const List<int> occhioDestro = [
    33, 7, 163, 144, 145, 153, 154, 155, 133, 246, 161, 160, 159, 158,
    157, 173,
  ];

  /// Il ponte del naso, dalla radice alla punta.
  static const List<int> ponteDelNaso = [168, 6, 197, 195, 5, 4];

  /// La base del naso e le narici.
  static const List<int> baseDelNaso = [98, 97, 2, 326, 327];

  /// Il labbro superiore, bordo esterno.
  static const List<int> labbroSuperiore = [
    61, 185, 40, 39, 37, 0, 267, 269, 270, 409, 291,
  ];

  /// Il labbro inferiore, bordo esterno.
  static const List<int> labbroInferiore = [
    61, 146, 91, 181, 84, 17, 314, 405, 321, 375, 291,
  ];

  /// Lo zigomo sinistro del soggetto.
  static const List<int> guanciaSinistra = [345, 352, 376, 433, 416];

  /// Lo zigomo destro del soggetto.
  static const List<int> guanciaDestra = [116, 123, 147, 213, 192];

  /// Tutti i gruppi, per nome. Serve alla guardia, che senza un elenco
  /// scoperto controllerebbe solo quelli che qualcuno si ricorda di elencare.
  static const Map<String, List<int>> gruppi = {
    'ovale': ovale,
    'sopracciglio sinistro': sopraccioSinistro,
    'sopracciglio destro': sopraccioDestro,
    'occhio sinistro': occhioSinistro,
    'occhio destro': occhioDestro,
    'ponte del naso': ponteDelNaso,
    'base del naso': baseDelNaso,
    'labbro superiore': labbroSuperiore,
    'labbro inferiore': labbroInferiore,
    'guancia sinistra': guanciaSinistra,
    'guancia destra': guanciaDestra,
  };

  /// Quanti punti restituisce la mesh con l'iride accesa.
  static const int quantiPunti = 478;

  /// I contorni nella forma che il classificatore dei tratti gia' conosce.
  ///
  /// **QUI STAVA IL DIFETTO CHE RENDEVA I RESPONSI A CASO.** Ordine CR,
  /// seconda stesura, 6 settembre 2026.
  ///
  /// Parole del fondatore dopo la prova sul telefono: *"il responso NON
  /// C'ENTRA UN CAZZO! SONO DESCRIZIONI BUTTATE LI' A CASO?"*. Non erano
  /// buttate a caso: erano misure vere fatte su un viso schiacciato.
  ///
  /// La riga era questa:
  ///
  ///     Offset(punti[i].x * 1000, punti[i].y * 1000)
  ///
  /// I punti arrivano **normalizzati da zero a uno sui due lati**, e i due
  /// lati non sono lunghi uguale: su un fotogramma tre quarti, un
  /// centesimo di larghezza e un centesimo di altezza sono due distanze
  /// diverse. Moltiplicandoli per lo stesso numero il volto veniva
  /// **stirato in orizzontale di un terzo**, e il classificatore, che
  /// lavora quasi solo su rapporti fra una larghezza e un'altezza, leggeva
  /// un ovale come un volto tondo o quadrato. Da li' in poi ogni categoria
  /// sbagliava insieme alle altre: forma, occhi, naso, bocca, mascella,
  /// zigomi.
  ///
  /// **Adesso la proporzione del fotogramma entra nel conto**: il lato
  /// lungo prende mille, il lato corto prende meno in proporzione, e le
  /// distanze tornano confrontabili fra loro. Il classificatore non
  /// cambia: cambia che i numeri che gli arrivano sono di un volto e non
  /// di un volto stirato.
  ///
  /// [proporzioneDelFotogramma] e' larghezza diviso altezza. Uno vuol dire
  /// quadrato, e allora questa funzione fa cio' che faceva prima.
  static FaceContours contorniDa(
    List<FaceMeshLandmark> punti, {
    required double proporzioneDelFotogramma,
  }) {
    final p = proporzioneDelFotogramma > 0 ? proporzioneDelFotogramma : 1.0;
    // Il lato lungo prende la scala piena, l'altro prende la sua parte.
    final scalaX = p >= 1 ? 1000.0 : 1000.0 * p;
    final scalaY = p >= 1 ? 1000.0 / p : 1000.0;
    List<Offset> presi(List<int> indici) => [
          for (final i in indici)
            if (i < punti.length)
              Offset(punti[i].x * scalaX, punti[i].y * scalaY),
        ];
    return FaceContours(
      volto: presi(ovale),
      sopraccioSx: presi(sopraccioSinistro),
      sopraccioDx: presi(sopraccioDestro),
      occhioSx: presi(occhioSinistro),
      occhioDx: presi(occhioDestro),
      nasoPonte: presi(ponteDelNaso),
      nasoBase: presi(baseDelNaso),
      labbroSopra: presi(labbroSuperiore),
      labbroSotto: presi(labbroInferiore),
      // **LE GUANCE SONO UN PUNTO SOLO**, e il classificatore le vuole
      // cosi: e' lo zigomo, cioe' il punto piu' sporgente, non un
      // contorno. Si prende il centro del gruppo, che e' la sua media.
      guanciaSx: _centro(presi(guanciaSinistra)),
      guanciaDx: _centro(presi(guanciaDestra)),
    );
  }

  /// Il centro di un gruppo di punti, cioe' la loro media. Nullo se il
  /// gruppo e' vuoto: meglio niente che un punto inventato all'origine.
  static Offset? _centro(List<Offset> p) {
    if (p.isEmpty) return null;
    var x = 0.0;
    var y = 0.0;
    for (final o in p) {
      x += o.dx;
      y += o.dy;
    }
    return Offset(x / p.length, y / p.length);
  }
}
