import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/astro/zodiac.dart';
import '../../core/horoscope/horoscope.dart';
import '../../design_system/components/brand_mark.dart';
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
/// schede in forma compatta con la loro forma a tema e il livello col numero,
/// numero fortunato e colore del giorno, marchio e deep link. Tutto
/// deterministico.
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
    // La sintesi arriva dalla scheda che questa card ha gia' in mano, non dal
    // corpus riletto per conto proprio: era l'unica porta dell'Oroscopo che
    // scavalcava `Horoscope`, e sostituire la composizione avrebbe lasciato
    // indietro proprio l'immagine che la gente condivide.
    final synthesis = cards
        .firstWhere((c) => c.domain == HoroscopeDomain.generale)
        .synthesis;
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
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 4.0)),
          const SizedBox(height: SpacingTokens.sm),
          Center(
            child: Column(
              children: [
                Container(
                  width: 104,
                  height: 104,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      palette.gold.withValues(alpha: 0.26),
                      Colors.transparent,
                    ]),
                  ),
                  child: ZodiacEmblem(
                      sign: sign, size: 92, art: ZodiacEmblemArt.emblem),
                ),
                Text(sign.italianName,
                    style: TypographyTokens.display(size: 26)
                        .copyWith(color: palette.goldSoft)),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
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
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Le quattro bolle, ognuna con la sua forma a tema e il livello.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in cards.take(2))
                  Expanded(
                      child:
                          _LevelTile(card: c, palette: palette, pulse: still)),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in cards.skip(2))
                  Expanded(
                      child:
                          _LevelTile(card: c, palette: palette, pulse: still)),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Numero e Colore: due bolle della stessa misura, col titolo sopra.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _InfoBubble(
                    label: 'Numero',
                    palette: palette,
                    child: Text('${fortuna.luckyNumber}',
                        textAlign: TextAlign.center,
                        style: TypographyTokens.titoloSezione()
                            .copyWith(color: palette.goldSoft)),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: _InfoBubble(
                    label: 'Colore',
                    palette: palette,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: oroscopoColor(fortuna.dayColor) ??
                                palette.goldSoft,
                            border: Border.all(
                                color: palette.gold.withValues(alpha: 0.6)),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(fortuna.dayColor ?? '',
                              maxLines: 1,
                              style: TypographyTokens.didascalia()
                                  .copyWith(color: ColorTokens.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Marchio: il logo vero se c'e', altrimenti il sigillo provvisorio.
          const Center(child: BrandLogo(size: 42)),
          const SizedBox(height: 4),
          Text(BrandMark.wordmark,
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
          Text('esotericircle.com/oroscopo',
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.6)),
        ],
      ),
    );
  }
}

/// Una bolla di scheda: la forma a tema col livello e il titolo per intero, mai
/// troncato coi puntini.
class _LevelTile extends StatelessWidget {
  const _LevelTile(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stesso linguaggio della schermata: cinque icone col numero.
          DomainLevel(
            domain: card.domain,
            value: card.indicator,
            palette: palette,
            pulse: pulse,
            iconSize: 13,
            gap: 2,
            animateFill: false,
          ),
          const SizedBox(height: 4),
          Text(card.domain.label.toUpperCase(),
              maxLines: 1,
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          // Titolo intero: va a capo e si rimpicciolisce, nessuna ellissi.
          Text(card.title,
              textAlign: TextAlign.center,
              maxLines: 3,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: TypographyTokens.display(size: 16)
                  .copyWith(color: palette.goldSoft, height: 1.15)),
        ],
      ),
    );
  }
}

/// Una bolla informativa col titolo sopra e il contenuto sotto, di misura
/// uguale alle sue sorelle.
class _InfoBubble extends StatelessWidget {
  const _InfoBubble(
      {required this.label, required this.child, required this.palette});

  final String label;
  final Widget child;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Center(child: child),
        ],
      ),
    );
  }
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
