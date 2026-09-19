import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// UNA RIGA CHE APRE UN SOTTO MENU', con la stessa forma di quelle che
/// portano un interruttore. Ordine CN voce 07.
///
/// **Perche' non si e' copiata dal menu' utente.** Li' esiste gia' una riga
/// che naviga, ma e' privata dentro `account_screen.dart` e porta con se' la
/// logica di quel menu'. Copiarla avrebbe creato due righe identiche che
/// divergono al primo che ne cambia una: e' la stessa ragione per cui
/// `RigaInterruttore` e' uscita da `settings_screen.dart` con l'ordine CE.
class RigaCheApre extends StatelessWidget {
  const RigaCheApre({
    super.key,
    required this.itemKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.onTap,
  });

  final Key itemKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final MaestroPalette palette;

  /// Nullo quando la riga non si puo' toccare: cio' che sta dietro e' gia'
  /// governato da un comando spento, e aprirlo mostrerebbe una pagina di
  /// comandi che non fanno niente.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final vivo = onTap != null;
    final colore = vivo ? palette.goldSoft : ColorTokens.textSecondary;
    return InkWell(
      enableFeedback: false,
      key: itemKey,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: colore, size: 22),
            const SizedBox(width: SpacingTokens.md),
            // **IL TESTO DEVE POTER CEDERE**, voce CM.09 famiglia A: accanto
            // ci sono un'icona e una freccia, tutte e due di misura fissa.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: colore)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Icon(Icons.chevron_right_rounded, color: colore),
          ],
        ),
      ),
    );
  }
}
