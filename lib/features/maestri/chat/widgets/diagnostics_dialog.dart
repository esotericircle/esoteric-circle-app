import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../services/ai/registro_dei_guasti.dart';
import '../../../../services/firebase/attestazione.dart';

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
  RegistroDeiGuasti? guasti,
  EsitoAttestazione attestazione = EsitoAttestazione.installata,
  String? nota,
  String? appCheckDebugToken,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Riavvolto in MaestroScope: il foglio vive nell'overlay del navigator,
    // fuori dallo scope della schermata, e senza questo non troverebbe la
    // palette del Maestro attivo.
    builder: (_) => MaestroScope(
      child: _DiagnosticsSheet(
        aiReady: aiReady,
        memoryPersistent: memoryPersistent,
        guasti: guasti,
        attestazione: attestazione,
        nota: nota,
        appCheckDebugToken: appCheckDebugToken,
      ),
    ),
  );
}

class _DiagnosticsSheet extends StatelessWidget {
  const _DiagnosticsSheet({
    required this.aiReady,
    required this.memoryPersistent,
    required this.guasti,
    required this.attestazione,
    required this.nota,
    required this.appCheckDebugToken,
  });

  final bool aiReady;
  final bool memoryPersistent;

  /// Il registro dei guasti della voce. E' la ragione per cui questo pannello
  /// esiste ancora: prima diceva "Voce di Medora: attiva" anche quando ogni
  /// chiamata falliva, perche' leggeva `isReady`, che risponde sempre di si'.
  final RegistroDeiGuasti? guasti;

  /// Com'e' andata l'attestazione. Si mostra SEMPRE, anche quando va bene:
  /// un pannello che tace su cio' che non e' installato mente per omissione.
  final EsitoAttestazione attestazione;

  /// La nota diagnostica dell'avvio, per esempio il motivo per cui la memoria
  /// non e' persistente. Esisteva gia' in AppServices e non la leggeva nessuno.
  final String? nota;

  final String? appCheckDebugToken;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ultimo = guasti?.ultimo;
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
            label: 'Voce del Maestro',
            value: !aiReady
                ? 'non configurata'
                : ultimo == null
                    ? 'attiva'
                    : 'accesa ma in guasto',
            good: aiReady && ultimo == null,
          ),
          _StatusRow(
            label: 'Memoria',
            value: memoryPersistent ? 'persistente' : 'di sessione',
            good: memoryPersistent,
          ),
          _StatusRow(
            label: 'Attestazione',
            value: switch (attestazione) {
              EsitoAttestazione.installata => 'installata',
              EsitoAttestazione.nonInstallataPerScelta =>
                'non installata, per scelta',
              EsitoAttestazione.fallita => 'installata ma fallita',
            },
            good: attestazione == EsitoAttestazione.installata,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            Attestazione.ragioneDi(attestazione),
            style: TypographyTokens.body(size: 13)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          if (nota != null && nota!.trim().isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Nota dell\'avvio',
              style: TypographyTokens.body(size: 15, weight: 600)
                  .copyWith(color: palette.goldSoft),
            ),
            const SizedBox(height: SpacingTokens.xxs),
            Text(
              nota!,
              style: TypographyTokens.body(size: 13)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
          if (ultimo != null) ...[
            const SizedBox(height: SpacingTokens.lg),
            Text(
              'Ultimo guasto della voce',
              style: TypographyTokens.body(size: 15, weight: 600)
                  .copyWith(color: palette.goldSoft),
            ),
            const SizedBox(height: SpacingTokens.xs),
            _CausaBox(guasto: ultimo),
          ],
          const SizedBox(height: SpacingTokens.lg),
          Text(
            'Token di debug App Check',
            style: TypographyTokens.body(size: 15, weight: 600)
                .copyWith(color: palette.goldSoft),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Serve solo per attivare l\'enforcement di App Check. Per la prima '
            'prova non è necessario.',
            style: TypographyTokens.body(size: 13)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _DebugTokenBox(token: appCheckDebugToken),
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

/// La causa vera dell'ultimo silenzio, per esteso e copiabile.
///
/// Mostra il tipo dell'eccezione prima del messaggio, perche' il tipo e' il
/// dato che distingue una quota finita da un servizio spento, e per due giri
/// di lavoro era esattamente il dato che si perdeva.
class _CausaBox extends StatelessWidget {
  const _CausaBox({required this.guasto});

  final GuastoDellaVoce guasto;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${guasto.operazione}: ${guasto.tipo}',
                  style: TypographyTokens.body(size: 14, weight: 600),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: guasto.riga));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Causa copiata')),
                  );
                },
                child:
                    Icon(Icons.copy_rounded, color: palette.goldSoft, size: 20),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            guasto.messaggio,
            style: TypographyTokens.body(size: 13)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          if (guasto.eLApiSpenta) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Non è un difetto dell\'app. Sul progetto Google manca l\'API '
              'firebasevertexai.googleapis.com: finché resta spenta nessuna '
              'chiamata arriva a Gemini.',
              style: TypographyTokens.body(size: 13)
                  .copyWith(color: palette.goldSoft),
            ),
          ],
        ],
      ),
    );
  }
}

class _DebugTokenBox extends StatelessWidget {
  const _DebugTokenBox({required this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
              token ??
                  'Non disponibile in questa build. Compare quando la chat gira su Firebase in debug.',
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
                Clipboard.setData(ClipboardData(text: token!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token copiato')),
                );
              },
              child: Icon(Icons.copy_rounded, color: palette.goldSoft, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
