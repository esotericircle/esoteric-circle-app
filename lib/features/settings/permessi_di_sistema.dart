import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LA RIGA DEI PERMESSI DI SISTEMA. Ordine CE voce 03.
///
/// **Era dentro le Impostazioni e adesso vive per conto suo**, perche' il
/// fondatore ha chiesto che "tutto quel blocco di permessi" andasse in un sotto
/// menu' dedicato. Il codice e' lo stesso di prima, spostato: cambiare una riga
/// mentre la si trasloca vorrebbe dire non sapere piu' quale delle due cose ha
/// rotto qualcosa.
class PermessiDiSistema extends StatelessWidget {
  const PermessiDiSistema({super.key, required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('settings_permessi'),
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      // Geolocator apre le impostazioni DELL'APP, non quelle della posizione:
      // e' la stessa via che il cielo usa gia' quando il permesso e' negato per
      // sempre. Nessuna dipendenza nuova per una riga.
      onTap: () => Geolocator.openAppSettings(),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Microfono, fotocamera e movimento',
                    style: TypographyTokens.display(size: 16)),
                const SizedBox(height: SpacingTokens.xxs),
                Text(
                  'Apri i permessi di sistema. Ogni esperienza che li usa '
                  'funziona anche col solo tocco.',
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}
