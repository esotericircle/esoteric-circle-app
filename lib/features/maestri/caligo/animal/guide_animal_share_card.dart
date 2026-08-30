import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../core/rituals/animal_catalog.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import '../../../../core/condivisione/porta_della_condivisione.dart';

/// La card condivisibile dell'Animale Guida, nella cornice oro e rossa di
/// Caligo. Il totem sul cielo del profilo, il nome, la sintesi, l'origine dal
/// segno o dall'archetipo, la firma e l'invito.
class GuideAnimalShareCard extends StatelessWidget {
  const GuideAnimalShareCard({
    super.key,
    required this.animal,
    required this.origine,
  });

  final GuideAnimal animal;

  /// La riga d'origine: dal segno solare, oppure dall'archetipo quando c'e'.
  final String origine;

  static const double larghezza = 400;
  static const double _latoTotem = 300;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    return Container(
      key: const Key('guide_animal_share_card'),
      width: larghezza,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.75), width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ANIMALE GUIDA',
                style: TypographyTokens.label(size: 12).copyWith(
                    color: palette.goldSoft, letterSpacing: 2.0)),
            const SizedBox(height: SpacingTokens.md),
            // Il totem sul cielo del profilo: la wow, l'animale composto col cosmo.
            SizedBox(
              width: _latoTotem,
              height: _latoTotem,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  CustomPaint(painter: _CieloPainter(palette: palette)),
                  Image.asset(animal.fullPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.pets,
                          size: 150, color: palette.goldSoft)),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(animal.name.toUpperCase(),
                style: TypographyTokens.cerimoniale()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: 2),
            Text(animal.summary,
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo().copyWith(
                    color: palette.textPrimary, fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.sm),
            Text(origine,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.75),
                    letterSpacing: 0.5)),
            const SizedBox(height: SpacingTokens.md),
            Text('Esoteric Circle · Caligo',
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text('Scopri il tuo animale guida su Esoteric Circle',
                style: TypographyTokens.corpo().copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.6),
                    letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

/// Il cielo dietro il totem: stelle e un alone caldo, deterministico, cosi' la
/// card compone l'animale col cosmo senza casualita'.
class _CieloPainter extends CustomPainter {
  _CieloPainter({required this.palette});

  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.45);
    canvas.drawCircle(
      c,
      size.shortestSide * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.primary.withValues(alpha: 0.35),
          palette.deepest.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: c, radius: size.shortestSide * 0.5)),
    );
    // Stelle in posizioni fisse, deterministiche dall'indice.
    final stella = Paint()..color = palette.goldSoft;
    for (var i = 0; i < 40; i++) {
      final a = i * 2.399963; // angolo aureo
      final r = size.shortestSide * (0.12 + 0.36 * ((i * 37) % 100) / 100);
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      final raggio = 0.6 + ((i * 13) % 5) * 0.35;
      canvas.drawCircle(
          p, raggio, stella..color = palette.goldSoft.withValues(alpha: 0.5 + 0.5 * ((i * 7) % 10) / 10));
    }
  }

  @override
  bool shouldRepaint(_CieloPainter old) => false;
}

/// Genera la card come PNG dal boundary e apre il foglio di condivisione.
Future<bool> shareGuideAnimalCard({
  required GlobalKey boundaryKey,
  required GuideAnimal animal,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/animale_guida_${animal.stem}.png');
  await file.writeAsBytes(png, flush: true);
  // Ordine BG voce 04: l'esito VERO della porta risale al chiamante,
  // che a condivisione avvenuta paga il premio dichiarato sul pulsante.
  return PortaDellaCondivisione.daFile(file.path, testo: 'Il mio animale guida è ${animal.name}. '
          'Scopri il tuo con Caligo, su Esoteric Circle.');
}
