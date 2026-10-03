import 'package:flutter/material.dart';

import '../../core/legal/pagina_legale.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'vestito_del_menu_utente.dart';

/// LA PAGINA LEGALE, UNA SOLA. Ordine BH voce 07, allargata dall'ordine EA
/// voce 18.
///
/// Monta i testi che vivono in `core/legal/`: qui solo la forma, mai il
/// contenuto. **Tre parti in una pagina**, privacy policy, condizioni d'uso e
/// disclaimer, ognuna col suo titolo; si apre su quella che serve e le altre
/// due restano sotto, a un dito di distanza. La pagina si legge, non si
/// firma: i consensi veri si danno dove servono, come la policy racconta.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key, this.parte = ParteLegale.privacy});

  /// Da quale delle tre parti si apre.
  final ParteLegale parte;

  /// La rotta, che apre sulla parte chiesta. **Il nome resta quello di
  /// prima**, e non e' pigrizia: `PrivacyPolicyScreen.route()` e' la porta
  /// che l'app chiama da tre punti e che una guardia pretende, e cambiarlo
  /// avrebbe spostato un difetto dentro un lavoro che non lo riguarda.
  static Route<void> route({ParteLegale parte = ParteLegale.privacy}) =>
      PassaggioDelCerchio.rotta<void>((_) => VestitoDelMenuUtente(
            seme: 13,
            child: PrivacyPolicyScreen(parte: parte),
          ));

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final Map<ParteLegale, GlobalKey> _ancore = {
    for (final p in ParteLegale.values) p: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    // **SI APRE DOVE SERVE, e senza animazione**: chi tocca "Disclaimer" deve
    // trovarsi il disclaimer, non guardare la pagina che scorre da sola.
    if (widget.parte != ParteLegale.privacy) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _vaiA(widget.parte));
    }
  }

  void _vaiA(ParteLegale parte) {
    final contesto = _ancore[parte]?.currentContext;
    if (contesto == null) return;
    Scrollable.ensureVisible(contesto,
        duration: Duration.zero, alignment: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Privacy, condizioni e disclaimer'),
      ),
      extendBodyBehindAppBar: false,
      body: CosmosBackground(
        child: ListView(
          key: const Key('privacy_policy_lista'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.md, SpacingTokens.sm,
              SpacingTokens.md, SpacingTokens.xl),
          children: [
            // **LE TRE PORTE IN CIMA**, cosi' chi arriva per una delle altre
            // due non deve scorrere per sapere che ci sono.
            Wrap(
              key: const Key('pagina_legale_indice'),
              spacing: SpacingTokens.sm,
              children: [
                for (final p in ParteLegale.values)
                  TextButton(
                    key: Key('pagina_legale_vai_${p.ancora}'),
                    onPressed: () => _vaiA(p),
                    child: Text(p.titolo,
                        style: TypographyTokens.label()
                            .copyWith(color: palette.goldSoft)),
                  ),
              ],
            ),
            for (final parte in paginaLegale) ...[
              const SizedBox(height: SpacingTokens.lg),
              Text(parte.parte.titolo,
                  key: _ancore[parte.parte],
                  style: TypographyTokens.titoloDiSchermata()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.xs),
              Text('Ultimo aggiornamento: ${parte.data}',
                  key: parte.parte == ParteLegale.privacy
                      ? const Key('privacy_policy_data')
                      : Key('pagina_legale_data_${parte.parte.ancora}'),
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
              const SizedBox(height: SpacingTokens.sm),
              Text(parte.apertura,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
              for (final sezione in parte.sezioni) ...[
                const SizedBox(height: SpacingTokens.lg),
                Text(sezione.titolo,
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xs),
                Text(sezione.corpo,
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textSecondary, height: 1.5)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
