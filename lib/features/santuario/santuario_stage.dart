import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/astro/celestial.dart';
import '../../core/astro/zodiac.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/quality/quality_tier.dart';
import '../../design_system/components/moon_phase_emblem.dart';
import '../../design_system/components/zodiac_figures.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../home/widgets/demo_controls.dart';
import 'widgets/maestro_bust.dart';

/// Il Santuario, la schermata eroe: un palco unico e neutro con la Luna in alto
/// e molto buio attorno; i tre Maestri in busto, al centro l'ultimo usato e piu'
/// grande, gli altri due arretrati ai lati. Solo il centrale e' vivo.
///
/// Elevazioni: il cielo e' quello di adesso (Luna nella fase reale attuale,
/// atmosfera che segue l'ora); reagisce al cielo del giorno (Luna piena cambia
/// l'atmosfera e fa un passo avanti il Maestro competente); il cerchio visibile
/// (un filo d'oro unisce i tre); il Santuario si popola con le identita'
/// conquistate (per ora la costellazione del segno). Quality Tier ovunque.
/// Solo per l'anteprima: forza un istante di Luna piena con
/// `--dart-define=DEMO_FULLMOON=true`, per rivedere l'elevazione del cielo del
/// giorno. Vuoto in produzione, dove conta l'ora reale.
const bool _kDemoFullMoon = bool.fromEnvironment('DEMO_FULLMOON');

class SantuarioStage extends StatefulWidget {
  const SantuarioStage({super.key, this.now});

  /// Istante di riferimento; se null si usa l'ora reale. Iniettabile per test e
  /// per dimostrare casi come la Luna piena.
  final DateTime? now;

  @override
  State<SantuarioStage> createState() => _SantuarioStageState();
}

class _SantuarioStageState extends State<SantuarioStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final DateTime _now;
  late final MoonIllumination _moon;
  Maestro? _featured;
  bool _userChose = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    _now = widget.now ??
        (_kDemoFullMoon ? DateTime(1990, 6, 8, 22) : DateTime.now());
    _moon = Celestial.moonIllumination(Celestial.julianDay(_now.toUtc()));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool get _fullMoon => _moon.fraction > 0.96;

  /// Il Maestro competente per l'evento del giorno (per ora la Luna piena, che
  /// e' cielo e destino, quindi Medora). Predisposto per altri transiti.
  Maestro get _competentToday => Maestro.medora;

  /// Ritorno solare: oggi e' il compleanno.
  bool _isSolarReturn(DateTime? birth) =>
      birth != null && birth.day == _now.day && birth.month == _now.month;

  void _cycle(int dir, List<Maestro> order) {
    final cur = _featured ?? order.first;
    final i = (order.indexOf(cur) + dir) % order.length;
    setState(() {
      _userChose = true;
      _featured = order[(i + order.length) % order.length];
    });
    HapticFeedback.selectionClick();
    // Ricorda l'ultimo usato, senza cambiare la tab attiva.
    context.read<MaestroController>().rememberLast(_featured!);
  }

  @override
  Widget build(BuildContext context) {
    final tier = context.watch<QualityTierController>().tier;
    final last = context.watch<MaestroController>().lastMaestro;
    final sun = context.watch<ZodiacController>().sunSign;
    final birth = context.watch<BirthIdentityController>().facts?.birthDate;

    // Ordine fisso; il centrale ruota come un carosello.
    const order = [Maestro.medora, Maestro.aura, Maestro.caligo];
    // Default: l'ultimo usato; su Luna piena si fa avanti il competente, finche'
    // l'utente non sceglie diversamente.
    final featured = _featured ??
        (_fullMoon && !_userChose ? _competentToday : last);
    final palette = MaestroPalette.forKey(ThemeKey.of(featured));
    final solarReturn = _isSolarReturn(birth);

    final ci = order.indexOf(featured);
    final left = order[(ci - 1 + order.length) % order.length];
    final right = order[(ci + 1) % order.length];

    return SafeArea(
      bottom: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v < -120) _cycle(1, order);
          if (v > 120) _cycle(-1, order);
        },
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          final centerW = w * 0.52;
          final sideW = w * 0.34;
          final baseY = h * 0.86; // i piedi dei busti
          final centerX = w / 2;
          final sideDX = w * 0.30;

          return Stack(
            children: [
              // Atmosfera: accento del Maestro, ora locale, Luna piena, e la
              // costellazione del segno come identita' conquistata.
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) => CustomPaint(
                    painter: _StagePainter(
                      t: _pulse.value,
                      glow: palette.glow,
                      gold: palette.goldSoft,
                      hour: _now.hour,
                      fullMoon: _fullMoon,
                      solarReturn: solarReturn,
                      sunSign: sun,
                      tier: tier,
                      leftAnchor: Offset(centerX - sideDX, baseY - sideW * 0.9),
                      centerAnchor: Offset(centerX, baseY - centerW * 0.9),
                      rightAnchor: Offset(centerX + sideDX, baseY - sideW * 0.9),
                    ),
                  ),
                ),
              ),

              // La Luna reale di adesso, in alto.
              Positioned(
                top: h * 0.015,
                left: 0,
                right: 0,
                child: Center(
                  child: MoonPhaseEmblem(
                    phase: _moon,
                    size: _fullMoon ? 84 : 66,
                    animate: tier != QualityTier.low,
                  ),
                ),
              ),

              // Barra degli appuntamenti, consapevole dell'ora.
              Positioned(
                top: h * 0.14,
                left: SpacingTokens.lg,
                right: SpacingTokens.lg,
                child: _AppointmentBar(
                  label: _appointmentLabel(solarReturn),
                  palette: palette,
                  pulse: _pulse,
                  tier: tier,
                ),
              ),

              // I tre busti: laterali arretrati, centrale grande e vivo.
              Positioned(
                left: centerX - sideDX - sideW / 2,
                bottom: h - baseY - sideW * 0.1,
                child: MaestroBust(
                  maestro: left,
                  palette: MaestroPalette.forKey(ThemeKey.of(left)),
                  featured: false,
                  width: sideW,
                  alive: tier != QualityTier.low,
                ),
              ),
              Positioned(
                left: centerX + sideDX - sideW / 2,
                bottom: h - baseY - sideW * 0.1,
                child: MaestroBust(
                  maestro: right,
                  palette: MaestroPalette.forKey(ThemeKey.of(right)),
                  featured: false,
                  width: sideW,
                  alive: tier != QualityTier.low,
                ),
              ),
              Positioned(
                left: centerX - centerW / 2,
                bottom: h - baseY,
                child: GestureDetector(
                  onTap: () {}, // il centrale e' gia' in scena
                  child: MaestroBust(
                    maestro: featured,
                    palette: palette,
                    featured: true,
                    width: centerW,
                    alive: tier != QualityTier.low &&
                        !MediaQuery.of(context).disableAnimations,
                  ),
                ),
              ),

              // Tocca un laterale per portarlo al centro.
              Positioned(
                left: 0,
                bottom: h - baseY - sideW,
                width: sideW,
                height: sideW * 1.4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _cycle(-1, order),
                ),
              ),
              Positioned(
                right: 0,
                bottom: h - baseY - sideW,
                width: sideW,
                height: sideW * 1.4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _cycle(1, order),
                ),
              ),

              // Nome del Maestro centrale e, su evento, la sua frase.
              Positioned(
                left: SpacingTokens.lg,
                right: SpacingTokens.lg,
                bottom: SpacingTokens.md,
                child: _FeaturedCaption(
                  maestro: featured,
                  palette: palette,
                  eventPhrase: _eventPhrase(featured, solarReturn),
                ),
              ),

              // Controlli dimostrativi (Quality Tier), solo per la revisione.
              Positioned(
                top: 0,
                right: SpacingTokens.xs,
                child: IconButton(
                  tooltip: 'Controlli dimostrativi',
                  icon: Icon(Icons.tune_rounded, color: palette.goldSoft),
                  onPressed: () => showDemoControls(context),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _appointmentLabel(bool solarReturn) => santuarioAppointment(
      hour: _now.hour, fullMoon: _fullMoon, solarReturn: solarReturn);

  String? _eventPhrase(Maestro featured, bool solarReturn) {
    if (solarReturn) {
      return 'Oggi il Sole torna dove sei nato. Il cerchio e\' in festa per te.';
    }
    if (_fullMoon && featured == _competentToday) {
      return 'La Luna e\' piena stanotte: alza lo sguardo, e\' tempo di guardare in alto.';
    }
    return null;
  }
}

/// L'appuntamento del momento, consapevole dell'ora e degli eventi del cielo.
/// Il ritorno solare e la Luna piena hanno la precedenza.
String santuarioAppointment({
  required int hour,
  required bool fullMoon,
  required bool solarReturn,
}) {
  if (solarReturn) return 'Il tuo Ritorno Solare';
  if (fullMoon) return 'Rito della Luna Piena';
  if (hour >= 5 && hour < 8) return 'Rito dell\'Alba';
  if (hour >= 8 && hour < 13) return 'Oracolo del Giorno';
  if (hour >= 13 && hour < 18) return 'Carta del Pomeriggio';
  if (hour >= 18 && hour < 22) return 'Runa del Tramonto';
  return 'Soffio della Notte';
}

class _AppointmentBar extends StatelessWidget {
  const _AppointmentBar({
    required this.label,
    required this.palette,
    required this.pulse,
    required this.tier,
  });

  final String label;
  final MaestroPalette palette;
  final Animation<double> pulse;
  final QualityTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Il punto dell'appuntamento del momento pulsa in sintonia.
          AnimatedBuilder(
            animation: pulse,
            builder: (context, _) {
              final a = tier == QualityTier.low
                  ? 0.8
                  : 0.4 + 0.6 * (0.5 + 0.5 * math.sin(pulse.value * 2 * math.pi));
              return Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.goldSoft.withValues(alpha: a),
                  boxShadow: tier == QualityTier.high
                      ? [
                          BoxShadow(
                              color: palette.glow.withValues(alpha: a),
                              blurRadius: 8,
                              spreadRadius: 1)
                        ]
                      : null,
                ),
              );
            },
          ),
          const SizedBox(width: SpacingTokens.xs),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.body(size: 16, weight: 600)
                    .copyWith(color: palette.goldSoft)),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCaption extends StatelessWidget {
  const _FeaturedCaption({
    required this.maestro,
    required this.palette,
    required this.eventPhrase,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final String? eventPhrase;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eventPhrase != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
            ),
            child: Text('${maestro.displayName}: $eventPhrase',
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 16)
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
        Text(maestro.displayName,
            style: TypographyTokens.display(size: 26)
                .copyWith(color: palette.goldSoft)),
        const SizedBox(height: 2),
        Text(maestro.tagline,
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textSecondary)),
      ],
    );
  }
}

class _StagePainter extends CustomPainter {
  _StagePainter({
    required this.t,
    required this.glow,
    required this.gold,
    required this.hour,
    required this.fullMoon,
    required this.solarReturn,
    required this.sunSign,
    required this.tier,
    required this.leftAnchor,
    required this.centerAnchor,
    required this.rightAnchor,
  });

  final double t;
  final Color glow;
  final Color gold;
  final int hour;
  final bool fullMoon;
  final bool solarReturn;
  final Zodiac? sunSign;
  final QualityTier tier;
  final Offset leftAnchor;
  final Offset centerAnchor;
  final Offset rightAnchor;

  bool get _rich => tier == QualityTier.high;

  @override
  void paint(Canvas canvas, Size size) {
    // Atmosfera dell'ora: una tinta che segue il momento del giorno.
    final hourTint = _hourTint();
    if (hourTint.a > 0) {
      canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [hourTint, Colors.transparent],
            ).createShader(Offset.zero & size));
    }

    // Luna piena: un velo d'argento freddo sull'intera scena.
    if (fullMoon) {
      canvas.drawRect(
          Offset.zero & size,
          Paint()..color = const Color(0xFFBFD0E8).withValues(alpha: 0.06));
    }

    // Cosmo che vira all'accento del Maestro centrale: un grande alone dietro.
    canvas.drawCircle(
        centerAnchor.translate(0, -size.height * 0.05),
        size.width * 0.62,
        Paint()
          ..shader = RadialGradient(
            colors: [
              glow.withValues(alpha: 0.20),
              glow.withValues(alpha: 0.06),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(
              center: centerAnchor.translate(0, -size.height * 0.05),
              radius: size.width * 0.62)));

    // Identita' conquistata: la costellazione del segno solare, in alto, come
    // presenza acquisita del profilo. Architettata per crescere (Angelo,
    // archetipo, Animale Guida verranno accanto).
    if (sunSign != null) _sunConstellation(canvas, size, sunSign!);

    // Il cerchio visibile: un filo d'oro che unisce i tre Maestri.
    _circleThread(canvas, size);

    // Ritorno solare: la festa, scintille dorate che salgono.
    if (solarReturn && _rich) _celebration(canvas, size);
  }

  Color _hourTint() {
    // Alba calda, giorno azzurro, tramonto viola, notte profonda.
    if (hour >= 5 && hour < 8) return const Color(0xFFE0A06A).withValues(alpha: 0.10);
    if (hour >= 8 && hour < 17) return const Color(0xFF3E6DA8).withValues(alpha: 0.08);
    if (hour >= 17 && hour < 21) return const Color(0xFF7A5AA8).withValues(alpha: 0.12);
    return const Color(0xFF0B1030).withValues(alpha: 0.14);
  }

  void _sunConstellation(Canvas canvas, Size size, Zodiac sign) {
    ZodiacConstellation? fig;
    for (final c in kZodiacConstellations) {
      if (c.sign == sign) {
        fig = c;
        break;
      }
    }
    if (fig == null) return;
    // Collocata in alto, sotto la Luna.
    final anchor = Offset(size.width * 0.5, size.height * 0.30);
    final scale = size.width * 0.34;
    Offset at(Offset p) =>
        anchor + Offset((p.dx - 0.5) * scale, (p.dy - 0.5) * scale);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gold.withValues(alpha: 0.28);
    for (final (a, b) in fig.edges) {
      canvas.drawLine(at(fig.points[a]), at(fig.points[b]), line);
    }
    for (final p in fig.points) {
      final tw = _rich ? 0.6 + 0.4 * math.sin(t * 2 * math.pi + p.dx * 6) : 1.0;
      canvas.drawCircle(at(p), 1.6, Paint()..color = gold.withValues(alpha: 0.8 * tw));
    }
  }

  void _circleThread(Canvas canvas, Size size) {
    final a = leftAnchor, b = centerAnchor, c = rightAnchor;
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(
          (a.dx + b.dx) / 2, b.dy - size.height * 0.02, b.dx, b.dy)
      ..quadraticBezierTo(
          (b.dx + c.dx) / 2, b.dy - size.height * 0.02, c.dx, c.dy);
    if (_rich) {
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = gold.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = gold.withValues(alpha: 0.5));
    // Nodi luminosi ai tre ancoraggi.
    for (final p in [a, b, c]) {
      canvas.drawCircle(p, 3, Paint()..color = gold.withValues(alpha: 0.8));
    }
    // Scintilla che scorre lungo il filo.
    if (_rich) {
      final metric = path.computeMetrics().first;
      final pos = metric.getTangentForOffset(metric.length * (t % 1.0))?.position;
      if (pos != null) {
        canvas.drawCircle(
            pos,
            2.4,
            Paint()
              ..color = Colors.white.withValues(alpha: 0.9)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      }
    }
  }

  void _celebration(Canvas canvas, Size size) {
    final rng = math.Random(7);
    for (var i = 0; i < 24; i++) {
      final f = ((t * 1.5 + rng.nextDouble()) % 1.0);
      final x = rng.nextDouble() * size.width;
      final y = size.height * (1 - f);
      canvas.drawCircle(
          Offset(x, y),
          1 + rng.nextDouble() * 1.5,
          Paint()..color = gold.withValues(alpha: (0.8 * (1 - f)).clamp(0.0, 0.8)));
    }
  }

  @override
  bool shouldRepaint(_StagePainter old) => old.t != t;
}
