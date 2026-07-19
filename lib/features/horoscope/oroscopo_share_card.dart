import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/astro/zodiac.dart';
import '../../core/horoscope/horoscope.dart';
import '../../core/horoscope/horoscope_data.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'horoscope_visuals.dart';
import 'oroscopo_colors.dart';

/// La card verticale condivisibile dell'Oroscopo, formato storia social:
/// emblema e nome del segno, la riga di sintesi (ancora del Generale), le quattro
/// schede in forma compatta con la loro forma a tema, numero fortunato e colore
/// del giorno, sigillo di Medora, watermark e deep link. Tutto deterministico.
class OroscopoShareCard extends StatelessWidget {
  const OroscopoShareCard({
    super.key,
    required this.sign,
    required this.cards,
    required this.palette,
    this.width = 360,
  });

  final Zodiac sign;
  final List<HoroscopeCard> cards;
  final MaestroPalette palette;
  final double width;

  @override
  Widget build(BuildContext context) {
    final fortuna =
        cards.firstWhere((c) => c.domain == HoroscopeDomain.fortuna);
    final synthesis = HoroscopeData.anchors[sign.id]![0][1];
    const still = AlwaysStoppedAnimation<double>(0.5);

    return Container(
      width: width,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest,
            Color.lerp(palette.deepest, palette.primary, 0.55)!,
            palette.deepest,
          ],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.8), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('OROSCOPO',
              textAlign: TextAlign.center,
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: palette.goldSoft, letterSpacing: 4.0)),
          const SizedBox(height: SpacingTokens.md),
          // Emblema e nome del segno.
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      palette.gold.withValues(alpha: 0.28),
                      Colors.transparent,
                    ]),
                  ),
                  child: ZodiacEmblem(
                      sign: sign, size: 78, art: ZodiacEmblemArt.emblem),
                ),
                Text(sign.italianName,
                    style: TypographyTokens.display(size: 26)
                        .copyWith(color: palette.goldSoft)),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Riga di sintesi in evidenza: l'ancora del Generale.
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              color: palette.primary.withValues(alpha: 0.4),
              border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
            ),
            child: Text(synthesis,
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 15).copyWith(
                    color: ColorTokens.textPrimary, height: 1.4)),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Le quattro schede in forma compatta, ognuna con la sua forma a tema.
          Row(children: [
            for (final c in cards.take(2))
              Expanded(
                  child: _CompactTile(card: c, palette: palette, pulse: still)),
          ]),
          const SizedBox(height: SpacingTokens.sm),
          Row(children: [
            for (final c in cards.skip(2))
              Expanded(
                  child: _CompactTile(card: c, palette: palette, pulse: still)),
          ]),
          const SizedBox(height: SpacingTokens.md),
          // Numero fortunato e colore del giorno.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _fortunaChip('Numero', '${fortuna.luckyNumber}', palette),
              const SizedBox(width: SpacingTokens.sm),
              _colorChip(fortuna.dayColor, palette),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          // Sigillo di Medora, watermark e deep link.
          const _MedoraSeal(),
          const SizedBox(height: 4),
          Text('ESOTERIC CIRCLE',
              textAlign: TextAlign.center,
              style: TypographyTokens.label(size: 10)
                  .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
          Text('esotericircle.com/oroscopo',
              textAlign: TextAlign.center,
              style: TypographyTokens.label(size: 8).copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.6)),
        ],
      ),
    );
  }

  Widget _fortunaChip(String label, String value, MaestroPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(),
              style: TypographyTokens.label(size: 8).copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          Text(value,
              style: TypographyTokens.display(size: 20)
                  .copyWith(color: palette.goldSoft)),
        ],
      ),
    );
  }

  Widget _colorChip(String? name, MaestroPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: oroscopoColor(name) ?? palette.goldSoft,
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
          ),
          const SizedBox(width: 6),
          Text(name ?? '',
              style: TypographyTokens.body(size: 13)
                  .copyWith(color: ColorTokens.textPrimary)),
        ],
      ),
    );
  }
}

class _CompactTile extends StatelessWidget {
  const _CompactTile(
      {required this.card, required this.palette, required this.pulse});

  final HoroscopeCard card;
  final MaestroPalette palette;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.sm, horizontal: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.surfaceElevated.withValues(alpha: 0.35),
        border: Border.all(color: palette.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          DomainVisual(
            domain: card.domain,
            value: card.indicator,
            palette: palette,
            pulse: pulse,
            size: 40,
            animateFill: false,
          ),
          const SizedBox(height: 4),
          Text(card.domain.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.label(size: 8).copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          Text(card.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.display(size: 12)
                  .copyWith(color: palette.goldSoft)),
        ],
      ),
    );
  }
}

/// Un piccolo sigillo di Medora disegnato a vettori: un medaglione dorato con la
/// stella, sempre disponibile, senza dipendere da un asset.
class _MedoraSeal extends StatelessWidget {
  const _MedoraSeal();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: CustomPaint(painter: _SealPainter()),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.46;
    const gold = Color(0xFFE9C46A);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.06
          ..color = gold);
    // Stella a otto punte.
    final star = Paint()..color = gold;
    for (var k = 0; k < 8; k++) {
      final a = k * math.pi / 4;
      final tip = c + Offset(math.cos(a), math.sin(a)) * r * 0.62;
      canvas.drawCircle(tip, size.shortestSide * 0.03, star);
    }
    canvas.drawCircle(c, size.shortestSide * 0.1, star);
  }

  @override
  bool shouldRepaint(_SealPainter old) => false;
}

/// Genera la card come immagine dal boundary e apre il foglio di condivisione.
/// Il PNG va in un file temporaneo del dispositivo, non su un server.
Future<bool> shareOroscopoCard({
  required GlobalKey boundaryKey,
  required String text,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/oroscopo_card.png');
  await file.writeAsBytes(png, flush: true);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: text),
  );
  return true;
}
