import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/brand/brand.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/synastry_approfondita/la_lettura_approfondita.dart';
import '../../core/synastry_approfondita/legame_e_eta.dart';
import '../../design_system/components/brand_mark.dart';
import '../../design_system/components/card_a_misura_fissa.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'sinastria_share_card.dart' show captureBoundaryPng;

/// Il percorso di un'immagine della Sinastria approfondita.
String immagineDellaSinastria(String nome) => 'assets/img/sinastria/$nome.webp';

/// La cornice comune delle due card: il formato unico (Linee Guida V13
/// sezione 3), fondo blu e oro di Medora, il visivo, la sintesi, il logo e il
/// dominio. **Nessun dato di nascita stampato** (FT.11): ne' date ne' ore ne'
/// luoghi, solo il nome che la persona ha dato all'altra.
class _CorniceDellaCard extends StatelessWidget {
  const _CorniceDellaCard(
      {required this.palette, required this.width, required this.figli});

  final MaestroPalette palette;
  final double width;
  final List<Widget> figli;

  @override
  Widget build(BuildContext context) {
    return CardAMisuraFissa(
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(SpacingTokens.md, SpacingTokens.lg,
            SpacingTokens.md, SpacingTokens.lg),
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
          border:
              Border.all(color: palette.gold.withValues(alpha: 0.8), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...figli,
            const SizedBox(height: SpacingTokens.md),
            const Center(child: BrandLogo(size: 40)),
            const SizedBox(height: SpacingTokens.xxs),
            Text(BrandMark.wordmark,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
            Text(Brand.domain,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// **IL RITRATTO DELLA COPPIA.** Ordine FT voce FT.11, esclusiva del piano
/// Adepto. Che cosa porta e la sua forma le decide Code (sezione 58.4): la
/// coppia del segno della relazione (il Sole composito) come visivo, il
/// titolo del Composito come sintesi, i cinque titoli dei capitoli coi loro
/// medaglioni, il legame.
class RitrattoDellaCoppia extends StatelessWidget {
  const RitrattoDellaCoppia({
    super.key,
    required this.palette,
    required this.nomeSuo,
    required this.legame,
    required this.coppia,
    required this.sintesi,
    required this.capitoli,
    this.width = 380,
  });

  final MaestroPalette palette;
  final String nomeSuo;
  final Legame legame;

  /// Il percorso della coppia del segno della relazione.
  final String coppia;
  final String sintesi;
  final List<CapitoloLetto> capitoli;
  final double width;

  @override
  Widget build(BuildContext context) {
    return _CorniceDellaCard(
      palette: palette,
      width: width,
      figli: [
        Text('SINASTRIA APPROFONDITA',
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 3.0)),
        const SizedBox(height: SpacingTokens.xxs),
        Text('Con $nomeSuo · ${legame.nome}',
            key: const Key('ritratto_con_chi'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo().copyWith(
                color: ColorTokens.textSecondary, fontStyle: FontStyle.italic)),
        const SizedBox(height: SpacingTokens.sm),
        AspectRatio(
          aspectRatio: 896 / 1200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            child: Image.asset(coppia, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Container(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            color: palette.primary.withValues(alpha: 0.4),
            border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
          ),
          child: Text(sintesi,
              key: const Key('ritratto_sintesi'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft, height: 1.25)),
        ),
        const SizedBox(height: SpacingTokens.sm),
        for (final c in capitoli)
          Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.xxs),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                      immagineDellaSinastria(c.capitolo.medaglione),
                      width: 32,
                      height: 32),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(c.titolo,
                      maxLines: 2,
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textPrimary, height: 1.2)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// **LA CARD DEL CAPITOLO**, per chi non e' nel piano Adepto (FT.14): un
/// capitolo solo, col suo medaglione, il titolo e il primo paragrafo.
class CardDelCapitolo extends StatelessWidget {
  const CardDelCapitolo({
    super.key,
    required this.palette,
    required this.nomeSuo,
    required this.legame,
    required this.capitolo,
    this.width = 380,
  });

  final MaestroPalette palette;
  final String nomeSuo;
  final Legame legame;
  final CapitoloLetto capitolo;
  final double width;

  @override
  Widget build(BuildContext context) {
    return _CorniceDellaCard(
      palette: palette,
      width: width,
      figli: [
        Text(capitolo.capitolo.nome.toUpperCase(),
            textAlign: TextAlign.center,
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 3.0)),
        const SizedBox(height: SpacingTokens.xxs),
        Text('Con $nomeSuo · ${legame.nome}',
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo().copyWith(
                color: ColorTokens.textSecondary, fontStyle: FontStyle.italic)),
        const SizedBox(height: SpacingTokens.sm),
        Center(
          child: ClipOval(
            child: Image.asset(
                immagineDellaSinastria(capitolo.capitolo.medaglione),
                width: 160,
                height: 160),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(capitolo.titolo,
            key: const Key('card_capitolo_titolo'),
            textAlign: TextAlign.center,
            style: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft, height: 1.25)),
        const SizedBox(height: SpacingTokens.sm),
        Text(capitolo.paragrafi.first,
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
      ],
    );
  }
}

/// Fotografa la card e la manda con la porta comune della condivisione.
/// Torna vero quando la condivisione e' avvenuta davvero.
Future<bool> shareSinastriaApprofonditaCard({
  required GlobalKey boundaryKey,
  required String testo,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/sinastria_approfondita.png');
  await file.writeAsBytes(png, flush: true);
  return PortaDellaCondivisione.daFile(file.path, testo: testo);
}
