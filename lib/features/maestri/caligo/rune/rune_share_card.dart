import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../core/rituals/rune_cast.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'bindrune.dart';

/// La card condivisibile dell'Estrazione Rune, cornice oro e rossa di Caligo:
/// la gettata, le rune nelle loro posizioni col verso, e il presagio in sintesi.
class RuneShareCard extends StatelessWidget {
  const RuneShareCard({
    super.key,
    required this.esito,
    required this.presagio,
  });

  final EsitoGettata esito;

  /// Il presagio in sintesi, mostrato in coda alla card.
  final String presagio;

  static const double larghezza = 400;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    return Container(
      key: const Key('rune_share_card'),
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
            Text('ESTRAZIONE RUNE',
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
            const SizedBox(height: 2),
            Text(esito.gettata.nome.toUpperCase(),
                style: TypographyTokens.display(size: 22)
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.sm),
            // IL SIGILLO, l'elemento grafico forte per la condivisione.
            BindruneSigillo(
              runeNames: [for (final r in esito.rune) r.rune.name],
              oro: palette.gold,
              alone: palette.goldSoft,
              lato: 190,
            ),
            Text('Il sigillo del giorno, una bindrune',
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.85),
                    letterSpacing: 0.8)),
            Text('glifi intrecciati autentici della tradizione runica',
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.6),
                    letterSpacing: 0.3)),
            const SizedBox(height: SpacingTokens.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: SpacingTokens.md,
              runSpacing: SpacingTokens.md,
              children: [
                for (final r in esito.rune)
                  _RunaTile(
                      runa: r,
                      palette: palette,
                      libera: esito.gettata.libera),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            Container(height: 1, color: palette.gold.withValues(alpha: 0.3)),
            const SizedBox(height: SpacingTokens.sm),
            Text(presagio,
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 13).copyWith(
                    color: palette.textPrimary, height: 1.45)),
            const SizedBox(height: SpacingTokens.md),
            Text('Esoteric Circle · Caligo',
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text('Getta le rune su Esoteric Circle',
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.6),
                    letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

/// Una runa nella card: la pietra incisa, dritta o capovolta in merkstave, col
/// nome, il verso e la posizione.
class _RunaTile extends StatelessWidget {
  const _RunaTile(
      {required this.runa, required this.palette, this.libera = false});

  final RunaGettata runa;
  final MaestroPalette palette;
  final bool libera;

  @override
  Widget build(BuildContext context) {
    final img = SizedBox(
      width: 64,
      height: 78,
      child: runa.rune.hasImage
          ? Image.asset(runa.rune.thumbPath!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.diamond_outlined, color: palette.goldSoft))
          : Icon(Icons.diamond_outlined, color: palette.goldSoft),
    );
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          // In merkstave la pietra si mostra capovolta, il verso d'ombra.
          runa.inOmbra
              ? Transform.rotate(angle: math.pi, child: img)
              : img,
          const SizedBox(height: 4),
          Text(runa.rune.name,
              textAlign: TextAlign.center,
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: palette.goldSoft)),
          Text(
              libera ? 'in luce' : (runa.inOmbra ? 'in merkstave' : 'diritta'),
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta().copyWith(
                  color: palette.textPrimary.withValues(alpha: 0.7),
                  letterSpacing: 0.4)),
          Text(runa.posizione.titolo,
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta().copyWith(
                  color: palette.textPrimary.withValues(alpha: 0.5),
                  letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

/// Genera la card come PNG dal boundary e apre il foglio di condivisione.
Future<bool> shareRuneCard({
  required GlobalKey boundaryKey,
  required EsitoGettata esito,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/estrazione_rune_${esito.gettata.id}.png');
  await file.writeAsBytes(png, flush: true);
  final nomi = esito.rune.map((r) => r.rune.name).join(', ');
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'Ho gettato le rune con ${esito.gettata.nome}: $nomi. '
          'Scopri il tuo presagio con Caligo, su Esoteric Circle.',
    ),
  );
  return true;
}
