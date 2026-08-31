import 'package:flutter/material.dart';

import '../../core/cammino/custode_del_cammino.dart';
import '../../core/cammino/rinascita_del_cammino.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';

/// LA RIGA ONESTA DELLA RINASCITA. Ordine AR voce 06.
///
/// **Perche' si dice, e perche' si dice una volta sola.** Chi riapre l'app e
/// trova il Journal spento penserebbe a un guasto, o peggio a un furto: il
/// Cammino e' stato riprogettato e il suo riparte da qui, e la prima cosa che
/// deve sapere e' che gli Eos non sono stati toccati. Poi non si ripete mai
/// piu': un annuncio che torna a ogni apertura diventa un rimprovero.
///
/// **Non e' una SnackBar di sistema**, che in questo progetto e' vietata dove
/// la persona guarda: e' un foglio dal basso nel tono del Maestro attivo.
class FoglioDellaRinascita {
  const FoglioDellaRinascita._();

  /// Mostra la riga, se questo avvio ha davvero azzerato un cammino. Consuma
  /// il segno, cosi' il foglio non torna una seconda volta nella stessa
  /// sessione.
  static Future<void> seServe(BuildContext context) async {
    if (!CustodeDelCammino.rinascitaDaRaccontare) return;
    CustodeDelCammino.rinascitaDaRaccontare = false;
    if (!context.mounted) return;
    final palette = MaestroScope.forse(context);
    await foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (foglio) => Container(
        key: const Key('foglio_della_rinascita'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette?.surfaceElevated ?? ColorTokens.neutralSurface,
              palette?.deepest ?? ColorTokens.neutralDeepest,
            ],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Il Cammino riparte',
                key: const Key('rinascita_titolo'),
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette?.goldSoft),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                RinascitaDelCammino.rigaOnesta,
                key: const Key('rinascita_riga'),
                style: TypographyTokens.corpo().copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('rinascita_avanti'),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette?.primary,
                    foregroundColor: palette?.onPrimary,
                  ),
                  onPressed: () => Navigator.of(foglio).pop(),
                  child: Text('Ricomincio',
                      style: TypographyTokens.etichetta()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
