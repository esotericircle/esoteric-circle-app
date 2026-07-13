import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/zodiac_figures.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'widgets/moon_widget.dart';

/// "Il cielo sopra di te": il cielo del momento, ancorato all'ora di adesso.
///
/// Riusa cio' che nel repo e' reale: gli asterismi stilizzati ma fedeli dello
/// zodiaco e la Luna nella fase attuale. Con l'ora di adesso calcola quali
/// costellazioni stanno all'opposizione del Sole, cioe' sono alte stanotte
/// (`NightSky`). La volta scorre col giroscopio, con ripiego allo scorrimento
/// del dito per chi non ha il sensore, e si ferma con Riduci Movimento. I corpi
/// principali (Luna e costellazioni alte) sono toccabili: mostrano etichetta e
/// una riga breve nella voce di Medora. I pianeti restano segnaposto dichiarato
/// finche' non arriva il motore a effemeridi. Freccia Indietro al Santuario.
class SkyOverviewScreen extends StatefulWidget {
  const SkyOverviewScreen({super.key, this.now});

  /// Momento del cielo, iniettabile per i test; di default l'ora di adesso.
  final DateTime? now;

  static Route<void> route({DateTime? now}) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(child: SkyOverviewScreen(now: now)),
    );
  }

  @override
  State<SkyOverviewScreen> createState() => _SkyOverviewScreenState();
}

class _SkyOverviewScreenState extends State<SkyOverviewScreen> {
  Offset _pan = Offset.zero;
  String? _selectedKey;

  // Posizioni normalizzate dei corpi nella volta.
  static const List<Offset> _slots = [
    Offset(0.26, 0.42),
    Offset(0.52, 0.64),
    Offset(0.76, 0.40),
  ];

  void _onPan(DragUpdateDetails d, Size size) {
    setState(() {
      final limit = Offset(size.width * 0.18, size.height * 0.14);
      _pan = Offset(
        (_pan.dx + d.delta.dx).clamp(-limit.dx, limit.dx),
        (_pan.dy + d.delta.dy).clamp(-limit.dy, limit.dy),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final now = widget.now ?? DateTime.now();
    final moon = MoonPhase.forDate(now);
    final high = NightSky.constellationsHighTonight(now);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final parallax = context.watch<ParallaxController>();

    // La deriva del giroscopio muove la volta; con Riduci Movimento si ferma.
    // Lo scorrimento del dito resta sempre, come ripiego tattile.
    final tilt = reduceMotion ? Offset.zero : parallax.layerOffset(0.5);
    final vault = _pan + tilt;

    final bodies = <_SkyBody>[
      _SkyBody.moon(moon),
      for (var i = 0; i < high.length && i < _slots.length; i++)
        _SkyBody.constellation(high[i], _slots[i]),
    ];
    final selected = bodies.where((b) => b.key == _selectedKey).firstOrNull;

    return Scaffold(
      key: const Key('sky_overview_screen'),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title:
            Text('Il cielo sopra di te', style: TypographyTokens.display(size: 20)),
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) => _onPan(d, size),
              onTap: () => setState(() => _selectedKey = null),
              child: Stack(
                children: [
                  // La volta con i corpi, che scorre con giroscopio e dito.
                  Transform.translate(
                    offset: vault,
                    child: Stack(
                      children: [
                        for (final b in bodies)
                          Positioned(
                            left: b.slot.dx * size.width - b.size / 2,
                            top: b.slot.dy * size.height - b.size / 2,
                            width: b.size,
                            height: b.size + 36,
                            child: _BodyView(
                              body: b,
                              selected: b.key == _selectedKey,
                              palette: palette,
                              onTap: () =>
                                  setState(() => _selectedKey = b.key),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Scheda in basso: cosa e', nella voce di Medora.
                  Positioned(
                    left: SpacingTokens.lg,
                    right: SpacingTokens.lg,
                    bottom: SpacingTokens.lg,
                    child: SafeArea(
                      top: false,
                      child: _SkyInfoCard(
                        selected: selected,
                        moon: moon,
                        palette: palette,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Un corpo celeste toccabile della volta: la Luna oppure una costellazione.
class _SkyBody {
  const _SkyBody({
    required this.key,
    required this.label,
    required this.description,
    required this.slot,
    required this.size,
    this.moon,
    this.constellation,
  });

  factory _SkyBody.moon(MoonPhase moon) => _SkyBody(
        key: 'moon',
        label: 'Luna',
        description: NightSky.describeMoon(moon),
        slot: const Offset(0.5, 0.18),
        size: 96,
        moon: moon,
      );

  factory _SkyBody.constellation(Zodiac sign, Offset slot) {
    final fig = kZodiacConstellations.firstWhere((c) => c.sign == sign);
    return _SkyBody(
      key: sign.id,
      label: sign.italianName,
      description: NightSky.describe(sign),
      slot: slot,
      size: 116,
      constellation: fig,
    );
  }

  final String key;
  final String label;
  final String description;
  final Offset slot;
  final double size;
  final MoonPhase? moon;
  final ZodiacConstellation? constellation;
}

/// Rende un corpo: Luna con la sua fase, o l'asterismo di una costellazione,
/// con l'etichetta sotto. Evidenziato quando selezionato.
class _BodyView extends StatelessWidget {
  const _BodyView({
    required this.body,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final _SkyBody body;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget visual = body.moon != null
        ? MoonWidget(phase: body.moon, size: body.size * 0.5)
        : CustomPaint(
            size: Size(body.size, body.size),
            painter: _AsterismPainter(
              figure: body.constellation!,
              color: selected ? palette.goldSoft : palette.gold,
              highlighted: selected,
            ),
          );

    return GestureDetector(
      key: Key('sky_body_${body.key}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: body.size, height: body.size, child: Center(child: visual)),
          const SizedBox(height: 2),
          Text(
            body.label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TypographyTokens.label(size: 11).copyWith(
              color: selected ? palette.goldSoft : ColorTokens.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Disegna l'asterismo di una costellazione dentro il riquadro del corpo.
class _AsterismPainter extends CustomPainter {
  _AsterismPainter({
    required this.figure,
    required this.color,
    required this.highlighted,
  });

  final ZodiacConstellation figure;
  final Color color;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 10.0;
    final rect = Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2);
    Offset map(Offset p) =>
        Offset(rect.left + p.dx * rect.width, rect.top + p.dy * rect.height);
    final pts = figure.points.map(map).toList();

    if (highlighted) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      for (final (a, b) in figure.edges) {
        canvas.drawLine(pts[a], pts[b], glow);
      }
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlighted ? 1.4 : 1.0
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: highlighted ? 0.9 : 0.6);
    for (final (a, b) in figure.edges) {
      canvas.drawLine(pts[a], pts[b], line);
    }
    final dot = Paint()
      ..color = color.withValues(alpha: highlighted ? 1.0 : 0.75);
    for (final p in pts) {
      canvas.drawCircle(p, highlighted ? 2.4 : 1.8, dot);
    }
  }

  @override
  bool shouldRepaint(_AsterismPainter old) =>
      old.figure != figure ||
      old.color != color ||
      old.highlighted != highlighted;
}

/// Scheda in basso: se un corpo e' scelto ne mostra etichetta e riga; altrimenti
/// invita a toccare il cielo. In coda, la nota segnaposto sui pianeti.
class _SkyInfoCard extends StatelessWidget {
  const _SkyInfoCard({
    required this.selected,
    required this.moon,
    required this.palette,
  });

  final _SkyBody? selected;
  final MoonPhase moon;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final s = selected;
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.85),
            palette.deepest.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            s?.label ?? 'Il cielo di stanotte',
            style: TypographyTokens.display(size: 18)
                .copyWith(color: palette.goldSoft),
          ),
          const SizedBox(height: 4),
          Text(
            s?.description ??
                'Tocca la Luna o una costellazione alta per sapere cosa è.',
            style: TypographyTokens.body(size: 14)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Nota segnaposto onesta: i pianeti tornano col motore vero.
          Row(
            children: [
              Icon(Icons.public_off_rounded,
                  size: 14, color: palette.gold.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'I pianeti tornano col motore delle effemeridi. Qui, per ora, '
                  'la Luna reale e le costellazioni alte stanotte.',
                  style: TypographyTokens.label(size: 10).copyWith(
                    color: ColorTokens.textMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
