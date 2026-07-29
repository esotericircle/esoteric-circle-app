import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/motion/parallax_controller.dart';
import '../../design_system/theme/maestro_palette.dart';

/// Il planisfero a punti: la mappa del mondo resa come una costellazione.
///
/// Sostituisce il cerchio anonimo della schermata del luogo. Non il logo:
/// mettere il proprio marchio nel punto in cui si chiede alla persona dove e'
/// nata sarebbe parlare di se' mentre si sta ascoltando.
///
/// Come nasce la sagoma. Nessun asset e nessuna rete: i continenti sono
/// descritti da pochi poligoni in gradi veri di latitudine e longitudine, e i
/// punti nascono dove una griglia regolare cade dentro un poligono. Sono
/// contorni grossolani, dichiarati tali: servono a far riconoscere il mondo
/// con la coda dell'occhio, non a misurare confini.
///
/// La proiezione e' equirettangolare, la piu' semplice che esista: la
/// longitudine diventa la x e la latitudine la y, con una formula diretta.
/// E' quella che permette di accendere la stella del luogo scelto nel punto
/// giusto senza inseguire matematiche di proiezione.
class Planisfero extends StatefulWidget {
  const Planisfero({
    super.key,
    required this.palette,
    this.luogo,
    this.reduceMotion = false,
  });

  final MaestroPalette palette;

  /// Il luogo scelto, in gradi. Null finche' non si sceglie.
  final ({double lat, double lon})? luogo;

  final bool reduceMotion;

  /// Quanto e' fitta la griglia dei punti.
  static const int colonne = 84;
  static const int righe = 40;

  /// Da gradi a coordinate normalizzate 0..1 sulla mappa.
  static Offset proietta(double lat, double lon) => Offset(
        (lon + 180) / 360,
        (90 - lat) / 180,
      );

  @override
  State<Planisfero> createState() => _PlanisferoState();
}

class _PlanisferoState extends State<Planisfero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulsare;

  /// I punti di terra, calcolati una volta sola: la griglia non cambia mai,
  /// e rifare il conto a ogni fotogramma sarebbe uno spreco.
  late final List<Offset> _terra;

  @override
  void initState() {
    super.initState();
    _terra = _puntiDiTerra();
    _pulsare = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (!widget.reduceMotion) _pulsare.repeat();
  }

  @override
  void dispose() {
    _pulsare.dispose();
    super.dispose();
  }

  static List<Offset> _puntiDiTerra() {
    final out = <Offset>[];
    for (var r = 0; r < Planisfero.righe; r++) {
      for (var c = 0; c < Planisfero.colonne; c++) {
        // Il centro della cella, in gradi.
        final lon = -180 + (c + 0.5) * 360 / Planisfero.colonne;
        final lat = 90 - (r + 0.5) * 180 / Planisfero.righe;
        if (_MondoGrezzo.eTerra(lat, lon)) {
          out.add(Planisfero.proietta(lat, lon));
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    // Il giroscopio, come il resto della scena. Lettura tollerante: senza
    // provider il planisfero resta fermo invece di rompersi.
    final parallax = context.watch<ParallaxController?>();
    final deriva = widget.reduceMotion || parallax == null
        ? Offset.zero
        : Offset(parallax.tiltX * 8, parallax.tiltY * 5);

    return AnimatedBuilder(
      animation: _pulsare,
      builder: (context, _) => CustomPaint(
        painter: _PlanisferoPainter(
          terra: _terra,
          palette: widget.palette,
          t: widget.reduceMotion ? 0 : _pulsare.value,
          luogo: widget.luogo == null
              ? null
              : Planisfero.proietta(widget.luogo!.lat, widget.luogo!.lon),
          deriva: deriva,
        ),
      ),
    );
  }
}

class _PlanisferoPainter extends CustomPainter {
  _PlanisferoPainter({
    required this.terra,
    required this.palette,
    required this.t,
    required this.deriva,
    this.luogo,
  });

  final List<Offset> terra;
  final MaestroPalette palette;
  final double t;
  final Offset deriva;
  final Offset? luogo;

  @override
  void paint(Canvas canvas, Size size) {
    // La mappa sta al centro, con le proporzioni giuste: due a uno, che e'
    // quello che vuole una proiezione equirettangolare.
    final larghezza = math.min(size.width, size.height * 2);
    final altezza = larghezza / 2;
    final origine = Offset(
      (size.width - larghezza) / 2,
      (size.height - altezza) / 2,
    );

    Offset suSchermo(Offset p) =>
        origine + Offset(p.dx * larghezza, p.dy * altezza) + deriva;

    // I punti di terra. Ognuno pulsa col suo tempo, cosi' non lampeggiano
    // tutti insieme come un'insegna: si accendono pochi per volta, a caso.
    final base = Paint()..color = palette.goldSoft.withValues(alpha: 0.28);
    for (var i = 0; i < terra.length; i++) {
      final p = suSchermo(terra[i]);
      // Sfasamento deterministico per punto: sempre lo stesso disegno.
      final fase = (i * 0.6180339887) % 1.0;
      final onda = 0.5 + 0.5 * math.sin(2 * math.pi * (t + fase));
      // Solo una minoranza brilla forte in ogni istante.
      final acceso = math.pow(onda, 6).toDouble();
      final r = 0.9 + 0.9 * acceso;
      canvas.drawCircle(
        p,
        r,
        acceso > 0.15
            ? (Paint()
              ..color = palette.goldSoft
                  .withValues(alpha: 0.30 + 0.60 * acceso))
            : base,
      );
    }

    // La stella del luogo scelto: piu' grande, con l'alone, e con un piccolo
    // cerchio che la circonda perche' si trovi a colpo d'occhio.
    final l = luogo;
    if (l != null) {
      final p = suSchermo(l);
      final respiro = 0.5 + 0.5 * math.sin(2 * math.pi * t * 2);

      canvas.drawCircle(
        p,
        16 + 4 * respiro,
        Paint()
          ..shader = RadialGradient(colors: [
            palette.goldSoft.withValues(alpha: 0.55),
            palette.goldSoft.withValues(alpha: 0.0),
          ]).createShader(Rect.fromCircle(center: p, radius: 16 + 4 * respiro)),
      );
      canvas.drawCircle(p, 3.4, Paint()..color = palette.goldSoft);
      // I quattro raggi corti: una stella, non un puntino grosso.
      final raggio = Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = palette.goldSoft.withValues(alpha: 0.9);
      for (var i = 0; i < 4; i++) {
        final a = i * math.pi / 2;
        final d = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(p + d * 5, p + d * (9 + 2 * respiro), raggio);
      }
    }
  }

  @override
  bool shouldRepaint(_PlanisferoPainter old) =>
      old.t != t || old.luogo != luogo || old.deriva != deriva;
}

/// La forma del mondo, ridotta all'osso.
///
/// Poligoni grossolani in gradi veri: bastano a far riconoscere i continenti a
/// colpo d'occhio, e nessuno ci misurera' un confine. Sono scritti qui e non
/// caricati da un file perche' un asset di contorni costa piu' peso di quanto
/// serva a una silhouette di punti.
class _MondoGrezzo {
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
    // Antartide, una fascia bassa.
    [
      [-180, -70], [180, -70], [180, -85], [-180, -85],
    ],
  ];
}
