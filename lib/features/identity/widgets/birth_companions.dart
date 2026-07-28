import 'package:flutter/material.dart';

import '../../../core/angels/guardian_angels.dart';
import '../../../core/assets/family_image.dart';
import '../../../core/astro/birth_details.dart';
import '../../../core/astro/night_sky.dart';
import '../../../core/identity/birth_identity.dart';
import '../../../core/rituals/guide_animal_derivation.dart';
import '../../../design_system/components/depth_card.dart';
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
              Row(
                children: [
                  for (final a in triade.known) ...[
                    _Miniatura(
                      path: FamilyImage.thumb(AssetFamily.angeli, a.artStem),
                      ripiego: Icons.auto_awesome,
                      palette: palette,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                  ],
                  Expanded(
                    child: Text(
                      triade.known.map((a) => a.name).join(', '),
                      style: TypographyTokens.body(size: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
  });

  final String path;
  final IconData ripiego;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(ripiego, color: palette.goldSoft, size: 22),
        ),
      ),
    );
  }
}
