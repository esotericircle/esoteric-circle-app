import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../theme/maestro_scope.dart';
import '../tokens/spacing_tokens.dart';

/// **IL TERZO PARAGRAFO DELLA LUNGA, IN UN RIQUADRO.** Il fondatore, 1 ottobre
/// 2026: *"Per ogni risposta, quando c'è la profondità lunga il terzo
/// paragrafo inseriscilo in un riquadro, così da sembrare in evidenza e
/// staccare dalla monotonia del testo."*
///
/// Nella Lunga i paragrafi sono quattro (la risposta, che cosa fare, la
/// risposta lunga, che cosa fare nella Lunga): il terzo e' quello che la
/// Lunga aggiunge, e il riquadro lo mette in evidenza col fondo appena
/// dorato e il filo d'oro del Maestro.
class RiquadroInEvidenza extends StatelessWidget {
  const RiquadroInEvidenza({super.key, required this.child, this.palette});

  final Widget child;
  final MaestroPalette? palette;

  /// Quale paragrafo va nel riquadro, contando da zero, quando i paragrafi
  /// sono [quanti]: il terzo, solo nella Lunga (quattro paragrafi).
  static bool eIlTerzoDellaLunga(int indice, int quanti) =>
      quanti == 4 && indice == 2;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? MaestroScope.forse(context) ?? MaestroPalette.neutral;
    return Container(
      key: const Key('paragrafo_in_evidenza'),
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: p.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: p.gold.withValues(alpha: 0.45)),
      ),
      child: child,
    );
  }
}
