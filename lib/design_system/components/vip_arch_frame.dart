import 'dart:typed_data';

import 'package:flutter/material.dart';

/// La silhouette ad arco dei ritratti VIP, ricostruita a vettori. Un arco
/// romanico: fianchi dritti, spalla, sommita' tondeggiante, angoli bassi
/// arrotondati. [inset] rientra il bordo verso l'interno.
Path buildVipArchPath(Size s, [double inset = 0]) {
  final l = inset;
  final r = s.width - inset;
  final top = inset;
  final bot = s.height - inset;
  final cx = (l + r) / 2;
  final shoulder = top + (bot - top) * 0.42;
  final rb = (r - l) * 0.12; // raggio degli angoli bassi
  final path = Path()
    ..moveTo(l, bot - rb)
    ..lineTo(l, shoulder)
    ..quadraticBezierTo(l, top, cx, top)
    ..quadraticBezierTo(r, top, r, shoulder)
    ..lineTo(r, bot - rb)
    ..quadraticBezierTo(r, bot, r - rb, bot)
    ..lineTo(l + rb, bot)
    ..quadraticBezierTo(l, bot, l, bot - rb)
    ..close();
  return path;
}

/// Cornice ad arco oro e blu di Medora, ricostruita a vettori quando non esiste
/// un asset di cornice separato. Incornicia un [child] gia' ritagliato all'arco,
/// con un doppio filo d'oro, un accento blu profondo e un alone caldo.
class VipArchFrame extends StatelessWidget {
  const VipArchFrame({
    super.key,
    required this.child,
    required this.gold,
    required this.goldSoft,
    required this.blue,
    this.borderWidth = 4,
  });

  final Widget child;
  final Color gold;
  final Color goldSoft;

  /// Il blu profondo di Medora, per l'accento interno della cornice.
  final Color blue;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            // Il contenuto, ritagliato dentro l'arco, sotto la cornice.
            ClipPath(
              clipper: _ArchClipper(inset: borderWidth * 0.6),
              child: child,
            ),
            // La cornice a vettori, sopra.
            CustomPaint(
              painter: _ArchFramePainter(
                size: size,
                gold: gold,
                goldSoft: goldSoft,
                blue: blue,
                borderWidth: borderWidth,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArchClipper extends CustomClipper<Path> {
  const _ArchClipper({required this.inset});
  final double inset;

  @override
  Path getClip(Size size) => buildVipArchPath(size, inset);

  @override
  bool shouldReclip(_ArchClipper old) => old.inset != inset;
}

class _ArchFramePainter extends CustomPainter {
  _ArchFramePainter({
    required this.size,
    required this.gold,
    required this.goldSoft,
    required this.blue,
    required this.borderWidth,
  });

  final Size size;
  final Color gold;
  final Color goldSoft;
  final Color blue;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size s) {
    final outer = buildVipArchPath(s, borderWidth * 0.5);
    final inner = buildVipArchPath(s, borderWidth * 1.6);

    // Accento blu profondo appena dentro il filo d'oro.
    canvas.drawPath(
      buildVipArchPath(s, borderWidth * 1.1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 0.9
        ..color = blue.withValues(alpha: 0.85),
    );

    // Filo d'oro esterno, con un lieve gradiente per dare metallo.
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [goldSoft, gold, goldSoft],
        ).createShader(Offset.zero & s),
    );

    // Filo d'oro interno sottile.
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 0.4
        ..color = goldSoft.withValues(alpha: 0.7),
    );

    // Vignettatura interna: scurisce appena i bordi per dare profondita' e
    // fondere la foto coi ritratti incisi.
    canvas.save();
    canvas.clipPath(inner);
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = RadialGradient(
          radius: 0.9,
          colors: [Colors.transparent, blue.withValues(alpha: 0.28)],
          stops: const [0.62, 1.0],
        ).createShader(Offset.zero & s),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArchFramePainter old) =>
      old.gold != gold ||
      old.goldSoft != goldSoft ||
      old.blue != blue ||
      old.borderWidth != borderWidth;
}

/// La foto dell'utente armonizzata coi ritratti VIP illustrati: un filtro caldo
/// e leggermente desaturato piu' un velo dorato e cosmico. La foto resta in
/// memoria, non lascia il dispositivo.
class GoldenCosmicPhoto extends StatelessWidget {
  const GoldenCosmicPhoto({
    super.key,
    required this.bytes,
    required this.gold,
    required this.blue,
  });

  final Uint8List bytes;
  final Color gold;
  final Color blue;

  // Matrice calda e leggera: alza il rosso, tiene il verde, abbassa un poco il
  // blu, con una lieve desaturazione, cosi' il volto vira all'oro senza
  // diventare seppia pieno.
  static const List<double> _warmMatrix = <double>[
    0.92, 0.10, 0.04, 0, 6, //
    0.05, 0.90, 0.05, 0, 3, //
    0.03, 0.08, 0.80, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // Velo dorato in alto, blu cosmico in basso, fuso in morbido.
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gold.withValues(alpha: 0.30),
            Colors.transparent,
            blue.withValues(alpha: 0.34),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        backgroundBlendMode: BlendMode.softLight,
      ),
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(_warmMatrix),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
