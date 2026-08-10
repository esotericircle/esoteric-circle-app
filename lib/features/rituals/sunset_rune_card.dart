import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/rituals/sunset_rune.dart';
import '../../core/rituals/sunset_rune_corpus.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/caligo/rune/bindrune.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'rune_strokes.dart';

/// La carta condivisibile della Runa del Tramonto: la pietra incisa, il nome, il
/// verso e la data. Senza indirizzo web inventato.
class SunsetRuneCard extends StatelessWidget {
  const SunsetRuneCard({
    super.key,
    required this.estrazione,
    required this.palette,
    this.runeSettimana,
  });

  final EstrazioneTramonto estrazione;
  final MaestroPalette palette;

  /// Se presente, la carta e' quella del sigillo della settimana: mostra la
  /// bindrune invece della singola pietra.
  final List<String>? runeSettimana;

  static const double larghezza = 400;

  @override
  Widget build(BuildContext context) {
    final sigillo = runeSettimana != null;
    return Container(
      key: const Key('sunset_rune_card'),
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
            Text(sigillo ? 'SIGILLO DELLA SETTIMANA' : 'RUNA DEL TRAMONTO',
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.0)),
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              width: 210,
              height: 230,
              child: sigillo
                  ? BindruneSigillo(
                      runeNames: runeSettimana!,
                      oro: palette.gold,
                      alone: palette.goldSoft,
                      lato: 210,
                      deduplica: true,
                    )
                  : _Pietra(estrazione: estrazione, palette: palette),
            ),
            const SizedBox(height: SpacingTokens.sm),
            if (!sigillo)
              Text(estrazione.rune.name.toUpperCase(),
                  style: TypographyTokens.display(size: 28)
                      .copyWith(color: palette.goldSoft)),
            const SizedBox(height: 2),
            Text(
                sigillo
                    ? 'Sette sere, un segno solo'
                    : (estrazione.simmetrica
                        ? SunsetRuneCorpus.noteSimmetrica
                        : (estrazione.inOmbra
                            ? 'verso d\'ombra'
                            : 'verso dritto')),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo().copyWith(
                    color: palette.textPrimary, fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.md),
            Text(SunsetRuneCorpus.trasparenza(estrazione),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.85),
                    letterSpacing: 0.4)),
            const SizedBox(height: SpacingTokens.md),
            Text('Esoteric Circle · Caligo',
                style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text('La runa che scende con la sera, su Esoteric Circle',
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

/// La pietra incisa: l'arte reale della famiglia rune_bone, col ripiego al glifo
/// disegnato a tratti se l'asset non c'e'.
class _Pietra extends StatelessWidget {
  const _Pietra({required this.estrazione, required this.palette});

  final EstrazioneTramonto estrazione;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final r = estrazione.rune;
    final glifo = r.hasImage
        ? Image.asset(r.fullPath!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => CustomPaint(
                  painter: RunePainter(
                      runeName: r.name,
                      color: Colors.white,
                      glow: palette.goldSoft,
                      intensity: 1.0),
                ))
        : CustomPaint(
            painter: RunePainter(
                runeName: r.name,
                color: Colors.white,
                glow: palette.goldSoft,
                intensity: 1.0),
          );
    // In merkstave la pietra si mostra capovolta, il verso d'ombra.
    return estrazione.inOmbra
        ? Transform.rotate(angle: 3.14159, child: glifo)
        : glifo;
  }
}

/// Genera la carta come PNG dal boundary e apre il foglio di condivisione.
Future<bool> shareSunsetRuneCard({
  required GlobalKey boundaryKey,
  required EstrazioneTramonto estrazione,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/runa_tramonto_${estrazione.giornoIso}.png');
  await file.writeAsBytes(png, flush: true);
  final verso = estrazione.simmetrica
      ? 'simmetrica'
      : (estrazione.inOmbra ? 'in merkstave' : 'dritta');
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'La mia runa del tramonto: ${estrazione.rune.name} $verso. '
          'Scopri la tua con Caligo, su Esoteric Circle.',
    ),
  );
  return true;
}
