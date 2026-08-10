import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/identity/birth_moon.dart';
import '../../core/rituals/dream_rite_corpus.dart';
import '../../design_system/components/zodiac_figures.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;

/// La carta della notte del Rito del Sogno: la costellazione unita, una parola
/// sola, la frase della notte e la provenienza dal cielo reale. Senza indirizzi
/// web inventati.
class DreamRiteCard extends StatelessWidget {
  const DreamRiteCard({
    super.key,
    required this.luna,
    required this.palette,
    required this.saluto,
    required this.maestroNome,
  });

  final BirthMoon luna;
  final MaestroPalette palette;
  final String saluto;
  final String maestroNome;

  static const double larghezza = 400;

  @override
  Widget build(BuildContext context) {
    final figura =
        kZodiacConstellations.firstWhere((c) => c.sign == luna.sign);
    return Container(
      key: const Key('dream_rite_card'),
      width: larghezza,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        border:
            Border.all(color: palette.gold.withValues(alpha: 0.75), width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('RITO DEL SOGNO',
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
            const SizedBox(height: SpacingTokens.md),
            // La costellazione unita, il disegno reale del segno della Luna.
            SizedBox(
              width: 220,
              height: 200,
              child: CustomPaint(
                painter: _FiguraUnitaPainter(figura: figura, palette: palette),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(DreamRiteCorpus.parola(luna.sign).toUpperCase(),
                style: TypographyTokens.display(size: 30)
                    .copyWith(color: palette.goldSoft, letterSpacing: 1.5)),
            const SizedBox(height: SpacingTokens.sm),
            Text(saluto,
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: palette.textPrimary, height: 1.5)),
            const SizedBox(height: SpacingTokens.md),
            Text(DreamRiteCorpus.provenienza(luna),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.85),
                    letterSpacing: 0.5)),
            const SizedBox(height: SpacingTokens.md),
            Text('Esoteric Circle · $maestroNome',
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text('Il cielo notturno reale di questa notte',
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo().copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.6),
                    letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

/// La costellazione tutta unita, stelle piu' fili d'oro, come resta a fine rito.
class _FiguraUnitaPainter extends CustomPainter {
  _FiguraUnitaPainter({required this.figura, required this.palette});

  final ZodiacConstellation figura;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    Offset map(Offset p) => Offset(
          (0.1 + p.dx * 0.8) * size.width,
          (0.1 + p.dy * 0.8) * size.height,
        );
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.8);
    for (final (a, b) in figura.edges) {
      canvas.drawLine(map(figura.points[a]), map(figura.points[b]), filo);
    }
    for (final p in figura.points) {
      final c = map(p);
      canvas.drawCircle(
          c,
          7,
          Paint()
            ..color = palette.goldSoft.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawCircle(c, 2.8, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_FiguraUnitaPainter old) => old.figura != figura;
}

/// Genera la carta come PNG dal boundary e apre il foglio di condivisione.
Future<bool> shareDreamRiteCard({
  required GlobalKey boundaryKey,
  required BirthMoon luna,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/rito_del_sogno_${luna.sign.id}.png');
  await file.writeAsBytes(png, flush: true);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'La mia notte con ${DreamRiteCorpus.provenienza(luna)}. '
          'Il Rito del Sogno, su Esoteric Circle.',
    ),
  );
  return true;
}
