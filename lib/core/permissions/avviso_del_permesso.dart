import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'app_permission.dart';
import 'esito_del_permesso.dart';
import 'registro_dei_permessi.dart';

/// L'AVVISO DEL PERMESSO NEGATO: uno solo per tutta l'app.
///
/// Ordine 2166, voce 2. La regola dei tre esiti distinti era viva in un solo
/// punto, il Tramonto, e in una forma scritta a mano li' dentro. Copiarla a
/// mano nelle altre schermate avrebbe prodotto quattro avvisi diversi il
/// giorno che uno viene corretto: questo componente e' la forma, e le parole
/// vengono da `ParoleDelPermesso`, il ripiego dal registro dei permessi.
///
/// Chi lo monta passa l'esito e cosa fare per richiedere. Quando l'esito e'
/// negato per sempre, il pulsante NON richiede: apre le impostazioni, perche'
/// chiedere ancora non mostrerebbe piu' niente e sembrerebbe un pulsante
/// rotto.
class AvvisoDelPermesso extends StatelessWidget {
  const AvvisoDelPermesso({
    super.key,
    required this.chiave,
    required this.permesso,
    required this.esito,
    required this.palette,
    required this.onRichiedi,
    this.onApriImpostazioni,
  });

  /// Un nome breve della schermata che lo monta: entra nella chiave del
  /// widget, cosi' le prove possono cercarlo per punto.
  final String chiave;

  final AppPermission permesso;
  final EsitoDelPermesso esito;
  final MaestroPalette palette;

  /// Chiede di nuovo il permesso. Non viene chiamato quando l'esito e'
  /// negato per sempre.
  final Future<void> Function() onRichiedi;

  /// Apre le impostazioni di sistema. Se nullo si usa quella di Geolocator,
  /// che apre la scheda dell'app e vale per tutti i permessi.
  final Future<void> Function()? onApriImpostazioni;

  @override
  Widget build(BuildContext context) {
    if (esito == EsitoDelPermesso.concesso) return const SizedBox.shrink();
    final ripiego = RegistroDeiPermessi.di(permesso).ripiego;
    final azione = ParoleDelPermesso.azione(esito);
    final perSempre = esito == EsitoDelPermesso.negatoPerSempre;

    return Container(
      key: Key('avviso_permesso_$chiave'),
      margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        // Opaco, composto una volta: sotto passa il cosmo o la scena del
        // rito, e un velo trasparente lascerebbe leggere attraverso.
        color: Color.alphaBlend(
            palette.surfaceElevated.withValues(alpha: 0.55), palette.deepest),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ParoleDelPermesso.titolo(permesso, esito),
            key: Key('avviso_permesso_titolo_$chiave'),
            style: TypographyTokens.label(size: 13)
                .copyWith(color: palette.goldSoft, letterSpacing: 1.1),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            ParoleDelPermesso.corpo(permesso, esito, ripiego: ripiego),
            style: TypographyTokens.body(size: 13.5)
                .copyWith(color: ColorTokens.textPrimary, height: 1.4),
          ),
          if (azione != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            TextButton(
              key: Key(perSempre
                  ? 'avviso_permesso_impostazioni_$chiave'
                  : 'avviso_permesso_richiedi_$chiave'),
              onPressed: () async {
                if (perSempre) {
                  final apri = onApriImpostazioni ??
                      () async {
                        await Geolocator.openAppSettings();
                      };
                  await apri();
                  return;
                }
                await onRichiedi();
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.md, vertical: 8),
                backgroundColor: palette.gold.withValues(alpha: 0.14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusPill),
                  side:
                      BorderSide(color: palette.gold.withValues(alpha: 0.5)),
                ),
              ),
              child: Text(azione,
                  style: TypographyTokens.label(size: 13)
                      .copyWith(color: palette.goldSoft)),
            ),
          ],
        ],
      ),
    );
  }
}
