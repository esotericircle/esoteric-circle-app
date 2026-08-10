
import 'package:flutter/material.dart';

import '../../../core/astro/birth_details.dart';
import '../../../core/astro/celestial.dart';
import '../../../core/identity/natal_identity.dart';
import '../../../design_system/components/cosmos_background.dart';
import '../../../design_system/components/depth_card.dart';
import '../../../design_system/components/life_number_emblem.dart';
import '../../../design_system/components/moon_phase_emblem.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../santuario/sky_overview_screen.dart';

/// I fatti identitari fissi (fase lunare di nascita e numero della vita), come
/// coppia di carte. Riusati dalla carta natale e dal profilo, pronti per il
/// Cosmic Passport.
class IdentityFactsSection extends StatelessWidget {
  const IdentityFactsSection({super.key, required this.facts});
  final NatalFacts facts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MoonPhaseFactCard(facts: facts),
        const SizedBox(height: SpacingTokens.sm),
        LifeNumberFactCard(facts: facts),
      ],
    );
  }
}

/// La fase della Luna del giorno di nascita, col segno lunare.
class MoonPhaseFactCard extends StatelessWidget {
  const MoonPhaseFactCard({super.key, required this.facts});
  final NatalFacts facts;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final sign = facts.moonSign;
    return DepthCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoonPhaseEmblem(phase: facts.moonPhase, size: 58),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LA TUA LUNA DI NASCITA',
                    style: TypographyTokens.label(size: 12.5)
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(
                  sign != null
                      ? '${facts.moonPhaseName} in ${sign.italianName}'
                      : facts.moonPhaseName,
                  style: TypographyTokens.display(size: 19),
                ),
                const SizedBox(height: 4),
                Text(facts.moonMeaning,
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Il numero della vita col suo emblema a sigillo.
class LifeNumberFactCard extends StatelessWidget {
  const LifeNumberFactCard({super.key, required this.facts});
  final NatalFacts facts;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LifeNumberEmblem(number: facts.lifeNumber, palette: palette, size: 60),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IL TUO NUMERO DELLA VITA',
                    style: TypographyTokens.label(size: 12.5)
                        .copyWith(color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text('${facts.lifeNumber}, ${facts.lifeTitle}',
                    style: TypographyTokens.display(size: 19)),
                const SizedBox(height: 4),
                Text(facts.lifeMeaning,
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Il portale al cielo reale della nascita: un piccolo cielo vivo che al tocco
/// riapre il momento a tutto schermo. Sostituisce il vecchio bagliore in cima
/// alla carta e tiene quel cielo raggiungibile (domani anche dal Cosmic
/// Passport).
class BirthSkyPortal extends StatefulWidget {
  const BirthSkyPortal({
    super.key,
    required this.details,
    this.moonPhase,
  });

  final BirthDetails details;
  final MoonIllumination? moonPhase;

  @override
  State<BirthSkyPortal> createState() => _BirthSkyPortalState();
}

class _BirthSkyPortalState extends State<BirthSkyPortal> {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: const Key('portale_cielo_nascita'),
      onTap: () => openBirthSky(context, widget.details),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          // L'occhio del portale e' il motore unico del cielo, in miniatura:
          // stesso cosmo delle schermate piene, seme suo, e reagisce al
          // sensore come tutto il resto. Prima qui viveva un painter privato
          // con un timer di otto secondi, il settimo modo di disegnare un
          // cielo, ed era quello che rendeva statica la carta natale.
          SizedBox(
            width: 62,
            height: 62,
            child: ClipOval(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: palette.goldSoft.withValues(alpha: 0.5),
                      width: 1.2),
                ),
                position: DecorationPosition.foreground,
                child: const CosmosBackground(
                  seed: 4,
                  showZodiac: false,
                  showPlanets: false,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Il tuo cielo di nascita',
                    style: TypographyTokens.display(size: 19)),
                const SizedBox(height: 4),
                Text('Tocca per rivedere il cielo autentico della tua notte.',
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textSecondary, height: 1.35)),
              ],
            ),
          ),
          Icon(Icons.north_east_rounded, color: palette.goldSoft, size: 22),
        ],
      ),
    );
  }
}


/// Apre il cielo reale della nascita a tutto schermo, con il ritorno alla carta.
void openBirthSky(BuildContext context, BirthDetails details) {
  // La stessa schermata del cielo in tempo reale, ancorata alla nascita:
  // corpi toccabili, scheda che racconta, parallasse dal motore unico.
  Navigator.of(context)
      .push(SkyOverviewScreen.birthRoute(birthMoment: details.dateTime));
}

