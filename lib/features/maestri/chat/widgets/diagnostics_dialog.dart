import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../services/firebase/app_check_debug.dart';

/// Pannello diagnostico della chat, discreto e a portata di tocco.
///
/// Mostra se la voce del Maestro e' attiva, come sta la memoria e, quando
/// serve, il token di debug di App Check da copiare dal telefono per attivare
/// l'enforcement senza un PC. Non e' un pannello per l'utente finale, e' uno
/// strumento di messa a punto per la Demo.
Future<void> showChatDiagnostics(
  BuildContext context, {
  required bool aiReady,
  required bool memoryPersistent,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DiagnosticsSheet(
      aiReady: aiReady,
      memoryPersistent: memoryPersistent,
    ),
  );
}

class _DiagnosticsSheet extends StatelessWidget {
  const _DiagnosticsSheet({
    required this.aiReady,
    required this.memoryPersistent,
  });

  final bool aiReady;
  final bool memoryPersistent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        top: SpacingTokens.lg,
        bottom: SpacingTokens.xl + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpacingTokens.radiusXl),
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Messa a punto', style: TypographyTokens.display(size: 20)),
          const SizedBox(height: SpacingTokens.md),
          _StatusRow(
            label: 'Voce di Medora',
            value: aiReady ? 'attiva' : 'non configurata',
            good: aiReady,
          ),
          _StatusRow(
            label: 'Memoria',
            value: memoryPersistent ? 'persistente' : 'di sessione',
            good: memoryPersistent,
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            'Token di debug App Check',
            style: TypographyTokens.body(size: 15, weight: 600)
                .copyWith(color: palette.goldSoft),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Serve solo per attivare l\'enforcement di App Check. Per la prima '
            'prova non e\' necessario.',
            style: TypographyTokens.body(size: 13)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.sm),
          const _DebugTokenBox(),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.good,
  });

  final String label;
  final String value;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            good ? Icons.check_circle_outline : Icons.info_outline,
            size: 18,
            color: good ? palette.goldSoft : ColorTokens.textMuted,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Text(
            '$label: ',
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          Text(
            value,
            style: TypographyTokens.body(size: 15, weight: 600),
          ),
        ],
      ),
    );
  }
}

class _DebugTokenBox extends StatelessWidget {
  const _DebugTokenBox();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return FutureBuilder<String?>(
      future: AppCheckDebug.androidDebugToken(),
      builder: (context, snapshot) {
        final waiting = snapshot.connectionState == ConnectionState.waiting;
        final token = snapshot.data;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  waiting
                      ? 'Lettura in corso...'
                      : (token ??
                          'Non disponibile. Compare dopo il primo messaggio, con Firebase configurato.'),
                  style: TypographyTokens.body(size: 14).copyWith(
                    color: token != null
                        ? ColorTokens.textPrimary
                        : ColorTokens.textMuted,
                  ),
                ),
              ),
              if (token != null) ...[
                const SizedBox(width: SpacingTokens.sm),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: token));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token copiato')),
                    );
                  },
                  child: Icon(Icons.copy_rounded,
                      color: palette.goldSoft, size: 20),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
