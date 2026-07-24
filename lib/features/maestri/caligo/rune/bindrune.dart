import 'package:flutter/material.dart';

import '../../../rituals/rune_strokes.dart';

/// Il sigillo del giorno: una bindrune, un glifo unico che intreccia le rune
/// uscite sovrapponendone i tratti su un'asta centrale condivisa, in oro. E'
/// deterministico dalle rune della gettata, nessuna casualita' nel disegno.
class BindruneSigillo extends StatelessWidget {
  const BindruneSigillo({
    super.key,
    required this.runeNames,
    required this.oro,
    this.alone,
    this.lato = 150,
  });

  /// I nomi delle rune da intrecciare, nell'ordine di lettura.
  final List<String> runeNames;

  /// L'oro dei tratti e dell'asta.
  final Color oro;

  /// Un secondo tono d'oro per l'alone, oppure [oro] se assente.
  final Color? alone;

  final double lato;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('bindrune'),
      width: lato,
      height: lato,
      child: CustomPaint(
        painter: _BindrunePainter(
          runeNames: runeNames,
          oro: oro,
          alone: alone ?? oro,
        ),
      ),
    );
  }
}

class _BindrunePainter extends CustomPainter {
  _BindrunePainter({
    required this.runeNames,
    required this.oro,
    required this.alone,
  });

  final List<String> runeNames;
  final Color oro;
  final Color alone;

  @override
  void paint(Canvas canvas, Size size) {
    final box = size.shortestSide * 0.74;
    final left = (size.width - box) / 2;
    final top = (size.height - box) / 2;
    Offset map(Offset p) => Offset(left + p.dx * box, top + p.dy * box);

    // Alone tondo dietro il sigillo, per staccarlo dal fondo.
    canvas.drawCircle(
      size.center(Offset.zero),
      box * 0.62,
      Paint()
        ..shader = RadialGradient(colors: [
          alone.withValues(alpha: 0.22),
          alone.withValues(alpha: 0.0),
        ]).createShader(
            Rect.fromCircle(center: size.center(Offset.zero), radius: box * 0.62)),
    );

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = alone.withValues(alpha: 0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.04);

    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = oro;

    // I tratti di ogni runa, centrati orizzontalmente sull'asta condivisa.
    for (final name in runeNames) {
      final strokes = kRuneStrokes[name];
      if (strokes == null) continue;
      var minX = 1.0;
      var maxX = 0.0;
      for (final poly in strokes) {
        for (final p in poly) {
          if (p.dx < minX) minX = p.dx;
          if (p.dx > maxX) maxX = p.dx;
        }
      }
      final shift = 0.5 - (minX + maxX) / 2;
      for (final poly in strokes) {
        final path = Path()
          ..moveTo(map(poly.first.translate(shift, 0)).dx,
              map(poly.first.translate(shift, 0)).dy);
        for (var i = 1; i < poly.length; i++) {
          final p = map(poly[i].translate(shift, 0));
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, glow);
        canvas.drawPath(path, tratto);
      }
    }

    // L'asta centrale condivisa, sopra tutto, che unisce l'intreccio.
    final asta = Path()
      ..moveTo(map(const Offset(0.5, 0.02)).dx, map(const Offset(0.5, 0.02)).dy)
      ..lineTo(map(const Offset(0.5, 0.98)).dx, map(const Offset(0.5, 0.98)).dy);
    canvas.drawPath(
        asta,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = box * 0.06
          ..strokeCap = StrokeCap.round
          ..color = alone.withValues(alpha: 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.03));
    canvas.drawPath(
        asta,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = box * 0.045
          ..strokeCap = StrokeCap.round
          ..color = oro);
  }

  @override
  bool shouldRepaint(_BindrunePainter old) =>
      old.runeNames != runeNames || old.oro != oro || old.alone != alone;
}
