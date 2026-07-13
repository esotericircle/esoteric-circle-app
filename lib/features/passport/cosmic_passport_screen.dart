import 'package:flutter/material.dart';

import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../santuario/sky_overview_screen.dart';
import '../settings/settings_screen.dart';

/// Schermata segnaposto del Cosmic Passport.
///
/// In attesa dei dati identitari reali (BirthIdentity, calcolati sulle
/// effemeridi svizzere via FreeAstroAPI) e dei relativi asset, questa
/// schermata mostra soltanto la struttura cerimoniale e le voci "in arrivo".
/// Nessun dato reale, nessuna rete, nessun asset esterno.
///
/// Non ha un proprio Scaffold, AppBar o sfondo cosmico: e' solo contenuto,
/// destinato a essere inserito in un contenitore che fornisce navigazione e
/// sfondo.
class CosmicPassport extends StatelessWidget {
  const CosmicPassport({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Margine in alto: il titolo non deve mai finire sotto un
                  // eventuale pulsante nell'angolo in alto a sinistra.
                  const SizedBox(height: SpacingTokens.xl),
                  // Header cerimoniale: titolo e ingresso pulito alle
                  // Impostazioni, nell'angolo del documento.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Cosmic Passport',
                          style: TypographyTokens.display(size: 30),
                        ),
                      ),
                      IconButton(
                        key: const Key('passport_settings'),
                        icon: const Icon(Icons.settings_outlined),
                        color: palette.goldSoft,
                        tooltip: 'Impostazioni',
                        onPressed: () =>
                            Navigator.of(context).push(SettingsScreen.route()),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'La tua identità cosmica, che si compone nel tempo.',
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: palette.goldSoft),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Testo introduttivo: spiega la natura fissa del documento.
                  Text(
                    'Qui vivono i fatti identitari fissi del tuo cammino: la '
                    'carta natale non cambia mai.',
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                ],
              ),
            ),
          ),
          // Il portale gia' vivo: il cielo di nascita, immersivo ed esplorabile
          // con lo stesso motore del cielo di adesso, ma fisso sulla notte di
          // nascita. Le altre voci restano dietro il velo.
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(SpacingTokens.lg, 0, SpacingTokens.lg,
                SpacingTokens.sm),
            sliver: SliverToBoxAdapter(child: _BirthSkyPortalCard()),
          ),
          // Colonna di tessere "in arrivo", una per ogni fatto identitario.
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  for (final entry in _passportEntries) ...[
                    _PassportEntryCard(entry: entry),
                    const SizedBox(height: SpacingTokens.sm),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: SpacingTokens.xxxl),
          ),
        ],
      ),
    );
  }
}

/// Il portale gia' attivo del passaporto: apre "Il tuo cielo di nascita", la
/// volta immersiva ancorata alla notte di nascita. Finche' non ci sono nascita
/// e luogo reali (BirthIdentity dalle effemeridi), usa un momento d'esempio,
/// dichiarato in-world nella schermata stessa.
class _BirthSkyPortalCard extends StatelessWidget {
  const _BirthSkyPortalCard();

  // Momento di nascita d'esempio, finche' l'onboarding non raccoglie il dato
  // reale. La schermata lo dichiara come veduta d'esempio.
  static final DateTime _placeholderBirth = DateTime(1990, 6, 15, 2, 30);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      key: const Key('passport_birth_sky'),
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        SkyOverviewScreen.birthRoute(birthMoment: _placeholderBirth),
      ),
      child: DepthCard(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.nights_stay, color: palette.goldSoft, size: 28),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Il tuo cielo di nascita',
                    style: TypographyTokens.display(size: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'La volta della tua prima notte, da esplorare con Medora.',
                    style: TypographyTokens.body(size: 14)
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
          ],
        ),
      ),
    );
  }
}

/// Descrizione statica di una voce segnaposto del passaporto.
class _PassportEntry {
  const _PassportEntry({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Voci segnaposto dei fatti identitari fissi.
const List<_PassportEntry> _passportEntries = [
  _PassportEntry(
    icon: Icons.auto_awesome,
    title: 'Carta natale',
    description: 'La tua mappa celeste, calcolata sulle effemeridi.',
  ),
  _PassportEntry(
    icon: Icons.nightlight_round,
    title: 'Fase lunare di nascita',
    description: 'La Luna sotto cui sei venuto al mondo.',
  ),
  _PassportEntry(
    icon: Icons.tag,
    title: 'Numero della vita',
    description: 'La cifra che riduce il tuo giorno di nascita.',
  ),
  _PassportEntry(
    icon: Icons.brightness_7,
    title: 'Angelo custode',
    description: 'Il tuo Angelo nella tradizione dei settantadue nomi.',
  ),
  _PassportEntry(
    icon: Icons.psychology_alt,
    title: 'Archetipo',
    description: 'La figura profonda che ti accompagna.',
  ),
  _PassportEntry(
    icon: Icons.pets,
    title: 'Animale guida',
    description: 'Il tuo alleato fra i dodici archetipi.',
  ),
];

/// Tessera "in arrivo" di un singolo fatto identitario del passaporto.
class _PassportEntryCard extends StatelessWidget {
  const _PassportEntryCard({required this.entry});

  final _PassportEntry entry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DepthCard(
      opacity: 0.6,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(entry.icon, color: palette.goldSoft, size: 28),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TypographyTokens.display(size: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.description,
                  style: TypographyTokens.body(size: 14)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          _VeilBadge(palette: palette),
        ],
      ),
    );
  }
}

/// Piccolo badge testuale con l'etichetta in-world unica, "Dietro il velo",
/// per le voci non ancora pronte. Stessa etichetta del dominio.
class _VeilBadge extends StatelessWidget {
  const _VeilBadge({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Dietro il velo',
        style: TypographyTokens.label(size: 10).copyWith(color: palette.gold),
      ),
    );
  }
}
