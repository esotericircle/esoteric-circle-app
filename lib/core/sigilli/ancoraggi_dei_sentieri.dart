library;

import 'lettura_degli_ancoraggi.dart';
import 'sentieri.dart';

/// GLI ANCORAGGI DEI TRE SENTIERI. Ordine T voce 01.
///
/// **QUESTO FILE NON SI SCRIVE A MANO.** Lo produce
/// `tool/ancoraggi_dai_sentieri.dart` leggendo le immagini di
/// `brand_assets/sentieri/`, e
/// `test/gli_ancoraggi_vengono_dall_arte_test.dart` rifa' la
/// lettura a ogni giro e confronta: se l'arte cambia e questo
/// file no, una riga cade.
///
/// **Perche' il dato sta qui invece di ricavarsi ogni volta.**
/// Riconoscere le macchie su un milione e mezzo di pixel costa
/// troppo per farlo mentre qualcuno guarda la schermata.
///
/// **Sentieri senza ancoraggi, oggi: costellazione, loto.**
/// Non hanno una regola di riconoscimento perche' la loro
/// arte non consente di ricavarli da sola: la ragione,
/// misurata, sta in `docs/ordini/ORDINE_T_MANIFESTO.md`.
/// Chi chiede gli ancoraggi di un sentiero senza arte
/// riceve nulla, e il disegno resta quello procedurale.
class AncoraggiDeiSentieri {
  const AncoraggiDeiSentieri._();

  static const Map<Sentiero, List<AncoraggioDelSentiero>> tutti = {
    Sentiero.albero: [
      AncoraggioDelSentiero(x: 0.80460, y: 0.67436, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.87201, y: 0.68213, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.73716, y: 0.68428, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.93123, y: 0.69972, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.68406, y: 0.71058, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.32329, y: 0.70728, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.07743, y: 0.69710, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.26960, y: 0.68215, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.13614, y: 0.67970, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.20380, y: 0.67297, gruppo: 0, eGrande: false),
      AncoraggioDelSentiero(x: 0.50808, y: 0.68451, gruppo: 0, eGrande: true),
      AncoraggioDelSentiero(x: 0.80468, y: 0.53538, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.87218, y: 0.54031, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.73699, y: 0.54575, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.93184, y: 0.55682, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.68425, y: 0.57265, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.32597, y: 0.57008, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.07672, y: 0.55565, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.27135, y: 0.54455, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.13545, y: 0.53869, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.20500, y: 0.53420, gruppo: 1, eGrande: false),
      AncoraggioDelSentiero(x: 0.50778, y: 0.53465, gruppo: 1, eGrande: true),
      AncoraggioDelSentiero(x: 0.80516, y: 0.39093, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.87271, y: 0.39753, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.93187, y: 0.41452, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.73880, y: 0.40424, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.68610, y: 0.42966, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.32232, y: 0.42959, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.26991, y: 0.40405, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.07707, y: 0.41385, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.13646, y: 0.39702, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.20530, y: 0.39034, gruppo: 2, eGrande: false),
      AncoraggioDelSentiero(x: 0.50960, y: 0.38342, gruppo: 2, eGrande: true),
      AncoraggioDelSentiero(x: 0.80315, y: 0.24980, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.87257, y: 0.25494, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.93103, y: 0.27311, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.73832, y: 0.26301, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.68361, y: 0.28760, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.32203, y: 0.28804, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.27104, y: 0.26379, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.07786, y: 0.27274, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.13731, y: 0.25497, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.20551, y: 0.25067, gruppo: 3, eGrande: false),
      AncoraggioDelSentiero(x: 0.50893, y: 0.24196, gruppo: 3, eGrande: true),
      AncoraggioDelSentiero(x: 0.87073, y: 0.10844, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.80167, y: 0.10193, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.93172, y: 0.12656, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.73503, y: 0.11398, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.68207, y: 0.13931, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.32209, y: 0.14000, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.27169, y: 0.11417, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.07797, y: 0.12623, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.13843, y: 0.10949, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.20693, y: 0.10190, gruppo: 4, eGrande: false),
      AncoraggioDelSentiero(x: 0.51286, y: 0.07262, gruppo: 4, eGrande: true),
    ],
  };

  /// Gli ancoraggi di un sentiero, o nulla se la sua arte non
  /// e' ancora leggibile.
  static List<AncoraggioDelSentiero>? di(Sentiero sentiero) =>
      tutti[sentiero];
}
