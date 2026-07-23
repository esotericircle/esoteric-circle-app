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
/// La statua del dominante resta protagonista, con la mini-ruota dietro. Attorno
/// racconta il responso vero: provenienza in alto, il nome con l'articolo, la
/// percentuale del dominante, il co-dominante, l'essenza dal corpus e una
/// classifica compatta dei primi tre col cerchio della miniatura. In fondo, oltre
/// alla firma, un invito a scoprire il proprio archetipo. Il testo e le
/// percentuali vengono tutti dallo stesso profilo mostrato nel responso, quindi
/// la card e' deterministica: stesso profilo, stessa immagine. Si cattura come
/// PNG da un `RepaintBoundary` e si apre col foglio di condivisione.
class ArchetypeShareCard extends StatelessWidget {
  const ArchetypeShareCard({super.key, required this.profilo});

  final ArchetypeProfile profilo;

  static const double larghezza = 400;
  static const double altezza = 760;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    final dom = profilo.dominante;
    final ritratto = ArchetypeCorpus.di(dom);
    final secondo = profilo.secondo;
    final primiTre = profilo.graduatoria.take(3).toList();
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
            // Provenienza in alto: da dove arriva l'immagine.
            Text('TEST ARCHETIPO',
                style: TypographyTokens.label(size: 12).copyWith(
                    color: palette.goldSoft, letterSpacing: 2.0)),
            const SizedBox(height: SpacingTokens.sm),
            // La statua protagonista, con la mini-ruota del profilo dietro.
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: ArchetypeWheel(
                      profilo: profilo,
                      palette: palette,
                      lato: 270,
                      etichette: false,
                    ),
                  ),
                  Image.asset(dom.artePiena,
                      height: 270,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.person_outline_rounded,
                          size: 170,
                          color: palette.goldSoft)),
                ],
              ),
            ),
            Text(dom.conArticolo.toUpperCase(),
                style: TypographyTokens.display(size: 26)
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: 2),
            // La percentuale del dominante e il co-dominante, quando c'e'.
            Text(
              secondo != null
                  ? '${profilo.percentualeDi(dom).round()}% · accanto ${secondo.conArticolo}'
                  : '${profilo.percentualeDi(dom).round()}%',
              style: TypographyTokens.label(size: 12).copyWith(
                  color: palette.textPrimary.withValues(alpha: 0.85),
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(ritratto.essenza,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.body(size: 14).copyWith(
                    color: palette.textPrimary, fontStyle: FontStyle.italic)),
            const SizedBox(height: SpacingTokens.md),
            // La classifica compatta dei primi tre: cerchio, nome, percentuale.
            for (final a in primiTre)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                child: _RigaTre(
                  archetipo: a,
                  percentuale: profilo.percentualeDi(a).round(),
                  dominante: a == dom,
                  palette: palette,
                ),
              ),
            const SizedBox(height: SpacingTokens.sm),
            Text('Esoteric Circle · Aura',
                style: TypographyTokens.label(size: 10).copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.0)),
            const SizedBox(height: 2),
            Text('Scopri il tuo archetipo su Esoteric Circle',
                style: TypographyTokens.label(size: 10).copyWith(
                    color: palette.textPrimary.withValues(alpha: 0.6),
                    letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

/// Una riga della classifica compatta sulla card: cerchio con la miniatura,
/// nome e percentuale. Il dominante e' acceso in oro.
class _RigaTre extends StatelessWidget {
  const _RigaTre({
    required this.archetipo,
    required this.percentuale,
    required this.dominante,
    required this.palette,
  });

  final Archetype archetipo;
  final int percentuale;
  final bool dominante;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: palette.surface.withValues(alpha: 0.6),
            border: Border.all(
              color: dominante
                  ? palette.goldSoft
                  : palette.gold.withValues(alpha: 0.3),
              width: dominante ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            archetipo.arteThumb,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.person_outline_rounded,
                size: 16, color: palette.goldSoft),
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(archetipo.nome,
              style: TypographyTokens.body(size: 14).copyWith(
                  color:
                      dominante ? palette.goldSoft : palette.textPrimary,
                  fontWeight:
                      dominante ? FontWeight.w700 : FontWeight.w400)),
        ),
        Text('$percentuale%',
            style: TypographyTokens.label(size: 12).copyWith(
                color: dominante
                    ? palette.goldSoft
                    : palette.textPrimary.withValues(alpha: 0.7),
                letterSpacing: 0.5)),
      ],
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
