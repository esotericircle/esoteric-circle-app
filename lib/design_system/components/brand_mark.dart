import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Il marchio di Esoteric Circle, in un punto solo.
///
/// Finche' il logo vero non c'e' si mostra il sigillo provvisorio disegnato a
/// vettori. Quando Mauro consegna il logo, si cambia SOLO [logoAsset] con il
/// percorso dell'asset (e lo si dichiara nel pubspec): card, app e ogni altro
/// punto lo prendono da qui, senza toccare altro codice.
class BrandMark {
  const BrandMark._();

  /// Unico punto del logo. Vuoto finche' il logo vero non e' stato consegnato:
  /// quando arriva basta mettere qui il percorso, per esempio
  /// 'brand_assets/logo/esoteric_circle.webp', e dichiararlo nel pubspec.
  static const String logoAsset = '';

  static bool get hasLogo => logoAsset.isNotEmpty;

  /// Il nome del marchio, per il watermark.
  static const String wordmark = 'ESOTERIC CIRCLE';
}

/// Il marchio da mostrare: il logo vero se c'e', altrimenti il sigillo
/// provvisorio. Un solo widget per tutta l'app.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 44, this.color});

  final double size;

  /// Tinta del sigillo provvisorio. Il logo vero non viene ricolorato.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (BrandMark.hasLogo) {
      return Image.asset(BrandMark.logoAsset,
          width: size, height: size, fit: BoxFit.contain);
    }
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SealPainter(color: color ?? const Color(0xFFE9C46A)),
      ),
    );
  }
}

/// Il sigillo provvisorio: un medaglione dorato con la stella a otto punte.
class _SealPainter extends CustomPainter {
  _SealPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.46;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.06
          ..color = color);
    final star = Paint()..color = color;
    for (var k = 0; k < 8; k++) {
      final a = k * math.pi / 4;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r * 0.62,
          size.shortestSide * 0.03, star);
    }
    canvas.drawCircle(c, size.shortestSide * 0.1, star);
  }

  @override
  bool shouldRepaint(_SealPainter old) => old.color != color;
}
