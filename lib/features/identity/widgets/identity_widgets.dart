import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/astro/birth_details.dart';
import '../../../core/astro/celestial.dart';
import '../../../core/identity/natal_identity.dart';
import '../../../design_system/components/depth_card.dart';
import '../../../design_system/components/immersive_scaffold.dart';
import '../../../design_system/components/life_number_emblem.dart';
import '../../../design_system/components/moon_phase_emblem.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../onboarding/birth_sky_hero.dart';

/// I fatti identitari fissi (fase lunare di nascita e numero della vita), come
/// coppia di carte. Riusati dalla carta natale e dal profilo, pronti per il
/// Cosmic Passport.
class IdentityFactsSection extends StatelessWidget {
  const IdentityFactsSection({super.key, required this.facts});
  final NatalFacts facts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MoonPhaseFactCard(facts: facts),
        const SizedBox(height: SpacingTokens.sm),
        LifeNumberFactCard(facts: facts),
      ],
    );
  }
}

/// La fase della Luna del giorno di nascita, col segno lunare.
class MoonPhaseFactCard extends StatelessWidget {
  const MoonPhaseFactCard({super.key, required this.facts});
  final NatalFacts facts;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final sign = facts.moonSign;
    return DepthCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoonPhaseEmblem(phase: facts.moonPhase, size: 58),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LA TUA LUNA DI NASCITA',
                    style: TypographyTokens.label(size: 12.5)
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(
                  sign != null
                      ? '${facts.moonPhaseName} in ${sign.italianName}'
                      : facts.moonPhaseName,
                  style: TypographyTokens.display(size: 19),
                ),
                const SizedBox(height: 4),
                Text(facts.moonMeaning,
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Il numero della vita col suo emblema a sigillo.
class LifeNumberFactCard extends StatelessWidget {
  const LifeNumberFactCard({super.key, required this.facts});
  final NatalFacts facts;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LifeNumberEmblem(number: facts.lifeNumber, palette: palette, size: 60),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IL TUO NUMERO DELLA VITA',
                    style: TypographyTokens.label(size: 12.5)
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text('${facts.lifeNumber}, ${facts.lifeTitle}',
                    style: TypographyTokens.display(size: 19)),
                const SizedBox(height: 4),
                Text(facts.lifeMeaning,
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Il portale al cielo reale della nascita: un piccolo cielo vivo che al tocco
/// riapre il momento a tutto schermo. Sostituisce il vecchio bagliore in cima
/// alla carta e tiene quel cielo raggiungibile (domani anche dal Cosmic
/// Passport).
class BirthSkyPortal extends StatefulWidget {
  const BirthSkyPortal({
    super.key,
    required this.details,
    this.moonPhase,
  });

  final BirthDetails details;
  final MoonIllumination? moonPhase;

  @override
  State<BirthSkyPortal> createState() => _BirthSkyPortalState();
}

class _BirthSkyPortalState extends State<BirthSkyPortal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      onTap: () => openBirthSky(context, widget.details),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _PortalSkyPainter(
                  t: _c.value,
                  moonPhase: widget.moonPhase,
                  gold: palette.goldSoft,
                ),
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Il tuo cielo di nascita',
                    style: TypographyTokens.display(size: 19)),
                const SizedBox(height: 4),
                Text('Tocca per rivedere il cielo autentico della tua notte.',
                    style: TypographyTokens.body(size: 15).copyWith(
                        color: ColorTokens.textSecondary, height: 1.35)),
              ],
            ),
          ),
          Icon(Icons.north_east_rounded, color: palette.goldSoft, size: 22),
        ],
      ),
    );
  }
}

/// Apre il cielo reale della nascita a tutto schermo, con il ritorno alla carta.
void openBirthSky(BuildContext context, BirthDetails details) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (routeContext) => MaestroScope(
      child: ImmersiveScaffold(
        child: BirthSkyHero(
          details: details,
          ctaLabel: 'Torna alla carta',
          onContinue: () => Navigator.of(routeContext).pop(),
        ),
      ),
    ),
  ));
}

class _PortalSkyPainter extends CustomPainter {
  _PortalSkyPainter({required this.t, required this.moonPhase, required this.gold});
  final double t;
  final MoonIllumination? moonPhase;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Cornice tonda a vetro.
    canvas.drawCircle(
        c,
        size.width * 0.46,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = gold.withValues(alpha: 0.5));
    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: c, radius: size.width * 0.45)));
    canvas.drawCircle(c, size.width * 0.45,
        Paint()..color = const Color(0xFF0B1030));

    // Una piccola costellazione viva.
    final pts = <Offset>[
      Offset(size.width * 0.28, size.height * 0.34),
      Offset(size.width * 0.44, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.62, size.height * 0.42),
    ];
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = gold.withValues(alpha: 0.4);
    for (var i = 0; i < pts.length - 1; i++) {
      canvas.drawLine(pts[i], pts[i + 1], line);
    }
    for (var i = 0; i < pts.length; i++) {
      final tw = 0.6 + 0.4 * math.sin(t * 2 * math.pi * 2 + i);
      canvas.drawCircle(
          pts[i], 1.4, Paint()..color = Colors.white.withValues(alpha: tw));
    }

    // La Luna nella sua fase reale, in alto a destra.
    if (moonPhase != null) {
      paintMoonPhase(
          canvas, Offset(size.width * 0.68, size.height * 0.66), size.width * 0.12,
          fraction: moonPhase!.fraction, waxing: moonPhase!.waxing, glow: false);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PortalSkyPainter old) => old.t != t;
}
