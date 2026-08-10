import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/face/face_classifier.dart';
import '../../../../core/face/face_corpus.dart';
import '../../../../core/face/face_trait.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'face_constellation.dart';
import 'face_constellation_painter.dart';
import 'face_silhouette.dart';

/// La card condivisibile della Costellazione del Viso, nella cornice verde e oro
/// di Aura, coerente con la card del Test Archetipo.
///
/// Il volto sta sotto, molto sbiadito, e la COSTELLAZIONE sopra e' molto
/// visibile, con contrasto e luminosita' alzati: e' lei la protagonista. In alto
/// la provenienza, poi il titolo evocativo, la sintesi breve, i tratti
/// principali, in fondo la firma e l'invito. L'altezza si adatta al contenuto.
class FaceShareCard extends StatelessWidget {
  const FaceShareCard({
    super.key,
    required this.reading,
    required this.costellazione,
    this.fotoPath,
  });

  final FaceReading reading;
  final FaceConstellation costellazione;
  final String? fotoPath;

  static const double larghezza = 400;
  static const double _latoVolto = 300;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    final dom = reading.dominante;
    final principali = reading.marcati.take(4).toList();
    return Container(
      key: const Key('face_share_card'),
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
            Text('COSTELLAZIONE DEL VISO',
                style: TypographyTokens.label(size: 12).copyWith(
                    color: palette.goldSoft, letterSpacing: 2.0)),
            const SizedBox(height: SpacingTokens.md),
            // Il volto sbiadito con la costellazione molto accesa sopra.
            SizedBox(
              width: _latoVolto,
              height: _latoVolto,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: fotoPath != null ? 0.35 : 0.6,
                      child: fotoPath != null
                          ? Image.file(File(fotoPath!), fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _Sagoma(palette: palette))
                          : _Sagoma(palette: palette),
                    ),
                    CustomPaint(
                      painter: FaceConstellationPainter(
                        costellazione: costellazione,
                        palette: palette,
                        pulsazione: 1.0,
                        risalto: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(dom.titoloEvocativo,
                textAlign: TextAlign.center,
                style: TypographyTokens.display(size: 24)
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: 2),
            Text(dom.nome,
                style: TypographyTokens.label(size: 12).copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.85),
                    letterSpacing: 0.5)),
            const SizedBox(height: SpacingTokens.xs),
            // La sintesi breve: la frase del tratto dominante.
            Text(FaceCorpus.frase(dom),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo().copyWith(
                    color: palette.textPrimary, fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.md),
            for (final t in principali)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, size: 15, color: palette.goldSoft),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(t.nome,
                          style: TypographyTokens.corpo().copyWith(
                              color: t == dom
                                  ? palette.goldSoft
                                  : palette.textPrimary,
                              fontWeight: t == dom
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: SpacingTokens.sm),
            Text('Esoteric Circle · Aura',
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text('Scopri la tua costellazione su Esoteric Circle',
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.6),
                    letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _Sagoma extends StatelessWidget {
  const _Sagoma({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: [
          palette.surfaceElevated.withValues(alpha: 0.6),
          palette.deepest.withValues(alpha: 0.9),
        ]),
      ),
      child: CustomPaint(painter: FaceSilhouettePainter(palette: palette)),
    );
  }
}

/// Genera la card come PNG dal boundary e apre il foglio di condivisione.
Future<bool> shareFaceCard({
  required GlobalKey boundaryKey,
  required FaceTrait dominante,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/costellazione_viso_${dominante.name}.png');
  await file.writeAsBytes(png, flush: true);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'La mia Costellazione del Viso dice "${dominante.titoloEvocativo}". '
          'Scopri la tua con Aura, su Esoteric Circle.',
    ),
  );
  return true;
}
