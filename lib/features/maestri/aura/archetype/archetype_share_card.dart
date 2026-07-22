import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/archetypes/archetype.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/archetypes/archetype_corpus.dart';
import '../../../../core/archetypes/archetype_scoring.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'archetype_wheel.dart';

/// La card condivisibile del Test Archetipo, nella cornice verde e oro di Aura.
///
/// Statua del dominante, nome con l'articolo, essenza e una mini-ruota. Il testo
/// e' tutto dal corpus, quindi la card e' deterministica: stesso profilo, stessa
/// immagine. Si cattura come PNG da un `RepaintBoundary` e si apre col foglio di
/// condivisione, come le altre card del progetto.
class ArchetypeShareCard extends StatelessWidget {
  const ArchetypeShareCard({super.key, required this.profilo});

  final ArchetypeProfile profilo;

  static const double larghezza = 400;
  static const double altezza = 620;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    final dom = profilo.dominante;
    final ritratto = ArchetypeCorpus.di(dom);
    return Container(
      key: const Key('archetype_share_card'),
      width: larghezza,
      height: altezza,
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
          children: [
            Text('IL TUO ARCHETIPO',
                style: TypographyTokens.label(size: 12).copyWith(
                    color: palette.goldSoft, letterSpacing: 2.0)),
            const SizedBox(height: SpacingTokens.md),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: ArchetypeWheel(
                      profilo: profilo,
                      palette: palette,
                      lato: 300,
                      etichette: false,
                    ),
                  ),
                  Image.asset(dom.artePiena,
                      height: 300,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.person_outline_rounded,
                          size: 180,
                          color: palette.goldSoft)),
                ],
              ),
            ),
            Text(dom.conArticolo.toUpperCase(),
                style: TypographyTokens.display(size: 28)
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.xs),
            Text(ritratto.essenza,
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 15).copyWith(
                    color: palette.textPrimary, fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.md),
            Text('Esoteric Circle · Aura',
                style: TypographyTokens.label(size: 10).copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }
}

/// Genera la card come PNG dal boundary e apre il foglio di condivisione.
/// Il deep link porta all'arte del Test Archetipo nel dominio di Aura.
Future<bool> shareArchetypeCard({
  required GlobalKey boundaryKey,
  required Archetype dominante,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/archetipo_${dominante.name}.png');
  await file.writeAsBytes(png, flush: true);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'Il mio archetipo è ${dominante.conArticolo}. '
          'Scopri il tuo con Aura, su Esoteric Circle. '
          'https://esotericircle.app/aura/archetype_test',
    ),
  );
  return true;
}
