import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../widgets/maestro_presence.dart';

/// Apertura della chat prima del primo messaggio.
///
/// Immersione a riposo: il Maestro col mezzo busto piu' grande in alto, con la
/// sola animazione idle di respiro (segnaposto), un invito caldo e alcuni chip
/// di avvio al centro. Al primo messaggio tutto questo sparisce e il busto si
/// rimpicciolisce nell'avatar dell'header. Il livello visivo arriva prima del
/// testo, come vuole la legge del visivo.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.maestro,
    required this.greeting,
    required this.starters,
    required this.onStarter,
    this.personali = const [],
    this.enabled = true,
    this.spazioInFondo = 0,
  });

  final Maestro maestro;
  final String greeting;

  /// LE DUE FAMIGLIE TORNANO A VIDEO, ordine 2161 voce 3. Il 12 luglio 2026,
  /// commit 93e1481, il pannello coi due segmenti fu sostituito da tre chip
  /// con le famiglie dietro un bottone: Mauro le rivuole divise e visibili
  /// sulla prima schermata. [starters] sono le frequenti, [personali] le
  /// personali GIA' filtrate sul dato vero della persona: se una famiglia
  /// arriva vuota, la sua etichetta non compare, per la regola del vero.
  final List<String> starters;
  final List<String> personali;
  final ValueChanged<String> onStarter;
  final bool enabled;

  /// IL FONDO PORTA IL COMPOSITORE E LA BARRA, come nella lista dei
  /// messaggi: senza questa misura le famiglie di domande riposavano DIETRO
  /// il compositore sospeso, e per leggerle bisognava indovinare che sotto
  /// il vetro ci fosse qualcosa. La misura arriva dalla schermata, che e'
  /// l'unica a conoscere l'altezza vera del suo compositore.
  final double spazioInFondo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.lg,
        SpacingTokens.lg,
        SpacingTokens.lg + spazioInFondo,
      ),
      child: Column(
        children: [
          // Mezzo busto piu' grande, respiro idle come segnaposto.
          MaestroPresence(maestro: maestro, height: 280),
          const SizedBox(height: SpacingTokens.md),
          Text(
            greeting,
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 18).copyWith(
              color: ColorTokens.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          if (starters.isNotEmpty)
            _Famiglia(
              chiave: const Key('chat_famiglia_frequenti'),
              etichetta: 'Domande frequenti',
              domande: starters,
              enabled: enabled,
              onStarter: onStarter,
              palette: palette,
            ),
          if (personali.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.md),
            _Famiglia(
              chiave: const Key('chat_famiglia_personali'),
              etichetta: 'Domande personali',
              domande: personali,
              enabled: enabled,
              onStarter: onStarter,
              palette: palette,
            ),
          ],
        ],
      ),
    );
  }
}

/// Una famiglia di domande, con la sua etichetta sopra i chip.
class _Famiglia extends StatelessWidget {
  const _Famiglia({
    required this.chiave,
    required this.etichetta,
    required this.domande,
    required this.enabled,
    required this.onStarter,
    required this.palette,
  });

  final Key chiave;
  final String etichetta;
  final List<String> domande;
  final bool enabled;
  final ValueChanged<String> onStarter;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: chiave,
      children: [
        Text(etichetta,
            style: TypographyTokens.label(size: 12).copyWith(
                color: palette.goldSoft, letterSpacing: 1.2)),
        const SizedBox(height: SpacingTokens.xs),
        Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            children: [
              for (final s in domande)
                _StarterChip(
                  label: s,
                  onTap: enabled ? () => onStarter(s) : null,
                  palette: palette,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({
    required this.label,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final VoidCallback? onTap;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TypographyTokens.body(size: 15)
              .copyWith(color: palette.goldSoft),
        ),
      ),
    );
  }
}
