import 'package:flutter/material.dart';

import '../theme/maestro_scope.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// L'INTERRUTTORE DEL CERCHIO: uno solo, col colore del Maestro attivo.
///
/// **Perche' esiste.** "Lega al cielo di oggi", nel Test Archetipo e nella
/// Costellazione del Viso, usava lo `SwitchListTile` standard di Material dentro
/// due schermate tutte oro e verde: erano gli unici due elementi che sembravano
/// venire da un'altra app. Non bastava colorare il pollice, come si faceva: la
/// TRACCIA restava quella di Material, grigia da spento e viola da acceso, ed e'
/// la parte piu' grande.
///
/// Sta nel design system e non nelle due schermate perche' il terzo interruttore
/// che nascera' non deve ricominciare da capo. Chi usa `Switch` direttamente e'
/// enumerato da una prova.
class InterruttoreDelCerchio extends StatelessWidget {
  const InterruttoreDelCerchio({
    super.key,
    required this.acceso,
    required this.onCambia,
    required this.titolo,
    this.sottotitolo,
  });

  final bool acceso;
  final ValueChanged<bool>? onCambia;
  final String titolo;
  final String? sottotitolo;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.of(context);
    final sotto = sottotitolo;
    return SwitchListTile(
      value: acceso,
      onChanged: onCambia,
      contentPadding: EdgeInsets.zero,
      // Tutte e quattro le facce, non solo il pollice acceso: da spento il
      // grigio di Material era vistoso quanto il viola.
      activeThumbColor: palette.gold,
      activeTrackColor: palette.goldSoft.withValues(alpha: 0.45),
      inactiveThumbColor: palette.goldSoft.withValues(alpha: 0.55),
      inactiveTrackColor: palette.deepest.withValues(alpha: 0.55),
      trackOutlineColor:
          WidgetStatePropertyAll(palette.goldSoft.withValues(alpha: 0.45)),
      title: Text(titolo,
          style: TypographyTokens.display(size: 16)
              .copyWith(color: ColorTokens.textPrimary)),
      subtitle: sotto == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.xs),
              child: Text(sotto,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textSecondary)),
            ),
    );
  }
}
