import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/astro/sky_catalog.dart';
import '../../core/astro/zodiac.dart';
import '../../design_system/theme/maestro_palette.dart';

/// La cartolina condivisibile del cielo, costruita apposta, non uno screenshot.
///
/// Disegna un widget fuori schermo (un canvas verticale ad alta risoluzione) e
/// lo esporta in PNG: il cielo di stanotte, la data, il marchio Esoteric Circle,
/// una riga poetica nella voce di Medora e un invito discreto. Nessun widget da
/// montare, tutto deterministico e testabile.
class SkyPostcard {
  const SkyPostcard._();

  static const double width = 1080;
  static const double height = 1920;

  static const List<String> _months = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];

  static const List<String> _poeticLines = [
    'Stanotte il cielo si china su di te e ti chiama per nome.',
    'Le stelle non decidono, ti accompagnano: ascolta, poi scegli.',
    'Ogni luce lassù è un ricordo che il buio custodisce per te.',
    'La Luna non ha fretta: stanotte nemmeno tu.',
    'Guarda in alto: il tuo cielo ti stava già aspettando.',
  ];

  static String formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static String poeticLine(DateTime now) {
    final doy = now.difference(DateTime(now.year)).inDays;
    return _poeticLines[doy % _poeticLines.length];
  }

  /// Testo precompilato per il foglio di condivisione, con hashtag.
  static String shareText(DateTime now) =>
      'Il mio cielo di stanotte, ${formatDate(now)}. '
      'Scopri il tuo con Esoteric Circle. '
      '#EsotericCircle #IlCieloSopraDiTe #astrologia #luna';

  /// Costruisce la cartolina e la esporta in PNG.
  static Future<Uint8List> render({
    required DateTime now,
    required MoonPhase moon,
    required List<Zodiac> high,
    required MaestroPalette palette,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));
    _paint(canvas, now, moon, high, palette);
    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    return data!.buffer.asUint8List();
  }

  static void _paint(Canvas canvas, DateTime now, MoonPhase moon,
      List<Zodiac> high, MaestroPalette palette) {
    const w = width, h = height;

    // Fondo profondo e verticale.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          const Offset(0, h),
          [
            palette.deepest,
            palette.backgroundGradient.length > 1
                ? palette.backgroundGradient[1]
                : palette.surface,
            palette.deepest,
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // Cornice dorata sottile.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(40, 40, w - 80, h - 80), const Radius.circular(36)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.gold.withValues(alpha: 0.5),
    );

    // Campo stellato.
    final rng = math.Random(now.year * 1000 + now.month * 40 + now.day);
    for (var i = 0; i < 220; i++) {
      final x = 60 + rng.nextDouble() * (w - 120);
      final y = 60 + rng.nextDouble() * (h - 120);
      final m = rng.nextDouble();
      canvas.drawCircle(
        Offset(x, y),
        0.6 + m * 2.2,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.25 + 0.6 * m),
      );
    }

    // Marchio in alto.
    _text(canvas, 'ESOTERIC CIRCLE', const Offset(w / 2, 130),
        _style(palette.goldSoft, 30, 'Cinzel', spacing: 8), align: TextAlign.center);
    _text(canvas, 'Il cielo sopra di te', const Offset(w / 2, 180),
        _style(palette.textPrimary, 64, 'Cinzel'), align: TextAlign.center);
    _text(canvas, formatDate(now), const Offset(w / 2, 280),
        _style(palette.goldSoft, 34, 'EBGaramond', spacing: 2), align: TextAlign.center);

    // La Luna, disco luminoso con la fase.
    const moonC = Offset(w / 2, 520);
    _drawMoon(canvas, moonC, 120, moon);
    _text(canvas, moon.italianName.toUpperCase(), const Offset(w / 2, 660),
        _style(palette.goldSoft, 28, 'Cinzel', spacing: 4), align: TextAlign.center);

    // Le costellazioni alte, immerse nel campo centrale.
    final slots = [
      const Offset(w * 0.26, 980),
      const Offset(w * 0.74, 940),
      const Offset(w * 0.5, 1180),
    ];
    for (var i = 0; i < high.length && i < slots.length; i++) {
      final fig = kZodiacAsterisms[high[i]]!;
      _drawAsterism(canvas, slots[i], 230, fig, palette);
      _text(canvas, high[i].italianName, Offset(slots[i].dx, slots[i].dy + 130),
          _style(palette.textSecondary, 26, 'Cinzel', spacing: 3),
          align: TextAlign.center);
    }

    // Riga poetica di Medora.
    _text(canvas, poeticLine(now), const Offset(w / 2, 1440),
        _style(palette.textPrimary, 40, 'EBGaramond', italic: true),
        align: TextAlign.center, maxWidth: w - 220);

    // Invito discreto in basso.
    _text(canvas, 'Scopri il tuo cielo', const Offset(w / 2, 1700),
        _style(palette.goldSoft, 34, 'Cinzel', spacing: 3), align: TextAlign.center);
    _text(canvas, 'esotericircle.com', const Offset(w / 2, 1760),
        _style(palette.textSecondary, 26, 'EBGaramond', spacing: 2),
        align: TextAlign.center);
  }

  static void _drawMoon(Canvas canvas, Offset c, double r, MoonPhase moon) {
    // Alone.
    canvas.drawCircle(
      c,
      r * 1.7,
      Paint()
        ..shader = ui.Gradient.radial(c, r * 1.7, [
          const Color(0xFFF4F1E8).withValues(alpha: 0.28),
          const Color(0x00000000),
        ]),
    );
    // Disco in ombra, tenue.
    canvas.drawCircle(
        c, r, Paint()..color = const Color(0xFFF4F1E8).withValues(alpha: 0.18));
    // Falcato illuminato.
    final f = moon.fraction;
    if (moon.illumination >= 0.02) {
      final rx = (math.cos(2 * math.pi * f)).abs() * r;
      final waxing = moon.waxing;
      final gibbous = moon.illumination > 0.5;
      final top = Offset(c.dx, c.dy - r);
      final bottom = Offset(c.dx, c.dy + r);
      final termClockwise = gibbous ? waxing : !waxing;
      final lit = Path()
        ..moveTo(top.dx, top.dy)
        ..arcToPoint(bottom, radius: Radius.circular(r), clockwise: waxing)
        ..arcToPoint(top,
            radius: Radius.elliptical(rx, r), clockwise: termClockwise)
        ..close();
      canvas.drawPath(
          lit,
          Paint()
            ..shader = ui.Gradient.radial(c, r, [
              const Color(0xFFFFFFFF),
              const Color(0xFFF4F1E8),
            ]));
    }
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFF4F1E8).withValues(alpha: 0.5),
    );
  }

  static void _drawAsterism(
      Canvas canvas, Offset center, double box, Asterism fig, MaestroPalette palette) {
    Offset map(Offset p) =>
        center + Offset((p.dx - 0.5) * box, (p.dy - 0.5) * box);
    final pts = fig.stars.map(map).toList();
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.55);
    for (final (a, b) in fig.lines) {
      canvas.drawLine(pts[a], pts[b], line);
    }
    for (var i = 0; i < pts.length; i++) {
      final m = fig.mag[i];
      canvas.drawCircle(pts[i], 2.5 + m * 3.5,
          Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6 + 0.4 * m));
    }
  }

  static TextStyle _style(Color color, double size, String family,
      {double spacing = 0, bool italic = false}) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontFamily: family,
      letterSpacing: spacing,
      height: 1.25,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
  }

  static void _text(Canvas canvas, String s, Offset center, TextStyle style,
      {TextAlign align = TextAlign.left, double? maxWidth}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? width);
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy));
  }
}
