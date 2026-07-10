import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/astro/birth_details.dart';
import '../../core/astro/sky.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/identity_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../core/quality/quality_tier.dart';
import '../../design_system/components/moon_phase_emblem.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Momento eroe del cielo reale della nascita, subito prima del colpo d'occhio.
///
/// Dai dati di nascita calcola e disegna il cielo autentico di quel momento: le
/// costellazioni nelle loro posizioni vere viste da quel luogo, la Luna nella
/// sua fase reale. Il cielo si muove in parallasse (giroscopio con fallback allo
/// scorrimento del dito) e le stelle pulsano. Se manca l'ora, usa la notte
/// simbolica del giorno e lo dice con garbo. Regolato dal Quality Tier.
class BirthSkyHero extends StatefulWidget {
  const BirthSkyHero({
    super.key,
    required this.details,
    required this.onContinue,
    this.ctaLabel = 'Leggi la tua carta',
  });

  final BirthDetails details;
  final VoidCallback onContinue;

  /// Testo del pulsante finale: "Leggi la tua carta" nell'onboarding, oppure
  /// "Torna alla carta" quando il cielo si riapre dal portale.
  final String ctaLabel;

  @override
  State<BirthSkyHero> createState() => _BirthSkyHeroState();
}

class _BirthSkyHeroState extends State<BirthSkyHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final ParallaxController _parallax = ParallaxController();
  SkySnapshot? _snapshot;
  double _dragAz = 0; // pan manuale in gradi (fallback tattile)
  bool _showCaption = false;
  Timer? _captionTimer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(seconds: 24))
      ..repeat();
    _load();
  }

  Future<void> _load() async {
    final catalog = await SkyCatalog.load();
    if (!mounted) return;
    setState(() => _snapshot = buildSkySnapshot(catalog, widget.details));
    HapticFeedback.selectionClick(); // il cielo si apre
    // La didascalia arriva con dolcezza dopo lo stupore.
    _captionTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _showCaption = true);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _parallax.dispose();
    _captionTimer?.cancel();
    super.dispose();
  }

  void _onPan(DragUpdateDetails d) {
    setState(() => _dragAz = (_dragAz - d.delta.dx * 0.20).clamp(-70.0, 70.0));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final identity = context.watch<IdentityController>();
    final tier = context.watch<QualityTierController>().tier;
    final snap = _snapshot;

    final born = identity.pick(
      masculine: 'Questo e\' il cielo della notte in cui sei nato.',
      feminine: 'Questo e\' il cielo della notte in cui sei nata.',
      neutral: 'Questo e\' il cielo della notte della tua nascita.',
    );

    return GestureDetector(
      onPanUpdate: _onPan,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (snap == null)
            Center(
              child: Text('Sto aprendo il tuo cielo...',
                  style: TypographyTokens.body(size: TypographyTokens.guide)
                      .copyWith(color: ColorTokens.textSecondary)),
            )
          else
            AnimatedBuilder(
              animation: Listenable.merge([_pulse, _parallax]),
              builder: (context, _) => CustomPaint(
                painter: _SkyPainter(
                  snapshot: snap,
                  t: _pulse.value,
                  panAz: _dragAz + (tier == QualityTier.low ? 0 : _parallax.tiltX * 16),
                  tiltY: tier == QualityTier.low ? 0 : _parallax.tiltY,
                  gold: palette.goldSoft,
                  deep: palette.deepest,
                  tier: tier,
                ),
              ),
            ),
          // Testo veritiero in alto.
          Positioned(
            top: SpacingTokens.xl,
            left: SpacingTokens.lg,
            right: SpacingTokens.lg,
            child: Column(
              children: [
                Text('IL CIELO AUTENTICO',
                    style: TypographyTokens.label(size: 13)
                        .copyWith(color: palette.goldSoft, letterSpacing: 3)),
                const SizedBox(height: SpacingTokens.sm),
                Text(born,
                    textAlign: TextAlign.center,
                    style: TypographyTokens.display(size: 24)
                        .copyWith(height: 1.25)),
                if (snap != null && !snap.hasTime) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  Text('Manca l\'ora esatta: e\' la notte simbolica del tuo giorno.',
                      textAlign: TextAlign.center,
                      style: TypographyTokens.body(size: TypographyTokens.guide)
                          .copyWith(
                              color: ColorTokens.textSecondary, height: 1.4)),
                ],
              ],
            ),
          ),
          // Invito a proseguire in basso, sul proprio piano scuro, staccato
          // dalla culla da un velo che dona respiro e leggibilita'.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  SpacingTokens.lg,
                  SpacingTokens.xl,
                  SpacingTokens.lg,
                  SpacingTokens.xl + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.deepest.withValues(alpha: 0),
                    palette.deepest.withValues(alpha: 0.72),
                    palette.deepest.withValues(alpha: 0.92),
                  ],
                  stops: const [0, 0.35, 1],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Didascalia vera del cielo, dai dati reali di quel momento.
                  if (snap != null)
                    GestureDetector(
                      onTap: () => setState(() => _showCaption = !_showCaption),
                      child: AnimatedOpacity(
                        opacity: _showCaption ? 1 : 0,
                        duration: const Duration(milliseconds: 700),
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: SpacingTokens.lg),
                          padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.md,
                              vertical: SpacingTokens.sm),
                          decoration: BoxDecoration(
                            color: palette.surface.withValues(alpha: 0.42),
                            borderRadius:
                                BorderRadius.circular(SpacingTokens.radiusLg),
                            border: Border.all(
                                color: palette.gold.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            _skyCaption(snap, widget.details),
                            textAlign: TextAlign.center,
                            style: TypographyTokens.body(size: 16).copyWith(
                                color: ColorTokens.textPrimary, height: 1.4),
                          ),
                        ),
                      ),
                    ),
                  // La riga d'aiuto, staccata dal pulsante, mai sopra la culla.
                  Text(
                    _parallax.sensorActive
                        ? 'Inclina il telefono per guardarti attorno'
                        : 'Trascina il dito per guardarti attorno',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textMuted),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.gold,
                        foregroundColor: palette.deepest,
                        padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusPill),
                        ),
                      ),
                      onPressed: snap == null ? null : widget.onContinue,
                      child: Text(widget.ctaLabel,
                          style: TypographyTokens.body(size: 17, weight: 600)
                              .copyWith(color: palette.deepest)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter({
    required this.snapshot,
    required this.t,
    required this.panAz,
    required this.tiltY,
    required this.gold,
    required this.deep,
    required this.tier,
  });

  final SkySnapshot snapshot;
  final double t;
  final double panAz;
  final double tiltY;
  final Color gold;
  final Color deep;
  final QualityTier tier;

  static const double _fov = 150; // campo visivo orizzontale in gradi
  // L'orizzonte, e con lui la culla, stanno piu' in alto: sotto resta un
  // respiro di cielo scuro per la didascalia, la riga d'aiuto e il pulsante,
  // che non si accavallano piu' con la culla.
  static const double _horizonFrac = 0.70;
  bool get _rich => tier == QualityTier.high;

  double _normDelta(double d) {
    var v = d % 360.0;
    if (v > 180) v -= 360;
    if (v < -180) v += 360;
    return v;
  }

  /// Proietta (azimut, altezza) su schermo. Ritorna null se fuori dal campo.
  Offset? _project(double azDeg, double altDeg, Size size, {double depth = 1}) {
    final delta = _normDelta(azDeg - (snapshot.centerAzDeg + panAz * depth));
    if (delta.abs() > _fov / 2 + 6) return null;
    final x = size.width / 2 + (delta / (_fov / 2)) * (size.width / 2);
    final alt = altDeg.clamp(-6.0, 80.0);
    final y = size.height * _horizonFrac -
        (alt / 78.0) * (size.height * 0.60) +
        tiltY * 16 * depth;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Velo notturno e bagliore d'orizzonte.
    final horizonY = size.height * _horizonFrac;
    if (_rich) {
      canvas.drawRect(
          Rect.fromLTWH(0, horizonY - 40, size.width, size.height - horizonY + 40),
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, gold.withValues(alpha: 0.06)],
            ).createShader(Rect.fromLTWH(
                0, horizonY - 40, size.width, size.height - horizonY + 40)));
    }

    // Stelle di sfondo (polvere), regolate dal tier.
    _dustField(canvas, size);

    // Costellazioni.
    for (final con in snapshot.constellations) {
      final pts = <int, Offset>{};
      for (var i = 0; i < con.stars.length; i++) {
        final s = con.stars[i];
        if (s.altDeg < -4) continue;
        final depth = 1 + (2.0 - s.mag).clamp(0.0, 3.0) * 0.03; // 2.5D lieve
        final p = _project(s.azDeg, s.altDeg, size, depth: depth);
        if (p != null) pts[i] = p;
      }
      // Linee.
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = gold.withValues(alpha: 0.28);
      for (final l in con.lines) {
        final a = pts[l[0]], b = pts[l[1]];
        if (a != null && b != null) canvas.drawLine(a, b, linePaint);
      }
      // Stelle pulsanti.
      for (final entry in pts.entries) {
        final s = con.stars[entry.key];
        _star(canvas, entry.value, s.mag, entry.key);
      }
    }

    // La Luna, nella sua fase reale.
    final moon = snapshot.moon;
    if (moon != null && moon.altDeg > -3) {
      final p = _project(moon.azDeg, moon.altDeg, size, depth: 1.18);
      if (p != null) _moon(canvas, p, size.width * 0.055);
    }

    // Ancoraggio a terra: orizzonte discreto e culla di luce.
    _horizonAndCradle(canvas, size);
  }

  void _horizonAndCradle(Canvas canvas, Size size) {
    final hY = size.height * _horizonFrac;

    // Terra scura, appena accennata.
    canvas.drawRect(
        Rect.fromLTWH(0, hY, size.width, size.height - hY),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              deep.withValues(alpha: 0.35),
              deep.withValues(alpha: 0.85),
            ],
          ).createShader(Rect.fromLTWH(0, hY, size.width, size.height - hY)));
    // Linea d'orizzonte luminosa.
    if (_rich) {
      canvas.drawLine(
          Offset(0, hY),
          Offset(size.width, hY),
          Paint()
            ..color = gold.withValues(alpha: 0.22)
            ..strokeWidth = 3
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    canvas.drawLine(
        Offset(0, hY),
        Offset(size.width, hY),
        Paint()
          ..color = gold.withValues(alpha: 0.35)
          ..strokeWidth = 1);

    _cradle(canvas, size.width / 2, hY, size.width * 0.185);
  }

  // La culla di luce: una culla vera e riconoscibile, la conca che accoglie e i
  // due dondoli curvi sotto, appoggiata sull'orizzonte. Dentro, un piccolo
  // bagliore che pulsa piano: l'anima appena nata sotto il suo cielo. Nessun
  // volto ne' genere.
  void _cradle(Canvas canvas, double cx, double cy, double w) {
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi * 5); // respiro lento
    // La culla poggia sull'orizzonte: il bordo superiore sta appena sopra.
    final rimY = cy - w * 0.34;
    final soul = Offset(cx, rimY - w * 0.06);

    // Il bagliore dell'anima, dentro la conca.
    if (_rich) {
      canvas.drawCircle(
          soul,
          w * (0.40 + 0.13 * pulse),
          Paint()
            ..color = gold.withValues(alpha: 0.22 + 0.26 * pulse)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    }
    canvas.drawCircle(
        soul,
        w * 0.13 * (0.9 + 0.18 * pulse),
        Paint()..color = Colors.white.withValues(alpha: 0.9));

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = gold.withValues(alpha: 0.85);

    // La conca della culla: pareti che si alzano ai lati e fondo tondo, come un
    // cesto. Il bordo superiore ha un piccolo rialzo verso la testa.
    final leftTop = Offset(cx - w * 0.52, rimY);
    final rightTop = Offset(cx + w * 0.52, rimY);
    final basket = Path()
      ..moveTo(leftTop.dx, leftTop.dy)
      ..lineTo(cx - w * 0.44, rimY + w * 0.06)
      ..quadraticBezierTo(
          cx, rimY + w * 0.62, cx + w * 0.44, rimY + w * 0.06)
      ..lineTo(rightTop.dx, rightTop.dy);
    canvas.drawPath(basket, stroke);
    // Il bordo superiore, la sponda.
    canvas.drawLine(leftTop, rightTop, stroke);

    // I due dondoli curvi sotto, che la fanno leggere come culla.
    final rockPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = gold.withValues(alpha: 0.55);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(cx, rimY + w * 0.30),
            width: w * 1.28,
            height: w * 0.62),
        0.08 * math.pi,
        0.84 * math.pi,
        false,
        rockPaint);

    // Polvere di stelle che sale dalla culla.
    if (_rich) {
      final rng = math.Random(31);
      for (var i = 0; i < 6; i++) {
        final f = ((t * 2 + i / 6) % 1.0);
        final drift = rng.nextDouble() - 0.5;
        final p = soul +
            Offset(drift * w * 0.5 + math.sin(f * 6 + i) * w * 0.06,
                -f * w * 0.9);
        canvas.drawCircle(
            p,
            0.8 + (1 - f) * 1.2,
            Paint()
              ..color = gold.withValues(alpha: (0.7 * (1 - f)).clamp(0.0, 0.7)));
      }
    }
  }

  void _dustField(Canvas canvas, Size size) {
    final count = switch (tier) {
      QualityTier.high => 120,
      QualityTier.medium => 60,
      QualityTier.low => 24,
    };
    final rng = math.Random(99);
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * _horizonFrac;
      final base = 0.10 + rng.nextDouble() * 0.30;
      final tw = _rich
          ? 0.6 + 0.4 * math.sin(t * 2 * math.pi * 2 + i)
          : 1.0;
      canvas.drawCircle(
          Offset(x, y),
          rng.nextDouble() * 0.9 + 0.3,
          Paint()..color = Colors.white.withValues(alpha: base * tw));
    }
  }

  void _star(Canvas canvas, Offset p, double mag, int seed) {
    // Piu' luminosa la stella, piu' grande e viva.
    final r = (2.6 - mag * 0.5).clamp(0.8, 3.4);
    final twinkle = _rich
        ? 0.75 + 0.25 * math.sin(t * 2 * math.pi * 2.2 + seed * 1.7)
        : 1.0;
    if (_rich) {
      canvas.drawCircle(
          p,
          r * 2.4,
          Paint()
            ..color = gold.withValues(alpha: 0.16 * twinkle)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
    canvas.drawCircle(
        p,
        r * twinkle,
        Paint()..color = Colors.white.withValues(alpha: 0.95));
    // Punta di riflesso dorato sulle piu' brillanti.
    if (mag < 1.6) {
      canvas.drawCircle(p, r * 0.5,
          Paint()..color = gold.withValues(alpha: 0.9));
    }
  }

  void _moon(Canvas canvas, Offset c, double r) {
    paintMoonPhase(canvas, c, r,
        fraction: snapshot.moonPhase.fraction,
        waxing: snapshot.moonPhase.waxing,
        glow: _rich);
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.t != t || old.panAz != panAz || old.tiltY != tiltY;
}

/// Didascalia vera del cielo, dai dati reali di quel momento: fase e nome della
/// Luna, una o due costellazioni allora alte, la stagione. Poco testo, dopo il
/// visivo.
String _skyCaption(SkySnapshot snap, BirthDetails details) {
  final phase = phaseNameOf(snap.moonPhase).toLowerCase();
  final tops = <MapEntry<String, double>>[];
  for (final c in snap.constellations) {
    var maxAlt = -90.0;
    for (final s in c.stars) {
      if (s.altDeg > maxAlt) maxAlt = s.altDeg;
    }
    if (maxAlt > 32) tops.add(MapEntry(c.name, maxAlt));
  }
  tops.sort((a, b) => b.value.compareTo(a.value));
  final names = tops.take(2).map((e) => e.key).toList();
  final season = _seasonOf(details.date.month, details.place.latitude);

  final buf = StringBuffer('Vegliava una $phase');
  if (names.length == 2) {
    buf.write('; in alto ${names[0]} e ${names[1]}');
  } else if (names.length == 1) {
    buf.write('; in alto ${names[0]}');
  }
  buf.write(', nel cuore $season.');
  return buf.toString();
}

String _seasonOf(int month, double latitude) {
  String s;
  if (month == 12 || month <= 2) {
    s = 'inverno';
  } else if (month <= 5) {
    s = 'primavera';
  } else if (month <= 8) {
    s = 'estate';
  } else {
    s = 'autunno';
  }
  if (latitude < 0) {
    // Emisfero australe: le stagioni si invertono.
    s = const {
      'inverno': 'estate',
      'estate': 'inverno',
      'primavera': 'autunno',
      'autunno': 'primavera',
    }[s]!;
  }
  return const {
    'inverno': 'dell\'inverno',
    'primavera': 'della primavera',
    'estate': 'dell\'estate',
    'autunno': 'dell\'autunno',
  }[s]!;
}
