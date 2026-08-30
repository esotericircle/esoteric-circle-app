import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// UNA RIGA CON UN INTERRUTTORE, la forma che le Impostazioni usano da sempre.
///
/// **Era privata dentro `settings_screen.dart` e adesso vive per conto suo.**
/// Ordine CE voce 03: l'interruttore della misura del ritorno si e' spostato
/// nel sotto menu' e continua ad avere la stessa forma delle altre righe.
/// Copiare quella forma nel file nuovo avrebbe creato due righe identiche che
/// divergono al primo che ne cambia una.
class RigaInterruttore extends StatelessWidget {
  const RigaInterruttore({
    super.key,
    required this.itemKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.palette,
  });

  final Key itemKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;

  /// Nullo quando la riga non si puo' toccare: l'interruttore unico e'
  /// spento e sotto di lui non c'e' piu' niente da decidere.
  final ValueChanged<bool>? onChanged;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TypographyTokens.display(size: 16)),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  subtitle,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            key: itemKey,
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? palette.deepest
                  : palette.goldSoft.withValues(alpha: 0.7),
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? palette.gold
                  : palette.surfaceElevated,
            ),
            trackOutlineColor: WidgetStateProperty.all(
              palette.gold.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}
