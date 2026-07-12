import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../widgets/maestro_presence.dart';

/// Apertura della chat prima del primo messaggio: la presenza del Maestro con
/// la sua aura e un invito caldo. Il livello visivo arriva prima del testo,
/// come vuole la legge del visivo. Gli spunti toccabili vivono nella barra dei
/// suggerimenti sopra il composer, sempre a portata.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.maestro,
    required this.greeting,
  });

  final Maestro maestro;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.xl,
      ),
      child: Column(
        children: [
          MaestroPresence(maestro: maestro, height: 190),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            greeting,
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 18).copyWith(
              color: ColorTokens.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
