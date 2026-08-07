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
/// Il Maestro col mezzo busto in alto, il benvenuto, l'INVITO A TOCCARE LE
/// STELLINE e un assaggio di TRE domande in una riga orizzontale dentro i
/// margini. Ordine 2163, voce 4: la colonna lunga delle famiglie che viveva
/// qui era una SECONDA PORTA per cio' che il pannello gia' offre, scorreva
/// dietro al campo e dietro alla barra, ed e' stata TOLTA, non corretta.
/// Le famiglie intere e divise vivono nel pannello dei suggerimenti.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.maestro,
    required this.greeting,
    required this.assaggio,
    required this.onStarter,
    required this.onSuggerimenti,
    this.enabled = true,
    this.spazioInFondo = 0,
  });

  final Maestro maestro;
  final String greeting;

  /// L'assaggio: al massimo tre domande, in una riga che scorre in
  /// orizzontale. Chi ne passa di piu' ne vede tre: il taglio sta qui,
  /// dichiarato, cosi' nessun chiamante puo' ricostruire la colonna.
  final List<String> assaggio;

  final ValueChanged<String> onStarter;

  /// Apre il pannello dei suggerimenti: e' lo stesso gesto delle stelline
  /// accanto al campo, offerto anche come invito al centro della schermata.
  final VoidCallback onSuggerimenti;

  final bool enabled;

  /// IL FONDO PORTA IL COMPOSITORE E LA BARRA, come nella lista dei
  /// messaggi: la misura arriva dalla schermata, che e' l'unica a conoscere
  /// l'altezza vera del suo compositore.
  final double spazioInFondo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final voci = assaggio.take(3).toList();
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.lg,
        SpacingTokens.lg,
        SpacingTokens.lg + spazioInFondo,
      ),
      child: Column(
        children: [
          // 220 E NON 280, misurato sulla misura del fondatore (360x797):
          // con 280 l'assaggio nasceva DIETRO il vetro del campo sospeso, e
          // il primo sguardo deve avere invito e assaggio in chiaro sopra
          // il campo, senza scorrere. Ordine 2163, voce 4.
          MaestroPresence(maestro: maestro, height: 220),
          const SizedBox(height: SpacingTokens.md),
          Text(
            greeting,
            key: const Key('chat_benvenuto'),
            textAlign: TextAlign.center,
            // AL PRIMARIO, ordine 2163 voce 9: il benvenuto era grigio
            // (textSecondary) sul fondale scuro, la prima cosa che si legge
            // ed era la meno leggibile. Il minimo dichiarato per il testo
            // d'apertura e' 7 di contrasto, misurato dalla prova.
            style: TypographyTokens.body(size: 18).copyWith(
              color: ColorTokens.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // L'INVITO ALLE STELLINE: un pulsante vero con area di tocco
          // piena, non una scritta.
          TextButton.icon(
            key: const Key('chat_invito_stelline'),
            // APRE SEMPRE, anche a voce spenta: guardare le domande non
            // richiede la voce, e l'icona accanto al campo non ha guardia.
            // Due porte sullo stesso pannello, UNA regola di accesso.
            onPressed: onSuggerimenti,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg, vertical: 10),
              backgroundColor: palette.gold.withValues(alpha: 0.14),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusPill),
                side: BorderSide(
                    color: palette.gold.withValues(alpha: 0.5)),
              ),
            ),
            icon: Icon(Icons.auto_awesome_outlined,
                color: palette.goldSoft, size: 18),
            label: Text(
              'Tocca per tutte le domande',
              style: TypographyTokens.label(size: 13)
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.4),
            ),
          ),
          if (voci.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.lg),
            // L'assaggio: UNA riga che scorre in orizzontale, dentro i
            // margini. Mai una colonna che occupa la schermata.
            SizedBox(
              key: const Key('chat_assaggio'),
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: voci.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: SpacingTokens.xs),
                itemBuilder: (context, i) => _VoceDAssaggio(
                  key: const Key('chat_assaggio_voce'),
                  label: voci[i],
                  onTap: enabled ? () => onStarter(voci[i]) : null,
                  palette: palette,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoceDAssaggio extends StatelessWidget {
  const _VoceDAssaggio({
    super.key,
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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TypographyTokens.body(size: 14)
              .copyWith(color: palette.goldSoft),
        ),
      ),
    );
  }
}
