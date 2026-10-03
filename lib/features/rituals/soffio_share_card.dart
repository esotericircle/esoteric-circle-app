import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/brand/brand.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../design_system/components/brand_mark.dart';
import '../../design_system/components/card_a_misura_fissa.dart';
import '../../design_system/components/loto_dorato.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;

/// **LA CARD DEL SOFFIO DEL DESTINO, da mandare.** Ordine DW voce 03, 18
/// settembre 2026.
///
/// Il Soffio condivideva un testo solo: chi lo riceveva leggeva una frase
/// senza sapere da dove venisse. Adesso parte un'immagine, come per gli altri
/// doni: il soffione del rito, l'orientamento del giorno, il loto di Aura e
/// il marchio.
class SoffioShareCard extends StatelessWidget {
  const SoffioShareCard({
    super.key,
    required this.orientamento,
    required this.palette,
    this.width = 380,
  });

  final String orientamento;
  final MaestroPalette palette;
  final double width;

  /// Il soffione del rito, lo stesso della schermata.
  static const String immagine =
      'assets/ritual_backgrounds/breath_dandelion.png';

  @override
  Widget build(BuildContext context) {
    return CardAMisuraFissa(
      child: Container(
        key: const Key('soffio_card_da_condividere'),
        width: width,
        padding: const EdgeInsets.all(SpacingTokens.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.deepest,
              Color.lerp(palette.deepest, palette.primary, 0.5)!,
              palette.deepest,
            ],
          ),
          border:
              Border.all(color: palette.gold.withValues(alpha: 0.8), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('SOFFIO DEL DESTINO',
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 3.0)),
            const SizedBox(height: SpacingTokens.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              child: SizedBox(
                height: 200,
                child: Image.asset(immagine,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text('IL MIO SOFFIO DI OGGI',
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 1.6)),
            const SizedBox(height: SpacingTokens.xs),
            Text(orientamento,
                key: const Key('soffio_card_orientamento'),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.45)),
            const SizedBox(height: SpacingTokens.md),
            Center(child: LotoDorato(lato: 34, colore: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.sm),
            const Center(child: BrandLogo(size: 36)),
            const SizedBox(height: 4),
            Text(BrandMark.wordmark,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
            Text(Brand.domain,
                key: const Key('soffio_card_dominio'),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// Il testo che accompagna la card: chi la riceve sa che cosa guarda e dove
/// trovare il suo.
String testoDelSoffioCondiviso(String orientamento) =>
    'Il mio Soffio del Destino di oggi, con Aura: $orientamento '
    'Scopri il tuo su ${Brand.url}';

/// Genera la card come immagine dal boundary e apre il foglio di condivisione.
Future<bool> shareSoffioCard({
  required GlobalKey boundaryKey,
  required String text,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/soffio_del_destino.png');
  await file.writeAsBytes(png, flush: true);
  return PortaDellaCondivisione.daFile(file.path, testo: text);
}
