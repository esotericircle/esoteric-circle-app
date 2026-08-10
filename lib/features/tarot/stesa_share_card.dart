import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/tarot/tarot_reading.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../core/tarot/tarot_topic.dart';
import '../../design_system/components/brand_mark.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'tarot_card_art.dart';

/// La card verticale condivisibile della Stesa a Tre Carte, nel formato unico:
/// sfondo blu e oro di Medora, i tre arcani grandi con la loro posizione, la
/// sintesi, un estratto della lettura, il consiglio in evidenza, watermark e
/// deep link.
class StesaShareCard extends StatelessWidget {
  const StesaShareCard({
    super.key,
    required this.spread,
    required this.palette,
    this.topic = TarotTopic.predefinito,
    this.width = 380,
  });

  final TarotSpread spread;
  final MaestroPalette palette;

  /// L'argomento su cui la lettura e' stata direzionata.
  final TarotTopic topic;

  final double width;

  @override
  Widget build(BuildContext context) {
    final reading = TarotReading.of(spread, topic);
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(SpacingTokens.md,
          SpacingTokens.lg, SpacingTokens.md, SpacingTokens.lg),
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
          Text('STESA A TRE CARTE',
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 3.0)),
          const SizedBox(height: 2),
          // L'argomento su cui la lettura e' stata direzionata.
          Text(topic.label,
              key: const Key('share_topic'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 13).copyWith(
                  color: ColorTokens.textSecondary,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.md),
          // I tre arcani, ognuno con la sua posizione.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < spread.cards.length; i++) ...[
                Expanded(child: _CardTile(drawn: spread.cards[i], palette: palette)),
                if (i < spread.cards.length - 1) const SizedBox(width: 5),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // I nomi a tutta larghezza: nella colonna della carta il minimo
          // tipografico li spezzerebbe a meta' parola.
          for (final drawn in spread.cards)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 74,
                    child: Text(drawn.position.label.toUpperCase(),
                        style: TypographyTokens.etichetta().copyWith(
                            color: palette.goldSoft, letterSpacing: 0.8)),
                  ),
                  Expanded(
                    child: Text(drawn.displayName,
                        maxLines: 2,
                        style: TypographyTokens.display(size: 17).copyWith(
                            color: ColorTokens.textPrimary, height: 1.15)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: SpacingTokens.md),
          // La sintesi in evidenza.
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              color: palette.primary.withValues(alpha: 0.4),
              border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
            ),
            child: Text(reading.sintesi,
                textAlign: TextAlign.center,
                style: TypographyTokens.display(size: 17)
                    .copyWith(color: palette.goldSoft, height: 1.25)),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Un estratto della lettura: come le carte dialogano fra loro.
          Text(reading.dialogo.text,
              key: const Key('share_dialogo'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 13).copyWith(
                  color: ColorTokens.textPrimary, height: 1.4)),
          const SizedBox(height: SpacingTokens.sm),
          // La carta chiave, il cuore della stesa.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LA CARTA CHIAVE  ',
                  style: TypographyTokens.etichetta().copyWith(
                      color: ColorTokens.textSecondary, letterSpacing: 1.4)),
              Flexible(
                child: Text(reading.chiave.drawn.displayName,
                    key: const Key('share_chiave'),
                    style: TypographyTokens.display(size: 16)
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Il consiglio di Medora, quello che ci si porta a casa.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
            ),
            child: Text(reading.consiglio,
                key: const Key('share_consiglio'),
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 13).copyWith(
                    color: palette.goldSoft, height: 1.4)),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(TarotSpread.closing,
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 13).copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.35,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.md),
          const Center(child: BrandLogo(size: 40)),
          const SizedBox(height: 4),
          Text(BrandMark.wordmark,
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
          Text('esotericircle.com/tarocchi',
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.6)),
        ],
      ),
    );
  }
}

/// Un arcano nella card: l'arte, la posizione e il nome col verso.
class _CardTile extends StatelessWidget {
  const _CardTile({required this.drawn, required this.palette});

  final DrawnCard drawn;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: TarotFrame.aspect,
          // Stessa carta della schermata, coi cartigli riempiti a runtime.
          child: TarotCardArt(
            card: drawn.card,
            palette: palette,
            reversed: drawn.reversed,
            borderRadius: 5,
          ),
        ),
      ],
    );
  }
}

/// Genera la card come immagine dal boundary e apre il foglio di condivisione.
/// Il PNG va in un file temporaneo del dispositivo, non su un server.
Future<bool> shareStesaCard({
  required GlobalKey boundaryKey,
  required String text,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/stesa_tre_carte.png');
  await file.writeAsBytes(png, flush: true);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: text),
  );
  return true;
}
