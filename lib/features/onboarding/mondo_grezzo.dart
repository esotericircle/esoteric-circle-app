/// Il mondo a poligoni grossolani del Planisfero, in un file suo:
/// lo leggono sia il Planisfero (la griglia del mondo) sia la Mappa della
/// Nazione (lo sfondo di regione dell'ordine BD voce 03), e un import
/// circolare fra i due sarebbe stato il prezzo di tenerlo dov'era.
/// La forma del mondo, ridotta all'osso.
///
/// Poligoni grossolani in gradi veri: bastano a far riconoscere i continenti a
/// colpo d'occhio, e nessuno ci misurera' un confine. Sono scritti qui e non
/// caricati da un file perche' un asset di contorni costa piu' peso di quanto
/// serva a una silhouette di punti.
/// Pubblica perche' i confini della sagoma sono l'unica cosa che un test
/// possa misurare senza guardare i pixel.
class MondoGrezzo {
  /// Vero se quel punto in gradi cade sulla terra emersa.
  static bool eTerra(double lat, double lon) {
    for (final p in _poligoni) {
      if (_dentro(lat, lon, p)) return true;
    }
    return false;
  }

  /// Punto dentro poligono, col metodo del raggio: si conta quante volte una
  /// semiretta orizzontale attraversa il contorno.
  static bool _dentro(double lat, double lon, List<List<double>> poli) {
    var dentro = false;
    for (var i = 0, j = poli.length - 1; i < poli.length; j = i++) {
      final xi = poli[i][0], yi = poli[i][1];
      final xj = poli[j][0], yj = poli[j][1];
      if ((yi > lat) != (yj > lat) &&
          lon < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
        dentro = !dentro;
      }
    }
    return dentro;
  }

  /// Ogni poligono e' una lista di coppie longitudine e latitudine.
  static const List<List<List<double>>> _poligoni = [
    // Nord America.
    [
      [-168, 66], [-140, 70], [-125, 71], [-100, 73], [-80, 74], [-62, 66],
      [-56, 52], [-66, 45], [-74, 40], [-81, 31], [-80, 25], [-90, 29],
      [-97, 26], [-105, 22], [-115, 30], [-125, 40], [-130, 55], [-152, 59],
      [-166, 62],
    ],
    // America Centrale, un ponte sottile.
    [
      [-92, 18], [-83, 15], [-77, 9], [-79, 8], [-86, 11], [-95, 16],
    ],
    // Sud America.
    [
      [-81, 6], [-73, 11], [-60, 11], [-51, 4], [-35, -5], [-39, -18],
      [-48, -25], [-58, -34], [-62, -41], [-66, -50], [-71, -54], [-73, -45],
      [-71, -30], [-70, -18], [-77, -6], [-80, 0],
    ],
    // Europa.
    [
      [-10, 44], [-9, 52], [0, 51], [5, 53], [10, 58], [18, 60], [25, 61],
      [30, 60], [40, 60], [40, 47], [28, 45], [20, 40], [12, 38], [3, 40],
      [-6, 37],
    ],
    // Isole britanniche.
    [
      [-8, 55], [-3, 59], [1, 53], [-3, 50], [-6, 51],
    ],
    // Scandinavia.
    [
      [5, 58], [12, 65], [20, 70], [30, 70], [24, 60], [12, 59],
    ],
    // Africa.
    [
      [-17, 21], [-16, 14], [-8, 5], [9, 4], [10, -1], [12, -6], [13, -17],
      [15, -28], [20, -35], [30, -31], [35, -22], [40, -15], [42, -2],
      [51, 12], [43, 12], [35, 23], [33, 31], [25, 32], [10, 37], [-6, 36],
      [-13, 28],
    ],
    // Madagascar.
    [
      [44, -12], [50, -15], [48, -25], [44, -20],
    ],
    // Asia.
    [
      [40, 47], [45, 60], [60, 70], [80, 76], [100, 78], [120, 74], [140, 73],
      [160, 70], [170, 66], [160, 60], [142, 54], [135, 45], [122, 40],
      [122, 31], [110, 21], [100, 13], [95, 16], [92, 22], [80, 8], [72, 20],
      [62, 25], [56, 27], [48, 30], [44, 38],
    ],
    // Arcipelago indonesiano, tre macchie.
    [
      [95, 5], [106, 0], [104, -6], [96, -2],
    ],
    [
      [108, 1], [118, 4], [117, -4], [110, -3],
    ],
    [
      [105, -6], [114, -8], [122, -9], [112, -8],
    ],
    // Giappone.
    [
      [130, 33], [140, 38], [145, 44], [141, 42], [134, 34],
    ],
    // Australia.
    [
      [113, -22], [122, -18], [130, -12], [137, -12], [142, -11], [146, -19],
      [153, -28], [150, -37], [141, -38], [131, -32], [118, -35], [114, -28],
    ],
    // Nuova Zelanda.
    [
      [172, -35], [178, -38], [174, -46], [168, -44], [170, -39],
    ],
    // Groenlandia.
    [
      [-55, 60], [-45, 60], [-20, 70], [-20, 82], [-40, 83], [-60, 78],
      [-58, 68],
    ],
    // Antartide: NON piu' una fascia da bordo a bordo. Nella proiezione
    // equirettangolare il polo si stira in una riga dritta che attraversa
    // tutto lo schermo, e a occhio non si legge come un continente, si legge
    // come un tratto rimasto li' per sbaglio. Ridotta a una calotta centrale
    // con i bordi rientrati, che e' meno fedele alla mappa ed e' molto piu'
    // fedele a cio' che l'occhio riconosce.
    [
      [-120, -73], [-60, -70], [0, -72], [60, -70], [120, -73],
      [140, -80], [60, -83], [0, -84], [-60, -83], [-140, -80],
    ],
  ];
}
