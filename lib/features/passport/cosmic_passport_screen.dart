import 'package:flutter/material.dart';

import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

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
                  // Header cerimoniale: titolo e sottotitolo del documento.
                  Text(
                    'Cosmic Passport',
                    style: TypographyTokens.display(size: 30),
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
