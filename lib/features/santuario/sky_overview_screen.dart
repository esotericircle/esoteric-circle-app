import 'dart:math' as math;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/astro/night_sky.dart';
import '../../core/astro/sky_catalog.dart';
import '../../core/astro/sky_location.dart';
import '../../core/astro/zodiac.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'sky_postcard.dart';
import 'widgets/moon_widget.dart';

/// "Il cielo sopra di te": il cielo del momento, immersivo ed esplorabile.
///
/// Non uno schema, ma una volta stellata densa: centinaia di stelle su tre
/// piani che si muovono a velocita' diverse col giroscopio e col trascinamento
/// del dito, un accenno di Via Lattea, e le costellazioni immerse nel campo con
/// le loro forme reali. La tela e' piu' ampia dello schermo: scorrendo o
/// inclinando si rivela altro cielo ai lati e in alto. La Luna e le
/// costellazioni alte stanotte (`NightSky`, dalla posizione reale del Sole) sono
/// distribuite su questa tela, toccabili, con etichetta e riga breve nella voce
/// di Medora. Riduci Movimento appiattisce o ferma la parallasse. Freccia
/// Indietro al Santuario.
class SkyOverviewScreen extends StatefulWidget {
  const SkyOverviewScreen({
    super.key,
    this.now,
    this.location = const DisabledSkyLocation(),
    this.birth = false,
  });

  /// Momento del cielo, iniettabile per i test; di default l'ora di adesso.
  /// Per il cielo di nascita e' il momento fisso della nascita.
  final DateTime? now;

  /// Sorgente della posizione, per orientare il cielo sul luogo reale. Di
  /// default e' spenta, cosi' test e anteprime non chiedono nulla; l'ingresso
  /// dal Santuario passa quella vera. Il pre-avviso appare solo quando il
  /// momento e' l'adesso reale (`now` nullo) e la sorgente e' disponibile.
  final SkyLocation location;

  /// Se e' il cielo di nascita: stesso motore immersivo, ma ancorato alla
  /// notte di nascita e fisso (identita'). Cambia titolo e voce, e non chiede
  /// mai la posizione: il luogo e' quello della nascita, non l'adesso.
  final bool birth;

  static Route<void> route({DateTime? now, SkyLocation? location}) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        child: SkyOverviewScreen(
          now: now,
          location: location ?? const GeolocatorSkyLocation(),
        ),
      ),
    );
  }

  /// Il cielo di nascita, ancorato alla notte di nascita e fisso. Riusa il
  /// motore immersivo del cielo di adesso, con la voce di Medora sull'identita'.
  static Route<void> birthRoute({required DateTime birthMoment}) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        child: SkyOverviewScreen(now: birthMoment, birth: true),
      ),
    );
  }

  @override
  State<SkyOverviewScreen> createState() => _SkyOverviewScreenState();
}

class _SkyOverviewScreenState extends State<SkyOverviewScreen> {
  Offset _cam = Offset.zero;
  String? _selectedKey;

  // Luogo risolto per orientare la volta, e se il pre-avviso e' gia' stato
  // proposto in questa visita (una sola volta).
  SkyPlace? _place;
  bool _askedLocation = false;

  @override
  void initState() {
    super.initState();
    // Il pre-avviso vale solo per il cielo di adesso, non per il cielo di
    // nascita ne per i test o le anteprime, che passano un momento fisso o una
    // sorgente spenta.
    if (widget.now == null && widget.location.available) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _offerLocation());
    }
  }

  Future<void> _offerLocation() async {
    if (!mounted || _askedLocation) return;
    _askedLocation = true;
    final accepted = await _askLocationConsent();
    if (accepted != true || !mounted) return;
    final place = await widget.location.resolve();
    if (!mounted) return;
    if (place != null) {
      setState(() => _place = place);
    } else {
      // Permesso negato o sensore assente: ripiego elegante, nessun vicolo
      // cieco, resta la veduta attuale.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resto sulla veduta di stanotte, senza il tuo luogo.'),
        ),
      );
    }
  }

  // Il pre-avviso gentile, nel tono di Medora: spiega a cosa serve la posizione
  // prima che il sistema mostri la sua richiesta secca.
  Future<bool?> _askLocationConsent() {
    final palette = context.palette;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        key: const Key('sky_location_prompt'),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(SpacingTokens.lg),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.surfaceElevated, palette.deepest],
            ),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.public_rounded, color: palette.goldSoft, size: 22),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text('Oriento il cielo sul tuo luogo?',
                        style: TypographyTokens.display(size: 18)
                            .copyWith(color: palette.goldSoft)),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Con il tuo permesso leggo dove ti trovi, così la volta sopra di '
                'te si dispone come la vedi davvero da lì. La posizione resta sul '
                'dispositivo: serve solo a orientare le stelle. La precisione '
                'piena in alt-azimut è custodita dal motore a effemeridi.',
                style: TypographyTokens.body(size: 14)
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.md),
              // Wrap, non Row: se le etichette non stanno su una riga vanno a
              // capo, senza mai sforare il bordo del riquadro.
              Wrap(
                alignment: WrapAlignment.end,
                spacing: SpacingTokens.sm,
                children: [
                  TextButton(
                    key: const Key('sky_location_decline'),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text('Non ora',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: ColorTokens.textSecondary)),
                  ),
                  TextButton(
                    key: const Key('sky_location_accept'),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text('Orienta il cielo',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: palette.goldSoft)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // La longitudine sposta il centro della volta in orizzontale, la latitudine
  // alza o abbassa l'orizzonte: un orientamento simbolico sul luogo reale. La
  // volta piena in alt-azimut resta al motore a effemeridi, come dichiarato.
  Offset _orientOffset(Size size) {
    final p = _place;
    if (p == null) return Offset.zero;
    return Offset(
      (p.longitude / 180.0) * size.width * 0.32,
      (p.latitude / 90.0) * size.height * 0.14,
    );
  }

  // Slot prominenti dei corpi alti stanotte, sempre raggiungibili.
  static const Offset _moonSlot = Offset(0.5, 0.2);
  static const List<Offset> _highSlots = [
    Offset(0.24, 0.52),
    Offset(0.78, 0.44),
    Offset(0.5, 0.64),
  ];

  // Ancore sparse delle costellazioni ambientali, su una tela piu' ampia dello
  // schermo (coordinate normalizzate, fuori da [0,1] verso i bordi).
  static const Map<String, Offset> _ambientAnchors = {
    'aries': Offset(-0.14, 0.22),
    'taurus': Offset(0.16, -0.1),
    'gemini': Offset(0.46, -0.12),
    'cancer': Offset(0.82, -0.06),
    'leo': Offset(1.16, 0.16),
    'virgo': Offset(1.2, 0.52),
    'libra': Offset(1.12, 0.86),
    'scorpio': Offset(0.86, 1.12),
    'sagittarius': Offset(0.5, 1.16),
    'capricorn': Offset(0.16, 1.12),
    'aquarius': Offset(-0.14, 0.86),
    'pisces': Offset(-0.2, 0.52),
    'orion': Offset(0.26, 0.76),
    'ursa_major': Offset(0.76, 0.74),
    'cassiopeia': Offset(0.32, 0.14),
    'cygnus': Offset(0.7, 0.2),
  };

  void _onPan(DragUpdateDetails d, Size size) {
    setState(() {
      final limit = Offset(size.width * 0.4, size.height * 0.35);
      _cam = Offset(
        (_cam.dx + d.delta.dx).clamp(-limit.dx, limit.dx),
        (_cam.dy + d.delta.dy).clamp(-limit.dy, limit.dy),
      );
    });
  }

  // Offre il formato (Storia verticale o Feed quadrato), genera la cartolina
  // costruita apposta e apre il foglio di condivisione del sistema con
  // l'immagine e un testo con hashtag. Su Instagram l'immagine va nelle Storie,
  // altrove passa il testo. Solo su device: qui e' best effort.
  Future<void> _share(BuildContext context, DateTime now, MoonPhase moon,
      List<Zodiac> high, MaestroPalette palette) async {
    final format = await _chooseFormat(context, palette);
    if (format == null || !context.mounted) return;
    try {
      final bytes = await SkyPostcard.render(
          now: now,
          moon: moon,
          high: high,
          palette: palette,
          format: format,
          birth: widget.birth);
      final dir = await getTemporaryDirectory();
      final kind = widget.birth ? 'nascita' : 'cielo';
      final file = File('${dir.path}/esoteric_${kind}_${format.name}.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: SkyPostcard.shareText(now, birth: widget.birth),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Non è stato possibile condividere ora.')),
      );
    }
  }

  Future<PostcardFormat?> _chooseFormat(
      BuildContext context, MaestroPalette palette) {
    return showModalBottomSheet<PostcardFormat>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Condividi il tuo cielo',
                  style: TypographyTokens.display(size: 18)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.md),
              _FormatOption(
                itemKey: const Key('share_story'),
                icon: Icons.crop_portrait_rounded,
                title: 'Storia',
                subtitle: 'Verticale, per le Storie.',
                palette: palette,
                onTap: () =>
                    Navigator.of(sheetContext).pop(PostcardFormat.story),
              ),
              _FormatOption(
                itemKey: const Key('share_feed'),
                icon: Icons.crop_square_rounded,
                title: 'Feed',
                subtitle: 'Quadrato, per il feed.',
                palette: palette,
                onTap: () =>
                    Navigator.of(sheetContext).pop(PostcardFormat.feed),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final now = widget.now ?? DateTime.now();
    final moon = MoonPhase.forDate(now);
    final high = NightSky.constellationsHighTonight(now);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final parallax = context.watch<ParallaxController>();

    // Deriva del giroscopio; con Riduci Movimento si ferma. Il trascinamento
    // del dito resta sempre. La camera e' pan piu' tilt.
    final tilt = reduceMotion ? Offset.zero : parallax.layerOffset(1.0);
    final cam = _cam + tilt;
    // Con Riduci Movimento i piani si muovono insieme (parallasse piatta), cosi'
    // la tela resta esplorabile ma senza effetto di profondita'.
    double depth(double d) => reduceMotion ? 0.9 : d;

    final highKeys = high.map((z) => z.id).toSet();
    final ambient = <(Asterism, Offset)>[
      for (final e in kZodiacAsterisms.entries)
        if (!highKeys.contains(e.value.id))
          (e.value, _ambientAnchors[e.value.id]!),
      for (final a in kBrightAsterisms) (a, _ambientAnchors[a.id]!),
    ];

    final bodies = <_SkyBody>[
      _SkyBody.moon(moon, _moonSlot),
      for (var i = 0; i < high.length && i < _highSlots.length; i++)
        _SkyBody.constellation(high[i], _highSlots[i]),
    ];
    final selected = bodies.where((b) => b.key == _selectedKey).firstOrNull;

    return Scaffold(
      key: const Key('sky_overview_screen'),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: ColorTokens.neutralDeepest,
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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(SkyPostcard.titleFor(birth: widget.birth),
              style: TypographyTokens.display(size: 20)),
        ),
        actions: [
          IconButton(
            key: const Key('sky_share'),
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Condividi il tuo cielo',
            onPressed: () => _share(context, now, moon, high, palette),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          // La camera vista: pan del dito, deriva del giroscopio e, se il luogo
          // e' noto, l'orientamento sul luogo reale dell'utente.
          final camView = cam + _orientOffset(size);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _onPan(d, size),
            onTap: () => setState(() => _selectedKey = null),
            child: Stack(
              children: [
                // Fondo immersivo: Via Lattea, tre piani di stelle dense, le
                // costellazioni ambientali immerse nel campo.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SkyFieldPainter(
                      cam: camView,
                      depth: depth,
                      palette: palette,
                      ambient: ambient,
                    ),
                  ),
                ),

                // I corpi alti stanotte, toccabili, sul piano delle
                // costellazioni.
                Transform.translate(
                  offset: camView * depth(0.42),
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
                        palette: palette,
                        oriented: _place != null,
                        birth: widget.birth),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Un corpo celeste toccabile: la Luna oppure una costellazione alta.
class _SkyBody {
  const _SkyBody({
    required this.key,
    required this.label,
    required this.description,
    required this.slot,
    required this.size,
    this.moon,
    this.asterism,
  });

  factory _SkyBody.moon(MoonPhase moon, Offset slot) => _SkyBody(
        key: 'moon',
        label: 'Luna',
        description: NightSky.describeMoon(moon),
        slot: slot,
        size: 96,
        moon: moon,
      );

  factory _SkyBody.constellation(Zodiac sign, Offset slot) => _SkyBody(
        key: sign.id,
        label: sign.italianName,
        description: NightSky.describe(sign),
        slot: slot,
        size: 130,
        asterism: kZodiacAsterisms[sign]!,
      );

  final String key;
  final String label;
  final String description;
  final Offset slot;
  final double size;
  final MoonPhase? moon;
  final Asterism? asterism;
}

/// Rende un corpo con la sua etichetta sotto, evidenziato quando selezionato.
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
              figure: body.asterism!,
              color: selected ? palette.goldSoft : palette.gold,
              highlighted: true,
              emphasis: selected ? 1.0 : 0.82,
            ),
          );

    return GestureDetector(
      key: Key('sky_body_${body.key}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: body.size,
              height: body.size,
              child: Center(child: visual)),
          const SizedBox(height: 2),
          Text(
            body.label,
            maxLines: 1,
            style: TypographyTokens.label(size: 11).copyWith(
              color: selected ? palette.goldSoft : ColorTokens.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Disegna un asterismo dentro il riquadro del corpo, con le stelle piu'
/// brillanti piu' grandi e le linee dorate.
class _AsterismPainter extends CustomPainter {
  _AsterismPainter({
    required this.figure,
    required this.color,
    required this.highlighted,
    this.emphasis = 1.0,
  });

  final Asterism figure;
  final Color color;
  final bool highlighted;
  final double emphasis;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = size.width * 0.1;
    final rect =
        Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2);
    Offset map(Offset p) =>
        Offset(rect.left + p.dx * rect.width, rect.top + p.dy * rect.height);
    final pts = figure.stars.map(map).toList();

    if (highlighted) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.28 * emphasis)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      for (final (a, b) in figure.lines) {
        canvas.drawLine(pts[a], pts[b], glow);
      }
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.72 * emphasis);
    for (final (a, b) in figure.lines) {
      canvas.drawLine(pts[a], pts[b], line);
    }

    for (var i = 0; i < pts.length; i++) {
      final m = figure.mag[i];
      canvas.drawCircle(
        pts[i],
        1.4 + m * 2.0,
        Paint()..color = Colors.white.withValues(alpha: (0.55 + 0.45 * m) * emphasis),
      );
      if (m >= 0.9) {
        canvas.drawCircle(
          pts[i],
          3.0 + m * 3.0,
          Paint()
            ..color = color.withValues(alpha: 0.35 * emphasis)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AsterismPainter old) =>
      old.figure != figure ||
      old.color != color ||
      old.emphasis != emphasis ||
      old.highlighted != highlighted;
}

/// Il fondo immersivo: Via Lattea, tre piani di stelle e le costellazioni
/// ambientali, tutti mossi dalla camera con profondita' diversa.
class _SkyFieldPainter extends CustomPainter {
  _SkyFieldPainter({
    required this.cam,
    required this.depth,
    required this.palette,
    required this.ambient,
  });

  final Offset cam;
  final double Function(double) depth;
  final MaestroPalette palette;
  final List<(Asterism, Offset)> ambient;

  @override
  void paint(Canvas canvas, Size size) {
    _milkyWay(canvas, size, cam * depth(0.06));
    _stars(canvas, size, cam * depth(0.12), seed: 11, count: 260, rMin: 0.3, rMax: 1.1, alpha: 0.55);
    _stars(canvas, size, cam * depth(0.28), seed: 29, count: 120, rMin: 0.5, rMax: 1.7, alpha: 0.7);
    _ambient(canvas, size, cam * depth(0.42));
    _stars(canvas, size, cam * depth(0.55), seed: 71, count: 44, rMin: 0.9, rMax: 2.4, alpha: 0.9);
  }

  void _milkyWay(Canvas canvas, Size size, Offset off) {
    // Una fascia soffusa in diagonale, appena percepibile.
    canvas.save();
    canvas.translate(off.dx, off.dy);
    final rng = math.Random(3);
    final start = Offset(size.width * 0.12, -size.height * 0.1);
    final end = Offset(size.width * 0.9, size.height * 1.12);
    const steps = 26;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final base = Offset.lerp(start, end, t)!;
      final jitter = Offset(
        (rng.nextDouble() - 0.5) * size.width * 0.14,
        (rng.nextDouble() - 0.5) * size.height * 0.06,
      );
      final radius = size.width * (0.16 + rng.nextDouble() * 0.12);
      canvas.drawCircle(
        base + jitter,
        radius,
        Paint()
          ..color = (i.isEven ? palette.glow : Colors.white)
              .withValues(alpha: 0.03)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.09),
      );
    }
    canvas.restore();
  }

  void _stars(
    Canvas canvas,
    Size size,
    Offset off, {
    required int seed,
    required int count,
    required double rMin,
    required double rMax,
    required double alpha,
  }) {
    final rng = math.Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < count; i++) {
      // Campo generato su un'area piu' ampia dello schermo, cosi' scorrendo non
      // compaiono bordi vuoti.
      final x = (-0.5 + rng.nextDouble() * 2.0) * size.width + off.dx;
      final y = (-0.4 + rng.nextDouble() * 1.8) * size.height + off.dy;
      final m = rng.nextDouble();
      final r = rMin + m * (rMax - rMin);
      final a = (alpha * (0.4 + 0.6 * m)).clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), r, paint);
      // Qualche stella piu' brillante ha un piccolo alone caldo.
      if (m > 0.94) {
        canvas.drawCircle(
          Offset(x, y),
          r * 2.6,
          Paint()
            ..color = palette.goldSoft.withValues(alpha: 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }

  void _ambient(Canvas canvas, Size size, Offset off) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.16);
    final scale = size.width * 0.2;
    for (final (fig, anchor) in ambient) {
      final center = Offset(anchor.dx * size.width, anchor.dy * size.height) + off;
      Offset map(Offset p) =>
          center + Offset((p.dx - 0.5) * scale, (p.dy - 0.5) * scale);
      final pts = fig.stars.map(map).toList();
      for (final (a, b) in fig.lines) {
        canvas.drawLine(pts[a], pts[b], line);
      }
      for (var i = 0; i < pts.length; i++) {
        final m = fig.mag[i];
        canvas.drawCircle(
          pts[i],
          0.9 + m * 1.4,
          Paint()..color = Colors.white.withValues(alpha: 0.28 + 0.4 * m),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SkyFieldPainter old) =>
      old.cam != cam || old.palette != palette;
}

/// Scheda in basso: se un corpo e' scelto ne mostra etichetta e riga; altrimenti
/// invita a toccare il cielo. In coda, la nota in-world sui pianeti.
class _SkyInfoCard extends StatelessWidget {
  const _SkyInfoCard({
    required this.selected,
    required this.palette,
    this.oriented = false,
    this.birth = false,
  });

  final _SkyBody? selected;
  final MaestroPalette palette;

  /// Se il cielo e' orientato sul luogo reale dell'utente.
  final bool oriented;

  /// Se e' il cielo di nascita: la voce di Medora parla dell'identita'.
  final bool birth;

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
            palette.surfaceElevated.withValues(alpha: 0.88),
            palette.deepest.withValues(alpha: 0.88),
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
            s?.label ??
                (birth ? 'Il cielo della tua nascita' : 'Il cielo di stanotte'),
            style: TypographyTokens.display(size: 18)
                .copyWith(color: palette.goldSoft),
          ),
          const SizedBox(height: 4),
          Text(
            s?.description ??
                (birth
                    ? 'La volta che ti ha accolto nella tua prima notte. Sfiora '
                        'il cielo, poi tocca la Luna o una costellazione per '
                        'sapere cosa vegliava su di te.'
                    : 'Sfiora il cielo col dito o inclina il telefono, poi '
                        'tocca la Luna o una costellazione per sapere cosa è.'),
            style: TypographyTokens.body(size: 14)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Nota in-world, piccola ed elegante.
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 13, color: palette.goldSoft),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  birth
                      ? 'Veduta d\'esempio finché non registri nascita e luogo. '
                          'La volta esatta viene dal motore a effemeridi.'
                      : oriented
                          ? 'Orientato sul tuo luogo. La volta piena in '
                              'alt-azimut è custodita dal motore a effemeridi.'
                          : 'I pianeti si uniranno presto al tuo cielo.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.label(size: 10).copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.7),
                    letterSpacing: 0.4,
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

/// Una scelta di formato nel foglio di condivisione.
class _FormatOption extends StatelessWidget {
  const _FormatOption({
    required this.itemKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onTap,
  });

  final Key itemKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: itemKey,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm, vertical: SpacingTokens.sm),
        child: Row(
          children: [
            Icon(icon, color: palette.goldSoft, size: 26),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TypographyTokens.display(size: 17)),
                  Text(
                    subtitle,
                    style: TypographyTokens.body(size: 13)
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
          ],
        ),
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
