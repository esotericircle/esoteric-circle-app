import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/spacing_tokens.dart';

/// Un mezzo busto del Maestro davanti al palco del Santuario, dentro la sua
/// carta in formato ritratto con cornice dorata lavorata, stile tarocco.
///
/// La testa esce dal bordo alto della cornice, che resta un piano dietro: e' li'
/// che scatta il 2.5D. Il master full body e' segnaposto in attesa del crop a
/// mezzo busto; il codice lo anima soltanto (respiro e aura del centrale). I
/// busti laterali restano piu' scuri, arretrati e quasi fermi: si smorza la
/// sola figura scontornata, mai un rettangolo dietro.
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

  /// Vero per il Maestro preferito, con un marcatore discreto sulla cornice.
  final bool preferred;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    // Carta in formato ritratto, piu' alta che larga, come un tarocco.
    final frameWidth = height * 0.58;
    final frameHeight = height * 0.84;
    final floatY = central ? (breath - 0.5) * 8 : 0.0;
    final auraPulse = 0.5 + 0.5 * breath;

    // La sola figura si scurisce, rispettando l'alpha del PNG: nessun velo
    // rettangolare dietro. srcATop tinge solo i pixel opachi del master.
    final Color? figureTint =
        dim > 0 ? Colors.black.withValues(alpha: dim * 0.5) : null;

    Widget bust = SizedBox(
      width: frameWidth * 1.3,
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
                width: frameWidth * 1.7,
                height: frameWidth * 1.7,
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
          // La carta con la cornice dorata lavorata, un piano dietro.
          Positioned(
            bottom: 0,
            child: _MaestroFrame(
              width: frameWidth,
              height: frameHeight,
              palette: palette,
              central: central,
            ),
          ),
          // Il busto: master full body, allineato in basso e piu' alto della
          // cornice, cosi' la testa rompe il bordo alto. La figura si scurisce
          // via colorBlendMode, che rispetta la trasparenza del PNG.
          Transform.translate(
            offset: Offset(0, floatY),
            child: Image.asset(
              maestro.avatarAsset,
              height: height,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              color: figureTint,
              colorBlendMode: BlendMode.srcATop,
              errorBuilder: (context, error, stack) => _fallback(palette),
            ),
          ),
          // Marcatore del preferito: un piccolo rombo dorato discreto,
          // incastonato al centro del bordo basso della carta.
          if (preferred)
            Positioned(
              bottom: -3,
              child: _PreferredGem(color: palette.goldSoft),
            ),
        ],
      ),
    );

    // I laterali sono arretrati: solo un velo di opacita' complessiva, senza
    // alcun rettangolo scuro (la penombra della figura la da' figureTint).
    if (dim > 0) {
      bust = Opacity(opacity: 1 - dim * 0.28, child: bust);
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

/// La carta del Maestro: cornice dorata a doppio filo con fioroni agli angoli,
/// stile tarocco, tinta sulla palette del Maestro. E' la finestra da cui il
/// mezzo busto sporge in avanti.
class _MaestroFrame extends StatelessWidget {
  const _MaestroFrame({
    required this.width,
    required this.height,
    required this.palette,
    required this.central,
  });

  final double width;
  final double height;
  final MaestroPalette palette;
  final bool central;

  @override
  Widget build(BuildContext context) {
    final double outerAlpha = central ? 0.85 : 0.5;
    final double innerAlpha = central ? 0.6 : 0.35;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.95),
            palette.deepest.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(
          color: palette.gold.withValues(alpha: outerAlpha),
          width: 2,
        ),
        boxShadow: central
            ? [
                BoxShadow(
                  color: palette.glow.withValues(alpha: 0.35),
                  blurRadius: 34,
                  spreadRadius: -6,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Secondo filo dorato interno, il tratto lavorato della cornice.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusMd),
                  border: Border.all(
                    color: palette.goldSoft.withValues(alpha: innerAlpha),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          // Fioroni: quattro piccoli rombi dorati agli angoli interni.
          for (final a in const [
            Alignment.topLeft,
            Alignment.topRight,
            Alignment.bottomLeft,
            Alignment.bottomRight,
          ])
            Align(
              alignment: a,
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: _Diamond(
                  size: 5,
                  color: palette.goldSoft.withValues(alpha: outerAlpha),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Piccolo rombo dorato, gemma del marcatore del preferito.
class _PreferredGem extends StatelessWidget {
  const _PreferredGem({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.14),
      ),
      child: _Diamond(size: 7, color: color),
    );
  }
}

/// Un rombo pieno, mattone ornamentale della cornice.
class _Diamond extends StatelessWidget {
  const _Diamond({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(width: size, height: size, color: color),
    );
  }
}
