import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/astro/sky_catalog.dart';
import '../../core/astro/zodiac.dart';
import '../../core/brand/brand.dart';
import '../../design_system/theme/maestro_palette.dart';

/// Formato della cartolina: verticale per le Storie, quadrato per il feed.
enum PostcardFormat {
  story(1080, 1920, 'Storia'),
  feed(1080, 1080, 'Feed');

  const PostcardFormat(this.width, this.height, this.label);

  final double width;
  final double height;
  final String label;
}

/// La cartolina condivisibile del cielo, costruita apposta, non uno screenshot.
///
/// Disegna un canvas fuori schermo ad alta risoluzione e lo esporta in PNG: il
/// cielo (Luna nella fase e costellazioni con le forme corrette), la data, il
/// marchio, una riga poetica nella voce di Medora e un invito discreto. Il
/// layout si adatta al formato: verticale 1080x1920 per le Storie, quadrato
/// 1080x1080 per il feed. Nessun widget da montare, tutto deterministico.
class SkyPostcard {
  const SkyPostcard._();

  static const List<String> _months = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];

  static const List<String> _poeticLines = [
    'Stanotte il cielo si china su di te e ti chiama per nome.',
    'Le stelle non decidono, ti accompagnano: ascolta, poi scegli.',
    'Ogni luce lassù è un ricordo che il buio custodisce per te.',
    'La Luna non ha fretta: stanotte nemmeno tu.',
    'Guarda in alto: il tuo cielo ti stava già aspettando.',
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
      'Scopri il tuo con ${Brand.name}. '
      '#EsotericCircle #IlCieloSopraDiTe #astrologia #luna';

  /// Titolo mostrato in cartolina: cielo di adesso o cielo di nascita.
  static String titleFor({required bool birth}) =>
      birth ? 'Il tuo cielo di nascita' : 'Il cielo sopra di te';

  /// Costruisce la cartolina nel formato scelto e la esporta in PNG.
  static Future<Uint8List> render({
    required DateTime now,
    required MoonPhase moon,
    required List<Zodiac> high,
    required MaestroPalette palette,
    PostcardFormat format = PostcardFormat.story,
    bool birth = false,
  }) async {
    final size = Size(format.width, format.height);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & size);
    _paint(canvas, size, now, moon, high, palette, birth);
    final picture = recorder.endRecording();
    final image =
        await picture.toImage(format.width.toInt(), format.height.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    return data!.buffer.asUint8List();
  }

  static void _paint(Canvas canvas, Size size, DateTime now, MoonPhase moon,
      List<Zodiac> high, MaestroPalette palette, bool birth) {
    final w = size.width, h = size.height;
    final s = h / 1920.0; // scala tipografica rispetto al verticale
    double fy(double f) => f * h; // posizione verticale come frazione

    // Fondo profondo.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, h),
          [
            palette.deepest,
            palette.backgroundGradient.length > 1
                ? palette.backgroundGradient[1]
                : palette.surface,
            palette.deepest,
          ],
          const [0.0, 0.5, 1.0],
        ),
    );

    // Cornice dorata sottile.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(40, 40, w - 80, h - 80), const Radius.circular(36)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.gold.withValues(alpha: 0.5),
    );

    // Campo stellato, densita' proporzionale all'area.
    final count = (w * h / 9000).round();
    final rng = math.Random(now.year * 1000 + now.month * 40 + now.day);
    for (var i = 0; i < count; i++) {
      final x = 60 + rng.nextDouble() * (w - 120);
      final y = 60 + rng.nextDouble() * (h - 120);
      final m = rng.nextDouble();
      canvas.drawCircle(
        Offset(x, y),
        0.6 + m * 2.2,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.25 + 0.6 * m),
      );
    }

    // Marchio, titolo, data.
    _text(canvas, Brand.name.toUpperCase(), Offset(w / 2, fy(0.065)),
        _style(palette.goldSoft, 30 * s, 'Cinzel', spacing: 8 * s),
        align: TextAlign.center);
    _text(canvas, titleFor(birth: birth), Offset(w / 2, fy(0.095)),
        _style(palette.textPrimary, 60 * s, 'Cinzel'), align: TextAlign.center);
    _text(canvas, formatDate(now), Offset(w / 2, fy(0.155)),
        _style(palette.goldSoft, 34 * s, 'EBGaramond', spacing: 2 * s),
        align: TextAlign.center);

    // La Luna con la sua fase.
    final moonR = h * 0.062;
    final moonC = Offset(w / 2, fy(0.29));
    _drawMoon(canvas, moonC, moonR, moon);
    _text(canvas, moon.italianName.toUpperCase(), Offset(w / 2, fy(0.365)),
        _style(palette.goldSoft, 28 * s, 'Cinzel', spacing: 4 * s),
        align: TextAlign.center);

    // Le costellazioni alte, immerse nel campo centrale.
    final box = h * 0.12;
    final slots = [
      Offset(w * 0.26, fy(0.53)),
      Offset(w * 0.74, fy(0.5)),
      Offset(w * 0.5, fy(0.64)),
    ];
    for (var i = 0; i < high.length && i < slots.length; i++) {
      final fig = kZodiacAsterisms[high[i]]!;
      _drawAsterism(canvas, slots[i], box, fig, palette);
      _text(canvas, high[i].italianName,
          Offset(slots[i].dx, slots[i].dy + box * 0.62),
          _style(palette.textSecondary, 26 * s, 'Cinzel', spacing: 3 * s),
          align: TextAlign.center);
    }

    // Riga poetica di Medora.
    _text(canvas, poeticLine(now), Offset(w / 2, fy(0.78)),
        _style(palette.textPrimary, 40 * s, 'EBGaramond', italic: true),
        align: TextAlign.center, maxWidth: w - 220 * s);

    // Invito discreto in basso.
    _text(canvas, 'Scopri il tuo cielo', Offset(w / 2, fy(0.9)),
        _style(palette.goldSoft, 34 * s, 'Cinzel', spacing: 3 * s),
        align: TextAlign.center);
    _text(canvas, Brand.domain, Offset(w / 2, fy(0.935)),
        _style(palette.textSecondary, 26 * s, 'EBGaramond', spacing: 2 * s),
        align: TextAlign.center);
  }

  static void _drawMoon(Canvas canvas, Offset c, double r, MoonPhase moon) {
    canvas.drawCircle(
      c,
      r * 1.7,
      Paint()
        ..shader = ui.Gradient.radial(c, r * 1.7, [
          const Color(0xFFF4F1E8).withValues(alpha: 0.28),
          const Color(0x00000000),
        ]),
    );
    canvas.drawCircle(
        c, r, Paint()..color = const Color(0xFFF4F1E8).withValues(alpha: 0.18));
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

  static void _drawAsterism(Canvas canvas, Offset center, double box,
      Asterism fig, MaestroPalette palette) {
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
    )..layout(maxWidth: maxWidth ?? 2000);
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy));
  }
}
