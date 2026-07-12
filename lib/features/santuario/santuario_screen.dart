import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../maestri/domain_screen.dart';
import 'widgets/maestro_bust.dart';
import 'widgets/moon_widget.dart';

/// La schermata eroe, il Santuario.
///
/// Un unico palco antico e neutro con la Luna reale in alto e, dietro i
/// Maestri, una silhouette architettonica di tempio fatta di linee dorate e
/// stelle. Tre mezzibusti davanti: al centro, piu' grande e vivo, l'ultimo
/// Maestro usato; gli altri due sbucano ai lati, piu' in alto, piu' scuri e
/// arretrati nella parallasse. Un filo d'oro li unisce. Toccare il centro entra
/// nel dominio, toccare un laterale lo porta al centro.
///
/// Costruita ai punti dati da Mauro: nel repo non c'e' una Specifica del
/// Santuario dedicata, solo i quattro briefing. Fondo, tempio e cielo sono un
/// segnaposto architettonico, l'asset dipinto e il motore a effemeridi
/// arrivano dopo.
class SantuarioScreen extends StatefulWidget {
  const SantuarioScreen({super.key});

  /// Maestro preferito, segnaposto in attesa dell'assegnazione all'onboarding.
  static const Maestro preferred = Maestro.medora;

  @override
  State<SantuarioScreen> createState() => _SantuarioScreenState();
}

class _SantuarioScreenState extends State<SantuarioScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  Maestro? _lastCentral;
  String? _greeting;
  Timer? _greetingTimer;
  final Map<Maestro, int> _greetingIndex = {};

  static const Map<Maestro, List<String>> _greetings = {
    Maestro.medora: [
      'Medora ti accoglie.',
      'Medora ti sorride.',
      'Le stelle si voltano verso di te.',
    ],
    Maestro.aura: [
      'Aura respira con te.',
      'Aura ti avvolge.',
      'Un respiro e sei qui.',
    ],
    Maestro.caligo: [
      'Caligo alza lo sguardo.',
      'Caligo ti riconosce.',
      'Le rune si destano.',
    ],
  };

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _onCentralChanged(Maestro maestro) {
    // Saluto breve a rotazione, mai lo stesso due volte di fila, non blocca.
    final variants = _greetings[maestro]!;
    final next = ((_greetingIndex[maestro] ?? -1) + 1) % variants.length;
    _greetingIndex[maestro] = next;
    setState(() => _greeting = variants[next]);
    _greetingTimer?.cancel();
    _greetingTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _greeting = null);
    });
  }

  void _enterDomain(BuildContext context, Maestro maestro) {
    // Ingresso rapido nel dominio. L'incantesimo a tutto schermo resta per la
    // prima volta, non a ogni ingresso: segnaposto per un passo successivo.
    context.read<MaestroController>().selectMaestro(maestro);
    final services = context.read<AppServices>();
    Navigator.of(context).push(
      DomainScreen.route(maestro: maestro, services: services),
    );
  }

  void _selectSide(BuildContext context, Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
  }

  /// La riga dell'oggi, attribuita al Maestro al centro e alla sua arte. Per
  /// Medora la parte astronomica e' vera (fase e luce della Luna reali). Per
  /// Aura e Caligo il contenuto e' un segnaposto in attesa del motore vero.
  (String, String) _tonight(Maestro maestro, MoonPhase moon) {
    switch (maestro) {
      case Maestro.medora:
        final pct = (moon.illumination * 100).round();
        final tend =
            moon.waxing ? 'cresce, semina ora.' : 'cala, lascia andare.';
        return ('Il cielo di stanotte', '${moon.italianName}, $pct% di luce: $tend');
      case Maestro.aura:
        return (
          "L'energia di stanotte",
          'Il verde del cuore respira: sciogli le spalle e allunga il respiro.'
        );
      case Maestro.caligo:
        return (
          'Il presagio di stanotte',
          'Sale Perthro, la runa del segreto: qualcosa matura al riparo.'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = context.watch<MaestroController>().activeMaestro;
    final central = active ?? SantuarioScreen.preferred;
    final selected = active != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final parallax = context.watch<ParallaxController>();
    final palette = context.palette;

    // Segnala il cambio di centrale per il saluto (solo su un Maestro scelto).
    if (selected && central != _lastCentral) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onCentralChanged(central);
      });
    }
    _lastCentral = selected ? central : null;

    final moon = MoonPhase.forDate(DateTime.now());
    final (tonightEyebrow, tonightLine) = _tonight(central, moon);

    // Riduci Movimento: niente deriva di parallasse, scena ferma.
    Offset depth(double d) => reduceMotion ? Offset.zero : parallax.layerOffset(d);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          // I busti occupano la fascia centrale e bassa in modo pieno, non
          // schiacciati sul fondo. Una carta piu' alta riduce lo spazio morto.
          final centralH = (h * 0.54).clamp(240.0, 460.0);
          // Sollevati dal margine inferiore, cosi' poggiano sul palco senza
          // sprofondare dietro la bottom bar.
          final carouselBottom = h * 0.05;
          final carouselHeight = centralH * 1.32;

          return Stack(
            children: [
              // Silhouette architettonica del tempio, dietro tutto, tenue e
              // sensibile alla parallasse: colonne, arco e cupola di linee
              // dorate e stelle. Segnaposto del fondale dipinto.
              Positioned.fill(
                child: CustomPaint(
                  painter: _TempleSilhouettePainter(
                    color: palette.goldSoft,
                    offset: depth(0.22),
                  ),
                ),
              ),

              // Cielo in alto: nebulose soffuse tinte sull'accento del Maestro
              // e un paio di stelle piu' luminose a evocare i pianeti, in
              // attesa del motore a effemeridi.
              Positioned.fill(
                child: CustomPaint(
                  painter: _SkyAccentsPainter(
                    glow: palette.glow,
                    primary: palette.primary,
                    star: palette.goldSoft,
                    offset: depth(0.12),
                  ),
                ),
              ),

              // Luna reale protagonista, il nome della fase e la riga dell'oggi.
              Positioned(
                top: h * 0.015,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    MoonWidget(phase: moon, size: (w * 0.12).clamp(58.0, 108.0)),
                    Text(
                      moon.italianName,
                      style: TypographyTokens.label(size: 11).copyWith(
                        color: ColorTokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tonightEyebrow.toUpperCase(),
                      style: TypographyTokens.label(size: 10).copyWith(
                        color: palette.goldSoft,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        tonightLine,
                        textAlign: TextAlign.center,
                        style: TypographyTokens.body(size: 13).copyWith(
                          color: ColorTokens.textSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Palco e busti, alzati verso il centro della scena.
              Positioned(
                left: 0,
                right: 0,
                bottom: carouselBottom,
                height: carouselHeight,
                child: _Carousel(
                  central: central,
                  selected: selected,
                  centralHeight: centralH,
                  breath: _breath,
                  reduceMotion: reduceMotion,
                  preferred: SantuarioScreen.preferred,
                  sideDepth: depth(0.3),
                  onTapCentral: () => _enterDomain(context, central),
                  onTapSide: (m) => _selectSide(context, m),
                ),
              ),

              // Saluto breve appena sopra i busti, non blocca mai.
              if (_greeting != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: carouselBottom + centralH * 1.06,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _greeting!,
                          style: TypographyTokens.display(size: 18).copyWith(
                            color: palette.goldSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Il carosello dei tre busti: centrale grande e vivo, laterali alzati verso
/// l'alto, arretrati e in penombra, uniti dal filo d'oro del cerchio.
class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.central,
    required this.selected,
    required this.centralHeight,
    required this.breath,
    required this.reduceMotion,
    required this.preferred,
    required this.sideDepth,
    required this.onTapCentral,
    required this.onTapSide,
  });

  final Maestro central;
  final bool selected;
  final double centralHeight;
  final Animation<double> breath;
  final bool reduceMotion;
  final Maestro preferred;

  /// Deriva di parallasse dei laterali, piano arretrato.
  final Offset sideDepth;
  final VoidCallback onTapCentral;
  final ValueChanged<Maestro> onTapSide;

  @override
  Widget build(BuildContext context) {
    // I due laterali sono gli altri due nell'ordine fisso, primo a sinistra.
    final sides = Maestro.fixedOrder.where((m) => m != central).toList();
    final sideH = centralHeight * 0.60;
    final centralW = centralHeight * 0.75;
    final sideW = sideH * 0.75;
    // Laterali sollevati: sbucano ai lati sopra la carta centrale, cosi' si
    // vede che i Maestri sono tre.
    final sideBottom = centralHeight * 0.44;

    return AnimatedBuilder(
      animation: breath,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final breathValue = reduceMotion ? 0.5 : breath.value;

            // Punti di aggancio del filo d'oro, all'altezza del petto.
            final centralPoint = Offset(w / 2, c.maxHeight - centralHeight * 0.5);
            final sideMid = c.maxHeight - sideBottom - sideH * 0.5;
            final leftPoint = Offset(w * 0.14 + sideW / 2, sideMid);
            final rightPoint = Offset(w * 0.86 - sideW / 2, sideMid);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Il cerchio visibile: filo sottile di luce dorata.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GoldenThreadPainter(
                      a: leftPoint,
                      b: centralPoint,
                      cc: rightPoint,
                      color: context.palette.goldSoft,
                    ),
                  ),
                ),

                // Busto sinistro, alzato, arretrato e in penombra.
                Positioned(
                  left: w * 0.01,
                  bottom: sideBottom,
                  width: sideW,
                  height: sideH,
                  child: Transform.translate(
                    offset: sideDepth,
                    child: GestureDetector(
                      onTap: () => onTapSide(sides[0]),
                      child: MaestroBust(
                        maestro: sides[0],
                        height: sideH,
                        central: false,
                        dim: 0.5,
                        preferred: sides[0] == preferred,
                      ),
                    ),
                  ),
                ),

                // Busto destro, alzato, arretrato e in penombra.
                Positioned(
                  right: w * 0.01,
                  bottom: sideBottom,
                  width: sideW,
                  height: sideH,
                  child: Transform.translate(
                    offset: sideDepth,
                    child: GestureDetector(
                      onTap: () => onTapSide(sides[1]),
                      child: MaestroBust(
                        maestro: sides[1],
                        height: sideH,
                        central: false,
                        dim: 0.5,
                        preferred: sides[1] == preferred,
                      ),
                    ),
                  ),
                ),

                // Busto centrale, l'unico vivo, in primo piano.
                Positioned(
                  left: (w - centralW) / 2,
                  bottom: 0,
                  width: centralW,
                  height: centralHeight,
                  child: GestureDetector(
                    key: const Key('santuario_central_bust'),
                    onTap: onTapCentral,
                    child: MaestroBust(
                      maestro: central,
                      height: centralHeight,
                      central: true,
                      breath: breathValue,
                      preferred: central == preferred,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Silhouette architettonica del tempio: colonne, arco e cupola disegnati con
/// linee dorate sottili e punti-stella ai giunti. Una architettura-costellazione
/// tenue dietro i Maestri, segnaposto del fondale dipinto.
class _TempleSilhouettePainter extends CustomPainter {
  _TempleSilhouettePainter({required this.color, required this.offset});

  final Color color;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final w = size.width;
    final h = size.height;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.12);
    final star = Paint()..color = color.withValues(alpha: 0.4);

    final baseY = h * 0.80;
    final topY = h * 0.50;
    final cols = [0.12, 0.28, 0.5, 0.72, 0.88].map((f) => f * w).toList();
    final joints = <Offset>[];

    // Basamento e architrave.
    canvas.drawLine(Offset(cols.first, baseY), Offset(cols.last, baseY), line);
    canvas.drawLine(Offset(cols.first, topY), Offset(cols.last, topY), line);

    // Colonne coi capitelli.
    for (final x in cols) {
      canvas.drawLine(Offset(x, baseY), Offset(x, topY), line);
      canvas.drawLine(Offset(x - 8, topY), Offset(x + 8, topY), line);
      joints.add(Offset(x, baseY));
      joints.add(Offset(x, topY));
    }

    // Arco centrale, come una porta.
    final arch = Path()
      ..moveTo(w * 0.40, baseY)
      ..lineTo(w * 0.40, h * 0.56)
      ..arcToPoint(Offset(w * 0.60, h * 0.56),
          radius: Radius.circular(w * 0.10))
      ..lineTo(w * 0.60, baseY);
    canvas.drawPath(arch, line);

    // Cupola sopra l'architrave.
    final dome = Path()
      ..moveTo(w * 0.28, topY)
      ..quadraticBezierTo(w * 0.5, h * 0.30, w * 0.72, topY);
    canvas.drawPath(dome, line);
    final finial = Offset(w * 0.5, h * 0.33);
    canvas.drawLine(Offset(w * 0.5, h * 0.30), finial, line);
    joints
      ..add(finial)
      ..add(Offset(w * 0.5, h * 0.36));

    // Punti-stella luminosi ai giunti dell'architettura.
    for (final p in joints) {
      canvas.drawCircle(p, 1.5, star);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TempleSilhouettePainter old) =>
      old.color != color || old.offset != offset;
}

/// Accenti del cielo del Santuario: nebulose soffuse tinte sull'accento del
/// Maestro e un paio di stelle piu' luminose a evocare i pianeti. Sparso ed
/// elegante, mai affollato.
class _SkyAccentsPainter extends CustomPainter {
  _SkyAccentsPainter({
    required this.glow,
    required this.primary,
    required this.star,
    required this.offset,
  });

  final Color glow;
  final Color primary;
  final Color star;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final w = size.width;
    final h = size.height;

    // Nebulose soffuse, ai lati della Luna, tinte sull'accento.
    const nebulae = [
      (Offset(0.20, 0.15), 0.30),
      (Offset(0.82, 0.22), 0.26),
      (Offset(0.66, 0.09), 0.20),
    ];
    for (var i = 0; i < nebulae.length; i++) {
      final (pos, rf) = nebulae[i];
      final center = Offset(pos.dx * w, pos.dy * h);
      final radius = w * rf;
      final color = i.isEven ? glow : primary;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: 0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
    }

    // Stelle-pianeta: piu' luminose, con un piccolo alone.
    const planets = [
      (Offset(0.30, 0.27), 2.4),
      (Offset(0.74, 0.31), 1.8),
    ];
    for (final (pos, r) in planets) {
      final center = Offset(pos.dx * w, pos.dy * h);
      canvas.drawCircle(
        center,
        r * 3.2,
        Paint()
          ..color = star.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        center,
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkyAccentsPainter old) =>
      old.glow != glow ||
      old.primary != primary ||
      old.star != star ||
      old.offset != offset;
}

/// Filo d'oro sottile che unisce i tre Maestri, discreto.
class _GoldenThreadPainter extends CustomPainter {
  _GoldenThreadPainter({
    required this.a,
    required this.b,
    required this.cc,
    required this.color,
  });

  final Offset a;
  final Offset b;
  final Offset cc;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    // Un arco morbido dai laterali al centro.
    final smooth = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo((a.dx + b.dx) / 2, b.dy - 30, b.dx, b.dy)
      ..quadraticBezierTo((b.dx + cc.dx) / 2, b.dy - 30, cc.dx, cc.dy);
    canvas.drawPath(smooth, paint);
    // piccoli nodi di luce sui Maestri
    final dot = Paint()..color = color.withValues(alpha: 0.7);
    for (final o in [a, b, cc]) {
      canvas.drawCircle(o, 2, dot);
    }
  }

  @override
  bool shouldRepaint(_GoldenThreadPainter old) =>
      old.a != a || old.b != b || old.cc != cc || old.color != color;
}
