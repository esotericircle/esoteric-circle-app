import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// **IL RIQUADRO ARANCIONE DELL'APPROFONDIMENTO.** Ordine FN, 13 ottobre
/// 2026.
///
/// Il fondatore: con la profondita' Lunga, due paragrafi in piu' con
/// risposte dirette di approfondimento, "incorniciati da un riquadro
/// arancione". Non l'oro del Maestro: quello lo porta gia' `RiquadroInEvidenza`
/// per il secondo paragrafo del responso normale, e un colore suo distingue
/// a colpo d'occhio il contenuto che solo la Lunga aggiunge.
class RiquadroArancione extends StatelessWidget {
  const RiquadroArancione({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        key: const Key('riquadro_approfondimento'),
        width: double.infinity,
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: ColorTokens.arancioDellaCarta.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(
              color: ColorTokens.arancioDellaCarta.withValues(alpha: 0.55)),
        ),
        child: child,
      );
}
