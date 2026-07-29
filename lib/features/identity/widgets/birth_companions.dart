import 'package:flutter/material.dart';

import '../../../core/angels/guardian_angels.dart';
import '../../../core/assets/family_image.dart';
import '../../../core/astro/birth_details.dart';
import '../../../core/astro/night_sky.dart';
import '../../../core/identity/birth_identity.dart';
import '../../../core/rituals/guide_animal_derivation.dart';
import '../../../design_system/components/depth_card.dart';
import '../../angels/angelo_ingrandito.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../angels/angels_screen.dart';

/// Chi accompagna la persona dalla nascita: l'Animale Guida e i tre Angeli.
///
/// Vive dentro la carta natale accanto a Sole, Luna, Ascendente e Numero della
/// Vita, perche' l'identita' di nascita e' una cosa sola e non va spezzata fra
/// schermate diverse. L'Animale Guida resta anche nel Passport, dove gia' era.
class BirthCompanions extends StatelessWidget {
  const BirthCompanions({
    super.key,
    required this.details,
    this.identity,
  });

  final BirthDetails details;

  /// L'identita' completa, quando c'e': serve solo ad aprire la schermata dei
  /// tre Angeli. Senza, le tessere restano leggibili ma non aprono nulla.
  final BirthIdentity? identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final triade = GuardianAngels.forBirth(details);
    final segno = NightSky.sunSign(details.dateTime);
    final animale = GuideAnimalDerivation.forSign(segno);

    return Column(
      key: const Key('carta_compagni'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CHI TI ACCOMPAGNA',
            style: TypographyTokens.label(size: 13)
                .copyWith(color: palette.goldSoft, letterSpacing: 3)),
        const SizedBox(height: SpacingTokens.sm),
        DepthCard(
          key: const Key('carta_animale_guida'),
          raised: true,
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Row(
            children: [
              _Miniatura(
                path: animale.thumbPath,
                ripiego: Icons.pets,
                palette: palette,
                // Piu' grande di prima: contenuto invece che ritagliato, in 44
                // px il totem diventava un francobollo illeggibile.
                larghezza: 64,
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Animale guida',
                        style: TypographyTokens.label(size: 11).copyWith(
                            color: palette.goldSoft, letterSpacing: 2)),
                    Text(animale.name,
                        style: TypographyTokens.display(size: 18)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        DepthCard(
          key: const Key('carta_angeli'),
          raised: true,
          padding: const EdgeInsets.all(SpacingTokens.md),
          onTap: identity == null
              ? null
              : () => Navigator.of(context)
                  .push(AngelsScreen.route(identity: identity!)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('I tuoi Angeli',
                      style: TypographyTokens.label(size: 11).copyWith(
                          color: palette.goldSoft, letterSpacing: 2)),
                  const Spacer(),
                  if (identity != null)
                    Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              // Una riga di volti, uno per angelo, col nome sotto il proprio.
              // Prima i tre stavano su una riga sola con i nomi accanto, e in
              // colonna stretta restava spazio per una miniatura soltanto:
              // il conto tornava nel codice, non sullo schermo.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final a in triade.known)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: SpacingTokens.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ogni carta apre l'ingrandimento, LO STESSO che
                            // si apre dal trionfo: un secondo componente
                            // sarebbe due verita' che col tempo divergono.
                            Center(
                              child: GestureDetector(
                                key: Key('carta_angelo_${a.number}'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () => AngeloIngrandito.apri(
                                  context,
                                  angelo: a,
                                  ruolo: RuoloAngelo.perIndice(
                                      triade.known.indexOf(a)),
                                ),
                                child: _Miniatura(
                                  path: FamilyImage.thumb(
                                      AssetFamily.angeli, a.artStem),
                                  ripiego: Icons.auto_awesome,
                                  palette: palette,
                                  larghezza: 62,
                                  // Due terzi: la proporzione di una carta.
                                  proporzione: 2 / 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.xxs),
                            Text(
                              a.name,
                              style: TypographyTokens.body(size: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (!triade.hasIntellect) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  'Il terzo Angelo arriva con l\'ora di nascita.',
                  style: TypographyTokens.body(size: 13)
                      .copyWith(color: ColorTokens.textMuted),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({
    required this.path,
    required this.ripiego,
    required this.palette,
    this.larghezza = 44,
    this.proporzione = 1,
  });

  final String path;
  final IconData ripiego;
  final MaestroPalette palette;

  /// La larghezza del riquadro.
  final double larghezza;

  /// Larghezza diviso altezza. Uno per il quadrato dell'animale, due terzi
  /// per la carta verticale degli Angeli, che e' la proporzione della loro
  /// arte: in un quadrato quell'arte perde per forza qualcosa.
  final double proporzione;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: larghezza,
      height: larghezza / proporzione,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        child: Image.asset(
          path,
          // CONTAIN e non cover: cover riempie il riquadro ritagliando cio'
          // che avanza, e in un quadrato da 44 un totem verticale perdeva la
          // testa. Un animale guida decapitato non e' un animale guida, e una
          // carta d'angelo senza cornice non e' una carta.
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Icon(ripiego, color: palette.goldSoft, size: 22),
        ),
      ),
    );
  }
}
