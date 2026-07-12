import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/spacing_tokens.dart';

/// Un mezzo busto del Maestro davanti al palco del Santuario, dentro la sua
/// cornice a carta 2.5D.
///
/// La testa esce dal bordo alto della cornice, che resta un piano dietro: e' li'
/// che scatta il 2.5D. Il master full body e' segnaposto in attesa del crop a
/// mezzo busto; il codice lo anima soltanto (respiro e aura del centrale). I
/// busti laterali restano piu' scuri, arretrati e quasi fermi.
class MaestroBust extends StatelessWidget {
  const MaestroBust({
    super.key,
    required this.maestro,
    required this.height,
    required this.central,
    this.dim = 0.0,
    this.breath = 0.0,
    this.preferred = false,
  });

  final Maestro maestro;
  final double height;
  final bool central;

  /// Quanto scurire e arretrare il busto, da 0 (centrale, pieno) a 1.
  final double dim;

  /// Fase del respiro idle, da 0 a 1, usata solo dal centrale.
  final double breath;

  /// Vero per il Maestro preferito, con un marcatore discreto.
  final bool preferred;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    final frameWidth = height * 0.60;
    final frameHeight = height * 0.66;
    final floatY = central ? (breath - 0.5) * 8 : 0.0;
    final auraPulse = 0.5 + 0.5 * breath;

    Widget bust = SizedBox(
      width: frameWidth * 1.25,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Aura del Maestro dietro, viva solo per il centrale.
          if (central)
            Positioned(
              bottom: frameHeight * 0.2,
              child: Container(
                width: frameWidth * 1.6,
                height: frameWidth * 1.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.glow.withValues(alpha: 0.10 + 0.22 * auraPulse),
                      palette.primary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          // Cornice a carta coi colori del Maestro, un piano dietro.
          Positioned(
            bottom: 0,
            child: Container(
              width: frameWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.surfaceElevated.withValues(alpha: 0.95),
                    palette.deepest.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusLg),
                border: Border.all(
                  color: palette.gold.withValues(alpha: central ? 0.6 : 0.35),
                  width: 1.2,
                ),
                boxShadow: central
                    ? [
                        BoxShadow(
                          color: palette.glow.withValues(alpha: 0.35),
                          blurRadius: 30,
                          spreadRadius: -6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          // Il busto: master full body, allineato in basso e piu' alto della
          // cornice, cosi' la testa rompe il bordo alto.
          Transform.translate(
            offset: Offset(0, floatY),
            child: Image.asset(
              maestro.avatarAsset,
              height: height,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (context, error, stack) => _fallback(palette),
            ),
          ),
          if (preferred)
            Positioned(
              bottom: frameHeight - 10,
              right: frameWidth * 0.16,
              child: Icon(Icons.star_rounded,
                  color: palette.goldSoft, size: 18),
            ),
        ],
      ),
    );

    // I laterali sono piu' scuri e arretrati.
    if (dim > 0) {
      bust = Opacity(
        opacity: 1 - dim * 0.35,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: dim * 0.5),
            BlendMode.darken,
          ),
          child: bust,
        ),
      );
    }
    return bust;
  }

  Widget _fallback(MaestroPalette palette) {
    return Container(
      width: height * 0.4,
      height: height * 0.4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
      ),
      child:
          Icon(maestro.icon, color: palette.goldSoft, size: height * 0.16),
    );
  }
}
